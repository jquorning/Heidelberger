--
-- Screen API: WP_Screen class
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Arrays;
with UStrings;

package Adi_Class_Wp_Screens
is
   use Arrays;

--
-- Core class used to implement an admin screen API.
--
-- @since 3.3.0
--
--#[AllowDynamicProperties]
   type Wp_Screen is tagged
      record
        --
        -- Any action associated with the screen.
        --
        -- "add" for---add.php and---new.php screens. Empty otherwise.
        --
        -- @since 3.3.0
        -- @var string
        --
        Action : UStrings.UString;

        --
        -- The base type of the screen.
        --
        -- This is typically the same as `id` but with any post types and taxonomies
        -- stripped. For example, for an `id` of "edit-post" the base is "edit".
        --
        -- @since 3.3.0
        -- @var string
        --
        Base : UStrings.UString;

        --
        -- The number of columns to display. Access with get_columns().
        --
        -- @since 3.4.0
        -- @var int
        --
        -- private
        Columns : Natural := 0;

        --
        -- The unique ID of the screen.
        --
        -- @since 3.3.0
        -- @var string
        --
        Id : UStrings.UString;

        --
        -- Which admin the screen is in. network | user | site | false
        --
        -- @since 3.5.0
        -- @var string
        --
--        protected
        M_In_Admin : UStrings.UString;

        --
        -- Whether the screen is in the network admin.
        --
        -- Deprecated. Use in_admin() instead.
        --
        -- @since 3.3.0
        -- @deprecated 3.5.0
        -- @var bool
        --
        Is_Network : Boolean;

        --
        -- Whether the screen is in the user admin.
        --
        -- Deprecated. Use in_admin() instead.
        --
        -- @since 3.3.0
        -- @deprecated 3.5.0
        -- @var bool
        --
        Is_User : Boolean;

        --
        -- The base menu parent.
        --
        -- This is derived from `parent_file` by removing the query string and any .php extension.
        -- `parent_file` values of "edit.php?post_type=page" and "edit.php?post_type=post"
        -- have a `parent_base` of "edit".
        --
        -- @since 3.3.0
        -- @var string
        --
        Parent_Base : UStrings.UString;

        --
        -- The parent_file for the screen per the admin menu system.
        --
        -- Some `parent_file` values are "edit.php?post_type=page", "edit.php", and "options-general.php".
        --
        -- @since 3.3.0
        -- @var string
        --
        Parent_File : UStrings.UString;

        --
        -- The post type associated with the screen, if any.
        --
        -- The "edit.php?post_type=page" screen has a post type of "page".
        -- The "edit-tags.php?taxonomy=taxonomy&post_type=page" screen has a post type of "page".
        --
        -- @since 3.3.0
        -- @var string
        --
        Post_Type : UStrings.UString;

        --
        -- The taxonomy associated with the screen, if any.
        --
        -- The "edit-tags.php?taxonomy=category" screen has a taxonomy of "category".
        --
        -- @since 3.3.0
        -- @var string
        --
        Taxonomy : UStrings.UString;

        --
        -- The help tab data associated with the screen, if any.
        --
        -- @since 3.3.0
        -- @var array
        --
--        private _help_tabs = array();

        --
        -- The help sidebar data associated with screen, if any.
        --
        -- @since 3.3.0
        -- @var string
        --
--        private _help_sidebar = "";

        --
        -- The accessible hidden headings and text associated with the screen, if any.
        --
        -- @since 4.4.0
        -- @var array
        --
         X_Screen_Reader_Content : Array_Type;

        --
        -- Stores old string-based help.
        --
        -- @var array
        --
--        private static _old_compat_help = array();

        --
        -- The screen options associated with screen, if any.
        --
        -- @since 3.3.0
        -- @var array
        --
--        private _options = array();

        --
        -- The screen object registry.
        --
        -- @since 3.3.0
        --
        -- @var array
        --
--        private static _registry = array();

        --
        -- Stores the result of the show_screen_options function.
        --
        -- @since 3.3.0
        -- @var bool
        --
--        private _show_screen_options;

        --
        -- Stores the "screen_settings" section of screen options.
        --
        -- @since 3.3.0
        -- @var string
        --
