with Arrays;

with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;

package Inc_Posts
is
   use Arrays;
   use Inc_Class_Wp_Posts;

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
-- Determines whether a post type is registered.
--
-- For more information on this and similar theme functions, check out
-- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 3.0.0
--
-- @see get_post_type_object()
--
-- @param string $post_type Post type name.
-- @return bool Whether post type is registered.
--
   function Post_Type_Exists (Post_Type : String)
                              return Boolean
                              is (True);

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
  function Get_Post_Type_Object (Post_Type : String)
                                 return Boolean
                                 is (True);
--
-- Gets a list of all registered post type objects.
--
-- @since 2.9.0
--
-- @global array $wp_post_types List of post types.
--
-- @see register_post_type() for accepted arguments.
--
-- @param array|string $args     Optional. An array of key => value arguments to match against
--                               the post type objects. Default empty array.
-- @param string       $output   Optional. The type of output to return. Accepts post type 'names'
--                               or 'objects'. Default 'names'.
-- @param string       $operator Optional. The logical operation to perform. 'or' means only one
--                               element from the array needs to match; 'and' means all elements
--                               must match; 'not' means no elements may match. Default 'and'.
-- @return string[]|WP_Post_Type[] An array of post type names or objects.
--
   function Get_Post_Types (Args     : Array_Type := Empty_Array;
                            Output   : String     := "names";
                            Operator : String     := "and")
                            return Inc_Class_Wp_Post_Type.Wp_Post_Type_Array;
   function Get_Post_Types (Args     : Array_Type := Empty_Array;
                            Output   : String     := "names";
                            Operator : String     := "and")
                            return String_Array
                            is (Empty_String_Array);

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
-- Updates a post with new post data.
--
-- The date does not have to be set for drafts. You can set the date and it will
-- not be overridden.
--
-- @since 1.0.0
-- @since 3.5.0 Added the `$wp_error` parameter to allow a WP_Error to be returned on failure.
-- @since 5.6.0 Added the `$fire_after_hooks` parameter.
--
-- @param array|object $postarr          Optional. Post data. Arrays are expected to be escaped,
--                                       objects are not. See wp_insert_post() for accepted arguments.
--                                       Default array.
-- @param bool         $wp_error         Optional. Whether to return a WP_Error on failure. Default false.
-- @param bool         $fire_after_hooks Optional. Whether to fire the after insert hooks. Default true.
-- @return int|WP_Error The post ID on success. The value 0 or WP_Error on failure.
--
   function Wp_Update_Post (Postarr          : Array_Type := Empty_Array;
                            wp_error         : Boolean    := False;
                            Fire_After_Hooks : Boolean    := True)
                            return Integer
                            is (1);

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
   function Sanitize_Post (Post    : Inc_Class_Wp_Posts.Wp_Post;
                           Context : String := "display")
                           return Inc_Class_Wp_Posts.Wp_Post;
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
                                 Post_Id : Inc_Class_Wp_Posts.Post_Id;
                                 Context : String := "display")
                                 return Array_Type;
--
-- Restores a post from the Trash.
--
-- @since 2.9.0
-- @since 5.6.0 An untrashed post is now returned to 'draft' status by default, except for
--              attachments which are returned to their original 'inherit' status.
--
-- @param int $post_id Optional. Post ID. Default is the ID of the global `$post`.
-- @return WP_Post|false|null Post data on success, false or null on failure.
--
   function Wp_Untrash_Post (Post_Id : Integer := 0)
                             return Wp_Post;
   function Wp_Untrash_Post (Item : Assoc_Type) return Boolean is (True);
   function Wp_Untrash_Post (Item : String) return Boolean is (True);
   function Wp_Untrash_Post (Item : Inc_Class_Wp_Posts.Wp_Post)
                             return Boolean is (True);

--
-- Retrieves the IDs of the ancestors of a post.
--
-- @since 2.5.0
--
-- @param int|WP_Post $post Post ID or post object.
-- @return int[] Array of ancestor IDs or empty array if there are none.
--
   -- type Post_Id_List is array (Positive range <>) of Inc_Class_Posts.Post_Id;

   function Get_Post_Ancestors (Post : Inc_Class_Wp_Posts.Wp_Post)
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
   function Get_Post_Meta (Post_Id : Inc_Class_Wp_Posts.Post_Id;
                           Key     : String  := "";
                           Single  : Boolean := False)
                           return Array_Type; -- Post_Id_List;

--
-- Updates a post meta field based on the given post ID.
--
-- Use the `$prev_value` parameter to differentiate between meta fields with the
-- same key and post ID.
--
-- If the meta field for the post does not exist, it will be added and its ID returned.
--
-- Can be used in place of add_post_meta().
--
-- @since 1.5.0
--
-- @param int    $post_id    Post ID.
-- @param string $meta_key   Metadata key.
-- @param mixed  $meta_value Metadata value. Must be serializable if non-scalar.
-- @param mixed  $prev_value Optional. Previous value to check before updating.
--                           If specified, only update existing metadata entries with
--                           this value. Otherwise, update all entries. Default empty.
-- @return int|bool Meta ID if the key didn't exist, true on successful update,
--                  false on failure or if the value passed to the function
--                  is the same as the one that is already in the database.
--
   function Update_Post_Meta (Post_Id    : Integer;
                              Meta_Key   : String;
                              Meta_Value : Array_Type;
                              Prev_Value : Array_Type := Empty_Array) -- = '' )
                              return Integer
                              is (1);

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
