--
-- Taxonomy API: Core category-specific template tags
--
-- @package WordPress
-- @subpackage Template
-- @since 1.2.0
--

with Ada.Containers;

with UStrings;
with Php.Echoing;
with Php.Strings;
with Lists;
with Wp_Common;

with Adi_Caches;

with Class_Walker_Category_Dropdown;
with Class_Taxonomy;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Plugins;
with Inc_Posts;
with Inc_Querys;
with Inc_Taxonomys;

package body Inc_Category_Templates
is
   use Lists;

--
-- Retrieves category link URL.
--
-- @since 1.0.0
--
-- @see get_term_link()
--
-- @param int|object $category Category ID or object.
-- @return string Link on success, empty string if category does not exist.
--

-- function get_category_link( $category ) then
--         if ( ! is_object( $category ) ) then
--                 $category = (int) $category;
--         end;

--         $category = get_term_link( $category );

--         if ( is_wp_error( $category ) ) then
--                 return '';
--         end;

--         return $category;
-- end;

   --------------------------
   -- Get_Category_Parents --
   --------------------------

   function Get_Category_Parents (Category_Id : Integer;
                                  Link        : Boolean := False;
                                  Separator   : String  := "/";
                                  Nicename    : Boolean := False)
                                  -- , $deprecated = array() ) then
                                  return String -- List_Type -- String;
   is
--        if ( ! empty( $deprecated ) ) then
--                _deprecated_argument( __FUNCTION__, '4.8.0' );
--        end;

      Format : String := (if Nicename then "slug" else "name");

      Args : constant Array_Type := To_Array (List => (
        Build ("separator", Separator),
        Build ("link",      Link),
        Build ("format",    Format)
      ));
   begin
      return Get_Term_Parents_List (Category_Id, "category", Args);
   end Get_Category_Parents;

   ----------------------
   -- Get_The_Category --
   ----------------------

   function Get_The_Category (Post_Id : Class_Posts.Post_Id := 0) -- false
                              return Class_Terms.Wp_Term_Array
   is
      use Wp_Common;
      use Class_Terms;
      use Class_Terms.Term_Vectors;
--    use Inc_Load;
--    use Inc_Plugins;

      Categories : Wp_Term_Array := Get_The_Terms (Post_Id, "category");
   begin
      if
        Categories = Empty_Term_Array -- or else
--      not Categories or else
--      Is_Wp_Error (Categories)
      then
         Categories := Empty_Term_Array; -- Empty_Array;
      end if;

--    Categories := Array_Values (Categories);

--    for Key of Array_Keys (Categories) loop
--       X_Make_Cat_Compat (Get (Categories, Key));
--    end loop;

      --
      -- Filters the array of categories to return for a post.
      --
      -- @since 3.1.0
      -- @since 4.4.0 Added the `$post_id` parameter.
      --
      -- @param WP_Term[] $categories An array of categories to return for the post.
      -- @param int|false $post_id    The post ID.
      --
      return Apply_Filters ("get_the_categories", Categories, Post_Id);
   end Get_The_Category;

--
-- Retrieves category name based on category ID.
--
-- @since 0.71
--
-- @param int $cat_id Category ID.
-- @return string|WP_Error Category name on success, WP_Error on failure.
--

-- function get_the_category_by_ID( $cat_id ) then // phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionNameInvalid
--         $cat_id   = (int) $cat_id;
--         $category = get_term( $cat_id );

--         if ( is_wp_error( $category ) ) then
--                 return $category;
--         end;

--         return ( $category ) ? $category->name : '';
-- end;

--
-- Retrieves category list for a post in either HTML list or custom format.
--
-- Generally used for quick, delimited (e.g. comma-separated) lists of categories,
-- as part of a post entry meta.
--
-- For a more powerful, list-based function, see wp_list_categories().
--
-- @since 1.5.1
--
-- @see wp_list_categories()
--
-- @global WP_Rewrite $wp_rewrite WordPress rewrite component.
--
-- @param string $separator Optional. Separator between the categories. By default, the links are placed
--                          in an unordered list. An empty string will result in the default behavior.
-- @param string $parents   Optional. How to display the parents. Accepts 'multiple', 'single', or empty.
--                          Default empty string.
-- @param int    $post_id   Optional. ID of the post to retrieve categories for. Defaults to the current post.
-- @return string Category list for a post.
--

-- function get_the_category_list( $separator = '', $parents = '', $post_id = false ) then
--         global $wp_rewrite;

--         if ( ! is_object_in_taxonomy( get_post_type( $post_id ), 'category' ) ) then
--                 -- This filter is documented in wp-includes/category-template.php--
--                 return apply_filters( 'the_category', '', $separator, $parents );
--         end;

--         --
--         -- Filters the categories before building the category list.
--         --
--         -- @since 4.4.0
--         --
--         -- @param WP_Term[] $categories An array of the post's categories.
--         -- @param int|false $post_id    ID of the post to retrieve categories for.
--         --                              When `false`, defaults to the current post in the loop.
--         --
--         $categories = apply_filters( 'the_category_list', get_the_category( $post_id ), $post_id );

--         if ( empty( $categories ) ) then
--                 -- This filter is documented in wp-includes/category-template.php--
--                 return apply_filters( 'the_category', __( 'Uncategorized' ), $separator, $parents );
--         end;

--         $rel = ( is_object( $wp_rewrite ) && $wp_rewrite->using_permalinks() ) ? 'rel="category tag"' : 'rel="category"';

--         $thelist = '';
--         if ( '' === $separator ) then
--                 $thelist .= '<ul class="post-categories">';
--                 foreach ( $categories as $category ) then
--                         $thelist .= "\n\t<li>";
--                         switch ( strtolower( $parents ) ) then
--                                 case 'multiple':
--                                         if ( $category->parent ) then
--                                                 $thelist .= get_category_parents( $category->parent, true, $separator );
--                                         end;
--                                         $thelist .= '<a href="' . esc_url( get_category_link( $category->term_id ) ) . '" ' . $rel . '>' . $category->name . '</a></li>';
--                                         break;
--                                 case 'single':
--                                         $thelist .= '<a href="' . esc_url( get_category_link( $category->term_id ) ) . '"  ' . $rel . '>';
--                                         if ( $category->parent ) then
--                                                 $thelist .= get_category_parents( $category->parent, false, $separator );
--                                         end;
--                                         $thelist .= $category->name . '</a></li>';
--                                         break;
--                                 case '':
--                                 default:
--                                         $thelist .= '<a href="' . esc_url( get_category_link( $category->term_id ) ) . '" ' . $rel . '>' . $category->name . '</a></li>';
--                         end;
--                 end;
--                 $thelist .= '</ul>';
--         end; else then
--                 $i = 0;
--                 foreach ( $categories as $category ) then
--                         if ( 0 < $i ) then
--                                 $thelist .= $separator;
--                         end;
--                         switch ( strtolower( $parents ) ) then
--                                 case 'multiple':
--                                         if ( $category->parent ) then
--                                                 $thelist .= get_category_parents( $category->parent, true, $separator );
--                                         end;
--                                         $thelist .= '<a href="' . esc_url( get_category_link( $category->term_id ) ) . '" ' . $rel . '>' . $category->name . '</a>';
--                                         break;
--                                 case 'single':
--                                         $thelist .= '<a href="' . esc_url( get_category_link( $category->term_id ) ) . '" ' . $rel . '>';
--                                         if ( $category->parent ) then
--                                                 $thelist .= get_category_parents( $category->parent, false, $separator );
--                                         end;
--                                         $thelist .= "$category->name</a>";
--                                         break;
--                                 case '':
--                                 default:
--                                         $thelist .= '<a href="' . esc_url( get_category_link( $category->term_id ) ) . '" ' . $rel . '>' . $category->name . '</a>';
--                         end;
--                         ++$i;
--                 end;
--         end;

