--
-- Core Navigation Menu API
--
-- @package WordPress
-- @subpackage Nav_Menus
-- @since 3.0.0
--

with Arrays;

package Inc_Nav_Menu_Templates
is
   use Arrays;

   procedure Dummy;

   --
   -- Retrieves the HTML list content for nav menu items.
   --
   -- @uses Walker_Nav_Menu to create HTML list content.
   -- @since 3.0.0
   --
   -- @param array    items The menu items, sorted by each menu item's menu order.
   -- @param int      depth Depth of the item in reference to parents.
   -- @param stdClass args  An object containing wp_nav_menu() arguments.
   -- @return string The HTML list content for the menu items.
   --
   function Walk_Nav_Menu_Tree (Items : Array_Type;
                                Depth : Integer;
                                Args  : Array_Type)
                                return String
                                is ("XXX-627");

end Inc_Nav_Menu_Templates;
