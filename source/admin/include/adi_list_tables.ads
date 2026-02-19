--
-- Helper functions for displaying a list of items in an ajaxified HTML table.
--
-- @package WordPress
-- @subpackage List_Table
-- @since 3.1.0
--

with Class_List_Tables;

with Arrays;

package Adi_List_Tables
is
   use Arrays;

   --
   -- Fetches an instance of a WP_List_Table class.
   --
   -- @since 3.1.0
   --
   -- @global string hook_suffix
   --
   -- @param string class_name The type of the list table, which is the class name.
   -- @param array  args       Optional. Arguments to pass to the class. Accepts "screen".
   -- @return WP_List_Table|false List table object on success, false if the class does not exist.
   --
   function X_Get_List_Table (Class_Name : String;
                              Args       : Array_Type := Empty_Array)
                              return Class_List_Tables.Wp_List_Table'Class;

end Adi_List_Tables;
