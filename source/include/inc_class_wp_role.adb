--
-- User API: WP_Role class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Hb_Common;

package body Inc_Class_Wp_Role
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Role         : String;
                         Capabilities : Array_Type)
                         return Wp_Role
   is
      use Hb_Common;

      This : Wp_Role;
   begin
      This.Name         := +Role;
      This.Capabilities := Capabilities;
      return This;
   end X_Construct;

end Inc_Class_Wp_Role;
