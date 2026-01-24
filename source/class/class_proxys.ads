--
-- HTTP API: WP_HTTP_Proxy class
--
-- @package WordPress
-- @subpackage HTTP
-- @since 4.4.0
--

package Class_HTTP_Proxys
is

   --
   -- Core class used to implement HTTP API proxy support.
   --
   -- There are caveats to proxy support. It requires that defines be made in the
   -- wp-config.php file to enable proxy support. There are also a few filters that
   -- plugins can hook into for some of the constants.
   --
   -- Please note that only BASIC authentication is supported by most transports.
   -- cURL MAY support more methods (such as NTLM authentication) depending on your
   -- environment.
   --
   -- The constants are as follows:
   -- <ol>
   -- <li>WP_PROXY_HOST - Enable proxy support and host for connecting.</li>
   -- <li>WP_PROXY_PORT - Proxy port for connection. No default, must be defined.</li>
   -- <li>WP_PROXY_USERNAME - Proxy username, if it requires authentication.</li>
   -- <li>WP_PROXY_PASSWORD - Proxy password, if it requires authentication.</li>
   -- <li>WP_PROXY_BYPASS_HOSTS - Will prevent the hosts in this list from going
   --                             through the proxy.
   -- You do not need to have localhost and the site host in this list, because they
   -- will not be passed through the proxy. The list should be presented in a comma
   -- separated list, wildcards using * are supported. Example:*.wordpress.org</li>
   -- </ol>
   --
   -- An example can be as seen below.
   --
   --     define("WP_PROXY_HOST", "192.168.84.101");
   --     define("WP_PROXY_PORT", "8080");
   --     define("WP_PROXY_BYPASS_HOSTS",
   --            "localhost, www.example.com,*.wordpress.org");
   --
   -- @link https://core.trac.wordpress.org/ticket/4011 Proxy support ticket in
   -- WordPress.
   -- @link https://core.trac.wordpress.org/ticket/14636 Allow wildcard domains in
   -- WP_PROXY_BYPASS_HOSTS
   --
   -- @since 2.8.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Http_Proxy is tagged
     record
        null;
     end record;

        -- --
        -- -- Whether proxy connection should be used.
        -- --
        -- -- Constants which control this behaviour:
        -- --
        -- -- - `WP_PROXY_HOST`
        -- -- - `WP_PROXY_PORT`
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @return bool
        -- --
        -- public function is_enabled() then
        --         return defined( "WP_PROXY_HOST" ) && defined( "WP_PROXY_PORT" );
        -- end;

        -- --
        -- -- Whether authentication should be used.
        -- --
        -- -- Constants which control this behaviour:
        -- --
        -- -- - `WP_PROXY_USERNAME`
        -- -- - `WP_PROXY_PASSWORD`
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @return bool
        -- --
        -- public function use_authentication() then
        --         return defined( "WP_PROXY_USERNAME" ) && defined( "WP_PROXY_PASSWORD" );
        -- end;

        -- --
        -- -- Retrieve the host for the proxy server.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @return string
        -- --
        -- public function host() then
        --         if ( defined( "WP_PROXY_HOST" ) ) then
        --                 return WP_PROXY_HOST;
        --         end;

        --         return "";
        -- end;

        -- --
        -- -- Retrieve the port for the proxy server.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @return string
        -- --
        -- public function port() then
        --         if ( defined( "WP_PROXY_PORT" ) ) then
        --                 return WP_PROXY_PORT;
        --         end;

        --         return "";
        -- end;

        -- --
        -- -- Retrieve the username for proxy authentication.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @return string
        -- --
        -- public function username() then
        --         if ( defined( "WP_PROXY_USERNAME" ) ) then
        --                 return WP_PROXY_USERNAME;
        --         end;

        --         return "";
        -- end;

        -- --
        -- -- Retrieve the password for proxy authentication.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @return string
        -- --
        -- public function password() then
        --         if ( defined( "WP_PROXY_PASSWORD" ) ) then
        --                 return WP_PROXY_PASSWORD;
        --         end;

        --         return "";
        -- end;

        -- --
        -- -- Retrieve authentication string for proxy authentication.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @return string
        -- --
        -- public function authentication() then
        --         return this.username() . ":" . this.password();
        -- end;

        -- --
        -- -- Retrieve header string for proxy authentication.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @return string
        -- --
        -- public function authentication_header() then
        --         return "Proxy-Authorization: Basic " . base64_encode( this.authentication() );
        -- end;

        -- --
        -- -- Determines whether the request should be sent through a proxy.
        -- --
        -- -- We want to keep localhost and the site URL from being sent through the proxy, because
        -- -- some proxies can not handle this. We also have the constant available for defining other
        -- -- hosts that won"t be sent through the proxy.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @param string uri URL of the request.
        -- -- @return bool Whether to send the request through the proxy.
        -- --
        -- public function send_through_proxy( uri ) then
        --         check = parse_url( uri );

        --         // Malformed URL, can not process, but this could mean ssl, so let through anyway.
        --         if ( false === check ) then
        --                 return true;
        --         end;

        --         home = parse_url( get_option( "siteurl" ) );

        --         --
        --         -- Filters whether to preempt sending the request through the proxy.
        --         --
        --         -- Returning false will bypass the proxy; returning true will send
        --         -- the request through the proxy. Returning null bypasses the filter.
        --         --
        --         -- @since 3.5.0
        --         --
        --         -- @param bool|null override Whether to send the request through the proxy. Default null.
        --         -- @param string    uri      URL of the request.
        --         -- @param array     check    Associative array result of parsing the request URL with `parse_url()`.
        --         -- @param array     home     Associative array result of parsing the site URL with `parse_url()`.
        --         --
        --         result = apply_filters( "pre_http_send_through_proxy", null, uri, check, home );
        --         if ( ! is_null( result ) ) then
        --                 return result;
        --         end;

        --         if ( "localhost" === check["host"] || ( isset( home["host"] ) && home["host"] === check["host"] ) ) then
        --                 return false;
        --         end;

        --         if ( ! defined( "WP_PROXY_BYPASS_HOSTS" ) ) then
        --                 return true;
        --         end;

        --         static bypass_hosts   = null;
        --         static wildcard_regex = array();
        --         if ( null === bypass_hosts ) then
        --                 bypass_hosts = preg_split( "|,\s*|", WP_PROXY_BYPASS_HOSTS );

        --                 if ( false !== strpos( WP_PROXY_BYPASS_HOSTS, "*" ) ) then
        --                         wildcard_regex = array();
        --                         foreach ( bypass_hosts as host ) then
        --                                 wildcard_regex[] = str_replace( "\*", ".+", preg_quote( host, "/" ) );
        --                         end;
        --                         wildcard_regex = "/^(" . implode( "|", wildcard_regex ) . ")/i";
        --                 end;
        --         end;

        --         if ( ! empty( wildcard_regex ) ) then
        --                 return ! preg_match( wildcard_regex, check["host"] );
        --         end; else then
        --                 return ! in_array( check["host"], bypass_hosts, true );
        --         end;
        -- end;

end Class_HTTP_Proxys;
