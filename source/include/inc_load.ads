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
-- If Multisite is enabled.
--
-- @since 3.0.0
--
-- @return bool True if Multisite is enabled, false otherwise.
--
   function Is_Multisite
            return Boolean;

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

end Inc_Load;
