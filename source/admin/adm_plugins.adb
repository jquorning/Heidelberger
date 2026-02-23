--
-- Plugins administration panel.
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
with Php.Misc;
with Php.Strings;

with Arrays;
with Array_Lists;
with Binder;
with Constants;
with Globals;
with Helpers;
with Lists;
with UStrings;

with Adm_Admin;
with Adm_Admin_Footer;
with Adm_Admin_Header;

with Adi_Plugins;

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

package body Adm_Plugins
is
   use Arrays;
   use Lists;

   procedure Action_Activate (Plugin : String);
   procedure Action_Activate_Selected;
   procedure Action_Update_Selected;
   procedure Action_Error_Scrape (Plugin : String);
   procedure Action_Deactivate (Plugin : String);
   procedure Action_Deactivate_Selected;
   procedure Action_Delete_Selected;
   procedure Action_Clear_Recent_List;
   procedure Action_Resume;
   procedure Action_Auto_Update (Action : String);
   procedure Action_Default;

   -------------
   -- Action_ --
   -------------

   procedure Action_Activate (Plugin : String)
   is
      use Php.Errors;
      use Php.Files;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
   begin
      if not Current_User_Can ("activate_plugin", Plugin) then
         Wp_Die (abs "Sorry, you are not allowed to activate this plugin.");
      end if;

      if
        Is_Multisite and then
        not Is_Network_Admin and then
        Is_Network_Only_Plugin (Plugin)
      then
         Wp_Redirect (
           Self_Admin_Url ("plugins.php?plugin_status=status&paged=page&s=s"));
         Die; -- exit;
      end if;

      Check_Admin_Referer ("activate-plugin_" & Plugin);

      declare
         Result : constant Null_Error_Type :=
           Activate_Plugin (Plugin,
                            Self_Admin_Url ("plugins.php?error=true&plugin=" &
                                            Url_Encode (Plugin)),
                            Is_Network_Admin);
      begin
         if not Result.Success then
