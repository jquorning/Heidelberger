
--
-- A simple set of functions to check the WordPress.org Version Update service.
--
-- @package WordPress
-- @since 2.3.0
--

package body Inc_Updates
is
   procedure Dummy is null;

-- --
-- -- Checks WordPress version against the newest version.
-- --
-- -- The WordPress version, PHP version, and locale is sent.
-- --
-- -- Checks against the WordPress server at api.wordpress.org. Will only check
-- -- if WordPress isn"t installing.
-- --
-- -- @since 2.3.0
-- --
-- -- @global string wp_version       Used to check against the newest WordPress version.
-- -- @global wpdb   wpdb             WordPress database abstraction object.
-- -- @global string wp_local_package Locale code of the package.
-- --
-- -- @param array extra_stats Extra statistics to report to the WordPress.org API.
-- -- @param bool  force_check Whether to bypass the transient cache and force a fresh update check.
-- --                           Defaults to false, true if extra_stats is set.
-- --
-- function wp_version_check( extra_stats = array(), force_check = false ) then
--         global wpdb, wp_local_package;

--         if ( wp_installing() ) then
--                 return;
--         end;

--         -- Include an unmodified wp_version.
--         require ABSPATH . WPINC . "/version.php";
--         php_version = PHP_VERSION;

--         current      = get_site_transient( "update_core" );
--         translations = wp_get_installed_translations( "core" );

--         -- Invalidate the transient when wp_version changes.
--         if ( is_object( current ) and then wp_version not== current->version_checked ) then
--                 current = false;
--         end;

--         if ( not is_object( current ) ) then
--                 current                  = new stdClass;
--                 current->updates         = array();
--                 current->version_checked = wp_version;
--         end;

--         if ( not empty( extra_stats ) ) then
--                 force_check = true;
--         end;

--         -- Wait 1 minute between multiple version check requests.
--         timeout          = MINUTE_IN_SECONDS;
--         time_not_changed = isset( current->last_checked ) and then timeout > ( time() - current->last_checked );

--         if ( not force_check and then time_not_changed ) then
--                 return;
--         end;

--         --
--         -- Filters the locale requested for WordPress core translations.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string locale Current locale.
--         --
--         locale = apply_filters( "core_version_check_locale", get_locale() );

--         -- Update last_checked for current to prevent multiple blocking requests if request hangs.
--         current->last_checked = time();
--         set_site_transient( "update_core", current );

--         if ( method_exists( wpdb, "db_version" ) ) then
--                 mysql_version = preg_replace( "/[^0-9.].*/", "", wpdb->db_version() );
--         end; else then
--                 mysql_version = "N/A";
--         end;

--         if ( is_multisite() ) then
--                 num_blogs         = get_blog_count();
--                 wp_install        = network_site_url();
--                 multisite_enabled = 1;
--         end; else then
--                 multisite_enabled = 0;
--                 num_blogs         = 1;
--                 wp_install        = home_url( "/" );
--         end;

--         extensions = get_loaded_extensions();
--         sort( extensions, SORT_STRING | SORT_FLAG_CASE );
--         query = array(
--                 "version"            => wp_version,
--                 "php"                => php_version,
--                 "locale"             => locale,
--                 "mysql"              => mysql_version,
--                 "local_package"      => isset( wp_local_package ) ? wp_local_package : "",
--                 "blogs"              => num_blogs,
--                 "users"              => get_user_count(),
--                 "multisite_enabled"  => multisite_enabled,
--                 "initial_db_version" => get_site_option( "initial_db_version" ),
--                 "extensions"         => array_combine( extensions, array_map( "phpversion", extensions ) ),
--                 "platform_flags"     => array(
--                         "os"   => PHP_OS,
--                         "bits" => PHP_INT_SIZE === 4 ? 32 : 64,
--                 ),
--                 "image_support"      => array(),
--         );

--         if ( function_exists( "gd_info" ) ) then
--                 gd_info = gd_info();
--                 -- Filter to supported values.
--                 gd_info = array_filter( gd_info );

--                 -- Add data for GD WebP and AVIF support.
--                 query["image_support"]["gd"] = array_keys(
--                         array_filter(
--                                 array(
--                                         "webp" => isset( gd_info["WebP Support"] ),
--                                         "avif" => isset( gd_info["AVIF Support"] ),
--                                 )
--                         )
--                 );
--         end;

--         if ( class_exists( "Imagick" ) ) then
--                 -- Add data for Imagick WebP and AVIF support.
--                 query["image_support"]["imagick"] = array_keys(
--                         array_filter(
--                                 array(
--                                         "webp" => not empty( Imagick::queryFormats( "WEBP" ) ),
--                                         "avif" => not empty( Imagick::queryFormats( "AVIF" ) ),
--                                 )
--                         )
--                 );
--         end;

