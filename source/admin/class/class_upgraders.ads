--
-- Upgrade API: WP_Upgrader class
--
-- Requires skin classes and WP_Upgrader subclasses for backward compatibility.
--
-- @package WordPress
-- @subpackage Upgrader
-- @since 2.8.0
--

with Arrays;
with Lists;

with Adi_Class_Wp_Upgrader_Skins;

package Class_Upgraders
is
   use Arrays;
   use Lists;

-- WP_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-wp-upgrader-skin.php";

-- Plugin_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-plugin-upgrader-skin.php";

-- Theme_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-theme-upgrader-skin.php";

-- Bulk_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-bulk-upgrader-skin.php";

-- Bulk_Plugin_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-bulk-plugin-upgrader-skin.php";

-- Bulk_Theme_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-bulk-theme-upgrader-skin.php";

-- Plugin_Installer_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-plugin-installer-skin.php";

-- Theme_Installer_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-theme-installer-skin.php";

-- Language_Pack_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-language-pack-upgrader-skin.php";

-- Automatic_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-automatic-upgrader-skin.php";

-- WP_Ajax_Upgrader_Skin class--
-- require_once ABSPATH . "wp-admin/includes/class-wp-ajax-upgrader-skin.php";

   --
   -- Core class used for upgrading/installing a local set of files via
   -- the Filesystem Abstraction classes from a Zip file.
   --
   -- @since 2.8.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Upgrader is tagged
      record
         --
         -- The error/notification strings used to update the user on the progress.
         --
         -- @since 2.8.0
         -- @var array strings
         --
         Strings : Array_Type;

         --
         -- The upgrader skin being used.
         --
         -- @since 2.8.0
         -- @var Automatic_Upgrader_Skin|WP_Upgrader_Skin skin
         --
         Skin : Adi_Class_Wp_Upgrader_Skins.Wp_Upgrader_Skin; --  = null;

         --
         -- The result of the installation.
         --
         -- This is set by WP_Upgrader::install_package(), only when the package is
         -- installed successfully. It will then be an array, unless a WP_Error is
         -- returned by the {@see "upgrader_post_install"} filter. In that case, the
         -- WP_Error will be assigned to it.
         --
         -- @since 2.8.0
         --
         -- @var array|WP_Error result {
         --     @type string source             The full path to the source the files
         --                                      were installed from.
         --     @type string source_files       List of all the files in the source
         --                                      directory.
         --     @type string destination        The full path to the installation
         --                                      destination folder.
         --     @type string destination_name   The name of the destination folder,
         --                                      or empty if `destination` and
         --                                      `local_destination` are the same.
         --     @type string local_destination  The full local path to the destination
         --                                      folder. This is usually the same as
         --                                      `destination`.
         --     @type string remote_destination The full remote path to the
         --                                      destination folder
         --                                      (i.e., from `wp_filesystem`).
         --     @type bool   clear_destination  Whether the destination folder was
         --                                      cleared.
         -- }
         --
         Result : Array_Type;

         --
         -- The total number of updates being performed.
         --
         -- Set by the bulk update methods.
         --
         -- @since 3.0.0
         -- @var int update_count
         --
         Update_Count : Integer := 0;

         --
         -- The current update if multiple updates are being performed.
         --
         -- Used by the bulk update methods, and incremented for each update.
         --
         -- @since 3.0.0
         -- @var int
         --
         Update_Current : Integer := 0;

      end record;

   --
   -- Construct the upgrader with a skin.
   --
   -- @since 2.8.0
   --
   -- @param WP_Upgrader_Skin skin The upgrader skin to use. Default is a
   --                               WP_Upgrader_Skin instance.
   --
   function X_Construct (Skin : Adi_Class_Wp_Upgrader_Skins.Wp_Upgrader_Skin) -- null
                         return Wp_Upgrader;

   --
   -- Initialize the upgrader.
   --
   -- This will set the relationship between the skin being used and this upgrader,
   -- and also add the generic strings to `WP_Upgrader::strings`.
   --
   -- @since 2.8.0
   --
   procedure Init (This : in out Wp_Upgrader);

   --
   -- Add the generic strings to WP_Upgrader::strings.
   --
   -- @since 2.8.0
   --
   procedure Generic_Strings (This : in out Wp_Upgrader);

   --
   -- Connect to the filesystem.
   --
   -- @since 2.8.0
   --
   -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
   --
   -- @param string[] directories                  Optional. Array of directories. If
   --                                               any of these do not exist, a
   --                                               WP_Error object will be returned.
   --                                               Default empty array.
   -- @param bool     allow_relaxed_file_ownership Whether to allow relaxed file
   --                                               ownership. Default false.
   -- @return bool|WP_Error True if able to connect, false or a WP_Error otherwise.
   --
   function FS_Connect (This                         : Wp_Upgrader;
                        Directories                  : List_Type; -- = array(),
                        Allow_Relaxed_File_Ownership : Boolean := False)
                        return Boolean;
        --         global wp_filesystem;

        --         credentials = this.skin.request_filesystem_credentials( false, directories[0], allow_relaxed_file_ownership );
        --         if ( false === credentials ) then
        --                 return false;
        --         end;

        --         if ( ! WP_Filesystem( credentials, directories[0], allow_relaxed_file_ownership ) ) then
        --                 error = true;
        --                 if ( is_object( wp_filesystem ) && wp_filesystem.errors.has_errors() ) then
        --                         error = wp_filesystem.errors;
        --                 end;
        --                 -- Failed to connect. Error and request again.
        --                 this.skin.request_filesystem_credentials( error, directories[0], allow_relaxed_file_ownership );
        --                 return false;
        --         end;

        --         if ( ! is_object( wp_filesystem ) ) then
        --                 return new WP_Error( "fs_unavailable", this.strings["fs_unavailable"] );
        --         end;

        --         if ( is_wp_error( wp_filesystem.errors ) && wp_filesystem.errors.has_errors() ) then
        --                 return new WP_Error( "fs_error", this.strings["fs_error"], wp_filesystem.errors );
        --         end;

        --         foreach ( (array) directories as dir ) then
        --                 switch ( dir ) then
        --                         case ABSPATH:
        --                                 if ( ! wp_filesystem.abspath() ) then
        --                                         return new WP_Error( "fs_no_root_dir", this.strings["fs_no_root_dir"] );
        --                                 end;
        --                                 break;
        --                         case WP_CONTENT_DIR:
        --                                 if ( ! wp_filesystem.wp_content_dir() ) then
        --                                         return new WP_Error( "fs_no_content_dir", this.strings["fs_no_content_dir"] );
        --                                 end;
        --                                 break;
        --                         case WP_PLUGIN_DIR:
        --                                 if ( ! wp_filesystem.wp_plugins_dir() ) then
        --                                         return new WP_Error( "fs_no_plugins_dir", this.strings["fs_no_plugins_dir"] );
        --                                 end;
        --                                 break;
        --                         case get_theme_root():
        --                                 if ( ! wp_filesystem.wp_themes_dir() ) then
        --                                         return new WP_Error( "fs_no_themes_dir", this.strings["fs_no_themes_dir"] );
        --                                 end;
        --                                 break;
        --                         default:
        --                                 if ( ! wp_filesystem.find_folder( dir ) ) then
        --                                         return new WP_Error( "fs_no_folder", sprintf( this.strings["fs_no_folder"], esc_html( basename( dir ) ) ) );
        --                                 end;
        --                                 break;
        --                 end;
        --         end;
        --         return true;
        -- end;

        -- --
        -- -- Download a package.
        -- --
        -- -- @since 2.8.0
        -- -- @since 5.2.0 Added the `check_signatures` parameter.
        -- -- @since 5.5.0 Added the `hook_extra` parameter.
        -- --
        -- -- @param string package          The URI of the package. If this is the full path to an
        -- --                                 existing local file, it will be returned untouched.
        -- -- @param bool   check_signatures Whether to validate file signatures. Default false.
        -- -- @param array  hook_extra       Extra arguments to pass to the filter hooks. Default empty array.
        -- -- @return string|WP_Error The full path to the downloaded package file, or a WP_Error object.
        -- --
        -- public function download_package( package, check_signatures = false, hook_extra = array() ) then
        --         --
        --         -- Filters whether to return the package.
        --         --
        --         -- @since 3.7.0
        --         -- @since 5.5.0 Added the `hook_extra` parameter.
        --         --
        --         -- @param bool        reply      Whether to bail without returning the package.
        --         --                                Default false.
        --         -- @param string      package    The package file name.
        --         -- @param WP_Upgrader upgrader   The WP_Upgrader instance.
        --         -- @param array       hook_extra Extra arguments passed to hooked filters.
        --         --
        --         reply = apply_filters( "upgrader_pre_download", false, package, this, hook_extra );
        --         if ( false !== reply ) then
        --                 return reply;
        --         end;

        --         if ( ! preg_match( "!^(http|https|ftp)://!i", package ) && file_exists( package ) ) then -- Local file or remote?
        --                 return package; -- Must be a local file.
        --         end;

        --         if ( empty( package ) ) then
        --                 return new WP_Error( "no_package", this.strings["no_package"] );
        --         end;

        --         this.skin.feedback( "downloading_package", package );

        --         download_file = download_url( package, 300, check_signatures );

        --         if ( is_wp_error( download_file ) && ! download_file.get_error_data( "softfail-filename" ) ) then
        --                 return new WP_Error( "download_failed", this.strings["download_failed"], download_file.get_error_message() );
        --         end;

        --         return download_file;
        -- end;

        -- --
        -- -- Unpack a compressed package file.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
        -- --
        -- -- @param string package        Full path to the package file.
        -- -- @param bool   delete_package Optional. Whether to delete the package file after attempting
        -- --                               to unpack it. Default true.
        -- -- @return string|WP_Error The path to the unpacked contents, or a WP_Error on failure.
        -- --
        -- public function unpack_package( package, delete_package = true ) then
        --         global wp_filesystem;

        --         this.skin.feedback( "unpack_package" );

        --         upgrade_folder = wp_filesystem.wp_content_dir() . "upgrade/";

        --         -- Clean up contents of upgrade directory beforehand.
        --         upgrade_files = wp_filesystem.dirlist( upgrade_folder );
        --         if ( ! empty( upgrade_files ) ) then
        --                 foreach ( upgrade_files as file ) then
        --                         wp_filesystem.delete( upgrade_folder . file["name"], true );
        --                 end;
        --         end;

        --         -- We need a working directory - strip off any .tmp or .zip suffixes.
        --         working_dir = upgrade_folder . basename( basename( package, ".tmp" ), ".zip" );

        --         -- Clean up working directory.
        --         if ( wp_filesystem.is_dir( working_dir ) ) then
        --                 wp_filesystem.delete( working_dir, true );
        --         end;

        --         -- Unzip package to working directory.
        --         result = unzip_file( package, working_dir );

        --         -- Once extracted, delete the package if required.
        --         if ( delete_package ) then
        --                 unlink( package );
        --         end;

        --         if ( is_wp_error( result ) ) then
        --                 wp_filesystem.delete( working_dir, true );
        --                 if ( "incompatible_archive" === result.get_error_code() ) then
        --                         return new WP_Error( "incompatible_archive", this.strings["incompatible_archive"], result.get_error_data() );
        --                 end;
        --                 return result;
        --         end;

        --         return working_dir;
        -- end;

        -- --
        -- -- Flatten the results of WP_Filesystem_Base::dirlist() for iterating over.
        -- --
        -- -- @since 4.9.0
        -- -- @access protected
        -- --
        -- -- @param array  nested_files Array of files as returned by WP_Filesystem_Base::dirlist().
        -- -- @param string path         Relative path to prepend to child nodes. Optional.
        -- -- @return array A flattened array of the nested_files specified.
        -- --
        -- protected function flatten_dirlist( nested_files, path = "" ) then
        --         files = array();

        --         foreach ( nested_files as name => details ) then
        --                 files[ path . name ] = details;

        --                 -- Append children recursively.
        --                 if ( ! empty( details["files"] ) ) then
        --                         children = this.flatten_dirlist( details["files"], path . name . "/" );

        --                         -- Merge keeping possible numeric keys, which array_merge() will reindex from 0..n.
        --                         files = files + children;
        --                 end;
        --         end;

        --         return files;
        -- end;

        -- --
        -- -- Clears the directory where this item is going to be installed into.
        -- --
        -- -- @since 4.3.0
        -- --
        -- -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
        -- --
        -- -- @param string remote_destination The location on the remote filesystem to be cleared.
        -- -- @return true|WP_Error True upon success, WP_Error on failure.
        -- --
        -- public function clear_destination( remote_destination ) then
        --         global wp_filesystem;

        --         files = wp_filesystem.dirlist( remote_destination, true, true );

        --         -- False indicates that the remote_destination doesn"t exist.
        --         if ( false === files ) then
        --                 return true;
        --         end;

        --         -- Flatten the file list to iterate over.
        --         files = this.flatten_dirlist( files );

        --         -- Check all files are writable before attempting to clear the destination.
        --         unwritable_files = array();

        --         -- Check writability.
        --         foreach ( files as filename => file_details ) then
        --                 if ( ! wp_filesystem.is_writable( remote_destination . filename ) ) then
        --                         -- Attempt to alter permissions to allow writes and try again.
        --                         wp_filesystem.chmod( remote_destination . filename, ( "d" === file_details["type"] ? FS_CHMOD_DIR : FS_CHMOD_FILE ) );
        --                         if ( ! wp_filesystem.is_writable( remote_destination . filename ) ) then
        --                                 unwritable_files[] = filename;
        --                         end;
        --                 end;
        --         end;

        --         if ( ! empty( unwritable_files ) ) then
        --                 return new WP_Error( "files_not_writable", this.strings["files_not_writable"], implode( ", ", unwritable_files ) );
        --         end;

        --         if ( ! wp_filesystem.delete( remote_destination, true ) ) then
        --                 return new WP_Error( "remove_old_failed", this.strings["remove_old_failed"] );
        --         end;

        --         return true;
        -- end;

        -- --
        -- -- Install a package.
        -- --
        -- -- Copies the contents of a package from a source directory, and installs them in
        -- -- a destination directory. Optionally removes the source. It can also optionally
        -- -- clear out the destination folder if it already exists.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @global WP_Filesystem_Base wp_filesystem        WordPress filesystem subclass.
        -- -- @global array              wp_theme_directories
        -- --
        -- -- @param array|string args then
        -- --     Optional. Array or string of arguments for installing a package. Default empty array.
        -- --
        -- --     @type string source                      Required path to the package source. Default empty.
        -- --     @type string destination                 Required path to a folder to install the package in.
        -- --                                               Default empty.
        -- --     @type bool   clear_destination           Whether to delete any files already in the destination
        -- --                                               folder. Default false.
        -- --     @type bool   clear_working               Whether to delete the files from the working directory
        -- --                                               after copying them to the destination. Default false.
        -- --     @type bool   abort_if_destination_exists Whether to abort the installation if
        -- --                                               the destination folder already exists. Default true.
        -- --     @type array  hook_extra                  Extra arguments to pass to the filter hooks called by
        -- --                                               WP_Upgrader::install_package(). Default empty array.
        -- -- end;
        -- --
        -- -- @return array|WP_Error The result (also stored in `WP_Upgrader::result`), or a WP_Error on failure.
        -- --
        -- public function install_package( args = array() ) then
        --         global wp_filesystem, wp_theme_directories;

        --         defaults = array(
        --                 "source"                      => "", -- Please always pass this.
        --                 "destination"                 => "", -- ...and this.
        --                 "clear_destination"           => false,
        --                 "clear_working"               => false,
        --                 "abort_if_destination_exists" => true,
        --                 "hook_extra"                  => array(),
        --         );

        --         args = wp_parse_args( args, defaults );

        --         -- These were previously extract()"d.
        --         source            = args["source"];
        --         destination       = args["destination"];
        --         clear_destination = args["clear_destination"];

        --         set_time_limit( 300 );

        --         if ( empty( source ) || empty( destination ) ) then
        --                 return new WP_Error( "bad_request", this.strings["bad_request"] );
        --         end;
        --         this.skin.feedback( "installing_package" );

        --         --
        --         -- Filters the installation response before the installation has started.
        --         --
        --         -- Returning a value that could be evaluated as a `WP_Error` will effectively
        --         -- short-circuit the installation, returning that value instead.
        --         --
        --         -- @since 2.8.0
        --         --
        --         -- @param bool|WP_Error response   Installation response.
        --         -- @param array         hook_extra Extra arguments passed to hooked filters.
        --         --
        --         res = apply_filters( "upgrader_pre_install", true, args["hook_extra"] );

        --         if ( is_wp_error( res ) ) then
        --                 return res;
        --         end;

        --         -- Retain the original source and destinations.
        --         remote_source     = args["source"];
        --         local_destination = destination;

        --         source_files       = array_keys( wp_filesystem.dirlist( remote_source ) );
        --         remote_destination = wp_filesystem.find_folder( local_destination );

        --         -- Locate which directory to copy to the new folder. This is based on the actual folder holding the files.
        --         if ( 1 === count( source_files ) && wp_filesystem.is_dir( trailingslashit( args["source"] ) . source_files[0] . "/" ) ) then
        --                 -- Only one folder? Then we want its contents.
        --                 source = trailingslashit( args["source"] ) . trailingslashit( source_files[0] );
        --         end; elseif ( 0 === count( source_files ) ) then
        --                 -- There are no files?
        --                 return new WP_Error( "incompatible_archive_empty", this.strings["incompatible_archive"], this.strings["no_files"] );
        --         end; else then
        --                 -- It"s only a single file, the upgrader will use the folder name of this file as the destination folder.
        --                 -- Folder name is based on zip filename.
        --                 source = trailingslashit( args["source"] );
        --         end;

        --         --
        --         -- Filters the source file location for the upgrade package.
        --         --
        --         -- @since 2.8.0
        --         -- @since 4.4.0 The hook_extra parameter became available.
        --         --
        --         -- @param string      source        File source location.
        --         -- @param string      remote_source Remote file source location.
        --         -- @param WP_Upgrader upgrader      WP_Upgrader instance.
        --         -- @param array       hook_extra    Extra arguments passed to hooked filters.
        --         --
        --         source = apply_filters( "upgrader_source_selection", source, remote_source, this, args["hook_extra"] );

        --         if ( is_wp_error( source ) ) then
        --                 return source;
        --         end;

        --         -- Has the source location changed? If so, we need a new source_files list.
        --         if ( source !== remote_source ) then
        --                 source_files = array_keys( wp_filesystem.dirlist( source ) );
        --         end;

        --         /*
        --         -- Protection against deleting files in any important base directories.
        --         -- Theme_Upgrader & Plugin_Upgrader also trigger this, as they pass the
        --         -- destination directory (WP_PLUGIN_DIR / wp-content/themes) intending
        --         -- to copy the directory into the directory, whilst they pass the source
        --         -- as the actual files to copy.
        --         --
        --         protected_directories = array( ABSPATH, WP_CONTENT_DIR, WP_PLUGIN_DIR, WP_CONTENT_DIR . "/themes" );

        --         if ( is_array( wp_theme_directories ) ) then
        --                 protected_directories = array_merge( protected_directories, wp_theme_directories );
        --         end;

        --         if ( in_array( destination, protected_directories, true ) ) then
        --                 remote_destination = trailingslashit( remote_destination ) . trailingslashit( basename( source ) );
        --                 destination        = trailingslashit( destination ) . trailingslashit( basename( source ) );
        --         end;

        --         if ( clear_destination ) then
        --                 -- We"re going to clear the destination if there"s something there.
        --                 this.skin.feedback( "remove_old" );

        --                 removed = this.clear_destination( remote_destination );

        --                 --
        --                 -- Filters whether the upgrader cleared the destination.
        --                 --
        --                 -- @since 2.8.0
        --                 --
        --                 -- @param true|WP_Error removed            Whether the destination was cleared.
        --                 --                                          True upon success, WP_Error on failure.
        --                 -- @param string        local_destination  The local package destination.
        --                 -- @param string        remote_destination The remote package destination.
        --                 -- @param array         hook_extra         Extra arguments passed to hooked filters.
        --                 --
        --                 removed = apply_filters( "upgrader_clear_destination", removed, local_destination, remote_destination, args["hook_extra"] );

        --                 if ( is_wp_error( removed ) ) then
        --                         return removed;
        --                 end;
        --         end; elseif ( args["abort_if_destination_exists"] && wp_filesystem.exists( remote_destination ) ) then
        --                 -- If we"re not clearing the destination folder and something exists there already, bail.
        --                 -- But first check to see if there are actually any files in the folder.
        --                 _files = wp_filesystem.dirlist( remote_destination );
        --                 if ( ! empty( _files ) ) then
        --                         wp_filesystem.delete( remote_source, true ); -- Clear out the source files.
        --                         return new WP_Error( "folder_exists", this.strings["folder_exists"], remote_destination );
        --                 end;
        --         end;

        --         -- Create destination if needed.
        --         if ( ! wp_filesystem.exists( remote_destination ) ) then
        --                 if ( ! wp_filesystem.mkdir( remote_destination, FS_CHMOD_DIR ) ) then
        --                         return new WP_Error( "mkdir_failed_destination", this.strings["mkdir_failed"], remote_destination );
        --                 end;
        --         end;

        --         -- Copy new version of item into place.
        --         result = copy_dir( source, remote_destination );
        --         if ( is_wp_error( result ) ) then
        --                 if ( args["clear_working"] ) then
        --                         wp_filesystem.delete( remote_source, true );
        --                 end;
        --                 return result;
        --         end;

        --         -- Clear the working folder?
        --         if ( args["clear_working"] ) then
        --                 wp_filesystem.delete( remote_source, true );
        --         end;

        --         destination_name = basename( str_replace( local_destination, "", destination ) );
        --         if ( "." === destination_name ) then
        --                 destination_name = "";
        --         end;

        --         this.result = compact( "source", "source_files", "destination", "destination_name", "local_destination", "remote_destination", "clear_destination" );

        --         --
        --         -- Filters the installation response after the installation has finished.
        --         --
        --         -- @since 2.8.0
        --         --
        --         -- @param bool  response   Installation response.
        --         -- @param array hook_extra Extra arguments passed to hooked filters.
        --         -- @param array result     Installation result data.
        --         --
        --         res = apply_filters( "upgrader_post_install", true, args["hook_extra"], this.result );

        --         if ( is_wp_error( res ) ) then
        --                 this.result = res;
        --                 return res;
        --         end;

        --         -- Bombard the calling function will all the info which we"ve just used.
        --         return this.result;
        -- end;

        -- --
        -- -- Run an upgrade/installation.
        -- --
        -- -- Attempts to download the package (if it is not a local file), unpack it, and
        -- -- install it in the destination folder.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @param array options then
        -- --     Array or string of arguments for upgrading/installing a package.
        -- --
        -- --     @type string package                     The full path or URI of the package to install.
        -- --                                               Default empty.
        -- --     @type string destination                 The full path to the destination folder.
        -- --                                               Default empty.
        -- --     @type bool   clear_destination           Whether to delete any files already in the
        -- --                                               destination folder. Default false.
        -- --     @type bool   clear_working               Whether to delete the files from the working
        -- --                                               directory after copying them to the destination.
        -- --                                               Default true.
        -- --     @type bool   abort_if_destination_exists Whether to abort the installation if the destination
        -- --                                               folder already exists. When true, `clear_destination`
        -- --                                               should be false. Default true.
        -- --     @type bool   is_multi                    Whether this run is one of multiple upgrade/installation
        -- --                                               actions being performed in bulk. When true, the skin
        -- --                                               WP_Upgrader::header() and WP_Upgrader::footer()
        -- --                                               aren"t called. Default false.
        -- --     @type array  hook_extra                  Extra arguments to pass to the filter hooks called by
        -- --                                               WP_Upgrader::run().
        -- -- end;
        -- -- @return array|false|WP_Error The result from self::install_package() on success, otherwise a WP_Error,
        -- --                              or false if unable to connect to the filesystem.
        -- --
        -- public function run( options ) then

        --         defaults = array(
        --                 "package"                     => "", -- Please always pass this.
        --                 "destination"                 => "", -- ...and this.
        --                 "clear_destination"           => false,
        --                 "clear_working"               => true,
        --                 "abort_if_destination_exists" => true, -- Abort if the destination directory exists. Pass clear_destination as false please.
        --                 "is_multi"                    => false,
        --                 "hook_extra"                  => array(), -- Pass any extra hook_extra args here, this will be passed to any hooked filters.
        --         );

        --         options = wp_parse_args( options, defaults );

        --         --
        --         -- Filters the package options before running an update.
        --         --
        --         -- See also then@see "upgrader_process_complete"end;.
        --         --
        --         -- @since 4.3.0
        --         --
        --         -- @param array options then
        --         --     Options used by the upgrader.
        --         --
        --         --     @type string package                     Package for update.
        --         --     @type string destination                 Update location.
        --         --     @type bool   clear_destination           Clear the destination resource.
        --         --     @type bool   clear_working               Clear the working resource.
        --         --     @type bool   abort_if_destination_exists Abort if the Destination directory exists.
        --         --     @type bool   is_multi                    Whether the upgrader is running multiple times.
        --         --     @type array  hook_extra then
        --         --         Extra hook arguments.
        --         --
        --         --         @type string action               Type of action. Default "update".
        --         --         @type string type                 Type of update process. Accepts "plugin", "theme", or "core".
        --         --         @type bool   bulk                 Whether the update process is a bulk update. Default true.
        --         --         @type string plugin               Path to the plugin file relative to the plugins directory.
        --         --         @type string theme                The stylesheet or template name of the theme.
        --         --         @type string language_update_type The language pack update type. Accepts "plugin", "theme",
        --         --                                            or "core".
        --         --         @type object language_update      The language pack update offer.
        --         --     end;
        --         -- end;
        --         --
        --         options = apply_filters( "upgrader_package_options", options );

        --         if ( ! options["is_multi"] ) then -- Call this.header separately if running multiple times.
        --                 this.skin.header();
        --         end;

        --         -- Connect to the filesystem first.
        --         res = this.fs_connect( array( WP_CONTENT_DIR, options["destination"] ) );
        --         -- Mainly for non-connected filesystem.
        --         if ( ! res ) then
        --                 if ( ! options["is_multi"] ) then
        --                         this.skin.footer();
        --                 end;
        --                 return false;
        --         end;

        --         this.skin.before();

        --         if ( is_wp_error( res ) ) then
        --                 this.skin.error( res );
        --                 this.skin.after();
        --                 if ( ! options["is_multi"] ) then
        --                         this.skin.footer();
        --                 end;
        --                 return res;
        --         end;

        --         /*
        --         -- Download the package. Note: If the package is the full path
        --         -- to an existing local file, it will be returned untouched.
        --         --
        --         download = this.download_package( options["package"], true, options["hook_extra"] );

        --         -- Allow for signature soft-fail.
        --         -- WARNING: This may be removed in the future.
        --         if ( is_wp_error( download ) && download.get_error_data( "softfail-filename" ) ) then

        --                 -- Don"t output the "no signature could be found" failure message for now.
        --                 if ( "signature_verification_no_signature" !== download.get_error_code() || WP_DEBUG ) then
        --                         -- Output the failure error as a normal feedback, and not as an error.
        --                         this.skin.feedback( download.get_error_message() );

        --                         -- Report this failure back to WordPress.org for debugging purposes.
        --                         wp_version_check(
        --                                 array(
        --                                         "signature_failure_code" => download.get_error_code(),
        --                                         "signature_failure_data" => download.get_error_data(),
        --                                 )
        --                         );
        --                 end;

        --                 -- Pretend this error didn"t happen.
        --                 download = download.get_error_data( "softfail-filename" );
        --         end;

        --         if ( is_wp_error( download ) ) then
        --                 this.skin.error( download );
        --                 this.skin.after();
        --                 if ( ! options["is_multi"] ) then
        --                         this.skin.footer();
        --                 end;
        --                 return download;
        --         end;

        --         delete_package = ( download !== options["package"] ); -- Do not delete a "local" file.

        --         -- Unzips the file into a temporary directory.
        --         working_dir = this.unpack_package( download, delete_package );
        --         if ( is_wp_error( working_dir ) ) then
        --                 this.skin.error( working_dir );
        --                 this.skin.after();
        --                 if ( ! options["is_multi"] ) then
        --                         this.skin.footer();
        --                 end;
        --                 return working_dir;
        --         end;

        --         -- With the given options, this installs it to the destination directory.
        --         result = this.install_package(
        --                 array(
        --                         "source"                      => working_dir,
        --                         "destination"                 => options["destination"],
        --                         "clear_destination"           => options["clear_destination"],
        --                         "abort_if_destination_exists" => options["abort_if_destination_exists"],
        --                         "clear_working"               => options["clear_working"],
        --                         "hook_extra"                  => options["hook_extra"],
        --                 )
        --         );

        --         --
        --         -- Filters the result of WP_Upgrader::install_package().
        --         --
        --         -- @since 5.7.0
        --         --
        --         -- @param array|WP_Error result     Result from WP_Upgrader::install_package().
        --         -- @param array          hook_extra Extra arguments passed to hooked filters.
        --         --
        --         result = apply_filters( "upgrader_install_package_result", result, options["hook_extra"] );

        --         this.skin.set_result( result );
        --         if ( is_wp_error( result ) ) then
        --                 this.skin.error( result );

        --                 if ( ! method_exists( this.skin, "hide_process_failed" ) || ! this.skin.hide_process_failed( result ) ) then
        --                         this.skin.feedback( "process_failed" );
        --                 end;
        --         end; else then
        --                 -- Installation succeeded.
        --                 this.skin.feedback( "process_success" );
        --         end;

        --         this.skin.after();

        --         if ( ! options["is_multi"] ) then

        --                 --
        --                 -- Fires when the upgrader process is complete.
        --                 --
        --                 -- See also then@see "upgrader_package_options"end;.
        --                 --
        --                 -- @since 3.6.0
        --                 -- @since 3.7.0 Added to WP_Upgrader::run().
        --                 -- @since 4.6.0 `translations` was added as a possible argument to `hook_extra`.
        --                 --
        --                 -- @param WP_Upgrader upgrader   WP_Upgrader instance. In other contexts this might be a
        --                 --                                Theme_Upgrader, Plugin_Upgrader, Core_Upgrade, or Language_Pack_Upgrader instance.
        --                 -- @param array       hook_extra then
        --                 --     Array of bulk item update data.
        --                 --
        --                 --     @type string action       Type of action. Default "update".
        --                 --     @type string type         Type of update process. Accepts "plugin", "theme", "translation", or "core".
        --                 --     @type bool   bulk         Whether the update process is a bulk update. Default true.
        --                 --     @type array  plugins      Array of the basename paths of the plugins" main files.
        --                 --     @type array  themes       The theme slugs.
        --                 --     @type array  translations then
        --                 --         Array of translations update data.
        --                 --
        --                 --         @type string language The locale the translation is for.
        --                 --         @type string type     Type of translation. Accepts "plugin", "theme", or "core".
        --                 --         @type string slug     Text domain the translation is for. The slug of a theme/plugin or
        --                 --                                "default" for core translations.
        --                 --         @type string version  The version of a theme, plugin, or core.
        --                 --     end;
        --                 -- end;
        --                 --
        --                 do_action( "upgrader_process_complete", this, options["hook_extra"] );

        --                 this.skin.footer();
        --         end;

        --         return result;
        -- end;

        -- --
        -- -- Toggle maintenance mode for the site.
        -- --
        -- -- Creates/deletes the maintenance file to enable/disable maintenance mode.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @global WP_Filesystem_Base wp_filesystem WordPress filesystem subclass.
        -- --
        -- -- @param bool enable True to enable maintenance mode, false to disable.
        -- --
        -- public function maintenance_mode( enable = false ) then
        --         global wp_filesystem;
        --         file = wp_filesystem.abspath() . ".maintenance";
        --         if ( enable ) then
        --                 this.skin.feedback( "maintenance_start" );
        --                 -- Create maintenance file to signal that we are upgrading.
        --                 maintenance_string = "<?php upgrading = " . time() . "; ?>";
        --                 wp_filesystem.delete( file );
        --                 wp_filesystem.put_contents( file, maintenance_string, FS_CHMOD_FILE );
        --         end; elseif ( ! enable && wp_filesystem.exists( file ) ) then
        --                 this.skin.feedback( "maintenance_end" );
        --                 wp_filesystem.delete( file );
        --         end;
        -- end;

        -- --
        -- -- Creates a lock using WordPress options.
        -- --
        -- -- @since 4.5.0
        -- --
        -- -- @param string lock_name       The name of this unique lock.
        -- -- @param int    release_timeout Optional. The duration in seconds to respect an existing lock.
        -- --                                Default: 1 hour.
        -- -- @return bool False if a lock couldn"t be created or if the lock is still valid. True otherwise.
        -- --
        -- public static function create_lock( lock_name, release_timeout = null ) then
        --         global wpdb;
        --         if ( ! release_timeout ) then
        --                 release_timeout = HOUR_IN_SECONDS;
        --         end;
        --         lock_option = lock_name . ".lock";

        --         -- Try to lock.
        --         lock_result = wpdb.query( wpdb.prepare( "INSERT IGNORE INTO `wpdb.options` ( `option_name`, `option_value`, `autoload` ) VALUES (%s, %s, "no") /* LOCK--", lock_option, time() ) );

        --         if ( ! lock_result ) then
        --                 lock_result = get_option( lock_option );

        --                 -- If a lock couldn"t be created, and there isn"t a lock, bail.
        --                 if ( ! lock_result ) then
        --                         return false;
        --                 end;

        --                 -- Check to see if the lock is still valid. If it is, bail.
        --                 if ( lock_result > ( time() - release_timeout ) ) then
        --                         return false;
        --                 end;

        --                 -- There must exist an expired lock, clear it and re-gain it.
        --                 WP_Upgrader::release_lock( lock_name );

        --                 return WP_Upgrader::create_lock( lock_name, release_timeout );
        --         end;

        --         -- Update the lock, as by this point we've definitely got a lock, just need to fire the actions.
        --         update_option( lock_option, time() );

        --         return true;
        -- end;

        -- --
        -- -- Releases an upgrader lock.
        -- --
        -- -- @since 4.5.0
        -- --
        -- -- @see WP_Upgrader::create_lock()
        -- --
        -- -- @param string lock_name The name of this unique lock.
        -- -- @return bool True if the lock was successfully released. False on failure.
        -- --
        -- public static function release_lock( lock_name ) then
        --         return delete_option( lock_name . ".lock" );
        -- end;

end Class_Upgraders;

-- Plugin_Upgrader class--
-- require_once ABSPATH . "wp-admin/includes/class-plugin-upgrader.php";

-- Theme_Upgrader class--
-- require_once ABSPATH . "wp-admin/includes/class-theme-upgrader.php";

-- Language_Pack_Upgrader class--
-- require_once ABSPATH . "wp-admin/includes/class-language-pack-upgrader.php";

-- Core_Upgrader class--
-- require_once ABSPATH . "wp-admin/includes/class-core-upgrader.php";

-- File_Upload_Upgrader class--
-- require_once ABSPATH . "wp-admin/includes/class-file-upload-upgrader.php";

-- WP_Automatic_Updater class--
-- require_once ABSPATH . "wp-admin/includes/class-wp-automatic-updater.php";
