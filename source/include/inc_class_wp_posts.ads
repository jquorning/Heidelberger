--
-- Post API: WP_Post class
--
-- @package WordPress
-- @subpackage Post
-- @since 4.4.0
--

with Ada.Strings.Unbounded;

with Arrays;

package Inc_Class_Wp_Posts
is
   use Ada.Strings.Unbounded;
   use Arrays;

   function To_Us (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   type Property_Type is
      record
         Taxonomy : Unbounded_String;
         Term_Id  : Integer;
      end record;

   Null_Property_Type : constant Property_Type := (Null_Unbounded_String, 0);
--
-- Core class used to implement the WP_Post object.
--
-- @since 3.5.0
--
-- @property string $page_template
--
-- @property-read int[]    $ancestors
-- @property-read int[]    $post_category
-- @property-read string[] $tags_input
--
-- #[AllowDynamicProperties]
-- final class WP_Post {
   type Post_Id is new Natural;

   type Wp_Post is tagged
      record
        --
        -- Post ID.
        --
        -- @since 3.5.0
        -- @var int
        --
        Id : Post_Id;

        --
        -- ID of post author.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Author : Unbounded_String;

        --
        -- The post's local publication time.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Date : Unbounded_String := To_Us ("0000-00-00 00:00:00");

        --
        -- The post's GMT publication time.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Date_Gmt : Unbounded_String := To_Us ("0000-00-00 00:00:00");

        --
        -- The post's content.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Content : Unbounded_String;

        --
        -- The post's title.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Title : Unbounded_String;

        --
        -- The post's excerpt.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Excerpt : Unbounded_String;

        --
        -- The post's status.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Status : Unbounded_String := To_Us ("publish");

        --
        -- Whether comments are allowed.
        --
        -- @since 3.5.0
        -- @var string
        --
        Comment_Status : Unbounded_String := To_Us ("open");

        --
        -- Whether pings are allowed.
        --
        -- @since 3.5.0
        -- @var string
        --
        Ping_Status : Unbounded_String := To_Us ("open");

        --
        -- The post's password in plain text.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Password : Unbounded_String;

        --
        -- The post's slug.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Name : Unbounded_String;

        --
        -- URLs queued to be pinged.
        --
        -- @since 3.5.0
        -- @var string
        --
        To_Ping : Unbounded_String;

        --
        -- URLs that have been pinged.
        --
        -- @since 3.5.0
        -- @var string
        --
        Pinged : Unbounded_String;

        --
        -- The post's local modified time.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Modified : Unbounded_String := To_Us ("0000-00-00 00:00:00");

        --
        -- The post's GMT modified time.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Modified_Gmt : Unbounded_String := To_Us ("0000-00-00 00:00:00");

        --
        -- A utility DB field for post content.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Content_Filtered : Unbounded_String;

        --
        -- ID of a post's parent post.
        --
        -- @since 3.5.0
        -- @var int
        --
        Post_Parent : Integer := 0;

        --
        -- The unique identifier for a post, not necessarily a URL, used as the feed GUID.
        --
        -- @since 3.5.0
        -- @var string
        --
        Guid : Unbounded_String;

        --
        -- A field used for ordering posts.
        --
        -- @since 3.5.0
        -- @var int
        --
        Menu_Order : Integer := 0;

        --
        -- The post's type, like post or page.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Type : Unbounded_String := To_Us ("post");

        --
        -- An attachment's mime type.
        --
        -- @since 3.5.0
        -- @var string
        --
        Post_Mime_Type : Unbounded_String;

        --
        -- Cached comment count.
        --
        -- A numeric string, for compatibility reasons.
        --
        -- @since 3.5.0
        -- @var string
        --
        Comment_Count : Unbounded_String;

        --
        -- Stores the post object's sanitization level.
        --
        -- Does not correspond to a DB field.
        --
        -- @since 3.5.0
        -- @var string
        --
        Filter : Unbounded_String;

         -- Added by jq
         Dyn : Property_Type;

      end record;

   --
   -- Retrieve WP_Post instance.
   --
   -- @since 3.5.0
   --
   -- @global wpdb $wpdb WordPress database abstraction object.
   --
   -- @param int $post_id Post ID.
   -- @return WP_Post|false Post object, false otherwise.
   --
   procedure Get_Instance (Id      : Post_Id;
                           Post    : out Wp_Post;
                           Success : out Boolean);
--        function Get_Instance (Id : Post_Id) return Wp_Post;

   --
   -- Constructor.
   --
   -- @since 3.5.0
   --
   -- @param WP_Post|object post Post object.
   --
--        public function __construct( post )
   function X_Construct (Post : Wp_Post) return Wp_Post;

   --
   -- Isset-er.
   --
   -- @since 3.5.0
   --
   -- @param string $key Property to check if set.
   -- @return bool
   --
   function X_Isset (Post : Wp_Post;
                     Key  : String)
                     return Boolean;

   --
   -- Getter.
   --
   -- @since 3.5.0
   --
   -- @param string $key Key to get.
   -- @return mixed
   --
   function X_Get (Post : Wp_post;
                   Key  : String)
                   return Array_Type;

   --
   -- {@Missing Summary}
   --
   -- @since 3.5.0
   --
   -- @param string $filter Filter.
   -- @return WP_Post
   --
   function Filter (Post   : Wp_Post;
                    Filter : String)
                    return Wp_Post;

   --
   -- Convert object to array.
   --
   -- @since 3.5.0
   --
   -- @return array Object as array.
   --
   function To_Array (Post : Wp_Post)
                      return Array_Type;

   Null_Post : constant Wp_Post :=
     (Id => 0, Post_Parent => 0, Menu_Order => 0, Dyn => Null_Property_Type,
      others => Null_Unbounded_String);

end Inc_Class_Wp_Posts;
