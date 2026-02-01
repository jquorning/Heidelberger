--
-- Taxonomy API: Core category-specific template tags
--
-- @package WordPress
-- @subpackage Template
-- @since 1.2.0
--

with Arrays;
-- with Lists;

with Class_Terms;
with Class_Posts;

package Inc_Category_Templates
is
   use Arrays;
-- use Lists;

   No_Terms : exception;
   Error    : exception;

   --
   -- Retrieves category parents with separator.
   --
   -- @since 1.2.0
   -- @since 4.8.0 The `$visited` parameter was deprecated and renamed to
   --               `$deprecated`.
   --
   -- @param int    $category_id Category ID.
   -- @param bool   $link        Optional. Whether to format with link. Default false.
   -- @param string $separator   Optional. How to separate categories. Default '/'.
   -- @param bool   $nicename    Optional. Whether to use nice name for display.
   --                            Default false.
   -- @param array  $deprecated  Not used.
   -- @return string|WP_Error A list of category parents on success, WP_Error on
   --                          failure.
   --
   function Get_Category_Parents (Category_Id : Integer;
                                  Link        : Boolean := False;
                                  Separator   : String  := "/";
                                  Nicename    : Boolean := False)
                                  -- , $deprecated = array() ) then
                                  return String; -- List_Type; -- String;

   --
   -- Retrieves post categories.
   --
   -- This tag may be used outside The Loop by passing a post ID as the parameter.
   --
   -- Note: This function only returns results from the default "category" taxonomy.
   -- For custom taxonomies use get_the_terms().
   --
   -- @since 0.71
   --
   -- @param int $post_id Optional. The post ID. Defaults to current post ID.
   -- @return WP_Term[] Array of WP_Term objects, one for each category assigned to
   --                    the post.
   --
   function Get_The_Category (Post_Id : Class_Posts.Post_Id_Type := 0) -- false
                              return Class_Terms.Wp_Term_Array;

   --
   -- Displays or retrieves the HTML dropdown list of categories.
   --
   -- The 'hierarchical' argument, which is disabled by default, will override the
   -- depth argument, unless it is true. When the argument is false, it will
   -- display all of the categories. When it is enabled it will use the value in
   -- the 'depth' argument.
   --
   -- @since 2.1.0
   -- @since 4.2.0 Introduced the `value_field` argument.
   -- @since 4.6.0 Introduced the `required` argument.
   -- @since 6.1.0 Introduced the `aria_describedby` argument.
   --
   -- @param array|string $args {
   --     Optional. Array or string of arguments to generate a categories drop-down
   --     element. See WP_Term_Query::__construct() for information on additional
   --     accepted arguments.
   --
   --     @type string       $show_option_all   Text to display for showing all
   --                                           categories. Default empty.
   --     @type string       $show_option_none  Text to display for showing no
   --                                           categories. Default empty.
   --     @type string       $option_none_value Value to use when no category is
   --                                           selected. Default empty.
   --     @type string       $orderby           Which column to use for ordering
   --                                           categories. See get_terms() for a list
   --                                           of accepted values. Default 'id'
   --                                           (term_id).
   --     @type bool         $pad_counts        See get_terms() for an argument
   --                                           description. Default false.
   --     @type bool|int     $show_count        Whether to include post counts.
   --                                           Accepts 0, 1, or their bool
   --                                           equivalents. Default 0.
   --     @type bool|int     $echo              Whether to echo or return the
   --                                           generated markup. Accepts 0, 1, or
   --                                           their bool equivalents. Default 1.
   --     @type bool|int     $hierarchical      Whether to traverse the taxonomy
   --                                           hierarchy. Accepts 0, 1, or their bool
   --                                           equivalents. Default 0.
   --     @type int          $depth             Maximum depth. Default 0.
   --     @type int          $tab_index         Tab index for the select element.
   --                                           Default 0 (no tabindex).
   --     @type string       $name              Value for the 'name' attribute of the
   --                                           select element. Default 'cat'.
   --     @type string       $id                Value for the 'id' attribute of the
   --                                           select element. Defaults to the value
   --                                           of `$name`.
   --     @type string       $class             Value for the 'class' attribute of the
   --                                           select element. Default 'postform'.
   --     @type int|string   $selected          Value of the option that should be
   --                                           selected. Default 0.
   --     @type string       $value_field       Term field that should be used to
   --                                           populate the 'value' attribute of the
   --                                           option elements. Accepts any valid
   --                                           term field: 'term_id', 'name', 'slug',
   --                                           'term_group', 'term_taxonomy_id',
   --                                           'taxonomy', 'description', 'parent',
   --                                           'count'. Default 'term_id'.
   --     @type string|array $taxonomy          Name of the taxonomy or taxonomies to
   --                                           retrieve. Default 'category'.
   --     @type bool         $hide_if_empty     True to skip generating markup if no
   --                                           categories are found. Default false
   --                                           (create select element even if no
   --                                           categories are found).
   --     @type bool         $required          Whether the `<select>` element should
   --                                           have the HTML5 'required' attribute.
   --                                           Default false.
   --     @type Walker       $walker            Walker object to use to build the
   --                                           output. Default empty which results
   --                                           in a Walker_CategoryDropdown instance
   --                                           being used.
   --     @type string       $aria_describedby  The 'id' of an element that contains
   --                                           descriptive text for the select.
   --                                           Default empty string.
   -- }
   -- @return string HTML dropdown list of categories.
   --
   function Wp_Dropdown_Categories (Args : Array_Type := Empty_Array) -- := "")
                                    return String;

   --
   -- Retrieves the terms of the taxonomy that are attached to the post.
   --
   -- @since 2.5.0
   --
   -- @param int|WP_Post $post     Post ID or object.
   -- @param string      $taxonomy Taxonomy name.
   -- @return WP_Term[]|false|WP_Error Array of WP_Term objects on success, false if
   --                                  there are no terms or the post does not exist,
   --                                  WP_Error on failure.
   --
   function Get_The_Terms (Post     : Class_Posts.Wp_Post;
                           Taxonomy : String)
                           return Class_Terms.Wp_Term_Array;
                           -- Inc_Class_Posts.Wp_Post;

   function Get_The_Terms (Post     : Class_Posts.Post_Id_Type;
                           Taxonomy : String)
                           return Class_Terms.Wp_Term_Array;

   --
   -- Retrieves term parents with separator.
   --
   -- @since 4.8.0
   --
   -- @param int          $term_id  Term ID.
   -- @param string       $taxonomy Taxonomy name.
   -- @param string|array $args {
   --     Array of optional arguments.
   --
   --     @type string $format    Use term names or slugs for display. Accepts "name"
   --                              or "slug". Default "name".
   --     @type string $separator Separator for between the terms. Default "/".
   --     @type bool   $link      Whether to format as a link. Default true.
   --     @type bool   $inclusive Include the term to get the parents for. Default
   --                              true.
   -- }
   -- @return string|WP_Error A list of term parents on success, WP_Error or empty
   --                          string on failure.
   --
   function Get_Term_Parents_List (Term_Id  : Integer;
                                   Taxonomy : String;
                                   Args     : Array_Type := Empty_Array)
                                   return String; -- List_Type;

   --
   -- Retrieves HTML dropdown (select) content for category list.
   --
   -- @since 2.1.0
   -- @since 5.3.0 Formalized the existing `...$args` parameter by adding it
   --              to the function signature.
   --
   -- @uses Walker_CategoryDropdown to create HTML dropdown content.
   -- @see Walker::walk() for parameters and return description.
   --
   -- @param mixed ...$args Elements array, maximum hierarchical depth and optional
   --                       additional arguments.
   -- @return string
   --
   function Walk_Category_Dropdown_Tree
     (Categories : Array_Type; -- Class_Terms.Wp_Term_Array; -- ...$args
      Depth      : Integer;
      Args       : Array_Type)
      return String;

end Inc_Category_Templates;
