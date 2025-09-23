--
-- WordPress Post Template Functions.
--
-- Gets content for the current post in the loop.
--
-- @package WordPress
-- @subpackage Template
--

package Inc_Post_Templates
is

--
-- Retrieves the post title.
--
-- If the post is protected and the visitor is not an admin, then "Protected"
-- will be inserted before the post title. If the post is private, then
-- "Private" will be inserted before the post title.
--
-- @since 0.71
--
-- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- @return string
--
   function Get_The_Title (Post : Integer := 0)
                           return String;

end Inc_Post_Templates;
