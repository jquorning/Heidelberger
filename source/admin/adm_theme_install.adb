--
-- Install theme administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.HTML;
with Php.Strings;

with Arrays;
with Array_Lists;
with Binder;
with Globals;
with Helpers;
with Lists;
with Logging;
with UStrings;
with Wp_Common;

with Adi_Files;
with Adi_Screens;
with Adi_Themes;
with Adi_Theme_Install;
with Adi_Update;

with Adm_Admin;
with Adm_Admin_Header;
with Adm_Admin_Footer;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Pluggables;
with Inc_Themes;
with Inc_Users;

package body Adm_Theme_Install is
   use Arrays;
   use Lists;

   procedure Emit_Script_1;
   procedure Emit_Script_2;

   ------------
   -- Render --
   ------------

   procedure Render is
      use Php.Arrays;
      use Php.Echoing;
      use Php.HTML;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use Globals;
      use UStrings;
      use Wp_Common;
      use Adi_Files;
      use Adi_Screens;
      use Adi_Themes;
      use Adi_Theme_Install;
      use Adi_Update;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
      use Inc_Themes;
      use Inc_Users;

      Tab : constant String :=
        (if not Empty (X_REQUEST, "tab")
         then Sanitize_Text_Field (Get_As_String (X_REQUEST, "tab"))
         else "");
   begin
      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      if not Current_User_Can ("install_themes") then
         Wp_Die
           (abs "Sorry, you are not allowed to install themes on this site.");
      end if;

      if Is_Multisite and then not Is_Network_Admin then
         Wp_Redirect (Network_Admin_URL ("theme-install.php"));
         Php.Errors.Die; -- exit;

      end if;

      -- Used in the HTML title tag.
      Globals.Global_Title := +abs "Add Themes";
      Globals.Global_Parent_File := +"themes.php";

      if not Is_Network_Admin then
         Globals.Global_Submenu_File := +"themes.php";
      end if;

      declare
         Installed_Themes_2 : constant Array_Type := Search_Theme_Directories;

         Installed_Themes : Array_Type :=
           (if Installed_Themes_2.Is_Empty
            then Empty_Array
            else Installed_Themes_2);
      begin
         Logging.Log ("adm_theme_install.render", Installed_Themes'Image);
         declare
            To_Delete : List_Type;
         begin
            for A in Installed_Themes.Iterate loop
               declare
                  Theme_Slug : constant String := Key (A);
                  -- Theme_Data : Multi_Type := Element (A);
               begin
                  -- Ignore child themes.
                  if Str_Contains (Theme_Slug, "/") then
                     To_Delete.Append (Theme_Slug);
                     Logging.Log ("render", "delete");
                  -- Delete (Installed_Themes, Theme_Slug);

                  end if;
               end;
            end loop;

            for Slug of To_Delete loop
               Installed_Themes.Delete (Slug);
            end loop;
         end;

         if False then
            Wp_Localize_Script
              ("theme",
               "_wpThemeSettings",
               To_Array_Type
                 ([Build ("themes", False),
                   Build
                     ("settings",
                      To_Array_Type
                        ([Build ("isInstall", True),
                          Build
                            ("canInstall",
                             Current_User_Can ("install_themes")),
                          Build
                            ("installURI",
                             (if Current_User_Can ("install_themes")
                              then Self_Admin_URL ("theme-install.php")
                              else "")), -- null
                          Build
                            ("adminUrl",
                             String'
                               (Parse_URL (Self_Admin_URL, PHP_URL_PATH)))])),
                   Build
                     ("l10n",
                      To_Array_Type
                        ([Build ("addNew", abs "Add Theme"),
                          Build ("search", abs "Search Themes"),
                          Build ("upload", abs "Upload Theme"),
                          Build ("back", abs "Back"),
                          Build
                            ("error",
                             Sprintf
                               (
                                -- translators: %s: Support forums URL.
                                abs "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href=""%s"">support forums</a>.",
                                [abs "https://wordpress.org/support/forums/"])),
                          Build ("tryAgain", abs "Try Again"),
                          -- translators: %d: Number of themes.
                          Build
                            ("themesFound", abs "Number of Themes found: %d"),
                          Build
                            ("noThemesFound",
                             abs "No themes found. Try a different search."),
                          Build ("collapseSidebar", abs "Collapse Sidebar"),
                          Build ("expandSidebar", abs "Expand Sidebar"),
                          -- translators: Hidden accessibility text.
                          Build
                            ("selectFeatureFilter",
                             abs "Select one or more Theme features to filter by")])),
                   Build
                     ("installedThemes",
                      List_Type'(Array_Keys (Installed_Themes))),
                   Build ("activeTheme", Get_Stylesheet)]));
         end if;
      end;

      Wp_Enqueue_Script ("theme");
      Wp_Enqueue_Script ("updates");

      if Tab /= "" then
         --
         -- Fires before each of the tabs are rendered on the Install Themes page.
         --
         -- The dynamic portion of the hook name, `tab`, refers to the current
         -- theme installation tab.
         --
         -- Possible hook names include:
         --
         --  - `install_themes_pre_block-themes`
         --  - `install_themes_pre_dashboard`
         --  - `install_themes_pre_featured`
         --  - `install_themes_pre_new`
         --  - `install_themes_pre_search`
         --  - `install_themes_pre_updated`
         --  - `install_themes_pre_upload`
         --
         -- @since 2.8.0
         -- @since 6.1.0 Added the `install_themes_pre_block-themes` hook name.
         --
         Do_Action ("install_themes_pre_" & Tab);
      end if;

      declare
         Help_Overview : constant String :=
           "<p>"
           & Sprintf
               (
                -- translators: %s: Theme Directory URL.
                abs "You can find additional themes for your site by using the Theme Browser/Installer on this screen, which will display themes from the <a href=""%s"">WordPress Theme Directory</a>. These themes are designed and developed by third parties, are available free of charge, and are compatible with the license WordPress uses.",
                [abs "https://wordpress.org/themes/"])
           & "</p>"
           & "<p>"
           & abs "You can Search for themes by keyword, author, or tag, or can get more specific and search by criteria listed in the feature filter."
           & " <span id=""live-search-desc"">"
           & abs "The search results will be updated as you type."
           & "</span></p>"
           & "<p>"
           & abs "Alternately, you can browse the themes that are Popular or Latest. When you find a theme you like, you can preview it or install it."
           & "</p>"
           & "<p>"
           & Sprintf
               (
                -- translators: %s: /wp-content/themes
                abs "You can Upload a theme manually if you have already downloaded its ZIP archive onto your computer (make sure it is from a trusted and original source). You can also do it the old-fashioned way and copy a downloaded theme&#8217;s folder via FTP into your %s directory.",
                ["<code>/wp-content/themes</code>"])
           & "</p>";
      begin
         Get_Current_Screen.Add_Help_Tab
           ( -- ()->
            To_Array_Type
              ([Build ("id", "overview"),
                Build ("title", abs "Overview"),
                Build ("content", Help_Overview)]));
      end;

      declare
         Help_Installing : constant String :=
           "<p>"
           & abs "Once you have generated a list of themes, you can preview and install any of them. Click on the thumbnail of the theme you are interested in previewing. It will open up in a full-screen Preview page to give you a better idea of how that theme will look."
           & "</p>"
           & "<p>"
           & abs "To install the theme so you can preview it with your site&#8217;s content and customize its theme options, click the ""Install"" button at the top of the left-hand pane. The theme files will be downloaded to your website automatically. When this is complete, the theme is now available for activation, which you can do by clicking the ""Activate"" link, or by navigating to your Manage Themes screen and clicking the ""Live Preview"" link under any installed theme&#8217;s thumbnail image."
           & "</p>";
      begin
         Get_Current_Screen.Add_Help_Tab
           (To_Array_Type
              ([Build ("id", "installing"),
                Build ("title", abs "Previewing and Installing"),
                Build ("content", Help_Installing)]));
      end;

      -- Help tab: Block themes.
      declare
         Help_Block_Themes : constant String :=
           "<p>"
           & abs "A block theme is a theme that uses blocks for all parts of a site including navigation menus, header, content, and site footer. These themes are built for the features that allow you to edit and customize all parts of your site."
           & "</p>"
           & "<p>"
           & abs "With a block theme, you can place and edit blocks without affecting your content by customizing or creating new templates."
           & "</p>";
      begin
         Get_Current_Screen.Add_Help_Tab
           (To_Array_Type
              ([Build ("id", "block_themes"),
                Build ("title", abs "Block themes"),
                Build ("content", Help_Block_Themes)]));
      end;

      Get_Current_Screen.Set_Help_Sidebar
        ("<p><strong>"
         & abs "For more information:"
         & "</strong></p>"
         & "<p>"
         & abs "<a href=""https://wordpress.org/documentation/article/appearance-themes-screen/#install-themes"">Documentation on Adding New Themes</a>"
         & "</p>"
         & "<p>"
         & abs "<a href=""https://wordpress.org/documentation/article/block-themes/"">Documentation on Block Themes</a>"
         & "</p>"
         & "<p>"
         & abs "<a href=""https://wordpress.org/support/forums/"">Support forums</a>"
         & "</p>");

      -- require_once ABSPATH & "wp-admin/admin-header.php";
      Adm_Admin_Header.Run;

      Echo (TAB0 & "<div class=""wrap"">" & NL);
      Echo
        (TAB1
         & "<h1 class=""wp-heading-inline"">"
         & ESC_HTML (-Globals.Global_Title)
         & "</h1>"
         & NL);

      --
      -- Filters the tabs shown on the Add Themes screen.
      --
      -- This filter is for backward compatibility only, for the suppression of the upload tab.
      --
      -- @since 2.8.0
      --
      -- @param string[] tabs Associative array of the tabs shown on the Add Themes screen. Default is "upload".
      --
      Globals.Global_Tabs :=
        Apply_Filters
          ("install_themes_tabs", Build ("upload", abs "Upload Theme"));

      if not Empty (Globals.Global_Tabs, "upload")
        and then Current_User_Can ("upload_themes")
      then
         Echo
           (" <button type=""button"" class=""upload-view-toggle page-title-action hide-if-no-js"" aria-expanded=""false"">"
            & abs "Upload Theme"
            & "</button>" & NL);
      end if;

      Echo (TAB1 & "<hr class=""wp-header-end"">");

      Wp_Admin_Notice
        (abs "The Theme Installer screen requires JavaScript.",
         To_Array_Type
           ([Build
               ("additional_classes",
                To_Array_Type ([Build ("error", "hide-if-js")]))]));

      Echo (TAB1 & "<div class=""upload-theme"">" & NL);
      Install_Themes_Upload;
      Echo (TAB1 & "</div>" & NL);

      Echo (TAB1 & "<h2 class=""screen-reader-text hide-if-no-js"">");
      -- translators: Hidden accessibility text.
      X_E ("Filter themes list");
      Echo (TAB1 & "</h2>" & NL);

      Echo (TAB1 & "<div class=""wp-filter hide-if-no-js"">" & NL);
      Echo (TAB2 & "<div class=""filter-count"">" & NL);
      Echo (TAB3 & "<span class=""count theme-count""></span>" & NL);
      Echo (TAB2 & "</div>" & NL);

      Echo (TAB2 & "<ul class=""filter-links"">" & NL);

      Echo (TAB3 & "<li><a href=""#"" data-sort=""popular"">");
      X_Ex ("Popular", "themes");
      Echo ("</a></li>" & NL);

      Echo (TAB3 & "<li><a href=""#"" data-sort=""new"">");
      X_Ex ("Latest", "themes");
      Echo ("</a></li>" & NL);

      Echo (TAB3 & "<li><a href=""#"" data-sort=""block-themes"">");
      X_Ex ("Block Themes", "themes");
      Echo ("</a></li>" & NL);

      Echo (TAB3 & "<li><a href=""#"" data-sort=""favorites"">");
      X_Ex ("Favorites", "themes");
      Echo ("</a></li>" & NL);

      Echo (TAB2 & "</ul>" & NL);

      Echo
        (TAB2
         & "<button type=""button"" class=""button drawer-toggle"" aria-expanded=""false"">");
      X_E ("Feature Filter");
      Echo ("</button>" & NL);

      Echo
        (TAB2
         & "<form class=""search-form""><p class=""search-box""></p></form>" & NL);

      Echo (TAB2 & "<div class=""favorites-form"">" & NL);

      declare
         Action : constant String :=
           "save_wporg_username_"
           & Helpers.Image (Integer (Get_Current_User_Id));

         User : UString;
      begin
         if Isset (XX_GET, "_wpnonce")
           and then Wp_Verify_Nonce
                      (Wp_Unslash (Get_As_String (XX_GET, "_wpnonce")), Action)
                    /= 0
         then
            User :=
              +(if Isset (XX_GET, "user")
                then Wp_Unslash (Get_As_String (XX_GET, "user"))
                else Get_User_Option ("wporg_favorites"));
            Update_User_Meta (Get_Current_User_Id, "wporg_favorites", -User);
         else
            User := +Get_User_Option ("wporg_favorites");
         end if;

         Echo (TAB3 & "<p class=""install-help"">");
         X_E
           ("If you have marked themes as favorites on WordPress.org, you can browse them here.");
         Echo ("</p>" & NL);

         Echo (TAB3 & "<p class=""favorites-username"">");
         Echo (TAB4 & "<label for=""wporg-username-input"">");
         X_E ("Your WordPress.org username:");
         Echo ("</label>" & NL);
         Echo
           (TAB4
            & "<input type=""hidden"" id=""wporg-username-nonce"" name=""_wpnonce"" value="""
            & ESC_Attr (Wp_Create_Nonce (Action))
            & """ />");
         Echo
           (TAB4
            & "<input type=""search"" id=""wporg-username-input"" value="""
            & ESC_Attr (-User)
            & """ />");
         Echo
           (TAB4
            & "<input type=""button"" class=""button favorites-form-submit"" value=""");
         ESC_Attr_E ("Get Favorites");
         Echo (""" />");
         Echo (TAB3 & "</p>" & NL);
         Echo (TAB2 & "</div>" & NL);

         Echo (TAB2 & "<div class=""filter-drawer"">" & NL);
         Echo (TAB3 & "<div class=""buttons"">" & NL);
         Echo
           (TAB4 & "<button type=""button"" class=""apply-filters button"">");
         X_E ("Apply Filters");
         Echo ("<span></span></button>" & NL);
         Echo
           (TAB4
            & "<button type=""button"" class=""clear-filters button"" aria-label=""");
         ESC_Attr_E ("Clear current filters");
         Echo (""">");
         X_E ("Clear");
         Echo ("</button>" & NL);
         Echo (TAB3 & "</div>" & NL);
      end;

      -- Use the core list, rather than the .org API, due to inconsistencies
      -- and to ensure tags are translated.
      declare
         Feature_List : constant Array_Type := Get_Theme_Feature_List (False);
      begin
         for A in Feature_List.Iterate loop
            declare
               Feature_Group : constant String := Key (A);
               Features      : constant Array_Type := As_Array (Element (A));
            begin
               Echo ("<fieldset class=""filter-group"">" & NL);
               Echo ("<legend>" & ESC_HTML (Feature_Group) & "</legend>" & NL);
               Echo ("<div class=""filter-group-feature"">" & NL);
               for B in Features.Iterate loop
                  declare
                     Feature_2    : constant String := Key (B);
                     Feature_Name : constant String := As_String (Element (B));
                     Feature      : constant String := ESC_Attr (Feature_2);
                  begin
                     Echo
                       ("<input type=""checkbox"" id=""filter-id-"
                        & Feature
                        & """ value="""
                        & Feature
                        & """ /> ");
                     Echo
                       ("<label for=""filter-id-"
                        & Feature
                        & """>"
                        & ESC_HTML (Feature_Name)
                        & "</label>"
                        & NL);
                  end;
               end loop;
               Echo ("</div>" & NL);
               Echo ("</fieldset>" & NL);
            end;
         end loop;
      end;

      Echo (TAB3 & "<div class=""buttons"">" & NL);
      Echo (TAB4 & "<button type=""button"" class=""apply-filters button"">");
      X_E ("Apply Filters");
      Echo ("<span></span></button>" & NL);
      Echo
        (TAB4
         & "<button type=""button"" class=""clear-filters button"" aria-label=""");
      ESC_Attr_E ("Clear current filters");
      Echo (""">");
      X_E ("Clear");
      Echo ("</button>" & NL);
      Echo (TAB3 & "</div>" & NL);

      Echo (TAB3 & "<div class=""filtered-by"">" & NL);
      Echo (TAB4 & "<span>");
      X_E ("Filtering by:");
      Echo ("</span>" & NL);
      Echo (TAB4 & "<div class=""tags""></div>" & NL);
      Echo
        (TAB5 & "<button type=""button"" class=""button-link edit-filters"">");
      X_E ("Edit Filters");
      Echo ("</button>" & NL);
      Echo (TAB3 & "</div>" & NL);
      Echo (TAB2 & "</div>" & NL);
      Echo (TAB1 & "</div>" & NL);

      Echo (TAB1 & "<h2 class=""screen-reader-text hide-if-no-js"">");
      -- translators: Hidden accessibility text.
      X_E ("Themes list");
      Echo (TAB1 & "</h2>" & NL);

      Echo (TAB1 & "<div class=""theme-browser content-filterable""></div>");
      Echo
        (TAB1
         & "<div class=""theme-install-overlay wp-full-overlay expanded""></div>" & NL);

      Echo (TAB1 & "<p class=""no-themes"">");
      X_E ("No themes found. Try a different search.");
      Echo ("</p>" & NL);
      Echo (TAB1 & "<span class=""spinner""></span>" & NL);

      if Tab /= "" then
         --
         -- Fires at the top of each of the tabs on the Install Themes page.
         --
         -- The dynamic portion of the hook name, `tab`, refers to the current
         -- theme installation tab.
         --
         -- Possible hook names include:
         --
         --  - `install_themes_block-themes`
         --  - `install_themes_dashboard`
         --  - `install_themes_featured`
         --  - `install_themes_new`
         --  - `install_themes_search`
         --  - `install_themes_updated`
         --  - `install_themes_upload`
         --
         -- @since 2.8.0
         -- @since 6.1.0 Added the `install_themes_block-themes` hook name.
         --
         -- @param int paged Number of the current page of results being viewed.
         --
         Do_Action ("install_themes_" & Tab, Globals.Global_Paged);
      end if;

      Echo (TAB0 & "</div>" & NL);

      Emit_Script_1;
      Emit_Script_2;

      Wp_Print_Request_Filesystem_Credentials_Modal;
      Wp_Print_Admin_Notice_Templates;

      Adm_Admin_Footer.Run;
   end Render;

   -------------------
   -- Emit_Script_1 --
   -------------------

   procedure Emit_Script_1 is
      use Php.Echoing;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;
   begin
      Echo (TAB0 & "<script id=""tmpl-theme"" type=""text/template"">" & NL);
      Echo (TAB1 & "<# if ( data.screenshot_url ) { #>" & NL);
      Echo (TAB2 & "<div class=""theme-screenshot"">" & NL);
      Echo
        (TAB3
         & "<img src=""{{ data.screenshot_url }}?ver={{ data.version }}"" alt="""" />" & NL);
      Echo (TAB2 & "</div>" & NL);
      Echo (TAB1 & "<# } else { #>" & NL);
      Echo (TAB2 & "<div class=""theme-screenshot blank""></div>" & NL);
      Echo (TAB1 & "<# } #>" & NL);

      Echo (TAB1 & "<# if ( data.installed ) { #>" & NL);
      Wp_Admin_Notice
        (X_X ("Installed", "theme"),
         To_Array_Type
           ([Build ("type", "success"),
             Build ("additional_classes", List_Type'["notice-alt"])]));
      Echo (TAB1 & "<# } #>" & NL);

      Echo
        (TAB1
         & "<# if ( ! data.compatible_wp || ! data.compatible_php ) { #>" & NL);
      Echo (TAB2 & "<div class=""notice notice-error notice-alt""><p>" & NL);
      Echo
        (TAB3
         & "<# if ( ! data.compatible_wp && ! data.compatible_php ) { #>" & NL);
      X_E
        ("This theme does not work with your versions of WordPress and PHP.");
      if Current_User_Can ("update_core")
        and then Current_User_Can ("update_php")
      then
         Printf
           (
            -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
            " "
            & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
            [1 => Self_Admin_URL ("update-core.php"),
             2 => ESC_URL (Wp_Get_Update_PHP_URL)]);
         Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");

      elsif Current_User_Can ("update_core") then
         Printf
           (
            -- translators: %s: URL to WordPress Updates screen.
            " " & abs "<a href=""%s"">Please update WordPress</a>.",
            [Self_Admin_URL ("update-core.php")]);

      elsif Current_User_Can ("update_php") then
         Printf
           (
            -- translators: %s: URL to Update PHP page.
            " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
            [ESC_URL (Wp_Get_Update_PHP_URL)]);
         Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
      end if;

      Echo (TAB3 & "<# else if ( ! data.compatible_wp ) { #>" & NL);
      X_E ("This theme does not work with your version of WordPress.");
      if Current_User_Can ("update_core") then
         Printf
           (
            -- translators: %s: URL to WordPress Updates screen.
            " " & abs "<a href=""%s"">Please update WordPress</a>.",
            [Self_Admin_URL ("update-core.php")]);
      end if;

      Echo (TAB3 & "<# else if ( ! data.compatible_php ) { #>" & NL);
      X_E ("This theme does not work with your version of PHP.");
      if Current_User_Can ("update_php") then
         Printf
           (
            -- translators: %s: URL to Update PHP page.
            " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
            [ESC_URL (Wp_Get_Update_PHP_URL)]);
         Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
      end if;

      Echo (TAB3 & "<# } #>" & NL);
      Echo (TAB2 & "</p></div>" & NL);
      Echo (TAB1 & "<# } #>" & NL);

      Echo (TAB1 & "<span class=""more-details"">");
      X_Ex ("Details &amp; Preview", "theme");
      Echo ("</span>" & NL);

      Echo (TAB1 & "<div class=""theme-author"">");
      -- translators: %s: Theme author name.
      Printf (abs "By %s", ["{{ data.author }}"]);
      Echo ("</div>" & NL);

      Echo (TAB1 & "<div class=""theme-id-container"">" & NL);
      Echo (TAB2 & "<h3 class=""theme-name"">{{ data.name }}</h3>" & NL);

      Echo (TAB2 & "<div class=""theme-actions"">" & NL);
      Echo (TAB3 & "<# if ( data.installed ) { #>" & NL);
      Echo (TAB4 & "<# if ( data.compatible_wp && data.compatible_php ) { #>" & NL);
      -- translators: %s: Theme name.
      declare
         Aria_Label : constant String :=
           Sprintf (X_X ("Activate %s", "theme"), ["{{ data.name }}"]);
      begin
         Echo (TAB5 & "<# if ( data.activate_url ) { #>" & NL);
         Echo (TAB6 & "<# if ( ! data.active ) { #>" & NL);
         Echo
           (TAB7
            & "<a class=""button button-primary activate"" href=""{{ data.activate_url }}"" aria-label="""
            & ESC_Attr (Aria_Label)
            & """>");
         X_E ("Activate");
         Echo ("</a>" & NL);
      end;
      Echo (TAB6 & "<# } else { #>" & NL);
      Echo (TAB7 & "<button class=""button button-primary disabled"">");
      X_Ex ("Activated", "theme");
      Echo ("</button>" & NL);
      Echo (TAB6 & "<# } #>" & NL);
      Echo (TAB5 & "<# } #>" & NL);

      Echo (TAB5 & "<# if ( data.customize_url ) { #>" & NL);
      Echo (TAB6 & "<# if ( ! data.active ) { #>" & NL);
      Echo (TAB7 & "<# if ( ! data.block_theme ) { #>" & NL);
      Echo
        (TAB8
         & "<a class=""button load-customize"" href=""{{ data.customize_url }}"">");
      X_E ("Live Preview");
      Echo ("</a>" & NL);
      Echo (TAB7 & "<# } #>" & NL);
      Echo (TAB6 & "<# } else { #>" & NL);
      Echo
        (TAB7
         & "<a class=""button load-customize"" href=""{{ data.customize_url }}"">");
      X_E ("Customize");
      Echo ("</a>" & NL);
      Echo (TAB6 & "<# } #>" & NL);
      Echo (TAB5 & "<# } else { #>" & NL);
      Echo (TAB6 & "<button class=""button preview install-theme-preview"">");
      X_E ("Preview");
      Echo ("</button>" & NL);
      Echo (TAB5 & "<# } #>" & NL);
      Echo (TAB4 & "<# } else { #>" & NL);
      -- translators: %s: Theme name.
      declare
         Aria_Label : constant String :=
           Sprintf (X_X ("Cannot Activate %s", "theme"), ["{{ data.name }}"]);
      begin
         Echo (TAB5 & "<# if ( data.activate_url ) { #>" & NL);
         Echo
           (TAB6
            & "<a class=""button button-primary disabled"" aria-label="""
            & ESC_Attr (Aria_Label)
            & """>");
         X_Ex ("Cannot Activate", "theme");
         Echo ("</a>" & NL);
      end;
      Echo (TAB5 & "<# } #>" & NL);
      Echo (TAB5 & "<# if ( data.customize_url ) { #>" & NL);
      Echo (TAB6 & "<a class=""button disabled"">");
      X_E ("Live Preview");
      Echo ("</a>" & NL);
      Echo (TAB5 & "<# } else { #>" & NL);
      Echo (TAB6 & "<button class=""button disabled"">");
      X_E ("Preview");
      Echo ("</button>" & NL);
      Echo (TAB5 & "<# } #>" & NL);
      Echo (TAB4 & "<# } #>" & NL);

      Echo (TAB3 & "<# } else { #>" & NL);
      Echo (TAB4 & "<# if ( data.compatible_wp && data.compatible_php ) { #>" & NL);
      -- translators: %s: Theme name.
      declare
         Aria_Label : constant String :=
           Sprintf (X_X ("Install %s", "theme"), ["{{ data.name }}"]);
      begin
         Echo
           (TAB5
            & "<a class=""button button-primary theme-install"" data-name=""{{ data.name }}"" data-slug=""{{ data.id }}"" href=""{{ data.install_url }}"" aria-label="""
            & ESC_Attr (Aria_Label)
            & """>");
         X_E ("Install");
         Echo ("</a>" & NL);
      end;
      Echo (TAB5 & "<button class=""button preview install-theme-preview"">");
      X_E ("Preview");
      Echo ("</button>" & NL);
      Echo (TAB4 & "<# } else { #>" & NL);
      -- translators: %s: Theme name.
      declare
         Aria_Label : constant String :=
           Sprintf (X_X ("Cannot Install %s", "theme"), ["{{ data.name }}"]);
      begin
         Echo
           (TAB5
            & "<a class=""button button-primary disabled"" data-name=""{{ data.name }}"" aria-label="""
            & ESC_Attr (Aria_Label)
            & """>");
         X_Ex ("Cannot Install", "theme");
         Echo ("</a>" & NL);
      end;
      Echo (TAB5 & "<button class=""button disabled"">");
      X_E ("Preview");
      Echo ("</button>" & NL);
      Echo (TAB4 & "<# } #>" & NL);
      Echo (TAB3 & "<# } #>" & NL);
      Echo (TAB2 & "</div>" & NL);
      Echo (TAB1 & "</div>" & NL);
      Echo (TAB0 & "</script>" & NL);
   end Emit_Script_1;

   -------------------
   -- Emit_Script_2 --
   -------------------

   procedure Emit_Script_2 is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;
   begin
      Echo
        (TAB0 & "<script id=""tmpl-theme-preview"" type=""text/template"">" & NL);
      Echo (TAB1 & "<div class=""wp-full-overlay-sidebar"">" & NL);
      Echo (TAB2 & "<div class=""wp-full-overlay-header"">" & NL);
      Echo
        (TAB3
         & "<button class=""close-full-overlay""><span class=""screen-reader-text"">");
      -- translators: Hidden accessibility text.
      X_E ("Close");

      Echo (TAB & "</span></button>" & NL);
      Echo
        (TAB3
         & "<button class=""previous-theme""><span class=""screen-reader-text"">");
      -- translators: Hidden accessibility text.
      X_E ("Previous theme");

      Echo (TAB3 & "</span></button>" & NL);
      Echo
        (TAB3
         & "<button class=""next-theme""><span class=""screen-reader-text"">");
      -- translators: Hidden accessibility text.
      X_E ("Next theme");
      Echo (TAB3 & "</span></button>" & NL);

      Echo (TAB3 & "<# if ( data.installed ) { #>" & NL);
      Echo (TAB4 & "<# if ( data.compatible_wp && data.compatible_php ) { #>" & NL);
      -- translators: %s: Theme name.
      declare
         Aria_Label : constant String :=
           Sprintf (X_X ("Activate %s", "theme"), ["{{ data.name }}"]);
      begin
         Echo (TAB4 & "<# if ( ! data.active ) { #>" & NL);
         Echo
           (TAB5
            & "<a class=""button button-primary activate"" href=""{{ data.activate_url }}"" aria-label="""
            & ESC_Attr (Aria_Label)
            & """>");
         X_E ("Activate");
         Echo ("</a>" & NL);
      end;
      Echo (TAB4 & "<# } else { #>" & NL);
      Echo (TAB5 & "<button class=""button button-primary disabled"">");
      X_Ex ("Activated", "theme");
      Echo ("</button>" & NL);
      Echo (TAB4 & "<# } #>" & NL);
      Echo (TAB3 & "<# } else { #>" & NL);
      Echo (TAB4 & "<a class=""button button-primary disabled"" >");
      X_Ex ("Cannot Activate", "theme");
      Echo ("</a>" & NL);
      Echo (TAB3 & "<# } #>" & NL);

      Echo (TAB3 & "<# } else { #>" & NL);
      Echo
        (TAB4 & "<# if ( data.compatible_wp && data.compatible_php ) then #>" & NL);
      Echo
        (TAB5
         & "<a href=""{{ data.install_url }}"" class=""button button-primary theme-install"" data-name=""{{ data.name }}"" data-slug=""{{ data.id }}"">");
      X_E ("Install");
      Echo (TAB5 & "</a>" & NL);
      Echo (TAB4 & "<# } else { #>" & NL);
      Echo (TAB5 & "<a class=""button button-primary disabled"" >");
      X_Ex ("Cannot Install", "theme");
      Echo ("</a>" & NL);
      Echo (TAB4 & "<# } #>" & NL);
      Echo (TAB3 & "<# } #>" & NL);
      Echo (TAB2 & "</div>" & NL);
      Echo (TAB2 & "<div class=""wp-full-overlay-sidebar-content"">" & NL);
      Echo (TAB3 & "<div class=""install-theme-info"">" & NL);
      Echo (TAB4 & "<h3 class=""theme-name"">{{ data.name }}</h3>" & NL);
      Echo (TAB4 & "<span class=""theme-by"">");
      -- translators: %s: Theme author name.
      Printf (abs "By %s", ["{{ data.author }}"]);

      Echo (TAB4 & "</span>" & NL);

      Echo (TAB4 & "<div class=""theme-screenshot"">" & NL);
      Echo
        (TAB5
         & "<img class=""theme-screenshot"" src=""{{ data.screenshot_url }}?ver={{ data.version }}"" alt="""" />" & NL);
      Echo (TAB4 & "</div>" & NL);

      Echo (TAB4 & "<div class=""theme-details"">" & NL);
      Echo (TAB6 & "<# if ( data.rating ) { #>" & NL);
      Echo (TAB7 & "<div class=""theme-rating"">" & NL);
      Echo (TAB8 & "{{{ data.stars }}}");
      Echo
        (TAB8 & "<a class=""num-ratings"" href=""{{ data.reviews_url }}"">" & NL);
      -- translators: %s: Number of ratings.
      Printf (abs "(%s ratings)", ["{{ data.num_ratings }}"]);

      Echo (TAB8 & "</a>" & NL);
      Echo (TAB7 & "</div>" & NL);
      Echo (TAB6 & "<# } else { #>" & NL);
      Echo (TAB7 & "<span class=""no-rating"">");
      X_E ("This theme has not been rated yet.");
      Echo ("</span>" & NL);
      Echo (TAB6 & "<# } #>" & NL);

      Echo (TAB6 & "<div class=""theme-version"">" & NL);
      -- translators: %s: Theme version.
      Printf (abs "Version: %s", ["{{ data.version }}"]);

      Echo (TAB6 & "</div>" & NL);

      Echo
        (TAB6
         & "<# if ( ! data.compatible_wp || ! data.compatible_php ) { #>" & NL);
      Echo
        (TAB7
         & "<div class=""notice notice-error notice-alt notice-large""><p>" & NL);

      Echo
        (TAB8
         & "<# if ( ! data.compatible_wp && ! data.compatible_php ) { #>" & NL);
      X_E
        ("This theme does not work with your versions of WordPress and PHP.");

      if Current_User_Can ("update_core")
        and then Current_User_Can ("update_php")
      then
         Printf
           (
            -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
            " "
            & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
            [Self_Admin_URL ("update-core.php"),
             ESC_URL (Wp_Get_Update_PHP_URL)]);
         Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");

      elsif Current_User_Can ("update_core") then
         Printf
           (
            -- translators: %s: URL to WordPress Updates screen.
            " " & abs "<a href=""%s"">Please update WordPress</a>.",
            [Self_Admin_URL ("update-core.php")]);

      elsif Current_User_Can ("update_php") then
         Printf
           (
            -- translators: %s: URL to Update PHP page.
            " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
            [ESC_URL (Wp_Get_Update_PHP_URL)]);
         Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
      end if;

      Echo (TAB8 & "<# } else if ( ! data.compatible_wp ) { #>" & NL);
      X_E ("This theme does not work with your version of WordPress.");
      if Current_User_Can ("update_core") then
         Printf
           (
            -- translators: %s: URL to WordPress Updates screen.
            " " & abs "<a href=""%s"">Please update WordPress</a>.",
            [Self_Admin_URL ("update-core.php")]);
      end if;

      Echo (TAB8 & "<# } else if ( ! data.compatible_php ) { #>" & NL);
      X_E ("This theme does not work with your version of PHP.");
      if Current_User_Can ("update_php") then
         Printf
           (
            -- translators: %s: URL to Update PHP page.
            " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
            [ESC_URL (Wp_Get_Update_PHP_URL)]);
         Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
      end if;

      Echo (TAB8 & "<# } #>" & NL);
      Echo (TAB7 & "</p></div>" & NL);
      Echo (TAB6 & "<# } #>" & NL);

      Echo
        (TAB6
         & "<div class=""theme-description"">{{{ data.description }}}</div>" & NL);
      Echo (TAB5 & "</div>" & NL);
      Echo (TAB4 & "</div>" & NL);
      Echo (TAB3 & "</div>" & NL);
      Echo (TAB3 & "<div class=""wp-full-overlay-footer"">" & NL);
      Echo
        (TAB4
         & "<button type=""button"" class=""collapse-sidebar button"" aria-expanded=""true"" aria-label=""");
      ESC_Attr_E ("Collapse Sidebar");
      Echo (""">" & NL);
      Echo (TAB5 & "<span class=""collapse-sidebar-arrow""></span>" & NL);
      Echo (TAB5 & "<span class=""collapse-sidebar-label"">" & NL);
      X_E ("Collapse");
      Echo ("</span>" & NL);
      Echo (TAB4 & "</button>" & NL);
      Echo (TAB3 & "</div>" & NL);
      Echo (TAB2 & "</div>" & NL);
      Echo (TAB2 & "<div class=""wp-full-overlay-main"">" & NL);
      Echo (TAB2 & "<iframe src=""{{ data.preview_url }}"" title=""");
      ESC_Attr_E ("Preview");
      Echo ("""></iframe>" & NL);
      Echo (TAB1 & "</div>" & NL);
      Echo (TAB0 & "</script>" & NL);
   end Emit_Script_2;

end Adm_Theme_Install;
-- require_once ABSPATH & "wp-admin/admin-footer.php";
