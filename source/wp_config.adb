--
-- The base configuration for WordPress
--
-- The wp-config.php creation script uses this file during the installation.
-- You don't have to use the web site, you can copy this file to "wp-config.php"
-- and fill in the values.
--
-- This file contains the following configurations:
--
-- * Database settings
-- * Secret keys
-- * Database table prefix
-- * ABSPATH
--
-- @link https://wordpress.org/support/article/editing-wp-config-php/
--
-- @package WordPress
--

with Wp_Settings;

package body Wp_Config
is

-- -- That's all, stop editing! Happy publishing.

-- -- Absolute path to the WordPress directory.
-- if ( ! defined( 'ABSPATH' ) ) then
--         define( 'ABSPATH', __DIR__ . '/' );
-- end if;

-- -- Sets up WordPress vars and included files.
-- require_once ABSPATH . 'wp-settings.php';

   ---------
   -- Run --
   ---------

   procedure Run
   is
   begin
      Wp_Settings.Run;
   end Run;

end Wp_Config;
