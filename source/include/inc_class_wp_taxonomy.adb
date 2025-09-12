-- --
-- -- Taxonomy API: WP_Taxonomy class
-- --
-- -- @package WordPress
-- -- @subpackage Taxonomy
-- -- @since 4.7.0
-- --

package body Inc_Class_Wp_Taxonomy
is
   procedure Dummy is null;
--         --
--         -- Constructor.
--         --
--         -- See the register_taxonomy() function for accepted arguments for `args`.
--         --
--         -- @since 4.7.0
--         --
--         -- @global WP wp Current WordPress environment instance.
--         --
--         -- @param string       taxonomy    Taxonomy key, must not exceed 32 characters.
--         -- @param array|string object_type Name of the object type for the taxonomy object.
--         -- @param array|string args        Optional. Array or query string of arguments for registering a taxonomy.
--         --                                  Default empty array.
--         --
--         public function __construct( taxonomy, object_type, args = array() ) then
--                 this->name = taxonomy;

--                 this->set_props( object_type, args );
--         end;

--         --
--         -- Sets taxonomy properties.
--         --
--         -- See the register_taxonomy() function for accepted arguments for `args`.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string|string[] object_type Name or array of names of the object types for the taxonomy.
--         -- @param array|string    args        Array or query string of arguments for registering a taxonomy.
--         --
--         public function set_props( object_type, args ) then
--                 args = wp_parse_args( args );

--                 --
--                 -- Filters the arguments for registering a taxonomy.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param array    args        Array of arguments for registering a taxonomy.
--                 --                              See the register_taxonomy() function for accepted arguments.
--                 -- @param string   taxonomy    Taxonomy key.
--                 -- @param string[] object_type Array of names of object types for the taxonomy.
--                 --
--                 args = apply_filters( 'register_taxonomy_args', args, this->name, (array) object_type );

--                 taxonomy = this->name;

--                 --
--                 -- Filters the arguments for registering a specific taxonomy.
--                 --
--                 -- The dynamic portion of the filter name, `taxonomy`, refers to the taxonomy key.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `register_category_taxonomy_args`
--                 --  - `register_post_tag_taxonomy_args`
--                 --
--                 -- @since 6.0.0
--                 --
--                 -- @param array    args        Array of arguments for registering a taxonomy.
--                 --                              See the register_taxonomy() function for accepted arguments.
--                 -- @param string   taxonomy    Taxonomy key.
--                 -- @param string[] object_type Array of names of object types for the taxonomy.
--                 --
--                 args = apply_filters( "register_thentaxonomyend;_taxonomy_args", args, this->name, (array) object_type );

--                 defaults = array(
--                         'labels'                => array(),
--                         'description'           => '',
--                         'public'                => true,
--                         'publicly_queryable'    => null,
--                         'hierarchical'          => false,
--                         'show_ui'               => null,
--                         'show_in_menu'          => null,
--                         'show_in_nav_menus'     => null,
--                         'show_tagcloud'         => null,
--                         'show_in_quick_edit'    => null,
--                         'show_admin_column'     => false,
--                         'meta_box_cb'           => null,
--                         'meta_box_sanitize_cb'  => null,
--                         'capabilities'          => array(),
--                         'rewrite'               => true,
--                         'query_var'             => this->name,
--                         'update_count_callback' => '',
--                         'show_in_rest'          => false,
--                         'rest_base'             => false,
--                         'rest_namespace'        => false,
--                         'rest_controller_class' => false,
--                         'default_term'          => null,
--                         'sort'                  => null,
--                         'args'                  => null,
--                         '_builtin'              => false,
--                 );

--                 args = array_merge( defaults, args );

--                 // If not set, default to the setting for 'public'.
--                 if ( null === args['publicly_queryable'] ) then
--                         args['publicly_queryable'] = args['public'];
--                 end;

