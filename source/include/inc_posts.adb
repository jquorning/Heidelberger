--
-- Core Post API
--
-- @package WordPress
-- @subpackage Post
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Globals;
with Hb_Common;
with Php;

with Inc_Formatting;
with Inc_Functions;
with Inc_L10n;
with Inc_Meta;

package body Inc_Posts
is
   use Ada.Strings.Unbounded;
   use Hb_Common;
   use Php;
   use Inc_L10n;

   package Post_Type_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
         (Key_Type     => String,
          Element_Type => Inc_Class_Wp_Post_Type.Wp_Post_Type,
          "="          => Inc_Class_Wp_Post_Type."=");

   subtype Post_Type_Map is Post_Type_Maps.Map;

   Wp_Post_Types : Post_Type_Map; -- List_Type;


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
   procedure Create_Initial_Post_Types
   is
      use String_Vectors;
   begin
        Inc_Class_Wp_Post_Type.Reset_Default_Labels; -- :: ();

        Register_Post_Type (
                "post",
                Args_Type'(
                        Labels                =>
                           Arrays.To_Array ((
                              1 => Build ("name_admin_bar",
                                          x_x ("Post", "add new from admin bar")))),
                        public                => True,
                        x_builtin             => True, -- internal use only. don"t use this when registering your own post type.
                        x_edit_link           => +"post.php?post=%d", -- internal use only. don"t use this when registering your own post type.
                        Capability_Type_String => +"post",
                        Capability_Type_Array  => Empty_Array,
                        map_meta_cap          => True,
                        menu_position         => 5,
                        menu_icon             => +"dashicons-admin-post",
                        hierarchical          => False,
                        Rewrite_Bool          => False,
                        rewrite               => Empty_Rewrite,
                        Query_Var_bool        => False,
                        query_var             => Null_Unbounded_String,
                        delete_with_user      => True,
                        supports              => To_List ((+"title", +"editor", +"author", +"thumbnail", +"excerpt", +"trackbacks", +"custom-fields", +"comments", +"revisions", +"post-formats")),
                        show_in_rest          => True,
                        rest_base             => +"posts",
                        rest_controller_class => +"WP_REST_Posts_Controller",

                        -- Added
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
                        Rest_Namespace       => Null_Unbounded_String,
                        Capabilities         => Empty_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "page",
                Args_Type'(
                        labels                =>
                           Arrays.To_Array ((
                             1 => Build ("name_admin_bar",
                                         x_x ("Page", "add new from admin bar")))),
                        public                => True,
                        publicly_queryable    => False,
                        x_builtin             => True, -- internal use only. don"t use this when registering your own post type.--
                        x_edit_link           => +"post.php?post=%d", -- internal use only. don"t use this when registering your own post type.--
                        Capability_Type_String => +"page",
                        Capability_Type_Array  => Empty_Array,
                        map_meta_cap          => True,
                        menu_position         => 20,
                        menu_icon             => +"dashicons-admin-page",
                        hierarchical          => True,
                        rewrite               => Empty_Rewrite,
                        query_var             => Null_Unbounded_String,
                        delete_with_user      => True,
                        supports              => to_list ((+"title", +"editor", +"author", +"thumbnail", +"page-attributes", +"custom-fields", +"comments", +"revisions")),
                        show_in_rest          => True,
                        rest_base             => +"pages",
                        rest_controller_class => +"WP_REST_Posts_Controller",

                        -- Added
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
--                      Publicly_Queryable   => False,
                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
                        Rest_Namespace       => Null_Unbounded_String,
                        Capabilities         => Empty_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "attachment",
                Args_Type'(
                        labels                => Arrays.to_array ((
                                Build ("name",           x_x ("Media", "post type general name")),
                                Build ("name_admin_bar", x_x ("Media", "add new from admin bar")),
                                Build ("add_new",        x_x ("Add New", "file")),
                                Build ("edit_item",      abs "Edit Media"),
                                Build ("view_item",      abs "View Attachment Page"),
                                Build ("attributes",     abs "Attachment Attributes")
                        )),
                        public                => True,
                        show_ui               => True,
                        x_builtin             => True, -- internal use only. don"t use this when registering your own post type.
                        x_edit_link           => +"post.php?post=%d", -- internal use only. don"t use this when registering your own post type.
                        Capability_Type_String => +"post",
                        Capability_Type_Array  => Empty_Array,
                        capabilities          =>
                           Arrays.To_Array ((
                              1 => Build ("create_posts", "upload_files"))),
                        map_meta_cap          => True,
                        menu_icon             => +"dashicons-admin-media",
                        hierarchical          => False,
                        rewrite               => Empty_Rewrite,
                        query_var             => Null_Unbounded_String,
                        show_in_nav_menus     => False,
                        delete_with_user      => True,
                        supports              => To_List ((+"title", +"author", +"comments")),
                        show_in_rest          => True,
                        rest_base             => +"media",
                        rest_controller_class => +"WP_REST_Attachments_Controller",

                        -- Added
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
--                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
--                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
                        Rest_Namespace       => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0
--                        Capability_Type      => Null_Unbounded_String
                )
        );
        Add_Post_Type_Support ("attachment:audio", "thumbnail");
        Add_Post_Type_Support ("attachment:video", "thumbnail");

        Register_Post_Type (
                "revision",
                Args_Type'(
                        labels           => Arrays.to_array ((
                                Build ("name",          abs "Revisions"),
                                Build ("singular_name", abs "Revision")
                        )),
                        public           => False,
                        x_builtin         => True, -- internal use only. don"t use this when registering your own post type.--
                        x_edit_link       => +"revision.php?revision=%d", -- internal use only. don"t use this when registering your own post type.--
                        Capability_Type_String => +"post",
                        Capability_Type_Array  => Empty_Array,
                        map_meta_cap     => True,
                        hierarchical     => False,
                        rewrite          => Empty_Rewrite,
                        query_var        => Null_Unbounded_String,
                        can_export       => False,
                        delete_with_user => True,
                        supports         => to_list ((1 => +"author")),

                        -- Added
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
                        Rest_Base            => Null_Unbounded_String,
                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
                        Capabilities         => Empty_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
--                      Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0
--                        Capability_Type      => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "nav_menu_item",
                Args_Type'(
                        labels                => Arrays.to_array ((
                                Build ("name",          abs "Navigation Menu Items"),
                                Build ("singular_name", abs "Navigation Menu Item")
                        )),
                        public                => False,
                        x_builtin             => True, -- internal use only. don"t use this when registering your own post type.--
                        hierarchical          => False,
                        rewrite               => Empty_Rewrite,
                        delete_with_user      => False,
                        query_var             => Null_Unbounded_String,
                        map_meta_cap          => True,
                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  =>
                           Arrays.To_Array ((1 => Build ("edit_theme_options",
                                                         "edit_theme_options"))),
                        capabilities          => Arrays.To_Array ((
                                -- Meta Capabilities.
                                Build ("edit_post",              "edit_post"),
                                Build ("read_post",              "read_post"),
                                Build ("delete_post",            "delete_post"),
                                -- Primitive Capabilities.
                                Build ("edit_posts",             "edit_theme_options"),
                                Build ("edit_others_posts",      "edit_theme_options"),
                                Build ("delete_posts",           "edit_theme_options"),
                                Build ("publish_posts",          "edit_theme_options"),
                                Build ("read_private_posts",     "edit_theme_options"),
                                Build ("read",                   "read"),
                                Build ("delete_private_posts",   "edit_theme_options"),
                                Build ("delete_published_posts", "edit_theme_options"),
                                Build ("delete_others_posts",    "edit_theme_options"),
                                Build ("edit_private_posts",     "edit_theme_options"),
                                Build ("edit_published_posts",   "edit_theme_options")
                        )),
                        show_in_rest          => True,
                        rest_base             => +"menu-items",
                        rest_controller_class => +"WP_REST_Menu_Items_Controller",

                        -- Added
                        Supports             => Empty_List,
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
--                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
--                        Rest_Base            => Null_Unbounded_String,
--                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "custom_css",
                Args_Type'(
                        labels           => Arrays.to_array ((
                                Build ("name",          abs "Custom CSS"),
                                Build ("singular_name", abs "Custom CSS")
                        )),
                        public           => False,
                        hierarchical     => False,
                        rewrite          => Empty_Rewrite,
                        query_var        => Null_Unbounded_String,
                        delete_with_user => False,
                        can_export       => True,
                        x_builtin        => True, -- internal use only. don"t use this when registering your own post type.--
                        supports         => to_list ((+"title", +"revisions")),
                        capabilities     => Arrays.to_array ((
                                Build ("delete_posts",           "edit_theme_options"),
                                Build ("delete_post",            "edit_theme_options"),
                                Build ("delete_published_posts", "edit_theme_options"),
                                Build ("delete_private_posts",   "edit_theme_options"),
                                Build ("delete_others_posts",    "edit_theme_options"),
                                Build ("edit_post",              "edit_css"),
                                Build ("edit_posts",             "edit_css"),
                                Build ("edit_others_posts",      "edit_css"),
                                Build ("edit_published_posts",   "edit_css"),
                                Build ("read_post",              "read"),
                                Build ("read_private_posts",     "read"),
                                Build ("publish_posts",          "edit_theme_options")
                        )),

                        -- Added
                        Map_Meta_Cap           => False,
                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  => Empty_Array,
--                        Supports             => Empty_List,
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
                        Rest_Base            => Null_Unbounded_String,
                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
--                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "customize_changeset",
                Args_Type'(
                        labels           => Arrays.to_array ((
                                Build ("name",               x_x ("Changesets", "post type general name")),
                                Build ("singular_name",      x_x ("Changeset", "post type singular name")),
                                Build ("add_new",            x_x ("Add New", "Customize Changeset")),
                                Build ("add_new_item",       abs "Add New Changeset"),
                                Build ("new_item",           abs "New Changeset"),
                                Build ("edit_item",          abs "Edit Changeset"),
                                Build ("view_item",          abs "View Changeset"),
                                Build ("all_items",          abs "All Changesets"),
                                Build ("search_items",       abs "Search Changesets"),
                                Build ("not_found",          abs "No changesets found."),
                                Build ("not_found_in_trash", abs "No changesets found in Trash.")
                        )),
                        public           => False,
                        x_builtin        => True, -- internal use only. don"t use this when registering your own post type.--
                        map_meta_cap     => True,
                        hierarchical     => False,
                        rewrite          => Empty_Rewrite,
                        query_var        => Null_Unbounded_String,
                        can_export       => False,
                        delete_with_user => False,
                        supports         => To_List ((+"title", +"author")),
                        Capability_Type_String => +"customize_changeset",
                        Capability_Type_Array  => Empty_Array,
                        capabilities     => Arrays.to_array ((
                                Build ("create_posts",           "customize"),
                                Build ("delete_others_posts",    "customize"),
                                Build ("delete_post",            "customize"),
                                Build ("delete_posts",           "customize"),
                                Build ("delete_private_posts",   "customize"),
                                Build ("delete_published_posts", "customize"),
                                Build ("edit_others_posts",      "customize"),
                                Build ("edit_post",              "customize"),
                                Build ("edit_posts",             "customize"),
                                Build ("edit_private_posts",     "customize"),
                                Build ("edit_published_posts",   "do_not_allow"),
                                Build ("publish_posts",          "customize"),
                                Build ("read",                   "read"),
                                Build ("read_post",              "customize"),
                                Build ("read_private_posts",     "customize")
                        )),

                        -- Added
--                        Map_Meta_Cap           => False,
--                        Capability_Type_String => Null_Unbounded_String,
--                        Capability_Type_Array  => Empty_Array,
--                        Supports             => Empty_List,
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
                        Rest_Base            => Null_Unbounded_String,
                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
--                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "oembed_cache",
                Args_Type'(
                        labels           => Arrays.to_array ((
                                Build ("name",          abs "oEmbed Responses"),
                                Build ("singular_name", abs "oEmbed Response")
                        )),
                        public           => False,
                        hierarchical     => False,
                        rewrite          => Empty_Rewrite,
                        query_var        => Null_Unbounded_String,
                        delete_with_user => False,
                        can_export       => False,
                        x_builtin        => True, -- internal use only. don"t use this when registering your own post type.--
                        supports         => Empty_List,

                        -- Added
                        Map_Meta_Cap           => False,
                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  => Empty_Array,
                        Capabilities         => Empty_Array,
--                        Supports             => Empty_List,
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
                        Rest_Base            => Null_Unbounded_String,
                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
--                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "user_request",
                Args_Type'(
                        labels           => Arrays.to_array ((
                                Build ("name",          abs "User Requests"),
                                Build ("singular_name", abs "User Request")
                        )),
                        public           => False,
                        x_builtin        => True, -- internal use only. don"t use this when registering your own post type.--
                        hierarchical     => False,
                        rewrite          => Empty_Rewrite,
                        query_var        => Null_Unbounded_String,
                        can_export       => False,
                        delete_with_user => False,
                        supports         => Empty_List,

                        -- Added
                        Map_Meta_Cap           => False,
                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  => Empty_Array,
                        Capabilities         => Empty_Array,
--                        Supports             => Empty_List,
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
                        Rest_Base            => Null_Unbounded_String,
                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
--                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "wp_block",
                Args_Type'(
                        labels                => Arrays.to_array ((
                                Build ("name",                     x_x ("Reusable blocks", "post type general name")),
                                Build ("singular_name",            x_x ("Reusable block", "post type singular name")),
                                Build ("add_new",                  x_x ("Add New", "Reusable block")),
                                Build ("add_new_item",             abs "Add new Reusable block"),
                                Build ("new_item",                 abs "New Reusable block"),
                                Build ("edit_item",                abs "Edit Reusable block"),
                                Build ("view_item",                abs "View Reusable block"),
                                Build ("all_items",                abs "All Reusable blocks"),
                                Build ("search_items",             abs "Search Reusable blocks"),
                                Build ("not_found",                abs "No reusable blocks found."),
                                Build ("not_found_in_trash",       abs "No reusable blocks found in Trash."),
                                Build ("filter_items_list",        abs "Filter reusable blocks list"),
                                Build ("items_list_navigation",    abs "Reusable blocks list navigation"),
                                Build ("items_list",               abs "Reusable blocks list"),
                                Build ("item_published",           abs "Reusable block published."),
                                Build ("item_published_privately", abs "Reusable block published privately."),
                                Build ("item_reverted_to_draft",   abs "Reusable block reverted to draft."),
                                Build ("item_scheduled",           abs "Reusable block scheduled."),
                                Build ("item_updated",             abs "Reusable block updated.")
                        )),
                        public                => False,
                        x_builtin             => True, -- internal use only. don"t use this when registering your own post type.--
                        show_ui               => True,
                        show_in_menu          => Null_Unbounded_String,
                        rewrite               => Empty_Rewrite,
                        show_in_rest          => True,
                        rest_base              => +"blocks",
                        rest_controller_class  => +"WP_REST_Blocks_Controller",
                        Capability_Type_String => +"block",
                        capabilities           => Arrays.to_array ((
                                -- You need to be able to edit posts, in order to read blocks in their raw form.
                                Build ("read",                   "edit_posts"),
                                -- You need to be able to publish posts, in order to create blocks.
                                Build ("create_posts",           "publish_posts"),
                                Build ("edit_posts",             "edit_posts"),
                                Build ("edit_published_posts",   "edit_published_posts"),
                                Build ("delete_published_posts", "delete_published_posts"),
                                Build ("edit_others_posts",      "edit_others_posts"),
                                Build ("delete_others_posts",    "delete_others_posts")
                        )),
                        map_meta_cap          => True,
                        supports              => To_List ((
                                +"title",
                                +"editor",
                                +"revisions"
                        )),

                        -- Added
                        Hierarchical           => False,
                        Query_Var              => Null_Unbounded_String,
--                        Map_Meta_Cap           => False,
--                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  => Empty_Array,
--                        Capabilities         => Empty_Array,
--                        Supports             => Empty_List,
                        Label                => Null_Unbounded_String,
                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
--                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
--                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
--                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
--                        Rest_Base            => Null_Unbounded_String,
--                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
                        Delete_With_User     => False,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "wp_template",
                Args_Type'(
                        labels                => Arrays.to_array ((
                                Build ("name",                  x_x ("Templates", "post type general name")),
                                Build ("singular_name",         x_x ("Template", "post type singular name")),
                                Build ("add_new",               x_x ("Add New", "Template")),
                                Build ("add_new_item",          abs "Add New Template"),
                                Build ("new_item",              abs "New Template"),
                                Build ("edit_item",             abs "Edit Template"),
                                Build ("view_item",             abs "View Template"),
                                Build ("all_items",             abs "Templates"),
                                Build ("search_items",          abs "Search Templates"),
                                Build ("parent_item_colon",     abs "Parent Template:"),
                                Build ("not_found",             abs "No templates found."),
                                Build ("not_found_in_trash",    abs "No templates found in Trash."),
                                Build ("archives",              abs "Template archives"),
                                Build ("insert_into_item",      abs "Insert into template"),
                                Build ("uploaded_to_this_item", abs "Uploaded to this template"),
                                Build ("filter_items_list",     abs "Filter templates list"),
                                Build ("items_list_navigation", abs "Templates list navigation"),
                                Build ("items_list",            abs "Templates list")
                        )),
                        description           => +abs "Templates to include in your theme.",
                        public                => False,
                        x_builtin             => True, -- internal use only. don"t use this when registering your own post type.--
                        has_archive           => Null_Unbounded_String,
                        show_ui               => False,
                        show_in_menu          => Null_Unbounded_String,
                        show_in_rest          => True,
                        rewrite               => Empty_Rewrite,
                        rest_base             => +"templates",
                        rest_controller_class => +"WP_REST_Templates_Controller",
                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  => Arrays.to_array ((1 =>  Build ("template", "templates"))),
                        capabilities          => Arrays.to_array ((
                                Build ("create_posts",           "edit_theme_options"),
                                Build ("delete_posts",           "edit_theme_options"),
                                Build ("delete_others_posts",    "edit_theme_options"),
                                Build ("delete_private_posts",   "edit_theme_options"),
                                Build ("delete_published_posts", "edit_theme_options"),
                                Build ("edit_posts",             "edit_theme_options"),
                                Build ("edit_others_posts",      "edit_theme_options"),
                                Build ("edit_private_posts",     "edit_theme_options"),
                                Build ("edit_published_posts",   "edit_theme_options"),
                                Build ("publish_posts",          "edit_theme_options"),
                                Build ("read",                   "edit_theme_options"),
                                Build ("read_private_posts",     "edit_theme_options")
                        )),
                        map_meta_cap          => True,
                        supports              => to_list ((
                                +"title",
                                +"slug",
                                +"excerpt",
                                +"editor",
                                +"revisions",
                                +"author"
                        )),

                        -- Added
                        Hierarchical           => False,
                        Query_Var              => Null_Unbounded_String,
--                        Map_Meta_Cap           => False,
--                        Capability_Type_String => Null_Unbounded_String,
--                        Capability_Type_Array  => Empty_Array,
--                        Capabilities         => Empty_Array,
--                        Supports             => Empty_List,
                        Label                => Null_Unbounded_String,
--                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
--                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
--                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
--                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
--                        Rest_Base            => Null_Unbounded_String,
--                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
--                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
                        Delete_With_User     => False,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "wp_template_part",
                Args_Type'(
                        labels                => Arrays.to_array ((
                                Build ("name",                  x_x ("Template Parts", "post type general name")),
                                Build ("singular_name",         x_x ("Template Part", "post type singular name")),
                                Build ("add_new",               x_x ("Add New", "Template Part")),
                                Build ("add_new_item",          abs "Add New Template Part"),
                                Build ("new_item",              abs "New Template Part"),
                                Build ("edit_item",             abs "Edit Template Part"),
                                Build ("view_item",             abs "View Template Part"),
                                Build ("all_items",             abs "Template Parts"),
                                Build ("search_items",          abs "Search Template Parts"),
                                Build ("parent_item_colon",     abs "Parent Template Part:"),
                                Build ("not_found",             abs "No template parts found."),
                                Build ("not_found_in_trash",    abs "No template parts found in Trash."),
                                Build ("archives",              abs "Template part archives"),
                                Build ("insert_into_item",      abs "Insert into template part"),
                                Build ("uploaded_to_this_item", abs "Uploaded to this template part"),
                                Build ("filter_items_list",     abs "Filter template parts list"),
                                Build ("items_list_navigation", abs "Template parts list navigation"),
                                Build ("items_list",            abs "Template parts list")
                        )),
                        description           => +abs "Template parts to include in your templates.",
                        public                => False,
                        x_builtin             => True, -- internal use only. don"t use this when registering your own post type.--
                        has_archive           => Null_Unbounded_String,
                        show_ui               => False,
                        show_in_menu          => Null_Unbounded_String,
                        show_in_rest          => True,
                        rewrite               => Empty_Rewrite,
                        rest_base             => +"template-parts",
                        rest_controller_class => +"WP_REST_Templates_Controller",
                        map_meta_cap          => True,
                        capabilities          => Arrays.to_array ((
                                Build ("create_posts",           "edit_theme_options"),
                                Build ("delete_posts",           "edit_theme_options"),
                                Build ("delete_others_posts",    "edit_theme_options"),
                                Build ("delete_private_posts",   "edit_theme_options"),
                                Build ("delete_published_posts", "edit_theme_options"),
                                Build ("edit_posts",             "edit_theme_options"),
                                Build ("edit_others_posts",      "edit_theme_options"),
                                Build ("edit_private_posts",     "edit_theme_options"),
                                Build ("edit_published_posts",   "edit_theme_options"),
                                Build ("publish_posts",          "edit_theme_options"),
                                Build ("read",                   "edit_theme_options"),
                                Build ("read_private_posts",     "edit_theme_options")
                        )),
                        supports              => To_List ((
                                +"title",
                                +"slug",
                                +"excerpt",
                                +"editor",
                                +"revisions",
                                +"author"
                        )),

                        -- Added
                        Hierarchical           => False,
                        Query_Var              => Null_Unbounded_String,
--                        Map_Meta_Cap           => False,
                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  => Empty_Array,
--                        Capabilities         => Empty_Array,
--                        Supports             => Empty_List,
                        Label                => Null_Unbounded_String,
--                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
--                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
--                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
--                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
--                        Rest_Base            => Null_Unbounded_String,
--                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
--                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
                        Delete_With_User     => False,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "wp_global_styles",
                Args_Type'(
                        label        => +x_x ("Global Styles", "post type general name"),
                        description  => +abs "Global styles to include in themes.",
                        public       => False,
                        x_builtin    => True, -- internal use only. don't use this when registering your own post type.
                        show_ui      => False,
                        show_in_rest => False,
                        rewrite      => Empty_Rewrite,
                        capabilities => Arrays.to_array ((
                                Build ("read",                   "edit_theme_options"),
                                Build ("create_posts",           "edit_theme_options"),
                                Build ("edit_posts",             "edit_theme_options"),
                                Build ("edit_published_posts",   "edit_theme_options"),
                                Build ("delete_published_posts", "edit_theme_options"),
                                Build ("edit_others_posts",      "edit_theme_options"),
                                Build ("delete_others_posts",    "edit_theme_options")
                        )),
                        map_meta_cap => True,
                        supports     => To_List ((
                                +"title",
                                +"editor",
                                +"revisions"
                        )),

                        -- Added
                        Labels                 => Empty_Array,
                        Hierarchical           => False,
                        Query_Var              => Null_Unbounded_String,
--                        Map_Meta_Cap           => False,
                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  => Empty_Array,
--                        Capabilities         => Empty_Array,
--                        Supports             => Empty_List,
--                        Label                => Null_Unbounded_String,
--                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => True,
                        Publicly_Queryable   => False,
--                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
                        Show_In_Admin_Bar    => False,
--                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
                        Rest_Base            => Null_Unbounded_String,
                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
                        Delete_With_User     => False,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Type (
                "wp_navigation",
                Args_Type'(
                        labels                => Arrays.to_array ((
                                Build ("name",                  x_x ("Navigation Menus", "post type general name")),
                                Build ("singular_name",         x_x ("Navigation Menu", "post type singular name")),
                                Build ("add_new",               x_x ("Add New", "Navigation Menu")),
                                Build ("add_new_item",          abs "Add New Navigation Menu"),
                                Build ("new_item",              abs "New Navigation Menu"),
                                Build ("edit_item",             abs "Edit Navigation Menu"),
                                Build ("view_item",             abs "View Navigation Menu"),
                                Build ("all_items",             abs "Navigation Menus"),
                                Build ("search_items",          abs "Search Navigation Menus"),
                                Build ("parent_item_colon",     abs "Parent Navigation Menu:"),
                                Build ("not_found",             abs "No Navigation Menu found."),
                                Build ("not_found_in_trash",    abs "No Navigation Menu found in Trash."),
                                Build ("archives",              abs "Navigation Menu archives"),
                                Build ("insert_into_item",      abs "Insert into Navigation Menu"),
                                Build ("uploaded_to_this_item", abs "Uploaded to this Navigation Menu"),
                                Build ("filter_items_list",     abs "Filter Navigation Menu list"),
                                Build ("items_list_navigation", abs "Navigation Menus list navigation"),
                                Build ("items_list",            abs "Navigation Menus list")
                        )),
                        description           => +abs "Navigation menus that can be inserted into your site.",
                        public                => False,
                        x_builtin             => True, -- internal use only. don't use this when registering your own post type.
                        has_archive           => Null_Unbounded_String,
                        show_ui               => True,
                        show_in_menu          => Null_Unbounded_String,
                        show_in_admin_bar     => False,
                        show_in_rest          => True,
                        rewrite               => Empty_Rewrite,
                        map_meta_cap          => True,
                        capabilities          => Arrays.to_array ((
                                Build ("edit_others_posts",      "edit_theme_options"),
                                Build ("delete_posts",           "edit_theme_options"),
                                Build ("publish_posts",          "edit_theme_options"),
                                Build ("create_posts",           "edit_theme_options"),
                                Build ("read_private_posts",     "edit_theme_options"),
                                Build ("delete_private_posts",   "edit_theme_options"),
                                Build ("delete_published_posts", "edit_theme_options"),
                                Build ("delete_others_posts",    "edit_theme_options"),
                                Build ("edit_private_posts",     "edit_theme_options"),
                                Build ("edit_published_posts",   "edit_theme_options"),
                                Build ("edit_posts",             "edit_theme_options")
                        )),
                        rest_base             => +"navigation",
                        rest_controller_class => +"WP_REST_Posts_Controller",
                        supports              => to_list ((
                                +"title",
                                +"editor",
                                +"revisions"
                        )),

                        -- Added
--                        Internal               => False,
--                        Protect                => False,
--                        Privat                 => False,
--                        Publicly_Queryable     => False,
                        Label                  => Null_Unbounded_String,
--                        Labels                 => Empty_Array,
                        Hierarchical           => False,
                        Query_Var              => Null_Unbounded_String,
--                        Map_Meta_Cap           => False,
                        Capability_Type_String => Null_Unbounded_String,
                        Capability_Type_Array  => Empty_Array,
--                        Capabilities         => Empty_Array,
--                        Supports             => Empty_List,
--                        Label                => Null_Unbounded_String,
--                        Description          => Null_Unbounded_String,
                        Exclude_From_Search  => False,
                        Publicly_Queryable   => False,
--                        Show_Ui              => False,
                        Show_In_Menu_Bool    => False,
--                        Show_In_Menu         => Null_Unbounded_String,
                        Show_In_Nav_Menus    => False,
--                        Show_In_Admin_Bar    => False,
--                        Show_In_Admin_All_List => False,
--                        Show_In_Admin_Status_List => False,
--                        Date_Floating             => False,
--                        Show_In_Rest         => False,
                        Rest_Namespace       => Null_Unbounded_String,
--                        Rest_Base            => Null_Unbounded_String,
--                        Rest_Controller_Class => Null_Unbounded_String,
                        Menu_Icon            => Null_Unbounded_String,
--                        Capabilities         => Empty_String_Array,
                        Register_Meta_Box_Cb => Null_Callable,
                        Taxonomies           => Empty_String_Array,
                        Has_Archive_Bool     => False,
--                        Has_Archive          => Null_Unbounded_String,
                        Rewrite_Bool         => False,
                        Query_Var_Bool       => False,
                        Delete_With_User     => False,
                        Can_Export           => False,
                        Template             => Empty_Array,
                        Template_Lock_Bool   => False,
                        Template_Lock        => Null_Unbounded_String,
                        Menu_Position        => 0,
--                        Capability_Type      => Null_Unbounded_String
                        X_Edit_Link          => Null_Unbounded_String
                )
        );

        Register_Post_Status (
                "publish",
                Status_Type'(
                        label       => +x_x ("Published", "post status"),
                        public      => True,
                        x_builtin   => True, -- internal use only.
                        -- translators: %s: Number of published posts.
                        label_count => X_N_Noop (
                                "Published <span class=""count"">(%s)</span>",
                                "Published <span class=""count"">(%s)</span>"
                        ),

                        -- Added
                        Exclude_From_Search       => False,
                        Internal                  => False,
                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "future",
                Status_Type'(
                        label       => +x_x ("Scheduled", "post status"),
                        Protect     => True,
                        x_builtin   => True, -- internal use only.
                        -- translators: %s: Number of scheduled posts.
                        label_count => X_N_Noop (
                                "Scheduled <span class=""count"">(%s)</span>",
                                "Scheduled <span class=""count"">(%s)</span>"
                        ),

                        -- Added
                        Exclude_From_Search       => False,
                        Internal                  => False,
                        Public                    => False,
--                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "draft",
                Status_Type'(
                        label         => +x_x ("Draft", "post status"),
                        Protect       => True,
                        x_builtin     => True, -- internal use only.
                        -- translators: %s: Number of draft posts.
                        label_count   => X_N_Noop (
                                "Draft <span class=""count"">(%s)</span>",
                                "Drafts <span class=""count"">(%s)</span>"
                        ),
                        date_floating => True,

                        -- Added
                        Exclude_From_Search       => False,
                        Internal                  => False,
                        Public                    => False,
--                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False
--                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "pending",
                Status_Type'(
                        label         => +x_x ("Pending", "post status"),
                        Protect       => True,
                        x_builtin     => True, -- internal use only.
                        -- translators: %s: Number of pending posts.
                        label_count   => X_N_Noop (
                                "Pending <span class=""count"">(%s)</span>",
                                "Pending <span class=""count"">(%s)</span>"
                        ),
                        date_floating => True,

                        -- Added
                        Exclude_From_Search       => False,
                        Internal                  => False,
                        Public                    => False,
--                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False
--                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "private",
                Status_Type'(
                        label       => +x_x ("Private", "post status"),
                        Privat      => True,
                        x_builtin   => True, -- internal use only.
                        -- translators: %s: Number of private posts.
                        label_count => X_N_Noop (
                                "Private <span class=""count"">(%s)</span>",
                                "Private <span class=""count"">(%s)</span>"
                        ),

                        -- Added
                        Exclude_From_Search       => False,
                        Internal                  => False,
                        Public                    => False,
                        Protect                   => False,
--                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "trash",
                Status_Type'(
                        label                     => +x_x ("Trash", "post status"),
                        internal                  => True,
                        x_builtin                 => True, -- internal use only.
                        -- translators: %s: Number of trashed posts.
                        label_count               => X_N_Noop (
                                "Trash <span class=""count"">(%s)</span>",
                                "Trash <span class=""count"">(%s)</span>"
                        ),
                        show_in_admin_status_list => True,

                        -- Added
                        Exclude_From_Search       => False,
--                        Internal                  => False,
                        Public                    => False,
                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
--                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "auto-draft",
                Status_Type'(
                        label         => +"auto-draft",
                        internal      => True,
                        x_builtin     => True, -- internal use only.
                        date_floating => True,

                        -- Added
                        Label_Count               => Empty_Array,
                        Exclude_From_Search       => False,
--                        Internal                  => False,
                        Public                    => False,
                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False
--                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "inherit",
                Status_Type'(
                        label               => +"inherit",
                        internal            => True,
                        x_builtin           => True, -- internal use only.
                        exclude_from_search => False,

                        -- Added
                        Label_Count               => Empty_Array,
--                        Exclude_From_Search       => False,
--                        Internal                  => False,
                        Public                    => False,
                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "request-pending",
                Status_Type'(
                        label               => +x_x ("Pending", "request status"),
                        internal            => True,
                        x_builtin           => True, -- internal use only.
                        -- translators: %s: Number of pending requests.
                        label_count         => X_N_Noop (
                                "Pending <span class=""count"">(%s)</span>",
                                "Pending <span class=""count"">(%s)</span>"
                        ),
                        exclude_from_search => False,

                        -- Added
--                        Exclude_From_Search       => False,
--                        Internal                  => False,
                        Public                    => False,
                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "request-confirmed",
                Status_Type'(
                        label               => +x_x ("Confirmed", "request status"),
                        internal            => True,
                        x_builtin           => True, -- internal use only.
                        -- translators: %s: Number of confirmed requests.
                        label_count         => X_N_Noop (
                                "Confirmed <span class=""count"">(%s)</span>",
                                "Confirmed <span class=""count"">(%s)</span>"
                        ),
                        exclude_from_search => False,

                        -- Added
--                        Exclude_From_Search       => False,
--                        Internal                  => False,
                        Public                    => False,
                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "request-failed",
                Status_Type'(
                        label               => +x_x ("Failed", "request status"),
                        internal            => True,
                        x_builtin           => True, -- internal use only.
                        -- translators: %s: Number of failed requests.
                        label_count         => X_N_Noop (
                                "Failed <span class=""count"">(%s)</span>",
                                "Failed <span class=""count"">(%s)</span>"
                        ),
                        exclude_from_search => False,

                        -- Added
--                        Exclude_From_Search       => False,
--                        Internal                  => False,
                        Public                    => False,
                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );

        Register_Post_Status (
                "request-completed",
                Status_Type'(
                        label               => +x_x ("Completed", "request status"),
                        internal            => True,
                        x_builtin           => True, -- internal use only.
                        -- translators: %s: Number of completed requests.
                        label_count         => X_N_Noop (
                                "Completed <span class=""count"">(%s)</span>",
                                "Completed <span class=""count"">(%s)</span>"
                        ),
                        exclude_from_search => False,

                        -- Added
--                        Exclude_From_Search       => False,
--                        Internal                  => False,
                        Public                    => False,
                        Protect                   => False,
                        Privat                    => False,
                        Publicly_Queryable        => False,
                        Show_In_Admin_All_List    => False,
                        Show_In_Admin_Status_List => False,
                        Date_Floating             => False
                )
        );
   end Create_Initial_Post_Types;

