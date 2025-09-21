with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wpdb;

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
   Plugin_Page : Unbounded_String;
   -- typenow, taxnow;

   Title        : Unbounded_String;
   Parent_File  : Unbounded_String;
   Submenu_File : Unbounded_String;

end Globals;
