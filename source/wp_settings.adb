--
-- Used to set up and fix common variables and include
-- the WordPress procedural and class library.
--
-- Allows for some configuration in wp-config.php (see default-constants.php)
--
-- @package WordPress
--

with Globals;
with Php;

with Inc_Default_Filters;
-- with Inc_Default_Constants;
with Inc_L10n;
with Inc_Load;
with Inc_Plugins;
with Inc_Pluggables;
with Inc_Posts;
with Inc_Taxonomys;
with Inc_Themes;
with Inc_Vars;
with Inc_Versions;

package body Wp_Settings
is

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Inc_Plugins;
   begin
      --
      -- Stores the location of the WordPress directory of functions, classes,
      -- and core content.
      --
      -- @since 1.0.0
      --
--    WPINC := "wp-includes";

      --
      -- Version information for the current WordPress release.
      --
      -- These can't be directly globalized in version.php. When updating,
      -- we're including version.php from another installation and don't want
      -- these values to be overridden if already set.
      --
      -- @global string $wp_version             The WordPress version string.
      -- @global int    $wp_db_version          WordPress database version.
      -- @global string $tinymce_version        TinyMCE version.
      -- @global string $required_php_version   The required PHP version string.
      -- @global string $required_mysql_version The required MySQL version string.
      -- @global string $wp_local_package       Locale code of the package.
      --
-- global $wp_version, $wp_db_version, $tinymce_version, $required_php_version;
-- global $required_mysql_version, $wp_local_package;

--    Inc_Versions.Run;
--    Inc_Load.Run;
-- require ABSPATH . WPINC . '/version.php';
-- require ABSPATH . WPINC . '/load.php';

      -- Check for the required PHP version and for the MySQL extension or a
      --  database drop-in.
      Inc_Load.Wp_Check_Php_Mysql_Versions;

      -- Include files required for initialization.
      -- require ABSPATH . WPINC . '/class-wp-paused-extensions-storage.php';
      -- require ABSPATH . WPINC . '/class-wp-fatal-error-handler.php';
      -- require ABSPATH . WPINC . '/class-wp-recovery-mode-cookie-service.php';
      -- require ABSPATH . WPINC . '/class-wp-recovery-mode-key-service.php';
      -- require ABSPATH . WPINC . '/class-wp-recovery-mode-link-service.php';
      -- require ABSPATH . WPINC . '/class-wp-recovery-mode-email-service.php';
      -- require ABSPATH . WPINC . '/class-wp-recovery-mode.php';
      -- require ABSPATH . WPINC . '/error-protection.php';
      -- require ABSPATH . WPINC . '/default-constants.php';
      -- require_once ABSPATH . WPINC . '/plugin.php';

      --
      -- If not already configured, `$blog_id` will default to 1 in a single site
      -- configuration. In multisite, it will be overridden by default in
      --  ms-settings.php.
      --
      -- @global int $blog_id
      -- @since 2.0.0
      --
--      global $blog_id;

      -- Set initial default constants including WP_MEMORY_LIMIT, WP_MAX_MEMORY_LIMIT,
      -- WP_DEBUG, SCRIPT_DEBUG, WP_CONTENT_DIR and WP_CACHE.
--    Inc_Default_Constants.Wp_Initial_Constants;

      -- Make sure we register the shutdown handler for fatal errors as soon as
      -- possible.
--    Inc_Error_Protection.Wp_Register_Fatal_Error_Handler;

      -- WordPress calculates offsets from UTC.
      -- phpcs:ignore WordPress.DateTime.RestrictedFunctions.timezone_change_date_default_timezone_set
--    Date_Default_Timezone_Set ("UTC");

      -- Standardize $_SERVER variables across setups.
--    Inc_Load.Wp_Fix_Server_Vars;

      -- Check if we're in maintenance mode.
--    Inc_Load.Wp_Maintenance;

      -- Start loading timer.
      Inc_Load.Timer_Start;

      -- Check if we're in WP_DEBUG mode.
--    Inc_Load.Wp_Debug_Mode;

      --
      -- Filters whether to enable loading of the advanced-cache.php drop-in.
      --
      -- This filter runs before it can be used by plugins. It is designed for non-web
      -- run-times. If false is returned, advanced-cache.php will never be loaded.
      --
      -- @since 4.6.0
      --
      -- @param bool $enable_advanced_cache Whether to enable loading
      --                                    advanced-cache.php (if present).
      --                                    Default true.
      --
