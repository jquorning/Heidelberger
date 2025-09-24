
--
-- Object Cache API
--
-- @link https://developer.wordpress.org/reference/classes/wp_object_cache/
--
-- @package WordPress
-- @subpackage Cache
--

package body Adi_Caches
is


-- WP_Object_Cache class
-- require_once ABSPATH . WPINC . '/class-wp-object-cache.php';

--
-- Sets up Object Cache Global and assigns it.
--
-- @since 2.0.0
--
-- @global WP_Object_Cache $wp_object_cache
--

-- function Wp_Cache_Init
-- is
-- begin
--         null;
-- --        $GLOBALS['wp_object_cache'] = new WP_Object_Cache();
-- end Wp_Cache_Init;

------------------
-- wp_cache_add --
------------------

   procedure Wp_Cache_Add (Key    : String;
                           Data   : Inc_Class_Wp_Posts.Wp_Post;  --- String;
                           Group  : String  := "";
                           Expire : Integer := 0)
   is
--        global $wp_object_cache;
   begin
      null;

--        return $wp_object_cache->add( $key, $data, $group, (int) $expire );
   end Wp_Cache_Add;

--
-- Adds multiple values to the cache in one call.
--
-- @since 6.0.0
--
-- @see WP_Object_Cache::add_multiple()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param array  $data   Array of keys and values to be set.
-- @param string $group  Optional. Where the cache contents are grouped. Default empty.
-- @param int    $expire Optional. When to expire the cache contents, in seconds.
--                       Default 0 (no expiration).
-- @return bool[] Array of return values, grouped by key. Each value is either
--                true on success, or false if cache key and group already exist.
--

-- function wp_cache_add_multiple( array $data, $group = '', $expire = 0 ) then
--         global $wp_object_cache;

--         return $wp_object_cache->add_multiple( $data, $group, $expire );
-- end;

--
-- Replaces the contents of the cache with new data.
--
-- @since 2.0.0
--
-- @see WP_Object_Cache::replace()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param int|string $key    The key for the cache data that should be replaced.
-- @param mixed      $data   The new data to store in the cache.
-- @param string     $group  Optional. The group for the cache data that should be replaced.
--                           Default empty.
-- @param int        $expire Optional. When to expire the cache contents, in seconds.
--                           Default 0 (no expiration).
-- @return bool True if contents were replaced, false if original value does not exist.
--

-- function wp_cache_replace( $key, $data, $group = '', $expire = 0 ) then
--         global $wp_object_cache;

--         return $wp_object_cache->replace( $key, $data, $group, (int) $expire );
-- end;

--
-- Saves the data to the cache.
--
-- Differs from wp_cache_add() and wp_cache_replace() in that it will always write data.
--
-- @since 2.0.0
--
-- @see WP_Object_Cache::set()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param int|string $key    The cache key to use for retrieval later.
-- @param mixed      $data   The contents to store in the cache.
-- @param string     $group  Optional. Where to group the cache contents. Enables the same key
--                           to be used across groups. Default empty.
-- @param int        $expire Optional. When to expire the cache contents, in seconds.
--                           Default 0 (no expiration).
-- @return bool True on success, false on failure.
--

-- function wp_cache_set( $key, $data, $group = '', $expire = 0 ) then
--         global $wp_object_cache;

--         return $wp_object_cache->set( $key, $data, $group, (int) $expire );
-- end;

--
-- Sets multiple values to the cache in one call.
--
-- @since 6.0.0
--
-- @see WP_Object_Cache::set_multiple()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param array  $data   Array of keys and values to be set.
-- @param string $group  Optional. Where the cache contents are grouped. Default empty.
-- @param int    $expire Optional. When to expire the cache contents, in seconds.
--                       Default 0 (no expiration).
-- @return bool[] Array of return values, grouped by key. Each value is either
--                true on success, or false on failure.
--

-- function wp_cache_set_multiple( array $data, $group = '', $expire = 0 ) then
--         global $wp_object_cache;

