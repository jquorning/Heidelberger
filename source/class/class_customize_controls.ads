--
-- WordPress Customize Control classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.4.0
--

with Ada.Strings.Unbounded;

with Arrays;

limited with Class_Customize_Managers;

package Class_Customize_Controls
is
   use Ada.Strings.Unbounded;
   use Arrays;

   type Wp_Customize_Control;

   type Active_Callback_Type is access function (This : Wp_Customize_Control)
                                                 return Boolean;

   --
   -- Customize Control class.
   --
   -- @since 3.4.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Customize_Control is tagged
      record
         --
         -- Order in which this instance was created in relation to other instances.
         --
         -- @since 4.1.0
         -- @var int
         --
         Instance_Number : Natural;

         --
         -- Customizer manager.
         --
         -- @since 3.4.0
         -- @var WP_Customize_Manager
         --
         Manager : access Class_Customize_Managers.Wp_Customize_Manager;

         --
         -- Control ID.
         --
         -- @since 3.4.0
         -- @var string
         --
         Id : Unbounded_String;

         --
         -- All settings tied to the control.
         --
         -- @since 3.4.0
         -- @var array
         --
         Settings : Array_Type;

         --
         -- The primary setting for the control (if there is one).
         --
         -- @since 3.4.0
         -- @var string|WP_Customize_Setting|null
         --
--         public setting = "default";

         --
         -- Capability required to use this control.
         --
         -- Normally this is empty and the capability is derived from the capabilities
         -- of the associated `settings`.
         --
         -- @since 4.5.0
         -- @var string
         --
--         public capability;

         --
         -- Order priority to load the control in Customizer.
         --
         -- @since 3.4.0
         -- @var int
         --
--         public priority = 10;

         --
         -- Section the control belongs to.
         --
         -- @since 3.4.0
         -- @var string
         --
--         public section = "";

         --
         -- Label for the control.
         --
         -- @since 3.4.0
         -- @var string
         --
--         public label = "";

         --
         -- Description for the control.
         --
         -- @since 4.0.0
         -- @var string
         --
--         public description = "";

         --
         -- List of choices for "radio" or "select" type controls, where values are the keys, and labels are the values.
         --
         -- @since 3.4.0
         -- @var array
         --
--         public choices = array();

         --
         -- List of custom input attributes for control output, where attribute names are the keys and values are the values.
         --
         -- Not used for "checkbox", "radio", "select", "textarea", or "dropdown-pages" control types.
         --
         -- @since 4.0.0
         -- @var array
         --
--         public input_attrs = array();

         --
         -- Show UI for adding new content, currently only used for the dropdown-pages control.
         --
         -- @since 4.7.0
         -- @var bool
         --
--         public allow_addition = false;

         --
         -- @deprecated It is better to just call the json() method
         -- @since 3.4.0
         -- @var array
         --
--         public json = array();

         --
         -- Control"s Type.
         --
         -- @since 3.4.0
         -- @var string
         --