--        private _screen_settings;

        --
        -- Whether the screen is using the block editor.
        --
        -- @since 5.0.0
        -- @var bool
        --
        Is_Block_Editor : Boolean := False;

      end record;

      --
      -- Sets the parent information for the screen.
      --
      -- This is called in admin-header.php after the menu parent for the screen
      --  has been determined.
      --
      -- @since 3.3.0
      --
      -- @param string $parent_file The parent file of the screen. Typically the
      --                            parent_file global.
      --
      procedure Set_Parentage (This        : Wp_Screen;
                               Parent_File : String)
                               is null;

   --
   -- Indicates whether the screen is in a particular admin.
   --
   -- @since 3.5.0
   --
   -- @param string $admin The admin to check against (network | user | site).
   --                      If empty any of the three admins will result in true.
   -- @return bool True if the screen is in the indicated admin, false otherwise.
   --
   function In_Admin (This  : Wp_Screen;
                      Admin : String := "") -- null
                      return Boolean;

   --
   -- Gets the number of layout columns the user has selected.
   --
   -- The layout_columns option controls the max number and default number of
   -- columns. This method returns the number of columns within that range selected
   -- by the user via Screen Options. If no selection has been made, the default
   -- provisioned in layout_columns is returned. If the screen does not support
   -- selecting the number of layout columns, 0 is returned.
   --
   -- @since 3.4.0
   --
   -- @return int Number of columns to display.
   --
   function Get_Columns (This : Wp_Screen)
                         return Natural;

      --
      -- Renders the screen"s help section.
      --
      -- This will trigger the deprecated filters for backward compatibility.
      --
      -- @since 3.3.0
      --
      -- @global string $screen_layout_columns
      --
      procedure Render_Screen_Meta (This : Wp_Screen)
                                    is null;

   --
   -- Adds a help tab to the contextual help for the screen.
   --
   -- Call this on the `load-$pagenow` hook for the relevant screen,
   -- or fetch the `$current_screen` object, or use get_current_screen()
   -- and then call the method from the object.
   --
   -- You may need to filter `$current_screen` using an if or switch statement
   -- to prevent new help tabs from being added to ALL admin screens.
   --
   -- @since 3.3.0
   -- @since 4.4.0 The `$priority` argument was added.
   --
   -- @param array $args {
   --     Array of arguments used to display the help tab.
   --
   --     @type string   $title    Title for the tab. Default false.
   --     @type string   $id       Tab ID. Must be HTML-safe and should be unique
   --                              for this menu.
   --                              It is NOT allowed to contain any empty spaces.
   --                              Default false.
   --     @type string   $content  Optional. Help tab content in plain text or HTML.
   --                              Default empty string.
   --     @type callable $callback Optional. A callback to generate the tab content.
   --                              Default false.
   --     @type int      $priority Optional. The priority of the tab, used for
   --                              ordering. Default 10.
   -- }
   --
   procedure Add_Help_Tab (This : Wp_Screen;
                           Args : Array_Type)
                           is null;

   --
   -- Adds a sidebar to the contextual help for the screen.
   --
   -- Call this in template files after admin.php is loaded and before
   -- admin-header.php is loaded to add a sidebar to the contextual help.
   --
   -- @since 3.3.0
   --
   -- @param string $content Sidebar content in plain text or HTML.
   --
   procedure Set_Help_Sidebar (This    : Wp_Screen;
                               Content : String)
                               is null;

   --
   -- Adds accessible hidden headings and text for the screen.
   --
   -- @since 4.4.0
   --
   -- @param array $content then
   --     An associative array of screen reader text strings.
   --
   --     @type string $heading_views      Screen reader text for the filter links
   --                                      heading.
   --                                      Default "Filter items list".
   --     @type string $heading_pagination Screen reader text for the pagination
   --                                      heading.
   --                                      Default "Items list navigation".
   --     @type string $heading_list       Screen reader text for the items list
   --                                      heading.
   --                                      Default "Items list".
   -- end;
   --
   procedure Set_Screen_Reader_Content (This    : Wp_Screen;
                                        Content : Array_Type)
                                        is null;

   --
   -- Renders screen reader text.
   --
   -- @since 4.4.0
   --
   -- @param string $key The screen reader text array named key.
   -- @param string $tag Optional. The HTML tag to wrap the screen reader text.
   --                    Default h2.
   --
   procedure Render_Screen_Reader_Content (This : Wp_Screen;
                                           Key  : String := "";
                                           Tag  : String := "h2");

   --
   -- Fetches a screen object.
   --
   -- @since 3.3.0
   --
   -- @global string $hook_suffix
   --
   -- @param string|WP_Screen $hook_name Optional. The hook name (also known as the
   --                                    hook suffix) used to determine the screen.
   --                                    Defaults to the current $hook_suffix global.
   -- @return WP_Screen Screen object.
   --
   -- static
   function Get (Hook_Name : String := "")
                 return Wp_Screen;

end Adi_Class_Wp_Screens;
