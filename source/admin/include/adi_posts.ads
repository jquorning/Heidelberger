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
