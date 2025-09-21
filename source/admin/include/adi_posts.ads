--
-- WordPress Post Administration API.
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;

package Adi_Posts
is
   use Arrays;

   procedure Dummy;
--
-- Processes the post data for the bulk editing of posts.
--
-- Updates all bulk edited posts/pages, adding (but not removing) tags and
-- categories. Skips pages when they would be their own parent or child.
--
-- @since 2.7.0
--
-- @global wpdb $wpdb WordPress database abstraction object.
--
-- @param array|null $post_data Optional. The array of post data to process.
--                              Defaults to the `$_POST` superglobal.
-- @return array
--
   function Bulk_Edit_Posts (Post_Data : Array_Type := Empty_Array) -- = null
                             return Array_Type
                             is (Empty_Array);

--
-- Marks the post as currently being edited by the current user.
--
-- @since 2.5.0
--
-- @param int|WP_Post $post ID or object of the post being edited.
-- @return array|false then
--     Array of the lock time and user ID. False if the post does not exist, or there
--     is no current user.
--
--     @type int $0 The current time as a Unix timestamp.
--     @type int $1 The ID of the current user.
-- end;
--
   function Wp_Set_Post_Lock (Post : Integer)
                              return Array_Type
                              is (Empty_Array);

--
-- Determines whether the post is currently being edited by another user.
--
-- @since 2.5.0
--
-- @param int|WP_Post $post ID or object of the post to check for editing.
-- @return int|false ID of the user with lock. False if the post does not exist, post is not locked,
--                   the user with lock does not exist, or the post is locked by current user.
--
-- function wp_check_post_lock( $post ) then

   function Wp_Check_Post_Lock (Post_Id : Assoc_Type) return Boolean is (True);
   function Wp_Check_Post_Lock (Post_Id : String)     return Integer is (1);


end Adi_Posts;
