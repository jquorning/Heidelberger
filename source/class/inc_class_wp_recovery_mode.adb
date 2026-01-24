--
-- Error Protection API: WP_Recovery_Mode class
--
-- @package WordPress
-- @since 5.2.0
--

with Hb_Common;

package body Inc_Class_Wp_Recovery_Mode
is

--         --
--         -- WP_Recovery_Mode constructor.
--         --
--         -- @since 5.2.0
--         --
--         public function __construct() then
--                 this.cookie_service = new WP_Recovery_Mode_Cookie_Service();
--                 this.key_service    = new WP_Recovery_Mode_Key_Service();
--                 this.link_service   = new WP_Recovery_Mode_Link_Service( this.cookie_service, this.key_service );
--                 this.email_service  = new WP_Recovery_Mode_Email_Service( this.link_service );
--         end;

--         --
--         -- Initialize recovery mode for the current request.
--         --
--         -- @since 5.2.0
--         --
--         public function initialize() then
--                 this.is_initialized = true;

--                 add_action( "wp_logout", array( this, "exit_recovery_mode" ) );
--                 add_action( "login_form_" . self::EXIT_ACTION, array( this, "handle_exit_recovery_mode" ) );
--                 add_action( "recovery_mode_clean_expired_keys", array( this, "clean_expired_keys" ) );

--                 if ( ! wp_next_scheduled( "recovery_mode_clean_expired_keys" ) && ! wp_installing() ) then
--                         wp_schedule_event( time(), "daily", "recovery_mode_clean_expired_keys" );
--                 end;

--                 if ( defined( "WP_RECOVERY_MODE_SESSION_ID" ) ) then
--                         this.is_active  = true;
--                         this.session_id = WP_RECOVERY_MODE_SESSION_ID;

--                         return;
--                 end;

--                 if ( this.cookie_service.is_cookie_set() ) then
--                         this.handle_cookie();

--                         return;
--                 end;

--                 this.link_service.handle_begin_link( this.get_link_ttl() );
--         end;

--         --
--         -- Checks whether recovery mode is active.
--         --
--         -- This will not change after recovery mode has been initialized. {@see WP_Recovery_Mode::run()}.
--         --
--         -- @since 5.2.0
--         --
--         -- @return bool True if recovery mode is active, false otherwise.
--         --
--         public function is_active() then
--                 return this.is_active;
--         end;

   ---------------------
   -- Get_Sesstion_Id --
   ---------------------

   function Get_Session_Id (This : Wp_Recovery_Mode)
                            return String
   is
      use Hb_Common;
   begin
      return -This.Session_Id;
   end Get_Session_Id;

--         --
--         -- Checks whether recovery mode has been initialized.
--         --
--         -- Recovery mode should not be used until this point. Initialization happens immediately before loading plugins.
--         --
--         -- @since 5.2.0
--         --
--         -- @return bool
--         --
--         public function is_initialized() then
--                 return this.is_initialized;
--         end;

--         --
--         -- Handles a fatal error occurring.
--         --
--         -- The calling API should immediately die() after calling this function.
--         --
--         -- @since 5.2.0
--         --
--         -- @param array error Error details from `error_get_last()`.
--         -- @return true|WP_Error True if the error was handled and headers have already been sent.
--         --                       Or the request will exit to try and catch multiple errors at once.
--         --                       WP_Error if an error occurred preventing it from being handled.
--         --
--         public function handle_error( array error ) then

--                 extension = this.get_extension_for_error( error );

--                 if ( ! extension || this.is_network_plugin( extension ) ) then
--                         return new WP_Error( "invalid_source", __( "Error not caused by a plugin or theme." ) );
--                 end;

--                 if ( ! this.is_active() ) then
--                         if ( ! is_protected_endpoint() ) then
--                                 return new WP_Error( "non_protected_endpoint", __( "Error occurred on a non-protected endpoint." ) );
--                         end;

--                         if ( ! function_exists( "wp_generate_password" ) ) then
--                                 require_once ABSPATH . WPINC . "/pluggable.php";
--                         end;

--                         return this.email_service.maybe_send_recovery_mode_email( this.get_email_rate_limit(), error, extension );
--                 end;

