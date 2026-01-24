--
-- Core Post API
--
-- @package WordPress
-- @subpackage Post
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Arrays;
with Lists;

with Class_Posts;
with Class_Post_Type;
with Class_Taxonomy;

package Inc_Posts
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Lists;
   use Class_Posts;

   --
   -- Post Type registration.
   --

   --
   -- Creates the initial post types when "init" action is fired.
   --
   -- See {@see "init"}.
   --
   -- @since 2.9.0
   --
   procedure Create_Initial_Post_Types;

   --
   -- Retrieves the post type of the current post or of a given post.
   --
   -- @since 2.1.0
   --
   -- @param int|WP_Post|null $post Optional. Post ID or post object. Default is
   --                               global $post.
   -- @return string|false          Post type on success, false on failure.
   --
   function Get_Post_Type (Post : Post_Id := 0) -- Integer := 0) -- := null )
                           return String is ("XXX-250");
   function Get_Post_Type (Post : Wp_Post) -- := null )
                           return String is ("XXX-251");

   --
   -- Determines whether a post type is registered.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 3.0.0
   --
   -- @see get_post_type_object()
   --
   -- @param string $post_type Post type name.
   -- @return bool Whether post type is registered.
   --
   function Post_Type_Exists (Post_Type : String)
                              return Boolean
                              is (True);

   -- @param array|string args {
   --     Optional. Array or string of post status arguments.
   type Status_Type is
      record

--       @type bool|string
         Label : Unbounded_String;
         -- A descriptive name for the post status marked
         -- for translation. Defaults to value of post_status.

--       @type array|false
         Label_Count : Array_Type;
         -- Nooped plural text from _n_noop() to provide the singular
         -- and plural forms of the label for counts. Default false
         -- which means the `label` argument will be used for both
         -- the singular and plural forms of this label.

--       @type bool
         Exclude_From_Search : Boolean;
         -- Whether to exclude posts with this post status
         -- from search results. Default is value of internal.

--       @type bool
         X_Builtin : Boolean;
         -- Whether the status is built-in. Core-use only.
         -- Default false.

--       @type bool
         Public : Boolean;
         -- Whether posts of this status should be shown
         -- in the front end of the site. Default false.

--       @type bool
         Internal : Boolean;
         -- Whether the status is for internal use only.
         -- Default false.

--       @type bool
         Protect : Boolean;
         -- Whether posts with this status should be protected.
         -- Default false.

--       @type bool
         Privat : Boolean;
         -- Whether posts with this status should be private.
         -- Default false.

--       @type bool
         Publicly_Queryable : Boolean;
         -- Whether posts with this status should be publicly-
         -- queryable. Default is value of public.

--       @type bool
         Show_In_Admin_All_List : Boolean;
         -- Whether to include posts in the edit listing for
         -- their post type. Default is the opposite value
         -- of internal.

--       @type bool
         Show_In_Admin_Status_List : Boolean;
         -- Show in the list of statuses with post counts at
         -- the top of the edit listings,
         -- e.g. All (12) | Published (9) | My Custom Status (2)
         -- Default is the opposite value of internal.

--       @type bool
         Date_Floating : Boolean;
         -- Whether the post has a floating creation date.
         -- Default to false.
      end record;

   package Status_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => Status_Type);
   subtype Status_Map is Status_Maps.Map;

   Wp_Post_Statuses : Status_Map;

   --
   -- Registers a post status. Do not use before init.
   --
   -- A simple function for creating or modifying a post status based on the
   -- parameters given. The function will accept an array (second optional
   -- parameter), along with a string for the post status name.
   --
   -- Arguments prefixed with an _underscore shouldn"t be used by plugins and themes.
   --
   -- @since 3.0.0
   --
   -- @global stdClass[] wp_post_statuses Inserts new post status object into the list
   --
   -- @param string       post_status Name of the post status.
   -- @param array|string args {
   --     Optional. Array or string of post status arguments.
   --
   --     @type bool|string label                     A descriptive name for the post status marked
   --                                                  for translation. Defaults to value of post_status.
   --     @type array|false label_count               Nooped plural text from _n_noop() to provide the singular
   --                                                  and plural forms of the label for counts. Default false
   --                                                  which means the `label` argument will be used for both
   --                                                  the singular and plural forms of this label.
   --     @type bool        exclude_from_search       Whether to exclude posts with this post status
   --                                                  from search results. Default is value of internal.
   --     @type bool        _builtin                  Whether the status is built-in. Core-use only.
   --                                                  Default false.
   --     @type bool        public                    Whether posts of this status should be shown
   --                                                  in the front end of the site. Default false.
   --     @type bool        internal                  Whether the status is for internal use only.
   --                                                  Default false.
   --     @type bool        protected                 Whether posts with this status should be protected.
   --                                                  Default false.
   --     @type bool        private                   Whether posts with this status should be private.
   --                                                  Default false.
   --     @type bool        publicly_queryable        Whether posts with this status should be publicly-
   --                                                  queryable. Default is value of public.
   --     @type bool        show_in_admin_all_list    Whether to include posts in the edit listing for
   --                                                  their post type. Default is the opposite value
   --                                                  of internal.
   --     @type bool        show_in_admin_status_list Show in the list of statuses with post counts at
   --                                                  the top of the edit listings,
   --                                                  e.g. All (12) | Published (9) | My Custom Status (2)
   --                                                  Default is the opposite value of internal.
   --     @type bool        date_floating             Whether the post has a floating creation date.
   --                                                  Default to false.
   -- }
   -- @return object
   --
   function Register_Post_Status (Post_Status : String;
                                  Args        : Status_Type)
                                  return Status_Type; -- Array_Type;
   procedure Register_Post_Status (Post_Status : String;
                                   Args        : Status_Type); --  = to_array ()

   --
   -- Retrieves a post type object by name.
   --
   -- @since 3.0.0
   -- @since 4.6.0 Object returned is now an instance of `WP_Post_Type`.
   --
   -- @global array $wp_post_types List of post types.
   --
   -- @see register_post_type()
   --
   -- @param string $post_type The name of a registered post type.
   -- @return WP_Post_Type|null WP_Post_Type object if it exists, null otherwise.
   --
   function Get_Post_Type_Object (Post_Type : String)
                                  return Class_Post_Type.Wp_Post_Type;
