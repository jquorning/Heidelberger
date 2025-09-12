with Inc_Class_Wp_Terms;
with Inc_Class_Posts;
with Inc_Taxonomys;

package Inc_Category_Templates
is
   No_Terms : exception;
   Error    : exception;
--
-- Retrieves the terms of the taxonomy that are attached to the post.
--
-- @since 2.5.0
--
-- @param int|WP_Post $post     Post ID or object.
-- @param string      $taxonomy Taxonomy name.
-- @return WP_Term[]|false|WP_Error Array of WP_Term objects on success, false if there are no terms
--                                  or the post does not exist, WP_Error on failure.
--
   function Get_The_Terms (Post     : Inc_Class_Posts.Wp_Post;
                           Taxonomy : String)
                           return Inc_Class_Wp_Terms.Wp_Term_Array;
                            -- Inc_Class_Posts.Wp_Post;

end Inc_Category_Templates;
