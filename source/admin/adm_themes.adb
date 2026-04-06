--
-- Themes administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.Files;
with Php.HTML;
with Php.Lists;
with Php.Strings;

with Arrays;
with Array_Lists;
with Binder;
with Constants;
with Globals;
with Helpers;
with Lists;
with UStrings;
with Wp_Common;

with Class_Errors;
with Class_Screens;
with Class_Themes;

with Adm_Admin;
with Adm_Admin_Footer;
with Adm_Admin_Header;
with Adm_Menu; -- For Parent_File

with Adi_Files;
with Adi_Misc;
with Adi_Screens;
with Adi_Themes;
with Adi_Update;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_General_Templates;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Pluggables;
with Inc_Themes;

package body Adm_Themes
is
   use Arrays;
   use Lists;

   -- Placeholder for real 'data' when I find out where it is from. XXX
   type Screenshot_Array is array (0 .. 0) of Boolean;

   type Resp_Record is record
      compatibleWP  : Boolean;
      compatiblePHP : Boolean;
   end record;

   type Autoupdate_Record is record
      supported : Boolean;
      forced    : Boolean;
      enabled   : Boolean;
   end record;

   type Data_Type is record
      Screenshot : Screenshot_Array;
      hasUpdate  : Boolean;
      hasPackage : Boolean;
      compatibleWP  : Boolean;
      compatiblePHP : Boolean;
      active        : Boolean;
      updateResponse : Resp_Record;
      name       : UStrings.UString;
      actions    : Array_Type; -- Actions_Record;
      blockTheme : Boolean;
      Update : String (1 .. 20);
      parent : Boolean;
      tags   : Boolean;
      autoupdate : Autoupdate_Record;
   end record;

   Data : Data_Type;

   function Build_Submenu
            return String;

   procedure Build_Help_Tabs;

   --
   -- Returns the JavaScript template used to display the auto-update setting for
   -- a theme.
   --
   -- @since 5.5.0
   --
   -- @return string The template for displaying the auto-update setting link.
   --
   function Wp_Theme_Auto_Update_Setting_Template (Data : Data_Type)
            return String;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Arrays;
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use Php.Lists;
      use Php.Strings;

      use Array_Lists;
      use Binder;
      use Globals;
      use UStrings;

      use Class_Errors;
      use Class_Themes;

      use Adm_Menu;
      use Adi_Files;
      use Adi_Misc;
      use Adi_Update;
      use Adi_Themes;

      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
      use Inc_Themes;

      Current_Theme_Actions : UString; -- Array_Type := Empty_Array;
      Themes : Array_Type;
   begin

      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      if
        not Current_User_Can ("switch_themes") and then
        not Current_User_Can ("edit_theme_options")
      then
         Wp_Die (
           "<h1>" & abs "You need a higher level of permission." & "</h1>" &
           "<p>" &
           abs "Sorry, you are not allowed to edit theme options on this site." &
           "</p>",
           Code => 403
         );
      end if;

      if Current_User_Can ("switch_themes") and then Isset (XX_GET, "action") then
         if "activate" = Get_As_String (XX_GET, "action") then
            Check_Admin_Referer ("switch-theme_" & Get_As_String (XX_GET, "stylesheet"));
            declare
               Theme : constant Wp_Theme :=
                 Wp_Get_Theme (Get_As_String (XX_GET, "stylesheet"));
            begin
               if not Theme.Exists or else not Theme.Is_Allowed then
                  Wp_Die (
                    "<h1>" & abs "Something went wrong." & "</h1>" &
                    "<p>" & abs "The requested theme does not exist." & "</p>",
                    Code => 403
                  );
               end if;

               Switch_Theme (Theme.Get_Stylesheet);
            end;
            Wp_Redirect (Admin_URL ("themes.php?activated=true"));
            Die; -- exit;

         elsif "resume" = Get_As_String (XX_GET, "action") then
            Check_Admin_Referer ("resume-theme_" & Get_As_String (XX_GET, "stylesheet"));
            declare
               Theme : constant Wp_Theme :=
                 Wp_Get_Theme (Get_As_String (XX_GET, "stylesheet"));
            begin
               if not Current_User_Can ("resume_theme", Get_As_String (XX_GET, "stylesheet")) then
                  Wp_Die (
                    "<h1>" & abs "You need a higher level of permission." & "</h1>" &
                    "<p>" &
                    abs "Sorry, you are not allowed to resume this theme." &
                    "</p>",
                    Code => 403
                             );
               end if;

               declare
                  Result : constant Bool_Error_Type :=
                    Resume_Theme (Theme.Get_Stylesheet,
                                  Self_Admin_URL ("themes.php?error=resuming"));
               begin
                  if not Result.Success then
--                if Is_Wp_Error (result) then
                     Wp_Die (Result.Error);
                  end if;
               end;
            end;
            Wp_Redirect (Admin_URL ("themes.php?resumed=true"));
            Die; -- exit;

         elsif "delete" = Get_As_String (XX_GET, "action") then
            Check_Admin_Referer ("delete-theme_" & Get_As_String (XX_GET, "stylesheet"));
            declare
               Theme : constant Wp_Theme :=
                 Wp_Get_Theme (Get_As_String (XX_GET, "stylesheet"));
            begin
               if not Current_User_Can ("delete_themes") then
                  Wp_Die (
                    "<h1>" & abs "You need a higher level of permission." & "</h1>" &
                    "<p>" &
                    abs "Sorry, you are not allowed to delete this item." & "</p>",
                    Code => 403
                  );
               end if;

               if not Theme.Exists then
                  Wp_Die (
                    "<h1>" & abs "Something went wrong." & "</h1>" &
                    "<p>" & abs "The requested theme does not exist." & "</p>",
                    Code => 403
                  );
               end if;

               declare
                  Active : Wp_Theme := Wp_Get_Theme;
               begin
                  if Active.Get ("Template") = Get_As_String (XX_GET, "stylesheet") then
                     Wp_Redirect (Admin_URL ("themes.php?delete-active-child=true"));
                  else
                     Delete_Theme (Get_As_String (XX_GET, "stylesheet"));
                     Wp_Redirect (Admin_URL ("themes.php?deleted=true"));
                  end if;
               end;
            end;
            Die; -- exit;

         elsif "enable-auto-update" = Get_As_String (XX_GET, "action") then
            if
              not (Current_User_Can ("update_themes") and then
                   Wp_Is_Auto_Update_Enabled_For_Type ("theme"))
            then
               Wp_Die (abs "Sorry, you are not allowed to enable themes automatic updates.");
            end if;

            Check_Admin_Referer ("updates");
            declare
               All_Items : constant Array_Type := Wp_Get_Themes;

               Auto_Updates : List_Type :=
                 As_List (Get_Site_Option ("auto_update_themes",
                                           From_Array (Empty_Array))); -- (array)
            begin
               Auto_Updates.Append (Get_As_String (XX_GET, "stylesheet"));
               Auto_Updates := List_Unique (Auto_Updates);
               -- Remove themes that have been deleted since the site option was
               -- last updated.
               Auto_Updates := List_Intersect (Auto_Updates,
                                               Array_Keys (All_Items));

               Update_Site_Option ("auto_update_themes",
                                   From_List (Auto_Updates));
            end;
            Wp_Redirect (Admin_URL ("themes.php?enabled-auto-update=true"));
            Die; -- exit;

         elsif "disable-auto-update" = Get_As_String (XX_GET, "action") then
            if
              not (Current_User_Can ("update_themes") and then
                   Wp_Is_Auto_Update_Enabled_For_Type ("theme"))
            then
               Wp_Die (abs "Sorry, you are not allowed to disable themes automatic updates.");
            end if;
            Check_Admin_Referer ("updates");

            declare
               All_Items    : constant Array_Type := Wp_Get_Themes;
               Auto_Updates : List_Type  :=
                 As_List (Get_Site_Option ("auto_update_themes",
                                           From_Array (Empty_Array))); -- (array)
            begin
               Auto_Updates := List_Diff (Auto_Updates,
                                          Get_As_String (XX_GET, "stylesheet")); -- array
               -- Remove themes that have been deleted since the site option was
               -- last updated.
               Auto_Updates := List_Intersect (Auto_Updates,
                                               Array_Keys (All_Items));

               Update_Site_Option ("auto_update_themes",
                                   From_List (Auto_Updates));
            end;
            Wp_Redirect (Admin_URL ("themes.php?disabled-auto-update=true"));
            Die; -- exit;
         end if;
      end if;

      -- Used in the HTML title tag.
      Globals.Global_Title := +abs "Themes";
      Parent_File   := +Slug_Type'("themes.php");

      Build_Help_Tabs;

