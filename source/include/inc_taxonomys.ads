--
-- Core Taxonomy API
--
-- @package WordPress
-- @subpackage Taxonomy
--

with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Taxonomy;

package Inc_Taxonomys
is
   use Ada.Strings.Unbounded;
   use Arrays;
--
-- Returns the names or objects of the taxonomies which are registered for the requested object or object type,
-- such as a post object or post type name.
--
-- Example:
--
--     taxonomies = get_object_taxonomies ("post");
--
-- This results in:
--
--     Array ("category", "post_tag")
--
-- @since 2.3.0
--
-- @global WP_Taxonomy() wp_taxonomies The registered taxonomies.
--
-- @param string|string()|WP_Post object Name of the type of taxonomy object, or an object (row from posts)
-- @param string                  output Optional. The type of output to return in the array. Accepts either
--                                        "names" or "objects". Default "names".
-- @return string()|WP_Taxonomy() The names or objects of all taxonomies of `object_type`.
--
-- function get_object_taxonomies (object, output = "names") then
   package Taxonomy_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Inc_Class_Wp_Taxonomy.Wp_Taxonomy,
                              "="          => Inc_Class_Wp_Taxonomy."=");

   subtype Taxonomy_Array is Taxonomy_Vectors.Vector;
   Empty_Taxonomy_Array : constant Taxonomy_Array := Taxonomy_Vectors.Empty_Vector;

   function Get_Object_Taxonomies (Object : String;  -- Wp_Post;
                                   Output : String := "names")
                                   return Taxonomy_Array
                                   is (Empty_Taxonomy_Array);

--
-- Gets all term data from database by term ID.
--
-- The usage of the get_term function is to apply filters to a term object. It
-- is possible to get a term object from the database before applying the
-- filters.
--
-- term ID must be part of taxonomy, to get from the database. Failure, might
-- be able to be captured by the hooks. Failure would be the same value as wpdb
-- returns for the get_row method.
--
-- There are two hooks, one is specifically for each term, named "get_term", and
-- the second is for the taxonomy name, "term_taxonomy". Both hooks gets the
-- term object, and the taxonomy name as parameters. Both hooks are expected to
-- return a term object.
--
-- then@see "get_term"end; hook - Takes two parameters the term Object and the taxonomy name.
-- Must return term object. Used in get_term() as a catch-all filter for every
-- term.
--
-- then@see "get_taxonomy"end; hook - Takes two parameters the term Object and the taxonomy
-- name. Must return term object. taxonomy will be the taxonomy name, so for
-- example, if "category", it would be "get_category" as the filter name. Useful
-- for custom taxonomies or plugging into default taxonomies.
--
-- @todo Better formatting for DocBlock
--
-- @since 2.3.0
-- @since 4.4.0 Converted to return a WP_Term object if `output` is `OBJECT`.
--              The `taxonomy` parameter was made optional.
--
-- @see sanitize_term_field() The context param lists the available values for get_term_by() filter param.
--
-- @param int|WP_Term|object term     If integer, term data will be fetched from the database,
--                                     or from the cache if available.
--                                     If stdClass object (as in the results of a database query),
--                                     will apply filters and return a `WP_Term` object with the `term` data.
--                                     If `WP_Term`, will return `term`.
-- @param string             taxonomy Optional. Taxonomy name that `term` is part of.
-- @param string             output   Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
--                                     correspond to a WP_Term object, an associative array, or a numeric array,
--                                     respectively. Default OBJECT.
-- @param string             filter   Optional. How to sanitize term fields. Default "raw".
-- @return WP_Term|array|WP_Error|null WP_Term instance (or array) on success, depending on the `output` value.
--                                     WP_Error if `taxonomy` does not exist. Null for miscellaneous failure.
--
-- function get_term (term, taxonomy = "", output = OBJECT, filter = "raw") then

   function Get_Term (Term     : Integer; -- Inc_Class_Wp_Terms.Wp_Term;
                      Taxonomy : String := "";
                      Output   : String := "OBJECT";
                      Filter   : String := "raw")
                      return Inc_Class_Wp_Terms.Wp_Term;

