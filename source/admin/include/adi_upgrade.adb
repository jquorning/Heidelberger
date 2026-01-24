--
-- WordPress Upgrade API
--
-- Most of the functions are pluggable and can be overwritten.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Php.Arrays;
with Php.Files;
with Php.Lists;
with Php.Misc;
with Php.Preg;
with Php.Strings;

with Globals;
with UStrings;
with Helpers;
with Lists;
with Wp_Common;

with Adi_Plugins;
with Adi_Schemas;

with Inc_Caches;
with Inc_Capabilities;
with Class_Errors;
with Class_Roles;
with Class_Users;
with Class_WpDB;
with Inc_Cron;
with Inc_Formatting;
with Inc_Functions;
with Inc_Load;
with Inc_L10n;
with Inc_Ms_Sites;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Rewrites;
with Inc_Roles;
with Inc_Users;
with Inc_Versions;

package body Adi_Upgrade
is
   use Lists;

   ----------------
   -- Wp_Install --
   ----------------

   function Wp_Install (Blog_Title    : String;
                        User_Name     : String;
                        User_Email    : String;
                        Is_Public     : Boolean;
                        Deprecated    : String := "";
                        User_Password : String := "";
                        Language      : String := "")
                        return Arrays.Array_Type
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Adi_Schemas;
      use Inc_Caches;
      use Class_Users;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
--    use Inc_Plugins;
      use Inc_Rewrites;
      use Inc_Users;
   begin
      if not Empty (Deprecated) then
         X_Deprecated_Argument ("__FUNCTION__", "2.6.0");
      end if;

      Wp_Check_MySQL_Version;
      Wp_Cache_Flush;
      Make_DB_Current_Silent;
      Populate_Options;
      Populate_Roles;

      Update_Option ("blogname",    From_String  (Blog_Title));
      Update_Option ("admin_email", From_String  (User_Email));
      Update_Option ("blog_public", From_Boolean (Is_Public));

      -- Freshness of site - in the future, this could get more specific about
      -- actions taken, perhaps.
      Update_Option ("fresh_site", From_Integer (1));

      if Language /= "" then
         Update_Option ("WPLANG", From_String (Language));
      end if;

      declare
         Guess_URL : constant String := Wp_Guess_URL;
      begin
         Update_Option ("siteurl", From_String (Guess_URL));

         -- If not a public site, don't ping.
         if not Is_Public then
            Update_Option ("default_pingback_flag", From_Integer (0));
         end if;

         --
         -- Create default user. If the user already exists, the user tables are
         -- being shared among sites. Just set the role in that case.
         --
         declare
            User_Id         : Integer := Username_Exists (User_Name);
            User_Password_2 : constant String  := Trim (User_Password);
            Email_Password  : Boolean := False;
            User_Created    : Boolean := False;

            Message : Unbounded_String;
         begin
            if User_Id = 0 and then Empty (User_Password_2) then
               declare
                  User_Password : constant String := Wp_Generate_Password (12, False);
                  User_Id       : constant Integer :=
                    Wp_Create_User (User_Name, User_Password, User_Email);
               begin
                  Update_User_Meta (User_Id,
                                    "default_password_nag",
                                    Empty_Array); -- True);
               end;
               Message        := +abs "<strong><em>Note that password</em></strong> carefully! It is a <em>random</em> password that was generated just for you.";
               Email_Password := True;
               User_Created   := True;
            elsif User_Id = 0 then
               -- Password has been provided.
               Message      := +"<em>" & abs "Your chosen password." & "</em>";
               User_Id      := Wp_Create_User (User_Name, User_Password, User_Email);
               User_Created := True;
            else
               Message := +abs "User already exists. Password inherited.";
            end if;

            declare
               User : Wp_User := X_Construct (User_Id);
            begin
               User.Set_Role ("administrator");

               if User_Created then
                  User.Prop.User_URL := +Guess_URL;
                  Wp_Update_User (User);
               end if;

               Wp_Install_Defaults (User_Id);

               Wp_Install_Maybe_Enable_Pretty_Permalinks;

               Flush_Rewrite_Rules;

               Wp_New_Blog_Notification
                 (Blog_Title, Guess_URL, User_Id,
                  (if Email_Password then User_Password
                   else abs "The password you chose during installation."));

               Wp_Cache_Flush;

               --
               -- Fires after a site is fully installed.
               --
               -- @since 3.9.0
               --
               -- @param WP_User user The site owner.
               --
               Do_Action ("wp_install", User);

               return
                 To_Array (List => (
                   Build ("url",              Guess_URL),
                   Build ("user_id",          User_Id),
                   Build ("password",         User_Password),
                   Build ("password_message", -Message)
                 ));
            end;
         end;
      end;
   end Wp_Install;

   ----------------
   -- Wp_Upgrade --
   ----------------

   procedure Wp_Upgrade
   is
      use Wp_Common;
      use Inc_Caches;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Ms_Sites;
      use Inc_Versions;
--    global wp_current_db_version, wp_db_version, wpdb;
   begin
      Wp_Current_DB_Version := As_Integer (X_Get_Option ("db_version"));

      -- We are up to date. Nothing to do.
      if Wp_DB_Version = Wp_Current_DB_Version then
         return;
      end if;

      if not Is_Blog_Installed then
         return;
      end if;

      Wp_Check_MySQL_Version;
      Wp_Cache_Flush;
      Pre_Schema_Upgrade;
      Make_DB_Current_Silent;
      Upgrade_All;

      if Is_Multisite and then Is_Main_Site then
         Upgrade_Network;
      end if;

      Wp_Cache_Flush;

      if Is_Multisite then
         Update_Site_Meta (Get_Current_Blog_Id, "db_version",
                           From_Integer (Wp_DB_Version));

         Update_Site_Meta (Get_Current_Blog_Id, "db_last_updated",
                           From_String (Php.Misc.Microtime));
      end if;

      --
      -- Fires after a site is fully upgraded.
      --
      -- @since 3.9.0
      --
      -- @param int wp_db_version         The new wp_db_version.
      -- @param int wp_current_db_version The old (current) wp_db_version.
      --
      Do_Action ("wp_upgrade", Wp_DB_Version, Wp_Current_DB_Version);
   end Wp_Upgrade;

   -----------------
   -- Upgrade_All --
   -----------------

   procedure Upgrade_All
   is
      use Adi_Schemas;
      use Inc_Options;
      use Inc_Versions;
--    global wp_current_db_version, wp_db_version;
   begin
      Wp_Current_DB_Version := As_Integer (X_Get_Option ("db_version"));

      -- We are up to date. Nothing to do.
      if Wp_DB_Version = Wp_Current_DB_Version then
         return;
      end if;

      -- If the version is not set in the DB, try to guess the version.
      if Wp_Current_DB_Version = 0 then -- ???
--    if Empty (Wp_Current_DB_Version) then
         Wp_Current_DB_Version := 0;

         -- If the template option exists, we have 1.5.
         declare
            Template : constant Multi_Type :=
              X_Get_Option ("template");
         begin
            if Kind_Of (Template) /= Kind_Null then
--          if not Empty (Template) then
               Wp_Current_DB_Version := 2541;
            end if;
         end;
      end if;

      if Wp_Current_DB_Version < 6039 then
         Upgrade_230_Options_Table;
      end if;

      Populate_Options;

      if Wp_Current_DB_Version < 2541 then
         Upgrade_100;
         Upgrade_101;
         Upgrade_110;
         Upgrade_130;
      end if;

      if Wp_Current_DB_Version < 3308 then
         Upgrade_160;
      end if;

      if Wp_Current_DB_Version < 4772 then
         Upgrade_210;
      end if;

      if Wp_Current_DB_Version < 4351 then
         Upgrade_Old_Slugs;
      end if;

      if Wp_Current_DB_Version < 5539 then
         Upgrade_230;
      end if;

      if Wp_Current_DB_Version < 6124 then
         Upgrade_230_Old_Tables;
      end if;

      if Wp_Current_DB_Version < 7499 then
         Upgrade_250;
      end if;

      if Wp_Current_DB_Version < 7935 then
         Upgrade_252;
      end if;

      if Wp_Current_DB_Version < 8201 then
         Upgrade_260;
      end if;

      if Wp_Current_DB_Version < 8989 then
         Upgrade_270;
      end if;

      if Wp_Current_DB_Version < 10360 then
         Upgrade_280;
      end if;

      if Wp_Current_DB_Version < 11958 then
         Upgrade_290;
      end if;

      if Wp_Current_DB_Version < 15260 then
         Upgrade_300;
      end if;

      if Wp_Current_DB_Version < 19389 then
         Upgrade_330;
      end if;

      if Wp_Current_DB_Version < 20080 then
         Upgrade_340;
      end if;

      if Wp_Current_DB_Version < 22422 then
         Upgrade_350;
      end if;

      if Wp_Current_DB_Version < 25824 then
         Upgrade_370;
      end if;

      if Wp_Current_DB_Version < 26148 then
         Upgrade_372;
      end if;

      if Wp_Current_DB_Version < 26691 then
         Upgrade_380;
      end if;

      if Wp_Current_DB_Version < 29630 then
         Upgrade_400;
      end if;

      if Wp_Current_DB_Version < 33055 then
         Upgrade_430;
      end if;

      if Wp_Current_DB_Version < 33056 then
         Upgrade_431;
      end if;

      if Wp_Current_DB_Version < 35700 then
         Upgrade_440;
      end if;

      if Wp_Current_DB_Version < 36686 then
         Upgrade_450;
      end if;

      if Wp_Current_DB_Version < 37965 then
         Upgrade_460;
      end if;

      if Wp_Current_DB_Version < 44719 then
         Upgrade_510;
      end if;

      if Wp_Current_DB_Version < 45744 then
         Upgrade_530;
      end if;

      if Wp_Current_DB_Version < 48575 then
         Upgrade_550;
      end if;

      if Wp_Current_DB_Version < 49752 then
         Upgrade_560;
      end if;

      if Wp_Current_DB_Version < 51917 then
         Upgrade_590;
      end if;

      if Wp_Current_DB_Version < 53011 then
         Upgrade_600;
      end if;

      Maybe_Disable_Link_Manager;

      Maybe_Disable_Automattic_Widgets;

      Update_Option ("db_version",  From_Integer (Wp_DB_Version));
      Update_Option ("db_upgraded", From_Boolean (True));
   end Upgrade_All;

   -----------------
   -- Upgrade_100 --
   -----------------

   procedure Upgrade_100
   is null;
--         global wpdb;

--         -- Get the title and ID of every post, post_name to check if it already has a value.
--         posts = wpdb->get_results( "SELECT ID, post_title, post_name FROM wpdb->posts WHERE post_name = """ );
--         if ( posts ) then
--                 foreach ( posts as post ) then
--                         if ( "" === post->post_name ) then
--                                 newtitle = sanitize_title( post->post_title );
--                                 wpdb->query( wpdb->prepare( "UPDATE wpdb->posts SET post_name = %s WHERE ID = %d", newtitle, post->ID ) );
--                         end;
--                 end;
--         end;

--         categories = wpdb->get_results( "SELECT cat_ID, cat_name, category_nicename FROM wpdb->categories" );
--         foreach ( categories as category ) then
--                 if ( "" === category->category_nicename ) then
--                         newtitle = sanitize_title( category->cat_name );
--                         wpdb->update( wpdb->categories, array( "category_nicename" => newtitle ), array( "cat_ID" => category->cat_ID ) );
--                 end;
--         end;

--         sql = "UPDATE wpdb->options
--                 SET option_value = REPLACE(option_value, "wp-links/links-images/", "wp-images/links/")
--                 WHERE option_name LIKE %s
--                 AND option_value LIKE %s";
--         wpdb->query( wpdb->prepare( sql, wpdb->esc_like( "links_rating_image" ) . "%", wpdb->esc_like( "wp-links/links-images/" ) . "%" ) );

