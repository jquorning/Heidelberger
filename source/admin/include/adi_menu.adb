--
-- Build Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Containers.Generic_Array_Sort;
with Ada.Containers.Generic_Constrained_Array_Sort;
with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Less_Case_Insensitive;

with Arrays;
with HB_Common;
with Php;

with Adm_Menu;

with Adi_Plugins;
with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_L10n;
with Inc_Load;
with Inc_Plugins;

package body Adi_Menu
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use HB_Common;
   use Php;

   -- Dummy
   function Apply_Filters (Hookname : String;
                           Menu     : Adm_Menu.Menu_Vector)
                           return Adm_Menu.Menu_Vector
                           is (Menu);

   --
   -- Adds a CSS class to a string.
   --
   -- @since 2.7.0
   --
   -- @param string class_to_add The CSS class to add.
   -- @param string classes      The string to add the CSS class to.
   -- @return string The string with the CSS class added.
   --
   function Add_Cssclass (Class_To_Add : String;
                          Classes      : String)
                          return String;

   --
   -- Adds CSS classes for top-level administration menu items.
   --
   -- The list of added classes includes `.menu-top-first` and `.menu-top-last`.
   --
   -- @since 2.7.0
   --
   -- @param array menu The array of administration menu items.
   -- @return array The array of administration menu items with the CSS classes added.
   --
   procedure Add_Menu_Classes (Menu : in out Adm_Menu.Menu_Vector); -- Array_Type)
--                              return Adm_Menu.Menu_Vector;  -- Array_Type
--   function Add_Menu_Classes (Menu : Array_Type)
--                              return Array_Type;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Inc_Plugins;

      Menu : Adm_Menu.Menu_Vector -- _Map -- _Array
         renames Adm_Menu.Menu;

      Submenu : Adm_Menu.Submenu_Type
         renames Adm_Menu.Submenu;

   begin
      if Inc_Load.Is_Network_Admin then
         --
         -- Fires before the administration menu loads in the Network Admin.
         --
         -- The hook fires before menus and sub-menus are removed based on user
         -- privileges.
         --
         -- @private
         -- @since 3.1.0
         --
         Do_Action ("_network_admin_menu");

      elsif Inc_Load.Is_User_Admin then
         --
         -- Fires before the administration menu loads in the User Admin.
         --
         -- The hook fires before menus and sub-menus are removed based on user
         -- privileges.
         --
         -- @private
         -- @since 3.1.0
         --
         Do_Action ("_user_admin_menu");

      else
         --
         -- Fires before the administration menu loads in the admin.
         --
         -- The hook fires before menus and sub-menus are removed based on user
         -- privileges.
         --
         -- @private
         -- @since 2.2.0
         --
         Do_Action ("_admin_menu");

      end if;

      -- Create list of page plugin hook names.
      for Menu_Page of Menu loop
         declare
            Pos : constant Integer := Strpos (-Menu_Page.Menu_Slug, "?"); -- (2)
            Hook_Name : Unbounded_String;
         begin
            if 0 /= Pos then
               -- Handle post_type=post|page|foo pages.
               Hook_Name := +Substr (-Menu_Page.Menu_Slug, 0, Pos); -- (2)
               declare
                  Hook_Args : String := Substr (-Menu_Page.Menu_Slug, Pos + 1); -- (2)
               begin
                  Inc_Formatting.Wp_Parse_Str (Hook_Args, Hook_Args);
                  -- Set the hook name to be the post type.
                  if Isset (Hook_Args ("post_type")) then
                     Hook_Name := +Hook_Args ("post_type");
                  else
                     Hook_Name := +Basename (-Hook_Name, ".php");
                  end if;
--                Unset (Hook_Args);
               end;
            else
               Hook_Name := +Basename (-Menu_Page.Menu_Slug, ".php"); -- (2)
            end if;
            Hook_Name := +Inc_Formatting.Sanitize_Title (-Hook_Name);

--            if Isset (Compat (Hook_Name)) then
--               Hook_Name := Compat (Hook_Name);
--            els(if)
            if Hook_Name = "" then
               goto Continue_3;
            end if;