--                 if ( false !== args['query_var'] && ( is_admin() || false !== args['publicly_queryable'] ) ) then
--                         if ( true === args['query_var'] ) then
--                                 args['query_var'] = this->name;
--                         end; else then
--                                 args['query_var'] = sanitize_title_with_dashes( args['query_var'] );
--                         end;
--                 end; else then
--                         // Force 'query_var' to false for non-public taxonomies.
--                         args['query_var'] = false;
--                 end;

--                 if ( false !== args['rewrite'] && ( is_admin() || get_option( 'permalink_structure' ) ) ) then
--                         args['rewrite'] = wp_parse_args(
--                                 args['rewrite'],
--                                 array(
--                                         'with_front'   => true,
--                                         'hierarchical' => false,
--                                         'ep_mask'      => EP_NONE,
--                                 )
--                         );

--                         if ( empty( args['rewrite']['slug'] ) ) then
--                                 args['rewrite']['slug'] = sanitize_title_with_dashes( this->name );
--                         end;
--                 end;

--                 // If not set, default to the setting for 'public'.
--                 if ( null === args['show_ui'] ) then
--                         args['show_ui'] = args['public'];
--                 end;

--                 // If not set, default to the setting for 'show_ui'.
--                 if ( null === args['show_in_menu'] || ! args['show_ui'] ) then
--                         args['show_in_menu'] = args['show_ui'];
--                 end;

--                 // If not set, default to the setting for 'public'.
--                 if ( null === args['show_in_nav_menus'] ) then
--                         args['show_in_nav_menus'] = args['public'];
--                 end;

--                 // If not set, default to the setting for 'show_ui'.
--                 if ( null === args['show_tagcloud'] ) then
--                         args['show_tagcloud'] = args['show_ui'];
--                 end;

--                 // If not set, default to the setting for 'show_ui'.
--                 if ( null === args['show_in_quick_edit'] ) then
--                         args['show_in_quick_edit'] = args['show_ui'];
--                 end;

--                 // If not set, default rest_namespace to wp/v2 if show_in_rest is true.
--                 if ( false === args['rest_namespace'] && ! empty( args['show_in_rest'] ) ) then
--                         args['rest_namespace'] = 'wp/v2';
--                 end;

--                 default_caps = array(
--                         'manage_terms' => 'manage_categories',
--                         'edit_terms'   => 'manage_categories',
--                         'delete_terms' => 'manage_categories',
--                         'assign_terms' => 'edit_posts',
--                 );

--                 args['cap'] = (object) array_merge( default_caps, args['capabilities'] );
--                 unset( args['capabilities'] );

--                 args['object_type'] = array_unique( (array) object_type );

--                 // If not set, use the default meta box.
--                 if ( null === args['meta_box_cb'] ) then
--                         if ( args['hierarchical'] ) then
--                                 args['meta_box_cb'] = 'post_categories_meta_box';
--                         end; else then
--                                 args['meta_box_cb'] = 'post_tags_meta_box';
--                         end;
--                 end;

--                 args['name'] = this->name;

--                 // Default meta box sanitization callback depends on the value of 'meta_box_cb'.
--                 if ( null === args['meta_box_sanitize_cb'] ) then
--                         switch ( args['meta_box_cb'] ) then
--                                 case 'post_categories_meta_box':
--                                         args['meta_box_sanitize_cb'] = 'taxonomy_meta_box_sanitize_cb_checkboxes';
--                                         break;

--                                 case 'post_tags_meta_box':
--                                 default:
--                                         args['meta_box_sanitize_cb'] = 'taxonomy_meta_box_sanitize_cb_input';
--                                         break;
--                         end;
--                 end;

--                 // Default taxonomy term.
--                 if ( ! empty( args['default_term'] ) ) then
--                         if ( ! is_array( args['default_term'] ) ) then
--                                 args['default_term'] = array( 'name' => args['default_term'] );
--                         end;
--                         args['default_term'] = wp_parse_args(
--                                 args['default_term'],
--                                 array(
--                                         'name'        => '',
--                                         'slug'        => '',
--                                         'description' => '',
--                                 )
--                         );
--                 end;

