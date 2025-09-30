with Ada.Strings.Unbounded;

with Arrays;

with Adm_Menu;

with Adi_Class_Wp_Screens;

with Inc_Class_Wpdb;
with Inc_Class_Wp_Locale;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;

package Globals
is
   use Ada.Strings.Unbounded;
   use Arrays;

   procedure Dummy;

   GLOBALS : Array_Type := Empty_Array;

   ABSPATH         : constant String := "";
   WPINC           : constant String := "";
   WP_PLUGIN_DIR   : Unbounded_String;
   WPMU_PLUGIN_DIR : Unbounded_String;
   WP_CONTENT_DIR  : constant String := "";
   WP_SITEURL      : constant String := "";
   WP_LANG_DIR     : constant String := "";

   WP_CONTENT_URL  : Unbounded_String;
   WP_PLUGIN_URL   : Unbounded_String;
   PLUGINDIR       : Unbounded_String;
   WPMU_PLUGIN_URL : Unbounded_String;
   MUPLUGINDIR     : Unbounded_String;

   AUTOSAVE_INTERVAL    : Natural;
   EMPTY_TRASH_DAYS     : Natural;
   WP_POST_REVISIONS    : Boolean;
   WP_CRON_LOCK_TIMEOUT : Natural;

   TEMPLATEPATH     : Unbounded_String;
   STYLESHEETPATH   : Unbounded_String;
   WP_DEFAULT_THEME : Unbounded_String;

   MINUTE_IN_SECONDS : Natural;

   WPLANG : constant String := "da_DK";

   WP_SETUP_CONFIG : constant Boolean := False;

   Wpdb : Inc_Class_Wpdb.Wpdb_Class;

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

   WP_INSTALLING         : Boolean := False;
   WP_REPAIRING          : Boolean := False;
   WP_INSTALLING_NETWORK : Boolean := False;

   Wp_Importers : Array_Type;

   Typenow     : Unbounded_String;
   Taxnow      : Unbounded_String;
   Pagenow     : Unbounded_String;
   Hook_Suffix : Unbounded_String;
   Plugin_Page : Adm_Menu.Unbounded_Slug;

   Title         : Unbounded_String;
   Parent_File   : Adm_Menu.Unbounded_Slug;
   Submenu_File  : Adm_Menu.Unbounded_Slug;
   Post_New_File : Unbounded_String;

   Current_Screen     : Adi_Class_Wp_Screens.Wp_Screen;
   Wp_Locale          : Inc_Class_Wp_Locale.Wp_Locale;
   Total_Update_Count : Natural;
   Update_Title       : Unbounded_String;

   Post_Type        : Unbounded_String;
   Post_Type_Object : Inc_Class_Wp_Post_Type.Wp_Post_Type;
   Post             : Inc_Class_Wp_Posts.Wp_Post;

end Globals;
