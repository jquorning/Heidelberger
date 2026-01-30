--
-- Dependencies API: Scripts functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Php.Preg;
with Php.Strings;

with UStrings;

with Class_Dependencies;
with Class_Scripts;
with Inc_Functions;
with Inc_L10n;
with Inc_Plugins;
with Inc_Script_Loader;

package body Inc_Functions_Wp_Scripts
is

--    ------------------
--    -- Wp_Scripts_X --
--    ------------------

--    function Wp_Scripts_X
--             return Class_Scripts.Wp_Scripts
--    is
-- --    global wp_scripts;
--    begin
--       -- if ( ! ( wp_scripts instanceof WP_Scripts ) ) then
--       --           wp_scripts = new WP_Scripts();
--       -- end if;

--       return Class_Scripts.Wp_Scripts;
--    end Wp_Scripts_X;

   ---------------------------------------
   -- X_Wp_Scripts_Maybe_Doing_It_Wrong --
   ---------------------------------------

   procedure X_Wp_Scripts_Maybe_Doing_It_Wrong (Funct  : String;
                                                Handle : String := "")
   is
      use Php.Strings;
      use UStrings;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Plugins;

      Message : UString;
   begin
      if
        Did_Action ("init")                  or else
        Did_Action ("wp_enqueue_scripts")    or else
        Did_Action ("admin_enqueue_scripts") or else
        Did_Action ("login_enqueue_scripts")
      then
         return;
      end if;

      Message := +Sprintf (
        -- translators: 1: wp_enqueue_scripts, 2: admin_enqueue_scripts, 3: login_enqueue_scripts
        abs "Scripts and styles should not be registered or enqueued until the %1s, %2s, or %3s hooks.",
        [
          1 => "<code>wp_enqueue_scripts</code>",
          2 => "<code>admin_enqueue_scripts</code>",
          3 => "<code>login_enqueue_scripts</code>"
        ]);

      if Handle /= "" then
         Append (Message, " " & Sprintf (
           -- translators: %s: Name of the script or stylesheet.
           abs "This notice was triggered by the %s handle.",
           [1 => "<code>" & Handle & "</code>"]
         ));
      end if;

      X_Doing_It_Wrong (
        Funct,
        -Message,
        "3.3.0"
      );
   end X_Wp_Scripts_Maybe_Doing_It_Wrong;

   ----------------------
   -- Wp_Print_Scripts --
   ----------------------

   function Wp_Print_Scripts (Handles : List_Type := Empty_List)
                              return List_Type
   is
--    global wp_scripts;
      use Class_Scripts;
      use Inc_Script_Loader;
      use Inc_Plugins;
   begin
      --
      -- Fires before scripts in the handles queue are printed.
      --
      -- @since 2.1.0
      --
      Do_Action ("wp_print_scripts");

--    if "" = Handles then  -- For "wp_head".
--       Handles := False;
--    end if;

      X_Wp_Scripts_Maybe_Doing_It_Wrong ("__FUNCTION__");

