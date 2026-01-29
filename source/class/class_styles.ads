--
-- Dependencies API: WP_Styles class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Lists;
with UStrings;

with Class_Dependencies;

package Class_Styles
is
   use Lists;

   --
   -- Core class used to register styles.
   --
   -- @since 2.6.0
   --
   -- @see WP_Dependencies
   --
   type Wp_Styles is new Class_Dependencies.Wp_Dependencies
      with record
        --
        -- Base URL for styles.
        --
        -- Full URL with trailing slash.
        --
        -- @since 2.6.0
        -- @var string
        --
        Base_URL : UStrings.UString;

        --
        -- URL of the content directory.
        --
        -- @since 2.8.0
        -- @var string
        --
        Content_URL : UStrings.UString;

        --
        -- Default version string for stylesheets.
        --
        -- @since 2.6.0
        -- @var string
        --
        Default_Version : UStrings.UString;

        --
        -- The current text direction.
        --
        -- @since 2.6.0
        -- @var string
        --
        Text_Direction : UStrings.UString := UStrings.To_UString ("ltr");

        --
        -- Holds a list of style handles which will be concatenated.
        --
        -- @since 2.8.0
        -- @var string
        --
        Concat : UStrings.UString;

        --
        -- Holds a string which contains style handles and their version.
        --
        -- @since 2.8.0
        -- @deprecated 3.4.0
        -- @var string
        --
        Concat_Version : UStrings.UString;

        --
        -- Whether to perform concatenation.
        --
        -- @since 2.8.0
        -- @var bool
        --
        Do_Concat : Boolean := False;

        --
        -- Holds HTML markup of styles and additional data if concatenation
        -- is enabled.
        --
        -- @since 2.8.0
        -- @var string
        --
        Print_HTML : UStrings.UString;

        --
        -- Holds inline styles if concatenation is enabled.
        --
        -- @since 3.3.0
        -- @var string
        --
        Print_Code : UStrings.UString;

        --
        -- List of default directories.
        --
        -- @since 2.8.0
        -- @var array
        --
        Default_Dirs : List_Type;

        --
        -- Holds a string which contains the type attribute for style tag.
        --
        -- If the active theme does not declare HTML5 support for 'style',
        -- then it initializes as `type='text/css'`.
        --
        -- @since 5.3.0
        -- @var string
        --
        -- private
        Type_Attr : UStrings.UString;

      end record;

   --
   -- Constructor.
   --
   -- @since 2.6.0
   --
   function X_Construct
            return Wp_Styles;

   --
   -- Processes a style dependency.
   --
   -- @since 2.6.0
   -- @since 5.5.0 Added the `group` parameter.
   --
   -- @see WP_Dependencies::do_item()
   --
   -- @param string    handle The style's registered handle.
   -- @param int|false group  Optional. Group level: level (int), no groups (false).
   --                          Default false.
   -- @return bool True on success, false on failure.
   --
   function Do_Item (This   : in out Wp_Styles;
                     Handle : String;
                     Group  : Boolean := False)
                     return Boolean;

   --
   -- Adds extra CSS styles to a registered stylesheet.
   --
   -- @since 3.3.0
   --
   -- @param string handle The style"s registered handle.
   -- @param string code   String containing the CSS styles to be added.
   -- @return bool True on success, false on failure.
   --
   function Add_Inline_Style (This   : in out Wp_Styles;
                              Handle : String;
                              Code   : String)
                              return Boolean;

   --
   -- Prints extra CSS styles of a registered stylesheet.
   --
   -- @since 3.3.0
   --
   -- @param string handle  The style"s registered handle.
   -- @param bool   display Optional. Whether to print the inline style
   --                        instead of just returning it. Default true.
   -- @return string|bool False if no data exists, inline styles if `display` is true,
   --                     true otherwise.
   --
   function Print_Inline_Style (This    : Wp_Styles;
                                Handle  : String;
                                Display : Boolean := True)
                                return String;

   procedure Print_Inline_Style (This    : Wp_Styles;
                                 Handle  : String;
                                 Display : Boolean := True);

   --
   -- Generates an enqueued style's fully-qualified URL.
   --
   -- @since 2.6.0
   --
   -- @param string src    The source of the enqueued style.
   -- @param string ver    The version of the enqueued style.
   -- @param string handle The style"s registered handle.
   -- @return string Style's fully-qualified URL.
   --
   function X_CSS_Href (This   : Wp_Styles;
                        Src    : String;
                        Ver    : String;
                        Handle : String)
                        return String;

   --
   -- Whether a handle"s source is in a default directory.
   --
   -- @since 2.8.0
   --
   -- @param string src The source of the enqueued style.
   -- @return bool True if found, false if not.
   --
   function In_Default_Dir (This : Wp_Styles;
                            Src  : String)
                            return Boolean;

   --
   -- Processes items and dependencies for the footer group.
   --
   -- HTML 5 allows styles in the body, grab late enqueued items and output them in
   -- the footer.
   --
   -- @since 3.3.0
   --
   -- @see WP_Dependencies::do_items()
   --
   -- @return string[] Handles of items that have been processed.
   --
   function Do_Footer_Items (This : in out Wp_Styles)
            return List_Type;

   procedure Do_Footer_Items (This : in out Wp_Styles);

   --
   -- Resets class properties.
   --
   -- @since 3.3.0
   --
   procedure Reset (This : in out Wp_Styles);

end Class_Styles;