--          Admin_Page_Hooks (-Menu_Page.Menu_Slug) := -Hook_Name; -- (2)
         end;
         << Continue_3 >>
      end loop;
--    Unset (Menu_Page);
--    Unset (Compat);

      declare
         X_Wp_Submenu_Nopriv : Array_Type;
         X_Wp_Menu_Nopriv    : List_Type;
      begin
         -- Loop over submenus and remove pages for which the user does not have privs.
         for A in Submenu.First_Index .. Submenu.Last_Index loop
            declare
               use Adm_Menu;

--             Parent : String := -A.Key;
--             Sub    : String := -A.Value;
               Parent : Submenu_Index := A;
               Sub    : Submenu_Item renames Submenu (A);
            begin
               for B of Sub loop
                  declare
                     Index : constant String := -B.Key;
                     Data  : constant String := -B.Value;
                  begin
                     if not Inc_Capabilities.Current_User_Can (-Data.Capability) then
--                   if not Inc_Capabilities.Current_User_Can (Data (1)) then
                        Unset (Submenu (Parent) (Index));
                        X_Wp_Submenu_Nopriv (Parent) (-Data.Menu_Slug) := True;
--                      X_wp_Submenu_Nopriv (Parent) (Data (2)) := True;
                     end if;
                  end;
               end loop;
--             Unset (Index);
--             Unset (Data);

               if Submenu.Contains (Sub) then
--             if Empty (Submenu (Parent)) then
                  Submenu.Delete (Parent);
--                Unset (Submenu (Parent));
               end if;
            end;
         end loop;
--      end;
--    Unset (Sub);
--    Unset (Parent);

         --
         -- Loop over the top-level menu.
         -- Menus for which the original parent is not accessible due to lack of
         -- privileges will have the next submenu in line be assigned as the new menu
         -- parent.
         --
         for M in Menu.First_Index .. Menu.Last_Index loop
            declare
               use Adm_Menu;

--             Id   : constant String := -M.Key;
--             Data : constant String := -M.Value;
               Id   : constant Menu_Index := M;
               Data : Menu_Item renames Menu (Id);
            begin
               if not Submenu.Contains (-Data.Menu_Slug) then -- (2)
--             if Submenu (-Data.Menu_Slug) = "" then -- (2)
                  goto Continue_1;
               end if;

               declare
                  Subs       : String  := Submenu (-Data.Menu_Slug); -- (2)
                  First_Sub  : Integer := Reset (Subs);       -- (2)
                  Old_Parent : String  := -Data.Menu_Slug;           -- (2)
                  New_Parent : String  := -First_Sub.Menu_Slug;      -- (2)
               begin
                  --
                  -- If the first submenu is not the same as the assigned parent,
                  -- make the first submenu the new parent.
                  --
                  if New_Parent /= Old_Parent then
                     declare
                        use Arrays.Array_Vectors;
                        Pos   : Extended_Index;
                        Found : Boolean := False;
                     begin
                        for
                           E in X_Wp_Real_Parent_File.First_Index
                             .. X_Wp_Real_Parent_File.Last_Index
                        loop
                           if X_Wp_Real_Parent_File (E).Key = Old_Parent then
                              Pos   := E;
                              Found := True;
                              exit;
                           end if;
                        end loop;

                        if Found then
                           X_Wp_Real_Parent_File.Replace_Element
                              (Pos, (+Old_Parent, +New_Parent));
                        else
                           X_Wp_Real_Parent_File.Append
                              ((+Old_Parent, +New_Parent));
                        end if;
                     end;
--                   X_Wp_Real_Parent_File (Old_Parent) := New_Parent;
                     Menu (Id) (2)                      := New_Parent;

                     for S of Submenu (Old_Parent) loop
                        declare
                           Index : constant String := -S.Key;
                           Data  : constant String := -S.Value;
                        begin
                           Submenu (New_Parent) (Index) :=
                              Submenu (Old_Parent) (Index);
                           Unset (Submenu (Old_Parent) (Index));
                        end;
                     end loop;
                     Unset (Submenu (Old_Parent));
