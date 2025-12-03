--
-- Navigation Menu functions
--
-- @package WordPress
-- @subpackage Nav_Menus
-- @since 3.0.0
--

with Ada.Strings.Unbounded;

with Arrays;
with Lists;

with Inc_Class_Wp_Terms;

package Inc_Nav_Menus
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Lists;

   --
   -- Returns a navigation menu object.
   --
   -- @since 3.0.0
   --
   -- @param int|string|WP_Term $menu Menu ID, slug, name, or object.
   -- @return WP_Term|false Menu object on success, false if $menu param isn't
   --                       supplied or term does not exist.
   --
   function Wp_Get_Nav_Menu_Object (Menu : Integer)
                                    return Integer
                                    is (1);

   --
   -- Determines whether the given ID is a navigation menu.
   --
   -- Returns true if it is; false otherwise.
   --
   -- @since 3.0.0
   --
   -- @param int|string|WP_Term $menu Menu ID, slug, name, or object of menu to check.
   -- @return bool Whether the menu exists.
   --
   function Is_Nav_Menu (Menu : Integer)
                        return Boolean
                        is (True);

--
-- Determines whether the given ID is a nav menu item.
--
-- @since 3.0.0
--
-- @param int $menu_item_id The ID of the potential nav menu item.
-- @return bool Whether the given ID is that of a nav menu item.
--
   function Is_Nav_Menu_Item (Menu_Item_Id : Integer := 0)
                              return Boolean
                              is (True);

--
-- Decorates a menu item object with the shared navigation menu item properties.
--
-- Properties:
-- - ID:               The term_id if the menu item represents a taxonomy term.
-- - attr_title:       The title attribute of the link element for this menu item.
-- - classes:          The array of class attribute values for the link element of this menu item.
-- - db_id:            The DB ID of this item as a nav_menu_item object, if it exists (0 if it doesn"t exist).
-- - description:      The description of this menu item.
-- - menu_item_parent: The DB ID of the nav_menu_item that is this item"s menu parent, if any. 0 otherwise.
-- - object:           The type of object originally represented, such as "category", "post", or "attachment".
-- - object_id:        The DB ID of the original object this menu item represents, e.g. ID for posts and term_id for categories.
-- - post_parent:      The DB ID of the original object"s parent object, if any (0 otherwise).
-- - post_title:       A "no title" label if menu item represents a post that lacks a title.
-- - target:           The target attribute of the link element for this menu item.
-- - title:            The title of this menu item.
-- - type:             The family of objects originally represented, such as "post_type" or "taxonomy".
-- - type_label:       The singular label used to describe this type of menu item.
-- - url:              The URL to which this menu item points.
-- - xfn:              The XFN relationship expressed in the link of this menu item.
-- - _invalid:         Whether the menu item represents an object that no longer exists.
--
-- @since 3.0.0
--
-- @param object $menu_item The menu item to modify.
-- @return object The menu item with standard menu item properties.
--
   function Wp_Setup_Nav_Menu_Item (Menu_Item : Array_Type)
                                    return Array_Type
                                    is (Empty_Array);

   -- function Wp_Setup_Nav_Menu_Item (Menu_Item : Array_Type)
   --                                  return Array_Type
   --                                  is (Empty_Array);

--
-- Retrieves all registered navigation menu locations in a theme.
--
-- @since 3.0.0
--
-- @global array $_wp_registered_nav_menus
--
-- @return string[] Associative array of egistered navigation menu descriptions keyed
--                  by their location. If none are registered, an empty array.
--
   function Get_Registered_Nav_Menus
            return List_Type -- String_Array
            is (Empty_List);

   --
   -- Returns all navigation menu objects.
   --
   -- @since 3.0.0
   -- @since 4.1.0 Default value of the "orderby" argument was changed from "none"
   --              to "name".
   --
   -- @param array $args Optional. Array of arguments passed on to get_terms().
   --                    Default empty array.
   -- @return WP_Term[] An array of menu objects.
   --
   function Wp_Get_Nav_Menus (Args : Array_Type := Empty_Array)
                              return Inc_Class_Wp_Terms.Wp_Term_Array
                              is (Inc_Class_Wp_Terms.Empty_Term_Array);

--
-- Retrieves all registered navigation menu locations and the menus assigned to them.
--
-- @since 3.0.0
--
-- @return int[] Associative array of registered navigation menu IDs keyed by their
--               location name. If none are registered, an empty array.
--
   function Get_Nav_Menu_Locations
            return Integer_Array
            is (Empty_Integer_Array);

--
-- Retrieves all menu items of a navigation menu.
--
-- Note: Most arguments passed to the `$args` parameter – save for "output_key" – are
-- specifically for retrieving nav_menu_item posts from get_posts() and may only
-- indirectly affect the ultimate ordering and content of the resulting nav menu
-- items that get returned from this function.
--
-- @since 3.0.0
--
-- @param int|string|WP_Term $menu Menu ID, slug, name, or object.
-- @param array              $args {
--     Optional. Arguments to pass to get_posts().
--
--     @type string $order       How to order nav menu items as queried with get_posts(). Will be ignored
--                               if "output" is ARRAY_A. Default "ASC".
--     @type string $orderby     Field to order menu items by as retrieved from get_posts(). Supply an orderby
--                               field via "output_key" to affect the output order of nav menu items.
--                               Default "menu_order".
--     @type string $post_type   Menu items post type. Default "nav_menu_item".
--     @type string $post_status Menu items post status. Default "publish".
--     @type string $output      How to order outputted menu items. Default ARRAY_A.
--     @type string $output_key  Key to use for ordering the actual menu items that get returned. Note that
--                               that is not a get_posts() argument and will only affect output of menu items
--                               processed in this function. Default "menu_order".
--     @type bool   $nopaging    Whether to retrieve all menu items (true) or paginate (false). Default true.
-- }
-- @return array|false Array of menu items, otherwise false.
--

   -- Added nby jq
   type Menu_Item is
      record
         Post_Status : Unbounded_String;
         X_Invalid   : Boolean;
         DB_Id       : Unbounded_String;
      end record;

   type Menu_Item_Array is array (Positive range <>) of Menu_Item;

   function Wp_Get_Nav_Menu_Items (Menu : String;
                                   Args : Array_Type := Empty_Array)
                                   return Menu_Item_Array -- Array_Type
                                   is (1 .. 0 => <>);     -- is (Empty_Array);

   procedure Dummy;

end Inc_Nav_Menus;
