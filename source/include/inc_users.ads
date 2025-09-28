
--
-- Core User API
--
-- @package WordPress
-- @subpackage Users
--

with Arrays;

with Inc_Class_Wp_Users;
with Inc_Class_Wp_Admin_Bar;

package Inc_Users
is
   use Arrays;

   procedure Dummy;
--
-- Retrieves user option that can be either per Site or per Network.
--
-- If the user ID is not given, then the current user will be used instead. If
-- the user ID is given, then the user data will be retrieved. The filter for
-- the result, will also pass the original option name and finally the user data
-- object as the third parameter.
--
-- The option will first check for the per site name and then the per Network name.
--
-- @since 2.0.0
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string option     User option name.
-- @param int    user       Optional. User ID.
-- @param string deprecated Use get_option() to check for an option in the options table.
-- @return mixed User option value on success, false on failure.
--
   function Get_User_Option (Option     : String;
                             User       : Integer := 0;
                             Deprecated : String := "")
                             return Boolean
                             is (True);
   function Get_User_Option (Option     : String;
                             User       : Integer := 0;
                             Deprecated : String := "")
                             return String
                             is ("XXX-601");

   --
   -- Retrieves user meta field for a user.
   --
   -- @since 3.0.0
   --
   -- @link https://developer.wordpress.org/reference/functions/get_user_meta/
   --
   -- @param int    user_id User ID.
   -- @param string key     Optional. The meta key to retrieve. By default,
   --                        returns data for all keys.
   -- @param bool   single  Optional. Whether to return a single value.
   --                        This parameter has no effect if `key` is not specified.
   --                        Default false.
   -- @return mixed An array of values if `single` is false.
   --               The value of meta data field if `single` is true.
   --               False for an invalid `user_id` (non-numeric, zero, or negative value).
   --               An empty string if a valid but non-existing user ID is passed.
   --
   function Get_User_Meta (User_Id : Integer;
                           Key     : String  := "";
                           Single  : Boolean := False)
                           return Boolean
                           is (True);

   --
   -- Updates user meta field based on user ID.
   --
   -- Use the prev_value parameter to differentiate between meta fields with the
   -- same key and user ID.
   --
   -- If the meta field for the user does not exist, it will be added.
   --
   -- @since 3.0.0
   --
   -- @link https://developer.wordpress.org/reference/functions/update_user_meta/
   --
   -- @param int    user_id    User ID.
   -- @param string meta_key   Metadata key.
   -- @param mixed  meta_value Metadata value. Must be serializable if non-scalar.
   -- @param mixed  prev_value Optional. Previous value to check before updating.
   --                           If specified, only update existing metadata entries with
   --                           this value. Otherwise, update all entries. Default empty.
   -- @return int|bool Meta ID if the key didn"t exist, true on successful update,
   --                  false on failure or if the value passed to the function
   --                  is the same as the one that is already in the database.
   --
   function Update_User_Meta (User_Id    : Integer;
                              Meta_Key   : String;
                              Meta_Value : Boolean;
                              prev_value : String := "")
                              return Integer
                              is (0);

   procedure Update_User_Meta (User_Id    : Integer;
                               Meta_Key   : String;
                               Meta_Value : Array_Type; -- Boolean;
                               prev_value : String := "")
                               is null;

--
-- Finds out whether a user is a member of a given blog.
--
-- @since MU (3.0.0)
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int user_id Optional. The unique ID of the user. Defaults to the current user.
-- @param int blog_id Optional. ID of the blog to check. Defaults to the current site.
-- @return bool
--
   function Is_User_Member_Of_Blog (User_Id : Integer := 0;
                                    Blog_Id : Integer := 0)
                                    return Boolean
                                    is (True);

--
-- Gets the current user"s ID.
--
-- @since MU (3.0.0)
--
-- @return int The current user"s ID, or 0 if no user is logged in.
--
   function Get_Current_User_Id
            return Integer
            is (1);

--
-- Gets the sites a user belongs to.
--
-- @since 3.0.0
-- @since 4.7.0 Converted to use `get_sites()`.
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param int  user_id User ID
-- @param bool all     Whether to retrieve all sites, or only sites that are not
--                      marked as deleted, archived, or spam.
-- @return object[] A list of the user"s sites. An empty array if the user doesn"t exist
--                  or belongs to no sites.
--
   function Get_Blogs_Of_User (User_Id   : Integer;
                               All_Sites : Boolean := False)
                               return Inc_Class_Wp_Admin_Bar.Blog_List -- String_Array
                               is (Inc_Class_Wp_Admin_Bar.Empty_Blog_List); -- (Empty_String_Array);

--
-- Retrieves the current user object.
--
-- Will set the current user, if the current user is not set. The current user
-- will be set to the logged-in person. If no user is logged-in, then it will
-- set the current user to 0, which is invalid and won"t have any permissions.
--
-- This function is used by the pluggable functions wp_get_current_user() and
-- get_currentuserinfo(), the latter of which is deprecated but used for backward
-- compatibility.
--
-- @since 4.5.0
-- @access private
--
-- @see wp_get_current_user()
-- @global WP_User current_user Checks if the current user is set.
--
-- @return WP_User Current WP_User instance.
--
   function X_Wp_Get_Current_User
            return Inc_Class_Wp_Users.Wp_User;

end Inc_Users;
