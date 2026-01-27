--
-- HTTP API: WP_HTTP_Proxy class
--
-- @package WordPress
-- @subpackage HTTP
-- @since 4.4.0
--

with Constants;
with Globals;
with UStrings;

package body Class_HTTP_Proxys
is

   ----------------
   -- Is_Enabled --
   ----------------

   function Is_Enabled (This : Wp_HTTP_Proxy)
                        return Boolean
   is
      use UStrings;
   begin
      return
        Constants.WP_PROXY_HOST /= "" and then
        Constants.WP_PROXY_PORT /= "";
--    return defined( "WP_PROXY_HOST" ) && defined( "WP_PROXY_PORT" );
   end Is_Enabled;

end Class_HTTP_Proxys;
