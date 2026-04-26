--
-- List Table API: WP_Plugin_Install_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Arrays;
with UStrings;

with Class_Errors;
with Class_List_Tables;

package Class_Plugin_Install_List_Tables is
   use Arrays;

   --
   -- Core class used to implement displaying plugins to install in a list table.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table
   --
   type Wp_Plugin_Install_List_Table is new Class_List_Tables.Wp_List_Table
   with record
      Order   : UStrings.UString := UStrings.To_UString ("ASC");
      Orderby : UStrings.UString; -- null;
      Groups  : Array_Type;

      Error : Class_Errors.Wp_Error; -- private error;
   end record;

   --
   --
   --
   function X_Construct
     (Args : Array_Type) return Wp_Plugin_Install_List_Table;

   --
   -- @return bool
   --
   function Ajax_User_Can (This : Wp_Plugin_Install_List_Table) return Boolean;

   --
   -- Returns the list of known plugins.
   --
   -- Uses the transient data from the updates API to determine the known
   -- installed plugins.
   --
   -- @since 4.9.0
   -- @access protected
   --
   -- @return array
   --
   -- protected
   function Get_Installed_Plugins
     (This : Wp_Plugin_Install_List_Table) return Array_Type;

   --
   -- Returns a list of slugs of installed plugins, if known.
   --
   -- Uses the transient data from the updates API to determine the slugs of
   -- known installed plugins. This might be better elsewhere, perhaps even
   -- within get_plugins().
   --
   -- @since 4.0.0
   --
   -- @return array
   --
   -- protected
   function Get_Installed_Plugin_Slugs
     (This : Wp_Plugin_Install_List_Table) return Array_Type;

   --
   -- @global array  tabs
   -- @global string tab
   -- @global int    paged
   -- @global string type
   -- @global string term
   --
   overriding
   procedure Prepare_Items (This : in out Wp_Plugin_Install_List_Table);

   --
   --
   procedure No_Items (This : Wp_Plugin_Install_List_Table);

   --
   -- @global array tabs
   -- @global string tab
   --
   -- @return array
   --
   -- protected
   function Get_Views (This : Wp_Plugin_Install_List_Table) return Array_Type;

   --
   -- Overrides parent views so we can use the filter bar display.
   --
   procedure Views (This : Wp_Plugin_Install_List_Table);

   --
   -- Displays the plugin install table.
   --
   -- Overrides the parent display() method to provide a different container.
   --
   -- @since 4.0.0
   --
   procedure Display (This : in out Wp_Plugin_Install_List_Table);

   --
   -- @global string tab
   --
   -- @param string which
   --
   -- protected
   overriding
   procedure Display_Tablenav
     (This : in out Wp_Plugin_Install_List_Table; Which : String);

   --
   -- @return array
   --
   -- protected
   function Get_Table_Classes
     (This : Wp_Plugin_Install_List_Table) return Array_Type;

   --
   -- @return string[] Array of column titles keyed by their column name.
   --
   function Get_Columns (This : Wp_Plugin_Install_List_Table) return Array_Type;

   --
   -- @param object plugin_a
   -- @param object plugin_b
   -- @return int
   --
--   function Order_Callback
--     (This : Wp_Plugin_Install_List_Table; plugin_a, Plugin_B : Integer)
--      return Integer;

   --
   -- Generates the list table rows.
   --
   -- @since 3.1.0
   --
   overriding
   procedure Display_Rows (This : in out Wp_Plugin_Install_List_Table);

   --
   -- Returns a notice containing a list of dependencies required by the plugin.
   --
   -- @since 6.5.0
   --
   -- @param array  plugin_data An array of plugin data. See then@see plugins_api()end;
   --                            for the list of possible values.
   -- @return string A notice containing a list of dependencies required by the plugin,
   --                or an empty string if none is required.
   --
   -- protected
   function Get_Dependencies_Notice
     (This : Wp_Plugin_Install_List_Table; Plugin_Data : Array_Type)
      return String;

   --
   -- Creates a "More details" link for the plugin.
   --
   -- @since 6.5.0
   --
   -- @param string name The plugin"s name.
   -- @param string slug The plugin"s slug.
   -- @return string The "More details" link for the plugin.
   --
   -- protected
   function Get_More_Details_Link
     (This : Wp_Plugin_Install_List_Table; Name : String; Slug : String)
      return String;

end Class_Plugin_Install_List_Tables;
