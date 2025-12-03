--
-- WordPress Customize Control classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.4.0
--

with Hb_Common;
with Php;

with Inc_Class_Wp_Customize_Managers;

package body Inc_Class_Wp_Customize_Controls
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
             (Manager : access Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager;
              Id      : String;
              Args    : Array_Type := Empty_Array)
              return Wp_Customize_Control
   is
      use Hb_Common;
      use Php;

      This : Wp_Customize_Control;
--    Keys : List_Type := Array_Keys (Get_Object_Vars (This));
   begin
      -- for Key of Keys loop
      --    if Isset (Args, Key) then
      --       This.Key := Get (Args, Key);
      --    end if;
      -- end loop;

      This.Manager := Manager;
      This.Id      := +Id;

      if This.Active_Callback = null then
--    if Empty (This.Active_Callback) then
         This.Active_Callback := Active_Callback'Access;
--       This.Active_Callback := To_Array (This, "active_callback");
      end if;

      Instance_Count := Instance_Count + 1; -- self::
      This.Instance_Number := Instance_Count;  -- self::

      -- Process settings.
      -- if not Isset (This.Settings) then
      --    This.Settings := Id;
      -- end if;

      declare
         Settings : Array_Type;
      begin
         if Is_Array (This.Settings) then
            for A in This.Settings.Iterate loop
               declare
                  Key     : constant String := Arrays.Key (A);
                  Setting : constant String := As_String (Arrays.Element (A));
               begin
                  null;
--                Set (Settings, Key, This.Manager.Get_Setting (Setting));
               end;
            end loop;
--         elsif Is_String (This.Settings) then
--            This.Setting       := This.Manager.Get_Setting (This.Settings);
--            Set (Settings, "default", This.Setting);
         end if;
         This.Settings := Settings;
      end;
      return This;
   end X_Construct;

   ---------------------
   -- Active_Callback --
   ---------------------

   function Active_Callback (This : Wp_Customize_Control)
                             return Boolean
   is
   begin
      return True;
   end Active_Callback;

end Inc_Class_Wp_Customize_Controls;
