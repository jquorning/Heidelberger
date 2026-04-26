--
-- List Table API: WP_Plugin_Install_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Php.Arrays;
with Php.Echoing;
with Php.Misc;
with Php.Sorting;
with Php.Strings;

with Array_Lists;
with Binder;
with Globals;
with Helpers;
with Lists;
with Wp_Common;

with Adi_Plugin_Install;
with Adi_Templates;

with Class_Plugin_Dependencies;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_General_Templates;
with Inc_KSES;
with Inc_Link_Templates;
with Inc_L10n;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Users;

package body Class_Plugin_Install_List_Tables is
   use Lists;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Args : Array_Type) return Wp_Plugin_Install_List_Table
   is
      This : Wp_Plugin_Install_List_Table;
   begin
      return This;
   end X_Construct;

   -------------------
   -- Ajax_User_Can --
   -------------------

   function Ajax_User_Can (This : Wp_Plugin_Install_List_Table) return Boolean
   is
      use Inc_Capabilities;
   begin
      return Current_User_Can ("install_plugins");
   end Ajax_User_Can;

   ---------------------------
   -- Get_Installed_Plugins --
   ---------------------------

   function Get_Installed_Plugins
     (This : Wp_Plugin_Install_List_Table) return Array_Type
   is
      use Inc_Options;

      Plugins : Array_Type;

      Plugin_Info : Array_Type := Get_Site_Transient ("update_plugins");
   begin
      -- if Isset (Plugin_Info.No_Update) then
      --    for Plugin of Plugin_Info.No_Update loop
      --       if Isset (Plugin.Slug) then
      --          Plugin.Upgrade := False;
      --          Set (Plugins, Plugin.Slug, Plugin);
      --       end if;
      --    end loop;
      -- end if;

      -- if Isset (Plugin_Info.Response) then
      --    for Plugin of Plugin_Info.Response loop
      --       if Isset (Plugin.Slug) then
      --          Plugin.Upgrade := True;
      --          Set (Plugins, Plugin.Slug, Plugin);
      --       end if;
      --    end loop;
      -- end if;

      return Plugins;
   end Get_Installed_Plugins;

   --------------------------------
   -- Get_Installed_Plugin_Slugs --
   --------------------------------

   function Get_Installed_Plugin_Slugs
     (This : Wp_Plugin_Install_List_Table) return Array_Type
   is
      use Php.Arrays;
   begin
      return Array_Keys (This.Get_Installed_Plugins);
   end Get_Installed_Plugin_Slugs;

   -------------------
   -- Prepare_Items --
   -------------------

   overriding
   procedure Prepare_Items (This : in out Wp_Plugin_Install_List_Table) is
      use Php.Arrays;
      use Php.Sorting;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Adi_Plugin_Install;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_General_Templates;
      use Inc_L10n;
      use Inc_Pluggables;
      use Inc_Plugins;
      use Inc_Users;

      -- require_once ABSPATH . "wp-admin/includes/plugin-install.php";

      -- global tabs, tab, paged, type, term;
      Per_Page : constant Natural := 36;

      Tabs  : Array_Type renames Globals.Global_Tabs;
      Tab   : UString renames Globals.Global_Tab;
      Paged : Natural renames Globals.Global_Paged;
      Typ   : UString renames Globals.Global_Type;
      Term  : UString renames Globals.Global_Term;
   begin
      Tab :=
        +(if not Empty (X_REQUEST, "tab")
          then Sanitize_Text_Field (Get_As_String (X_REQUEST, "tab"))
          else "");

      Paged := This.Get_Pagenum;

      -- These are the tabs which are shown on the page.
      Tabs := Empty_Array;

      if "search" = Tab then
         Set (Tabs, "search", From_String (abs "Search Results"));
      end if;

      if "beta" = Tab or else Str_Contains (Get_Bloginfo ("version"), "-") then
         Set
           (Tabs,
            "beta",
            From_String (X_X ("Beta Testing", "Plugin Installer")));
      end if;

      Set
        (Tabs, "featured", From_String (X_X ("Featured", "Plugin Installer")));
      Set (Tabs, "popular", From_String (X_X ("Popular", "Plugin Installer")));
      Set
        (Tabs,
         "recommended",
         From_String (X_X ("Recommended", "Plugin Installer")));
      Set
        (Tabs,
         "favorites",
         From_String (X_X ("Favorites", "Plugin Installer")));

      if Current_User_Can ("upload_plugins") then
         --
         -- No longer a real tab. Here for filter compatibility.
         -- Gets skipped in get_views().
         --
         Set (Tabs, "upload", From_String (abs "Upload Plugin"));
      end if;

      declare
         Nonmenu_Tabs : Array_Type :=
           Build
             ("plugin-information",
              ""); -- Valid actions to perform which do not have a Menu item.
      begin
         --
         -- Filters the tabs shown on the Add Plugins screen.
         --
         -- @since 2.7.0
         --
         -- @param string[] tabs The tabs shown on the Add Plugins screen. Defaults include
         --                       "featured", "popular", "recommended", "favorites", and "upload".
         --
         Tabs := Apply_Filters ("install_plugins_tabs", Tabs);

         --
         -- Filters tabs not associated with a menu item on the Add Plugins screen.
         --
         -- @since 2.7.0
         --
         -- @param string[] nonmenu_tabs The tabs that don"t have a menu item on the Add Plugins screen.
         --
         Nonmenu_Tabs :=
           Apply_Filters ("install_plugins_nonmenu_tabs", Nonmenu_Tabs);

         -- If a non-valid menu tab has been selected, And it's not a non-menu action.
         if Empty (Tab)
           or else (not Isset (Tabs, -Tab)
                    and then not In_Array (-Tab, Nonmenu_Tabs, True))
         then
            Tab := +"XXX-E99"; -- Key (Tabs);
         end if;
      end;

      declare
         Installed_Plugins : constant Array_Type := This.Get_Installed_Plugins;

         Args : Plugin_API_Args :=
           (Null_Plugin_API_Args
            with delta
              Page     => Paged,
              Per_Page => Per_Page,
              -- Send the locale to the API so it can provide context-sensitive results.
              Locale   => +Get_User_Locale);
         -- Args : Array_Type :=
         --   To_Array_Type
         --     ([Build ("page", Paged),
         --       Build ("per_page", Per_Page),
         --       -- Send the locale to the API so it can provide context-sensitive results.
         --       Build ("locale", Get_User_Locale)]);
      begin
         -- switch ( tab ) then
         if Tab = "search" then

            Typ :=
              +(if Isset (X_REQUEST, "type")
                then Wp_Unslash (Get_As_String (X_REQUEST, "type"))
                else "term");

            Term :=
              +(if Isset (X_REQUEST, "s")
                then Wp_Unslash (Get_As_String (X_REQUEST, "s"))
                else "");

            -- switch ( type ) then
            if Typ = "tag" then
               Args.Tag := +Sanitize_Title_With_Dashes (-Term);

            elsif Typ = "term" then
               Args.Search := Term;

            elsif Typ = "author" then
               Args.Author := Term;

            end if;

         elsif (-Tab) in "featured" | "popular" | "new" | "beta" then
            Args.Browse := Tab;

         elsif Tab = "recommended" then
            Args.Browse := Tab;
            -- Include the list of installed plugins so we can get relevant results.
            Args.Installed_Plugins := +"XXX-E98"; -- Array_Keys (Installed_Plugins);

         elsif Tab = "favorites" then
            declare
               Action : constant String :=
                 "save_wporg_username_"
                 & Helpers.Image (Integer (Get_Current_User_Id));
               User   : UString;
            begin
               if Isset (XX_GET, "_wpnonce")
                 and then Wp_Verify_Nonce
                            (Wp_Unslash (Get_As_String (XX_GET, "_wpnonce")),
                             Action) /= 0
               then
                  User :=
                    +(if Isset (XX_GET, "user")
                      then Wp_Unslash (Get_As_String (XX_GET, "user"))
                      else Get_User_Option ("wporg_favorites"));

                  -- If the save url parameter is passed with a falsey value, don't save the favorite user.
                  if not Isset (XX_GET, "save")
                    or else As_Boolean (Get (XX_GET, "save"))
                  then
                     Update_User_Meta
                       (Get_Current_User_Id, "wporg_favorites", -User);
                  end if;
               else
                  User := +Get_User_Option ("wporg_favorites");
               end if;

               if User /= "" then
                  Args.User := User;
               else
                  Args := Null_Plugin_API_Args; -- False
               end if;
            end;

            Add_Action
              ("install_plugins_favorites",
               Install_Plugins_Favorites_Form'Access,
               9,
               0);

         else
            Args := Null_Plugin_API_Args; -- False
         end if;

         --
         -- Filters API request arguments for each Add Plugins screen tab.
         --
         -- The dynamic portion of the hook name, `tab`, refers to the plugin install tabs.
         --
         -- Possible hook names include:
         --
         --  - `install_plugins_table_api_args_favorites`
         --  - `install_plugins_table_api_args_featured`
         --  - `install_plugins_table_api_args_popular`
         --  - `install_plugins_table_api_args_recommended`
         --  - `install_plugins_table_api_args_upload`
         --  - `install_plugins_table_api_args_search`
         --  - `install_plugins_table_api_args_beta`
         --
         -- @since 3.7.0
         --
         -- @param array|false args Plugin install API arguments.
         --
         Args := Apply_Filters ("install_plugins_table_api_args_" & (-Tab), Args);

         if Args = Null_Plugin_API_Args then -- not
            return;
         end if;

         declare
            API : constant Plugin_API_Result :=
              Plugins_API ("query_plugins", Args);
         begin
            if not API.Success then
            -- if Is_Wp_Error (Api) then
               This.Error := API.Error;
               return;
            end if;

            This.Items := API.Plugins;

            if This.Orderby /= "" then
               UASort (This.Items); -- , ""); -- array( this, "order_callback" ) );

            end if;

            This.Set_Pagination_Args
              (To_Array_Type
                 ([Build ("total_items", Get (API.Info, "results")),
                   Build ("per_page", Args.Per_Page)]));

            if Isset (API.Info, "groups") then
               This.Groups := As_Array (Get (API.Info, "groups"));
            end if;
         end;

         if not Installed_Plugins.Is_Empty then
            declare
               JS_Plugins : Array_Type :=
                 Array_Fill_Keys
                   (List_Type'
                      ["all",
                       "search",
                       "active",
                       "inactive",
                       "recently_activated",
                       "mustuse",
                       "dropins"],
                    False); -- Empty_Array);
            begin
               Set
                 (JS_Plugins,
                  "all",
                  From_Array
                    (Array_Values
                       (Wp_List_Pluck (Installed_Plugins, "plugin"))));

               declare
                  Upgrade_Plugins : constant Array_Type :=
                    Wp_Filter_Object_List
                      (Installed_Plugins,
                       Build ("upgrade", True),
                       "and",
                       "plugin");
               begin
                  if not Upgrade_Plugins.Is_Empty then
                     Set
                       (JS_Plugins,
                        "upgrade",
                        From_Array (Array_Values (Upgrade_Plugins)));
                  end if;
               end;

               Wp_Localize_Script
                 ("updates",
                  "_wpUpdatesItemCounts",
                  To_Array_Type
                    ([Build ("plugins", JS_Plugins),
                      Build ("totals", 0) -- Wp_Get_Update_Data)
                     ]));
            end;
         end if;
      end;
   end Prepare_Items;

   --------------
   -- No_Items --
   --------------

   procedure No_Items (This : Wp_Plugin_Install_List_Table) is
      use Php.Echoing;
      use Array_Lists;
      use UStrings;
      use Class_Errors;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if This.Error /= Null_Wp_Error then
      -- if Isset (This.Error) then
         declare
            Error_Message : UString :=
              +"<p>" & This.Error.Get_Error_Message & "</p>";
         begin
            Append
              (Error_Message,
               "<p class=""hide-if-no-js""><button class=""button try-again"">"
               & abs "Try Again"
               & "</button></p>");
            Wp_Admin_Notice
              (-Error_Message,
               To_Array_Type
                 ([Build ("additional_classes", List_Type'["inline", "error"]),
                   Build ("paragraph_wrap", False)]));
         end;
      else
         Echo (TAB2 & "<div class=""no-plugin-results"">");
         X_E ("No plugins found. Try a different search.");
         Echo ("</div>" & NL);
      end if;
   end No_Items;

   ---------------
   -- Get_Views --
   ---------------

   function Get_Views (This : Wp_Plugin_Install_List_Table) return Array_Type
   is
      use Array_Lists;
      use UStrings;
      use Inc_Link_Templates;

      -- global tabs, tab;
      Tabs : constant Array_Type := Globals.Global_Tabs;
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
               "plugin-install-" & Action,
               From_Array
                 (To_Array_Type
                    ([Build
                        ("url",
                         Self_Admin_URL ("plugin-install.php?tab=" & Action)),
                      Build ("label", Text),
                      Build ("current", Action = Tab)])));
         end;
      end loop;
      -- No longer a real tab.
      Delete (Display_Tabs, "plugin-install-upload");

      return This.Get_Views_Links (Display_Tabs);
   end Get_Views;

   -----------
   -- Views --
   -----------

   procedure Views (This : Wp_Plugin_Install_List_Table) is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Adi_Plugin_Install;

      Views : Array_Type := This.Get_Views;
   begin
      -- This filter is documented in wp-admin/includes/class-wp-list-table.php
      Views := Apply_Filters ("views_" & (-This.Screen.Id), Views);

      This.Screen.Render_Screen_Reader_Content ("heading_views");

      Echo (TAB0 & "<div class=""wp-filter"">" & NL);
      Echo (TAB1 & "<ul class=""filter-links"">" & NL);

      if not Views.Is_Empty then
         for A in Views.Iterate loop
            declare
               Class : constant String := Key (A);
               View  : constant String := As_String (Element (A));
            begin
               Set
                 (Views,
                  Class,
                  From_String (TAB & "<li class=""class"">" & View));
            end;
         end loop;
         Echo (Implode (" </li>" & NL, Views) & "</li>" & NL);
      end if;
      Echo (TAB1 & "</ul>" & NL);

      Install_Search_Form;
      Echo (TAB0 & "</div>" & NL);
   end Views;

   -------------
   -- Display --
   -------------

   procedure Display (This : in out Wp_Plugin_Install_List_Table) is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;

      Singular : constant Boolean :=
        As_Boolean (Get (This.X_Args, "singular"));

      Data_Attr : UString;
   begin
      if Singular then
         Data_Attr := +" data-wp-lists=""list:singular""";
      end if;

      This.Display_Tablenav ("top");

      Echo
        (TAB0
         & "<div class=""wp-list-table "
         & Implode (" ", Array_Type'(This.Get_Table_Classes)) & ">");

      This.Screen.Render_Screen_Reader_Content ("heading_list");

      Echo (TAB1 & "<div id=""the-list""" & (-Data_Attr) & ">" & NL);
      This.Display_Rows_Or_Placeholder;
      Echo (TAB1 & "</div>" & NL);
      Echo (TAB0 & "</div>" & NL);

      This.Display_Tablenav ("bottom");
   end Display;

   ----------------------
   -- Display_Tablenav --
   ----------------------

   overriding
   procedure Display_Tablenav
     (This : in out Wp_Plugin_Install_List_Table; Which : String)
   is
      use Php.Echoing;
      use UStrings;
      use Wp_Common;
      use Inc_Functions;
   begin
      if "featured" = Globals.Global_Tab then
         -- if "featured" = GLOBALS["tab"]  then
         return;
      end if;

      if "top" = Which then
         Wp_Referer_Field;

         Echo ("<div class=""tablenav top"">");
         Echo ("        <div class=""alignleft actions"">");

         --
         -- Fires before the Plugin Install table header pagination is displayed.
         --
         -- @since 2.7.0
         --
         Do_Action ("install_plugins_table_header");

         Echo ("        </div>");
         This.Pagination (Which);
         Echo ("        <br class=""clear"" />");
         Echo ("</div>");
      else
         Echo ("<div class=""tablenav bottom"">");
         This.Pagination (Which);
         Echo ("        <br class=""clear"" />");
         Echo ("</div>");
      end if;
   end Display_Tablenav;

   -----------------------
   -- Get_Table_Classes --
   -----------------------

   function Get_Table_Classes
     (This : Wp_Plugin_Install_List_Table) return Array_Type is
   begin
      return Build ("widefat", As_Boolean (Get (This.X_Args, "plural")));
   end Get_Table_Classes;

           -----------------
           -- Get_Columns --
           -----------------

   function Get_Columns (This : Wp_Plugin_Install_List_Table) return Array_Type
   is
   begin
      return Empty_Array;
   end Get_Columns;

   --         --
   --         -- @param object plugin_a
   --         -- @param object plugin_b
   --         -- @return int
   --         --
   --         private function order_callback( plugin_a, plugin_b ) then
   --                 orderby = this.orderby;
   --                 if ( ! isset( plugin_a.orderby, plugin_b.orderby ) ) then
   --                         return 0;
   --                 end;

   --                 a = plugin_a.orderby;
   --                 b = plugin_b.orderby;

   --                 if ( a === b ) then
   --                         return 0;
   --                 end;

   --                 if ( "DESC" === this.order ) then
   --                         return ( a < b ) ? 1 : -1;
   --                 end; else then
   --                         return ( a < b ) ? -1 : 1;
   --                 end;
   --         end;

   ------------------
   -- Display_Rows --
   ------------------

   overriding
   procedure Display_Rows (This : in out Wp_Plugin_Install_List_Table) is
      use Php.Echoing;
      use Php.Misc;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Adi_Plugin_Install;
      use Adi_Templates;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_KSES;
      use Inc_Link_Templates;
      use Inc_L10n;

      Plugins_Allowedtags : constant Array_Type :=
        To_Array_Type
          ([Build
              ("a",
               To_Array_Type
                 ([Build ("href", Empty_Array),
                   Build ("title", Empty_Array),
                   Build ("target", Empty_Array)])),
            Build ("abbr", Build ("title", Empty_Array)),
            Build ("acronym", Build ("title", Empty_Array)),
            Build ("code", Empty_Array),
            Build ("pre", Empty_Array),
            Build ("em", Empty_Array),
            Build ("strong", Empty_Array),
            Build ("ul", Empty_Array),
            Build ("ol", Empty_Array),
            Build ("li", Empty_Array),
            Build ("p", Empty_Array),
            Build ("br", Empty_Array)]);

      Plugins_Group_Titles : constant Array_Type :=
        To_Array_Type
          ([Build
              ("Performance",
               X_X ("Performance", "Plugin installer group title")),
            Build ("Social", X_X ("Social", "Plugin installer group title")),
            Build ("Tools", X_X ("Tools", "Plugin installer group title"))]);

      Group : UString; -- := null;
   begin
      for A in This.Items.Iterate loop
         declare
            Plugin : constant Array_Type := As_Array (Element (A));
         begin

            -- (array)
            -- if  is_object( plugin )  then
            --         plugin := (array) plugin;
            -- end if;

            -- Display the group heading if there is one.
            if Isset (Plugin, "group")
              and then Get_As_String (Plugin, "group") /= Group
            then
               declare
                  Group_Name : UString;
               begin
                  if Isset (This.Groups, Get_As_String (Plugin, "group")) then
                     Group_Name :=
                       +Get_As_String
                          (This.Groups, Get_As_String (Plugin, "group"));
                     if Isset (Plugins_Group_Titles, -Group_Name) then
                        Group_Name :=
                          +Get_As_String (Plugins_Group_Titles, -Group_Name);
                     end if;
                  else
                     Group_Name := +Get_As_String (Plugin, "group");
                  end if;

                  -- Starting a new group, close off the divs of the last one.
                  if not Empty (-Group) then
                     Echo ("</div></div>");
                  end if;

                  Echo
                    ("<div class=""plugin-group""><h3>"
                     & ESC_HTML (-Group_Name)
                     & "</h3>");
                  -- Needs an extra wrapping div for nth-child selectors to work.
                  Echo ("<div class=""plugin-items"">");

                  Group := +Get_As_String (Plugin, "group");
               end;
            end if;

            declare
               Title : constant String :=
                 Wp_KSES (Get_As_String (Plugin, "name"), Plugins_Allowedtags);

               -- Remove any HTML from the description.
               Description_2 : constant String :=
                 Strip_Tags (Get_As_String (Plugin, "short_description"));

               --
               -- Filters the plugin card description on the Add Plugins screen.
               --
               -- @since 6.0.0
               --
               -- @param string description Plugin card description.
               -- @param array  plugin      An array of plugin data. See then@see plugins_api()end;
               --                            for the list of possible values.
               --
               Description : constant String :=
                 Apply_Filters
                   ("plugin_install_description", Description_2, Plugin);

               Version : constant String :=
                 Wp_KSES
                   (Get_As_String (Plugin, "version"), Plugins_Allowedtags);

               Name : constant String := Strip_Tags (Title & " " & Version);

               Author_2 : constant String :=
                 Wp_KSES
                   (Get_As_String (Plugin, "author"), Plugins_Allowedtags);

               Author : constant String :=
                 (if not Empty (Author_2)
                  then
                    -- translators: %s: Plugin author.
                    " <cite>" & Sprintf (abs "By %s", [Author_2]) & "</cite>"
                  else Author_2);

               Requires_PHP : constant String :=
                 (if Isset (Plugin, "requires_php")
                  then Get_As_String (Plugin, "requires_php")
                  else ""); -- null

               Requires_WP : constant String :=
                 (if Isset (Plugin, "requires")
                  then Get_As_String (Plugin, "requires")
                  else ""); -- null

               Compatible_PHP : constant Boolean :=
                 Is_PHP_Version_Compatible (Requires_PHP);
               Compatible_WP  : constant Boolean :=
                 Is_WP_Version_Compatible (Requires_WP);

               Tested_WP : constant Boolean :=
                 (Empty (Plugin, "tested")
                  or else Version_Compare
                            (Get_Bloginfo ("version"),
                             Get_As_String (Plugin, "tested"),
                             "<="));

               Action_Links : List_Type;

               Details_Link : constant String :=
                 Self_Admin_URL
                   ("plugin-install.php?tab=plugin-information&amp;plugin="
                    & Get_As_String (Plugin, "slug")
                    & "&amp;TB_iframe=true&amp;width=600&amp;height=550");

               Plugin_Icon_URL : UString;
            begin
               Action_Links.Append
                 (Wp_Get_Plugin_Action_Button
                    (Name, Plugin, Compatible_PHP, Compatible_WP));

               Action_Links.Append
                 (Sprintf
                    ("<a href=""%s"" class=""thickbox open-plugin-details-modal"" aria-label=""%s"" data-title=""%s"">%s</a>",
                     [1 => ESC_URL (Details_Link),
                      -- translators: %s: Plugin name and version.
                      2 =>
                        ESC_Attr
                          (Sprintf (abs "More information about %s", [Name])),
                      3 => ESC_Attr (Name),
                      4 => abs "More Details"]));

               if not Empty (As_String (Get (Ref_2 (Plugin, "icons", "svg"))))
               then
                  Plugin_Icon_URL :=
                    +As_String (Get (Ref_2 (Plugin, "icons", "svg")));
               elsif not Empty
                           (As_String (Get (Ref_2 (Plugin, "icons", "2x"))))
               then
                  Plugin_Icon_URL :=
                    +As_String (Get (Ref_2 (Plugin, "icons", "2x")));
               elsif not Empty
                           (As_String (Get (Ref_2 (Plugin, "icons", "1x"))))
               then
                  Plugin_Icon_URL :=
                    +As_String (Get (Ref_2 (Plugin, "icons", "1x")));
               else
                  Plugin_Icon_URL :=
                    +As_String (Get (Ref_2 (Plugin, "icons", "default")));
               end if;

               --
               -- Filters the install action links for a plugin.
               --
               -- @since 2.7.0
               --
               -- @param string[] action_links An array of plugin action links.
               --                               Defaults are links to Details and Install Now.
               -- @param array    plugin       An array of plugin data. See then@see plugins_api()end;
               --                               for the list of possible values.
               --
               Action_Links :=
                 Apply_Filters
                   ("plugin_install_action_links", Action_Links, Plugin);

               declare
                  Last_Updated_Timestamp : constant Integer :=
                    Strtotime (Get_As_String (Plugin, "last_updated"));
               begin
                  Echo
                    ("<div class=""plugin-card plugin-card-"
                     & Sanitize_HTML_Class (Get_As_String (Plugin, "slug"))
                     & ">");

                  if not Compatible_PHP or else not Compatible_WP then
                     declare
                        Incompatible_Notice_Message : UString;
                     begin
                        if not Compatible_PHP and then not Compatible_WP then
                           Append
                             (Incompatible_Notice_Message,
                              abs "This plugin does not work with your versions of WordPress and PHP.");

                           if Current_User_Can ("update_core")
                             and then Current_User_Can ("update_php")
                           then
                              Append
                                (Incompatible_Notice_Message,
                                 Sprintf
                                   (
                                    -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
                                    " "
                                    & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
                                    [1 => Self_Admin_URL ("update-core.php"),
                                     2 => ESC_URL (Wp_Get_Update_PHP_URL)]));
                              Append
                                (Incompatible_Notice_Message,
                                 Wp_Update_PHP_Annotation
                                   ("</p><p><em>", "</em>", False));

                           elsif Current_User_Can ("update_core") then
                              Append
                                (Incompatible_Notice_Message,
                                 Sprintf
                                   (
                                    -- translators: %s: URL to WordPress Updates screen.
                                    " "
                                    & abs "<a href=""%s"">Please update WordPress</a>.",
                                    [Self_Admin_URL ("update-core.php")]));

                           elsif Current_User_Can ("update_php") then
                              Append
                                (Incompatible_Notice_Message,
                                 Sprintf
                                   (
                                    -- translators: %s: URL to Update PHP page.
                                    " "
                                    & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                                    [ESC_URL (Wp_Get_Update_PHP_URL)]));
                              Append
                                (Incompatible_Notice_Message,
                                 Wp_Update_PHP_Annotation
                                   ("</p><p><em>", "</em>", False));
                           end if;

                        elsif not Compatible_WP then
                           Append
                             (Incompatible_Notice_Message,
                              abs "This plugin does not work with your version of WordPress.");
                           if Current_User_Can ("update_core") then
                              Append
                                (Incompatible_Notice_Message,
                                 Sprintf
                                   (
                                    -- translators: %s: URL to WordPress Updates screen.
                                    " "
                                    & abs "<a href=""%s"">Please update WordPress</a>.",
                                    [Self_Admin_URL ("update-core.php")]));
                           end if;

                        elsif not Compatible_PHP then
                           Append
                             (Incompatible_Notice_Message,
                              abs "This plugin does not work with your version of PHP.");
                           if Current_User_Can ("update_php") then
                              Append
                                (Incompatible_Notice_Message,
                                 Sprintf
                                   (
                                    -- translators: %s: URL to Update PHP page.
                                    " "
                                    & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                                    [ESC_URL (Wp_Get_Update_PHP_URL)]));
                              Append
                                (Incompatible_Notice_Message,
                                 Wp_Update_PHP_Annotation
                                   ("</p><p><em>", "</em>", False));
                           end if;
                        end if;

                        Wp_Admin_Notice
                          (-Incompatible_Notice_Message,
                           To_Array_Type
                             ([Build ("type", "error"),
                               Build
                                 ("additional_classes",
                                  List_Type'["notice-alt", "inline"])]));
                     end;
                  end if;

                  Echo ("<div class=""plugin-card-top"">");
                  Echo ("        <div class=""name column-name"">");
                  Echo ("                <h3>");
                  Echo
                    ("                        <a href="""
                     & ESC_URL (Details_Link)
                     & """ class=""thickbox open-plugin-details-modal"">");
                  Echo (Title);
                  Echo
                    ("                        <img src="""
                     & ESC_URL (-Plugin_Icon_URL)
                     & """ class=""plugin-icon"" alt="""" />");
                  Echo ("                        </a>");
                  Echo ("                </h3>");
                  Echo ("        </div>");
                  Echo ("        <div class=""action-links"">");

                  if not Action_Links.Is_Empty then
                     Echo
                       ("<ul class=""plugin-action-buttons""><li>"
                        & Implode ("</li><li>", Action_Links)
                        & "</li></ul>");
                  end if;

                  Echo ("        </div>");
                  Echo ("        <div class=""desc column-description"">");
                  Echo ("                <p>" & Description & "</p>");
                  Echo
                    ("                <p class=""authors"">"
                     & Author
                     & "</p>");
                  Echo ("        </div>");
                  Echo ("</div>");

                  declare
                     Dependencies_Notice : constant String :=
                       This.Get_Dependencies_Notice (Plugin);
                  begin
                     if not Empty (Dependencies_Notice) then
                        Echo (Dependencies_Notice);
                     end if;
                  end;

                  Echo ("<div class=""plugin-card-bottom"">");
                  Echo ("        <div class=""vers column-rating"">");

                  Wp_Star_Rating
                    (To_Array_Type
                       ([Build ("rating", As_Integer (Get (Plugin, "rating"))),
                         Build ("type", "percent"),
                         Build
                           ("number",
                            As_Integer (Get (Plugin, "num_ratings")))]));

                  Echo
                    ("                <span class=""num-ratings"" aria-hidden=""true"">("
                     & Number_Format_I18n
                         (Float (As_Integer (Get (Plugin, "num_ratings"))))
                     & ")</span>");
                  Echo ("        </div>");
                  Echo ("        <div class=""column-updated"">");
                  Echo ("                <strong>");
                  X_E ("Last Updated:");
                  Echo ("</strong>");

                  -- translators: %s: Human-readable time difference.
                  Printf
                    (abs "%s ago", [Human_Time_Diff (Last_Updated_Timestamp)]);

                  Echo ("        </div>");
               end;

               Echo ("        <div class=""column-downloaded"">");
               declare
                  Active_Installs_Text : UString;
               begin
                  if As_Integer (Get (Plugin, "active_installs")) >= 1_000_000
                  then
                     declare
                        Active_Installs_Millions : constant Natural :=
                          Natural
                            (Float'Floor
                               (Float
                                  (As_Integer
                                     (Get (Plugin, "active_installs")))
                                / 1_000_000.0));
                     begin
                        Active_Installs_Text :=
                          +Sprintf
                             (
                              -- translators: %s: Number of millions.
                              X_Nx
                                ("%s+ Million",
                                 "%s+ Million",
                                 Helpers.Image (Active_Installs_Millions),
                                 "Active plugin installations"),
                              [Number_Format_I18n
                                 (Float (Active_Installs_Millions))]);
                     end;

                  elsif 0 = As_Integer (Get (Plugin, "active_installs")) then
                     Active_Installs_Text :=
                       +X_X ("Less Than 10", "Active plugin installations");

                  else
                     Active_Installs_Text :=
                       +Number_Format_I18n
                          (Float (As_Integer (Get (Plugin, "active_installs"))))
                       & "+";
                  end if;

                  -- translators: %s: Number of installations.
                  Printf (abs "%s Active Installations", [-Active_Installs_Text]);

                  Echo ("        </div>");
               end;

               Echo ("        <div class=""column-compatibility"">");

               if not Tested_WP then
                  Echo
                    ("<span class=""compatibility-untested"">"
                     & abs "Untested with your version of WordPress"
                     & "</span>");
               elsif not Compatible_WP then
                  Echo
                    ("<span class=""compatibility-incompatible"">"
                     & abs "<strong>Incompatible</strong> with your version of WordPress"
                     & "</span>");
               else
                  Echo
                    ("<span class=""compatibility-compatible"">"
                     & abs "<strong>Compatible</strong> with your version of WordPress"
                     & "</span>");
               end if;

               Echo ("        </div>");
               Echo ("</div>");
               Echo ("</div>");
            end;
         end;
      end loop;

      -- Close off the group divs of the last one.
      if not Empty (Group) then
         Echo ("</div></div>");
      end if;
   end Display_Rows;

   -----------------------------
   -- Get_Dependencies_Notice --
   -----------------------------

   function Get_Dependencies_Notice
     (This : Wp_Plugin_Install_List_Table; Plugin_Data : Array_Type)
      return String
   is
      use Php.Strings;
      use UStrings;
      use Adi_Plugin_Install;
      use Inc_Formatting;
      use Inc_L10n;
   begin
      if Empty (Plugin_Data, "requires_plugins") then
         return "";
      end if;

      declare
         No_Name_Markup : constant String :=
           "<div class=""plugin-dependency""><span class=""plugin-dependency-name"">%s</span></div>";

         Has_Name_Markup : constant String :=
           "<div class=""plugin-dependency""><span class=""plugin-dependency-name"">%s</span> %s</div>";

         Dependencies_List : UString; --  = "";
      begin
         for A in As_Array (Get (Plugin_Data, "requires_plugins")).Iterate loop
            declare
               Dependency      : constant String := Key (A);
               Dependency_Data : constant Array_Type :=
                 Class_Plugin_Dependencies.Get_Dependency_Data (Dependency);
            begin
               if not Dependency_Data.Is_Empty -- false
                 and then not Empty (Get_As_String (Dependency_Data, "name"))
                 and then not Empty (Get_As_String (Dependency_Data, "slug"))
                 and then not Empty
                                (Get_As_String (Dependency_Data, "version"))
               then
                  declare
                     More_Details_Link : constant String :=
                       This.Get_More_Details_Link
                         (Get_As_String (Dependency_Data, "name"),
                          Get_As_String (Dependency_Data, "slug"));
                  begin
                     Append
                       (Dependencies_List,
                        Sprintf
                          (Has_Name_Markup,
                           [1 =>
                              ESC_HTML
                                (Get_As_String (Dependency_Data, "name")),
                            2 => More_Details_Link]));
                  end;
                  goto Continue;
               end if;

               declare
                  Result : constant Plugin_API_Result :=
                    Plugins_API
                      ("plugin_information",
                       (Null_Plugin_API_Args with delta Slug => +Dependency));
               begin
                  if not Empty (Result.Name) then
                     declare
                        More_Details_Link : constant String :=
                          This.Get_More_Details_Link
                            (-Result.Name, -Result.Slug);
                     begin
                        Append
                          (Dependencies_List,
                           Sprintf
                             (Has_Name_Markup,
                              [1 => ESC_HTML (-Result.Name),
                               2 => More_Details_Link]));
                     end;
                     goto Continue;
                  end if;

                  Append
                    (Dependencies_List,
                     Sprintf (No_Name_Markup, [ESC_HTML (Dependency)]));
               end;
            end;
            <<Continue>>
         end loop;

         declare
            Dependencies_Notice : constant String :=
              Sprintf
                ("<div class=""plugin-dependencies notice notice-alt notice-info inline""><p class=""plugin-dependencies-explainer-text"">%s</p> %s</div>",
                 [1 =>
                    "<strong>"
                    & abs "Additional plugins are required"
                    & "</strong>",
                  2 => -Dependencies_List]);
         begin
            return Dependencies_Notice;
         end;
      end;
   end Get_Dependencies_Notice;

   ---------------------------
   -- Get_More_Details_Link --
   ---------------------------

   function Get_More_Details_Link
     (This : Wp_Plugin_Install_List_Table; Name : String; Slug : String)
      return String
   is
      use Php.Strings;
      use Array_Lists;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;

      URL : constant String :=
        Add_Query_Arg
          (To_Array_Type
             ([Build ("tab", "plugin-information"),
               Build ("plugin", Slug),
               Build ("TB_iframe", "true"),
               Build ("width", "600"),
               Build ("height", "550")]),
           Network_Admin_URL ("plugin-install.php"));

      More_Details_Link : constant String :=
        Sprintf
          ("<a href=""%1s"" class=""more-details-link thickbox open-plugin-details-modal"" aria-label=""%2s"" data-title=""%3s"">%4s</a>",
           [1 => ESC_URL (URL),
            -- translators: %s: Plugin name.
            2 => Sprintf (abs "More information about %s", [ESC_HTML (Name)]),
            3 => ESC_Attr (Name),
            4 => abs "More Details"]);
   begin
      return More_Details_Link;
   end Get_More_Details_Link;

end Class_Plugin_Install_List_Tables;
