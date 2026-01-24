--
-- Customize API: WP_Widget_Form_Customize_Control class
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.4.0
--

with Class_Customize_Controls;

package Cust_Class_Wp_Widget_Form_Customize_Controls
is

   --
   -- Widget Form Customize Control class.
   --
   -- @since 3.9.0
   --
   -- @see WP_Customize_Control
   --
   type Wp_Widget_Form_Customize_Control is
      new Class_Customize_Controls.Wp_Customize_Control with
      record
         --
         -- Customize control type.
         --
         -- @since 3.9.0
         -- @var string
         --
--         public type = "widget_form";

         --
         -- Widget ID.
         --
         -- @since 3.9.0
         -- @var string
         --
--         public widget_id;

         --
         -- Widget ID base.
         --
         -- @since 3.9.0
         -- @var string
         --
--         public widget_id_base;

         --
         -- Sidebar ID.
         --
         -- @since 3.9.0
         -- @var string
         --
--         public sidebar_id;

         --
         -- Widget status.
         --
         -- @since 3.9.0
         -- @var bool True if new, false otherwise. Default false.
         --
--         public is_new = false;

         --
         -- Widget width.
         --
         -- @since 3.9.0
         -- @var int
         --
--         public width;

         --
         -- Widget height.
         --
         -- @since 3.9.0
         -- @var int
         --
--         public height;

         --
         -- Widget mode.
         --
         -- @since 3.9.0
         -- @var bool True if wide, false otherwise. Default false.
         --
--         public is_wide = false;

         null;
      end record;

        -- --
        -- -- Gather control params for exporting to JavaScript.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @global array wp_registered_widgets
        -- --
        -- public function to_json() then
        --         global wp_registered_widgets;

        --         parent::to_json();
        --         exported_properties = array( "widget_id", "widget_id_base", "sidebar_id", "width", "height", "is_wide" );
        --         foreach ( exported_properties as key ) then
        --                 this.json[ key ] = this.key;
        --         end;

        --         // Get the widget_control and widget_content.
        --         require_once ABSPATH . "wp-admin/includes/widgets.php";

        --         widget = wp_registered_widgets[ this.widget_id ];
        --         if ( ! isset( widget["params"][0] ) ) then
        --                 widget["params"][0] = array();
        --         end;

        --         args = array(
        --                 "widget_id"   => widget["id"],
        --                 "widget_name" => widget["name"],
        --         );

        --         args                 = wp_list_widget_controls_dynamic_sidebar(
        --                 array(
        --                         0 => args,
        --                         1 => widget["params"][0],
        --                 )
        --         );
        --         widget_control_parts = this.manager.widgets.get_widget_control_parts( args );

        --         this.json["widget_control"] = widget_control_parts["control"];
        --         this.json["widget_content"] = widget_control_parts["content"];
        -- end;

        -- --
        -- -- Override render_content to be no-op since content is exported via to_json for deferred embedding.
        -- --
        -- -- @since 3.9.0
        -- --
        -- public function render_content() thenend;

        -- --
        -- -- Whether the current widget is rendered on the page.
        -- --
        -- -- @since 4.0.0
        -- --
        -- -- @return bool Whether the widget is rendered.
        -- --
        -- public function active_callback() then
        --         return this.manager.widgets.is_widget_rendered( this.widget_id );
        -- end;

end Cust_Class_Wp_Widget_Form_Customize_Controls;
