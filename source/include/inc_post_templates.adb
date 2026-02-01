--
-- WordPress Post Template Functions.
--
-- Gets content for the current post in the loop.
--
-- @package WordPress
-- @subpackage Template
--

with Php.Echoing;
with Php.Strings;

with Inc_Formatting;
with Inc_Functions;
with Inc_Posts;

package body Inc_Post_Templates
is

-- --
-- -- Displays the ID of the current item in the WordPress Loop.
-- --
-- -- @since 0.71
-- --
-- function the_ID() then -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionNameInvalid
--         echo get_the_ID();
-- end;

   ----------------
   -- Get_The_Id --
   ----------------

   function Get_The_Id
            return Class_Posts.Post_Id_Type
   is
      use Class_Posts;
      use Inc_Posts;

      Post : constant Wp_Post := Get_Post;
   begin
      return (if Post = Null_Post then Post.Id else 0); -- False);
   end Get_The_Id;

-- --
-- -- Displays or retrieves the current post title with optional markup.
-- --
-- -- @since 0.71
-- --
-- -- @param string before Optional. Markup to prepend to the title. Default empty.
-- -- @param string after  Optional. Markup to append to the title. Default empty.
-- -- @param bool   echo   Optional. Whether to echo or return the title. Default true for echo.
-- -- @return void|string Void if `echo` argument is true, current post title if `echo` is false.
-- --
-- function the_title( before = "", after = "", echo = true ) then
--         title = get_the_title();

--         if ( strlen( title ) == 0 ) then
--                 return;
--         end;

--         title = before . title . after;

--         if ( echo ) then
--                 echo title;
--         end; else then
--                 return title;
--         end;
-- end;

   -------------------------
   -- The_Title_Attribute --
   -------------------------

   function The_Title_Attribute (Args : Array_Type) -- ""
                                 return String
   is
      use Php.Echoing;
      use Php.Strings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Posts;

      Defaults : constant Array_Type :=
        To_Array (List => (
          Build ("before", ""),
          Build ("after",  ""),
          Build ("echo",   True),
          Build ("post",   Get_Post)
        ));

      Parsed_Args : constant Array_Type := Wp_Parse_Args (Args, Defaults);

      Title_3 : constant String :=
        Get_The_Title (As_Integer (Get (Parsed_Args, "post")));
   begin
      if Strlen (Title_3) = 0 then
         return "";
      end if;

      declare
         Title_2 : constant String :=
           Get_As_String (Parsed_Args, "before") & Title_3 &
           Get_As_String (Parsed_Args, "after");

         Title : constant String := ESC_Attr (Strip_Tags (Title_2));
      begin
         if As_Boolean (Get (Parsed_Args, "echo")) then
            Echo (Title);
         else
            return Title;
         end if;
      end;
      return "";
   end The_Title_Attribute;

-- --
-- -- Retrieves the post title.
-- --
-- -- If the post is protected and the visitor is not an admin, then "Protected"
-- -- will be inserted before the post title. If the post is private, then
-- -- "Private" will be inserted before the post title.
-- --
-- -- @since 0.71
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- -- @return string
-- --
-- function get_the_title( post = 0 ) then
--         post = get_post( post );

--         post_title = isset( post.post_title ) ? post.post_title : "";
--         post_id    = isset( post.ID ) ? post.ID : 0;

--         if ( ! is_admin() ) then
--                 if ( ! empty( post.post_password ) ) then

