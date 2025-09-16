
--
-- Core User API
--
-- @package WordPress
-- @subpackage Users
--

with Inc_Class_Wp_Users;

package Inc_Users
is
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