--       if
--         WP_CACHE and then
--           Apply_Filters ("enable_loading_advanced_cache_dropin", True) and then
--             File_Exists (WP_CONTENT_DIR & "/advanced-cache.php")
--       then
--          -- For an advanced caching plugin to use. Uses a static drop-in because
--          -- you would only want one.
-- --       include WP_CONTENT_DIR & "/advanced-cache.php";

--          -- Re-initialize any hooks added manually by advanced-cache.php.
--          if Wp_Filter then
--             Wp_Filter := Wp_Hook.Build_Preinitialized_Hooks (Wp_Filter); -- ::
--          end if;
--       end if;

      -- Define WP_LANG_DIR if not set.
      Inc_Load.Wp_Set_Lang_Dir;

      -- Load early WordPress files.
      -- require ABSPATH . WPINC . '/compat.php';
      -- require ABSPATH . WPINC . '/class-wp-list-util.php';
      -- require ABSPATH . WPINC . '/formatting.php';
      -- require ABSPATH . WPINC . '/meta.php';
      -- require ABSPATH . WPINC . '/functions.php';
      -- require ABSPATH . WPINC . '/class-wp-meta-query.php';
      -- require ABSPATH . WPINC . '/class-wp-matchesmapregex.php';
      -- require ABSPATH . WPINC . '/class-wp.php';
      -- require ABSPATH . WPINC . '/class-wp-error.php';
      -- require ABSPATH . WPINC . '/pomo/mo.php';

      --
      -- @global wpdb $wpdb WordPress database abstraction object.
      -- @since 0.71
      --
--    global $wpdb;

      -- Include the wpdb class and, if present, a db.php database drop-in.
      Inc_Load.Require_Wp_DB;

      -- Set the database table prefix and the format specifiers for database
      -- table columns.
--    $GLOBALS['table_prefix'] = $table_prefix;
      Inc_Load.Wp_Set_Wpdb_Vars;

      -- Start the WordPress object cache, or an external object cache if the
      -- drop-in is present.
--    Inc_Load.Wp_Start_Object_Cache;

      -- Attach the default filters.
--    Inc_Default_Filters.Run;
--    require ABSPATH & WPINC & "/default-filters.php";

      -- Initialize multisite if enabled.
      if Inc_Load.Is_Multisite then
         null;
         -- require ABSPATH . WPINC . '/class-wp-site-query.php';
         -- require ABSPATH . WPINC . '/class-wp-network-query.php';
         -- require ABSPATH . WPINC . '/ms-blogs.php';
         -- require ABSPATH . WPINC . '/ms-settings.php';
--    elsif not Defined ("MULTISITE") then
--       Globals.MULTISITE := False;
      end if;

--    Php.Register_Shutdown_Function ("shutdown_action_hook");

      -- Stop most of WordPress from being loaded if we just want the basics.
      -- if SHORTINIT then
      --    return False;
      -- end if;

      -- Load the L10n library.
--    require_once ABSPATH . WPINC . '/l10n.php';
--    require_once ABSPATH . WPINC . '/class-wp-textdomain-registry.php';
--    require_once ABSPATH . WPINC . '/class-wp-locale.php';
--    require_once ABSPATH . WPINC . '/class-wp-locale-switcher.php';

      -- Run the installer if WordPress is not installed.
--    Inc_Load.Wp_Not_Installed;

