--
-- WordPress Options Administration API.
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Helpers_2;

package Adi_Options is

   --
   -- Display JavaScript on the page.
   --
   -- @since 3.5.0
   --
   procedure Options_General_Add_JS;

   function Options_General_Add_JS is new
     Helpers_2.Generic_Call_Procedure (Options_General_Add_JS);

end Adi_Options;
