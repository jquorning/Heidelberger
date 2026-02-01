--
-- WordPress Post Template Functions.
--
-- Gets content for the current post in the loop.
--
-- @package WordPress
-- @subpackage Template
--

with Arrays;

with Class_Posts;

package Inc_Post_Templates
is
   use Arrays;

   --
   -- Retrieves the ID of the current item in the WordPress Loop.
   --
   -- @since 2.1.0
   --
   -- @return int|false The ID of the current item in the WordPress Loop. False if
   --                   post is not set.
   --
   function Get_The_Id
            return Class_Posts.Post_Id_Type;

   --
   -- Retrieves the post title.
   --
   -- If the post is protected and the visitor is not an admin, then "Protected"
   -- will be inserted before the post title. If the post is private, then
   -- "Private" will be inserted before the post title.
   --
   -- @since 0.71
   --
   -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global
   --                          post.
   -- @return string
   --
   function Get_The_Title (Post : Integer := 0)
                           return String
                           is ("XXX-604");

   --
   -- Sanitizes the current title when retrieving or displaying.
   --
   -- Works like the_title(), except the parameters can be in a string or
   -- an array. See the function for what can be override in the args parameter.
   --
   -- The title before it is displayed will have the tags stripped and esc_attr()
   -- before it is passed to the user or displayed. The default as with the_title(),
   -- is to display the title.
   --
   -- @since 2.3.0
   --
   -- @param string|array args {
   --     Title attribute arguments. Optional.
   --
   --     @type string  before Markup to prepend to the title. Default empty.
   --     @type string  after  Markup to append to the title. Default empty.
   --     @type bool    echo   Whether to echo or return the title. Default true for
   --                          echo.
   --     @type WP_Post post   Current post object to retrieve the title for.
   -- }
   -- @return void|string Void if "echo" argument is true, the title attribute if
   --                     "echo" is false.
   --
   function The_Title_Attribute (Args : Array_Type) -- ""
                                 return String;

end Inc_Post_Templates;
