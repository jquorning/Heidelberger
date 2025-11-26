--
-- Dependencies API: Styles functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Arrays;

with Inc_Class_Wp_Styles;

package Inc_Functions_Wp_Styles
is
   use Arrays;
   use Inc_Class_Wp_Styles;

   --
   -- Initialize wp_styles if it has not been set.
   --
   -- @global WP_Styles wp_styles
   --
   -- @since 4.2.0
   --
   -- @return WP_Styles WP_Styles instance.
   --
   function Wp_Styles_X
            return Wp_Styles;

   --
   -- Add extra CSS styles to a registered stylesheet.
   --
   -- Styles will only be added if the stylesheet is already in the queue.
   -- Accepts a string data containing the CSS. If two or more CSS code blocks
   -- are added to the same stylesheet handle, they will be printed in the order
   -- they were added, i.e. the latter added styles can redeclare the previous.
   --
   -- @see WP_Styles::add_inline_style()
   --
   -- @since 3.3.0
   --
   -- @param string handle Name of the stylesheet to add the extra styles to.
   -- @param string data   String containing the CSS styles to be added.
   -- @return bool True on success, false on failure.
   --
   function Wp_Add_Inline_Style (Handle : String;
                                 Data   : String)
                                 return Boolean;

   procedure Wp_Add_Inline_Style (Handle : String;
                                  Data   : String);

   --
   -- Register a CSS stylesheet.
   --
   -- @see WP_Dependencies::add()
   -- @link https://www.w3.org/TR/CSS2/media.html#media-types List of CSS media types.
   --
   -- @since 2.6.0
   -- @since 4.3.0 A return value was added.
   --
   -- @param string           handle Name of the stylesheet. Should be unique.
   -- @param string|false     src    Full URL of the stylesheet, or path of the
   --                                stylesheet relative to the WordPress root
   --                                directory. If source is set to false, stylesheet
   --                                is an alias of other stylesheets it depends on.
   -- @param string[]         deps   Optional. An array of registered stylesheet
   --                                handles this stylesheet depends on. Default empty
   --                                array.
   -- @param string|bool|null ver    Optional. String specifying stylesheet version
   --                                number, if it has one, which is added to the URL
   --                                as a query string for cache busting purposes. If
   --                                version is set to false, a version number is
   --                                automatically added equal to current installed
   --                                WordPress version. If set to null, no version is
   --                                added.
   -- @param string           media  Optional. The media for which this stylesheet has
   --                                been defined. Default 'all'. Accepts media types
   --                                like 'all', 'print' and 'screen', or media
   --                                queries like '(orientation: portrait)' and
   --                                '(max-width: 640px)'.
   -- @return bool Whether the style has been registered. True on success, false on
   --              failure.
   --
   function Wp_Register_Style (Handle : String;
                               Src    : String;
                               Deps   : List_Type := Empty_List;
                               -- Array_Type := Empty_Array;
                               Ver    : String    := ""; -- Boolean    := False;
                               Media  : String    := "all")
                               return Boolean;

   procedure Wp_Register_Style (Handle : String;
                                Src    : Boolean;
                                Deps   : List_Type := Empty_List;
                                Ver    : Boolean   := False;
                                Media  : Boolean   := False);

   --
   -- Enqueue a CSS stylesheet.
   --
   -- Registers the style if source provided (does NOT overwrite) and enqueues.
   --
   -- @see WP_Dependencies::add()
   -- @see WP_Dependencies::enqueue()
   -- @link https://www.w3.org/TR/CSS2/media.html#media-types List of CSS media types.
   --
   -- @since 2.6.0
   --
   -- @param string           handle Name of the stylesheet. Should be unique.
   -- @param string           src    Full URL of the stylesheet, or path of the
   --                                stylesheet relative to the WordPress root
   --                                directory. Default empty.
   -- @param string[]         deps   Optional. An array of registered stylesheet
   --                                handles this stylesheet depends on. Default
   --                                empty array.
   -- @param string|bool|null ver    Optional. String specifying stylesheet version
   --                                number, if it has one, which is added to the URL
   --                                as a query string for cache busting purposes. If
   --                                version is set to false, a version number is
   --                                automatically added equal to current installed
   --                                WordPress version. If set to null, no version is
   --                                added.
   -- @param string           media  Optional. The media for which this stylesheet has
   --                                been defined. Default 'all'. Accepts media types
   --                                like 'all', 'print' and 'screen', or media
   --                                queries like '(orientation: portrait)' and
   --                                '(max-width: 640px)'.
   --
   -- function wp_enqueue_style( handle, src = '', deps = array(), ver = false, media = 'all' ) then
   procedure Wp_Enqueue_Style (Handle : String;
                               Src    : String    := "";
                               Deps   : List_Type := Empty_List;
                               -- String_Array := Empty_String_Array;
                               Ver    : String    := ""; -- Boolean      := False;
                               Media  : String    := "all");

end Inc_Functions_Wp_Styles;
