--
-- Displays Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Containers;

with Arrays;
with Globals;
with HB_Common;
with Php;

with Adi_Plugins;
with Inc_Capabilities;
with Inc_Formatting;
with Inc_L10n;
with Inc_Plugins;

package body Adm_Menu_Header
is
   use Arrays;
   use Globals;
   use Php;
   use Inc_L10n;
   use HB_Common;

--
-- The current page.
--
-- @global string self
--
   procedure Top
   is
      Self   : Unbounded_String;  -- Where does this come from? jq
      Unused : Unbounded_String;
   begin
      Self := +Get (X_SERVER, "PHP_SELF");
      Self := +Preg_Replace ("|^.*/wp-admin/network/|i", "", -Self);
      Self := +Preg_Replace ("|^.*/wp-admin/|i", "",   -Self);
      Self := +Preg_Replace ("|^.*/plugins/|i", "",    -Self);
      Self := +Preg_Replace ("|^.*/mu-plugins/|i", "", -Self);

      --
      -- For when admin-header is included from within a function.
      --
      -- @global array  menu
      -- @global array  submenu
      -- @global string parent_file
      -- @global string submenu_file
      --
--      global menu, submenu, parent_file, submenu_file;

      --
      -- Filters the parent file of an admin menu sub-menu item.
      --
      -- Allows plugins to move sub-menu items around.
      --
      -- @since MU (3.0.0)
      --
      -- @param string parent_file The parent file.
      --
--      Parent_File := Apply_Filters ("parent_file", Parent_File);

      --
      -- Filters the file of an admin menu sub-menu item.
      --
      -- @since 4.4.0
      --
      -- @param string submenu_file The submenu file.
      -- @param string parent_file  The submenu item's parent file.
      --
--      Submenu_File := Apply_Filters ("submenu_file", Submenu_File, Parent_File);

      Unused := +Adi_Plugins.Get_Admin_Page_Parent; -- ();
   end Top;

   ----------------------
   -- X_Wp_Menu_Output --
   ----------------------

   procedure X_Wp_Menu_Output
     (Menu              : Adm_Menu.Menu_Vector; -- _Map; -- _Array; -- Array_Type;
      Submenu           : Adm_Menu.Submenu_Type; -- Array_Type;
      Submenu_As_Parent : Boolean := True)
   is
      use Inc_Capabilities;
      use Inc_Formatting;

--        global self, parent_file, submenu_file, plugin_page, typenow;
      First : Boolean := True;
   begin
      -- 0 := menu_title, 1 := capability, 2 := menu_slug,
      -- 3 := page_title, 4 := classes, 5 := hookname, 6 := icon_url.
      for Item of Menu loop
         declare
            use List_Vectors;
            use Adm_Menu;
            use type Adm_Menu.Submenu_Maps.Map;
            use type Adm_Menu.Inner_Maps.Map;

            Admin_Is_Parent : Boolean    := False;
            Class           : List_Type  := Empty_List;
            Aria_Attributes : List_Type  := Empty_List; -- String     := "";
            Aria_Hidden     : Unbounded_String;
            Is_Separator    : Boolean    := False;

            Submenu_Items : Adm_Menu.Inner_Maps.Map;
         begin

            if First then
               Append (Class, +"wp-first-item");  -- ()
               First := False;
            end if;

            if Item.Menu_Slug /= "" then
               Append (Class, +"wp-has-submenu"); -- ()
               Submenu_Items := Submenu (-Item.Menu_Slug);
            end if;

            if
              (Parent_File /= "" and then Item.Menu_Slug = Parent_File) or else
              (Empty (-Typenow) and then Self = Item.Menu_Slug)
            then
               if Submenu_Items = Inner_Maps.Empty_Map then
--             if not Empty (Submenu_Items) then
                  Append (Class, +"wp-has-current-submenu wp-menu-open");
               else
                  Append (Class, +"current");  -- ()
                  Append (Aria_Attributes, +"aria-current=""page""");
               end if;
            else
               Append (Class, +"wp-not-current-submenu");  -- ()
               if Submenu_Items = Inner_Maps.Empty_Map then
