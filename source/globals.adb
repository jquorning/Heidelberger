--
--
--

with Inc_Script_Loader;

package body Globals
is

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
   is
   begin
      Global_Wp_Scripts := Class_Scripts.X_Construct;
      Inc_Script_Loader.Wp_Default_Scripts (Global_Wp_Scripts);

      Global_Wp_Styles := Class_Styles.X_Construct;
      Inc_Script_Loader.Wp_Default_Styles (Global_Wp_Styles);
   end Initialize;

end Globals;