--    if Wp_Scripts not in Class_Scripts.Wp_Scripts then -- instanceof
--       if not Handles then
--          return array(); -- No need to instantiate if nothing is there.
--       end if;
--    end if;

      return Global_Wp_Scripts.Do_Items (Handles);
   end Wp_Print_Scripts;

   ----------------------
   -- Wp_Print_Scripts --
   ----------------------

   procedure Wp_Print_Scripts (Handles : List_Type := Empty_List)
   is
      Unused : constant List_Type :=
        Wp_Print_Scripts (Handles);
   begin
      null;
   end Wp_Print_Scripts;

   --------------------------
   -- Wp_Add_Inline_Script --
   --------------------------

   function Wp_Add_Inline_Script (Handle   : String;
                                  Data     : String;
                                  Position : String := "after")
                                  return Boolean
   is
      use Php.Preg;
      use Php.Strings;
      use Class_Scripts;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Script_Loader;
   begin
      X_Wp_Scripts_Maybe_Doing_It_Wrong ("__FUNCTION__", Handle);

      if 0 /= Stripos (Data, "</script>") then
         X_Doing_It_Wrong (
           "__FUNCTION__",
           Sprintf (
             -- translators: 1: <script>, 2: wp_add_inline_script()
             abs "Do not pass %1s tags to %2s.",
             [
               1 => "<code>&lt;script&gt;</code>",
               2 => "<code>wp_add_inline_script()</code>"
             ]
           ),
           "4.5.0"
         );
         declare
            Data_2 : constant String :=
              Trim (Preg_Replace ("#<script[^>]*>(.*)</script>#is",
                                  "1", Data));
         begin
            return
              Global_Wp_Scripts.Add_Inline_Script (Handle, Data_2, Position);
         end;
      end if;

      return Global_Wp_Scripts.Add_Inline_Script (Handle, Data, Position);
   end Wp_Add_Inline_Script;

   procedure Wp_Add_Inline_Script (Handle   : String;
                                   Data     : String;
                                   Position : String := "after")
   is
      Unused : constant Boolean :=
        Wp_Add_Inline_Script (Handle, Data, Position);
   begin
      null;
   end Wp_Add_Inline_Script;

-- --
-- -- Register a new script.
-- --
-- -- Registers a script to be enqueued later using the wp_enqueue_script() function.
-- --
-- -- @see WP_Dependencies::add()
-- -- @see WP_Dependencies::add_data()
-- --
-- -- @since 2.1.0
-- -- @since 4.3.0 A return value was added.
-- --
-- -- @param string           handle    Name of the script. Should be unique.
-- -- @param string|false     src       Full URL of the script, or path of the script relative to the WordPress root directory.
-- --                                    If source is set to false, script is an alias of other scripts it depends on.
-- -- @param string[]         deps      Optional. An array of registered script handles this script depends on. Default empty array.
-- -- @param string|bool|null ver       Optional. String specifying script version number, if it has one, which is added to the URL
-- --                                    as a query string for cache busting purposes. If version is set to false, a version
-- --                                    number is automatically added equal to current installed WordPress version.
-- --                                    If set to null, no version is added.
-- -- @param bool             in_footer Optional. Whether to enqueue the script before `</body>` instead of in the `<head>`.
-- --                                    Default "false".
-- -- @return bool Whether the script has been registered. True on success, false on failure.
-- --
-- function wp_register_script( handle, src, deps = array(), ver = false, in_footer = false ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         wp_scripts = wp_scripts();

--         registered = wp_scripts.add( handle, src, deps, ver );
--         if ( in_footer ) then
--                 wp_scripts.add_data( handle, "group", 1 );
--         end;

--         return registered;
-- end;

-- --
-- -- Localize a script.
-- --
-- -- Works only if the script has already been registered.
-- --
-- -- Accepts an associative array l10n and creates a JavaScript object:
-- --
-- --     "object_name" = then
-- --         key: value,
-- --         key: value,
-- --         ...
-- --     end;
-- --
-- -- @see WP_Scripts::localize()
-- -- @link https://core.trac.wordpress.org/ticket/11520
-- -- @global WP_Scripts wp_scripts The WP_Scripts object for printing scripts.
-- --
-- -- @since 2.2.0
-- --
-- -- @todo Documentation cleanup
-- --
-- -- @param string handle      Script handle the data will be attached to.
-- -- @param string object_name Name for the JavaScript object. Passed directly, so it should be qualified JS variable.
-- --                            Example: "/[a-zA-Z0-9_]+/".
-- -- @param array  l10n        The data itself. The data can be either a single or multi-dimensional array.
-- -- @return bool True if the script was successfully localized, false otherwise.
-- --
-- function wp_localize_script( handle, object_name, l10n ) then
--         global wp_scripts;

--         if ( ! ( wp_scripts instanceof WP_Scripts ) ) then
--                 _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );
--                 return false;
--         end;

--         return wp_scripts.localize( handle, object_name, l10n );
-- end;

