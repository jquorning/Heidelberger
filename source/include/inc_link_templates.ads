--
-- WordPress Link Template Functions
--
-- @package WordPress
-- @subpackage Template
--

with Arrays;

with Inc_Class_Wp_Posts;

package Inc_Link_Templates
is
   use Arrays;

   procedure Dummy;

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
                                        return String
                                        is ("XXX-357");

--
-- Retrieves the full permalink for the current post or post ID.
--
-- @since 1.0.0
--
-- @param int|WP_Post post      Optional. Post ID or post object. Default is the global `post`.
-- @param bool        leavename Optional. Whether to keep post name or page name. Default false.
-- @return string|false The permalink URL. False if the post does not exist.
--
   function Get_Permalink (Post      : Integer := 0;
                           Leavename : Boolean := False)
                           return String
                           is ("XXX-358");

--
-- Retrieves the URL for a given site where the front end is accessible.
--
-- Returns the "home" option with the appropriate protocol. The protocol will be "https"
-- if is_ssl() evaluates to true; otherwise, it will be the same as the "home" option.
-- If `scheme` is "http" or "https", is_ssl() is overridden.
--
-- @since 3.0.0
--
-- @param int|null    blog_id Optional. Site ID. Default null (current site).
-- @param string      path    Optional. Path relative to the home URL. Default empty.
-- @param string|null scheme  Optional. Scheme to give the home URL context. Accepts
--                             "http", "https", "relative", "rest", or null. Default null.
-- @return string Home URL link with optional path appended.
--
   function Get_Home_Url (Blog_Id : Integer := 0; --  = null,
                          Path    : String  := "";
                          Scheme  : String  := "") -- = null
                          return String
                          is ("XXX-325");

--
-- Retrieves the URL to the admin area for the current user.
--
-- @since 3.0.0
--
-- @param string path   Optional. Path relative to the admin URL. Default empty.
-- @param string scheme Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
--                       and is_ssl(). "http" or "https" can be passed to force those schemes.
-- @return string Admin URL link with optional path appended.
--
   function User_Admin_Url (Path   : String := "";
                            Scheme : String := "admin")
                            return String
                            is ("XXX-342");

--
-- Retrieves the URL for the current site where the front end is accessible.
--
-- Returns the "home" option with the appropriate protocol. The protocol will be "https"
-- if is_ssl() evaluates to true; otherwise, it will be the same as the "home" option.
-- If `scheme` is "http" or "https", is_ssl() is overridden.
--
-- @since 3.0.0
--
-- @param string      path   Optional. Path relative to the home URL. Default empty.
-- @param string|null scheme Optional. Scheme to give the home URL context. Accepts
--                            "http", "https", "relative", "rest", or null. Default null.
-- @return string Home URL link with optional path appended.
--
   function Home_Url (Path   : String := "";
                      Scheme : String := "") --  = null
                      return String
                      is ("XXX-344");

--
-- Retrieves the URL to the user"s dashboard.
--
-- If a user does not belong to any site, the global user dashboard is used. If the user
-- belongs to the current site, the dashboard for the current site is returned. If the user
-- cannot edit the current site, the dashboard to the user"s primary site is returned.
--
-- @since 3.1.0
--
-- @param int    user_id Optional. User ID. Defaults to current user.
-- @param string path    Optional path relative to the dashboard. Use only paths known to
--                        both site and user admins. Default empty.
-- @param string scheme  The scheme to use. Default is "admin", which obeys force_ssl_admin()
--                        and is_ssl(). "http" or "https" can be passed to force those schemes.
-- @return string Dashboard URL link with optional path appended.
--
   function Get_Dashboard_Url (User_Id : Integer := 0;
                               Path    : String  := "";
                               Scheme  : String  := "admin")
                               return String
                               is ("XXX-351");

--
-- Retrieves the edit post link for post.
--
-- Can be used within the WordPress loop or outside of it. Can be used with
-- pages, posts, attachments, and revisions.
--
-- @since 2.3.0
--
-- @param int|WP_Post post    Optional. Post ID or post object. Default is the global `post`.
-- @param string      context Optional. How to output the "&" character. Default "&amp;".
-- @return string|null The edit post link for the given post. Null if the post type does not exist
--                     or does not allow an editing UI.
--
   function Get_Edit_Post_Link (Post    : Integer := 0;
                                Context : String  := "display")
                                return String
                                is ("XXX-444");

--
-- Retrieves the URL to the admin area for either the current site or the network depending on context.
--
-- @since 3.1.0
--
-- @param string path   Optional. Path relative to the admin URL. Default empty.
-- @param string scheme Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
--                       and is_ssl(). "http" or "https" can be passed to force those schemes.
-- @return string Admin URL link with optional path appended.
--
   function Self_Admin_Url (Path   : String := "";
                            Scheme : String := "admin")
                            return String
                            is ("XXX-352");
