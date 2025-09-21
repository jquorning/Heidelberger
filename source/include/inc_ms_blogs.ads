--
-- Site/blog functions that work with the blogs table and related data.
--
-- @package WordPress
-- @subpackage Multisite
-- @since MU (3.0.0)
--

package Inc_Ms_Blogs
is
   procedure Dummy;
--
-- Switch the current blog.
--
-- This function is useful if you need to pull posts, or other information,
-- from other blogs. You can switch back afterwards using restore_current_blog().
--
-- Things that aren"t switched:
--  - plugins. See #14941
--
-- @see restore_current_blog()
-- @since MU (3.0.0)
--
-- @global wpdb            wpdb               WordPress database abstraction object.
-- @global int             blog_id
-- @global array           _wp_switched_stack
-- @global bool            switched
-- @global string          table_prefix
-- @global WP_Object_Cache wp_object_cache
--
-- @param int  new_blog_id The ID of the blog to switch to. Default: current blog.
-- @param bool deprecated  Not used.
-- @return true Always returns true.
--
   function Switch_To_Blog (New_Blog_Id : Integer;
                            Deprecated  : Boolean := False) -- = null
                            return Boolean
                            is (True);

--
-- Restore the current blog, after calling switch_to_blog().
--
-- @see switch_to_blog()
-- @since MU (3.0.0)
--
-- @global wpdb            wpdb               WordPress database abstraction object.
-- @global array           _wp_switched_stack
-- @global int             blog_id
-- @global bool            switched
-- @global string          table_prefix
-- @global WP_Object_Cache wp_object_cache
--
-- @return bool True on success, false if we"re already on the current blog.
--
   function Restore_Current_Blog
            return Boolean
            is (True);

end Inc_Ms_Blogs;