-- --
-- -- Sets translated strings for a script.
-- --
-- -- Works only if the script has already been registered.
-- --
-- -- @see WP_Scripts::set_translations()
-- -- @global WP_Scripts wp_scripts The WP_Scripts object for printing scripts.
-- --
-- -- @since 5.0.0
-- -- @since 5.1.0 The `domain` parameter was made optional.
-- --
-- -- @param string handle Script handle the textdomain will be attached to.
-- -- @param string domain Optional. Text domain. Default "default".
-- -- @param string path   Optional. The full file path to the directory containing translation files.
-- -- @return bool True if the text domain was successfully localized, false otherwise.
-- --
-- function wp_set_script_translations( handle, domain = "default", path = "" ) then
--         global wp_scripts;

--         if ( ! ( wp_scripts instanceof WP_Scripts ) ) then
--                 _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );
--                 return false;
--         end;

--         return wp_scripts.set_translations( handle, domain, path );
-- end;

-- --
-- -- Remove a registered script.
-- --
-- -- Note: there are intentional safeguards in place to prevent critical admin scripts,
-- -- such as jQuery core, from being unregistered.
-- --
-- -- @see WP_Dependencies::remove()
-- --
-- -- @since 2.1.0
-- --
-- -- @global string pagenow The filename of the current screen.
-- --
-- -- @param string handle Name of the script to be removed.
-- --
-- function wp_deregister_script( handle ) then
--         global pagenow;

--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         --
--         -- Do not allow accidental or negligent de-registering of critical scripts in the admin.
--         -- Show minimal remorse if the correct hook is used.
--         --
--         current_filter = current_filter();
--         if ( ( is_admin() && "admin_enqueue_scripts" !== current_filter ) ||
--                 ( "wp-login.php" === pagenow && "login_enqueue_scripts" !== current_filter )
--         ) then
--                 not_allowed = array(
--                         "jquery",
--                         "jquery-core",
--                         "jquery-migrate",
--                         "jquery-ui-core",
--                         "jquery-ui-accordion",
--                         "jquery-ui-autocomplete",
--                         "jquery-ui-button",
--                         "jquery-ui-datepicker",
--                         "jquery-ui-dialog",
--                         "jquery-ui-draggable",
--                         "jquery-ui-droppable",
--                         "jquery-ui-menu",
--                         "jquery-ui-mouse",
--                         "jquery-ui-position",
--                         "jquery-ui-progressbar",
--                         "jquery-ui-resizable",
--                         "jquery-ui-selectable",
--                         "jquery-ui-slider",
--                         "jquery-ui-sortable",
--                         "jquery-ui-spinner",
--                         "jquery-ui-tabs",
--                         "jquery-ui-tooltip",
--                         "jquery-ui-widget",
--                         "underscore",
--                         "backbone",
--                 );

