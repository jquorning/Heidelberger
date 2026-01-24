--
-- Error Protection API: WP_Recovery_Mode_Link_Handler class
--
-- @package WordPress
-- @since 5.2.0
--

package Inc_Class_Wp_Recovery_Mode_Link_Services
is

   LOGIN_ACTION_ENTER   : constant String := "enter_recovery_mode";
   LOGIN_ACTION_ENTERED : constant String := "entered_recovery_mode";

   --
   -- Core class used to generate and handle recovery mode links.
   --
   -- @since 5.2.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Recovery_Mode_Link_Service is tagged
     record
        --
        -- Service to generate and validate recovery mode keys.
        --
        -- @since 5.2.0
        -- @var WP_Recovery_Mode_Key_Service
        --
--      private key_service;

        --
        -- Service to handle cookies.
        --
        -- @since 5.2.0
        -- @var WP_Recovery_Mode_Cookie_Service
        --
--      private cookie_service;

        null;
     end record;
        -- --
        -- -- WP_Recovery_Mode_Link_Service constructor.
        -- --
        -- -- @since 5.2.0
        -- --
        -- -- @param WP_Recovery_Mode_Cookie_Service cookie_service Service to handle setting the recovery mode cookie.
        -- -- @param WP_Recovery_Mode_Key_Service    key_service    Service to handle generating recovery mode keys.
        -- --
        -- public function __construct( WP_Recovery_Mode_Cookie_Service cookie_service, WP_Recovery_Mode_Key_Service key_service ) then
        --         this.cookie_service = cookie_service;
        --         this.key_service    = key_service;
        -- end;

        -- --
        -- -- Generates a URL to begin recovery mode.
        -- --
        -- -- Only one recovery mode URL can may be valid at the same time.
        -- --
        -- -- @since 5.2.0
        -- --
        -- -- @return string Generated URL.
        -- --
        -- public function generate_url() then
        --         token = this.key_service.generate_recovery_mode_token();
        --         key   = this.key_service.generate_and_store_recovery_mode_key( token );

        --         return this.get_recovery_mode_begin_url( token, key );
        -- end;

        -- --
        -- -- Enters recovery mode when the user hits wp-login.php with a valid recovery mode link.
        -- --
        -- -- @since 5.2.0
        -- --
        -- -- @global string pagenow The filename of the current screen.
        -- --
        -- -- @param int ttl Number of seconds the link should be valid for.
        -- --
        -- public function handle_begin_link( ttl ) then
        --         if ( ! isset( GLOBALS['pagenow'] ) || 'wp-login.php' !== GLOBALS['pagenow'] ) then
        --                 return;
        --         end;

        --         if ( ! isset( _GET['action'], _GET['rm_token'], _GET['rm_key'] ) || self::LOGIN_ACTION_ENTER !== _GET['action'] ) then
        --                 return;
        --         end;

        --         if ( ! function_exists( 'wp_generate_password' ) ) then
        --                 require_once ABSPATH . WPINC . '/pluggable.php';
        --         end;

        --         validated = this.key_service.validate_recovery_mode_key( _GET['rm_token'], _GET['rm_key'], ttl );

        --         if ( is_wp_error( validated ) ) then
        --                 wp_die( validated, '' );
        --         end;

        --         this.cookie_service.set_cookie();

        --         url = add_query_arg( 'action', self::LOGIN_ACTION_ENTERED, wp_login_url() );
        --         wp_redirect( url );
        --         die;
        -- end;

        -- --
        -- -- Gets a URL to begin recovery mode.
        -- --
        -- -- @since 5.2.0
        -- --
        -- -- @param string token Recovery Mode token created by then@see generate_recovery_mode_token()end;.
        -- -- @param string key   Recovery Mode key created by then@see generate_and_store_recovery_mode_key()end;.
        -- -- @return string Recovery mode begin URL.
        -- --
        -- private function get_recovery_mode_begin_url( token, key ) then

        --         url = add_query_arg(
        --                 array(
        --                         'action'   => self::LOGIN_ACTION_ENTER,
        --                         'rm_token' => token,
        --                         'rm_key'   => key,
        --                 ),
        --                 wp_login_url()
        --         );

        --         --
        --         -- Filters the URL to begin recovery mode.
        --         --
        --         -- @since 5.2.0
        --         --
        --         -- @param string url   The generated recovery mode begin URL.
        --         -- @param string token The token used to identify the key.
        --         -- @param string key   The recovery mode key.
        --         --
        --         return apply_filters( 'recovery_mode_begin_url', url, token, key );
        -- end;

end Inc_Class_Wp_Recovery_Mode_Link_Services;
