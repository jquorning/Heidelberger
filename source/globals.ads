with Arrays;

with Inc_Class_Wpdb;

package Globals
is
   use Arrays;

   ABSPATH       : constant String := "";
   WPINC         : constant String := "";
   WP_PLUGIN_DIR : constant String := "";

   function Typenow return String;
   function Taxnow  return String;

   X_SERVER  : Array_Type := Empty_Array;
   X_POST    : Array_Type := Empty_Array;
   XX_GET    : Array_Type := Empty_Array;
   X_REQUEST : Array_Type := Empty_Array;
   X_COOKIE  : Array_Type := Empty_Array;
   GLOBALS   : Array_Type := Empty_Array;

    Wpdb : Inc_Class_Wpdb.Wpdb_Class;

end Globals;
