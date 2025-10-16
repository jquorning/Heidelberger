--
-- Taxonomy API: WP_Taxonomy class
--
-- @package WordPress
-- @subpackage Taxonomy
-- @since 4.7.0
--

with Ada.Strings.Unbounded;
with Arrays;

package Inc_Class_Wp_Taxonomy
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- Core class used for interacting with taxonomies.
   --
   -- @since 4.7.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Taxonomy is tagged
      record
         --
         -- Taxonomy key.
         --
         -- @since 4.7.0
         -- @var string
         --
         Name : Unbounded_String;

         --
         -- Name of the taxonomy shown in the menu. Usually plural.
         --
         -- @since 4.7.0
         -- @var string
         --
         Label : Unbounded_String;

         --
         -- Labels object for this taxonomy.
         --
         -- If not set, tag labels are inherited for non-hierarchical types
         -- and category labels for hierarchical ones.
         --
         -- @see get_taxonomy_labels()
         --
         -- @since 4.7.0
         -- @var stdClass
         --
         Labels : Array_Type; -- List_Type;

         --
         -- Default labels.
         --
         -- @since 6.0.0
         -- @var (string|null)[][] default_labels
         --
--        protected static default_labels = array();

         --
         -- A short descriptive summary of what the taxonomy is for.
         --
         -- @since 4.7.0
         -- @var string
         --
         Description : Unbounded_String;

         --
         -- Whether a taxonomy is intended for use -- publicly either via the admin interface or by front-end users.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Public : Boolean := True;

         --
         -- Whether the taxonomy is -- publicly queryable.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Publicly_Queryable : Boolean := True;

         --
         -- Whether the taxonomy is hierarchical.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Hierarchical : Boolean := False;

         --
         -- Whether to generate and allow a UI for managing terms in this taxonomy in the admin.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Show_UI : Boolean := True;

         --
         -- Whether to show the taxonomy in the admin menu.
         --
         -- If true, the taxonomy is shown as a submenu of the object type menu. If false, no menu is shown.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Show_In_Menu : Boolean := True;

         --
         -- Whether the taxonomy is available for selection in navigation menus.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Show_In_Nav_Menus : Boolean := True;

         --
         -- Whether to list the taxonomy in the tag cloud widget controls.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Show_Tagcloud : Boolean := True;

         --
         -- Whether to show the taxonomy in the quick/bulk edit panel.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Show_In_Quick_Edit : Boolean := True;

         --
         -- Whether to display a column for the taxonomy on its post type listing screens.
         --
         -- @since 4.7.0
         -- @var bool
         --
         Show_Admin_Column : Boolean := False;

         --
         -- The callback function for the meta box display.
         --
         -- @since 4.7.0
         -- @var bool|callable
         --
         -- public meta_box_cb = null;

         --
         -- The callback function for sanitizing taxonomy data saved from a meta box.
         --
         -- @since 5.1.0
         -- @var callable
         --
         -- public meta_box_sanitize_cb = null;

         --
         -- An array of object types this taxonomy is registered for.
         --
         -- @since 4.7.0
         -- @var string[]
         --
         Object_Type : String_Array; -- = null;

         --
         -- Capabilities for this taxonomy.
         --
         -- @since 4.7.0
         -- @var stdClass
         --
         -- public cap;
         Cap : Array_Type;

         --
         -- Rewrites information for this taxonomy.
         --
         -- @since 4.7.0
         -- @var array|false
         --
         Rewrite : Array_Type;

         --
         -- Query var string for this taxonomy.
         --
         -- @since 4.7.0
         -- @var string|false
         --
         Query_Var : Unbounded_String;

         --
         -- Function that will be called when the count is updated.
         --
         -- @since 4.7.0
         -- @var callable
         --
         -- public update_count_callback;

         --
         -- Whether this taxonomy should appear in the REST API.
         --
         -- Default false. If true, standard endpoints will be registered with
         -- respect to rest_base and rest_controller_class.
         --
         -- @since 4.7.4
         -- @var bool show_in_rest
         --
         Show_In_REST : Boolean;

         --
         -- The base path for this taxonomy's REST API endpoints.
         --
         -- @since 4.7.4
         -- @var string|bool rest_base
         --
         -- public rest_base;

         --
         -- The namespace for this taxonomy's REST API endpoints.
         --
         -- @since 5.9.0
         -- @var string|bool rest_namespace
         --
         -- public rest_namespace;

         --
         -- The controller for this taxonomy's REST API endpoints.
         --
         -- Custom controllers must extend WP_REST_Controller.
         --
         -- @since 4.7.4
         -- @var string|bool rest_controller_class
         --
         -- public rest_controller_class;

         --
         -- The controller instance for this taxonomy's REST API endpoints.
         --
         -- Lazily computed. Should be accessed using {@see WP_Taxonomy::get_rest_controller()}.
         --
         -- @since 5.5.0
         -- @var WP_REST_Controller rest_controller
         --
         -- public rest_controller;

         --
         -- The default term name for this taxonomy. If you pass an array you have
         -- to set 'name' and optionally 'slug' and 'description'.
         --
         -- @since 5.5.0
         -- @var array|string
         --
         Default_Term : Array_Type; -- Unbounded_String;

         --
         -- Whether terms in this taxonomy should be sorted in the order they are provided to `wp_set_object_terms()`.
         --
         -- Use this in combination with `'orderby' => 'term_order'` when fetching terms.
         --
         -- @since 2.5.0
         -- @var bool|null
         --
         -- public sort = null;

         --
         -- Array of arguments to automatically use inside `wp_get_object_terms()` for this taxonomy.
         --
         -- @since 2.6.0
         -- @var array|null
         --
         Args : Array_Type; --  = null;

         --
         -- Whether it is a built-in taxonomy.
         --
         -- @since 4.7.0
         -- @var bool
         --
         -- public _builtin;

      end record;

   --
   -- Constructor.
   --
   -- See the register_taxonomy() function for accepted arguments for `args`.
   --
   -- @since 4.7.0
   --
   -- @global WP wp Current WordPress environment instance.
   --
   -- @param string       taxonomy    Taxonomy key, must not exceed 32 characters.
   -- @param array|string object_type Name of the object type for the taxonomy object.
   -- @param array|string args        Optional. Array or query string of arguments
   --                                 for registering a taxonomy. Default empty array.
   --
   function X_Construct (Taxonomy    : String;
                         Object_Type : List_Type;
                         Args        : Array_Type := Empty_Array)
                         return Wp_Taxonomy;

   --
   -- Sets taxonomy properties.
   --
   -- See the register_taxonomy() function for accepted arguments for `args`.
   --
   -- @since 4.7.0
   --
   -- @param string|string[] object_type Name or array of names of the object types
   --                                    for the taxonomy.
   -- @param array|string    args        Array or query string of arguments for
   --                                    registering a taxonomy.
   --
   procedure Set_Props (This        : in out Wp_Taxonomy;
                        Object_Type : List_Type;
                        Args        : Array_Type);

   --
   -- Adds the necessary rewrite rules for the taxonomy.
   --
   -- @since 4.7.0
   --
   -- @global WP wp Current WordPress environment instance.
   --
   procedure Add_Rewrite_Rules (This : Wp_Taxonomy);

   --
   -- Registers the ajax callback for the meta box.
   --
   -- @since 4.7.0
   --
   procedure Add_Hooks (This : Wp_Taxonomy);

   Null_Taxonomy : constant Wp_Taxonomy :=
      (Labels             => Empty_Array, -- Empty_List,
       Show_Admin_Column  => False,
       Show_In_Quick_Edit => False,
       Show_Tagcloud      => False,
       Show_In_Nav_Menus  => False,
       Show_In_Menu       => False,
       Show_UI            => False,
       Hierarchical       => False,
       Publicly_Queryable => False,
       Public             => False,
       Cap                => Empty_Array,
       Object_Type        => Empty_String_Array,
       Show_In_REST       => False,
       Default_Term       => Empty_Array,
       Args               => Empty_Array,
       Rewrite            => Empty_Array,
       others             => Null_Unbounded_String);

   --
   -- Default labels.
   --
   -- @since 6.0.0
   -- @var (string|null)[][] default_labels
   --
   -- protected static
   Self_Default_Labels : Array_Type;

   --
   -- Returns the default labels for taxonomies.
   --
   -- @since 6.0.0
   --
   -- @return (string|null)[][] The default labels for taxonomies.
   --
   -- static
   function Get_Default_Labels
            return Array_Type;

   --
   -- Resets the cache for the default labels.
   --
   -- @since 6.0.0
   --
   -- static
   procedure Reset_Default_Labels;

end Inc_Class_Wp_Taxonomy;