--                 if ( ! this.store_error( error ) ) then
--                         return new WP_Error( "storage_error", __( "Failed to store the error." ) );
--                 end;

--                 if ( headers_sent() ) then
--                         return true;
--                 end;

--                 this.redirect_protected();
--         end;

--         --
--         -- Ends the current recovery mode session.
--         --
--         -- @since 5.2.0
--         --
--         -- @return bool True on success, false on failure.
--         --
--         public function exit_recovery_mode() then
--                 if ( ! this.is_active() ) then
--                         return false;
--                 end;

--                 this.email_service.clear_rate_limit();
--                 this.cookie_service.clear_cookie();

--                 wp_paused_plugins().delete_all();
--                 wp_paused_themes().delete_all();

--                 return true;
--         end;

--         --
--         -- Handles a request to exit Recovery Mode.
--         --
--         -- @since 5.2.0
--         --
--         public function handle_exit_recovery_mode() then
--                 redirect_to = wp_get_referer();

--                 -- Safety check in case referrer returns false.
--                 if ( ! redirect_to ) then
--                         redirect_to = is_user_logged_in() ? admin_url() : home_url();
--                 end;

--                 if ( ! this.is_active() ) then
--                         wp_safe_redirect( redirect_to );
--                         die;
--                 end;

--                 if ( ! isset( _GET["action"] ) || self::EXIT_ACTION !== _GET["action"] ) then
--                         return;
--                 end;

--                 if ( ! isset( _GET["_wpnonce"] ) || ! wp_verify_nonce( _GET["_wpnonce"], self::EXIT_ACTION ) ) then
--                         wp_die( __( "Exit recovery mode link expired." ), 403 );
--                 end;

--                 if ( ! this.exit_recovery_mode() ) then
--                         wp_die( __( "Failed to exit recovery mode. Please try again later." ) );
--                 end;

--                 wp_safe_redirect( redirect_to );
--                 die;
--         end;

--         --
--         -- Cleans any recovery mode keys that have expired according to the link TTL.
--         --
--         -- Executes on a daily cron schedule.
--         --
--         -- @since 5.2.0
--         --
--         public function clean_expired_keys() then
--                 this.key_service.clean_expired_keys( this.get_link_ttl() );
--         end;

--         --
--         -- Handles checking for the recovery mode cookie and validating it.
--         --
--         -- @since 5.2.0
--         --
--         protected function handle_cookie() then
--                 validated = this.cookie_service.validate_cookie();

--                 if ( is_wp_error( validated ) ) then
--                         this.cookie_service.clear_cookie();

--                         validated.add_data( array( "status" => 403 ) );
--                         wp_die( validated );
--                 end;

--                 session_id = this.cookie_service.get_session_id_from_cookie();
--                 if ( is_wp_error( session_id ) ) then
--                         this.cookie_service.clear_cookie();

--                         session_id.add_data( array( "status" => 403 ) );
--                         wp_die( session_id );
--                 end;

--                 this.is_active  = true;
--                 this.session_id = session_id;
--         end;

--         --
--         -- Gets the rate limit between sending new recovery mode email links.
--         --
--         -- @since 5.2.0
--         --
--         -- @return int Rate limit in seconds.
--         --
--         protected function get_email_rate_limit() then
--                 --
--                 -- Filters the rate limit between sending new recovery mode email links.
--                 --
--                 -- @since 5.2.0
--                 --
--                 -- @param int rate_limit Time to wait in seconds. Defaults to 1 day.
--                 --
--                 return apply_filters( "recovery_mode_email_rate_limit", DAY_IN_SECONDS );
--         end;

--         --
--         -- Gets the number of seconds the recovery mode link is valid for.
--         --
--         -- @since 5.2.0
--         --
--         -- @return int Interval in seconds.
--         --
--         protected function get_link_ttl() then

--                 rate_limit = this.get_email_rate_limit();
--                 valid_for  = rate_limit;

--                 --
--                 -- Filters the amount of time the recovery mode email link is valid for.
--                 --
--                 -- The ttl must be at least as long as the email rate limit.
--                 --
--                 -- @since 5.2.0
--                 --
--                 -- @param int valid_for The number of seconds the link is valid for.
--                 --
--                 valid_for = apply_filters( "recovery_mode_email_link_ttl", valid_for );

