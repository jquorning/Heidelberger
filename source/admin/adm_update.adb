--
-- Update/Install Plugin/Theme administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

package body Adm_Update
is

   procedure Run
   is
   begin
      raise Program_Error with "not implemented";
   end Run;

end Adm_Update;

-- if ( ! defined( "IFRAME_REQUEST" )
--         && isset( _GET["action"] ) && in_array( _GET["action"], array( "update-selected", "activate-plugin", "update-selected-themes" ), true )
-- ) then
--         define( "IFRAME_REQUEST", true );
-- end;

-- -- WordPress Administration Bootstrap--
-- require_once __DIR__ . "/admin.php";

-- require_once ABSPATH . "wp-admin/includes/class-wp-upgrader.php";

-- wp_enqueue_script( "wp-a11y" );

-- if ( isset( _GET["action"] ) ) then
--         plugin = isset( _REQUEST["plugin"] ) ? trim( _REQUEST["plugin"] ) : "";
--         theme  = isset( _REQUEST["theme"] ) ? urldecode( _REQUEST["theme"] ) : "";
--         action = isset( _REQUEST["action"] ) ? _REQUEST["action"] : "";

--         if ( "update-selected" === action ) then
--                 if ( ! current_user_can( "update_plugins" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to update plugins for this site." ) );
--                 end;

--                 check_admin_referer( "bulk-update-plugins" );

--                 if ( isset( _GET["plugins"] ) ) then
--                         plugins = explode( ",", stripslashes( _GET["plugins"] ) );
--                 end; elseif ( isset( _POST["checked"] ) ) then
--                         plugins = (array) _POST["checked"];
--                 end; else then
--                         plugins = array();
--                 end;

--                 plugins = array_map( "urldecode", plugins );

--                 url   = "update.php?action=update-selected&amp;plugins=" . urlencode( implode( ",", plugins ) );
--                 nonce = "bulk-update-plugins";

--                 wp_enqueue_script( "updates" );
--                 iframe_header();

--                 upgrader = new Plugin_Upgrader( new Bulk_Plugin_Upgrader_Skin( compact( "nonce", "url" ) ) );
--                 upgrader.bulk_upgrade( plugins );

--                 iframe_footer();

--         end; elseif ( "upgrade-plugin" === action ) then
--                 if ( ! current_user_can( "update_plugins" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to update plugins for this site." ) );
--                 end;

--                 check_admin_referer( "upgrade-plugin_" . plugin );

--                 -- Used in the HTML title tag.
--                 title        = __( "Update Plugin" );
--                 parent_file  = "plugins.php";
--                 submenu_file = "plugins.php";

--                 wp_enqueue_script( "updates" );
--                 require_once ABSPATH . "wp-admin/admin-header.php";

--                 nonce = "upgrade-plugin_" . plugin;
--                 url   = "update.php?action=upgrade-plugin&plugin=" . urlencode( plugin );

--                 upgrader = new Plugin_Upgrader( new Plugin_Upgrader_Skin( compact( "title", "nonce", "url", "plugin" ) ) );
--                 upgrader.upgrade( plugin );

--                 require_once ABSPATH . "wp-admin/admin-footer.php";

--         end; elseif ( "activate-plugin" === action ) then
--                 if ( ! current_user_can( "update_plugins" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to update plugins for this site." ) );
--                 end;

--                 check_admin_referer( "activate-plugin_" . plugin );
--                 if ( ! isset( _GET["failure"] ) && ! isset( _GET["success"] ) ) then
--                         wp_redirect( admin_url( "update.php?action=activate-plugin&failure=true&plugin=" . urlencode( plugin ) . "&_wpnonce=" . _GET["_wpnonce"] ) );
--                         activate_plugin( plugin, "", ! empty( _GET["networkwide"] ), true );
--                         wp_redirect( admin_url( "update.php?action=activate-plugin&success=true&plugin=" . urlencode( plugin ) . "&_wpnonce=" . _GET["_wpnonce"] ) );
--                         die();
--                 end;
--                 iframe_header( __( "Plugin Reactivation" ), true );
--                 if ( isset( _GET["success"] ) ) then
--                         echo "<p>" . __( "Plugin reactivated successfully." ) . "</p>";
--                 end;

--                 if ( isset( _GET["failure"] ) ) then
--                         echo "<p>" . __( "Plugin failed to reactivate due to a fatal error." ) . "</p>";

--                         error_reporting( E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_ERROR | E_WARNING | E_PARSE | E_USER_ERROR | E_USER_WARNING | E_RECOVERABLE_ERROR );
--                         ini_set( "display_errors", true ); -- Ensure that fatal errors are displayed.
--                         wp_register_plugin_realpath( WP_PLUGIN_DIR . "/" . plugin );
--                         include WP_PLUGIN_DIR . "/" . plugin;
--                 end;
--                 iframe_footer();
--         end; elseif ( "install-plugin" === action ) then

--                 if ( ! current_user_can( "install_plugins" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to install plugins on this site." ) );
--                 end;

--                 include_once ABSPATH . "wp-admin/includes/plugin-install.php"; -- For plugins_api().

--                 check_admin_referer( "install-plugin_" . plugin );
--                 api = plugins_api(
--                         "plugin_information",
--                         array(
--                                 "slug"   => plugin,
--                                 "fields" => array(
--                                         "sections" => false,
--                                 ),
--                         )
--                 );

--                 if ( is_wp_error( api ) ) then
--                         wp_die( api );
--                 end;

--                 -- Used in the HTML title tag.
--                 title        = __( "Plugin Installation" );
--                 parent_file  = "plugins.php";
--                 submenu_file = "plugin-install.php";

--                 require_once ABSPATH . "wp-admin/admin-header.php";

--                 /* translators: %s: Plugin name and version.--
--                 title = sprintf( __( "Installing Plugin: %s" ), api.name . " " . api.version );
--                 nonce = "install-plugin_" . plugin;
--                 url   = "update.php?action=install-plugin&plugin=" . urlencode( plugin );
--                 if ( isset( _GET["from"] ) ) then
--                         url .= "&from=" . urlencode( stripslashes( _GET["from"] ) );
--                 end;

--                 type = "web"; -- Install plugin type, From Web or an Upload.

--                 upgrader = new Plugin_Upgrader( new Plugin_Installer_Skin( compact( "title", "url", "nonce", "plugin", "api" ) ) );
--                 upgrader.install( api.download_link );

--                 require_once ABSPATH . "wp-admin/admin-footer.php";

--         end; elseif ( "upload-plugin" === action ) then

--                 if ( ! current_user_can( "upload_plugins" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to install plugins on this site." ) );
--                 end;

--                 check_admin_referer( "plugin-upload" );

--                 if ( isset( _FILES["pluginzip"]["name"] ) && ! str_ends_with( strtolower( _FILES["pluginzip"]["name"] ), ".zip" ) ) then
--                         wp_die( __( "Only .zip archives may be uploaded." ) );
--                 end;

--                 file_upload = new File_Upload_Upgrader( "pluginzip", "package" );

--                 -- Used in the HTML title tag.
--                 title        = __( "Upload Plugin" );
--                 parent_file  = "plugins.php";
--                 submenu_file = "plugin-install.php";

--                 require_once ABSPATH . "wp-admin/admin-header.php";

--                 /* translators: %s: File name.--
--                 title = sprintf( __( "Installing plugin from uploaded file: %s" ), esc_html( basename( file_upload.filename ) ) );
--                 nonce = "plugin-upload";
--                 url   = add_query_arg( array( "package" => file_upload.id ), "update.php?action=upload-plugin" );
--                 type  = "upload"; -- Install plugin type, From Web or an Upload.

--                 overwrite = isset( _GET["overwrite"] ) ? sanitize_text_field( _GET["overwrite"] ) : "";
--                 overwrite = in_array( overwrite, array( "update-plugin", "downgrade-plugin" ), true ) ? overwrite : "";

--                 upgrader = new Plugin_Upgrader( new Plugin_Installer_Skin( compact( "type", "title", "nonce", "url", "overwrite" ) ) );
--                 result   = upgrader.install( file_upload.package, array( "overwrite_package" => overwrite ) );

--                 if ( result || is_wp_error( result ) ) then
--                         file_upload.cleanup();
--                 end;

--                 require_once ABSPATH . "wp-admin/admin-footer.php";

--         end; elseif ( "upload-plugin-cancel-overwrite" === action ) then
--                 if ( ! current_user_can( "upload_plugins" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to install plugins on this site." ) );
--                 end;

--                 check_admin_referer( "plugin-upload-cancel-overwrite" );

--                 -- Make sure the attachment still exists, or File_Upload_Upgrader will call wp_die()
--                 -- that shows a generic "Please select a file" error.
--                 if ( ! empty( _GET["package"] ) ) then
--                         attachment_id = (int) _GET["package"];

--                         if ( get_post( attachment_id ) ) then
--                                 file_upload = new File_Upload_Upgrader( "pluginzip", "package" );
--                                 file_upload.cleanup();
--                         end;
--                 end;

--                 wp_redirect( self_admin_url( "plugin-install.php" ) );
--                 exit;
--         end; elseif ( "upgrade-theme" === action ) then

--                 if ( ! current_user_can( "update_themes" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to update themes for this site." ) );
--                 end;

--                 check_admin_referer( "upgrade-theme_" . theme );

--                 wp_enqueue_script( "updates" );

--                 -- Used in the HTML title tag.
--                 title        = __( "Update Theme" );
--                 parent_file  = "themes.php";
--                 submenu_file = "themes.php";

--                 require_once ABSPATH . "wp-admin/admin-header.php";

--                 nonce = "upgrade-theme_" . theme;
--                 url   = "update.php?action=upgrade-theme&theme=" . urlencode( theme );

--                 upgrader = new Theme_Upgrader( new Theme_Upgrader_Skin( compact( "title", "nonce", "url", "theme" ) ) );
--                 upgrader.upgrade( theme );

--                 require_once ABSPATH . "wp-admin/admin-footer.php";
--         end; elseif ( "update-selected-themes" === action ) then
--                 if ( ! current_user_can( "update_themes" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to update themes for this site." ) );
--                 end;

--                 check_admin_referer( "bulk-update-themes" );

--                 if ( isset( _GET["themes"] ) ) then
--                         themes = explode( ",", stripslashes( _GET["themes"] ) );
--                 end; elseif ( isset( _POST["checked"] ) ) then
--                         themes = (array) _POST["checked"];
--                 end; else then
--                         themes = array();
--                 end;

--                 themes = array_map( "urldecode", themes );

--                 url   = "update.php?action=update-selected-themes&amp;themes=" . urlencode( implode( ",", themes ) );
--                 nonce = "bulk-update-themes";

--                 wp_enqueue_script( "updates" );
--                 iframe_header();

--                 upgrader = new Theme_Upgrader( new Bulk_Theme_Upgrader_Skin( compact( "nonce", "url" ) ) );
--                 upgrader.bulk_upgrade( themes );

--                 iframe_footer();
--         end; elseif ( "install-theme" === action ) then

--                 if ( ! current_user_can( "install_themes" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to install themes on this site." ) );
--                 end;

--                 include_once ABSPATH . "wp-admin/includes/class-wp-upgrader.php"; -- For themes_api().

--                 check_admin_referer( "install-theme_" . theme );
--                 api = themes_api(
--                         "theme_information",
--                         array(
--                                 "slug"   => theme,
--                                 "fields" => array(
--                                         "sections" => false,
--                                         "tags"     => false,
--                                 ),
--                         )
--                 ); -- Save on a bit of bandwidth.

--                 if ( is_wp_error( api ) ) then
--                         wp_die( api );
--                 end;

--                 -- Used in the HTML title tag.
--                 title        = __( "Install Themes" );
--                 parent_file  = "themes.php";
--                 submenu_file = "themes.php";

--                 require_once ABSPATH . "wp-admin/admin-header.php";

--                 /* translators: %s: Theme name and version.--
--                 title = sprintf( __( "Installing Theme: %s" ), api.name . " " . api.version );
--                 nonce = "install-theme_" . theme;
--                 url   = "update.php?action=install-theme&theme=" . urlencode( theme );
--                 type  = "web"; -- Install theme type, From Web or an Upload.

--                 upgrader = new Theme_Upgrader( new Theme_Installer_Skin( compact( "title", "url", "nonce", "plugin", "api" ) ) );
--                 upgrader.install( api.download_link );

--                 require_once ABSPATH . "wp-admin/admin-footer.php";

--         end; elseif ( "upload-theme" === action ) then

--                 if ( ! current_user_can( "upload_themes" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to install themes on this site." ) );
--                 end;

--                 check_admin_referer( "theme-upload" );

--                 if ( isset( _FILES["themezip"]["name"] ) && ! str_ends_with( strtolower( _FILES["themezip"]["name"] ), ".zip" ) ) then
--                         wp_die( __( "Only .zip archives may be uploaded." ) );
--                 end;

--                 file_upload = new File_Upload_Upgrader( "themezip", "package" );

--                 -- Used in the HTML title tag.
--                 title        = __( "Upload Theme" );
--                 parent_file  = "themes.php";
--                 submenu_file = "theme-install.php";

--                 require_once ABSPATH . "wp-admin/admin-header.php";

--                 /* translators: %s: File name.--
--                 title = sprintf( __( "Installing theme from uploaded file: %s" ), esc_html( basename( file_upload.filename ) ) );
--                 nonce = "theme-upload";
--                 url   = add_query_arg( array( "package" => file_upload.id ), "update.php?action=upload-theme" );
--                 type  = "upload"; -- Install theme type, From Web or an Upload.

--                 overwrite = isset( _GET["overwrite"] ) ? sanitize_text_field( _GET["overwrite"] ) : "";
--                 overwrite = in_array( overwrite, array( "update-theme", "downgrade-theme" ), true ) ? overwrite : "";

--                 upgrader = new Theme_Upgrader( new Theme_Installer_Skin( compact( "type", "title", "nonce", "url", "overwrite" ) ) );
--                 result   = upgrader.install( file_upload.package, array( "overwrite_package" => overwrite ) );

--                 if ( result || is_wp_error( result ) ) then
--                         file_upload.cleanup();
--                 end;

--                 require_once ABSPATH . "wp-admin/admin-footer.php";

--         end; elseif ( "upload-theme-cancel-overwrite" === action ) then
--                 if ( ! current_user_can( "upload_themes" ) ) then
--                         wp_die( __( "Sorry, you are not allowed to install themes on this site." ) );
--                 end;

--                 check_admin_referer( "theme-upload-cancel-overwrite" );

--                 -- Make sure the attachment still exists, or File_Upload_Upgrader will call wp_die()
--                 -- that shows a generic "Please select a file" error.
--                 if ( ! empty( _GET["package"] ) ) then
--                         attachment_id = (int) _GET["package"];

--                         if ( get_post( attachment_id ) ) then
--                                 file_upload = new File_Upload_Upgrader( "themezip", "package" );
--                                 file_upload.cleanup();
--                         end;
--                 end;

--                 wp_redirect( self_admin_url( "theme-install.php" ) );
--                 exit;
--         end; else then
--                 --
--                 -- Fires when a custom plugin or theme update request is received.
--                 --
--                 -- The dynamic portion of the hook name, `action`, refers to the action
--                 -- provided in the request for wp-admin/update.php. Can be used to
--                 -- provide custom update functionality for themes and plugins.
--                 --
--                 -- @since 2.8.0
--                 --
--                 do_action( "update-custom_thenactionend;" ); -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
--         end;
-- end;
