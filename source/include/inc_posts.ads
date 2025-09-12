with Arrays;

with Inc_Class_Posts;
with Inc_Class_Wp_Post_Type;

package Inc_Posts
is
   use Arrays;
   use Inc_Class_Posts;

--
-- Retrieves the post type of the current post or of a given post.
--
-- @since 2.1.0
--
-- @param int|WP_Post|null $post Optional. Post ID or post object. Default is global $post.
-- @return string|false          Post type on success, false on failure.
--
   function Get_Post_Type (Post : Integer := 0) -- := null )
                           return String is ("XXX-250");
   function Get_Post_Type (Post : Wp_Post) -- := null )
                           return String is ("XXX-251");

--
-- Retrieves a post type object by name.
--
-- @since 3.0.0
-- @since 4.6.0 Object returned is now an instance of `WP_Post_Type`.
--
-- @global array $wp_post_types List of post types.
--
-- @see register_post_type()
--
-- @param string $post_type The name of a registered post type.
-- @return WP_Post_Type|null WP_Post_Type object if it exists, null otherwise.
--
  function Get_Post_Type_Object (Post_Type : String) return Wp_Post;
  function Get_Post_Type_Object (Post_Type : String)
                                 return Inc_Class_Wp_Post_Type.Wp_Post_Type;

--
-- Retrieves a post status object by name.
--
-- @since 3.0.0
--
-- @global stdClass[] $wp_post_statuses List of post statuses.
--
-- @see register_post_status()
--
-- @param string $post_status The name of a registered post status.
-- @return stdClass|null A post status object.
--
   function Get_Post_Status_Object (Post_Status : String)
                                    return Array_Type
                                    is (Empty_Array);

--
-- Retrieves post data given a post ID or post object.
--
-- See sanitize_post() for optional $filter values. Also, the parameter
-- `$post`, must be given as a variable, since it is passed by reference.
--
-- @since 1.5.1
--
-- @global WP_Post $post Global post object.
--
-- @param int|WP_Post|null $post   Optional. Post ID or post object. `null`, `false`, `0` and other PHP falsey values
--                                 return the current global post inside the loop. A numerically valid post ID that
--                                 points to a non-existent post returns `null`. Defaults to global $post.
-- @param string           $output Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
--                                 correspond to a WP_Post object, an associative array, or a numeric array,
--                                 respectively. Default OBJECT.
-- @param string           $filter Optional. Type of filter to apply. Accepts 'raw', 'edit', 'db',
--                                 or 'display'. Default 'raw'.
-- @return WP_Post|array|null Type corresponding to $output on success or null on failure.
--                            When $output is OBJECT, a `WP_Post` instance is returned.
--
   function Get_Post (Post   : Wp_Post; -- = null,
                      Output : String := "OBJECT"; --  = OBJECT,
                      Filter : String := "raw")
                      return Wp_Post;
   function Get_Post (Post   : Integer;
                      Output : String := "OBJECT"; --  = OBJECT,
                      Filter : String := "raw")
                      return Wp_Post;

   --
   -- Sanitizes every post field.
   --
   -- If the context is 'raw', then the post object or array will get minimal
   -- sanitization of the integer fields.
   --
   -- @since 2.3.0
   --
   -- @see sanitize_post_field()
   --
   -- @param object|WP_Post|array $post    The post object or array
   -- @param string               $context Optional. How to sanitize post fields.
   --                                      Accepts 'raw', 'edit', 'db', 'display',
   --                                      'attribute', or 'js'. Default 'display'.
   -- @return object|WP_Post|array The now sanitized post object or array (will be the
   --                              same type as `$post`).
   --
   function Sanitize_Post (Post    : Inc_Class_Posts.Wp_Post;
                           Context : String := "display")
                           return Inc_Class_Posts.Wp_Post;
--   function Sanitize_Post (Key    : String;
--                           Post   : Array_Type;
--                           Id     : Integer; -- Inc_Class_Posts.Post_Id;
--                           Filter : String := "display")
--                           return Array_Type;

--
-- Sanitizes a post field based on context.
--
-- Possible context values are:  'raw', 'edit', 'db', 'display', 'attribute' and
-- 'js'. The 'display' context is used by default. 'attribute' and 'js' contexts
-- are treated like 'display' when calling filters.
--
-- @since 2.3.0
-- @since 4.4.0 Like `sanitize_post()`, `$context` defaults to 'display'.
--
-- @param string $field   The Post Object field name.
-- @param mixed  $value   The Post Object value.
-- @param int    $post_id Post ID.
-- @param string $context Optional. How to sanitize the field. Possible values are 'raw', 'edit',
--                        'db', 'display', 'attribute' and 'js'. Default 'display'.
-- @return mixed Sanitized value.
--
   function Sanitize_Post_Field (Field   : String;
                                 Value   : Array_Type; -- Inc_Class_Posts.Wp_Post;
                                 Post_Id : Inc_Class_Posts.Post_Id;
                                 Context : String := "display")
                                 return Array_Type;
--
-- Retrieves the IDs of the ancestors of a post.
--
-- @since 2.5.0
--
-- @param int|WP_Post $post Post ID or post object.
-- @return int[] Array of ancestor IDs or empty array if there are none.
--
   -- type Post_Id_List is array (Positive range <>) of Inc_Class_Posts.Post_Id;

   function Get_Post_Ancestors (Post : Inc_Class_Posts.Wp_Post)
                                return Array_Type;  -- return Post_Id_List;

--
-- Retrieves a post meta field for the given post ID.
--
-- @since 1.5.0
--
-- @param int    $post_id Post ID.
-- @param string $key     Optional. The meta key to retrieve. By default,
--                        returns data for all keys. Default empty.
-- @param bool   $single  Optional. Whether to return a single value.
--                        This parameter has no effect if `$key` is not specified.
--                        Default false.
-- @return mixed An array of values if `$single` is false.
--               The value of the meta field if `$single` is true.
--               False for an invalid `$post_id` (non-numeric, zero, or negative value).
--               An empty string if a valid but non-existing post ID is passed.
--
   function Get_Post_Meta (Post_Id : Inc_Class_Posts.Post_Id;
                           Key     : String  := "";
                           Single  : Boolean := False)
                           return Array_Type; -- Post_Id_List;

--
-- Retrieves the URL for an attachment.
--
-- @since 2.1.0
--
-- @global string $pagenow The filename of the current screen.
--
-- @param int $attachment_id Optional. Attachment post ID. Defaults to global $post.
-- @return string|false Attachment URL, otherwise false.
--
   function Wp_Get_Attachment_Url (Attachment_Id : Integer := 0)
                                   return String
                                   is ("XXX-209");



-- By jq
   function Get (Post  : Wp_Post;
                 Field : String)
                 return Array_Type is (Empty_Array);

   procedure Set (Post  : in out Wp_Post;
                  Field : String;
                  Value : Array_Type) is null;

   procedure Set (Post  : in out Wp_Post;
                  Field : String;
                  Value : String) is null;

end Inc_Posts;