--         public type = "text";

         --
         -- Callback.
         --
         -- @since 4.0.0
         --
         -- @see WP_Customize_Control::active()
         --
         -- @var callable Callback is called with one argument, the instance of
         --               WP_Customize_Control, and returns bool to indicate whether
         --               the control is active (such as it relates to the URL
         --               currently being previewed).
         --
         Active_Callback : Active_Callback_Type := null; -- Callable; --  = "";

      end record;

   --
   -- Constructor.
   --
   -- Supplied `args` override class property defaults.
   --
   -- If `args["settings"]` is not defined, use the `id` as the setting ID.
   --
   -- @since 3.4.0
   --
   -- @param WP_Customize_Manager manager Customizer bootstrap instance.
   -- @param string               id      Control ID.
   -- @param array                args    {
   --     Optional. Array of properties for the new Control object. Default empty array.
   --
   --     @type int                  instance_number Order in which this instance was
   --                                                 created in relation to other
   --                                                 instances.
   --     @type WP_Customize_Manager manager         Customizer bootstrap instance.
   --     @type string               id              Control ID.
   --     @type array                settings        All settings tied to the control.
   --                                                 If undefined, `id` will be used.
   --     @type string               setting         The primary setting for the
   --                                                 control (if there is one).
   --                                                 Default "default".
   --     @type string               capability      Capability required to use this
   --                                                 control. Normally this is empty
   --                                                 and the capability is derived
   --                                                 from `settings`.
   --     @type int                  priority        Order priority to load the
   --                                                control. Default 10.
   --     @type string               section         Section the control belongs to.
   --                                                 Default empty.
   --     @type string               label           Label for the control. Default
   --                                                 empty.
   --     @type string               description     Description for the control.
   --                                                 Default empty.
   --     @type array                choices         List of choices for "radio" or
   --                                                 "select" type controls, where
   --                                                 values are the keys, and labels
   --                                                 are the values.
   --                                                 Default empty array.
   --     @type array                input_attrs     List of custom input attributes
   --                                                 for control output, where
   --                                                 attribute names are the keys and
   --                                                 values are the values. Not
   --                                                 used for "checkbox", "radio",
   --                                                 "select", "textarea", or
   --                                                 "dropdown-pages" control types.
   --                                                 Default empty array.
   --     @type bool                 allow_addition  Show UI for adding new content,
   --                                                 currently only used for the
   --                                                 dropdown-pages control. Default
   --                                                 false.
   --     @type array                json            Deprecated. Use
   --                                                 WP_Customize_Control::json()
   --                                                 instead.
   --     @type string               type            Control type. Core controls
   --                                                 include "text", "checkbox",
   --                                                 "textarea", "radio", "select",
   --                                                 and "dropdown-pages". Additional
   --                                                 input types such as "email",
   --                                                 "url", "number", "hidden", and
   --                                                 "date" are supported implicitly.
   --                                                 Default "text".
   --     @type callable             active_callback Active callback.
   -- }
   --
   function X_Construct
             (Manager : access Class_Customize_Managers.Wp_Customize_Manager;
              Id      : String;
              Args    : Array_Type := Empty_Array)
              return Wp_Customize_Control;
        --         keys = array_keys( get_object_vars( this ) );
        --         foreach ( keys as key ) then
        --                 if ( isset( args[ key ] ) ) then
        --                         this.key = args[ key ];
        --                 end;
        --         end;

        --         this.manager = manager;
        --         this.id      = id;
        --         if ( empty( this.active_callback ) ) then
        --                 this.active_callback = array( this, "active_callback" );
        --         end;
        --         self::instance_count += 1;
        --         this.instance_number = self::instance_count;

        --         // Process settings.
        --         if ( ! isset( this.settings ) ) then
        --                 this.settings = id;
        --         end;

        --         settings = array();
        --         if ( is_array( this.settings ) ) then
        --                 foreach ( this.settings as key => setting ) then
        --                         settings[ key ] = this.manager.get_setting( setting );
        --                 end;
        --         end; elseif ( is_string( this.settings ) ) then
        --                 this.setting       = this.manager.get_setting( this.settings );
        --                 settings["default"] = this.setting;
        --         end;
        --         this.settings = settings;
        -- end;

        -- --
        -- -- Enqueue control related scripts/styles.
        -- --
        -- -- @since 3.4.0
        -- --
        -- public function enqueue() thenend;

        -- --
        -- -- Check whether control is active to current Customizer preview.
        -- --
        -- -- @since 4.0.0
        -- --
        -- -- @return bool Whether the control is active to the current preview.
        -- --
        -- final public function active() then
        --         control = this;
        --         active  = call_user_func( this.active_callback, this );

        --         --
        --         -- Filters response of WP_Customize_Control::active().
        --         --
        --         -- @since 4.0.0
        --         --
        --         -- @param bool                 active  Whether the Customizer control is active.
        --         -- @param WP_Customize_Control control WP_Customize_Control instance.
        --         --
        --         active = apply_filters( "customize_control_active", active, control );

        --         return active;
        -- end;

   --
   -- Default callback used when invoking WP_Customize_Control::active().
   --
   -- Subclasses can override this with their specific logic, or they may
   -- provide an "active_callback" argument to the constructor.
   --
   -- @since 4.0.0
   --
   -- @return true Always true.
   --
   function Active_Callback (This : Wp_Customize_Control)
                             return Boolean;
        --         return true;
        -- end;

        -- --
        -- -- Fetch a setting"s value.
        -- -- Grabs the main setting by default.
        -- --
        -- -- @since 3.4.0
        -- --
        -- -- @param string setting_key
        -- -- @return mixed The requested setting"s value, if the setting exists.
        -- --
        -- final public function value( setting_key = "default" ) then
        --         if ( isset( this.settings[ setting_key ] ) ) then
        --                 return this.settings[ setting_key ].value();
        --         end;
        -- end;

        -- --
        -- -- Refresh the parameters passed to the JavaScript via JSON.
        -- --
        -- -- @since 3.4.0
        -- --
        -- public function to_json() then
        --         this.json["settings"] = array();
        --         foreach ( this.settings as key => setting ) then
        --                 this.json["settings"][ key ] = setting.id;
        --         end;

        --         this.json["type"]           = this.type;
        --         this.json["priority"]       = this.priority;
        --         this.json["active"]         = this.active();
        --         this.json["section"]        = this.section;
        --         this.json["content"]        = this.get_content();
        --         this.json["label"]          = this.label;
        --         this.json["description"]    = this.description;
        --         this.json["instanceNumber"] = this.instance_number;

        --         if ( "dropdown-pages" === this.type ) then
        --                 this.json["allow_addition"] = this.allow_addition;
        --         end;
        -- end;

        -- --
        -- -- Get the data to export to the client via JSON.
        -- --
        -- -- @since 4.1.0
        -- --
        -- -- @return array Array of parameters passed to the JavaScript.
        -- --
        -- public function json() then
        --         this.to_json();
        --         return this.json;
        -- end;

        -- --
        -- -- Checks if the user can use this control.
        -- --
        -- -- Returns false if the user cannot manipulate one of the associated settings,
        -- -- or if one of the associated settings does not exist. Also returns false if
        -- -- the associated section does not exist or if its capability check returns
        -- -- false.
        -- --
        -- -- @since 3.4.0
        -- --
        -- -- @return bool False if theme doesn"t support the control or user doesn"t have the required permissions, otherwise true.
        -- --
        -- final public function check_capabilities() then
        --         if ( ! empty( this.capability ) && ! current_user_can( this.capability ) ) then
        --                 return false;
        --         end;

        --         foreach ( this.settings as setting ) then
        --                 if ( ! setting || ! setting.check_capabilities() ) then
        --                         return false;
        --                 end;
        --         end;

        --         section = this.manager.get_section( this.section );
        --         if ( isset( section ) && ! section.check_capabilities() ) then
        --                 return false;
        --         end;

        --         return true;
        -- end;

        -- --
        -- -- Get the control"s content for insertion into the Customizer pane.
        -- --
        -- -- @since 4.1.0
        -- --
        -- -- @return string Contents of the control.
        -- --
        -- final public function get_content() then
        --         ob_start();
        --         this.maybe_render();
        --         return trim( ob_get_clean() );
        -- end;

        -- --
        -- -- Check capabilities and render the control.
        -- --
        -- -- @since 3.4.0
        -- -- @uses WP_Customize_Control::render()
        -- --
        -- final public function maybe_render() then
        --         if ( ! this.check_capabilities() ) then
        --                 return;
        --         end;

        --         --
        --         -- Fires just before the current Customizer control is rendered.
        --         --
        --         -- @since 3.4.0
        --         --
        --         -- @param WP_Customize_Control control WP_Customize_Control instance.
        --         --
        --         do_action( "customize_render_control", this );

        --         --
        --         -- Fires just before a specific Customizer control is rendered.
        --         --
        --         -- The dynamic portion of the hook name, `this.id`, refers to
        --         -- the control ID.
        --         --
        --         -- @since 3.4.0
        --         --
        --         -- @param WP_Customize_Control control WP_Customize_Control instance.
        --         --
        --         do_action( "customize_render_control_thenthis.idend;", this );

        --         this.render();
        -- end;

        -- --
        -- -- Renders the control wrapper and calls this.render_content() for the internals.
        -- --
        -- -- @since 3.4.0
        -- --
        -- protected function render() then
        --         id    = "customize-control-" . str_replace( array( "[", "]" ), array( "-", "" ), this.id );
        --         class = "customize-control customize-control-" . this.type;

        --         printf( "<li id="%s" class="%s">", esc_attr( id ), esc_attr( class ) );
        --         this.render_content();
        --         echo "</li>";
        -- end;

        -- --
        -- -- Get the data link attribute for a setting.
        -- --
        -- -- @since 3.4.0
        -- -- @since 4.9.0 Return a `data-customize-setting-key-link` attribute if a setting is not registered for the supplied setting key.
        -- --
        -- -- @param string setting_key
        -- -- @return string Data link parameter, a `data-customize-setting-link` attribute if the `setting_key` refers to a pre-registered setting,
        -- --                and a `data-customize-setting-key-link` attribute if the setting is not yet registered.
        -- --
        -- public function get_link( setting_key = "default" ) then
        --         if ( isset( this.settings[ setting_key ] ) && this.settings[ setting_key ] instanceof WP_Customize_Setting ) then
        --                 return "data-customize-setting-link="" . esc_attr( this.settings[ setting_key ].id ) . """;
        --         end; else then
        --                 return "data-customize-setting-key-link="" . esc_attr( setting_key ) . """;
        --         end;
        -- end;

        -- --
        -- -- Render the data link attribute for the control"s input element.
        -- --
        -- -- @since 3.4.0
        -- -- @uses WP_Customize_Control::get_link()
        -- --
        -- -- @param string setting_key
        -- --
        -- public function link( setting_key = "default" ) then
        --         echo this.get_link( setting_key );
        -- end;

        -- --
        -- -- Render the custom attributes for the control"s input element.
        -- --
        -- -- @since 4.0.0
        -- --
        -- public function input_attrs() then
        --         foreach ( this.input_attrs as attr => value ) then
        --                 echo attr . "="" . esc_attr( value ) . "" ";
        --         end;
        -- end;

        -- --
        -- -- Render the control"s content.
        -- --
        -- -- Allows the content to be overridden without having to rewrite the wrapper in `this::render()`.
        -- --
        -- -- Supports basic input types `text`, `checkbox`, `textarea`, `radio`, `select` and `dropdown-pages`.
        -- -- Additional input types such as `email`, `url`, `number`, `hidden` and `date` are supported implicitly.
        -- --
        -- -- Control content can alternately be rendered in JS. See WP_Customize_Control::print_template().
        -- --
        -- -- @since 3.4.0
        -- --
        -- protected function render_content() then
        --         input_id         = "_customize-input-" . this.id;
        --         description_id   = "_customize-description-" . this.id;
        --         describedby_attr = ( ! empty( this.description ) ) ? " aria-describedby="" . esc_attr( description_id ) . "" " : "";
        --         switch ( this.type ) then
        --                 case "checkbox":
        --                         ?>
        --                         <span class="customize-inside-control-row">
        --                                 <input
        --                                         id="<?php echo esc_attr( input_id ); ?>"
        --                                         <?php echo describedby_attr; ?>
        --                                         type="checkbox"
        --                                         value="<?php echo esc_attr( this.value() ); ?>"
        --                                         <?php this.link(); ?>
        --                                         <?php checked( this.value() ); ?>
        --                                 />
        --                                 <label for="<?php echo esc_attr( input_id ); ?>"><?php echo esc_html( this.label ); ?></label>
        --                                 <?php if ( ! empty( this.description ) ) : ?>
        --                                         <span id="<?php echo esc_attr( description_id ); ?>" class="description customize-control-description"><?php echo this.description; ?></span>
        --                                 <?php endif; ?>
        --                         </span>
        --                         <?php
        --                         break;
        --                 case "radio":
        --                         if ( empty( this.choices ) ) then
        --                                 return;
        --                         end;

        --                         name = "_customize-radio-" . this.id;
        --                         ?>
        --                         <?php if ( ! empty( this.label ) ) : ?>
        --                                 <span class="customize-control-title"><?php echo esc_html( this.label ); ?></span>
        --                         <?php endif; ?>
        --                         <?php if ( ! empty( this.description ) ) : ?>
        --                                 <span id="<?php echo esc_attr( description_id ); ?>" class="description customize-control-description"><?php echo this.description; ?></span>
        --                         <?php endif; ?>

        --                         <?php foreach ( this.choices as value => label ) : ?>
        --                                 <span class="customize-inside-control-row">
        --                                         <input
        --                                                 id="<?php echo esc_attr( input_id . "-radio-" . value ); ?>"
        --                                                 type="radio"
        --                                                 <?php echo describedby_attr; ?>
        --                                                 value="<?php echo esc_attr( value ); ?>"
        --                                                 name="<?php echo esc_attr( name ); ?>"
        --                                                 <?php this.link(); ?>
        --                                                 <?php checked( this.value(), value ); ?>
        --                                                 />
        --                                         <label for="<?php echo esc_attr( input_id . "-radio-" . value ); ?>"><?php echo esc_html( label ); ?></label>
        --                                 </span>
        --                         <?php endforeach; ?>
        --                         <?php
        --                         break;
        --                 case "select":
        --                         if ( empty( this.choices ) ) then
        --                                 return;
        --                         end;

        --                         ?>
        --                         <?php if ( ! empty( this.label ) ) : ?>
        --                                 <label for="<?php echo esc_attr( input_id ); ?>" class="customize-control-title"><?php echo esc_html( this.label ); ?></label>
        --                         <?php endif; ?>
        --                         <?php if ( ! empty( this.description ) ) : ?>
        --                                 <span id="<?php echo esc_attr( description_id ); ?>" class="description customize-control-description"><?php echo this.description; ?></span>
        --                         <?php endif; ?>

        --                         <select id="<?php echo esc_attr( input_id ); ?>" <?php echo describedby_attr; ?> <?php this.link(); ?>>
        --                                 <?php
        --                                 foreach ( this.choices as value => label ) then
        --                                         echo "<option value="" . esc_attr( value ) . """ . selected( this.value(), value, false ) . ">" . label . "</option>";
        --                                 end;
        --                                 ?>
        --                         </select>
        --                         <?php
        --                         break;
        --                 case "textarea":
        --                         ?>
        --                         <?php if ( ! empty( this.label ) ) : ?>
        --                                 <label for="<?php echo esc_attr( input_id ); ?>" class="customize-control-title"><?php echo esc_html( this.label ); ?></label>
        --                         <?php endif; ?>
        --                         <?php if ( ! empty( this.description ) ) : ?>
        --                                 <span id="<?php echo esc_attr( description_id ); ?>" class="description customize-control-description"><?php echo this.description; ?></span>
        --                         <?php endif; ?>
        --                         <textarea
        --                                 id="<?php echo esc_attr( input_id ); ?>"
        --                                 rows="5"
        --                                 <?php echo describedby_attr; ?>
        --                                 <?php this.input_attrs(); ?>
        --                                 <?php this.link(); ?>
        --                         ><?php echo esc_textarea( this.value() ); ?></textarea>
        --                         <?php
        --                         break;
        --                 case "dropdown-pages":
        --                         ?>
        --                         <?php if ( ! empty( this.label ) ) : ?>
        --                                 <label for="<?php echo esc_attr( input_id ); ?>" class="customize-control-title"><?php echo esc_html( this.label ); ?></label>
        --                         <?php endif; ?>
        --                         <?php if ( ! empty( this.description ) ) : ?>
        --                                 <span id="<?php echo esc_attr( description_id ); ?>" class="description customize-control-description"><?php echo this.description; ?></span>
        --                         <?php endif; ?>

        --                         <?php
        --                         dropdown_name     = "_customize-dropdown-pages-" . this.id;
        --                         show_option_none  = __( "&mdash; Select &mdash;" );
        --                         option_none_value = "0";
        --                         dropdown          = wp_dropdown_pages(
        --                                 array(
        --                                         "name"              => dropdown_name,
        --                                         "echo"              => 0,
        --                                         "show_option_none"  => show_option_none,
        --                                         "option_none_value" => option_none_value,
        --                                         "selected"          => this.value(),
        --                                 )
        --                         );
        --                         if ( empty( dropdown ) ) then
        --                                 dropdown  = sprintf( "<select id="%1s" name="%1s">", esc_attr( dropdown_name ) );
        --                                 dropdown .= sprintf( "<option value="%1s">%2s</option>", esc_attr( option_none_value ), esc_html( show_option_none ) );
        --                                 dropdown .= "</select>";
        --                         end;

        --                         // Hackily add in the data link parameter.
        --                         dropdown = str_replace( "<select", "<select " . this.get_link() . " id="" . esc_attr( input_id ) . "" " . describedby_attr, dropdown );

        --                         // Even more hacikly add auto-draft page stubs.
        --                         // @todo Eventually this should be removed in favor of the pages being injected into the underlying get_pages() call. See <https://github.com/xwp/wp-customize-posts/pull/250>.
        --                         nav_menus_created_posts_setting = this.manager.get_setting( "nav_menus_created_posts" );
        --                         if ( nav_menus_created_posts_setting && current_user_can( "publish_pages" ) ) then
        --                                 auto_draft_page_options = "";
        --                                 foreach ( nav_menus_created_posts_setting.value() as auto_draft_page_id ) then
        --                                         post = get_post( auto_draft_page_id );
        --                                         if ( post && "page" === post.post_type ) then
        --                                                 auto_draft_page_options .= sprintf( "<option value="%1s">%2s</option>", esc_attr( post.ID ), esc_html( post.post_title ) );
        --                                         end;
        --                                 end;
        --                                 if ( auto_draft_page_options ) then
        --                                         dropdown = str_replace( "</select>", auto_draft_page_options . "</select>", dropdown );
        --                                 end;
        --                         end;

        --                         echo dropdown;
        --                         ?>
        --                         <?php if ( this.allow_addition && current_user_can( "publish_pages" ) && current_user_can( "edit_theme_options" ) ) : // Currently tied to menus functionality. ?>
        --                                 <button type="button" class="button-link add-new-toggle">
        --                                         <?php
        --                                         /* translators: %s: Add New Page label.--
        --                                         printf( __( "+ %s" ), get_post_type_object( "page" ).labels.add_new_item );
        --                                         ?>
        --                                 </button>
        --                                 <div class="new-content-item">
        --                                         <label for="create-input-<?php echo esc_attr( this.id ); ?>"><span class="screen-reader-text"><?php _e( "New page title" ); ?></span></label>
        --                                         <input type="text" id="create-input-<?php echo esc_attr( this.id ); ?>" class="create-item-input" placeholder="<?php esc_attr_e( "New page title&hellip;" ); ?>">
        --                                         <button type="button" class="button add-content"><?php _e( "Add" ); ?></button>
        --                                 </div>
        --                         <?php endif; ?>
        --                         <?php
        --                         break;
        --                 default:
        --                         ?>
        --                         <?php if ( ! empty( this.label ) ) : ?>
        --                                 <label for="<?php echo esc_attr( input_id ); ?>" class="customize-control-title"><?php echo esc_html( this.label ); ?></label>
        --                         <?php endif; ?>
        --                         <?php if ( ! empty( this.description ) ) : ?>
        --                                 <span id="<?php echo esc_attr( description_id ); ?>" class="description customize-control-description"><?php echo this.description; ?></span>
        --                         <?php endif; ?>
        --                         <input
        --                                 id="<?php echo esc_attr( input_id ); ?>"
        --                                 type="<?php echo esc_attr( this.type ); ?>"
        --                                 <?php echo describedby_attr; ?>
        --                                 <?php this.input_attrs(); ?>
        --                                 <?php if ( ! isset( this.input_attrs["value"] ) ) : ?>
        --                                         value="<?php echo esc_attr( this.value() ); ?>"
        --                                 <?php endif; ?>
        --                                 <?php this.link(); ?>
        --                                 />
        --                         <?php
        --                         break;
        --         end;
        -- end;

        -- --
        -- -- Render the control"s JS template.
        -- --
        -- -- This function is only run for control types that have been registered with
        -- -- WP_Customize_Manager::register_control_type().
        -- --
        -- -- In the future, this will also print the template for the control"s container
        -- -- element and be override-able.
        -- --
        -- -- @since 4.1.0
        -- --
        -- final public function print_template() then
        --         ?>
        --         <script type="text/html" id="tmpl-customize-control-<?php echo esc_attr( this.type ); ?>-content">
        --                 <?php this.content_template(); ?>
        --         </script>
        --         <?php
        -- end;

        -- --
        -- -- An Underscore (JS) template for this control"s content (but not its container).
        -- --
        -- -- Class variables for this control class are available in the `data` JS object;
        -- -- export custom variables by overriding WP_Customize_Control::to_json().
        -- --
        -- -- @see WP_Customize_Control::print_template()
        -- --
        -- -- @since 4.1.0
        -- --
        -- protected function content_template() thenend;

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
   -- protected static
   Instance_Count : Natural := 0;

end Class_Customize_Controls;

-- --
-- -- WP_Customize_Color_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-color-control.php";

-- --
-- -- WP_Customize_Media_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-media-control.php";

-- --
-- -- WP_Customize_Upload_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-upload-control.php";

-- --
-- -- WP_Customize_Image_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-image-control.php";

-- --
-- -- WP_Customize_Background_Image_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-background-image-control.php";

-- --
-- -- WP_Customize_Background_Position_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-background-position-control.php";

-- --
-- -- WP_Customize_Cropped_Image_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-cropped-image-control.php";

-- --
-- -- WP_Customize_Site_Icon_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-site-icon-control.php";

-- --
-- -- WP_Customize_Header_Image_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-header-image-control.php";

-- --
-- -- WP_Customize_Theme_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-theme-control.php";

-- --
-- -- WP_Widget_Area_Customize_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-widget-area-customize-control.php";

-- --
-- -- WP_Widget_Form_Customize_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-widget-form-customize-control.php";

-- --
-- -- WP_Customize_Nav_Menu_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-control.php";

-- --
-- -- WP_Customize_Nav_Menu_Item_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-item-control.php";

-- --
-- -- WP_Customize_Nav_Menu_Location_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-location-control.php";

-- --
-- -- WP_Customize_Nav_Menu_Name_Control class.
-- --
-- -- As this file is deprecated, it will trigger a deprecation notice if instantiated. In a subsequent
-- -- release, the require_once here will be removed and _deprecated_file() will be called if file is
-- -- required at all.
-- --
-- -- @deprecated 4.9.0 This file is no longer used due to new menu creation UX.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-name-control.php";

-- --
-- -- WP_Customize_Nav_Menu_Locations_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-locations-control.php";

-- --
-- -- WP_Customize_Nav_Menu_Auto_Add_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-auto-add-control.php";

-- --
-- -- WP_Customize_Date_Time_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-date-time-control.php";

-- --
-- -- WP_Sidebar_Block_Editor_Control class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-sidebar-block-editor-control.php";
