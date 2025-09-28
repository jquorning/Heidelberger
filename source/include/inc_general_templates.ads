--
-- General template tags that can go anywhere in a template.
--
-- @package WordPress
-- @subpackage Template
--

with Arrays;

package Inc_General_Templates
is

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
   -- Displays information about the current site.
   --
   -- @since 0.71
   --
   -- @see get_bloginfo() For possible `show` values
   --
   -- @param string show Optional. Site information to display. Default empty.
   --
   procedure Bloginfo (Show : String := "")
   is null;

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
   --   can override the default value using the {@see "pre_option_html_type"} filter
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
                          return String;

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
-- Retrieves the contents of the search WordPress query variable.
--
-- The search query string is passed through esc_attr() to ensure that it is safe
-- for placing in an HTML attribute.
--
-- @since 2.3.0
--
-- @param bool escaped Whether the result is escaped. Default true.
--                      Only use when you are later escaping it. Do not use unescaped.
-- @return string
--
   function Get_Search_Query (Escaped : Boolean := True)
                              return String
                              is ("XXX-445");

   --
   -- Displays the language attributes for the "html" tag.
   --
   -- Builds up a set of HTML attributes containing the text direction and language
   -- information for the page.
   --
   -- @since 2.1.0
   -- @since 4.3.0 Converted into a wrapper for get_language_attributes().
   --
   -- @param string doctype Optional. The type of HTML document. Accepts "xhtml" or
   -- "html". Default "html".
   --
   procedure Language_Attributes (Doctype : String := "html")
   is null;

   --
   -- Outputs the HTML disabled attribute.
   --
   -- Compares the first two arguments and if identical marks as disabled.
   --
   -- @since 3.0.0
   --
   -- @param mixed disabled One of the values to compare.
   -- @param mixed current  Optional. The other value to compare if not just true.
   --                        Default true.
   -- @param bool  echo     Optional. Whether to echo or just return the string.
   --                        Default true.
   -- @return string HTML attribute or empty string.
   --
   function Disabled (Disabled : String;
                      Current  : Integer;
--                    Current  : Boolean := True;
                      Echo     : Boolean := True)
                      return String
                      is ("XXX-613");

   --
   -- Retrieves paginated links for archive post pages.
   --
   -- Technically, the function can be used to create paginated link list for any
   -- area. The "base" argument is used to reference the url, which will be used to
   -- create the paginated links. The "format" argument is then used for replacing
   -- the page number. It is however, most likely and by default, to be used on the
   -- archive post pages.
   --
   -- The "type" argument controls format of the returned value. The default is
   -- "plain", which is just a string with the links separated by a newline
   -- character. The other possible values are either "array" or "list". The
   -- "array" value will return an array of the paginated link list to offer full
   -- control of display. The "list" value will place all of the paginated links in
   -- an unordered HTML list.
   --
   -- The "total" argument is the total amount of pages and is an integer. The
   -- "current" argument is the current page number and is also an integer.
   --
   -- An example of the "base" argument is "http://example.com/all_posts.php%_%"
   -- and the "%_%" is required. The "%_%" will be replaced by the contents of in
   -- the "format" argument. An example for the "format" argument is "?page=%#%"
   -- and the "%#%" is also required. The "%#%" will be replaced with the page
   -- number.
   --
   -- You can include the previous and next links in the list by setting the
   -- "prev_next" argument to true, which it is by default. You can set the
   -- previous text, by using the "prev_text" argument. You can set the next text
   -- by setting the "next_text" argument.
   --
   -- If the "show_all" argument is set to true, then it will show all of the pages
   -- instead of a short list of the pages near the current page. By default, the
   -- "show_all" is set to false and controlled by the "end_size" and "mid_size"
   -- arguments. The "end_size" argument is how many numbers on either the start
   -- and the end list edges, by default is 1. The "mid_size" argument is how many
   -- numbers to either side of current page, but not including current page.
   --
   -- It is possible to add query vars to the link by using the "add_args" argument
   -- and see add_query_arg() for more information.
   --
   -- The "before_page_number" and "after_page_number" arguments allow users to
   -- augment the links themselves. Typically this might be to add context to the
   -- numbered links so that screen reader users understand what the links are for.
   -- The text strings are added before and after the page number - within the
   -- anchor tag.
   --
   -- @since 2.1.0
   -- @since 4.9.0 Added the `aria_current` argument.
   --
   -- @global WP_Query   wp_query   WordPress Query object.
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param string|array args {
   --     Optional. Array or string of arguments for generating paginated links for
   --     archives.
   --
   --     @type string base               Base of the paginated url. Default empty.
   --     @type string format             Format for the pagination structure. Default
   --                                     empty.
   --     @type int    total              The total amount of pages. Default is the
   --                                     value WP_Query"s `max_num_pages` or 1.
   --     @type int    current            The current page number. Default is "paged"
   --                                     query var or 1.
   --     @type string aria_current       The value for the aria-current attribute.
   --                                     Possible values are "page", "step",
   --                                     "location", "date", "time", "true", "false".
   --                                     Default is "page".
   --     @type bool   show_all           Whether to show all pages. Default false.
   --     @type int    end_size           How many numbers on either the start and the
   --                                     end list edges. Default 1.
   --     @type int    mid_size           How many numbers to either side of the
   --                                     current pages. Default 2.
   --     @type bool   prev_next          Whether to include the previous and next
   --                                     links in the list. Default true.
   --     @type string prev_text          The previous page text. Default "&laquo;
   --                                     Previous".
   --     @type string next_text          The next page text. Default "Next &raquo;".
   --     @type string type               Controls format of the returned value.
   --                                     Possible values are "plain", "array" and
   --                                     "list". Default is "plain".
   --     @type array  add_args           An array of query args to add. Default false.
   --     @type string add_fragment       A string to append to each link. Default
   --                                     empty.
   --     @type string before_page_number A string to appear before the page number.
   --                                     Default empty.
   --     @type string after_page_number  A string to append after the page number.
   --                                     Default empty.
   -- }
   -- @return string|string[]|void String of page links or array of page links,
   --                              depending on "type" argument. Void if total number
   --                              of pages is less than 2.
   --
   function Paginate_Links (Args : Arrays.Array_Type := Arrays.Empty_Array) -- ""
                            return String
                            is ("XXX-612");

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
