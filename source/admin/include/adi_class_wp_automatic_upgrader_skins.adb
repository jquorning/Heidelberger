--
-- Upgrader API: Automatic_Upgrader_Skin class
--
-- @package WordPress
-- @subpackage Upgrader
-- @since 4.6.0
--

package body Adi_Class_Wp_Automatic_Upgrader_Skins
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Args : Array_Type := Empty_Array)
                         return Automatic_Upgrader_Skin
   is
      This : Automatic_Upgrader_Skin;
   begin
      return This;
   end X_Construct;

end Adi_Class_Wp_Automatic_Upgrader_Skins;
