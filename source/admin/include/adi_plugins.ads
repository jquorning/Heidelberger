--
-- WordPress Plugin Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrays;
with Lists;

with Class_Errors;

package Adi_Plugins
is
   use Arrays;
   use Lists;

   X_Wp_Real_Parent_File : Array_Type;

   --
   -- Parses the plugin contents to retrieve plugin"s metadata.
   --
   -- All plugin headers must be on their own line. Plugin description must not have
   -- any newlines, otherwise only parts of the description will be displayed.
   -- The below is formatted for printing.
   --
   --     /*
   --     Plugin Name: Name of the plugin.
   --     Plugin URI: The home page of the plugin.
   --     Description: Plugin description.
   --     Author: Plugin author"s name.
   --     Author URI: Link to the author"s website.
   --     Version: Plugin version.
   --     Text Domain: Optional. Unique identifier, should be same as the one used in
   --          load_plugin_textdomain().
   --     Domain Path: Optional. Only useful if the translations are located in a
   --          folder above the plugin"s base path. For example, if .mo files are
   --          located in the locale folder then Domain Path will be "/locale/" and
   --          must have the first slash. Defaults to the base folder the plugin is
   --          located in.
   --     Network: Optional. Specify "Network: true" to require that a plugin is
   --          activated across all sites in an installation. This will prevent a
   --          plugin from being activated on a single site when Multisite is enabled.
   --     Requires at least: Optional. Specify the minimum required WordPress version.
   --     Requires PHP: Optional. Specify the minimum required PHP version.
   --    -- / # Remove the space to close comment.
   --
   -- The first 8 KB of the file will be pulled in and if the plugin data is not
   -- within that first 8 KB, then the plugin author should correct their plugin
   -- and move the plugin data headers to the top.
   --
   -- The plugin file is assumed to have permissions to allow for scripts to read
   -- the file. This is not checked however and the file is only opened for
   -- reading.
   --
   -- @since 1.5.0
   -- @since 5.3.0 Added support for `Requires at least` and `Requires PHP` headers.
   -- @since 5.8.0 Added support for `Update URI` header.
   --
   -- @param string $plugin_file Absolute path to the main plugin file.
   -- @param bool   $markup      Optional. If the returned data should have HTML
   --                            markup applied. Default true.
   -- @param bool   $translate   Optional. If the returned data should be translated.
   --                            Default true.
   -- @return array {
   --     Plugin data. Values will be empty if not supplied by the plugin.
   --
   --     @type string $Name        Name of the plugin. Should be unique.
   --     @type string $PluginURI   Plugin URI.
   --     @type string $Version     Plugin version.
   --     @type string $Description Plugin description.
   --     @type string $Author      Plugin author's name.
   --     @type string $AuthorURI   Plugin author's website address (if set).
   --     @type string $TextDomain  Plugin textdomain.
   --     @type string $DomainPath  Plugin's relative directory path to .mo files.
   --     @type bool   $Network     Whether the plugin can only be activated
   --                               network-wide.
   --     @type string $RequiresWP  Minimum required version of WordPress.
   --     @type string $RequiresPHP Minimum required version of PHP.
   --     @type string $UpdateURI   ID of the plugin for update purposes, should
   --                               be a URI.
   --     @type string $Title       Title of the plugin and link to the plugin's
   --                               site (if set).
   --     @type string AuthorName  Plugin author"s name.
   -- }
   --
   function Get_Plugin_Data (Plugin_File : String;
                             Markup      : Boolean := True;
                             Translate   : Boolean := True)
                             return Array_Type
   is (raise Program_Error with "not implemented");

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
   -- @param string    parent_slug The slug name for the parent menu (or the file
   --                              name of a standard WordPress admin page).
   -- @param string    page_title  The text to be displayed in the title tags of the
   --                              page when the menu is selected.
   -- @param string    menu_title  The text to be used for the menu.
   -- @param string    capability  The capability required for this menu to be
   --                              displayed to the user.
   -- @param string    menu_slug   The slug name to refer to this menu by. Should be
   --                              unique for this menu and only include lowercase
   --                              alphanumeric, dashes, and underscores characters
   --                              to be compatible with sanitize_key().
   -- @param callable  callback    Optional. The function to be called to output the
   --                              content for this page.
   -- @param int|float position    Optional. The position in the menu order this item
   --                              should appear.
   -- @return string|false The resulting page"s hook_suffix, or false if the user
   --                      does not have the capability required.
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
   -- @param string parent_page Optional. The slug name for the parent menu (or the
   --                           file name of a standard WordPress admin page).
   --                           Default empty string.
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
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
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
   -- Determines whether the current user can access the current admin page.
   --
   -- @since 1.5.0
   --
   -- @global string pagenow            The filename of the current screen.
   -- @global array  menu
   -- @global array  submenu
   -- @global array  _wp_menu_nopriv
   -- @global array  _wp_submenu_nopriv
   -- @global string plugin_page
   -- @global array  _registered_pages
   --
   -- @return bool True if the current user can access the admin page, false otherwise.
   --
   function User_Can_Access_Admin_Page
            return Boolean
            is (True);

   --
   -- Gets the title of the current admin page.
   --
   -- @since 1.5.0
   --
   -- @global string title
   -- @global array  menu
   -- @global array  submenu
   -- @global string pagenow     The filename of the current screen.
   -- @global string typenow     The post type of the current screen.
   -- @global string plugin_page
   --
   -- @return string The title of the current admin page.
   --
-- function Get_Admin_Page_Title
--          return String;

   procedure Get_Admin_Page_Title
   is null;

   --
   -- Gets the hook attached to the administrative page of a plugin.
   --
   -- @since 1.5.0
   --
   -- @param string plugin_page The slug name of the plugin page.
   -- @param string parent_page The slug name for the parent menu (or the file name
   --                           of a standard WordPress admin page).
   -- @return string|null Hook attached to the plugin page, null otherwise.
   --
   function Get_Plugin_Page_Hook (Plugin_Page : String;
                                  Parent_Page : String)
                                  return String
                                  is ("XXX-308");

   procedure Dummy;

   --
   -- Deactivates a single plugin or multiple plugins.
   --
   -- The deactivation hook is disabled by the plugin upgrader by using the silent
   -- parameter.
   --
   -- @since 2.5.0
   --
   -- @param string|string[] plugins      Single plugin or list of plugins to
   --                                     deactivate.
   -- @param bool            silent       Prevent calling deactivation hooks. Default
   --                                     false.
   -- @param bool|null       network_wide Whether to deactivate the plugin for all
   --                                     sites in the network. A value of null will
   --                                     deactivate plugins for both the network and
   --                                     the current site. Multisite only. Default
   --                                     null.
   --
   procedure Deactivate_Plugins (Plugins      : List_Type;
                                 Silent       : Boolean := False;
                                 Network_Wide : Boolean := False) -- null
                                 is null;

   --
   -- Checks for "Network: true" in the plugin header to see if this should
   -- be activated only as a network wide plugin. The plugin would also work
   -- when Multisite is not enabled.
   --
   -- Checks for "Site Wide Only: true" for backward compatibility.
   --
   -- @since 3.0.0
   --
   -- @param string plugin Path to the plugin file relative to the plugins directory.
   -- @return bool True if plugin is network only, false otherwise.
   --
   function Is_Network_Only_Plugin (Plugin : String)
                                    return Boolean
   is (raise Program_Error with "not implemented");

   --
   -- Attempts activation of plugin in a "sandbox" and redirects on success.
   --
   -- A plugin that is already activated will not attempt to be activated again.
   --
   -- The way it works is by setting the redirection to the error before trying to
   -- include the plugin file. If the plugin fails, then the redirection will not
   -- be overwritten with the success message. Also, the options will not be
   -- updated and the activation hook will not be called on plugin error.
   --
   -- It should be noted that in no way the below code will actually prevent errors
   -- within the file. The code should not be used elsewhere to replicate the
   -- "sandbox", which uses redirection to work.
   -- then@source 13 1end;
   --
   -- If any errors are found or text is outputted, then it will be captured to
   -- ensure that the success redirection will update the error redirection.
   --
   -- @since 2.5.0
   -- @since 5.2.0 Test for WordPress version and PHP version compatibility.
   --
   -- @param string plugin       Path to the plugin file relative to the plugins
   --                            directory.
   -- @param string redirect     Optional. URL to redirect to.
   -- @param bool   network_wide Optional. Whether to enable the plugin for all sites
   --                            in the network or just the current site. Multisite
   --                            only. Default false.
   -- @param bool   silent       Optional. Whether to prevent calling activation
   --                            hooks. Default false.
   -- @return null|WP_Error Null on success, WP_Error on invalid file.
   --

   type Null_Error_Type is record
      Success : Boolean;
      Error   : Class_Errors.Wp_Error;
   end record;

   function Activate_Plugin (Plugin : String;
                             Redirect : String := "";
                             Network_Wide : Boolean := False;
                             Silent       : Boolean := False)
                             return Null_Error_Type
   is (raise Program_Error with "not implemented");

   --
   -- Activates multiple plugins.
   --
   -- When WP_Error is returned, it does not mean that one of the plugins had
   -- errors. It means that one or more of the plugin file paths were invalid.
   --
   -- The execution will be halted as soon as one of the plugins has an error.
   --
   -- @since 2.6.0
   --
   -- @param string|string[] plugins      Single plugin or list of plugins to activate.
   -- @param string          redirect     Redirect to page after successful activation.
   -- @param bool            network_wide Whether to enable the plugin for all sites
   --                                     in the network. Default false.
   -- @param bool            silent       Prevent calling activation hooks. Default
   --                                     false.
   -- @return bool|WP_Error True when finished or WP_Error if there were errors
   --                       during a plugin activation.
   --
   type Bool_Error_Type is record
      Success : Boolean;
      Error   : Class_Errors.Wp_Error;
   end record;

   function Activate_Plugins (Plugins      : List_Type;
                              Redirect     : String := "";
                              Network_Wide : Boolean := False;
                              Silent       : Boolean := False)
                              return Bool_Error_Type
   is (raise Program_Error with "not implemented");

   procedure Activate_Plugins (Plugins      : List_Type;
                               Redirect     : String := "";
                               Network_Wide : Boolean := False;
                               Silent       : Boolean := False)
   is null;

   --
   -- Validates the plugin path.
   --
   -- Checks that the main plugin file exists and is a valid plugin. See
   -- validate_file().
   --
   -- @since 2.5.0
   --
   -- @param string plugin Path to the plugin file relative to the plugins directory.
   -- @return int|WP_Error 0 on success, WP_Error on failure.
   --
   function Validate_Plugin (Plugin : String)
                             return Bool_Error_Type
   is (raise Program_Error with "not implemented");

   --
   -- Determines whether the plugin is active for the entire network.
   --
   -- Only plugins installed in the plugins/ folder can be active.
   --
   -- Plugins in the mu-plugins/ folder can't be "activated," so this function will
   -- return false for those plugins.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 3.0.0
   --
   -- @param string plugin Path to the plugin file relative to the plugins directory.
   -- @return bool True if active for the network, otherwise false.
   --
   function Is_Plugin_Active_For_Network (Plugin : String)
                                          return Boolean
   is (raise Program_Error with "not implemented");

   --
   -- Loads a given plugin attempt to generate errors.
   --
   -- @since 3.0.0
   -- @since 4.4.0 Function was moved into the `wp-admin/includes/plugin.php` file.
   --
   -- @param string plugin Path to the plugin file relative to the plugins directory.
   --
   procedure Plugin_Sandbox_Scrape (Plugin : String)
   is null;

   --
   -- Determines whether the plugin is inactive.
   --
   -- Reverse of is_plugin_active(). Used as a callback.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 3.1.0
   --
   -- @see is_plugin_active()
   --
   -- @param string plugin Path to the plugin file relative to the plugins directory.
   -- @return bool True if inactive. False if active.
   --
   function Is_Plugin_Inactive (Plugin : String)
                                return Boolean
   is (raise Program_Error with "not implemented");

   --
   -- Determines whether the plugin can be uninstalled.
   --
   -- @since 2.7.0
   --
   -- @param string plugin Path to the plugin file relative to the plugins directory.
   -- @return bool Whether plugin can be uninstalled.
   --
   function Is_Uninstallable_Plugin (Plugin : String)
                                     return Boolean
   is (raise Program_Error with "not implemented");

   --
   -- Checks the plugins directory and retrieve all plugin files with plugin data.
   --
   -- WordPress only supports plugin files in the base plugins directory
   -- (wp-content/plugins) and in one directory above the plugins directory
   -- (wp-content/plugins/my-plugin). The file it looks for has the plugin data
   -- and must be found in those two locations. It is recommended to keep your
   -- plugin files in their own directories.
   --
   -- The file with the plugin data is the file that will be included and therefore
   -- needs to have the main execution for the plugin. This does not mean
   -- everything must be contained in the file and it is recommended that the file
   -- be split for maintainability. Keep everything in one file for extreme
   -- optimization purposes.
   --
   -- @since 1.5.0
   --
   -- @param string plugin_folder Optional. Relative path to single plugin folder.
   -- @return array[] Array of arrays of plugin data, keyed by plugin file name.
   --                 See get_plugin_data().
   --
   function Get_Plugins (Plugin_Folder : String := "")
                         return Array_Type
   is (raise Program_Error with "not implemented");

   --
   -- Sanitizes plugin data, optionally adds markup, optionally translates.
   --
   -- @since 2.7.0
   --
   -- @see get_plugin_data()
   --
   -- @access private
   --
   -- @param string plugin_file Path to the main plugin file.
   -- @param array  plugin_data An array of plugin data. See get_plugin_data().
   -- @param bool   markup      Optional. If the returned data should have HTML markup
   --                           applied. Default true.
   -- @param bool   translate   Optional. If the returned data should be translated.
   --                           Default true.
   -- @return array Plugin data. Values will be empty if not supplied by the plugin.
   --               See get_plugin_data() for the list of possible values.
   --
   function X_Get_Plugin_Data_Markup_Translate
              (Plugin_File : String;
               Plugin_Data : Array_Type;
               Markup      : Boolean := True;
               Translate   : Boolean := True)
               return Array_Type
   is (raise Program_Error with "not implemented");

   --
   -- Removes directory and files of a plugin for a list of plugins.
   --
   -- @since 2.6.0
   --
   -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
   --
   -- @param string[] plugins    List of plugin paths to delete, relative to the
   --                            plugins directory.
   -- @param string   deprecated Not used.
   -- @return bool|null|WP_Error True on success, false if `plugins` is empty,
   --                            `WP_Error` on failure. `null` if filesystem
   --                            credentials are required to proceed.
   --
   function Delete_Plugins (Plugins    : List_Type;
                            Deprecated : String := "")
                            return Boolean
   is (raise Program_Error with "not implemented");

   --
   -- Tries to resume a single plugin.
   --
   -- If a redirect was provided, we first ensure the plugin does not throw fatal
   -- errors anymore.
   --
   -- The way it works is by setting the redirection to the error before trying to
   -- include the plugin file. If the plugin fails, then the redirection will not
   -- be overwritten with the success message and the plugin will not be resumed.
   --
   -- @since 5.2.0
   --
   -- @param string plugin   Single plugin to resume.
   -- @param string redirect Optional. URL to redirect to. Default empty string.
   -- @return bool|WP_Error True on success, false if `plugin` was not paused,
   --                       `WP_Error` on failure.
   --
   function Resume_Plugin (Plugin   : String;
                           Redirect : String := "")
                           return Bool_Error_Type
   is (raise Program_Error with "not implemented");

   --
   -- Validates active plugins.
   --
   -- Validate all active plugins, deactivates invalid and
   -- returns an array of deactivated ones.
   --
   -- @since 2.5.0
   -- @return WP_Error[] Array of plugin errors keyed by plugin file name.
   --

   package Error_Maps is
      new Ada.Containers.Indefinite_Ordered_Maps
            (Key_Type     => String,
             Element_Type => Class_Errors.Wp_Error,
             "="          => Class_Errors."=");

   subtype Error_List is Error_Maps.Map;

   function Validate_Active_Plugins
            return Error_List
   is (Error_Maps.Empty_Map);
-- is (raise Program_Error with "not implemented");

   --
   -- Returns drop-ins that WordPress uses.
   --
   -- Includes Multisite drop-ins only when is_multisite()
   --
   -- @since 3.0.0
   -- @return array[] Key is file name. The value is an array, with the first value the
   --  purpose of the drop-in and the second value the name of the constant that must
   --  be true for the drop-in to be used, or true if no constant is required.
   --
   function X_Get_Dropins
            return Array_Type
   is (raise Program_Error with "not implemented");

   --
   -- Determines whether a plugin is technically active but was paused while
   -- loading.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 5.2.0
   --
   -- @param string plugin Path to the plugin file relative to the plugins directory.
   -- @return bool True, if in the list of paused plugins. False, if not in the list.
   --
   function Is_Plugin_Paused (Plugin : String)
                              return Boolean
   is (raise Program_Error with "not implemented");

   --
   -- Gets the error that was recorded for a paused plugin.
   --
   -- @since 5.2.0
   --
   -- @param string plugin Path to the plugin file relative to the plugins directory.
   -- @return array|false Array of error information as returned by `error_get_last()`,
   --                     or false if none was recorded.
   --
   function Wp_Get_Plugin_Error (Plugin : String)
                                 return List_Type  -- Array_Type;
   is (raise Program_Error with "not implemented");

end Adi_Plugins;
