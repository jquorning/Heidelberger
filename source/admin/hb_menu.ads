
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
   type Menu_Item is
      record
         Name    : Unbounded_String;
         Cap     : Unbounded_String;
         Url     : Unbounded_String;
         Title   : Unbounded_String;
         Classes : Unbounded_String;
         Id      : Unbounded_String;
         Icon    : Unbounded_String;
      end record;

   type Menu_Array is array (0 .. 99) of Menu_Item;

   Menu : Menu_Array;

   procedure Run;

end Hb_Menu;
