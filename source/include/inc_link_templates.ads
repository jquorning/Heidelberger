--
-- WordPress Link Template Functions
--
-- @package WordPress
-- @subpackage Template
--

with Arrays;

with Class_Posts;
with Class_Rewrites;
with Class_Users;

package Inc_Link_Templates
is
   use Arrays;

   Global_Wp_Rewrite : Class_Rewrites.Wp_Rewrite;

   --
   -- Retrieves a trailing-slashed string if the site is set for adding trailing
   -- slashes.
   --
   -- Conditionally adds a trailing slash if the permalink structure has a trailing
   -- slash, strips the trailing slash if not. The string is passed through the
   -- {@see "user_trailingslashit"} filter. Will remove trailing slash from string, if
   -- site is not set to have them.
   --
   -- @since 2.2.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param string string      URL with or without a trailing slash.
   -- @param string type_of_url Optional. The type of URL being considered (e.g.
   --                            single, category, etc) for use in the filter.
   --                            Default empty string.
   -- @return string The URL with the trailing slash appended or stripped.
   --
   function User_Trailing_Slash_It (Item        : String;
                                    Type_Of_URL : String := "")
                                    return String;

   --
   -- Determine whether post should always use a plain permalink structure.
   --
   -- @since 5.7.0
   --
   -- @param WP_Post|int|null post   Optional. Post ID or post object. Defaults to
   --                                 global post.
   -- @param bool|null        sample Optional. Whether to force consideration based on
   --                                 sample links. If omitted, a sample link is
   --                                 generated if a post object is passed
   --                                 with the filter property set to "sample".
   -- @return bool Whether to use a plain permalink structure.
   --
   function Wp_Force_Plain_Post_Permalink
              (Post   : Class_Posts.Wp_Post; -- null
               Sample : Boolean := False) -- null
               return Boolean;

   --
   -- Retrieves the permalink for a post type archive.
   --
   -- @since 3.1.0
   -- @since 4.5.0 Support for posts was added.
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param string post_type Post type.
   -- @return string|false The post type archive permalink. False if the post type
   --                      does not exist or does not have an archive.
   --
   function Get_Post_Type_Archive_Link (Post_Type : String)
                                        return String;

   --
   -- Retrieves the permalink for a post type archive feed.
   --
   -- @since 3.1.0
   --
   -- @param string post_type Post type.
   -- @param string feed      Optional. Feed type. Possible values include "rss2",
   --                         "atom". Default is the value of get_default_feed().
   -- @return string|false The post type feed permalink. False if the post type
   --                      does not exist or does not have an archive.
   --
   function Get_Post_Type_Archive_Feed_Link (Post_Type : String;
                                             Feed      : String := "")
                                             return String;

   --
   -- Retrieves the full permalink for the current post or post ID.
   --
   -- @since 1.0.0
   --
   -- @param int|WP_Post post      Optional. Post ID or post object. Default is the
   --                               global `post`.
   -- @param bool        leavename Optional. Whether to keep post name or page name.
   --                               Default false.
   -- @return string|false The permalink URL. False if the post does not exist.
   --
   function Get_Permalink (Id        : Class_Posts.Post_Id_Type := 0;
                           Leavename : Boolean := False)
                           return String;

   function Get_Permalink (Post      : Class_Posts.Wp_Post;
                           Leavename : Boolean := False)
                           return String;

   --
   -- Retrieves the permalink for a post of a custom post type.
   --
   -- @since 3.0.0
   -- @since 6.1.0 Returns false if the post does not exist.
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param int|WP_Post post      Optional. Post ID or post object. Default is the
   --                               global `post`.
   -- @param bool        leavename Optional. Whether to keep post name. Default false.
   -- @param bool        sample    Optional. Is it a sample permalink. Default false.
   -- @return string|false The post permalink URL. False if the post does not exist.
   --
   function Get_Post_Permalink (Id        : Class_Posts.Wp_Post; -- Post, 0,
                                Leavename : Boolean := False;
                                Sample    : Boolean := False)
                                return String;

   --
   -- Retrieves the permalink for the current page or page ID.
   --
   -- Respects page_on_front. Use this one.
   --
   -- @since 1.5.0
   --
   -- @param int|WP_Post post      Optional. Post ID or object. Default uses the
   --                               global `post`.
   -- @param bool        leavename Optional. Whether to keep the page name. Default
   --                               false.
   -- @param bool        sample    Optional. Whether it should be treated as a sample
   --                               permalink. Default false.
   -- @return string The page permalink.
   --
