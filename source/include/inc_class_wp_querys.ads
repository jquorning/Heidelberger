--
-- Query API: WP_Query class
--
-- @package WordPress
-- @subpackage Query
-- @since 4.7.0
--

with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wp_Posts;
-- with Inc_Class_Posts;

package Inc_Class_Wp_Querys
is
   use Ada.Strings.Unbounded;
   use Arrays;

   procedure Dummy;
--
-- The WordPress Query class.
--
-- @link https://developer.wordpress.org/reference/classes/wp_query/
--
-- @since 1.5.0
-- @since 4.5.0 Removed the `$comments_popup` property.
--
-- #[AllowDynamicProperties]
   type WP_Query is tagged
      record

        --
        -- Query vars set by the user.
        --
        -- @since 1.5.0
        -- @var array
        --
        Query : Array_Type;

        --
        -- Query vars, after parsing.
        --
        -- @since 1.5.0
        -- @var array
        --
        Query_Vars : Array_Type; --  = array();

        --
        -- Taxonomy query, as passed to get_tax_sql().
        --
        -- @since 3.1.0
        -- @var WP_Tax_Query A taxonomy query instance.
        --
--        public $tax_query;

        --
        -- Metadata query container.
        --
        -- @since 3.2.0
        -- @var WP_Meta_Query A meta query instance.
        --
--        public $meta_query = false;

        --
        -- Date query container.
        --
        -- @since 3.7.0
        -- @var WP_Date_Query A date query instance.
        --
--        public $date_query = false;

        --
        -- Holds the data for a single object that is queried.
        --
        -- Holds the contents of a post, page, category, attachment.
        --
        -- @since 1.5.0
        -- @var WP_Term|WP_Post_Type|WP_Post|WP_User|null
        --
--        public $queried_object;

        --
        -- The ID of the queried object.
        --
        -- @since 1.5.0
        -- @var int
        --
        Queried_Object_Id : Integer;

        --
        -- SQL for the database query.
        --
        -- @since 2.0.1
        -- @var string
        --
        Request : Unbounded_String;

        --
        -- Array of post objects or post IDs.
        --
        -- @since 1.5.0
        -- @var WP_Post[]|int[]
        --
--        public $posts;

        --
        -- The number of posts for the current query.
        --
        -- @since 1.5.0
        -- @var int
        --
        Post_Count : Integer := 0;

        --
        -- Index of the current item in the loop.
        --
        -- @since 1.5.0
        -- @var int
        --
        Current_Post : Integer := -1;

        --
        -- Whether the loop has started and the caller is in the loop.
        --
        -- @since 2.0.0
        -- @var bool
        --
        In_The_Loop : Boolean := False;

        --
        -- The current post.
        --
        -- This property does not get populated when the `fields` argument is set to
        -- `ids` or `id=>parent`.
        --
        -- @since 1.5.0
        -- @var WP_Post|null
        --
--        public $post;

        --
        -- The list of comments for current post.
        --
        -- @since 2.2.0
        -- @var WP_Comment[]
        --
--        public $comments;

        --
        -- The number of comments for the posts.
        --
        -- @since 2.2.0
        -- @var int
        --
        Comment_Count : Integer := 0;

        --
        -- The index of the comment in the comment loop.
        --
        -- @since 2.2.0
        -- @var int
        --
        Current_Comment : Integer := -1;

        --
        -- Current comment object.
        --
        -- @since 2.2.0
        -- @var WP_Comment
        --
