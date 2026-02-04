--
--
--

package body Globals
is

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
   is
   begin
      Global_Wp_Scripts := Class_Scripts.X_Construct;
      Global_Wp_Styles  := Class_Styles.X_Construct;
   end Initialize;

end Globals;