--                   Unset (Index);

                     if Isset (X_Wp_Submenu_Nopriv (old_parent)) then
                        X_Wp_Submenu_Nopriv (New_Parent) :=
                           X_Wp_Submenu_Nopriv (Old_Parent);
                     end if;
                  end if;
               end;
            end;
            << Continue_1 >>
         end loop;
--       Unset (Id);
--       Unset (Data);
--       Unset (Subs);
--       Unset (First_Sub);
--       Unset (Old_Parent);
--       Unset (New_Parent);

         if Inc_Load.Is_Network_Admin then
            --
            -- Fires before the administration menu loads in the Network Admin.
            --
            -- @since 3.1.0
            --
            -- @param string context Empty context.
            --
            Do_Action ("network_admin_menu", "");

         elsif Inc_Load.Is_User_Admin then
            --
            -- Fires before the administration menu loads in the User Admin.
            --
            -- @since 3.1.0
            --
            -- @param string context Empty context.
            --
            Do_Action ("user_admin_menu", "");

         else
            --
            -- Fires before the administration menu loads in the admin.
            --
            -- @since 1.5.0
            --
            -- @param string context Empty context.
            --
            Do_Action ("admin_menu", "");
         end if;

         --
         -- Remove menus that have no accessible submenus and require privileges
         -- that the user does not have. Run re-parent loop again.
         --
         for M in Menu.First_Index .. Menu.Last_Index loop
            declare
               use Adm_Menu;

               Id   : Menu_Index := M; -- constant String := -M.Key;
               Data : Menu_Item  renames Menu (Id); -- constant String := -M.Value;
            begin
               if not Inc_Capabilities.Current_User_Can (-Data.Capability) then -- (1)
                  X_Wp_Menu_Nopriv.Append (Data.Menu_Slug); -- := True; -- (2)
               end if;

               --
               -- If there is only one submenu and it is has same destination as the
               -- parent, remove the submenu.
               --
               if
                 not Submenu (Data.Menu_Slug).Is_Empty and then -- (2)
                 1 = Length (Submenu (Data.Menu_Slug)) -- (2)
               then
                  declare
                     Subs      : Integer := Submenu (Data.Menu_Slug); -- (2)
                     First_Sub : Integer := Reset (Subs);
                  begin
                     if Data.Menu_Slug = First_Sub.Menu_Slug then -- 2x(2)
                        Unset (Submenu (Data.Menu_Slug));   -- (2)
                     end if;
                  end;
               end if;

               -- If submenu is empty...
               if Empty (Submenu (Data.Menu_Slug)) then  -- (2)
                  -- And user Doesn't have privs, remove menu.
                  if X_Wp_Menu_Nopriv.Contains (Data.Menu_Slug) then  -- (2)
--                if Isset (X_Wp_Menu_Nopriv (Data.Menu_Slug)) then  -- (2)
                     Menu.Delete (Id);
--                   Unset (Menu (Id));
                  end if;
               end if;
            end;
         end loop;
--       Unset (Id);
--       Unset (Data);
--       Unset (Subs);
--       Unset (First_Sub);
      end;

      -- Make it all pretty.
      declare
         function Less_Than (Left, Right : Adm_Menu.Menu_Item)
                             return Boolean;

         function Less_Than (Left, Right : Adm_Menu.Menu_Item)
                             return Boolean
         is
         begin
            return
               Ada.Strings.Unbounded.Less_Case_Insensitive
                  (Left.Menu_Title, Right.Menu_Title);
         end Less_Than;

         package Sorting is new
            Adm_Menu.Menu_Vectors.Generic_Sorting ("<" => Less_Than);
      begin
         Sorting.Sort (Menu);