--                         /* translators: %s: Protected post title.--
--                         prepend = __( "Protected: %s" );

--                         --
--                         -- Filters the text prepended to the post title for protected posts.
--                         --
--                         -- The filter is only applied on the front end.
--                         --
--                         -- @since 2.8.0
--                         --
--                         -- @param string  prepend Text displayed before the post title.
--                         --                         Default "Protected: %s".
--                         -- @param WP_Post post    Current post object.
--                         --
--                         protected_title_format = apply_filters( "protected_title_format", prepend, post );

--                         post_title = sprintf( protected_title_format, post_title );
--                 end; elseif ( isset( post.post_status ) && "private" === post.post_status ) then

--                         /* translators: %s: Private post title.--
--                         prepend = __( "Private: %s" );

--                         --
--                         -- Filters the text prepended to the post title of private posts.
--                         --
--                         -- The filter is only applied on the front end.
--                         --
--                         -- @since 2.8.0
--                         --
--                         -- @param string  prepend Text displayed before the post title.
--                         --                         Default "Private: %s".
--                         -- @param WP_Post post    Current post object.
--                         --
--                         private_title_format = apply_filters( "private_title_format", prepend, post );

--                         post_title = sprintf( private_title_format, post_title );
--                 end;
--         end;

--         --
--         -- Filters the post title.
--         --
--         -- @since 0.71
--         --
--         -- @param string post_title The post title.
--         -- @param int    post_id    The post ID.
--         --
--         return apply_filters( "the_title", post_title, post_id );
-- end;

-- --
-- -- Displays the Post Global Unique Identifier (guid).
-- --
-- -- The guid will appear to be a link, but should not be used as a link to the
-- -- post. The reason you should not use it as a link, is because of moving the
-- -- blog across domains.
-- --
-- -- URL is escaped to make it XML-safe.
-- --
-- -- @since 1.5.0
-- --
-- -- @param int|WP_Post post Optional. Post ID or post object. Default is global post.
-- --
-- function the_guid( post = 0 ) then
--         post = get_post( post );

--         post_guid = isset( post.guid ) ? get_the_guid( post ) : "";
--         post_id   = isset( post.ID ) ? post.ID : 0;

--         --
--         -- Filters the escaped Global Unique Identifier (guid) of the post.
--         --
--         -- @since 4.2.0
--         --
--         -- @see get_the_guid()
--         --
--         -- @param string post_guid Escaped Global Unique Identifier (guid) of the post.
--         -- @param int    post_id   The post ID.
--         --
--         echo apply_filters( "the_guid", post_guid, post_id );
-- end;

-- --
-- -- Retrieves the Post Global Unique Identifier (guid).
-- --
-- -- The guid will appear to be a link, but should not be used as an link to the
-- -- post. The reason you should not use it as a link, is because of moving the
-- -- blog across domains.
-- --
-- -- @since 1.5.0
-- --
-- -- @param int|WP_Post post Optional. Post ID or post object. Default is global post.
-- -- @return string
-- --
-- function get_the_guid( post = 0 ) then
--         post = get_post( post );

--         post_guid = isset( post.guid ) ? post.guid : "";
--         post_id   = isset( post.ID ) ? post.ID : 0;

--         --
--         -- Filters the Global Unique Identifier (guid) of the post.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string post_guid Global Unique Identifier (guid) of the post.
--         -- @param int    post_id   The post ID.
--         --
--         return apply_filters( "get_the_guid", post_guid, post_id );
-- end;

-- --
-- -- Displays the post content.
-- --
-- -- @since 0.71
-- --
-- -- @param string more_link_text Optional. Content for when there is more text.
-- -- @param bool   strip_teaser   Optional. Strip teaser content before the more text. Default false.
-- --
-- function the_content( more_link_text = null, strip_teaser = false ) then
--         content = get_the_content( more_link_text, strip_teaser );

--         --
--         -- Filters the post content.
--         --
--         -- @since 0.71
--         --
--         -- @param string content Content of the current post.
--         --
--         content = apply_filters( "the_content", content );
--         content = str_replace( "]]>", "]]&gt;", content );
--         echo content;
-- end;

-- --
-- -- Retrieves the post content.
-- --
-- -- @since 0.71
-- -- @since 5.2.0 Added the `post` parameter.
-- --
-- -- @global int   page      Page number of a single post/page.
-- -- @global int   more      Boolean indicator for whether single post/page is being viewed.
-- -- @global bool  preview   Whether post/page is in preview mode.
-- -- @global array pages     Array of all pages in post/page. Each array element contains
-- --                          part of the content separated by the `<!--nextpage-.` tag.
-- -- @global int   multipage Boolean indicator for whether multiple pages are in play.
-- --
-- -- @param string             more_link_text Optional. Content for when there is more text.
-- -- @param bool               strip_teaser   Optional. Strip teaser content before the more text. Default false.
-- -- @param WP_Post|object|int post           Optional. WP_Post instance or Post ID/object. Default null.
-- -- @return string
-- --
-- function get_the_content( more_link_text = null, strip_teaser = false, post = null ) then
--         global page, more, preview, pages, multipage;

--         _post = get_post( post );

--         if ( ! ( _post instanceof WP_Post ) ) then
--                 return "";
--         end;

--         -- Use the globals if the post parameter was not specified,
--         -- but only after they have been set up in setup_postdata().
--         if ( null === post && did_action( "the_post" ) ) then
--                 elements = compact( "page", "more", "preview", "pages", "multipage" );
--         end; else then
--                 elements = generate_postdata( _post );
--         end;

--         if ( null === more_link_text ) then
--                 more_link_text = sprintf(
--                         "<span aria-label="%1s">%2s</span>",
--                         sprintf(
--                                 /* translators: %s: Post title.--
--                                 __( "Continue reading %s" ),
--                                 the_title_attribute(
--                                         array(
--                                                 "echo" => false,
--                                                 "post" => _post,
--                                         )
--                                 )
--                         ),
--                         __( "(more&hellip;)" )
--                 );
--         end;

--         output     = "";
--         has_teaser = false;

--         -- If post password required and it doesn"t match the cookie.
--         if ( post_password_required( _post ) ) then
--                 return get_the_password_form( _post );
--         end;

--         -- If the requested page doesn"t exist.
--         if ( elements["page"] > count( elements["pages"] ) ) then
--                 -- Give them the highest numbered page that DOES exist.
--                 elements["page"] = count( elements["pages"] );
--         end;

--         page_no = elements["page"];
--         content = elements["pages"][ page_no - 1 ];
--         if ( preg_match( "/<!--more(.*?)?-./", content, matches ) ) then
--                 if ( has_block( "more", content ) ) then
--                         -- Remove the core/more block delimiters. They will be left over after content is split up.
--                         content = preg_replace( "/<!-- \/?wp:more(.*?) -./", "", content );
--                 end;

--                 content = explode( matches[0], content, 2 );

--                 if ( ! empty( matches[1] ) && ! empty( more_link_text ) ) then
--                         more_link_text = strip_tags( wp_kses_no_null( trim( matches[1] ) ) );
--                 end;

--                 has_teaser = true;
--         end; else then
--                 content = array( content );
--         end;

--         if ( false !== strpos( _post.post_content, "<!--noteaser-." ) && ( ! elements["multipage"] || 1 == elements["page"] ) ) then
--                 strip_teaser = true;
--         end;

--         teaser = content[0];

--         if ( elements["more"] && strip_teaser && has_teaser ) then
--                 teaser = "";
--         end;

--         output .= teaser;

--         if ( count( content ) > 1 ) then
--                 if ( elements["more"] ) then
--                         output .= "<span id="more-" . _post.ID . ""></span>" . content[1];
--                 end; else then
--                         if ( ! empty( more_link_text ) ) then

--                                 --
--                                 -- Filters the Read More link text.
--                                 --
--                                 -- @since 2.8.0
--                                 --
--                                 -- @param string more_link_element Read More link element.
--                                 -- @param string more_link_text    Read More text.
--                                 --
--                                 output .= apply_filters( "the_content_more_link", " <a href="" . get_permalink( _post ) . "#more-then_post.IDend;\" class=\"more-link\">more_link_text</a>", more_link_text );
--                         end;
--                         output = force_balance_tags( output );
--                 end;
--         end;

--         return output;
-- end;

-- --
-- -- Displays the post excerpt.
-- --
-- -- @since 0.71
-- --
-- function the_excerpt() then

--         --
--         -- Filters the displayed post excerpt.
--         --
--         -- @since 0.71
--         --
--         -- @see get_the_excerpt()
--         --
--         -- @param string post_excerpt The post excerpt.
--         --
--         echo apply_filters( "the_excerpt", get_the_excerpt() );
-- end;

-- --
-- -- Retrieves the post excerpt.
-- --
-- -- @since 0.71
-- -- @since 4.5.0 Introduced the `post` parameter.
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- -- @return string Post excerpt.
-- --
-- function get_the_excerpt( post = null ) then
--         if ( is_bool( post ) ) then
--                 _deprecated_argument( __FUNCTION__, "2.3.0" );
--         end;

--         post = get_post( post );
--         if ( empty( post ) ) then
--                 return "";
--         end;

--         if ( post_password_required( post ) ) then
--                 return __( "There is no excerpt because this is a protected post." );
--         end;

--         --
--         -- Filters the retrieved post excerpt.
--         --
--         -- @since 1.2.0
--         -- @since 4.5.0 Introduced the `post` parameter.
--         --
--         -- @param string  post_excerpt The post excerpt.
--         -- @param WP_Post post         Post object.
--         --
--         return apply_filters( "get_the_excerpt", post.post_excerpt, post );
-- end;

-- --
-- -- Determines whether the post has a custom excerpt.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tags} article in the Theme Developer Handbook.
-- --
-- -- @since 2.3.0
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- -- @return bool True if the post has a custom excerpt, false otherwise.
-- --
-- function has_excerpt( post = 0 ) then
--         post = get_post( post );
--         return ( ! empty( post.post_excerpt ) );
-- end;

-- --
-- -- Displays the classes for the post container element.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string|string[] class One or more classes to add to the class list.
-- -- @param int|WP_Post     post  Optional. Post ID or post object. Defaults to the global `post`.
-- --
-- function post_class( class = "", post = null ) then
--         -- Separates classes with a single space, collates classes for post DIV.
--         echo "class="" . esc_attr( implode( " ", get_post_class( class, post ) ) ) . """;
-- end;

-- --
-- -- Retrieves an array of the class names for the post container element.
-- --
-- -- The class names are many. If the post is a sticky, then the "sticky"
-- -- class name. The class "hentry" is always added to each post. If the post has a
-- -- post thumbnail, "has-post-thumbnail" is added as a class. For each taxonomy that
-- -- the post belongs to, a class will be added of the format "thentaxonomyend;-thenslugend;" -
-- -- eg "category-foo" or "my_custom_taxonomy-bar".
-- --
-- -- The "post_tag" taxonomy is a special
-- -- case; the class has the "tag-" prefix instead of "post_tag-". All class names are
-- -- passed through the filter, {@see "post_class"}, with the list of class names, followed by
-- -- class parameter value, with the post ID as the last parameter.
-- --
-- -- @since 2.7.0
-- -- @since 4.2.0 Custom taxonomy class names were added.
-- --
-- -- @param string|string[] class Space-separated string or array of class names to add to the class list.
-- -- @param int|WP_Post     post  Optional. Post ID or post object.
-- -- @return string[] Array of class names.
-- --
-- function get_post_class( class = "", post = null ) then
--         post = get_post( post );

--         classes = array();

--         if ( class ) then
--                 if ( ! is_array( class ) ) then
--                         class = preg_split( "#\s+#", class );
--                 end;
--                 classes = array_map( "esc_attr", class );
--         end; else then
--                 -- Ensure that we always coerce class to being an array.
--                 class = array();
--         end;

--         if ( ! post ) then
--                 return classes;
--         end;

--         classes[] = "post-" . post.ID;
--         if ( ! is_admin() ) then
--                 classes[] = post.post_type;
--         end;
--         classes[] = "type-" . post.post_type;
--         classes[] = "status-" . post.post_status;

--         -- Post Format.
--         if ( post_type_supports( post.post_type, "post-formats" ) ) then
--                 post_format = get_post_format( post.ID );

--                 if ( post_format && ! is_wp_error( post_format ) ) then
--                         classes[] = "format-" . sanitize_html_class( post_format );
--                 end; else then
--                         classes[] = "format-standard";
--                 end;
--         end;

--         post_password_required = post_password_required( post.ID );

--         -- Post requires password.
--         if ( post_password_required ) then
--                 classes[] = "post-password-required";
--         end; elseif ( ! empty( post.post_password ) ) then
--                 classes[] = "post-password-protected";
--         end;

--         -- Post thumbnails.
--         if ( current_theme_supports( "post-thumbnails" ) && has_post_thumbnail( post.ID ) && ! is_attachment( post ) && ! post_password_required ) then
--                 classes[] = "has-post-thumbnail";
--         end;

--         -- Sticky for Sticky Posts.
--         if ( is_sticky( post.ID ) ) then
--                 if ( is_home() && ! is_paged() ) then
--                         classes[] = "sticky";
--                 end; elseif ( is_admin() ) then
--                         classes[] = "status-sticky";
--                 end;
--         end;

--         -- hentry for hAtom compliance.
--         classes[] = "hentry";

--         -- All public taxonomies.
--         taxonomies = get_taxonomies( array( "public" => true ) );

--         --
--         -- Filters the taxonomies to generate classes for each individual term.
--         --
--         -- Default is all public taxonomies registered to the post type.
--         --
--         -- @since 6.1.0
--         --
--         -- @param string[] taxonomies List of all taxonomy names to generate classes for.
--         -- @param int      post_id    The post ID.
--         -- @param string[] classes    An array of post class names.
--         -- @param string[] class      An array of additional class names added to the post.
--        --
--         taxonomies = apply_filters( "post_class_taxonomies", taxonomies, post.ID, classes, class );

--         foreach ( (array) taxonomies as taxonomy ) then
--                 if ( is_object_in_taxonomy( post.post_type, taxonomy ) ) then
--                         foreach ( (array) get_the_terms( post.ID, taxonomy ) as term ) then
--                                 if ( empty( term.slug ) ) then
--                                         continue;
--                                 end;

--                                 term_class = sanitize_html_class( term.slug, term.term_id );
--                                 if ( is_numeric( term_class ) || ! trim( term_class, "-" ) ) then
--                                         term_class = term.term_id;
--                                 end;

--                                 -- "post_tag" uses the "tag" prefix for backward compatibility.
--                                 if ( "post_tag" === taxonomy ) then
--                                         classes[] = "tag-" . term_class;
--                                 end; else then
--                                         classes[] = sanitize_html_class( taxonomy . "-" . term_class, taxonomy . "-" . term.term_id );
--                                 end;
--                         end;
--                 end;
--         end;

--         classes = array_map( "esc_attr", classes );

--         --
--         -- Filters the list of CSS class names for the current post.
--         --
--         -- @since 2.7.0
--         --
--         -- @param string[] classes An array of post class names.
--         -- @param string[] class   An array of additional class names added to the post.
--         -- @param int      post_id The post ID.
--         --
--         classes = apply_filters( "post_class", classes, class, post.ID );

--         return array_unique( classes );
-- end;

-- --
-- -- Displays the class names for the body element.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string|string[] class Space-separated string or array of class names to add to the class list.
-- --
-- function body_class( class = "" ) then
--         -- Separates class names with a single space, collates class names for body element.
--         echo "class="" . esc_attr( implode( " ", get_body_class( class ) ) ) . """;
-- end;

-- --
-- -- Retrieves an array of the class names for the body element.
-- --
-- -- @since 2.8.0
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param string|string[] class Space-separated string or array of class names to add to the class list.
-- -- @return string[] Array of class names.
-- --
-- function get_body_class( class = "" ) then
--         global wp_query;

--         classes = array();

--         if ( is_rtl() ) then
--                 classes[] = "rtl";
--         end;

--         if ( is_front_page() ) then
--                 classes[] = "home";
--         end;
--         if ( is_home() ) then
--                 classes[] = "blog";
--         end;
--         if ( is_privacy_policy() ) then
--                 classes[] = "privacy-policy";
--         end;
--         if ( is_archive() ) then
--                 classes[] = "archive";
--         end;
--         if ( is_date() ) then
--                 classes[] = "date";
--         end;
--         if ( is_search() ) then
--                 classes[] = "search";
--                 classes[] = wp_query.posts ? "search-results" : "search-no-results";
--         end;
--         if ( is_paged() ) then
--                 classes[] = "paged";
--         end;
--         if ( is_attachment() ) then
--                 classes[] = "attachment";
--         end;
--         if ( is_404() ) then
--                 classes[] = "error404";
--         end;

--         if ( is_singular() ) then
--                 post_id   = wp_query.get_queried_object_id();
--                 post      = wp_query.get_queried_object();
--                 post_type = post.post_type;

--                 if ( is_page_template() ) then
--                         classes[] = "thenpost_typeend;-template";

--                         template_slug  = get_page_template_slug( post_id );
--                         template_parts = explode( "/", template_slug );

--                         foreach ( template_parts as part ) then
--                                 classes[] = "thenpost_typeend;-template-" . sanitize_html_class( str_replace( array( ".", "/" ), "-", basename( part, ".php" ) ) );
--                         end;
--                         classes[] = "thenpost_typeend;-template-" . sanitize_html_class( str_replace( ".", "-", template_slug ) );
--                 end; else then
--                         classes[] = "thenpost_typeend;-template-default";
--                 end;

--                 if ( is_single() ) then
--                         classes[] = "single";
--                         if ( isset( post.post_type ) ) then
--                                 classes[] = "single-" . sanitize_html_class( post.post_type, post_id );
--                                 classes[] = "postid-" . post_id;

--                                 -- Post Format.
--                                 if ( post_type_supports( post.post_type, "post-formats" ) ) then
--                                         post_format = get_post_format( post.ID );

--                                         if ( post_format && ! is_wp_error( post_format ) ) then
--                                                 classes[] = "single-format-" . sanitize_html_class( post_format );
--                                         end; else then
--                                                 classes[] = "single-format-standard";
--                                         end;
--                                 end;
--                         end;
--                 end;

--                 if ( is_attachment() ) then
--                         mime_type   = get_post_mime_type( post_id );
--                         mime_prefix = array( "application/", "image/", "text/", "audio/", "video/", "music/" );
--                         classes[]   = "attachmentid-" . post_id;
--                         classes[]   = "attachment-" . str_replace( mime_prefix, "", mime_type );
--                 end; elseif ( is_page() ) then
--                         classes[] = "page";

--                         page_id = wp_query.get_queried_object_id();

--                         post = get_post( page_id );

--                         classes[] = "page-id-" . page_id;

--                         if ( get_pages(
--                                 array(
--                                         "parent" => page_id,
--                                         "number" => 1,
--                                 )
--                         ) ) then
--                                 classes[] = "page-parent";
--                         end;

--                         if ( post.post_parent ) then
--                                 classes[] = "page-child";
--                                 classes[] = "parent-pageid-" . post.post_parent;
--                         end;
--                 end;
--         end; elseif ( is_archive() ) then
--                 if ( is_post_type_archive() ) then
--                         classes[] = "post-type-archive";
--                         post_type = get_query_var( "post_type" );
--                         if ( is_array( post_type ) ) then
--                                 post_type = reset( post_type );
--                         end;
--                         classes[] = "post-type-archive-" . sanitize_html_class( post_type );
--                 end; elseif ( is_author() ) then
--                         author    = wp_query.get_queried_object();
--                         classes[] = "author";
--                         if ( isset( author.user_nicename ) ) then
--                                 classes[] = "author-" . sanitize_html_class( author.user_nicename, author.ID );
--                                 classes[] = "author-" . author.ID;
--                         end;
--                 end; elseif ( is_category() ) then
--                         cat       = wp_query.get_queried_object();
--                         classes[] = "category";
--                         if ( isset( cat.term_id ) ) then
--                                 cat_class = sanitize_html_class( cat.slug, cat.term_id );
--                                 if ( is_numeric( cat_class ) || ! trim( cat_class, "-" ) ) then
--                                         cat_class = cat.term_id;
--                                 end;

--                                 classes[] = "category-" . cat_class;
--                                 classes[] = "category-" . cat.term_id;
--                         end;
--                 end; elseif ( is_tag() ) then
--                         tag       = wp_query.get_queried_object();
--                         classes[] = "tag";
--                         if ( isset( tag.term_id ) ) then
--                                 tag_class = sanitize_html_class( tag.slug, tag.term_id );
--                                 if ( is_numeric( tag_class ) || ! trim( tag_class, "-" ) ) then
--                                         tag_class = tag.term_id;
--                                 end;

--                                 classes[] = "tag-" . tag_class;
--                                 classes[] = "tag-" . tag.term_id;
--                         end;
--                 end; elseif ( is_tax() ) then
--                         term = wp_query.get_queried_object();
--                         if ( isset( term.term_id ) ) then
--                                 term_class = sanitize_html_class( term.slug, term.term_id );
--                                 if ( is_numeric( term_class ) || ! trim( term_class, "-" ) ) then
--                                         term_class = term.term_id;
--                                 end;

--                                 classes[] = "tax-" . sanitize_html_class( term.taxonomy );
--                                 classes[] = "term-" . term_class;
--                                 classes[] = "term-" . term.term_id;
--                         end;
--                 end;
--         end;

--         if ( is_user_logged_in() ) then
--                 classes[] = "logged-in";
--         end;

--         if ( is_admin_bar_showing() ) then
--                 classes[] = "admin-bar";
--                 classes[] = "no-customize-support";
--         end;

--         if ( current_theme_supports( "custom-background" )
--                 && ( get_background_color() !== get_theme_support( "custom-background", "default-color" ) || get_background_image() ) ) then
--                 classes[] = "custom-background";
--         end;

--         if ( has_custom_logo() ) then
--                 classes[] = "wp-custom-logo";
--         end;

--         if ( current_theme_supports( "responsive-embeds" ) ) then
--                 classes[] = "wp-embed-responsive";
--         end;

--         page = wp_query.get( "page" );

--         if ( ! page || page < 2 ) then
--                 page = wp_query.get( "paged" );
--         end;

--         if ( page && page > 1 && ! is_404() ) then
--                 classes[] = "paged-" . page;

--                 if ( is_single() ) then
--                         classes[] = "single-paged-" . page;
--                 end; elseif ( is_page() ) then
--                         classes[] = "page-paged-" . page;
--                 end; elseif ( is_category() ) then
--                         classes[] = "category-paged-" . page;
--                 end; elseif ( is_tag() ) then
--                         classes[] = "tag-paged-" . page;
--                 end; elseif ( is_date() ) then
--                         classes[] = "date-paged-" . page;
--                 end; elseif ( is_author() ) then
--                         classes[] = "author-paged-" . page;
--                 end; elseif ( is_search() ) then
--                         classes[] = "search-paged-" . page;
--                 end; elseif ( is_post_type_archive() ) then
--                         classes[] = "post-type-paged-" . page;
--                 end;
--         end;

--         if ( ! empty( class ) ) then
--                 if ( ! is_array( class ) ) then
--                         class = preg_split( "#\s+#", class );
--                 end;
--                 classes = array_merge( classes, class );
--         end; else then
--                 -- Ensure that we always coerce class to being an array.
--                 class = array();
--         end;

--         classes = array_map( "esc_attr", classes );

--         --
--         -- Filters the list of CSS body class names for the current post or page.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string[] classes An array of body class names.
--         -- @param string[] class   An array of additional class names added to the body.
--         --
--         classes = apply_filters( "body_class", classes, class );

--         return array_unique( classes );
-- end;

-- --
-- -- Determines whether the post requires password and whether a correct password has been provided.
-- --
-- -- @since 2.7.0
-- --
-- -- @param int|WP_Post|null post An optional post. Global post used if not provided.
-- -- @return bool false if a password is not required or the correct password cookie is present, true otherwise.
-- --
-- function post_password_required( post = null ) then
--         post = get_post( post );

--         if ( empty( post.post_password ) ) then
--                 -- This filter is documented in wp-includes/post-template.php--
--                 return apply_filters( "post_password_required", false, post );
--         end;

--         if ( ! isset( _COOKIE[ "wp-postpass_" . COOKIEHASH ] ) ) then
--                 -- This filter is documented in wp-includes/post-template.php--
--                 return apply_filters( "post_password_required", true, post );
--         end;

--         require_once ABSPATH . WPINC . "/class-phpass.php";
--         hasher = new PasswordHash( 8, true );

--         hash = wp_unslash( _COOKIE[ "wp-postpass_" . COOKIEHASH ] );
--         if ( 0 !== strpos( hash, "PB" ) ) then
--                 required = true;
--         end; else then
--                 required = ! hasher.CheckPassword( post.post_password, hash );
--         end;

--         --
--         -- Filters whether a post requires the user to supply a password.
--         --
--         -- @since 4.7.0
--         --
--         -- @param bool    required Whether the user needs to supply a password. True if password has not been
--         --                          provided or is incorrect, false if password has been supplied or is not required.
--         -- @param WP_Post post     Post object.
--         --
--         return apply_filters( "post_password_required", required, post );
-- end;

-- --
-- -- Page Template Functions for usage in Themes.
-- --

-- --
-- -- The formatted output of a list of pages.
-- --
-- -- Displays page links for paginated posts (i.e. including the `<!--nextpage-.`
-- -- Quicktag one or more times). This tag must be within The Loop.
-- --
-- -- @since 1.2.0
-- -- @since 5.1.0 Added the `aria_current` argument.
-- --
-- -- @global int page
-- -- @global int numpages
-- -- @global int multipage
-- -- @global int more
-- --
-- -- @param string|array args then
-- --     Optional. Array or string of default arguments.
-- --
-- --     @type string       before           HTML or text to prepend to each link. Default is `<p> Pages:`.
-- --     @type string       after            HTML or text to append to each link. Default is `</p>`.
-- --     @type string       link_before      HTML or text to prepend to each link, inside the `<a>` tag.
-- --                                          Also prepended to the current item, which is not linked. Default empty.
-- --     @type string       link_after       HTML or text to append to each Pages link inside the `<a>` tag.
-- --                                          Also appended to the current item, which is not linked. Default empty.
-- --     @type string       aria_current     The value for the aria-current attribute. Possible values are "page",
-- --                                          "step", "location", "date", "time", "true", "false". Default is "page".
-- --     @type string       next_or_number   Indicates whether page numbers should be used. Valid values are number
-- --                                          and next. Default is "number".
-- --     @type string       separator        Text between pagination links. Default is " ".
-- --     @type string       nextpagelink     Link text for the next page link, if available. Default is "Next Page".
-- --     @type string       previouspagelink Link text for the previous page link, if available. Default is "Previous Page".
-- --     @type string       pagelink         Format string for page numbers. The % in the parameter string will be
-- --                                          replaced with the page number, so "Page %" generates "Page 1", "Page 2", etc.
-- --                                          Defaults to "%", just the page number.
-- --     @type int|bool     echo             Whether to echo or not. Accepts 1|true or 0|false. Default 1|true.
-- -- end;
-- -- @return string Formatted output in HTML.
-- --
-- function wp_link_pages( args = "" ) then
--         global page, numpages, multipage, more;

--         defaults = array(
--                 "before"           => "<p class="post-nav-links">" . __( "Pages:" ),
--                 "after"            => "</p>",
--                 "link_before"      => "",
--                 "link_after"       => "",
--                 "aria_current"     => "page",
--                 "next_or_number"   => "number",
--                 "separator"        => " ",
--                 "nextpagelink"     => __( "Next page" ),
--                 "previouspagelink" => __( "Previous page" ),
--                 "pagelink"         => "%",
--                 "echo"             => 1,
--         );

--         parsed_args = wp_parse_args( args, defaults );

--         --
--         -- Filters the arguments used in retrieving page links for paginated posts.
--         --
--         -- @since 3.0.0
--         --
--         -- @param array parsed_args An array of page link arguments. See wp_link_pages()
--         --                           for information on accepted arguments.
--         --
--         parsed_args = apply_filters( "wp_link_pages_args", parsed_args );

--         output = "";
--         if ( multipage ) then
--                 if ( "number" === parsed_args["next_or_number"] ) then
--                         output .= parsed_args["before"];
--                         for ( i = 1; i <= numpages; i++ ) then
--                                 link = parsed_args["link_before"] . str_replace( "%", i, parsed_args["pagelink"] ) . parsed_args["link_after"];
--                                 if ( i != page || ! more && 1 == page ) then
--                                         link = _wp_link_page( i ) . link . "</a>";
--                                 end; elseif ( i === page ) then
--                                         link = "<span class="post-page-numbers current" aria-current="" . esc_attr( parsed_args["aria_current"] ) . "">" . link . "</span>";
--                                 end;
--                                 --
--                                 -- Filters the HTML output of individual page number links.
--                                 --
--                                 -- @since 3.6.0
--                                 --
--                                 -- @param string link The page number HTML output.
--                                 -- @param int    i    Page number for paginated posts" page links.
--                                 --
--                                 link = apply_filters( "wp_link_pages_link", link, i );

--                                 -- Use the custom links separator beginning with the second link.
--                                 output .= ( 1 === i ) ? " " : parsed_args["separator"];
--                                 output .= link;
--                         end;
--                         output .= parsed_args["after"];
--                 end; elseif ( more ) then
--                         output .= parsed_args["before"];
--                         prev    = page - 1;
--                         if ( prev > 0 ) then
--                                 link = _wp_link_page( prev ) . parsed_args["link_before"] . parsed_args["previouspagelink"] . parsed_args["link_after"] . "</a>";

--                                 -- This filter is documented in wp-includes/post-template.php--
--                                 output .= apply_filters( "wp_link_pages_link", link, prev );
--                         end;
--                         next = page + 1;
--                         if ( next <= numpages ) then
--                                 if ( prev ) then
--                                         output .= parsed_args["separator"];
--                                 end;
--                                 link = _wp_link_page( next ) . parsed_args["link_before"] . parsed_args["nextpagelink"] . parsed_args["link_after"] . "</a>";

--                                 -- This filter is documented in wp-includes/post-template.php--
--                                 output .= apply_filters( "wp_link_pages_link", link, next );
--                         end;
--                         output .= parsed_args["after"];
--                 end;
--         end;

--         --
--         -- Filters the HTML output of page links for paginated posts.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string       output HTML output of paginated posts" page links.
--         -- @param array|string args   An array or query string of arguments. See wp_link_pages()
--         --                             for information on accepted arguments.
--         --
--         html = apply_filters( "wp_link_pages", output, args );

--         if ( parsed_args["echo"] ) then
--                 echo html;
--         end;
--         return html;
-- end;

-- --
-- -- Helper function for wp_link_pages().
-- --
-- -- @since 3.1.0
-- -- @access private
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param int i Page number.
-- -- @return string Link.
-- --
-- function _wp_link_page( i ) then
--         global wp_rewrite;
--         post       = get_post();
--         query_args = array();

--         if ( 1 == i ) then
--                 url = get_permalink();
--         end; else then
--                 if ( ! get_option( "permalink_structure" ) || in_array( post.post_status, array( "draft", "pending" ), true ) ) then
--                         url = add_query_arg( "page", i, get_permalink() );
--                 end; elseif ( "page" === get_option( "show_on_front" ) && get_option( "page_on_front" ) == post.ID ) then
--                         url = trailingslashit( get_permalink() ) . user_trailingslashit( "wp_rewrite.pagination_base/" . i, "single_paged" );
--                 end; else then
--                         url = trailingslashit( get_permalink() ) . user_trailingslashit( i, "single_paged" );
--                 end;
--         end;

--         if ( is_preview() ) then

--                 if ( ( "draft" !== post.post_status ) && isset( _GET["preview_id"], _GET["preview_nonce"] ) ) then
--                         query_args["preview_id"]    = wp_unslash( _GET["preview_id"] );
--                         query_args["preview_nonce"] = wp_unslash( _GET["preview_nonce"] );
--                 end;

--                 url = get_preview_post_link( post, query_args, url );
--         end;

--         return "<a href="" . esc_url( url ) . "" class="post-page-numbers">";
-- end;

-- --
-- -- Post-meta: Custom per-post fields.
-- --

-- --
-- -- Retrieves post custom meta data field.
-- --
-- -- @since 1.5.0
-- --
-- -- @param string key Meta data key name.
-- -- @return array|string|false Array of values, or single value if only one element exists.
-- --                            False if the key does not exist.
-- --
-- function post_custom( key = "" ) then
--         custom = get_post_custom();

--         if ( ! isset( custom[ key ] ) ) then
--                 return false;
--         end; elseif ( 1 === count( custom[ key ] ) ) then
--                 return custom[ key ][0];
--         end; else then
--                 return custom[ key ];
--         end;
-- end;

-- --
-- -- Displays a list of post custom fields.
-- --
-- -- @since 1.2.0
-- --
-- -- @deprecated 6.0.2 Use get_post_meta() to retrieve post meta and render manually.
-- --
-- function the_meta() then
--         _deprecated_function( __FUNCTION__, "6.0.2", "get_post_meta()" );
--         keys = get_post_custom_keys();
--         if ( keys ) then
--                 li_html = "";
--                 foreach ( (array) keys as key ) then
--                         keyt = trim( key );
--                         if ( is_protected_meta( keyt, "post" ) ) then
--                                 continue;
--                         end;

--                         values = array_map( "trim", get_post_custom_values( key ) );
--                         value  = implode( ", ", values );

--                         html = sprintf(
--                                 "<li><span class="post-meta-key">%s</span> %s</li>\n",
--                                 /* translators: %s: Post custom field name.--
--                                 esc_html( sprintf( _x( "%s:", "Post custom field name" ), key ) ),
--                                 esc_html( value )
--                         );

--                         --
--                         -- Filters the HTML output of the li element in the post custom fields list.
--                         --
--                         -- @since 2.2.0
--                         --
--                         -- @param string html  The HTML output for the li element.
--                         -- @param string key   Meta key.
--                         -- @param string value Meta value.
--                         --
--                         li_html .= apply_filters( "the_meta_key", html, key, value );
--                 end;

--                 if ( li_html ) then
--                         echo "<ul class="post-meta">\nthenli_htmlend;</ul>\n";
--                 end;
--         end;
-- end;

-- --
-- -- Pages.
-- --

-- --
-- -- Retrieves or displays a list of pages as a dropdown (select list).
-- --
-- -- @since 2.1.0
-- -- @since 4.2.0 The `value_field` argument was added.
-- -- @since 4.3.0 The `class` argument was added.
-- --
-- -- @see get_pages()
-- --
-- -- @param array|string args then
-- --     Optional. Array or string of arguments to generate a page dropdown. See get_pages() for additional arguments.
-- --
-- --     @type int          depth                 Maximum depth. Default 0.
-- --     @type int          child_of              Page ID to retrieve child pages of. Default 0.
-- --     @type int|string   selected              Value of the option that should be selected. Default 0.
-- --     @type bool|int     echo                  Whether to echo or return the generated markup. Accepts 0, 1,
-- --                                               or their bool equivalents. Default 1.
-- --     @type string       name                  Value for the "name" attribute of the select element.
-- --                                               Default "page_id".
-- --     @type string       id                    Value for the "id" attribute of the select element.
-- --     @type string       class                 Value for the "class" attribute of the select element. Default: none.
-- --                                               Defaults to the value of `name`.
-- --     @type string       show_option_none      Text to display for showing no pages. Default empty (does not display).
-- --     @type string       show_option_no_change Text to display for "no change" option. Default empty (does not display).
-- --     @type string       option_none_value     Value to use when no page is selected. Default empty.
-- --     @type string       value_field           Post field used to populate the "value" attribute of the option
-- --                                               elements. Accepts any valid post field. Default "ID".
-- -- end;
-- -- @return string HTML dropdown list of pages.
-- --
-- function wp_dropdown_pages( args = "" ) then
--         defaults = array(
--                 "depth"                 => 0,
--                 "child_of"              => 0,
--                 "selected"              => 0,
--                 "echo"                  => 1,
--                 "name"                  => "page_id",
--                 "id"                    => "",
--                 "class"                 => "",
--                 "show_option_none"      => "",
--                 "show_option_no_change" => "",
--                 "option_none_value"     => "",
--                 "value_field"           => "ID",
--         );

--         parsed_args = wp_parse_args( args, defaults );

--         pages  = get_pages( parsed_args );
--         output = "";
--         -- Back-compat with old system where both id and name were based on name argument.
--         if ( empty( parsed_args["id"] ) ) then
--                 parsed_args["id"] = parsed_args["name"];
--         end;

--         if ( ! empty( pages ) ) then
--                 class = "";
--                 if ( ! empty( parsed_args["class"] ) ) then
--                         class = " class="" . esc_attr( parsed_args["class"] ) . """;
--                 end;

--                 output = "<select name="" . esc_attr( parsed_args["name"] ) . """ . class . " id="" . esc_attr( parsed_args["id"] ) . "">\n";
--                 if ( parsed_args["show_option_no_change"] ) then
--                         output .= "\t<option value=\"-1\">" . parsed_args["show_option_no_change"] . "</option>\n";
--                 end;
--                 if ( parsed_args["show_option_none"] ) then
--                         output .= "\t<option value=\"" . esc_attr( parsed_args["option_none_value"] ) . "">" . parsed_args["show_option_none"] . "</option>\n";
--                 end;
--                 output .= walk_page_dropdown_tree( pages, parsed_args["depth"], parsed_args );
--                 output .= "</select>\n";
--         end;

--         --
--         -- Filters the HTML output of a list of pages as a dropdown.
--         --
--         -- @since 2.1.0
--         -- @since 4.4.0 `parsed_args` and `pages` added as arguments.
--         --
--         -- @param string    output      HTML output for dropdown list of pages.
--         -- @param array     parsed_args The parsed arguments array. See wp_dropdown_pages()
--         --                               for information on accepted arguments.
--         -- @param WP_Post[] pages       Array of the page objects.
--         --
--         html = apply_filters( "wp_dropdown_pages", output, parsed_args, pages );

--         if ( parsed_args["echo"] ) then
--                 echo html;
--         end;

--         return html;
-- end;

-- --
-- -- Retrieves or displays a list of pages (or hierarchical post type items) in list (li) format.
-- --
-- -- @since 1.5.0
-- -- @since 4.7.0 Added the `item_spacing` argument.
-- --
-- -- @see get_pages()
-- --
-- -- @global WP_Query wp_query WordPress Query object.
-- --
-- -- @param array|string args then
-- --     Optional. Array or string of arguments to generate a list of pages. See get_pages() for additional arguments.
-- --
-- --     @type int          child_of     Display only the sub-pages of a single page by ID. Default 0 (all pages).
-- --     @type string       authors      Comma-separated list of author IDs. Default empty (all authors).
-- --     @type string       date_format  PHP date format to use for the listed pages. Relies on the "show_date" parameter.
-- --                                      Default is the value of "date_format" option.
-- --     @type int          depth        Number of levels in the hierarchy of pages to include in the generated list.
-- --                                      Accepts -1 (any depth), 0 (all pages), 1 (top-level pages only), and n (pages to
-- --                                      the given n depth). Default 0.
-- --     @type bool         echo         Whether or not to echo the list of pages. Default true.
-- --     @type string       exclude      Comma-separated list of page IDs to exclude. Default empty.
-- --     @type array        include      Comma-separated list of page IDs to include. Default empty.
-- --     @type string       link_after   Text or HTML to follow the page link label. Default null.
-- --     @type string       link_before  Text or HTML to precede the page link label. Default null.
-- --     @type string       post_type    Post type to query for. Default "page".
-- --     @type string|array post_status  Comma-separated list or array of post statuses to include. Default "publish".
-- --     @type string       show_date    Whether to display the page publish or modified date for each page. Accepts
-- --                                      "modified" or any other value. An empty value hides the date. Default empty.
-- --     @type string       sort_column  Comma-separated list of column names to sort the pages by. Accepts "post_author",
-- --                                      "post_date", "post_title", "post_name", "post_modified", "post_modified_gmt",
-- --                                      "menu_order", "post_parent", "ID", "rand", or "comment_count". Default "post_title".
-- --     @type string       title_li     List heading. Passing a null or empty value will result in no heading, and the list
-- --                                      will not be wrapped with unordered list `<ul>` tags. Default "Pages".
-- --     @type string       item_spacing Whether to preserve whitespace within the menu"s HTML. Accepts "preserve" or "discard".
-- --                                      Default "preserve".
-- --     @type Walker       walker       Walker instance to use for listing pages. Default empty which results in a
-- --                                      Walker_Page instance being used.
-- -- end;
-- -- @return void|string Void if "echo" argument is true, HTML list of pages if "echo" is false.
-- --
-- function wp_list_pages( args = "" ) then
--         defaults = array(
--                 "depth"        => 0,
--                 "show_date"    => "",
--                 "date_format"  => get_option( "date_format" ),
--                 "child_of"     => 0,
--                 "exclude"      => "",
--                 "title_li"     => __( "Pages" ),
--                 "echo"         => 1,
--                 "authors"      => "",
--                 "sort_column"  => "menu_order, post_title",
--                 "link_before"  => "",
--                 "link_after"   => "",
--                 "item_spacing" => "preserve",
--                 "walker"       => "",
--         );

--         parsed_args = wp_parse_args( args, defaults );

--         if ( ! in_array( parsed_args["item_spacing"], array( "preserve", "discard" ), true ) ) then
--                 -- Invalid value, fall back to default.
--                 parsed_args["item_spacing"] = defaults["item_spacing"];
--         end;

--         output       = "";
--         current_page = 0;

--         -- Sanitize, mostly to keep spaces out.
--         parsed_args["exclude"] = preg_replace( "/[^0-9,]/", "", parsed_args["exclude"] );

--         -- Allow plugins to filter an array of excluded pages (but don"t put a nullstring into the array).
--         exclude_array = ( parsed_args["exclude"] ) ? explode( ",", parsed_args["exclude"] ) : array();

--         --
--         -- Filters the array of pages to exclude from the pages list.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string[] exclude_array An array of page IDs to exclude.
--         --
--         parsed_args["exclude"] = implode( ",", apply_filters( "wp_list_pages_excludes", exclude_array ) );

--         parsed_args["hierarchical"] = 0;

--         -- Query pages.
--         pages = get_pages( parsed_args );

--         if ( ! empty( pages ) ) then
--                 if ( parsed_args["title_li"] ) then
--                         output .= "<li class="pagenav">" . parsed_args["title_li"] . "<ul>";
--                 end;
--                 global wp_query;
--                 if ( is_page() || is_attachment() || wp_query.is_posts_page ) then
--                         current_page = get_queried_object_id();
--                 end; elseif ( is_singular() ) then
--                         queried_object = get_queried_object();
--                         if ( is_post_type_hierarchical( queried_object.post_type ) ) then
--                                 current_page = queried_object.ID;
--                         end;
--                 end;

--                 output .= walk_page_tree( pages, parsed_args["depth"], current_page, parsed_args );

--                 if ( parsed_args["title_li"] ) then
--                         output .= "</ul></li>";
--                 end;
--         end;

--         --
--         -- Filters the HTML output of the pages to list.
--         --
--         -- @since 1.5.1
--         -- @since 4.4.0 `pages` added as arguments.
--         --
--         -- @see wp_list_pages()
--         --
--         -- @param string    output      HTML output of the pages list.
--         -- @param array     parsed_args An array of page-listing arguments. See wp_list_pages()
--         --                               for information on accepted arguments.
--         -- @param WP_Post[] pages       Array of the page objects.
--         --
--         html = apply_filters( "wp_list_pages", output, parsed_args, pages );

--         if ( parsed_args["echo"] ) then
--                 echo html;
--         end; else then
--                 return html;
--         end;
-- end;

-- --
-- -- Displays or retrieves a list of pages with an optional home link.
-- --
-- -- The arguments are listed below and part of the arguments are for wp_list_pages() function.
-- -- Check that function for more info on those arguments.
-- --
-- -- @since 2.7.0
-- -- @since 4.4.0 Added `menu_id`, `container`, `before`, `after`, and `walker` arguments.
-- -- @since 4.7.0 Added the `item_spacing` argument.
-- --
-- -- @param array|string args then
-- --     Optional. Array or string of arguments to generate a page menu. See wp_list_pages() for additional arguments.
-- --
-- --     @type string          sort_column  How to sort the list of pages. Accepts post column names.
-- --                                         Default "menu_order, post_title".
-- --     @type string          menu_id      ID for the div containing the page list. Default is empty string.
-- --     @type string          menu_class   Class to use for the element containing the page list. Default "menu".
-- --     @type string          container    Element to use for the element containing the page list. Default "div".
-- --     @type bool            echo         Whether to echo the list or return it. Accepts true (echo) or false (return).
-- --                                         Default true.
-- --     @type int|bool|string show_home    Whether to display the link to the home page. Can just enter the text
-- --                                         you"d like shown for the home link. 1|true defaults to "Home".
-- --     @type string          link_before  The HTML or text to prepend to show_home text. Default empty.
-- --     @type string          link_after   The HTML or text to append to show_home text. Default empty.
-- --     @type string          before       The HTML or text to prepend to the menu. Default is "<ul>".
-- --     @type string          after        The HTML or text to append to the menu. Default is "</ul>".
-- --     @type string          item_spacing Whether to preserve whitespace within the menu"s HTML. Accepts "preserve"
-- --                                         or "discard". Default "discard".
-- --     @type Walker          walker       Walker instance to use for listing pages. Default empty which results in a
-- --                                         Walker_Page instance being used.
-- -- end;
-- -- @return void|string Void if "echo" argument is true, HTML menu if "echo" is false.
-- --
-- function wp_page_menu( args = array() ) then
--         defaults = array(
--                 "sort_column"  => "menu_order, post_title",
--                 "menu_id"      => "",
--                 "menu_class"   => "menu",
--                 "container"    => "div",
--                 "echo"         => true,
--                 "link_before"  => "",
--                 "link_after"   => "",
--                 "before"       => "<ul>",
--                 "after"        => "</ul>",
--                 "item_spacing" => "discard",
--                 "walker"       => "",
--         );
--         args     = wp_parse_args( args, defaults );

--         if ( ! in_array( args["item_spacing"], array( "preserve", "discard" ), true ) ) then
--                 -- Invalid value, fall back to default.
--                 args["item_spacing"] = defaults["item_spacing"];
--         end;

--         if ( "preserve" === args["item_spacing"] ) then
--                 t = "\t";
--                 n = "\n";
--         end; else then
--                 t = "";
--                 n = "";
--         end;

--         --
--         -- Filters the arguments used to generate a page-based menu.
--         --
--         -- @since 2.7.0
--         --
--         -- @see wp_page_menu()
--         --
--         -- @param array args An array of page menu arguments. See wp_page_menu()
--         --                    for information on accepted arguments.
--         --
--         args = apply_filters( "wp_page_menu_args", args );

--         menu = "";

--         list_args = args;

--         -- Show Home in the menu.
--         if ( ! empty( args["show_home"] ) ) then
--                 if ( true === args["show_home"] || "1" === args["show_home"] || 1 === args["show_home"] ) then
--                         text = __( "Home" );
--                 end; else then
--                         text = args["show_home"];
--                 end;
--                 class = "";
--                 if ( is_front_page() && ! is_paged() ) then
--                         class = "class="current_page_item"";
--                 end;
--                 menu .= "<li " . class . "><a href="" . esc_url( home_url( "/" ) ) . "">" . args["link_before"] . text . args["link_after"] . "</a></li>";
--                 -- If the front page is a page, add it to the exclude list.
--                 if ( "page" === get_option( "show_on_front" ) ) then
--                         if ( ! empty( list_args["exclude"] ) ) then
--                                 list_args["exclude"] .= ",";
--                         end; else then
--                                 list_args["exclude"] = "";
--                         end;
--                         list_args["exclude"] .= get_option( "page_on_front" );
--                 end;
--         end;

--         list_args["echo"]     = false;
--         list_args["title_li"] = "";
--         menu                 .= wp_list_pages( list_args );

--         container = sanitize_text_field( args["container"] );

--         -- Fallback in case `wp_nav_menu()` was called without a container.
--         if ( empty( container ) ) then
--                 container = "div";
--         end;

--         if ( menu ) then

--                 -- wp_nav_menu() doesn"t set before and after.
--                 if ( isset( args["fallback_cb"] ) &&
--                         "wp_page_menu" === args["fallback_cb"] &&
--                         "ul" !== container ) then
--                         args["before"] = "<ul>thennend;";
--                         args["after"]  = "</ul>";
--                 end;

--                 menu = args["before"] . menu . args["after"];
--         end;

--         attrs = "";
--         if ( ! empty( args["menu_id"] ) ) then
--                 attrs .= " id="" . esc_attr( args["menu_id"] ) . """;
--         end;

--         if ( ! empty( args["menu_class"] ) ) then
--                 attrs .= " class="" . esc_attr( args["menu_class"] ) . """;
--         end;

--         menu = "<thencontainerend;thenattrsend;>" . menu . "</thencontainerend;>thennend;";

--         --
--         -- Filters the HTML output of a page-based menu.
--         --
--         -- @since 2.7.0
--         --
--         -- @see wp_page_menu()
--         --
--         -- @param string menu The HTML output.
--         -- @param array  args An array of arguments. See wp_page_menu()
--         --                     for information on accepted arguments.
--         --
--         menu = apply_filters( "wp_page_menu", menu, args );

--         if ( args["echo"] ) then
--                 echo menu;
--         end; else then
--                 return menu;
--         end;
-- end;

-- --
-- -- Page helpers.
-- --

-- --
-- -- Retrieves HTML list content for page list.
-- --
-- -- @uses Walker_Page to create HTML list content.
-- -- @since 2.1.0
-- --
-- -- @param array pages
-- -- @param int   depth
-- -- @param int   current_page
-- -- @param array args
-- -- @return string
-- --
-- function walk_page_tree( pages, depth, current_page, args ) then
--         if ( empty( args["walker"] ) ) then
--                 walker = new Walker_Page;
--         end; else then
--                 --
--                 -- @var Walker walker
--                 --
--                 walker = args["walker"];
--         end;

--         foreach ( (array) pages as page ) then
--                 if ( page.post_parent ) then
--                         args["pages_with_children"][ page.post_parent ] = true;
--                 end;
--         end;

--         return walker.walk( pages, depth, args, current_page );
-- end;

-- --
-- -- Retrieves HTML dropdown (select) content for page list.
-- --
-- -- @since 2.1.0
-- -- @since 5.3.0 Formalized the existing `...args` parameter by adding it
-- --              to the function signature.
-- --
-- -- @uses Walker_PageDropdown to create HTML dropdown content.
-- -- @see Walker_PageDropdown::walk() for parameters and return description.
-- --
-- -- @param mixed ...args Elements array, maximum hierarchical depth and optional additional arguments.
-- -- @return string
-- --
-- function walk_page_dropdown_tree( ...args ) then
--         if ( empty( args[2]["walker"] ) ) then -- The user"s options are the third parameter.
--                 walker = new Walker_PageDropdown;
--         end; else then
--                 --
--                 -- @var Walker walker
--                 --
--                 walker = args[2]["walker"];
--         end;

--         return walker.walk( ...args );
-- end;

-- --
-- -- Attachments.
-- --

-- --
-- -- Displays an attachment page link using an image or icon.
-- --
-- -- @since 2.0.0
-- --
-- -- @param int|WP_Post post       Optional. Post ID or post object.
-- -- @param bool        fullsize   Optional. Whether to use full size. Default false.
-- -- @param bool        deprecated Deprecated. Not used.
-- -- @param bool        permalink Optional. Whether to include permalink. Default false.
-- --
-- function the_attachment_link( post = 0, fullsize = false, deprecated = false, permalink = false ) then
--         if ( ! empty( deprecated ) ) then
--                 _deprecated_argument( __FUNCTION__, "2.5.0" );
--         end;

--         if ( fullsize ) then
--                 echo wp_get_attachment_link( post, "full", permalink );
--         end; else then
--                 echo wp_get_attachment_link( post, "thumbnail", permalink );
--         end;
-- end;

-- --
-- -- Retrieves an attachment page link using an image or icon, if possible.
-- --
-- -- @since 2.5.0
-- -- @since 4.4.0 The `post` parameter can now accept either a post ID or `WP_Post` object.
-- --
-- -- @param int|WP_Post  post      Optional. Post ID or post object.
-- -- @param string|int[] size      Optional. Image size. Accepts any registered image size name, or an array
-- --                                of width and height values in pixels (in that order). Default "thumbnail".
-- -- @param bool         permalink Optional. Whether to add permalink to image. Default false.
-- -- @param bool         icon      Optional. Whether the attachment is an icon. Default false.
-- -- @param string|false text      Optional. Link text to use. Activated by passing a string, false otherwise.
-- --                                Default false.
-- -- @param array|string attr      Optional. Array or string of attributes. Default empty.
-- -- @return string HTML content.
-- --
-- function wp_get_attachment_link( post = 0, size = "thumbnail", permalink = false, icon = false, text = false, attr = "" ) then
--         _post = get_post( post );

--         if ( empty( _post ) || ( "attachment" !== _post.post_type ) || ! wp_get_attachment_url( _post.ID ) ) then
--                 return __( "Missing Attachment" );
--         end;

--         url = wp_get_attachment_url( _post.ID );

--         if ( permalink ) then
--                 url = get_attachment_link( _post.ID );
--         end;

--         if ( text ) then
--                 link_text = text;
--         end; elseif ( size && "none" !== size ) then
--                 link_text = wp_get_attachment_image( _post.ID, size, icon, attr );
--         end; else then
--                 link_text = "";
--         end;

--         if ( "" === trim( link_text ) ) then
--                 link_text = _post.post_title;
--         end;

--         if ( "" === trim( link_text ) ) then
--                 link_text = esc_html( pathinfo( get_attached_file( _post.ID ), PATHINFO_FILENAME ) );
--         end;

--         link_html = "<a href="" . esc_url( url ) . "">link_text</a>";

--         --
--         -- Filters a retrieved attachment page link.
--         --
--         -- @since 2.7.0
--         -- @since 5.1.0 Added the `attr` parameter.
--         --
--         -- @param string       link_html The page link HTML output.
--         -- @param int|WP_Post  post      Post ID or object. Can be 0 for the current global post.
--         -- @param string|int[] size      Requested image size. Can be any registered image size name, or
--         --                                an array of width and height values in pixels (in that order).
--         -- @param bool         permalink Whether to add permalink to image. Default false.
--         -- @param bool         icon      Whether to include an icon.
--         -- @param string|false text      If string, will be link text.
--         -- @param array|string attr      Array or string of attributes.
--         --
--         return apply_filters( "wp_get_attachment_link", link_html, post, size, permalink, icon, text, attr );
-- end;

-- --
-- -- Wraps attachment in paragraph tag before content.
-- --
-- -- @since 2.0.0
-- --
-- -- @param string content
-- -- @return string
-- --
-- function prepend_attachment( content ) then
--         post = get_post();

--         if ( empty( post.post_type ) || "attachment" !== post.post_type ) then
--                 return content;
--         end;

--         if ( wp_attachment_is( "video", post ) ) then
--                 meta = wp_get_attachment_metadata( get_the_ID() );
--                 atts = array( "src" => wp_get_attachment_url() );
--                 if ( ! empty( meta["width"] ) && ! empty( meta["height"] ) ) then
--                         atts["width"]  = (int) meta["width"];
--                         atts["height"] = (int) meta["height"];
--                 end;
--                 if ( has_post_thumbnail() ) then
--                         atts["poster"] = wp_get_attachment_url( get_post_thumbnail_id() );
--                 end;
--                 p = wp_video_shortcode( atts );
--         end; elseif ( wp_attachment_is( "audio", post ) ) then
--                 p = wp_audio_shortcode( array( "src" => wp_get_attachment_url() ) );
--         end; else then
--                 p = "<p class="attachment">";
--                 -- Show the medium sized image representation of the attachment if available, and link to the raw file.
--                 p .= wp_get_attachment_link( 0, "medium", false );
--                 p .= "</p>";
--         end;

--         --
--         -- Filters the attachment markup to be prepended to the post content.
--         --
--         -- @since 2.0.0
--         --
--         -- @see prepend_attachment()
--         --
--         -- @param string p The attachment HTML output.
--         --
--         p = apply_filters( "prepend_attachment", p );

--         return "p\ncontent";
-- end;

-- --
-- -- Misc.
-- --

-- --
-- -- Retrieves protected post password form content.
-- --
-- -- @since 1.0.0
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- -- @return string HTML content for password form for password protected post.
-- --
-- function get_the_password_form( post = 0 ) then
--         post   = get_post( post );
--         label  = "pwbox-" . ( empty( post.ID ) ? rand() : post.ID );
--         output = "<form action="" . esc_url( site_url( "wp-login.php?action=postpass", "login_post" ) ) . "" class="post-password-form" method="post">
--         <p>" . __( "This content is password protected. To view it please enter your password below:" ) . "</p>
--         <p><label for="" . label . "">" . __( "Password:" ) . " <input name="post_password" id="" . label . "" type="password" size="20" /></label> <input type="submit" name="Submit" value="" . esc_attr_x( "Enter", "post password form" ) . "" /></p></form>
--         ";

--         --
--         -- Filters the HTML output for the protected post password form.
--         --
--         -- If modifying the password field, please note that the core database schema
--         -- limits the password field to 20 characters regardless of the value of the
--         -- size attribute in the form input.
--         --
--         -- @since 2.7.0
--         -- @since 5.8.0 Added the `post` parameter.
--         --
--         -- @param string  output The password form HTML output.
--         -- @param WP_Post post   Post object.
--         --
--         return apply_filters( "the_password_form", output, post );
-- end;

-- --
-- -- Determines whether the current post uses a page template.
-- --
-- -- This template tag allows you to determine if you are in a page template.
-- -- You can optionally provide a template filename or array of template filenames
-- -- and then the check will be specific to that template.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tags} article in the Theme Developer Handbook.
-- --
-- -- @since 2.5.0
-- -- @since 4.2.0 The `template` parameter was changed to also accept an array of page templates.
-- -- @since 4.7.0 Now works with any post type, not just pages.
-- --
-- -- @param string|string[] template The specific template filename or array of templates to match.
-- -- @return bool True on success, false on failure.
-- --
-- function is_page_template( template = "" ) then
--         if ( ! is_singular() ) then
--                 return false;
--         end;

--         page_template = get_page_template_slug( get_queried_object_id() );

--         if ( empty( template ) ) then
--                 return (bool) page_template;
--         end;

--         if ( template == page_template ) then
--                 return true;
--         end;

--         if ( is_array( template ) ) then
--                 if ( ( in_array( "default", template, true ) && ! page_template )
--                         || in_array( page_template, template, true )
--                 ) then
--                         return true;
--                 end;
--         end;

--         return ( "default" === template && ! page_template );
-- end;

-- --
-- -- Gets the specific template filename for a given post.
-- --
-- -- @since 3.4.0
-- -- @since 4.7.0 Now works with any post type, not just pages.
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- -- @return string|false Page template filename. Returns an empty string when the default page template
-- --                      is in use. Returns false if the post does not exist.
-- --
-- function get_page_template_slug( post = null ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return false;
--         end;

--         template = get_post_meta( post.ID, "_wp_page_template", true );

--         if ( ! template || "default" === template ) then
--                 return "";
--         end;

--         return template;
-- end;

-- --
-- -- Retrieves formatted date timestamp of a revision (linked to that revisions"s page).
-- --
-- -- @since 2.6.0
-- --
-- -- @param int|object revision Revision ID or revision object.
-- -- @param bool       link     Optional. Whether to link to revision"s page. Default true.
-- -- @return string|false i18n formatted datetimestamp or localized "Current Revision".
-- --
-- function wp_post_revision_title( revision, link = true ) then
--         revision = get_post( revision );

--         if ( ! revision ) then
--                 return revision;
--         end;

--         if ( ! in_array( revision.post_type, array( "post", "page", "revision" ), true ) ) then
--                 return false;
--         end;

--         /* translators: Revision date format, see https://www.php.net/manual/datetime.format.php--
--         datef = _x( "F j, Y @ H:i:s", "revision date format" );
--         /* translators: %s: Revision date.--
--         autosavef = __( "%s [Autosave]" );
--         /* translators: %s: Revision date.--
--         currentf = __( "%s [Current Revision]" );

--         date      = date_i18n( datef, strtotime( revision.post_modified ) );
--         edit_link = get_edit_post_link( revision.ID );
--         if ( link && current_user_can( "edit_post", revision.ID ) && edit_link ) then
--                 date = "<a href="edit_link">date</a>";
--         end;

--         if ( ! wp_is_post_revision( revision ) ) then
--                 date = sprintf( currentf, date );
--         end; elseif ( wp_is_post_autosave( revision ) ) then
--                 date = sprintf( autosavef, date );
--         end;

--         return date;
-- end;

-- --
-- -- Retrieves formatted date timestamp of a revision (linked to that revisions"s page).
-- --
-- -- @since 3.6.0
-- --
-- -- @param int|object revision Revision ID or revision object.
-- -- @param bool       link     Optional. Whether to link to revision"s page. Default true.
-- -- @return string|false gravatar, user, i18n formatted datetimestamp or localized "Current Revision".
-- --
-- function wp_post_revision_title_expanded( revision, link = true ) then
--         revision = get_post( revision );

--         if ( ! revision ) then
--                 return revision;
--         end;

--         if ( ! in_array( revision.post_type, array( "post", "page", "revision" ), true ) ) then
--                 return false;
--         end;

--         author = get_the_author_meta( "display_name", revision.post_author );
--         /* translators: Revision date format, see https://www.php.net/manual/datetime.format.php--
--         datef = _x( "F j, Y @ H:i:s", "revision date format" );

--         gravatar = get_avatar( revision.post_author, 24 );

--         date      = date_i18n( datef, strtotime( revision.post_modified ) );
--         edit_link = get_edit_post_link( revision.ID );
--         if ( link && current_user_can( "edit_post", revision.ID ) && edit_link ) then
--                 date = "<a href="edit_link">date</a>";
--         end;

--         revision_date_author = sprintf(
--                 /* translators: Post revision title. 1: Author avatar, 2: Author name, 3: Time ago, 4: Date.--
--                 __( "%1s %2s, %3s ago (%4s)" ),
--                 gravatar,
--                 author,
--                 human_time_diff( strtotime( revision.post_modified_gmt ) ),
--                 date
--         );

--         /* translators: %s: Revision date with author avatar.--
--         autosavef = __( "%s [Autosave]" );
--         /* translators: %s: Revision date with author avatar.--
--         currentf = __( "%s [Current Revision]" );

--         if ( ! wp_is_post_revision( revision ) ) then
--                 revision_date_author = sprintf( currentf, revision_date_author );
--         end; elseif ( wp_is_post_autosave( revision ) ) then
--                 revision_date_author = sprintf( autosavef, revision_date_author );
--         end;

--         --
--         -- Filters the formatted author and date for a revision.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string  revision_date_author The formatted string.
--         -- @param WP_Post revision             The revision object.
--         -- @param bool    link                 Whether to link to the revisions page, as passed into
--         --                                      wp_post_revision_title_expanded().
--         --
--         return apply_filters( "wp_post_revision_title_expanded", revision_date_author, revision, link );
-- end;

-- --
-- -- Displays a list of a post"s revisions.
-- --
-- -- Can output either a UL with edit links or a TABLE with diff interface, and
-- -- restore action links.
-- --
-- -- @since 2.6.0
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- -- @param string      type "all" (default), "revision" or "autosave"
-- --
-- function wp_list_post_revisions( post = 0, type = "all" ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         -- args array with (parent, format, right, left, type) deprecated since 3.6.
--         if ( is_array( type ) ) then
--                 type = ! empty( type["type"] ) ? type["type"] : type;
--                 _deprecated_argument( __FUNCTION__, "3.6.0" );
--         end;

--         revisions = wp_get_post_revisions( post.ID );

--         if ( ! revisions ) then
--                 return;
--         end;

--         rows = "";
--         foreach ( revisions as revision ) then
--                 if ( ! current_user_can( "read_post", revision.ID ) ) then
--                         continue;
--                 end;

--                 is_autosave = wp_is_post_autosave( revision );
--                 if ( ( "revision" === type && is_autosave ) || ( "autosave" === type && ! is_autosave ) ) then
--                         continue;
--                 end;

--                 rows .= "\t<li>" . wp_post_revision_title_expanded( revision ) . "</li>\n";
--         end;

--         echo "<div class="hide-if-js"><p>" . __( "JavaScript must be enabled to use this feature." ) . "</p></div>\n";

--         echo "<ul class="post-revisions hide-if-no-js">\n";
--         echo rows;
--         echo "</ul>";
-- end;

-- --
-- -- Retrieves the parent post object for the given post.
-- --
-- -- @since 5.7.0
-- --
-- -- @param int|WP_Post|null post Optional. Post ID or WP_Post object. Default is global post.
-- -- @return WP_Post|null Parent post object, or null if there isn"t one.
-- --
-- function get_post_parent( post = null ) then
--         wp_post = get_post( post );
--         return ! empty( wp_post.post_parent ) ? get_post( wp_post.post_parent ) : null;
-- end;

-- --
-- -- Returns whether the given post has a parent post.
-- --
-- -- @since 5.7.0
-- --
-- -- @param int|WP_Post|null post Optional. Post ID or WP_Post object. Default is global post.
-- -- @return bool Whether the post has a parent post.
-- --
-- function has_post_parent( post = null ) then
--         return (bool) get_post_parent( post );
-- end;

end Inc_Post_Templates;
