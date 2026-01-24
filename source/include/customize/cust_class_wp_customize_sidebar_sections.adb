--
-- Customize API: WP_Customize_Sidebar_Section class
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.4.0
--

package body Cust_Class_Wp_Customize_Sidebar_Sections
is

   -----------------
   -- X_Construct --
   -----------------

   overriding
   function X_Construct
              (Manager : access Class_Customize_Managers.Wp_Customize_Manager;
               Id      : String;
               Args    : Array_Type := Empty_Array)
               return Wp_Customize_Sidebar_Section
   is
   begin
      return
        (Class_Customize_Sections.X_Construct (Manager, Id, Args)
         with
           Typ        => <>,
           Sidebar_Id => <>);
   end X_Construct;

end Cust_Class_Wp_Customize_Sidebar_Sections;
