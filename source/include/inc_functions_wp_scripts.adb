--
-- Dependencies API: Scripts functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Hb_Common;
with Php;

with Inc_Class_Wp_Dependencies;
with Inc_Class_Wp_Dependency;
with Inc_Class_Wp_Scripts;

package body Inc_Functions_Wp_Scripts
is
   use Hb_Common;
   use Php;
-- --
-- -- Initialize wp_scripts if it has not been set.
-- --
-- -- @global WP_Scripts wp_scripts
-- --
-- -- @since 4.2.0
-- --
-- -- @return WP_Scripts WP_Scripts instance.
-- --
-- function wp_scripts() then
--         global wp_scripts;

--         if ( ! ( wp_scripts instanceof WP_Scripts ) ) then
--                 wp_scripts = new WP_Scripts();
--         end;

--         return wp_scripts;
-- end;

--
-- Helper function to output a _doing_it_wrong message when applicable.
--
-- @ignore
-- @since 4.2.0
-- @since 5.5.0 Added the `handle` parameter.
--
-- @param string function Function name.
-- @param string handle   Optional. Name of the script or stylesheet that was
--                         registered or enqueued too early. Default empty.
--
   procedure X_Wp_Scripts_Maybe_Doing_It_Wrong (Funct  : String;
                                                Handle : String := "")
   is
   begin
      null;
   end X_Wp_Scripts_Maybe_Doing_It_Wrong;
--         if ( did_action( "init" ) || did_action( "wp_enqueue_scripts" )
--                 || did_action( "admin_enqueue_scripts" ) || did_action( "login_enqueue_scripts" )
--         ) then
--                 return;
--         end;

--         message = sprintf(
--                 -- translators: 1: wp_enqueue_scripts, 2: admin_enqueue_scripts, 3: login_enqueue_scripts
--                 __( "Scripts and styles should not be registered or enqueued until the %1s, %2s, or %3s hooks." ),
--                 "<code>wp_enqueue_scripts</code>",
--                 "<code>admin_enqueue_scripts</code>",
--                 "<code>login_enqueue_scripts</code>"
--         );

--         if ( handle ) then
--                 message .= " " . sprintf(
--                         /* translators: %s: Name of the script or stylesheet.--
--                         __( "This notice was triggered by the %s handle." ),
--                         "<code>" . handle . "</code>"
--                 );
--         end;

--         _doing_it_wrong(
--                 function,
--                 message,
--                 "3.3.0"
--         );
-- end;

-- --
-- -- Prints scripts in document head that are in the handles queue.
-- --
-- -- Called by admin-header.php and then@see "wp_head"end; hook. Since it is called by wp_head on every page load,
-- -- the function does not instantiate the WP_Scripts object unless script names are explicitly passed.
-- -- Makes use of already-instantiated wp_scripts global if present. Use provided then@see "wp_print_scripts"end;
-- -- hook to register/enqueue new scripts.
-- --
-- -- @see WP_Scripts::do_item()
-- -- @global WP_Scripts wp_scripts The WP_Scripts object for printing scripts.
-- --
-- -- @since 2.1.0
-- --
-- -- @param string|bool|array handles Optional. Scripts to be printed. Default "false".
-- -- @return string[] On success, an array of handles of processed WP_Dependencies items; otherwise, an empty array.
-- --
-- function wp_print_scripts( handles = false ) then
--         global wp_scripts;

--         --
--         -- Fires before scripts in the handles queue are printed.
--         --
--         -- @since 2.1.0
--         --
--         do_action( "wp_print_scripts" );

--         if ( "" === handles ) then // For "wp_head".
--                 handles = false;
--         end;

--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__ );

--         if ( ! ( wp_scripts instanceof WP_Scripts ) ) then
--                 if ( ! handles ) then
--                         return array(); // No need to instantiate if nothing is there.
--                 end;
--         end;

--         return wp_scripts().do_items( handles );
-- end;

-- --
-- -- Adds extra code to a registered script.
-- --
-- -- Code will only be added if the script is already in the queue.
-- -- Accepts a string data containing the Code. If two or more code blocks
-- -- are added to the same script handle, they will be printed in the order
-- -- they were added, i.e. the latter added code can redeclare the previous.
-- --
-- -- @since 4.5.0
-- --
-- -- @see WP_Scripts::add_inline_script()
-- --
-- -- @param string handle   Name of the script to add the inline script to.
-- -- @param string data     String containing the JavaScript to be added.
-- -- @param string position Optional. Whether to add the inline script before the handle
-- --                         or after. Default "after".
-- -- @return bool True on success, false on failure.
-- --
-- function wp_add_inline_script( handle, data, position = "after" ) then
--         _wp_scripts_maybe_doing_it_wrong( __FUNCTION__, handle );

--         if ( false !== stripos( data, "</script>" ) ) then
--                 _doing_it_wrong(
--                         __FUNCTION__,
--                         sprintf(
--                                 /* translators: 1: <script>, 2: wp_add_inline_script()--
--                                 __( "Do not pass %1s tags to %2s." ),
--                                 "<code>&lt;script&gt;</code>",
--                                 "<code>wp_add_inline_script()</code>"
--                         ),
--                         "4.5.0"
--                 );
--                 data = trim( preg_replace( "#<script[^>]*>(.*)</script>#is", "1", data ) );
--         end;

--         return wp_scripts().add_inline_script( handle, data, position );
-- end;

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

-- function wp_enqueue_script( handle, src = '', deps = array(), ver = false, in_footer = false ) then
   procedure Wp_Enqueue_Script (Handle    : String;
                                Src       : String       := "";
                                Deps      : String_Array := Empty_String_Array;
                                Ver       : String       := ""; -- Boolean    := False;
                                In_Footer : Boolean      := False)
   is
      use Inc_Class_Wp_Scripts;
      use Inc_Class_Wp_Dependencies;
      use Inc_Class_Wp_Dependency;
      use Inc_Functions_Wp_Scripts;
      use String_Vectors;
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
                  Unused := Inc_Class_Wp_Dependencies.Add
                    (Wp_Dependencies (Scripts),
                     -(X_Handle.First_Element), Src, Deps, Ver); -- (0)
               end if;

               if In_Footer then
                  Unused := Inc_Class_Wp_Dependencies.Add_Data
                    (Wp_Dependencies (Scripts),
                     -(X_Handle.First_Element), "group", "1"); -- (0), 1 -> "1"
               end if;
            end;
         end if;
         Scripts.Enqueue (To_Vector (New_Item => Handle,
                                     Length   => 1));
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
-- -- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tagsend; article in the Theme Developer Handbook.
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
