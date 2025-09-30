--
-- Defines constants and global variables that can be overridden, generally in
-- wp-config.php.
--
-- @package WordPress
--

package Inc_Default_Constants
is
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
