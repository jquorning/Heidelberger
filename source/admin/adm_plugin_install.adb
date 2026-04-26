--
-- Install plugin administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;
with Php.Errors;
with Php.Strings;

with Arrays;
with Array_Lists;
with Binder;
with Constants;
with Globals;
with Helpers;
with UStrings;
with Wp_Common;

with Adi_Files;
with Adi_List_Tables;
with Adi_Screens;
with Adi_Update;

with Adm_Admin;
with Adm_Admin_Footer;
with Adm_Admin_Header;

with Class_List_Tables;
with Class_Plugin_Dependencies;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_General_Templates;
with Inc_Load;
with Inc_Link_Templates;
with Inc_L10n;
with Inc_Pluggables;

package body Adm_Plugin_Install is
   use Arrays;

   ------------
   -- Render --
   ------------

   procedure Render is
      use Php.Echoing;
      use Php.Errors;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Adi_Files;
      use Adi_List_Tables;
      use Adi_Screens;
      use Adi_Update;
      use Class_List_Tables;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_General_Templates;
      use Inc_Load;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Pluggables;

      Tab : constant String := -Globals.Global_Tab;
   begin

      -- TODO: Route this page via a specific iframe handler instead of the do_action below.
      if not Constants.IFRAME_REQUEST -- Defined ("IFRAME_REQUEST")
        and then Isset (XX_GET, "tab")
        and then ("plugin-information" = Get_As_String (XX_GET, "tab"))
      then
         Constants.IFRAME_REQUEST := True;
      -- Define ("IFRAME_REQUEST", True);

      end if;

      --
      -- WordPress Administration Bootstrap.
      --
      Adm_Admin.Run;

      if not Current_User_Can ("install_plugins") then
         Wp_Die
           (abs "Sorry, you are not allowed to install plugins on this site.");
      end if;

      if Is_Multisite and then not Is_Network_Admin then
         Wp_Redirect (Network_Admin_URL ("plugin-install.php"));
         Die; -- exit;

      end if;

      declare
         Table : Wp_List_Table'Class :=
           X_Get_List_Table ("WP_Plugin_Install_List_Table");

         Pagenum : constant Natural := Table.Get_Pagenum;
      begin
         if not Empty (X_REQUEST, "_wp_http_referer") then
            declare
               Location_2 : constant String :=
                 Remove_Query_Arg
                   ("_wp_http_referer",
                    Wp_Unslash (Get_As_String (X_SERVER, "REQUEST_URI")));

               Location : constant String :=
                 (if not Empty (X_REQUEST, "paged")
                  then
                    Add_Query_Arg
                      ("paged",
                       Helpers.Image (As_Integer (Get (X_REQUEST, "paged"))),
                       Location_2)
                  else Location_2);
            begin
               Wp_Redirect (Location);
            end;
            Die; -- exit;

         end if;

         Table.Prepare_Items;

         declare
            Total_Pages : constant Natural :=
              Table.Get_Pagination_Arg ("total_pages");
         begin
            if Pagenum > Total_Pages and then Total_Pages > 0 then
               Wp_Redirect (Add_Query_Arg (Build ("paged", Total_Pages)));
               Die; -- exit;

            end if;
         end;

         -- Used in the HTML title tag.
         Globals.Global_Title := +abs "Add Plugins";
         Globals.Global_Parent_File := +"plugins.php";

         Wp_Enqueue_Script ("plugin-install");

         if "plugin-information" /= Tab then
            Add_Thickbox;
         end if;

         declare
            Body_Id : constant String := Tab;
            pragma Unreferenced (Body_Id);
         begin
            null;
         end;

         Wp_Enqueue_Script ("updates");

         --
         -- Fires before each tab on the Install Plugins screen is loaded.
         --
         -- The dynamic portion of the hook name, `tab`, allows for targeting
         -- individual tabs.
         --
         -- Possible hook names include:
         --
         --  - `install_plugins_pre_beta`
         --  - `install_plugins_pre_favorites`
         --  - `install_plugins_pre_featured`
         --  - `install_plugins_pre_plugin-information`
         --  - `install_plugins_pre_popular`
         --  - `install_plugins_pre_recommended`
         --  - `install_plugins_pre_search`
         --  - `install_plugins_pre_upload`
         --
         -- @since 2.7.0
         --
         Do_Action ("install_plugins_pre_" & Tab);

         --
         -- Call the pre upload action on every non-upload plugin installation screen
         -- because the form is always displayed on these screens.
         --
         if "upload" /= Tab then
            -- This action is documented in wp-admin/plugin-install.php--
            Do_Action ("install_plugins_pre_upload");
         end if;

         Get_Current_Screen.Add_Help_Tab
           (To_Array_Type
              ([Build ("id", "overview"),
                Build ("title", abs "Overview"),
                Build
                  ("content",
                   "<p>"
                   & Sprintf
                       (
                        -- translators: %s: https://wordpress.org/plugins/
                        abs "Plugins hook into WordPress to extend its functionality with custom features. Plugins are developed independently from the core WordPress application by thousands of developers all over the world. All plugins in the official <a href=""%s"">WordPress Plugin Directory</a> are compatible with the license WordPress uses.",
                        [abs "https://wordpress.org/plugins/"])
                   & "</p>"
                   & "<p>"
                   & abs "You can find new plugins to install by searching or browsing the directory right here in your own Plugins section."
                   & " <span id=""live-search-desc"" class=""hide-if-no-js"">"
                   & abs "The search results will be updated as you type."
                   & "</span></p>"

                  )]));
         Get_Current_Screen.Add_Help_Tab
           (To_Array_Type
              ([Build ("id", "adding-plugins"),
                Build ("title", abs "Adding Plugins"),
                Build
                  ("content",
                   "<p>"
                   & abs "If you know what you are looking for, Search is your best bet. The Search screen has options to search the WordPress Plugin Directory for a particular Term, Author, or Tag. You can also search the directory by selecting popular tags. Tags in larger type mean more plugins have been labeled with that tag."
                   & "</p>"
                   & "<p>"
                   & abs "If you just want to get an idea of what&#8217;s available, you can browse Featured and Popular plugins by using the links above the plugins list. These sections rotate regularly."
                   & "</p>"
                   & "<p>"
                   & abs "You can also browse a user&#8217;s favorite plugins, by using the Favorites link above the plugins list and entering their WordPress.org username."
                   & "</p>"
                   & "<p>"
                   & abs "If you want to install a plugin that you&#8217;ve downloaded elsewhere, click the Upload Plugin button above the plugins list. You will be prompted to upload the .zip package, and once uploaded, you can activate the new plugin."
                   & "</p>")]));

         Get_Current_Screen.Set_Help_Sidebar
           ("<p><strong>"
            & abs "For more information:"
            & "</strong></p>"
            & "<p>"
            & abs "<a href=""https://wordpress.org/documentation/article/plugins-add-new-screen/"">Documentation on Installing Plugins</a>"
            & "</p>"
            & "<p>"
            & abs "<a href=""https://wordpress.org/support/forums/"">Support forums</a>"
            & "</p>");

         Get_Current_Screen.Set_Screen_Reader_Content
           (To_Array_Type
              ([Build ("heading_views", abs "Filter plugins list"),
                Build ("heading_pagination", abs "Plugins list navigation"),
                Build ("heading_list", abs "Plugins list")]));

         --
         -- WordPress Administration Template Header.
         --
         Adm_Admin_Header.Run;

         Class_Plugin_Dependencies.Initialize;
         Class_Plugin_Dependencies.Display_Admin_Notice_For_Unmet_Dependencies;
         Class_Plugin_Dependencies.Display_Admin_Notice_For_Circular_Dependencies;

         Echo
           ("<div class=""wrap " & ESC_Attr ("plugin-install-tab-tab") & """>" & NL);

         Echo ("<h1 class=""wp-heading-inline"">" & NL);
         Echo (ESC_HTML (-Globals.Global_Title));
         Echo ("</h1>" & NL);

         if not Empty (Globals.Global_Tabs, "upload")
           and then Current_User_Can ("upload_plugins")
         then
            Printf
              (" <a href=""%s"" class=""upload-view-toggle page-title-action""><span class=""upload"">%s</span><span class=""browse"">%s</span></a>",
               [1 =>
                  (if "upload" = Tab
                   then Self_Admin_URL ("plugin-install.php")
                   else Self_Admin_URL ("plugin-install.php?tab=upload")),
                2 => abs "Upload Plugin",
                3 => abs "Browse Plugins"]);
         end if;

         Echo ("<hr class=""wp-header-end"">" & NL);

         --
         -- Output the upload plugin form on every non-upload plugin installation screen, so it can be
         -- displayed via JavaScript rather then opening up the devoted upload plugin page.
         --
         if "upload" /= Tab then

            Echo (TAB1 & "<div class=""upload-plugin-wrap"">" & NL);

            -- This action is documented in wp-admin/plugin-install.php
            Do_Action ("install_plugins_upload");

            Echo (TAB1 & "</div>" & NL);

            Table.Views;
         end if;
      end;

      --
      -- Fires after the plugins list table in each tab of the Install Plugins screen.
      --
      -- The dynamic portion of the hook name, `tab`, allows for targeting
      -- individual tabs.
      --
      -- Possible hook names include:
      --
      --  - `install_plugins_beta`
      --  - `install_plugins_favorites`
      --  - `install_plugins_featured`
      --  - `install_plugins_plugin-information`
      --  - `install_plugins_popular`
      --  - `install_plugins_recommended`
      --  - `install_plugins_search`
      --  - `install_plugins_upload`
      --
      -- @since 2.7.0
      --
      -- @param int paged The current page number of the plugins list table.
      --
      Do_Action ("install_plugins_" & Tab, Globals.Global_Paged);

      Echo (TAB1 & "<span class=""spinner""></span>" & NL);
      Echo (TAB0 & "</div>" & NL);

      Wp_Print_Request_Filesystem_Credentials_Modal;
      Wp_Print_Admin_Notice_Templates;

      --
      -- WordPress Administration Template Footer.
      --
      Adm_Admin_Footer.Run;
   end Render;

end Adm_Plugin_Install;