--
-- Retrieves attached file path based on attachment ID.
--
-- By default the path will go through the "get_attached_file" filter, but
-- passing a True to the unfiltered argument of get_attached_file() will
-- return the file path unfiltered.
--
-- The function works by getting the single post meta name, named
-- "_wp_attached_file" and returning it. This is a convenience function to
-- prevent looking up the meta name and provide a mechanism for sending the
-- attached filename through a filter.
--
-- @since 2.0.0
--
-- @param int  attachment_id Attachment ID.
-- @param bool unfiltered    Optional. Whether to apply filters. Default False.
-- @return string|False The file path to where the attached file should be, False otherwise.
--
-- function get_attached_file( attachment_id, unfiltered = False ) then
--         file = get_post_meta( attachment_id, "_wp_attached_file", True );

--         // If the file is relative, prepend upload dir.
--         if ( file && 0 !== strpos( file, "/" ) && ! preg_match( "|^.:\\\|", file ) ) then
--                 uploads = wp_get_upload_dir();
--                 if ( False === uploads["error"] ) then
--                         file = uploads["basedir"] . "/file";
--                 end;
--         end;

--         if ( unfiltered ) then
--                 return file;
--         end;

--         --
--         -- Filters the attached file based on the given ID.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string|False file          The file path to where the attached file should be, False otherwise.
--         -- @param int          attachment_id Attachment ID.
--         --
--         return apply_filters( "get_attached_file", file, attachment_id );
-- end;

--
-- Updates attachment file path based on attachment ID.
--
-- Used to update the file path of the attachment, which uses post meta name
-- "_wp_attached_file" to store the path of the attachment.
--
-- @since 2.1.0
--
-- @param int    attachment_id Attachment ID.
-- @param string file          File path for the attachment.
-- @return bool True on success, False on failure.
--
-- function update_attached_file( attachment_id, file ) then
--         if ( ! get_post( attachment_id ) ) then
--                 return False;
--         end;

--         --
--         -- Filters the path to the attached file to update.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string file          Path to the attached file to update.
--         -- @param int    attachment_id Attachment ID.
--         --
--         file = apply_filters( "update_attached_file", file, attachment_id );

--         file = _wp_relative_upload_path( file );
--         if ( file ) then
--                 return update_post_meta( attachment_id, "_wp_attached_file", file );
--         end; else then
--                 return delete_post_meta( attachment_id, "_wp_attached_file" );
--         end;
-- end;

--
-- Returns relative path to an uploaded file.
--
-- The path is relative to the current upload dir.
--
-- @since 2.9.0
-- @access private
--
-- @param string path Full path to the file.
-- @return string Relative path on success, unchanged path on failure.
--
-- function _wp_relative_upload_path( path ) then
--         new_path = path;

--         uploads = wp_get_upload_dir();
--         if ( 0 === strpos( new_path, uploads["basedir"] ) ) then
--                         new_path = str_replace( uploads["basedir"], "", new_path );
--                         new_path = ltrim( new_path, "/" );
--         end;

--         --
--         -- Filters the relative path to an uploaded file.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string new_path Relative path to the file.
--         -- @param string path     Full path to the file.
--         --
--         return apply_filters( "_wp_relative_upload_path", new_path, path );
-- end;

--
-- Retrieves all children of the post parent ID.
--
-- Normally, without any enhancements, the children would apply to pages. In the
-- context of the inner workings of WordPress, pages, posts, and attachments
-- share the same table, so therefore the functionality could apply to any one
-- of them. It is then noted that while this function does not work on posts, it
-- does not mean that it won"t work on posts. It is recommended that you know
-- what context you wish to retrieve the children of.
--
-- Attachments may also be made the child of a post, so if that is an accurate
-- statement (which needs to be verified), it would then be possible to get
-- all of the attachments for a post. Attachments have since changed since
-- version 2.5, so this is most likely inaccurate, but serves generally as an
-- example of what is possible.
--
-- The arguments listed as defaults are for this function and also of the
-- get_posts() function. The arguments are combined with the get_children defaults
-- and are then passed to the get_posts() function, which accepts additional arguments.
-- You can replace the defaults in this function, listed below and the additional
-- arguments listed in the get_posts() function.
--
-- The "post_parent" is the most important argument and important attention
-- needs to be paid to the args parameter. If you pass either an object or an
-- integer (number), then just the "post_parent" is grabbed and everything else
-- is lost. If you don"t specify any arguments, then it is assumed that you are
-- in The Loop and the post parent will be grabbed for from the current post.
--
-- The "post_parent" argument is the ID to get the children. The "numberposts"
-- is the amount of posts to retrieve that has a default of "-1", which is
-- used to get all of the posts. Giving a number higher than 0 will only
-- retrieve that amount of posts.
--
-- The "post_type" and "post_status" arguments can be used to choose what
-- criteria of posts to retrieve. The "post_type" can be anything, but WordPress
-- post types are "post", "pages", and "attachments". The "post_status"
-- argument will accept any post status within the write administration panels.
--
-- @since 2.0.0
--
-- @see get_posts()
-- @todo Check validity of description.
--
-- @global WP_Post post Global post object.
--
-- @param mixed  args   Optional. User defined arguments for replacing the defaults. Default empty.
-- @param string output Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
--                       correspond to a WP_Post object, an associative array, or a numeric array,
--                       respectively. Default OBJECT.
-- @return WP_Post[]|array[]|int[] Array of post objects, arrays, or IDs, depending on `output`.
--
-- function get_children( args = "", output = OBJECT ) then
--         kids = to_array ();
--         if ( empty( args ) ) then
--                 if ( isset( GLOBALS["post"] ) ) then
--                         args = to_array ( "post_parent" => (int) GLOBALS["post"].post_parent );
--                 end; else then
--                         return kids;
--                 end;
--         end; elseif ( is_object( args ) ) then
--                 args = to_array ( "post_parent" => (int) args.post_parent );
--         end; elseif ( is_numeric( args ) ) then
--                 args = to_array ( "post_parent" => (int) args );
--         end;

--         defaults = to_array (
--                 "numberposts" => -1,
--                 "post_type"   => "any",
--                 "post_status" => "any",
--                 "post_parent" => 0,
--         );

--         parsed_args = wp_parse_args( args, defaults );

--         children = get_posts( parsed_args );

--         if ( ! children ) then
--                 return kids;
--         end;

--         if ( ! empty( parsed_args["fields"] ) ) then
--                 return children;
--         end;

--         update_post_cache( children );

--         foreach ( children as key => child ) then
--                 kids[ child.ID ] = children[ key ];
--         end;

--         if ( OBJECT === output ) then
--                 return kids;
--         end; elseif ( ARRAY_A === output ) then
--                 weeuns = to_array ();
--                 foreach ( (array) kids as kid ) then
--                         weeuns[ kid.ID ] = get_object_vars( kids[ kid.ID ] );
--                 end;
--                 return weeuns;
--         end; elseif ( ARRAY_N === output ) then
--                 babes = to_array ();
--                 foreach ( (array) kids as kid ) then
--                         babes[ kid.ID ] = array_values( get_object_vars( kids[ kid.ID ] ) );
--                 end;
--                 return babes;
--         end; else then
--                 return kids;
--         end;
-- end;

--
-- Gets extended entry info (<!--more-.).
--
-- There should not be any space after the second dash and before the word
-- "more". There can be text or space(s) after the word "more", but won"t be
-- referenced.
--
-- The returned array has "main", "extended", and "more_text" keys. Main has the text before
-- the `<!--more-.`. The "extended" key has the content after the
-- `<!--more-.` comment. The "more_text" key has the custom "Read More" text.
--
-- @since 1.0.0
--
-- @param string post Post content.
-- @return string[] then
--     Extended entry info.
--
--     @type string main      Content before the more tag.
--     @type string extended  Content after the more tag.
--     @type string more_text Custom read more text, or empty string.
-- end;
--
-- function get_extended( post ) then
--         // Match the new style more links.
--         if ( preg_match( "/<!--more(.*?)?-./", post, matches ) ) then
--                 list(main, extended) = explode( matches[0], post, 2 );
--                 more_text             = matches[1];
--         end; else then
--                 main      = post;
--                 extended  = "";
--                 more_text = "";
--         end;

--         // Leading and trailing whitespace.
--         main      = preg_replace( "/^[\s]*(.*)[\s]*/", "\\1", main );
--         extended  = preg_replace( "/^[\s]*(.*)[\s]*/", "\\1", extended );
--         more_text = preg_replace( "/^[\s]*(.*)[\s]*/", "\\1", more_text );

--         return to_array (
--                 "main"      => main,
--                 "extended"  => extended,
--                 "more_text" => more_text,
--         );
-- end;

   --------------
   -- Get_Post --
   --------------

   function Get_Post (Post   : Wp_Post; -- = null,
                      Output : String := "OBJECT"; --  = OBJECT,
                      Filter : String := "raw")
                      return Wp_Post
   is
       Post_2 : constant Wp_Post := Post;
       X_Post : Wp_Post;
       Unused_Success : Boolean;
   begin
      if
--         Empty (Post) and then
        Isset (String'(Get (Globals.GLOBALS, "post")))
      then
         null;
--          Post_2 := Get (GLOBALS, "post");
      end if;

      if Post in WP_Post then -- instanceof
         X_Post := Post_2;
      elsif Is_Object (Post_2) then
         if Post_2.Filter = "" then -- empty
            X_Post := Sanitize_Post (Post_2, "raw");
            X_Post := X_Construct (X_Post);  -- new Wp_Post (X_Post);
         elsif "raw" = Post_2.Filter then
            X_Post := X_Construct (Post_2);  -- new Wp_Post (Post_2);
         else
            Get_Instance (Post_2.Id, X_Post, Unused_Success); -- ::
         end if;
      else
         Get_Instance (Post.Id, X_Post, Unused_Success); -- :: .id added
      end if;

--      if not X_Post then
--         return null;
--      end if;

      X_Post := Inc_Class_Wp_Posts.Filter (X_Post, Filter);

      if "ARRAY_A" = Output then
         return X_Post; -- .To_Array; -- ();
      elsif "ARRAY_N" = Output then
         return X_Post; -- Array_Values (X_Post.To_Array); -- () );
      end if;

      return X_Post;
   end Get_Post;

   function Get_Post (Post   : Integer := 0;
                      Output : String := "OBJECT"; --  = OBJECT,
                      Filter : String := "raw")
                      return Wp_Post
   is
      P : Wp_Post;
   begin
      return P;
   end Get_Post;


--
-- Retrieves the IDs of the ancestors of a post.
--
-- @since 2.5.0
--
-- @param int|WP_Post post Post ID or post object.
-- @return int[] Array of ancestor IDs or empty array if there are none.
--
-- function get_post_ancestors( post ) then

   function Get_Post_Ancestors (Post : Inc_Class_Wp_Posts.Wp_Post)
                                return Array_Type  -- return Post_Id_List;
   is
        Post_2 : Inc_Class_Wp_Posts.Wp_Post := Get_Post (Post);
   begin
      if
--        not Post or else
        Post.Post_Parent = 0 or else -- empty
        Post.Post_Parent = Integer (Post.Id)
      then
         return Empty_Array;
      end if;

      declare
         use Array_Vectors;

         Ancestors : Array_Type := Empty_Array;

         Id        : Integer    := Post.Post_Parent;
