--
-- Bootstrap file for setting the ABSPATH constant
-- and loading the wp-config.php file. The wp-config.php
-- file will then load the wp-settings.php file, which
-- will then set up the WordPress environment.
--
-- If the wp-config.php file is not found then an error
-- will be displayed asking the visitor to set up the
-- wp-config.php file.
--
-- Will also search for wp-config.php in WordPress" parent
-- directory to allow the WordPress directory to remain
-- untouched.
--
-- @package WordPress
--

with Arrays;
with Binder;
with UStrings;
with Lists;
with Php.HTML;
with Php.Strings;
with Wp_Config;

with Inc_Functions;
with Inc_L10n;
with Inc_Load;

package body Wp_Load
is
   use Arrays;
   use Lists;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Php.HTML;
      use Php.Strings;
      use UStrings;
      use Inc_L10n;
   begin

-- -- Define ABSPATH as this file"s directory
-- if ( ! defined( "ABSPATH" ) ) then
--         define( "ABSPATH", __DIR__ . "/" );
-- end;

      --
      -- The error_reporting() function can be disabled in php.ini. On systems where
      -- that is the case, it's best to add a dummy function to the wp-config.php
      -- file, but as this call to the function is run prior to wp-config.php loading,
      -- it is wrapped in a function_exists() check.
      --
-- if ( function_exists( "error_reporting" ) ) then
--         --
--         -- Initialize error reporting to a known set of levels.
--         --
--         -- This will be adapted in wp_debug_mode() located in wp-includes/load.php based on WP_DEBUG.
--         -- @see http://php.net/manual/en/errorfunc.constants.php List of known error levels.
--         --
--         error_reporting( E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_ERROR | E_WARNING | E_PARSE | E_USER_ERROR | E_USER_WARNING | E_RECOVERABLE_ERROR );
-- end;

      --
      -- If wp-config.php exists in the WordPress root, or if it exists in the root
      -- and wp-settings.php doesn't, load wp-config.php. The secondary check for
      -- wp-settings.php has the added benefit of avoiding cases where the current
      -- directory is a nested installation, e.g. / is WordPress(a) and /blog/ is
      -- WordPress(b).
      --
      -- If neither set of conditions is true, initiate loading the setup process.
      --
      if True then
--    if File_Exists (ABSPATH & "wp-config.php") then

         -- The config file resides in ABSPATH
         Wp_Config.Run;
--       require_once ABSPATH & "wp-config.php";

-- elsif ( @file_exists( dirname( ABSPATH ) . "/wp-config.php" ) && ! @file_exists( dirname( ABSPATH ) . "/wp-settings.php" ) ) then

--         -- The config file resides one level above ABSPATH but is not part of another installation
--         require_once dirname( ABSPATH ) . "/wp-config.php";

      else
         declare
            Die  : UString;
            Path : UString;
         begin
            -- A config file doesn't exist.

--          WPINC := "wp-includes";
--          require_once ABSPATH & WPINC & "/load.php";

            -- Standardize $_SERVER variables across setups.
            Inc_Load.Wp_Fix_Server_Vars;

--          require_once ABSPATH & WPINC & "/functions.php";

            Path := +Inc_Functions.Wp_Guess_URL & "/wp-admin/setup-config.php";

            --
            -- We're going to redirect to setup-config.php. While this shouldn't result
            -- in an infinite loop, that's a silly thing to assume, don't you think? If
            -- we"re traveling in circles, our last-ditch effort is "Need more help?"
            --
            if
              0 = Strpos (Get_As_String (Binder.X_SERVER, "REQUEST_URI"),
                          "setup-config")
            then
               Header ("Location: " & (-Path));
               return; -- exit;
            end if;

--          WP_CONTENT_DIR := ABSPATH & "wp-content";
--          require_once ABSPATH & WPINC & "/version.php";

            Inc_Load.Wp_Check_PHP_MySQL_Versions;
            Inc_Load.Wp_Load_Translations_Early;

            -- Die with an error message.

            Append (Die, "<p>" & Sprintf (
               -- translators: %s: wp-config.php
               abs "There doesn't seem to be a %s file. It is needed before the installation can continue.",
               To_List ("<code>wp-config.php</code>")) & "</p>");

            Append (Die, "<p>" & Sprintf (
               -- translators: 1: Documentation URL, 2: wp-config.php
               abs "Need more help? <a href=""%1$s"">Read the support article on %2$s</a>.",
               To_List (List => (
                 1 => +abs "https://wordpress.org/support/article/editing-wp-config-php/",
                 2 => +"<code>wp-config.php</code>"))) & "</p>");

            Append (Die, "<p>" & Sprintf (
               -- translators: %s: wp-config.php
               abs "You can create a %s file through a web interface, but this doesn't work for all server setups. The safest way is to manually create the file.",
               To_List ("<code>wp-config.php</code>")) & "</p>");

            Append (Die, "<p><a href=""" & (-Path) &
                    """ class=""button button-large"">" &
                    abs "Create a Configuration File" & "</a></p>");

            Inc_Functions.Wp_Die (-Die, abs "WordPress &rsaquo; Error");
         end;
      end if;

   end Run;

end Wp_Load;
