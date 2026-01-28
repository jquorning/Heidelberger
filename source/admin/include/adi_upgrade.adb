--
-- WordPress Upgrade API
--
-- Most of the functions are pluggable and can be overwritten.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Arrays;
with Php.Files;
with Php.Lists;
with Php.Misc;
with Php.Preg;
with Php.Strings;

with Constants;
with Globals;
with Helpers;
with Lists;
with UStrings;
with Wp_Common;

with Adi_Files;
with Adi_Plugins;
with Adi_Schemas;

with Class_Categories;
with Class_Comments;
with Class_Errors;
with Class_Links;
with Class_Options;
with Class_Posts;
with Class_Post2cat;
with Class_Roles;
with Class_WpDB;

with Inc_Caches;
with Inc_Capabilities;
with Inc_Cron;
with Inc_Formatting;
with Inc_Functions;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Ms_Sites;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Posts;
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
            User_Id         : User_Id_Type := Username_Exists (User_Name);
            User_Password_2 : constant String  := Trim (User_Password);
            Email_Password  : Boolean := False;
            User_Created    : Boolean := False;

            Message : UString;
         begin
            if User_Id = 0 and then Empty (User_Password_2) then
               declare
                  User_Password : constant String := Wp_Generate_Password (12, False);

                  User_Id : constant User_Id_Type :=
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
                   Build ("user_id",          Integer (User_Id)),
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
   is
      use Php.Strings;
      use Globals;
      use UStrings;
      use Class_Categories;
      use Class_Posts;
      use Class_Post2cat;
      use Class_WpDB;
      use Inc_Formatting;

      Posts    : constant Statement_Type := Statement_Type (-WpDB.Posts);
      Options  : constant Statement_Type := Statement_Type (-WpDB.Options);
      Post2cat : constant Statement_Type := Statement_Type (-WpDB.Post2cat);

      -- Get the title and ID of every post, post_name to check if it already
      -- has a value.
      Posts_2 : constant Post_Array := -- Array_Type :=
        WpDB.Get_Results ("SELECT ID, post_title, post_name FROM " & Posts &
                          " WHERE post_name = ''");
   begin
      if not Posts_2.Is_Empty then
         for Post of Posts_2 loop
            if "" = Post.Post_Name then
               declare
                  Newtitle : constant String := Sanitize_Title (-Post.Post_Title);
               begin
                  WpDB.Query (WpDB.Prepare (
                    "UPDATE " & Posts & " SET post_name = %s WHERE ID = %d",
                    [
                      1 => Newtitle,
                      2 => Helpers.Image (Integer (Post.Id))
                    ]
                  ));
               end;
            end if;
         end loop;
      end if;

      declare
         Categories_2 : constant Statement_Type := Statement_Type (-WpDB.Categories);

         Categories : constant Categories_List :=
           WpDB.Get_Results (
             "SELECT cat_ID, cat_name, category_nicename FROM " & Categories_2);
      begin
         for Category of Categories loop
            if "" = Category.Category_Nicename then
               declare
                  Newtitle : constant String := Sanitize_Title (-Category.Cat_Name);
               begin
                  WpDB.Update
                    (-WpDB.Categories,
                     Data  => To_Array (List => (1 =>
                       Build ("category_nicename", Newtitle))),
                     Where => To_Array (List => (1 =>
                       Build ("cat_ID", Category.Cat_Id))));
               end;
            end if;
         end loop;
      end;

      declare
         SQL : constant Statement_Type :=
           "UPDATE " & Options &
           " SET option_value =" &
           " REPLACE(option_value, 'wp-links/links-images/', 'wp-images/links/')" &
           " WHERE option_name LIKE %S" &
           " AND option_value LIKE %s";

         Cat_Where : UString;
      begin
         WpDB.Query (WpDB.Prepare (SQL,
           [
             1 => WpDB.ESC_Like ("links_rating_image") & "%",
             2 => WpDB.ESC_Like ("wp-links/links-images/") & "%"
           ]
         ));

         declare
            Done_Ids : constant Post2cat_List :=
              WpDB.Get_Results ("SELECT DISTINCT post_id FROM " & Post2cat);
         begin
            if not Done_Ids.Is_Empty then
               declare
                  Done_Posts : List_Type; --  = array();
               begin
                  for Done_Id of Done_Ids loop
                     Done_Posts.Append (Helpers.Image (Done_Id.Post_Id));
                  end loop;
                  Cat_Where := +" AND ID NOT IN (" & Implode (",", Done_Posts) & ")";
               end;
            else
               Cat_Where := +"";
            end if;
         end;

         declare
            Cat_Where_2 : constant Statement_Type := Statement_Type (-Cat_Where);

            All_Posts : constant Post_Array := -- Array_Type :=
              WpDB.Get_Results ("SELECT ID, post_category FROM " & Posts &
                                " WHERE post_category != '0' " & Cat_Where_2);
         begin
            if not All_Posts.Is_Empty then
               for Post of All_Posts loop
                  -- Check to see if it's already been imported.
                  declare
                     Success : Boolean;

                     Cat : constant Post2cat_List := -- Duration :=
                       WpDB.Get_Row (WpDB.Prepare (
                         "SELECT * FROM " & Post2cat &
                         " WHERE post_id = %d AND category_id = %d",
                         [
                           1 => Helpers.Image (Integer (Post.Id)),
                           2 => -Post.Post_Category
                         ]
                       ),
                       Success => Success
                     );
                  begin
                     -- If there's no result.
                     if
                       not Cat.Is_Empty and then
--                     not Cat and then
                       "" /= Post.Post_Category
                     then
                        WpDB.Insert (
                          -WpDB.Post2cat,
                          To_Array (List => (
                            Build ("post_id",     Integer (Post.Id)),
                            Build ("category_id", -Post.Post_Category)
                          ))
                        );
                     end if;
                  end;
               end loop;
            end if;
         end;
      end;
   end Upgrade_100;

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
      Add_Clean_Index (-WpDB.Categories, "category_nicename");
      Add_Clean_Index (-WpDB.Comments, "comment_approved");
      Add_Clean_Index (-WpDB.Comments, "comment_post_ID");
      Add_Clean_Index (-WpDB.Links, "link_category");
      Add_Clean_Index (-WpDB.Links, "link_visible");
   end Upgrade_101;

   -----------------
   -- Upgrade_110 --
   -----------------

   procedure Upgrade_110
   is
      use Php.Preg;
      use Constants;
      use Globals;
      use UStrings;
      use Class_Users;
      use Class_WpDB;
      use Inc_Formatting;
      use Inc_Options;

      Users_2 : constant Statement_Type := Statement_Type (-WpDB.Users);

      Diff_GMT_Weblogger : Integer;
   begin
      declare
         -- Set user_nicename.
         Users : constant User_List :=
           WpDB.Get_Results (
             "SELECT ID, user_nickname, user_nicename FROM " & Users_2);
      begin
         for User of Users loop
            if "" = User.Prop.User_Nicename then
               declare
                  Newname : constant String := Sanitize_Title (-User.Prop.Nickname);
