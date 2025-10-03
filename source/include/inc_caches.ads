--
-- Object Cache API
--
-- @link https://developer.wordpress.org/reference/classes/wp_object_cache/
--
-- @package WordPress
-- @subpackage Cache
--

with Arrays;

package Inc_Caches
is
   use Arrays;

   procedure Dummy;

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
   -- @param string     $group  Optional. The group to add the cache to. Enables the
   --                           same key to be used across groups. Default empty.
   -- @param int        $expire Optional. When the cache data should expire, in
   --                           seconds. Default 0 (no expiration).
   -- @return bool True on success, false if cache key and group already exist.
   --
   function Wp_Cache_Add (Key    : String;
                          Data   : Array_Type;
                          Group  : String  := "";
                          Expire : Natural := 0)
                          return Boolean
                          is (False);

   --
   -- Retrieves the cache contents from the cache by key and group.
   --
   -- @since 2.0.0
   --
   -- @see WP_Object_Cache::get()
   -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
   --
   -- @param int|string $key   The key under which the cache contents are stored.
   -- @param string     $group Optional. Where the cache contents are grouped. Default
   --                          empty.
   -- @param bool       $force Optional. Whether to force an update of the local cache
   --                          from the persistent cache. Default false.
   -- @param bool       $found Optional. Whether the key was found in the cache
   --                          (passed by reference). Disambiguates a return of false,
   --                          a storable value. Default null.
   -- @return mixed|false The cache contents on success, false on failure to retrieve
   --                     contents.
   --
   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean) -- = null
                          return String
                          is ("XXX-628");

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean) -- = null
                          return Array_Type
                          is (Empty_Array);

end Inc_Caches;
