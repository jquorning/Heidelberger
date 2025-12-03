--
-- Misc WordPress Administration API.
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;
with Lists;

package Adi_Misc
is
   use Arrays;
   use Lists;

   procedure Dummy;

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

end Adi_Misc;
