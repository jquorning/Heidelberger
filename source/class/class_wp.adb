--
-- WordPress environment setup class.
--
-- @package WordPress
-- @since 2.0.0
--

with Php.Arrays;
with Php.HTML;
with Php.Strings;

with Globals;

with Class_Posts;
with Class_Users;

with Inc_Pluggables;
with Inc_Plugins;
with Inc_Querys;

package body Class_Wp
is

--         --
--         -- Adds a query variable to the list of public query variables.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string $qv Query variable name.
--         --
--         public function add_query_var( $qv ) then
--                 if ( ! in_array( $qv, $this->public_query_vars, true ) ) then
--                         $this->public_query_vars[] = $qv;
--                 end;
--         end;

--         --
--         -- Removes a query variable from a list of public query variables.
--         --
--         -- @since 4.5.0
--         --
--         -- @param string $name Query variable name.
--         --
--         public function remove_query_var( $name ) then
--                 $this->public_query_vars = array_diff( $this->public_query_vars, array( $name ) );
--         end;

--         --
--         -- Sets the value of a query variable.
--         --
--         -- @since 2.3.0
--         --
--         -- @param string $key   Query variable name.
--         -- @param mixed  $value Query variable value.
--         --
--         public function set_query_var( $key, $value ) then
--                 $this->query_vars[ $key ] = $value;
--         end;

   -------------------
   -- Parse_Request --
   -------------------

   function Parse_Request (This             : Wp_Class;
                           Extra_Query_Vars : Array_Type) --  = ""
                           return Boolean
   is (raise Program_Error with "not implemented");
--                 global $wp_rewrite;

--                 --
--                 -- Filters whether to parse the request.
--                 --
--                 -- @since 3.5.0
--                 --
--                 -- @param bool         $bool             Whether or not to parse the request. Default true.
--                 -- @param WP           $wp               Current WordPress environment instance.
--                 -- @param array|string $extra_query_vars Extra passed query variables.
--                 --
--                 if ( ! apply_filters( "do_parse_request", true, $this, $extra_query_vars ) ) then
--                         return false;
--                 end;

--                 $this->query_vars     = array();
--                 $post_type_query_vars = array();

--                 if ( is_array( $extra_query_vars ) ) then
--                         $this->extra_query_vars = & $extra_query_vars;
--                 end; elseif ( ! empty( $extra_query_vars ) ) then
--                         parse_str( $extra_query_vars, $this->extra_query_vars );
--                 end;
--                 // Process PATH_INFO, REQUEST_URI, and 404 for permalinks.

--                 // Fetch the rewrite rules.
--                 $rewrite = $wp_rewrite->wp_rewrite_rules();

--                 if ( ! empty( $rewrite ) ) then
--                         // If we match a rewrite rule, this will be cleared.
--                         $error               = "404";
--                         $this->did_permalink = true;

--                         $pathinfo         = isset( $_SERVER["PATH_INFO"] ) ? $_SERVER["PATH_INFO"] : "";
--                         list( $pathinfo ) = explode( "?", $pathinfo );
--                         $pathinfo         = str_replace( "%", "%25", $pathinfo );

--                         list( $req_uri ) = explode( "?", $_SERVER["REQUEST_URI"] );
--                         $self            = $_SERVER["PHP_SELF"];

--                         $home_path       = parse_url( home_url(), PHP_URL_PATH );
--                         $home_path_regex = "";
--                         if ( is_string( $home_path ) && "" !== $home_path ) then
--                                 $home_path       = trim( $home_path, "/" );
--                                 $home_path_regex = sprintf( "|^%s|i", preg_quote( $home_path, "|" ) );
--                         end;

