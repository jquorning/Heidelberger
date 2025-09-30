
--
-- Option API
--
-- @package WordPress
-- @subpackage Option
--

with Ada.Strings.Unbounded;
-- with Hb_Common;
with Php;

with Inc_Caches;
with Inc_Load;
with Inc_Plugins;

package body Inc_Options
is
   procedure Dummy is null;

-- --
-- -- Retrieves an option value based on an option name.
-- --
-- -- If the option does not exist, and a default value is not provided,
-- -- boolean false is returned. This could be used to check whether you need
-- -- to initialize an option during installation of a plugin, however that
-- -- can be done better by using add_option() which will not overwrite
-- -- existing options.
-- --
-- -- Not initializing an option and using boolean `false` as a return value
-- -- is a bad practice as it triggers an additional database query.
-- --
-- -- The type of the returned value can be different from the type that was passed
-- -- when saving or updating the option. If the option value was serialized,
-- -- then it will be unserialized when it is returned. In this case the type will
-- -- be the same. For example, storing a non-scalar value like an array will
-- -- return the same array.
-- --
-- -- In most cases non-string scalar and null values will be converted and returned
-- -- as string equivalents.
-- --
-- -- Exceptions:
-- --
-- -- 1. When the option has not been saved in the database, the `default` value
-- --    is returned if provided. If not, boolean `false` is returned.
-- -- 2. When one of the Options API filters is used: {@see "pre_option_option"},
-- --    {@see "default_option_option"}, or {@see "option_option"}, the returned
-- --    value may not match the expected type.
-- -- 3. When the option has just been saved in the database, and get_option()
-- --    is used right after, non-string scalar and null values are not converted to
-- --    string equivalents and the original type is returned.
-- --
-- -- Examples:
-- --
-- -- When adding options like this: `add_option( "my_option_name", "value" )`
-- -- and then retrieving them with `get_option( "my_option_name" )`, the returned
-- -- values will be:
-- --
-- --   - `false` returns `string(0) ""`
-- --   - `true`  returns `string(1) "1"`
-- --   - `0`     returns `string(1) "0"`
-- --   - `1`     returns `string(1) "1"`
-- --   - `"0"`   returns `string(1) "0"`
-- --   - `"1"`   returns `string(1) "1"`
-- --   - `null`  returns `string(0) ""`
-- --
-- -- When adding options with non-scalar values like
-- -- `add_option( "my_array", array( false, "str", null ) )`, the returned value
-- -- will be identical to the original as it is serialized before saving
-- -- it in the database:
-- --
-- --     array(3) then
-- --         [0] => bool(false)
-- --         [1] => string(3) "str"
-- --         [2] => NULL
-- --     end;
-- --
-- -- @since 1.5.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string option  Name of the option to retrieve. Expected to not be SQL-escaped.
-- -- @param mixed  default Optional. Default value to return if the option does not exist.
-- -- @return mixed Value of the option. A value of any type may be returned, including
-- --               scalar (string, boolean, float, integer), null, array, object.
-- --               Scalar and null values will be returned as strings as long as they originate
-- --               from a database stored option value. If there is no option in the database,
-- --               boolean `false` is returned.
-- --
-- function get_option( option, default = false ) then
   function Get_Option (Option : String)
                        return String
   is
   begin
      if Option = "html_type" then
         return "text/html";
      elsif Option = "blog_charset" then
         return "UTF-8";
      else
         return "XXX-222";
      end if;
--         global wpdb;

--         if ( is_scalar( option ) ) then
--                 option = trim( option );
--         end;

--         if ( empty( option ) ) then
--                 return false;
--         end;

