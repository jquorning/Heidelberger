--
-- Post API: WP_Post_Type class
--
-- @package WordPress
-- @subpackage Post
-- @since 4.6.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Arrays;

-- with Inc_Posts; -- circular

package Inc_Class_Wp_Post_Type
is
   use Ada.Strings.Unbounded;
   use Arrays;

   procedure Dummy;

--
-- Core class used for interacting with post types.
--
-- @since 4.6.0
--
-- @see register_post_type()
--
--#[AllowDynamicProperties]
   type Wp_Post_Type is tagged
      record
        --
        -- Post type key.
        --
        -- @since 4.6.0
        -- @var string name
        --
        Name : Unbounded_String;

        --
        -- Name of the post type shown in the menu. Usually plural.
        --
        -- @since 4.6.0
        -- @var string label
        --
        Label : Unbounded_String;

        --
        -- Labels object for this post type.
        --
        -- If not set, post labels are inherited for non-hierarchical types
        -- and page labels for hierarchical ones.
        --
        -- @see get_post_type_labels()
        --
        -- @since 4.6.0
        -- @var stdClass labels
        --
        Labels : Array_Type;

        --
        -- Default labels.
        --
        -- @since 6.0.0
        -- @var (string|null)[][] default_labels
        --
--        protected static default_labels = array();

        --
        -- A short descriptive summary of what the post type is.
        --
        -- Default empty.
        --
        -- @since 4.6.0
        -- @var string description
        --
        Description : Unbounded_String;

        --
        -- Whether a post type is intended for use -- publicly either via the admin interface or by front-end users.
        --
        -- While the default settings of exclude_from_search, -- publicly_queryable, show_ui, and show_in_nav_menus
        -- are inherited from -- public, each does not rely on this relationship and controls a very specific intention.
        --
        -- Default false.
        --
        -- @since 4.6.0
        -- @var bool -- public
        --
        Public : Boolean := False;

        --
        -- Whether the post type is hierarchical (e.g. page).
        --
        -- Default false.
        --
        -- @since 4.6.0
        -- @var bool hierarchical
        --
        Hierarchical : Boolean := False;

        --
        -- Whether to exclude posts with this post type from front end search
        -- results.
        --
        -- Default is the opposite value of -- public.
        --
        -- @since 4.6.0
        -- @var bool exclude_from_search
        --
        Exclude_From_Search : Boolean := False; --  = null;

        --
        -- Whether queries can be performed on the front end for the post type as
        --  part of `parse_request()`.
        --
        -- Endpoints would include:
        --
        -- - `?post_type=thenpost_type_keyend;`
        -- - `?thenpost_type_keyend;=thensingle_post_slugend;`
        -- - `?thenpost_type_query_varend;=thensingle_post_slugend;`
        --
        -- Default is the value of -- public.
        --
        -- @since 4.6.0
        -- @var bool -- publicly_queryable
        --
        Publicly_Queryable : Boolean := False; --  = null;

        --
        -- Whether to generate and allow a UI for managing this post type in the admin.
        --
        -- Default is the value of -- public.
        --
        -- @since 4.6.0
        -- @var bool show_ui
        --
        Show_Ui : Boolean := False; --  = null;

        --
        -- Where to show the post type in the admin menu.
        --
        -- To work, show_ui must be true. If true, the post type is shown in its own
        -- top level menu. If false, no menu is
        -- shown. If a string of an existing top level menu ("tools.php" or
        -- "edit.php?post_type=page", for example), the
        -- post type will be placed as a sub-menu of that.
        --
        -- Default is the value of show_ui.
        --
        -- @since 4.6.0
        -- @var bool|string show_in_menu
        --
        -- public show_in_menu = null;
        Show_In_Menu_Bool : Boolean;
        Show_In_Menu      : Unbounded_String;

        --
        -- Makes this post type available for selection in navigation menus.
        --
        -- Default is the value -- public.
        --
        -- @since 4.6.0
        -- @var bool show_in_nav_menus
        --
        Show_In_Nav_Menus : Boolean := False; --  = null;

        --
        -- Makes this post type available via the admin bar.
        --
        -- Default is the value of show_in_menu.
        --
        -- @since 4.6.0
        -- @var bool show_in_admin_bar
        --
        Show_In_Admin_Bar : Boolean := False; -- = null;

        --
        -- The position in the menu order the post type should appear.
        --
        -- To work, show_in_menu must be true. Default null (at the bottom).
        --
        -- @since 4.6.0
        -- @var int menu_position
        --
        Menu_Position : Integer := 0; -- null;

        --
        -- The URL or reference to the icon to be used for this menu.
        --
        -- Pass a base64-encoded SVG using a data URI, which will be colored to match
        -- the color scheme.
        -- This should begin with "data:image/svg+xml;base64,". Pass the name of a
        -- Dashicons helper class
        -- to use a font icon, e.g. "dashicons-chart-pie". Pass "none" to leave
        -- div.wp-menu-image empty
        -- so an icon can be added via CSS.
        --
        -- Defaults to use the posts icon.
        --
        -- @since 4.6.0
        -- @var string menu_icon
        --
        Menu_Icon : Unbounded_String; --  = null;

        --
        -- The string to use to build the read, edit, and delete capabilities.
        --
        -- May be passed as an array to allow for alternative plurals when using
        -- this argument as a base to construct the capabilities, e.g.
        -- array( "story", "stories" ). Default "post".
        --
        -- @since 4.6.0
        -- @var string capability_type
        --
        Capability_Type : Unbounded_String := To_Unbounded_String ("post");

        --
        -- Whether to use the internal default meta capability handling.
        --
        -- Default false.
        --
        -- @since 4.6.0
        -- @var bool map_meta_cap
        --
        Map_Meta_Cap : Boolean := False;

        --
        -- Provide a callback function that sets up the meta boxes for the edit form.
        --
        -- Do `remove_meta_box()` and `add_meta_box()` calls in the callback. Default null.
        --
        -- @since 4.6.0
        -- @var callable register_meta_box_cb
        --
        -- public register_meta_box_cb = null;

        --
        -- An array of taxonomy identifiers that will be registered for the post type.
        --
        -- Taxonomies can be registered later with `register_taxonomy()` or `register_taxonomy_for_object_type()`.
        --
        -- Default empty array.
        --
        -- @since 4.6.0
        -- @var string[] taxonomies
        --
        -- public taxonomies = array();

        --
        -- Whether there should be post type archives, or if a string, the archive slug to use.
        --
        -- Will generate the proper rewrite rules if rewrite is enabled. Default false.
        --
        -- @since 4.6.0
        -- @var bool|string has_archive
        --
        -- public has_archive = false;

        --
        -- Sets the query_var key for this post type.
        --
        -- Defaults to post_type key. If false, a post type cannot be loaded at `?thenquery_varend;=thenpost_slugend;`.
        -- If specified as a string, the query `?thenquery_var_stringend;=thenpost_slugend;` will be valid.
        --
        -- @since 4.6.0
        -- @var string|bool query_var
        --
        -- public query_var;

        --
        -- Whether to allow this post type to be exported.
        --
        -- Default true.
        --
        -- @since 4.6.0
        -- @var bool can_export
        --
        Can_Export : Boolean := True;

        --
        -- Whether to delete posts of this type when deleting a user.
        --
        -- - If true, posts of this type belonging to the user will be moved to Trash when the user is deleted.
        -- - If false, posts of this type belonging to the user will--not* be trashed or deleted.
        -- - If not set (the default), posts are trashed if post type supports the "author" feature.
        --   Otherwise posts are not trashed or deleted.
        --
        -- Default null.
        --
        -- @since 4.6.0
        -- @var bool delete_with_user
        --
        Delete_With_User : Boolean := False; -- = null;

        --
        -- Array of blocks to use as the default initial state for an editor session.
        --
        -- Each item should be an array containing block name and optional attributes.
        --
        -- Default empty array.
        --
        -- @link https://developer.wordpress.org/block-editor/developers/block-api/block-templates/
        --
        -- @since 5.0.0
        -- @var array[] template
        --
        -- public template = array();

        --
        -- Whether the block template should be locked if template is set.
        --
        -- - If set to "all", the user is unable to insert new blocks, move existing blocks
        --   and delete blocks.
        -- - If set to "insert", the user is able to move existing blocks but is unable to insert
        --   new blocks and delete blocks.
        --
        -- Default false.
        --
        -- @link https://developer.wordpress.org/block-editor/developers/block-api/block-templates/
        --
        -- @since 5.0.0
        -- @var string|false template_lock
        --
        -- public template_lock = false;

        --
        -- Whether this post type is a native or "built-in" post_type.
        --
        -- Default false.
        --
        -- @since 4.6.0
        -- @var bool _builtin
        --
        -- public _builtin = false;

        --
        -- URL segment to use for edit link of this post type.
        --
        -- Default "post.php?post=%d".
        --
        -- @since 4.6.0
        -- @var string _edit_link
        --
        -- public _edit_link = "post.php?post=%d";

        --
        -- Post type capabilities.
        --
        -- @since 4.6.0
        -- @var stdClass cap
        --
        Cap : Array_Type;

        --
        -- Triggers the handling of rewrites for this post type.
        --
        -- Defaults to true, using post_type as slug.
        --
        -- @since 4.6.0
        -- @var array|false rewrite
        --
        -- public rewrite;

        --
        -- The features supported by the post type.
        --
        -- @since 4.6.0
        -- @var array|bool supports
        --
        -- public supports;

        --
        -- Whether this post type should appear in the REST API.
        --
        -- Default false. If true, standard endpoints will be registered with
        -- respect to rest_base and rest_controller_class.
        --
        -- @since 4.7.4
        -- @var bool show_in_rest
        --
        Show_In_Rest : Boolean;

        --
        -- The base path for this post type"s REST API endpoints.
        --
        -- @since 4.7.4
        -- @var string|bool rest_base
        --
        -- public rest_base;

        --
        -- The namespace for this post type"s REST API endpoints.
        --
        -- @since 5.9.0
        -- @var string|bool rest_namespace
        --
        -- public rest_namespace;

        --
        -- The controller for this post type"s REST API endpoints.
        --
        -- Custom controllers must extend WP_REST_Controller.
        --
        -- @since 4.7.4
        -- @var string|bool rest_controller_class
        --
        -- public rest_controller_class;

        --
        -- The controller instance for this post type"s REST API endpoints.
        --
        -- Lazily computed. Should be accessed using {@see WP_Post_Type::get_rest_controller()}.
        --
        -- @since 5.3.0
        -- @var WP_REST_Controller rest_controller
        --
        -- public rest_controller;

      end record;

        --
        -- Constructor.
        --
        -- See the register_post_type() function for accepted arguments for `args`.
        --
        -- Will populate object properties from the provided arguments and assign other
        -- default properties based on that information.
        --
        -- @since 4.6.0
        --
        -- @see register_post_type()
        --
        -- @param string       post_type Post type key.
        -- @param array|string args      Optional. Array or string of arguments for registering a post type.
        --                                Default empty array.
        --
