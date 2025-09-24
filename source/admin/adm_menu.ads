
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Multiway_Trees;
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
         Menu_Title : Unbounded_String; -- Name
         Capability : Unbounded_String; -- Cap
         Menu_Slug  : Unbounded_String; -- Url
         Page_Title : Unbounded_String; -- Title
         Classes    : Unbounded_String;
         Hookname   : Unbounded_String; -- Id
         Icon_Url   : Unbounded_String; -- Icon
      end record;

   type Menu_Index is range 0 .. 99;
--   subtype Menu_Key is String;

--   package Menu_Maps is new
--      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => Menu_Key,
--                                              Element_Type => Menu_Item);
   package Menu_Vectors is new
      Ada.Containers.vectors (Index_Type   => Menu_Index,
                              Element_Type => Menu_Item);

-- type Menu_Array is array (Menu_Index) of Menu_Item;
--   subtype Menu_Map is Menu_Maps.Map;
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

--   No_Submenu : constant Submenu_Index := 0;

   -- package Submenu_Trees  is new
   --    Ada.Containers.Multiway_Trees (Element_Type => Submenu_Item);

   -- subtype Submenu_Type is Submenu_Trees.Tree;

   package Submenu_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Submenu_Index,
                              Element_Type => Submenu_Item);

   subtype Submenu_Type is Submenu_Vectors.Vector;

   Menu    : Menu_Vector;  -- Menu_Map;
   Submenu : Submenu_Type;

   --
   --
   --
   procedure Run;

   --
   --
   --
   procedure Find_Submenu (Submenu : Submenu_Type;
                           Slug    : String;
                           Found   : out Boolean;
                           Index   : out Submenu_Index);

   --
   --
   --
   function Get_Sub_Submenu (Submenu   : Submenu_Type;
                             Menu_Slug : String)
                             return Submenu_Type;
   --
   --
   --
   function Filter_And_Sort (Submenu : Submenu_Type)
                             return Submenu_Type;

end Adm_Menu;
