--
-- WordPress Rewrite API
--
-- @package WordPress
-- @subpackage Rewrite
--
package Inc_Rewrites
is
   procedure Dummy;

--
-- Removes rewrite rules and then recreate rewrite rules.
--
-- @since 3.0.0
--
-- @global WP_Rewrite wp_rewrite WordPress rewrite component.
--
-- @param bool hard Whether to update .htaccess (hard flush) or just update
--                   rewrite_rules option (soft flush). Default is true (hard).
--
   procedure Flush_Rewrite_Rules (Hard : Boolean := True) is null;

end Inc_Rewrites;