--         --
--         -- Filters the category or list of categories.
--         --
--         -- @since 1.2.0
--         --
--         -- @param string $thelist   List of categories for the current post.
--         -- @param string $separator Separator used between the categories.
--         -- @param string $parents   How to display the category parents. Accepts 'multiple',
--         --                          'single', or empty.
--         --
--         return apply_filters( 'the_category', $thelist, $separator, $parents );
-- end;

--
-- Checks if the current post is within any of the given categories.
--
-- The given categories are checked against the post's categories' term_ids, names and slugs.
-- Categories given as integers will only be checked against the post's categories' term_ids.
--
-- Prior to v2.5 of WordPress, category names were not supported.
-- Prior to v2.7, category slugs were not supported.
-- Prior to v2.7, only one category could be compared: in_category( $single_category ).
-- Prior to v2.7, this function could only be used in the WordPress Loop.
-- As of 2.7, the function can be used anywhere if it is provided a post ID or post object.
--
-- For more information on this and similar theme functions, check out
-- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tags} article in the Theme Developer Handbook.
--
-- @since 1.2.0
-- @since 2.7.0 The `$post` parameter was added.
--
-- @param int|string|int[]|string[] $category Category ID, name, slug, or array of such
--                                            to check against.
-- @param int|WP_Post               $post     Optional. Post to check. Defaults to the current post.
-- @return bool True if the current post is in any of the given categories.
--

-- function in_category( $category, $post = null ) then
--         if ( empty( $category ) ) then
--                 return false;
--         end;

--         return has_category( $category, $post );
-- end;

--
-- Displays category list for a post in either HTML list or custom format.
--
-- @since 0.71
--
-- @param string $separator Optional. Separator between the categories. By default, the links are placed
--                          in an unordered list. An empty string will result in the default behavior.
-- @param string $parents   Optional. How to display the parents. Accepts 'multiple', 'single', or empty.
--                          Default empty string.
-- @param int    $post_id   Optional. ID of the post to retrieve categories for. Defaults to the current post.
--

-- function the_category( $separator = '', $parents = '', $post_id = false ) then
--         echo get_the_category_list( $separator, $parents, $post_id );
-- end;

--
-- Retrieves category description.
--
-- @since 1.0.0
--
-- @param int $category Optional. Category ID. Defaults to the current category ID.
-- @return string Category description, if available.
--

-- function category_description( $category = 0 ) then
--         return term_description( $category );
-- end;

   ----------------------------
   -- Wp_Dropdown_Categories --
   ----------------------------

   function Wp_Dropdown_Categories (Args : Array_Type := Empty_Array) -- := "")
                                    return String
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Plugins;

      Defaults : Array_Type := To_Array ((
         Build ("show_option_all",   ""),
         Build ("show_option_none",  ""),
         Build ("orderby",           "id"),
         Build ("order",             "ASC"),
         Build ("show_count",        0),
         Build ("hide_empty",        1),
         Build ("child_of",          0),
         Build ("exclude",           ""),
         Build ("echo",              1),
         Build ("selected",          0),
         Build ("hierarchical",      0),
         Build ("name",              "cat"),
         Build ("id",                ""),
         Build ("class",             "postform"),
         Build ("depth",             0),
         Build ("tab_index",         0),
         Build ("taxonomy",          "category"),
         Build ("hide_if_empty",     False),
         Build ("option_none_value", -1),
         Build ("value_field",       "term_id"),
         Build ("required",          False),
         Build ("aria_describedby",  "")
      ));

      Parsed_Args       : Array_Type;
      Get_Terms_Args    : Array_Type;
      Option_None_Value : UString;
      Tab_Index         : Integer;
      Tab_Index_Attribute : UString;
      Output            : UString;
   begin
      Set (Defaults, "selected",
           From_Integer (if Inc_Querys.Is_Category
                         then Inc_Querys.Get_Query_Var ("cat")
                         else 0));

      -- Back compat.
      if Isset (Args, "type") and then "link" = As_String (Get (Args, "type")) then
         X_Deprecated_Argument (
           "__FUNCTION__",
           "3.0.0",
           Sprintf (
              -- translators: 1: 'type => link', 2: 'taxonomy => link_category'
              abs "%1$s is deprecated. Use %2$s instead.",
              To_List (List => (
                1 => +"<code>type => link</code>",
                2 => +"<code>taxonomy => link_category</code>"))
           )
         );
--       Set (Args, "taxonomy", "link_category");
      end if;

      -- Parse incoming $args into an array and merge it with $defaults.
      Parsed_Args := Wp_Parse_Args (Args, Defaults);

      Option_None_Value := +As_Integer (Get (Parsed_Args, "option_none_value"))'Image;

      if
        not Isset (Parsed_Args, "pad_counts")          and then
        As_Integer (Get (Parsed_Args, "show_count"))   /= 0 and then
        As_Integer (Get (Parsed_Args, "hierarchical")) /= 0
      then
         Set (Parsed_Args, "pad_counts", From_Boolean (True));
      end if;

      Tab_Index := As_Integer (Get (Parsed_Args, "tab_index"));

      Tab_Index_Attribute := +"";
      if Tab_Index > 0 then -- (int)
         Tab_Index_Attribute := +" tabindex=""" & Integer'Image (Tab_Index) & """";
      end if;

      -- Avoid clashes with the 'name' param of get_terms().
      Get_Terms_Args := Parsed_Args;