--   function Get_Post_Type_Object (Post_Type : String)
--                                  return Boolean
--                                  is (True);

   --
   -- Gets a list of all registered post type objects.
   --
   -- @since 2.9.0
   --
   -- @global array $wp_post_types List of post types.
   --
   -- @see register_post_type() for accepted arguments.
   --
   -- @param array|string $args     Optional. An array of key => value arguments to
   --                               match against the post type objects. Default
   --                               empty array.
   -- @param string       $output   Optional. The type of output to return. Accepts
   --                               post type 'names'
   --                               or 'objects'. Default 'names'.
   -- @param string       $operator Optional. The logical operation to perform. 'or'
   --                               means only one element from the array needs to
   --                               match; 'and' means all elements must match; 'not'
   --                               means no elements may match. Default 'and'.
   -- @return string[]|WP_Post_Type[] An array of post type names or objects.
   --
   function Get_Post_Types (Args     : Array_Type := Empty_Array;
                            Output   : String     := "names";
                            Operator : String     := "and")
                            return Class_Post_Type.Wp_Post_Type_Array;

   -- function Get_Post_Types (Args     : Array_Type := Empty_Array;
   --                          Output   : String     := "names";
   --                          Operator : String     := "and")
   --                          return String_Array
   --                          is (Empty_String_Array);

   function Get_Post_Types (Args     : Array_Type := Empty_Array;
                            Output   : String     := "names";
                            Operator : String     := "and")
                            return List_Type
                            is (Empty_List);

