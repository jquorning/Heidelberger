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
   WP_PLUGIN_DIR   : constant String := "";
   WPMU_PLUGIN_DIR : constant String := "";

   Wpdb : Inc_Class_Wpdb.Wpdb_Class;

   XMLRPC_REQUEST : Boolean := False;
   DOING_AJAX     : Boolean := False;
   IFRAME_REQUEST : Boolean := False;

   MEDIA_TRASH : Boolean := False;

   WP_ADMIN          : Boolean;
   WP_NETWORK_ADMIN  : Boolean;
   WP_USER_ADMIN     : Boolean;
   WP_BLOG_ADMIN     : Boolean;
   WP_LOAD_IMPORTERS : Boolean;

   WP_DEBUG         : Boolean;
   WP_DEBUG_DISPLAY : Boolean;

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
