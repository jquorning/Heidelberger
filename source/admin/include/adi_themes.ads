--
-- WordPress Theme Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;

with Class_Errors;

package Adi_Themes
is
   use Arrays;

   type Bool_Error_Type is record
      Success : Boolean;
      Error   : Class_Errors.Wp_Error;
   end record;

   --
   -- Removes a theme.
   --
   -- @since 2.8.0
   --
   -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
   --
   -- @param string stylesheet Stylesheet of the theme to delete.
   -- @param string redirect   Redirect to page when complete.
   -- @return bool|null|WP_Error True on success, false if `stylesheet` is empty,
   --                            WP_Error on failure. Null if filesystem credentials
   --                            are required to proceed.
   --
   function Delete_Theme (Stylesheet : String;
                          Redirect   : String := "")
                          return Bool_Error_Type;

   procedure Delete_Theme (Stylesheet : String;
                           Redirect   : String := "");

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

   --
   -- Retrieves theme installer pages from the WordPress.org Themes API.
   --
   -- It is possible for a theme to override the Themes API result with three
   -- filters. Assume this is for themes, which can extend on the Theme Info to
   -- offer more choices. This is very powerful and must be used with care, when
   -- overriding the filters.
   --
   -- The first filter, then@see "themes_api_args"end;, is for the args and gives the action
   -- as the second parameter. The hook for then@see "themes_api_args"end; must ensure that
   -- an object is returned.
   --
   -- The second filter, then@see "themes_api"end;, allows a plugin to override the WordPress.org
   -- Theme API entirely. If `action` is "query_themes", "theme_information", or "feature_list",
   -- an object MUST be passed. If `action` is "hot_tags", an array should be passed.
   --
   -- Finally, the third filter, then@see "themes_api_result"end;, makes it possible to filter the
   -- response object or array, depending on the `action` type.
   --
   -- Supported arguments per action:
   --
   -- | Argument Name      | "query_themes" | "theme_information" | "hot_tags" | "feature_list"   |
   -- | -------------------| :------------: | :-----------------: | :--------: | :--------------: |
   -- | `slug`            | No             |  Yes                | No         | No               |
   -- | `per_page`        | Yes            |  No                 | No         | No               |
   -- | `page`            | Yes            |  No                 | No         | No               |
   -- | `number`          | No             |  No                 | Yes        | No               |
   -- | `search`          | Yes            |  No                 | No         | No               |
   -- | `tag`             | Yes            |  No                 | No         | No               |
   -- | `author`          | Yes            |  No                 | No         | No               |
   -- | `user`            | Yes            |  No                 | No         | No               |
   -- | `browse`          | Yes            |  No                 | No         | No               |
   -- | `locale`          | Yes            |  Yes                | No         | No               |
   -- | `fields`          | Yes            |  Yes                | No         | No               |
   --
   -- @since 2.8.0
   --
   -- @param string       action API action to perform: "query_themes", "theme_information",
   --                             "hot_tags" or "feature_list".
   -- @param array|object args   {
   --     Optional. Array or object of arguments to serialize for the Themes API.
   --
   --     @type string  slug     The theme slug. Default empty.
   --     @type int     per_page Number of themes per page. Default 24.
   --     @type int     page     Number of current page. Default 1.
   --     @type int     number   Number of tags to be queried.
   --     @type string  search   A search term. Default empty.
   --     @type string  tag      Tag to filter themes. Default empty.
   --     @type string  author   Username of an author to filter themes. Default empty.
   --     @type string  user     Username to query for their favorites. Default empty.
   --     @type string  browse   Browse view: "featured", "popular", "updated", "favorites".
   --     @type string  locale   Locale to provide context-sensitive results. Default is the value of get_locale().
   --     @type array   fields   {
   --         Array of fields which should or should not be returned.
   --
   --         @type bool description        Whether to return the theme full
   --                                       description. Default false.
   --         @type bool sections           Whether to return the theme readme
   --                                       sections: description, installation,  FAQ,
   --                                       screenshots, other notes, and changelog.
   --                                       Default false.
   --         @type bool rating             Whether to return the rating in percent
   --                                       and total number of ratings. Default false.
   --         @type bool ratings            Whether to return the number of rating for
   --                                       each star (1-5). Default false.
   --         @type bool downloaded         Whether to return the download count.
   --                                       Default false.
   --         @type bool downloadlink       Whether to return the download link for
   --                                       the package. Default false.
   --         @type bool last_updated       Whether to return the date of the last
   --                                       update. Default false.
   --         @type bool tags               Whether to return the assigned tags.
   --                                       Default false.
   --         @type bool homepage           Whether to return the theme homepage link.
   --                                       Default false.
   --         @type bool screenshots        Whether to return the screenshots. Default
   --                                       false.
   --         @type int  screenshot_count   Number of screenshots to return. Default 1.
   --         @type bool screenshot_url     Whether to return the URL of the first
   --                                       screenshot. Default false.
   --         @type bool photon_screenshots Whether to return the screenshots via
   --                                       Photon. Default false.
   --         @type bool template           Whether to return the slug of the parent
   --                                       theme. Default false.
   --         @type bool parent             Whether to return the slug, name and
   --                                       homepage of the parent theme. Default
   --                                       false.
   --         @type bool versions           Whether to return the list of all
   --                                       available versions. Default false.
   --         @type bool theme_url          Whether to return theme's URL. Default
   --                                       false.
   --         @type bool extended_author    Whether to return nicename or nicename and
   --                                       display name. Default false.
   --     }
   -- }
   -- @return object|array|WP_Error Response object or array on success, WP_Error on
   --         failure. See the
   --         {@link https://developer.wordpress.org/reference/functions/themes_api/
   --         function reference article} for more information on the make-up of
   --         possible return objects depending on the value of `action`.
   --
   type Array_Error_Type is record
      Success : Boolean;
      Arry    : Array_Type;
      Error   : Class_Errors.Wp_Error;
   end record;

   function Themes_API (Action : String;
                        Args   : Array_Type := Empty_Array)
                        return Array_Error_Type;

   --
   -- Prepares themes for JavaScript.
   --
   -- @since 3.8.0
   --
   -- @param WP_Theme[] themes Optional. Array of theme objects to prepare.
   --                           Defaults to all allowed themes.
   --
   -- @return array An associative array of theme data, sorted by name.
   --
   function Wp_Prepare_Themes_For_JS (Themes : Array_Type := Empty_Array) -- null
                                      return Array_Type;

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

   --
   -- Tries to resume a single theme.
   --
   -- If a redirect was provided and a functions.php file was found, we first ensure
   -- that functions.php file does not throw fatal errors anymore.
   --
   -- The way it works is by setting the redirection to the error before trying to
   -- include the file. If the theme fails, then the redirection will not be
   -- overwritten with the success message and the theme will not be resumed.
   --
   -- @since 5.2.0
   --
   -- @param string theme    Single theme to resume.
   -- @param string redirect Optional. URL to redirect to. Default empty string.
   -- @return bool|WP_Error True on success, false if `theme` was not paused,
   --                       `WP_Error` on failure.
   --
   function Resume_Theme (Theme    : String;
                          Redirect : String := "")
                          return Bool_Error_Type;

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
