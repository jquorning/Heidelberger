--
-- Defines constants and global variables that can be overridden, generally in wp-config.php.
--
-- @package WordPress
--

with Globals;
with Hb_Common;
with Php;

with Inc_Themes;
with Inc_Options;

package body Inc_Default_Constants
is

   --------------------------
   -- Wp_Initial_Constants --
   --------------------------

   procedure Wp_Initial_Constants
   is
--    use Globals;
   begin
--         global $blog_id, $wp_version;

--         --#@+
--         -- Constants for expressing human-readable data sizes in their respective number of bytes.
--         --
--         -- @since 4.4.0
--         -- @since 6.0.0 `PB_IN_BYTES`, `EB_IN_BYTES`, `ZB_IN_BYTES`, and `YB_IN_BYTES` were added.
--         --
--         define( "KB_IN_BYTES", 1024 );
--         define( "MB_IN_BYTES", 1024 * KB_IN_BYTES );
--         define( "GB_IN_BYTES", 1024 * MB_IN_BYTES );
--         define( "TB_IN_BYTES", 1024 * GB_IN_BYTES );
--         define( "PB_IN_BYTES", 1024 * TB_IN_BYTES );
--         define( "EB_IN_BYTES", 1024 * PB_IN_BYTES );
--         define( "ZB_IN_BYTES", 1024 * EB_IN_BYTES );
--         define( "YB_IN_BYTES", 1024 * ZB_IN_BYTES );
--         --#@-*/

--         -- Start of run timestamp.
--         if ( ! defined( "WP_START_TIMESTAMP" ) ) then
--                 define( "WP_START_TIMESTAMP", microtime( true ) );
--         end;

--         $current_limit     = ini_get( "memory_limit" );
--         $current_limit_int = wp_convert_hr_to_bytes( $current_limit );

--         -- Define memory limits.
--         if ( ! defined( "WP_MEMORY_LIMIT" ) ) then
--                 if ( false === wp_is_ini_value_changeable( "memory_limit" ) ) then
--                         define( "WP_MEMORY_LIMIT", $current_limit );
--                 end; elseif ( is_multisite() ) then
--                         define( "WP_MEMORY_LIMIT", "64M" );
--                 end; else then
--                         define( "WP_MEMORY_LIMIT", "40M" );
--                 end;
--         end;