--       Uksort (Menu, "strnatcasecmp");
      end;

      --
      -- Filters whether to enable custom ordering of the administration menu.
      --
      -- See the {@see "menu_order"} filter for reordering menu items.
      --
      -- @since 2.8.0
      --
      -- @param bool custom Whether custom ordering is enabled. Default false.
      --
      if Apply_Filters ("custom_menu_order", False) then
         declare
            Menu_Order         : List_Type;
            Default_Menu_Order : List_Type;
         begin
            for Menu_Item of Menu loop
               List_Vectors.Append (Menu_Order, Menu_Item.Menu_Slug); -- () & (2)
            end loop;
--            Unset (Menu_Item);
            Default_Menu_Order := Menu_Order;

            --
            -- Filters the order of administration menu items.
            --
            -- A truthy value must first be passed to the {@see "custom_menu_order"}
            -- filter for this filter to work. Use the following to enable custom menu
            -- ordering:
            --
            --     add_filter ("custom_menu_order", "__return_true");
            --
            -- @since 2.8.0
            --
            -- @param array menu_order An ordered array of menu items.
            --
            Menu_Order         := Apply_Filters ("menu_order", Menu_Order);
--          Menu_Order         := Array_Flip (Menu_Order);
--          Default_Menu_Order := Array_Flip (Default_Menu_Order);

            declare
               --
               -- @global array menu_order
               -- @global array default_menu_order
               --
               -- @param array a
               -- @param array b
               -- @return int
               --
               function Less_Than (Left, Right : Adm_Menu.Menu_Item)
                                   return Boolean;

               ---------------
               -- Less_Than --
               ---------------

               function Less_Than (Left, Right : Adm_Menu.Menu_Item)
                                  return Boolean
               is
                  use List_Vectors;

--                global Menu_Order, Default_Menu_Order;
                  A : constant String := -Left. Menu_Slug; --  (2)
                  B : constant String := -Right.Menu_Slug; --  (2)

                  Contains_A : constant Boolean := Contains (Menu_Order, +A);
                  Contains_B : constant Boolean := Contains (Menu_Order, +B);
               begin
                  if Contains_A and not Contains_B then
                     return True;

                  elsif not Contains_A and Contains_B then
                     return False;

                  elsif Contains_A and Contains_B then
                     return
                        Menu_Order (A) < Menu_Order (B);
                  else
                     return
                        Default_Menu_Order (A) < Default_Menu_Order (B);
                  end if;
               end Less_Than;

               ----------
               -- Sort --
               ----------

               package Sorting is new
                  Adm_Menu.Menu_Vectors.Generic_Sorting ("<" => Less_Than);
            begin
               Sorting.Sort (Menu);
--             Usort (Menu, "sort_menu");
            end;
         end;

--       Unset (Menu_Order);
--       Unset (Default_Menu_Order);
      end if;

      -- Prevent adjacent separators.
      declare
         Prev_Menu_Was_Separator : Boolean := False;
      begin
         for M in Menu.First_Index .. Menu.Last_Index loop
            declare
               use Adm_Menu;

               Id   : constant Menu_Index := M;   -- String := -M.Key;
               Data : Menu_Item renames Menu (M); --    String := -M.Value;
            begin

               if not Stristr (-Data.Classes, "wp-menu-separator") then -- (4)
                  -- This item is not a separator, so falsey the toggler and do
                  -- nothing.
                  Prev_Menu_Was_Separator := False;

               else
                  -- The previous item was a separator, so unset this one.
                  if Prev_Menu_Was_Separator then
                     Menu.Delete (Id);
--                   Unset (Menu (Id));
                  end if;

                  -- This item is a separator, so truthy the toggler and move on.
                  Prev_Menu_Was_Separator := True;
               end if;
            end;
         end loop;
--       Unset (Id);
--       Unset (Data);
--       Unset (Prev_Menu_Was_Separator);
      end;

      -- Remove the last menu item if it is a separator.
--       declare
--          Last_Menu_Key : Unbounded_String;
--       begin
--          Last_Menu_Key := Array_Keys (Menu);
--          Last_Menu_Key := Array_Pop (Last_Menu_Key);
      if
        not Menu.Is_Empty and then
        "wp-menu-separator" = Menu.Last_Element.Classes -- (4)
      then
         Menu.Delete_Last;
