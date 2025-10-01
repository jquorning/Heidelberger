with Ada.Calendar;

package Inc_Load
is

   --
   -- Fix `_SERVER` variables for various setups.
   --
   -- @since 3.0.0
   -- @access private
   --
   -- @global string PHP_SELF The filename of the currently executing script,
   --                          relative to the document root.
   --
   procedure Wp_Fix_Server_Vars;

   --
   -- Check for the required PHP version, and the MySQL extension or
   -- a database drop-in.
   --
   -- Dies if requirements are not met.
   --
   -- @since 3.0.0
   -- @access private
   --
   -- @global string required_php_version The required PHP version string.
   -- @global string wp_version           The WordPress version string.
   --
   procedure Wp_Check_Php_Mysql_Versions;

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
   -- @global WP_Textdomain_Registry $wp_textdomain_registry WordPress Textdomain
   --                                                        Registry.
   -- @global WP_Locale $wp_locale WordPress date and time locale object.
   --
   procedure Wp_Load_Translations_Early;

   --
   -- Check or set whether WordPress is in "installation" mode.
   --
   -- If the `WP_INSTALLING` constant is defined during the bootstrap,
   -- `wp_installing()` will default to `true`.
   --
   -- @since 4.4.0
   --
   -- @param bool is_installing Optional. True to set WP into Installing mode, false
   --                           to turn Installing mode off. Omit this parameter if
   --                           you only want to fetch the current status.
   -- @return bool True if WP is installing, otherwise false. When a `is_installing`
   --              is passed, the function will report whether WP was in installing
   --              mode prior to the change to `is_installing`.
   --
   function Wp_Installing (Is_Installing : Boolean := False) -- null
            return Boolean
            is (False);

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
   -- Die with a maintenance message when conditions are met.
   --
   -- The default message can be replaced by using a drop-in (maintenance.php in
   -- the wp-content directory).
   --
   -- @since 3.0.0
   -- @access private
   --
   procedure Wp_Maintenance;

   --
   -- Add magic quotes to `_GET`, `_POST`, `_COOKIE`, and `_SERVER`.
   --
   -- Also forces `_REQUEST` to be `_GET + _POST`. If `_SERVER`,
   -- `_COOKIE`, or `_ENV` are needed, use those superglobals directly.
   --
   -- @since 3.0.0
   -- @access private
   --
   procedure Wp_Magic_Quotes;

   --
   -- Check if maintenance mode is enabled.
   --
   -- Checks for a file in the WordPress root directory named ".maintenance".
   -- This file will contain the variable upgrading, set to the time the file
   -- was created. If the file was created less than 10 minutes ago, WordPress
   -- is in maintenance mode.
   --
   -- @since 5.5.0
   --
   -- @global int upgrading The Unix timestamp marking when upgrading WordPress began.
   --
   -- @return bool True if maintenance mode is enabled, false otherwise.
   --
   function Wp_Is_Maintenance_Mode
            return Boolean;

   Timestart : Ada.Calendar.Time;

   --
   -- Start the WordPress micro-timer.
   --
   -- @since 0.71
   -- @access private
   --
   -- @global float timestart Unix timestamp set at the beginning of the page load.
   -- @see timer_stop()
   --
   -- @return bool Always returns true.
   --
   procedure Timer_Start;

   --
   -- Set the location of the language directory.
   --
   -- To set directory manually, define the `WP_LANG_DIR` constant
   -- in wp-config.php.
   --
   -- If the language directory exists within `WP_CONTENT_DIR`, it
   -- is used. Otherwise the language directory is assumed to live
   -- in `WPINC`.
   --
   -- @since 3.0.0
   -- @access private
   --
   procedure Wp_Set_Lang_Dir;

   --
   -- Load the database class file and instantiate the `wpdb` global.
   --
   -- @since 2.5.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Require_Wp_DB;

   --
   -- Set the database table prefix and the format specifiers for database
   -- table columns.
   --
   -- Columns not listed here default to `%s`.
   --
   -- @since 3.0.0
   -- @access private
   --
   -- @global wpdb   wpdb         WordPress database abstraction object.
   -- @global string table_prefix The database table prefix.
   --
   procedure Wp_Set_Wpdb_Vars;

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
   -- Determines whether the current request is for the network administrative
   -- interface.
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
   -- Toggle `_wp_using_ext_object_cache` on and off without directly
   -- touching global.
   --
   -- @since 3.7.0
   --
   -- @global bool _wp_using_ext_object_cache
   --
   -- @param bool using Whether external object cache is being used.
   -- @return bool The current "using" setting.
   --
   function Wp_Using_Ext_Object_Cache (Using : Boolean := False) -- = null
                                       return Boolean;

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
   -- @return bool True if `Accepts` or `Content-Type` headers contain
   --              `application/json`. False otherwise.
   --
   function Wp_Is_Json_Request
            return Boolean
            is (False);

end Inc_Load;
