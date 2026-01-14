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

package Inc_Class_Wp_Role
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

        -- --
        -- -- Removes a capability from a role.
        -- --
        -- -- @since 2.0.0
        -- --
        -- -- @param string cap Capability name.
        -- --
        -- public function remove_cap( cap ) then
        --         unset( this->capabilities[ cap ] );
        --         wp_roles()->remove_cap( this->name, cap );
        -- end;

        -- --
        -- -- Determines whether the role has the given capability.
        -- --
        -- -- @since 2.0.0
        -- --
        -- -- @param string cap Capability name.
        -- -- @return bool Whether the role has the given capability.
        -- --
        -- public function has_cap( cap ) then
        --         --
        --         -- Filters which capabilities a role has.
        --         --
        --         -- @since 2.0.0
        --         --
        --         -- @param bool[] capabilities Array of key/value pairs where keys represent a capability name and boolean values
        --         --                             represent whether the role has that capability.
        --         -- @param string cap          Capability name.
        --         -- @param string name         Role name.
        --         --
        --         capabilities = apply_filters( "role_has_cap", this->capabilities, cap, this->name );

        --         if ( ! empty( capabilities[ cap ] ) ) then
        --                 return capabilities[ cap ];
        --         end; else then
        --                 return false;
        --         end;
        -- end;

   package Role_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Inc_Class_Wp_Role.Wp_Role,
         "="          => Inc_Class_Wp_Role."=");

   Null_Role : constant Wp_Role :=
     (Name         => Null_Unbounded_String,
      Capabilities => Empty_Array);

end Inc_Class_Wp_Role;