--        Ancestors : Array_Type := Id;      -- []
         Ancestor  : Wp_Post;
      begin
         Arrays.Array_Vectors.Append (Ancestors, New_Item => (+Id'Image, +""));
         Ancestor := Inc_posts.Get_Post (Id);
         loop -- while Ancestor loop
            -- Loop detection: If the ancestor has been seen before, break.
            if
              Ancestor.Post_Parent /= 0                or else -- empty
              Ancestor.Post_Parent = Integer (Post.Id) or else
              In_Array (Ancestor.Post_Parent'Image, Ancestors, True)
            then
               exit;
            end if;

            Id := Ancestor.Post_Parent;
            Ancestors.Append (New_Item => (+Id'Image, +"")); -- []

            Ancestor := Get_Post (Id);
         end loop;

         return Ancestors;
      end;
   end Get_Post_Ancestors;

--
-- Retrieves data from a post field based on Post ID.
--
-- Examples of the post field will be, "post_type", "post_status", "post_content",
-- etc and based off of the post object property or key names.
--
-- The context values are based off of the taxonomy filter functions and
-- supported values are found within those functions.
--
-- @since 2.3.0
-- @since 4.5.0 The `post` parameter was made optional.
--
-- @see sanitize_post_field()
--
-- @param string      field   Post field name.
-- @param int|WP_Post post    Optional. Post ID or post object. Defaults to global post.
-- @param string      context Optional. How to filter the field. Accepts "raw", "edit", "db",
--                             or "display". Default "display".
-- @return string The value of the post field on success, empty string on failure.
--
-- function get_post_field( field, post = null, context = "display" ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return "";
--         end;

--         if ( ! isset( post.field ) ) then
--                 return "";
--         end;

--         return sanitize_post_field( field, post.field, post.ID, context );
-- end;

--
-- Retrieves the mime type of an attachment based on the ID.
--
-- This function can be used with any post type, but it makes more sense with
-- attachments.
--
-- @since 2.0.0
--
-- @param int|WP_Post post Optional. Post ID or post object. Defaults to global post.
-- @return string|False The mime type on success, False on failure.
--
-- function get_post_mime_type( post = null ) then
--         post = get_post( post );

--         if ( is_object( post ) ) then
--                 return post.post_mime_type;
--         end;

--         return False;
-- end;

--
-- Retrieves the post status based on the post ID.
--
-- If the post ID is of an attachment, then the parent post status will be given
-- instead.
--
-- @since 2.0.0
--
-- @param int|WP_Post post Optional. Post ID or post object. Defaults to global post.
-- @return string|False Post status on success, False on failure.
--
-- function get_post_status( post = null ) then
--         post = get_post( post );

--         if ( ! is_object( post ) ) then
--                 return False;
--         end;

--         post_status = post.post_status;

--         if (
--                 "attachment" === post.post_type &&
--                 "inherit" === post_status
--         ) then
--                 if (
--                         0 === post.post_parent ||
--                         ! get_post( post.post_parent ) ||
--                         post.ID === post.post_parent
--                 ) then
--                         // Unattached attachments with inherit status are assumed to be published.
--                         post_status = "publish";
--                 end; elseif ( "trash" === get_post_status( post.post_parent ) ) then
--                         // Get parent status prior to trashing.
--                         post_status = get_post_meta( post.post_parent, "_wp_trash_meta_status", True );

--                         if ( ! post_status ) then
--                                 // Assume publish as above.
--                                 post_status = "publish";
--                         end;
--                 end; else then
--                         post_status = get_post_status( post.post_parent );
--                 end;
--         end; elseif (
--                 "attachment" === post.post_type &&
--                 ! in_to_array ( post_status, to_array ( "private", "trash", "auto-draft" ), True )
--         ) then
--                 --
--                 -- Ensure uninherited attachments have a permitted status either "private", "trash", "auto-draft".
--                 -- This is to match the logic in wp_insert_post().
--                 --
--                 -- Note: "inherit" is excluded from this check as it is resolved to the parent post"s
--                 -- status in the logic block above.
--                 --
--                 post_status = "publish";
--         end;

--         --
--         -- Filters the post status.
--         --
--         -- @since 4.4.0
--         -- @since 5.7.0 The attachment post type is now passed through this filter.
--         --
--         -- @param string  post_status The post status.
--         -- @param WP_Post post        The post object.
--         --
--         return apply_filters( "get_post_status", post_status, post );
-- end;

--
-- Retrieves all of the WordPress supported post statuses.
--
-- Posts have a limited set of valid status values, this provides the
-- post_status values and descriptions.
--
-- @since 2.5.0
--
-- @return string[] Array of post status labels keyed by their status.
--
-- function get_post_statuses() then
--         status = to_array (
--                 "draft"   => abs( "Draft" ),
--                 "pending" => abs( "Pending Review" ),
--                 "private" => abs( "Private" ),
--                 "publish" => abs( "Published" ),
--         );

--         return status;
-- end;

--
-- Retrieves all of the WordPress support page statuses.
--
-- Pages have a limited set of valid status values, this provides the
-- post_status values and descriptions.
--
-- @since 2.5.0
--
-- @return string[] Array of page status labels keyed by their status.
--
-- function get_page_statuses() then
--         status = to_array (
--                 "draft"   => abs( "Draft" ),
--                 "private" => abs( "Private" ),
--                 "publish" => abs( "Published" ),
--         );

--         return status;
-- end;

--
-- Returns statuses for privacy requests.
--
-- @since 4.9.6
-- @access private
--
-- @return array
--
-- function _wp_privacy_statuses() then
--         return to_array (
--                 "request-pending"   => x_x ("Pending", "request status" ),      // Pending confirmation from user.
--                 "request-confirmed" => x_x ("Confirmed", "request status" ),    // User has confirmed the action.
--                 "request-failed"    => x_x ("Failed", "request status" ),       // User failed to confirm the action.
--                 "request-completed" => x_x ("Completed", "request status" ),    // Admin has handled the request.
--         );
-- end;

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
--     @type array|False label_count               Nooped plural text from _n_noop() to provide the singular
--                                                  and plural forms of the label for counts. Default False
--                                                  which means the `label` argument will be used for both
--                                                  the singular and plural forms of this label.
--     @type bool        exclude_from_search       Whether to exclude posts with this post status
--                                                  from search results. Default is value of internal.
--     @type bool        _builtin                  Whether the status is built-in. Core-use only.
--                                                  Default False.
--     @type bool        public                    Whether posts of this status should be shown
--                                                  in the front end of the site. Default False.
--     @type bool        internal                  Whether the status is for internal use only.
--                                                  Default False.
--     @type bool        protected                 Whether posts with this status should be protected.
--                                                  Default False.
--     @type bool        private                   Whether posts with this status should be private.
--                                                  Default False.
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
--                                                  Default to False.
-- }
-- @return object
--
   procedure Register_Post_Status (Post_Status : String;
                                   Args        : Status_Type)
   is
--         global wp_post_statuses;
        -- Args prefixed with an underscore are reserved for internal use.
        -- defaults = to_array (
        --         "label"                     => False,
        --         "label_count"               => False,
        --         "exclude_from_search"       => null,
        --         "_builtin"                  => False,
        --         "public"                    => null,
        --         "internal"                  => null,
        --         "protected"                 => null,
        --         "private"                   => null,
        --         "publicly_queryable"        => null,
        --         "show_in_admin_status_list" => null,
        --         "show_in_admin_all_list"    => null,
        --         "date_floating"             => null,
        -- );
   begin
--        if not Is_To_Array (Wp_Post_Statuses) then
--                Wp_Post_Statuses := Empty_Array);
--        end if;

--        args     = wp_parse_args( args, defaults );
--        args     = (object) args;

--        post_status = sanitize_key( post_status );
--        args.name  = post_status;

        -- -- Set various defaults.
        -- if ( null === args.public && null === args.internal && null === args.protected && null === args.private ) then
        --         args.internal = True;
        -- end;

        -- if ( null === args.public ) then
        --         args.public = False;
        -- end;

        -- if ( null === args.private ) then
        --         args.private = False;
        -- end;

        -- if ( null === args.protected ) then
        --         args.protected = False;
        -- end;

        -- if ( null === args.internal ) then
        --         args.internal = False;
        -- end;

        -- if ( null === args.publicly_queryable ) then
        --         args.publicly_queryable = args.public;
        -- end;

        -- if ( null === args.exclude_from_search ) then
        --         args.exclude_from_search = args.internal;
        -- end;

        -- if ( null === args.show_in_admin_all_list ) then
        --         args.show_in_admin_all_list = ! args.internal;
        -- end;

        -- if ( null === args.show_in_admin_status_list ) then
        --         args.show_in_admin_status_list = ! args.internal;
        -- end;

        -- if ( null === args.date_floating ) then
        --         args.date_floating = False;
        -- end;

        -- if ( False === args.label ) then
        --         args.label = post_status;
        -- end;

        -- if ( False === args.label_count ) then
        --         -- phpcs:ignore WordPress.WP.I18n.NonSingularStringLiteralSingle,WordPress.WP.I18n.NonSingularStringLiteralPlural
        --         args.label_count = _n_noop( args.label, args.label );
        -- end;

        Wp_Post_Statuses (Post_Status) := Args;

--        return args;
   end Register_Post_Status;

--
-- Retrieves a post status object by name.
--
-- @since 3.0.0
--
-- @global stdClass[] wp_post_statuses List of post statuses.
--
-- @see register_post_status()
--
-- @param string post_status The name of a registered post status.
-- @return stdClass|null A post status object.
--
-- function get_post_status_object( post_status ) then
--         global wp_post_statuses;

--         if ( empty( wp_post_statuses[ post_status ] ) ) then
--                 return null;
--         end;

--         return wp_post_statuses[ post_status ];
-- end;

--
-- Gets a list of post statuses.
--
-- @since 3.0.0
--
-- @global stdClass[] wp_post_statuses List of post statuses.
--
-- @see register_post_status()
--
-- @param array|string args     Optional. Array or string of post status arguments to compare against
--                               properties of the global `wp_post_statuses objects`. Default empty array.
-- @param string       output   Optional. The type of output to return, either "names" or "objects". Default "names".
-- @param string       operator Optional. The logical operation to perform. "or" means only one element
--                               from the array needs to match; "and" means all elements must match.
--                               Default "and".
-- @return string[]|stdClass[] A list of post status names or objects.
--
-- function get_post_stati( args = to_array (), output = "names", operator = "and" ) then
--         global wp_post_statuses;

--         field = ( "names" === output ) ? "name" : False;

--         return wp_filter_object_list( wp_post_statuses, args, operator, field );
-- end;

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
-- function is_post_type_hierarchical( post_type ) then
--         if ( ! post_type_exists( post_type ) ) then
--                 return False;
--         end;

--         post_type = get_post_type_object( post_type );
--         return post_type.hierarchical;
-- end;

--
-- Determines whether a post type is registered.
--
-- For more information on this and similar theme functions, check out
-- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 3.0.0
--
-- @see get_post_type_object()
--
-- @param string post_type Post type name.
-- @return bool Whether post type is registered.
--
-- function post_type_exists( post_type ) then
--         return (bool) get_post_type_object( post_type );
-- end;

--
-- Retrieves the post type of the current post or of a given post.
--
-- @since 2.1.0
--
-- @param int|WP_Post|null post Optional. Post ID or post object. Default is global post.
-- @return string|False          Post type on success, False on failure.
--
-- function get_post_type( post = null ) then
--         post = get_post( post );
--         if ( post ) then
--                 return post.post_type;
--         end;

--         return False;
-- end;

--
-- Retrieves a post type object by name.
--
-- @since 3.0.0
-- @since 4.6.0 Object returned is now an instance of `WP_Post_Type`.
--
-- @global array wp_post_types List of post types.
--
-- @see register_post_type()
--
-- @param string post_type The name of a registered post type.
-- @return WP_Post_Type|null WP_Post_Type object if it exists, null otherwise.
--
   function Get_Post_Type_Object (Post_Type : String)
                                  return Inc_Class_Wp_Post_Type.Wp_Post_Type
   is
--      use List_Vectors;
      use Post_Type_Maps;
--        global wp_post_types;
      P : Inc_Class_Wp_Post_Type.Wp_Post_Type;
   begin
      if
--        not Is_Scalar (Post_Type) or else
        Wp_Post_Types.Find (Post_Type) = No_Element  -- empty
      then
         null;
--         return null;
      end if;

      return P; -- Get (Wp_Post_Types, Post_Type);
   end Get_Post_Type_Object;

--
-- Gets a list of all registered post type objects.
--
-- @since 2.9.0
--
-- @global array wp_post_types List of post types.
--
-- @see register_post_type() for accepted arguments.
--
-- @param array|string args     Optional. An array of key => value arguments to match against
--                               the post type objects. Default empty array.
-- @param string       output   Optional. The type of output to return. Accepts post type "names"
--                               or "objects". Default "names".
-- @param string       operator Optional. The logical operation to perform. "or" means only one
--                               element from the array needs to match; "and" means all elements
--                               must match; "not" means no elements may match. Default "and".
-- @return string[]|WP_Post_Type[] An array of post type names or objects.
--
-- function get_post_types( args = to_array (), output = "names", operator = "and" ) then
--         global wp_post_types;

--         field = ( "names" === output ) ? "name" : False;

--         return wp_filter_object_list( wp_post_types, args, operator, field );
-- end;
   function Get_Post_Types (Args     : Array_Type := Empty_Array;
                            Output   : String     := "names";
                            Operator : String     := "and")
                            return Inc_Class_Wp_Post_Type.Wp_Post_Type_Array
   is
      P : Inc_Class_Wp_Post_Type.Wp_Post_Type_Array;
   begin
      return P;
   end Get_Post_Types;

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
--                                               Default False.
--     @type bool         hierarchical          Whether the post type is hierarchical (e.g. page). Default False.
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
--                                               must be True. If True, the post type is shown in its own top level
--                                               menu. If False, no menu is shown. If a string of an existing top
--                                               level menu ("tools.php" or "edit.php?post_type=page", for example), the
--                                               post type will be placed as a sub-menu of that.
--                                               Default is value of show_ui.
--     @type bool         show_in_nav_menus     Makes this post type available for selection in navigation menus.
--                                               Default is value of public.
--     @type bool         show_in_admin_bar     Makes this post type available via the admin bar. Default is value
--                                               of show_in_menu.
--     @type bool         show_in_rest          Whether to include the post type in the REST API. Set this to True
--                                               for the post type to be available in the block editor.
--     @type string       rest_base             To change the base URL of REST API route. Default is post_type.
--     @type string       rest_namespace        To change the namespace URL of REST API route. Default is wp/v2.
--     @type string       rest_controller_class REST API controller class name. Default is "WP_REST_Posts_Controller".
--     @type int          menu_position         The position in the menu order the post type should appear. To work,
--                                               show_in_menu must be True. Default null (at the bottom).
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
--                                               Default False.
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
--                                               rewrite is enabled. Default False.
--     @type bool|array   rewrite               {
--         Triggers the handling of rewrites for this post type. To prevent rewrite, set to False.
--         Defaults to True, using post_type as slug. To specify rewrite rules, an array can be
--         passed with any of these keys:
--
--         @type string slug       Customize the permastruct slug. Defaults to post_type key.
--         @type bool   with_front Whether the permastruct should be prepended with WP_Rewrite::front.
--                                  Default True.
--         @type bool   feeds      Whether the feed permastruct should be built for this post type.
--                                  Default is value of has_archive.
--         @type bool   pages      Whether the permastruct should provide for pagination. Default True.
--         @type int    ep_mask    Endpoint mask to assign. If not specified and permalink_epmask is set,
--                                  inherits from permalink_epmask. If not specified and permalink_epmask
--                                  is not set, defaults to EP_PERMALINK.
--     }
--     @type string|bool  query_var             Sets the query_var key for this post type. Defaults to post_type
--                                               key. If False, a post type cannot be loaded at
--                                               ?thenquery_varend;=thenpost_slugend;. If specified as a string, the query
--                                               ?thenquery_var_stringend;=thenpost_slugend; will be valid.
--     @type bool         can_export            Whether to allow this post type to be exported. Default True.
--     @type bool         delete_with_user      Whether to delete posts of this type when deleting a user.
--                                              -- If True, posts of this type belonging to the user will be moved
--                                                 to Trash when the user is deleted.
--                                              -- If False, posts of this type belonging to the user will--not*
--                                                 be trashed or deleted.
--                                              -- If not set (the default), posts are trashed if post type supports
--                                                 the "author" feature. Otherwise posts are not trashed or deleted.
--                                               Default null.
--     @type array        template              Array of blocks to use as the default initial state for an editor
--                                               session. Each item should be an array containing block name and
--                                               optional attributes. Default empty array.
--     @type string|False template_lock         Whether the block template should be locked if template is set.
--                                              -- If set to "all", the user is unable to insert new blocks,
--                                                 move existing blocks and delete blocks.
--                                              -- If set to "insert", the user is able to move existing blocks
--                                                 but is unable to insert new blocks and delete blocks.
--                                               Default False.
--     @type bool         _builtin              FOR INTERNAL USE ONLY! True if this post type is a native or
--                                               "built-in" post_type. Default False.
--     @type string       _edit_link            FOR INTERNAL USE ONLY! URL segment to use for edit link of
--                                               this post type. Default "post.php?post=%d".
-- }
-- @return WP_Post_Type|WP_Error The registered post type object on success,
--                               WP_Error object on failure.
--
-- function register_post_type( post_type, args = to_array () ) then

   procedure Register_Post_Type (Post_Type : String;
                                 Args      : Args_Type) -- Array_Type := Empty_Array)
--                                return Wp_Post_Type
   is
      use Inc_Class_Wp_Post_Type;
      use Inc_Formatting;

      function Construct (Post_Type : String;
                          Args      : Args_Type)
                          return Wp_Post_Type;

      function Construct (Post_Type : String;
                          Args      : Args_Type)
                          return Wp_Post_Type
      is
         This : Wp_Post_Type;
      begin
         This.Name := +Post_Type;
         return This;
      end Construct;

--         global wp_post_types;
   begin

--         if ( ! is_to_array ( wp_post_types ) ) then
--                 wp_post_types = to_array ();
--         end;

        -- Sanitize post type name.
      declare
         Post_Type_2 : String := Sanitize_Key (Post_Type);

--         if ( empty( post_type ) || strlen( post_type ) > 20 ) then
--                 _doing_it_wrong( absFUNCTIONabs, abs( "Post type names must be between 1 and 20 characters in length." ), "4.2.0" );
--                 return new WP_Error( "post_type_length_invalid", abs( "Post type names must be between 1 and 20 characters in length." ) );
--         end;

         Post_Type_Object : Wp_Post_Type := Construct (Post_Type, Args); -- new Wp_Post_Type (Post_Type, Args);
      begin
         Post_Type_Object.Add_Supports;
         Post_Type_Object.Add_Rewrite_Rules;
         Post_Type_Object.Register_Meta_Boxes;

         Wp_Post_Types.Include (Post_Type, New_Item => Post_Type_Object);

         Post_Type_Object.Add_Hooks;
         Post_Type_Object.Register_Taxonomies;

         --
         -- Fires after a post type is registered.
         --
         -- @since 3.3.0
         -- @since 4.6.0 Converted the `post_type` parameter to accept a `WP_Post_Type` object.
         --
         -- @param string       post_type        Post type.
         -- @param WP_Post_Type post_type_object Arguments used to register the post type.
         --
--         Do_Action ("registered_post_type", Post_Type_2, Post_Type_Object);

         --
         -- Fires after a specific post type is registered.
         --
         -- The dynamic portion of the filter name, `post_type`, refers to the post type key.
         --
         -- Possible hook names include:
         --
         --  - `registered_post_type_post`
         --  - `registered_post_type_page`
         --
         -- @since 6.0.0
         --
         -- @param string       post_type        Post type.
         -- @param WP_Post_Type post_type_object Arguments used to register the post type.
         --
--         Do_Action ("registered_post_type_{post_type}", Post_Type_2, Post_Type_Object);
      end;

--         return post_type_object;
   end Register_Post_Type;

--
-- Unregisters a post type.
--
-- Cannot be used to unregister built-in post types.
--
-- @since 4.5.0
--
-- @global array wp_post_types List of post types.
--
-- @param string post_type Post type to unregister.
-- @return True|WP_Error True on success, WP_Error on failure or if the post type doesn"t exist.
--
-- function unregister_post_type( post_type ) then
--         global wp_post_types;

--         if ( ! post_type_exists( post_type ) ) then
--                 return new WP_Error( "invalid_post_type", abs( "Invalid post type." ) );
--         end;

--         post_type_object = get_post_type_object( post_type );

--         // Do not allow unregistering internal post types.
--         if ( post_type_object._builtin ) then
--                 return new WP_Error( "invalid_post_type", abs( "Unregistering a built-in post type is not allowed" ) );
--         end;

--         post_type_object.remove_supports();
--         post_type_object.remove_rewrite_rules();
--         post_type_object.unregister_meta_boxes();
--         post_type_object.remove_hooks();
--         post_type_object.unregister_taxonomies();

--         unset( wp_post_types[ post_type ] );

--         --
--         -- Fires after a post type was unregistered.
--         --
--         -- @since 4.5.0
--         --
--         -- @param string post_type Post type key.
--         --
--         do_action( "unregistered_post_type", post_type );

--         return True;
-- end;

--
-- Builds an object with all post type capabilities out of a post type object
--
-- Post type capabilities use the "capability_type" argument as a base, if the
-- capability is not set in the "capabilities" argument array or if the
-- "capabilities" argument is not supplied.
--
-- The capability_type argument can optionally be registered as an array, with
-- the first value being singular and the second plural, e.g. to_array ("story, "stories")
-- Otherwise, an "s" will be added to the value for the plural form. After
-- registration, capability_type will always be a string of the singular value.
--
-- By default, eight keys are accepted as part of the capabilities array:
--
-- - edit_post, read_post, and delete_post are meta capabilities, which are then
--   generally mapped to corresponding primitive capabilities depending on the
--   context, which would be the post being edited/read/deleted and the user or
--   role being checked. Thus these capabilities would generally not be granted
--   directly to users or roles.
--
-- - edit_posts - Controls whether objects of this post type can be edited.
-- - edit_others_posts - Controls whether objects of this type owned by other users
--   can be edited. If the post type does not support an author, then this will
--   behave like edit_posts.
-- - delete_posts - Controls whether objects of this post type can be deleted.
-- - publish_posts - Controls publishing objects of this post type.
-- - read_private_posts - Controls whether private objects can be read.
--
-- These five primitive capabilities are checked in core in various locations.
-- There are also six other primitive capabilities which are not referenced
-- directly in core, except in map_meta_cap(), which takes the three aforementioned
-- meta capabilities and translates them into one or more primitive capabilities
-- that must then be checked against the user or role, depending on the context.
--
-- - read - Controls whether objects of this post type can be read.
-- - delete_private_posts - Controls whether private objects can be deleted.
-- - delete_published_posts - Controls whether published objects can be deleted.
-- - delete_others_posts - Controls whether objects owned by other users can be
--   can be deleted. If the post type does not support an author, then this will
--   behave like delete_posts.
-- - edit_private_posts - Controls whether private objects can be edited.
-- - edit_published_posts - Controls whether published objects can be edited.
--
-- These additional capabilities are only used in map_meta_cap(). Thus, they are
-- only assigned by default if the post type is registered with the "map_meta_cap"
-- argument set to True (default is False).
--
-- @since 3.0.0
-- @since 5.4.0 "delete_posts" is included in default capabilities.
--
-- @see register_post_type()
-- @see map_meta_cap()
--
-- @param object args Post type registration arguments.
-- @return object Object with all the capabilities as member variables.
--
-- function get_post_type_capabilities( args ) then
--         if ( ! is_to_array ( args.capability_type ) ) then
--                 args.capability_type = to_array ( args.capability_type, args.capability_type . "s" );
--         end;

--         // Singular base for meta capabilities, plural base for primitive capabilities.
--         list( singular_base, plural_base ) = args.capability_type;

--         default_capabilities = to_array (
--                 // Meta capabilities.
--                 "edit_post"          => "edit_" . singular_base,
--                 "read_post"          => "read_" . singular_base,
--                 "delete_post"        => "delete_" . singular_base,
--                 // Primitive capabilities used outside of map_meta_cap():
--                 "edit_posts"         => "edit_" . plural_base,
--                 "edit_others_posts"  => "edit_others_" . plural_base,
--                 "delete_posts"       => "delete_" . plural_base,
--                 "publish_posts"      => "publish_" . plural_base,
--                 "read_private_posts" => "read_private_" . plural_base,
--         );

--         // Primitive capabilities used within map_meta_cap():
--         if ( args.map_meta_cap ) then
--                 default_capabilities_for_mapping = to_array (
--                         "read"                   => "read",
--                         "delete_private_posts"   => "delete_private_" . plural_base,
--                         "delete_published_posts" => "delete_published_" . plural_base,
--                         "delete_others_posts"    => "delete_others_" . plural_base,
--                         "edit_private_posts"     => "edit_private_" . plural_base,
--                         "edit_published_posts"   => "edit_published_" . plural_base,
--                 );
--                 default_capabilities             = array_merge( default_capabilities, default_capabilities_for_mapping );
--         end;

--         capabilities = array_merge( default_capabilities, args.capabilities );

--         // Post creation capability simply maps to edit_posts by default:
--         if ( ! isset( capabilities["create_posts"] ) ) then
--                 capabilities["create_posts"] = capabilities["edit_posts"];
--         end;

--         // Remember meta capabilities for future reference.
--         if ( args.map_meta_cap ) then
--                 _post_type_meta_capabilities( capabilities );
--         end;

--         return (object) capabilities;
-- end;

--
-- Stores or returns a list of post type meta caps for map_meta_cap().
--
-- @since 3.1.0
-- @access private
--
-- @global array post_type_meta_caps Used to store meta capabilities.
--
-- @param string[] capabilities Post type meta capabilities.
--
-- function _post_type_meta_capabilities( capabilities = null ) then
--         global post_type_meta_caps;

--         foreach ( capabilities as core => custom ) then
--                 if ( in_to_array ( core, to_array ( "read_post", "delete_post", "edit_post" ), True ) ) then
--                         post_type_meta_caps[ custom ] = core;
--                 end;
--         end;
-- end;

--
-- Builds an object with all post type labels out of a post type object.
--
-- Accepted keys of the label array in the post type object:
--
-- - `name` - General name for the post type, usually plural. The same and overridden
--          by `post_type_object.label`. Default is "Posts" / "Pages".
-- - `singular_name` - Name for one object of this post type. Default is "Post" / "Page".
-- - `add_new` - Default is "Add New" for both hierarchical and non-hierarchical types.
--             When internationalizing this string, please use a then@link https://developer.wordpress.org/plugins/internationalization/how-to-internationalize-your-plugin/#disambiguation-by-context gettext contextend;
--             matching your post type. Example: `x_x ("Add New", "product", "textdomain" );`.
-- - `add_new_item` - Label for adding a new singular item. Default is "Add New Post" / "Add New Page".
-- - `edit_item` - Label for editing a singular item. Default is "Edit Post" / "Edit Page".
-- - `new_item` - Label for the new item page title. Default is "New Post" / "New Page".
-- - `view_item` - Label for viewing a singular item. Default is "View Post" / "View Page".
-- - `view_items` - Label for viewing post type archives. Default is "View Posts" / "View Pages".
-- - `search_items` - Label for searching plural items. Default is "Search Posts" / "Search Pages".
-- - `not_found` - Label used when no items are found. Default is "No posts found" / "No pages found".
-- - `not_found_in_trash` - Label used when no items are in the Trash. Default is "No posts found in Trash" /
--                        "No pages found in Trash".
-- - `parent_item_colon` - Label used to prefix parents of hierarchical items. Not used on non-hierarchical
--                       post types. Default is "Parent Page:".
-- - `all_items` - Label to signify all items in a submenu link. Default is "All Posts" / "All Pages".
-- - `archives` - Label for archives in nav menus. Default is "Post Archives" / "Page Archives".
-- - `attributes` - Label for the attributes meta box. Default is "Post Attributes" / "Page Attributes".
-- - `insert_into_item` - Label for the media frame button. Default is "Insert into post" / "Insert into page".
-- - `uploaded_to_this_item` - Label for the media frame filter. Default is "Uploaded to this post" /
--                           "Uploaded to this page".
-- - `featured_image` - Label for the featured image meta box title. Default is "Featured image".
-- - `set_featured_image` - Label for setting the featured image. Default is "Set featured image".
-- - `remove_featured_image` - Label for removing the featured image. Default is "Remove featured image".
-- - `use_featured_image` - Label in the media frame for using a featured image. Default is "Use as featured image".
-- - `menu_name` - Label for the menu name. Default is the same as `name`.
-- - `filter_items_list` - Label for the table views hidden heading. Default is "Filter posts list" /
--                       "Filter pages list".
-- - `filter_by_date` - Label for the date filter in list tables. Default is "Filter by date".
-- - `items_list_navigation` - Label for the table pagination hidden heading. Default is "Posts list navigation" /
--                           "Pages list navigation".
-- - `items_list` - Label for the table hidden heading. Default is "Posts list" / "Pages list".
-- - `item_published` - Label used when an item is published. Default is "Post published." / "Page published."
-- - `item_published_privately` - Label used when an item is published with private visibility.
--                              Default is "Post published privately." / "Page published privately."
-- - `item_reverted_to_draft` - Label used when an item is switched to a draft.
--                            Default is "Post reverted to draft." / "Page reverted to draft."
-- - `item_scheduled` - Label used when an item is scheduled for publishing. Default is "Post scheduled." /
--                    "Page scheduled."
-- - `item_updated` - Label used when an item is updated. Default is "Post updated." / "Page updated."
-- - `item_link` - Title for a navigation link block variation. Default is "Post Link" / "Page Link".
-- - `item_link_description` - Description for a navigation link block variation. Default is "A link to a post." /
--                             "A link to a page."
--
-- Above, the first default value is for non-hierarchical post types (like posts)
-- and the second one is for hierarchical post types (like pages).
--
-- Note: To set labels used in post type admin notices, see the then@see "post_updated_messages"end; filter.
--
-- @since 3.0.0
-- @since 4.3.0 Added the `featured_image`, `set_featured_image`, `remove_featured_image`,
--              and `use_featured_image` labels.
-- @since 4.4.0 Added the `archives`, `insert_into_item`, `uploaded_to_this_item`, `filter_items_list`,
--              `items_list_navigation`, and `items_list` labels.
-- @since 4.6.0 Converted the `post_type` parameter to accept a `WP_Post_Type` object.
-- @since 4.7.0 Added the `view_items` and `attributes` labels.
-- @since 5.0.0 Added the `item_published`, `item_published_privately`, `item_reverted_to_draft`,
--              `item_scheduled`, and `item_updated` labels.
-- @since 5.7.0 Added the `filter_by_date` label.
-- @since 5.8.0 Added the `item_link` and `item_link_description` labels.
--
-- @access private
--
-- @param object|WP_Post_Type post_type_object Post type object.
-- @return object Object with all the labels as member variables.
--
-- function get_post_type_labels( post_type_object ) then
--         nohier_vs_hier_defaults = WP_Post_Type::get_default_labels();

--         nohier_vs_hier_defaults["menu_name"] = nohier_vs_hier_defaults["name"];

--         labels = _get_custom_object_labels( post_type_object, nohier_vs_hier_defaults );

--         post_type = post_type_object.name;

--         default_labels = clone labels;

--         --
--         -- Filters the labels of a specific post type.
--         --
--         -- The dynamic portion of the hook name, `post_type`, refers to
--         -- the post type slug.
--         --
--         -- Possible hook names include:
--         --
--         --  - `post_type_labels_post`
--         --  - `post_type_labels_page`
--         --  - `post_type_labels_attachment`
--         --
--         -- @since 3.5.0
--         --
--         -- @see get_post_type_labels() for the full list of labels.
--         --
--         -- @param object labels Object with labels for the post type as member variables.
--         --
--         labels = apply_filters( "post_type_labels_thenpost_typeend;", labels );

--         // Ensure that the filtered labels contain all required default values.
--         labels = (object) array_merge( (array) default_labels, (array) labels );

--         return labels;
-- end;

--
-- Builds an object with custom-something object (post type, taxonomy) labels
-- out of a custom-something object
--
-- @since 3.0.0
-- @access private
--
-- @param object object                  A custom-something object.
-- @param array  nohier_vs_hier_defaults Hierarchical vs non-hierarchical default labels.
-- @return object Object containing labels for the given custom-something object.
--
-- function _get_custom_object_labels( object, nohier_vs_hier_defaults ) then
--         object.labels = (array) object.labels;

--         if ( isset( object.label ) && empty( object.labels["name"] ) ) then
--                 object.labels["name"] = object.label;
--         end;

--         if ( ! isset( object.labels["singular_name"] ) && isset( object.labels["name"] ) ) then
--                 object.labels["singular_name"] = object.labels["name"];
--         end;

--         if ( ! isset( object.labels["name_admin_bar"] ) ) then
--                 object.labels["name_admin_bar"] = isset( object.labels["singular_name"] ) ? object.labels["singular_name"] : object.name;
--         end;

--         if ( ! isset( object.labels["menu_name"] ) && isset( object.labels["name"] ) ) then
--                 object.labels["menu_name"] = object.labels["name"];
--         end;

--         if ( ! isset( object.labels["all_items"] ) && isset( object.labels["menu_name"] ) ) then
--                 object.labels["all_items"] = object.labels["menu_name"];
--         end;

--         if ( ! isset( object.labels["archives"] ) && isset( object.labels["all_items"] ) ) then
--                 object.labels["archives"] = object.labels["all_items"];
--         end;

--         defaults = to_array ();
--         foreach ( nohier_vs_hier_defaults as key => value ) then
--                 defaults[ key ] = object.hierarchical ? value[1] : value[0];
--         end;
--         labels         = array_merge( defaults, object.labels );
--         object.labels = (object) object.labels;

--         return (object) labels;
-- end;

--
-- Adds submenus for post types.
--
-- @access private
-- @since 3.1.0
--
-- function _add_post_type_submenus() then
--         foreach ( get_post_types( to_array ( "show_ui" => True ) ) as ptype ) then
--                 ptype_obj = get_post_type_object( ptype );
--                 // Sub-menus only.
--                 if ( ! ptype_obj.show_in_menu || True === ptype_obj.show_in_menu ) then
--                         continue;
--                 end;
--                 add_submenu_page( ptype_obj.show_in_menu, ptype_obj.labels.name, ptype_obj.labels.all_items, ptype_obj.cap.edit_posts, "edit.php?post_type=ptype" );
--         end;
-- end;

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
-- @param mixed        ...args   Optional extra arguments to pass along with certain features.
--
   procedure Add_Post_Type_Support (Post_Type : String;
                                    Feature   : String) is null;
--                                  ...args ) then
--         global _wp_post_type_features;

--         features = (array) feature;
--         foreach ( features as feature ) then
--                 if ( args ) then
--                         _wp_post_type_features[ post_type ][ feature ] = args;
--                 end; else then
--                         _wp_post_type_features[ post_type ][ feature ] = True;
--                 end;
--         end;
-- end;

--
-- Removes support for a feature from a post type.
--
-- @since 3.0.0
--
-- @global array _wp_post_type_features
--
-- @param string post_type The post type for which to remove the feature.
-- @param string feature   The feature being removed.
--
-- function remove_post_type_support( post_type, feature ) then
--         global _wp_post_type_features;

--         unset( _wp_post_type_features[ post_type ][ feature ] );
-- end;

--
-- Gets all the post type features
--
-- @since 3.4.0
--
-- @global array _wp_post_type_features
--
-- @param string post_type The post type.
-- @return array Post type supports list.
--
-- function get_all_post_type_supports( post_type ) then
--         global _wp_post_type_features;

--         if ( isset( _wp_post_type_features[ post_type ] ) ) then
--                 return _wp_post_type_features[ post_type ];
--         end;

--         return to_array ();
-- end;

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
-- function post_type_supports( post_type, feature ) then
--         global _wp_post_type_features;

--         return ( isset( _wp_post_type_features[ post_type ][ feature ] ) );
-- end;

--
-- Retrieves a list of post type names that support a specific feature.
--
-- @since 4.5.0
--
-- @global array _wp_post_type_features Post type features
--
-- @param array|string feature  Single feature or an array of features the post types should support.
-- @param string       operator Optional. The logical operation to perform. "or" means
--                               only one element from the array needs to match; "and"
--                               means all elements must match; "not" means no elements may
--                               match. Default "and".
-- @return string[] A list of post type names.
--
-- function get_post_types_by_support( feature, operator = "and" ) then
--         global _wp_post_type_features;

--         features = array_fill_keys( (array) feature, True );

--         return array_keys( wp_filter_object_list( _wp_post_type_features, features, operator ) );
-- end;

--
-- Updates the post type for the post ID.
--
-- The page or post cache will be cleaned for the post ID.
--
-- @since 2.5.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int    post_id   Optional. Post ID to change post type. Default 0.
-- @param string post_type Optional. Post type. Accepts "post" or "page" to
--                          name a few. Default "post".
-- @return int|False Amount of rows changed. Should be 1 for success and 0 for failure.
--
-- function set_post_type( post_id = 0, post_type = "post" ) then
--         global wpdb;

--         post_type = sanitize_post_field( "post_type", post_type, post_id, "db" );
--         return    = wpdb.update( wpdb.posts, to_array ( "post_type" => post_type ), to_array ( "ID" => post_id ) );

--         clean_post_cache( post_id );

--         return return;
-- end;

--
-- Determines whether a post type is considered "viewable".
--
-- For built-in post types such as posts and pages, the "public" value will be evaluated.
-- For all others, the "publicly_queryable" value will be used.
--
-- @since 4.4.0
-- @since 4.5.0 Added the ability to pass a post type name in addition to object.
-- @since 4.6.0 Converted the `post_type` parameter to accept a `WP_Post_Type` object.
-- @since 5.9.0 Added `is_post_type_viewable` hook to filter the result.
--
-- @param string|WP_Post_Type post_type Post type name or object.
-- @return bool Whether the post type should be considered viewable.
--
-- function is_post_type_viewable( post_type ) then
--         if ( is_scalar( post_type ) ) then
--                 post_type = get_post_type_object( post_type );

--                 if ( ! post_type ) then
--                         return False;
--                 end;
--         end;

--         if ( ! is_object( post_type ) ) then
--                 return False;
--         end;

--         is_viewable = post_type.publicly_queryable || ( post_type._builtin && post_type.public );

--         --
--         -- Filters whether a post type is considered "viewable".
--         --
--         -- The returned filtered value must be a boolean type to ensure
--         -- `is_post_type_viewable()` only returns a boolean. This strictness
--         -- is by design to maintain backwards-compatibility and guard against
--         -- potential type errors in PHP 8.1+. Non-boolean values (even Falsey
--         -- and truthy values) will result in the function returning False.
--         --
--         -- @since 5.9.0
--         --
--         -- @param bool         is_viewable Whether the post type is "viewable" (strict type).
--         -- @param WP_Post_Type post_type   Post type object.
--         --
--         return True === apply_filters( "is_post_type_viewable", is_viewable, post_type );
-- end;

--
-- Determines whether a post status is considered "viewable".
--
-- For built-in post statuses such as publish and private, the "public" value will be evaluated.
-- For all others, the "publicly_queryable" value will be used.
--
-- @since 5.7.0
-- @since 5.9.0 Added `is_post_status_viewable` hook to filter the result.
--
-- @param string|stdClass post_status Post status name or object.
-- @return bool Whether the post status should be considered viewable.
--
-- function is_post_status_viewable( post_status ) then
--         if ( is_scalar( post_status ) ) then
--                 post_status = get_post_status_object( post_status );

--                 if ( ! post_status ) then
--                         return False;
--                 end;
--         end;

--         if (
--                 ! is_object( post_status ) ||
--                 post_status.internal ||
--                 post_status.protected
--         ) then
--                 return False;
--         end;

--         is_viewable = post_status.publicly_queryable || ( post_status._builtin && post_status.public );

--         --
--         -- Filters whether a post status is considered "viewable".
--         --
--         -- The returned filtered value must be a boolean type to ensure
--         -- `is_post_status_viewable()` only returns a boolean. This strictness
--         -- is by design to maintain backwards-compatibility and guard against
--         -- potential type errors in PHP 8.1+. Non-boolean values (even Falsey
--         -- and truthy values) will result in the function returning False.
--         --
--         -- @since 5.9.0
--         --
--         -- @param bool     is_viewable Whether the post status is "viewable" (strict type).
--         -- @param stdClass post_status Post status object.
--         --
--         return True === apply_filters( "is_post_status_viewable", is_viewable, post_status );
-- end;

--
-- Determines whether a post is publicly viewable.
--
-- Posts are considered publicly viewable if both the post status and post type
-- are viewable.
--
-- @since 5.7.0
--
-- @param int|WP_Post|null post Optional. Post ID or post object. Defaults to global post.
-- @return bool Whether the post is publicly viewable.
--
-- function is_post_publicly_viewable( post = null ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return False;
--         end;

--         post_type   = get_post_type( post );
--         post_status = get_post_status( post );

--         return is_post_type_viewable( post_type ) && is_post_status_viewable( post_status );
-- end;

--
-- Retrieves an array of the latest posts, or posts matching the given criteria.
--
-- For more information on the accepted arguments, see the
-- then@link https://developer.wordpress.org/reference/classes/wp_query/
-- WP_Queryend; documentation in the Developer Handbook.
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
-- @param array args then
--     Optional. Arguments to retrieve posts. See WP_Query::parse_query() for all available arguments.
--
--     @type int        numberposts      Total number of posts to retrieve. Is an alias of `posts_per_page`
--                                        in WP_Query. Accepts -1 for all. Default 5.
--     @type int|string category         Category ID or comma-separated list of IDs (this or any children).
--                                        Is an alias of `cat` in WP_Query. Default 0.
--     @type int[]      include          An array of post IDs to retrieve, sticky posts will be included.
--                                        Is an alias of `postabsin` in WP_Query. Default empty array.
--     @type int[]      exclude          An array of post IDs not to retrieve. Default empty array.
--     @type bool       suppress_filters Whether to suppress filters. Default True.
-- end;
-- @return WP_Post[]|int[] Array of post objects or post IDs.
--
-- function get_posts( args = null ) then
--         defaults = to_array (
--                 "numberposts"      => 5,
--                 "category"         => 0,
--                 "orderby"          => "date",
--                 "order"            => "DESC",
--                 "include"          => to_array (),
--                 "exclude"          => to_array (),
--                 "meta_key"         => "",
--                 "meta_value"       => "",
--                 "post_type"        => "post",
--                 "suppress_filters" => True,
--         );

--         parsed_args = wp_parse_args( args, defaults );
--         if ( empty( parsed_args["post_status"] ) ) then
--                 parsed_args["post_status"] = ( "attachment" === parsed_args["post_type"] ) ? "inherit" : "publish";
--         end;
--         if ( ! empty( parsed_args["numberposts"] ) && empty( parsed_args["posts_per_page"] ) ) then
--                 parsed_args["posts_per_page"] = parsed_args["numberposts"];
--         end;
--         if ( ! empty( parsed_args["category"] ) ) then
--                 parsed_args["cat"] = parsed_args["category"];
--         end;
--         if ( ! empty( parsed_args["include"] ) ) then
--                 incposts                      = wp_parse_id_list( parsed_args["include"] );
--                 parsed_args["posts_per_page"] = count( incposts );  // Only the number of posts included.
--                 parsed_args["postabsin"]       = incposts;
--         end; elseif ( ! empty( parsed_args["exclude"] ) ) then
--                 parsed_args["postabsnot_in"] = wp_parse_id_list( parsed_args["exclude"] );
--         end;

--         parsed_args["ignore_sticky_posts"] = True;
--         parsed_args["no_found_rows"]       = True;

--         get_posts = new WP_Query;
--         return get_posts.query( parsed_args );

-- end;

--
-- Post meta functions.
--

--
-- Adds a meta field to the given post.
--
-- Post meta data is called "Custom Fields" on the Administration Screen.
--
-- @since 1.5.0
--
-- @param int    post_id    Post ID.
-- @param string meta_key   Metadata name.
-- @param mixed  meta_value Metadata value. Must be serializable if non-scalar.
-- @param bool   unique     Optional. Whether the same key should not be added.
--                           Default False.
-- @return int|False Meta ID on success, False on failure.
--
-- function add_post_meta( post_id, meta_key, meta_value, unique = False ) then
--         // Make sure meta is added to the post, not a revision.
--         the_post = wp_is_post_revision( post_id );
--         if ( the_post ) then
--                 post_id = the_post;
--         end;

--         return add_metadata( "post", post_id, meta_key, meta_value, unique );
-- end;

--
-- Deletes a post meta field for the given post ID.
--
-- You can match based on the key, or key and value. Removing based on key and
-- value, will keep from removing duplicate metadata with the same key. It also
-- allows removing all metadata matching the key, if needed.
--
-- @since 1.5.0
--
-- @param int    post_id    Post ID.
-- @param string meta_key   Metadata name.
-- @param mixed  meta_value Optional. Metadata value. If provided,
--                           rows will only be removed that match the value.
--                           Must be serializable if non-scalar. Default empty.
-- @return bool True on success, False on failure.
--
-- function delete_post_meta( post_id, meta_key, meta_value = "" ) then
--         // Make sure meta is deleted from the post, not from a revision.
--         the_post = wp_is_post_revision( post_id );
--         if ( the_post ) then
--                 post_id = the_post;
--         end;

--         return delete_metadata( "post", post_id, meta_key, meta_value );
-- end;

--
-- Retrieves a post meta field for the given post ID.
--
-- @since 1.5.0
--
-- @param int    post_id Post ID.
-- @param string key     Optional. The meta key to retrieve. By default,
--                        returns data for all keys. Default empty.
-- @param bool   single  Optional. Whether to return a single value.
--                        This parameter has no effect if `key` is not specified.
--                        Default False.
-- @return mixed An array of values if `single` is False.
--               The value of the meta field if `single` is True.
--               False for an invalid `post_id` (non-numeric, zero, or negative value).
--               An empty string if a valid but non-existing post ID is passed.
--
--   function get_post_meta( post_id, key = "", single = False ) then

   function Get_Post_Meta (Post_Id : Inc_Class_Wp_Posts.Post_Id;
                           Key     : String  := "";
                           Single  : Boolean := False)
                           return Array_Type -- Post_Id_List;
   is
   begin
        return Inc_Meta.Get_Metadata ("post", Integer (Post_Id), Key, Single);
   end Get_Post_Meta;

--
-- Updates a post meta field based on the given post ID.
--
-- Use the `prev_value` parameter to differentiate between meta fields with the
-- same key and post ID.
--
-- If the meta field for the post does not exist, it will be added and its ID returned.
--
-- Can be used in place of add_post_meta().
--
-- @since 1.5.0
--
-- @param int    post_id    Post ID.
-- @param string meta_key   Metadata key.
-- @param mixed  meta_value Metadata value. Must be serializable if non-scalar.
-- @param mixed  prev_value Optional. Previous value to check before updating.
--                           If specified, only update existing metadata entries with
--                           this value. Otherwise, update all entries. Default empty.
-- @return int|bool Meta ID if the key didn"t exist, True on successful update,
--                  False on failure or if the value passed to the function
--                  is the same as the one that is already in the database.
--
-- function update_post_meta( post_id, meta_key, meta_value, prev_value = "" ) then
--         // Make sure meta is updated for the post, not for a revision.
--         the_post = wp_is_post_revision( post_id );
--         if ( the_post ) then
--                 post_id = the_post;
--         end;

--         return update_metadata( "post", post_id, meta_key, meta_value, prev_value );
-- end;

--
-- Deletes everything from post meta matching the given meta key.
--
-- @since 2.3.0
--
-- @param string post_meta_key Key to search for when deleting.
-- @return bool Whether the post meta key was deleted from the database.
--
-- function delete_post_meta_by_key( post_meta_key ) then
--         return delete_metadata( "post", null, post_meta_key, "", True );
-- end;

--
-- Registers a meta key for posts.
--
-- @since 4.9.8
--
-- @param string post_type Post type to register a meta key for. Pass an empty string
--                          to register the meta key across all existing post types.
-- @param string meta_key  The meta key to register.
-- @param array  args      Data used to describe the meta key when registered. See
--                          then@see register_meta()end; for a list of supported arguments.
-- @return bool True if the meta key was successfully registered, False if not.
--
-- function register_post_meta( post_type, meta_key, array args ) then
--         args["object_subtype"] = post_type;

--         return register_meta( "post", meta_key, args );
-- end;

--
-- Unregisters a meta key for posts.
--
-- @since 4.9.8
--
-- @param string post_type Post type the meta key is currently registered for. Pass
--                          an empty string if the meta key is registered across all
--                          existing post types.
-- @param string meta_key  The meta key to unregister.
-- @return bool True on success, False if the meta key was not previously registered.
--
-- function unregister_post_meta( post_type, meta_key ) then
--         return unregister_meta_key( "post", meta_key, post_type );
-- end;

--
-- Retrieves post meta fields, based on post ID.
--
-- The post meta fields are retrieved from the cache where possible,
-- so the function is optimized to be called more than once.
--
-- @since 1.2.0
--
-- @param int post_id Optional. Post ID. Default is the ID of the global `post`.
-- @return mixed An array of values.
--               False for an invalid `post_id` (non-numeric, zero, or negative value).
--               An empty string if a valid but non-existing post ID is passed.
--
-- function get_post_custom( post_id = 0 ) then
--         post_id = absint( post_id );

--         if ( ! post_id ) then
--                 post_id = get_the_ID();
--         end;

--         return get_post_meta( post_id );
-- end;

--
-- Retrieves meta field names for a post.
--
-- If there are no meta fields, then nothing (null) will be returned.
--
-- @since 1.2.0
--
-- @param int post_id Optional. Post ID. Default is the ID of the global `post`.
-- @return array|void Array of the keys, if retrieved.
--
-- function get_post_custom_keys( post_id = 0 ) then
--         custom = get_post_custom( post_id );

--         if ( ! is_to_array ( custom ) ) then
--                 return;
--         end;

--         keys = array_keys( custom );
--         if ( keys ) then
--                 return keys;
--         end;
-- end;

--
-- Retrieves values for a custom post field.
--
-- The parameters must not be considered optional. All of the post meta fields
-- will be retrieved and only the meta field key values returned.
--
-- @since 1.2.0
--
-- @param string key     Optional. Meta field key. Default empty.
-- @param int    post_id Optional. Post ID. Default is the ID of the global `post`.
-- @return array|null Meta field values.
--
-- function get_post_custom_values( key = "", post_id = 0 ) then
--         if ( ! key ) then
--                 return null;
--         end;

--         custom = get_post_custom( post_id );

--         return isset( custom[ key ] ) ? custom[ key ] : null;
-- end;

--
-- Determines whether a post is sticky.
--
-- Sticky posts should remain at the top of The Loop. If the post ID is not
-- given, then The Loop ID for the current post will be used.
--
-- For more information on this and similar theme functions, check out
-- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 2.7.0
--
-- @param int post_id Optional. Post ID. Default is the ID of the global `post`.
-- @return bool Whether post is sticky.
--
-- function is_sticky( post_id = 0 ) then
--         post_id = absint( post_id );

--         if ( ! post_id ) then
--                 post_id = get_the_ID();
--         end;

--         stickies = get_option( "sticky_posts" );

--         if ( is_to_array ( stickies ) ) then
--                 stickies  = array_map( "intval", stickies );
--                 is_sticky = in_to_array ( post_id, stickies, True );
--         end; else then
--                 is_sticky = False;
--         end;

--         --
--         -- Filters whether a post is sticky.
--         --
--         -- @since 5.3.0
--         --
--         -- @param bool is_sticky Whether a post is sticky.
--         -- @param int  post_id   Post ID.
--         --
--         return apply_filters( "is_sticky", is_sticky, post_id );
-- end;

--
-- Sanitizes every post field.
--
-- If the context is "raw", then the post object or array will get minimal
-- sanitization of the integer fields.
--
-- @since 2.3.0
--
-- @see sanitize_post_field()
--
-- @param object|WP_Post|array post    The post object or array
-- @param string               context Optional. How to sanitize post fields.
--                                      Accepts "raw", "edit", "db", "display",
--                                      "attribute", or "js". Default "display".
-- @return object|WP_Post|array The now sanitized post object or array (will be the
--                              same type as `post`).
--
-- function sanitize_post( post, context = "display" )

   function Sanitize_Post (Post    : Inc_Class_Wp_Posts.Wp_Post;
                           Context : String := "display")
                           return Inc_Class_Wp_Posts.Wp_Post
   is
      Post_2 : Inc_Class_Wp_Posts.Wp_Post := Post;
   begin
--      if Is_Object (Post_2) then
         -- Check if post already filtered for this context.
         if Post_2.Filter /= "" and then Context = Post_2.Filter then
            return Post_2;
         end if;
         if Post_2.Id = 0 then
            Post_2.ID := 0;
         end if;
         for Field of Array_Keys (Get_Object_Vars (Post_2)) loop
            -- field selecting jq
            Set (Post_2, -Field,
                 Sanitize_Post_Field (-Field, Get (Post_2, -Field),
                                      Post_2.ID, Context));
         end loop;
         Set (Post_2, "filter", Context);

      -- elsif Is_Array (Post_2) then
      --    -- Check if post already filtered for this context.
      --    if Post_2.Filter /= "" and then Context = Post_2.Filter then
      --       return Post_2;
      --    end if;
      --    if not Isset (Post_2 ("ID")) then
      --       Post_2 ("ID") := 0;
      --    end if;
      --    for Field of Array_Keys (Post) loop
      --       Set (Post_2, Field,
      --            Sanitize_Post_Field (-Field, Get (Post_2, Field),
      --                                 Post_2.ID, Context));
      --    end loop;
      --    Set (Post_2, "filter", Context);
      -- end if;
      return Post_2;
   end Sanitize_Post;

--
-- Sanitizes a post field based on context.
--
-- Possible context values are:  "raw", "edit", "db", "display", "attribute" and
-- "js". The "display" context is used by default. "attribute" and "js" contexts
-- are treated like "display" when calling filters.
--
-- @since 2.3.0
-- @since 4.4.0 Like `sanitize_post()`, `context` defaults to "display".
--
-- @param string field   The Post Object field name.
-- @param mixed  value   The Post Object value.
-- @param int    post_id Post ID.
-- @param string context Optional. How to sanitize the field. Possible values are "raw", "edit",
--                        "db", "display", "attribute" and "js". Default "display".
-- @return mixed Sanitized value.
--
-- function sanitize_post_field( field, value, post_id, context = "display" ) then

   function Sanitize_Post_Field (Field   : String;
                                 Value   : Array_Type; -- Inc_Class_Posts.Wp_Post;
                                 Post_Id : Inc_Class_Wp_Posts.Post_Id;
                                 Context : String := "display")
                                 return Array_Type
   is
      Int_Fields : List_Type  := To_List ((+"ID", +"post_parent", +"menu_order"));
      Value_2    : Array_Type := Value;
      pragma Unreferenced (Value);
      Array_Int_Fields : constant List_Type := To_List ((1 => +"ancestors"));
   begin
--      if In_Array (Field, Int_Fields, True) then
--         Value_2 := Integer (Value_2);
--      end if;

      -- Fields which contain arrays of integers.
      if In_Array (Field, Array_Int_Fields, True) then
         Value_2 := Array_Map ("absint", Value_2);
         return Value_2;
      end if;

      if "raw" = Context then
         return Value_2;
      end if;

      declare
         Prefixed        : Boolean    := False;
         Field_No_Prefix : Unbounded_String;
--         Value_2         : Array_Type := Value_2;
         Format_To_Edit  : List_Type;
      begin
         if 0 /= Strpos (Field, "post_") then -- False =
            Prefixed        := True;
            Field_No_Prefix := +Str_Replace ("post_", "", Field);
         end if;

         if "edit" = Context then
            Format_To_Edit := To_List ((+"post_content", +"post_excerpt",
                                        +"post_title",   +"post_password"));

            if Prefixed then

               --
                        -- Filters the value of a specific post field to edit.
                        --
                        -- The dynamic portion of the hook name, `field`, refers to the post
                        -- field name.
                        --
                        -- @since 2.3.0
                        --
                        -- @param mixed value   Value of the post field.
                        -- @param int   post_id Post ID.
                        --
                        Value_2 := Apply_Filters ("edit_" & Field, Value_2, Post_Id);

                        --
                        -- Filters the value of a specific post field to edit.
                        --
                        -- The dynamic portion of the hook name, `field_no_prefix`, refers to
                        -- the post field name.
                        --
                        -- @since 2.3.0
                        --
                        -- @param mixed value   Value of the post field.
                        -- @param int   post_id Post ID.
                        --
                        Value_2 := Apply_Filters (-Field_No_Prefix & "_edit_pre",
                                                  Value_2, Post_Id);
            else
                        Value_2 := Apply_Filters ("edit_post_" & Field,
                                                  Value_2, Post_Id);
            end if;

                -- if In_Array (Field, Format_To_Edit, True) then
                --         if "post_content" = Field then
                --                 Value_2 := Format_To_Edit (Value_2, User_Can_Richedit); -- ()
                --         else
                --                 Value_2 := Format_To_Edit (Value_2);
                --         end if;
                -- else
                --         Value_2 := Esc_Attr (Value_2);
                -- end if;
         elsif "db" = Context then
                if Prefixed then

                        --
                        -- Filters the value of a specific post field before saving.
                        --
                        -- The dynamic portion of the hook name, `field`, refers to the post
                        -- field name.
                        --
                        -- @since 2.3.0
                        --
                        -- @param mixed value Value of the post field.
                        --
                        Value_2 := Apply_Filters ("pre_" & Field, Value_2);

                        --
                        -- Filters the value of a specific field before saving.
                        --
                        -- The dynamic portion of the hook name, `field_no_prefix`, refers
                        -- to the post field name.
                        --
                        -- @since 2.3.0
                        --
                        -- @param mixed value Value of the post field.
                        --
                        Value_2 := Apply_Filters (-Field_No_Prefix & "_save_pre",
                                                  Value_2);
                else
                        Value_2 := Apply_Filters ("pre_post_" & Field, Value_2);

                        --
                        -- Filters the value of a specific post field before saving.
                        --
                        -- The dynamic portion of the hook name, `field`, refers to the post
                        -- field name.
                        --
                        -- @since 2.3.0
                        --
                        -- @param mixed value Value of the post field.
                        --
                        Value_2 := Apply_Filters (Field & "_pre", Value_2);
                end if;
         else
                -- Use display filters by default.
                if Prefixed then

                        --
                        -- Filters the value of a specific post field for display.
                        --
                        -- The dynamic portion of the hook name, `field`, refers to the post
                        -- field name.
                        --
                        -- @since 2.3.0
                        --
                        -- @param mixed  value   Value of the prefixed post field.
                        -- @param int    post_id Post ID.
                        -- @param string context Context for how to sanitize the field.
                        --                        Accepts "raw", "edit", "db", "display",
                        --                        "attribute", or "js". Default "display".
                        --
                        Value_2 := Apply_Filters (Field, Value_2, Post_Id'Image,
                                                  Context);
                else
                        Value_2 := Apply_Filters ("post_" & Field, Value_2,
                                                  Post_Id'Image, Context);
                end if;

                -- if "attribute" = Context then
                --         Value_2 := Esc_Attr (Value_2);
                -- elsif "js" = Context then
                --         Value_2 := Esc_Js (Value_2);
                -- end if;
         end if;

        -- Restore the type for integer fields after esc_attr().
--        if In_Array (Field, Int_Fields, True) then
--                Value_2 := Integer (Value_2);
--        end if;
      end;
      return Value_2;
   end Sanitize_Post_Field;

--
-- Makes a post sticky.
--
-- Sticky posts should be displayed at the top of the front page.
--
-- @since 2.7.0
--
-- @param int post_id Post ID.
--
-- function stick_post( post_id ) then
--         post_id  = (int) post_id;
--         stickies = get_option( "sticky_posts" );
--         updated  = False;

--         if ( ! is_to_array ( stickies ) ) then
--                 stickies = to_array ();
--         end; else then
--                 stickies = array_unique( array_map( "intval", stickies ) );
--         end;

--         if ( ! in_to_array ( post_id, stickies, True ) ) then
--                 stickies[] = post_id;
--                 updated    = update_option( "sticky_posts", array_values( stickies ) );
--         end;

--         if ( updated ) then
--                 --
--                 -- Fires once a post has been added to the sticky list.
--                 --
--                 -- @since 4.6.0
--                 --
--                 -- @param int post_id ID of the post that was stuck.
--                 --
--                 do_action( "post_stuck", post_id );
--         end;
-- end;

--
-- Un-sticks a post.
--
-- Sticky posts should be displayed at the top of the front page.
--
-- @since 2.7.0
--
-- @param int post_id Post ID.
--
-- function unstick_post( post_id ) then
--         post_id  = (int) post_id;
--         stickies = get_option( "sticky_posts" );

--         if ( ! is_to_array ( stickies ) ) then
--                 return;
--         end;

--         stickies = array_values( array_unique( array_map( "intval", stickies ) ) );

--         if ( ! in_to_array ( post_id, stickies, True ) ) then
--                 return;
--         end;

--         offset = array_search( post_id, stickies, True );
--         if ( False === offset ) then
--                 return;
--         end;

--         array_splice( stickies, offset, 1 );

--         updated = update_option( "sticky_posts", stickies );

--         if ( updated ) then
--                 --
--                 -- Fires once a post has been removed from the sticky list.
--                 --
--                 -- @since 4.6.0
--                 --
--                 -- @param int post_id ID of the post that was unstuck.
--                 --
--                 do_action( "post_unstuck", post_id );
--         end;
-- end;

--
-- Returns the cache key for wp_count_posts() based on the passed arguments.
--
-- @since 3.9.0
-- @access private
--
-- @param string type Optional. Post type to retrieve count Default "post".
-- @param string perm Optional. "readable" or empty. Default empty.
-- @return string The cache key.
--
-- function _count_posts_cache_key( type = "post", perm = "" ) then
--         cache_key = "posts-" . type;

--         if ( "readable" === perm && is_user_logged_in() ) then
--                 post_type_object = get_post_type_object( type );

--                 if ( post_type_object && ! current_user_can( post_type_object.cap.read_private_posts ) ) then
--                         cache_key .= "_" . perm . "_" . get_current_user_id();
--                 end;
--         end;

--         return cache_key;
-- end;

--
-- Counts number of posts of a post type and if user has permissions to view.
--
-- This function provides an efficient method of finding the amount of post"s
-- type a blog has. Another method is to count the amount of items in
-- get_posts(), but that method has a lot of overhead with doing so. Therefore,
-- when developing for 2.5+, use this function instead.
--
-- The perm parameter checks for "readable" value and if the user can read
-- private posts, it will display that for the user that is signed in.
--
-- @since 2.5.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string type Optional. Post type to retrieve count. Default "post".
-- @param string perm Optional. "readable" or empty. Default empty.
-- @return stdClass Number of posts for each status.
--
-- function wp_count_posts( type = "post", perm = "" ) then
--         global wpdb;

--         if ( ! post_type_exists( type ) ) then
--                 return new stdClass;
--         end;

--         cache_key = _count_posts_cache_key( type, perm );

--         counts = wp_cache_get( cache_key, "counts" );
--         if ( False !== counts ) then
--                 // We may have cached this before every status was registered.
--                 foreach ( get_post_stati() as status ) then
--                         if ( ! isset( counts.thenstatusend; ) ) then
--                                 counts.thenstatusend; = 0;
--                         end;
--                 end;

--                 -- This filter is documented in wp-includes/post.php--
--                 return apply_filters( "wp_count_posts", counts, type, perm );
--         end;

--         query = "SELECT post_status, COUNT(-- ) AS num_posts FROM thenwpdb.postsend; WHERE post_type = %s";

--         if ( "readable" === perm && is_user_logged_in() ) then
--                 post_type_object = get_post_type_object( type );
--                 if ( ! current_user_can( post_type_object.cap.read_private_posts ) ) then
--                         query .= wpdb.prepare(
--                                 " AND (post_status != "private" OR ( post_author = %d AND post_status = "private" ))",
--                                 get_current_user_id()
--                         );
--                 end;
--         end;

--         query .= " GROUP BY post_status";

--         results = (array) wpdb.get_results( wpdb.prepare( query, type ), ARRAY_A );
--         counts  = array_fill_keys( get_post_stati(), 0 );

--         foreach ( results as row ) then
--                 counts[ row["post_status"] ] = row["num_posts"];
--         end;

--         counts = (object) counts;
--         wp_cache_set( cache_key, counts, "counts" );

--         --
--         -- Modifies returned post counts by status for the current post type.
--         --
--         -- @since 3.7.0
--         --
--         -- @param stdClass counts An object containing the current post_type"s post
--         --                         counts by status.
--         -- @param string   type   Post type.
--         -- @param string   perm   The permission to determine if the posts are "readable"
--         --                         by the current user.
--         --
--         return apply_filters( "wp_count_posts", counts, type, perm );
-- end;

--
-- Counts number of attachments for the mime type(s).
--
-- If you set the optional mime_type parameter, then an array will still be
-- returned, but will only have the item you are looking for. It does not give
-- you the number of attachments that are children of a post. You can get that
-- by counting the number of children that post has.
--
-- @since 2.5.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string|string[] mime_type Optional. Array or comma-separated list of
--                                   MIME patterns. Default empty.
-- @return stdClass An object containing the attachment counts by mime type.
--
-- function wp_count_attachments( mime_type = "" ) then
--         global wpdb;

--         cache_key = sprintf(
--                 "attachments%s",
--                 ! empty( mime_type ) ? ":" . str_replace( "/", "_", implode( "-", (array) mime_type ) ) : ""
--         );

--         counts = wp_cache_get( cache_key, "counts" );
--         if ( False == counts ) then
--                 and   = wp_post_mime_type_where( mime_type );
--                 count = wpdb.get_results( "SELECT post_mime_type, COUNT(-- ) AS num_posts FROM wpdb.posts WHERE post_type = "attachment" AND post_status != "trash" and GROUP BY post_mime_type", ARRAY_A );

--                 counts = to_array ();
--                 foreach ( (array) count as row ) then
--                         counts[ row["post_mime_type"] ] = row["num_posts"];
--                 end;
--                 counts["trash"] = wpdb.get_var( "SELECT COUNT(-- ) FROM wpdb.posts WHERE post_type = "attachment" AND post_status = "trash" and" );

--                 wp_cache_set( cache_key, (object) counts, "counts" );
--         end;

--         --
--         -- Modifies returned attachment counts by mime type.
--         --
--         -- @since 3.7.0
--         --
--         -- @param stdClass        counts    An object containing the attachment counts by
--         --                                   mime type.
--         -- @param string|string[] mime_type Array or comma-separated list of MIME patterns.
--         --
--         return apply_filters( "wp_count_attachments", (object) counts, mime_type );
-- end;

--
-- Gets default post mime types.
--
-- @since 2.9.0
-- @since 5.3.0 Added the "Documents", "Spreadsheets", and "Archives" mime type groups.
--
-- @return array List of post mime types.
--
-- function get_post_mime_types() then
--         post_mime_types = to_array (   // to_array ( adj, noun )
--                 "image"       => to_array (
--                         abs( "Images" ),
--                         abs( "Manage Images" ),
--                         -- translators: %s: Number of images.--
--                         _n_noop(
--                                 "Image <span class="count">(%s)</span>",
--                                 "Images <span class="count">(%s)</span>"
--                         ),
--                 ),
--                 "audio"       => to_array (
--                         x_x ("Audio", "file type group" ),
--                         abs( "Manage Audio" ),
--                         -- translators: %s: Number of audio files.--
--                         _n_noop(
--                                 "Audio <span class="count">(%s)</span>",
--                                 "Audio <span class="count">(%s)</span>"
--                         ),
--                 ),
--                 "video"       => to_array (
--                         x_x ("Video", "file type group" ),
--                         abs( "Manage Video" ),
--                         -- translators: %s: Number of video files.--
--                         _n_noop(
--                                 "Video <span class="count">(%s)</span>",
--                                 "Video <span class="count">(%s)</span>"
--                         ),
--                 ),
--                 "document"    => to_array (
--                         abs( "Documents" ),
--                         abs( "Manage Documents" ),
--                         -- translators: %s: Number of documents.--
--                         _n_noop(
--                                 "Document <span class="count">(%s)</span>",
--                                 "Documents <span class="count">(%s)</span>"
--                         ),
--                 ),
--                 "spreadsheet" => to_array (
--                         abs( "Spreadsheets" ),
--                         abs( "Manage Spreadsheets" ),
--                         -- translators: %s: Number of spreadsheets.--
--                         _n_noop(
--                                 "Spreadsheet <span class="count">(%s)</span>",
--                                 "Spreadsheets <span class="count">(%s)</span>"
--                         ),
--                 ),
--                 "archive"     => to_array (
--                         x_x ("Archives", "file type group" ),
--                         abs( "Manage Archives" ),
--                         -- translators: %s: Number of archives.--
--                         _n_noop(
--                                 "Archive <span class="count">(%s)</span>",
--                                 "Archives <span class="count">(%s)</span>"
--                         ),
--                 ),
--         );

--         ext_types  = wp_get_ext_types();
--         mime_types = wp_get_mime_types();

--         foreach ( post_mime_types as group => labels ) then
--                 if ( in_to_array ( group, to_array ( "image", "audio", "video" ), True ) ) then
--                         continue;
--                 end;

--                 if ( ! isset( ext_types[ group ] ) ) then
--                         unset( post_mime_types[ group ] );
--                         continue;
--                 end;

--                 group_mime_types = to_array ();
--                 foreach ( ext_types[ group ] as extension ) then
--                         foreach ( mime_types as exts => mime ) then
--                                 if ( preg_match( "!^(" . exts . ")!i", extension ) ) then
--                                         group_mime_types[] = mime;
--                                         break;
--                                 end;
--                         end;
--                 end;
--                 group_mime_types = implode( ",", array_unique( group_mime_types ) );

--                 post_mime_types[ group_mime_types ] = labels;
--                 unset( post_mime_types[ group ] );
--         end;

--         --
--         -- Filters the default list of post mime types.
--         --
--         -- @since 2.5.0
--         --
--         -- @param array post_mime_types Default list of post mime types.
--         --
--         return apply_filters( "post_mime_types", post_mime_types );
-- end;

--
-- Checks a MIME-Type against a list.
--
-- If the `wildcard_mime_types` parameter is a string, it must be comma separated
-- list. If the `real_mime_types` is a string, it is also comma separated to
-- create the list.
--
-- @since 2.5.0
--
-- @param string|string[] wildcard_mime_types Mime types, e.g. `audio/mpeg`, `image` (same as `image--`),
--                                             or `flash` (same as `*flash*`).
-- @param string|string[] real_mime_types     Real post mime type values.
-- @return array to_array (wildcard=>to_array (real types)).
--
-- function wp_match_mime_types( wildcard_mime_types, real_mime_types ) then
--         matches = to_array ();
--         if ( is_string( wildcard_mime_types ) ) then
--                 wildcard_mime_types = array_map( "trim", explode( ",", wildcard_mime_types ) );
--         end;
--         if ( is_string( real_mime_types ) ) then
--                 real_mime_types = array_map( "trim", explode( ",", real_mime_types ) );
--         end;

--         patternses = to_array ();
--         wild       = "[-._a-z0-9]*";

--         foreach ( (array) wildcard_mime_types as type ) then
--                 mimes = array_map( "trim", explode( ",", type ) );
--                 foreach ( mimes as mime ) then
--                         regex = str_replace( "abswildcardabs", wild, preg_quote( str_replace( "*", "abswildcardabs", mime ) ) );

--                         patternses[][ type ] = "^regex";

--                         if ( False === strpos( mime, "/" ) ) then
--                                 patternses[][ type ] = "^regex/";
--                                 patternses[][ type ] = regex;
--                         end;
--                 end;
--         end;
--         asort( patternses );

--         foreach ( patternses as patterns ) then
--                 foreach ( patterns as type => pattern ) then
--                         foreach ( (array) real_mime_types as real ) then
--                                 if ( preg_match( "#pattern#", real )
--                                         && ( empty( matches[ type ] ) || False === array_search( real, matches[ type ], True ) )
--                                 ) then
--                                         matches[ type ][] = real;
--                                 end;
--                         end;
--                 end;
--         end;

--         return matches;
-- end;

--
-- Converts MIME types into SQL.
--
-- @since 2.5.0
--
-- @param string|string[] post_mime_types List of mime types or comma separated string
--                                         of mime types.
-- @param string          table_alias     Optional. Specify a table alias, if needed.
--                                         Default empty.
-- @return string The SQL AND clause for mime searching.
--
-- function wp_post_mime_type_where( post_mime_types, table_alias = "" ) then
--         where     = "";
--         wildcards = to_array ( "", "%", "%/%" );
--         if ( is_string( post_mime_types ) ) then
--                 post_mime_types = array_map( "trim", explode( ",", post_mime_types ) );
--         end;

--         wheres = to_array ();

--         foreach ( (array) post_mime_types as mime_type ) then
--                 mime_type = preg_replace( "/\s/", "", mime_type );
--                 slashpos  = strpos( mime_type, "/" );
--                 if ( False !== slashpos ) then
--                         mime_group    = preg_replace( "/[^-*.a-zA-Z0-9]/", "", substr( mime_type, 0, slashpos ) );
--                         mime_subgroup = preg_replace( "/[^-*.+a-zA-Z0-9]/", "", substr( mime_type, slashpos + 1 ) );
--                         if ( empty( mime_subgroup ) ) then
--                                 mime_subgroup = "*";
--                         end; else then
--                                 mime_subgroup = str_replace( "/", "", mime_subgroup );
--                         end;
--                         mime_pattern = "mime_group/mime_subgroup";
--                 end; else then
--                         mime_pattern = preg_replace( "/[^-*.a-zA-Z0-9]/", "", mime_type );
--                         if ( False === strpos( mime_pattern, "*" ) ) then
--                                 mime_pattern .= "--";
--                         end;
--                 end;

--                 mime_pattern = preg_replace( "/\*+/", "%", mime_pattern );

--                 if ( in_to_array ( mime_type, wildcards, True ) ) then
--                         return "";
--                 end;

--                 if ( False !== strpos( mime_pattern, "%" ) ) then
--                         wheres[] = empty( table_alias ) ? "post_mime_type LIKE "mime_pattern"" : "table_alias.post_mime_type LIKE "mime_pattern"";
--                 end; else then
--                         wheres[] = empty( table_alias ) ? "post_mime_type = "mime_pattern"" : "table_alias.post_mime_type = "mime_pattern"";
--                 end;
--         end;

--         if ( ! empty( wheres ) ) then
--                 where = " AND (" . implode( " OR ", wheres ) . ") ";
--         end;

--         return where;
-- end;

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
-- function wp_delete_post( postid = 0, force_delete = False ) then
--         global wpdb;

--         post = wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.posts WHERE ID = %d", postid ) );

--         if ( ! post ) then
--                 return post;
--         end;

--         post = get_post( post );

--         if ( ! force_delete && ( "post" === post.post_type || "page" === post.post_type ) && "trash" !== get_post_status( postid ) && EMPTY_TRASH_DAYS ) then
--                 return wp_trash_post( postid );
--         end;

--         if ( "attachment" === post.post_type ) then
--                 return wp_delete_attachment( postid, force_delete );
--         end;

--         --
--         -- Filters whether a post deletion should take place.
--         --
--         -- @since 4.4.0
--         --
--         -- @param WP_Post|False|null delete       Whether to go forward with deletion.
--         -- @param WP_Post            post         Post object.
--         -- @param bool               force_delete Whether to bypass the Trash.
--         --
--         check = apply_filters( "pre_delete_post", null, post, force_delete );
--         if ( null !== check ) then
--                 return check;
--         end;

--         --
--         -- Fires before a post is deleted, at the start of wp_delete_post().
--         --
--         -- @since 3.2.0
--         -- @since 5.5.0 Added the `post` parameter.
--         --
--         -- @see wp_delete_post()
--         --
--         -- @param int     postid Post ID.
--         -- @param WP_Post post   Post object.
--         --
--         do_action( "before_delete_post", postid, post );

--         delete_post_meta( postid, "_wp_trash_meta_status" );
--         delete_post_meta( postid, "_wp_trash_meta_time" );

--         wp_delete_object_term_relationships( postid, get_object_taxonomies( post.post_type ) );

--         parent_data  = to_array ( "post_parent" => post.post_parent );
--         parent_where = to_array ( "post_parent" => postid );

--         if ( is_post_type_hierarchical( post.post_type ) ) then
--                 // Point children of this page to its parent, also clean the cache of affected children.
--                 children_query = wpdb.prepare( "SELECT-- FROM wpdb.posts WHERE post_parent = %d AND post_type = %s", postid, post.post_type );
--                 children       = wpdb.get_results( children_query );
--                 if ( children ) then
--                         wpdb.update( wpdb.posts, parent_data, parent_where + to_array ( "post_type" => post.post_type ) );
--                 end;
--         end;

--         // Do raw query. wp_get_post_revisions() is filtered.
--         revision_ids = wpdb.get_col( wpdb.prepare( "SELECT ID FROM wpdb.posts WHERE post_parent = %d AND post_type = "revision"", postid ) );
--         // Use wp_delete_post (via wp_delete_post_revision) again. Ensures any meta/misplaced data gets cleaned up.
--         foreach ( revision_ids as revision_id ) then
--                 wp_delete_post_revision( revision_id );
--         end;

--         // Point all attachments to this post up one level.
--         wpdb.update( wpdb.posts, parent_data, parent_where + to_array ( "post_type" => "attachment" ) );

--         wp_defer_comment_counting( True );

--         comment_ids = wpdb.get_col( wpdb.prepare( "SELECT comment_ID FROM wpdb.comments WHERE comment_post_ID = %d ORDER BY comment_ID DESC", postid ) );
--         foreach ( comment_ids as comment_id ) then
--                 wp_delete_comment( comment_id, True );
--         end;

--         wp_defer_comment_counting( False );

--         post_meta_ids = wpdb.get_col( wpdb.prepare( "SELECT meta_id FROM wpdb.postmeta WHERE post_id = %d ", postid ) );
--         foreach ( post_meta_ids as mid ) then
--                 delete_metadata_by_mid( "post", mid );
--         end;

--         --
--         -- Fires immediately before a post is deleted from the database.
--         --
--         -- @since 1.2.0
--         -- @since 5.5.0 Added the `post` parameter.
--         --
--         -- @param int     postid Post ID.
--         -- @param WP_Post post   Post object.
--         --
--         do_action( "delete_post", postid, post );

--         result = wpdb.delete( wpdb.posts, to_array ( "ID" => postid ) );
--         if ( ! result ) then
--                 return False;
--         end;

--         --
--         -- Fires immediately after a post is deleted from the database.
--         --
--         -- @since 2.2.0
--         -- @since 5.5.0 Added the `post` parameter.
--         --
--         -- @param int     postid Post ID.
--         -- @param WP_Post post   Post object.
--         --
--         do_action( "deleted_post", postid, post );

--         clean_post_cache( post );

--         if ( is_post_type_hierarchical( post.post_type ) && children ) then
--                 foreach ( children as child ) then
--                         clean_post_cache( child );
--                 end;
--         end;

--         wp_clear_scheduled_hook( "publish_future_post", to_array ( postid ) );

--         --
--         -- Fires after a post is deleted, at the conclusion of wp_delete_post().
--         --
--         -- @since 3.2.0
--         -- @since 5.5.0 Added the `post` parameter.
--         --
--         -- @see wp_delete_post()
--         --
--         -- @param int     postid Post ID.
--         -- @param WP_Post post   Post object.
--         --
--         do_action( "after_delete_post", postid, post );

--         return post;
-- end;

--
-- Resets the page_on_front, show_on_front, and page_for_post settings when
-- a linked page is deleted or trashed.
--
-- Also ensures the post is no longer sticky.
--
-- @since 3.7.0
-- @access private
--
-- @param int post_id Post ID.
--
-- function _reset_front_page_settings_for_post( post_id ) then
--         post = get_post( post_id );

--         if ( "page" === post.post_type ) then
--                 --
--                 -- If the page is defined in option page_on_front or post_for_posts,
--                 -- adjust the corresponding options.
--                 --
--                 if ( get_option( "page_on_front" ) == post.ID ) then
--                         update_option( "show_on_front", "posts" );
--                         update_option( "page_on_front", 0 );
--                 end;
--                 if ( get_option( "page_for_posts" ) == post.ID ) then
--                         update_option( "page_for_posts", 0 );
--                 end;
--         end;

--         unstick_post( post.ID );
-- end;

--
-- Moves a post or page to the Trash
--
-- If Trash is disabled, the post or page is permanently deleted.
--
-- @since 2.9.0
--
-- @see wp_delete_post()
--
-- @param int post_id Optional. Post ID. Default is the ID of the global `post`
--                     if `EMPTY_TRASH_DAYS` equals True.
-- @return WP_Post|False|null Post data on success, False or null on failure.
--
-- function wp_trash_post( post_id = 0 ) then
--         if ( ! EMPTY_TRASH_DAYS ) then
--                 return wp_delete_post( post_id, True );
--         end;

--         post = get_post( post_id );

--         if ( ! post ) then
--                 return post;
--         end;

--         if ( "trash" === post.post_status ) then
--                 return False;
--         end;

--         --
--         -- Filters whether a post trashing should take place.
--         --
--         -- @since 4.9.0
--         --
--         -- @param bool|null trash Whether to go forward with trashing.
--         -- @param WP_Post   post  Post object.
--         --
--         check = apply_filters( "pre_trash_post", null, post );

--         if ( null !== check ) then
--                 return check;
--         end;

--         --
--         -- Fires before a post is sent to the Trash.
--         --
--         -- @since 3.3.0
--         --
--         -- @param int post_id Post ID.
--         --
--         do_action( "wp_trash_post", post_id );

--         add_post_meta( post_id, "_wp_trash_meta_status", post.post_status );
--         add_post_meta( post_id, "_wp_trash_meta_time", time() );

--         post_updated = wp_update_post(
--                 to_array (
--                         "ID"          => post_id,
--                         "post_status" => "trash",
--                 )
--         );

--         if ( ! post_updated ) then
--                 return False;
--         end;

--         wp_trash_post_comments( post_id );

--         --
--         -- Fires after a post is sent to the Trash.
--         --
--         -- @since 2.9.0
--         --
--         -- @param int post_id Post ID.
--         --
--         do_action( "trashed_post", post_id );

--         return post;
-- end;

--
-- Restores a post from the Trash.
--
-- @since 2.9.0
-- @since 5.6.0 An untrashed post is now returned to "draft" status by default, except for
--              attachments which are returned to their original "inherit" status.
--
-- @param int post_id Optional. Post ID. Default is the ID of the global `post`.
-- @return WP_Post|False|null Post data on success, False or null on failure.
--
   function Wp_Untrash_Post (Post_Id : Integer := 0)
                             return Wp_Post
   is
      P : Wp_Post;
   begin
      return P;
   end Wp_Untrash_Post;


-- function wp_untrash_post( post_id = 0 ) then
--         post = get_post( post_id );

--         if ( ! post ) then
--                 return post;
--         end;

--         post_id = post.ID;

--         if ( "trash" !== post.post_status ) then
--                 return False;
--         end;

--         previous_status = get_post_meta( post_id, "_wp_trash_meta_status", True );

--         --
--         -- Filters whether a post untrashing should take place.
--         --
--         -- @since 4.9.0
--         -- @since 5.6.0 The `previous_status` parameter was added.
--         --
--         -- @param bool|null untrash         Whether to go forward with untrashing.
--         -- @param WP_Post   post            Post object.
--         -- @param string    previous_status The status of the post at the point where it was trashed.
--         --
--         check = apply_filters( "pre_untrash_post", null, post, previous_status );
--         if ( null !== check ) then
--                 return check;
--         end;

--         --
--         -- Fires before a post is restored from the Trash.
--         --
--         -- @since 2.9.0
--         -- @since 5.6.0 The `previous_status` parameter was added.
--         --
--         -- @param int    post_id         Post ID.
--         -- @param string previous_status The status of the post at the point where it was trashed.
--         --
--         do_action( "untrash_post", post_id, previous_status );

--         new_status = ( "attachment" === post.post_type ) ? "inherit" : "draft";

--         --
--         -- Filters the status that a post gets assigned when it is restored from the trash (untrashed).
--         --
--         -- By default posts that are restored will be assigned a status of "draft". Return the value of `previous_status`
--         -- in order to assign the status that the post had before it was trashed. The `wp_untrash_post_set_previous_status()`
--         -- function is available for this.
--         --
--         -- Prior to WordPress 5.6.0, restored posts were always assigned their original status.
--         --
--         -- @since 5.6.0
--         --
--         -- @param string new_status      The new status of the post being restored.
--         -- @param int    post_id         The ID of the post being restored.
--         -- @param string previous_status The status of the post at the point where it was trashed.
--         --
--         post_status = apply_filters( "wp_untrash_post_status", new_status, post_id, previous_status );

--         delete_post_meta( post_id, "_wp_trash_meta_status" );
--         delete_post_meta( post_id, "_wp_trash_meta_time" );

--         post_updated = wp_update_post(
--                 to_array (
--                         "ID"          => post_id,
--                         "post_status" => post_status,
--                 )
--         );

--         if ( ! post_updated ) then
--                 return False;
--         end;

--         wp_untrash_post_comments( post_id );

--         --
--         -- Fires after a post is restored from the Trash.
--         --
--         -- @since 2.9.0
--         -- @since 5.6.0 The `previous_status` parameter was added.
--         --
--         -- @param int    post_id         Post ID.
--         -- @param string previous_status The status of the post at the point where it was trashed.
--         --
--         do_action( "untrashed_post", post_id, previous_status );

--         return post;
-- end;

--
-- Moves comments for a post to the Trash.
--
-- @since 2.9.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int|WP_Post|null post Optional. Post ID or post object. Defaults to global post.
-- @return mixed|void False on failure.
--
-- function wp_trash_post_comments( post = null ) then
--         global wpdb;

--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         post_id = post.ID;

--         --
--         -- Fires before comments are sent to the Trash.
--         --
--         -- @since 2.9.0
--         --
--         -- @param int post_id Post ID.
--         --
--         do_action( "trash_post_comments", post_id );

--         comments = wpdb.get_results( wpdb.prepare( "SELECT comment_ID, comment_approved FROM wpdb.comments WHERE comment_post_ID = %d", post_id ) );

--         if ( ! comments ) then
--                 return;
--         end;

--         // Cache current status for each comment.
--         statuses = to_array ();
--         foreach ( comments as comment ) then
--                 statuses[ comment.comment_ID ] = comment.comment_approved;
--         end;
--         add_post_meta( post_id, "_wp_trash_meta_comments_status", statuses );

--         // Set status for all comments to post-trashed.
--         result = wpdb.update( wpdb.comments, to_array ( "comment_approved" => "post-trashed" ), to_array ( "comment_post_ID" => post_id ) );

--         clean_comment_cache( array_keys( statuses ) );

--         --
--         -- Fires after comments are sent to the Trash.
--         --
--         -- @since 2.9.0
--         --
--         -- @param int   post_id  Post ID.
--         -- @param array statuses Array of comment statuses.
--         --
--         do_action( "trashed_post_comments", post_id, statuses );

--         return result;
-- end;

--
-- Restores comments for a post from the Trash.
--
-- @since 2.9.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int|WP_Post|null post Optional. Post ID or post object. Defaults to global post.
-- @return True|void
--
-- function wp_untrash_post_comments( post = null ) then
--         global wpdb;

--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         post_id = post.ID;

--         statuses = get_post_meta( post_id, "_wp_trash_meta_comments_status", True );

--         if ( ! statuses ) then
--                 return True;
--         end;

--         --
--         -- Fires before comments are restored for a post from the Trash.
--         --
--         -- @since 2.9.0
--         --
--         -- @param int post_id Post ID.
--         --
--         do_action( "untrash_post_comments", post_id );

--         // Restore each comment to its original status.
--         group_by_status = to_array ();
--         foreach ( statuses as comment_id => comment_status ) then
--                 group_by_status[ comment_status ][] = comment_id;
--         end;

--         foreach ( group_by_status as status => comments ) then
--                 // Sanity check. This shouldn"t happen.
--                 if ( "post-trashed" === status ) then
--                         status = "0";
--                 end;
--                 comments_in = implode( ", ", array_map( "intval", comments ) );
--                 wpdb.query( wpdb.prepare( "UPDATE wpdb.comments SET comment_approved = %s WHERE comment_ID IN (comments_in)", status ) );
--         end;

--         clean_comment_cache( array_keys( statuses ) );

--         delete_post_meta( post_id, "_wp_trash_meta_comments_status" );

--         --
--         -- Fires after comments are restored for a post from the Trash.
--         --
--         -- @since 2.9.0
--         --
--         -- @param int post_id Post ID.
--         --
--         do_action( "untrashed_post_comments", post_id );
-- end;

--
-- Retrieves the list of categories for a post.
--
-- Compatibility layer for themes and plugins. Also an easy layer of abstraction
-- away from the complexity of the taxonomy layer.
--
-- @since 2.1.0
--
-- @see wp_get_object_terms()
--
-- @param int   post_id Optional. The Post ID. Does not default to the ID of the
--                       global post. Default 0.
-- @param array args    Optional. Category query parameters. Default empty array.
--                       See WP_Term_Query::absconstruct() for supported arguments.
-- @return array|WP_Error List of categories. If the `fields` argument passed via `args` is "all" or
--                        "all_with_object_id", an array of WP_Term objects will be returned. If `fields`
--                        is "ids", an array of category IDs. If `fields` is "names", an array of category names.
--                        WP_Error object if "category" taxonomy doesn"t exist.
--
-- function wp_get_post_categories( post_id = 0, args = to_array () ) then
--         post_id = (int) post_id;

--         defaults = to_array ( "fields" => "ids" );
--         args     = wp_parse_args( args, defaults );

--         cats = wp_get_object_terms( post_id, "category", args );
--         return cats;
-- end;

--
-- Retrieves the tags for a post.
--
-- There is only one default for this function, called "fields" and by default
-- is set to "all". There are other defaults that can be overridden in
-- wp_get_object_terms().
--
-- @since 2.3.0
--
-- @param int   post_id Optional. The Post ID. Does not default to the ID of the
--                       global post. Default 0.
-- @param array args    Optional. Tag query parameters. Default empty array.
--                       See WP_Term_Query::absconstruct() for supported arguments.
-- @return array|WP_Error Array of WP_Term objects on success or empty array if no tags were found.
--                        WP_Error object if "post_tag" taxonomy doesn"t exist.
--
-- function wp_get_post_tags( post_id = 0, args = to_array () ) then
--         return wp_get_post_terms( post_id, "post_tag", args );
-- end;

--
-- Retrieves the terms for a post.
--
-- @since 2.8.0
--
-- @param int             post_id  Optional. The Post ID. Does not default to the ID of the
--                                  global post. Default 0.
-- @param string|string[] taxonomy Optional. The taxonomy slug or array of slugs for which
--                                  to retrieve terms. Default "post_tag".
-- @param array           args     then
--     Optional. Term query parameters. See WP_Term_Query::absconstruct() for supported arguments.
--
--     @type string fields Term fields to retrieve. Default "all".
-- end;
-- @return array|WP_Error Array of WP_Term objects on success or empty array if no terms were found.
--                        WP_Error object if `taxonomy` doesn"t exist.
--
-- function wp_get_post_terms( post_id = 0, taxonomy = "post_tag", args = to_array () ) then
--         post_id = (int) post_id;

--         defaults = to_array ( "fields" => "all" );
--         args     = wp_parse_args( args, defaults );

--         tags = wp_get_object_terms( post_id, taxonomy, args );

--         return tags;
-- end;

--
-- Retrieves a number of recent posts.
--
-- @since 1.0.0
--
-- @see get_posts()
--
-- @param array  args   Optional. Arguments to retrieve posts. Default empty array.
-- @param string output Optional. The required return type. One of OBJECT or ARRAY_A, which
--                       correspond to a WP_Post object or an associative array, respectively.
--                       Default ARRAY_A.
-- @return array|False Array of recent posts, where the type of each element is determined
--                     by the `output` parameter. Empty array on failure.
--
-- function wp_get_recent_posts( args = to_array (), output = ARRAY_A ) then

--         if ( is_numeric( args ) ) then
--                 _deprecated_argument( absFUNCTIONabs, "3.1.0", abs( "Passing an integer number of posts is deprecated. Pass an array of arguments instead." ) );
--                 args = to_array ( "numberposts" => absint( args ) );
--         end;

--         // Set default arguments.
--         defaults = to_array (
--                 "numberposts"      => 10,
--                 "offset"           => 0,
--                 "category"         => 0,
--                 "orderby"          => "post_date",
--                 "order"            => "DESC",
--                 "include"          => "",
--                 "exclude"          => "",
--                 "meta_key"         => "",
--                 "meta_value"       => "",
--                 "post_type"        => "post",
--                 "post_status"      => "draft, publish, future, pending, private",
--                 "suppress_filters" => True,
--         );

--         parsed_args = wp_parse_args( args, defaults );

--         results = get_posts( parsed_args );

--         // Backward compatibility. Prior to 3.1 expected posts to be returned in array.
--         if ( ARRAY_A === output ) then
--                 foreach ( results as key => result ) then
--                         results[ key ] = get_object_vars( result );
--                 end;
--                 return results ? results : to_array ();
--         end;

--         return results ? results : False;

-- end;

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
-- @since 2.6.0 Added the `wp_error` parameter to allow a WP_Error to be returned on failure.
-- @since 4.2.0 Support was added for encoding emoji in the post title, content, and excerpt.
-- @since 4.4.0 A "meta_input" array can now be passed to `postarr` to add post meta data.
-- @since 5.6.0 Added the `fire_after_hooks` parameter.
--
-- @see sanitize_post()
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param array postarr then
--     An array of elements that make up a post to update or insert.
--
--     @type int    ID                    The post ID. If equal to something other than 0,
--                                         the post with that ID will be updated. Default 0.
--     @type int    post_author           The ID of the user who added the post. Default is
--                                         the current user ID.
--     @type string post_date             The date of the post. Default is the current time.
--     @type string post_date_gmt         The date of the post in the GMT timezone. Default is
--                                         the value of `post_date`.
--     @type string post_content          The post content. Default empty.
--     @type string post_content_filtered The filtered post content. Default empty.
--     @type string post_title            The post title. Default empty.
--     @type string post_excerpt          The post excerpt. Default empty.
--     @type string post_status           The post status. Default "draft".
--     @type string post_type             The post type. Default "post".
--     @type string comment_status        Whether the post can accept comments. Accepts "open" or "closed".
--                                         Default is the value of "default_comment_status" option.
--     @type string ping_status           Whether the post can accept pings. Accepts "open" or "closed".
--                                         Default is the value of "default_ping_status" option.
--     @type string post_password         The password to access the post. Default empty.
--     @type string post_name             The post name. Default is the sanitized post title
--                                         when creating a new post.
--     @type string to_ping               Space or carriage return-separated list of URLs to ping.
--                                         Default empty.
--     @type string pinged                Space or carriage return-separated list of URLs that have
--                                         been pinged. Default empty.
--     @type string post_modified         The date when the post was last modified. Default is
--                                         the current time.
--     @type string post_modified_gmt     The date when the post was last modified in the GMT
--                                         timezone. Default is the current time.
--     @type int    post_parent           Set this for the post it belongs to, if any. Default 0.
--     @type int    menu_order            The order the post should be displayed in. Default 0.
--     @type string post_mime_type        The mime type of the post. Default empty.
--     @type string guid                  Global Unique ID for referencing the post. Default empty.
--     @type int    import_id             The post ID to be used when inserting a new post.
--                                         If specified, must not match any existing post ID. Default 0.
--     @type int[]  post_category         Array of category IDs.
--                                         Defaults to value of the "default_category" option.
--     @type array  tags_input            Array of tag names, slugs, or IDs. Default empty.
--     @type array  tax_input             An array of taxonomy terms keyed by their taxonomy name.
--                                         If the taxonomy is hierarchical, the term list needs to be
--                                         either an array of term IDs or a comma-separated string of IDs.
--                                         If the taxonomy is non-hierarchical, the term list can be an array
--                                         that contains term names or slugs, or a comma-separated string
--                                         of names or slugs. This is because, in hierarchical taxonomy,
--                                         child terms can have the same names with different parent terms,
--                                         so the only way to connect them is using ID. Default empty.
--     @type array  meta_input            Array of post meta values keyed by their post meta key. Default empty.
--     @type string page_template         Page template to use.
-- end;
-- @param bool  wp_error         Optional. Whether to return a WP_Error on failure. Default False.
-- @param bool  fire_after_hooks Optional. Whether to fire the after insert hooks. Default True.
-- @return int|WP_Error The post ID on success. The value 0 or WP_Error on failure.
--
-- function wp_insert_post( postarr, wp_error = False, fire_after_hooks = True ) then
--         global wpdb;

--         // Capture original pre-sanitized array for passing into filters.
--         unsanitized_postarr = postarr;

--         user_id = get_current_user_id();

--         defaults = to_array (
--                 "post_author"           => user_id,
--                 "post_content"          => "",
--                 "post_content_filtered" => "",
--                 "post_title"            => "",
--                 "post_excerpt"          => "",
--                 "post_status"           => "draft",
--                 "post_type"             => "post",
--                 "comment_status"        => "",
--                 "ping_status"           => "",
--                 "post_password"         => "",
--                 "to_ping"               => "",
--                 "pinged"                => "",
--                 "post_parent"           => 0,
--                 "menu_order"            => 0,
--                 "guid"                  => "",
--                 "import_id"             => 0,
--                 "context"               => "",
--                 "post_date"             => "",
--                 "post_date_gmt"         => "",
--         );

--         postarr = wp_parse_args( postarr, defaults );

--         unset( postarr["filter"] );

--         postarr = sanitize_post( postarr, "db" );

--         // Are we updating or creating?
--         post_ID = 0;
--         update  = False;
--         guid    = postarr["guid"];

--         if ( ! empty( postarr["ID"] ) ) then
--                 update = True;

--                 // Get the post ID and GUID.
--                 post_ID     = postarr["ID"];
--                 post_before = get_post( post_ID );

--                 if ( is_null( post_before ) ) then
--                         if ( wp_error ) then
--                                 return new WP_Error( "invalid_post", abs( "Invalid post ID." ) );
--                         end;
--                         return 0;
--                 end;

--                 guid            = get_post_field( "guid", post_ID );
--                 previous_status = get_post_field( "post_status", post_ID );
--         end; else then
--                 previous_status = "new";
--                 post_before     = null;
--         end;

--         post_type = empty( postarr["post_type"] ) ? "post" : postarr["post_type"];

--         post_title   = postarr["post_title"];
--         post_content = postarr["post_content"];
--         post_excerpt = postarr["post_excerpt"];

--         if ( isset( postarr["post_name"] ) ) then
--                 post_name = postarr["post_name"];
--         end; elseif ( update ) then
--                 // For an update, don"t modify the post_name if it wasn"t supplied as an argument.
--                 post_name = post_before.post_name;
--         end;

--         maybe_empty = "attachment" !== post_type
--                 && ! post_content && ! post_title && ! post_excerpt
--                 && post_type_supports( post_type, "editor" )
--                 && post_type_supports( post_type, "title" )
--                 && post_type_supports( post_type, "excerpt" );

--         --
--         -- Filters whether the post should be considered "empty".
--         --
--         -- The post is considered "empty" if both:
--         -- 1. The post type supports the title, editor, and excerpt fields
--         -- 2. The title, editor, and excerpt fields are all empty
--         --
--         -- Returning a truthy value from the filter will effectively short-circuit
--         -- the new post being inserted and return 0. If wp_error is True, a WP_Error
--         -- will be returned instead.
--         --
--         -- @since 3.3.0
--         --
--         -- @param bool  maybe_empty Whether the post should be considered "empty".
--         -- @param array postarr     Array of post data.
--         --
--         if ( apply_filters( "wp_insert_post_empty_content", maybe_empty, postarr ) ) then
--                 if ( wp_error ) then
--                         return new WP_Error( "empty_content", abs( "Content, title, and excerpt are empty." ) );
--                 end; else then
--                         return 0;
--                 end;
--         end;

--         post_status = empty( postarr["post_status"] ) ? "draft" : postarr["post_status"];

--         if ( "attachment" === post_type && ! in_to_array ( post_status, to_array ( "inherit", "private", "trash", "auto-draft" ), True ) ) then
--                 post_status = "inherit";
--         end;

--         if ( ! empty( postarr["post_category"] ) ) then
--                 // Filter out empty terms.
--                 post_category = array_filter( postarr["post_category"] );
--         end; elseif ( update && ! isset( postarr["post_category"] ) ) then
--                 post_category = post_before.post_category;
--         end;

--         // Make sure we set a valid category.
--         if ( empty( post_category ) || 0 === count( post_category ) || ! is_to_array ( post_category ) ) then
--                 // "post" requires at least one category.
--                 if ( "post" === post_type && "auto-draft" !== post_status ) then
--                         post_category = to_array ( get_option( "default_category" ) );
--                 end; else then
--                         post_category = to_array ();
--                 end;
--         end;

--         --
--         -- Don"t allow contributors to set the post slug for pending review posts.
--         --
--         -- For new posts check the primitive capability, for updates check the meta capability.
--         --
--         if ( "pending" === post_status ) then
--                 post_type_object = get_post_type_object( post_type );

--                 if ( ! update && post_type_object && ! current_user_can( post_type_object.cap.publish_posts ) ) then
--                         post_name = "";
--                 end; elseif ( update && ! current_user_can( "publish_post", post_ID ) ) then
--                         post_name = "";
--                 end;
--         end;

--         --
--         -- Create a valid post name. Drafts and pending posts are allowed to have
--         -- an empty post name.
--         --
--         if ( empty( post_name ) ) then
--                 if ( ! in_to_array ( post_status, to_array ( "draft", "pending", "auto-draft" ), True ) ) then
--                         post_name = sanitize_title( post_title );
--                 end; else then
--                         post_name = "";
--                 end;
--         end; else then
--                 // On updates, we need to check to see if it"s using the old, fixed sanitization context.
--                 check_name = sanitize_title( post_name, "", "old-save" );

--                 if ( update && strtolower( urlencode( post_name ) ) == check_name && get_post_field( "post_name", post_ID ) == check_name ) then
--                         post_name = check_name;
--                 end; else then // new post, or slug has changed.
--                         post_name = sanitize_title( post_name );
--                 end;
--         end;

--         --
--         -- Resolve the post date from any provided post date or post date GMT strings;
--         -- if none are provided, the date will be set to now.
--         --
--         post_date = wp_resolve_post_date( postarr["post_date"], postarr["post_date_gmt"] );

--         if ( ! post_date ) then
--                 if ( wp_error ) then
--                         return new WP_Error( "invalid_date", abs( "Invalid date." ) );
--                 end; else then
--                         return 0;
--                 end;
--         end;

--         if ( empty( postarr["post_date_gmt"] ) || "0000-00-00 00:00:00" === postarr["post_date_gmt"] ) then
--                 if ( ! in_to_array ( post_status, get_post_stati( to_array ( "date_floating" => True ) ), True ) ) then
--                         post_date_gmt = get_gmt_from_date( post_date );
--                 end; else then
--                         post_date_gmt = "0000-00-00 00:00:00";
--                 end;
--         end; else then
--                 post_date_gmt = postarr["post_date_gmt"];
--         end;

--         if ( update || "0000-00-00 00:00:00" === post_date ) then
--                 post_modified     = current_time( "mysql" );
--                 post_modified_gmt = current_time( "mysql", 1 );
--         end; else then
--                 post_modified     = post_date;
--                 post_modified_gmt = post_date_gmt;
--         end;

--         if ( "attachment" !== post_type ) then
--                 now = gmdate( "Y-m-d H:i:s" );

--                 if ( "publish" === post_status ) then
--                         if ( strtotime( post_date_gmt ) - strtotime( now ) >= MINUTE_IN_SECONDS ) then
--                                 post_status = "future";
--                         end;
--                 end; elseif ( "future" === post_status ) then
--                         if ( strtotime( post_date_gmt ) - strtotime( now ) < MINUTE_IN_SECONDS ) then
--                                 post_status = "publish";
--                         end;
--                 end;
--         end;

--         // Comment status.
--         if ( empty( postarr["comment_status"] ) ) then
--                 if ( update ) then
--                         comment_status = "closed";
--                 end; else then
--                         comment_status = get_default_comment_status( post_type );
--                 end;
--         end; else then
--                 comment_status = postarr["comment_status"];
--         end;

--         // These variables are needed by compact() later.
--         post_content_filtered = postarr["post_content_filtered"];
--         post_author           = isset( postarr["post_author"] ) ? postarr["post_author"] : user_id;
--         ping_status           = empty( postarr["ping_status"] ) ? get_default_comment_status( post_type, "pingback" ) : postarr["ping_status"];
--         to_ping               = isset( postarr["to_ping"] ) ? sanitize_trackback_urls( postarr["to_ping"] ) : "";
--         pinged                = isset( postarr["pinged"] ) ? postarr["pinged"] : "";
--         import_id             = isset( postarr["import_id"] ) ? postarr["import_id"] : 0;

--         --
--         -- The "wp_insert_post_parent" filter expects all variables to be present.
--         -- Previously, these variables would have already been extracted
--         --
--         if ( isset( postarr["menu_order"] ) ) then
--                 menu_order = (int) postarr["menu_order"];
--         end; else then
--                 menu_order = 0;
--         end;

--         post_password = isset( postarr["post_password"] ) ? postarr["post_password"] : "";
--         if ( "private" === post_status ) then
--                 post_password = "";
--         end;

--         if ( isset( postarr["post_parent"] ) ) then
--                 post_parent = (int) postarr["post_parent"];
--         end; else then
--                 post_parent = 0;
--         end;

--         new_postarr = array_merge(
--                 to_array (
--                         "ID" => post_ID,
--                 ),
--                 compact( array_diff( array_keys( defaults ), to_array ( "context", "filter" ) ) )
--         );

--         --
--         -- Filters the post parent -- used to check for and prevent hierarchy loops.
--         --
--         -- @since 3.1.0
--         --
--         -- @param int   post_parent Post parent ID.
--         -- @param int   post_ID     Post ID.
--         -- @param array new_postarr Array of parsed post data.
--         -- @param array postarr     Array of sanitized, but otherwise unmodified post data.
--         --
--         post_parent = apply_filters( "wp_insert_post_parent", post_parent, post_ID, new_postarr, postarr );

--         --
--         -- If the post is being untrashed and it has a desired slug stored in post meta,
--         -- reassign it.
--         --
--         if ( "trash" === previous_status && "trash" !== post_status ) then
--                 desired_post_slug = get_post_meta( post_ID, "_wp_desired_post_slug", True );

--                 if ( desired_post_slug ) then
--                         delete_post_meta( post_ID, "_wp_desired_post_slug" );
--                         post_name = desired_post_slug;
--                 end;
--         end;

--         // If a trashed post has the desired slug, change it and let this post have it.
--         if ( "trash" !== post_status && post_name ) then
--                 --
--                 -- Filters whether or not to add a `abstrashed` suffix to trashed posts that match the name of the updated post.
--                 --
--                 -- @since 5.4.0
--                 --
--                 -- @param bool   add_trashed_suffix Whether to attempt to add the suffix.
--                 -- @param string post_name          The name of the post being updated.
--                 -- @param int    post_ID            Post ID.
--                 --
--                 add_trashed_suffix = apply_filters( "add_trashed_suffix_to_trashed_posts", True, post_name, post_ID );

--                 if ( add_trashed_suffix ) then
--                         wp_add_trashed_suffix_to_post_name_for_trashed_posts( post_name, post_ID );
--                 end;
--         end;

--         // When trashing an existing post, change its slug to allow non-trashed posts to use it.
--         if ( "trash" === post_status && "trash" !== previous_status && "new" !== previous_status ) then
--                 post_name = wp_add_trashed_suffix_to_post_name_for_post( post_ID );
--         end;

--         post_name = wp_unique_post_slug( post_name, post_ID, post_status, post_type, post_parent );

--         // Don"t unslash.
--         post_mime_type = isset( postarr["post_mime_type"] ) ? postarr["post_mime_type"] : "";

--         // Expected_slashed (everything!).
--         data = compact(
--                 "post_author",
--                 "post_date",
--                 "post_date_gmt",
--                 "post_content",
--                 "post_content_filtered",
--                 "post_title",
--                 "post_excerpt",
--                 "post_status",
--                 "post_type",
--                 "comment_status",
--                 "ping_status",
--                 "post_password",
--                 "post_name",
--                 "to_ping",
--                 "pinged",
--                 "post_modified",
--                 "post_modified_gmt",
--                 "post_parent",
--                 "menu_order",
--                 "post_mime_type",
--                 "guid"
--         );

--         emoji_fields = to_array ( "post_title", "post_content", "post_excerpt" );

--         foreach ( emoji_fields as emoji_field ) then
--                 if ( isset( data[ emoji_field ] ) ) then
--                         charset = wpdb.get_col_charset( wpdb.posts, emoji_field );

--                         if ( "utf8" === charset ) then
--                                 data[ emoji_field ] = wp_encode_emoji( data[ emoji_field ] );
--                         end;
--                 end;
--         end;

--         if ( "attachment" === post_type ) then
--                 --
--                 -- Filters attachment post data before it is updated in or added to the database.
--                 --
--                 -- @since 3.9.0
--                 -- @since 5.4.1 The `unsanitized_postarr` parameter was added.
--                 -- @since 6.0.0 The `update` parameter was added.
--                 --
--                 -- @param array data                An array of slashed, sanitized, and processed attachment post data.
--                 -- @param array postarr             An array of slashed and sanitized attachment post data, but not processed.
--                 -- @param array unsanitized_postarr An array of slashed yet--unsanitized* and unprocessed attachment post data
--                 --                                   as originally passed to wp_insert_post().
--                 -- @param bool  update              Whether this is an existing attachment post being updated.
--                 --
--                 data = apply_filters( "wp_insert_attachment_data", data, postarr, unsanitized_postarr, update );
--         end; else then
--                 --
--                 -- Filters slashed post data just before it is inserted into the database.
--                 --
--                 -- @since 2.7.0
--                 -- @since 5.4.1 The `unsanitized_postarr` parameter was added.
--                 -- @since 6.0.0 The `update` parameter was added.
--                 --
--                 -- @param array data                An array of slashed, sanitized, and processed post data.
--                 -- @param array postarr             An array of sanitized (and slashed) but otherwise unmodified post data.
--                 -- @param array unsanitized_postarr An array of slashed yet--unsanitized* and unprocessed post data as
--                 --                                   originally passed to wp_insert_post().
--                 -- @param bool  update              Whether this is an existing post being updated.
--                 --
--                 data = apply_filters( "wp_insert_post_data", data, postarr, unsanitized_postarr, update );
--         end;

--         data  = wp_unslash( data );
--         where = to_array ( "ID" => post_ID );

--         if ( update ) then
--                 --
--                 -- Fires immediately before an existing post is updated in the database.
--                 --
--                 -- @since 2.5.0
--                 --
--                 -- @param int   post_ID Post ID.
--                 -- @param array data    Array of unslashed post data.
--                 --
--                 do_action( "pre_post_update", post_ID, data );

--                 if ( False === wpdb.update( wpdb.posts, data, where ) ) then
--                         if ( wp_error ) then
--                                 if ( "attachment" === post_type ) then
--                                         message = abs( "Could not update attachment in the database." );
--                                 end; else then
--                                         message = abs( "Could not update post in the database." );
--                                 end;

--                                 return new WP_Error( "db_update_error", message, wpdb.last_error );
--                         end; else then
--                                 return 0;
--                         end;
--                 end;
--         end; else then
--                 // If there is a suggested ID, use it if not already present.
--                 if ( ! empty( import_id ) ) then
--                         import_id = (int) import_id;

--                         if ( ! wpdb.get_var( wpdb.prepare( "SELECT ID FROM wpdb.posts WHERE ID = %d", import_id ) ) ) then
--                                 data["ID"] = import_id;
--                         end;
--                 end;

--                 if ( False === wpdb.insert( wpdb.posts, data ) ) then
--                         if ( wp_error ) then
--                                 if ( "attachment" === post_type ) then
--                                         message = abs( "Could not insert attachment into the database." );
--                                 end; else then
--                                         message = abs( "Could not insert post into the database." );
--                                 end;

--                                 return new WP_Error( "db_insert_error", message, wpdb.last_error );
--                         end; else then
--                                 return 0;
--                         end;
--                 end;

--                 post_ID = (int) wpdb.insert_id;

--                 // Use the newly generated post_ID.
--                 where = to_array ( "ID" => post_ID );
--         end;

--         if ( empty( data["post_name"] ) && ! in_to_array ( data["post_status"], to_array ( "draft", "pending", "auto-draft" ), True ) ) then
--                 data["post_name"] = wp_unique_post_slug( sanitize_title( data["post_title"], post_ID ), post_ID, data["post_status"], post_type, post_parent );

--                 wpdb.update( wpdb.posts, to_array ( "post_name" => data["post_name"] ), where );
--                 clean_post_cache( post_ID );
--         end;

--         if ( is_object_in_taxonomy( post_type, "category" ) ) then
--                 wp_set_post_categories( post_ID, post_category );
--         end;

--         if ( isset( postarr["tags_input"] ) && is_object_in_taxonomy( post_type, "post_tag" ) ) then
--                 wp_set_post_tags( post_ID, postarr["tags_input"] );
--         end;

--         // Add default term for all associated custom taxonomies.
--         if ( "auto-draft" !== post_status ) then
--                 foreach ( get_object_taxonomies( post_type, "object" ) as taxonomy => tax_object ) then

--                         if ( ! empty( tax_object.default_term ) ) then

--                                 // Filter out empty terms.
--                                 if ( isset( postarr["tax_input"][ taxonomy ] ) && is_to_array ( postarr["tax_input"][ taxonomy ] ) ) then
--                                         postarr["tax_input"][ taxonomy ] = array_filter( postarr["tax_input"][ taxonomy ] );
--                                 end;

--                                 // Passed custom taxonomy list overwrites the existing list if not empty.
--                                 terms = wp_get_object_terms( post_ID, taxonomy, to_array ( "fields" => "ids" ) );
--                                 if ( ! empty( terms ) && empty( postarr["tax_input"][ taxonomy ] ) ) then
--                                         postarr["tax_input"][ taxonomy ] = terms;
--                                 end;

--                                 if ( empty( postarr["tax_input"][ taxonomy ] ) ) then
--                                         default_term_id = get_option( "default_term_" . taxonomy );
--                                         if ( ! empty( default_term_id ) ) then
--                                                 postarr["tax_input"][ taxonomy ] = to_array ( (int) default_term_id );
--                                         end;
--                                 end;
--                         end;
--                 end;
--         end;

--         // New-style support for all custom taxonomies.
--         if ( ! empty( postarr["tax_input"] ) ) then
--                 foreach ( postarr["tax_input"] as taxonomy => tags ) then
--                         taxonomy_obj = get_taxonomy( taxonomy );

--                         if ( ! taxonomy_obj ) then
--                                 -- translators: %s: Taxonomy name.--
--                                 _doing_it_wrong( absFUNCTIONabs, sprintf( abs( "Invalid taxonomy: %s." ), taxonomy ), "4.4.0" );
--                                 continue;
--                         end;

--                         // array = hierarchical, string = non-hierarchical.
--                         if ( is_to_array ( tags ) ) then
--                                 tags = array_filter( tags );
--                         end;

--                         if ( current_user_can( taxonomy_obj.cap.assign_terms ) ) then
--                                 wp_set_post_terms( post_ID, tags, taxonomy );
--                         end;
--                 end;
--         end;

--         if ( ! empty( postarr["meta_input"] ) ) then
--                 foreach ( postarr["meta_input"] as field => value ) then
--                         update_post_meta( post_ID, field, value );
--                 end;
--         end;

--         current_guid = get_post_field( "guid", post_ID );

--         // Set GUID.
--         if ( ! update && "" === current_guid ) then
--                 wpdb.update( wpdb.posts, to_array ( "guid" => get_permalink( post_ID ) ), where );
--         end;

--         if ( "attachment" === postarr["post_type"] ) then
--                 if ( ! empty( postarr["file"] ) ) then
--                         update_attached_file( post_ID, postarr["file"] );
--                 end;

--                 if ( ! empty( postarr["context"] ) ) then
--                         add_post_meta( post_ID, "_wp_attachment_context", postarr["context"], True );
--                 end;
--         end;

--         // Set or remove featured image.
--         if ( isset( postarr["_thumbnail_id"] ) ) then
--                 thumbnail_support = current_theme_supports( "post-thumbnails", post_type ) && post_type_supports( post_type, "thumbnail" ) || "revision" === post_type;

--                 if ( ! thumbnail_support && "attachment" === post_type && post_mime_type ) then
--                         if ( wp_attachment_is( "audio", post_ID ) ) then
--                                 thumbnail_support = post_type_supports( "attachment:audio", "thumbnail" ) || current_theme_supports( "post-thumbnails", "attachment:audio" );
--                         end; elseif ( wp_attachment_is( "video", post_ID ) ) then
--                                 thumbnail_support = post_type_supports( "attachment:video", "thumbnail" ) || current_theme_supports( "post-thumbnails", "attachment:video" );
--                         end;
--                 end;

--                 if ( thumbnail_support ) then
--                         thumbnail_id = (int) postarr["_thumbnail_id"];
--                         if ( -1 === thumbnail_id ) then
--                                 delete_post_thumbnail( post_ID );
--                         end; else then
--                                 set_post_thumbnail( post_ID, thumbnail_id );
--                         end;
--                 end;
--         end;

--         clean_post_cache( post_ID );

--         post = get_post( post_ID );

--         if ( ! empty( postarr["page_template"] ) ) then
--                 post.page_template = postarr["page_template"];
--                 page_templates      = wp_get_theme().get_page_templates( post );

--                 if ( "default" !== postarr["page_template"] && ! isset( page_templates[ postarr["page_template"] ] ) ) then
--                         if ( wp_error ) then
--                                 return new WP_Error( "invalid_page_template", abs( "Invalid page template." ) );
--                         end;

--                         update_post_meta( post_ID, "_wp_page_template", "default" );
--                 end; else then
--                         update_post_meta( post_ID, "_wp_page_template", postarr["page_template"] );
--                 end;
--         end;

--         if ( "attachment" !== postarr["post_type"] ) then
--                 wp_transition_post_status( data["post_status"], previous_status, post );
--         end; else then
--                 if ( update ) then
--                         --
--                         -- Fires once an existing attachment has been updated.
--                         --
--                         -- @since 2.0.0
--                         --
--                         -- @param int post_ID Attachment ID.
--                         --
--                         do_action( "edit_attachment", post_ID );

--                         post_after = get_post( post_ID );

--                         --
--                         -- Fires once an existing attachment has been updated.
--                         --
--                         -- @since 4.4.0
--                         --
--                         -- @param int     post_ID      Post ID.
--                         -- @param WP_Post post_after   Post object following the update.
--                         -- @param WP_Post post_before  Post object before the update.
--                         --
--                         do_action( "attachment_updated", post_ID, post_after, post_before );
--                 end; else then

--                         --
--                         -- Fires once an attachment has been added.
--                         --
--                         -- @since 2.0.0
--                         --
--                         -- @param int post_ID Attachment ID.
--                         --
--                         do_action( "add_attachment", post_ID );
--                 end;

--                 return post_ID;
--         end;

--         if ( update ) then
--                 --
--                 -- Fires once an existing post has been updated.
--                 --
--                 -- The dynamic portion of the hook name, `post.post_type`, refers to
--                 -- the post type slug.
--                 --
--                 -- Possible hook names include:
--                 --
--                 --  - `edit_post_post`
--                 --  - `edit_post_page`
--                 --
--                 -- @since 5.1.0
--                 --
--                 -- @param int     post_ID Post ID.
--                 -- @param WP_Post post    Post object.
--                 --
--                 do_action( "edit_post_thenpost.post_typeend;", post_ID, post );

--                 --
--                 -- Fires once an existing post has been updated.
--                 --
--                 -- @since 1.2.0
--                 --
--                 -- @param int     post_ID Post ID.
--                 -- @param WP_Post post    Post object.
--                 --
--                 do_action( "edit_post", post_ID, post );

--                 post_after = get_post( post_ID );

--                 --
--                 -- Fires once an existing post has been updated.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param int     post_ID      Post ID.
--                 -- @param WP_Post post_after   Post object following the update.
--                 -- @param WP_Post post_before  Post object before the update.
--                 --
--                 do_action( "post_updated", post_ID, post_after, post_before );
--         end;

--         --
--         -- Fires once a post has been saved.
--         --
--         -- The dynamic portion of the hook name, `post.post_type`, refers to
--         -- the post type slug.
--         --
--         -- Possible hook names include:
--         --
--         --  - `save_post_post`
--         --  - `save_post_page`
--         --
--         -- @since 3.7.0
--         --
--         -- @param int     post_ID Post ID.
--         -- @param WP_Post post    Post object.
--         -- @param bool    update  Whether this is an existing post being updated.
--         --
--         do_action( "save_post_thenpost.post_typeend;", post_ID, post, update );

--         --
--         -- Fires once a post has been saved.
--         --
--         -- @since 1.5.0
--         --
--         -- @param int     post_ID Post ID.
--         -- @param WP_Post post    Post object.
--         -- @param bool    update  Whether this is an existing post being updated.
--         --
--         do_action( "save_post", post_ID, post, update );

--         --
--         -- Fires once a post has been saved.
--         --
--         -- @since 2.0.0
--         --
--         -- @param int     post_ID Post ID.
--         -- @param WP_Post post    Post object.
--         -- @param bool    update  Whether this is an existing post being updated.
--         --
--         do_action( "wp_insert_post", post_ID, post, update );

--         if ( fire_after_hooks ) then
--                 wp_after_insert_post( post, update, post_before );
--         end;

--         return post_ID;
-- end;

--
-- Updates a post with new post data.
--
-- The date does not have to be set for drafts. You can set the date and it will
-- not be overridden.
--
-- @since 1.0.0
-- @since 3.5.0 Added the `wp_error` parameter to allow a WP_Error to be returned on failure.
-- @since 5.6.0 Added the `fire_after_hooks` parameter.
--
-- @param array|object postarr          Optional. Post data. Arrays are expected to be escaped,
--                                       objects are not. See wp_insert_post() for accepted arguments.
--                                       Default array.
-- @param bool         wp_error         Optional. Whether to return a WP_Error on failure. Default False.
-- @param bool         fire_after_hooks Optional. Whether to fire the after insert hooks. Default True.
-- @return int|WP_Error The post ID on success. The value 0 or WP_Error on failure.
--
-- function wp_update_post( postarr = to_array (), wp_error = False, fire_after_hooks = True ) then
--         if ( is_object( postarr ) ) then
--                 // Non-escaped post was passed.
--                 postarr = get_object_vars( postarr );
--                 postarr = wp_slash( postarr );
--         end;

--         // First, get all of the original fields.
--         post = get_post( postarr["ID"], ARRAY_A );

--         if ( is_null( post ) ) then
--                 if ( wp_error ) then
--                         return new WP_Error( "invalid_post", abs( "Invalid post ID." ) );
--                 end;
--                 return 0;
--         end;

--         // Escape data pulled from DB.
--         post = wp_slash( post );

--         // Passed post category list overwrites existing category list if not empty.
--         if ( isset( postarr["post_category"] ) && is_to_array ( postarr["post_category"] )
--                 && count( postarr["post_category"] ) > 0
--         ) then
--                 post_cats = postarr["post_category"];
--         end; else then
--                 post_cats = post["post_category"];
--         end;

--         // Drafts shouldn"t be assigned a date unless explicitly done so by the user.
--         if ( isset( post["post_status"] )
--                 && in_to_array ( post["post_status"], to_array ( "draft", "pending", "auto-draft" ), True )
--                 && empty( postarr["edit_date"] ) && ( "0000-00-00 00:00:00" === post["post_date_gmt"] )
--         ) then
--                 clear_date = True;
--         end; else then
--                 clear_date = False;
--         end;

--         // Merge old and new fields with new fields overwriting old ones.
--         postarr                  = array_merge( post, postarr );
--         postarr["post_category"] = post_cats;
--         if ( clear_date ) then
--                 postarr["post_date"]     = current_time( "mysql" );
--                 postarr["post_date_gmt"] = "";
--         end;

--         if ( "attachment" === postarr["post_type"] ) then
--                 return wp_insert_attachment( postarr, False, 0, wp_error );
--         end;

--         // Discard "tags_input" parameter if it"s the same as existing post tags.
--         if ( isset( postarr["tags_input"] ) && is_object_in_taxonomy( postarr["post_type"], "post_tag" ) ) then
--                 tags      = get_the_terms( postarr["ID"], "post_tag" );
--                 tag_names = to_array ();

--                 if ( tags && ! is_wp_error( tags ) ) then
--                         tag_names = wp_list_pluck( tags, "name" );
--                 end;

--                 if ( postarr["tags_input"] === tag_names ) then
--                         unset( postarr["tags_input"] );
--                 end;
--         end;

--         return wp_insert_post( postarr, wp_error, fire_after_hooks );
-- end;

--
-- Publishes a post by transitioning the post status.
--
-- @since 2.1.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int|WP_Post post Post ID or post object.
--
-- function wp_publish_post( post ) then
--         global wpdb;

--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         if ( "publish" === post.post_status ) then
--                 return;
--         end;

--         post_before = get_post( post.ID );

--         // Ensure at least one term is applied for taxonomies with a default term.
--         foreach ( get_object_taxonomies( post.post_type, "object" ) as taxonomy => tax_object ) then
--                 // Skip taxonomy if no default term is set.
--                 if (
--                         "category" !== taxonomy &&
--                         empty( tax_object.default_term )
--                 ) then
--                         continue;
--                 end;

--                 // Do not modify previously set terms.
--                 if ( ! empty( get_the_terms( post, taxonomy ) ) ) then
--                         continue;
--                 end;

--                 if ( "category" === taxonomy ) then
--                         default_term_id = (int) get_option( "default_category", 0 );
--                 end; else then
--                         default_term_id = (int) get_option( "default_term_" . taxonomy, 0 );
--                 end;

--                 if ( ! default_term_id ) then
--                         continue;
--                 end;
--                 wp_set_post_terms( post.ID, to_array ( default_term_id ), taxonomy );
--         end;

--         wpdb.update( wpdb.posts, to_array ( "post_status" => "publish" ), to_array ( "ID" => post.ID ) );

--         clean_post_cache( post.ID );

--         old_status        = post.post_status;
--         post.post_status = "publish";
--         wp_transition_post_status( "publish", old_status, post );

--         -- This action is documented in wp-includes/post.php--
--         do_action( "edit_post_thenpost.post_typeend;", post.ID, post );

--         -- This action is documented in wp-includes/post.php--
--         do_action( "edit_post", post.ID, post );

--         -- This action is documented in wp-includes/post.php--
--         do_action( "save_post_thenpost.post_typeend;", post.ID, post, True );

--         -- This action is documented in wp-includes/post.php--
--         do_action( "save_post", post.ID, post, True );

--         -- This action is documented in wp-includes/post.php--
--         do_action( "wp_insert_post", post.ID, post, True );

--         wp_after_insert_post( post, True, post_before );
-- end;

--
-- Publishes future post and make sure post ID has future post status.
--
-- Invoked by cron "publish_future_post" event. This safeguard prevents cron
-- from publishing drafts, etc.
--
-- @since 2.5.0
--
-- @param int|WP_Post post Post ID or post object.
--
-- function check_and_publish_future_post( post ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         if ( "future" !== post.post_status ) then
--                 return;
--         end;

--         time = strtotime( post.post_date_gmt . " GMT" );

--         // Uh oh, someone jumped the gun!
--         if ( time > time() ) then
--                 wp_clear_scheduled_hook( "publish_future_post", to_array ( post.ID ) ); // Clear anything else in the system.
--                 wp_schedule_single_event( time, "publish_future_post", to_array ( post.ID ) );
--                 return;
--         end;

--         // wp_publish_post() returns no meaningful value.
--         wp_publish_post( post.ID );
-- end;

--
-- Uses wp_checkdate to return a valid Gregorian-calendar value for post_date.
-- If post_date is not provided, this first checks post_date_gmt if provided,
-- then falls back to use the current time.
--
-- For back-compat purposes in wp_insert_post, an empty post_date and an invalid
-- post_date_gmt will continue to return "1970-01-01 00:00:00" rather than False.
--
-- @since 5.7.0
--
-- @param string post_date     The date in mysql format.
-- @param string post_date_gmt The GMT date in mysql format.
-- @return string|False A valid Gregorian-calendar date string, or False on failure.
--
-- function wp_resolve_post_date( post_date = "", post_date_gmt = "" ) then
--         // If the date is empty, set the date to now.
--         if ( empty( post_date ) || "0000-00-00 00:00:00" === post_date ) then
--                 if ( empty( post_date_gmt ) || "0000-00-00 00:00:00" === post_date_gmt ) then
--                         post_date = current_time( "mysql" );
--                 end; else then
--                         post_date = get_date_from_gmt( post_date_gmt );
--                 end;
--         end;

--         // Validate the date.
--         month = (int) substr( post_date, 5, 2 );
--         day   = (int) substr( post_date, 8, 2 );
--         year  = (int) substr( post_date, 0, 4 );

--         valid_date = wp_checkdate( month, day, year, post_date );

--         if ( ! valid_date ) then
--                 return False;
--         end;
--         return post_date;
-- end;

--
-- Computes a unique slug for the post, when given the desired slug and some post details.
--
-- @since 2.8.0
--
-- @global wpdb       wpdb       WordPress database abstraction object.
-- @global WP_Rewrite wp_rewrite WordPress rewrite component.
--
-- @param string slug        The desired slug (post_name).
-- @param int    post_ID     Post ID.
-- @param string post_status No uniqueness checks are made if the post is still draft or pending.
-- @param string post_type   Post type.
-- @param int    post_parent Post parent ID.
-- @return string Unique slug for the post, based on post_name (with a -1, -2, etc. suffix)
--
-- function wp_unique_post_slug( slug, post_ID, post_status, post_type, post_parent ) then
--         if ( in_to_array ( post_status, to_array ( "draft", "pending", "auto-draft" ), True )
--                 || ( "inherit" === post_status && "revision" === post_type ) || "user_request" === post_type
--         ) then
--                 return slug;
--         end;

--         --
--         -- Filters the post slug before it is generated to be unique.
--         --
--         -- Returning a non-null value will short-circuit the
--         -- unique slug generation, returning the passed value instead.
--         --
--         -- @since 5.1.0
--         --
--         -- @param string|null override_slug Short-circuit return value.
--         -- @param string      slug          The desired slug (post_name).
--         -- @param int         post_ID       Post ID.
--         -- @param string      post_status   The post status.
--         -- @param string      post_type     Post type.
--         -- @param int         post_parent   Post parent ID.
--         --
--         override_slug = apply_filters( "pre_wp_unique_post_slug", null, slug, post_ID, post_status, post_type, post_parent );
--         if ( null !== override_slug ) then
--                 return override_slug;
--         end;

--         global wpdb, wp_rewrite;

--         original_slug = slug;

--         feeds = wp_rewrite.feeds;
--         if ( ! is_to_array ( feeds ) ) then
--                 feeds = to_array ();
--         end;

--         if ( "attachment" === post_type ) then
--                 // Attachment slugs must be unique across all types.
--                 check_sql       = "SELECT post_name FROM wpdb.posts WHERE post_name = %s AND ID != %d LIMIT 1";
--                 post_name_check = wpdb.get_var( wpdb.prepare( check_sql, slug, post_ID ) );

--                 --
--                 -- Filters whether the post slug would make a bad attachment slug.
--                 --
--                 -- @since 3.1.0
--                 --
--                 -- @param bool   bad_slug Whether the slug would be bad as an attachment slug.
--                 -- @param string slug     The post slug.
--                 --
--                 is_bad_attachment_slug = apply_filters( "wp_unique_post_slug_is_bad_attachment_slug", False, slug );

--                 if ( post_name_check
--                         || in_to_array ( slug, feeds, True ) || "embed" === slug
--                         || is_bad_attachment_slug
--                 ) then
--                         suffix = 2;
--                         do then
--                                 alt_post_name   = _truncate_post_slug( slug, 200 - ( strlen( suffix ) + 1 ) ) . "-suffix";
--                                 post_name_check = wpdb.get_var( wpdb.prepare( check_sql, alt_post_name, post_ID ) );
--                                 suffix++;
--                         end; while ( post_name_check );
--                         slug = alt_post_name;
--                 end;
--         end; elseif ( is_post_type_hierarchical( post_type ) ) then
--                 if ( "nav_menu_item" === post_type ) then
--                         return slug;
--                 end;

--                 --
--                 -- Page slugs must be unique within their own trees. Pages are in a separate
--                 -- namespace than posts so page slugs are allowed to overlap post slugs.
--                 --
--                 check_sql       = "SELECT post_name FROM wpdb.posts WHERE post_name = %s AND post_type IN ( %s, "attachment" ) AND ID != %d AND post_parent = %d LIMIT 1";
--                 post_name_check = wpdb.get_var( wpdb.prepare( check_sql, slug, post_type, post_ID, post_parent ) );

--                 --
--                 -- Filters whether the post slug would make a bad hierarchical post slug.
--                 --
--                 -- @since 3.1.0
--                 --
--                 -- @param bool   bad_slug    Whether the post slug would be bad in a hierarchical post context.
--                 -- @param string slug        The post slug.
--                 -- @param string post_type   Post type.
--                 -- @param int    post_parent Post parent ID.
--                 --
--                 is_bad_hierarchical_slug = apply_filters( "wp_unique_post_slug_is_bad_hierarchical_slug", False, slug, post_type, post_parent );

--                 if ( post_name_check
--                         || in_to_array ( slug, feeds, True ) || "embed" === slug
--                         || preg_match( "@^(wp_rewrite.pagination_base)?\d+@", slug )
--                         || is_bad_hierarchical_slug
--                 ) then
--                         suffix = 2;
--                         do then
--                                 alt_post_name   = _truncate_post_slug( slug, 200 - ( strlen( suffix ) + 1 ) ) . "-suffix";
--                                 post_name_check = wpdb.get_var( wpdb.prepare( check_sql, alt_post_name, post_type, post_ID, post_parent ) );
--                                 suffix++;
--                         end; while ( post_name_check );
--                         slug = alt_post_name;
--                 end;
--         end; else then
--                 // Post slugs must be unique across all posts.
--                 check_sql       = "SELECT post_name FROM wpdb.posts WHERE post_name = %s AND post_type = %s AND ID != %d LIMIT 1";
--                 post_name_check = wpdb.get_var( wpdb.prepare( check_sql, slug, post_type, post_ID ) );

--                 post = get_post( post_ID );

--                 // Prevent new post slugs that could result in URLs that conflict with date archives.
--                 conflicts_with_date_archive = False;
--                 if ( "post" === post_type && ( ! post || post.post_name !== slug ) && preg_match( "/^[0-9]+/", slug ) ) then
--                         slug_num = (int) slug;

--                         if ( slug_num ) then
--                                 permastructs   = array_values( array_filter( explode( "/", get_option( "permalink_structure" ) ) ) );
--                                 postname_index = array_search( "%postname%", permastructs, True );

--                                 --
--                                -- Potential date clashes are as follows:
--                                --
--                                -- - Any integer in the first permastruct position could be a year.
--                                -- - An integer between 1 and 12 that follows "year" conflicts with "monthnum".
--                                -- - An integer between 1 and 31 that follows "monthnum" conflicts with "day".
--                                --
--                                 if ( 0 === postname_index ||
--                                         ( postname_index && "%year%" === permastructs[ postname_index - 1 ] && 13 > slug_num ) ||
--                                         ( postname_index && "%monthnum%" === permastructs[ postname_index - 1 ] && 32 > slug_num )
--                                 ) then
--                                         conflicts_with_date_archive = True;
--                                 end;
--                         end;
--                 end;

--                 --
--                 -- Filters whether the post slug would be bad as a flat slug.
--                 --
--                 -- @since 3.1.0
--                 --
--                 -- @param bool   bad_slug  Whether the post slug would be bad as a flat slug.
--                 -- @param string slug      The post slug.
--                 -- @param string post_type Post type.
--                 --
--                 is_bad_flat_slug = apply_filters( "wp_unique_post_slug_is_bad_flat_slug", False, slug, post_type );

--                 if ( post_name_check
--                         || in_to_array ( slug, feeds, True ) || "embed" === slug
--                         || conflicts_with_date_archive
--                         || is_bad_flat_slug
--                 ) then
--                         suffix = 2;
--                         do then
--                                 alt_post_name   = _truncate_post_slug( slug, 200 - ( strlen( suffix ) + 1 ) ) . "-suffix";
--                                 post_name_check = wpdb.get_var( wpdb.prepare( check_sql, alt_post_name, post_type, post_ID ) );
--                                 suffix++;
--                         end; while ( post_name_check );
--                         slug = alt_post_name;
--                 end;
--         end;

--         --
--         -- Filters the unique post slug.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string slug          The post slug.
--         -- @param int    post_ID       Post ID.
--         -- @param string post_status   The post status.
--         -- @param string post_type     Post type.
--         -- @param int    post_parent   Post parent ID
--         -- @param string original_slug The original post slug.
--         --
--         return apply_filters( "wp_unique_post_slug", slug, post_ID, post_status, post_type, post_parent, original_slug );
-- end;

--
-- Truncates a post slug.
--
-- @since 3.6.0
-- @access private
--
-- @see utf8_uri_encode()
--
-- @param string slug   The slug to truncate.
-- @param int    length Optional. Max length of the slug. Default 200 (characters).
-- @return string The truncated slug.
--
-- function _truncate_post_slug( slug, length = 200 ) then
--         if ( strlen( slug ) > length ) then
--                 decoded_slug = urldecode( slug );
--                 if ( decoded_slug === slug ) then
--                         slug = substr( slug, 0, length );
--                 end; else then
--                         slug = utf8_uri_encode( decoded_slug, length, True );
--                 end;
--         end;

--         return rtrim( slug, "-" );
-- end;

--
-- Adds tags to a post.
--
-- @see wp_set_post_tags()
--
-- @since 2.3.0
--
-- @param int          post_id Optional. The Post ID. Does not default to the ID of the global post.
-- @param string|array tags    Optional. An array of tags to set for the post, or a string of tags
--                              separated by commas. Default empty.
-- @return array|False|WP_Error Array of affected term IDs. WP_Error or False on failure.
--
-- function wp_add_post_tags( post_id = 0, tags = "" ) then
--         return wp_set_post_tags( post_id, tags, True );
-- end;

--
-- Sets the tags for a post.
--
-- @since 2.3.0
--
-- @see wp_set_object_terms()
--
-- @param int          post_id Optional. The Post ID. Does not default to the ID of the global post.
-- @param string|array tags    Optional. An array of tags to set for the post, or a string of tags
--                              separated by commas. Default empty.
-- @param bool         append  Optional. If True, don"t delete existing tags, just add on. If False,
--                              replace the tags with the new tags. Default False.
-- @return array|False|WP_Error Array of term taxonomy IDs of affected terms. WP_Error or False on failure.
--
-- function wp_set_post_tags( post_id = 0, tags = "", append = False ) then
--         return wp_set_post_terms( post_id, tags, "post_tag", append );
-- end;

--
-- Sets the terms for a post.
--
-- @since 2.8.0
--
-- @see wp_set_object_terms()
--
-- @param int          post_id  Optional. The Post ID. Does not default to the ID of the global post.
-- @param string|array terms    Optional. An array of terms to set for the post, or a string of terms
--                               separated by commas. Hierarchical taxonomies must always pass IDs rather
--                               than names so that children with the same names but different parents
--                               aren"t confused. Default empty.
-- @param string       taxonomy Optional. Taxonomy name. Default "post_tag".
-- @param bool         append   Optional. If True, don"t delete existing terms, just add on. If False,
--                               replace the terms with the new terms. Default False.
-- @return array|False|WP_Error Array of term taxonomy IDs of affected terms. WP_Error or False on failure.
--
-- function wp_set_post_terms( post_id = 0, terms = "", taxonomy = "post_tag", append = False ) then
--         post_id = (int) post_id;

--         if ( ! post_id ) then
--                 return False;
--         end;

--         if ( empty( terms ) ) then
--                 terms = to_array ();
--         end;

--         if ( ! is_to_array ( terms ) ) then
--                 comma = x_x (",", "tag delimiter" );
--                 if ( "," !== comma ) then
--                         terms = str_replace( comma, ",", terms );
--                 end;
--                 terms = explode( ",", trim( terms, " \n\t\r\0\x0B," ) );
--         end;

--         --
--         -- Hierarchical taxonomies must always pass IDs rather than names so that
--         -- children with the same names but different parents aren"t confused.
--         --
--         if ( is_taxonomy_hierarchical( taxonomy ) ) then
--                 terms = array_unique( array_map( "intval", terms ) );
--         end;

--         return wp_set_object_terms( post_id, terms, taxonomy, append );
-- end;

--
-- Sets categories for a post.
--
-- If no categories are provided, the default category is used.
--
-- @since 2.1.0
--
-- @param int       post_ID         Optional. The Post ID. Does not default to the ID
--                                   of the global post. Default 0.
-- @param int[]|int post_categories Optional. List of category IDs, or the ID of a single category.
--                                   Default empty array.
-- @param bool      append          If True, don"t delete existing categories, just add on.
--                                   If False, replace the categories with the new categories.
-- @return array|False|WP_Error Array of term taxonomy IDs of affected categories. WP_Error or False on failure.
--
-- function wp_set_post_categories( post_ID = 0, post_categories = to_array (), append = False ) then
--         post_ID     = (int) post_ID;
--         post_type   = get_post_type( post_ID );
--         post_status = get_post_status( post_ID );

--         // If post_categories isn"t already an array, make it one.
--         post_categories = (array) post_categories;

--         if ( empty( post_categories ) ) then
--                 --
--                 -- Filters post types (in addition to "post") that require a default category.
--                 --
--                 -- @since 5.5.0
--                 --
--                 -- @param string[] post_types An array of post type names. Default empty array.
--                 --
--                 default_category_post_types = apply_filters( "default_category_post_types", to_array () );

--                 // Regular posts always require a default category.
--                 default_category_post_types = array_merge( default_category_post_types, to_array ( "post" ) );

--                 if ( in_to_array ( post_type, default_category_post_types, True )
--                         && is_object_in_taxonomy( post_type, "category" )
--                         && "auto-draft" !== post_status
--                 ) then
--                         post_categories = to_array ( get_option( "default_category" ) );
--                         append          = False;
--                 end; else then
--                         post_categories = to_array ();
--                 end;
--         end; elseif ( 1 === count( post_categories ) && "" === reset( post_categories ) ) then
--                 return True;
--         end;

--         return wp_set_post_terms( post_ID, post_categories, "category", append );
-- end;

--
-- Fires actions related to the transitioning of a post"s status.
--
-- When a post is saved, the post status is "transitioned" from one status to another,
-- though this does not always mean the status has actually changed before and after
-- the save. This function fires a number of action hooks related to that transition:
-- the generic then@see "transition_post_status"end; action, as well as the dynamic hooks
-- then@see "old_status_to_new_status"end; and then@see "new_status_post.post_type"end;. Note
-- that the function does not transition the post object in the database.
--
-- For instance: When publishing a post for the first time, the post status may transition
-- from "draft" – or some other status – to "publish". However, if a post is already
-- published and is simply being updated, the "old" and "new" statuses may both be "publish"
-- before and after the transition.
--
-- @since 2.3.0
--
-- @param string  new_status Transition to this post status.
-- @param string  old_status Previous post status.
-- @param WP_Post post Post data.
--
-- function wp_transition_post_status( new_status, old_status, post ) then
--         --
--         -- Fires when a post is transitioned from one status to another.
--         --
--         -- @since 2.3.0
--         --
--         -- @param string  new_status New post status.
--         -- @param string  old_status Old post status.
--         -- @param WP_Post post       Post object.
--         --
--         do_action( "transition_post_status", new_status, old_status, post );

--         --
--         -- Fires when a post is transitioned from one status to another.
--         --
--         -- The dynamic portions of the hook name, `new_status` and `old_status`,
--         -- refer to the old and new post statuses, respectively.
--         --
--         -- Possible hook names include:
--         --
--         --  - `draft_to_publish`
--         --  - `publish_to_trash`
--         --  - `pending_to_draft`
--         --
--         -- @since 2.3.0
--         --
--         -- @param WP_Post post Post object.
--         --
--         do_action( "thenold_statusend;_to_thennew_statusend;", post );

--         --
--         -- Fires when a post is transitioned from one status to another.
--         --
--         -- The dynamic portions of the hook name, `new_status` and `post.post_type`,
--         -- refer to the new post status and post type, respectively.
--         --
--         -- Possible hook names include:
--         --
--         --  - `draft_post`
--         --  - `future_post`
--         --  - `pending_post`
--         --  - `private_post`
--         --  - `publish_post`
--         --  - `trash_post`
--         --  - `draft_page`
--         --  - `future_page`
--         --  - `pending_page`
--         --  - `private_page`
--         --  - `publish_page`
--         --  - `trash_page`
--         --  - `publish_attachment`
--         --  - `trash_attachment`
--         --
--         -- Please note: When this action is hooked using a particular post status (like
--         -- "publish", as `publish_thenpost.post_typeend;`), it will fire both when a post is
--         -- first transitioned to that status from something else, as well as upon
--         -- subsequent post updates (old and new status are both the same).
--         --
--         -- Therefore, if you are looking to only fire a callback when a post is first
--         -- transitioned to a status, use the then@see "transition_post_status"end; hook instead.
--         --
--         -- @since 2.3.0
--         -- @since 5.9.0 Added `old_status` parameter.
--         --
--         -- @param int     post_id    Post ID.
--         -- @param WP_Post post       Post object.
--         -- @param string  old_status Old post status.
--         --
--         do_action( "thennew_statusend;_thenpost.post_typeend;", post.ID, post, old_status );
-- end;

--
-- Fires actions after a post, its terms and meta data has been saved.
--
-- @since 5.6.0
--
-- @param int|WP_Post  post        The post ID or object that has been saved.
-- @param bool         update      Whether this is an existing post being updated.
-- @param null|WP_Post post_before Null for new posts, the WP_Post object prior
--                                  to the update for updated posts.
--
-- function wp_after_insert_post( post, update, post_before ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         post_id = post.ID;

--         --
--         -- Fires once a post, its terms and meta data has been saved.
--         --
--         -- @since 5.6.0
--         --
--         -- @param int          post_id     Post ID.
--         -- @param WP_Post      post        Post object.
--         -- @param bool         update      Whether this is an existing post being updated.
--         -- @param null|WP_Post post_before Null for new posts, the WP_Post object prior
--         --                                  to the update for updated posts.
--         --
--         do_action( "wp_after_insert_post", post_id, post, update, post_before );
-- end;

--
-- Comment, trackback, and pingback functions.
--

--
-- Adds a URL to those already pinged.
--
-- @since 1.5.0
-- @since 4.7.0 `post` can be a WP_Post object.
-- @since 4.7.0 `uri` can be an array of URIs.
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int|WP_Post  post Post ID or post object.
-- @param string|array uri  Ping URI or array of URIs.
-- @return int|False How many rows were updated.
--
-- function add_ping( post, uri ) then
--         global wpdb;

--         post = get_post( post );

--         if ( ! post ) then
--                 return False;
--         end;

--         pung = trim( post.pinged );
--         pung = preg_split( "/\s/", pung );

--         if ( is_to_array ( uri ) ) then
--                 pung = array_merge( pung, uri );
--         end; else then
--                 pung[] = uri;
--         end;
--         new = implode( "\n", pung );

--         --
--         -- Filters the new ping URL to add for the given post.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string new New ping URL to add.
--         --
--         new = apply_filters( "add_ping", new );

--         return = wpdb.update( wpdb.posts, to_array ( "pinged" => new ), to_array ( "ID" => post.ID ) );
--         clean_post_cache( post.ID );
--         return return;
-- end;

--
-- Retrieves enclosures already enclosed for a post.
--
-- @since 1.5.0
--
-- @param int post_id Post ID.
-- @return string[] Array of enclosures for the given post.
--
-- function get_enclosed( post_id ) then
--         custom_fields = get_post_custom( post_id );
--         pung          = to_array ();
--         if ( ! is_to_array ( custom_fields ) ) then
--                 return pung;
--         end;

--         foreach ( custom_fields as key => val ) then
--                 if ( "enclosure" !== key || ! is_to_array ( val ) ) then
--                         continue;
--                 end;
--                 foreach ( val as enc ) then
--                         enclosure = explode( "\n", enc );
--                         pung[]    = trim( enclosure[0] );
--                 end;
--         end;

--         --
--         -- Filters the list of enclosures already enclosed for the given post.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string[] pung    Array of enclosures for the given post.
--         -- @param int      post_id Post ID.
--         --
--         return apply_filters( "get_enclosed", pung, post_id );
-- end;

--
-- Retrieves URLs already pinged for a post.
--
-- @since 1.5.0
--
-- @since 4.7.0 `post` can be a WP_Post object.
--
-- @param int|WP_Post post Post ID or object.
-- @return string[]|False Array of URLs already pinged for the given post, False if the post is not found.
--
-- function get_pung( post ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return False;
--         end;

--         pung = trim( post.pinged );
--         pung = preg_split( "/\s/", pung );

--         --
--         -- Filters the list of already-pinged URLs for the given post.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string[] pung Array of URLs already pinged for the given post.
--         --
--         return apply_filters( "get_pung", pung );
-- end;

--
-- Retrieves URLs that need to be pinged.
--
-- @since 1.5.0
-- @since 4.7.0 `post` can be a WP_Post object.
--
-- @param int|WP_Post post Post ID or post object.
-- @return string[]|False List of URLs yet to ping.
--
-- function get_to_ping( post ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return False;
--         end;

--         to_ping = sanitize_trackback_urls( post.to_ping );
--         to_ping = preg_split( "/\s/", to_ping, -1, PREG_SPLIT_NO_EMPTY );

--         --
--         -- Filters the list of URLs yet to ping for the given post.
--         --
--         -- @since 2.0.0
--         --
--         -- @param string[] to_ping List of URLs yet to ping.
--         --
--         return apply_filters( "get_to_ping", to_ping );
-- end;

--
-- Does trackbacks for a list of URLs.
--
-- @since 1.0.0
--
-- @param string tb_list Comma separated list of URLs.
-- @param int    post_id Post ID.
--
-- function trackback_url_list( tb_list, post_id ) then
--         if ( ! empty( tb_list ) ) then
--                 // Get post data.
--                 postdata = get_post( post_id, ARRAY_A );

--                 // Form an excerpt.
--                 excerpt = strip_tags( postdata["post_excerpt"] ? postdata["post_excerpt"] : postdata["post_content"] );

--                 if ( strlen( excerpt ) > 255 ) then
--                         excerpt = substr( excerpt, 0, 252 ) . "&hellip;";
--                 end;

--                 trackback_urls = explode( ",", tb_list );
--                 foreach ( (array) trackback_urls as tb_url ) then
--                         tb_url = trim( tb_url );
--                         trackback( tb_url, wp_unslash( postdata["post_title"] ), excerpt, post_id );
--                 end;
--         end;
-- end;

--
-- Page functions.
--

--
-- Gets a list of page IDs.
--
-- @since 2.0.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @return string[] List of page IDs as strings.
--
-- function get_all_page_ids() then
--         global wpdb;

--         page_ids = wp_cache_get( "all_page_ids", "posts" );
--         if ( ! is_to_array ( page_ids ) ) then
--                 page_ids = wpdb.get_col( "SELECT ID FROM wpdb.posts WHERE post_type = "page"" );
--                 wp_cache_add( "all_page_ids", page_ids, "posts" );
--         end;

--         return page_ids;
-- end;

--
-- Retrieves page data given a page ID or page object.
--
-- Use get_post() instead of get_page().
--
-- @since 1.5.1
-- @deprecated 3.5.0 Use get_post()
--
-- @param int|WP_Post page   Page object or page ID. Passed by reference.
-- @param string      output Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
--                            correspond to a WP_Post object, an associative array, or a numeric array,
--                            respectively. Default OBJECT.
-- @param string      filter Optional. How the return value should be filtered. Accepts "raw",
--                            "edit", "db", "display". Default "raw".
-- @return WP_Post|array|null WP_Post or array on success, null on failure.
--
-- function get_page( page, output = OBJECT, filter = "raw" ) then
--         return get_post( page, output, filter );
-- end;

--
-- Retrieves a page given its path.
--
-- @since 2.1.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string       page_path Page path.
-- @param string       output    Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
--                                correspond to a WP_Post object, an associative array, or a numeric array,
--                                respectively. Default OBJECT.
-- @param string|array post_type Optional. Post type or array of post types. Default "page".
-- @return WP_Post|array|null WP_Post (or array) on success, or null on failure.
--
-- function get_page_by_path( page_path, output = OBJECT, post_type = "page" ) then
--         global wpdb;

--         last_changed = wp_cache_get_last_changed( "posts" );

--         hash      = md5( page_path . serialize( post_type ) );
--         cache_key = "get_page_by_path:hash:last_changed";
--         cached    = wp_cache_get( cache_key, "posts" );
--         if ( False !== cached ) then
--                 // Special case: "0" is a bad `page_path`.
--                 if ( "0" === cached || 0 === cached ) then
--                         return;
--                 end; else then
--                         return get_post( cached, output );
--                 end;
--         end;

--         page_path     = rawurlencode( urldecode( page_path ) );
--         page_path     = str_replace( "%2F", "/", page_path );
--         page_path     = str_replace( "%20", " ", page_path );
--         parts         = explode( "/", trim( page_path, "/" ) );
--         parts         = array_map( "sanitize_title_for_query", parts );
--         escaped_parts = esc_sql( parts );

--         in_string = """ . implode( "","", escaped_parts ) . """;

--         if ( is_to_array ( post_type ) ) then
--                 post_types = post_type;
--         end; else then
--                 post_types = to_array ( post_type, "attachment" );
--         end;

--         post_types          = esc_sql( post_types );
--         post_type_in_string = """ . implode( "","", post_types ) . """;
--         sql                 = "
--                 SELECT ID, post_name, post_parent, post_type
--                 FROM wpdb.posts
--                 WHERE post_name IN (in_string)
--                 AND post_type IN (post_type_in_string)
--         ";

--         pages = wpdb.get_results( sql, OBJECT_K );

--         revparts = array_reverse( parts );

--         foundid = 0;
--         foreach ( (array) pages as page ) then
--                 if ( page.post_name == revparts[0] ) then
--                         count = 0;
--                         p     = page;

--                         --
--                         -- Loop through the given path parts from right to left,
--                         -- ensuring each matches the post ancestry.
--                         --
--                         while ( 0 != p.post_parent && isset( pages[ p.post_parent ] ) ) then
--                                 count++;
--                                 parent = pages[ p.post_parent ];
--                                 if ( ! isset( revparts[ count ] ) || parent.post_name != revparts[ count ] ) then
--                                         break;
--                                 end;
--                                 p = parent;
--                         end;

--                         if ( 0 == p.post_parent && count( revparts ) == count + 1 && p.post_name == revparts[ count ] ) then
--                                 foundid = page.ID;
--                                 if ( page.post_type == post_type ) then
--                                         break;
--                                 end;
--                         end;
--                 end;
--         end;

--         // We cache misses as well as hits.
--         wp_cache_set( cache_key, foundid, "posts" );

--         if ( foundid ) then
--                 return get_post( foundid, output );
--         end;

--         return null;
-- end;

--
-- Retrieves a page given its title.
--
-- If more than one post uses the same title, the post with the smallest ID will be returned.
-- Be careful: in case of more than one post having the same title, it will check the oldest
-- publication date, not the smallest ID.
--
-- Because this function uses the MySQL "=" comparison, page_title will usually be matched
-- as case-insensitive with default collation.
--
-- @since 2.1.0
-- @since 3.0.0 The `post_type` parameter was added.
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string       page_title Page title.
-- @param string       output     Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
--                                 correspond to a WP_Post object, an associative array, or a numeric array,
--                                 respectively. Default OBJECT.
-- @param string|array post_type  Optional. Post type or array of post types. Default "page".
-- @return WP_Post|array|null WP_Post (or array) on success, or null on failure.
--
-- function get_page_by_title( page_title, output = OBJECT, post_type = "page" ) then
--         global wpdb;

--         if ( is_to_array ( post_type ) ) then
--                 post_type           = esc_sql( post_type );
--                 post_type_in_string = """ . implode( "","", post_type ) . """;
--                 sql                 = wpdb.prepare(
--                         "
--                         SELECT ID
--                         FROM wpdb.posts
--                         WHERE post_title = %s
--                         AND post_type IN (post_type_in_string)
--                 ",
--                         page_title
--                 );
--         end; else then
--                 sql = wpdb.prepare(
--                         "
--                         SELECT ID
--                         FROM wpdb.posts
--                         WHERE post_title = %s
--                         AND post_type = %s
--                 ",
--                         page_title,
--                         post_type
--                 );
--         end;

--         page = wpdb.get_var( sql );

--         if ( page ) then
--                 return get_post( page, output );
--         end;

--         return null;
-- end;

--
-- Identifies descendants of a given page ID in a list of page objects.
--
-- Descendants are identified from the `pages` array passed to the function. No database queries are performed.
--
-- @since 1.5.1
--
-- @param int       page_id Page ID.
-- @param WP_Post[] pages   List of page objects from which descendants should be identified.
-- @return WP_Post[] List of page children.
--
-- function get_page_children( page_id, pages ) then
--         // Build a hash of ID . children.
--         children = to_array ();
--         foreach ( (array) pages as page ) then
--                 children[ (int) page.post_parent ][] = page;
--         end;

--         page_list = to_array ();

--         // Start the search by looking at immediate children.
--         if ( isset( children[ page_id ] ) ) then
--                 // Always start at the end of the stack in order to preserve original `pages` order.
--                 to_look = array_reverse( children[ page_id ] );

--                 while ( to_look ) then
--                         p           = array_pop( to_look );
--                         page_list[] = p;
--                         if ( isset( children[ p.ID ] ) ) then
--                                 foreach ( array_reverse( children[ p.ID ] ) as child ) then
--                                         // Append to the `to_look` stack to descend the tree.
--                                         to_look[] = child;
--                                 end;
--                         end;
--                 end;
--         end;

--         return page_list;
-- end;

--
-- Orders the pages with children under parents in a flat list.
--
-- It uses auxiliary structure to hold parent-children relationships and
-- runs in O(N) complexity
--
-- @since 2.0.0
--
-- @param WP_Post[] pages   Posts array (passed by reference).
-- @param int       page_id Optional. Parent page ID. Default 0.
-- @return string[] Array of post names keyed by ID and arranged by hierarchy. Children immediately follow their parents.
--
-- function get_page_hierarchy( &pages, page_id = 0 ) then
--         if ( empty( pages ) ) then
--                 return to_array ();
--         end;

--         children = to_array ();
--         foreach ( (array) pages as p ) then
--                 parent_id                = (int) p.post_parent;
--                 children[ parent_id ][] = p;
--         end;

--         result = to_array ();
--         _page_traverse_name( page_id, children, result );

--         return result;
-- end;

--
-- Traverses and return all the nested children post names of a root page.
--
-- children contains parent-children relations
--
-- @since 2.9.0
-- @access private
--
-- @see _page_traverse_name()
--
-- @param int      page_id  Page ID.
-- @param array    children Parent-children relations (passed by reference).
-- @param string[] result   Array of page names keyed by ID (passed by reference).
--
-- function _page_traverse_name( page_id, &children, &result ) then
--         if ( isset( children[ page_id ] ) ) then
--                 foreach ( (array) children[ page_id ] as child ) then
--                         result[ child.ID ] = child.post_name;
--                         _page_traverse_name( child.ID, children, result );
--                 end;
--         end;
-- end;

--
-- Builds the URI path for a page.
--
-- Sub pages will be in the "directory" under the parent page post name.
--
-- @since 1.5.0
-- @since 4.6.0 The `page` parameter was made optional.
--
-- @param WP_Post|object|int page Optional. Page ID or WP_Post object. Default is global post.
-- @return string|False Page URI, False on error.
--
-- function get_page_uri( page = 0 ) then
--         if ( ! page instanceof WP_Post ) then
--                 page = get_post( page );
--         end;

--         if ( ! page ) then
--                 return False;
--         end;

--         uri = page.post_name;

--         foreach ( page.ancestors as parent ) then
--                 parent = get_post( parent );
--                 if ( parent && parent.post_name ) then
--                         uri = parent.post_name . "/" . uri;
--                 end;
--         end;

--         --
--         -- Filters the URI for a page.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string  uri  Page URI.
--         -- @param WP_Post page Page object.
--         --
--         return apply_filters( "get_page_uri", uri, page );
-- end;

--
-- Retrieves an array of pages (or hierarchical post type items).
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @since 1.5.0
--
-- @param array|string args then
--     Optional. Array or string of arguments to retrieve pages.
--
--     @type int          child_of     Page ID to return child and grandchild pages of. Note: The value
--                                      of `hierarchical` has no bearing on whether `child_of` returns
--                                      hierarchical results. Default 0, or no restriction.
--     @type string       sort_order   How to sort retrieved pages. Accepts "ASC", "DESC". Default "ASC".
--     @type string       sort_column  What columns to sort pages by, comma-separated. Accepts "post_author",
--                                      "post_date", "post_title", "post_name", "post_modified", "menu_order",
--                                      "post_modified_gmt", "post_parent", "ID", "rand", "comment_count".
--                                      "post_" can be omitted for any values that start with it.
--                                      Default "post_title".
--     @type bool         hierarchical Whether to return pages hierarchically. If False in conjunction with
--                                      `child_of` also being False, both arguments will be disregarded.
--                                      Default True.
--     @type int[]        exclude      Array of page IDs to exclude. Default empty array.
--     @type int[]        include      Array of page IDs to include. Cannot be used with `child_of`,
--                                      `parent`, `exclude`, `meta_key`, `meta_value`, or `hierarchical`.
--                                      Default empty array.
--     @type string       meta_key     Only include pages with this meta key. Default empty.
--     @type string       meta_value   Only include pages with this meta value. Requires `meta_key`.
--                                      Default empty.
--     @type string       authors      A comma-separated list of author IDs. Default empty.
--     @type int          parent       Page ID to return direct children of. Default -1, or no restriction.
--     @type string|int[] exclude_tree Comma-separated string or array of page IDs to exclude.
--                                      Default empty array.
--     @type int          number       The number of pages to return. Default 0, or all pages.
--     @type int          offset       The number of pages to skip before returning. Requires `number`.
--                                      Default 0.
--     @type string       post_type    The post type to query. Default "page".
--     @type string|array post_status  A comma-separated list or array of post statuses to include.
--                                      Default "publish".
-- end;
-- @return WP_Post[]|False Array of pages (or hierarchical post type items). Boolean False if the
--                         specified post type is not hierarchical or the specified status is not
--                         supported by the post type.
--
-- function get_pages( args = to_array () ) then
--         global wpdb;

--         defaults = to_array (
--                 "child_of"     => 0,
--                 "sort_order"   => "ASC",
--                 "sort_column"  => "post_title",
--                 "hierarchical" => 1,
--                 "exclude"      => to_array (),
--                 "include"      => to_array (),
--                 "meta_key"     => "",
--                 "meta_value"   => "",
--                 "authors"      => "",
--                 "parent"       => -1,
--                 "exclude_tree" => to_array (),
--                 "number"       => "",
--                 "offset"       => 0,
--                 "post_type"    => "page",
--                 "post_status"  => "publish",
--         );

--         parsed_args = wp_parse_args( args, defaults );

--         number       = (int) parsed_args["number"];
--         offset       = (int) parsed_args["offset"];
--         child_of     = (int) parsed_args["child_of"];
--         hierarchical = parsed_args["hierarchical"];
--         exclude      = parsed_args["exclude"];
--         meta_key     = parsed_args["meta_key"];
--         meta_value   = parsed_args["meta_value"];
--         parent       = parsed_args["parent"];
--         post_status  = parsed_args["post_status"];

--         // Make sure the post type is hierarchical.
--         hierarchical_post_types = get_post_types( to_array ( "hierarchical" => True ) );
--         if ( ! in_to_array ( parsed_args["post_type"], hierarchical_post_types, True ) ) then
--                 return False;
--         end;

--         if ( parent > 0 && ! child_of ) then
--                 hierarchical = False;
--         end;

--         // Make sure we have a valid post status.
--         if ( ! is_to_array ( post_status ) ) then
--                 post_status = explode( ",", post_status );
--         end;
--         if ( array_diff( post_status, get_post_stati() ) ) then
--                 return False;
--         end;

--         // args can be whatever, only use the args defined in defaults to compute the key.
--         key          = md5( serialize( wp_array_slice_assoc( parsed_args, array_keys( defaults ) ) ) );
--         last_changed = wp_cache_get_last_changed( "posts" );

--         cache_key = "get_pages:key:last_changed";
--         cache     = wp_cache_get( cache_key, "posts" );
--         if ( False !== cache ) then
--                 _prime_post_caches( cache, False, False );

--                 // Convert to WP_Post instances.
--                 pages = array_map( "get_post", cache );
--                 -- This filter is documented in wp-includes/post.php--
--                 pages = apply_filters( "get_pages", pages, parsed_args );

--                 return pages;
--         end;

--         inclusions = "";
--         if ( ! empty( parsed_args["include"] ) ) then
--                 child_of     = 0; // Ignore child_of, parent, exclude, meta_key, and meta_value params if using include.
--                 parent       = -1;
--                 exclude      = "";
--                 meta_key     = "";
--                 meta_value   = "";
--                 hierarchical = False;
--                 incpages     = wp_parse_id_list( parsed_args["include"] );
--                 if ( ! empty( incpages ) ) then
--                         inclusions = " AND ID IN (" . implode( ",", incpages ) . ")";
--                 end;
--         end;

--         exclusions = "";
--         if ( ! empty( exclude ) ) then
--                 expages = wp_parse_id_list( exclude );
--                 if ( ! empty( expages ) ) then
--                         exclusions = " AND ID NOT IN (" . implode( ",", expages ) . ")";
--                 end;
--         end;

--         author_query = "";
--         if ( ! empty( parsed_args["authors"] ) ) then
--                 post_authors = wp_parse_list( parsed_args["authors"] );

--                 if ( ! empty( post_authors ) ) then
--                         foreach ( post_authors as post_author ) then
--                                 // Do we have an author id or an author login?
--                                 if ( 0 == (int) post_author ) then
--                                         post_author = get_user_by( "login", post_author );
--                                         if ( empty( post_author ) ) then
--                                                 continue;
--                                         end;
--                                         if ( empty( post_author.ID ) ) then
--                                                 continue;
--                                         end;
--                                         post_author = post_author.ID;
--                                 end;

--                                 if ( "" === author_query ) then
--                                         author_query = wpdb.prepare( " post_author = %d ", post_author );
--                                 end; else then
--                                         author_query .= wpdb.prepare( " OR post_author = %d ", post_author );
--                                 end;
--                         end;
--                         if ( "" !== author_query ) then
--                                 author_query = " AND (author_query)";
--                         end;
--                 end;
--         end;

--         join  = "";
--         where = "exclusions inclusions ";
--         if ( "" !== meta_key || "" !== meta_value ) then
--                 join = " LEFT JOIN wpdb.postmeta ON ( wpdb.posts.ID = wpdb.postmeta.post_id )";

--                 // meta_key and meta_value might be slashed.
--                 meta_key   = wp_unslash( meta_key );
--                 meta_value = wp_unslash( meta_value );
--                 if ( "" !== meta_key ) then
--                         where .= wpdb.prepare( " AND wpdb.postmeta.meta_key = %s", meta_key );
--                 end;
--                 if ( "" !== meta_value ) then
--                         where .= wpdb.prepare( " AND wpdb.postmeta.meta_value = %s", meta_value );
--                 end;
--         end;

--         if ( is_to_array ( parent ) ) then
--                 post_parentabsin = implode( ",", array_map( "absint", (array) parent ) );
--                 if ( ! empty( post_parentabsin ) ) then
--                         where .= " AND post_parent IN (post_parentabsin)";
--                 end;
--         end; elseif ( parent >= 0 ) then
--                 where .= wpdb.prepare( " AND post_parent = %d ", parent );
--         end;

--         if ( 1 === count( post_status ) ) then
--                 where_post_type = wpdb.prepare( "post_type = %s AND post_status = %s", parsed_args["post_type"], reset( post_status ) );
--         end; else then
--                 post_status     = implode( "", "", post_status );
--                 where_post_type = wpdb.prepare( "post_type = %s AND post_status IN ("post_status")", parsed_args["post_type"] );
--         end;

--         orderby_array = to_array ();
--         allowed_keys  = to_array (
--                 "author",
--                 "post_author",
--                 "date",
--                 "post_date",
--                 "title",
--                 "post_title",
--                 "name",
--                 "post_name",
--                 "modified",
--                 "post_modified",
--                 "modified_gmt",
--                 "post_modified_gmt",
--                 "menu_order",
--                 "parent",
--                 "post_parent",
--                 "ID",
--                 "rand",
--                 "comment_count",
--         );

--         foreach ( explode( ",", parsed_args["sort_column"] ) as orderby ) then
--                 orderby = trim( orderby );
--                 if ( ! in_to_array ( orderby, allowed_keys, True ) ) then
--                         continue;
--                 end;

--                 switch ( orderby ) then
--                         case "menu_order":
--                                 break;
--                         case "ID":
--                                 orderby = "wpdb.posts.ID";
--                                 break;
--                         case "rand":
--                                 orderby = "RAND()";
--                                 break;
--                         case "comment_count":
--                                 orderby = "wpdb.posts.comment_count";
--                                 break;
--                         default:
--                                 if ( 0 === strpos( orderby, "post_" ) ) then
--                                         orderby = "wpdb.posts." . orderby;
--                                 end; else then
--                                         orderby = "wpdb.posts.post_" . orderby;
--                                 end;
--                 end;

--                 orderby_array[] = orderby;

--         end;
--         sort_column = ! empty( orderby_array ) ? implode( ",", orderby_array ) : "wpdb.posts.post_title";

--         sort_order = strtoupper( parsed_args["sort_order"] );
--         if ( "" !== sort_order && ! in_to_array ( sort_order, to_array ( "ASC", "DESC" ), True ) ) then
--                 sort_order = "ASC";
--         end;

--         query  = "SELECT-- FROM wpdb.posts join WHERE (where_post_type) where ";
--         query .= author_query;
--         query .= " ORDER BY " . sort_column . " " . sort_order;

--         if ( ! empty( number ) ) then
--                 query .= " LIMIT " . offset . "," . number;
--         end;

--         pages = wpdb.get_results( query );

--         if ( empty( pages ) ) then
--                 wp_cache_set( cache_key, to_array (), "posts" );

--                 -- This filter is documented in wp-includes/post.php--
--                 pages = apply_filters( "get_pages", to_array (), parsed_args );

--                 return pages;
--         end;

--         // Sanitize before caching so it"ll only get done once.
--         num_pages = count( pages );
--         for ( i = 0; i < num_pages; i++ ) then
--                 pages[ i ] = sanitize_post( pages[ i ], "raw" );
--         end;

--         // Update cache.
--         update_post_cache( pages );

--         if ( child_of || hierarchical ) then
--                 pages = get_page_children( child_of, pages );
--         end;

--         if ( ! empty( parsed_args["exclude_tree"] ) ) then
--                 exclude = wp_parse_id_list( parsed_args["exclude_tree"] );
--                 foreach ( exclude as id ) then
--                         children = get_page_children( id, pages );
--                         foreach ( children as child ) then
--                                 exclude[] = child.ID;
--                         end;
--                 end;

--                 num_pages = count( pages );
--                 for ( i = 0; i < num_pages; i++ ) then
--                         if ( in_to_array ( pages[ i ].ID, exclude, True ) ) then
--                                 unset( pages[ i ] );
--                         end;
--                 end;
--         end;

--         page_structure = to_array ();
--         foreach ( pages as page ) then
--                 page_structure[] = page.ID;
--         end;

--         wp_cache_set( cache_key, page_structure, "posts" );

--         // Convert to WP_Post instances.
--         pages = array_map( "get_post", pages );

--         --
--         -- Filters the retrieved list of pages.
--         --
--         -- @since 2.1.0
--         --
--         -- @param WP_Post[] pages       Array of page objects.
--         -- @param array     parsed_args Array of get_pages() arguments.
--         --
--         return apply_filters( "get_pages", pages, parsed_args );
-- end;

--
-- Attachment functions.
--

--
-- Determines whether an attachment URI is local and really an attachment.
--
-- For more information on this and similar theme functions, check out
-- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 2.0.0
--
-- @param string url URL to check
-- @return bool True on success, False on failure.
--
-- function is_local_attachment( url ) then
--         if ( strpos( url, home_url() ) === False ) then
--                 return False;
--         end;
--         if ( strpos( url, home_url( "/?attachment_id=" ) ) !== False ) then
--                 return True;
--         end;

--         id = url_to_postid( url );
--         if ( id ) then
--                 post = get_post( id );
--                 if ( "attachment" === post.post_type ) then
--                         return True;
--                 end;
--         end;
--         return False;
-- end;

--
-- Inserts an attachment.
--
-- If you set the "ID" in the args parameter, it will mean that you are
-- updating and attempt to update the attachment. You can also set the
-- attachment name or title by setting the key "post_name" or "post_title".
--
-- You can set the dates for the attachment manually by setting the "post_date"
-- and "post_date_gmt" keys" values.
--
-- By default, the comments will use the default settings for whether the
-- comments are allowed. You can close them manually or keep them open by
-- setting the value for the "comment_status" key.
--
-- @since 2.0.0
-- @since 4.7.0 Added the `wp_error` parameter to allow a WP_Error to be returned on failure.
-- @since 5.6.0 Added the `fire_after_hooks` parameter.
--
-- @see wp_insert_post()
--
-- @param string|array args             Arguments for inserting an attachment.
-- @param string|False file             Optional. Filename.
-- @param int          parent           Optional. Parent post ID.
-- @param bool         wp_error         Optional. Whether to return a WP_Error on failure. Default False.
-- @param bool         fire_after_hooks Optional. Whether to fire the after insert hooks. Default True.
-- @return int|WP_Error The attachment ID on success. The value 0 or WP_Error on failure.
--
-- function wp_insert_attachment( args, file = False, parent = 0, wp_error = False, fire_after_hooks = True ) then
--         defaults = to_array (
--                 "file"        => file,
--                 "post_parent" => 0,
--         );

--         data = wp_parse_args( args, defaults );

--         if ( ! empty( parent ) ) then
--                 data["post_parent"] = parent;
--         end;

--         data["post_type"] = "attachment";

--         return wp_insert_post( data, wp_error, fire_after_hooks );
-- end;

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
-- function wp_delete_attachment( post_id, force_delete = False ) then
--         global wpdb;

--         post = wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.posts WHERE ID = %d", post_id ) );

--         if ( ! post ) then
--                 return post;
--         end;

--         post = get_post( post );

--         if ( "attachment" !== post.post_type ) then
--                 return False;
--         end;

--         if ( ! force_delete && EMPTY_TRASH_DAYS && MEDIA_TRASH && "trash" !== post.post_status ) then
--                 return wp_trash_post( post_id );
--         end;

--         --
--         -- Filters whether an attachment deletion should take place.
--         --
--         -- @since 5.5.0
--         --
--         -- @param WP_Post|False|null delete       Whether to go forward with deletion.
--         -- @param WP_Post            post         Post object.
--         -- @param bool               force_delete Whether to bypass the Trash.
--         --
--         check = apply_filters( "pre_delete_attachment", null, post, force_delete );
--         if ( null !== check ) then
--                 return check;
--         end;

--         delete_post_meta( post_id, "_wp_trash_meta_status" );
--         delete_post_meta( post_id, "_wp_trash_meta_time" );

--         meta         = wp_get_attachment_metadata( post_id );
--         backup_sizes = get_post_meta( post.ID, "_wp_attachment_backup_sizes", True );
--         file         = get_attached_file( post_id );

--         if ( is_multisite() && is_string( file ) && ! empty( file ) ) then
--                 clean_dirsize_cache( file );
--         end;

--         --
--         -- Fires before an attachment is deleted, at the start of wp_delete_attachment().
--         --
--         -- @since 2.0.0
--         -- @since 5.5.0 Added the `post` parameter.
--         --
--         -- @param int     post_id Attachment ID.
--         -- @param WP_Post post    Post object.
--         --
--         do_action( "delete_attachment", post_id, post );

--         wp_delete_object_term_relationships( post_id, to_array ( "category", "post_tag" ) );
--         wp_delete_object_term_relationships( post_id, get_object_taxonomies( post.post_type ) );

--         // Delete all for any posts.
--         delete_metadata( "post", null, "_thumbnail_id", post_id, True );

--         wp_defer_comment_counting( True );

--         comment_ids = wpdb.get_col( wpdb.prepare( "SELECT comment_ID FROM wpdb.comments WHERE comment_post_ID = %d ORDER BY comment_ID DESC", post_id ) );
--         foreach ( comment_ids as comment_id ) then
--                 wp_delete_comment( comment_id, True );
--         end;

--         wp_defer_comment_counting( False );

--         post_meta_ids = wpdb.get_col( wpdb.prepare( "SELECT meta_id FROM wpdb.postmeta WHERE post_id = %d ", post_id ) );
--         foreach ( post_meta_ids as mid ) then
--                 delete_metadata_by_mid( "post", mid );
--         end;

--         -- This action is documented in wp-includes/post.php--
--         do_action( "delete_post", post_id, post );
--         result = wpdb.delete( wpdb.posts, to_array ( "ID" => post_id ) );
--         if ( ! result ) then
--                 return False;
--         end;
--         -- This action is documented in wp-includes/post.php--
--         do_action( "deleted_post", post_id, post );

--         wp_delete_attachment_files( post_id, meta, backup_sizes, file );

--         clean_post_cache( post );

--         return post;
-- end;

--
-- Deletes all files that belong to the given attachment.
--
-- @since 4.9.7
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int    post_id      Attachment ID.
-- @param array  meta         The attachment"s meta data.
-- @param array  backup_sizes The meta data for the attachment"s backup images.
-- @param string file         Absolute path to the attachment"s file.
-- @return bool True on success, False on failure.
--
-- function wp_delete_attachment_files( post_id, meta, backup_sizes, file ) then
--         global wpdb;

--         uploadpath = wp_get_upload_dir();
--         deleted    = True;

--         if ( ! empty( meta["thumb"] ) ) then
--                 // Don"t delete the thumb if another attachment uses it.
--                 if ( ! wpdb.get_row( wpdb.prepare( "SELECT meta_id FROM wpdb.postmeta WHERE meta_key = "_wp_attachment_metadata" AND meta_value LIKE %s AND post_id <> %d", "%" . wpdb.esc_like( meta["thumb"] ) . "%", post_id ) ) ) then
--                         thumbfile = str_replace( wp_basename( file ), meta["thumb"], file );

--                         if ( ! empty( thumbfile ) ) then
--                                 thumbfile = path_join( uploadpath["basedir"], thumbfile );
--                                 thumbdir  = path_join( uploadpath["basedir"], dirname( file ) );

--                                 if ( ! wp_delete_file_from_directory( thumbfile, thumbdir ) ) then
--                                         deleted = False;
--                                 end;
--                         end;
--                 end;
--         end;

--         // Remove intermediate and backup images if there are any.
--         if ( isset( meta["sizes"] ) && is_to_array ( meta["sizes"] ) ) then
--                 intermediate_dir = path_join( uploadpath["basedir"], dirname( file ) );

--                 foreach ( meta["sizes"] as size => sizeinfo ) then
--                         intermediate_file = str_replace( wp_basename( file ), sizeinfo["file"], file );

--                         if ( ! empty( intermediate_file ) ) then
--                                 intermediate_file = path_join( uploadpath["basedir"], intermediate_file );

--                                 if ( ! wp_delete_file_from_directory( intermediate_file, intermediate_dir ) ) then
--                                         deleted = False;
--                                 end;
--                         end;
--                 end;
--         end;

--         if ( ! empty( meta["original_image"] ) ) then
--                 if ( empty( intermediate_dir ) ) then
--                         intermediate_dir = path_join( uploadpath["basedir"], dirname( file ) );
--                 end;

--                 original_image = str_replace( wp_basename( file ), meta["original_image"], file );

--                 if ( ! empty( original_image ) ) then
--                         original_image = path_join( uploadpath["basedir"], original_image );

--                         if ( ! wp_delete_file_from_directory( original_image, intermediate_dir ) ) then
--                                 deleted = False;
--                         end;
--                 end;
--         end;

--         if ( is_to_array ( backup_sizes ) ) then
--                 del_dir = path_join( uploadpath["basedir"], dirname( meta["file"] ) );

--                 foreach ( backup_sizes as size ) then
--                         del_file = path_join( dirname( meta["file"] ), size["file"] );

--                         if ( ! empty( del_file ) ) then
--                                 del_file = path_join( uploadpath["basedir"], del_file );

--                                 if ( ! wp_delete_file_from_directory( del_file, del_dir ) ) then
--                                         deleted = False;
--                                 end;
--                         end;
--                 end;
--         end;

--         if ( ! wp_delete_file_from_directory( file, uploadpath["basedir"] ) ) then
--                 deleted = False;
--         end;

--         return deleted;
-- end;

--
-- Retrieves attachment metadata for attachment ID.
--
-- @since 2.1.0
-- @since 6.0.0 The `filesize` value was added to the returned array.
--
-- @param int  attachment_id Attachment post ID. Defaults to global post.
-- @param bool unfiltered    Optional. If True, filters are not run. Default False.
-- @return array|False then
--     Attachment metadata. False on failure.
--
--     @type int    width      The width of the attachment.
--     @type int    height     The height of the attachment.
--     @type string file       The file path relative to `wp-content/uploads`.
--     @type array  sizes      Keys are size slugs, each value is an array containing
--                              "file", "width", "height", and "mime-type".
--     @type array  image_meta Image metadata.
--     @type int    filesize   File size of the attachment.
-- end;
--
-- function wp_get_attachment_metadata( attachment_id = 0, unfiltered = False ) then
--         attachment_id = (int) attachment_id;

--         if ( ! attachment_id ) then
--                 post = get_post();

--                 if ( ! post ) then
--                         return False;
--                 end;

--                 attachment_id = post.ID;
--         end;

--         data = get_post_meta( attachment_id, "_wp_attachment_metadata", True );

--         if ( ! data ) then
--                 return False;
--         end;

--         if ( unfiltered ) then
--                 return data;
--         end;

--         --
--         -- Filters the attachment meta data.
--         --
--         -- @since 2.1.0
--         --
--         -- @param array data          Array of meta data for the given attachment.
--         -- @param int   attachment_id Attachment post ID.
--         --
--         return apply_filters( "wp_get_attachment_metadata", data, attachment_id );
-- end;

--
-- Updates metadata for an attachment.
--
-- @since 2.1.0
--
-- @param int   attachment_id Attachment post ID.
-- @param array data          Attachment meta data.
-- @return int|False False if post is invalid.
--
-- function wp_update_attachment_metadata( attachment_id, data ) then
--         attachment_id = (int) attachment_id;

--         post = get_post( attachment_id );

--         if ( ! post ) then
--                 return False;
--         end;

--         --
--         -- Filters the updated attachment meta data.
--         --
--         -- @since 2.1.0
--         --
--         -- @param array data          Array of updated attachment meta data.
--         -- @param int   attachment_id Attachment post ID.
--         --
--         data = apply_filters( "wp_update_attachment_metadata", data, post.ID );
--         if ( data ) then
--                 return update_post_meta( post.ID, "_wp_attachment_metadata", data );
--         end; else then
--                 return delete_post_meta( post.ID, "_wp_attachment_metadata" );
--         end;
-- end;

--
-- Retrieves the URL for an attachment.
--
-- @since 2.1.0
--
-- @global string pagenow The filename of the current screen.
--
-- @param int attachment_id Optional. Attachment post ID. Defaults to global post.
-- @return string|False Attachment URL, otherwise False.
--
-- function wp_get_attachment_url( attachment_id = 0 ) then
--         global pagenow;

--         attachment_id = (int) attachment_id;

--         post = get_post( attachment_id );

--         if ( ! post ) then
--                 return False;
--         end;

--         if ( "attachment" !== post.post_type ) then
--                 return False;
--         end;

--         url = "";
--         // Get attached file.
--         file = get_post_meta( post.ID, "_wp_attached_file", True );
--         if ( file ) then
--                 // Get upload directory.
--                 uploads = wp_get_upload_dir();
--                 if ( uploads && False === uploads["error"] ) then
--                         // Check that the upload base exists in the file location.
--                         if ( 0 === strpos( file, uploads["basedir"] ) ) then
--                                 // Replace file location with url location.
--                                 url = str_replace( uploads["basedir"], uploads["baseurl"], file );
--                         end; elseif ( False !== strpos( file, "wp-content/uploads" ) ) then
--                                 // Get the directory name relative to the basedir (back compat for pre-2.7 uploads).
--                                 url = trailingslashit( uploads["baseurl"] . "/" . _wp_get_attachment_relative_path( file ) ) . wp_basename( file );
--                         end; else then
--                                 // It"s a newly-uploaded file, therefore file is relative to the basedir.
--                                 url = uploads["baseurl"] . "/file";
--                         end;
--                 end;
--         end;

--         --
--         -- If any of the above options failed, Fallback on the GUID as used pre-2.7,
--         -- not recommended to rely upon this.
--         --
--         if ( ! url ) then
--                 url = get_the_guid( post.ID );
--         end;

--         // On SSL front end, URLs should be HTTPS.
--         if ( is_ssl() && ! is_admin() && "wp-login.php" !== pagenow ) then
--                 url = set_url_scheme( url );
--         end;

--         --
--         -- Filters the attachment URL.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string url           URL for the given attachment.
--         -- @param int    attachment_id Attachment post ID.
--         --
--         url = apply_filters( "wp_get_attachment_url", url, post.ID );

--         if ( ! url ) then
--                 return False;
--         end;

--         return url;
-- end;

--
-- Retrieves the caption for an attachment.
--
-- @since 4.6.0
--
-- @param int post_id Optional. Attachment ID. Default is the ID of the global `post`.
-- @return string|False Attachment caption on success, False on failure.
--
-- function wp_get_attachment_caption( post_id = 0 ) then
--         post_id = (int) post_id;
--         post    = get_post( post_id );

--         if ( ! post ) then
--                 return False;
--         end;

--         if ( "attachment" !== post.post_type ) then
--                 return False;
--         end;

--         caption = post.post_excerpt;

--         --
--         -- Filters the attachment caption.
--         --
--         -- @since 4.6.0
--         --
--         -- @param string caption Caption for the given attachment.
--         -- @param int    post_id Attachment ID.
--         --
--         return apply_filters( "wp_get_attachment_caption", caption, post.ID );
-- end;

--
-- Retrieves URL for an attachment thumbnail.
--
-- @since 2.1.0
-- @since 6.1.0 Changed to use wp_get_attachment_image_url().
--
-- @param int post_id Optional. Attachment ID. Default is the ID of the global `post`.
-- @return string|False Thumbnail URL on success, False on failure.
--
-- function wp_get_attachment_thumb_url( post_id = 0 ) then
--         post_id = (int) post_id;

--         // This uses image_downsize() which also looks for the (very) old format image_meta["thumb"]
--         // when the newer format image_meta["sizes"]["thumbnail"] doesn"t exist.
--         thumbnail_url = wp_get_attachment_image_url( post_id, "thumbnail" );

--         if ( empty( thumbnail_url ) ) then
--                 return False;
--         end;

--         --
--         -- Filters the attachment thumbnail URL.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string thumbnail_url URL for the attachment thumbnail.
--         -- @param int    post_id       Attachment ID.
--         --
--         return apply_filters( "wp_get_attachment_thumb_url", thumbnail_url, post_id );
-- end;

--
-- Verifies an attachment is of a given type.
--
-- @since 4.2.0
--
-- @param string      type Attachment type. Accepts "image", "audio", or "video".
-- @param int|WP_Post post Optional. Attachment ID or object. Default is global post.
-- @return bool True if one of the accepted types, False otherwise.
--
-- function wp_attachment_is( type, post = null ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return False;
--         end;

--         file = get_attached_file( post.ID );

--         if ( ! file ) then
--                 return False;
--         end;

--         if ( 0 === strpos( post.post_mime_type, type . "/" ) ) then
--                 return True;
--         end;

--         check = wp_check_filetype( file );

--         if ( empty( check["ext"] ) ) then
--                 return False;
--         end;

--         ext = check["ext"];

--         if ( "import" !== post.post_mime_type ) then
--                 return type === ext;
--         end;

--         switch ( type ) then
--                 case "image":
--                         image_exts = to_array ( "jpg", "jpeg", "jpe", "gif", "png", "webp" );
--                         return in_to_array ( ext, image_exts, True );

--                 case "audio":
--                         return in_to_array ( ext, wp_get_audio_extensions(), True );

--                 case "video":
--                         return in_to_array ( ext, wp_get_video_extensions(), True );

--                 default:
--                         return type === ext;
--         end;
-- end;

--
-- Determines whether an attachment is an image.
--
-- For more information on this and similar theme functions, check out
-- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 2.1.0
-- @since 4.2.0 Modified into wrapper for wp_attachment_is() and
--              allowed WP_Post object to be passed.
--
-- @param int|WP_Post post Optional. Attachment ID or object. Default is global post.
-- @return bool Whether the attachment is an image.
--
-- function wp_attachment_is_image( post = null ) then
--         return wp_attachment_is( "image", post );
-- end;

--
-- Retrieves the icon for a MIME type or attachment.
--
-- @since 2.1.0
--
-- @param string|int mime MIME type or attachment ID.
-- @return string|False Icon, False otherwise.
--
-- function wp_mime_type_icon( mime = 0 ) then
--         if ( ! is_numeric( mime ) ) then
--                 icon = wp_cache_get( "mime_type_icon_mime" );
--         end;

--         post_id = 0;
--         if ( empty( icon ) ) then
--                 post_mimes = to_array ();
--                 if ( is_numeric( mime ) ) then
--                         mime = (int) mime;
--                         post = get_post( mime );
--                         if ( post ) then
--                                 post_id = (int) post.ID;
--                                 file    = get_attached_file( post_id );
--                                 ext     = preg_replace( "/^.+?\.([^.]+)/", "1", file );
--                                 if ( ! empty( ext ) ) then
--                                         post_mimes[] = ext;
--                                         ext_type     = wp_ext2type( ext );
--                                         if ( ext_type ) then
--                                                 post_mimes[] = ext_type;
--                                         end;
--                                 end;
--                                 mime = post.post_mime_type;
--                         end; else then
--                                 mime = 0;
--                         end;
--                 end; else then
--                         post_mimes[] = mime;
--                 end;

--                 icon_files = wp_cache_get( "icon_files" );

--                 if ( ! is_to_array ( icon_files ) ) then
--                         --
--                         -- Filters the icon directory path.
--                         --
--                         -- @since 2.0.0
--                         --
--                         -- @param string path Icon directory absolute path.
--                         --
--                         icon_dir = apply_filters( "icon_dir", ABSPATH . WPINC . "/images/media" );

--                         --
--                         -- Filters the icon directory URI.
--                         --
--                         -- @since 2.0.0
--                         --
--                         -- @param string uri Icon directory URI.
--                         --
--                         icon_dir_uri = apply_filters( "icon_dir_uri", includes_url( "images/media" ) );

--                         --
--                         -- Filters the array of icon directory URIs.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string[] uris Array of icon directory URIs keyed by directory absolute path.
--                         --
--                         dirs       = apply_filters( "icon_dirs", to_array ( icon_dir => icon_dir_uri ) );
--                         icon_files = to_array ();
--                         while ( dirs ) then
--                                 keys = array_keys( dirs );
--                                 dir  = array_shift( keys );
--                                 uri  = array_shift( dirs );
--                                 dh   = opendir( dir );
--                                 if ( dh ) then
--                                         while ( False !== file = readdir( dh ) ) then
--                                                 file = wp_basename( file );
--                                                 if ( "." === substr( file, 0, 1 ) ) then
--                                                         continue;
--                                                 end;

--                                                 ext = strtolower( substr( file, -4 ) );
--                                                 if ( ! in_to_array ( ext, to_array ( ".png", ".gif", ".jpg" ), True ) ) then
--                                                         if ( is_dir( "dir/file" ) ) then
--                                                                 dirs[ "dir/file" ] = "uri/file";
--                                                         end;
--                                                         continue;
--                                                 end;
--                                                 icon_files[ "dir/file" ] = "uri/file";
--                                         end;
--                                         closedir( dh );
--                                 end;
--                         end;
--                         wp_cache_add( "icon_files", icon_files, "default", 600 );
--                 end;

--                 types = to_array ();
--                 // Icon wp_basename - extension = MIME wildcard.
--                 foreach ( icon_files as file => uri ) then
--                         types[ preg_replace( "/^([^.]*).*/", "1", wp_basename( file ) ) ] =& icon_files[ file ];
--                 end;

--                 if ( ! empty( mime ) ) then
--                         post_mimes[] = substr( mime, 0, strpos( mime, "/" ) );
--                         post_mimes[] = substr( mime, strpos( mime, "/" ) + 1 );
--                         post_mimes[] = str_replace( "/", "_", mime );
--                 end;

--                 matches            = wp_match_mime_types( array_keys( types ), post_mimes );
--                 matches["default"] = to_array ( "default" );

--                 foreach ( matches as match => wilds ) then
--                         foreach ( wilds as wild ) then
--                                 if ( ! isset( types[ wild ] ) ) then
--                                         continue;
--                                 end;

--                                 icon = types[ wild ];
--                                 if ( ! is_numeric( mime ) ) then
--                                         wp_cache_add( "mime_type_icon_mime", icon );
--                                 end;
--                                 break 2;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters the mime type icon.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string icon    Path to the mime type icon.
--         -- @param string mime    Mime type.
--         -- @param int    post_id Attachment ID. Will equal 0 if the function passed
--         --                        the mime type.
--         --
--         return apply_filters( "wp_mime_type_icon", icon, mime, post_id );
-- end;

--
-- Checks for changed slugs for published post objects and save the old slug.
--
-- The function is used when a post object of any type is updated,
-- by comparing the current and previous post objects.
--
-- If the slug was changed and not already part of the old slugs then it will be
-- added to the post meta field ("_wp_old_slug") for storing old slugs for that
-- post.
--
-- The most logically usage of this function is redirecting changed post objects, so
-- that those that linked to an changed post will be redirected to the new post.
--
-- @since 2.1.0
--
-- @param int     post_id     Post ID.
-- @param WP_Post post        The post object.
-- @param WP_Post post_before The previous post object.
--
-- function wp_check_for_changed_slugs( post_id, post, post_before ) then
--         // Don"t bother if it hasn"t changed.
--         if ( post.post_name == post_before.post_name ) then
--                 return;
--         end;

--         // We"re only concerned with published, non-hierarchical objects.
--         if ( ! ( "publish" === post.post_status || ( "attachment" === get_post_type( post ) && "inherit" === post.post_status ) ) || is_post_type_hierarchical( post.post_type ) ) then
--                 return;
--         end;

--         old_slugs = (array) get_post_meta( post_id, "_wp_old_slug" );

--         // If we haven"t added this old slug before, add it now.
--         if ( ! empty( post_before.post_name ) && ! in_to_array ( post_before.post_name, old_slugs, True ) ) then
--                 add_post_meta( post_id, "_wp_old_slug", post_before.post_name );
--         end;

--         // If the new slug was used previously, delete it from the list.
--         if ( in_to_array ( post.post_name, old_slugs, True ) ) then
--                 delete_post_meta( post_id, "_wp_old_slug", post.post_name );
--         end;
-- end;

--
-- Checks for changed dates for published post objects and save the old date.
--
-- The function is used when a post object of any type is updated,
-- by comparing the current and previous post objects.
--
-- If the date was changed and not already part of the old dates then it will be
-- added to the post meta field ("_wp_old_date") for storing old dates for that
-- post.
--
-- The most logically usage of this function is redirecting changed post objects, so
-- that those that linked to an changed post will be redirected to the new post.
--
-- @since 4.9.3
--
-- @param int     post_id     Post ID.
-- @param WP_Post post        The post object.
-- @param WP_Post post_before The previous post object.
--
-- function wp_check_for_changed_dates( post_id, post, post_before ) then
--         previous_date = gmdate( "Y-m-d", strtotime( post_before.post_date ) );
--         new_date      = gmdate( "Y-m-d", strtotime( post.post_date ) );

--         // Don"t bother if it hasn"t changed.
--         if ( new_date == previous_date ) then
--                 return;
--         end;

--         // We"re only concerned with published, non-hierarchical objects.
--         if ( ! ( "publish" === post.post_status || ( "attachment" === get_post_type( post ) && "inherit" === post.post_status ) ) || is_post_type_hierarchical( post.post_type ) ) then
--                 return;
--         end;

--         old_dates = (array) get_post_meta( post_id, "_wp_old_date" );

--         // If we haven"t added this old date before, add it now.
--         if ( ! empty( previous_date ) && ! in_to_array ( previous_date, old_dates, True ) ) then
--                 add_post_meta( post_id, "_wp_old_date", previous_date );
--         end;

--         // If the new slug was used previously, delete it from the list.
--         if ( in_to_array ( new_date, old_dates, True ) ) then
--                 delete_post_meta( post_id, "_wp_old_date", new_date );
--         end;
-- end;

--
-- Retrieves the private post SQL based on capability.
--
-- This function provides a standardized way to appropriately select on the
-- post_status of a post type. The function will return a piece of SQL code
-- that can be added to a WHERE clause; this SQL is constructed to allow all
-- published posts, and all private posts to which the user has access.
--
-- @since 2.2.0
-- @since 4.3.0 Added the ability to pass an array to `post_type`.
--
-- @param string|array post_type Single post type or an array of post types. Currently only supports "post" or "page".
-- @return string SQL code that can be added to a where clause.
--
-- function get_private_posts_cap_sql( post_type ) then
--         return get_posts_by_author_sql( post_type, False );
-- end;

--
-- Retrieves the post SQL based on capability, author, and type.
--
-- @since 3.0.0
-- @since 4.3.0 Introduced the ability to pass an array of post types to `post_type`.
--
-- @see get_private_posts_cap_sql()
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string|string[] post_type   Single post type or an array of post types.
-- @param bool            full        Optional. Returns a full WHERE statement instead of just
--                                     an "andalso" term. Default True.
-- @param int             post_author Optional. Query posts having a single author ID. Default null.
-- @param bool            public_only Optional. Only return public posts. Skips cap checks for
--                                     current_user.  Default False.
-- @return string SQL WHERE code that can be added to a query.
--
-- function get_posts_by_author_sql( post_type, full = True, post_author = null, public_only = False ) then
--         global wpdb;

--         if ( is_to_array ( post_type ) ) then
--                 post_types = post_type;
--         end; else then
--                 post_types = to_array ( post_type );
--         end;

--         post_type_clauses = to_array ();
--         foreach ( post_types as post_type ) then
--                 post_type_obj = get_post_type_object( post_type );

--                 if ( ! post_type_obj ) then
--                         continue;
--                 end;

--                 --
--                 -- Filters the capability to read private posts for a custom post type
--                 -- when generating SQL for getting posts by author.
--                 --
--                 -- @since 2.2.0
--                 -- @deprecated 3.2.0 The hook transitioned from "somewhat useless" to "totally useless".
--                 --
--                 -- @param string cap Capability.
--                 --
--                 cap = apply_filters_deprecated( "pub_priv_sql_capability", to_array ( "" ), "3.2.0" );

--                 if ( ! cap ) then
--                         cap = current_user_can( post_type_obj.cap.read_private_posts );
--                 end;

--                 // Only need to check the cap if public_only is False.
--                 post_status_sql = "post_status = "publish"";

--                 if ( False === public_only ) then
--                         if ( cap ) then
--                                 // Does the user have the capability to view private posts? Guess so.
--                                 post_status_sql .= " OR post_status = "private"";
--                         end; elseif ( is_user_logged_in() ) then
--                                 // Users can view their own private posts.
--                                 id = get_current_user_id();
--                                 if ( null === post_author || ! full ) then
--                                         post_status_sql .= " OR post_status = "private" AND post_author = id";
--                                 end; elseif ( id == (int) post_author ) then
--                                         post_status_sql .= " OR post_status = "private"";
--                                 end; // Else none.
--                         end; // Else none.
--                 end;

--                 post_type_clauses[] = "( post_type = "" . post_type . "" AND ( post_status_sql ) )";
--         end;

--         if ( empty( post_type_clauses ) ) then
--                 return full ? "WHERE 1 = 0" : "1 = 0";
--         end;

--         sql = "( " . implode( " OR ", post_type_clauses ) . " )";

--         if ( null !== post_author ) then
--                 sql .= wpdb.prepare( " AND post_author = %d", post_author );
--         end;

--         if ( full ) then
--                 sql = "WHERE " . sql;
--         end;

--         return sql;
-- end;

--
-- Retrieves the most recent time that a post on the site was published.
--
-- The server timezone is the default and is the difference between GMT and
-- server time. The "blog" value is the date when the last post was posted.
-- The "gmt" is when the last post was posted in GMT formatted date.
--
-- @since 0.71
-- @since 4.4.0 The `post_type` argument was added.
--
-- @param string timezone  Optional. The timezone for the timestamp. Accepts "server", "blog", or "gmt".
--                          "server" uses the server"s internal timezone.
--                          "blog" uses the `post_date` field, which proxies to the timezone set for the site.
--                          "gmt" uses the `post_date_gmt` field.
--                          Default "server".
-- @param string post_type Optional. The post type to check. Default "any".
-- @return string The date of the last post, or False on failure.
--
-- function get_lastpostdate( timezone = "server", post_type = "any" ) then
--         lastpostdate = _get_last_post_time( timezone, "date", post_type );

--         --
--         -- Filters the most recent time that a post on the site was published.
--         --
--         -- @since 2.3.0
--         -- @since 5.5.0 Added the `post_type` parameter.
--         --
--         -- @param string|False lastpostdate The most recent time that a post was published,
--         --                                   in "Y-m-d H:i:s" format. False on failure.
--         -- @param string       timezone     Location to use for getting the post published date.
--         --                                   See get_lastpostdate() for accepted `timezone` values.
--         -- @param string       post_type    The post type to check.
--         --
--         return apply_filters( "get_lastpostdate", lastpostdate, timezone, post_type );
-- end;

--
-- Gets the most recent time that a post on the site was modified.
--
-- The server timezone is the default and is the difference between GMT and
-- server time. The "blog" value is just when the last post was modified.
-- The "gmt" is when the last post was modified in GMT time.
--
-- @since 1.2.0
-- @since 4.4.0 The `post_type` argument was added.
--
-- @param string timezone  Optional. The timezone for the timestamp. See get_lastpostdate()
--                          for information on accepted values.
--                          Default "server".
-- @param string post_type Optional. The post type to check. Default "any".
-- @return string The timestamp in "Y-m-d H:i:s" format, or False on failure.
--
-- function get_lastpostmodified( timezone = "server", post_type = "any" ) then
--         --
--         -- Pre-filter the return value of get_lastpostmodified() before the query is run.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string|False lastpostmodified The most recent time that a post was modified,
--         --                                       in "Y-m-d H:i:s" format, or False. Returning anything
--         --                                       other than False will short-circuit the function.
--         -- @param string       timezone         Location to use for getting the post modified date.
--         --                                       See get_lastpostdate() for accepted `timezone` values.
--         -- @param string       post_type        The post type to check.
--         --
--         lastpostmodified = apply_filters( "pre_get_lastpostmodified", False, timezone, post_type );

--         if ( False !== lastpostmodified ) then
--                 return lastpostmodified;
--         end;

--         lastpostmodified = _get_last_post_time( timezone, "modified", post_type );
--         lastpostdate     = get_lastpostdate( timezone, post_type );

--         if ( lastpostdate > lastpostmodified ) then
--                 lastpostmodified = lastpostdate;
--         end;

--         --
--         -- Filters the most recent time that a post on the site was modified.
--         --
--         -- @since 2.3.0
--         -- @since 5.5.0 Added the `post_type` parameter.
--         --
--         -- @param string|False lastpostmodified The most recent time that a post was modified,
--         --                                       in "Y-m-d H:i:s" format. False on failure.
--         -- @param string       timezone         Location to use for getting the post modified date.
--         --                                       See get_lastpostdate() for accepted `timezone` values.
--         -- @param string       post_type        The post type to check.
--         --
--         return apply_filters( "get_lastpostmodified", lastpostmodified, timezone, post_type );
-- end;

--
-- Gets the timestamp of the last time any post was modified or published.
--
-- @since 3.1.0
-- @since 4.4.0 The `post_type` argument was added.
-- @access private
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string timezone  The timezone for the timestamp. See get_lastpostdate().
--                          for information on accepted values.
-- @param string field     Post field to check. Accepts "date" or "modified".
-- @param string post_type Optional. The post type to check. Default "any".
-- @return string|False The timestamp in "Y-m-d H:i:s" format, or False on failure.
--
-- function _get_last_post_time( timezone, field, post_type = "any" ) then
--         global wpdb;

--         if ( ! in_to_array ( field, to_array ( "date", "modified" ), True ) ) then
--                 return False;
--         end;

--         timezone = strtolower( timezone );

--         key = "lastpostthenfieldend;:timezone";
--         if ( "any" !== post_type ) then
--                 key .= ":" . sanitize_key( post_type );
--         end;

--         date = wp_cache_get( key, "timeinfo" );
--         if ( False !== date ) then
--                 return date;
--         end;

--         if ( "any" === post_type ) then
--                 post_types = get_post_types( to_array ( "public" => True ) );
--                 array_walk( post_types, to_array ( wpdb, "escape_by_ref" ) );
--                 post_types = """ . implode( "", "", post_types ) . """;
--         end; else then
--                 post_types = """ . sanitize_key( post_type ) . """;
--         end;

--         switch ( timezone ) then
--                 case "gmt":
--                         date = wpdb.get_var( "SELECT post_thenfieldend;_gmt FROM wpdb.posts WHERE post_status = "publish" AND post_type IN (thenpost_typesend;) ORDER BY post_thenfieldend;_gmt DESC LIMIT 1" );
--                         break;
--                 case "blog":
--                         date = wpdb.get_var( "SELECT post_thenfieldend; FROM wpdb.posts WHERE post_status = "publish" AND post_type IN (thenpost_typesend;) ORDER BY post_thenfieldend;_gmt DESC LIMIT 1" );
--                         break;
--                 case "server":
--                         add_seconds_server = gmdate( "Z" );
--                         date               = wpdb.get_var( "SELECT DATE_ADD(post_thenfieldend;_gmt, INTERVAL "add_seconds_server" SECOND) FROM wpdb.posts WHERE post_status = "publish" AND post_type IN (thenpost_typesend;) ORDER BY post_thenfieldend;_gmt DESC LIMIT 1" );
--                         break;
--         end;

--         if ( date ) then
--                 wp_cache_set( key, date, "timeinfo" );

--                 return date;
--         end;

--         return False;
-- end;

--
-- Updates posts in cache.
--
-- @since 1.5.1
--
-- @param WP_Post[] posts Array of post objects (passed by reference).
--
-- function update_post_cache( &posts ) then
--         if ( ! posts ) then
--                 return;
--         end;

--         data = to_array ();
--         foreach ( posts as post ) then
--                 if ( empty( post.filter ) || "raw" !== post.filter ) then
--                         post = sanitize_post( post, "raw" );
--                 end;
--                 data[ post.ID ] = post;
--         end;
--         wp_cache_add_multiple( data, "posts" );
-- end;

--
-- Will clean the post in the cache.
--
-- Cleaning means delete from the cache of the post. Will call to clean the term
-- object cache associated with the post ID.
--
-- This function not run if _wp_suspend_cache_invalidation is not empty. See
-- wp_suspend_cache_invalidation().
--
-- @since 2.0.0
--
-- @global bool _wp_suspend_cache_invalidation
--
-- @param int|WP_Post post Post ID or post object to remove from the cache.
--
-- function clean_post_cache( post ) then
--         global _wp_suspend_cache_invalidation;

--         if ( ! empty( _wp_suspend_cache_invalidation ) ) then
--                 return;
--         end;

--         post = get_post( post );

--         if ( ! post ) then
--                 return;
--         end;

--         wp_cache_delete( post.ID, "posts" );
--         wp_cache_delete( post.ID, "post_meta" );

--         clean_object_term_cache( post.ID, post.post_type );

--         wp_cache_delete( "wp_get_archives", "general" );

--         --
--         -- Fires immediately after the given post"s cache is cleaned.
--         --
--         -- @since 2.5.0
--         --
--         -- @param int     post_id Post ID.
--         -- @param WP_Post post    Post object.
--         --
--         do_action( "clean_post_cache", post.ID, post );

--         if ( "page" === post.post_type ) then
--                 wp_cache_delete( "all_page_ids", "posts" );

--                 --
--                 -- Fires immediately after the given page"s cache is cleaned.
--                 --
--                 -- @since 2.5.0
--                 --
--                 -- @param int post_id Post ID.
--                 --
--                 do_action( "clean_page_cache", post.ID );
--         end;

--         wp_cache_set( "last_changed", microtime(), "posts" );
-- end;

--
-- Updates post, term, and metadata caches for a list of post objects.
--
-- @since 1.5.0
--
-- @param WP_Post[] posts             Array of post objects (passed by reference).
-- @param string    post_type         Optional. Post type. Default "post".
-- @param bool      update_term_cache Optional. Whether to update the term cache. Default True.
-- @param bool      update_meta_cache Optional. Whether to update the meta cache. Default True.
--
-- function update_post_caches( &posts, post_type = "post", update_term_cache = True, update_meta_cache = True ) then
--         // No point in doing all this work if we didn"t match any posts.
--         if ( ! posts ) then
--                 return;
--         end;

--         update_post_cache( posts );

--         post_ids = to_array ();
--         foreach ( posts as post ) then
--                 post_ids[] = post.ID;
--         end;

--         if ( ! post_type ) then
--                 post_type = "any";
--         end;

--         if ( update_term_cache ) then
--                 if ( is_to_array ( post_type ) ) then
--                         ptypes = post_type;
--                 end; elseif ( "any" === post_type ) then
--                         ptypes = to_array ();
--                         // Just use the post_types in the supplied posts.
--                         foreach ( posts as post ) then
--                                 ptypes[] = post.post_type;
--                         end;
--                         ptypes = array_unique( ptypes );
--                 end; else then
--                         ptypes = to_array ( post_type );
--                 end;

--                 if ( ! empty( ptypes ) ) then
--                         update_object_term_cache( post_ids, ptypes );
--                 end;
--         end;

--         if ( update_meta_cache ) then
--                 update_postmeta_cache( post_ids );
--         end;
-- end;

--
-- Updates post author user caches for a list of post objects.
--
-- @since 6.1.0
--
-- @param WP_Post[] posts Array of post objects.
--
-- function update_post_author_caches( posts ) then
--         --
--         -- cache_users() is a pluggable function so is not available prior
--         -- to the `plugins_loaded` hook firing. This is to ensure against
--         -- fatal errors when the function is not available.
--         --
--         if ( ! function_exists( "cache_users" ) ) then
--                 return;
--         end;

--         author_ids = wp_list_pluck( posts, "post_author" );
--         author_ids = array_map( "absint", author_ids );
--         author_ids = array_unique( array_filter( author_ids ) );

--         cache_users( author_ids );
-- end;

--
-- Updates parent post caches for a list of post objects.
--
-- @since 6.1.0
--
-- @param WP_Post[] posts Array of post objects.
--
-- function update_post_parent_caches( posts ) then
--         parent_ids = wp_list_pluck( posts, "post_parent" );
--         parent_ids = array_map( "absint", parent_ids );
--         parent_ids = array_unique( array_filter( parent_ids ) );

--         if ( ! empty( parent_ids ) ) then
--                 _prime_post_caches( parent_ids, False );
--         end;
-- end;

--
-- Updates metadata cache for a list of post IDs.
--
-- Performs SQL query to retrieve the metadata for the post IDs and updates the
-- metadata cache for the posts. Therefore, the functions, which call this
-- function, do not need to perform SQL queries on their own.
--
-- @since 2.1.0
--
-- @param int[] post_ids Array of post IDs.
-- @return array|False An array of metadata on success, False if there is nothing to update.
--
-- function update_postmeta_cache( post_ids ) then
--         return update_meta_cache( "post", post_ids );
-- end;

--
-- Will clean the attachment in the cache.
--
-- Cleaning means delete from the cache. Optionally will clean the term
-- object cache associated with the attachment ID.
--
-- This function will not run if _wp_suspend_cache_invalidation is not empty.
--
-- @since 3.0.0
--
-- @global bool _wp_suspend_cache_invalidation
--
-- @param int  id          The attachment ID in the cache to clean.
-- @param bool clean_terms Optional. Whether to clean terms cache. Default False.
--
-- function clean_attachment_cache( id, clean_terms = False ) then
--         global _wp_suspend_cache_invalidation;

--         if ( ! empty( _wp_suspend_cache_invalidation ) ) then
--                 return;
--         end;

--         id = (int) id;

--         wp_cache_delete( id, "posts" );
--         wp_cache_delete( id, "post_meta" );

--         if ( clean_terms ) then
--                 clean_object_term_cache( id, "attachment" );
--         end;

--         --
--         -- Fires after the given attachment"s cache is cleaned.
--         --
--         -- @since 3.0.0
--         --
--         -- @param int id Attachment ID.
--         --
--         do_action( "clean_attachment_cache", id );
-- end;

--
-- Hooks.
--

--
-- Hook for managing future post transitions to published.
--
-- @since 2.3.0
-- @access private
--
-- @see wp_clear_scheduled_hook()
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string  new_status New post status.
-- @param string  old_status Previous post status.
-- @param WP_Post post       Post object.
--
-- function _transition_post_status( new_status, old_status, post ) then
--         global wpdb;

--         if ( "publish" !== old_status && "publish" === new_status ) then
--                 // Reset GUID if transitioning to publish and it is empty.
--                 if ( "" === get_the_guid( post.ID ) ) then
--                         wpdb.update( wpdb.posts, to_array ( "guid" => get_permalink( post.ID ) ), to_array ( "ID" => post.ID ) );
--                 end;

--                 --
--                 -- Fires when a post"s status is transitioned from private to published.
--                 --
--                 -- @since 1.5.0
--                 -- @deprecated 2.3.0 Use then@see "private_to_publish"end; instead.
--                 --
--                 -- @param int post_id Post ID.
--                 --
--                 do_action_deprecated( "private_to_published", to_array ( post.ID ), "2.3.0", "private_to_publish" );
--         end;

--         // If published posts changed clear the lastpostmodified cache.
--         if ( "publish" === new_status || "publish" === old_status ) then
--                 foreach ( to_array ( "server", "gmt", "blog" ) as timezone ) then
--                         wp_cache_delete( "lastpostmodified:timezone", "timeinfo" );
--                         wp_cache_delete( "lastpostdate:timezone", "timeinfo" );
--                         wp_cache_delete( "lastpostdate:timezone:thenpost.post_typeend;", "timeinfo" );
--                 end;
--         end;

--         if ( new_status !== old_status ) then
--                 wp_cache_delete( _count_posts_cache_key( post.post_type ), "counts" );
--                 wp_cache_delete( _count_posts_cache_key( post.post_type, "readable" ), "counts" );
--         end;

--         // Always clears the hook in case the post status bounced from future to draft.
--         wp_clear_scheduled_hook( "publish_future_post", to_array ( post.ID ) );
-- end;

--
-- Hook used to schedule publication for a post marked for the future.
--
-- The post properties used and must exist are "ID" and "post_date_gmt".
--
-- @since 2.3.0
-- @access private
--
-- @param int     deprecated Not used. Can be set to null. Never implemented. Not marked
--                            as deprecated with _deprecated_argument() as it conflicts with
--                            wp_transition_post_status() and the default filter for _future_post_hook().
-- @param WP_Post post       Post object.
--
-- function _future_post_hook( deprecated, post ) then
--         wp_clear_scheduled_hook( "publish_future_post", to_array ( post.ID ) );
--         wp_schedule_single_event( strtotime( get_gmt_from_date( post.post_date ) . " GMT" ), "publish_future_post", to_array ( post.ID ) );
-- end;

--
-- Hook to schedule pings and enclosures when a post is published.
--
-- Uses XMLRPC_REQUEST and WP_IMPORTING constants.
--
-- @since 2.3.0
-- @access private
--
-- @param int post_id The ID of the post being published.
--
-- function _publish_post_hook( post_id ) then
--         if ( defined( "XMLRPC_REQUEST" ) ) then
--                 --
--                 -- Fires when _publish_post_hook() is called during an XML-RPC request.
--                 --
--                 -- @since 2.1.0
--                 --
--                 -- @param int post_id Post ID.
--                 --
--                 do_action( "xmlrpc_publish_post", post_id );
--         end;

--         if ( defined( "WP_IMPORTING" ) ) then
--                 return;
--         end;

--         if ( get_option( "default_pingback_flag" ) ) then
--                 add_post_meta( post_id, "_pingme", "1", True );
--         end;
--         add_post_meta( post_id, "_encloseme", "1", True );

--         to_ping = get_to_ping( post_id );
--         if ( ! empty( to_ping ) ) then
--                 add_post_meta( post_id, "_trackbackme", "1" );
--         end;

--         if ( ! wp_next_scheduled( "do_pings" ) ) then
--                 wp_schedule_single_event( time(), "do_pings" );
--         end;
-- end;

--
-- Returns the ID of the post"s parent.
--
-- @since 3.1.0
-- @since 5.9.0 The `post` parameter was made optional.
--
-- @param int|WP_Post|null post Optional. Post ID or post object. Defaults to global post.
-- @return int|False Post parent ID (which can be 0 if there is no parent),
--                   or False if the post does not exist.
--
-- function wp_get_post_parent_id( post = null ) then
--         post = get_post( post );

--         if ( ! post || is_wp_error( post ) ) then
--                 return False;
--         end;

--         return (int) post.post_parent;
-- end;

--
-- Checks the given subset of the post hierarchy for hierarchy loops.
--
-- Prevents loops from forming and breaks those that it finds. Attached
-- to the then@see "wp_insert_post_parent"end; filter.
--
-- @since 3.1.0
--
-- @see wp_find_hierarchy_loop()
--
-- @param int post_parent ID of the parent for the post we"re checking.
-- @param int post_ID     ID of the post we"re checking.
-- @return int The new post_parent for the post, 0 otherwise.
--
-- function wp_check_post_hierarchy_for_loops( post_parent, post_ID ) then
--         // Nothing fancy here - bail.
--         if ( ! post_parent ) then
--                 return 0;
--         end;

--         // New post can"t cause a loop.
--         if ( ! post_ID ) then
--                 return post_parent;
--         end;

--         // Can"t be its own parent.
--         if ( post_parent == post_ID ) then
--                 return 0;
--         end;

--         // Now look for larger loops.
--         loop = wp_find_hierarchy_loop( "wp_get_post_parent_id", post_ID, post_parent );
--         if ( ! loop ) then
--                 return post_parent; // No loop.
--         end;

--         // Setting post_parent to the given value causes a loop.
--         if ( isset( loop[ post_ID ] ) ) then
--                 return 0;
--         end;

--         // There"s a loop, but it doesn"t contain post_ID. Break the loop.
--         foreach ( array_keys( loop ) as loop_member ) then
--                 wp_update_post(
--                         to_array (
--                                 "ID"          => loop_member,
--                                 "post_parent" => 0,
--                         )
--                 );
--         end;

--         return post_parent;
-- end;

--
-- Sets the post thumbnail (featured image) for the given post.
--
-- @since 3.1.0
--
-- @param int|WP_Post post         Post ID or post object where thumbnail should be attached.
-- @param int         thumbnail_id Thumbnail to attach.
-- @return int|bool True on success, False on failure.
--
-- function set_post_thumbnail( post, thumbnail_id ) then
--         post         = get_post( post );
--         thumbnail_id = absint( thumbnail_id );
--         if ( post && thumbnail_id && get_post( thumbnail_id ) ) then
--                 if ( wp_get_attachment_image( thumbnail_id, "thumbnail" ) ) then
--                         return update_post_meta( post.ID, "_thumbnail_id", thumbnail_id );
--                 end; else then
--                         return delete_post_meta( post.ID, "_thumbnail_id" );
--                 end;
--         end;
--         return False;
-- end;

--
-- Removes the thumbnail (featured image) from the given post.
--
-- @since 3.3.0
--
-- @param int|WP_Post post Post ID or post object from which the thumbnail should be removed.
-- @return bool True on success, False on failure.
--
-- function delete_post_thumbnail( post ) then
--         post = get_post( post );
--         if ( post ) then
--                 return delete_post_meta( post.ID, "_thumbnail_id" );
--         end;
--         return False;
-- end;

--
-- Deletes auto-drafts for new posts that are > 7 days old.
--
-- @since 3.4.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- function wp_delete_auto_drafts() then
--         global wpdb;

--         // Cleanup old auto-drafts more than 7 days old.
--         old_posts = wpdb.get_col( "SELECT ID FROM wpdb.posts WHERE post_status = "auto-draft" AND DATE_SUB( NOW(), INTERVAL 7 DAY ) > post_date" );
--         foreach ( (array) old_posts as delete ) then
--                 // Force delete.
--                 wp_delete_post( delete, True );
--         end;
-- end;

--
-- Queues posts for lazy-loading of term meta.
--
-- @since 4.5.0
--
-- @param WP_Post[] posts Array of WP_Post objects.
--
-- function wp_queue_posts_for_term_meta_lazyload( posts ) then
--         post_type_taxonomies = to_array ();
--         term_ids             = to_array ();
--         foreach ( posts as post ) then
--                 if ( ! ( post instanceof WP_Post ) ) then
--                         continue;
--                 end;

--                 if ( ! isset( post_type_taxonomies[ post.post_type ] ) ) then
--                         post_type_taxonomies[ post.post_type ] = get_object_taxonomies( post.post_type );
--                 end;

--                 foreach ( post_type_taxonomies[ post.post_type ] as taxonomy ) then
--                         // Term cache should already be primed by `update_post_term_cache()`.
--                         terms = get_object_term_cache( post.ID, taxonomy );
--                         if ( False !== terms ) then
--                                 foreach ( terms as term ) then
--                                         if ( ! in_to_array ( term.term_id, term_ids, True ) ) then
--                                                 term_ids[] = term.term_id;
--                                         end;
--                                 end;
--                         end;
--                 end;
--         end;

--         if ( term_ids ) then
--                 lazyloader = wp_metadata_lazyloader();
--                 lazyloader.queue_objects( "term", term_ids );
--         end;
-- end;

--
-- Updates the custom taxonomies" term counts when a post"s status is changed.
--
-- For example, default posts term counts (for custom taxonomies) don"t include
-- private / draft posts.
--
-- @since 3.3.0
-- @access private
--
-- @param string  new_status New post status.
-- @param string  old_status Old post status.
-- @param WP_Post post       Post object.
--
-- function _update_term_count_on_transition_post_status( new_status, old_status, post ) then
--         // Update counts for the post"s terms.
--         foreach ( (array) get_object_taxonomies( post.post_type ) as taxonomy ) then
--                 tt_ids = wp_get_object_terms( post.ID, taxonomy, to_array ( "fields" => "tt_ids" ) );
--                 wp_update_term_count( tt_ids, taxonomy );
--         end;
-- end;

--
-- Adds any posts from the given IDs to the cache that do not already exist in cache.
--
-- @since 3.4.0
-- @since 6.1.0 This function is no longer marked as "private".
--
-- @see update_post_caches()
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int[] ids               ID list.
-- @param bool  update_term_cache Optional. Whether to update the term cache. Default True.
-- @param bool  update_meta_cache Optional. Whether to update the meta cache. Default True.
--
-- function _prime_post_caches( ids, update_term_cache = True, update_meta_cache = True ) then
--         global wpdb;

--         non_cached_ids = _get_non_cached_ids( ids, "posts" );
--         if ( ! empty( non_cached_ids ) ) then
--                 fresh_posts = wpdb.get_results( sprintf( "SELECT wpdb.posts.* FROM wpdb.posts WHERE ID IN (%s)", implode( ",", non_cached_ids ) ) );

--                 update_post_caches( fresh_posts, "any", update_term_cache, update_meta_cache );
--         end;
-- end;

--
-- Adds a suffix if any trashed posts have a given slug.
--
-- Store its desired (i.e. current) slug so it can try to reclaim it
-- if the post is untrashed.
--
-- For internal use.
--
-- @since 4.5.0
-- @access private
--
-- @param string post_name Post slug.
-- @param int    post_ID   Optional. Post ID that should be ignored. Default 0.
--
-- function wp_add_trashed_suffix_to_post_name_for_trashed_posts( post_name, post_ID = 0 ) then
--         trashed_posts_with_desired_slug = get_posts(
--                 to_array (
--                         "name"         => post_name,
--                         "post_status"  => "trash",
--                         "post_type"    => "any",
--                         "nopaging"     => True,
--                         "postabsnot_in" => to_array ( post_ID ),
--                 )
--         );

--         if ( ! empty( trashed_posts_with_desired_slug ) ) then
--                 foreach ( trashed_posts_with_desired_slug as _post ) then
--                         wp_add_trashed_suffix_to_post_name_for_post( _post );
--                 end;
--         end;
-- end;

--
-- Adds a trashed suffix for a given post.
--
-- Store its desired (i.e. current) slug so it can try to reclaim it
-- if the post is untrashed.
--
-- For internal use.
--
-- @since 4.5.0
-- @access private
--
-- @param WP_Post post The post.
-- @return string New slug for the post.
--
-- function wp_add_trashed_suffix_to_post_name_for_post( post ) then
--         global wpdb;

--         post = get_post( post );

--         if ( "abstrashed" === substr( post.post_name, -9 ) ) then
--                 return post.post_name;
--         end;
--         add_post_meta( post.ID, "_wp_desired_post_slug", post.post_name );
--         post_name = _truncate_post_slug( post.post_name, 191 ) . "__trashed";
--         wpdb.update( wpdb.posts, to_array ( "post_name" => post_name ), to_array ( "ID" => post.ID ) );
--         clean_post_cache( post.ID );
--         return post_name;
-- end;

--
-- Sets the last changed time for the "posts" cache group.
--
-- @since 5.0.0
--
-- function wp_cache_set_posts_last_changed() then
--         wp_cache_set( "last_changed", microtime(), "posts" );
-- end;

--
-- Gets all available post MIME types for a given post type.
--
-- @since 2.5.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string type
-- @return string[] An array of MIME types.
--
-- function get_available_post_mime_types( type = "attachment" ) then
--         global wpdb;

--         types = wpdb.get_col( wpdb.prepare( "SELECT DISTINCT post_mime_type FROM wpdb.posts WHERE post_type = %s", type ) );
--         return types;
-- end;

--
-- Retrieves the path to an uploaded image file.
--
-- Similar to `get_attached_file()` however some images may have been processed after uploading
-- to make them suitable for web use. In this case the attached "full" size file is usually replaced
-- with a scaled down version of the original image. This function always returns the path
-- to the originally uploaded image file.
--
-- @since 5.3.0
-- @since 5.4.0 Added the `unfiltered` parameter.
--
-- @param int  attachment_id Attachment ID.
-- @param bool unfiltered Optional. Passed through to `get_attached_file()`. Default False.
-- @return string|False Path to the original image file or False if the attachment is not an image.
--
-- function wp_get_original_image_path( attachment_id, unfiltered = False ) then
--         if ( ! wp_attachment_is_image( attachment_id ) ) then
--                 return False;
--         end;

--         image_meta = wp_get_attachment_metadata( attachment_id );
--         image_file = get_attached_file( attachment_id, unfiltered );

--         if ( empty( image_meta["original_image"] ) ) then
--                 original_image = image_file;
--         end; else then
--                 original_image = path_join( dirname( image_file ), image_meta["original_image"] );
--         end;

--         --
--         -- Filters the path to the original image.
--         --
--         -- @since 5.3.0
--         --
--         -- @param string original_image Path to original image file.
--         -- @param int    attachment_id  Attachment ID.
--         --
--         return apply_filters( "wp_get_original_image_path", original_image, attachment_id );
-- end;

--
-- Retrieves the URL to an original attachment image.
--
-- Similar to `wp_get_attachment_url()` however some images may have been
-- processed after uploading. In this case this function returns the URL
-- to the originally uploaded image file.
--
-- @since 5.3.0
--
-- @param int attachment_id Attachment post ID.
-- @return string|False Attachment image URL, False on error or if the attachment is not an image.
--
-- function wp_get_original_image_url( attachment_id ) then
--         if ( ! wp_attachment_is_image( attachment_id ) ) then
--                 return False;
--         end;

--         image_url = wp_get_attachment_url( attachment_id );

--         if ( ! image_url ) then
--                 return False;
--         end;

--         image_meta = wp_get_attachment_metadata( attachment_id );

--         if ( empty( image_meta["original_image"] ) ) then
--                 original_image_url = image_url;
--         end; else then
--                 original_image_url = path_join( dirname( image_url ), image_meta["original_image"] );
--         end;

--         --
--         -- Filters the URL to the original attachment image.
--         --
--         -- @since 5.3.0
--         --
--         -- @param string original_image_url URL to original image.
--         -- @param int    attachment_id      Attachment ID.
--         --
--         return apply_filters( "wp_get_original_image_url", original_image_url, attachment_id );
-- end;

--
-- Filters callback which sets the status of an untrashed post to its previous status.
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
-- function wp_untrash_post_set_previous_status( new_status, post_id, previous_status ) then
--         return previous_status;
-- end;

--
-- Returns whether the post can be edited in the block editor.
--
-- @since 5.0.0
-- @since 6.1.0 Moved to wp-includes from wp-admin.
--
-- @param int|WP_Post post Post ID or WP_Post object.
-- @return bool Whether the post can be edited in the block editor.
--
-- function use_block_editor_for_post( post ) then
--         post = get_post( post );

--         if ( ! post ) then
--                 return False;
--         end;

--         // We"re in the meta box loader, so don"t use the block editor.
--         if ( is_admin() && isset( _GET["meta-box-loader"] ) ) then
--                 check_admin_referer( "meta-box-loader", "meta-box-loader-nonce" );
--                 return False;
--         end;

--         use_block_editor = use_block_editor_for_post_type( post.post_type );

--         --
--         -- Filters whether a post is able to be edited in the block editor.
--         --
--         -- @since 5.0.0
--         --
--         -- @param bool    use_block_editor Whether the post can be edited or not.
--         -- @param WP_Post post             The post being checked.
--         --
--         return apply_filters( "use_block_editor_for_post", use_block_editor, post );
-- end;

--
-- Returns whether a post type is compatible with the block editor.
--
-- The block editor depends on the REST API, and if the post type is not shown in the
-- REST API, then it won"t work with the block editor.
--
-- @since 5.0.0
-- @since 6.1.0 Moved to wp-includes from wp-admin.
--
-- @param string post_type The post type.
-- @return bool Whether the post type can be edited with the block editor.
--
-- function use_block_editor_for_post_type( post_type ) then
--         if ( ! post_type_exists( post_type ) ) then
--                 return False;
--         end;

--         if ( ! post_type_supports( post_type, "editor" ) ) then
--                 return False;
--         end;

--         post_type_object = get_post_type_object( post_type );
--         if ( post_type_object && ! post_type_object.show_in_rest ) then
--                 return False;
--         end;

--         --
--         -- Filters whether a post is able to be edited in the block editor.
--         --
--         -- @since 5.0.0
--         --
--         -- @param bool   use_block_editor  Whether the post type can be edited or not. Default True.
--         -- @param string post_type         The post type being checked.
--         --
--         return apply_filters( "use_block_editor_for_post_type", True, post_type );
-- end;




end Inc_Posts;