--         return $wp_object_cache->set_multiple( $data, $group, $expire );
-- end;

------------------
-- wp_cache_get --
------------------

-- function Wp_Cache_Get (Key   : String;
--                        Group : String  := "";
--                        Force : Boolean := False;
--                        found : out Boolean)
--                        return String
   procedure Wp_Cache_Get (Key   : String;
                           Group : String  := "";
                           Post  : Inc_Class_Wp_Posts.Wp_Post;
                           Force : Boolean := False;
--                         found : out Boolean
                           Success : out Boolean)
--                         return String
   is
--    global $wp_object_cache;
   begin
      null;
--    return $wp_object_cache->get( $key, $group, $force, $found );
   end Wp_Cache_Get;

--
-- Retrieves multiple values from the cache in one call.
--
-- @since 5.5.0
--
-- @see WP_Object_Cache::get_multiple()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param array  $keys  Array of keys under which the cache contents are stored.
-- @param string $group Optional. Where the cache contents are grouped. Default empty.
-- @param bool   $force Optional. Whether to force an update of the local cache
--                      from the persistent cache. Default false.
-- @return array Array of return values, grouped by key. Each value is either
--               the cache contents on success, or false on failure.
--

-- function wp_cache_get_multiple( $keys, $group = '', $force = false ) then
--         global $wp_object_cache;

--         return $wp_object_cache->get_multiple( $keys, $group, $force );
-- end;

--
-- Removes the cache contents matching key and group.
--
-- @since 2.0.0
--
-- @see WP_Object_Cache::delete()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param int|string $key   What the contents in the cache are called.
-- @param string     $group Optional. Where the cache contents are grouped. Default empty.
-- @return bool True on successful removal, false on failure.
--

-- function wp_cache_delete( $key, $group = '' ) then
--         global $wp_object_cache;

--         return $wp_object_cache->delete( $key, $group );
-- end;

--
-- Deletes multiple values from the cache in one call.
--
-- @since 6.0.0
--
-- @see WP_Object_Cache::delete_multiple()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param array  $keys  Array of keys under which the cache to deleted.
-- @param string $group Optional. Where the cache contents are grouped. Default empty.
-- @return bool[] Array of return values, grouped by key. Each value is either
--                true on success, or false if the contents were not deleted.
--

-- function wp_cache_delete_multiple( array $keys, $group = '' ) then
--         global $wp_object_cache;

--         return $wp_object_cache->delete_multiple( $keys, $group );
-- end;

--
-- Increments numeric cache item's value.
--
-- @since 3.3.0
--
-- @see WP_Object_Cache::incr()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param int|string $key    The key for the cache contents that should be incremented.
-- @param int        $offset Optional. The amount by which to increment the item's value.
--                           Default 1.
-- @param string     $group  Optional. The group the key is in. Default empty.
-- @return int|false The item's new value on success, false on failure.
--

-- function wp_cache_incr( $key, $offset = 1, $group = '' ) then
--         global $wp_object_cache;

--         return $wp_object_cache->incr( $key, $offset, $group );
-- end;

--
-- Decrements numeric cache item's value.
--
-- @since 3.3.0
--
-- @see WP_Object_Cache::decr()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param int|string $key    The cache key to decrement.
-- @param int        $offset Optional. The amount by which to decrement the item's value.
--                           Default 1.
-- @param string     $group  Optional. The group the key is in. Default empty.
-- @return int|false The item's new value on success, false on failure.
--

-- function wp_cache_decr( $key, $offset = 1, $group = '' ) then
--         global $wp_object_cache;

--         return $wp_object_cache->decr( $key, $offset, $group );
-- end;

--
-- Removes all cache items.
--
-- @since 2.0.0
--
-- @see WP_Object_Cache::flush()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @return bool True on success, false on failure.
--

-- function wp_cache_flush() then
--         global $wp_object_cache;

--         return $wp_object_cache->flush();
-- end;

