--
-- Object Cache API
--
-- @link https://developer.wordpress.org/reference/classes/wp_object_cache/
--
-- @package WordPress
-- @subpackage Cache
--

with Helpers;

with Inc_Class_Wp_Object_Caches;

package body Inc_Caches
is

   Global_Wp_Object_Cache : Inc_Class_Wp_Object_Caches.Wp_Object_Cache;

-- --
-- -- Sets up Object Cache Global and assigns it.
-- --
-- -- @since 2.0.0
-- --
-- -- @global WP_Object_Cache $wp_object_cache
-- --
-- function wp_cache_init() then
--         $GLOBALS['wp_object_cache'] = new WP_Object_Cache();
-- end;

   ------------------
   -- Wp_Cache_Add --
   ------------------

   procedure Wp_Cache_Add (Key     : String;
                           Data    : Multi_Type;
                           Group   : String  := "";
                           Expire  : Natural := 0;
                           Success : out Boolean)
   is
   begin
      Global_Wp_Object_Cache.Add (Key, Data, Group, Expire, Success => Success);
   end Wp_Cache_Add;

-- --
-- -- Adds multiple values to the cache in one call.
-- --
-- -- @since 6.0.0
-- --
-- -- @see WP_Object_Cache::add_multiple()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param array  $data   Array of keys and values to be set.
-- -- @param string $group  Optional. Where the cache contents are grouped. Default empty.
-- -- @param int    $expire Optional. When to expire the cache contents, in seconds.
-- --                       Default 0 (no expiration).
-- -- @return bool[] Array of return values, grouped by key. Each value is either
-- --                true on success, or false if cache key and group already exist.
-- --
-- function wp_cache_add_multiple( array $data, $group = '', $expire = 0 ) then
--         global $wp_object_cache;

--         return $wp_object_cache->add_multiple( $data, $group, $expire );
-- end;

-- --
-- -- Replaces the contents of the cache with new data.
-- --
-- -- @since 2.0.0
-- --
-- -- @see WP_Object_Cache::replace()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param int|string $key    The key for the cache data that should be replaced.
-- -- @param mixed      $data   The new data to store in the cache.
-- -- @param string     $group  Optional. The group for the cache data that should be replaced.
-- --                           Default empty.
-- -- @param int        $expire Optional. When to expire the cache contents, in seconds.
-- --                           Default 0 (no expiration).
-- -- @return bool True if contents were replaced, false if original value does not exist.
-- --
-- function wp_cache_replace( $key, $data, $group = '', $expire = 0 ) then
--         global $wp_object_cache;

--         return $wp_object_cache->replace( $key, $data, $group, (int) $expire );
-- end;

   ------------------
   -- Wp_Cache_Set --
   ------------------

   procedure Wp_Cache_Set (Key     : String;
                           Data    : Multi_Type;
                           Group   : String  := "";
                           Expire  : Integer := 0;
                           Success : out Boolean)
   is
   begin
      Global_Wp_Object_Cache.Set (Key, Data, Group, Expire, Success);
   end Wp_Cache_Set;

-- --
-- -- Sets multiple values to the cache in one call.
-- --
-- -- @since 6.0.0
-- --
-- -- @see WP_Object_Cache::set_multiple()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param array  $data   Array of keys and values to be set.
-- -- @param string $group  Optional. Where the cache contents are grouped. Default empty.
-- -- @param int    $expire Optional. When to expire the cache contents, in seconds.
-- --                       Default 0 (no expiration).
-- -- @return bool[] Array of return values, grouped by key. Each value is either
-- --                true on success, or false on failure.
-- --
-- function wp_cache_set_multiple( array $data, $group = '', $expire = 0 ) then
--         global $wp_object_cache;

