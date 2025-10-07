--
-- Core User Role & Capabilities API
--
-- @package WordPress
-- @subpackage Users
--

with Arrays;

with Inc_Class_Wp_Posts;

package Inc_Capabilities
is
   use Arrays;

   procedure Dummy;

   --
   -- Returns whether the current user has the specified capability.
   --
   -- This function also accepts an ID of an object to check against if the capability
   -- is a meta capability. Meta capabilities such as `edit_post` and `edit_user` are
   -- capabilities used by the `map_meta_cap()` function to map to primitive
   -- capabilities that a user or role has, such as `edit_posts` and
   -- `edit_others_posts`.
   --
   -- Example usage:
   --
   --     current_user_can( 'edit_posts' );
   --     current_user_can( 'edit_post', post.ID );
   --     current_user_can( 'edit_post_meta', post.ID, meta_key );
   --
   -- While checking against particular roles in place of a capability is supported
   -- in part, this practice is discouraged as it may produce unreliable results.
   --
   -- Note: Will always return true if the current user is a super admin, unless
   -- specifically denied.
   --
   -- @since 2.0.0
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   -- @since 5.8.0 Converted to wrapper for the user_can() function.
   --
   -- @see WP_User::has_cap()
   -- @see map_meta_cap()
   --
   -- @param string capability Capability name.
   -- @param mixed  ...args    Optional further parameters, typically starting with
   --                          an object ID.
   -- @return bool Whether the current user has the given capability. If `capability`
   --              is a meta cap and `object_id` is passed, whether the current user
   --              has the given meta capability for the given object.
   --
--   function Current_User_Can (Capability : String)
--                              --, ...args )
--                              return Boolean;
--   function Current_User_Can (Trait : Boolean) return Boolean;
--   function Current_User_Can (Capability : String; Val : Array_Type)
--                              return Boolean
--                              is (True);
   -- function Current_User_Can (Capability : String; Val : Assoc_Type)
   --                            return Boolean
   --                            is (True);
   function Current_User_Can (Capability : String; Val : String)
                              return Boolean
                              is (True);
   function Current_User_Can (Capability : String; Val : Integer)
                              return Boolean
                              is (True);
   function Current_User_Can (Capability : String)
                              return Boolean
                              is (True);
   function Current_User_Can (Capability : String; Val : Inc_Class_Wp_Posts.Wp_Post)
                              return Boolean
                              is (True);

end Inc_Capabilities;
