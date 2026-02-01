--
-- Post API: WP_Post class
--
-- @package WordPress
-- @subpackage Post
-- @since 4.4.0
--

with Ada.Containers.Vectors;

with Arrays;
with Helpers_2;
with UStrings;

with Class_Users;

package Class_Posts
is
   use Arrays;

   type Property_Type is
      record
         Taxonomy : UStrings.UString;
         Term_Id  : Integer;
      end record;

   Null_Property_Type : constant Property_Type := (UStrings.Null_UString, 0);

   type Post_Id_Type is new Natural;

   function Image is new Helpers_2.Generic_Image (Post_Id_Type);

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
   type Wp_Post is tagged
      record
         --
         -- Post ID.
         --
         -- @since 3.5.0
         -- @var int
         --
         Id : Post_Id_Type;

         --
         -- ID of post author.
         --
         -- A numeric string, for compatibility reasons.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Author : Class_Users.User_Id_Type; -- Integer; -- UString;

         --
         -- The post's local publication time.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Date : UStrings.UString :=
           UStrings.To_UString ("0000-00-00 00:00:00");

         --
         -- The post's GMT publication time.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Date_GMT : UStrings.UString :=
           UStrings.To_UString ("0000-00-00 00:00:00");

         --
         -- The post's content.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Content : UStrings.UString;

         --
         -- The post's title.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Title : UStrings.UString;

         --
         -- The post's excerpt.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Excerpt : UStrings.UString;

         --
         -- The post's status.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Status : UStrings.UString :=
           UStrings.To_UString ("publish");

         --
         -- Whether comments are allowed.
         --
         -- @since 3.5.0
         -- @var string
         --
         Comment_Status : UStrings.UString :=
           UStrings.To_UString ("open");

         --
         -- Whether pings are allowed.
         --
         -- @since 3.5.0
         -- @var string
         --
         Ping_Status : UStrings.UString :=
           UStrings.To_UString ("open");

         --
         -- The post's password in plain text.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Password : UStrings.UString;

         --
         -- The post's slug.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Name : UStrings.UString;

         --
         -- URLs queued to be pinged.
         --
         -- @since 3.5.0
         -- @var string
         --
         To_Ping : UStrings.UString;

         --
         -- URLs that have been pinged.
         --
         -- @since 3.5.0
         -- @var string
         --
         Pinged : UStrings.UString;

         --
         -- The post's local modified time.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Modified : UStrings.UString :=
           UStrings.To_UString ("0000-00-00 00:00:00");

         --
         -- The post's GMT modified time.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Modified_GMT : UStrings.UString :=
           UStrings.To_UString ("0000-00-00 00:00:00");

         --
         -- A utility DB field for post content.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Content_Filtered : UStrings.UString;

         --
         -- ID of a post's parent post.
         --
         -- @since 3.5.0
         -- @var int
         --
         Post_Parent : Post_Id_Type := 0; -- Integer := 0;

         --
         -- The unique identifier for a post, not necessarily a URL, used as the
         -- feed GUID.
         --
         -- @since 3.5.0
         -- @var string
         --
         GUID : UStrings.UString;

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
         Post_Type : UStrings.UString :=
           UStrings.To_UString ("post");

         --
         -- An attachment's mime type.
         --
         -- @since 3.5.0
         -- @var string
         --
         Post_Mime_Type : UStrings.UString;

         --
         -- Cached comment count.
         --
         -- A numeric string, for compatibility reasons.
         --
         -- @since 3.5.0
         -- @var string
         --
         Comment_Count : UStrings.UString;

         --
         -- Stores the post object's sanitization level.
         --
         -- Does not correspond to a DB field.
         --
         -- @since 3.5.0
         -- @var string
         --
         Filter : UStrings.UString;

         -- Added by jq
         Props         : Property_Type;
         Post_Category : UStrings.UString; -- obsolete
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
   procedure Get_Instance (Id      : Post_Id_Type;
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
   function X_Get (Post : Wp_Post;
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
     (Id          => 0,
      Post_Author => 0,
      Post_Parent => 0,
      Menu_Order  => 0,
      Props       => Null_Property_Type,
      others      => UStrings.Null_UString);

-- type Wp_Post_Array is array (Positive range <>) of Wp_Post;

-- Empty_Wp_Post_Array : constant Wp_Post_Array := (1 .. 0 => Null_Post);

   ----------------
   -- Post_Array --
   ----------------

   package Post_Arrays is new
      Ada.Containers.Vectors (Index_Type   => Post_Id_Type, -- Positive,
                              Element_Type => Wp_Post);

   subtype Post_Array is Post_Arrays.Vector;

   Empty_Post_Array : constant Post_Array := Post_Arrays.Empty_Vector;

end Class_Posts;