-- Load most of WordPress.
-- require ABSPATH . WPINC . '/class-wp-walker.php';
-- require ABSPATH . WPINC . '/class-wp-ajax-response.php';
-- require ABSPATH . WPINC . '/capabilities.php';
-- require ABSPATH . WPINC . '/class-wp-roles.php';
-- require ABSPATH . WPINC . '/class-wp-role.php';
-- require ABSPATH . WPINC . '/class-wp-user.php';
-- require ABSPATH . WPINC . '/class-wp-query.php';
-- require ABSPATH . WPINC . '/query.php';
-- require ABSPATH . WPINC . '/class-wp-date-query.php';
-- require ABSPATH . WPINC . '/theme.php';
-- require ABSPATH . WPINC . '/class-wp-theme.php';
-- require ABSPATH . WPINC . '/class-wp-theme-json-schema.php';
-- require ABSPATH . WPINC . '/class-wp-theme-json-data.php';
-- require ABSPATH . WPINC . '/class-wp-theme-json.php';
-- require ABSPATH . WPINC . '/class-wp-theme-json-resolver.php';
-- require ABSPATH . WPINC . '/global-styles-and-settings.php';
-- require ABSPATH . WPINC . '/class-wp-block-template.php';
-- require ABSPATH . WPINC . '/block-template-utils.php';
-- require ABSPATH . WPINC . '/block-template.php';
-- require ABSPATH . WPINC . '/theme-templates.php';
-- require ABSPATH . WPINC . '/template.php';
-- require ABSPATH . WPINC . '/https-detection.php';
-- require ABSPATH . WPINC . '/https-migration.php';
-- require ABSPATH . WPINC . '/class-wp-user-request.php';
-- require ABSPATH . WPINC . '/user.php';
-- require ABSPATH . WPINC . '/class-wp-user-query.php';
-- require ABSPATH . WPINC . '/class-wp-session-tokens.php';
-- require ABSPATH . WPINC . '/class-wp-user-meta-session-tokens.php';
-- require ABSPATH . WPINC . '/class-wp-metadata-lazyloader.php';
-- require ABSPATH . WPINC . '/general-template.php';
-- require ABSPATH . WPINC . '/link-template.php';
-- require ABSPATH . WPINC . '/author-template.php';
-- require ABSPATH . WPINC . '/robots-template.php';
-- require ABSPATH . WPINC . '/post.php';
-- require ABSPATH . WPINC . '/class-walker-page.php';
-- require ABSPATH . WPINC . '/class-walker-page-dropdown.php';
-- require ABSPATH . WPINC . '/class-wp-post-type.php';
-- require ABSPATH . WPINC . '/class-wp-post.php';
-- require ABSPATH . WPINC . '/post-template.php';
-- require ABSPATH . WPINC . '/revision.php';
-- require ABSPATH . WPINC . '/post-formats.php';
-- require ABSPATH . WPINC . '/post-thumbnail-template.php';
-- require ABSPATH . WPINC . '/category.php';
-- require ABSPATH . WPINC . '/class-walker-category.php';
-- require ABSPATH . WPINC . '/class-walker-category-dropdown.php';
-- require ABSPATH . WPINC . '/category-template.php';
-- require ABSPATH . WPINC . '/comment.php';
-- require ABSPATH . WPINC . '/class-wp-comment.php';
-- require ABSPATH . WPINC . '/class-wp-comment-query.php';
-- require ABSPATH . WPINC . '/class-walker-comment.php';
-- require ABSPATH . WPINC . '/comment-template.php';
-- require ABSPATH . WPINC . '/rewrite.php';
-- require ABSPATH . WPINC . '/class-wp-rewrite.php';
-- require ABSPATH . WPINC . '/feed.php';
-- require ABSPATH . WPINC . '/bookmark.php';
-- require ABSPATH . WPINC . '/bookmark-template.php';
-- require ABSPATH . WPINC . '/kses.php';
-- require ABSPATH . WPINC . '/cron.php';
-- require ABSPATH . WPINC . '/deprecated.php';
-- require ABSPATH . WPINC . '/script-loader.php';
-- require ABSPATH . WPINC . '/taxonomy.php';
-- require ABSPATH . WPINC . '/class-wp-taxonomy.php';
-- require ABSPATH . WPINC . '/class-wp-term.php';
-- require ABSPATH . WPINC . '/class-wp-term-query.php';
-- require ABSPATH . WPINC . '/class-wp-tax-query.php';
-- require ABSPATH . WPINC . '/update.php';
-- require ABSPATH . WPINC . '/canonical.php';
-- require ABSPATH . WPINC . '/shortcodes.php';
-- require ABSPATH . WPINC . '/embed.php';
-- require ABSPATH . WPINC . '/class-wp-embed.php';
-- require ABSPATH . WPINC . '/class-wp-oembed.php';
-- require ABSPATH . WPINC . '/class-wp-oembed-controller.php';
-- require ABSPATH . WPINC . '/media.php';
-- require ABSPATH . WPINC . '/http.php';
-- require ABSPATH . WPINC . '/class-wp-http.php';
-- require ABSPATH . WPINC . '/class-wp-http-streams.php';
-- require ABSPATH . WPINC . '/class-wp-http-curl.php';
-- require ABSPATH . WPINC . '/class-wp-http-proxy.php';
-- require ABSPATH . WPINC . '/class-wp-http-cookie.php';
-- require ABSPATH . WPINC . '/class-wp-http-encoding.php';
-- require ABSPATH . WPINC . '/class-wp-http-response.php';
-- require ABSPATH . WPINC . '/class-wp-http-requests-response.php';
-- require ABSPATH . WPINC . '/class-wp-http-requests-hooks.php';
-- require ABSPATH . WPINC . '/widgets.php';
-- require ABSPATH . WPINC . '/class-wp-widget.php';
-- require ABSPATH . WPINC . '/class-wp-widget-factory.php';
-- require ABSPATH . WPINC . '/nav-menu-template.php';
-- require ABSPATH . WPINC . '/nav-menu.php';
-- require ABSPATH . WPINC . '/admin-bar.php';
-- require ABSPATH . WPINC . '/class-wp-application-passwords.php';
-- require ABSPATH . WPINC . '/rest-api.php';
-- require ABSPATH . WPINC . '/rest-api/class-wp-rest-server.php';
-- require ABSPATH . WPINC . '/rest-api/class-wp-rest-response.php';
-- require ABSPATH . WPINC . '/rest-api/class-wp-rest-request.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-posts-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-attachments-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-global-styles-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-post-types-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-post-statuses-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-revisions-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-autosaves-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-taxonomies-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-terms-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-menu-items-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-menus-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-menu-locations-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-users-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-comments-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-search-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-blocks-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-block-types-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-block-renderer-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-settings-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-themes-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-plugins-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-block-directory-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-edit-site-export-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-pattern-directory-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-block-patterns-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-block-pattern-categories-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-application-passwords-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-site-health-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-sidebars-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-widget-types-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-widgets-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-templates-controller.php';
-- require ABSPATH . WPINC . '/rest-api/endpoints/class-wp-rest-url-details-controller.php';
-- require ABSPATH . WPINC . '/rest-api/fields/class-wp-rest-meta-fields.php';
-- require ABSPATH . WPINC . '/rest-api/fields/class-wp-rest-comment-meta-fields.php';
-- require ABSPATH . WPINC . '/rest-api/fields/class-wp-rest-post-meta-fields.php';
-- require ABSPATH . WPINC . '/rest-api/fields/class-wp-rest-term-meta-fields.php';
-- require ABSPATH . WPINC . '/rest-api/fields/class-wp-rest-user-meta-fields.php';
-- require ABSPATH . WPINC . '/rest-api/search/class-wp-rest-search-handler.php';
-- require ABSPATH . WPINC . '/rest-api/search/class-wp-rest-post-search-handler.php';
-- require ABSPATH . WPINC . '/rest-api/search/class-wp-rest-term-search-handler.php';
-- require ABSPATH . WPINC . '/rest-api/search/class-wp-rest-post-format-search-handler.php';
-- require ABSPATH . WPINC . '/sitemaps.php';
-- require ABSPATH . WPINC . '/sitemaps/class-wp-sitemaps.php';
-- require ABSPATH . WPINC . '/sitemaps/class-wp-sitemaps-index.php';
-- require ABSPATH . WPINC . '/sitemaps/class-wp-sitemaps-provider.php';
-- require ABSPATH . WPINC . '/sitemaps/class-wp-sitemaps-registry.php';
-- require ABSPATH . WPINC . '/sitemaps/class-wp-sitemaps-renderer.php';
-- require ABSPATH . WPINC . '/sitemaps/class-wp-sitemaps-stylesheet.php';
-- require ABSPATH . WPINC . '/sitemaps/providers/class-wp-sitemaps-posts.php';
-- require ABSPATH . WPINC . '/sitemaps/providers/class-wp-sitemaps-taxonomies.php';
-- require ABSPATH . WPINC . '/sitemaps/providers/class-wp-sitemaps-users.php';
-- require ABSPATH . WPINC . '/class-wp-block-editor-context.php';
-- require ABSPATH . WPINC . '/class-wp-block-type.php';
-- require ABSPATH . WPINC . '/class-wp-block-pattern-categories-registry.php';
-- require ABSPATH . WPINC . '/class-wp-block-patterns-registry.php';
-- require ABSPATH . WPINC . '/class-wp-block-styles-registry.php';
-- require ABSPATH . WPINC . '/class-wp-block-type-registry.php';
-- require ABSPATH . WPINC . '/class-wp-block.php';
-- require ABSPATH . WPINC . '/class-wp-block-list.php';
-- require ABSPATH . WPINC . '/class-wp-block-parser.php';
-- require ABSPATH . WPINC . '/blocks.php';
-- require ABSPATH . WPINC . '/blocks/index.php';
-- require ABSPATH . WPINC . '/block-editor.php';
-- require ABSPATH . WPINC . '/block-patterns.php';
-- require ABSPATH . WPINC . '/class-wp-block-supports.php';
-- require ABSPATH . WPINC . '/block-supports/utils.php';
-- require ABSPATH . WPINC . '/block-supports/align.php';
-- require ABSPATH . WPINC . '/block-supports/border.php';
-- require ABSPATH . WPINC . '/block-supports/colors.php';
-- require ABSPATH . WPINC . '/block-supports/custom-classname.php';
-- require ABSPATH . WPINC . '/block-supports/dimensions.php';
-- require ABSPATH . WPINC . '/block-supports/duotone.php';
-- require ABSPATH . WPINC . '/block-supports/elements.php';
-- require ABSPATH . WPINC . '/block-supports/generated-classname.php';
-- require ABSPATH . WPINC . '/block-supports/layout.php';
-- require ABSPATH . WPINC . '/block-supports/spacing.php';
-- require ABSPATH . WPINC . '/block-supports/typography.php';
-- require ABSPATH . WPINC . '/style-engine.php';
-- require ABSPATH . WPINC . '/style-engine/class-wp-style-engine.php';
-- require ABSPATH . WPINC . '/style-engine/class-wp-style-engine-css-declarations.php';
-- require ABSPATH . WPINC . '/style-engine/class-wp-style-engine-css-rule.php';
-- require ABSPATH . WPINC . '/style-engine/class-wp-style-engine-css-rules-store.php';
-- require ABSPATH . WPINC . '/style-engine/class-wp-style-engine-processor.php';

