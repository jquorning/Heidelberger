--
-- Block Editor API.
--
-- @package WordPress
-- @subpackage Editor
-- @since 5.8.0
--

with Arrays;
with Lists;

with Class_Block_Editor_Contexts;

package Inc_Block_Editors
is
   use Arrays;
   use Lists;

   --
   -- Returns the list of default categories for block types.
   --
   -- @since 5.8.0
   --
   -- @return array[] Array of categories for block types.
   --
   function Get_Default_Block_Categories
            return Array_Type;
--         return array(
--                 array(
--                         "slug"  => "text",
--                         "title" => _x( "Text", "block category" ),
--                         "icon"  => null,
--                 ),
--                 array(
--                         "slug"  => "media",
--                         "title" => _x( "Media", "block category" ),
--                         "icon"  => null,
--                 ),
--                 array(
--                         "slug"  => "design",
--                         "title" => _x( "Design", "block category" ),
--                         "icon"  => null,
--                 ),
--                 array(
--                         "slug"  => "widgets",
--                         "title" => _x( "Widgets", "block category" ),
--                         "icon"  => null,
--                 ),
--                 array(
--                         "slug"  => "theme",
--                         "title" => _x( "Theme", "block category" ),
--                         "icon"  => null,
--                 ),
--                 array(
--                         "slug"  => "embed",
--                         "title" => _x( "Embeds", "block category" ),
--                         "icon"  => null,
--                 ),
--                 array(
--                         "slug"  => "reusable",
--                         "title" => _x( "Reusable Blocks", "block category" ),
--                         "icon"  => null,
--                 ),
--         );
-- end;

   --
   -- Returns all the categories for block types that will be shown in the block
   -- editor.
   --
   -- @since 5.0.0
   -- @since 5.8.0 It is possible to pass the block editor context as param.
   --
   -- @param WP_Post|WP_Block_Editor_Context post_or_block_editor_context
   --           The current post object or the block editor context.
   --
   -- @return array[] Array of categories for block types.
   --
   function Get_Block_Categories
              (Post_Or_Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type;
--         block_categories     = get_default_block_categories();
--         block_editor_context = post_or_block_editor_context instanceof WP_Post ?
--                 new WP_Block_Editor_Context(
--                         array(
--                                 "post" => post_or_block_editor_context,
--                         )
--                 ) : post_or_block_editor_context;

--         --
--         -- Filters the default array of categories for block types.
--         --
--         -- @since 5.8.0
--         --
--         -- @param array[]                 block_categories     Array of categories for block types.
--         -- @param WP_Block_Editor_Context block_editor_context The current block editor context.
--         --
--         block_categories = apply_filters( "block_categories_all", block_categories, block_editor_context );

--         if ( ! empty( block_editor_context->post ) ) then
--                 post = block_editor_context->post;

--                 --
--                 -- Filters the default array of categories for block types.
--                 --
--                 -- @since 5.0.0
--                 -- @deprecated 5.8.0 Use the then@see "block_categories_all"end; filter instead.
--                 --
--                 -- @param array[] block_categories Array of categories for block types.
--                 -- @param WP_Post post             Post being loaded.
--                 --
--                 block_categories = apply_filters_deprecated( "block_categories", array( block_categories, post ), "5.8.0", "block_categories_all" );
--         end;

--         return block_categories;
-- end;

   --
   -- Gets the list of allowed block types to use in the block editor.
   --
   -- @since 5.8.0
   --
   -- @param WP_Block_Editor_Context block_editor_context The current block editor
   --                                                      context.
   --
   -- @return bool|string[] Array of block type slugs, or boolean to enable/disable
   --                        all.
   --
   function Get_Allowed_Block_Types
              (Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return List_Type;

   --
   -- Returns the default block editor settings.
   --
   -- @since 5.8.0
   --
   -- @return array The default block editor settings.
   --
   function Get_Default_Block_Editor_Settings
            return Array_Type;
--         // Media settings.

--         // wp_max_upload_size() can be expensive, so only call it when relevant for the current user.
--         max_upload_size = 0;
--         if ( current_user_can( "upload_files" ) ) then
--                 max_upload_size = wp_max_upload_size();
--                 if ( ! max_upload_size ) then
--                         max_upload_size = 0;
--                 end;
--         end;

--         -- This filter is documented in wp-admin/includes/media.php--
--         image_size_names = apply_filters(
--                 "image_size_names_choose",
--                 array(
--                         "thumbnail" => __( "Thumbnail" ),
--                         "medium"    => __( "Medium" ),
--                         "large"     => __( "Large" ),
--                         "full"      => __( "Full Size" ),
--                 )
--         );

--         available_image_sizes = array();
--         foreach ( image_size_names as image_size_slug => image_size_name ) then
--                 available_image_sizes[] = array(
--                         "slug" => image_size_slug,
--                         "name" => image_size_name,
--                 );
--         end;

--         default_size       = get_option( "image_default_size", "large" );
--         image_default_size = in_array( default_size, array_keys( image_size_names ), true ) ? default_size : "large";

--         image_dimensions = array();
--         all_sizes        = wp_get_registered_image_subsizes();
--         foreach ( available_image_sizes as size ) then
--                 key = size["slug"];
--                 if ( isset( all_sizes[ key ] ) ) then
--                         image_dimensions[ key ] = all_sizes[ key ];
--                 end;
--         end;

--         // These styles are used if the "no theme styles" options is triggered or on
--         // themes without their own editor styles.
--         default_editor_styles_file = ABSPATH . WPINC . "/css/dist/block-editor/default-editor-styles.css";

--         static default_editor_styles_file_contents = false;
--         if ( ! default_editor_styles_file_contents && file_exists( default_editor_styles_file ) ) then
--                 default_editor_styles_file_contents = file_get_contents( default_editor_styles_file );
--         end;

--         default_editor_styles = array();
--         if ( default_editor_styles_file_contents ) then
--                 default_editor_styles = array(
--                         array( "css" => default_editor_styles_file_contents ),
--                 );
--         end;

--         editor_settings = array(
--                 "alignWide"                        => get_theme_support( "align-wide" ),
--                 "allowedBlockTypes"                => true,
--                 "allowedMimeTypes"                 => get_allowed_mime_types(),
--                 "defaultEditorStyles"              => default_editor_styles,
--                 "blockCategories"                  => get_default_block_categories(),
--                 "disableCustomColors"              => get_theme_support( "disable-custom-colors" ),
--                 "disableCustomFontSizes"           => get_theme_support( "disable-custom-font-sizes" ),
--                 "disableCustomGradients"           => get_theme_support( "disable-custom-gradients" ),
--                 "disableLayoutStyles"              => get_theme_support( "disable-layout-styles" ),
--                 "enableCustomLineHeight"           => get_theme_support( "custom-line-height" ),
--                 "enableCustomSpacing"              => get_theme_support( "custom-spacing" ),
--                 "enableCustomUnits"                => get_theme_support( "custom-units" ),
--                 "isRTL"                            => is_rtl(),
--                 "imageDefaultSize"                 => image_default_size,
--                 "imageDimensions"                  => image_dimensions,
--                 "imageEditing"                     => true,
--                 "imageSizes"                       => available_image_sizes,
--                 "maxUploadFileSize"                => max_upload_size,
--                 // The following flag is required to enable the new Gallery block format on the mobile apps in 5.9.
--                 "__unstableGalleryWithImageBlocks" => true,
--         );

--         // Theme settings.
--         color_palette = current( (array) get_theme_support( "editor-color-palette" ) );
--         if ( false !== color_palette ) then
--                 editor_settings["colors"] = color_palette;
--         end;

--         font_sizes = current( (array) get_theme_support( "editor-font-sizes" ) );
--         if ( false !== font_sizes ) then
--                 editor_settings["fontSizes"] = font_sizes;
--         end;

--         gradient_presets = current( (array) get_theme_support( "editor-gradient-presets" ) );
--         if ( false !== gradient_presets ) then
--                 editor_settings["gradients"] = gradient_presets;
--         end;

--         return editor_settings;
-- end;

   --
   -- Returns the block editor settings needed to use the Legacy Widget block which
   -- is not registered by default.
   --
   -- @since 5.8.0
   --
   -- @return array Settings to be used with get_block_editor_settings().
   --

   function Get_Legacy_Widget_Block_Editor_Settings
            return Array_Type;

-- --
-- -- Collect the block editor assets that need to be loaded into the editor"s iframe.
-- --
-- -- @since 6.0.0
-- -- @access private
-- --
-- -- @global string pagenow The filename of the current screen.
-- --
-- -- @return array then
-- --     The block editor assets.
-- --
-- --     @type string|false styles  String containing the HTML for styles.
-- --     @type string|false scripts String containing the HTML for scripts.
-- -- end;
-- --
-- function _wp_get_iframed_editor_assets() then
--         global pagenow;

--         script_handles = array();
--         style_handles  = array(
--                 "wp-block-editor",
--                 "wp-block-library",
--                 "wp-edit-blocks",
--         );

--         if ( current_theme_supports( "wp-block-styles" ) ) then
--                 style_handles[] = "wp-block-library-theme";
--         end;

--         if ( "widgets.php" === pagenow || "customize.php" === pagenow ) then
--                 style_handles[] = "wp-widgets";
--                 style_handles[] = "wp-edit-widgets";
--         end;

--         block_registry = WP_Block_Type_Registry::get_instance();

--         foreach ( block_registry->get_all_registered() as block_type ) then
--                 style_handles = array_merge(
--                         style_handles,
--                         block_type->style_handles,
--                         block_type->editor_style_handles
--                 );

--                 script_handles = array_merge(
--                         script_handles,
--                         block_type->script_handles
--                 );
--         end;

--         style_handles = array_unique( style_handles );
--         done          = wp_styles()->done;

--         ob_start();

--         // We do not need reset styles for the iframed editor.
--         wp_styles()->done = array( "wp-reset-editor-styles" );
--         wp_styles()->do_items( style_handles );
--         wp_styles()->done = done;

--         styles = ob_get_clean();

--         script_handles = array_unique( script_handles );
--         done           = wp_scripts()->done;

--         ob_start();

--         wp_scripts()->done = array();
--         wp_scripts()->do_items( script_handles );
--         wp_scripts()->done = done;

--         scripts = ob_get_clean();

--         return array(
--                 "styles"  => styles,
--                 "scripts" => scripts,
--         );
-- end;

   --
   -- Returns the contextualized block editor settings for a selected editor context.
   --
   -- @since 5.8.0
   --
   -- @param array                   custom_settings      Custom settings to use with
   --                                                      the given editor type.
   -- @param WP_Block_Editor_Context block_editor_context The current block editor
   --                                                      context.
   --
   -- @return array The contextualized block editor settings.
   --
   function Get_Block_Editor_Settings
              (Custom_Settings      : Array_Type;
               Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type;

-- --
-- -- Preloads common data used with the block editor by specifying an array of
-- -- REST API paths that will be preloaded for a given block editor context.
-- --
-- -- @since 5.8.0
-- --
-- -- @global WP_Post    post       Global post object.
-- -- @global WP_Scripts wp_scripts The WP_Scripts object for printing scripts.
-- -- @global WP_Styles  wp_styles  The WP_Styles object for printing styles.
-- --
-- -- @param string[]                preload_paths        List of paths to preload.
-- -- @param WP_Block_Editor_Context block_editor_context The current block editor context.
-- --
-- function block_editor_rest_api_preload( array preload_paths, block_editor_context ) then
--         global post, wp_scripts, wp_styles;

--         --
--         -- Filters the array of REST API paths that will be used to preloaded common data for the block editor.
--         --
--         -- @since 5.8.0
--         --
--         -- @param string[]                preload_paths        Array of paths to preload.
--         -- @param WP_Block_Editor_Context block_editor_context The current block editor context.
--         --
--         preload_paths = apply_filters( "block_editor_rest_api_preload_paths", preload_paths, block_editor_context );

--         if ( ! empty( block_editor_context->post ) ) then
--                 selected_post = block_editor_context->post;

--                 --
--                 -- Filters the array of paths that will be preloaded.
--                 --
--                 -- Preload common data by specifying an array of REST API paths that will be preloaded.
--                 --
--                 -- @since 5.0.0
--                 -- @deprecated 5.8.0 Use the then@see "block_editor_rest_api_preload_paths"end; filter instead.
--                 --
--                 -- @param string[] preload_paths Array of paths to preload.
--                 -- @param WP_Post  selected_post Post being edited.
--                 --
--                 preload_paths = apply_filters_deprecated( "block_editor_preload_paths", array( preload_paths, selected_post ), "5.8.0", "block_editor_rest_api_preload_paths" );
--         end;

--         if ( empty( preload_paths ) ) then
--                 return;
--         end;

--         /*
--         -- Ensure the global post, wp_scripts, and wp_styles remain the same after
--         -- API data is preloaded.
--         -- Because API preloading can call the_content and other filters, plugins
--         -- can unexpectedly modify the global post or enqueue assets which are not
--         -- intended for the block editor.
--         --
--         backup_global_post = ! empty( post ) ? clone post : post;
--         backup_wp_scripts  = ! empty( wp_scripts ) ? clone wp_scripts : wp_scripts;
--         backup_wp_styles   = ! empty( wp_styles ) ? clone wp_styles : wp_styles;

--         foreach ( preload_paths as &path ) then
--                 if ( is_string( path ) && ! str_starts_with( path, "/" ) ) then
--                         path = "/" . path;
--                         continue;
--                 end;

--                 if ( is_array( path ) && is_string( path[0] ) && ! str_starts_with( path[0], "/" ) ) then
--                         path[0] = "/" . path[0];
--                 end;
--         end;

--         unset( path );

--         preload_data = array_reduce(
--                 preload_paths,
--                 "rest_preload_api_request",
--                 array()
--         );

--         // Restore the global post, wp_scripts, and wp_styles as they were before API preloading.
--         post       = backup_global_post;
--         wp_scripts = backup_wp_scripts;
--         wp_styles  = backup_wp_styles;

--         wp_add_inline_script(
--                 "wp-api-fetch",
--                 sprintf(
--                         "wp.apiFetch.use( wp.apiFetch.createPreloadingMiddleware( %s ) );",
--                         wp_json_encode( preload_data )
--                 ),
--                 "after"
--         );
-- end;

-- --
-- -- Creates an array of theme styles to load into the block editor.
-- --
-- -- @since 5.8.0
-- --
-- -- @global array editor_styles
-- --
-- -- @return array An array of theme styles for the block editor.
-- --
-- function get_block_editor_theme_styles() then
--         global editor_styles;

--         styles = array();

--         if ( editor_styles && current_theme_supports( "editor-styles" ) ) then
--                 foreach ( editor_styles as style ) then
--                         if ( preg_match( "~^(https?:)?//~", style ) ) then
--                                 response = wp_remote_get( style );
--                                 if ( ! is_wp_error( response ) ) then
--                                         styles[] = array(
--                                                 "css"            => wp_remote_retrieve_body( response ),
--                                                 "__unstableType" => "theme",
--                                                 "isGlobalStyles" => false,
--                                         );
--                                 end;
--                         end; else then
--                                 file = get_theme_file_path( style );
--                                 if ( is_file( file ) ) then
--                                         styles[] = array(
--                                                 "css"            => file_get_contents( file ),
--                                                 "baseURL"        => get_theme_file_uri( style ),
--                                                 "__unstableType" => "theme",
--                                                 "isGlobalStyles" => false,
--                                         );
--                                 end;
--                         end;
--                 end;
--         end;

--         return styles;
-- end;

end Inc_Block_Editors;
