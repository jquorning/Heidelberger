--
-- List Table API: WP_Posts_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Arrays;

with Class_List_Tables;

package Adi_Class_Wp_Posts_List_Tables
is
   use Arrays;

   --
   -- Core class used to implement displaying posts in a list table.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table
   --
   type Wp_Posts_List_Table is new Class_List_Tables.Wp_List_Table with
      record

--         --
--         -- Whether the items should be displayed hierarchically or linearly.
--         --
--         -- @since 3.1.0
--         -- @var bool
--         --
--         protected
           Hierarchical_Display : Boolean;

--         --
--         -- Holds the number of pending comments for each post.
--         --
--         -- @since 3.1.0
--         -- @var array
--         --
--         protected comment_pending_count;

         --
         -- Holds the number of posts for this user.
         --
         -- @since 3.1.0
         -- @var int
         --
         -- private
         User_Posts_Count : Natural;

         --
         -- Holds the number of posts which are sticky.
         --
         -- @since 3.1.0
         -- @var int
         --
         -- private
         Sticky_Posts_Count : Natural := 0;

--         private is_trash;

--         --
--         -- Current level for output.
--         --
--         -- @since 4.3.0
--         -- @var int
--         --
--         protected current_level = 0;

      end record;

   --
   -- Constructor.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table::__construct() for more information on default arguments.
   --
   -- @global WP_Post_Type post_type_object
   -- @global wpdb         wpdb             WordPress database abstraction object.
   --
   -- @param array args An associative array of arguments.
   --
   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_Posts_List_Table;

   --
   -- Outputs the hidden row displayed when inline editing
   --
   -- @since 3.1.0
   --
   -- @global string mode List table view mode.
   --
   procedure Inline_Edit (This : Wp_Posts_List_Table)
                          is null;

end Adi_Class_Wp_Posts_List_Tables;