--                         /*
--                         -- Trim path info from the end and the leading home path from the front.
--                         -- For path info requests, this leaves us with the requesting filename, if any.
--                         -- For 404 requests, this leaves us with the requested permalink.
--                         --
--                         $req_uri  = str_replace( $pathinfo, "", $req_uri );
--                         $req_uri  = trim( $req_uri, "/" );
--                         $pathinfo = trim( $pathinfo, "/" );
--                         $self     = trim( $self, "/" );

--                         if ( ! empty( $home_path_regex ) ) then
--                                 $req_uri  = preg_replace( $home_path_regex, "", $req_uri );
--                                 $req_uri  = trim( $req_uri, "/" );
--                                 $pathinfo = preg_replace( $home_path_regex, "", $pathinfo );
--                                 $pathinfo = trim( $pathinfo, "/" );
--                                 $self     = preg_replace( $home_path_regex, "", $self );
--                                 $self     = trim( $self, "/" );
--                         end;

--                         // The requested permalink is in $pathinfo for path info requests and
--                         // $req_uri for other requests.
--                         if ( ! empty( $pathinfo ) && ! preg_match( "|^.*" . $wp_rewrite->index . "$|", $pathinfo ) ) then
--                                 $requested_path = $pathinfo;
--                         end; else then
--                                 // If the request uri is the index, blank it out so that we don"t try to match it against a rule.
--                                 if ( $req_uri == $wp_rewrite->index ) then
--                                         $req_uri = "";
--                                 end;
--                                 $requested_path = $req_uri;
--                         end;
--                         $requested_file = $req_uri;

--                         $this->request = $requested_path;

--                         // Look for matches.
--                         $request_match = $requested_path;
--                         if ( empty( $request_match ) ) then
--                                 // An empty request could only match against ^$ regex.
--                                 if ( isset( $rewrite["$"] ) ) then
--                                         $this->matched_rule = "$";
--                                         $query              = $rewrite["$"];
--                                         $matches            = array( "" );
--                                 end;
--                         end; else then
--                                 foreach ( (array) $rewrite as $match => $query ) then
--                                         // If the requested file is the anchor of the match, prepend it to the path info.
--                                         if ( ! empty( $requested_file ) && strpos( $match, $requested_file ) === 0 && $requested_file != $requested_path ) then
--                                                 $request_match = $requested_file . "/" . $requested_path;
--                                         end;

--                                         if ( preg_match( "#^$match#", $request_match, $matches ) ||
--                                                 preg_match( "#^$match#", urldecode( $request_match ), $matches ) ) then

--                                                 if ( $wp_rewrite->use_verbose_page_rules && preg_match( "/pagename=\$matches\[([0-9]+)\]/", $query, $varmatch ) ) then
--                                                         // This is a verbose page match, let"s check to be sure about it.
--                                                         $page = get_page_by_path( $matches[ $varmatch[1] ] );
--                                                         if ( ! $page ) then
--                                                                 continue;
--                                                         end;

--                                                         $post_status_obj = get_post_status_object( $page->post_status );
--                                                         if ( ! $post_status_obj->public && ! $post_status_obj->protected
--                                                                 && ! $post_status_obj->private && $post_status_obj->exclude_from_search ) then
--                                                                 continue;
--                                                         end;
--                                                 end;

--                                                 // Got a match.
--                                                 $this->matched_rule = $match;
--                                                 break;
--                                         end;
--                                 end;
--                         end;

--                         if ( ! empty( $this->matched_rule ) ) then
--                                 // Trim the query of everything up to the "?".
--                                 $query = preg_replace( "!^.+\?!", "", $query );

--                                 // Substitute the substring matches into the query.
--                                 $query = addslashes( WP_MatchesMapRegex::apply( $query, $matches ) );

--                                 $this->matched_query = $query;

--                                 // Parse the query.
--                                 parse_str( $query, $perma_query_vars );

--                                 // If we"re processing a 404 request, clear the error var since we found something.
--                                 if ( "404" == $error ) then
--                                         unset( $error, $_GET["error"] );
--                                 end;
--                         end;

--                         // If req_uri is empty or if it is a request for ourself, unset error.
--                         if ( empty( $requested_path ) || $requested_file == $self || strpos( $_SERVER["PHP_SELF"], "wp-admin/" ) !== false ) then
--                                 unset( $error, $_GET["error"] );

--                                 if ( isset( $perma_query_vars ) && strpos( $_SERVER["PHP_SELF"], "wp-admin/" ) !== false ) then
--                                         unset( $perma_query_vars );
--                                 end;

--                                 $this->did_permalink = false;
--                         end;
--                 end;

--                 --
--                 -- Filters the query variables allowed before processing.
--                 --
--                 -- Allows (publicly allowed) query vars to be added, removed, or changed prior
--                 -- to executing the query. Needed to allow custom rewrite rules using your own arguments
--                 -- to work, or any other custom query variables you want to be publicly available.
--                 --
--                 -- @since 1.5.0
--                 --
--                 -- @param string[] $public_query_vars The array of allowed query variable names.
--                 --
--                 $this->public_query_vars = apply_filters( "query_vars", $this->public_query_vars );

--                 foreach ( get_post_types( array(), "objects" ) as $post_type => $t ) then
--                         if ( is_post_type_viewable( $t ) && $t->query_var ) then
--                                 $post_type_query_vars[ $t->query_var ] = $post_type;
--                         end;
--                 end;

--                 foreach ( $this->public_query_vars as $wpvar ) then
--                         if ( isset( $this->extra_query_vars[ $wpvar ] ) ) then
--                                 $this->query_vars[ $wpvar ] = $this->extra_query_vars[ $wpvar ];
--                         end; elseif ( isset( $_GET[ $wpvar ] ) && isset( $_POST[ $wpvar ] ) && $_GET[ $wpvar ] !== $_POST[ $wpvar ] ) then
--                                 wp_die( __( "A variable mismatch has been detected." ), __( "Sorry, you are not allowed to view this item." ), 400 );
--                         end; elseif ( isset( $_POST[ $wpvar ] ) ) then
--                                 $this->query_vars[ $wpvar ] = $_POST[ $wpvar ];
--                         end; elseif ( isset( $_GET[ $wpvar ] ) ) then
--                                 $this->query_vars[ $wpvar ] = $_GET[ $wpvar ];
--                         end; elseif ( isset( $perma_query_vars[ $wpvar ] ) ) then
--                                 $this->query_vars[ $wpvar ] = $perma_query_vars[ $wpvar ];
--                         end;

--                         if ( ! empty( $this->query_vars[ $wpvar ] ) ) then
--                                 if ( ! is_array( $this->query_vars[ $wpvar ] ) ) then
--                                         $this->query_vars[ $wpvar ] = (string) $this->query_vars[ $wpvar ];
--                                 end; else then
--                                         foreach ( $this->query_vars[ $wpvar ] as $vkey => $v ) then
--                                                 if ( is_scalar( $v ) ) then
--                                                         $this->query_vars[ $wpvar ][ $vkey ] = (string) $v;
--                                                 end;
--                                         end;
--                                 end;

--                                 if ( isset( $post_type_query_vars[ $wpvar ] ) ) then
--                                         $this->query_vars["post_type"] = $post_type_query_vars[ $wpvar ];
--                                         $this->query_vars["name"]      = $this->query_vars[ $wpvar ];
--                                 end;
--                         end;
--                 end;

--                 // Convert urldecoded spaces back into "+".
--                 foreach ( get_taxonomies( array(), "objects" ) as $taxonomy => $t ) then
--                         if ( $t->query_var && isset( $this->query_vars[ $t->query_var ] ) ) then
--                                 $this->query_vars[ $t->query_var ] = str_replace( " ", "+", $this->query_vars[ $t->query_var ] );
--                         end;
--                 end;

--                 // Don"t allow non-publicly queryable taxonomies to be queried from the front end.
--                 if ( ! is_admin() ) then
--                         foreach ( get_taxonomies( array( "publicly_queryable" => false ), "objects" ) as $taxonomy => $t ) then
--                                 /*
--                                 -- Disallow when set to the "taxonomy" query var.
--                                 -- Non-publicly queryable taxonomies cannot register custom query vars. See register_taxonomy().
--                                 --
--                                 if ( isset( $this->query_vars["taxonomy"] ) && $taxonomy === $this->query_vars["taxonomy"] ) then
--                                         unset( $this->query_vars["taxonomy"], $this->query_vars["term"] );
--                                 end;
--                         end;
--                 end;

--                 // Limit publicly queried post_types to those that are "publicly_queryable".
--                 if ( isset( $this->query_vars["post_type"] ) ) then
--                         $queryable_post_types = get_post_types( array( "publicly_queryable" => true ) );
--                         if ( ! is_array( $this->query_vars["post_type"] ) ) then
--                                 if ( ! in_array( $this->query_vars["post_type"], $queryable_post_types, true ) ) then
--                                         unset( $this->query_vars["post_type"] );
--                                 end;
--                         end; else then
--                                 $this->query_vars["post_type"] = array_intersect( $this->query_vars["post_type"], $queryable_post_types );
--                         end;
--                 end;

--                 // Resolve conflicts between posts with numeric slugs and date archive queries.
--                 $this->query_vars = wp_resolve_numeric_slug_conflicts( $this->query_vars );

--                 foreach ( (array) $this->private_query_vars as $var ) then
--                         if ( isset( $this->extra_query_vars[ $var ] ) ) then
--                                 $this->query_vars[ $var ] = $this->extra_query_vars[ $var ];
--                         end;
--                 end;

--                 if ( isset( $error ) ) then
--                         $this->query_vars["error"] = $error;
--                 end;

--                 --
--                 -- Filters the array of parsed query variables.
--                 --
--                 -- @since 2.1.0
--                 --
--                 -- @param array $query_vars The array of requested query variables.
--                 --
--                 $this->query_vars = apply_filters( "request", $this->query_vars );

--                 --
--                 -- Fires once all query variables for the current request have been parsed.
--                 --
--                 -- @since 2.1.0
--                 --
--                 -- @param WP $wp Current WordPress environment instance (passed by reference).
--                 --
--                 do_action_ref_array( "parse_request", array( &$this ) );

--                 return true;
--         end;

   ------------------
   -- Send_Headers --
   ------------------

   procedure Send_Headers (This : Wp_Class)
   is
   begin
      raise Program_Error with "not implemented";
   end Send_Headers;
--                 global $wp_query;

--                 $headers       = array();
--                 $status        = null;
--                 $exit_required = false;
--                 $date_format   = "D, d M Y H:i:s";

--                 if ( is_user_logged_in() ) then
--                         $headers = array_merge( $headers, wp_get_nocache_headers() );
--                 end; elseif ( ! empty( $_GET["unapproved"] ) && ! empty( $_GET["moderation-hash"] ) ) then
--                         // Unmoderated comments are only visible for 10 minutes via the moderation hash.
--                         $expires = 10-- MINUTE_IN_SECONDS;

--                         $headers["Expires"]       = gmdate( $date_format, time() + $expires );
--                         $headers["Cache-Control"] = sprintf(
--                                 "max-age=%d, must-revalidate",
--                                 $expires
--                         );
--                 end;
--                 if ( ! empty( $this->query_vars["error"] ) ) then
--                         $status = (int) $this->query_vars["error"];
--                         if ( 404 === $status ) then
--                                 if ( ! is_user_logged_in() ) then
--                                         $headers = array_merge( $headers, wp_get_nocache_headers() );
--                                 end;
--                                 $headers["Content-Type"] = get_option( "html_type" ) . "; charset=" . get_option( "blog_charset" );
--                         end; elseif ( in_array( $status, array( 403, 500, 502, 503 ), true ) ) then
--                                 $exit_required = true;
--                         end;
--                 end; elseif ( empty( $this->query_vars["feed"] ) ) then
--                         $headers["Content-Type"] = get_option( "html_type" ) . "; charset=" . get_option( "blog_charset" );
--                 end; else then
--                         // Set the correct content type for feeds.
--                         $type = $this->query_vars["feed"];
--                         if ( "feed" === $this->query_vars["feed"] ) then
--                                 $type = get_default_feed();
--                         end;
--                         $headers["Content-Type"] = feed_content_type( $type ) . "; charset=" . get_option( "blog_charset" );

--                         // We"re showing a feed, so WP is indeed the only thing that last changed.
--                         if ( ! empty( $this->query_vars["withcomments"] )
--                                 || false !== strpos( $this->query_vars["feed"], "comments-" )
--                                 || ( empty( $this->query_vars["withoutcomments"] )
--                                         && ( ! empty( $this->query_vars["p"] )
--                                                 || ! empty( $this->query_vars["name"] )
--                                                 || ! empty( $this->query_vars["page_id"] )
--                                                 || ! empty( $this->query_vars["pagename"] )
--                                                 || ! empty( $this->query_vars["attachment"] )
--                                                 || ! empty( $this->query_vars["attachment_id"] )
--                                         )
--                                 )
--                         ) then
--                                 $wp_last_modified_post    = mysql2date( $date_format, get_lastpostmodified( "GMT" ), false );
--                                 $wp_last_modified_comment = mysql2date( $date_format, get_lastcommentmodified( "GMT" ), false );
--                                 if ( strtotime( $wp_last_modified_post ) > strtotime( $wp_last_modified_comment ) ) then
--                                         $wp_last_modified = $wp_last_modified_post;
--                                 end; else then
--                                         $wp_last_modified = $wp_last_modified_comment;
--                                 end;
--                         end; else then
--                                 $wp_last_modified = mysql2date( $date_format, get_lastpostmodified( "GMT" ), false );
--                         end;

--                         if ( ! $wp_last_modified ) then
--                                 $wp_last_modified = gmdate( $date_format );
--                         end;

--                         $wp_last_modified .= " GMT";

--                         $wp_etag                  = """ . md5( $wp_last_modified ) . """;
--                         $headers["Last-Modified"] = $wp_last_modified;
--                         $headers["ETag"]          = $wp_etag;

--                         // Support for conditional GET.
--                         if ( isset( $_SERVER["HTTP_IF_NONE_MATCH"] ) ) then
--                                 $client_etag = wp_unslash( $_SERVER["HTTP_IF_NONE_MATCH"] );
--                         end; else then
--                                 $client_etag = false;
--                         end;

--                         $client_last_modified = empty( $_SERVER["HTTP_IF_MODIFIED_SINCE"] ) ? "" : trim( $_SERVER["HTTP_IF_MODIFIED_SINCE"] );
--                         // If string is empty, return 0. If not, attempt to parse into a timestamp.
--                         $client_modified_timestamp = $client_last_modified ? strtotime( $client_last_modified ) : 0;

--                         // Make a timestamp for our most recent modification..
--                         $wp_modified_timestamp = strtotime( $wp_last_modified );

--                         if ( ( $client_last_modified && $client_etag ) ?
--                                         ( ( $client_modified_timestamp >= $wp_modified_timestamp ) && ( $client_etag == $wp_etag ) ) :
--                                         ( ( $client_modified_timestamp >= $wp_modified_timestamp ) || ( $client_etag == $wp_etag ) ) ) then
--                                 $status        = 304;
--                                 $exit_required = true;
--                         end;
--                 end;

--                 if ( is_singular() ) then
--                         $post = isset( $wp_query->post ) ? $wp_query->post : null;

--                         // Only set X-Pingback for single posts that allow pings.
--                         if ( $post && pings_open( $post ) ) then
--                                 $headers["X-Pingback"] = get_bloginfo( "pingback_url", "display" );
--                         end;
--                 end;

--                 --
--                 -- Filters the HTTP headers before they"re sent to the browser.
--                 --
--                 -- @since 2.8.0
--                 --
--                 -- @param string[] $headers Associative array of headers to be sent.
--                 -- @param WP       $wp      Current WordPress environment instance.
--                 --
--                 $headers = apply_filters( "wp_headers", $headers, $this );

--                 if ( ! empty( $status ) ) then
--                         status_header( $status );
--                 end;

--                 // If Last-Modified is set to false, it should not be sent (no-cache situation).
--                 if ( isset( $headers["Last-Modified"] ) && false === $headers["Last-Modified"] ) then
--                         unset( $headers["Last-Modified"] );

--                         if ( ! headers_sent() ) then
--                                 header_remove( "Last-Modified" );
--                         end;
--                 end;

--                 if ( ! headers_sent() ) then
--                         foreach ( (array) $headers as $name => $field_value ) then
--                                 header( "then$nameend;: then$field_valueend;" );
--                         end;
--                 end;

--                 if ( $exit_required ) then
--                         exit;
--                 end;

--                 --
--                 -- Fires once the requested HTTP headers for caching, content type, etc. have been sent.
--                 --
--                 -- @since 2.1.0
--                 --
--                 -- @param WP $wp Current WordPress environment instance (passed by reference).
--                 --
--                 do_action_ref_array( "send_headers", array( &$this ) );
--         end;

   ------------------------
   -- Build_Query_String --
   ------------------------

   procedure Build_Query_String (This : in out Wp_Class)
   is
      use Php.Arrays;
      use Php.HTML;
      use Php.Strings;
      use Inc_Plugins;
   begin
      This.Query_String := +"";

      for Wpvar of List_Type'(Array_Keys (This.Query_Vars)) loop
         if "" /= Get_As_String (This.Query_Vars, Wpvar) then

            Append (This.Query_String,
                    (if Strlen (-This.Query_String) < 1 then "" else "&"));

            if Kind_Of (Get (This.Query_Vars, Wpvar)) in Kind_Array then
               -- Discard non-scalars.
               goto Continue;
            end if;

            Append (This.Query_String,
                    Wpvar & "=" &
                    Raw_URL_Encode (Get_As_String (This.Query_Vars, Wpvar)));
         end if;
         << Continue >>
      end loop;

      if Has_Filter ("query_string") then
         -- Don't bother filtering and parsing if no plugins are hooked in.

         --
         -- Filters the query string before parsing.
         --
         -- @since 1.5.0
         -- @deprecated 2.1.0 Use {@see "query_vars"} or {@see "request"} filters
         -- instead.
         --
         -- @param string $query_string The query string to modify.
         --
         This.Query_String := +Apply_Filters_Deprecated (
           "query_string",
           [-This.Query_String],
           "2.1.0",
           "query_vars, request"
         );
         Parse_Str (-This.Query_String, This.Query_Vars);
      end if;
   end Build_Query_String;

   ----------------------
   -- Register_Globals --
   ----------------------

   procedure Register_Globals (This : Wp_Class)
   is
      use Globals;
      use Class_Posts;
      use Class_Users;
      use Inc_Pluggables;
      use Inc_Querys;

      function Isset (Post : Wp_Post)
                      return Boolean;

      function Isset (Post : Wp_Post)
                      return Boolean
      is
      begin
         return Post /= Null_Post;
      end Isset;
--                 global $wp_query;
   begin
      -- Extract updated query vars back into global namespace.
      for A in Global_Wp_Query.Query_Vars.Iterate loop -- (array)
         declare
            Key   : constant String     := Arrays.Key (A);
            Value : constant Multi_Type := Arrays.Element (A);
         begin
            Set (Globals.GLOBALS, Key, Value);
         end;
      end loop;

      Globals.Global_Query_String := This.Query_String;

      Globals.Global_Posts := Global_Wp_Query.Posts;

      Globals.Global_Post  := (if Isset (Global_Wp_Query.Post)
                               then Global_Wp_Query.Post else Null_Post);

      Globals.Global_Request := Global_Wp_Query.Request;

      if
        Global_Wp_Query.Is_Single or else
        Global_Wp_Query.Is_Page
      then
         Globals.Global_More   := 1;
         Globals.Global_Single := 1;
      end if;

      if Global_Wp_Query.Is_Author then
         Globals.Global_Authordata :=
           Get_Userdata (User_Id_Type (Get_Queried_Object_Id));
      end if;
   end Register_Globals;

   ----------
   -- Init --
   ----------

   procedure Init (This : Wp_Class)
   is
      pragma Unreferenced (This);
      use Class_Users;
      use Inc_Pluggables;

      Unused : constant Wp_User := Wp_Get_Current_User;
   begin
      null;
   end Init;

   -----------------
   -- Query_Posts --
   -----------------

   procedure Query_Posts (This : in out Wp_Class)
   is
      use Inc_Querys;
--    global $wp_the_query;
   begin
      This.Build_Query_String;
      Global_Wp_The_Query.Query (This.Query_Vars);
   end Query_Posts;

   ----------------
   -- Handle_404 --
   ----------------

   procedure Handle_404 (This : Wp_Class)
   is
   begin
      raise Program_Error with "not implemented";
   end Handle_404;
--                 global $wp_query;

--                 --
--                 -- Filters whether to short-circuit default header status handling.
--                 --
--                 -- Returning a non-false value from the filter will short-circuit the handling
--                 -- and return early.
--                 --
--                 -- @since 4.5.0
--                 --
--                 -- @param bool     $preempt  Whether to short-circuit default header status handling. Default false.
--                 -- @param WP_Query $wp_query WordPress Query object.
--                 --
--                 if ( false !== apply_filters( "pre_handle_404", false, $wp_query ) ) then
--                         return;
--                 end;

--                 // If we"ve already issued a 404, bail.
--                 if ( is_404() ) then
--                         return;
--                 end;

--                 $set_404 = true;

--                 // Never 404 for the admin, robots, or favicon.
--                 if ( is_admin() || is_robots() || is_favicon() ) then
--                         $set_404 = false;

--                         // If posts were found, check for paged content.
--                 end; elseif ( $wp_query->posts ) then
--                         $content_found = true;

--                         if ( is_singular() ) then
--                                 $post = isset( $wp_query->post ) ? $wp_query->post : null;
--                                 $next = "<!--nextpage-->";

--                                 // Check for paged content that exceeds the max number of pages.
--                                 if ( $post && ! empty( $this->query_vars["page"] ) ) then
--                                         // Check if content is actually intended to be paged.
--                                         if ( false !== strpos( $post->post_content, $next ) ) then
--                                                 $page          = trim( $this->query_vars["page"], "/" );
--                                                 $content_found = (int) $page <= ( substr_count( $post->post_content, $next ) + 1 );
--                                         end; else then
--                                                 $content_found = false;
--                                         end;
--                                 end;
--                         end;

--                         // The posts page does not support the <!--nextpage--> pagination.
--                         if ( $wp_query->is_posts_page && ! empty( $this->query_vars["page"] ) ) then
--                                 $content_found = false;
--                         end;

--                         if ( $content_found ) then
--                                 $set_404 = false;
--                         end;

--                         // We will 404 for paged queries, as no posts were found.
--                 end; elseif ( ! is_paged() ) then
--                         $author = get_query_var( "author" );

--                         // Don"t 404 for authors without posts as long as they matched an author on this site.
--                         if ( is_author() && is_numeric( $author ) && $author > 0 && is_user_member_of_blog( $author )
--                                 // Don"t 404 for these queries if they matched an object.
--                                 || ( is_tag() || is_category() || is_tax() || is_post_type_archive() ) && get_queried_object()
--                                 // Don"t 404 for these queries either.
--                                 || is_home() || is_search() || is_feed()
--                         ) then
--                                 $set_404 = false;
--                         end;
--                 end;

--                 if ( $set_404 ) then
--                         // Guess it"s time to 404.
--                         $wp_query->set_404();
--                         status_header( 404 );
--                         nocache_headers();
--                 end; else then
--                         status_header( 200 );
--                 end;
--         end;

   ----------
   -- Main --
   ----------

   procedure Main (This       : in out Wp_Class;
                   Query_Args : Array_Type)
   is
   begin
      This.Init;

      declare
         Parsed : constant Boolean :=
           This.Parse_Request (Query_Args);
      begin
         if Parsed then
            This.Query_Posts;
            This.Handle_404;
            This.Register_Globals;
         end if;

         This.Send_Headers;

         --
         -- Fires once the WordPress environment has been set up.
         --
         -- @since 2.1.0
         --
         -- @param WP $wp Current WordPress environment instance (passed by reference).
         --
--       Do_Action_Ref_Array ("wp", This); -- XXX -- array( &$this ) );
      end;
   end Main;

end Class_Wp;
