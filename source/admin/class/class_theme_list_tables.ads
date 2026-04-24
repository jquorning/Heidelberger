--
-- List Table API: WP_Themes_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Arrays;
with Lists;

with Class_List_Tables;
with Class_Themes;

package Class_Theme_List_Tables is
   use Arrays;
   use Lists;

   --
   -- Core class used to implement displaying installed themes in a list table.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table
   --
   type Wp_Themes_List_Table is new Class_List_Tables.Wp_List_Table with record
      -- protected
      Search_Terms : List_Type; -- Array_Type;

      -- public
      Features : List_Type; -- Array_Type;
   end record;

   --
   -- Constructor.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table::__construct() for more information on default arguments.
   --
   -- @param array $args An associative array of arguments.
   --
   function X_Construct (Args : Array_Type) return Wp_Themes_List_Table;

   --
   -- @return bool
   --
   function Ajax_User_Can (This : Wp_Themes_List_Table) return Boolean;

   --
   --
   overriding
   procedure Prepare_Items (This : in out Wp_Themes_List_Table);

   --
   --
   procedure No_Items (This : Wp_Themes_List_Table);

   --
   -- @param string which
   --
   procedure Tablenav (This : in out Wp_Themes_List_Table; Which : String := "top");

   --
   -- Displays the themes table.
   --
   -- Overrides the parent display() method to provide a different container.
   --
   -- @since 3.1.0
   --
   procedure Display (This : in out Wp_Themes_List_Table);

   --
   -- @return string[] Array of column titles keyed by their column name.
   --
   function Get_Columns (This : Wp_Themes_List_Table) return List_Type;

   --
   --
   overriding
   procedure Display_Rows_Or_Placeholder (This : in out Wp_Themes_List_Table);

   --
   -- Generates the list table rows.
   --
   -- @since 3.1.0
   --
   overriding
   procedure Display_Rows (This : in out Wp_Themes_List_Table);

   --
   -- @param WP_Theme theme
   -- @return bool
   --
   function Search_Theme
     (This : Wp_Themes_List_Table; Theme : in out Class_Themes.Wp_Theme)
      return Boolean;

   --
   -- Send required variables to JavaScript land
   --
   -- @since 3.4.0
   --
   -- @param array extra_args
   --
   procedure X_JS_Vars (This : Wp_Themes_List_Table; Extra_Args : Array_Type);

end Class_Theme_List_Tables;
