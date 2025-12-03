--
-- Blocks API: WP_Block_Editor_Context class
--
-- @package WordPress
-- @since 5.8.0
--

with Hb_Common;

package body Inc_Class_Wp_Block_Editor_Contexts
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Settings : Array_Type := Empty_Array)
                         return Wp_Block_Editor_Context
   is
      use Hb_Common;

      This : Wp_Block_Editor_Context;
   begin
      if Isset (Settings, "name") then
         This.Name := +As_String (Get (Settings, "name"));
      end if;

      if Isset (Settings, "post") then
         This.Post := null; -- +As_String (Get (Settings, "post"));
      end if;

      return This;
   end X_Construct;

end Inc_Class_Wp_Block_Editor_Contexts;
