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

package Wp_Config
is
   --
   -- Database settings - You can get this info from your web host
   --

   -- The name of the database for WordPress
   DB_NAME : constant String := "wordpress";

   -- Database username
   DB_USER : constant String := "wordpress";

   -- Database password
   DB_PASSWORD : constant String := "YourStrongPasswordHere";

   -- Database hostname
   DB_HOST : constant String := "localhost";

   -- Database charset to use in creating database tables.
   DB_CHARSET : constant String := "utf8";

   -- The database collate type. Don't change this if in doubt.
   DB_COLLATE : constant String := "";

   --#@+
   -- Authentication unique keys and salts.
   --
   -- Change these to different unique phrases! You can generate these using
   -- the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
   --
   -- You can change these at any point in time to invalidate all existing cookies.
   -- This will force all users to have to log in again.
   --
   -- @since 2.6.0
   --
   AUTH_KEY         : constant String := "put your unique phrase here";
   SECURE_AUTH_KEY  : constant String := "put your unique phrase here";
   LOGGED_IN_KEY    : constant String := "put your unique phrase here";
   NONCE_KEY        : constant String := "put your unique phrase here";
   AUTH_SALT        : constant String := "put your unique phrase here";
   SECURE_AUTH_SALT : constant String := "put your unique phrase here";
   LOGGED_IN_SALT   : constant String := "put your unique phrase here";
   NONCE_SALT       : constant String := "put your unique phrase here";
   --#@-

   --
   -- WordPress database table prefix.
   --
   -- You can have multiple installations in one database if you give each
   -- a unique prefix. Only numbers, letters, and underscores please!
   --
   Table_Prefix : constant String := "wp_";

   --
   -- For developers: WordPress debugging mode.
   --
   -- Change this to true to enable the display of notices during development.
   -- It is strongly recommended that plugin and theme developers use WP_DEBUG
   -- in their development environments.
   --
   -- For information on other constants that can be used for debugging,
   -- visit the documentation.
   --
   -- @link https://wordpress.org/support/article/debugging-in-wordpress/
   --
   WP_DEBUG : constant Boolean := False;

   -- Add any custom values between this line and the "stop editing" line.

   --
   -- That's all, stop editing! Happy publishing.
   --

-- -- Absolute path to the WordPress directory.
-- if ( ! defined( 'ABSPATH' ) ) then
--         define( 'ABSPATH', __DIR__ . '/' );
-- end if;

-- -- Sets up WordPress vars and included files.
-- require_once ABSPATH . 'wp-settings.php';
   procedure Run;

end Wp_Config;
