--
-- Defines constants and global variables that can be overridden, generally in
-- wp-config.php.
--
-- @package WordPress
--

with Ada.Strings.Unbounded;

package Inc_Default_Constants
is
   use Ada.Strings.Unbounded;

   --
   -- Defines initial WordPress constants.
   --
   -- @see wp_debug_mode()
   --
   -- @since 3.0.0
   --
   -- @global int    $blog_id    The current site ID.
   -- @global string $wp_version The WordPress version string.
   --
   procedure Wp_Initial_Constants;

   --
   -- Defines plugin directory WordPress constants.
   --
   -- Defines must-use plugin directory constants, which may be overridden in the
   -- sunrise.php drop-in.
   --
   -- @since 3.0.0
   --
   procedure Wp_Plugin_Directory_Constants;

   COOKIEHASH           : Unbounded_String := To_Unbounded_String ("undefined");
   USER_COOKIE          : Unbounded_String;
   PASS_COOKIE          : Unbounded_String;
   AUTH_COOKIE          : Unbounded_String;
   SECURE_AUTH_COOKIE   : Unbounded_String;
   LOGGED_IN_COOKIE     : Unbounded_String;
   TEST_COOKIE          : Unbounded_String;
   COOKIEPATH           : Unbounded_String;
   SITECOOKIEPATH       : Unbounded_String;
   ADMIN_COOKIE_PATH    : Unbounded_String;
   PLUGINS_COOKIE_PATH  : Unbounded_String;
   COOKIE_DOMAIN        : Boolean;
   RECOVERY_MODE_COOKIE : Unbounded_String;

   --
   -- Defines cookie-related WordPress constants.
   --
   -- Defines constants after multisite is loaded.
   --
   -- @since 3.0.0
   --
   procedure Wp_Cookie_Constants;

   --
   -- Defines functionality-related WordPress constants.
   --
   -- @since 3.0.0
   --
   procedure Wp_Functionality_Constants;

   --
   -- Defines templating-related WordPress constants.
   --
   -- @since 3.0.0
   --
   procedure Wp_Templating_Constants;

end Inc_Default_Constants;
