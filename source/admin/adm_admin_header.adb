--
-- WordPress Administration Template Header
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Arrays;
with Globals;
with Hb_Common;
with Php;

with Adm_Menu;
with Adm_Menu_Header;

with Adi_Templates;
with Adi_Plugins;

with Inc_Admin_Bar;
with Inc_Capabilities;
with Inc_Class_Wp_Post_Type;
with Inc_Formatting;
with Inc_Functions_Wp_Scripts;
with Inc_Functions_Wp_Styles;
with Inc_General_Templates;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Load;
with Inc_Ms_Networks;
with Inc_Options;
with Inc_Plugins;
with Inc_Post_Templates;
with Inc_Posts;
with Inc_Themes;
with Inc_Users;

package body Adm_Admin_Header
is

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Ada.Strings.Unbounded;
      use Inc_Formatting;
      use Inc_L10n;
      use Inc_Load;
      use Inc_Options;
      use Inc_Plugins;
      use Hb_Common;
      use Php;

      function RTL_To_String (RTL : Boolean)
                              return String;

      function RTL_To_String (RTL : Boolean)
                              return String
      is
      begin
         return (if RTL then "1" else "0");
      end RTL_To_String;

      Admin_Body_Class   : Unbounded_String;
      Admin_Body_Classes : Unbounded_String;
      Admin_Title        : Unbounded_String;
      Screen_Title       : Unbounded_String;
   begin
      Header ("Content-Type: " & Get_Option ("html_type") &
              "; charset=" & Get_Option ("blog_charset"));
-- if ( ! defined( "WP_ADMIN" ) ) then
--        require_once __DIR__ . "/admin.php";
-- end;

--
-- In case admin-header.php is included in a function.
--
-- @global string    title
-- @global string    hook_suffix
-- @global WP_Screen current_screen     WordPress current screen object.
-- @global WP_Locale wp_locale          WordPress date and time locale object.
-- @global string    pagenow            The filename of the current screen.
-- @global string    update_title
-- @global int       total_update_count
-- @global string    parent_file
-- @global string    typenow            The post type of the current screen.
--
-- global title, hook_suffix, current_screen, wp_locale, pagenow,
--         update_title, total_update_count, parent_file, typenow;

-- Catch plugins that include admin-header.php before admin.php completes.
-- if ( empty( current_screen ) ) then
--        set_current_screen();
-- end;

      Adi_Plugins.Get_Admin_Page_Title;
      Globals.Title := +Strip_Tags (-Globals.Title);

      if Is_Network_Admin then
         -- translators: Network admin screen title. %s: Network title.
         Admin_Title := +Sprintf (abs "Network Admin: %s",
                                  -Inc_Ms_Networks.Get_Network.Site_Name);

      elsif Is_User_Admin then
         -- translators: User dashboard screen title. %s: Network title.
         Admin_Title := +Sprintf (abs "User Dashboard: %s",
                                  -Inc_Ms_Networks.Get_Network.Site_Name);

      else
         Admin_Title := +Inc_General_Templates.Get_Bloginfo ("name");
      end if;

      if Admin_Title = Globals.Title then
         -- translators: Admin screen title. %s: Admin screen name.
         Admin_Title := +Sprintf (abs "%s &#8212; WordPress", -Globals.Title);
      else
         Screen_Title := Globals.Title;

         if
           "post" = Globals.Current_Screen.Base and then
           "add" /= Globals.Current_Screen.Action
         then
            declare
               Post_Title : Unbounded_String;
            begin
               Post_Title := +Inc_Post_Templates.Get_The_Title;
               if not Empty (-Post_Title) then
                  declare
                     use Inc_Class_Wp_Post_Type;

                     Post_Type_Obj : Wp_Post_Type;
                  begin
                     Post_Type_Obj :=
                       Inc_Posts.Get_Post_Type_Object (-Globals.Typenow);

                     Screen_Title  := +Sprintf (
                        -- translators: Editor admin screen title. 1: "Edit item" text for the post type, 2: Post title.
                        abs "%1s &#8220;%2s&#8221;",
                        "XX-603", -- Post_Type_Obj.Labels.Edit_Item,
                        -Post_Title);
                  end;
               end if;
            end;
         end if;

         -- translators: Admin screen title. 1: Admin screen name, 2: Network or site name.
         Admin_Title := +Sprintf (abs "%1s &lsaquo; %2s &#8212; WordPress",
                                  -Screen_Title, -Admin_Title);
      end if;

      if Wp_Is_Recovery_Mode then
         -- translators: %s: Admin screen title.
         Admin_Title := +Sprintf (abs "Recovery Mode &#8212; %s", -Admin_Title);
      end if;

      --
      -- Filters the title tag content for an admin page.
      --
      -- @since 3.1.0
      --
      -- @param string admin_title The page title, with extra context added.
      -- @param string title       The original page title.
      --
      Admin_Title := +Apply_Filters ("admin_title", -Admin_Title, -Globals.Title);

      Inc_Options.Wp_User_Settings;

      Adi_Templates.X_Wp_Admin_Html_Begin;