--     @type bool|array   rewrite               {
   type Rewrite_Rec is
      record
         -- Triggers the handling of rewrites for this post type. To prevent rewrite,
         -- set to false. Defaults to true, using post_type as slug. To specify
         -- rewrite rules, an array can be passed with any of these keys:

--       @type string
         Slug : Unbounded_String;
         -- Customize the permastruct slug. Defaults to post_type key.

--       @type bool
         With_Front : Boolean;
         -- Whether the permastruct should be prepended with WP_Rewrite::front.
         -- Default true.

--       @type bool
         Feeds : Boolean;
         -- Whether the feed permastruct should be built for this post type.
         -- Default is value of has_archive.

--       @type bool
         Pages : Boolean;
         -- Whether the permastruct should provide for pagination. Default true.

--       @type int
         EP_Mask : Integer;
         -- Endpoint mask to assign. If not specified and permalink_epmask is set,
         -- inherits from permalink_epmask. If not specified and permalink_epmask
         -- is not set, defaults to EP_PERMALINK.
      end record;

   Empty_Rewrite : constant Rewrite_Rec :=
     (Slug       => Null_Unbounded_String,
      With_Front => False,
      Feeds      => False,
      Pages      => False,
      EP_Mask    => 0
     );

   type Callable is null record;
   Null_Callable : constant Callable := (null record);

   -- @param array|string args {
   --     Array or string of arguments for registering a post type.
   type Args_Type is
      record
--       @type string
         Label : Unbounded_String;
         -- Name of the post type shown in the menu. Usually plural.
         -- Default is value of labels["name"].

--       @type string[]
         Labels : Array_Type; -- String_Array;
         -- An array of labels for this post type. If not set, post
         -- labels are inherited for non-hierarchical types and page
         -- labels for hierarchical ones. See get_post_type_labels() for a full
         -- list of supported labels.

--       @type string
         Description : Unbounded_String;
         -- A short descriptive summary of what the post type is.
         -- Default empty.

--       @type bool
         Public : Boolean;
         -- Whether a post type is intended for use publicly either via
         -- the admin interface or by front-end users. While the default
         -- settings of exclude_from_search, publicly_queryable, show_ui,
         -- and show_in_nav_menus are inherited from public, each does not
         -- rely on this relationship and controls a very specific intention.
         -- Default false.

--       @type bool
         Hierarchical : Boolean;
         -- Whether the post type is hierarchical (e.g. page). Default false.

--       @type bool
         Exclude_From_Search : Boolean;
         -- Whether to exclude posts with this post type from front end search
         -- results. Default is the opposite value of public.

--       @type bool
         Publicly_Queryable : Boolean;
         -- Whether queries can be performed on the front end for the post type
         -- as part of parse_request(). Endpoints would include:
         -- -- ?post_type=thenpost_type_keyend;
         -- -- ?thenpost_type_keyend;=thensingle_post_slugend;
         -- -- ?thenpost_type_query_varend;=thensingle_post_slugend;
         -- If not set, the default is inherited from public.

--       @type bool
         Show_UI : Boolean;
         -- Whether to generate and allow a UI for managing this post type in the
         -- admin. Default is value of public.

--       @type bool|string
         Show_In_Menu_Bool : Boolean;
         Show_In_Menu : Unbounded_String;
         -- Where to show the post type in the admin menu. To work, show_ui
         -- must be true. If true, the post type is shown in its own top level
         -- menu. If false, no menu is shown. If a string of an existing top
         -- level menu ("tools.php" or "edit.php?post_type=page", for example), the
         -- post type will be placed as a sub-menu of that.
         -- Default is value of show_ui.

--       @type bool
         Show_In_Nav_Menus : Boolean;
         -- Makes this post type available for selection in navigation menus.
         -- Default is value of public.

--       @type bool
         Show_In_Admin_Bar : Boolean;
         -- Makes this post type available via the admin bar. Default is value
         -- of show_in_menu.

--       @type bool
         Show_In_REST : Boolean;
         -- Whether to include the post type in the REST API. Set this to true
         -- for the post type to be available in the block editor.

--       @type string
         REST_Base : Unbounded_String;
         -- To change the base URL of REST API route. Default is post_type.

--       @type string
         REST_Namespace : Unbounded_String;
         -- To change the namespace URL of REST API route. Default is wp/v2.

--       @type string
         REST_Controller_Class : Unbounded_String;
         -- REST API controller class name. Default is "WP_REST_Posts_Controller".

--       @type int
         Menu_Position : Integer;
         -- The position in the menu order the post type should appear. To work,
         -- show_in_menu must be true. Default null (at the bottom).

--       @type string
         Menu_Icon : Unbounded_String;
         -- The URL to the icon to be used for this menu. Pass a base64-encoded
         -- SVG using a data URI, which will be colored to match the color scheme
         -- -- this should begin with "data:image/svg+xml;base64,". Pass the name
         -- of a Dashicons helper class to use a font icon, e.g.
         -- "dashicons-chart-pie". Pass "none" to leave div.wp-menu-image empty
         -- so an icon can be added via CSS. Defaults to use the posts icon.

--       @type string|array
         Capability_Type_String : Unbounded_String;
         Capability_Type_Array  : Array_Type;
         -- The string to use to build the read, edit, and delete capabilities.
         -- May be passed as an array to allow for alternative plurals when using
         -- this argument as a base to construct the capabilities, e.g.
         -- to_array ("story", "stories"). Default "post".

--       @type string[]
         Capabilities : Array_Type; -- String_Array;
         -- Array of capabilities for this post type. capability_type is used
         -- as a base to construct capabilities by default.
         -- See get_post_type_capabilities().

--       @type bool
         Map_Meta_Cap : Boolean;
         -- Whether to use the internal default meta capability handling.
         -- Default false.

--       @type array
         Supports : List_Type;
         -- Core feature(s) the post type supports. Serves as an alias for calling
         -- add_post_type_support() directly. Core features include "title",
         -- "editor", "comments", "revisions", "trackbacks", "author", "excerpt",
         -- "page-attributes", "thumbnail", "custom-fields", and "post-formats".
         -- Additionally, the "revisions" feature dictates whether the post type
         -- will store revisions, and the "comments" feature dictates whether the
         -- comments count will show on the edit screen. A feature can also be
         -- specified as an array of arguments to provide additional information
         -- about supporting that feature.
         -- Example: `to_array ( "my_feature", to_array ( "field" => "value" ) )`.
         -- Default is an array containing "title" and "editor".

--       @type callable
         Register_Meta_Box_CB : Callable;
         -- Provide a callback function that sets up the meta boxes for the
         -- edit form. Do remove_meta_box() and add_meta_box() calls in the
         -- callback. Default null.

--       @type string[]
         Taxonomies : List_Type; -- String_Array;
         -- An array of taxonomy identifiers that will be registered for the
         -- post type. Taxonomies can be registered later with register_taxonomy()
         -- or register_taxonomy_for_object_type().
         -- Default empty array.

--       @type bool|string
         Has_Archive_Bool : Boolean;
         Has_Archive : Unbounded_String;
         -- Whether there should be post type archives, or if a string, the
         -- archive slug to use. Will generate the proper rewrite rules if
         -- rewrite is enabled. Default false.

--       @type bool|array
         Rewrite_Bool : Boolean;
         Rewrite : Rewrite_Rec;
--                      {
--         Triggers the handling of rewrites for this post type. To prevent rewrite, set to false.
--         Defaults to true, using post_type as slug. To specify rewrite rules, an array can be
--         passed with any of these keys:
--
--         @type string slug       Customize the permastruct slug. Defaults to post_type key.
--         @type bool   with_front Whether the permastruct should be prepended with WP_Rewrite::front.
--                                  Default true.
--         @type bool   feeds      Whether the feed permastruct should be built for this post type.
--                                  Default is value of has_archive.
--         @type bool   pages      Whether the permastruct should provide for pagination. Default true.
--         @type int    ep_mask    Endpoint mask to assign. If not specified and permalink_epmask is set,
--                                  inherits from permalink_epmask. If not specified and permalink_epmask
--                                  is not set, defaults to EP_PERMALINK.
--     }

--       @type string|bool
         Query_Var_Bool : Boolean;
         Query_Var : Unbounded_String;
         -- Sets the query_var key for this post type. Defaults to post_type
         -- key. If false, a post type cannot be loaded at
         -- ?thenquery_varend;=thenpost_slugend;. If specified as a string, the query
         -- ?thenquery_var_stringend;=thenpost_slugend; will be valid.

--       @type bool
         Can_Export : Boolean;
         -- Whether to allow this post type to be exported. Default true.

--       @type bool
         Delete_With_User : Boolean;
         -- Whether to delete posts of this type when deleting a user.
         -- -- If true, posts of this type belonging to the user will be moved
         -- to Trash when the user is deleted.
         -- -- If false, posts of this type belonging to the user will--not*
         -- be trashed or deleted.
         -- -- If not set (the default), posts are trashed if post type supports
         -- the "author" feature. Otherwise posts are not trashed or deleted.
         -- Default null.

--       @type array
         Template : Array_Type;
         -- Array of blocks to use as the default initial state for an editor
         -- session. Each item should be an array containing block name and
         -- optional attributes. Default empty array.

--       @type string|false
         Template_Lock_Bool : Boolean;
         Template_Lock : Unbounded_String;
         -- Whether the block template should be locked if template is set.
         -- -- If set to "all", the user is unable to insert new blocks,
         -- move existing blocks and delete blocks.
         -- -- If set to "insert", the user is able to move existing blocks
         -- but is unable to insert new blocks and delete blocks.
         -- Default false.

--       @type bool
         X_Builtin : Boolean;
         -- FOR INTERNAL USE ONLY! True if this post type is a native or
         -- "built-in" post_type. Default false.

--       @type string
         X_Edit_Link : Unbounded_String;
         -- FOR INTERNAL USE ONLY! URL segment to use for edit link of
         -- this post type. Default "post.php?post=%d".
      end record;

   --
   -- Registers a post type.
   --
   -- Note: Post type registrations should not be hooked before the
   -- {@see "init"} action. Also, any taxonomy connections should be
   -- registered via the `taxonomies` argument to ensure consistency
   -- when hooks such as {@see "parse_query"} or {@see "pre_get_posts"}
   -- are used.
   --
   -- Post types can support any number of built-in core features such
   -- as meta boxes, custom fields, post thumbnails, post statuses,
   -- comments, and more. See the `supports` argument for a complete
   -- list of supported features.
   --
   -- @since 2.9.0
   -- @since 3.0.0 The `show_ui` argument is now enforced on the new post screen.
   -- @since 4.4.0 The `show_ui` argument is now enforced on the post type listing
   --              screen and post editing screen.
   -- @since 4.6.0 Post type object returned is now an instance of `WP_Post_Type`.
   -- @since 4.7.0 Introduced `show_in_rest`, `rest_base` and `rest_controller_class`
   --              arguments to register the post type in REST API.
   -- @since 5.0.0 The `template` and `template_lock` arguments were added.
   -- @since 5.3.0 The `supports` argument will now accept an array of arguments for a feature.
   -- @since 5.9.0 The `rest_namespace` argument was added.
   --
   -- @global array wp_post_types List of post types.
   --
   -- @param string       post_type Post type key. Must not exceed 20 characters and may
   --                                only contain lowercase alphanumeric characters, dashes,
   --                                and underscores. See sanitize_key().
   -- @param array|string args {
   --     Array or string of arguments for registering a post type.
   --
   --     @type string       label                 Name of the post type shown in the menu. Usually plural.
   --                                               Default is value of labels["name"].
   --     @type string[]     labels                An array of labels for this post type. If not set, post
   --                                               labels are inherited for non-hierarchical types and page
   --                                               labels for hierarchical ones. See get_post_type_labels() for a full
   --                                               list of supported labels.
   --     @type string       description           A short descriptive summary of what the post type is.
   --                                               Default empty.
   --     @type bool         public                Whether a post type is intended for use publicly either via
   --                                               the admin interface or by front-end users. While the default
   --                                               settings of exclude_from_search, publicly_queryable, show_ui,
   --                                               and show_in_nav_menus are inherited from public, each does not
   --                                               rely on this relationship and controls a very specific intention.
   --                                               Default false.
   --     @type bool         hierarchical          Whether the post type is hierarchical (e.g. page). Default false.
   --     @type bool         exclude_from_search   Whether to exclude posts with this post type from front end search
   --                                               results. Default is the opposite value of public.
   --     @type bool         publicly_queryable    Whether queries can be performed on the front end for the post type
   --                                               as part of parse_request(). Endpoints would include:
   --                                              -- ?post_type=thenpost_type_keyend;
   --                                              -- ?thenpost_type_keyend;=thensingle_post_slugend;
   --                                              -- ?thenpost_type_query_varend;=thensingle_post_slugend;
   --                                               If not set, the default is inherited from public.
   --     @type bool         show_ui               Whether to generate and allow a UI for managing this post type in the
   --                                               admin. Default is value of public.
   --     @type bool|string  show_in_menu          Where to show the post type in the admin menu. To work, show_ui
   --                                               must be true. If true, the post type is shown in its own top level
   --                                               menu. If false, no menu is shown. If a string of an existing top
   --                                               level menu ("tools.php" or "edit.php?post_type=page", for example), the
   --                                               post type will be placed as a sub-menu of that.
   --                                               Default is value of show_ui.
   --     @type bool         show_in_nav_menus     Makes this post type available for selection in navigation menus.
   --                                               Default is value of public.
   --     @type bool         show_in_admin_bar     Makes this post type available via the admin bar. Default is value
   --                                               of show_in_menu.
   --     @type bool         show_in_rest          Whether to include the post type in the REST API. Set this to true
   --                                               for the post type to be available in the block editor.
   --     @type string       rest_base             To change the base URL of REST API route. Default is post_type.
   --     @type string       rest_namespace        To change the namespace URL of REST API route. Default is wp/v2.
   --     @type string       rest_controller_class REST API controller class name. Default is "WP_REST_Posts_Controller".
   --     @type int          menu_position         The position in the menu order the post type should appear. To work,
   --                                               show_in_menu must be true. Default null (at the bottom).
   --     @type string       menu_icon             The URL to the icon to be used for this menu. Pass a base64-encoded
   --                                               SVG using a data URI, which will be colored to match the color scheme
   --                                               -- this should begin with "data:image/svg+xml;base64,". Pass the name
   --                                               of a Dashicons helper class to use a font icon, e.g.
   --                                               "dashicons-chart-pie". Pass "none" to leave div.wp-menu-image empty
   --                                               so an icon can be added via CSS. Defaults to use the posts icon.
   --     @type string|array capability_type       The string to use to build the read, edit, and delete capabilities.
   --                                               May be passed as an array to allow for alternative plurals when using
   --                                               this argument as a base to construct the capabilities, e.g.
   --                                               to_array ("story", "stories"). Default "post".
   --     @type string[]     capabilities          Array of capabilities for this post type. capability_type is used
   --                                               as a base to construct capabilities by default.
   --                                               See get_post_type_capabilities().
   --     @type bool         map_meta_cap          Whether to use the internal default meta capability handling.
   --                                               Default false.
   --     @type array        supports              Core feature(s) the post type supports. Serves as an alias for calling
   --                                               add_post_type_support() directly. Core features include "title",
   --                                               "editor", "comments", "revisions", "trackbacks", "author", "excerpt",
   --                                               "page-attributes", "thumbnail", "custom-fields", and "post-formats".
   --                                               Additionally, the "revisions" feature dictates whether the post type
   --                                               will store revisions, and the "comments" feature dictates whether the
   --                                               comments count will show on the edit screen. A feature can also be
   --                                               specified as an array of arguments to provide additional information
   --                                               about supporting that feature.
   --                                               Example: `to_array ( "my_feature", to_array ( "field" => "value" ) )`.
   --                                               Default is an array containing "title" and "editor".
   --     @type callable     register_meta_box_cb  Provide a callback function that sets up the meta boxes for the
   --                                               edit form. Do remove_meta_box() and add_meta_box() calls in the
   --                                               callback. Default null.
   --     @type string[]     taxonomies            An array of taxonomy identifiers that will be registered for the
   --                                               post type. Taxonomies can be registered later with register_taxonomy()
   --                                               or register_taxonomy_for_object_type().
   --                                               Default empty array.
   --     @type bool|string  has_archive           Whether there should be post type archives, or if a string, the
   --                                               archive slug to use. Will generate the proper rewrite rules if
   --                                               rewrite is enabled. Default false.
   --     @type bool|array   rewrite               {
   --         Triggers the handling of rewrites for this post type. To prevent rewrite, set to false.
   --         Defaults to true, using post_type as slug. To specify rewrite rules, an array can be
   --         passed with any of these keys:
   --
   --         @type string slug       Customize the permastruct slug. Defaults to post_type key.
   --         @type bool   with_front Whether the permastruct should be prepended with WP_Rewrite::front.
   --                                  Default true.
   --         @type bool   feeds      Whether the feed permastruct should be built for this post type.
   --                                  Default is value of has_archive.
   --         @type bool   pages      Whether the permastruct should provide for pagination. Default true.
   --         @type int    ep_mask    Endpoint mask to assign. If not specified and permalink_epmask is set,
   --                                  inherits from permalink_epmask. If not specified and permalink_epmask
   --                                  is not set, defaults to EP_PERMALINK.
   --     }
   --     @type string|bool  query_var             Sets the query_var key for this post type. Defaults to post_type
   --                                               key. If false, a post type cannot be loaded at
   --                                               ?thenquery_varend;=thenpost_slugend;. If specified as a string, the query
   --                                               ?thenquery_var_stringend;=thenpost_slugend; will be valid.
   --     @type bool         can_export            Whether to allow this post type to be exported. Default true.
   --     @type bool         delete_with_user      Whether to delete posts of this type when deleting a user.
   --                                              -- If true, posts of this type belonging to the user will be moved
   --                                                 to Trash when the user is deleted.
   --                                              -- If false, posts of this type belonging to the user will--not*
   --                                                 be trashed or deleted.
   --                                              -- If not set (the default), posts are trashed if post type supports
   --                                                 the "author" feature. Otherwise posts are not trashed or deleted.
   --                                               Default null.
   --     @type array        template              Array of blocks to use as the default initial state for an editor
   --                                               session. Each item should be an array containing block name and
   --                                               optional attributes. Default empty array.
   --     @type string|false template_lock         Whether the block template should be locked if template is set.
   --                                              -- If set to "all", the user is unable to insert new blocks,
   --                                                 move existing blocks and delete blocks.
   --                                              -- If set to "insert", the user is able to move existing blocks
   --                                                 but is unable to insert new blocks and delete blocks.
   --                                               Default false.
   --     @type bool         _builtin              FOR INTERNAL USE ONLY! True if this post type is a native or
   --                                               "built-in" post_type. Default false.
   --     @type string       _edit_link            FOR INTERNAL USE ONLY! URL segment to use for edit link of
   --                                               this post type. Default "post.php?post=%d".
   -- }
   -- @return WP_Post_Type|WP_Error The registered post type object on success,
   --                               WP_Error object on failure.
   --
   procedure Register_Post_Type (Post_Type : String;
                                 Args      : Args_Type); -- Array_Type := Empty_Array)
   --                            return incWp_Post_Type.Wp_Post_Type;

   --
   -- Builds an object with custom-something object (post type, taxonomy) labels
   -- out of a custom-something object
   --
   -- @since 3.0.0
   -- @access private
   --
   -- @param object object                  A custom-something object.
   -- @param array  nohier_vs_hier_defaults Hierarchical vs non-hierarchical default
   --                                       labels.
   -- @return object Object containing labels for the given custom-something object.
   --
   function X_Get_Custom_Object_Labels
      (Object                 : in out Class_Taxonomy.Wp_Taxonomy;
      Nohier_Vs_Hier_Defaults : Array_Type)
      return Array_Type;

   --
   -- Adds submenus for post types.
   --
   -- @access private
   -- @since 3.1.0
   --
   procedure X_Add_Post_Type_Submenus;

   --
   -- Gets a list of post statuses.
   --
   -- @since 3.0.0
   --
   -- @global stdClass[] wp_post_statuses List of post statuses.
   --
   -- @see register_post_status()
   --
   -- @param array|string args     Optional. Array or string of post status arguments
   --                               to compare against properties of the global
   --                               `wp_post_statuses objects`. Default empty array.
   -- @param string       output   Optional. The type of output to return, either
   --                               "names" or "objects". Default "names".
   -- @param string       operator Optional. The logical operation to perform. "or"
   --                               means only one element from the array needs to
   --                               match; "and" means all elements must match.
   --                               Default "and".
   -- @return string[]|stdClass[] A list of post status names or objects.
   --
   function Get_Post_Stati (Args     : Array_Type := Empty_Array;
                            Output   : String     := "names";
                            Operator : String     := "and")
                            return List_Type
                            is (Empty_List);

   --
   -- Determines whether the post type is hierarchical.
   --
   -- A False return value might also mean that the post type does not exist.
   --
   -- @since 3.0.0
   --
   -- @see get_post_type_object()
   --
   -- @param string post_type Post type name
   -- @return bool Whether post type is hierarchical.
   --
   function Is_Post_Type_Hierarchical (Post_Type : String)
                                       return Boolean
                                       is (False);

   --
   -- Registers support of certain features for a post type.
   --
   -- All core features are directly associated with a functional area of the edit
   -- screen, such as the editor or a meta box. Features include: "title", "editor",
   -- "comments", "revisions", "trackbacks", "author", "excerpt", "page-attributes",
   -- "thumbnail", "custom-fields", and "post-formats".
   --
   -- Additionally, the "revisions" feature dictates whether the post type will
   -- store revisions, and the "comments" feature dictates whether the comments
   -- count will show on the edit screen.
   --
   -- A third, optional parameter can also be passed along with a feature to provide
   -- additional information about supporting that feature.
   --
   -- Example usage:
   --
   --     add_post_type_support( "my_post_type", "comments" );
   --     add_post_type_support( "my_post_type", to_array (
   --         "author", "excerpt",
   --     ) );
   --     add_post_type_support( "my_post_type", "my_feature", to_array (
   --         "field" => "value",
   --     ) );
   --
   -- @since 3.0.0
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   --
   -- @global array _wp_post_type_features
   --
   -- @param string       post_type The post type for which to add the feature.
   -- @param string|array feature   The feature being added, accepts an array of
   --                                feature strings or a single string.
   -- @param mixed        ...args   Optional extra arguments to pass along with
   --                                certain features.
   --
   procedure Add_Post_Type_Support (Post_Type : String;
                                    Feature   : String);
--                                  ...args ) then

   --
   -- Determines whether a post status is considered "viewable".
   --
   -- For built-in post statuses such as publish and private, the "public" value will
   -- be evaluated. For all others, the "publicly_queryable" value will be used.
   --
   -- @since 5.7.0
   -- @since 5.9.0 Added `is_post_status_viewable` hook to filter the result.
   --
   -- @param string|stdClass post_status Post status name or object.
   -- @return bool Whether the post status should be considered viewable.
   --
   function Is_Post_Status_Viewable (Post_Status : Status_Type)
                                     return Boolean;

   --
   -- Retrieves an array of the latest posts, or posts matching the given criteria.
   --
   -- For more information on the accepted arguments, see the
   -- {@link https://developer.wordpress.org/reference/classes/wp_query/
   -- WP_Query} documentation in the Developer Handbook.
   --
   -- The `ignore_sticky_posts` and `no_found_rows` arguments are ignored by
   -- this function and both are set to `True`.
   --
   -- The defaults are as follows:
   --
   -- @since 1.2.0
   --
   -- @see WP_Query
   -- @see WP_Query::parse_query()
   --
   -- @param array args {
   --     Optional. Arguments to retrieve posts. See WP_Query::parse_query() for all
   --     available arguments.
   --
   --     @type int        numberposts      Total number of posts to retrieve. Is an
   --                                        alias of `posts_per_page` in WP_Query.
   --                                        Accepts -1 for all. Default 5.
   --
   --     @type int|string category         Category ID or comma-separated list of IDs
   --                                        (this or any children). Is an alias of
   --                                        `cat` in WP_Query. Default 0.
   --     @type int[]      include          An array of post IDs to retrieve, sticky
   --                                        posts will be included. Is an alias of
   --                                        `postabsin` in WP_Query. Default empty
   --                                        array.
   --     @type int[]      exclude          An array of post IDs not to retrieve.
   --                                        Default empty array.
   --     @type bool       suppress_filters Whether to suppress filters. Default True.
   -- }
   -- @return WP_Post[]|int[] Array of post objects or post IDs.
   --
   function Get_Posts (Args : Array_Type := Empty_Array) -- null
                       return Class_Posts.Post_Array;

   --
   -- Checks a post type"s support for a given feature.
   --
   -- @since 3.0.0
   --
   -- @global array _wp_post_type_features
   --
   -- @param string post_type The post type being checked.
   -- @param string feature   The feature being checked.
   -- @return bool Whether the post type supports the given feature.
   --
   function Post_Type_Supports (Post_Type : String;
                                Feature   : String)
                                return Boolean
                                is (True);

   --
   -- Trashes or deletes a post or page.
   --
   -- When the post and page is permanently deleted, everything that is tied to
   -- it is deleted also. This includes comments, post meta fields, and terms
   -- associated with the post.
   --
   -- The post or page is moved to Trash instead of permanently deleted unless
   -- Trash is disabled, item is already in the Trash, or force_delete is True.
   --
   -- @since 1.0.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   -- @see wp_delete_attachment()
   -- @see wp_trash_post()
   --
   -- @param int  postid       Optional. Post ID. Default 0.
   -- @param bool force_delete Optional. Whether to bypass Trash and force deletion.
   --                           Default False.
   -- @return WP_Post|False|null Post data on success, False or null on failure.
   --
   function Wp_Delete_Post (Postid       : Integer := 0;
                            Force_Delete : Boolean := False)
                            return Wp_Post
                            is (Null_Post);

   --
   -- Retrieves a post status object by name.
   --
   -- @since 3.0.0
   --
   -- @global stdClass[] $wp_post_statuses List of post statuses.
   --
   -- @see register_post_status()
   --
   -- @param string $post_status The name of a registered post status.
   -- @return stdClass|null A post status object.
   --
   function Get_Post_Status_Object (Post_Status : String)
                                    return Status_Type; -- Array_Type
                                    -- is (Empty_Array);

   --
   -- Retrieves post data given a post ID or post object.
   --
   -- See sanitize_post() for optional $filter values. Also, the parameter
   -- `$post`, must be given as a variable, since it is passed by reference.
   --
   -- @since 1.5.1
   --
   -- @global WP_Post $post Global post object.
   --
   -- @param int|WP_Post|null $post   Optional. Post ID or post object. `null`,
   --                                 `false`, `0` and other PHP falsey values return
   --                                 the current global post inside the loop. A
   --                                 numerically valid post ID that points to a
   --                                 non-existent post returns `null`. Defaults to
   --                                 global $post.
   -- @param string           $output Optional. The required return type. One of
   --                                 OBJECT, ARRAY_A, or ARRAY_N, which correspond to
   --                                 a WP_Post object, an associative array, or a
   --                                 numeric array, respectively. Default OBJECT.
   -- @param string           $filter Optional. Type of filter to apply. Accepts
   --                                 'raw', 'edit', 'db', or 'display'. Default 'raw'.
   -- @return WP_Post|array|null Type corresponding to $output on success or null on
   --                            failure. When $output is OBJECT, a `WP_Post`
   --                            instance is returned.
   --
   function Get_Post (Post   : Wp_Post; -- = null,
                      Output : String := "OBJECT"; --  = OBJECT,
                      Filter : String := "raw")
                      return Wp_Post;

   function Get_Post (Post   : Post_Id := 0;
                      Output : String  := "OBJECT"; --  = OBJECT,
                      Filter : String  := "raw")
                      return Wp_Post;

   function Get_Post (Post   : Post_Id := 0;
                      Output : String  := "OBJECT";
                      Filter : String  := "raw")
                      return Array_Type
                      is (Empty_Array);

   function Get_Post (Post   : Wp_Post;
                      Output : String  := "OBJECT";
                      Filter : String  := "raw")
                      return Array_Type
                      is (Empty_Array);

   --
   -- Builds the URI path for a page.
   --
   -- Sub pages will be in the "directory" under the parent page post name.
   --
   -- @since 1.5.0
   -- @since 4.6.0 The `page` parameter was made optional.
   --
   -- @param WP_Post|object|int page Optional. Page ID or WP_Post object. Default is
   --                                 global post.
   -- @return string|False Page URI, False on error.
   --
   function Get_Page_URI (Page : Wp_Post) -- Integer := 0)
                          return String;

   --
   -- Determines whether a post type is considered "viewable".
   --
   -- For built-in post types such as posts and pages, the "public" value will be
   -- evaluated. For all others, the "publicly_queryable" value will be used.
   --
   -- @since 4.4.0
   -- @since 4.5.0 Added the ability to pass a post type name in addition to object.
   -- @since 4.6.0 Converted the `post_type` parameter to accept a `WP_Post_Type`
   --               object.
   -- @since 5.9.0 Added `is_post_type_viewable` hook to filter the result.
   --
   -- @param string|WP_Post_Type post_type Post type name or object.
   -- @return bool Whether the post type should be considered viewable.
   --
   function Is_Post_Type_Viewable (Post_Type : String)
                                   return Boolean;

   function Is_Post_Type_Viewable (Post_Type : Class_Post_Type.Wp_Post_Type)
                                   return Boolean;

   --
   -- Trashes or deletes an attachment.
   --
   -- When an attachment is permanently deleted, the file will also be removed.
   -- Deletion removes all post meta fields, taxonomy, comments, etc. associated
   -- with the attachment (except the main post).
   --
   -- The attachment is moved to the Trash instead of permanently deleted unless Trash
   -- for media is disabled, item is already in the Trash, or force_delete is True.
   --
   -- @since 2.0.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int  post_id      Attachment ID.
   -- @param bool force_delete Optional. Whether to bypass Trash and force deletion.
   --                           Default False.
   -- @return WP_Post|False|null Post data on success, False or null on failure.
   --
   function Wp_Delete_Attachment (Post_Id      : Integer;
                                  Force_Delete : Boolean := False)
                                  return Class_Posts.Wp_Post
                                  is (Class_Posts.Null_Post);

   --
   -- Updates a post with new post data.
   --
   -- The date does not have to be set for drafts. You can set the date and it will
   -- not be overridden.
   --
   -- @since 1.0.0
   -- @since 3.5.0 Added the `$wp_error` parameter to allow a WP_Error to be returned on failure.
   -- @since 5.6.0 Added the `$fire_after_hooks` parameter.
   --
   -- @param array|object $postarr          Optional. Post data. Arrays are expected to be escaped,
   --                                       objects are not. See wp_insert_post() for accepted arguments.
   --                                       Default array.
   -- @param bool         $wp_error         Optional. Whether to return a WP_Error on failure. Default false.
   -- @param bool         $fire_after_hooks Optional. Whether to fire the after insert hooks. Default true.
   -- @return int|WP_Error The post ID on success. The value 0 or WP_Error on failure.
   --
   function Wp_Update_Post (Postarr          : Array_Type := Empty_Array;
                            wp_error         : Boolean    := False;
                            Fire_After_Hooks : Boolean    := True)
                            return Integer
                            is (1);

   --
   -- Updates metadata for an attachment.
   --
   -- @since 2.1.0
   --
   -- @param int   attachment_id Attachment post ID.
   -- @param array data          Attachment meta data.
   -- @return int|False False if post is invalid.
   --
   function Wp_Update_Attachment_Metadata (Attachment_Id : Integer;
                                           Data          : Array_Type)
                                           return Integer
                                           is (1);

   --
   -- Sanitizes every post field.
   --
   -- If the context is 'raw', then the post object or array will get minimal
   -- sanitization of the integer fields.
   --
   -- @since 2.3.0
   --
   -- @see sanitize_post_field()
   --
   -- @param object|WP_Post|array $post    The post object or array
   -- @param string               $context Optional. How to sanitize post fields.
   --                                      Accepts 'raw', 'edit', 'db', 'display',
   --                                      'attribute', or 'js'. Default 'display'.
   -- @return object|WP_Post|array The now sanitized post object or array (will be the
   --                              same type as `$post`).
   --
   function Sanitize_Post (Post    : Class_Posts.Wp_Post;
                           Context : String := "display")
                           return Class_Posts.Wp_Post;
