--
-- Query API: WP_Query class
--
-- @package WordPress
-- @subpackage Query
-- @since 4.7.0
--

with Ada.Containers;

with Php.Lists;
with Php.Strings;

with Lists;

with Class_Post_Type;
with Inc_Options;
with Inc_Posts;

package body Class_Querys
is
   use Lists;

--         --
--         -- Resets query flags to false.
--         --
--         -- The query flags are what page info WordPress was able to figure out.
--         --
--         -- @since 2.0.0
--         --
--         private function init_query_flags() then
--                 $this->is_single            = false;
--                 $this->is_preview           = false;
--                 $this->is_page              = false;
--                 $this->is_archive           = false;
--                 $this->is_date              = false;
--                 $this->is_year              = false;
--                 $this->is_month             = false;
--                 $this->is_day               = false;
--                 $this->is_time              = false;
--                 $this->is_author            = false;
--                 $this->is_category          = false;
--                 $this->is_tag               = false;
--                 $this->is_tax               = false;
--                 $this->is_search            = false;
--                 $this->is_feed              = false;
--                 $this->is_comment_feed      = false;
--                 $this->is_trackback         = false;
--                 $this->is_home              = false;
--                 $this->is_privacy_policy    = false;
--                 $this->is_404               = false;
--                 $this->is_paged             = false;
--                 $this->is_admin             = false;
--                 $this->is_attachment        = false;
--                 $this->is_singular          = false;
--                 $this->is_robots            = false;
--                 $this->is_favicon           = false;
--                 $this->is_posts_page        = false;
--                 $this->is_post_type_archive = false;
--         end;

--         --
--         -- Initiates object properties and sets default values.
--         --
--         -- @since 1.5.0
--         --
--         public function init() then
--                 unset( $this->posts );
--                 unset( $this->query );
--                 $this->query_vars = array();
--                 unset( $this->queried_object );
--                 unset( $this->queried_object_id );
--                 $this->post_count   = 0;
--                 $this->current_post = -1;
--                 $this->in_the_loop  = false;
--                 unset( $this->request );
--                 unset( $this->post );
--                 unset( $this->comments );
--                 unset( $this->comment );
--                 $this->comment_count         = 0;
--                 $this->current_comment       = -1;
--                 $this->found_posts           = 0;
--                 $this->max_num_pages         = 0;
--                 $this->max_num_comment_pages = 0;

--                 $this->init_query_flags();
--         end;

--         --
--         -- Reparse the query vars.
--         --
--         -- @since 1.5.0
--         --
--         public function parse_query_vars() then
--                 $this->parse_query();
--         end;

--         --
--         -- Fills in the query variables, which do not exist within the parameter.
--         --
--         -- @since 2.1.0
--         -- @since 4.5.0 Removed the `comments_popup` public query variable.
--         --
--         -- @param array $query_vars Defined query variables.
--         -- @return array Complete query variables with undefined ones filled in empty.
--         --
--         public function fill_query_vars( $query_vars ) then
--                 $keys = array(
--                         'error',
--                         'm',
--                         'p',
--                         'post_parent',
--                         'subpost',
--                         'subpost_id',
--                         'attachment',
--                         'attachment_id',
--                         'name',
--                         'pagename',
--                         'page_id',
--                         'second',
--                         'minute',
--                         'hour',
--                         'day',
--                         'monthnum',
--                         'year',
--                         'w',
--                         'category_name',
--                         'tag',
--                         'cat',
--                         'tag_id',
--                         'author',
--                         'author_name',
--                         'feed',
--                         'tb',
--                         'paged',
--                         'meta_key',
--                         'meta_value',
--                         'preview',
--                         's',
--                         'sentence',
--                         'title',
--                         'fields',
--                         'menu_order',
--                         'embed',
--                 );

--                 foreach ( $keys as $key ) then
--                         if ( ! isset( $query_vars[ $key ] ) ) then
--                                 $query_vars[ $key ] = '';
--                         end;
--                 end;

--                 $array_keys = array(
--                         'category__in',
--                         'category__not_in',
--                         'category__and',
--                         'post__in',
--                         'post__not_in',
--                         'post_name__in',
--                         'tag__in',
--                         'tag__not_in',
--                         'tag__and',
--                         'tag_slug__in',
--                         'tag_slug__and',
--                         'post_parent__in',
--                         'post_parent__not_in',
--                         'author__in',
--                         'author__not_in',
--                 );

--                 foreach ( $array_keys as $key ) then
--                         if ( ! isset( $query_vars[ $key ] ) ) then
--                                 $query_vars[ $key ] = array();
--                         end;
--                 end;

--                 return $query_vars;
--         end;

--         --
--         -- Parse a query string and set query type booleans.
--         --
--         -- @since 1.5.0
--         -- @since 4.2.0 Introduced the ability to order by specific clauses of a `$meta_query`, by passing the clause's
--         --              array key to `$orderby`.
--         -- @since 4.4.0 Introduced `$post_name__in` and `$title` parameters. `$s` was updated to support excluded
--         --              search terms, by prepending a hyphen.
--         -- @since 4.5.0 Removed the `$comments_popup` parameter.
--         --              Introduced the `$comment_status` and `$ping_status` parameters.
--         --              Introduced `RAND(x)` syntax for `$orderby`, which allows an integer seed value to random sorts.
--         -- @since 4.6.0 Added 'post_name__in' support for `$orderby`. Introduced the `$lazy_load_term_meta` argument.
--         -- @since 4.9.0 Introduced the `$comment_count` parameter.
--         -- @since 5.1.0 Introduced the `$meta_compare_key` parameter.
--         -- @since 5.3.0 Introduced the `$meta_type_key` parameter.
--         -- @since 6.1.0 Introduced the `$update_menu_item_cache` parameter.
--         --
--         -- @param string|array $query then
--         --     Optional. Array or string of Query parameters.
--         --
--         --     @type int             $attachment_id           Attachment post ID. Used for 'attachment' post_type.
--         --     @type int|string      $author                  Author ID, or comma-separated list of IDs.
--         --     @type string          $author_name             User 'user_nicename'.
--         --     @type int[]           $author__in              An array of author IDs to query from.
--         --     @type int[]           $author__not_in          An array of author IDs not to query from.
--         --     @type bool            $cache_results           Whether to cache post information. Default true.
--         --     @type int|string      $cat                     Category ID or comma-separated list of IDs (this or any children).
--         --     @type int[]           $category__and           An array of category IDs (AND in).
--         --     @type int[]           $category__in            An array of category IDs (OR in, no children).
--         --     @type int[]           $category__not_in        An array of category IDs (NOT in).
--         --     @type string          $category_name           Use category slug (not name, this or any children).
--         --     @type array|int       $comment_count           Filter results by comment count. Provide an integer to match
--         --                                                    comment count exactly. Provide an array with integer 'value'
--         --                                                    and 'compare' operator ('=', '!=', '>', '>=', '<', '<=' ) to
--         --                                                    compare against comment_count in a specific way.
--         --     @type string          $comment_status          Comment status.
--         --     @type int             $comments_per_page       The number of comments to return per page.
--         --                                                    Default 'comments_per_page' option.
--         --     @type array           $date_query              An associative array of WP_Date_Query arguments.
--         --                                                    See WP_Date_Query::__construct().
--         --     @type int             $day                     Day of the month. Default empty. Accepts numbers 1-31.
--         --     @type bool            $exact                   Whether to search by exact keyword. Default false.
--         --     @type string          $fields                  Post fields to query for. Accepts:
--         --                                                    - '' Returns an array of complete post objects (`WP_Post[]`).
--         --                                                    - 'ids' Returns an array of post IDs (`int[]`).
--         --                                                    - 'id=>parent' Returns an associative array of parent post IDs,
--         --                                                      keyed by post ID (`int[]`).
--         --                                                    Default ''.
--         --     @type int             $hour                    Hour of the day. Default empty. Accepts numbers 0-23.
--         --     @type int|bool        $ignore_sticky_posts     Whether to ignore sticky posts or not. Setting this to false
--         --                                                    excludes stickies from 'post__in'. Accepts 1|true, 0|false.
--         --                                                    Default false.
--         --     @type int             $m                       Combination YearMonth. Accepts any four-digit year and month
--         --                                                    numbers 01-12. Default empty.
--         --     @type string|string[] $meta_key                Meta key or keys to filter by.
--         --     @type string|string[] $meta_value              Meta value or values to filter by.
--         --     @type string          $meta_compare            MySQL operator used for comparing the meta value.
--         --                                                    See WP_Meta_Query::__construct() for accepted values and default value.
--         --     @type string          $meta_compare_key        MySQL operator used for comparing the meta key.
--         --                                                    See WP_Meta_Query::__construct() for accepted values and default value.
--         --     @type string          $meta_type               MySQL data type that the meta_value column will be CAST to for comparisons.
--         --                                                    See WP_Meta_Query::__construct() for accepted values and default value.
--         --     @type string          $meta_type_key           MySQL data type that the meta_key column will be CAST to for comparisons.
--         --                                                    See WP_Meta_Query::__construct() for accepted values and default value.
--         --     @type array           $meta_query              An associative array of WP_Meta_Query arguments.
--         --                                                    See WP_Meta_Query::__construct() for accepted values.
--         --     @type int             $menu_order              The menu order of the posts.
--         --     @type int             $minute                  Minute of the hour. Default empty. Accepts numbers 0-59.
--         --     @type int             $monthnum                The two-digit month. Default empty. Accepts numbers 1-12.
--         --     @type string          $name                    Post slug.
--         --     @type bool            $nopaging                Show all posts (true) or paginate (false). Default false.
--         --     @type bool            $no_found_rows           Whether to skip counting the total rows found. Enabling can improve
--         --                                                    performance. Default false.
--         --     @type int             $offset                  The number of posts to offset before retrieval.
--         --     @type string          $order                   Designates ascending or descending order of posts. Default 'DESC'.
--         --                                                    Accepts 'ASC', 'DESC'.
--         --     @type string|array    $orderby                 Sort retrieved posts by parameter. One or more options may be passed.
--         --                                                    To use 'meta_value', or 'meta_value_num', 'meta_key=keyname' must be
--         --                                                    also be defined. To sort by a specific `$meta_query` clause, use that
--         --                                                    clause's array key. Accepts:
--         --                                                    - 'none'
--         --                                                    - 'name'
--         --                                                    - 'author'
--         --                                                    - 'date'
--         --                                                    - 'title'
--         --                                                    - 'modified'
--         --                                                    - 'menu_order'
--         --                                                    - 'parent'
--         --                                                    - 'ID'
--         --                                                    - 'rand'
--         --                                                    - 'relevance'
--         --                                                    - 'RAND(x)' (where 'x' is an integer seed value)
--         --                                                    - 'comment_count'
--         --                                                    - 'meta_value'
--         --                                                    - 'meta_value_num'
--         --                                                    - 'post__in'
--         --                                                    - 'post_name__in'
--         --                                                    - 'post_parent__in'
--         --                                                    - The array keys of `$meta_query`.
--         --                                                    Default is 'date', except when a search is being performed, when
--         --                                                    the default is 'relevance'.
--         --     @type int             $p                       Post ID.
--         --     @type int             $page                    Show the number of posts that would show up on page X of a
--         --                                                    static front page.
--         --     @type int             $paged                   The number of the current page.
--         --     @type int             $page_id                 Page ID.
--         --     @type string          $pagename                Page slug.
--         --     @type string          $perm                    Show posts if user has the appropriate capability.
--         --     @type string          $ping_status             Ping status.
--         --     @type int[]           $post__in                An array of post IDs to retrieve, sticky posts will be included.
--         --     @type int[]           $post__not_in            An array of post IDs not to retrieve. Note: a string of comma-
--         --                                                    separated IDs will NOT work.
--         --     @type string          $post_mime_type          The mime type of the post. Used for 'attachment' post_type.
--         --     @type string[]        $post_name__in           An array of post slugs that results must match.
--         --     @type int             $post_parent             Page ID to retrieve child pages for. Use 0 to only retrieve
--         --                                                    top-level pages.
--         --     @type int[]           $post_parent__in         An array containing parent page IDs to query child pages from.
--         --     @type int[]           $post_parent__not_in     An array containing parent page IDs not to query child pages from.
--         --     @type string|string[] $post_type               A post type slug (string) or array of post type slugs.
--         --                                                    Default 'any' if using 'tax_query'.
--         --     @type string|string[] $post_status             A post status (string) or array of post statuses.
--         --     @type int             $posts_per_page          The number of posts to query for. Use -1 to request all posts.
--         --     @type int             $posts_per_archive_page  The number of posts to query for by archive page. Overrides
--         --                                                    'posts_per_page' when is_archive(), or is_search() are true.
--         --     @type string          $s                       Search keyword(s). Prepending a term with a hyphen will
--         --                                                    exclude posts matching that term. Eg, 'pillow -sofa' will
--         --                                                    return posts containing 'pillow' but not 'sofa'. The
--         --                                                    character used for exclusion can be modified using the
--         --                                                    the 'wp_query_search_exclusion_prefix' filter.
--         --     @type int             $second                  Second of the minute. Default empty. Accepts numbers 0-59.
--         --     @type bool            $sentence                Whether to search by phrase. Default false.
--         --     @type bool            $suppress_filters        Whether to suppress filters. Default false.
--         --     @type string          $tag                     Tag slug. Comma-separated (either), Plus-separated (all).
--         --     @type int[]           $tag__and                An array of tag IDs (AND in).
--         --     @type int[]           $tag__in                 An array of tag IDs (OR in).
--         --     @type int[]           $tag__not_in             An array of tag IDs (NOT in).
--         --     @type int             $tag_id                  Tag id or comma-separated list of IDs.
--         --     @type string[]        $tag_slug__and           An array of tag slugs (AND in).
--         --     @type string[]        $tag_slug__in            An array of tag slugs (OR in). unless 'ignore_sticky_posts' is
--         --                                                    true. Note: a string of comma-separated IDs will NOT work.
--         --     @type array           $tax_query               An associative array of WP_Tax_Query arguments.
--         --                                                    See WP_Tax_Query::__construct().
--         --     @type string          $title                   Post title.
--         --     @type bool            $update_post_meta_cache  Whether to update the post meta cache. Default true.
--         --     @type bool            $update_post_term_cache  Whether to update the post term cache. Default true.
--         --     @type bool            $update_menu_item_cache  Whether to update the menu item cache. Default false.
--         --     @type bool            $lazy_load_term_meta     Whether to lazy-load term meta. Setting to false will
--         --                                                    disable cache priming for term meta, so that each
--         --                                                    get_term_meta() call will hit the database.
--         --                                                    Defaults to the value of `$update_post_term_cache`.
--         --     @type int             $w                       The week number of the year. Default empty. Accepts numbers 0-53.
--         --     @type int             $year                    The four-digit year. Default empty. Accepts any four-digit year.
--         -- end;
--         --
--         public function parse_query( $query = '' ) then
--                 if ( ! empty( $query ) ) then
--                         $this->init();
--                         $this->query      = wp_parse_args( $query );
--                         $this->query_vars = $this->query;
--                 end; elseif ( ! isset( $this->query ) ) then
--                         $this->query = $this->query_vars;
--                 end;

--                 $this->query_vars         = $this->fill_query_vars( $this->query_vars );
--                 $qv                       = &$this->query_vars;
--                 $this->query_vars_changed = true;

--                 if ( ! empty( $qv['robots'] ) ) then
--                         $this->is_robots = true;
--                 end; elseif ( ! empty( $qv['favicon'] ) ) then
--                         $this->is_favicon = true;
--                 end;

--                 if ( ! is_scalar( $qv['p'] ) || (int) $qv['p'] < 0 ) then
--                         $qv['p']     = 0;
--                         $qv['error'] = '404';
--                 end; else then
--                         $qv['p'] = (int) $qv['p'];
--                 end;

--                 $qv['page_id']  = is_scalar( $qv['page_id'] ) ? absint( $qv['page_id'] ) : 0;
--                 $qv['year']     = is_scalar( $qv['year'] ) ? absint( $qv['year'] ) : 0;
--                 $qv['monthnum'] = is_scalar( $qv['monthnum'] ) ? absint( $qv['monthnum'] ) : 0;
--                 $qv['day']      = is_scalar( $qv['day'] ) ? absint( $qv['day'] ) : 0;
--                 $qv['w']        = is_scalar( $qv['w'] ) ? absint( $qv['w'] ) : 0;
--                 $qv['m']        = is_scalar( $qv['m'] ) ? preg_replace( '|[^0-9]|', '', $qv['m'] ) : '';
--                 $qv['paged']    = is_scalar( $qv['paged'] ) ? absint( $qv['paged'] ) : 0;
--                 $qv['cat']      = preg_replace( '|[^0-9,-]|', '', $qv['cat'] ); // Array or comma-separated list of positive or negative integers.
--                 $qv['author']   = is_scalar( $qv['author'] ) ? preg_replace( '|[^0-9,-]|', '', $qv['author'] ) : ''; // Comma-separated list of positive or negative integers.
--                 $qv['pagename'] = is_scalar( $qv['pagename'] ) ? trim( $qv['pagename'] ) : '';
--                 $qv['name']     = is_scalar( $qv['name'] ) ? trim( $qv['name'] ) : '';
--                 $qv['title']    = is_scalar( $qv['title'] ) ? trim( $qv['title'] ) : '';

--                 if ( is_scalar( $qv['hour'] ) && '' !== $qv['hour'] ) then
--                         $qv['hour'] = absint( $qv['hour'] );
--                 end; else then
--                         $qv['hour'] = '';
--                 end;

--                 if ( is_scalar( $qv['minute'] ) && '' !== $qv['minute'] ) then
--                         $qv['minute'] = absint( $qv['minute'] );
--                 end; else then
--                         $qv['minute'] = '';
--                 end;

--                 if ( is_scalar( $qv['second'] ) && '' !== $qv['second'] ) then
--                         $qv['second'] = absint( $qv['second'] );
--                 end; else then
--                         $qv['second'] = '';
--                 end;

--                 if ( is_scalar( $qv['menu_order'] ) && '' !== $qv['menu_order'] ) then
--                         $qv['menu_order'] = absint( $qv['menu_order'] );
--                 end; else then
--                         $qv['menu_order'] = '';
--                 end;

--                 // Fairly large, potentially too large, upper bound for search string lengths.
--                 if ( ! is_scalar( $qv['s'] ) || ( ! empty( $qv['s'] ) && strlen( $qv['s'] ) > 1600 ) ) then
--                         $qv['s'] = '';
--                 end;

--                 // Compat. Map subpost to attachment.
--                 if ( is_scalar( $qv['subpost'] ) && '' != $qv['subpost'] ) then
--                         $qv['attachment'] = $qv['subpost'];
--                 end;
--                 if ( is_scalar( $qv['subpost_id'] ) && '' != $qv['subpost_id'] ) then
--                         $qv['attachment_id'] = $qv['subpost_id'];
--                 end;

--                 $qv['attachment_id'] = is_scalar( $qv['attachment_id'] ) ? absint( $qv['attachment_id'] ) : 0;

--                 if ( ( '' !== $qv['attachment'] ) || ! empty( $qv['attachment_id'] ) ) then
--                         $this->is_single     = true;
--                         $this->is_attachment = true;
--                 end; elseif ( '' !== $qv['name'] ) then
--                         $this->is_single = true;
--                 end; elseif ( $qv['p'] ) then
--                         $this->is_single = true;
--                 end; elseif ( '' !== $qv['pagename'] || ! empty( $qv['page_id'] ) ) then
--                         $this->is_page   = true;
--                         $this->is_single = false;
--                 end; else then
--                         // Look for archive queries. Dates, categories, authors, search, post type archives.

--                         if ( isset( $this->query['s'] ) ) then
--                                 $this->is_search = true;
--                         end;

--                         if ( '' !== $qv['second'] ) then
--                                 $this->is_time = true;
--                                 $this->is_date = true;
--                         end;

--                         if ( '' !== $qv['minute'] ) then
--                                 $this->is_time = true;
--                                 $this->is_date = true;
--                         end;

--                         if ( '' !== $qv['hour'] ) then
--                                 $this->is_time = true;
--                                 $this->is_date = true;
--                         end;

--                         if ( $qv['day'] ) then
--                                 if ( ! $this->is_date ) then
--                                         $date = sprintf( '%04d-%02d-%02d', $qv['year'], $qv['monthnum'], $qv['day'] );
--                                         if ( $qv['monthnum'] && $qv['year'] && ! wp_checkdate( $qv['monthnum'], $qv['day'], $qv['year'], $date ) ) then
--                                                 $qv['error'] = '404';
--                                         end; else then
--                                                 $this->is_day  = true;
--                                                 $this->is_date = true;
--                                         end;
--                                 end;
--                         end;

