--
-- WordPress Version
--
-- Contains version information for the current WordPress release.
--
-- @package WordPress
-- @since 1.2.0
--
package Inc_Versions
is
   --
   -- The WordPress version string.
   --
   -- Holds the current version number for WordPress core. Used to bust caches
   -- and to enable development mode for scripts when running from the /src directory.
   --
   -- @global string wp_version
   --
   Wp_Version : constant String := "6.1.6";

   --
   -- Holds the WordPress DB revision, increments when changes are made to the
   -- WordPress DB schema.
   --
   -- @global int wp_db_version
   --
   Wp_DB_Version : constant := 53496;

   --
   -- Holds the TinyMCE version.
   --
   -- @global string tinymce_version
   --
   Tinymce_Version : constant String := "49110-20201110";

   --
   -- Holds the required PHP version.
   --
   -- @global string required_php_version
   --
   Required_PHP_Version : constant String := "5.6.20";

   --
   -- Holds the required MySQL version.
   --
   -- @global string required_mysql_version
   --
   Required_MySQL_Version : constant String := "5.0";

end Inc_Versions;
