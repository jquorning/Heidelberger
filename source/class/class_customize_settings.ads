--
-- WordPress Customize Setting classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.4.0
--

with Ada.Strings.Unbounded;

with Arrays;
with Lists;

with Class_Errors;

limited with Class_Customize_Managers;

package Class_Customize_Settings
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Lists;

   --
   -- Customize Setting class.
   --
   -- Handles saving and sanitizing of settings.
   --
   -- @since 3.4.0
   --
   -- @see WP_Customize_Manager
   -- @link https://developer.wordpress.org/themes/customize-api
   --
   -- #[AllowDynamicProperties]
   type Wp_Customize_Setting is tagged
      record
         --
         -- Customizer bootstrap instance.
         --
         -- @since 3.4.0
         -- @var WP_Customize_Manager
         --
         Manager : access Class_Customize_Managers.Wp_Customize_Manager;

         --
         -- Unique string identifier for the setting.
         --
         -- @since 3.4.0
         -- @var string
         --
         Id : Unbounded_String;

         --
         -- Type of customize settings.
         --
         -- @since 3.4.0
         -- @var string
         --
         Typ : Unbounded_String := To_Unbounded_String ("theme_mod");

         --
         -- Capability required to edit this setting.
         --
         -- @since 3.4.0
         -- @var string|array
         --
--         public capability = "edit_theme_options";

         --
         -- Theme features required to support the setting.
         --
         -- @since 3.4.0
         -- @var string|string[]
         --
--         public theme_supports = "";

         --
         -- The default value for the setting.
         --
         -- @since 3.4.0
         -- @var string
         --
         Default : Unbounded_String;

         --
         -- Options for rendering the live preview of changes in Customizer.
         --
         -- Set this value to "postMessage" to enable a custom JavaScript handler to
         -- render changes to this setting as opposed to reloading the whole page.
         --
         -- @since 3.4.0
         -- @var string
         --
--         public transport = "refresh";

         --
         -- Server-side validation callback for the setting"s value.
         --
         -- @since 4.6.0
         -- @var callable
         --
--        public validate_callback = "";

         --
         -- Callback to filter a Customize setting value in un-slashed form.
         --
         -- @since 3.4.0
         -- @var callable
         --
--         public sanitize_callback = "";

         --
         -- Callback to convert a Customize PHP setting value to a value that is JSON
         -- serializable.
         --
         -- @since 3.4.0
         -- @var callable
         --
--         public sanitize_js_callback = "";

         --
         -- Whether or not the setting is initially dirty when created.
         --
         -- This is used to ensure that a setting will be sent from the pane to the
         -- preview when loading the Customizer. Normally a setting only is synced to
         -- the preview if it has been changed. This allows the setting to be sent
         -- from the start.
         --
         -- @since 4.2.0
         -- @var bool
         --
--         public dirty = false;

         --
         -- ID Data.
         --
         -- @since 3.4.0
         -- @var array
         --
         -- protected
         Id_Data : Array_Type;

         --
         -- Whether or not preview() was called.
         --
         -- @since 4.4.0
         -- @var bool
         --
         -- protected
         Is_Previewed : Boolean := False;

         --
         -- Whether the multidimensional setting is aggregated.
         --
         -- @since 4.4.0
         -- @var bool
         --
         -- protected
         Is_Multidimensional_Aggregated : Boolean := False;

         --
         -- The ID for the current site when the preview() method was called.
         --
         -- @since 4.2.0
         -- @var int
         --
         -- protected
         X_Previewed_Blog_Id : Integer;

      end record;

--         --
--         -- Constructor.
--         --
--         -- Any supplied args override class property defaults.
--         --
--         -- @since 3.4.0
--         --
--         -- @param WP_Customize_Manager manager Customizer bootstrap instance.
--         -- @param string               id      A specific ID of the setting.
--         --                                      Can be a theme mod or option name.
--         -- @param array                args    then
--         --     Optional. Array of properties for the new Setting object. Default empty array.
--         --
--         --     @type string          type                 Type of the setting. Default "theme_mod".
--         --     @type string          capability           Capability required for the setting. Default "edit_theme_options"
--         --     @type string|string[] theme_supports       Theme features required to support the panel. Default is none.
--         --     @type string          default              Default value for the setting. Default is empty string.
--         --     @type string          transport            Options for rendering the live preview of changes in Customizer.
--         --                                                 Using "refresh" makes the change visible by reloading the whole preview.
--         --                                                 Using "postMessage" allows a custom JavaScript to handle live changes.
--         --                                                 Default is "refresh".
--         --     @type callable        validate_callback    Server-side validation callback for the setting"s value.
--         --     @type callable        sanitize_callback    Callback to filter a Customize setting value in un-slashed form.
--         --     @type callable        sanitize_js_callback Callback to convert a Customize PHP setting value to a value that is
--         --                                                 JSON serializable.
--         --     @type bool            dirty                Whether or not the setting is initially dirty when created.
--         -- end;
--         --
--         public function __construct( manager, id, args = array() ) then
--                 keys = array_keys( get_object_vars( this ) );
--                 foreach ( keys as key ) then
--                         if ( isset( args[ key ] ) ) then
--                                 this.key = args[ key ];
--                         end;
--                 end;