--         /*
--         -- Until a proper _deprecated_option() function can be introduced,
--         -- redirect requests to deprecated keys to the new, correct ones.
--         --
--         deprecated_keys = array(
--                 "blacklist_keys"    => "disallowed_keys",
--                 "comment_whitelist" => "comment_previously_approved",
--         );

--         if ( isset( deprecated_keys[ option ] ) && ! wp_installing() ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "5.5.0",
--                         sprintf(
--                                 /* translators: 1: Deprecated option key, 2: New option key.--
--                                 __( "The "%1s" option key has been renamed to "%2s"." ),
--                                 option,
--                                 deprecated_keys[ option ]
--                         )
--                 );
--                 return get_option( deprecated_keys[ option ], default );
--         end;

--         --
--         -- Filters the value of an existing option before it is retrieved.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- Returning a value other than false from the filter will short-circuit retrieval
--         -- and return that value instead.
--         --
--         -- @since 1.5.0
--         -- @since 4.4.0 The `option` parameter was added.
--         -- @since 4.9.0 The `default` parameter was added.
--         --
--         -- @param mixed  pre_option The value to return instead of the option value. This differs
--         --                           from `default`, which is used as the fallback value in the event
--         --                           the option doesn"t exist elsewhere in get_option().
--         --                           Default false (to skip past the short-circuit).
--         -- @param string option     Option name.
--         -- @param mixed  default    The fallback value to return if the option does not exist.
--         --                           Default false.
--         --
--         pre = apply_filters( "pre_option_thenoptionend;", false, option, default );

--         --
--         -- Filters the value of all existing options before it is retrieved.
--         --
--         -- Returning a truthy value from the filter will effectively short-circuit retrieval
--         -- and return the passed value instead.
--         --
--         -- @since 6.1.0
--         --
--         -- @param mixed  pre_option  The value to return instead of the option value. This differs
--         --                            from `default`, which is used as the fallback value in the event
--         --                            the option doesn"t exist elsewhere in get_option().
--         --                            Default false (to skip past the short-circuit).
--         -- @param string option      Name of the option.
--         -- @param mixed  default     The fallback value to return if the option does not exist.
--         --                            Default false.
--         --
--         pre = apply_filters( "pre_option", pre, option, default );

--         if ( false !== pre ) then
--                 return pre;
--         end;

--         if ( defined( "WP_SETUP_CONFIG" ) ) then
--                 return false;
--         end;

--         // Distinguish between `false` as a default, and not passing one.
--         passed_default = func_num_args() > 1;

--         if ( ! wp_installing() ) then
--                 // Prevent non-existent options from triggering multiple queries.
--                 notoptions = wp_cache_get( "notoptions", "options" );

--                 // Prevent non-existent `notoptions` key from triggering multiple key lookups.
--                 if ( ! is_array( notoptions ) ) then
--                         notoptions = array();
--                         wp_cache_set( "notoptions", notoptions, "options" );
--                 end;

--                 if ( isset( notoptions[ option ] ) ) then
--                         --
--                         -- Filters the default value for an option.
--                         --
--                         -- The dynamic portion of the hook name, `option`, refers to the option name.
--                         --
--                         -- @since 3.4.0
--                         -- @since 4.4.0 The `option` parameter was added.
--                         -- @since 4.7.0 The `passed_default` parameter was added to distinguish between a `false` value and the default parameter value.
--                         --
--                         -- @param mixed  default The default value to return if the option does not exist
--                         --                        in the database.
--                         -- @param string option  Option name.
--                         -- @param bool   passed_default Was `get_option()` passed a default value?
--                         --
--                         return apply_filters( "default_option_thenoptionend;", default, option, passed_default );
--                 end;

--                 alloptions = wp_load_alloptions();

--                 if ( isset( alloptions[ option ] ) ) then
--                         value = alloptions[ option ];
--                 end; else then
--                         value = wp_cache_get( option, "options" );

--                         if ( false === value ) then
--                                 row = wpdb->get_row( wpdb->prepare( "SELECT option_value FROM wpdb->options WHERE option_name = %s LIMIT 1", option ) );

--                                 // Has to be get_row() instead of get_var() because of funkiness with 0, false, null values.
--                                 if ( is_object( row ) ) then
--                                         value = row->option_value;
--                                         wp_cache_add( option, value, "options" );
--                                 end; else then // Option does not exist, so we must cache its non-existence.
--                                         if ( ! is_array( notoptions ) ) then
--                                                 notoptions = array();
--                                         end;

--                                         notoptions[ option ] = true;
--                                         wp_cache_set( "notoptions", notoptions, "options" );

--                                         -- This filter is documented in wp-includes/option.php--
--                                         return apply_filters( "default_option_thenoptionend;", default, option, passed_default );
--                                 end;
--                         end;
--                 end;
--         end; else then
--                 suppress = wpdb->suppress_errors();
--                 row      = wpdb->get_row( wpdb->prepare( "SELECT option_value FROM wpdb->options WHERE option_name = %s LIMIT 1", option ) );
--                 wpdb->suppress_errors( suppress );

--                 if ( is_object( row ) ) then
--                         value = row->option_value;
--                 end; else then
--                         -- This filter is documented in wp-includes/option.php--
--                         return apply_filters( "default_option_thenoptionend;", default, option, passed_default );
--                 end;
--         end;

--         // If home is not set, use siteurl.
--         if ( "home" === option && "" === value ) then
--                 return get_option( "siteurl" );
--         end;

--         if ( in_array( option, array( "siteurl", "home", "category_base", "tag_base" ), true ) ) then
--                 value = untrailingslashit( value );
--         end;

--         --
--         -- Filters the value of an existing option.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- @since 1.5.0 As "option_" . setting
--         -- @since 3.0.0
--         -- @since 4.4.0 The `option` parameter was added.
--         --
--         -- @param mixed  value  Value of the option. If stored serialized, it will be
--         --                       unserialized prior to being returned.
--         -- @param string option Option name.
--         --
--         return apply_filters( "option_thenoptionend;", maybe_unserialize( value ), option );
   end Get_Option;

-- --
-- -- Protects WordPress special option from being modified.
-- --
-- -- Will die if option is in protected list. Protected options are "alloptions"
-- -- and "notoptions" options.
-- --
-- -- @since 2.2.0
-- --
-- -- @param string option Option name.
-- --
-- function wp_protect_special_option( option ) then
--         if ( "alloptions" === option || "notoptions" === option ) then
--                 wp_die(
--                         sprintf(
--                                 /* translators: %s: Option name.--
--                                 __( "%s is a protected WP option and may not be modified" ),
--                                 esc_html( option )
--                         )
--                 );
--         end;
-- end;

-- --
-- -- Prints option value after sanitizing for forms.
-- --
-- -- @since 1.5.0
-- --
-- -- @param string option Option name.
-- --
-- function form_option( option ) then
--         echo esc_attr( get_option( option ) );
-- end;

-- --
-- -- Loads and caches all autoloaded options, if available or all options.
-- --
-- -- @since 2.2.0
-- -- @since 5.3.1 The `force_cache` parameter was added.
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param bool force_cache Optional. Whether to force an update of the local cache
-- --                          from the persistent cache. Default false.
-- -- @return array List of all options.
-- --
-- function wp_load_alloptions( force_cache = false ) then
--         global wpdb;

--         if ( ! wp_installing() || ! is_multisite() ) then
--                 alloptions = wp_cache_get( "alloptions", "options", force_cache );
--         end; else then
--                 alloptions = false;
--         end;

--         if ( ! alloptions ) then
--                 suppress      = wpdb->suppress_errors();
--                 alloptions_db = wpdb->get_results( "SELECT option_name, option_value FROM wpdb->options WHERE autoload = "yes"" );
--                 if ( ! alloptions_db ) then
--                         alloptions_db = wpdb->get_results( "SELECT option_name, option_value FROM wpdb->options" );
--                 end;
--                 wpdb->suppress_errors( suppress );

--                 alloptions = array();
--                 foreach ( (array) alloptions_db as o ) then
--                         alloptions[ o->option_name ] = o->option_value;
--                 end;

--                 if ( ! wp_installing() || ! is_multisite() ) then
--                         --
--                         -- Filters all options before caching them.
--                         --
--                         -- @since 4.9.0
--                         --
--                         -- @param array alloptions Array with all options.
--                         --
--                         alloptions = apply_filters( "pre_cache_alloptions", alloptions );

--                         wp_cache_add( "alloptions", alloptions, "options" );
--                 end;
--         end;

--         --
--         -- Filters all options after retrieving them.
--         --
--         -- @since 4.9.0
--         --
--         -- @param array alloptions Array with all options.
--         --
--         return apply_filters( "alloptions", alloptions );
-- end;

-- --
-- -- Loads and caches certain often requested site options if is_multisite() and a persistent cache is not being used.
-- --
-- -- @since 3.0.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int network_id Optional site ID for which to query the options. Defaults to the current site.
-- --
-- function wp_load_core_site_options( network_id = null ) then
--         global wpdb;

--         if ( ! is_multisite() || wp_using_ext_object_cache() || wp_installing() ) then
--                 return;
--         end;

--         if ( empty( network_id ) ) then
--                 network_id = get_current_network_id();
--         end;

--         core_options = array( "site_name", "siteurl", "active_sitewide_plugins", "_site_transient_timeout_theme_roots", "_site_transient_theme_roots", "site_admins", "can_compress_scripts", "global_terms_enabled", "ms_files_rewriting" );

--         core_options_in = """ . implode( "", "", core_options ) . """;
--         options         = wpdb->get_results( wpdb->prepare( "SELECT meta_key, meta_value FROM wpdb->sitemeta WHERE meta_key IN (core_options_in) AND site_id = %d", network_id ) );

--         data = array();
--         foreach ( options as option ) then
--                 key                = option->meta_key;
--                 cache_key          = "thennetwork_idend;:key";
--                 option->meta_value = maybe_unserialize( option->meta_value );

--                 data[ cache_key ] = option->meta_value;
--         end;
--         wp_cache_set_multiple( data, "site-options" );
-- end;

-- --
-- -- Updates the value of an option that was already added.
-- --
-- -- You do not need to serialize values. If the value needs to be serialized,
-- -- then it will be serialized before it is inserted into the database.
-- -- Remember, resources cannot be serialized or added as an option.
-- --
-- -- If the option does not exist, it will be created.

-- -- This function is designed to work with or without a logged-in user. In terms of security,
-- -- plugin developers should check the current user"s capabilities before updating any options.
-- --
-- -- @since 1.0.0
-- -- @since 4.2.0 The `autoload` parameter was added.
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string      option   Name of the option to update. Expected to not be SQL-escaped.
-- -- @param mixed       value    Option value. Must be serializable if non-scalar. Expected to not be SQL-escaped.
-- -- @param string|bool autoload Optional. Whether to load the option when WordPress starts up. For existing options,
-- --                              `autoload` can only be updated using `update_option()` if `value` is also changed.
-- --                              Accepts "yes"|true to enable or "no"|false to disable. For non-existent options,
-- --                              the default value is "yes". Default null.
-- -- @return bool True if the value was updated, false otherwise.
-- --
-- function update_option( option, value, autoload = null ) then
--         global wpdb;

--         if ( is_scalar( option ) ) then
--                 option = trim( option );
--         end;

--         if ( empty( option ) ) then
--                 return false;
--         end;

--         /*
--         -- Until a proper _deprecated_option() function can be introduced,
--         -- redirect requests to deprecated keys to the new, correct ones.
--         --
--         deprecated_keys = array(
--                 "blacklist_keys"    => "disallowed_keys",
--                 "comment_whitelist" => "comment_previously_approved",
--         );

--         if ( isset( deprecated_keys[ option ] ) && ! wp_installing() ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "5.5.0",
--                         sprintf(
--                                 /* translators: 1: Deprecated option key, 2: New option key.--
--                                 __( "The "%1s" option key has been renamed to "%2s"." ),
--                                 option,
--                                 deprecated_keys[ option ]
--                         )
--                 );
--                 return update_option( deprecated_keys[ option ], value, autoload );
--         end;

--         wp_protect_special_option( option );

--         if ( is_object( value ) ) then
--                 value = clone value;
--         end;

--         value     = sanitize_option( option, value );
--         old_value = get_option( option );

--         --
--         -- Filters a specific option before its value is (maybe) serialized and updated.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- @since 2.6.0
--         -- @since 4.4.0 The `option` parameter was added.
--         --
--         -- @param mixed  value     The new, unserialized option value.
--         -- @param mixed  old_value The old option value.
--         -- @param string option    Option name.
--         --
--         value = apply_filters( "pre_update_option_thenoptionend;", value, old_value, option );

--         --
--         -- Filters an option before its value is (maybe) serialized and updated.
--         --
--         -- @since 3.9.0
--         --
--         -- @param mixed  value     The new, unserialized option value.
--         -- @param string option    Name of the option.
--         -- @param mixed  old_value The old option value.
--         --
--         value = apply_filters( "pre_update_option", value, option, old_value );

--         /*
--         -- If the new and old values are the same, no need to update.
--         --
--         -- Unserialized values will be adequate in most cases. If the unserialized
--         -- data differs, the (maybe) serialized data is checked to avoid
--         -- unnecessary database calls for otherwise identical object instances.
--         --
--         -- See https://core.trac.wordpress.org/ticket/38903
--         --
--         if ( value === old_value || maybe_serialize( value ) === maybe_serialize( old_value ) ) then
--                 return false;
--         end;

--         -- This filter is documented in wp-includes/option.php--
--         if ( apply_filters( "default_option_thenoptionend;", false, option, false ) === old_value ) then
--                 // Default setting for new options is "yes".
--                 if ( null === autoload ) then
--                         autoload = "yes";
--                 end;

--                 return add_option( option, value, "", autoload );
--         end;

--         serialized_value = maybe_serialize( value );

--         --
--         -- Fires immediately before an option value is updated.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string option    Name of the option to update.
--         -- @param mixed  old_value The old option value.
--         -- @param mixed  value     The new option value.
--         --
--         do_action( "update_option", option, old_value, value );

--         update_args = array(
--                 "option_value" => serialized_value,
--         );

--         if ( null !== autoload ) then
--                 update_args["autoload"] = ( "no" === autoload || false === autoload ) ? "no" : "yes";
--         end;

--         result = wpdb->update( wpdb->options, update_args, array( "option_name" => option ) );
--         if ( ! result ) then
--                 return false;
--         end;

--         notoptions = wp_cache_get( "notoptions", "options" );

--         if ( is_array( notoptions ) && isset( notoptions[ option ] ) ) then
--                 unset( notoptions[ option ] );
--                 wp_cache_set( "notoptions", notoptions, "options" );
--         end;

--         if ( ! wp_installing() ) then
--                 alloptions = wp_load_alloptions( true );
--                 if ( isset( alloptions[ option ] ) ) then
--                         alloptions[ option ] = serialized_value;
--                         wp_cache_set( "alloptions", alloptions, "options" );
--                 end; else then
--                         wp_cache_set( option, serialized_value, "options" );
--                 end;
--         end;

--         --
--         -- Fires after the value of a specific option has been successfully updated.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- @since 2.0.1
--         -- @since 4.4.0 The `option` parameter was added.
--         --
--         -- @param mixed  old_value The old option value.
--         -- @param mixed  value     The new option value.
--         -- @param string option    Option name.
--         --
--         do_action( "update_option_thenoptionend;", old_value, value, option );

--         --
--         -- Fires after the value of an option has been successfully updated.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string option    Name of the updated option.
--         -- @param mixed  old_value The old option value.
--         -- @param mixed  value     The new option value.
--         --
--         do_action( "updated_option", option, old_value, value );

--         return true;
-- end;

-- --
-- -- Adds a new option.
-- --
-- -- You do not need to serialize values. If the value needs to be serialized,
-- -- then it will be serialized before it is inserted into the database.
-- -- Remember, resources cannot be serialized or added as an option.
-- --
-- -- You can create options without values and then update the values later.
-- -- Existing options will not be updated and checks are performed to ensure that you
-- -- aren"t adding a protected WordPress option. Care should be taken to not name
-- -- options the same as the ones which are protected.
-- --
-- -- @since 1.0.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string      option     Name of the option to add. Expected to not be SQL-escaped.
-- -- @param mixed       value      Optional. Option value. Must be serializable if non-scalar.
-- --                                Expected to not be SQL-escaped.
-- -- @param string      deprecated Optional. Description. Not used anymore.
-- -- @param string|bool autoload   Optional. Whether to load the option when WordPress starts up.
-- --                                Default is enabled. Accepts "no" to disable for legacy reasons.
-- -- @return bool True if the option was added, false otherwise.
-- --
-- function add_option( option, value = "", deprecated = "", autoload = "yes" ) then
--         global wpdb;

--         if ( ! empty( deprecated ) ) then
--                 _deprecated_argument( __FUNCTION__, "2.3.0" );
--         end;

--         if ( is_scalar( option ) ) then
--                 option = trim( option );
--         end;

--         if ( empty( option ) ) then
--                 return false;
--         end;

--         /*
--         -- Until a proper _deprecated_option() function can be introduced,
--         -- redirect requests to deprecated keys to the new, correct ones.
--         --
--         deprecated_keys = array(
--                 "blacklist_keys"    => "disallowed_keys",
--                 "comment_whitelist" => "comment_previously_approved",
--         );

--         if ( isset( deprecated_keys[ option ] ) && ! wp_installing() ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "5.5.0",
--                         sprintf(
--                                 /* translators: 1: Deprecated option key, 2: New option key.--
--                                 __( "The "%1s" option key has been renamed to "%2s"." ),
--                                 option,
--                                 deprecated_keys[ option ]
--                         )
--                 );
--                 return add_option( deprecated_keys[ option ], value, deprecated, autoload );
--         end;

--         wp_protect_special_option( option );

--         if ( is_object( value ) ) then
--                 value = clone value;
--         end;

--         value = sanitize_option( option, value );

--         // Make sure the option doesn"t already exist.
--         // We can check the "notoptions" cache before we ask for a DB query.
--         notoptions = wp_cache_get( "notoptions", "options" );

--         if ( ! is_array( notoptions ) || ! isset( notoptions[ option ] ) ) then
--                 -- This filter is documented in wp-includes/option.php--
--                 if ( apply_filters( "default_option_thenoptionend;", false, option, false ) !== get_option( option ) ) then
--                         return false;
--                 end;
--         end;

--         serialized_value = maybe_serialize( value );
--         autoload         = ( "no" === autoload || false === autoload ) ? "no" : "yes";

--         --
--         -- Fires before an option is added.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string option Name of the option to add.
--         -- @param mixed  value  Value of the option.
--         --
--         do_action( "add_option", option, value );

--         result = wpdb->query( wpdb->prepare( "INSERT INTO `wpdb->options` (`option_name`, `option_value`, `autoload`) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE `option_name` = VALUES(`option_name`), `option_value` = VALUES(`option_value`), `autoload` = VALUES(`autoload`)", option, serialized_value, autoload ) );
--         if ( ! result ) then
--                 return false;
--         end;

--         if ( ! wp_installing() ) then
--                 if ( "yes" === autoload ) then
--                         alloptions            = wp_load_alloptions( true );
--                         alloptions[ option ] = serialized_value;
--                         wp_cache_set( "alloptions", alloptions, "options" );
--                 end; else then
--                         wp_cache_set( option, serialized_value, "options" );
--                 end;
--         end;

--         // This option exists now.
--         notoptions = wp_cache_get( "notoptions", "options" ); // Yes, again... we need it to be fresh.

--         if ( is_array( notoptions ) && isset( notoptions[ option ] ) ) then
--                 unset( notoptions[ option ] );
--                 wp_cache_set( "notoptions", notoptions, "options" );
--         end;

--         --
--         -- Fires after a specific option has been added.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- @since 2.5.0 As "add_option_thennameend;"
--         -- @since 3.0.0
--         --
--         -- @param string option Name of the option to add.
--         -- @param mixed  value  Value of the option.
--         --
--         do_action( "add_option_thenoptionend;", option, value );

--         --
--         -- Fires after an option has been added.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string option Name of the added option.
--         -- @param mixed  value  Value of the option.
--         --
--         do_action( "added_option", option, value );

--         return true;
-- end;

-- --
-- -- Removes option by name. Prevents removal of protected WordPress options.
-- --
-- -- @since 1.2.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string option Name of the option to delete. Expected to not be SQL-escaped.
-- -- @return bool True if the option was deleted, false otherwise.
-- --
-- function delete_option( option ) then
--         global wpdb;

--         if ( is_scalar( option ) ) then
--                 option = trim( option );
--         end;

--         if ( empty( option ) ) then
--                 return false;
--         end;

--         wp_protect_special_option( option );

--         // Get the ID, if no ID then return.
--         row = wpdb->get_row( wpdb->prepare( "SELECT autoload FROM wpdb->options WHERE option_name = %s", option ) );
--         if ( is_null( row ) ) then
--                 return false;
--         end;

--         --
--         -- Fires immediately before an option is deleted.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string option Name of the option to delete.
--         --
--         do_action( "delete_option", option );

--         result = wpdb->delete( wpdb->options, array( "option_name" => option ) );

--         if ( ! wp_installing() ) then
--                 if ( "yes" === row->autoload ) then
--                         alloptions = wp_load_alloptions( true );
--                         if ( is_array( alloptions ) && isset( alloptions[ option ] ) ) then
--                                 unset( alloptions[ option ] );
--                                 wp_cache_set( "alloptions", alloptions, "options" );
--                         end;
--                 end; else then
--                         wp_cache_delete( option, "options" );
--                 end;
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after a specific option has been deleted.
--                 --
--                 -- The dynamic portion of the hook name, `option`, refers to the option name.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string option Name of the deleted option.
--                 --
--                 do_action( "delete_option_thenoptionend;", option );

--                 --
--                 -- Fires after an option has been deleted.
--                 --
--                 -- @since 2.9.0
--                 --
--                 -- @param string option Name of the deleted option.
--                 --
--                 do_action( "deleted_option", option );

--                 return true;
--         end;

--         return false;
-- end;

-- --
-- -- Deletes a transient.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string transient Transient name. Expected to not be SQL-escaped.
-- -- @return bool True if the transient was deleted, false otherwise.
-- --
-- function delete_transient( transient ) then

--         --
--         -- Fires immediately before a specific transient is deleted.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string transient Transient name.
--         --
--         do_action( "delete_transient_thentransientend;", transient );

--         if ( wp_using_ext_object_cache() || wp_installing() ) then
--                 result = wp_cache_delete( transient, "transient" );
--         end; else then
--                 option_timeout = "_transient_timeout_" . transient;
--                 option         = "_transient_" . transient;
--                 result         = delete_option( option );

--                 if ( result ) then
--                         delete_option( option_timeout );
--                 end;
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after a transient is deleted.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string transient Deleted transient name.
--                 --
--                 do_action( "deleted_transient", transient );
--         end;

--         return result;
-- end;

-- --
-- -- Retrieves the value of a transient.
-- --
-- -- If the transient does not exist, does not have a value, or has expired,
-- -- then the return value will be false.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string transient Transient name. Expected to not be SQL-escaped.
-- -- @return mixed Value of transient.
-- --
-- function get_transient( transient ) then

--         --
--         -- Filters the value of an existing transient before it is retrieved.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- Returning a value other than false from the filter will short-circuit retrieval
--         -- and return that value instead.
--         --
--         -- @since 2.8.0
--         -- @since 4.4.0 The `transient` parameter was added
--         --
--         -- @param mixed  pre_transient The default value to return if the transient does not exist.
--         --                              Any value other than false will short-circuit the retrieval
--         --                              of the transient, and return that value.
--         -- @param string transient     Transient name.
--         --
--         pre = apply_filters( "pre_transient_thentransientend;", false, transient );

--         if ( false !== pre ) then
--                 return pre;
--         end;

--         if ( wp_using_ext_object_cache() || wp_installing() ) then
--                 value = wp_cache_get( transient, "transient" );
--         end; else then
--                 transient_option = "_transient_" . transient;
--                 if ( ! wp_installing() ) then
--                         // If option is not in alloptions, it is not autoloaded and thus has a timeout.
--                         alloptions = wp_load_alloptions();
--                         if ( ! isset( alloptions[ transient_option ] ) ) then
--                                 transient_timeout = "_transient_timeout_" . transient;
--                                 timeout           = get_option( transient_timeout );
--                                 if ( false !== timeout && timeout < time() ) then
--                                         delete_option( transient_option );
--                                         delete_option( transient_timeout );
--                                         value = false;
--                                 end;
--                         end;
--                 end;

--                 if ( ! isset( value ) ) then
--                         value = get_option( transient_option );
--                 end;
--         end;

--         --
--         -- Filters an existing transient"s value.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- @since 2.8.0
--         -- @since 4.4.0 The `transient` parameter was added
--         --
--         -- @param mixed  value     Value of transient.
--         -- @param string transient Transient name.
--         --
--         return apply_filters( "transient_thentransientend;", value, transient );
-- end;

-- --
-- -- Sets/updates the value of a transient.
-- --
-- -- You do not need to serialize values. If the value needs to be serialized,
-- -- then it will be serialized before it is set.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string transient  Transient name. Expected to not be SQL-escaped.
-- --                           Must be 172 characters or fewer in length.
-- -- @param mixed  value      Transient value. Must be serializable if non-scalar.
-- --                           Expected to not be SQL-escaped.
-- -- @param int    expiration Optional. Time until expiration in seconds. Default 0 (no expiration).
-- -- @return bool True if the value was set, false otherwise.
-- --
-- function set_transient( transient, value, expiration = 0 ) then

--         expiration = (int) expiration;

--         --
--         -- Filters a specific transient before its value is set.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- @since 3.0.0
--         -- @since 4.2.0 The `expiration` parameter was added.
--         -- @since 4.4.0 The `transient` parameter was added.
--         --
--         -- @param mixed  value      New value of transient.
--         -- @param int    expiration Time until expiration in seconds.
--         -- @param string transient  Transient name.
--         --
--         value = apply_filters( "pre_set_transient_thentransientend;", value, expiration, transient );

--         --
--         -- Filters the expiration for a transient before its value is set.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- @since 4.4.0
--         --
--         -- @param int    expiration Time until expiration in seconds. Use 0 for no expiration.
--         -- @param mixed  value      New value of transient.
--         -- @param string transient  Transient name.
--         --
--         expiration = apply_filters( "expiration_of_transient_thentransientend;", expiration, value, transient );

--         if ( wp_using_ext_object_cache() || wp_installing() ) then
--                 result = wp_cache_set( transient, value, "transient", expiration );
--         end; else then
--                 transient_timeout = "_transient_timeout_" . transient;
--                 transient_option  = "_transient_" . transient;

--                 if ( false === get_option( transient_option ) ) then
--                         autoload = "yes";
--                         if ( expiration ) then
--                                 autoload = "no";
--                                 add_option( transient_timeout, time() + expiration, "", "no" );
--                         end;
--                         result = add_option( transient_option, value, "", autoload );
--                 end; else then
--                         // If expiration is requested, but the transient has no timeout option,
--                         // delete, then re-create transient rather than update.
--                         update = true;

--                         if ( expiration ) then
--                                 if ( false === get_option( transient_timeout ) ) then
--                                         delete_option( transient_option );
--                                         add_option( transient_timeout, time() + expiration, "", "no" );
--                                         result = add_option( transient_option, value, "", "no" );
--                                         update = false;
--                                 end; else then
--                                         update_option( transient_timeout, time() + expiration );
--                                 end;
--                         end;

--                         if ( update ) then
--                                 result = update_option( transient_option, value );
--                         end;
--                 end;
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after the value for a specific transient has been set.
--                 --
--                 -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--                 --
--                 -- @since 3.0.0
--                 -- @since 3.6.0 The `value` and `expiration` parameters were added.
--                 -- @since 4.4.0 The `transient` parameter was added.
--                 --
--                 -- @param mixed  value      Transient value.
--                 -- @param int    expiration Time until expiration in seconds.
--                 -- @param string transient  The name of the transient.
--                 --
--                 do_action( "set_transient_thentransientend;", value, expiration, transient );

--                 --
--                 -- Fires after the value for a transient has been set.
--                 --
--                 -- @since 3.0.0
--                 -- @since 3.6.0 The `value` and `expiration` parameters were added.
--                 --
--                 -- @param string transient  The name of the transient.
--                 -- @param mixed  value      Transient value.
--                 -- @param int    expiration Time until expiration in seconds.
--                 --
--                 do_action( "setted_transient", transient, value, expiration );
--         end;

--         return result;
-- end;

-- --
-- -- Deletes all expired transients.
-- --
-- -- Note that this function won"t do anything if an external object cache is in use.
-- --
-- -- The multi-table delete syntax is used to delete the transient record
-- -- from table a, and the corresponding transient_timeout record from table b.
-- --
-- -- @since 4.9.0
-- --
-- -- @param bool force_db Optional. Force cleanup to run against the database even when an external object cache is used.
-- --
-- function delete_expired_transients( force_db = false ) then
--         global wpdb;

--         if ( ! force_db && wp_using_ext_object_cache() ) then
--                 return;
--         end;

--         wpdb->query(
--                 wpdb->prepare(
--                         "DELETE a, b FROM thenwpdb->optionsend; a, thenwpdb->optionsend; b
--                         WHERE a.option_name LIKE %s
--                         AND a.option_name NOT LIKE %s
--                         AND b.option_name = CONCAT( "_transient_timeout_", SUBSTRING( a.option_name, 12 ) )
--                         AND b.option_value < %d",
--                         wpdb->esc_like( "_transient_" ) . "%",
--                         wpdb->esc_like( "_transient_timeout_" ) . "%",
--                         time()
--                 )
--         );

--         if ( ! is_multisite() ) then
--                 // Single site stores site transients in the options table.
--                 wpdb->query(
--                         wpdb->prepare(
--                                 "DELETE a, b FROM thenwpdb->optionsend; a, thenwpdb->optionsend; b
--                                 WHERE a.option_name LIKE %s
--                                 AND a.option_name NOT LIKE %s
--                                 AND b.option_name = CONCAT( "_site_transient_timeout_", SUBSTRING( a.option_name, 17 ) )
--                                 AND b.option_value < %d",
--                                 wpdb->esc_like( "_site_transient_" ) . "%",
--                                 wpdb->esc_like( "_site_transient_timeout_" ) . "%",
--                                 time()
--                         )
--                 );
--         end; elseif ( is_multisite() && is_main_site() && is_main_network() ) then
--                 // Multisite stores site transients in the sitemeta table.
--                 wpdb->query(
--                         wpdb->prepare(
--                                 "DELETE a, b FROM thenwpdb->sitemetaend; a, thenwpdb->sitemetaend; b
--                                 WHERE a.meta_key LIKE %s
--                                 AND a.meta_key NOT LIKE %s
--                                 AND b.meta_key = CONCAT( "_site_transient_timeout_", SUBSTRING( a.meta_key, 17 ) )
--                                 AND b.meta_value < %d",
--                                 wpdb->esc_like( "_site_transient_" ) . "%",
--                                 wpdb->esc_like( "_site_transient_timeout_" ) . "%",
--                                 time()
--                         )
--                 );
--         end;
-- end;

-- --
-- -- Saves and restores user interface settings stored in a cookie.
-- --
-- -- Checks if the current user-settings cookie is updated and stores it. When no
-- -- cookie exists (different browser used), adds the last saved cookie restoring
-- -- the settings.
-- --
-- -- @since 2.7.0
-- --
-- function wp_user_settings() then

--         if ( ! is_admin() || wp_doing_ajax() ) then
--                 return;
--         end;

--         user_id = get_current_user_id();
--         if ( ! user_id ) then
--                 return;
--         end;

--         if ( ! is_user_member_of_blog() ) then
--                 return;
--         end;

--         settings = (string) get_user_option( "user-settings", user_id );

--         if ( isset( _COOKIE[ "wp-settings-" . user_id ] ) ) then
--                 cookie = preg_replace( "/[^A-Za-z0-9=&_]/", "", _COOKIE[ "wp-settings-" . user_id ] );

--                 // No change or both empty.
--                 if ( cookie == settings ) then
--                         return;
--                 end;

--                 last_saved = (int) get_user_option( "user-settings-time", user_id );
--                 current    = isset( _COOKIE[ "wp-settings-time-" . user_id ] ) ? preg_replace( "/[^0-9]/", "", _COOKIE[ "wp-settings-time-" . user_id ] ) : 0;

--                 // The cookie is newer than the saved value. Update the user_option and leave the cookie as-is.
--                 if ( current > last_saved ) then
--                         update_user_option( user_id, "user-settings", cookie, false );
--                         update_user_option( user_id, "user-settings-time", time() - 5, false );
--                         return;
--                 end;
--         end;

--         // The cookie is not set in the current browser or the saved value is newer.
--         secure = ( "https" === parse_url( admin_url(), PHP_URL_SCHEME ) );
--         setcookie( "wp-settings-" . user_id, settings, time() + YEAR_IN_SECONDS, SITECOOKIEPATH, "", secure );
--         setcookie( "wp-settings-time-" . user_id, time(), time() + YEAR_IN_SECONDS, SITECOOKIEPATH, "", secure );
--         _COOKIE[ "wp-settings-" . user_id ] = settings;
-- end;

-- --
-- -- Retrieves user interface setting value based on setting name.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string       name    The name of the setting.
-- -- @param string|false default Optional. Default value to return when name is not set. Default false.
-- -- @return mixed The last saved user setting or the default value/false if it doesn"t exist.
-- --
-- function get_user_setting( name, default = false ) then
--         all_user_settings = get_all_user_settings();

--         return isset( all_user_settings[ name ] ) ? all_user_settings[ name ] : default;
-- end;

-- --
-- -- Adds or updates user interface setting.
-- --
-- -- Both `name` and `value` can contain only ASCII letters, numbers, hyphens, and underscores.
-- --
-- -- This function has to be used before any output has started as it calls `setcookie()`.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string name  The name of the setting.
-- -- @param string value The value for the setting.
-- -- @return bool|null True if set successfully, false otherwise.
-- --                   Null if the current user is not a member of the site.
-- --
-- function set_user_setting( name, value ) then
--         if ( headers_sent() ) then
--                 return false;
--         end;

--         all_user_settings          = get_all_user_settings();
--         all_user_settings[ name ] = value;

--         return wp_set_all_user_settings( all_user_settings );
-- end;

-- --
-- -- Deletes user interface settings.
-- --
-- -- Deleting settings would reset them to the defaults.
-- --
-- -- This function has to be used before any output has started as it calls `setcookie()`.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string names The name or array of names of the setting to be deleted.
-- -- @return bool|null True if deleted successfully, false otherwise.
-- --                   Null if the current user is not a member of the site.
-- --
-- function delete_user_setting( names ) then
--         if ( headers_sent() ) then
--                 return false;
--         end;

--         all_user_settings = get_all_user_settings();
--         names             = (array) names;
--         deleted           = false;

--         foreach ( names as name ) then
--                 if ( isset( all_user_settings[ name ] ) ) then
--                         unset( all_user_settings[ name ] );
--                         deleted = true;
--                 end;
--         end;

--         if ( deleted ) then
--                 return wp_set_all_user_settings( all_user_settings );
--         end;

--         return false;
-- end;

-- --
-- -- Retrieves all user interface settings.
-- --
-- -- @since 2.7.0
-- --
-- -- @global array _updated_user_settings
-- --
-- -- @return array The last saved user settings or empty array.
-- --
-- function get_all_user_settings() then
--         global _updated_user_settings;

--         user_id = get_current_user_id();
--         if ( ! user_id ) then
--                 return array();
--         end;

--         if ( isset( _updated_user_settings ) && is_array( _updated_user_settings ) ) then
--                 return _updated_user_settings;
--         end;

--         user_settings = array();

--         if ( isset( _COOKIE[ "wp-settings-" . user_id ] ) ) then
--                 cookie = preg_replace( "/[^A-Za-z0-9=&_-]/", "", _COOKIE[ "wp-settings-" . user_id ] );

--                 if ( strpos( cookie, "=" ) ) then // "=" cannot be 1st char.
--                         parse_str( cookie, user_settings );
--                 end;
--         end; else then
--                 option = get_user_option( "user-settings", user_id );

--                 if ( option && is_string( option ) ) then
--                         parse_str( option, user_settings );
--                 end;
--         end;

--         _updated_user_settings = user_settings;
--         return user_settings;
-- end;

-- --
-- -- Private. Sets all user interface settings.
-- --
-- -- @since 2.8.0
-- -- @access private
-- --
-- -- @global array _updated_user_settings
-- --
-- -- @param array user_settings User settings.
-- -- @return bool|null True if set successfully, false if the current user could not be found.
-- --                   Null if the current user is not a member of the site.
-- --
-- function wp_set_all_user_settings( user_settings ) then
--         global _updated_user_settings;

--         user_id = get_current_user_id();
--         if ( ! user_id ) then
--                 return false;
--         end;

--         if ( ! is_user_member_of_blog() ) then
--                 return;
--         end;

--         settings = "";
--         foreach ( user_settings as name => value ) then
--                 _name  = preg_replace( "/[^A-Za-z0-9_-]+/", "", name );
--                 _value = preg_replace( "/[^A-Za-z0-9_-]+/", "", value );

--                 if ( ! empty( _name ) ) then
--                         settings .= _name . "=" . _value . "&";
--                 end;
--         end;

--         settings = rtrim( settings, "&" );
--         parse_str( settings, _updated_user_settings );

--         update_user_option( user_id, "user-settings", settings, false );
--         update_user_option( user_id, "user-settings-time", time(), false );

--         return true;
-- end;

-- --
-- -- Deletes the user settings of the current user.
-- --
-- -- @since 2.7.0
-- --
-- function delete_all_user_settings() then
--         user_id = get_current_user_id();
--         if ( ! user_id ) then
--                 return;
--         end;

--         update_user_option( user_id, "user-settings", "", false );
--         setcookie( "wp-settings-" . user_id, " ", time() - YEAR_IN_SECONDS, SITECOOKIEPATH );
-- end;

-- --
-- -- Retrieve an option value for the current network based on name of option.
-- --
-- -- @since 2.8.0
-- -- @since 4.4.0 The `use_cache` parameter was deprecated.
-- -- @since 4.4.0 Modified into wrapper for get_network_option()
-- --
-- -- @see get_network_option()
-- --
-- -- @param string option     Name of the option to retrieve. Expected to not be SQL-escaped.
-- -- @param mixed  default    Optional. Value to return if the option doesn"t exist. Default false.
-- -- @param bool   deprecated Whether to use cache. Multisite only. Always set to true.
-- -- @return mixed Value set for the option.
-- --
-- function get_site_option( option, default = false, deprecated = true ) then
   function Get_Site_Option (Option     : String;
                             Default    : Boolean := False;
                             Deprecated : Boolean := True)
                             return String
   is
   begin
      return Get_Network_Option (0, -- null,
                                 Option, Default);
   end Get_Site_Option;

-- --
-- -- Adds a new option for the current network.
-- --
-- -- Existing options will not be updated. Note that prior to 3.3 this wasn"t the case.
-- --
-- -- @since 2.8.0
-- -- @since 4.4.0 Modified into wrapper for add_network_option()
-- --
-- -- @see add_network_option()
-- --
-- -- @param string option Name of the option to add. Expected to not be SQL-escaped.
-- -- @param mixed  value  Option value, can be anything. Expected to not be SQL-escaped.
-- -- @return bool True if the option was added, false otherwise.
-- --
-- function add_site_option( option, value ) then
--         return add_network_option( null, option, value );
-- end;

-- --
-- -- Removes a option by name for the current network.
-- --
-- -- @since 2.8.0
-- -- @since 4.4.0 Modified into wrapper for delete_network_option()
-- --
-- -- @see delete_network_option()
-- --
-- -- @param string option Name of the option to delete. Expected to not be SQL-escaped.
-- -- @return bool True if the option was deleted, false otherwise.
-- --
-- function delete_site_option( option ) then
--         return delete_network_option( null, option );
-- end;

-- --
-- -- Updates the value of an option that was already added for the current network.
-- --
-- -- @since 2.8.0
-- -- @since 4.4.0 Modified into wrapper for update_network_option()
-- --
-- -- @see update_network_option()
-- --
-- -- @param string option Name of the option. Expected to not be SQL-escaped.
-- -- @param mixed  value  Option value. Expected to not be SQL-escaped.
-- -- @return bool True if the value was updated, false otherwise.
-- --
-- function update_site_option( option, value ) then
--         return update_network_option( null, option, value );
-- end;

-- --
-- -- Retrieves a network"s option value based on the option name.
-- --
-- -- @since 4.4.0
-- --
-- -- @see get_option()
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int    network_id ID of the network. Can be null to default to the current network ID.
-- -- @param string option     Name of the option to retrieve. Expected to not be SQL-escaped.
-- -- @param mixed  default    Optional. Value to return if the option doesn"t exist. Default false.
-- -- @return mixed Value set for the option.
-- --
-- function get_network_option( network_id, option, default = false ) then
--         global wpdb;

--         if ( network_id && ! is_numeric( network_id ) ) then
--                 return false;
--         end;

--         network_id = (int) network_id;

--         // Fallback to the current network if a network ID is not specified.
--         if ( ! network_id ) then
--                 network_id = get_current_network_id();
--         end;

--         --
--         -- Filters the value of an existing network option before it is retrieved.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- Returning a value other than false from the filter will short-circuit retrieval
--         -- and return that value instead.
--         --
--         -- @since 2.9.0 As "pre_site_option_" . key
--         -- @since 3.0.0
--         -- @since 4.4.0 The `option` parameter was added.
--         -- @since 4.7.0 The `network_id` parameter was added.
--         -- @since 4.9.0 The `default` parameter was added.
--         --
--         -- @param mixed  pre_option The value to return instead of the option value. This differs
--         --                           from `default`, which is used as the fallback value in the event
--         --                           the option doesn"t exist elsewhere in get_network_option().
--         --                           Default false (to skip past the short-circuit).
--         -- @param string option     Option name.
--         -- @param int    network_id ID of the network.
--         -- @param mixed  default    The fallback value to return if the option does not exist.
--         --                           Default false.
--         --
--         pre = apply_filters( "pre_site_option_thenoptionend;", false, option, network_id, default );

--         if ( false !== pre ) then
--                 return pre;
--         end;

--         // Prevent non-existent options from triggering multiple queries.
--         notoptions_key = "network_id:notoptions";
--         notoptions     = wp_cache_get( notoptions_key, "site-options" );

--         if ( is_array( notoptions ) && isset( notoptions[ option ] ) ) then

--                 --
--                 -- Filters the value of a specific default network option.
--                 --
--                 -- The dynamic portion of the hook name, `option`, refers to the option name.
--                 --
--                 -- @since 3.4.0
--                 -- @since 4.4.0 The `option` parameter was added.
--                 -- @since 4.7.0 The `network_id` parameter was added.
--                 --
--                 -- @param mixed  default    The value to return if the site option does not exist
--                 --                           in the database.
--                 -- @param string option     Option name.
--                 -- @param int    network_id ID of the network.
--                 --
--                 return apply_filters( "default_site_option_thenoptionend;", default, option, network_id );
--         end;

--         if ( ! is_multisite() ) then
--                 -- This filter is documented in wp-includes/option.php--
--                 default = apply_filters( "default_site_option_" . option, default, option, network_id );
--                 value   = get_option( option, default );
--         end; else then
--                 cache_key = "network_id:option";
--                 value     = wp_cache_get( cache_key, "site-options" );

--                 if ( ! isset( value ) || false === value ) then
--                         row = wpdb->get_row( wpdb->prepare( "SELECT meta_value FROM wpdb->sitemeta WHERE meta_key = %s AND site_id = %d", option, network_id ) );

--                         // Has to be get_row() instead of get_var() because of funkiness with 0, false, null values.
--                         if ( is_object( row ) ) then
--                                 value = row->meta_value;
--                                 value = maybe_unserialize( value );
--                                 wp_cache_set( cache_key, value, "site-options" );
--                         end; else then
--                                 if ( ! is_array( notoptions ) ) then
--                                         notoptions = array();
--                                 end;

--                                 notoptions[ option ] = true;
--                                 wp_cache_set( notoptions_key, notoptions, "site-options" );

--                                 -- This filter is documented in wp-includes/option.php--
--                                 value = apply_filters( "default_site_option_" . option, default, option, network_id );
--                         end;
--                 end;
--         end;

--         if ( ! is_array( notoptions ) ) then
--                 notoptions = array();
--                 wp_cache_set( notoptions_key, notoptions, "site-options" );
--         end;

--         --
--         -- Filters the value of an existing network option.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- @since 2.9.0 As "site_option_" . key
--         -- @since 3.0.0
--         -- @since 4.4.0 The `option` parameter was added.
--         -- @since 4.7.0 The `network_id` parameter was added.
--         --
--         -- @param mixed  value      Value of network option.
--         -- @param string option     Option name.
--         -- @param int    network_id ID of the network.
--         --
--         return apply_filters( "site_option_thenoptionend;", value, option, network_id );
-- end;

-- --
-- -- Adds a new network option.
-- --
-- -- Existing options will not be updated.
-- --
-- -- @since 4.4.0
-- --
-- -- @see add_option()
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int    network_id ID of the network. Can be null to default to the current network ID.
-- -- @param string option     Name of the option to add. Expected to not be SQL-escaped.
-- -- @param mixed  value      Option value, can be anything. Expected to not be SQL-escaped.
-- -- @return bool True if the option was added, false otherwise.
-- --
-- function add_network_option( network_id, option, value ) then
--         global wpdb;

--         if ( network_id && ! is_numeric( network_id ) ) then
--                 return false;
--         end;

--         network_id = (int) network_id;

--         // Fallback to the current network if a network ID is not specified.
--         if ( ! network_id ) then
--                 network_id = get_current_network_id();
--         end;

--         wp_protect_special_option( option );

--         --
--         -- Filters the value of a specific network option before it is added.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- @since 2.9.0 As "pre_add_site_option_" . key
--         -- @since 3.0.0
--         -- @since 4.4.0 The `option` parameter was added.
--         -- @since 4.7.0 The `network_id` parameter was added.
--         --
--         -- @param mixed  value      Value of network option.
--         -- @param string option     Option name.
--         -- @param int    network_id ID of the network.
--         --
--         value = apply_filters( "pre_add_site_option_thenoptionend;", value, option, network_id );

--         notoptions_key = "network_id:notoptions";

--         if ( ! is_multisite() ) then
--                 result = add_option( option, value, "", "no" );
--         end; else then
--                 cache_key = "network_id:option";

--                 // Make sure the option doesn"t already exist.
--                 // We can check the "notoptions" cache before we ask for a DB query.
--                 notoptions = wp_cache_get( notoptions_key, "site-options" );

--                 if ( ! is_array( notoptions ) || ! isset( notoptions[ option ] ) ) then
--                         if ( false !== get_network_option( network_id, option, false ) ) then
--                                 return false;
--                         end;
--                 end;

--                 value = sanitize_option( option, value );

--                 serialized_value = maybe_serialize( value );
--                 result           = wpdb->insert(
--                         wpdb->sitemeta,
--                         array(
--                                 "site_id"    => network_id,
--                                 "meta_key"   => option,
--                                 "meta_value" => serialized_value,
--                         )
--                 );

--                 if ( ! result ) then
--                         return false;
--                 end;

--                 wp_cache_set( cache_key, value, "site-options" );

--                 // This option exists now.
--                 notoptions = wp_cache_get( notoptions_key, "site-options" ); // Yes, again... we need it to be fresh.

--                 if ( is_array( notoptions ) && isset( notoptions[ option ] ) ) then
--                         unset( notoptions[ option ] );
--                         wp_cache_set( notoptions_key, notoptions, "site-options" );
--                 end;
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after a specific network option has been successfully added.
--                 --
--                 -- The dynamic portion of the hook name, `option`, refers to the option name.
--                 --
--                 -- @since 2.9.0 As "add_site_option_thenkeyend;"
--                 -- @since 3.0.0
--                 -- @since 4.7.0 The `network_id` parameter was added.
--                 --
--                 -- @param string option     Name of the network option.
--                 -- @param mixed  value      Value of the network option.
--                 -- @param int    network_id ID of the network.
--                 --
--                 do_action( "add_site_option_thenoptionend;", option, value, network_id );

--                 --
--                 -- Fires after a network option has been successfully added.
--                 --
--                 -- @since 3.0.0
--                 -- @since 4.7.0 The `network_id` parameter was added.
--                 --
--                 -- @param string option     Name of the network option.
--                 -- @param mixed  value      Value of the network option.
--                 -- @param int    network_id ID of the network.
--                 --
--                 do_action( "add_site_option", option, value, network_id );

--                 return true;
--         end;

--         return false;
-- end;

-- --
-- -- Removes a network option by name.
-- --
-- -- @since 4.4.0
-- --
-- -- @see delete_option()
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int    network_id ID of the network. Can be null to default to the current network ID.
-- -- @param string option     Name of the option to delete. Expected to not be SQL-escaped.
-- -- @return bool True if the option was deleted, false otherwise.
-- --
-- function delete_network_option( network_id, option ) then
--         global wpdb;

--         if ( network_id && ! is_numeric( network_id ) ) then
--                 return false;
--         end;

--         network_id = (int) network_id;

--         // Fallback to the current network if a network ID is not specified.
--         if ( ! network_id ) then
--                 network_id = get_current_network_id();
--         end;

--         --
--         -- Fires immediately before a specific network option is deleted.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- @since 3.0.0
--         -- @since 4.4.0 The `option` parameter was added.
--         -- @since 4.7.0 The `network_id` parameter was added.
--         --
--         -- @param string option     Option name.
--         -- @param int    network_id ID of the network.
--         --
--         do_action( "pre_delete_site_option_thenoptionend;", option, network_id );

--         if ( ! is_multisite() ) then
--                 result = delete_option( option );
--         end; else then
--                 row = wpdb->get_row( wpdb->prepare( "SELECT meta_id FROM thenwpdb->sitemetaend; WHERE meta_key = %s AND site_id = %d", option, network_id ) );
--                 if ( is_null( row ) || ! row->meta_id ) then
--                         return false;
--                 end;
--                 cache_key = "network_id:option";
--                 wp_cache_delete( cache_key, "site-options" );

--                 result = wpdb->delete(
--                         wpdb->sitemeta,
--                         array(
--                                 "meta_key" => option,
--                                 "site_id"  => network_id,
--                         )
--                 );
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after a specific network option has been deleted.
--                 --
--                 -- The dynamic portion of the hook name, `option`, refers to the option name.
--                 --
--                 -- @since 2.9.0 As "delete_site_option_thenkeyend;"
--                 -- @since 3.0.0
--                 -- @since 4.7.0 The `network_id` parameter was added.
--                 --
--                 -- @param string option     Name of the network option.
--                 -- @param int    network_id ID of the network.
--                 --
--                 do_action( "delete_site_option_thenoptionend;", option, network_id );

--                 --
--                 -- Fires after a network option has been deleted.
--                 --
--                 -- @since 3.0.0
--                 -- @since 4.7.0 The `network_id` parameter was added.
--                 --
--                 -- @param string option     Name of the network option.
--                 -- @param int    network_id ID of the network.
--                 --
--                 do_action( "delete_site_option", option, network_id );

--                 return true;
--         end;

--         return false;
-- end;

-- --
-- -- Updates the value of a network option that was already added.
-- --
-- -- @since 4.4.0
-- --
-- -- @see update_option()
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int    network_id ID of the network. Can be null to default to the current network ID.
-- -- @param string option     Name of the option. Expected to not be SQL-escaped.
-- -- @param mixed  value      Option value. Expected to not be SQL-escaped.
-- -- @return bool True if the value was updated, false otherwise.
-- --
-- function update_network_option( network_id, option, value ) then
--         global wpdb;

--         if ( network_id && ! is_numeric( network_id ) ) then
--                 return false;
--         end;

--         network_id = (int) network_id;

--         // Fallback to the current network if a network ID is not specified.
--         if ( ! network_id ) then
--                 network_id = get_current_network_id();
--         end;

--         wp_protect_special_option( option );

--         old_value = get_network_option( network_id, option, false );

--         --
--         -- Filters a specific network option before its value is updated.
--         --
--         -- The dynamic portion of the hook name, `option`, refers to the option name.
--         --
--         -- @since 2.9.0 As "pre_update_site_option_" . key
--         -- @since 3.0.0
--         -- @since 4.4.0 The `option` parameter was added.
--         -- @since 4.7.0 The `network_id` parameter was added.
--         --
--         -- @param mixed  value      New value of the network option.
--         -- @param mixed  old_value  Old value of the network option.
--         -- @param string option     Option name.
--         -- @param int    network_id ID of the network.
--         --
--         value = apply_filters( "pre_update_site_option_thenoptionend;", value, old_value, option, network_id );

--         /*
--         -- If the new and old values are the same, no need to update.
--         --
--         -- Unserialized values will be adequate in most cases. If the unserialized
--         -- data differs, the (maybe) serialized data is checked to avoid
--         -- unnecessary database calls for otherwise identical object instances.
--         --
--         -- See https://core.trac.wordpress.org/ticket/44956
--         --
--         if ( value === old_value || maybe_serialize( value ) === maybe_serialize( old_value ) ) then
--                 return false;
--         end;

--         if ( false === old_value ) then
--                 return add_network_option( network_id, option, value );
--         end;

--         notoptions_key = "network_id:notoptions";
--         notoptions     = wp_cache_get( notoptions_key, "site-options" );

--         if ( is_array( notoptions ) && isset( notoptions[ option ] ) ) then
--                 unset( notoptions[ option ] );
--                 wp_cache_set( notoptions_key, notoptions, "site-options" );
--         end;

--         if ( ! is_multisite() ) then
--                 result = update_option( option, value, "no" );
--         end; else then
--                 value = sanitize_option( option, value );

--                 serialized_value = maybe_serialize( value );
--                 result           = wpdb->update(
--                         wpdb->sitemeta,
--                         array( "meta_value" => serialized_value ),
--                         array(
--                                 "site_id"  => network_id,
--                                 "meta_key" => option,
--                         )
--                 );

--                 if ( result ) then
--                         cache_key = "network_id:option";
--                         wp_cache_set( cache_key, value, "site-options" );
--                 end;
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after the value of a specific network option has been successfully updated.
--                 --
--                 -- The dynamic portion of the hook name, `option`, refers to the option name.
--                 --
--                 -- @since 2.9.0 As "update_site_option_thenkeyend;"
--                 -- @since 3.0.0
--                 -- @since 4.7.0 The `network_id` parameter was added.
--                 --
--                 -- @param string option     Name of the network option.
--                 -- @param mixed  value      Current value of the network option.
--                 -- @param mixed  old_value  Old value of the network option.
--                 -- @param int    network_id ID of the network.
--                 --
--                 do_action( "update_site_option_thenoptionend;", option, value, old_value, network_id );

--                 --
--                 -- Fires after the value of a network option has been successfully updated.
--                 --
--                 -- @since 3.0.0
--                 -- @since 4.7.0 The `network_id` parameter was added.
--                 --
--                 -- @param string option     Name of the network option.
--                 -- @param mixed  value      Current value of the network option.
--                 -- @param mixed  old_value  Old value of the network option.
--                 -- @param int    network_id ID of the network.
--                 --
--                 do_action( "update_site_option", option, value, old_value, network_id );

--                 return true;
--         end;

--         return false;
-- end;

-- --
-- -- Deletes a site transient.
-- --
-- -- @since 2.9.0
-- --
-- -- @param string transient Transient name. Expected to not be SQL-escaped.
-- -- @return bool True if the transient was deleted, false otherwise.
-- --
-- function delete_site_transient( transient ) then

--         --
--         -- Fires immediately before a specific site transient is deleted.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string transient Transient name.
--         --
--         do_action( "delete_site_transient_thentransientend;", transient );

--         if ( wp_using_ext_object_cache() || wp_installing() ) then
--                 result = wp_cache_delete( transient, "site-transient" );
--         end; else then
--                 option_timeout = "_site_transient_timeout_" . transient;
--                 option         = "_site_transient_" . transient;
--                 result         = delete_site_option( option );

--                 if ( result ) then
--                         delete_site_option( option_timeout );
--                 end;
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after a transient is deleted.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string transient Deleted transient name.
--                 --
--                 do_action( "deleted_site_transient", transient );
--         end;

--         return result;
-- end;

-- --
-- -- Retrieves the value of a site transient.
-- --
-- -- If the transient does not exist, does not have a value, or has expired,
-- -- then the return value will be false.
-- --
-- -- @since 2.9.0
-- --
-- -- @see get_transient()
-- --
-- -- @param string transient Transient name. Expected to not be SQL-escaped.
-- -- @return mixed Value of transient.
-- --
-- function get_site_transient( transient ) then
   function Get_Site_Transient (Transient : String)
                                return Hb_Common.String_Maps.Map
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Inc_Caches;
      use Inc_Load;

      Found : Boolean;
      Value : Unbounded_String; -- Array_Type;
   begin
      --
      -- Filters the value of an existing site transient before it is retrieved.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      --  name.
      --
      -- Returning a value other than boolean false will short-circuit retrieval and
      -- return that value instead.
      --
      -- @since 2.9.0
      -- @since 4.4.0 The `transient` parameter was added.
      --
      -- @param mixed  pre_site_transient The default value to return if the site
      --                                  transient does not exist. Any value other
      --                                  than false will short-circuit the retrieval
      --                                  of the transient, and return that value.
      -- @param string transient          Transient name.
      --
--    Pre := Apply_Filters ("pre_site_transient_" & Transient, False, Transient);

      -- -- if False /= Pre then
      -- --    return Pre;
      -- -- end if;

      if
        Wp_Using_Ext_Object_Cache -- or else
--      Wp_Installing
      then
         Value := +Wp_Cache_Get (Transient, "site-transient", Found => Found);
      else
         -- Core transients that do not have a timeout. Listed here so querying
         -- timeouts can be avoided.
         declare
            No_Timeout : constant List_Type := To_List ((+"update_core",
                                                         +"update_plugins",
                                                         +"update_themes"));
            Transient_Option : constant String := "_site_transient_" & Transient;
         begin
            if not In_Array (Transient, No_Timeout, True) then
               declare
                  Transient_Timeout : String :=
                    "_site_transient_timeout_" & Transient;

--                Timeout := Get_Site_Option (Transient_Timeout);
               begin
                  null;
                  -- if false /= timeout and then Timeout < Time() ) then
                  --    Delete_Site_Option (Transient_Option);
                  --    Delete_Site_Option (Transient_Timeout);
                  --    Value := False;
                  -- end if;
               end;
            end if;

            if not Isset (-Value) then
               Value := +Get_Site_Option (Transient_Option);
            end if;
         end;
      end if;

      --
      -- Filters the value of an existing site transient.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      --  name.
      --
      -- @since 2.9.0
      -- @since 4.4.0 The `transient` parameter was added.
      --
      -- @param mixed  value     Value of site transient.
      -- @param string transient Transient name.
      --
      declare
         use Inc_Plugins;

         M : Hb_Common.String_Maps.Map;
         R : constant String :=
           Apply_Filters ("site_transient_" & Transient, -Value, Transient);
      begin
         M.Include (R, R);
         return M;
      end;
   end Get_Site_Transient;

-- --
-- -- Sets/updates the value of a site transient.
-- --
-- -- You do not need to serialize values. If the value needs to be serialized,
-- -- then it will be serialized before it is set.
-- --
-- -- @since 2.9.0
-- --
-- -- @see set_transient()
-- --
-- -- @param string transient  Transient name. Expected to not be SQL-escaped. Must be
-- --                           167 characters or fewer in length.
-- -- @param mixed  value      Transient value. Expected to not be SQL-escaped.
-- -- @param int    expiration Optional. Time until expiration in seconds. Default 0 (no expiration).
-- -- @return bool True if the value was set, false otherwise.
-- --
-- function set_site_transient( transient, value, expiration = 0 ) then

--         --
--         -- Filters the value of a specific site transient before it is set.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- @since 3.0.0
--         -- @since 4.4.0 The `transient` parameter was added.
--         --
--         -- @param mixed  value     New value of site transient.
--         -- @param string transient Transient name.
--         --
--         value = apply_filters( "pre_set_site_transient_thentransientend;", value, transient );

--         expiration = (int) expiration;

--         --
--         -- Filters the expiration for a site transient before its value is set.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- @since 4.4.0
--         --
--         -- @param int    expiration Time until expiration in seconds. Use 0 for no expiration.
--         -- @param mixed  value      New value of site transient.
--         -- @param string transient  Transient name.
--         --
--         expiration = apply_filters( "expiration_of_site_transient_thentransientend;", expiration, value, transient );

--         if ( wp_using_ext_object_cache() || wp_installing() ) then
--                 result = wp_cache_set( transient, value, "site-transient", expiration );
--         end; else then
--                 transient_timeout = "_site_transient_timeout_" . transient;
--                 option            = "_site_transient_" . transient;

--                 if ( false === get_site_option( option ) ) then
--                         if ( expiration ) then
--                                 add_site_option( transient_timeout, time() + expiration );
--                         end;
--                         result = add_site_option( option, value );
--                 end; else then
--                         if ( expiration ) then
--                                 update_site_option( transient_timeout, time() + expiration );
--                         end;
--                         result = update_site_option( option, value );
--                 end;
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after the value for a specific site transient has been set.
--                 --
--                 -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--                 --
--                 -- @since 3.0.0
--                 -- @since 4.4.0 The `transient` parameter was added
--                 --
--                 -- @param mixed  value      Site transient value.
--                 -- @param int    expiration Time until expiration in seconds.
--                 -- @param string transient  Transient name.
--                 --
--                 do_action( "set_site_transient_thentransientend;", value, expiration, transient );

--                 --
--                 -- Fires after the value for a site transient has been set.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string transient  The name of the site transient.
--                 -- @param mixed  value      Site transient value.
--                 -- @param int    expiration Time until expiration in seconds.
--                 --
--                 do_action( "setted_site_transient", transient, value, expiration );
--         end;

--         return result;
-- end;

-- --
-- -- Registers default settings available in WordPress.
-- --
-- -- The settings registered here are primarily useful for the REST API, so this
-- -- does not encompass all settings available in WordPress.
-- --
-- -- @since 4.7.0
-- -- @since 6.0.1 The `show_on_front`, `page_on_front`, and `page_for_posts` options were added.
-- --
-- function register_initial_settings() then
--         register_setting(
--                 "general",
--                 "blogname",
--                 array(
--                         "show_in_rest" => array(
--                                 "name" => "title",
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "Site title." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "blogdescription",
--                 array(
--                         "show_in_rest" => array(
--                                 "name" => "description",
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "Site tagline." ),
--                 )
--         );

--         if ( ! is_multisite() ) then
--                 register_setting(
--                         "general",
--                         "siteurl",
--                         array(
--                                 "show_in_rest" => array(
--                                         "name"   => "url",
--                                         "schema" => array(
--                                                 "format" => "uri",
--                                         ),
--                                 ),
--                                 "type"         => "string",
--                                 "description"  => __( "Site URL." ),
--                         )
--                 );
--         end;

--         if ( ! is_multisite() ) then
--                 register_setting(
--                         "general",
--                         "admin_email",
--                         array(
--                                 "show_in_rest" => array(
--                                         "name"   => "email",
--                                         "schema" => array(
--                                                 "format" => "email",
--                                         ),
--                                 ),
--                                 "type"         => "string",
--                                 "description"  => __( "This address is used for admin purposes, like new user notification." ),
--                         )
--                 );
--         end;

--         register_setting(
--                 "general",
--                 "timezone_string",
--                 array(
--                         "show_in_rest" => array(
--                                 "name" => "timezone",
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "A city in the same timezone as you." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "date_format",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "string",
--                         "description"  => __( "A date format for all date strings." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "time_format",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "string",
--                         "description"  => __( "A time format for all time strings." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "start_of_week",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "A day number of the week that the week should start on." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "WPLANG",
--                 array(
--                         "show_in_rest" => array(
--                                 "name" => "language",
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "WordPress locale code." ),
--                         "default"      => "en_US",
--                 )
--         );

--         register_setting(
--                 "writing",
--                 "use_smilies",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "boolean",
--                         "description"  => __( "Convert emoticons like :-) and :-P to graphics on display." ),
--                         "default"      => true,
--                 )
--         );

--         register_setting(
--                 "writing",
--                 "default_category",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "Default post category." ),
--                 )
--         );

--         register_setting(
--                 "writing",
--                 "default_post_format",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "string",
--                         "description"  => __( "Default post format." ),
--                 )
--         );

--         register_setting(
--                 "reading",
--                 "posts_per_page",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "Blog pages show at most." ),
--                         "default"      => 10,
--                 )
--         );

--         register_setting(
--                 "reading",
--                 "show_on_front",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "string",
--                         "description"  => __( "What to show on the front page" ),
--                 )
--         );

--         register_setting(
--                 "reading",
--                 "page_on_front",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "The ID of the page that should be displayed on the front page" ),
--                 )
--         );

--         register_setting(
--                 "reading",
--                 "page_for_posts",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "The ID of the page that should display the latest posts" ),
--                 )
--         );

--         register_setting(
--                 "discussion",
--                 "default_ping_status",
--                 array(
--                         "show_in_rest" => array(
--                                 "schema" => array(
--                                         "enum" => array( "open", "closed" ),
--                                 ),
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "Allow link notifications from other blogs (pingbacks and trackbacks) on new articles." ),
--                 )
--         );

--         register_setting(
--                 "discussion",
--                 "default_comment_status",
--                 array(
--                         "show_in_rest" => array(
--                                 "schema" => array(
--                                         "enum" => array( "open", "closed" ),
--                                 ),
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "Allow people to submit comments on new posts." ),
--                 )
--         );
-- end;

-- --
-- -- Registers a setting and its data.
-- --
-- -- @since 2.7.0
-- -- @since 3.0.0 The `misc` option group was deprecated.
-- -- @since 3.5.0 The `privacy` option group was deprecated.
-- -- @since 4.7.0 `args` can be passed to set flags on the setting, similar to `register_meta()`.
-- -- @since 5.5.0 `new_whitelist_options` was renamed to `new_allowed_options`.
-- --              Please consider writing more inclusive code.
-- --
-- -- @global array new_allowed_options
-- -- @global array wp_registered_settings
-- --
-- -- @param string option_group A settings group name. Should correspond to an allowed option key name.
-- --                             Default allowed option key names include "general", "discussion", "media",
-- --                             "reading", "writing", and "options".
-- -- @param string option_name The name of an option to sanitize and save.
-- -- @param array  args then
-- --     Data used to describe the setting when registered.
-- --
-- --     @type string     type              The type of data associated with this setting.
-- --                                         Valid values are "string", "boolean", "integer", "number", "array", and "object".
-- --     @type string     description       A description of the data attached to this setting.
-- --     @type callable   sanitize_callback A callback function that sanitizes the option"s value.
-- --     @type bool|array show_in_rest      Whether data associated with this setting should be included in the REST API.
-- --                                         When registering complex settings, this argument may optionally be an
-- --                                         array with a "schema" key.
-- --     @type mixed      default           Default value when calling `get_option()`.
-- -- end;
-- --
-- function register_setting( option_group, option_name, args = array() ) then
--         global new_allowed_options, wp_registered_settings;

--         /*
--         -- In 5.5.0, the `new_whitelist_options` global variable was renamed to `new_allowed_options`.
--         -- Please consider writing more inclusive code.
--         --
--         GLOBALS["new_whitelist_options"] = &new_allowed_options;

--         defaults = array(
--                 "type"              => "string",
--                 "group"             => option_group,
--                 "description"       => "",
--                 "sanitize_callback" => null,
--                 "show_in_rest"      => false,
--         );

--         // Back-compat: old sanitize callback is added.
--         if ( is_callable( args ) ) then
--                 args = array(
--                         "sanitize_callback" => args,
--                 );
--         end;

--         --
--         -- Filters the registration arguments when registering a setting.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array  args         Array of setting registration arguments.
--         -- @param array  defaults     Array of default arguments.
--         -- @param string option_group Setting group.
--         -- @param string option_name  Setting name.
--         --
--         args = apply_filters( "register_setting_args", args, defaults, option_group, option_name );

--         args = wp_parse_args( args, defaults );

--         // Require an item schema when registering settings with an array type.
--         if ( false !== args["show_in_rest"] && "array" === args["type"] && ( ! is_array( args["show_in_rest"] ) || ! isset( args["show_in_rest"]["schema"]["items"] ) ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "When registering an "array" setting to show in the REST API, you must specify the schema for each array item in "show_in_rest.schema.items"." ), "5.4.0" );
--         end;

--         if ( ! is_array( wp_registered_settings ) ) then
--                 wp_registered_settings = array();
--         end;

--         if ( "misc" === option_group ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "3.0.0",
--                         sprintf(
--                                 /* translators: %s: misc--
--                                 __( "The "%s" options group has been removed. Use another settings group." ),
--                                 "misc"
--                         )
--                 );
--                 option_group = "general";
--         end;

--         if ( "privacy" === option_group ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "3.5.0",
--                         sprintf(
--                                 /* translators: %s: privacy--
--                                 __( "The "%s" options group has been removed. Use another settings group." ),
--                                 "privacy"
--                         )
--                 );
--                 option_group = "reading";
--         end;

--         new_allowed_options[ option_group ][] = option_name;

--         if ( ! empty( args["sanitize_callback"] ) ) then
--                 add_filter( "sanitize_option_thenoption_nameend;", args["sanitize_callback"] );
--         end;
--         if ( array_key_exists( "default", args ) ) then
--                 add_filter( "default_option_thenoption_nameend;", "filter_default_option", 10, 3 );
--         end;

--         --
--         -- Fires immediately before the setting is registered but after its filters are in place.
--         --
--         -- @since 5.5.0
--         --
--         -- @param string option_group Setting group.
--         -- @param string option_name  Setting name.
--         -- @param array  args         Array of setting registration arguments.
--         --
--         do_action( "register_setting", option_group, option_name, args );

--         wp_registered_settings[ option_name ] = args;
-- end;

-- --
-- -- Unregisters a setting.
-- --
-- -- @since 2.7.0
-- -- @since 4.7.0 `sanitize_callback` was deprecated. The callback from `register_setting()` is now used instead.
-- -- @since 5.5.0 `new_whitelist_options` was renamed to `new_allowed_options`.
-- --              Please consider writing more inclusive code.
-- --
-- -- @global array new_allowed_options
-- -- @global array wp_registered_settings
-- --
-- -- @param string   option_group The settings group name used during registration.
-- -- @param string   option_name  The name of the option to unregister.
-- -- @param callable deprecated   Optional. Deprecated.
-- --
-- function unregister_setting( option_group, option_name, deprecated = "" ) then
--         global new_allowed_options, wp_registered_settings;

--         /*
--         -- In 5.5.0, the `new_whitelist_options` global variable was renamed to `new_allowed_options`.
--         -- Please consider writing more inclusive code.
--         --
--         GLOBALS["new_whitelist_options"] = &new_allowed_options;

--         if ( "misc" === option_group ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "3.0.0",
--                         sprintf(
--                                 /* translators: %s: misc--
--                                 __( "The "%s" options group has been removed. Use another settings group." ),
--                                 "misc"
--                         )
--                 );
--                 option_group = "general";
--         end;

--         if ( "privacy" === option_group ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "3.5.0",
--                         sprintf(
--                                 /* translators: %s: privacy--
--                                 __( "The "%s" options group has been removed. Use another settings group." ),
--                                 "privacy"
--                         )
--                 );
--                 option_group = "reading";
--         end;

--         pos = array_search( option_name, (array) new_allowed_options[ option_group ], true );

--         if ( false !== pos ) then
--                 unset( new_allowed_options[ option_group ][ pos ] );
--         end;

--         if ( "" !== deprecated ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "4.7.0",
--                         sprintf(
--                                 /* translators: 1: sanitize_callback, 2: register_setting()--
--                                 __( "%1s is deprecated. The callback from %2s is used instead." ),
--                                 "<code>sanitize_callback</code>",
--                                 "<code>register_setting()</code>"
--                         )
--                 );
--                 remove_filter( "sanitize_option_thenoption_nameend;", deprecated );
--         end;

--         if ( isset( wp_registered_settings[ option_name ] ) ) then
--                 // Remove the sanitize callback if one was set during registration.
--                 if ( ! empty( wp_registered_settings[ option_name ]["sanitize_callback"] ) ) then
--                         remove_filter( "sanitize_option_thenoption_nameend;", wp_registered_settings[ option_name ]["sanitize_callback"] );
--                 end;

--                 // Remove the default filter if a default was provided during registration.
--                 if ( array_key_exists( "default", wp_registered_settings[ option_name ] ) ) then
--                         remove_filter( "default_option_thenoption_nameend;", "filter_default_option", 10 );
--                 end;

--                 --
--                 -- Fires immediately before the setting is unregistered and after its filters have been removed.
--                 --
--                 -- @since 5.5.0
--                 --
--                 -- @param string option_group Setting group.
--                 -- @param string option_name  Setting name.
--                 --
--                 do_action( "unregister_setting", option_group, option_name );

--                 unset( wp_registered_settings[ option_name ] );
--         end;
-- end;

-- --
-- -- Retrieves an array of registered settings.
-- --
-- -- @since 4.7.0
-- --
-- -- @global array wp_registered_settings
-- --
-- -- @return array List of registered settings, keyed by option name.
-- --
-- function get_registered_settings() then
--         global wp_registered_settings;

--         if ( ! is_array( wp_registered_settings ) ) then
--                 return array();
--         end;

--         return wp_registered_settings;
-- end;

-- --
-- -- Filters the default value for the option.
-- --
-- -- For settings which register a default setting in `register_setting()`, this
-- -- function is added as a filter to `default_option_thenoptionend;`.
-- --
-- -- @since 4.7.0
-- --
-- -- @param mixed  default        Existing default value to return.
-- -- @param string option         Option name.
-- -- @param bool   passed_default Was `get_option()` passed a default value?
-- -- @return mixed Filtered default value.
-- --
-- function filter_default_option( default, option, passed_default ) then
--         if ( passed_default ) then
--                 return default;
--         end;

--         registered = get_registered_settings();
--         if ( empty( registered[ option ] ) ) then
--                 return default;
--         end;

--         return registered[ option ]["default"];
-- end;

end Inc_Options;
