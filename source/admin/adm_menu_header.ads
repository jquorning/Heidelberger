--
-- Displays Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Adm_Menu;

package Adm_Menu_Header
is
   use Ada.Strings.Unbounded;

--        global self, parent_file, submenu_file, plugin_page, typenow;
   Self         : Adm_Menu.Unbounded_Slug;

   --
   -- Display menu.
   --
   -- @access private
   -- @since 2.7.0
   --
   -- @global string self
   -- @global string parent_file
   -- @global string submenu_file
   -- @global string plugin_page
   -- @global string typenow      The post type of the current screen.
   --
   -- @param array menu
   -- @param array submenu
   -- @param bool  submenu_as_parent
   --

   procedure X_Wp_Menu_Output
     (Menu              : Adm_Menu.Menu_Vector;
      Submenu           : Adm_Menu.Submenu_Type;
      Submenu_As_Parent : Boolean := True);

   procedure Top;
   procedure Bottom;

end Adm_Menu_Header;