--                 return max( valid_for, rate_limit );
--         end;

--         --
--         -- Gets the extension that the error occurred in.
--         --
--         -- @since 5.2.0
--         --
--         -- @global array wp_theme_directories
--         --
--         -- @param array error Error details from `error_get_last()`.
--         -- @return array|false then
--         --     Extension details.
--         --
--         --     @type string slug The extension slug. This is the plugin or theme"s directory.
--         --     @type string type The extension type. Either "plugin" or "theme".
--         -- end;
--         --
--         protected function get_extension_for_error( error ) then
--                 global wp_theme_directories;

--                 if ( ! isset( error["file"] ) ) then
--                         return false;
--                 end;

--                 if ( ! defined( "WP_PLUGIN_DIR" ) ) then
--                         return false;
--                 end;

--                 error_file    = wp_normalize_path( error["file"] );
--                 wp_plugin_dir = wp_normalize_path( WP_PLUGIN_DIR );

--                 if ( 0 === strpos( error_file, wp_plugin_dir ) ) then
--                         path  = str_replace( wp_plugin_dir . "/", "", error_file );
--                         parts = explode( "/", path );

--                         return array(
--                                 "type" => "plugin",
--                                 "slug" => parts[0],
--                         );
--                 end;

--                 if ( empty( wp_theme_directories ) ) then
--                         return false;
--                 end;

--                 foreach ( wp_theme_directories as theme_directory ) then
--                         theme_directory = wp_normalize_path( theme_directory );

--                         if ( 0 === strpos( error_file, theme_directory ) ) then
--                                 path  = str_replace( theme_directory . "/", "", error_file );
--                                 parts = explode( "/", path );

--                                 return array(
--                                         "type" => "theme",
--                                         "slug" => parts[0],
--                                 );
--                         end;
--                 end;

--                 return false;
--         end;

--         --
--         -- Checks whether the given extension a network activated plugin.
--         --
--         -- @since 5.2.0
--         --
--         -- @param array extension Extension data.
--         -- @return bool True if network plugin, false otherwise.
--         --
--         protected function is_network_plugin( extension ) then
--                 if ( "plugin" !== extension["type"] ) then
--                         return false;
--                 end;

--                 if ( ! is_multisite() ) then
--                         return false;
--                 end;

--                 network_plugins = wp_get_active_network_plugins();

--                 foreach ( network_plugins as plugin ) then
--                         if ( 0 === strpos( plugin, extension["slug"] . "/" ) ) then
--                                 return true;
--                         end;
--                 end;

--                 return false;
--         end;

--         --
--         -- Stores the given error so that the extension causing it is paused.
--         --
--         -- @since 5.2.0
--         --
--         -- @param array error Error details from `error_get_last()`.
--         -- @return bool True if the error was stored successfully, false otherwise.
--         --
--         protected function store_error( error ) then
--                 extension = this.get_extension_for_error( error );

--                 if ( ! extension ) then
--                         return false;
--                 end;

--                 switch ( extension["type"] ) then
--                         case "plugin":
--                                 return wp_paused_plugins().set( extension["slug"], error );
--                         case "theme":
--                                 return wp_paused_themes().set( extension["slug"], error );
--                         default:
--                                 return false;
--                 end;
--         end;

--         --
--         -- Redirects the current request to allow recovering multiple errors in one go.
--         --
--         -- The redirection will only happen when on a protected endpoint.
--         --
--         -- It must be ensured that this method is only called when an error actually occurred and will not occur on the
--         -- next request again. Otherwise it will create a redirect loop.
--         --
--         -- @since 5.2.0
--         --
--         protected function redirect_protected() then
--                 -- Pluggable is usually loaded after plugins, so we manually include it here for redirection functionality.
--                 if ( ! function_exists( "wp_safe_redirect" ) ) then
--                         require_once ABSPATH . WPINC . "/pluggable.php";
--                 end;

--                 scheme = is_ssl() ? "https://" : "http://";

--                 url = "thenschemeend;then_SERVER["HTTP_HOST"]end;then_SERVER["REQUEST_URI"]end;";
--                 wp_safe_redirect( url );
--                 exit;
--         end;
-- end;

end Inc_Class_Wp_Recovery_Mode;