--         if ( ! defined( "WP_MAX_MEMORY_LIMIT" ) ) then
--                 if ( false === wp_is_ini_value_changeable( "memory_limit" ) ) then
--                         define( "WP_MAX_MEMORY_LIMIT", $current_limit );
--                 end; elseif ( -1 === $current_limit_int || $current_limit_int > 268435456 /* = 256M-- ) then
--                         define( "WP_MAX_MEMORY_LIMIT", $current_limit );
--                 end; else then
--                         define( "WP_MAX_MEMORY_LIMIT", "256M" );
--                 end;
--         end;

--         -- Set memory limits.
--         $wp_limit_int = wp_convert_hr_to_bytes( WP_MEMORY_LIMIT );
--         if ( -1 !== $current_limit_int && ( -1 === $wp_limit_int || $wp_limit_int > $current_limit_int ) ) then
--                 ini_set( "memory_limit", WP_MEMORY_LIMIT );
--         end;

--         if ( ! isset( $blog_id ) ) then
--                 $blog_id = 1;
--         end;

--         if ( ! defined( "WP_CONTENT_DIR" ) ) then
--                 define( "WP_CONTENT_DIR", ABSPATH . "wp-content" ); -- No trailing slash, full paths only - WP_CONTENT_URL is defined further down.
--         end;

--         -- Add define( "WP_DEBUG", true ); to wp-config.php to enable display of notices during development.
--         if ( ! defined( "WP_DEBUG" ) ) then
--                 if ( "development" === wp_get_environment_type() ) then
--                         define( "WP_DEBUG", true );
--                 end; else then
--                         define( "WP_DEBUG", false );
--                 end;
--         end;

--         -- Add define( "WP_DEBUG_DISPLAY", null ); to wp-config.php to use the globally configured setting
--         -- for "display_errors" and not force errors to be displayed. Use false to force "display_errors" off.
--         if ( ! defined( "WP_DEBUG_DISPLAY" ) ) then
--                 define( "WP_DEBUG_DISPLAY", true );
--         end;

--         -- Add define( "WP_DEBUG_LOG", true ); to enable error logging to wp-content/debug.log.
--         if ( ! defined( "WP_DEBUG_LOG" ) ) then
--                 define( "WP_DEBUG_LOG", false );
--         end;

--         if ( ! defined( "WP_CACHE" ) ) then
--                 define( "WP_CACHE", false );
--         end;

--         -- Add define( "SCRIPT_DEBUG", true ); to wp-config.php to enable loading of non-minified,
--         -- non-concatenated scripts and stylesheets.
--         if ( ! defined( "SCRIPT_DEBUG" ) ) then
--                 if ( ! empty( $wp_version ) ) then
--                         $develop_src = false !== strpos( $wp_version, "-src" );
--                 end; else then
--                         $develop_src = false;
--                 end;

--                 define( "SCRIPT_DEBUG", $develop_src );
--         end;

--         --
--         -- Private
--         --
--         if ( ! defined( "MEDIA_TRASH" ) ) then
--                 define( "MEDIA_TRASH", false );
--         end;

--         if ( ! defined( "SHORTINIT" ) ) then
--                 define( "SHORTINIT", false );
--         end;

--         -- Constants for features added to WP that should short-circuit their plugin implementations.
--         define( "WP_FEATURE_BETTER_PASSWORDS", true );

      --#@+
      -- Constants for expressing human-readable intervals
      -- in their respective number of seconds.
      --
      -- Please note that these values are approximate and are provided for
      -- convenience.
      -- For example, MONTH_IN_SECONDS wrongly assumes every month has 30 days and
      -- YEAR_IN_SECONDS does not take leap years into account.
      --
      -- If you need more accuracy please consider using the DateTime class
      -- (https://www.php.net/manual/en/class.datetime.php).
      --
      -- @since 3.5.0
      -- @since 4.4.0 Introduced `MONTH_IN_SECONDS`.
      --
--    MINUTE_IN_SECONDS := 60;
--    HOUR_IN_SECONDS   := 60 * MINUTE_IN_SECONDS;
--    DAY_IN_SECONDS    := 24 * HOUR_IN_SECONDS;
      -- define( "WEEK_IN_SECONDS", 7 * DAY_IN_SECONDS );
      -- define( "MONTH_IN_SECONDS", 30 * DAY_IN_SECONDS );
      -- define( "YEAR_IN_SECONDS", 365 * DAY_IN_SECONDS );
      --#@-
      null;
   end Wp_Initial_Constants;

   -----------------------------------
   -- Wp_Plugin_Directory_Constants --
   -----------------------------------

   procedure Wp_Plugin_Directory_Constants
   is
      use Globals;
      use Hb_Common;
      use Inc_Options;
   begin
--    if ( ! defined( "WP_CONTENT_URL" ) ) then
      WP_CONTENT_URL := +Get_Option ("siteurl") & "/wp-content";
      -- Full URL - WP_CONTENT_DIR is defined further up.
--    end;

      --
      -- Allows for the plugins directory to be moved from the default location.
      --
      -- @since 2.6.0
      --
--    if ( ! defined( "WP_PLUGIN_DIR" ) ) then
      WP_PLUGIN_DIR := WP_CONTENT_DIR & "/plugins";
      -- Full path, no trailing slash.
--    end;

      --
      -- Allows for the plugins directory to be moved from the default location.
      --
      -- @since 2.6.0
      --
--    if ( ! defined( "WP_PLUGIN_URL" ) ) then
      WP_PLUGIN_URL := WP_CONTENT_URL & "/plugins";
      -- Full URL, no trailing slash.
--    end;

      --
      -- Allows for the plugins directory to be moved from the default location.
      --
      -- @since 2.1.0
      -- @deprecated
      --
--    if ( ! defined( "PLUGINDIR" ) ) then
      PLUGINDIR := +"wp-content/plugins"; -- Relative to ABSPATH. For back compat.
--    end;

      --
      -- Allows for the mu-plugins directory to be moved from the default location.
      --
      -- @since 2.8.0
      --
--    if ( ! defined( "WPMU_PLUGIN_DIR" ) ) then
      WPMU_PLUGIN_DIR := WP_CONTENT_DIR & "/mu-plugins";
      -- Full path, no trailing slash.
--    end;

      --
      -- Allows for the mu-plugins directory to be moved from the default location.
      --
      -- @since 2.8.0
      --
--    if ( ! defined( "WPMU_PLUGIN_URL" ) ) then
      WPMU_PLUGIN_URL := WP_CONTENT_URL & "/mu-plugins";
      -- Full URL, no trailing slash.
--    end;

      --
      -- Allows for the mu-plugins directory to be moved from the default location.
      --
      -- @since 2.8.0
      -- @deprecated
      --
--    if ( ! defined( "MUPLUGINDIR" ) ) then
      MUPLUGINDIR := +"wp-content/mu-plugins";
      -- Relative to ABSPATH. For back compat.
--    end;
   end Wp_Plugin_Directory_Constants;

   -------------------------
   -- Wp_Cookie_Constants --
   -------------------------

   procedure Wp_Cookie_Constants
   is
      use Hb_Common;
      use Php;
      use Inc_Options;
   begin
      --
      -- Used to guarantee unique hash cookies.
      --
      -- @since 1.5.0
      --
      if COOKIEHASH = "undefined" then
         declare
            SiteURL : constant String := Get_Site_Option ("siteurl");
         begin
            if SiteURL /= "" then
               COOKIEHASH := +MD5 (SiteURL);
            else
               COOKIEHASH := +"";
            end if;
         end;
      end if;

      --
      -- @since 2.0.0
      --
      USER_COOKIE := "wordpressuser_" & COOKIEHASH;

      --
      -- @since 2.0.0
      --
      PASS_COOKIE := "wordpresspass_" & COOKIEHASH;

      --
      -- @since 2.5.0
      --
      AUTH_COOKIE := "wordpress_" & COOKIEHASH;

      --
      -- @since 2.6.0
      --
      SECURE_AUTH_COOKIE := "wordpress_sec_" & COOKIEHASH;

      --
      -- @since 2.6.0
      --
      LOGGED_IN_COOKIE := "wordpress_logged_in_" & COOKIEHASH;

      --
      -- @since 2.3.0
      --
      TEST_COOKIE := +"wordpress_test_cookie";

      --
      -- @since 1.2.0
      --
      COOKIEPATH := +Preg_Replace ("|https?://[^/]+|i", "", Get_Option ("home") & "/");

      --
      -- @since 1.5.0
      --
      SITECOOKIEPATH :=
        +Preg_Replace ("|https?://[^/]+|i", "", Get_Option ("siteurl") & "/");

      --
      -- @since 2.6.0
      --
      ADMIN_COOKIE_PATH := SITECOOKIEPATH & "wp-admin";

      --
      -- @since 2.6.0
      --
      PLUGINS_COOKIE_PATH := +Preg_Replace ("|https?://[^/]+|i", "",
                                            -Globals.WP_PLUGIN_URL);

      --
      -- @since 2.0.0
      --
      COOKIE_DOMAIN := False;

      --
      -- @since 5.2.0
      --
      RECOVERY_MODE_COOKIE := "wordpress_rec_" & COOKIEHASH;
   end Wp_Cookie_Constants;

-- --
-- -- Defines SSL-related WordPress constants.
-- --
-- -- @since 3.0.0
-- --
-- function wp_ssl_constants() then
--         --
--         -- @since 2.6.0
--         --
--         if ( ! defined( "FORCE_SSL_ADMIN" ) ) then
--                 if ( "https" === parse_url( get_option( "siteurl" ), PHP_URL_SCHEME ) ) then
--                         define( "FORCE_SSL_ADMIN", true );
--                 end; else then
--                         define( "FORCE_SSL_ADMIN", false );
--                 end;
--         end;
--         force_ssl_admin( FORCE_SSL_ADMIN );

--         --
--         -- @since 2.6.0
--         -- @deprecated 4.0.0
--         --
--         if ( defined( "FORCE_SSL_LOGIN" ) && FORCE_SSL_LOGIN ) then
--                 force_ssl_admin( true );
--         end;
-- end;

   --------------------------------
   -- Wp_Functionality_Constants --
   --------------------------------

   procedure Wp_Functionality_Constants
   is
      use Globals;
   begin
      --
      -- @since 2.5.0
      --
--    if ( ! defined( "AUTOSAVE_INTERVAL" ) ) then
      AUTOSAVE_INTERVAL := MINUTE_IN_SECONDS;
--    end;

      --
      -- @since 2.9.0
      --
--    if ( ! defined( "EMPTY_TRASH_DAYS" ) ) then
      EMPTY_TRASH_DAYS := 30;
--    end;

--    if ( ! defined( "WP_POST_REVISIONS" ) ) then
      WP_POST_REVISIONS := True;
--    end;

      --
      -- @since 3.3.0
      --
--    if ( ! defined( "WP_CRON_LOCK_TIMEOUT" ) ) then
      WP_CRON_LOCK_TIMEOUT := MINUTE_IN_SECONDS;
--    end;
   end Wp_Functionality_Constants;

   -----------------------------
   -- Wp_Templating_Constants --
   -----------------------------

   procedure Wp_Templating_Constants
   is
      use Globals;
      use Hb_Common;
      use Inc_Themes;
   begin
      --
      -- Filesystem path to the current active template directory.
      --
      -- @since 1.5.0
      --
      TEMPLATEPATH := +Get_Template_Directory;

      --
      -- Filesystem path to the current active template stylesheet directory.
      --
      -- @since 2.1.0
      --
      STYLESHEETPATH := +Get_Stylesheet_Directory;

      --
      -- Slug of the default theme for this installation.
      -- Used as the default theme when installing new sites.
      -- It will be used as the fallback if the active theme doesn"t exist.
      --
      -- @since 3.0.0
      --
      -- @see WP_Theme::get_core_default_theme()
      --
--        if ( ! defined( "WP_DEFAULT_THEME" ) ) then
      WP_DEFAULT_THEME := +"twentytwentythree";
--        end;

   end Wp_Templating_Constants;

end Inc_Default_Constants;
