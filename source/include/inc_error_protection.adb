--
-- Error Protection API: Functions
--
-- @package WordPress
-- @since 5.2.0
--

package body Inc_Error_Protection
is

   Static_Storage : Class_Paused_Extensions_Storages.Wp_Paused_Extensions_Storage :=
     Class_Paused_Extensions_Storages.Null_Paused_Extensions_Storage;

   ----------------------
   -- Wp_Paused_Themes --
   ----------------------

   function Wp_Paused_Themes
            return Class_Paused_Extensions_Storages.Wp_Paused_Extensions_Storage
   is
      use Class_Paused_Extensions_Storages;
   begin
      if Static_Storage = Null_Paused_Extensions_Storage then
         Static_Storage := Wp_Paused_Extensions_Storage'(X_Construct ("theme"));
      end if;

      return Static_Storage;
   end Wp_Paused_Themes;

   Static_Wp_Recovery_Mode : Class_Recovery_Mode.Wp_Recovery_Mode;

   ------------------------
   -- X_Wp_Recovery_Mode --
   ------------------------

   function X_Wp_Recovery_Mode
            return Class_Recovery_Mode.Wp_Recovery_Mode
   is
      use Class_Recovery_Mode;
   begin
      if Static_Wp_Recovery_Mode = Null_Recovery_Mode then
         Static_Wp_Recovery_Mode := Wp_Recovery_Mode'(Default_Recovery_Mode);
      end if;

      return Static_Wp_Recovery_Mode;
   end X_Wp_Recovery_Mode;

end Inc_Error_Protection;