--      declare
      Themes := --  Array_Type :=
        (if Current_User_Can ("switch_themes")
         then Wp_Prepare_Themes_For_JS
         else Wp_Prepare_Themes_For_JS); -- (Build ("", Wp_Get_Theme)); -- array -- XXX
--      begin

         Wp_Reset_Vars (["theme", "search"]); -- array

         Wp_Localize_Script (
           "theme",
           "_wpThemeSettings",
           To_Array_Type ([
             Build ("themes",   Themes),
             Build ("settings", To_Array_Type ([
               Build ("canInstall",    (not Is_Multisite and then Current_User_Can ("install_themes"))),
               Build ("installURI",    (if not Is_Multisite and then Current_User_Can ("install_themes") then Admin_URL ("theme-install.php") else "")), -- null
               Build ("confirmDelete", abs "Are you sure you want to delete this theme?\n\nClick ""Cancel"" to go back, ""OK"" to confirm the delete."),
               Build ("adminUrl",      String'(Parse_URL (Admin_URL, PHP_URL_PATH)))
             ])),
             Build ("l10n",     To_Array_Type ([
               Build ("addNew",            abs "Add New Theme"),
               Build ("search",            abs "Search Installed Themes"),
               Build ("searchPlaceholder", abs "Search installed themes..."), -- Placeholder (no ellipsis).
               -- translators: %d: Number of themes.
               Build ("themesFound",       abs "Number of Themes found: %d"),
               Build ("noThemesFound",     abs "No themes found. Try a different search.")
             ]))
           ])
         );

         Add_Thickbox;
         Wp_Enqueue_Script ("theme");
         Wp_Enqueue_Script ("updates");

         Adm_Admin_Header.Run;

         Echo ("<div class=""wrap"">");
         Echo ("<h1 class=""wp-heading-inline"">");
         ESC_HTML_E ("Themes");
         Echo ("<span class=""title-count theme-count"">" &
               (if not Empty (XX_GET, "search")
                then abs "&hellip;" else Helpers.Image (Themes.Length)) & "</span>");
         Echo ("</h1>");
--    end;

      if not Is_Multisite and then Current_User_Can ("install_themes") then
         Echo ("<a href=""" & ESC_URL (Admin_URL ("theme-install.php")) &
               """ class=""hide-if-no-js page-title-action"">" &
               ESC_HTML_X ("Add New", "theme") & "</a>");
      end if;

      Echo ("<form class=""search-form""></form>");
      Echo ("<hr class=""wp-header-end"">");

      if not Validate_Current_Theme or else Isset (XX_GET, "broken") then
         Echo ("<div id=""message1"" class=""updated notice is-dismissible""><p>");
         X_E ("The active theme is broken. Reverting to the default theme.");
         Echo ("</p></div>");

      elsif Isset (XX_GET, "activated") then
         if Isset (XX_GET, "previewed") then
            Echo ("<div id=""message2"" class=""updated notice is-dismissible""><p>");
            X_E ("Settings saved and theme activated.");
            Echo (" <a href=""" & ESC_URL (Home_URL ("/")) & ">");
            X_E ("Visit site");
            Echo ("</a></p></div>");

         else
            Echo ("<div id=""message2"" class=""updated notice is-dismissible""><p>");
            X_E ("New theme activated.");
            Echo (" <a href=""" & ESC_URL (Home_URL ("/")) & """>");
            X_E ("Visit site");
            Echo ("</a></p></div>");

         end if;
      elsif Isset (XX_GET, "deleted") then
         Echo ("<div id=""message3"" class=""updated notice is-dismissible""><p>");
         X_E ("Theme deleted."); Echo ("</p></div>");

      elsif Isset (XX_GET, "delete-active-child") then
         Echo ("<div id=""message4"" class=""error""><p>");
         X_E ("You cannot delete a theme while it has an active child theme.");
         Echo ("</p></div>");

      elsif Isset (XX_GET, "resumed") then
         Echo ("<div id=""message5"" class=""updated notice is-dismissible""><p>");
         X_E ("Theme resumed.");
         Echo ("</p></div>");

      elsif
        Isset (XX_GET, "error") and then
        "resuming" = Get_As_String (XX_GET, "error")
      then
         Echo ("<div id=""message6"" class=""error""><p>");
         X_E ("Theme could not be resumed because it triggered a <strong>fatal error</strong>.");
         Echo ("</p></div>");

      elsif Isset (XX_GET, "enabled-auto-update") then
         Echo ("<div id=""message7"" class=""updated notice is-dismissible""><p>");
         X_E ("Theme will be auto-updated.");
         Echo ("</p></div>");

      elsif Isset (XX_GET, "disabled-auto-update") then
         Echo ("<div id=""message8"" class=""updated notice is-dismissible""><p>");
         X_E ("Theme will no longer be auto-updated.");
         Echo ("</p></div>");

      end if;

      declare
         Current_Theme : constant Wp_Theme := Wp_Get_Theme;
      begin
         if
           Current_Theme.Errors /= Null_Wp_Error and then
--         Current_Theme.Errors and then
           (not Is_Multisite or else
            Current_User_Can ("manage_network_themes"))
         then
            Echo ("<div class=""error""><p>" & abs "Error:" & " " &
                  Current_Theme.Errors.Get_Error_Message & "</p></div>");
         end if;
      end;

--    Current_Theme_Actions : Ustring; -- Array_Type := Empty_Array;
      Current_Theme_Actions := +Build_Submenu;

      declare
         Class_Name : UString := +"theme-browser";
      begin
         if not Empty (XX_GET, "search") then
            Append (Class_Name, " search-loading");
         end if;

         Echo ("<div class=""" & ESC_Attr (-Class_Name) & """>");
         Echo ("<div class=""themes wp-clearfix"">");
      end;

      --
      -- This PHP is synchronized with the tmpl-theme template below!
      --
      for A in Themes.Iterate loop
-- for Theme of Themes loop
         declare
            Theme : constant Array_Type := As_Array (Element (A));

            Aria_Action : constant String := Get_As_String (Theme, "id") & "-action";
            Aria_Name   : constant String := Get_As_String (Theme, "id") & "-name";

            Active_Class : UString;
         begin
            if As_Boolean (Get (Theme, "active")) then
               Active_Class := +" active";
            end if;

            Echo ("<div class=""theme" & (-Active_Class) & """>");
            if not Empty (As_String (Get (Ref_2 (Theme, "screenshot", "[0]")))) then
               Echo ("<div class=""theme-screenshot"">");
               Echo ("<img src=""" & ESC_URL (As_String (Get (Ref_2 (Theme, "screenshot", "[0]"))) & "?ver=" & Get_As_String (Theme, "version")) & """ alt="""" />");
               Echo ("</div>");
            else
               Echo ("<div class=""theme-screenshot Blank""></div>");
            end if;

            if As_Boolean (Get (Theme, "hasUpdate")) then
               if
                  As_Boolean (Get (Ref_2 (Theme, "updateResponse", "compatibleWP")))
                  and then
                  As_Boolean (Get (Ref_2 (Theme, "updateResponse", "compatiblePHP")))
               then
                  Echo ("<div class=""update-message notice inline notice-warning notice-alt""><p>");
                  if As_Boolean (Get (Theme, "hasPackage")) then
                     X_E ("New version available. <button class=""button-link"" type=""button"">Update now</button>");
                  else
                     X_E ("New version available.");
                  end if;
                  Echo ("</p></div>");
               else
                  Echo ("<div class=""update-message notice inline notice-error notice-alt""><p>");

                  if
                     not As_Boolean (Get (Ref_2 (Theme, "updateResponse", "compatibleWP")))
                     and then
                     not As_Boolean (Get (Ref_2 (Theme, "updateResponse", "compatiblePHP")))
                  then
                     Printf (
                       -- translators: %s: Theme name.
                       abs "There is a new version of %s available, but it does not work with your versions of WordPress and PHP.",
                       [Get_As_String (Theme, "name")]
                     );
                     if
                       Current_User_Can ("update_core") and then
                       Current_User_Can ("update_php")
                     then
                        Printf (
                          -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
                          " " & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
                          [
                            1 => Self_Admin_URL ("update-core.php"),
                            2 => ESC_URL (Wp_Get_Update_PHP_URL)
                          ]
                        );
                        Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");

                     elsif Current_User_Can ("update_core") then
                        Printf (
                          -- translators: %s: URL to WordPress Updates screen.
                          " " & abs "<a href=""%s"">Please update WordPress</a>.",
                          [1 => Self_Admin_URL ("update-core.php")]
                        );

                     elsif Current_User_Can ("update_php") then
                        Printf (
                          -- translators: %s: URL to Update PHP page.--
                          " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                          [1 => ESC_URL (Wp_Get_Update_PHP_URL)]
                        );
                        Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
                     end if;

                  elsif not As_Boolean (Get (Ref_2 (Theme, "updateResponse", "compatibleWP"))) then
                     Printf (
                       -- translators: %s: Theme name.
                       abs "There is a new version of %s available, but it does not work with your version of WordPress.",
                       [Get_As_String (Theme, "name")]
                     );
                     if Current_User_Can ("update_core") then
                        Printf (
                          -- translators: %s: URL to WordPress Updates screen.
                          " " & abs "<a href=""%s"">Please update WordPress</a>.",
                          [Self_Admin_URL ("update-core.php")]
                        );
                     end if;

                  elsif not As_Boolean (Get (Ref_2 (Theme, "updateResponse", "compatiblePHP"))) then
                     Printf (
                       -- translators: %s: Theme name.
                       abs "There is a new version of %s available, but it does not work with your version of PHP.",
                       [Get_As_String (Theme, "name")]
                     );
                     if Current_User_Can ("update_php") then
                        Printf (
                          -- translators: %s: URL to Update PHP page.--
                          " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                          [ESC_URL (Wp_Get_Update_PHP_URL)]
                        );
                        Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
                     end if;
                  end if;

                  Echo ("</p></div>");
               end if;
            end if;

            if
              not As_Boolean (Get (Theme, "compatibleWP")) or else
              not As_Boolean (Get (Theme, "compatiblePHP"))
            then
               Echo ("<div class=""notice inline notice-error notice-alt""><p>");
               if
                 not As_Boolean (Get (Theme, "compatibleWP")) and then
                 not As_Boolean (Get (Theme, "compatiblePHP"))
               then
                  X_E ("This theme does not work with your versions of WordPress and PHP.");
                  if
                    Current_User_Can ("update_core") and then
                    Current_User_Can ("update_php")
                  then
                     Printf (
                       -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
                       " " & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
                       [
                         1 => Self_Admin_URL ("update-core.php"),
                         2 => ESC_URL (Wp_Get_Update_PHP_URL)
                       ]
                     );
                     Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");

                  elsif Current_User_Can ("update_core") then
                     Printf (
                       -- translators: %s: URL to WordPress Updates screen.
                       " " & abs "<a href=""%s"">Please update WordPress</a>.",
                       [1 => Self_Admin_URL ("update-core.php")]
                     );

                  elsif Current_User_Can ("update_php") then
                     Printf (
                       -- translators: %s: URL to Update PHP page.
                       " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                       [ESC_URL (Wp_Get_Update_PHP_URL)]
                     );
                     Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
                  end if;

               elsif not As_Boolean (Get (Theme, "compatibleWP")) then
                  X_E ("This theme does not work with your version of WordPress.");
                  if Current_User_Can ("update_core") then
                     Printf (
                       -- translators: %s: URL to WordPress Updates screen.
                       " " & abs "<a href=""%s"">Please update WordPress</a>.",
                       [Self_Admin_URL ("update-core.php")]
                     );
                  end if;

               elsif not As_Boolean (Get (Theme, "compatiblePHP")) then
                  X_E ("This theme does not work with your version of PHP.");
                  if Current_User_Can ("update_php") then
                     Printf (
                        -- translators: %s: URL to Update PHP page.
                        " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                        [ESC_URL (Wp_Get_Update_PHP_URL)]
                     );
                     Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
                  end if;
               end if;

               Echo ("</p></div>");
            end if;

            declare
               -- translators: %s: Theme name.
               Details_Aria_Label : constant String :=
                 Sprintf (X_X ("View Theme Details for %s", "theme"),
                          [Get_As_String (Theme, "name")]);
            begin
               Echo ("<button type=""button"" aria-label=""" &
                     ESC_Attr (Details_Aria_Label) &
                     """ class=""more-details"" id=""" &
                     ESC_Attr (Aria_Action) & """>");
               X_E ("Theme Details");  Echo ("</button>");
               Echo ("<div class=""theme-author"">");
            end;

            -- translators: %s: Theme author name.
            Printf (abs "By %s", [Get_As_String (Theme, "author")]);

            Echo ("</div>");

            Echo ("<div class=""theme-id-container"">");
            if As_Boolean (Get (Theme, "active")) then
               Echo ("<h2 class=""theme-name"" id=""" & ESC_Attr (Aria_Name) & """>");
               Echo ("<span>");
               X_Ex ("Active:", "theme");
               Echo ("</span> " & Get_As_String (Theme, "name"));
               Echo ("</h2>");
            else
               Echo ("<h2 class=""theme-name"" id=""" & ESC_Attr (Aria_Name) &
                     """>" & Get_As_String (Theme, "name") & "</h2>");
            end if;

            Echo ("<div class=""theme-actions"">");

            if As_Boolean (Get (Theme, "active")) then
               if
                 As_Boolean (Get (Ref_2 (Theme, "actions", "customize"))) and then
                 Current_User_Can ("edit_theme_options") and then
                 Current_User_Can ("customize")
               then
                  declare
                     -- translators: %s: Theme name.
                     Customize_Aria_Label : constant String :=
                       Sprintf (X_X ("Customize %s", "theme"),
                                [Get_As_String (Theme, "name")]);
                  begin
                     Echo ("<a aria-label=""" & ESC_Attr (Customize_Aria_Label) &
                           """ class=""button button-primary customize load-customize hide-if-no-customize"" href=""" & As_String (Get (Ref_2 (Theme, "actions", "customize"))) & """>");
                     X_E ("Customize");  Echo ("</a>");
                  end;
               end if;

            elsif
              As_Boolean (Get (Theme, "compatibleWP")) and then
              As_Boolean (Get (Theme, "compatiblePHP"))
            then
               declare
                  -- translators: %s: Theme name.
                  Aria_Label : constant String :=
                    Sprintf (X_X ("Activate %s", "theme"),
                             ["{{ data.name }}"]);
               begin
                  Echo ("<a class=""button activate"" href=""" &
                        As_String (Get (Ref_2 (Theme, "actions", "activate"))) &
                        """ aria-label=""" & ESC_Attr (Aria_Label) & """>");
                  X_E ("Activate");
                  Echo ("</a>");
               end;

               if
                 not As_Boolean (Get (Theme, "blockTheme")) and then
                 Current_User_Can ("edit_theme_options") and then
                 Current_User_Can ("customize")
               then
                  declare
                     -- translators: %s: Theme name.
                     Live_Preview_Aria_Label : constant String :=
                       Sprintf (X_X ("Live Preview %s", "theme"),
                                ["{{ data.name }}"]);
                  begin
                     Echo ("<a aria-label=""" & ESC_Attr (Live_Preview_Aria_Label) &
                           """ class=""button button-primary load-customize hide-if-no-customize"" href=""" &
                           As_String (Get (Ref_2 (Theme, "actions", "customize"))) & """>");
                     X_E ("Live Preview");
                     Echo ("</a>");
                  end;
               end if;

            else
               declare
                  -- translators: %s: Theme name.
                  Aria_Label : constant String :=
                    Sprintf (X_X ("Cannot Activate %s", "theme"),
                             ["{{ data.name }}"]);
               begin
                  Echo ("<a class=""button disabled"" aria-label=""" &
                        ESC_Attr (Aria_Label) & """>");
                  X_Ex ("Cannot Activate", "theme");  Echo ("</a>");
               end;
               if
                 not As_Boolean (Get (Theme, "blockTheme")) and then
                 Current_User_Can ("edit_theme_options") and then
                 Current_User_Can ("customize")
               then
                  Echo ("<a class=""button button-primary hide-if-no-customize disabled"">");
                  X_E ("Live Preview");
                  Echo ("</a>");
               end if;
            end if;

            Echo ("</div>");
            Echo ("</div>");
            Echo ("</div>");
         end;
      end loop;
      Echo ("</div>");
      Echo ("</div>");
      Echo ("<div class=""theme-overlay"" tabindex=""0"" role=""dialog"" aria-label=""");
      ESC_Attr_E ("Theme Details");  Echo ("""></div>");

      Echo ("<p class=""no-themes"">");
      X_E ("No themes found. Try a different search.");
      Echo ("</p>");

      -- List broken themes, if any.
      declare
         Broken_Themes : constant Array_Type :=
           Wp_Get_Themes (Build ("errors", True)); -- array
      begin
         if not Is_Multisite and then not Broken_Themes.Is_Empty then

            Echo ("<div class=""broken-themes"">");
            Echo ("<h3>");  X_E ("Broken Themes");  Echo ("</h3>");
            Echo ("<p>");  X_E ("The following themes are installed but incomplete.");  Echo ("</p>");

            declare
               Can_Resume  : constant Boolean := Current_User_Can ("resume_themes");
               Can_Delete  : constant Boolean := Current_User_Can ("delete_themes");
               Can_Install : constant Boolean := Current_User_Can ("install_themes");
            begin
               Echo ("<table>");
               Echo ("<tr>");
               Echo ("<th>");  X_Ex ("Name", "theme name");  Echo ("</th>");
               Echo ("<th>");  X_E ("Description");  Echo ("</th>");

               if Can_Resume then
                  Echo ("<td></td>");
               end if;

               if Can_Delete then
                  Echo ("<td></td>");
               end if;

               if Can_Install then
                  Echo ("<td></td>");
               end if;

               Echo ("</tr>");

               for A in Broken_Themes.Iterate loop
--             for Broken_Theme of Broken_Themes loop
                  declare
                     Broken_Theme : Wp_Theme; --  := Element (A);       -- XXX
                  begin
                     Echo ("<tr>");
                     Echo ("<td>");
                     if Broken_Theme.Get ("Name") /= "" then
                        Echo (Broken_Theme.Display ("Name"));
                     else
                        Echo (ESC_HTML (Broken_Theme.Get_Stylesheet));
                     end if;
                     Echo ("</td>");
                     Echo ("<td>" & Broken_Theme.Errors.Get_Error_Message & "</td>");

                     if Can_Resume then
                        if "theme_paused" = Broken_Theme.Errors.Get_Error_Code then
                           declare
                              Stylesheet : constant String :=
                                Broken_Theme.Get_Stylesheet;

                              Resume_URL_2 : constant String :=
                                Add_Query_Arg (
                                  To_Array_Type ([
                                    Build ("action",     "resume"),
                                    Build ("stylesheet", URL_Encode (Stylesheet))
                                  ]),
                                  Admin_URL ("themes.php")
                                );

                              Resume_URL : constant String :=
                                Wp_Nonce_URL (Resume_URL_2,
                                              "resume-theme_" & Stylesheet);
                           begin
                              Echo ("<td><a href=""" & ESC_URL (Resume_URL) &
                                    """ class=""button resume-theme"">");
                              X_E ("Resume");  Echo ("</a></td>");
                           end;

                        else
                           Echo ("<td></td>");

                        end if;
                     end if;

                     if Can_Delete then
                        declare
                           Stylesheet : constant String :=
                             Broken_Theme.Get_Stylesheet;

                           Delete_URL_2 : constant String :=
                             Add_Query_Arg (
                               To_Array_Type ([
                                 Build ("action",     "delete"),
                                 Build ("stylesheet", URL_Encode (Stylesheet))
                               ]),
                               Admin_URL ("themes.php")
                             );

                           Delete_URL : constant String :=
                             Wp_Nonce_URL (Delete_URL_2,
                                           "delete-theme_" & Stylesheet);
                        begin
                           Echo ("<td><a href=""" & ESC_URL (Delete_URL) &
                                 """ class=""button delete-theme"">");
                           X_E ("Delete");  Echo ("</a></td>");
                        end;
                     end if;

                     if
                       Can_Install and then
                       "theme_no_parent" = Broken_Theme.Errors.Get_Error_Code
                     then
                        declare
                           Parent_Theme_Name : constant String :=
                             Broken_Theme.Get ("Template");

                           Parent_Theme : constant Array_Error_Type :=
                             Themes_API ("theme_information",
                                         Build ("slug", URL_Encode (Parent_Theme_Name))); -- array
                        begin
                           if Parent_Theme.Success then
--                         if not Is_Wp_Error (Parent_Theme) then
                              declare
                                 Install_URL_2 : constant String :=
                                   Add_Query_Arg (
                                     To_Array_Type ([
                                       Build ("action", "install-theme"),
                                       Build ("theme",  URL_Encode (Parent_Theme_Name))
                                     ]),
                                     Admin_URL ("update.php")
                                   );

                                 Install_URL : constant String :=
                                   Wp_Nonce_URL (Install_URL_2,
                                                 "install-theme_" & Parent_Theme_Name);
                              begin
                                 Echo ("<td><a href=""" & ESC_URL (Install_URL) & """ class=""button install-theme"">");
                                 X_E ("Install Parent Theme");
                                 Echo ("</a></td>");
                              end;
                           end if;
                        end;
                     end if;

                     Echo ("</tr>");
                  end;
               end loop;
               Echo ("</table>");
               Echo ("</div>");
            end;
         end if;
      end;

      Echo ("</div><!-- .wrap -->");

      --
      -- The tmpl-theme template is synchronized with PHP above!
      --
      Echo ("<script id=""tmpl-theme"" type=""text/template"">");
      if Data.Screenshot (0) then
         Echo ("<div class=""theme-screenshot"">");
         Echo ("<img src=""{{ data.screenshot[0] }}?ver={{ data.version }}"" alt="""" />");
         Echo ("</div>");
      else
         Echo ("<div class=""theme-screenshot blank""></div>");
      end if;

      if Data.hasUpdate then
         if
           Data.updateResponse.compatibleWP and then
           Data.updateResponse.compatiblePHP
         then
            Echo ("<div class=""update-message notice inline notice-warning notice-alt""><p>");
            if Data.hasPackage then
               X_E ("New version available. <button class=""button-link"" type=""button"">Update now</button>");
            else
               X_E ("New version available.");
            end if;
            Echo ("</p></div>");
         else
            Echo ("<div class=""update-message notice inline notice-error notice-alt""><p>");
            if
              not Data.updateResponse.compatibleWP and then
              not Data.updateResponse.compatiblePHP
            then
               Printf (
                 -- translators: %s: Theme name.
                 abs "There is a new version of %s available, but it does not work with your versions of WordPress and PHP.",
                 ["{{{ data.name }}}"]
               );
               if
                 Current_User_Can ("update_core") and then
                 Current_User_Can ("update_php")
               then
                  Printf (
                    -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
                    " " & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
                    [
                      1 => Self_Admin_URL ("update-core.php"),
                      2 => ESC_URL (Wp_Get_Update_PHP_URL)
                    ]
                  );
                  Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");

               elsif Current_User_Can ("update_core") then
                  Printf (
                    -- translators: %s: URL to WordPress Updates screen.
                    " " & abs "<a href=""%s"">Please update WordPress</a>.",
                    [Self_Admin_URL ("update-core.php")]
                  );

               elsif Current_User_Can ("update_php") then
                  Printf (
                    -- translators: %s: URL to Update PHP page.
                    " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                    [ESC_URL (Wp_Get_Update_PHP_URL)]
                  );
                  Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
               end if;

            elsif not Data.updateResponse.compatibleWP then
               Printf (
                 -- translators: %s: Theme name.
                 abs "There is a new version of %s available, but it does not work with your version of WordPress.",
                 ["{{{ data.name }}}"]
               );
               if Current_User_Can ("update_core") then
                  Printf (
                    -- translators: %s: URL to WordPress Updates screen.
                    " " & abs "<a href=""%s"">Please update WordPress</a>.",
                    [Self_Admin_URL ("update-core.php")]
                  );
               end if;

            elsif not Data.updateResponse.compatiblePHP then
               Printf (
                 -- translators: %s: Theme name.
                 abs "There is a new version of %s available, but it does not work with your version of PHP.",
                 ["{{{ data.name }}}"]
               );
               if Current_User_Can ("update_php") then
                  Printf (
                    -- translators: %s: URL to Update PHP page.
                    " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                    [ESC_URL (Wp_Get_Update_PHP_URL)]
                  );
                  Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
               end if;

            end if;
            Echo ("</p></div>");
         end if;
      end if;

      if
        not Data.compatibleWP or else
        not Data.compatiblePHP
      then
         Echo ("<div class=""notice notice-error notice-alt""><p>");
         if not Data.compatibleWP and then not Data.compatiblePHP then

            X_E ("This theme does not work with your versions of WordPress and PHP.");
            if
              Current_User_Can ("update_core") and then
              Current_User_Can ("update_php")
            then
               Printf (
                 -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
                 " " & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
                 [
                   1 => Self_Admin_URL ("update-core.php"),
                   2 => ESC_URL (Wp_Get_Update_PHP_URL)
                 ]
               );
               Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");

            elsif Current_User_Can ("update_core") then
               Printf (
                 -- translators: %s: URL to WordPress Updates screen.
                 " " & abs "<a href=""%s"">Please update WordPress</a>.",
                 [Self_Admin_URL ("update-core.php")]
               );

            elsif Current_User_Can ("update_php") then
               Printf (
                 -- translators: %s: URL to Update PHP page.
                 " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                 [ESC_URL (Wp_Get_Update_PHP_URL)]
               );
               Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
            end if;

         elsif not Data.compatibleWP then
            X_E ("This theme does not work with your version of WordPress.");
            if Current_User_Can ("update_core") then
               Printf (
                 -- translators: %s: URL to WordPress Updates screen.
                 " " & abs "<a href=""%s"">Please update WordPress</a>.",
                 [Self_Admin_URL ("update-core.php")]
               );
            end if;

         elsif not Data.compatiblePHP then
            X_E ("This theme does not work with your version of PHP.");
            if Current_User_Can ("update_php") then
               Printf (
                 -- translators: %s: URL to Update PHP page.
                 " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                 [ESC_URL (Wp_Get_Update_PHP_URL)]
               );
               Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
            end if;

         end if;
         Echo ("</p></div>");
      end if;

      declare
         -- translators: %s: Theme name.
         Details_Aria_Label : constant String :=
           Sprintf (X_X ("View Theme Details for %s", "theme"),
                    ["{{ data.name }}"]);
      begin
         Echo ("<button type=""button"" aria-label=""" &
               ESC_Attr (Details_Aria_Label) &
               """ class=""more-details"" id=""{{ data.id }}-action"">");
         X_E ("Theme Details");  Echo ("</button>");
      end;
      Echo ("<div class=""theme-author"">");
      -- translators: %s: Theme author name.
      Printf (abs "By %s", ["{{{ data.author }}}"]);
      Echo ("</div>");

      Echo ("<div class=""theme-id-container"">");
      if Data.active then
         Echo ("<h2 class=""theme-name"" id=""{{ data.id }}-name"">");
         Echo ("<span>");
         X_Ex ("Active:", "theme");
         Echo ("</span> {{{ data.name }}}");
         Echo ("</h2>");
      else
         Echo ("<h2 class=""theme-name"" id=""{{ data.id }}-name"">" & (-Data.name) & "</h2>"); -- {{{}}}
      end if;

      Echo ("<div class=""theme-actions"">");
      if Data.active then
         if As_Boolean (Get (Data.actions, "customize")) then
--       if Data.Actions.Customize then
            declare
               -- translators: %s: Theme name.
               Customize_Aria_Label : constant String :=
                 Sprintf (X_X ("Customize %s", "theme"), ["{{ data.name }}"]);
            begin
               Echo ("<a aria-label=""" & ESC_Attr (Customize_Aria_Label) & """ class=""button button-primary customize load-customize hide-if-no-customize"" href=""{{{ data.actions.customize }}}"">");
               X_E ("Customize");  Echo ("</a>");
            end;
         end if;
      else
         if Data.compatibleWP and then Data.compatiblePHP then
            declare
               -- translators: %s: Theme name.
               Aria_Label : constant String :=
                 Sprintf (X_X ("Activate %s", "theme"),
                          ["{{ data.name }}"]);
            begin
               Echo ("<a class=""button activate"" href=""{{{ data.actions.activate }}}"" aria-label=""" & ESC_Attr (Aria_Label) & """>");
               X_E ("Activate");  Echo ("</a>");
            end;
            if not Data.blockTheme then
               declare
                  -- translators: %s: Theme name.
                  Live_Preview_Aria_Label : constant String :=
                    Sprintf (X_X ("Live Preview %s", "theme"),
                             ["{{ data.name }}"]);
               begin
                  Echo ("<a aria-label=""" & ESC_Attr (Live_Preview_Aria_Label) &
                        """ class=""button button-primary load-customize hide-if-no-customize"" href=""{{{ data.actions.customize }}}"">");
                  X_E ("Live Preview");  Echo ("</a>");
               end;
            end if;
         else
            declare
               -- translators: %s: Theme name.
               Aria_Label : constant String :=
                 Sprintf (X_X ("Cannot Activate %s", "theme"),
                          ["{{ data.name }}"]);
            begin
               Echo ("<a class=""button disabled"" aria-label=""" & ESC_Attr (Aria_Label) & """>");
               X_Ex ("Cannot Activate", "theme");
               Echo ("</a>");
            end;
            if not Data.blockTheme then
               Echo ("<a class=""button button-primary hide-if-no-customize disabled"">");
               X_E ("Live Preview");
               Echo ("</a>");
            end if;
         end if;
      end if;
      Echo ("</div>");
      Echo ("</div>");
      Echo ("</script>");

      Echo ("<script id=""tmpl-theme-single"" type=""text/template"">");
      Echo ("<div class=""theme-backdrop""></div>");
      Echo ("<div class=""theme-wrap wp-clearfix"" role=""document"">");
      Echo ("<div class=""theme-header"">");
      Echo ("<button class=""left dashicons dashicons-no""><span class=""screen-reader-text"">");
      X_E ("Show previous theme");  Echo ("</span></button>");
      Echo ("<button class=""right dashicons dashicons-no""><span class=""screen-reader-text"">");
      X_E ("Show next theme");  Echo ("</span></button>");
      Echo ("<button class=""close dashicons dashicons-no""><span class=""screen-reader-text"">");
      X_E ("Close details dialog");  Echo ("</span></button>");
      Echo ("</div>");
      Echo ("<div class=""theme-about wp-clearfix"">");
      Echo ("<div class=""theme-screenshots"">");
      if Data.Screenshot (0) then
         Echo ("<div class=""screenshot""><img src=""{{.screenshot[0] }}?ver={{.version }}"" alt="""" /></div>");
      else
         Echo ("<div class=""screenshot blank""></div>");
      end if;
      Echo ("</div>");

      Echo ("<div class=""theme-info"">");
      if Data.active then
         Echo ("<span class=""current-label"">");
         X_E ("Active Theme");  Echo ("</span>");
      end if;
      Echo ("<h2 class=""theme-name"">{{{ data.name }}}<span class=""theme-version"">");

      -- translators: %s: Theme version.
      Printf (abs "Version: %s", ["{{ data.version }}"]);

      Echo ("</span></h2>");
      Echo ("<p class=""theme-author"">");

      -- translators: %s: Theme author link.
      Printf (abs "By %s", ["{{{ Data.authorAndUri }}}"]);
      Echo ("</p>");

      if not Data.compatibleWP or else not Data.compatiblePHP then
         Echo ("<div class=""notice notice-error notice-alt notice-large""><p>");
         if
           not Data.compatibleWP and then
           not Data.compatiblePHP
         then
            X_E ("This theme does not work with your versions of WordPress and PHP.");
            if
              Current_User_Can ("update_core") and then
              Current_User_Can ("update_php")
            then
               Printf (
                 -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
                 " " & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
                 [
                   1 => Self_Admin_URL ("update-core.php"),
                   2 => ESC_URL (Wp_Get_Update_PHP_URL)
                 ]
               );
               Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
            elsif Current_User_Can ("update_core") then
               Printf (
                 -- translators: %s: URL to WordPress Updates screen.
                 " " & abs "<a href=""%s"">Please update WordPress</a>.",
                 [Self_Admin_URL ("update-core.php")]
               );

            elsif Current_User_Can ("update_php") then
               Printf (
                 -- translators: %s: URL to Update PHP page.
                 " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                 [ESC_URL (Wp_Get_Update_PHP_URL)]
               );
               Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
            end if;

         elsif not Data.compatibleWP then
            X_E ("This theme does not work with your version of WordPress.");
            if Current_User_Can ("update_core") then
               Printf (
                 -- translators: %s: URL to WordPress Updates screen.
                 " " & abs "<a href=""%s"">Please update WordPress</a>.",
                 [Self_Admin_URL ("update-core.php")]
               );
            end if;

         elsif not Data.compatiblePHP then
            X_E ("This theme does not work with your version of PHP.");
            if Current_User_Can ("update_php") then
               Printf (
                 -- translators: %s: URL to Update PHP page.
                 " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                 [ESC_URL (Wp_Get_Update_PHP_URL)]
               );
               Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
            end if;

         end if;
         Echo ("</p></div>");
      end if;

      if Data.hasUpdate then
         if
           Data.updateResponse.compatibleWP and then
           Data.updateResponse.compatiblePHP
         then
            Echo ("<div class=""notice notice-warning notice-alt notice-large"">");
            Echo ("<h3 class=""notice-title"">");
            X_E ("Update Available");  Echo ("</h3>");
            Echo (Data.Update); -- {{{}}}
            Echo ("</div>");
         else
            Echo ("<div class=""notice notice-error notice-alt notice-large"">");
            Echo ("<h3 class=""notice-title"">");
            X_E ("Update Incompatible");  Echo ("</h3>");
            Echo ("<p>");
            if
              not Data.updateResponse.compatibleWP and then
              not Data.updateResponse.compatiblePHP
            then
               Printf (
                 -- translators: %s: Theme name.
                 abs "There is a new version of %s available, but it does not work with your versions of WordPress and PHP.",
                 ["{{{ data.name }}}"]
               );
               if
                 Current_User_Can ("update_core") and then
                 Current_User_Can ("update_php")
               then
                  Printf (
                    -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
                    " " & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
                    [
                      1 => Self_Admin_URL ("update-core.php"),
                      2 => ESC_URL (Wp_Get_Update_PHP_URL)
                    ]
                  );
                  Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");

               elsif Current_User_Can ("update_core") then
                  Printf (
                    -- translators: %s: URL to WordPress Updates screen.
                    " " & abs "<a href=""%s"">Please update WordPress</a>.",
                    [Self_Admin_URL ("update-core.php")]
                  );
               elsif Current_User_Can ("update_php") then
                  Printf (
                    -- translators: %s: URL to Update PHP page.
                    " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                    [ESC_URL (Wp_Get_Update_PHP_URL)]
                  );
                  Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
               end if;

            elsif not Data.updateResponse.compatibleWP then
               Printf (
                 -- translators: %s: Theme name.
                 abs "There is a new version of %s available, but it does not work with your version of WordPress.",
                 ["{{{ data.name }}}"]
               );
               if Current_User_Can ("update_core") then
                  Printf (
                    -- translators: %s: URL to WordPress Updates screen.
                    " " & abs "<a href=""%s"">Please update WordPress</a>.",
                    [Self_Admin_URL ("update-core.php")]
                  );
               end if;

            elsif not Data.updateResponse.compatiblePHP then
               Printf (
                 -- translators: %s: Theme name.
                 abs "There is a new version of %s available, but it does not work with your version of PHP.",
                 ["{{{ data.name }}}"]
               );
               if Current_User_Can ("update_php") then
                  Printf (
                    -- translators: %s: URL to Update PHP page.
                    " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                    [ESC_URL (Wp_Get_Update_PHP_URL)]
                  );
                  Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
               end if;

            end if;
            Echo ("</p>");
            Echo ("</div>");
         end if;
      end if;

      if As_Boolean (Get (Data.actions, "autoupdate")) then
--    if Data.actions.autoupdate then
         Echo (Wp_Theme_Auto_Update_Setting_Template (Data));
      end if;

      Echo ("<p class=""theme-description"">{{{ data.description }}}</p>");

      if Data.parent then
         Echo ("<p class=""parent-theme"">");
         -- translators: %s: Theme name.
         Printf (abs "This is a child theme of %s.",
                 ["<strong>{{{ data.parent }}}</strong>"]);
         Echo ("</p>");
      end if;

      if Data.tags then
         Echo ("<p class=""theme-tags""><span>");
         X_E ("Tags:");  Echo ("</span> {{{ data.tags }}}</p>");
      end if;
      Echo ("</div>");
      Echo ("</div>");

      Echo ("<div class=""theme-actions"">");
      Echo ("<div class=""active-theme"">");
      Echo ("<a href=""{{{ data.actions.customize }}}"" class=""button button-primary customize load-customize hide-if-no-customize"">");
      X_E ("Customize");  Echo ("</a>");
      Echo (Implode (" ", -Current_Theme_Actions));
      Echo ("</div>");
      Echo ("<div class=""inactive-theme"">");

      if Data.compatibleWP and then Data.compatiblePHP then
         declare
            -- translators: %s: Theme name.
            Aria_Label : constant String :=
              Sprintf (X_X ("Activate %s", "theme"),
                       ["{{ data.name }}"]);
         begin
            if As_Boolean (Get (Data.actions, "activate")) then
--          if Data.actions.activate then
               Echo ("<a href=""{{{ data.actions.activate }}}"" class=""button activate"" aria-label=""" & ESC_Attr (Aria_Label) & """>");
               X_E ("Activate");  Echo ("</a>");
            end if;
         end;

         if not Data.blockTheme then
            Echo ("<a href=""{{{ data.actions.customize }}}"" class=""button button-primary load-customize hide-if-no-customize"">");
            X_E ("Live Preview");  Echo ("</a>");
         end if;

      else
         declare
            -- translators: %s: Theme name.
            Aria_Label : constant String :=
              Sprintf (X_X ("Cannot Activate %s", "theme"),
                       ["{{ data.name }}"]);
         begin
            if As_Boolean (Get (Data.actions, "activate")) then
--          if Data.actions.activate then
               Echo ("<a class=""button disabled"" aria-label=""" &
                     ESC_Attr (Aria_Label) & """>");
               X_Ex ("Cannot Activate", "theme");
               Echo ("</a>");
            end if;
         end;
         if not Data.blockTheme then
            Echo ("<a class=""button button-primary hide-if-no-customize disabled"">");
            X_E ("Live Preview");  Echo ("</a>");
         end if;
      end if;
      Echo ("</div>");

      if not Data.active and then As_Boolean (Get (Data.actions, "delete")) then
         declare
            -- translators: %s: Theme name.
            Aria_Label : constant String :=
              Sprintf (X_X ("Delete %s", "theme"),
                       ["{{ data.name }}"]);
         begin
            Echo ("<a href=""" & Get_As_String (Data.actions, "delete") &
                  """ class=""button delete-theme"" aria-label=""" &
                  ESC_Attr (Aria_Label) & """>");
            X_E ("Delete");  Echo ("</a>");
         end;
      end if;
      Echo ("</div>");
      Echo ("</div>");
      Echo ("</script>");

      Wp_Print_Request_Filesystem_Credentials_Modal;
      Wp_Print_Admin_Notice_Templates;
      Wp_Print_Update_Row_Templates;

      Wp_Localize_Script (
        "updates",
        "_wpUpdatesItemCounts",
        To_Array_Type ([
          Build ("totals", 999) -- Wp_Get_Update_Data) -- XXX
        ])
      );

      Adm_Admin_Footer.Run;
   end Render;

   -------------------
   -- Build_Submenu --
   -------------------

   function Build_Submenu
            return String
   is
      use Php.Files;
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Adm_Menu;
      use Inc_Capabilities;

      Self : constant String := "XXX-921"; -- XXX

      Current_Theme_Actions : UString;

      Forbidden_Paths : constant List_Type := [
        "themes.php",
        "theme-editor.php",
        "site-editor.php",
        "edit.php?post_type=wp_navigation"
      ];
   begin
      if
--      Is_Array (Submenu) and then
        Submenu_Maps.Has_Element (Submenu.Find ("themes.php"))
--      Isset (Submenu, "themes.php")
      then

         for Item of Submenu_Maps.Element (Submenu.Find ("themes.php")) loop -- (array)
--       for Item of As_List (Get (Submenu, "themes.php")) loop -- (array)
            declare
               Class_2 : UString;

               Item_1 : constant String := -Item.Capability;
               -- Get_As_String (Item, "[1]");

               Item_2 : constant String := String (-Item.Menu_Slug);
               -- Get_As_String (Item, "[2]");
            begin
               if
                  In_List (Item_2, Forbidden_Paths, True) or else
                  Str_Starts_With (Item_2, "customize.php")
               then
                  goto Continue;
               end if;

               -- 0 = name, 1 = capability, 2 = file.
               if (0 = Strcmp (Self, Item_2) and then Empty (String (-Parent_File)))
                   or else (Parent_File /= "" and then Item_2 = Parent_File)
               then  -- XXX mixed logical operators
                  Class_2 := +" current";
               end if;

               if Submenu_Maps.Has_Element (Submenu.Find (Slug_Type (Item_2))) then
--             if not Empty (Submenu, Item_2) then
                  -- Re-index.
--                Submenu.Include (Key => Slug_Type (Item_2),
--                                 New_Item => Array_Values (Submenu.Find (Slug_Type (Item_2)))); -- XXX
--                Set (Submenu, Item_2, Array_Values (As_List (Get (Submenu, Item_2)))); -- Re-index.
                  declare
                     Menu_Hook : constant String := "XXX-922";
--                     Get_Plugin_Page_Hook (Submenu [Item_2] [0] [2], Item_2); -- XXX
                     Class : constant String := -Class_2;
                  begin
                     if File_Exists ((-Constants.WP_PLUGIN_DIR) & "/thensubmenu[item[2]][0][2]end;") or else not Empty (Menu_Hook) then
                        Append (Current_Theme_Actions, "<a class=""button" & Class & """ href=""admin.php?page=thensubmenu[item[2]][0][2]end;"">thenitem[0]end;</a>");
                     else
                        Append (Current_Theme_Actions, "<a class=""button" & Class & """ href=""thensubmenu[item[2]][0][2]end;"">thenitem[0]end;</a>");
                     end if;
                  end;

               elsif not Empty (Item_2) and then Current_User_Can (Item_1) then
                  declare
                     Menu_File : constant String := Item_2;
                     Class     : constant String := -Class_2;
                  begin
                     if Current_User_Can ("customize") then
                        if "custom-header" = Menu_File then
                           Append (Current_Theme_Actions, "<a class=""button hide-if-no-customize" & Class & """ href=""customize.php?autofocus[control]=header_image"">thenitem[   0]end;</a>");
                        elsif "custom-background" = Menu_File then
                           Append (Current_Theme_Actions, "<a class=""button hide-if-no-customize" & Class & """ href=""customize.php?autofocus[control]=background_image"">thenitem[0]end;</a>");
                        end if;
                     end if;

                     declare
                        Pos : constant Natural := Strpos (Menu_File, "?");

                        Menu_File_2 : constant String :=
                          (if 0 /= Pos
                           then Substr (Menu_File, 0, Pos)
                           else Menu_File);

                        Class : constant String := -Class_2;
                     begin
                        if File_Exists (Constants.ABSPATH & "wp-admin/" & Menu_File_2) then
                           Append (Current_Theme_Actions, "<a class=""button" & Class & """ href=""thenitem[2]end;"">thenitem[0]end;</a>");
                        else
                           Append (Current_Theme_Actions, "<a class=""button" & Class & """ href=""themes.php?page=thenitem[2]end;"">thenitem[0]end;</a>");
                        end if;
                     end;
                  end;
               end if;
            end;
            << Continue >>
         end loop;
      end if;
      return -Current_Theme_Actions;
   end Build_Submenu;

   ---------------------
   -- Build_Help_Tabs --
   ---------------------

   procedure Build_Help_Tabs
   is
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Adi_Screens;
      use Adi_Update;
      use Inc_Capabilities;
      use Inc_Load;
      use Inc_L10n;
   begin
      -- Help tab: Overview.
      if Current_User_Can ("switch_themes") then
         declare
            Help_Overview : constant String :=
              "<p>" & abs "This screen is used for managing your installed themes. Aside from the default theme(s) included with your WordPress installation, themes are designed and developed by third parties." & "</p>" &
              "<p>" & abs "From this screen you can:" & "</p>" &
              "<ul><li>" & abs "Hover or tap to see Activate and Live Preview buttons" & "</li>" &
              "<li>" & abs "Click on the theme to see the theme name, version, author, description, tags, and the Delete link" & "</li>" &
              "<li>" & abs "Click Customize for the active theme or Live Preview for any other theme to see a live preview" & "</li></ul>" &
              "<p>" & abs "The active theme is displayed highlighted as the first theme." & "</p>" &
              "<p>" & abs "The search for installed themes will search for terms in their name, description, author, or tag." & " <span id=""live-search-desc"">" & abs "The search results will be updated as you type." & "</span></p>";
         begin
            Get_Current_Screen.Add_Help_Tab (
              To_Array_Type ([
                Build ("id",      "overview"),
                Build ("title",   abs "Overview"),
                Build ("content", Help_Overview)
              ])
            );
         end;
      end if; -- End if "switch_themes".

      -- Help tab: Adding Themes.
      if Current_User_Can ("install_themes") then
         declare
            Help_Install : UString;
         begin
            if Is_Multisite then
               Help_Install := +"<p>" & abs "Installing themes on Multisite can only be done from the Network Admin section." & "</p>";
            else
               Help_Install := +"<p>" & Sprintf (
                 -- translators: %s: https://wordpress.org/themes/
                 abs "If you would like to see more themes to choose from, click on the &#8220;Add New&#8221; button and you will be able to browse or search for additional themes from the <a href=""%s"">WordPress Theme Directory</a>. Themes in the WordPress Theme Directory are designed and developed by third parties, and are compatible with the license WordPress uses. Oh, and they&#8217;re free!",
                 [abs "https://wordpress.org/themes/"]
               ) & "</p>";
            end if;

            Get_Current_Screen.Add_Help_Tab (
              To_Array_Type ([
                Build ("id",      "adding-themes"),
                Build ("title",   abs "Adding Themes"),
                Build ("content", -Help_Install)
              ])
            );
         end;
      end if; -- End if "install_themes".

      -- Help tab: Previewing and Customizing.
      if
        Current_User_Can ("edit_theme_options") and then
        Current_User_Can ("customize")
      then
         declare
            Help_Customize : constant String :=
              "<p>" & abs "Tap or hover on any theme then click the Live Preview button to see a live preview of that theme and change theme options in a separate, full-sc   reen view. You can also find a Live Preview button at the bottom of the theme details screen. Any installed theme can be previewed and customized in this way." & "</p>" &
              "<p>" & abs "The theme being previewed is fully interactive &mdash; navigate to different pages to see how the theme handles posts, archives, and other page tem   plates. The settings may differ depending on what theme features the theme being previewed supports. To accept the new settings and activate the theme all in one step, click the Activate &amp; Publish button above the menu." & "</p>" &
              "<p>" & abs "When previewing on smaller monitors, you can use the collapse icon at the bottom of the left-hand pane. This will hide the pane, giving you more room to preview your site in the new theme. To bring the pane back, click on the collapse icon again." & "</p>";
         begin
            Get_Current_Screen.Add_Help_Tab (
              To_Array_Type ([
                Build ("id",      "customize-preview-themes"),
                Build ("title",   abs "Previewing and Customizing"),
                Build ("content", Help_Customize)
              ])
            );
         end;
      end if; -- End if "edit_theme_options" and then "customize".

      declare
         Help_Sidebar_Autoupdates : UString;
      begin
         -- Help tab: Auto-updates.
         if
           Current_User_Can ("update_themes") and then
           Wp_Is_Auto_Update_Enabled_For_Type ("theme")
         then
            declare
               Help_Tab_Autoupdates : constant String :=
                 "<p>" & abs "Auto-updates can be enabled or disabled for each individual theme. Themes with auto-updates enabled will display the estimated date of the next    auto-update. Auto-updates depends on the WP-Cron task scheduling system." & "</p>" &
                 "<p>" & abs "Please note: Third-party themes and plugins, or custom code, may override WordPress scheduling." & "</p>";
            begin
               Get_Current_Screen.Add_Help_Tab (
                 To_Array_Type ([
                   Build ("id",      "plugins-themes-auto-updates"),
                   Build ("title",   abs "Auto-updates"),
                   Build ("content", Help_Tab_Autoupdates)
                 ])
               );
            end;

            Help_Sidebar_Autoupdates :=
             +"<p>" & abs "<a href=""https://wordpress.org/support/article/plugins-themes-auto-updates/"">Learn more: Auto-updates documentation</a>" & "</p>";
         end if; -- End if "update_themes" and then "wp_is_auto_update_enabled_for_type".

         Get_Current_Screen.Set_Help_Sidebar (
           "<p><strong>" & abs "For more information:" & "</strong></p>" &
           "<p>" & abs "<a href=""https://wordpress.org/support/article/using-themes/"">Documentation on Using Themes</a>" & "</p>" &
           "<p>" & abs "<a href=""https://wordpress.org/support/article/appearance-themes-screen/"">Documentation on Managing Themes</a>" & "</p>" &
           (-Help_Sidebar_Autoupdates) &
           "<p>" & abs "<a href=""https://wordpress.org/support/"">Support</a>" & "</p>"
         );
      end;
   end Build_Help_Tabs;

   -------------------------------------------
   -- Wp_Theme_Auto_Update_Setting_Template --
   -------------------------------------------

   function Wp_Theme_Auto_Update_Setting_Template (Data : Data_Type)
            return String
   is
      use UStrings;
      use Wp_Common;
      use Adi_Update;
      use Inc_L10n;

      Template : UString;
   begin
      Append (Template, "<div class=""theme-autoupdate"">");
      if Data.autoupdate.supported then
         if Data.autoupdate.forced = False then
            Append (Template, abs "Auto-updates disabled");
         elsif Data.autoupdate.forced then
            Append (Template, abs "Auto-updates enabled");
         elsif Data.autoupdate.enabled then
            Append (Template, "<button type=""button"" class=""toggle-auto-update button-link"" data-slug=""{{ data.id }}"" data-wp-action=""disable"">");
            Append (Template, "<span class=""dashicons dashicons-update spin hidden"" aria-hidden=""true""></span><span class=""label"">" & abs "Disable auto-updates" & "</span>");
            Append (Template, "</button>");
         else
            Append (Template, "<button type=""button"" class=""toggle-auto-update button-link"" data-slug=""{{ data.id }}"" data-wp-action=""enable"">");
            Append (Template, "<span class=""dashicons dashicons-update spin hidden"" aria-hidden=""true""></span><span class=""label"">" & abs "Enable auto-updates" & "</span>");
            Append (Template, "</button>");
         end if;
      end if;

      if Data.hasUpdate then
         if Data.autoupdate.supported and then Data.autoupdate.enabled then
            Append (Template, "<span class=""auto-update-time"">");
         else
            Append (Template, "<span class=""auto-update-time hidden"">");
         end if;
         Append (Template, "<br />" & Wp_Get_Auto_Update_Message & "</span>");
      end if;
      Append (Template, "<div class=""notice notice-error notice-alt inline hidden""><p></p></div>");
      Append (Template, "</div>");

      --
      -- Filters the JavaScript template used to display the auto-update setting
      -- for a theme (in the overlay).
      --
      -- See {@see wp_prepare_themes_for_js} for the properties of the `data` object.
      --
      -- @since 5.5.0
      --
      -- @param string template The template for displaying the auto-update
      --                        setting link.
      --
      return Apply_Filters ("theme_auto_update_setting_template", -Template);
   end Wp_Theme_Auto_Update_Setting_Template;

end Adm_Themes;
