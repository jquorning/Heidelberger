--
-- WordPress scripts and styles default loader.
--
-- Several constants are used to manage the loading, concatenating and compression of scripts and CSS:
-- define('SCRIPT_DEBUG', true); loads the development (non-minified) versions of all scripts and CSS, and disables compression and concatenation,
-- define('CONCATENATE_SCRIPTS', false); disables compression and concatenation of scripts and CSS,
-- define('COMPRESS_SCRIPTS', false); disables compression of scripts,
-- define('COMPRESS_CSS', false); disables compression of CSS,
-- define('ENFORCE_GZIP', true); forces gzip for compression (default is deflate).
--
-- The globals concatenate_scripts, compress_scripts and compress_css can be set by plugins
-- to temporarily override the above settings. Also a compression test is run once and the result is saved
-- as option 'can_compress_scripts' (0/1). The test will run again if that option is deleted.
--
-- @package WordPress
--

with Php.Arrays;
with Php.Echoing;
with Php.Files;
with Php.HTML;
with Php.Ini;
with Php.Lists;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Array_Lists;
with Binder;
with Constants;
with Helpers;
with Globals;
with UStrings;
with Wp_Common;

with Class_Dependency;
with Class_Screens;
with Class_Theme_JSON_Resolver;
with Class_Users;

with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Styles;
with Inc_General_Templates;
with Inc_Global_Styles_And_Settings;
with Inc_L10n;
with Inc_Load;
with Inc_Link_Templates;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_REST_API;
with Inc_Style_Engines;
with Inc_Themes;
with Inc_Users;
with Inc_Versions;

with Style_Class_Wp_Style_Engine_CSS_Rules_Stores;

package body Inc_Script_Loader
is

   Concatenate_Scripts : Boolean;
   Compress_CSS        : Boolean;
   Compress_Scripts    : Boolean;

-- -- WordPress Dependency Class
-- require ABSPATH . WPINC . "/class-wp-dependency.php";

-- -- WordPress Dependencies Class
-- require ABSPATH . WPINC . "/class-wp-dependencies.php";

-- -- WordPress Scripts Class
-- require ABSPATH . WPINC . "/class-wp-scripts.php";

-- -- WordPress Scripts Functions
-- require ABSPATH . WPINC . "/functions.wp-scripts.php";

-- -- WordPress Styles Class
-- require ABSPATH . WPINC . "/class-wp-styles.php";

-- -- WordPress Styles Functions
-- require ABSPATH . WPINC . "/functions.wp-styles.php";
   Static_Compress_Scripts   : constant Boolean := False;
   Static_Concatenate_Script : constant Boolean := False;

   ---------------------------------
   -- Wp_Register_Tinymse_Scritps --
   ---------------------------------

   procedure Wp_Register_TinyMCE_Scripts
     (Scripts            : in out Class_Scripts.Wp_Scripts;
      Force_Uncompressed : Boolean := False)
   is
      use Php.Strings;
      use Inc_Link_Templates;
      use Inc_Versions;

--        global tinymce_version
--        global concatenate_scripts
--        global compress_scripts
      Suffix     : constant String := Wp_Scripts_Get_Suffix;
      Dev_Suffix : constant String := Wp_Scripts_Get_Suffix ("dev");
      Compressed : Boolean;
   begin
      Script_Concat_Settings;

      Compressed :=
        Static_Compress_Scripts   and then
        Static_Concatenate_Script and then
        Isset (Binder.X_SERVER, "HTTP_ACCEPT_ENCODING") and then
        0 /= Stripos (Get_As_String (Binder.X_SERVER, "HTTP_ACCEPT_ENCODING"), "gzip") and then
        not Force_Uncompressed;

      -- Load tinymce.js when running from /src, otherwise load wp-tinymce.js.gz (in
      -- production) or tinymce.min.js (when SCRIPT_DEBUG is true).
      if Compressed then
         Scripts.Add
           ("wp-tinymce",
            Includes_URL ("js/tinymce/") & "wp-tinymce.js",
            Empty_List,
            Tinymce_Version);
      else
         Scripts.Add
           ("wp-tinymce-root",
            Includes_URL ("js/tinymce/") & "tinymce" & Dev_Suffix & ".js",
            Empty_List,
            Tinymce_Version);

         Scripts.Add
           ("wp-tinymce",
            Includes_URL ("js/tinymce/") &
                          "plugins/compat3x/plugin" & Dev_Suffix & ".js",
            ["wp-tinymce-root"],
            Tinymce_Version);
      end if;

      Scripts.Add
        ("wp-tinymce-lists",
         Includes_URL ("js/tinymce/plugins/lists/plugin" & Suffix & ".js"),
         ["wp-tinymce"],
         Tinymce_Version);

   end Wp_Register_TinyMCE_Scripts;

   --------------------------------
   -- Wp_Default_Packages_Vendor --
   --------------------------------

   procedure Wp_Default_Packages_Vendor
     (Scripts : in out Class_Scripts.Wp_Scripts)
   is
      use Array_Lists;
      use UStrings;
      use Inc_L10n;
      use Inc_Functions;
      use Inc_Options;
      use Inc_Plugins;
--    global wp_locale;

      Suffix : constant String := Wp_Scripts_Get_Suffix;

      Vendor_Scripts : constant Array_Type := To_Array_Type ([
        Build ("react",       To_Array_Type ([Build ("wp-polyfill", "")])),
        Build ("react-dom",   To_Array_Type ([Build ("react", "")])),
        Build ("regenerator-runtime", ""),
        Build ("moment", ""),
        Build ("lodash", ""),
        Build ("wp-polyfill-fetch", ""),
        Build ("wp-polyfill-formdata", ""),
        Build ("wp-polyfill-node-contains", ""),
        Build ("wp-polyfill-url", ""),
        Build ("wp-polyfill-dom-rect", ""),
        Build ("wp-polyfill-element-closest", ""),
        Build ("wp-polyfill-object-fit", ""),
        Build ("wp-polyfill", To_Array_Type ([Build ("regenerator-runtime", "")]))
      ]);

      Vendor_Scripts_Versions : constant Array_Type := To_Array_Type ([
        Build ("react",                       "17.0.1"),
        Build ("react-dom",                   "17.0.1"),
        Build ("regenerator-runtime",         "0.13.9"),
        Build ("moment",                      "2.29.4"),
        Build ("lodash",                      "4.17.19"),
        Build ("wp-polyfill-fetch",           "3.6.2"),
        Build ("wp-polyfill-formdata",        "4.0.10"),
        Build ("wp-polyfill-node-contains",   "4.4.0"),
        Build ("wp-polyfill-url",             "3.6.4"),
        Build ("wp-polyfill-dom-rect",        "4.4.0"),
        Build ("wp-polyfill-element-closest", "2.0.2"),
        Build ("wp-polyfill-object-fit",      "2.3.5"),
        Build ("wp-polyfill",                 "3.15.0")
      ]);
   begin
      for A in Vendor_Scripts.Iterate loop
         declare
