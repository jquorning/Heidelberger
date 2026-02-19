--
-- Administration API: WP_List_Table class
--
-- @package WordPress
-- @subpackage List_Table
-- @since 3.1.0
--

with Arrays;
with Lists;
with UStrings;

with Class_Screens;

package Class_List_Tables
is
   use Arrays;
   use Lists;

   type Columns_Type is
      record
         Columns  : Array_Type;
         Hidden   : Array_Type;
         Sortable : Array_Type;
         Primary  : UStrings.UString;
      end record;

   --
   -- Base class for displaying a list of items in an ajaxified HTML table.
   --
   -- @since 3.1.0
   --
-- #[AllowDynamicProperties]
   type Wp_List_Table is tagged
      record

         --
         -- The current list of items.
         --
         -- @since 3.1.0
         -- @var array
         --
         Items : Array_Type;

         --
         -- Various information about the current table.
         --
         -- @since 3.1.0
         -- @var array
         --
         -- protected
         X_Args : Array_Type;

         --
         -- Various information needed for displaying the pagination.
         --
         -- @since 3.1.0
         -- @var array
         --
         -- protected
         X_Pagination_Args : Array_Type;

         --
         -- The current screen.
         --
         -- @since 3.1.0
         -- @var WP_Screen
         --
--         protected
          Screen : Class_Screens.Wp_Screen;

         --
         -- Cached bulk actions.
         --
         -- @since 3.1.0
         -- @var array
         --
         -- private
         X_Actions : Array_Type;

         --
         -- Cached pagination output.
         --
         -- @since 3.1.0
         -- @var string
         --
         X_Pagination : UStrings.UString;

         --
         -- The view switcher modes.
         --
         -- @since 4.1.0
         -- @var array
         --
         -- protected
         Modes : Array_Type;

         --
         -- Stores the value returned by .get_column_info().
         --
         -- @since 4.1.0
         -- @var array
         --
         -- protected
         X_Column_Headers : Columns_Type; -- Array_Type;

--         --
--         -- then@internal Missing Summaryend;
--         --
--         -- @var array
--         --
--         protected compat_fields = array( "_args", "_pagination_args", "screen", "_actions", "_pagination" );