-- ?>
      Echo ("<title>" & ESC_HTML (-Admin_Title) & "</title>" & NL);
-- <?php

      Inc_Functions_Wp_Styles.Wp_Enqueue_Style ("colors");

      Inc_Functions_Wp_Scripts.Wp_Enqueue_Script ("utils");
      Inc_Functions_Wp_Scripts.Wp_Enqueue_Script ("svg-painter");

      Admin_Body_Class := +Preg_Replace ("/[^a-z0-9_-]+/i", "-", -Globals.Hook_Suffix);
-- ?>
      Echo ("<script type=""text/javascript"">" & NL);
      Echo ("addLoadEvent = function(func){if(typeof jQuery!==""undefined"")jQuery(function(){func();});else if(typeof wpOnload!==""function""){wpOnload=func;}else{var oldonload=wpOnload;wpOnload=function(){oldonload();func()}}};" & NL);
      Echo ("var ajaxurl = '" &
            ESC_JS (Inc_Link_Templates.Admin_URL ("admin-ajax.php", "relative")) &
            "'," & NL);
      Echo ("        pagenow = '" &
            ESC_JS (-Globals.Current_Screen.Id) & "'," & NL);
      Echo ("        typenow = '" &
            ESC_JS (-Globals.Current_Screen.Post_Type) & "'," & NL);
      Echo ("        adminpage = '" & ESC_JS (-Admin_Body_Class) & "'," & NL);
--    Echo ("        thousandsSeparator = '" &
--          ESC_JS (Globals.Wp_Locale.Number_Format ("thousands_sep")) & "'," & NL);
--    Echo ("        decimalPoint = '" &
--          ESC_JS (Globals.Wp_Locale.Number_Format ("decimal_point")) & "'," & NL);
      Echo ("        isRtl = " & RTL_To_String (Is_RTL) & ";" & NL); -- (int)
      Echo ("</script>" & NL);
-- <?php

      --
      -- Enqueue scripts for all admin pages.
      --
      -- @since 2.8.0
      --
      -- @param string hook_suffix The current admin page.
      --
      Do_Action ("admin_enqueue_scripts", -Globals.Hook_Suffix);

      --
      -- Fires when styles are printed for a specific admin page based on hook_suffix.
      --
      -- @since 2.6.0
      --
      Do_Action ("admin_print_styles-" & (-Globals.Hook_Suffix));
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      --
      -- Fires when styles are printed for all admin pages.
      --
      -- @since 2.6.0
      --
      Do_Action ("admin_print_styles");

      --
      -- Fires when scripts are printed for a specific admin page based on hook_suffix.
      --
      -- @since 2.1.0
      --
      Do_Action ("admin_print_scripts-" & (-Globals.Hook_Suffix));
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      --
      -- Fires when scripts are printed for all admin pages.
      --
      -- @since 2.1.0
      --
      Do_Action ("admin_print_scripts");

      --
      -- Fires in head section for a specific admin page.
      --
      -- The dynamic portion of the hook name, `hook_suffix`, refers to the hook
      -- suffix for the admin page.
      --
      -- @since 2.1.0
      --
      Do_Action ("admin_head-" & (-Globals.Hook_Suffix));
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      --
      -- Fires in head section for all admin pages.
      --
      -- @since 2.1.0
      --
      Do_Action ("admin_head");

      if "f" = Inc_Options.Get_User_Setting ("mfold") then
         Append (Admin_Body_Class, " folded");
      end if;

      if "" = Inc_Options.Get_User_Setting ("unfold") then -- not
         Append (Admin_Body_Class, " auto-fold");
      end if;

      if Inc_Admin_Bar.Is_Admin_Bar_Showing then
         Append (Admin_Body_Class, " admin-bar");
      end if;

      if Is_RTL then
         Append (Admin_Body_Class, " rtl");
      end if;

      if Globals.Current_Screen.Post_Type /= "" then
         Append (Admin_Body_Class, " post-type-" & Globals.Current_Screen.Post_Type);
      end if;

      if Globals.Current_Screen.Taxonomy /= "" then
         Append (Admin_Body_Class, " taxonomy-" & Globals.Current_Screen.Taxonomy);
      end if;

      Append (Admin_Body_Class, " branch-" &
        Str_Replace (Arrays.To_List ((+".", +",")), "-",
                     Inc_General_Templates.Get_Bloginfo ("version")));

      Append (Admin_Body_Class, " version-" & Str_Replace (".", "-",
                               Preg_Replace ("/^([.0-9]+).*/", "1",
                                             Inc_General_Templates.Get_Bloginfo ("version"))));
      Append (Admin_Body_Class, " admin-color-" &
                               Sanitize_Html_Class (
                                 Inc_Users.Get_User_Option ("admin_color"), "fresh"));
      Append (Admin_Body_Class, (" locale-" &
                               Sanitize_Html_Class (Strtolower (
                                 Str_Replace ("_", "-", Get_User_Locale)))));

      if Wp_Is_Mobile then
         Append (Admin_Body_Class, " mobile");
      end if;

      if Is_Multisite then
         Append (Admin_Body_Class, " multisite");
      end if;

      if Is_Network_Admin then
         Append (Admin_Body_Class, " network-admin");
      end if;

      Append (Admin_Body_Class, " no-customize-support no-svg");

      if Globals.Current_Screen.Is_Block_Editor then
         Append (Admin_Body_Class, " block-editor-page wp-embed-responsive");
      end if;

      declare
         use Arrays;

         Error_Get_Last : constant Array_Type := Php.Error_Get_Last; --()
      begin
         -- Print a CSS class to make PHP errors visible.
         if
           Error_Get_Last.Is_Empty and then Globals.WP_DEBUG and then
           Globals.WP_DEBUG_DISPLAY and then "" /= Ini_Get ("display_errors")
           -- Don't print the class for PHP notices in wp-config.php, as they happen
           -- before WP_DEBUG takes effect, and should not be displayed with the
           -- `error_reporting` level previously set in wp-load.php.
