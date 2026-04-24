--
-- WordPress Theme Administration API
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

with Arrays.IO;
with Array_Lists;
with Binder;
with Constants;
with Lists;
with Logging;
with Wp_Common;

with Adi_Update;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_HTTP;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Themes;

package body Adi_Themes
is
   use Lists;

   ------------------
   -- Delete_Theme --
   ------------------

   function Delete_Theme (Stylesheet : String;
                          Redirect   : String := "")
                          return Bool_Error_Type
   is (raise Program_Error with "not implemented");

   procedure Delete_Theme (Stylesheet : String;
                           Redirect   : String := "")
   is
      Unused : constant Bool_Error_Type :=
        Delete_Theme (Stylesheet, Redirect);
   begin
      null;
   end Delete_Theme;

--         global wp_filesystem;

--         if ( empty( stylesheet ) ) then
--                 return false;
--         end;

--         if ( empty( redirect ) ) then
--                 redirect = wp_nonce_url( "themes.php?action=delete&stylesheet=" . urlencode( stylesheet ), "delete-theme_" . stylesheet );
--         end;

--         ob_start();
--         credentials = request_filesystem_credentials( redirect );
--         data        = ob_get_clean();

--         if ( false === credentials ) then
--                 if ( ! empty( data ) ) then
--                         require_once ABSPATH . "wp-admin/admin-header.php";
--                         echo data;
--                         require_once ABSPATH . "wp-admin/admin-footer.php";
--                         exit;
--                 end;
--                 return;
--         end;

--         if ( ! WP_Filesystem( credentials ) ) then
--                 ob_start();
--                 // Failed to connect. Error and request again.
--                 request_filesystem_credentials( redirect, "", true );
--                 data = ob_get_clean();

--                 if ( ! empty( data ) ) then
--                         require_once ABSPATH . "wp-admin/admin-header.php";
--                         echo data;
--                         require_once ABSPATH . "wp-admin/admin-footer.php";
--                         exit;
--                 end;
--                 return;
--         end;

--         if ( ! is_object( wp_filesystem ) ) then
--                 return new WP_Error( "fs_unavailable", __( "Could not access filesystem." ) );
--         end;

--         if ( is_wp_error( wp_filesystem.errors ) && wp_filesystem.errors.has_errors() ) then
--                 return new WP_Error( "fs_error", __( "Filesystem error." ), wp_filesystem.errors );
--         end;

--         // Get the base theme folder.
--         themes_dir = wp_filesystem.wp_themes_dir();
--         if ( empty( themes_dir ) ) then
--                 return new WP_Error( "fs_no_themes_dir", __( "Unable to locate WordPress theme directory." ) );
--         end;

--         --
--         -- Fires immediately before a theme deletion attempt.
--         --
--         -- @since 5.8.0
--         --
--         -- @param string stylesheet Stylesheet of the theme to delete.
--         --
--         do_action( "delete_theme", stylesheet );

--         theme = wp_get_theme( stylesheet );
--
--         themes_dir = trailingslashit( themes_dir );
--         theme_dir  = trailingslashit( themes_dir . stylesheet );
--         deleted    = wp_filesystem.delete( theme_dir, true );

--         --
--         -- Fires immediately after a theme deletion attempt.
--         --
--         -- @since 5.8.0
--         --
--         -- @param string stylesheet Stylesheet of the theme to delete.
--         -- @param bool   deleted    Whether the theme deletion was successful.
--         --
--         do_action( "deleted_theme", stylesheet, deleted );

