
--
-- Core Comment API
--
-- @package WordPress
-- @subpackage Comment
--

with Class_Comments;
with Class_Errors;

with Arrays;

package Inc_Comments
is
   use Arrays;

   type Comment_Counts_Type is
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
   -- Retrieves a list of comments.
   --
   -- The comment list can be for the blog as a whole or for an individual post.
   --
   -- @since 2.7.0
   --
   -- @param string|array args Optional. Array or string of arguments. See
   --                          WP_Comment_Query::__construct() for information on
   --                          accepted arguments. Default empty.
   -- @return WP_Comment[]|int[]|int List of comments or number of found comments
   --                                if `count` argument is true.
   --
   function Get_Comments (Args : Array_Type) -- String := "")
                          return Class_Comments.Comments_List;

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
                               return Comment_Counts_Type;

   --
   -- Adds a new comment to the database.
   --
   -- Filters new comment to ensure that the fields are sanitized and valid before
   -- inserting comment into database. Calls {@see "comment_post"} action with comment
   -- ID and whether comment is approved by WordPress. Also has {@see
   -- "preprocess_comment"} filter for processing the comment data before the function
   -- handles it.
   --
   -- We use `REMOTE_ADDR` here directly. If you are behind a proxy, you should ensure
   -- that it is properly set, such as in wp-config.php, for your environment.
   --
   -- See {@link https://core.trac.wordpress.org/ticket/9235}
   --
   -- @since 1.5.0
   -- @since 4.3.0 Introduced the `comment_agent` and `comment_author_IP` arguments.
   -- @since 4.7.0 The `avoid_die` parameter was added, allowing the function
   --              to return a WP_Error object instead of dying.
   -- @since 5.5.0 The `avoid_die` parameter was renamed to `wp_error`.
   -- @since 5.5.0 Introduced the `comment_type` argument.
   --
   -- @see wp_insert_comment()
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param array commentdata {
   --     Comment data.
   --
   --     @type string comment_author       The name of the comment author.
   --     @type string comment_author_email The comment author email address.
   --     @type string comment_author_url   The comment author URL.
   --     @type string comment_content      The content of the comment.
   --     @type string comment_date         The date the comment was submitted.
   --                                       Default is the current time.
   --     @type string comment_date_gmt     The date the comment was submitted in the
   --                                       GMT timezone. Default is `comment_date`
   --                                       in the GMT timezone.
   --     @type string comment_type         Comment type. Default "comment".
   --     @type int    comment_parent       The ID of this comment"s parent, if any.
   --                                       Default 0.
   --     @type int    comment_post_ID      The ID of the post that relates to the
   --                                       comment.
   --     @type int    user_id              The ID of the user who submitted the
   --                                       comment. Default 0.
   --     @type int    user_ID              Kept for backward-compatibility. Use
   --                                       `user_id` instead.
   --     @type string comment_agent        Comment author user agent. Default is the
   --                                       value of "HTTP_USER_AGENT" in the
   --                                       `_SERVER` superglobal sent in the original
   --                                       request.
   --     @type string comment_author_IP    Comment author IP address in IPv4 format.
   --                                       Default is the value of "REMOTE_ADDR" in
   --                                       the `_SERVER` superglobal sent in the
   --                                       original request.
   -- }
   -- @param bool  wp_error Should errors be returned as WP_Error objects instead of
   --                        executing wp_die()? Default false.
   -- @return int|false|WP_Error The ID of the comment on success, false or WP_Error
   --                            on failure.
   --
   type Comment_Error_Type is record
      Success : Boolean;
      Comment : Integer;
      Error   : Class_Errors.Wp_Error;
   end record;

   function Wp_New_Comment
              (Commentdata : Array_Type;
               Error       : Class_Errors.Wp_Error := Class_Errors.Null_Wp_Error) -- false
               return Comment_Error_Type;

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
                               return Comment_Counts_Type;

   Null_Comment_Counts : constant Comment_Counts_Type :=
     (others => 0);

end Inc_Comments;