--           and then ( -- E_NOTICE /= Error_Get_Last ("type") or else
--                     "wp-config.php" /= Inc_Formatting.Wp_Basename (Error_Get_Last ("file").First_Element.Key))
         then
            Append (Admin_Body_Class, " php-error");
         end if;

--       Unset (Error_Get_Last);
      end;

      Echo ("</head>" & NL);

      --
      -- Filters the CSS classes for the body tag in the admin.
      --
      -- This filter differs from the {@see "post_class"} and
      -- {@see "body_class"} filters in two important ways:
      --
      -- 1. `classes` is a space-separated string of class names instead of an array.
      -- 2. Not all core admin classes are filterable, notably: wp-admin, wp-core-ui,
      --    and no-js cannot be removed.
      --
      -- @since 2.3.0
      --
      -- @param string classes Space-separated list of CSS classes.
      --
      Admin_Body_Classes := +Apply_Filters ("admin_body_class", "");
      Admin_Body_Classes := +Ltrim (-Admin_Body_Classes & " " & (-Admin_Body_Class));

      Echo ("<body class=""wp-admin wp-core-ui no-js " & (-Admin_Body_Classes) &
            """>" & NL);
      Echo ("<script type=""text/javascript"">" & NL);
      Echo ("        document.body.className = document.body.className.replace(""no-js"",""js"")" & NL);
      Echo ("</script>" & NL);

      -- Make sure the customize body classes are correct as early as possible.
      if Inc_Capabilities.Current_User_Can ("customize") then
         Inc_Themes.Wp_Customize_Support_Script; -- ()
      end if;

      Echo ("<div id=""wpwrap"">" & NL);
      Adm_Menu_Header.Top;
      Adm_Menu_Header.Bottom;
-- Echo ("<?php require ABSPATH . ""wp-admin/menu-header.php""; ?>" & NL);
      Echo ("<div id=""wpcontent"">" & NL);

      --
      -- Fires at the beginning of the content section in an admin page.
      --
      -- @since 3.0.0
      --
      Do_Action ("in_admin_header");

      Echo ("<div id=""wpbody"" role=""main"">" & NL);
--    Unset (Blog_Name);
--    Unset (Globals.Total_Update_Count);
--    Unset (-Globals.Update_Title);

      declare
         use Adm_Menu;
      begin
         Globals.Current_Screen.Set_Parentage (String (-Globals.Parent_File));
      end;

      Echo ("<div id=""wpbody-content"">" & NL);

      Globals.Current_Screen.Render_Screen_Meta; -- ()

      if Is_Network_Admin then
         --
         -- Prints network admin screen notices.
         --
         -- @since 3.1.0
         --
         Do_Action ("network_admin_notices");

      elsif Is_User_Admin then
         --
         -- Prints user admin screen notices.
         --
         -- @since 3.1.0
         --
         Do_Action ("user_admin_notices");

      else
         --
         -- Prints admin screen notices.
         --
         -- @since 3.1.0
         --
         Do_Action ("admin_notices");
      end if;

      --
      -- Prints generic admin screen notices.
      --
      -- @since 3.1.0
      --
      Do_Action ("all_admin_notices");

--       declare
--          use Adm_Menu;
--       begin
--          if "options-general.php" = String (-Globals.Parent_File) then
--             Adm_Options_Head.Run;
-- --          require ABSPATH . "wp-admin/options-head.php";
--          end if;
--       end;
   end Run;

end Adm_Admin_Header;
