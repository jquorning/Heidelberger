--
-- Build Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.HTML;
with Php.Lists;
with Php.Strings;
with Php.Types;

with Binder;
with Wp_Common;
with Lists;

with Adi_Plugins;

with Inc_Capabilities;
with Inc_Comments;
with Inc_Formatting;
with Inc_Functions;
with Inc_L10n;
with Inc_Load;
with Inc_Media;
with Inc_Options;
with Inc_Plugins;
with Inc_Posts;
with Inc_Taxonomys;
with Inc_Themes;
with Inc_Updates;
with Class_Post_Type;

package body Adm_Menu
is
   use Arrays;
   use Lists;

   function To_Menu (Menu_Title : String;
                     Capability : String;
                     Menu_Slug  : Adm_Menu.Slug_Type;
                     Page_Title : String;
                     Classes    : String;
                     Hookname   : String := "";
                     Icon_Url   : String := "")
                     return Menu_Item;

   procedure Set (Submenu    : in out Submenu_Type;
                  Menu_Slug  : Adm_Menu.Slug_Type;
                  Position   : Adm_Menu.Submenu_Index;
                  Menu_Title : String;  -- Localized
                  Capability : String;
                  Page_Title : String;
                  Unknown    : String := "";
                  Classes    : String := "");

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Php.HTML;
      use Php.Lists;
      use Php.Strings;
      use Php.Types;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Formatting;
      use Inc_L10n;
      use Inc_Updates;

      Is_Multisite : constant Boolean := Inc_Load.Is_Multisite;
      Cap          : UString;
      I            : Adm_Menu.Submenu_Index; -- Natural;
      Update_Data  : Update_Counts; -- Array_Type;
      Counts_Total : Integer;
   begin
      Menu (2) := To_Menu (abs "Dashboard", "read", "index.php", "",
                           "menu-top menu-top-first menu-icon-dashboard",
                           "menu-dashboard", "dashicons-dashboard");

      Set (Submenu, Menu_Slug  => "index.php",
                    Position   => 0,
                    Menu_Title => abs "Home",
                    Capability => "read",
                    Page_Title => "index.php");

      if Is_Multisite  then -- ()
         Set (Submenu, "index.php", 5, abs "My Sites", "read", "my-sites.php");
      end if;

      if not Is_Multisite or else Current_User_Can ("update_core") then
         Update_Data := Inc_Updates.Wp_Get_Update_Data; -- ();
      end if;

      if not Is_Multisite then
         if Current_User_Can ("update_core") then
            Cap := +"update_core";
         elsif Current_User_Can ("update_plugins") then
            Cap := +"update_plugins";
         elsif Current_User_Can ("update_themes") then
            Cap := +"update_themes";
         else
            Cap := +"update_languages";
         end if;

         Counts_Total := Update_Data.Total;
--       Integer'Value (Get_2 (Update_Data, "counts", "total"));

         Set (Submenu, "index.php", 10,
              Sprintf (
                 -- translators: %s: Number of pending updates.
                 abs "Updates %s",
                 To_List (Sprintf (
                    "<span class=""update-plugins count-%s""><span class=""update-count"">%s</span></span>",
                    [
                      1 => Counts_Total'Image,
                           -- Update_Data ("counts") ("total"),
                      2 => Number_Format_I18n (Float (Counts_Total))
                           -- Update_Data ("counts") ("total"))
                    ]
                  ))),
              -Cap,
              "update-core.php");

--       Unset (Cap);
      end if;

      Menu (4) := To_Menu ("", "read", "separator1", "", "wp-menu-separator");

      -- menu(5) = Posts.

      Menu (10) := To_Menu (abs "Media", "upload_files", "upload.php", "",
                            "menu-top menu-icon-media", "menu-media",
                            "dashicons-admin-media");
      Set (Submenu, "upload.php", 5, abs "Library", "upload_files", "upload.php");
      Set (Submenu, "upload.php", 10,
           -- translators: Add new file.
           X_X ("Add New", "file"), "upload_files", "media-new.php");

      I := 15;
      for Tax of Inc_Media.Get_Taxonomies_For_Attachments ("objects") loop
         if not Tax.Show_UI or else not Tax.Show_In_Menu then
            goto Continue_1;
         end if;

         Set (Submenu, "upload.php", I, ESC_Attr (As_String (Get (Tax.Labels, "menu_name"))),
              As_String (Get (Tax.Cap, "manage_terms")),
              "edit-tags.php?taxonomy=" & (-Tax.Name) & "&amp;post_type=attachment");
         I := I + 1;
         << Continue_1 >>
      end loop;
