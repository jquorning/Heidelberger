with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Arrays;

package Hb_Menu
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

   type Menu_Array is array (0 .. 99) of Menu_Item;

   -- 0 := menu_title, 1 := capability, 2 := menu_slug,
   -- 3 := page_title, 4 := classes.
   type Submenu_Record is
      record
         Menu_Title : Unbounded_String;
         Capability : Unbounded_String;
         Menu_Slug  : Unbounded_String;
         Page_Title : Unbounded_String;
         Classes    : Unbounded_String;
      end record;

   type Submenu_Extended_Index is new Natural;
   subtype Submenu_Index is Submenu_Extended_Index
     range 1 .. Submenu_Extended_Index'Last;

   No_Submenu : constant Submenu_Extended_Index := 0;

   package Submenu_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Submenu_Index,
                              Element_Type => Submenu_Record);

   subtype Submenu_Type is Submenu_Vectors.Vector;

   Menu    : Menu_Array;
   Submenu : Submenu_Type;

   --
   --
   --
   procedure Run;

   --
   --
   --
   function Find_Submenu (Submenu : Submenu_Type;
                          Slug    : String)
                          return Submenu_Extended_Index;

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

end Hb_Menu;