-- $GLOBALS['wp_embed'] = new WP_Embed();

      --
      -- WordPress Textdomain Registry object.
      --
      -- Used to support just-in-time translations for manually loaded text domains.
      --
      -- @since 6.1.0
      --
      -- @global WP_Textdomain_Registry $wp_textdomain_registry WordPress
      --                                Textdomain Registry.
      --
--    $GLOBALS['wp_textdomain_registry'] = new WP_Textdomain_Registry();

      -- Load multisite-specific files.
      if Inc_Load.Is_Multisite then
         null;
--       require ABSPATH . WPINC . '/ms-functions.php';
--       require ABSPATH . WPINC . '/ms-default-filters.php';
--       require ABSPATH . WPINC . '/ms-deprecated.php';
      end if;

      -- Define constants that rely on the API to obtain the default value.
      -- Define must-use plugin directory constants, which may be overridden in the
      -- sunrise.php drop-in.
      Inc_Default_Constants.Wp_Plugin_Directory_Constants;

--    $GLOBALS['wp_plugin_paths'] = array();

      -- Load must-use plugins.
--    for Mu_Plugin of Wp_Get_Mu_Plugins loop
--       X_Wp_Plugin_File := Mu_Plugin;
--       include_once (Mu_Plugin);
--       Mu_Plugin := X_Wp_Plugin_File;
         -- Avoid stomping of the $mu_plugin variable in a plugin.

         --
         -- Fires once a single must-use plugin has loaded.
         --
         -- @since 5.1.0
         --
         -- @param string $mu_plugin Full path to the plugin's main file.
         --
