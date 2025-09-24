with Arrays;

package Inc_Themes
is
   use Arrays;

   procedure Dummy;
--
-- Gets the header images uploaded for the active theme.
--
-- @since 3.2.0
--
-- @return array
--
   function Get_Uploaded_Header_Images
      return Array_Type is (Empty_Array);

--
-- Checks if random header image is in use.
--
-- Always true if user expressly chooses the option in Appearance > Header.
-- Also true if theme has multiple header images registered, no specific header image
-- is chosen, and theme turns on random headers with add_theme_support().
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
-- Checks whether a header video is set or not.
--
-- @since 4.7.0
--
-- @see get_header_video_url()
--
-- @return bool Whether a header video is set or not.
--
   function Has_Header_Video
            return Boolean
            is (False);

--
-- Checks a theme"s support for a given feature.
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
-- @param string feature The feature being checked. See add_theme_support() for the list
--                        of possible values.
-- @param mixed  ...args Optional extra arguments to be checked against certain features.
-- @return bool True if the active theme supports the feature, false otherwise.
--
-- function current_theme_supports( feature, ...args ) then
   function Current_Theme_Supports (Feature : String;
                                    Arg_2   : String := "")
--                                   , ...args )
                                    return Boolean
                                    is (True);


--
-- Retrieves all theme modifications.
--
-- @since 3.1.0
-- @since 5.9.0 The return value is always an array.
--
-- @return array Theme modifications.
--
   function Get_Theme_Mods
            return Array_Type is (Empty_Array);

--
-- Retrieves theme modification value for the active theme.
--
-- If the modification name does not exist and `default` is a string, then the
-- default will be passed through the then@link https://www.php.net/sprintf sprintf()end;
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
                           return Integer is (1);

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
            return Boolean
            is (True);

--
-- Retrieves header image for custom header.
--
-- @since 2.1.0
--
-- @return string|false
--
   function Get_Header_Image
            return String
            is ("XXX-211");

--
-- Retrieves background image for custom background.
--
-- @since 3.0.0
--
-- @return string
--
   function Get_Background_Image
            return String
            is ("XXX-210");

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
--                        of possible values.
-- @param mixed  ...args Optional extra arguments to be checked against certain features.
-- @return mixed The array of extra arguments or the value for the registered feature.
--
-- function get_theme_support( feature, ...args ) then
   function Get_Theme_Support (Feature : String;
                               T       : String := "")
                               return String_Array
                               is (Empty_String_Array);

--
-- Whether the site is being previewed in the Customizer.
--
-- @since 4.0.0
--
-- @global WP_Customize_Manager wp_customize Customizer instance.
--
-- @return bool True if the site is being previewed in the Customizer, false otherwise.
--
   function Is_Customize_Preview
            return Boolean
            is (True);

--
-- Returns a URL to load the Customizer.
--
-- @since 3.4.0
--
-- @param string stylesheet Optional. Theme to customize. Defaults to active theme.
--                           The theme"s stylesheet will be urlencoded if necessary.
-- @return string
--
   function Wp_Customize_Url (Stylesheet : String := "")
                              return String
                              is ("XXX-353");

--
-- Returns whether the active theme is a block-based theme or not.
--
-- @since 5.9.0
--
-- @return boolean Whether the active theme is a block-based theme or not.
--
   function Wp_Is_Block_Theme
            return Boolean
            is (True);

end Inc_Themes;
