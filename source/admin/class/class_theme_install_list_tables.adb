--
-- List Table API: WP_Theme_Install_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Php.Arrays;
with Php.Echoing;
with Php.Lists;
with Php.Misc;
with Php.Strings;

with Array_Lists;
with Binder;
with Globals;
with Helpers_2;
with Logging;
with UStrings;
with Wp_Common;

with Adi_Templates;
with Adi_Theme_Install;

with Class_Themes;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_KSES;
with Inc_Link_Templates;
with Inc_L10n;
with Inc_Plugins;
with Inc_Themes;

package body Class_Theme_Install_List_Tables is

   -----------------
   -- X_Construct --
   -----------------

   overriding
   function X_Construct (Args : Array_Type) return Wp_Theme_Install_List_Table
   is
      Table : constant Wp_Theme_Install_List_Table :=
        Wp_Theme_Install_List_Table'(X_Construct (Args));
   begin
      return Table;
   end X_Construct;

   -------------------
   -- Ajax_User_Can --
   -------------------

   function Ajax_User_Can (This : Wp_Theme_Install_List_Table) return Boolean
   is
      pragma Unreferenced (This);
      use Inc_Capabilities;
   begin
      return Current_User_Can ("install_themes");
   end Ajax_User_Can;

   ------------------------------------
   -- Install_Theme_Search_Form_Wrap --
   ------------------------------------

   function Install_Theme_Search_Form_Wrap is new
     Helpers_2.Generic_Call_Procedure_4
       (Adi_Theme_Install.Install_Theme_Search_Form);

   -------------------
   -- Prepare_Items --
   -------------------

   procedure Prepare_Items (This : in out Wp_Theme_Install_List_Table) is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Adi_Themes;
      use Adi_Theme_Install;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Plugins;

      -- global tabs, tab, paged, type, theme_field_defaults;
      Tabs  : Array_Type renames Globals.Global_Tabs;
      Tab   : UString renames Globals.Global_Tab;
      Paged : Natural renames Globals.Global_Paged;
      Typ   : UString renames Globals.Global_Type;

      Search_Terms  : Array_Type;
      Search_String : String := "";
   begin
      Tab :=
        +(if not Empty (X_REQUEST, "tab")
          then Sanitize_Text_Field (Get_As_String (X_REQUEST, "tab"))
          else "");

      if not Empty (X_REQUEST, "s") then
         Search_String :=
           Strtolower (Wp_Unslash (Get_As_String (X_REQUEST, "s")));

         Search_Terms :=
           Array_Unique
             (Array_Filter
                (Array_Map (Trim'Access, Explode (",", Search_String))));
      end if;

      if not Empty (X_REQUEST, "features") then
         This.Features := As_List (Get (X_REQUEST, "features"));
      end if;

      Paged := This.Get_Pagenum;

      declare
         Per_Page : constant Natural := 36;

         -- These are the tabs which are shown on the page,
         -- Tabs : Array_Type;
      begin
         Set (Tabs, "dashboard", From_String (abs "Search"));
         if "search" = Tab then
            Set (Tabs, "search", From_String (abs "Search Results"));
         end if;
         Set (Tabs, "upload", From_String (X_X ("Upload", "noun")));
         Set (Tabs, "featured", From_String (X_X ("Featured", "themes")));
         -- tabs["popular"]  := _x( "Popular", "themes" );
         Set (Tabs, "new", From_String (X_X ("Latest", "themes")));
         Set
           (Tabs, "updated", From_String (X_X ("Recently Updated", "themes")));

         declare
            Nonmenu_Tabs : List_Type :=
              List_Type'
                ["theme-information"]; -- Valid actions to perform which do not have a Menu item.
         begin
            -- This filter is documented in wp-admin/theme-install.php--
            Tabs := Apply_Filters ("install_themes_tabs", Tabs);

            --
            -- Filters tabs not associated with a menu item on the Install Themes screen.
            --
            -- @since 2.8.0
            --
            -- @param string[] nonmenu_tabs The tabs that don"t have a menu item on
            --                               the Install Themes screen.
            --
            Nonmenu_Tabs :=
              Apply_Filters ("install_themes_nonmenu_tabs", Nonmenu_Tabs);

            -- If a non-valid menu tab has been selected, And it's not a non-menu action.
            if Empty (Tab)
              or else (not Isset (Tabs, -Tab)
                       and then not In_List (-Tab, Nonmenu_Tabs, True))
            then
               Logging.Log ("prepare_items", "not implemented (key)");
               -- Tab := Key (Tabs);
            end if;
         end;

         declare
            Args : Themes_API_Args :=
              (Empty_Themes_API_Args
               with delta
                 Page     => Paged,
                 Per_Page => Per_Page,
                 Fields   => Theme_Field_Defaults);
            -- Args : Array_Type :=
            --   To_Array_Type
            --     ([Build ("page", Paged),
            --       Build ("per_page", Per_Page),
            --       Build ("fields", Theme_Field_Defaults)]);
         begin
            -- switch ( tab ) then
            if Tab = "search" then
                  Typ :=
                    +(if Isset (X_REQUEST, "type")
                     then Wp_Unslash (Get_As_String (X_REQUEST, "type"))
                     else "term");

               if Typ = "tag" then
                  Args.Tag := +"XXX-E01";
               -- List_Type'(Array_Map (Sanitize_Key'Access, Search_Terms));
               -- Set
               --   (Args,
               --    "tag",
               --    From_List
               --      (Array_Map (Sanitize_Key'Access, Search_Terms)));

               elsif Typ = "term" then
                  Args.Search := +Search_String;
               -- Set (Args, "search", From_String (Search_String));

               elsif Typ = "author" then
                  Args.Author := +Search_String;
               -- Set (Args, "author", From_String (Search_String));

               end if;

               if This.Features.Is_Empty then
                  Args.Tag := +"XXX-E02"; -- This.Features;
                  -- Set (Args, "tag", From_List (This.Features));
                  Set
                    (X_REQUEST,
                     "s",
                     From_String (Implode (",", This.Features)));
                  Set (X_REQUEST, "type", From_String ("tag"));
               end if;

               Add_Action
                 ("install_themes_table_header",
                  Install_Theme_Search_Form_Wrap'Access,
                  10,
                  0);

            elsif (-Tab)
                  in "featured"
                   -- case "popular":
                   | "new"
                   | "updated"
            then
               Args.Browse := Tab;
               -- Set (Args, "browse", From_String (-Tab));

            else
               Args := Empty_Themes_API_Args; -- False

            end if;

            --
            -- Filters API request arguments for each Install Themes screen tab.
            --
            -- The dynamic portion of the hook name, `tab`, refers to the theme install
            -- tab.
            --
            -- Possible hook names include:
            --
            --  - `install_themes_table_api_args_dashboard`
            --  - `install_themes_table_api_args_featured`
            --  - `install_themes_table_api_args_new`
            --  - `install_themes_table_api_args_search`
            --  - `install_themes_table_api_args_updated`
            --  - `install_themes_table_api_args_upload`
            --
            -- @since 3.7.0
            --
            -- @param array|false args Theme install API arguments.
            --
            Args :=
              Apply_Filters ("install_themes_table_api_args_" & (-Tab), Args);

            if Args = Empty_Themes_API_Args then
            -- if Args.Is_Empty then
               return;
            end if;

            declare
               API : constant Themes_API_Result :=
                 Themes_API ("query_themes", Args);
            begin
               if not API.Success then
                  Wp_Die
                    ("<p>"
                     & API.Error.Get_Error_Message
                     & "</p> <p><a href=""#"" onclick=""document.location.reload(); return false;"">"
                     & abs "Try Again"
                     & "</a></p>");
               end if;

               -- This.Items := API.Themes; -- XXX

               This.Set_Pagination_Args
                 (To_Array_Type
                    ([Build ("total_items", 888),
                      -- As_Integer (Get (API.Info, "results"))),
                      Build ("per_page", Args.Per_Page), -- Get_As_String (Args, "per_page")),
                      Build ("infinite_scroll", True)]));
            end;
         end;
      end;
   end Prepare_Items;

   --------------
   -- No_Items --
   --------------

   procedure No_Items (This : Wp_Theme_Install_List_Table) is
      use Inc_L10n;
   begin
      X_E ("No themes match your request.");
   end No_Items;

   ---------------
   -- Get_Views --
   ---------------

   function Get_Views (This : Wp_Theme_Install_List_Table) return Array_Type is
      use Array_Lists;
      use UStrings;
      use Inc_Link_Templates;
      -- global tabs, tab;

      Tabs : Array_Type renames Globals.Global_Tabs;
      Tab  : constant String := -Globals.Global_Tab;

      Display_Tabs : Array_Type;
   begin
      for A in Tabs.Iterate loop
         declare
            Action : constant String := Key (A);
            Text   : constant String := As_String (Element (A));
         begin
            Set
              (Display_Tabs,
               "theme-install-" & Action,
               From_Array
                 (To_Array_Type
                    ([Build
                        ("url",
                         Self_Admin_URL ("theme-install.php?tab=" & Action)),
                      Build ("label", Text),
                      Build ("current", Action = Tab)])));
         end;
      end loop;

      return This.Get_Views_Links (Display_Tabs);
   end Get_Views;

   -------------
   -- Display --
   -------------

   procedure Display (This : in out Wp_Theme_Install_List_Table) is
      use Php.Echoing;
      use UStrings;
      use Wp_Common;
      use Inc_Functions;
   begin
      Wp_Nonce_Field
        ("fetch-list-" & Get_Class (This), "_ajax_fetch_list_nonce");

      Echo (TAB2 & "<div class=""tablenav top themes"">");
      Echo (TAB3 & "<div class=""alignleft actions"">");

      --
      -- Fires in the Install Themes list table header.
      --
      -- @since 2.8.0
      --
      Do_Action ("install_themes_table_header");

      Echo (TAB3 & "</div>");
      Echo (TAB3);
      This.Pagination ("top");
      Echo (TAB3 & "<br class=""clear"" />");
      Echo (TAB2 & "</div>");

      Echo (TAB2 & "<div id=""availablethemes"">");
      Echo (TAB3);
      This.Display_Rows_Or_Placeholder;
      Echo (TAB2 & "</div>");

      This.Tablenav ("bottom");
   end Display;

   ------------------
   -- Display_Rows --
   ------------------

   procedure Display_Rows (This : in out Wp_Theme_Install_List_Table) is
      use Php.Echoing;
      use UStrings;
      use Adi_Themes;

      Themes : Theme_API_List; -- := This.Items; -- XXX
   begin
      for Theme of Themes loop
         Echo (TAB4 & "<div class=""available-theme installable-theme"">");
         This.Single_Row (Theme);
         Echo (TAB4 & "</div>");
      end loop; -- End foreach theme_names.

      This.Theme_Installer;
   end Display_Rows;

   ----------------
   -- Single_Row --
   ----------------

   procedure Single_Row
     (This : in out Wp_Theme_Install_List_Table; Theme : Adi_Themes.Theme_API_Type) -- Theme_API_Type) -- Class_Themes.Wp_Theme) -- Array_Type)
   is
      use Php.Echoing;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Adi_Theme_Install;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_KSES;
      use Inc_Link_Templates;
      use Inc_L10n;
      -- global themes_allowedtags;
   begin
      -- if Theme.Is_Empty then
      --    return;
      -- end if;

      declare
         Name : constant String := Wp_KSES (-Theme.Name, Themes_Allowedtags);

         Author : constant String :=
           Wp_KSES (-Theme.Author, Themes_Allowedtags);

         -- translators: %s: Theme name.
         Preview_Title : constant String :=
           Sprintf (abs "Preview &#8220;%s&#8221;", [Name]);

         Preview_URL : constant String :=
           Add_Query_Arg
             (To_Array_Type
                ([Build ("tab", "theme-information"),
                  Build ("theme", -Theme.Slug)]),
              Self_Admin_URL ("theme-install.php"));

         Actions : List_Type;

         Install_URL : constant String :=
           Add_Query_Arg
             (To_Array_Type
                ([Build ("action", "install-theme"),
                  Build ("theme", -Theme.Slug)]),
              Self_Admin_URL ("update.php"));

         Update_URL : constant String :=
           Add_Query_Arg
             (To_Array_Type
                ([Build ("action", "upgrade-theme"),
                  Build ("theme", -Theme.Slug)]),
              Self_Admin_URL ("update.php"));

         Status : constant String := This.X_Get_Theme_Status (Theme);
      begin
         if Status = "update_available" then
            Append
              (Actions,
               Sprintf
                 ("<a class=""install-now"" href=""%s"" aria-label=""%s"">%s</a>",
                  [1 =>
                     ESC_URL
                       (Wp_Nonce_URL
                          (Update_URL, "upgrade-theme_" & (-Theme.Slug))),
                   -- translators: %s: Theme version.
                   2 =>
                     ESC_Attr
                       (Sprintf
                          (abs "Update to version %s", [-Theme.Version])),
                   3 => abs "Update"]));

         elsif Status in "newer_installed" | "latest_installed" then
            Append
              (Actions,
               Sprintf
                 ("<span class=""install-now"">%s</span>",
                  [1 => X_X ("Installed", "theme")]));

         elsif Status = "install" or True then
            Append
              (Actions,
               Sprintf
                 ("<a class=""install-now"" href=""%s"" aria-label=""%s"">%s</a>",
                  [1 =>
                     ESC_URL
                       (Wp_Nonce_URL
                          (Install_URL, "install-theme_" & (-Theme.Slug))),
                   -- translators: %s: Theme name.
                   2 =>
                     ESC_Attr
                       (Sprintf (X_X ("Install %s", "theme"), [1 => Name])),
                   3 => X_X ("Install Now", "theme")]));

         end if;

         Append
           (Actions,
            Sprintf
              ("<a class=""install-theme-preview"" href=""%s"" aria-label=""%s"">%s</a>",
               [1 => ESC_URL (Preview_URL),
                2 => ESC_Attr (Preview_Title),
                3 => abs "Preview"]));

         --
         -- Filters the install action links for a theme in the Install Themes list table.
         --
         -- @since 3.4.0
         --
         -- @param string[] actions An array of theme action links. Defaults are
         --                          links to Install Now, Preview, and Details.
         -- @param stdClass theme   An object that contains theme data returned by the
         --                          WordPress.org API.
         --
         Actions := Apply_Filters ("theme_install_actions", Actions, Theme);

         Echo
           (TAB2
            & "<a class=""screenshot install-theme-preview"" href="""
            & ESC_URL (Preview_URL)
            & """ aria-label="""
            & ESC_Attr (Preview_Title)
            & """>");
         Echo
           (TAB3
            & "<img src="""
            & ESC_URL ((-Theme.Screenshot_URL) & "?ver=" & (-Theme.Version))
            & """ width=""150"" alt="""" />");
         Echo (TAB2 & "</a>");

         Echo (TAB2 & "<h3>" & Name & "</h3>");
         Echo (TAB2 & "<div class=""theme-author"">");

         -- translators: %s: Theme author.
         Printf (abs "By %s", [Author]);

         Echo (TAB2 & "</div>");

         Echo (TAB2 & "<div class=""action-links"">");
         Echo (TAB3 & "<ul>");
         for Action of Actions loop
            Echo (TAB5 & "<li>" & Action & "</li>");
         end loop;
         Echo
           (TAB4
            & "<li class=""hide-if-no-js""><a href=""#"" class=""theme-detail"">");
         X_E ("Details");
         Echo ("</a></li>");
         Echo (TAB3 & "</ul>");
         Echo (TAB2 & "</div>");

         This.Install_Theme_Info (Theme);
      end;
   end Single_Row;

   ---------------------
   -- Theme_Installer --
   ---------------------

   procedure Theme_Installer (This : Wp_Theme_Install_List_Table) is
      use Php.Echoing;
      use UStrings;
      use Inc_L10n;
   begin
      Echo
        (TAB2
         & "<div id=""theme-installer"" class=""wp-full-overlay expanded"">");
      Echo (TAB3 & "<div class=""wp-full-overlay-sidebar"">");
      Echo (TAB4 & "<div class=""wp-full-overlay-header"">");
      Echo (TAB5 & "<a href=""#"" class=""close-full-overlay button"">");
      X_E ("Close");
      Echo ("</a>");
      Echo (TAB5 & "<span class=""theme-install""></span>");
      Echo (TAB4 & "</div>");
      Echo (TAB4 & "<div class=""wp-full-overlay-sidebar-content"">");
      Echo (TAB5 & "<div class=""install-theme-info""></div>");
      Echo (TAB5 & "</div>");
      Echo (TAB4 & "<div class=""wp-full-overlay-footer"">");
      Echo
        (TAB5
         & "<button type=""button"" class=""collapse-sidebar button"" aria-expanded=""true"" aria-label=""");
      ESC_Attr_E ("Collapse Sidebar");
      Echo (""">");
      Echo (TAB6 & "<span class=""collapse-sidebar-arrow""></span>");
      Echo (TAB6 & "<span class=""collapse-sidebar-label"">");
      X_E ("Collapse");
      Echo ("</span>");
      Echo (TAB5 & "</button>");
      Echo (TAB4 & "</div>");
      Echo (TAB3 & "</div>");
      Echo (TAB3 & "<div class=""wp-full-overlay-main""></div>");
      Echo (TAB2 & "</div>");
   end Theme_Installer;

   ----------------------------
   -- Theme_Installer_Single --
   ----------------------------

   procedure Theme_Installer_Single
     (This  : Wp_Theme_Install_List_Table;
      Theme : Adi_Themes.Theme_API_Type) -- Array_Type)
   is
      use Php.Echoing;
      use UStrings;
      use Inc_Formatting;
   begin
      Echo
        (TAB2
         & "<div id=""theme-installer"" class=""wp-full-overlay single-theme"">");
      Echo (TAB3 & "<div class=""wp-full-overlay-sidebar"">");
      Echo (TAB4);
      This.Install_Theme_Info (Theme);
      Echo (TAB3 & "</div>");
      Echo (TAB3 & "<div class=""wp-full-overlay-main"">");
      Echo
        (TAB4
         & "<iframe src="""
         & ESC_URL (-Theme.Preview_URL)
         & """></iframe>");
      Echo (TAB3 & "</div>");
      Echo (TAB2 & "</div>");
   end Theme_Installer_Single;

   ------------------------
   -- Install_Theme_Info --
   ------------------------

   procedure Install_Theme_Info
     (This : Wp_Theme_Install_List_Table; Theme : Adi_Themes.Theme_API_Type) -- Array_Type)
   is
      use Php.Echoing;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Adi_Templates;
      use Adi_Theme_Install;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_KSES;
      use Inc_Link_Templates;
      use Inc_L10n;
      -- global themes_allowedtags;
   begin
      -- if Theme.Is_Empty then
      --    return;
      -- end if;

      declare
         Name : constant String := Wp_KSES (-Theme.Name, Themes_Allowedtags);

         Author : constant String :=
           Wp_KSES (-Theme.Author, Themes_Allowedtags);

         Install_URL : constant String :=
           Add_Query_Arg
             (To_Array_Type
                ([Build ("action", "install-theme"),
                  Build ("theme", -Theme.Slug)]),
              Self_Admin_URL ("update.php"));

         Update_URL : constant String :=
           Add_Query_Arg
             (To_Array_Type
                ([Build ("action", "upgrade-theme"),
                  Build ("theme", -Theme.Slug)]),
              Self_Admin_URL ("update.php"));

         Status : constant String := This.X_Get_Theme_Status (Theme);
      begin
         Echo (TAB2 & "<div class=""install-theme-info"">");

         if Status = "update_available" then
            Printf
              ("<a class=""theme-install button button-primary"" href=""%s"" aria-label=""%s"">%s</a>",
               [1 =>
                  ESC_URL
                    (Wp_Nonce_URL
                       (Update_URL, "upgrade-theme_" & (-Theme.Slug))),
                -- translators: %s: Theme version.
                2 =>
                  ESC_Attr
                    (Sprintf (abs "Update to version %s", [-Theme.Version])),
                3 => abs "Update"]);

         elsif Status in "newer_installed" | "latest_installed" then
            Printf
              ("<span class=""theme-install"">%s</span>",
               [X_X ("Installed", "theme")]);

         elsif Status = "install" or True then
            Printf
              ("<a class=""theme-install button button-primary"" href=""%s"">%s</a>",
               [1 =>
                  ESC_URL
                    (Wp_Nonce_URL
                       (Install_URL, "install-theme_" & (-Theme.Slug))),
                2 => abs "Install"]);

         end if;

         Echo (TAB3 & "<h3 class=""theme-name"">" & Name & "</h3>");
         Echo (TAB3 & "<span class=""theme-by"">");

         -- translators: %s: Theme author.
         Printf (abs "By %s", [Author]);
      end;

      Echo (TAB3 & "</span>");
      if Isset (-Theme.Screenshot_URL) then
         Echo
           (TAB4
            & "<img class=""theme-screenshot"" src="""
            & ESC_URL ((-Theme.Screenshot_URL) & "?ver=" & (-Theme.Version))
            & """ alt="""" />");
      end if;
      Echo (TAB3 & "<div class=""theme-details"">");

      Wp_Star_Rating
        (To_Array_Type
           ([Build ("rating", Integer (Theme.Rating)),
             Build ("type", "percent"),
             Build ("number", Theme.Num_Ratings)]));

      Echo (TAB4 & "<div class=""theme-version"">");
      Echo (TAB5 & "<strong>");
      X_E ("Version:");
      Echo (" </strong>");
      Echo (Wp_KSES (-Theme.Version, Themes_Allowedtags));
      Echo (TAB4 & "</div>");
      Echo (TAB4 & "<div class=""theme-description"">");
      Echo (Wp_KSES (-Theme.Description, Themes_Allowedtags));
      Echo (TAB4 & "</div>");
      Echo (TAB3 & "</div>");
      Echo
        (TAB3
         & "<input class=""theme-preview-url"" type=""hidden"" value="""
         & ESC_URL (-Theme.Preview_URL)
         & """ />");
      Echo (TAB2 & "</div>");
   end Install_Theme_Info;

   ---------------
   -- X_JS_Vars --
   ---------------

   procedure X_JS_Vars
     (This : Wp_Theme_Install_List_Table; Extra_Args : Array_Type)
   is
      use Array_Lists;
      use UStrings;
      -- global tab, type;
   begin
      X_JS_Vars
        (This, -- Wp_List_Table (This),
         To_Array_Type
           ([Build ("tab", -Globals.Global_Tab),
             Build ("type", -Globals.Global_Type)])); -- parent::
   end X_JS_Vars;

   ------------------------
   -- X_Get_Theme_Status --
   ------------------------

   function X_Get_Theme_Status
     (This : Wp_Theme_Install_List_Table; Theme : Adi_Themes.Theme_API_Type)
      return String
   is
      use Php.Misc;
      use UStrings;
      use Class_Themes;
      use Inc_Themes;

      Status : UString := +"install";

      Installed_Theme : Wp_Theme := Wp_Get_Theme (-Theme.Slug);
   begin
      if Installed_Theme.Exists then
         if Version_Compare
              (As_String (Installed_Theme.Get ("Version")), -Theme.Version, "=")
         then
            Status := +"latest_installed";
         elsif Version_Compare
                 (As_String (Installed_Theme.Get ("Version")),
                  -Theme.Version,
                  ">")
         then
            Status := +"newer_installed";
         else
            Status := +"update_available";
         end if;
      end if;

      return -Status;
   end X_Get_Theme_Status;

end Class_Theme_Install_List_Tables;
