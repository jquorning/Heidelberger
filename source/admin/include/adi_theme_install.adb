--
-- WordPress Theme Installation Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;
with Php.Errors;

with Binder;
with UStrings;

with Adi_Templates;
with Adi_Themes;
with Adi_List_Tables;

-- with Class_List_Tables;
with Class_Theme_Install_List_Tables;

with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_Link_Templates;
with Inc_L10n;
-- with Inc_Options;

package body Adi_Theme_Install
is

   Global_Theme_List_Table :
     Class_Theme_Install_List_Tables.Wp_Theme_Install_List_Table;

   ---------------------------------
   -- Install_Themes_Feature_List --
   ---------------------------------

   -- function Install_Themes_Feature_List return Array_Type is
   --    use Adi_Themes;
   --    use Inc_Functions;
   --    use Inc_Options;
   -- begin
   --    X_Deprecated_Function
   --      ("__FUNCTION__", "3.1.0", "get_theme_feature_list()");
   --    declare
   --       Cache : constant Array_Type :=
   --         As_Array (Get_Transient ("wporg_theme_feature_list"));
   --    begin
   --       if Cache.Is_Empty then
   --          -- not
   --          Set_Transient
   --            ("wporg_theme_feature_list",
   --             From_Array (Empty_Array),
   --             3 * Constants.HOUR_IN_SECONDS);
   --       end if;

   --       if not Cache.Is_Empty then
   --          return Cache;
   --       end if;
   --    end;

   --    declare
   --       Feature_List : constant API_Result_Type :=
   --         Themes_API ("feature_list", Empty_Array);
   --    begin
   --       if not Feature_List.Success then
   --          return Empty_Array;
   --       end if;

   --       Set_Transient
   --         ("wporg_theme_feature_list",
   --          Feature_List.Themes,
   --          3 * Constants.HOUR_IN_SECONDS);

   --       return Feature_List.Themes;
   --    end;
   -- end Install_Themes_Feature_List;

   --
   -- Displays Search Form for searching themes.
   --
   -- @since 2.8.0
   --
   -- @param bool type_selector
   --
   procedure Install_Theme_Search_Form (Type_Selector : Boolean := True) is
      use Php.Echoing;
      use Binder;
      use Adi_Templates;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_L10n;

      Typ : String :=
        (if Isset (X_REQUEST, "type")
         then Wp_Unslash (Get_As_String (X_REQUEST, "type"))
         else "term");

      Term : String :=
        (if Isset (X_REQUEST, "s")
         then Wp_Unslash (Get_As_String (X_REQUEST, "s"))
         else ""); -- 1
   begin
      if not Type_Selector then
         Echo
           ("<p class=""install-help"">"
            & abs "Search for themes by keyword."
            & "</p>");
      end if;

      Echo ("<form id=""search-themes"" method=""get"">");
      Echo ("        <input type=""hidden"" name=""tab"" value=""search"" />");
      if Type_Selector then
         Echo
           ("        <label class=""screen-reader-text"" for=""typeselector"">");

         -- translators: Hidden accessibility text.
         X_E ("Type of search");

         Echo ("        </label>");
         Echo ("        <select name=""type"" id=""typeselector"">");
         Echo
           ("        <option value=""term"" " & Selected ("term", Typ) & ">");
         X_E ("Keyword");
         Echo ("</option>");
         Echo
           ("        <option value=""author"" "
            & Selected ("author", Typ)
            & ">");
         X_E ("Author");
         Echo ("</option>");
         Echo ("        <option value=""tag"" " & Selected ("tag", Typ) & ">");
         X_Ex ("Tag", "Theme Installer");
         Echo ("</option>");
         Echo ("        </select>");
         Echo ("        <label class=""screen-reader-text"" for=""s"">");

         if Typ = "term" then
            -- translators: Hidden accessibility text.
            X_E ("Search by keyword");

         elsif Typ = "author" then
            -- translators: Hidden accessibility text.
            X_E ("Search by author");

         elsif Typ = "tag" then
            -- translators: Hidden accessibility text.
            X_E ("Search by tag");

         end if;

         Echo ("        </label>");
      else
         Echo ("        <label class=""screen-reader-text"" for=""s"">");

         -- translators: Hidden accessibility text.
         X_E ("Search by keyword");

         Echo ("        </label>");
      end if;
      Echo
        ("        <input type=""search"" name=""s"" id=""s"" size=""30"" value="""
         & ESC_Attr (Term)
         & """ autofocus=""autofocus"" />");
      Echo ("        ");
      Submit_Button (abs "Search", "", "search", False);
      Echo ("</form>");
   end Install_Theme_Search_Form;

   --
   -- Displays tags filter for themes.
   --
   -- @since 2.8.0
   --
   procedure Install_Themes_Dashboard is
      use Php.Echoing;
      use Adi_Themes;
      use Adi_Templates;
      use Inc_Formatting;
      use Inc_L10n;
   begin
      Install_Theme_Search_Form (False);

      Echo ("<h4>");
      X_E ("Feature Filter");
      Echo ("</h4>");
      Echo ("<p class=""install-help"">");
      X_E ("Find a theme based on specific features.");
      Echo ("</p>");

      Echo ("<form method=""get"">");
      Echo ("        <input type=""hidden"" name=""tab"" value=""search"" />");
      declare
         Feature_List : constant Array_Type := Get_Theme_Feature_List;
      begin
         Echo ("<div class=""feature-filter"">");

         for A in Feature_List.Iterate loop
            declare
               Feature_Name_2 : constant String := Key (A);
               Features       : constant Array_Type := As_Array (Element (A));
               Feature_Name   : constant String := ESC_HTML (Feature_Name_2);
            begin
               Echo ("<div class=""feature-name"">" & Feature_Name & "</div>");

               Echo ("<ol class=""feature-group"">");
               for B in Features.Iterate loop
                  declare
                     Feature_2      : constant String := Key (B);
                     Feature_Name_2 : constant String :=
                       As_String (Element (B));
                     Feature_Name   : constant String :=
                       ESC_HTML (Feature_Name_2);
                     Feature        : constant String := ESC_Attr (Feature_2);
                  begin
                     Echo ("<li>");
                     Echo
                       ("        <input type=""checkbox"" name=""features[]"" id=""feature-id-"
                        & Feature
                        & """ value="""
                        & Feature
                        & """ />");
                     Echo
                       ("        <label for=""feature-id-"
                        & Feature
                        & """>"
                        & Feature_Name
                        & "</label>");
                     Echo ("</li>");
                  end;
               end loop;
               Echo ("</ol>");
               Echo ("<br class=""clear"" />");
            end;
         end loop;
      end;
      Echo ("</div>");
      Echo ("<br class=""clear"" />");
      Echo ("        ");
      Submit_Button (abs "Find Themes", "", "search");
      Echo ("</form>");
   end Install_Themes_Dashboard;

   --
   -- Displays a form to upload themes from zip files.
   --
   -- @since 2.8.0
   --
   procedure Install_Themes_Upload is
      use Php.Echoing;
      use Adi_Templates;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;
   begin
      Echo ("<p class=""install-help"">");
      X_E
        ("If you have a theme in a .zip format, you may install or update it by uploading it here.");
      Echo ("</p>");
      Echo
        ("<form method=""post"" enctype=""multipart/form-data"" class=""wp-upload-form"" action="""
         & ESC_URL (Self_Admin_URL ("update.php?action=upload-theme"))
         & """>");
      Wp_Nonce_Field ("theme-upload");
      Echo ("        <label class=""screen-reader-text"" for=""themezip"">");

      -- translators: Hidden accessibility text.
      X_E ("Theme zip file");

      Echo ("        </label>");
      Echo
        ("        <input type=""file"" id=""themezip"" name=""themezip"" accept="".zip"" />");
      Echo ("        ");
      Submit_Button
        (X_X ("Install Now", "theme"), "", "install-theme-submit", False);
      Echo ("</form>");
   end Install_Themes_Upload;

   --
   -- Prints a theme on the Install Themes pages.
   --
   -- @deprecated 3.4.0
   --
   -- @global WP_Theme_Install_List_Table wp_list_table
   --
   -- @param object theme
   --
   procedure Display_Theme (Theme : Object) is
      use Adi_List_Tables;
      -- use Class_List_Tables;
      use Class_Theme_Install_List_Tables;
      use Inc_Functions;
      -- global wp_list_table;

      List_Table : Wp_Theme_Install_List_Table renames Global_Theme_List_Table;
   begin
      X_Deprecated_Function ("__FUNCTION__", "3.4.0");
      -- if List_Table = Null_List_Table then
         -- if not Isset (List_Table) then
      List_Table :=
        Wp_Theme_Install_List_Table
          (X_Get_List_Table ("WP_Theme_Install_List_Table"));
      -- end if;
      List_Table.Prepare_Items;
      List_Table.Single_Row (Theme);
   end Display_Theme;

   --
   -- Displays theme content based on theme list.
   --
   -- @since 2.8.0
   --
   -- @global WP_Theme_Install_List_Table wp_list_table
   --
   procedure Display_Themes is
      use Adi_List_Tables;
      -- use Class_List_Tables;
      use Class_Theme_Install_List_Tables;
      -- global wp_list_table;

      List_Table : Wp_Theme_Install_List_Table renames Global_Theme_List_Table;
   begin
      -- if not Isset (List_Table) then
      List_Table :=
        Wp_Theme_Install_List_Table
          (X_Get_List_Table ("WP_Theme_Install_List_Table"));
      -- end if;
      List_Table.Prepare_Items;
      Display (List_Table);
      -- List_Table.Display;
   end Display_Themes;

   --
   -- Displays theme information in dialog box form.
   --
   -- @since 2.8.0
   --
   -- @global WP_Theme_Install_List_Table wp_list_table
   --
   procedure Install_Theme_Information is
      use Php.Errors;
      use Binder;
      use UStrings;
      use Adi_Themes;
      use Adi_Templates;
      use Adi_List_Tables;
      use Class_Theme_Install_List_Tables;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;

      -- global wp_list_table;
      List_Table : Wp_Theme_Install_List_Table renames Global_Theme_List_Table;

      Args : constant Themes_API_Args :=
        (Empty_Themes_API_Args
         with delta
           Slug => +String'(Wp_Unslash (Get_As_String (X_REQUEST, "theme"))));

      Theme : constant Themes_API_Result :=
        Themes_API ("theme_information", Args);
--           Build
--             ("slug",
--              String'(Wp_Unslash (Get_As_String (X_REQUEST, "theme")))));
   begin
      if not Theme.Success then
         Wp_Die (Theme.Error);
      end if;

      Iframe_Header (abs "Theme Installation");
      -- if not Isset (List_Table) then
      List_Table :=
        Wp_Theme_Install_List_Table
          (X_Get_List_Table ("WP_Theme_Install_List_Table"));
      -- end if;
      List_Table.Theme_Installer_Single (Theme.Themes.First_Element); -- Arry);
      Iframe_Footer;
      Die; -- exit;
   end Install_Theme_Information;

end Adi_Theme_Install;
