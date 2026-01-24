--
-- Post API: WP_Post_Type class
--
-- @package WordPress
-- @subpackage Post
-- @since 4.6.0
--

package body Class_Post_Type
is

--         --
--         -- Constructor.
--         --
--         -- See the register_post_type() function for accepted arguments for `args`.
--         --
--         -- Will populate object properties from the provided arguments and assign other
--         -- default properties based on that information.
--         --
--         -- @since 4.6.0
--         --
--         -- @see register_post_type()
--         --
--         -- @param string       post_type Post type key.
--         -- @param array|string args      Optional. Array or string of arguments for registering a post type.
--         --                                Default empty array.
--         --
--         public function __construct( post_type, args = array() ) then
--                 this->name = post_type;

--                 this->set_props( args );
--         end;

--         --
--         -- Sets post type properties.
--         --
--         -- See the register_post_type() function for accepted arguments for `args`.
--         --
--         -- @since 4.6.0
--         --
--         -- @param array|string args Array or string of arguments for registering a post type.
--         --
--         public function set_props( args ) then
--                 args = wp_parse_args( args );

--                 --
--                 -- Filters the arguments for registering a post type.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param array  args      Array of arguments for registering a post type.
--                 --                          See the register_post_type() function for accepted arguments.
--                 -- @param string post_type Post type key.
--                 --
--                 args = apply_filters( "register_post_type_args", args, this->name );

--                 post_type = this->name;

--                 --
--                 -- Filters the arguments for registering a specific post type.
--                 --
--                 -- The dynamic portion of the filter name, `post_type`, refers to the post type key.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `register_post_post_type_args`
--                 --  - `register_page_post_type_args`
--                 --
--                 -- @since 6.0.0
--                 --
--                 -- @param array  args      Array of arguments for registering a post type.
--                 --                          See the register_post_type() function for accepted arguments.
--                 -- @param string post_type Post type key.
--                 --
--                 args = apply_filters( "register_thenpost_typeend;_post_type_args", args, this->name );

--                 has_edit_link = ! empty( args["_edit_link"] );

--                 // Args prefixed with an underscore are reserved for internal use.
--                 defaults = array(
--                         "labels"                => array(),
--                         "description"           => "",
--                         "public"                => false,
--                         "hierarchical"          => false,
--                         "exclude_from_search"   => null,
--                         "publicly_queryable"    => null,
--                         "show_ui"               => null,
--                         "show_in_menu"          => null,
--                         "show_in_nav_menus"     => null,
--                         "show_in_admin_bar"     => null,
--                         "menu_position"         => null,
--                         "menu_icon"             => null,
--                         "capability_type"       => "post",
--                         "capabilities"          => array(),
--                         "map_meta_cap"          => null,
--                         "supports"              => array(),
--                         "register_meta_box_cb"  => null,
--                         "taxonomies"            => array(),
--                         "has_archive"           => false,
--                         "rewrite"               => true,
--                         "query_var"             => true,
--                         "can_export"            => true,
--                         "delete_with_user"      => null,
--                         "show_in_rest"          => false,
--                         "rest_base"             => false,
--                         "rest_namespace"        => false,
--                         "rest_controller_class" => false,
--                         "template"              => array(),
--                         "template_lock"         => false,
--                         "_builtin"              => false,
--                         "_edit_link"            => "post.php?post=%d",
--                 );

--                 args = array_merge( defaults, args );

--                 args["name"] = this->name;

--                 // If not set, default to the setting for "public".
--                 if ( null === args["publicly_queryable"] ) then
--                         args["publicly_queryable"] = args["public"];
--                 end;

--                 // If not set, default to the setting for "public".
--                 if ( null === args["show_ui"] ) then
--                         args["show_ui"] = args["public"];
--                 end;

--                 // If not set, default rest_namespace to wp/v2 if show_in_rest is true.
--                 if ( false === args["rest_namespace"] && ! empty( args["show_in_rest"] ) ) then
--                         args["rest_namespace"] = "wp/v2";
--                 end;

--                 // If not set, default to the setting for "show_ui".
--                 if ( null === args["show_in_menu"] || ! args["show_ui"] ) then
--                         args["show_in_menu"] = args["show_ui"];
--                 end;

--                 // If not set, default to the setting for "show_in_menu".
--                 if ( null === args["show_in_admin_bar"] ) then
--                         args["show_in_admin_bar"] = (bool) args["show_in_menu"];
--                 end;

--                 // If not set, default to the setting for "public".
--                 if ( null === args["show_in_nav_menus"] ) then
--                         args["show_in_nav_menus"] = args["public"];
--                 end;