--       Do_Action ("mu_plugin_loaded", Mu_Plugin);
--    end loop;
--    unset( $mu_plugin, $_wp_plugin_file );

      -- Load network activated plugins.
--    if Inc_Load.Is_Multisite then
--       for Network_Plugin of Wp_Get_Active_Network_Plugins loop
--          Wp_Register_Plugin_Realpath (Network_Plugin);

--          X_Wp_Plugin_File := Network_Plugin;
--          Include_Once (Network_Plugin);
--          Network_Plugin := X_Wp_Plugin_File;
            -- Avoid stomping of the $network_plugin variable in a plugin.

            --
            -- Fires once a single network-activated plugin has loaded.
            --
            -- @since 5.1.0
            --
            -- @param string $network_plugin Full path to the plugin's main file.
            --
--          Do_Action ("network_plugin_loaded", Network_Plugin);
--       end loop;
--       null;
--       unset( $network_plugin, $_wp_plugin_file );
--    end if;

      --
      -- Fires once all must-use and network-activated plugins have loaded.
      --
      -- @since 2.8.0
      --
      Do_Action ("muplugins_loaded");

--    if Inc_Load.Is_Multisite then
--       Ms_Cookie_Constants;
--    end if;

      -- Define constants after multisite is loaded.
--    Wp_Cookie_Constants;

      -- Define and enforce our SSL constants.
