--
-- Object Cache API: WP_Object_Cache class
--
-- @package WordPress
-- @subpackage Cache
-- @since 5.4.0
--

with Ada.Strings.Unbounded;

with Arrays;

package Class_Object_Caches
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- Core class that implements an object cache.
   --
   -- The WordPress Object Cache is used to save on trips to the database. The
   -- Object Cache stores all of the cache data to memory and makes the cache
   -- contents available by using a key, which is used to name and later retrieve
   -- the cache contents.
   --
   -- The Object Cache can be replaced by other caching mechanisms by placing files
   -- in the wp-content folder which is looked at in wp-settings. If that file
   -- exists, then this file will not be included.
   --
   -- @since 2.0.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Object_Cache is tagged
     record

        --
        -- Holds the cached objects.
        --
        -- @since 2.0.0
        -- @var array
        --
        -- private
        Cache : Array_Type;

        --
        -- The amount of times the cache data was already stored in the cache.
        --
        -- @since 2.5.0
        -- @var int
        --
        Cache_Hits : Natural := 0;

        --
        -- Amount of times the cache did not have the request in cache.
        --
        -- @since 2.0.0
        -- @var int
        --
        Cache_Misses : Natural := 0;

        --
        -- List of global cache groups.
        --
        -- @since 3.0.0
        -- @var string[]
        --
        -- protected
        Global_Groups : Array_Type;

        --
        -- The blog prefix to prepend to keys in non-global groups.
        --
        -- @since 3.5.0
        -- @var string
        --
        -- private
        Blog_Prefix : Unbounded_String;

        --
        -- Holds the value of is_multisite().
        --
        -- @since 3.5.0
        -- @var bool
        --
        -- private
        Multisite : Boolean;

     end record;

--         --
--         -- Sets up object properties; PHP 5 style constructor.
--         --
--         -- @since 2.0.8
--         --
--         public function __construct() then
--                 this->multisite   = is_multisite();
--                 this->blog_prefix = this->multisite ? get_current_blog_id() . ":" : "";
--         end;

--         --
--         -- Makes private properties readable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name Property to get.
--         -- @return mixed Property.
--         --
--         public function __get( name ) then
--                 return this->name;
--         end;

--         --
--         -- Makes private properties settable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name  Property to set.
--         -- @param mixed  value Property value.
--         -- @return mixed Newly-set property.
--         --
--         public function __set( name, value ) then
--                 return this->name = value;
--         end;

--         --
--         -- Makes private properties checkable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name Property to check if set.
--         -- @return bool Whether the property is set.
--         --
--         public function __isset( name ) then
--                 return isset( this->name );
--         end;

--         --
--         -- Makes private properties un-settable for backward compatibility.
--         --
--         -- @since 4.0.0
--         --
--         -- @param string name Property to unset.
--         --
--         public function __unset( name ) then
--                 unset( this->name );
--         end;

   --
   -- Serves as a utility function to determine whether a key is valid.
   --
   -- @since 6.1.0
   --
   -- @param int|string key Cache key to check for validity.
   -- @return bool Whether the key is valid.
   --
   -- protected
   function Is_Valid_Key (This : Wp_Object_Cache;
                          Key  : String)
                          return Boolean;

   --
   -- Serves as a utility function to determine whether a key exists in the cache.
   --
   -- @since 3.4.0
   --
   -- @param int|string key   Cache key to check for existence.
   -- @param string     group Cache group for the key existence check.
   -- @return bool Whether the key exists in the cache for the given group.
   --
   -- protected
   function X_Exists (This  : Wp_Object_Cache;
                      Key   : String;
                      Group : String)
                      return Boolean;

   --
   -- Adds data to the cache if it doesn"t already exist.
   --
   -- @since 2.0.0
   --
   -- @uses WP_Object_Cache::_exists() Checks to see if the cache already has data.
   -- @uses WP_Object_Cache::set()     Sets the data after the checking the cache
   --                                  contents existence.
   --
   -- @param int|string key    What to call the contents in the cache.
   -- @param mixed      data   The contents to store in the cache.
   -- @param string     group  Optional. Where to group the cache contents.
   --                          Default "default".
   -- @param int        expire Optional. When to expire the cache contents, in seconds.
   --                           Default 0 (no expiration).
   -- @return bool True on success, false if cache key and group already exist.
   --
   procedure Add (This    : in out Wp_Object_Cache;
                  Key     : String;
                  Data    : Multi_Type;
                  Group   : String  := "default";
                  Expire  : Natural := 0;
                  Success : out Boolean);