--
-- Retrieves the URL to the admin area for the current site.
--
-- @since 2.6.0
--
-- @param string path   Optional. Path relative to the admin URL. Default empty.
-- @param string scheme The scheme to use. Default is "admin", which obeys force_ssl_admin() and is_ssl().
--                       "http" or "https" can be passed to force those schemes.
-- @return string Admin URL link with optional path appended.
--
   function Admin_Url (Path   : String := "";
                       Scheme : String := "admin")
                       return String
                       is ("XXX-353");

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
   function Get_Admin_Url (Blog_Id : Integer := 0; --  = null
                           Path    : String  := "";
                           Scheme  : String  := "admin")
                           return String
                           is ("XXX-354");

--
-- Retrieves the URL to the admin area for the network.
--
-- @since 3.0.0
--
-- @param string path   Optional path relative to the admin URL. Default empty.
-- @param string scheme Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
--                       and is_ssl(). "http" or "https" can be passed to force those schemes.
-- @return string Admin URL link with optional path appended.
--
   function Network_Admin_Url (Path   : String := "";
                               Scheme : String := "admin")
                               return String
                               is ("XXX-401");

--
-- Retrieves the URL to the user"s profile editor.
--
-- @since 3.1.0
--
-- @param int    user_id Optional. User ID. Defaults to current user.
-- @param string scheme  Optional. The scheme to use. Default is "admin", which obeys force_ssl_admin()
--                        and is_ssl(). "http" or "https" can be passed to force those schemes.
-- @return string Dashboard URL link with optional path appended.
--
   function Get_Edit_Profile_Url (User_Id : Integer := 0;
                                  Scheme  : String  := "admin")
                                  return String
                                  is ("XXX-402");

--
-- Retrieves the edit user link.
--
-- @since 3.5.0
--
-- @param int user_id Optional. User ID. Defaults to the current user.
-- @return string URL to edit user page or empty string.
--
   function Get_Edit_User_Link (User_Id : Integer := 0) -- = null
                                return String
                                is ("XXX-371");

--
-- Retrieves the URL for editing a given term.
--
-- @since 3.1.0
-- @since 4.5.0 The `taxonomy` parameter was made optional.
--
-- @param int|WP_Term|object term        The ID or term object whose edit link will be retrieved.
-- @param string             taxonomy    Optional. Taxonomy. Defaults to the taxonomy of the term identified
--                                        by `term`.
-- @param string             object_type Optional. The object type. Used to highlight the proper post type
--                                        menu on the linked page. Defaults to the first object_type associated
--                                        with the taxonomy.
-- @return string|null The edit term link URL for the given term, or null on failure.
--
   function Get_Edit_Term_Link (Term        : Integer;
                                Taxonomy    : String := "";
                                Object_Type : String := "")
                                return String
                                is ("XXX-411");

--
-- Returns a shortlink for a post, page, attachment, or site.
--
-- This function exists to provide a shortlink tag that all themes and plugins can target.
-- A plugin must hook in to provide the actual shortlinks. Default shortlink support is
-- limited to providing ?p= style links for posts. Plugins can short-circuit this function
-- via the then@see "pre_get_shortlink"end; filter or filter the output via the then@see "get_shortlink"end;
-- filter.
--
-- @since 3.0.0
--
-- @param int    id          Optional. A post or site ID. Default is 0, which means the current post or site.
-- @param string context     Optional. Whether the ID is a "site" ID, "post" ID, or "media" ID. If "post",
--                            the post_type of the post is consulted. If "query", the current query is consulted
--                            to determine the ID and context. Default "post".
-- @param bool   allow_slugs Optional. Whether to allow post slugs in the shortlink. It is up to the plugin how
--                            and whether to honor this. Default true.
-- @return string A shortlink or an empty string if no shortlink exists for the requested resource or if shortlinks
--                are not enabled.
--
   function Wp_Get_Shortlink (Id          : Integer := 0;
                              Context     : String  := "post";
                              Allow_Slugs : Boolean := True)
                              return String
                              is ("XXX-356");

--
-- Retrieves the URL used for the post preview.
--
-- Allows additional query args to be appended.
--
-- @since 4.4.0
--
-- @param int|WP_Post post         Optional. Post ID or `WP_Post` object. Defaults to global `post`.
-- @param array       query_args   Optional. Array of additional query args to be appended to the link.
--                                  Default empty array.
-- @param string      preview_link Optional. Base preview link to be used if it should differ from the
--                                  post permalink. Default empty.
-- @return string|null URL used for the post preview, or null if the post does not exist.
--
   function Get_Preview_Post_Link
      (Post         : Inc_Class_Wp_Posts.Wp_Post := Inc_Class_Wp_Posts.Null_Post; -- Integer    := 0; -- = null
       Query_Args   : Array_Type := Empty_Array;
       Preview_Link : String     := "")
       return String
       is ("XXX-357");

end Inc_Link_Templates;
