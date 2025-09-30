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
   -- Taxonomy registration.
   --

   --
   -- Creates the initial taxonomies.
   --
   -- This function fires twice: in wp-settings.php before plugins are loaded (for
   -- backward compatibility reasons), and again on the {@see "init"} action. We must
   -- avoid registering rewrite rules before the {@see "init"} action.
   --
   -- @since 2.8.0
   -- @since 5.9.0 Added `"wp_template_part_area"` taxonomy.
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   procedure Create_Initial_Taxonomies;

   --
   -- Creates or modifies a taxonomy object.
   --
   -- Note: Do not use before the {@see "init"} hook.
   --
   -- A simple function for creating or modifying a taxonomy object based on
   -- the parameters given. If modifying an existing taxonomy object, note
   -- that the `object_type` value from the original registration will be
   -- overwritten.
   --
   -- @since 2.3.0
   -- @since 4.2.0 Introduced `show_in_quick_edit` argument.
   -- @since 4.4.0 The `show_ui` argument is now enforced on the term editing screen.
   -- @since 4.4.0 The `public` argument now controls whether the taxonomy can be queried on the front end.
   -- @since 4.5.0 Introduced `publicly_queryable` argument.
   -- @since 4.7.0 Introduced `show_in_rest`, "rest_base" and "rest_controller_class"
   --              arguments to register the taxonomy in REST API.
   -- @since 5.1.0 Introduced `meta_box_sanitize_cb` argument.
   -- @since 5.4.0 Added the registered taxonomy object as a return value.
   -- @since 5.5.0 Introduced `default_term` argument.
   -- @since 5.9.0 Introduced `rest_namespace` argument.
   --
   -- @global WP_Taxonomy() wp_taxonomies Registered taxonomies.
   --
   -- @param string       taxonomy    Taxonomy key, must not exceed 32 characters and may only contain lowercase alphanumeric
   --                                  characters, dashes, and underscores. See sanitize_key().
   -- @param array|string object_type Object type or array of object types with which the taxonomy should be associated.
   -- @param array|string args        {
   --     Optional. Array or query string of arguments for registering a taxonomy.
   --
   --     @type string()      labels                An array of labels for this taxonomy. By default, Tag labels are
   --                                                used for non-hierarchical taxonomies, and Category labels are used
   --                                                for hierarchical taxonomies. See accepted values in
   --                                                get_taxonomy_labels(). Default empty array.
   --     @type string        description           A short descriptive summary of what the taxonomy is for. Default empty.
   --     @type bool          public                Whether a taxonomy is intended for use publicly either via
   --                                                the admin interface or by front-end users. The default settings
   --                                                of `publicly_queryable`, `show_ui`, and `show_in_nav_menus`
   --                                                are inherited from `public`.
   --     @type bool          publicly_queryable    Whether the taxonomy is publicly queryable.
   --                                                If not set, the default is inherited from `public`
   --     @type bool          hierarchical          Whether the taxonomy is hierarchical. Default false.
   --     @type bool          show_ui               Whether to generate and allow a UI for managing terms in this taxonomy in
   --                                                the admin. If not set, the default is inherited from `public`
   --                                                (default true).
   --     @type bool          show_in_menu          Whether to show the taxonomy in the admin menu. If true, the taxonomy is
   --                                                shown as a submenu of the object type menu. If false, no menu is shown.
   --                                                `show_ui` must be true. If not set, default is inherited from `show_ui`
   --                                                (default true).
   --     @type bool          show_in_nav_menus     Makes this taxonomy available for selection in navigation menus. If not
   --                                                set, the default is inherited from `public` (default true).
   --     @type bool          show_in_rest          Whether to include the taxonomy in the REST API. Set this to true
   --                                                for the taxonomy to be available in the block editor.
   --     @type string        rest_base             To change the base url of REST API route. Default is taxonomy.
   --     @type string        rest_namespace        To change the namespace URL of REST API route. Default is wp/v2.
   --     @type string        rest_controller_class REST API Controller class name. Default is "WP_REST_Terms_Controller".
   --     @type bool          show_tagcloud         Whether to list the taxonomy in the Tag Cloud Widget controls. If not set,
   --                                                the default is inherited from `show_ui` (default true).
   --     @type bool          show_in_quick_edit    Whether to show the taxonomy in the quick/bulk edit panel. It not set,
   --                                                the default is inherited from `show_ui` (default true).
   --     @type bool          show_admin_column     Whether to display a column for the taxonomy on its post type listing
   --                                                screens. Default false.
   --     @type bool|callable meta_box_cb           Provide a callback function for the meta box display. If not set,
   --                                                post_categories_meta_box() is used for hierarchical taxonomies, and
   --                                                post_tags_meta_box() is used for non-hierarchical. If false, no meta
   --                                                box is shown.
   --     @type callable      meta_box_sanitize_cb  Callback function for sanitizing taxonomy data saved from a meta
   --                                                box. If no callback is defined, an appropriate one is determined
   --                                                based on the value of `meta_box_cb`.
   --     @type string()      capabilities {
   --         Array of capabilities for this taxonomy.
   --
   --         @type string manage_terms Default "manage_categories".
   --         @type string edit_terms   Default "manage_categories".
   --         @type string delete_terms Default "manage_categories".
   --         @type string assign_terms Default "edit_posts".
   --     }
   --     @type bool|array    rewrite {
   --         Triggers the handling of rewrites for this taxonomy. Default true, using taxonomy as slug. To prevent
   --         rewrite, set to false. To specify rewrite rules, an array can be passed with any of these keys:
   --
   --         @type string slug         Customize the permastruct slug. Default `taxonomy` key.
   --         @type bool   with_front   Should the permastruct be prepended with WP_Rewrite::front. Default true.
   --         @type bool   hierarchical Either hierarchical rewrite tag or not. Default false.
   --         @type int    ep_mask      Assign an endpoint mask. Default `EP_NONE`.
   --     }
   --     @type string|bool   query_var             Sets the query var key for this taxonomy. Default `taxonomy` key. If
   --                                                false, a taxonomy cannot be loaded at `?thenquery_varend;=thenterm_slugend;`. If a
   --                                                string, the query `?thenquery_varend;=thenterm_slugend;` will be valid.
   --     @type callable      update_count_callback Works much like a hook, in that it will be called when the count is
   --                                                updated. Default _update_post_term_count() for taxonomies attached
   --                                                to post types, which confirms that the objects are published before
   --                                                counting them. Default _update_generic_term_count() for taxonomies
   --                                                attached to other object types, such as users.
   --     @type string|array  default_term {
   --         Default term to be used for the taxonomy.
   --
   --         @type string name         Name of default term.
   --         @type string slug         Slug for default term. Default empty.
   --         @type string description  Description for default term. Default empty.
   --     }
   --     @type bool          sort                  Whether terms in this taxonomy should be sorted in the order they are
   --                                                provided to `wp_set_object_terms()`. Default null which equates to false.
   --     @type array         args                  Array of arguments to automatically use inside `wp_get_object_terms()`
   --                                                for this taxonomy.
   --     @type bool          _builtin              This taxonomy is a "built-in" taxonomy. INTERNAL USE ONLY!
   --                                                Default false.
   -- }
   -- @return WP_Taxonomy|WP_Error The registered taxonomy object on success, WP_Error object on failure.
   --
   function Register_Taxonomy (Taxonomy    : String;
                               Object_Type : List_Type; -- String;
                               Args        : Array_Type)
                               return Inc_Class_Wp_Taxonomy.Wp_Taxonomy;

   procedure Register_Taxonomy (Taxonomy    : String;
                                Object_Type : String;
                                Args        : Array_Type);

   procedure Register_Taxonomy (Taxonomy    : String;
                                Object_Type : List_Type;
                                Args        : Array_Type);

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
-- {@see "get_term"} hook - Takes two parameters the term Object and the taxonomy name.
-- Must return term object. Used in get_term() as a catch-all filter for every
-- term.
--
-- {@see "get_taxonomy"} hook - Takes two parameters the term Object and the taxonomy
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
-- Determines whether the taxonomy object is hierarchical.
--
-- Checks to make sure that the taxonomy is an object first. Then Gets the
-- object, and finally returns the hierarchical value in the object.
--
-- A false return value might also mean that the taxonomy does not exist.
--
-- For more information on this and similar theme functions, check out
-- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 2.3.0
--
-- @param string taxonomy Name of taxonomy object.
-- @return bool Whether the taxonomy is hierarchical.
--
   function Is_Taxonomy_Hierarchical (Taxonomy : String)
                                      return Boolean
                                      is (True);

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
   -- Counts how many terms are in taxonomy.
   --
   -- Default args is "hide_empty" which can be "hide_empty=true" or
   -- array("hide_empty" => true).
   --
   -- @since 2.3.0
   -- @since 5.6.0 Changed the function signature so that the `args` array can be
   --              provided as the first parameter.
   --
   -- @internal The `deprecated` parameter is parsed for backward compatibility only.
   --
   -- @param array|string args       Optional. Array or string of arguments. See
   --                                WP_Term_Query::__construct() for information on
   --                                accepted arguments. Default empty array.
   -- @param array|string deprecated Optional. Argument array, when using the legacy
   --                                function parameter format. If present, this
   --                                parameter will be interpreted as `args`, and the
   --                                first function parameter will be parsed as a
   --                                taxonomy or array of taxonomies. Default empty.
   -- @return string|WP_Error Numeric string containing the number of terms in that
   --                         taxonomy or WP_Error if the taxonomy does not exist.
   --
   function Wp_Count_Terms (Args       : Array_Type := Empty_Array;
                            Deprecated : Array_Type := Empty_Array) -- = "")
                            return Natural
                            is (1);

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
-- The {@see "get_terms"} filter will be called when the cache has the term and will
-- pass the found term along with the array of taxonomies and array of args.
-- This filter is also called before the array of terms is passed and will pass
-- the array of terms, along with the taxonomies and args.
--
-- The {@see "list_terms_exclusions"} filter passes the compiled exclusions along with
-- the args.
--
-- The {@see "get_terms_orderby"} filter passes the `ORDER BY` clause for the query
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
   -- Retrieves the terms associated with the given object(s), in the supplied
   -- taxonomies.
   --
   -- @since 2.3.0
   -- @since 4.2.0 Added support for 'taxonomy', 'parent', and 'term_taxonomy_id'
   --              values of `$orderby`. Introduced `$parent` argument.
   -- @since 4.4.0 Introduced `$meta_query` and `$update_term_meta_cache` arguments.
   --              When `$fields` is 'all' or 'all_with_object_id', an array of
   --              `WP_Term` objects will be returned.
   -- @since 4.7.0 Refactored to use WP_Term_Query, and to support any WP_Term_Query
   --              arguments.
   --
   -- @param int|int[]       $object_ids The ID(s) of the object(s) to retrieve.
   -- @param string|string[] $taxonomies The taxonomy names to retrieve terms from.
   -- @param array|string    $args       See WP_Term_Query::__construct() for
   --                                    supported arguments.
   -- @return WP_Term[]|int[]|string[]|string|WP_Error Array of terms, a count
   --                                                  thereof as a numeric string,
   --                                                  or WP_Error if any of the
   --                                                  taxonomies do not exist.
   --                                                  See WP_Term_Query::get_terms()
   --                                                  for more information.
   --
   function Wp_Get_Object_Terms (Object_Ids : Integer;
                                 Taxonomies : String;
                                 Args       : List_Type := Empty_List)
                                 return Array_Type
                                 -- Inc_Class_Wp_Terms.Wp_Term_Array;
                                 is (Empty_Array);

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
-- Updates term based on arguments provided.
--
-- The `args` will indiscriminately override all values with the same field name.
-- Care must be taken to not override important information need to update or
-- update will fail (or perhaps create a new term, neither would be acceptable).
--
-- Defaults will set "alias_of", "description", "parent", and "slug" if not
-- defined in `args` already.
--
-- "alias_of" will create a term group, if it doesn"t already exist, and
-- update it for the `term`.
--
-- If the "slug" argument in `args` is missing, then the "name" will be used.
-- If you set "slug" and it isn"t unique, then a WP_Error is returned.
-- If you don"t pass any slug, then a unique one will be created.
--
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int          term_id  The ID of the term.
-- @param string       taxonomy The taxonomy of the term.
-- @param array        args then
--     Optional. Array of arguments for updating a term.
--
--     @type string alias_of    Slug of the term to make this term an alias of.
--                               Default empty string. Accepts a term slug.
--     @type string description The term description. Default empty string.
--     @type int    parent      The id of the parent term. Default 0.
--     @type string slug        The term slug to use. Default empty string.
-- end;
-- @return array|WP_Error An array containing the `term_id` and `term_taxonomy_id`,
--                        WP_Error otherwise.
--
   function Wp_Update_Term (Term_Id  : Integer;
                            Taxonomy : String;
                            Args     : Array_Type := Empty_Array)
                            return Array_Type
                            is (Empty_Array);

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
   function Wp_Defer_Term_Counting (Defer : Boolean := False) -- = null
                                    return Boolean
                                    is (False);