--       Unset (Menu (Last_Menu_Key));
      end if;
-- --       Unset (Last_Menu_Key);
--       end;

      if not Adi_Plugins.User_Can_Access_Admin_Page then

         --
         -- Fires when access to an admin page is denied.
         --
         -- @since 2.5.0
         --
         Do_Action ("admin_page_access_denied");
         declare
            use Inc_Functions;
            use Inc_L10n;
         begin
            Wp_Die (abs "Sorry, you are not allowed to access this page.",
                    Code => 403);
         end;
      end if;

      Add_Menu_Classes (Menu);
--    Menu := Add_Menu_Classes (Menu);

   end Run;

   --
   -- Adds a CSS class to a string.
   --
   -- @since 2.7.0
   --
   -- @param string class_to_add The CSS class to add.
   -- @param string classes      The string to add the CSS class to.
   -- @return string The string with the CSS class added.
   --
   function Add_Cssclass (Class_To_Add : String;
                          Classes      : String)
                          return String
   is
   begin
      if Empty (Classes) then
         return Class_To_Add;
      end if;

      return Classes & " " & Class_To_Add;
   end Add_Cssclass;

   --
   -- Adds CSS classes for top-level administration menu items.
   --
   -- The list of added classes includes `.menu-top-first` and `.menu-top-last`.
   --
   -- @since 2.7.0
   --
   -- @param array menu The array of administration menu items.
   -- @return array The array of administration menu items with the CSS classes added.
   --
   procedure Add_Menu_Classes (Menu : in out Adm_Menu.Menu_Vector) -- Array_Type)
--                              return Adm_Menu.Menu_Vector  -- Array_Type
   is
      use Adm_Menu;

      First_Item       : Boolean    := False;
      Last_Order       : Boolean    := False;
      Last_Order_Index : Menu_Index := 0;
      Items_Count      : Menu_Index := Menu.Last_Index; -- Count (Menu);
--    I           : Natural := 0;
   begin
      for Order in Menu.First_Index .. Menu.Last_Index loop
         declare
--            Order : constant String := -M.Key;
            Top   : Menu_Item renames Menu (Order); -- constant String := -M.Value;
         begin
--          I := I + 1;

            if 0 = Order then -- Dashboard is always shown/single.
               Menu (0).Classes :=
                  +Add_Cssclass ("menu-top-first", -Top.Classes); -- 2x(4)

               Last_Order := False;
               goto Continue_2;
            end if;

            -- If separator.
            if
              0 = Strpos (-Top.Menu_Slug, "separator") and then      -- (2)
              Last_Order
            then
               First_Item := True;
               declare
                  Classes : constant String := -Menu (Last_Order_Index).Classes; -- (4)
               begin
                  Menu (Last_Order_Index).Classes :=  -- (4)
                     +Add_Cssclass ("menu-top-last", Classes);
               end;
               goto Continue_2;
            end if;

            if First_Item then
               declare
                  Classes : constant String := -Menu (Order).Classes; -- (4)
               begin
                  Menu (Order).Classes :=   -- (4)
                     +Add_Cssclass ("menu-top-first", Classes);
               end;
               First_Item := False;
            end if;

            if Order = Menu.Last_Index then -- Last item.
--          if I = Items_Count then -- Last item.
               declare
                  Classes : constant String := -Menu (Order).Classes; -- (4)
               begin
                  Menu (Order).Classes := -- (4)
                     +Add_Cssclass ("menu-top-last", Classes);
               end;
            end if;

            Last_Order_Index := Order;
            Last_Order       := True;
--          Last_Order := Order;
         end;
         << Continue_2 >>
      end loop;

      --
      -- Filters administration menu array with classes added for top-level items.
      --
      -- @since 2.7.0
      --
      -- @param array menu Associative array of administration menu items.
      --
      Menu := Apply_Filters ("add_menu_classes", Menu);
   end Add_Menu_Classes;

end Adi_Menu;