--                 if ( in_array( handle, not_allowed, true ) ) then
--                         _doing_it_wrong(
--                                 __FUNCTION__,
--                                 sprintf(
--                                         /* translators: 1: Script name, 2: wp_enqueue_scripts--
--                                         __( "Do not deregister the %1s script in the administration area. To target the front-end theme, use the %2s hook." ),
--                                         "<code>handle</code>",
--                                         "<code>wp_enqueue_scripts</code>"
--                                 ),
--                                 "3.6.0"
--                         );
--                         return;
--                 end;
--         end;

--         wp_scripts().remove( handle );
-- end;

-- --
-- -- Enqueue a script.
-- --
-- -- Registers the script if src provided (does NOT overwrite), and enqueues it.
-- --
-- -- @see WP_Dependencies::add()
-- -- @see WP_Dependencies::add_data()
-- -- @see WP_Dependencies::enqueue()
-- --
-- -- @since 2.1.0
-- --
-- -- @param string           handle    Name of the script. Should be unique.
-- -- @param string           src       Full URL of the script, or path of the script relative to the WordPress root directory.
-- --                                    Default empty.
-- -- @param string[]         deps      Optional. An array of registered script handles this script depends on. Default empty array.
-- -- @param string|bool|null ver       Optional. String specifying script version number, if it has one, which is added to the URL
-- --                                    as a query string for cache busting purposes. If version is set to false, a version
-- --                                    number is automatically added equal to current installed WordPress version.
-- --                                    If set to null, no version is added.
-- -- @param bool             in_footer Optional. Whether to enqueue the script before `</body>` instead of in the `<head>`.
-- --                                    Default "false".
-- --

   -----------------------
   -- Wp_Enqueue_Script --
   -----------------------

   procedure Wp_Enqueue_Script (Handle    : String;
                                Src       : String    := "";
                                Deps      : List_Type := Empty_List;
                                Ver       : String    := "";
                                In_Footer : Boolean   := False)
   is
      use Php.Strings;
      use Class_Scripts;
      use Class_Dependencies;
   begin
      X_Wp_Scripts_Maybe_Doing_It_Wrong ("__FUNCTION__", Handle);
      declare
         Scripts : Wp_Scripts := X_Construct; -- wp_scripts();
      begin
         if Src /= "" or else In_Footer then
            declare
               X_Handle : constant List_Type := Explode ("?", Handle);
               Unused   : Boolean;
            begin
               if Src /= "" then
                  Unused := Class_Dependencies.Add
                    (Wp_Dependencies (Scripts),
                     X_Handle.First_Element, Src, Deps, Ver); -- (0)
               end if;

               if In_Footer then
                  Unused := Class_Dependencies.Add_Data
                    (Wp_Dependencies (Scripts),
                     X_Handle.First_Element, "group", "1"); -- (0), 1 -> "1"
               end if;
            end;
         end if;
         Scripts.Enqueue ([Handle]);
      end;
   end Wp_Enqueue_Script;

-- function wp_enqueue_script( handle, src = "", deps = array(), ver = false, in_footer = false ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         wp_scripts = wp_scripts();

--         if ( src || in_footer ) then
--                 _handle = explode( "?", handle );

--                 if ( src ) then
--                         wp_scripts.add( _handle[0], src, deps, ver );
--                 end;

--                 if ( in_footer ) then
--                         wp_scripts.add_data( _handle[0], "group", 1 );
--                 end;
--         end;

--         wp_scripts.enqueue( handle );
-- end;

-- --
-- -- Remove a previously enqueued script.
-- --
-- -- @see WP_Dependencies::dequeue()
-- --
-- -- @since 3.1.0
-- --
-- -- @param string handle Name of the script to be removed.
-- --
-- function wp_dequeue_script( handle ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         wp_scripts().dequeue( handle );
-- end;

-- --
-- -- Determines whether a script has been added to the queue.
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tags} article in the Theme Developer Handbook.
-- --
-- -- @since 2.8.0
-- -- @since 3.5.0 "enqueued" added as an alias of the "queue" list.
-- --
-- -- @param string handle Name of the script.
-- -- @param string list   Optional. Status of the script to check. Default "enqueued".
-- --                       Accepts "enqueued", "registered", "queue", "to_do", and "done".
-- -- @return bool Whether the script is queued.
-- --
-- function wp_script_is( handle, list = "enqueued" ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         return (bool) wp_scripts().query( handle, list );
-- end;

-- --
-- -- Add metadata to a script.
-- --
-- -- Works only if the script has already been registered.
-- --
-- -- Possible values for key and value:
-- -- "conditional" string Comments for IE 6, lte IE 7, etc.
-- --
-- -- @since 4.2.0
-- --
-- -- @see WP_Dependencies::add_data()
-- --
-- -- @param string handle Name of the script.
-- -- @param string key    Name of data point for which we're storing a value.
-- -- @param mixed  value  String containing the data to be added.
-- -- @return bool True on success, false on failure.
-- --
-- function wp_script_add_data( handle, key, value ) then
--         return wp_scripts().add_data( handle, key, value );
-- end;

end Inc_Functions_Wp_Scripts;