--                Newname : String := Sanitize_Title (User.Prop.User_Nickname);
               begin
                  WpDB.Update
                    (-WpDB.Users,
                     To_Array (List => (1 => Build ("user_nicename", Newname))),
                     To_Array (List => (1 => Build ("ID", Integer (User.Id))))
                  );
               end;
            end if;
         end loop;
      end;

      declare
         Users : constant User_List :=
           WpDB.Get_Results ("SELECT ID, user_pass from " & Users_2);
      begin
         for Row of Users loop
            if not Preg_Match ("/^[A-Fa-f0-9]{32}/", -Row.Prop.User_Pass) then
               WpDB.Update
                 (-WpDB.Users,
                  To_Array (List => (1 =>
                    Build ("user_pass", Php.Misc.MD5 (-Row.Prop.User_Pass)))),
                  To_Array (List => (1 =>
                    Build ("ID", Integer (Row.Id))))
                 );
            end if;
         end loop;
      end;

      declare
         -- Get the GMT offset, we'll use that later on.
         All_Options : constant Array_Type := Get_Alloptions_110;

         Time_Difference : constant Integer := 999; -- All_Options.Time_Difference;

         Server_Time : constant Integer := Php.Misc.Time + 0;
         -- + Php.Misc.GMdate ("Z");  -- returns string ???

         Weblogger_Time : constant Integer :=
           Server_Time + Time_Difference * HOUR_IN_SECONDS;

         GMT_Time : constant Integer := Php.Misc.Time;

         Diff_GMT_Server : constant Integer :=
           (GMT_Time - Server_Time) / HOUR_IN_SECONDS;

         Diff_Weblogger_Server : constant Integer :=
           (Weblogger_Time - Server_Time) / HOUR_IN_SECONDS;

         GMT_Offset : Integer;
      begin
         Diff_GMT_Weblogger :=
           Diff_GMT_Server - Diff_Weblogger_Server;

         GMT_Offset := -Diff_GMT_Weblogger;

         -- Add a gmt_offset option, with value gmt_offset.
         Add_Option ("gmt_offset", From_Integer (GMT_Offset));
      end;

      --
      -- Check if we already set the GMT fields. If we did, then
      -- MAX(post_date_gmt) can't be "0000-00-00 00:00:00".
      -- <michel_v> I just slapped myself silly for not thinking about it earlier.
      --
      declare
         Posts    : constant Statement_Type := Statement_Type (-WpDB.Posts);
         Comments : constant Statement_Type := Statement_Type (-WpDB.Comments);
         Users    : constant Statement_Type := Statement_Type (-WpDB.Users);

         Got_GMT_Fields : constant Boolean :=
           "0000-00-00 00:00:00" /=
           WpDB.Get_Var ("SELECT MAX(post_date_gmt) FROM " & Posts);
      begin
         if not Got_GMT_Fields then
            -- Add or subtract time to all dates, to get GMT dates.
            declare
               Add_Hours   : constant Integer := Diff_GMT_Weblogger; -- (int)

               Add_Minutes : constant Integer :=
                 (60 * (Diff_GMT_Weblogger - Add_Hours));

               Hours : constant Statement_Type :=
                 Statement_Type (Helpers.Image (Add_Hours));

               Minutes : constant Statement_Type :=
                 Statement_Type (Helpers.Image (Add_Minutes));
            begin
               WpDB.Query ("UPDATE " & Posts &
                           " SET post_date_gmt = DATE_ADD(post_date, INTERVAL " &
                           Hours & ":" & Minutes & " HOUR_MINUTE)");

               WpDB.Query ("UPDATE " & Posts & " SET post_modified = post_date");

               WpDB.Query
                 ("UPDATE " & Posts &
                  " SET post_modified_gmt = DATE_ADD(post_modified, INTERVAL '" &
                  Hours & ":" & Minutes &
                  "' HOUR_MINUTE) WHERE post_modified != '0000-00-00 00:00:00'");

               WpDB.Query
                 ("UPDATE " & Comments &
                  " SET comment_date_gmt = DATE_ADD(comment_date, INTERVAL '" &
                  Hours & ":" & Minutes & "' HOUR_MINUTE)");

               WpDB.Query
                 ("UPDATE " & Users &
                  " SET user_registered = DATE_ADD(user_registered, INTERVAL '" &
                  Hours & ":" & Minutes & "' HOUR_MINUTE)");
            end;
         end if;
      end;
   end Upgrade_110;

   -----------------
   -- Upgrade_130 --
   -----------------

   procedure Upgrade_130
   is
      use Php.Strings;
      use Globals;
      use UStrings;
      use Class_Comments;
      use Class_Links;
      use Class_Options;
      use Class_Posts;
      use Class_WpDB;
      use Inc_Link_Templates;
   begin
      -- Remove extraneous backslashes.
      declare
         Posts_2 : constant Statement_Type := Statement_Type (-WpDB.Posts);

         Posts : constant Post_Array :=
           WpDB.Get_Results (
             "SELECT ID, post_title, post_content, post_excerpt, guid, post_date, " &
             "post_name, post_status, post_author FROM " & Posts_2);
      begin
         if not Posts.Is_Empty then
            for Post of Posts loop
               declare
                  Post_Content : constant String :=
                    Add_Slashes (Deslash (-Post.Post_Content));

                  Post_Title   : constant String :=
                    Add_Slashes (Deslash (-Post.Post_Title));

                  Post_Excerpt : constant String :=
                    Add_Slashes (Deslash (-Post.Post_Excerpt));

                  GUID : constant String :=
                    (if Empty (-Post.GUID)
                     then Get_Permalink (Post.Id)
                     else -Post.GUID);

                  Update : constant Array_Type :=
                    To_Array (List => (
                      Build ("post_title",   Post_Title),
                      Build ("post_content", Post_Content),
                      Build ("post_exerpt",  Post_Excerpt),
                      Build ("guid",         GUID)
                    ));
               begin
                  WpDB.Update
                    (-WpDB.Posts, Update,
                     To_Array (List => (1 =>
                       Build ("ID", Integer (Post.Id))))
                    );
               end;
            end loop;
         end if;
      end;

      -- Remove extraneous backslashes.
      declare
         Comments_2 : constant Statement_Type := Statement_Type (-WpDB.Comments);

         Comments : constant Comments_List :=
           WpDB.Get_Results (
             "SELECT comment_ID, comment_author, comment_content FROM " & Comments_2);
      begin
         if not Comments.Is_Empty then
            for Comment of Comments loop
               declare
                  Comment_Content : constant String :=
                    Deslash (-Comment.Comment_Content);

                  Comment_Author : constant String :=
                    Deslash (-Comment.Comment_Author);

                  Update : constant Array_Type :=
                    To_Array (List => (
                      Build ("comment_content", Comment_Content),
                      Build ("comment_author",  Comment_Author)
                    ));
               begin
                  WpDB.Update (-WpDB.Comments, Update,
                               To_Array (List => (1 =>
                                 Build ("comment_ID", -Comment.Comment_Id))));
               end;
            end loop;
         end if;
      end;

      -- Remove extraneous backslashes.
      declare
         Links_2 : constant Statement_Type := Statement_Type (-WpDB.Links);

         Links : constant Links_List :=
           WpDB.Get_Results (
             "SELECT link_id, link_name, link_description FROM " & Links_2);
      begin
         if not Links.Is_Empty then
            for Link of Links loop
               declare
                  Link_Name : constant String :=
                    Deslash (-Link.Link_Name);

                  Link_Description : constant String :=
                    Deslash (-Link.Link_Description);

                  Update : constant Array_Type :=
                    To_Array (List => (
                      Build ("link_name",        Link_Name),
                      Build ("link_description", Link_Description)
                    ));
               begin
                  WpDB.Update (-WpDB.Links, Update, To_Array (List => (1 =>
                    Build ("link_id", Link.Link_Id))));
               end;
            end loop;
         end if;
      end;

      -- declare
      --    Active_Plugins : Duration := X_Get_Option ("active_plugins");
      -- begin
      --    --
      --    -- If plugins are not stored in an array, they're stored in the old
      --    -- newline separated format. Convert to new format.
      --    --
      --    if ( ! is_array( active_plugins ) ) then
      --           active_plugins = explode( "\n", trim( active_plugins ) );
      --           update_option( "active_plugins", active_plugins );
      --    end if;
      -- end;

      -- Obsolete tables.
      declare
         Prefix : constant Statement_Type := Statement_Type (-WpDB.Prefix);
      begin
         WpDB.Query ("DROP TABLE IF EXISTS " & Prefix & "optionvalues");
         WpDB.Query ("DROP TABLE IF EXISTS " & Prefix & "optiontypes");
         WpDB.Query ("DROP TABLE IF EXISTS " & Prefix & "optiongroups");
         WpDB.Query ("DROP TABLE IF EXISTS " & Prefix & "optiongroup_options");
      end;

      -- Update comments table to use comment_type.
      declare
         Comments : constant Statement_Type := Statement_Type (-WpDB.Comments);
      begin
         WpDB.Query (
           "UPDATE " & Comments &
           " SET comment_type='trackback', comment_content = " &
           "REPLACE(comment_content, '<trackback />', '') " &
           "WHERE comment_content LIKE '<trackback />%'");

         WpDB.Query (
           "UPDATE " & Comments &
           " SET comment_type='pingback', comment_content = " &
           "REPLACE(comment_content, '<pingback />', '') " &
           "WHERE comment_content LIKE '<pingback />%'");
      end;

      -- Some versions have multiple duplicate option_name rows with the same values.
      declare
         Options_2 : constant Statement_Type := Statement_Type (-WpDB.Options);

         Options : constant Options_List :=
           WpDB.Get_Results (
             "SELECT option_name, COUNT(option_name) AS dupes FROM `" & Options_2 &
             "` GROUP BY option_name");
      begin
         for Option of Options loop
            if 1 /= Option.Dupes then -- Could this be done in the query?
               declare
                  Limit : constant Integer := Option.Dupes - 1;

                  Dupe_Ids : constant List_Type :=
                    WpDB.Get_Col (WpDB.Prepare (
                      "SELECT option_id FROM " & Options_2 &
                      " WHERE option_name = %s LIMIT %d",
                      [
                        1 => -Option.Option_Name,
                        2 => Helpers.Image (Limit)
                      ]
                    ));
               begin
                  if not Dupe_Ids.Is_Empty then
                     declare
                        Dupe_Ids_2 : constant Statement_Type :=
                          Statement_Type (Implode (",", Dupe_Ids));
                     begin
                        WpDB.Query (
                          "DELETE FROM " & Options_2 &
                          " WHERE option_id IN (" & Dupe_Ids_2 & ")");
                     end;
                  end if;
               end;
            end if;
         end loop;
      end;

      Make_Site_Theme;
   end Upgrade_130;

   -----------------
   -- Upgrade_160 --
   -----------------

   procedure Upgrade_160
   is
      use Php.Strings;
      use Constants;
      use Globals;
      use UStrings;
      use Adi_Schemas;
      use Class_Comments;
      use Class_Posts;
      use Class_Users;
      use Class_WpDB;
      use Inc_Formatting;
      use Inc_Posts;
      use Inc_Users;

      Users_2 : constant Statement_Type := Statement_Type (-WpDB.Users);
   begin
      Populate_Roles_160;

      declare
         Users : constant User_List :=
           WpDB.Get_Results ("SELECT * FROM " & Users_2);
      begin
         for User of Users loop
            if not Empty (-User.Prop.User_Firstname) then
               Update_User_Meta (User.Id, "first_name",
                                 Wp_Slash (-User.Prop.User_Firstname));
            end if;

            if not Empty (-User.Prop.User_Lastname) then
               Update_User_Meta (User.Id, "last_name",
                                 Wp_Slash (-User.Prop.User_Lastname));
            end if;

            if not Empty (-User.Prop.Nickname) then
