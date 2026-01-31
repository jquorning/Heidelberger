--
-- Misc WordPress Administration API.
--
-- @package WordPress
-- @subpackage Administration
--

with Lists;

package Adi_Misc
is
   use Lists;

   --
   -- Displays the viewport meta in the admin.
   --
   -- @since 5.5.0
   --
   procedure Wp_Admin_Viewport_Meta;

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
   -- Sends a referrer policy header so referrers are not sent externally from
   -- administration screens.
   --
   -- @since 4.9.0
   --
   procedure Wp_Admin_Headers;

end Adi_Misc;
