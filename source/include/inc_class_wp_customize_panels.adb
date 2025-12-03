--
-- WordPress Customize Panel classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.0.0
--

with Hb_Common;

with Inc_Class_Wp_Customize_Managers;

package body Inc_Class_Wp_Customize_Panels
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
              (Manager : access Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager;
               Id      : String;
               Args    : Array_Type := Empty_Array)
               return Wp_Customize_Panel
   is
      use Hb_Common;

      This : Wp_Customize_Panel;
--    Keys := Array_Keys (Get_Object_Vars (This));
   begin
      -- for Key of Keys loop
      --    if ( isset( args[ key ] ) ) then
      --       this.key = args[ key ];
      --    end if;
      -- end loop;

      This.Manager := Manager;
      This.Id      := +Id;

--    if Empty (This.Active_Callback) then
--       This.Active_Callback := To_Array (This, "active_callback");
--    end if;

      Instance_Count := Instance_Count + 1;
      This.Instance_Number := Instance_Count;

      This.Sections := Empty_Array;
      -- Users cannot customize the sections array.

      return This;
   end X_Construct;

end Inc_Class_Wp_Customize_Panels;