--         return $wp_object_cache->set_multiple( $data, $group, $expire );
-- end;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Multi_Type
   is
   begin
      return Global_Wp_Object_Cache.Get (Key, Group, Force, Found);
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Array_Type
   is
      Result : constant Multi_Type :=
        Wp_Cache_Get (Key, Group, Force, Found);
   begin
      case Kind_Of (Result) is
      when Kind_Null =>
         return Empty_Array;
      when others =>
         return As_Array (Result);
      end case;
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Boolean
   is
   begin
      return As_Boolean (Wp_Cache_Get (Key, Group, Force, Found));
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return String
   is
   begin
      return As_String (Wp_Cache_Get (Key, Group, Force, Found));
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Inc_Class_Wp_Posts.Wp_Post
   is
      Result : constant Multi_Type := Wp_Cache_Get (Key, Group, Force, Found);
   begin
      if Result = From_Null then
         return Inc_Class_Wp_Posts.Null_Post;
      else
         return Inc_Class_Wp_Posts.Null_Post;
      end if;
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Integer
   is
   begin
      return As_Integer (Wp_Cache_Get (Key, Group, Force, Found));
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Inc_Comments.Comment_Counts
   is
      Result : constant Multi_Type :=
        Wp_Cache_Get (Key, Group, Force, Found);
   begin
      if Result = From_Null then
         return Inc_Comments.Null_Comment_Counts;
      else
         return Inc_Comments.Null_Comment_Counts; -- Comment_Counts (Result);
      end if;
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : Integer;         -- Comment_Id
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Inc_Class_Wp_Comments.Wp_Comment
   is
      Result : constant Multi_Type :=
        Wp_Cache_Get (Helpers.Image (Key),
                      Group, Force, Found);
   begin
      if Result = From_Null then
         return Inc_Class_Wp_Comments.Null_Comment;
      else
         return Inc_Class_Wp_Comments.Null_Comment; -- Wp_Comment (Result);
      end if;
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : Integer;         -- User_Id
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Inc_Class_Wp_Users.Wp_User
   is
      Result : constant Multi_Type :=
        Wp_Cache_Get (Helpers.Image (Key),
                      Group, Force, Found);
   begin
      if Result = From_Null then
         return Inc_Class_Wp_Users.Null_User;
      else
         return Inc_Class_Wp_Users.Null_User; -- Wp_Comment (Result);
      end if;
   end Wp_Cache_Get;

   ------------------
   -- Wp_Cache_Get --
   ------------------

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Inc_Class_Wp_Users.Wp_User
   is
      Result : constant Multi_Type :=
        Wp_Cache_Get (Key, Group, Force, Found);
   begin
      if Result = From_Null then
         return Inc_Class_Wp_Users.Null_User;
      else
         return Inc_Class_Wp_Users.Null_User; -- Wp_User (Result);
      end if;
   end Wp_Cache_Get;

-- --
-- -- Retrieves multiple values from the cache in one call.
-- --
-- -- @since 5.5.0
-- --
-- -- @see WP_Object_Cache::get_multiple()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param array  $keys  Array of keys under which the cache contents are stored.
-- -- @param string $group Optional. Where the cache contents are grouped. Default empty.
-- -- @param bool   $force Optional. Whether to force an update of the local cache
-- --                      from the persistent cache. Default false.
-- -- @return array Array of return values, grouped by key. Each value is either
-- --               the cache contents on success, or false on failure.
-- --
-- function wp_cache_get_multiple( $keys, $group = '', $force = false ) then
--         global $wp_object_cache;

--         return $wp_object_cache->get_multiple( $keys, $group, $force );
-- end;

   ---------------------
   -- Wp_Cache_Delete --
   ---------------------

   procedure Wp_Cache_Delete (Key   : String;
                              Group : String := "")
   is
      Unused_Done : Boolean;
   begin
      Global_Wp_Object_Cache.Delete (Key, Group, Done => Unused_Done);
   end Wp_Cache_Delete;

-- --
-- -- Deletes multiple values from the cache in one call.
-- --
-- -- @since 6.0.0
-- --
-- -- @see WP_Object_Cache::delete_multiple()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param array  $keys  Array of keys under which the cache to deleted.
-- -- @param string $group Optional. Where the cache contents are grouped. Default empty.
-- -- @return bool[] Array of return values, grouped by key. Each value is either
-- --                true on success, or false if the contents were not deleted.
-- --
-- function wp_cache_delete_multiple( array $keys, $group = '' ) then
--         global $wp_object_cache;

--         return $wp_object_cache->delete_multiple( $keys, $group );
-- end;

-- --
-- -- Increments numeric cache item's value.
-- --
-- -- @since 3.3.0
-- --
-- -- @see WP_Object_Cache::incr()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param int|string $key    The key for the cache contents that should be incremented.
-- -- @param int        $offset Optional. The amount by which to increment the item's value.
-- --                           Default 1.
-- -- @param string     $group  Optional. The group the key is in. Default empty.
-- -- @return int|false The item's new value on success, false on failure.
-- --
-- function wp_cache_incr( $key, $offset = 1, $group = '' ) then
--         global $wp_object_cache;

--         return $wp_object_cache->incr( $key, $offset, $group );
-- end;

