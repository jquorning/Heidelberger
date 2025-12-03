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
with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Users;

package Inc_Class_Wp_Querys
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- The WordPress Query class.
   --
   -- @link https://developer.wordpress.org/reference/classes/wp_query/
   --
   -- @since 1.5.0
   -- @since 4.5.0 Removed the `$comments_popup` property.
   --
   -- #[AllowDynamicProperties]
   type Wp_Query is tagged
      record
        --
        -- Query vars set by the user.
        --
        -- @since 1.5.0
        -- @var array
        --
        M_Query : Array_Type;

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
        Posts : Inc_Class_Wp_Posts.Post_Array;

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
        M_Is_Single : Boolean := False;

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
        M_Is_Page : Boolean := False; -- M_ added

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
        M_Is_Author : Boolean := False; -- M_ added

        --
        -- Signifies whether the current query is for a category archive.
        --
        -- @since 1.5.0
        -- @var bool
        --
        M_Is_Category : Boolean := False; -- M_ added

        --
        -- Signifies whether the current query is for a tag archive.
        --
        -- @since 2.3.0
        -- @var bool
        --
        M_Is_Tag : Boolean := False;

        --
        -- Signifies whether the current query is for a taxonomy archive.
        --
        -- @since 2.5.0
        -- @var bool
        --
        M_Is_Tax : Boolean := False;

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
        -- Signifies whether the current query is for a paged result and not for the
        -- first page.
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
        -- Signifies whether the current query is for an existing single post of any
        -- post type (post, attachment, page, custom post types).
        --
        -- @since 2.1.0
        -- @var bool
        --
        M_Is_Singular : Boolean := False;

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
        X_Is_Post_Type_Archive : Boolean := False; -- X_ added jq

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
   -- Retrieves the value of a query variable.
   --
   -- @since 1.5.0
   -- @since 3.9.0 The `$default_value` argument was introduced.
   --
   -- @param string $query_var     Query variable key.
   -- @param mixed  $default_value Optional. Value to return if the query variable
   --                              is not set. Default empty string.
   -- @return mixed Contents of the query variable.
   --
   function Get (This          : Wp_Query;
                 Query_Var     : String;
                 Default_Value : String := "")
                 return String;

   --
   -- Sets up the WordPress query by parsing query string.
   --
   -- @since 1.5.0
   --
   -- @see WP_Query::parse_query() for all available arguments.
   --
   -- @param string|array $query URL query string or array of query arguments.
   -- @return WP_Post[]|int[] Array of post objects or post IDs.
   --
   procedure Query (This  : Wp_Query;
                    Query : Array_Type)
   is null;

   --
   -- Constructor.
   --
   -- Sets up the WordPress query, if parameter is not empty.
   --
   -- @since 1.5.0
   --
   -- @see WP_Query::parse_query() for all available arguments.
   --
   -- @param string|array $query URL query string or array of vars.
   --
   function X_Construct (Query : Array_Type) -- ''
                         return Wp_Query;

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

   function Get_Queried_Object (This : Wp_Query)
                                return Inc_Class_Wp_Terms.Wp_Term
                                is (Inc_Class_Wp_Terms.Null_Term);

   function Get_Queried_Object (This : Wp_Query)
                                return Inc_Class_Wp_Users.Wp_User
                                is (Inc_Class_Wp_Users.Null_User);

   --
   -- Is the query for an existing post type archive page?
   --
   -- @since 3.1.0
   --
   -- @param string|string[] $post_types Optional. Post type or array of posts types
   --                                    to check against. Default empty.
   -- @return bool Whether the query is for an existing post type archive page.
   --
   function Is_Post_Type_Archive (This       : Wp_Query;
                                  Post_Types : String := "")
                                  return Boolean;

   --
   -- Is the query for an existing author archive page?
   --
   -- If the $author parameter is specified, this function will additionally
   -- check if the query is for one of the authors specified.
   --
   -- @since 3.1.0
   --
   -- @param int|string|int[]|string[] $author Optional. User ID, nickname, nicename,
   --                                          or array of such to check against.
   --                                          Default empty.
   -- @return bool Whether the query is for an existing author archive page.
   --
   function Is_Author (This   : Wp_Query;
                       Author : String := "")
                       return Boolean;

   --
   -- Is the query for an existing category archive page?
   --
   -- If the $category parameter is specified, this function will additionally
   -- check if the query is for one of the categories specified.
   --
   -- @since 3.1.0
   --
   -- @param int|string|int[]|string[] $category Optional. Category ID, name, slug,
   --                                            or array of such to check against.
   --                                            Default empty.
   -- @return bool Whether the query is for an existing category archive page.
   --
   function Is_Category (This     : Wp_Query;
                         Category : String := "")
                         return Boolean;

   --
   -- Is the query for an existing tag archive page?
   --
   -- If the $tag parameter is specified, this function will additionally
   -- check if the query is for one of the tags specified.
   --
   -- @since 3.1.0
   --
   -- @param int|string|int[]|string[] $tag Optional. Tag ID, name, slug, or array of
   --                                        such to check against. Default empty.
   -- @return bool Whether the query is for an existing tag archive page.
   --
   function Is_Tag (This : Wp_Query;
                    Tag  : String := "")
                    return Boolean;

   --
   -- Is the query for an existing custom taxonomy archive page?
   --
   -- If the $taxonomy parameter is specified, this function will additionally
   -- check if the query is for that specific $taxonomy.
   --
   -- If the $term parameter is specified in addition to the $taxonomy parameter,
   -- this function will additionally check if the query is for one of the terms
   -- specified.
   --
   -- @since 3.1.0
   --
   -- @global WP_Taxonomy[] $wp_taxonomies Registered taxonomies.
   --
   -- @param string|string[]           $taxonomy Optional. Taxonomy slug or slugs to
   --                                            check against. Default empty.
   -- @param int|string|int[]|string[] $term     Optional. Term ID, name, slug, or
   --                                            array of such to check against.
   --                                            Default empty.
   -- @return bool Whether the query is for an existing custom taxonomy archive page.
   --              True for custom taxonomy archive pages, false for built-in
   --              taxonomies (category and tag archives).
   --
   function Is_Tax (This     : Wp_Query;
                    Taxonomy : String := "";
                    Term     : String := "")
                    return Boolean;

   --
   -- Is the query for the front page of the site?
   --
   -- This is for what is displayed at your site's main URL.
   --
   -- Depends on the site's "Front page displays" Reading Settings 'show_on_front'
   -- and 'page_on_front'.
   --
   -- If you set a static page for the front page of your site, this function will
   -- return true when viewing that page.
   --
   -- Otherwise the same as @see WP_Query::is_home()
   --
   -- @since 3.1.0
   --
   -- @return bool Whether the query is for the front page of the site.
   --
   function Is_Front_Page (This : Wp_Query)
                           return Boolean;

   --
   -- Is the query for an existing single page?
   --
   -- If the $page parameter is specified, this function will additionally
   -- check if the query is for one of the pages specified.
   --
   -- @since 3.1.0
   --
   -- @see WP_Query::is_single()
   -- @see WP_Query::is_singular()
   --
   -- @param int|string|int[]|string[] $page Optional. Page ID, title, slug, path, or
   --                                        array of such to check against. Default
   --                                        empty.
   -- @return bool Whether the query is for an existing single page.
   --
   function Is_Page (This : Wp_Query;
                     Page : String := "")
                     return Boolean;

   --
   -- Is the query for an existing single post?
   --
   -- Works for any post type excluding pages.
   --
   -- If the $post parameter is specified, this function will additionally
   -- check if the query is for one of the Posts specified.
   --
   -- @since 3.1.0
   --
   -- @see WP_Query::is_page()
   -- @see WP_Query::is_singular()
   --
   -- @param int|string|int[]|string[] $post Optional. Post ID, title, slug, path, or
   --                                        array of such to check against. Default
   --                                        empty.
   -- @return bool Whether the query is for an existing single post.
   --
   function Is_Single (This : Wp_Query;
                       Post : String := "")
                       return Boolean;

   --
   -- Is the query for an existing single post of any post type (post, attachment,
   -- page, custom post types)?
   --
   -- If the $post_types parameter is specified, this function will additionally
   -- check if the query is for one of the Posts Types specified.
   --
   -- @since 3.1.0
   --
   -- @see WP_Query::is_page()
   -- @see WP_Query::is_single()
   --
   -- @param string|string[] $post_types Optional. Post type or array of post types
   --                                    to check against. Default empty.
   -- @return bool Whether the query is for an existing single post
   --              or any of the given post types.
   --
   function Is_Singular (This       : Wp_Query;
                         Post_Types : String := "")
                         return Boolean;

   --
   -- Sets up the WordPress query by parsing query string.
   --
   -- @since 1.5.0
   --
   -- @see WP_Query::parse_query() for all available arguments.
   --
   -- @param string|array $query URL query string or array of query arguments.
   -- @return WP_Post[]|int[] Array of post objects or post IDs.
   --
   function Query (This  : Wp_Query;
                   Query : Array_Type)
                   return Inc_Class_Wp_Posts.Post_Array -- Wp_Post_Array
                   is (Inc_Class_Wp_Posts.Empty_Post_Array); -- Empty_Wp_Post_Array);

   Null_Query : constant Wp_Query :=
     (M_Query               => Empty_Array,
      Query_Vars            => Empty_Array,
      Queried_Object_Id     => 0,
      Request               => Null_Unbounded_String,
      Post_Count            => 0,
      Current_Post          => 0,
      Comment_Count         => 0,
      Current_Comment       => 0,
      Found_Posts           => 0,
      Max_Num_Pages         => 0,
      Max_Num_Comment_Pages => 0,
      Posts                 => Inc_Class_Wp_Posts.Post_Arrays.Empty_Vector,
      others                => False);

end Inc_Class_Wp_Querys;
