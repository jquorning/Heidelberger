--
-- Post format functions.
--
-- @package WordPress
-- @subpackage Post
--

with Arrays;

package Inc_Post_Formats
is
   use Arrays;

-- --
-- -- Retrieve the format slug for a post
-- --
-- -- @since 3.1.0
-- --
-- -- @param int|WP_Post|null post Optional. Post ID or post object. Defaults to the current post in the loop.
-- -- @return string|false The format if successful. False otherwise.
-- --
-- function get_post_format( post = null ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return false;
--         end;

--         if ( ! post_type_supports( post.post_type, "post-formats" ) ) then
--                 return false;
--         end;

--         _format = get_the_terms( post.ID, "post_format" );

--         if ( empty( _format ) ) then
--                 return false;
--         end;

--         format = reset( _format );

--         return str_replace( "post-format-", "", format.slug );
-- end;

-- --
-- -- Check if a post has any of the given formats, or any format.
-- --
-- -- @since 3.1.0
-- --
-- -- @param string|string[]  format Optional. The format or formats to check.
-- -- @param WP_Post|int|null post   Optional. The post to check. Defaults to the current post in the loop.
-- -- @return bool True if the post has any of the given formats (or any format, if no format specified),
-- --              false otherwise.
-- --
-- function has_post_format( format = array(), post = null ) then
--         prefixed = array();

--         if ( format ) then
--                 foreach ( (array) format as single ) then
--                         prefixed[] = "post-format-" . sanitize_key( single );
--                 end;
--         end;

--         return has_term( prefixed, "post_format", post );
-- end;

-- --
-- -- Assign a format to a post
-- --
-- -- @since 3.1.0
-- --
-- -- @param int|object post   The post for which to assign a format.
-- -- @param string     format A format to assign. Use an empty string or array to remove all formats from the post.
-- -- @return array|WP_Error|false Array of affected term IDs on success. WP_Error on error.
-- --
-- function set_post_format( post, format ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return new WP_Error( "invalid_post", __( "Invalid post." ) );
--         end;

--         if ( ! empty( format ) ) then
--                 format = sanitize_key( format );
--                 if ( "standard" === format || ! in_array( format, get_post_format_slugs(), true ) ) then
--                         format = "";
--                 end; else then
--                         format = "post-format-" . format;
--                 end;
--         end;

--         return wp_set_post_terms( post.ID, format, "post_format" );
-- end;

   --
   -- Returns an array of post format slugs to their translated and pretty display
   -- versions
   --
   -- @since 3.1.0
   --
   -- @return string[] Array of post format labels keyed by format slug.
   --
   function Get_Post_Format_Strings
            return Array_Type;

   --
   -- Retrieves the array of post format slugs.
   --
   -- @since 3.1.0
   --
   -- @return string[] The array of post format slugs as both keys and values.
   --
   function Get_Post_Format_Slugs
            return List_Type;

-- --
-- -- Returns a pretty, translated version of a post format slug
-- --
-- -- @since 3.1.0
-- --
-- -- @param string slug A post format slug.
-- -- @return string The translated post format name.
-- --
-- function get_post_format_string( slug ) then
--         strings = get_post_format_strings();
--         if ( ! slug ) then
--                 return strings["standard"];
--         end; else then
--                 return ( isset( strings[ slug ] ) ) ? strings[ slug ] : "";
--         end;
-- end;

-- --
-- -- Returns a link to a post format index.
-- --
-- -- @since 3.1.0
-- --
-- -- @param string format The post format slug.
-- -- @return string|WP_Error|false The post format term link.
-- --
-- function get_post_format_link( format ) then
--         term = get_term_by( "slug", "post-format-" . format, "post_format" );
--         if ( ! term || is_wp_error( term ) ) then
--                 return false;
--         end;
--         return get_term_link( term );
-- end;

-- --
-- -- Filters the request to allow for the format prefix.
-- --
-- -- @access private
-- -- @since 3.1.0
-- --
-- -- @param array qvs
-- -- @return array
-- --
-- function _post_format_request( qvs ) then
--         if ( ! isset( qvs["post_format"] ) ) then
--                 return qvs;
--         end;
--         slugs = get_post_format_slugs();
--         if ( isset( slugs[ qvs["post_format"] ] ) ) then
--                 qvs["post_format"] = "post-format-" . slugs[ qvs["post_format"] ];
--         end;
--         tax = get_taxonomy( "post_format" );
--         if ( ! is_admin() ) then
--                 qvs["post_type"] = tax.object_type;
--         end;
--         return qvs;
-- end;

-- --
-- -- Filters the post format term link to remove the format prefix.
-- --
-- -- @access private
-- -- @since 3.1.0
-- --
-- -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
-- --
-- -- @param string  link
-- -- @param WP_Term term
-- -- @param string  taxonomy
-- -- @return string
-- --
-- function _post_format_link( link, term, taxonomy ) then
--         global wp_rewrite;
--         if ( "post_format" !== taxonomy ) then
--                 return link;
--         end;
--         if ( wp_rewrite.get_extra_permastruct( taxonomy ) ) then
--                 return str_replace( "/thenterm.slugend;", "/" . str_replace( "post-format-", "", term.slug ), link );
--         end; else then
--                 link = remove_query_arg( "post_format", link );
--                 return add_query_arg( "post_format", str_replace( "post-format-", "", term.slug ), link );
--         end;
-- end;

-- --
-- -- Remove the post format prefix from the name property of the term object created by get_term().
-- --
-- -- @access private
-- -- @since 3.1.0
-- --
-- -- @param object term
-- -- @return object
-- --
-- function _post_format_get_term( term ) then
--         if ( isset( term.slug ) ) then
--                 term.name = get_post_format_string( str_replace( "post-format-", "", term.slug ) );
--         end;
--         return term;
-- end;

-- --
-- -- Remove the post format prefix from the name property of the term objects created by get_terms().
-- --
-- -- @access private
-- -- @since 3.1.0
-- --
-- -- @param array        terms
-- -- @param string|array taxonomies
-- -- @param array        args
-- -- @return array
-- --
-- function _post_format_get_terms( terms, taxonomies, args ) then
--         if ( in_array( "post_format", (array) taxonomies, true ) ) then
--                 if ( isset( args["fields"] ) && "names" === args["fields"] ) then
--                         foreach ( terms as order => name ) then
--                                 terms[ order ] = get_post_format_string( str_replace( "post-format-", "", name ) );
--                         end;
--                 end; else then
--                         foreach ( (array) terms as order => term ) then
--                                 if ( isset( term.taxonomy ) && "post_format" === term.taxonomy ) then
--                                         terms[ order ].name = get_post_format_string( str_replace( "post-format-", "", term.slug ) );
--                                 end;
--                         end;
--                 end;
--         end;
--         return terms;
-- end;

-- --
-- -- Remove the post format prefix from the name property of the term objects created by wp_get_object_terms().
-- --
-- -- @access private
-- -- @since 3.1.0
-- --
-- -- @param array terms
-- -- @return array
-- --
-- function _post_format_wp_get_object_terms( terms ) then
--         foreach ( (array) terms as order => term ) then
--                 if ( isset( term.taxonomy ) && "post_format" === term.taxonomy ) then
--                         terms[ order ].name = get_post_format_string( str_replace( "post-format-", "", term.slug ) );
--                 end;
--         end;
--         return terms;
-- end;

end Inc_Post_Formats;
