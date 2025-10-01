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

with Inc_Class_Wp_Scripts;
with Inc_Class_Wp_Styles;

package Inc_Script_Loader
is
   procedure Dummy;

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
   procedure Wp_Default_Styles (Styles : in out Inc_Class_Wp_Styles.Wp_Styles);

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
   procedure Wp_Default_Scripts (Scripts : in out Inc_Class_Wp_Scripts.Wp_Scripts);

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
     (Scripts : in out Inc_Class_Wp_Scripts.Wp_Scripts);

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
     (Scripts : in out Inc_Class_Wp_Scripts.Wp_Scripts);

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

end Inc_Script_Loader;
