
with Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

--  with Templates_Parser;

with L10n;

with HB_Common;

--
-- Build Administration Menu.
--
-- @package WordPress
-- @subpackage Administration
--

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

package body Hb_Menu
is
   use Ada.Strings.Unbounded;
   use L10n;
   use HB_Common;

   function run
   is

Menu (2) := To_Array (abs "Dashboard", "read", "index.php", "", "menu-top menu-top-first menu-icon-dashboard", "menu-dashboard", "dashicons-dashboard");

Submenu ("index.php") (0) := To_Array (abs "Home", "read", "index.php");

if Is_Multisite  then -- ()
        Submenu ("index.php") (5) := To_Array (abs "My Sites", "read", "my-sites.php");
end if;

if not Is_Multisite or else Current_User_Can ("update_core") then
        Update_Data := Hb_Get_Update_Data; -- ();
end if;

if not Is_Multisite then
        if Current_User_Can ("update_core") then
                Cap := "update_core";
        elsif Current_User_Can ("update_plugins")) then
                Cap := "update_plugins";
        elsif current_user_can ("update_themes")) then
                Cap := "update_themes";
        else
                Cap := "update_languages";
        end if;
        Submenu ("index.php") (10) := To_Array (
                Sprintf (
                        -- translators: %s: Number of pending updates.
                        abs "Updates %s",
                        Sprintf (
                                "<span class=""update-plugins count-%s""><span class=""update-count"">%s</span></span>",
                                Update_Data ("counts") ("total"),
                                Number_Format_I18n (Update_Data ("counts") ("total"))
                       )
                ),
                cap,
                "update-core.php"
        );
        Unset (Cap);
end if;

Menu (4) := To_Array ("", "read", "separator1", "", "wp-menu-separator");

-- menu(5) = Posts.

Menu (10) := To_array (abs "Media", "upload_files", "upload.php", "", "menu-top menu-icon-media", "menu-media", "dashicons-admin-media");
        Submenu ("upload.php") (5) := To_Array (abs "Library", "upload_files", "upload.php");
        -- translators: Add new file.
        Submenu ("upload.php") (10) := To_array (X_X ("Add New", "file") , "upload_files", "media-new.php");
        I : = 15;
for Tax of Get_Taxonomies_For_Attachments ("objects") loop
        if not Tax.Show_UI or else not Tax.Show_In_Menu then
                goto Continue;
        end if;

        Submenu ("upload.php") (I) := To_Array (ESC_Attr (Tax.Labels.Menu_name) , Tax.Cap.Manage_Terms, "edit-tags.php?taxonomy=" . Tax.name & "&amp;post_type=attachment");
        I := I + 1;
end loop;
        Unset (Tax, I);

Menu (15) := To_array (abs "Links", "manage_links", "link-manager.php", "", "menu-top menu-icon-links", "menu-links", "dashicons-admin-links");
        Submenu ("link-manager.php") (5) := To_array (X_X ("All Links", "admin menu") , "manage_links", "link-manager.php");
        -- translators: Add new links.
        Submenu ("link-manager.php") (10) = To_array (X_X ("Add New", "link"), "manage_links", "link-add.php");
        Submenu ("link-manager.php") (15) = To_array (abs "Link Categories", "manage_categories", "edit-tags.php?taxonomy=link_category");

-- menu(20) = Pages.