--      Unset (Tax, I);

      Menu (15) := To_Menu (abs "Links", "manage_links", "link-manager.php", "",
                            "menu-top menu-icon-links", "menu-links",
                            "dashicons-admin-links");
      Set (Submenu, "link-manager.php", 5, X_X ("All Links", "admin menu"),
           "manage_links", "link-manager.php");
      -- translators: Add new links.
      Set (Submenu, "link-manager.php", 10, X_X ("Add New", "link"),
           "manage_links", "link-add.php");
      Set (Submenu, "link-manager.php", 15, abs "Link Categories",
           "manage_categories", "edit-tags.php?taxonomy=link_category");

      -- menu(20) = Pages.

      -- Avoid the comment count query for users who cannot edit_posts.
      if Current_User_Can ("edit_posts") then
         declare
            Comments : constant Inc_Comments.Comment_Counts :=
               Inc_Comments.Wp_Count_Comments; --();
            Awaiting_Mod      : constant Integer := Comments.Moderated;
            Awaiting_Mod_I18n : constant String  :=
               Number_Format_I18n (Float (Awaiting_Mod));
            -- translators: %s: Number of comments
            Awaiting_Mod_Text : constant String :=
               Sprintf (X_N ("%s Comment in moderation",
                              "%s Comments in moderation",
                              Awaiting_Mod),
                        To_List (Awaiting_Mod_I18n));
         begin
            Menu (25) := To_Menu (
              -- translators: %s: Number of comments.
              Sprintf (
                abs "Comments %s",
                To_List ("<span class=""awaiting-mod count-" &
                         Awaiting_Mod'Image &
                         """><span class=""pending-count"" aria-hidden=""true"">" &
                         Awaiting_Mod_I18n &
                         "</span><span class=""comments-in-moderation-text " &
                         "screen-reader-text"">" &
                         Awaiting_Mod_Text & "</span></span>")),
                "edit_posts",
                "edit-comments.php",
                "",
                "menu-top menu-icon-comments",
                "menu-comments",
                "dashicons-admin-comments"
            );
         end;
--         Unset (Awaiting_Mod);
      end if;

      Set (Submenu, "edit-comments.php", 0, abs "All Comments",
           "edit_posts", "edit-comments.php");

      declare
         use Class_Post_Type;
         use Inc_Posts;

         X_Wp_Last_Object_Menu : Natural := 25;
         -- The index of the last top-level menu in the object menu group.

         Types  : constant List_Type := Get_Post_Types (  -- (array)
            Arrays.To_Array ((
                Build ("show_ui",      "true"),
                Build ("_builtin",     "false"),
                Build ("show_in_menu", "true"))));

--         Builtin : constant String_Array := String_Array'(1 => "post", 2 => "page");
--            Arrays.To_Array ((
--               Build ("post", ""),
--               Build ("page", "")));
      begin
         for Ptype of Types loop -- String_Array'(Builtin & Types) loop -- Array_Merge (Builtin, Types) loop
            declare
               Ptype_Obj : constant Class_Post_Type.Wp_Post_Type :=
                  Inc_Posts.Get_Post_Type_Object (Ptype);
               Ptype_Menu_Position : Menu_Index;
               Ptype_For_Id        : UString;
               Menu_Icon           : UString;
               Menu_Class          : UString;
               Ptype_File          : Unbounded_Slug;
               Post_New_File       : UString;
               Edit_Tags_File      : UString;
               Ptype_Menu_Id       : UString;
            begin

               -- Check if it should be a submenu.
               if  True /= Ptype_Obj.Show_In_Menu_Bool then
                  goto Continue_2;
               end if;

               if Is_Int (Ptype_Obj.Menu_Position) then
                  Ptype_Menu_Position := Menu_Index (Ptype_Obj.Menu_Position);
               else
                  X_Wp_Last_Object_Menu := X_Wp_Last_Object_Menu + 1;
               end if;

               -- If we"re to use _wp_last_object_menu, increment it first.
               Ptype_For_Id := +Inc_Formatting.Sanitize_HTML_Class (Ptype);
               Menu_Icon    := +"dashicons-admin-post";

               if Is_String (-Ptype_Obj.Menu_Icon) then
                  -- Special handling for data:image/svg+xml and Dashicons.
                  if
                    0 = Strpos (-Ptype_Obj.Menu_Icon, "data:image/svg+xml;base64,") or else
                    0 = Strpos (-Ptype_Obj.Menu_Icon, "dashicons-")
                  then
                     Menu_Icon := Ptype_Obj.Menu_Icon;
                  else
                     Menu_Icon := +ESC_URL (-Ptype_Obj.Menu_Icon);
                  end if;
--               elsif In_Array (Ptype, Builtin, True) then
--                  Menu_Icon := "dashicons-admin-" & Ptype;
               end if;

               Menu_Class := "menu-top menu-icon-" & Ptype_For_Id;
               -- "post" special case.
               if "post" = Ptype then
                  Menu_Class     := Menu_Class & " open-if-no-js";
                  Ptype_File     := +"edit.php";
                  Post_New_File  := +"post-new.php";
                  Edit_Tags_File := +"edit-tags.php?taxonomy=%s";
               else
                  Ptype_File     := +"edit.php?post_type=ptype";
                  Post_New_File  := +"post-new.php?post_type=ptype";
                  Edit_Tags_File := +"edit-tags.php?taxonomy=%s&amp;post_type=ptype";
               end if;

--               if In_Array (Ptype, Builtin, True) then
--                  Ptype_Menu_Id := "menu-" & Ptype_For_Id & "s";
--               else
                  Ptype_Menu_Id := "menu-posts-" & Ptype_For_Id;
--               end if;

               --
               -- If ptype_menu_position is already populated or will be populated
               -- by a hard-coded value below, increment the position.
               --
               while
                 Menu (Ptype_Menu_Position).Menu_Title /= "" or else
                 -- Isset (Menu (Ptype_Menu_Position)) or else
                 Ptype_Menu_Position in 59 | 60 | 65 | 70 | 75 | 80 | 85 | 99
--               In_Array (Ptype_Menu_Position, Core_Menu_Positions, True)
               loop
                  Ptype_Menu_Position := Ptype_Menu_Position + 1;
               end loop;

               Menu (Ptype_Menu_Position)  :=
                  To_Menu (ESC_Attr (Get (Ptype_Obj, "labels.menu_name")),
                           As_String (Get (Ptype_Obj.Cap, "edit_posts")),
                           -Ptype_File, "", -Menu_Class, -Ptype_Menu_Id, -Menu_Icon);

               Set (Submenu, -Ptype_File, 5, Get (Ptype_Obj, "labels.all_items"),
                    As_String (Get (Ptype_Obj.Cap, "edit_posts")), String (-Ptype_File));

               Set (Submenu, -Ptype_File, 10, Get (Ptype_Obj, "labels.add_new"),
                    As_String (Get (Ptype_Obj.Cap, "create_posts")), -Post_New_File);

               I := 15;
               for Tax of Inc_Taxonomys.Get_Taxonomies (Empty_Array, "objects") loop
                  if
                    not Tax.Show_UI      or else
                    not Tax.Show_In_Menu or else
                    not In_List (Ptype, Tax.Object_Type, True) -- (array)
                  then
                     goto Continue_3;
                  end if;

                  Set (Submenu, -Ptype_File, I,
                       ESC_Attr (As_String (Get (Tax.Labels, "menu_name"))),
                       As_String (Get (Tax.Cap, "manage_terms")),
                       Sprintf (-Edit_Tags_File, To_List (-Tax.Name)));
                  I := I + 1;
                  << Continue_3 >>
               end loop;
            end;
            << Continue_2 >>
         end loop;

--      Unset (ptype, ptype_obj, ptype_for_id, ptype_menu_position, menu_icon, i, tax, post_new_file);
      end;

      Menu (59) := To_Menu ("", "read", "separator2", "", "wp-menu-separator");

      declare
         Appearance_Cap : String := (if Current_User_Can ("switch_themes")
                                     then "switch_themes"
                                     else "edit_theme_options");
      begin
         Menu (60) := To_Menu (abs "Appearance", Appearance_Cap, "themes.php", "",
                               "menu-top menu-icon-appearance", "menu-appearance",
                               "dashicons-admin-appearance");

         declare
            Count       : UString;
            Update_Date : Update_Counts; -- Array_Type;
         begin
            if not Is_Multisite and then Current_User_Can ("update_themes") then
               if True then -- not Isset (Update_Data) then
                  Update_Data := Inc_Updates.Wp_Get_Update_Data;  -- ();
               end if;

               declare
                  Theme_Count : constant String := Natural'Image (Update_Data.Themes);
--                Theme_Count : constant String := Get_2 (Update_Data, "counts",
--                                                                     "themes");
               begin
                  Count := +Sprintf (
                     "<span class=""update-plugins count-%s""><span class=""theme-count"">%s</span></span>",
                     [
                       1 => Theme_Count,
                       2 => Number_Format_I18n (Float'Value (Theme_Count))
                     ]
                   );
               end;
            end if;

            -- translators: %s: Number of available theme updates.
            Set (Submenu, "themes.php", 5, Sprintf (abs "Themes %s", To_List (-Count)),
                 Appearance_Cap, "themes.php");
         end;

         if Inc_Themes.Wp_Is_Block_Theme then -- ()
            Set (Submenu, "themes.php", 6,
              Sprintf (
                -- translators: %s: "beta" label
                abs "Editor %s",
                To_List ("<span class=""awaiting-mod"">" & abs "beta" & "</span>"
              )),
              "edit_theme_options",
              "site-editor.php");
         end if;

         if
           not Inc_Themes.Wp_Is_Block_Theme and then
           Inc_Themes.Current_Theme_Supports ("block-template-parts")
         then
            Set (Submenu, "themes.php", 6,
                abs "Template Parts",
                "edit_theme_options",
                "site-editor.php?postType=wp_template_part");
         end if;

         declare
            use Inc_Plugins;
            use Inc_Themes;

            Customize_Url : constant String :=
                Add_Query_Arg
                  ("return",
                   URL_Encode (Remove_Query_Arg (List_Type'(Wp_Removable_Query_Args),
                                          Wp_Unslash (As_String (Get (X_SERVER, "REQUEST_URI"))))),
                   "customize.php");
         begin
            -- Hide Customize link on block themes unless a plugin or theme
            -- is using "customize_register" to add a setting.
            if not Wp_Is_Block_Theme or Has_Action ("customize_register") then

               declare
                  Block_Theme : constant Boolean :=
                     Wp_Is_Block_Theme or else
                     Current_Theme_Supports ("block-template-parts");

                  Position : constant Adm_Menu.Submenu_Index :=
                     (if Block_Theme then 7 else 6);
               begin
                  Set (Submenu, "themes.php", Position, abs "Customize", "customize",
                       ESC_URL (Customize_Url), "", "hide-if-no-customize");
               end;
            end if;

            if
              Current_Theme_Supports ("menus") or else
              Current_Theme_Supports ("widgets")
            then
               Set (Submenu, "themes.php", 10, abs "Menus", "edit_theme_options",
                    "nav-menus.php");
            end if;

            if
              Current_Theme_Supports ("custom-header") and then
              Current_User_Can ("customize")
            then
               declare
                  Array_1 : constant Array_Type := Arrays.To_Array ((1 =>
                                                   Build ("control", "header_image")));
                  Array_2 : constant Array_Type := Arrays.To_Array ((1 =>
                                                   Build ("autofocus", Array_1)));
                  Customize_Header_Url : constant String :=
                     Add_Query_Arg (Array_2, Customize_Url);
               begin
                  Set (Submenu, "themes.php", 15, abs "Header", Appearance_Cap,
                       ESC_URL (Customize_Header_Url), "", "hide-if-no-customize");
               end;
            end if;

            if
              Current_Theme_Supports ("custom-background") and then
              Current_User_Can ("customize")
            then
               declare
                  Array_1 : constant Array_Type :=
                     Arrays.To_Array ((1 => Build ("control", "background_image")));

                  Array_2 : constant Array_Type :=
                     Arrays.To_Array ((1 => Build ("autofocus", Array_1)));

                  Customize_Background_Url : constant String :=
                     Add_Query_Arg (Array_2, Customize_Url);
               begin
                  Set (Submenu, "themes.php", 20, abs "Background", Appearance_Cap,
                       ESC_URL (Customize_Background_Url), "", "hide-if-no-customize");
               end;
            end if;

--          Unset (Customize_Url);
--          Unset (Appearance_Cap);
         end;
      end;

         -- Add "Theme File Editor" to the bottom of the Appearance (non-block themes)
         -- or Tools (block themes) menu.
         if not Is_Multisite  then
            -- Must use API on the admin_menu hook, direct modification is only
            -- possible on/before the _admin_menu hook.
            Inc_Plugins.Add_Action
              ("admin_menu", X_Add_Themes_Utility_Last'Access, 101);
         end if;

         declare
            Count        : UString;
            Update_Date  : Update_Counts; -- Array_Type;
            Plugin_Count : UString;
         begin
            if not Is_Multisite and then Current_User_Can ("update_plugins") then
               if True then -- not Isset (Update_Data) then
                  Update_Data := Inc_Updates.Wp_Get_Update_Data; -- ();
               end if;
               Plugin_Count := +Natural'Image (Update_Data.Plugins);
--             Plugin_Count := +Get_2 (Update_Data, "counts", "plugins");
               Count := +Sprintf (
                  "<span class=""update-plugins count-%s""><span class=""plugin-count"">%s</span></span>",
                  [
                    1 => -Plugin_Count,
                    2 => Number_Format_I18n (Float'Value (-Plugin_Count))
                  ]
                );
            end if;

            -- translators: %s: Number of available plugin updates.
            Menu (65) := To_Menu (Sprintf (abs "Plugins %s", To_List (-Count)),
                               "activate_plugins",
                               "plugins.php", "", "menu-top menu-icon-plugins",
                               "menu-plugins", "dashicons-admin-plugins");
         end;

         Set (Submenu, "plugins.php", 5, abs "Installed Plugins",
              "activate_plugins", "plugins.php");

         if not Is_Multisite then
            -- translators: Add new plugin.
            Set (Submenu, "plugins.php", 10, X_X ("Add New", "plugin"),
                 "install_plugins", "plugin-install.php");
            if Inc_Themes.Wp_Is_Block_Theme then
               -- Place the menu item below the Theme File Editor menu item.
               Inc_Plugins.Add_Action ("admin_menu",
                                       X_Add_Plugin_File_Editor_To_Tools'Access,
                                       101);
            else
               Set (Submenu, "plugins.php", 15, abs "Plugin File Editor",
                    "edit_plugins", "plugin-editor.php");
            end if;
         end if;

--       Unset (Update_Data);

         if Current_User_Can ("list_users") then
            Menu (70) := To_Menu (abs "Users", "list_users", "users.php", "",
                                  "menu-top menu-icon-users", "menu-users",
                                  "dashicons-admin-users");
         else
            Menu (70) := To_Menu (abs "Profile", "read", "profile.php", "",
                                  "menu-top menu-icon-users", "menu-users",
                                  "dashicons-admin-users");
         end if;

         if Current_User_Can ("list_users") then
            Set (X_Wp_Real_Parent_File, "profile.php", From_String ("users.php"));
            -- Back-compat for plugins adding submenus to profile.php.

            Set (Submenu, "users.php", 5, abs "All Users", "list_users",
                 "users.php");
            if Current_User_Can ("create_users") then
               Set (Submenu, "users.php", 10, X_X ("Add New", "user"),
                    "create_users", "user-new.php");
            elsif Is_Multisite then
               Set (Submenu, "users.php", 10, X_X ("Add New", "user"),
                    "promote_users", "user-new.php");
            end if;

            Set (Submenu, "users.php", 15, abs "Profile", "read", "profile.php");
         else
            Set (X_Wp_Real_Parent_File, "users.php", From_String ("profile.php"));
            Set (Submenu, "profile.php", 5, abs "Profile", "read", "profile.php");

            if Current_User_Can ("create_users") then
               Set (Submenu, "profile.php", 10, abs "Add New User", "create_users",
                    "user-new.php");
            elsif Is_Multisite then
               Set (Submenu, "profile.php", 10, abs "Add New User", "promote_users",
                    "user-new.php");
            end if;
         end if;

         declare
            Site_Health_Count : UString;
         begin
            if not Is_Multisite and then
               Current_User_Can ("view_site_health_checks")
            then
               declare
--                use Array_Maps;

                  Get_Issues   : String :=
                     As_String (
                       Inc_Options.Get_Transient ("health-check-site-status-result"));
                  Issue_Counts : Array_Type := Empty_Array;
               begin
                  -- if False /= Get_Issues then
                  --    Issue_Counts := Json_Decode (Get_Issues, True);
                  -- end if;

                  if
                    not Is_Array (Issue_Counts) or else
                    Issue_Counts = Empty_Array
                  then
                     Issue_Counts := Arrays.To_Array ((
                        Build ("good",        "0"),
                     Build ("recommended", "0"),
                     Build ("critical",    "0")));
                  end if;

                  declare
                     Health : constant String := As_String (Get (Issue_Counts, "critical"));
                  begin
                     Site_Health_Count := +Sprintf (
                        "<span class=""menu-counter site-health-counter count-%s""><span class=""count"">%s</span></span>",
                        [
                          1 => Health,
                          2 => Number_Format_I18n (Float'Value (Health))
                        ]);
                  end;
               end;
            end if;

            Menu (75) := To_Menu (abs "Tools", "edit_posts", "tools.php", "",
                                  "menu-top menu-icon-tools", "menu-tools",
                                  "dashicons-admin-tools");
            Set (Submenu, "tools.php", 5, abs "Available Tools", "edit_posts",
                 "tools.php");
            Set (Submenu, "tools.php", 10, abs "Import", "import", "import.php");
            Set (Submenu, "tools.php", 15, abs "Export", "export", "export.php");
            -- translators: %s: Number of critical Site Health checks.
            Set (Submenu, "tools.php", 20, Sprintf (abs "Site Health %s",
                                                    To_List (-Site_Health_Count)),
                 "view_site_health_checks", "site-health.php");
            Set (Submenu, "tools.php", 25, abs "Export Personal Data",
                 "export_others_personal_data", "export-personal-data.php");
            Set (Submenu, "tools.php", 30, abs "Erase Personal Data",
                 "erase_others_personal_data", "erase-personal-data.php");
         end;

         if Is_Multisite and then not Inc_Functions.Is_Main_Site  then
            Set (Submenu, "tools.php", 35, abs "Delete Site", "delete_site",
                 "ms-delete-site.php");
         end if;

         -- if
         --   not Is_Multisite and then
         --   defined ("WP_ALLOW_MULTISITE") and then
         --   WP_ALLOW_MULTISITE
         -- then
         --    Set (Submenu, "tools.php", 50, abs "Network Setup", "setup_network",
         --         "network.php");
         -- end if;

         Menu (80) := To_Menu (abs "Settings", "manage_options",
                               "options-general.php",
                               "", "menu-top menu-icon-settings", "menu-settings",
                               "dashicons-admin-settings");
         Set (Submenu, "options-general.php", 10,
              X_X ("General", "settings screen"),
              "manage_options", "options-general.php");
         Set (Submenu, "options-general.php", 15, abs "Writing", "manage_options",
              "options-writing.php");
         Set (Submenu, "options-general.php", 20, abs "Reading", "manage_options",
              "options-reading.php");
         Set (Submenu, "options-general.php", 25, abs "Discussion",
              "manage_options", "options-discussion.php");
         Set (Submenu, "options-general.php", 30, abs "Media", "manage_options",
              "options-media.php");
         Set (Submenu, "options-general.php", 40, abs "Permalinks",
              "manage_options", "options-permalink.php");
         Set (Submenu, "options-general.php", 45, abs "Privacy",
              "manage_privacy_options", "options-privacy.php");

--          X_wp_Last_Utility_Menu := 80;
            -- The index of the last top-level menu in the utility menu group.

         Menu (99) := To_Menu ("", "read", "separator-last", "",
                               "wp-menu-separator");

      -- -- Back-compat for old top-levels.
      -- X_wp_Real_Parent_File ("post.php")       := "edit.php";
      -- X_wp_Real_Parent_File ("post-new.php")   := "edit.php";
      -- X_wp_Real_Parent_File ("edit-pages.php") := "edit.php?post_type=page";
      -- X_wp_Real_Parent_File ("page-new.php")   := "edit.php?post_type=page";
      -- X_wp_Real_Parent_File ("wpmu-admin.php") := "tools.php";
      -- X_wp_Real_Parent_File ("ms-admin.php")   := "tools.php";

      -- -- Ensure backward compatibility.
      -- Compat := To_Array ((
      --    Build ("index",           "dashboard"),
      --    Build ("edit",            "posts"),
      --    Build ("post",            "posts"),
      --    Build ("upload",          "media"),
      --    Build ("link-manager",    "links"),
      --    Build ("edit-pages",      "pages"),
      --    Build ("page",            "pages"),
      --    Build ("edit-comments",   "comments"),
      --    Build ("options-general", "settings"),
      --    Build ("themes",          "appearance")
      -- ));
   end Run;

   ---------------------
   -- Filter_And_Sort --
   ---------------------

   function Filter_And_Sort (Submenu : Submenu_Type)
                             return Submenu_Type
   is
   begin
      return Submenu;
   end Filter_And_Sort;

   -------------
   -- To_Menu --
   -------------

   function To_Menu (Menu_Title : String;
                     Capability : String;
                     Menu_Slug  : Adm_Menu.Slug_Type;
                     Page_Title : String;
                     Classes    : String;
                     Hookname   : String := "";
                     Icon_Url   : String := "")
                     return Menu_Item
   is
      use UStrings;

      Item : constant Menu_Item :=
         (Menu_Title  =>  +Menu_Title,
          Capability  =>  +Capability,
          Menu_Slug   =>  +Menu_Slug,
          Page_Title  =>  +Page_Title,
          Classes     =>  +Classes,
          Hookname    =>  +Hookname,
          Icon_Url    =>  +Icon_Url);
   begin
      return Item;
   end To_Menu;

   ---------
   -- Set --
   ---------

   procedure Set (Submenu    : in out Submenu_Type;
                  Menu_Slug  : Adm_Menu.Slug_Type;
                  Position   : Adm_Menu.Submenu_Index;
                  Menu_Title : String;  -- Localized
                  Capability : String;
                  Page_Title : String;
                  Unknown    : String := "";
                  Classes    : String := "")
   is
      use UStrings;
      -- Submenu (position : int) (menu_slug : map) of submenu_item

      Sub_Item : constant Submenu_Item :=
        (Menu_Title  =>  +Menu_Title,
         Capability  =>  +Capability,
         Menu_Slug   =>  +Menu_Slug,
         Page_Title  =>  +Page_Title,
         Classes     =>  +Classes);

      use Submenu_Maps;
      use Inner_Maps;

      B : constant Submenu_Maps.Cursor := Submenu.Find (Menu_Slug);
--    A : Inner_Maps.Map := Submenu (Menu_Slug);
   begin
      if not Submenu_Maps.Has_Element (B) then
--    if A = Inner_Maps.Empty_Map then
         declare
            Map : Inner_Maps.Map;
         begin
            Map.Include (Key => Position, New_Item => Sub_Item);
            Submenu.Include (Key => Menu_Slug, New_Item => Map);
         end;
      else
         declare
            A : Inner_Maps.Map := Submenu (Menu_Slug);
--          M : Submenu_Maps.Map;
            E : constant Inner_Maps.Cursor := A.Find (Key => Position);
         begin
            if E = Inner_Maps.No_Element then
               A.Include (Key => Position, New_Item => Sub_Item);
            else
               A.Include (Key => Position, New_Item => Sub_Item);
            end if;

         end;
      end if;
--    Adm_Menu.Submenu (Position) := Item;
   end Set;

   -------------------------------
   -- X_Add_Themes_Utility_Last --
   -------------------------------

   procedure X_Add_Themes_Utility_Last
   is
      use Adi_Plugins;
      use Inc_Themes;
      use Inc_L10n;
   begin
      Add_Submenu_Page (
        (if Wp_Is_Block_Theme then "tools.php" else "themes.php"),
        abs "Theme File Editor",
        abs "Theme File Editor",
        "edit_themes",
        "theme-editor.php");
   end X_Add_Themes_Utility_Last;

   ---------------------------------------
   -- X_Add_Plugin_File_Editor_To_Tools --
   ---------------------------------------

   procedure X_Add_Plugin_File_Editor_To_Tools
   is
      use Adi_Plugins;
      use Inc_Themes;
      use Inc_L10n;
   begin
      if not Wp_Is_Block_Theme then
         return;
      end if;

      Add_Submenu_Page (
        "tools.php",
        abs "Plugin File Editor",
        abs "Plugin File Editor",
        "edit_plugins",
        "plugin-editor.php");
   end X_Add_Plugin_File_Editor_To_Tools;

end Adm_Menu;
-- require_once ABSPATH . "wp-admin/includes/menu.php";
