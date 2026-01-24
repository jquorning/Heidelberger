--
-- Dependencies API: WP_Styles class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--
with Ada.Strings.Unbounded;

with Lists;

with Class_Dependencies;

package Class_Styles
is
   use Ada.Strings.Unbounded;
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
        Base_URL : Unbounded_String;

        --
        -- URL of the content directory.
        --
        -- @since 2.8.0
        -- @var string
        --
        Content_URL : Unbounded_String;

        --
        -- Default version string for stylesheets.
        --
        -- @since 2.6.0
        -- @var string
        --
        Default_Version : Unbounded_String;

        --
        -- The current text direction.
        --
        -- @since 2.6.0
        -- @var string
        --
        Text_Direction : Unbounded_String := To_Unbounded_String ("ltr");

        --
        -- Holds a list of style handles which will be concatenated.
        --
        -- @since 2.8.0
        -- @var string
        --
        Concat : Unbounded_String;

        --
        -- Holds a string which contains style handles and their version.
        --
        -- @since 2.8.0
        -- @deprecated 3.4.0
        -- @var string
        --
        Concat_Version : Unbounded_String;

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
        Print_HTML : Unbounded_String;

        --
        -- Holds inline styles if concatenation is enabled.
        --
        -- @since 3.3.0
        -- @var string
        --
        Print_Code : Unbounded_String;

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
        Type_Attr : Unbounded_String;

      end record;

   --
   -- Constructor.
   --
   -- @since 2.6.0
   --
   function X_Construct
            return Wp_Styles;

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