--                 foreach ( args as property_name => property_value ) then
--                         this->property_name = property_value;
--                 end;

--                 this->labels = get_taxonomy_labels( this );
--                 this->label  = this->labels->name;
--         end;

--         --
--         -- Adds the necessary rewrite rules for the taxonomy.
--         --
--         -- @since 4.7.0
--         --
--         -- @global WP wp Current WordPress environment instance.
--         --
--         public function add_rewrite_rules() then
--                 /* @var WP wp--
--                 global wp;

--                 // Non-publicly queryable taxonomies should not register query vars, except in the admin.
--                 if ( false !== this->query_var && wp ) then
--                         wp->add_query_var( this->query_var );
--                 end;

--                 if ( false !== this->rewrite && ( is_admin() || get_option( 'permalink_structure' ) ) ) then
--                         if ( this->hierarchical && this->rewrite['hierarchical'] ) then
--                                 tag = '(.+?)';
--                         end; else then
--                                 tag = '([^/]+)';
--                         end;

--                         add_rewrite_tag( "%this->name%", tag, this->query_var ? "thenthis->query_varend;=" : "taxonomy=this->name&term=" );
--                         add_permastruct( this->name, "thenthis->rewrite['slug']end;/%this->name%", this->rewrite );
--                 end;
--         end;

--         --
--         -- Removes any rewrite rules, permastructs, and rules for the taxonomy.
--         --
--         -- @since 4.7.0
--         --
--         -- @global WP wp Current WordPress environment instance.
--         --
--         public function remove_rewrite_rules() then
--                 /* @var WP wp--
--                 global wp;

--                 // Remove query var.
--                 if ( false !== this->query_var ) then
--                         wp->remove_query_var( this->query_var );
--                 end;

--                 // Remove rewrite tags and permastructs.
--                 if ( false !== this->rewrite ) then
--                         remove_rewrite_tag( "%this->name%" );
--                         remove_permastruct( this->name );
--                 end;
--         end;

--         --
--         -- Registers the ajax callback for the meta box.
--         --
--         -- @since 4.7.0
--         --
--         public function add_hooks() then
--                 add_filter( 'wp_ajax_add-' . this->name, '_wp_ajax_add_hierarchical_term' );
--         end;

--         --
--         -- Removes the ajax callback for the meta box.
--         --
--         -- @since 4.7.0
--         --
--         public function remove_hooks() then
--                 remove_filter( 'wp_ajax_add-' . this->name, '_wp_ajax_add_hierarchical_term' );
--         end;

--         --
--         -- Gets the REST API controller for this taxonomy.
--         --
--         -- Will only instantiate the controller class once per request.
--         --
--         -- @since 5.5.0
--         --
--         -- @return WP_REST_Controller|null The controller instance, or null if the taxonomy
--         --                                 is set not to show in rest.
--         --
--         public function get_rest_controller() then
--                 if ( ! this->show_in_rest ) then
--                         return null;
--                 end;

--                 class = this->rest_controller_class ? this->rest_controller_class : WP_REST_Terms_Controller::class;

--                 if ( ! class_exists( class ) ) then
--                         return null;
--                 end;

--                 if ( ! is_subclass_of( class, WP_REST_Controller::class ) ) then
--                         return null;
--                 end;

--                 if ( ! this->rest_controller ) then
--                         this->rest_controller = new class( this->name );
--                 end;

--                 if ( ! ( this->rest_controller instanceof class ) ) then
--                         return null;
--                 end;

--                 return this->rest_controller;
--         end;

--         --
--         -- Returns the default labels for taxonomies.
--         --
--         -- @since 6.0.0
--         --
--         -- @return (string|null)[][] The default labels for taxonomies.
--         --
--         public static function get_default_labels() then
--                 if ( ! empty( self::default_labels ) ) then
--                         return self::default_labels;
--                 end;

--                 name_field_description   = __( 'The name is how it appears on your site.' );
--                 slug_field_description   = __( 'The &#8220;slug&#8221; is the URL-friendly version of the name. It is usually all lowercase and contains only letters, numbers, and hyphens.' );
--                 parent_field_description = __( 'Assign a parent term to create a hierarchy. The term Jazz, for example, would be the parent of Bebop and Big Band.' );
--                 desc_field_description   = __( 'The description is not prominent by default; however, some themes may show it.' );

--                 self::default_labels = array(
--                         'name'                       => array( _x( 'Tags', 'taxonomy general name' ), _x( 'Categories', 'taxonomy general name' ) ),
--                         'singular_name'              => array( _x( 'Tag', 'taxonomy singular name' ), _x( 'Category', 'taxonomy singular name' ) ),
--                         'search_items'               => array( __( 'Search Tags' ), __( 'Search Categories' ) ),
--                         'popular_items'              => array( __( 'Popular Tags' ), null ),
--                         'all_items'                  => array( __( 'All Tags' ), __( 'All Categories' ) ),
--                         'parent_item'                => array( null, __( 'Parent Category' ) ),
--                         'parent_item_colon'          => array( null, __( 'Parent Category:' ) ),
--                         'name_field_description'     => array( name_field_description, name_field_description ),
--                         'slug_field_description'     => array( slug_field_description, slug_field_description ),
--                         'parent_field_description'   => array( null, parent_field_description ),
--                         'desc_field_description'     => array( desc_field_description, desc_field_description ),
--                         'edit_item'                  => array( __( 'Edit Tag' ), __( 'Edit Category' ) ),
--                         'view_item'                  => array( __( 'View Tag' ), __( 'View Category' ) ),
--                         'update_item'                => array( __( 'Update Tag' ), __( 'Update Category' ) ),
--                         'add_new_item'               => array( __( 'Add New Tag' ), __( 'Add New Category' ) ),
--                         'new_item_name'              => array( __( 'New Tag Name' ), __( 'New Category Name' ) ),
--                         'separate_items_with_commas' => array( __( 'Separate tags with commas' ), null ),
--                         'add_or_remove_items'        => array( __( 'Add or remove tags' ), null ),
--                         'choose_from_most_used'      => array( __( 'Choose from the most used tags' ), null ),
--                         'not_found'                  => array( __( 'No tags found.' ), __( 'No categories found.' ) ),
--                         'no_terms'                   => array( __( 'No tags' ), __( 'No categories' ) ),
--                         'filter_by_item'             => array( null, __( 'Filter by category' ) ),
--                         'items_list_navigation'      => array( __( 'Tags list navigation' ), __( 'Categories list navigation' ) ),
--                         'items_list'                 => array( __( 'Tags list' ), __( 'Categories list' ) ),
--                         /* translators: Tab heading when selecting from the most used terms.--
--                         'most_used'                  => array( _x( 'Most Used', 'tags' ), _x( 'Most Used', 'categories' ) ),
--                         'back_to_items'              => array( __( '&larr; Go to Tags' ), __( '&larr; Go to Categories' ) ),
--                         'item_link'                  => array(
--                                 _x( 'Tag Link', 'navigation link block title' ),
--                                 _x( 'Category Link', 'navigation link block title' ),
--                         ),
--                         'item_link_description'      => array(
--                                 _x( 'A link to a tag.', 'navigation link block description' ),
--                                 _x( 'A link to a category.', 'navigation link block description' ),
--                         ),
--                 );

--                 return self::default_labels;
--         end;

--         --
--         -- Resets the cache for the default labels.
--         --
--         -- @since 6.0.0
--         --
--         public static function reset_default_labels() then
--                 self::default_labels = array();
--         end;
-- end;

end Inc_Class_Wp_Taxonomy;
