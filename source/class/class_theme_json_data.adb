--
-- WP_Theme_JSON_Data class
--
-- @package WordPress
-- @subpackage Theme
-- @since 6.1.0
--

package body Class_Theme_JSON_Data
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Data   : Array_Type := Empty_Array;
                         Origin : String     := "theme")
                         return Wp_Theme_JSON_Data
   is
      use UStrings;
      use Class_Theme_JSON;

      This  : Wp_Theme_JSON_Data;
      Theme : constant Wp_Theme_JSON := X_Construct (Data, Origin);
   begin
      This.Origin     := +Origin;
      This.Theme_JSON := Theme;
      return This;
   end X_Construct;

   --------------
   -- Get_Data --
   --------------

   function Get_Data (This : Wp_Theme_JSON_Data)
                      return Array_Type
   is
   begin
      return This.Theme_JSON.Get_Raw_Data;
   end Get_Data;

end Class_Theme_JSON_Data;
