--
-- Build Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Arrays;
with Hb_Common;

with Inc_Plugins;

package body Adi_Menu
is
    use Ada.Strings.Unbounded;
    use Arrays;
    use Hb_Common;

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
   function Add_Menu_Classes (Menu : Array_Type)
                              return Array_Type;

   --
   -- @global array menu_order
   -- @global array default_menu_order
   --
   -- @param array a
   -- @param array b
   -- @return int
   --
   function Sort_Menu (A, B : Integer)
                       return Integer;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Inc_Plugins;
   begin
      if Is_Network_Admin then

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
      elsif Is_User_Admin then

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
            Pos : constant Integer := Strpos (Menu_Page (2), "?");
            Hook_Name : Unbounded_String;
         begin
            if 0 /= Pos then
               -- Handle post_type=post|page|foo pages.
               Hook_Name := +Substr (Menu_Page (2), 0, Pos);
               declare
                  Hook_Args : String := Substr (Menu_Page (2), Pos + 1);
               begin
                  wp_parse_str (hook_args, Hook_Args);
                  -- Set the hook name to be the post type.
                  if Isset (Hook_Args ("post_type")) then
                      Hook_Name := +Hook_Args ("post_type");
                  else
                      Hook_Name := +Basename (-Hook_Name, ".php");
                  end if;
                  Unset (Hook_Args);
               end;
            else
               Hook_Name := +Basename (Menu_Page (2), ".php");
            end if;
            Hook_Name := +Sanitize_Title (Hook_Name);

            if Isset (Compat (Hook_Name)) then
               Hook_Name := Compat (Hook_Name);
            elsif Hook_Name = "" then
               goto Continue_3;
            end if;

            Admin_Page_Hooks (Menu_Page (2)) := Hook_Name;
         end;
         << Continue_3 >>
      end loop;
      Unset (Menu_Page);
      Unset (Compat);

      X_Hb_Submenu_Nopriv := Empty_Array;
      X_hb_menu_nopriv    := Empty_Array;
      -- Loop over submenus and remove pages for which the user does not have privs.
      for A of Submenu loop
         declare
            Parent : String := -A.Key;
            Sub    : String := -A.Value;
         begin
            for B of Sub loop
               declare
                  Index : constant String := -B.Key;
                   Data : constant String := -B.Value;
               begin
                  if not Current_User_Can (Data (1)) then
                     Unset (Submenu (Parent) (Index));
                     X_Hb_Submenu_Nopriv (Parent) (Data (2)) := True;
                  end if;
               end;
            end loop;
--          unset (index, data);

            if Empty (Submenu (Parent)) then
               Unset (Submenu (Parent));
            end if;
         end;
      end loop;
      Unset (Sub, Parent);

      --
      -- Loop over the top-level menu.
      -- Menus for which the original parent is not accessible due to lack of
      -- privileges will have the next submenu in line be assigned as the new menu
      -- parent.
      --
      for M of Menu loop
         declare
            Id   : constant String := -M.Key;
            Data : constant String := -M.Value;
         begin
            if Empty (Submenu (Data (2))) then
               goto Continue_1;
            end if;
            Subs       := Submenu (Data (2));
            First_Sub  := Reset (subs);
            Old_Parent := Data (2);
            New_Parent := First_Sub (2);
            --
            -- If the first submenu is not the same as the assigned parent,
            -- make the first submenu the new parent.
            --
            if New_Parent /= Old_Parent then
               X_Hb_Real_Parent_File (Old_Parent) := New_Parent;
               Menu (Id) (2)                      := New_Parent;

               for S of Submenu (Old_Parent) loop
                  declare
                     Index : constant String := -S.Key;
                     Data  : constant String := -S.Value;
                  begin
                     Submenu (New_Parent) (Index) := Submenu (Old_Parent) (Index);
                     Unset (Submenu (Old_Parent) (Index));
                  end;
               end loop;
               Unset (Submenu (Old_Parent));
