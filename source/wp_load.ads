--
-- Bootstrap file for setting the ABSPATH constant
-- and loading the wp-config.php file. The wp-config.php
-- file will then load the wp-settings.php file, which
-- will then set up the WordPress environment.
--
-- If the wp-config.php file is not found then an error
-- will be displayed asking the visitor to set up the
-- wp-config.php file.
--
-- Will also search for wp-config.php in WordPress" parent
-- directory to allow the WordPress directory to remain
-- untouched.
--
-- @package WordPress
--

package Wp_Load
is
   procedure Run;

end Wp_Load;
