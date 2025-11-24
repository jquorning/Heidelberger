--
-- WP_Theme_JSON_Resolver class
--
-- @package WordPress
-- @subpackage Theme
-- @since 5.8.0
--

with Arrays;

with Inc_Class_Wp_Themes;
with Inc_Class_Wp_Theme_JSON;

package Inc_Class_Wp_Theme_JSON_Resolver
is
   use Arrays;

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
         -- Static_Theme_Has_Support : Boolean := False; --  = null;

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

         null;
      end record;

   --
   -- Container for keep track of registered blocks.
   --
   -- @since 6.1.0
   -- @var array
   --
   -- protected static
   Static_Blocks_Cache : Array_Type := To_Array (List => (
     Build ("core",   Empty_Array),
     Build ("blocks", Empty_Array),
     Build ("theme",  Empty_Array),
     Build ("user",   Empty_Array)
   ));

   --
   -- Container for data coming from core.
   --
   -- @since 5.8.0
   -- @var WP_Theme_JSON
   --
   -- protected
   Static_Core : Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON :=
     Inc_Class_Wp_Theme_JSON.Null_Theme_JSON; -- = null;

   --
   -- Container for data coming from the blocks.
   --
   -- @since 6.1.0
   -- @var WP_Theme_JSON
   --
   -- protected static
   Static_Blocks : Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON :=
     Inc_Class_Wp_Theme_JSON.Null_Theme_JSON;

   --
   -- Whether or not the theme supports theme.json.
   --
   -- @since 5.8.0
   -- @var bool
   --
   -- protected static
   Static_Theme_Has_Support : Boolean := False; --  = null;

   --
   -- Container for data coming from the user.
   --
   -- @since 5.9.0
   -- @var WP_Theme_JSON
   --
   -- protected static
   Static_User : Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON :=
     Inc_Class_Wp_Theme_JSON.Null_Theme_JSON;

   --
   -- Container for data coming from the theme.
   --
   -- @since 5.8.0
   -- @var WP_Theme_JSON
   --
   -- protected
   Static_Theme : Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON :=
     Inc_Class_Wp_Theme_JSON.Null_Theme_JSON;

   --
   -- Container to keep loaded i18n schema for `theme.json`.
   --
   -- @since 5.8.0 As `theme_json_i18n`.
   -- @since 5.9.0 Renamed from `theme_json_i18n` to `i18n_schema`.
   -- @var array
   --
   -- protected
   Static_I18n_Schema : Array_Type := Empty_Array; -- null;

   --
   -- `theme.json` file cache.
   --
   -- @since 6.1.0
   -- @var array
   --
   -- protected
   Static_Theme_JSON_File_Cache : Array_Type;

   --
   -- Processes a file that adheres to the theme.json schema
   -- and returns an array with its contents, or a void array if none found.
   --
   -- @since 5.8.0
   -- @since 6.1.0 Added caching.
   --
   -- @param string file_path Path to file. Empty if no file.
   -- @return array Contents that adhere to the theme.json schema.
   --
   -- protected static
   function Read_JSON_File (File_Path : String)
                            return Array_Type;

   --
   -- Given a theme.json structure modifies it in place to update certain values
   -- by its translated strings according to the language set by the user.
   --
   -- @since 5.8.0
   --
   -- @param array  theme_json The theme.json to translate.
   -- @param string domain     Optional. Text domain. Unique identifier for retrieving
   --                           translated strings. Default "default".
   -- @return array Returns the modified theme_json_structure.
   --
   -- protected static
   function Translate (Theme_JSON : Array_Type;
                       Domain     : String := "default")
                       return Array_Type;

   --
   -- Returns core's origin config.
   --
   -- @since 5.8.0
   --
   -- @return WP_Theme_JSON Entity that holds core data.
   --
   -- public static
   function Get_Core_Data
            return Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON;

   --
   -- Returns the theme's data.
   --
   -- Data from theme.json will be backfilled from existing
   -- theme supports, if any. Note that if the same data
   -- is present in theme.json and in theme supports,
   -- the theme.json takes precedence.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Theme supports have been inlined and the `theme_support_data`
   --              argument removed.
   -- @since 6.0.0 Added an `options` parameter to allow the theme data to be returned
   --              without theme supports.
   --
   -- @param array deprecated Deprecated. Not used.
   -- @param array options {
   --     Options arguments.
   --
   --     @type bool with_supports Whether to include theme supports in the data.
   --                              Default true.
   -- }
   -- @return WP_Theme_JSON Entity that holds theme data.
   --
   -- public static
   function Get_Theme_Data (Deprecated : Array_Type := Empty_Array;
                            Options    : Array_Type := Empty_Array)
                            return Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON;

   --
   -- Gets the styles for blocks from the block.json file.
   --
   -- @since 6.1.0
   --
   -- @return WP_Theme_JSON
   --
   -- public static
   function Get_Block_Data
            return Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON;

   --
   -- When given an array, this will remove any keys with the name `//`.
   --
   -- @param array array The array to filter.
   -- @return array The filtered array.
   --
   -- private static
   function Remove_JSON_Comments (Arry : Array_Type)
                                  return Array_Type;

   --
   -- Returns the custom post type that contains the user's origin config
   -- for the active theme or a void array if none are found.
   --
   -- This can also create and return a new draft custom post type.
   --
   -- @since 5.9.0
   --
   -- @param WP_Theme theme              The theme object. If empty, it
   --                                     defaults to the active theme.
   -- @param bool     create_post        Optional. Whether a new custom post
   --                                     type should be created if none are
   --                                     found. Default false.
   -- @param array    post_status_filter Optional. Filter custom post type by
   --                                     post status. Default `array( "publish" )`,
   --                                     so it only fetches published posts.
   -- @return array Custom Post Type for the user"s origin config.
   --
   -- public static
   function Get_User_Data_From_Wp_Global_Styles
     (Theme              : Inc_Class_Wp_Themes.Wp_Theme;
      Create_Post        : Boolean   := False;
      Post_Status_Filter : List_Type := To_List ("publish"))
      return Array_Type;

   --
   -- Checks whether the registered blocks were already processed for this origin.
   --
   -- @since 6.1.0
   --
   -- @param string origin Data source for which to cache the blocks.
   --                       Valid values are "core", "blocks", "theme", and "user".
   -- @return bool True on success, false otherwise.
   --
   -- protected static
   function Has_Same_Registered_Blocks (Origin : String)
                                        return Boolean;

   --
   -- Returns the user"s origin config.
   --
   -- @since 5.9.0
   --
   -- @return WP_Theme_JSON Entity that holds styles for user data.
   --
   -- public static
   function Get_User_Data
            return Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON;

   --
   -- Returns the data merged from multiple origins.
   --
   -- There are three sources of data (origins) for a site:
   -- default, theme, and custom. The custom"s has higher priority
   -- than the theme"s, and the theme"s higher than default"s.
   --
   -- Unlike the getters
   -- {@link https://developer.wordpress.org/reference/classes/wp_theme_json_resolver/get_core_data/ get_core_data},
   -- {@link https://developer.wordpress.org/reference/classes/wp_theme_json_resolver/get_theme_data/ get_theme_data},
   -- and {@link https://developer.wordpress.org/reference/classes/wp_theme_json_resolver/get_user_data/ get_user_data},
   -- this method returns data after it has been merged with the previous origins.
   -- This means that if the same piece of data is declared in different origins
   -- (user, theme, and core), the last origin overrides the previous.
   --
   -- For example, if the user has set a background color
   -- for the paragraph block, and the theme has done it as well,
   -- the user preference wins.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added user data, removed the `settings` parameter,
   --              added the `origin` parameter.
   -- @since 6.1.0 Added block data and generation of spacingSizes array.
   --
   -- @param string origin Optional. To what level should we merge data.
   --                       Valid values are "theme" or "custom". Default "custom".
   -- @return WP_Theme_JSON
   --
   -- public static
   function Get_Merged_Data (Origin : String := "custom")
                             return Inc_Class_Wp_Theme_JSON.Wp_Theme_JSON;

   --
   -- Determines whether the active theme has a theme.json file.
   --
   -- @since 5.8.0
   -- @since 5.9.0 Added a check in the parent theme.
   --
   -- @return bool
   --
   -- public static
   function Theme_Has_Support
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
   function Get_File_Path_From_Theme (File_Name : String;
                                      Template  : Boolean := False)
                                      return String;

-- Static : Wp_Theme_JSON_Resolver;

end Inc_Class_Wp_Theme_JSON_Resolver;
