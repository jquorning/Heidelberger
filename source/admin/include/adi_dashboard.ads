--
-- WordPress Dashboard Widget Administration Screen API
--
-- @package WordPress
-- @subpackage Administration
--
package Adi_Dashboard
is
   procedure Dummy;

   --
   -- The Quick Draft widget display and creation of drafts.
   --
   -- @since 3.8.0
   --
   -- @global int post_ID
   --
   -- @param string|false error_msg Optional. Error message. Default false.
   --
   procedure Wp_Dashboard_Quick_Press (Error_Msg : String := "") -- = false
                                       is null;

end Adi_Dashboard;