--         --
--         -- Adds multiple values to the cache in one call.
--         --
--         -- @since 6.0.0
--         --
--         -- @param array  data   Array of keys and values to be added.
--         -- @param string group  Optional. Where the cache contents are grouped. Default empty.
--         -- @param int    expire Optional. When to expire the cache contents, in seconds.
--         --                       Default 0 (no expiration).
--         -- @return bool[] Array of return values, grouped by key. Each value is either
--         --                true on success, or false if cache key and group already exist.
--         --
--         public function add_multiple( array data, group = "", expire = 0 ) then
--                 values = array();

--                 foreach ( data as key => value ) then
--                         values[ key ] = this->add( key, value, group, expire );
--                 end;

--                 return values;
--         end;

--         --
--         -- Replaces the contents in the cache, if contents already exist.
--         --
--         -- @since 2.0.0
--         --
--         -- @see WP_Object_Cache::set()
--         --
--         -- @param int|string key    What to call the contents in the cache.
--         -- @param mixed      data   The contents to store in the cache.
--         -- @param string     group  Optional. Where to group the cache contents. Default "default".
--         -- @param int        expire Optional. When to expire the cache contents, in seconds.
--         --                           Default 0 (no expiration).
--         -- @return bool True if contents were replaced, false if original value does not exist.
--         --
--         public function replace( key, data, group = "default", expire = 0 ) then
--                 if ( ! this->is_valid_key( key ) ) then
--                         return false;
--                 end;

--                 if ( empty( group ) ) then
--                         group = "default";
--                 end;

--                 id = key;
--                 if ( this->multisite && ! isset( this->global_groups[ group ] ) ) then
--                         id = this->blog_prefix . key;
--                 end;

--                 if ( ! this->_exists( id, group ) ) then
--                         return false;
--                 end;

--                 return this->set( key, data, group, (int) expire );
--         end;

   --
   -- Sets the data contents into the cache.
   --
   -- The cache contents are grouped by the group parameter followed by the
   -- key. This allows for duplicate IDs in unique groups. Therefore, naming of
   -- the group should be used with care and should follow normal function
   -- naming guidelines outside of core WordPress usage.
   --
   -- The expire parameter is not used, because the cache will automatically
   -- expire for each time a page is accessed and PHP finishes. The method is
   -- more for cache plugins which use files.
   --
   -- @since 2.0.0
   -- @since 6.1.0 Returns false if cache key is invalid.
   --
   -- @param int|string key    What to call the contents in the cache.
   -- @param mixed      data   The contents to store in the cache.
   -- @param string     group  Optional. Where to group the cache contents. Default
   --                           "default".
   -- @param int        expire Optional. Not used.
   -- @return bool True if contents were set, false if key is invalid.
   --
   procedure Set (This    : in out Wp_Object_Cache;
                  Key     : String;
                  Data    : Multi_Type;
                  Group   : String  := "default";
                  Expire  : Natural := 0;
                  Success : out Boolean);

--         --
--         -- Sets multiple values to the cache in one call.
--         --
--         -- @since 6.0.0
--         --
--         -- @param array  data   Array of key and value to be set.
--         -- @param string group  Optional. Where the cache contents are grouped. Default empty.
--         -- @param int    expire Optional. When to expire the cache contents, in seconds.
--         --                       Default 0 (no expiration).
--         -- @return bool[] Array of return values, grouped by key. Each value is always true.
--         --
--         public function set_multiple( array data, group = "", expire = 0 ) then
--                 values = array();

--                 foreach ( data as key => value ) then
--                         values[ key ] = this->set( key, value, group, expire );
--                 end;

