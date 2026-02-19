--
-- Helper functions for displaying a list of items in an ajaxified HTML table.
--
-- @package WordPress
-- @subpackage List_Table
-- @since 3.1.0
--

with Adi_Class_Wp_Terms_List_Tables;
with Adi_Class_Wp_Posts_List_Tables;

package body Adi_List_Tables
is

-- --
-- -- Fetches an instance of a WP_List_Table class.
-- --
-- -- @since 3.1.0
-- --
-- -- @global string hook_suffix
-- --
-- -- @param string class_name The type of the list table, which is the class name.
-- -- @param array  args       Optional. Arguments to pass to the class. Accepts "screen".
-- -- @return WP_List_Table|false List table object on success, false if the class does not exist.
-- --
-- function _get_list_table( class_name, args = array() ) then
   function X_Get_List_Table (Class_Name : String;
                              Args       : Array_Type := Empty_Array)
                              return Class_List_Tables.Wp_List_Table'Class
   is
   begin

      if Class_Name = "Wp_Posts_List_Table" then
         return Adi_Class_Wp_Posts_List_Tables.X_Construct;

      elsif Class_Name = "Wp_Terms_List_Table" then
         return Adi_Class_Wp_Terms_List_Tables.X_Construct;

      end if;
      raise Program_Error;
   end X_Get_List_Table;
--         core_classes = array(
--                 -- Site Admin.
--                 "WP_Posts_List_Table"                         => "posts",
--                 "WP_Media_List_Table"                         => "media",
--                 "WP_Terms_List_Table"                         => "terms",
--                 "WP_Users_List_Table"                         => "users",
--                 "WP_Comments_List_Table"                      => "comments",
--                 "WP_Post_Comments_List_Table"                 => array( "comments", "post-comments" ),
--                 "WP_Links_List_Table"                         => "links",
--                 "WP_Plugin_Install_List_Table"                => "plugin-install",
--                 "WP_Themes_List_Table"                        => "themes",
--                 "WP_Theme_Install_List_Table"                 => array( "themes", "theme-install" ),
--                 "WP_Plugins_List_Table"                       => "plugins",
--                 "WP_Application_Passwords_List_Table"         => "application-passwords",

--                 -- Network Admin.
--                 "WP_MS_Sites_List_Table"                      => "ms-sites",
--                 "WP_MS_Users_List_Table"                      => "ms-users",
--                 "WP_MS_Themes_List_Table"                     => "ms-themes",

--                 -- Privacy requests tables.
--                 "WP_Privacy_Data_Export_Requests_List_Table"  => "privacy-data-export-requests",
--                 "WP_Privacy_Data_Removal_Requests_List_Table" => "privacy-data-removal-requests",
--         );

--         if ( isset( core_classes[ class_name ] ) ) then
--                 foreach ( (array) core_classes[ class_name ] as required ) then
--                         require_once ABSPATH . "wp-admin/includes/class-wp-" . required . "-list-table.php";
--                 end;

--                 if ( isset( args["screen"] ) ) then
--                         args["screen"] = convert_to_screen( args["screen"] );
--                 end; elseif ( isset( GLOBALS["hook_suffix"] ) ) then
--                         args["screen"] = get_current_screen();
--                 end; else then
--                         args["screen"] = null;
--                 end;

--                 --
--                 -- Filters the list table class to instantiate.
--                 --
--                 -- @since 6.1.0
--                 --
--                 -- @param string class_name The list table class to use.
--                 -- @param array  args       An array containing _get_list_table() arguments.
--                 --
--                 custom_class_name = apply_filters( "wp_list_table_class_name", class_name, args );

--                 if ( is_string( custom_class_name ) && class_exists( custom_class_name ) ) then
--                         class_name = custom_class_name;
--                 end;

--                 return new class_name( args );
--         end;

--         return false;
-- end;

-- --
-- -- Register column headers for a particular screen.
-- --
-- -- @see get_column_headers(), print_column_headers(), get_hidden_columns()
-- --
-- -- @since 2.7.0
-- --
-- -- @param string    screen The handle for the screen to register column headers for. This is
-- --                          usually the hook name returned by the `add_*_page()` functions.
-- -- @param string[] columns An array of columns with column IDs as the keys and translated
-- --                          column names as the values.
-- --
-- function register_column_headers( screen, columns ) then
--         new _WP_List_Table_Compat( screen, columns );
-- end;

-- --
-- -- Prints column headers for a particular screen.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string|WP_Screen screen  The screen hook name or screen object.
-- -- @param bool             with_id Whether to set the ID attribute or not.
-- --
-- function print_column_headers( screen, with_id = true ) then
--         wp_list_table = new _WP_List_Table_Compat( screen );

--         wp_list_table.print_column_headers( with_id );
-- end;

end Adi_List_Tables;
