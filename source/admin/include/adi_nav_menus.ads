--
-- Core Navigation Menu API
--
-- @package WordPress
-- @subpackage Nav_Menus
-- @since 3.0.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Ordered_Maps;

with Arrays;

with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;

package Adi_Nav_Menus
is
   use Arrays;

   -- Wp_Meta_Boxes ("nav-menus") (Context) (Priority)

   package Priority_Maps is new
      Ada.Containers.Ordered_Maps (Key_Type     => Integer,
                                   Element_Type => Array_Type,
                                   "="          => Array_Vectors."=");
   package Context_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => Priority_Maps.Map,
                                              "="          => Priority_Maps."=");
   package Meta_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => Context_Maps.Map,
                                              "="          => Context_Maps."=");

   Wp_Meta_Boxes               : Meta_Maps.Map; -- Array_Type;
   One_Theme_Location_No_Menus : Boolean;
   X_Nav_Menu_Placeholder      : Integer;
   Nav_Menu_Selected_Id        : Boolean;
   --
   -- Prints the appropriate response to a menu quick search.
   --
   -- @since 3.0.0
   --
   -- @param array request The unsanitized request values.
   --
   procedure X_Wp_Ajax_Menu_Quick_Search (Request : Array_Type := Empty_Array);

   --
   -- Register nav menu meta boxes and advanced menu items.
   --
   -- @since 3.0.0
   --
   procedure Wp_Nav_Menu_Setup;

   --
   -- Limit the amount of meta boxes to pages, posts, links, and categories for first time users.
   --
   -- @since 3.0.0
   --
   -- @global array wp_meta_boxes
   --
   procedure Wp_Initial_Nav_Menu_Meta_Boxes;

   --
   -- Creates meta boxes for any post type menu item..
   --
   -- @since 3.0.0
   --
   procedure Wp_Nav_Menu_Post_Type_Meta_Boxes;

   --
   -- Creates meta boxes for any taxonomy menu item.
   --
   -- @since 3.0.0
   --
   procedure Wp_Nav_Menu_Taxonomy_Meta_Boxes;

   --
   -- Check whether to disable the Menu Locations meta box submit button and inputs.
   --
   -- @since 3.6.0
   -- @since 5.3.1 The `display` parameter was added.
   --
   -- @global bool one_theme_location_no_menus to determine if no menus exist
   --
   -- @param int|string nav_menu_selected_id ID, name, or slug of the currently selected menu.
   -- @param bool       display              Whether to display or just return the string.
   -- @return string|false Disabled attribute if at least one menu exists, false if not.
   --
   function Wp_Nav_Menu_Disabled_Check (Nav_Menu_Selected_Id : String;
                                        Display              : Boolean := True)
                                        return String;

   --
   -- Displays a meta box for the custom links menu item.
   --
   -- @since 3.0.0
   --
   -- @global int        _nav_menu_placeholder
   -- @global int|string nav_menu_selected_id
   --
   procedure Wp_Nav_Menu_Item_Link_Meta_Box;

   --
   -- Displays a meta box for a post type menu item.
   --
   -- @since 3.0.0
   --
   -- @global int        _nav_menu_placeholder
   -- @global int|string nav_menu_selected_id
   --
   -- @param string data_object Not used.
   -- @param array  box {
   --     Post type menu item meta box arguments.
   --
   --     @type string       id       Meta box "id" attribute.
   --     @type string       title    Meta box title.
   --     @type callable     callback Meta box display callback.
   --     @type WP_Post_Type args     Extra meta box arguments (the post type object for this meta box).
   -- }
   --
   function Wp_Nav_Menu_Item_Post_Type_Meta_Box (Data_Object : String;
                                                 Box         : Array_Type)
                                                 return Array_Type;

   --
   -- Displays a meta box for a taxonomy menu item.
   --
   -- @since 3.0.0
   --
   -- @global int|string nav_menu_selected_id
   --
   -- @param string data_object Not used.
   -- @param array  box then
   --     Taxonomy menu item meta box arguments.
   --
   --     @type string   id       Meta box "id" attribute.
   --     @type string   title    Meta box title.
   --     @type callable callback Meta box display callback.
   --     @type object   args     Extra meta box arguments (the taxonomy object for this meta box).
   -- end;
   --
   procedure Wp_Nav_Menu_Item_Taxonomy_Meta_Box (Data_Object : String;
                                                 Box         : Array_Type);

   --
   -- Save posted nav menu item data.
   --
   -- @since 3.0.0
   --
   -- @param int     menu_id   The menu ID for which to save this item. Value of 0
   --                          makes a draft, orphaned menu item. Default 0.
   -- @param array() menu_data The unsanitized POSTed menu item data.
   -- @return int() The database IDs of the items saved
   --
   function Wp_Save_Nav_Menu_Items (Menu_Id   : Integer    := 0;
                                    Menu_Data : Array_Type := Empty_Array)
                                    return Integer; -- (_Array)

   --
   -- Adds custom arguments to some of the meta box object types.
   --
   -- @since 3.0.0
   --
   -- @access private
   --
   -- @param object data_object The post type or taxonomy meta-object.
   -- @return object The post type or taxonomy object.
   --
   function X_Wp_Nav_Menu_Meta_Box_Object (Data_Object : Array_Type) -- := null)
                                           return Array_Type;

   function X_Wp_Nav_Menu_Meta_Box_Object (Data_Object : Inc_Class_Wp_Posts.Wp_Post)
                                           return Array_Type
                                           is (Empty_Array);

   function X_Wp_Nav_Menu_Meta_Box_Object
     (Data_Object : Inc_Class_Wp_Post_Type.Wp_Post_Type)
      return Inc_Class_Wp_Posts.Wp_Post
      is (Inc_Class_Wp_Posts.Null_Post);

   --
   -- Returns the menu formatted to edit.
   --
   -- @since 3.0.0
   --
   -- @param int menu_id Optional. The ID of the menu to format. Default 0.
   -- @return string|WP_Error The menu formatted to edit or error object on failure.
   --
   function Wp_Get_Nav_Menu_To_Edit (Menu_Id : Integer := 0)
                                     return String;

   --
   -- Returns the columns for the nav menus page.
   --
   -- @since 3.0.0
   --
   -- @return string() Array of column titles keyed by their column name.
   --
   function Wp_Nav_Menu_Manage_Columns
            return Array_Type;

   --
   -- Deletes orphaned draft menu items
   --
   -- @access private
   -- @since 3.0.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure X_Wp_Delete_Orphaned_Draft_Menu_Items;

   --
   -- Saves nav menu items
   --
   -- @since 3.6.0
   --
   -- @param int|string nav_menu_selected_id    ID, slug, or name of the currently-selected menu.
   -- @param string     nav_menu_selected_title Title of the currently-selected menu.
   -- @return array The menu updated message
   --
   function Wp_Nav_Menu_Update_Menu_Items (Nav_Menu_Selected_Id    : String;
                                           Nav_Menu_Selected_Title : String)
                                           return Array_Type;
   --
   -- If a JSON blob of navigation menu data is in POST data, expand it and inject
   -- it into `_POST` to avoid PHP `max_input_vars` limitations. See #14134.
   --
   -- @ignore
   -- @since 4.5.3
   -- @access private
   --
   procedure X_Wp_Expand_Nav_Menu_Post_Data;

end Adi_Nav_Menus;
