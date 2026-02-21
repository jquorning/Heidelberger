--
-- Object Cache API
--
-- @link https://developer.wordpress.org/reference/classes/wp_object_cache/
--
-- @package WordPress
-- @subpackage Cache
--

with Arrays;
with Lists;

with Class_Comments;
with Class_Posts;
with Class_Users;
with Inc_Comments;

package Inc_Caches
is
   use Arrays;
   use Lists;

   --
   -- Removes the cache contents matching key and group.
   --
   -- @since 2.0.0
   --
   -- @see WP_Object_Cache::delete()
   -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
   --
   -- @param int|string $key   What the contents in the cache are called.
   -- @param string     $group Optional. Where the cache contents are grouped.
   --                           Default empty.
   -- @return bool True on successful removal, false on failure.
   --
   function Wp_Cache_Delete (Key   : String;
                             Group : String := "")
                             return Boolean;

   procedure Wp_Cache_Delete (Key   : String;
                              Group : String := "");

   --
   -- Deletes multiple values from the cache in one call.
   --
   -- @since 6.0.0
   --
   -- @see WP_Object_Cache::delete_multiple()
   -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
   --
   -- @param array  $keys  Array of keys under which the cache to deleted.
   -- @param string $group Optional. Where the cache contents are grouped. Default
   --                      empty.
   -- @return bool[] Array of return values, grouped by key. Each value is either
   --                true on success, or false if the contents were not deleted.
   --
   function Wp_Cache_Delete_Multiple (Keys  : List_Type;
                                      Group : String := "")
                                      return Array_Type;

   procedure Wp_Cache_Delete_Multiple (Keys  : List_Type;
                                       Group : String := "");

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
   procedure Wp_Cache_Flush;

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
   procedure Wp_Cache_Add_Global_Groups (Groups : String);

   --
   -- Adds a group or set of groups to the list of non-persistent groups.
   --
   -- @since 2.6.0
   --
   -- @param string|string[] $groups A group or an array of groups to add.
   --
   procedure Wp_Cache_Add_Non_Persistent_Groups (Groups : String);

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
   procedure Wp_Cache_Add (Key     : String;
                           Data    : Multi_Type;
                           Group   : String  := "";
                           Expire  : Natural := 0;
                           Success : out Boolean);

   generic
      type Data_Type is private;
   procedure Generic_Wp_Cache_Add (Key    : String;
                                   Data   : Data_Type;
                                   Group  : String  := "";
                                   Expire : Natural := 0);

   procedure Generic_Wp_Cache_Add (Key    : String;
                                   Data   : Data_Type;
                                   Group  : String  := "";
                                   Expire : Natural := 0)
   is null;

   procedure Wp_Cache_Add is new Generic_Wp_Cache_Add (Multi_Type);
   procedure Wp_Cache_Add is new Generic_Wp_Cache_Add (Integer);
   procedure Wp_Cache_Add is new
     Generic_Wp_Cache_Add (Class_Comments.Wp_Comment);

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
                          Found : out Boolean)
                          return Multi_Type;

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return String;

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Boolean;

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Class_Posts.Wp_Post;

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Array_Type;

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Integer;

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Inc_Comments.Comment_Counts_Type;

   function Wp_Cache_Get (Key   : Integer;         -- Comment_Id
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Class_Comments.Wp_Comment;

   function Wp_Cache_Get (Key   : Integer;         -- User_Id
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Class_Users.Wp_User;

   function Wp_Cache_Get (Key   : String;         -- User_Id
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Class_Users.Wp_User;

   --
   -- Saves the data to the cache.
   --
   -- Differs from wp_cache_add() and wp_cache_replace() in that it will always
   -- write data.
   --
   -- @since 2.0.0
   --
   -- @see WP_Object_Cache::set()
   -- @global WP_Object_Cache $wp_object_cache Object cache global instance.
   --
   -- @param int|string $key    The cache key to use for retrieval later.
   -- @param mixed      $data   The contents to store in the cache.
   -- @param string     $group  Optional. Where to group the cache contents. Enables
   --                           the same key to be used across groups. Default empty.
   -- @param int        $expire Optional. When to expire the cache contents, in
   --                           seconds. Default 0 (no expiration).
   --
   -- @return bool True on success, false on failure.
   --
   procedure Wp_Cache_Set (Key     : String;
                           Data    : Multi_Type;
                           Group   : String  := "";
                           Expire  : Integer := 0;
                           Success : out Boolean);

   generic
      type Data_Type (<>) is private;
   procedure Generic_Wp_Cache_Set (Key    : String;
                                   Data   : Data_Type;
                                   Group  : String  := "";
                                   Expire : Integer := 0);

   procedure Generic_Wp_Cache_Set (Key    : String;
                                   Data   : Data_Type;
                                   Group  : String  := "";
                                   Expire : Integer := 0)
   is null;

   procedure Wp_Cache_Set is new Generic_Wp_Cache_Set (Integer);
   procedure Wp_Cache_Set is new Generic_Wp_Cache_Set (String);
   procedure Wp_Cache_Set is new Generic_Wp_Cache_Set (Array_Type);
   procedure Wp_Cache_Set is new Generic_Wp_Cache_Set (Boolean);

   procedure Wp_Cache_Set is
     new Generic_Wp_Cache_Set (Inc_Comments.Comment_Counts_Type);

end Inc_Caches;