--          use Array_Maps;

            Handle       : constant String := Key     (A);
            Dependencies : constant String := Get_As_String (Vendor_Scripts, Handle);
            -- Element (A);
            Path    : UString;
            Version : UString;
         begin
            -- if ( is_string( dependencies ) ) then
            --         handle       = dependencies;
            --         dependencies = array();
            -- end if;

            Path    := +"/wp-includes/js/dist/vendor/handle" & Suffix & " .js";
            Version := +Get_As_String (Vendor_Scripts_Versions, Handle);

            Scripts.Add (Handle, -Path, [Dependencies], -Version, 1);
         end;
      end loop;

      if Did_Action ("init") then
         Scripts.Add_Inline_Script ("lodash", "window.lodash = _.noConflict();");
      end if;

      if Did_Action ("init") then
         Scripts.Add_Inline_Script (
            "moment",
            Php.Strings.Sprintf (
              "moment.updateLocale( ""%s"", %s );",
              [
                1 => Get_User_Locale,
                2 => Wp_JSON_Encode (From_Array (
                  To_Array_Type ([
                  Build ("months",
                         List_Type'(Php.Arrays.Array_Values (Globals.Wp_Locale.Month))),
                  Build ("monthsShort",
                         List_Type'(Php.Arrays.Array_Values (Globals.Wp_Locale.Month_Abbrev))),
                  Build ("weekdays",
                         List_Type'(Php.Arrays.Array_Values (Globals.Wp_Locale.Weekday))),
                  Build ("weekdaysShort",
                         List_Type'(Php.Arrays.Array_Values (Globals.Wp_Locale.Weekday_Abbrev))),
                  Build ("week",           To_Array_Type ([
                    Build ("dow", String'(Get_Option ("start_of_week", "0"))) -- (int), 0
                  ])),
                  Build ("longDateFormat", To_Array_Type ([
                    Build ("LT",   String'(Get_Option ("time_format", abs "g:i a"))),
--                                              "LTS"  => null,
--                                              "L"    => null,
                    Build ("LL",   String'(Get_Option ("date_format", abs "F j, Y"))),
                    Build ("LLL",  abs "F j, Y g:i a")
--                                             "LLLL" => null,
                  ]))
                ])
              ))
            ]),
            "after"
         );
      end if;
   end Wp_Default_Packages_Vendor;

-- --
-- -- Returns contents of an inline script used in appending polyfill scripts for
-- -- browsers which fail the provided tests. The provided array is a mapping from
-- -- a condition to verify feature support to its polyfill script handle.
-- --
-- -- @since 5.0.0
-- --
-- -- @param WP_Scripts scripts WP_Scripts object.
-- -- @param string[]   tests   Features to detect.
-- -- @return string Conditional polyfill inline script.
-- --
-- function wp_get_script_polyfill( scripts, tests ) then
--         polyfill = "";
--         foreach ( tests as test => handle ) then
--                 if ( ! array_key_exists( handle, scripts->registered ) ) then
--                         continue;
--                 end;

--                 src = scripts->registered[ handle ]->src;
--                 ver = scripts->registered[ handle ]->ver;

--                 if ( ! preg_match( "|^(https?:)?--|", src ) && ! ( scripts->content_url && 0 === strpos( src, scripts->content_url ) ) ) then
--                         src = scripts->base_url . src;
--                 end;

--                 if ( ! empty( ver ) ) then
--                         src = add_query_arg( "ver", ver, src );
--                 end;

--                 -- This filter is documented in wp-includes/class-wp-scripts.php--
--                 src = esc_url( apply_filters( "script_loader_src", src, handle ) );

--                 if ( ! src ) then
--                         continue;
--                 end;

--                 polyfill .= (
--                         -- Test presence of feature...
--                         "( " . test . " ) || " .
--                         /*
--                         -- ...appending polyfill on any failures. Cautious viewers may balk
--                         -- at the `document.write`. Its caveat of synchronous mid-stream
--                         -- blocking write is exactly the behavior we need though.
--                         --
--                         "document.write( \"<script src="" .
--                         src .
--                         ""></scr\" + \"ipt>\" );"
--                 );
--         end;

--         return polyfill;
-- end;

   -------------------------------------
   -- Wp_Register_Development_Scripts --
   -------------------------------------

   procedure Wp_Register_Development_Scripts
     (Scripts : in out Class_Scripts.Wp_Scripts)
   is
      Development_Scripts : constant List_Type :=
        [
          "react-refresh-entry",
          "react-refresh-runtime"
        ];
   begin
      if
--      not Defined ("SCRIPT_DEBUG") or else
        not Constants.SCRIPT_DEBUG
        or else not Class_Dependency.Dependency_Maps.Has_Element (Scripts.Registered.Find ("react"))
--      or else Empty (Scripts.Registered, "react")
--      or else Defined ("WP_RUN_CORE_TESTS")
        or else Constants.WP_RUN_CORE_TESTS
      then
         return;
      end if;

      for Script_Name of Development_Scripts loop
         declare
            Assets : Array_Type; -- String := "";
--            include ABSPATH & WPINC & "/assets/script-loader-" & Script_Name & ".php";
         begin
            -- if not Is_Array (Assets) then
            --    return;
            -- end if;

            Scripts.Add (
              "wp-" & Script_Name,
              "/wp-includes/js/dist/development/" & Script_Name & ".js",
              As_List (Get (Assets, "dependencies")),
              Get_As_String (Assets, "version")
            );
         end;
      end loop;

      -- See https://github.com/pmmmwh/react-refresh-webpack-plugin/blob/main/docs/TROUBLESHOOTING.md#externalising-react.
      Scripts.Registered ("react").Deps.Append ("wp-react-refresh-entry");
   end Wp_Register_Development_Scripts;

   ---------------------------------
   -- Wp_Default_Packages_Scripts --
   ---------------------------------

   procedure Wp_Default_Packages_Scripts
     (Scripts : in out Class_Scripts.Wp_Scripts)
   is
      use Php.Lists;
      use Php.Strings;

      Suffix : String := (if Constants.WP_RUN_CORE_TESTS then ".min"
                          else Wp_Scripts_Get_Suffix);
      --
      -- Expects multidimensional array like:
      --
      --     "a11y.js" => array("dependencies" => array(...), "version" => "..."),
      --     "annotations.js" => array("dependencies" => array(...),
      --                                              "version" => "..."),
      --     "api-fetch.js" => array(...
      --
      Assets : Array_Type; -- := include ABSPATH & WPINC & "/assets/script-loader-packages{suffix}.php";
   begin
      for A in Assets.Iterate loop -- as file_name => package_data ) then
         declare
--          use Array_Maps;
--          use UStrings;

            File_Name    : constant String := Key     (A);
            Package_Data : Array_Type;
--          Package_Data : String := Element (A);
            Basename     : constant String :=
              Str_Replace (Suffix & ".js", "",
                           Php.Files.Basename (File_Name));

            Handle       : constant String := "wp-" & Basename;
            Path         : constant String :=
              "/wp-includes/js/dist/" & Basename & Suffix & ".js";

            Dependencies : List_Type;
            Unused       : List_Type;
         begin
            if Isset (Package_Data, "dependencies") then
--          if not Empty (Package_Data ("dependencies")) then
               Dependencies := As_List (Get (Package_Data, "dependencies"));
            else
               Dependencies := Empty_List;
            end if;

            -- Add dependencies that cannot be detected and generated by build tools.
            if Handle = "wp-block-library" then
               Unused := List_Push (Dependencies, "editor");

            elsif Handle = "wp-edit-post" then
               Unused := List_Push (Dependencies, "media-models");
               Unused := List_Push (Dependencies, "media-views");
               Unused := List_Push (Dependencies, "postbox");
               Unused := List_Push (Dependencies, "wp-dom-ready");

            elsif Handle = "wp-preferences" then
               Unused := List_Push (Dependencies, "wp-preferences-persistence");

            end if;

            Scripts.Add (Handle, Path, Dependencies,
                         Get_As_String (Package_Data, "version"), 1);

            if In_List ("wp-i18n", Dependencies, True) then
               Scripts.Set_Translations (Handle);
            end if;

            --
            -- Manually set the text direction localization after wp-i18n is printed.
            -- This ensures that wp.i18n.isRTL() returns true in RTL languages.
            -- We cannot use scripts->set_translations( "wp-i18n" ) to do this
            -- because WordPress prints a script"s translations--before* the script,
            -- which means, in the case of wp-i18n, that wp.i18n.setLocaleData()
            -- is called before wp.i18n is defined.
            --
            if "wp-i18n" = Handle then
               declare
                  LTR    : constant String := Inc_L10n.X_X ("ltr", "text direction");
                  Script : constant String :=
                    Sprintf (
                      "wp.i18n.setLocaleData( { ""text direction\u0004ltr"": [ ""%s"" ] } );",
                      [1 => LTR]);
               begin
                  Scripts.Add_Inline_Script (Handle, Script, "after");
               end;
            end if;
         end;
      end loop;
   end Wp_Default_Packages_Scripts;

   ---------------------------------------
   -- Wp_Default_Package_Inline_Scripts --
   ---------------------------------------

   procedure Wp_Default_Packages_Inline_Scripts
     (Scripts : in out Class_Scripts.Wp_Scripts)
   is
      use Php.Arrays;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Class_Dependency.Dependency_Maps;
      use Class_Users;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_REST_API;
--    global wp_locale, wpdb;
   begin
      if Has_Element (Scripts.Registered.Find ("wp-api-fetch")) then
--    if Isset (Scripts.Registered, "wp-api-fetch") then
         Scripts.Registered ("wp-api-fetch").Deps.Append ("wp-hooks");
      end if;

      Scripts.Add_Inline_Script (
        "wp-api-fetch",
        Sprintf (
          "wp.apiFetch.use( wp.apiFetch.createRootURLMiddleware( ""%s"" ) );",
          [1 => Sanitize_URL (Get_REST_URL)]
        ),
        "after"
      );

      Scripts.Add_Inline_Script (
        "wp-api-fetch",
        Implode (
          NL, -- "\n",
          List_Type'[
            Sprintf (
             "wp.apiFetch.nonceMiddleware = wp.apiFetch.createNonceMiddleware( ""%s"" );",
             [1 => (if Inc_Load.Wp_Installing then ""
                    else Inc_Pluggables.Wp_Create_Nonce ("wp_rest"))]
            ),
            "wp.apiFetch.use( wp.apiFetch.nonceMiddleware );",
            "wp.apiFetch.use( wp.apiFetch.mediaUploadMiddleware );",
            Sprintf (
              "wp.apiFetch.nonceEndpoint = ""%s"";",
              [1 => Admin_URL ("admin-ajax.php?action=rest-nonce")]
            )
          ]
        ),
        "after"
      );

      declare
         use Inc_Functions;
         use Inc_Users;

         Meta_Key : constant String  :=
           Globals.WpDB.Get_Blog_Prefix & "persisted_preferences";

         User_Id      : constant User_Id_Type := Get_Current_User_Id;
         Preload_Data : constant Boolean := Get_User_Meta (User_Id, Meta_Key, True);
      begin
         Scripts.Add_Inline_Script (
           "wp-preferences",
           Sprintf (
             "( function() then "        &
             "  var serverData = %s; "   &
             "  var userId = ""%d"";   " &
             "  var persistenceLayer = wp.preferencesPersistence.__unstableCreatePersistenceLayer( serverData, userId ); "      &
             "  var preferencesStore = wp.preferences.store; " &
             "  wp.data.dispatch( preferencesStore ).setPersistenceLayer( persistenceLayer ); " &
             "end; ) ();",
             [
                1 => Wp_JSON_Encode (From_Boolean (Preload_Data)),
                2 => Image (User_Id)
             ]
           )
         );

         -- Backwards compatibility - configure the old wp-data persistence system.
         Scripts.Add_Inline_Script (
           "wp-data",
           Implode (
             NL, -- "\n",
             List_Type'[
               "( function() then",
               ("       var userId = " & Image (Get_Current_User_Id) & ";"),
               "       var storageKey = ""WP_DATA_USER_"" + userId;",
               "       wp.data",
               "  .use( wp.data.plugins.persistence, { storageKey: storageKey } );",
               "end; )();"
             ]
           )
         );
      end;

      declare
         use Globals;
         use Inc_Functions;
         use Inc_L10n;
         use Inc_Options;

         -- Calculate the timezone abbr (EDT, PST) if possible.
         Timezone_String : constant String := Get_Option ("timezone_string", "UTC");
         Timezone_Abbr   : constant String := "";
      begin
         -- if not Empty (Timezone_String) then
         --    Timezone_Date :=
         --      new Datetime ("now", new DatetimeZone (Timezone_String));
         --    Timezone_Abbr := Timezone_Date.Format ("T");
         -- end if;

         Scripts.Add_Inline_Script (
           "wp-date",
           Sprintf (
             "wp.date.setSettings( %s );",
             [1 => Wp_JSON_Encode (From_Array (
               To_Array_Type ([
                 Build ("l10n",     To_Array_Type ([
                   Build ("locale",        Get_User_Locale),
                   Build ("months",        List_Type'(Array_Values (Wp_Locale.Month))),
                   Build ("monthsShort",   List_Type'(Array_Values (Wp_Locale.Month_Abbrev))),
                   Build ("weekdays",      List_Type'(Array_Values (Wp_Locale.Weekday))),
                   Build ("weekdaysShort", List_Type'(Array_Values (Wp_Locale.Weekday_Abbrev))),
                   Build ("meridiem",      Wp_Locale.Meridiem), -- (object)
                   Build ("relative",      To_Array_Type ([
                      -- translators: %s: Duration.
                      Build ("future", abs "%s from now"),
                      -- translators: %s: Duration.
                      Build ("past",   abs "%s ago")
                   ])),
                   Build ("startOfWeek",   Integer'(Get_Option ("start_of_week", 0)))
                 ])),
                 Build ("formats",  To_Array_Type ([
                   -- translators: Time format, see
                   -- https://www.php.net/manual/datetime.format.php
                   Build ("time",  String'(Get_Option ("time_format", abs "g:i a"))),
                   -- translators: Date format, see
                   -- https://www.php.net/manual/datetime.format.php
                   Build ("date",  String'(Get_Option ("date_format", abs "F j, Y"))),
                   -- translators: Date/Time format, see
                   -- https://www.php.net/manual/datetime.format.php
                   Build ("datetime", abs "F j, Y g:i a"),
                   -- translators: Abbreviated date/time format, see
                   -- https://www.php.net/manual/datetime.format.php
                   Build ("datetimeAbbreviated", abs "M j, Y g:i a")
                 ])),
                 Build ("timezone", To_Array_Type ([
                   Build ("offset", Get_Option ("gmt_offset", 0)), -- (float)
                   Build ("string", Timezone_String),
                   Build ("abbr",   Timezone_Abbr)
                 ]))
               ])
             ))]
           ),
           "after"
         );
      end;

      -- Loading the old editor and its config to ensure the classic block works
      -- as expected.
      Scripts.Add_Inline_Script (
        "editor",
        "window.wp.oldEditor = window.wp.editor;",
        "after"
      );

      --
      -- wp-editor module is exposed as window.wp.editor.
      -- Problem: there is quite some code expecting window.wp.oldEditor object
      -- available under window.wp.editor.
      -- Solution: fuse the two objects together to maintain backward compatibility.
      -- For more context, see https://github.com/WordPress/gutenberg/issues/33203.
      --
      Scripts.Add_Inline_Script (
        "wp-editor",
        "Object.assign( window.wp.editor, window.wp.oldEditor );",
        "after"
      );
   end Wp_Default_Packages_Inline_Scripts;

-- --
-- -- Adds inline scripts required for the TinyMCE in the block editor.
-- --
-- -- These TinyMCE init settings are used to extend and override the default settings
-- -- from `_WP_Editors::default_settings()` for the Classic block.
-- --
-- -- @since 5.0.0
-- --
-- -- @global WP_Scripts wp_scripts
-- --
-- function wp_tinymce_inline_scripts() then
--         global wp_scripts;

--         -- This filter is documented in wp-includes/class-wp-editor.php--
--         editor_settings = apply_filters( "wp_editor_settings", array( "tinymce" => true ), "classic-block" );

--         tinymce_plugins = array(
--                 "charmap",
--                 "colorpicker",
--                 "hr",
--                 "lists",
--                 "media",
--                 "paste",
--                 "tabfocus",
--                 "textcolor",
--                 "fullscreen",
--                 "wordpress",
--                 "wpautoresize",
--                 "wpeditimage",
--                 "wpemoji",
--                 "wpgallery",
--                 "wplink",
--                 "wpdialogs",
--                 "wptextpattern",
--                 "wpview",
--         );

--         -- This filter is documented in wp-includes/class-wp-editor.php--
--         tinymce_plugins = apply_filters( "tiny_mce_plugins", tinymce_plugins, "classic-block" );
--         tinymce_plugins = array_unique( tinymce_plugins );

--         disable_captions = false;
--         -- Runs after `tiny_mce_plugins` but before `mce_buttons`.
--         -- This filter is documented in wp-admin/includes/media.php--
--         if ( apply_filters( "disable_captions", "" ) ) then
--                 disable_captions = true;
--         end;

--         toolbar1 = array(
--                 "formatselect",
--                 "bold",
--                 "italic",
--                 "bullist",
--                 "numlist",
--                 "blockquote",
--                 "alignleft",
--                 "aligncenter",
--                 "alignright",
--                 "link",
--                 "unlink",
--                 "wp_more",
--                 "spellchecker",
--                 "wp_add_media",
--                 "wp_adv",
--         );

--         -- This filter is documented in wp-includes/class-wp-editor.php--
--         toolbar1 = apply_filters( "mce_buttons", toolbar1, "classic-block" );

--         toolbar2 = array(
--                 "strikethrough",
--                 "hr",
--                 "forecolor",
--                 "pastetext",
--                 "removeformat",
--                 "charmap",
--                 "outdent",
--                 "indent",
--                 "undo",
--                 "redo",
--                 "wp_help",
--         );

--         -- This filter is documented in wp-includes/class-wp-editor.php--
--         toolbar2 = apply_filters( "mce_buttons_2", toolbar2, "classic-block" );
--         -- This filter is documented in wp-includes/class-wp-editor.php--
--         toolbar3 = apply_filters( "mce_buttons_3", array(), "classic-block" );
--         -- This filter is documented in wp-includes/class-wp-editor.php--
--         toolbar4 = apply_filters( "mce_buttons_4", array(), "classic-block" );
--         -- This filter is documented in wp-includes/class-wp-editor.php--
--         external_plugins = apply_filters( "mce_external_plugins", array(), "classic-block" );

--         tinymce_settings = array(
--                 "plugins"              => implode( ",", tinymce_plugins ),
--                 "toolbar1"             => implode( ",", toolbar1 ),
--                 "toolbar2"             => implode( ",", toolbar2 ),
--                 "toolbar3"             => implode( ",", toolbar3 ),
--                 "toolbar4"             => implode( ",", toolbar4 ),
--                 "external_plugins"     => wp_json_encode( external_plugins ),
--                 "classic_block_editor" => true,
--         );

--         if ( disable_captions ) then
--                 tinymce_settings["wpeditimage_disable_captions"] = true;
--         end;

--         if ( ! empty( editor_settings["tinymce"] ) && is_array( editor_settings["tinymce"] ) ) then
--                 array_merge( tinymce_settings, editor_settings["tinymce"] );
--         end;

--         -- This filter is documented in wp-includes/class-wp-editor.php--
--         tinymce_settings = apply_filters( "tiny_mce_before_init", tinymce_settings, "classic-block" );

--         -- Do "by hand" translation from PHP array to js object.
--         -- Prevents breakage in some custom settings.
--         init_obj = "";
--         foreach ( tinymce_settings as key => value ) then
--                 if ( is_bool( value ) ) then
--                         val       = value ? "true" : "false";
--                         init_obj .= key . ":" . val . ",";
--                         continue;
--                 end; elseif ( ! empty( value ) && is_string( value ) && (
--                         ( "then" === value[0] && "end;" === value[ strlen( value ) - 1 ] ) ||
--                         ( "[" === value[0] && "]" === value[ strlen( value ) - 1 ] ) ||
--                         preg_match( "/^\(?function ?\(/", value ) ) ) then
--                         init_obj .= key . ":" . value . ",";
--                         continue;
--                 end;
--                 init_obj .= key . ":"" . value . "",";
--         end;

--         init_obj = "then" . trim( init_obj, " ," ) . "end;";

--         script = "window.wpEditorL10n = then
--                 tinymce: then
--                         baseURL: " . wp_json_encode( includes_url( "js/tinymce" ) ) . ",
--                         suffix: " . ( SCRIPT_DEBUG ? """" : "".min"" ) . ",
--                         settings: " . init_obj . ",
--                 end;
--         end;";

--         wp_scripts->add_inline_script( "wp-block-library", script, "before" );
-- end;

   -------------------------
   -- Wp_Default_Packages --
   -------------------------

   procedure Wp_Default_Packages (Scripts : in out Class_Scripts.Wp_Scripts)
   is
      use Inc_Plugins;
   begin
      Wp_Register_Development_Scripts (Scripts);
      Wp_Register_TinyMCE_Scripts (Scripts);
      Wp_Default_Packages_Scripts (Scripts);

      if Did_Action ("init") then
         Wp_Default_Packages_Inline_Scripts (Scripts);
      end if;
   end Wp_Default_Packages;

   Static_Suffixes : Array_Type;

-- --
-- -- Returns the suffix that can be used for the scripts.
-- --
-- -- There are two suffix types, the normal one and the dev suffix.
-- --
-- -- @since 5.0.0
-- --
-- -- @param string type The type of suffix to retrieve.
-- -- @return string The script suffix.
-- --
-- function wp_scripts_get_suffix( type = "" ) then
   function Wp_Scripts_Get_Suffix (Typ : String := "")
                                   return String
   is
      use Array_Lists;
      use Constants;
      use Inc_Versions;
--         static suffixes;
   begin
      if Static_Suffixes.Is_Empty then --  = Empty_Array then -- null =
         declare
            -- Include an unmodified wp_version.
--          require ABSPATH . WPINC . "/version.php";

            Develop_Src : constant Boolean :=
              0 /= Php.Strings.Strpos (Wp_Version, "-src");
         begin
--          if ( ! defined( "SCRIPT_DEBUG" ) ) then
               SCRIPT_DEBUG := Develop_Src;
--             Define ("SCRIPT_DEBUG", Develop_Src);
--          end if;

            declare
               Suffix     : constant String := (if SCRIPT_DEBUG then "" else ".min");
               Dev_Suffix : constant String := (if Develop_Src  then "" else ".min");
            begin
               Static_Suffixes := To_Array_Type ([
                  Build ("suffix",     Suffix),
                  Build ("dev_suffix", Dev_Suffix)
               ]);
            end;
         end;
      end if;

      if "dev" = Typ then
         return Get_As_String (Static_Suffixes, "dev_suffix");
      end if;

      return Get_As_String (Static_Suffixes, "suffix");
   end Wp_Scripts_Get_Suffix;

   ------------------------
   -- Wp_Default_Scripts --
   ------------------------

   procedure Wp_Default_Scripts (Scripts : in out Class_Scripts.Wp_Scripts)
   is
      use Array_Lists;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Load;
      use Inc_Plugins;

      Suffix      : constant String := Wp_Scripts_Get_Suffix;
      Dev_Suffix  : constant String := Wp_Scripts_Get_Suffix ("dev");
      GuessURL    : UString := +Site_URL;
      Guessed_URL : Boolean := False;
   begin
      if GuessURL = "" then
         Guessed_URL := True;
         GuessURL    := +Wp_Guess_URL;
      end if;

      Scripts.Base_URL        := GuessURL;
      Scripts.Content_URL     := Constants.WP_CONTENT_URL; -- defined( "WP_CONTENT_URL" ) ? WP_CONTENT_URL : "";
      Scripts.Default_Version := +Get_Bloginfo ("version");
      Scripts.Default_Dirs    :=
        ["/wp-admin/js/", "/wp-includes/js/"];

      Scripts.Add ("utils", "/wp-includes/js/utils" & Suffix & ".js");
      if Did_Action ("init") then
         Scripts.Localize (
           "utils",
           "userSettings",
           To_Array_Type ([
             Build ("url",    -Constants.SITECOOKIEPATH), -- (string)
             Build ("uid",    Integer (Inc_Users.Get_Current_User_Id)), -- (string)
--           Build ("time",   (string) time(),
             Build ("secure", Boolean'Image ("https" = Php.HTML.Parse_URL (Site_URL, Php.HTML.PHP_URL_SCHEME)))
           ])
         );
      end if;

      Scripts.Add ("common", "/wp-admin/js/common" & Suffix & ".js",
                   ["jquery", "hoverIntent", "utils"], "(false)", 1);
      Scripts.Set_Translations ("common");

      Scripts.Add ("wp-sanitize", "/wp-includes/js/wp-sanitize" & Suffix & ".js",
                   Empty_List, "(false)", 1);

      Scripts.Add ("sack", "/wp-includes/js/tw-sack" & Suffix & ".js",
                   Empty_List, "1.6.1", 1);

      Scripts.Add ("quicktags", "/wp-includes/js/quicktags" & Suffix & ".js",
                   Empty_List, "(false)", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "quicktags",
           "quicktagsL10n",
           To_Array_Type ([
             Build ("closeAllOpenTags",      abs "Close all open tags"),
             Build ("closeTags",             abs "close tags"),
             Build ("enterURL",              abs "Enter the URL"),
             Build ("enterImageURL",         abs "Enter the URL of the image"),
             Build ("enterImageDescription", abs "Enter a description of the image"),
             Build ("textdirection",         abs "text direction"),
             Build ("toggleTextdirection",   abs "Toggle Editor Text Direction"),
             Build ("dfw",                   abs "Distraction-free writing mode"),
             Build ("strong",                abs "Bold"),
             Build ("strongClose",           abs "Close bold tag"),
             Build ("em",                    abs "Italic"),
             Build ("emClose",               abs "Close italic tag"),
             Build ("link",                  abs "Insert link"),
             Build ("blockquote",            abs "Blockquote"),
             Build ("blockquoteClose",       abs "Close blockquote tag"),
             Build ("del",                   abs "Deleted text (strikethrough)"),
             Build ("delClose",              abs "Close deleted text tag"),
             Build ("ins",                   abs "Inserted text"),
             Build ("insClose",              abs "Close inserted text tag"),
             Build ("image",                 abs "Insert image"),
             Build ("ul",                    abs "Bulleted list"),
             Build ("ulClose",               abs "Close bulleted list tag"),
             Build ("ol",                    abs "Numbered list"),
             Build ("olClose",               abs "Close numbered list tag"),
             Build ("li",                    abs "List item"),
             Build ("liClose",               abs "Close list item tag"),
             Build ("code",                  abs "Code"),
             Build ("codeClose",             abs "Close code tag"),
             Build ("more",                  abs "Insert Read More tag")
           ])
         );
      end if;

      Scripts.Add ("colorpicker", "/wp-includes/js/colorpicker" & Suffix & ".js",
                   ["prototype"], "3517m");

      Scripts.Add ("editor", "/wp-admin/js/editor" & Suffix & ".js",
                   ["utils", "jquery"], "(false)", 1);

      Scripts.Add ("clipboard", "/wp-includes/js/clipboard" & Suffix & ".js",
                   Empty_List, "2.0.11", 1);

      Scripts.Add ("wp-ajax-response", "/wp-includes/js/wp-ajax-response" & Suffix & ".js",
                   ["jquery", "wp-a11y"], "(false)", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "wp-ajax-response",
           "wpAjax",
           To_Array_Type ([
             Build ("noPerm", abs "Sorry, you are not allowed to do that."),
             Build ("broken", abs "Something went wrong.")
           ])
         );
      end if;

      Scripts.Add ("wp-api-request", "/wp-includes/js/api-request" & Suffix & ".js",
                   ["jquery"], "(false)", 1);

      -- `wpApiSettings` is also used by `wp-api`, which depends on this script.
      if Did_Action ("init") then
         Scripts.Localize (
           "wp-api-request",
           "wpApiSettings",
           To_Array_Type ([
             Build ("root",     Sanitize_URL (Inc_REST_API.Get_REST_URL)),
             Build ("nonce",    (if Globals.WP_INSTALLING then ""
                                 else Inc_Pluggables.Wp_Create_Nonce ("wp_rest"))),
             Build ("versionString", "wp/v2/")
           ])
         );
      end if;

      Scripts.Add ("wp-pointer", "/wp-includes/js/wp-pointer" & Suffix & ".js",
                   ["jquery-ui-core"], "(false)", 1);

      Scripts.Set_Translations ("wp-pointer");

      Scripts.Add ("autosave", "/wp-includes/js/autosave" & Suffix & ".js",
                   ["heartbeat"], "(false)", 1);

      Scripts.Add ("heartbeat", "/wp-includes/js/heartbeat" & Suffix & ".js",
                   ["jquery", "wp-hooks"], "(false)", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "heartbeat",
           "heartbeatSettings",
           --
           -- Filters the Heartbeat settings.
           --
           -- @since 3.6.0
           --
           -- @param array settings Heartbeat settings array.
           --
           Apply_Filters ("heartbeat_settings", Empty_Array)
         );
      end if;

      Scripts.Add ("wp-auth-check", "/wp-includes/js/wp-auth-check" & Suffix & ".js",
                   ["heartbeat"], "(false)", 1);

      Scripts.Set_Translations ("wp-auth-check");

      Scripts.Add ("wp-lists", "/wp-includes/js/wp-lists" & Suffix & ".js",
                   ["wp-ajax-response", "jquery-color"], "(false)", 1);

      -- WordPress no longer uses or bundles Prototype or script.aculo.us. These
      -- are now pulled from an external source.
      Scripts.Add (
        "prototype",
        "https://ajax.googleapis.com/ajax/libs/prototype/1.7.1.0/prototype.js",
        Empty_List, "1.7.1");
      Scripts.Add (
        "scriptaculous-root",
        "https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/scriptaculous.js",
        ["prototype"], "1.9.0");
      Scripts.Add (
        "scriptaculous-builder",
        "https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/builder.js",
        ["scriptaculous-root"], "1.9.0");
      Scripts.Add (
        "scriptaculous-dragdrop",
        "https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/dragdrop.js",
        ["scriptaculous-builder", "scriptaculous-effects"], "1.9.0");
      Scripts.Add (
        "scriptaculous-effects",
        "https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/effects.js",
        ["scriptaculous-root"], "1.9.0");
      Scripts.Add (
        "scriptaculous-slider",
        "https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/slider.js",
        ["scriptaculous-effects"], "1.9.0");
      Scripts.Add (
        "scriptaculous-sound",
        "https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/sound.js",
        ["scriptaculous-root"], "1.9.0");
      Scripts.Add (
        "scriptaculous-controls",
        "https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/controls.js",
        ["scriptaculous-root"], "1.9.0");
      Scripts.Add (
        "scriptaculous", False,
        ["scriptaculous-dragdrop", "scriptaculous-slider",
         "scriptaculous-controls"]);

      -- Not used in core, replaced by Jcrop.js.
      Scripts.Add ("cropper", "/wp-includes/js/crop/cropper.js",
                   ["scriptaculous-dragdrop"]);

      -- jQuery.
      -- The unminified jquery.js and jquery-migrate.js are included to facilitate
      -- debugging.
      Scripts.Add (
        "jquery", False,
        ["jquery-core", "jquery-migrate"], "3.6.1");
      Scripts.Add (
        "jquery-core",
        "/wp-includes/js/jquery/jquery" & Suffix & ".js", Empty_List, "3.6.1");
      Scripts.Add (
        "jquery-migrate",
        "/wp-includes/js/jquery/jquery-migrate" & Suffix & ".js", Empty_List, "3.3.2");

      -- Full jQuery UI.
      -- The build process in 1.12.1 has changed significantly.
      -- In order to keep backwards compatibility, and to keep the optimized loading,
      -- the source files were flattened and included with some modifications for AMD
      -- loading.
      -- A notable change is that "jquery-ui-core" now contains "jquery-ui-position"
      -- and "jquery-ui-widget".
      Scripts.Add (
        "jquery-ui-core",
        "/wp-includes/js/jquery/ui/core" & Suffix & ".js",
        ["jquery"], "1.13.2", 1);
      Scripts.Add (
        "jquery-effects-core",
        "/wp-includes/js/jquery/ui/effect" & Suffix & ".js",
        ["jquery"], "1.13.2", 1);

      Scripts.Add ("jquery-effects-blind", "/wp-includes/js/jquery/ui/effect-blind" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-bounce", "/wp-includes/js/jquery/ui/effect-bounce" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-clip", "/wp-includes/js/jquery/ui/effect-clip" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-drop", "/wp-includes/js/jquery/ui/effect-drop" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-explode", "/wp-includes/js/jquery/ui/effect-explode" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-fade", "/wp-includes/js/jquery/ui/effect-fade" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-fold", "/wp-includes/js/jquery/ui/effect-fold" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-highlight", "/wp-includes/js/jquery/ui/effect-highlight" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-puff", "/wp-includes/js/jquery/ui/effect-puff" & Suffix & ".js", ["jquery-effects-core", "jquery-effects-scale"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-pulsate", "/wp-includes/js/jquery/ui/effect-pulsate" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-scale", "/wp-includes/js/jquery/ui/effect-scale" & Suffix & ".js", ["jquery-effects-core", "jquery-effects-size"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-shake", "/wp-includes/js/jquery/ui/effect-shake" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-size", "/wp-includes/js/jquery/ui/effect-size" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-slide", "/wp-includes/js/jquery/ui/effect-slide" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);
      Scripts.Add ("jquery-effects-transfer", "/wp-includes/js/jquery/ui/effect-transfer" & Suffix & ".js", ["jquery-effects-core"], "1.13.2", 1);

      -- Widgets
      Scripts.Add ("jquery-ui-accordion", "/wp-includes/js/jquery/ui/accordion" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-autocomplete", "/wp-includes/js/jquery/ui/autocomplete" & Suffix & ".js", ["jquery-ui-menu", "wp-a11y"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-button", "/wp-includes/js/jquery/ui/button" & Suffix & ".js",
                   ["jquery-ui-core", "jquery-ui-controlgroup", "jquery-ui-checkboxradio"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-datepicker", "/wp-includes/js/jquery/ui/datepicker" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-dialog", "/wp-includes/js/jquery/ui/dialog" & Suffix & ".js",
                   ["jquery-ui-resizable", "jquery-ui-draggable", "jquery-ui-button"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-menu", "/wp-includes/js/jquery/ui/menu" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-mouse", "/wp-includes/js/jquery/ui/mouse" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-progressbar", "/wp-includes/js/jquery/ui/progressbar" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-selectmenu", "/wp-includes/js/jquery/ui/selectmenu" & Suffix & ".js", ["jquery-ui-menu"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-slider", "/wp-includes/js/jquery/ui/slider" & Suffix & ".js", ["jquery-ui-mouse"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-spinner", "/wp-includes/js/jquery/ui/spinner" & Suffix & ".js", ["jquery-ui-button"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-tabs", "/wp-includes/js/jquery/ui/tabs" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-tooltip", "/wp-includes/js/jquery/ui/tooltip" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);

      -- New in 1.12.1
      Scripts.Add ("jquery-ui-checkboxradio", "/wp-includes/js/jquery/ui/checkboxradio" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-controlgroup", "/wp-includes/js/jquery/ui/controlgroup" & Suffix & ".js", ["jquery-ui-core"], "1.13.2", 1);

      -- Interactions
      Scripts.Add ("jquery-ui-draggable", "/wp-includes/js/jquery/ui/draggable" & Suffix & ".js", ["jquery-ui-mouse"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-droppable", "/wp-includes/js/jquery/ui/droppable" & Suffix & ".js", ["jquery-ui-draggable"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-resizable", "/wp-includes/js/jquery/ui/resizable" & Suffix & ".js", ["jquery-ui-mouse"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-selectable", "/wp-includes/js/jquery/ui/selectable" & Suffix & ".js", ["jquery-ui-mouse"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-sortable", "/wp-includes/js/jquery/ui/sortable" & Suffix & ".js", ["jquery-ui-mouse"], "1.13.2", 1);

      -- As of 1.12.1 `jquery-ui-position` and `jquery-ui-widget` are part of `jquery-ui-core`.
      -- Listed here for back-compat.
      Scripts.Add ("jquery-ui-position", "(false)", ["jquery-ui-core"], "1.13.2", 1);
      Scripts.Add ("jquery-ui-widget", "(false)", ["jquery-ui-core"], "1.13.2", 1);

      -- Strings for "jquery-ui-autocomplete" live region messages.
      if Did_Action ("init") then
         Scripts.Localize (
           "jquery-ui-autocomplete",
           "uiAutocompleteL10n",
           To_Array_Type ([
             Build ("noResults",    abs "No results found."),
             -- translators: Number of results found when using jQuery UI Autocomplete.
             Build ("oneResult",    abs "1 result found. Use up and down arrow keys to navigate."),
             -- translators: %d: Number of results found when using jQuery UI Autocomplete.
             Build ("manyResults",  abs "%d results found. Use up and down arrow keys to navigate."),
             Build ("itemSelected", abs "Item selected.")
           ])
         );
      end if;

      -- Deprecated, not used in core, most functionality is included in jQuery 1.3.
      Scripts.Add ("jquery-form", "/wp-includes/js/jquery/jquery.form" & Suffix & ".js", ["jquery"], "4.3.0", 1);

      -- jQuery plugins.
      Scripts.Add ("jquery-color", "/wp-includes/js/jquery/jquery.color.min.js", ["jquery"], "2.2.0", 1);
      Scripts.Add ("schedule", "/wp-includes/js/jquery/jquery.schedule.js", ["jquery"], "20m", 1);
      Scripts.Add ("jquery-query", "/wp-includes/js/jquery/jquery.query.js", ["jquery"], "2.2.3", 1);
      Scripts.Add ("jquery-serialize-object", "/wp-includes/js/jquery/jquery.serialize-object.js", ["jquery"], "0.2-wp", 1);
      Scripts.Add ("jquery-hotkeys", "/wp-includes/js/jquery/jquery.hotkeys" & Suffix & ".js", ["jquery"], "0.0.2m", 1);
      Scripts.Add ("jquery-table-hotkeys", "/wp-includes/js/jquery/jquery.table-hotkeys" & Suffix & ".js", ["jquery", "jquery-hotkeys"], "(false)", 1);
      Scripts.Add ("jquery-touch-punch", "/wp-includes/js/jquery/jquery.ui.touch-punch.js", ["jquery-ui-core", "jquery-ui-mouse"], "0.2.2", 1);

      -- Not used any more, registered for backward compatibility.
      Scripts.Add ("suggest", "/wp-includes/js/jquery/suggest" & Suffix & ".js", ["jquery"], "1.1-20110113", 1);

      -- Masonry v2 depended on jQuery. v3 does not. The older jquery-masonry handle is a shiv.
      -- It sets jQuery as a dependency, as the theme may have been implicitly loading it this way.
      Scripts.Add ("imagesloaded", "/wp-includes/js/imagesloaded.min.js", Empty_List, "4.1.4", 1);
      Scripts.Add ("masonry", "/wp-includes/js/masonry.min.js", ["imagesloaded"], "4.2.2", 1);
      Scripts.Add ("jquery-masonry", "/wp-includes/js/jquery/jquery.masonry.min.js", ["jquery", "masonry"], "3.1.2b", 1);

      Scripts.Add ("thickbox", "/wp-includes/js/thickbox/thickbox.js", ["jquery"], "3.1-20121105", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "thickbox",
           "thickboxL10n",
           To_Array_Type ([
             Build ("next",             abs "Next &gt;"),
             Build ("prev",             abs "&lt; Prev"),
             Build ("image",            abs "Image"),
             Build ("of",               abs "of"),
             Build ("close",            abs "Close"),
             Build ("noiframes",        abs "This feature requires inline frames. You have iframes disabled or your browser does not support them."),
             Build ("loadingAnimation", Includes_URL ("js/thickbox/loadingAnimation.gif"))
           ])
         );
      end if;

      -- Not used in core, replaced by imgAreaSelect.
      Scripts.Add ("jcrop", "/wp-includes/js/jcrop/jquery.Jcrop.min.js", ["jquery"], "0.9.15");

      Scripts.Add ("swfobject", "/wp-includes/js/swfobject.js", Empty_List, "2.2-20120417");

      -- Error messages for Plupload.
      declare
         Uploader_L10n : constant Array_Type := To_Array_Type ([
           Build ("queue_limit_exceeded",      abs "You have attempted to queue too many files."),
           -- translators: %s: File name.
           Build ("file_exceeds_size_limit",   abs "%s exceeds the maximum upload size for this site."),
           Build ("zero_byte_file",            abs "This file is empty. Please try another."),
           Build ("invalid_filetype",          abs "Sorry, you are not allowed to upload this file type."),
           Build ("not_an_image",              abs "This file is not an image. Please try another."),
           Build ("image_memory_exceeded",     abs "Memory exceeded. Please try another smaller file."),
           Build ("image_dimensions_exceeded", abs "This is larger than the maximum size. Please try another."),
           Build ("default_error",             abs "An error occurred in the upload. Please try again later."),
           Build ("missing_upload_url",        abs "There was a configuration error. Please contact the server administrator."),
           Build ("upload_limit_exceeded",     abs "You may only upload 1 file."),
           Build ("http_error",                abs "Unexpected response from the server. The file may have been uploaded successfully. Check in the Media Library or reload the page."),
           Build ("http_error_image",          abs "The server cannot process the image. This can happen if the server is busy or does not have enough resources to complete the task. Uploading a smaller image may help. Suggested maximum size is 2560 pixels."),
           Build ("upload_failed",             abs "Upload failed."),
           -- translators: 1: Opening link tag, 2: Closing link tag.
           Build ("big_upload_failed",         abs "Please try uploading this file with the %1sbrowser uploader%2s."),
           -- translators: %s: File name.
           Build ("big_upload_queued",         abs "%s exceeds the maximum upload size for the multi-file uploader when used in your browser."),
           Build ("io_error",                  abs "IO error."),
           Build ("security_error",            abs "Security error."),
           Build ("file_cancelled",            abs "File canceled."),
           Build ("upload_stopped",            abs "Upload stopped."),
           Build ("dismiss",                   abs "Dismiss"),
           Build ("crunching",                 abs "Crunching&hellip;"),
           Build ("deleted",                   abs "moved to the Trash."),
           -- translators: %s: File name.
           Build ("error_uploading",           abs "&#8220;%s&#8221; has failed to upload."),
           Build ("unsupported_image",         abs "This image cannot be displayed in a web browser. For best results convert it to JPEG before uploading."),
           Build ("noneditable_image",         abs "This image cannot be processed by the web server. Convert it to JPEG or PNG before uploading."),
           Build ("file_url_copied",           abs "The file URL has been copied to your clipboard")
         ]);
      begin
         Scripts.Add ("moxiejs", "/wp-includes/js/plupload/moxie" & Suffix & ".js", Empty_List, "1.3.5");
         Scripts.Add ("plupload", "/wp-includes/js/plupload/plupload" & Suffix & ".js", ["moxiejs"], "2.1.9");

         -- Back compat handles:
         for Handle of List_Type'["all", "html5", "flash", "silverlight", "html4"] loop
            Scripts.Add ("plupload-" & Handle, "(false)", ["plupload"], "2.1.1");
         end loop;

         Scripts.Add (
           "plupload-handlers",
           "/wp-includes/js/plupload/handlers" & Suffix & ".js",
           ["clipboard", "jquery", "plupload", "underscore",
            "wp-a11y", "wp-i18n"]);

         if Did_Action ("init") then
            Scripts.Localize ("plupload-handlers", "pluploadL10n", Uploader_L10n);
         end if;

         Scripts.Add (
           "wp-plupload",
           "/wp-includes/js/plupload/wp-plupload" & Suffix & ".js",
           ["plupload", "jquery", "json2", "media-models"], "(false)", 1);

         if Did_Action ("init") then
            Scripts.Localize ("wp-plupload", "pluploadL10n", Uploader_L10n);
         end if;

         -- Keep "swfupload" for back-compat.
         Scripts.Add (
           "swfupload",
           "/wp-includes/js/swfupload/swfupload.js",
           Empty_List, "2201-20110113");
         Scripts.Add ("swfupload-all", "(false)", ["swfupload"], "2201");
         Scripts.Add (
           "swfupload-handlers",
           "/wp-includes/js/swfupload/handlers" & Suffix & ".js",
           ["swfupload-all", "jquery"], "2201-20110524");

         if Did_Action ("init") then
            Scripts.Localize ("swfupload-handlers", "swfuploadL10n", Uploader_L10n);
         end if;
      end;
      Scripts.Add (
        "comment-reply",
        "/wp-includes/js/comment-reply" & Suffix & ".js", Empty_List, "(false)", 1);

      Scripts.Add (
        "json2",
        "/wp-includes/js/json2" & Suffix & ".js", Empty_List, "2015-05-03");

      if Did_Action ("init") then
         Scripts.Add_Data ("json2", "conditional", "lt IE 8");
      end if;

      Scripts.Add ("underscore",
                   "/wp-includes/js/underscore" & Dev_Suffix & ".js",
                   Empty_List, "1.13.4", 1);

      Scripts.Add ("backbone",
                   "/wp-includes/js/backbone" & Dev_Suffix & ".js",
                   ["underscore", "jquery"], "1.4.1", 1);

      Scripts.Add ("wp-util",
                   "/wp-includes/js/wp-util" & Suffix & ".js",
                   ["underscore", "jquery"], "(false)", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "wp-util",
           "_wpUtilSettings",
           To_Array_Type ([
             Build ("ajax", To_Array_Type ([
               Build ("url", Admin_URL ("admin-ajax.php", "relative"))
           ]))
          ])
         );
      end if;

      Scripts.Add ("wp-backbone",
                   "/wp-includes/js/wp-backbone" & Suffix & ".js",
                   ["backbone", "wp-util"], "(false)", 1);

      Scripts.Add ("revisions",
                   "/wp-admin/js/revisions" & Suffix & ".js",
                   ["wp-backbone", "jquery-ui-slider",
                    "hoverIntent"], "(false)", 1);

      Scripts.Add ("imgareaselect",
                   "/wp-includes/js/imgareaselect/jquery.imgareaselect" &
                   Suffix & ".js",
                   ["jquery"], "(false)", 1);

      Scripts.Add ("mediaelement", False,
                   ["jquery", "mediaelement-core",
                    "mediaelement-migrate"],
                   "4.2.17", 1);

      Scripts.Add ("mediaelement-core",
                   "/wp-includes/js/mediaelement/mediaelement-and-player" &
                   Suffix & ".js",
                   Empty_List, "4.2.17", 1);

      Scripts.Add ("mediaelement-migrate",
                   "/wp-includes/js/mediaelement/mediaelement-migrate" &
                   Suffix & ".js", Empty_List, "(false)", 1);

      if Did_Action ("init") then
         Scripts.Add_Inline_Script (
           "mediaelement-core",
           Php.Strings.Sprintf (
             "var mejsL10n = %s;",
             [Wp_JSON_Encode (From_Array (
               To_Array_Type ([
                 Build ("language",
                        Php.Strings.Strtolower (Php.Strings.Strtok (Determine_Locale, "_-"))),
                 Build ("strings",  To_Array_Type ([
                 Build ("mejs.download-file",       abs "Download File"),
                 Build ("mejs.install-flash",       abs "You are using a browser that does not have Flash player enabled or installed. Please turn on your Flash player plugin or download the latest version from https://get.adobe.com/flashplayer/"),
                 Build ("mejs.fullscreen",          abs "Fullscreen"),
                 Build ("mejs.play",                abs "Play"),
                 Build ("mejs.pause",               abs "Pause"),
                 Build ("mejs.time-slider",         abs "Time Slider"),
                 Build ("mejs.time-help-text",      abs "Use Left/Right Arrow keys to advance one second, Up/Down arrows to advance ten seconds."),
                 Build ("mejs.live-broadcast",      abs "Live Broadcast"),
                 Build ("mejs.volume-help-text",    abs "Use Up/Down Arrow keys to increase or decrease volume."),
                 Build ("mejs.unmute",              abs "Unmute"),
                 Build ("mejs.mute",                abs "Mute"),
                 Build ("mejs.volume-slider",       abs "Volume Slider"),
                 Build ("mejs.video-player",        abs "Video Player"),
                 Build ("mejs.audio-player",        abs "Audio Player"),
                 Build ("mejs.captions-subtitles",  abs "Captions/Subtitles"),
                 Build ("mejs.captions-chapters",   abs "Chapters"),
                 Build ("mejs.none",                abs "None"),
                 Build ("mejs.afrikaans",           abs "Afrikaans"),
                 Build ("mejs.albanian",            abs "Albanian"),
                 Build ("mejs.arabic",              abs "Arabic"),
                 Build ("mejs.belarusian",          abs "Belarusian"),
                 Build ("mejs.bulgarian",           abs "Bulgarian"),
                 Build ("mejs.catalan",             abs "Catalan"),
                 Build ("mejs.chinese",             abs "Chinese"),
                 Build ("mejs.chinese-simplified",  abs "Chinese (Simplified)"),
                 Build ("mejs.chinese-traditional", abs "Chinese (Traditional)"),
                 Build ("mejs.croatian",            abs "Croatian"),
                 Build ("mejs.czech",               abs "Czech"),
                 Build ("mejs.danish",              abs "Danish"),
                 Build ("mejs.dutch",               abs "Dutch"),
                 Build ("mejs.english",             abs "English"),
                 Build ("mejs.estonian",            abs "Estonian"),
                 Build ("mejs.filipino",            abs "Filipino"),
                 Build ("mejs.finnish",             abs "Finnish"),
                 Build ("mejs.french",              abs "French"),
                 Build ("mejs.galician",            abs "Galician"),
                 Build ("mejs.german",              abs "German"),
                 Build ("mejs.greek",               abs "Greek"),
                 Build ("mejs.haitian-creole",      abs "Haitian Creole"),
                 Build ("mejs.hebrew",              abs "Hebrew"),
                 Build ("mejs.hindi",               abs "Hindi"),
                 Build ("mejs.hungarian",           abs "Hungarian"),
                 Build ("mejs.icelandic",           abs "Icelandic"),
                 Build ("mejs.indonesian",          abs "Indonesian"),
                 Build ("mejs.irish",               abs "Irish"),
                 Build ("mejs.italian",             abs "Italian"),
                 Build ("mejs.japanese",            abs "Japanese"),
                 Build ("mejs.korean",              abs "Korean"),
                 Build ("mejs.latvian",             abs "Latvian"),
                 Build ("mejs.lithuanian",          abs "Lithuanian"),
                 Build ("mejs.macedonian",          abs "Macedonian"),
                 Build ("mejs.malay",               abs "Malay"),
                 Build ("mejs.maltese",             abs "Maltese"),
                 Build ("mejs.norwegian",           abs "Norwegian"),
                 Build ("mejs.persian",             abs "Persian"),
                 Build ("mejs.polish",              abs "Polish"),
                 Build ("mejs.portuguese",          abs "Portuguese"),
                 Build ("mejs.romanian",            abs "Romanian"),
                 Build ("mejs.russian",             abs "Russian"),
                 Build ("mejs.serbian",             abs "Serbian"),
                 Build ("mejs.slovak",              abs "Slovak"),
                 Build ("mejs.slovenian",           abs "Slovenian"),
                 Build ("mejs.spanish",             abs "Spanish"),
                 Build ("mejs.swahili",             abs "Swahili"),
                 Build ("mejs.swedish",             abs "Swedish"),
                 Build ("mejs.tagalog",             abs "Tagalog"),
                 Build ("mejs.thai",                abs "Thai"),
                 Build ("mejs.turkish",             abs "Turkish"),
                 Build ("mejs.ukrainian",           abs "Ukrainian"),
                 Build ("mejs.vietnamese",          abs "Vietnamese"),
                 Build ("mejs.welsh",               abs "Welsh"),
                 Build ("mejs.yiddish",             abs "Yiddish")
               ]))
             ]))
           )]
           ),
           "before"
         );
      end if;

      Scripts.Add ("mediaelement-vimeo",
                   "/wp-includes/js/mediaelement/renderers/vimeo.min.js",
                   ["mediaelement"], "4.2.17", 1);
      Scripts.Add ("wp-mediaelement",
                   "/wp-includes/js/mediaelement/wp-mediaelement" & Suffix & ".js",
                   ["mediaelement"], "(false)", 1);

      declare
         Mejs_Settings : constant Array_Type := To_Array_Type ([
           Build ("pluginPath",  Includes_URL ("js/mediaelement/", "relative")),
           Build ("classPrefix", "mejs-"),
           Build ("stretching",  "responsive")
         ]);
      begin
         if Did_Action ("init") then
            Scripts.Localize (
              "mediaelement",
              "_wpmejsSettings",
              --
              -- Filters the MediaElement configuration settings.
              --
              -- @since 4.4.0
              --
              -- @param array mejs_settings MediaElement settings array.
              --
              Apply_Filters ("mejs_settings", Mejs_Settings)
            );
         end if;
      end;

      Scripts.Add ("wp-codemirror", "/wp-includes/js/codemirror/codemirror.min.js", Empty_List, "5.29.1-alpha-ee20357");
      Scripts.Add ("csslint", "/wp-includes/js/codemirror/csslint.js", Empty_List, "1.0.5");
      Scripts.Add ("esprima", "/wp-includes/js/codemirror/esprima.js", Empty_List, "4.0.0");
      Scripts.Add ("jshint", "/wp-includes/js/codemirror/fakejshint.js", ["esprima"], "2.9.5");
      Scripts.Add ("jsonlint", "/wp-includes/js/codemirror/jsonlint.js", Empty_List, "1.6.2");
      Scripts.Add ("htmlhint", "/wp-includes/js/codemirror/htmlhint.js", Empty_List, "0.9.14-xwp");
      Scripts.Add ("htmlhint-kses", "/wp-includes/js/codemirror/htmlhint-kses.js", ["htmlhint"]);
      Scripts.Add ("code-editor", "/wp-admin/js/code-editor" & Suffix & ".js",
                   ["jquery", "wp-codemirror", "underscore"]);
      Scripts.Add (
        "wp-theme-plugin-editor",
        "/wp-admin/js/theme-plugin-editor" & Suffix & ".js",
        ["common", "wp-util", "wp-sanitize", "jquery", "jquery-ui-core",
         "wp-a11y", "underscore"]);
      Scripts.Set_Translations ("wp-theme-plugin-editor");

      Scripts.Add (
        "wp-playlist",
        "/wp-includes/js/mediaelement/wp-playlist" & Suffix & ".js",
        ["wp-util", "backbone", "mediaelement"], "(false)", 1);

      Scripts.Add (
        "zxcvbn-async",
        "/wp-includes/js/zxcvbn-async" & Suffix & ".js", Empty_List, "1.0");

      if Did_Action ("init") then
         Scripts.Localize (
           "zxcvbn-async",
           "_zxcvbnSettings",
           To_Array_Type ([1 =>
             Build ("src", (if not Guessed_URL
                            then Includes_URL ("/js/zxcvbn.min.js")
                            else -Scripts.Base_URL & "/wp-includes/js/zxcvbn.min.js"))
           ])
         );
      end if;

      Scripts.Add (
        "password-strength-meter",
        "/wp-admin/js/password-strength-meter" & Suffix & ".js",
        ["jquery", "zxcvbn-async"], "(false)", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "password-strength-meter",
           "pwsL10n",
           To_Array_Type ([
             Build ("unknown",  X_X ("Password strength unknown", "password strength")),
             Build ("short",    X_X ("Very weak", "password strength")),
             Build ("bad",      X_X ("Weak", "password strength")),
             Build ("good",     X_X ("Medium", "password strength")),
             Build ("strong",   X_X ("Strong", "password strength")),
             Build ("mismatch", X_X ("Mismatch", "password mismatch"))
           ])
         );
      end if;

      Scripts.Set_Translations ("password-strength-meter");

      Scripts.Add (
        "application-passwords",
        "/wp-admin/js/application-passwords" & Suffix & ".js",
        ["jquery", "wp-util", "wp-api-request", "wp-date",
         "wp-i18n", "wp-hooks"], "(false)", 1);
      Scripts.Set_Translations ("application-passwords");

      Scripts.Add (
        "auth-app",
        "/wp-admin/js/auth-app" & Suffix & ".js",
        ["jquery", "wp-api-request", "wp-i18n", "wp-hooks"], "(false)", 1);
      Scripts.Set_Translations ("auth-app");

      Scripts.Add (
        "user-profile",
        "/wp-admin/js/user-profile" & Suffix & ".js",
        ["jquery", "password-strength-meter", "wp-util"], "(false)", 1);
      Scripts.Set_Translations ("user-profile");

      declare
         User_Id : constant Integer :=
           (if Isset (XX_GET, "user_id")
            then As_Integer (Get (XX_GET, "user_id")) else 0);
      begin
         if Did_Action ("init") then
            Scripts.Localize (
              "user-profile",
              "userProfileL10n",
              To_Array_Type ([
                Build ("user_id", User_Id),
                Build ("nonce",
                  (if Wp_Installing then ""
                   else Inc_Pluggables.Wp_Create_Nonce ("reset-password-for-" & Helpers.Image (User_Id))))
              ])
            );
         end if;
      end;

      Scripts.Add ("language-chooser", "/wp-admin/js/language-chooser" & Suffix & ".js", ["jquery"], "(false)", 1);

      Scripts.Add ("user-suggest", "/wp-admin/js/user-suggest" & Suffix & ".js", ["jquery-ui-autocomplete"], "(false)", 1);

      Scripts.Add ("admin-bar", "/wp-includes/js/admin-bar" & Suffix & ".js", ["hoverintent-js"], "(false)", 1);

      Scripts.Add ("wplink", "/wp-includes/js/wplink" & Suffix & ".js", ["jquery", "wp-a11y"], "(false)", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "wplink",
           "wpLinkL10n",
           To_Array_Type ([
             Build ("title",          abs "Insert/edit link"),
             Build ("update",         abs "Update"),
             Build ("save",           abs "Add Link"),
             Build ("noTitle",        abs "(no title)"),
             Build ("noMatchesFound", abs "No results found."),
             Build ("linkSelected",   abs "Link selected."),
             Build ("linkInserted",   abs "Link inserted."),
             -- translators: Minimum input length in characters to start searching posts in the "Insert/edit link" modal.
             Build ("minInputLength", "XXX-930") -- XXX -- Integer'Value (X_X ("3", "minimum input length for searching post links")))
           ])
         );
      end if;

      Scripts.Add ("wpdialogs", "/wp-includes/js/wpdialog" & Suffix & ".js", ["jquery-ui-dialog"], "(false)", 1);

      Scripts.Add ("word-count", "/wp-admin/js/word-count" & Suffix & ".js", Empty_List, "(false)", 1);

      Scripts.Add ("media-upload", "/wp-admin/js/media-upload" & Suffix & ".js", ["thickbox", "shortcode"], "(false)", 1);

      Scripts.Add ("hoverIntent", "/wp-includes/js/hoverIntent" & Suffix & ".js", ["jquery"], "1.10.2", 1);

      -- JS-only version of hoverintent (no dependencies).
      Scripts.Add ("hoverintent-js", "/wp-includes/js/hoverintent-js.min.js", Empty_List, "2.2.1", 1);

      Scripts.Add ("customize-base", "/wp-includes/js/customize-base" & Suffix & ".js",
                   ["jquery", "json2", "underscore"], "(false)", 1);
      Scripts.Add ("customize-loader",
                   "/wp-includes/js/customize-loader" & Suffix & ".js",
                   ["customize-base"], "(false)", 1);
      Scripts.Add ("customize-preview",
                   "/wp-includes/js/customize-preview" & Suffix & ".js",
                   ["wp-a11y", "customize-base"], "(false)", 1);
      Scripts.Add ("customize-models", "/wp-includes/js/customize-models.js",
                   ["underscore", "backbone"], "(false)", 1);
      Scripts.Add ("customize-views", "/wp-includes/js/customize-views.js",
                   ["jquery", "underscore", "imgareaselect", "customize-models",
                    "media-editor", "media-views"], "(false)", 1);
      Scripts.Add ("customize-controls",
                   "/wp-admin/js/customize-controls" & Suffix & ".js",
                   ["customize-base", "wp-a11y", "wp-util", "jquery-ui-core"],
                   "(false)", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "customize-controls",
           "_wpCustomizeControlsL10n",
           To_Array_Type ([
             Build ("activate",                abs "Activate &amp; Publish"),
             Build ("save",                    abs "Save &amp; Publish"),
             -- @todo Remove as not required.
             Build ("publish",                 abs "Publish"),
             Build ("published",               abs "Published"),
             Build ("saveDraft",               abs "Save Draft"),
             Build ("draftSaved",              abs "Draft Saved"),
             Build ("updating",                abs "Updating"),
             Build ("schedule",                X_X ("Schedule", "customizer changeset action/button label")),
             Build ("scheduled",               X_X ("Scheduled", "customizer changeset status")),
             Build ("invalid",                 abs "Invalid"),
             Build ("saveBeforeShare",         abs "Please save your changes in order to share the preview."),
             Build ("futureDateError",         abs "You must supply a future date to schedule."),
             Build ("saveAlert",               abs "The changes you made will be lost if you navigate away from this page."),
             Build ("saved",                   abs "Saved"),
             Build ("cancel",                  abs "Cancel"),
             Build ("close",                   abs "Close"),
             Build ("action",                  abs "Action"),
             Build ("discardChanges",          abs "Discard changes"),
             Build ("cheatin",                 abs "Something went wrong."),
             Build ("notAllowedHeading",       abs "You need a higher level of permission."),
             Build ("notAllowed",              abs "Sorry, you are not allowed to customize this site."),
             Build ("previewIframeTitle",      abs "Site Preview"),
             Build ("loginIframeTitle",        abs "Session expired"),
             Build ("collapseSidebar",         X_X ("Hide Controls", "label for hide controls button without length constraints")),
             Build ("expandSidebar",           X_X ("Show Controls", "label for hide controls button without length constraints")),
             Build ("untitledBlogName",        abs "(Untitled)"),
             Build ("unknownRequestFail",      abs "Looks like something&#8217;s gone wrong. Wait a couple seconds, and then try again."),
             Build ("themeDownloading",        abs "Downloading your new theme&hellip;"),
             Build ("themePreviewWait",        abs "Setting up your live preview. This may take a bit."),
             Build ("revertingChanges",        abs "Reverting unpublished changes&hellip;"),
             Build ("trashConfirm",            abs "Are you sure you want to discard your unpublished changes?"),
             -- translators: %s: Display name of the user who has taken over the changeset in customizer.
             Build ("takenOverMessage",        abs "%s has taken over and is currently customizing."),
             -- translators: %s: URL to the Customizer to load the autosaved version.
             Build ("autosaveNotice",          abs "There is a more recent autosave of your changes than the one you are previewing. <a href=""%s"">Restore the autosave</a>"),
             Build ("videoHeaderNotice",       abs "This theme does not support video headers on this page. Navigate to the front page or another page that supports video headers."),
             -- Used for overriding the file types allowed in Plupload.
             Build ("allowedFiles",            abs "Allowed Files"),
             Build ("customCssError",          To_Array_Type ([
               -- translators: %d: Error count.
               Build ("singular", X_N ("There is %d error which must be fixed before you can save.", "There are %d errors which must be fixed before you can save.", 1)),
               -- translators: %d: Error count.
               Build ("plural",   X_N ("There is %d error which must be fixed before you can save.", "There are %d errors which must be fixed before you can save.", 2))
               -- @todo This is lacking, as some languages have a dedicated dual
               -- form. For proper handling of plurals in JS, see #20491.
             ])),
             Build ("pageOnFrontError",        abs "Homepage and posts page must be different."),
             Build ("saveBlockedError",        To_Array_Type ([
                -- translators: %s: Number of invalid settings.
                Build ("singular", X_N ("Unable to save due to %s invalid setting.", "Unable to save due to %s invalid settings.", 1)),
                -- translators: %s: Number of invalid settings.
                Build ("plural",   X_N ("Unable to save due to %s invalid setting.", "Unable to save due to %s invalid settings.", 2))
                -- @todo This is lacking, as some languages have a dedicated dual
                -- form. For proper handling of plurals in JS, see #20491.
              ])),
              Build ("scheduleDescription",     abs "Schedule your customization changes to publish ('go live') at a future date."),
              Build ("themePreviewUnavailable", abs "Sorry, you cannot preview new themes when you have changes scheduled or saved as a draft. Please publish your changes, or wait until they publish to preview new themes."),
              Build ("themeInstallUnavailable", Php.Strings.Sprintf (
                -- translators: %s: URL to Add Themes admin screen.
                abs "You will not be able to install new themes from here yet since your install requires SFTP credentials. For now, please <a href=""%s"">add themes in the admin</a>.",
                [1 => ESC_URL (Admin_URL ("theme-install.php"))])
              ),
              Build ("publishSettings",         abs "Publish Settings"),
              Build ("invalidDate",             abs "Invalid date."),
              Build ("invalidValue",            abs "Invalid value."),
              Build ("blockThemeNotification",
                Php.Strings.Sprintf (
                  -- translators: 1: Link to Site Editor documentation on HelpHub, 2: HTML button.--
                  abs "Hurray! Your theme supports site editing with blocks. <a href=""%1s"">Tell me more</a>. %2s",
                  [
                    1 => abs "https://wordpress.org/support/article/site-editor/",
                    2 => Php.Strings.Sprintf (
                      "<button type=""button"" data-action=""%1s"" class=""button switch-to-editor"">%2s</button>",
                      [
                        1 => ESC_URL (Admin_URL ("site-editor.php")),
                        2 => abs "Use Site Editor"
                      ]
                    )
                  ]
                ))
                ])
         );
      end if;

      Scripts.Add (
        "customize-selective-refresh",
        "/wp-includes/js/customize-selective-refresh" & Suffix & ".js",
        ["jquery", "wp-util", "customize-preview"], "(false)", 1);

      Scripts.Add (
        "customize-widgets",
        "/wp-admin/js/customize-widgets" & Suffix & ".js",
        ["jquery", "jquery-ui-sortable", "jquery-ui-droppable",
         "wp-backbone", "customize-controls"], "(false)", 1);
      Scripts.Add (
        "customize-preview-widgets",
        "/wp-includes/js/customize-preview-widgets" & Suffix & ".js",
        ["jquery", "wp-util", "customize-preview",
         "customize-selective-refresh"], "(false)", 1);

      Scripts.Add ("customize-nav-menus",
                   "/wp-admin/js/customize-nav-menus" & Suffix & ".js",
                   ["jquery", "wp-backbone", "customize-controls",
                    "accordion", "nav-menu", "wp-sanitize"], "(false)", 1);
      Scripts.Add (
        "customize-preview-nav-menus",
        "/wp-includes/js/customize-preview-nav-menus" & Suffix & ".js",
        ["jquery", "wp-util", "customize-preview",
         "customize-selective-refresh"], "(false)", 1);

      Scripts.Add ("wp-custom-header",
                   "/wp-includes/js/wp-custom-header" & Suffix & ".js",
                   ["wp-a11y"], "(false)", 1);

      Scripts.Add ("accordion",
                   "/wp-admin/js/accordion" & Suffix & ".js",
                   ["jquery"], "(false)", 1);

      Scripts.Add ("shortcode",
                   "/wp-includes/js/shortcode" & Suffix & ".js",
                   ["underscore"], "(false)", 1);
      Scripts.Add ("media-models",
                   "/wp-includes/js/media-models" & Suffix & ".js",
                   ["wp-backbone"], "(false)", 1);

      if Did_Action ("init") then
         Scripts.Localize (
           "media-models",
           "_wpMediaModelsL10n",
           To_Array_Type ([1 =>
             Build ("settings", To_Array_Type ([
               Build ("ajaxurl", Admin_URL ("admin-ajax.php", "relative")),
               Build ("post",    To_Array_Type ([Build ("id", 0)]))
             ]))
           ])
         );
      end if;
      Scripts.Add ("wp-embed",
                   "/wp-includes/js/wp-embed" & Suffix & ".js",
                   Empty_List, "(false)", 1);

      -- To enqueue media-views or media-editor, call wp_enqueue_media().
      -- Both rely on numerous settings, styles, and templates to operate correctly.
      Scripts.Add ("media-views", "/wp-includes/js/media-views" & Suffix & ".js",
                   ["utils", "media-models", "wp-plupload", "jquery-ui-sortable",
                    "wp-mediaelement", "wp-api-request", "wp-a11y", "clipboard"],
                    "(false)", 1);
      Scripts.Set_Translations ("media-views");

      Scripts.Add ("media-editor", "/wp-includes/js/media-editor" & Suffix & ".js",
                   ["shortcode", "media-views"], "(false)", 1);
      Scripts.Set_Translations ("media-editor");
      Scripts.Add ("media-audiovideo",
                   "/wp-includes/js/media-audiovideo" & Suffix & ".js",
                   ["media-editor"], "(false)", 1);
      Scripts.Add (
        "mce-view", "/wp-includes/js/mce-view" & Suffix & ".js",
        ["shortcode", "jquery", "media-views", "media-audiovideo"], "(false)", 1);

      Scripts.Add (
        "wp-api", "/wp-includes/js/wp-api" & Suffix & ".js",
        ["jquery", "backbone", "underscore", "wp-api-request"], "(false)", 1);

      if Is_Admin then
         Scripts.Add ("admin-tags", "/wp-admin/js/tags" & Suffix & ".js",
                      ["jquery", "wp-ajax-response"], "(false)", 1);
         Scripts.Set_Translations ("admin-tags");

         Scripts.Add ("admin-comments", "/wp-admin/js/edit-comments" & Suffix & ".js",
                      ["wp-lists", "quicktags", "jquery-query"], "(false)", 1);
         Scripts.Set_Translations ("admin-comments");
         if Did_Action ("init") then
            Scripts.Localize (
              "admin-comments",
              "adminCommentsSettings",
              To_Array_Type ([
                Build ("hotkeys_highlight_first", Isset (XX_GET, "hotkeys_highlight_first")),
                Build ("hotkeys_highlight_last",  Isset (XX_GET, "hotkeys_highlight_last"))
              ])
            );
         end if;

         Scripts.Add ("xfn", "/wp-admin/js/xfn" & Suffix & ".js", ["jquery"], "(false)", 1);

         Scripts.Add ("postbox", "/wp-admin/js/postbox" & Suffix & ".js", ["jquery-ui-sortable", "wp-a11y"], "(false)", 1);
         Scripts.Set_Translations ("postbox");

         Scripts.Add ("tags-box", "/wp-admin/js/tags-box" & Suffix & ".js", ["jquery", "tags-suggest"], "(false)", 1);
         Scripts.Set_Translations ("tags-box");

         Scripts.Add ("tags-suggest", "/wp-admin/js/tags-suggest" & Suffix & ".js", ["jquery-ui-autocomplete", "wp-a11y"], "(false)", 1);
         Scripts.Set_Translations ("tags-suggest");

         Scripts.Add (
           "post", "/wp-admin/js/post" & Suffix & ".js",
           ["suggest", "wp-lists", "postbox", "tags-box", "underscore",
            "word-count", "wp-a11y", "wp-sanitize", "clipboard"], "(false)", 1);
         Scripts.Set_Translations ("post");

         Scripts.Add ("editor-expand", "/wp-admin/js/editor-expand" & Suffix & ".js", ["jquery", "underscore"], "(false)", 1);

         Scripts.Add ("link", "/wp-admin/js/link" & Suffix & ".js", ["wp-lists", "postbox"], "(false)", 1);

         Scripts.Add ("comment", "/wp-admin/js/comment" & Suffix & ".js", ["jquery", "postbox"], "(false)", 1);
         Scripts.Set_Translations ("comment");

         Scripts.Add ("admin-gallery", "/wp-admin/js/gallery" & Suffix & ".js", ["jquery-ui-sortable"]);

         Scripts.Add ("admin-widgets", "/wp-admin/js/widgets" & Suffix & ".js", ["jquery-ui-sortable", "jquery-ui-draggable", "jquery-ui-droppable", "wp-a11y"], "(false)", 1);
         Scripts.Set_Translations ("admin-widgets");

         Scripts.Add ("media-widgets", "/wp-admin/js/widgets/media-widgets" & Suffix & ".js", ["jquery", "media-models", "media-views", "wp-api-request"]);
         Scripts.Add_Inline_Script ("media-widgets", "wp.mediaWidgets.init();", "after");

         Scripts.Add ("media-audio-widget", "/wp-admin/js/widgets/media-audio-widget" & Suffix & ".js", ["media-widgets", "media-audiovideo"]);
         Scripts.Add ("media-image-widget", "/wp-admin/js/widgets/media-image-widget" & Suffix & ".js", ["media-widgets"]);
         Scripts.Add ("media-gallery-widget", "/wp-admin/js/widgets/media-gallery-widget" & Suffix & ".js", ["media-widgets"]);
         Scripts.Add ("media-video-widget", "/wp-admin/js/widgets/media-video-widget" & Suffix & ".js", ["media-widgets", "media-audiovideo", "wp-api-request"]);
         Scripts.Add ("text-widgets", "/wp-admin/js/widgets/text-widgets" & Suffix & ".js", ["jquery", "backbone", "editor", "wp-util", "wp-a11y"]);
         Scripts.Add ("custom-html-widgets", "/wp-admin/js/widgets/custom-html-widgets" & Suffix & ".js", ["jquery", "backbone", "wp-util", "jquery-ui-core", "wp-a11y"]);

         Scripts.Add ("theme", "/wp-admin/js/theme" & Suffix & ".js", ["wp-backbone", "wp-a11y", "customize-base"], "(false)", 1);

         Scripts.Add ("inline-edit-post", "/wp-admin/js/inline-edit-post" & Suffix & ".js", ["jquery", "tags-suggest", "wp-a11y"], "(false)", 1);
         Scripts.Set_Translations ("inline-edit-post");

         Scripts.Add ("inline-edit-tax", "/wp-admin/js/inline-edit-tax" & Suffix & ".js", ["jquery", "wp-a11y"], "(false)", 1);
         Scripts.Set_Translations ("inline-edit-tax");

         Scripts.Add ("plugin-install", "/wp-admin/js/plugin-install" & Suffix & ".js", ["jquery", "jquery-ui-core", "thickbox"], "(false)", 1);
         Scripts.Set_Translations ("plugin-install");

         Scripts.Add ("site-health", "/wp-admin/js/site-health" & Suffix & ".js", ["clipboard", "jquery", "wp-util", "wp-a11y", "wp-api-request", "wp-url", "wp-i18n", "wp-hooks"], "(false)", 1);
         Scripts.Set_Translations ("site-health");

         Scripts.Add ("privacy-tools", "/wp-admin/js/privacy-tools" & Suffix & ".js", ["jquery", "wp-a11y"], "(false)", 1);
         Scripts.Set_Translations ("privacy-tools");

         Scripts.Add ("updates", "/wp-admin/js/updates" & Suffix & ".js", ["common", "jquery", "wp-util", "wp-a11y", "wp-sanitize", "wp-i18n"], "(false)", 1);
         Scripts.Set_Translations ("updates");

         if Did_Action ("init") then
            Scripts.Localize (
              "updates",
              "_wpUpdatesSettings",
              To_Array_Type ([1 =>
                Build ("ajax_nonce", (if Wp_Installing then "" else Inc_Pluggables.Wp_Create_Nonce ("updates")))
              ])
            );
         end if;

         Scripts.Add ("farbtastic", "/wp-admin/js/farbtastic.js", ["jquery"], "1.2");

         Scripts.Add ("iris", "/wp-admin/js/iris.min.js", ["jquery-ui-draggable", "jquery-ui-slider", "jquery-touch-punch"], "1.1.1", 1);
         Scripts.Add ("wp-color-picker", "/wp-admin/js/color-picker" & Suffix & ".js", ["iris"], "(false)", 1);
         Scripts.Set_Translations ("wp-color-picker");

         Scripts.Add ("dashboard", "/wp-admin/js/dashboard" & Suffix & ".js", ["jquery", "admin-comments", "postbox", "wp-util", "wp-a11y", "wp-date"], "(false)", 1);
         Scripts.Set_Translations ("dashboard");

         Scripts.Add ("list-revisions", "/wp-includes/js/wp-list-revisions" & Suffix & ".js");

         Scripts.Add ("media-grid", "/wp-includes/js/media-grid" & Suffix & ".js", ["media-editor"], "(false)", 1);
         Scripts.Add ("media", "/wp-admin/js/media" & Suffix & ".js", ["jquery", "clipboard", "wp-i18n", "wp-a11y"], "(false)", 1);
         Scripts.Set_Translations ("media");

         Scripts.Add ("image-edit", "/wp-admin/js/image-edit" & Suffix & ".js", ["jquery", "jquery-ui-core", "json2", "imgareaselect", "wp-a11y"], "(false)", 1);
         Scripts.Set_Translations ("image-edit");

         Scripts.Add ("set-post-thumbnail", "/wp-admin/js/set-post-thumbnail" & Suffix & ".js", ["jquery"], "(false)", 1);
         Scripts.Set_Translations ("set-post-thumbnail");

         --
         -- Navigation Menus: Adding underscore as a dependency to utilize _.debounce
         -- see https://core.trac.wordpress.org/ticket/42321
         --
         Scripts.Add ("nav-menu", "/wp-admin/js/nav-menu" & Suffix & ".js", ["jquery-ui-sortable", "jquery-ui-draggable", "jquery-ui-droppable", "wp-lists", "postbox", "json2", "underscore"]);
         Scripts.Set_Translations ("nav-menu");

         Scripts.Add ("custom-header", "/wp-admin/js/custom-header.js", ["jquery-masonry"], "(false)", 1);
         Scripts.Add ("custom-background", "/wp-admin/js/custom-background" & Suffix & ".js", ["wp-color-picker", "media-views"], "(false)", 1);
         Scripts.Add ("media-gallery", "/wp-admin/js/media-gallery" & Suffix & ".js", ["jquery"], "(false)", 1);

         Scripts.Add ("svg-painter", "/wp-admin/js/svg-painter.js", ["jquery"], "(false)", 1);
      end if;
   end Wp_Default_Scripts;

   ------------------------
   -- Wp_Default_Scripts --
   ------------------------

   function Wp_Default_Scripts
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Array_Type
   is
      pragma Unreferenced (Arry);
   begin
      Wp_Default_Scripts (Globals.Global_Wp_Scripts);
      return Empty_Array;
   end Wp_Default_Scripts;

   Global_Editor_Styles : Array_Type;

   -----------------------
   -- Wp_Default_Styles --
   -----------------------

   procedure Wp_Default_Styles (Styles : in out Class_Styles.Wp_Styles)
   is
      use Array_Lists;
      use UStrings;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_L10n;
      use Inc_Link_Templates;

--         global editor_styles;
      Guess_URL : constant String :=
        (if Site_URL = ""
         then Wp_Guess_URL
         else Site_URL);

      Open_Sans_Font_URL : UString;
   begin
      -- -- Include an unmodified wp_version.
      -- require ABSPATH . WPINC . "/version.php";

      -- if ( ! defined( "SCRIPT_DEBUG" ) ) then
      --         define( "SCRIPT_DEBUG", False !== strpos( wp_version, "-src" ));
      -- end;

      Styles.Base_URL        := +Guess_URL;
      Styles.Content_URL     := Constants.WP_CONTENT_URL; --  ) ? WP_CONTENT_URL : "";
      Styles.Default_Version := +Get_Bloginfo ("version");
      Styles.Text_Direction  := +(if Is_RTL then "rtl" else "ltr");
--    Styles.Text_Direction  := function_exists( "is_rtl" ) && (if is_rtl then "rtl" else "ltr");
      Styles.Default_Dirs :=
        ["/wp-admin/", "/wp-includes/css/"];

      -- Open Sans is no longer used by core, but may be relied upon by themes
      -- and plugins.
      Open_Sans_Font_URL := Null_UString;

      --
      -- translators: If there are characters in your language that are not supported
      -- by Open Sans, translate this to "off". Do not translate into your own
      -- language.
      --
      if "off" /= X_X ("on", "Open Sans font: on or off") then
         declare
            --
            -- translators: To add an additional Open Sans character subset specific
            -- to your language, translate this to "greek", "cyrillic" or
            -- "vietnamese". Do not translate into your own language.
            --
            Subset : constant String :=
               X_X ("no-subset",
                    "Open Sans font: add new subset (greek, cyrillic, vietnamese)");

            Subsets : constant String :=
              (if "cyrillic" = Subset
                 then "latin,latin-ext,cyrillic,cyrillic-ext"
               elsif "greek" = Subset
                 then "latin,latin-ext,greek,greek-ext"
               elsif "vietnamese" = Subset
                 then "latin,latin-ext,vietnamese"
               else   "latin,latin-ext");
         begin
            -- Hotlink Open Sans, for now.
            Open_Sans_Font_URL :=
              +"https://fonts.googleapis.com/css?" &
              "family=Open+Sans:300italic,400italic,600italic,300,400,600&" &
              "subset=" & Subsets & "&display=fallback";
         end;
      end if;

      -- Register a stylesheet for the selected admin color scheme.
      Styles.Add ("colors", "true",    -- True
                  ["wp-admin", "buttons"]);

      declare
         Suffix : constant String :=
           (if Constants.SCRIPT_DEBUG then "" else ".min");
      begin
         -- Admin CSS.
         Styles.Add ("common",      "/wp-admin/css/common" & Suffix & ".css");
         Styles.Add ("forms",       "/wp-admin/css/forms" & Suffix & ".css");
         Styles.Add ("admin-menu",  "/wp-admin/css/admin-menu" & Suffix & ".css");
         Styles.Add ("dashboard",   "/wp-admin/css/dashboard" & Suffix & ".css");
         Styles.Add ("list-tables", "/wp-admin/css/list-tables" & Suffix & ".css");
         Styles.Add ("edit",        "/wp-admin/css/edit" & Suffix & ".css");
         Styles.Add ("revisions",   "/wp-admin/css/revisions" & Suffix & ".css");
         Styles.Add ("media",       "/wp-admin/css/media" & Suffix & ".css");
         Styles.Add ("themes",      "/wp-admin/css/themes" & Suffix & ".css");
         Styles.Add ("about",       "/wp-admin/css/about" & Suffix & ".css");
         Styles.Add ("nav-menus",   "/wp-admin/css/nav-menus" & Suffix & ".css");
         Styles.Add ("widgets",
                     "/wp-admin/css/widgets" & Suffix & ".css",
                     ["wp-pointer"]);
         Styles.Add ("site-icon",   "/wp-admin/css/site-icon" & Suffix & ".css");
         Styles.Add ("l10n",        "/wp-admin/css/l10n" & Suffix & ".css");
         Styles.Add ("code-editor", "/wp-admin/css/code-editor" & Suffix & ".css",
                     ["wp-codemirror"]);
--                   ["wp-codemirror"));
         Styles.Add ("site-health", "/wp-admin/css/site-health" & Suffix & ".css");

         Styles.Add ("wp-admin", "False", -- False
                     ["dashicons", "common",
                      "forms", "admin-menu",
                      "dashboard", "list-tables",
                      "edit", "revisions",
                      "media", "themes",
                      "about", "nav-menus",
                      "widgets", "site-icon",
                      "l10n"]);

         Styles.Add ("login",   "/wp-admin/css/login" & Suffix & ".css",
                     ["dashicons", "buttons", "forms", "l10n"]);
         Styles.Add ("install", "/wp-admin/css/install" & Suffix & ".css",
                     ["dashicons", "buttons", "forms", "l10n"]);
         Styles.Add ("wp-color-picker",
                     "/wp-admin/css/color-picker" & Suffix & ".css");
         Styles.Add ("customize-controls",
                     "/wp-admin/css/customize-controls" & Suffix & ".css",
                     ["wp-admin", "colors", "imgareaselect"]);
         Styles.Add ("customize-widgets",
                     "/wp-admin/css/customize-widgets" & Suffix & ".css",
                     ["wp-admin", "colors"]);
         Styles.Add ("customize-nav-menus",
                     "/wp-admin/css/customize-nav-menus" & Suffix & ".css",
                     ["wp-admin", "colors"]);

         -- Common dependencies.
         Styles.Add ("buttons",   "/wp-includes/css/buttons" & Suffix & ".css");
         Styles.Add ("dashicons", "/wp-includes/css/dashicons" & Suffix & ".css");

         -- Includes CSS.
         Styles.Add ("admin-bar", "/wp-includes/css/admin-bar" & Suffix & ".css",
                     ["dashicons"]);
         Styles.Add ("wp-auth-check",
                     "/wp-includes/css/wp-auth-check" & Suffix & ".css",
                     ["dashicons"]);
         Styles.Add ("editor-buttons", "/wp-includes/css/editor" & Suffix & ".css",
                     ["dashicons"]);
         Styles.Add ("media-views",
                     "/wp-includes/css/media-views" & Suffix & ".css",
                     ["buttons", "dashicons", "wp-mediaelement"]);
         Styles.Add ("wp-pointer", "/wp-includes/css/wp-pointer" & Suffix & ".css",
                     ["dashicons"]);
         Styles.Add ("customize-preview",
                     "/wp-includes/css/customize-preview" & Suffix & ".css",
                     ["dashicons"]);
         Styles.Add ("wp-embed-template-ie",
                     "/wp-includes/css/wp-embed-template-ie" & Suffix & ".css");
         Styles.Add_Data ("wp-embed-template-ie", "conditional", "lte IE 8");

         -- External libraries and friends.
         Styles.Add ("imgareaselect",
                     "/wp-includes/js/imgareaselect/imgareaselect.css",
                     Empty_List, "0.9.8");
         Styles.Add ("wp-jquery-ui-dialog",
                     "/wp-includes/css/jquery-ui-dialog" & Suffix & ".css",
                     ["dashicons"]);
         Styles.Add ("mediaelement",
                     "/wp-includes/js/mediaelement/mediaelementplayer-legacy.min.css",
                     Empty_List, "4.2.17");
         Styles.Add ("wp-mediaelement",
                     "/wp-includes/js/mediaelement/wp-mediaelement" & Suffix & ".css",
                     ["mediaelement"]);
         Styles.Add ("thickbox", "/wp-includes/js/thickbox/thickbox.css",
                     ["dashicons"]);
         Styles.Add ("wp-codemirror",
                     "/wp-includes/js/codemirror/codemirror.min.css",
                     Empty_List, "5.29.1-alpha-ee20357");

         -- Deprecated CSS.
         Styles.Add ("deprecated-media",
                     "/wp-admin/css/deprecated-media" & Suffix & ".css");
         Styles.Add ("farbtastic", "/wp-admin/css/farbtastic" & Suffix & ".css",
                     Empty_List, "1.3u1");
         Styles.Add ("jcrop", "/wp-includes/js/jcrop/jquery.Jcrop.min.css",
                     Empty_List, "0.9.15");
         Styles.Add ("colors-fresh", "False", -- False
                     ["wp-admin", "buttons"]); -- Old handle.
         Styles.Add ("open-sans", -Open_Sans_Font_URL);
         -- No longer used in core as of 4.6.

         -- Noto Serif is no longer used by core, but may be relied upon by themes
         -- and plugins.
         declare
            --
            -- translators: Use this to specify the proper Google Font name and
            -- variants to load that is supported by your language. Do not translate.
            -- Set to "off" to disable loading.
            --
            Font_Family : constant String :=
              X_X ("Noto Serif:400,400i,700,700i",
                   "Google Font Name and Variants");

            Fonts_URL : constant String :=
              (if "off" /= Font_Family
               then "https://fonts.googleapis.com/css?family=" &
                             Php.HTML.URL_Encode (Font_Family)
               else "");
         begin
            Styles.Add ("wp-editor-font", Fonts_URL);
         end;
         -- No longer used in core as of 5.7.

         declare
            Block_Library_Theme_Path : constant String :=
              -Globals.WPINC & "/css/dist/block-library/theme" & Suffix & ".css";
         begin
            Styles.Add ("wp-block-library-theme", "/block_library_theme_path");
            Styles.Add_Data ("wp-block-library-theme", "path",
                             Constants.ABSPATH & Block_Library_Theme_Path);
         end;

         Styles.Add (
           "wp-reset-editor-styles",
           "/wp-includes/css/dist/block-library/reset" & Suffix & ".css",
           ["common", "forms"]
           -- Make sure the reset is loaded after the default WP Admin styles.
         );

         Styles.Add (
           "wp-editor-classic-layout-styles",
           "/wp-includes/css/dist/edit-post/classic" & Suffix & ".css",
            Empty_List
         );

         declare
            Wp_Edit_Blocks_Dependencies : List_Type :=
              ["wp-components",
               "wp-editor",
               -- This need to be added before the block library styles,
               -- The block library styles override the "reset" styles.
               "wp-reset-editor-styles",
               "wp-block-library",
               "wp-reusable-blocks"
              ];
         begin
            -- Only load the default layout and margin styles for themes without
            -- theme.json file.
            if
              True -- not Inc_Class_Wp_Theme_Json_Resolver.Theme_Has_Support -- ::
            then
               Wp_Edit_Blocks_Dependencies.Append ("wp-editor-classic-layout-styles");
            end if;

            if
              not Php.Types.Is_Array (Global_Editor_Styles) or else
              Global_Editor_Styles.Length in 0
            then
               -- Include opinionated block styles if no editor_styles are declared,
               -- so the editor never appears broken.
               Wp_Edit_Blocks_Dependencies.Append ("wp-block-library-theme");
            end if;

            Styles.Add (
              "wp-edit-blocks",
              "/wp-includes/css/dist/block-library/editor" & Suffix & ".css",
              Wp_Edit_Blocks_Dependencies
            );
         end;

         declare
            Package_Styles : constant Array_Type := To_Array_Type ([
                Build ("block-editor",         ["wp-components")),
                Build ("block-library",        Empty_List),
                Build ("block-directory",      Empty_List),
                Build ("components",           Empty_List),
                Build ("edit-post",            List_Type'[
                        "wp-components",
                        "wp-block-editor",
                        "wp-editor",
                        "wp-edit-blocks",
                        "wp-block-library",
                        "wp-nux"
                ]),
                Build ("editor",               List_Type'[
                        "wp-components",
                        "wp-block-editor",
                        "wp-nux",
                        "wp-reusable-blocks"
                ]),
                Build ("format-library",       Empty_List),
                Build ("list-reusable-blocks", ["wp-components")),
                Build ("reusable-blocks",      ["wp-components")),
                Build ("nux",                  ["wp-components")),
                Build ("widgets",              ["wp-components")),
                Build ("edit-widgets",         List_Type'[
                        "wp-widgets",
                        "wp-block-editor",
                        "wp-edit-blocks",
                        "wp-block-library",
                        "wp-reusable-blocks"
                ]),
                Build ("customize-widgets",    List_Type'[
                        "wp-widgets",
                        "wp-block-editor",
                        "wp-edit-blocks",
                        "wp-block-library",
                        "wp-reusable-blocks"
                ]),
                Build ("edit-site",            List_Type'[
                        "wp-components",
                        "wp-block-editor",
                        "wp-edit-blocks"
                ])
         ]);

         begin

            for P in Package_Styles.Iterate loop
               declare
                  Packag : constant String := Key (P);

                  Dependencies : constant List_Type :=
                    As_List (Get (Package_Styles, Packag));

                  Handle : constant String := "wp-" & Packag;

                  Path : constant String := "/wp-includes/css/dist/" & Packag &
                    (if
                      "block-library" = Packag and then
                      Wp_Should_Load_Separate_Core_Block_Assets
                    then "/common" & Suffix & ".css"
                    else "/style" & Suffix & ".css");
               begin
                  Styles.Add (Handle, Path, Dependencies);
                  Styles.Add_Data (Handle, "path", Constants.ABSPATH & (Path));
               end;
            end loop;
         end;

         declare
            -- RTL CSS.
            RTL_Styles : constant List_Type :=
              [
                -- Admin CSS.
                "common",
                "forms",
                "admin-menu",
                "dashboard",
                "list-tables",
                "edit",
                "revisions",
                "media",
                "themes",
                "about",
                "nav-menus",
                "widgets",
                "site-icon",
                "l10n",
                "install",
                "wp-color-picker",
                "customize-controls",
                "customize-widgets",
                "customize-nav-menus",
                "customize-preview",
                "login",
                "site-health",
                -- Includes CSS.
                "buttons",
                "admin-bar",
                "wp-auth-check",
                "editor-buttons",
                "media-views",
                "wp-pointer",
                "wp-jquery-ui-dialog",
                -- Package styles.
                "wp-reset-editor-styles",
                "wp-editor-classic-layout-styles",
                "wp-block-library-theme",
                "wp-edit-blocks",
                "wp-block-editor",
                "wp-block-library",
                "wp-block-directory",
                "wp-components",
                "wp-customize-widgets",
                "wp-edit-post",
                "wp-edit-site",
                "wp-edit-widgets",
                "wp-editor",
                "wp-format-library",
                "wp-list-reusable-blocks",
                "wp-reusable-blocks",
                "wp-nux",
                "wp-widgets",
                -- Deprecated CSS.
                "deprecated-media",
                "farbtastic"
           ];
         begin
            for RTL_Style of RTL_Styles loop
               Styles.Add_Data (RTL_Style, "rtl", "replace");
               if Suffix /= "" then
                  Styles.Add_Data (RTL_Style, "suffix", Suffix);
               end if;
            end loop;
         end;
      end;
   end Wp_Default_Styles;

   -----------------------
   -- Wp_Default_Styles --
   -----------------------

   function Wp_Default_Styles
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
                               return Array_Type
   is
      pragma Unreferenced (Arry);
   begin
      Wp_Default_Styles (Globals.Global_Wp_Styles);
      return Empty_Array;
   end Wp_Default_Styles;

-- --
-- -- Reorders JavaScript scripts array to place prototype before jQuery.
-- --
-- -- @since 2.3.1
-- --
-- -- @param string[] js_array JavaScript scripts array
-- -- @return string[] Reordered array, if needed.
-- --
-- function wp_prototype_before_jquery( js_array ) then
--         prototype = array_search( "prototype", js_array, true);

--         if ( False === prototype ) then
--                 return js_array;
--         end;

--         jquery = array_search( "jquery", js_array, true);

--         if ( False === jquery ) then
--                 return js_array;
--         end;

--         if ( prototype < jquery ) then
--                 return js_array;
--         end;

--         unset( js_array[ prototype ]);

--         array_splice( js_array, jquery, 0, "prototype");

--         return js_array;
-- end;

-- --
-- -- Loads localized data on print rather than initialization.
-- --
-- -- These localizations require information that may not be loaded even by init.
-- --
-- -- @since 2.5.0
-- --
-- function wp_just_in_time_script_localization() then

--         wp_localize_script(
--                 "autosave",
--                 "autosaveL10n",
--                 array(
--                         "autosaveInterval" => AUTOSAVE_INTERVAL,
--                         "blog_id"          => get_current_blog_id(),
--                 )
--        );

--         wp_localize_script(
--                 "mce-view",
--                 "mceViewL10n",
--                 array(
--                         "shortcodes" => ! empty( GLOBALS["shortcode_tags"] ) ? array_keys( GLOBALS["shortcode_tags"] ) : array(),
--                 )
--        );

--         wp_localize_script(
--                 "word-count",
--                 "wordCountL10n",
--                 array(
--                         /*
--                         -- translators: If your word count is based on single characters (e.g. East Asian characters),
--                         -- enter "characters_excluding_spaces" or "characters_including_spaces". Otherwise, enter "words".
--                         -- Do not translate into your own language.
--                         --
--                         "type"       => _x( "words", "Word count type. Do not translate!"),
--                         "shortcodes" => ! empty( GLOBALS["shortcode_tags"] ) ? array_keys( GLOBALS["shortcode_tags"] ) : array(),
--                 )
--        );
-- end;

-- --
-- -- Localizes the jQuery UI datepicker.
-- --
-- -- @since 4.6.0
-- --
-- -- @link https://api.jqueryui.com/datepicker/#options
-- --
-- -- @global WP_Locale wp_locale WordPress date and time locale object.
-- --
-- function wp_localize_jquery_ui_datepicker() then
--         global wp_locale;

--         if ( ! wp_script_is( "jquery-ui-datepicker", "enqueued" ) ) then
--                 return;
--         end;

--         -- Convert the PHP date format into jQuery UI"s format.
--         datepicker_date_format = str_replace(
--                 array(
--                         "d",
--                         "j",
--                         "l",
--                         "z", -- Day.
--                         "F",
--                         "M",
--                         "n",
--                         "m", -- Month.
--                         "Y",
--                         "y", -- Year.
--                ),
--                 array(
--                         "dd",
--                         "d",
--                         "DD",
--                         "o",
--                         "MM",
--                         "M",
--                         "m",
--                         "mm",
--                         "yy",
--                         "y",
--                ),
--                 get_option( "date_format" )
--        );

--         datepicker_defaults = wp_json_encode(
--                 array(
--                         "closeText"       => abs "Close"),
--                         "currentText"     => abs "Today"),
--                         "monthNames"      => array_values( wp_locale.month),
--                         "monthNamesShort" => array_values( wp_locale.month_abbrev),
--                         "nextText"        => abs "Next"),
--                         "prevText"        => abs "Previous"),
--                         "dayNames"        => array_values( wp_locale.weekday),
--                         "dayNamesShort"   => array_values( wp_locale.weekday_abbrev),
--                         "dayNamesMin"     => array_values( wp_locale.weekday_initial),
--                         "dateFormat"      => datepicker_date_format,
--                         "firstDay"        => absint( get_option( "start_of_week" )),
--                         "isRTL"           => wp_locale.is_rtl(),
--                 )
--        );

--         wp_add_inline_script( "jquery-ui-datepicker", "jQuery(function(jQuery)thenjQuery.datepicker.setDefaults(thendatepicker_defaultsend;);end;);");
-- end;

-- --
-- -- Localizes community events data that needs to be passed to dashboard.js.
-- --
-- -- @since 4.8.0
-- --
-- function wp_localize_community_events() then
--         if ( ! wp_script_is( "dashboard" ) ) then
--                 return;
--         end;

--         require_once ABSPATH . "wp-admin/includes/class-wp-community-events.php";

--         user_id            = get_current_user_id();
--         saved_location     = get_user_option( "community-events-location", user_id);
--         saved_ip_address   = isset( saved_location["ip"] ) ? saved_location["ip"] : False;
--         current_ip_address = WP_Community_Events::get_unsafe_client_ip();

--         /*
--         -- If the user"s location is based on their IP address, then update their
--         -- location when their IP address changes. This allows them to see events
--         -- in their current city when travelling. Otherwise, they would always be
--         -- shown events in the city where they were when they first loaded the
--         -- Dashboard, which could have been months or years ago.
--         --
--         if ( saved_ip_address && current_ip_address && current_ip_address !== saved_ip_address ) then
--                 saved_location["ip"] = current_ip_address;
--                 update_user_meta( user_id, "community-events-location", saved_location);
--         end;

--         events_client = new WP_Community_Events( user_id, saved_location);

--         wp_localize_script(
--                 "dashboard",
--                 "communityEventsData",
--                 array(
--                         "nonce"       => wp_create_nonce( "community_events"),
--                         "cache"       => events_client.get_cached_events(),
--                         "time_format" => get_option( "time_format"),
--                 )
--        );
-- end;

-- --
-- -- Administration Screen CSS for changing the styles.
-- --
-- -- If installing the "wp-admin/" directory will be replaced with "./".
-- --
-- -- The _wp_admin_css_colors global manages the Administration Screens CSS
-- -- stylesheet that is loaded. The option that is set is "admin_color" and is the
-- -- color and key for the array. The value for the color key is an object with
-- -- a "url" parameter that has the URL path to the CSS file.
-- --
-- -- The query from src parameter will be appended to the URL that is given from
-- -- the _wp_admin_css_colors array value URL.
-- --
-- -- @since 2.6.0
-- --
-- -- @global array _wp_admin_css_colors
-- --
-- -- @param string src    Source URL.
-- -- @param string handle Either "colors" or "colors-rtl".
-- -- @return string|False URL path to CSS stylesheet for Administration Screens.
-- --
-- function wp_style_loader_src( src, handle ) then
--         global _wp_admin_css_colors;

--         if ( wp_installing() ) then
--                 return preg_replace( "#^wp-admin/#", "./", src);
--         end;

--         if ( "colors" === handle ) then
--                 color = get_user_option( "admin_color");

--                 if ( empty( color ) || ! isset( _wp_admin_css_colors[ color ] ) ) then
--                         color = "fresh";
--                 end;

--                 color = _wp_admin_css_colors[ color ];
--                 url   = color.url;

--                 if ( ! url ) then
--                         return False;
--                 end;

--                 parsed = parse_url( src);
--                 if ( isset( parsed["query"] ) && parsed["query"] ) then
--                         wp_parse_str( parsed["query"], qv);
--                         url = add_query_arg( qv, url);
--                 end;

--                 return url;
--         end;

--         return src;
-- end;

   ------------------------
   -- Print_Head_Scripts --
   ------------------------

   function Print_Head_Scripts
            return List_Type
   is
      use Wp_Common;
      use Inc_Plugins;
--    global concatenate_scripts;
      Wp_Scripts : Class_Scripts.Wp_Scripts
        renames Globals.Global_Wp_Scripts;
   begin
      if not Did_Action ("wp_print_scripts") then
         -- This action is documented in wp-includes/functions.wp-scripts.php
         Do_Action ("wp_print_scripts");
      end if;

      Script_Concat_Settings;
      Wp_Scripts.Do_Concat := Concatenate_Scripts;
      Wp_Scripts.Do_Head_Items;

      --
      -- Filters whether to print the head scripts.
      --
      -- @since 2.8.0
      --
      -- @param bool print Whether to print the head scripts. Default true.
      --
      if Apply_Filters ("print_head_scripts", True) then
         X_Print_Scripts;
      end if;

      Wp_Scripts.Reset;
      return Wp_Scripts.Done;
   end Print_Head_Scripts;

   --------------------------
   -- Print_Footer_Scripts --
   --------------------------

   function Print_Footer_Scripts
            return List_Type
   is
      use Wp_Common;
      use Class_Scripts;

--    global wp_scripts, concatenate_scripts;
      Wp_Scripts : Class_Scripts.Wp_Scripts
        renames Globals.Global_Wp_Scripts;
   begin
      if Wp_Scripts not in Wp_Scripts then -- instanceof
         return Empty_List; -- No need to run if not instantiated.
      end if;

      Script_Concat_Settings;
      Wp_Scripts.Do_Concat := Concatenate_Scripts;
      Wp_Scripts.Do_Footer_Items;

      --
      -- Filters whether to print the footer scripts.
      --
      -- @since 2.8.0
      --
      -- @param bool print Whether to print the footer scripts. Default true.
      --
      if Apply_Filters ("print_footer_scripts", True) then
         X_Print_Scripts;
      end if;

      Wp_Scripts.Reset;
      return Wp_Scripts.Done;
   end Print_Footer_Scripts;

   --------------------------
   -- Print_Footer_Scripts --
   --------------------------

   procedure Print_Footer_Scripts
   is
      Unused : constant List_Type := Print_Footer_Scripts;
   begin
      null;
   end Print_Footer_Scripts;

   ---------------------
   -- X_Print_Scripts --
   ---------------------

   procedure X_Print_Scripts
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Class_Scripts;
      use Inc_Formatting;
      use Inc_Themes;
--    global wp_scripts, compress_scripts;
      Scripts : Wp_Scripts renames
         Globals.Global_Wp_Scripts;

      Zip_2 : constant String :=
        (if Compress_Scripts then "1" else "0");

      Zip : constant String :=
        (if Zip_2 = "1" and then Constants.ENFORCE_GZIP
         then "gzip"
         else Zip_2);

      Concat : constant String := Trim (-Scripts.Concat, ", ");

      Type_Attr : constant String :=
        (if Current_Theme_Supports ("html5", "script")
         then "" else " type=""text/javascript""");
   begin
      if Concat /= "" then
         if not Empty (Scripts.Print_Code) then
            Echo (NL & "<script" & Type_Attr & ">" & NL);
            Echo ("/* <![CDATA[ */" & NL); -- Not needed in HTML 5.
            Echo (-Scripts.Print_Code);
            Echo ("/* ]]> */" & NL);
            Echo ("</script>" & NL);
         end if;

         declare
            Concat_2 : constant Array_Type := Str_Split (Concat, 128);
            Concatenated : UString;
         begin
            for A in Concat_2.Iterate loop
               declare
                  Key   : constant String := Arrays.Key (A);
                  Chunk : constant String := As_String (Arrays.Element (A));
               begin
                  Append (Concatenated, "&load%5Bchunk_" & Key & "%5D=" & Chunk);
               end;
            end loop;

            declare
               Src : constant String :=
                 -(Scripts.Base_URL & "/wp-admin/load-scripts.php?c=" & Zip &
                 Concatenated & "&ver=" & Scripts.Default_Version);
            begin
               Echo ("<script" & Type_Attr & " src=""" & ESC_Attr (Src) &
                     """></script>" & NL);
            end;
         end;
      end if;

      if not Empty (Scripts.Print_HTML) then
         Echo (-Scripts.Print_HTML);
      end if;
   end X_Print_Scripts;

   ---------------------------
   -- Wp_Print_Head_Scripts --
   ---------------------------

   function Wp_Print_Head_Scripts
            return List_Type
   is
      use Wp_Common;
      use Inc_Plugins;
--    global wp_scripts;
   begin
      if not Did_Action ("wp_print_scripts") then
         -- This action is documented in wp-includes/functions.wp-scripts.php--
         Do_Action ("wp_print_scripts");
      end if;

      -- if not ( wp_scripts instanceof WP_Scripts ) then
      --    return Empty_Array; -- No need to run if nothing is queued.
      -- end if;

      return Print_Head_Scripts;
   end Wp_Print_Head_Scripts;

   ---------------------------
   -- Wp_Print_Head_Scripts --
   ---------------------------

   function Wp_Print_Head_Scripts
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Array_Type
   is
      pragma Unreferenced (Arry);
      Unused : constant List_Type := Wp_Print_Head_Scripts;
   begin
      return Empty_Array;
   end Wp_Print_Head_Scripts;

   -------------------------
   -- X_Wp_Footer_Scripts --
   -------------------------

   procedure X_Wp_Footer_Scripts
   is
   begin
      Print_Late_Styles;
      Print_Footer_Scripts;
   end X_Wp_Footer_Scripts;

   -----------------------------
   -- Wp_Print_Footer_Scripts --
   -----------------------------

   procedure Wp_Print_Footer_Scripts
   is
      use Wp_Common;
   begin
      --
      -- Fires when footer scripts are printed.
      --
      -- @since 2.8.0
      --
      Do_Action ("wp_print_footer_scripts");
   end Wp_Print_Footer_Scripts;

   ------------------------
   -- Wp_Enqueue_Scripts --
   ------------------------

   procedure Wp_Enqueue_Scripts
   is
      use Wp_Common;
   begin
      --
      -- Fires when scripts and styles are enqueued.
      --
      -- @since 2.8.0
      --
      Do_Action ("wp_enqueue_scripts");
   end Wp_Enqueue_Scripts;

   ------------------------
   -- Print_Admin_Styles --
   ------------------------

   function Print_Admin_Styles
            return List_Type
   is
      use Wp_Common;
      use Class_Styles;

--         global concatenate_scripts;
      Styles : Wp_Styles
        renames Globals.Global_Wp_Styles;
   begin
      Script_Concat_Settings;
      Styles.Do_Concat := Concatenate_Scripts;
      Styles.Do_Items (False);

      --
      -- Filters whether to print the admin styles.
      --
      -- @since 2.8.0
      --
      -- @param bool print Whether to print the admin styles. Default true.
      --
      if Apply_Filters ("print_admin_styles", True) then
         X_Print_Styles;
      end if;

      Styles.Reset;
      return Styles.Done;
   end Print_Admin_Styles;

   ------------------------
   -- Print_Admin_Styles --
   ------------------------

   procedure Print_Admin_Styles
   is
      Unused : constant List_Type := Print_Admin_Styles;
   begin
      null;
   end Print_Admin_Styles;

   -----------------------
   -- Print_Late_Styles --
   -----------------------

   function Print_Late_Styles
            return List_Type
   is
      use Wp_Common;
      use Class_Styles;
--    global wp_styles, concatenate_scripts;

      Styles : Wp_Styles
        renames Globals.Global_Wp_Styles;
   begin
      -- if not ( wp_styles instanceof WP_Styles ) ) then
      --         return;
      -- end if;

      Script_Concat_Settings;
      Styles.Do_Concat := Concatenate_Scripts;
      Styles.Do_Footer_Items;

      --
      -- Filters whether to print the styles queued too late for the HTML head.
      --
      -- @since 3.3.0
      --
      -- @param bool print Whether to print the "late" styles. Default true.
      --
      if Apply_Filters ("print_late_styles", True) then
         X_Print_Styles;
      end if;

      Styles.Reset;
      return Styles.Done;
   end Print_Late_Styles;

   -----------------------
   -- Print_Late_Styles --
   -----------------------

   procedure Print_Late_Styles
   is
      Unused : constant List_Type := Print_Late_Styles;
   begin
      null;
   end Print_Late_Styles;

   --------------------
   -- X_Print_Styles --
   --------------------

   procedure X_Print_Styles
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Class_Styles;
      use Inc_Formatting;
      use Inc_Themes;
--      global compress_css;

      Styles : Wp_Styles renames
        Globals.Global_Wp_Styles;

      Zip : constant String :=
        (if not Compress_CSS then "0"
         elsif Constants.ENFORCE_GZIP then "gzip"
         else "1");

      Concat : constant String := Trim (-Styles.Concat, ", ");

      Type_Attr : constant String :=
        (if Current_Theme_Supports ("html5", "style")
         then "" else " type=""text/css""");
   begin

      if Concat /= "" then
         declare
            Dir : constant String := -Styles.Text_Direction;
            Ver : constant String := -Styles.Default_Version;

            Concat_2 : constant Array_Type :=
              Str_Split (Concat, Length => 128);

            Concatenated : UString;
         begin
            for A in Concat_2.Iterate loop
               declare
                  Key   : constant String := Arrays.Key (A);
                  Chunk : constant String := Get_As_String (Concat_2, Key);
               begin
                  Append (Concatenated, "&load%5Bchunk_" & Key & "%5D=" & Chunk);
               end;
            end loop;

            declare
               Href : constant String :=
                 -Styles.Base_URL & "/wp-admin/load-styles.php?c=" & Zip &
                 "&dir=" & Dir & (-Concatenated) & "&ver=" & Ver;
            begin
               Echo ("<link rel=""stylesheet"" href=""" & ESC_Attr (Href) & """" &
                     Type_Attr & " media=""all"" />" & NL);
            end;

            if not Empty (Styles.Print_Code) then
               Echo ("<style" & Type_Attr & ">" & NL);
               Echo (-Styles.Print_Code);
               Echo (NL & "</style>" & NL);
            end if;
         end;
      end if;

      if not Empty (Styles.Print_HTML) then
         Echo (-Styles.Print_HTML);
      end if;
   end X_Print_Styles;

   ----------------------------
   -- Script_Concat_Settings --
   ----------------------------

   procedure Script_Concat_Settings
   is
      use Php.Ini;
      use Inc_Load;
      use Inc_Options;
      use Inc_Plugins;
--    global concatenate_scripts, compress_scripts, compress_css;

      Compressed_Output : constant Boolean :=
        Ini_Get ("zlib.output_compression") or else
        "ob_gzhandler" = Ini_Get ("output_handler");

      Can_Compress_Scripts : constant Boolean :=
        not Wp_Installing and then
        "" /= As_String (Get_Site_Option ("can_compress_scripts"));

   begin
      if not Concatenate_Scripts then
         Concatenate_Scripts := Constants.CONCATENATE_SCRIPTS;
--       Concatenate_Scripts :=
--         defined( "CONCATENATE_SCRIPTS" ) ? CONCATENATE_SCRIPTS : true;
         if
           (not Is_Admin and then
            not Did_Action ("login_init")) or else
           Constants.SCRIPT_DEBUG
         then
            Concatenate_Scripts := False;
         end if;
      end if;

      if not Compress_Scripts then
         Compress_Scripts := Constants.COMPRESS_SCRIPTS;
         if
           Compress_Scripts and then
           (not Can_Compress_Scripts or else Compressed_Output)
         then
            Compress_Scripts := False;
         end if;
      end if;

      if not Compress_CSS then
         Compress_CSS := Constants.COMPRESS_CSS;
         if
           Compress_CSS and then
           (not Can_Compress_Scripts or else Compressed_Output)
         then
            Compress_CSS := False;
         end if;
      end if;
   end Script_Concat_Settings;

   ----------------------------------------
   -- Wp_Common_Block_Scripts_And_Styles --
   ----------------------------------------

   procedure Wp_Common_Block_Scripts_And_Styles
   is
      use Php.Files;
      use UStrings;
      use Wp_Common;
      use Inc_Functions_Wp_Styles;
      use Inc_L10n;

      X_DIR_X : String renames Constants.X_DIR_X;
   begin
      if
        Inc_Load.Is_Admin and then
        not Wp_Should_Load_Block_Editor_Scripts_And_Styles
      then
         return;
      end if;

      Wp_Enqueue_Style ("wp-block-library");

      if Inc_Themes.Current_Theme_Supports ("wp-block-styles") then
         if Wp_Should_Load_Separate_Core_Block_Assets then
            declare
               Suffix : String :=
                 (if Constants.SCRIPT_DEBUG then "css" else "min.css");
--             Suffix := defined( "SCRIPT_DEBUG" ) && SCRIPT_DEBUG ? "css" : "min.css";

               Files  : constant List_Type :=
                 Glob (X_DIR_X & "/blocks/*theme." & Suffix);
            begin
               for Path of Files loop
                  declare
                     Block_Name : constant String := Basename (Dirname (Path));
                     Path_2     : UString := +Path;
                     Unused     : Boolean;
                  begin
                     if
                       Is_RTL and then
                       File_Exists (X_DIR_X & "/blocks/block_name/theme-rtl." & Suffix)
                     then
                        Path_2 := +X_DIR_X & "/blocks/block_name/theme-rtl." & Suffix;
                     end if;
                     Unused :=
                       Wp_Add_Inline_Style ("wp-block-" & Block_Name,
                                            File_Get_Contents (-Path_2));
                  end;
               end loop;
            end;
         else
            Wp_Enqueue_Style ("wp-block-library-theme");
         end if;
      end if;

      --
      -- Fires after enqueuing block assets for both editor and front-end.
      --
      -- Call `add_action` on any hook before "wp_enqueue_scripts".
      --
      -- In the function call you supply, simply use `wp_enqueue_script` and
      -- `wp_enqueue_style` to add your functionality to the Gutenberg editor.
      --
      -- @since 5.0.0
      --
      Do_Action ("enqueue_block_assets");

   end Wp_Common_Block_Scripts_And_Styles;

   ------------------
   -- Filter_Block --
   ------------------

   -- For use in Wp_Filter_Out_Block_Nodes

   function Filter_Blocks (Node : Array_Type) return Boolean;

   function Filter_Blocks (Node : Array_Type) return Boolean
   is
      use Php.Arrays;
   begin
      return
        not In_Array ("blocks",
                      As_Array (Get (Node, "path")),
                      Strict => True);
   end Filter_Blocks;

   -------------------------------
   -- Wp_Filter_Out_Block_Nodes --
   -------------------------------

   function Wp_Filter_Out_Block_Nodes (Nodes : Array_Type)
                                       return Array_Type
   is
      use Php.Arrays;
   begin
      return
        Array_Filter (
          Nodes,
          Filter_Blocks'Access,
--          function( node ) then
--             return ! in_array( "blocks", node["path"], true);
--          end;,
          ARRAY_FILTER_USE_BOTH
        );
   end Wp_Filter_Out_Block_Nodes;

   -------------------------------
   -- Wp_Filter_Out_Block_Nodes --
   -------------------------------

   function Wp_Filter_Out_Block_Nodes
              (Nodes : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Array_Type
   is
   begin
      return Wp_Filter_Out_Block_Nodes (Nodes.To_Array);
   end Wp_Filter_Out_Block_Nodes;

   ------------------------------
   -- Wp_Enqueue_Global_Styles --
   ------------------------------

   procedure Wp_Enqueue_Global_Styles
   is
      use Php.Strings;
      use Inc_Functions_Wp_Styles;
      use Inc_Global_Styles_And_Settings;
      use Inc_Plugins;
      use Inc_Themes;

      Separate_Assets  : constant Boolean := Wp_Should_Load_Separate_Core_Block_Assets;
      Is_Block_Theme   : constant Boolean := Wp_Is_Block_Theme;
      Is_Classic_Theme : constant Boolean := not Is_Block_Theme;
   begin
      --
      -- Global styles should be printed in the head when loading all styles combined.
      -- The footer should only be used to print global styles for classic themes with
      -- separate core assets enabled.
      --
      -- See https://core.trac.wordpress.org/ticket/53494.
      --
      if
        (Is_Block_Theme   and then Doing_Action ("wp_footer")) or else
        (Is_Classic_Theme and then Doing_Action ("wp_footer") and then
         not Separate_Assets) or else
        (Is_Classic_Theme and then Doing_Action ("wp_enqueue_scripts") and then
        Separate_Assets)
      then
         return;
      end if;

      --
      -- If loading the CSS for each block separately, then load the theme.json CSS
      -- conditionally. This removes the CSS from the global-styles stylesheet and
      -- adds it to the inline CSS for each block. This filter must be registered
      -- before calling wp_get_global_stylesheet();
      --
      Add_Filter ("wp_theme_json_get_style_nodes", Wp_Filter_Out_Block_Nodes'Access);

      declare
         Stylesheet : constant String := Wp_Get_Global_Stylesheet;
      begin
         if Empty (Stylesheet) then
            return;
         end if;

         Wp_Register_Style ("global-styles", False, Empty_List, True, True);
         Wp_Add_Inline_Style ("global-styles", Stylesheet);
         Wp_Enqueue_Style ("global-styles");
      end;

      -- Add each block as an inline css.
      Wp_Add_Global_Styles_For_Blocks;
   end Wp_Enqueue_Global_Styles;

-- --
-- -- Renders the SVG filters supplied by theme.json.
-- --
-- -- Note that this doesn"t render the per-block user-defined
-- -- filters which are handled by wp_render_duotone_support,
-- -- but it should be rendered before the filtered content
-- -- in the body to satisfy Safari"s rendering quirks.
-- --
-- -- @since 5.9.1
-- --
-- function wp_global_styles_render_svg_filters() then
--         /*
--         -- When calling via the in_admin_header action, we only want to render the
--         -- SVGs on block editor pages.
--         --
--         if (
--                 is_admin() &&
--                 ! get_current_screen().is_block_editor()
--         ) then
--                 return;
--         end;

--         filters = wp_get_global_styles_svg_filters();
--         if ( ! empty( filters ) ) then
--                 echo filters;
--         end;
-- end;

   -----------------------------------------------
   -- Wp_Should_Load_Separate_Core_Block_Assets --
   -----------------------------------------------

   function Wp_Should_Load_Block_Editor_Scripts_And_Styles
            return Boolean
   is
      use Wp_Common;
--    global current_screen;
      Is_Block_Editor_Screen : constant Boolean :=
        Globals.Current_Screen in Class_Screens.Wp_Screen and then -- instanceof
        Globals.Current_Screen.Is_Block_Editor;
   begin
      --
      -- Filters the flag that decides whether or not block editor scripts and styles
      -- are going to be enqueued on the current screen.
      --
      -- @since 5.6.0
      --
      -- @param bool is_block_editor_screen Current value of the flag.
      --
      return Apply_Filters ("should_load_block_editor_scripts_and_styles",
                            Is_Block_Editor_Screen);

   end Wp_Should_Load_Block_Editor_Scripts_And_Styles;

-- --
-- -- Checks whether separate styles should be loaded for core blocks on-render.
-- --
-- -- When this function returns true, other functions ensure that core blocks
-- -- only load their assets on-render, and each block loads its own, individual
-- -- assets. Third-party blocks only load their assets when rendered.
-- --
-- -- When this function returns False, all core block assets are loaded regardless
-- -- of whether they are rendered in a page or not, because they are all part of
-- -- the `block-library/style.css` file. Assets for third-party blocks are always
-- -- enqueued regardless of whether they are rendered or not.
-- --
-- -- This only affects front end and not the block editor screens.
-- --
-- -- @see wp_enqueue_registered_block_scripts_and_styles()
-- -- @see register_block_style_handle()
-- --
-- -- @since 5.8.0
-- --
-- -- @return bool Whether separate assets will be loaded.
-- --
-- function wp_should_load_separate_core_block_assets() then
--         if ( is_admin() || is_feed() || ( defined( "REST_REQUEST" ) && REST_REQUEST ) ) then
--                 return False;
--         end;

--         --
--         -- Filters whether block styles should be loaded separately.
--         --
--         -- Returning False loads all core block assets, regardless of whether they are rendered
--         -- in a page or not. Returning true loads core block assets only when they are rendered.
--         --
--         -- @since 5.8.0
--         --
--         -- @param bool load_separate_assets Whether separate assets will be loaded.
--         --                                   Default False (all block assets are loaded, even when not used).
--         --
--         return apply_filters( "should_load_separate_core_block_assets", False);
-- end;

-- --
-- -- Enqueues registered block scripts and styles, depending on current rendered
-- -- context (only enqueuing editor scripts while in context of the editor).
-- --
-- -- @since 5.0.0
-- --
-- -- @global WP_Screen current_screen WordPress current screen object.
-- --
-- function wp_enqueue_registered_block_scripts_and_styles() then
--         global current_screen;

--         if ( wp_should_load_separate_core_block_assets() ) then
--                 return;
--         end;

--         load_editor_scripts_and_styles = is_admin() && wp_should_load_block_editor_scripts_and_styles();

--         block_registry = WP_Block_Type_Registry::get_instance();
--         foreach ( block_registry.get_all_registered() as block_name => block_type ) then
--                 -- Front-end and editor styles.
--                 foreach ( block_type.style_handles as style_handle ) then
--                         wp_enqueue_style( style_handle);
--                 end;

--                 -- Front-end and editor scripts.
--                 foreach ( block_type.script_handles as script_handle ) then
--                         wp_enqueue_script( script_handle);
--                 end;

--                 if ( load_editor_scripts_and_styles ) then
--                         -- Editor styles.
--                         foreach ( block_type.editor_style_handles as editor_style_handle ) then
--                                 wp_enqueue_style( editor_style_handle);
--                         end;

--                         -- Editor scripts.
--                         foreach ( block_type.editor_script_handles as editor_script_handle ) then
--                                 wp_enqueue_script( editor_script_handle);
--                         end;
--                 end;
--         end;
-- end;

-- --
-- -- Function responsible for enqueuing the styles required for block styles functionality on the editor and on the frontend.
-- --
-- -- @since 5.3.0
-- --
-- -- @global WP_Styles wp_styles
-- --
-- function enqueue_block_styles_assets() then
--         global wp_styles;

--         block_styles = WP_Block_Styles_Registry::get_instance().get_all_registered();

--         foreach ( block_styles as block_name => styles ) then
--                 foreach ( styles as style_properties ) then
--                         if ( isset( style_properties["style_handle"] ) ) then

--                                 -- If the site loads separate styles per-block, enqueue the stylesheet on render.
--                                 if ( wp_should_load_separate_core_block_assets() ) then
--                                         add_filter(
--                                                 "render_block",
--                                                 function( html, block ) use ( block_name, style_properties ) then
--                                                         if ( block["blockName"] === block_name ) then
--                                                                 wp_enqueue_style( style_properties["style_handle"]);
--                                                         end;
--                                                         return html;
--                                                 end;,
--                                                 10,
--                                                 2
--                                        );
--                                 end; else then
--                                         wp_enqueue_style( style_properties["style_handle"]);
--                                 end;
--                         end;
--                         if ( isset( style_properties["inline_style"] ) ) then

--                                 -- Default to "wp-block-library".
--                                 handle = "wp-block-library";

--                                 -- If the site loads separate styles per-block, check if the block has a stylesheet registered.
--                                 if ( wp_should_load_separate_core_block_assets() ) then
--                                         block_stylesheet_handle = generate_block_asset_handle( block_name, "style");

--                                         if ( isset( wp_styles.registered[ block_stylesheet_handle ] ) ) then
--                                                 handle = block_stylesheet_handle;
--                                         end;
--                                 end;

--                                 -- Add inline styles to the calculated handle.
--                                 wp_add_inline_style( handle, style_properties["inline_style"]);
--                         end;
--                 end;
--         end;
-- end;

-- --
-- -- Function responsible for enqueuing the assets required for block styles functionality on the editor.
-- --
-- -- @since 5.3.0
-- --
-- function enqueue_editor_block_styles_assets() then
--         block_styles = WP_Block_Styles_Registry::get_instance().get_all_registered();

--         register_script_lines = array( "( function() then");
--         foreach ( block_styles as block_name => styles ) then
--                 foreach ( styles as style_properties ) then
--                         block_style = array(
--                                 "name"  => style_properties["name"],
--                                 "label" => style_properties["label"],
--                        );
--                         if ( isset( style_properties["is_default"] ) ) then
--                                 block_style["isDefault"] = style_properties["is_default"];
--                         end;
--                         register_script_lines[] = sprintf(
--                                 "       wp.blocks.registerBlockStyle( \"%s\", %s);",
--                                 block_name,
--                                 wp_json_encode( block_style )
--                        );
--                 end;
--         end;
--         register_script_lines[] = "end; )();";
--         inline_script           = implode( "\n", register_script_lines);

--         wp_register_script( "wp-block-styles", False, array( "wp-blocks"), true, true);
--         wp_add_inline_script( "wp-block-styles", inline_script);
--         wp_enqueue_script( "wp-block-styles");
-- end;

-- --
-- -- Enqueues the assets required for the block directory within the block editor.
-- --
-- -- @since 5.5.0
-- --
-- function wp_enqueue_editor_block_directory_assets() then
--         wp_enqueue_script( "wp-block-directory");
--         wp_enqueue_style( "wp-block-directory");
-- end;

-- --
-- -- Enqueues the assets required for the format library within the block editor.
-- --
-- -- @since 5.8.0
-- --
-- function wp_enqueue_editor_format_library_assets() then
--         wp_enqueue_script( "wp-format-library");
--         wp_enqueue_style( "wp-format-library");
-- end;

-- --
-- -- Sanitizes an attributes array into an attributes string to be placed inside a `<script>` tag.
-- --
-- -- Automatically injects type attribute if needed.
-- -- Used by {@see wp_get_script_tag()} and {@see wp_get_inline_script_tag()}.
-- --
-- -- @since 5.7.0
-- --
-- -- @param array attributes Key-value pairs representing `<script>` tag attributes.
-- -- @return string String made of sanitized `<script>` tag attributes.
-- --
-- function wp_sanitize_script_attributes( attributes ) {
--         html5_script_support = ! is_admin() && ! current_theme_supports( "html5", "script");
--         attributes_string    = "";

--         -- If HTML5 script tag is supported, only the attribute name is added
--         -- to attributes_string for entries with a boolean value, and that are true.
--         foreach ( attributes as attribute_name => attribute_value ) then
--                 if ( is_bool( attribute_value ) ) then
--                         if ( attribute_value ) then
--                                 attributes_string .= html5_script_support ? sprintf( " %1s="%2s"", esc_attr( attribute_name), esc_attr( attribute_name ) ) : " " . esc_attr( attribute_name);
--                         }
--                 end; else then
--                         attributes_string .= sprintf( " %1s="%2s"", esc_attr( attribute_name), esc_attr( attribute_value ));
--                 end;
--         end;

--         return attributes_string;
-- end;

-- --
-- -- Formats `<script>` loader tags.
-- --
-- -- It is possible to inject attributes in the `<script>` tag via the {@see "wp_script_attributes"} filter.
-- -- Automatically injects type attribute if needed.
-- --
-- -- @since 5.7.0
-- --
-- -- @param array attributes Key-value pairs representing `<script>` tag attributes.
-- -- @return string String containing `<script>` opening and closing tags.
-- --
-- function wp_get_script_tag( attributes ) then
--         if ( ! isset( attributes["type"] ) && ! is_admin() && ! current_theme_supports( "html5", "script" ) ) then
--                 attributes["type"] = "text/javascript";
--         end;
--         --
--         -- Filters attributes to be added to a script tag.
--         --
--         -- @since 5.7.0
--         --
--         -- @param array attributes Key-value pairs representing `<script>` tag attributes.
--         --                          Only the attribute name is added to the `<script>` tag for
--         --                          entries with a boolean value, and that are true.
--         --
--         attributes = apply_filters( "wp_script_attributes", attributes);

--         return sprintf( "<script%s></script>\n", wp_sanitize_script_attributes( attributes ));
-- end;

-- --
-- -- Prints formatted `<script>` loader tag.
-- --
-- -- It is possible to inject attributes in the `<script>` tag via the  {@see "wp_script_attributes"}  filter.
-- -- Automatically injects type attribute if needed.
-- --
-- -- @since 5.7.0
-- --
-- -- @param array attributes Key-value pairs representing `<script>` tag attributes.
-- --
-- function wp_print_script_tag( attributes ) then
--         echo wp_get_script_tag( attributes);
-- end;

-- --
-- -- Wraps inline JavaScript in `<script>` tag.
-- --
-- -- It is possible to inject attributes in the `<script>` tag via the  {@see "wp_script_attributes"}  filter.
-- -- Automatically injects type attribute if needed.
-- --
-- -- @since 5.7.0
-- --
-- -- @param string javascript Inline JavaScript code.
-- -- @param array  attributes Optional. Key-value pairs representing `<script>` tag attributes.
-- -- @return string String containing inline JavaScript code wrapped around `<script>` tag.
-- --
-- function wp_get_inline_script_tag( javascript, attributes = array() ) then
--         if ( ! isset( attributes["type"] ) && ! is_admin() && ! current_theme_supports( "html5", "script" ) ) then
--                 attributes["type"] = "text/javascript";
--         end;
--         --
--         -- Filters attributes to be added to a script tag.
--         --
--         -- @since 5.7.0
--         --
--         -- @param array  attributes Key-value pairs representing `<script>` tag attributes.
--         --                           Only the attribute name is added to the `<script>` tag for
--         --                           entries with a boolean value, and that are true.
--         -- @param string javascript Inline JavaScript code.
--         --
--         attributes = apply_filters( "wp_inline_script_attributes", attributes, javascript);

--         javascript = "\n" . trim( javascript, "\n\r " ) . "\n";

--         return sprintf( "<script%s>%s</script>\n", wp_sanitize_script_attributes( attributes), javascript);
-- end;

-- --
-- -- Prints inline JavaScript wrapped in `<script>` tag.
-- --
-- -- It is possible to inject attributes in the `<script>` tag via the  {@see "wp_script_attributes"}  filter.
-- -- Automatically injects type attribute if needed.
-- --
-- -- @since 5.7.0
-- --
-- -- @param string javascript Inline JavaScript code.
-- -- @param array  attributes Optional. Key-value pairs representing `<script>` tag attributes.
-- --
-- function wp_print_inline_script_tag( javascript, attributes = array() ) then
--         echo wp_get_inline_script_tag( javascript, attributes);
-- end;

   ----------------------------
   -- Wp_Maybe_Inline_Styles --
   ----------------------------

   procedure Wp_Maybe_Inline_Styles
   is
      use Php.Files;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Class_Dependency;

--    global wp_styles;

      Total_Inline_Limit_2 : constant Natural := 20_000;

      --
      -- The maximum size of inlined styles in bytes.
      --
      -- @since 5.8.0
      --
      -- @param int total_inline_limit The file-size threshold, in bytes. Default
      --                                20000.
      --
      Total_Inline_Limit : constant Natural :=
        Apply_Filters ("styles_inline_size_limit", Total_Inline_Limit_2);

      --
      -- The total inlined size.
      --
      -- On each iteration of the loop, if a style gets added inline the value of
      -- this var increases to reflect the total size of inlined styles.
      --
      Total_Inline_Size : Natural := 0;

      Styles_2 : Array_List;
   begin
      -- Build an array of styles that have a path defined.
      for Handle of Globals.Global_Wp_Styles.Queue loop -- wp_ removed
         declare
            Registered : constant X_Wp_Dependency :=
              Dependency_Maps.Element (
                Globals.Global_Wp_Styles.Registered.Find (Handle));

            Path : constant String := Get_As_String (Registered.Extra, "path");
         begin
            if
              "" /= Globals.Global_Wp_Styles.Get_Data (Handle, "path") and then
              File_Exists (Path)
            then
               Styles_2.Append (To_Array_Type ([
                 Build ("handle", Handle),
                 Build ("src",    -Registered.Src),
                 Build ("path",   Path),
                 Build ("size",   Filesize (Path))
               ]));
            end if;
         end;
      end loop;

      if Styles_2.Is_Empty then
         return;
      end if;

      -- Reorder styles array based on size.
      -- Usort (
      --   Styles,
      --   static function( a, b ) then
      --     return ( a["size"] <= b["size"] ) ? -1 : 1;
      --   end;
      -- );

      -- Loop styles.
      for Style of Styles_2 loop
         declare
            Size : constant Natural := As_Integer (Get (Style, "size"));
            Path : constant String  := Get_As_String (Style, "path");
            Src  : constant String  := Get_As_String (Style, "src");

            Contents_2 : constant String := File_Get_Contents (Path);

            Contents : constant String :=
              X_Wp_Normalize_Relative_CSS_Links (Contents_2, Src);
         begin
            -- Size check. Since styles are ordered by size, we can break the loop.
            if Total_Inline_Size + Size > Total_Inline_Limit then
               exit;
            end if;

            -- Get the styles if we don't already have them.
            Set (Style, "css", From_String (Contents));

            -- Check if the style contains relative URLs that need to be modified.
            -- URLs relative to the stylesheet's path should be converted to relative
            -- to the site's root.
            Set (Style, "css", From_String (
                 X_Wp_Normalize_Relative_CSS_Links (
                   Get_As_String (Style, "css"), Src)));

            -- Set `src` to `False` and add styles inline.
            declare
               Handle : constant String := Get_As_String (Style, "handle");
            begin
               Globals.Global_Wp_Styles.Registered (Handle).Src := Null_UString;
               if
                 Empty (Get_As_String (
                   Globals.Global_Wp_Styles.Registered (Handle).Extra, "after"))
               then
                  Set (Globals.Global_Wp_Styles.Registered (Handle).Extra, "after",
                       From_Array (Empty_Array));
               end if;

               -- Array_Unshift (
               --   As_Array (Get (Styles.Registered (Handle).Extra, "after")),
               --   Get_As_String (Style, "css"));

               -- Add the styles size to the total_inline_size var.
               Total_Inline_Size := Total_Inline_Size + Size;
            end;
         end;
      end loop;
   end Wp_Maybe_Inline_Styles;

   ---------------------------------------
   -- X_Wp_Normalize_Relative_CSS_Links --
   ---------------------------------------

   function X_Wp_Normalize_Relative_CSS_Links (CSS            : String;
                                               Stylesheet_URL : String)
                                               return String
   is
      use Php.Files;
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;

      CSS_2 : UString := +CSS;

      Src_Results     : Array_Type;
      Src_Results_1   : Array_Type;
      Has_Src_Results : Natural;
   begin
      Has_Src_Results :=
        Preg_Match_All ("#url\s*\(\s*[\'""]?\s*([^\'""\)]+)#", CSS, Src_Results);

      if Has_Src_Results = 0 then
         return CSS;
      end if;

      -- Loop through the URLs to find relative ones.
      Src_Results_1 := As_Array (Get (Src_Results, "2")); -- Src_Results (2);
      for A in Src_Results_1.Iterate loop -- [1]
--    for A in Src_Results (2).Iterate loop -- [1]
         declare
            Src_Index  : String := Key (A);
            Src_Result : constant String := As_String (Element (A));
         begin
            -- Skip if this is an absolute URL.
            if
              0 = Strpos (Src_Result, "http") or else
              0 = Strpos (Src_Result, "//")
            then
               goto Continue;
            end if;

            -- Skip if the URL is an HTML ID.
            if Str_Starts_With (Src_Result, "#") then
               goto Continue;
            end if;

            -- Skip if the URL is a data URI.
            if Str_Starts_With (Src_Result, "data:") then
               goto Continue;
            end if;

            -- Build the absolute URL.
            declare
               Absolute_URL_2 : constant String :=
                 Dirname (Stylesheet_URL) & "/" & Src_Result;

               Absolute_URL : constant String :=
                 Str_Replace ("/./", "/", Absolute_URL_2);

               -- Convert to URL related to the site root.
               Relative_URL : constant String :=
                 Wp_Make_Link_Relative (Absolute_URL);

               Aaa : constant String := "XXX-012"; -- Src_Results (0) (Src_Index);
            begin
               -- Replace the URL in the CSS.
               CSS_2 := +
                 Str_Replace (
                   Aaa,
                   Str_Replace (Src_Result, Relative_URL, Aaa),
                   -CSS_2
                 );
            end;
            << Continue >>
         end;
      end loop;

      return -CSS_2;
   end X_Wp_Normalize_Relative_CSS_Links;

-- --
-- -- Function that enqueues the CSS Custom Properties coming from theme.json.
-- --
-- -- @since 5.9.0
-- --
-- function wp_enqueue_global_styles_css_custom_properties() then
--         wp_register_style( "global-styles-css-custom-properties", False, array(), true, true);
--         wp_add_inline_style( "global-styles-css-custom-properties", wp_get_global_stylesheet( array( "variables" ) ));
--         wp_enqueue_style( "global-styles-css-custom-properties");
-- end;

-- --
-- -- Hooks inline styles in the proper place, depending on the active theme.
-- --
-- -- @since 5.9.1
-- -- @since 6.1.0 Added the `priority` parameter.
-- --
-- -- For block themes, styles are loaded in the head.
-- -- For classic ones, styles are loaded in the body because the wp_head action happens before render_block.
-- --
-- -- @link https://core.trac.wordpress.org/ticket/53494.
-- --
-- -- @param string style    String containing the CSS styles to be added.
-- -- @param int    priority To set the priority for the add_action.
-- --
-- function wp_enqueue_block_support_styles( style, priority = 10 ) then
--         action_hook_name = "wp_footer";
--         if ( wp_is_block_theme() ) then
--                 action_hook_name = "wp_head";
--         end;
--         add_action(
--                 action_hook_name,
--                 static function () use ( style ) then
--                         echo "<style>style</style>\n";
--                 end;,
--                 priority
--        );
-- end;

   ------------------------------
   -- Wp_Enqueue_Stored_Styles --
   ------------------------------

   procedure Wp_Enqueue_Stored_Styles (Options : Array_Type := Empty_Array)
   is
      use UStrings;
      use Php.Lists;
      use Php.Strings;
      use Inc_Functions_Wp_Styles;
      use Inc_Style_Engines;
      use Inc_Themes;
      use Inc_Plugins;
      use Style_Class_Wp_Style_Engine_CSS_Rules_Stores;

      Is_Block_Theme   : constant Boolean := Wp_Is_Block_Theme; -- ();
      Is_Classic_Theme : constant Boolean := not Is_Block_Theme;
   begin
      --
      -- For block themes, this function prints stored styles in the header.
      -- For classic themes, in the footer.
      --
      if
        (Is_Block_Theme   and then Doing_Action ("wp_footer")) or else
        (Is_Classic_Theme and then Doing_Action ("wp_enqueue_scripts"))
      then
         return;
      end if;

      declare
         Core_Styles_Keys         : constant List_Type := ["block-supports"];
         Compiled_Core_Stylesheet : UString;
         Style_Tag_Id             : UString := +"core";
         -- Adds comment if code is prettified to identify core styles sections in
         -- debugging.
         Should_Prettify : constant Boolean :=
           (if Isset (Options, "prettify")
            then True = As_Boolean (Get (Options, "prettify"))
            else Constants.SCRIPT_DEBUG);
      begin
         for Style_Key of Core_Styles_Keys loop
            if Should_Prettify then
               Append (Compiled_Core_Stylesheet,
                       "/**\n * Core styles: " & Style_Key & "\n /*\n");
            end if;
            -- Chains core store ids to signify what the styles contain.
            Append (Style_Tag_Id, "-" & Style_Key);
            Append (Compiled_Core_Stylesheet,
                    Wp_Style_Engine_Get_Stylesheet_From_Context
                      (Style_Key, Options));
         end loop;

         -- Combines Core styles.
         if not Empty (Compiled_Core_Stylesheet) then
            Wp_Register_Style   (-Style_Tag_Id, False, Empty_List, True, True);
            Wp_Add_Inline_Style (-Style_Tag_Id, -Compiled_Core_Stylesheet);
            Wp_Enqueue_Style    (-Style_Tag_Id);
         end if;

         -- Prints out any other stores registered by themes or otherwise.
         declare
            Additional_Stores : constant Store_Maps.Map :=
              Style_Class_Wp_Style_Engine_CSS_Rules_Stores.Get_Stores; -- :: ()
         begin
            for A in Additional_Stores.Iterate loop
--          for Store_Name of Array_Keys (Additional_Stores) loop
               declare
                  Store_Name : constant String := Store_Maps.Key (A);
               begin
                  if In_List (Store_Name, Core_Styles_Keys, True) then
                     goto Continue;
                  end if;

                  declare
                     Styles : constant String :=
                       Wp_Style_Engine_Get_Stylesheet_From_Context
                         (Store_Name, Options);
                  begin
                     if not Empty (Styles) then
                        declare
                           Key : constant String := "wp-style-engine-" & Store_Name;
                        begin
                           Wp_Register_Style   (Key, False, Empty_List, True, True);
                           Wp_Add_Inline_Style (Key, Styles);
                           Wp_Enqueue_Style    (Key);
                        end;
                     end if;
                  end;
               end;
               << Continue >>
            end loop;
         end;
      end;
   end Wp_Enqueue_Stored_Styles;

   ------------------------------
   -- Wp_Enqueue_Stored_Styles --
   ------------------------------

   function Wp_Enqueue_Stored_Styles
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Array_Type
   is
   begin
      Wp_Enqueue_Stored_Styles (Arry.To_Array);
      return Empty_Array;
   end Wp_Enqueue_Stored_Styles;

-- --
-- -- Enqueues a stylesheet for a specific block.
-- --
-- -- If the theme has opted-in to separate-styles loading,
-- -- then the stylesheet will be enqueued on-render,
-- -- otherwise when the block inits.
-- --
-- -- @since 5.9.0
-- --
-- -- @param string block_name The block-name, including namespace.
-- -- @param array  args       An array of arguments [handle,src,deps,ver,media].
-- --
-- function wp_enqueue_block_style( block_name, args ) then
--         args = wp_parse_args(
--                 args,
--                 array(
--                         "handle" => "",
--                         "src"    => "",
--                         "deps"   => array(),
--                         "ver"    => False,
--                         "media"  => "all",
--                 )
--        );

--         --
--         -- Callback function to register and enqueue styles.
--         --
--         -- @param string content When the callback is used for the render_block filter,
--         --                        the content needs to be returned so the function parameter
--         --                        is to ensure the content exists.
--         -- @return string Block content.
--         --
--         callback = static function( content ) use ( args ) then
--                 -- Register the stylesheet.
--                 if ( ! empty( args["src"] ) ) then
--                         wp_register_style( args["handle"], args["src"], args["deps"], args["ver"], args["media"]);
--                 end;

--                 -- Add `path` data if provided.
--                 if ( isset( args["path"] ) ) then
--                         wp_style_add_data( args["handle"], "path", args["path"]);

--                         -- Get the RTL file path.
--                         rtl_file_path = str_replace( ".css", "-rtl.css", args["path"]);

--                         -- Add RTL stylesheet.
--                         if ( file_exists( rtl_file_path ) ) then
--                                 wp_style_add_data( args["handle"], "rtl", "replace");

--                                 if ( is_rtl() ) then
--                                         wp_style_add_data( args["handle"], "path", rtl_file_path);
--                                 end;
--                         end;
--                 end;

--                 -- Enqueue the stylesheet.
--                 wp_enqueue_style( args["handle"]);

--                 return content;
--         end;;

--         hook = did_action( "wp_enqueue_scripts" ) ? "wp_footer" : "wp_enqueue_scripts";
--         if ( wp_should_load_separate_core_block_assets() ) then
--                 --
--                 -- Callback function to register and enqueue styles.
--                 --
--                 -- @param string content The block content.
--                 -- @param array  block   The full block, including name and attributes.
--                 -- @return string Block content.
--                 --
--                 callback_separate = static function( content, block ) use ( block_name, callback ) then
--                         if ( ! empty( block["blockName"] ) && block_name === block["blockName"] ) then
--                                 return callback( content);
--                         end;
--                         return content;
--                 end;;

--                 /*
--                 -- The filter"s callback here is an anonymous function because
--                 -- using a named function in this case is not possible.
--                 --
--                 -- The function cannot be unhooked, however, users are still able
--                 -- to dequeue the stylesheets registered/enqueued by the callback
--                 -- which is why in this case, using an anonymous function
--                 -- was deemed acceptable.
--                 --
--                 add_filter( "render_block", callback_separate, 10, 2);
--                 return;
--         end;

--         /*
--         -- The filter"s callback here is an anonymous function because
--         -- using a named function in this case is not possible.
--         --
--         -- The function cannot be unhooked, however, users are still able
--         -- to dequeue the stylesheets registered/enqueued by the callback
--         -- which is why in this case, using an anonymous function
--         -- was deemed acceptable.
--         --
--         add_filter( hook, callback);

--         -- Enqueue assets in the editor.
--         add_action( "enqueue_block_assets", callback);
-- end;

-- --
-- -- Runs the theme.json webfonts handler.
-- --
-- -- Using `WP_Theme_JSON_Resolver`, it gets the fonts defined
-- -- in the `theme.json` for the current selection and style
-- -- variations, validates the font-face properties, generates
-- -- the "@font-face" style declarations, and then enqueues the
-- -- styles for both the editor and front-end.
-- --
-- -- Design Notes:
-- -- This is not a public API, but rather an internal handler.
-- -- A future public Webfonts API will replace this stopgap code.
-- --
-- -- This code design is intentional.
-- --    a. It hides the inner-workings.
-- --    b. It does not expose API ins or outs for consumption.
-- --    c. It only works with a theme"s `theme.json`.
-- --
-- -- Why?
-- --    a. To avoid backwards-compatibility issues when
-- --       the Webfonts API is introduced in Core.
-- --    b. To make `fontFace` declarations in `theme.json` work.
-- --
-- -- @link  https://github.com/WordPress/gutenberg/issues/40472
-- --
-- -- @since 6.0.0
-- -- @access private
-- --
-- function _wp_theme_json_webfonts_handler() then
--         -- Block themes are unavailable during installation.
--         if ( wp_installing() ) then
--                 return;
--         end;

--         -- Webfonts to be processed.
--         registered_webfonts = array();

--         --
--         -- Gets the webfonts from theme.json.
--         --
--         -- @since 6.0.0
--         --
--         -- @return array Array of defined webfonts.
--         --
--         fn_get_webfonts_from_theme_json = static function() then
--                 -- Get settings from theme.json.
--                 settings = WP_Theme_JSON_Resolver::get_merged_data().get_settings();

--                 -- If in the editor, add webfonts defined in variations.
--                 if ( is_admin() || ( defined( "REST_REQUEST" ) && REST_REQUEST ) ) then
--                         variations = WP_Theme_JSON_Resolver::get_style_variations();
--                         foreach ( variations as variation ) then
--                                 -- Skip if fontFamilies are not defined in the variation.
--                                 if ( empty( variation["settings"]["typography"]["fontFamilies"] ) ) then
--                                         continue;
--                                 end;

--                                 -- Initialize the array structure.
--                                 if ( empty( settings["typography"] ) ) then
--                                         settings["typography"] = array();
--                                 end;
--                                 if ( empty( settings["typography"]["fontFamilies"] ) ) then
--                                         settings["typography"]["fontFamilies"] = array();
--                                 end;
--                                 if ( empty( settings["typography"]["fontFamilies"]["theme"] ) ) then
--                                         settings["typography"]["fontFamilies"]["theme"] = array();
--                                 end;

--                                 -- Combine variations with settings. Remove duplicates.
--                                 settings["typography"]["fontFamilies"]["theme"] = array_merge( settings["typography"]["fontFamilies"]["theme"], variation["settings"]["typography"]["fontFamilies"]["theme"]);
--                                 settings["typography"]["fontFamilies"]          = array_unique( settings["typography"]["fontFamilies"]);
--                         end;
--                 end;

--                 -- Bail out early if there are no settings for webfonts.
--                 if ( empty( settings["typography"]["fontFamilies"] ) ) then
--                         return array();
--                 end;

--                 webfonts = array();

--                 -- Look for fontFamilies.
--                 foreach ( settings["typography"]["fontFamilies"] as font_families ) then
--                         foreach ( font_families as font_family ) then

--                                 -- Skip if fontFace is not defined.
--                                 if ( empty( font_family["fontFace"] ) ) then
--                                         continue;
--                                 end;

--                                 -- Skip if fontFace is not an array of webfonts.
--                                 if ( ! is_array( font_family["fontFace"] ) ) then
--                                         continue;
--                                 end;

--                                 webfonts = array_merge( webfonts, font_family["fontFace"]);
--                         end;
--                 end;

--                 return webfonts;
--         end;;

--         --
--         -- Transforms each "src" into an URI by replacing "file:./"
--         -- placeholder from theme.json.
--         --
--         -- The absolute path to the webfont file(s) cannot be defined in
--         -- theme.json. `file:./` is the placeholder which is replaced by
--         -- the theme"s URL path to the theme"s root.
--         --
--         -- @since 6.0.0
--         --
--         -- @param array src Webfont file(s) `src`.
--         -- @return array Webfont"s `src` in URI.
--         --
--         fn_transform_src_into_uri = static function( array src ) then
--                 foreach ( src as key => url ) then
--                         -- Tweak the URL to be relative to the theme root.
--                         if ( ! str_starts_with( url, "file:./" ) ) then
--                                 continue;
--                         end;

--                         src[ key ] = get_theme_file_uri( str_replace( "file:./", "", url ));
--                 end;

--                 return src;
--         end;;

--         --
--         -- Converts the font-face properties (i.e. keys) into kebab-case.
--         --
--         -- @since 6.0.0
--         --
--         -- @param array font_face Font face to convert.
--         -- @return array Font faces with each property in kebab-case format.
--         --
--         fn_convert_keys_to_kebab_case = static function( array font_face ) then
--                 foreach ( font_face as property => value ) then
--                         kebab_case               = _wp_to_kebab_case( property);
--                         font_face[ kebab_case ] = value;
--                         if ( kebab_case !== property ) then
--                                 unset( font_face[ property ]);
--                         end;
--                 end;

--                 return font_face;
--         end;;

--         --
--         -- Validates a webfont.
--         --
--         -- @since 6.0.0
--         --
--         -- @param array webfont The webfont arguments.
--         -- @return array|False The validated webfont arguments, or False if the webfont is invalid.
--         --
--         fn_validate_webfont = static function( webfont ) then
--                 webfont = wp_parse_args(
--                         webfont,
--                         array(
--                                 "font-family"  => "",
--                                 "font-style"   => "normal",
--                                 "font-weight"  => "400",
--                                 "font-display" => "fallback",
--                                 "src"          => array(),
--                         )
--                );

--                 -- Check the font-family.
--                 if ( empty( webfont["font-family"] ) || ! is_string( webfont["font-family"] ) ) then
--                         trigger_error( abs "Webfont font family must be a non-empty string." ));

--                         return False;
--                 end;

--                 -- Check that the `src` property is defined and a valid type.
--                 if ( empty( webfont["src"] ) || ( ! is_string( webfont["src"] ) && ! is_array( webfont["src"] ) ) ) then
--                         trigger_error( abs "Webfont src must be a non-empty string or an array of strings." ));

--                         return False;
--                 end;

--                 -- Validate the `src` property.
--                 foreach ( (array) webfont["src"] as src ) then
--                         if ( ! is_string( src ) || "" === trim( src ) ) then
--                                 trigger_error( abs "Each webfont src must be a non-empty string." ));

--                                 return False;
--                         end;
--                 end;

--                 -- Check the font-weight.
--                 if ( ! is_string( webfont["font-weight"] ) && ! is_int( webfont["font-weight"] ) ) then
--                         trigger_error( abs "Webfont font weight must be a properly formatted string or integer." ));

--                         return False;
--                 end;

--                 -- Check the font-display.
--                 if ( ! in_array( webfont["font-display"], array( "auto", "block", "fallback", "swap"), true ) ) then
--                         webfont["font-display"] = "fallback";
--                 end;

--                 valid_props = array(
--                         "ascend-override",
--                         "descend-override",
--                         "font-display",
--                         "font-family",
--                         "font-stretch",
--                         "font-style",
--                         "font-weight",
--                         "font-variant",
--                         "font-feature-settings",
--                         "font-variation-settings",
--                         "line-gap-override",
--                         "size-adjust",
--                         "src",
--                         "unicode-range",
--                );

--                 foreach ( webfont as prop => value ) then
--                         if ( ! in_array( prop, valid_props, true ) ) then
--                                 unset( webfont[ prop ]);
--                         end;
--                 end;

--                 return webfont;
--         end;;

--         --
--         -- Registers webfonts declared in theme.json.
--         --
--         -- @since 6.0.0
--         --
--         -- @uses registered_webfonts To access and update the registered webfonts registry (passed by reference).
--         -- @uses fn_get_webfonts_from_theme_json To run the function that gets the webfonts from theme.json.
--         -- @uses fn_convert_keys_to_kebab_case To run the function that converts keys into kebab-case.
--         -- @uses fn_validate_webfont To run the function that validates each font-face (webfont) from theme.json.
--         --
--         fn_register_webfonts = static function() use ( &registered_webfonts, fn_get_webfonts_from_theme_json, fn_convert_keys_to_kebab_case, fn_validate_webfont, fn_transform_src_into_uri ) then
--                 registered_webfonts = array();

--                 foreach ( fn_get_webfonts_from_theme_json() as webfont ) then
--                         if ( ! is_array( webfont ) ) then
--                                 continue;
--                         end;

--                         webfont = fn_convert_keys_to_kebab_case( webfont);

--                         webfont = fn_validate_webfont( webfont);

--                         webfont["src"] = fn_transform_src_into_uri( (array) webfont["src"]);

--                         -- Skip if not valid.
--                         if ( empty( webfont ) ) then
--                                 continue;
--                         end;

--                         registered_webfonts[] = webfont;
--                 end;
--         end;;

--         --
--         -- Orders "src" items to optimize for browser support.
--         --
--         -- @since 6.0.0
--         --
--         -- @param array webfont Webfont to process.
--         -- @return array Ordered `src` items.
--         --
--         fn_order_src = static function( array webfont ) then
--                 src         = array();
--                 src_ordered = array();

--                 foreach ( webfont["src"] as url ) then
--                         -- Add data URIs first.
--                         if ( str_starts_with( trim( url), "data:" ) ) then
--                                 src_ordered[] = array(
--                                         "url"    => url,
--                                         "format" => "data",
--                                );
--                                 continue;
--                         end;
--                         format         = pathinfo( url, PATHINFO_EXTENSION);
--                         src[ format ] = url;
--                 end;

--                 -- Add woff2.
--                 if ( ! empty( src["woff2"] ) ) then
--                         src_ordered[] = array(
--                                 "url"    => sanitize_url( src["woff2"]),
--                                 "format" => "woff2",
--                        );
--                 end;

--                 -- Add woff.
--                 if ( ! empty( src["woff"] ) ) then
--                         src_ordered[] = array(
--                                 "url"    => sanitize_url( src["woff"]),
--                                 "format" => "woff",
--                        );
--                 end;

--                 -- Add ttf.
--                 if ( ! empty( src["ttf"] ) ) then
--                         src_ordered[] = array(
--                                 "url"    => sanitize_url( src["ttf"]),
--                                 "format" => "truetype",
--                        );
--                 end;

--                 -- Add eot.
--                 if ( ! empty( src["eot"] ) ) then
--                         src_ordered[] = array(
--                                 "url"    => sanitize_url( src["eot"]),
--                                 "format" => "embedded-opentype",
--                        );
--                 end;

--                 -- Add otf.
--                 if ( ! empty( src["otf"] ) ) then
--                         src_ordered[] = array(
--                                 "url"    => sanitize_url( src["otf"]),
--                                 "format" => "opentype",
--                        );
--                 end;
--                 webfont["src"] = src_ordered;

--                 return webfont;
--         end;;

--         --
--         -- Compiles the "src" into valid CSS.
--         --
--         -- @since 6.0.0
--         --
--         -- @param string font_family Font family.
--         -- @param array  value       Value to process.
--         -- @return string The CSS.
--         --
--         fn_compile_src = static function( font_family, array value ) then
--                 src = "local(font_family)";

--                 foreach ( value as item ) then

--                         if (
--                                 str_starts_with( item["url"], site_url() ) ||
--                                 str_starts_with( item["url"], home_url() )
--                         ) then
--                                 item["url"] = wp_make_link_relative( item["url"]);
--                         end;

--                         src .= ( "data" === item["format"] )
--                                 ? ", url(thenitem["url"]end;)"
--                                 : ", url("thenitem["url"]end;") format("thenitem["format"]end;")";
--                 end;

--                 return src;
--         end;;

--         --
--         -- Compiles the font variation settings.
--         --
--         -- @since 6.0.0
--         --
--         -- @param array font_variation_settings Array of font variation settings.
--         -- @return string The CSS.
--         --
--         fn_compile_variations = static function( array font_variation_settings ) then
--                 variations = "";

--                 foreach ( font_variation_settings as key => value ) then
--                         variations .= "key value";
--                 end;

--                 return variations;
--         end;;

--         --
--         -- Builds the font-family"s CSS.
--         --
--         -- @since 6.0.0
--         --
--         -- @uses fn_compile_src To run the function that compiles the src.
--         -- @uses fn_compile_variations To run the function that compiles the variations.
--         --
--         -- @param array webfont Webfont to process.
--         -- @return string This font-family"s CSS.
--         --
--         fn_build_font_face_css = static function( array webfont ) use ( fn_compile_src, fn_compile_variations ) then
--                 css = "";

--                 -- Wrap font-family in quotes if it contains spaces.
--                 if (
--                         str_contains( webfont["font-family"], " " ) &&
--                         ! str_contains( webfont["font-family"], """ ) &&
--                         ! str_contains( webfont["font-family"], """ )
--                 ) then
--                         webfont["font-family"] = """ . webfont["font-family"] . """;
--                 end;

--                 foreach ( webfont as key => value ) then
--                         /*
--                         -- Skip "provider", since it"s for internal API use,
--                         -- and not a valid CSS property.
--                         --
--                         if ( "provider" === key ) then
--                                 continue;
--                         end;

--                         -- Compile the "src" parameter.
--                         if ( "src" === key ) then
--                                 value = fn_compile_src( webfont["font-family"], value);
--                         end;

--                         -- If font-variation-settings is an array, convert it to a string.
--                         if ( "font-variation-settings" === key && is_array( value ) ) then
--                                 value = fn_compile_variations( value);
--                         end;

--                         if ( ! empty( value ) ) then
--                                 css .= "key:value;";
--                         end;
--                 end;

--                 return css;
--         end;;

--         --
--         -- Gets the "@font-face" CSS styles for locally-hosted font files.
--         --
--         -- @since 6.0.0
--         --
--         -- @uses registered_webfonts To access and update the registered webfonts registry (passed by reference).
--         -- @uses fn_order_src To run the function that orders the src.
--         -- @uses fn_build_font_face_css To run the function that builds the font-face CSS.
--         --
--         -- @return string The `@font-face` CSS.
--         --
--         fn_get_css = static function() use ( &registered_webfonts, fn_order_src, fn_build_font_face_css ) then
--                 css = "";

--                 foreach ( registered_webfonts as webfont ) then
--                         -- Order the Webfont's `src` items to optimize for browser support.
--                         webfont = fn_order_src( webfont);

--                         -- Build the @font-face CSS for this webfont.
--                         css .= "@font-facethen" . fn_build_font_face_css( webfont ) . "end;";
--                 end;

--                 return css;
--         end;;

--         --
--         -- Generates and enqueues webfonts styles.
--         --
--         -- @since 6.0.0
--         --
--         -- @uses fn_get_css To run the function that gets the CSS.
--         --
--         fn_generate_and_enqueue_styles = static function() use ( fn_get_css ) then
--                 -- Generate the styles.
--                 styles = fn_get_css();

--                 -- Bail out if there are no styles to enqueue.
--                 if ( "" === styles ) then
--                         return;
--                 end;

--                 -- Enqueue the stylesheet.
--                 wp_register_style( "wp-webfonts", "");
--                 wp_enqueue_style( "wp-webfonts");

--                 -- Add the styles to the stylesheet.
--                 wp_add_inline_style( "wp-webfonts", styles);
--         end;;

--         --
--         -- Generates and enqueues editor styles.
--         --
--         -- @since 6.0.0
--         --
--         -- @uses fn_get_css To run the function that gets the CSS.
--         --
--         fn_generate_and_enqueue_editor_styles = static function() use ( fn_get_css ) then
--                 -- Generate the styles.
--                 styles = fn_get_css();

--                 -- Bail out if there are no styles to enqueue.
--                 if ( "" === styles ) then
--                         return;
--                 end;

--                 wp_add_inline_style( "wp-block-library", styles);
--         end;;

--         add_action( "wp_loaded", fn_register_webfonts);
--         add_action( "wp_enqueue_scripts", fn_generate_and_enqueue_styles);
--         add_action( "admin_init", fn_generate_and_enqueue_editor_styles);
-- end;

   -------------------------------------
   -- Wp_Enqueue_Classic_Theme_Styles --
   -------------------------------------

   procedure Wp_Enqueue_Classic_Theme_Styles
   is
      use Globals;
      use UStrings;
      use Class_Theme_JSON_Resolver;
      use Inc_Functions_Wp_Styles;
   begin
      if not Theme_Has_Support then
         declare
            Suffix : constant String := Wp_Scripts_Get_Suffix;
            Unused : Boolean;
         begin
            Unused :=
              Wp_Register_Style
                ("classic-theme-styles",
                 "/" & (-WPINC) & "/css/classic-themes" & Suffix & ".css",
                 [], Ver => "true"); -- Ver => True

            Wp_Enqueue_Style ("classic-theme-styles");
         end;
      end if;
   end Wp_Enqueue_Classic_Theme_Styles;

-- --
-- -- Loads classic theme styles on classic themes in the editor.
-- --
-- -- This is needed for backwards compatibility for button blocks specifically.
-- --
-- -- @since 6.1.0
-- --
-- -- @param array editor_settings The array of editor settings.
-- -- @return array A filtered array of editor settings.
-- --
-- function wp_add_editor_classic_theme_styles( editor_settings ) then
--         if ( WP_Theme_JSON_Resolver::theme_has_support() ) then
--                 return editor_settings;
--         end;
--         suffix = wp_scripts_get_suffix();
--         classic_theme_styles = ABSPATH . WPINC . "/css/classic-themes" & Suffix & ".css";

--         -- This follows the pattern of get_block_editor_theme_styles,
--         -- but we can't use get_block_editor_theme_styles directly as it
--         -- only handles external files or theme files.
--         classic_theme_styles_settings = array(
--                 "css"            => file_get_contents( classic_theme_styles),
--                 "__unstableType" => "core",
--                 "isGlobalStyles" => False,
--        );

--         -- Add these settings to the start of the array so that themes can override them.
--         array_unshift( editor_settings["styles"], classic_theme_styles_settings);

--         return editor_settings;
-- end;

end Inc_Script_Loader;
