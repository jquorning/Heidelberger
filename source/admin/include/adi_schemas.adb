--
-- WordPress Administration Scheme API
--
-- Here we keep the DB structure and option values.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Php.Arrays;
with Php.Lists;
with Php.Misc;
with Php.Strings;
with Php.Types;

with Lists;
with Globals;
with Hb_Common;

with Adi_Upgrade;
with Inc_Class_Wpdb;
with Inc_Class_Wp_Role;
with Inc_Class_Wp_Themes;
with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Plugins;
with Inc_Themes;
with Inc_Versions;

package body Adi_Schemas
is
   use Lists;

   subtype Wp_Role is Inc_Class_Wp_Role.Wp_Role;
   Null_Role : constant Wp_Role := Inc_Class_Wp_Role.Null_Role;
   use type Wp_Role;

   --
   -- Create the roles for WordPress 2.0
   --
   -- @since 2.0.0
   --
   procedure Populate_Roles_160;

   --
   -- Create and modify WordPress roles for WordPress 2.1.
   --
   -- @since 2.1.0
   --
   procedure Populate_Roles_210;

   --
   -- Create and modify WordPress roles for WordPress 2.3.
   --
   -- @since 2.3.0
   --
   procedure Populate_Roles_230;

   --
   -- Create and modify WordPress roles for WordPress 2.5.
   --
   -- @since 2.5.0
   --
   procedure Populate_Roles_250;

   --
   -- Create and modify WordPress roles for WordPress 2.6.
   --
   -- @since 2.6.0
   --
   procedure Populate_Roles_260;

   --
   -- Create and modify WordPress roles for WordPress 2.7.
   --
   -- @since 2.7.0
   --
   procedure Populate_Roles_270;

   --
   -- Create and modify WordPress roles for WordPress 2.8.
   --
   -- @since 2.8.0
   --
   procedure Populate_Roles_280;

   --
   -- Create and modify WordPress roles for WordPress 3.0.
   --
   -- @since 3.0.0
   --
   procedure Populate_Roles_300;

   ----------------------
   -- Wp_Get_DB_Schema --
   ----------------------

   function Wp_Get_DB_Schema (Scope   : String  := "all";
                              Blog_Id : Integer := 0)
                              return String
   is
      use Ada.Strings.Unbounded;
      use Globals;
      use Hb_Common;

      Charset_Collate : constant String :=
        WpDB.Get_Charset_Collate;

      Old_Blog_Id : constant Integer :=
        (if Blog_Id /= 0 and then Blog_Id /= WpDB.Blogid
         then WpDB.Set_Blog_Id (Blog_Id)
         else -1);

      -- Engage multisite if in the middle of turning it on from network.php.
      Is_Multisite : constant Boolean :=
        Inc_Load.Is_Multisite or else ( -- Defined ("WP_INSTALLING_NETWORK") and then
          Globals.WP_INSTALLING_NETWORK);

      --
      -- Indexes have a maximum size of 767 bytes. Historically, we haven't need to
      -- be concerned about that. As of 4.2, however, we moved to utf8mb4, which
      -- uses 4 bytes per character. This means that an index which used to have
      -- room for floor(767/3) = 255 characters, now only has room for
      -- floor(767/4) = 191 characters.
      --
      Max_Index_Length : constant String := "191";

      -- Blog-specific tables.
      Blog_Tables : constant String :=
           "CREATE TABLE " & (-WpDB.Termmeta) & " ( " &
           " meta_id bigint(20) unsigned NOT NULL auto_increment, " &
           " term_id bigint(20) unsigned NOT NULL default '0', " &
           " meta_key varchar(255) default NULL, " &
           " meta_value longtext, " &
           " PRIMARY KEY  (meta_id), " &
           " KEY term_id (term_id), " &
           " KEY meta_key (meta_key(" & Max_Index_Length & ")) " &
           ") " & Charset_Collate & "; " &

           "CREATE TABLE " & (-WpDB.Terms) & " ( " &
           " term_id bigint(20) unsigned NOT NULL auto_increment, " &
           " name varchar(200) NOT NULL default "", " &
           " slug varchar(200) NOT NULL default "", " &
           " term_group bigint(10) NOT NULL default 0, " &
           " PRIMARY KEY  (term_id), " &
           " KEY slug (slug(" & Max_Index_Length & ")), " &
           " KEY name (name(" & Max_Index_Length & ")) " &
           ") " & Charset_Collate & "; " &

           "CREATE TABLE " & (-WpDB.Term_Taxonomy) & " ( " &
           " term_taxonomy_id bigint(20) unsigned NOT NULL auto_increment, " &
           " term_id bigint(20) unsigned NOT NULL default 0, " &
           " taxonomy varchar(32) NOT NULL default "", " &
           " description longtext NOT NULL, " &
           " parent bigint(20) unsigned NOT NULL default 0, " &
           " count bigint(20) NOT NULL default 0, " &
           " PRIMARY KEY  (term_taxonomy_id), " &
           " UNIQUE KEY term_id_taxonomy (term_id,taxonomy), " &
           " KEY taxonomy (taxonomy) " &
           ") " & Charset_Collate & "; " &

           "CREATE TABLE " & (-WpDB.Term_Relationships) & " ( " &
           " object_id bigint(20) unsigned NOT NULL default 0, " &
           " term_taxonomy_id bigint(20) unsigned NOT NULL default 0, " &
           " term_order int(11) NOT NULL default 0, " &
           " PRIMARY KEY  (object_id,term_taxonomy_id), " &
           " KEY term_taxonomy_id (term_taxonomy_id) " &
           ") " & Charset_Collate & "; " &

           "CREATE TABLE " & (-WpDB.Commentmeta) & " ( " &
           "        meta_id bigint(20) unsigned NOT NULL auto_increment, " &
           "        comment_id bigint(20) unsigned NOT NULL default '0', " &
           "        meta_key varchar(255) default NULL, " &
           "        meta_value longtext, " &
           "        PRIMARY KEY  (meta_id), " &
           "        KEY comment_id (comment_id), " &
           "        KEY meta_key (meta_key(" & Max_Index_Length & ")) " &
           ") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Comments) & " ( " &
"        comment_ID bigint(20) unsigned NOT NULL auto_increment, " &
"        comment_post_ID bigint(20) unsigned NOT NULL default '0', " &
"        comment_author tinytext NOT NULL, " &
"        comment_author_email varchar(100) NOT NULL default '', " &
"        comment_author_url varchar(200) NOT NULL default '', " &
"        comment_author_IP varchar(100) NOT NULL default '', " &
"        comment_date datetime NOT NULL default '0000-00-00 00:00:00', " &
"        comment_date_gmt datetime NOT NULL default '0000-00-00 00:00:00', " &
"        comment_content text NOT NULL, " &
"        comment_karma int(11) NOT NULL default '0', " &
"        comment_approved varchar(20) NOT NULL default '1', " &
"        comment_agent varchar(255) NOT NULL default '', " &
"        comment_type varchar(20) NOT NULL default 'comment', " &
"        comment_parent bigint(20) unsigned NOT NULL default '0', " &
"        user_id bigint(20) unsigned NOT NULL default '0', " &
"        PRIMARY KEY  (comment_ID), " &
"        KEY comment_post_ID (comment_post_ID), " &
"        KEY comment_approved_date_gmt (comment_approved,comment_date_gmt), " &
"        KEY comment_date_gmt (comment_date_gmt), " &
"        KEY comment_parent (comment_parent), " &
"        KEY comment_author_email (comment_author_email(10)) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Links) & " ( " &
"        link_id bigint(20) unsigned NOT NULL auto_increment, " &
"        link_url varchar(255) NOT NULL default '', " &
"        link_name varchar(255) NOT NULL default '', " &
"        link_image varchar(255) NOT NULL default '', " &
"        link_target varchar(25) NOT NULL default '', " &
"        link_description varchar(255) NOT NULL default '', " &
"        link_visible varchar(20) NOT NULL default 'Y', " &
"        link_owner bigint(20) unsigned NOT NULL default '1', " &
"        link_rating int(11) NOT NULL default '0', " &
"        link_updated datetime NOT NULL default '0000-00-00 00:00:00', " &
"        link_rel varchar(255) NOT NULL default '', " &
"        link_notes mediumtext NOT NULL, " &
"        link_rss varchar(255) NOT NULL default '', " &
"        PRIMARY KEY  (link_id), " &
"        KEY link_visible (link_visible) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Options) & " ( " &
"        option_id bigint(20) unsigned NOT NULL auto_increment, " &
"        option_name varchar(191) NOT NULL default '', " &
"        option_value longtext NOT NULL, " &
"        autoload varchar(20) NOT NULL default 'yes', " &
"        PRIMARY KEY  (option_id), " &
"        UNIQUE KEY option_name (option_name), " &
"        KEY autoload (autoload) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Postmeta) & " ( " &
"        meta_id bigint(20) unsigned NOT NULL auto_increment, " &
"        post_id bigint(20) unsigned NOT NULL default '0', " &
"        meta_key varchar(255) default NULL, " &
"        meta_value longtext, " &
"        PRIMARY KEY  (meta_id), " &
"        KEY post_id (post_id), " &
"        KEY meta_key (meta_key(" & Max_Index_Length & ")) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Posts) & " ( " &
"        ID bigint(20) unsigned NOT NULL auto_increment, " &
"        post_author bigint(20) unsigned NOT NULL default '0', " &
"        post_date datetime NOT NULL default '0000-00-00 00:00:00', " &
"        post_date_gmt datetime NOT NULL default '0000-00-00 00:00:00', " &
"        post_content longtext NOT NULL, " &
"        post_title text NOT NULL, " &
"        post_excerpt text NOT NULL, " &
"        post_status varchar(20) NOT NULL default 'publish', " &
"        comment_status varchar(20) NOT NULL default 'open', " &
"        ping_status varchar(20) NOT NULL default 'open', " &
"        post_password varchar(255) NOT NULL default '', " &
"        post_name varchar(200) NOT NULL default '', " &
"        to_ping text NOT NULL, " &
"        pinged text NOT NULL, " &
"        post_modified datetime NOT NULL default '0000-00-00 00:00:00', " &
"        post_modified_gmt datetime NOT NULL default '0000-00-00 00:00:00', " &
"        post_content_filtered longtext NOT NULL, " &
"        post_parent bigint(20) unsigned NOT NULL default '0', " &
"        guid varchar(255) NOT NULL default '', " &
"        menu_order int(11) NOT NULL default '0', " &
"        post_type varchar(20) NOT NULL default 'post', " &
"        post_mime_type varchar(100) NOT NULL default '', " &
"        comment_count bigint(20) NOT NULL default '0', " &
"        PRIMARY KEY  (ID), " &
"        KEY post_name (post_name(" & Max_Index_Length & ")), " &
"        KEY type_status_date (post_type,post_status,post_date,ID), " &
"        KEY post_parent (post_parent), " &
"        KEY post_author (post_author) " &
") " & Charset_Collate & ";\n";

      -- Single site users table. The multisite flavor of the users table is
      -- handled below.
      Users_Single_Table : constant String :=
"        CREATE TABLE " & (-WpDB.Users) & " ( " &
"        ID bigint(20) unsigned NOT NULL auto_increment, " &
"        user_login varchar(60) NOT NULL default '', " &
"        user_pass varchar(255) NOT NULL default '', " &
"        user_nicename varchar(50) NOT NULL default '', " &
"        user_email varchar(100) NOT NULL default '', " &
"        user_url varchar(100) NOT NULL default '', " &
"        user_registered datetime NOT NULL default '0000-00-00 00:00:00', " &
"        user_activation_key varchar(255) NOT NULL default '', " &
"        user_status int(11) NOT NULL default '0', " &
"        display_name varchar(250) NOT NULL default '', " &
"        PRIMARY KEY  (ID), " &
"        KEY user_login_key (user_login), " &
"        KEY user_nicename (user_nicename), " &
"        KEY user_email (user_email) " &
") " & Charset_Collate & ";\n";

      -- Multisite users table.
      Users_Multi_Table : constant String :=
"        CREATE TABLE " & (-WpDB.Users) & " ( " &
"        ID bigint(20) unsigned NOT NULL auto_increment, " &
"        user_login varchar(60) NOT NULL default '', " &
"        user_pass varchar(255) NOT NULL default '', " &
"        user_nicename varchar(50) NOT NULL default '', " &
"        user_email varchar(100) NOT NULL default '', " &
"        user_url varchar(100) NOT NULL default '', " &
"        user_registered datetime NOT NULL default '0000-00-00 00:00:00', " &
"        user_activation_key varchar(255) NOT NULL default '', " &
"        user_status int(11) NOT NULL default '0', " &
"        display_name varchar(250) NOT NULL default '', " &
"        spam tinyint(2) NOT NULL default '0', " &
"        deleted tinyint(2) NOT NULL default '0', " &
"        PRIMARY KEY  (ID), " &
"        KEY user_login_key (user_login), " &
"        KEY user_nicename (user_nicename), " &
"        KEY user_email (user_email) " &
") " & Charset_Collate & ";\n";

      -- Usermeta.
      Usermeta_Table : constant String :=
"        CREATE TABLE " & (-WpDB.Usermeta) & " ( " &
"        umeta_id bigint(20) unsigned NOT NULL auto_increment, " &
"        user_id bigint(20) unsigned NOT NULL default '0', " &
"        meta_key varchar(255) default NULL, " &
"        meta_value longtext, " &
"        PRIMARY KEY  (umeta_id), " &
"        KEY user_id (user_id), " &
"        KEY meta_key (meta_key(" & Max_Index_Length & ")) " &
") " & Charset_Collate & ";\n";

      -- Global tables.
      Global_Tables : constant String :=
        (if Is_Multisite
         then Users_Multi_Table & Usermeta_Table
         else Users_Single_Table & Usermeta_Table);

      -- Multisite global tables.
      MS_Global_Tables : constant String :=
"        CREATE TABLE " & (-WpDB.Blogs) & " ( " &
"        blog_id bigint(20) NOT NULL auto_increment, " &
"        site_id bigint(20) NOT NULL default '0', " &
"        domain varchar(200) NOT NULL default '', " &
"        path varchar(100) NOT NULL default '', " &
"        registered datetime NOT NULL default '0000-00-00 00:00:00', " &
"        last_updated datetime NOT NULL default '0000-00-00 00:00:00', " &
"        public tinyint(2) NOT NULL default '1', " &
"        archived tinyint(2) NOT NULL default '0', " &
"        mature tinyint(2) NOT NULL default '0', " &
"        spam tinyint(2) NOT NULL default '0', " &
"        deleted tinyint(2) NOT NULL default '0', " &
"        lang_id int(11) NOT NULL default '0', " &
"        PRIMARY KEY  (blog_id), " &
"        KEY domain (domain(50),path(5)), " &
"        KEY lang_id (lang_id) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Blogmeta) & " ( " &
"        meta_id bigint(20) unsigned NOT NULL auto_increment, " &
"        blog_id bigint(20) NOT NULL default '0', " &
"        meta_key varchar(255) default NULL, " &
"        meta_value longtext, " &
"        PRIMARY KEY  (meta_id), " &
"        KEY meta_key (meta_key(" & Max_Index_Length & ")), " &
"        KEY blog_id (blog_id) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Registration_Log) & " ( " &
"        ID bigint(20) NOT NULL auto_increment, " &
"        email varchar(255) NOT NULL default '', " &
"        IP varchar(30) NOT NULL default '', " &
"        blog_id bigint(20) NOT NULL default '0', " &
"        date_registered datetime NOT NULL default '0000-00-00 00:00:00', " &
"        PRIMARY KEY  (ID), " &
"        KEY IP (IP) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Site) & " ( " &
"        id bigint(20) NOT NULL auto_increment, " &
"        domain varchar(200) NOT NULL default '', " &
"        path varchar(100) NOT NULL default '', " &
"        PRIMARY KEY  (id), " &
"        KEY domain (domain(140),path(51)) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Sitemeta) & " ( " &
"        meta_id bigint(20) NOT NULL auto_increment, " &
"        site_id bigint(20) NOT NULL default '0', " &
"        meta_key varchar(255) default NULL, " &
"        meta_value longtext, " &
"        PRIMARY KEY  (meta_id), " &
"        KEY meta_key (meta_key(" & Max_Index_Length & ")), " &
"        KEY site_id (site_id) " &
") " & Charset_Collate & "; " &

"CREATE TABLE " & (-WpDB.Signups) & " ( " &
"        signup_id bigint(20) NOT NULL auto_increment, " &
"        domain varchar(200) NOT NULL default '', " &
"        path varchar(100) NOT NULL default '', " &
"        title longtext NOT NULL, " &
"        user_login varchar(60) NOT NULL default '', " &
"        user_email varchar(100) NOT NULL default '', " &
"        registered datetime NOT NULL default '0000-00-00 00:00:00', " &
"        activated datetime NOT NULL default '0000-00-00 00:00:00', " &
"        active tinyint(1) NOT NULL default '0', " &
"        activation_key varchar(50) NOT NULL default '', " &
"        meta longtext, " &
"        PRIMARY KEY  (signup_id), " &
"        KEY activation_key (activation_key), " &
"        KEY user_email (user_email), " &
"        KEY user_login_email (user_login,user_email), " &
"        KEY domain_path (domain(140),path(51)) " &
") " & Charset_Collate & ";";

      Queries : Unbounded_String;
   begin
      if Scope in "blog" then
         Queries := +Blog_Tables;

      elsif Scope in "global" then
         Queries := +Global_Tables;
         if Is_Multisite then
            Append (Queries, MS_Global_Tables);
         end if;

      elsif Scope in "ms_global" then
         Queries := +MS_Global_Tables;

      elsif Scope in "all" then
         Queries := +(Global_Tables & Blog_Tables);
         if Is_Multisite then
            Append (Queries, MS_Global_Tables);
         end if;
      end if;

      if Old_Blog_Id /= -1 then
--    if Isset (Old_Blog_Id) then
         declare
            Unused : Integer;
         begin
            Unused := WpDB.Set_Blog_Id (Old_Blog_Id);
         end;
      end if;

      return -Queries;
   end Wp_Get_DB_Schema;

   ----------------------
   -- Populate_Options --
   ----------------------

   procedure Populate_Options (Options : Array_Type := Empty_Array)
   is
      use Ada.Strings.Unbounded;
      use Php.Arrays;
      use Php.Lists;
      use Php.Misc;
      use Php.Strings;
      use Php.Types;
      use Globals;
      use Hb_Common;
      use Adi_Upgrade;
      use Inc_Class_Wp_Themes;
      use Inc_Class_Wpdb;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Plugins;
      use Inc_Themes;
      use Inc_Versions;
--    global wpdb, wp_db_version, wp_current_db_version;

      Guess_URL : constant String := Wp_Guess_URL;
   begin
      --
      -- Fires before creating WordPress options and populating their default values.
      --
      -- @since 2.6.0
      --
      Do_Action ("populate_options");

      -- If WP_DEFAULT_THEME doesn't exist, fall back to the latest core
      -- default theme.
      declare
         Stylesheet : Unbounded_String := WP_DEFAULT_THEME;
         Template   : Unbounded_String := WP_DEFAULT_THEME;
         Theme      : Wp_Theme := Wp_Get_Theme (-WP_DEFAULT_THEME);
      begin
         if not Theme.Exists then
            Theme := Get_Core_Default_Theme; -- WP_Theme::
         end if;

         -- If we can't find a core default theme, WP_DEFAULT_THEME is the best we
         -- can do.
         if Theme /= Null_Theme then
--       if Theme then
            Stylesheet := +Theme.Get_Stylesheet;
            Template   := +Theme.Get_Template;
         end if;

         declare
            Timezone_String : Unbounded_String;
            GMT_Offset      : Integer := 0;
            --
            -- translators: default GMT offset or timezone string. Must be either a
            -- valid offset (-12 to 14) or a valid timezone string (America/New_York).
            -- See https://www.php.net/manual/en/timezones.php
            -- for all timezone strings currently supported by PHP.
            --
            -- Important: When a previous timezone string, like `Europe/Kiev`, has
            -- been superseded by an updated one, like `Europe/Kyiv`, as a rule of
            -- thumb, the **old** timezone name should be used in the "translation"
            -- to allow for the default timezone setting to be PHP cross-version
            -- compatible, as old timezone names will be recognized in new PHP
            -- versions, while new timezone names cannot be recognized in old PHP
            -- versions.
            --
            -- To verify which timezone strings are available in the _oldest_ PHP
            -- version supported, you can use https://3v4l.org/6YQAt#v5.6.20 and
            -- replace the "BR" (Brazil) in the code line with the country code for
            -- which you want to look up the supported timezone names.
            --
            Offset_Or_TZ : constant String :=
              X_X ("0", "default GMT offset or timezone string");
         begin
            if Is_Numeric (Offset_Or_TZ) then
               GMT_Offset := Integer'Value (Offset_Or_TZ);
            elsif
              Offset_Or_TZ /= "" and then
              In_List (Offset_Or_TZ,
                       Timezone_Identifiers_List (ALL_WITH_BC), True) -- DateTimeZone::
            then
               Timezone_String := +Offset_Or_TZ;
            end if;

            declare
               Defaults : Array_Type := To_Array (List => (
                Build ("siteurl",                         Guess_URL),
                Build ("home",                            Guess_URL),
                Build ("blogname",                        abs "My Site"),
                Build ("blogdescription",                 ""),
                Build ("users_can_register",              0),
                Build ("admin_email",                     "you@example.com"),
                -- translators: Default start of the week. 0 = Sunday, 1 = Monday.
                Build ("start_of_week",                   X_X ("1", "start of week")),
                Build ("use_balanceTags",                 0),
                Build ("use_smilies",                     1),
                Build ("require_name_email",              1),
                Build ("comments_notify",                 1),
                Build ("posts_per_rss",                   10),
                Build ("rss_use_excerpt",                 0),
                Build ("mailserver_url",                  "mail.example.com"),
                Build ("mailserver_login",                "login@example.com"),
                Build ("mailserver_pass",                 "password"),
                Build ("mailserver_port",                 110),
                Build ("default_category",                1),
                Build ("default_comment_status",          "open"),
                Build ("default_ping_status",             "open"),
                Build ("default_pingback_flag",           1),
                Build ("posts_per_page",                  10),
                -- translators: Default date format, see https://www.php.net/manual/datetime.format.php
                Build ("date_format",                     abs "F j, Y"),
                -- translators: Default time format, see https://www.php.net/manual/datetime.format.php
                Build ("time_format",                     abs "g:i a"),
                -- translators: Links last updated date format, see https://www.php.net/manual/datetime.format.php
                Build ("links_updated_date_format",       abs "F j, Y g:i a"),
                Build ("comment_moderation",              0),
                Build ("moderation_notify",               1),
                Build ("permalink_structure",             ""),
                Build ("rewrite_rules",                   ""),
                Build ("hack_file",                       0),
                Build ("blog_charset",                    "UTF-8"),
                Build ("moderation_keys",                 ""),
                Build ("active_plugins",                  Empty_Array),
                Build ("category_base",                   ""),
                Build ("ping_sites",                      "http://rpc.pingomatic.com/"),
                Build ("comment_max_links",               2),
                Build ("gmt_offset",                      GMT_Offset),

                -- 1.5.0
                Build ("default_email_category",          1),
                Build ("recently_edited",                 ""),
                Build ("template",                        -Template),
                Build ("stylesheet",                      -Stylesheet),
                Build ("comment_registration",            0),
                Build ("html_type",                       "text/html"),

                -- 1.5.1
                Build ("use_trackback",                   0),

                -- 2.0.0
                Build ("default_role",                    "subscriber"),
                Build ("db_version",                      Wp_DB_Version),

                -- 2.0.1
                Build ("uploads_use_yearmonth_folders",   1),
                Build ("upload_path",                     ""),

                -- 2.1.0
                Build ("blog_public",                     "1"),
                Build ("default_link_category",           2),
                Build ("show_on_front",                   "posts"),

                -- 2.2.0
                Build ("tag_base",                        ""),

                -- 2.5.0
                Build ("show_avatars",                    "1"),
                Build ("avatar_rating",                   "G"),
                Build ("upload_url_path",                 ""),
                Build ("thumbnail_size_w",                150),
                Build ("thumbnail_size_h",                150),
                Build ("thumbnail_crop",                  1),
                Build ("medium_size_w",                   300),
                Build ("medium_size_h",                   300),

                -- 2.6.0
                Build ("avatar_default",                  "mystery"),

                -- 2.7.0
                Build ("large_size_w",                    1024),
                Build ("large_size_h",                    1024),
                Build ("image_default_link_type",         "none"),
                Build ("image_default_size",              ""),
                Build ("image_default_align",             ""),
                Build ("close_comments_for_old_posts",    0),
                Build ("close_comments_days_old",         14),
                Build ("thread_comments",                 1),
                Build ("thread_comments_depth",           5),
                Build ("page_comments",                   0),
                Build ("comments_per_page",               50),
                Build ("default_comments_page",           "newest"),
                Build ("comment_order",                   "asc"),
                Build ("sticky_posts",                    Empty_Array),
                Build ("widget_categories",               Empty_Array),
                Build ("widget_text",                     Empty_Array),
                Build ("widget_rss",                      Empty_Array),
                Build ("uninstall_plugins",               Empty_Array),

                -- 2.8.0
                Build ("timezone_string",                 -Timezone_String),

                -- 3.0.0
                Build ("page_for_posts",                  0),
                Build ("page_on_front",                   0),

                -- 3.1.0
                Build ("default_post_format",             0),

                -- 3.5.0
                Build ("link_manager_enabled",            0),

                -- 4.3.0
                Build ("finished_splitting_shared_terms", 1),
                Build ("site_icon",                       0),

                -- 4.4.0
                Build ("medium_large_size_w",             768),
                Build ("medium_large_size_h",             0),

                -- 4.9.6
                Build ("wp_page_for_privacy_policy",      0),

                -- 4.9.8
                Build ("show_comments_cookies_opt_in",    1),

                -- 5.3.0
                Build ("admin_email_lifespan",
                       (Php.Misc.Time + 6 * MONTH_IN_SECONDS)),

                -- 5.5.0
                Build ("disallowed_keys",                 ""),
                Build ("comment_previously_approved",     1),
                Build ("auto_plugin_theme_update_emails", Empty_Array),

                -- 5.6.0
                Build ("auto_update_core_dev",            "enabled"),
                Build ("auto_update_core_minor",          "enabled"),
                -- Default to enabled for new installs.
                -- See https://core.trac.wordpress.org/ticket/51742.
                Build ("auto_update_core_major",          "enabled"),

                -- 5.8.0
                Build ("wp_force_deactivated_plugins",    Empty_Array)
               ));
            begin
               -- 3.3.0
               if not Is_Multisite then
                  Set (Defaults, "initial_db_version",
                       From_Integer
                       (if
--                        not Empty (Wp_Current_DB_Version) and then
                          Wp_Current_DB_Version < Wp_DB_Version
                        then Wp_Current_DB_Version
                        else Wp_DB_Version));
               end if;

               -- 3.0.0 multisite.
               if Is_Multisite then
                  Set (Defaults, "permalink_structure", From_String (
                       "/%year%/%monthnum%/%day%/%postname%/"));
               end if;

               declare
                  Options_2 : constant Array_Type :=
                    Wp_Parse_Args (Options, Defaults);

                  -- Set autoload to no for these options.
                  Fat_Options : constant List_Type := To_List (List => (
                    +"moderation_keys",
                    +"recently_edited",
                    +"disallowed_keys",
                    +"uninstall_plugins",
                    +"auto_plugin_theme_update_emails"
                  ));

                  Keys : constant String :=
                    "'" & Implode ("', '", List_Type'(Array_Keys (Options_2))) & "'";

                  Existing_Options : constant List_Type :=
                    WpDB.Get_Col (Statement_Type (
                      "SELECT option_name FROM " & (-WpDB.Options) &
                      " WHERE option_name in (" & Keys & ")"));
                  -- phpcs:ignore WordPress.DB.PreparedSQL.NotPrepared

                  Insert : Unbounded_String;
               begin

                  for A in Options_2.Iterate loop
                     declare
                        Option : constant String := Key (A);
                        Value  : Multi_Type      := Element (A);
                        Autoload : Unbounded_String;
                     begin
                        if In_List (Option, Existing_Options, True) then
                           goto Continue;
                        end if;

                        if In_List (Option, Fat_Options, True) then
                           Autoload := +"no";
                        else
                           Autoload := +"yes";
                        end if;

                        if not Empty (-Insert) then
                           Append (Insert, ", ");
                        end if;

                        Value :=
                          Maybe_Serialize (
                            Sanitize_Option (Option, As_String (Value)));

                        Append (Insert, String (
                                WpDB.Prepare ("(%s, %s, %s)",
                                              To_List (List => (
                                                1 => +Option,
                                                2 => +As_String (Value),
                                                3 => Autoload))
                                             )));
                     end;
                     << Continue >>
                  end loop;

                  if not Empty (-Insert) then
                     WpDB.Query (Statement_Type (
                       "INSERT INTO " & (-WpDB.Options) &
                       " (option_name, option_value, autoload) " &
                       "VALUES " & (-Insert)));
                     -- phpcs:ignore WordPress.DB.PreparedSQL.NotPrepared
                  end if;
               end;
            end;
         end;
      end;

      -- In case it is set, but blank, update "home".
      if X_Get_Option ("home") = Null_Multi_Type then -- not
         Update_Option ("home", From_String (Guess_URL));
      end if;

      declare
         -- Delete unused options.
         Unusedoptions : constant List_Type := To_List (List => (
                +"blodotgsping_url",
                +"bodyterminator",
                +"emailtestonly",
                +"phoneemail_separator",
                +"smilies_directory",
                +"subjectprefix",
                +"use_bbcode",
                +"use_blodotgsping",
                +"use_phoneemail",
                +"use_quicktags",
                +"use_weblogsping",
                +"weblogs_cache_file",
                +"use_preview",
                +"use_htmltrans",
                +"smilies_directory",
                +"fileupload_allowedusers",
                +"use_phoneemail",
                +"default_post_status",
                +"default_post_category",
                +"archive_mode",
                +"time_difference",
                +"links_minadminlevel",
                +"links_use_adminlevels",
                +"links_rating_type",
                +"links_rating_char",
                +"links_rating_ignore_zero",
                +"links_rating_single_image",
                +"links_rating_image0",
                +"links_rating_image1",
                +"links_rating_image2",
                +"links_rating_image3",
                +"links_rating_image4",
                +"links_rating_image5",
                +"links_rating_image6",
                +"links_rating_image7",
                +"links_rating_image8",
                +"links_rating_image9",
                +"links_recently_updated_time",
                +"links_recently_updated_prepend",
                +"links_recently_updated_append",
                +"weblogs_cacheminutes",
                +"comment_allowed_tags",
                +"search_engine_friendly_urls",
                +"default_geourl_lat",
                +"default_geourl_lon",
                +"use_default_geourl",
                +"weblogs_xml_url",
                +"new_users_can_blog",
                +"_wpnonce",
                +"_wp_http_referer",
                +"Update",
                +"action",
                +"rich_editing",
                +"autosave_interval",
                +"deactivated_plugins",
                +"can_compress_scripts",
                +"page_uris",
                +"update_core",
                +"update_plugins",
                +"update_themes",
                +"doing_cron",
                +"random_seed",
                +"rss_excerpt_length",
                +"secret",
                +"use_linksupdate",
                +"default_comment_status_page",
                +"wporg_popular_tags",
                +"what_to_show",
                +"rss_language",
                +"language",
                +"enable_xmlrpc",
                +"enable_app",
                +"embed_autourls",
                +"default_post_edit_rows",
                +"gzipcompression",
                +"advanced_edit"
              ));
      begin
         for Option of Unusedoptions loop
            Delete_Option (-Option);
         end loop;
      end;

      -- Delete obsolete magpie stuff.
      WpDB.Query (Statement_Type (
        "DELETE FROM " & (-WpDB.Options) &
        " WHERE option_name REGEXP ""^rss_[0-9a-f]{32}(_ts)?"""));

      -- Clear expired transients.
      Delete_Expired_Transients (True);
   end Populate_Options;

   --------------------
   -- Populate_Roles --
   --------------------

   procedure Populate_Roles
   is
   begin
      Populate_Roles_160;
      Populate_Roles_210;
      Populate_Roles_230;
      Populate_Roles_250;
      Populate_Roles_260;
      Populate_Roles_270;
      Populate_Roles_280;
      Populate_Roles_300;
   end Populate_Roles;

   ------------------------
   -- Populate_Roles_160 --
   ------------------------

   procedure Populate_Roles_160
   is
      use Inc_Capabilities;
   begin
      -- Add roles.
      Add_Role ("administrator", "Administrator");
      Add_Role ("editor", "Editor");
      Add_Role ("author", "Author");
      Add_Role ("contributor", "Contributor");
      Add_Role ("subscriber", "Subscriber");

      -- Add caps for Administrator role.
      declare
         Role : Wp_Role := Get_Role ("administrator");
      begin
         Role.Add_Cap ("switch_themes");
         Role.Add_Cap ("edit_themes");
         Role.Add_Cap ("activate_plugins");
         Role.Add_Cap ("edit_plugins");
         Role.Add_Cap ("edit_users");
         Role.Add_Cap ("edit_files");
         Role.Add_Cap ("manage_options");
         Role.Add_Cap ("moderate_comments");
         Role.Add_Cap ("manage_categories");
         Role.Add_Cap ("manage_links");
         Role.Add_Cap ("upload_files");
         Role.Add_Cap ("import");
         Role.Add_Cap ("unfiltered_html");
         Role.Add_Cap ("edit_posts");
         Role.Add_Cap ("edit_others_posts");
         Role.Add_Cap ("edit_published_posts");
         Role.Add_Cap ("publish_posts");
         Role.Add_Cap ("edit_pages");
         Role.Add_Cap ("read");
         Role.Add_Cap ("level_10");
         Role.Add_Cap ("level_9");
         Role.Add_Cap ("level_8");
         Role.Add_Cap ("level_7");
         Role.Add_Cap ("level_6");
         Role.Add_Cap ("level_5");
         Role.Add_Cap ("level_4");
         Role.Add_Cap ("level_3");
         Role.Add_Cap ("level_2");
         Role.Add_Cap ("level_1");
         Role.Add_Cap ("level_0");
      end;

      -- Add caps for Editor    Role.
      declare
         Role : Wp_Role := Get_Role ("editor");
      begin
         Role.Add_Cap ("moderate_comments");
         Role.Add_Cap ("manage_categories");
         Role.Add_Cap ("manage_links");
         Role.Add_Cap ("upload_files");
         Role.Add_Cap ("unfiltered_html");
         Role.Add_Cap ("edit_posts");
         Role.Add_Cap ("edit_others_posts");
         Role.Add_Cap ("edit_published_posts");
         Role.Add_Cap ("publish_posts");
         Role.Add_Cap ("edit_pages");
         Role.Add_Cap ("read");
         Role.Add_Cap ("level_7");
         Role.Add_Cap ("level_6");
         Role.Add_Cap ("level_5");
         Role.Add_Cap ("level_4");
         Role.Add_Cap ("level_3");
         Role.Add_Cap ("level_2");
         Role.Add_Cap ("level_1");
         Role.Add_Cap ("level_0");
      end;

      -- Add caps for Author    Role.
      declare
         Role : Wp_Role := Get_Role ("author");
      begin
         Role.Add_Cap ("upload_files");
         Role.Add_Cap ("edit_posts");
         Role.Add_Cap ("edit_published_posts");
         Role.Add_Cap ("publish_posts");
         Role.Add_Cap ("read");
         Role.Add_Cap ("level_2");
         Role.Add_Cap ("level_1");
         Role.Add_Cap ("level_0");
      end;

      -- Add caps for Contributor    Role.
      declare
         Role : Wp_Role := Get_Role ("contributor");
      begin
         Role.Add_Cap ("edit_posts");
         Role.Add_Cap ("read");
         Role.Add_Cap ("level_1");
         Role.Add_Cap ("level_0");
      end;

      -- Add caps for Subscriber    Role.
      declare
         Role : Wp_Role := Get_Role ("subscriber");
      begin
         Role.Add_Cap ("read");
         Role.Add_Cap ("level_0");
      end;
   end Populate_Roles_160;

   ------------------------
   -- Populate_Roles_210 --
   ------------------------

   procedure Populate_Roles_210
   is
      use Hb_Common;
      use Inc_Capabilities;

      Roles : constant List_Type :=
        To_List (List => (+"administrator", +"editor"));
   begin
      for R of Roles loop
         declare
            Role : Wp_Role := Get_Role (-R);
         begin
            if Role = Null_Role then
               goto Continue;
            end if;

            Role.Add_Cap ("edit_others_pages");
            Role.Add_Cap ("edit_published_pages");
            Role.Add_Cap ("publish_pages");
            Role.Add_Cap ("delete_pages");
            Role.Add_Cap ("delete_others_pages");
            Role.Add_Cap ("delete_published_pages");
            Role.Add_Cap ("delete_posts");
            Role.Add_Cap ("delete_others_posts");
            Role.Add_Cap ("delete_published_posts");
            Role.Add_Cap ("delete_private_posts");
            Role.Add_Cap ("edit_private_posts");
            Role.Add_Cap ("read_private_posts");
            Role.Add_Cap ("delete_private_pages");
            Role.Add_Cap ("edit_private_pages");
            Role.Add_Cap ("read_private_pages");
         end;
         << Continue >>
      end loop;

      declare
         Role : Wp_Role := Get_Role ("administrator");
      begin
         if Role /= Null_Role then
            Role.Add_Cap ("delete_users");
            Role.Add_Cap ("create_users");
         end if;
      end;

      declare
         Role : Wp_Role := Get_Role ("author");
      begin
         if Role /= Null_Role then
            Role.Add_Cap ("delete_posts");
            Role.Add_Cap ("delete_published_posts");
         end if;
      end;

      declare
         Role : Wp_Role := Get_Role ("contributor");
      begin
         if Role /= Null_Role then
            Role.Add_Cap ("delete_posts");
         end if;
      end;
   end Populate_Roles_210;

   ------------------------
   -- Populate_Roles_230 --
   ------------------------

   procedure Populate_Roles_230
   is
      use Inc_Capabilities;

      Role : Wp_Role := Get_Role ("administrator");
   begin
      if Role /= Null_Role then
         Role.Add_Cap ("unfiltered_upload");
      end if;
   end Populate_Roles_230;

   ------------------------
   -- Populate_Roles_250 --
   ------------------------

   procedure Populate_Roles_250
   is
      use Inc_Capabilities;

      Role : Wp_Role := Get_Role ("administrator");
   begin
      if Role /= Null_Role then
         Role.Add_Cap ("edit_dashboard");
      end if;
   end Populate_Roles_250;

   ------------------------
   -- Populate_Roles_260 --
   ------------------------

   procedure Populate_Roles_260
   is
      use Inc_Capabilities;

      Role : Wp_Role := Get_Role ("administrator");
   begin
      if Role /= Null_Role then
         Role.Add_Cap ("update_plugins");
         Role.Add_Cap ("delete_plugins");
      end if;
   end Populate_Roles_260;

   ------------------------
   -- Populate_Roles_270 --
   ------------------------

   procedure Populate_Roles_270
   is
      use Inc_Capabilities;

      Role : Wp_Role := Get_Role ("administrator");
   begin
      if Role /= Null_Role then
         Role.Add_Cap ("install_plugins");
         Role.Add_Cap ("update_themes");
      end if;
   end Populate_Roles_270;

   ------------------------
   -- Populate_Roles_280 --
   ------------------------

   procedure Populate_Roles_280
   is
      use Inc_Capabilities;

      Role : Wp_Role := Get_Role ("administrator");
   begin
      if Role /= Null_Role then
         Role.Add_Cap ("install_themes");
      end if;
   end Populate_Roles_280;

   ------------------------
   -- Populate_Roles_300 --
   ------------------------

   procedure Populate_Roles_300
   is
      use Inc_Capabilities;

      Role : Wp_Role := Get_Role ("administrator");
   begin
      if Role /= Null_Role then
         Role.Add_Cap ("update_core");
         Role.Add_Cap ("list_users");
         Role.Add_Cap ("remove_users");
         Role.Add_Cap ("promote_users");
         Role.Add_Cap ("edit_theme_options");
         Role.Add_Cap ("delete_themes");
         Role.Add_Cap ("export");
      end if;
   end Populate_Roles_300;

end Adi_Schemas;
