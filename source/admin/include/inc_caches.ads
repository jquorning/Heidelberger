with Arrays;

with Inc_Class_Posts;

package Inc_Caches
is
   use Arrays;
--
-- Adds data to the cache, if the cache key doesn't already exist.
--
-- @since 2.0.0
--
-- @see WP_Object_Cache::add()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param int|string $key    The cache key to use for retrieval later.
-- @param mixed      $data   The data to add to the cache.
-- @param string     $group  Optional. The group to add the cache to. Enables the same key
--                           to be used across groups. Default empty.
-- @param int        $expire Optional. When the cache data should expire, in seconds.
--                           Default 0 (no expiration).
-- @return bool True on success, false if cache key and group already exist.
--
   procedure Wp_Cache_Add (Key    : String;
                           Data   : Inc_Class_Posts.Wp_Post;  --- String;
                           Group  : String  := "";
                           Expire : Integer := 0);

   procedure Wp_Cache_Add (Key    : Integer; -- String;
                           Data   : Array_Type;
                           Group  : String  := "";
                           Expire : Integer := 0) is null;
--
-- Retrieves the cache contents from the cache by key and group.
--
-- @since 2.0.0
--
-- @see WP_Object_Cache::get()
-- @global WP_Object_Cache $wp_object_cache Object cache global instance.
--
-- @param int|string $key   The key under which the cache contents are stored.
-- @param string     $group Optional. Where the cache contents are grouped. Default empty.
-- @param bool       $force Optional. Whether to force an update of the local cache
--                          from the persistent cache. Default false.
-- @param bool       $found Optional. Whether the key was found in the cache (passed by reference).
--                          Disambiguates a return of false, a storable value. Default null.
-- @return mixed|false The cache contents on success, false on failure to retrieve contents.
--
   procedure Wp_Cache_Get (Key   : String;
                           Group : String  := "";
                           Post  : Inc_Class_Posts.Wp_Post;
                           Force : Boolean := False;
--                         found : out Boolean
                           Success : out Boolean);
--                         return String;

   procedure Wp_Cache_Get (Key    : Integer;
                           Group  : String  := "";
                           Result : out Array_Type;
                           Hit    : out Boolean) is null;

end Inc_Caches;