--   function Get_Page_Link (Post      : Class_Posts.Post_Id := 0; -- false
--                           Leavename : Boolean := False;
--                           Sample    : Boolean := False)
--                           return String;

   function Get_Page_Link (Post      : Class_Posts.Wp_Post;
                           Leavename : Boolean := False;
                           Sample    : Boolean := False)
                           return String;

   --
   -- Retrieves the page permalink.
   --
   -- Ignores page_on_front. Internal use only.
   --
   -- @since 2.1.0
   -- @access private
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param int|WP_Post post      Optional. Post ID or object. Default uses the
   --                               global `post`.
   -- @param bool        leavename Optional. Whether to keep the page name. Default
   --                               false.
   -- @param bool        sample    Optional. Whether it should be treated as a sample
   --                               permalink. Default false.
   -- @return string The page permalink.
   --
   function X_Get_Page_Link (Post      : Class_Posts.Wp_Post; -- = false,
                             Leavename : Boolean := False;
                             Sample    : Boolean := False)
                             return String;

   function X_Get_Page_Link (Post      : Class_Posts.Post_Id_Type; -- = false,
                             Leavename : Boolean := False;
                             Sample    : Boolean := False)
                             return String
                             is (raise Program_Error with "not implemented");

   --
   -- Retrieves the permalink for an attachment.
   --
   -- This can be used in the WordPress Loop or outside of it.
   --
   -- @since 2.0.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param int|object post      Optional. Post ID or object. Default uses the global
   --                              `post`.
   -- @param bool       leavename Optional. Whether to keep the page name. Default
   --                              false.
   -- @return string The attachment permalink.
   --
   function Get_Attachment_Link (Post      : Class_Posts.Wp_Post; -- null
                                 Leavename : Boolean := False)
                                 return String;

   --
   -- Retrieves the permalink for the feed type.
   --
   -- @since 1.5.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param string feed Optional. Feed type. Possible values include "rss2", "atom".
   --                     Default is the value of get_default_feed().
   -- @return string The feed permalink.
   --
   function Get_Feed_Link (Feed : String := "")
                           return String;

   --
   -- Retrieves the feed link for a given author.
   --
   -- Returns a link to the feed for all posts by a given author. A specific feed
   -- can be requested or left blank to get the default feed.
   --
   -- @since 2.5.0
   --
   -- @param int    author_id Author ID.
   -- @param string feed      Optional. Feed type. Possible values include "rss2",
   --                         "atom". Default is the value of get_default_feed().
   -- @return string Link to the feed for the author specified by author_id.
   --
   function Get_Author_Feed_Link (Author_Id : Integer;
                                  Feed      : String := "")
                                  return String;

   --
   -- Retrieves the permalink for the post comments feed.
   --
   -- @since 2.2.0
   --
   -- @param int    post_id Optional. Post ID. Default is the ID of the global `post`.
   -- @param string feed    Optional. Feed type. Possible values include "rss2",
   --                       "atom". Default is the value of get_default_feed().
   -- @return string The permalink for the comments feed for the given post on
   --                success, empty string on failure.
   --
   function Get_Post_Comments_Feed_Link (Post_Id : Class_Posts.Post_Id_Type := 0;
                                         Feed    : String                   := "")
                                         return String;

   --
   -- Retrieves the feed link for a category.
   --
   -- Returns a link to the feed for all posts in a given category. A specific feed
   -- can be requested or left blank to get the default feed.
   --
   -- @since 2.5.0
   --
   -- @param int|WP_Term|object cat  The ID or category object whose feed link will
   --                                be retrieved.
   -- @param string             feed Optional. Feed type. Possible values include
   --                                "rss2", "atom". Default is the value of
   --                                get_default_feed().
   --
   -- @return string Link to the feed for the category specified by `cat`.
   --
   function Get_Category_Feed_Link (Cat  : Integer;
                                    Feed : String := "")
                                    return String;

   --
   -- Retrieves the feed link for a term.
   --
   -- Returns a link to the feed for all posts in a given term. A specific feed
   -- can be requested or left blank to get the default feed.
   --
   -- @since 3.0.0
   --
   -- @param int|WP_Term|object term     The ID or term object whose feed link will
   --                                    be retrieved.
   -- @param string             taxonomy Optional. Taxonomy of `term_id`.
   -- @param string             feed     Optional. Feed type. Possible values include
   --                                    "rss2", "atom". Default is the value of
   --                                    get_default_feed().
   -- @return string|false Link to the feed for the term specified by `term` and
   --                      `taxonomy`.
   --
   function Get_Term_Feed_Link (Term     : Integer;
                                Taxonomy : String := "";
                                Feed     : String := "")
                                return String;

   --
   -- Retrieves the permalink for a tag feed.
   --
   -- @since 2.3.0
   --
   -- @param int|WP_Term|object tag  The ID or term object whose feed link will be
   --                                retrieved.
   -- @param string             feed Optional. Feed type. Possible values include
   --                                "rss2", "atom". Default is the value of
   --                                get_default_feed().
   -- @return string                 The feed permalink for the given tag.
   --
   function Get_Tag_Feed_Link (Tag  : Integer;
                               Feed : String := "")
                               return String;

   --
   -- Retrieves the URL for a given site where the front end is accessible.
   --
   -- Returns the "home" option with the appropriate protocol. The protocol will be
   -- "https" if is_ssl() evaluates to true; otherwise, it will be the same as the
   -- "home" option. If `scheme` is "http" or "https", is_ssl() is overridden.
   --
   -- @since 3.0.0
   --
   -- @param int|null    blog_id Optional. Site ID. Default null (current site).
   -- @param string      path    Optional. Path relative to the home URL. Default
   --                             empty.
   -- @param string|null scheme  Optional. Scheme to give the home URL context. Accepts
   --                             "http", "https", "relative", "rest", or null.
   --                             Default null.
   -- @return string Home URL link with optional path appended.
   --
   function Get_Home_URL (Blog_Id : Integer := 0; --  = null,
                          Path    : String  := "";
                          Scheme  : String  := "") -- = null
                          return String;

   --
   -- Retrieves the URL to the admin area for the current user.
   --
   -- @since 3.0.0
   --
   -- @param string path   Optional. Path relative to the admin URL. Default empty.
   -- @param string scheme Optional. The scheme to use. Default is "admin", which
   --                       obeys force_ssl_admin() and is_ssl(). "http" or "https"
   --                       can be passed to force those schemes.
   -- @return string Admin URL link with optional path appended.
   --
   function User_Admin_URL (Path   : String := "";
                            Scheme : String := "admin")
                            return String;

   --
   -- Retrieves the URL for the current site where the front end is accessible.
   --
   -- Returns the "home" option with the appropriate protocol. The protocol will be
   -- "https" if is_ssl() evaluates to true; otherwise, it will be the same as the
   -- "home" option. If `scheme` is "http" or "https", is_ssl() is overridden.
   --
   -- @since 3.0.0
   --
   -- @param string      path   Optional. Path relative to the home URL. Default empty.
   -- @param string|null scheme Optional. Scheme to give the home URL context. Accepts
   --                            "http", "https", "relative", "rest", or null. Default
   --                            null.
   -- @return string Home URL link with optional path appended.
   --
   function Home_URL (Path   : String := "";
                      Scheme : String := "") --  = null
                      return String;

   --
   -- Retrieves the URL to the user's dashboard.
   --
   -- If a user does not belong to any site, the global user dashboard is used. If the
   -- user belongs to the current site, the dashboard for the current site is
   -- returned. If the user cannot edit the current site, the dashboard to the user's
   -- primary site is returned.
   --
   -- @since 3.1.0
   --
   -- @param int    user_id Optional. User ID. Defaults to current user.
   -- @param string path    Optional path relative to the dashboard. Use only paths
   --                        known to both site and user admins. Default empty.
   -- @param string scheme  The scheme to use. Default is "admin", which obeys
   --                        force_ssl_admin() and is_ssl(). "http" or "https" can be
   --                        passed to force those schemes.
   -- @return string Dashboard URL link with optional path appended.
   --
   function Get_Dashboard_URL (User_Id : Class_Users.User_Id_Type := 0;
                               Path    : String                   := "";
                               Scheme  : String                   := "admin")
                               return String;

   --
   -- Retrieves the edit post link for post.
   --
   -- Can be used within the WordPress loop or outside of it. Can be used with
   -- pages, posts, attachments, and revisions.
   --
   -- @since 2.3.0
   --
   -- @param int|WP_Post post    Optional. Post ID or post object. Default is the
   --                             global `post`.
   -- @param string      context Optional. How to output the "&" character. Default
   --                             "&amp;".
   -- @return string|null The edit post link for the given post. Null if the post type
   --                     does not exist or does not allow an editing UI.
   --
   function Get_Edit_Post_Link (Post    : Integer := 0;
                                Context : String  := "display")
                                return String;

   --
   -- Retrieves the URL to the admin area for either the current site or the network
   -- depending on context.
   --
   -- @since 3.1.0
   --
   -- @param string path   Optional. Path relative to the admin URL. Default empty.
   -- @param string scheme Optional. The scheme to use. Default is "admin", which
   --                       obeys force_ssl_admin() and is_ssl(). "http" or "https"
   --                       can be passed to force those schemes.
   -- @return string Admin URL link with optional path appended.
   --
   function Self_Admin_URL (Path   : String := "";
                            Scheme : String := "admin")
                            return String;
   --
   -- Retrieves the URL to the admin area for the current site.
   --
   -- @since 2.6.0
   --
   -- @param string path   Optional. Path relative to the admin URL. Default empty.
   -- @param string scheme The scheme to use. Default is "admin", which obeys
   --                       force_ssl_admin() and is_ssl(). "http" or "https" can be
   --                       passed to force those schemes.
   -- @return string Admin URL link with optional path appended.
   --
   function Admin_URL (Path   : String := "";
                       Scheme : String := "admin")
                       return String;

   --
   -- Retrieves the URL to the admin area for a given site.
   --
   -- @since 3.0.0
   --
   -- @param int|null blog_id Optional. Site ID. Default null (current site).
   -- @param string   path    Optional. Path relative to the admin URL. Default empty.
   -- @param string   scheme  Optional. The scheme to use. Accepts "http" or "https",
   --                          to force those schemes. Default "admin", which obeys
   --                          force_ssl_admin() and is_ssl().
   -- @return string Admin URL link with optional path appended.
   --
   function Get_Admin_URL (Blog_Id : Integer := 0; --  = null
                           Path    : String  := "";
                           Scheme  : String  := "admin")
                           return String;

   --
   -- Retrieves the URL to the admin area for the network.
   --
   -- @since 3.0.0
   --
   -- @param string path   Optional path relative to the admin URL. Default empty.
   -- @param string scheme Optional. The scheme to use. Default is "admin", which
   --                       obeys force_ssl_admin() and is_ssl(). "http" or "https"
   --                       can be passed to force those schemes.
   -- @return string Admin URL link with optional path appended.
   --
   function Network_Admin_URL (Path   : String := "";
                               Scheme : String := "admin")
                               return String;

   --
   -- Retrieves the URL to the user's profile editor.
   --
   -- @since 3.1.0
   --
   -- @param int    user_id Optional. User ID. Defaults to current user.
   -- @param string scheme  Optional. The scheme to use. Default is "admin", which
   --                        obeys force_ssl_admin() and is_ssl(). "http" or "https"
   --                        can be passed to force those schemes.
   -- @return string Dashboard URL link with optional path appended.
   --
   function Get_Edit_Profile_URL (User_Id : Class_Users.User_Id_Type := 0;
                                  Scheme  : String                   := "admin")
                                  return String;

   --
   -- Retrieves the edit user link.
   --
   -- @since 3.5.0
   --
   -- @param int user_id Optional. User ID. Defaults to the current user.
   -- @return string URL to edit user page or empty string.
   --
   function Get_Edit_User_Link (User_Id : Class_Users.User_Id_Type := 0) -- = null
                                return String;

   --
   -- Retrieves the URL for editing a given term.
   --
   -- @since 3.1.0
   -- @since 4.5.0 The `taxonomy` parameter was made optional.
   --
   -- @param int|WP_Term|object term        The ID or term object whose edit link will
   --                                        be retrieved.
   -- @param string             taxonomy    Optional. Taxonomy. Defaults to the
   --                                        taxonomy of the term identified by `term`.
   -- @param string             object_type Optional. The object type. Used to
   --                                        highlight the proper post type menu on
   --                                        the linked page. Defaults to the first
   --                                        object_type associated with the taxonomy.
   -- @return string|null The edit term link URL for the given term, or null on
   --                      failure.
   --
   function Get_Edit_Term_Link (Term        : Integer;
                                Taxonomy    : String := "";
                                Object_Type : String := "")
                                return String;

   --
   -- Retrieves the permalink for a search.
   --
   -- @since 3.0.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param string query Optional. The query string to use. If empty the current
   --                     query is used. Default empty.
   -- @return string The search permalink.
   --
   function Get_Search_Link (Query : String := "")
                             return String;

   --
   -- Retrieves the permalink for the search results feed.
   --
   -- @since 2.5.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param string search_query Optional. Search query. Default empty.
   -- @param string feed         Optional. Feed type. Possible values include "rss2",
   --                            "atom". Default is the value of get_default_feed().
   -- @return string The search results feed permalink.
   --
   function Get_Search_Feed_Link (Search_Query : String := "";
                                  Feed         : String := "")
                                  return String;

   --
   -- Retrieves the link for a page number.
   --
   -- @since 1.5.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param int  pagenum Optional. Page number. Default 1.
   -- @param bool escape  Optional. Whether to escape the URL for display, with
   --                     esc_url(). Defaults to true. Otherwise, prepares the URL
   --                     with sanitize_url().
   -- @return string The link URL for the given page number.
   --
   function Get_Pagenum_Link (Pagenum : Integer := 1;
                              Escape  : Boolean := True)
                              return String;

   --
   -- Retrieves the previous posts page link.
   --
   -- Will only return string, if not on a single page or post.
   --
   -- Backported to 2.0.10 from 2.1.3.
   --
   -- @since 2.0.10
   --
   -- @global int paged
   --
   -- @return string|void The link for the previous posts page.
   --
   function Get_Previous_Posts_Page_Link
            return String;

   --
   -- Returns a shortlink for a post, page, attachment, or site.
   --
   -- This function exists to provide a shortlink tag that all themes and plugins can
   -- target. A plugin must hook in to provide the actual shortlinks. Default
   -- shortlink support is limited to providing ?p= style links for posts. Plugins can
   -- short-circuit this function via the {@see "pre_get_shortlink"} filter or filter
   -- the output via the {@see "get_shortlink"} filter.
   --
   -- @since 3.0.0
   --
   -- @param int    id          Optional. A post or site ID. Default is 0, which means
   --                            the current post or site.
   -- @param string context     Optional. Whether the ID is a "site" ID, "post" ID, or
   --                            "media" ID. If "post", the post_type of the post is
   --                            consulted. If "query", the current query is consulted
   --                            to determine the ID and context. Default "post".
   -- @param bool   allow_slugs Optional. Whether to allow post slugs in the
   --                            shortlink. It is up to the plugin how
   --                            and whether to honor this. Default true.
   -- @return string A shortlink or an empty string if no shortlink exists for the
   --                 requested resource or if shortlinks are not enabled.
   --
   function Wp_Get_Shortlink (Id          : Integer := 0;
                              Context     : String  := "post";
                              Allow_Slugs : Boolean := True)
                              return String;

   --
   -- Retrieves the avatar URL.
   --
   -- @since 4.2.0
   --
   -- @param mixed id_or_email The Gravatar to retrieve a URL for. Accepts a user_id,
   --                           gravatar md5 hash, user email, WP_User object,
   --                           WP_Post object, or WP_Comment object.
   -- @param array args {
   --     Optional. Arguments to use instead of the default arguments.
   --
   --     @type int    size           Height and width of the avatar in pixels.
   --                                 Default 96.
   --     @type string default        URL for the default image or a default type.
   --                                 Accepts "404" (return a 404 instead of a default
   --                                 image), "retro" (8bit), "monsterid" (monster),
   --                                 "wavatar" (cartoon face), "indenticon" (the
   --                                 "quilt"), "mystery", "mm", or "mysteryman" (The
   --                                 Oyster Man), "blank" (transparent GIF), or
   --                                 "gravatar_default" (the Gravatar logo). Default
   --                                 is the value of the  "avatar_default" option,
   --                                 with a fallback of "mystery".
   --     @type bool   force_default  Whether to always show the default image, never
   --                                 the Gravatar. Default false.
   --     @type string rating         What rating to display avatars up to. Accepts
   --                                 "G", "PG", "R", "X", and are judged in that
   --                                 order. Default is the value of the
   --                                 "avatar_rating" option.
   --     @type string scheme         URL scheme to use. See set_url_scheme() for
   --                                 accepted values. Default null.
   --     @type array  processed_args When the function returns, the value will be
   --                                 the processed/sanitized args plus a
   --                                 "found_avatar" guess. Pass as a reference.
   --                                 Default null.
   -- }
   -- @return string|false The URL of the avatar on success, false on failure.
   --
   function Get_Avatar_URL (Id_Or_Email : String;
                            Args        : Array_Type := Empty_Array) -- null
                            return String;
   --
   -- Retrieves the URL for the current site where WordPress application files
   -- (e.g. wp-blog-header.php or the wp-admin/ folder) are accessible.
   --
   -- Returns the "site_url" option with the appropriate protocol, "https" if
   -- is_ssl() and "http" otherwise. If scheme is "http" or "https", is_ssl() is
   -- overridden.
   --
   -- @since 3.0.0
   --
   -- @param string      path   Optional. Path relative to the site URL. Default empty.
   -- @param string|null scheme Optional. Scheme to give the site URL context. See
   --                           set_url_scheme().
   -- @return string Site URL link with optional path appended.
   --
   function Site_URL (Path   : String := "";
                      Scheme : String := "") --  = null
                      return String;

   --
   -- Retrieves the URL for a given site where WordPress application files
   -- (e.g. wp-blog-header.php or the wp-admin/ folder) are accessible.
   --
   -- Returns the "site_url" option with the appropriate protocol, "https" if
   -- is_ssl() and "http" otherwise. If `scheme` is "http" or "https",
   -- `is_ssl()` is overridden.
   --
   -- @since 3.0.0
   --
   -- @param int|null    blog_id Optional. Site ID. Default null (current site).
   -- @param string      path    Optional. Path relative to the site URL. Default
   --                             empty.
   -- @param string|null scheme  Optional. Scheme to give the site URL context. Accepts
   --                             "http", "https", "login", "login_post", "admin", or
   --                             "relative". Default null.
   -- @return string Site URL link with optional path appended.
   --
   function Get_Site_URL (Blog_Id : Integer := 0; -- null
                          Path    : String  := "";
                          Scheme  : String  := "") -- null
                          return String;

   --
   -- Retrieves the URL to the includes directory.
   --
   -- @since 2.6.0
   --
   -- @param string      path   Optional. Path relative to the includes URL. Default
   --                           empty.
   -- @param string|null scheme Optional. Scheme to give the includes URL context.
   --                            Accepts "http", "https", or "relative". Default null.
   -- @return string Includes URL link with optional path appended.
   --
   function Includes_URL (Path   : String := "";
                          Scheme : String := "") -- null
                          return String;

   --
   -- Retrieves the URL to the content directory.
   --
   -- @since 2.6.0
   --
   -- @param string path Optional. Path relative to the content URL. Default empty.
   -- @return string Content URL link with optional path appended.
   --
   function Content_URL (Path : String := "")
                         return String;

   --
   -- Retrieves a URL within the plugins or mu-plugins directory.
   --
   -- Defaults to the plugins directory URL if no arguments are supplied.
   --
   -- @since 2.6.0
   --
   -- @param string path   Optional. Extra path appended to the end of the URL,
   --                      including the relative directory if plugin is supplied.
   --                      Default empty.
   -- @param string plugin Optional. A full path to a file inside a plugin or
   --                      mu-plugin. The URL will be relative to its directory.
   --                      Default empty. Typically this is done by passing
   --                      `__FILE__` as the argument.
   -- @return string Plugins URL link with optional paths appended.
   --
   function Plugins_URL (Path   : String := "";
                         Plugin : String := "")
                         return String;

   --
   -- Retrieves the site URL for the current network.
   --
   -- Returns the site URL with the appropriate protocol, "https" if
   -- is_ssl() and "http" otherwise. If scheme is "http" or "https", is_ssl() is
   -- overridden.
   --
   -- @since 3.0.0
   --
   -- @see set_url_scheme()
   --
   -- @param string      path   Optional. Path relative to the site URL. Default empty.
   -- @param string|null scheme Optional. Scheme to give the site URL context. Accepts
   --                            "http", "https", or "relative". Default null.
   -- @return string Site URL link with optional path appended.
   --
   function Network_Site_URL (Path   : String := "";
                              Scheme : String := "") -- null
                              return String;

   --
   -- Retrieves default data about the avatar.
   --
   -- @since 4.2.0
   --
   -- @param mixed id_or_email The avatar to retrieve. Accepts a user ID, Gravatar MD5
   --                           hash, user email, WP_User object, WP_Post object, or
   --                           WP_Comment object.
   -- @param array args {
   --     Optional. Arguments to use instead of the default arguments.
   --
   --     @type int    size           Height and width of the avatar image file in
   --                                  pixels. Default 96.
   --     @type int    height         Display height of the avatar in pixels. Defaults
   --                                  to size.
   --     @type int    width          Display width of the avatar in pixels. Defaults
   --                                  to size.
   --     @type string default        URL for the default image or a default type.
   --                                  Accepts "404" (return a 404 instead of a
   --                                  default image), "retro" (8bit), "monsterid"
   --                                  (monster), "wavatar" (cartoon face),
   --                                  "indenticon" (the "quilt"), "mystery", "mm",
   --                                  or "mysteryman" (The Oyster Man), "blank"
   --                                  (transparent GIF), or "gravatar_default" (the
   --                                  Gravatar logo). Default is the value of the
   --                                  "avatar_default" option, with a fallback of
   --                                  "mystery".
   --     @type bool   force_default  Whether to always show the default image, never
   --                                  the Gravatar. Default false.
   --     @type string rating         What rating to display avatars up to. Accepts
   --                                  "G", "PG", "R", "X", and are judged in that
   --                                  order. Default is the value of the
   --                                  "avatar_rating" option.
   --     @type string scheme         URL scheme to use. See set_url_scheme() for
   --                                  accepted values. Default null.
   --     @type array  processed_args When the function returns, the value will be
   --                                  the processed/sanitized args plus a
   --                                  "found_avatar" guess. Pass as a reference.
   --                                  Default null.
   --     @type string extra_attr     HTML attributes to insert in the IMG element.
   --                                  Is not sanitized. Default empty.
   -- }
   -- @return array {
   --     Along with the arguments passed in `args`, this will contain a couple of
   --      extra arguments.
   --
   --     @type bool         found_avatar True if an avatar was found for this user,
   --                                      false or not set if none was found.
   --     @type string|false url          The URL of the avatar that was found, or
   --                                      false.
   -- }
   --
   function Get_Avatar_Data (Id_Or_Email : String;
                             Args        : Array_Type) -- = null
                             return Array_Type;

   --
   -- Retrieves the URL of a file in the theme.
   --
   -- Searches in the stylesheet directory before the template directory so themes
   -- which inherit from a parent theme can just override one file.
   --
   -- @since 4.7.0
   --
   -- @param string file Optional. File to search for in the stylesheet directory.
   -- @return string The URL of the file.
   --
   function Get_Theme_File_URI (File : String := "")
                                return String;

   --
   -- Retrieves the path of a file in the theme.
   --
   -- Searches in the stylesheet directory before the template directory so themes
   -- which inherit from a parent theme can just override one file.
   --
   -- @since 4.7.0
   --
   -- @param string file Optional. File to search for in the stylesheet directory.
   -- @return string The path of the file.
   --
   function Get_Theme_File_Path (File : String := "")
                                 return String;

   --
   -- Retrieves the URL to the privacy policy page.
   --
   -- @since 4.9.6
   --
   -- @return string The URL to the privacy policy page. Empty string if it doesn't
   --                exist.
   --
   function Get_Privacy_Policy_URL
            return String;

   --
   -- Displays the privacy policy link with formatting, when applicable.
   --
   -- @since 4.9.6
   --
   -- @param string before Optional. Display before privacy policy link. Default empty.
   -- @param string after  Optional. Display after privacy policy link. Default empty.
   --
   procedure The_Privacy_Policy_Link (Before : String := "";
                                      After  : String := "");

   --
   -- Returns the privacy policy link with formatting, when applicable.
   --
   -- @since 4.9.6
   --
   -- @param string before Optional. Display before privacy policy link. Default empty.
   -- @param string after  Optional. Display after privacy policy link. Default empty.
   -- @return string Markup for the link and surrounding elements. Empty string if it
   --                doesn't exist.
   --
   function Get_The_Privacy_Policy_Link (Before : String := "";
                                         After  : String := "")
                                         return String;

   --
   -- Sets the scheme for a URL.
   --
   -- @since 3.4.0
   -- @since 4.4.0 The "rest" scheme was added.
   --
   -- @param string      url    Absolute URL that includes a scheme
   -- @param string|null scheme Optional. Scheme to give url. Currently "http",
   --                           "https", "login", "login_post", "admin", "relative",
   --                           "rest", "rpc", or null. Default null.
   -- @return string URL with chosen scheme.
   --
   function Set_URL_Scheme (URL    : String;
                            Scheme : String := "") -- null
                            return String;

   --
   -- Retrieves the URL used for the post preview.
   --
   -- Allows additional query args to be appended.
   --
   -- @since 4.4.0
   --
   -- @param int|WP_Post post         Optional. Post ID or `WP_Post` object. Defaults
   --                                  to global `post`.
   -- @param array       query_args   Optional. Array of additional query args to be
   --                                  appended to the link. Default empty array.
   -- @param string      preview_link Optional. Base preview link to be used if it
   --                                  should differ from the post permalink. Default
   --                                  empty.
   --
   -- @return string|null URL used for the post preview, or null if the post does not
   --                      exist.
   --
   function Get_Preview_Post_Link
      (Post         : Class_Posts.Wp_Post := Class_Posts.Null_Post;
       Query_Args   : Array_Type := Empty_Array;
       Preview_Link : String     := "")
       return String;

end Inc_Link_Templates;
