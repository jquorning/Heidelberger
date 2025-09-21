--
-- WordPress Plugin Administration API
--
-- @package WordPress
-- @subpackage Administration
--
package Adi_Plugins
is
--
-- Adds a submenu page.
--
-- This function takes a capability which will be used to determine whether
-- or not a page is included in the menu.
--
-- The function which is hooked in to handle the output of the page must check
-- that the user has the required capability as well.
--
-- @since 1.5.0
-- @since 5.3.0 Added the `position` parameter.
--
-- @global array submenu
-- @global array menu
-- @global array _wp_real_parent_file
-- @global bool  _wp_submenu_nopriv
-- @global array _registered_pages
-- @global array _parent_pages
--
-- @param string    parent_slug The slug name for the parent menu (or the file name of a standard
--                               WordPress admin page).
-- @param string    page_title  The text to be displayed in the title tags of the page when the menu
--                               is selected.
-- @param string    menu_title  The text to be used for the menu.
-- @param string    capability  The capability required for this menu to be displayed to the user.
-- @param string    menu_slug   The slug name to refer to this menu by. Should be unique for this menu
--                               and only include lowercase alphanumeric, dashes, and underscores characters
--                               to be compatible with sanitize_key().
-- @param callable  callback    Optional. The function to be called to output the content for this page.
-- @param int|float position    Optional. The position in the menu order this item should appear.
-- @return string|false The resulting page"s hook_suffix, or false if the user does not have the capability required.
--
   procedure Add_Submenu_Page (Parent_Slug : String;
                               Page_Title  : String;
                               Menu_Title  : String;
                               Capability  : String;
                               Menu_Slug   : String;
                               Callback    : String := "";
                               Position    : Integer := 0) -- = null
                               -- return String;
                               is null;

--
-- Pluggable Menu Support -- Private.
--
--
-- Gets the parent file of the current admin page.
--
-- @since 1.5.0
--
-- @global string parent_file
-- @global array  menu
-- @global array  submenu
-- @global string pagenow              The filename of the current screen.
-- @global string typenow              The post type of the current screen.
-- @global string plugin_page
-- @global array  _wp_real_parent_file
-- @global array  _wp_menu_nopriv
-- @global array  _wp_submenu_nopriv
--
-- @param string parent_page Optional. The slug name for the parent menu (or the file name
--                            of a standard WordPress admin page). Default empty string.
-- @return string The parent file of the current admin page.
--
   function Get_Admin_Page_Parent (Parent_Page : String := "")
                                   return String
                                   is ("XXX-307");

--
-- Determines whether a plugin is active.
--
-- Only plugins installed in the plugins/ folder can be active.
--
-- Plugins in the mu-plugins/ folder can"t be "activated," so this function will
-- return false for those plugins.
--
-- For more information on this and similar theme functions, check out
-- the then@link https:--developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 2.5.0
--
-- @param string plugin Path to the plugin file relative to the plugins directory.
-- @return bool True, if in the active plugins list. False, not in the list.
--
   function Is_Plugin_Active (Plugin : String)
                              return Boolean
                              is (False);

--
-- Gets the hook attached to the administrative page of a plugin.
--
-- @since 1.5.0
--
-- @param string plugin_page The slug name of the plugin page.
-- @param string parent_page The slug name for the parent menu (or the file name of a standard
--                            WordPress admin page).
-- @return string|null Hook attached to the plugin page, null otherwise.
--
   function Get_Plugin_Page_Hook (Plugin_Page : String;
                                  Parent_Page : String)
                                  return String
                                  is ("XXX-308");

procedure Dummy;

end Adi_Plugins;
