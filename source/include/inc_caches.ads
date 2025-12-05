--
-- Object Cache API
--
-- @link https://developer.wordpress.org/reference/classes/wp_object_cache/
--
-- @package WordPress
-- @subpackage Cache
--

with Arrays;

with Inc_Class_Wp_Comments;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Users;
with Inc_Comments;

package Inc_Caches
is
   use Arrays;

   procedure Dummy;

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
   function Wp_Cache_Add (Key    : String;
                          Data   : Array_Type;
                          Group  : String  := "";
                          Expire : Natural := 0)
                          return Boolean
                          is (False);

   procedure Wp_Cache_Add (Key    : String;
                           Data   : Integer; -- String;
                           Group  : String  := "";
                           Expire : Natural := 0)
                           is null;

   procedure Wp_Cache_Add (Key    : String;
                           Data   : Inc_Class_Wp_Comments.Wp_Comment; -- String;
                           Group  : String  := "";
                           Expire : Natural := 0)
                           is null;

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
                          Found : out Boolean)
                          return Inc_Class_Wp_Posts.Wp_Post
                          is (Inc_Class_Wp_Posts.Null_Post);

   function Wp_Cache_Get (Key   : Integer; -- String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean)
                          return Inc_Class_Wp_Comments.Wp_Comment
                          is (Inc_Class_Wp_Comments.Null_Comment);

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean) -- = null
                          return Array_Type
                          is (Empty_Array);

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean) -- = null
                          return Integer
                          is (99);

   function Wp_Cache_Get (Key   : Integer;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean) -- = null
                          return Inc_Class_Wp_Users.Wp_User -- Integer
                          is (Inc_Class_Wp_Users.Null_User);

   function Wp_Cache_Get (Key   : String;
                          Group : String  := "";
                          Force : Boolean := False;
                          Found : out Boolean) -- = null
                          return Inc_Comments.Comment_Counts
                          is (Inc_Comments.Null_Comment_Counts);

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
   -- function Wp_Cache_Set (Key    : String;
   --                        Data   : Integer;
   --                        Group  : String  := "";
   --                        Expire : Integer := 0)
   --                        return Boolean;

   procedure Wp_Cache_Set (Key    : String;
                           Data   : Integer;
                           Group  : String  := "";
                           Expire : Integer := 0)
                           is null;

   procedure Wp_Cache_Set (Key    : String;
                           Data   : Inc_Comments.Comment_Counts;
                           Group  : String  := "";
                           Expire : Integer := 0)
                           is null;

end Inc_Caches;
