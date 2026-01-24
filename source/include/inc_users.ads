--
-- Core User API
--
-- @package WordPress
-- @subpackage Users
--

with Arrays;

with Inc_Class_Wp_Errors;
with Inc_Class_Wp_Users;
with Inc_Class_Wp_Admin_Bar;

package Inc_Users
is
   use Arrays;

   type User_Error_Type is record
      Success : Boolean;
      User    : Inc_Class_Wp_Users.Wp_User;
      Error   : Inc_Class_Wp_Errors.Wp_Error;
   end record;

   type User_Id_Error_Type is record
      Success : Boolean;
      User_Id : Integer;
      Error   : Inc_Class_Wp_Errors.Wp_Error;
   end record;

   type Success_Error_Type is record
      Success : Boolean;
      Error   : Inc_Class_Wp_Errors.Wp_Error;
   end record;

   --
   -- Authenticates and logs a user in with 'remember' capability.
   --
   -- The credentials is an array that has 'user_login', 'user_password', and
   -- 'remember' indices. If the credentials is not given, then the log in form
   -- will be assumed and used if set.
   --
   -- The various authentication cookies will be set by this function and will be
   -- set for a longer period depending on if the 'remember' credential is set to
   -- true.
   --
   -- Note: wp_signon() doesn't handle setting the current user. This means that if the
   -- function is called before the {@see "init"} hook is fired, is_user_logged_in()
   -- will evaluate as false until that point. If is_user_logged_in() is needed in
   -- conjunction with wp_signon(), wp_set_current_user() should be called explicitly.
   --
   -- @since 2.5.0
   --
   -- @global string auth_secure_cookie
   --
   -- @param array       credentials   Optional. User info in order to sign on.
   -- @param string|bool secure_cookie Optional. Whether to use secure cookie.
   -- @return WP_User|WP_Error WP_User on success, WP_Error on failure.
   --
   function Wp_Signon (Credentials   : Array_Type := Empty_Array;
                       Secure_Cookie : Boolean    := False) -- String := ""
                       return User_Error_Type;

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
   -- @param string deprecated Use get_option() to check for an option in the
   --                          options table.
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

   function Get_User_Option (Option     : String;
                             User       : Integer := 0;
                             Deprecated : String := "")
                             return Natural
                             is (999);

   function Get_User_Option (Option     : String;
                             User       : Integer := 0;
                             Deprecated : String := "")
                             return Array_Type
                             is (Empty_Array);

   --
   -- Updates user option with global blog capability.
   --
   -- User options are just like user metadata except that they have support for
   -- global blog options. If the "global" parameter is false, which it is by default
   -- it will prepend the WordPress table prefix to the option name.
   --
   -- Deletes the user option if newvalue is empty.
   --
   -- @since 2.0.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int    user_id     User ID.
   -- @param string option_name User option name.
   -- @param mixed  newvalue    User option value.
   -- @param bool   global      Optional. Whether option name is global or blog
   --                            specific. Default false (blog specific).
   -- @return int|bool User meta ID if the option didn't exist, true on successful
   --                  update, false on failure.
   --
   procedure Update_User_Option (User_Id     : Integer;
                                 Option_Name : String;
                                 Newvalue    : Multi_Type;
                                 Global      : Boolean := False)
                                 is null;

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
   --               False for an invalid `user_id` (non-numeric, zero, or negative
   --               value). An empty string if a valid but non-existing user ID is
   --               passed.
   --
   function Get_User_Meta (User_Id : Integer;
                           Key     : String  := "";
                           Single  : Boolean := False)
                           return Boolean
                           is (True);

   function Get_User_Meta (User_Id : Integer;
                           Key     : String  := "";
                           Single  : Boolean := False)
                           return Array_Type
                           is (Empty_Array);

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
   --                           If specified, only update existing metadata entries
   --                           with this value. Otherwise, update all entries.
   --                           Default empty.
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

   procedure Update_User_Meta (User_Id    : Integer;
                               Meta_Key   : String;
                               Meta_Value : Integer;
                               prev_value : String := "")
                               is null;

   --
   -- Updates a user in the database.
   --
   -- It is possible to update a user's password by specifying the "user_pass"
   -- value in the userdata parameter array.
   --
   -- If current user's password is being updated, then the cookies will be
   -- cleared.
   --
   -- @since 2.0.0
   --
   -- @see wp_insert_user() For what fields can be set in userdata.
   --
   -- @param array|object|WP_User userdata An array of user data or a user object
   --                                       of type stdClass or WP_User.
   -- @return int|WP_Error The updated user's ID or a WP_Error object if the user
   --                       could not be updated.
   --
   function Wp_Update_User (Userdata : Inc_Class_Wp_Users.Wp_User)
                            return Integer
                            is (raise Program_Error with "not implemented");

   procedure Wp_Update_User (Userdata : Inc_Class_Wp_Users.Wp_User)
   is null;

   --
   -- Provides a simpler way of inserting a user into the database.
   --
   -- Creates a new user with just the username, password, and email. For more
   -- complex user creation use wp_insert_user() to specify more information.
   --
   -- @since 2.0.0
   --
   -- @see wp_insert_user() More complete way to create a new user.
   --
   -- @param string username The user's username.
   -- @param string password The user's password.
   -- @param string email    Optional. The user's email. Default empty.
   -- @return int|WP_Error The newly created user's ID or a WP_Error object if
   --                      the user could not be created.
   --
   function Wp_Create_User (Username : String;
                            Password : String;
                            Email    : String := "")
                            return Integer;

   --
   -- Retrieves a user row based on password reset key and login.
   --
   -- A key is considered "expired" if it exactly matches the value of the
   -- user_activation_key field, rather than being matched after going through the
   -- hashing process. This field is now hashed; old values are no longer accepted
   -- but have a different WP_Error code so good user feedback can be provided.
   --
   -- @since 3.1.0
   --
   -- @global wpdb         wpdb      WordPress database object for queries.
   -- @global PasswordHash wp_hasher Portable PHP password hashing framework instance.
   --
   -- @param string key       Hash to validate sending user"s password.
   -- @param string login     The user login.
   -- @return WP_User|WP_Error WP_User object on success, WP_Error object for invalid
   --                          or expired keys.
   --
   function Check_Password_Reset_Key (Key   : String;
                                      Login : String)
                                      return User_Error_Type;

   --
   -- Finds out whether a user is a member of a given blog.
   --
   -- @since MU (3.0.0)
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int user_id Optional. The unique ID of the user. Defaults to the
   --                               current user.
   -- @param int blog_id Optional. ID of the blog to check. Defaults to the
   --                               current site.
   -- @return bool
   --
   function Is_User_Member_Of_Blog (User_Id : Integer := 0;
                                    Blog_Id : Integer := 0)
                                    return Boolean
                                    is (True);

   --
   -- Gets the text suggesting how to create strong passwords.
   --
   -- @since 4.1.0
   --
   -- @return string The password hint text.
   --
   function Wp_Get_Password_Hint
            return String;

   --
   -- Handles sending a password retrieval email to a user.
   --
   -- @since 2.5.0
   -- @since 5.7.0 Added `user_login` parameter.
   --
   -- @global wpdb         wpdb       WordPress database abstraction object.
   -- @global PasswordHash wp_hasher  Portable PHP password hashing framework.
   --
   -- @param string user_login Optional. Username to send a password retrieval email
   --                           for. Defaults to `_POST["user_login"]` if not set.
   -- @return true|WP_Error True when finished, WP_Error object on error.
   --
   function Retrieve_Password (User_Login : String := "") -- null
                               return Success_Error_Type;

   --
   -- Handles resetting the user's password.
   --
   -- @since 2.5.0
   --
   -- @param WP_User user     The user
   -- @param string  new_pass New password for the user in plaintext
   --
   procedure Reset_Password (User     : Inc_Class_Wp_Users.Wp_User;
                             New_Pass : String);

   --
   -- Handles registering a new user.
   --
   -- @since 2.5.0
   --
   -- @param string user_login User's username for logging in
   -- @param string user_email User's email address to send password and add
   -- @return int|WP_Error Either user's ID or error on failure.
   --
   function Register_New_User (User_Login : String;
                               User_Email : String)
                               return User_Id_Error_Type;

   --
   -- Retrieves the current session token from the logged_in cookie.
   --
   -- @since 4.0.0
   --
   -- @return string Token.
   --
   function Wp_Get_Session_Token
            return String;

   --
   -- Removes the current session token from the database.
   --
   -- @since 4.0.0
   --
   procedure Wp_Destroy_Current_Session;

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
   -- @return object[] A list of the user"s sites. An empty array if the user doesn't
   --                  exist or belongs to no sites.
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

   --
   -- Updates the total count of users on the site.
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   -- @since 6.0.0
   --
   -- @param int|null network_id ID of the network. Defaults to the current network.
   -- @return bool Whether the update was successful.
   --
   function Wp_Update_User_Counts (Network_Id : Integer := 0) -- null
                                   return Boolean;

   procedure Wp_Update_User_Counts (Network_Id : Integer := 0); -- null

   --
   -- Sets up global user vars.
   --
   -- Used by wp_set_current_user() for back compat. Might be deprecated in the future.
   --
   -- @since 2.0.4
   --
   -- @global string  user_login    The user username for logging in
   -- @global WP_User userdata      User data.
   -- @global int     user_level    The level of the user
   -- @global int     user_ID       The ID of the user
   -- @global string  user_email    The email address of the user
   -- @global string  user_url      The url in the user"s profile
   -- @global string  user_identity The display name of the user
   --
   -- @param int for_user_id Optional. User ID to set up global data. Default 0.
   --
   procedure Setup_Userdata (For_User_Id : Integer := 0);

   --
   -- Updates all user caches.
   --
   -- @since 3.0.0
   --
   -- @param object|WP_User user User object or database row to be cached
   -- @return void|false Void on success, false on failure.
   --
   procedure Update_User_Caches (User : Inc_Class_Wp_Users.Wp_User);

   --
   -- Determines whether the given username exists.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 2.0.0
   --
   -- @param string username The username to check for existence.
   -- @return int|false The user ID on success, false on failure.
   --
   function Username_Exists (Username : String)
                             return Integer;

   --
   -- Inserts a user into the database.
   --
   -- Most of the `userdata` array fields have filters associated with the values.
   -- Exceptions are "ID", "rich_editing", "syntax_highlighting", "comment_shortcuts",
   -- "admin_color", "use_ssl", "user_registered", "user_activation_key", "spam", and
   -- "role". The filters have the prefix "pre_user_" followed by the field name. An
   -- example using "description" would have the filter called "pre_user_description"
   -- that can be hooked into.
   --
   --
   -- @since 2.0.0
   -- @since 3.6.0 The `aim`, `jabber`, and `yim` fields were removed as default user
   --              contact methods for new installations. See
   --              wp_get_user_contact_methods().
   -- @since 4.7.0 The `locale` field can be passed to `userdata`.
   -- @since 5.3.0 The `user_activation_key` field can be passed to `userdata`.
   -- @since 5.3.0 The `spam` field can be passed to `userdata` (Multisite only).
   -- @since 5.9.0 The `meta_input` field can be passed to `userdata` to allow
   --              addition of user meta data.
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param array|object|WP_User userdata {
   --     An array, object, or WP_User object of user data arguments.
   --
   --     @type int    ID                   User ID. If supplied, the user will be
   --                                        updated.
   --     @type string user_pass            The plain-text user password.
   --     @type string user_login           The user's login username.
   --     @type string user_nicename        The URL-friendly user name.
   --     @type string user_url             The user URL.
   --     @type string user_email           The user email address.
   --     @type string display_name         The user's display name.
   --                                        Default is the user"s username.
   --     @type string nickname             The user's nickname.
   --                                        Default is the user"s username.
   --     @type string first_name           The user's first name. For new users, will
   --                                        be used to build the first part of the
   --                                        user's display name if `display_name` is
   --                                        not specified.
   --     @type string last_name            The user's last name. For new users, will
   --                                        be used to build the second part of the
   --                                        user's display name if `display_name` is
   --                                        not specified.
   --     @type string description          The user's biographical description.
   --     @type string rich_editing         Whether to enable the rich-editor for the
   --                                        user. Accepts "true" or "false" as a
   --                                        string literal, not boolean. Default
   --                                        "true".
   --     @type string syntax_highlighting  Whether to enable the rich code editor for
   --                                        the user. Accepts "true" or "false" as a
   --                                        string literal, not boolean. Default
   --                                        "true".
   --     @type string comment_shortcuts    Whether to enable comment moderation
   --                                        keyboard shortcuts for the user. Accepts
   --                                        "true" or "false" as a string literal,
   --                                        not boolean. Default "false".
   --     @type string admin_color          Admin color scheme for the user. Default
   --                                        "fresh".
   --     @type bool   use_ssl              Whether the user should always access the
   --                                        admin over https. Default false.
   --     @type string user_registered      Date the user registered in UTC. Format
   --                                        is "Y-m-d H:i:s".
   --     @type string user_activation_key  Password reset key. Default empty.
   --     @type bool   spam                 Multisite only. Whether the user is marked
   --                                        as spam. Default false.
   --     @type string show_admin_bar_front Whether to display the Admin Bar for the
   --                                        user on the site"s front end. Accepts
   --                                        "true" or "false" as a string literal,
   --                                        not boolean. Default "true".
   --     @type string role                 User's role.
   --     @type string locale               User's locale. Default empty.
   --     @type array  meta_input           Array of custom user meta values keyed by
   --                                        meta key. Default empty.
   -- }
   -- @return int|WP_Error The newly created user's ID or a WP_Error object if the
   --                      user could not be created.
   --
   function Wp_Insert_User (Userdata : Array_Type)
                            return Integer;

   --
   -- Returns request confirmation message HTML.
   --
   -- @since 4.9.6
   -- @access private
   --
   -- @param int request_id The request ID being confirmed.
   -- @return string The confirmation message.
   --
   function X_Wp_Privacy_Account_Request_Confirmed_Message
              (Request_Id : Integer)
              return String;

   --
   -- Validates a user request by comparing the key with the request's key.
   --
   -- @since 4.9.6
   --
   -- @param string request_id ID of the request being confirmed.
   -- @param string key        Provided key to validate.
   -- @return true|WP_Error True on success, WP_Error on failure.
   --
   function Wp_Validate_User_Request_Key (Request_Id : String;
                                          Key        : String)
                                          return Success_Error_Type;

end Inc_Users;
