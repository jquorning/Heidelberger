--
-- Network API
--
-- @package WordPress
-- @subpackage Multisite
-- @since 5.1.0
--

package body Inc_Ms_Networks
is
   procedure Dummy is null;
-- --
-- -- Retrieves network data given a network ID or network object.
-- --
-- -- Network data will be cached and returned after being passed through a filter.
-- -- If the provided network is empty, the current network global will be used.
-- --
-- -- @since 4.6.0
-- --
-- -- @global WP_Network current_site
-- --
-- -- @param WP_Network|int|null network Optional. Network to retrieve. Default is the current network.
-- -- @return WP_Network|null The network object or null if not found.
-- --
-- function get_network( network = null ) then
--         global current_site;
--         if ( empty( network ) && isset( current_site ) ) then
--                 network = current_site;
--         end;

--         if ( network instanceof WP_Network ) then
--                 _network = network;
--         end; elseif ( is_object( network ) ) then
--                 _network = new WP_Network( network );
--         end; else then
--                 _network = WP_Network::get_instance( network );
--         end;

--         if ( ! _network ) then
--                 return null;
--         end;

--         --
--         -- Fires after a network is retrieved.
--         --
--         -- @since 4.6.0
--         --
--         -- @param WP_Network _network Network data.
--         --
--         _network = apply_filters( "get_network", _network );

--         return _network;
-- end;

-- --
-- -- Retrieves a list of networks.
-- --
-- -- @since 4.6.0
-- --
-- -- @param string|array args Optional. Array or string of arguments. See WP_Network_Query::parse_query()
-- --                           for information on accepted arguments. Default empty array.
-- -- @return array|int List of WP_Network objects, a list of network IDs when "fields" is set to "ids",
-- --                   or the number of networks when "count" is passed as a query var.
-- --
-- function get_networks( args = array() ) then
--         query = new WP_Network_Query();

--         return query->query( args );
-- end;

-- --
-- -- Removes a network from the object cache.
-- --
-- -- @since 4.6.0
-- --
-- -- @global bool _wp_suspend_cache_invalidation
-- --
-- -- @param int|array ids Network ID or an array of network IDs to remove from cache.
-- --
-- function clean_network_cache( ids ) then
--         global _wp_suspend_cache_invalidation;

--         if ( ! empty( _wp_suspend_cache_invalidation ) ) then
--                 return;
--         end;

--         network_ids = (array) ids;
--         wp_cache_delete_multiple( network_ids, "networks" );

--         foreach ( network_ids as id ) then
--                 --
--                 -- Fires immediately after a network has been removed from the object cache.
--                 --
--                 -- @since 4.6.0
--                 --
--                 -- @param int id Network ID.
--                 --
--                 do_action( "clean_network_cache", id );
--         end;

--         wp_cache_set( "last_changed", microtime(), "networks" );
-- end;

-- --
-- -- Updates the network cache of given networks.
-- --
-- -- Will add the networks in networks to the cache. If network ID already exists
-- -- in the network cache then it will not be updated. The network is added to the
-- -- cache using the network group with the key using the ID of the networks.
-- --
-- -- @since 4.6.0
-- --
-- -- @param array networks Array of network row objects.
-- --
-- function update_network_cache( networks ) then
--         data = array();
--         foreach ( (array) networks as network ) then
--                 data[ network->id ] = network;
--         end;
--         wp_cache_add_multiple( data, "networks" );
-- end;

-- --
-- -- Adds any networks from the given IDs to the cache that do not already exist in cache.
-- --
-- -- @since 4.6.0
-- -- @since 6.1.0 This function is no longer marked as "private".
-- --
-- -- @see update_network_cache()
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param array network_ids Array of network IDs.
-- --
-- function _prime_network_caches( network_ids ) then
--         global wpdb;

--         non_cached_ids = _get_non_cached_ids( network_ids, "networks" );
--         if ( ! empty( non_cached_ids ) ) then
--                 fresh_networks = wpdb->get_results( sprintf( "SELECT wpdb->site.* FROM wpdb->site WHERE id IN (%s)", implode( ",", array_map( "intval", non_cached_ids ) ) ) ); // phpcs:ignore WordPress.DB.PreparedSQL.NotPrepared

--                 update_network_cache( fresh_networks );
--         end;
-- end;

end Inc_Ms_Networks;
