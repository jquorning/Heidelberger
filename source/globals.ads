with Ada.Strings.Unbounded;

with Arrays;

-- with Adm_Menu;

with Adi_Class_Wp_Screens;

with Inc_Class_Wpdb;
with Inc_Class_Wp_Locale;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;
with Inc_Class_Wp_Taxonomy;

package Globals
is
   use Ada.Strings.Unbounded;
   use Arrays;

   procedure Dummy;

   GLOBALS : Array_Type := Empty_Array;

   X_DIR_X         : constant String := "";
   ABSPATH         : constant String := "";
   WPINC           : Unbounded_String;
   WP_PLUGIN_DIR   : Unbounded_String;
   WPMU_PLUGIN_DIR : Unbounded_String;
   WP_CONTENT_DIR  : Unbounded_String;
   WP_LANG_DIR     : constant String := "";
   WP_TEMP_DIR     : Unbounded_String;

   WP_CONTENT_URL  : Unbounded_String;
   WP_PLUGIN_URL   : Unbounded_String;
   PLUGINDIR       : Unbounded_String;
   WPMU_PLUGIN_URL : Unbounded_String;
   MUPLUGINDIR     : Unbounded_String;

   AUTOSAVE_INTERVAL    : Natural;
   EMPTY_TRASH_DAYS     : Natural;
   WP_POST_REVISIONS    : Boolean;
   WP_CRON_LOCK_TIMEOUT : Natural;
   WP_RUN_CORE_TESTS    : Boolean;
   ENFORCE_GZIP         : Boolean;
   CONCATENATE_SCRIPTS  : Boolean;
   COMPRESS_SCRIPTS     : Boolean;
   COMPRESS_CSS         : Boolean;
   MULTISITE            : constant Boolean := False;

   TEMPLATEPATH     : Unbounded_String;
   STYLESHEETPATH   : Unbounded_String;
   WP_DEFAULT_THEME : Unbounded_String;

   MINUTE_IN_SECONDS : constant Natural := 60;
   HOUR_IN_SECONDS   : constant Natural := 60 * MINUTE_IN_SECONDS;
   DAY_IN_SECONDS    : constant Natural := 24 * HOUR_IN_SECONDS;
   MONTH_IN_SECONDS  : constant Natural := 30 * DAY_IN_SECONDS;
   YEAR_IN_SECONDS   : constant Natural := 365 * DAY_IN_SECONDS;

   SITECOOKIEPATH : Unbounded_String;

   WPLANG : constant String := "da_DK";

   WP_SETUP_CONFIG : constant Boolean := False;

   WpDB : Inc_Class_Wpdb.Wpdb_Class;

   XMLRPC_REQUEST : Boolean := False;
   DOING_AJAX     : Boolean := False;
   IFRAME_REQUEST : Boolean := False;
   DOING_CRON     : Boolean := False;

   MEDIA_TRASH : Boolean := False;

   WP_ADMIN          : Boolean;
   WP_NETWORK_ADMIN  : Boolean;
   WP_USER_ADMIN     : Boolean;
   WP_BLOG_ADMIN     : Boolean;
   WP_LOAD_IMPORTERS : Boolean;

   WP_DEBUG         : Boolean;
   WP_DEBUG_DISPLAY : Boolean;
   SCRIPT_DEBUG     : Boolean := False;
   REST_REQUEST     : Boolean := False;

   WP_INSTALLING         : Boolean := False;
   WP_REPAIRING          : Boolean := False;
   WP_INSTALLING_NETWORK : Boolean := False;

   WP_HTTP_BLOCK_EXTERNAL : Boolean := False;
   WP_ACCESSIBLE_HOSTS : Unbounded_String;

   WP_PROXY_HOST : Unbounded_String;
   WP_PROXY_PORT : Unbounded_String;

   WP_HOME_DEF : constant Boolean := False;
   WP_HOME     : constant String  := "";

   WP_SITEURL_DEF : constant Boolean := False;
   WP_SITEURL     : constant String  := "";

   Wp_Importers : Array_Type;

   Typenow     : Unbounded_String;
   Taxnow      : Unbounded_String;
   Pagenow     : Unbounded_String;
   Hook_Suffix : Unbounded_String;

   Title         : Unbounded_String;
   Post_New_File : Unbounded_String;

   Current_Screen     : Adi_Class_Wp_Screens.Wp_Screen;
   Wp_Locale          : Inc_Class_Wp_Locale.Wp_Locale;
   Total_Update_Count : Natural;
   Update_Title       : Unbounded_String;

   Post_Type        : Unbounded_String;
   Post_Type_Object : Inc_Class_Wp_Post_Type.Wp_Post_Type;
   Post             : Inc_Class_Wp_Posts.Wp_Post;

   Action   : Unbounded_String;
   Taxonomy : Unbounded_String;
   Tax      : Inc_Class_Wp_Taxonomy.Wp_Taxonomy; -- := Inc_Class_Wp_Taxonomy.X_Construct;

   KB_IN_BYTES : constant := 1024;
   MB_IN_BYTES : constant := 1024 * KB_IN_BYTES;
   GB_IN_BYTES : constant := 1024 * MB_IN_BYTES;
--         define( "TB_IN_BYTES", 1024 * GB_IN_BYTES );
--         define( "PB_IN_BYTES", 1024 * TB_IN_BYTES );
--         define( "EB_IN_BYTES", 1024 * PB_IN_BYTES );
--         define( "ZB_IN_BYTES", 1024 * EB_IN_BYTES );
--         define( "YB_IN_BYTES", 1024 * ZB_IN_BYTES );

   ALLOW_UNFILTERED_UPLOADS : constant Boolean := True;
   DISALLOW_UNFILTERED_HTML : constant Boolean := True;
   DISALLOW_FILE_EDIT       : constant Boolean := True;
   DISALLOW_FILE_MODS       : constant Boolean := True;

   DO_NOT_UPGRADE_GLOBAL_TABLES : constant Boolean := False;

   CUSTOM_USER_TABLE      : constant String := "USER_TABLE";
   CUSTOM_USER_META_TABLE : constant String := "USER_META_TABLE";

   AUTH_SALT : constant String := "SALT";

   DB_COLLATE : constant String := "";
   DB_CHARSET : constant String := "";

end Globals;