--        public $comment;

        --
        -- The number of found posts for the current query.
        --
        -- If limit clause was not used, equals $post_count.
        --
        -- @since 2.1.0
        -- @var int
        --
        Found_Posts : Integer := 0;

        --
        -- The number of pages.
        --
        -- @since 2.1.0
        -- @var int
        --
        Max_Num_Pages : Integer := 0;

        --
        -- The number of comment pages.
        --
        -- @since 2.7.0
        -- @var int
        --
        Max_Num_Comment_Pages : Integer := 0;

        --
        -- Signifies whether the current query is for a single post.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Single : Boolean := False;

        --
        -- Signifies whether the current query is for a preview.
        --
        -- @since 2.0.0
        -- @var bool
        --
        Is_Preview : Boolean := False;

        --
        -- Signifies whether the current query is for a page.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Page : Boolean := False;

        --
        -- Signifies whether the current query is for an archive.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Archive : Boolean := False;

        --
        -- Signifies whether the current query is for a date archive.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Date : Boolean := False;

        --
        -- Signifies whether the current query is for a year archive.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Year : Boolean := False;

        --
        -- Signifies whether the current query is for a month archive.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Month : Boolean := False;

        --
        -- Signifies whether the current query is for a day archive.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Day : Boolean := False;

        --
        -- Signifies whether the current query is for a specific time.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Time : Boolean := False;

        --
        -- Signifies whether the current query is for an author archive.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Author : Boolean := False;

        --
        -- Signifies whether the current query is for a category archive.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Category : Boolean := False;

        --
        -- Signifies whether the current query is for a tag archive.
        --
        -- @since 2.3.0
        -- @var bool
        --
        Is_Tag : Boolean := False;

        --
        -- Signifies whether the current query is for a taxonomy archive.
        --
        -- @since 2.5.0
        -- @var bool
        --
        Is_Tax : Boolean := False;

        --
        -- Signifies whether the current query is for a search.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Search : Boolean := False;

        --
        -- Signifies whether the current query is for a feed.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Feed : Boolean := False;

        --
        -- Signifies whether the current query is for a comment feed.
        --
        -- @since 2.2.0
        -- @var bool
        --
        Is_Comment_Feed : Boolean := False;

        --
        -- Signifies whether the current query is for trackback endpoint call.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Trackback : Boolean := False;

        --
        -- Signifies whether the current query is for the site homepage.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Home : Boolean := False;

        --
        -- Signifies whether the current query is for the Privacy Policy page.
        --
        -- @since 5.2.0
        -- @var bool
        --
        Is_Privacy_Policy : Boolean := False;

        --
        -- Signifies whether the current query couldn't find anything.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_404 : Boolean := False;

        --
        -- Signifies whether the current query is for an embed.
        --
        -- @since 4.4.0
        -- @var bool
        --
        Is_Embed : Boolean := False;

        --
        -- Signifies whether the current query is for a paged result and not for the first page.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Paged : Boolean := False;

        --
        -- Signifies whether the current query is for an administrative interface page.
        --
        -- @since 1.5.0
        -- @var bool
        --
        Is_Admin : Boolean := False;

        --
        -- Signifies whether the current query is for an attachment page.
        --
        -- @since 2.0.0
        -- @var bool
        --
        Is_Attachment : Boolean := False;

        --
        -- Signifies whether the current query is for an existing single post of any post type
        -- (post, attachment, page, custom post types).
        --
        -- @since 2.1.0
        -- @var bool
        --
        Is_Singular : Boolean := False;

        --
        -- Signifies whether the current query is for the robots.txt file.
        --
        -- @since 2.1.0
        -- @var bool
        --
        Is_Robots : Boolean := False;

        --
        -- Signifies whether the current query is for the favicon.ico file.
        --
        -- @since 5.4.0
        -- @var bool
        --
        Is_Favicon : Boolean := False;

        --
        -- Signifies whether the current query is for the page_for_posts page.
        --
        -- Basically, the homepage if the option isn't set for the static homepage.
        --
        -- @since 2.1.0
        -- @var bool
        --
        Is_Posts_Page : Boolean := False;

        --
        -- Signifies whether the current query is for a post type archive.
        --
        -- @since 3.1.0
        -- @var bool
        --
        Is_Post_Type_Archive : Boolean := False;

        --
        -- Stores the ->query_vars state like md5(serialize( $this->query_vars ) ) so we know
        -- whether we have to re-parse because something has changed
        --
        -- @since 3.1.0
        -- @var bool|string
        --
--        private $query_vars_hash = false;

        --
        -- Whether query vars have changed since the initial parse_query() call. Used to catch modifications to query vars made
        -- via pre_get_posts hooks.
        --
        -- @since 3.1.1
        --
--        private $query_vars_changed = true;

        --
        -- Set if post thumbnails are cached
        --
        -- @since 3.2.0
        -- @var bool
        --
        Thumbnails_Cached : Boolean := False;

        --
        -- Controls whether an attachment query should include filenames or not.
        --
        -- @since 6.0.3
        -- @var bool
        --
--        protected $allow_query_attachment_by_filename = false;

        --
        -- Cached list of search stopwords.
        --
        -- @since 3.7.0
        -- @var array
        --
--        private $stopwords;

--        private $compat_fields = array( 'query_vars_hash', 'query_vars_changed' );

--        private $compat_methods = array( 'init_query_flags', 'parse_tax_query' );
      end record;

        --
        -- Determines whether there are more posts available in the loop.
        --
        -- Calls the {@see 'loop_end'} action when the loop is complete.
        --
        -- @since 1.5.0
        --
        -- @return bool True if posts are available, false if end of the loop.
        --
        function Have_Posts (This : in out Wp_Query)
                             return Boolean
                             is (True);

        --
        -- Set up the next post and iterate current post index.
        --
        -- @since 1.5.0
        --
        -- @return WP_Post Next post.
        --
        function Next_Post (This : Wp_Query)
                            return Inc_Class_Wp_Posts.Wp_Post -- Inc_Class_Wp_Posts
                            is (Inc_Class_Wp_Posts.Null_Post);
        --
        -- Retrieves the currently queried object.
        --
        -- If queried object is not set, then the queried object will be set from
        -- the category, tag, taxonomy, posts page, single post, page, or author
        -- query variable. After it is set up, it will be returned.
        --
        -- @since 1.5.0
        --
        -- @return WP_Term|WP_Post_Type|WP_Post|WP_User|null The queried object.
        --
        function Get_Queried_Object (This : Wp_Query)
                                     return Inc_Class_Wp_Posts.Wp_Post
                                     is (Inc_Class_Wp_Posts.Null_Post);

end Inc_Class_Wp_Querys;
