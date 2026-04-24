--
-- List Table API: WP_Themes_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Php.Arrays;
with Php.Echoing;
with Php.HTML;
with Php.Lists;
with Php.Strings;

with Array_Lists;
with Binder;
with Helpers;
with Wp_Common;

with Adi_Themes;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Themes;

package body Class_Theme_List_Tables is

   --
   -- Constructor.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table::__construct() for more information on default arguments.
   --
   -- @param array $args An associative array of arguments.
   --
   function X_Construct (Args : Array_Type) return Wp_Themes_List_Table is
      use Array_Lists;

      Screen : constant String :=
        (if Isset (Args, "screen")
         then Get_As_String (Args, "screen")
         else ""); -- null

      Result : constant Wp_Themes_List_Table :=
        Wp_Themes_List_Table'
          (X_Construct
             ( -- parent::
              To_Array_Type
                ([Build ("ajax", True), Build ("screen", Screen)])));
   begin
      return Result;
   end X_Construct;

   --
   -- @return bool
   --
   function Ajax_User_Can (This : Wp_Themes_List_Table) return Boolean is
      use Inc_Capabilities;
   begin
      -- Do not check edit_theme_options here. Ajax calls for available themes require switch_themes.
      return Current_User_Can ("switch_themes");
   end Ajax_User_Can;

   --
   --
   procedure Prepare_Items (This : in out Wp_Themes_List_Table) is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      -- use Array_Lists;
      use Binder;
      use Class_Themes;
      use Inc_Formatting;
      use Inc_Options;
      use Inc_Themes;

      Themes : Theme_Array := Wp_Get_Themes (Build ("allowed", True));
   begin
      if not Empty (X_REQUEST, "s") then
         This.Search_Terms :=
           List_Unique
             (Array_Filter
                (Array_Map
                   (Trim'Access,
                    Explode
                      (",",
                       Strtolower
                         (Wp_Unslash (Get_As_String (X_REQUEST, "s")))))));
      end if;

      if not Empty (X_REQUEST, "features") then
         This.Features := As_List (Get (X_REQUEST, "features"));
      end if;

      if not This.Search_Terms.Is_Empty or else not This.Features.Is_Empty then
         for A in Themes.Iterate loop
            declare
               Keyy  : constant String := Theme_Maps.Key (A);
               Theme : Wp_Theme := Theme_Maps.Element (A);
            begin
               if not This.Search_Theme (Theme) then
                  Themes.Delete (Keyy);
               end if;
            end;
         end loop;
      end if;

      Themes.Delete (Get_Option ("stylesheet"));

      Sort_By_Name (Themes); -- wp_theme::

      declare
         Per_Page : constant Natural := 36;
         Page     : constant Natural := This.Get_Pagenum;

         Start : constant Natural := (Page - 1) * Per_Page;
      begin
         -- This.Items := Array_Slice (Themes, Start, Per_Page, True); -- XXX

         null;

         -- XXX
         -- This.Set_Pagination_Args
         --   (To_Array_Type
         --      ([Build ("total_items", Count (Themes)),
         --        Build ("per_page", Per_Page),
         --        Build ("infinite_scroll", True)]));
      end;
   end Prepare_Items;

   --
   --
   procedure No_Items (This : Wp_Themes_List_Table) is
      use Php.Echoing;
      use Inc_Capabilities;
      use Inc_Load;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Options;
   begin
      if not This.Search_Terms.Is_Empty or else not This.Features.Is_Empty then
         X_E ("No items found.");
         return;
      end if;

      declare
         Blog_Id : constant String := Helpers.Image (Get_Current_Blog_Id);
      begin
         if Is_Multisite then
            if Current_User_Can ("install_themes")
              and then Current_User_Can ("manage_network_themes")
            then
               Printf
                 (
                  -- translators: 1: URL to Themes tab on Edit Site screen, 2: URL to Add Themes screen.
                  abs "You only have one theme enabled for this site right now. Visit the Network Admin to <a href=""%1s"">enable</a> or <a href=""%2s"">install</a> more themes.",
                  [1 => Network_Admin_URL ("site-themes.php?id=" & Blog_Id),
                   2 => Network_Admin_URL ("theme-install.php")]);

               return;
            elsif Current_User_Can ("manage_network_themes") then
               Printf
                 (
                  -- translators: %s: URL to Themes tab on Edit Site screen.
                  abs "You only have one theme enabled for this site right now. Visit the Network Admin to <a href=""%s"">enable</a> more themes.",
                  [Network_Admin_URL ("site-themes.php?id=" & Blog_Id)]);

               return;
            end if;
         -- Else, fallthrough. install_themes doesn"t help if you can"t enable it.

         else
            if Current_User_Can ("install_themes") then
               Printf
                 (
                  -- translators: %s: URL to Add Themes screen.
                  abs "You only have one theme installed right now. Live a little! You can choose from over 1,000 free themes in the WordPress Theme Directory at any time: just click on the <a href=""%s"">Install Themes</a> tab above.",
                  [Admin_URL ("theme-install.php")]);

               return;
            end if;
         end if;

         -- Fallthrough.
         Printf
           (
            -- translators: %s: Network title.
            abs "Only the active theme is available to you. Contact the %s administrator for information about accessing additional themes.",
            [As_String (Get_Site_Option ("site_name"))]);
      end;
   end No_Items;

   --
   -- @param string which
   --
   procedure Tablenav (This : in out Wp_Themes_List_Table; Which : String := "top") is
      use Php.Echoing;
   begin
      if This.Get_Pagination_Arg ("total_pages") <= 1 then
         return;
      end if;

      Echo ("                <div class=""tablenav themes " & Which & ">");
      This.Pagination (Which);
      Echo ("                        <span class=""spinner""></span>");
      Echo ("                        <br class=""clear"" />");
      Echo ("                </div>");
   end Tablenav;

   --
   -- Displays the themes table.
   --
   -- Overrides the parent display() method to provide a different container.
   --
   -- @since 3.1.0
   --
   procedure Display (This : in out Wp_Themes_List_Table) is
      use Php.Echoing;
      use Inc_Functions;
   begin
      Wp_Nonce_Field
        ("fetch-list-" & "XXX-D01", -- Get_Class (This),
         "_ajax_fetch_list_nonce");

      This.Tablenav ("top");

      Echo ("                <div id=""availablethemes"">");
      This.Display_Rows_Or_Placeholder;
      Echo ("                </div>");

      This.Tablenav ("bottom");

   end Display;

   --
   -- @return string[] Array of column titles keyed by their column name.
   --
   function Get_Columns (This : Wp_Themes_List_Table) return List_Type is
   begin
      return Empty_List;
   end Get_Columns;

   --
   --
   procedure Display_Rows_Or_Placeholder (This : in out Wp_Themes_List_Table) is
      use Php.Echoing;
   begin
      if This.Has_Items then
         This.Display_Rows;
      else
         Echo ("<div class=""no-items"">");
         This.No_Items;
         Echo ("</div>");
      end if;
   end Display_Rows_Or_Placeholder;

   --
   -- Generates the list table rows.
   --
   -- @since 3.1.0
   --
   procedure Display_Rows (This : in out Wp_Themes_List_Table) is
      use Php.Echoing;
      use Php.HTML;
      use Php.Strings;
      use Wp_Common;
      use Adi_Themes;
      use Class_Themes;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Themes;

      Themes : Theme_Array; -- := This.Items;
   begin

      for Theme of Themes loop

         Echo ("                        <div class=""available-theme"">");

         declare
            Template   : constant String := Theme.Get_Template;
            Stylesheet : constant String := Theme.Get_Stylesheet;
            Title      : constant String := Theme.Display ("Name");
            Version    : constant String := Theme.Display ("Version");
            Author     : constant String := Theme.Display ("Author");

            Activate_Link : constant String :=
              Wp_Nonce_URL
                ("themes.php?action=activate&amp;template="
                 & URL_Encode (Template)
                 & "&amp;stylesheet="
                 & URL_Encode (Stylesheet),
                 "switch-theme_" & Stylesheet);

            Actions : Array_Type;

            Label : constant String :=
                     ESC_Attr
                       (Sprintf
                          (X_X ("Activate &#8220;%s&#8221;", "theme"),
                           [Title]));
         begin
            Set
              (Actions,
               "activate",
               From_String
                 (Sprintf
                    ("<a href=""%s"" class=""activatelink"" aria-label=""%s"">%s</a>",
                     [1 => Activate_Link,
                      -- translators: %s: Theme name.
                      2 => Label,
                      3 => X_X ("Activate", "theme")])));

            if Current_User_Can ("edit_theme_options")
              and then Current_User_Can ("customize")
            then
               Set
                 (Actions,
                  "preview",
                  From_String
                    (Get_As_String (Actions, "preview")
                     & Sprintf
                         ("<a href=""%s"" class=""load-customize hide-if-no-customize"">%s</a>",
                          [1 => Wp_Customize_URL (Stylesheet),
                           2 => abs "Live Preview"])));
            end if;

            if not Is_Multisite and then Current_User_Can ("delete_themes")
            then
               Set
                 (Actions,
                  "delete",
                  From_String
                    (Sprintf
                       ("<a class=""submitdelete deletion"" href=""%s"" onclick=""return confirm( \""%s\"" );"">%s</a>",
                        [1 =>
                           Wp_Nonce_URL
                             ("themes.php?action=delete&amp;stylesheet="
                              & URL_Encode (Stylesheet),
                              "delete-theme_" & Stylesheet),
                         -- translators: %s: Theme name.
                         2 =>
                           ESC_JS
                             (Sprintf
                                (abs "You are about to delete this theme ""%s""\n  ""Cancel"" to stop, ""OK"" to delete.",
                                 [Title])),
                         3 => abs "Delete"])));
            end if;

            -- This filter is documented in wp-admin/includes/class-wp-ms-themes-list-table.php
            Actions :=
              Apply_Filters ("theme_action_links", Actions, Theme, "all");

            -- This filter is documented in wp-admin/includes/class-wp-ms-themes-list-table.php
            Actions :=
              Apply_Filters
                ("theme_action_links_" & Stylesheet, Actions, Theme, "all");

            declare
               Delete_Action : String :=
                 (if Isset (Actions, "delete")
                  then
                    "<div class=""delete-theme"">"
                    & Get_As_String (Actions, "delete")
                    & "</div>"
                  else "");

               Screenshot : constant String := Theme.Get_Screenshot;
            begin
               Delete (Actions, "delete");

               Echo
                 ("                        <span class=""screenshot hide-if-customize"">");
               if Screenshot /= "" then
                  Echo
                    ("                                        <img src="""
                     & ESC_URL
                         (Screenshot
                          & "?ver="
                          & "XXX-D02" -- Theme.Version
                          & """ alt="""" />"));
               end if;
               Echo ("                        </span>");
               Echo
                 ("                        <a href="""
                  & Wp_Customize_URL (Stylesheet)
                  & """ class=""screenshot load-customize hide-if-no-customize"">");
               if Screenshot /= "" then
                  Echo
                    ("                                        <img src="""
                     & ESC_URL (Screenshot & "?ver=" & "XXX-D03") -- Theme.Version)
                     & """ alt="""" />");
               end if;
               Echo ("                        </a>");

               Echo ("                        <h3>" & Title & "</h3>");
               Echo ("                        <div class=""theme-author"">");

               -- translators: %s: Theme author.
               Printf (abs "By %s", [Author]);

               Echo ("                        </div>");
               Echo ("                        <div class=""action-links"">");
               Echo ("                                <ul>");
               for Action in Actions.Iterate loop
                  Echo
                    ("                                                <li>"
                     & Key (Action) -- key added
                     & "</li>");
               end loop;
               Echo
                 ("                                        <li class=""hide-if-no-js""><a href=""#"" class=""theme-detail"">");
               X_E ("Details");
               Echo ("</a></li>");
               Echo ("                                </ul>");
               Echo (Delete_Action);

               Theme_Update_Available (Theme);
               Echo ("                        </div>");
            end;

            Echo
              ("                        <div class=""themedetaildiv hide-if-js"">");
            Echo ("                                <p><strong>");
            X_E ("Version:");
            Echo ("</strong> " & Version & "</p>");
            Echo
              ("                                <p>"
               & Theme.Display ("Description")
               & "</p>");

            declare
               Parent : Wp_Theme := Theme.Parent;
            begin
               if Parent /= Null_Theme then
                  Printf
                    (
                     -- translators: 1: Link to documentation on child themes, 2: Name of parent theme.
                     " <p class=""howto"">"
                     & abs "This <a href=""%1s"">child theme</a> requires its parent theme, %2s."
                     & "</p>",
                     [1 =>
                        abs "https://developer.wordpress.org/themes/advanced-topics/child-themes/",
                      2 => Parent.Display ("Name")]);
               end if;
            end;

            Echo ("                        </div>");
            Echo ("                        </div>");
         end;
      end loop;
   end Display_Rows;

   --
   -- @param WP_Theme theme
   -- @return bool
   --
   function Search_Theme
     (This : Wp_Themes_List_Table; Theme : in out Class_Themes.Wp_Theme)
      return Boolean
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
   begin
      -- Search the features.
      for Word of This.Features loop
         if not In_List (Word, As_List (Theme.Get ("Tags")), True) then
            return False;
         end if;
      end loop;

      -- Match all phrases.
      for Word of This.Search_Terms loop
         if In_List (Word, As_List (Theme.Get ("Tags")), True) then
            goto Continue;
         end if;

         for Header of List_Type'["Name", "Description", "Author", "AuthorURI"]
         loop
            -- Don't mark up; Do translate.
            if 0 -- False
              /= Stripos
                   (Strip_Tags (Theme.Display (Header, False, True)), Word)
            then
               goto Continue;
            end if;
         end loop;

         if 0 /= Stripos (Theme.Get_Stylesheet, Word) then
            -- false
            goto Continue;
         end if;

         if 0 /= Stripos (Theme.Get_Template, Word) then
            -- false
            goto Continue;
         end if;

         return False;
         <<Continue>>
      end loop;

      return True;
   end Search_Theme;

   --
   -- Send required variables to JavaScript land
   --
   -- @since 3.4.0
   --
   -- @param array extra_args
   --
   procedure X_JS_Vars (This : Wp_Themes_List_Table; Extra_Args : Array_Type)
   is
      use Php.Arrays;
      use Php.Echoing;
      use Array_Lists;
      use Binder;
      use Class_List_Tables;
      use Inc_Formatting;
      use Inc_Functions;

      Search_String : constant String :=
        (if Isset (X_REQUEST, "s")
         then ESC_Attr (Wp_Unslash (Get_As_String (X_REQUEST, "s")))
         else "");

      Total_Pages : constant Integer :=
        (if not Empty (This.X_Pagination_Args, "total_pages")
         then As_Integer (Get (This.X_Pagination_Args, "total_pages"))
         else 1);

      Args : constant Array_Type :=
        To_Array_Type
          ([Build ("search", Search_String),
            Build ("features", This.Features),
            Build ("paged", This.Get_Pagenum),
            Build ("total_pages", Total_Pages)]);

      Args_2 : constant Array_Type := Array_Merge (Args, Extra_Args);
   begin
      -- if Is_Array (Extra_Args) then
      -- end if;

      Printf
        ("<script type=""text/javascript"">var theme_list_args = %s;</script>\n",
         [Wp_JSON_Encode (From_Array (Args_2))]);

   -- X_JS_Vars (Wp_List_Table (This)); -- parent:: XXX
   end X_JS_Vars;

end Class_Theme_List_Tables;
