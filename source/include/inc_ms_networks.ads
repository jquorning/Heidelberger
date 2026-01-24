--
-- Network API
--
-- @package WordPress
-- @subpackage Multisite
-- @since 5.1.0
--

with Ada.Containers.Vectors;

with Arrays;

with Class_Networks;

package Inc_Ms_Networks
is
   use Class_Networks;

   package Network_Lists
     is new Ada.Containers.Vectors (Index_Type   => Positive,
                                    Element_Type => Wp_Network);
   subtype Network_List is Network_Lists.Vector;

   procedure Dummy;

   --
   -- Retrieves network data given a network ID or network object.
   --
   -- Network data will be cached and returned after being passed through a filter.
   -- If the provided network is empty, the current network global will be used.
   --
   -- @since 4.6.0
   --
   -- @global WP_Network current_site
   --
   -- @param WP_Network|int|null network Optional. Network to retrieve. Default is
   --                                     the current network.
   -- @return WP_Network|null The network object or null if not found.
   --
   function Get_Network (Network : Wp_Network := Null_Network) --  := null)
                         return Wp_Network
                         is (Null_Network);

   function Get_Network (Network : Integer) --  := null)
                         return Wp_Network
                         is (Null_Network);

   --
   -- Retrieves a list of networks.
   --
   -- @since 4.6.0
   --
   -- @param string|array args Optional. Array or string of arguments. See
   --                           WP_Network_Query::parse_query() for information on
   --                           accepted arguments. Default empty array.
   --
   -- @return array|int List of WP_Network objects, a list of network IDs when
   --                   "fields" is set to "ids", or the number of networks when
   --                   "count" is passed as a query var.
   --
   function Get_Networks (Args : Arrays.Array_Type := Arrays.Empty_Array)
                          return Network_List
                          is (raise Program_Error with "not implemented");

end Inc_Ms_Networks;