--         done_ids = wpdb->get_results( "SELECT DISTINCT post_id FROM wpdb->post2cat" );
--         if ( done_ids ) :
--                 done_posts = array();
--                 foreach ( done_ids as done_id ) :
--                         done_posts[] = done_id->post_id;
--                 endforeach;
--                 catwhere = " AND ID NOT IN (" . implode( ",", done_posts ) . ")";
--         else :
--                 catwhere = "";
--         endif;

--         allposts = wpdb->get_results( "SELECT ID, post_category FROM wpdb->posts WHERE post_category != "0" catwhere" );
--         if ( allposts ) :
--                 foreach ( allposts as post ) then
--                         -- Check to see if it"s already been imported.
--                         cat = wpdb->get_row( wpdb->prepare( "SELECT-- FROM wpdb->post2cat WHERE post_id = %d AND category_id = %d", post->ID, post->post_category ) );
--                         if ( ! cat && 0 != post->post_category ) then -- If there"s no result.
--                                 wpdb->insert(
--                                         wpdb->post2cat,
--                                         array(
--                                                 "post_id"     => post->ID,
--                                                 "category_id" => post->post_category,
--                                         )
--                                 );
--                         end;
--                 end;
--         endif;
-- end;

   -----------------
   -- Upgrade_101 --
   -----------------

   procedure Upgrade_101
   is
      use Globals;
      use UStrings;
   begin
      -- Clean up indices, add a few.
      Add_Clean_Index (-WpDB.Posts, "post_name");
      Add_Clean_Index (-WpDB.Posts, "post_status");
--    Add_Clean_Index (-WpDB.Categories, "category_nicename"); ???
      Add_Clean_Index (-WpDB.Comments, "comment_approved");
      Add_Clean_Index (-WpDB.Comments, "comment_post_ID");
      Add_Clean_Index (-WpDB.Links, "link_category");
      Add_Clean_Index (-WpDB.Links, "link_visible");
   end Upgrade_101;

   -----------------
   -- Upgrade_110 --
   -----------------

   procedure Upgrade_110
   is null;
--         global wpdb;

--         -- Set user_nicename.
--         users = wpdb->get_results( "SELECT ID, user_nickname, user_nicename FROM wpdb->users" );
--         foreach ( users as user ) then
--                 if ( "" === user->user_nicename ) then
--                         newname = sanitize_title( user->user_nickname );
--                         wpdb->update( wpdb->users, array( "user_nicename" => newname ), array( "ID" => user->ID ) );
--                 end;
--         end;

--         users = wpdb->get_results( "SELECT ID, user_pass from wpdb->users" );
--         foreach ( users as row ) then
--                 if ( ! preg_match( "/^[A-Fa-f0-9]then32end;/", row->user_pass ) ) then
--                         wpdb->update( wpdb->users, array( "user_pass" => md5( row->user_pass ) ), array( "ID" => row->ID ) );
--                 end;
--         end;

--         -- Get the GMT offset, we"ll use that later on.
--         all_options = get_alloptions_110();

--         time_difference = all_options->time_difference;

--                 server_time = time() + gmdate( "Z" );
--         weblogger_time  = server_time + time_difference-- HOUR_IN_SECONDS;
--         gmt_time        = time();

--         diff_gmt_server       = ( gmt_time - server_time ) / HOUR_IN_SECONDS;
--         diff_weblogger_server = ( weblogger_time - server_time ) / HOUR_IN_SECONDS;
--         diff_gmt_weblogger    = diff_gmt_server - diff_weblogger_server;
--         gmt_offset            = -diff_gmt_weblogger;

--         -- Add a gmt_offset option, with value gmt_offset.
--         add_option( "gmt_offset", gmt_offset );