--
-- Removes all cache items from the in-memory runtime cache.
--
-- @since 6.0.0
--
-- @see WP_Object_Cache::flush()
--
-- @return bool True on success, false on failure.
--

-- function wp_cache_flush_runtime() then
--         return wp_cache_flush();
-- end;

--
-- Removes all cache items in a group, if the object cache implementation supports it.
--
-- Before calling this function, always check for group flushing support using the
-- `wp_cache_supports( 'flush_group' )` function.
--
-- @since 6.1.0
--
-- @see WP_Object_Cache::flush_group()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param string $group Name of group to remove from cache.
-- @return bool True if group was flushed, false otherwise.
--

-- function wp_cache_flush_group( $group ) then
--         global $wp_object_cache;

--         return $wp_object_cache->flush_group( $group );
-- end;

--
-- Determines whether the object cache implementation supports a particular feature.
--
-- @since 6.1.0
--
-- @param string $feature Name of the feature to check for. Possible values include:
--                        'add_multiple', 'set_multiple', 'get_multiple', 'delete_multiple',
--                        'flush_runtime', 'flush_group'.
-- @return bool True if the feature is supported, false otherwise.
--

-- function wp_cache_supports( $feature ) then
--         switch ( $feature ) then
--                 case 'add_multiple':
--                 case 'set_multiple':
--                 case 'get_multiple':
--                 case 'delete_multiple':
--                 case 'flush_runtime':
--                 case 'flush_group':
--                         return true;

--                 default:
--                         return false;
--         end;
-- end;

--
-- Closes the cache.
--
-- This function has ceased to do anything since WordPress 2.5. The
-- functionality was removed along with the rest of the persistent cache.
--
-- This does not mean that plugins can't implement this function when they need
-- to make sure that the cache is cleaned up after WordPress no longer needs it.
--
-- @since 2.0.0
--
-- @return true Always returns true.
--

-- function wp_cache_close() then
--         return true;
-- end;

--
-- Adds a group or set of groups to the list of global groups.
--
-- @since 2.6.0
--
-- @see WP_Object_Cache::add_global_groups()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param string|string[] $groups A group or an array of groups to add.
--

-- function wp_cache_add_global_groups( $groups ) then
--         global $wp_object_cache;

--         $wp_object_cache->add_global_groups( $groups );
-- end;

--
-- Adds a group or set of groups to the list of non-persistent groups.
--
-- @since 2.6.0
--
-- @param string|string[] $groups A group or an array of groups to add.
--

-- function wp_cache_add_non_persistent_groups( $groups ) then
--         // Default cache doesn't persist so nothing to do here.
-- end;

--
-- Switches the internal blog ID.
--
-- This changes the blog id used to create keys in blog specific groups.
--
-- @since 3.5.0
--
-- @see WP_Object_Cache::switch_to_blog()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param int $blog_id Site ID.
--

-- function wp_cache_switch_to_blog( $blog_id ) then
--         global $wp_object_cache;

--         $wp_object_cache->switch_to_blog( $blog_id );
-- end;

--
-- Resets internal cache keys and structures.
--
-- If the cache back end uses global blog or site IDs as part of its cache keys,
-- this function instructs the back end to reset those keys and perform any cleanup
-- since blog or site IDs have changed since cache init.
--
-- This function is deprecated. Use wp_cache_switch_to_blog() instead of this
-- function when preparing the cache for a blog switch. For clearing the cache
-- during unit tests, consider using wp_cache_init(). wp_cache_init() is not
-- recommended outside of unit tests as the performance penalty for using it is high.
--
-- @since 3.0.0
-- @deprecated 3.5.0 Use wp_cache_switch_to_blog()
-- @see WP_Object_Cache::reset()
--
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--

-- function wp_cache_reset() then
--         _deprecated_function( __FUNCTION__, '3.5.0', 'wp_cache_switch_to_blog()' );

--         global $wp_object_cache;

--         $wp_object_cache->reset();
-- end;

end Adi_Caches;
