--
-- WordPress Plugin Install Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;
with Helpers_2;
with UStrings;

with Class_Errors;

package Adi_Plugin_Install is
   use Arrays;

   type Plugin_API_Args is record
      Slug     : UStrings.UString;   -- The plugin slug. Default empty.
      Per_Page : Natural;   -- Number of plugins per page. Default 24.
      Page     : Natural;   -- Number of current page. Default 1.

      Number : Natural;
      -- Number of tags or categories to be queried.

      Search : UStrings.UString;   -- A search term. Default empty.

      Tag : UStrings.UString;
      -- Tag to filter plugins. Default empty.

      Author : UStrings.UString;
      -- Username of an plugin author to filter plugins. Default empty.

      User : UStrings.UString;
      -- Username to query for their favorites. Default empty.

      Browse : UStrings.UString;
      -- Browse view: 'popular', 'new', 'beta', 'recommended'.

      Locale : UStrings.UString;
      -- Locale to provide context-sensitive results. Default is the value
      -- of get_locale().

      Installed_Plugins : UStrings.UString;
      -- Installed plugins to provide context-sensitive results.

      Is_SSL : Boolean;
      -- Whether links should be returned with https or not. Default false.

      Fields : Array_Type;   --     @type array   $fields            {
   end record;

   Null_Plugin_API_Args : constant Plugin_API_Args :=
     (Per_Page | Page | Number => 0,
      Is_SSL                   => False,
      Fields                   => Empty_Array,
      others                   => UStrings.Null_UString);

   function To_Array (Args : Plugin_API_Args) return Array_Type;

   --
   -- Retrieves plugin installer pages from the WordPress.org Plugins API.
   --
   -- It is possible for a plugin to override the Plugin API result with three
   -- filters. Assume this is for plugins, which can extend on the Plugin Info to
   -- offer more choices. This is very powerful and must be used with care when
   -- overriding the filters.
   --
   -- The first filter, {@see 'plugins_api_args'}, is for the args and gives the action
   -- as the second parameter. The hook for {@see 'plugins_api_args'} must ensure that
   -- an object is returned.
   --
   -- The second filter, {@see 'plugins_api'}, allows a plugin to override the WordPress.org
   -- Plugin Installation API entirely. If `$action` is 'query_plugins' or 'plugin_information',
   -- an object MUST be passed. If `$action` is 'hot_tags', an array MUST be passed.
   --
   -- Finally, the third filter, {@see 'plugins_api_result'}, makes it possible to filter the
   -- response object or array, depending on the `$action` type.
   --
   -- Supported arguments per action:
   --
   -- | Argument Name        | query_plugins | plugin_information | hot_tags |
   -- | -------------------- | :-----------: | :----------------: | :------: |
   -- | `$slug`              | No            |  Yes               | No       |
   -- | `$per_page`          | Yes           |  No                | No       |
   -- | `$page`              | Yes           |  No                | No       |
   -- | `$number`            | No            |  No                | Yes      |
   -- | `$search`            | Yes           |  No                | No       |
   -- | `$tag`               | Yes           |  No                | No       |
   -- | `$author`            | Yes           |  No                | No       |
   -- | `$user`              | Yes           |  No                | No       |
   -- | `$browse`            | Yes           |  No                | No       |
   -- | `$locale`            | Yes           |  Yes               | No       |
   -- | `$installed_plugins` | Yes           |  No                | No       |
   -- | `$is_ssl`            | Yes           |  Yes               | No       |
   -- | `$fields`            | Yes           |  Yes               | No       |
   --
   -- @since 2.7.0
   --
   -- @param string       $action API action to perform: 'query_plugins', 'plugin_information',
   --                             or 'hot_tags'.
   -- @param array|object $args   {
   --     Optional. Array or object of arguments to serialize for the Plugin Info API.
   --
   --     @type string  $slug              The plugin slug. Default empty.
   --     @type int     $per_page          Number of plugins per page. Default 24.
   --     @type int     $page              Number of current page. Default 1.
   --     @type int     $number            Number of tags or categories to be queried.
   --     @type string  $search            A search term. Default empty.
   --     @type string  $tag               Tag to filter plugins. Default empty.
   --     @type string  $author            Username of an plugin author to filter plugins. Default empty.
   --     @type string  $user              Username to query for their favorites. Default empty.
   --     @type string  $browse            Browse view: 'popular', 'new', 'beta', 'recommended'.
   --     @type string  $locale            Locale to provide context-sensitive results. Default is the value
   --                                      of get_locale().
   --     @type string  $installed_plugins Installed plugins to provide context-sensitive results.
   --     @type bool    $is_ssl            Whether links should be returned with https or not. Default false.
   --     @type array   $fields            {
   --         Array of fields which should or should not be returned.
   --
   --         @type bool $short_description Whether to return the plugin short description. Default true.
   --         @type bool $description       Whether to return the plugin full description. Default false.
   --         @type bool $sections          Whether to return the plugin readme sections: description, installation,
   --                                       FAQ, screenshots, other notes, and changelog. Default false.
   --         @type bool $tested            Whether to return the 'Compatible up to' value. Default true.
   --         @type bool $requires          Whether to return the required WordPress version. Default true.
   --         @type bool $requires_php      Whether to return the required PHP version. Default true.
   --         @type bool $rating            Whether to return the rating in percent and total number of ratings.
   --                                       Default true.
   --         @type bool $ratings           Whether to return the number of rating for each star (1-5). Default true.
   --         @type bool $downloaded        Whether to return the download count. Default true.
   --         @type bool $downloadlink      Whether to return the download link for the package. Default true.
   --         @type bool $last_updated      Whether to return the date of the last update. Default true.
   --         @type bool $added             Whether to return the date when the plugin was added to the wordpress.org
   --                                       repository. Default true.
   --         @type bool $tags              Whether to return the assigned tags. Default true.
   --         @type bool $compatibility     Whether to return the WordPress compatibility list. Default true.
   --         @type bool $homepage          Whether to return the plugin homepage link. Default true.
   --         @type bool $versions          Whether to return the list of all available versions. Default false.
   --         @type bool $donate_link       Whether to return the donation link. Default true.
   --         @type bool $reviews           Whether to return the plugin reviews. Default false.
   --         @type bool $banners           Whether to return the banner images links. Default false.
   --         @type bool $icons             Whether to return the icon links. Default false.
   --         @type bool $active_installs   Whether to return the number of active installations. Default false.
   --         @type bool $contributors      Whether to return the list of contributors. Default false.
   --     }
   -- }
   -- @return object|array|WP_Error Response object or array on success, WP_Error on failure. See the
   --         {@link https://developer.wordpress.org/reference/functions/plugins_api/ function reference article}
   --         for more information on the make-up of possible return values depending on the value of `$action`.
   --
   type Plugin_API_Result is record
      Success  : Boolean;
      External : Boolean;
      Info     : Array_Type;
      Plugins  : Array_Type;
      Arry     : Array_Type;
      Name     : UStrings.UString;
      Slug     : UStrings.UString;
      Error    : Class_Errors.Wp_Error;
   end record;

   type Plugin_Object_Type is record
      Name            : UStrings.UString;
      Slug            : UStrings.UString;
      Author          : UStrings.UString;
      Version         : UStrings.UString;
      Homepage        : UStrings.UString;
      Download_Link   : UStrings.UString;
      Donate_Link     : UStrings.UString;
      Key             : UStrings.UString;
      Requires        : UStrings.UString;
      Requires_PHP    : UStrings.UString;
      Tested          : UStrings.UString;
      Last_Updated    : UStrings.UString;
      External        : Boolean;
      Active_Installs : Natural;
      Rating          : Natural;
      Num_Ratings     : Natural;
      Contributors    : Array_Type;
      Ratings         : Array_Type;
      Banners         : Array_Type;
      Sections        : Array_Type;
   end record;

   function To_Object (Arry : Array_Type) return Plugin_Object_Type
   is (raise Program_Error with "not implemented");

   Null_Plugin_API_Result : constant Plugin_API_Result :=
     (Success     => False,
      External    => False,
      Info        => Empty_Array,
      Plugins     => Empty_Array,
      Arry        => Empty_Array,
      Name | Slug => UStrings.Null_UString,
      Error       => Class_Errors.Null_Wp_Error);

   -- function To_Array (Arry : Plugin_API_Result) return Array_Type;

   function Plugins_API
     (Action : String; Args : Plugin_API_Args := Null_Plugin_API_Args)
      return Plugin_API_Result;

   --
   -- Retrieves popular WordPress plugin tags.
   --
   -- @since 2.7.0
   --
   -- @param array args
   -- @return array|WP_Error
   --
   type Array_Error_Type is record
      Success : Boolean;
      Arry    : Array_Type;
      Error   : Class_Errors.Wp_Error;
   end record;

   function Install_Popular_Tags
     (Args : Array_Type := Empty_Array) return Array_Error_Type;

   --
   -- Displays the Featured tab of Add Plugins screen.
   --
   -- @since 2.7.0
   --
   procedure Install_Dashboard;

   --
   -- Displays a search form for searching plugins.
   --
   -- @since 2.7.0
   -- @since 4.6.0 The `type_selector` parameter was deprecated.
   --
   -- @param bool deprecated Not used.
   --
   procedure Install_Search_Form (Deprecated : Boolean := True);

   --
   -- Displays a form to upload plugins from zip files.
   --
   -- @since 2.8.0
   --
   procedure Install_Plugins_Upload;

   --
   -- Shows a username form for the favorites page.
   --
   -- @since 3.5.0
   --
   procedure Install_Plugins_Favorites_Form;

   function Install_Plugins_Favorites_Form is new
     Helpers_2.Generic_Call_Procedure (Install_Plugins_Favorites_Form);

   --
   -- Displays plugin content based on plugin list.
   --
   -- @since 2.7.0
   --
   -- @global WP_List_Table wp_list_table
   --
   procedure Display_Plugins_Table;

   --
   -- Determines the status we can perform on a plugin.
   --
   -- @since 3.0.0
   --
   -- @param array|object api  Data about the plugin retrieved from the API.
   -- @param bool         loop Optional. Disable further loops. Default false.
   -- @return array then
   --     Plugin installation status data.
   --
   --     @type string status  Status of a plugin. Could be one of "install", "update_available", "latest_installed" or "newer_installed".
   --     @type string url     Plugin installation URL.
   --     @type string version The most recent version of the plugin.
   --     @type string file    Plugin filename relative to the plugins directory.
   -- end;
   --
   function Install_Plugin_Install_Status
     (API : Array_Type; Looop : Boolean := False) return Array_Type;

   --
   -- Displays plugin information in dialog box form.
   --
   -- @since 2.7.0
   --
   -- @global string tab
   --
   procedure Install_Plugin_Information;

   --
   -- Gets the markup for the plugin install action button.
   --
   -- @since 6.5.0
   --
   -- @param string       name           Plugin name.
   -- @param array|object data           then
   --     An array or object of plugin data. Can be retrieved from the API.
   --
   --     @type string   slug             The plugin slug.
   --     @type string[] requires_plugins An array of plugin dependency slugs.
   --     @type string   version          The plugin"s version string. Used when getting the install status.
   -- end;
   -- @param bool         compatible_php   The result of a PHP compatibility check.
   -- @param bool         compatible_wp    The result of a WP compatibility check.
   -- @return string The markup for the dependency row button. An empty string if the user does not have capabilities.
   --
   function Wp_Get_Plugin_Action_Button
     (Name           : String;
      Data           : Array_Type;
      Compatible_PHP : Boolean;
      Compatible_WP  : Boolean) return String;

end Adi_Plugin_Install;