-- Avoid the comment count query for users who cannot edit_posts.
if Current_User_Can ("edit_posts") then
        Awaiting_Mod      := Wp_Count_Comments; --();
        Awaiting_Mod      := Awaiting_Mod.Moderated;
        awaiting_mod_i18n := Number_Format_I18n (Awaiting_Mod);
        -- translators: %s: Number of comments
        Awaiting_Mod_Text = Sprintf (N_N ("%s Comment in moderation", "%s Comments in moderation", awaiting_mod) , awaiting_mod_i18n);

        Menu (25) := To_Array (
                -- translators: %s: Number of comments.
                sprintf (abs "Comments %s", "<span class=""awaiting-mod count-" & Absint (Awaiting_Mod)  & """><span class=""pending-count"" aria-hidden=""true"">" & Awaiting_Mod_I18n & "</span><span class=""comments-in-moderation-text screen-reader-text"">" & Awaiting_Mod_Text & "</span></span>"),
                "edit_posts",
                "edit-comments.php",
                "",
                "menu-top menu-icon-comments",
                "menu-comments",
                "dashicons-admin-comments"
       );
        Unset (Awaiting_Mod);
end if;

Submenu ("edit-comments.php") (0) = To_Array (abs "All Comments", "edit_posts", "edit-comments.php");

X_HP_Last_Object_Menu := 25; -- The index of the last top-level menu in the object menu group.

Types   := (array) Get_Post_Types (
        To_Array ((
                Build ("show_ui",      True),
                Build ("_builtin",     False),
                Build ("show_in_menu", True),
       ))
);
Builtin := To_Array ("post", "page");
foreach  (array_merge (builtin, types)  as ptype)  then
        Ptype_Obj := Get_Post_Type_Object (Ptype);
        -- Check if it should be a submenu.
        if  True /= Ptype_Obj.Show_In_Menu then
                goto Continue;
        end if;
        Ptype_Menu_Position := (if Is_Int (Ptype_Obj.Menu_Position) then Ptype_Obj.Menu_Position else ++_Wp_Last_Object_Menu);
        -- If we"re to use _wp_last_object_menu, increment it first.
        Ptype_For_Id        := Sanitize_Html_Class (Ptype);

        Menu_Icon := "dashicons-admin-post";
        if Is_String (Ptype_Obj.Menu_Icon) then
                -- Special handling for data:image/svg+xml and Dashicons.
                if 0 = Strpos (Ptype_Obj.Menu_Icon, "data:image/svg+xml;base64,") or else 0 = Strpos (Ptype_Obj.Menu_Icon, "dashicons-") then
                        Menu_Icon := Ptype_Obj.Menu_Icon;
                else
                        Menu_Icon := ESC_URL (Ptype_Obj.Menu_Icon);
                end if;
        elsif In_Array (Ptype, Builtin, True) then
                Menu_Icon := "dashicons-admin-" & Ptype;
        end if;

        Menu_Class := "menu-top menu-icon-" & Ptype_For_Id;
        -- "post" special case.
        if "post" = ptype then
                Menu_Class     := Menu_Class & " open-if-no-js";
                Ptype_File     := "edit.php";
                Post_New_File  := "post-new.php";
                Edit_Tags_File := "edit-tags.php?taxonomy=%s";
        else
                Ptype_File     := "edit.php?post_type=ptype";
                Post_New_File  := "post-new.php?post_type=ptype";
                Edit_Tags_File := "edit-tags.php?taxonomy=%s&amp;post_type=ptype";
        end if;

        if in_array (Ptype, Builtin, True) then
                Ptype_Menu_Id := "menu-" & Ptype_For_Id & "s";
        else
                Ptype_Menu_Id := "menu-posts-" & Ptype_For_Id;
        end if;
        --
        -- If ptype_menu_position is already populated or will be populated
        -- by a hard-coded value below, increment the position.
        --
        Core_Menu_Positions := To_array (59, 60, 65, 70, 75, 80, 85, 99);
        while Isset (Menu (Ptype_Menu_Position)) or else In_Array (ptype_menu_position, Core_Menu_Positions, True) then
                Ptype_Menu_Position := Ptype_Menu_Position + 1;
        end loop;

        Menu (Ptype_Menu_Position)  := To_Array (ESC_Attr (Ptype_Obj.Labels.Menu_Name), Ptype_Obj.Cap.Edit_Posts, Ptype_File, "", Menu_Class, Ptype_Menu_Id, Menu_Icon);
        Submenu (Ptype_File) (5)    := To_Array (Ptype_Obj.Labels.All_Items, Ptype_Obj.Cap.Edit_Posts,   Ptype_File);
        Submenu (Ptype_File) (10)   := To_Array (Ptype_Obj.Labels.Add_New,   Ptype_Obj.Cap.Create_Posts, Post_New_File);

        i := 15;
        for Tax of Get_Taxonomies (To_array(), "objects") loop
                if not Tax.Show_UI or else not Tax.Show_In_Menu or else not In_Array (Ptype, (array) Tax.Object_Type, True)) then
                        goto continue;
                end if;

                Submenu (Ptype_File)  (i++)  := To_Array (ESC_Attr (Tax.Labels.Menu_name) , Tax.Cap.Manage_Terms, sprintf (Edit_Tags_File, Tax.Name));
        end loop;
end;
Unset (ptype, ptype_obj, ptype_for_id, ptype_menu_position, menu_icon, i, tax, post_new_file);

Menu (59) := To_array ("", "read", "separator2", "", "wp-menu-separator");

Appearance_Cap := (if current_user_can ("switch_themes") then "switch_themes" else "edit_theme_options");

Menu (60) := To_Array (abs "Appearance", Appearance_Cap, "themes.php", "", "menu-top menu-icon-appearance", "menu-appearance", "dashicons-admin-appearance");

count := "";
if not Is_Multisite and then Current_User_Can ("update_themes") then
        if not Isset (Update_Data)) then
                Update_Data := Hb_Get_Update_Data;  -- ();
        end if;
        Count := Sprintf (
                "<span class=""update-plugins count-%s""><span class=""theme-count"">%s</span></span>",
                Update_Data ("counts") ("themes"),
                Number_Format_I18n (Update_Data ("counts") ("themes"))
       );
end if;

        -- translators: %s: Number of available theme updates.
        Submenu ("themes.php") (5) := To_array (Sprintf (abs "Themes %s", Count) , Appearance_Cap, "themes.php");

if Hb_Is_Block_Theme then -- ()
        Submenu ("themes.php") (6) := To_Array (
                Sprintf (
                        -- translators: %s: "beta" label
                        abs "Editor %s",
                        "<span class=""awaiting-mod"">" & abs "beta" & "</span>"
               ),
                "edit_theme_options",
                "site-editor.php"
       );
end if;

if not Hb_Is_Block_Theme and then Current_Theme_Supports ("block-template-parts") then
        Submenu ("themes.php") (6) := To_Array (
                abs "Template Parts",
                "edit_theme_options",
                "site-editor.php?postType=wp_template_part"
       );
end if;

Customize_Url := Add_Query_Arg ("return", Urlencode (Remove_Query_Arg (Hb_Removable_Query_Args, Hb_Unslash (X_SERVER ("REQUEST_URI")))) , "customize.php");

-- Hide Customize link on block themes unless a plugin or theme
-- is using "customize_register" to add a setting.
if not Hb_Is_Block_Theme or Has_Action ("customize_register") then
        position :=  (if Hb_Is_Block_Theme or else Current_Theme_Supports ("block-template-parts") then 7 else 6);

        Submenu ("themes.php") (Position) := To_Array (abs "Customize", "customize", ESC_URL (Customize_Url), "", "hide-if-no-customize");
end if;

if  Current_Theme_Supports ("menus") or else Current_Theme_Supports ("widgets") then
        Submenu ("themes.php") (10) := To_array (abs "Menus" , "edit_theme_options", "nav-menus.php");
end if;

if Current_Theme_Supports ("custom-header")  and then Current_User_Can ("customize") then
        Customize_Header_Url        := Add_Query_Arg (Tp_array ("autofocus" => To_array ("control" => "header_image") ), Customize_Url);
        Submenu ("themes.php") (15) := To_Array (abs "Header", Appearance_Cap, ESC_URL (Customize_Header_Url), "", "hide-if-no-customize");
end if;

if Current_Theme_Supports ("custom-background") and then Current_User_Can ("customize") then
        Customize_Background_Url    := Add_Query_Arg (To_Array ("autofocus" => To_Array ("control" => "background_image") ) , Customize_Url);
        Submenu ("themes.php") (20) := To_Array (abs "Background", Appearance_Cap, ESC_URL (Customize_Background_Url) , "", "hide-if-no-customize");
end if;

Unset (Customize_Url);
Unset (Appearance_Cap);

-- Add "Theme File Editor" to the bottom of the Appearance (non-block themes) or Tools (block themes) menu.
if not Is_Multisite  then
        -- Must use API on the admin_menu hook, direct modification is only possible on/before the _admin_menu hook.
        Add_Action ("admin_menu", "_add_themes_utility_last", 101);
end if;

--
-- Adds the "Theme File Editor" menu item to the bottom of the Appearance (non-block themes)
-- or Tools (block themes) menu.
--
-- @access private
-- @since 3.0.0
-- @since 5.9.0 Renamed "Theme Editor" to "Theme File Editor".
--              Relocates to Tools for block themes.
--

procedure X_Add_Themes_Utility_Last is
begin
        Add_Submenu_Page (
                (if Hb_Is_Block_Theme then "tools.php" else "themes.php"),
                abs "Theme File Editor",
                abs "Theme File Editor",
                "edit_themes",
                "theme-editor.php"
       );
end X_Add_Themes_Utility_Last;

--
-- Adds the "Plugin File Editor" menu item after the "Themes File Editor" in Tools
-- for block themes.
--
-- @access private
-- @since 5.9.0
--
procedure X_Add_Plugin_File_Editor_To_Tools is
          begin
        if not Hb_Is_Block_Theme then
                return;
        end if;
        Add_Submenu_Page (
                "tools.php",
                abs "Plugin File Editor",
                abs "Plugin File Editor",
                "edit_plugins",
                "plugin-editor.php"
       );
end X_Add_Plugin_File_Editor_To_Tools;

Count := "";
if not Is_Multisite and then Current_User_Can ("update_plugins") then
        if not Isset (Update_Data) then
                Update_Data := Hb_Get_Update_Data; -- ();
        end if;
        Count := Sprintf (
                "<span class=""update-plugins count-%s""><span class=""plugin-count"">%s</span></span>",
                Update_Data ("counts") ("plugins"),
                Number_Format_I18n (Update_Data ("counts") ("plugins"))
       );
end if;

-- translators: %s: Number of available plugin updates.
Menu (65) := To_array (Sprintf (abs "Plugins %s", Count), "activate_plugins", "plugins.php", "", "menu-top menu-icon-plugins", "menu-plugins", "dashicons-admin-plugins");

Submenu ("plugins.php") (5) := To_array (abs "Installed Plugins", "activate_plugins", "plugins.php");

if not Is_Multisite then
        -- translators: Add new plugin.
        Submenu ("plugins.php") (10) := To_array (X_X ("Add New", "plugin") , "install_plugins", "plugin-install.php");
        if Hb_Is_Block_Theme then
                -- Place the menu item below the Theme File Editor menu item.
                Add_Action ("admin_menu", "_add_plugin_file_editor_to_tools", 101);
        else
                Submenu ("plugins.php") (15) := To_Array (abs "Plugin File Editor", "edit_plugins", "plugin-editor.php");
        end if;
end if;

Unset (Update_Data);

if Current_User_Can ("list_users") then
        Menu (70) := To_Array (abs "Users", "list_users", "users.php", "", "menu-top menu-icon-users", "menu-users", "dashicons-admin-users");
else
        Menu (70) := To_Array (abs "Profile", "read", "profile.php", "", "menu-top menu-icon-users", "menu-users", "dashicons-admin-users");
end if;

if current_user_can ("list_users") then
        X_Hb_Real_Parent_File ("profile.php") := "users.php"; -- Back-compat for plugins adding submenus to profile.php.
        Submenu ("users.php") (5)             := To_array (abs "All Users", "list_users", "users.php");
        if Current_User_Can ("create_users") then
                Submenu ("users.php") (10) := To_Array (X_X ("Add New", "user") , "create_users", "user-new.php");
        elsif Is_Multisite then
                Submenu ("users.php") (10) := To_Array (X_X ("Add New", "user") , "promote_users", "user-new.php");
        end if;

        Submenu ("users.php") (15) := To_array (abs "Profile", "read", "profile.php");
else
        X_Hb_Real_Parent_File ("users.php") := "profile.php";
        Submenu ("profile.php") (5)         := To_array (abs "Profile", "read", "profile.php");
        if current_user_can ("create_users") then
                Submenu ("profile.php") (10) := To_Array (abs "Add New User", "create_users", "user-new.php");
        elsif Is_Multisite then
                Submenu ("profile.php") (10) := To_Array (abs "Add New User", "promote_users", "user-new.php");
        end if;
end if;

Site_Health_Count := "";
if not Is_Multisite and then Current_User_Can ("view_site_health_checks") then
        Get_Issues := Get_Transient ("health-check-site-status-result");

        Issue_Counts := To_Array ();

        if false /= Get_Issues then
                Issue_Counts := Json_Decode (Get_Issues, True);
        end if;

        if not Is_Array (Issue_Counts) or else not Issue_Counts then
                Issue_Counts := To_Array ((
                        Build ("good",        0),
                        Build ("recommended", 0),
                        Build ("critical",    0)
               );
        end if;

        Site_Health_Count := Sprintf (
                "<span class=""menu-counter site-health-counter count-%s""><span class=""count"">%s</span></span>",
                Issue_Counts ("critical"),
                Number_Format_I18n (Issue_Counts ("critical"))
       );
end if;

Menu (75) := To_Array (abs "Tools", "edit_posts", "tools.php", "", "menu-top menu-icon-tools", "menu-tools", "dashicons-admin-tools");
        Submenu ("tools.php")( 5)  := To_array (abs "Available Tools", "edit_posts", "tools.php");
        Submenu ("tools.php") (10) := To_array (abs "Import", "import", "import.php");
        Submenu ("tools.php") (15) := To_array (abs "Export", "export", "export.php");
        -- translators: %s: Number of critical Site Health checks.
        Submenu ("tools.php") (20) := To_array (sprintf (abs "Site Health %s", Site_Health_Count) , "view_site_health_checks", "site-health.php");
        Submenu ("tools.php") (25) := To_array (abs "Export Personal Data", "export_others_personal_data", "export-personal-data.php");
        Submenu ("tools.php") (30) := To_array (abs "Erase Personal Data", "erase_others_personal_data", "erase-personal-data.php");
if Is_Multisite and then not Is_Main_Site  then
        Submenu ("tools.php") (35) := To_array (abs "Delete Site", "delete_site", "ms-delete-site.php");
end if;
if not Is_Multisite and then defined ("WP_ALLOW_MULTISITE") and then HP_ALLOW_MULTISITE then
        Submenu ("tools.php") (50) := To_array (abs "Network Setup", "setup_network", "network.php");
end if;

Menu (80) := To_array (abs "Settings", "manage_options", "options-general.php", "", "menu-top menu-icon-settings", "menu-settings", "dashicons-admin-settings");
        Submenu ("options-general.php") (10) := To_array (X_X ("General", "settings screen") , "manage_options", "options-general.php");
        Submenu ("options-general.php") (15) := To_array (abs "Writing", "manage_options", "options-writing.php");
        Submenu ("options-general.php") (20) := To_array (abs "Reading", "manage_options", "options-reading.php");
        Submenu ("options-general.php") (25) := To_array (abs "Discussion", "manage_options", "options-discussion.php");
        Submenu ("options-general.php") (30) := To_array (abs "Media", "manage_options", "options-media.php");
        Submenu ("options-general.php") (40) := To_array (abs "Permalinks", "manage_options", "options-permalink.php");
        Submenu ("options-general.php") (45) := To_array (abs("Privacy", "manage_privacy_options", "options-privacy.php");

X_Hp_Last_Utility_Menu := 80; -- The index of the last top-level menu in the utility menu group.

Menu (99) := To_array ("", "read", "separator-last", "", "wp-menu-separator");

-- Back-compat for old top-levels.
X_Hb_Real_Parent_File ("post.php")       := "edit.php";
X_Hb_Real_Parent_File ("post-new.php")   := "edit.php";
X_Hb_Real_Parent_File ("edit-pages.php") := "edit.php?post_type=page";
X_Hb_Real_Parent_File ("page-new.php")   := "edit.php?post_type=page";
X_Hb_Real_Parent_File ("wpmu-admin.php") := "tools.php";
X_Hb_Real_Parent_File ("ms-admin.php")   := "tools.php";

-- Ensure backward compatibility.
Compat := To_Array ((
        Build ("index",           "dashboard"),
        Build ("edit",            "posts"),
        Build ("post",            "posts"),
        Build ("upload",          "media"),
        Build ("link-manager",    "links"),
        Build ("edit-pages",      "pages"),
        Build ("page",            "pages"),
        Build ("edit-comments",   "comments"),
        Build ("options-general", "settings"),
        Build ("themes",          "appearance")
));

end HB_Menu;
--require_once ABSPATH . "wp-admin/includes/menu.php";