--         --
--         -- Filters the query arguments sent as part of the core version check.
--         --
--         -- WARNING: Changing this data may result in your site not receiving security updates.
--         -- Please exercise extreme caution.
--         --
--         -- @since 4.9.0
--         --
--         -- @param array query then
--         --     Version check query arguments.
--         --
--         --     @type string version            WordPress version number.
--         --     @type string php                PHP version number.
--         --     @type string locale             The locale to retrieve updates for.
--         --     @type string mysql              MySQL version number.
--         --     @type string local_package      The value of the wp_local_package global, when set.
--         --     @type int    blogs              Number of sites on this WordPress installation.
--         --     @type int    users              Number of users on this WordPress installation.
--         --     @type int    multisite_enabled  Whether this WordPress installation uses Multisite.
--         --     @type int    initial_db_version Database version of WordPress at time of installation.
--         -- end;
--         --
--         query = apply_filters( "core_version_check_query_args", query );

--         post_body = array(
--                 "translations" => wp_json_encode( translations ),
--         );

--         if ( is_array( extra_stats ) ) then
--                 post_body = array_merge( post_body, extra_stats );
--         end;

--         -- Allow for WP_AUTO_UPDATE_CORE to specify beta/RC/development releases.
--         if ( defined( "WP_AUTO_UPDATE_CORE" )
--                 and then in_array( WP_AUTO_UPDATE_CORE, array( "beta", "rc", "development", "branch-development" ), true )
--         ) then
--                 query["channel"] = WP_AUTO_UPDATE_CORE;
--         end;

--         url      = "http:--api.wordpress.org/core/version-check/1.7/?" . http_build_query( query, "", "&" );
--         http_url = url;
--         ssl      = wp_http_supports( array( "ssl" ) );

--         if ( ssl ) then
--                 url = set_url_scheme( url, "https" );
--         end;

--         doing_cron = wp_doing_cron();

--         options = array(
--                 "timeout"    => doing_cron ? 30 : 3,
--                 "user-agent" => "WordPress/" . wp_version . "; " . home_url( "/" ),
--                 "headers"    => array(
--                         "wp_install" => wp_install,
--                         "wp_blog"    => home_url( "/" ),
--                 ),
--                 "body"       => post_body,
--         );

--         response = wp_remote_post( url, options );

