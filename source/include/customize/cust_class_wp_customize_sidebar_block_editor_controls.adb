--
-- Customize API: WP_Sidebar_Block_Editor_Control class.
--
-- @package WordPress
-- @subpackage Customize
-- @since 5.8.0
--

package body Cust_Class_Wp_Customize_Sidebar_Block_Editor_Controls
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
              (Manager : access Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager;
               Id      : String;
               Args    : Array_Type := Empty_Array)
               return Wp_Sidebar_Block_Editor_Control
   is
   begin
      return
        (Inc_Class_Wp_Customize_Controls.X_Construct (Manager, Id, Args)
         with Typ => <>);
   end X_Construct;

end Cust_Class_Wp_Customize_Sidebar_Block_Editor_Controls;
