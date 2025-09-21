package Inc_Load
is
--
-- Attempt an early load of translations.
--
-- Used for errors encountered during the initial loading process, before
-- the locale has been properly detected and loaded.
--
-- Designed for unusual load sequences (like setup-config.php) or for when
-- the script will then terminate with an error, otherwise there is a risk
-- that a file can be double-included.
--
-- @since 3.4.0
-- @access private
--
-- @global WP_Textdomain_Registry $wp_textdomain_registry WordPress Textdomain Registry.
-- @global WP_Locale $wp_locale WordPress date and time locale object.
--
   procedure Wp_Load_Translations_Early;

--
-- Determines if SSL is used.
--
-- @since 2.6.0
-- @since 4.6.0 Moved from functions.php to load.php.
--
-- @return bool True if SSL, otherwise false.
--
function Is_Ssl
         return Boolean
         is (False);

--
-- Determines whether the current request is for an administrative interface page.
--
-- Does not check if the user is an administrator; use current_user_can()
-- for checking roles and capabilities.
--
-- For more information on this and similar theme functions, check out
-- the then@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- Conditional Tagsend; article in the Theme Developer Handbook.
--
-- @since 1.5.1
--
-- @global WP_Screen current_screen WordPress current screen object.
--
-- @return bool True if inside WordPress administration interface, false otherwise.
--
   function Is_Admin
            return Boolean;

--
-- Determines whether the current request is for the network administrative interface.
--
-- e.g. `/wp-admin/network/`
--
-- Does not check if the user is an administrator; use current_user_can()
-- for checking roles and capabilities.
--
-- Does not check if the site is a Multisite network; use is_multisite()
-- for checking if Multisite is enabled.
--
-- @since 3.1.0
--
-- @global WP_Screen current_screen WordPress current screen object.
--
-- @return bool True if inside WordPress network administration pages.
--
   function Is_Network_Admin
            return Boolean
            is (True);

--
-- Determines whether the current request is for a user admin screen.
--
-- e.g. `/wp-admin/user/`
--
-- Does not check if the user is an administrator; use current_user_can()
-- for checking roles and capabilities.
--
-- @since 3.1.0
--
-- @global WP_Screen current_screen WordPress current screen object.
--
-- @return bool True if inside WordPress user administration pages.
--
   function Is_User_Admin
            return Boolean
            is (True);

--
-- Determines whether the current request is for a site"s administrative interface.
--
-- e.g. `/wp-admin/`
--
-- Does not check if the user is an administrator; use current_user_can()
-- for checking roles and capabilities.
--
-- @since 3.1.0
--
-- @global WP_Screen current_screen WordPress current screen object.
--
-- @return bool True if inside WordPress site administration pages.
--
   function Is_Blog_Admin
            return Boolean
            is (True);

--
-- If Multisite is enabled.
--
-- @since 3.0.0
--
-- @return bool True if Multisite is enabled, false otherwise.
--
   function Is_Multisite
            return Boolean;

--
-- Retrieve the current site ID.
--
-- @since 3.1.0
--
-- @global int blog_id
--
-- @return int Site ID.
--
   function Get_Current_Blog_Id
            return Integer
            is (1);

--
-- Is WordPress in Recovery Mode.
--
-- In this mode, plugins or themes that cause WSODs will be paused.
--
-- @since 5.2.0
--
-- @return bool
--
   function Wp_Is_Recovery_Mode
            return Boolean
            is (False);

--
-- Checks whether the given variable is a WordPress Error.
--
-- Returns whether `$thing` is an instance of the `WP_Error` class.
--
-- @since 2.1.0
--
-- @param mixed $thing The variable to check.
-- @return bool Whether the variable is an instance of WP_Error.
--
   function Is_Wp_Error (Thing : String)
                         return Boolean is (False);

--
-- Determines whether the current request is a WordPress Ajax request.
--
-- @since 4.7.0
--
-- @return bool True if it"s a WordPress Ajax request, false otherwise.
--
   function Wp_Doing_Ajax
            return Boolean
            is (True);

--
-- @since 5.0.0
--
-- @return bool True if `Accepts` or `Content-Type` headers contain `application/json`.
--              False otherwise.
--
   function Wp_Is_Json_Request
            return Boolean
            is (False);

end Inc_Load;