--                 // If not set, default to true if not public, false if public.
--                 if ( null === args["exclude_from_search"] ) then
--                         args["exclude_from_search"] = ! args["public"];
--                 end;

--                 // Back compat with quirky handling in version 3.0. #14122.
--                 if ( empty( args["capabilities"] )
--                         && null === args["map_meta_cap"] && in_array( args["capability_type"], array( "post", "page" ), true )
--                 ) then
--                         args["map_meta_cap"] = true;
--                 end;

--                 // If not set, default to false.
--                 if ( null === args["map_meta_cap"] ) then
--                         args["map_meta_cap"] = false;
--                 end;

--                 -- If there's no specified edit link and no UI, remove the edit link.
--                 if ( ! args["show_ui"] && ! has_edit_link ) then
--                         args["_edit_link"] = "";
--                 end;

--                 this->cap = get_post_type_capabilities( (object) args );
--                 unset( args["capabilities"] );

--                 if ( is_array( args["capability_type"] ) ) then
--                         args["capability_type"] = args["capability_type"][0];
--                 end;

--                 if ( false !== args["query_var"] ) then
--                         if ( true === args["query_var"] ) then
--                                 args["query_var"] = this->name;
--                         end; else then
--                                 args["query_var"] = sanitize_title_with_dashes( args["query_var"] );
--                         end;
--                 end;

--                 if ( false !== args["rewrite"] && ( is_admin() || get_option( "permalink_structure" ) ) ) then
--                         if ( ! is_array( args["rewrite"] ) ) then
--                                 args["rewrite"] = array();
--                         end;
--                         if ( empty( args["rewrite"]["slug"] ) ) then
--                                 args["rewrite"]["slug"] = this->name;
--                         end;
--                         if ( ! isset( args["rewrite"]["with_front"] ) ) then
--                                 args["rewrite"]["with_front"] = true;
--                         end;
--                         if ( ! isset( args["rewrite"]["pages"] ) ) then
--                                 args["rewrite"]["pages"] = true;
--                         end;
--                         if ( ! isset( args["rewrite"]["feeds"] ) || ! args["has_archive"] ) then
--                                 args["rewrite"]["feeds"] = (bool) args["has_archive"];
--                         end;
--                         if ( ! isset( args["rewrite"]["ep_mask"] ) ) then
--                                 if ( isset( args["permalink_epmask"] ) ) then
--                                         args["rewrite"]["ep_mask"] = args["permalink_epmask"];
--                                 end; else then
--                                         args["rewrite"]["ep_mask"] = EP_PERMALINK;
--                                 end;
--                         end;
--                 end;

--                 foreach ( args as property_name => property_value ) then
--                         this->property_name = property_value;
--                 end;

--                 this->labels = get_post_type_labels( this );
--                 this->label  = this->labels->name;
--         end;

--         --
--         -- Sets the features support for the post type.
--         --
--         -- @since 4.6.0
--         --
--         public function add_supports() then
--                 if ( ! empty( this->supports ) ) then
--                         foreach ( this->supports as feature => args ) then
--                                 if ( is_array( args ) ) then
--                                         add_post_type_support( this->name, feature, args );
--                                 end; else then
--                                         add_post_type_support( this->name, args );
--                                 end;
--                         end;
--                         unset( this->supports );
--                 end; elseif ( false !== this->supports ) then
--                         // Add default features.
--                         add_post_type_support( this->name, array( "title", "editor" ) );
--                 end;
--         end;

--         --
--         -- Adds the necessary rewrite rules for the post type.
--         --
--         -- @since 4.6.0
--         --
--         -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
--         -- @global WP         wp         Current WordPress environment instance.
--         --
--         public function add_rewrite_rules() then
--                 global wp_rewrite, wp;

--                 if ( false !== this->query_var && wp && is_post_type_viewable( this ) ) then
--                         wp->add_query_var( this->query_var );
--                 end;

--                 if ( false !== this->rewrite && ( is_admin() || get_option( "permalink_structure" ) ) ) then
--                         if ( this->hierarchical ) then
--                                 add_rewrite_tag( "%this->name%", "(.+?)", this->query_var ? "thenthis->query_varend;=" : "post_type=this->name&pagename=" );
--                         end; else then
--                                 add_rewrite_tag( "%this->name%", "([^/]+)", this->query_var ? "thenthis->query_varend;=" : "post_type=this->name&name=" );
--                         end;