--         /*
--         -- Check if we already set the GMT fields. If we did, then
--         -- MAX(post_date_gmt) can"t be "0000-00-00 00:00:00".
--         -- <michel_v> I just slapped myself silly for not thinking about it earlier.
--         --
--         got_gmt_fields = ( "0000-00-00 00:00:00" !== wpdb->get_var( "SELECT MAX(post_date_gmt) FROM wpdb->posts" ) );

--         if ( ! got_gmt_fields ) then

--                 -- Add or subtract time to all dates, to get GMT dates.
--                 add_hours   = (int) diff_gmt_weblogger;
--                 add_minutes = (int) ( 60-- ( diff_gmt_weblogger - add_hours ) );
--                 wpdb->query( "UPDATE wpdb->posts SET post_date_gmt = DATE_ADD(post_date, INTERVAL "add_hours:add_minutes" HOUR_MINUTE)" );
--                 wpdb->query( "UPDATE wpdb->posts SET post_modified = post_date" );
--                 wpdb->query( "UPDATE wpdb->posts SET post_modified_gmt = DATE_ADD(post_modified, INTERVAL "add_hours:add_minutes" HOUR_MINUTE) WHERE post_modified != "0000-00-00 00:00:00"" );
--                 wpdb->query( "UPDATE wpdb->comments SET comment_date_gmt = DATE_ADD(comment_date, INTERVAL "add_hours:add_minutes" HOUR_MINUTE)" );
--                 wpdb->query( "UPDATE wpdb->users SET user_registered = DATE_ADD(user_registered, INTERVAL "add_hours:add_minutes" HOUR_MINUTE)" );
--         end;

-- end;

   -----------------
   -- Upgrade_130 --
   -----------------

   procedure Upgrade_130
   is null;
--         global wpdb;

--         -- Remove extraneous backslashes.
--         posts = wpdb->get_results( "SELECT ID, post_title, post_content, post_excerpt, guid, post_date, post_name, post_status, post_author FROM wpdb->posts" );
--         if ( posts ) then
--                 foreach ( posts as post ) then
--                         post_content = addslashes( deslash( post->post_content ) );
--                         post_title   = addslashes( deslash( post->post_title ) );
--                         post_excerpt = addslashes( deslash( post->post_excerpt ) );
--                         if ( empty( post->guid ) ) then
--                                 guid = get_permalink( post->ID );
--                         end; else then
--                                 guid = post->guid;
--                         end;

--                         wpdb->update( wpdb->posts, compact( "post_title", "post_content", "post_excerpt", "guid" ), array( "ID" => post->ID ) );

--                 end;
--         end;

--         -- Remove extraneous backslashes.
--         comments = wpdb->get_results( "SELECT comment_ID, comment_author, comment_content FROM wpdb->comments" );
--         if ( comments ) then
--                 foreach ( comments as comment ) then
--                         comment_content = deslash( comment->comment_content );
--                         comment_author  = deslash( comment->comment_author );

--                         wpdb->update( wpdb->comments, compact( "comment_content", "comment_author" ), array( "comment_ID" => comment->comment_ID ) );
--                 end;
--         end;

--         -- Remove extraneous backslashes.
--         links = wpdb->get_results( "SELECT link_id, link_name, link_description FROM wpdb->links" );
--         if ( links ) then
--                 foreach ( links as link ) then
--                         link_name        = deslash( link->link_name );
--                         link_description = deslash( link->link_description );

--                         wpdb->update( wpdb->links, compact( "link_name", "link_description" ), array( "link_id" => link->link_id ) );
--                 end;
--         end;

--         active_plugins = __get_option( "active_plugins" );

--         /*
--         -- If plugins are not stored in an array, they"re stored in the old
--         -- newline separated format. Convert to new format.
--         --
--         if ( ! is_array( active_plugins ) ) then
--                 active_plugins = explode( "\n", trim( active_plugins ) );
--                 update_option( "active_plugins", active_plugins );
--         end;

--         -- Obsolete tables.
--         wpdb->query( "DROP TABLE IF EXISTS " . wpdb->prefix . "optionvalues" );
--         wpdb->query( "DROP TABLE IF EXISTS " . wpdb->prefix . "optiontypes" );
--         wpdb->query( "DROP TABLE IF EXISTS " . wpdb->prefix . "optiongroups" );
--         wpdb->query( "DROP TABLE IF EXISTS " . wpdb->prefix . "optiongroup_options" );

--         -- Update comments table to use comment_type.
--         wpdb->query( "UPDATE wpdb->comments SET comment_type="trackback", comment_content = REPLACE(comment_content, "<trackback />", "") WHERE comment_content LIKE "<trackback />%"" );
--         wpdb->query( "UPDATE wpdb->comments SET comment_type="pingback", comment_content = REPLACE(comment_content, "<pingback />", "") WHERE comment_content LIKE "<pingback />%"" );

--         -- Some versions have multiple duplicate option_name rows with the same values.
--         options = wpdb->get_results( "SELECT option_name, COUNT(option_name) AS dupes FROM `wpdb->options` GROUP BY option_name" );
--         foreach ( options as option ) then
--                 if ( 1 != option->dupes ) then -- Could this be done in the query?
--                         limit    = option->dupes - 1;
--                         dupe_ids = wpdb->get_col( wpdb->prepare( "SELECT option_id FROM wpdb->options WHERE option_name = %s LIMIT %d", option->option_name, limit ) );
--                         if ( dupe_ids ) then
--                                 dupe_ids = implode( ",", dupe_ids );
--                                 wpdb->query( "DELETE FROM wpdb->options WHERE option_id IN (dupe_ids)" );
--                         end;
--                 end;
--         end;

--         make_site_theme();
-- end;

   -----------------
   -- Upgrade_160 --
   -----------------

   procedure Upgrade_160
   is null;
--         global wpdb, wp_current_db_version;

--         populate_roles_160();

--         users = wpdb->get_results( "SELECT-- FROM wpdb->users" );
--         foreach ( users as user ) :
--                 if ( ! empty( user->user_firstname ) ) then
--                         update_user_meta( user->ID, "first_name", wp_slash( user->user_firstname ) );
--                 end;
--                 if ( ! empty( user->user_lastname ) ) then
--                         update_user_meta( user->ID, "last_name", wp_slash( user->user_lastname ) );
--                 end;
--                 if ( ! empty( user->user_nickname ) ) then
--                         update_user_meta( user->ID, "nickname", wp_slash( user->user_nickname ) );
--                 end;
--                 if ( ! empty( user->user_level ) ) then
--                         update_user_meta( user->ID, wpdb->prefix . "user_level", user->user_level );
--                 end;
--                 if ( ! empty( user->user_icq ) ) then
--                         update_user_meta( user->ID, "icq", wp_slash( user->user_icq ) );
--                 end;
--                 if ( ! empty( user->user_aim ) ) then
--                         update_user_meta( user->ID, "aim", wp_slash( user->user_aim ) );
--                 end;
--                 if ( ! empty( user->user_msn ) ) then
--                         update_user_meta( user->ID, "msn", wp_slash( user->user_msn ) );
--                 end;
--                 if ( ! empty( user->user_yim ) ) then
--                         update_user_meta( user->ID, "yim", wp_slash( user->user_icq ) );
--                 end;
--                 if ( ! empty( user->user_description ) ) then
--                         update_user_meta( user->ID, "description", wp_slash( user->user_description ) );
--                 end;

--                 if ( isset( user->user_idmode ) ) :
--                         idmode = user->user_idmode;
--                         if ( "nickname" === idmode ) then
--                                 id = user->user_nickname;
--                         end;
--                         if ( "login" === idmode ) then
--                                 id = user->user_login;
--                         end;
--                         if ( "firstname" === idmode ) then
--                                 id = user->user_firstname;
--                         end;
--                         if ( "lastname" === idmode ) then
--                                 id = user->user_lastname;
--                         end;
--                         if ( "namefl" === idmode ) then
--                                 id = user->user_firstname . " " . user->user_lastname;
--                         end;
--                         if ( "namelf" === idmode ) then
--                                 id = user->user_lastname . " " . user->user_firstname;
--                         end;
--                         if ( ! idmode ) then
--                                 id = user->user_nickname;
--                         end;
--                         wpdb->update( wpdb->users, array( "display_name" => id ), array( "ID" => user->ID ) );
--                 endif;

--                 -- FIXME: RESET_CAPS is temporary code to reset roles and caps if flag is set.
--                 caps = get_user_meta( user->ID, wpdb->prefix . "capabilities" );
--                 if ( empty( caps ) || defined( "RESET_CAPS" ) ) then
--                         level = get_user_meta( user->ID, wpdb->prefix . "user_level", true );
--                         role  = translate_level_to_role( level );
--                         update_user_meta( user->ID, wpdb->prefix . "capabilities", array( role => true ) );
--                 end;

--         endforeach;
--         old_user_fields = array( "user_firstname", "user_lastname", "user_icq", "user_aim", "user_msn", "user_yim", "user_idmode", "user_ip", "user_domain", "user_browser", "user_description", "user_nickname", "user_level" );
--         wpdb->hide_errors();
--         foreach ( old_user_fields as old ) then
--                 wpdb->query( "ALTER TABLE wpdb->users DROP old" );
--         end;
--         wpdb->show_errors();

--         -- Populate comment_count field of posts table.
--         comments = wpdb->get_results( "SELECT comment_post_ID, COUNT(*) as c FROM wpdb->comments WHERE comment_approved = "1" GROUP BY comment_post_ID" );
--         if ( is_array( comments ) ) then
--                 foreach ( comments as comment ) then
--                         wpdb->update( wpdb->posts, array( "comment_count" => comment->c ), array( "ID" => comment->comment_post_ID ) );
--                 end;
--         end;

--         /*
--         -- Some alpha versions used a post status of object instead of attachment
--         -- and put the mime type in post_type instead of post_mime_type.
--         --
--         if ( wp_current_db_version > 2541 && wp_current_db_version <= 3091 ) then
--                 objects = wpdb->get_results( "SELECT ID, post_type FROM wpdb->posts WHERE post_status = "object"" );
--                 foreach ( objects as object ) then
--                         wpdb->update(
--                                 wpdb->posts,
--                                 array(
--                                         "post_status"    => "attachment",
--                                         "post_mime_type" => object->post_type,
--                                         "post_type"      => "",
--                                 ),
--                                 array( "ID" => object->ID )
--                         );

--                         meta = get_post_meta( object->ID, "imagedata", true );
--                         if ( ! empty( meta["file"] ) ) then
--                                 update_attached_file( object->ID, meta["file"] );
--                         end;
--                 end;
--         end;
-- end;

   -----------------
   -- Upgrade_210 --
   -----------------

   procedure Upgrade_210
   is null;
--         global wp_current_db_version, wpdb;

--         if ( wp_current_db_version < 3506 ) then
--                 -- Update status and type.
--                 posts = wpdb->get_results( "SELECT ID, post_status FROM wpdb->posts" );

--                 if ( ! empty( posts ) ) then
--                         foreach ( posts as post ) then
--                                 status = post->post_status;
--                                 type   = "post";

--                                 if ( "static" === status ) then
--                                         status = "publish";
--                                         type   = "page";
--                                 end; elseif ( "attachment" === status ) then
--                                         status = "inherit";
--                                         type   = "attachment";
--                                 end;

--                                 wpdb->query( wpdb->prepare( "UPDATE wpdb->posts SET post_status = %s, post_type = %s WHERE ID = %d", status, type, post->ID ) );
--                         end;
--                 end;
--         end;

--         if ( wp_current_db_version < 3845 ) then
--                 populate_roles_210();
--         end;

--         if ( wp_current_db_version < 3531 ) then
--                 -- Give future posts a post_status of future.
--                 now = gmdate( "Y-m-d H:i:59" );
--                 wpdb->query( "UPDATE wpdb->posts SET post_status = "future" WHERE post_status = "publish" AND post_date_gmt > "now"" );

--                 posts = wpdb->get_results( "SELECT ID, post_date FROM wpdb->posts WHERE post_status ="future"" );
--                 if ( ! empty( posts ) ) then
--                         foreach ( posts as post ) then
--                                 wp_schedule_single_event( mysql2date( "U", post->post_date, false ), "publish_future_post", array( post->ID ) );
--                         end;
--                 end;
--         end;
-- end;

   -----------------
   -- Upgrade_230 --
   -----------------

   procedure Upgrade_230
   is null;
--         global wp_current_db_version, wpdb;

--         if ( wp_current_db_version < 5200 ) then
--                 populate_roles_230();
--         end;

--         -- Convert categories to terms.
--         tt_ids     = array();
--         have_tags  = false;
--         categories = wpdb->get_results( "SELECT-- FROM wpdb->categories ORDER BY cat_ID" );
--         foreach ( categories as category ) then
--                 term_id     = (int) category->cat_ID;
--                 name        = category->cat_name;
--                 description = category->category_description;
--                 slug        = category->category_nicename;
--                 parent      = category->category_parent;
--                 term_group  = 0;

--                 -- Associate terms with the same slug in a term group and make slugs unique.
--                 exists = wpdb->get_results( wpdb->prepare( "SELECT term_id, term_group FROM wpdb->terms WHERE slug = %s", slug ) );
--                 if ( exists ) then
--                         term_group = exists[0]->term_group;
--                         id         = exists[0]->term_id;
--                         num        = 2;
--                         do then
--                                 alt_slug = slug . "-num";
--                                 num++;
--                                 slug_check = wpdb->get_var( wpdb->prepare( "SELECT slug FROM wpdb->terms WHERE slug = %s", alt_slug ) );
--                         end; while ( slug_check );

--                         slug = alt_slug;

--                         if ( empty( term_group ) ) then
--                                 term_group = wpdb->get_var( "SELECT MAX(term_group) FROM wpdb->terms GROUP BY term_group" ) + 1;
--                                 wpdb->query( wpdb->prepare( "UPDATE wpdb->terms SET term_group = %d WHERE term_id = %d", term_group, id ) );
--                         end;
--                 end;

--                 wpdb->query(
--                         wpdb->prepare(
--                                 "INSERT INTO wpdb->terms (term_id, name, slug, term_group) VALUES
--                 (%d, %s, %s, %d)",
--                                 term_id,
--                                 name,
--                                 slug,
--                                 term_group
--                         )
--                 );

--                 count = 0;
--                 if ( ! empty( category->category_count ) ) then
--                         count    = (int) category->category_count;
--                         taxonomy = "category";
--                         wpdb->query( wpdb->prepare( "INSERT INTO wpdb->term_taxonomy (term_id, taxonomy, description, parent, count) VALUES ( %d, %s, %s, %d, %d)", term_id, taxonomy, description, parent, count ) );
--                         tt_ids[ term_id ][ taxonomy ] = (int) wpdb->insert_id;
--                 end;

--                 if ( ! empty( category->link_count ) ) then
--                         count    = (int) category->link_count;
--                         taxonomy = "link_category";
--                         wpdb->query( wpdb->prepare( "INSERT INTO wpdb->term_taxonomy (term_id, taxonomy, description, parent, count) VALUES ( %d, %s, %s, %d, %d)", term_id, taxonomy, description, parent, count ) );
--                         tt_ids[ term_id ][ taxonomy ] = (int) wpdb->insert_id;
--                 end;

--                 if ( ! empty( category->tag_count ) ) then
--                         have_tags = true;
--                         count     = (int) category->tag_count;
--                         taxonomy  = "post_tag";
--                         wpdb->insert( wpdb->term_taxonomy, compact( "term_id", "taxonomy", "description", "parent", "count" ) );
--                         tt_ids[ term_id ][ taxonomy ] = (int) wpdb->insert_id;
--                 end;

--                 if ( empty( count ) ) then
--                         count    = 0;
--                         taxonomy = "category";
--                         wpdb->insert( wpdb->term_taxonomy, compact( "term_id", "taxonomy", "description", "parent", "count" ) );
--                         tt_ids[ term_id ][ taxonomy ] = (int) wpdb->insert_id;
--                 end;
--         end;

--         select = "post_id, category_id";
--         if ( have_tags ) then
--                 select .= ", rel_type";
--         end;

--         posts = wpdb->get_results( "SELECT select FROM wpdb->post2cat GROUP BY post_id, category_id" );
--         foreach ( posts as post ) then
--                 post_id  = (int) post->post_id;
--                 term_id  = (int) post->category_id;
--                 taxonomy = "category";
--                 if ( ! empty( post->rel_type ) && "tag" === post->rel_type ) then
--                         taxonomy = "tag";
--                 end;
--                 tt_id = tt_ids[ term_id ][ taxonomy ];
--                 if ( empty( tt_id ) ) then
--                         continue;
--                 end;

--                 wpdb->insert(
--                         wpdb->term_relationships,
--                         array(
--                                 "object_id"        => post_id,
--                                 "term_taxonomy_id" => tt_id,
--                         )
--                 );
--         end;

--         -- < 3570 we used linkcategories. >= 3570 we used categories and link2cat.
--         if ( wp_current_db_version < 3570 ) then
--                 /*
--                 -- Create link_category terms for link categories. Create a map of link
--                 -- category IDs to link_category terms.
--                 --
--                 link_cat_id_map  = array();
--                 default_link_cat = 0;
--                 tt_ids           = array();
--                 link_cats        = wpdb->get_results( "SELECT cat_id, cat_name FROM " . wpdb->prefix . "linkcategories" );
--                 foreach ( link_cats as category ) then
--                         cat_id     = (int) category->cat_id;
--                         term_id    = 0;
--                         name       = wp_slash( category->cat_name );
--                         slug       = sanitize_title( name );
--                         term_group = 0;

--                         -- Associate terms with the same slug in a term group and make slugs unique.
--                         exists = wpdb->get_results( wpdb->prepare( "SELECT term_id, term_group FROM wpdb->terms WHERE slug = %s", slug ) );
--                         if ( exists ) then
--                                 term_group = exists[0]->term_group;
--                                 term_id    = exists[0]->term_id;
--                         end;

--                         if ( empty( term_id ) ) then
--                                 wpdb->insert( wpdb->terms, compact( "name", "slug", "term_group" ) );
--                                 term_id = (int) wpdb->insert_id;
--                         end;

--                         link_cat_id_map[ cat_id ] = term_id;
--                         default_link_cat           = term_id;

--                         wpdb->insert(
--                                 wpdb->term_taxonomy,
--                                 array(
--                                         "term_id"     => term_id,
--                                         "taxonomy"    => "link_category",
--                                         "description" => "",
--                                         "parent"      => 0,
--                                         "count"       => 0,
--                                 )
--                         );
--                         tt_ids[ term_id ] = (int) wpdb->insert_id;
--                 end;

--                 -- Associate links to categories.
--                 links = wpdb->get_results( "SELECT link_id, link_category FROM wpdb->links" );
--                 if ( ! empty( links ) ) then
--                         foreach ( links as link ) then
--                                 if ( 0 == link->link_category ) then
--                                         continue;
--                                 end;
--                                 if ( ! isset( link_cat_id_map[ link->link_category ] ) ) then
--                                         continue;
--                                 end;
--                                 term_id = link_cat_id_map[ link->link_category ];
--                                 tt_id   = tt_ids[ term_id ];
--                                 if ( empty( tt_id ) ) then
--                                         continue;
--                                 end;

--                                 wpdb->insert(
--                                         wpdb->term_relationships,
--                                         array(
--                                                 "object_id"        => link->link_id,
--                                                 "term_taxonomy_id" => tt_id,
--                                         )
--                                 );
--                         end;
--                 end;

--                 -- Set default to the last category we grabbed during the upgrade loop.
--                 update_option( "default_link_category", default_link_cat );
--         end; else then
--                 links = wpdb->get_results( "SELECT link_id, category_id FROM wpdb->link2cat GROUP BY link_id, category_id" );
--                 foreach ( links as link ) then
--                         link_id  = (int) link->link_id;
--                         term_id  = (int) link->category_id;
--                         taxonomy = "link_category";
--                         tt_id    = tt_ids[ term_id ][ taxonomy ];
--                         if ( empty( tt_id ) ) then
--                                 continue;
--                         end;
--                         wpdb->insert(
--                                 wpdb->term_relationships,
--                                 array(
--                                         "object_id"        => link_id,
--                                         "term_taxonomy_id" => tt_id,
--                                 )
--                         );
--                 end;
--         end;

--         if ( wp_current_db_version < 4772 ) then
--                 -- Obsolete linkcategories table.
--                 wpdb->query( "DROP TABLE IF EXISTS " . wpdb->prefix . "linkcategories" );
--         end;

--         -- Recalculate all counts.
--         terms = wpdb->get_results( "SELECT term_taxonomy_id, taxonomy FROM wpdb->term_taxonomy" );
--         foreach ( (array) terms as term ) then
--                 if ( "post_tag" === term->taxonomy || "category" === term->taxonomy ) then
--                         count = wpdb->get_var( wpdb->prepare( "SELECT COUNT(*) FROM wpdb->term_relationships, wpdb->posts WHERE wpdb->posts.ID = wpdb->term_relationships.object_id AND post_status = "publish" AND post_type = "post" AND term_taxonomy_id = %d", term->term_taxonomy_id ) );
--                 end; else then
--                         count = wpdb->get_var( wpdb->prepare( "SELECT COUNT(*) FROM wpdb->term_relationships WHERE term_taxonomy_id = %d", term->term_taxonomy_id ) );
--                 end;
--                 wpdb->update( wpdb->term_taxonomy, array( "count" => count ), array( "term_taxonomy_id" => term->term_taxonomy_id ) );
--         end;
-- end;

   -------------------------------
   -- Upgrade_230_Options_Table --
   -------------------------------

   procedure Upgrade_230_Options_Table
   is
      use Globals;
      use UStrings;
      use Class_WpDB;

      Old_Options_Fields : constant List_Type :=
        To_List (List => (
          +"option_can_override", +"option_type", +"option_width",
          +"option_height", +"option_description", +"option_admin_level"));
   begin
      WpDB.Hide_Errors;
      for Old of Old_Options_Fields loop
         WpDB.Query (Statement_Type (
           "ALTER TABLE " & (-WpDB.Options) & " DROP " & (-Old)));
      end loop;
      WpDB.Show_Errors;
   end Upgrade_230_Options_Table;

   ----------------------------
   -- Upgrade_230_Old_Tables --
   ----------------------------

   procedure Upgrade_230_Old_Tables
   is
      use Globals;
      use UStrings;
      use Class_WpDB;

      Prefix : constant Statement_Type := Statement_Type (-WpDB.Prefix);
   begin
      WpDB.Query ("DROP TABLE IF EXISTS " & Prefix & "categories");
      WpDB.Query ("DROP TABLE IF EXISTS " & Prefix & "link2cat");
      WpDB.Query ("DROP TABLE IF EXISTS " & Prefix & "post2cat");
   end Upgrade_230_Old_Tables;

   -----------------------
   -- Upgrade_Old_Slugs --
   -----------------------

   procedure Upgrade_Old_Slugs
   is
      use Globals;
      use UStrings;
      use Class_WpDB;

      Postmeta : constant Statement_Type := Statement_Type (-WpDB.Postmeta);
   begin
      -- Upgrade people who were using the Redirect Old Slugs plugin.
      WpDB.Query (
        "UPDATE " & Postmeta &
        " SET meta_key = '_wp_old_slug' WHERE meta_key = 'old_slug'");
   end Upgrade_Old_Slugs;

   -----------------
   -- Upgrade_250 --
   -----------------

   procedure Upgrade_250
   is
      use Adi_Schemas;
   begin
      if Wp_Current_DB_Version < 6689 then
         Populate_Roles_250;
      end if;
   end Upgrade_250;

   -----------------
   -- Upgrade_252 --
   -----------------

   procedure Upgrade_252
   is
      use Globals;
      use UStrings;
      use Class_WpDB;

      Users : constant Statement_Type := Statement_Type (-WpDB.Users);
   begin
      WpDB.Query ("UPDATE " & Users & " SET user_activation_key = ''");
   end Upgrade_252;

   -----------------
   -- Upgrade_260 --
   -----------------

   procedure Upgrade_260
   is
      use Adi_Schemas;
   begin
      if Wp_Current_DB_Version < 8000 then
         Populate_Roles_260;
      end if;
   end Upgrade_260;

   -----------------
   -- Upgrade_270 --
   -----------------

   procedure Upgrade_270
   is
      use Globals;
      use UStrings;
      use Adi_Schemas;
      use Class_WpDB;

      Posts : constant Statement_Type := Statement_Type (-WpDB.Posts);
   begin
      if Wp_Current_DB_Version < 8980 then
         Populate_Roles_270;
      end if;

      -- Update post_date for unpublished posts with empty timestamp.
      if Wp_Current_DB_Version < 8921 then
         WpDB.Query (
           "UPDATE " & Posts & " SET post_date = post_modified " &
           "WHERE post_date = '0000-00-00 00:00:00'");
      end if;
   end Upgrade_270;

   -----------------
   -- Upgrade_280 --
   -----------------

   procedure Upgrade_280
   is null;
--         global wp_current_db_version, wpdb;

--         if ( wp_current_db_version < 10360 ) then
--                 populate_roles_280();
--         end;
--         if ( is_multisite() ) then
--                 start = 0;
--                 while ( rows = wpdb->get_results( "SELECT option_name, option_value FROM wpdb->options ORDER BY option_id LIMIT start, 20" ) ) then
--                         foreach ( rows as row ) then
--                                 value = maybe_unserialize( row->option_value );
--                                 if ( value === row->option_value ) then
--                                         value = stripslashes( value );
--                                 end;
--                                 if ( value !== row->option_value ) then
--                                         update_option( row->option_name, value );
--                                 end;
--                         end;
--                         start += 20;
--                 end;
--                 clean_blog_cache( get_current_blog_id() );
--         end;
-- end;

   -----------------
   -- Upgrade_290 --
   -----------------

   procedure Upgrade_290
   is
      use Inc_Options;
   begin
      if Wp_Current_DB_Version < 11958 then
         -- Previously, setting depth to 1 would redundantly disable threading,
         -- but now 2 is the minimum depth to avoid confusion.
         if Get_Option ("thread_comments_depth") = "1" then
            Update_Option ("thread_comments_depth", From_Integer (2));
            Update_Option ("thread_comments",       From_Integer (0));
         end if;
      end if;
   end Upgrade_290;

   -----------------
   -- Upgrade_300 --
   -----------------

   procedure Upgrade_300
   is null;
--         global wp_current_db_version, wpdb;

--         if ( wp_current_db_version < 15093 ) then
--                 populate_roles_300();
--         end;

--         if ( wp_current_db_version < 14139 && is_multisite() && is_main_site() && ! defined( "MULTISITE" ) && get_site_option( "siteurl" ) === false ) then
--                 add_site_option( "siteurl", "" );
--         end;

--         -- 3.0 screen options key name changes.
--         if ( wp_should_upgrade_global_tables() ) then
--                 sql    = "DELETE FROM wpdb->usermeta
--                         WHERE meta_key LIKE %s
--                         OR meta_key LIKE %s
--                         OR meta_key LIKE %s
--                         OR meta_key LIKE %s
--                         OR meta_key LIKE %s
--                         OR meta_key LIKE %s
--                         OR meta_key = "manageedittagscolumnshidden"
--                         OR meta_key = "managecategoriescolumnshidden"
--                         OR meta_key = "manageedit-tagscolumnshidden"
--                         OR meta_key = "manageeditcolumnshidden"
--                         OR meta_key = "categories_per_page"
--                         OR meta_key = "edit_tags_per_page"";
--                 prefix = wpdb->esc_like( wpdb->base_prefix );
--                 wpdb->query(
--                         wpdb->prepare(
--                                 sql,
--                                 prefix . "%" . wpdb->esc_like( "meta-box-hidden" ) . "%",
--                                 prefix . "%" . wpdb->esc_like( "closedpostboxes" ) . "%",
--                                 prefix . "%" . wpdb->esc_like( "manage-" ) . "%" . wpdb->esc_like( "-columns-hidden" ) . "%",
--                                 prefix . "%" . wpdb->esc_like( "meta-box-order" ) . "%",
--                                 prefix . "%" . wpdb->esc_like( "metaboxorder" ) . "%",
--                                 prefix . "%" . wpdb->esc_like( "screen_layout" ) . "%"
--                         )
--                 );
--         end;

-- end;

   -----------------
   -- Upgrade_330 --
   -----------------

   procedure Upgrade_330
   is null;
--         global wp_current_db_version, wpdb, wp_registered_widgets, sidebars_widgets;

--         if ( wp_current_db_version < 19061 && wp_should_upgrade_global_tables() ) then
--                 wpdb->query( "DELETE FROM wpdb->usermeta WHERE meta_key IN ("show_admin_bar_admin", "plugins_last_view")" );
--         end;

--         if ( wp_current_db_version >= 11548 ) then
--                 return;
--         end;

--         sidebars_widgets  = get_option( "sidebars_widgets", array() );
--         _sidebars_widgets = array();

--         if ( isset( sidebars_widgets["wp_inactive_widgets"] ) || empty( sidebars_widgets ) ) then
--                 sidebars_widgets["array_version"] = 3;
--         end; elseif ( ! isset( sidebars_widgets["array_version"] ) ) then
--                 sidebars_widgets["array_version"] = 1;
--         end;

--         switch ( sidebars_widgets["array_version"] ) then
--                 case 1:
--                         foreach ( (array) sidebars_widgets as index => sidebar ) then
--                                 if ( is_array( sidebar ) ) then
--                                         foreach ( (array) sidebar as i => name ) then
--                                                 id = strtolower( name );
--                                                 if ( isset( wp_registered_widgets[ id ] ) ) then
--                                                         _sidebars_widgets[ index ][ i ] = id;
--                                                         continue;
--                                                 end;
--                                                 id = sanitize_title( name );
--                                                 if ( isset( wp_registered_widgets[ id ] ) ) then
--                                                         _sidebars_widgets[ index ][ i ] = id;
--                                                         continue;
--                                                 end;

--                                                 found = false;

--                                                 foreach ( wp_registered_widgets as widget_id => widget ) then
--                                                         if ( strtolower( widget["name"] ) == strtolower( name ) ) then
--                                                                 _sidebars_widgets[ index ][ i ] = widget["id"];
--                                                                 found                             = true;
--                                                                 break;
--                                                         end; elseif ( sanitize_title( widget["name"] ) == sanitize_title( name ) ) then
--                                                                 _sidebars_widgets[ index ][ i ] = widget["id"];
--                                                                 found                             = true;
--                                                                 break;
--                                                         end;
--                                                 end;

--                                                 if ( found ) then
--                                                         continue;
--                                                 end;

--                                                 unset( _sidebars_widgets[ index ][ i ] );
--                                         end;
--                                 end;
--                         end;
--                         _sidebars_widgets["array_version"] = 2;
--                         sidebars_widgets                   = _sidebars_widgets;
--                         unset( _sidebars_widgets );

--                         -- Intentional fall-through to upgrade to the next version.
--                 case 2:
--                         sidebars_widgets                  = retrieve_widgets();
--                         sidebars_widgets["array_version"] = 3;
--                         update_option( "sidebars_widgets", sidebars_widgets );
--         end;
-- end;

   -----------------
   -- Upgrade_340 --
   -----------------

   procedure Upgrade_340
   is
      use Globals;
      use UStrings;
      use Class_WpDB;
      use Inc_Options;

      Options  : constant Statement_Type := Statement_Type (-WpDB.Options);
      Comments : constant Statement_Type := Statement_Type (-WpDB.Comments);
      Usermeta : constant Statement_Type := Statement_Type (-WpDB.Usermeta);
   begin
      if Wp_Current_DB_Version < 19798 then
         WpDB.Hide_Errors;
         WpDB.Query ("ALTER TABLE " & Options & " DROP COLUMN blog_id");
         WpDB.Show_Errors;
      end if;

      if Wp_Current_DB_Version < 19799 then
         WpDB.Hide_Errors;
         WpDB.Query ("ALTER TABLE " & Comments & " DROP INDEX comment_approved");
         WpDB.Show_Errors;
      end if;

      if
        Wp_Current_DB_Version < 20022 and then
        Wp_Should_Upgrade_Global_Tables
      then
         WpDB.Query (
           "DELETE FROM " & Usermeta & " WHERE meta_key = 'themes_last_view'");
      end if;

      if Wp_Current_DB_Version < 20080 then
         if
           "yes" = WpDB.Get_Var ("SELECT autoload FROM " & Options &
                                 " WHERE option_name = 'uninstall_plugins'")
         then
            declare
               Uninstall_Plugins : constant String :=
                 Get_Option ("uninstall_plugins");
            begin
               Delete_Option ("uninstall_plugins");
               Add_Option ("uninstall_plugins",
                           From_String (Uninstall_Plugins),
                           "", False);  -- null, "no"
            end;
         end if;
      end if;
   end Upgrade_340;

   -----------------
   -- Upgrade_350 --
   -----------------

   procedure Upgrade_350
   is null;
--         global wp_current_db_version, wpdb;

--         if ( wp_current_db_version < 22006 && wpdb->get_var( "SELECT link_id FROM wpdb->links LIMIT 1" ) ) then
--                 update_option( "link_manager_enabled", 1 ); -- Previously set to 0 by populate_options().
--         end;

--         if ( wp_current_db_version < 21811 && wp_should_upgrade_global_tables() ) then
--                 meta_keys = array();
--                 foreach ( array_merge( get_post_types(), get_taxonomies() ) as name ) then
--                         if ( false !== strpos( name, "-" ) ) then
--                                 meta_keys[] = "edit_" . str_replace( "-", "_", name ) . "_per_page";
--                         end;
--                 end;
--                 if ( meta_keys ) then
--                         meta_keys = implode( "", "", meta_keys );
--                         wpdb->query( "DELETE FROM wpdb->usermeta WHERE meta_key IN ("meta_keys")" );
--                 end;
--         end;

--         if ( wp_current_db_version < 22422 ) then
--                 term = get_term_by( "slug", "post-format-standard", "post_format" );
--                 if ( term ) then
--                         wp_delete_term( term->term_id, "post_format" );
--                 end;
--         end;
-- end;

   -----------------
   -- Upgrade_370 --
   -----------------

   procedure Upgrade_370
   is
      use Inc_Cron;
   begin
      if Wp_Current_DB_Version < 25824 then
         Wp_Clear_Scheduled_Hook ("wp_auto_updates_maybe_update");
      end if;
   end Upgrade_370;

   -----------------
   -- Upgrade_372 --
   -----------------

   procedure Upgrade_372
   is
      use Inc_Cron;
   begin
      if Wp_Current_DB_Version < 26148 then
         Wp_Clear_Scheduled_Hook ("wp_maybe_auto_update");
      end if;
   end Upgrade_372;

   -----------------
   -- Upgrade_380 --
   -----------------

   procedure Upgrade_380
   is
      use Adi_Plugins;
   begin
      if Wp_Current_DB_Version < 26691 then
         Deactivate_Plugins (To_List ("mp6/mp6.php"), True); -- array(
      end if;
   end Upgrade_380;

   -----------------
   -- Upgrade_400 --
   -----------------

   procedure Upgrade_400
   is
      use Php.Arrays;
      use Globals;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
   begin
      if Wp_Current_DB_Version < 29630 then
         if
           not Is_Multisite and then
           False = Get_Option ("WPLANG")
         then
            if
--            Defined ("WPLANG") and then
              "" /= WPLANG and then
              In_Array (WPLANG, Get_Available_Languages, True)
            then
               Update_Option ("WPLANG", From_String (WPLANG));
            else
               Update_Option ("WPLANG", From_String (""));
            end if;
         end if;
      end if;
   end Upgrade_400;

   -----------------
   -- Upgrade_420 --
   -----------------

   procedure Upgrade_420
   is null;

   -----------------
   -- Upgrade_430 --
   -----------------

   procedure Upgrade_430
   is
      use Ada.Strings.Unbounded;
      use Php.Arrays;
      use Globals;
      use Inc_Cron;
      use Inc_Load;
      use Inc_Options;

      Tables : Array_Type;
   begin
      if Wp_Current_DB_Version < 32364 then
         Upgrade_430_Fix_Comments;
      end if;

      -- Shared terms are split in a separate process.
      if Wp_Current_DB_Version < 32814 then
         Update_Option ("finished_splitting_shared_terms", From_Integer (0));
         Wp_Schedule_Single_Event (Php.Misc.Time + (1 * MINUTE_IN_SECONDS),
                                   "wp_split_shared_term_batch");
      end if;

      if
        Wp_Current_DB_Version < 33055 and then
        "utf8mb4" = WpDB.Charset
      then
         if Is_Multisite then
            Tables := WpDB.Tables ("blog");
         else
            Tables := WpDB.Tables ("all");
            if not Wp_Should_Upgrade_Global_Tables then
               declare
                  Global_Tables : constant Array_Type := WpDB.Tables ("global");
               begin
                  Tables := Array_Diff_Assoc (Tables, Global_Tables);
               end;
            end if;
         end if;

         for T in Tables.Iterate loop
            declare
               Table : constant String := Key (T);
            begin
               Maybe_Convert_Table_To_Utf8mb4 (Table);
            end;
         end loop;
      end if;
   end Upgrade_430;

   ------------------------------
   -- Upgrade_430_Fix_Comments --
   ------------------------------

   procedure Upgrade_430_Fix_Comments
   is null;
--         global wpdb;

--         content_length = wpdb->get_col_length( wpdb->comments, "comment_content" );

--         if ( is_wp_error( content_length ) ) then
--                 return;
--         end;

--         if ( false === content_length ) then
--                 content_length = array(
--                         "type"   => "byte",
--                         "length" => 65535,
--                 );
--         end; elseif ( ! is_array( content_length ) ) then
--                 length         = (int) content_length > 0 ? (int) content_length : 65535;
--                 content_length = array(
--                         "type"   => "byte",
--                         "length" => length,
--                 );
--         end;

--         if ( "byte" !== content_length["type"] || 0 === content_length["length"] ) then
--                 -- Sites with malformed DB schemas are on their own.
--                 return;
--         end;

--         allowed_length = (int) content_length["length"] - 10;

--         comments = wpdb->get_results(
--                 "SELECT `comment_ID` FROM `thenwpdb->commentsend;`
--                         WHERE `comment_date_gmt` > "2015-04-26"
--                         AND LENGTH( `comment_content` ) >= thenallowed_lengthend;
--                         AND ( `comment_content` LIKE "%<%" OR `comment_content` LIKE "%>%" )"
--         );

--         foreach ( comments as comment ) then
--                 wp_delete_comment( comment->comment_ID, true );
--         end;
-- end;

   -----------------
   -- Upgrade_431 --
   -----------------

   procedure Upgrade_431
   is
      use Inc_Cron;

      -- Fix incorrect cron entries for term splitting.
      Cron_Array : constant Array_Type := X_Get_Cron_Array;
   begin
      if Isset (Cron_Array, "wp_batch_split_terms") then
         Delete (Ref (Cron_Array, "wp_batch_split_terms"));
         X_Set_Cron_Array (Cron_Array);
      end if;
   end Upgrade_431;

   -----------------
   -- Upgrade_440 --
   -----------------

   procedure Upgrade_440
   is
      use Globals;
      use UStrings;
      use Class_WpDB;
      use Class_Roles;
      use Inc_Roles;

      Options : constant Statement_Type := Statement_Type (-WpDB.Options);
   begin
      if Wp_Current_DB_Version < 34030 then
         WpDB.Query ("ALTER TABLE " & Options & " MODIFY option_name VARCHAR(191)");
      end if;

      -- Remove the unused "add_users" role.
      declare
         Roles : Wp_Roles := Global_Wp_Roles; -- ();
      begin
         for Role of Roles.Role_Objects loop
            if Role.Has_Cap ("add_users") then
               Role.Remove_Cap ("add_users");
            end if;
         end loop;
      end;
   end Upgrade_440;

   -----------------
   -- Upgrade_450 --
   -----------------

   procedure Upgrade_450
   is
      use Globals;
      use UStrings;
      use Inc_Cron;
      use Inc_Load;
      use Inc_Options;
      use Class_WpDB;

      Options : constant Statement_Type := Statement_Type (-WpDB.Options);
   begin
      if Wp_Current_DB_Version < 36180 then
         Wp_Clear_Scheduled_Hook ("wp_maybe_auto_update");
      end if;

      -- Remove unused email confirmation options, moved to usermeta.
      if Wp_Current_DB_Version < 36679 and then Is_Multisite then
         WpDB.Query ("DELETE FROM " & Options &
                     " WHERE option_name REGEXP '^[0-9]+_new_email'");
      end if;

      -- Remove unused user setting for wpLink.
      Delete_User_Setting ("wplink");
   end Upgrade_450;

   -----------------
   -- Upgrade_460 --
   -----------------

   procedure Upgrade_460
   is null;
--         global wp_current_db_version;

--         -- Remove unused post meta.
--         if ( wp_current_db_version < 37854 ) then
--                 delete_post_meta_by_key( "_post_restored_from" );
--         end;

--         -- Remove plugins with callback as an array object/method as the uninstall hook, see #13786.
--         if ( wp_current_db_version < 37965 ) then
--                 uninstall_plugins = get_option( "uninstall_plugins", array() );

--                 if ( ! empty( uninstall_plugins ) ) then
--                         foreach ( uninstall_plugins as basename => callback ) then
--                                 if ( is_array( callback ) && is_object( callback[0] ) ) then
--                                         unset( uninstall_plugins[ basename ] );
--                                 end;
--                         end;

--                         update_option( "uninstall_plugins", uninstall_plugins );
--                 end;
--         end;
-- end;

   -----------------
   -- Upgrade_500 --
   -----------------

   procedure Upgrade_500
   is null;

   -----------------
   -- Upgrade_510 --
   -----------------

   procedure Upgrade_510
   is
      use Inc_Options;
   begin
      Delete_Site_Option ("upgrade_500_was_gutenberg_active");
   end Upgrade_510;

   -----------------
   -- Upgrade_530 --
   -----------------

   procedure Upgrade_530
   is
      use Inc_Capabilities;
      use Inc_Options;
   begin
      --
      -- The `admin_email_lifespan` option may have been set by an admin that just
      -- logged in, saw the verification screen, clicked on a button there, and is
      -- now upgrading the db, or by populate_options() that is called earlier in
      -- upgrade_all(). In the second case `admin_email_lifespan` should be reset so
      -- the verification screen is shown next time an admin logs in.
      --
      if
        -- function_exists( "current_user_can" ) and then
        not Current_User_Can ("manage_options")
      then
         Update_Option ("admin_email_lifespan", From_Integer (0));
      end if;
   end Upgrade_530;

   -----------------
   -- Upgrade_550 --
   -----------------

   procedure Upgrade_550
   is
      use List_Vectors;
      use Inc_Cron;
      use Inc_Options;
   begin
      if Wp_Current_DB_Version < 48121 then
         declare
            Comment_Previously_Approved : constant List_Type :=
              Get_Option ("comment_whitelist", "");
         begin
            Update_Option ("comment_previously_approved",
                           From_List (Comment_Previously_Approved));
            Delete_Option ("comment_whitelist");
         end;
      end if;

      if Wp_Current_DB_Version < 48575 then
         -- Use more clear and inclusive language.
         declare
            Disallowed_List : List_Type := Get_Option ("blacklist_keys");
         begin
            --
            -- This option key was briefly renamed `blocklist_keys`.
            -- Account for sites that have this key present when the original key
            -- does not exist.
            --
            if Disallowed_List = Empty_List then
--          if False = Disallowed_List then
               Disallowed_List := Get_Option ("blocklist_keys");
            end if;

            Update_Option ("disallowed_keys", From_List (Disallowed_List));
            Delete_Option ("blacklist_keys");
            Delete_Option ("blocklist_keys");
         end;
      end if;

      if Wp_Current_DB_Version < 48748 then
         Update_Option ("finished_updating_comment_type", From_Integer (0));
         Wp_Schedule_Single_Event (Php.Misc.Time + (1 * Globals.MINUTE_IN_SECONDS),
                                   "wp_update_comment_type_batch");
      end if;
   end Upgrade_550;

   -----------------
   -- Upgrade_560 --
   -----------------

   procedure Upgrade_560
   is null;
--         global wp_current_db_version, wpdb;

--         if ( wp_current_db_version < 49572 ) then
--                 /*
--                 -- Clean up the `post_category` column removed from schema in version 2.8.0.
--                 -- Its presence may conflict with `WP_Post::__get()`.
--                 --
--                 post_category_exists = wpdb->get_var( "SHOW COLUMNS FROM wpdb->posts LIKE "post_category"" );
--                 if ( ! is_null( post_category_exists ) ) then
--                         wpdb->query( "ALTER TABLE wpdb->posts DROP COLUMN `post_category`" );
--                 end;

--                 /*
--                 -- When upgrading from WP < 5.6.0 set the core major auto-updates option to `unset` by default.
--                 -- This overrides the same option from populate_options() that is intended for new installs.
--                 -- See https://core.trac.wordpress.org/ticket/51742.
--                 --
--                 update_option( "auto_update_core_major", "unset" );
--         end;

--         if ( wp_current_db_version < 49632 ) then
--                 /*
--                 -- Regenerate the .htaccess file to add the `HTTP_AUTHORIZATION` rewrite rule.
--                 -- See https://core.trac.wordpress.org/ticket/51723.
--                 --
--                 save_mod_rewrite_rules();
--         end;

--         if ( wp_current_db_version < 49735 ) then
--                 delete_transient( "dirsize_cache" );
--         end;

--         if ( wp_current_db_version < 49752 ) then
--                 results = wpdb->get_results(
--                         wpdb->prepare(
--                                 "SELECT 1 FROM thenwpdb->usermetaend; WHERE meta_key = %s LIMIT 1",
--                                 WP_Application_Passwords::USERMETA_KEY_APPLICATION_PASSWORDS
--                         )
--                 );

--                 if ( ! empty( results ) ) then
--                         network_id = get_main_network_id();
--                         update_network_option( network_id, WP_Application_Passwords::OPTION_KEY_IN_USE, 1 );
--                 end;
--         end;
-- end;

   -----------------
   -- Upgrade_590 --
   -----------------

   procedure Upgrade_590
   is
      use Php.Arrays;
      use Inc_Cron;
   begin
      if Wp_Current_DB_Version < 51917 then
         declare
            Crons : Array_Type := X_Get_Cron_Array;
         begin
            if
              Crons /= Empty_Array -- and then
--            Is_Array (Crons)
            then
               -- Remove errant `false` values, see #53950, #54906.
               Crons := Array_Filter (Crons);
               X_Set_Cron_Array (Crons);
            end if;
         end;
      end if;
   end Upgrade_590;

   -----------------
   -- Upgrade_600 --
   -----------------

   procedure Upgrade_600
   is
      use Inc_Users;
   begin
      if Wp_Current_DB_Version < 53011 then
         Wp_Update_User_Counts;
      end if;
   end Upgrade_600;

   ----------------
   -- Drop_Index --
   ----------------

   procedure Drop_Index (Table : String;
                         Index : String)
   is
      use Globals;
      use Class_WpDB;
   begin
      WpDB.Hide_Errors;

      WpDB.Query (Statement_Type (
        "ALTER TABLE `" & Table & "` DROP INDEX `" & Index & "`"));

      -- Now we need to take out all the extra ones we may have created.
      for I in 0 .. 24 loop
         WpDB.Query (Statement_Type (
           "ALTER TABLE `" & Table & "` DROP INDEX `" &
           Index & "_" & Helpers.Image (I) & "`"));
      end loop;

      WpDB.Show_Errors;

--    return true;
   end Drop_Index;

   ---------------------
   -- Add_Clean_Index --
   ---------------------

   procedure Add_Clean_Index (Table : String;
                              Index : String)
   is
      use Globals;
      use Class_WpDB;
   begin
      Drop_Index (Table, Index);
      WpDB.Query (Statement_Type (
        "ALTER TABLE `" & Table & "` ADD INDEX ( `" & Index & "` )"));

--    return true;
   end Add_Clean_Index;

   ------------------
   -- X_Get_Option --
   ------------------

   function X_Get_Option (Setting : String)
                          return Arrays.Multi_Type
   is
      use Php.Lists;
      use UStrings;
      use Inc_Formatting;
      use Inc_Functions;
   begin
      if "home" = Setting and then Globals.WP_HOME_DEF then
         return From_String (Un_Trailing_Slash_It (Globals.WP_HOME));
      end if;

      if "siteurl" = Setting and then Globals.WP_SITEURL_DEF then
         return From_String (Un_Trailing_Slash_It (Globals.WP_SITEURL));
      end if;

      declare
         Option : constant String :=
           Globals.WpDB.Get_Var (
             Globals.WpDB.Prepare (
               "SELECT option_value FROM " & (-Globals.WpDB.Options) &
               " WHERE option_name = %s", To_List (Setting)));
      begin
         if "home" = Setting and then Option = "" then -- not
            return X_Get_Option ("siteurl");
         end if;

         if
           In_List (Setting, To_List (List => (+"siteurl", +"home",
                                               +"category_base", +"tag_base")), True)
         then
            return Maybe_Unserialize (Un_Trailing_Slash_It (Option));
         end if;

         return Maybe_Unserialize (Option);
      end;
   end X_Get_Option;

   --------------
   -- DB_Delta --
   --------------

   function DB_Delta (Queries : String  := "";
                      Execute : Boolean := True)
                      return Array_Type
   is
      use Ada.Strings.Unbounded;
      use Php.Arrays;
      use Php.Lists;
      use Php.Misc;
      use Php.Preg;
      use Php.Strings;
      use Globals;
      use UStrings;
      use Adi_Schemas;
      use Class_WpDB;
      use Inc_Plugins;

      List : constant List_Type := To_List (List => (+"", +"all", +"blog",
                                                     +"global", +"ms_global"));
      Queries_2 : constant String :=
         (if In_List (Queries, List, True)
          then Wp_Get_DB_Schema (Queries)
          else Queries);

      -- Separate individual queries into an array.
--      if not Is_Array (Queries) then
      Queries_3 : constant List_Type := Explode (";", Queries_2);
      Queries_4 : constant List_Type := List_Filter (Queries_3);
--      end if;

      --
      -- Filters the dbDelta SQL queries.
      --
      -- @since 3.3.0
      --
      -- @param string[] queries An array of dbDelta SQL queries.
      --
      Queries_5 : constant List_Type :=
        Apply_Filters ("dbdelta_queries", Queries_4);

      C_Queries  : Array_Type; -- Creation queries.
      I_Queries  : Array_Type; -- Insertion queries.
      For_Update : Array_Type;
      Matches    : List_Type;
   begin
      -- Create a tablename index for an array (cqueries) of queries.
      for Qry of Queries_5 loop
         if Preg_Match ("|CREATE TABLE ([^ ]*)|", -Qry, Matches) /= 0 then
            declare
               M : constant String := -Matches (1); -- [1]
            begin
               Set (C_Queries,  Trim (M, "`"), From_String (-Qry));
               Set (For_Update, M,             From_String ("Created table " & M));
            end;

         elsif Preg_Match ("|CREATE DATABASE ([^ ]*)|", -Qry, Matches) /= 0 then
            Array_Unshift (C_Queries, -Qry);

         elsif Preg_Match ("|INSERT INTO ([^ ]*)|", -Qry, Matches) /= 0 then
            I_Queries.Append (From_String (-Qry));

         elsif Preg_Match ("|UPDATE ([^ ]*)|", -Qry, Matches) /= 0 then
            I_Queries.Append (From_String (-Qry));

         else
            null;  -- Unrecognized query type.
         end if;
      end loop;

      --
      -- Filters the dbDelta SQL queries for creating tables and/or databases.
      --
      -- Queries filterable via this hook contain "CREATE TABLE" or
      -- "CREATE DATABASE".
      --
      -- @since 3.3.0
      --
      -- @param string[] cqueries An array of dbDelta create SQL queries.
      --
      C_Queries := Apply_Filters ("dbdelta_create_queries", C_Queries);

      --
      -- Filters the dbDelta SQL queries for inserting or updating.
      --
      -- Queries filterable via this hook contain "INSERT INTO" or "UPDATE".
      --
      -- @since 3.3.0
      --
      -- @param string[] iqueries An array of dbDelta insert or update SQL queries.
      --
      I_Queries := Apply_Filters ("dbdelta_insert_queries", I_Queries);

      declare
         Text_Fields : constant List_Type :=
           To_List (List => (+"tinytext", +"text", +"mediumtext", +"longtext"));

         Blob_Fields : constant List_Type :=
           To_List (List => (+"tinyblob", +"blob", +"mediumblob", +"longblob"));

         Int_Fields  : constant List_Type :=
           To_List (List => (+"tinyint", +"smallint", +"mediumint",
                             +"int", +"integer", +"bigint"));

         Global_Tables  : constant Array_Type := WpDB.Tables ("global");
         DB_Version     : constant String     := WpDB.DB_Version;
         DB_Server_Info : constant String     := WpDB.DB_Server_Info;
      begin
         for A in C_Queries.Iterate loop
            declare
               Table : constant String := Key (A);
               Qry   : constant String := As_String (Element (A));
            begin
               -- Upgrade global tables only for the main site. Don't upgrade at all
               -- if conditions are not optimal.
               if
                 In_Array (Table, Global_Tables, True) and then
                 not Wp_Should_Upgrade_Global_Tables
               then
                  Delete (Ref (C_Queries,  Table));
                  Delete (Ref (For_Update, Table));
                  goto Continue;
               end if;

               declare
                  -- Fetch the table column structure from the database.
                  Suppress : constant Boolean := WpDB.Suppress_Errors;

                  Tablefields : constant Array_Type :=
                    WpDB.Get_Results (Statement_Type ("DESCRIBE " & Table & ";"));
               begin
                  WpDB.Suppress_Errors (Suppress);

                  if Tablefields.Is_Empty then -- not
                     goto Continue;
                  end if;

                  declare
                     -- Clear the field and index arrays.
                     C_Fields                 : Array_Type;
                     Indices                  : List_Type;
                     Indices_Without_Subparts : List_Type;
                     Match_2 : List_Type;
                  begin
                     -- Get all of the field names in the query from between the
                     -- parentheses.
                     Preg_Match ("|\((.*)\)|ms", Qry, Match_2);
                     declare
                        Qryline : constant String := Trim (-Match_2 (1));

                        -- Separate field lines into an array.
                        Flds : constant List_Type := Explode ("\n", Qryline);
                     begin
                        -- For every field line specified in the query.
                        for Fld_0 of Flds loop
                           declare
                              Fld : constant String := Trim (-Fld_0, " \t\n\r\0\x0B,");
                              -- Default trim characters, plus ",".
                              Fvals : List_Type;
                           begin
                              -- Extract the field name.
                              Preg_Match ("|^([^ ]*)|", Fld, Fvals);
                              declare
                                 Fieldname : constant String :=
                                   Trim (-Fvals (1), "`");

                                 Fieldname_Lowercased : constant String :=
                                   Strtolower (Fieldname);

                                 -- Verify the found field name.
                                 Validfield    : Boolean := True;
                                 Index_Matches : Array_Type;
                              begin
                                 if Fieldname_Lowercased in
                                   ""
                                 | "primary"
                                 | "index"
                                 | "fulltext"
                                 | "unique"
                                 | "key"
                                 | "spatial"
                                 then
                                    Validfield := False;

                                    --
                                    -- Normalize the index definition.
                                    --
                                    -- This is done so the definition can be compared
                                    -- against the result of a `SHOW INDEX FROM
                                    -- table_name` query which returns the current
                                    -- table index information.
                                    --

                                    -- Extract type, name and columns from the definition.
                                    -- phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound
                                    -- don't remove regex indentation
                                    Preg_Match (
                                      "/^"
                                      &   "(?P<index_type>"             -- 1) Type of the index.
                                      &       "PRIMARY\s+KEY|(?:UNIQUE|FULLTEXT|SPATIAL)\s+(?:KEY|INDEX)|KEY|INDEX"
                                      &   ")"
                                      &   "\s+"                         -- Followed by at least one white space character.
                                      &   "(?:"                         -- Name of the index. Optional if type is PRIMARY KEY.
                                      &       "`?"                      -- Name can be escaped with a backtick.
                                      &           "(?P<index_name>"     -- 2) Name of the index.
                                      &               "(?:[0-9a-zA-Z_-]|[\xC2-\xDF][\x80-\xBF])+"
                                      &           ")"
                                      &       "`?"                      -- Name can be escaped with a backtick.
                                      &       "\s+"                     -- Followed by at least one white space character.
                                      &   ")*"
                                      &   "\("                          -- Opening bracket for the columns.
                                      &       "(?P<index_columns>"
                                      &           ".+?"                 -- 3) Column names, index prefixes, and orders.
                                      &       ")"
                                      &   "\)"                          -- Closing bracket for the columns.
                                      & "/im",
                                      Fld,
                                      Index_Matches
                                    );

                                    -- phpcs:enable
                                    declare
                                       -- Uppercase the index type and normalize space characters.
                                       Index_Type_2 : constant String :=
                                         Strtoupper (Preg_Replace ("/\s+/", " ", Trim (Get_As_String (Index_Matches, "index_type"))));

                                       -- "INDEX" is a synonym for "KEY", standardize on "KEY".
                                       Index_Type : constant String :=
                                         Str_Replace ("INDEX", "KEY", Index_Type_2);

                                       -- Escape the index name with backticks. An index for a primary key has no name.
                                       Index_Name : constant String :=
                                         (if "PRIMARY KEY" = Index_Type then ""
                                          else "`" & Strtolower (Get_As_String (Index_Matches, "index_name")) & "`");

                                       -- Parse the columns. Multiple columns are
                                       -- separated by a comma.
                                       To_Trim : constant List_Type :=
                                         Explode (",", Get_As_String (Index_Matches, "index_columns"));

                                       Index_Columns : constant Array_Type :=
                                         Array_Map (Trim'Access, To_Trim);

                                       Index_Columns_Without_Subparts : Array_Type :=
                                         Index_Columns;
                                    begin
                                       -- Normalize columns.
                                       for B in Index_Columns.Iterate loop
                                          declare
                                             Id : constant String := Key (B);

                                             Index_Column : constant String :=
                                               As_String (Element (B)); -- &

                                             Index_Column_Matches : Array_Type;
                                          begin
                                             -- Extract column name and number of indexed characters (sub_part).
                                             -- phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound
                                             -- don't remove regex indentation
                                             Preg_Match (
                                               "/"
                                               &   "`?"                      -- Name can be escaped with a backtick.
                                               &       "(?P<column_name>"    -- 1) Name of the column.
                                               &           "(?:[0-9a-zA-Z_-]|[\xC2-\xDF][\x80-\xBF])+"
                                               &       ")"
                                               &   "`?"                      -- Name can be escaped with a backtick.
                                               &   "(?:"                     -- Optional sub part.
                                               &       "\s*"                 -- Optional white space character between name and opening bracket.
                                               &       "\("                  -- Opening bracket for the sub part.
                                               &           "\s*"             -- Optional white space character after opening bracket.
                                               &           "(?P<sub_part>"
                                               &               "\d+"         -- 2) Number of indexed characters.
                                               &           ")"
                                               &           "\s*"             -- Optional white space character before closing bracket.
                                               &       "\)"                  -- Closing bracket for the sub part.
                                               &   ")?"
                                               & "/",
                                               Index_Column,
                                               Index_Column_Matches
                                             );

                                             -- phpcs:enable
                                             declare
                                                -- Escape the column name with backticks.
                                                Index_Column : Unbounded_String :=
                                                  +("`" & Get_As_String (Index_Column_Matches, "column_name") & "`");
                                             begin
                                                -- We don't need to add the subpart to index_columns_without_subparts
                                                Set (Index_Columns_Without_Subparts, Id,
                                                     From_String (-Index_Column));

                                                -- Append the optional sup part with the number of indexed characters.
                                                if Isset (Index_Column_Matches, "sub_part") then
                                                   Append (Index_Column, "(" & Get_As_String (Index_Column_Matches, "sub_part") & ")");
                                                end if;
                                             end;
                                          end;
                                       end loop;

                                       -- Build the normalized index definition and add
                                       -- it to the list of indices.
                                       Append (Indices,
                                               Index_Type & " " & Index_Name &
                                               " (" & Implode (",", Index_Columns) & ")");

                                       Append (Indices_Without_Subparts,
                                               Index_Type & " " & Index_Name &
                                               " (" & Implode (",", Index_Columns_Without_Subparts) & ")");

                                       -- Destroy no longer needed variables.
                                       -- unset( index_column, index_column_matches, index_matches, index_type, index_name, index_columns, index_columns_without_subparts );

                                       -- Break;
                                    end;

                                 end if; -- case;

                                 -- If it's a valid field, add it to the field array.
                                 if Validfield then
                                    Set (C_Fields, Fieldname_Lowercased,
                                         From_String (Fld));
                                 end if;
                              end;
                           end;
                        end loop;
                     end;

                     -- For every field in the table.
                     for Tablefield_0 in Tablefields.Iterate loop
                        declare
                           Tablefield : constant Array_Type :=
                             As_Array (Element (Tablefield_0));

                           Tablefield_Field_Lowercased : constant String :=
                             Strtolower (Get_As_String (Tablefield, "Field"));

                           Tablefield_Type_Lowercased : constant String :=
                             Strtolower (Get_As_String (Tablefield, "Type"));

                           Tablefield_Type_Without_Parentheses : constant String :=
                             Preg_Replace (
                               "/"
                               & "(.+)"       -- Field type, e.g. `int`.
                               & "\(\d*\)"    -- Display width.
                               & "(.*)"       -- Optional attributes, e.g. `unsigned`.
                               & "/",
                               "12",
                               Tablefield_Type_Lowercased
                             );

                           -- Get the type without attributes, e.g. `int`.
                           Tablefield_Type_Base : constant String :=
                             Strtok (Tablefield_Type_Without_Parentheses, " ");
                        begin
                           -- If the table field exists in the field array...
                           if Array_Key_Exists (Tablefield_Field_Lowercased, C_Fields) then
                              declare
                                 Matches : List_Type;
                              begin
                                 -- Get the field type from the query.
                                 Preg_Match
                                   ("|`?" & Get_As_String (Tablefield, "Field") & "`? ([^ ]*( unsigned)?)|i",
                                    Get_As_String (C_Fields, Tablefield_Field_Lowercased), Matches);
                                 declare
                                    Fieldtype : constant String := -Matches (1);

                                    Fieldtype_Lowercased : constant String :=
                                      Strtolower (Fieldtype);

                                    Fieldtype_Without_Parentheses : constant String :=
                                      Preg_Replace (
                                        "/"
                                        & "(.+)"       -- Field type, e.g. `int`.
                                        & "\(\d*\)"    -- Display width.
                                        & "(.*)"       -- Optional attributes, e.g. `unsigned`.
                                        & "/",
                                        "12",
                                        Fieldtype_Lowercased
                                      );

                                    -- Get the type without attributes, e.g. `int`.
                                    Fieldtype_Base : constant String :=
                                      Strtok (Fieldtype_Without_Parentheses, " ");
                                 begin
                                    -- Is actual field type different from the field
                                    -- type in query?
                                    if Get_As_String (Tablefield, "Type") /= Fieldtype then
                                       declare
                                          Do_Change : Boolean := True;
                                       begin
                                          if
                                            In_List (Fieldtype_Lowercased, Text_Fields, True) and then
                                            In_List (Tablefield_Type_Lowercased, Text_Fields, True)
                                          then
                                             if
                                               List_Search (Fieldtype_Lowercased, Text_Fields, True) <
                                               List_Search (Tablefield_Type_Lowercased, Text_Fields, True)
                                             then
                                                Do_Change := False;
                                             end if;
                                          end if;

                                          if
                                            In_List (Fieldtype_Lowercased, Blob_Fields, True) and then
                                            In_List (Tablefield_Type_Lowercased, Blob_Fields, True)
                                          then
                                             if
                                               List_Search (Fieldtype_Lowercased, Blob_Fields, True) <
                                               List_Search (Tablefield_Type_Lowercased, Blob_Fields, True)
                                             then
                                                Do_Change := False;
                                             end if;
                                          end if;

                                          if
                                            In_List (Fieldtype_Base, Int_Fields, True) and then
                                            In_List (Tablefield_Type_Base, Int_Fields, True) and then
                                            Fieldtype_Without_Parentheses = Tablefield_Type_Without_Parentheses
                                          then
                                             --
                                             -- MySQL 8.0.17 or later does not support display width for integer data types,
                                             -- so if display width is the only difference, it can be safely ignored.
                                             -- Note: This is specific to MySQL and does not affect MariaDB.
                                             --
                                             if
                                               Version_Compare (DB_Version, "8.0.17", ">=") and then
                                               not Str_Contains (DB_Server_Info, "MariaDB")
                                             then
                                                Do_Change := False;
                                             end if;
                                          end if;

                                          if Do_Change then
                                             -- Add a query to change the column type.
                                             C_Queries.Append (From_String (
                                               "ALTER TABLE " & Table &
                                               " CHANGE COLUMN `" & Get_As_String (Tablefield, "Field") & "` " &
                                               Get_As_String (C_Fields, Tablefield_Field_Lowercased)));

                                             Set (For_Update,
                                                  Table & "." & Get_As_String (Tablefield, "Field"),
                                                  From_String (
                                                  "Changed type of " & Table & "." & Get_As_String (Tablefield, "Field") &
                                                  " from " & Get_As_String (Tablefield, "Type") & " to " & Fieldtype));
                                          end if;
                                       end;
                                    end if;

                                    -- Get the default value from the array.
                                    if
                                      Preg_Match ("| DEFAULT '(.*?)'|i",
                                                  Get_As_String (C_Fields, Tablefield_Field_Lowercased), Matches) /= 0
                                    then
                                       declare
                                          Default_Value : constant String :=
                                            -Matches (1);
                                       begin
                                          if Get_As_String (Tablefield, "Default") /= Default_Value then
                                             -- Add a query to change the column's
                                             -- default value
                                             C_Queries.Append (From_String (
                                               "ALTER TABLE " & Table &
                                               " ALTER COLUMN `" & Get_As_String (Tablefield, "Field") &
                                               "` SET DEFAULT '" & Default_Value & "'"));

                                             Set (For_Update,
                                                  Table & "." & Get_As_String (Tablefield, "Field"),
                                                  From_String (
                                                  "Changed default value of " & Table & "." & Get_As_String (Tablefield, "Field") &
                                                  " from " & Get_As_String (Tablefield, "Default") & " to " & Default_Value));
                                          end if;
                                       end;
                                    end if;

                                    -- Remove the field from the array (so it's not
                                    -- added).
                                    Delete (Ref (C_Fields, Tablefield_Field_Lowercased));
                                 end;
                              end;
                           else
                              null;
                              -- This field exists in the table, but not in the
                              -- creation queries?
                           end if;
                        end;
                     end loop;

                     -- For every remaining field specified for the table.
                     for E in C_Fields.Iterate loop
                        declare
                           Fieldname : constant String := Key (E);
                           Fielddef  : constant String := As_String (Element (E));
                        begin
                           -- Push a query line into cqueries that adds the field to
                           -- that table.
                           C_Queries.Append (From_String (
                             "ALTER TABLE " & Table & " ADD COLUMN " & Fielddef));

                           Set (For_Update,
                                Table & "." & Fieldname,
                                From_String (
                                  "Added column " & Table & "." & Fieldname));
                        end;
                     end loop;

                     -- Index stuff goes here. Fetch the table index structure from
                     -- the database.
                     declare
                        Tableindices : constant Array_Type :=
                          WpDB.Get_Results (Statement_Type (
                            "SHOW INDEX FROM " & Table & ";"));
                     begin
                        if not Tableindices.Is_Empty then
                           declare
                              -- Clear the index array.
                              Index_Ary : Array_Type;
                           begin
                              -- For every index in the table.
                              for Tableindex_0 in Tableindices.Iterate loop
                                 declare
                                    Tableindex : constant Array_Type :=
                                      As_Array (Element (Tableindex_0));

                                    Keyname : constant String :=
                                      Strtolower (Get_As_String (Tableindex, "Key_Name"));
                                 begin
                                    -- Add the index to the index data array.
                                    Append_2
                                      (Index_Ary,
                                       Key_1 => Keyname,
                                       Key_2 => "columns",
                                       Value => From_Array (To_Array (List => (
                                         Build ("fieldname", Get_As_String (Tableindex, "Column_Name")),
                                         Build ("subpart",   Get_As_String (Tableindex, "Sub_Part"))
                                       )))
                                      );

                                    Set_2 (Index_Ary, Keyname, "unique",
                                           Value => From_Boolean
                                                    (if "0" = Get_As_String (Tableindex, "Non_Unique")
                                                     then True else False));
                                    Set_2 (Index_Ary, Keyname, "index_type",
                                           Value => From_String (
                                             Get_As_String (Tableindex, "Index_Type")));
                                 end;
                              end loop;

                              -- For each actual index in the index array.
                              for F in Index_Ary.Iterate loop
                                 declare
                                    Index_Name : constant String := Key (F);

                                    Index_Data : constant Array_Type :=
                                      As_Array (Element (F));

                                    Index_String  : Unbounded_String;
                                    Index_Columns : Unbounded_String;
                                 begin
                                    -- Build a create string to compare to the query.
                                    if "primary" = Index_Name then
                                       Append (Index_String, "PRIMARY ");

                                    elsif Get_As_String (Index_Data, "unique") /= "" then
                                       Append (Index_String, "UNIQUE ");
                                    end if;

                                    if "FULLTEXT" = Strtoupper (Get_As_String (Index_Data, "index_type")) then
                                       Append (Index_String, "FULLTEXT ");
                                    end if;

                                    if "SPATIAL" = Strtoupper (Get_As_String (Index_Data, "index_type")) then
                                       Append (Index_String, "SPATIAL ");
                                    end if;

                                    Append (Index_String, "KEY ");
                                    if "primary" /= Index_Name then
                                       Append (Index_String, "`" & Index_Name & "`");
                                    end if;

                                    -- For each column in the index.
                                    for
                                      Column_Data_0 in
                                      As_Array (Get (Index_Data, "columns")).Iterate
                                    loop
                                       declare
                                          Column_Data : constant Multi_Type :=
                                            Element (Column_Data_0);
                                       begin
                                          if "" /= Index_Columns then
                                             Append (Index_Columns, ",");
                                          end if;

                                          -- Add the field to the column list string.
                                          Append (Index_Columns,
                                                  String'("`" & Get_As_String (As_Array (Column_Data), "fieldname") & "`"));
                                       end;
                                    end loop;

                                    -- Add the column list to the index create string.
                                    Append (Index_String, " (" & Index_Columns & ")");

                                    -- Check if the index definition exists, ignoring
                                    -- subparts.
                                    declare
                                       A_Index : constant String :=
                                         List_Search (-Index_String, Indices_Without_Subparts, True);
                                    begin
                                       if A_Index /= "" then
--                                     if False /= A_Index then
                                          -- If the index already exists (even with
                                          -- different subparts), we don't need to
                                          -- create it.
                                          null;
--                                        Delete (Ref (Indices_Without_Subparts, A_Index));
--                                        Delete (Ref (Indices, A_Index));
                                       end if;
                                    end;
                                 end;
                              end loop;
                           end;
                        end if;

                        -- For every remaining index specified for the table.
                        for Index of Indices loop -- (array)
                           -- Push a query line into cqueries that adds the index to that table.
                           C_Queries.Append (From_String (
                             -("ALTER TABLE " & Table & " ADD " & Index)));

                           For_Update.Append (From_String (
                             -("Added " & Index & " " & Table & " " & Index)));
                        end loop;

                        -- Remove the original table creation query from processing.
                        Delete (Ref (C_Queries,  Table));
                        Delete (Ref (For_Update, Table));
                     end;
                  end;
               end;
            end;
            << Continue >>
         end loop;

         declare
            All_Queries : constant Array_Type :=
              Array_Merge (C_Queries, I_Queries);
         begin
            if Execute then
               for Q in All_Queries.Iterate loop
                  declare
                     Query : constant Multi_Type := Element (Q);
                  begin
                     WpDB.Query (Statement_Type (As_String (Query)));
                  end;
               end loop;
            end if;
         end;

         return For_Update;
      end;
   end DB_Delta;

   ----------------------------
   -- Make_DB_Current_Silent --
   ----------------------------

   procedure Make_DB_Current_Silent (Tables : String := "all")
   is
      Unused : constant Array_Type := DB_Delta (Tables);
   begin
      null;
   end Make_DB_Current_Silent;

   ----------------------------
   -- Wp_Check_MySQL_Version --
   ----------------------------

   procedure Wp_Check_MySQL_Version
   is
      use Class_Errors;
      use Inc_Functions;
      use Inc_Load;

      Result : constant Wp_Error :=
        Globals.WpDB.Check_Database_Version;
   begin
      if Is_Wp_Error (Result) then
         Wp_Die (Result.Get_Error_Code); -- Get_Error_Code added
      end if;
   end Wp_Check_MySQL_Version;

   --------------------------------------
   -- Maybe_Disable_Automattic_Widgets --
   --------------------------------------

   procedure Maybe_Disable_Automattic_Widgets
   is
      use Php.Arrays;
      use Php.Files;
      use UStrings;
      use Inc_Options;

      Plugins : constant List_Type := Empty_List;  -- ???
--      As_List (X_Get_Option ("active_plugins"));
   begin
      for Plugin of Plugins loop -- (array)
         if "widgets.php" = Basename (-Plugin) then
--          Array_Splice (Plugins, Array_Search (-Plugin, Plugins, True), 1); -- ???
            Update_Option ("active_plugins", From_List (Plugins));
            exit;
         end if;
      end loop;
   end Maybe_Disable_Automattic_Widgets;

   --------------------------------
   -- Maybe_Disable_Link_Manager --
   --------------------------------

   procedure Maybe_Disable_Link_Manager
   is
      use Globals;
      use Inc_Options;
--    global wp_current_db_version, wpdb;
   begin
      if
        Wp_Current_DB_Version >= 22006 and then
        Get_Option ("link_manager_enabled") and then
        "" = WpDB.Get_Var ("SELECT link_id FROM wpdb->links LIMIT 1") -- not
      then
         Update_Option ("link_manager_enabled", From_Integer (0));
      end if;
   end Maybe_Disable_Link_Manager;

   -----------------------
   -- Pre_Scema_Upgrade --
   -----------------------

   procedure Pre_Schema_Upgrade
   is
      use Globals;
      use UStrings;
      use Class_WpDB;
      use Inc_Load;
--    global wp_current_db_version, wpdb;
   begin
      -- Upgrade versions prior to 2.9.
      if Wp_Current_DB_Version < 11557 then
         -- Delete duplicate options. Keep the option with the highest option_id.
         WpDB.Query ("DELETE o1 FROM wpdb->options AS o1 JOIN wpdb->options AS o2 USING (`option_name`) WHERE o2.option_id > o1.option_id");

         -- Drop the old primary key and add the new.
         WpDB.Query ("ALTER TABLE wpdb->options DROP PRIMARY KEY, ADD PRIMARY KEY(option_id)");

         -- Drop the old option_name index. dbDelta() Doesn't do the drop.
         WpDB.Query ("ALTER TABLE wpdb->options DROP INDEX option_name");
      end if;

      -- Multisite schema upgrades.
      if
        Wp_Current_DB_Version < 25448 and then
        Is_Multisite and then
        Wp_Should_Upgrade_Global_Tables
      then
         -- Upgrade versions prior to 3.7.
         if Wp_Current_DB_Version < 25179 then
            -- New primary key for signups.
            WpDB.Query ("ALTER TABLE wpdb->signups ADD signup_id BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST");
            WpDB.Query ("ALTER TABLE wpdb->signups DROP INDEX domain");
         end if;

         if Wp_Current_DB_Version < 25448 then
            -- Convert archived from enum to tinyint.
            WpDB.Query ("ALTER TABLE wpdb->blogs CHANGE COLUMN archived archived varchar(1) NOT NULL default '0'");
            WpDB.Query ("ALTER TABLE wpdb->blogs CHANGE COLUMN archived archived tinyint(2) NOT NULL default 0");
         end if;
      end if;

      -- Upgrade versions prior to 4.2.
      if Wp_Current_DB_Version < 31351 then
         if
           not Is_Multisite and then
           Wp_Should_Upgrade_Global_Tables
         then
            WpDB.Query ("ALTER TABLE wpdb->usermeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         end if;
         WpDB.Query ("ALTER TABLE wpdb->terms DROP INDEX slug, ADD INDEX slug(slug(191))");
         WpDB.Query ("ALTER TABLE wpdb->terms DROP INDEX name, ADD INDEX name(name(191))");
         WpDB.Query ("ALTER TABLE wpdb->commentmeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         WpDB.Query ("ALTER TABLE wpdb->postmeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         WpDB.Query ("ALTER TABLE wpdb->posts DROP INDEX post_name, ADD INDEX post_name(post_name(191))");
      end if;

      -- Upgrade versions prior to 4.4.
      if Wp_Current_DB_Version < 34978 then
         -- If compatible termmeta table is found, use it, but enforce a proper
         -- index and update collation.
         if
           "" /= WpDB.Get_Var
             (Statement_Type ("SHOW TABLES LIKE '" & (-WpDB.Termmeta) & "'"))
         and then
           WpDB.Get_Results (Statement_Type (
             "SHOW INDEX FROM " & (-WpDB.Termmeta) &
             " WHERE Column_name = 'meta_key'")) /= Empty_Array
         then
            WpDB.Query ("ALTER TABLE wpdb->termmeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
            Maybe_Convert_Table_To_Utf8mb4 (-WpDB.Termmeta);
         end if;
      end if;
   end Pre_Schema_Upgrade;

   -------------------------------------
   -- Wp_Should_Upgrade_Global_Tables --
   -------------------------------------

   function Wp_Should_Upgrade_Global_Tables
            return Boolean
   is
      use Inc_Functions;
      use Inc_Plugins;

      -- Assume global tables should be upgraded.
      Should_Upgrade : Boolean := True;
   begin
      -- Return false early if explicitly not upgrading.
      if Globals.DO_NOT_UPGRADE_GLOBAL_TABLES then
         return False;
      end if;

      -- Set to false if not on main network (does not matter if not multi-network).
      if not Is_Main_Network then
         Should_Upgrade := False;
      end if;

      -- Set to false if not on main site of current network (does not matter if
      -- not multi-site).
      if not Is_Main_Site then
         Should_Upgrade := False;
      end if;

      --
      -- Filters if upgrade routines should be run on global tables.
      --
      -- @since 4.3.0
      --
      -- @param bool should_upgrade Whether to run the upgrade routines on
      -- global tables.
      --
      return Apply_Filters ("wp_should_upgrade_global_tables", Should_Upgrade);
   end Wp_Should_Upgrade_Global_Tables;

end Adi_Upgrade;
