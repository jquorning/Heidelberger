--
-- WordPress scripts and styles default loader.
--
-- Several constants are used to manage the loading, concatenating and compression
-- of scripts and CSS:
-- define('SCRIPT_DEBUG', true); loads the development (non-minified) versions of
-- all scripts and CSS, and disables compression and concatenation,
-- define('CONCATENATE_SCRIPTS', false); disables compression and concatenation of
-- scripts and CSS,
-- define('COMPRESS_SCRIPTS', false); disables compression of scripts,
-- define('COMPRESS_CSS', false); disables compression of CSS,
-- define('ENFORCE_GZIP', true); forces gzip for compression (default is deflate).
--
-- The globals concatenate_scripts, compress_scripts and compress_css can be set by
-- plugins to temporarily override the above settings. Also a compression test is
-- run once and the result is saved as option 'can_compress_scripts' (0/1). The
-- test will run again if that option is deleted.
--
-- @package WordPress
--

with Arrays;
with Lists;

with Class_Scripts;
with Class_Styles;

package Inc_Script_Loader
is
   use Arrays;
   use Lists;

   Global_Wp_Scripts : Class_Scripts.Wp_Scripts; -- arbitrary position (jq)

   --
   -- Registers TinyMCE scripts.
   --
   -- @since 5.0.0
   --
   -- @global string tinymce_version
   -- @global bool   concatenate_scripts
   -- @global bool   compress_scripts
   --
   -- @param WP_Scripts scripts            WP_Scripts object.
   -- @param bool       force_uncompressed Whether to forcibly prevent gzip
   --                                      compression. Default false.
   --
   procedure Wp_Register_TinyMCE_Scripts
     (Scripts            : in out Class_Scripts.Wp_Scripts;
      Force_Uncompressed : Boolean := False);

   --
   -- Assigns default styles to styles object.
   --
   -- Nothing is returned, because the styles parameter is passed by reference.
   -- Meaning that whatever object is passed will be updated without having to
   -- reassign the variable that was passed back to the same value. This saves
   -- memory.
   --
   -- Adding default styles is not the only task, it also assigns the base_url
   -- property, the default version, and text direction for the object.
   --
   -- @since 2.6.0
   --
   -- @global array editor_styles
   --
   -- @param WP_Styles styles
   --
   procedure Wp_Default_Styles (Styles : in out Class_Styles.Wp_Styles);

   --
   -- Prints scripts (internal use only)
   --
   -- @ignore
   --
   -- @global WP_Scripts wp_scripts
   -- @global bool       compress_scripts
   --
   procedure X_Print_Scripts
             is null;

   --
   -- Registers all the WordPress packages scripts.
   --
   -- @since 5.0.0
   --
   -- @param WP_Scripts scripts WP_Scripts object.
   --
   procedure Wp_Default_Packages (Scripts : in out Class_Scripts.Wp_Scripts);

   --
   -- Returns the suffix that can be used for the scripts.
   --
   -- There are two suffix types, the normal one and the dev suffix.
   --
   -- @since 5.0.0
   --
   -- @param string type The type of suffix to retrieve.
   -- @return string The script suffix.
   --
   function Wp_Scripts_Get_Suffix (Typ : String := "")
                                   return String;

   --
   -- Registers all WordPress scripts.
   --
   -- Localizes some of them.
   -- args order: `scripts->add( "handle", "url", "dependencies", "query-string", 1 );`
   -- when last arg === 1 queues the script for the footer
   --
   -- @since 2.6.0
   --
   -- @param WP_Scripts scripts WP_Scripts object.
   --
   procedure Wp_Default_Scripts (Scripts : in out Class_Scripts.Wp_Scripts);

   --
   -- Registers all the WordPress vendor scripts that are in the standardized
   -- `js/dist/vendor/` location.
   --
   -- For the order of `scripts->add` see `wp_default_scripts`.
   --
   -- @since 5.0.0
   --
   -- @global WP_Locale wp_locale WordPress date and time locale object.
   --
   -- @param WP_Scripts scripts WP_Scripts object.
   --
   procedure Wp_Default_Packages_Vendor
     (Scripts : in out Class_Scripts.Wp_Scripts);

   --
   -- Registers development scripts that integrate with `@wordpress/scripts`.
   --
   -- @see https://github.com/WordPress/gutenberg/tree/trunk/packages/scripts#start
   --
   -- @since 6.0.0
   --
   -- @param WP_Scripts scripts WP_Scripts object.
   --
   procedure Wp_Register_Development_Scripts
     (Scripts : in out Class_Scripts.Wp_Scripts);

   --
   -- Registers all the WordPress packages scripts that are in the standardized
   -- `js/dist/` location.
   --
   -- For the order of `scripts->add` see `wp_default_scripts`.
   --
   -- @since 5.0.0
   --
   -- @param WP_Scripts scripts WP_Scripts object.
   --
   procedure Wp_Default_Packages_Scripts
     (Scripts : in out Class_Scripts.Wp_Scripts);

   --
   -- Adds inline scripts required for the WordPress JavaScript packages.
   --
   -- @since 5.0.0
   --
   -- @global WP_Locale wp_locale WordPress date and time locale object.
   -- @global wpdb      wpdb      WordPress database abstraction object.
   --
   -- @param WP_Scripts scripts WP_Scripts object.
   --
   procedure Wp_Default_Packages_Inline_Scripts
     (Scripts : in out Class_Scripts.Wp_Scripts);

   --
   -- Loads classic theme styles on classic themes in the frontend.
   --
   -- This is needed for backwards compatibility for button blocks specifically.
   --
   -- @since 6.1.0
   --
   procedure Wp_Enqueue_Classic_Theme_Styles;

   --
   -- Checks whether separate styles should be loaded for core blocks on-render.
   --
   -- When this function returns true, other functions ensure that core blocks
   -- only load their assets on-render, and each block loads its own, individual
   -- assets. Third-party blocks only load their assets when rendered.
   --
   -- When this function returns false, all core block assets are loaded regardless
   -- of whether they are rendered in a page or not, because they are all part of
   -- the `block-library/style.css` file. Assets for third-party blocks are always
   -- enqueued regardless of whether they are rendered or not.
   --
   -- This only affects front end and not the block editor screens.
   --
   -- @see wp_enqueue_registered_block_scripts_and_styles()
   -- @see register_block_style_handle()
   --
   -- @since 5.8.0
   --
   -- @return bool Whether separate assets will be loaded.
   --
   function Wp_Should_Load_Separate_Core_Block_Assets
            return Boolean
            is (True);

   --
   -- Wrapper for do_action( "wp_enqueue_scripts" ).
   --
   -- Allows plugins to queue scripts for the front end using wp_enqueue_script().
   -- Runs first in wp_head() where all is_home(), is_page(), etc. functions are
   -- available.
   --
   -- @since 2.8.0
   --
   procedure Wp_Enqueue_Scripts;

   --
   -- Prints the styles queue in the HTML head on admin pages.
   --
   -- @since 2.8.0
   --
   -- @global bool concatenate_scripts
   --
   -- @return array
   --
   function Print_Admin_Styles
            return List_Type;

   --
   -- Prints the styles that were queued too late for the HTML head.
   --
   -- @since 3.3.0
   --
   -- @global WP_Styles wp_styles
   -- @global bool      concatenate_scripts
   --
   -- @return array|void
   --
   function Print_Late_Styles
            return List_Type;

   --
   -- Prints styles (internal use only).
   --
   -- @ignore
   -- @since 3.3.0
   --
   -- @global bool compress_css
   --
   procedure X_Print_Styles;

   --
   -- Determines the concatenation and compression settings for scripts and styles.
   --
   -- @since 2.8.0
   --
   -- @global bool concatenate_scripts
   -- @global bool compress_scripts
   -- @global bool compress_css
   --
   procedure Script_Concat_Settings;

   --
   -- Handles the enqueueing of block scripts and styles that are common to both
   -- the editor and the front-end.
   --
   -- @since 5.0.0
   --
   procedure Wp_Common_Block_Scripts_And_Styles;

   --
   -- Applies a filter to the list of style nodes that comes from
   -- WP_Theme_JSON::get_style_nodes().
   --
   -- This particular filter removes all of the blocks from the array.
   --
   -- We want WP_Theme_JSON to be ignorant of the implementation details of how the
   -- CSS is being used. This filter allows us to modify the output of WP_Theme_JSON
   -- depending on whether or not we are loading separate assets, without making the
   -- class aware of that detail.
   --
   -- @since 6.1.0
   --
   -- @param array nodes The nodes to filter.
   -- @return array A filtered array of style nodes.
   --
   function Wp_Filter_Out_Block_Nodes (Nodes : Array_Type)
                                       return Array_Type;

   --
   -- Enqueues the global styles defined via theme.json.
   --
   -- @since 5.8.0
   --
   procedure Wp_Enqueue_Global_Styles;

   --
   -- Checks if the editor scripts and styles for all registered block types
   -- should be enqueued on the current screen.
   --
   -- @since 5.6.0
   --
   -- @global WP_Screen current_screen WordPress current screen object.
   --
   -- @return bool Whether scripts and styles should be enqueued.
   --
   function Wp_Should_Load_Block_Editor_Scripts_And_Styles
            return Boolean;

   --
   -- Allows small styles to be inlined.
   --
   -- This improves performance and sustainability, and is opt-in. Stylesheets can
   -- opt in by adding `path` data using `wp_style_add_data`, and defining the file's
   -- absolute path:
   --
   --     wp_style_add_data( style_handle, "path", file_path);
   --
   -- @since 5.8.0
   --
   -- @global WP_Styles wp_styles
   --
   procedure Wp_Maybe_Inline_Styles;

   --
   -- Makes URLs relative to the WordPress installation.
   --
   -- @since 5.9.0
   -- @access private
   --
   -- @param string css            The CSS to make URLs relative to the WordPress
   --                               installation.
   -- @param string stylesheet_url The URL to the stylesheet.
   --
   -- @return string The CSS with URLs made relative to the WordPress installation.
   --
   function X_Wp_Normalize_Relative_CSS_Links (CSS            : String;
                                               Stylesheet_URL : String)
                                               return String;

   --
   -- Fetches, processes and compiles stored core styles, then combines and renders
   -- them to the page. Styles are stored via the style engine API.
   --
   -- @link https://developer.wordpress.org/block-editor/reference-guides/packages/packages-style-engine/
   --
   -- @since 6.1.0
   --
   -- @param array options {
   --     Optional. An array of options to pass to
   --     wp_style_engine_get_stylesheet_from_context(). Default empty array.
   --
   --     @type bool optimize Whether to optimize the CSS output, e.g., combine rules.
   --                          Default is `False`.
   --     @type bool prettify Whether to add new lines and indents to output. Default
   --                          is the test of whether the global constant
   --                          `SCRIPT_DEBUG` is defined.
   -- }
   --
   -- @return void
   --
   procedure Wp_Enqueue_Stored_Styles (Options : Array_Type := Empty_Array);
   procedure Wp_Enqueue_Stored_Styles;

end Inc_Script_Loader;
