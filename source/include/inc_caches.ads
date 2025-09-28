--
-- Object Cache API
--
-- @link https://developer.wordpress.org/reference/classes/wp_object_cache/
--
-- @package WordPress
-- @subpackage Cache
--

package Inc_Caches
is
   procedure Dummy;

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

end Inc_Caches;
