--
-- Customize API: WP_Customize_Selective_Refresh class
--
-- @package WordPress
-- @subpackage Customize
-- @since 4.5.0
--

with Arrays;
with Binder;
with Hb_Common;
with Php;

with Inc_Class_Wp_Customize_Managers;

-- require_once ABSPATH . WPINC . "/customize/class-wp-customize-partial.php";

package body Cust_Class_Wp_Customize_Selective_Refresh
is
   use Arrays;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
              (Manager : access Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager)
               return Wp_Customize_Selective_Refresh
   is
      This : Wp_Customize_Selective_Refresh;
   begin
      This.Manager := Manager;

--    Add_Action ("customize_preview_init", array( this, "init_preview"));

      return This;
   end X_Construct;

   --------------------------------
   -- Is_Render_Partials_Request --
   --------------------------------

   function Is_Render_Partials_Request (This : Wp_Customize_Selective_Refresh)
                                        return Boolean
   is
      use Binder;
      use Hb_Common;
      use Php;
   begin
      return not Isset (X_POST, RENDER_QUERY_VAR);
--    return not Empty (X_POST, RENDER_QUERY_VAR);
   end Is_Render_Partials_Request;

end Cust_Class_Wp_Customize_Selective_Refresh;
