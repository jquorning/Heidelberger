--
-- WordPress Post Administration API.
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;

with Class_Posts;
with Class_Users;

package Adi_Posts
is
   use Arrays;

   --
   -- Returns the list of classes to be used by a meta box.
   --
   -- @since 2.5.0
   --
   -- @param string box_id    Meta box ID (used in the "id" attribute for the meta
   --                         box).
   -- @param string screen_id The screen on which the meta box is shown.
   -- @return string Space-separated string of class names.
   --
   function Postbox_Classes (Box_Id    : String;
                             Screen_Id : String)
                             return String;

   --
   -- Processes the post data for the bulk editing of posts.
   --
   -- Updates all bulk edited posts/pages, adding (but not removing) tags and
   -- categories. Skips pages when they would be their own parent or child.
   --
   -- @since 2.7.0
   --
   -- @global wpdb $wpdb WordPress database abstraction object.
   --
   -- @param array|null $post_data Optional. The array of post data to process.
   --                              Defaults to the `$_POST` superglobal.
   -- @return array
   --
   function Bulk_Edit_Posts (Post_Data : Array_Type := Empty_Array) -- = null
                             return Array_Type
                             is (Empty_Array);

   --
   -- Updates an existing post with values provided in `$_POST`.
   --
   -- If post data is passed as an argument, it is treated as an array of data
   -- keyed appropriately for turning into a post object.
   --
   -- If post data is not passed, the `$_POST` global variable is used instead.
   --
   -- @since 1.5.0
   --
   -- @global wpdb $wpdb WordPress database abstraction object.
   --
   -- @param array|null $post_data Optional. The array of post data to process.
   --                              Defaults to the `$_POST` superglobal.
   -- @return int Post ID.
   --
   function Edit_Post (Post_Data : Array_Type := Empty_Array) -- = null
                       return Integer
                       is (1);

   --
   -- Calls wp_write_post() and handles the errors.
   --
   -- @since 2.0.0
   --
   -- @return int|void Post ID on success, void on failure.
   --
   function Write_Post
            return Integer
            is (1);

   --
   -- Marks the post as currently being edited by the current user.
   --
   -- @since 2.5.0
   --
   -- @param int|WP_Post $post ID or object of the post being edited.
   -- @return array|false {
   --     Array of the lock time and user ID. False if the post does not exist, or
   --     there is no current user.
   --
   --     @type int $0 The current time as a Unix timestamp.
   --     @type int $1 The ID of the current user.
   -- }
   --
   function Wp_Set_Post_Lock (Post : Integer)
                              return Array_Type
                              is (Empty_Array);

   --
   -- Redirects to previous page.
   --
   -- @since 2.7.0
   --
   -- @param int $post_id Optional. Post ID.
   --
   procedure Redirect_Post (Post_Id : Integer := 0) is null;

   --
   -- Determines whether the post is currently being edited by another user.
   --
   -- @since 2.5.0
   --
   -- @param int|WP_Post $post ID or object of the post to check for editing.
   -- @return int|false ID of the user with lock. False if the post does not exist,
   --                   post is not locked, the user with lock does not exist, or
   --                   the post is locked by current user.
   --
-- function Wp_Check_Post_Lock (Post_Id : Array_Type) return Boolean is (True);
-- function Wp_Check_Post_Lock (Post_Id : Assoc_Type) return Boolean is (True);
   function Wp_Check_Post_Lock (Post_Id : String)
                                return Class_Users.User_Id_Type
                                is (1);

   --
   -- Saves a draft or manually autosaves for the purpose of showing a post preview.
   --
   -- @since 2.7.0
   --
   -- @return string URL to redirect to show the preview.
   --
   function Post_Preview
            return String
            is ("XXX-501");

   --
   -- Prepares server-registered blocks for the block editor.
   --
   -- Returns an associative array of registered block data keyed by block name. Data
   -- includes properties of a block relevant for client registration.
   --
   -- @since 5.0.0
   --
   -- @return array An associative array of registered block data.
   --
   function Get_Block_Editor_Server_Block_Settings
            return Array_Type;

   --
   -- Returns default post information to use when populating the "Write Post" form.
   --
   -- @since 2.0.0
   --
   -- @param string post_type    Optional. A post type string. Default "post".
   -- @param bool   create_in_db Optional. Whether to insert the post into database.
   --                            Default false.
   -- @return WP_Post Post object containing all the default post data as attributes
   --
   function Get_Default_Post_To_Edit (Post_Type    : String := "post";
                                      Create_In_DB : Boolean := False)
                                      return Class_Posts.Wp_Post;

end Adi_Posts;