--                 this.manager = manager;
--                 this.id      = id;

--                 // Parse the ID for array keys.
--                 this.id_data["keys"] = preg_split( "/\[/", str_replace( "]", "", this.id ) );
--                 this.id_data["base"] = array_shift( this.id_data["keys"] );

--                 // Rebuild the ID.
--                 this.id = this.id_data["base"];
--                 if ( ! empty( this.id_data["keys"] ) ) then
--                         this.id .= "[" . implode( "][", this.id_data["keys"] ) . "]";
--                 end;

--                 if ( this.validate_callback ) then
--                         add_filter( "customize_validate_thenthis.idend;", this.validate_callback, 10, 3 );
--                 end;
--                 if ( this.sanitize_callback ) then
--                         add_filter( "customize_sanitize_thenthis.idend;", this.sanitize_callback, 10, 2 );
--                 end;
--                 if ( this.sanitize_js_callback ) then
--                         add_filter( "customize_sanitize_js_thenthis.idend;", this.sanitize_js_callback, 10, 2 );
--                 end;

--                 if ( "option" === this.type || "theme_mod" === this.type ) then
--                         // Other setting types can opt-in to aggregate multidimensional explicitly.
--                         this.aggregate_multidimensional();

--                         // Allow option settings to indicate whether they should be autoloaded.
--                         if ( "option" === this.type && isset( args["autoload"] ) ) then
--                                 self::aggregated_multidimensionals[ this.type ][ this.id_data["base"] ]["autoload"] = args["autoload"];
--                         end;
--                 end;
--         end;

--         --
--         -- Get parsed ID data for multidimensional setting.
--         --
--         -- @since 4.4.0
--         --
--         -- @return array then
--         --     ID data for multidimensional setting.
--         --
--         --     @type string base ID base
--         --     @type array  keys Keys for multidimensional array.
--         -- end;
--         --
--         final public function id_data() then
--                 return this.id_data;
--         end;

--         --
--         -- Set up the setting for aggregated multidimensional values.
--         --
--         -- When a multidimensional setting gets aggregated, all of its preview and update
--         -- calls get combined into one call, greatly improving performance.
--         --
--         -- @since 4.4.0
--         --
--         protected function aggregate_multidimensional() then
--                 id_base = this.id_data["base"];
--                 if ( ! isset( self::aggregated_multidimensionals[ this.type ] ) ) then
--                         self::aggregated_multidimensionals[ this.type ] = array();
--                 end;
--                 if ( ! isset( self::aggregated_multidimensionals[ this.type ][ id_base ] ) ) then
--                         self::aggregated_multidimensionals[ this.type ][ id_base ] = array(
--                                 "previewed_instances"       => array(), // Calling preview() will add the setting to the array.
--                                 "preview_applied_instances" => array(), // Flags for which settings have had their values applied.
--                                 "root_value"                => this.get_root_value( array() ), // Root value for initial state, manipulated by preview and update calls.
--                         );
--                 end;

--                 if ( ! empty( this.id_data["keys"] ) ) then
--                         // Note the preview-applied flag is cleared at priority 9 to ensure it is cleared before a deferred-preview runs.
--                         add_action( "customize_post_value_set_thenthis.idend;", array( this, "_clear_aggregated_multidimensional_preview_applied_flag" ), 9 );
--                         this.is_multidimensional_aggregated = true;
--                 end;
--         end;

--         --
--         -- Reset `aggregated_multidimensionals` static variable.
--         --
--         -- This is intended only for use by unit tests.
--         --
--         -- @since 4.5.0
--         -- @ignore
--         --
--         public static function reset_aggregated_multidimensionals() then
--                 self::aggregated_multidimensionals = array();
--         end;

   --
   -- Return true if the current site is not the same as the previewed site.
   --
   -- @since 4.2.0
   --
   -- @return bool If preview() has been called.
   --
   function Is_Current_Blog_Previewed (This : Wp_Customize_Setting)
                                       return Boolean;