--                         if ( $qv['monthnum'] ) then
--                                 if ( ! $this->is_date ) then
--                                         if ( 12 < $qv['monthnum'] ) then
--                                                 $qv['error'] = '404';
--                                         end; else then
--                                                 $this->is_month = true;
--                                                 $this->is_date  = true;
--                                         end;
--                                 end;
--                         end;

--                         if ( $qv['year'] ) then
--                                 if ( ! $this->is_date ) then
--                                         $this->is_year = true;
--                                         $this->is_date = true;
--                                 end;
--                         end;

--                         if ( $qv['m'] ) then
--                                 $this->is_date = true;
--                                 if ( strlen( $qv['m'] ) > 9 ) then
--                                         $this->is_time = true;
--                                 end; elseif ( strlen( $qv['m'] ) > 7 ) then
--                                         $this->is_day = true;
--                                 end; elseif ( strlen( $qv['m'] ) > 5 ) then
--                                         $this->is_month = true;
--                                 end; else then
--                                         $this->is_year = true;
--                                 end;
--                         end;

--                         if ( $qv['w'] ) then
--                                 $this->is_date = true;
--                         end;

--                         $this->query_vars_hash = false;
--                         $this->parse_tax_query( $qv );

--                         foreach ( $this->tax_query->queries as $tax_query ) then
--                                 if ( ! is_array( $tax_query ) ) then
--                                         continue;
--                                 end;

--                                 if ( isset( $tax_query['operator'] ) && 'NOT IN' !== $tax_query['operator'] ) then
--                                         switch ( $tax_query['taxonomy'] ) then
--                                                 case 'category':
--                                                         $this->is_category = true;
--                                                         break;
--                                                 case 'post_tag':
--                                                         $this->is_tag = true;
--                                                         break;
--                                                 default:
--                                                         $this->is_tax = true;
--                                         end;
--                                 end;
--                         end;
--                         unset( $tax_query );

--                         if ( empty( $qv['author'] ) || ( '0' == $qv['author'] ) ) then
--                                 $this->is_author = false;
--                         end; else then
--                                 $this->is_author = true;
--                         end;

--                         if ( '' !== $qv['author_name'] ) then
--                                 $this->is_author = true;
--                         end;

--                         if ( ! empty( $qv['post_type'] ) && ! is_array( $qv['post_type'] ) ) then
--                                 $post_type_obj = get_post_type_object( $qv['post_type'] );
--                                 if ( ! empty( $post_type_obj->has_archive ) ) then
--                                         $this->is_post_type_archive = true;
--                                 end;
--                         end;

--                         if ( $this->is_post_type_archive || $this->is_date || $this->is_author || $this->is_category || $this->is_tag || $this->is_tax ) then
--                                 $this->is_archive = true;
--                         end;
--                 end;

--                 if ( '' != $qv['feed'] ) then
--                         $this->is_feed = true;
--                 end;

--                 if ( '' != $qv['embed'] ) then
--                         $this->is_embed = true;
--                 end;

--                 if ( '' != $qv['tb'] ) then
--                         $this->is_trackback = true;
--                 end;

--                 if ( '' != $qv['paged'] && ( (int) $qv['paged'] > 1 ) ) then
--                         $this->is_paged = true;
--                 end;

--                 // If we're previewing inside the write screen.
--                 if ( '' != $qv['preview'] ) then
--                         $this->is_preview = true;
--                 end;

--                 if ( is_admin() ) then
--                         $this->is_admin = true;
--                 end;

--                 if ( false !== strpos( $qv['feed'], 'comments-' ) ) then
--                         $qv['feed']         = str_replace( 'comments-', '', $qv['feed'] );
--                         $qv['withcomments'] = 1;
--                 end;

--                 $this->is_singular = $this->is_single || $this->is_page || $this->is_attachment;

--                 if ( $this->is_feed && ( ! empty( $qv['withcomments'] ) || ( empty( $qv['withoutcomments'] ) && $this->is_singular ) ) ) then
--                         $this->is_comment_feed = true;
--                 end;

--                 if ( ! ( $this->is_singular || $this->is_archive || $this->is_search || $this->is_feed
--                                 || ( defined( 'REST_REQUEST' ) && REST_REQUEST && $this->is_main_query() )
--                                 || $this->is_trackback || $this->is_404 || $this->is_admin || $this->is_robots || $this->is_favicon ) ) then
--                         $this->is_home = true;
--                 end;

--                 // Correct `is_*` for 'page_on_front' and 'page_for_posts'.
--                 if ( $this->is_home && 'page' === get_option( 'show_on_front' ) && get_option( 'page_on_front' ) ) then
--                         $_query = wp_parse_args( $this->query );
--                         // 'pagename' can be set and empty depending on matched rewrite rules. Ignore an empty 'pagename'.
--                         if ( isset( $_query['pagename'] ) && '' === $_query['pagename'] ) then
--                                 unset( $_query['pagename'] );
--                         end;

--                         unset( $_query['embed'] );

--                         if ( empty( $_query ) || ! array_diff( array_keys( $_query ), array( 'preview', 'page', 'paged', 'cpage' ) ) ) then
--                                 $this->is_page = true;
--                                 $this->is_home = false;
--                                 $qv['page_id'] = get_option( 'page_on_front' );
--                                 // Correct <!--nextpage--> for 'page_on_front'.
--                                 if ( ! empty( $qv['paged'] ) ) then
--                                         $qv['page'] = $qv['paged'];
--                                         unset( $qv['paged'] );
--                                 end;
--                         end;
--                 end;

--                 if ( '' !== $qv['pagename'] ) then
--                         $this->queried_object = get_page_by_path( $qv['pagename'] );

--                         if ( $this->queried_object && 'attachment' === $this->queried_object->post_type ) then
--                                 if ( preg_match( '/^[^%]*%(?:postname)%/', get_option( 'permalink_structure' ) ) ) then
--                                         // See if we also have a post with the same slug.
--                                         $post = get_page_by_path( $qv['pagename'], OBJECT, 'post' );
--                                         if ( $post ) then
--                                                 $this->queried_object = $post;
--                                                 $this->is_page        = false;
--                                                 $this->is_single      = true;
--                                         end;
--                                 end;
--                         end;

--                         if ( ! empty( $this->queried_object ) ) then
--                                 $this->queried_object_id = (int) $this->queried_object->ID;
--                         end; else then
--                                 unset( $this->queried_object );
--                         end;

--                         if ( 'page' === get_option( 'show_on_front' ) && isset( $this->queried_object_id ) && get_option( 'page_for_posts' ) == $this->queried_object_id ) then
--                                 $this->is_page       = false;
--                                 $this->is_home       = true;
--                                 $this->is_posts_page = true;
--                         end;

--                         if ( isset( $this->queried_object_id ) && get_option( 'wp_page_for_privacy_policy' ) == $this->queried_object_id ) then
--                                 $this->is_privacy_policy = true;
--                         end;
--                 end;

--                 if ( $qv['page_id'] ) then
--                         if ( 'page' === get_option( 'show_on_front' ) && get_option( 'page_for_posts' ) == $qv['page_id'] ) then
--                                 $this->is_page       = false;
--                                 $this->is_home       = true;
--                                 $this->is_posts_page = true;
--                         end;

--                         if ( get_option( 'wp_page_for_privacy_policy' ) == $qv['page_id'] ) then
--                                 $this->is_privacy_policy = true;
--                         end;
--                 end;

--                 if ( ! empty( $qv['post_type'] ) ) then
--                         if ( is_array( $qv['post_type'] ) ) then
--                                 $qv['post_type'] = array_map( 'sanitize_key', $qv['post_type'] );
--                         end; else then
--                                 $qv['post_type'] = sanitize_key( $qv['post_type'] );
--                         end;
--                 end;

--                 if ( ! empty( $qv['post_status'] ) ) then
--                         if ( is_array( $qv['post_status'] ) ) then
--                                 $qv['post_status'] = array_map( 'sanitize_key', $qv['post_status'] );
--                         end; else then
--                                 $qv['post_status'] = preg_replace( '|[^a-z0-9_,-]|', '', $qv['post_status'] );
--                         end;
--                 end;

--                 if ( $this->is_posts_page && ( ! isset( $qv['withcomments'] ) || ! $qv['withcomments'] ) ) then
--                         $this->is_comment_feed = false;
--                 end;

--                 $this->is_singular = $this->is_single || $this->is_page || $this->is_attachment;
--                 // Done correcting `is_*` for 'page_on_front' and 'page_for_posts'.

--                 if ( '404' == $qv['error'] ) then
--                         $this->set_404();
--                 end;

--                 $this->is_embed = $this->is_embed && ( $this->is_singular || $this->is_404 );

--                 $this->query_vars_hash    = md5( serialize( $this->query_vars ) );
--                 $this->query_vars_changed = false;

--                 --
--                 -- Fires after the main query vars have been parsed.
--                 --
--                 -- @since 1.5.0
--                 --
--                 -- @param WP_Query $query The WP_Query instance (passed by reference).
--                 --
--                 do_action_ref_array( 'parse_query', array( &$this ) );
--         end;

--         --
--         -- Parses various taxonomy related query vars.
--         --
--         -- For BC, this method is not marked as protected. See [28987].
--         --
--         -- @since 3.1.0
--         --
--         -- @param array $q The query variables. Passed by reference.
--         --
--         public function parse_tax_query( &$q ) then
--                 if ( ! empty( $q['tax_query'] ) && is_array( $q['tax_query'] ) ) then
--                         $tax_query = $q['tax_query'];
--                 end; else then
--                         $tax_query = array();
--                 end;

--                 if ( ! empty( $q['taxonomy'] ) && ! empty( $q['term'] ) ) then
--                         $tax_query[] = array(
--                                 'taxonomy' => $q['taxonomy'],
--                                 'terms'    => array( $q['term'] ),
--                                 'field'    => 'slug',
--                         );
--                 end;

--                 foreach ( get_taxonomies( array(), 'objects' ) as $taxonomy => $t ) then
--                         if ( 'post_tag' === $taxonomy ) then
--                                 continue; // Handled further down in the $q['tag'] block.
--                         end;

--                         if ( $t->query_var && ! empty( $q[ $t->query_var ] ) ) then
--                                 $tax_query_defaults = array(
--                                         'taxonomy' => $taxonomy,
--                                         'field'    => 'slug',
--                                 );

--                                 if ( ! empty( $t->rewrite['hierarchical'] ) ) then
--                                         $q[ $t->query_var ] = wp_basename( $q[ $t->query_var ] );
--                                 end;

--                                 $term = $q[ $t->query_var ];

--                                 if ( is_array( $term ) ) then
--                                         $term = implode( ',', $term );
--                                 end;

--                                 if ( strpos( $term, '+' ) !== false ) then
--                                         $terms = preg_split( '/[+]+/', $term );
--                                         foreach ( $terms as $term ) then
--                                                 $tax_query[] = array_merge(
--                                                         $tax_query_defaults,
--                                                         array(
--                                                                 'terms' => array( $term ),
--                                                         )
--                                                 );
--                                         end;
--                                 end; else then
--                                         $tax_query[] = array_merge(
--                                                 $tax_query_defaults,
--                                                 array(
--                                                         'terms' => preg_split( '/[,]+/', $term ),
--                                                 )
--                                         );
--                                 end;
--                         end;
--                 end;

--                 // If query string 'cat' is an array, implode it.
--                 if ( is_array( $q['cat'] ) ) then
--                         $q['cat'] = implode( ',', $q['cat'] );
--                 end;

--                 // Category stuff.

--                 if ( ! empty( $q['cat'] ) && ! $this->is_singular ) then
--                         $cat_in     = array();
--                         $cat_not_in = array();

--                         $cat_array = preg_split( '/[,\s]+/', urldecode( $q['cat'] ) );
--                         $cat_array = array_map( 'intval', $cat_array );
--                         $q['cat']  = implode( ',', $cat_array );

--                         foreach ( $cat_array as $cat ) then
--                                 if ( $cat > 0 ) then
--                                         $cat_in[] = $cat;
--                                 end; elseif ( $cat < 0 ) then
--                                         $cat_not_in[] = abs( $cat );
--                                 end;
--                         end;

--                         if ( ! empty( $cat_in ) ) then
--                                 $tax_query[] = array(
--                                         'taxonomy'         => 'category',
--                                         'terms'            => $cat_in,
--                                         'field'            => 'term_id',
--                                         'include_children' => true,
--                                 );
--                         end;

--                         if ( ! empty( $cat_not_in ) ) then
--                                 $tax_query[] = array(
--                                         'taxonomy'         => 'category',
--                                         'terms'            => $cat_not_in,
--                                         'field'            => 'term_id',
--                                         'operator'         => 'NOT IN',
--                                         'include_children' => true,
--                                 );
--                         end;
--                         unset( $cat_array, $cat_in, $cat_not_in );
--                 end;

--                 if ( ! empty( $q['category__and'] ) && 1 === count( (array) $q['category__and'] ) ) then
--                         $q['category__and'] = (array) $q['category__and'];
--                         if ( ! isset( $q['category__in'] ) ) then
--                                 $q['category__in'] = array();
--                         end;
--                         $q['category__in'][] = absint( reset( $q['category__and'] ) );
--                         unset( $q['category__and'] );
--                 end;

--                 if ( ! empty( $q['category__in'] ) ) then
--                         $q['category__in'] = array_map( 'absint', array_unique( (array) $q['category__in'] ) );
--                         $tax_query[]       = array(
--                                 'taxonomy'         => 'category',
--                                 'terms'            => $q['category__in'],
--                                 'field'            => 'term_id',
--                                 'include_children' => false,
--                         );
--                 end;

--                 if ( ! empty( $q['category__not_in'] ) ) then
--                         $q['category__not_in'] = array_map( 'absint', array_unique( (array) $q['category__not_in'] ) );
--                         $tax_query[]           = array(
--                                 'taxonomy'         => 'category',
--                                 'terms'            => $q['category__not_in'],
--                                 'operator'         => 'NOT IN',
--                                 'include_children' => false,
--                         );
--                 end;

--                 if ( ! empty( $q['category__and'] ) ) then
--                         $q['category__and'] = array_map( 'absint', array_unique( (array) $q['category__and'] ) );
--                         $tax_query[]        = array(
--                                 'taxonomy'         => 'category',
--                                 'terms'            => $q['category__and'],
--                                 'field'            => 'term_id',
--                                 'operator'         => 'AND',
--                                 'include_children' => false,
--                         );
--                 end;

--                 // If query string 'tag' is array, implode it.
--                 if ( is_array( $q['tag'] ) ) then
--                         $q['tag'] = implode( ',', $q['tag'] );
--                 end;

--                 // Tag stuff.

--                 if ( '' !== $q['tag'] && ! $this->is_singular && $this->query_vars_changed ) then
--                         if ( strpos( $q['tag'], ',' ) !== false ) then
--                                 $tags = preg_split( '/[,\r\n\t ]+/', $q['tag'] );
--                                 foreach ( (array) $tags as $tag ) then
--                                         $tag                 = sanitize_term_field( 'slug', $tag, 0, 'post_tag', 'db' );
--                                         $q['tag_slug__in'][] = $tag;
--                                 end;
--                         end; elseif ( preg_match( '/[+\r\n\t ]+/', $q['tag'] ) || ! empty( $q['cat'] ) ) then
--                                 $tags = preg_split( '/[+\r\n\t ]+/', $q['tag'] );
--                                 foreach ( (array) $tags as $tag ) then
--                                         $tag                  = sanitize_term_field( 'slug', $tag, 0, 'post_tag', 'db' );
--                                         $q['tag_slug__and'][] = $tag;
--                                 end;
--                         end; else then
--                                 $q['tag']            = sanitize_term_field( 'slug', $q['tag'], 0, 'post_tag', 'db' );
--                                 $q['tag_slug__in'][] = $q['tag'];
--                         end;
--                 end;

--                 if ( ! empty( $q['tag_id'] ) ) then
--                         $q['tag_id'] = absint( $q['tag_id'] );
--                         $tax_query[] = array(
--                                 'taxonomy' => 'post_tag',
--                                 'terms'    => $q['tag_id'],
--                         );
--                 end;

--                 if ( ! empty( $q['tag__in'] ) ) then
--                         $q['tag__in'] = array_map( 'absint', array_unique( (array) $q['tag__in'] ) );
--                         $tax_query[]  = array(
--                                 'taxonomy' => 'post_tag',
--                                 'terms'    => $q['tag__in'],
--                         );
--                 end;

--                 if ( ! empty( $q['tag__not_in'] ) ) then
--                         $q['tag__not_in'] = array_map( 'absint', array_unique( (array) $q['tag__not_in'] ) );
--                         $tax_query[]      = array(
--                                 'taxonomy' => 'post_tag',
--                                 'terms'    => $q['tag__not_in'],
--                                 'operator' => 'NOT IN',
--                         );
--                 end;

--                 if ( ! empty( $q['tag__and'] ) ) then
--                         $q['tag__and'] = array_map( 'absint', array_unique( (array) $q['tag__and'] ) );
--                         $tax_query[]   = array(
--                                 'taxonomy' => 'post_tag',
--                                 'terms'    => $q['tag__and'],
--                                 'operator' => 'AND',
--                         );
--                 end;

--                 if ( ! empty( $q['tag_slug__in'] ) ) then
--                         $q['tag_slug__in'] = array_map( 'sanitize_title_for_query', array_unique( (array) $q['tag_slug__in'] ) );
--                         $tax_query[]       = array(
--                                 'taxonomy' => 'post_tag',
--                                 'terms'    => $q['tag_slug__in'],
--                                 'field'    => 'slug',
--                         );
--                 end;

--                 if ( ! empty( $q['tag_slug__and'] ) ) then
--                         $q['tag_slug__and'] = array_map( 'sanitize_title_for_query', array_unique( (array) $q['tag_slug__and'] ) );
--                         $tax_query[]        = array(
--                                 'taxonomy' => 'post_tag',
--                                 'terms'    => $q['tag_slug__and'],
--                                 'field'    => 'slug',
--                                 'operator' => 'AND',
--                         );
--                 end;

--                 $this->tax_query = new WP_Tax_Query( $tax_query );

--                 --
--                 -- Fires after taxonomy-related query vars have been parsed.
--                 --
--                 -- @since 3.7.0
--                 --
--                 -- @param WP_Query $query The WP_Query instance.
--                 --
--                 do_action( 'parse_tax_query', $this );
--         end;

--         --
--         -- Generates SQL for the WHERE clause based on passed search terms.
--         --
--         -- @since 3.7.0
--         --
--         -- @global wpdb $wpdb WordPress database abstraction object.
--         --
--         -- @param array $q Query variables.
--         -- @return string WHERE clause.
--         --
--         protected function parse_search( &$q ) then
--                 global $wpdb;

--                 $search = '';

--                 // Added slashes screw with quote grouping when done early, so done later.
--                 $q['s'] = stripslashes( $q['s'] );
--                 if ( empty( $_GET['s'] ) && $this->is_main_query() ) then
--                         $q['s'] = urldecode( $q['s'] );
--                 end;
--                 // There are no line breaks in <input /> fields.
--                 $q['s']                  = str_replace( array( "\r", "\n" ), '', $q['s'] );
--                 $q['search_terms_count'] = 1;
--                 if ( ! empty( $q['sentence'] ) ) then
--                         $q['search_terms'] = array( $q['s'] );
--                 end; else then
--                         if ( preg_match_all( '/".*?("|$)|((?<=[\t ",+])|^)[^\t ",+]+/', $q['s'], $matches ) ) then
--                                 $q['search_terms_count'] = count( $matches[0] );
--                                 $q['search_terms']       = $this->parse_search_terms( $matches[0] );
--                                 // If the search string has only short terms or stopwords, or is 10+ terms long, match it as sentence.
--                                 if ( empty( $q['search_terms'] ) || count( $q['search_terms'] ) > 9 ) then
--                                         $q['search_terms'] = array( $q['s'] );
--                                 end;
--                         end; else then
--                                 $q['search_terms'] = array( $q['s'] );
--                         end;
--                 end;

--                 $n                         = ! empty( $q['exact'] ) ? '' : '%';
--                 $searchand                 = '';
--                 $q['search_orderby_title'] = array();

--                 --
--                 -- Filters the prefix that indicates that a search term should be excluded from results.
--                 --
--                 -- @since 4.7.0
--                 --
--                 -- @param string $exclusion_prefix The prefix. Default '-'. Returning
--                 --                                 an empty value disables exclusions.
--                 --
--                 $exclusion_prefix = apply_filters( 'wp_query_search_exclusion_prefix', '-' );

