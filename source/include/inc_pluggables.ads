
--
-- These functions can be replaced via plugins. If plugins do not redefine these
-- functions, then these will be used instead.
--
-- @package WordPress
--

with Arrays;
with Lists;

with Inc_Class_Wp_Users;
with Inc_Users;

package Inc_Pluggables
is
   use Arrays;
   use Lists;

   --
   -- Changes the current user by ID or name.
   --
   -- Set id to null and specify a name if you do not know a user's ID.
   --
   -- Some WordPress functionality is based on the current user and not based on
   -- the signed in user. Therefore, it opens the ability to edit and perform
   -- actions on users who aren't signed in.
   --
   -- @since 2.0.3
   --
   -- @global WP_User current_user The current user object which holds the user data.
   --
   -- @param int|null id   User ID.
   -- @param string   name User's username.
   -- @return WP_User Current user User object.
   --
   function Wp_Set_Current_User (Id   : Integer;
                                 Name : String := "")
                                 return Inc_Class_Wp_Users.Wp_User;

   procedure Wp_Set_Current_User (Id   : Integer;
                                  Name : String := "");

   --
   -- Retrieves the current user object.
   --
   -- Will set the current user, if the current user is not set. The current user
   -- will be set to the logged-in person. If no user is logged-in, then it will
   -- set the current user to 0, which is invalid and won't have any permissions.
   --
   -- @since 2.0.3
   --
   -- @see _wp_get_current_user()
   -- @global WP_User current_user Checks if the current user is set.
   --
   -- @return WP_User Current WP_User instance.
   --
   function Wp_Get_Current_User
            return Inc_Class_Wp_Users.Wp_User;

   --
   -- Retrieves user info by user ID.
   --
   -- @since 0.71
   --
   -- @param int user_id User ID
   -- @return WP_User|false WP_User object on success, false on failure.
   --
   function Get_Userdata (User_Id : Integer)
                          return Inc_Class_Wp_Users.Wp_User;

   --
   -- Retrieves user info by a given field.
   --
   -- @since 2.8.0
   -- @since 4.4.0 Added 'ID' as an alias of 'id' for the `field` parameter.
   --
   -- @global WP_User current_user The current user object which holds the user data.
   --
   -- @param string     field The field to retrieve the user with.
   --                          id | ID | slug | email | login.
   -- @param int|string value A value for field. A user ID, slug, email address, or
   --                          login name.
   -- @return WP_User|false WP_User object on success, false on failure.
   --
   function Get_User_By (Field : String;
                         Value : Integer)
                         return Inc_Class_Wp_Users.Wp_User;

   function Get_User_By (Field : String;
                         Value : String)
                         return Inc_Class_Wp_Users.Wp_User
                         is (raise Program_Error with "not implemented");

   --
   -- Redirects to another page.
   --
   -- Note: wp_redirect() does not exit automatically, and should almost always be
   -- followed by a call to `exit;`:
   --
   --     wp_redirect( url );
   --     exit;
   --
   -- Exiting can also be selectively manipulated by using wp_redirect() as a
   -- conditional in conjunction with the {@see 'wp_redirect'} and
   --  {@see 'wp_redirect_location'} filters:
   --
   --     if ( wp_redirect( url ) ) {
   --         exit;
   --     }
   --
   -- @since 1.5.1
   -- @since 5.1.0 The `x_redirect_by` parameter was added.
   -- @since 5.4.0 On invalid status codes, wp_die() is called.
   --
   -- @global bool is_IIS
   --
   -- @param string location      The path or URL to redirect to.
   -- @param int    status        Optional. HTTP response status code to use.
   --                             Default '302' (Moved Temporarily).
   -- @param string x_redirect_by Optional. The application doing the redirect.
   --                             Default 'WordPress'.
   -- @return bool False if the redirect was cancelled, true otherwise.
   --
   function Wp_Redirect (Location      : String;
                         Status        : Integer := 302;
                         X_Redirect_By : String  := "WordPress")
                         return Boolean;

   procedure Wp_Redirect (Location      : String;
                          Status        : Integer := 302;
                          X_Redirect_By : String  := "WordPress");

   --
   -- Sanitizes a URL for use in a redirect.
   --
   -- @since 2.3.0
   --
   -- @param string location The path to redirect to.
   -- @return string Redirect-sanitized URL.
   --
   function Wp_Sanitize_Redirect (Location : String)
                                  return String;

   --
   -- URL encodes UTF-8 characters in a URL.
   --
   -- @ignore
   -- @since 4.2.0
   -- @access private
   --
   -- @see wp_sanitize_redirect()
   --
   -- @param array matches RegEx matches against the redirect location.
   -- @return string URL-encoded version of the first RegEx match.
   --
   function X_Wp_Sanitize_UTF8_In_Redirect (Matches : List_Type)
                                            return String;

   --
   -- Validates a URL for use in a redirect.
   --
   -- Checks whether the location is using an allowed host, if it has an absolute
   -- path. A plugin can therefore set or remove allowed host(s) to or from the
   -- list.
   --
   -- If the host is not allowed, then the redirect is to default supplied.
   --
   -- @since 2.8.1
   --
   -- @param string location The redirect to validate.
   -- @param string default  The value to return if location is not allowed.
   -- @return string redirect-sanitized URL.
   --
   function Wp_Validate_Redirect (Location : String;
                                  Default  : String := "")
                                  return String;

   --
   -- Creates a cryptographic token tied to a specific action, user, user session,
   -- and window of time.
   --
   -- @since 2.0.3
   -- @since 4.0.0 Session tokens were integrated with nonce creation.
   --
   -- @param string|int action Scalar value to add context to the nonce.
   -- @return string The token.
   --
   function Wp_Create_Nonce (Action : Integer := -1)
            return String;

   function Wp_Create_Nonce (Action : String)
            return String;

   --
   -- Returns the time-dependent variable for nonce creation.
   --
   -- A nonce has a lifespan of two ticks. Nonces in their second tick may be
   -- updated, e.g. by autosave.
   --
   -- @since 2.5.0
   -- @since 6.1.0 Added `action` argument.
   --
   -- @param string|int action Optional. The nonce action. Default -1.
   -- @return float Float value rounded up to the next highest integer.
   --
   function Wp_Nonce_Tick (Action : Integer := -1)
                           return Float;

   --
   -- Authenticates a user, confirming the login credentials are valid.
   --
   -- @since 2.5.0
   -- @since 4.5.0 `username` now accepts an email address.
   --
   -- @param string username User's username or email address.
   -- @param string password User's password.
   -- @return WP_User|WP_Error WP_User object if the credentials are valid,
   --                          otherwise WP_Error.
   --
   function Wp_Authenticate (Username : String;
                             Password : String)
                             return Inc_Users.User_Error_Type;

   --
   -- Logs the current user out.
   --
   -- @since 2.5.0
   --
   procedure Wp_Logout;

   --
   -- Validates authentication cookie.
   --
   -- The checks include making sure that the authentication cookie is set and
   -- pulling in the contents (if cookie is not used).
   --
   -- Makes sure the cookie is not expired. Verifies the hash in cookie is what is
   -- should be and compares the two.
   --
   -- @since 2.5.0
   --
   -- @global int login_grace_period
   --
   -- @param string cookie Optional. If used, will validate contents instead of
   --                      cookie's.
   -- @param string scheme Optional. The cookie scheme to use: 'auth', 'secure_auth',
   --                      or 'logged_in'.
   -- @return int|false User ID if valid cookie, false if invalid.
   --
   function Wp_Validate_Auth_Cookie (Cookie : String := "";
                                     Scheme : String := "")
                                     return Integer;

   --
   -- Removes all of the cookies associated with authentication.
   --
   -- @since 2.5.0
   --
   procedure Wp_Clear_Auth_Cookie;

   --
   -- Parses a cookie into its components.
   --
   -- @since 2.7.0
   -- @since 4.0.0 The `token` element was added to the return value.
   --
   -- @param string cookie Authentication cookie.
   -- @param string scheme Optional. The cookie scheme to use: 'auth', 'secure_auth',
   --                       or 'logged_in'.
   -- @return string[]|false {
   --     Authentication cookie components. None of the components should be assumed
   --     to be valid as they come directly from a client-provided cookie value. If
   --     the cookie value is malformed, false is returned.
   --
   --     @type string username   User's username.
   --     @type string expiration The time the cookie expires as a UNIX timestamp.
   --     @type string token      User's session token used.
   --     @type string hmac       The security hash for the cookie.
   --     @type string scheme     The cookie scheme to use.
   -- }
   --
   function Wp_Parse_Auth_Cookie (Cookie : String := "";
                                  Scheme : String := "")
                                  return Array_Type;

   --
   -- Sets the authentication cookies based on user ID.
   --
   -- The remember parameter increases the time that the cookie will be kept. The
   -- default the cookie is kept without remembering is two days. When remember is
   -- set, the cookies will be kept for 14 days or two weeks.
   --
   -- @since 2.5.0
   -- @since 4.3.0 Added the `token` parameter.
   --
   -- @param int         user_id  User ID.
   -- @param bool        remember Whether to remember the user.
   -- @param bool|string secure   Whether the auth cookie should only be sent over
   --                             HTTPS. Default is an empty string which means the
   --                             value of `is_ssl()` will be used.
   -- @param string      token    Optional. User's session token to use for this
   --                             cookie.
   --
   procedure Wp_Set_Auth_Cookie (User_Id  : Integer;
                                 Remember : Boolean := False;
                                 Secure   : Boolean := False; -- ""
                                 Token    : String  := "");

   --
   -- Ensures intent by verifying that a user was referred from another admin page
   -- with the correct security nonce.
   --
   -- This function ensures the user intends to perform a given action, which helps
   -- protect against clickjacking style attacks. It verifies intent, not
   -- authorisation, therefore it does not verify the user's capabilities. This should
   -- be performed with `current_user_can()` or similar.
   --
   -- If the nonce value is invalid, the function will exit with an "Are You Sure?"
   -- style message.
   --
   -- @since 1.2.0
   -- @since 2.5.0 The `query_arg` parameter was added.
   --
   -- @param int|string action    The nonce action.
   -- @param string     query_arg Optional. Key to check for nonce in `_REQUEST`.
   --                             Default '_wpnonce'.
   -- @return int|false 1 if the nonce is valid and generated between 0-12 hours ago,
   --                   2 if the nonce is valid and generated between 12-24 hours ago.
   --                   False if the nonce is invalid.
   --
   function Check_Admin_Referer (Action    : String := "-1"; -- Integer := -1;
                                 Query_Arg : String := "_wpnonce")
                                 return Integer;

   procedure Check_Admin_Referer (Action    : String := "-1";  -- = -1
                                  Query_Arg : String := "_wpnonce");

   --
   -- Checks if a user is logged in, if not it redirects them to the login page.
   --
   -- When this code is called from a page, it checks to see if the user viewing the
   -- page is logged in. If the user is not logged in, they are redirected to the
   -- login page. The user is redirected in such a way that, upon logging in, they
   -- will be sent directly to the page they were originally trying to access.
   --
   -- @since 1.5.0
   --
   procedure Auth_Redirect;

   --
   -- Determines whether the current visitor is a logged in user.
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 2.0.0
   --
   -- @return bool True if user is logged in, false if not logged in.
   --
   function Is_User_Logged_In
            return Boolean;

   --
   -- Performs a safe (local) redirect, using wp_redirect().
   --
   -- Checks whether the location is using an allowed host, if it has an absolute
   -- path. A plugin can therefore set or remove allowed host(s) to or from the
   -- list.
   --
   -- If the host is not allowed, then the redirect defaults to wp-admin on the siteurl
   -- instead. This prevents malicious redirects which redirect to another host,
   -- but only used in a few places.
   --
   -- Note: wp_safe_redirect() does not exit automatically, and should almost always be
   -- followed by a call to `exit;`:
   --
   --     wp_safe_redirect( url );
   --     exit;
   --
   -- Exiting can also be selectively manipulated by using wp_safe_redirect() as a
   -- conditional in conjunction with the {@see 'wp_redirect'} and
   -- {@see 'wp_redirect_location'} filters:
   --
   --     if ( wp_safe_redirect( url ) ) then
   --         exit;
   --     end;
   --
   -- @since 2.3.0
   -- @since 5.1.0 The return value from wp_redirect() is now passed on, and the
   --              `x_redirect_by` parameter was added.
   --
   -- @param string location      The path or URL to redirect to.
   -- @param int    status        Optional. HTTP response status code to use.
   --                             Default '302' (Moved Temporarily).
   -- @param string x_redirect_by Optional. The application doing the redirect.
   --                             Default 'WordPress'.
   -- @return bool False if the redirect was cancelled, true otherwise.
   --
   function Wp_Safe_Redirect (Location      : String;
                              Status        : Integer := 302;
                              X_Redirect_By : String := "WordPress")
                              return Boolean;

   procedure Wp_Safe_Redirect (Location      : String;
                               Status        : Integer := 302;
                               X_Redirect_By : String := "WordPress");

   --
   -- Retrieves the avatar `<img>` tag for a user, email address, MD5 hash, comment,
   -- or post.
   --
   -- @since 2.5.0
   -- @since 4.2.0 Optional `args` parameter added.
   --
   -- @param mixed  id_or_email The Gravatar to retrieve. Accepts a user_id, gravatar
   --                           md5 hash, user email, WP_User object, WP_Post object,
   --                           or WP_Comment object.
   -- @param int    size        Optional. Height and width of the avatar image file
   --                           in pixels. Default 96.
   -- @param string default     Optional. URL for the default image or a default type.
   --                           Accepts '404' (return a 404 instead of a default
   --                           image), 'retro' (8bit), 'monsterid' (monster),
   --                           'wavatar' (cartoon face), 'indenticon' (the "quilt"),
   --                           'mystery', 'mm', or 'mysteryman' (The Oyster Man),
   --                           'blank' (transparent GIF), or 'gravatar_default' (the
   --                           Gravatar logo). Default is the value of the
   --                           'avatar_default' option, with a fallback of 'mystery'.
   -- @param string alt         Optional. Alternative text to use in img tag. Default
   --                           empty.
   -- @param array  args {
   --     Optional. Extra arguments to retrieve the avatar.
   --
   --     @type int          height        Display height of the avatar in pixels.
   --                                      Defaults to size.
   --     @type int          width         Display width of the avatar in pixels.
   --                                      Defaults to size.
   --     @type bool         force_default Whether to always show the default image,
   --                                      never the Gravatar. Default false.
   --     @type string       rating        What rating to display avatars up to.
   --                                      Accepts 'G', 'PG', 'R', 'X', and are judged
   --                                      in that order. Default is the value of the
   --                                      'avatar_rating' option.
   --     @type string       scheme        URL scheme to use. See set_url_scheme() for
   --                                      accepted values. Default null.
   --     @type array|string class         Array or string of additional classes to
   --                                      add to the img element. Default null.
   --     @type bool         force_display Whether to always show the avatar - ignores
   --                                      the show_avatars option. Default false.
   --     @type string       loading       Value for the `loading` attribute.
   --                                      Default null.
   --     @type string       extra_attr    HTML attributes to insert in the IMG
   --                                      element. Is not sanitized. Default empty.
   -- }
   -- @return string|false `<img>` tag for the user's avatar. False on failure.
   --
   function Get_Avatar (Id_Or_Email : String;
                        Size        : Integer    := 96;
                        Default     : String     := "";
                        Alt         : String     := "";
                        Args        : Array_Type := Empty_Array) -- = null
                        return String;

   --
   -- Returns a salt to add to hashes.
   --
   -- Salts are created using secret keys. Secret keys are located in two places:
   -- in the database and in the wp-config.php file. The secret key in the database
   -- is randomly generated and will be appended to the secret keys in wp-config.php.
   --
   -- The secret keys in wp-config.php should be updated to strong, random keys to
   -- maximize security. Below is an example of how the secret key constants are
   -- defined. Do not paste this example directly into wp-config.php. Instead, have a
   -- {@link https://api.wordpress.org/secret-key/1.1/salt/ secret key created} just
   -- for you.
   --
   --     define('AUTH_KEY',
   --        ' Xakm<o xQy rw4EMsLKM-?!T+,PFFend;)H4lzcW57AF0U@N@< >M%G4Yt>f`z]MON');
   --     define('SECURE_AUTH_KEY',
   --        'LzJend;op]mr|6+![Pend;Ak:uNdJCJZd>(Hx.-Mh#Tz)pCIU#uGEnfFz|f ;;eU%/U^O~');
   --     define('LOGGED_IN_KEY',
   --        '|i|Ux`9<p-haFf(qnT:sDO:D1P^wZ/Ra@miTJi9G;ddp_<qend;6H1)o|a +&JCM');
   --     define('NONCE_KEY',
   --        '%:Rthen[P|,s.KuMltH5end;cI;/k<Gx~j!f0I)m_sIyu+&NJZ)-iO>z7X>QYR0Z_XnZ@|');
   --     define('AUTH_SALT',
   --        'eZyT)-Naw]F8CwA*VaW#q*|.)g@o}||wf~@C-YSt}(dh_r6EbI#A,y|nU2{B#JBW');
   --     define('SECURE_AUTH_SALT',
   --        '!=oLUTXh,QW=H `}`L|9/^4-3 STz},T(w}W<I`.JjPi)<Bmf1v,HpGe}T1:Xt7n');
   --     define('LOGGED_IN_SALT',
   --        '+XSqHc;@Q*K_b|Z?NC[3H!!EONbh.n<+=uKR:>*c(u`g~EJBf#8u#RthenmUEZrozmm');
   --     define('NONCE_SALT',
   --        'h`GXHhD>SLWVfg1(1(N{;.V!MoE(SfbA_ksP@&`+AycHcAV+?@3q+rxV{%^VyKT');
   --
   -- Salting passwords helps against tools which has stored hashed values of
   -- common dictionary strings. The added values makes it harder to crack.
   --
   -- @since 2.5.0
   --
   -- @link https://api.wordpress.org/secret-key/1.1/salt/ Create secrets for
   --                                                      wp-config.php
   --
   -- @param string scheme Authentication scheme (auth, secure_auth, logged_in, nonce).
   -- @return string Salt value
   --
   function Wp_Salt (Scheme : String := "auth")
                     return String;

   --
   -- Gets hash of given string.
   --
   -- @since 2.0.3
   --
   -- @param string data   Plain text to hash.
   -- @param string scheme Authentication scheme (auth, secure_auth, logged_in, nonce).
   -- @return string Hash of data.
   --
   function Wp_Hash (Data   : String;
                     Scheme : String := "auth")
                     return String;

   --
   -- Generates a random password drawn from the defined set of characters.
   --
   -- Uses wp_rand() is used to create passwords with far less predictability
   -- than similar native PHP functions like `rand()` or `mt_rand()`.
   --
   -- @since 2.5.0
   --
   -- @param int  length              Optional. The length of password to generate.
   --                                  Default 12.
   -- @param bool special_chars       Optional. Whether to include standard special
   --                                  characters. Default true.
   -- @param bool extra_special_chars Optional. Whether to include other special
   --                                  characters. Used when generating secret keys
   --                                  and salts. Default false.
   -- @return string The random password.
   --
   function Wp_Generate_Password (Length              : Natural := 12;
                                  Special_Chars       : Boolean := True;
                                  Extra_Special_Chars : Boolean := False)
                                  return String;

   --
   -- Verifies that a correct security nonce was used with time limit.
   --
   -- A nonce is valid for 24 hours (by default).
   --
   -- @since 2.0.3
   --
   -- @param string     nonce  Nonce value that was used for verification, usually
   --                          via a form field.
   -- @param string|int action Should give context to what is taking place and be
   --                          the same when nonce was created.
   -- @return int|false 1 if the nonce is valid and generated between 0-12 hours ago,
   --                   2 if the nonce is valid and generated between 12-24 hours ago.
   --                   False if the nonce is invalid.
   --
   function Wp_Verify_Nonce (Nonce  : String;
                             Action : String := "-1") -- Integer := -1)
                             return Integer;

end Inc_Pluggables;
