--
-- User API: WP_Role class
--
-- @package WordPress
-- @subpackage Users
-- @since 4.4.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Arrays;

package Class_Role
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- Core class used to extend the user roles API.
   --
   -- @since 2.0.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Role is tagged
      record
         --
         -- Role name.
         --
         -- @since 2.0.0
         -- @var string
         --
         Name : Unbounded_String;

         --
         -- List of capabilities the role contains.
         --
         -- @since 2.0.0
         -- @var bool[] Array of key/value pairs where keys represent a capability
         --             name and boolean values represent whether the role has that
         --             capability.
         --
         Capabilities : Array_Type; -- Boolean_Maps.Map;

      end record;

   --
   -- Constructor - Set up object properties.
   --
   -- The list of capabilities must have the key as the name of the capability
   -- and the value a boolean of whether it is granted to the role.
   --
   -- @since 2.0.0
   --
   -- @param string role         Role name.
   -- @param bool[] capabilities Array of key/value pairs where keys represent a
   --                             capability name and boolean values represent whether
   --                             the role has that capability.
   --
   function X_Construct (Role         : String;
                         Capabilities : Array_Type)
                         return Wp_Role;

   --
   -- Assign role a capability.
   --
   -- @since 2.0.0
   --
   -- @param string cap   Capability name.
   -- @param bool   grant Whether role has capability privilege.
   --
   procedure Add_Cap (This  : in out Wp_Role;
                      Cap   : String;
                      Grant : Boolean := True);

   --
   -- Removes a capability from a role.
   --
   -- @since 2.0.0
   --
   -- @param string cap Capability name.
   --
   procedure Remove_Cap (This : in out Wp_Role;
                         Cap  : String);

   --
   -- Determines whether the role has the given capability.
   --
   -- @since 2.0.0
   --
   -- @param string cap Capability name.
   -- @return bool Whether the role has the given capability.
   --
   function Has_Cap (This : Wp_Role;
                     Cap  : String)
                     return Boolean;

   package Role_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Class_Role.Wp_Role,
         "="          => Class_Role."=");

   Null_Role : constant Wp_Role :=
     (Name         => Null_Unbounded_String,
      Capabilities => Empty_Array);

end Class_Role;