--          if not Empty (-User.Prop.User_Nickname) then
               Update_User_Meta (User.Id, "nickname",
                                 Wp_Slash (-User.Prop.Nickname));
--                               Wp_Slash (-User.Prop.User_Nickname));
            end if;

            if User.Prop.User_Level /= 0 then
--          if not Empty (User.Prop.User_Level) then
               Update_User_Meta (User.Id, (-WpDB.Prefix) & "user_level",
                                 User.Prop.User_Level);
            end if;

            -- if not Empty (User.User_ICQ) then
            --    Update_User_Meta (User.Id, "icq", Wp_Slash (User.User_ICQ));
            -- end if;

            -- if not Empty (User.User_AIM) then
            --    Update_User_Meta (User.Id, "aim", Wp_Slash (User.User_AIM));
            -- end if;

            -- if not Empty (User.User_MSN) then
            --    Update_User_Meta  (User.Id, "msn", Wp_Slash (User.User_MSN));
            -- end if;

            -- if not Empty (User.User_YIM) then
            --    Update_User_Meta (User.Id, "yim", Wp_Slash (User.User_ICQ));
            -- end if;

            if not Empty (-User.Prop.User_Description) then
               Update_User_Meta (User.Id, "description",
                                 Wp_Slash (-User.Prop.User_Description));
            end if;

            -- if Isset (User.User_Idmode) then
            --    declare
            --       Idmode : String := User.User_Idmode;
            --       Id     : Ustring;
            --    begin
            --       if "nickname" = Idmode then
            --          Id := User.User_Nickname;
            --       end if;
            --       if "login" = Idmode then
            --          Id := User.User_Login;
            --       end if;
            --       if "firstname" = Idmode then
            --          Id := User.User_Firstname;
            --       end if;
            --       if "lastname" = Idmode then
            --          Id := User.User_Lastname;
            --       end if;
            --       if "namefl" = Idmode then
            --          Id := User.User_Firstname & " " & User.User_Lastname;
            --       end if;
            --       if "namelf" = Idmode then
            --          Id := User.User_Lastname & " " & User.User_Firstname;
            --       end if;
            --       if not Idmode then
            --          Id := User.User_Nickname;
            --       end if;

            --       WpDB.Update (WpDB.Users,
            --                    To_Array (List => (1 =>
            --                      Build ("display_name", Id))),
            --                    To_Array (List => (1 =>
            --                      Build ("ID", User.Id)))
            --                   );
            --    end;
            -- end if;

            -- FIXME: RESET_CAPS is temporary code to reset roles and caps if flag
            -- is set.
            declare
               Caps : constant Array_Type :=
                 Get_User_Meta (User.Id, (-WpDB.Prefix) & "capabilities");
            begin
               if Caps.Is_Empty or else RESET_CAPS then
                  declare
                     Level : constant Integer :=
                       Get_User_Meta (User.Id,
                                      (-WpDB.Prefix) & "user_level", True);

                     Role : constant String := Translate_Level_To_Role (Level);
                  begin
                     Update_User_Meta (User.Id,
                                       (-WpDB.Prefix) & "capabilities",
                                       To_Array (List => (1 =>
                                         Build (Role, True))));
                  end;
               end if;
            end;
         end loop;
      end;

      declare
         Old_User_Fields : constant List_Type :=
           ["user_firstname", "user_lastname", "user_icq", "user_aim",
            "user_msn", "user_yim", "user_idmode", "user_ip", "user_domain",
            "user_browser", "user_description", "user_nickname", "user_level"];
      begin
         WpDB.Hide_Errors;
         for Old of Old_User_Fields loop
            WpDB.Query ("ALTER TABLE " & Users_2 & " DROP " & Statement_Type (Old));
         end loop;
         WpDB.Show_Errors;
      end;

      -- Populate comment_count field of posts table.
      declare
         Comments_2 : constant Statement_Type := Statement_Type (-WpDB.Comments);

         Comments : constant Comments_List :=
           WpDB.Get_Results (
             "SELECT comment_post_ID, COUNT(*) as c FROM " & Comments_2 &
             " WHERE comment_approved = '1' GROUP BY comment_post_ID");
      begin
         if True then -- Is_Array (Comments) then
            for Comment of Comments loop
               WpDB.Update (
                 -WpDB.Posts,
                 To_Array (List => (1 =>
                   Build ("comment_count", -Comment.C))),
                 To_Array (List => (1 =>
                   Build ("ID", Integer (Comment.Comment_Post_Id)))));
            end loop;
         end if;
      end;

      --
      -- Some alpha versions used a post status of object instead of attachment
      -- and put the mime type in post_type instead of post_mime_type.
      --
      if Wp_Current_DB_Version > 2541 and Wp_Current_DB_Version <= 3091 then
         declare
            Posts_2 : constant Statement_Type := Statement_Type (-WpDB.Posts);

            Objects : constant Post_Array :=
              WpDB.Get_Results (
                "SELECT ID, post_type FROM " & Posts_2 &
                " WHERE post_status = 'object'");
         begin
            for Object of Objects loop
               WpDB.Update (
                 -WpDB.Posts,
                 To_Array (List => (
                   Build ("post_status",    "attachment"),
                   Build ("post_mime_type", -Object.Post_Type),
                   Build ("post_type",      "")
                 )),
                 To_Array (List => (1 =>
                   Build ("ID", Integer (Object.Id))))
               );

               declare
                  Meta : constant Array_Type :=
                    Get_Post_Meta (Object.Id, "imagedata", True);
               begin
                  if not Empty (Meta, "file") then
                     Update_Attached_File (Object.Id, Get_As_String (Meta, "file"));
                  end if;
               end;
            end loop;
         end;
      end if;
   end Upgrade_160;

   -----------------
   -- Upgrade_210 --
   -----------------

   procedure Upgrade_210
   is null;
