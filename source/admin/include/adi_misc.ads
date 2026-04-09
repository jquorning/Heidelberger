--
-- Misc WordPress Administration API.
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;
with Helpers_2;
with Lists;

package Adi_Misc
is
   use Arrays;
   use Lists;

   --
   -- Displays the viewport meta in the admin.
   --
   -- @since 5.5.0
   --
   procedure Wp_Admin_Viewport_Meta;

   function Wp_Admin_Viewport_Meta
     is new Helpers_2.Generic_Call_Procedure (Wp_Admin_Viewport_Meta);

   --
   -- Resets global variables based on _GET and _POST.
   --
   -- This function resets global variables based on the names passed
   -- in the vars array to the value of _POST[var] or _GET[var] or ""
   -- if neither is defined.
   --
   -- @since 2.0.0
   --
   -- @param array vars An array of globals to reset.
   --
   procedure Wp_Reset_Vars (Vars : List_Type)
                           is null;

   --
   -- Removes single-use URL parameters and create canonical link based on new URL.
   --
   -- Removes specific query string parameters from a URL, create the canonical link,
   -- put it in the admin header, and change the current URL to match.
   --
   -- @since 4.2.0
   --
   procedure Wp_Admin_Canonical_URL;

   function Wp_Admin_Canonical_URL
     is new Helpers_2.Generic_Call_Procedure (Wp_Admin_Canonical_URL);

   --
   -- Sends a referrer policy header so referrers are not sent externally from
   -- administration screens.
   --
   -- @since 4.9.0
   --
   procedure Wp_Admin_Headers;

   function Wp_Admin_Headers
     is new Helpers_2.Generic_Call_Procedure (Wp_Admin_Headers);

   --
   -- Checks if the user needs to update PHP.
   --
   -- @since 5.1.0
   -- @since 5.1.1 Added the {@see "wp_is_php_version_acceptable"} filter.
   --
   -- @return array|false Array of PHP version data. False on failure.
   --
   function Wp_Check_PHP_Version
            return Array_Type;

end Adi_Misc;
