--
-- Upgrade WordPress Page.
--
-- @package WordPress
-- @subpackage Administration
--

package Adm_Upgrade
is

   --
   -- @global string wp_version             The WordPress version string.
   -- @global string required_php_version   The required PHP version string.
   -- @global string required_mysql_version The required MySQL version string.
   -- @global wpdb   wpdb                   WordPress database abstraction object.
   --
   procedure Render;

end Adm_Upgrade;
