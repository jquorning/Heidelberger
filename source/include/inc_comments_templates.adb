--
-- Comment template functions
--
-- These functions are meant to live inside of the WordPress loop.
--
-- @package WordPress
-- @subpackage Template
--

with UStrings;
with Wp_Common;

with Inc_Posts;

package body Inc_Comments_Templates
is

   -------------------
   -- Comments_Open --
   -------------------

   function Comments_Open (Post : Class_Posts.Post_Id_Type := 0) -- null
                           return Boolean
   is
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Inc_Posts;

      X_Post : constant Wp_Post := Get_Post (Post);

      Post_Id : constant Class_Posts.Post_Id_Type :=
        (if X_Post /= Null_Post then X_Post.Id else 0);

      Open : constant Boolean :=
        X_Post /= Null_Post and then "open" = X_Post.Comment_Status;
   begin
      --
      -- Filters whether the current post is open for comments.
      --
      -- @since 2.5.0
      --
      -- @param bool open    Whether the current post is open for comments.
      -- @param int  post_id The post ID.
      --
      return Apply_Filters ("comments_open", Open, Post_Id);
   end Comments_Open;

   ----------------
   -- Pings_Open --
   ----------------

   function Pings_Open (Post : Class_Posts.Post_Id_Type := 0) -- null
                        return Boolean
   is
      use UStrings;
      use Wp_Common;
      use Class_Posts;
      use Inc_Posts;

      X_Post : constant Wp_Post := Get_Post (Post);

      Post_Id : constant Class_Posts.Post_Id_Type :=
        (if X_Post /= Null_Post then X_Post.Id else 0);

      Open : constant Boolean :=
        X_Post /= Null_Post and then "open" = X_Post.Ping_Status;
   begin
      --
      -- Filters whether the current post is open for pings.
      --
      -- @since 2.5.0
      --
      -- @param bool open    Whether the current post is open for pings.
      -- @param int  post_id The post ID.
      --
      return Apply_Filters ("pings_open", Open, Post_Id);
   end Pings_Open;

end Inc_Comments_Templates;
