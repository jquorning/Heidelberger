--
-- WordPress Theme Administration API
--
-- @package WordPress
-- @subpackage Administration
--

package body Adi_Themes
is

   ------------------
   -- Delete_Theme --
   ------------------

   function Delete_Theme (Stylesheet : String;
                          Redirect   : String := "")
                          return Bool_Error_Type
   is (raise Program_Error with "not implemented");

   procedure Delete_Theme (Stylesheet : String;
                           Redirect   : String := "")
   is
      Unused : constant Bool_Error_Type :=
        Delete_Theme (Stylesheet, Redirect);
   begin
      null;
   end Delete_Theme;

--         global wp_filesystem;

--         if ( empty( stylesheet ) ) then
--                 return false;
--         end;

--         if ( empty( redirect ) ) then
--                 redirect = wp_nonce_url( "themes.php?action=delete&stylesheet=" . urlencode( stylesheet ), "delete-theme_" . stylesheet );
--         end;

--         ob_start();
--         credentials = request_filesystem_credentials( redirect );
--         data        = ob_get_clean();

--         if ( false === credentials ) then
--                 if ( ! empty( data ) ) then
--                         require_once ABSPATH . "wp-admin/admin-header.php";
--                         echo data;
--                         require_once ABSPATH . "wp-admin/admin-footer.php";
--                         exit;
--                 end;
--                 return;
--         end;

--         if ( ! WP_Filesystem( credentials ) ) then
--                 ob_start();
--                 // Failed to connect. Error and request again.
--                 request_filesystem_credentials( redirect, "", true );
--                 data = ob_get_clean();

--                 if ( ! empty( data ) ) then
--                         require_once ABSPATH . "wp-admin/admin-header.php";
--                         echo data;
--                         require_once ABSPATH . "wp-admin/admin-footer.php";
--                         exit;
--                 end;
--                 return;
--         end;

--         if ( ! is_object( wp_filesystem ) ) then
--                 return new WP_Error( "fs_unavailable", __( "Could not access filesystem." ) );
--         end;

--         if ( is_wp_error( wp_filesystem.errors ) && wp_filesystem.errors.has_errors() ) then
--                 return new WP_Error( "fs_error", __( "Filesystem error." ), wp_filesystem.errors );
--         end;

--         // Get the base plugin folder.
--         themes_dir = wp_filesystem.wp_themes_dir();
--         if ( empty( themes_dir ) ) then
--                 return new WP_Error( "fs_no_themes_dir", __( "Unable to locate WordPress theme directory." ) );
--         end;

--         --
--         -- Fires immediately before a theme deletion attempt.
--         --
--         -- @since 5.8.0
--         --
--         -- @param string stylesheet Stylesheet of the theme to delete.
--         --
--         do_action( "delete_theme", stylesheet );

--         themes_dir = trailingslashit( themes_dir );
--         theme_dir  = trailingslashit( themes_dir . stylesheet );
--         deleted    = wp_filesystem.delete( theme_dir, true );

--         --
--         -- Fires immediately after a theme deletion attempt.
--         --
--         -- @since 5.8.0
--         --
--         -- @param string stylesheet Stylesheet of the theme to delete.
--         -- @param bool   deleted    Whether the theme deletion was successful.
--         --
--         do_action( "deleted_theme", stylesheet, deleted );

