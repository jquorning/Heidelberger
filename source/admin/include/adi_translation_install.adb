--
-- WordPress Translation Installation Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.HTML;
with Php.JSON;
with Php.Lists;
with Php.Strings;
with Php.Types;

with Array_Lists;
with Constants;
with Globals;
with Lists;
with UStrings;
with Wp_Common;

with Adi_Class_Language_Pack_Upgraders;
with Adi_Class_Wp_Automatic_Upgrader_Skins;
with Adi_Class_Wp_Upgrader_Skins;

with Inc_Formatting;
with Inc_HTTP;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Versions;

package body Adi_Translation_Install
is
   use Lists;

   ----------------------
   -- Translations_API --
   ----------------------

   function Translations_API (Typ  : String;
                              Args : Array_Type := Empty_Array)
                              return Trans_Result
   is
      use Php.Errors;
      use Php.HTML;
      use Php.JSON;
      use Php.Lists;
      use Php.Strings;
      use Php.Types;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Class_Errors;
      use Inc_HTTP;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Link_Templates;
      use Inc_Versions;
   begin
--    -- Include an unmodified wp_version.
--    require ABSPATH . WPINC . "/version.php";

      if
        not In_List (Typ, List_Type'["plugins", "themes", "core"], True)
      then
         return (Success => False,
                 Arry    => Empty_Array,
                 Error   => X_Construct ("invalid_type",
                                         abs "Invalid translation type."));
      end if;

      --
      -- Allows a plugin to override the WordPress.org Translation Installation
      -- API entirely.
      --
      -- @since 4.0.0
      --
      -- @param false|array result The result array. Default false.
      -- @param string      type   The type of translations being requested.
      -- @param object      args   Translation API arguments.
      --
      declare
         Res : Trans_Result := Apply_Filters ("translations_api", False, Typ, Args);
      begin
         if False = Res.Success then
            declare
               URL : UString :=
                 +"http://api.wordpress.org/translations/" & Typ & "/1.0/";

               HTTP_URL : constant String := -URL;
               SSL      : constant Boolean :=
                 Wp_HTTP_Supports (To_Array_Type ([Build ("ssl", "")]));

               Options : Array_Type := To_Array_Type ([
                 Build ("timeout", 3),
                 Build ("body",    To_Array_Type ([
                   Build ("wp_version", Wp_Version),
                   Build ("locale",     Get_Locale),
                   Build ("version",    Get_As_String (Args, "version"))
                   -- Version of plugin, theme or core.
                 ]))
               ]);
            begin
               if SSL then
                  URL := +Set_URL_Scheme (-URL, "https");
               end if;

               if "core" /= Typ then
                  Set_2 (Options,
                         Key_1 => "body",
                         Key_2 => "slug",
                         Value => From_String (Get_As_String (Args, "slug")));
                         -- Plugin or theme slug.
               end if;

               declare
                  Request : Array_Type := Wp_Remote_Post (-URL, Options);
               begin
                  if SSL and then Is_Wp_Error (Request) then
                     Trigger_Error (
                       Sprintf (
                         -- translators: %s: Support forums URL.
                         abs "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href=""%s"">support forums</a>.",
                         [1 => abs "https://wordpress.org/support/forums/"]
                       ) & " " & abs "(WordPress could not establish a secure connection to WordPress.org. Please contact your server administrator.)",
                       (if Headers_Sent or else Constants.WP_DEBUG
                        then E_USER_WARNING
                        else E_USER_NOTICE)
                     );

                     Request := Wp_Remote_Post (HTTP_URL, Options);
                  end if;

                  if Is_Wp_Error (Request) then
                     Res.Error := X_Construct ( -- new Wp_Error (
                       "translations_api_failed",
                       Sprintf (
                         -- translators: %s: Support forums URL.
                         abs "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href=""%s"">support forums</a>.",
                         [1 => abs "https://wordpress.org/support/forums/"]
                       ),
                       "XXX-976" -- Request.Get_Error_Message
                     );
                  else
                     Res.Arry :=
                       JSON_Decode (
                         Wp_Remote_Retrieve_Body (Request), True);

                     if
                       not Is_Object (Res.Arry) and then
                       not Is_Array (Res.Arry)
                     then
                        Res.Error := X_Construct ( --  := new Wp_Error (
                          "translations_api_failed",
                          Sprintf (
                            -- translators: %s: Support forums URL.
                            abs "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href=""%s"">support forums</a>.",
                            [1 => abs "https://wordpress.org/support/forums/"]
                          ),
                          Wp_Remote_Retrieve_Body (Request)
                        );
                     end if;
                  end if;
               end;
            end;
         end if;

         --
         -- Filters the Translation Installation API response results.
         --
         -- @since 4.0.0
         --
         -- @param array|WP_Error res  Response as an associative array or WP_Error.
         -- @param string         type The type of translations being requested.
         -- @param object         args Translation API arguments.
         --
         return Apply_Filters ("translations_api_result", Res, Typ, Args);
      end;
   end Translations_API;

   -----------------------------------
   -- Wp_Get_Available_Translations --
   -----------------------------------

   function Wp_Get_Available_Translations
            return Array_Type
   is
      use Array_Lists;
      use Inc_Load;
      use Inc_Options;
      use Inc_Versions;
   begin
      if not Wp_Installing then
         declare
            Translations : Array_Type; --  :=
--            Get_Site_Transient ("available_translations");
         begin
            if not Translations.Is_Empty then -- false
               return Translations;
            end if;
         end;
      end if;

--      -- Include an unmodified wp_version.
--      require ABSPATH . WPINC . "/version.php";

      declare
         API : constant Trans_Result := -- Array_Type :=
           Translations_API ("core", To_Array_Type ([
                                       Build ("version", Wp_Version)]));
      begin
         if
           Is_Wp_Error (API.Arry) or else
           Empty (API.Arry, "translations")
         then
            return Empty_Array;
         end if;

         declare
            Translations : Array_Type;
         begin
            -- Key the array with the language code for now.
            for A in As_Array (Get (API.Arry, "translations")).Iterate loop
               declare
                  Translation : constant Multi_Type := Element (A);
               begin
                  Set (Translations,
                       Get_As_String (As_Array (Translation), "language"),
                       Translation);
               end;
            end loop;

            if not Globals.WP_INSTALLING then
--          if not Defined ("WP_INSTALLING") then
               Set_Site_Transient ("available_translations", Translations,
                                   3 * Constants.HOUR_IN_SECONDS);
            end if;

            return Translations;
         end;
      end;
   end Wp_Get_Available_Translations;

   ------------------------------
   -- Wp_Install_Language_Form --
   ------------------------------

   procedure Wp_Install_Language_Form (Languages : Array_Type)
   is
      use Php.Arrays;
      use Php.Echoing;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Inc_Formatting;
      use Inc_L10n;

      Wp_Local_Package : UString
        renames Global_Wp_Local_Package;

      Installed_Languages : constant Array_Type := Get_Available_Languages;
   begin
      Echo ("<label class=""screen-reader-text"" for=""language"">Select a default language</label>" & NL);
      Echo ("<select size=""14"" name=""language"" id=""language"">" & NL);
      Echo ("<option value="""" lang=""en"" selected=""selected"" data-continue=""Continue"" data-installed=""1"">English (United States)</option>");
      Echo (NL);

      if
        not Empty (-Wp_Local_Package) and then
        Isset (Languages, -Wp_Local_Package)
      then
         if Isset (Languages, -Wp_Local_Package) then
            declare
               Language : constant Array_Type :=
                 As_Array (Get (Languages, -Wp_Local_Package));
            begin
               Printf (
                 "<option value=""%s"" lang=""%s"" data-continue=""%s""%s>%s</option>" & NL,
                 [
                   1 => ESC_Attr (Get_As_String (Language, "language")),
                   2 => ESC_Attr (Get_As_String (Language, "iso")), -- current
                   3 => ESC_Attr (if As_Boolean (Get (Ref_2 (Language,
                                                             Key_1 => "strings",
                                                             Key_2 => "continue")))
                                  then As_String (Get (Ref_2 (Language,
                                                              Key_1 => "strings",
                                                              Key_2 => "continue")))
                                  else "Continue"),
                   4 => (if In_Array (Get_As_String (Language, "language"),
                                      Installed_Languages, True)
                         then " data-installed=""1""" else ""),
                   5 => ESC_HTML (Get_As_String (Language, "native_name"))
                 ]
               );
            end;
            Delete (Ref (Languages, -Wp_Local_Package));
         end if;
      end if;

      for A in Languages.Iterate loop
         declare
            Language : constant Array_Type := As_Array (Element (A));
         begin
            Printf (
              "<option value=""%s"" lang=""%s"" data-continue=""%s""%s>%s</option>" & NL,
              [
                1 => ESC_Attr (Get_As_String (Language, "language")),
                2 => ESC_Attr (Get_As_String (Language, "iso")), -- current
                3 => ESC_Attr
                       (if As_Boolean (Get (Ref_2 (Language, "strings", "continue")))
                        then As_String (Get (Ref_2 (Language, "strings", "continue")))
                        else "Continue"),
                4 => (if In_Array (Get_As_String (Language, "language"),
                                   Installed_Languages, True)
                      then " data-installed=""1""" else ""),
                5 => ESC_HTML (Get_As_String (Language, "native_name"))
              ]
            );
         end;
      end loop;
      Echo ("</select>" & NL);
      Echo ("<p class=""step""><span class=""spinner""></span><input id=""language-continue"" type=""submit"" class=""button button-primary button-large"" value=""Continue"" /></p>");
   end Wp_Install_Language_Form;

   -------------------------------
   -- Wp_Download_Language_Pack --
   -------------------------------

   function Wp_Download_Language_Pack (Download : String)
                                       return String
   is
      use Php.Arrays;
      use Array_Lists;
      use Adi_Class_Language_Pack_Upgraders;
      use Adi_Class_Wp_Automatic_Upgrader_Skins;
      use Adi_Class_Wp_Upgrader_Skins;
      use Inc_Load;
      use Inc_L10n;
   begin
      -- Check if the translation is already installed.
      if In_Array (Download, Get_Available_Languages, True) then
         return Download;
      end if;

      if not Wp_Is_File_Mod_Allowed ("download_language_pack") then
         return ""; -- false
      end if;

      -- Confirm the translation is one we can download.
      declare
         Translations : constant Array_Type := Wp_Get_Available_Translations;
         Translation_To_Load : Boolean := False;
         Trans : Multi_Type; -- added
      begin
         if Translations.Is_Empty then
            return ""; -- false
         end if;

         for A in Translations.Iterate loop
            declare
               Translation : constant Multi_Type := Element (A);
            begin
               if Get_As_String (As_Array (Translation), "language") = Download then
                  Translation_To_Load := True;
                  Trans := Translation;
                  exit;
               end if;
            end;
         end loop;

         if not Translation_To_Load then
            return ""; -- false
         end if;

         declare
--          Translation := (object) Translation;
            Translation : constant Multi_Type := Trans;

--          require_once ABSPATH . "wp-admin/includes/class-wp-upgrader.php";
            Skin : constant Automatic_Upgrader_Skin :=
              X_Construct;

            Upgrader : constant Language_Pack_Upgrader  :=
              X_Construct (Adi_Class_Wp_Upgrader_Skins.Wp_Upgrader_Skin (Skin));
         begin
--          Translation.Typ := +"core";
            declare
               Result : constant Array_Type :=
                 Upgrader.Upgrade (As_String (Translation),
                                   To_Array_Type ([
                                     Build ("clear_update_cache", False)
                                   ]));
            begin
               if
                 Result = Empty_Array or else   -- not
                 Is_Wp_Error (Result)
               then
                  return ""; -- false
               end if;

--             return Translation.Language;
               return "XXX-975";
            end;
         end;
      end;
   end Wp_Download_Language_Pack;

   ----------------------------------
   -- Wp_Can_Install_Language_Pack --
   ----------------------------------

   function Wp_Can_Install_Language_Pack
            return Boolean
   is
      use UStrings;
      use Adi_Class_Language_Pack_Upgraders;
      use Adi_Class_Wp_Automatic_Upgrader_Skins;
      use Adi_Class_Wp_Upgrader_Skins;
      use Inc_Load;
   begin
      if not Wp_Is_File_Mod_Allowed ("can_install_language_pack") then
         return False;
      end if;

      declare
--       require_once ABSPATH . "wp-admin/includes/class-wp-upgrader.php";
         Skin : constant Automatic_Upgrader_Skin :=
           X_Construct;

         Upgrader : Language_Pack_Upgrader  :=
           X_Construct (Wp_Upgrader_Skin (Skin));
      begin
         Upgrader.Init;
         declare
            Check : constant Boolean :=
              Upgrader.FS_Connect (List_Type'[-Globals.WP_CONTENT_DIR,
                                              Constants.WP_LANG_DIR]);
         begin
            if not Check or else Is_Wp_Error (Check) then
               return False;
            end if;
         end;
      end;

      return True;
   end Wp_Can_Install_Language_Pack;

end Adi_Translation_Install;
