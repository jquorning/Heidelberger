--
-- WordPress Customize Panel classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.0.0
--

with Arrays;
with UStrings;

limited with Class_Customize_Managers;

package Class_Customize_Panels
is
   use Arrays;

   --
   -- Customize Panel class.
   --
   -- A UI container for sections, managed by the WP_Customize_Manager.
   --
   -- @since 4.0.0
   --
   -- @see WP_Customize_Manager
   --
   -- #[AllowDynamicProperties]
   type Wp_Customize_Panel is tagged
      record
         --
         -- Order in which this instance was created in relation to other instances.
         --
         -- @since 4.1.0
         -- @var int
         --
         Instance_Number : Natural;

         --
         -- WP_Customize_Manager instance.
         --
         -- @since 4.0.0
         -- @var WP_Customize_Manager
         --
         Manager : access Class_Customize_Managers.Wp_Customize_Manager;

         --
         -- Unique identifier.
         --
         -- @since 4.0.0
         -- @var string
         --
         Id : UStrings.UString;

         --
         -- Priority of the panel, defining the display order of panels and sections.
         --
         -- @since 4.0.0
         -- @var int
         --
--         public priority = 160;

         --
         -- Capability required for the panel.
         --
         -- @since 4.0.0
         -- @var string
         --
--         public capability = "edit_theme_options";

         --
         -- Theme features required to support the panel.
         --
         -- @since 4.0.0
         -- @var mixed[]
         --
--         public theme_supports = "";

         --
         -- Title of the panel to show in UI.
         --
         -- @since 4.0.0
         -- @var string
         --
         Title : UStrings.UString;

         --
         -- Description to show in the UI.
         --
         -- @since 4.0.0
         -- @var string
         --
--         public description = "";

         --
         -- Auto-expand a section in a panel when the panel is expanded when the panel
         -- only has the one section.
         --
         -- @since 4.7.4
         -- @var bool
         --
--         public auto_expand_sole_section = false;

         --
         -- Customizer sections for this panel.
         --
         -- @since 4.0.0
         -- @var array
         --
         Sections : Array_Type;

         --
         -- Type of this panel.
         --
         -- @since 4.1.0
         -- @var string
         --
--         public type = "default";

         --
         -- Active callback.
         --
         -- @since 4.1.0
         --
         -- @see WP_Customize_Section::active()
         --
         -- @var callable Callback is called with one argument, the instance of
         --               WP_Customize_Section, and returns bool to indicate whether
         --               the section is active (such as it relates to the URL
         --               currently being previewed).
         --
         Active_Callback : access Integer := null; --  = "";

      end record;

   --
   -- Constructor.
   --
   -- Any supplied args override class property defaults.
   --
   -- @since 4.0.0
   --
   -- @param WP_Customize_Manager manager Customizer bootstrap instance.
   -- @param string               id      A specific ID for the panel.
   -- @param array                args    {
   --     Optional. Array of properties for the new Panel object. Default empty array.
   --
   --     @type int             priority        Priority of the panel, defining the
   --                                            display order of panels and sections.
   --                                            Default 160.
   --     @type string          capability      Capability required for the panel.
   --                                            Default `edit_theme_options`.
   --     @type mixed[]         theme_supports  Theme features required to support
   --                                            the panel.
   --     @type string          title           Title of the panel to show in UI.
   --     @type string          description     Description to show in the UI.
   --     @type string          type            Type of the panel.
   --     @type callable        active_callback Active callback.
   -- }
   --
   function X_Construct
              (Manager : access Class_Customize_Managers.Wp_Customize_Manager;
               Id      : String;
               Args    : Array_Type := Empty_Array)
               return Wp_Customize_Panel;

--         --
--         -- Check whether panel is active to current Customizer preview.
--         --
--         -- @since 4.1.0
--         --
--         -- @return bool Whether the panel is active to the current preview.
--         --
--         final public function active() then
--                 panel  = this;
--                 active = call_user_func( this.active_callback, this );

--                 --
--                 -- Filters response of WP_Customize_Panel::active().
--                 --
--                 -- @since 4.1.0
--                 --
--                 -- @param bool               active Whether the Customizer panel is active.
--                 -- @param WP_Customize_Panel panel  WP_Customize_Panel instance.
--                 --
--                 active = apply_filters( "customize_panel_active", active, panel );

--                 return active;
--         end;

--         --
--         -- Default callback used when invoking WP_Customize_Panel::active().
--         --
--         -- Subclasses can override this with their specific logic, or they may
--         -- provide an "active_callback" argument to the constructor.
--         --
--         -- @since 4.1.0
--         --
--         -- @return bool Always true.
--         --
--         public function active_callback() then
--                 return true;
--         end;

--         --
--         -- Gather the parameters passed to client JavaScript via JSON.
--         --
--         -- @since 4.1.0
--         --
--         -- @return array The array to be exported to the client as JSON.
--         --
--         public function json() then
--                 array                          = wp_array_slice_assoc( (array) this, array( "id", "description", "priority", "type" ) );
--                 array["title"]                 = html_entity_decode( this.title, ENT_QUOTES, get_bloginfo( "charset" ) );
--                 array["content"]               = this.get_content();
--                 array["active"]                = this.active();
--                 array["instanceNumber"]        = this.instance_number;
--                 array["autoExpandSoleSection"] = this.auto_expand_sole_section;
--                 return array;
--         end;

--         --
--         -- Checks required user capabilities and whether the theme has the
--         -- feature support required by the panel.
--         --
--         -- @since 4.0.0
--         -- @since 5.9.0 Method was marked non-final.
--         --
--         -- @return bool False if theme doesn"t support the panel or the user doesn"t have the capability.
--         --
--         public function check_capabilities() then
--                 if ( this.capability && ! current_user_can( this.capability ) ) then
--                         return false;
--                 end;