-- --
-- -- Decrements numeric cache item's value.
-- --
-- -- @since 3.3.0
-- --
-- -- @see WP_Object_Cache::decr()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param int|string $key    The cache key to decrement.
-- -- @param int        $offset Optional. The amount by which to decrement the item's value.
-- --                           Default 1.
-- -- @param string     $group  Optional. The group the key is in. Default empty.
-- -- @return int|false The item's new value on success, false on failure.
-- --
-- function wp_cache_decr( $key, $offset = 1, $group = '' ) then
--         global $wp_object_cache;

--         return $wp_object_cache->decr( $key, $offset, $group );
-- end;

   --------------------
   -- Wp_Cache_Flush --
   --------------------

   procedure Wp_Cache_Flush
   is
   begin
--         return $
      Global_Wp_Object_Cache.Flush;
   end Wp_Cache_Flush;

-- --
-- -- Removes all cache items from the in-memory runtime cache.
-- --
-- -- @since 6.0.0
-- --
-- -- @see WP_Object_Cache::flush()
-- --
-- -- @return bool True on success, false on failure.
-- --
-- function wp_cache_flush_runtime() then
--         return wp_cache_flush();
-- end;

-- --
-- -- Removes all cache items in a group, if the object cache implementation supports it.
-- --
-- -- Before calling this function, always check for group flushing support using the
-- -- `wp_cache_supports( 'flush_group' )` function.
-- --
-- -- @since 6.1.0
-- --
-- -- @see WP_Object_Cache::flush_group()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param string $group Name of group to remove from cache.
-- -- @return bool True if group was flushed, false otherwise.
-- --
-- function wp_cache_flush_group( $group ) then
--         global $wp_object_cache;

--         return $wp_object_cache->flush_group( $group );
-- end;

-- --
-- -- Determines whether the object cache implementation supports a particular feature.
-- --
-- -- @since 6.1.0
-- --
-- -- @param string $feature Name of the feature to check for. Possible values include:
-- --                        'add_multiple', 'set_multiple', 'get_multiple', 'delete_multiple',
-- --                        'flush_runtime', 'flush_group'.
-- -- @return bool True if the feature is supported, false otherwise.
-- --
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

-- --
-- -- Closes the cache.
-- --
-- -- This function has ceased to do anything since WordPress 2.5. The
-- -- functionality was removed along with the rest of the persistent cache.
-- --
-- -- This does not mean that plugins can't implement this function when they need
-- -- to make sure that the cache is cleaned up after WordPress no longer needs it.
-- --
-- -- @since 2.0.0
-- --
-- -- @return true Always returns true.
-- --
-- function wp_cache_close() then
--         return true;
-- end;

   --------------------------------
   -- Wp_Cache_Add_Global_Groups --
   --------------------------------

   procedure Wp_Cache_Add_Global_Groups (Groups : String)
   is
--    global $wp_object_cache;
   begin
--    Wp_Object_Cache.Add_Global_Groups (Groups);
      null;
   end Wp_Cache_Add_Global_Groups;

   ----------------------------------------
   -- Wp_Cache_Add_Non_Persistent_Groups --
   ----------------------------------------

   procedure Wp_Cache_Add_Non_Persistent_Groups (Groups : String)
   is null;
   -- Default cache doesn't persist so nothing to do here.

-- --
-- -- Switches the internal blog ID.
-- --
-- -- This changes the blog id used to create keys in blog specific groups.
-- --
-- -- @since 3.5.0
-- --
-- -- @see WP_Object_Cache::switch_to_blog()
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- -- @param int $blog_id Site ID.
-- --
-- function wp_cache_switch_to_blog( $blog_id ) then
--         global $wp_object_cache;

--         $wp_object_cache->switch_to_blog( $blog_id );
-- end;

-- --
-- -- Resets internal cache keys and structures.
-- --
-- -- If the cache back end uses global blog or site IDs as part of its cache keys,
-- -- this function instructs the back end to reset those keys and perform any cleanup
-- -- since blog or site IDs have changed since cache init.
-- --
-- -- This function is deprecated. Use wp_cache_switch_to_blog() instead of this
-- -- function when preparing the cache for a blog switch. For clearing the cache
-- -- during unit tests, consider using wp_cache_init(). wp_cache_init() is not
-- -- recommended outside of unit tests as the performance penalty for using it is high.
-- --
-- -- @since 3.0.0
-- -- @deprecated 3.5.0 Use wp_cache_switch_to_blog()
-- -- @see WP_Object_Cache::reset()
-- --
-- -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
-- --
-- function wp_cache_reset() then
--         _deprecated_function( __FUNCTION__, '3.5.0', 'wp_cache_switch_to_blog()' );

--         global $wp_object_cache;

--         $wp_object_cache->reset();
-- end;

end Inc_Caches;