--   function Sanitize_Post (Key    : String;
--                           Post   : Array_Type;
--                           Id     : Integer; -- Inc_Class_Posts.Post_Id;
--                           Filter : String := "display")
--                           return Array_Type;

   --
   -- Sanitizes a post field based on context.
   --
   -- Possible context values are:  'raw', 'edit', 'db', 'display', 'attribute' and
   -- 'js'. The 'display' context is used by default. 'attribute' and 'js' contexts
   -- are treated like 'display' when calling filters.
   --
   -- @since 2.3.0
   -- @since 4.4.0 Like `sanitize_post()`, `$context` defaults to 'display'.
   --
   -- @param string $field   The Post Object field name.
   -- @param mixed  $value   The Post Object value.
   -- @param int    $post_id Post ID.
   -- @param string $context Optional. How to sanitize the field. Possible values
   --                        are 'raw', 'edit', 'db', 'display', 'attribute' and
   --                        'js'. Default 'display'.
   -- @return mixed Sanitized value.
   --
   function Sanitize_Post_Field (Field   : String;
                                 Value   : Array_Type; -- Inc_Class_Posts.Wp_Post;
                                 Post_Id : Class_Posts.Post_Id;
                                 Context : String := "display")
                                 return Array_Type;
   --
   -- Moves a post or page to the Trash
   --
   -- If Trash is disabled, the post or page is permanently deleted.
   --
   -- @since 2.9.0
   --
   -- @see wp_delete_post()
   --
   -- @param int $post_id Optional. Post ID. Default is the ID of the global `$post`
   --                     if `EMPTY_TRASH_DAYS` equals true.
   -- @return WP_Post|false|null Post data on success, false or null on failure.
   --
   function Wp_Trash_Post (Post_Id : String)
                           return Boolean
                           is (True);

   --
   -- Restores a post from the Trash.
   --
   -- @since 2.9.0
   -- @since 5.6.0 An untrashed post is now returned to 'draft' status by default,
   --              except for attachments which are returned to their original
   --              'inherit' status.
   --
   -- @param int $post_id Optional. Post ID. Default is the ID of the global `$post`.
   -- @return WP_Post|false|null Post data on success, false or null on failure.
   --
   function Wp_Untrash_Post (Post_Id : Integer := 0)
                             return Wp_Post;

   function Wp_Untrash_Post (Item : String)
                             return Boolean
                             is (True);

   function Wp_Untrash_Post (Item : Class_Posts.Wp_Post)
                             return Boolean
                             is (True);

   --
   -- Inserts or update a post.
   --
   -- If the postarr parameter has "ID" set to a value, then post will be updated.
   --
   -- You can set the post date manually, by setting the values for "post_date"
   -- and "post_date_gmt" keys. You can close the comments or open the comments by
   -- setting the value for "comment_status" key.
   --
   -- @since 1.0.0
   -- @since 2.6.0 Added the `wp_error` parameter to allow a WP_Error to be returned
   --               on failure.
   -- @since 4.2.0 Support was added for encoding emoji in the post title, content,
   --               and excerpt.
   -- @since 4.4.0 A "meta_input" array can now be passed to `postarr` to add post
   --               meta data.
   -- @since 5.6.0 Added the `fire_after_hooks` parameter.
   --
   -- @see sanitize_post()
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param array postarr {
   --     An array of elements that make up a post to update or insert.
   --
   --     @type int    ID                    The post ID. If equal to something other
   --                                         than 0, the post with that ID will be
   --                                         updated. Default 0.
   --     @type int    post_author           The ID of the user who added the post.
   --                                         Default is the current user ID.
   --     @type string post_date             The date of the post. Default is the
   --                                         current time.
   --     @type string post_date_gmt         The date of the post in the GMT timezone.
   --                                         Default is the value of `post_date`.
   --     @type string post_content          The post content. Default empty.
   --     @type string post_content_filtered The filtered post content. Default empty.
   --     @type string post_title            The post title. Default empty.
   --     @type string post_excerpt          The post excerpt. Default empty.
   --     @type string post_status           The post status. Default "draft".
   --     @type string post_type             The post type. Default "post".
   --     @type string comment_status        Whether the post can accept comments.
   --                                         Accepts "open" or "closed". Default is
   --                                         the value of "default_comment_status"
   --                                         option.
   --     @type string ping_status           Whether the post can accept pings.
   --                                         Accepts "open" or "closed". Default is
   --                                         the value of "default_ping_status"
   --                                         option.
   --     @type string post_password         The password to access the post. Default
   --                                         empty.
   --     @type string post_name             The post name. Default is the sanitized
   --                                         post title when creating a new post.
   --     @type string to_ping               Space or carriage return-separated list
   --                                         of URLs to ping. Default empty.
   --     @type string pinged                Space or carriage return-separated list
   --                                         of URLs that have been pinged. Default
   --                                         empty.
   --     @type string post_modified         The date when the post was last modified.
   --                                         Default is the current time.
   --     @type string post_modified_gmt     The date when the post was last modified
   --                                         in the GMT timezone. Default is the
   --                                         current time.
   --     @type int    post_parent           Set this for the post it belongs to, if
   --                                         any. Default 0.
   --     @type int    menu_order            The order the post should be displayed
   --                                         in. Default 0.
   --     @type string post_mime_type        The mime type of the post. Default empty.
   --     @type string guid                  Global Unique ID for referencing the
   --                                         post. Default empty.
   --     @type int    import_id             The post ID to be used when inserting a
   --                                         new post. If specified, must not match
   --                                         any existing post ID. Default 0.
   --     @type int[]  post_category         Array of category IDs.
   --                                         Defaults to value of the
   --                                         "default_category" option.
   --     @type array  tags_input            Array of tag names, slugs, or IDs.
   --                                         Default empty.
   --     @type array  tax_input             An array of taxonomy terms keyed by their
   --                                         taxonomy name. If the taxonomy is
   --                                         hierarchical, the term list needs to be
   --                                         either an array of term IDs or a
   --                                         comma-separated string of IDs. If the
   --                                         taxonomy is non-hierarchical, the term
   --                                         list can be an array that contains term
   --                                         names or slugs, or a comma-separated
   --                                         string of names or slugs. This is
   --                                         because, in hierarchical taxonomy, child
   --                                         terms can have the same names with
   --                                         different parent terms, so the only way
   --                                         to connect them is using ID. Default
   --                                         empty.
   --     @type array  meta_input            Array of post meta values keyed by their
   --                                         post meta key. Default empty.
   --     @type string page_template         Page template to use.
   -- }
   -- @param bool  wp_error         Optional. Whether to return a WP_Error on failure.
   --                                          Default False.
   -- @param bool  fire_after_hooks Optional. Whether to fire the after insert hooks.
   --                                          Default True.
   -- @return int|WP_Error The post ID on success. The value 0 or WP_Error on failure.
   --
   function Wp_Insert_Post (Postarr          : Array_Type;
                            Wp_Error         : Boolean := False;
                            Fire_After_Hooks : Boolean := True)
                            return Post_Id
                            is (0);

   --
   -- Retrieves the icon for a MIME type or attachment.
   --
   -- @since 2.1.0
   --
   -- @param string|int mime MIME type or attachment ID.
   -- @return string|False Icon, False otherwise.
   --
   function Wp_MIME_Type_Icon (MIME : Integer := 0)
                               return String;

   --
   -- Retrieves a page given its path.
   --
   -- @since 2.1.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string       page_path Page path.
   -- @param string       output    Optional. The required return type. One of OBJECT,
   --                                ARRAY_A, or ARRAY_N, which correspond to a
   --                                WP_Post object, an associative array, or a
   --                                numeric array, respectively. Default OBJECT.
   -- @param string|array post_type Optional. Post type or array of post types.
   --                                Default "page".
   -- @return WP_Post|array|null WP_Post (or array) on success, or null on failure.
   --
   function Get_Page_By_Path (Page_Path : String;
                              Output    : String := "OBJECT";
                              Post_Type : String := "page")
                              return Wp_Post;

   --
   -- Retrieves the IDs of the ancestors of a post.
   --
   -- @since 2.5.0
   --
   -- @param int|WP_Post $post Post ID or post object.
   -- @return int[] Array of ancestor IDs or empty array if there are none.
   --
   function Get_Post_Ancestors (Post : Class_Posts.Wp_Post)
                                return Array_Type;

   function Get_Post_Ancestors (Post : Class_Posts.Post_Id)
                                return Class_Taxonomy.Int_Arrays.Vector
                                is (raise Program_Error with "not implemented");

   --
   -- Retrieves the post status based on the post ID.
   --
   -- If the post ID is of an attachment, then the parent post status will be given
   -- instead.
   --
   -- @since 2.0.0
   --
   -- @param int|WP_Post post Optional. Post ID or post object. Defaults to global
   --                          post.
   -- @return string|False Post status on success, False on failure.
   --
   function Get_Post_Status (Post : Wp_Post := Null_Post)
                             return String;
   function Get_Post_Status (Post : Post_Id := 0)
                             return String;

   --
   -- Retrieves a post meta field for the given post ID.
   --
   -- @since 1.5.0
   --
   -- @param int    $post_id Post ID.
   -- @param string $key     Optional. The meta key to retrieve. By default,
   --                        returns data for all keys. Default empty.
   -- @param bool   $single  Optional. Whether to return a single value.
   --                        This parameter has no effect if `$key` is not specified.
   --                        Default false.
   -- @return mixed An array of values if `$single` is false.
   --               The value of the meta field if `$single` is true.
   --               False for an invalid `$post_id` (non-numeric, zero, or negative
   --               value). An empty string if a valid but non-existing post ID is
   --               passed.
   --
   function Get_Post_Meta (Post_Id : Class_Posts.Post_Id;
                           Key     : String  := "";
                           Single  : Boolean := False)
                           return Array_Type; -- Post_Id_List;
   function Get_Post_Meta (Post_Id : Class_Posts.Post_Id;
                           Key     : String  := "";
                           Single  : Boolean := False)
                           return String;

   --
   -- Updates a post meta field based on the given post ID.
   --
   -- Use the `$prev_value` parameter to differentiate between meta fields with the
   -- same key and post ID.
   --
   -- If the meta field for the post does not exist, it will be added and its ID returned.
   --
   -- Can be used in place of add_post_meta().
   --
   -- @since 1.5.0
   --
   -- @param int    $post_id    Post ID.
   -- @param string $meta_key   Metadata key.
   -- @param mixed  $meta_value Metadata value. Must be serializable if non-scalar.
   -- @param mixed  $prev_value Optional. Previous value to check before updating.
   --                           If specified, only update existing metadata entries with
   --                           this value. Otherwise, update all entries. Default empty.
   -- @return int|bool Meta ID if the key didn't exist, true on successful update,
   --                  false on failure or if the value passed to the function
   --                  is the same as the one that is already in the database.
   --
   function Update_Post_Meta (Post_Id    : Class_Posts.Post_Id; -- Integer;
                              Meta_Key   : String;
                              Meta_Value : Array_Type;
                              Prev_Value : Array_Type := Empty_Array) -- = '' )
                              return Integer
                              is (1);

   procedure Update_Post_Meta (Post_Id    : Class_Posts.Post_Id;
                               Meta_Key   : String;
                               Meta_Value : String;
                               Prev_Value : Array_Type := Empty_Array) -- = '' )
   is null;

   --
   -- Retrieves the URL for an attachment.
   --
   -- @since 2.1.0
   --
   -- @global string $pagenow The filename of the current screen.
   --
   -- @param int $attachment_id Optional. Attachment post ID. Defaults to global $post.
   -- @return string|false Attachment URL, otherwise false.
   --
   function Wp_Get_Attachment_Url (Attachment_Id : Integer := 0)
                                   return String
                                   is ("XXX-209");

   --
   -- Retrieves attachment metadata for attachment ID.
   --
   -- @since 2.1.0
   -- @since 6.0.0 The `filesize` value was added to the returned array.
   --
   -- @param int  attachment_id Attachment post ID. Defaults to global post.
   -- @param bool unfiltered    Optional. If True, filters are not run. Default False.
   -- @return array|False {
   --     Attachment metadata. False on failure.
   --
   --     @type int    width      The width of the attachment.
   --     @type int    height     The height of the attachment.
   --     @type string file       The file path relative to `wp-content/uploads`.
   --     @type array  sizes      Keys are size slugs, each value is an array
   --                             containing "file", "width", "height", and
   --                             "mime-type".
   --     @type array  image_meta Image metadata.
   --     @type int    filesize   File size of the attachment.
   -- }
   --

   function Wp_Get_Attachment_Metadata (Attachment_Id : Integer := 0;
                                        Unfiltered    : Boolean := False)
                                        return Array_Type
                                        is (Empty_Array);

   --
   -- Returns whether the post can be edited in the block editor.
   --
   -- @since 5.0.0
   -- @since 6.1.0 Moved to wp-includes from wp-admin.
   --
   -- @param int|WP_Post post Post ID or WP_Post object.
   -- @return bool Whether the post can be edited in the block editor.
   --
   function Use_Block_Editor_For_Post (Post : Wp_Post)
                                       return Boolean
                                       is (True);

   --
   -- Filters callback which sets the status of an untrashed post to its previous
   -- status.
   --
   -- This can be used as a callback on the `wp_untrash_post_status` filter.
   --
   -- @since 5.6.0
   --
   -- @param string new_status      The new status of the post being restored.
   -- @param int    post_id         The ID of the post being restored.
   -- @param string previous_status The status of the post at the point where it was trashed.
   -- @return string The new status of the post.
   --
   function Wp_Untrash_Post_Set_Previous_Status (New_Status      : String;
                                                 Post_Id         : Integer;
                                                 Previous_Status : String)
                                                 return String
                                                 is ("XXX-611");

   -- By jq
   function Get (Post  : Wp_Post;
                 Field : String)
                 return Array_Type is (Empty_Array);

   procedure Set (Post  : in out Wp_Post;
                  Field : String;
                  Value : Array_Type) is null;

   procedure Set (Post  : in out Wp_Post;
                  Field : String;
                  Value : String) is null;

   Null_Status : constant Status_Type :=
     (Label       => Null_Unbounded_String,
      Label_Count => Empty_Array,
      others      => False);
         -- Exclude_From_Search : Boolean;
         -- X_Builtin : Boolean;
         -- Public : Boolean;
         -- Internal : Boolean;
         -- Protect : Boolean;
         -- Privat : Boolean;
         -- Publicly_Queryable : Boolean;
         -- Show_In_Admin_All_List : Boolean;
         -- Show_In_Admin_Status_List : Boolean;
         -- Date_Floating : Boolean);

end Inc_Posts;