--                 if ( this.theme_supports && ! current_theme_supports( ... (array) this.theme_supports ) ) then
--                         return false;
--                 end;

--                 return true;
--         end;

--         --
--         -- Get the panel"s content template for insertion into the Customizer pane.
--         --
--         -- @since 4.1.0
--         --
--         -- @return string Content for the panel.
--         --
--         final public function get_content() then
--                 ob_start();
--                 this.maybe_render();
--                 return trim( ob_get_clean() );
--         end;

--         --
--         -- Check capabilities and render the panel.
--         --
--         -- @since 4.0.0
--         --
--         final public function maybe_render() then
--                 if ( ! this.check_capabilities() ) then
--                         return;
--                 end;

--                 --
--                 -- Fires before rendering a Customizer panel.
--                 --
--                 -- @since 4.0.0
--                 --
--                 -- @param WP_Customize_Panel panel WP_Customize_Panel instance.
--                 --
--                 do_action( "customize_render_panel", this );

--                 --
--                 -- Fires before rendering a specific Customizer panel.
--                 --
--                 -- The dynamic portion of the hook name, `this.id`, refers to
--                 -- the ID of the specific Customizer panel to be rendered.
--                 --
--                 -- @since 4.0.0
--                 --
--                 do_action( "customize_render_panel_thenthis.idend;" );

--                 this.render();
--         end;

--         --
--         -- Render the panel container, and then its contents (via `this.render_content()`) in a subclass.
--         --
--         -- Panel containers are now rendered in JS by default, see WP_Customize_Panel::print_template().
--         --
--         -- @since 4.0.0
--         --
--         protected function render() thenend;

--         --
--         -- Render the panel UI in a subclass.
--         --
--         -- Panel contents are now rendered in JS by default, see WP_Customize_Panel::print_template().
--         --
--         -- @since 4.1.0
--         --
--         protected function render_content() thenend;

--         --
--         -- Render the panel"s JS templates.
--         --
--         -- This function is only run for panel types that have been registered with
--         -- WP_Customize_Manager::register_panel_type().
--         --
--         -- @since 4.3.0
--         --
--         -- @see WP_Customize_Manager::register_panel_type()
--         --
--         public function print_template() then
--                 ?>
--                 <script type="text/html" id="tmpl-customize-panel-<?php echo esc_attr( this.type ); ?>-content">
--                         <?php this.content_template(); ?>
--                 </script>
--                 <script type="text/html" id="tmpl-customize-panel-<?php echo esc_attr( this.type ); ?>">
--                         <?php this.render_template(); ?>
--                 </script>
--                 <?php
--         end;

--         --
--         -- An Underscore (JS) template for rendering this panel"s container.
--         --
--         -- Class variables for this panel class are available in the `data` JS object;
--         -- export custom variables by overriding WP_Customize_Panel::json().
--         --
--         -- @see WP_Customize_Panel::print_template()
--         --
--         -- @since 4.3.0
--         --
--         protected function render_template() then
--                 ?>
--                 <li id="accordion-panel-thenthen data.id end;end;" class="accordion-section control-section control-panel control-panel-thenthen data.type end;end;">
--                         <h3 class="accordion-section-title" tabindex="0">
--                                 thenthen data.title end;end;
--                                 <span class="screen-reader-text"><?php _e( "Press return or enter to open this panel" ); ?></span>
--                         </h3>
--                         <ul class="accordion-sub-container control-panel-content"></ul>
--                 </li>
--                 <?php
--         end;

--         --
--         -- An Underscore (JS) template for this panel"s content (but not its container).
--         --
--         -- Class variables for this panel class are available in the `data` JS object;
--         -- export custom variables by overriding WP_Customize_Panel::json().
--         --
--         -- @see WP_Customize_Panel::print_template()
--         --
--         -- @since 4.3.0
--         --
--         protected function content_template() then
--                 ?>
--                 <li class="panel-meta customize-info accordion-section <# if ( ! data.description ) then #> cannot-expand<# end; #>">
--                         <button class="customize-panel-back" tabindex="-1"><span class="screen-reader-text"><?php _e( "Back" ); ?></span></button>
--                         <div class="accordion-section-title">
--                                 <span class="preview-notice">
--                                 <?php
--                                         /* translators: %s: The site/panel title in the Customizer.--
--                                         printf( __( "You are customizing %s" ), "<strong class="panel-title">thenthen data.title end;end;</strong>" );
--                                 ?>
--                                 </span>
--                                 <# if ( data.description ) then #>
--                                         <button type="button" class="customize-help-toggle dashicons dashicons-editor-help" aria-expanded="false"><span class="screen-reader-text"><?php _e( "Help" ); ?></span></button>
--                                 <# end; #>
--                         </div>
--                         <# if ( data.description ) then #>
--                                 <div class="description customize-panel-description">
--                                         thenthenthen data.description end;end;end;
--                                 </div>
--                         <# end; #>

--                         <div class="customize-control-notifications-container"></div>
--                 </li>
--                 <?php
--         end;

   Null_Panel : constant Wp_Customize_Panel :=
     (Instance_Number => 0,
      Manager         => null,
      Id              => UStrings.Null_UString,
      Title           => UStrings.Null_UString,
      Active_Callback => null,
      Sections        => Empty_Array);

private
   --
   -- Incremented with each new class instantiation, then stored in
   -- instance_number.
   --
   -- Used when sorting two instances whose priorities are equal.
   --
   -- @since 4.1.0
   -- @var int
   --
   Instance_Count : Natural := 0;

end Class_Customize_Panels;

-- -- WP_Customize_Nav_Menus_Panel class--
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menus-panel.php";
