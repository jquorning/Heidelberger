--
-- General template tags that can go anywhere in a template.
--
-- @package WordPress
-- @subpackage Template
--

with Php.Calendar;

with Arrays;
with Lists;

with Class_Posts;

package Inc_General_Templates
is
   use Arrays;
   use Lists;

   Post_Not_Found  : exception;
   Some_Time_Error : exception;

   --
   -- Displays information about the current site.
   --
   -- @since 0.71
   --
   -- @see get_bloginfo() For possible `show` values
   --
   -- @param string show Optional. Site information to display. Default empty.
   --
   procedure Bloginfo (Show : String := "");

   --
   -- Determines whether the site has a Site Icon.
   --
   -- @since 4.3.0
   --
   -- @param int blog_id Optional. ID of the blog in question. Default current blog.
   -- @return bool Whether the site has a site icon or not.
   --
   function Has_Site_Icon (Blog_Id : Integer := 0)
                           return Boolean;

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
   -- - "text_direction" - The text direction determined by the site"s language.
   --   is_rtl() should be used instead
   -- - "language" - Language code for the current site
   -- - "stylesheet_url" - URL to the stylesheet for the active theme. An active
   --   child theme will take precedence over this value
   -- - "stylesheet_directory" - Directory path for the active theme.  An active
   --   child theme will take precedence over this value
   -- - "template_url" / "template_directory" - URL of the active theme"s directory.
   --   An active child theme will NOT take precedence over this value
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
   -- Retrieves the logout URL.
   --
   -- Returns the URL that allows the user to log out of the site.
   --
   -- @since 2.7.0
   --
   -- @param string redirect Path to redirect to on logout.
   -- @return string The logout URL. Note: HTML-encoded via esc_html() in
   --                 wp_nonce_url().
   --
   function Wp_Logout_URL (Redirect : String := "")
                           return String;

   --
   -- Returns the URL that allows the user to register on the site.
   --
   -- @since 3.6.0
   --
   -- @return string User registration URL.
   --
   function Wp_Registration_URL
            return String;

   --
   -- Returns the URL that allows the user to reset the lost password.
   --
   -- @since 2.8.0
   --
   -- @param string redirect Path to redirect to on login.
   -- @return string Lost password URL.
   --
   function Wp_Lostpassword_URL (Redirect : String := "")
                                 return String;

   --
   -- Retrieves the login URL.
   --
   -- @since 2.7.0
   --
   -- @param string redirect     Path to redirect to on log in.
   -- @param bool   force_reauth Whether to force reauthorization, even if a cookie
   --                             is present. Default false.
   -- @return string The login URL. Not HTML-encoded.
   --
   function Wp_Login_URL (Redirect     : String  := "";
                          Force_Reauth : Boolean := False)
                          return String;

   --
   -- Retrieves the contents of the search WordPress query variable.
   --
   -- The search query string is passed through esc_attr() to ensure that it is safe
   -- for placing in an HTML attribute.
   --
   -- @since 2.3.0
   --
   -- @param bool escaped Whether the result is escaped. Default true.
   --                      Only use when you are later escaping it. Do not use
   --                      unescaped.
   -- @return string
   --
   function Get_Search_Query (Escaped : Boolean := True)
                              return String;

   --
   -- Gets the language attributes for the "html" tag.
   --
   -- Builds up a set of HTML attributes containing the text direction and language
   -- information for the page.
   --
   -- @since 4.3.0
   --
   -- @param string doctype Optional. The type of HTML document. Accepts "xhtml" or
   --                        "html". Default "html".
   -- @return string A space-separated list of language attributes.
   --
   function Get_Language_Attributes (Doctype : String := "html")
                                     return String;

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
   procedure Language_Attributes (Doctype : String := "html");

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
                      Current  : String; -- Integer;
                      Echo     : Boolean := True)
                      return String;

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
   function Paginate_Links (Args : Array_Type := Empty_Array) -- ""
                            return String;

   --
   -- Returns the Site Icon URL.
   --
   -- @since 4.3.0
   --
   -- @param int    size    Optional. Size of the site icon. Default 512 (pixels).
   -- @param string url     Optional. Fallback url if no site icon is found. Default
   --                       empty.
   -- @param int    blog_id Optional. ID of the blog to get the site icon for.
   --                       Default current blog.
   -- @return string Site Icon URL.
   --
   function Get_Site_Icon_URL (Size    : Integer := 512;
                               URL     : String  := "";
                               Blog_Id : Integer := 0)
                               return String;

   --
   -- Outputs the HTML selected attribute.
   --
   -- Compares the first two arguments and if identical marks as selected.
   --
   -- @since 1.0.0
   --
   -- @param mixed selected One of the values to compare.
   -- @param mixed current  Optional. The other value to compare if not just true.
   --                        Default true.
   -- @param bool  echo     Optional. Whether to echo or just return the string.
   --                        Default true.
   -- @return string HTML attribute or empty string.
   --
   function Selected (Selectd : String;
                      Current : String; --  = true,
                      Echo    : Boolean := True)
                      return String;

   --
   -- Returns document title for the current page.
   --
   -- @since 4.4.0
   --
   -- @global int page  Page number of a single post.
   -- @global int paged Page number of a list of posts.
   --
   -- @return string Tag with the document title.
   --
   function Wp_Get_Document_Title
            return String;

   --
   -- Displays title tag with content.
   --
   -- @ignore
   -- @since 4.1.0
   -- @since 4.4.0 Improved title output replaced `wp_title()`.
   -- @access private
   --
   procedure X_Wp_Render_Title_Tag;

   --
   -- Displays or retrieves title for a post type archive.
   --
   -- This is optimized for archive.php and archive-thenpost_typeend;.php template
   -- files for displaying the title of the post type.
   --
   -- @since 3.1.0
   --
   -- @param string prefix  Optional. What to display before the title.
   -- @param bool   display Optional. Whether to display or retrieve title. Default
   --                        true.
   -- @return string|void Title when retrieving, null when displaying or failure.
   --
   function Post_Type_Archive_Title (Prefix  : String  := "";
                                     Display : Boolean := True)
                                     return String;

   --
   -- Displays or retrieves page title for post.
   --
   -- This is optimized for single.php template file for displaying the post title.
   --
   -- It does not support placing the separator after the title, but by leaving the
   -- prefix parameter empty, you can set the title separator manually. The prefix
   -- does not automatically place a space between the prefix, so if there should
   -- be a space, the parameter value will need to have it at the end.
   --
   -- @since 0.71
   --
   -- @param string prefix  Optional. What to display before the title.
   -- @param bool   display Optional. Whether to display or retrieve title. Default
   --                        true.
   -- @return string|void Title when retrieving.
   --
   function Single_Post_Title (Prefix  : String  := "";
                               Display : Boolean := True)
                               return String;

   --
   -- Displays or retrieves page title for tag post archive.
   --
   -- Useful for tag template files for displaying the tag page title. The prefix
   -- does not automatically place a space between the prefix, so if there should
   -- be a space, the parameter value will need to have it at the end.
   --
   -- @since 2.3.0
   --
   -- @param string prefix  Optional. What to display before the title.
   -- @param bool   display Optional. Whether to display or retrieve title. Default
   --                        true.
   -- @return string|void Title when retrieving.
   --
   function Single_Tag_Title (Prefix  : String  := "";
                              Display : Boolean := True)
                              return String;

   --
   -- Displays or retrieves page title for taxonomy term archive.
   --
   -- Useful for taxonomy term template files for displaying the taxonomy term page
   -- title. The prefix does not automatically place a space between the prefix, so
   -- if there should be a space, the parameter value will need to have it at the end.
   --
   -- @since 3.1.0
   --
   -- @param string $prefix  Optional. What to display before the title.
   -- @param bool   $display Optional. Whether to display or retrieve title. Default
   --                         true.
   -- @return string|void Title when retrieving.
   --
   function Single_Term_Title (Prefix  : String  := "";
                               Display : Boolean := True)
                               return String;

   --
   -- Retrieves the date on which the post was written.
   --
   -- Unlike the_date() this function will always return the date.
   -- Modify output with the {@see "get_the_date"} filter.
   --
   -- @since 3.0.0
   --
   -- @param string      format Optional. PHP date format. Defaults to the
   --                            "date_format" option.
   -- @param int|WP_Post post   Optional. Post ID or WP_Post object. Default current
   --                            post.
   -- @return string|int|false Date the current post was written. False on failure.
   --
   function Get_The_Date (Format : String := "";
                          Post   : Integer := 0) -- null
                          return String;

   --
   -- Retrieves the time at which the post was written.
   --
   -- @since 2.0.0
   --
   -- @param string      format    Optional. Format to use for retrieving the time
   --                               the post was written. Accepts "G", "U", or PHP
   --                               date format. Default "U".
   -- @param bool        gmt       Optional. Whether to retrieve the GMT time.
   --                               Default false.
   -- @param int|WP_Post post      Post ID or post object. Default is global `post`
   --                               object.
   -- @param bool        translate Whether to translate the time string. Default false.
   -- @return string|int|false Formatted date string or Unix timestamp if `format`
   --                           is "U" or "G". False on failure.
   --
   function Get_Post_Time (Format    : String  := "U";
                           GMT       : Boolean := False;
                           Post      : Class_Posts.Wp_Post;
                           Translate : Boolean := False)
                           return String;

   --
   -- Displays a referrer `strict-origin-when-cross-origin` meta tag.
   --
   -- Outputs a referrer `strict-origin-when-cross-origin` meta tag that tells the
   -- browser not to send the full URL as a referrer to other sites when cross-origin
   -- assets are loaded.
   --
   -- Typical usage is as a {@see "wp_head"} callback:
   --
   --     add_action( "wp_head", "wp_strict_cross_origin_referrer" );
   --
   -- @since 5.7.0
   --
   procedure Wp_Strict_Cross_Origin_Referrer;

   --
   -- Prints resource hints to browsers for pre-fetching, pre-rendering
   -- and pre-connecting to web sites.
   --
   -- Gives hints to browsers to prefetch specific pages or render them
   -- in the background, to perform DNS lookups or to begin the connection
   -- handshake (DNS, TCP, TLS) in the background.
   --
   -- These performance improving indicators work by using `<link rel"…">`.
   --
   -- @since 4.6.0
   --
   procedure Wp_Resource_Hints;

   --
   -- Prints resource preloads directives to browsers.
   --
   -- Gives directive to browsers to preload specific resources that website will
   -- need very soon, this ensures that they are available earlier and are less
   -- likely to block the page"s render. Preload directives should not be used for
   -- non-render-blocking elements, as then they would compete with the
   -- render-blocking ones, slowing down the render.
   --
   -- These performance improving indicators work by using `<link rel="preload">`.
   --
   -- @link https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types/preload
   -- @link https://web.dev/preload-responsive-images/
   --
   -- @since 6.1.0
   --
   procedure Wp_Preload_Resources;

   --
   -- Retrieves a list of unique hosts of all enqueued scripts and styles.
   --
   -- @since 4.6.0
   --
   -- @return string[] A list of unique hosts of enqueued scripts and styles.
   --
   function Wp_Dependencies_Unique_Hosts
            return List_Type;

   --
   -- Retrieves post published or modified time as a `DateTimeImmutable` object
   -- instance.
   --
   -- The object will be set to the timezone from WordPress settings.
   --
   -- For legacy reasons, this function allows to choose to instantiate from local or
   -- UTC time in database. Normally this should make no difference to the result.
   -- However, the values might get out of sync in database, typically because of
   -- timezone setting changes. The parameter ensures the ability to reproduce
   -- backwards compatible behaviors in such cases.
   --
   -- @since 5.3.0
   --
   -- @param int|WP_Post post   Optional. Post ID or post object. Default is global
   --                           `post` object.
   -- @param string      field  Optional. Published or modified time to use from
   --                            database. Accepts "date" or "modified".
   --                            Default "date".
   -- @param string      source Optional. Local or UTC time to use from database.
   --                           Accepts "local" or "gmt". Default "local".
   -- @return DateTimeImmutable|false Time object on success, false on failure.
   --
   function Get_Post_Datetime (Post   : Class_Posts.Wp_Post; -- = null,
                               Field  : String := "date";
                               Source : String := "local")
                               return Php.Calendar.Date_Time_Immutable;

   --
   -- Displays the URL of a WordPress admin CSS file.
   --
   -- @see WP_Styles::_css_href() and its {@see "style_loader_src"} filter.
   --
   -- @since 2.3.0
   --
   -- @param string file file relative to wp-admin/ without its ".css" extension.
   -- @return string
   --
   function Wp_Admin_CSS_URI (File : String := "wp-admin")
                              return String;

   --
   -- Enqueues or directly prints a stylesheet link to the specified CSS file.
   --
   -- "Intelligently" decides to enqueue or to print the CSS file. If the
   -- {@see "wp_print_styles"} action has *not* yet been called, the CSS file will be
   -- enqueued. If the {@see "wp_print_styles"} action has been called, the CSS link
   -- will be printed. Printing may be forced by passing true as the force_echo
   -- (second) parameter.
   --
   -- For backward compatibility with WordPress 2.3 calling method: If the file
   -- (first) parameter does not correspond to a registered CSS file, we assume
   -- file is a file relative to wp-admin/ without its ".css" extension. A
   -- stylesheet link to that generated URL is printed.
   --
   -- @since 2.3.0
   --
   -- @param string file       Optional. Style handle name or file name (without
   --                           ".css" extension) relative to wp-admin/. Defaults to
   --                           "wp-admin".
   -- @param bool   force_echo Optional. Force the stylesheet link to be printed
   --                           rather than enqueued.
   --
   procedure Wp_Admin_CSS (File       : String := "wp-admin";
                           Force_Echo : Boolean := False);

   --
   -- Outputs the HTML checked attribute.
   --
   -- Compares the first two arguments and if identical marks as checked.
   --
   -- @since 1.0.0
   --
   -- @param mixed checked One of the values to compare.
   -- @param mixed current Optional. The other value to compare if not just true.
   --                       Default true.
   -- @param bool  echo    Optional. Whether to echo or just return the string.
   --                       Default true.
   -- @return string HTML attribute or empty string.
   --
   function Checked (Checkd  : String;
                     Current : String;
                     Echo    : Boolean := True)
                     return String;

   function Checked (Checkd  : Integer;
                     Current : Integer;
                     Echo    : Boolean := True)
                     return String;

   function Checked (Checkd  : Boolean := True;
                     Current : Boolean := True;
                     Echo    : Boolean := True)
                     return String;

   --
   -- Private helper function for checked, selected, disabled and readonly.
   --
   -- Compares the first two arguments and if identical marks as `type`.
   --
   -- @since 2.8.0
   -- @access private
   --
   -- @param mixed  helper  One of the values to compare.
   -- @param mixed  current The other value to compare if not just true.
   -- @param bool   echo    Whether to echo or just return the string.
   -- @param string type    The type of checked|selected|disabled|readonly we are
   --                        doing.
   -- @return string HTML attribute or empty string.
   --
   function X_Checked_Selected_Helper (Helper  : String;
                                       Current : String;
                                       Echo    : Boolean;
                                       Typ     : String)
                                       return String;

   function X_Checked_Selected_Helper (Helper  : Integer;
                                       Current : Integer;
                                       Echo    : Boolean;
                                       Typ     : String)
                                       return String;

end Inc_General_Templates;
