--
-- List Table API: WP_Theme_Install_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Arrays;
with Lists;

with Adi_Themes;

with Class_Theme_List_Tables;

package Class_Theme_Install_List_Tables is
   use Arrays;
   use Lists;

   --
   -- Core class used to implement displaying themes to install in a list table.
   --
   -- @since 3.1.0
   --
   -- @see WP_Themes_List_Table
   --
   type Wp_Theme_Install_List_Table is
     new Class_Theme_List_Tables.Wp_Themes_List_Table
   with record

      Install_Features : List_Type; -- Array_Type;
   end record;

   overriding
   function X_Construct (Args : Array_Type) return Wp_Theme_Install_List_Table;

   --
   -- @return bool
   --
   function Ajax_User_Can (This : Wp_Theme_Install_List_Table) return Boolean;

   --
   -- @global array  tabs
   -- @global string tab
   -- @global int    paged
   -- @global string type
   -- @global array  theme_field_defaults
   --
   overriding
   procedure Prepare_Items (This : in out Wp_Theme_Install_List_Table);

   --
   --
   procedure No_Items (This : Wp_Theme_Install_List_Table);

   --
   -- @global array tabs
   -- @global string tab
   -- @return array
   --
   -- protected
   function Get_Views (This : Wp_Theme_Install_List_Table) return Array_Type;

   --
   -- Displays the theme install table.
   --
   -- Overrides the parent display() method to provide a different container.
   --
   -- @since 3.1.0
   --
   overriding
   procedure Display (This : in out Wp_Theme_Install_List_Table);

   --
   -- Generates the list table rows.
   --
   -- @since 3.1.0
   --
   procedure Display_Rows (This : in out Wp_Theme_Install_List_Table);

   --
   -- Prints a theme from the WordPress.org API.
   --
   -- @since 3.1.0
   --
   -- @global array themes_allowedtags
   --
   -- @param stdClass theme {
   --     An object that contains theme data returned by the WordPress.org API.
   --
   --     @type string name           Theme name, e.g. "Twenty Twenty-One".
   --     @type string slug           Theme slug, e.g. "twentytwentyone".
   --     @type string version        Theme version, e.g. "1.1".
   --     @type string author         Theme author username, e.g. "melchoyce".
   --     @type string preview_url    Preview URL, e.g. "https://2021.wordpress.net/".
   --     @type string screenshot_url Screenshot URL, e.g. "https://wordpress.org/themes/twentytwentyone/".
   --     @type float  rating         Rating score.
   --     @type int    num_ratings    The number of ratings.
   --     @type string homepage       Theme homepage, e.g. "https://wordpress.org/themes/twentytwentyone/".
   --     @type string description    Theme description.
   --     @type string download_link  Theme ZIP download URL.
   -- }
   --
   procedure Single_Row
     (This  : in out Wp_Theme_Install_List_Table;
      Theme : Adi_Themes.Theme_API_Type); -- Class_Themes.Wp_Theme); -- Array_Type);

   --
   -- Prints the wrapper for the theme installer.
   --
   procedure Theme_Installer (This : Wp_Theme_Install_List_Table);

   --
   -- Prints the wrapper for the theme installer with a provided theme"s data.
   -- Used to make the theme installer work for no-js.
   --
   -- @param stdClass theme A WordPress.org Theme API object.
   --
   procedure Theme_Installer_Single
     (This : Wp_Theme_Install_List_Table; Theme : Adi_Themes.Theme_API_Type); -- Array_Type);

   --
   -- Prints the info for a theme (to be used in the theme installer modal).
   --
   -- @global array themes_allowedtags
   --
   -- @param stdClass theme A WordPress.org Theme API object.
   --
   procedure Install_Theme_Info
     (This : Wp_Theme_Install_List_Table; Theme : Adi_Themes.Theme_API_Type); -- Array_Type);

   --
   -- Send required variables to JavaScript land
   --
   -- @since 3.4.0
   --
   -- @global string tab  Current tab within Themes.Install screen
   -- @global string type Type of search.
   --
   -- @param array extra_args Unused.
   --
   procedure X_JS_Vars
     (This : Wp_Theme_Install_List_Table; Extra_Args : Array_Type);

   --
   -- Checks to see if the theme is already installed.
   --
   -- @since 3.4.0
   --
   -- @param stdClass theme A WordPress.org Theme API object.
   -- @return string Theme status.
   --
   -- private
   function X_Get_Theme_Status
     (This : Wp_Theme_Install_List_Table; Theme : Adi_Themes.Theme_API_Type)
      return String;

end Class_Theme_Install_List_Tables;
