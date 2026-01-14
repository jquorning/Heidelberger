--
-- User API: WP_Role class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Hb_Common;

with Inc_Capabilities;
with Inc_Class_Wp_Roles;
with Inc_Roles;

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

   -------------
   -- Add_Cap --
   -------------

   procedure Add_Cap (This  : in out Wp_Role;
                      Cap   : String;
                      Grant : Boolean := True)
   is
      use Hb_Common;
      use Inc_Capabilities;
      use Inc_Class_Wp_Roles;
      use Inc_Roles;
   begin
      Set (This.Capabilities, Cap, From_Boolean (Grant));
      Global_Wp_Roles.Add_Cap (-This.Name, Cap, Grant);
   end Add_Cap;

end Inc_Class_Wp_Role;
