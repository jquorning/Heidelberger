--
--
--

with Arrays;
with UStrings;

with Adi_Class_Wp_Screens;

with Class_WpDB;
with Class_Locales;
with Class_Posts;
with Class_Post_Type;
with Class_Taxonomy;

package Globals
is
   use Arrays;

   procedure Dummy;

   GLOBALS : Array_Type := Empty_Array;

   X_DIR_X         : constant String := "";
   ABSPATH         : constant String := "";
   WPINC           : UStrings.UString;
   WP_PLUGIN_DIR   : UStrings.UString;
   WPMU_PLUGIN_DIR : UStrings.UString;
   WP_CONTENT_DIR  : UStrings.UString;
   WP_LANG_DIR     : constant String := "";
   WP_TEMP_DIR     : UStrings.UString;

   WP_CONTENT_URL  : UStrings.UString;
   WP_PLUGIN_URL   : UStrings.UString;
   PLUGINDIR       : UStrings.UString;
   WPMU_PLUGIN_URL : UStrings.UString;
   MUPLUGINDIR     : UStrings.UString;

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

   TEMPLATEPATH     : UStrings.UString;
   STYLESHEETPATH   : UStrings.UString;
   WP_DEFAULT_THEME : UStrings.UString;

   MINUTE_IN_SECONDS : constant Natural := 60;
   HOUR_IN_SECONDS   : constant Natural := 60 * MINUTE_IN_SECONDS;
   DAY_IN_SECONDS    : constant Natural := 24 * HOUR_IN_SECONDS;
   MONTH_IN_SECONDS  : constant Natural := 30 * DAY_IN_SECONDS;
   YEAR_IN_SECONDS   : constant Natural := 365 * DAY_IN_SECONDS;

   COOKIE_DOMAIN        : UStrings.UString;
   COOKIEHASH           : UStrings.UString;
   USER_COOKIE          : UStrings.UString;
   PASS_COOKIE          : UStrings.UString;
   AUTH_COOKIE          : UStrings.UString;
   SECURE_AUTH_COOKIE   : UStrings.UString;
   LOGGED_IN_COOKIE     : UStrings.UString;
   TEST_COOKIE          : UStrings.UString;
   COOKIEPATH           : UStrings.UString;
   SITECOOKIEPATH       : UStrings.UString;
   ADMIN_COOKIE_PATH    : UStrings.UString;
   PLUGINS_COOKIE_PATH  : UStrings.UString;
   RECOVERY_MODE_COOKIE : UStrings.UString;

   RELOCATE_DEF : constant Boolean := False;
   RELOCATE     : constant Boolean := False;

   WPLANG : constant String := "en_US";

   WP_SETUP_CONFIG : constant Boolean := False;

   WpDB : Class_WpDB.Wpdb_Class;

   XMLRPC_REQUEST : Boolean := False;

   DOING_AJAX_DEF : constant Boolean := False;
   DOING_AJAX     : constant Boolean := False;

   IFRAME_REQUEST : Boolean := False;
   DOING_CRON     : Boolean := False;

   MEDIA_TRASH : Boolean := False;

   WP_ADMIN          : Boolean;
   WP_NETWORK_ADMIN_DEF : constant Boolean := False;
   WP_NETWORK_ADMIN     : constant Boolean := False;
   WP_USER_ADMIN_DEF    : constant Boolean := False;
   WP_USER_ADMIN        : constant Boolean := False;
   WP_BLOG_ADMIN_DEF    : constant Boolean := False;
   WP_BLOG_ADMIN        :          Boolean := False;

   WP_LOAD_IMPORTERS : Boolean;

   WP_DEBUG         : Boolean := True;
   WP_DEBUG_DISPLAY : Boolean;
   SCRIPT_DEBUG     : Boolean := False;
   REST_REQUEST     : Boolean := False;

   WP_INSTALLING         : Boolean := True;
   WP_REPAIRING          : Boolean := False;
   WP_INSTALLING_NETWORK : Boolean := False;

   WP_HTTP_BLOCK_EXTERNAL : Boolean := False;
   WP_ACCESSIBLE_HOSTS : UStrings.UString;

   WP_PROXY_HOST : UStrings.UString;
   WP_PROXY_PORT : UStrings.UString;

   WP_HOME_DEF : constant Boolean := False;
   WP_HOME     : constant String  := "";

   WP_SITEURL_DEF : constant Boolean := False;
   WP_SITEURL     : constant String  := "";

   Wp_Importers : Array_Type;

   Typenow     : UStrings.UString;
   Taxnow      : UStrings.UString;
   Pagenow     : UStrings.UString;
   Hook_Suffix : UStrings.UString;

   Title         : UStrings.UString;
   Post_New_File : UStrings.UString;

   Current_Screen     : Adi_Class_Wp_Screens.Wp_Screen;
   Wp_Locale          : Class_Locales.Wp_Locale;
   Total_Update_Count : Natural;
   Update_Title       : UStrings.UString;

   Post_Type        : UStrings.UString;
   Post_Type_Object : Class_Post_Type.Wp_Post_Type;
   Post             : Class_Posts.Wp_Post;

   Action   : UStrings.UString;
   Taxonomy : UStrings.UString;
   Tax      : Class_Taxonomy.Wp_Taxonomy; -- := Class_Taxonomy.X_Construct;

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

   Login_Grace_Period : Integer := 0;

   Global_Page  : Natural;
   Global_Paged : Natural;

end Globals;