--         global wp_current_db_version, WpDB;

--         if ( wp_current_db_version < 3506 ) then
--                 -- Update status and type.
--                 posts = WpDB.get_results( "SELECT ID, post_status FROM WpDB.posts" );

--                 if ( ! empty( posts ) ) then
--                         foreach ( posts as post ) then
--                                 status = post.post_status;
--                                 type   = "post";

--                                 if ( "static" === status ) then
--                                         status = "publish";
--                                         type   = "page";
--                                 end; elseif ( "attachment" === status ) then
--                                         status = "inherit";
--                                         type   = "attachment";
--                                 end;

--                                 WpDB.query( WpDB.prepare( "UPDATE WpDB.posts SET post_status = %s, post_type = %s WHERE ID = %d", status, type, post.ID ) );
--                         end;
--                 end;
--         end;

--         if ( wp_current_db_version < 3845 ) then
--                 populate_roles_210();
--         end;

--         if ( wp_current_db_version < 3531 ) then
--                 -- Give future posts a post_status of future.
--                 now = gmdate( "Y-m-d H:i:59" );
--                 WpDB.query( "UPDATE WpDB.posts SET post_status = "future" WHERE post_status = "publish" AND post_date_gmt > "now"" );

--                 posts = WpDB.get_results( "SELECT ID, post_date FROM WpDB.posts WHERE post_status ="future"" );
--                 if ( ! empty( posts ) ) then
--                         foreach ( posts as post ) then
--                                 wp_schedule_single_event( mysql2date( "U", post.post_date, false ), "publish_future_post", array( post.ID ) );
--                         end;
--                 end;
--         end;
-- end;

   -----------------
   -- Upgrade_230 --
   -----------------

   procedure Upgrade_230
   is null;
--         global wp_current_db_version, WpDB;

--         if ( wp_current_db_version < 5200 ) then
--                 populate_roles_230();
--         end;

--         -- Convert categories to terms.
--         tt_ids     = array();
--         have_tags  = false;
--         categories = WpDB.get_results( "SELECT-- FROM WpDB.categories ORDER BY cat_ID" );
--         foreach ( categories as category ) then
--                 term_id     = (int) category.cat_ID;
--                 name        = category.cat_name;
--                 description = category.category_description;
--                 slug        = category.category_nicename;
--                 parent      = category.category_parent;
--                 term_group  = 0;

--                 -- Associate terms with the same slug in a term group and make slugs unique.
--                 exists = WpDB.get_results( WpDB.prepare( "SELECT term_id, term_group FROM WpDB.terms WHERE slug = %s", slug ) );
--                 if ( exists ) then
--                         term_group = exists[0].term_group;
--                         id         = exists[0].term_id;
--                         num        = 2;
--                         do then
--                                 alt_slug = slug . "-num";
--                                 num++;
--                                 slug_check = WpDB.get_var( WpDB.prepare( "SELECT slug FROM WpDB.terms WHERE slug = %s", alt_slug ) );
--                         end; while ( slug_check );

--                         slug = alt_slug;

--                         if ( empty( term_group ) ) then
--                                 term_group = WpDB.get_var( "SELECT MAX(term_group) FROM WpDB.terms GROUP BY term_group" ) + 1;
--                                 WpDB.query( WpDB.prepare( "UPDATE WpDB.terms SET term_group = %d WHERE term_id = %d", term_group, id ) );
--                         end;
--                 end;

--                 WpDB.query(
--                         WpDB.prepare(
--                                 "INSERT INTO WpDB.terms (term_id, name, slug, term_group) VALUES
--                 (%d, %s, %s, %d)",
--                                 term_id,
--                                 name,
--                                 slug,
--                                 term_group
--                         )
--                 );

--                 count = 0;
--                 if ( ! empty( category.category_count ) ) then
--                         count    = (int) category.category_count;
--                         taxonomy = "category";
--                         WpDB.query( WpDB.prepare( "INSERT INTO WpDB.term_taxonomy (term_id, taxonomy, description, parent, count) VALUES ( %d, %s, %s, %d, %d)", term_id, taxonomy, description, parent, count ) );
--                         tt_ids[ term_id ][ taxonomy ] = (int) WpDB.insert_id;
--                 end;

--                 if ( ! empty( category.link_count ) ) then
--                         count    = (int) category.link_count;
--                         taxonomy = "link_category";
--                         WpDB.query( WpDB.prepare( "INSERT INTO WpDB.term_taxonomy (term_id, taxonomy, description, parent, count) VALUES ( %d, %s, %s, %d, %d)", term_id, taxonomy, description, parent, count ) );
--                         tt_ids[ term_id ][ taxonomy ] = (int) WpDB.insert_id;
--                 end;

--                 if ( ! empty( category.tag_count ) ) then
--                         have_tags = true;
--                         count     = (int) category.tag_count;
--                         taxonomy  = "post_tag";
--                         WpDB.insert( WpDB.term_taxonomy, compact( "term_id", "taxonomy", "description", "parent", "count" ) );
--                         tt_ids[ term_id ][ taxonomy ] = (int) WpDB.insert_id;
--                 end;

