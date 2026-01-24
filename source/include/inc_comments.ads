
--
-- Core Comment API
--
-- @package WordPress
-- @subpackage Comment
--

with Class_Comments;

package Inc_Comments
is

   type Comment_Counts is
      record
         Approved            : Natural;
         Moderated           : Natural;
         Awaiting_Moderation : Natural;
         Spam                : Natural;
         Post_Trashed        : Natural;
         Total_Comments      : Natural;
         All_Pend_Appov      : Natural;
      end record;

   --
   -- Retrieves comment data given a comment ID or comment object.
   --
   -- If an object is passed then the comment data will be cached and then returned
   -- after being passed through a filter. If the comment is empty, then the global
   -- comment variable will be used, if it is set.
   --
   -- @since 2.0.0
   --
   -- @global WP_Comment comment Global comment object.
   --
   -- @param WP_Comment|string|int comment Comment to retrieve.
   -- @param string                output  Optional. The required return type. One of
   --                                       OBJECT, ARRAY_A, or ARRAY_N, which
   --                                       correspond to a WP_Comment object, an
   --                                       associative array, or a numeric array,
   --                                       respectively. Default OBJECT.
   -- @return WP_Comment|array|null Depends on output value.
   --
   function Get_Comment (Comment : Integer := 0; -- null
                         Output  : String  := "OBJECT")
                         return Class_Comments.Wp_Comment;

   --
   -- Retrieves the total comment counts for the whole site or a single post.
   --
   -- @since 2.0.0
   --
   -- @param int post_id Optional. Restrict the comment counts to the given post.
   --                     Default 0, which indicates that comment counts for the
   --                     whole site will be retrieved.
   -- @return int[] {
   --     The number of comments keyed by their status.
   --
   --     @type int approved            The number of approved comments.
   --     @type int awaiting_moderation The number of comments awaiting moderation
   --                                    (a.k.a. pending).
   --     @type int spam                The number of spam comments.
   --     @type int trash               The number of trashed comments.
   --     @type int post-trashed        The number of comments for posts that are in
   --                                    the trash.
   --     @type int total_comments      The total number of non-trashed comments,
   --                                    including spam.
   --     @type int all                 The total number of pending or approved
   --                                    comments.
   -- }
   --
   function Get_Comment_Count (Post_Id : Integer := 0)
                               return Comment_Counts;

   --
   -- Gets the default comment status for a post type.
   --
   -- @since 4.3.0
   --
   -- @param string post_type    Optional. Post type. Default "post".
   -- @param string comment_type Optional. Comment type. Default "comment".
   -- @return string Expected return value is "open" or "closed".
   --
   function Get_Default_Comment_Status (Post_Type    : String := "post";
                                        Comment_Type : String := "comment")
                                        return String
                                        is ("XXX-447");

   --
   -- Retrieves the total comment counts for the whole site or a single post.
   --
   -- The comment stats are cached and then retrieved, if they already exist in the
   -- cache.
   --
   -- @see get_comment_count() Which handles fetching the live comment counts.
   --
   -- @since 2.5.0
   --
   -- @param int post_id Optional. Restrict the comment counts to the given post.
   --                     Default 0, which indicates that comment counts for the
   --                     whole site will be retrieved.
   -- @return stdClass {
   --     The number of comments keyed by their status.
   --
   --     @type int approved       The number of approved comments.
   --     @type int moderated      The number of comments awaiting moderation
   --                               (a.k.a. pending).
   --     @type int spam           The number of spam comments.
   --     @type int trash          The number of trashed comments.
   --     @type int post-trashed   The number of comments for posts that are in the
   --                               trash.
   --     @type int total_comments The total number of non-trashed comments,
   --                               including spam.
   --     @type int all            The total number of pending or approved comments.
   -- }
   --
   function Wp_Count_Comments (Post_Id : Integer := 0)
                               return Comment_Counts;

   Null_Comment_Counts : constant Comment_Counts :=
     (others => 0);

end Inc_Comments;
