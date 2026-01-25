--
-- Network API: WP_Network class
--
-- @package WordPress
-- @subpackage Multisite
-- @since 4.4.0
--

with UStrings;

package Class_Networks
is

   procedure Dummy;

   --
   -- Core class used for interacting with a multisite network.
   --
   -- This class is used during load to populate the `$current_site` global and
   -- setup the current network.
   --
   -- This class is most useful in WordPress multi-network installations where the
   -- ability to interact with any network of sites is required.
   --
   -- @since 4.4.0
   --
   type Prop_Type is record
      Id      : Integer;
      Site_Id : Integer;
   end record;

   -- @property int $id
   -- @property int $site_id
   --
   --#[AllowDynamicProperties]
   type Wp_Network is
     record
        --
        -- Network ID.
        --
        -- @since 4.4.0
        -- @since 4.6.0 Converted from public to private to explicitly enable more
        --              intuitive access via magic methods. As part of the access
        --              change, the type was also changed from `string` to `int`.
        -- @var int
        --
--        private
        Id : Integer;

        --
        -- Domain of the network.
        --
        -- @since 4.4.0
        -- @var string
        --
        Domain : UStrings.UString;

        --
        -- Path of the network.
        --
        -- @since 4.4.0
        -- @var string
        --
        Path : UStrings.UString;

        --
        -- The ID of the network's main site.
        --
        -- Named "blog" vs. "site" for legacy reasons. A main site is mapped to
        -- the network when the network is created.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 4.4.0
        -- @var string
        --
--        private
        Blog_Id : UStrings.UString :=
          UStrings.To_UString ("0");

        --
        -- Domain used to set cookies for this network.
        --
        -- @since 4.4.0
        -- @var string
        --
        Cookie_Domain : UStrings.UString;

        --
        -- Name of this network.
        --
        -- Named "site" vs. "network" for legacy reasons.
        --
        -- @since 4.4.0
        -- @var string
        --
        Site_Name : UStrings.UString;

        Prop : Prop_Type;
   end record;

   Null_Network : constant Wp_Network :=
     (Id     => 0,
      Prop   => (others => 0),
      others => UStrings.Null_UString);

end Class_Networks;