--                 return values;
--         end;

   --
   -- Retrieves the cache contents, if it exists.
   --
   -- The contents will be first attempted to be retrieved by searching by the
   -- key in the cache group. If the cache is hit (success) then the contents
   -- are returned.
   --
   -- On failure, the number of cache misses will be incremented.
   --
   -- @since 2.0.0
   --
   -- @param int|string key   The key under which the cache contents are stored.
   -- @param string     group Optional. Where the cache contents are grouped. Default
   --                         "default".
   -- @param bool       force Optional. Unused. Whether to force an update of the
   --                          local cache from the persistent cache. Default false.
   -- @param bool       found Optional. Whether the key was found in the cache (passed
   --                          by reference). Disambiguates a return of false, a
   --                          storable value. Default null.
   -- @return mixed|false The cache contents on success, false on failure to retrieve
   --                      contents.
   --
   function Get (This  : in out Wp_Object_Cache;
                 Key   : String;
                 Group : String  := "default";
                 Force : Boolean := False;
                 Found : out Boolean) -- null
                 return Multi_Type;

--         --
--         -- Retrieves multiple values from the cache in one call.
--         --
--         -- @since 5.5.0
--         --
--         -- @param array  keys  Array of keys under which the cache contents are stored.
--         -- @param string group Optional. Where the cache contents are grouped. Default "default".
--         -- @param bool   force Optional. Whether to force an update of the local cache
--         --                      from the persistent cache. Default false.
--         -- @return array Array of return values, grouped by key. Each value is either
--         --               the cache contents on success, or false on failure.
--         --
--         public function get_multiple( keys, group = "default", force = false ) then
--                 values = array();

--                 foreach ( keys as key ) then
--                         values[ key ] = this->get( key, group, force );
--                 end;

--                 return values;
--         end;

   --
   -- Removes the contents of the cache key in the group.
   --
   -- If the cache key does not exist in the group, then nothing will happen.
   --
   -- @since 2.0.0
   --
   -- @param int|string key        What the contents in the cache are called.
   -- @param string     group      Optional. Where the cache contents are grouped.
   --                              Default "default".
   -- @param bool       deprecated Optional. Unused. Default false.
   -- @return bool True on success, false if the contents were not deleted.
   --
   procedure Delete (This       : in out Wp_Object_Cache;
                     Key        : String;
                     Group      : String := "default";
                     Deprecated : Boolean := False;
                     Done       : out Boolean);

--         --
--         -- Deletes multiple values from the cache in one call.
--         --
--         -- @since 6.0.0
--         --
--         -- @param array  keys  Array of keys to be deleted.
--         -- @param string group Optional. Where the cache contents are grouped. Default empty.
--         -- @return bool[] Array of return values, grouped by key. Each value is either
--         --                true on success, or false if the contents were not deleted.
--         --
--         public function delete_multiple( array keys, group = "" ) then
--                 values = array();

--                 foreach ( keys as key ) then
--                         values[ key ] = this->delete( key, group );
--                 end;

--                 return values;
--         end;

--         --
--         -- Increments numeric cache item"s value.
--         --
--         -- @since 3.3.0
--         --
--         -- @param int|string key    The cache key to increment.
--         -- @param int        offset Optional. The amount by which to increment the item"s value.
--         --                           Default 1.
--         -- @param string     group  Optional. The group the key is in. Default "default".
--         -- @return int|false The item"s new value on success, false on failure.
--         --
--         public function incr( key, offset = 1, group = "default" ) then
--                 if ( ! this->is_valid_key( key ) ) then
--                         return false;
--                 end;

--                 if ( empty( group ) ) then
--                         group = "default";
--                 end;

--                 if ( this->multisite && ! isset( this->global_groups[ group ] ) ) then
--                         key = this->blog_prefix . key;
--                 end;

--                 if ( ! this->_exists( key, group ) ) then
--                         return false;
--                 end;

--                 if ( ! is_numeric( this->cache[ group ][ key ] ) ) then
--                         this->cache[ group ][ key ] = 0;
--                 end;

--                 offset = (int) offset;

--                 this->cache[ group ][ key ] += offset;

--                 if ( this->cache[ group ][ key ] < 0 ) then
--                         this->cache[ group ][ key ] = 0;
--                 end;

