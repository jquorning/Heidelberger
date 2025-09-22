--
-- Taxonomy API: Core category-specific template tags
--
-- @package WordPress
-- @subpackage Template
-- @since 1.2.0
--

with Arrays;

with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Posts;
with Inc_Taxonomys;

package Inc_Category_Templates
is
   use Arrays;

   No_Terms : exception;
   Error    : exception;

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
   --     Optional. Array or string of arguments to generate a categories drop-down element. See WP_Term_Query::__construct()
   --     for information on additional accepted arguments.
   --
   --     @type string       $show_option_all   Text to display for showing all categories. Default empty.
   --     @type string       $show_option_none  Text to display for showing no categories. Default empty.
   --     @type string       $option_none_value Value to use when no category is selected. Default empty.
   --     @type string       $orderby           Which column to use for ordering categories. See get_terms() for a list
   --                                           of accepted values. Default 'id' (term_id).
   --     @type bool         $pad_counts        See get_terms() for an argument description. Default false.
   --     @type bool|int     $show_count        Whether to include post counts. Accepts 0, 1, or their bool equivalents.
   --                                           Default 0.
   --     @type bool|int     $echo              Whether to echo or return the generated markup. Accepts 0, 1, or their
   --                                           bool equivalents. Default 1.
   --     @type bool|int     $hierarchical      Whether to traverse the taxonomy hierarchy. Accepts 0, 1, or their bool
   --                                           equivalents. Default 0.
   --     @type int          $depth             Maximum depth. Default 0.
   --     @type int          $tab_index         Tab index for the select element. Default 0 (no tabindex).
   --     @type string       $name              Value for the 'name' attribute of the select element. Default 'cat'.
   --     @type string       $id                Value for the 'id' attribute of the select element. Defaults to the value
   --                                           of `$name`.
   --     @type string       $class             Value for the 'class' attribute of the select element. Default 'postform'.
   --     @type int|string   $selected          Value of the option that should be selected. Default 0.
   --     @type string       $value_field       Term field that should be used to populate the 'value' attribute
   --                                           of the option elements. Accepts any valid term field: 'term_id', 'name',
   --                                           'slug', 'term_group', 'term_taxonomy_id', 'taxonomy', 'description',
   --                                           'parent', 'count'. Default 'term_id'.
   --     @type string|array $taxonomy          Name of the taxonomy or taxonomies to retrieve. Default 'category'.
   --     @type bool         $hide_if_empty     True to skip generating markup if no categories are found.
   --                                           Default false (create select element even if no categories are found).
   --     @type bool         $required          Whether the `<select>` element should have the HTML5 'required' attribute.
   --                                           Default false.
   --     @type Walker       $walker            Walker object to use to build the output. Default empty which results in a
   --                                           Walker_CategoryDropdown instance being used.
   --     @type string       $aria_describedby  The 'id' of an element that contains descriptive text for the select.
   --                                           Default empty string.
   -- }
   -- @return string HTML dropdown list of categories.
   --
  function Wp_Dropdown_Categories (Args : Array_Type := Empty_Array) -- := "")
                                   return String
                                   is ("XXX-447");

   --
   -- Retrieves the terms of the taxonomy that are attached to the post.
   --
   -- @since 2.5.0
   --
   -- @param int|WP_Post $post     Post ID or object.
   -- @param string      $taxonomy Taxonomy name.
   -- @return WP_Term[]|false|WP_Error Array of WP_Term objects on success, false if there are no terms
   --                                  or the post does not exist, WP_Error on failure.
   --
   function Get_The_Terms (Post     : Inc_Class_Wp_Posts.Wp_Post;
                           Taxonomy : String)
                           return Inc_Class_Wp_Terms.Wp_Term_Array;
                            -- Inc_Class_Posts.Wp_Post;

end Inc_Category_Templates;
