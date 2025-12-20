--
-- Upgrade API: WP_Upgrader class
--
-- Requires skin classes and WP_Upgrader subclasses for backward compatibility.
--
-- @package WordPress
-- @subpackage Upgrader
-- @since 2.8.0
--

with Inc_L10n;

package body Adi_Class_Wp_Upgraders
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Skin : Adi_Class_Wp_Upgrader_Skins.Wp_Upgrader_Skin)
                         return Wp_Upgrader
   is
      This : Wp_Upgrader;
   begin
--      if ( null === skin ) then
--         this.skin = new WP_Upgrader_Skin();
--      else
         This.Skin := Skin;
--      end if;
      return This;
   end X_Construct;

   ----------
   -- Init --
   ----------

   procedure Init (This : in out Wp_Upgrader)
   is
   begin
      This.Skin.Set_Upgrader (This'Access);
      This.Generic_Strings;
   end Init;

   ---------------------
   -- Generic_Strings --
   ---------------------

   procedure Generic_Strings (This : in out Wp_Upgrader)
   is
      use Inc_L10n;

      procedure S (Key   : String;
                   Value : String);

      procedure S (Key   : String;
                   Value : String)
      is
      begin
         Set (This.Strings, Key, From_String (Value));
      end S;

   begin
      S ("bad_request",    abs "Invalid data provided.");
      S ("fs_unavailable", abs "Could not access filesystem.");
      S ("fs_error",       abs "Filesystem error.");
      S ("fs_no_root_dir", abs "Unable to locate WordPress root directory.");
      S ("fs_no_content_dir", abs "Unable to locate WordPress content directory (wp-content).");
      S ("fs_no_plugins_dir", abs "Unable to locate WordPress plugin directory.");
      S ("fs_no_themes_dir",  abs "Unable to locate WordPress theme directory.");
      -- translators: %s: Directory name.
      S ("fs_no_folder", abs "Unable to locate needed folder (%s).");

      S ("download_failed",      abs "Download failed.");
      S ("installing_package",   abs "Installing the latest version&#8230;");
      S ("no_files",             abs "The package contains no files.");
      S ("folder_exists",        abs "Destination folder already exists.");
      S ("mkdir_failed",         abs "Could not create directory.");
      S ("incompatible_archive", abs "The package could not be installed.");
      S ("files_not_writable",   abs "The update cannot be installed because some files could not be copied. This is usually due to inconsistent file permissions.");

      S ("maintenance_start", abs "Enabling Maintenance mode&#8230;");
      S ("maintenance_end",   abs "Disabling Maintenance mode&#8230;");
   end Generic_Strings;

   ----------------
   -- FS_Connect --
   ----------------

   function FS_Connect (This                         : Wp_Upgrader;
                        Directories                  : List_Type; -- = array(),
                        Allow_Relaxed_File_Ownership : Boolean := False)
                        return Boolean
   is (raise Program_Error with "not implemented");

end Adi_Class_Wp_Upgraders;
