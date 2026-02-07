--
-- Upgrader API: WP_Upgrader_Skin class
--
-- @package WordPress
-- @subpackage Upgrader
-- @since 4.6.0
--

with Array_Lists;

with Inc_Functions;

package body Adi_Class_Wp_Upgrader_Skins
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_Upgrader_Skin
   is
      use Array_Lists;
      use Inc_Functions;

      This : Wp_Upgrader_Skin;

      Defaults : constant Array_Type := To_Array_Type ([
        Build ("url",     ""),
        Build ("nonce",   ""),
        Build ("title",   ""),
        Build ("context", False)
      ]);
   begin
      This.Options := Wp_Parse_Args (Args, Defaults);
      return This;
   end X_Construct;

   ------------------
   -- Set_Upgrader --
   ------------------

   procedure Set_Upgrader (This     : in out Wp_Upgrader_Skin;
                           Upgrader : access Adi_Class_Wp_Upgraders.Wp_Upgrader)
   is
   begin
--    if Is_Object (Upgrader) then
         This.Upgrader := Upgrader; -- &
--    end if;
      This.Add_Strings;
   end Set_Upgrader;

end Adi_Class_Wp_Upgrader_Skins;
