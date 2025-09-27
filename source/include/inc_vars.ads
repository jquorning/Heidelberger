--
-- Creates common globals for the rest of WordPress
--
-- Sets $pagenow global which is the filename of the current screen.
-- Checks for the browser to set which one is currently being used.
--
-- Detects which user environment WordPress is being used on.
-- Only attempts to check for Apache, Nginx and IIS -- three web
-- servers with known pretty permalink capability.
--
-- Note: Though Nginx is detected, WordPress does not currently
-- generate rewrite rules for it. See https:--wordpress.org/support/article/nginx/
--
-- @package WordPress
--

with Ada.Strings.Unbounded;

package Inc_Vars
is
   use Ada.Strings.Unbounded;

   Pagenow : Unbounded_String;

   Is_Lynx   : Boolean;
   Is_Gecko  : Boolean;
   Is_winIE  : Boolean;
   Is_macIE  : Boolean;
   Is_Opera  : Boolean;
   Is_NS4    : Boolean;
   Is_Safari : Boolean;
   Is_Chrome : Boolean;
   Is_iPhone : Boolean;
   Is_IE     : Boolean;
   Is_Edge   : Boolean;

   Is_Apache : Boolean;
   Is_IIS    : Boolean;
   Is_IIS7   : Boolean;
   Is_Nginx  : Boolean;

   procedure Run;

   --
   -- Test if the current browser runs on a mobile device (smart phone, tablet, etc.)
   --
   -- @since 3.4.0
   --
   -- @return bool
   --
   function Wp_Is_Mobile
            return Boolean;

end Inc_Vars;