--    Wp_SSL_Constants;

      -- Create common globals.
      Inc_Vars.Run;
--    require ABSPATH . WPINC . '/vars.php';

      -- Make taxonomies and posts available to plugins and themes.
      -- @plugin authors: warning: these get registered again on the init hook.
      Inc_Taxonomys.Create_Initial_Taxonomies;
      Inc_Posts.Create_Initial_Post_Types;

--    Wp_Start_Scraping_Edited_File_Errors;

      -- Register the default theme directory root.
      Inc_Themes.Register_Theme_Directory (Get_Theme_Root);

--    if not Inc_Load.Is_Multisite then
         -- Handle users requesting a recovery mode link and initiating recovery mode.
--       Wp_Recovery_Mode.Initialize;
--    end if;

      -- Load active plugins.
--    for Plugin of Wp_Get_Active_And_Valid_Plugins loop
--       Wp_Register_Plugin_Realpath (Plugin);

--       X_Wp_Plugin_File := Plugin;
--       Include_Once (Plugin);
--       Plugin := X_Wp_Plugin_File;
         -- Avoid stomping of the $plugin variable in a plugin.

         --
         -- Fires once a single activated plugin has loaded.
         --
         -- @since 5.1.0
         --
         -- @param string $plugin Full path to the plugin's main file.
         --
--       Do_Action ("plugin_loaded", Plugin);
--    end loop;
--    unset( $plugin, $_wp_plugin_file );

      -- Load pluggable functions.
      Inc_Pluggables.Run;
--    require ABSPATH . WPINC . '/pluggable.php';
--    require ABSPATH . WPINC . '/pluggable-deprecated.php';

      -- Set internal encoding.
--    Wp_Set_Internal_Encoding;

      -- Run wp_cache_postload() if object cache is enabled and the function exists.
--    if WP_CACHE and then Function_Exists ("wp_cache_postload") then
--       Wp_Cache_Postload;
--    end if;

      --
      -- Fires once activated plugins have loaded.
      --
      -- Pluggable functions are also available at this point in the loading order.
      --
      -- @since 1.5.0
      --
      Do_Action ("plugins_loaded");

      -- Define constants which affect functionality if not already defined.
      Inc_Default_Constants.Wp_Functionality_Constants;

      -- Add magic quotes and set up $_REQUEST ( $_GET + $_POST ).
      Inc_Load.Wp_Magic_Quotes;

      --
      -- Fires when comment cookies are sanitized.
      --
      -- @since 2.0.11
      --
      Do_Action ("sanitize_comment_cookies");

      --
      -- WordPress Query object
      --
      -- @global WP_Query $wp_the_query WordPress Query object.
      -- @since 2.0.0
      --
-- $GLOBALS['wp_the_query'] = new WP_Query();

      --
      -- Holds the reference to @see $wp_the_query
      -- Use this global for WordPress queries
      --
      -- @global WP_Query $wp_query WordPress Query object.
      -- @since 1.5.0
      --
-- $GLOBALS['wp_query'] = $GLOBALS['wp_the_query'];

      --
      -- Holds the WordPress Rewrite object for creating pretty URLs
      --
      -- @global WP_Rewrite $wp_rewrite WordPress rewrite component.
      -- @since 1.5.0
      --
