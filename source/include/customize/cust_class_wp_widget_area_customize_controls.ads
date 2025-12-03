--
-- Customize API: WP_Widget_Area_Customize_Control class
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.4.0
--

with Inc_Class_Wp_Customize_Controls;

package Cust_Class_Wp_Widget_Area_Customize_Controls
is

   --
   -- Widget Area Customize Control class.
   --
   -- @since 3.9.0
   --
   -- @see WP_Customize_Control
   --
   type Wp_Widget_Area_Customize_Control is
      new Inc_Class_Wp_Customize_Controls.Wp_Customize_Control with
      record
         --
         -- Customize control type.
         --
         -- @since 3.9.0
         -- @var string
         --
--         public type = "sidebar_widgets";

         --
         -- Sidebar ID.
         --
         -- @since 3.9.0
         -- @var int|string
         --
--         public sidebar_id;

         null;
      end record;

        -- --
        -- -- Refreshes the parameters passed to the JavaScript via JSON.
        -- --
        -- -- @since 3.9.0
        -- --
        -- public function to_json() then
        --         parent::to_json();
        --         exported_properties = array( "sidebar_id" );
        --         foreach ( exported_properties as key ) then
        --                 this.json[ key ] = this.key;
        --         end;
        -- end;

        -- --
        -- -- Renders the control"s content.
        -- --
        -- -- @since 3.9.0
        -- --
        -- public function render_content() then
        --         id = "reorder-widgets-desc-" . str_replace( array( "[", "]" ), array( "-", "" ), this.id );
        --         ?>
        --         <button type="button" class="button add-new-widget" aria-expanded="false" aria-controls="available-widgets">
        --                 <?php _e( "Add a Widget" ); ?>
        --         </button>
        --         <button type="button" class="button-link reorder-toggle" aria-label="<?php esc_attr_e( "Reorder widgets" ); ?>" aria-describedby="<?php echo esc_attr( id ); ?>">
        --                 <span class="reorder"><?php _e( "Reorder" ); ?></span>
        --                 <span class="reorder-done"><?php _e( "Done" ); ?></span>
        --         </button>
        --         <p class="screen-reader-text" id="<?php echo esc_attr( id ); ?>"><?php _e( "When in reorder mode, additional controls to reorder widgets will be available in the widgets list above." ); ?></p>
        --         <?php
        -- end;

end Cust_Class_Wp_Widget_Area_Customize_Controls;
