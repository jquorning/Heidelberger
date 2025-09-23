--
-- Dependencies API: WP_Styles class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--
with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wp_Dependencies;

package Inc_Class_Wp_Styles
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- Core class used to register styles.
   --
   -- @since 2.6.0
   --
   -- @see WP_Dependencies
   --
   type WP_Styles is new Inc_Class_Wp_Dependencies.WP_Dependencies
      with record
        --
        -- Base URL for styles.
        --
        -- Full URL with trailing slash.
        --
        -- @since 2.6.0
        -- @var string
        --
        Base_Url : Unbounded_String;

        --
        -- URL of the content directory.
        --
        -- @since 2.8.0
        -- @var string
        --
        Content_Url : Unbounded_String;

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
        Print_Html : Unbounded_String;

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
        Default_Dirs : Array_Type;

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

end Inc_Class_Wp_Styles;
