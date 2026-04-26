--
-- WordPress Plugin Administration API: WP_Plugin_Dependencies class
--
-- @package WordPress
-- @subpackage Administration
-- @since 6.5.0
--

with Php.Arrays;
with Php.Files;
with Php.Lists;
with Php.Misc;
with Php.Preg;
with Php.Sorting;
with Php.Strings;

with Array_Lists;
with Constants;
with Globals;
with UStrings;
with Wp_Common;

with Adi_Plugins;
with Adi_Plugin_Install;
with Adi_Screens;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;

package body Class_Plugin_Dependencies is

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      if not Self.Initialized then
         Read_Dependencies_From_Plugin_Headers;
         Get_Dependency_API_Data;
         Self.Initialized := True;
      end if;
   end Initialize;

   -- --
   -- -- Determines whether the plugin has plugins that depend on it.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- -- @return bool Whether the plugin has plugins that depend on it.
   -- --
   -- public static function has_dependents( plugin_file ) then
   --         return in_array( self::convert_to_slug( plugin_file ), (array) self::dependency_slugs, true );
   -- end;

   -- --
   -- -- Determines whether the plugin has plugin dependencies.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- -- @return bool Whether a plugin has plugin dependencies.
   -- --
   -- public static function has_dependencies( plugin_file ) then
   --         return isset( self::dependencies[ plugin_file ] );
   -- end;

   -- --
   -- -- Determines whether the plugin has active dependents.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- -- @return bool Whether the plugin has active dependents.
   -- --
   -- public static function has_active_dependents( plugin_file ) then
   --         require_once ABSPATH . "wp-admin/includes/plugin.php";

   --         dependents = self::get_dependents( self::convert_to_slug( plugin_file ) );
   --         foreach ( dependents as dependent ) then
   --                 if ( is_plugin_active( dependent ) ) then
   --                         return true;
   --                 end;
   --         end;

   --         return false;
   -- end;

   -- --
   -- -- Gets filepaths of plugins that require the dependency.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string slug The dependency"s slug.
   -- -- @return array An array of dependent plugin filepaths, relative to the plugins directory.
   -- --
   -- public static function get_dependents( slug ) then
   --         dependents = array();

   --         foreach ( (array) self::dependencies as dependent => dependencies ) then
   --                 if ( in_array( slug, dependencies, true ) ) then
   --                         dependents[] = dependent;
   --                 end;
   --         end;

   --         return dependents;
   -- end;

   -- --
   -- -- Gets the slugs of plugins that the dependent requires.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string plugin_file The dependent plugin"s filepath, relative to the plugins directory.
   -- -- @return array An array of dependency plugin slugs.
   -- --
   -- public static function get_dependencies( plugin_file ) then
   --         if ( isset( self::dependencies[ plugin_file ] ) ) then
   --                 return self::dependencies[ plugin_file ];
   --         end;

   --         return array();
   -- end;

   -- --
   -- -- Gets a dependent plugin"s filepath.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string slug  The dependent plugin"s slug.
   -- -- @return string|false The dependent plugin"s filepath, relative to the plugins directory,
   -- --                      or false if the plugin has no dependencies.
   -- --
   -- public static function get_dependent_filepath( slug ) then
   --         filepath = array_search( slug, self::dependent_slugs, true );

   --         return filepath ? filepath : false;
   -- end;

   -- --
   -- -- Determines whether the plugin has unmet dependencies.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- -- @return bool Whether the plugin has unmet dependencies.
   -- --
   -- public static function has_unmet_dependencies( plugin_file ) then
   --         if ( ! isset( self::dependencies[ plugin_file ] ) ) then
   --                 return false;
   --         end;

   --         require_once ABSPATH . "wp-admin/includes/plugin.php";

   --         foreach ( self::dependencies[ plugin_file ] as dependency ) then
   --                 dependency_filepath = self::get_dependency_filepath( dependency );

   --                 if ( false === dependency_filepath || is_plugin_inactive( dependency_filepath ) ) then
   --                         return true;
   --                 end;
   --         end;

   --         return false;
   -- end;

   -- --
   -- -- Determines whether the plugin has a circular dependency.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- -- @return bool Whether the plugin has a circular dependency.
   -- --
   -- public static function has_circular_dependency( plugin_file ) then
   --         if ( ! is_array( self::circular_dependencies_slugs ) ) then
   --                 self::get_circular_dependencies();
   --         end;

   --         if ( ! empty( self::circular_dependencies_slugs ) ) then
   --                 slug = self::convert_to_slug( plugin_file );

   --                 if ( in_array( slug, self::circular_dependencies_slugs, true ) ) then
   --                         return true;
   --                 end;
   --         end;

   --         return false;
   -- end;

   -- --
   -- -- Gets the names of plugins that require the plugin.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- -- @return array An array of dependent names.
   -- --
   -- public static function get_dependent_names( plugin_file ) then
   --         dependent_names = array();
   --         plugins         = self::get_plugins();
   --         slug            = self::convert_to_slug( plugin_file );

   --         foreach ( self::get_dependents( slug ) as dependent ) then
   --                 dependent_names[ dependent ] = plugins[ dependent ]["Name"];
   --         end;
   --         sort( dependent_names );

   --         return dependent_names;
   -- end;

   -- --
   -- -- Gets the names of plugins required by the plugin.
   -- --
   -- -- @since 6.5.0
   -- --
   -- -- @param string plugin_file The dependent plugin"s filepath, relative to the plugins directory.
   -- -- @return array An array of dependency names.
   -- --
   -- public static function get_dependency_names( plugin_file ) then
   --         dependency_api_data = self::get_dependency_api_data();
   --         dependencies        = self::get_dependencies( plugin_file );
   --         plugins             = self::get_plugins();

   --         dependency_names = array();
   --         foreach ( dependencies as dependency ) then
   --                 -- Use the name if it's available, otherwise fall back to the slug.
   --                 if ( isset( dependency_api_data[ dependency ]["name"] ) ) then
   --                         name = dependency_api_data[ dependency ]["name"];
   --                 end; else then
   --                         dependency_filepath = self::get_dependency_filepath( dependency );
   --                         if ( false !== dependency_filepath ) then
   --                                 name = plugins[ dependency_filepath ]["Name"];
   --                         end; else then
   --                                 name = dependency;
   --                         end;
   --                 end;

   --                 dependency_names[ dependency ] = name;
   --         end;

   --         return dependency_names;
   -- end;

   -----------------------------
   -- Get_Dependency_Filepath --
   -----------------------------

   function Get_Dependency_Filepath (Slug : String) return String is
      Dependency_Filepaths : constant Array_Type := Get_Dependency_Filepaths;
   begin
      if not Isset (Dependency_Filepaths, Slug) then
         return ""; -- false;

      end if;

      return Get_As_String (Dependency_Filepaths, Slug);
   end Get_Dependency_Filepath;

   -------------------------
   -- Get_Dependency_Data --
   -------------------------

   function Get_Dependency_Data (Slug : String) return Array_Type is
      Dependency_API_Data : constant Array_Type := Get_Dependency_API_Data;
   begin
      if Isset (Dependency_API_Data, Slug) then
         return As_Array (Get (Dependency_API_Data, Slug));
      end if;

      return Empty_Array; -- false;
   end Get_Dependency_Data;

   -------------------------------------------------
   -- Display_Admin_Notice_For_Unmet_Dependencies --
   -------------------------------------------------

   procedure Display_Admin_Notice_For_Unmet_Dependencies is
      use Php.Arrays;
      use Php.Strings;
      use UStrings;
      use Adi_Screens;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
   begin
      if In_Array
           ("", -- False,
            Get_Dependency_Filepaths,
            True)
      then
         declare
            Error_Message : UString :=
              +abs "Some required plugins are missing or inactive.";
         begin
            if Is_Multisite then
               if Current_User_Can ("manage_network_plugins") then
                  Append
                    (Error_Message,
                     " "
                     & Sprintf
                         (
                          -- translators: %s: Link to the network plugins page.
                          abs "<a href=""%s"">Manage plugins</a>.",
                          [ESC_URL (Network_Admin_URL ("plugins.php"))]));
               else
                  Append
                    (Error_Message,
                     " " & abs "Please contact your network administrator.");
               end if;
            elsif "plugins" /= Get_Current_Screen.Base then
               Append
                 (Error_Message,
                  " "
                  & Sprintf
                      (
                       -- translators: %s: Link to the plugins page.
                       abs "<a href=""%s"">Manage plugins</a>.",
                       [ESC_URL (Admin_URL ("plugins.php"))]));
            end if;

            Wp_Admin_Notice (-Error_Message, Build ("type", "warning"));
         end;
      end if;
   end Display_Admin_Notice_For_Unmet_Dependencies;

   ----------------------------------------------------
   -- Display_Admin_Notice_For_Circular_Dependencies --
   ----------------------------------------------------

   procedure Display_Admin_Notice_For_Circular_Dependencies is
      use Php.Arrays;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;

      Circular_Dependencies : Array_Type := Get_Circular_Dependencies;
   begin
      if not Circular_Dependencies.Is_Empty
        and then Length (Circular_Dependencies) > 1
      then
         Circular_Dependencies :=
           Array_Unique (Circular_Dependencies, Php.Arrays.Sort_Regular);
         declare
            Plugins         : constant Array_Type := Get_Plugins;
            Plugin_Dirnames : constant Array_Type := Get_Plugin_Dirnames;

            -- Build output lines.
            Circular_Dependency_Lines : UString := +"";
         begin
            for D in Circular_Dependencies.Iterate loop
               declare
                  Circular_Dependency : constant Array_Type :=
                    As_Array (Element (D));

                  First_Filepath : constant String :=
                    Get_As_String
                      (Plugin_Dirnames,
                       Get_As_String (Circular_Dependency, "[0]"));

                  Second_Filepath : constant String :=
                    Get_As_String
                      (Plugin_Dirnames,
                       Get_As_String (Circular_Dependency, "[1]"));
               begin
                  Append
                    (Circular_Dependency_Lines,
                     Sprintf
                       (
                        -- translators: 1: First plugin name, 2: Second plugin name.
                        "<li>"
                        & X_X
                            ("%1s requires %2s",
                             "The first plugin requires the second plugin.")
                        & "</li>",
                        [1 =>
                           "<strong>"
                           & ESC_HTML
                               (As_String
                                  (Get
                                     (Ref_2
                                        (Plugins, First_Filepath, "Name"))))
                           & "</strong>",
                         2 =>
                           "<strong>"
                           & ESC_HTML
                               (As_String
                                  (Get
                                     (Ref_2
                                        (Plugins, Second_Filepath, "Name"))))
                           & "</strong>"]));
               end;
            end loop;

            Wp_Admin_Notice
              (Sprintf
                 ("<p>%1s</p><ul>%2s</ul><p>%3s</p>",
                  [1 =>
                     abs "These plugins cannot be activated because their requirements are invalid.",
                   2 => -Circular_Dependency_Lines,
                   3 =>
                     abs "Please contact the plugin authors for more information."]),
               To_Array_Type
                 ([Build ("type", "warning"),
                   Build ("paragraph_wrap", False)]));
         end;
      end if;
   end Display_Admin_Notice_For_Circular_Dependencies;

   -- --
   -- -- Checks plugin dependencies after a plugin is installed via AJAX.
   -- --
   -- -- @since 6.5.0
   -- --
   -- public static function check_plugin_dependencies_during_ajax() then
   --         check_ajax_referer( "updates" );

   --         if ( empty( _POST["slug"] ) ) then
   --                 wp_send_json_error(
   --                         array(
   --                                 "slug"         => "",
   --                                 "pluginName"   => "",
   --                                 "errorCode"    => "no_plugin_specified",
   --                                 "errorMessage" => __( "No plugin specified." ),
   --                         )
   --                 );
   --         end;

   --         slug   = sanitize_key( wp_unslash( _POST["slug"] ) );
   --         status = array( "slug" => slug );

   --         self::get_plugins();
   --         self::get_plugin_dirnames();

   --         if ( ! isset( self::plugin_dirnames[ slug ] ) ) then
   --                 status["errorCode"]    = "plugin_not_installed";
   --                 status["errorMessage"] = __( "The plugin is not installed." );
   --                 wp_send_json_error( status );
   --         end;

   --         plugin_file          = self::plugin_dirnames[ slug ];
   --         status["pluginName"] = self::plugins[ plugin_file ]["Name"];
   --         status["plugin"]     = plugin_file;

   --         if ( current_user_can( "activate_plugin", plugin_file ) && is_plugin_inactive( plugin_file ) ) then
   --                 status["activateUrl"] = add_query_arg(
   --                         array(
   --                                 "_wpnonce" => wp_create_nonce( "activate-plugin_" . plugin_file ),
   --                                 "action"   => "activate",
   --                                 "plugin"   => plugin_file,
   --                         ),
   --                         is_multisite() ? network_admin_url( "plugins.php" ) : admin_url( "plugins.php" )
   --                 );
   --         end;

   --         if ( is_multisite() && current_user_can( "manage_network_plugins" ) ) then
   --                 status["activateUrl"] = add_query_arg( array( "networkwide" => 1 ), status["activateUrl"] );
   --         end;

   --         self::initialize();
   --         dependencies = self::get_dependencies( plugin_file );
   --         if ( empty( dependencies ) ) then
   --                 status["message"] = __( "The plugin has no required plugins." );
   --                 wp_send_json_success( status );
   --         end;

   --         require_once ABSPATH . "wp-admin/includes/plugin.php";

   --         inactive_dependencies = array();
   --         foreach ( dependencies as dependency ) then
   --                 if ( false === self::plugin_dirnames[ dependency ] || is_plugin_inactive( self::plugin_dirnames[ dependency ] ) ) then
   --                         inactive_dependencies[] = dependency;
   --                 end;
   --         end;

   --         if ( ! empty( inactive_dependencies ) ) then
   --                 inactive_dependency_names = array_map(
   --                         function ( dependency ) then
   --                                 if ( isset( self::dependency_api_data[ dependency ]["Name"] ) ) then
   --                                         inactive_dependency_name = self::dependency_api_data[ dependency ]["Name"];
   --                                 end; else then
   --                                         inactive_dependency_name = dependency;
   --                                 end;
   --                                 return inactive_dependency_name;
   --                         end;,
   --                         inactive_dependencies
   --                 );

   --                 status["errorCode"]    = "inactive_dependencies";
   --                 status["errorMessage"] = sprintf(
   --                         /* translators: %s: A list of inactive dependency plugin names.--
   --                         __( "The following plugins must be activated first: %s." ),
   --                         implode( ", ", inactive_dependency_names )
   --                 );
   --                 status["errorData"] = array_combine( inactive_dependencies, inactive_dependency_names );

   --                 wp_send_json_error( status );
   --         end;

   --         status["message"] = __( "All required plugins are installed and activated." );
   --         wp_send_json_success( status );
   -- end;

   -----------------
   -- Get_Plugins --
   -----------------

   function Get_Plugins return Array_Type is
   begin
      if Self.Plugins /= Empty_Array then
         -- if Is_Array (Self.Plugins) then
         return Self.Plugins;
      end if;

      -- require_once ABSPATH . "wp-admin/includes/plugin.php";
      Self.Plugins := Adi_Plugins.Get_Plugins;

      return Self.Plugins;
   end Get_Plugins;

   -------------------------------------------
   -- Read_Dependencies_From_Plugin_Headers --
   -------------------------------------------

   procedure Read_Dependencies_From_Plugin_Headers is
      use Php.Arrays;
   begin
      Self.Dependencies := Empty_Array;
      Self.Dependency_Slugs := Empty_Array;
      Self.Dependent_Slugs := Empty_Array;
      declare
         Plugins : constant Array_Type := Get_Plugins;
      begin
         for A in Plugins.Iterate loop
            declare
               Plugin : constant String := Key (A);
               Header : constant Array_Type := As_Array (Element (A));
            begin
               if "" = Get_As_String (Header, "RequiresPlugins") then
                  goto Continue;
               end if;
               declare
                  Dependency_Slugs : constant Array_Type :=
                    Sanitize_Dependency_Slugs
                         (Get_As_String (Header, "RequiresPlugins"));
               begin
                  Set
                    (Self.Dependencies, Plugin, From_Array (Dependency_Slugs));
                  Self.Dependency_Slugs :=
                    Array_Merge (Self.Dependency_Slugs, Dependency_Slugs);
               end;

               declare
                  Dependent_Slug : constant String := Convert_To_Slug (Plugin);
               begin
                  Set
                    (Self.Dependent_Slugs,
                     Plugin,
                     From_String (Dependent_Slug));
               end;
               <<Continue>>
            end;
         end loop;
      end;
      Self.Dependency_Slugs := Array_Unique (Self.Dependency_Slugs);
   end Read_Dependencies_From_Plugin_Headers;

   -------------------------------
   -- Sanitize_Dependency_Slugs --
   -------------------------------

   function Sanitize_Dependency_Slugs (Slugs : String) return Array_Type is
      use Php.Lists;
      use Php.Preg;
      use Php.Sorting;
      use Php.Strings;
      use Wp_Common;

      Sanitized_Slugs : List_Type; -- Array_Type;

      Slugs_2 : constant List_Type := Explode (",", Slugs);
   begin
      for Slug of Slugs_2 loop
         declare
            Slug_2 : constant String := Trim (Slug);

            --
            -- Filters a plugin dependency"s slug before matching to
            -- the WordPress.org slug format.
            --
            -- Can be used to switch between free and premium plugin slugs, for example.
            --
            -- @since 6.5.0
            --
            -- @param string slug The slug.
            --
            Slug_3 : constant String :=
              Apply_Filters ("wp_plugin_dependencies_slug", Slug_2);
         begin
            -- Match to WordPress.org slug format.
            if Preg_Match ("/^[a-z0-9]+(-[a-z0-9]+)*/mu", Slug_3) then
               Append (Sanitized_Slugs, Slug_3);
            end if;
         end;
      end loop;
      Sanitized_Slugs := List_Unique (Sanitized_Slugs);
      Sort (Sanitized_Slugs);

      return Empty_Array; -- Sanitized_Slugs;
   end Sanitize_Dependency_Slugs;

   ------------------------------
   -- Get_Dependency_Filepaths --
   ------------------------------

   function Get_Dependency_Filepaths return Array_Type is
   begin
      if Self.Dependency_Filepaths /= Empty_Array then
      -- if Is_Array (Self.Dependency_Filepaths) then
         return Self.Dependency_Filepaths;
      end if;

      if Empty_Array = Self.Dependency_Slugs then -- null
         return Empty_Array;
      end if;

      Self.Dependency_Filepaths := Empty_Array;

      declare
         Plugin_Dirnames : constant Array_Type := Get_Plugin_Dirnames;
      begin
         for A in Self.Dependency_Slugs.Iterate loop
            declare
               Slug : constant String := Key (A);
            begin
               if Isset (Plugin_Dirnames, Slug) then
                  Set
                    (Self.Dependency_Filepaths,
                     Slug,
                     From_String (Get_As_String (Plugin_Dirnames, Slug)));
                  goto Continue;
               end if;

               Set (Self.Dependency_Filepaths, Slug, From_Boolean (False));
            end;
            <<Continue>>
         end loop;
      end;

      return Self.Dependency_Filepaths;
   end Get_Dependency_Filepaths;

   -----------------------------
   -- Get_Dependency_API_Data --
   -----------------------------

   function Get_Dependency_API_Data return Array_Type is
      use Php.Arrays;
      use Php.Lists;
      use Php.Misc;
      use Php.Sorting;
      use Array_Lists;
      use UStrings;
      use Adi_Plugin_Install;
      use Inc_Load;
      use Inc_Options;

      -- global pagenow;
      Pagenow : constant String := -Globals.Global_Pagenow;
   begin
      if not Is_Admin
        or else ("plugins.php" /= Pagenow
                 and then "plugin-install.php" /= Pagenow)
      then
         return Empty_Array;
      end if;

      if True then
         -- Is_Array (Self.Dependency_API_Data) then
         return Self.Dependency_API_Data;
      end if;

      declare
         Plugins : constant Array_Type := Get_Plugins;
      begin
         Self.Dependency_API_Data :=
           Get_Site_Transient
             ("wp_plugin_dependencies_plugin_data"); -- (array)

         for A in Self.Dependency_Slugs.Iterate loop
            declare
               Slug : constant String := Key (A);
            begin
               -- Set transient for individual data, remove from self::dependency_api_data if transient expired.
               if Get_Site_Transient
                    ("wp_plugin_dependencies_plugin_timeout_" & Slug)
                 = Empty_Array -- not
               then
                  Delete (Self.Dependency_API_Data, Slug);
                  Set_Site_Transient
                    ("wp_plugin_dependencies_plugin_timeout_" & Slug,
                     True,
                     12 * Constants.HOUR_IN_SECONDS);
               end if;

               if Isset (Self.Dependency_API_Data, Slug) then
                  if False = As_Boolean (Get (Self.Dependency_API_Data, Slug))
                  then
                     declare
                        Dependency_File : constant String :=
                          Get_Dependency_Filepath (Slug);
                     begin
                        if "" = Dependency_File then
                           -- false
                           Set
                             (Self.Dependency_API_Data,
                              Slug,
                              From_Array (Build ("Name", Slug)));
                        else
                           Set
                             (Self.Dependency_API_Data,
                              Slug,
                              From_Array
                                (Build
                                   ("Name",
                                    Get
                                      (Ref_2
                                         (Plugins,
                                          Dependency_File,
                                          "Name")))));
                        end if;
                     end;
                     goto Continue;
                  end if;

                  -- Don't hit the Plugin API if data exists.
                  if not Empty
                           (Ref_2
                              (Self.Dependency_API_Data, Slug, "last_updated"))
                  then
                     goto Continue;
                  end if;
               end if;

               if not Function_Exists ("plugins_api") then
                  null; --  require_once ABSPATH . "wp-admin/includes/plugin-install.php";

               end if;

               declare
                  Information : constant Plugin_API_Result :=
                    Plugins_API
                      ("plugin_information",
                       (Null_Plugin_API_Args
                        with delta
                          -- To_Array_Type
                          Slug   => +Slug,
                          -- ([Build ("slug", Slug),
                          Fields =>
                            --Build
                            -- ("fields",
                            To_Array_Type
                              ([Build ("short_description", True),
                                Build ("icons", True)]))); -- ]));
               begin
                  if not Information.Success then
                     -- if Is_Wp_Error (Information) then
                     goto Continue;
                  end if;

                  Set
                    (Self.Dependency_API_Data,
                     Slug,
                     From_Array (Information.Arry)); -- (array)
               end;
               -- plugins_api() returns "name" not "Name".

               Set_2
                 (Self.Dependency_API_Data,
                  Slug,
                  "Name",
                  Value =>
                    Get (Ref_2 (Self.Dependency_API_Data, Slug, "name")));

               Set_Site_Transient
                 ("wp_plugin_dependencies_plugin_data",
                  Self.Dependency_API_Data,
                  0);
            end;
            <<Continue>>
         end loop;

         -- Remove from self::dependency_api_data if slug no longer a dependency.
         declare
            Differences : constant List_Type :=
              List_Diff -- Array_Diff
                (Array_Keys (Self.Dependency_API_Data),
                 Array_Keys (Self.Dependency_Slugs)); -- array_keys added
         begin
            for Difference of Differences loop
               Delete (Self.Dependency_API_Data, Difference);
            end loop;
         end;
      end;
      Ksort (Self.Dependency_API_Data);
      -- Remove empty elements.
      Self.Dependency_API_Data := Array_Filter (Self.Dependency_API_Data);
      Set_Site_Transient
        ("wp_plugin_dependencies_plugin_data", Self.Dependency_API_Data, 0);

      return Self.Dependency_API_Data;
   end Get_Dependency_API_Data;

   -----------------------------
   -- Get_Dependency_API_Data --
   -----------------------------

   procedure Get_Dependency_API_Data is
      Unused : constant Array_Type := Get_Dependency_API_Data;
   begin
      null;
   end Get_Dependency_API_Data;

   -------------------------
   -- Get_Plugin_Dirnames --
   -------------------------

   function Get_Plugin_Dirnames return Array_Type is
      use Php.Arrays;
   begin
      if Self.Plugin_Dirnames /= Empty_Array then
         -- if Is_Array (Self.Plugin_Dirnames) then
         return Self.Plugin_Dirnames;
      end if;

      Self.Plugin_Dirnames := Empty_Array;

      declare
         Plugin_Files : constant List_Type := Array_Keys (Get_Plugins);
      begin
         for Plugin_File of Plugin_Files loop
            declare
               Slug : constant String := Convert_To_Slug (Plugin_File);
            begin
               Set (Self.Plugin_Dirnames, Slug, From_String (Plugin_File));
            end;
         end loop;
      end;
      return Self.Plugin_Dirnames;
   end Get_Plugin_Dirnames;

   -------------------------------
   -- Get_Circular_Dependencies --
   -------------------------------

   function Get_Circular_Dependencies return Array_Type is
      use Php.Arrays;
   begin
      if Self.Circular_Dependencies_Pairs = Empty_Array then
      -- if Is_Array (Self.Circular_Dependencies_Pairs) then
         return Self.Circular_Dependencies_Pairs;
      end if;

      if Self.Dependencies.Is_Empty then -- null
         return Empty_Array;
      end if;

      Self.Circular_Dependencies_Slugs := Empty_List; -- Array;
      Self.Circular_Dependencies_Pairs := Empty_Array;

      for A in Self.Dependencies.Iterate loop
         declare
            Dependent    : constant String := Key (A);
            Dependencies : constant Array_Type := As_Array (Element (A));

            --
            -- dependent is in "a/a.php" format. Dependencies are stored as slugs, i.e. "a".
            --
            -- Convert dependent to slug format for checking.
            --
            Dependent_Slug : constant String := Convert_To_Slug (Dependent);
         begin
            Self.Circular_Dependencies_Pairs :=
              Array_Merge
                (Self.Circular_Dependencies_Pairs,
                 Check_For_Circular_Dependencies
                   (Build (Dependent_Slug, ""), Dependencies) -- (array)
                );
         end;
      end loop;

      return Self.Circular_Dependencies_Pairs;
   end Get_Circular_Dependencies;

   -------------------------------------
   -- Check_For_Circular_Dependencies --
   -------------------------------------

   function Check_For_Circular_Dependencies
     (Dependents : Array_Type; Dependencies : Array_Type) return Array_Type
   is
      use Php.Arrays;

      Dependents_2   : Array_Type := Dependents;
      Dependencies_2 : Array_Type := Dependencies;

      Circular_Dependencies_Pairs : Array_Type;
   begin
      declare
         -- Check for a self-dependency.
         Dependents_Location_In_Its_Own_Dependencies : constant Array_Type :=
           Array_Intersect (Dependents_2, Dependencies_2);
      begin
         if not Dependents_Location_In_Its_Own_Dependencies.Is_Empty then
            for A in Dependents_Location_In_Its_Own_Dependencies.Iterate loop
               declare
                  Self_Dependency : constant String := Key (A);
               begin
                  Self.Circular_Dependencies_Slugs.Append (Self_Dependency);
                  Circular_Dependencies_Pairs.Append
                    (Self_Dependency, From_String (Self_Dependency));

                  -- No need to check for itself again.
                  Delete
                    (Dependencies_2,
                     Array_Search
                       (Needle   => Self_Dependency,
                        Haystack => Dependencies_2,
                        Strict   => True));
               end;
            end loop;
         end if;
      end;

      --
      -- Check each dependency to see:
      -- 1. If it has dependencies.
      -- 2. If its list of dependencies includes one of its own dependents.
      --
      for A in Dependencies_2.Iterate loop
         -- Check if the dependency is also a dependent.
         declare
            Dependency : constant String := Key (A);

            Dependency_Location_In_Dependents : constant String :=
              Array_Search
                (Needle   => Dependency,
                 Haystack => Self.Dependent_Slugs,
                 Strict   => True);
         begin
            if "" /= Dependency_Location_In_Dependents then
               -- false
               declare
                  Dependencies_Of_The_Dependency : Array_Type := -- String :=
                    As_Array
                         (Get
                            (Self.Dependencies,
                             Dependency_Location_In_Dependents));
               begin
                  for B in Dependents.Iterate loop
                     -- Check if its dependencies includes one of its own dependents.
                     declare
                        Dependent : constant String := Key (B);

                        Dependent_Location_In_Dependency_Dependencies :
                          constant String :=
                            Array_Search
                              (Needle   => Dependent,
                               Haystack => Dependencies_Of_The_Dependency,
                               Strict   => True);
                     begin
                        if "" -- False
                          /= Dependent_Location_In_Dependency_Dependencies
                        then
                           Self.Circular_Dependencies_Slugs.Append (Dependent);
                           Self.Circular_Dependencies_Slugs.Append
                             (Dependency);
                           Circular_Dependencies_Pairs.Append
                             (Dependent, From_String (Dependency));

                           -- Remove the dependent from its dependency's dependencies.
                           Delete
                             (Dependencies_Of_The_Dependency,
                              Dependent_Location_In_Dependency_Dependencies);
                        end if;
                     end;
                  end loop;

                  Dependents_2.Append (Dependency, From_String ("")); -- "" added

                  --
                  -- Now check the dependencies of the dependency's dependencies for the dependent.
                  --
                  -- Yes, that does make sense.
                  --
                  Circular_Dependencies_Pairs :=
                    Array_Merge
                      (Circular_Dependencies_Pairs,
                       Check_For_Circular_Dependencies
                         (Dependents_2,
                          Array_Unique (Dependencies_Of_The_Dependency)));
               end;
            end if;
         end;
      end loop;

      return Circular_Dependencies_Pairs;
   end Check_For_Circular_Dependencies;

   ---------------------
   -- Convert_To_Slug --
   ---------------------

   function Convert_To_Slug (Plugin_File : String) return String is
      use Php.Files;
      use Php.Strings;
   begin
      if "hello.php" = Plugin_File then
         return "hello-dolly";
      end if;

      return
        (if Str_Contains (Plugin_File, "/")
         then Dirname (Plugin_File)
         else Str_Replace (".php", "", Plugin_File));
   end Convert_To_Slug;

end Class_Plugin_Dependencies;