--         --
--         -- Original non-previewed value stored by the preview method.
--         --
--         -- @see WP_Customize_Setting::preview()
--         -- @since 4.1.1
--         -- @var mixed
--         --
--         protected _original_value;

   --
   -- Add filters to supply the setting"s value when accessed.
   --
   -- If the setting already has a pre-existing value and there is no incoming
   -- post value for the setting, then this method will short-circuit since
   -- there is no change to preview.
   --
   -- @since 3.4.0
   -- @since 4.4.0 Added boolean return value.
   --
   -- @return bool False when preview short-circuits due no change needing to be
   --              previewed.
   --
   procedure Preview (This : in out Wp_Customize_Setting);

--         --
--         -- Clear out the previewed-applied flag for a multidimensional-aggregated value whenever its post value is updated.
--         --
--         -- This ensures that the new value will get sanitized and used the next time
--         -- that `WP_Customize_Setting::_multidimensional_preview_filter()`
--         -- is called for this setting.
--         --
--         -- @since 4.4.0
--         --
--         -- @see WP_Customize_Manager::set_post_value()
--         -- @see WP_Customize_Setting::_multidimensional_preview_filter()
--         --
--         final public function _clear_aggregated_multidimensional_preview_applied_flag() then
--                 unset( self::aggregated_multidimensionals[ this.type ][ this.id_data["base"] ]["preview_applied_instances"][ this.id ] );
--         end;

   --
   -- Callback function to filter non-multidimensional theme mods and options.
   --
   -- If switch_to_blog() was called after the preview() method, and the current
   -- site is now not the same site, then this method does a no-op and returns
   -- the original value.
   --
   -- @since 3.4.0
   --
   -- @param mixed original Old value.
   -- @return mixed New or old value.
   --
   function X_Preview_Filter (This     : in out Wp_Customize_Setting;
                              Original : String)
                              return String;

   procedure X_Preview_Filter (This : in out Wp_Customize_Setting);

   --
   -- Callback function to filter multidimensional theme mods and options.
   --
   -- For all multidimensional settings of a given type, the preview filter for
   -- the first setting previewed will be used to apply the values for the others.
   --
   -- @since 4.4.0
   --
   -- @see WP_Customize_Setting::aggregated_multidimensionals
   -- @param mixed original Original root value.
   -- @return mixed New or old value.
   --
   -- final public
   function X_Multidimensional_Preview_Filter
              (This : in out Wp_Customize_Setting;
               Original : String)
               return String;

   procedure X_Multidimensional_Preview_Filter (This : in out Wp_Customize_Setting);

--         --
--         -- Checks user capabilities and theme supports, and then saves
--         -- the value of the setting.
--         --
--         -- @since 3.4.0
--         --
--         -- @return void|false Void on success, false if cap check fails
--         --                    or value isn"t set or is invalid.
--         --
--         final public function save() then
--                 value = this.post_value();

--                 if ( ! this.check_capabilities() || ! isset( value ) ) then
--                         return false;
--                 end;

--                 id_base = this.id_data["base"];

--                 --
--                 -- Fires when the WP_Customize_Setting::save() method is called.
--                 --
--                 -- The dynamic portion of the hook name, `id_base` refers to
--                 -- the base slug of the setting name.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param WP_Customize_Setting setting WP_Customize_Setting instance.
--                 --
--                 do_action( "customize_save_thenid_baseend;", this );

--                 this.update( value );
--         end;

   --
   -- Fetch and sanitize the _POST value for the setting.
   --
   -- During a save request prior to save, post_value() provides the new value while
   -- value() does not.
   --
   -- @since 3.4.0
   --
   -- @param mixed default_value A default value which is used as a fallback.
   --                             Default null.
   -- @return mixed The default value on failure, otherwise the sanitized and
   --                validated value.
   --
   -- final
   function Post_Value (This          : Wp_Customize_Setting;
                        Default_Value : String := "") -- null
                        return String;

   --
   -- Sanitize an input.
   --
   -- @since 3.4.0
   --
   -- @param string|array value The value to sanitize.
   -- @return string|array|null|WP_Error Sanitized value, or `null`/`WP_Error` if
   --                                     invalid.
   --
   function Sanitize (This  : Wp_Customize_Setting;
                      Value : Multi_Type)
                      return Multi_Type;