--                 foreach ( $q['search_terms'] as $term ) then
--                         // If there is an $exclusion_prefix, terms prefixed with it should be excluded.
--                         $exclude = $exclusion_prefix && ( substr( $term, 0, 1 ) === $exclusion_prefix );
--                         if ( $exclude ) then
--                                 $like_op  = 'NOT LIKE';
--                                 $andor_op = 'AND';
--                                 $term     = substr( $term, 1 );
--                         end; else then
--                                 $like_op  = 'LIKE';
--                                 $andor_op = 'OR';
--                         end;

--                         if ( $n && ! $exclude ) then
--                                 $like                        = '%' . $wpdb->esc_like( $term ) . '%';
--                                 $q['search_orderby_title'][] = $wpdb->prepare( "then$wpdb->postsend;.post_title LIKE %s", $like );
--                         end;

--                         $like = $n . $wpdb->esc_like( $term ) . $n;

--                         if ( ! empty( $this->allow_query_attachment_by_filename ) ) then
--                                 $search .= $wpdb->prepare( "then$searchandend;((then$wpdb->postsend;.post_title $like_op %s) $andor_op (then$wpdb->postsend;.post_excerpt $like_op %s) $andor_op (then$wpdb->postsend;.post_content $like_op %s) $andor_op (sq1.meta_value $like_op %s))", $like, $like, $like, $like );
--                         end; else then
--                                 $search .= $wpdb->prepare( "then$searchandend;((then$wpdb->postsend;.post_title $like_op %s) $andor_op (then$wpdb->postsend;.post_excerpt $like_op %s) $andor_op (then$wpdb->postsend;.post_content $like_op %s))", $like, $like, $like );
--                         end;
--                         $searchand = ' AND ';
--                 end;

--                 if ( ! empty( $search ) ) then
--                         $search = " AND (then$searchend;) ";
--                         if ( ! is_user_logged_in() ) then
--                                 $search .= " AND (then$wpdb->postsend;.post_password = '') ";
--                         end;
--                 end;

--                 return $search;
--         end;

--         --
--         -- Check if the terms are suitable for searching.
--         --
--         -- Uses an array of stopwords (terms) that are excluded from the separate
--         -- term matching when searching for posts. The list of English stopwords is
--         -- the approximate search engines list, and is translatable.
--         --
--         -- @since 3.7.0
--         --
--         -- @param string[] $terms Array of terms to check.
--         -- @return string[] Terms that are not stopwords.
--         --
--         protected function parse_search_terms( $terms ) then
--                 $strtolower = function_exists( 'mb_strtolower' ) ? 'mb_strtolower' : 'strtolower';
--                 $checked    = array();

--                 $stopwords = $this->get_search_stopwords();

--                 foreach ( $terms as $term ) then
--                         // Keep before/after spaces when term is for exact match.
--                         if ( preg_match( '/^".+"$/', $term ) ) then
--                                 $term = trim( $term, "\"'" );
--                         end; else then
--                                 $term = trim( $term, "\"' " );
--                         end;

--                         // Avoid single A-Z and single dashes.
--                         if ( ! $term || ( 1 === strlen( $term ) && preg_match( '/^[a-z\-]$/i', $term ) ) ) then
--                                 continue;
--                         end;

--                         if ( in_array( call_user_func( $strtolower, $term ), $stopwords, true ) ) then
--                                 continue;
--                         end;

--                         $checked[] = $term;
--                 end;

--                 return $checked;
--         end;

--         --
--         -- Retrieve stopwords used when parsing search terms.
--         --
--         -- @since 3.7.0
--         --
--         -- @return string[] Stopwords.
--         --
--         protected function get_search_stopwords() then
--                 if ( isset( $this->stopwords ) ) then
--                         return $this->stopwords;
--                 end;