--         if ( ! deleted ) then
--                 return new WP_Error(
--                         "could_not_remove_theme",
--                         /* translators: %s: Theme name.--
--                         sprintf( __( "Could not fully remove the theme %s." ), stylesheet )
--                 );
--         end;

--         theme_translations = wp_get_installed_translations( "themes" );

--         // Remove language files, silently.
--         if ( ! empty( theme_translations[ stylesheet ] ) ) then
--                 translations = theme_translations[ stylesheet ];

--                 foreach ( translations as translation => data ) then
--                         wp_filesystem.delete( WP_LANG_DIR . "/themes/" . stylesheet . "-" . translation . ".po" );
--                         wp_filesystem.delete( WP_LANG_DIR . "/themes/" . stylesheet . "-" . translation . ".mo" );

--                         json_translation_files = glob( WP_LANG_DIR . "/themes/" . stylesheet . "-" . translation . "-*.json" );
--                         if ( json_translation_files ) then
--                                 array_map( array( wp_filesystem, "delete" ), json_translation_files );
--                         end;
--                 end;
--         end;

--         // Remove the theme from allowed themes on the network.
--         if ( is_multisite() ) then
--                 WP_Theme::network_disable_theme( stylesheet );
--         end;

--         // Force refresh of theme update information.
--         delete_site_transient( "update_themes" );

--         return true;
-- end;

-- --
-- -- Gets the page templates available in this theme.
-- --
-- -- @since 1.5.0
-- -- @since 4.7.0 Added the `post_type` parameter.
-- --
-- -- @param WP_Post|null post      Optional. The post being edited, provided for context.
-- -- @param string       post_type Optional. Post type to get the templates for. Default "page".
-- -- @return string[] Array of template file names keyed by the template header name.
-- --
-- function get_page_templates( post = null, post_type = "page" ) then
--         return array_flip( wp_get_theme().get_page_templates( post, post_type ) );
-- end;

-- --
-- -- Tidies a filename for url display by the theme file editor.
-- --
-- -- @since 2.9.0
-- -- @access private
-- --
-- -- @param string fullpath Full path to the theme file
-- -- @param string containingfolder Path of the theme parent folder
-- -- @return string
-- --
-- function _get_template_edit_filename( fullpath, containingfolder ) then
--         return str_replace( dirname( dirname( containingfolder ) ), "", fullpath );
-- end;

-- --
-- -- Check if there is an update for a theme available.
-- --
-- -- Will display link, if there is an update available.
-- --
-- -- @since 2.7.0
-- --
-- -- @see get_theme_update_available()
-- --
-- -- @param WP_Theme theme Theme data object.
-- --
-- function theme_update_available( theme ) then
--         echo get_theme_update_available( theme );
-- end;

-- --
-- -- Retrieves the update link if there is a theme update available.
-- --
-- -- Will return a link if there is an update available.
-- --
-- -- @since 3.8.0
-- --
-- -- @param WP_Theme theme WP_Theme object.
-- -- @return string|false HTML for the update link, or false if invalid info was passed.
-- --
-- function get_theme_update_available( theme ) then
--         static themes_update = null;

--         if ( ! current_user_can( "update_themes" ) ) then
--                 return false;
--         end;

--         if ( ! isset( themes_update ) ) then
--                 themes_update = get_site_transient( "update_themes" );
--         end;

--         if ( ! ( theme instanceof WP_Theme ) ) then
--                 return false;
--         end;

--         stylesheet = theme.get_stylesheet();

--         html = "";

--         if ( isset( themes_update.response[ stylesheet ] ) ) then
--                 update      = themes_update.response[ stylesheet ];
--                 theme_name  = theme.display( "Name" );
--                 details_url = add_query_arg(
--                         array(
--                                 "TB_iframe" => "true",
--                                 "width"     => 1024,
--                                 "height"    => 800,
--                         ),
--                         update["url"]
--                 ); // Theme browser inside WP? Replace this. Also, theme preview JS will override this on the available list.
--                 update_url  = wp_nonce_url( admin_url( "update.php?action=upgrade-theme&amp;theme=" . urlencode( stylesheet ) ), "upgrade-theme_" . stylesheet );

--                 if ( ! is_multisite() ) then
--                         if ( ! current_user_can( "update_themes" ) ) then
--                                 html = sprintf(
--                                         /* translators: 1: Theme name, 2: Theme details URL, 3: Additional link attributes, 4: Version number.--
--                                         "<p><strong>" . __( "There is a new version of %1s available. <a href="%2s" %3s>View version %4s details</a>." ) . "</strong></p>",
--                                         theme_name,
--                                         esc_url( details_url ),
--                                         sprintf(
--                                                 "class="thickbox open-plugin-details-modal" aria-label="%s"",
--                                                 /* translators: 1: Theme name, 2: Version number.--
--                                                 esc_attr( sprintf( __( "View %1s version %2s details" ), theme_name, update["new_version"] ) )
--                                         ),
--                                         update["new_version"]
--                                 );
--                         end; elseif ( empty( update["package"] ) ) then
--                                 html = sprintf(
--                                         /* translators: 1: Theme name, 2: Theme details URL, 3: Additional link attributes, 4: Version number.--
--                                         "<p><strong>" . __( "There is a new version of %1s available. <a href="%2s" %3s>View version %4s details</a>. <em>Automatic update is unavailable for this theme.</em>" ) . "</strong></p>",
--                                         theme_name,
--                                         esc_url( details_url ),
--                                         sprintf(
--                                                 "class="thickbox open-plugin-details-modal" aria-label="%s"",
--                                                 /* translators: 1: Theme name, 2: Version number.--
--                                                 esc_attr( sprintf( __( "View %1s version %2s details" ), theme_name, update["new_version"] ) )
--                                         ),
--                                         update["new_version"]
--                                 );
--                         end; else then
--                                 html = sprintf(
--                                         /* translators: 1: Theme name, 2: Theme details URL, 3: Additional link attributes, 4: Version number, 5: Update URL, 6: Additional link attributes.--
--                                         "<p><strong>" . __( "There is a new version of %1s available. <a href="%2s" %3s>View version %4s details</a> or <a href="%5s" %6s>update now</a>." ) . "</strong></p>",
--                                         theme_name,
--                                         esc_url( details_url ),
--                                         sprintf(
--                                                 "class="thickbox open-plugin-details-modal" aria-label="%s"",
--                                                 /* translators: 1: Theme name, 2: Version number.--
--                                                 esc_attr( sprintf( __( "View %1s version %2s details" ), theme_name, update["new_version"] ) )
--                                         ),
--                                         update["new_version"],
--                                         update_url,
--                                         sprintf(
--                                                 "aria-label="%s" id="update-theme" data-slug="%s"",
--                                                 /* translators: %s: Theme name.--
--                                                 esc_attr( sprintf( _x( "Update %s now", "theme" ), theme_name ) ),
--                                                 stylesheet
--                                         )
--                                 );
--                         end;
--                 end;
--         end;

--         return html;
-- end;

-- --
-- -- Retrieves list of WordPress theme features (aka theme tags).
-- --
-- -- @since 3.1.0
-- -- @since 3.2.0 Added "Gray" color and "Featured Image Header", "Featured Images",
-- --              "Full Width Template", and "Post Formats" features.
-- -- @since 3.5.0 Added "Flexible Header" feature.
-- -- @since 3.8.0 Renamed "Width" filter to "Layout".
-- -- @since 3.8.0 Renamed "Fixed Width" and "Flexible Width" options
-- --              to "Fixed Layout" and "Fluid Layout".
-- -- @since 3.8.0 Added "Accessibility Ready" feature and "Responsive Layout" option.
-- -- @since 3.9.0 Combined "Layout" and "Columns" filters.
-- -- @since 4.6.0 Removed "Colors" filter.
-- -- @since 4.6.0 Added "Grid Layout" option.
-- --              Removed "Fixed Layout", "Fluid Layout", and "Responsive Layout" options.
-- -- @since 4.6.0 Added "Custom Logo" and "Footer Widgets" features.
-- --              Removed "Blavatar" feature.
-- -- @since 4.6.0 Added "Blog", "E-Commerce", "Education", "Entertainment", "Food & Drink",
-- --              "Holiday", "News", "Photography", and "Portfolio" subjects.
-- --              Removed "Photoblogging" and "Seasonal" subjects.
-- -- @since 4.9.0 Reordered the filters from "Layout", "Features", "Subject"
-- --              to "Subject", "Features", "Layout".
-- -- @since 4.9.0 Removed "BuddyPress", "Custom Menu", "Flexible Header",
-- --              "Front Page Posting", "Microformats", "RTL Language Support",
-- --              "Threaded Comments", and "Translation Ready" features.
-- -- @since 5.5.0 Added "Block Editor Patterns", "Block Editor Styles",
-- --              and "Full Site Editing" features.
-- -- @since 5.5.0 Added "Wide Blocks" layout option.
-- -- @since 5.8.1 Added "Template Editing" feature.
-- -- @since 6.1.1 Replaced "Full Site Editing" feature name with "Site Editor".
-- --
-- -- @param bool api Optional. Whether try to fetch tags from the WordPress.org API. Defaults to true.
-- -- @return array Array of features keyed by category with translations keyed by slug.
-- --
-- function get_theme_feature_list( api = true ) then
--         // Hard-coded list is used if API is not accessible.
--         features = array(

--                 __( "Subject" )  => array(
--                         "blog"           => __( "Blog" ),
--                         "e-commerce"     => __( "E-Commerce" ),
--                         "education"      => __( "Education" ),
--                         "entertainment"  => __( "Entertainment" ),
--                         "food-and-drink" => __( "Food & Drink" ),
--                         "holiday"        => __( "Holiday" ),
--                         "news"           => __( "News" ),
--                         "photography"    => __( "Photography" ),
--                         "portfolio"      => __( "Portfolio" ),
--                 ),

--                 __( "Features" ) => array(
--                         "accessibility-ready"   => __( "Accessibility Ready" ),
--                         "block-patterns"        => __( "Block Editor Patterns" ),
--                         "block-styles"          => __( "Block Editor Styles" ),
--                         "custom-background"     => __( "Custom Background" ),
--                         "custom-colors"         => __( "Custom Colors" ),
--                         "custom-header"         => __( "Custom Header" ),
--                         "custom-logo"           => __( "Custom Logo" ),
--                         "editor-style"          => __( "Editor Style" ),
--                         "featured-image-header" => __( "Featured Image Header" ),
--                         "featured-images"       => __( "Featured Images" ),
--                         "footer-widgets"        => __( "Footer Widgets" ),
--                         "full-site-editing"     => __( "Site Editor" ),
--                         "full-width-template"   => __( "Full Width Template" ),
--                         "post-formats"          => __( "Post Formats" ),
--                         "sticky-post"           => __( "Sticky Post" ),
--                         "template-editing"      => __( "Template Editing" ),
--                         "theme-options"         => __( "Theme Options" ),
--                 ),

--                 __( "Layout" )   => array(
--                         "grid-layout"   => __( "Grid Layout" ),
--                         "one-column"    => __( "One Column" ),
--                         "two-columns"   => __( "Two Columns" ),
--                         "three-columns" => __( "Three Columns" ),
--                         "four-columns"  => __( "Four Columns" ),
--                         "left-sidebar"  => __( "Left Sidebar" ),
--                         "right-sidebar" => __( "Right Sidebar" ),
--                         "wide-blocks"   => __( "Wide Blocks" ),
--                 ),

--         );

--         if ( ! api || ! current_user_can( "install_themes" ) ) then
--                 return features;
--         end;

--         feature_list = get_site_transient( "wporg_theme_feature_list" );
--         if ( ! feature_list ) then
--                 set_site_transient( "wporg_theme_feature_list", array(), 3-- HOUR_IN_SECONDS );
--         end;

--         if ( ! feature_list ) then
--                 feature_list = themes_api( "feature_list", array() );
--                 if ( is_wp_error( feature_list ) ) then
--                         return features;
--                 end;
--         end;

--         if ( ! feature_list ) then
--                 return features;
--         end;

--         set_site_transient( "wporg_theme_feature_list", feature_list, 3-- HOUR_IN_SECONDS );

--         category_translations = array(
--                 "Layout"   => __( "Layout" ),
--                 "Features" => __( "Features" ),
--                 "Subject"  => __( "Subject" ),
--         );

--         wporg_features = array();

--         // Loop over the wp.org canonical list and apply translations.
--         foreach ( (array) feature_list as feature_category => feature_items ) then
--                 if ( isset( category_translations[ feature_category ] ) ) then
--                         feature_category = category_translations[ feature_category ];
--                 end;

--                 wporg_features[ feature_category ] = array();

--                 foreach ( feature_items as feature ) then
--                         if ( isset( features[ feature_category ][ feature ] ) ) then
--                                 wporg_features[ feature_category ][ feature ] = features[ feature_category ][ feature ];
--                         end; else then
--                                 wporg_features[ feature_category ][ feature ] = feature;
--                         end;
--                 end;
--         end;

--         return wporg_features;
-- end;

   ----------------
   -- Themes_API --
   ----------------

   function Themes_API (Action : String;
                        Args   : Array_Type := Empty_Array)
                        return Array_Error_Type
   is (raise Program_Error with "not implemented");
--         // Include an unmodified wp_version.
--         require ABSPATH . WPINC . "/version.php";

--         if ( is_array( args ) ) then
--                 args = (object) args;
--         end;

--         if ( "query_themes" === action ) then
--                 if ( ! isset( args.per_page ) ) then
--                         args.per_page = 24;
--                 end;
--         end;

--         if ( ! isset( args.locale ) ) then
--                 args.locale = get_user_locale();
--         end;

--         if ( ! isset( args.wp_version ) ) then
--                 args.wp_version = substr( wp_version, 0, 3 ); // x.y
--         end;

--         --
--         -- Filters arguments used to query for installer pages from the WordPress.org Themes API.
--         --
--         -- Important: An object MUST be returned to this filter.
--         --
--         -- @since 2.8.0
--         --
--         -- @param object args   Arguments used to query for installer pages from the WordPress.org Themes API.
--         -- @param string action Requested action. Likely values are "theme_information",
--         --                       "feature_list", or "query_themes".
--         --
--         args = apply_filters( "themes_api_args", args, action );

--         --
--         -- Filters whether to override the WordPress.org Themes API.
--         --
--         -- Returning a non-false value will effectively short-circuit the WordPress.org API request.
--         --
--         -- If `action` is "query_themes", "theme_information", or "feature_list", an object MUST
--         -- be passed. If `action` is "hot_tags", an array should be passed.
--         --
--         -- @since 2.8.0
--         --
--         -- @param false|object|array override Whether to override the WordPress.org Themes API. Default false.
--         -- @param string             action   Requested action. Likely values are "theme_information",
--         --                                    "feature_list", or "query_themes".
--         -- @param object             args     Arguments used to query for installer pages from the Themes API.
--         --
--         res = apply_filters( "themes_api", false, action, args );

--         if ( ! res ) then
--                 url = "http://api.wordpress.org/themes/info/1.2/";
--                 url = add_query_arg(
--                         array(
--                                 "action"  => action,
--                                 "request" => args,
--                         ),
--                         url
--                 );

--                 http_url = url;
--                 ssl      = wp_http_supports( array( "ssl" ) );
--                 if ( ssl ) then
--                         url = set_url_scheme( url, "https" );
--                 end;

--                 http_args = array(
--                         "user-agent" => "WordPress/" . wp_version . "; " . home_url( "/" ),
--                 );
--                 request   = wp_remote_get( url, http_args );

--                 if ( ssl && is_wp_error( request ) ) then
--                         if ( ! wp_doing_ajax() ) then
--                                 trigger_error(
--                                         sprintf(
--                                                 /* translators: %s: Support forums URL.--
--                                                 __( "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href="%s">support forums</a>." ),
--                                                 __( "https://wordpress.org/support/forums/" )
--                                         ) . " " . __( "(WordPress could not establish a secure connection to WordPress.org. Please contact your server administrator.)" ),
--                                         headers_sent() || WP_DEBUG ? E_USER_WARNING : E_USER_NOTICE
--                                 );
--                         end;
--                         request = wp_remote_get( http_url, http_args );
--                 end;

--                 if ( is_wp_error( request ) ) then
--                         res = new WP_Error(
--                                 "themes_api_failed",
--                                 sprintf(
--                                         /* translators: %s: Support forums URL.--
--                                         __( "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href="%s">support forums</a>." ),
--                                         __( "https://wordpress.org/support/forums/" )
--                                 ),
--                                 request.get_error_message()
--                         );
--                 end; else then
--                         res = json_decode( wp_remote_retrieve_body( request ), true );
--                         if ( is_array( res ) ) then
--                                 // Object casting is required in order to match the info/1.0 format.
--                                 res = (object) res;
--                         end; elseif ( null === res ) then
--                                 res = new WP_Error(
--                                         "themes_api_failed",
--                                         sprintf(
--                                                 /* translators: %s: Support forums URL.--
--                                                 __( "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href="%s">support forums</a>." ),
--                                                 __( "https://wordpress.org/support/forums/" )
--                                         ),
--                                         wp_remote_retrieve_body( request )
--                                 );
--                         end;

--                         if ( isset( res.error ) ) then
--                                 res = new WP_Error( "themes_api_failed", res.error );
--                         end;
--                 end;

--                 if ( ! is_wp_error( res ) ) then
--                         // Back-compat for info/1.2 API, upgrade the theme objects in query_themes to objects.
--                         if ( "query_themes" === action ) then
--                                 foreach ( res.themes as i => theme ) then
--                                         res.themes[ i ] = (object) theme;
--                                 end;
--                         end;

--                         // Back-compat for info/1.2 API, downgrade the feature_list result back to an array.
--                         if ( "feature_list" === action ) then
--                                 res = (array) res;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters the returned WordPress.org Themes API response.
--         --
--         -- @since 2.8.0
--         --
--         -- @param array|stdClass|WP_Error res    WordPress.org Themes API response.
--         -- @param string                  action Requested action. Likely values are "theme_information",
--         --                                        "feature_list", or "query_themes".
--         -- @param stdClass                args   Arguments used to query for installer pages from the WordPress.org Themes API.
--         --
--         return apply_filters( "themes_api_result", res, action, args );
-- end;

   ------------------------------
   -- Wp_Prepare_Themes_For_JS --
   ------------------------------

   function Wp_Prepare_Themes_For_JS (Themes : Array_Type := Empty_Array) -- null
                                      return Array_Type
   is (raise Program_Error with "not implemented");
--         current_theme = get_stylesheet();

--         --
--         -- Filters theme data before it is prepared for JavaScript.
--         --
--         -- Passing a non-empty array will result in wp_prepare_themes_for_js() returning
--         -- early with that value instead.
--         --
--         -- @since 4.2.0
--         --
--         -- @param array           prepared_themes An associative array of theme data. Default empty array.
--         -- @param WP_Theme[]|null themes          An array of theme objects to prepare, if any.
--         -- @param string          current_theme   The active theme slug.
--         --
--         prepared_themes = (array) apply_filters( "pre_prepare_themes_for_js", array(), themes, current_theme );

--         if ( ! empty( prepared_themes ) ) then
--                 return prepared_themes;
--         end;

--         // Make sure the active theme is listed first.
--         prepared_themes[ current_theme ] = array();

--         if ( null === themes ) then
--                 themes = wp_get_themes( array( "allowed" => true ) );
--                 if ( ! isset( themes[ current_theme ] ) ) then
--                         themes[ current_theme ] = wp_get_theme();
--                 end;
--         end;

--         updates    = array();
--         no_updates = array();
--         if ( ! is_multisite() && current_user_can( "update_themes" ) ) then
--                 updates_transient = get_site_transient( "update_themes" );
--                 if ( isset( updates_transient.response ) ) then
--                         updates = updates_transient.response;
--                 end;
--                 if ( isset( updates_transient.no_update ) ) then
--                         no_updates = updates_transient.no_update;
--                 end;
--         end;

--         WP_Theme::sort_by_name( themes );

--         parents = array();

--         auto_updates = (array) get_site_option( "auto_update_themes", array() );

--         foreach ( themes as theme ) then
--                 slug         = theme.get_stylesheet();
--                 encoded_slug = urlencode( slug );

--                 parent = false;
--                 if ( theme.parent() ) then
--                         parent           = theme.parent();
--                         parents[ slug ] = parent.get_stylesheet();
--                         parent           = parent.display( "Name" );
--                 end;

--                 customize_action = null;

--                 can_edit_theme_options = current_user_can( "edit_theme_options" );
--                 can_customize          = current_user_can( "customize" );
--                 is_block_theme         = theme.is_block_theme();

--                 if ( is_block_theme && can_edit_theme_options ) then
--                         customize_action = esc_url( admin_url( "site-editor.php" ) );
--                 end; elseif ( ! is_block_theme && can_customize && can_edit_theme_options ) then
--                         customize_action = esc_url(
--                                 add_query_arg(
--                                         array(
--                                                 "return" => urlencode( sanitize_url( remove_query_arg( wp_removable_query_args(), wp_unslash( _SERVER["REQUEST_URI"] ) ) ) ),
--                                         ),
--                                         wp_customize_url( slug )
--                                 )
--                         );
--                 end;

--                 update_requires_wp  = isset( updates[ slug ]["requires"] ) ? updates[ slug ]["requires"] : null;
--                 update_requires_php = isset( updates[ slug ]["requires_php"] ) ? updates[ slug ]["requires_php"] : null;

--                 auto_update        = in_array( slug, auto_updates, true );
--                 auto_update_action = auto_update ? "disable-auto-update" : "enable-auto-update";

--                 if ( isset( updates[ slug ] ) ) then
--                         auto_update_supported      = true;
--                         auto_update_filter_payload = (object) updates[ slug ];
--                 end; elseif ( isset( no_updates[ slug ] ) ) then
--                         auto_update_supported      = true;
--                         auto_update_filter_payload = (object) no_updates[ slug ];
--                 end; else then
--                         auto_update_supported = false;
--                         /*
--                         -- Create the expected payload for the auto_update_theme filter, this is the same data
--                         -- as contained within updates or no_updates but used when the Theme is not known.
--                         --
--                         auto_update_filter_payload = (object) array(
--                                 "theme"        => slug,
--                                 "new_version"  => theme.get( "Version" ),
--                                 "url"          => "",
--                                 "package"      => "",
--                                 "requires"     => theme.get( "RequiresWP" ),
--                                 "requires_php" => theme.get( "RequiresPHP" ),
--                         );
--                 end;

--                 auto_update_forced = wp_is_auto_update_forced_for_item( "theme", null, auto_update_filter_payload );

--                 prepared_themes[ slug ] = array(
--                         "id"             => slug,
--                         "name"           => theme.display( "Name" ),
--                         "screenshot"     => array( theme.get_screenshot() ), // @todo Multiple screenshots.
--                         "description"    => theme.display( "Description" ),
--                         "author"         => theme.display( "Author", false, true ),
--                         "authorAndUri"   => theme.display( "Author" ),
--                         "tags"           => theme.display( "Tags" ),
--                         "version"        => theme.get( "Version" ),
--                         "compatibleWP"   => is_wp_version_compatible( theme.get( "RequiresWP" ) ),
--                         "compatiblePHP"  => is_php_version_compatible( theme.get( "RequiresPHP" ) ),
--                         "updateResponse" => array(
--                                 "compatibleWP"  => is_wp_version_compatible( update_requires_wp ),
--                                 "compatiblePHP" => is_php_version_compatible( update_requires_php ),
--                         ),
--                         "parent"         => parent,
--                         "active"         => slug === current_theme,
--                         "hasUpdate"      => isset( updates[ slug ] ),
--                         "hasPackage"     => isset( updates[ slug ] ) && ! empty( updates[ slug ]["package"] ),
--                         "update"         => get_theme_update_available( theme ),
--                         "autoupdate"     => array(
--                                 "enabled"   => auto_update || auto_update_forced,
--                                 "supported" => auto_update_supported,
--                                 "forced"    => auto_update_forced,
--                         ),
--                         "actions"        => array(
--                                 "activate"   => current_user_can( "switch_themes" ) ? wp_nonce_url( admin_url( "themes.php?action=activate&amp;stylesheet=" . encoded_slug ), "switch-theme_" . slug ) : null,
--                                 "customize"  => customize_action,
--                                 "delete"     => ( ! is_multisite() && current_user_can( "delete_themes" ) ) ? wp_nonce_url( admin_url( "themes.php?action=delete&amp;stylesheet=" . encoded_slug ), "delete-theme_" . slug ) : null,
--                                 "autoupdate" => wp_is_auto_update_enabled_for_type( "theme" ) && ! is_multisite() && current_user_can( "update_themes" )
--                                         ? wp_nonce_url( admin_url( "themes.php?action=" . auto_update_action . "&amp;stylesheet=" . encoded_slug ), "updates" )
--                                         : null,
--                         ),
--                         "blockTheme"     => theme.is_block_theme(),
--                 );
--         end;

--         // Remove "delete" action if theme has an active child.
--         if ( ! empty( parents ) && array_key_exists( current_theme, parents ) ) then
--                 unset( prepared_themes[ parents[ current_theme ] ]["actions"]["delete"] );
--         end;

--         --
--         -- Filters the themes prepared for JavaScript, for themes.php.
--         --
--         -- Could be useful for changing the order, which is by name by default.
--         --
--         -- @since 3.8.0
--         --
--         -- @param array prepared_themes Array of theme data.
--         --
--         prepared_themes = apply_filters( "wp_prepare_themes_for_js", prepared_themes );
--         prepared_themes = array_values( prepared_themes );
--         return array_filter( prepared_themes );
-- end;

-- --
-- -- Prints JS templates for the theme-browsing UI in the Customizer.
-- --
-- -- @since 4.2.0
-- --
-- function customize_themes_print_templates() then
--         ?>
--         <script type="text/html" id="tmpl-customize-themes-details-view">
--                 <div class="theme-backdrop"></div>
--                 <div class="theme-wrap wp-clearfix" role="document">
--                         <div class="theme-header">
--                                 <button type="button" class="left dashicons dashicons-no"><span class="screen-reader-text"><?php _e( "Show previous theme" ); ?></span></button>
--                                 <button type="button" class="right dashicons dashicons-no"><span class="screen-reader-text"><?php _e( "Show next theme" ); ?></span></button>
--                                 <button type="button" class="close dashicons dashicons-no"><span class="screen-reader-text"><?php _e( "Close details dialog" ); ?></span></button>
--                         </div>
--                         <div class="theme-about wp-clearfix">
--                                 <div class="theme-screenshots">
--                                 <# if ( data.screenshot && data.screenshot[0] ) then #>
--                                         <div class="screenshot"><img src="thenthen data.screenshot[0] end;end;?ver=thenthen data.version end;end;" alt="" /></div>
--                                 <# end; else then #>
--                                         <div class="screenshot blank"></div>
--                                 <# end; #>
--                                 </div>

--                                 <div class="theme-info">
--                                         <# if ( data.active ) then #>
--                                                 <span class="current-label"><?php _e( "Active Theme" ); ?></span>
--                                         <# end; #>
--                                         <h2 class="theme-name">thenthenthen data.name end;end;end;<span class="theme-version">
--                                                 <?php
--                                                 /* translators: %s: Theme version.--
--                                                 printf( __( "Version: %s" ), "thenthen data.version end;end;" );
--                                                 ?>
--                                         </span></h2>
--                                         <h3 class="theme-author">
--                                                 <?php
--                                                 /* translators: %s: Theme author link.--
--                                                 printf( __( "By %s" ), "thenthenthen data.authorAndUri end;end;end;" );
--                                                 ?>
--                                         </h3>

--                                         <# if ( data.stars && 0 != data.num_ratings ) then #>
--                                                 <div class="theme-rating">
--                                                         thenthenthen data.stars end;end;end;
--                                                         <a class="num-ratings" target="_blank" href="thenthen data.reviews_url end;end;">
--                                                                 <?php
--                                                                 printf(
--                                                                         "%1s <span class="screen-reader-text">%2s</span>",
--                                                                         /* translators: %s: Number of ratings.--
--                                                                         sprintf( __( "(%s ratings)" ), "thenthen data.num_ratings end;end;" ),
--                                                                         /* translators: Accessibility text.--
--                                                                         __( "(opens in a new tab)" )
--                                                                 );
--                                                                 ?>
--                                                         </a>
--                                                 </div>
--                                         <# end; #>

--                                         <# if ( data.hasUpdate ) then #>
--                                                 <# if ( data.updateResponse.compatibleWP && data.updateResponse.compatiblePHP ) then #>
--                                                         <div class="notice notice-warning notice-alt notice-large" data-slug="thenthen data.id end;end;">
--                                                                 <h3 class="notice-title"><?php _e( "Update Available" ); ?></h3>
--                                                                 thenthenthen data.update end;end;end;
--                                                         </div>
--                                                 <# end; else then #>
--                                                         <div class="notice notice-error notice-alt notice-large" data-slug="thenthen data.id end;end;">
--                                                                 <h3 class="notice-title"><?php _e( "Update Incompatible" ); ?></h3>
--                                                                 <p>
--                                                                         <# if ( ! data.updateResponse.compatibleWP && ! data.updateResponse.compatiblePHP ) then #>
--                                                                                 <?php
--                                                                                 printf(
--                                                                                         /* translators: %s: Theme name.--
--                                                                                         __( "There is a new version of %s available, but it does not work with your versions of WordPress and PHP." ),
--                                                                                         "thenthenthen data.name end;end;end;"
--                                                                                 );
--                                                                                 if ( current_user_can( "update_core" ) && current_user_can( "update_php" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.--
--                                                                                                 " " . __( "<a href="%1s">Please update WordPress</a>, and then <a href="%2s">learn more about updating PHP</a>." ),
--                                                                                                 self_admin_url( "update-core.php" ),
--                                                                                                 esc_url( wp_get_update_php_url() )
--                                                                                         );
--                                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                                 end; elseif ( current_user_can( "update_core" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: %s: URL to WordPress Updates screen.--
--                                                                                                 " " . __( "<a href="%s">Please update WordPress</a>." ),
--                                                                                                 self_admin_url( "update-core.php" )
--                                                                                         );
--                                                                                 end; elseif ( current_user_can( "update_php" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: %s: URL to Update PHP page.--
--                                                                                                 " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
--                                                                                                 esc_url( wp_get_update_php_url() )
--                                                                                         );
--                                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                                 end;
--                                                                                 ?>
--                                                                         <# end; else if ( ! data.updateResponse.compatibleWP ) then #>
--                                                                                 <?php
--                                                                                 printf(
--                                                                                         /* translators: %s: Theme name.--
--                                                                                         __( "There is a new version of %s available, but it does not work with your version of WordPress." ),
--                                                                                         "thenthenthen data.name end;end;end;"
--                                                                                 );
--                                                                                 if ( current_user_can( "update_core" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: %s: URL to WordPress Updates screen.--
--                                                                                                 " " . __( "<a href="%s">Please update WordPress</a>." ),
--                                                                                                 self_admin_url( "update-core.php" )
--                                                                                         );
--                                                                                 end;
--                                                                                 ?>
--                                                                         <# end; else if ( ! data.updateResponse.compatiblePHP ) then #>
--                                                                                 <?php
--                                                                                 printf(
--                                                                                         /* translators: %s: Theme name.--
--                                                                                         __( "There is a new version of %s available, but it does not work with your version of PHP." ),
--                                                                                         "thenthenthen data.name end;end;end;"
--                                                                                 );
--                                                                                 if ( current_user_can( "update_php" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: %s: URL to Update PHP page.--
--                                                                                                 " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
--                                                                                                 esc_url( wp_get_update_php_url() )
--                                                                                         );
--                                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                                 end;
--                                                                                 ?>
--                                                                         <# end; #>
--                                                                 </p>
--                                                         </div>
--                                                 <# end; #>
--                                         <# end; #>

--                                         <# if ( data.parent ) then #>
--                                                 <p class="parent-theme">
--                                                         <?php
--                                                         printf(
--                                                                 /* translators: %s: Theme name.--
--                                                                 __( "This is a child theme of %s." ),
--                                                                 "<strong>thenthenthen data.parent end;end;end;</strong>"
--                                                         );
--                                                         ?>
--                                                 </p>
--                                         <# end; #>

--                                         <# if ( ! data.compatibleWP || ! data.compatiblePHP ) then #>
--                                                 <div class="notice notice-error notice-alt notice-large"><p>
--                                                         <# if ( ! data.compatibleWP && ! data.compatiblePHP ) then #>
--                                                                 <?php
--                                                                 _e( "This theme does not work with your versions of WordPress and PHP." );
--                                                                 if ( current_user_can( "update_core" ) && current_user_can( "update_php" ) ) then
--                                                                         printf(
--                                                                                 /* translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.--
--                                                                                 " " . __( "<a href="%1s">Please update WordPress</a>, and then <a href="%2s">learn more about updating PHP</a>." ),
--                                                                                 self_admin_url( "update-core.php" ),
--                                                                                 esc_url( wp_get_update_php_url() )
--                                                                         );
--                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                 end; elseif ( current_user_can( "update_core" ) ) then
--                                                                         printf(
--                                                                                 /* translators: %s: URL to WordPress Updates screen.--
--                                                                                 " " . __( "<a href="%s">Please update WordPress</a>." ),
--                                                                                 self_admin_url( "update-core.php" )
--                                                                         );
--                                                                 end; elseif ( current_user_can( "update_php" ) ) then
--                                                                         printf(
--                                                                                 /* translators: %s: URL to Update PHP page.--
--                                                                                 " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
--                                                                                 esc_url( wp_get_update_php_url() )
--                                                                         );
--                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                 end;
--                                                                 ?>
--                                                         <# end; else if ( ! data.compatibleWP ) then #>
--                                                                 <?php
--                                                                 _e( "This theme does not work with your version of WordPress." );
--                                                                 if ( current_user_can( "update_core" ) ) then
--                                                                         printf(
--                                                                                 /* translators: %s: URL to WordPress Updates screen.--
--                                                                                 " " . __( "<a href="%s">Please update WordPress</a>." ),
--                                                                                 self_admin_url( "update-core.php" )
--                                                                         );
--                                                                 end;
--                                                                 ?>
--                                                         <# end; else if ( ! data.compatiblePHP ) then #>
--                                                                 <?php
--                                                                 _e( "This theme does not work with your version of PHP." );
--                                                                 if ( current_user_can( "update_php" ) ) then
--                                                                         printf(
--                                                                                 /* translators: %s: URL to Update PHP page.--
--                                                                                 " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
--                                                                                 esc_url( wp_get_update_php_url() )
--                                                                         );
--                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                 end;
--                                                                 ?>
--                                                         <# end; #>
--                                                 </p></div>
--                                         <# end; else if ( ! data.active && data.blockTheme ) then #>
--                                                 <div class="notice notice-error notice-alt notice-large"><p>
--                                                 <?php
--                                                         _e( "This theme doesn\'t support Customizer." );
--                                                 ?>
--                                                 <# if ( data.actions.activate ) then #>
--                                                         <?php
--                                                         printf(
--                                                                 /* translators: %s: URL to the themes page (also it activates the theme).--
--                                                                 " " . __( "However, you can still <a href="%s">activate this theme</a>, and use the Site Editor to customize it." ),
--                                                                 "thenthenthen data.actions.activate end;end;end;"
--                                                         );
--                                                         ?>
--                                                 <# end; #>
--                                                 </p></div>
--                                         <# end; #>

--                                         <p class="theme-description">thenthenthen data.description end;end;end;</p>

--                                         <# if ( data.tags ) then #>
--                                                 <p class="theme-tags"><span><?php _e( "Tags:" ); ?></span> thenthenthen data.tags end;end;end;</p>
--                                         <# end; #>
--                                 </div>
--                         </div>

--                         <div class="theme-actions">
--                                 <# if ( data.active ) then #>
--                                         <button type="button" class="button button-primary customize-theme"><?php _e( "Customize" ); ?></button>
--                                 <# end; else if ( "installed" === data.type ) then #>
--                                         <?php if ( current_user_can( "delete_themes" ) ) then ?>
--                                                 <# if ( data.actions && data.actions["delete"] ) then #>
--                                                         <a href="thenthenthen data.actions["delete"] end;end;end;" data-slug="thenthen data.id end;end;" class="button button-secondary delete-theme"><?php _e( "Delete" ); ?></a>
--                                                 <# end; #>
--                                         <?php end; ?>

--                                         <# if ( data.blockTheme ) then #>
--                                                 <?php
--                                                         /* translators: %s: Theme name.--
--                                                         aria_label = sprintf( _x( "Activate %s", "theme" ), "thenthen data.name end;end;" );
--                                                 ?>
--                                                 <# if ( data.compatibleWP && data.compatiblePHP && data.actions.activate ) then #>
--                                                         <a href="thenthenthen data.actions.activate end;end;end;" class="button button-primary activate" aria-label="<?php echo esc_attr( aria_label ); ?>"><?php _e( "Activate" ); ?></a>
--                                                 <# end; #>
--                                         <# end; else then #>
--                                                 <# if ( data.compatibleWP && data.compatiblePHP ) then #>
--                                                         <button type="button" class="button button-primary preview-theme" data-slug="thenthen data.id end;end;"><?php _e( "Live Preview" ); ?></button>
--                                                 <# end; else then #>
--                                                         <button class="button button-primary disabled"><?php _e( "Live Preview" ); ?></button>
--                                                 <# end; #>
--                                         <# end; #>
--                                 <# end; else then #>
--                                         <# if ( data.compatibleWP && data.compatiblePHP ) then #>
--                                                 <button type="button" class="button theme-install" data-slug="thenthen data.id end;end;"><?php _e( "Install" ); ?></button>
--                                                 <button type="button" class="button button-primary theme-install preview" data-slug="thenthen data.id end;end;"><?php _e( "Install &amp; Preview" ); ?></button>
--                                         <# end; else then #>
--                                                 <button type="button" class="button disabled"><?php _ex( "Cannot Install", "theme" ); ?></button>
--                                                 <button type="button" class="button button-primary disabled"><?php _e( "Install &amp; Preview" ); ?></button>
--                                         <# end; #>
--                                 <# end; #>
--                         </div>
--                 </div>
--         </script>
--         <?php
-- end;

-- --
-- -- Determines whether a theme is technically active but was paused while
-- -- loading.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 5.2.0
-- --
-- -- @param string theme Path to the theme directory relative to the themes directory.
-- -- @return bool True, if in the list of paused themes. False, not in the list.
-- --
-- function is_theme_paused( theme ) then
--         if ( ! isset( GLOBALS["_paused_themes"] ) ) then
--                 return false;
--         end;

--         if ( get_stylesheet() !== theme && get_template() !== theme ) then
--                 return false;
--         end;

--         return array_key_exists( theme, GLOBALS["_paused_themes"] );
-- end;

-- --
-- -- Gets the error that was recorded for a paused theme.
-- --
-- -- @since 5.2.0
-- --
-- -- @param string theme Path to the theme directory relative to the themes
-- --                      directory.
-- -- @return array|false Array of error information as it was returned by
-- --                     `error_get_last()`, or false if none was recorded.
-- --
-- function wp_get_theme_error( theme ) then
--         if ( ! isset( GLOBALS["_paused_themes"] ) ) then
--                 return false;
--         end;

--         if ( ! array_key_exists( theme, GLOBALS["_paused_themes"] ) ) then
--                 return false;
--         end;

--         return GLOBALS["_paused_themes"][ theme ];
-- end;

   ------------------
   -- Resume_Theme --
   ------------------

   function Resume_Theme (Theme    : String;
                          Redirect : String := "")
                          return Bool_Error_Type
   is (raise Program_Error with "not implemented");
--         list( extension ) = explode( "/", theme );

--         /*
--         -- We"ll override this later if the theme could be resumed without
--         -- creating a fatal error.
--         --
--         if ( ! empty( redirect ) ) then
--                 functions_path = "";
--                 if ( strpos( STYLESHEETPATH, extension ) ) then
--                         functions_path = STYLESHEETPATH . "/functions.php";
--                 end; elseif ( strpos( TEMPLATEPATH, extension ) ) then
--                         functions_path = TEMPLATEPATH . "/functions.php";
--                 end;

--                 if ( ! empty( functions_path ) ) then
--                         wp_redirect(
--                                 add_query_arg(
--                                         "_error_nonce",
--                                         wp_create_nonce( "theme-resume-error_" . theme ),
--                                         redirect
--                                 )
--                         );

--                         -- Load the theme's functions.php to test whether it throws a fatal error.
--                         ob_start();
--                         if ( ! defined( "WP_SANDBOX_SCRAPING" ) ) then
--                                 define( "WP_SANDBOX_SCRAPING", true );
--                         end;
--                         include functions_path;
--                         ob_clean();
--                 end;
--         end;

--         result = wp_paused_themes().delete( extension );

--         if ( ! result ) then
--                 return new WP_Error(
--                         "could_not_resume_theme",
--                         __( "Could not resume the theme." )
--                 );
--         end;

--         return true;
-- end;

-- --
-- -- Renders an admin notice in case some themes have been paused due to errors.
-- --
-- -- @since 5.2.0
-- --
-- -- @global string pagenow The filename of the current screen.
-- --
-- function paused_themes_notice() then
--         if ( "themes.php" === GLOBALS["pagenow"] ) then
--                 return;
--         end;

--         if ( ! current_user_can( "resume_themes" ) ) then
--                 return;
--         end;

--         if ( ! isset( GLOBALS["_paused_themes"] ) || empty( GLOBALS["_paused_themes"] ) ) then
--                 return;
--         end;

--         printf(
--                 "<div class="notice notice-error"><p><strong>%s</strong><br>%s</p><p><a href="%s">%s</a></p></div>",
--                 __( "One or more themes failed to load properly." ),
--                 __( "You can find more details and make changes on the Themes screen." ),
--                 esc_url( admin_url( "themes.php" ) ),
--                 __( "Go to the Themes screen" )
--         );
-- end;

end Adi_Themes;
