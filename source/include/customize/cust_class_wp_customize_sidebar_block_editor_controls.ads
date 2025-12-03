--
-- Customize API: WP_Sidebar_Block_Editor_Control class.
--
-- @package WordPress
-- @subpackage Customize
-- @since 5.8.0
--

with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wp_Customize_Controls;

limited with Inc_Class_Wp_Customize_Managers;

package Cust_Class_Wp_Customize_Sidebar_Block_Editor_Controls
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- Core class used to implement the widgets block editor control in the
   -- customizer.
   --
   -- @since 5.8.0
   --
   -- @see WP_Customize_Control
   --
   type Wp_Sidebar_Block_Editor_Control is
      new Inc_Class_Wp_Customize_Controls.Wp_Customize_Control with
      record
         --
         -- The control type.
         --
         -- @since 5.8.0
         --
         -- @var string
         --
         Typ : Unbounded_String := To_Unbounded_String ("sidebar_block_editor");
      end record;

   function X_Construct
              (Manager : access Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager;
               Id      : String;
               Args    : Array_Type := Empty_Array)
               return Wp_Sidebar_Block_Editor_Control;
        -- --
        -- -- Render the widgets block editor container.
        -- --
        -- -- @since 5.8.0
        -- --
        -- public function render_content() then
        --         // Render an empty control. The JavaScript in
        --         // @wordpress/customize-widgets will do the rest.
        -- end;

end Cust_Class_Wp_Customize_Sidebar_Block_Editor_Controls;