--                 /*
--                 -- translators: This is a comma-separated list of very common words that should be excluded from a search,
--                 -- like a, an, and the. These are usually called "stopwords". You should not simply translate these individual
--                 -- words into your language. Instead, look for and provide commonly accepted stopwords in your language.
--                 --
--                 $words = explode(
--                         ',',
--                         _x(
--                                 'about,an,are,as,at,be,by,com,for,from,how,in,is,it,of,on,or,that,the,this,to,was,what,when,where,who,will,with,www',
--                                 'Comma-separated list of search stopwords in your language'
--                         )
--                 );

--                 $stopwords = array();
--                 foreach ( $words as $word ) then
--                         $word = trim( $word, "\r\n\t " );
--                         if ( $word ) then
--                                 $stopwords[] = $word;
--                         end;
--                 end;

--                 --
--                 -- Filters stopwords used when parsing search terms.
--                 --
--                 -- @since 3.7.0
--                 --
--                 -- @param string[] $stopwords Array of stopwords.
--                 --
--                 $this->stopwords = apply_filters( 'wp_search_stopwords', $stopwords );
--                 return $this->stopwords;
--         end;

--         --
--         -- Generates SQL for the ORDER BY condition based on passed search terms.
--         --
--         -- @since 3.7.0
--         --
--         -- @global wpdb $wpdb WordPress database abstraction object.
--         --
--         -- @param array $q Query variables.
--         -- @return string ORDER BY clause.
--         --
--         protected function parse_search_order( &$q ) then
--                 global $wpdb;

--                 if ( $q['search_terms_count'] > 1 ) then
--                         $num_terms = count( $q['search_orderby_title'] );

--                         // If the search terms contain negative queries, don't bother ordering by sentence matches.
--                         $like = '';
--                         if ( ! preg_match( '/(?:\s|^)\-/', $q['s'] ) ) then
--                                 $like = '%' . $wpdb->esc_like( $q['s'] ) . '%';
--                         end;

--                         $search_orderby = '';

--                         // Sentence match in 'post_title'.
--                         if ( $like ) then
--                                 $search_orderby .= $wpdb->prepare( "WHEN then$wpdb->postsend;.post_title LIKE %s THEN 1 ", $like );
--                         end;

--                         // Sanity limit, sort as sentence when more than 6 terms
--                         // (few searches are longer than 6 terms and most titles are not).
--                         if ( $num_terms < 7 ) then
--                                 // All words in title.
--                                 $search_orderby .= 'WHEN ' . implode( ' AND ', $q['search_orderby_title'] ) . ' THEN 2 ';
--                                 // Any word in title, not needed when $num_terms == 1.
--                                 if ( $num_terms > 1 ) then
--                                         $search_orderby .= 'WHEN ' . implode( ' OR ', $q['search_orderby_title'] ) . ' THEN 3 ';
--                                 end;
--                         end;

--                         // Sentence match in 'post_content' and 'post_excerpt'.
--                         if ( $like ) then
--                                 $search_orderby .= $wpdb->prepare( "WHEN then$wpdb->postsend;.post_excerpt LIKE %s THEN 4 ", $like );
--                                 $search_orderby .= $wpdb->prepare( "WHEN then$wpdb->postsend;.post_content LIKE %s THEN 5 ", $like );
--                         end;

--                         if ( $search_orderby ) then
--                                 $search_orderby = '(CASE ' . $search_orderby . 'ELSE 6 END)';
--                         end;
--                 end; else then
--                         // Single word or sentence search.
--                         $search_orderby = reset( $q['search_orderby_title'] ) . ' DESC';
--                 end;

--                 return $search_orderby;
--         end;

--         --
--         -- Converts the given orderby alias (if allowed) to a properly-prefixed value.
--         --
--         -- @since 4.0.0
--         --
--         -- @global wpdb $wpdb WordPress database abstraction object.
--         --
--         -- @param string $orderby Alias for the field to order by.
--         -- @return string|false Table-prefixed value to used in the ORDER clause. False otherwise.
--         --
--         protected function parse_orderby( $orderby ) then
--                 global $wpdb;

--                 // Used to filter values.
--                 $allowed_keys = array(
--                         'post_name',
--                         'post_author',
--                         'post_date',
--                         'post_title',
--                         'post_modified',
--                         'post_parent',
--                         'post_type',
--                         'name',
--                         'author',
--                         'date',
--                         'title',
--                         'modified',
--                         'parent',
--                         'type',
--                         'ID',
--                         'menu_order',
--                         'comment_count',
--                         'rand',
--                         'post__in',
--                         'post_parent__in',
--                         'post_name__in',
--                 );

--                 $primary_meta_key   = '';
--                 $primary_meta_query = false;
--                 $meta_clauses       = $this->meta_query->get_clauses();
--                 if ( ! empty( $meta_clauses ) ) then
--                         $primary_meta_query = reset( $meta_clauses );

--                         if ( ! empty( $primary_meta_query['key'] ) ) then
--                                 $primary_meta_key = $primary_meta_query['key'];
--                                 $allowed_keys[]   = $primary_meta_key;
--                         end;

--                         $allowed_keys[] = 'meta_value';
--                         $allowed_keys[] = 'meta_value_num';
--                         $allowed_keys   = array_merge( $allowed_keys, array_keys( $meta_clauses ) );
--                 end;

--                 // If RAND() contains a seed value, sanitize and add to allowed keys.
--                 $rand_with_seed = false;
--                 if ( preg_match( '/RAND\(([0-9]+)\)/i', $orderby, $matches ) ) then
--                         $orderby        = sprintf( 'RAND(%s)', (int) $matches[1] );
--                         $allowed_keys[] = $orderby;
--                         $rand_with_seed = true;
--                 end;

--                 if ( ! in_array( $orderby, $allowed_keys, true ) ) then
--                         return false;
--                 end;

--                 $orderby_clause = '';

--                 switch ( $orderby ) then
--                         case 'post_name':
--                         case 'post_author':
--                         case 'post_date':
--                         case 'post_title':
--                         case 'post_modified':
--                         case 'post_parent':
--                         case 'post_type':
--                         case 'ID':
--                         case 'menu_order':
--                         case 'comment_count':
--                                 $orderby_clause = "then$wpdb->postsend;.then$orderbyend;";
--                                 break;
--                         case 'rand':
--                                 $orderby_clause = 'RAND()';
--                                 break;
--                         case $primary_meta_key:
--                         case 'meta_value':
--                                 if ( ! empty( $primary_meta_query['type'] ) ) then
--                                         $orderby_clause = "CAST(then$primary_meta_query['alias']end;.meta_value AS then$primary_meta_query['cast']end;)";
--                                 end; else then
--                                         $orderby_clause = "then$primary_meta_query['alias']end;.meta_value";
--                                 end;
--                                 break;
--                         case 'meta_value_num':
--                                 $orderby_clause = "then$primary_meta_query['alias']end;.meta_value+0";
--                                 break;
--                         case 'post__in':
--                                 if ( ! empty( $this->query_vars['post__in'] ) ) then
--                                         $orderby_clause = "FIELD(then$wpdb->postsend;.ID," . implode( ',', array_map( 'absint', $this->query_vars['post__in'] ) ) . ')';
--                                 end;
--                                 break;
--                         case 'post_parent__in':
--                                 if ( ! empty( $this->query_vars['post_parent__in'] ) ) then
--                                         $orderby_clause = "FIELD( then$wpdb->postsend;.post_parent," . implode( ', ', array_map( 'absint', $this->query_vars['post_parent__in'] ) ) . ' )';
--                                 end;
--                                 break;
--                         case 'post_name__in':
--                                 if ( ! empty( $this->query_vars['post_name__in'] ) ) then
--                                         $post_name__in        = array_map( 'sanitize_title_for_query', $this->query_vars['post_name__in'] );
--                                         $post_name__in_string = "'" . implode( "','", $post_name__in ) . "'";
--                                         $orderby_clause       = "FIELD( then$wpdb->postsend;.post_name," . $post_name__in_string . ' )';
--                                 end;
--                                 break;
--                         default:
--                                 if ( array_key_exists( $orderby, $meta_clauses ) ) then
--                                         // $orderby corresponds to a meta_query clause.
--                                         $meta_clause    = $meta_clauses[ $orderby ];
--                                         $orderby_clause = "CAST(then$meta_clause['alias']end;.meta_value AS then$meta_clause['cast']end;)";
--                                 end; elseif ( $rand_with_seed ) then
--                                         $orderby_clause = $orderby;
--                                 end; else then
--                                         // Default: order by post field.
--                                         $orderby_clause = "then$wpdb->postsend;.post_" . sanitize_key( $orderby );
--                                 end;

--                                 break;
--                 end;

--                 return $orderby_clause;
--         end;

--         --
--         -- Parse an 'order' query variable and cast it to ASC or DESC as necessary.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string $order The 'order' query variable.
--         -- @return string The sanitized 'order' query variable.
--         --
--         protected function parse_order( $order ) then
--                 if ( ! is_string( $order ) || empty( $order ) ) then
--                         return 'DESC';
--                 end;

--                 if ( 'ASC' === strtoupper( $order ) ) then
--                         return 'ASC';
--                 end; else then
--                         return 'DESC';
--                 end;
--         end;

--         --
--         -- Sets the 404 property and saves whether query is feed.
--         --
--         -- @since 2.0.0
--         --
--         public function set_404() then
--                 $is_feed = $this->is_feed;

--                 $this->init_query_flags();
--                 $this->is_404 = true;

--                 $this->is_feed = $is_feed;

--                 --
--                 -- Fires after a 404 is triggered.
--                 --
--                 -- @since 5.5.0
--                 --
--                 -- @param WP_Query $query The WP_Query instance (passed by reference).
--                 --
--                 do_action_ref_array( 'set_404', array( $this ) );
--         end;

   ---------
   -- Get --
   ---------

   function Get (This          : Wp_Query;
                 Query_Var     : String;
                 Default_Value : String := "")
                 return String
   is
--    use UStrings;
   begin
      if Isset (This.Query_Vars, Query_Var) then
         return As_String (Get (This.Query_Vars, Query_Var));
      end if;

      return Default_Value;
   end Get;

--         --
--         -- Sets the value of a query variable.
--         --
--         -- @since 1.5.0
--         --
--         -- @param string $query_var Query variable key.
--         -- @param mixed  $value     Query variable value.
--         --
--         public function set( $query_var, $value ) then
--                 $this->query_vars[ $query_var ] = $value;
--         end;

--         --
--         -- Retrieves an array of posts based on query variables.
--         --
--         -- There are a few filters and actions that can be used to modify the post
--         -- database query.
--         --
--         -- @since 1.5.0
--         --
--         -- @global wpdb $wpdb WordPress database abstraction object.
--         --
--         -- @return WP_Post[]|int[] Array of post objects or post IDs.
--         --
--         public function get_posts() then
--                 global $wpdb;

--                 $this->parse_query();

--                 --
--                 -- Fires after the query variable object is created, but before the actual query is run.
--                 --
--                 -- Note: If using conditional tags, use the method versions within the passed instance
--                 -- (e.g. $this->is_main_query() instead of is_main_query()). This is because the functions
--                 -- like is_main_query() test against the global $wp_query instance, not the passed one.
--                 --
--                 -- @since 2.0.0
--                 --
--                 -- @param WP_Query $query The WP_Query instance (passed by reference).
--                 --
--                 do_action_ref_array( 'pre_get_posts', array( &$this ) );

--                 // Shorthand.
--                 $q = &$this->query_vars;

--                 // Fill again in case 'pre_get_posts' unset some vars.
--                 $q = $this->fill_query_vars( $q );

--                 --
--                 -- Filters whether an attachment query should include filenames or not.
--                 --
--                 -- @since 6.0.3
--                 --
--                 -- @param bool $allow_query_attachment_by_filename Whether or not to include filenames.
--                 --
--                 $this->allow_query_attachment_by_filename = apply_filters( 'wp_allow_query_attachment_by_filename', false );
--                 remove_all_filters( 'wp_allow_query_attachment_by_filename' );

--                 // Parse meta query.
--                 $this->meta_query = new WP_Meta_Query();
--                 $this->meta_query->parse_query_vars( $q );

--                 // Set a flag if a 'pre_get_posts' hook changed the query vars.
--                 $hash = md5( serialize( $this->query_vars ) );
--                 if ( $hash != $this->query_vars_hash ) then
--                         $this->query_vars_changed = true;
--                         $this->query_vars_hash    = $hash;
--                 end;
--                 unset( $hash );

--                 // First let's clear some variables.
--                 $distinct         = '';
--                 $whichauthor      = '';
--                 $whichmimetype    = '';
--                 $where            = '';
--                 $limits           = '';
--                 $join             = '';
--                 $search           = '';
--                 $groupby          = '';
--                 $post_status_join = false;
--                 $page             = 1;

--                 if ( isset( $q['caller_get_posts'] ) ) then
--                         _deprecated_argument(
--                                 'WP_Query',
--                                 '3.1.0',
--                                 sprintf(
--                                         /* translators: 1: caller_get_posts, 2: ignore_sticky_posts--
--                                         __( '%1$s is deprecated. Use %2$s instead.' ),
--                                         '<code>caller_get_posts</code>',
--                                         '<code>ignore_sticky_posts</code>'
--                                 )
--                         );

--                         if ( ! isset( $q['ignore_sticky_posts'] ) ) then
--                                 $q['ignore_sticky_posts'] = $q['caller_get_posts'];
--                         end;
--                 end;

--                 if ( ! isset( $q['ignore_sticky_posts'] ) ) then
--                         $q['ignore_sticky_posts'] = false;
--                 end;

--                 if ( ! isset( $q['suppress_filters'] ) ) then
--                         $q['suppress_filters'] = false;
--                 end;

--                 if ( ! isset( $q['cache_results'] ) ) then
--                         $q['cache_results'] = true;
--                 end;

--                 if ( ! isset( $q['update_post_term_cache'] ) ) then
--                         $q['update_post_term_cache'] = true;
--                 end;

--                 if ( ! isset( $q['update_menu_item_cache'] ) ) then
--                         $q['update_menu_item_cache'] = false;
--                 end;

--                 if ( ! isset( $q['lazy_load_term_meta'] ) ) then
--                         $q['lazy_load_term_meta'] = $q['update_post_term_cache'];
--                 end;

--                 if ( ! isset( $q['update_post_meta_cache'] ) ) then
--                         $q['update_post_meta_cache'] = true;
--                 end;

--                 if ( ! isset( $q['post_type'] ) ) then
--                         if ( $this->is_search ) then
--                                 $q['post_type'] = 'any';
--                         end; else then
--                                 $q['post_type'] = '';
--                         end;
--                 end;
--                 $post_type = $q['post_type'];
--                 if ( empty( $q['posts_per_page'] ) ) then
--                         $q['posts_per_page'] = get_option( 'posts_per_page' );
--                 end;
--                 if ( isset( $q['showposts'] ) && $q['showposts'] ) then
--                         $q['showposts']      = (int) $q['showposts'];
--                         $q['posts_per_page'] = $q['showposts'];
--                 end;
--                 if ( ( isset( $q['posts_per_archive_page'] ) && 0 != $q['posts_per_archive_page'] ) && ( $this->is_archive || $this->is_search ) ) then
--                         $q['posts_per_page'] = $q['posts_per_archive_page'];
--                 end;
--                 if ( ! isset( $q['nopaging'] ) ) then
--                         if ( -1 == $q['posts_per_page'] ) then
--                                 $q['nopaging'] = true;
--                         end; else then
--                                 $q['nopaging'] = false;
--                         end;
--                 end;

--                 if ( $this->is_feed ) then
--                         // This overrides 'posts_per_page'.
--                         if ( ! empty( $q['posts_per_rss'] ) ) then
--                                 $q['posts_per_page'] = $q['posts_per_rss'];
--                         end; else then
--                                 $q['posts_per_page'] = get_option( 'posts_per_rss' );
--                         end;
--                         $q['nopaging'] = false;
--                 end;
--                 $q['posts_per_page'] = (int) $q['posts_per_page'];
--                 if ( $q['posts_per_page'] < -1 ) then
--                         $q['posts_per_page'] = abs( $q['posts_per_page'] );
--                 end; elseif ( 0 == $q['posts_per_page'] ) then
--                         $q['posts_per_page'] = 1;
--                 end;

--                 if ( ! isset( $q['comments_per_page'] ) || 0 == $q['comments_per_page'] ) then
--                         $q['comments_per_page'] = get_option( 'comments_per_page' );
--                 end;

--                 if ( $this->is_home && ( empty( $this->query ) || 'true' === $q['preview'] ) && ( 'page' === get_option( 'show_on_front' ) ) && get_option( 'page_on_front' ) ) then
--                         $this->is_page = true;
--                         $this->is_home = false;
--                         $q['page_id']  = get_option( 'page_on_front' );
--                 end;

--                 if ( isset( $q['page'] ) ) then
--                         $q['page'] = trim( $q['page'], '/' );
--                         $q['page'] = absint( $q['page'] );
--                 end;

--                 // If true, forcibly turns off SQL_CALC_FOUND_ROWS even when limits are present.
--                 if ( isset( $q['no_found_rows'] ) ) then
--                         $q['no_found_rows'] = (bool) $q['no_found_rows'];
--                 end; else then
--                         $q['no_found_rows'] = false;
--                 end;

--                 switch ( $q['fields'] ) then
--                         case 'ids':
--                                 $fields = "then$wpdb->postsend;.ID";
--                                 break;
--                         case 'id=>parent':
--                                 $fields = "then$wpdb->postsend;.ID, then$wpdb->postsend;.post_parent";
--                                 break;
--                         default:
--                                 $fields = "then$wpdb->postsend;.*";
--                 end;

--                 if ( '' !== $q['menu_order'] ) then
--                         $where .= " AND then$wpdb->postsend;.menu_order = " . $q['menu_order'];
--                 end;
--                 // The "m" parameter is meant for months but accepts datetimes of varying specificity.
--                 if ( $q['m'] ) then
--                         $where .= " AND YEAR(then$wpdb->postsend;.post_date)=" . substr( $q['m'], 0, 4 );
--                         if ( strlen( $q['m'] ) > 5 ) then
--                                 $where .= " AND MONTH(then$wpdb->postsend;.post_date)=" . substr( $q['m'], 4, 2 );
--                         end;
--                         if ( strlen( $q['m'] ) > 7 ) then
--                                 $where .= " AND DAYOFMONTH(then$wpdb->postsend;.post_date)=" . substr( $q['m'], 6, 2 );
--                         end;
--                         if ( strlen( $q['m'] ) > 9 ) then
--                                 $where .= " AND HOUR(then$wpdb->postsend;.post_date)=" . substr( $q['m'], 8, 2 );
--                         end;
--                         if ( strlen( $q['m'] ) > 11 ) then
--                                 $where .= " AND MINUTE(then$wpdb->postsend;.post_date)=" . substr( $q['m'], 10, 2 );
--                         end;
--                         if ( strlen( $q['m'] ) > 13 ) then
--                                 $where .= " AND SECOND(then$wpdb->postsend;.post_date)=" . substr( $q['m'], 12, 2 );
--                         end;
--                 end;

--                 // Handle the other individual date parameters.
--                 $date_parameters = array();

--                 if ( '' !== $q['hour'] ) then
--                         $date_parameters['hour'] = $q['hour'];
--                 end;

--                 if ( '' !== $q['minute'] ) then
--                         $date_parameters['minute'] = $q['minute'];
--                 end;

--                 if ( '' !== $q['second'] ) then
--                         $date_parameters['second'] = $q['second'];
--                 end;

--                 if ( $q['year'] ) then
--                         $date_parameters['year'] = $q['year'];
--                 end;

--                 if ( $q['monthnum'] ) then
--                         $date_parameters['monthnum'] = $q['monthnum'];
--                 end;

--                 if ( $q['w'] ) then
--                         $date_parameters['week'] = $q['w'];
--                 end;

--                 if ( $q['day'] ) then
--                         $date_parameters['day'] = $q['day'];
--                 end;

--                 if ( $date_parameters ) then
--                         $date_query = new WP_Date_Query( array( $date_parameters ) );
--                         $where     .= $date_query->get_sql();
--                 end;
--                 unset( $date_parameters, $date_query );

--                 // Handle complex date queries.
--                 if ( ! empty( $q['date_query'] ) ) then
--                         $this->date_query = new WP_Date_Query( $q['date_query'] );
--                         $where           .= $this->date_query->get_sql();
--                 end;

--                 // If we've got a post_type AND it's not "any" post_type.
--                 if ( ! empty( $q['post_type'] ) && 'any' !== $q['post_type'] ) then
--                         foreach ( (array) $q['post_type'] as $_post_type ) then
--                                 $ptype_obj = get_post_type_object( $_post_type );
--                                 if ( ! $ptype_obj || ! $ptype_obj->query_var || empty( $q[ $ptype_obj->query_var ] ) ) then
--                                         continue;
--                                 end;

--                                 if ( ! $ptype_obj->hierarchical ) then
--                                         // Non-hierarchical post types can directly use 'name'.
--                                         $q['name'] = $q[ $ptype_obj->query_var ];
--                                 end; else then
--                                         // Hierarchical post types will operate through 'pagename'.
--                                         $q['pagename'] = $q[ $ptype_obj->query_var ];
--                                         $q['name']     = '';
--                                 end;

--                                 // Only one request for a slug is possible, this is why name & pagename are overwritten above.
--                                 break;
--                         end; // End foreach.
--                         unset( $ptype_obj );
--                 end;

--                 if ( '' !== $q['title'] ) then
--                         $where .= $wpdb->prepare( " AND then$wpdb->postsend;.post_title = %s", stripslashes( $q['title'] ) );
--                 end;

--                 // Parameters related to 'post_name'.
--                 if ( '' !== $q['name'] ) then
--                         $q['name'] = sanitize_title_for_query( $q['name'] );
--                         $where    .= " AND then$wpdb->postsend;.post_name = '" . $q['name'] . "'";
--                 end; elseif ( '' !== $q['pagename'] ) then
--                         if ( isset( $this->queried_object_id ) ) then
--                                 $reqpage = $this->queried_object_id;
--                         end; else then
--                                 if ( 'page' !== $q['post_type'] ) then
--                                         foreach ( (array) $q['post_type'] as $_post_type ) then
--                                                 $ptype_obj = get_post_type_object( $_post_type );
--                                                 if ( ! $ptype_obj || ! $ptype_obj->hierarchical ) then
--                                                         continue;
--                                                 end;

--                                                 $reqpage = get_page_by_path( $q['pagename'], OBJECT, $_post_type );
--                                                 if ( $reqpage ) then
--                                                         break;
--                                                 end;
--                                         end;
--                                         unset( $ptype_obj );
--                                 end; else then
--                                         $reqpage = get_page_by_path( $q['pagename'] );
--                                 end;
--                                 if ( ! empty( $reqpage ) ) then
--                                         $reqpage = $reqpage->ID;
--                                 end; else then
--                                         $reqpage = 0;
--                                 end;
--                         end;

--                         $page_for_posts = get_option( 'page_for_posts' );
--                         if ( ( 'page' !== get_option( 'show_on_front' ) ) || empty( $page_for_posts ) || ( $reqpage != $page_for_posts ) ) then
--                                 $q['pagename'] = sanitize_title_for_query( wp_basename( $q['pagename'] ) );
--                                 $q['name']     = $q['pagename'];
--                                 $where        .= " AND (then$wpdb->postsend;.ID = '$reqpage')";
--                                 $reqpage_obj   = get_post( $reqpage );
--                                 if ( is_object( $reqpage_obj ) && 'attachment' === $reqpage_obj->post_type ) then
--                                         $this->is_attachment = true;
--                                         $post_type           = 'attachment';
--                                         $q['post_type']      = 'attachment';
--                                         $this->is_page       = true;
--                                         $q['attachment_id']  = $reqpage;
--                                 end;
--                         end;
--                 end; elseif ( '' !== $q['attachment'] ) then
--                         $q['attachment'] = sanitize_title_for_query( wp_basename( $q['attachment'] ) );
--                         $q['name']       = $q['attachment'];
--                         $where          .= " AND then$wpdb->postsend;.post_name = '" . $q['attachment'] . "'";
--                 end; elseif ( is_array( $q['post_name__in'] ) && ! empty( $q['post_name__in'] ) ) then
--                         $q['post_name__in'] = array_map( 'sanitize_title_for_query', $q['post_name__in'] );
--                         $post_name__in      = "'" . implode( "','", $q['post_name__in'] ) . "'";
--                         $where             .= " AND then$wpdb->postsend;.post_name IN ($post_name__in)";
--                 end;

--                 // If an attachment is requested by number, let it supersede any post number.
--                 if ( $q['attachment_id'] ) then
--                         $q['p'] = absint( $q['attachment_id'] );
--                 end;

--                 // If a post number is specified, load that post.
--                 if ( $q['p'] ) then
--                         $where .= " AND then$wpdb->postsend;.ID = " . $q['p'];
--                 end; elseif ( $q['post__in'] ) then
--                         $post__in = implode( ',', array_map( 'absint', $q['post__in'] ) );
--                         $where   .= " AND then$wpdb->postsend;.ID IN ($post__in)";
--                 end; elseif ( $q['post__not_in'] ) then
--                         $post__not_in = implode( ',', array_map( 'absint', $q['post__not_in'] ) );
--                         $where       .= " AND then$wpdb->postsend;.ID NOT IN ($post__not_in)";
--                 end;

--                 if ( is_numeric( $q['post_parent'] ) ) then
--                         $where .= $wpdb->prepare( " AND then$wpdb->postsend;.post_parent = %d ", $q['post_parent'] );
--                 end; elseif ( $q['post_parent__in'] ) then
--                         $post_parent__in = implode( ',', array_map( 'absint', $q['post_parent__in'] ) );
--                         $where          .= " AND then$wpdb->postsend;.post_parent IN ($post_parent__in)";
--                 end; elseif ( $q['post_parent__not_in'] ) then
--                         $post_parent__not_in = implode( ',', array_map( 'absint', $q['post_parent__not_in'] ) );
--                         $where              .= " AND then$wpdb->postsend;.post_parent NOT IN ($post_parent__not_in)";
--                 end;

--                 if ( $q['page_id'] ) then
--                         if ( ( 'page' !== get_option( 'show_on_front' ) ) || ( get_option( 'page_for_posts' ) != $q['page_id'] ) ) then
--                                 $q['p'] = $q['page_id'];
--                                 $where  = " AND then$wpdb->postsend;.ID = " . $q['page_id'];
--                         end;
--                 end;

--                 // If a search pattern is specified, load the posts that match.
--                 if ( strlen( $q['s'] ) ) then
--                         $search = $this->parse_search( $q );
--                 end;

--                 if ( ! $q['suppress_filters'] ) then
--                         --
--                         -- Filters the search SQL that is used in the WHERE clause of WP_Query.
--                         --
--                         -- @since 3.0.0
--                         --
--                         -- @param string   $search Search SQL for WHERE clause.
--                         -- @param WP_Query $query  The current WP_Query object.
--                         --
--                         $search = apply_filters_ref_array( 'posts_search', array( $search, &$this ) );
--                 end;

--                 // Taxonomies.
--                 if ( ! $this->is_singular ) then
--                         $this->parse_tax_query( $q );

--                         $clauses = $this->tax_query->get_sql( $wpdb->posts, 'ID' );

--                         $join  .= $clauses['join'];
--                         $where .= $clauses['where'];
--                 end;

--                 if ( $this->is_tax ) then
--                         if ( empty( $post_type ) ) then
--                                 // Do a fully inclusive search for currently registered post types of queried taxonomies.
--                                 $post_type  = array();
--                                 $taxonomies = array_keys( $this->tax_query->queried_terms );
--                                 foreach ( get_post_types( array( 'exclude_from_search' => false ) ) as $pt ) then
--                                         $object_taxonomies = 'attachment' === $pt ? get_taxonomies_for_attachments() : get_object_taxonomies( $pt );
--                                         if ( array_intersect( $taxonomies, $object_taxonomies ) ) then
--                                                 $post_type[] = $pt;
--                                         end;
--                                 end;
--                                 if ( ! $post_type ) then
--                                         $post_type = 'any';
--                                 end; elseif ( count( $post_type ) == 1 ) then
--                                         $post_type = $post_type[0];
--                                 end;

--                                 $post_status_join = true;
--                         end; elseif ( in_array( 'attachment', (array) $post_type, true ) ) then
--                                 $post_status_join = true;
--                         end;
--                 end;

--                 /*
--                 -- Ensure that 'taxonomy', 'term', 'term_id', 'cat', and
--                 -- 'category_name' vars are set for backward compatibility.
--                 --
--                 if ( ! empty( $this->tax_query->queried_terms ) ) then

--                         /*
--                         -- Set 'taxonomy', 'term', and 'term_id' to the
--                         -- first taxonomy other than 'post_tag' or 'category'.
--                         --
--                         if ( ! isset( $q['taxonomy'] ) ) then
--                                 foreach ( $this->tax_query->queried_terms as $queried_taxonomy => $queried_items ) then
--                                         if ( empty( $queried_items['terms'][0] ) ) then
--                                                 continue;
--                                         end;

--                                         if ( ! in_array( $queried_taxonomy, array( 'category', 'post_tag' ), true ) ) then
--                                                 $q['taxonomy'] = $queried_taxonomy;

--                                                 if ( 'slug' === $queried_items['field'] ) then
--                                                         $q['term'] = $queried_items['terms'][0];
--                                                 end; else then
--                                                         $q['term_id'] = $queried_items['terms'][0];
--                                                 end;

--                                                 // Take the first one we find.
--                                                 break;
--                                         end;
--                                 end;
--                         end;

--                         // 'cat', 'category_name', 'tag_id'.
--                         foreach ( $this->tax_query->queried_terms as $queried_taxonomy => $queried_items ) then
--                                 if ( empty( $queried_items['terms'][0] ) ) then
--                                         continue;
--                                 end;

--                                 if ( 'category' === $queried_taxonomy ) then
--                                         $the_cat = get_term_by( $queried_items['field'], $queried_items['terms'][0], 'category' );
--                                         if ( $the_cat ) then
--                                                 $this->set( 'cat', $the_cat->term_id );
--                                                 $this->set( 'category_name', $the_cat->slug );
--                                         end;
--                                         unset( $the_cat );
--                                 end;

--                                 if ( 'post_tag' === $queried_taxonomy ) then
--                                         $the_tag = get_term_by( $queried_items['field'], $queried_items['terms'][0], 'post_tag' );
--                                         if ( $the_tag ) then
--                                                 $this->set( 'tag_id', $the_tag->term_id );
--                                         end;
--                                         unset( $the_tag );
--                                 end;
--                         end;
--                 end;

--                 if ( ! empty( $this->tax_query->queries ) || ! empty( $this->meta_query->queries ) || ! empty( $this->allow_query_attachment_by_filename ) ) then
--                         $groupby = "then$wpdb->postsend;.ID";
--                 end;

--                 // Author/user stuff.

--                 if ( ! empty( $q['author'] ) && '0' != $q['author'] ) then
--                         $q['author'] = addslashes_gpc( '' . urldecode( $q['author'] ) );
--                         $authors     = array_unique( array_map( 'intval', preg_split( '/[,\s]+/', $q['author'] ) ) );
--                         foreach ( $authors as $author ) then
--                                 $key         = $author > 0 ? 'author__in' : 'author__not_in';
--                                 $q[ $key ][] = abs( $author );
--                         end;
--                         $q['author'] = implode( ',', $authors );
--                 end;

--                 if ( ! empty( $q['author__not_in'] ) ) then
--                         $author__not_in = implode( ',', array_map( 'absint', array_unique( (array) $q['author__not_in'] ) ) );
--                         $where         .= " AND then$wpdb->postsend;.post_author NOT IN ($author__not_in) ";
--                 end; elseif ( ! empty( $q['author__in'] ) ) then
--                         $author__in = implode( ',', array_map( 'absint', array_unique( (array) $q['author__in'] ) ) );
--                         $where     .= " AND then$wpdb->postsend;.post_author IN ($author__in) ";
--                 end;

--                 // Author stuff for nice URLs.

--                 if ( '' !== $q['author_name'] ) then
--                         if ( strpos( $q['author_name'], '/' ) !== false ) then
--                                 $q['author_name'] = explode( '/', $q['author_name'] );
--                                 if ( $q['author_name'][ count( $q['author_name'] ) - 1 ] ) then
--                                         $q['author_name'] = $q['author_name'][ count( $q['author_name'] ) - 1 ]; // No trailing slash.
--                                 end; else then
--                                         $q['author_name'] = $q['author_name'][ count( $q['author_name'] ) - 2 ]; // There was a trailing slash.
--                                 end;
--                         end;
--                         $q['author_name'] = sanitize_title_for_query( $q['author_name'] );
--                         $q['author']      = get_user_by( 'slug', $q['author_name'] );
--                         if ( $q['author'] ) then
--                                 $q['author'] = $q['author']->ID;
--                         end;
--                         $whichauthor .= " AND (then$wpdb->postsend;.post_author = " . absint( $q['author'] ) . ')';
--                 end;

--                 // Matching by comment count.
--                 if ( isset( $q['comment_count'] ) ) then
--                         // Numeric comment count is converted to array format.
--                         if ( is_numeric( $q['comment_count'] ) ) then
--                                 $q['comment_count'] = array(
--                                         'value' => (int) $q['comment_count'],
--                                 );
--                         end;

--                         if ( isset( $q['comment_count']['value'] ) ) then
--                                 $q['comment_count'] = array_merge(
--                                         array(
--                                                 'compare' => '=',
--                                         ),
--                                         $q['comment_count']
--                                 );

--                                 // Fallback for invalid compare operators is '='.
--                                 $compare_operators = array( '=', '!=', '>', '>=', '<', '<=' );
--                                 if ( ! in_array( $q['comment_count']['compare'], $compare_operators, true ) ) then
--                                         $q['comment_count']['compare'] = '=';
--                                 end;

--                                 $where .= $wpdb->prepare( " AND then$wpdb->postsend;.comment_count then$q['comment_count']['compare']end; %d", $q['comment_count']['value'] );
--                         end;
--                 end;

--                 // MIME-Type stuff for attachment browsing.

--                 if ( isset( $q['post_mime_type'] ) && '' !== $q['post_mime_type'] ) then
--                         $whichmimetype = wp_post_mime_type_where( $q['post_mime_type'], $wpdb->posts );
--                 end;
--                 $where .= $search . $whichauthor . $whichmimetype;

--                 if ( ! empty( $this->allow_query_attachment_by_filename ) ) then
--                         $join .= " LEFT JOIN then$wpdb->postmetaend; AS sq1 ON ( then$wpdb->postsend;.ID = sq1.post_id AND sq1.meta_key = '_wp_attached_file' )";
--                 end;

--                 if ( ! empty( $this->meta_query->queries ) ) then
--                         $clauses = $this->meta_query->get_sql( 'post', $wpdb->posts, 'ID', $this );
--                         $join   .= $clauses['join'];
--                         $where  .= $clauses['where'];
--                 end;

--                 $rand = ( isset( $q['orderby'] ) && 'rand' === $q['orderby'] );
--                 if ( ! isset( $q['order'] ) ) then
--                         $q['order'] = $rand ? '' : 'DESC';
--                 end; else then
--                         $q['order'] = $rand ? '' : $this->parse_order( $q['order'] );
--                 end;

--                 // These values of orderby should ignore the 'order' parameter.
--                 $force_asc = array( 'post__in', 'post_name__in', 'post_parent__in' );
--                 if ( isset( $q['orderby'] ) && in_array( $q['orderby'], $force_asc, true ) ) then
--                         $q['order'] = '';
--                 end;

--                 // Order by.
--                 if ( empty( $q['orderby'] ) ) then
--                         /*
--                         -- Boolean false or empty array blanks out ORDER BY,
--                         -- while leaving the value unset or otherwise empty sets the default.
--                         --
--                         if ( isset( $q['orderby'] ) && ( is_array( $q['orderby'] ) || false === $q['orderby'] ) ) then
--                                 $orderby = '';
--                         end; else then
--                                 $orderby = "then$wpdb->postsend;.post_date " . $q['order'];
--                         end;
--                 end; elseif ( 'none' === $q['orderby'] ) then
--                         $orderby = '';
--                 end; else then
--                         $orderby_array = array();
--                         if ( is_array( $q['orderby'] ) ) then
--                                 foreach ( $q['orderby'] as $_orderby => $order ) then
--                                         $orderby = addslashes_gpc( urldecode( $_orderby ) );
--                                         $parsed  = $this->parse_orderby( $orderby );

--                                         if ( ! $parsed ) then
--                                                 continue;
--                                         end;

--                                         $orderby_array[] = $parsed . ' ' . $this->parse_order( $order );
--                                 end;
--                                 $orderby = implode( ', ', $orderby_array );

--                         end; else then
--                                 $q['orderby'] = urldecode( $q['orderby'] );
--                                 $q['orderby'] = addslashes_gpc( $q['orderby'] );

--                                 foreach ( explode( ' ', $q['orderby'] ) as $i => $orderby ) then
--                                         $parsed = $this->parse_orderby( $orderby );
--                                         // Only allow certain values for safety.
--                                         if ( ! $parsed ) then
--                                                 continue;
--                                         end;

--                                         $orderby_array[] = $parsed;
--                                 end;
--                                 $orderby = implode( ' ' . $q['order'] . ', ', $orderby_array );

--                                 if ( empty( $orderby ) ) then
--                                         $orderby = "then$wpdb->postsend;.post_date " . $q['order'];
--                                 end; elseif ( ! empty( $q['order'] ) ) then
--                                         $orderby .= " then$q['order']end;";
--                                 end;
--                         end;
--                 end;

--                 // Order search results by relevance only when another "orderby" is not specified in the query.
--                 if ( ! empty( $q['s'] ) ) then
--                         $search_orderby = '';
--                         if ( ! empty( $q['search_orderby_title'] ) && ( empty( $q['orderby'] ) && ! $this->is_feed ) || ( isset( $q['orderby'] ) && 'relevance' === $q['orderby'] ) ) then
--                                 $search_orderby = $this->parse_search_order( $q );
--                         end;

--                         if ( ! $q['suppress_filters'] ) then
--                                 --
--                                 -- Filters the ORDER BY used when ordering search results.
--                                 --
--                                 -- @since 3.7.0
--                                 --
--                                 -- @param string   $search_orderby The ORDER BY clause.
--                                 -- @param WP_Query $query          The current WP_Query instance.
--                                 --
--                                 $search_orderby = apply_filters( 'posts_search_orderby', $search_orderby, $this );
--                         end;

--                         if ( $search_orderby ) then
--                                 $orderby = $orderby ? $search_orderby . ', ' . $orderby : $search_orderby;
--                         end;
--                 end;

--                 if ( is_array( $post_type ) && count( $post_type ) > 1 ) then
--                         $post_type_cap = 'multiple_post_type';
--                 end; else then
--                         if ( is_array( $post_type ) ) then
--                                 $post_type = reset( $post_type );
--                         end;
--                         $post_type_object = get_post_type_object( $post_type );
--                         if ( empty( $post_type_object ) ) then
--                                 $post_type_cap = $post_type;
--                         end;
--                 end;

--                 if ( isset( $q['post_password'] ) ) then
--                         $where .= $wpdb->prepare( " AND then$wpdb->postsend;.post_password = %s", $q['post_password'] );
--                         if ( empty( $q['perm'] ) ) then
--                                 $q['perm'] = 'readable';
--                         end;
--                 end; elseif ( isset( $q['has_password'] ) ) then
--                         $where .= sprintf( " AND then$wpdb->postsend;.post_password %s ''", $q['has_password'] ? '!=' : '=' );
--                 end;

--                 if ( ! empty( $q['comment_status'] ) ) then
--                         $where .= $wpdb->prepare( " AND then$wpdb->postsend;.comment_status = %s ", $q['comment_status'] );
--                 end;

--                 if ( ! empty( $q['ping_status'] ) ) then
--                         $where .= $wpdb->prepare( " AND then$wpdb->postsend;.ping_status = %s ", $q['ping_status'] );
--                 end;

--                 $skip_post_status = false;
--                 if ( 'any' === $post_type ) then
--                         $in_search_post_types = get_post_types( array( 'exclude_from_search' => false ) );
--                         if ( empty( $in_search_post_types ) ) then
--                                 $post_type_where  = ' AND 1=0 ';
--                                 $skip_post_status = true;
--                         end; else then
--                                 $post_type_where = " AND then$wpdb->postsend;.post_type IN ('" . implode( "', '", array_map( 'esc_sql', $in_search_post_types ) ) . "')";
--                         end;
--                 end; elseif ( ! empty( $post_type ) && is_array( $post_type ) ) then
--                         $post_type_where = " AND then$wpdb->postsend;.post_type IN ('" . implode( "', '", esc_sql( $post_type ) ) . "')";
--                 end; elseif ( ! empty( $post_type ) ) then
--                         $post_type_where  = $wpdb->prepare( " AND then$wpdb->postsend;.post_type = %s", $post_type );
--                         $post_type_object = get_post_type_object( $post_type );
--                 end; elseif ( $this->is_attachment ) then
--                         $post_type_where  = " AND then$wpdb->postsend;.post_type = 'attachment'";
--                         $post_type_object = get_post_type_object( 'attachment' );
--                 end; elseif ( $this->is_page ) then
--                         $post_type_where  = " AND then$wpdb->postsend;.post_type = 'page'";
--                         $post_type_object = get_post_type_object( 'page' );
--                 end; else then
--                         $post_type_where  = " AND then$wpdb->postsend;.post_type = 'post'";
--                         $post_type_object = get_post_type_object( 'post' );
--                 end;

--                 $edit_cap = 'edit_post';
--                 $read_cap = 'read_post';

--                 if ( ! empty( $post_type_object ) ) then
--                         $edit_others_cap  = $post_type_object->cap->edit_others_posts;
--                         $read_private_cap = $post_type_object->cap->read_private_posts;
--                 end; else then
--                         $edit_others_cap  = 'edit_others_' . $post_type_cap . 's';
--                         $read_private_cap = 'read_private_' . $post_type_cap . 's';
--                 end;

--                 $user_id = get_current_user_id();

--                 $q_status = array();
--                 if ( $skip_post_status ) then
--                         $where .= $post_type_where;
--                 end; elseif ( ! empty( $q['post_status'] ) ) then

--                         $where .= $post_type_where;

--                         $statuswheres = array();
--                         $q_status     = $q['post_status'];
--                         if ( ! is_array( $q_status ) ) then
--                                 $q_status = explode( ',', $q_status );
--                         end;
--                         $r_status = array();
--                         $p_status = array();
--                         $e_status = array();
--                         if ( in_array( 'any', $q_status, true ) ) then
--                                 foreach ( get_post_stati( array( 'exclude_from_search' => true ) ) as $status ) then
--                                         if ( ! in_array( $status, $q_status, true ) ) then
--                                                 $e_status[] = "then$wpdb->postsend;.post_status <> '$status'";
--                                         end;
--                                 end;
--                         end; else then
--                                 foreach ( get_post_stati() as $status ) then
--                                         if ( in_array( $status, $q_status, true ) ) then
--                                                 if ( 'private' === $status ) then
--                                                         $p_status[] = "then$wpdb->postsend;.post_status = '$status'";
--                                                 end; else then
--                                                         $r_status[] = "then$wpdb->postsend;.post_status = '$status'";
--                                                 end;
--                                         end;
--                                 end;
--                         end;

--                         if ( empty( $q['perm'] ) || 'readable' !== $q['perm'] ) then
--                                 $r_status = array_merge( $r_status, $p_status );
--                                 unset( $p_status );
--                         end;

--                         if ( ! empty( $e_status ) ) then
--                                 $statuswheres[] = '(' . implode( ' AND ', $e_status ) . ')';
--                         end;
--                         if ( ! empty( $r_status ) ) then
--                                 if ( ! empty( $q['perm'] ) && 'editable' === $q['perm'] && ! current_user_can( $edit_others_cap ) ) then
--                                         $statuswheres[] = "(then$wpdb->postsend;.post_author = $user_id " . 'AND (' . implode( ' OR ', $r_status ) . '))';
--                                 end; else then
--                                         $statuswheres[] = '(' . implode( ' OR ', $r_status ) . ')';
--                                 end;
--                         end;
--                         if ( ! empty( $p_status ) ) then
--                                 if ( ! empty( $q['perm'] ) && 'readable' === $q['perm'] && ! current_user_can( $read_private_cap ) ) then
--                                         $statuswheres[] = "(then$wpdb->postsend;.post_author = $user_id " . 'AND (' . implode( ' OR ', $p_status ) . '))';
--                                 end; else then
--                                         $statuswheres[] = '(' . implode( ' OR ', $p_status ) . ')';
--                                 end;
--                         end;
--                         if ( $post_status_join ) then
--                                 $join .= " LEFT JOIN then$wpdb->postsend; AS p2 ON (then$wpdb->postsend;.post_parent = p2.ID) ";
--                                 foreach ( $statuswheres as $index => $statuswhere ) then
--                                         $statuswheres[ $index ] = "($statuswhere OR (then$wpdb->postsend;.post_status = 'inherit' AND " . str_replace( $wpdb->posts, 'p2', $statuswhere ) . '))';
--                                 end;
--                         end;
--                         $where_status = implode( ' OR ', $statuswheres );
--                         if ( ! empty( $where_status ) ) then
--                                 $where .= " AND ($where_status)";
--                         end;
--                 end; elseif ( ! $this->is_singular ) then
--                         if ( 'any' === $post_type ) then
--                                 $queried_post_types = get_post_types( array( 'exclude_from_search' => false ) );
--                         end; elseif ( is_array( $post_type ) ) then
--                                 $queried_post_types = $post_type;
--                         end; elseif ( ! empty( $post_type ) ) then
--                                 $queried_post_types = array( $post_type );
--                         end; else then
--                                 $queried_post_types = array( 'post' );
--                         end;

--                         if ( ! empty( $queried_post_types ) ) then

--                                 $status_type_clauses = array();

--                                 foreach ( $queried_post_types as $queried_post_type ) then

--                                         $queried_post_type_object = get_post_type_object( $queried_post_type );

--                                         $type_where = '(' . $wpdb->prepare( "then$wpdb->postsend;.post_type = %s AND (", $queried_post_type );

--                                         // Public statuses.
--                                         $public_statuses = get_post_stati( array( 'public' => true ) );
--                                         $status_clauses  = array();
--                                         foreach ( $public_statuses as $public_status ) then
--                                                 $status_clauses[] = "then$wpdb->postsend;.post_status = '$public_status'";
--                                         end;
--                                         $type_where .= implode( ' OR ', $status_clauses );

--                                         // Add protected states that should show in the admin all list.
--                                         if ( $this->is_admin ) then
--                                                 $admin_all_statuses = get_post_stati(
--                                                         array(
--                                                                 'protected'              => true,
--                                                                 'show_in_admin_all_list' => true,
--                                                         )
--                                                 );
--                                                 foreach ( $admin_all_statuses as $admin_all_status ) then
--                                                         $type_where .= " OR then$wpdb->postsend;.post_status = '$admin_all_status'";
--                                                 end;
--                                         end;

--                                         // Add private states that are visible to current user.
--                                         if ( is_user_logged_in() && $queried_post_type_object instanceof WP_Post_Type ) then
--                                                 $read_private_cap = $queried_post_type_object->cap->read_private_posts;
--                                                 $private_statuses = get_post_stati( array( 'private' => true ) );
--                                                 foreach ( $private_statuses as $private_status ) then
--                                                         $type_where .= current_user_can( $read_private_cap ) ? " \nOR then$wpdb->postsend;.post_status = '$private_status'" : " \nOR (then$wpdb->postsend;.post_author = $user_id AND then$wpdb->postsend;.post_status = '$private_status')";
--                                                 end;
--                                         end;

--                                         $type_where .= '))';

--                                         $status_type_clauses[] = $type_where;
--                                 end;

--                                 if ( ! empty( $status_type_clauses ) ) then
--                                         $where .= ' AND (' . implode( ' OR ', $status_type_clauses ) . ')';
--                                 end;
--                         end; else then
--                                 $where .= ' AND 1=0 ';
--                         end;
--                 end; else then
--                         $where .= $post_type_where;
--                 end;

--                 /*
--                 -- Apply filters on where and join prior to paging so that any
--                 -- manipulations to them are reflected in the paging by day queries.
--                 --
--                 if ( ! $q['suppress_filters'] ) then
--                         --
--                         -- Filters the WHERE clause of the query.
--                         --
--                         -- @since 1.5.0
--                         --
--                         -- @param string   $where The WHERE clause of the query.
--                         -- @param WP_Query $query The WP_Query instance (passed by reference).
--                         --
--                         $where = apply_filters_ref_array( 'posts_where', array( $where, &$this ) );

--                         --
--                         -- Filters the JOIN clause of the query.
--                         --
--                         -- @since 1.5.0
--                         --
--                         -- @param string   $join  The JOIN clause of the query.
--                         -- @param WP_Query $query The WP_Query instance (passed by reference).
--                         --
--                         $join = apply_filters_ref_array( 'posts_join', array( $join, &$this ) );
--                 end;

--                 // Paging.
--                 if ( empty( $q['nopaging'] ) && ! $this->is_singular ) then
--                         $page = absint( $q['paged'] );
--                         if ( ! $page ) then
--                                 $page = 1;
--                         end;

--                         // If 'offset' is provided, it takes precedence over 'paged'.
--                         if ( isset( $q['offset'] ) && is_numeric( $q['offset'] ) ) then
--                                 $q['offset'] = absint( $q['offset'] );
--                                 $pgstrt      = $q['offset'] . ', ';
--                         end; else then
--                                 $pgstrt = absint( ( $page - 1 )-- $q['posts_per_page'] ) . ', ';
--                         end;
--                         $limits = 'LIMIT ' . $pgstrt . $q['posts_per_page'];
--                 end;

--                 // Comments feeds.
--                 if ( $this->is_comment_feed && ! $this->is_singular ) then
--                         if ( $this->is_archive || $this->is_search ) then
--                                 $cjoin    = "JOIN then$wpdb->postsend; ON ( then$wpdb->commentsend;.comment_post_ID = then$wpdb->postsend;.ID ) $join ";
--                                 $cwhere   = "WHERE comment_approved = '1' $where";
--                                 $cgroupby = "then$wpdb->commentsend;.comment_id";
--                         end; else then // Other non-singular, e.g. front.
--                                 $cjoin    = "JOIN then$wpdb->postsend; ON ( then$wpdb->commentsend;.comment_post_ID = then$wpdb->postsend;.ID )";
--                                 $cwhere   = "WHERE ( post_status = 'publish' OR ( post_status = 'inherit' AND post_type = 'attachment' ) ) AND comment_approved = '1'";
--                                 $cgroupby = '';
--                         end;

--                         if ( ! $q['suppress_filters'] ) then
--                                 --
--                                 -- Filters the JOIN clause of the comments feed query before sending.
--                                 --
--                                 -- @since 2.2.0
--                                 --
--                                 -- @param string   $cjoin The JOIN clause of the query.
--                                 -- @param WP_Query $query The WP_Query instance (passed by reference).
--                                 --
--                                 $cjoin = apply_filters_ref_array( 'comment_feed_join', array( $cjoin, &$this ) );

--                                 --
--                                 -- Filters the WHERE clause of the comments feed query before sending.
--                                 --
--                                 -- @since 2.2.0
--                                 --
--                                 -- @param string   $cwhere The WHERE clause of the query.
--                                 -- @param WP_Query $query  The WP_Query instance (passed by reference).
--                                 --
--                                 $cwhere = apply_filters_ref_array( 'comment_feed_where', array( $cwhere, &$this ) );

--                                 --
--                                 -- Filters the GROUP BY clause of the comments feed query before sending.
--                                 --
--                                 -- @since 2.2.0
--                                 --
--                                 -- @param string   $cgroupby The GROUP BY clause of the query.
--                                 -- @param WP_Query $query    The WP_Query instance (passed by reference).
--                                 --
--                                 $cgroupby = apply_filters_ref_array( 'comment_feed_groupby', array( $cgroupby, &$this ) );

--                                 --
--                                 -- Filters the ORDER BY clause of the comments feed query before sending.
--                                 --
--                                 -- @since 2.8.0
--                                 --
--                                 -- @param string   $corderby The ORDER BY clause of the query.
--                                 -- @param WP_Query $query    The WP_Query instance (passed by reference).
--                                 --
--                                 $corderby = apply_filters_ref_array( 'comment_feed_orderby', array( 'comment_date_gmt DESC', &$this ) );

--                                 --
--                                 -- Filters the LIMIT clause of the comments feed query before sending.
--                                 --
--                                 -- @since 2.8.0
--                                 --
--                                 -- @param string   $climits The JOIN clause of the query.
--                                 -- @param WP_Query $query   The WP_Query instance (passed by reference).
--                                 --
--                                 $climits = apply_filters_ref_array( 'comment_feed_limits', array( 'LIMIT ' . get_option( 'posts_per_rss' ), &$this ) );
--                         end;

--                         $cgroupby = ( ! empty( $cgroupby ) ) ? 'GROUP BY ' . $cgroupby : '';
--                         $corderby = ( ! empty( $corderby ) ) ? 'ORDER BY ' . $corderby : '';
--                         $climits  = ( ! empty( $climits ) ) ? $climits : '';

--                         $comments_request = "SELECT $distinct then$wpdb->commentsend;.comment_ID FROM then$wpdb->commentsend; $cjoin $cwhere $cgroupby $corderby $climits";

--                         $key          = md5( $comments_request );
--                         $last_changed = wp_cache_get_last_changed( 'comment' ) . ':' . wp_cache_get_last_changed( 'posts' );

--                         $cache_key   = "comment_feed:$key:$last_changed";
--                         $comment_ids = wp_cache_get( $cache_key, 'comment' );
--                         if ( false === $comment_ids ) then
--                                 $comment_ids = $wpdb->get_col( $comments_request );
--                                 wp_cache_add( $cache_key, $comment_ids, 'comment' );
--                         end;
--                         _prime_comment_caches( $comment_ids, false );

--                         // Convert to WP_Comment.
--                         -- @var WP_Comment[]--
--                         $this->comments      = array_map( 'get_comment', $comment_ids );
--                         $this->comment_count = count( $this->comments );

--                         $post_ids = array();

--                         foreach ( $this->comments as $comment ) then
--                                 $post_ids[] = (int) $comment->comment_post_ID;
--                         end;

--                         $post_ids = implode( ',', $post_ids );
--                         $join     = '';
--                         if ( $post_ids ) then
--                                 $where = "AND then$wpdb->postsend;.ID IN ($post_ids) ";
--                         end; else then
--                                 $where = 'AND 0';
--                         end;
--                 end;

--                 $pieces = array( 'where', 'groupby', 'join', 'orderby', 'distinct', 'fields', 'limits' );

--                 /*
--                 -- Apply post-paging filters on where and join. Only plugins that
--                 -- manipulate paging queries should use these hooks.
--                 --
--                 if ( ! $q['suppress_filters'] ) then
--                         --
--                         -- Filters the WHERE clause of the query.
--                         --
--                         -- Specifically for manipulating paging queries.
--                         --
--                         -- @since 1.5.0
--                         --
--                         -- @param string   $where The WHERE clause of the query.
--                         -- @param WP_Query $query The WP_Query instance (passed by reference).
--                         --
--                         $where = apply_filters_ref_array( 'posts_where_paged', array( $where, &$this ) );

--                         --
--                         -- Filters the GROUP BY clause of the query.
--                         --
--                         -- @since 2.0.0
--                         --
--                         -- @param string   $groupby The GROUP BY clause of the query.
--                         -- @param WP_Query $query   The WP_Query instance (passed by reference).
--                         --
--                         $groupby = apply_filters_ref_array( 'posts_groupby', array( $groupby, &$this ) );

--                         --
--                         -- Filters the JOIN clause of the query.
--                         --
--                         -- Specifically for manipulating paging queries.
--                         --
--                         -- @since 1.5.0
--                         --
--                         -- @param string   $join  The JOIN clause of the query.
--                         -- @param WP_Query $query The WP_Query instance (passed by reference).
--                         --
--                         $join = apply_filters_ref_array( 'posts_join_paged', array( $join, &$this ) );

--                         --
--                         -- Filters the ORDER BY clause of the query.
--                         --
--                         -- @since 1.5.1
--                         --
--                         -- @param string   $orderby The ORDER BY clause of the query.
--                         -- @param WP_Query $query   The WP_Query instance (passed by reference).
--                         --
--                         $orderby = apply_filters_ref_array( 'posts_orderby', array( $orderby, &$this ) );

--                         --
--                         -- Filters the DISTINCT clause of the query.
--                         --
--                         -- @since 2.1.0
--                         --
--                         -- @param string   $distinct The DISTINCT clause of the query.
--                         -- @param WP_Query $query    The WP_Query instance (passed by reference).
--                         --
--                         $distinct = apply_filters_ref_array( 'posts_distinct', array( $distinct, &$this ) );

--                         --
--                         -- Filters the LIMIT clause of the query.
--                         --
--                         -- @since 2.1.0
--                         --
--                         -- @param string   $limits The LIMIT clause of the query.
--                         -- @param WP_Query $query  The WP_Query instance (passed by reference).
--                         --
--                         $limits = apply_filters_ref_array( 'post_limits', array( $limits, &$this ) );

--                         --
--                         -- Filters the SELECT clause of the query.
--                         --
--                         -- @since 2.1.0
--                         --
--                         -- @param string   $fields The SELECT clause of the query.
--                         -- @param WP_Query $query  The WP_Query instance (passed by reference).
--                         --
--                         $fields = apply_filters_ref_array( 'posts_fields', array( $fields, &$this ) );

--                         --
--                         -- Filters all query clauses at once, for convenience.
--                         --
--                         -- Covers the WHERE, GROUP BY, JOIN, ORDER BY, DISTINCT,
--                         -- fields (SELECT), and LIMIT clauses.
--                         --
--                         -- @since 3.1.0
--                         --
--                         -- @param string[] $clauses then
--                         --     Associative array of the clauses for the query.
--                         --
--                         --     @type string $where    The WHERE clause of the query.
--                         --     @type string $groupby  The GROUP BY clause of the query.
--                         --     @type string $join     The JOIN clause of the query.
--                         --     @type string $orderby  The ORDER BY clause of the query.
--                         --     @type string $distinct The DISTINCT clause of the query.
--                         --     @type string $fields   The SELECT clause of the query.
--                         --     @type string $limits   The LIMIT clause of the query.
--                         -- end;
--                         -- @param WP_Query $query   The WP_Query instance (passed by reference).
--                         --
--                         $clauses = (array) apply_filters_ref_array( 'posts_clauses', array( compact( $pieces ), &$this ) );

--                         $where    = isset( $clauses['where'] ) ? $clauses['where'] : '';
--                         $groupby  = isset( $clauses['groupby'] ) ? $clauses['groupby'] : '';
--                         $join     = isset( $clauses['join'] ) ? $clauses['join'] : '';
--                         $orderby  = isset( $clauses['orderby'] ) ? $clauses['orderby'] : '';
--                         $distinct = isset( $clauses['distinct'] ) ? $clauses['distinct'] : '';
--                         $fields   = isset( $clauses['fields'] ) ? $clauses['fields'] : '';
--                         $limits   = isset( $clauses['limits'] ) ? $clauses['limits'] : '';
--                 end;

--                 --
--                 -- Fires to announce the query's current selection parameters.
--                 --
--                 -- For use by caching plugins.
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @param string $selection The assembled selection query.
--                 --
--                 do_action( 'posts_selection', $where . $groupby . $orderby . $limits . $join );

--                 /*
--                 -- Filters again for the benefit of caching plugins.
--                 -- Regular plugins should use the hooks above.
--                 --
--                 if ( ! $q['suppress_filters'] ) then
--                         --
--                         -- Filters the WHERE clause of the query.
--                         --
--                         -- For use by caching plugins.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string   $where The WHERE clause of the query.
--                         -- @param WP_Query $query The WP_Query instance (passed by reference).
--                         --
--                         $where = apply_filters_ref_array( 'posts_where_request', array( $where, &$this ) );

--                         --
--                         -- Filters the GROUP BY clause of the query.
--                         --
--                         -- For use by caching plugins.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string   $groupby The GROUP BY clause of the query.
--                         -- @param WP_Query $query   The WP_Query instance (passed by reference).
--                         --
--                         $groupby = apply_filters_ref_array( 'posts_groupby_request', array( $groupby, &$this ) );

--                         --
--                         -- Filters the JOIN clause of the query.
--                         --
--                         -- For use by caching plugins.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string   $join  The JOIN clause of the query.
--                         -- @param WP_Query $query The WP_Query instance (passed by reference).
--                         --
--                         $join = apply_filters_ref_array( 'posts_join_request', array( $join, &$this ) );

--                         --
--                         -- Filters the ORDER BY clause of the query.
--                         --
--                         -- For use by caching plugins.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string   $orderby The ORDER BY clause of the query.
--                         -- @param WP_Query $query   The WP_Query instance (passed by reference).
--                         --
--                         $orderby = apply_filters_ref_array( 'posts_orderby_request', array( $orderby, &$this ) );

--                         --
--                         -- Filters the DISTINCT clause of the query.
--                         --
--                         -- For use by caching plugins.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string   $distinct The DISTINCT clause of the query.
--                         -- @param WP_Query $query    The WP_Query instance (passed by reference).
--                         --
--                         $distinct = apply_filters_ref_array( 'posts_distinct_request', array( $distinct, &$this ) );

--                         --
--                         -- Filters the SELECT clause of the query.
--                         --
--                         -- For use by caching plugins.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string   $fields The SELECT clause of the query.
--                         -- @param WP_Query $query  The WP_Query instance (passed by reference).
--                         --
--                         $fields = apply_filters_ref_array( 'posts_fields_request', array( $fields, &$this ) );

--                         --
--                         -- Filters the LIMIT clause of the query.
--                         --
--                         -- For use by caching plugins.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string   $limits The LIMIT clause of the query.
--                         -- @param WP_Query $query  The WP_Query instance (passed by reference).
--                         --
--                         $limits = apply_filters_ref_array( 'post_limits_request', array( $limits, &$this ) );

--                         --
--                         -- Filters all query clauses at once, for convenience.
--                         --
--                         -- For use by caching plugins.
--                         --
--                         -- Covers the WHERE, GROUP BY, JOIN, ORDER BY, DISTINCT,
--                         -- fields (SELECT), and LIMIT clauses.
--                         --
--                         -- @since 3.1.0
--                         --
--                         -- @param string[] $clauses then
--                         --     Associative array of the clauses for the query.
--                         --
--                         --     @type string $where    The WHERE clause of the query.
--                         --     @type string $groupby  The GROUP BY clause of the query.
--                         --     @type string $join     The JOIN clause of the query.
--                         --     @type string $orderby  The ORDER BY clause of the query.
--                         --     @type string $distinct The DISTINCT clause of the query.
--                         --     @type string $fields   The SELECT clause of the query.
--                         --     @type string $limits   The LIMIT clause of the query.
--                         -- end;
--                         -- @param WP_Query $query  The WP_Query instance (passed by reference).
--                         --
--                         $clauses = (array) apply_filters_ref_array( 'posts_clauses_request', array( compact( $pieces ), &$this ) );

--                         $where    = isset( $clauses['where'] ) ? $clauses['where'] : '';
--                         $groupby  = isset( $clauses['groupby'] ) ? $clauses['groupby'] : '';
--                         $join     = isset( $clauses['join'] ) ? $clauses['join'] : '';
--                         $orderby  = isset( $clauses['orderby'] ) ? $clauses['orderby'] : '';
--                         $distinct = isset( $clauses['distinct'] ) ? $clauses['distinct'] : '';
--                         $fields   = isset( $clauses['fields'] ) ? $clauses['fields'] : '';
--                         $limits   = isset( $clauses['limits'] ) ? $clauses['limits'] : '';
--                 end;

--                 if ( ! empty( $groupby ) ) then
--                         $groupby = 'GROUP BY ' . $groupby;
--                 end;
--                 if ( ! empty( $orderby ) ) then
--                         $orderby = 'ORDER BY ' . $orderby;
--                 end;

--                 $found_rows = '';
--                 if ( ! $q['no_found_rows'] && ! empty( $limits ) ) then
--                         $found_rows = 'SQL_CALC_FOUND_ROWS';
--                 end;

--                 $old_request = "
--                         SELECT $found_rows $distinct $fields
--                         FROM then$wpdb->postsend; $join
--                         WHERE 1=1 $where
--                         $groupby
--                         $orderby
--                         $limits
--                 ";

--                 $this->request = $old_request;

--                 if ( ! $q['suppress_filters'] ) then
--                         --
--                         -- Filters the completed SQL query before sending.
--                         --
--                         -- @since 2.0.0
--                         --
--                         -- @param string   $request The complete SQL query.
--                         -- @param WP_Query $query   The WP_Query instance (passed by reference).
--                         --
--                         $this->request = apply_filters_ref_array( 'posts_request', array( $this->request, &$this ) );
--                 end;

--                 --
--                 -- Filters the posts array before the query takes place.
--                 --
--                 -- Return a non-null value to bypass WordPress' default post queries.
--                 --
--                 -- Filtering functions that require pagination information are encouraged to set
--                 -- the `found_posts` and `max_num_pages` properties of the WP_Query object,
--                 -- passed to the filter by reference. If WP_Query does not perform a database
--                 -- query, it will not have enough information to generate these values itself.
--                 --
--                 -- @since 4.6.0
--                 --
--                 -- @param WP_Post[]|int[]|null $posts Return an array of post data to short-circuit WP's query,
--                 --                                    or null to allow WP to run its normal queries.
--                 -- @param WP_Query             $query The WP_Query instance (passed by reference).
--                 --
--                 $this->posts = apply_filters_ref_array( 'posts_pre_query', array( null, &$this ) );

--                 /*
--                 -- Ensure the ID database query is able to be cached.
--                 --
--                 -- Random queries are expected to have unpredictable results and
--                 -- cannot be cached. Note the space before `RAND` in the string
--                 -- search, that to ensure against a collision with another
--                 -- function.
--                 --
--                 -- If `$fields` has been modified by the `posts_fields`,
--                 -- `posts_fields_request`, `post_clauses` or `posts_clauses_request`
--                 -- filters, then caching is disabled to prevent caching collisions.
--                 --
--                 $id_query_is_cacheable = ! str_contains( strtoupper( $orderby ), ' RAND(' );

--                 $cacheable_field_values = array(
--                         "then$wpdb->postsend;.*",
--                         "then$wpdb->postsend;.ID, then$wpdb->postsend;.post_parent",
--                         "then$wpdb->postsend;.ID",
--                 );

--                 if ( ! in_array( $fields, $cacheable_field_values, true ) ) then
--                         $id_query_is_cacheable = false;
--                 end;

--                 if ( $q['cache_results'] && $id_query_is_cacheable ) then
--                         $new_request = str_replace( $fields, "then$wpdb->postsend;.*", $this->request );
--                         $cache_key   = $this->generate_cache_key( $q, $new_request );

--                         $cache_found = false;
--                         if ( null === $this->posts ) then
--                                 $cached_results = wp_cache_get( $cache_key, 'posts', false, $cache_found );

--                                 if ( $cached_results ) then
--                                         if ( 'ids' === $q['fields'] ) then
--                                                 -- @var int[]--
--                                                 $this->posts = array_map( 'intval', $cached_results['posts'] );
--                                         end; else then
--                                                 _prime_post_caches( $cached_results['posts'], $q['update_post_term_cache'], $q['update_post_meta_cache'] );
--                                                 -- @var WP_Post[]--
--                                                 $this->posts = array_map( 'get_post', $cached_results['posts'] );
--                                         end;

--                                         $this->post_count    = count( $this->posts );
--                                         $this->found_posts   = $cached_results['found_posts'];
--                                         $this->max_num_pages = $cached_results['max_num_pages'];

--                                         if ( 'ids' === $q['fields'] ) then
--                                                 return $this->posts;
--                                         end; elseif ( 'id=>parent' === $q['fields'] ) then
--                                                 -- @var int[]--
--                                                 $post_parents = array();

--                                                 foreach ( $this->posts as $key => $post ) then
--                                                         $obj              = new stdClass();
--                                                         $obj->ID          = (int) $post->ID;
--                                                         $obj->post_parent = (int) $post->post_parent;

--                                                         $this->posts[ $key ] = $obj;

--                                                         $post_parents[ $obj->ID ] = $obj->post_parent;
--                                                 end;

--                                                 return $post_parents;
--                                         end;
--                                 end;
--                         end;
--                 end;

--                 if ( 'ids' === $q['fields'] ) then
--                         if ( null === $this->posts ) then
--                                 $this->posts = $wpdb->get_col( $this->request );
--                         end;

--                         -- @var int[]--
--                         $this->posts      = array_map( 'intval', $this->posts );
--                         $this->post_count = count( $this->posts );
--                         $this->set_found_posts( $q, $limits );

--                         if ( $q['cache_results'] && $id_query_is_cacheable ) then
--                                 $cache_value = array(
--                                         'posts'         => $this->posts,
--                                         'found_posts'   => $this->found_posts,
--                                         'max_num_pages' => $this->max_num_pages,
--                                 );

--                                 wp_cache_set( $cache_key, $cache_value, 'posts' );
--                         end;

--                         return $this->posts;
--                 end;

--                 if ( 'id=>parent' === $q['fields'] ) then
--                         if ( null === $this->posts ) then
--                                 $this->posts = $wpdb->get_results( $this->request );
--                         end;

--                         $this->post_count = count( $this->posts );
--                         $this->set_found_posts( $q, $limits );

--                         -- @var int[]--
--                         $post_parents = array();
--                         $post_ids     = array();

--                         foreach ( $this->posts as $key => $post ) then
--                                 $this->posts[ $key ]->ID          = (int) $post->ID;
--                                 $this->posts[ $key ]->post_parent = (int) $post->post_parent;

--                                 $post_parents[ (int) $post->ID ] = (int) $post->post_parent;
--                                 $post_ids[]                      = (int) $post->ID;
--                         end;

--                         if ( $q['cache_results'] && $id_query_is_cacheable ) then
--                                 $cache_value = array(
--                                         'posts'         => $post_ids,
--                                         'found_posts'   => $this->found_posts,
--                                         'max_num_pages' => $this->max_num_pages,
--                                 );

--                                 wp_cache_set( $cache_key, $cache_value, 'posts' );
--                         end;

--                         return $post_parents;
--                 end;

--                 if ( null === $this->posts ) then
--                         $split_the_query = ( $old_request == $this->request && "then$wpdb->postsend;.*" === $fields && ! empty( $limits ) && $q['posts_per_page'] < 500 );

--                         --
--                         -- Filters whether to split the query.
--                         --
--                         -- Splitting the query will cause it to fetch just the IDs of the found posts
--                         -- (and then individually fetch each post by ID), rather than fetching every
--                         -- complete row at once. One massive result vs. many small results.
--                         --
--                         -- @since 3.4.0
--                         --
--                         -- @param bool     $split_the_query Whether or not to split the query.
--                         -- @param WP_Query $query           The WP_Query instance.
--                         --
--                         $split_the_query = apply_filters( 'split_the_query', $split_the_query, $this );

--                         if ( $split_the_query ) then
--                                 // First get the IDs and then fill in the objects.

--                                 $this->request = "
--                                         SELECT $found_rows $distinct then$wpdb->postsend;.ID
--                                         FROM then$wpdb->postsend; $join
--                                         WHERE 1=1 $where
--                                         $groupby
--                                         $orderby
--                                         $limits
--                                 ";

--                                 --
--                                 -- Filters the Post IDs SQL request before sending.
--                                 --
--                                 -- @since 3.4.0
--                                 --
--                                 -- @param string   $request The post ID request.
--                                 -- @param WP_Query $query   The WP_Query instance.
--                                 --
--                                 $this->request = apply_filters( 'posts_request_ids', $this->request, $this );

--                                 $post_ids = $wpdb->get_col( $this->request );

--                                 if ( $post_ids ) then
--                                         $this->posts = $post_ids;
--                                         $this->set_found_posts( $q, $limits );
--                                         _prime_post_caches( $post_ids, $q['update_post_term_cache'], $q['update_post_meta_cache'] );
--                                 end; else then
--                                         $this->posts = array();
--                                 end;
--                         end; else then
--                                 $this->posts = $wpdb->get_results( $this->request );
--                                 $this->set_found_posts( $q, $limits );
--                         end;
--                 end;

--                 // Convert to WP_Post objects.
--                 if ( $this->posts ) then
--                         -- @var WP_Post[]--
--                         $this->posts = array_map( 'get_post', $this->posts );
--                 end;

--                 if ( $q['cache_results'] && $id_query_is_cacheable && ! $cache_found ) then
--                         $post_ids = wp_list_pluck( $this->posts, 'ID' );

--                         $cache_value = array(
--                                 'posts'         => $post_ids,
--                                 'found_posts'   => $this->found_posts,
--                                 'max_num_pages' => $this->max_num_pages,
--                         );

--                         wp_cache_set( $cache_key, $cache_value, 'posts' );
--                 end;

--                 if ( ! $q['suppress_filters'] ) then
--                         --
--                         -- Filters the raw post results array, prior to status checks.
--                         --
--                         -- @since 2.3.0
--                         --
--                         -- @param WP_Post[] $posts Array of post objects.
--                         -- @param WP_Query  $query The WP_Query instance (passed by reference).
--                         --
--                         $this->posts = apply_filters_ref_array( 'posts_results', array( $this->posts, &$this ) );
--                 end;

--                 if ( ! empty( $this->posts ) && $this->is_comment_feed && $this->is_singular ) then
--                         -- This filter is documented in wp-includes/query.php--
--                         $cjoin = apply_filters_ref_array( 'comment_feed_join', array( '', &$this ) );

--                         -- This filter is documented in wp-includes/query.php--
--                         $cwhere = apply_filters_ref_array( 'comment_feed_where', array( "WHERE comment_post_ID = 'then$this->posts[0]->IDend;' AND comment_approved = '1'", &$this ) );

--                         -- This filter is documented in wp-includes/query.php--
--                         $cgroupby = apply_filters_ref_array( 'comment_feed_groupby', array( '', &$this ) );
--                         $cgroupby = ( ! empty( $cgroupby ) ) ? 'GROUP BY ' . $cgroupby : '';

--                         -- This filter is documented in wp-includes/query.php--
--                         $corderby = apply_filters_ref_array( 'comment_feed_orderby', array( 'comment_date_gmt DESC', &$this ) );
--                         $corderby = ( ! empty( $corderby ) ) ? 'ORDER BY ' . $corderby : '';

--                         -- This filter is documented in wp-includes/query.php--
--                         $climits = apply_filters_ref_array( 'comment_feed_limits', array( 'LIMIT ' . get_option( 'posts_per_rss' ), &$this ) );

--                         $comments_request = "SELECT then$wpdb->commentsend;.comment_ID FROM then$wpdb->commentsend; $cjoin $cwhere $cgroupby $corderby $climits";

--                         $comment_key          = md5( $comments_request );
--                         $comment_last_changed = wp_cache_get_last_changed( 'comment' );

--                         $comment_cache_key = "comment_feed:$comment_key:$comment_last_changed";
--                         $comment_ids       = wp_cache_get( $comment_cache_key, 'comment' );
--                         if ( false === $comment_ids ) then
--                                 $comment_ids = $wpdb->get_col( $comments_request );
--                                 wp_cache_add( $comment_cache_key, $comment_ids, 'comment' );
--                         end;
--                         _prime_comment_caches( $comment_ids, false );

--                         // Convert to WP_Comment.
--                         -- @var WP_Comment[]--
--                         $this->comments      = array_map( 'get_comment', $comment_ids );
--                         $this->comment_count = count( $this->comments );
--                 end;

--                 // Check post status to determine if post should be displayed.
--                 if ( ! empty( $this->posts ) && ( $this->is_single || $this->is_page ) ) then
--                         $status = get_post_status( $this->posts[0] );

--                         if ( 'attachment' === $this->posts[0]->post_type && 0 === (int) $this->posts[0]->post_parent ) then
--                                 $this->is_page       = false;
--                                 $this->is_single     = true;
--                                 $this->is_attachment = true;
--                         end;

--                         // If the post_status was specifically requested, let it pass through.
--                         if ( ! in_array( $status, $q_status, true ) ) then
--                                 $post_status_obj = get_post_status_object( $status );

--                                 if ( $post_status_obj && ! $post_status_obj->public ) then
--                                         if ( ! is_user_logged_in() ) then
--                                                 // User must be logged in to view unpublished posts.
--                                                 $this->posts = array();
--                                         end; else then
--                                                 if ( $post_status_obj->protected ) then
--                                                         // User must have edit permissions on the draft to preview.
--                                                         if ( ! current_user_can( $edit_cap, $this->posts[0]->ID ) ) then
--                                                                 $this->posts = array();
--                                                         end; else then
--                                                                 $this->is_preview = true;
--                                                                 if ( 'future' !== $status ) then
--                                                                         $this->posts[0]->post_date = current_time( 'mysql' );
--                                                                 end;
--                                                         end;
--                                                 end; elseif ( $post_status_obj->private ) then
--                                                         if ( ! current_user_can( $read_cap, $this->posts[0]->ID ) ) then
--                                                                 $this->posts = array();
--                                                         end;
--                                                 end; else then
--                                                         $this->posts = array();
--                                                 end;
--                                         end;
--                                 end; elseif ( ! $post_status_obj ) then
--                                         // Post status is not registered, assume it's not public.
--                                         if ( ! current_user_can( $edit_cap, $this->posts[0]->ID ) ) then
--                                                 $this->posts = array();
--                                         end;
--                                 end;
--                         end;

--                         if ( $this->is_preview && $this->posts && current_user_can( $edit_cap, $this->posts[0]->ID ) ) then
--                                 --
--                                 -- Filters the single post for preview mode.
--                                 --
--                                 -- @since 2.7.0
--                                 --
--                                 -- @param WP_Post  $post_preview  The Post object.
--                                 -- @param WP_Query $query         The WP_Query instance (passed by reference).
--                                 --
--                                 $this->posts[0] = get_post( apply_filters_ref_array( 'the_preview', array( $this->posts[0], &$this ) ) );
--                         end;
--                 end;

--                 // Put sticky posts at the top of the posts array.
--                 $sticky_posts = get_option( 'sticky_posts' );
--                 if ( $this->is_home && $page <= 1 && is_array( $sticky_posts ) && ! empty( $sticky_posts ) && ! $q['ignore_sticky_posts'] ) then
--                         $num_posts     = count( $this->posts );
--                         $sticky_offset = 0;
--                         // Loop over posts and relocate stickies to the front.
--                         for ( $i = 0; $i < $num_posts; $i++ ) then
--                                 if ( in_array( $this->posts[ $i ]->ID, $sticky_posts, true ) ) then
--                                         $sticky_post = $this->posts[ $i ];
--                                         // Remove sticky from current position.
--                                         array_splice( $this->posts, $i, 1 );
--                                         // Move to front, after other stickies.
--                                         array_splice( $this->posts, $sticky_offset, 0, array( $sticky_post ) );
--                                         // Increment the sticky offset. The next sticky will be placed at this offset.
--                                         $sticky_offset++;
--                                         // Remove post from sticky posts array.
--                                         $offset = array_search( $sticky_post->ID, $sticky_posts, true );
--                                         unset( $sticky_posts[ $offset ] );
--                                 end;
--                         end;

--                         // If any posts have been excluded specifically, Ignore those that are sticky.
--                         if ( ! empty( $sticky_posts ) && ! empty( $q['post__not_in'] ) ) then
--                                 $sticky_posts = array_diff( $sticky_posts, $q['post__not_in'] );
--                         end;

--                         // Fetch sticky posts that weren't in the query results.
--                         if ( ! empty( $sticky_posts ) ) then
--                                 $stickies = get_posts(
--                                         array(
--                                                 'post__in'               => $sticky_posts,
--                                                 'post_type'              => $post_type,
--                                                 'post_status'            => 'publish',
--                                                 'posts_per_page'         => count( $sticky_posts ),
--                                                 'suppress_filters'       => $q['suppress_filters'],
--                                                 'cache_results'          => $q['cache_results'],
--                                                 'update_post_meta_cache' => $q['update_post_meta_cache'],
--                                                 'update_post_term_cache' => $q['update_post_term_cache'],
--                                                 'lazy_load_term_meta'    => $q['lazy_load_term_meta'],
--                                         )
--                                 );

--                                 foreach ( $stickies as $sticky_post ) then
--                                         array_splice( $this->posts, $sticky_offset, 0, array( $sticky_post ) );
--                                         $sticky_offset++;
--                                 end;
--                         end;
--                 end;

--                 // If comments have been fetched as part of the query, make sure comment meta lazy-loading is set up.
--                 if ( ! empty( $this->comments ) ) then
--                         wp_queue_comments_for_comment_meta_lazyload( $this->comments );
--                 end;

--                 if ( ! $q['suppress_filters'] ) then
--                         --
--                         -- Filters the array of retrieved posts after they've been fetched and
--                         -- internally processed.
--                         --
--                         -- @since 1.5.0
--                         --
--                         -- @param WP_Post[] $posts Array of post objects.
--                         -- @param WP_Query  $query The WP_Query instance (passed by reference).
--                         --
--                         $this->posts = apply_filters_ref_array( 'the_posts', array( $this->posts, &$this ) );
--                 end;

--                 // Ensure that any posts added/modified via one of the filters above are
--                 // of the type WP_Post and are filtered.
--                 if ( $this->posts ) then
--                         $this->post_count = count( $this->posts );

--                         -- @var WP_Post[]--
--                         $this->posts = array_map( 'get_post', $this->posts );

--                         if ( $q['cache_results'] ) then
--                                 $post_ids = wp_list_pluck( $this->posts, 'ID' );
--                                 _prime_post_caches( $post_ids, $q['update_post_term_cache'], $q['update_post_meta_cache'] );
--                         end;

--                         -- @var WP_Post--
--                         $this->post = reset( $this->posts );
--                 end; else then
--                         $this->post_count = 0;
--                         $this->posts      = array();
--                 end;

--                 if ( ! empty( $this->posts ) && $q['update_menu_item_cache'] ) then
--                         update_menu_item_cache( $this->posts );
--                 end;

--                 if ( $q['lazy_load_term_meta'] ) then
--                         wp_queue_posts_for_term_meta_lazyload( $this->posts );
--                 end;

--                 return $this->posts;
--         end;

--         --
--         -- Set up the amount of found posts and the number of pages (if limit clause was used)
--         -- for the current query.
--         --
--         -- @since 3.5.0
--         --
--         -- @global wpdb $wpdb WordPress database abstraction object.
--         --
--         -- @param array  $q      Query variables.
--         -- @param string $limits LIMIT clauses of the query.
--         --
--         private function set_found_posts( $q, $limits ) then
--                 global $wpdb;

--                 // Bail if posts is an empty array. Continue if posts is an empty string,
--                 // null, or false to accommodate caching plugins that fill posts later.
--                 if ( $q['no_found_rows'] || ( is_array( $this->posts ) && ! $this->posts ) ) then
--                         return;
--                 end;

--                 if ( ! empty( $limits ) ) then
--                         --
--                         -- Filters the query to run for retrieving the found posts.
--                         --
--                         -- @since 2.1.0
--                         --
--                         -- @param string   $found_posts_query The query to run to find the found posts.
--                         -- @param WP_Query $query             The WP_Query instance (passed by reference).
--                         --
--                         $found_posts_query = apply_filters_ref_array( 'found_posts_query', array( 'SELECT FOUND_ROWS()', &$this ) );

--                         $this->found_posts = (int) $wpdb->get_var( $found_posts_query );
--                 end; else then
--                         if ( is_array( $this->posts ) ) then
--                                 $this->found_posts = count( $this->posts );
--                         end; else then
--                                 if ( null === $this->posts ) then
--                                         $this->found_posts = 0;
--                                 end; else then
--                                         $this->found_posts = 1;
--                                 end;
--                         end;
--                 end;

--                 --
--                 -- Filters the number of found posts for the query.
--                 --
--                 -- @since 2.1.0
--                 --
--                 -- @param int      $found_posts The number of posts found.
--                 -- @param WP_Query $query       The WP_Query instance (passed by reference).
--                 --
--                 $this->found_posts = (int) apply_filters_ref_array( 'found_posts', array( $this->found_posts, &$this ) );

--                 if ( ! empty( $limits ) ) then
--                         $this->max_num_pages = ceil( $this->found_posts / $q['posts_per_page'] );
--                 end;
--         end;

--         --
--         -- Set up the next post and iterate current post index.
--         --
--         -- @since 1.5.0
--         --
--         -- @return WP_Post Next post.
--         --
--         public function next_post() then

--                 $this->current_post++;

--                 -- @var WP_Post--
--                 $this->post = $this->posts[ $this->current_post ];
--                 return $this->post;
--         end;

--         --
--         -- Sets up the current post.
--         --
--         -- Retrieves the next post, sets up the post, sets the 'in the loop'
--         -- property to true.
--         --
--         -- @since 1.5.0
--         --
--         -- @global WP_Post $post Global post object.
--         --
--         public function the_post() then
--                 global $post;

--                 if ( ! $this->in_the_loop ) then
--                         // Only prime the post cache for queries limited to the ID field.
--                         $post_ids = array_filter( $this->posts, 'is_numeric' );
--                         // Exclude any falsey values, such as 0.
--                         $post_ids = array_filter( $post_ids );
--                         if ( $post_ids ) then
--                                 _prime_post_caches( $post_ids, $this->query_vars['update_post_term_cache'], $this->query_vars['update_post_meta_cache'] );
--                         end;
--                         $post_objects = array_map( 'get_post', $this->posts );
--                         update_post_author_caches( $post_objects );
--                 end;

--                 $this->in_the_loop = true;

--                 if ( -1 == $this->current_post ) then // Loop has just started.
--                         --
--                         -- Fires once the loop is started.
--                         --
--                         -- @since 2.0.0
--                         --
--                         -- @param WP_Query $query The WP_Query instance (passed by reference).
--                         --
--                         do_action_ref_array( 'loop_start', array( &$this ) );
--                 end;

--                 $post = $this->next_post();
--                 $this->setup_postdata( $post );
--         end;

--         --
--         -- Determines whether there are more posts available in the loop.
--         --
--         -- Calls the {@see 'loop_end'} action when the loop is complete.
--         --
--         -- @since 1.5.0
--         --
--         -- @return bool True if posts are available, false if end of the loop.
--         --
--         public function have_posts() then
--                 if ( $this->current_post + 1 < $this->post_count ) then
--                         return true;
--                 end; elseif ( $this->current_post + 1 == $this->post_count && $this->post_count > 0 ) then
--                         --
--                         -- Fires once the loop has ended.
--                         --
--                         -- @since 2.0.0
--                         --
--                         -- @param WP_Query $query The WP_Query instance (passed by reference).
--                         --
--                         do_action_ref_array( 'loop_end', array( &$this ) );
--                         // Do some cleaning up after the loop.
--                         $this->rewind_posts();
--                 end; elseif ( 0 === $this->post_count ) then
--                         --
--                         -- Fires if no results are found in a post query.
--                         --
--                         -- @since 4.9.0
--                         --
--                         -- @param WP_Query $query The WP_Query instance.
--                         --
--                         do_action( 'loop_no_results', $this );
--                 end;

--                 $this->in_the_loop = false;
--                 return false;
--         end;

--         --
--         -- Rewind the posts and reset post index.
--         --
--         -- @since 1.5.0
--         --
--         public function rewind_posts() then
--                 $this->current_post = -1;
--                 if ( $this->post_count > 0 ) then
--                         $this->post = $this->posts[0];
--                 end;
--         end;

--         --
--         -- Iterate current comment index and return WP_Comment object.
--         --
--         -- @since 2.2.0
--         --
--         -- @return WP_Comment Comment object.
--         --
--         public function next_comment() then
--                 $this->current_comment++;

--                 -- @var WP_Comment--
--                 $this->comment = $this->comments[ $this->current_comment ];
--                 return $this->comment;
--         end;

--         --
--         -- Sets up the current comment.
--         --
--         -- @since 2.2.0
--         --
--         -- @global WP_Comment $comment Global comment object.
--         --
--         public function the_comment() then
--                 global $comment;

--                 $comment = $this->next_comment();

--                 if ( 0 == $this->current_comment ) then
--                         --
--                         -- Fires once the comment loop is started.
--                         --
--                         -- @since 2.2.0
--                         --
--                         do_action( 'comment_loop_start' );
--                 end;
--         end;

--         --
--         -- Whether there are more comments available.
--         --
--         -- Automatically rewinds comments when finished.
--         --
--         -- @since 2.2.0
--         --
--         -- @return bool True if comments are available, false if no more comments.
--         --
--         public function have_comments() then
--                 if ( $this->current_comment + 1 < $this->comment_count ) then
--                         return true;
--                 end; elseif ( $this->current_comment + 1 == $this->comment_count ) then
--                         $this->rewind_comments();
--                 end;

--                 return false;
--         end;

--         --
--         -- Rewind the comments, resets the comment index and comment to first.
--         --
--         -- @since 2.2.0
--         --
--         public function rewind_comments() then
--                 $this->current_comment = -1;
--                 if ( $this->comment_count > 0 ) then
--                         $this->comment = $this->comments[0];
--                 end;
--         end;

--         --
--         -- Sets up the WordPress query by parsing query string.
--         --
--         -- @since 1.5.0
--         --
--         -- @see WP_Query::parse_query() for all available arguments.
--         --
--         -- @param string|array $query URL query string or array of query arguments.
--         -- @return WP_Post[]|int[] Array of post objects or post IDs.
--         --
--         public function query( $query ) then
--                 $this->init();
--                 $this->query      = wp_parse_args( $query );
--                 $this->query_vars = $this->query;
--                 return $this->get_posts();
--         end;

--         --
--         -- Retrieves the currently queried object.
--         --
--         -- If queried object is not set, then the queried object will be set from
--         -- the category, tag, taxonomy, posts page, single post, page, or author
--         -- query variable. After it is set up, it will be returned.
--         --
--         -- @since 1.5.0
--         --
--         -- @return WP_Term|WP_Post_Type|WP_Post|WP_User|null The queried object.
--         --
--         public function get_queried_object() then
--                 if ( isset( $this->queried_object ) ) then
--                         return $this->queried_object;
--                 end;

--                 $this->queried_object    = null;
--                 $this->queried_object_id = null;

--                 if ( $this->is_category || $this->is_tag || $this->is_tax ) then
--                         if ( $this->is_category ) then
--                                 $cat           = $this->get( 'cat' );
--                                 $category_name = $this->get( 'category_name' );

--                                 if ( $cat ) then
--                                         $term = get_term( $cat, 'category' );
--                                 end; elseif ( $category_name ) then
--                                         $term = get_term_by( 'slug', $category_name, 'category' );
--                                 end;
--                         end; elseif ( $this->is_tag ) then
--                                 $tag_id = $this->get( 'tag_id' );
--                                 $tag    = $this->get( 'tag' );

--                                 if ( $tag_id ) then
--                                         $term = get_term( $tag_id, 'post_tag' );
--                                 end; elseif ( $tag ) then
--                                         $term = get_term_by( 'slug', $tag, 'post_tag' );
--                                 end;
--                         end; else then
--                                 // For other tax queries, grab the first term from the first clause.
--                                 if ( ! empty( $this->tax_query->queried_terms ) ) then
--                                         $queried_taxonomies = array_keys( $this->tax_query->queried_terms );
--                                         $matched_taxonomy   = reset( $queried_taxonomies );
--                                         $query              = $this->tax_query->queried_terms[ $matched_taxonomy ];

--                                         if ( ! empty( $query['terms'] ) ) then
--                                                 if ( 'term_id' === $query['field'] ) then
--                                                         $term = get_term( reset( $query['terms'] ), $matched_taxonomy );
--                                                 end; else then
--                                                         $term = get_term_by( $query['field'], reset( $query['terms'] ), $matched_taxonomy );
--                                                 end;
--                                         end;
--                                 end;
--                         end;

--                         if ( ! empty( $term ) && ! is_wp_error( $term ) ) then
--                                 $this->queried_object    = $term;
--                                 $this->queried_object_id = (int) $term->term_id;

--                                 if ( $this->is_category && 'category' === $this->queried_object->taxonomy ) then
--                                         _make_cat_compat( $this->queried_object );
--                                 end;
--                         end;
--                 end; elseif ( $this->is_post_type_archive ) then
--                         $post_type = $this->get( 'post_type' );

--                         if ( is_array( $post_type ) ) then
--                                 $post_type = reset( $post_type );
--                         end;

--                         $this->queried_object = get_post_type_object( $post_type );
--                 end; elseif ( $this->is_posts_page ) then
--                         $page_for_posts = get_option( 'page_for_posts' );

--                         $this->queried_object    = get_post( $page_for_posts );
--                         $this->queried_object_id = (int) $this->queried_object->ID;
--                 end; elseif ( $this->is_singular && ! empty( $this->post ) ) then
--                         $this->queried_object    = $this->post;
--                         $this->queried_object_id = (int) $this->post->ID;
--                 end; elseif ( $this->is_author ) then
--                         $author      = (int) $this->get( 'author' );
--                         $author_name = $this->get( 'author_name' );

--                         if ( $author ) then
--                                 $this->queried_object_id = $author;
--                         end; elseif ( $author_name ) then
--                                 $user = get_user_by( 'slug', $author_name );

--                                 if ( $user ) then
--                                         $this->queried_object_id = $user->ID;
--                                 end;
--                         end;

--                         $this->queried_object = get_userdata( $this->queried_object_id );
--                 end;

--                 return $this->queried_object;
--         end;

   ---------------------------
   -- Get_Queried_Object_Id --
   ---------------------------

   function Get_Queried_Object_Id (This : Wp_Query)
                                   return Class_Posts.Post_Id -- Integer
   is
      use Class_Posts;

      Unused : constant Wp_Post := This.Get_Queried_Object;
   begin
      if This.Queried_Object_Id /= 0 then -- isset
         return Class_Posts.Post_Id (This.Queried_Object_Id);
      end if;

      return 0;
   end Get_Queried_Object_Id;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Query : Array_Type) -- ''
                         return Wp_Query
   is
      This : Wp_Query;
   begin
      if Query /= Empty_Array then
--    if not Empty (Query) then
         This.Query (Query);
      end if;
      return This; -- added
   end X_Construct;

--         --
--         -- Make private properties readable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string $name Property to get.
--         -- @return mixed Property.
--         --
--         public function __get( $name ) then
--                 if ( in_array( $name, $this->compat_fields, true ) ) then
--                         return $this->$name;
--                 end;
--         end;

--         --
--         -- Make private properties checkable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string $name Property to check if set.
--         -- @return bool Whether the property is set.
--         --
--         public function __isset( $name ) then
--                 if ( in_array( $name, $this->compat_fields, true ) ) then
--                         return isset( $this->$name );
--                 end;
--         end;

--         --
--         -- Make private/protected methods readable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string $name      Method to call.
--         -- @param array  $arguments Arguments to pass when calling.
--         -- @return mixed|false Return value of the callback, false otherwise.
--         --
--         public function __call( $name, $arguments ) then
--                 if ( in_array( $name, $this->compat_methods, true ) ) then
--                         return $this->$name( ...$arguments );
--                 end;
--                 return false;
--         end;

--         --
--         -- Is the query for an existing archive page?
--         --
--         -- Archive pages include category, tag, author, date, custom post type,
--         -- and custom taxonomy based archives.
--         --
--         -- @since 3.1.0
--         --
--         -- @see WP_Query::is_category()
--         -- @see WP_Query::is_tag()
--         -- @see WP_Query::is_author()
--         -- @see WP_Query::is_date()
--         -- @see WP_Query::is_post_type_archive()
--         -- @see WP_Query::is_tax()
--         --
--         -- @return bool Whether the query is for an existing archive page.
--         --
--         public function is_archive() then
--                 return (bool) $this->is_archive;
--         end;

   --------------------------
   -- Is_Post_Type_Archive --
   --------------------------

   function Is_Post_Type_Archive (This       : Wp_Query;
                                  Post_Types : String := "")
                                  return Boolean
   is
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Class_Post_Type;

   begin
      if Empty (Post_Types) or else not This.Is_Post_Type_Archive then
         return This.Is_Post_Type_Archive; -- (bool)
      end if;

      declare
         Post_Type : constant String := This.Get ("post_type");
         -- if Is_Array (Post_Type) then
         --    Post_Type := Reset (Post_Type);
         -- end if;
         Post_Type_Object : constant Class_Post_Type.Wp_Post_Type :=
           Inc_Posts.Get_Post_Type_Object (Post_Type);
      begin
         if Post_Type_Object = Null_Post_Type then
--       if not Post_Type_Object then
            return False;
         end if;

         return In_List (-Post_Type_Object.Name, To_List (Post_Types), True);
--       return In_Array (-Post_Type_Object.Name, Post_Types, True); -- (array)
      end;
   end Is_Post_Type_Archive;

--         --
--         -- Is the query for an existing attachment page?
--         --
--         -- @since 3.1.0
--         --
--         -- @param int|string|int[]|string[] $attachment Optional. Attachment ID, title, slug, or array of such
--         --                                              to check against. Default empty.
--         -- @return bool Whether the query is for an existing attachment page.
--         --
--         public function is_attachment( $attachment = '' ) then
--                 if ( ! $this->is_attachment ) then
--                         return false;
--                 end;

--                 if ( empty( $attachment ) ) then
--                         return true;
--                 end;

--                 $attachment = array_map( 'strval', (array) $attachment );

--                 $post_obj = $this->get_queried_object();
--                 if ( ! $post_obj ) then
--                         return false;
--                 end;

--                 if ( in_array( (string) $post_obj->ID, $attachment, true ) ) then
--                         return true;
--                 end; elseif ( in_array( $post_obj->post_title, $attachment, true ) ) then
--                         return true;
--                 end; elseif ( in_array( $post_obj->post_name, $attachment, true ) ) then
--                         return true;
--                 end;
--                 return false;
--         end;

   ---------------
   -- Is_Author --
   ---------------

   function Is_Author (This   : Wp_Query;
                       Author : String := "")
                       return Boolean
   is
      use UStrings;
      use Php.Lists;
      use Php.Strings;
      use Class_Users;
   begin
      if not This.Is_Author then
         return False;
      end if;

      if Empty (Author) then
         return True;
      end if;

      declare
         Author_Obj : constant Wp_User :=
           This.Get_Queried_Object;
      begin
         if Author_Obj = Null_User then
--       if not Author_Obj then
            return False;
         end if;

         declare
            Author_2 : constant List_Type :=
              List_Map (Strval'Access, To_List (Author)); -- (array)
         begin
            if In_List (Author_Obj.Id'Image, Author_2, True) then -- (string)
               return True;
            elsif In_List (-Author_Obj.Prop.Nickname, Author_2, True) then
               return True;
            elsif In_List (-Author_Obj.Prop.User_Nicename, Author_2, True) then
               return True;
            end if;
         end;
      end;
      return False;
   end Is_Author;

   -----------------
   -- Is_Category --
   -----------------

   function Is_Category (This     : Wp_Query;
                         Category : String := "")
                         return Boolean
   is
      use Php.Lists;
      use Php.Strings;
      use UStrings;
   begin
      if not This.M_Is_Category then
         return False;
      end if;

      if Empty (Category) then
         return True;
      end if;

      declare
         use Class_Terms; -- Posts;

         Cat_Obj : constant Wp_Term := This.Get_Queried_Object;
      begin
         if Cat_Obj = Null_Term then
--       if not Cat_Obj then
            return False;
         end if;

         declare
            Category_2 : List_Type; --  := Category; -- Array_Map ("strval", (array) Category);
         begin
            if In_List (Integer'Image (Cat_Obj.Term_Id), Category_2, True) then -- (string)
               return True;
            elsif In_List (-Cat_Obj.Name, Category_2, True) then
               return True;
            elsif In_List (-Cat_Obj.Slug, Category_2, True) then
               return True;
            end if;
         end;
      end;
      return False;
   end Is_Category;

   ------------
   -- Is_Tag --
   ------------

   function Is_Tag (This : Wp_Query;
                    Tag  : String := "")
                    return Boolean
   is
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Class_Terms;
   begin
      if not This.Is_Tag then
         return False;
      end if;

      if Empty (Tag) then
         return True;
      end if;

      declare
         Tag_Obj : constant Wp_Term :=
           This.Get_Queried_Object;
      begin
         if Tag_Obj = Null_Term then
--       if not Tag_Obj then
            return False;
         end if;

         declare
            Tag_2 : constant List_Type :=
              List_Map (Strval'Access, To_List (Tag)); -- (array)
         begin
            if In_List (Tag_Obj.Term_Id'Image, Tag_2, True) then -- (string)
               return True;
            elsif In_List (-Tag_Obj.Name, Tag_2, True) then
               return True;
            elsif In_List (-Tag_Obj.Slug, Tag_2, True) then
               return True;
            end if;
         end;
      end;
      return False;
   end Is_Tag;

   Wp_Taxonomies : List_Type;

   ------------
   -- Is_Tax --
   ------------

   function Is_Tax (This     : Wp_Query;
                    Taxonomy : String := "";
                    Term     : String := "")
                    return Boolean
   is
      use Ada.Containers;
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Class_Terms;
   begin
      if not This.Is_Tax then
         return False;
      end if;

      if Empty (Taxonomy) then
         return True;
      end if;

      declare
         Queried_Object : constant Wp_Term :=
           This.Get_Queried_Object;

         Tax_Array : constant List_Type :=
           List_Intersect (List_Keys (Wp_Taxonomies), To_List (Taxonomy));

         Term_Array : constant List_Type := To_List (Term); -- (array)
      begin
         -- Check that the taxonomy matches.
         if
           Isset (-Queried_Object.Taxonomy) and then
           Tax_Array.Length /= 0            and then
--         Count (Tax_Array)                and then
           In_List (-Queried_Object.Taxonomy, Tax_Array, True)
         then
            null;
         else
            return False;
         end if;

         -- Only a taxonomy provided.
         if Empty (Term) then
            return True;
         end if;

         return
           Queried_Object.Term_Id /= 0 and then
--         Isset (Queried_Object.Term_Id) and then
--         Count (
             List_Intersect (
               To_List (List => (+Queried_Object.Term_Id'Image,
                                 Queried_Object.Name,
                                 Queried_Object.Slug)),
               Term_Array
             ).Length /= 0;
--         );
      end;
   end Is_Tax;

--         --
--         -- Whether the current URL is within the comments popup window.
--         --
--         -- @since 3.1.0
--         -- @deprecated 4.5.0
--         --
--         -- @return false Always returns false.
--         --
--         public function is_comments_popup() then
--                 _deprecated_function( __FUNCTION__, '4.5.0' );

--                 return false;
--         end;

--         --
--         -- Is the query for an existing date archive?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for an existing date archive.
--         --
--         public function is_date() then
--                 return (bool) $this->is_date;
--         end;

--         --
--         -- Is the query for an existing day archive?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for an existing day archive.
--         --
--         public function is_day() then
--                 return (bool) $this->is_day;
--         end;

--         --
--         -- Is the query for a feed?
--         --
--         -- @since 3.1.0
--         --
--         -- @param string|string[] $feeds Optional. Feed type or array of feed types
--         --                                         to check against. Default empty.
--         -- @return bool Whether the query is for a feed.
--         --
--         public function is_feed( $feeds = '' ) then
--                 if ( empty( $feeds ) || ! $this->is_feed ) then
--                         return (bool) $this->is_feed;
--                 end;

--                 $qv = $this->get( 'feed' );
--                 if ( 'feed' === $qv ) then
--                         $qv = get_default_feed();
--                 end;

--                 return in_array( $qv, (array) $feeds, true );
--         end;

--         --
--         -- Is the query for a comments feed?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for a comments feed.
--         --
--         public function is_comment_feed() then
--                 return (bool) $this->is_comment_feed;
--         end;

   -------------------
   -- Is_Front_Page --
   -------------------

   function Is_Front_Page (This : Wp_Query)
                           return Boolean
   is
      use Inc_Options;
   begin
      -- Most likely case.
      if
        "posts" = Get_Option ("show_on_front") and then
        This.Is_Home
      then
         return True;

      elsif
        "page" = Get_Option ("show_on_front") and then
        Get_Option ("page_on_front")          and then
        This.Is_Page (Get_Option ("page_on_front"))
      then
         return True;
      else
         return False;
      end if;
   end Is_Front_Page;

--         --
--         -- Is the query for the blog homepage?
--         --
--         -- This is the page which shows the time based blog content of your site.
--         --
--         -- Depends on the site's "Front page displays" Reading Settings 'show_on_front' and 'page_for_posts'.
--         --
--         -- If you set a static page for the front page of your site, this function will return
--         -- true only on the page you set as the "Posts page".
--         --
--         -- @since 3.1.0
--         --
--         -- @see WP_Query::is_front_page()
--         --
--         -- @return bool Whether the query is for the blog homepage.
--         --
--         public function is_home() then
--                 return (bool) $this->is_home;
--         end;

--         --
--         -- Is the query for the Privacy Policy page?
--         --
--         -- This is the page which shows the Privacy Policy content of your site.
--         --
--         -- Depends on the site's "Change your Privacy Policy page" Privacy Settings 'wp_page_for_privacy_policy'.
--         --
--         -- This function will return true only on the page you set as the "Privacy Policy page".
--         --
--         -- @since 5.2.0
--         --
--         -- @return bool Whether the query is for the Privacy Policy page.
--         --
--         public function is_privacy_policy() then
--                 if ( get_option( 'wp_page_for_privacy_policy' )
--                         && $this->is_page( get_option( 'wp_page_for_privacy_policy' ) )
--                 ) then
--                         return true;
--                 end; else then
--                         return false;
--                 end;
--         end;

--         --
--         -- Is the query for an existing month archive?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for an existing month archive.
--         --
--         public function is_month() then
--                 return (bool) $this->is_month;
--         end;

   -------------
   -- Is_Page --
   -------------

   function Is_Page (This : Wp_Query;
                     Page : String := "")
                     return Boolean
   is
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Class_Posts;
      use Inc_Posts;
   begin
      if not This.Is_Page then
         return False;
      end if;

      if Empty (Page) then
         return True;
      end if;

      declare
         Page_Obj : constant Wp_Post :=
           This.Get_Queried_Object;
      begin
         if Page_Obj = Null_Post then
--       if not Page_Obj then
            return False;
         end if;

         declare
            Page_2 : constant List_Type :=
              List_Map (Strval'Access, To_List (Page)); -- (array)
         begin
            if In_List (Page_Obj.Id'Image, Page_2, True) then -- (string)
               return True;
            elsif In_List (-Page_Obj.Post_Title, Page_2, True) then
               return True;
            elsif In_List (-Page_Obj.Post_Name, Page_2, True) then
               return True;
            else
               for Pagepath of Page_2 loop
                  if 0 /= Strpos (-Pagepath, "/") then
                     goto Continue;
                  end if;

                  declare
                     Pagepath_Obj : constant Wp_Post :=
                       Get_Page_By_Path (-Pagepath);
                  begin
                     if
                       Pagepath_Obj /= Null_Post and then
                       Pagepath_Obj.Id = Page_Obj.Id
                     then
                        return True;
                     end if;
                  end;
                  << Continue >>
               end loop;
            end if;
         end;
      end;
      return False;
   end Is_Page;

--         --
--         -- Is the query for a paged result and not for the first page?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for a paged result.
--         --
--         public function is_paged() then
--                 return (bool) $this->is_paged;
--         end;

--         --
--         -- Is the query for a post or page preview?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for a post or page preview.
--         --
--         public function is_preview() then
--                 return (bool) $this->is_preview;
--         end;

--         --
--         -- Is the query for the robots.txt file?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for the robots.txt file.
--         --
--         public function is_robots() then
--                 return (bool) $this->is_robots;
--         end;

--         --
--         -- Is the query for the favicon.ico file?
--         --
--         -- @since 5.4.0
--         --
--         -- @return bool Whether the query is for the favicon.ico file.
--         --
--         public function is_favicon() then
--                 return (bool) $this->is_favicon;
--         end;

--         --
--         -- Is the query for a search?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for a search.
--         --
--         public function is_search() then
--                 return (bool) $this->is_search;
--         end;

   ---------------
   -- Is_Single --
   ---------------

   function Is_Single (This : Wp_Query;
                       Post : String := "")
                       return Boolean
   is
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Class_Posts;
      use Inc_Posts;
   begin
      if not This.Is_Single then
         return False;
      end if;

      if Empty (Post) then
         return True;
      end if;

      declare
         Post_Obj : constant Wp_Post :=
           This.Get_Queried_Object;
      begin
         if Post_Obj = Null_Post then
            return False;
         end if;

         declare
            Post_2 : constant List_Type := List_Map (Strval'Access, To_List (Post));
         begin
            if In_List (Post_Obj.Id'Image, Post_2, True) then
               return True;
            elsif In_List (-Post_Obj.Post_Title, Post_2, True) then
               return True;
            elsif In_List (-Post_Obj.Post_Name, Post_2, True) then
               return True;
            else
               for Postpath of Post_2 loop
                  if 0 /= Strpos (-Postpath, "/") then
                     goto Continue;
                  end if;

                  declare
                     Postpath_Obj : constant Wp_Post :=
                       Get_Page_By_Path (-Postpath, "OBJECT", -Post_Obj.Post_Type);
                  begin
                     if
                        Postpath_Obj /= Null_Post and then
                        Postpath_Obj.Id = Post_Obj.Id
                     then
                        return True;
                     end if;
                  end;
                  << Continue >>
               end loop;
            end if;
         end;
      end;
      return False;
   end Is_Single;

   -----------------
   -- Is_Singular --
   -----------------

   function Is_Singular (This       : Wp_Query;
                         Post_Types : String := "")
                         return Boolean
   is
      use UStrings;
      use Php.Lists;
      use Php.Strings;
      use Class_Posts;
   begin
      if
        Empty (Post_Types) or else
        not This.Is_Singular
      then
         return This.Is_Singular; -- (bool)
      end if;

      declare
         Post_Obj : constant Wp_Post :=
           This.Get_Queried_Object;
      begin
         if Post_Obj = Null_Post then
            return False;
         end if;

         return In_List (-Post_Obj.Post_Type, To_List (Post_Types), True);
      end;
   end Is_Singular;

--         --
--         -- Is the query for a specific time?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for a specific time.
--         --
--         public function is_time() then
--                 return (bool) $this->is_time;
--         end;

--         --
--         -- Is the query for a trackback endpoint call?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for a trackback endpoint call.
--         --
--         public function is_trackback() then
--                 return (bool) $this->is_trackback;
--         end;

--         --
--         -- Is the query for an existing year archive?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is for an existing year archive.
--         --
--         public function is_year() then
--                 return (bool) $this->is_year;
--         end;

--         --
--         -- Is the query a 404 (returns no results)?
--         --
--         -- @since 3.1.0
--         --
--         -- @return bool Whether the query is a 404 error.
--         --
--         public function is_404() then
--                 return (bool) $this->is_404;
--         end;

--         --
--         -- Is the query for an embedded post?
--         --
--         -- @since 4.4.0
--         --
--         -- @return bool Whether the query is for an embedded post.
--         --
--         public function is_embed() then
--                 return (bool) $this->is_embed;
--         end;

   -------------------
   -- Is_Main_Query --
   -------------------

   Global_Wp_The_Query : Wp_Query;

   function Is_Main_Query (This : Wp_Query)
                           return Boolean
   is
   begin
      return Global_Wp_The_Query = This;
   end Is_Main_Query;

--         --
--         -- Set up global post data.
--         --
--         -- @since 4.1.0
--         -- @since 4.4.0 Added the ability to pass a post ID to `$post`.
--         --
--         -- @global int     $id
--         -- @global WP_User $authordata
--         -- @global string  $currentday
--         -- @global string  $currentmonth
--         -- @global int     $page
--         -- @global array   $pages
--         -- @global int     $multipage
--         -- @global int     $more
--         -- @global int     $numpages
--         --
--         -- @param WP_Post|object|int $post WP_Post instance or Post ID/object.
--         -- @return true True when finished.
--         --
--         public function setup_postdata( $post ) then
--                 global $id, $authordata, $currentday, $currentmonth, $page, $pages, $multipage, $more, $numpages;

--                 if ( ! ( $post instanceof WP_Post ) ) then
--                         $post = get_post( $post );
--                 end;

--                 if ( ! $post ) then
--                         return;
--                 end;

--                 $elements = $this->generate_postdata( $post );
--                 if ( false === $elements ) then
--                         return;
--                 end;

--                 $id           = $elements['id'];
--                 $authordata   = $elements['authordata'];
--                 $currentday   = $elements['currentday'];
--                 $currentmonth = $elements['currentmonth'];
--                 $page         = $elements['page'];
--                 $pages        = $elements['pages'];
--                 $multipage    = $elements['multipage'];
--                 $more         = $elements['more'];
--                 $numpages     = $elements['numpages'];

--                 --
--                 -- Fires once the post data has been set up.
--                 --
--                 -- @since 2.8.0
--                 -- @since 4.1.0 Introduced `$query` parameter.
--                 --
--                 -- @param WP_Post  $post  The Post object (passed by reference).
--                 -- @param WP_Query $query The current Query object (passed by reference).
--                 --
--                 do_action_ref_array( 'the_post', array( &$post, &$this ) );

--                 return true;
--         end;

--         --
--         -- Generate post data.
--         --
--         -- @since 5.2.0
--         --
--         -- @param WP_Post|object|int $post WP_Post instance or Post ID/object.
--         -- @return array|false Elements of post or false on failure.
--         --
--         public function generate_postdata( $post ) then

--                 if ( ! ( $post instanceof WP_Post ) ) then
--                         $post = get_post( $post );
--                 end;

--                 if ( ! $post ) then
--                         return false;
--                 end;

--                 $id = (int) $post->ID;

--                 $authordata = get_userdata( $post->post_author );

--                 $currentday   = mysql2date( 'd.m.y', $post->post_date, false );
--                 $currentmonth = mysql2date( 'm', $post->post_date, false );
--                 $numpages     = 1;
--                 $multipage    = 0;
--                 $page         = $this->get( 'page' );
--                 if ( ! $page ) then
--                         $page = 1;
--                 end;

--                 /*
--                 -- Force full post content when viewing the permalink for the $post,
--                 -- or when on an RSS feed. Otherwise respect the 'more' tag.
--                 --
--                 if ( get_queried_object_id() === $post->ID && ( $this->is_page() || $this->is_single() ) ) then
--                         $more = 1;
--                 end; elseif ( $this->is_feed() ) then
--                         $more = 1;
--                 end; else then
--                         $more = 0;
--                 end;

--                 $content = $post->post_content;
--                 if ( false !== strpos( $content, '<!--nextpage-->' ) ) then
--                         $content = str_replace( "\n<!--nextpage-->\n", '<!--nextpage-->', $content );
--                         $content = str_replace( "\n<!--nextpage-->", '<!--nextpage-->', $content );
--                         $content = str_replace( "<!--nextpage-->\n", '<!--nextpage-->', $content );

--                         // Remove the nextpage block delimiters, to avoid invalid block structures in the split content.
--                         $content = str_replace( '<!-- wp:nextpage -->', '', $content );
--                         $content = str_replace( '<!-- /wp:nextpage -->', '', $content );

--                         // Ignore nextpage at the beginning of the content.
--                         if ( 0 === strpos( $content, '<!--nextpage-->' ) ) then
--                                 $content = substr( $content, 15 );
--                         end;

--                         $pages = explode( '<!--nextpage-->', $content );
--                 end; else then
--                         $pages = array( $post->post_content );
--                 end;

--                 --
--                 -- Filters the "pages" derived from splitting the post content.
--                 --
--                 -- "Pages" are determined by splitting the post content based on the presence
--                 -- of `<!-- nextpage -->` tags.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param string[] $pages Array of "pages" from the post content split by `<!-- nextpage -->` tags.
--                 -- @param WP_Post  $post  Current post object.
--                 --
--                 $pages = apply_filters( 'content_pagination', $pages, $post );

--                 $numpages = count( $pages );

--                 if ( $numpages > 1 ) then
--                         if ( $page > 1 ) then
--                                 $more = 1;
--                         end;
--                         $multipage = 1;
--                 end; else then
--                         $multipage = 0;
--                 end;

--                 $elements = compact( 'id', 'authordata', 'currentday', 'currentmonth', 'page', 'pages', 'multipage', 'more', 'numpages' );

--                 return $elements;
--         end;

--         --
--         -- Generate cache key.
--         --
--         -- @since 6.1.0
--         --
--         -- @global wpdb $wpdb WordPress database abstraction object.
--         --
--         -- @param array  $args Query arguments.
--         -- @param string $sql  SQL statement.
--         --
--         -- @return string Cache key.
--         --
--         protected function generate_cache_key( array $args, $sql ) then
--                 global $wpdb;

--                 unset(
--                         $args['cache_results'],
--                         $args['fields'],
--                         $args['lazy_load_term_meta'],
--                         $args['update_post_meta_cache'],
--                         $args['update_post_term_cache'],
--                         $args['update_menu_item_cache'],
--                         $args['suppress_filters']
--                 );

--                 $placeholder = $wpdb->placeholder_escape();
--                 array_walk_recursive(
--                         $args,
--                         /*
--                         -- Replace wpdb placeholders with the string used in the database
--                         -- query to avoid unreachable cache keys. This is necessary because
--                         -- the placeholder is randomly generated in each request.
--                         --
--                         -- $value is passed by reference to allow it to be modified.
--                         -- array_walk_recursive() does not return an array.
--                         --
--                         function ( &$value ) use ( $wpdb, $placeholder ) then
--                                 if ( is_string( $value ) && str_contains( $value, $placeholder ) ) then
--                                         $value = $wpdb->remove_placeholder_escape( $value );
--                                 end;
--                         end;
--                 );

--                 // Replace wpdb placeholder in the SQL statement used by the cache key.
--                 $sql = $wpdb->remove_placeholder_escape( $sql );
--                 $key = md5( serialize( $args ) . $sql );

--                 $last_changed = wp_cache_get_last_changed( 'posts' );
--                 if ( ! empty( $this->tax_query->queries ) ) then
--                         $last_changed .= wp_cache_get_last_changed( 'terms' );
--                 end;

--                 return "wp_query:$key:$last_changed";
--         end;

--         --
--         -- After looping through a nested query, this function
--         -- restores the $post global to the current post in this query.
--         --
--         -- @since 3.7.0
--         --
--         -- @global WP_Post $post Global post object.
--         --
--         public function reset_postdata() then
--                 if ( ! empty( $this->post ) ) then
--                         $GLOBALS['post'] = $this->post;
--                         $this->setup_postdata( $this->post );
--                 end;
--         end;

--         --
--         -- Lazyload term meta for posts in the loop.
--         --
--         -- @since 4.4.0
--         -- @deprecated 4.5.0 See wp_queue_posts_for_term_meta_lazyload().
--         --
--         -- @param mixed $check
--         -- @param int   $term_id
--         -- @return mixed
--         --
--         public function lazyload_term_meta( $check, $term_id ) then
--                 _deprecated_function( __METHOD__, '4.5.0' );
--                 return $check;
--         end;

--         --
--         -- Lazyload comment meta for comments in the loop.
--         --
--         -- @since 4.4.0
--         -- @deprecated 4.5.0 See wp_queue_comments_for_comment_meta_lazyload().
--         --
--         -- @param mixed $check
--         -- @param int   $comment_id
--         -- @return mixed
--         --
--         public function lazyload_comment_meta( $check, $comment_id ) then
--                 _deprecated_function( __METHOD__, '4.5.0' );
--                 return $check;
--         end;
-- end;

end Class_Querys;
