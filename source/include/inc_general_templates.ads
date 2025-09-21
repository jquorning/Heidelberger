--
-- General template tags that can go anywhere in a template.
--
-- @package WordPress
-- @subpackage Template
--
package Inc_General_Templates
is
   procedure Dummy;

--
-- Determines whether the site has a Site Icon.
--
-- @since 4.3.0
--
-- @param int blog_id Optional. ID of the blog in question. Default current blog.
-- @return bool Whether the site has a site icon or not.
--
   function Has_Site_Icon (Blog_Id : Integer := 0)
                           return Boolean
                           is (True);

--
-- Retrieves information about the current site.
--
-- Possible values for `show` include:
--
-- - "name" - Site title (set in Settings > General)
-- - "description" - Site tagline (set in Settings > General)
-- - "wpurl" - The WordPress address (URL) (set in Settings > General)
-- - "url" - The Site address (URL) (set in Settings > General)
-- - "admin_email" - Admin email (set in Settings > General)
-- - "charset" - The "Encoding for pages and feeds"  (set in Settings > Reading)
-- - "version" - The current WordPress version
-- - "html_type" - The content-type (default: "text/html"). Themes and plugins
--   can override the default value using the then@see "pre_option_html_type"end; filter
-- - "text_direction" - The text direction determined by the site"s language. is_rtl()
--   should be used instead
-- - "language" - Language code for the current site
-- - "stylesheet_url" - URL to the stylesheet for the active theme. An active child theme
--   will take precedence over this value
-- - "stylesheet_directory" - Directory path for the active theme.  An active child theme
--   will take precedence over this value
-- - "template_url" / "template_directory" - URL of the active theme"s directory. An active
--   child theme will NOT take precedence over this value
-- - "pingback_url" - The pingback XML-RPC file URL (xmlrpc.php)
-- - "atom_url" - The Atom feed URL (/feed/atom)
-- - "rdf_url" - The RDF/RSS 1.0 feed URL (/feed/rdf)
-- - "rss_url" - The RSS 0.92 feed URL (/feed/rss)
-- - "rss2_url" - The RSS 2.0 feed URL (/feed)
-- - "comments_atom_url" - The comments Atom feed URL (/comments/feed)
-- - "comments_rss2_url" - The comments RSS 2.0 feed URL (/comments/feed)
--
-- Some `show` values are deprecated and will be removed in future versions.
-- These options will trigger the _deprecated_argument() function.
--
-- Deprecated arguments include:
--
-- - "siteurl" - Use "url" instead
-- - "home" - Use "url" instead
--
-- @since 0.71
--
-- @global string wp_version The WordPress version string.
--
-- @param string show   Optional. Site info to retrieve. Default empty (site name).
-- @param string filter Optional. How to filter what is retrieved. Default "raw".
-- @return string Mostly string values, might be empty.
--
   function Get_Bloginfo (Show   : String := "";
                          Filter : String := "raw")
                          return String
                          is ("XXX-352");

--
-- Retrieves the login URL.
--
-- @since 2.7.0
--
-- @param string redirect     Path to redirect to on log in.
-- @param bool   force_reauth Whether to force reauthorization, even if a cookie is present.
--                             Default false.
-- @return string The login URL. Not HTML-encoded.
--
   function Wp_Login_Url (Redirect     : String  := "";
                          Force_Reauth : Boolean := False)
                          return String
                          is ("XXX-411");

--
-- Retrieves the logout URL.
--
-- Returns the URL that allows the user to log out of the site.
--
-- @since 2.7.0
--
-- @param string redirect Path to redirect to on logout.
-- @return string The logout URL. Note: HTML-encoded via esc_html() in wp_nonce_url().
--
   function Wp_Logout_Url (Redirect : String := "")
                           return String
                           is ("XXX-351");

--
-- Returns the Site Icon URL.
--
-- @since 4.3.0
--
-- @param int    size    Optional. Size of the site icon. Default 512 (pixels).
-- @param string url     Optional. Fallback url if no site icon is found. Default empty.
-- @param int    blog_id Optional. ID of the blog to get the site icon for. Default current blog.
-- @return string Site Icon URL.
--
   function Get_Site_Icon_Url (Size    : Integer := 512;
                               Url     : String  := "";
                               Blog_Id : Integer := 0)
                               return String
                               is ("XXX-355");

end Inc_General_Templates;
