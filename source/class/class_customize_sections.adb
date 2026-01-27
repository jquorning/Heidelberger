--
-- WordPress Customize Section classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.4.0
--

package body Class_Customize_Sections
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
             (Manager : access Class_Customize_Managers.Wp_Customize_Manager;
              Id      : String;
              Args    : Array_Type := Empty_Array)
              return Wp_Customize_Section
   is
      use UStrings;

      This : Wp_Customize_Section;
--    Keys : List_Type := Array_Keys (Get_Object_Vars (This));
   begin
      -- for Key of Keys loop
      --    if Isset (Args, Key) then
      --       Set (This, Key, Get (Args, Key));
      --    end if;
      -- end loop;

      This.Manager := Manager;
      This.Id      := +Id;

      if This.Active_Callback = null then
--    if Empty (This.Active_Callback) then
         This.Active_Callback := Active_Callback'Access;
--       This.Active_Callback := array( this, "active_callback" );
      end if;

      Instance_Count := Instance_Count + 1;
      This.Instance_Number := Instance_Count; -- self::

      This.Controls := Empty_Array; -- Users cannot customize the controls array.

      return This;
   end X_Construct;

   ---------------------
   -- Active_Callback --
   ---------------------

   function Active_Callback (This : Wp_Customize_Section)
                             return Boolean
   is
   begin
      return True;
   end Active_Callback;

end Class_Customize_Sections;
