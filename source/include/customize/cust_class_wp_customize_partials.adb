--
-- Customize API: WP_Customize_Partial class
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.5.0
--

package body Cust_Class_Wp_Customize_Partials
is

   -------------
   -- Id_Data --
   -------------

   function Id_Data (This : Wp_Customize_Partial)
                     return Array_Type
   is
   begin
      return This.M_Id_Data;
   end Id_Data;

end Cust_Class_Wp_Customize_Partials;
