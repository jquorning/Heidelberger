--
-- Network API
--
-- @package WordPress
-- @subpackage Multisite
-- @since 5.1.0
--

with Inc_Class_Wp_Networks;

package Inc_Ms_Networks
is
   use Inc_Class_Wp_Networks;

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
-- @param WP_Network|int|null network Optional. Network to retrieve. Default is the current network.
-- @return WP_Network|null The network object or null if not found.
--
   function Get_Network (Network : Wp_Network := Null_Network) --  := null)
                         return Wp_Network
                         is (Null_Network);

end Inc_Ms_Networks;
