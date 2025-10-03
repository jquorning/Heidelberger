--
-- Administration API: WP_List_Table class
--
-- @package WordPress
-- @subpackage List_Table
-- @since 3.1.0
--

with Ada.Strings.Unbounded;

with Arrays;

with Adi_Class_Wp_Screens;

package Adi_Class_Wp_List_Tables
is
   use Ada.Strings.Unbounded;
   use Arrays;

   procedure Dummy;

   --
   -- Base class for displaying a list of items in an ajaxified HTML table.
   --
   -- @since 3.1.0
   --
-- #[AllowDynamicProperties]
   type Wp_List_Table is tagged
      record

--         --
--         -- The current list of items.
--         --
--         -- @since 3.1.0
--         -- @var array
--         --
--         public items;

--         --
--         -- Various information about the current table.
--         --
--         -- @since 3.1.0
--         -- @var array
--         --
--         protected _args;

--         --
--         -- Various information needed for displaying the pagination.
--         --
--         -- @since 3.1.0
--         -- @var array
--         --
--         protected _pagination_args = array();

--         --
--         -- The current screen.
--         --
--         -- @since 3.1.0
--         -- @var WP_Screen
--         --
--         protected
          Screen : Adi_Class_Wp_Screens.Wp_Screen;

--         --
--         -- Cached bulk actions.
--         --
--         -- @since 3.1.0
--         -- @var array
--         --
--         private _actions;

--         --
--         -- Cached pagination output.
--         --
--         -- @since 3.1.0
--         -- @var string
--         --
         X_Pagination : Unbounded_String;

--         --
--         -- The view switcher modes.
--         --
--         -- @since 4.1.0
--         -- @var array
--         --
--         protected modes = array();

--         --
--         -- Stores the value returned by .get_column_info().
--         --
--         -- @since 4.1.0
--         -- @var array
--         --
--         protected _column_headers;

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
   -- @param string key Pagination argument to retrieve. Common values include "total_items",
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
                       return Boolean
                       is (True);

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
   -- Gets the current action selected from the bulk actions dropdown.
   --
   -- @since 3.1.0
   --
   -- @return string|false The action name. False if no action was selected.
   --
   function Current_Action (This : Wp_List_Table)
                            return String
                            is ("XXX-448");

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
   -- Displays the table.
   --
   -- @since 3.1.0
   --
   procedure Display (This : Wp_List_Table)
                      is null;

end Adi_Class_Wp_List_Tables;