--                 if ( empty( count ) ) then
--                         count    = 0;
--                         taxonomy = "category";
--                         WpDB.insert( WpDB.term_taxonomy, compact( "term_id", "taxonomy", "description", "parent", "count" ) );
--                         tt_ids[ term_id ][ taxonomy ] = (int) WpDB.insert_id;
--                 end;
--         end;

--         select = "post_id, category_id";
--         if ( have_tags ) then
--                 select .= ", rel_type";
--         end;

--         posts = WpDB.get_results( "SELECT select FROM WpDB.post2cat GROUP BY post_id, category_id" );
--         foreach ( posts as post ) then
--                 post_id  = (int) post.post_id;
--                 term_id  = (int) post.category_id;
--                 taxonomy = "category";
--                 if ( ! empty( post.rel_type ) && "tag" === post.rel_type ) then
--                         taxonomy = "tag";
--                 end;
--                 tt_id = tt_ids[ term_id ][ taxonomy ];
--                 if ( empty( tt_id ) ) then
--                         continue;
--                 end;

--                 WpDB.insert(
--                         WpDB.term_relationships,
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
--                 link_cats        = WpDB.get_results( "SELECT cat_id, cat_name FROM " . WpDB.prefix . "linkcategories" );
--                 foreach ( link_cats as category ) then
--                         cat_id     = (int) category.cat_id;
--                         term_id    = 0;
--                         name       = wp_slash( category.cat_name );
--                         slug       = sanitize_title( name );
--                         term_group = 0;

--                         -- Associate terms with the same slug in a term group and make slugs unique.
--                         exists = WpDB.get_results( WpDB.prepare( "SELECT term_id, term_group FROM WpDB.terms WHERE slug = %s", slug ) );
--                         if ( exists ) then
--                                 term_group = exists[0].term_group;
--                                 term_id    = exists[0].term_id;
--                         end;

--                         if ( empty( term_id ) ) then
--                                 WpDB.insert( WpDB.terms, compact( "name", "slug", "term_group" ) );
--                                 term_id = (int) WpDB.insert_id;
--                         end;

--                         link_cat_id_map[ cat_id ] = term_id;
--                         default_link_cat           = term_id;

--                         WpDB.insert(
--                                 WpDB.term_taxonomy,
--                                 array(
--                                         "term_id"     => term_id,
--                                         "taxonomy"    => "link_category",
--                                         "description" => "",
--                                         "parent"      => 0,
--                                         "count"       => 0,
--                                 )
--                         );
--                         tt_ids[ term_id ] = (int) WpDB.insert_id;
--                 end;

--                 -- Associate links to categories.
--                 links = WpDB.get_results( "SELECT link_id, link_category FROM WpDB.links" );
--                 if ( ! empty( links ) ) then
--                         foreach ( links as link ) then
--                                 if ( 0 == link.link_category ) then
--                                         continue;
--                                 end;
--                                 if ( ! isset( link_cat_id_map[ link.link_category ] ) ) then
--                                         continue;
--                                 end;
--                                 term_id = link_cat_id_map[ link.link_category ];
--                                 tt_id   = tt_ids[ term_id ];
--                                 if ( empty( tt_id ) ) then
--                                         continue;
--                                 end;

--                                 WpDB.insert(
--                                         WpDB.term_relationships,
--                                         array(
--                                                 "object_id"        => link.link_id,
--                                                 "term_taxonomy_id" => tt_id,
--                                         )
--                                 );
--                         end;
--                 end;

--                 -- Set default to the last category we grabbed during the upgrade loop.
--                 update_option( "default_link_category", default_link_cat );
--         end; else then
--                 links = WpDB.get_results( "SELECT link_id, category_id FROM WpDB.link2cat GROUP BY link_id, category_id" );
--                 foreach ( links as link ) then
--                         link_id  = (int) link.link_id;
--                         term_id  = (int) link.category_id;
--                         taxonomy = "link_category";
--                         tt_id    = tt_ids[ term_id ][ taxonomy ];
--                         if ( empty( tt_id ) ) then
--                                 continue;
--                         end;
--                         WpDB.insert(
--                                 WpDB.term_relationships,
--                                 array(
--                                         "object_id"        => link_id,
--                                         "term_taxonomy_id" => tt_id,
--                                 )
--                         );
--                 end;
--         end;

--         if ( wp_current_db_version < 4772 ) then
--                 -- Obsolete linkcategories table.
--                 WpDB.query( "DROP TABLE IF EXISTS " . WpDB.prefix . "linkcategories" );
--         end;

--         -- Recalculate all counts.
--         terms = WpDB.get_results( "SELECT term_taxonomy_id, taxonomy FROM WpDB.term_taxonomy" );
--         foreach ( (array) terms as term ) then
--                 if ( "post_tag" === term.taxonomy || "category" === term.taxonomy ) then
--                         count = WpDB.get_var( WpDB.prepare( "SELECT COUNT(*) FROM WpDB.term_relationships, WpDB.posts WHERE WpDB.posts.ID = WpDB.term_relationships.object_id AND post_status = "publish" AND post_type = "post" AND term_taxonomy_id = %d", term.term_taxonomy_id ) );
--                 end; else then
--                         count = WpDB.get_var( WpDB.prepare( "SELECT COUNT(*) FROM WpDB.term_relationships WHERE term_taxonomy_id = %d", term.term_taxonomy_id ) );
--                 end;
--                 WpDB.update( WpDB.term_taxonomy, array( "count" => count ), array( "term_taxonomy_id" => term.term_taxonomy_id ) );
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
        ["option_can_override", "option_type", "option_width",
         "option_height", "option_description", "option_admin_level"];
   begin
      WpDB.Hide_Errors;
      for Old of Old_Options_Fields loop
         WpDB.Query (Statement_Type (
           "ALTER TABLE " & (-WpDB.Options) & " DROP " & Old));
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
--         global wp_current_db_version, WpDB;

--         if ( wp_current_db_version < 10360 ) then
--                 populate_roles_280();
--         end;
--         if ( is_multisite() ) then
--                 start = 0;
--                 while ( rows = WpDB.get_results( "SELECT option_name, option_value FROM WpDB.options ORDER BY option_id LIMIT start, 20" ) ) then
--                         foreach ( rows as row ) then
--                                 value = maybe_unserialize( row.option_value );
--                                 if ( value === row.option_value ) then
--                                         value = stripslashes( value );
--                                 end;
--                                 if ( value !== row.option_value ) then
--                                         update_option( row.option_name, value );
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
--         global wp_current_db_version, WpDB;

--         if ( wp_current_db_version < 15093 ) then
--                 populate_roles_300();
--         end;

--         if ( wp_current_db_version < 14139 && is_multisite() && is_main_site() && ! defined( "MULTISITE" ) && get_site_option( "siteurl" ) === false ) then
--                 add_site_option( "siteurl", "" );
--         end;

--         -- 3.0 screen options key name changes.
--         if ( wp_should_upgrade_global_tables() ) then
--                 sql    = "DELETE FROM WpDB.usermeta
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
--                 prefix = WpDB.esc_like( WpDB.base_prefix );
--                 WpDB.query(
--                         WpDB.prepare(
--                                 sql,
--                                 prefix . "%" . WpDB.esc_like( "meta-box-hidden" ) . "%",
--                                 prefix . "%" . WpDB.esc_like( "closedpostboxes" ) . "%",
--                                 prefix . "%" . WpDB.esc_like( "manage-" ) . "%" . WpDB.esc_like( "-columns-hidden" ) . "%",
--                                 prefix . "%" . WpDB.esc_like( "meta-box-order" ) . "%",
--                                 prefix . "%" . WpDB.esc_like( "metaboxorder" ) . "%",
--                                 prefix . "%" . WpDB.esc_like( "screen_layout" ) . "%"
--                         )
--                 );
--         end;

-- end;

   -----------------
   -- Upgrade_330 --
   -----------------

   procedure Upgrade_330
   is null;
--         global wp_current_db_version, WpDB, wp_registered_widgets, sidebars_widgets;

--         if ( wp_current_db_version < 19061 && wp_should_upgrade_global_tables() ) then
--                 WpDB.query( "DELETE FROM WpDB.usermeta WHERE meta_key IN ("show_admin_bar_admin", "plugins_last_view")" );
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
--         global wp_current_db_version, WpDB;

--         if ( wp_current_db_version < 22006 && WpDB.get_var( "SELECT link_id FROM WpDB.links LIMIT 1" ) ) then
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
--                         WpDB.query( "DELETE FROM WpDB.usermeta WHERE meta_key IN ("meta_keys")" );
--                 end;
--         end;

--         if ( wp_current_db_version < 22422 ) then
--                 term = get_term_by( "slug", "post-format-standard", "post_format" );
--                 if ( term ) then
--                         wp_delete_term( term.term_id, "post_format" );
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
         Deactivate_Plugins (["mp6/mp6.php"], True); -- array(
      end if;
   end Upgrade_380;

   -----------------
   -- Upgrade_400 --
   -----------------

   procedure Upgrade_400
   is
      use Php.Arrays;
      use Constants;
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
      use Php.Arrays;
      use Constants;
      use Globals;
      use UStrings;
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
--         global WpDB;

--         content_length = WpDB.get_col_length( WpDB.comments, "comment_content" );

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

--         comments = WpDB.get_results(
--                 "SELECT `comment_ID` FROM `thenWpDB.commentsend;`
--                         WHERE `comment_date_gmt` > "2015-04-26"
--                         AND LENGTH( `comment_content` ) >= thenallowed_lengthend;
--                         AND ( `comment_content` LIKE "%<%" OR `comment_content` LIKE "%>%" )"
--         );

--         foreach ( comments as comment ) then
--                 wp_delete_comment( comment.comment_ID, true );
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
         Wp_Schedule_Single_Event (Php.Misc.Time + (1 * Constants.MINUTE_IN_SECONDS),
                                   "wp_update_comment_type_batch");
      end if;
   end Upgrade_550;

   -----------------
   -- Upgrade_560 --
   -----------------

   procedure Upgrade_560
   is null;
--         global wp_current_db_version, WpDB;

--         if ( wp_current_db_version < 49572 ) then
--                 /*
--                 -- Clean up the `post_category` column removed from schema in version 2.8.0.
--                 -- Its presence may conflict with `WP_Post::__get()`.
--                 --
--                 post_category_exists = WpDB.get_var( "SHOW COLUMNS FROM WpDB.posts LIKE "post_category"" );
--                 if ( ! is_null( post_category_exists ) ) then
--                         WpDB.query( "ALTER TABLE WpDB.posts DROP COLUMN `post_category`" );
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
--                 results = WpDB.get_results(
--                         WpDB.prepare(
--                                 "SELECT 1 FROM thenWpDB.usermetaend; WHERE meta_key = %s LIMIT 1",
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
      use Class_WpDB;
      use Inc_Formatting;
      use Inc_Functions;

      Options : constant Statement_Type := Statement_Type (-Globals.WpDB.Options);
   begin
      if "home" = Setting and then Constants.WP_HOME_DEF then
         return From_String (Un_Trailing_Slash_It (Constants.WP_HOME));
      end if;

      if "siteurl" = Setting and then Constants.WP_SITEURL_DEF then
         return From_String (Un_Trailing_Slash_It (Constants.WP_SITEURL));
      end if;

      declare
         Option : constant String :=
           Globals.WpDB.Get_Var (
             Globals.WpDB.Prepare (
               "SELECT option_value FROM " & Options &
               " WHERE option_name = %s", [Setting]));
      begin
         if "home" = Setting and then Option = "" then -- not
            return X_Get_Option ("siteurl");
         end if;

         if
           In_List (Setting, ["siteurl", "home", "category_base", "tag_base"], True)
         then
            return Maybe_Unserialize (Un_Trailing_Slash_It (Option));
         end if;

         return Maybe_Unserialize (Option);
      end;
   end X_Get_Option;

   -------------
   -- Deslash --
   -------------

   function Deslash (Content : String)
                     return String
   is
      use Php.Preg;

      -- Note: \\\ inside a regex denotes a single backslash.

      --
      -- Replace one or more backslashes followed by a single quote with
      -- a single quote.
      --
      Content_2 : constant String := Preg_Replace ("/\\\+'/", "'", Content);

      --
      -- Replace one or more backslashes followed by a double quote with
      -- a double quote.
      --
      Content_3 : constant String := Preg_Replace ("/\\\+'/", "'", Content_2);

      -- Replace one or more backslashes with one backslash.
      Content_4 : constant String := Preg_Replace ("/\\\+/", "\\", Content_3);
   begin
      return Content_4;
   end Deslash;

   --------------
   -- DB_Delta --
   --------------

   function DB_Delta (Queries : String  := "";
                      Execute : Boolean := True)
                      return Array_Type
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Misc;
      use Php.Preg;
      use Php.Strings;
      use Globals;
      use UStrings;
      use Wp_Common;
      use Adi_Schemas;
      use Class_WpDB;
      use Inc_Plugins;

      List : constant List_Type :=
        ["", "all", "blog", "global", "ms_global"];

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
         if Preg_Match ("|CREATE TABLE ([^ ]*)|", Qry, Matches) /= 0 then
            declare
               M : constant String := Matches (1); -- [1]
            begin
               Set (C_Queries,  Trim (M, "`"), From_String (Qry));
               Set (For_Update, M,             From_String ("Created table " & M));
            end;

         elsif Preg_Match ("|CREATE DATABASE ([^ ]*)|", Qry, Matches) /= 0 then
            Array_Unshift (C_Queries, Qry);

         elsif Preg_Match ("|INSERT INTO ([^ ]*)|", Qry, Matches) /= 0 then
            I_Queries.Append (From_String (Qry));

         elsif Preg_Match ("|UPDATE ([^ ]*)|", Qry, Matches) /= 0 then
            I_Queries.Append (From_String (Qry));

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
           ["tinytext", "text", "mediumtext", "longtext"];

         Blob_Fields : constant List_Type :=
           ["tinyblob", "blob", "mediumblob", "longblob"];

         Int_Fields  : constant List_Type :=
           ["tinyint", "smallint", "mediumint",
            "int", "integer", "bigint"];

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
                        Qryline : constant String := Trim (Match_2 (1));

                        -- Separate field lines into an array.
                        Flds : constant List_Type := Explode ("\n", Qryline);
                     begin
                        -- For every field line specified in the query.
                        for Fld_0 of Flds loop
                           declare
                              Fld : constant String := Trim (Fld_0, " \t\n\r\0\x0B,");
                              -- Default trim characters, plus ",".
                              Fvals : List_Type;
                           begin
                              -- Extract the field name.
                              Preg_Match ("|^([^ ]*)|", Fld, Fvals);
                              declare
                                 Fieldname : constant String :=
                                   Trim (Fvals (1), "`");

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
                                                Index_Column : UString :=
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
                                    Fieldtype : constant String := Matches (1);

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
                                            Matches (1);
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

                                    Index_String  : UString;
                                    Index_Columns : UString;
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
                             "ALTER TABLE " & Table & " ADD " & Index));

                           For_Update.Append (From_String (
                             "Added " & Index & " " & Table & " " & Index));
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

   ------------------------------------
   -- Make_Site_Theme_From_Oldschool --
   ------------------------------------

   function Make_Site_Theme_From_Oldschool (Theme_Name : String;
                                            Template   : String)
                                            return Boolean
   is
      use Php.Files;
      use Php.Preg;
      use Php.Strings;
      use Constants;
      use Globals;
      use UStrings;
      use Adi_Files;

      Home_Path : constant String := Get_Home_Path;
      Site_Dir  : constant String := -(WP_CONTENT_DIR & "/themes/template");
   begin
      if not File_Exists (Home_Path & "/index.php") then
         return False;
      end if;

      --
      -- Copy files from the old locations to the site theme.
      -- TODO: This does not copy arbitrary include dependencies. Only the standard
      -- WP files are copied.
      --
      declare
         Files : constant Array_Type := To_Array (List => (
           Build ("index.php",             "index.php"),
           Build ("wp-layout.css",         "style.css"),
           Build ("wp-comments.php",       "comments.php"),
           Build ("wp-comments-popup.php", "comments-popup.php")
         ));
      begin
         for A in Files.Iterate loop
            declare
               Oldfile : constant String := Key (A);
               Newfile : constant String := As_String (Element (A));

               Oldpath : constant String :=
                 (if "index.php" = Oldfile then Home_Path
                  else ABSPATH);
            begin
               -- Check to make sure it's not a new index.
               if "index.php" = Oldfile then
                  declare
                     Index : constant String :=
                       Implode ("", File (Oldpath & "/" & Oldfile));
                  begin
                     if Strpos (Index, "WP_USE_THEMES") /= 0 then
                        if
                          not Copy (-(WP_CONTENT_DIR & "/themes/" &
                                    WP_DEFAULT_THEME & "/index.php"),
                                    Site_Dir & "/" & Newfile)
                        then
                           return False;
                        end if;

                        -- Don't copy anything.
                        raise Program_Error with "do not know how to goto continue";
--                      goto Continue;
                     end if;
                  end;
               end if;

               if
                 not Copy (Oldpath & "/" & Oldfile,
                           Site_Dir & "/" & Newfile)
               then
                  return False;
               end if;

               Chmod (Site_Dir & "/" & Newfile, 8#777#);

               -- Update the blog header include in each file.
               declare
                  Lines : constant List_Type :=
                    Explode ("\n", Implode ("", File (Site_Dir & "/" & Newfile)));
               begin
                  if not Lines.Is_Empty then
                     declare
                        F : File_Type := Fopen (Site_Dir & "/" & Newfile, "w");
                     begin
                        for L of Lines loop
                           declare
                              Line : constant String := L;

                              Line_2 : String :=
                                (if Preg_Match ("/require.*wp-blog-header/", Line)
                                 then "//" & Line
                                 else Line);

                              -- Update stylesheet references.
                              Line_3 : constant String :=
                                Str_Replace (
                                  "<?php __get_option( ""siteurl"") ?>" &
                                  "/wp-layout.css",
                                  "<?php bloginfo( ""stylesheet_url"" ) ?>", Line_2);

                              -- Update comments template inclusion.
                              Line_4 : constant String :=
                                Str_Replace (
                                  "<?php include(ABSPATH . ""wp-comments.php""); ?>",
                                  "<?php comments_template(); ?>", Line_3);
                           begin
                              Fwrite (F, Line_4 & NL);
                           end;
                           << Continue >>
                        end loop;
                        Fclose (F);
                     end;
                  end if;
               end;
            end;
         end loop;
      end;

      -- Add a theme header.
      declare
         Header : constant String :=
           "/*" & NL & "Theme Name: " & Theme_Name & NL & "Theme URI: " &
           As_String (X_Get_Option ("siteurl")) & NL &
           "Description: A theme automatically created by the update." & NL &
           "Version: 1.0" & NL & "Author: Moi" & NL & "*/" & NL;

         Stylelines : constant String :=
           File_Get_Contents (Site_Dir & "/style.css");
      begin
         if Stylelines /= "" then
            declare
               F : File_Type := Fopen (Site_Dir & "/style.css", "w");
            begin
               Fwrite (F, Header);
               Fwrite (F, Stylelines);
               Fclose (F);
            end;
         end if;
      end;
      return True;
   end Make_Site_Theme_From_Oldschool;

   ----------------------------------
   -- Make_Site_Theme_From_Default --
   ----------------------------------

   function Make_Site_Theme_From_Default (Theme_Name : String;
                                          Template   : String)
                                          return Boolean
   is
      use Php.Files;
      use Php.Strings;
      use Constants;
      use Globals;
      use UStrings;

      Site_Dir : constant String :=
        (-WP_CONTENT_DIR) & "/themes/template";

      Default_Dir : constant String :=
        -(WP_CONTENT_DIR & "/themes/" & WP_DEFAULT_THEME);
   begin

      -- Copy files from the default theme to the site theme.
      -- files = array( "index.php", "comments.php", "comments-popup.php",
      -- "footer.php", "header.php", "sidebar.php", "style.css" );
      declare
         Theme_Dir : Dir_Handle := Opendir (Default_Dir); -- @
      begin
         if Theme_Dir.Is_Good then
            loop
            -- while ( ( theme_file = readdir( theme_dir ) ) !== false ) then
               declare
                  Theme_File : constant String := Readdir (Theme_Dir);
               begin
                  exit when Theme_File = "";

                  if Is_Dir (Default_Dir & "/" & Theme_File) then
                     goto Continue;
                  end if;

                  if
                    not Copy (Default_Dir & "/" & Theme_File,
                              Site_Dir & "/" & Theme_File)
                  then
                     return False; -- false added
                  end if;
                  Chmod (Site_Dir & "/" & Theme_File, 8#777#);
               end;
               << Continue >>
            end loop;

            Closedir (Theme_Dir);
         end if;
      end;

      -- Rewrite the theme header.
      declare
         Stylelines : constant List_Type :=
           Explode ("\n", Implode ("", File (Site_Dir & "/style.css")));
      begin
         if not Stylelines.Is_Empty then
            declare
               F : File_Type := Fopen (Site_Dir & "/style.css", "w");
            begin
               for L of Stylelines loop
                  declare
                     Line : constant String := L;

                     Line_2 : constant String :=
                       (if Strpos (Line, "Theme Name:") /= 0
                          then "Theme Name: " & Theme_Name
                        elsif Strpos (Line, "Theme URI:") /= 0
                          then "Theme URI: " & As_String (X_Get_Option ("url"))
                        elsif Strpos (Line, "Description:") /= 0
                          then "Description: Your theme."
                        elsif Strpos (Line, "Version:") /= 0
                          then "Version: 1"
                        elsif Strpos (Line, "Author:") /= 0
                          then "Author: You"
                        else "");
                  begin
                     Fwrite (F, Line_2 & NL);
                  end;
               end loop;
               Fclose (F);
            end;
         end if;
      end;

      -- Copy the images.
      Umask (0);
      if not Mkdir (Site_Dir & "/images", 8#777#) then
         return False;
      end if;

      declare
         Images_Dir : Dir_Handle :=
           Opendir (Default_Dir & "/images"); -- @
      begin
         if Images_Dir.Is_Good then
            loop
               -- while ( ( image = readdir( images_dir ) ) !== false ) then
               declare
                  Image : constant String :=
                    Readdir (Images_Dir);
               begin
                  if Is_Dir (Default_Dir & "/images/" & Image) then
                     goto Continue_2;
                  end if;

                  if
                    not Copy (Default_Dir & "/images/" & Image,
                              Site_Dir & "/images/" & Image)
                  then
                     return False; -- false added
                  end if;
                  Chmod (Site_Dir & "/images/" & Image, 8#777#);
               end;
               << Continue_2 >>
            end loop;

            Closedir (Images_Dir);
         end if;
      end;
      return True; -- added
   end Make_Site_Theme_From_Default;

   ---------------------
   -- Make_Site_Theme --
   ---------------------

   function Make_Site_Theme
            return String
   is
      use Php.Files;
      use UStrings;
      use Inc_Formatting;
      use Inc_Options;

      -- Name the theme after the blog.
      Theme_Name : constant String := As_String (X_Get_Option ("blogname"));
      Template   : constant String := Sanitize_Title (Theme_Name);
      Site_Dir   : constant String := (-Globals.WP_CONTENT_DIR) & "/themes/template";
   begin
      -- If the theme already exists, nothing to do.
      if Is_Dir (Site_Dir) then
         return ""; -- False;
      end if;

      -- We must be able to write to the themes dir.
      if not Is_Writable ((-Globals.WP_CONTENT_DIR) & "/themes") then
         return ""; -- False;
      end if;

      Umask (0);
      if not Mkdir (Site_Dir, 8#777#) then
         return ""; -- False;
      end if;

      if File_Exists (Constants.ABSPATH & "wp-layout.css") then
         if not Make_Site_Theme_From_Oldschool (Theme_Name, Template) then
            -- TODO: rm -rf the site theme directory.
            return ""; -- False;
         end if;
      else
         if not Make_Site_Theme_From_Default (Theme_Name, Template) then
            -- TODO: rm -rf the site theme directory.
            return ""; -- False;
         end if;
      end if;

      -- Make the new site theme active.
      declare
         Current_Template : constant String :=
           As_String (X_Get_Option ("template"));
      begin
         if Constants.WP_DEFAULT_THEME = Current_Template then
            Update_Option ("template",   From_String (Template));
            Update_Option ("stylesheet", From_String (Template));
         end if;
      end;
      return Template;
   end Make_Site_Theme;

   ---------------------
   -- Make_Site_Theme --
   ---------------------

   procedure Make_Site_Theme
   is
      Unused : constant String := Make_Site_Theme;
   begin
      null;
   end Make_Site_Theme;

   -----------------------------
   -- Translate_Level_To_Role --
   -----------------------------

   function Translate_Level_To_Role (Level : Integer)
                                     return String
   is
   begin
      case Level is

      when 8 .. 10 =>  return "administrator";
      when 5 .. 7  =>  return "editor";
      when 2 .. 4  =>  return "author";
      when 1       =>  return "contributor";
      when 0       =>  return "subscriber";
      when others  =>  return "subscriber";

      end case;
   end Translate_Level_To_Role;

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
      use Php.Files;
      use Inc_Options;

      Plugins : constant List_Type := Empty_List;  -- ???
--      As_List (X_Get_Option ("active_plugins"));
   begin
      for Plugin of Plugins loop -- (array)
         if "widgets.php" = Basename (Plugin) then
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
   begin
      if
        Wp_Current_DB_Version >= 22006 and then
        Get_Option ("link_manager_enabled") and then
        "" = WpDB.Get_Var ("SELECT link_id FROM WpDB.links LIMIT 1") -- not
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

      Options     : constant Statement_Type := Statement_Type (-WpDB.Options);
      Signups     : constant Statement_Type := Statement_Type (-WpDB.Signups);
      Blogs       : constant Statement_Type := Statement_Type (-WpDB.Blogs);
      Usermeta    : constant Statement_Type := Statement_Type (-WpDB.Usermeta);
      Terms       : constant Statement_Type := Statement_Type (-WpDB.Terms);
      Commentmeta : constant Statement_Type := Statement_Type (-WpDB.Commentmeta);
      Postmeta    : constant Statement_Type := Statement_Type (-WpDB.Postmeta);
      Termmeta    : constant Statement_Type := Statement_Type (-WpDB.Termmeta);
      Posts       : constant Statement_Type := Statement_Type (-WpDB.Posts);
   begin
      -- Upgrade versions prior to 2.9.
      if Wp_Current_DB_Version < 11557 then
         -- Delete duplicate options. Keep the option with the highest option_id.
         WpDB.Query ("DELETE o1 FROM " & Options & " AS o1 JOIN " & Options &
                     " AS o2 USING (`option_name`) WHERE o2.option_id > o1.option_id");

         -- Drop the old primary key and add the new.
         WpDB.Query ("ALTER TABLE " & Options &
                     " DROP PRIMARY KEY, ADD PRIMARY KEY(option_id)");

         -- Drop the old option_name index. dbDelta() Doesn't do the drop.
         WpDB.Query ("ALTER TABLE " & Options & " DROP INDEX option_name");
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
            WpDB.Query
              ("ALTER TABLE " & Signups &
               " ADD signup_id BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST");
            WpDB.Query ("ALTER TABLE " & Signups & " DROP INDEX domain");
         end if;

         if Wp_Current_DB_Version < 25448 then
            -- Convert archived from enum to tinyint.
            WpDB.Query
              ("ALTER TABLE " & Blogs &
               " CHANGE COLUMN archived archived varchar(1) NOT NULL default '0'");
            WpDB.Query
              ("ALTER TABLE " & Blogs &
               " CHANGE COLUMN archived archived tinyint(2) NOT NULL default 0");
         end if;
      end if;

      -- Upgrade versions prior to 4.2.
      if Wp_Current_DB_Version < 31351 then
         if
           not Is_Multisite and then
           Wp_Should_Upgrade_Global_Tables
         then
            WpDB.Query
              ("ALTER TABLE " & Usermeta &
               " DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         end if;
         WpDB.Query
           ("ALTER TABLE " & Terms &
            " DROP INDEX slug, ADD INDEX slug(slug(191))");
         WpDB.Query
           ("ALTER TABLE " & Terms &
            " DROP INDEX name, ADD INDEX name(name(191))");
         WpDB.Query
           ("ALTER TABLE " & Commentmeta &
            " DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         WpDB.Query
           ("ALTER TABLE " & Postmeta &
            " DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         WpDB.Query
           ("ALTER TABLE " & Posts &
            " DROP INDEX post_name, ADD INDEX post_name(post_name(191))");
      end if;

      -- Upgrade versions prior to 4.4.
      if Wp_Current_DB_Version < 34978 then
         -- If compatible termmeta table is found, use it, but enforce a proper
         -- index and update collation.
         if
           "" /= WpDB.Get_Var ("SHOW TABLES LIKE '" & Termmeta & "'")
         and then
           WpDB.Get_Results (
             "SHOW INDEX FROM " & Termmeta &
             " WHERE Column_name = 'meta_key'") /= Empty_Array
         then
            WpDB.Query
              ("ALTER TABLE " & Termmeta &
               " DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");

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
      use Wp_Common;
      use Inc_Functions;
      use Inc_Plugins;

      -- Assume global tables should be upgraded.
      Should_Upgrade : Boolean := True;
   begin
      -- Return false early if explicitly not upgrading.
      if Constants.DO_NOT_UPGRADE_GLOBAL_TABLES then
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