--                         if ( this->has_archive ) then
--                                 archive_slug = true === this->has_archive ? this->rewrite["slug"] : this->has_archive;
--                                 if ( this->rewrite["with_front"] ) then
--                                         archive_slug = substr( wp_rewrite->front, 1 ) . archive_slug;
--                                 end; else then
--                                         archive_slug = wp_rewrite->root . archive_slug;
--                                 end;

--                                 add_rewrite_rule( "thenarchive_slugend;/?", "index.php?post_type=this->name", "top" );
--                                 if ( this->rewrite["feeds"] && wp_rewrite->feeds ) then
--                                         feeds = "(" . trim( implode( "|", wp_rewrite->feeds ) ) . ")";
--                                         add_rewrite_rule( "thenarchive_slugend;/feed/feeds/?", "index.php?post_type=this->name" . "&feed=matches[1]", "top" );
--                                         add_rewrite_rule( "thenarchive_slugend;/feeds/?", "index.php?post_type=this->name" . "&feed=matches[1]", "top" );
--                                 end;
--                                 if ( this->rewrite["pages"] ) then
--                                         add_rewrite_rule( "thenarchive_slugend;/thenwp_rewrite->pagination_baseend;/([0-9]then1,end;)/?", "index.php?post_type=this->name" . "&paged=matches[1]", "top" );
--                                 end;
--                         end;

--                         permastruct_args         = this->rewrite;
--                         permastruct_args["feed"] = permastruct_args["feeds"];
--                         add_permastruct( this->name, "thenthis->rewrite["slug"]end;/%this->name%", permastruct_args );
--                 end;
--         end;

--         --
--         -- Registers the post type meta box if a custom callback was specified.
--         --
--         -- @since 4.6.0
--         --
--         public function register_meta_boxes() then
--                 if ( this->register_meta_box_cb ) then
--                         add_action( "add_meta_boxes_" . this->name, this->register_meta_box_cb, 10, 1 );
--                 end;
--         end;

--         --
--         -- Adds the future post hook action for the post type.
--         --
--         -- @since 4.6.0
--         --
--         public function add_hooks() then
--                 add_action( "future_" . this->name, "_future_post_hook", 5, 2 );
--         end;

--         --
--         -- Registers the taxonomies for the post type.
--         --
--         -- @since 4.6.0
--         --
--         public function register_taxonomies() then
--                 foreach ( this->taxonomies as taxonomy ) then
--                         register_taxonomy_for_object_type( taxonomy, this->name );
--                 end;
--         end;

--         --
--         -- Removes the features support for the post type.
--         --
--         -- @since 4.6.0
--         --
--         -- @global array _wp_post_type_features Post type features.
--         --
--         public function remove_supports() then
--                 global _wp_post_type_features;

--                 unset( _wp_post_type_features[ this->name ] );
--         end;

--         --
--         -- Removes any rewrite rules, permastructs, and rules for the post type.
--         --
--         -- @since 4.6.0
--         --
--         -- @global WP_Rewrite wp_rewrite          WordPress rewrite component.
--         -- @global WP         wp                  Current WordPress environment instance.
--         -- @global array      post_type_meta_caps Used to remove meta capabilities.
--         --
--         public function remove_rewrite_rules() then
--                 global wp, wp_rewrite, post_type_meta_caps;

--                 // Remove query var.
--                 if ( false !== this->query_var ) then
--                         wp->remove_query_var( this->query_var );
--                 end;

--                 // Remove any rewrite rules, permastructs, and rules.
--                 if ( false !== this->rewrite ) then
--                         remove_rewrite_tag( "%this->name%" );
--                         remove_permastruct( this->name );
--                         foreach ( wp_rewrite->extra_rules_top as regex => query ) then
--                                 if ( false !== strpos( query, "index.php?post_type=this->name" ) ) then
--                                         unset( wp_rewrite->extra_rules_top[ regex ] );
--                                 end;
--                         end;
--                 end;

--                 // Remove registered custom meta capabilities.
--                 foreach ( this->cap as cap ) then
--                         unset( post_type_meta_caps[ cap ] );
--                 end;
--         end;

--         --
--         -- Unregisters the post type meta box if a custom callback was specified.
--         --
--         -- @since 4.6.0
--         --
--         public function unregister_meta_boxes() then
--                 if ( this->register_meta_box_cb ) then
--                         remove_action( "add_meta_boxes_" . this->name, this->register_meta_box_cb, 10 );
--                 end;
--         end;

--         --
--         -- Removes the post type from all taxonomies.
--         --
--         -- @since 4.6.0
--         --
--         public function unregister_taxonomies() then
--                 foreach ( get_object_taxonomies( this->name ) as taxonomy ) then
--                         unregister_taxonomy_for_object_type( taxonomy, this->name );
--                 end;
--         end;

