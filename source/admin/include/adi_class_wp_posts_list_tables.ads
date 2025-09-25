--
-- List Table API: WP_Posts_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Adi_Class_Wp_List_Tables;

package Adi_Class_Wp_Posts_List_Tables
is
   procedure Dummy;

   --
   -- Core class used to implement displaying posts in a list table.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table
   --
   type Wp_Posts_List_Table is new Adi_Class_Wp_List_Tables.Wp_List_Table with
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

--         --
--         -- Holds the number of posts for this user.
--         --
--         -- @since 3.1.0
--         -- @var int
--         --
--         private user_posts_count;

--         --
--         -- Holds the number of posts which are sticky.
--         --
--         -- @since 3.1.0
--         -- @var int
--         --
--         private sticky_posts_count = 0;

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
   -- Outputs the hidden row displayed when inline editing
   --
   -- @since 3.1.0
   --
   -- @global string mode List table view mode.
   --
   procedure Inline_Edit (This : Wp_Posts_List_Table)
                          is null;

end Adi_Class_Wp_Posts_List_Tables;
