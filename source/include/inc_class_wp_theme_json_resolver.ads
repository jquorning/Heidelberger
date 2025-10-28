--
-- WP_Theme_JSON_Resolver class
--
-- @package WordPress
-- @subpackage Theme
-- @since 5.8.0
--

package Inc_Class_Wp_Theme_JSON_Resolver
is
   --
   -- Class that abstracts the processing of the different data sources
   -- for site-level config and offers an API to work with them.
   --
   -- This class is for internal core usage and is not supposed to be used by
   -- extenders (plugins and/or themes).
   -- This is a low-level API that may need to do breaking changes. Please,
   -- use get_global_settings, get_global_styles, and get_global_stylesheet instead.
   --
   -- @access private
   --
-- #[AllowDynamicProperties]
   type Wp_Theme_JSON_Resolver is tagged
      record

         --
         -- Container for keep track of registered blocks.
         --
         -- @since 6.1.0
         -- @var array
         --
         -- protected static blocks_cache = array(
         --        "core"   => array(),
         --        "blocks" => array(),
         --        "theme"  => array(),
         --        "user"   => array(),
         -- );

         --
         -- Container for data coming from core.
         --
         -- @since 5.8.0
         -- @var WP_Theme_JSON
         --
         -- protected static core = null;

         --
         -- Container for data coming from the blocks.
         --
         -- @since 6.1.0
         -- @var WP_Theme_JSON
         --
         -- protected static blocks = null;

         --
         -- Container for data coming from the theme.
         --
         -- @since 5.8.0
         -- @var WP_Theme_JSON
         --
         -- protected static theme = null;

         --
         -- Whether or not the theme supports theme.json.
         --
         -- @since 5.8.0
         -- @var bool
         --
         -- protected static
         Theme_Has_Support : Boolean := False; --  = null;

         --
         -- Container for data coming from the user.
         --
         -- @since 5.9.0
         -- @var WP_Theme_JSON
         --
         -- protected static user = null;

         --
         -- Stores the ID of the custom post type
         -- that holds the user data.
         --
         -- @since 5.9.0
         -- @var int
         --
         -- protected static user_custom_post_type_id = null;

         --
         -- Container to keep loaded i18n schema for `theme.json`.
         --
         -- @since 5.8.0 As `theme_json_i18n`.
         -- @since 5.9.0 Renamed from `theme_json_i18n` to `i18n_schema`.
         -- @var array
         --
         -- protected static i18n_schema = null;

         --
         -- `theme.json` file cache.
         --
         -- @since 6.1.0
         -- @var array
         --
         -- protected static theme_json_file_cache = array();

      end record;

   --
   -- Determines whether the active theme has a theme.json file.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added a check in the parent theme.
   --
   -- @return bool
   --
   -- public static
   function Theme_Has_Support (This : Wp_Theme_JSON_Resolver)
           return Boolean;

   --
   -- Builds the path to the given file and checks that it is readable.
   --
   -- If it isn"t, returns an empty string, otherwise returns the whole file path.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Adapted to work with child themes, added the `template` argument.
   --
   -- @param string file_name Name of the file.
   -- @param bool   template  Optional. Use template theme directory. Default false.
   -- @return string The whole file path or empty if the file doesn"t exist.
   --
   -- protected static
   function Get_File_Path_From_Theme (This      : Wp_Theme_JSON_Resolver;
                                      File_Name : String;
                                      Template  : Boolean := False)
                                      return String;

   Static : Wp_Theme_JSON_Resolver;

end Inc_Class_Wp_Theme_JSON_Resolver;
