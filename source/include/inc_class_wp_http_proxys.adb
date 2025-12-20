--
-- HTTP API: WP_HTTP_Proxy class
--
-- @package WordPress
-- @subpackage HTTP
-- @since 4.4.0
--

with Ada.Strings.Unbounded;

with Globals;

package body Inc_Class_Wp_HTTP_Proxys
is

   ----------------
   -- Is_Enabled --
   ----------------

   function Is_Enabled (This : Wp_HTTP_Proxy)
                        return Boolean
   is
      use Ada.Strings.Unbounded;
   begin
      return
        Globals.WP_PROXY_HOST /= "" and then
        Globals.WP_PROXY_PORT /= "";
--    return defined( "WP_PROXY_HOST" ) && defined( "WP_PROXY_PORT" );
   end Is_Enabled;

end Inc_Class_Wp_HTTP_Proxys;
