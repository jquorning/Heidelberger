with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wpdb;
with Adm_Menu;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;

package Globals
is
   use Ada.Strings.Unbounded;
   use Arrays;

   procedure Dummy;

   ABSPATH         : constant String := "";
   WPINC           : constant String := "";
   WP_PLUGIN_DIR   : constant String := "";
   WPMU_PLUGIN_DIR : constant String := "";

   X_SERVER  : Array_Type := Empty_Array;
   X_POST    : Array_Type := Empty_Array;
   XX_GET    : Array_Type := Empty_Array;
   X_REQUEST : Array_Type := Empty_Array;
   X_COOKIE  : Array_Type := Empty_Array;
   GLOBALS   : Array_Type := Empty_Array;

   Wpdb : Inc_Class_Wpdb.Wpdb_Class;

   XMLRPC_REQUEST : Boolean := True;
   DOING_AJAX     : Boolean := True;
   IFRAME_REQUEST : Boolean := True;

   MEDIA_TRASH : Boolean := False;

   WP_ADMIN          : Boolean;
   WP_NETWORK_ADMIN  : Boolean;
   WP_USER_ADMIN     : Boolean;
   WP_BLOG_ADMIN     : Boolean;
   WP_LOAD_IMPORTERS : Boolean;

   Wp_Importers : Array_Type;

   Typenow     : Unbounded_String;
   Taxnow      : Unbounded_String;
   Pagenow     : Unbounded_String;
   Hook_Suffix : Unbounded_String;
   Plugin_Page : Adm_Menu.Unbounded_Slug;

   Title        : Unbounded_String;
   Parent_File  : Adm_Menu.Unbounded_Slug;
   Submenu_File : Adm_Menu.Unbounded_Slug;

   Post_Type        : Unbounded_String;
   Post_Type_Object : Inc_Class_Wp_Post_Type.Wp_Post_Type;
   Post             : Inc_Class_Wp_Posts.Wp_Post;

end Globals;