--
-- Removes a term from the database.
--
-- If the term is a parent of other terms, then the children will be updated to
-- that term"s parent.
--
-- Metadata associated with the term will be deleted.
--
-- @since 2.3.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int          term     Term ID.
-- @param string       taxonomy Taxonomy name.
-- @param array|string args {
--     Optional. Array of arguments to override the default term ID. Default empty array.
--
--     @type int  default       The term ID to make the default term. This will only override
--                               the terms found if there is only one term found. Any other and
--                               the found terms are used.
--     @type bool force_default Optional. Whether to force the supplied term as default to be
--                               assigned even if the object was not going to be term-less.
--                               Default false.
-- }
-- @return bool|int|WP_Error True on success, false if term does not exist. Zero on attempted
--                           deletion of default Category. WP_Error if the taxonomy does not exist.
--
-- function wp_delete_term (term, taxonomy, args = array()) then
   procedure Wp_Delete_Term (Term     : Integer;
                             Taxonomy : String)
                             is null;
--
-- Adds a new term to the database.
--
-- A non-existent term is inserted in the following sequence:
-- 1. The term is added to the term table, then related to the taxonomy.
-- 2. If everything is correct, several actions are fired.
-- 3. The "term_id_filter" is evaluated.
-- 4. The term cache is cleaned.
-- 5. Several more actions are fired.
-- 6. An array is returned containing the `term_id` and `term_taxonomy_id`.
--
-- If the "slug" argument is not empty, then it is checked to see if the term
-- is invalid. If it is not a valid, existing term, it is added and the term_id
-- is given.
--
-- If the taxonomy is hierarchical, and the "parent" argument is not empty,
-- the term is inserted and the term_id will be given.
--
-- Error handling:
-- If `taxonomy` does not exist or `term` is empty,
-- a WP_Error object will be returned.
--
-- If the term already exists on the same hierarchical level,
-- or the term slug and name are not unique, a WP_Error object will be returned.
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @since 2.3.0
--
-- @param string       term     The term name to add.
-- @param string       taxonomy The taxonomy to which to add the term.
-- @param array|string args {
--     Optional. Array or query string of arguments for inserting a term.
--
--     @type string alias_of    Slug of the term to make this term an alias of.
--                               Default empty string. Accepts a term slug.
--     @type string description The term description. Default empty string.
--     @type int    parent      The id of the parent term. Default 0.
--     @type string slug        The term slug to use. Default empty string.
-- }
-- @return array|WP_Error {
--     An array of the new term data, WP_Error otherwise.
--
--     @type int        term_id          The new term ID.
--     @type int|string term_taxonomy_id The new term taxonomy ID. Can be a numeric string.
-- }
--
-- function wp_insert_term (term, taxonomy, args = array()) then
   function Wp_Insert_Term (Term     : String;
                            Taxonomy : String;
                            Args     : Array_Type := Empty_Array)
                            return Boolean
                            is (True);

--
-- Generates a permalink for a taxonomy term archive.
--
-- @since 2.5.0
--
-- @global WP_Rewrite wp_rewrite WordPress rewrite component.
--
-- @param WP_Term|int|string term     The term object, ID, or slug whose link will be retrieved.
-- @param string             taxonomy Optional. Taxonomy. Default empty.
-- @return string|WP_Error URL of the taxonomy term archive on success, WP_Error if term does not exist.
--
   function Get_Term_Link (Term     : Inc_Class_Wp_Terms.Wp_Term;
                           Taxonomy : String := "")
                           return String
                           is ("XXX-361");

--
-- Determines whether a term is publicly viewable.
--
-- A term is considered publicly viewable if its taxonomy is viewable.
--
-- @since 6.1.0
--
-- @param int|WP_Term term Term ID or term object.
-- @return bool Whether the term is publicly viewable.
--
   function Is_Term_Publicly_Viewable (Term : Inc_Class_Wp_Terms.Wp_Term)
                                       return Boolean
                                       is (True);

end Inc_Taxonomys;
