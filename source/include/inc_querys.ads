--
-- WordPress Query API
--
-- The query API attempts to get which part of WordPress the user is on. It
-- also provides functionality for getting URL query information.
--
-- @link https://developer.wordpress.org/themes/basics/the-loop/ More information on
-- The Loop.
--
-- @package WordPress
-- @subpackage Query
--

with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Users;

package Inc_Querys
is
   --
   -- Retrieves the value of a query variable in the WP_Query class.
   --
   -- @since 1.5.0
   -- @since 3.9.0 The `default` argument was introduced.
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param string var       The variable key to retrieve.
   -- @param mixed  default   Optional. Value to return if the query variable is not
   --                          set. Default empty.
   -- @return mixed Contents of the query variable.
   --
   function Get_Query_Var (Var     : String;
                           Default : String := "")
                           return String;

   function Get_Query_Var (Var     : String;
                           Default : String := "")
                           return Integer
                           is (0);

   --
   -- Retrieves the currently queried object.
   --
   -- Wrapper for WP_Query::get_queried_object().
   --
   -- @since 3.1.0
   --
   -- @global WP_Query $wp_query WordPress Query object.
   --
   -- @return WP_Term|WP_Post_Type|WP_Post|WP_User|null The queried object.
   --
   function Get_Queried_Object
            return Inc_Class_Wp_Posts.Wp_Post;
   function Get_Queried_Object
            return Inc_Class_Wp_Terms.Wp_Term;
   function Get_Queried_Object
            return Inc_Class_Wp_Users.Wp_User;

   --
   -- Determines whether the query is for an existing post type archive page.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 3.1.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param string|string[] post_types Optional. Post type or array of posts types
   --                                    to check against. Default empty.
   -- @return bool Whether the query is for an existing post type archive page.
   --
   function Is_Post_Type_Archive (Post_Types : String := "")
                                  return Boolean;

   --
   -- Determines whether the query is for an existing author archive page.
   --
   -- If the author parameter is specified, this function will additionally
   -- check if the query is for one of the authors specified.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param int|string|int[]|string[] author Optional. User ID, nickname, nicename,
   --                                          or array of such to check against.
   --                                          Default empty.
   -- @return bool Whether the query is for an existing author archive page.
   --
   function Is_Author (Author : String := "")
                       return Boolean;

   --
   -- Determines whether the query is for an existing category archive page.
   --
   -- If the category parameter is specified, this function will additionally
   -- check if the query is for one of the categories specified.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param int|string|int[]|string[] category Optional. Category ID, name, slug,
   --                                            or array of such to check against.
   --                                            Default empty.
   -- @return bool Whether the query is for an existing category archive page.
   --
   function Is_Category (Category : String := "")
                         return Boolean;

   --
   -- Determines whether the query is for an existing tag archive page.
   --
   -- If the tag parameter is specified, this function will additionally
   -- check if the query is for one of the tags specified.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 2.3.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param int|string|int[]|string[] tag Optional. Tag ID, name, slug, or array of
   --                                       such to check against. Default empty.
   -- @return bool Whether the query is for an existing tag archive page.
   --
   function Is_Tag (Tag : String := "")
                    return Boolean;

   --
   -- Determines whether the query is for an existing custom taxonomy archive page.
   --
   -- If the taxonomy parameter is specified, this function will additionally
   -- check if the query is for that specific taxonomy.
   --
   -- If the term parameter is specified in addition to the taxonomy parameter,
   -- this function will additionally check if the query is for one of the terms
   -- specified.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 2.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param string|string[]           taxonomy Optional. Taxonomy slug or slugs to
   --                                            check against. Default empty.
   -- @param int|string|int[]|string[] term     Optional. Term ID, name, slug, or
   --                                            array of such to check against.
   --                                            Default empty.
   -- @return bool Whether the query is for an existing custom taxonomy archive page.
   --              True for custom taxonomy archive pages, false for built-in
   --              taxonomies (category and tag archives).
   --
   function Is_Tax (Taxonomy : String := "";
                    Term     : String := "")
                    return Boolean;

   --
   -- Determines whether the query is for an existing day archive.
   --
   -- A conditional check to test whether the page is a date-based archive page
   -- displaying posts for the current day.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @return bool Whether the query is for an existing day archive.
   --
   function Is_Day
            return Boolean;

   --
   -- Determines whether the query is for the front page of the site.
   --
   -- This is for what is displayed at your site's main URL.
   --
   -- Depends on the site's "Front page displays" Reading Settings "show_on_front"
   -- and "page_on_front".
   --
   -- If you set a static page for the front page of your site, this function will
   -- return true when viewing that page.
   --
   -- Otherwise the same as @see is_home()
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 2.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @return bool Whether the query is for the front page of the site.
   --
   function Is_Front_Page
            return Boolean;

   --
   -- Determines whether the query is for the blog homepage.
   --
   -- The blog homepage is the page that shows the time-based blog content of the site.
   --
   -- is_home() is dependent on the site's "Front page displays" Reading Settings
   -- "show_on_front" and "page_for_posts".
   --
   -- If a static page is set for the front page of the site, this function will
   -- return true only on the page you set as the "Posts page".
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @see is_front_page()
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @return bool Whether the query is for the blog homepage.
   --
   function Is_Home
            return Boolean;

   --
   -- Determines whether the query is for an existing month archive.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @return bool Whether the query is for an existing month archive.
   --
   function Is_Month
            return Boolean;

   --
   -- Determines whether the query is for a search.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @return bool Whether the query is for a search.
   --
   function Is_Search
            return Boolean;

   --
   -- Determines whether the query is for an existing single post.
   --
   -- Works for any post type, except attachments and pages
   --
   -- If the post parameter is specified, this function will additionally
   -- check if the query is for one of the Posts specified.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @see is_page()
   -- @see is_singular()
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param int|string|int[]|string[] post Optional. Post ID, title, slug, or array of such
   --                                        to check against. Default empty.
   -- @return bool Whether the query is for an existing single post.
   --
   function Is_Single (Post : String := "")
            return Boolean;

   --
   -- Determines whether the query is for an existing single post of any post type
   -- (post, attachment, page, custom post types).
   --
   -- If the post_types parameter is specified, this function will additionally
   -- check if the query is for one of the Posts Types specified.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @see is_page()
   -- @see is_single()
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @param string|string[] post_types Optional. Post type or array of post types
   --                                    to check against. Default empty.
   -- @return bool Whether the query is for an existing single post
   --              or any of the given post types.
   --
   function Is_Singular (Post_Types : String := "")
                         return Boolean;

   --
   -- Determines whether the query is for an existing year archive.
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @return bool Whether the query is for an existing year archive.
   --
   function Is_Year
            return Boolean;

   --
   -- Determines whether the query has resulted in a 404 (returns no results).
   --
   -- For more information on this and similar theme functions, check out
   -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tagsend; article in the Theme Developer Handbook.
   --
   -- @since 1.5.0
   --
   -- @global WP_Query wp_query WordPress Query object.
   --
   -- @return bool Whether the query is a 404 error.
   --
   function Is_404
            return Boolean;

end Inc_Querys;
