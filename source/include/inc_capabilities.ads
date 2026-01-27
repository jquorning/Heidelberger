--
-- Core User Role & Capabilities API
--
-- @package WordPress
-- @subpackage Users
--

with Arrays;
with Lists;

with Class_Role;
with Class_Roles;
with Class_Posts;
with Class_Users;

package Inc_Capabilities
is
   use Arrays;
   use Lists;

   --
   -- Maps a capability to the primitive capabilities required of the given user to
   -- satisfy the capability being checked.
   --
   -- This function also accepts an ID of an object to map against if the capability
   -- is a meta capability. Meta capabilities such as `edit_post` and `edit_user` are
   -- capabilities used by this function to map to primitive capabilities that a user
   -- or role requires, such as `edit_posts` and `edit_others_posts`.
   --
   -- Example usage:
   --
   --     map_meta_cap( 'edit_posts', user.ID );
   --     map_meta_cap( 'edit_post', user.ID, post.ID );
   --     map_meta_cap( 'edit_post_meta', user.ID, post.ID, meta_key );
   --
   -- This function does not check whether the user has the required capabilities,
   -- it just returns what the required capabilities are.
   --
   -- @since 2.0.0
   -- @since 4.9.6 Added the `export_others_personal_data`,
   --              `erase_others_personal_data`, and `manage_privacy_options`
   --               capabilities.
   -- @since 5.1.0 Added the `update_php` capability.
   -- @since 5.2.0 Added the `resume_plugin` and `resume_theme` capabilities.
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   -- @since 5.7.0 Added the `create_app_password`, `list_app_passwords`,
   --              `read_app_password`, `edit_app_password`, `delete_app_passwords`,
   --              `delete_app_password`, and `update_https` capabilities.
   --
   -- @global array post_type_meta_caps Used to get post type meta capabilities.
   --
   -- @param string cap     Capability being checked.
   -- @param int    user_id User ID.
   -- @param mixed  ...args Optional further parameters, typically starting with an
   --                        object ID.
   -- @return string[] Primitive capabilities required of the user.
   --
   type Args_Type is
      record
         Comment_Id : Integer := 0;
         Object_Id  : Integer := 0;
         Post_Id    : Class_Posts.Post_Id := 0;
         Term_Id    : Integer := 0;
         User_Id    : Class_Users.User_Id_Type := 0;
         Meta_Key   : Boolean := False;
      end record;

   Null_Args_Type : constant Args_Type :=
     (Comment_Id => 0,
      Object_Id  => 0,
      Post_Id    => 0,
      Term_Id    => 0,
      User_Id    => 0,
      Meta_Key   => False);

   function Map_Meta_Cap (Cap     : String;
                          User_Id : Class_Users.User_Id_Type;
                          Args    : Args_Type := Null_Args_Type)
                          return List_Type;

   --
   -- Retrieves role object.
   --
   -- @since 2.0.0
   --
   -- @param string role Role name.
   -- @return WP_Role|null WP_Role object if found, null if the role does not exist.
   --
   function Get_Role (Role : String)
                      return Class_Role.Wp_Role;

   --
   -- Adds a role, if it does not exist.
   --
   -- @since 2.0.0
   --
   -- @param string role         Role name.
   -- @param string display_name Display name for role.
   -- @param bool[] capabilities List of capabilities keyed by the capability name,
   --                             e.g. array( "edit_posts" => true,
   --                                         "delete_posts" => false ).
   -- @return WP_Role|void WP_Role object, if the role is added.
   --
   procedure Add_Role (Role         : String;
                       Display_Name : String;
                       Capabilities : Array_Type := Empty_Array);

   --
   -- Retrieves a list of super admins.
   --
   -- @since 3.0.0
   --
   -- @global array super_admins
   --
   -- @return string[] List of super admin logins.
   --
   function Get_Super_Admins
            return List_Type;

   --
   -- Determines whether user is a site admin.
   --
   -- @since 3.0.0
   --
   -- @param int|false user_id Optional. The ID of a user. Defaults to false, to check
   --                           the current user.
   -- @return bool Whether the user is a site admin.
   --
   function Is_Super_Admin (User_Id : Class_Users.User_Id_Type := 0) -- false
                            return Boolean;

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
   function Current_User_Can (Capability : String; Val : Class_Posts.Wp_Post)
                              return Boolean
                              is (True);

   --
   -- Returns whether a particular user has the specified capability.
   --
   -- This function also accepts an ID of an object to check against if the capability
   -- is a meta capability. Meta capabilities such as `edit_post` and `edit_user` are
   -- capabilities used by the `map_meta_cap()` function to map to primitive
   -- capabilities that a user or role has, such as `edit_posts` and
   -- `edit_others_posts`.
   --
   -- Example usage:
   --
   --     user_can( user.ID, 'edit_posts' );
   --     user_can( user.ID, 'edit_post', post.ID );
   --     user_can( user.ID, 'edit_post_meta', post.ID, meta_key );
   --
   -- @since 3.1.0
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   --
   -- @param int|WP_User user       User ID or object.
   -- @param string      capability Capability name.
   -- @param mixed       ...args    Optional further parameters, typically starting
   --                                with an object ID.
   -- @return bool Whether the user has the given capability.
   --
   function User_Can (User       : Class_Users.Wp_User;
                      Capability : String)
                      -- , ...args)
                      return Boolean;
   function User_Can (User       : Class_Users.User_Id_Type;
                      Capability : String)
                      -- , ...args)
                      return Boolean;

   --
   -- Retrieves the global WP_Roles instance and instantiates it if necessary.
   --
   -- @since 4.3.0
   --
   -- @global WP_Roles wp_roles WordPress role management object.
   --
   -- @return WP_Roles WP_Roles global instance if not already instantiated.
   --
   function Wp_Roles_X -- _X added
            return Class_Roles.Wp_Roles;

end Inc_Capabilities;