--        function X_Construct (Post_Type : String;
--                              Args      : Inc_Posts.Args_Type) -- = array() )
--                              return Wp_Post_Type;

   --
   -- Sets the features support for the post type.
   --
   -- @since 4.6.0
   --
   procedure Add_Supports (This : in out Wp_Post_Type) is null;

   --
   -- Adds the necessary rewrite rules for the post type.
   --
   -- @since 4.6.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   -- @global WP         wp         Current WordPress environment instance.
   --
   procedure Add_Rewrite_Rules (This : in out Wp_Post_Type) is null;

   --
   -- Registers the post type meta box if a custom callback was specified.
   --
   -- @since 4.6.0
   --
   procedure Register_Meta_Boxes (This : in out Wp_Post_Type) is null;

   --
   -- Adds the future post hook action for the post type.
   --
   -- @since 4.6.0
   --
   procedure Add_Hooks (This : in out Wp_Post_Type) is null;

   --
   -- Registers the taxonomies for the post type.
   --
   -- @since 4.6.0
   --
   procedure Register_Taxonomies (This : in out Wp_Post_Type) is null;

   Null_Post_Type : constant Wp_Post_Type :=
     (Labels              => Empty_Array,
      Show_Ui             => False, --  = null;
      Publicly_Queryable  => False, --  = null;
      Exclude_From_Search => False, --  = null;
      Hierarchical      => False,
      Public            => False,
      Menu_Position     => 0, -- null;
      Show_In_Admin_Bar => False, -- = null;
      Show_In_Nav_Menus => False, --  = null;
      Show_In_Menu_Bool => False,
      Show_In_Rest      => False,
      Cap               => Empty_Array,
      Delete_With_User  => False, -- = null;
      Can_Export        => False,
      Map_Meta_Cap      => False,
      others            => Null_Unbounded_String);

   package Post_Type_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => Wp_Post_Type);
   subtype Wp_Post_Type_Array is Post_Type_Maps.Map;

   --
   -- Resets the cache for the default labels.
   --
   -- @since 6.0.0
   --
   -- public static
   procedure Reset_Default_Labels is null;

end Inc_Class_Wp_Post_Type;