--    unset( $get_terms_args["name"] );
      declare
         use Class_Terms;
         use Inc_Taxonomys;

         function Empty (Terms : Wp_Term_Array)
                         return Boolean;

         function Empty (Terms : Wp_Term_Array)
                         return Boolean
         is
            use Term_Vectors;
         begin
            return Terms = Empty_Term_Array;
         end Empty;

         Categories : constant Wp_Term_Array := Get_Terms (Get_Terms_Args);

         Name     : constant String := ESC_Attr (As_String (Get (Parsed_Args, "name")));
         Class    : constant String := ESC_Attr (As_String (Get (Parsed_Args, "class")));
         Id       : String := (if As_String (Get (Parsed_Args, "id")) /= ""
                               then ESC_Attr (As_String (Get (Parsed_Args, "id"))) else Name);
         Required : String := (if As_Boolean (Get (Parsed_Args, "required"))
                               then "required" else "");

         Aria_Describedby_Attribute : String :=
           (if As_String (Get (Parsed_Args, "aria_describedby")) /= ""
            then " aria-describedby=""" &
                 ESC_Attr (As_String (Get (Parsed_Args, "aria_describedby"))) & """"
            else "");
      begin
         if
           not As_Boolean (Get (Parsed_Args, "hide_if_empty")) or else
           not Empty (Categories)
         then
            Output := +"<select " & Required & " name=""" & Name & """ id=""" & Id &
                      """ class=""" & Class & """" & Tab_Index_Attribute &
                      Aria_Describedby_Attribute & ">" & NL;
         else
            Output := +"";
         end if;

         if
           Empty (Categories) and then
           not As_Boolean (Get (Parsed_Args, "hide_if_empty")) and then
           not Empty (As_String (Get (Parsed_Args, "show_option_none")))
         then
            --
            -- Filters a taxonomy drop-down display element.
            --
            -- A variety of taxonomy drop-down display elements can be modified
            -- just prior to display via this filter. Filterable arguments include
            -- "show_option_none", "show_option_all", and various forms of the
            -- term name.
            --
            -- @since 1.2.0
            --
            -- @see wp_dropdown_categories()
            --
            -- @param string       $element  Category name.
            -- @param WP_Term|null $category The category object, or null if there's
            --                                no corresponding category.
            --
            declare
               Show_Option_None : constant String :=
                 Apply_Filters ("list_cats", As_String (Get (Parsed_Args, "show_option_none")),
                                "null"); -- "" added
            begin
               Append (Output,
                       TAB & "<option value=""" & ESC_Attr (-Option_None_Value) &
                       """ selected=""selected"">" & Show_Option_None &
                       "</option>" & NL);
            end;
         end if;

         if not Empty (Categories) then
            if As_String (Get (Parsed_Args, "show_option_all")) /= "" then
               declare
                  -- This filter is documented in wp-includes/category-template.php
                  Show_Option_All : constant String :=
                    Apply_Filters ("list_cats", As_String (Get (Parsed_Args, "show_option_all")),
                                   "null");  -- "" added
                  Selected : String := (if "0" = As_String (Get (Parsed_Args, "selected"))
                                        then " selected=""selected""" else "");
               begin
                  Append (Output,
                          TAB & "<option value=""0""" & Selected & ">" &
                          Show_Option_All & "</option>" & NL);
               end;
            end if;

            if As_String (Get (Parsed_Args, "show_option_none")) /= "" then
               declare
                  use Inc_General_Templates;

                  -- This filter is documented in wp-includes/category-template.php
                  Show_Option_None : constant String :=
                    Apply_Filters ("list_cats", As_String (Get (Parsed_Args, "show_option_none")),
                                   "null");  -- "" added
                  Selectd : constant String :=
                    Selected (-Option_None_Value,
                              As_String (Get (Parsed_Args, "selected")),
                              Echo => False);
               begin
                  Append (Output,
                          TAB & "<option value=""" & ESC_Attr (-Option_None_Value) &
                          """" & Selectd & ">" & Show_Option_None &
                          "</option>" & NL);
               end;
            end if;

            declare
               Depth : Integer;
            begin
               if As_Integer (Get (Parsed_Args, "hierarchical")) /= 0 then
                  Depth := As_Integer (Get (Parsed_Args, "depth"));  -- Walk the full depth.
               else
                  Depth := -1; -- Flat.
               end if;
               Append (Output,
                       Walk_Category_Dropdown_Tree (Empty_Array, -- Categories,
                                                    Depth, Parsed_Args));
            end;
         end if;

         if
           not As_Boolean (Get (Parsed_Args, "hide_if_empty")) or else
           not Empty (Categories)
         then
            Append (Output, "</select>" & NL);
         end if;

         --
         -- Filters the taxonomy drop-down output.
         --
         -- @since 2.1.0
         --
         -- @param string $output      HTML output.
         -- @param array  $parsed_args Arguments used to build the drop-down.
         --
         Output := +Apply_Filters ("wp_dropdown_cats", -Output,
                                   P => Parsed_Args); -- P => added
         if As_Integer (Get (Parsed_Args, "echo")) /= 0 then
            Echo (-Output);
         end if;

         return -Output;
      end;
   end Wp_Dropdown_Categories;

--
-- Displays or retrieves the HTML list of categories.
--
-- @since 2.1.0
-- @since 4.4.0 Introduced the `hide_title_if_empty` and `separator` arguments.
-- @since 4.4.0 The `current_category` argument was modified to optionally accept an array of values.
-- @since 6.1.0 Default value of the "use_desc_for_title" argument was changed from 1 to 0.
--
-- @param array|string $args then
--     Array of optional arguments. See get_categories(), get_terms(), and WP_Term_Query::__construct()
--     for information on additional accepted arguments.
--
--     @type int|int[]    $current_category      ID of category, or array of IDs of categories, that should get the
--                                               "current-cat" class. Default 0.
--     @type int          $depth                 Category depth. Used for tab indentation. Default 0.
--     @type bool|int     $echo                  Whether to echo or return the generated markup. Accepts 0, 1, or their
--                                               bool equivalents. Default 1.
--     @type int[]|string $exclude               Array or comma/space-separated string of term IDs to exclude.
--                                               If `$hierarchical` is true, descendants of `$exclude` terms will also
--                                               be excluded; see `$exclude_tree`. See get_terms().
--                                               Default empty string.
--     @type int[]|string $exclude_tree          Array or comma/space-separated string of term IDs to exclude, along
--                                               with their descendants. See get_terms(). Default empty string.
--     @type string       $feed                  Text to use for the feed link. Default "Feed for all posts filed
--                                               under [cat name]".
--     @type string       $feed_image            URL of an image to use for the feed link. Default empty string.
--     @type string       $feed_type             Feed type. Used to build feed link. See get_term_feed_link().
--                                               Default empty string (default feed).
--     @type bool         $hide_title_if_empty   Whether to hide the `$title_li` element if there are no terms in
--                                               the list. Default false (title will always be shown).
--     @type string       $separator             Separator between links. Default "<br />".
--     @type bool|int     $show_count            Whether to include post counts. Accepts 0, 1, or their bool equivalents.
--                                               Default 0.
--     @type string       $show_option_all       Text to display for showing all categories. Default empty string.
--     @type string       $show_option_none      Text to display for the "no categories" option.
--                                               Default "No categories".
--     @type string       $style                 The style used to display the categories list. If "list", categories
--                                               will be output as an unordered list. If left empty or another value,
--                                               categories will be output separated by `<br>` tags. Default "list".
--     @type string       $taxonomy              Name of the taxonomy to retrieve. Default "category".
--     @type string       $title_li              Text to use for the list title `<li>` element. Pass an empty string
--                                               to disable. Default "Categories".
--     @type bool|int     $use_desc_for_title    Whether to use the category description as the title attribute.
--                                               Accepts 0, 1, or their bool equivalents. Default 0.
--     @type Walker       $walker                Walker object to use to build the output. Default empty which results
--                                               in a Walker_Category instance being used.
-- end;
-- @return void|string|false Void if "echo" argument is true, HTML list of categories if "echo" is false.
--                           False if the taxonomy does not exist.
--

-- function wp_list_categories( $args = "" ) then
--         $defaults = array(
--                 "child_of"            => 0,
--                 "current_category"    => 0,
--                 "depth"               => 0,
--                 "echo"                => 1,
--                 "exclude"             => "",
--                 "exclude_tree"        => "",
--                 "feed"                => "",
--                 "feed_image"          => "",
--                 "feed_type"           => "",
--                 "hide_empty"          => 1,
--                 "hide_title_if_empty" => false,
--                 "hierarchical"        => true,
--                 "order"               => "ASC",
--                 "orderby"             => "name",
--                 "separator"           => "<br />",
--                 "show_count"          => 0,
--                 "show_option_all"     => "",
--                 "show_option_none"    => __( "No categories" ),
--                 "style"               => "list",
--                 "taxonomy"            => "category",
--                 "title_li"            => __( "Categories" ),
--                 "use_desc_for_title"  => 0,
--         );

--         $parsed_args = wp_parse_args( $args, $defaults );

--         if ( ! isset( $parsed_args["pad_counts"] ) && $parsed_args["show_count"] && $parsed_args["hierarchical"] ) then
--                 $parsed_args["pad_counts"] = true;
--         end;

--         // Descendants of exclusions should be excluded too.
--         if ( true == $parsed_args["hierarchical"] ) then
--                 $exclude_tree = array();

--                 if ( $parsed_args["exclude_tree"] ) then
--                         $exclude_tree = array_merge( $exclude_tree, wp_parse_id_list( $parsed_args["exclude_tree"] ) );
--                 end;

--                 if ( $parsed_args["exclude"] ) then
--                         $exclude_tree = array_merge( $exclude_tree, wp_parse_id_list( $parsed_args["exclude"] ) );
--                 end;

--                 $parsed_args["exclude_tree"] = $exclude_tree;
--                 $parsed_args["exclude"]      = "";
--         end;

--         if ( ! isset( $parsed_args["class"] ) ) then
--                 $parsed_args["class"] = ( "category" === $parsed_args["taxonomy"] ) ? "categories" : $parsed_args["taxonomy"];
--         end;

--         if ( ! taxonomy_exists( $parsed_args["taxonomy"] ) ) then
--                 return false;
--         end;

--         $show_option_all  = $parsed_args["show_option_all"];
--         $show_option_none = $parsed_args["show_option_none"];

--         $categories = get_categories( $parsed_args );

--         $output = "";

--         if ( $parsed_args["title_li"] && "list" === $parsed_args["style"]
--                 && ( ! empty( $categories ) || ! $parsed_args["hide_title_if_empty"] )
--         ) then
--                 $output = "<li class="" . esc_attr( $parsed_args["class"] ) . "">" . $parsed_args["title_li"] . "<ul>";
--         end;

--         if ( empty( $categories ) ) then
--                 if ( ! empty( $show_option_none ) ) then
--                         if ( "list" === $parsed_args["style"] ) then
--                                 $output .= "<li class="cat-item-none">" . $show_option_none . "</li>";
--                         end; else then
--                                 $output .= $show_option_none;
--                         end;
--                 end;
--         end; else then
--                 if ( ! empty( $show_option_all ) ) then

--                         $posts_page = "";

--                         // For taxonomies that belong only to custom post types, point to a valid archive.
--                         $taxonomy_object = get_taxonomy( $parsed_args["taxonomy"] );
--                         if ( ! in_array( "post", $taxonomy_object->object_type, true ) && ! in_array( "page", $taxonomy_object->object_type, true ) ) then
--                                 foreach ( $taxonomy_object->object_type as $object_type ) then
--                                         $_object_type = get_post_type_object( $object_type );

--                                         // Grab the first one.
--                                         if ( ! empty( $_object_type->has_archive ) ) then
--                                                 $posts_page = get_post_type_archive_link( $object_type );
--                                                 break;
--                                         end;
--                                 end;
--                         end;

--                         // Fallback for the "All" link is the posts page.
--                         if ( ! $posts_page ) then
--                                 if ( "page" === get_option( "show_on_front" ) && get_option( "page_for_posts" ) ) then
--                                         $posts_page = get_permalink( get_option( "page_for_posts" ) );
--                                 end; else then
--                                         $posts_page = home_url( "/" );
--                                 end;
--                         end;

--                         $posts_page = esc_url( $posts_page );
--                         if ( "list" === $parsed_args["style"] ) then
--                                 $output .= "<li class="cat-item-all"><a href="$posts_page">$show_option_all</a></li>";
--                         end; else then
--                                 $output .= "<a href="$posts_page">$show_option_all</a>";
--                         end;
--                 end;

--                 if ( empty( $parsed_args["current_category"] ) && ( is_category() || is_tax() || is_tag() ) ) then
--                         $current_term_object = get_queried_object();
--                         if ( $current_term_object && $parsed_args["taxonomy"] === $current_term_object->taxonomy ) then
--                                 $parsed_args["current_category"] = get_queried_object_id();
--                         end;
--                 end;

--                 if ( $parsed_args["hierarchical"] ) then
--                         $depth = $parsed_args["depth"];
--                 end; else then
--                         $depth = -1; // Flat.
--                 end;
--                 $output .= walk_category_tree( $categories, $depth, $parsed_args );
--         end;

--         if ( $parsed_args["title_li"] && "list" === $parsed_args["style"]
--                 && ( ! empty( $categories ) || ! $parsed_args["hide_title_if_empty"] )
--         ) then
--                 $output .= "</ul></li>";
--         end;

--         --
--         -- Filters the HTML output of a taxonomy list.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string       $output HTML output.
--         -- @param array|string $args   An array or query string of taxonomy-listing arguments. See
--         --                             wp_list_categories() for information on accepted arguments.
--         --
--         $html = apply_filters( "wp_list_categories", $output, $args );

--         if ( $parsed_args["echo"] ) then
--                 echo $html;
--         end; else then
--                 return $html;
--         end;
-- end;

--
-- Displays a tag cloud.
--
-- Outputs a list of tags in what is called a "tag cloud", where the size of each tag
-- is determined by how many times that particular tag has been assigned to posts.
--
-- @since 2.3.0
-- @since 2.8.0 Added the `taxonomy` argument.
-- @since 4.8.0 Added the `show_count` argument.
--
-- @param array|string $args then
--     Optional. Array or string of arguments for displaying a tag cloud. See wp_generate_tag_cloud()
--     and get_terms() for the full lists of arguments that can be passed in `$args`.
--
--     @type int    $number    The number of tags to display. Accepts any positive integer
--                             or zero to return all. Default 45.
--     @type string $link      Whether to display term editing links or term permalinks.
--                             Accepts "edit" and "view". Default "view".
--     @type string $post_type The post type. Used to highlight the proper post type menu
--                             on the linked edit page. Defaults to the first post type
--                             associated with the taxonomy.
--     @type bool   $echo      Whether or not to echo the return value. Default true.
-- end;
-- @return void|string|string[] Void if "echo" argument is true, or on failure. Otherwise, tag cloud
--                              as a string or an array, depending on "format" argument.
--

-- function wp_tag_cloud( $args = "" ) then
--         $defaults = array(
--                 "smallest"   => 8,
--                 "largest"    => 22,
--                 "unit"       => "pt",
--                 "number"     => 45,
--                 "format"     => "flat",
--                 "separator"  => "\n",
--                 "orderby"    => "name",
--                 "order"      => "ASC",
--                 "exclude"    => "",
--                 "include"    => "",
--                 "link"       => "view",
--                 "taxonomy"   => "post_tag",
--                 "post_type"  => "",
--                 "echo"       => true,
--                 "show_count" => 0,
--         );

--         $args = wp_parse_args( $args, $defaults );

--         $tags = get_terms(
--                 array_merge(
--                         $args,
--                         array(
--                                 "orderby" => "count",
--                                 "order"   => "DESC",
--                         )
--                 )
--         ); // Always query top tags.

--         if ( empty( $tags ) || is_wp_error( $tags ) ) then
--                 return;
--         end;

--         foreach ( $tags as $key => $tag ) then
--                 if ( "edit" === $args["link"] ) then
--                         $link = get_edit_term_link( $tag, $tag->taxonomy, $args["post_type"] );
--                 end; else then
--                         $link = get_term_link( $tag, $tag->taxonomy );
--                 end;

--                 if ( is_wp_error( $link ) ) then
--                         return;
--                 end;

--                 $tags[ $key ]->link = $link;
--                 $tags[ $key ]->id   = $tag->term_id;
--         end;

--         // Here"s where those top tags get sorted according to $args.
--         $return = wp_generate_tag_cloud( $tags, $args );

--         --
--         -- Filters the tag cloud output.
--         --
--         -- @since 2.3.0
--         --
--         -- @param string|string[] $return Tag cloud as a string or an array, depending on "format" argument.
--         -- @param array           $args   An array of tag cloud arguments. See wp_tag_cloud()
--         --                                for information on accepted arguments.
--         --
--         $return = apply_filters( "wp_tag_cloud", $return, $args );

--         if ( "array" === $args["format"] || empty( $args["echo"] ) ) then
--                 return $return;
--         end;

--         echo $return;
-- end;

--
-- Default topic count scaling for tag links.
--
-- @since 2.9.0
--
-- @param int $count Number of posts with that tag.
-- @return int Scaled count.
--

-- function default_topic_count_scale( $count ) then
--         return round( log10( $count + 1 )-- 100 );
-- end;

--
-- Generates a tag cloud (heatmap) from provided data.
--
-- @todo Complete functionality.
-- @since 2.3.0
-- @since 4.8.0 Added the `show_count` argument.
--
-- @param WP_Term[]    $tags Array of WP_Term objects to generate the tag cloud for.
-- @param string|array $args then
--     Optional. Array or string of arguments for generating a tag cloud.
--
--     @type int      $smallest                   Smallest font size used to display tags. Paired
--                                                with the value of `$unit`, to determine CSS text
--                                                size unit. Default 8 (pt).
--     @type int      $largest                    Largest font size used to display tags. Paired
--                                                with the value of `$unit`, to determine CSS text
--                                                size unit. Default 22 (pt).
--     @type string   $unit                       CSS text size unit to use with the `$smallest`
--                                                and `$largest` values. Accepts any valid CSS text
--                                                size unit. Default "pt".
--     @type int      $number                     The number of tags to return. Accepts any
--                                                positive integer or zero to return all.
--                                                Default 0.
--     @type string   $format                     Format to display the tag cloud in. Accepts "flat"
--                                                (tags separated with spaces), "list" (tags displayed
--                                                in an unordered list), or "array" (returns an array).
--                                                Default "flat".
--     @type string   $separator                  HTML or text to separate the tags. Default "\n" (newline).
--     @type string   $orderby                    Value to order tags by. Accepts "name" or "count".
--                                                Default "name". The {@see "tag_cloud_sort"} filter
--                                                can also affect how tags are sorted.
--     @type string   $order                      How to order the tags. Accepts "ASC" (ascending),
--                                                "DESC" (descending), or "RAND" (random). Default "ASC".
--     @type int|bool $filter                     Whether to enable filtering of the final output
--                                                via {@see "wp_generate_tag_cloud"}. Default 1.
--     @type array    $topic_count_text           Nooped plural text from _n_noop() to supply to
--                                                tag counts. Default null.
--     @type callable $topic_count_text_callback  Callback used to generate nooped plural text for
--                                                tag counts based on the count. Default null.
--     @type callable $topic_count_scale_callback Callback used to determine the tag count scaling
--                                                value. Default default_topic_count_scale().
--     @type bool|int $show_count                 Whether to display the tag counts. Default 0. Accepts
--                                                0, 1, or their bool equivalents.
-- end;
-- @return string|string[] Tag cloud as a string or an array, depending on "format" argument.
--

-- function wp_generate_tag_cloud( $tags, $args = "" ) then
--         $defaults = array(
--                 "smallest"                   => 8,
--                 "largest"                    => 22,
--                 "unit"                       => "pt",
--                 "number"                     => 0,
--                 "format"                     => "flat",
--                 "separator"                  => "\n",
--                 "orderby"                    => "name",
--                 "order"                      => "ASC",
--                 "topic_count_text"           => null,
--                 "topic_count_text_callback"  => null,
--                 "topic_count_scale_callback" => "default_topic_count_scale",
--                 "filter"                     => 1,
--                 "show_count"                 => 0,
--         );

--         $args = wp_parse_args( $args, $defaults );

--         $return = ( "array" === $args["format"] ) ? array() : "";

--         if ( empty( $tags ) ) then
--                 return $return;
--         end;

--         // Juggle topic counts.
--         if ( isset( $args["topic_count_text"] ) ) then
--                 // First look for nooped plural support via topic_count_text.
--                 $translate_nooped_plural = $args["topic_count_text"];
--         end; elseif ( ! empty( $args["topic_count_text_callback"] ) ) then
--                 // Look for the alternative callback style. Ignore the previous default.
--                 if ( "default_topic_count_text" === $args["topic_count_text_callback"] ) then
--                         /* translators: %s: Number of items (tags).--
--                         $translate_nooped_plural = _n_noop( "%s item", "%s items" );
--                 end; else then
--                         $translate_nooped_plural = false;
--                 end;
--         end; elseif ( isset( $args["single_text"] ) && isset( $args["multiple_text"] ) ) then
--                 // If no callback exists, look for the old-style single_text and multiple_text arguments.
--                 // phpcs:ignore WordPress.WP.I18n.NonSingularStringLiteralSingle,WordPress.WP.I18n.NonSingularStringLiteralPlural
--                 $translate_nooped_plural = _n_noop( $args["single_text"], $args["multiple_text"] );
--         end; else then
--                 // This is the default for when no callback, plural, or argument is passed in.
--                 /* translators: %s: Number of items (tags).--
--                 $translate_nooped_plural = _n_noop( "%s item", "%s items" );
--         end;

--         --
--         -- Filters how the items in a tag cloud are sorted.
--         --
--         -- @since 2.8.0
--         --
--         -- @param WP_Term[] $tags Ordered array of terms.
--         -- @param array     $args An array of tag cloud arguments.
--         --
--         $tags_sorted = apply_filters( "tag_cloud_sort", $tags, $args );
--         if ( empty( $tags_sorted ) ) then
--                 return $return;
--         end;

--         if ( $tags_sorted !== $tags ) then
--                 $tags = $tags_sorted;
--                 unset( $tags_sorted );
--         end; else then
--                 if ( "RAND" === $args["order"] ) then
--                         shuffle( $tags );
--                 end; else then
--                         // SQL cannot save you; this is a second (potentially different) sort on a subset of data.
--                         if ( "name" === $args["orderby"] ) then
--                                 uasort( $tags, "_wp_object_name_sort_cb" );
--                         end; else then
--                                 uasort( $tags, "_wp_object_count_sort_cb" );
--                         end;

--                         if ( "DESC" === $args["order"] ) then
--                                 $tags = array_reverse( $tags, true );
--                         end;
--                 end;
--         end;

--         if ( $args["number"] > 0 ) then
--                 $tags = array_slice( $tags, 0, $args["number"] );
--         end;

--         $counts      = array();
--         $real_counts = array(); // For the alt tag.
--         foreach ( (array) $tags as $key => $tag ) then
--                 $real_counts[ $key ] = $tag->count;
--                 $counts[ $key ]      = call_user_func( $args["topic_count_scale_callback"], $tag->count );
--         end;

--         $min_count = min( $counts );
--         $spread    = max( $counts ) - $min_count;
--         if ( $spread <= 0 ) then
--                 $spread = 1;
--         end;
--         $font_spread = $args["largest"] - $args["smallest"];
--         if ( $font_spread < 0 ) then
--                 $font_spread = 1;
--         end;
--         $font_step = $font_spread / $spread;

--         $aria_label = false;
--         /*
--         -- Determine whether to output an "aria-label" attribute with the tag name and count.
--         -- When tags have a different font size, they visually convey an important information
--         -- that should be available to assistive technologies too. On the other hand, sometimes
--         -- themes set up the Tag Cloud to display all tags with the same font size (setting
--         -- the "smallest" and "largest" arguments to the same value).
--         -- In order to always serve the same content to all users, the "aria-label" gets printed out:
--         -- - when tags have a different size
--         -- - when the tag count is displayed (for example when users check the checkbox in the
--         --   Tag Cloud widget), regardless of the tags font size
--         --
--         if ( $args["show_count"] || 0 !== $font_spread ) then
--                 $aria_label = true;
--         end;

--         // Assemble the data that will be used to generate the tag cloud markup.
--         $tags_data = array();
--         foreach ( $tags as $key => $tag ) then
--                 $tag_id = isset( $tag->id ) ? $tag->id : $key;

--                 $count      = $counts[ $key ];
--                 $real_count = $real_counts[ $key ];

--                 if ( $translate_nooped_plural ) then
--                         $formatted_count = sprintf( translate_nooped_plural( $translate_nooped_plural, $real_count ), number_format_i18n( $real_count ) );
--                 end; else then
--                         $formatted_count = call_user_func( $args["topic_count_text_callback"], $real_count, $tag, $args );
--                 end;

--                 $tags_data[] = array(
--                         "id"              => $tag_id,
--                         "url"             => ( "#" !== $tag->link ) ? $tag->link : "#",
--                         "role"            => ( "#" !== $tag->link ) ? "" : " role="button"",
--                         "name"            => $tag->name,
--                         "formatted_count" => $formatted_count,
--                         "slug"            => $tag->slug,
--                         "real_count"      => $real_count,
--                         "class"           => "tag-cloud-link tag-link-" . $tag_id,
--                         "font_size"       => $args["smallest"] + ( $count - $min_count )-- $font_step,
--                         "aria_label"      => $aria_label ? sprintf( " aria-label="%1$s (%2$s)"", esc_attr( $tag->name ), esc_attr( $formatted_count ) ) : "",
--                         "show_count"      => $args["show_count"] ? "<span class="tag-link-count"> (" . $real_count . ")</span>" : "",
--                 );
--         end;

--         --
--         -- Filters the data used to generate the tag cloud.
--         --
--         -- @since 4.3.0
--         --
--         -- @param array[] $tags_data An array of term data arrays for terms used to generate the tag cloud.
--         --
--         $tags_data = apply_filters( "wp_generate_tag_cloud_data", $tags_data );

--         $a = array();

--         // Generate the output links array.
--         foreach ( $tags_data as $key => $tag_data ) then
--                 $class = $tag_data["class"] . " tag-link-position-" . ( $key + 1 );
--                 $a[]   = sprintf(
--                         "<a href="%1$s"%2$s class="%3$s" style="font-size: %4$s;"%5$s>%6$s%7$s</a>",
--                         esc_url( $tag_data["url"] ),
--                         $tag_data["role"],
--                         esc_attr( $class ),
--                         esc_attr( str_replace( ",", ".", $tag_data["font_size"] ) . $args["unit"] ),
--                         $tag_data["aria_label"],
--                         esc_html( $tag_data["name"] ),
--                         $tag_data["show_count"]
--                 );
--         end;

--         switch ( $args["format"] ) then
--                 case "array":
--                         $return =& $a;
--                         break;
--                 case "list":
--                         /*
--                         -- Force role="list", as some browsers (sic: Safari 10) don"t expose to assistive
--                         -- technologies the default role when the list is styled with `list-style: none`.
--                         -- Note: this is redundant but doesn"t harm.
--                         --
--                         $return  = "<ul class="wp-tag-cloud" role="list">\n\t<li>";
--                         $return .= implode( "</li>\n\t<li>", $a );
--                         $return .= "</li>\n</ul>\n";
--                         break;
--                 default:
--                         $return = implode( $args["separator"], $a );
--                         break;
--         end;

--         if ( $args["filter"] ) then
--                 --
--                 -- Filters the generated output of a tag cloud.
--                 --
--                 -- The filter is only evaluated if a true value is passed
--                 -- to the $filter argument in wp_generate_tag_cloud().
--                 --
--                 -- @since 2.3.0
--                 --
--                 -- @see wp_generate_tag_cloud()
--                 --
--                 -- @param string[]|string $return String containing the generated HTML tag cloud output
--                 --                                or an array of tag links if the "format" argument
--                 --                                equals "array".
--                 -- @param WP_Term[]       $tags   An array of terms used in the tag cloud.
--                 -- @param array           $args   An array of wp_generate_tag_cloud() arguments.
--                 --
--                 return apply_filters( "wp_generate_tag_cloud", $return, $tags, $args );
--         end; else then
--                 return $return;
--         end;
-- end;

--
-- Serves as a callback for comparing objects based on name.
--
-- Used with `uasort()`.
--
-- @since 3.1.0
-- @access private
--
-- @param object $a The first object to compare.
-- @param object $b The second object to compare.
-- @return int Negative number if `$a->name` is less than `$b->name`, zero if they are equal,
--             or greater than zero if `$a->name` is greater than `$b->name`.
--

-- function _wp_object_name_sort_cb( $a, $b ) then
--         return strnatcasecmp( $a->name, $b->name );
-- end;

--
-- Serves as a callback for comparing objects based on count.
--
-- Used with `uasort()`.
--
-- @since 3.1.0
-- @access private
--
-- @param object $a The first object to compare.
-- @param object $b The second object to compare.
-- @return bool Whether the count value for `$a` is greater than the count value for `$b`.
--

-- function _wp_object_count_sort_cb( $a, $b ) then
--         return ( $a->count > $b->count );
-- end;

--
-- Helper functions.
--

--
-- Retrieves HTML list content for category list.
--
-- @since 2.1.0
-- @since 5.3.0 Formalized the existing `...$args` parameter by adding it
--              to the function signature.
--
-- @uses Walker_Category to create HTML list content.
-- @see Walker::walk() for parameters and return description.
--
-- @param mixed ...$args Elements array, maximum hierarchical depth and optional additional arguments.
-- @return string
--

-- function walk_category_tree( ...$args ) then
--         // The user"s options are the third parameter.
--         if ( empty( $args[2]["walker"] ) || ! ( $args[2]["walker"] instanceof Walker ) ) then
--                 $walker = new Walker_Category;
--         end; else then
--                 --
--                 -- @var Walker $walker
--                 --
--                 $walker = $args[2]["walker"];
--         end;
--         return $walker->walk( ...$args );
-- end;

   ---------------------------------
   -- Walk_Category_Dropdown_Tree --
   ---------------------------------

   function Walk_Category_Dropdown_Tree
     (Categories : Array_Type; -- Class_Terms.Wp_Term_Array; -- ...$args
      Depth      : Integer;
      Args       : Array_Type)
      return String
   is
      use Class_Walker_Category_Dropdown;

      Walker : Walker_CategoryDropdown := X_Construct;
   begin
      -- The user's options are the third parameter.
      -- if empty( $args[2]["walker"] ) || ! ( $args[2]["walker"] instanceof Walker ) then
      --           walker = new Walker_CategoryDropdown;
      -- else
      --           --
      --           -- @var Walker $walker
      --           --
      --           walker = $args[2]["walker"];
      -- end if;
      return Walker.Walk (Categories, Depth, Args); -- (...$args)
   end Walk_Category_Dropdown_Tree;

--
-- Tags.
--

--
-- Retrieves the link to the tag.
--
-- @since 2.3.0
--
-- @see get_term_link()
--
-- @param int|object $tag Tag ID or object.
-- @return string Link on success, empty string if tag does not exist.
--

-- function get_tag_link( $tag ) then
--         return get_category_link( $tag );
-- end;

--
-- Retrieves the tags for a post.
--
-- @since 2.3.0
--
-- @param int|WP_Post $post Post ID or object.
-- @return WP_Term[]|false|WP_Error Array of WP_Term objects on success, false if there are no terms
--                                  or the post does not exist, WP_Error on failure.
--

-- function get_the_tags( $post = 0 ) then
--         $terms = get_the_terms( $post, "post_tag" );

--         --
--         -- Filters the array of tags for the given post.
--         --
--         -- @since 2.3.0
--         --
--         -- @see get_the_terms()
--         --
--         -- @param WP_Term[]|false|WP_Error $terms Array of WP_Term objects on success, false if there are no terms
--         --                                        or the post does not exist, WP_Error on failure.
--         --
--         return apply_filters( "get_the_tags", $terms );
-- end;

--
-- Retrieves the tags for a post formatted as a string.
--
-- @since 2.3.0
--
-- @param string $before  Optional. String to use before the tags. Default empty.
-- @param string $sep     Optional. String to use between the tags. Default empty.
-- @param string $after   Optional. String to use after the tags. Default empty.
-- @param int    $post_id Optional. Post ID. Defaults to the current post ID.
-- @return string|false|WP_Error A list of tags on success, false if there are no terms,
--                               WP_Error on failure.
--

-- function get_the_tag_list( $before = "", $sep = "", $after = "", $post_id = 0 ) then
--         $tag_list = get_the_term_list( $post_id, "post_tag", $before, $sep, $after );

--         --
--         -- Filters the tags list for a given post.
--         --
--         -- @since 2.3.0
--         --
--         -- @param string $tag_list List of tags.
--         -- @param string $before   String to use before the tags.
--         -- @param string $sep      String to use between the tags.
--         -- @param string $after    String to use after the tags.
--         -- @param int    $post_id  Post ID.
--         --
--         return apply_filters( "the_tags", $tag_list, $before, $sep, $after, $post_id );
-- end;

--
-- Displays the tags for a post.
--
-- @since 2.3.0
--
-- @param string $before Optional. String to use before the tags. Defaults to "Tags:".
-- @param string $sep    Optional. String to use between the tags. Default ", ".
-- @param string $after  Optional. String to use after the tags. Default empty.
--

-- function the_tags( $before = null, $sep = ", ", $after = "" ) then
--         if ( null === $before ) then
--                 $before = __( "Tags: " );
--         end;

--         $the_tags = get_the_tag_list( $before, $sep, $after );

--         if ( ! is_wp_error( $the_tags ) ) then
--                 echo $the_tags;
--         end;
-- end;

--
-- Retrieves tag description.
--
-- @since 2.8.0
--
-- @param int $tag Optional. Tag ID. Defaults to the current tag ID.
-- @return string Tag description, if available.
--

-- function tag_description( $tag = 0 ) then
--         return term_description( $tag );
-- end;

--
-- Retrieves term description.
--
-- @since 2.8.0
-- @since 4.9.2 The `$taxonomy` parameter was deprecated.
--
-- @param int  $term       Optional. Term ID. Defaults to the current term ID.
-- @param null $deprecated Deprecated. Not used.
-- @return string Term description, if available.
--

-- function term_description( $term = 0, $deprecated = null ) then
--         if ( ! $term && ( is_tax() || is_tag() || is_category() ) ) then
--                 $term = get_queried_object();
--                 if ( $term ) then
--                         $term = $term->term_id;
--                 end;
--         end;

--         $description = get_term_field( "description", $term );

--         return is_wp_error( $description ) ? "" : $description;
-- end;

   -------------------
   -- Get_The_Terms --
   -------------------

   function Get_The_Terms (Post     : Class_Posts.Wp_Post;
                           Taxonomy : String)
                           return Class_Terms.Wp_Term_Array
                           -- Inc_Class_Posts.Wp_Post
   is
      use Ada.Containers;
      use Wp_Common;
      use Adi_Caches;
      use Class_Terms;
      use Inc_Taxonomys;
      use Inc_Load;
      use Inc_Functions;

      Post_2 : constant Class_Posts.Wp_Post := Inc_Posts.Get_Post (Post);
   begin
--        if ( ! $post ) then
--                return false;
--        end;
      declare
         use Term_Vectors;
         use Integer_Vectors;

         Terms : Wp_Term_Array
            := Get_Object_Term_Cache (Integer (Post_2.Id), Taxonomy);
      begin
         if Length (Terms) = 0 then  -- false =
            Terms := Wp_Get_Object_Terms (Empty_Integer_Array & Integer (Post_2.Id),
                                          To_Array ((1 => Build (Taxonomy, ""))));
            if not Is_Wp_Error ("Terms") then
               declare
                  Term_Ids : constant Array_Type := Wp_List_Pluck (Terms, "term_id");
               begin
                  Wp_Cache_Add (Integer (Post_2.Id), Term_Ids,
                                Taxonomy & "_relationships");
               end;
            end if;
         end if;

         --
         -- Filters the list of terms attached to the given post.
         --
         -- @since 3.1.0
         --
         -- @param WP_Term[]|WP_Error $terms    Array of attached terms, or WP_Error on failure.
         -- @param int                $post_id  Post ID.
         -- @param string             $taxonomy Name of the taxonomy.
         --
         declare
            Terms_2 : constant Wp_Term_Array
               := Apply_Filters (Hook_Name => "get_the_terms",
                                 Value     => Terms,
                                 Id        => Post_2.Id'Image,
                                 Taxonomy  => Taxonomy);
         begin
            if Length (Terms_2) = 0 then
               raise Error; -- return False;
            end if;

            return Terms_2;
         end;
      end;
   end Get_The_Terms;

   function Get_The_Terms (Post     : Class_Posts.Post_Id;
                           Taxonomy : String)
                           return Class_Terms.Wp_Term_Array
                           is (raise Program_Error with "not implemented");

--
-- Retrieves a post's terms as a list with specified format.
--
-- Terms are linked to their respective term listing pages.
--
-- @since 2.5.0
--
-- @param int    $post_id  Post ID.
-- @param string $taxonomy Taxonomy name.
-- @param string $before   Optional. String to use before the terms. Default empty.
-- @param string $sep      Optional. String to use between the terms. Default empty.
-- @param string $after    Optional. String to use after the terms. Default empty.
-- @return string|false|WP_Error A list of terms on success, false if there are no terms,
--                               WP_Error on failure.
--

-- function get_the_term_list( $post_id, $taxonomy, $before = "", $sep = "", $after = "" ) then
--         $terms = get_the_terms( $post_id, $taxonomy );

--         if ( is_wp_error( $terms ) ) then
--                 return $terms;
--         end;

--         if ( empty( $terms ) ) then
--                 return false;
--         end;

--         $links = array();

--         foreach ( $terms as $term ) then
--                 $link = get_term_link( $term, $taxonomy );
--                 if ( is_wp_error( $link ) ) then
--                         return $link;
--                 end;
--                 $links[] = "<a href="" . esc_url( $link ) . "" rel="tag">" . $term->name . "</a>";
--         end;

--         --
--         -- Filters the term links for a given taxonomy.
--         --
--         -- The dynamic portion of the hook name, `$taxonomy`, refers
--         -- to the taxonomy slug.
--         --
--         -- Possible hook names include:
--         --
--         --  - `term_links-category`
--         --  - `term_links-post_tag`
--         --  - `term_links-post_format`
--         --
--         -- @since 2.5.0
--         --
--         -- @param string[] $links An array of term links.
--         --
--         $term_links = apply_filters( "term_links-then$taxonomyend;", $links );  // phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

--         return $before . implode( $sep, $term_links ) . $after;
-- end;

   ---------------------------
   -- Get_Term_Parents_List --
   ---------------------------

   function Get_Term_Parents_List (Term_Id  : Integer;
                                   Taxonomy : String;
                                   Args     : Array_Type := Empty_Array)
                                   return String -- List_Type
   is
      use UStrings;
      use Class_Taxonomy;
      use Class_Terms;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Taxonomys;

      List : UString;
      Term : constant Wp_Term := Get_Term (Term_Id, Taxonomy);
   begin
      if Is_Wp_Error (Term) then
         return "TERM"; -- Term;
      end if;

      if Term = Null_Term then
--    if not Term then
         return -List;
      end if;

      declare
         Term_Id_2 : constant Integer := Term.Term_Id;

         Defaults : constant Array_Type := To_Array (List => (
                Build ("format",    "name"),
                Build ("separator", "/"),
                Build ("link",      True),
                Build ("inclusive", True)
         ));

         Args_2 : Array_Type := Wp_Parse_Args (Args, Defaults);
      begin
         for Bool of To_List (List => (+"link", +"inclusive")) loop
            Set (Args_2, -Bool,
                 From_Boolean (Wp_Validate_Boolean (Get (Args_2, -Bool))));
         end loop;

         declare
            Parents : constant Int_Arrays.Vector :=
              Get_Ancestors (Term_Id_2, Taxonomy, "taxonomy");
         begin
            if As_Boolean (Get (Args_2, "inclusive")) then
               null;
--             Parents := Parents & Term_Id_2;
--             Array_Unshift (Parents, Term_Id_2);
            end if;

            for Term_Id of reverse Parents loop -- Array_Reverse (Parents) loop
               declare
                  Parent : Wp_Term := Get_Term (Term_Id, Taxonomy);

                  Name : constant String :=
                    -(if "slug" = Get_As_String (Args_2, "format")
                      then Parent.Slug else Parent.Name);
               begin
                  if Get_As_String (Args_2, "link") /= "" then
                     Append (List,
                             "<a href=""" &
                             ESC_URL (Get_Term_Link (Parent.Term_Id, Taxonomy)) &
                             """>" & Name & "</a>" &
                             Get_As_String (Args_2, "separator"));
                  else
                     Append (List, Name & Get_As_String (Args_2, "separator"));
                  end if;
               end;
            end loop;
         end;
      end;
      return -List;
   end Get_Term_Parents_List;

--
-- Displays the terms for a post in a list.
--
-- @since 2.5.0
--
-- @param int    post_id  Post ID.
-- @param string taxonomy Taxonomy name.
-- @param string before   Optional. String to use before the terms. Default empty.
-- @param string sep      Optional. String to use between the terms. Default ", ".
-- @param string after    Optional. String to use after the terms. Default empty.
-- @return void|false Void on success, false on failure.
--

-- function the_terms( post_id, taxonomy, before = "", sep = ", ", after = "" ) then
--         term_list = get_the_term_list( post_id, taxonomy, before, sep, after );

--         if ( is_wp_error( term_list ) ) then
--                 return false;
--         end;

--         --
--         -- Filters the list of terms to display.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string term_list List of terms to display.
--         -- @param string taxonomy  The taxonomy name.
--         -- @param string before    String to use before the terms.
--         -- @param string sep       String to use between the terms.
--         -- @param string after     String to use after the terms.
--         --
--         echo apply_filters( "the_terms", term_list, taxonomy, before, sep, after );
-- end;

--
-- Checks if the current post has any of given category.
--
-- The given categories are checked against the post"s categories" term_ids, names and slugs.
-- Categories given as integers will only be checked against the post"s categories" term_ids.
--
-- If no categories are given, determines if post has any categories.
--
-- @since 3.1.0
--
-- @param string|int|array category Optional. The category name/term_id/slug,
--                                   or an array of them to check for. Default empty.
-- @param int|WP_Post      post     Optional. Post to check. Defaults to the current post.
-- @return bool True if the current post has any of the given categories
--              (or any category, if no category specified). False otherwise.
--

-- function has_category( category = "", post = null ) then
--         return has_term( category, "category", post );
-- end;

--
-- Checks if the current post has any of given tags.
--
-- The given tags are checked against the post"s tags" term_ids, names and slugs.
-- Tags given as integers will only be checked against the post"s tags" term_ids.
--
-- If no tags are given, determines if post has any tags.
--
-- For more information on this and similar theme functions, check out
-- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tags} article in the Theme Developer Handbook.
--
-- @since 2.6.0
-- @since 2.7.0 Tags given as integers are only checked against
--              the post"s tags" term_ids, not names or slugs.
-- @since 2.7.0 Can be used outside of the WordPress Loop if `post` is provided.
--
-- @param string|int|array tag  Optional. The tag name/term_id/slug,
--                               or an array of them to check for. Default empty.
-- @param int|WP_Post      post Optional. Post to check. Defaults to the current post.
-- @return bool True if the current post has any of the given tags
--              (or any tag, if no tag specified). False otherwise.
--

-- function has_tag( tag = "", post = null ) then
--         return has_term( tag, "post_tag", post );
-- end;

--
-- Checks if the current post has any of given terms.
--
-- The given terms are checked against the post"s terms" term_ids, names and slugs.
-- Terms given as integers will only be checked against the post"s terms" term_ids.
--
-- If no terms are given, determines if post has any terms.
--
-- @since 3.1.0
--
-- @param string|int|array term     Optional. The term name/term_id/slug,
--                                   or an array of them to check for. Default empty.
-- @param string           taxonomy Optional. Taxonomy name. Default empty.
-- @param int|WP_Post      post     Optional. Post to check. Defaults to the current post.
-- @return bool True if the current post has any of the given terms
--              (or any term, if no term specified). False otherwise.
--

-- function has_term( term = "", taxonomy = "", post = null ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return false;
--         end;

--         r = is_object_in_term( post->ID, taxonomy, term );
--         if ( is_wp_error( r ) ) then
--                 return false;
--         end;

--         return r;
-- end;

end Inc_Category_Templates;