--
-- Retrieves the taxonomy object of taxonomy.
--
-- The get_taxonomy function will first check that the parameter string given
-- is a taxonomy object and if it is, it will return it.
--
-- @since 2.3.0
--
-- @global WP_Taxonomy() wp_taxonomies The registered taxonomies.
--
-- @param string taxonomy Name of taxonomy object to return.
-- @return WP_Taxonomy|false The taxonomy object or false if taxonomy doesn"t exist.
--
   function Get_Taxonomy (Taxonomy : String)
                          return Inc_Class_Wp_Taxonomy.Wp_Taxonomy;

   function Get_Taxonomies (Args     : Array_Type := Empty_Array;
                            Output   : String     := "names";
                            Operator : String     := "and")
                            return Taxonomy_Array
                            is (Empty_Taxonomy_Array);

--
-- Retrieves the cached term objects for the given object ID.
--
-- Upstream functions (like get_the_terms() and is_object_in_term()) are
-- responsible for populating the object-term relationship cache. The current
-- function only fetches relationship data that is already in the cache.
--
-- @since 2.3.0
-- @since 4.7.0 Returns a `WP_Error` object if there's an error with
--              any of the matched terms.
--
-- @param int    $id       Term object ID, for example a post, comment, or user ID.
-- @param string $taxonomy Taxonomy name.
-- @return bool|WP_Term[]|WP_Error Array of `WP_Term` objects, if cached.
--                                 False if cache is empty for `$taxonomy` and `$id`.
--                                 WP_Error if get_term() returns an error object for any term.
--
-- function get_object_term_cache( $id, $taxonomy ) {

   -- package Term_Vectors is new
   --    Ada.Containers.Vectors (Index_Type   => Positive,
   --                            Element_Type => Inc_Class_Wp_Terms.Wp_Term,
   --                            "="          => Inc_Class_Wp_Terms."=");
   -- subtype Wp_Term_Array is Term_Vectors.Vector;
   -- Empty_Term_Array : constant Wp_Term_Array := Term_Vectors.Empty_Vector;

   function Get_Object_Term_Cache (Id       : Integer;
                                   Taxonomy : String)
                                   return Inc_Class_Wp_Terms.Wp_Term_Array;
--
-- Retrieves the terms in a given taxonomy or list of taxonomies.
--
-- You can fully inject any customizations to the query before it is sent, as
-- well as control the output with a filter.
--
-- The return type varies depending on the value passed to `args("fields")`. See
-- WP_Term_Query::get_terms() for details. In all cases, a `WP_Error` object will
-- be returned if an invalid taxonomy is requested.
--
-- The then@see "get_terms"end; filter will be called when the cache has the term and will
-- pass the found term along with the array of taxonomies and array of args.
-- This filter is also called before the array of terms is passed and will pass
-- the array of terms, along with the taxonomies and args.
--
-- The then@see "list_terms_exclusions"end; filter passes the compiled exclusions along with
-- the args.
--
-- The then@see "get_terms_orderby"end; filter passes the `ORDER BY` clause for the query
-- along with the args array.
--
-- Prior to 4.5.0, the first parameter of `get_terms()` was a taxonomy or list of taxonomies:
--
--     terms = get_terms ("post_tag", array(
--         "hide_empty" => false,
--    ));
--
-- Since 4.5.0, taxonomies should be passed via the "taxonomy" argument in the `args` array:
--
--     terms = get_terms (array(
--         "taxonomy" => "post_tag",
--         "hide_empty" => false,
--    ));
--
-- @since 2.3.0
-- @since 4.2.0 Introduced "name" and "childless" parameters.
-- @since 4.4.0 Introduced the ability to pass "term_id" as an alias of "id" for the `orderby` parameter.
--              Introduced the "meta_query" and "update_term_meta_cache" parameters. Converted to return
--              a list of WP_Term objects.
-- @since 4.5.0 Changed the function signature so that the `args` array can be provided as the first parameter.
--              Introduced "meta_key" and "meta_value" parameters. Introduced the ability to order results by metadata.
-- @since 4.8.0 Introduced "suppress_filter" parameter.
--
-- @internal The `deprecated` parameter is parsed for backward compatibility only.
--
-- @param array|string args       Optional. Array or string of arguments. See WP_Term_Query::__construct()
--                                 for information on accepted arguments. Default empty array.
-- @param array|string deprecated Optional. Argument array, when using the legacy function parameter format.
--                                 If present, this parameter will be interpreted as `args`, and the first
--                                 function parameter will be parsed as a taxonomy or array of taxonomies.
--                                 Default empty.
-- @return WP_Term()|int()|string()|string|WP_Error Array of terms, a count thereof as a numeric string,
--                                                  or WP_Error if any of the taxonomies do not exist.
--                                                  See the function description for more information.
--
-- function get_terms (args = array(), deprecated = "") then

   function Get_Terms (Args        : Array_Type := Empty_Array;
                       Deprectated : String     := "")
                       return Inc_Class_Wp_Terms.Wp_Term_Array
                       is (Inc_Class_Wp_Terms.Empty_Term_Array);

--
-- Retrieves the terms associated with the given object(s), in the supplied taxonomies.
--
-- @since 2.3.0
-- @since 4.2.0 Added support for 'taxonomy', 'parent', and 'term_taxonomy_id' values of `$orderby`.
--              Introduced `$parent` argument.
-- @since 4.4.0 Introduced `$meta_query` and `$update_term_meta_cache` arguments. When `$fields` is 'all' or
--              'all_with_object_id', an array of `WP_Term` objects will be returned.
-- @since 4.7.0 Refactored to use WP_Term_Query, and to support any WP_Term_Query arguments.
--
-- @param int|int[]       $object_ids The ID(s) of the object(s) to retrieve.
-- @param string|string[] $taxonomies The taxonomy names to retrieve terms from.
-- @param array|string    $args       See WP_Term_Query::__construct() for supported arguments.
-- @return WP_Term[]|int[]|string[]|string|WP_Error Array of terms, a count thereof as a numeric string,
--                                                  or WP_Error if any of the taxonomies do not exist.
--                                                  See WP_Term_Query::get_terms() for more information.
--
   function Wp_Get_Object_Terms (Object_Ids : Integer_Array;
                                 Taxonomies : Array_Type; -- String_Array;
                                 Args       : Array_Type := Empty_Array)
                                 return Inc_Class_Wp_Terms.Wp_Term_Array;

--
-- Adds any terms from the given IDs to the cache that do not already exist in cache.
--
-- @since 4.6.0
-- @since 6.1.0 This function is no longer marked as "private".
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param array term_ids          Array of term IDs.
-- @param bool  update_meta_cache Optional. Whether to update the meta cache. Default true.
--
-- function _prime_term_caches (term_ids, update_meta_cache = true) then

   procedure X_Prime_Term_Caches (Term_Ids         : Array_Type;
                                  Updat_Meta_Cache : Boolean := True) is null;

--
-- Determines if the given object type is associated with the given taxonomy.
--
-- @since 3.0.0
--
-- @param string $object_type Object type string.
-- @param string $taxonomy    Single taxonomy name.
-- @return bool True if object is associated with the taxonomy, otherwise false.
--
   function Is_Object_In_Taxonomy (Object_Type : String;
                                   Taxonomy    : String)
                                   return Boolean;
--
-- Determines whether the taxonomy name exists.
--
-- Formerly is_taxonomy(), introduced in 2.3.0.
--
-- For more information on this and similar theme functions, check out
-- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 3.0.0
--
-- @global WP_Taxonomy() wp_taxonomies The registered taxonomies.
--
-- @param string taxonomy Name of taxonomy object.
-- @return bool Whether the taxonomy exists.
--
   function Taxonomy_Exists (Taxonomy : String)
                             return Boolean is (True);

--
-- Enables or disables term counting.
--
-- @since 2.5.0
--
-- @param bool defer Optional. Enable if true, disable if false.
-- @return bool Whether term counting is enabled or disabled.
--
   function wp_defer_term_counting (defer : Boolean := False) -- = null
                                    return Boolean
                                    is (False);

end Inc_Taxonomys;
