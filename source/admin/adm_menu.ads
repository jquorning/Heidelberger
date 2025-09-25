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
         Menu_Slug  : Unbounded_String;
         Page_Title : Unbounded_String;
         Classes    : Unbounded_String;
         Hookname   : Unbounded_String;
         Icon_Url   : Unbounded_String;
      end record;

   type Menu_Index is range 0 .. 99;

   package Menu_Vectors is new
      Ada.Containers.vectors (Index_Type   => Menu_Index,
                              Element_Type => Menu_Item);

   subtype Menu_Vector is Menu_Vectors.Vector;

   -- 0 := menu_title, 1 := capability, 2 := menu_slug,
   -- 3 := page_title, 4 := classes.
   type Submenu_Item is
      record
         Menu_Title : Unbounded_String;
         Capability : Unbounded_String;
         Menu_Slug  : Unbounded_String;
         Page_Title : Unbounded_String;
         Classes    : Unbounded_String;
      end record;

   type Submenu_Index is new Natural;

   package Inner_Maps is new
      Ada.Containers.Ordered_Maps (Key_Type     => Submenu_Index,
                                   Element_Type => Submenu_Item);

   package Submenu_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => Inner_Maps.Map,
                                              "="          => Inner_Maps."=");

   subtype Submenu_Type is Submenu_Maps.Map;

   Menu    : Menu_Vector;
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

end Adm_Menu;
