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

      Set (Wp_Locale.Number_Format, "thousands_sep", From_String (","));
      Set (Wp_Locale.Number_Format, "decimal_point", From_String ("."));
   end Initialize;

end Globals;