--               if not Empty (Submenu_Items) then
                  Append (Aria_Attributes, +"aria-haspopup=""true""");
               end if;
            end if;

            if Item.Classes /= "" then
               Append (Class, +ESC_Attr (-Item.Classes));
            end if;

            declare
               use Ada.Containers;

               Class_2 : String :=
                  (if Length (Class) = 0
                   then " class=""" & Implode (" ", Class) & """" else "");

               Id : String :=
                  (if Item.Hookname /= ""
                   then " id=""" & Preg_Replace ("|(^a-zA-Z0-9_:.)|", "-",
                                                 -Item.Hookname) & """"
                   else "");

               Img       : Unbounded_String;
               Img_Style : Unbounded_String;
               Img_Class : Unbounded_String := +" dashicons-before";
            begin
               if 0 /= Strpos (Class_2, "wp-menu-separator") then
                  Is_Separator := True;
               end if;

               --
               -- If the string "none" (previously "div") is passed instead of a
               -- URL, don't output the default menu image so an icon can be added
               -- to div.wp-menu-image as background with CSS. Dashicons and
               -- base64-encoded data:image/svg_xml URIs are also handled
               -- as special cases.
               --
               if Item.Icon_Url /= "" then
                  Img := +"<img src=""" & ESC_URL (-Item.Icon_Url) & """ alt="" />";

                  if "none" = Item.Icon_Url or else "div" = Item.Icon_Url then
                     Img := +"<br />";
                  elsif 0 = Strpos (-Item.Icon_Url, "data:image/svg+xml;base64,") then
                     Img := +"<br />";
                     -- The value is base64-encoded data, so esc_attr() is used here
                     -- instead of esc_url().
                     Img_Style := +" style=""background-image:url(\""" &
                                   ESC_Attr (-Item.Icon_Url) & "\"")""";
                     Img_Class := +" svg";
                  elsif 0 = Strpos (-Item.Icon_Url, "dashicons-") then
                     Img       := +"<br />";
                     Img_Class := +" dashicons-before " &
                                   Inc_Formatting.Sanitize_Html_Class (-Item.Icon_Url);
                  end if;
               end if;

               declare
                  Arrow : constant String :=
                     "<div class=""wp-menu-arrow""><div></div></div>";
                  Title : Unbounded_String :=
                     +Inc_Formatting.Wptexturize (-Item.Menu_Title);
               begin
                  -- Hide separators from screen readers.
                  if Is_Separator then
                     Aria_Hidden := +" aria-hidden=""true""";
                  end if;

                  Echo ("\n\t<liclassidaria_hidden>");

                  if Is_Separator then
                     Echo ("<div class=""separator""></div>");
                  elsif
                    Submenu_As_Parent and then
                    Submenu_Items /= Inner_Maps.Empty_Map
                  then
                     declare
                        Submenu_Items_2 : constant Submenu_Type :=
                           Filter_And_Sort (Submenu);  -- Re-index.

                        -- Re-index.
                        Submenu_Map : constant Inner_Maps.Map :=
                           Submenu_Items_2.First_Element;

                        Elem        : constant Submenu_Item :=
                           Submenu_Map.First_Element;

                        Menu_File   : String := -Elem.Menu_Slug;

                        Menu_Hook : constant String :=
                           Adi_Plugins.Get_Plugin_Page_Hook (Menu_File,
                                                             -Item.Menu_Slug);

                        Pos : constant Integer := Strpos (Menu_File, "?");
                     begin
                        if 0 /= Pos then
                           Menu_File := Substr (Menu_File, 0, Pos);
                        end if;

                        if not Empty (Menu_Hook)
                                or else (("index.php" /= Menu_File)
                                        and then File_Exists (WP_PLUGIN_DIR & "/menu_file")
                                        and then not File_Exists (ABSPATH & "/wp-admin/menu_file"))
                        then
                           Admin_Is_Parent := True;
                           Echo ("<a href=""admin.php?page=" & Menu_File & """class aria_attributes>arrow<div class=""wp-menu-imageimg_class""img_style aria-hidden=""true"">img</div><div class=""wp-menu-name"">title</div></a>");
                        else
                           Echo ("\n\t<a href=""" & Menu_File & """class aria_attributes>arrow<div class=""wp-menu-imageimg_class""img_style aria-hidden=""true"">img</div><div class=""wp-menu-name"">title</div></a>");
                        end if;
                     end;

                  elsif
                    Item.Menu_Slug /= "" and then
                    Current_User_Can (-Item.Capability)
                  then
                     declare
                        Menu_Hook : constant String :=
                           Adi_Plugins.Get_Plugin_Page_Hook (-Item.Menu_Slug,
                                                             "admin.php");
                        Menu_File : String  := -Item.Menu_Slug;
                        Pos       : constant Integer := Strpos (Menu_File, "?");
                     begin
                        if 0 /= Pos then
                           Menu_File := Substr (Menu_File, 0, Pos);
                        end if;

                        if not Empty (Menu_Hook)
                                or else (("index.php" /= Item.Menu_Slug)
                                        and then File_Exists (WP_PLUGIN_DIR & "/menu_file")
                                        and then not File_Exists (ABSPATH & "/wp-admin/menu_file"))
                        then
                           Admin_Is_Parent := True;
                           Echo ("\n\t<a href=""admin.php?page=" & (-Item.Menu_Slug) & """class aria_attributes>arrow<div class=""wp-menu-imageimg_class""img_style aria-hidden=""true"">img</div><div class=""wp-menu-name"">" & (-Item.Menu_Title) & "</div></a>");
                        else
                           Echo ("\n\t<a href=""" & (-Item.Menu_Slug) & """class aria_attributes>arrow<div class=""wp-menu-imageimg_class""img_style aria-hidden=""true"">img</div><div class=""wp-menu-name"">" & (-Item.Menu_Title) & "</div></a>");
                        end if;
                     end;
                  end if;

                  if Submenu_Items.Length /= 0 then
--                if not Empty (Submenu_Items) then
                     Echo ("\n\t<ul class=""wp-submenu wp-submenu-wrap"">");
                     Echo ("<li class=""wp-submenu-head"" aria-hidden=""true"">" &
                           (-Item.Menu_Title) & "</li>");

                     First := True;

                     -- 0 := menu_title, 1 := capability, 2 := menu_slug,
                     -- 3 := page_title, 4 := classes.
                     for Sub of Submenu_Items loop
                        declare
                           Sub_Item        : constant Adm_Menu.Submenu_Item := Sub;
                           Class           : List_Type := Empty_List;
                           Aria_Attributes : List_Type := Empty_List;
                        begin
                           if Current_User_Can (-Sub_Item.Capability) then
                              goto Continue_1;
                           end if;

                           if First then
                              Append (Class, +"wp-first-item");  -- ()
                              First := False;
                           end if;

                           declare
                              Menu_File : String  := -Item.Menu_Slug;
                              Pos       : constant Integer := Strpos (Menu_File, "?");

                              -- Handle current for post_type=post|page|foo pages,
                              -- which won't match self.
                              Self_Type : String :=
                                 (if not Empty (-Typenow)
                                  then (-Self) & "?post_type=" & (-Typenow)
                                  else "nothing");
                           begin
                              if 0 /= Pos then
                                 Menu_File := Substr (Menu_File, 0, Pos);
                              end if;

                              if Submenu_File /= "" then
                                 if Submenu_File = Sub_Item.Menu_Slug then
                                    Append (Class,           +"current");  -- ()
                                    Append (Aria_Attributes, +" aria-current=""page""");
                                 end if;
                                 -- If plugin_page is set the parent must either match
                                 -- the current page or not physically exist.
                                 -- This allows plugin pages with the same hook to exist
                                 -- under different parents.
                              elsif
                                (Plugin_Page /= "" and then
                                 Self = Sub_Item.Menu_Slug)
                                or else
                                 (Plugin_Page /= ""               and then
                                  Plugin_Page = Sub_Item.Menu_Slug and then
                                  (Item.Menu_Slug = Self_Type or else
                                   Item.Menu_Slug = Self      or else
                                   File_Exists (Menu_File) = False))
                              then
                                 Append (Class,           +"current");  -- ()
                                 Append (Aria_Attributes, +" aria-current=""page""");
                              end if;

                              if Sub_Item.Classes /= "" then
                                 Append (Class, +ESC_Attr (-Sub_Item.Classes));
                              end if;

                              declare
                                 Class_2 : String :=
                                    (if Length (Class) /= 0
                                     then " class=""" & Implode (" ", Class) & """"
                                     else "");

                                 Menu_Hook : constant String :=
                                    Adi_Plugins.Get_Plugin_Page_Hook
                                       (-Sub_Item.Menu_Slug, -Item.Menu_Slug);

                                 Sub_File : String  := -Sub_Item.Menu_Slug;
                                 Pos      : constant Integer := Strpos (Sub_File, "?");
                              begin
                                 if 0 /= Pos then
                                    Sub_File := Substr (Sub_File, 0, Pos);
                                 end if;

                                 Title :=
                                    +Inc_Formatting.Wptexturize (-Sub_Item.Menu_Title);

                                 if
                                    Menu_Hook /= "" or else
                                    (("index.php" /= Sub_Item.Menu_Slug)       and then
                                     File_Exists (WP_PLUGIN_DIR & "/sub_file") and then
                                     not File_Exists (ABSPATH & "/wp-admin/sub_file"))
                                 then
                                    declare
                                       Sub_Item_Url : Unbounded_String;
                                    begin
                                       -- If admin.php is the current page or if the
                                       -- parent exists as a file in the plugins or
                                       -- admin directory.
                                       if
                                         (not Admin_Is_Parent and then
                                          File_Exists (WP_PLUGIN_DIR & "/menu_file") and then
                                          not Is_Dir (WP_PLUGIN_DIR & "/" &
                                                      (-Item.Menu_Slug))) or else
                                          File_Exists (Menu_File)
                                       then
                                          Sub_Item_Url := Add_Query_Arg (
                                             Arrays.To_Array ((1 =>
                                                Build ("page", -Sub_Item.Menu_Slug))),
                                                        Item.Menu_Slug);
                                       else
                                          Sub_Item_Url := Add_Query_Arg (
                                             Arrays.To_Array ((1 =>
                                                Build ("page", -Sub_Item.Menu_Slug))),
                                                        +"admin.php");
                                       end if;
                                       Sub_Item_Url := +ESC_URL (-Sub_Item_Url);
                                       Echo ("<liclass><a href=""" & (-Sub_Item_Url) &
                                             """classaria_attributes>title</a></li>");
                                    end;
                                 else
                                    Echo ("<liclass><a href=""" & (-Sub_Item.Menu_Slug) &
                                          """classaria_attributes>title</a></li>");
                                 end if;
                              end;
                           end;
                        end;
                        << Continue_1 >>
                     end loop;
                     Echo ("</ul>");
                  end if;
                  Echo ("</li>");
               end;
            end;
         end;
      end loop;

      Echo ("<li id=""collapse-menu"" class=""hide-if-no-js"">" &
            "<button type=""button"" id=""collapse-button"" aria-label=""" &
            Esc_Attr_X ("Collapse Main menu") & """ aria-expanded=""true"">" &
            "<span class=""collapse-button-icon"" aria-hidden=""true""></span>" &
            "<span class=""collapse-button-label"">"" " & abs "Collapse menu" &
            "</span></button></li>");
   end X_Wp_Menu_Output;

   ------------
   -- Bottom --
   ------------

   procedure Bottom
   is
      use Adm_Menu;
      use Inc_Plugins;
   begin
-- ?>
      Echo
         ("<div id=""adminmenumain"" role=""navigation"" aria-label=""" &
          Esc_Attr_E ("Main menu") & """>" &
          "<a href=""#wpbody-content"" class=""screen-reader-shortcut"">" &
          X_E ("Skip to main content") & "</a>" &
          "<a href=""#wp-toolbar"" class=""screen-reader-shortcut"">" &
          X_E ("Skip to toolbar") & "</a>" &
          "<div id=""adminmenuback""></div>" &
          "<div id=""adminmenuwrap"">" &
          "<ul id=""adminmenu"">");

-- <?php

      X_Wp_Menu_Output (Menu, Submenu);
      --
      -- Fires after the admin menu has been output.
      --
      -- @since 2.5.0
      --
      Do_Action ("adminmenu");

-- ?>
      Echo ("</ul></div></div>");
   end Bottom;

end Adm_Menu_Header;
