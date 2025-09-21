
--
-- These functions can be replaced via plugins. If plugins do not redefine these
-- functions, then these will be used instead.
--
-- @package WordPress
--

with Arrays;

with Inc_Class_Wp_Users;

package Inc_Pluggables
is
   use Arrays;

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
        -- Redirects to another page.
        --
        -- Note: wp_redirect() does not exit automatically, and should almost always be
        -- followed by a call to `exit;`:
        --
        --     wp_redirect( url );
        --     exit;
        --
        -- Exiting can also be selectively manipulated by using wp_redirect() as a conditional
        -- in conjunction with the then@see 'wp_redirect'end; and then@see 'wp_redirect_location'end; filters:
        --
        --     if ( wp_redirect( url ) ) then
        --         exit;
        --     end;
        --
        -- @since 1.5.1
        -- @since 5.1.0 The `x_redirect_by` parameter was added.
        -- @since 5.4.0 On invalid status codes, wp_die() is called.
        --
        -- @global bool is_IIS
        --
        -- @param string location      The path or URL to redirect to.
        -- @param int    status        Optional. HTTP response status code to use. Default '302' (Moved Temporarily).
        -- @param string x_redirect_by Optional. The application doing the redirect. Default 'WordPress'.
        -- @return bool False if the redirect was cancelled, true otherwise.
        --
        -- function wp_redirect( location, status = 302, x_redirect_by = 'WordPress' ) then
   procedure Wp_Redirect (Location : String)
                          is null;

        --
        -- Ensures intent by verifying that a user was referred from another admin page with the correct security nonce.
        --
        -- This function ensures the user intends to perform a given action, which helps protect against clickjacking style
        -- attacks. It verifies intent, not authorisation, therefore it does not verify the user's capabilities. This should
        -- be performed with `current_user_can()` or similar.
        --
        -- If the nonce value is invalid, the function will exit with an "Are You Sure?" style message.
        --
        -- @since 1.2.0
        -- @since 2.5.0 The `query_arg` parameter was added.
        --
        -- @param int|string action    The nonce action.
        -- @param string     query_arg Optional. Key to check for nonce in `_REQUEST`. Default '_wpnonce'.
        -- @return int|false 1 if the nonce is valid and generated between 0-12 hours ago,
        --                   2 if the nonce is valid and generated between 12-24 hours ago.
        --                   False if the nonce is invalid.
        --
        procedure Check_Admin_Referer (Action : String := "-1";  -- = -1
                                       Query_Arg : String := "_wpnonce")
                                       is null;

        --
        -- Checks if a user is logged in, if not it redirects them to the login page.
        --
        -- When this code is called from a page, it checks to see if the user viewing the page is logged in.
        -- If the user is not logged in, they are redirected to the login page. The user is redirected
        -- in such a way that, upon logging in, they will be sent directly to the page they were originally
        -- trying to access.
        --
        -- @since 1.5.0
        --
        procedure Auth_Redirect is null;

        --
        -- Determines whether the current visitor is a logged in user.
        --
        -- For more information on this and similar theme functions, check out
        -- the then@link https:--developer.wordpress.org/themes/basics/conditional-tags/
        -- Conditional Tagsend; article in the Theme Developer Handbook.
        --
        -- @since 2.0.0
        --
        -- @return bool True if user is logged in, false if not logged in.
        --
        function Is_User_Logged_In
           return Boolean
           is (True);

        --
        -- Retrieves the avatar `<img>` tag for a user, email address, MD5 hash, comment, or post.
        --
        -- @since 2.5.0
        -- @since 4.2.0 Optional `args` parameter added.
        --
        -- @param mixed  id_or_email The Gravatar to retrieve. Accepts a user_id, gravatar md5 hash,
        --                            user email, WP_User object, WP_Post object, or WP_Comment object.
        -- @param int    size        Optional. Height and width of the avatar image file in pixels. Default 96.
        -- @param string default     Optional. URL for the default image or a default type. Accepts '404'
        --                            (return a 404 instead of a default image), 'retro' (8bit), 'monsterid'
        --                            (monster), 'wavatar' (cartoon face), 'indenticon' (the "quilt"),
        --                            'mystery', 'mm', or 'mysteryman' (The Oyster Man), 'blank' (transparent GIF),
        --                            or 'gravatar_default' (the Gravatar logo). Default is the value of the
        --                            'avatar_default' option, with a fallback of 'mystery'.
        -- @param string alt         Optional. Alternative text to use in img tag. Default empty.
        -- @param array  args {
        --     Optional. Extra arguments to retrieve the avatar.
        --
        --     @type int          height        Display height of the avatar in pixels. Defaults to size.
        --     @type int          width         Display width of the avatar in pixels. Defaults to size.
        --     @type bool         force_default Whether to always show the default image, never the Gravatar. Default false.
        --     @type string       rating        What rating to display avatars up to. Accepts 'G', 'PG', 'R', 'X', and are
        --                                       judged in that order. Default is the value of the 'avatar_rating' option.
        --     @type string       scheme        URL scheme to use. See set_url_scheme() for accepted values.
        --                                       Default null.
        --     @type array|string class         Array or string of additional classes to add to the img element.
        --                                       Default null.
        --     @type bool         force_display Whether to always show the avatar - ignores the show_avatars option.
        --                                       Default false.
        --     @type string       loading       Value for the `loading` attribute.
        --                                       Default null.
        --     @type string       extra_attr    HTML attributes to insert in the IMG element. Is not sanitized. Default empty.
        -- }
        -- @return string|false `<img>` tag for the user's avatar. False on failure.
        --
        function Get_Avatar (Id_Or_Email : Integer;
                             Size        : Integer := 96;
                             Default     : String  := "";
                             Alt         : String  := "";
                             Args        : Integer := 0) -- = null
                             return String
                             is ("XXX-358");

end Inc_Pluggables;
