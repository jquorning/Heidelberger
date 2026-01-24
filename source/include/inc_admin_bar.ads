--
-- Toolbar API: Top-level Toolbar functionality
--
-- @package WordPress
-- @subpackage Toolbar
-- @since 3.1.0
--

with Ada.Strings.Unbounded;

with Inc_Class_Wp_Admin_Bar;
with Inc_Class_Wp_Customize_Managers;
with Class_Posts;
with Class_Terms;
with Inc_Class_Wp_Querys;

package Inc_Admin_Bar
is
   use Ada.Strings.Unbounded;
   use Inc_Class_Wp_Admin_Bar;

   X_Wp_Admin_Bar : Wp_Admin_Bar; -- X_ added jq

   Tag            : Class_Terms.Wp_Term;
   Wp_The_Query   : Inc_Class_Wp_Querys.Wp_Query;
   User_Id        : Integer;
   Id_Of_Post     : Class_Posts.Post_Id; -- was Post_Id : Integer

   X_Show_Admin_Bar : Boolean; -- X_ added
   Pagenow          : Unbounded_String;

   Wp_Customize : Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager;

   --
   -- Instantiates the admin bar object and set it up as a global for access elsewhere.
   --
   -- UNHOOKING THIS FUNCTION WILL NOT PROPERLY REMOVE THE ADMIN BAR.
   -- For that, use show_admin_bar(false) or the {@see "show_admin_bar"} filter.
   --
   -- @since 3.1.0
   -- @access private
   --
   -- @global WP_Admin_Bar wp_admin_bar
   --
   -- @return bool Whether the admin bar was successfully initialized.
   --
   function X_Wp_Admin_Bar_Init
            return Boolean;

   procedure X_Wp_Admin_Bar_Init;

   --
   -- Renders the admin bar to the page based on the wp_admin_bar.menu member var.
   --
   -- This is called very early on the {@see "wp_body_open"} action so that it will
   -- render before anything else being added to the page body.
   --
   -- For backward compatibility with themes not using the "wp_body_open" action,
   -- the function is also called late on {@see "wp_footer"}.
   --
   -- It includes the {@see "admin_bar_menu"} action which should be used to
   -- hook in and add new menus to the admin bar. That way you can be sure that you
   -- are adding at most optimal point, right before the admin bar is rendered. This
   -- also gives you access to the `post` global, among others.
   --
   -- @since 3.1.0
   -- @since 5.4.0 Called on "wp_body_open" action first, with "wp_footer" as a
   --              fallback.
   --
   -- @global WP_Admin_Bar wp_admin_bar
   --
   procedure Wp_Admin_Bar_Render;

   --
   -- Adds the WordPress logo menu.
   --
   -- @since 3.3.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Wp_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds the sidebar toggle button.
   --
   -- @since 3.8.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Sidebar_Toggle (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds the "My Account" item.
   --
   -- @since 3.3.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_My_Account_Item (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds the "My Account" submenu items.
   --
   -- @since 3.1.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_My_Account_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds the "Site Name" menu.
   --
   -- @since 3.3.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Site_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds the "Edit site" link to the Toolbar.
   --
   -- @since 5.9.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Edit_Site_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds the "Customize" link to the Toolbar.
   --
   -- @since 4.3.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   -- @global WP_Customize_Manager wp_customize
   --
   procedure Wp_Admin_Bar_Customize_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds the "My Sites/[Site Name]" menu and all submenus.
   --
   -- @since 3.1.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_My_Sites_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Provides a shortlink.
   --
   -- @since 3.1.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Shortlink_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Provides an edit link for posts and terms.
   --
   -- @since 3.1.0
   -- @since 5.5.0 Added a "View Post" link on Comments screen for a single post.
   --
   -- @global WP_Term  tag
   -- @global WP_Query wp_the_query WordPress Query object.
   -- @global int      user_id      The ID of the user being edited. Not to be
   --                               confused with the global user_ID, which contains
   --                               the ID of the current user.
   -- @global int      post_id      The ID of the post when editing comments for a
   --                               single post.
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Edit_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds "Add New" menu.
   --
   -- @since 3.1.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_New_Content_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds edit comments link with awaiting moderation count bubble.
   --
   -- @since 3.1.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Comments_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds appearance submenu items to the "Site Name" menu.
   --
   -- @since 3.1.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Appearance_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Provides an update link if theme/plugin/core updates are available.
   --
   -- @since 3.1.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Updates_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds search form.
   --
   -- @since 3.3.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Search_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds a link to exit recovery mode when Recovery Mode is active.
   --
   -- @since 5.2.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Recovery_Mode_Menu (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Adds secondary menus.
   --
   -- @since 3.3.0
   --
   -- @param WP_Admin_Bar wp_admin_bar The WP_Admin_Bar instance.
   --
   procedure Wp_Admin_Bar_Add_Secondary_Groups (Admin_Bar : in out Wp_Admin_Bar);

   --
   -- Prints style and scripts for the admin bar.
   --
   -- @since 3.1.0
   --
   procedure Wp_Admin_Bar_Header;

   --
   -- Prints default admin bar callback.
   --
   -- @since 3.1.0
   --
   procedure X_Admin_Bar_Bump_Cb;

   --
   -- Sets the display status of the admin bar.
   --
   -- This can be called immediately upon plugin load. It does not need to be called
   -- from a function hooked to the {@see "init"} action.
   --
   -- @since 3.1.0
   --
   -- @global bool show_admin_bar
   --
   -- @param bool show Whether to allow the admin bar to show.
   --
   procedure Show_Admin_Bar (Show : Boolean);

   --
   -- Determines whether the admin bar should be showing.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 3.1.0
   --
   -- @global bool   show_admin_bar
   -- @global string pagenow        The filename of the current screen.
   --
   -- @return bool Whether the admin bar should be showing.
   --
   function Is_Admin_Bar_Showing
            return Boolean;

   --
   -- Retrieves the admin bar display preference of a user.
   --
   -- @since 3.1.0
   -- @access private
   --
   -- @param string context Context of this preference check. Defaults to "front".
   --                       The "admin preference is no longer used.
   -- @param int    user    Optional. ID of the user to check, defaults to 0 for
   --                       current user.
   -- @return bool Whether the admin bar should be showing for this user.
   --
   function X_Get_Admin_Bar_Pref (Context : String  := "front";
                                  User    : Integer := 0)
                                  return Boolean;

end Inc_Admin_Bar;