-- $GLOBALS['wp_rewrite'] = new WP_Rewrite();

      --
      -- WordPress Object
      --
      -- @global WP $wp Current WordPress environment instance.
      -- @since 2.0.0
      --
-- $GLOBALS['wp'] = new WP();

      --
      -- WordPress Widget Factory Object
      --
      -- @global WP_Widget_Factory $wp_widget_factory
      -- @since 2.8.0
      --
-- $GLOBALS['wp_widget_factory'] = new WP_Widget_Factory();

      --
      -- WordPress User Roles
      --
      -- @global WP_Roles $wp_roles WordPress role management object.
      -- @since 2.0.0
      --
-- $GLOBALS['wp_roles'] = new WP_Roles();

      --
      -- Fires before the theme is loaded.
      --
      -- @since 2.6.0
      --
      Do_Action ("setup_theme");

      -- Define the template related constants.
      Inc_Default_Constants.Wp_Templating_Constants;

      -- Load the default text localization domain.
      declare
         Unused : Boolean;
      begin
         Unused := Inc_L10n.Load_Default_Textdomain;
      end;

--    declare
--       Locale      : constant String := Get_Locale;
--       Locale_File : constant String := WP_LANG_DIR & "/" & Locale & ".php";
--    begin
--       if
--         0 = Validate_File (Locale) and then
--         Php.Is_Readable (Locale_File)
--       then
--          require (Locale_File);
--       end if;
--       unset( $locale_file );
--    end;

      --
      -- WordPress Locale object for loading locale domain date and various strings.
      --
      -- @global WP_Locale $wp_locale WordPress date and time locale object.
      -- @since 2.1.0
      --
-- $GLOBALS['wp_locale'] = new WP_Locale();

      --
      -- WordPress Locale Switcher object for switching locales.
      --
      -- @since 4.7.0
      --
      -- @global WP_Locale_Switcher $wp_locale_switcher WordPress locale switcher
      --                                                object.
      --
-- $GLOBALS['wp_locale_switcher'] = new WP_Locale_Switcher();
-- $GLOBALS['wp_locale_switcher']->init();

      -- Load the functions for the active theme, for both parent and child theme
      -- if applicable.
--    for Theme of Wp_Get_Active_And_Valid_Themes loop
--       if Php.File_Exists (Theme & "/functions.php") then
--          null;
--          Include (theme & "/functions.php");
--       end if;
--    end loop;
--    unset( $theme );

      --
      -- Fires after the theme is loaded.
      --
      -- @since 3.0.0
      --
      Do_Action ("after_setup_theme");

      -- Create an instance of WP_Site_Health so that Cron events may fire.
--    if not Class_Exists ("WP_Site_Health") then
--       Require_Once (ABSPATH & "wp-admin/includes/class-wp-site-health.php");
--    end if;
--    Wp_Site_Health.Get_Instance;
--    WP_Site_Health::Get_Instance;

      -- Set up current user.
-- $GLOBALS['wp']->init();

      --
      -- Fires after WordPress has finished loading but before any headers are sent.
      --
      -- Most of WP is loaded at this stage, and the user is authenticated. WP
      -- continues to load on the {@see 'init'} hook that follows (e.g. widgets),
      -- and many plugins instantiate themselves on it for all sorts of reasons
      -- (e.g. they need a user, a taxonomy, etc.).
      --
      -- If you wish to plug an action once WP is loaded, use the {@see 'wp_loaded'}
      -- hook below.
      --
      -- @since 1.5.0
      --
      Do_Action ("init");

      -- Check site status.
      -- if Is_Multisite then
      --    $file = ms_site_check();
      --    if ( true !== $file ) then
      --       require $file;
      --       die();
      --    end if;
      --    unset( $file );
      -- end if;

      --
      -- This hook is fired once WP, all plugins, and the theme are fully loaded and
      -- instantiated.
      --
      -- Ajax requests should use wp-admin/admin-ajax.php. admin-ajax.php can handle
      -- requests for users not logged in.
      --
      -- @link https://codex.wordpress.org/AJAX_in_Plugins
      --
      -- @since 3.0.0
      --
      Do_Action ("wp_loaded");

   end Run;

end Wp_Settings;
