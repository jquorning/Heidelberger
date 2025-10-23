--
-- Build Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Arrays;

package Adm_Menu
is
   use Ada.Strings.Unbounded;

   X_Wp_Real_Parent_File : Arrays.Array_Type;

   type Unbounded_Slug is new Unbounded_String;

   --
   -- Constructs the admin menu.
   --
   -- The elements in the array are:
   --     0: Menu item name.
   --     1: Minimum level or capability required.
   --     2: The URL of the item's file.
   --     3: Page title.
   --     4: Classes.
   --     5: ID.
   --     6: Icon for top level menu.
   --
   -- @global array $menu
   --
      -- 0 := menu_title, 1 := capability, 2 := menu_slug,
      -- 3 := page_title, 4 := classes, 5 := hookname, 6 := icon_url.
   type Menu_Item is
      record
         Menu_Title : Unbounded_String;
         Capability : Unbounded_String;
         Menu_Slug  : Unbounded_Slug;
         Page_Title : Unbounded_String;
         Classes    : Unbounded_String;
         Hookname   : Unbounded_String;
         Icon_Url   : Unbounded_String;
      end record;

   type Menu_Index is range 0 .. 99;

   package Menu_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Menu_Index,
                              Element_Type => Menu_Item);

   subtype Menu_Type is Menu_Vectors.Vector;

   -- 0 := menu_title, 1 := capability, 2 := menu_slug,
   -- 3 := page_title, 4 := classes.
   type Submenu_Item is
      record
         Menu_Title : Unbounded_String;
         Capability : Unbounded_String;
         Menu_Slug  : Unbounded_Slug;
         Page_Title : Unbounded_String;
         Classes    : Unbounded_String;
      end record;

   type Submenu_Index is new Natural;
   type Slug_Type     is new String;

   package Inner_Maps is new
      Ada.Containers.Ordered_Maps (Key_Type     => Submenu_Index,
                                   Element_Type => Submenu_Item);

   package Submenu_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => Slug_Type,
                                              Element_Type => Inner_Maps.Map,
                                              "="          => Inner_Maps."=");

   subtype Submenu_Type is Submenu_Maps.Map;

   function "-" (Item : Unbounded_Slug) return Slug_Type
     is (Slug_Type (To_String (Unbounded_String (Item))));

   function "+" (Item : Slug_Type) return Unbounded_Slug
     is (Unbounded_Slug (Ada.Strings.Unbounded.To_Unbounded_String (String (Item))));

   function "<" (Left, Right : Slug_Type) return Boolean is (True);

   Menu    : Menu_Type := Menu_Vectors.To_Vector (Length => 100);
   Submenu : Submenu_Type;

   --
   -- Run
   --
   procedure Run;

   --
   -- Filter_And_Sort
   --
   function Filter_And_Sort (Submenu : Submenu_Type)
                             return Submenu_Type;

   --
   -- Adds the "Theme File Editor" menu item to the bottom of the Appearance
   -- (non-block themes) or Tools (block themes) menu.
   --
   -- @access private
   -- @since 3.0.0
   -- @since 5.9.0 Renamed "Theme Editor" to "Theme File Editor".
   --              Relocates to Tools for block themes.
   --
   procedure X_Add_Themes_Utility_Last;

   --
   -- Adds the "Plugin File Editor" menu item after the "Themes File Editor" in Tools
   -- for block themes.
   --
   -- @access private
   -- @since 5.9.0
   --
   procedure X_Add_Plugin_File_Editor_To_Tools;

end Adm_Menu;
