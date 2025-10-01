--
-- Noop functions for load-scripts.php and load-styles.php.
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Php;

package body Adi_Noop
is

   -- --
   -- -- @ignore
   -- --
   -- function __() {}

   -- --
   -- -- @ignore
   -- --
   -- function _x() {}

   -- --
   -- -- @ignore
   -- --
   -- function add_filter() {}

   -- --
   -- -- @ignore
   -- --
   -- function esc_attr() {}

   -- --
   -- -- @ignore
   -- --
   -- function apply_filters() {}

   -- --
   -- -- @ignore
   -- --
   -- function get_option() {}

   -- --
   -- -- @ignore
   -- --
   -- function is_lighttpd_before_150() {}

   -- --
   -- -- @ignore
   -- --
   -- function add_action() {}

   -- --
   -- -- @ignore
   -- --
   -- function did_action() {}

   -- --
   -- -- @ignore
   -- --
   -- function do_action_ref_array() {}

   -- --
   -- -- @ignore
   -- --
   -- function get_bloginfo() {}

   -- --
   -- -- @ignore
   -- --
   -- function Is_Admin
   --          return Boolean
   --          is (True);

   -- --
   -- -- @ignore
   -- --
   -- function site_url() {}

   -- --
   -- -- @ignore
   -- --
   -- function admin_url() {}

   -- --
   -- -- @ignore
   -- --
   -- function home_url() {}

   -- --
   -- -- @ignore
   -- --
   -- function includes_url() {}

   -- --
   -- -- @ignore
   -- --
   -- function wp_guess_url() {}

   function Get_File (Path : String)
            return String
   is
      use Php;

      Path_2 : constant String := Realpath (Path);
   begin
      if Path_2 = "" or else not Is_File (Path_2) then -- @
         return "";
      end if;

      return File_Get_Contents (Path); -- @
   end Get_File;

end Adi_Noop;