--                 return this->cache[ group ][ key ];
--         end;

--         --
--         -- Decrements numeric cache item"s value.
--         --
--         -- @since 3.3.0
--         --
--         -- @param int|string key    The cache key to decrement.
--         -- @param int        offset Optional. The amount by which to decrement the item"s value.
--         --                           Default 1.
--         -- @param string     group  Optional. The group the key is in. Default "default".
--         -- @return int|false The item"s new value on success, false on failure.
--         --
--         public function decr( key, offset = 1, group = "default" ) then
--                 if ( ! this->is_valid_key( key ) ) then
--                         return false;
--                 end;

--                 if ( empty( group ) ) then
--                         group = "default";
--                 end;

--                 if ( this->multisite && ! isset( this->global_groups[ group ] ) ) then
--                         key = this->blog_prefix . key;
--                 end;

--                 if ( ! this->_exists( key, group ) ) then
--                         return false;
--                 end;

--                 if ( ! is_numeric( this->cache[ group ][ key ] ) ) then
--                         this->cache[ group ][ key ] = 0;
--                 end;

--                 offset = (int) offset;

--                 this->cache[ group ][ key ] -= offset;

--                 if ( this->cache[ group ][ key ] < 0 ) then
--                         this->cache[ group ][ key ] = 0;
--                 end;

--                 return this->cache[ group ][ key ];
--         end;

   --
   -- Clears the object cache of all data.
   --
   -- @since 2.0.0
   --
   -- @return true Always returns true.
   --
   procedure Flush (This : in out Wp_Object_Cache);
--                 this->cache = array();

--                 return true;
--         end;

--         --
--         -- Removes all cache items in a group.
--         --
--         -- @since 6.1.0
--         --
--         -- @param string group Name of group to remove from cache.
--         -- @return true Always returns true.
--         --
--         public function flush_group( group ) then
--                 unset( this->cache[ group ] );

--                 return true;
--         end;

--         --
--         -- Sets the list of global cache groups.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string|string[] groups List of groups that are global.
--         --
--         public function add_global_groups( groups ) then
--                 groups = (array) groups;

--                 groups              = array_fill_keys( groups, true );
--                 this->global_groups = array_merge( this->global_groups, groups );
--         end;

--         --
--         -- Switches the internal blog ID.
--         --
--         -- This changes the blog ID used to create keys in blog specific groups.
--         --
--         -- @since 3.5.0
--         --
--         -- @param int blog_id Blog ID.
--         --
--         public function switch_to_blog( blog_id ) then
--                 blog_id           = (int) blog_id;
--                 this->blog_prefix = this->multisite ? blog_id . ":" : "";
--         end;

--         --
--         -- Resets cache keys.
--         --
--         -- @since 3.0.0
--         --
--         -- @deprecated 3.5.0 Use WP_Object_Cache::switch_to_blog()
--         -- @see switch_to_blog()
--         --
--         public function reset() then
--                 _deprecated_function( __FUNCTION__, "3.5.0", "WP_Object_Cache::switch_to_blog()" );

--                 -- Clear out non-global caches since the blog ID has changed.
--                 foreach ( array_keys( this->cache ) as group ) then
--                         if ( ! isset( this->global_groups[ group ] ) ) then
--                                 unset( this->cache[ group ] );
--                         end;
--                 end;
--         end;

--         --
--         -- Echoes the stats of the caching.
--         --
--         -- Gives the cache hits, and cache misses. Also prints every cached group,
--         -- key and the data.
--         --
--         -- @since 2.0.0
--         --
--         public function stats() then
--                 echo "<p>";
--                 echo "<strong>Cache Hits:</strong> thenthis->cache_hitsend;<br />";
--                 echo "<strong>Cache Misses:</strong> thenthis->cache_missesend;<br />";
--                 echo "</p>";
--                 echo "<ul>";
--                 foreach ( this->cache as group => cache ) then
--                         echo "<li><strong>Group:</strong> " . esc_html( group ) . " - ( " . number_format( strlen( serialize( cache ) ) / KB_IN_BYTES, 2 ) . "k )</li>";
--                 end;
--                 echo "</ul>";
--         end;

end Class_Object_Caches;
