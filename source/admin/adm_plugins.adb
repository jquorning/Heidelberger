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
with Php.Ini;
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
with Wp_Common;

with Class_Errors;
with Class_List_Tables;
with Class_Plugins_List_Tables;

with Adm_Admin;
with Adm_Admin_Footer;
with Adm_Admin_Header;
with Adm_Update;

with Adi_Files;
with Adi_List_Tables;
with Adi_Plugins;
with Adi_Screens;
with Adi_Templates;
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
   procedure Action_Delete_Selected (User_Id : String);
   procedure Action_Clear_Recent_List;
   procedure Action_Resume (Plugin : String);
   procedure Action_Auto_Update (Plugin : String;
                                 Action : String);
   procedure Action_Default (Action : String);

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
           Self_Admin_URL ("plugins.php?plugin_status=status&paged=page&s=s"));
         Die; -- exit;
      end if;

      Check_Admin_Referer ("activate-plugin_" & Plugin);

      declare
         Result : constant Null_Error_Type :=
           Activate_Plugin (Plugin,
                            Self_Admin_URL ("plugins.php?error=true&plugin=" &
                                            URL_Encode (Plugin)),
                            Is_Network_Admin);
      begin
         if not Result.Success then
--       if Is_Wp_Error (Result) then
            if "unexpected_output" = Result.Error.Get_Error_Code then
               declare
                  Redirect : constant String :=
                    Self_Admin_URL (
                      "plugins.php?error=true&charsout=" &
                      Helpers.Image (Strlen (Result.Error.Get_Error_Data)) &
                      "&plugin=" & URL_Encode (Plugin) &
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
            Recent : constant Array_Type :=
              Get_Option ("recently_activated");
         begin
            Delete (Ref (Recent, Plugin));
            Update_Option ("recently_activated", From_Array (Recent));
         end;
      else
         declare
            Recent : constant Array_Type := As_Array (
              Get_Site_Option ("recently_activated"));
         begin
            Delete (Ref (Recent, Plugin));
            Update_Site_Option ("recently_activated", From_Array (Recent));
         end;
      end if;

      if
        Isset (XX_GET, "from") and then
        "import" = Get_As_String (XX_GET, "from")
      then
         -- Overrides the ?error=true one above and redirects to the Imports page,
         -- stripping the -importer suffix.
         Wp_Redirect (
           Self_Admin_URL ("import.php?import=" &
                           Str_Replace ("-importer", "", Dirname (Plugin))));
      elsif
        Isset (XX_GET, "from") and then
        "press-this" = Get_As_String (XX_GET, "from")
      then
         Wp_Redirect (Self_Admin_URL ("press-this.php"));
      else
         -- Overrides the ?error=true one above.
         Wp_Redirect (Self_Admin_URL (
           "plugins.php?activate=true&plugin_status=status&paged=page&s=s"));
      end if;
      Die; -- exit;
   end Action_Activate;

   -------------
   -- Action_ --
   -------------

   procedure Action_Activate_Selected
   is
      use Php.Errors;
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

      Plugins : List_Type;
   begin
      if not Current_User_Can ("activate_plugins") then
         Wp_Die (abs "Sorry, you are not allowed to activate plugins for this site.");
      end if;

      Check_Admin_Referer ("bulk-plugins");

      Plugins :=
        (if Isset (X_POST, "checked")
         then List_Type'(Wp_Unslash (Get_As_String (X_POST, "checked")))
         else Empty_List);

      if Is_Network_Admin then
         for I in reverse Plugins.First_Index .. Plugins.Last_Index loop
            -- Only activate plugins which are not already network activated.
            if Is_Plugin_Active_For_Network (Plugins (I)) then
               Plugins.Delete (I);
            end if;
         end loop;

      else
         for I in reverse Plugins.First_Index .. Plugins.Last_Index loop
            -- Only activate plugins which are not already active and are not
            -- network-only when on Multisite.
            if
              Is_Plugin_Active (Plugins (I)) or else
              (Is_Multisite and then Is_Network_Only_Plugin (Plugins (I)))
            then
               Plugins.Delete (I);
            end if;

            -- Only activate plugins which the user can activate.
            if not Current_User_Can ("activate_plugin", Plugins (I)) then
               Plugins.Delete (I);
            end if;
         end loop;
      end if;

      if Plugins.Is_Empty then
         Wp_Redirect (Self_Admin_URL (
           "plugins.php?plugin_status=status&paged=page&s=s"));
         Die; -- exit;
      end if;

      Activate_Plugins (Plugins,
                        Self_Admin_URL ("plugins.php?error=true"),
                        Is_Network_Admin);

      declare
         Recent : List_Type :=
           (if not Is_Network_Admin
            then List_Type'(Get_Option ("recently_activated"))
            else List_Type'(As_List (Get_Site_Option ("recently_activated"))));
      begin
         for Plugin in Plugins.First_Index .. Plugins.Last_Index loop
            Recent.Delete (Plugin);
         end loop;
         -- for Plugin of Plugins loop
         --    Delete (Ref (Recent, Plugin));
         -- end loop;

         if not Is_Network_Admin then
            Update_Option ("recently_activated", From_List (Recent));
         else
            Update_Site_Option ("recently_activated", From_List (Recent));
         end if;
      end;

      Wp_Redirect (Self_Admin_URL (
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
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      Check_Admin_Referer ("bulk-plugins");

      declare
         Plugins : constant List_Type :=
           (if Isset (XX_GET, "plugins")
              then Explode (",", Wp_Unslash (Get_As_String (XX_GET, "plugins")))
            elsif Isset (X_POST, "checked")
              then List_Type'(Wp_Unslash (Get_As_String (X_POST, "checked")))
            else Empty_List);
      begin
         -- Used in the HTML title tag.
         Globals.Title              := +abs "Update Plugins";
         Globals.Global_Parent_File := +"plugins.php";

         Wp_Enqueue_Script ("updates");
         Adm_Admin_Header.Run;

         Echo ("<div class=""wrap"">");
         Echo ("<h1>" & ESC_HTML (-Globals.Title) & "</h1>");

         declare
            URL_2 : constant String :=
              Self_Admin_URL ("update.php?action=update-selected&amp;plugins=" &
                              URL_Encode (Implode (",", Plugins)));

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
      use Php.Ini;
      use Wp_Common;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      if not Current_User_Can ("activate_plugin", Plugin) then
         Wp_Die (abs "Sorry, you are not allowed to activate this plugin.");
      end if;

      Check_Admin_Referer ("plugin-activation-error_" & Plugin);

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
      use Php.Arrays;
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
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

      Check_Admin_Referer ("deactivate-plugin_" & Plugin);

      if not Is_Network_Admin and then Is_Plugin_Active_For_Network (Plugin) then
         Wp_Redirect (Self_Admin_URL (
           "plugins.php?plugin_status=status&paged=page&s=s"));
         Die; -- exit;
      end if;

      Deactivate_Plugins ([Plugin], False, Is_Network_Admin);

      if not Is_Network_Admin then
         Update_Option ("recently_activated", From_Array (
                        Array_Merge (Build (Plugin, Php.Misc.Time),
                                     Get_Option ("recently_activated"))));
      else
         Update_Site_Option (
           "recently_activated", From_Array (
           Array_Merge (Build (Plugin, Php.Misc.Time),
                        As_Array (Get_Site_Option ("recently_activated")))));
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
      use Php.Lists;
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
           (if Isset (X_POST, "checked")
            then List_Type'(Wp_Unslash (Get_As_String (X_POST, "checked")))
            else Empty_List);
      begin
         -- Do not deactivate plugins which are already deactivated.
         if Is_Network_Admin then
            Plugins := List_Filter (Plugins,
                                    Is_Plugin_Active_For_Network'Access);
         else
            Plugins := List_Filter (Plugins,
                                    Is_Plugin_Active'Access);

            Plugins := List_Diff (Plugins,
                                  List_Filter (Plugins,
                                               Is_Plugin_Active_For_Network'Access));

            for I in reverse Plugins.First_Index .. Plugins.Last_Index loop
               -- Only deactivate plugins which the user can deactivate.
               if not Current_User_Can ("deactivate_plugin", Plugins (I)) then
                  Plugins.Delete (I);
               end if;
            end loop;
         end if;

         if Plugins.Is_Empty then
            Wp_Redirect (Self_Admin_URL (
              "plugins.php?plugin_status=status&paged=page&s=s"));
            Die; -- exit;
         end if;

         Deactivate_Plugins (Plugins, False, Is_Network_Admin);

         declare
            Deactivated : Array_Type;
         begin
            for Plugin of Plugins loop
               Set (Deactivated, Plugin, From_Integer (Php.Misc.Time));
            end loop;

            if not Is_Network_Admin then
               Update_Option ("recently_activated", From_Array (
                              Array_Merge (Deactivated,
                                           Get_Option ("recently_activated"))));
            else
               Update_Site_Option (
                 "recently_activated", From_Array (
                 Array_Merge (Deactivated,
                              As_Array (Get_Site_Option ("recently_activated")))));
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

   procedure Action_Delete_Selected (User_Id : String)
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.Files;
      use Php.Lists;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Adi_Plugins;
      use Adi_Templates;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;

      Plugins           : List_Type;
      Plugins_To_Delete : Natural;
      Data_To_Delete    : Boolean := False;
   begin
      if not Current_User_Can ("delete_plugins") then
         Wp_Die (abs "Sorry, you are not allowed to delete plugins for this site.");
      end if;

      Check_Admin_Referer ("bulk-plugins");

      -- _POST = from the plugin form; _GET = from the FTP details screen.
      Plugins :=
        (if Isset (X_REQUEST, "checked")
         then List_Type'(Wp_Unslash (Get_As_String (X_REQUEST, "checked")))
         else Empty_List);

      if Plugins.Is_Empty then
         Wp_Redirect (Self_Admin_URL (
           "plugins.php?plugin_status=status&paged=page&s=s"));
         Die; -- exit;
      end if;

      Plugins := List_Filter (Plugins, Is_Plugin_Inactive'Access);
      -- Do not allow to delete activated plugins.

      if Plugins.Is_Empty then
         Wp_Redirect (Self_Admin_URL (
           "plugins.php?error=true&main=true&plugin_status=status&paged=page&s=s"));
         Die; -- exit;
      end if;

      -- Bail on all if any paths are invalid.
      -- validate_file returns truthy for invalid files.
      declare
         Invalid_Plugin_Files : constant List_Type :=
           List_Filter (Plugins, Validate_File'Access);
      begin
         if not Invalid_Plugin_Files.Is_Empty then
            Wp_Redirect (Self_Admin_URL (
              "plugins.php?plugin_status=status&paged=page&s=s"));
            Die; -- exit;
         end if;
      end;

      Adm_Update.Run;

      Globals.Global_Parent_File := +"plugins.php";

      if not Isset (X_REQUEST, "verify-delete") then
         Wp_Enqueue_Script ("jquery");
         Adm_Admin_Header.Run;

         Echo ("<div class=""wrap"">");

         declare
            Plugin_Info              : Array_Type;
            Have_Non_Network_Plugins : Boolean := False;
         begin
            for Plugin of List_Type'(Plugins) loop
               declare
                  Plugin_Slug : constant String := Dirname (Plugin);
               begin
                  if "." = Plugin_Slug then
                     declare
                        Data : constant Array_Type :=
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
                        Folder_Plugins : constant Array_Type :=
                          Get_Plugins ("/" & Plugin_Slug);
                     begin
                        if not Folder_Plugins.Is_Empty then
                           for A in Folder_Plugins.Iterate loop
                              declare
                                 Plugin_File : constant String := Key (A);

                                 Data        : constant Array_Type :=
                                   As_Array (Element (A));
                              begin
                                 Set (Plugin_Info, Plugin_File, From_Array (
                                      X_Get_Plugin_Data_Markup_Translate (Plugin_File,
                                                                          Data)));
                                 Set_2 (Plugin_Info, Plugin_File, "is_uninstallable",
                                        From_Boolean (
                                          Is_Uninstallable_Plugin (Plugin)));

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
               if Have_Non_Network_Plugins and then Is_Network_Admin then
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
               if Have_Non_Network_Plugins and then Is_Network_Admin then
                  Echo ("<div class=""error""><p><strong>");
                  X_E ("Caution:");
                  Echo ("</strong> ");
                  X_E ("These plugins may be active on other sites in the network.");
                  Echo ("</p></div>");
               end if;
               Echo ("<p>");
               X_E ("You are about to remove the following plugins:");
               Echo ("</p>");
            end if;
            Echo ("<ul class=""ul-disc"">");

            Data_To_Delete := False;

            for A in Plugin_Info.Iterate loop
               declare
                  Plugin : constant Array_Type := As_Array (Element (A));
               begin
--          for Plugin of Plugin_Info loop
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
               end;
            end loop;
         end;
         Echo ("</ul>");
         Echo ("<p>");

         if Data_To_Delete then
            X_E ("Are you sure you want to delete these files and data?");
         else
            X_E ("Are you sure you want to delete these files?");
         end if;

         Echo ("</p>");
         Echo ("<form method=""post"" action=""" &
               ESC_URL (Get_As_String (X_SERVER, "REQUEST_URI")) &
               """ style=""display:inline;"">");
         Echo ("  <input type=""hidden"" name=""verify-delete"" value=""1"" />");
         Echo ("  <input type=""hidden"" name=""action"" value=""delete-selected"" />");

         for Plugin of List_Type'(Plugins) loop
            Echo ("<input type=""hidden"" name=""checked[]"" value=""""" &
                  ESC_Attr (Plugin) & """ />");
         end loop;

         Wp_Nonce_Field ("bulk-plugins");
         Submit_Button ((if Data_To_Delete
                         then abs "Yes, delete these files and data"
                         else abs "Yes, delete these files"), "", "submit", False);
         Echo ("</form>");

         declare
            Referer : constant String := Wp_Get_Referer;
         begin
            Echo ("<form method=""post"" action=""" &
                  (if Referer /= "" then ESC_URL (Referer) else "") &
                  """ style=""display:inline;"">");
            Submit_Button (abs "No, return me to the plugin list",
                           "", "submit", False);
            Echo ("</form>");
            Echo ("</div>");
         end;

         Adm_Admin_Footer.Run;
         Die;
      else
         Plugins_To_Delete := Natural (Plugins.Length);
      end if; -- End if verify-delete.

      declare
         Delete_Result : constant Boolean := Delete_Plugins (Plugins);
      begin
         -- Store the result in a cache rather than a URL param due to object
         -- type & length.
         Set_Transient ("plugins_delete_result_" & User_Id,
                        From_Boolean (Delete_Result));
      end;

      Wp_Redirect (Self_Admin_URL (
        "plugins.php?deleted=" & Helpers.Image (Plugins_To_Delete) &
        "&plugin_status=status&paged=page&s=s"));

      Die; -- exit;
   end Action_Delete_Selected;

   -------------
   -- Action_ --
   -------------

   procedure Action_Clear_Recent_List
   is
      use Inc_Load;
      use Inc_Options;
   begin
      if not Is_Network_Admin then
         Update_Option ("recently_activated", From_List (Empty_List));
      else
         Update_Site_Option ("recently_activated", From_List (Empty_List));
      end if;
   end Action_Clear_Recent_List;

   -------------
   -- Action_ --
   -------------

   procedure Action_Resume (Plugin : String)
   is
      use Php.Errors;
      use Adi_Plugins;
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

      if not Current_User_Can ("resume_plugin", Plugin) then
         Wp_Die (abs "Sorry, you are not allowed to resume this plugin.");
      end if;

      Check_Admin_Referer ("resume-plugin_" & Plugin);

      declare
         Result : constant Bool_Error_Type :=
           Resume_Plugin (Plugin, Self_Admin_URL (
             "plugins.php?error=resuming&plugin_status=status&paged=page&s=s"));
      begin
         if not Result.Success then
--       if Is_Wp_Error (Result) then
            Wp_Die (Result.Error);
         end if;
      end;

      Wp_Redirect (Self_Admin_URL (
        "plugins.php?resume=true&plugin_status=status&paged=page&s=s"));
      Die; -- exit;
   end Action_Resume;

   -------------
   -- Action_ --
   -------------

   procedure Action_Auto_Update (Plugin : String;
                                 Action : String)
   is
      use Php.Arrays;
      use Php.Errors;
      use Php.Lists;
      use Php.Strings;
      use Binder;
      use Wp_Common;
      use Adi_Plugins;
      use Adi_Update;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
   begin
      if
        not Current_User_Can ("update_plugins") or else
        not Wp_Is_Auto_Update_Enabled_For_Type ("plugin")
      then
         Wp_Die (
           abs "Sorry, you are not allowed to manage plugins automatic updates.");
      end if;

      if Is_Multisite and then not Is_Network_Admin then
         Wp_Die (abs "Please connect to your network admin to manage plugins automatic updates.");
      end if;

      declare
         Redirect : String := Self_Admin_URL (
           "plugins.php?plugin_status=thenstatusend;&paged=thenpageend;&s=thensend;");
      begin

         if Action in "enable-auto-update" | "disable-auto-update" then
            if Empty (Plugin) then
               Wp_Redirect (Redirect);
               Die; -- exit;
            end if;
            Check_Admin_Referer ("updates");

         else
            if Empty (X_POST, "checked") then
               Wp_Redirect (Redirect);
               Die; -- exit;
            end if;

            Check_Admin_Referer ("bulk-plugins");
         end if;

         declare
            Auto_Updates : List_Type :=
              As_List (Get_Site_Option ("auto_update_plugins",
                                        From_List (Empty_List)));
         begin
            if "enable-auto-update" = Action then
               Append (Auto_Updates, Plugin);
               Auto_Updates := List_Unique (Auto_Updates);
               Redirect     := Add_Query_Arg (Build ("enabled-auto-update", "true"),
                                              Redirect);

            elsif "disable-auto-update" = Action then
               Auto_Updates := List_Diff (Auto_Updates, Plugin);
               Redirect     := Add_Query_Arg (Build ("disabled-auto-update", "true"),
                                              Redirect);

            else
               declare
                  use List_Vectors;

                  Plugins : constant List_Type :=
                    Wp_Unslash (Get_As_String (X_POST, "checked"));

                  New_Auto_Updates : List_Type;
                  Query_Args       : Array_Type;
               begin
                  if "enable-auto-update-selected" = Action then
                     New_Auto_Updates := List_Merge (Auto_Updates, Plugins);
                     New_Auto_Updates := List_Unique (New_Auto_Updates);
                     Query_Args       := Build ("enabled-auto-update-multi", "true");
                  else
                     New_Auto_Updates := List_Diff (Auto_Updates, Plugins);
                     Query_Args       := Build ("disabled-auto-update-multi", "true");
                  end if;

                  -- Return early if all selected plugins already have auto-updates
                  -- enabled or disabled. Must use non-strict comparison, so that
                  -- array order is not treated as significant.
                  if New_Auto_Updates = Auto_Updates then
                     Wp_Redirect (Redirect);
                     Die; -- exit;
                  end if;

                  Auto_Updates := New_Auto_Updates;
                  Redirect     := Add_Query_Arg (Query_Args, Redirect);
               end;
            end if;

            -- This filter is documented in
            -- wp-admin/includes/class-wp-plugins-list-table.php
            declare
               All_Items : constant Array_Type :=
                 Apply_Filters ("all_plugins", Get_Plugins);
            begin
               -- Remove plugins that don't exist or have been deleted since the
               -- option was last updated.

               Auto_Updates := List_Intersect (Auto_Updates,
                                               Array_Keys (All_Items));

               Update_Site_Option ("auto_update_plugins", From_List (Auto_Updates));
            end;
         end;

         Wp_Redirect (Redirect);
      end;

      Die; -- exit;
   end Action_Auto_Update;

   -------------
   -- Action_ --
   -------------

   procedure Action_Default (Action : String)
   is
      use Php.Errors;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Adi_Screens;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Pluggables;
   begin
      if Isset (X_POST, "checked") then
         Check_Admin_Referer ("bulk-plugins");

         declare
            Screen   : constant String := -Get_Current_Screen.Id;
            Sendback : String := Wp_Get_Referer;

            Plugins : List_Type :=
              (if Isset (X_POST, "checked")
               then Wp_Unslash (Get_As_String (X_POST, "checked"))
               else Empty_List);
         begin
            -- This action is documented in wp-admin/edit.php
            Sendback := Apply_Filters ("handle_bulk_actions-" & Screen,
                                       Sendback, Action, Plugins);
            Wp_Safe_Redirect (Sendback);
         end;
         Die; -- exit;
      end if;
   end Action_Default;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Echoing;
      use Php.HTML;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use Globals;
      use UStrings;
      use Wp_Common;
      use Class_Errors;
      use Class_List_Tables;
      use Class_Plugins_List_Tables;
      use Adi_Files;
      use Adi_List_Tables;
      use Adi_Plugins;
      use Adi_Screens;
      use Adi_Update;
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

      User_Id : constant String := "XXX-941"; -- XXX ???
      Parent_File : UString;

      Help_Sidebar_Autoupdates : UString;
      Errmsg : UString;
   begin

      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      if not Current_User_Can ("activate_plugins") then
         Wp_Die (abs "Sorry, you are not allowed to manage plugins for this site.");
      end if;

      declare
         List_Table : Wp_Plugins_List_Table := -- Wp_List_Table'Class :=
           Wp_Plugins_List_Table (X_Get_List_Table ("Wp_Plugins_List_Table"));
--         X_Get_List_Table ("Wp_Plugins_List_Table");

         Pagenum : Natural := List_Table.Get_Pagenum;

         Action : constant String := List_Table.Current_Action;

         Plugin : String :=
           (if Isset (X_REQUEST, "plugin")
            then Wp_Unslash (Get_As_String (X_REQUEST, "plugin")) else "");

         S : String :=
           (if Isset (X_REQUEST, "s")
           then URL_Encode (Wp_Unslash (Get_As_String (X_REQUEST, "s"))) else "");

         -- Clean up request URI from temporary args for screen options/paging
         -- uri's to work as expected.
         Query_Args_To_Remove : constant List_Type :=
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
         Set (X_SERVER, "REQUEST_URI", From_String (
           Remove_Query_Arg (Query_Args_To_Remove,
                             Get_As_String (X_SERVER, "REQUEST_URI"))));

         Wp_Enqueue_Script ("updates");

         if Action /= "" then

            if Action in "activate" then
               Action_Activate (Plugin => Plugin);

            elsif Action in "activate-selected" then
               Action_Activate_Selected;

            elsif Action in "update-selected" then
               Action_Update_Selected;

            elsif Action in "error_scrape" then
               Action_Error_Scrape (Plugin => Plugin);

            elsif Action in "deactivate" then
               Action_Deactivate (Plugin => Plugin);

            elsif Action in "deactivate-selected" then
               Action_Deactivate_Selected;

            elsif Action in "delete-selected" then
               Action_Delete_Selected (User_Id => User_Id);

            elsif Action in "clear-recent-list" then
               Action_Clear_Recent_List;

            elsif Action in "resume" then
               Action_Resume (Plugin => Plugin);

            elsif Action in "enable-auto-update" |
                "disable-auto-update" |
                "enable-auto-update-selected" |
                "disable-auto-update-selected"
            then
               Action_Auto_Update (Plugin => Plugin,
                                   Action => Action);

            else -- Action
               Action_Default (Action => Action);
            end if;  -- Switch
         end if;  -- Action

         List_Table.Prepare_Items;

         Wp_Enqueue_Script ("plugin-install");
         Add_Thickbox;

         Add_Screen_Option ("per_page", Build ("default", 999));

         Get_Current_Screen.Add_Help_Tab (
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

         Get_Current_Screen.Add_Help_Tab (
           To_Array_Type ([
             Build ("id",      "compatibility-problems"),
             Build ("title",   abs "Troubleshooting"),
             Build ("content",
                    "<p>" & abs "Most of the time, plugins play nicely with the core of WordPress and with other plugins. Sometimes, though, a plugin&#8217;s code will get in the way of another plugin, causing compatibility issues. If your site starts doing strange things, this may be the problem. Try deactivating all your plugins and re-activating them in various combinations until you isolate which one(s) caused the issue." & "</p>" &
                    "<p>" & Sprintf (
                      -- translators: %s: WP_PLUGIN_DIR constant value.
                      abs "If something goes wrong with a plugin and you cannot use WordPress, delete or rename that file in the %s directory and it will be automatically deactivated.",
                      ["<code>" & (-Constants.WP_PLUGIN_DIR) & "</code>"]
                 ) & "</p>")
           ])
         );

         Help_Sidebar_Autoupdates := +"";

         if
           Current_User_Can ("update_plugins") and then
           Wp_Is_Auto_Update_Enabled_For_Type ("plugin")
         then
            Get_Current_Screen.Add_Help_Tab (
              To_Array_Type ([
                Build ("id",      "plugins-themes-auto-updates"),
                Build ("title",   abs "Auto-updates"),
                Build ("content",
                       "<p>" & abs "Auto-updates can be enabled or disabled for each individual plugin. Plugins with auto-updates enabled will display the estimated date of the next auto-update. Auto-updates depends on the WP-Cron task scheduling system." & "</p>" &
                       "<p>" & abs "Auto-updates are only available for plugins recognized by WordPress.org, or that include a compatible update system." & "</p>" &
                       "<p>" & abs "Please note: Third-party themes and plugins, or custom code, may override WordPress scheduling." & "</p>")
              ])
            );

            Help_Sidebar_Autoupdates := +"<p>" & abs "<a href=""https://wordpress.org/support/article/plugins-themes-auto-updates/"">Learn more: Auto-updates documentation</a>" & "</p>";
         end if;

         Get_Current_Screen.Set_Help_Sidebar (
           "<p><strong>" & abs "For more information:" & "</strong></p>" &
           "<p>" & abs "<a href=""https://wordpress.org/support/article/managing-plugins/"">Documentation on Managing Plugins</a>" & "</p>" &
           (-Help_Sidebar_Autoupdates) &
           "<p>" & abs "<a href=""https://wordpress.org/support/"">Support</a>" & "</p>"
         );

         Get_Current_Screen.Set_Screen_Reader_Content (
           To_Array_Type ([
             Build ("heading_views",      abs "Filter plugins list"),
             Build ("heading_pagination", abs "Plugins list navigation"),
             Build ("heading_list",       abs "Plugins list")
           ])
         );

         -- Used in the HTML title tag.
         Title       := +abs "Plugins";
         Parent_File := +"plugins.php";

         Adm_Admin_Header.Run;

         declare
            Invalid : constant Error_List := Validate_Active_Plugins;
         begin
            if not Invalid.Is_Empty then
--             for A of Invalid loop
               for A in Invalid.Iterate loop
                  declare
                     Plugin_File : constant String   := Error_Maps.Key     (A);
                     Error       : constant Wp_Error := Error_Maps.Element (A);
                  begin
                     Echo ("<div id=""message"" class=""error""><p>");
                     Printf (
                       -- translators: 1: Plugin file, 2: Error message.
                       abs "The plugin %1s has been deactivated due to an error: %2s",
                       ["<code>" & ESC_HTML (Plugin_File) & "</code>",
                        ESC_HTML (Error.Get_Error_Message)]
                     );
                  end;
                  Echo ("</p></div>");
               end loop;
            end if;
         end;

         if Isset (XX_GET, "error") then

            if Isset (XX_GET, "main") then
               Errmsg := +abs "You cannot delete a plugin while it is active on the main site.";
            elsif Isset (XX_GET, "charsout") then
               Errmsg := +Sprintf (
                 -- translators: %d: Number of characters.
                 X_N (
                   "The plugin generated %d character of <strong>unexpected output</strong> during activation.",
                   "The plugin generated %d characters of <strong>unexpected output</strong> during activation.",
                   As_Integer (Get (XX_GET, "charsout"))
                 ),
                 [Helpers.Image (As_Integer (Get (XX_GET, "charsout")))]
               );
               Append (Errmsg, " " & abs "If you notice &#8220;headers already sent&#8221; messages, problems with syndication feeds or other issues, try deactivating or removing this plugin.");
            elsif "resuming" = Get_As_String (XX_GET, "error") then
               Errmsg := +abs "Plugin could not be resumed because it triggered a <strong>fatal error</strong>.";
            else
               Errmsg := +abs "Plugin could not be activated because it triggered a <strong>fatal error</strong>.";
            end if;

            Echo ("<div id=""message"" class=""error""><p>" & (-Errmsg) & "</p>");

            if
              not Isset (XX_GET, "main") and then
              not Isset (XX_GET, "charsout") and then
              Isset (XX_GET, "_error_nonce") and then
              0 /= Wp_Verify_Nonce (Get_As_String (XX_GET, "_error_nonce"),
                                    "plugin-activation-error_" & Plugin)
            then
               declare
                  IFrame_URL : constant String := Add_Query_Arg (
                    To_Array_Type ([
                      Build ("action",   "error_scrape"),
                      Build ("plugin",   URL_Encode (Plugin)),
                      Build ("_wpnonce",
                             URL_Encode (Get_As_String (XX_GET, "_error_nonce")))
                    ]),
                    Admin_URL ("plugins.php")
                  );
               begin
                  Echo (
                    "<iframe style=""border:0"" width=""100%"" height=""70px"" " &
                    "src=""" & ESC_URL (IFrame_URL) & """></iframe>");
               end;
            end if;

            Echo ("</div>");

         elsif Isset (XX_GET, "deleted") then
            declare
               Delete_Result : constant Multi_Type :=
                 Get_Transient ("plugins_delete_result_" & User_Id);
            begin
               -- Delete it once we're done.
               Delete_Transient ("plugins_delete_result_" & User_Id);

               if False then -- Is_Wp_Error (Delete_Result) then -- XXX

                  Echo ("<div id=""message"" class=""error notice is-dismissible"">");
                  Echo ("        <p>");

                  Printf (
                    -- translators: %s: Error message.
                    abs "Plugin could not be deleted due to an error: %s",
                    [ESC_HTML ("XXX-944")]
--                  [ESC_HTML (Delete_Result.Get_Error_Message)]
                  );

                  Echo ("        </p>");
                  Echo ("</div>");
               else
                  Echo (
                    "<div id=""message"" class=""updated notice is-dismissible"">");
                  Echo ("        <p>");

                  if 1 = As_Integer (Get (XX_GET, "deleted")) then
                     X_E ("The selected plugin has been deleted.");
                  else
                     X_E ("The selected plugins have been deleted.");
                  end if;
                  Echo ("        </p>");
                  Echo ("</div>");
               end if;
            end;

         elsif Isset (XX_GET, "activate") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Plugin activated."); Echo ("</p></div>");

         elsif Isset (XX_GET, "activate-multi") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Selected plugins activated."); Echo ("</p></div>");

         elsif Isset (XX_GET, "deactivate") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Plugin deactivated."); Echo ("</p></div>");

         elsif Isset (XX_GET, "deactivate-multi") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Selected plugins deactivated."); Echo ("</p></div>");

         elsif "update-selected" = Action then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("All selected plugins are up to date."); Echo ("</p></div>");

         elsif Isset (XX_GET, "resume") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Plugin resumed."); Echo ("</p></div>");

         elsif Isset (XX_GET, "enabled-auto-update") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Plugin will be auto-updated."); Echo ("</p></div>");

         elsif Isset (XX_GET, "disabled-auto-update") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Plugin will no longer be auto-updated."); Echo ("</p></div>");

         elsif Isset (XX_GET, "enabled-auto-update-multi") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Selected plugins will be auto-updated."); Echo ("</p></div>");

         elsif Isset (XX_GET, "disabled-auto-update-multi") then
            Echo ("<div id=""message"" class=""updated notice is-dismissible""><p>");
            X_E ("Selected plugins will no longer be auto-updated.");
            Echo ("</p></div>");
         end if;

         Echo ("<div class=""wrap"">");
         Echo ("<h1 class=""wp-heading-inline"">");

         Echo (ESC_HTML (-Title));

         Echo ("</h1>");

         if
           (not Is_Multisite or else Is_Network_Admin) and then
           Current_User_Can ("install_plugins")
         then
            Echo ("<a href=""" & ESC_URL (Self_Admin_URL ("plugin-install.php")) &
            """ class=""page-title-action"">" & ESC_HTML_X ("Add New", "plugin") &
            "</a>");
         end if;

         if Strlen (S) /= 0 then
            Echo ("<span class=""subtitle"">");
            Printf (
              -- translators: %s: Search query.
              abs "Search results for: %s",
              ["<strong>" & ESC_HTML (URL_Decode (S)) & "</strong>"]
            );
            Echo ("</span>");
         end if;

         Echo ("<hr class=""wp-header-end"">");

         --
         -- Fires before the plugins list table is rendered.
         --
         -- This hook also fires before the plugins list table is rendered in the
         -- Network Admin.
         --
         -- Please note: The "active" portion of the hook name does not refer to
         -- whether the current view is for active plugins, but rather all plugins
         -- actively-installed.
         --
         -- @since 3.0.0
         --
         -- @param array[] plugins_all An array of arrays containing information
         --                            on all installed plugins.
         --
         declare
            Plugins : Array_Type;
         begin
            Do_Action ("pre_current_active_plugins", Get_As_String (Plugins, "all"));
         end;

         List_Table.Views;

         Echo ("<form class=""search-form search-plugins"" method=""get"">");
         List_Table.Search_Box (abs "Search Installed Plugins", "plugin");
         Echo ("</form>");

         Echo ("<form method=""post"" id=""bulk-action-form"">");

         Echo ("<input type=""hidden"" name=""plugin_status"" value=""" &
               ESC_Attr (-Globals.Global_Status) & """ />");
         Echo ("<input type=""hidden"" name=""paged"" value=""" &
               ESC_Attr (Helpers.Image (Globals.Global_Page)) & """ />");

         List_Table.Display;
         Echo ("</form>");

         Echo ("  <span class=""spinner""></span>");
         Echo ("</div>");

--         Wp_Print_Request_Filesystem_Credentials_Modal;
--         Wp_Print_Admin_Notice_Templates;
--         Wp_Print_Update_Row_Templates;

         Adm_Admin_Footer.Run;
      end;
   end Render;

end Adm_Plugins;