--       if Is_Wp_Error (Result) then
            if "unexpected_output" = Result.Error.Get_Error_Code then
               declare
                  Redirect : constant String :=
                    Self_Admin_URL (
                      "plugins.php?error=true&charsout=" &
                      Helpers.Image (Strlen (result.Error.Get_Error_Data)) &
                      "&plugin=" & Url_Encode (Plugin) &
                      "&plugin_status=status&paged=page&s=s");
               begin
                  Wp_Redirect (
                    Add_Query_Arg ("_error_nonce",
                                   Wp_Create_Nonce ("plugin-activation-error_" &
                                                    Plugin), Redirect));
               end;
               Die; -- exit;
            else
               Wp_Die (Result.Error);
            end if;
         end if;
      end;

      if not Is_Network_Admin then
         declare
            Recent : Array_Type :=
              Get_Option ("recently_activated");
         begin
            Delete (Ref (Recent, Plugin));
            update_option ("recently_activated", Recent);
         end;
      else
         declare
            Recent : Array_Type :=
              Get_Site_Option ("recently_activated");
         begin
            Delete (Ref (Recent, Plugin));
            Update_Site_Option ("recently_activated", Recent);
         end;
      end if;

      if
        isset (XX_GET, "from") and then
        "import" = Get_As_String (XX_GET, "from")
      then
         -- Overrides the ?error=true one above and redirects to the Imports page,
         -- stripping the -importer suffix.
         wp_redirect (
           self_admin_url ("import.php?import=" &
                           Str_Replace ("-importer", "", Dirname (plugin))));
      elsif
        isset (XX_GET, "from") and then
        "press-this" = Get_As_String (XX_GET, "from")
      then
         wp_redirect (self_admin_url ("press-this.php"));
      else
         -- Overrides the ?error=true one above.
         wp_redirect (self_admin_url ("plugins.php?activate=true&plugin_status=status&paged=page&s=s"));
      end if;
      Die; -- exit;
   end Action_Activate;

   -------------
   -- Action_ --
   -------------

   procedure Action_Activate_Selected
   is
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
   begin
      if not current_user_can ("activate_plugins") then
         wp_die (abs "Sorry, you are not allowed to activate plugins for this site.");
      end if;

      Check_Admin_Referer ("bulk-plugins");

      declare
         Plugins : List_Type :=
           (if isset (X_POST, "checked")
            then List_Type'(wp_unslash (Get_As_String (X_POST, "checked")))
            else Empty_List);
      begin

      if Is_Network_Admin then
         for A in Plugins.Iterate loop
            declare
               i : String := Key (A);
               Plugin : String := As_String (Element (A));
            begin
               -- Only activate plugins which are not already network activated.
               if Is_Plugin_Active_For_Network (Plugin) then
                  Delete (Ref (Plugins, I));
               end if;
            end;
         end loop;

      else
         for A in Plugins.Iterate loop
            declare
               I      : String := Key (A);
               Plugin : String := As_String (Element (A));
            begin
               -- Only activate plugins which are not already active and are not
               -- network-only when on Multisite.
               if
                 Is_Plugin_Active (Plugin) or else
                 (is_multisite and then is_network_only_plugin (plugin))
               then
                  Delete (Ref (Plugins, I));
               end if;

               -- Only activate plugins which the user can activate.
               if not current_user_can ("activate_plugin", plugin) then
                  Delete (Ref (Plugins, I));
               end if;

            end;
         end loop;
      end if;

      if empty (plugins) then
         wp_redirect (self_admin_url (
           "plugins.php?plugin_status=status&paged=page&s=s"));
         Die; -- exit;
      end if;

      Activate_Plugins (Plugins,
                        Self_Admin_URL ("plugins.php?error=true"),
                        Is_Network_Admin);

      declare
         Recent : List_Type :=
           (if not Is_Network_Admin
            then List_Type'(get_option ("recently_activated"))
            else List_Type'(get_site_option ("recently_activated")));
      begin
         for Plugin of Plugins loop
            Delete (Ref (Recent, Plugin));
         end loop;

         if not Is_Network_Admin then
            Update_Option ("recently_activated", Recent);
         else
            Update_Site_Option ("recently_activated", Recent);
         end if;
      end;
      end;

      wp_redirect (self_admin_url (
        "plugins.php?activate-multi=true&plugin_status=status&paged=page&s=s"));
      Die; -- exit;
   end Action_Activate_Selected;

   -------------
   -- Action_ --
   -------------

   procedure Action_Update_Selected
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      Check_Admin_Referer ("bulk-plugins");

      declare
         Plugins : constant List_Type :=
           (if isset (XX_GET, "plugins")
              then explode (",", wp_unslash (Get_As_String (XX_GET, "plugins")))
            elsif isset (X_POST, "checked")
              then List_Type'(Wp_Unslash (Get_As_String (X_POST, "checked")))
            else Empty_List);
      begin
         -- Used in the HTML title tag.
         Globals.Title              := +abs "Update Plugins";
         Globals.Global_Parent_File := +"plugins.php";

         Wp_Enqueue_Script ("updates");
         Adm_Admin_header.Run;

         Echo ("<div class=""wrap"">");
         Echo ("<h1>" & ESC_HTML (-Globals.Title) & "</h1>");

         declare
            URL_2 : constant String :=
              Self_Admin_URL ("update.php?action=update-selected&amp;plugins=" &
                              URL_Encode (implode (",", plugins)));

            URL : constant String := Wp_Nonce_URL (URL_2, "bulk-update-plugins");
         begin
            Echo (
              "<iframe src=""" & URL &
              """ style=""width: 100%; height:100%; min-height:850px;""></iframe>");
         end;
         Echo ("</div>");
      end;

      Adm_Admin_Footer.Run;

      Die; -- exit;
   end Action_Update_Selected;

   -------------
   -- Action_ --
   -------------

   procedure Action_Error_Scrape (Plugin : String)
   is
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      if not Current_User_Can ("activate_plugin", Plugin) then
         Wp_Die (abs "Sorry, you are not allowed to activate this plugin.");
      end if;

      Check_Admin_Referer ("plugin-activation-error_" & plugin);

      declare
         Valid : constant Bool_Error_Type := Validate_Plugin (Plugin);
      begin
         if not Valid.Success then
--       if Is_Wp_Error (Valid) then
            Wp_Die (Valid.Error);
         end if;
      end;

      if not Constants.WP_DEBUG then
         Error_Reporting (ERROR_ALL);
         -- E_CORE_ERROR or E_CORE_WARNING or E_COMPILE_ERROR or E_ERROR or E_WARNING or E_PARSE or E_USER_ERROR or E_USER_WARNING or E_RECOVERABLE_ERROR);
      end if;

      Ini_Set ("display_errors", True); -- Ensure that fatal errors are displayed.

      -- Go back to "sandbox" scope so we get the same errors as before.
      Plugin_Sandbox_Scrape (Plugin);

      -- This action is documented in wp-admin/includes/plugin.php
      Do_Action ("activate_" & Plugin);

      Die; -- exit;
   end Action_Error_Scrape;

   -------------
   -- Action_ --
   -------------

   procedure Action_Deactivate (Plugin : String)
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
   begin
      if not Current_User_Can ("deactivate_plugin", Plugin) then
         Wp_Die (abs "Sorry, you are not allowed to deactivate this plugin.");
      end if;

      Check_Admin_Referer ("deactivate-plugin_" & plugin);

      if not is_network_admin and then is_plugin_active_for_network (plugin) then
         wp_redirect (self_admin_url ("plugins.php?plugin_status=status&paged=page&s=s"));
         Die; -- exit;
      end if;

      Deactivate_Plugins ([Plugin], False, Is_Network_Admin);

      if not Is_Network_Admin then
         Update_Option ("recently_activated",
                        Build (Plugin, Php.Misc.Time) +
                        List_Type'(Get_Option ("recently_activated")));
      else
         Update_Site_Option ("recently_activated",
                             Build (Plugin, Php.Misc.Time) +
                             List_Type'(Get_Site_Option ("recently_activated")));
      end if;

      if Headers_Sent then
         Echo (
           "<meta http-equiv=""refresh"" content=""""" &
           ESC_Attr ("0;url=plugins.php?deactivate=true&plugin_status=status&paged=page&s=s") & """ />");
      else
         Wp_Redirect (Self_Admin_URL (
           "plugins.php?deactivate=true&plugin_status=status&paged=page&s=s"));
      end if;
      Die; -- exit;
   end Action_Deactivate;

   -------------
   -- Action_ --
   -------------

   procedure Action_Deactivate_Selected
   is
      use Php.Arrays;
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
   begin
      if not Current_User_Can ("deactivate_plugins") then
         Wp_Die (
           abs "Sorry, you are not allowed to deactivate plugins for this site.");
      end if;

      Check_Admin_Referer ("bulk-plugins");

      declare
         Plugins : List_Type :=
           (if isset (X_POST, "checked")
            then List_Type'(wp_unslash (Get_As_String (X_POST, "checked")))
            else Empty_List);
      begin
         -- Do not deactivate plugins which are already deactivated.
         if is_network_admin then
            Plugins := Array_Filter (Plugins,
                                     Is_Plugin_Active_For_Network'Access);
         else
            Plugins := Array_Filter (Plugins,
                                     Is_Plugin_Active'Access);

            Plugins := Array_Diff (Plugins,
                                   Array_Filter (Plugins,
                                                 Is_Plugin_Active_For_Network'Access));

            for A in Plugins.Iterate loop
               declare
                  I      : String := Key (A);
                  Plugin : String := As_String (Element (A));
               begin
                  -- Only deactivate plugins which the user can deactivate.
                  if not current_user_can ("deactivate_plugin", plugin) then
                     Delete (Ref (Plugins, I));
                  end if;
               end;
            end loop;
         end if;

         if empty (plugins) then
            Wp_Redirect (Self_Admin_URL (
              "plugins.php?plugin_status=status&paged=page&s=s"));
            Die; -- exit;
         end if;

         Deactivate_Plugins (Plugins, False, Is_Network_Admin);

         declare
            Deactivated : Array_Type;
         begin
            for Plugin of plugins loop
               Set (Deactivated, Plugin, From_Integer (Php.Misc.Time));
            end loop;

            if not Is_Network_Admin then
               Update_Option ("recently_activated",
                              deactivated +
                              List_Type'(get_option ("recently_activated")));
            else
               Update_Site_Option ("recently_activated",
                                   deactivated +
                                   List_Type'(get_site_option ("recently_activated")));
            end if;
         end;
      end;

      Wp_Redirect (Self_Admin_URL (
        "plugins.php?deactivate-multi=true&plugin_status=status&paged=page&s=s"));

      Die; -- exit;
   end Action_Deactivate_Selected;

   -------------
   -- Action_ --
   -------------

   procedure Action_Delete_Selected
   is
      use Php.Arrays;
      use Php.Echoing;
      use Php.Errors;
      use Php.Files;
      use Php.HTML;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;

      Plugins_To_Delete : Natural;
      Data_To_Delete    : Boolean := False;
   begin
      if not current_user_can ("delete_plugins") then
         wp_die (abs "Sorry, you are not allowed to delete plugins for this site.");
      end if;

      Check_Admin_Referer ("bulk-plugins");

      -- _POST = from the plugin form; _GET = from the FTP details screen.
      declare
         Plugins : List_Type :=
           (if isset (X_REQUEST, "checked")
            then List_Type'(wp_unslash (Get_As_String (X_REQUEST, "checked")))
            else List_Type);
      begin
         if Empty (Plugins) then
            Wp_Redirect (Self_Admin_URL (
              "plugins.php?plugin_status=status&paged=page&s=s"));
            Die; -- exit;
         end if;

         Plugins := Array_Filter (Plugins, Is_Plugin_Inactive'Access);
         -- Do not allow to delete activated plugins.

         if Empty (Plugins) then
            Wp_Redirect (Self_Admin_URL (
              "plugins.php?error=true&main=true&plugin_status=status&paged=page&s=s"));
            Die; -- exit;
         end if;

      -- Bail on all if any paths are invalid.
      -- validate_file returns truthy for invalid files.
      declare
         Invalid_Plugin_Files : List_Type :=
           Array_Filter (Plugins, Validate_File'Access);
      begin
         if not Invalid_Plugin_Files.Is_Empty then
            Wp_Redirect (Self_Admin_URL (
              "plugins.php?plugin_status=status&paged=page&s=s"));
            Die; -- exit;
         end if;
      end;

      Adm_Update.Run;

      Globals.Global_Parent_File := +"plugins.php";

      if not isset (X_REQUEST, "verify-delete") then
         Wp_Enqueue_Script ("jquery");
         Adm_Admin_header.Run;

         Echo ("<div class=""wrap"">");

         declare
            Plugin_Info              : Array_Type;
            Have_Non_Network_Plugins : Boolean := False;
         begin
            for Plugin of List_Type'(Plugins) loop
               declare
                  Plugin_Slug : String := Dirname (plugin);
               begin
                  if "." = plugin_slug then
                     declare
                        Data : Array_Type :=
                          Get_Plugin_Data ((-Constants.WP_PLUGIN_DIR) & "/" & Plugin);
                     begin
                        if not Data.Is_Empty then
                           Set (Plugin_Info, Plugin, From_Array (Data));
                           Set_2 (Plugin_Info, Plugin, "is_uninstallable",
                                  From_Boolean (Is_Uninstallable_Plugin (Plugin)));
                           if
                             not As_Boolean (Get (Ref_2 (Plugin_Info, Plugin, "Network")))
                           then
                              Have_Non_Network_Plugins := True;
                           end if;
                        end if;
                     end;
                  else
                     -- Get plugins list from that folder.
                     declare
                        Folder_Plugins : Array_Type :=
                          Get_Plugins ("/" & plugin_slug);
                     begin
                        if not Folder_Plugins.Is_Empty then
                           for A in Folder_Plugins.Iterate loop
                              declare
                                 Plugin_File : String     := Key (A);
                                 Data        : Array_Type := As_Array (Element (A));
                              begin
                                 Set (Plugin_Info, Plugin_File, From_Array (
                                      X_Get_Plugin_Data_Markup_Translate (Plugin_File,
                                                                          Data)));
                                 Set_2 (Plugin_Info, Plugin_File, "is_uninstallable",
                                        From_Boolean (
                                          Is_Uninstallable_Plugin (plugin)));

                                 if not As_Boolean (Get (Ref_2 (Plugin_Info, Plugin_File, "Network"))) then
                                    Have_Non_Network_Plugins := True;
                                 end if;
                              end;
                           end loop;
                        end if;
                     end;
                  end if;
               end;
            end loop;

            Plugins_To_Delete := Plugin_Info.Length;

            if 1 = Plugins_To_Delete then
               Echo ("<h1>"); X_E ("Delete Plugin"); Echo ("</h1>");
               if have_non_network_plugins and then is_network_admin then
                  Echo ("<div class=""error""><p><strong>");
                  X_E ("Caution:");
                  Echo ("</strong> ");
                  X_E ("This plugin may be active on other sites in the network.");
                  Echo ("</p></div>");
               end if;
               Echo ("<p>");
               X_E ("You are about to remove the following plugin:");
               Echo ("</p>");
            else
               Echo ("<h1>"); X_E ("Delete Plugins"); Echo ("</h1>");
               if have_non_network_plugins and then Is_Network_Admin then
                  Echo ("<div class=""error""><p><strong>");
                  X_E ("Caution:");
                  Echo ("</strong> ");
                  X_E ("These plugins may be active on other sites in the network.");
                  Echo ("</p></div>");
               end if;
               Echo ("<p>"); X_E ("You are about to remove the following plugins:"); Echo ("</p>");
            end if;
            Echo ("<ul class=""ul-disc"">");

            Data_To_Delete := False;

            for Plugin of Plugin_Info loop
               if As_Boolean (Get (Plugin, "is_uninstallable")) then
                  -- translators: 1: Plugin name, 2: Plugin author.
                  Echo (
                    "<li>" &
                    Sprintf (
                      abs "%1s by %2s (will also <strong>delete its data</strong>)",
                      [
                        1 => "<strong>" &
                             Get_As_String (Plugin, "Name") & "</strong>",
                        2 => "<em>" &
                             Get_As_String (Plugin, "AuthorName") & "</em>"
                      ]) &
                      "</li>");
                  Data_To_Delete := True;
               else
                  -- translators: 1: Plugin name, 2: Plugin author.
                  Echo (
                    "<li>" &
                    Sprintf (
                      X_X ("%1s by %2s", "plugin"),
                      [
                        1 => "<strong>" &
                             Get_As_String (Plugin, "Name") & "</strong>",
                        2 => "<em>" &
                             Get_As_String (Plugin, "AuthorName") & "</em>"
                      ]) &
                    "</li>");
               end if;
            end loop;
         end;
         Echo ("</ul>");
         Echo ("<p>");

         if Data_To_Delete then
            x_e ("Are you sure you want to delete these files and data?");
         else
            x_e ("Are you sure you want to delete these files?");
         end if;

         Echo ("</p>");
         Echo ("<form method=""post"" action=""" &
               ESC_URL (Get_As_String (X_SERVER, "REQUEST_URI")) &
               """ style=""display:inline;"">");
         Echo ("  <input type=""hidden"" name=""verify-delete"" value=""1"" />");
         Echo ("  <input type=""hidden"" name=""action"" value=""delete-selected"" />");

         for Plugin of List_Type'(Plugins) loop
            Echo ("<input type=""hidden"" name=""checked[]"" value=""""" &
                  ESC_Attr (plugin) & """ />");
         end loop;

         Wp_Nonce_Field ("bulk-plugins");
         Submit_Button ((if Data_To_Delete
                         then abs "Yes, delete these files and data"
                         else abs "Yes, delete these files"), "", "submit", False);
         Echo ("</form>");

         declare
            Referer : String := Wp_Get_Referer;
         begin
            Echo ("<form method=""post"" action=""" &
                  (if Referer then ESC_URL (Referer) else "") &
                  """ style=""display:inline;"">");
            Submit_Button (abs "No, return me to the plugin list",
                           "", "submit", False);
            Echo ("</form>");
            Echo ("</div>");
         end;

         Adm_Admin_Footer.Run;
         Die;
      else
         Plugins_To_Delete := Plugins.Length;
      end if; -- End if verify-delete.

      Delete_Result := Delete_Plugins (Plugins);

      -- Store the result in a cache rather than a URL param due to object
      -- type & length.
      Set_Transient ("plugins_delete_result_" & user_ID, Delete_Result);
      Wp_Redirect (Self_Admin_URL (
        "plugins.php?deleted=" & Helpers.Image (Plugins_To_Delete) &
        "&plugin_status=status&paged=page&s=s"));
      end;
      Die; -- exit;
   end Action_Delete_Selected;

   -------------
   -- Action_ --
   -------------

   procedure Action_Clear_Recent_List
   is
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      if not Is_Network_Admin then
         Update_Option ("recently_activated", Empty_List);
      else
         Update_Site_Option ("recently_activated", Empty_List);
      end if;
   end Action_Clear_Recent_List;

   -------------
   -- Action_ --
   -------------

   procedure Action_Resume
   is
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      if Is_Multisite then
         return;
      end if;

      if not current_user_can ("resume_plugin", plugin) then
         wp_die (abs "Sorry, you are not allowed to resume this plugin.");
      end if;

      check_admin_referer ("resume-plugin_" & plugin);

      result := resume_plugin (plugin, self_admin_url ("plugins.php?error=resuming&plugin_status=status&paged=page&s=s"));

      if is_wp_error (result) then
         wp_die (result);
      end if;

      wp_redirect (self_admin_url ("plugins.php?resume=true&plugin_status=status&paged=page&s=s"));
      Die; -- exit;
   end Action_Resume;

   -------------
   -- Action_ --
   -------------

   procedure Action_Auto_Update (Action : String)
   is
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
   begin
      if not current_user_can ("update_plugins") or else not wp_is_auto_update_enabled_for_type ("plugin") then
         wp_die (abs "Sorry, you are not allowed to manage plugins automatic updates.");
      end if;

      if is_multisite and then not is_network_admin then
         wp_die (abs "Please connect to your network admin to manage plugins automatic updates.");
      end if;

      redirect := self_admin_url ("plugins.php?plugin_status=thenstatusend;&paged=thenpageend;&s=thensend;");

      if "enable-auto-update" = action or else "disable-auto-update" = action then
         if empty (plugin) then
            wp_redirect (redirect);
            Die; -- exit;
         end if;

         check_admin_referer ("updates");
      else
         if empty (X_POST, "checked") then
            wp_redirect (redirect);
            Die; -- exit;
         end if;

         check_admin_referer ("bulk-plugins");
      end if;

      auto_updates := List_Type'(get_site_option ("auto_update_plugins", Empty_List));

      if "enable-auto-update" = Action then
         Append (Auto_Updates, Plugin);
         auto_updates   := array_unique (auto_updates);
         redirect       := add_query_arg (Build ("enabled-auto-update", "true"), redirect);
      elsif "disable-auto-update" = action then
         auto_updates := array_diff (auto_updates, [plugin]);
         redirect     := add_query_arg (Build ("disabled-auto-update", "true"), redirect);
      else
         plugins := List_Type'(wp_unslash (Get_As_String (X_POST, "checked")));

         if "enable-auto-update-selected" = action then
            new_auto_updates := array_merge (auto_updates, plugins);
            new_auto_updates := array_unique (new_auto_updates);
            query_args       := build ("enabled-auto-update-multi", "true");
         else
            new_auto_updates := array_diff (auto_updates, plugins);
            query_args       := build ("disabled-auto-update-multi", "true");
         end if;

         -- Return early if all selected plugins already have auto-updates enabled or disabled.
         -- Must use non-strict comparison, so that array order is not treated as significant.
         if new_auto_updates = auto_updates then -- phpcs:ignore WordPress.PHP.StrictComparisons.LooseComparison
            wp_redirect (redirect);
            Die; -- exit;
         end if;

         auto_updates := new_auto_updates;
         redirect     := add_query_arg (query_args, redirect);
      end if;

      -- This filter is documented in wp-admin/includes/class-wp-plugins-list-table.php--
      all_items := apply_filters ("all_plugins", get_plugins);

      -- Remove plugins that don't exist or have been deleted since the option was last updated.
      auto_updates := array_intersect (auto_updates, array_keys (all_items));

      update_site_option ("auto_update_plugins", auto_updates);

      wp_redirect (redirect);
      Die; -- exit;
   end Action_Auto_Update;

   -------------
   -- Action_ --
   -------------

   procedure Action_Default
   is
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      if isset (X_POST, "checked") then
         check_admin_referer ("bulk-plugins");

         screen   := get_current_screen.id;
         sendback := wp_get_referer;
         plugins  := (if isset (X_POST, "checked") then List_Type'(wp_unslash (Get_As_String (X_POST, "checked"))) else Empty_List);

         -- This action is documented in wp-admin/edit.php
         sendback := apply_filters ("handle_bulk_actions-thenscreenend;", sendback, action, plugins);
         wp_safe_redirect (sendback);
         Die; -- exit;
      end if;
   end Action_Default;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;

      use Array_Lists;
      use Binder;
      use Globals;
      use UStrings;

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
   begin

      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      if not Current_User_Can ("activate_plugins") then
         Wp_Die (abs "Sorry, you are not allowed to manage plugins for this site.");
      end if;

      declare
         Wp_List_Table : Duration := X_Get_List_Table ("WP_Plugins_List_Table");
         Pagenum       : Duration := Wp_List_Table.Get_Pagenum;

         Action : String := Wp_List_Table.Current_Action;

         Plugin : String := (if Isset (X_REQUEST, "plugin") then Wp_Unslash (Get_As_String (X_REQUEST, "plugin")) else "");
         S      : String := (if Isset (X_REQUEST, "s") then Url_Encode (Wp_Unslash (Get_As_String (X_REQUEST, "s"))) else "");

         -- Clean up request URI from temporary args for screen options/paging uri's to work as expected.
         Query_Args_To_Remove : List_Type :=
           [
             "error",
             "deleted",
             "activate",
             "activate-multi",
             "deactivate",
             "deactivate-multi",
             "enabled-auto-update",
             "disabled-auto-update",
             "enabled-auto-update-multi",
             "disabled-auto-update-multi",
             "_error_nonce"
          ];
      begin
         Set (X_SERVER, "REQUEST_URI",
              Remove_Query_Arg (Query_Args_To_Remove, Get (X_SERVER, "REQUEST_URI")));

         Wp_Enqueue_Script ("updates");

         if Action then

            if Action in "activate" then
               Action_Activate;

            elsif Action in "activate-selected" then
               Action_Activate_Selected;

            elsif Action in "update-selected" then
               Action_Update_Selected;

            elsif Action in "error_scrape" then
               Action_Error_Scrape;

            elsif Action in "deactivate" then
               Action_Deactivate;

            elsif Action in "deactivate-selected" then
               Action_Deactivate_Selected;

            elsif Action in "delete-selected" then
               Action_Delete_Selected;

            elsif Action in "clear-recent-list" then
               Action_Clear_Recent_List;

            elsif Action in "resume" then
               Action_Resume;

            elsif Action in "enable-auto-update" |
                "disable-auto-update" |
                "enable-auto-update-selected" |
                "disable-auto-update-selected"
            then
               Action_Auto_Update (Action);

            else -- Action
               Action_Default;
            end if;  -- Switch
         end if;  -- Action

         wp_list_table.prepare_items;

         wp_enqueue_script ("plugin-install");
         add_thickbox;

         add_screen_option ("per_page", Build ("default", 999));

         get_current_screen.Add_Help_Tab (
           To_Array_Type ([
             Build ("id",      "overview"),
             Build ("title",   abs "Overview"),
             Build ("content",
                    "<p>" & abs "Plugins extend and expand the functionality of WordPress. Once a plugin is installed, you may activate it or deactivate it here." & "</p>" &
                    "<p>" & abs "The search for installed plugins will search for terms in their name, description, or author." & " <span id=""live-search-desc"" class=""hide-if-no-js"">" & abs "The search results will be updated as you type." & "</span></p>" &
                    "<p>" & Sprintf (
                      -- translators: %s: WordPress Plugin Directory URL.
                      abs "If you would like to see more plugins to choose from, click on the &#8220;Add New&#8221; button and you will be able to browse or search for additional plugins from the <a href=""%s"">WordPress Plugin Directory</a>. Plugins in the WordPress Plugin Directory are designed and developed by third parties, and are compatible with the license WordPress uses. Oh, and they&#8217;re free!",
                      [abs "https://wordpress.org/plugins/"]
                    ) & "</p>")
           ])
         );

         get_current_screen.Add_Help_Tab (
           To_Array_Typ ([
             Build ("id",      "compatibility-problems"),
             Build ("title",   abs "Troubleshooting"),
             Build ("content",
                    "<p>" & abs "Most of the time, plugins play nicely with the core of WordPress and with other plugins. Sometimes, though, a plugin&#8217;s code will get in the way of another plugin, causing compatibility issues. If your site starts doing strange things, this may be the problem. Try deactivating all your plugins and re-activating them in various combinations until you isolate which one(s) caused the issue." & "</p>" &
                    "<p>" & Sprintf (
                      -- translators: %s: WP_PLUGIN_DIR constant value.
                      abs "If something goes wrong with a plugin and you cannot use WordPress, delete or rename that file in the %s directory and it will be automatically deactivated.",
                      ["<code>" & WP_PLUGIN_DIR & "</code>"]
                 ) & "</p>")
           ])
         );

         help_sidebar_autoupdates := "";

         if current_user_can ("update_plugins") and then wp_is_auto_update_enabled_for_type ("plugin") then
            get_current_screen.Add_Help_Tab (
              To_Array_Type ([
                Build ("id",      "plugins-themes-auto-updates"),
                Build ("title",   abs "Auto-updates"),
                Build ("content",
                       "<p>" & abs "Auto-updates can be enabled or disabled for each individual plugin. Plugins with auto-updates enabled will display the estimated date of the next auto-update. Auto-updates depends on the WP-Cron task scheduling system." & "</p>" &
                       "<p>" & abs "Auto-updates are only available for plugins recognized by WordPress.org, or that include a compatible update system." & "</p>" &
                       "<p>" & abs "Please note: Third-party themes and plugins, or custom code, may override WordPress scheduling." & "</p>")
              ])
            );

            help_sidebar_autoupdates := "<p>" & abs "<a href=""https://wordpress.org/support/article/plugins-themes-auto-updates/"">Learn more: Auto-updates documentation</a>" & "</p>";
         end if;

         get_current_screen.Set_Help_Sidebar (
           "<p><strong>" & abs "For more information:" & "</strong></p>" &
           "<p>" & abs "<a href=""https://wordpress.org/support/article/managing-plugins/"">Documentation on Managing Plugins</a>" & "</p>" &
           help_sidebar_autoupdates &
           "<p>" & abs "<a href=""https://wordpress.org/support/"">Support</a>" & "</p>"
         );

         get_current_screen.Set_Screen_Reader_Content (
           To_Array_Type ([
             Build ("heading_views",      abs "Filter plugins list"),
             Build ("heading_pagination", abs "Plugins list navigation"),
             Build ("heading_list",       abs "Plugins list")
           ])
         );

         -- Used in the HTML title tag.
         title       := abs "Plugins";
         parent_file := "plugins.php";

         Adm_Admin_header.Run;

         invalid := validate_active_plugins;
         if not empty (invalid) then
            for A in Invalid.Iterate loop
               declare
                  Plugin_File : String := Key (A);
                  Error : Multi_Type := Element (A);
               begin
                  Echo ("<div id=""message"" class=""error""><p>");
                  Printf (
                    -- translators: 1: Plugin file, 2: Error message.
                    abs "The plugin %1s has been deactivated due to an error: %2s",
                    ["<code>" & esc_html (plugin_file) & "</code>",
                     esc_html (error.get_error_message)]
                  );
               end;
               echo ("</p></div>");
            end loop;
         end if;

         if isset (XX_GET, "error") then

            if isset (XX_GET, "main") then
               errmsg := abs "You cannot delete a plugin while it is active on the main site.";
            elsif isset (XX_GET, "charsout") then
               errmsg := Sprintf (
                 -- translators: %d: Number of characters.
                 X_N (
                   "The plugin generated %d character of <strong>unexpected output</strong> during activation.",
                   "The plugin generated %d characters of <strong>unexpected output</strong> during activation.",
                   [As_Integer (Get (XX_GET, "charsout"))]
                 ),
                 [As_Integer (XX_GET, "charsout")]
               );
               Append (Errmsg, " " & abs "If you notice &#8220;headers already sent&#8221; messages, problems with syndication feeds or other issues, try deactivating or removing this plugin.");
            elsif "resuming" = Get_As_String (XX_GET, "error") then
               errmsg := abs "Plugin could not be resumed because it triggered a <strong>fatal error</strong>.";
            else
               errmsg := abs "Plugin could not be activated because it triggered a <strong>fatal error</strong>.";
            end if;

            Echo ("<div id=""message"" class=""error""><p>" & Errmsg & "</p>");

            if
              not isset (XX_GET, "main") and then
              not isset (XX_GET, "charsout") and then
              isset (XX_GET, "_error_nonce") and then
              wp_verify_nonce (Get_As_String (XX_GET, "_error_nonce"), "plugin-activation-error_" & plugin)
            then
               iframe_url := Add_Query_Arg (
                 To_Array_Type ([
                   Build ("action",   "error_scrape"),
                   Build ("plugin",   Url_encode (plugin)),
                   Build ("_wpnonce", Url_encode (Get_As_String (XX_GET, "_error_nonce")))
                 ]),
                 admin_url ("plugins.php")
               );

               Echo ("<iframe style=""border:0"" width=""100%"" height=""70px"" src=""" & esc_url (iframe_url) & """></iframe>");
            end if;

            Echo ("</div>");

         elsif isset (XX_GET, "deleted") then
            delete_result := get_transient ("plugins_delete_result_" & user_ID);
            -- Delete it once we're done.
            delete_transient ("plugins_delete_result_" & user_ID);

            if is_wp_error (delete_result) then

               Echo ("<div id=""message"" class=""error notice is-dismissible"">");
               Echo ("        <p>");

               Printf (
                 -- translators: %s: Error message.
                 abs "Plugin could not be deleted due to an error: %s",
                 [esc_html (delete_result.get_error_message)]
               );

               Echo ("        </p>");
               Echo ("</div>");
            else
               Echo ("<div id=""message"" class=""updated notice is-dismissible"">");
               Echo ("        <p>");

               if 1 = As_Integer (Get (XX_GET, "deleted")) then
                  x_e ("The selected plugin has been deleted.");
               else
                  x_e ("The selected plugins have been deleted.");
               end if;
               Echo ("        </p>");
               Echo ("</div>");
            end if;

         elsif isset (XX_GET, "activate") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Plugin activated."); Echo ("</p></div>");
         elsif isset (XX_GET, "activate-multi") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Selected plugins activated."); Echo ("</p></div>");
         elsif isset (XX_GET, "deactivate") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Plugin deactivated."); Echo ("</p></div>");
         elsif isset (XX_GET, "deactivate-multi") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Selected plugins deactivated."); Echo ("</p></div>");
         elsif "update-selected" = Action then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("All selected plugins are up to date."); Echo ("</p></div>");
         elsif isset (XX_GET, "resume") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Plugin resumed."); Echo ("</p></div>");
         elsif isset (XX_GET, "enabled-auto-update") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Plugin will be auto-updated."); Echo ("</p></div>");
         elsif isset (XX_GET, "disabled-auto-update") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Plugin will no longer be auto-updated."); Echo ("</p></div>");
         elsif isset (XX_GET, "enabled-auto-update-multi") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Selected plugins will be auto-updated."); Echo ("</p></div>");
         elsif isset (XX_GET, "disabled-auto-update-multi") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>"); X_E ("Selected plugins will no longer be auto-updated."); Echo ("</p></div>");
         end if;

         Echo ("<div class=""wrap"">");
         Echo ("<h1 class=""wp-heading-inline"">");

         echo (esc_html (title));

         Echo ("</h1>");

         if (not is_multisite or else is_network_admin) and then current_user_can ("install_plugins") then
            Echo ("<a href=""" & esc_url (self_admin_url ("plugin-install.php")) & """ class=""page-title-action"">" & esc_html_x ("Add New", "plugin") & "</a>");
         end if;

         if strlen (s) /= 0 then
            echo ("<span class=""subtitle"">");
            Printf (
              -- translators: %s: Search query.
              abs "Search results for: %s",
              ["<strong>" & esc_html (Url_decode (s)) & "</strong>"]
            );
            echo ("</span>");
         end if;

         Echo ("<hr class=""wp-header-end"">");

         --
         -- Fires before the plugins list table is rendered.
         --
         -- This hook also fires before the plugins list table is rendered in the Network Admin.
         --
         -- Please note: The "active" portion of the hook name does not refer to whether the current
         -- view is for active plugins, but rather all plugins actively-installed.
         --
         -- @since 3.0.0
         --
         -- @param array[] plugins_all An array of arrays containing information on all installed plugins.
         --
         do_action ("pre_current_active_plugins", Get_As_String (Plugins, "all"));

         wp_list_table.views;

         Echo ("<form class=""search-form search-plugins"" method=""get"">");
         wp_list_table.search_box (abs "Search Installed Plugins", "plugin");
         Echo ("</form>");

         Echo ("<form method=""post"" id=""bulk-action-form"">");

         Echo ("<input type=""hidden"" name=""plugin_status"" value=""" & Esc_Attr (Status) & """ />");
         Echo ("<input type=""hidden"" name=""paged"" value=""" & Esc_Attr (Page) & """ />");

         Wp_List_Table.Display;
         Echo ("</form>");

         Echo ("  <span class=""spinner""></span>");
         Echo ("</div>");

         wp_print_request_filesystem_credentials_modal;
         wp_print_admin_notice_templates;
         wp_print_update_row_templates;

         Adm_Admin_Footer.Run;
      end;
   end Render;

end Adm_Plugins;