--         --
--         -- then@internal Missing Summaryend;
--         --
--         -- @var array
--         --
--         protected compat_methods = array(
--                 "set_pagination_args",
--                 "get_views",
--                 "get_bulk_actions",
--                 "bulk_actions",
--                 "row_actions",
--                 "months_dropdown",
--                 "view_switcher",
--                 "comments_bubble",
--                 "get_items_per_page",
--                 "pagination",
--                 "get_sortable_columns",
--                 "get_column_info",
--                 "get_table_classes",
--                 "display_tablenav",
--                 "extra_tablenav",
--                 "single_row_columns",
--         );
      end record;

   --
   -- Constructor.
   --
   -- The child class should call this constructor from its own constructor to override
   -- the default args.
   --
   -- @since 3.1.0
   --
   -- @param array|string args {
   --     Array or string of arguments.
   --
   --     @type string plural   Plural value used for labels and the objects being
   --                            listed. This affects things such as CSS class-names
   --                            and nonces used in the list table, e.g. "posts".
   --                            Default empty.
   --     @type string singular Singular label for an object being listed, e.g. "post".
   --                            Default empty
   --     @type bool   ajax     Whether the list table supports Ajax. This includes
   --                            loading and sorting data, for example. If true, the
   --                            class will call the _js_vars() method in the footer
   --                            to provide variables to any scripts handling Ajax
   --                            events. Default false.
   --     @type string screen   String containing the hook name used to determine the
   --                            current screen. If left null, the current screen
   --                            will be automatically set. Default null.
   -- }
   --
   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_List_Table;

   --
   -- Prepares the list of items for displaying.
   --
   -- @uses WP_List_Table::set_pagination_args()
   --
   -- @since 3.1.0
   -- @abstract
   --
   procedure Prepare_Items (This : Wp_List_Table)
                            is null;

   --
   -- Access the pagination args.
   --
   -- @since 3.1.0
   --
   -- @param string key Pagination argument to retrieve. Common values include
   --                   "total_items",
   --                    "total_pages", "per_page", or "infinite_scroll".
   -- @return int Number of items that correspond to the given pagination argument.
   --
   function Get_Pagination_Arg (This : Wp_List_Table;
                                Key  : String)
                                return Natural
                                is (0);

   --
   -- Whether the table has items to display or not
   --
   -- @since 3.1.0
   --
   -- @return bool
   --
   function Has_Items (This : Wp_List_Table)
                       return Boolean;

   --
   -- Message to be displayed when there are no items
   --
   -- @since 3.1.0
   --
   procedure No_Items (This : Wp_List_Table);

   --
   -- Displays the search box.
   --
   -- @since 3.1.0
   --
   -- @param string text     The "submit" button label.
   -- @param string input_id ID attribute value for the search input field.
   --
   procedure Search_Box (This     : Wp_List_Table;
                         Text     : String;
                         Input_Id : String);

   --
   -- Gets the list of views available on this table.
   --
   -- The format is an associative array:
   -- - `"id" => "link"`
   --
   -- @since 3.1.0
   --
   -- @return array
   --
   -- protected
   function Get_Views (This : Wp_List_Table)
            return Array_Type;

   --
   -- Displays the list of views available on this table.
   --
   -- @since 3.1.0
   --
   procedure Views (This : Wp_List_Table);

   --
   -- Retrieves the list of bulk actions available for this table.
   --
   -- The format is an associative array where each element represents either a top
   -- level option value and label, or an array representing an optgroup and its
   -- options.
   --
   -- For a standard option, the array element key is the field value and the array
   -- element value is the field label.
   --
   -- For an optgroup, the array element key is the label and the array element value
   -- is an associative array of options as above.
   --
   -- Example:
   --
   --     [
   --         "edit"         => "Edit",
   --         "delete"       => "Delete",
   --         "Change State" => [
   --             "feature" => "Featured",
   --             "sale"    => "On Sale",
   --         ]
   --     ]
   --
   -- @since 3.1.0
   -- @since 5.6.0 A bulk action can now contain an array of options in order to
   --              create an optgroup.
   --
   -- @return array
   --
   -- protected
   function Get_Bulk_Actions (This : Wp_List_Table)
                              return Array_Type;

   --
   -- Gets the current action selected from the bulk actions dropdown.
   --
   -- @since 3.1.0
   --
   -- @return string|false The action name. False if no action was selected.
   --
   function Current_Action (This : Wp_List_Table)
                            return String
                            is ("XXX-450");

   --
   -- Gets the current page number.
   --
   -- @since 3.1.0
   --
   -- @return int
   --
   function Get_Pagenum (This : Wp_List_Table)
                         return Natural
                         is (1);

   --
   -- Returns the number of visible columns.
   --
   -- @since 3.1.0
   --
   -- @return int
   --
   function Get_Column_Count (This : in out Wp_List_Table)
                              return Natural;

   --
   -- Prints column headers, accounting for hidden and sortable columns.
   --
   -- @since 3.1.0
   --
   -- @param bool with_id Whether to set the ID attribute or not
   --
   procedure Print_Column_Headers (This    : in out Wp_List_Table;
                                   With_Id : Boolean := True);

   --
   -- Displays the bulk actions dropdown.
   --
   -- @since 3.1.0
   --
   -- @param string which The location of the bulk actions: "top" or "bottom".
   --                      This is designated as optional for backward compatibility.
   --
   -- protected
   procedure Bulk_Actions (This  : in out Wp_List_Table;
                           Which : String := "");

   --
   -- Gets the name of the default primary column.
   --
   -- @since 4.3.0
   --
   -- @return string Name of the default primary column, in this case, an empty string.
   --
   -- protected
   function Get_Default_Primary_Column_Name (This : Wp_List_Table)
                                             return String;

   --
   -- Gets the name of the primary column.
   --
   -- @since 4.3.0
   --
   -- @return string The name of the primary column.
   --
   -- protected
   function Get_Primary_Column_Name (This : Wp_List_Table)
                                     return String;

   --
   -- Gets a list of all, hidden, and sortable columns, with filter applied.
   --
   -- @since 3.1.0
   --
   -- @return array
   --
   -- protected
   function Get_Column_Info (This : in out Wp_List_Table)
                             return Columns_Type; -- Array_Type;

   --
   -- Displays the table.
   --
   -- @since 3.1.0
   --
   procedure Display (This : in out Wp_List_Table);

   --
   -- Gets a list of CSS classes for the WP_List_Table table tag.
   --
   -- @since 3.1.0
   --
   -- @return string[] Array of CSS classes for the table tag.
   --
   -- protected
   function Get_Table_Classes (This : Wp_List_Table)
                               return List_Type;

   --
   -- Generates the table navigation above or below the table
   --
   -- @since 3.1.0
   -- @param string which
   --
   -- protected
   procedure Display_Tablenav (This  : in out Wp_List_Table;
                               Which : String);

   --
   -- Extra controls to be displayed between bulk actions and pagination.
   --
   -- @since 3.1.0
   --
   -- @param string which
   --
   -- protected
   procedure Extra_Tablenav (This  : Wp_List_Table;
                             Which : String);

   --
   -- Generates the tbody element for the list table.
   --
   -- @since 3.1.0
   --
   procedure Display_Rows_Or_Placeholder (This : in out Wp_List_Table);

   --
   -- Generates the table rows.
   --
   -- @since 3.1.0
   --
   procedure Display_Rows (This : in out Wp_List_Table);

   --
   -- Generates content for a single row of the table.
   --
   -- @since 3.1.0
   --
   -- @param object|array item The current item
   --
   procedure Single_Row (This : in out Wp_List_Table;
                         Item : Array_Type);

   --
   -- @param object|array item
   -- @param string column_name
   --
   -- protected
   procedure Column_Default (This        : Wp_List_Table;
                             Item        : Array_Type;
                             Column_Name : String);

   --
   -- @param object|array item
   --
   -- protected
   procedure Column_CB (This : Wp_List_Table;
                        Item : Array_Type);

   --
   -- Generates the columns for a single row of the table.
   --
   -- @since 3.1.0
   --
   -- @param object|array item The current item.
   --
   -- protected
   procedure Single_Row_Columns (This : in out Wp_List_Table;
                                 Item : Array_Type);

   --
   -- Generates and display row actions links for the list table.
   --
   -- @since 4.3.0
   --
   -- @param object|array item        The item being acted upon.
   -- @param string       column_name Current column name.
   -- @param string       primary     Primary column name.
   -- @return string The row actions HTML, or an empty string
   --                if the current column is not the primary column.
   --
   -- protected
   function Handle_Row_Actions (This        : Wp_List_Table;
                                Item        : Array_Type;
                                Column_Name : String;
                                Primary     : String)
                                return String;

   --
   -- Displays the pagination.
   --
   -- @since 3.1.0
   --
   -- @param string which
   --
   -- protected
   procedure Pagination (This  : in out Wp_List_Table;
                         Which : String);

   --
   -- Gets a list of columns.
   --
   -- The format is:
   -- - `"internal-name" => "Title"`
   --
   -- @since 3.1.0
   -- @abstract
   --
   -- @return array
   --
   function Get_Columns (This : Wp_List_Table)
                         return Array_Type;

   --
   -- Gets a list of sortable columns.
   --
   -- The format is:
   -- - `"internal-name" => "orderby"`
   -- - `"internal-name" => array( "orderby", "asc" )` - The second element sets the
   --                                                    initial sorting order.
   -- - `"internal-name" => array( "orderby", true )`  - The second element makes the
   --                                                    initial order descending.
   --
   -- @since 3.1.0
   --
   -- @return array
   --
   -- protected
   function Get_Sortable_Columns (This : Wp_List_Table)
                                  return Array_Type;

end Class_List_Tables;
