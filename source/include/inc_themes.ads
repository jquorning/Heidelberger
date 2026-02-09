--
-- Theme, template, and stylesheet functions.
--
-- @package WordPress
-- @subpackage Theme
--

with Arrays;
with Helpers_2;
with Lists;

with Class_Posts;
with Class_Themes;
with Inc_Options;

package Inc_Themes
is
   use Arrays;
   use Lists;

--   package String_Maps is new
--      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
--                                              Element_Type => String);

   Wp_Theme_Directories : List_Type;

   --
   -- Gets a WP_Theme object for a theme.
   --
   -- @since 3.4.0
   --
   -- @global array wp_theme_directories
   --
   -- @param string stylesheet Optional. Directory name for the theme. Defaults to
   --                           active theme.
   -- @param string theme_root Optional. Absolute path of the theme root to look in.
   --                           If not specified, get_raw_theme_root() is used to
   --                           calculate the theme root for the stylesheet provided
   --                           (or active theme).
   -- @return WP_Theme Theme object. Be sure to check the object"s exists() method
   --                  if you need to confirm the theme"s existence.
   --
   function Wp_Get_Theme (Stylesheet : String := "";
                          Theme_Root : String := "")
                          return Class_Themes.Wp_Theme;

   --
   -- Gets the header images uploaded for the active theme.
   --
   -- @since 3.2.0
   --
   -- @return array
   --
   function Get_Uploaded_Header_Images
      return Array_Type
      is (Empty_Array);

   --
   -- Checks if random header image is in use.
   --
   -- Always true if user expressly chooses the option in Appearance > Header.
   -- Also true if theme has multiple header images registered, no specific header
   -- image is chosen, and theme turns on random headers with add_theme_support().
   --
   -- @since 3.2.0
   --
   -- @param string type The random pool to use. Possible values include "any",
   --                     "default", "uploaded". Default "any".
   -- @return bool
   --
   function Is_Random_Header_Image (typ : String := "any")
                                    return Boolean
                                    is (False);

   --
   -- Searches all registered theme directories for complete and valid themes.
   --
   -- @since 2.9.0
   --
   -- @global array wp_theme_directories
   --
   -- @param bool force Optional. Whether to force a new directory scan. Default false.
   -- @return array|false Valid themes found on success, false on failure.
   --
   function Search_Theme_Directories (Force : Boolean := False)
                                      return Array_Type
                                      is (Empty_Array);

   --
   -- Retrieves theme roots.
   --
   -- @since 2.9.0
   --
   -- @global array wp_theme_directories
   --
   -- @return array|string An array of theme roots keyed by template/stylesheet
   --                      or a single theme root if all themes have the same root.
   --
   function Get_Theme_Roots
            return Inc_Options.String_Maps.Map;

   --
   -- Registers a directory that contains themes.
   --
   -- @since 2.9.0
   --
   -- @global array wp_theme_directories
   --
   -- @param string directory Either the full filesystem path to a theme folder
   --                          or a folder within WP_CONTENT_DIR.
   -- @return bool True if successfully registered a directory that contains themes,
   --              false if the directory does not exist.
   --
   function Register_Theme_Directory (Directory : String)
                                      return Boolean;

   --
   -- Retrieves name of the current stylesheet.
   --
   -- The theme name that is currently set as the front end theme.
   --
   -- For all intents and purposes, the template name and the stylesheet name
   -- are going to be the same for most cases.
   --
   -- @since 1.5.0
   --
   -- @return string Stylesheet name.
   --
   function Get_Stylesheet
            return String;

   --
   -- Retrieves stylesheet directory path for the active theme.
   --
   -- @since 1.5.0
   --
   -- @return string Path to active theme"s stylesheet directory.
   --
   function Get_Stylesheet_Directory
            return String;

   --
   -- Retrieves stylesheet directory URI for the active theme.
   --
   -- @since 1.5.0
   --
   -- @return string URI to active theme"s stylesheet directory.
   --
   function Get_Stylesheet_Directory_URI
            return String;

   --
   -- Retrieves the localized stylesheet URI.
   --
   -- The stylesheet directory for the localized stylesheet files are located, by
   -- default, in the base theme directory. The name of the locale file will be the
   -- locale followed by ".css". If that does not exist, then the text direction
   -- stylesheet will be checked for existence, for example "ltr.css".
   --
   -- The theme may change the location of the stylesheet directory by either using
   -- the {@see "stylesheet_directory_uri"} or {@see "locale_stylesheet_uri"} filters.
   --
   -- If you want to change the location of the stylesheet files for the entire
   -- WordPress workflow, then change the former. If you just have the locale in a
   -- separate folder, then change the latter.
   --
   -- @since 2.1.0
   --
   -- @global WP_Locale wp_locale WordPress date and time locale object.
   --
   -- @return string URI to active theme"s localized stylesheet.
   --
   function Get_Locale_Stylesheet_URI
            return String;

   --
   -- Retrieves name of the active theme.
   --
   -- @since 1.5.0
   --
   -- @return string Template name.
   --
   function Get_Template
            return String;

   --
   -- Retrieves template directory path for the active theme.
   --
   -- @since 1.5.0
   --
   -- @return string Path to active theme"s template directory.
   --
   function Get_Template_Directory
            return String;

   --
   -- Retrieves template directory URI for the active theme.
   --
   -- @since 1.5.0
   --
   -- @return string URI to active theme"s template directory.
   --
   function Get_Template_Directory_URI
            return String;

   --
   -- Retrieves path to themes directory.
   --
   -- Does not have trailing slash.
   --
   -- @since 1.5.0
   --
   -- @global array wp_theme_directories
   --
   -- @param string stylesheet_or_template Optional. The stylesheet or template name
   --                                      of the theme. Default is to leverage the
   --                                      main theme root.
   -- @return string Themes directory path.
   --
   function Get_Theme_Root (Stylesheet_Or_Template : String := "")
                            return String;

   --
   -- Retrieves URI for themes directory.
   --
   -- Does not have trailing slash.
   --
   -- @since 1.5.0
   --
   -- @global array wp_theme_directories
   --
   -- @param string stylesheet_or_template Optional. The stylesheet or template name
   --                                      of the theme. Default is to leverage the
   --                                      main theme root.
   -- @param string theme_root             Optional. The theme root for which
   --                                      calculations will be based, preventing the
   --                                      need for a get_raw_theme_root() call.
   --                                      Default empty.
   -- @return string Themes directory URI.
   --
   function Get_Theme_Root_URI (Stylesheet_Or_Template : String := "";
                                Theme_Root             : String := "")
                                return String;

   --
   -- Gets the raw theme root relative to the content directory with no filters
   --  applied.
   --
   -- @since 3.1.0
   --
   -- @global array wp_theme_directories
   --
   -- @param string stylesheet_or_template The stylesheet or template name of the
   --                                      theme.
   -- @param bool   skip_cache             Optional. Whether to skip the cache.
   --                                      Defaults to false, meaning the cache is
   --                                      used.
   -- @return string Theme root.
   --
   function Get_Raw_Theme_Root (Stylesheet_Or_Template : String;
                                Skip_Cache             : Boolean := False)
                                return String;

   --
   -- Displays localized stylesheet link element.
   --
   -- @since 2.1.0
   --
   procedure Locale_Stylesheet;

   function Locale_Stylesheet
     is new Helpers_2.Generic_Call_Procedure (Locale_Stylesheet);

   --
   -- Checks whether a header video is set or not.
   --
   -- @since 4.7.0
   --
   -- @see get_header_video_url()
   --
   -- @return bool Whether a header video is set or not.
   --
   function Has_Header_Video
            return Boolean;

   --
   -- Retrieves header video URL for custom header.
   --
   -- Uses a local video if present, or falls back to an external video.
   --
   -- @since 4.7.0
   --
   -- @return string|false Header video URL or false if there is no video.
   --
   function Get_Header_Video_URL
            return String;

   --
   -- Checks a theme's support for a given feature.
   --
   -- Example usage:
   --
   --     current_theme_supports( "custom-logo" );
   --     current_theme_supports( "html5", "comment-form" );
   --
   -- @since 2.9.0
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   --
   -- @global array _wp_theme_features
   --
   -- @param string feature The feature being checked. See add_theme_support() for
   --                       the list of possible values.
   -- @param mixed  ...args Optional extra arguments to be checked against certain
   --                       features.
   -- @return bool True if the active theme supports the feature, false otherwise.
   --
   function Current_Theme_Supports (Feature : String;
                                    Arg_2   : String := "")
                                    return Boolean;

   --
   -- Retrieves all theme modifications.
   --
   -- @since 3.1.0
   -- @since 5.9.0 The return value is always an array.
   --
   -- @return array Theme modifications.
   --
   function Get_Theme_Mods
            return Array_Type
            is (Empty_Array);

   --
   -- Renders the Custom CSS style element.
   --
   -- @since 4.7.0
   --
   procedure Wp_Custom_CSS_CB;

   function Wp_Custom_CSS_CB
     is new Helpers_2.Generic_Call_Procedure (Wp_Custom_CSS_CB);

   --
   -- Fetches the `custom_css` post for a given theme.
   --
   -- @since 4.7.0
   --
   -- @param string stylesheet Optional. A theme object stylesheet name. Defaults
   --                          to the active theme.
   -- @return WP_Post|null The custom_css post or null if none exists.
   --
   function Wp_Get_Custom_CSS_Post (Stylesheet : String := "")
                                    return Class_Posts.Wp_Post;

   --
   -- Fetches the saved Custom CSS content for rendering.
   --
   -- @since 4.7.0
   --
   -- @param string stylesheet Optional. A theme object stylesheet name. Defaults
   --                          to the active theme.
   -- @return string The Custom CSS Post content.
   --
   function Wp_Get_Custom_CSS (Stylesheet : String := "")
                               return String;

   --
   -- Retrieves theme modification value for the active theme.
   --
   -- If the modification name does not exist and `default` is a string, then the
   -- default will be passed through the {@link https://www.php.net/sprintf sprintf()}
   -- PHP function with the template directory URI as the first value and the
   -- stylesheet directory URI as the second value.
   --
   -- @since 2.1.0
   --
   -- @param string name    Theme modification name.
   -- @param mixed  default Optional. Theme modification default value. Default false.
   -- @return mixed Theme modification value.
   --
   function Get_Theme_Mod (Name    : String;
                           Default : Boolean := False)
                           return Integer
                           is (1);

   function Get_Theme_Mod (Name    : String;
                           Default : Boolean := False)
                           return Array_Type
                           is (Empty_Array);

   function Get_Theme_Mod (Name    : String;
                           Default : String := "")
                           return String
                           is ("XXX-023");

   --
   -- Updates theme modification value for the active theme.
   --
   -- @since 2.1.0
   -- @since 5.6.0 A return value was added.
   --
   -- @param string name  Theme modification name.
   -- @param mixed  value Theme modification value.
   -- @return bool True if the value was updated, false otherwise.
   --
   function Set_Theme_Mod (Name  : String;
                           Value : Array_Type)
                           return Boolean
                           is (False);

   procedure Set_Theme_Mod (Name  : String;
                            Value : Integer)
                            is null;

   --
   -- Checks whether a header image is set or not.
   --
   -- @since 4.2.0
   --
   -- @see get_header_image()
   --
   -- @return bool Whether a header image is set or not.
   --
   function Has_Header_Image
            return Boolean;

   --
   -- Retrieves header image for custom header.
   --
   -- @since 2.1.0
   --
   -- @return string|false
   --
   function Get_Header_Image
            return String;

   --
   -- Gets random header image data from registered images in theme.
   --
   -- @since 3.4.0
   --
   -- @access private
   --
   -- @global array _wp_default_headers
   --
   -- @return object
   --
   function X_Get_Random_Header_Data
            return Duration;

   --
   -- Gets random header image URL from registered images in theme.
   --
   -- @since 3.2.0
   --
   -- @return string Path to header image.
   --
   function Get_Random_Header_Image
            return String;

   --
   -- Retrieves background image for custom background.
   --
   -- @since 3.0.0
   --
   -- @return string
   --
   function Get_Background_Image
            return String;

   --
   -- Gets the theme support arguments passed when registering that support.
   --
   -- Example usage:
   --
   --     get_theme_support( "custom-logo" );
   --     get_theme_support( "custom-header", "width" );
   --
   -- @since 3.1.0
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   --
   -- @global array _wp_theme_features
   --
   -- @param string feature The feature to check. See add_theme_support() for the list
   --                       of possible values.
   -- @param mixed  ...args Optional extra arguments to be checked against certain
   --                       features.
   -- @return mixed The array of extra arguments or the value for the registered
   --               feature.
   --
   -- function get_theme_support( feature, ...args ) then
   function Get_Theme_Support (Feature : String;
                               T       : String := "")
                               return List_Type;

   function Get_Theme_Support (Feature : String;
                               T       : String := "")
                               return Boolean;

   function Get_Theme_Support (Feature : String;
                               T       : String := "")
                               return String;

   --
   -- Whether the site is being previewed in the Customizer.
   --
   -- @since 4.0.0
   --
   -- @global WP_Customize_Manager wp_customize Customizer instance.
   --
   -- @return bool True if the site is being previewed in the Customizer, false
   --              otherwise.
   --
   function Is_Customize_Preview
            return Boolean;

   --
   -- Returns a URL to load the Customizer.
   --
   -- @since 3.4.0
   --
   -- @param string stylesheet Optional. Theme to customize. Defaults to active theme.
   --                           The theme"s stylesheet will be urlencoded if necessary.
   -- @return string
   --
   function Wp_Customize_URL (Stylesheet : String := "")
                              return String;

   --
   -- Prints a script to check whether or not the Customizer is supported,
   -- and apply either the no-customize-support or customize-support class
   -- to the body.
   --
   -- This function MUST be called inside the body tag.
   --
   -- Ideally, call this function immediately after the body tag is opened.
   -- This prevents a flash of unstyled content.
   --
   -- It is also recommended that you add the "no-customize-support" class
   -- to the body tag by default.
   --
   -- @since 3.4.0
   -- @since 4.7.0 Support for IE8 and below is explicitly removed via conditional
   --              comments.
   -- @since 5.5.0 IE8 and older are no longer supported.
   --
   procedure Wp_Customize_Support_Script;

   function Wp_Customize_Support_Script
     is new Helpers_2.Generic_Call_Procedure (Wp_Customize_Support_Script);

   --
   -- Returns whether the active theme is a block-based theme or not.
   --
   -- @since 5.9.0
   --
   -- @return boolean Whether the active theme is a block-based theme or not.
   --
   function Wp_Is_Block_Theme
            return Boolean;

   --
   -- Registers a theme feature for use in add_theme_support().
   --
   -- This does not indicate that the active theme supports the feature, it only
   -- describes the feature's supported options.
   --
   -- @since 5.5.0
   --
   -- @see add_theme_support()
   --
   -- @global array _wp_registered_theme_features
   --
   -- @param string feature The name uniquely identifying the feature. See
   --                        add_theme_support() for the list of possible values.
   -- @param array  args {
   --     Data used to describe the theme.
   --
   --     @type string     type         The type of data associated with this feature.
   --                                    Valid values are "string", "boolean",
   --                                    "integer", "number", "array", and "object".
   --                                    Defaults to "boolean".
   --     @type bool       variadic     Does this feature utilize the variadic support
   --                                    of add_theme_support(), or are all arguments
   --                                    specified as the second parameter. Must be
   --                                    used with the "array" type.
   --     @type string     description  A short description of the feature. Included in
   --                                    the Themes REST API schema. Intended for
   --                                    developers.
   --     @type bool|array show_in_rest {
   --         Whether this feature should be included in the Themes REST API endpoint.
   --         Defaults to not being included. When registering an "array" or "object"
   --         type, this argument must be an array with the "schema" key.
   --
   --         @type array    schema           Specifies the JSON Schema definition
   --                                          describing the feature. If any objects
   --                                          in the schema do not include the
   --                                          "additionalProperties" keyword, it is
   --                                          set to false.
   --         @type string   name             An alternate name to be used as the
   --                                          property name in the REST API.
   --         @type callable prepare_callback A function used to format the theme
   --                                          support in the REST API. Receives the
   --                                          raw theme support value.
   --      }
   -- }
   -- @return true|WP_Error True if the theme feature was successfully registered,
   --                        a WP_Error object if not.
   --
   Feature_Error : exception;

   procedure Register_Theme_Feature (Feature : String;
                                     Args    : Array_Type);

   --
   -- Includes and instantiates the WP_Customize_Manager class.
   --
   -- Loads the Customizer at plugins_loaded when accessing the customize.php admin
   -- page or when any request includes a wp_customize=on param or a
   -- customize_changeset param (a UUID). This param is a signal for whether to
   -- bootstrap the Customizer when WordPress is loading, especially in the Customizer
   -- preview or when making Customizer Ajax requests for widgets or menus.
   --
   -- @since 3.4.0
   --
   -- @global WP_Customize_Manager wp_customize
   --
   procedure X_Wp_Customize_Include;

   function X_Wp_Customize_Include
     is new Helpers_2.Generic_Call_Procedure (X_Wp_Customize_Include);

   --
   -- Registers theme support for a given feature.
   --
   -- Must be called in the theme"s functions.php file to work.
   -- If attached to a hook, it must be {@see "after_setup_theme"}.
   -- The {@see "init"} hook may be too late for some features.
   --
   -- Example usage:
   --
   --     add_theme_support( "title-tag" );
   --     add_theme_support( "custom-logo", array(
   --         "height" => 480,
   --         "width"  => 720,
   --     ) );
   --
   -- @since 2.9.0
   -- @since 3.4.0 The `custom-header-uploads` feature was deprecated.
   -- @since 3.6.0 The `html5` feature was added.
   -- @since 3.6.1 The `html5` feature requires an array of types to be passed.
   --               Defaults to "comment-list", "comment-form", "search-form" for
   --               backward compatibility.
   -- @since 3.9.0 The `html5` feature now also accepts "gallery" and "caption".
   -- @since 4.1.0 The `title-tag` feature was added.
   -- @since 4.5.0 The `customize-selective-refresh-widgets` feature was added.
   -- @since 4.7.0 The `starter-content` feature was added.
   -- @since 5.0.0 The `responsive-embeds`, `align-wide`, `dark-editor-style`,
   --               `disable-custom-colors`, `disable-custom-font-sizes`,
   --               `editor-color-palette`, `editor-font-sizes`, `editor-styles`, and
   --               `wp-block-styles` features were added.
   -- @since 5.3.0 The `html5` feature now also accepts "script" and "style".
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   -- @since 5.5.0 The `core-block-patterns` feature was added and is enabled by
   --               default.
   -- @since 5.5.0 The `custom-logo` feature now also accepts "unlink-homepage-logo".
   -- @since 5.6.0 The `post-formats` feature warns if no array is passed as the
   --               second parameter.
   -- @since 5.8.0 The `widgets-block-editor` feature enables the Widgets block editor.
   -- @since 6.0.0 The `html5` feature warns if no array is passed as the second
   --               parameter.
   --
   -- @global array _wp_theme_features
   --
   -- @param string feature The feature being added. Likely core values include:
   --                          - "admin-bar"
   --                          - "align-wide"
   --                          - "automatic-feed-links"
   --                          - "core-block-patterns"
   --                          - "custom-background"
   --                          - "custom-header"
   --                          - "custom-line-height"
   --                          - "custom-logo"
   --                          - "customize-selective-refresh-widgets"
   --                          - "custom-spacing"
   --                          - "custom-units"
   --                          - "dark-editor-style"
   --                          - "disable-custom-colors"
   --                          - "disable-custom-font-sizes"
   --                          - "editor-color-palette"
   --                          - "editor-gradient-presets"
   --                          - "editor-font-sizes"
   --                          - "editor-styles"
   --                          - "featured-content"
   --                          - "html5"
   --                          - "menus"
   --                          - "post-formats"
   --                          - "post-thumbnails"
   --                          - "responsive-embeds"
   --                          - "starter-content"
   --                          - "title-tag"
   --                          - "wp-block-styles"
   --                          - "widgets"
   --                          - "widgets-block-editor"
   -- @param mixed  ...args Optional extra arguments to pass along with certain
   --                        features.
   -- @return void|false Void on success, false on failure.
   --
   Support_Error : exception;

   procedure Add_Theme_Support (Feature : String;
                                List    : List_Type  := Empty_List;
                                Arry    : Array_Type := Empty_Array); -- ...args

   --
   -- Adds CSS to hide header text for custom logo, based on Customizer setting.
   --
   -- @since 4.5.0
   -- @access private
   --
   procedure X_Custom_Logo_Header_Styles;

   function X_Custom_Logo_Header_Styles
     is new Helpers_2.Generic_Call_Procedure (X_Custom_Logo_Header_Styles);

   --
   -- Creates the initial theme features when the "setup_theme" action is fired.
   --
   -- See {@see "setup_theme"}.
   --
   -- @since 5.5.0
   -- @since 6.0.1 The `block-templates` feature was added.
   --
   procedure Create_Initial_Theme_Features;

   function Create_Initial_Theme_Features
     is new Helpers_2.Generic_Call_Procedure (Create_Initial_Theme_Features);

   --
   -- Adds default theme supports for block themes when the "setup_theme" action fires.
   --
   -- See {@see "setup_theme"}.
   --
   -- @since 5.9.0
   -- @access private
   --
   procedure X_Add_Default_Theme_Supports;

   function X_Add_Default_Theme_Supports
     is new Helpers_2.Generic_Call_Procedure (X_Add_Default_Theme_Supports);

end Inc_Themes;
