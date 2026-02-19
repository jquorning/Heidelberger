--
-- Upgrade API: Language_Pack_Upgrader class
--
-- @package WordPress
-- @subpackage Upgrader
-- @since 4.6.0
--

with Arrays;

with Class_Upgraders;
with Class_Upgrader_Skins;

package Adi_Class_Language_Pack_Upgraders
is
   use Arrays;

   --
   -- Core class used for updating/installing language packs (translations)
   -- for plugins, themes, and core.
   --
   -- @since 3.7.0
   -- @since 4.6.0 Moved to its own file from wp-admin/includes/class-wp-upgrader.php.
   --
   -- @see WP_Upgrader
   --
   type Language_Pack_Upgrader
      is new Class_Upgraders.Wp_Upgrader with
      record
         --
         -- Result of the language pack upgrade.
         --
         -- @since 3.7.0
         -- @var array|WP_Error result
         -- @see WP_Upgrader::result
         --
--         public result;

         --
         -- Whether a bulk upgrade/installation is being performed.
         --
         -- @since 3.7.0
         -- @var bool bulk
         --
         Bulk : Boolean := True;

      end record;

   --
   -- Constructor
   --
   function X_Construct (Skin : Class_Upgrader_Skins.Wp_Upgrader_Skin) -- := null
                         return Language_Pack_Upgrader;

        -- --
        -- -- Asynchronously upgrades language packs after other upgrades have been made.
        -- --
        -- -- Hooked to the then@see "upgrader_process_complete"end; action by default.
        -- --
        -- -- @since 3.7.0
        -- --
        -- -- @param false|WP_Upgrader upgrader Optional. WP_Upgrader instance or false. If `upgrader` is
        -- --                                    a Language_Pack_Upgrader instance, the method will bail to
        -- --                                    avoid recursion. Otherwise unused. Default false.
        -- --
        -- public static function async_upgrade( upgrader = false ) then
        --         // Avoid recursion.
        --         if ( upgrader && upgrader instanceof Language_Pack_Upgrader ) then
        --                 return;
        --         end;

        --         // Nothing to do?
        --         language_updates = wp_get_translation_updates();
        --         if ( ! language_updates ) then
        --                 return;
        --         end;

        --         /*
        --         -- Avoid messing with VCS installations, at least for now.
        --         -- Noted: this is not the ideal way to accomplish this.
        --         --
        --         check_vcs = new WP_Automatic_Updater;
        --         if ( check_vcs.is_vcs_checkout( WP_CONTENT_DIR ) ) then
        --                 return;
        --         end;

        --         foreach ( language_updates as key => language_update ) then
        --                 update = ! empty( language_update.autoupdate );

        --                 --
        --                 -- Filters whether to asynchronously update translation for core, a plugin, or a theme.
        --                 --
        --                 -- @since 4.0.0
        --                 --
        --                 -- @param bool   update          Whether to update.
        --                 -- @param object language_update The update offer.
        --                 --
        --                 update = apply_filters( "async_update_translation", update, language_update );

        --                 if ( ! update ) then
        --                         unset( language_updates[ key ] );
        --                 end;
        --         end;

        --         if ( empty( language_updates ) ) then
        --                 return;
        --         end;

        --         // Re-use the automatic upgrader skin if the parent upgrader is using it.
        --         if ( upgrader && upgrader.skin instanceof Automatic_Upgrader_Skin ) then
        --                 skin = upgrader.skin;
        --         end; else then
        --                 skin = new Language_Pack_Upgrader_Skin(
        --                         array(
        --                                 "skip_header_footer" => true,
        --                         )
        --                 );
        --         end;

        --         lp_upgrader = new Language_Pack_Upgrader( skin );
        --         lp_upgrader.bulk_upgrade( language_updates );
        -- end;

        -- --
        -- -- Initialize the upgrade strings.
        -- --
        -- -- @since 3.7.0
        -- --
        -- public function upgrade_strings() then
        --         this.strings["starting_upgrade"] = __( "Some of your translations need updating. Sit tight for a few more seconds while they are updated as well." );
        --         this.strings["up_to_date"]       = __( "Your translations are all up to date." );
        --         this.strings["no_package"]       = __( "Update package not available." );
        --         /* translators: %s: Package URL.--
        --         this.strings["downloading_package"] = sprintf( __( "Downloading translation from %s&#8230;" ), "<span class="code">%s</span>" );
        --         this.strings["unpack_package"]      = __( "Unpacking the update&#8230;" );
        --         this.strings["process_failed"]      = __( "Translation update failed." );
        --         this.strings["process_success"]     = __( "Translation updated successfully." );
        --         this.strings["remove_old"]          = __( "Removing the old version of the translation&#8230;" );
        --         this.strings["remove_old_failed"]   = __( "Could not remove the old translation." );
        -- end;

   --
   -- Upgrade a language pack.
   --
   -- @since 3.7.0
   --
   -- @param string|false update Optional. Whether an update offer is available.
   --                             Default false.
   -- @param array        args   Optional. Other optional arguments, see
   --                             Language_Pack_Upgrader::bulk_upgrade(). Default
   --                             empty array.
   -- @return array|bool|WP_Error The result of the upgrade, or a WP_Error object
   --                              instead.
   --
   function Upgrade (This   : Language_Pack_Upgrader;
                     Update : String     := ""; -- false
                     Args   : Array_Type := Empty_Array)
                     return Array_Type;

   --
   -- Bulk upgrade language packs.
   --
   -- @since 3.7.0
   --
   -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
   --
   -- @param object[] language_updates Optional. Array of language packs to update.
   --                                   @see wp_get_translation_updates().
   --                                   Default empty array.
   -- @param array    args {
   --     Other arguments for upgrading multiple language packs. Default empty array.
   --
   --     @type bool clear_update_cache Whether to clear the update cache when done.
   --                                    Default true.
   -- }
   -- @return array|bool|WP_Error Will return an array of results, or true if there
   --                             are no updates, false or WP_Error for initial errors.
   --
   function Bulk_Upgrade (This             : Language_Pack_Upgrader;
                          Language_Updates : Array_Type;
                          Args             : Array_Type)
                          return Array_Type;
        --         global wp_filesystem;

        --         defaults    = array(
        --                 "clear_update_cache" => true,
        --         );
        --         parsed_args = wp_parse_args( args, defaults );

        --         this.init();
        --         this.upgrade_strings();

        --         if ( ! language_updates ) then
        --                 language_updates = wp_get_translation_updates();
        --         end;

        --         if ( empty( language_updates ) ) then
        --                 this.skin.header();
        --                 this.skin.set_result( true );
        --                 this.skin.feedback( "up_to_date" );
        --                 this.skin.bulk_footer();
        --                 this.skin.footer();
        --                 return true;
        --         end;

        --         if ( "upgrader_process_complete" === current_filter() ) then
        --                 this.skin.feedback( "starting_upgrade" );
        --         end;

        --         // Remove any existing upgrade filters from the plugin/theme upgraders #WP29425 & #WP29230.
        --         remove_all_filters( "upgrader_pre_install" );
        --         remove_all_filters( "upgrader_clear_destination" );
        --         remove_all_filters( "upgrader_post_install" );
        --         remove_all_filters( "upgrader_source_selection" );

        --         add_filter( "upgrader_source_selection", array( this, "check_package" ), 10, 2 );

        --         this.skin.header();

        --         // Connect to the filesystem first.
        --         res = this.fs_connect( array( WP_CONTENT_DIR, WP_LANG_DIR ) );
        --         if ( ! res ) then
        --                 this.skin.footer();
        --                 return false;
        --         end;

        --         results = array();

        --         this.update_count   = count( language_updates );
        --         this.update_current = 0;

        --         /*
        --         -- The filesystem"s mkdir() is not recursive. Make sure WP_LANG_DIR exists,
        --         -- as we then may need to create a /plugins or /themes directory inside of it.
        --         --
        --         remote_destination = wp_filesystem.find_folder( WP_LANG_DIR );
        --         if ( ! wp_filesystem.exists( remote_destination ) ) then
        --                 if ( ! wp_filesystem.mkdir( remote_destination, FS_CHMOD_DIR ) ) then
        --                         return new WP_Error( "mkdir_failed_lang_dir", this.strings["mkdir_failed"], remote_destination );
        --                 end;
        --         end;

        --         language_updates_results = array();

        --         foreach ( language_updates as language_update ) then

        --                 this.skin.language_update = language_update;

        --                 destination = WP_LANG_DIR;
        --                 if ( "plugin" === language_update.type ) then
        --                         destination .= "/plugins";
        --                 end; elseif ( "theme" === language_update.type ) then
        --                         destination .= "/themes";
        --                 end;

        --                 this.update_current++;

        --                 options = array(
        --                         "package"                     => language_update.package,
        --                         "destination"                 => destination,
        --                         "clear_destination"           => true,
        --                         "abort_if_destination_exists" => false, // We expect the destination to exist.
        --                         "clear_working"               => true,
        --                         "is_multi"                    => true,
        --                         "hook_extra"                  => array(
        --                                 "language_update_type" => language_update.type,
        --                                 "language_update"      => language_update,
        --                         ),
        --                 );

        --                 result = this.run( options );

        --                 results[] = this.result;

        --                 // Prevent credentials auth screen from displaying multiple times.
        --                 if ( false === result ) then
        --                         break;
        --                 end;

        --                 language_updates_results[] = array(
        --                         "language" => language_update.language,
        --                         "type"     => language_update.type,
        --                         "slug"     => isset( language_update.slug ) ? language_update.slug : "default",
        --                         "version"  => language_update.version,
        --                 );
        --         end;

        --         // Remove upgrade hooks which are not required for translation updates.
        --         remove_action( "upgrader_process_complete", array( "Language_Pack_Upgrader", "async_upgrade" ), 20 );
        --         remove_action( "upgrader_process_complete", "wp_version_check" );
        --         remove_action( "upgrader_process_complete", "wp_update_plugins" );
        --         remove_action( "upgrader_process_complete", "wp_update_themes" );

        --         -- This action is documented in wp-admin/includes/class-wp-upgrader.php--
        --         do_action(
        --                 "upgrader_process_complete",
        --                 this,
        --                 array(
        --                         "action"       => "update",
        --                         "type"         => "translation",
        --                         "bulk"         => true,
        --                         "translations" => language_updates_results,
        --                 )
        --         );

        --         // Re-add upgrade hooks.
        --         add_action( "upgrader_process_complete", array( "Language_Pack_Upgrader", "async_upgrade" ), 20 );
        --         add_action( "upgrader_process_complete", "wp_version_check", 10, 0 );
        --         add_action( "upgrader_process_complete", "wp_update_plugins", 10, 0 );
        --         add_action( "upgrader_process_complete", "wp_update_themes", 10, 0 );

        --         this.skin.bulk_footer();

        --         this.skin.footer();

        --         // Clean up our hooks, in case something else does an upgrade on this connection.
        --         remove_filter( "upgrader_source_selection", array( this, "check_package" ) );

        --         if ( parsed_args["clear_update_cache"] ) then
        --                 wp_clean_update_cache();
        --         end;

        --         return results;
        -- end;

        -- --
        -- -- Checks that the package source contains .mo and .po files.
        -- --
        -- -- Hooked to the then@see "upgrader_source_selection"end; filter by
        -- -- Language_Pack_Upgrader::bulk_upgrade().
        -- --
        -- -- @since 3.7.0
        -- --
        -- -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
        -- --
        -- -- @param string|WP_Error source        The path to the downloaded package source.
        -- -- @param string          remote_source Remote file source location.
        -- -- @return string|WP_Error The source as passed, or a WP_Error object on failure.
        -- --
        -- public function check_package( source, remote_source ) then
        --         global wp_filesystem;

        --         if ( is_wp_error( source ) ) then
        --                 return source;
        --         end;

        --         // Check that the folder contains a valid language.
        --         files = wp_filesystem.dirlist( remote_source );

        --         // Check to see if a .po and .mo exist in the folder.
        --         po = false;
        --         mo = false;
        --         foreach ( (array) files as file => filedata ) then
        --                 if ( ".po" === substr( file, -3 ) ) then
        --                         po = true;
        --                 end; elseif ( ".mo" === substr( file, -3 ) ) then
        --                         mo = true;
        --                 end;
        --         end;

        --         if ( ! mo || ! po ) then
        --                 return new WP_Error(
        --                         "incompatible_archive_pomo",
        --                         this.strings["incompatible_archive"],
        --                         sprintf(
        --                                 /* translators: 1: .po, 2: .mo--
        --                                 __( "The language pack is missing either the %1s or %2s files." ),
        --                                 "<code>.po</code>",
        --                                 "<code>.mo</code>"
        --                         )
        --                 );
        --         end;

        --         return source;
        -- end;

        -- --
        -- -- Get the name of an item being updated.
        -- --
        -- -- @since 3.7.0
        -- --
        -- -- @param object update The data for an update.
        -- -- @return string The name of the item being updated.
        -- --
        -- public function get_name_for_update( update ) then
        --         switch ( update.type ) then
        --                 case "core":
        --                         return "WordPress"; // Not translated.

        --                 case "theme":
        --                         theme = wp_get_theme( update.slug );
        --                         if ( theme.exists() ) then
        --                                 return theme.Get( "Name" );
        --                         end;
        --                         break;
        --                 case "plugin":
        --                         plugin_data = get_plugins( "/" . update.slug );
        --                         plugin_data = reset( plugin_data );
        --                         if ( plugin_data ) then
        --                                 return plugin_data["Name"];
        --                         end;
        --                         break;
        --         end;
        --         return "";
        -- end;

        -- --
        -- -- Clears existing translations where this item is going to be installed into.
        -- --
        -- -- @since 5.1.0
        -- --
        -- -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
        -- --
        -- -- @param string remote_destination The location on the remote filesystem to be cleared.
        -- -- @return bool|WP_Error True upon success, WP_Error on failure.
        -- --
        -- public function clear_destination( remote_destination ) then
        --         global wp_filesystem;

        --         language_update    = this.skin.language_update;
        --         language_directory = WP_LANG_DIR . "/"; // Local path for use with glob().

        --         if ( "core" === language_update.type ) then
        --                 files = array(
        --                         remote_destination . language_update.language . ".po",
        --                         remote_destination . language_update.language . ".mo",
        --                         remote_destination . "admin-" . language_update.language . ".po",
        --                         remote_destination . "admin-" . language_update.language . ".mo",
        --                         remote_destination . "admin-network-" . language_update.language . ".po",
        --                         remote_destination . "admin-network-" . language_update.language . ".mo",
        --                         remote_destination . "continents-cities-" . language_update.language . ".po",
        --                         remote_destination . "continents-cities-" . language_update.language . ".mo",
        --                 );

        --                 json_translation_files = glob( language_directory . language_update.language . "-*.json" );
        --                 if ( json_translation_files ) then
        --                         foreach ( json_translation_files as json_translation_file ) then
        --                                 files[] = str_replace( language_directory, remote_destination, json_translation_file );
        --                         end;
        --                 end;
        --         end; else then
        --                 files = array(
        --                         remote_destination . language_update.slug . "-" . language_update.language . ".po",
        --                         remote_destination . language_update.slug . "-" . language_update.language . ".mo",
        --                 );

        --                 language_directory     = language_directory . language_update.type . "s/";
        --                 json_translation_files = glob( language_directory . language_update.slug . "-" . language_update.language . "-*.json" );
        --                 if ( json_translation_files ) then
        --                         foreach ( json_translation_files as json_translation_file ) then
        --                                 files[] = str_replace( language_directory, remote_destination, json_translation_file );
        --                         end;
        --                 end;
        --         end;

        --         files = array_filter( files, array( wp_filesystem, "exists" ) );

        --         // No files to delete.
        --         if ( ! files ) then
        --                 return true;
        --         end;

        --         // Check all files are writable before attempting to clear the destination.
        --         unwritable_files = array();

        --         // Check writability.
        --         foreach ( files as file ) then
        --                 if ( ! wp_filesystem.is_writable( file ) ) then
        --                         // Attempt to alter permissions to allow writes and try again.
        --                         wp_filesystem.chmod( file, FS_CHMOD_FILE );
        --                         if ( ! wp_filesystem.is_writable( file ) ) then
        --                                 unwritable_files[] = file;
        --                         end;
        --                 end;
        --         end;

        --         if ( ! empty( unwritable_files ) ) then
        --                 return new WP_Error( "files_not_writable", this.strings["files_not_writable"], implode( ", ", unwritable_files ) );
        --         end;

        --         foreach ( files as file ) then
        --                 if ( ! wp_filesystem.delete( file ) ) then
        --                         return new WP_Error( "remove_old_failed", this.strings["remove_old_failed"] );
        --                 end;
        --         end;

        --         return true;
        -- end;

end Adi_Class_Language_Pack_Upgraders;