--         if ( ssl and then is_wp_error( response ) ) then
--                 trigger_error(
--                         sprintf(
--                                 /* translators: %s: Support forums URL.--
--                                 __( "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href="%s">support forums</a>." ),
--                                 __( "https:--wordpress.org/support/forums/" )
--                         ) . " " . __( "(WordPress could not establish a secure connection to WordPress.org. Please contact your server administrator.)" ),
--                         headers_sent() || WP_DEBUG ? E_USER_WARNING : E_USER_NOTICE
--                 );
--                 response = wp_remote_post( http_url, options );
--         end;

--         if ( is_wp_error( response ) || 200 not== wp_remote_retrieve_response_code( response ) ) then
--                 return;
--         end;

--         body = trim( wp_remote_retrieve_body( response ) );
--         body = json_decode( body, true );

--         if ( not is_array( body ) || not isset( body["offers"] ) ) then
--                 return;
--         end;

--         offers = body["offers"];

--         foreach ( offers as &offer ) then
--                 foreach ( offer as offer_key => value ) then
--                         if ( "packages" === offer_key ) then
--                                 offer["packages"] = (object) array_intersect_key(
--                                         array_map( "esc_url", offer["packages"] ),
--                                         array_fill_keys( array( "full", "no_content", "new_bundled", "partial", "rollback" ), "" )
--                                 );
--                         end; elseif ( "download" === offer_key ) then
--                                 offer["download"] = esc_url( value );
--                         end; else then
--                                 offer[ offer_key ] = esc_html( value );
--                         end;
--                 end;
--                 offer = (object) array_intersect_key(
--                         offer,
--                         array_fill_keys(
--                                 array(
--                                         "response",
--                                         "download",
--                                         "locale",
--                                         "packages",
--                                         "current",
--                                         "version",
--                                         "php_version",
--                                         "mysql_version",
--                                         "new_bundled",
--                                         "partial_version",
--                                         "notify_email",
--                                         "support_email",
--                                         "new_files",
--                                 ),
--                                 ""
--                         )
--                 );
--         end;

--         updates                  = new stdClass();
--         updates->updates         = offers;
--         updates->last_checked    = time();
--         updates->version_checked = wp_version;

--         if ( isset( body["translations"] ) ) then
--                 updates->translations = body["translations"];
--         end;

--         set_site_transient( "update_core", updates );

--         if ( not empty( body["ttl"] ) ) then
--                 ttl = (int) body["ttl"];

--                 if ( ttl and then ( time() + ttl < wp_next_scheduled( "wp_version_check" ) ) ) then
--                         -- Queue an event to re-run the update check in ttl seconds.
--                         wp_schedule_single_event( time() + ttl, "wp_version_check" );
--                 end;
--         end;

--         -- Trigger background updates if running non-interactively, and we weren"t called from the update handler.
--         if ( doing_cron and then not doing_action( "wp_maybe_auto_update" ) ) then
--                 --
--                 -- Fires during wp_cron, starting the auto-update process.
--                 --
--                 -- @since 3.9.0
--                 --
--                 do_action( "wp_maybe_auto_update" );
--         end;
-- end;

-- --
-- -- Checks for available updates to plugins based on the latest versions hosted on WordPress.org.
-- --
-- -- Despite its name this function does not actually perform any updates, it only checks for available updates.
-- --
-- -- A list of all plugins installed is sent to WP, along with the site locale.
-- --
-- -- Checks against the WordPress server at api.wordpress.org. Will only check
-- -- if WordPress isn"t installing.
-- --
-- -- @since 2.3.0
-- --
-- -- @global string wp_version The WordPress version string.
-- --
-- -- @param array extra_stats Extra statistics to report to the WordPress.org API.
-- --
-- function wp_update_plugins( extra_stats = array() ) then
--         if ( wp_installing() ) then
--                 return;
--         end;

--         -- Include an unmodified wp_version.
--         require ABSPATH . WPINC . "/version.php";

--         -- If running blog-side, bail unless we"ve not checked in the last 12 hours.
--         if ( not function_exists( "get_plugins" ) ) then
--                 require_once ABSPATH . "wp-admin/includes/plugin.php";
--         end;

--         plugins      = get_plugins();
--         translations = wp_get_installed_translations( "plugins" );

--         active  = get_option( "active_plugins", array() );
--         current = get_site_transient( "update_plugins" );

--         if ( not is_object( current ) ) then
--                 current = new stdClass;
--         end;

--         updates               = new stdClass;
--         updates->last_checked = time();
--         updates->response     = array();
--         updates->translations = array();
--         updates->no_update    = array();

--         doing_cron = wp_doing_cron();

--         -- Check for update on a different schedule, depending on the page.
--         switch ( current_filter() ) then
--                 case "upgrader_process_complete":
--                         timeout = 0;
--                         break;
--                 case "load-update-core.php":
--                         timeout = MINUTE_IN_SECONDS;
--                         break;
--                 case "load-plugins.php":
--                 case "load-update.php":
--                         timeout = HOUR_IN_SECONDS;
--                         break;
--                 default:
--                         if ( doing_cron ) then
--                                 timeout = 2-- HOUR_IN_SECONDS;
--                         end; else then
--                                 timeout = 12-- HOUR_IN_SECONDS;
--                         end;
--         end;

--         time_not_changed = isset( current->last_checked ) and then timeout > ( time() - current->last_checked );

--         if ( time_not_changed and then not extra_stats ) then
--                 plugin_changed = false;

--                 foreach ( plugins as file => p ) then
--                         updates->checked[ file ] = p["Version"];

--                         if ( not isset( current->checked[ file ] ) || (string) current->checked[ file ] not== (string) p["Version"] ) then
--                                 plugin_changed = true;
--                         end;
--                 end;

--                 if ( isset( current->response ) and then is_array( current->response ) ) then
--                         foreach ( current->response as plugin_file => update_details ) then
--                                 if ( not isset( plugins[ plugin_file ] ) ) then
--                                         plugin_changed = true;
--                                         break;
--                                 end;
--                         end;
--                 end;

--                 -- Bail if we"ve checked recently and if nothing has changed.
--                 if ( not plugin_changed ) then
--                         return;
--                 end;
--         end;

--         -- Update last_checked for current to prevent multiple blocking requests if request hangs.
--         current->last_checked = time();
--         set_site_transient( "update_plugins", current );

--         to_send = compact( "plugins", "active" );

--         locales = array_values( get_available_languages() );

--         --
--         -- Filters the locales requested for plugin translations.
--         --
--         -- @since 3.7.0
--         -- @since 4.5.0 The default value of the `locales` parameter changed to include all locales.
--         --
--         -- @param string[] locales Plugin locales. Default is all available locales of the site.
--         --
--         locales = apply_filters( "plugins_update_check_locales", locales );
--         locales = array_unique( locales );

--         if ( doing_cron ) then
--                 timeout = 30; -- 30 seconds.
--         end; else then
--                 -- Three seconds, plus one extra second for every 10 plugins.
--                 timeout = 3 + (int) ( count( plugins ) / 10 );
--         end;

--         options = array(
--                 "timeout"    => timeout,
--                 "body"       => array(
--                         "plugins"      => wp_json_encode( to_send ),
--                         "translations" => wp_json_encode( translations ),
--                         "locale"       => wp_json_encode( locales ),
--                         "all"          => wp_json_encode( true ),
--                 ),
--                 "user-agent" => "WordPress/" . wp_version . "; " . home_url( "/" ),
--         );

--         if ( extra_stats ) then
--                 options["body"]["update_stats"] = wp_json_encode( extra_stats );
--         end;

--         url      = "http:--api.wordpress.org/plugins/update-check/1.1/";
--         http_url = url;
--         ssl      = wp_http_supports( array( "ssl" ) );

--         if ( ssl ) then
--                 url = set_url_scheme( url, "https" );
--         end;

--         raw_response = wp_remote_post( url, options );

--         if ( ssl and then is_wp_error( raw_response ) ) then
--                 trigger_error(
--                         sprintf(
--                                 /* translators: %s: Support forums URL.--
--                                 __( "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href="%s">support forums</a>." ),
--                                 __( "https:--wordpress.org/support/forums/" )
--                         ) . " " . __( "(WordPress could not establish a secure connection to WordPress.org. Please contact your server administrator.)" ),
--                         headers_sent() || WP_DEBUG ? E_USER_WARNING : E_USER_NOTICE
--                 );
--                 raw_response = wp_remote_post( http_url, options );
--         end;

--         if ( is_wp_error( raw_response ) || 200 not== wp_remote_retrieve_response_code( raw_response ) ) then
--                 return;
--         end;

--         response = json_decode( wp_remote_retrieve_body( raw_response ), true );

--         if ( response and then is_array( response ) ) then
--                 updates->response     = response["plugins"];
--                 updates->translations = response["translations"];
--                 updates->no_update    = response["no_update"];
--         end;

--         -- Support updates for any plugins using the `Update URI` header field.
--         foreach ( plugins as plugin_file => plugin_data ) then
--                 if ( not plugin_data["UpdateURI"] || isset( updates->response[ plugin_file ] ) ) then
--                         continue;
--                 end;

--                 hostname = wp_parse_url( sanitize_url( plugin_data["UpdateURI"] ), PHP_URL_HOST );

--                 --
--                 -- Filters the update response for a given plugin hostname.
--                 --
--                 -- The dynamic portion of the hook name, `hostname`, refers to the hostname
--                 -- of the URI specified in the `Update URI` header field.
--                 --
--                 -- @since 5.8.0
--                 --
--                 -- @param array|false update then
--                 --     The plugin update data with the latest details. Default false.
--                 --
--                 --     @type string id           Optional. ID of the plugin for update purposes, should be a URI
--                 --                                specified in the `Update URI` header field.
--                 --     @type string slug         Slug of the plugin.
--                 --     @type string version      The version of the plugin.
--                 --     @type string url          The URL for details of the plugin.
--                 --     @type string package      Optional. The update ZIP for the plugin.
--                 --     @type string tested       Optional. The version of WordPress the plugin is tested against.
--                 --     @type string requires_php Optional. The version of PHP which the plugin requires.
--                 --     @type bool   autoupdate   Optional. Whether the plugin should automatically update.
--                 --     @type array  icons        Optional. Array of plugin icons.
--                 --     @type array  banners      Optional. Array of plugin banners.
--                 --     @type array  banners_rtl  Optional. Array of plugin RTL banners.
--                 --     @type array  translations then
--                 --         Optional. List of translation updates for the plugin.
--                 --
--                 --         @type string language   The language the translation update is for.
--                 --         @type string version    The version of the plugin this translation is for.
--                 --                                  This is not the version of the language file.
--                 --         @type string updated    The update timestamp of the translation file.
--                 --                                  Should be a date in the `YYYY-MM-DD HH:MM:SS` format.
--                 --         @type string package    The ZIP location containing the translation update.
--                 --         @type string autoupdate Whether the translation should be automatically installed.
--                 --     end;
--                 -- end;
--                 -- @param array       plugin_data      Plugin headers.
--                 -- @param string      plugin_file      Plugin filename.
--                 -- @param string[]    locales          Installed locales to look up translations for.
--                 --
--                 update = apply_filters( "update_plugins_thenhostnameend;", false, plugin_data, plugin_file, locales );

--                 if ( not update ) then
--                         continue;
--                 end;

--                 update = (object) update;

--                 -- Is it valid? We require at least a version.
--                 if ( not isset( update->version ) ) then
--                         continue;
--                 end;

--                 -- These should remain constant.
--                 update->id     = plugin_data["UpdateURI"];
--                 update->plugin = plugin_file;

--                 -- WordPress needs the version field specified as "new_version".
--                 if ( not isset( update->new_version ) ) then
--                         update->new_version = update->version;
--                 end;

--                 -- Handle any translation updates.
--                 if ( not empty( update->translations ) ) then
--                         foreach ( update->translations as translation ) then
--                                 if ( isset( translation["language"], translation["package"] ) ) then
--                                         translation["type"] = "plugin";
--                                         translation["slug"] = isset( update->slug ) ? update->slug : update->id;

--                                         updates->translations[] = translation;
--                                 end;
--                         end;
--                 end;

--                 unset( updates->no_update[ plugin_file ], updates->response[ plugin_file ] );

--                 if ( version_compare( update->new_version, plugin_data["Version"], ">" ) ) then
--                         updates->response[ plugin_file ] = update;
--                 end; else then
--                         updates->no_update[ plugin_file ] = update;
--                 end;
--         end;

--         sanitize_plugin_update_payload = static function( &item ) then
--                 item = (object) item;

--                 unset( item->translations, item->compatibility );

--                 return item;
--         end;;

--         array_walk( updates->response, sanitize_plugin_update_payload );
--         array_walk( updates->no_update, sanitize_plugin_update_payload );

--         set_site_transient( "update_plugins", updates );
-- end;

-- --
-- -- Checks for available updates to themes based on the latest versions hosted on WordPress.org.
-- --
-- -- Despite its name this function does not actually perform any updates, it only checks for available updates.
-- --
-- -- A list of all themes installed is sent to WP, along with the site locale.
-- --
-- -- Checks against the WordPress server at api.wordpress.org. Will only check
-- -- if WordPress isn"t installing.
-- --
-- -- @since 2.7.0
-- --
-- -- @global string wp_version The WordPress version string.
-- --
-- -- @param array extra_stats Extra statistics to report to the WordPress.org API.
-- --
-- function wp_update_themes( extra_stats = array() ) then
--         if ( wp_installing() ) then
--                 return;
--         end;

--         -- Include an unmodified wp_version.
--         require ABSPATH . WPINC . "/version.php";

--         installed_themes = wp_get_themes();
--         translations     = wp_get_installed_translations( "themes" );

--         last_update = get_site_transient( "update_themes" );

--         if ( not is_object( last_update ) ) then
--                 last_update = new stdClass;
--         end;

--         themes  = array();
--         checked = array();
--         request = array();

--         -- Put slug of active theme into request.
--         request["active"] = get_option( "stylesheet" );

--         foreach ( installed_themes as theme ) then
--                 checked[ theme->get_stylesheet() ] = theme->get( "Version" );

--                 themes[ theme->get_stylesheet() ] = array(
--                         "Name"       => theme->get( "Name" ),
--                         "Title"      => theme->get( "Name" ),
--                         "Version"    => theme->get( "Version" ),
--                         "Author"     => theme->get( "Author" ),
--                         "Author URI" => theme->get( "AuthorURI" ),
--                         "UpdateURI"  => theme->get( "UpdateURI" ),
--                         "Template"   => theme->get_template(),
--                         "Stylesheet" => theme->get_stylesheet(),
--                 );
--         end;

--         doing_cron = wp_doing_cron();

--         -- Check for update on a different schedule, depending on the page.
--         switch ( current_filter() ) then
--                 case "upgrader_process_complete":
--                         timeout = 0;
--                         break;
--                 case "load-update-core.php":
--                         timeout = MINUTE_IN_SECONDS;
--                         break;
--                 case "load-themes.php":
--                 case "load-update.php":
--                         timeout = HOUR_IN_SECONDS;
--                         break;
--                 default:
--                         if ( doing_cron ) then
--                                 timeout = 2-- HOUR_IN_SECONDS;
--                         end; else then
--                                 timeout = 12-- HOUR_IN_SECONDS;
--                         end;
--         end;

--         time_not_changed = isset( last_update->last_checked ) and then timeout > ( time() - last_update->last_checked );

--         if ( time_not_changed and then not extra_stats ) then
--                 theme_changed = false;

--                 foreach ( checked as slug => v ) then
--                         if ( not isset( last_update->checked[ slug ] ) || (string) last_update->checked[ slug ] not== (string) v ) then
--                                 theme_changed = true;
--                         end;
--                 end;

--                 if ( isset( last_update->response ) and then is_array( last_update->response ) ) then
--                         foreach ( last_update->response as slug => update_details ) then
--                                 if ( not isset( checked[ slug ] ) ) then
--                                         theme_changed = true;
--                                         break;
--                                 end;
--                         end;
--                 end;

--                 -- Bail if we"ve checked recently and if nothing has changed.
--                 if ( not theme_changed ) then
--                         return;
--                 end;
--         end;

--         -- Update last_checked for current to prevent multiple blocking requests if request hangs.
--         last_update->last_checked = time();
--         set_site_transient( "update_themes", last_update );

--         request["themes"] = themes;

--         locales = array_values( get_available_languages() );

--         --
--         -- Filters the locales requested for theme translations.
--         --
--         -- @since 3.7.0
--         -- @since 4.5.0 The default value of the `locales` parameter changed to include all locales.
--         --
--         -- @param string[] locales Theme locales. Default is all available locales of the site.
--         --
--         locales = apply_filters( "themes_update_check_locales", locales );
--         locales = array_unique( locales );

--         if ( doing_cron ) then
--                 timeout = 30; -- 30 seconds.
--         end; else then
--                 -- Three seconds, plus one extra second for every 10 themes.
--                 timeout = 3 + (int) ( count( themes ) / 10 );
--         end;

--         options = array(
--                 "timeout"    => timeout,
--                 "body"       => array(
--                         "themes"       => wp_json_encode( request ),
--                         "translations" => wp_json_encode( translations ),
--                         "locale"       => wp_json_encode( locales ),
--                 ),
--                 "user-agent" => "WordPress/" . wp_version . "; " . home_url( "/" ),
--         );

--         if ( extra_stats ) then
--                 options["body"]["update_stats"] = wp_json_encode( extra_stats );
--         end;

--         url      = "http:--api.wordpress.org/themes/update-check/1.1/";
--         http_url = url;
--         ssl      = wp_http_supports( array( "ssl" ) );

--         if ( ssl ) then
--                 url = set_url_scheme( url, "https" );
--         end;

--         raw_response = wp_remote_post( url, options );

--         if ( ssl and then is_wp_error( raw_response ) ) then
--                 trigger_error(
--                         sprintf(
--                                 /* translators: %s: Support forums URL.--
--                                 __( "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href="%s">support forums</a>." ),
--                                 __( "https:--wordpress.org/support/forums/" )
--                         ) . " " . __( "(WordPress could not establish a secure connection to WordPress.org. Please contact your server administrator.)" ),
--                         headers_sent() || WP_DEBUG ? E_USER_WARNING : E_USER_NOTICE
--                 );
--                 raw_response = wp_remote_post( http_url, options );
--         end;

--         if ( is_wp_error( raw_response ) || 200 not== wp_remote_retrieve_response_code( raw_response ) ) then
--                 return;
--         end;

--         new_update               = new stdClass;
--         new_update->last_checked = time();
--         new_update->checked      = checked;

--         response = json_decode( wp_remote_retrieve_body( raw_response ), true );

--         if ( is_array( response ) ) then
--                 new_update->response     = response["themes"];
--                 new_update->no_update    = response["no_update"];
--                 new_update->translations = response["translations"];
--         end;

--         -- Support updates for any themes using the `Update URI` header field.
--         foreach ( themes as theme_stylesheet => theme_data ) then
--                 if ( not theme_data["UpdateURI"] || isset( new_update->response[ theme_stylesheet ] ) ) then
--                         continue;
--                 end;

--                 hostname = wp_parse_url( esc_url_raw( theme_data["UpdateURI"] ), PHP_URL_HOST );

--                 --
--                 -- Filters the update response for a given theme hostname.
--                 --
--                 -- The dynamic portion of the hook name, `hostname`, refers to the hostname
--                 -- of the URI specified in the `Update URI` header field.
--                 --
--                 -- @since 6.1.0
--                 --
--                 -- @param array|false update then
--                 --     The theme update data with the latest details. Default false.
--                 --
--                 --     @type string id           Optional. ID of the theme for update purposes, should be a URI
--                 --                                specified in the `Update URI` header field.
--                 --     @type string theme        Directory name of the theme.
--                 --     @type string version      The version of the theme.
--                 --     @type string url          The URL for details of the theme.
--                 --     @type string package      Optional. The update ZIP for the theme.
--                 --     @type string tested       Optional. The version of WordPress the theme is tested against.
--                 --     @type string requires_php Optional. The version of PHP which the theme requires.
--                 --     @type bool   autoupdate   Optional. Whether the theme should automatically update.
--                 --     @type array  translations then
--                 --         Optional. List of translation updates for the theme.
--                 --
--                 --         @type string language   The language the translation update is for.
--                 --         @type string version    The version of the theme this translation is for.
--                 --                                  This is not the version of the language file.
--                 --         @type string updated    The update timestamp of the translation file.
--                 --                                  Should be a date in the `YYYY-MM-DD HH:MM:SS` format.
--                 --         @type string package    The ZIP location containing the translation update.
--                 --         @type string autoupdate Whether the translation should be automatically installed.
--                 --     end;
--                 -- end;
--                 -- @param array       theme_data       Theme headers.
--                 -- @param string      theme_stylesheet Theme stylesheet.
--                 -- @param string[]    locales          Installed locales to look up translations for.
--                 --
--                 update = apply_filters( "update_themes_thenhostnameend;", false, theme_data, theme_stylesheet, locales );

--                 if ( not update ) then
--                         continue;
--                 end;

--                 update = (object) update;

--                 -- Is it valid? We require at least a version.
--                 if ( not isset( update->version ) ) then
--                         continue;
--                 end;

--                 -- This should remain constant.
--                 update->id = theme_data["UpdateURI"];

--                 -- WordPress needs the version field specified as "new_version".
--                 if ( not isset( update->new_version ) ) then
--                         update->new_version = update->version;
--                 end;

--                 -- Handle any translation updates.
--                 if ( not empty( update->translations ) ) then
--                         foreach ( update->translations as translation ) then
--                                 if ( isset( translation["language"], translation["package"] ) ) then
--                                         translation["type"] = "theme";
--                                         translation["slug"] = isset( update->theme ) ? update->theme : update->id;

--                                         new_update->translations[] = translation;
--                                 end;
--                         end;
--                 end;

--                 unset( new_update->no_update[ theme_stylesheet ], new_update->response[ theme_stylesheet ] );

--                 if ( version_compare( update->new_version, theme_data["Version"], ">" ) ) then
--                         new_update->response[ theme_stylesheet ] = (array) update;
--                 end; else then
--                         new_update->no_update[ theme_stylesheet ] = (array) update;
--                 end;
--         end;

--         set_site_transient( "update_themes", new_update );
-- end;

-- --
-- -- Performs WordPress automatic background updates.
-- --
-- -- Updates WordPress core plus any plugins and themes that have automatic updates enabled.
-- --
-- -- @since 3.7.0
-- --
-- function wp_maybe_auto_update() then
--         include_once ABSPATH . "wp-admin/includes/admin.php";
--         require_once ABSPATH . "wp-admin/includes/class-wp-upgrader.php";

--         upgrader = new WP_Automatic_Updater;
--         upgrader->run();
-- end;

-- --
-- -- Retrieves a list of all language updates available.
-- --
-- -- @since 3.7.0
-- --
-- -- @return object[] Array of translation objects that have available updates.
-- --
-- function wp_get_translation_updates() then
--         updates    = array();
--         transients = array(
--                 "update_core"    => "core",
--                 "update_plugins" => "plugin",
--                 "update_themes"  => "theme",
--         );

--         foreach ( transients as transient => type ) then
--                 transient = get_site_transient( transient );

--                 if ( empty( transient->translations ) ) then
--                         continue;
--                 end;

--                 foreach ( transient->translations as translation ) then
--                         updates[] = (object) translation;
--                 end;
--         end;

--         return updates;
-- end;

-- --
-- -- Collects counts and UI strings for available updates.
-- --
-- -- @since 3.3.0
-- --
-- -- @return array
-- --
-- function wp_get_update_data() then
--         counts = array(
--                 "plugins"      => 0,
--                 "themes"       => 0,
--                 "wordpress"    => 0,
--                 "translations" => 0,
--         );

--         plugins = current_user_can( "update_plugins" );

--         if ( plugins ) then
--                 update_plugins = get_site_transient( "update_plugins" );

--                 if ( not empty( update_plugins->response ) ) then
--                         counts["plugins"] = count( update_plugins->response );
--                 end;
--         end;

--         themes = current_user_can( "update_themes" );

--         if ( themes ) then
--                 update_themes = get_site_transient( "update_themes" );

--                 if ( not empty( update_themes->response ) ) then
--                         counts["themes"] = count( update_themes->response );
--                 end;
--         end;

--         core = current_user_can( "update_core" );

--         if ( core and then function_exists( "get_core_updates" ) ) then
--                 update_wordpress = get_core_updates( array( "dismissed" => false ) );

--                 if ( not empty( update_wordpress )
--                         and then not in_array( update_wordpress[0]->response, array( "development", "latest" ), true )
--                         and then current_user_can( "update_core" )
--                 ) then
--                         counts["wordpress"] = 1;
--                 end;
--         end;

--         if ( ( core || plugins || themes ) and then wp_get_translation_updates() ) then
--                 counts["translations"] = 1;
--         end;

--         counts["total"] = counts["plugins"] + counts["themes"] + counts["wordpress"] + counts["translations"];
--         titles          = array();

--         if ( counts["wordpress"] ) then
--                 /* translators: %d: Number of available WordPress updates.--
--                 titles["wordpress"] = sprintf( __( "%d WordPress Update" ), counts["wordpress"] );
--         end;

--         if ( counts["plugins"] ) then
--                 /* translators: %d: Number of available plugin updates.--
--                 titles["plugins"] = sprintf( _n( "%d Plugin Update", "%d Plugin Updates", counts["plugins"] ), counts["plugins"] );
--         end;

--         if ( counts["themes"] ) then
--                 /* translators: %d: Number of available theme updates.--
--                 titles["themes"] = sprintf( _n( "%d Theme Update", "%d Theme Updates", counts["themes"] ), counts["themes"] );
--         end;

--         if ( counts["translations"] ) then
--                 titles["translations"] = __( "Translation Updates" );
--         end;

--         update_title = titles ? esc_attr( implode( ", ", titles ) ) : "";

--         update_data = array(
--                 "counts" => counts,
--                 "title"  => update_title,
--         );
--         --
--         -- Filters the returned array of update data for plugins, themes, and WordPress core.
--         --
--         -- @since 3.5.0
--         --
--         -- @param array update_data then
--         --     Fetched update data.
--         --
--         --     @type array   counts       An array of counts for available plugin, theme, and WordPress updates.
--         --     @type string  update_title Titles of available updates.
--         -- end;
--         -- @param array titles An array of update counts and UI strings for available updates.
--         --
--         return apply_filters( "wp_get_update_data", update_data, titles );
-- end;

-- --
-- -- Determines whether core should be updated.
-- --
-- -- @since 2.8.0
-- --
-- -- @global string wp_version The WordPress version string.
-- --
-- function _maybe_update_core() then
--         -- Include an unmodified wp_version.
--         require ABSPATH . WPINC . "/version.php";

--         current = get_site_transient( "update_core" );

--         if ( isset( current->last_checked, current->version_checked )
--                 and then 12-- HOUR_IN_SECONDS > ( time() - current->last_checked )
--                 and then current->version_checked === wp_version
--         ) then
--                 return;
--         end;

--         wp_version_check();
-- end;
-- --
-- -- Checks the last time plugins were run before checking plugin versions.
-- --
-- -- This might have been backported to WordPress 2.6.1 for performance reasons.
-- -- This is used for the wp-admin to check only so often instead of every page
-- -- load.
-- --
-- -- @since 2.7.0
-- -- @access private
-- --
-- function _maybe_update_plugins() then
--         current = get_site_transient( "update_plugins" );

--         if ( isset( current->last_checked )
--                 and then 12-- HOUR_IN_SECONDS > ( time() - current->last_checked )
--         ) then
--                 return;
--         end;

--         wp_update_plugins();
-- end;

-- --
-- -- Checks themes versions only after a duration of time.
-- --
-- -- This is for performance reasons to make sure that on the theme version
-- -- checker is not run on every page load.
-- --
-- -- @since 2.7.0
-- -- @access private
-- --
-- function _maybe_update_themes() then
--         current = get_site_transient( "update_themes" );

--         if ( isset( current->last_checked )
--                 and then 12-- HOUR_IN_SECONDS > ( time() - current->last_checked )
--         ) then
--                 return;
--         end;

--         wp_update_themes();
-- end;

-- --
-- -- Schedules core, theme, and plugin update checks.
-- --
-- -- @since 3.1.0
-- --
-- function wp_schedule_update_checks() then
--         if ( not wp_next_scheduled( "wp_version_check" ) and then not wp_installing() ) then
--                 wp_schedule_event( time(), "twicedaily", "wp_version_check" );
--         end;

--         if ( not wp_next_scheduled( "wp_update_plugins" ) and then not wp_installing() ) then
--                 wp_schedule_event( time(), "twicedaily", "wp_update_plugins" );
--         end;

--         if ( not wp_next_scheduled( "wp_update_themes" ) and then not wp_installing() ) then
--                 wp_schedule_event( time(), "twicedaily", "wp_update_themes" );
--         end;
-- end;

-- --
-- -- Clears existing update caches for plugins, themes, and core.
-- --
-- -- @since 4.1.0
-- --
-- function wp_clean_update_cache() then
--         if ( function_exists( "wp_clean_plugins_cache" ) ) then
--                 wp_clean_plugins_cache();
--         end; else then
--                 delete_site_transient( "update_plugins" );
--         end;

--         wp_clean_themes_cache();

--         delete_site_transient( "update_core" );
-- end;

-- if ( ( not is_main_site() and then not is_network_admin() ) || wp_doing_ajax() ) then
--         return;
-- end;

-- add_action( "admin_init", "_maybe_update_core" );
-- add_action( "wp_version_check", "wp_version_check" );

-- add_action( "load-plugins.php", "wp_update_plugins" );
-- add_action( "load-update.php", "wp_update_plugins" );
-- add_action( "load-update-core.php", "wp_update_plugins" );
-- add_action( "admin_init", "_maybe_update_plugins" );
-- add_action( "wp_update_plugins", "wp_update_plugins" );

-- add_action( "load-themes.php", "wp_update_themes" );
-- add_action( "load-update.php", "wp_update_themes" );
-- add_action( "load-update-core.php", "wp_update_themes" );
-- add_action( "admin_init", "_maybe_update_themes" );
-- add_action( "wp_update_themes", "wp_update_themes" );

-- add_action( "update_option_WPLANG", "wp_clean_update_cache", 10, 0 );

-- add_action( "wp_maybe_auto_update", "wp_maybe_auto_update" );

-- add_action( "init", "wp_schedule_update_checks" );

end Inc_Updates;