--         if ( ! deleted ) then
--                 return new WP_Error(
--                         "could_not_remove_theme",
--                         /* translators: %s: Theme name.--
--                         sprintf( __( "Could not fully remove the theme %s." ), stylesheet )
--                 );
--         end;

--         theme_translations = wp_get_installed_translations( "themes" );

--         // Remove language files, silently.
--         if ( ! empty( theme_translations[ stylesheet ] ) ) then
--                 translations = theme_translations[ stylesheet ];

--                 foreach ( translations as translation => data ) then
--                         wp_filesystem.delete( WP_LANG_DIR . "/themes/" . stylesheet . "-" . translation . ".po" );
--                         wp_filesystem.delete( WP_LANG_DIR . "/themes/" . stylesheet . "-" . translation . ".mo" );
--                         wp_filesystem.delete( WP_LANG_DIR . "/themes/" . stylesheet . "-" . translation . ".l10n.php" );

--                         json_translation_files = glob( WP_LANG_DIR . "/themes/" . stylesheet . "-" . translation . "-*.json" );
--                         if ( json_translation_files ) then
--                                 array_map( array( wp_filesystem, "delete" ), json_translation_files );
--                         end;
--                 end;
--         end;

--         // Remove the theme from allowed themes on the network.
--         if ( is_multisite() ) then
--                 WP_Theme::network_disable_theme( stylesheet );
--         end;

--         // Clear theme caches.
--         theme.cache_delete();
--
--         // Force refresh of theme update information.
--         delete_site_transient( "update_themes" );

--         return true;
-- end;

-- --
-- -- Gets the page templates available in this theme.
-- --
-- -- @since 1.5.0
-- -- @since 4.7.0 Added the `post_type` parameter.
-- --
-- -- @param WP_Post|null post      Optional. The post being edited, provided for context.
-- -- @param string       post_type Optional. Post type to get the templates for. Default "page".
-- -- @return string[] Array of template file names keyed by the template header name.
-- --
-- function get_page_templates( post = null, post_type = "page" ) then
--         return array_flip( wp_get_theme().get_page_templates( post, post_type ) );
-- end;

-- --
-- -- Tidies a filename for url display by the theme file editor.
-- --
-- -- @since 2.9.0
-- -- @access private
-- --
-- -- @param string fullpath Full path to the theme file
-- -- @param string containingfolder Path of the theme parent folder
-- -- @return string
-- --
-- function _get_template_edit_filename( fullpath, containingfolder ) then
--         return str_replace( dirname( containingfolder, 2 ), "", fullpath );
-- end;

   ----------------------------
   -- Theme_Update_Available --
   ----------------------------

   procedure Theme_Update_Available (Theme : in out Class_Themes.Wp_Theme) is
      use Php.Echoing;
   begin
      Echo (Get_Theme_Update_Available (Theme));
   end Theme_Update_Available;

   --------------------------------
   -- Get_Theme_Update_Available --
   --------------------------------

   Static_Themes_Update : Array_Type := Empty_Array;

   function Get_Theme_Update_Available
     (Theme : in out Class_Themes.Wp_Theme) return String
   is
      use Php.HTML;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Link_Templates;
      use Inc_L10n;

      Themes_Update : Array_Type renames Static_Themes_Update;
   begin
      if not Current_User_Can ("update_themes") then
         return ""; -- False

      end if;

      if Themes_Update = Empty_Array then
         -- if not Isset (Themes_Update) then
         Themes_Update := Empty_Array; -- As_Array (Get_Site_Transient ("update_themes"));
      end if;

      -- if not ( theme instanceof WP_Theme ) then
      --    return False;
      -- end if;

      declare
         Stylesheet : constant String := Theme.Get_Stylesheet;

         HTML : UString;
      begin
         if False then -- Isset (As_Array (Get (Themes_Update, "response")), Stylesheet) then
            declare
               Update : constant Array_Type :=
                 As_Array
                   (Get
                      (As_Array (Get (Themes_Update, "response")),
                       Stylesheet));

               Theme_Name : constant String := Theme.Display ("Name");

               Details_URL : constant String :=
                 Add_Query_Arg
                   (To_Array_Type
                      ([Build ("TB_iframe", "true"),
                        Build ("width", 1024),
                        Build ("height", 800)]),
                    Get_As_String
                      (Update,
                       "url")); -- Theme browser inside WP? Replace this. Also, theme preview JS will override this on the available list.

               Update_URL : constant String :=
                 Wp_Nonce_URL
                   (Admin_URL
                      ("update.php?action=upgrade-theme&amp;theme="
                       & URL_Encode (Stylesheet)),
                    "upgrade-theme_" & Stylesheet);
            begin
               if not Is_Multisite then
                  if not Current_User_Can ("update_themes") then
                     HTML :=
                       +Sprintf
                          (
                           -- translators: 1: Theme name, 2: Theme details URL, 3: Additional link attributes, 4: Version number.
                           "<p><strong>"
                           & abs "There is a new version of %1s available. <a href=""%2s"" %3s>View version %4s details</a>."
                           & "</strong></p>",
                           [1 => Theme_Name,
                            2 => ESC_URL (Details_URL),
                            3 =>
                              Sprintf
                                ("class=""thickbox open-plugin-details-modal"" aria-label=""%s""",
                                 -- translators: 1: Theme name, 2: Version number.
                                 [1 =>
                                    ESC_Attr
                                      (Sprintf
                                         (abs "View %1s version %2s details",
                                          [1 => Theme_Name,
                                           2 =>
                                             Get_As_String
                                               (Update, "new_version")]))]),
                            4 => Get_As_String (Update, "new_version")]);

                  elsif Empty (Update, "package") then
                     HTML :=
                       +Sprintf
                          (
                           -- translators: 1: Theme name, 2: Theme details URL, 3: Additional link attributes, 4: Version number.
                           "<p><strong>"
                           & abs "There is a new version of %1s available. <a href=""%2s"" %3s>View version %4s details</a>. <em>Automatic update is unavailable for this theme.</em>"
                           & "</strong></p>",
                           [1 => Theme_Name,
                            2 => ESC_URL (Details_URL),
                            3 =>
                              Sprintf
                                ("class=""thickbox open-plugin-details-modal"" aria-label=""%s""",
                                 -- translators: 1: Theme name, 2: Version number.
                                 [ESC_Attr
                                    (Sprintf
                                       (abs "View %1s version %2s details",
                                        [1 => Theme_Name,
                                         2 =>
                                           Get_As_String
                                             (Update, "new_version")]))]),
                            4 => Get_As_String (Update, "new_version")]);
                  else
                     HTML :=
                       +Sprintf
                          (
                           -- translators: 1: Theme name, 2: Theme details URL, 3: Additional link attributes, 4: Version number, 5: Update URL, 6: Additional link attributes.
                           "<p><strong>"
                           & abs "There is a new version of %1s available. <a href=""%2s"" %3s>View version %4s details</a> or <a href=""%5s"" %6s>update now</a>."
                           & "</strong></p>",
                           [1 => Theme_Name,
                            2 => ESC_URL (Details_URL),
                            3 =>
                              Sprintf
                                ("class=""thickbox open-plugin-details-modal"" aria-label=""%s""",
                                 -- translators: 1: Theme name, 2: Version number.
                                 [ESC_Attr
                                    (Sprintf
                                       (abs "View %1s version %2s details",
                                        [1 => Theme_Name,
                                         2 =>
                                           Get_As_String
                                             (Update, "new_version")]))]),
                            4 => Get_As_String (Update, "new_version"),
                            5 => Update_URL,
                            6 =>
                              Sprintf
                                ("aria-label=""%s"" id=""update-theme"" data-slug=""%s""",
                                 -- translators: %s: Theme name.
                                 [1 =>
                                    ESC_Attr
                                      (Sprintf
                                         (X_X ("Update %s now", "theme"),
                                          [1 => Theme_Name])),
                                  2 => Stylesheet])]);
                  end if;
               end if;
            end;
         end if;

         return -HTML;
      end;
   end Get_Theme_Update_Available;

   ----------------------------
   -- Get_Theme_Feature_List --
   ----------------------------

   function Get_Theme_Feature_List (API : Boolean := True) return Array_Type is
      use Array_Lists;
      use Inc_Capabilities;
      use Adi_Themes.Theme_API_Lists;
      use Inc_L10n;
      use Inc_Options;

      -- Hard-coded list is used if API is not accessible.
      Features : constant Array_Type :=
        To_Array_Type
          ([Build
              (abs "Subject",
               To_Array_Type
                 ([Build ("blog", abs "Blog"),
                   Build ("e-commerce", abs "E-Commerce"),
                   Build ("education", abs "Education"),
                   Build ("entertainment", abs "Entertainment"),
                   Build ("food-and-drink", abs "Food & Drink"),
                   Build ("holiday", abs "Holiday"),
                   Build ("news", abs "News"),
                   Build ("photography", abs "Photography"),
                   Build ("portfolio", abs "Portfolio")])),

            Build
              (abs "Features",
               To_Array_Type
                 ([Build ("accessibility-ready", abs "Accessibility Ready"),
                   Build ("block-patterns", abs "Block Editor Patterns"),
                   Build ("block-styles", abs "Block Editor Styles"),
                   Build ("custom-background", abs "Custom Background"),
                   Build ("custom-colors", abs "Custom Colors"),
                   Build ("custom-header", abs "Custom Header"),
                   Build ("custom-logo", abs "Custom Logo"),
                   Build ("editor-style", abs "Editor Style"),
                   Build
                     ("featured-image-header", abs "Featured Image Header"),
                   Build ("featured-images", abs "Featured Images"),
                   Build ("footer-widgets", abs "Footer Widgets"),
                   Build ("full-site-editing", abs "Site Editor"),
                   Build ("full-width-template", abs "Full Width Template"),
                   Build ("post-formats", abs "Post Formats"),
                   Build ("sticky-post", abs "Sticky Post"),
                   Build ("style-variations", abs "Style Variations"),
                   Build ("template-editing", abs "Template Editing"),
                   Build ("theme-options", abs "Theme Options")])),

            Build
              (abs "Layout",
               To_Array_Type
                 ([Build ("grid-layout", abs "Grid Layout"),
                   Build ("one-column", abs "One Column"),
                   Build ("two-columns", abs "Two Columns"),
                   Build ("three-columns", abs "Three Columns"),
                   Build ("four-columns", abs "Four Columns"),
                   Build ("left-sidebar", abs "Left Sidebar"),
                   Build ("right-sidebar", abs "Right Sidebar"),
                   Build ("wide-blocks", abs "Wide Blocks")]))

           ]);
   begin
      if not API or else not Current_User_Can ("install_themes") then
         return Features;
      end if;

      declare
         Feature_List : Theme_API_List := -- API_Result_Type := -- Array_Type :=
           Get_Site_Transient ("wporg_theme_feature_list");
      begin
         if Feature_List.Is_Empty then
            Set_Site_Transient
              ("wporg_theme_feature_list",
               Empty_Array,
               3 * Constants.HOUR_IN_SECONDS);
         end if;

         if Feature_List.Is_Empty then
            declare
               Result : constant Themes_API_Result :=
                 Themes_API ("feature_list", Empty_Themes_API_Args);
            begin
               if not Result.Success then
                  -- Is_Wp_Error (Feature_List) then
                  return Features;
               end if;
               Feature_List := Result.Themes; -- Arry;
            end;
         end if;

         if Feature_List.Is_Empty then
            return Features;
         end if;

         Set_Site_Transient
           ("wporg_theme_feature_list",
            Feature_List,
            3 * Constants.HOUR_IN_SECONDS);

         declare
            Category_Translations : constant Array_Type :=
              To_Array_Type
                ([Build ("Layout", abs "Layout"),
                  Build ("Features", abs "Features"),
                  Build ("Subject", abs "Subject")]);

            Wporg_Features : Array_Type;
         begin
            -- Loop over the wp.org canonical list and apply translations.
            for A in Feature_List.Iterate loop
               declare
                  Feature_Category_2 : constant String := Key (A);

                  Feature_Items : constant Array_Type :=
                    To_Array (Element (A));

                  Feature_Category : constant String :=
                    (if Isset (Category_Translations, Feature_Category_2)
                     then
                       Get_As_String
                         (Category_Translations, Feature_Category_2)
                     else Feature_Category_2);
               begin
                  Set
                    (Wporg_Features,
                     Key   => Feature_Category,
                     Value => From_Array (Empty_Array));

                  for F in Feature_Items.Iterate loop
                     declare
                        Feature : constant String := Key (F);
                     begin
                        if Isset_2 (Features, Feature_Category, Feature) then
                           Set_2
                             (Wporg_Features,
                              Key_1 => Feature_Category,
                              Key_2 => Feature,
                              Value =>
                                Get
                                  (Ref_2
                                     (Features,
                                      Key_1 => Feature_Category,
                                      Key_2 => Feature)));
                        else
                           Set_2
                             (Wporg_Features,
                              Key_1 => Feature_Category,
                              Key_2 => Feature,
                              Value => From_String (Feature));
                        end if;
                     end;
                  end loop;
               end;
            end loop;

            return Wporg_Features;
         end;
      end;
   end Get_Theme_Feature_List;

   ----------------
   -- Themes_API --
   ----------------

   function Themes_API
     (Action : String; Args : Themes_API_Args := Empty_Themes_API_Args)
      return Themes_API_Result
   is
      use Php.Errors;
      use Php.HTML;
      use Php.JSON;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Adi_Themes.Theme_API_Lists;
      use Inc_Functions;
      use Inc_HTTP;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;

      Args_2 : Themes_API_Args := Args;
   begin
      -- if Is_Array (Args) then
      --    Args := (object) args;
      -- end if;

      if "query_themes" = Action then
         if Args_2.Per_Page = 0 then
            -- if not Isset (Args_2.Per_Page) then
            Args_2.Per_Page := 24;
         end if;
      end if;

      if Args_2.Locale = "" then
         -- if not Isset (Args_2.Locale) then
         Args_2.Locale := +Get_User_Locale;
      end if;

      -- if Args_2.Wp_Version = "" then
      -- -- if not isset (Args_2.Wp_Version) then
      --    Args_2.Wp_Version := Substr (Wp_Get_Wp_Version, 0, 3); -- x.y

      -- end if;
      declare
         --
         -- Filters arguments used to query for installer pages from the WordPress.org Themes API.
         --
         -- Important: An object MUST be returned to this filter.
         --
         -- @since 2.8.0
         --
         -- @param object args   Arguments used to query for installer pages from the WordPress.org Themes API.
         -- @param string action Requested action. Likely values are "theme_information",
         --                       "feature_list", or "query_themes".
         --
         Args_3 : constant Themes_API_Args :=
           Apply_Filters ("themes_api_args", Args_2, Action);

         --
         -- Filters whether to override the WordPress.org Themes API.
         --
         -- Returning a non-false value will effectively short-circuit the WordPress.org API request.
         --
         -- If `action` is "query_themes", "theme_information", or "feature_list", an object MUST
         -- be passed. If `action` is "hot_tags", an array should be passed.
         --
         -- @since 2.8.0
         --
         -- @param false|object|array override Whether to override the WordPress.org Themes API. Default false.
         -- @param string             action   Requested action. Likely values are "theme_information",
         --                                    "feature_list", or "query_themes".
         -- @param object             args     Arguments used to query for installer pages from the Themes API.
         --
         Res : Themes_API_Result :=
           Apply_Filters
             ("themes_api",
              Empty_Themes_API_Result, -- False,
              Action,
              Args_3);
      begin
         if not Res.Success then
            -- if not Res then
            declare
               URL_3 : constant String :=
                 "http://api.wordpress.org/themes/info/1.2/";

               URL_2 : constant String :=
                 Add_Query_Arg
                   (To_Array_Type
                      ([Build ("action", Action),
                        Build ("request", To_Array (Args_3))]),
                    URL_3);

               HTTP_URL : constant String := URL_2;

               SSL : constant Boolean := Wp_HTTP_Supports (Build ("ssl", ""));

               URL : constant String :=
                 (if SSL then Set_URL_Scheme (URL_2, "https") else URL_2);

               HTTP_Args : constant Array_Type :=
                 To_Array_Type
                   ([Build ("timeout", 15),
                     Build
                       ("user-agent",
                        "WordPress/"
                        & Wp_Get_Wp_Version
                        & "; "
                        & Home_URL ("/"))]);

               Request : Array_Error_Type := Wp_Remote_Get (URL, HTTP_Args);
            begin
               if SSL and then not Request.Success then
                  -- if SSL and then Is_Wp_Error (Request) then
                  if not Wp_Doing_AJAX then
                     Wp_Trigger_Error
                       ("__FUNCTION__",
                        Sprintf
                          (
                           -- translators: %s: Support forums URL.
                           abs "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href=""%s"">support forums</a>.",
                           [abs "https://wordpress.org/support/forums/"])
                        & " "
                        & abs "(WordPress could not establish a secure connection to WordPress.org. Please contact your server administrator.)",
                        (if Headers_Sent or else Constants.WP_DEBUG
                         then E_USER_WARNING
                         else E_USER_NOTICE));
                  end if;
                  Request := Wp_Remote_Get (HTTP_URL, HTTP_Args);
               end if;

               if not Request.Success then
                  -- if Is_Wp_Error (Request) then
                  Res.Error :=
                    Class_Errors.X_Construct
                      ( -- new WP_Error(
                       "themes_api_failed",
                       Sprintf
                         (
                          -- translators: %s: Support forums URL.
                          abs "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href=""%s"">support forums</a>.",
                          [abs "https://wordpress.org/support/forums/"]),
                       Request.Error.Get_Error_Message);
               else
                  declare
                     Res2 : constant Multi_Type :=
                       JSON_Decode
                         (Wp_Remote_Retrieve_Body (Request.Arry),
                          Associative => True);
                  begin
                     if Is_Array (Res2) then
                        -- Object casting is required in order to match the info/1.0 format.
                        null; -- res := (object) res;

                     elsif Is_Null (Res2) then
                        Res.Error :=
                          Class_Errors.X_Construct
                            ( -- new WP_Error(
                             "themes_api_failed",
                             Sprintf
                               (
                                -- translators: %s: Support forums URL.
                                abs "An unexpected error occurred. Something may be wrong with WordPress.org or this server&#8217;s configuration. If you continue to have problems, please try the <a href=""%s"">support forums</a>.",
                                [abs "https://wordpress.org/support/forums/"]),
                             Wp_Remote_Retrieve_Body (Request.Arry));
                     end if;

                     if not Res.Success then
                        -- if Isset (Res.Error) then
                        Res.Error :=
                          Class_Errors.X_Construct
                            ("themes_api_failed", "XXX-E03"); -- Res2.Error);
                     -- Res := new WP_Error ("themes_api_failed", Res.Error);

                     end if;
                  end;
               end if;
            end;

            if not Res.Success then
               -- if not Is_Wp_Error (Res) then
               -- Back-compat for info/1.2 API, upgrade the theme objects in query_themes to objects.
               if "query_themes" = Action then
                  for A in Res.Themes.Iterate loop
                     declare
                        I     : constant String := Key (A);
                        Theme : constant Theme_API_Type := Element (A);
                     begin
                        Res.Themes.Insert (I, Theme); -- (object) theme;
                     -- Set (Res.Themes, I, From_Array (To_Array (Theme))); -- (object) theme;
                     -- Set (Res.Themes, I, Theme); -- (object) theme;
                     end;
                  end loop;
               end if;

               -- Back-compat for info/1.2 API, downgrade the feature_list result back to an array.
               if "feature_list" = Action then
                  null; -- Res := Res; -- (array) res;

               end if;
            end if;
         end if;

         --
         -- Filters the returned WordPress.org Themes API response.
         --
         -- @since 2.8.0
         --
         -- @param array|stdClass|WP_Error res    WordPress.org Themes API response.
         -- @param string                  action Requested action. Likely values are "theme_information",
         --                                        "feature_list", or "query_themes".
         -- @param stdClass                args   Arguments used to query for installer pages from the WordPress.org Themes API.
         --
         return Apply_Filters ("themes_api_result", Res, Action, Args_3);
      end;
   end Themes_API;

   ------------------------------
   -- Wp_Prepare_Themes_For_JS --
   ------------------------------

   function Wp_Prepare_Themes_For_JS
     (Themes : Class_Themes.Theme_Array := Class_Themes.Empty_Theme_Array)
      return Array_Type
   is
      use Php.Arrays;
      use Php.HTML;
      use Php.Lists;
      use Array_Lists;
      use Binder;
      use Wp_Common;
      use Class_Themes;
      use Class_Themes.Theme_Maps;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_Options;
      use Inc_Themes;

      --
      -- Builds the customize action URL, or "" if not applicable.
      --
      function Build_Customize_Action
        (Slug : String; Is_Block : Boolean; Is_Active : Boolean) return String;

      --
      -- Process one theme slug: build its data record and add to
      -- Prepared_Themes.
      --
      --      procedure Process_Theme (Slug : String);

      Current_Theme : constant String := Get_Stylesheet;

      Themes_2 : Theme_Array := Themes;
      -- Themes_Dir : constant String := -Globals.WP_CONTENT_DIR & "/themes";

      Can_Switch : constant Boolean := Current_User_Can ("switch_themes");

      Can_Delete : constant Boolean :=
        not Is_Multisite and then Current_User_Can ("delete_themes");

      Can_Customize : constant Boolean := Current_User_Can ("customize");

      Can_Edit : constant Boolean := Current_User_Can ("edit_theme_options");

      Can_Update : constant Boolean := Current_User_Can ("update_themes");

      Auto_Enabled : constant Boolean :=
        Adi_Update.Wp_Is_Auto_Update_Enabled_For_Type ("theme")
        and then not Is_Multisite
        and then Can_Update;

      Auto_Updates : constant List_Type :=
        As_List
          (Get_Site_Option ("auto_update_themes", From_Array (Empty_Array)));

      Request_URI : constant String :=
        Sanitize_URL (Wp_Unslash (Get_As_String (X_SERVER, "REQUEST_URI")));

      Prepared_Themes : Array_Type := Empty_Array;
      Parents         : Array_Type := Empty_Array;

      ----------------------------
      -- Build_Customize_Action --
      ----------------------------

      function Build_Customize_Action
        (Slug : String; Is_Block : Boolean; Is_Active : Boolean) return String
      is
         Return_Param : constant Array_Type :=
           To_Array_Type
             ([Build
                 ("return",
                  URL_Encode
                    (Remove_Query_Arg
                       (Wp_Removable_Query_Args, Request_URI)))]);
      begin
         if Is_Block and then Can_Edit then
            declare
               Base : constant String :=
                 (if Is_Active
                  then Admin_URL ("site-editor.php")
                  else
                    Add_Query_Arg
                      ("wp_theme_preview",
                       Slug,
                       Admin_URL ("site-editor.php")));
            begin
               return ESC_URL (Add_Query_Arg (Return_Param, Base));
            end;
         elsif not Is_Block and then Can_Customize and then Can_Edit then
            return
              ESC_URL (Add_Query_Arg (Return_Param, Wp_Customize_URL (Slug)));
         end if;
         return "";
      end Build_Customize_Action;

   begin
      Logging.Log ("wp_prepare_themes_for_js", Themes'Image);

      --
      -- Filters theme data before it is prepared for JavaScript.
      --
      -- Passing a non-empty array will result in wp_prepare_themes_for_js()
      -- returning early with that value instead.
      --
      -- @since 4.2.0
      --
      -- @param array           prepared_themes An associative array of
      --                                        theme data. Default empty
      --                                        array.
      -- @param WP_Theme[]|null themes          An array of theme objects to
      --                                        prepare, if any.
      -- @param string          current_theme   The active theme slug.
      --
      Prepared_Themes :=
        Apply_Filters
          ("pre_prepare_themes_for_js", Empty_Array, Themes_2, Current_Theme);

      if not Empty (Prepared_Themes) then
         return Prepared_Themes;
      end if;

      -- Ensure current theme entry exists first (for ordering).
      Set (Prepared_Themes, Current_Theme, From_Array (Empty_Array));

      if Themes_2 = Empty_Theme_Array then
         Themes_2 := Wp_Get_Themes (To_Array_Type ([Build ("allowed", True)]));
         if not Themes_2.Contains (Current_Theme) then
         -- if not Isset (Themes_2, Current_Theme) then
            Logging.Log ("wp_prepare_themes_for_js", "not implemented");
            Logging.Log ("wp_prepare_themes_for_js", Wp_Get_Theme'Image);

            Themes_2.Include (Current_Theme, Wp_Get_Theme);
         end if;
      end if;

      -- declare
      --    Updates    : Array_Type;
      --    No_Updates : Array_Type;
      -- begin
      --    if not Is_Multisite and then Current_User_Can ("update_themes") then
      --       declare
      --          Updates_Transient : Multi_Type :=
      --            Get_Site_Transient ("update_themes");
      --       begin
      --          if Isset (Updates_Transient.Response) then
      --             Updates := Updates_Transient.Response;
      --          end if;
      --          if Isset (Updates_Transient.No_Update) then
      --             No_Updates := Updates_Transient.No_Update;
      --          end if;
      --       end;
      --    end if;
      -- end;

      Sort_By_Name (Themes_2);

      Logging.Log ("XXX-C92", Themes_2'Image);
      -- Arrays.IO.Dump (Themes_2);

      for A in Themes_2.Iterate loop
         Process_Theme :
         declare
            Theme : Wp_Theme; --  := Element (A); -- Wp_Get_Theme (Slug);
            Slug  : constant String := Theme.Get_Stylesheet;

            Parent      : Wp_Theme := Theme.Parent;
            Parent_Slug : constant String := Parent.Get_Stylesheet;

            Parent_Name : constant String :=
              (if Parent_Slug /= "" then Parent.Display ("Name") else "");

            Is_Block    : constant Boolean := Theme.Is_Block_Theme;
            Is_Active   : constant Boolean := Slug = Current_Theme;
            Auto_Update : constant Boolean :=
              In_List (Slug, Auto_Updates, True);

            Auto_Action : constant String :=
              (if Auto_Update
               then "disable-auto-update"
               else "enable-auto-update");

            Is_WP : constant Boolean :=
              Is_WP_Version_Compatible (As_String (Theme.Get ("RequiresWP")));

            Is_PHP : constant Boolean :=
              Is_PHP_Version_Compatible (As_String (Theme.Get ("RequiresPHP")));

            Encoded_Slug : constant String := URL_Encode (Slug);

            Customize_A : constant String :=
              Build_Customize_Action (Slug, Is_Block, Is_Active);

            Theme_Data : constant Array_Type :=
              To_Array_Type
                ([Build ("id", Slug),
                  Build ("name", Theme.Display ("Name")),
                  Build
                    ("screenshot",
                     To_Array_Type ([Build ("1", Theme.Get_Screenshot)])),
                  Build ("description", Theme.Display ("Description")),
                  Build ("author", Theme.Display ("Author", False, True)),
                  Build ("authorAndUri", Theme.Display ("Author")),
                  Build ("tags", Theme.Display ("Tags")),
                  Build ("version", Theme.Get ("Version")),
                  Build ("compatibleWP", Is_WP),
                  Build ("compatiblePHP", Is_PHP),
                  Build
                    ("updateResponse",
                     To_Array_Type
                       ([Build ("compatibleWP", Is_WP),
                         Build ("compatiblePHP", Is_PHP),
                         Build ("parent", Parent_Name),
                         Build ("active", Is_Active),
                         Build ("hasUpdate", False), -- Isset (Updates, Slug)),
                         Build ("hasPackage", False),
                         -- Isset (Updates, Slug)
                         -- and then not Empty (Updates, Slug, "package")),
                         Build ("update", Get_Theme_Update_Available (Theme)),
                         Build
                           ("autoupdate",
                            To_Array_Type
                              ([Build ("enabled", Auto_Update),
                                Build
                                  ("supported",
                                   False), -- Auto_Update_Supported),
                                Build
                                  ("forced", False), -- Auto_Update_Forced)])),
                                Build
                                  ("actions",
                                   To_Array_Type
                                     ([Build
                                         ("activate",
                                          (if Can_Switch
                                           then
                                             Wp_Nonce_URL
                                               (Admin_URL
                                                  ("themes.php?action=activate&amp;stylesheet="
                                                   & Encoded_Slug),
                                                "switch-theme_" & Slug)
                                           else "")),
                                       Build ("customize", Customize_A),
                                       Build
                                         ("delete",
                                          (if Can_Delete
                                           then
                                             Wp_Nonce_URL
                                               (Admin_URL
                                                  ("themes.php?action=delete&amp;stylesheet="
                                                   & Encoded_Slug),
                                                "delete-theme_" & Slug)
                                           else "")),
                                       Build
                                         ("autoupdate",
                                          (if Auto_Enabled
                                           then
                                             Wp_Nonce_URL
                                               (Admin_URL
                                                  ("themes.php?action="
                                                   & Auto_Action
                                                   & "&amp;stylesheet="
                                                   & Encoded_Slug),
                                                "updates")
                                           else ""))])),
                                Build ("blockTheme", Is_Block)]))]))]);
         begin
            if Parent_Slug /= "" then
               Set (Parents, Slug, From_String (Parent_Slug));
            end if;
            Set (Prepared_Themes, Slug, From_Array (Theme_Data));
            Logging.Log ("XXX-C94", Slug);
            Arrays.IO.Dump (Prepared_Themes);
         end Process_Theme;
      end loop;

      -- if Length (Themes_2) > 0 then
      --    -- Use the keys of the provided array.
      --    declare
      --       Slugs : constant List_Type := Php.Arrays.Array_Keys (Themes_2);
      --    begin
      --       for S of Slugs loop
      --          Process_Theme (S);
      --       end loop;
      --    end;
      -- else
      --    -- Scan the themes directory for installed themes.
      --    if Is_Dir (Themes_Dir) then
      --       declare
      --          Search    : Search_Type;
      --          Dir_Entry : Directory_Entry_Type;
      --       begin
      --          Start_Search
      --            (Search,
      --             Themes_Dir,
      --             "",
      --             (Directory => True, others => False));
      --          while More_Entries (Search) loop
      --             Get_Next_Entry (Search, Dir_Entry);
      --             declare
      --                Name : constant String := Simple_Name (Dir_Entry);
      --             begin
      --                if Name /= "."
      --                  and then Name (Name'First) /= '.'
      --                  and then File_Exists
      --                             (Themes_Dir & "/" & Name & "/style.css")
      --                then
      --                   Process_Theme (Name);
      --                end if;
      --             end;
      --          end loop;
      --          End_Search (Search);
      --       end;
      --    end if;
      -- end if;

      -- Remove 'delete' action if the active theme has a child whose parent
      -- is also installed (the active theme is the child; its parent cannot
      -- be deleted while that child is active).
      if not Parents.Is_Empty and then Isset (Parents, Current_Theme) then
         declare
            Parent_Slug : constant String :=
              Get_As_String (Parents, Current_Theme);

            Parent_Data : Array_Type :=
              As_Array (Get (Prepared_Themes, Parent_Slug));

            Actions : Array_Type := As_Array (Get (Parent_Data, "actions"));
         begin
            Logging.Log ("XXX-C95", Parent_Slug);
            Set (Actions, "delete", From_String (""));
            Set (Parent_Data, "actions", From_Array (Actions));
            Set (Prepared_Themes, Parent_Slug, From_Array (Parent_Data));
         end;
      end if;

      --
      -- Filters the themes prepared for JavaScript, for themes.php.
      --
      -- Could be useful for changing the order, which is by name by default.
      --
      -- @since 3.8.0
      --
      -- @param array $prepared_themes Array of theme data.
      --
      Logging.Log ("wp_prepare_themes_for_js", "XXX-C00");
      -- Arrays.IO.Dump (Themes_2);
      Arrays.IO.Dump (Prepared_Themes);

      Prepared_Themes :=
        Apply_Filters ("wp_prepare_themes_for_js", Prepared_Themes);

      -- Logging.Log ("wp_prepare_themes_for_js", "XXX-C01");
      -- Arrays.IO.Dump (Prepared_Themes);

      Prepared_Themes := Array_Values (Prepared_Themes);
      Logging.Log ("wp_prepare_themes_for_js", "XXX-C02");
      Arrays.IO.Dump (Prepared_Themes);
      return Array_Filter (Prepared_Themes);
   end Wp_Prepare_Themes_For_JS;

-- --
-- -- Prints JS templates for the theme-browsing UI in the Customizer.
-- --
-- -- @since 4.2.0
-- --
-- function customize_themes_print_templates() then
--         ?>
--         <script type="text/html" id="tmpl-customize-themes-details-view">
--                 <div class="theme-backdrop"></div>
--                 <div class="theme-wrap wp-clearfix" role="document">
--                         <div class="theme-header">
--                                 <button type="button" class="left dashicons dashicons-no"><span class="screen-reader-text">
--                                         <?php
--                                         /* translators: Hidden accessibility text. */
--                                         _e( "Show previous theme" );
--                                         ?>
--                                 </span></button>
--                                 <button type="button" class="right dashicons dashicons-no"><span class="screen-reader-text">
--                                         <?php
--                                         /* translators: Hidden accessibility text. */
--                                         _e( "Show next theme" );
--                                         ?>
--                                 </span></button>
--                                 <button type="button" class="close dashicons dashicons-no"><span class="screen-reader-text">
--                                         <?php
--                                         /* translators: Hidden accessibility text. */
--                                         _e( "Close details dialog" );
--                                         ?>
--                                 </span></button>
--                         </div>
--                         <div class="theme-about wp-clearfix">
--                                 <div class="theme-screenshots">
--                                 <# if ( data.screenshot && data.screenshot[0] ) then #>
--                                         <div class="screenshot"><img src="thenthen data.screenshot[0] end;end;?ver=thenthen data.version end;end;" alt="" /></div>
--                                 <# end; else then #>
--                                         <div class="screenshot blank"></div>
--                                 <# end; #>
--                                 </div>

--                                 <div class="theme-info">
--                                         <# if ( data.active ) then #>
--                                                 <span class="current-label"><?php _e( "Active Theme" ); ?></span>
--                                         <# end; #>
--                                         <h2 class="theme-name">thenthenthen data.name end;end;end;<span class="theme-version">
--                                                 <?php
--                                                 /* translators: %s: Theme version.--
--                                                 printf( __( "Version: %s" ), "thenthen data.version end;end;" );
--                                                 ?>
--                                         </span></h2>
--                                         <h3 class="theme-author">
--                                                 <?php
--                                                 /* translators: %s: Theme author link.--
--                                                 printf( __( "By %s" ), "thenthenthen data.authorAndUri end;end;end;" );
--                                                 ?>
--                                         </h3>

--                                         <# if ( data.stars && 0 != data.num_ratings ) then #>
--                                                 <div class="theme-rating">
--                                                         thenthenthen data.stars end;end;end;
--                                                         <a class="num-ratings" target="_blank" href="thenthen data.reviews_url end;end;">
--                                                                 <?php
--                                                                 printf(
--                                                                         "%1s <span class="screen-reader-text">%2s</span>",
--                                                                         /* translators: %s: Number of ratings.--
--                                                                         sprintf( __( "(%s ratings)" ), "thenthen data.num_ratings end;end;" ),
--                                                                         /* translators: Accessibility text.--
--                                                                         __( "(opens in a new tab)" )
--                                                                 );
--                                                                 ?>
--                                                         </a>
--                                                 </div>
--                                         <# end; #>

--                                         <# if ( data.hasUpdate ) then #>
--                                                 <# if ( data.updateResponse.compatibleWP && data.updateResponse.compatiblePHP ) then #>
--                                                         <div class="notice notice-warning notice-alt notice-large" data-slug="thenthen data.id end;end;">
--                                                                 <h3 class="notice-title"><?php _e( "Update Available" ); ?></h3>
--                                                                 thenthenthen data.update end;end;end;
--                                                         </div>
--                                                 <# end; else then #>
--                                                         <div class="notice notice-error notice-alt notice-large" data-slug="thenthen data.id end;end;">
--                                                                 <h3 class="notice-title"><?php _e( "Update Incompatible" ); ?></h3>
--                                                                 <p>
--                                                                         <# if ( ! data.updateResponse.compatibleWP && ! data.updateResponse.compatiblePHP ) then #>
--                                                                                 <?php
--                                                                                 printf(
--                                                                                         /* translators: %s: Theme name.--
--                                                                                         __( "There is a new version of %s available, but it does not work with your versions of WordPress and PHP." ),
--                                                                                         "thenthenthen data.name end;end;end;"
--                                                                                 );
--                                                                                 if ( current_user_can( "update_core" ) && current_user_can( "update_php" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.--
--                                                                                                 " " . __( "<a href="%1s">Please update WordPress</a>, and then <a href="%2s">learn more about updating PHP</a>." ),
--                                                                                                 self_admin_url( "update-core.php" ),
--                                                                                                 esc_url( wp_get_update_php_url() )
--                                                                                         );
--                                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                                 end; elseif ( current_user_can( "update_core" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: %s: URL to WordPress Updates screen.--
--                                                                                                 " " . __( "<a href="%s">Please update WordPress</a>." ),
--                                                                                                 self_admin_url( "update-core.php" )
--                                                                                         );
--                                                                                 end; elseif ( current_user_can( "update_php" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: %s: URL to Update PHP page.--
--                                                                                                 " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
--                                                                                                 esc_url( wp_get_update_php_url() )
--                                                                                         );
--                                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                                 end;
--                                                                                 ?>
--                                                                         <# end; else if ( ! data.updateResponse.compatibleWP ) then #>
--                                                                                 <?php
--                                                                                 printf(
--                                                                                         /* translators: %s: Theme name.--
--                                                                                         __( "There is a new version of %s available, but it does not work with your version of WordPress." ),
--                                                                                         "thenthenthen data.name end;end;end;"
--                                                                                 );
--                                                                                 if ( current_user_can( "update_core" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: %s: URL to WordPress Updates screen.--
--                                                                                                 " " . __( "<a href="%s">Please update WordPress</a>." ),
--                                                                                                 self_admin_url( "update-core.php" )
--                                                                                         );
--                                                                                 end;
--                                                                                 ?>
--                                                                         <# end; else if ( ! data.updateResponse.compatiblePHP ) then #>
--                                                                                 <?php
--                                                                                 printf(
--                                                                                         /* translators: %s: Theme name.--
--                                                                                         __( "There is a new version of %s available, but it does not work with your version of PHP." ),
--                                                                                         "thenthenthen data.name end;end;end;"
--                                                                                 );
--                                                                                 if ( current_user_can( "update_php" ) ) then
--                                                                                         printf(
--                                                                                                 /* translators: %s: URL to Update PHP page.--
--                                                                                                 " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
--                                                                                                 esc_url( wp_get_update_php_url() )
--                                                                                         );
--                                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                                 end;
--                                                                                 ?>
--                                                                         <# end; #>
--                                                                 </p>
--                                                         </div>
--                                                 <# end; #>
--                                         <# end; #>

--                                         <# if ( data.parent ) then #>
--                                                 <p class="parent-theme">
--                                                         <?php
--                                                         printf(
--                                                                 /* translators: %s: Theme name.--
--                                                                 __( "This is a child theme of %s." ),
--                                                                 "<strong>thenthenthen data.parent end;end;end;</strong>"
--                                                         );
--                                                         ?>
--                                                 </p>
--                                         <# end; #>

--                                         <# if ( ! data.compatibleWP || ! data.compatiblePHP ) then #>
--                                                 <div class="notice notice-error notice-alt notice-large"><p>
--                                                         <# if ( ! data.compatibleWP && ! data.compatiblePHP ) then #>
--                                                                 <?php
--                                                                 _e( "This theme does not work with your versions of WordPress and PHP." );
--                                                                 if ( current_user_can( "update_core" ) && current_user_can( "update_php" ) ) then
--                                                                         printf(
--                                                                                 /* translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.--
--                                                                                 " " . __( "<a href="%1s">Please update WordPress</a>, and then <a href="%2s">learn more about updating PHP</a>." ),
--                                                                                 self_admin_url( "update-core.php" ),
--                                                                                 esc_url( wp_get_update_php_url() )
--                                                                         );
--                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                 end; elseif ( current_user_can( "update_core" ) ) then
--                                                                         printf(
--                                                                                 /* translators: %s: URL to WordPress Updates screen.--
--                                                                                 " " . __( "<a href="%s">Please update WordPress</a>." ),
--                                                                                 self_admin_url( "update-core.php" )
--                                                                         );
--                                                                 end; elseif ( current_user_can( "update_php" ) ) then
--                                                                         printf(
--                                                                                 /* translators: %s: URL to Update PHP page.--
--                                                                                 " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
--                                                                                 esc_url( wp_get_update_php_url() )
--                                                                         );
--                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                 end;
--                                                                 ?>
--                                                         <# end; else if ( ! data.compatibleWP ) then #>
--                                                                 <?php
--                                                                 _e( "This theme does not work with your version of WordPress." );
--                                                                 if ( current_user_can( "update_core" ) ) then
--                                                                         printf(
--                                                                                 /* translators: %s: URL to WordPress Updates screen.--
--                                                                                 " " . __( "<a href="%s">Please update WordPress</a>." ),
--                                                                                 self_admin_url( "update-core.php" )
--                                                                         );
--                                                                 end;
--                                                                 ?>
--                                                         <# end; else if ( ! data.compatiblePHP ) then #>
--                                                                 <?php
--                                                                 _e( "This theme does not work with your version of PHP." );
--                                                                 if ( current_user_can( "update_php" ) ) then
--                                                                         printf(
--                                                                                 /* translators: %s: URL to Update PHP page.--
--                                                                                 " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
--                                                                                 esc_url( wp_get_update_php_url() )
--                                                                         );
--                                                                         wp_update_php_annotation( "</p><p><em>", "</em>" );
--                                                                 end;
--                                                                 ?>
--                                                         <# end; #>
--                                                 </p></div>
--                                         <# end; else if ( ! data.active && data.blockTheme ) then #>
--                                                 <div class="notice notice-error notice-alt notice-large"><p>
--                                                 <?php
--                                                         _e( "This theme doesn\'t support Customizer." );
--                                                 ?>
--                                                 <# if ( data.actions.activate ) then #>
--                                                         <?php
--                                                         printf(
--                                                                 /* translators: %s: URL to the themes page (also it activates the theme).--
--                                                                 " " . __( "However, you can still <a href="%s">activate this theme</a>, and use the Site Editor to customize it." ),
--                                                                 "thenthenthen data.actions.activate end;end;end;"
--                                                         );
--                                                         ?>
--                                                 <# end; #>
--                                                 </p></div>
--                                         <# end; #>

--                                         <p class="theme-description">thenthenthen data.description end;end;end;</p>

--                                         <# if ( data.tags ) then #>
--                                                 <p class="theme-tags"><span><?php _e( "Tags:" ); ?></span> thenthenthen data.tags end;end;end;</p>
--                                         <# end; #>
--                                 </div>
--                         </div>

--                         <div class="theme-actions">
--                                 <# if ( data.active ) then #>
--                                         <button type="button" class="button button-primary customize-theme"><?php _e( "Customize" ); ?></button>
--                                 <# end; else if ( "installed" === data.type ) then #>
--                                         <div class="theme-inactive-actions">
--                                         <# if ( data.blockTheme ) then #>
--                                                 <?php
--                                                         /* translators: %s: Theme name. */
--                                                         aria_label = sprintf( _x( "Activate %s", "theme" ), "{{ data.name }}" );
--                                                 ?>
--                                                 <# if ( data.compatibleWP && data.compatiblePHP && data.actions.activate ) then #>
--                                                         <a href="{{{ data.actions.activate }}}" class="button button-primary activate" aria-label="<?php echo esc_attr( aria_label ); ?>"><?php _e( "Activate" ); ?></a>
--                                                 <# end; #>
--                                         <# end; else then #>
--                                                 <# if ( data.compatibleWP && data.compatiblePHP ) then #>
--                                                         <button type="button" class="button button-primary preview-theme" data-slug="{{ data.id }}"><?php _e( "Live Preview" ); ?></button>
--                                                 <# end; else then #>
--                                                         <button class="button button-primary disabled"><?php _e( "Live Preview" ); ?></button>
--                                                 <# end; #>
--                                         <# end; #>
--                                         </div>
--                                         <?php if ( current_user_can( "delete_themes" ) ) then ?>
--                                                 <# if ( data.actions && data.actions["delete"] ) then #>
--                                                         <a href="{{{ data.actions["delete"] }}}" data-slug="{{ data.id }}" class="button button-secondary delete-theme"><?php _e( "Delete" ); ?></a>
--                                                 <# end; #>
--                                         <?php end; ?>
--                                 <# end; else then #>
--                                         <# if ( data.compatibleWP && data.compatiblePHP ) then #>
--                                                 <button type="button" class="button theme-install" data-slug="thenthen data.id end;end;"><?php _e( "Install" ); ?></button>
--                                                 <button type="button" class="button button-primary theme-install preview" data-slug="thenthen data.id end;end;"><?php _e( "Install &amp; Preview" ); ?></button>
--                                         <# end; else then #>
--                                                 <button type="button" class="button disabled"><?php _ex( "Cannot Install", "theme" ); ?></button>
--                                                 <button type="button" class="button button-primary disabled"><?php _e( "Install &amp; Preview" ); ?></button>
--                                         <# end; #>
--                                 <# end; #>
--                         </div>
--                 </div>
--         </script>
--         <?php
-- end;

-- --
-- -- Determines whether a theme is technically active but was paused while
-- -- loading.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
-- --
-- -- @since 5.2.0
-- --
-- -- @param string theme Path to the theme directory relative to the themes directory.
-- -- @return bool True, if in the list of paused themes. False, not in the list.
-- --
-- function is_theme_paused( theme ) then
--         if ( ! isset( GLOBALS["_paused_themes"] ) ) then
--                 return false;
--         end;

--         if ( get_stylesheet() !== theme && get_template() !== theme ) then
--                 return false;
--         end;

--         return array_key_exists( theme, GLOBALS["_paused_themes"] );
-- end;

-- --
-- -- Gets the error that was recorded for a paused theme.
-- --
-- -- @since 5.2.0
-- --
-- -- @param string theme Path to the theme directory relative to the themes
-- --                      directory.
-- -- @return array|false Array of error information as it was returned by
-- --                     `error_get_last()`, or false if none was recorded.
-- --
-- function wp_get_theme_error( theme ) then
--         if ( ! isset( GLOBALS["_paused_themes"] ) ) then
--                 return false;
--         end;

--         if ( ! array_key_exists( theme, GLOBALS["_paused_themes"] ) ) then
--                 return false;
--         end;

--         return GLOBALS["_paused_themes"][ theme ];
-- end;

   ------------------
   -- Resume_Theme --
   ------------------

   function Resume_Theme (Theme    : String;
                          Redirect : String := "")
                          return Bool_Error_Type
   is (raise Program_Error with "not implemented");
--         list( extension ) = explode( "/", theme );

--         global wp_stylesheet_path, wp_template_path;
--         /*
--         -- We"ll override this later if the theme could be resumed without
--         -- creating a fatal error.
--         --
--         if ( ! empty( redirect ) ) then
--                 functions_path = "";
--                 if ( str_contains( wp_stylesheet_path, extension ) ) then
--                         functions_path = wp_stylesheet_path . "/functions.php";
--                 end; elseif ( str_contains( wp_template_path, extension ) ) then
--                         functions_path = wp_template_path . "/functions.php";
--                 end;

--                 if ( ! empty( functions_path ) ) then
--                         wp_redirect(
--                                 add_query_arg(
--                                         "_error_nonce",
--                                         wp_create_nonce( "theme-resume-error_" . theme ),
--                                         redirect
--                                 )
--                         );

--                         -- Load the theme's functions.php to test whether it throws a fatal error.
--                         ob_start();
--                         if ( ! defined( "WP_SANDBOX_SCRAPING" ) ) then
--                                 define( "WP_SANDBOX_SCRAPING", true );
--                         end;
--                         include functions_path;
--                         ob_clean();
--                 end;
--         end;

--         result = wp_paused_themes().delete( extension );

--         if ( ! result ) then
--                 return new WP_Error(
--                         "could_not_resume_theme",
--                         __( "Could not resume the theme." )
--                 );
--         end;

--         return true;
-- end;

-- --
-- -- Renders an admin notice in case some themes have been paused due to errors.
-- --
-- -- @since 5.2.0
-- --
-- -- @global string pagenow The filename of the current screen.
-- --
-- function paused_themes_notice() then
--         if ( "themes.php" === GLOBALS["pagenow"] ) then
--                 return;
--         end;

--         if ( ! current_user_can( "resume_themes" ) ) then
--                 return;
--         end;

--         if ( ! isset( GLOBALS["_paused_themes"] ) || empty( GLOBALS["_paused_themes"] ) ) then
--                 return;
--         end;

--         message = sprintf(
--                 "<p><strong>%s</strong><br>%s</p><p><a href="%s">%s</a></p>",
--                 __( "One or more themes failed to load properly." ),
--                 __( "You can find more details and make changes on the Themes screen." ),
--                 esc_url( admin_url( "themes.php" ) ),
--                 __( "Go to the Themes screen" )
--         );
--         wp_admin_notice(
--                 message,
--                 array(
--                         "type"           => "error",
--                         "paragraph_wrap" => false,
--                 )
--         );
-- end;

   --------------
   -- To_Array --
   --------------

   function To_Array (Args : Themes_API_Args) return Array_Type is
      use Array_Lists;
      use UStrings;

      Themes : constant Array_Type :=
        To_Array_Type
          ([Build ("slug", -Args.Slug),
            Build ("per_page", Args.Per_Page),
            Build ("page", Args.Page),
            Build ("number", Args.Number),
            Build ("search", -Args.Search),
            Build ("tag", -Args.Tag),
            Build ("author", -Args.Author),
            Build ("user", -Args.User),
            Build ("browse", -Args.Browse),
            Build ("locale", -Args.Locale),
            Build ("fields", Args.Fields)]);
   begin
      return Themes;
   end To_Array;

   --------------
   -- To_Array --
   --------------

   function To_Array (Args : Theme_API_Type) return Array_Type is
      use Array_Lists;
      use UStrings;

      Themes : constant Array_Type :=
        To_Array_Type
          ([Build ("name", -Args.Name),
            Build ("slug", -Args.Slug),
            Build ("version", -Args.Version),
            Build ("author", -Args.Author),
            Build ("preview_url", -Args.Preview_URL),
            Build ("screenshot_url", -Args.Screenshot_URL),
            Build ("rating", Integer (Args.Rating)),
            Build ("num_ratings", Args.Num_Ratings),
            Build ("homepage", -Args.Homepage),
            Build ("description", -Args.Description),
            Build ("download_link", -Args.Download_Link)]);
   begin
      return Themes;
   end To_Array;

end Adi_Themes;
