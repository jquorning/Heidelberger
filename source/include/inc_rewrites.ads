--
-- WordPress Rewrite API
--
-- @package WordPress
-- @subpackage Rewrite
--

with Arrays;

package Inc_Rewrites
is
   use Arrays;

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

   --
   -- Adds a new rewrite tag (like %postname%).
   --
   -- The `query` parameter is optional. If it is omitted you must ensure that you call
   -- this on, or before, the {@see "init"} hook. This is because `query` defaults to
   -- `tag=`, and for this to work a new query var has to be added.
   --
   -- @since 2.1.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   -- @global WP         wp         Current WordPress environment instance.
   --
   -- @param string tag   Name of the new rewrite tag.
   -- @param string regex Regular expression to substitute the tag for in rewrite
   --                      rules.
   -- @param string query Optional. String to append to the rewritten query. Must
   --                      end in "=". Default empty.
   --
   procedure Add_Rewrite_Tag (Tag   : String;
                              Regex : String;
                              Query : String := "")
                              is null;

   --
   -- Adds a permalink structure.
   --
   -- @since 3.0.0
   --
   -- @see WP_Rewrite::add_permastruct()
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @param string name   Name for permalink structure.
   -- @param string struct Permalink structure.
   -- @param array  args   Optional. Arguments for building the rules from the
   --                       permalink structure, see WP_Rewrite::add_permastruct()
   --                       for full details. Default empty array.
   --
   procedure Add_Permastruct (Name   : String;
                              Struct : String;
                              Args   : Array_Type := Empty_Array)
                              is null;

end Inc_Rewrites;