--                 --
--                 -- Filters a Customize setting value in un-slashed form.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param mixed                value   Value of the setting.
--                 -- @param WP_Customize_Setting setting WP_Customize_Setting instance.
--                 --
--                 return apply_filters( "customize_sanitize_thenthis.idend;", value, this );
--         end;

   --
   -- Validates an input.
   --
   -- @since 4.6.0
   --
   -- @see WP_REST_Request::has_valid_params()
   --
   -- @param mixed value Value to validate.
   -- @return true|WP_Error True if the input was validated, otherwise WP_Error.
   --
   type Validate_Result is
      record
         Success : Boolean;
         Error   : Class_Errors.Wp_Error;
      end record;

   function Validate (This  : Wp_Customize_Setting;
                      Value : Multi_Type)
                      return Validate_Result;

   --
   -- Get the root value for a setting, especially for multidimensional ones.
   --
   -- @since 4.4.0
   --
   -- @param mixed default_value Value to return if root does not exist.
   -- @return mixed
   --
   -- protected
   function Get_Root_Value (This          : Wp_Customize_Setting;
                            Default_Value : String := "") -- null
                            return String;

--         --
--         -- Set the root value for a setting, especially for multidimensional ones.
--         --
--         -- @since 4.4.0
--         --
--         -- @param mixed value Value to set as root of multidimensional setting.
--         -- @return bool Whether the multidimensional root was updated successfully.
--         --
--         protected function set_root_value( value ) then
--                 id_base = this.id_data["base"];
--                 if ( "option" === this.type ) then
--                         autoload = true;
--                         if ( isset( self::aggregated_multidimensionals[ this.type ][ this.id_data["base"] ]["autoload"] ) ) then
--                                 autoload = self::aggregated_multidimensionals[ this.type ][ this.id_data["base"] ]["autoload"];
--                         end;
--                         return update_option( id_base, value, autoload );
--                 end; elseif ( "theme_mod" === this.type ) then
--                         set_theme_mod( id_base, value );
--                         return true;
--                 end; else then
--                         /*
--                         -- Any WP_Customize_Setting subclass implementing aggregate multidimensional
--                         -- will need to override this method to obtain the data from the appropriate
--                         -- location.
--                         --
--                         return false;
--                 end;
--         end;

--         --
--         -- Save the value of the setting, using the related API.
--         --
--         -- @since 3.4.0
--         --
--         -- @param mixed value The value to update.
--         -- @return bool The result of saving the value.
--         --
--         protected function update( value ) then
--                 id_base = this.id_data["base"];
--                 if ( "option" === this.type || "theme_mod" === this.type ) then
--                         if ( ! this.is_multidimensional_aggregated ) then
--                                 return this.set_root_value( value );
--                         end; else then
--                                 root = self::aggregated_multidimensionals[ this.type ][ id_base ]["root_value"];
--                                 root = this.multidimensional_replace( root, this.id_data["keys"], value );
--                                 self::aggregated_multidimensionals[ this.type ][ id_base ]["root_value"] = root;
--                                 return this.set_root_value( root );
--                         end;
--                 end; else then
--                         --
--                         -- Fires when the WP_Customize_Setting::update() method is called for settings
--                         -- not handled as theme_mods or options.
--                         --
--                         -- The dynamic portion of the hook name, `this.type`, refers to the type of setting.
--                         --
--                         -- @since 3.4.0
--                         --
--                         -- @param mixed                value   Value of the setting.
--                         -- @param WP_Customize_Setting setting WP_Customize_Setting instance.
--                         --
--                         do_action( "customize_update_thenthis.typeend;", value, this );

--                         return has_action( "customize_update_thenthis.typeend;" );
--                 end;
--         end;

--         --
--         -- Deprecated method.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.4.0 Deprecated in favor of update() method.
--         --
--         protected function _update_theme_mod() then
--                 _deprecated_function( __METHOD__, "4.4.0", __CLASS__ . "::update()" );
--         end;

--         --
--         -- Deprecated method.
--         --
--         -- @since 3.4.0
--         -- @deprecated 4.4.0 Deprecated in favor of update() method.
--         --
--         protected function _update_option() then
--                 _deprecated_function( __METHOD__, "4.4.0", __CLASS__ . "::update()" );
--         end;

   --
   -- Fetch the value of the setting.
   --
   -- @since 3.4.0
   --
   -- @return mixed The value.
   --
   function Value (This : Wp_Customize_Setting)
                   return String;

--         --
--         -- Sanitize the setting"s value for use in JavaScript.
--         --
--         -- @since 3.4.0
--         --
--         -- @return mixed The requested escaped value.
--         --
--         public function js_value() then

--                 --
--                 -- Filters a Customize setting value for use in JavaScript.
--                 --
--                 -- The dynamic portion of the hook name, `this.id`, refers to the setting ID.
--                 --
--                 -- @since 3.4.0
--                 --
--                 -- @param mixed                value   The setting value.
--                 -- @param WP_Customize_Setting setting WP_Customize_Setting instance.
--                 --
--                 value = apply_filters( "customize_sanitize_js_thenthis.idend;", this.value(), this );

--                 if ( is_string( value ) ) then
--                         return html_entity_decode( value, ENT_QUOTES, "UTF-8" );
--                 end;

--                 return value;
--         end;

--         --
--         -- Retrieves the data to export to the client via JSON.
--         --
--         -- @since 4.6.0
--         --
--         -- @return array Array of parameters passed to JavaScript.
--         --
--         public function json() then
--                 return array(
--                         "value"     => this.js_value(),
--                         "transport" => this.transport,
--                         "dirty"     => this.dirty,
--                         "type"      => this.type,
--                 );
--         end;

--         --
--         -- Validate user capabilities whether the theme supports the setting.
--         --
--         -- @since 3.4.0
--         --
--         -- @return bool False if theme doesn"t support the setting or user can"t change setting, otherwise true.
--         --
--         final public function check_capabilities() then
--                 if ( this.capability && ! current_user_can( this.capability ) ) then
--                         return false;
--                 end;

--                 if ( this.theme_supports && ! current_theme_supports( ... (array) this.theme_supports ) ) then
--                         return false;
--                 end;

--                 return true;
--         end;

   --
   -- Multidimensional helper function.
   --
   -- @since 3.4.0
   --
   -- @param array root
   -- @param array keys
   -- @param bool  create Default false.
   -- @return array|void Keys are "root", "node", and "key".
   --
   -- final protected
   function Multidimensional (This   : Wp_Customize_Setting;
                              Root   : in out Array_Type;
                              Keys   : List_Type; -- String;
                              Create : Boolean := False)
                              return Array_Type;

   --
   -- Will attempt to replace a specific value in a multidimensional array.
   --
   -- @since 3.4.0
   --
   -- @param array root
   -- @param array keys
   -- @param mixed value The value to update.
   -- @return mixed
   --
   -- final protected
   function Multidimensional_Replace (This  : Wp_Customize_Setting;
                                      Root  : Array_Type; -- String;
                                      Keys  : List_Type;  -- String;
                                      Value : Multi_Type) -- String)
                                      return Array_Type; -- String;

   --
   -- Will attempt to fetch a specific value from a multidimensional array.
   --
   -- @since 3.4.0
   --
   -- @param array root
   -- @param array keys
   -- @param mixed default_value A default value which is used as a fallback.
   --                             Default null.
   -- @return mixed The requested value or the default value.
   --
   -- final protected
   function Multidimensional_Get
              (This : Wp_Customize_Setting;
               Root : Array_Type; -- Multi_Type; -- Array_Type;
               Keys : List_Type;  -- Multi_Type; -- Array_Type;
               Default_Value : Multi_Type := From_Null) -- String := "") -- null
               return Multi_Type; -- String;

--         --
--         -- Will attempt to check if a specific value in a multidimensional array is set.
--         --
--         -- @since 3.4.0
--         --
--         -- @param array root
--         -- @param array keys
--         -- @return bool True if value is set, false if not.
--         --
--         final protected function multidimensional_isset( root, keys ) then
--                 result = this.multidimensional_get( root, keys );
--                 return isset( result );
--         end;

   Null_Setting : constant Wp_Customize_Setting :=
     (Manager             => null,
      Id                  => Null_Unbounded_String,
      Typ                 => Null_Unbounded_String,
      Default             => Null_Unbounded_String,
      Id_Data             => Empty_Array,
      Is_Previewed        => False,
      Is_Multidimensional_Aggregated => False,
      X_Previewed_Blog_Id => 0);

private

   --
   -- Cache of multidimensional values to improve performance.
   --
   -- @since 4.4.0
   -- @var array
   --
   -- protected static
   Aggregated_Multidimensionals : Array_Type;

end Class_Customize_Settings;

-- --
-- -- WP_Customize_Filter_Setting class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-filter-setting.php";

-- --
-- -- WP_Customize_Header_Image_Setting class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-header-image-setting.php";

-- --
-- -- WP_Customize_Background_Image_Setting class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-background-image-setting.php";

-- --
-- -- WP_Customize_Nav_Menu_Item_Setting class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-item-setting.php";

-- --
-- -- WP_Customize_Nav_Menu_Setting class.
-- --
-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-nav-menu-setting.php";
