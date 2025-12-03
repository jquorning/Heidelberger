--
-- Displays Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

with Adm_Menu;

package Adm_Menu_Header
is

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
     (Menu              : Adm_Menu.Menu_Type;
      Submenu           : Adm_Menu.Submenu_Type;
      Submenu_As_Parent : Boolean := True);

   procedure Top;
   procedure Bottom;

end Adm_Menu_Header;
