--
-- User API: WP_Role class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with UStrings;

with Class_Roles;
with Inc_Plugins;
with Inc_Roles;

package body Class_Role
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Role         : String;
                         Capabilities : Array_Type)
                         return Wp_Role
   is
      use UStrings;

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
      use UStrings;
      use Class_Roles;
      use Inc_Roles;
   begin
      Set (This.Capabilities, Cap, From_Boolean (Grant));
      Global_Wp_Roles.Add_Cap (-This.Name, Cap, Grant);
   end Add_Cap;

   ----------------
   -- Remove_Cap --
   ----------------

   procedure Remove_Cap (This : in out Wp_Role;
                         Cap  : String)
   is
      use UStrings;
      use Inc_Roles;
   begin
      Delete (Ref (This.Capabilities, Cap));
      Global_Wp_Roles.Remove_Cap (-This.Name, Cap);
   end Remove_Cap;

   -------------
   -- Has_Cap --
   -------------

   function Has_Cap (This : Wp_Role;
                     Cap  : String)
                     return Boolean
   is
      use UStrings;
      use Inc_Plugins;

      --
      -- Filters which capabilities a role has.
      --
      -- @since 2.0.0
      --
      -- @param bool[] capabilities Array of key/value pairs where keys represent a
      --                            capability name and boolean values represent
      --                            whether the role has that capability.
      -- @param string cap          Capability name.
      -- @param string name         Role name.
      --
      Capabilities : constant Array_Type :=
        Apply_Filters ("role_has_cap", This.Capabilities, Cap, -This.Name);
   begin
      if not Empty (Capabilities, Cap) then
         return As_Boolean (Get (Capabilities, Cap));
      else
         return False;
      end if;
   end Has_Cap;

end Class_Role;