--             Unset (Index);

               if isset (X_Wp_Submenu_Nopriv (old_parent)) then
                  X_Hp_Submenu_Nopriv (New_Parent) := X_Wp_Submenu_Nopriv (Old_Parent);
               end if;
            end if;
         end;
         << Continue_1 >>
      end loop;
      Unset (Id);
      Unset (Data);
      Unset (Subs);
      Unset (First_Sub);
      Unset (Old_Parent);
      Unset (New_Parent);

      if Is_Network_Admin then
         --
         -- Fires before the administration menu loads in the Network Admin.
         --
         -- @since 3.1.0
         --
         -- @param string context Empty context.
         --
         Do_Action ("network_admin_menu", "");

      elsif Is_User_Admin then
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
      for M of Menu loop
         declare
            Id   : constant String := -M.Key;
            Data : constant String := -M.Value;
         begin
            if not Current_User_Can (Data (1)) then
               X_Hb_Menu_Nopriv (Data (2)) := True;
            end if;

            --
            -- If there is only one submenu and it is has same destination as the
            -- parent, remove the submenu.
            --
            if
              not Empty (Submenu (Data (2))) and then
              1 = Count (Submenu (Data (2)))
            then
               Subs      := Submenu (Data (2));
               First_Sub := Reset (Subs);
               if Data (2) = First_Sub (2) then
                  Unset (Submenu (Data (2)));
               end if;
            end if;

            -- If submenu is empty...
            if Empty (Submenu (Data (2))) then
               -- And user Doesn't have privs, remove menu.
               if Isset (X_Hb_Menu_Nopriv (Data (2))) then
                  Unset (Menu (Id));
               end if;
            end if;
         end;
      end loop;
      Unset (Id);
      Unset (Data);
      Unset (Subs);
      Unset (First_Sub);

      Uksort (Menu, "strnatcasecmp"); -- Make it all pretty.

      --
      -- Filters whether to enable custom ordering of the administration menu.
      --
      -- See the then@see "menu_order"end; filter for reordering menu items.
      --
      -- @since 2.8.0
      --
      -- @param bool custom Whether custom ordering is enabled. Default false.
      --
      if Apply_Filters ("custom_menu_order", False) then
         Menu_Order := Empty_array;
         for Menu_Item of Menu loop
            Menu_Order := Menu_Order & Menu_Item (2); -- ()
         end loop;
         Unset (Menu_Item);
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
         Menu_Order         := Array_Flip (Menu_Order);
         Default_Menu_Order := Array_Flip (Default_Menu_Order);

         Usort (Menu, "sort_menu");

         Unset (Menu_Order);
         Unset (Default_Menu_Order);
      end if;

      -- Prevent adjacent separators.
      Prev_Menu_Was_Separator := False;
      for M of menu loop
         declare
            Id   : constant String := -M.Key;
            Data : constant String := -M.Value;
         begin
            if false = Stristr (Data (4), "wp-menu-separator") then

               -- This item is not a separator, so falsey the toggler and do nothing.
               Prev_Menu_Was_Separator := False;
            else

               -- The previous item was a separator, so unset this one.
               if true = Prev_Menu_Was_Separator then
                  Unset (Menu (Id));
               end if;

               -- This item is a separator, so truthy the toggler and move on.
               Prev_Menu_Was_Separator := True;
            end if;
         end;
      end loop;
      Unset (Id);
      Unset (Data);
      Unset (Prev_Menu_Was_Separator);

      -- Remove the last menu item if it is a separator.
      Last_Menu_Key := Array_Keys (Menu);
      Last_Menu_Key := Array_Pop (Last_Menu_Key);
      if not Empty (Menu) and then "wp-menu-separator" = Menu (Last_Menu_Key) (4) then
         Unset (Menu (Last_Menu_Key));
      end if;
      Unset (Last_Menu_Key);

      if not User_Can_Access_Admin_Page then

         --
         -- Fires when access to an admin page is denied.
         --
         -- @since 2.5.0
         --
         Do_Action ("admin_page_access_denied");

         HP_Die (abs "Sorry, you are not allowed to access this page.",
                 Code => 403);
      end if;

      Menu := Add_Menu_Classes (Menu);

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

      return Classes & " " & Class_To_add;
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
   function Add_Menu_Classes (Menu : Array_Type)
                              return Array_Type
   is
      First_Item  : Boolean := False;
      Last_Order  : Boolean := False;
      Items_Count : Natural := Count (Menu);
      I           : Natural := 0;
   begin
      for M of menu loop
         declare
            Order : constant String := -M.Key;
            Top   : constant String := -M.Value;
         begin
            I := I + 1;

            if 0 = Order then -- Dashboard is always shown/single.
               Menu (0) (4) := Add_Cssclass ("menu-top-first", Top (4));
               Last_Order := 0;
               goto Continue_2;
            end if;

            if 0 = Strpos (Top (2), "separator") and then False /= Last_Order then -- If separator.
               First_Item            := True;
               Classes               := Menu (last_order) (4);
               Menu (Last_Order) (4) := Add_Cssclass ("menu-top-last", Classes);
               goto Continue_2;
            end if;

            if First_Item then
               Classes          := Menu (Order) (4);
                Menu (order) (4) := Add_Cssclass ("menu-top-first", Classes);
                First_Item       := False;
            end if;

            if I = Items_Count then -- Last item.
               Classes          := Menu (Order) (4);
               Menu (order) (4) := Add_Cssclass ("menu-top-last", Classes);
            end if;

            Last_Order := Order;
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
      return Apply_Filters ("add_menu_classes", Menu);
   end Add_Menu_Classes;

   --
   -- @global array menu_order
   -- @global array default_menu_order
   --
   -- @param array a
   -- @param array b
   -- @return int
   --
   function Sort_Menu (A, B : Integer)
                       return Integer
   is
--                global Menu_Order, Default_Menu_Order;
   begin
      A := A (2);
      B := B (2);
      if Isset (Menu_Order (a)) and then not Isset (Menu_Order (b)) then
         return -1;
      elsif not Isset (Menu_Order (A)) and then Isset (Menu_Order (b)) then
         return 1;
      elsif Isset (Menu_Order (a)) and then Isset (Menu_Order (B)) then
         if Menu_Order (A) = Menu_Order (B) then
            return 0;
         end if;
         return  (if Menu_Order (A) < Menu_Order (B) then -1 else 1);
      else
         return  (if Default_Menu_Order (A) <= Default_Menu_Order (B) then -1 else 1);
      end if;
   end Sort_Menu;

end Adi_Menu;
