--
-- WordPress Plugin Install Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.Files;
with Php.HTML;
with Php.JSON;
with Php.Misc;
with Php.Strings;

with Array_Lists;
with Binder;
with Constants;
with Globals;
with Helpers;
with Lists;
with Wp_Common;

with Adi_Files;
with Adi_Plugins;
with Adi_Templates;
with Adi_Update;

with Inc_Capabilities;
with Inc_Category_Templates;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_HTTP;
with Inc_KSES;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Updates;
with Inc_Users;

package body Adi_Plugin_Install is
   use Lists;

-- --
-- -- Retrieves plugin installer pages from the WordPress.org Plugins API.
-- --
-- -- It is possible for a plugin to override the Plugin API result with three
-- -- filters. Assume this is for plugins, which can extend on the Plugin Info to
-- -- offer more choices. This is very powerful and must be used with care when
-- -- overriding the filters.
-- --
-- -- The first filter, {@see 'plugins_api_args'}, is for the args and gives the action
-- -- as the second parameter. The hook for {@see 'plugins_api_args'} must ensure that
-- -- an object is returned.
-- --
-- -- The second filter, {@see 'plugins_api'}, allows a plugin to override the WordPress.org
-- -- Plugin Installation API entirely. If `action` is 'query_plugins' or 'plugin_information',
-- -- an object MUST be passed. If `action` is 'hot_tags', an array MUST be passed.
-- --
-- -- Finally, the third filter, {@see 'plugins_api_result'}, makes it possible to filter the
-- -- response object or array, depending on the `action` type.
-- --
-- -- Supported arguments per action:
-- --
-- -- | Argument Name        | query_plugins | plugin_information | hot_tags |
-- -- | -------------------- | :-----------: | :----------------: | :------: |
-- -- | `slug`              | No            |  Yes               | No       |
-- -- | `per_page`          | Yes           |  No                | No       |
-- -- | `page`              | Yes           |  No                | No       |
-- -- | `number`            | No            |  No                | Yes      |
-- -- | `search`            | Yes           |  No                | No       |
-- -- | `tag`               | Yes           |  No                | No       |
-- -- | `author`            | Yes           |  No                | No       |
-- -- | `user`              | Yes           |  No                | No       |
-- -- | `browse`            | Yes           |  No                | No       |
-- -- | `locale`            | Yes           |  Yes               | No       |
-- -- | `installed_plugins` | Yes           |  No                | No       |
-- -- | `is_ssl`            | Yes           |  Yes               | No       |
-- -- | `fields`            | Yes           |  Yes               | No       |
-- --
-- -- @since 2.7.0
-- --
-- -- @param string       action API action to perform: 'query_plugins', 'plugin_information',
-- --                             or 'hot_tags'.
-- -- @param array|object args   {
-- --     Optional. Array or object of arguments to serialize for the Plugin Info API.
-- --
-- --     @type string  slug              The plugin slug. Default empty.
-- --     @type int     per_page          Number of plugins per page. Default 24.
-- --     @type int     page              Number of current page. Default 1.
-- --     @type int     number            Number of tags or categories to be queried.
-- --     @type string  search            A search term. Default empty.
-- --     @type string  tag               Tag to filter plugins. Default empty.
-- --     @type string  author            Username of an plugin author to filter plugins. Default empty.
-- --     @type string  user              Username to query for their favorites. Default empty.
-- --     @type string  browse            Browse view: 'popular', 'new', 'beta', 'recommended'.
-- --     @type string  locale            Locale to provide context-sensitive results. Default is the value
-- --                                      of get_locale().
-- --     @type string  installed_plugins Installed plugins to provide context-sensitive results.
-- --     @type bool    is_ssl            Whether links should be returned with https or not. Default false.
-- --     @type array   fields            {
-- --         Array of fields which should or should not be returned.
-- --
-- --         @type bool short_description Whether to return the plugin short description. Default true.
-- --         @type bool description       Whether to return the plugin full description. Default false.
-- --         @type bool sections          Whether to return the plugin readme sections: description, installation,
-- --                                       FAQ, screenshots, other notes, and changelog. Default false.
-- --         @type bool tested            Whether to return the 'Compatible up to' value. Default true.
-- --         @type bool requires          Whether to return the required WordPress version. Default true.
-- --         @type bool requires_php      Whether to return the required PHP version. Default true.
-- --         @type bool rating            Whether to return the rating in percent and total number of ratings.
-- --                                       Default true.
-- --         @type bool ratings           Whether to return the number of rating for each star (1-5). Default true.
-- --         @type bool downloaded        Whether to return the download count. Default true.
-- --         @type bool downloadlink      Whether to return the download link for the package. Default true.
-- --         @type bool last_updated      Whether to return the date of the last update. Default true.
-- --         @type bool added             Whether to return the date when the plugin was added to the wordpress.org
-- --                                       repository. Default true.
-- --         @type bool tags              Whether to return the assigned tags. Default true.
-- --         @type bool compatibility     Whether to return the WordPress compatibility list. Default true.
-- --         @type bool homepage          Whether to return the plugin homepage link. Default true.
-- --         @type bool versions          Whether to return the list of all available versions. Default false.
-- --         @type bool donate_link       Whether to return the donation link. Default true.
-- --         @type bool reviews           Whether to return the plugin reviews. Default false.
-- --         @type bool banners           Whether to return the banner images links. Default false.
-- --         @type bool icons             Whether to return the icon links. Default false.
-- --         @type bool active_installs   Whether to return the number of active installations. Default false.
-- --         @type bool contributors      Whether to return the list of contributors. Default false.
-- --     }
-- -- }
-- -- @return object|array|WP_Error Response object or array on success, WP_Error on failure. See the
-- --         {@link https://developer.wordpress.org/reference/functions/plugins_api/ function reference article}
-- --         for more information on the make-up of possible return values depending on the value of `action`.
-- --

   function Plugins_API
     (Action : String; Args : Plugin_API_Args := Null_Plugin_API_Args)
      return Plugin_API_Result
   is
      use Php.Errors;
      use Php.HTML;
      use Php.JSON;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      --      use Adi_Themes.Theme_API_Lists;
      use Inc_Functions;
      use Inc_HTTP;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;

      Args_2 : Plugin_API_Args := Args;
   begin
      -- if Is_Array (Args) then
      --    Args := Args; -- (object)
      -- end if;

      if "query_plugins" = Action then
         if Args.Per_Page = 0 then
            -- if not Isset (Args.Per_Page) then
            Args_2.Per_Page := 24;
         end if;
      end if;

      if Args.Locale = "" then
         -- if not Isset (Args.Locale) then
         Args_2.Locale := +Get_User_Locale;
      end if;

      -- if not Isset (Args.Wp_Version) then
      --    Args_2.Wp_Version := Substr (Wp_Get_Wp_Version, 0, 3); -- x.y
      -- end if;

      declare
         --
         -- Filters the WordPress.org Plugin Installation API arguments.
         --
         -- Important: An object MUST be returned to this filter.
         --
         -- @since 2.7.0
         --
         -- @param object args   Plugin API arguments.
         -- @param string action The type of information being requested from the Plugin Installation API.
         --
         Args_3 : constant Plugin_API_Args :=
           Apply_Filters ("plugins_api_args", Args_2, Action);

         --
         -- Filters the response for the current WordPress.org Plugin Installation API request.
         --
         -- Returning a non-false value will effectively short-circuit the WordPress.org API request.
         --
         -- If `action` is "query_plugins" or "plugin_information", an object MUST be passed.
         -- If `action` is "hot_tags", an array should be passed.
         --
         -- @since 2.7.0
         --
         -- @param false|object|array result The result object or array. Default false.
         -- @param string             action The type of information being requested from the Plugin Installation API.
         -- @param object             args   Plugin API arguments.
         --
         Res : Plugin_API_Result :=
           Apply_Filters
             ("plugins_api",
              Null_Plugin_API_Result, -- False,
              Action,
              Args_2);
      begin
         if not Res.Success then
            declare
               URL_3 : constant String :=
                 "http://api.wordpress.org/plugins/info/1.2/";
               URL_2 : constant String :=
                 Add_Query_Arg
                   (To_Array_Type
                      ([Build ("action", Action),
                        Build ("request", To_Array (Args_3))]),
                    URL_3);

               HTTP_URL : constant String := URL_2;

               SSL : constant Boolean := Wp_HTTP_Supports (Build ("ssl", ""));

               URL : constant String :=
                 (if SSL then Set_URL_Scheme (URL_3, "https") else URL_3);

               HTTP_Args : constant Array_Type :=
                 To_Array_Type
                   ([Build ("timeout", 15),
                     Build
                       ("user-agent",
                        "WordPress/"
                        & Wp_Get_Wp_Version
                        & "; "
                        & Home_URL ("/"))]);

               Request : Inc_HTTP.Array_Error_Type :=
                 Wp_Remote_Get (URL, HTTP_Args);
            begin
               if SSL and then not Request.Success then
                  -- if SSL and then Is_Wp_Error (Request) then
                  if not Wp_Is_JSON_Request then
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
                      ("plugins_api_failed",
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
                         (Wp_Remote_Retrieve_Body (Request.Arry), True);
                  begin
                     if Is_Array (Res2) then
                        -- Object casting is required in order to match the info/1.0 format.
                        null;
                        Res := Res; -- (object) res;

                     elsif Is_Null (Res2) then
                        Res.Error :=
                          Class_Errors.X_Construct
                            ("plugins_api_failed",
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
                            ("plugins_api_failed",
                             Res.Error.Get_Error_Message);
                     end if;
                  end;
               end if;
            end;
         elsif Res.Success then
            -- elsif not Is_Wp_Error (Res) then
            Res.External := True;
         end if;

         --
         -- Filters the Plugin Installation API response results.
         --
         -- @since 2.7.0
         --
         -- @param object|WP_Error res    Response object or WP_Error.
         -- @param string          action The type of information being requested from the Plugin Installation API.
         -- @param object          args   Plugin API arguments.
         --
         return Apply_Filters ("plugins_api_result", Res, Action, Args_3);
      end;
   end Plugins_API;

   --------------------------
   -- Install_Popular_Tags --
   --------------------------

   function Install_Popular_Tags
     (Args : Array_Type := Empty_Array) return Array_Error_Type
   is
      use Php.JSON;
      use Php.Misc;
      use Inc_Options;

      Key  : constant String := MD5 (Serialize (From_Null)); -- Args)); XXX
      Tags : constant Array_Type := Get_Site_Transient ("poptags_" & Key);
   begin
      if not Tags.Is_Empty then
         -- if False /= Tags then
         return
           (Success => True,
            Arry    => Tags,
            Error   => Class_Errors.Null_Wp_Error);
      end if;

      declare
         Tags : constant Plugin_API_Result :=
           Plugins_API ("hot_tags", Null_Plugin_API_Args); -- Args);
      begin
         if not Tags.Success then
            -- if Is_Wp_Error (Tags) then
            return
              (Success => True,
               Arry    => Tags.Arry,
               Error   => Class_Errors.Null_Wp_Error);
         end if;

         Set_Site_Transient
           ("poptags_" & Key, Tags.Arry, 3 * Constants.HOUR_IN_SECONDS);

         return
           (Success => True,
            Arry    => Tags.Arry,
            Error   => Class_Errors.Null_Wp_Error);
      end;
   end Install_Popular_Tags;

   -----------------------
   -- Install_Dashboard --
   -----------------------

   procedure Install_Dashboard is
      use Php.Echoing;
      use Php.HTML;
      use Array_Lists;
      use Inc_Category_Templates;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_L10n;
   begin
      Display_Plugins_Table;

      Echo ("<div class=""plugins-popular-tags-wrapper"">");
      Echo ("<h2>");
      X_E ("Popular tags");
      Echo ("</h2>");
      Echo ("<p>");
      X_E
        ("You may also browse based on the most popular tags in the Plugin Directory:");
      Echo ("</p>");
      declare
         API_Tags : constant Array_Error_Type := Install_Popular_Tags;
      begin
         Echo ("<p class=""popular-tags"">");
         if not API_Tags.Success then
            -- if Is_Wp_Error (API_Tags) then
            Echo (API_Tags.Error.Get_Error_Message);
         else
            -- Set up the tags in a way which can be interpreted by wp_generate_tag_cloud().
            declare
               Tags : Array_Type;
            begin
               for A in API_Tags.Arry.Iterate loop
                  declare
                     Tag : constant Array_Type := As_Array (Element (A));

                     URL : constant String :=
                       Self_Admin_URL
                         ("plugin-install.php?tab=search&type=tag&s="
                          & URL_Encode (Get_As_String (Tag, "name")));

                     Data : constant Array_Type :=
                       To_Array_Type
                         ([Build ("link", ESC_URL (URL)),
                           Build ("name", Get_As_String (Tag, "name")),
                           Build ("slug", Get_As_String (Tag, "slug")),
                           Build
                             ("id",
                              Sanitize_Title_With_Dashes
                                (Get_As_String (Tag, "name"))),
                           Build ("count", As_Integer (Get (Tag, "count")))]);
                  begin
                     Set
                       (Tags,
                        Get_As_String (Tag, "name"),
                        From_Array (Data)); -- To_Object (Data));
                  end;
               end loop;
               Echo
                 (Wp_Generate_Tag_Cloud
                    (Tags,
                     To_Array_Type
                       ([
                         -- translators: %s: Number of plugins.
                         Build ("single_text", abs "%s plugin"),
                         -- translators: %s: Number of plugins.
                         Build ("multiple_text", abs "%s plugins")])));
            end;
         end if;
         Echo ("</p><br class=""clear"" /></div>");
      end;
   end Install_Dashboard;

   -------------------------
   -- Install_Search_Form --
   -------------------------

   procedure Install_Search_Form (Deprecated : Boolean := True) is
      pragma Unreferenced (Deprecated);
      use Php.Echoing;
      use Php.HTML;
      use Binder;
      use UStrings;
      use Adi_Templates;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_L10n;

      Typ : constant String :=
        (if Isset (X_REQUEST, "type")
         then Wp_Unslash (Get_As_String (X_REQUEST, "type"))
         else "term");

      Term : constant String :=
        (if Isset (X_REQUEST, "s")
         then URL_Decode (Wp_Unslash (Get_As_String (X_REQUEST, "s")))
         else "");

   begin
      Echo
        (TAB0
         & "<form class=""search-form search-plugins"" method=""get"">"
         & NL);
      Echo
        (TAB1
         & "<input type=""hidden"" name=""tab"" value=""search"" />"
         & NL);
      Echo (TAB1 & "<label for=""search-plugins"">");
      X_E ("Search Plugins");
      Echo ("</label>" & NL);
      Echo
        (TAB1
         & "<input type=""search"" name=""s"" id=""search-plugins"" value="""
         & ESC_Attr (Term)
         & """ class=""wp-filter-search"" />"
         & NL);
      Echo
        (TAB1
         & "<label class=""screen-reader-text"" for=""typeselector"">");
      -- translators: Hidden accessibility text.
      X_E ("Search plugins by:");
      Echo (NL);
      Echo (TAB1 & "</label>" & NL);

      Echo (TAB1 & "<select name=""type"" id=""typeselector"">" & NL);
      Echo (TAB2 & "<option value=""term""" & Selected ("term", Typ) & ">");
      X_E ("Keyword");
      Echo ("</option>" & NL);
      Echo
        (TAB2 & "<option value=""author""" & Selected ("author", Typ) & ">");
      X_E ("Author");
      Echo ("</option>" & NL);
      Echo (TAB2 & "<option value=""tag""" & Selected ("tag", Typ) & ">");
      X_Ex ("Tag", "Plugin Installer");
      Echo ("</option>" & NL);
      Echo (TAB1 & "</select>" & NL);
      Submit_Button
        (abs "Search Plugins",
         "hide-if-js",
         "(false)", -- False,
         False,
         Build ("id", "search-submit"));
      Echo (TAB0 & "</form>" & NL);
   end Install_Search_Form;

   ----------------------------
   -- Install_Plugins_Upload --
   ----------------------------

   procedure Install_Plugins_Upload is
      use Php.Echoing;
      use UStrings;
      use Adi_Templates;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_L10n;
   begin
      Echo (TAB0 & "<div class=""upload-plugin"">" & NL);
      Echo (TAB1 & "<p class=""install-help"">" & NL);
      X_E
        ("If you have a plugin in a .zip format, you may install or update it by uploading it here.");
      Echo ("</p>" & NL);
      Echo
        (TAB1
         & "<form method=""post"" enctype=""multipart/form-data"" class=""wp-upload-form"" action="""
         & ESC_URL (Self_Admin_URL ("update.php?action=upload-plugin"))
         & """>" & NL);
      Wp_Nonce_Field ("plugin-upload");
      Echo (TAB2 & "<label class=""screen-reader-text"" for=""pluginzip"">" & NL);

      -- translators: Hidden accessibility text.
      X_E ("Plugin zip file");

      Echo (TAB2 & "</label>" & NL);
      Echo
        (TAB2
         & "<input type=""file"" id=""pluginzip"" name=""pluginzip"" accept="".zip"" />");
      Submit_Button
        (X_X ("Install Now", "plugin"), "", "install-plugin-submit", False);
      Echo (TAB1 & "</form>" & NL);
      Echo (TAB0 & "</div>" & NL);
   end Install_Plugins_Upload;

   ------------------------------------
   -- Install_Plugins_Favorites_Form --
   ------------------------------------

   procedure Install_Plugins_Favorites_Form is
      use Php.Echoing;
      use UStrings;
      use Inc_Formatting;
      use Inc_L10n;
      use Inc_Pluggables;
      use Inc_Users;

      User   : constant String := Get_User_Option ("wporg_favorites");
      Action : constant String :=
        "save_wporg_username_" & Helpers.Image (Integer (Get_Current_User_Id));
   begin
      Echo (TAB0 & "<p>");
      X_E
        ("If you have marked plugins as favorites on WordPress.org, you can browse them here.");
      Echo ("</p>" & NL);
      Echo (TAB0 & "<form method=""get"">" & NL);
      Echo
        (TAB1
         & "<input type=""hidden"" name=""tab"" value=""favorites"" />"
         & NL);
      Echo (TAB1 & "<p>" & NL);
      Echo (TAB2 & "<label for=""user"">");
      X_E ("Your WordPress.org username:");
      Echo ("</label>" & NL);
      Echo
        (TAB2
         & "<input type=""search"" id=""user"" name=""user"" value="""
         & ESC_Attr (User)
         & """ />"
         & NL);
      Echo (TAB2 & "<input type=""submit"" class=""button"" value=""");
      ESC_Attr_E ("Get Favorites");
      Echo (""" />" & NL);
      Echo
        (TAB2
         & "<input type=""hidden"" id=""wporg-username-nonce"" name=""_wpnonce"" value="""
         & ESC_Attr (Wp_Create_Nonce (Action))
         & """ />"
         & NL);
      Echo (TAB1 & "</p>" & NL);
      Echo (TAB0 & "</form>" & NL);
   end Install_Plugins_Favorites_Form;

   ---------------------------
   -- Display_Plugins_Table --
   ---------------------------

   procedure Display_Plugins_Table is
      use Php.Echoing;
      use Binder;
      use Inc_L10n;
      use Inc_Plugins;
      use Inc_Users;
      -- global wp_list_table;

      Filter : constant String := Current_Filter;
   begin
      if Filter = "install_plugins_beta" then
         Printf
           (
            -- translators: %s: URL to "Features as Plugins" page.
            "<p>"
            & abs "You are using a development version of WordPress. These feature plugins are also under development. <a href=""%s"">Learn more</a>."
            & "</p>",
            ["https://make.wordpress.org/core/handbook/about/release-cycle/features-as-plugins/"]);

      elsif Filter = "install_plugins_featured" then
         Printf
           (
            -- translators: %s: https://wordpress.org/plugins/
            "<p>"
            & abs "Plugins extend and expand the functionality of WordPress. You may install plugins in the <a href=""%s"">WordPress Plugin Directory</a> right from here, or upload a plugin in .zip format by clicking the button at the top of this page."
            & "</p>",
            [abs "https://wordpress.org/plugins/"]);

      elsif Filter = "install_plugins_recommended" then
         Echo
           ("<p>"
            & abs "These suggestions are based on the plugins you and other users have installed."
            & "</p>");

      elsif Filter = "install_plugins_favorites" then
         if Empty (XX_GET, "user")
           and then not Get_User_Option ("wporg_favorites")
         then
            return;
         end if;

      end if;

      Echo ("<form id=""plugin-filter"" method=""post"">");
      Echo ("        " & "XXX-E96"); -- Wp_List_Table.Display);
      Echo ("</form>");
   end Display_Plugins_Table;

   -----------------------------------
   -- Install_Plugin_Install_Status --
   -----------------------------------

   function Install_Plugin_Install_Status
     (API : Array_Type; Looop : Boolean := False) return Array_Type
   is
      use Php.Arrays;
      use Php.Files;
      use Php.HTML;
      use Php.Misc;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Options;
      use Inc_Updates;

      type Object_Type is record
         Slug    : UString;
         Version : UString;
      end record;

      type Plugin_Object_Type is record
         Slug        : UString;
         New_Version : UString;
      end record;

      type Update_Object_Type is record
         Response : Array_Type;
      end record;

      function To_Object (Arry : Array_Type) return Object_Type;
      function To_Object (Arry : Array_Type) return Plugin_Object_Type;
      function To_Object (Arry : Array_Type) return Update_Object_Type;

      function To_Object (Arry : Array_Type) return Object_Type is
      begin
         return
           (Slug    => +Get_As_String (Arry, "slug"),
            Version => +Get_As_String (Arry, "version"));
      end To_Object;

      function To_Object (Arry : Array_Type) return Plugin_Object_Type is
      begin
         return
           (Slug        => +Get_As_String (Arry, "slug"),
            New_Version => +Get_As_String (Arry, "new_version"));
      end To_Object;

      function To_Object (Arry : Array_Type) return Update_Object_Type is
      begin
         return
           (Response => As_Array (Get (Arry, "response")));
      end To_Object;

      API_2 : constant Object_Type := To_Object (API);
   begin
      -- This function is called recursively, loop prevents further loops.
      -- if Is_Array (API) then
      --    null; -- api := (object) api;

      -- end if;

      declare
         -- Default to a "new" plugin.
         Status      : UString := +"install";
         URL         : UString := +""; -- = false;
         Update_File : UString := +""; -- False;
         Version     : UString := +"";

         --
         -- Check to see if this plugin is known to be installed,
         -- and has an update awaiting it.
         --
         Update_Plugins : constant Update_Object_Type :=
           To_Object (Get_Site_Transient ("update_plugins"));
      begin
         if Isset (Update_Plugins.Response) then
            for A in Update_Plugins.Response.Iterate loop
               declare
                  File   : constant String := Key (A);
                  Plugin : constant Plugin_Object_Type :=
                    To_Object (As_Array (Element (A)));
               begin
                  if Plugin.Slug = API_2.Slug then
                     Status := +"update_available";
                     Update_File := +File;
                     Version := Plugin.New_Version;
                     if Current_User_Can ("update_plugins") then
                        URL :=
                          +Wp_Nonce_URL
                             (Self_Admin_URL
                                ("update.php?action=upgrade-plugin&plugin="
                                 & (-Update_File)),
                              "upgrade-plugin_" & (-Update_File));
                     end if;
                     exit;
                  end if;
               end;
            end loop;
         end if;

         if "install" = Status then
            if Is_Dir (-(Constants.WP_PLUGIN_DIR & "/" & API_2.Slug)) then
               declare
                  Installed_Plugin : constant Array_Type :=
                    Get_Plugins ("/" & (-API_2.Slug));
               begin
                  if Empty (Installed_Plugin) then
                     if Current_User_Can ("install_plugins") then
                        URL :=
                          +Wp_Nonce_URL
                             (Self_Admin_URL
                                ("update.php?action=install-plugin&plugin="
                                 & (-API_2.Slug)),
                              "install-plugin_" & (-API_2.Slug));
                     end if;
                  else
                     declare
                        Key_2 : constant List_Type :=
                          Array_Keys (Installed_Plugin);
                        --
                        -- Use the first plugin regardless of the name.
                        -- Could have issues for multiple plugins in one directory if they share different version numbers.
                        --
                        Key   : constant String :=
                          Key_2.First_Element; -- Reset (Key);
                     begin
                        Update_File := API_2.Slug & "/" & Key;
                        if Version_Compare
                             (-API_2.Version,
                              As_String
                                (Get
                                   (Ref_2 (Installed_Plugin, Key, "Version"))),
                              "=")
                        then
                           Status := +"latest_installed";
                        elsif Version_Compare
                                (-API_2.Version,
                                 As_String
                                   (Get
                                      (Ref_2
                                         (Installed_Plugin, Key, "Version"))),
                                 "<")
                        then
                           Status := +"newer_installed";
                           Version :=
                             +As_String
                                (Get
                                   (Ref_2 (Installed_Plugin, Key, "Version")));
                        else
                           -- If the above update check failed, then that probably means that the update checker has out-of-date information, force a refresh.
                           if not Looop then
                              Delete_Site_Transient ("update_plugins");
                              Wp_Update_Plugins;
                              return Install_Plugin_Install_Status (API, True);
                           end if;
                        end if;
                     end;
                  end if;
               end;
            else
               -- "install" & no directory with that slug.
               if Current_User_Can ("install_plugins") then
                  URL :=
                    +Wp_Nonce_URL
                       (Self_Admin_URL
                          ("update.php?action=install-plugin&plugin="
                           & (-API_2.Slug)),
                        "install-plugin_" & (-API_2.Slug));
               end if;
            end if;
         end if;

         if Isset (XX_GET, "from") then
            Append
              (URL,
               "&amp;from="
               & URL_Encode (Wp_Unslash (Get_As_String (XX_GET, "from"))));
         end if;

         declare
            File : constant String := -Update_File;
         begin
            return
              To_Array_Type
                ([Build ("status", -Status),
                  Build ("url", -URL),
                  Build ("version", -Version),
                  Build ("file", File)]);
         -- return compact( "status", "url", "version", "file" );
         end;
      end;
   end Install_Plugin_Install_Status;

   --------------------------------
   -- Install_Plugin_Information --
   --------------------------------

   procedure Install_Plugin_Information is
      -- global tab;
      use Php.Arrays;
      use Php.Echoing;
      use Php.Misc;
      use Php.Strings;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Adi_Files;
      use Adi_Templates;
      use Adi_Update;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_KSES;
      use Inc_Link_Templates;
      use Inc_L10n;

      Tab : constant String := -Globals.Global_Tab;
   begin
      if Empty (X_REQUEST, "plugin") then
         return;
      end if;

      declare
         API_2 : constant Plugin_API_Result :=
           Plugins_API
             ("plugin_information",
              (Null_Plugin_API_Args
               with delta
                 Slug => +Wp_Unslash (Get_As_String (X_REQUEST, "plugin"))));

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
               Build ("div", Build ("class", Empty_Array)),
               Build ("span", Build ("class", Empty_Array)),
               Build ("p", Empty_Array),
               Build ("br", Empty_Array),
               Build ("ul", Empty_Array),
               Build ("ol", Empty_Array),
               Build ("li", Empty_Array),
               Build ("h1", Empty_Array),
               Build ("h2", Empty_Array),
               Build ("h3", Empty_Array),
               Build ("h4", Empty_Array),
               Build ("h5", Empty_Array),
               Build ("h6", Empty_Array),
               Build
                 ("img",
                  To_Array_Type
                    ([Build ("src", Empty_Array),
                      Build ("class", Empty_Array),
                      Build ("alt", Empty_Array)])),
               Build ("blockquote", Build ("cite", True))]);

         Plugins_Section_Titles : constant Array_Type :=
           To_Array_Type
             ([Build
                 ("description",
                  X_X ("Description", "Plugin installer section title")),
               Build
                 ("installation",
                  X_X ("Installation", "Plugin installer section title")),
               Build ("faq", X_X ("FAQ", "Plugin installer section title")),
               Build
                 ("screenshots",
                  X_X ("Screenshots", "Plugin installer section title")),
               Build
                 ("changelog",
                  X_X ("Changelog", "Plugin installer section title")),
               Build
                 ("reviews",
                  X_X ("Reviews", "Plugin installer section title")),
               Build
                 ("other_notes",
                  X_X ("Other Notes", "Plugin installer section title"))]);

         API : Plugin_Object_Type := To_Object (API_2.Arry);
      begin
         if not API_2.Success then
            -- if Is_Wp_Error (API) then
            Wp_Die (API_2.Error);
         end if;

         -- Sanitize HTML.
         for A in API.Sections.Iterate loop
            declare
               Section_Name : constant String := Key (A);
               Content      : constant String := As_String (Element (A));
            begin
               Set
                 (API.Sections,
                  Section_Name,
                  From_String (Wp_KSES (Content, Plugins_Allowedtags)));
            end;
         end loop;

         for Key of
           List_Type'
             ["version",
              "author",
              "requires",
              "tested",
              "homepage",
              "downloaded",
              "slug"]
         loop
            if Isset (-API.Key) then
               API.Key := +Wp_KSES (-API.Key, Plugins_Allowedtags);
            end if;
         end loop;

         declare
            X_Tab : constant String := ESC_Attr (Tab);

            -- Default to the Description tab, Do not translate, API returns English.
            Section : UString :=
              +(if Isset (X_REQUEST, "section")
                then Wp_Unslash (Get_As_String (X_REQUEST, "section"))
                else "description");
         begin
            if Empty (Section) or else not Isset (API.Sections, -Section) then
               declare
                  Section_Titles : constant Array_Type :=
                    Array_Keys (API.Sections); -- (array)
               begin
                  Section :=
                    +As_String
                       (Section_Titles
                          .First_Element); -- Reset (Section_Titles);
               end;
            end if;

            Iframe_Header (abs "Plugin Installation");

            declare
               X_With_Banner : UString;
            begin
               if not Empty (API.Banners)
                 and then (not Empty (API.Banners, "low")
                           or else not Empty (API.Banners, "high"))
               then
                  X_With_Banner := +"with-banner";
                  declare
                     Low : String :=
                       (if Empty (API.Banners, "low")
                        then Get_As_String (API.Banners, "high")
                        else Get_As_String (API.Banners, "low"));

                     High : String :=
                       (if Empty (API.Banners, "high")
                        then Get_As_String (API.Banners, "low")
                        else Get_As_String (API.Banners, "high"));
                  begin
                     Echo ("<style type=""text/css"">");
                     Echo ("        #plugin-information-title.with-banner {");
                     Echo
                       ("                background-image: url( "
                        & ESC_URL (Low)
                        & " );");
                     Echo ("        }");
                     Echo
                       ("        @media only screen and ( -webkit-min-device-pixel-ratio: 1.5 ) {");
                     Echo
                       ("                #plugin-information-title.with-banner {");
                     Echo
                       ("                        background-image: url( "
                        & ESC_URL (High)
                        & " );");
                     Echo ("                }");
                     Echo ("        }");
                     Echo ("</style>");
                  end;
               end if;

               Echo ("<div id=""plugin-information-scrollable"">");
               Echo
                 ("<div id="""
                  & X_Tab
                  & "-title"" class="""
                  & (-X_With_Banner)
                  & """><div class=""vignette""></div><h2>"
                  & (-API.Name)
                  & "</h2></div>");
               Echo
                 ("<div id="""
                  & X_Tab
                  & "-tabs"" class="""
                  & (-X_With_Banner)
                  & """>\n");

               for A in API.Sections.Iterate loop
                  -- (array)
                  declare
                     Section_Name : constant String := Key (A);
                     Content      : constant Array_Type := As_Array (Element (A));
                  begin
                     if "reviews" = Section_Name
                       and then (Empty (API.Ratings)
                                 or else 0 = Array_Sum (API.Ratings))
                     then
                        goto Continue;
                     end if;

                     declare
                        Title : constant String :=
                          (if Isset (Plugins_Section_Titles, Section_Name)
                           then

                               Get_As_String
                                  (Plugins_Section_Titles, Section_Name)
                           else
                             UC_Words (Str_Replace ("_", " ", Section_Name)));

                        Class : constant String :=
                          (if Section_Name = Section
                           then " class=""current"""
                           else "");

                        Href_2 : constant String :=
                          Add_Query_Arg
                            (To_Array_Type
                               ([Build ("tab", Tab),
                                 Build ("section", Section_Name)]));

                        Href : constant String := ESC_URL (Href_2);

                        San_Section : constant String :=
                          ESC_Attr (Section_Name);
                     begin
                        Echo
                          ("\t<a name="""
                           & San_Section
                           & """ href="""
                           & Href
                           & """ "
                           & Class
                           & ">"
                           & Title
                           & "</a>\n");
                     end;
                  end;
                  <<Continue>>
               end loop;

               Echo ("</div>\n");

               Echo
                 ("<div id="""
                  & X_Tab
                  & "-content"" class="""
                  & (-X_With_Banner)
                  & """>");
            end;

            Echo ("        <div class=""fyi"">");
            Echo ("                <ul>");
            if not Empty (API.Version) then
               Echo ("                                <li><strong>");
               X_E ("Version:");
               Echo ("</strong> " & (-API.Version) & "</li>");
            elsif not Empty (API.Author) then
               Echo ("                                <li><strong>");
               X_E ("Author:");
               Echo
                 ("</strong> "
                  & Links_Add_Target (-API.Author, "_blank")
                  & "</li>");
            elsif not Empty (API.Last_Updated) then
               Echo ("                                <li><strong>");
               X_E ("Last Updated:");
               Echo ("</strong>");

               -- translators: %s: Human-readable time difference.
               Printf
                 (abs "%s ago",
                  [Human_Time_Diff (Strtotime (-API.Last_Updated))]);

               Echo ("                                </li>");
            elsif not Empty (API.Requires) then
               Echo ("                                <li>");
               Echo ("                                        <strong>");
               X_E ("Requires WordPress Version:");
               Echo ("</strong>");

               -- translators: %s: Version number.
               Printf (abs "%s or higher", [-API.Requires]);

               Echo ("                                </li>");
            elsif not Empty (API.Tested) then
               Echo ("                                <li><strong>");
               X_E ("Compatible up to:");
               Echo ("</strong> " & (-API.Tested) & "</li>");
            elsif not Empty (API.Requires_PHP) then
               Echo ("                                <li>");
               Echo ("                                        <strong>");
               X_E ("Requires PHP Version:");
               Echo ("</strong>");

               -- translators: %s: Version number.
               Printf (abs "%s or higher", [-API.Requires_PHP]);

               Echo ("                                </li>");
            elsif API.Active_Installs /= 0 then
               -- elsif Isset (API.Active_Installs) then
               Echo ("                                <li><strong>");
               X_E ("Active Installations:");
               Echo ("</strong>");

               if API.Active_Installs >= 1_000_000 then
                  declare
                     Active_Installs_Millions : constant Natural :=
                       Natural
                         (Float'Floor
                            (Float (API.Active_Installs) / 1_000_000.0));
                  begin
                     Printf
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
               elsif API.Active_Installs < 10 then
                  X_Ex ("Less Than 10", "Active plugin installations");
               else
                  Echo
                    (Number_Format_I18n (Float (API.Active_Installs)) & "+");
               end if;

               Echo ("                                </li>");
            elsif not Empty (API.Slug) and then not API.External then
               -- Empty (API.External) then
               Echo
                 ("                                <li><a target=""_blank"" href="""
                  & ESC_URL
                      (abs "https://wordpress.org/plugins/" & (-API.Slug))
                  & """/"">");
               X_E ("WordPress.org Plugin Page &#187;");
               Echo ("</a></li>");
            elsif not Empty (API.Homepage) then
               Echo
                 ("                                <li><a target=""_blank"" href="""
                  & ESC_URL (-API.Homepage)
                  & """>");
               X_E ("Plugin Homepage &#187;");
               Echo ("</a></li>");
            elsif not Empty (API.Donate_Link) and then Empty (API.Contributors)
            then
               Echo
                 ("                                <li><a target=""_blank"" href="""
                  & ESC_URL (-API.Donate_Link)
                  & """>");
               X_E ("Donate to this plugin &#187;");
               Echo ("</a></li>");
            end if;
            Echo ("                </ul>");
            if API.Rating /= 0 then
               -- if not Empty (API.Rating) then
               Echo ("                        <h3>");
               X_E ("Average Rating");
               Echo ("</h3>");

               Wp_Star_Rating
                 (To_Array_Type
                    ([Build ("rating", API.Rating),
                      Build ("type", "percent"),
                      Build ("number", API.Num_Ratings)]));

               Echo
                 ("                        <p aria-hidden=""true"" class=""fyi-description"">");

               Printf
                 (
                  -- translators: %s: Number of ratings.
                  X_N
                    ("(based on %s rating)",
                     "(based on %s ratings)",
                     API.Num_Ratings),
                  [Number_Format_I18n (Float (API.Num_Ratings))]);

               Echo ("                        </p>");

            end if;

            if not Empty (API.Ratings) and then Array_Sum (API.Ratings) > 0
            then

               Echo ("                        <h3>");
               X_E ("Reviews");
               Echo ("</h3>");
               Echo ("                        <p class=""fyi-description"">");
               X_E ("Read all reviews on WordPress.org or write your own!");
               Echo ("</p>");

               for A in API.Ratings.Iterate loop
                  declare
                     Keyy      : constant Integer := Integer'Value (Key (A));
                     Ratecount : constant Natural := As_Integer (Element (A));

                     -- Avoid div-by-zero.
                     X_Rating : constant Natural :=
                       (if API.Num_Ratings /= 0
                        then (Ratecount / API.Num_Ratings)
                        else 0);

                     Aria_Label : constant String :=
                       ESC_Attr
                         (Sprintf
                            (
                             -- translators: 1: Number of stars (used to determine singular/plural), 2: Number of reviews.
                             X_N
                               ("Reviews with %1d star: %2s. Opens in a new tab.",
                                "Reviews with %1d stars: %2s. Opens in a new tab.",
                                Keyy),
                             [1 => Helpers.Image (Keyy),
                              2 => Number_Format_I18n (Float (Ratecount))]));
                  begin
                     Echo
                       ("                                <div class=""counter-container"">");
                     Echo
                       ("                                                <span class=""counter-label"">");

                     Printf
                       ("<a href=""%s"" target=""_blank"" aria-label=""%s"">%s</a>",
                        [1 =>
                           "https://wordpress.org/support/plugin/thenapi.slugend;/reviews/?filter=thenkeyend;",
                         2 => Aria_Label,
                         -- translators: %s: Number of stars.
                         3 =>
                           Sprintf
                             (X_N ("%d star", "%d stars", Keyy),
                              [Helpers.Image (Keyy)])]);

                     Echo
                       ("                                                </span>");
                     Echo
                       ("                                                <span class=""counter-back"">");
                     Echo
                       ("                                                        <span class=""counter-bar"" style=""width: "
                        & Helpers.Image (92 * X_Rating)
                        & "px;""></span>");
                     Echo
                       ("                                                </span>");
                     Echo
                       ("                                        <span class=""counter-count"" aria-hidden=""true"">"
                        & Number_Format_I18n (Float (Ratecount))
                        & "</span>");
                     Echo ("                                </div>");
                  end;
               end loop;
            end if;

            if not Empty (API.Contributors) then

               Echo ("                        <h3>");
               X_E ("Contributors");
               Echo ("</h3>");
               Echo ("                        <ul class=""contributors"">");

               for B in API.Contributors.Iterate loop
                  declare
                     Contrib_Username : constant String := Key (B);
                     Contrib_Details  : constant Array_Type := As_Array (Element (B));

                     Contrib_Name_3 : constant String :=
                       Get_As_String (Contrib_Details, "display_name");

                     Contrib_Name_2 : constant String :=
                       (if Contrib_Name_3 = ""
                        then Contrib_Username
                        else Contrib_Name_3);

                     Contrib_Name : constant String :=
                       ESC_HTML (Contrib_Name_2);

                     Contrib_Profile : constant String :=
                       ESC_URL (Get_As_String (Contrib_Details, "profile"));

                     Contrib_Avatar : constant String :=
                       ESC_URL
                         (Add_Query_Arg
                            ("s",
                             "36",
                             Get_As_String (Contrib_Details, "avatar")));
                  begin
                     Echo
                       ("<li><a href="""
                        & Contrib_Profile
                        & """ target=""_blank""><img src="""
                        & Contrib_Avatar
                        & """ width=""18"" height=""18"" alt="""" />"
                        & Contrib_Name
                        & "</a></li>");
                  end;
               end loop;

               Echo ("                        </ul>");
               if not Empty (API.Donate_Link) then
                  Echo
                    ("                                <a target=""_blank"" href="""
                     & ESC_URL (-API.Donate_Link)
                     & """>");
                  X_E ("Donate to this plugin &#187;");
                  Echo ("</a>");
               end if;
            end if;
            Echo ("        </div>");
            Echo ("        <div id=""section-holder"">");

            declare
               Requires_PHP : constant String :=
                 (if API.Requires_PHP /= "" -- Isset (API.Requires_PHP)
                  then
                    -API.Requires_PHP
                  else ""); -- null

               Requires_WP : constant String :=
                 (if API.Requires /= "" -- Isset (API.Requires)
                  then
                    -API.Requires
                  else ""); -- null

               Compatible_PHP : constant Boolean :=
                 Is_PHP_Version_Compatible (Requires_PHP);
               Compatible_WP : constant Boolean :=
                 Is_WP_Version_Compatible (Requires_WP);

               Tested_WP : constant Boolean :=
                 (Empty (API.Tested)
                  or else Version_Compare
                            (Get_Bloginfo ("version"), -API.Tested, "<="));
            begin
               if not Compatible_PHP then
                  declare
                     Compatible_PHP_Notice_Message : UString := +"<p>";
                  begin
                     Append
                       (Compatible_PHP_Notice_Message,
                        abs "<strong>Error:</strong> This plugin <strong>requires a newer version of PHP</strong>.");

                     if Current_User_Can ("update_php") then
                        Append
                          (Compatible_PHP_Notice_Message,
                           Sprintf
                             (
                              -- translators: %s: URL to Update PHP page.
                              " "
                              & abs "<a href=""%s"" target=""_blank"">Click here to learn more about updating PHP</a>.",
                              [ESC_URL (Wp_Get_Update_PHP_URL)])
                           & Wp_Update_PHP_Annotation
                               ("</p><p><em>", "</em>", False));
                     else
                        Append (Compatible_PHP_Notice_Message, "</p>");
                     end if;

                     Wp_Admin_Notice
                       (-Compatible_PHP_Notice_Message,
                        To_Array_Type
                          ([Build ("type", "error"),
                            Build
                              ("additional_classes", List_Type'["notice-alt"]),
                            Build ("paragraph_wrap", False)]));
                  end;
               end if;

               if not Tested_WP then
                  Wp_Admin_Notice
                    (abs "<strong>Warning:</strong> This plugin <strong>has not been tested</strong> with your current version of WordPress.",
                     To_Array_Type
                       ([Build ("type", "warning"),
                         Build
                           ("additional_classes", List_Type'["notice-alt"])]));
               elsif not Compatible_WP then
                  declare
                     Compatible_WP_Notice_Message : UString :=
                       +abs "<strong>Error:</strong> This plugin <strong>requires a newer version of WordPress</strong>.";
                  begin
                     if Current_User_Can ("update_core") then
                        Append
                          (Compatible_WP_Notice_Message,
                           Sprintf
                             (
                              -- translators: %s: URL to WordPress Updates screen.
                              " "
                              & abs "<a href=""%s"" target=""_parent"">Click here to update WordPress</a>.",
                              [ESC_URL (Self_Admin_URL ("update-core.php"))]));
                     end if;

                     Wp_Admin_Notice
                       (-Compatible_WP_Notice_Message,
                        To_Array_Type
                          ([Build ("type", "error"),
                            Build
                              ("additional_classes",
                               List_Type'["notice-alt"])]));
                  end;
               end if;

               for D in API.Sections.Iterate loop
                  declare
                     Section_Name : constant String := Key (D);
                     Content_3    : constant String := As_String (Element (D));

                     Content_2 : constant String :=
                       Links_Add_Base_URL
                         (Content_3,
                          "https://wordpress.org/plugins/"
                          & (-API.Slug)
                          & "/");

                     Content : constant String :=
                       Links_Add_Target (Content_2, "_blank");

                     San_Section : constant String := ESC_Attr (Section_Name);

                     Display : constant String :=
                       (if Section_Name = Section then "block" else "none");
                  begin
                     Echo
                       ("\t<div id=""section-"
                        & San_Section
                        & """ class=""section"" style=""display: "
                        & Display
                        & ";"">\n");
                     Echo (Content);
                     Echo ("\t</div>\n");
                  end;
               end loop;
               Echo ("</div>\n");
               Echo ("</div>\n");
               Echo ("</div>\n"); -- #plugin-information-scrollable

               Echo ("<div id=""tab-footer"">\n");
               if not Empty (API.Download_Link)
                 and then (Current_User_Can ("install_plugins")
                           or else Current_User_Can ("update_plugins"))
               then
                  declare
                     Button_3 : constant String :=
                       Wp_Get_Plugin_Action_Button
                         (-API.Name,
                          API_2.Arry,
                          Compatible_PHP,
                          Compatible_WP);

                     Button_2 : constant String :=
                       Str_Replace
                         ("class=""""", "class=""right """, Button_3);

                     Button : constant String :=
                       (if not Str_Contains
                                 (Button_2, X_X ("Activate", "plugin"))
                        then
                          Str_Replace
                            ("class=""""",
                             "id=""plugin_install_from_iframe"" class=""""",
                             Button_2)
                        else Button_2);
                  begin
                     Echo (Wp_KSES_Post (Button));
                  end;
               end if;
               Echo ("</div>\n");
            end;
         end;
      end;

      Wp_Print_Request_Filesystem_Credentials_Modal;
      Wp_Print_Admin_Notice_Templates;

      Iframe_Footer;
      Php.Errors.Die; -- exit;
   end Install_Plugin_Information;

   ---------------------------------
   -- Wp_Get_Plugin_Action_Button --
   ---------------------------------

   function Wp_Get_Plugin_Action_Button
     (Name           : String;
      Data           : Array_Type;
      Compatible_PHP : Boolean;
      Compatible_WP  : Boolean) return String
   is
      use Php.Arrays;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Adi_Plugins;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;

      type Object_Type is record
         Slug             : UString;
         Download_Link    : UString;
         Requires_Plugins : Array_Type;
      end record;

      function To_Object (Arry : Array_Type) return Object_Type;

      function To_Object (Arry : Array_Type) return Object_Type is
      begin
         return
           (Slug             => +Get_As_String (Arry, "slug"),
            Download_Link    => +Get_As_String (Arry, "download_link"),
            Requires_Plugins => As_Array (Get (Arry, "requires_plugins")));
      end To_Object;

      Button : UString; -- = "";
      Data_2 : constant Object_Type := To_Object (Data);
      Status : constant Array_Type := Install_Plugin_Install_Status (Data);

      Requires_Plugins : constant Array_Type := Data_2.Requires_Plugins; -- ?? array();

      -- Determine the status of plugin dependencies.
      Installed_Plugins : constant Array_Type := Get_Plugins;

      Active_Plugins : constant List_Type := List_Type'["XXX-E97"];
      -- Get_Option ("active_plugins", Empty_Array); -- XXX

      Plugin_Dependencies_Count           : constant Natural :=
        Length (Requires_Plugins);
      Installed_Plugin_Dependencies_Count : Natural := 0;
      Active_Plugin_Dependencies_Count    : Natural := 0;
   begin
      for A in Requires_Plugins.Iterate loop
         declare
            Dependency : constant String := Key (A);
         begin
            for Installed_Plugin_File of
              List_Type'(Array_Keys (Installed_Plugins))
            loop
               if Str_Contains (Installed_Plugin_File, "/")
                 and then Explode ("/", Installed_Plugin_File).First_Element
                          = Dependency
               then
                  Installed_Plugin_Dependencies_Count := @ + 1;
               end if;
            end loop;

            for Active_Plugin_File of Active_Plugins loop
               if Str_Contains (Active_Plugin_File, "/")
                 and then Explode ("/", Active_Plugin_File).First_Element
                          = Dependency
               then
                  Active_Plugin_Dependencies_Count := @ + 1;
               end if;
            end loop;
         end;
      end loop;

      declare
         All_Plugin_Dependencies_Installed : constant Boolean :=
           Installed_Plugin_Dependencies_Count = Plugin_Dependencies_Count;

         All_Plugin_Dependencies_Active : constant Boolean :=
           Active_Plugin_Dependencies_Count = Plugin_Dependencies_Count;
      begin
         if Current_User_Can ("install_plugins")
           or else Current_User_Can ("update_plugins")
         then
            declare
               Stat : constant String := Get_As_String (Status, "status");
               URL  : constant String := Get_As_String (Status, "url");
               File : constant String := Get_As_String (Status, "file");
            begin
               -- switch ( status["status"] ) then
               if Stat = "install" then
                  if URL /= "" then
                     if Compatible_PHP
                       and then Compatible_WP
                       and then All_Plugin_Dependencies_Installed
                       and then not Empty (-Data_2.Download_Link)
                     then
                        Button :=
                          +Sprintf
                             ("<a class=""install-now button"" data-slug=""%s"" href=""%s"" aria-label=""%s"" data-name=""%s"" role=""button"">%s</a>",
                              [1 => ESC_Attr (-Data_2.Slug),
                               2 => ESC_URL (URL),
                               -- translators: %s: Plugin name and version.
                               3 =>
                                 ESC_Attr
                                   (Sprintf
                                      (X_X ("Install %s now", "plugin"),
                                       [Name])),
                               4 => ESC_Attr (Name),
                               5 => X_X ("Install Now", "plugin")]);
                     else
                        Button :=
                          +Sprintf
                             ("<button type=""button"" class=""install-now button button-disabled"" disabled=""disabled"">%s</button>",
                              [X_X ("Install Now", "plugin")]);
                     end if;
                  end if;

               elsif Stat = "update_available" then
                  if URL /= "" then
                     if Compatible_PHP and then Compatible_WP then
                        Button :=
                          +Sprintf
                             ("<a class=""update-now button aria-button-if-js"" data-plugin=""%s"" data-slug=""%s"" href=""%s"" aria-label=""%s"" data-name=""%s"" role=""button"">%s</a>",
                              [1 => ESC_Attr (File),
                               2 => ESC_Attr (-Data_2.Slug),
                               3 => ESC_URL (URL),
                               -- translators: %s: Plugin name and version.
                               4 =>
                                 ESC_Attr
                                   (Sprintf
                                      (X_X ("Update %s now", "plugin"),
                                       [Name])),
                               5 => ESC_Attr (Name),
                               6 => X_X ("Update Now", "plugin")]);
                     else
                        Button :=
                          +Sprintf
                             ("<button type=""button"" class=""button button-disabled"" disabled=""disabled"">%s</button>",
                              [X_X ("Update Now", "plugin")]);
                     end if;
                  end if;

               elsif Stat in "latest_installed" | "newer_installed" then
                  if Is_Plugin_Active (File) then
                     Button :=
                       +Sprintf
                          ("<button type=""button"" class=""button button-disabled"" disabled=""disabled"">%s</button>",
                           [X_X ("Active", "plugin")]);
                  elsif Current_User_Can ("activate_plugin", File) then
                     if Compatible_PHP
                       and then Compatible_WP
                       and then All_Plugin_Dependencies_Active
                     then
                        declare
                           Button_Text  : UString :=
                             +X_X ("Activate", "plugin");
                           -- translators: %s: Plugin name.
                           Button_Label : UString :=
                             +X_X ("Activate %s", "plugin");
                           Activate_URL : UString :=
                             +Add_Query_Arg
                                (To_Array_Type
                                   ([Build
                                       ("_wpnonce",
                                        Wp_Create_Nonce
                                          ("activate-plugin_" & File)),
                                     Build ("action", "activate"),
                                     Build ("plugin", File)]),
                                 Network_Admin_URL ("plugins.php"));
                        begin
                           if Is_Network_Admin then
                              Button_Text :=
                                +X_X ("Network Activate", "plugin");
                              -- translators: %s: Plugin name.
                              Button_Label :=
                                +X_X ("Network Activate %s", "plugin");
                              Activate_URL :=
                                +Add_Query_Arg
                                   (Build ("networkwide", 1), -Activate_URL);
                           end if;

                           Button :=
                             +Sprintf
                                ("<a href=""%1s"" data-name=""%2s"" data-slug=""%3s"" data-plugin=""%4s"" class=""button button-primary activate-now"" aria-label=""%5s"" role=""button"">%6s</a>",
                                 [1 => ESC_URL (-Activate_URL),
                                  2 => ESC_Attr (Name),
                                  3 => ESC_Attr (-Data_2.Slug),
                                  4 => ESC_Attr (File),
                                  5 =>
                                    ESC_Attr (Sprintf (-Button_Label, [Name])),
                                  6 => -Button_Text]);
                        end;
                     else
                        Button :=
                          +Sprintf
                             ("<button type=""button"" class=""button button-disabled"" disabled=""disabled"">%s</button>",
                              [(if Is_Network_Admin
                                then X_X ("Network Activate", "plugin")
                                else X_X ("Activate", "plugin"))]);
                     end if;
                  else
                     Button :=
                       +Sprintf
                          ("<button type=""button"" class=""button button-disabled"" disabled=""disabled"">%s</button>",
                           [X_X ("Installed", "plugin")]);
                  end if;
               end if; -- stat
            end;
         end if;

         return -Button;
      end;
   end Wp_Get_Plugin_Action_Button;

   --------------
   -- To_Array --
   --------------

   function To_Array (Args : Plugin_API_Args) return Array_Type is
      use Array_Lists;
      use UStrings;

      Result : constant Array_Type :=
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
            Build ("installed_plugins", -Args.Installed_Plugins),
            Build ("is_ssl", Args.Is_SSL),
            Build ("fields", Args.Fields)]);
   begin
      return Result;
   end To_Array;

end Adi_Plugin_Install;