--         --
--         -- Removes the future post hook action for the post type.
--         --
--         -- @since 4.6.0
--         --
--         public function remove_hooks() then
--                 remove_action( "future_" . this->name, "_future_post_hook", 5 );
--         end;

--         --
--         -- Gets the REST API controller for this post type.
--         --
--         -- Will only instantiate the controller class once per request.
--         --
--         -- @since 5.3.0
--         --
--         -- @return WP_REST_Controller|null The controller instance, or null if the post type
--         --                                 is set not to show in rest.
--         --
--         public function get_rest_controller() then
--                 if ( ! this->show_in_rest ) then
--                         return null;
--                 end;

--                 class = this->rest_controller_class ? this->rest_controller_class : WP_REST_Posts_Controller::class;

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
--         -- Returns the default labels for post types.
--         --
--         -- @since 6.0.0
--         --
--         -- @return (string|null)[][] The default labels for post types.
--         --
--         public static function get_default_labels() then
--                 if ( ! empty( self::default_labels ) ) then
--                         return self::default_labels;
--                 end;

--                 self::default_labels = array(
--                         "name"                     => array( _x( "Posts", "post type general name" ), _x( "Pages", "post type general name" ) ),
--                         "singular_name"            => array( _x( "Post", "post type singular name" ), _x( "Page", "post type singular name" ) ),
--                         "add_new"                  => array( _x( "Add New", "post" ), _x( "Add New", "page" ) ),
--                         "add_new_item"             => array( __( "Add New Post" ), __( "Add New Page" ) ),
--                         "edit_item"                => array( __( "Edit Post" ), __( "Edit Page" ) ),
--                         "new_item"                 => array( __( "New Post" ), __( "New Page" ) ),
--                         "view_item"                => array( __( "View Post" ), __( "View Page" ) ),
--                         "view_items"               => array( __( "View Posts" ), __( "View Pages" ) ),
--                         "search_items"             => array( __( "Search Posts" ), __( "Search Pages" ) ),
--                         "not_found"                => array( __( "No posts found." ), __( "No pages found." ) ),
--                         "not_found_in_trash"       => array( __( "No posts found in Trash." ), __( "No pages found in Trash." ) ),
--                         "parent_item_colon"        => array( null, __( "Parent Page:" ) ),
--                         "all_items"                => array( __( "All Posts" ), __( "All Pages" ) ),
--                         "archives"                 => array( __( "Post Archives" ), __( "Page Archives" ) ),
--                         "attributes"               => array( __( "Post Attributes" ), __( "Page Attributes" ) ),
--                         "insert_into_item"         => array( __( "Insert into post" ), __( "Insert into page" ) ),
--                         "uploaded_to_this_item"    => array( __( "Uploaded to this post" ), __( "Uploaded to this page" ) ),
--                         "featured_image"           => array( _x( "Featured image", "post" ), _x( "Featured image", "page" ) ),
--                         "set_featured_image"       => array( _x( "Set featured image", "post" ), _x( "Set featured image", "page" ) ),
--                         "remove_featured_image"    => array( _x( "Remove featured image", "post" ), _x( "Remove featured image", "page" ) ),
--                         "use_featured_image"       => array( _x( "Use as featured image", "post" ), _x( "Use as featured image", "page" ) ),
--                         "filter_items_list"        => array( __( "Filter posts list" ), __( "Filter pages list" ) ),
--                         "filter_by_date"           => array( __( "Filter by date" ), __( "Filter by date" ) ),
--                         "items_list_navigation"    => array( __( "Posts list navigation" ), __( "Pages list navigation" ) ),
--                         "items_list"               => array( __( "Posts list" ), __( "Pages list" ) ),
--                         "item_published"           => array( __( "Post published." ), __( "Page published." ) ),
--                         "item_published_privately" => array( __( "Post published privately." ), __( "Page published privately." ) ),
--                         "item_reverted_to_draft"   => array( __( "Post reverted to draft." ), __( "Page reverted to draft." ) ),
--                         "item_scheduled"           => array( __( "Post scheduled." ), __( "Page scheduled." ) ),
--                         "item_updated"             => array( __( "Post updated." ), __( "Page updated." ) ),
--                         "item_link"                => array(
--                                 _x( "Post Link", "navigation link block title" ),
--                                 _x( "Page Link", "navigation link block title" ),
--                         ),
--                         "item_link_description"    => array(
--                                 _x( "A link to a post.", "navigation link block description" ),
--                                 _x( "A link to a page.", "navigation link block description" ),
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
   procedure Dummy is null;

end Class_Post_Type;
