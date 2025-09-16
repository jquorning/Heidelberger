--
-- Displays Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Arrays;

with Hb_Menu;

package Adm_Menu_Header
is
   use Ada.Strings.Unbounded;
   use Arrays;

--        global self, parent_file, submenu_file, plugin_page, typenow;
   Self         : Unbounded_String;
   Parent_File  : Unbounded_String;
   Submenu_File : Unbounded_String;
   Plugin_Page  : Unbounded_String;

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

   procedure X_Wp_Menu_Output (Menu              : Hb_Menu.Menu_Array; -- Array_Type;
                               Submenu           : Hb_Menu.Submenu_Type; -- Array_Type;
                               Submenu_As_Parent : Boolean := True);

   procedure Top;
   procedure Bottom;

end Adm_Menu_Header;
