--
-- Core HTTP Request API
--
-- Standardizes the HTTP requests for WordPress. Handles cookies, gzip encoding
-- and decoding, chunk decoding, if HTTP 1.1 and various other difficult HTTP
-- protocol implementations.
--
-- @package WordPress
-- @subpackage HTTP
--

with Ada.Containers;

with Php.Arrays;
with Php.HTML;
with Php.Lists;
with Php.Strings;
with Php.Types;

with UStrings;

with Class_HTTP;
with Inc_Functions;
with Inc_Load;

package body Inc_HTTP
is

   subtype Wp_Http is Class_HTTP.Wp_Http;

   Static_HTTP : Wp_Http; -- = null;

   --------------------------
   -- X_Wp_HTTP_Get_Object --
   --------------------------

   -- function X_Wp_HTTP_Get_Object
   --          return Wp_Http
   -- is
   --      static http = null;
   -- begin
   --      if ( is_null( http ) ) then
   --              http = new WP_Http();
   --      end;
   --      return http;
   -- end X_Wp_HTTP_Get_Object;
   X_Wp_HTTP_Get_Object : Wp_Http
     renames Static_HTTP;

-- --
-- -- Retrieve the raw response from a safe HTTP request.
-- --
-- -- This function is ideal when the HTTP request is being made to an arbitrary
-- -- URL. The URL is validated to avoid redirection and request forgery attacks.
-- --
-- -- @since 3.6.0
-- --
-- -- @see wp_remote_request() For more information on the response array format.
-- -- @see WP_Http::request() For default arguments information.
-- --
-- -- @param string url  URL to retrieve.
-- -- @param array  args Optional. Request arguments. Default empty array.
-- -- @return array|WP_Error The response or WP_Error on failure.
-- --
-- function wp_safe_remote_request( url, args = array() ) then
--         args["reject_unsafe_urls"] = true;
--         http                       = _wp_http_get_object();
--         return http.request( url, args );
-- end;

-- --
-- -- Retrieve the raw response from a safe HTTP request using the GET method.
-- --
-- -- This function is ideal when the HTTP request is being made to an arbitrary
-- -- URL. The URL is validated to avoid redirection and request forgery attacks.
-- --
-- -- @since 3.6.0
-- --
-- -- @see wp_remote_request() For more information on the response array format.
-- -- @see WP_Http::request() For default arguments information.
-- --
-- -- @param string url  URL to retrieve.
-- -- @param array  args Optional. Request arguments. Default empty array.
-- -- @return array|WP_Error The response or WP_Error on failure.
-- --
-- function wp_safe_remote_get( url, args = array() ) then
--         args["reject_unsafe_urls"] = true;
--         http                       = _wp_http_get_object();
--         return http.get( url, args );
-- end;

-- --
-- -- Retrieve the raw response from a safe HTTP request using the POST method.
-- --
-- -- This function is ideal when the HTTP request is being made to an arbitrary
-- -- URL. The URL is validated to avoid redirection and request forgery attacks.
-- --
-- -- @since 3.6.0
-- --
-- -- @see wp_remote_request() For more information on the response array format.
-- -- @see WP_Http::request() For default arguments information.
-- --
-- -- @param string url  URL to retrieve.
-- -- @param array  args Optional. Request arguments. Default empty array.
-- -- @return array|WP_Error The response or WP_Error on failure.
-- --
-- function wp_safe_remote_post( url, args = array() ) then
--         args["reject_unsafe_urls"] = true;
--         http                       = _wp_http_get_object();
--         return http.post( url, args );
-- end;

-- --
-- -- Retrieve the raw response from a safe HTTP request using the HEAD method.
-- --
-- -- This function is ideal when the HTTP request is being made to an arbitrary
-- -- URL. The URL is validated to avoid redirection and request forgery attacks.
-- --
-- -- @since 3.6.0
-- --
-- -- @see wp_remote_request() For more information on the response array format.
-- -- @see WP_Http::request() For default arguments information.
-- --
-- -- @param string url  URL to retrieve.
-- -- @param array  args Optional. Request arguments. Default empty array.
-- -- @return array|WP_Error The response or WP_Error on failure.
-- --
-- function wp_safe_remote_head( url, args = array() ) then
--         args["reject_unsafe_urls"] = true;
--         http                       = _wp_http_get_object();
--         return http.head( url, args );
-- end;

-- --
-- -- Performs an HTTP request and returns its response.
-- --
-- -- There are other API functions available which abstract away the HTTP method:
-- --
-- --  - Default "GET"  for wp_remote_get()
-- --  - Default "POST" for wp_remote_post()
-- --  - Default "HEAD" for wp_remote_head()
-- --
-- -- @since 2.7.0
-- --
-- -- @see WP_Http::request() For information on default arguments.
-- --
-- -- @param string url  URL to retrieve.
-- -- @param array  args Optional. Request arguments. Default empty array.
-- -- @return array|WP_Error then
-- --     The response array or a WP_Error on failure.
-- --
-- --     @type string[]                       headers       Array of response headers keyed by their name.
-- --     @type string                         body          Response body.
-- --     @type array                          response      then
-- --         Data about the HTTP response.
-- --
-- --         @type int|false    code    HTTP response code.
-- --         @type string|false message HTTP response message.
-- --     end;
-- --     @type WP_HTTP_Cookie[]               cookies       Array of response cookies.
-- --     @type WP_HTTP_Requests_Response|null http_response Raw HTTP response object.
-- -- end;
-- --
-- function wp_remote_request( url, args = array() ) then
--         http = _wp_http_get_object();
--         return http.request( url, args );
-- end;

-- --
-- -- Performs an HTTP request using the GET method and returns its response.
-- --
-- -- @since 2.7.0
-- --
-- -- @see wp_remote_request() For more information on the response array format.
-- -- @see WP_Http::request() For default arguments information.
-- --
-- -- @param string url  URL to retrieve.
-- -- @param array  args Optional. Request arguments. Default empty array.
-- -- @return array|WP_Error The response or WP_Error on failure.
-- --
-- function wp_remote_get( url, args = array() ) then
--         http = _wp_http_get_object();
--         return http.get( url, args );
-- end;

   --------------------
   -- Wp_Remove_Post --
   --------------------

   function Wp_Remote_Post (URL  : String;
                            Args : Array_Type := Empty_Array)
                            return Array_Type
   is
      HTTP : constant Wp_Http := X_Wp_HTTP_Get_Object;
   begin
      return HTTP.Post (URL, Args);
   end Wp_Remote_Post;

-- --
-- -- Performs an HTTP request using the HEAD method and returns its response.
-- --
-- -- @since 2.7.0
-- --
-- -- @see wp_remote_request() For more information on the response array format.
-- -- @see WP_Http::request() For default arguments information.
-- --
-- -- @param string url  URL to retrieve.
-- -- @param array  args Optional. Request arguments. Default empty array.
-- -- @return array|WP_Error The response or WP_Error on failure.
-- --
-- function wp_remote_head( url, args = array() ) then
--         http = _wp_http_get_object();
--         return http.head( url, args );
-- end;

-- --
-- -- Retrieve only the headers from the raw response.
-- --
-- -- @since 2.7.0
-- -- @since 4.6.0 Return value changed from an array to an Requests_Utility_CaseInsensitiveDictionary instance.
-- --
-- -- @see \Requests_Utility_CaseInsensitiveDictionary
-- --
-- -- @param array|WP_Error response HTTP response.
-- -- @return \Requests_Utility_CaseInsensitiveDictionary|array The headers of the response, or empty array
-- --                                                           if incorrect parameter given.
-- --
-- function wp_remote_retrieve_headers( response ) then
--         if ( is_wp_error( response ) || ! isset( response["headers"] ) ) then
--                 return array();
--         end;

--         return response["headers"];
-- end;

-- --
-- -- Retrieve a single header by name from the raw response.
-- --
-- -- @since 2.7.0
-- --
-- -- @param array|WP_Error response HTTP response.
-- -- @param string         header   Header name to retrieve value from.
-- -- @return array|string The header(s) value(s). Array if multiple headers with the same name are retrieved.
-- --                      Empty string if incorrect parameter given, or if the header doesn"t exist.
-- --
-- function wp_remote_retrieve_header( response, header ) then
--         if ( is_wp_error( response ) || ! isset( response["headers"] ) ) then
--                 return "";
--         end;

--         if ( isset( response["headers"][ header ] ) ) then
--                 return response["headers"][ header ];
--         end;

--         return "";
-- end;

-- --
-- -- Retrieve only the response code from the raw response.
-- --
-- -- Will return an empty string if incorrect parameter value is given.
-- --
-- -- @since 2.7.0
-- --
-- -- @param array|WP_Error response HTTP response.
-- -- @return int|string The response code as an integer. Empty string if incorrect parameter given.
-- --
-- function wp_remote_retrieve_response_code( response ) then
--         if ( is_wp_error( response ) || ! isset( response["response"] ) || ! is_array( response["response"] ) ) then
--                 return "";
--         end;

--         return response["response"]["code"];
-- end;

-- --
-- -- Retrieve only the response message from the raw response.
-- --
-- -- Will return an empty string if incorrect parameter value is given.
-- --
-- -- @since 2.7.0
-- --
-- -- @param array|WP_Error response HTTP response.
-- -- @return string The response message. Empty string if incorrect parameter given.
-- --
-- function wp_remote_retrieve_response_message( response ) then
--         if ( is_wp_error( response ) || ! isset( response["response"] ) || ! is_array( response["response"] ) ) then
--                 return "";
--         end;

--         return response["response"]["message"];
-- end;

   -----------------------------
   -- Wp_Remote_Retrieve_Body --
   -----------------------------

   function Wp_Remote_Retrieve_Body (Response : Array_Type)
                                     return String
   is
      use Inc_Load;
   begin
      if
        Is_Wp_Error (Response) or else
        not Isset (Response, "body")
      then
         return "";
      end if;

      return Get_As_String (Response, "body");
   end Wp_Remote_Retrieve_Body;

-- --
-- -- Retrieve only the cookies from the raw response.
-- --
-- -- @since 4.4.0
-- --
-- -- @param array|WP_Error response HTTP response.
-- -- @return WP_Http_Cookie[] An array of `WP_Http_Cookie` objects from the response.
-- --                          Empty array if there are none, or the response is a WP_Error.
-- --
-- function wp_remote_retrieve_cookies( response ) then
--         if ( is_wp_error( response ) || empty( response["cookies"] ) ) then
--                 return array();
--         end;

--         return response["cookies"];
-- end;

-- --
-- -- Retrieve a single cookie by name from the raw response.
-- --
-- -- @since 4.4.0
-- --
-- -- @param array|WP_Error response HTTP response.
-- -- @param string         name     The name of the cookie to retrieve.
-- -- @return WP_Http_Cookie|string The `WP_Http_Cookie` object, or empty string
-- --                               if the cookie is not present in the response.
-- --
-- function wp_remote_retrieve_cookie( response, name ) then
--         cookies = wp_remote_retrieve_cookies( response );

--         if ( empty( cookies ) ) then
--                 return "";
--         end;

--         foreach ( cookies as cookie ) then
--                 if ( cookie.name === name ) then
--                         return cookie;
--                 end;
--         end;

--         return "";
-- end;

-- --
-- -- Retrieve a single cookie"s value by name from the raw response.
-- --
-- -- @since 4.4.0
-- --
-- -- @param array|WP_Error response HTTP response.
-- -- @param string         name     The name of the cookie to retrieve.
-- -- @return string The value of the cookie, or empty string
-- --                if the cookie is not present in the response.
-- --
-- function wp_remote_retrieve_cookie_value( response, name ) then
--         cookie = wp_remote_retrieve_cookie( response, name );

--         if ( ! is_a( cookie, "WP_Http_Cookie" ) ) then
--                 return "";
--         end;

--         return cookie.value;
-- end;

   ----------------------
   -- Wp_HTTP_Supports --
   ----------------------

   function Wp_HTTP_Supports (Capabilities : Array_Type := Empty_Array;
   -- List_Type := Empty_List;
                              URL          : String    := "")
                              return Boolean
   is
      use Ada.Containers;
      use Php.Arrays;
      use Php.HTML;
      use Php.Lists;
      use Php.Types;
      use Inc_Functions;

      HTTP : constant Wp_Http := X_Wp_HTTP_Get_Object;

      Capabilities_2 : Array_Type := Wp_Parse_Args (Capabilities);

      Count : constant Count_Type := Capabilities_2.Length;
   begin
      -- If we have a numeric capabilities array, spoof a wp_remote_request()
      -- associative args array.
      if
        Count not in 0 and then
        List_Filter (Array_Keys (Capabilities_2),
                     Is_Numeric'Access).Length = Count
      then
         Capabilities_2 :=
           List_Combine (Array_Values (Capabilities_2),
                         List_Fill (0, Integer (Count), From_Boolean (True)));
      end if;

      if
        URL /= "" and then
        not Isset (Capabilities_2, "ssl")
      then
         declare
            Scheme : constant String := Parse_URL (URL, PHP_URL_SCHEME);
         begin
            if Scheme in "https" | "ssl" then
               Set (Capabilities_2, "ssl", From_Boolean (True));
            end if;
         end;
      end if;

      return HTTP.X_Get_First_Available_Transport (Capabilities_2) /= ""; -- (bool)
   end Wp_HTTP_Supports;

-- --
-- -- Get the HTTP Origin of the current request.
-- --
-- -- @since 3.4.0
-- --
-- -- @return string URL of the origin. Empty string if no origin.
-- --
-- function get_http_origin() then
--         origin = "";
--         if ( ! empty( _SERVER["HTTP_ORIGIN"] ) ) then
--                 origin = _SERVER["HTTP_ORIGIN"];
--         end;

--         --
--         -- Change the origin of an HTTP request.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string origin The original origin for the request.
--         --
--         return apply_filters( "http_origin", origin );
-- end;

-- --
-- -- Retrieve list of allowed HTTP origins.
-- --
-- -- @since 3.4.0
-- --
-- -- @return string[] Array of origin URLs.
-- --
-- function get_allowed_http_origins() then
--         admin_origin = parse_url( admin_url() );
--         home_origin  = parse_url( home_url() );

--         // @todo Preserve port?
--         allowed_origins = array_unique(
--                 array(
--                         "http://" . admin_origin["host"],
--                         "https://" . admin_origin["host"],
--                         "http://" . home_origin["host"],
--                         "https://" . home_origin["host"],
--                 )
--         );

--         --
--         -- Change the origin types allowed for HTTP requests.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string[] allowed_origins then
--         --     Array of default allowed HTTP origins.
--         --
--         --     @type string 0 Non-secure URL for admin origin.
--         --     @type string 1 Secure URL for admin origin.
--         --     @type string 2 Non-secure URL for home origin.
--         --     @type string 3 Secure URL for home origin.
--         -- end;
--         --
--         return apply_filters( "allowed_http_origins", allowed_origins );
-- end;

-- --
-- -- Determines if the HTTP origin is an authorized one.
-- --
-- -- @since 3.4.0
-- --
-- -- @param string|null origin Origin URL. If not provided, the value of get_http_origin() is used.
-- -- @return string Origin URL if allowed, empty string if not.
-- --
-- function is_allowed_http_origin( origin = null ) then
--         origin_arg = origin;

--         if ( null === origin ) then
--                 origin = get_http_origin();
--         end;

--         if ( origin && ! in_array( origin, get_allowed_http_origins(), true ) ) then
--                 origin = "";
--         end;

--         --
--         -- Change the allowed HTTP origin result.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string origin     Origin URL if allowed, empty string if not.
--         -- @param string origin_arg Original origin string passed into is_allowed_http_origin function.
--         --
--         return apply_filters( "allowed_http_origin", origin, origin_arg );
-- end;

-- --
-- -- Send Access-Control-Allow-Origin and related headers if the current request
-- -- is from an allowed origin.
-- --
-- -- If the request is an OPTIONS request, the script exits with either access
-- -- control headers sent, or a 403 response if the origin is not allowed. For
-- -- other request methods, you will receive a return value.
-- --
-- -- @since 3.4.0
-- --
-- -- @return string|false Returns the origin URL if headers are sent. Returns false
-- --                      if headers are not sent.
-- --
-- function send_origin_headers() then
--         origin = get_http_origin();

--         if ( is_allowed_http_origin( origin ) ) then
--                 header( "Access-Control-Allow-Origin: " . origin );
--                 header( "Access-Control-Allow-Credentials: true" );
--                 if ( "OPTIONS" === _SERVER["REQUEST_METHOD"] ) then
--                         exit;
--                 end;
--                 return origin;
--         end;

--         if ( "OPTIONS" === _SERVER["REQUEST_METHOD"] ) then
--                 status_header( 403 );
--                 exit;
--         end;

--         return false;
-- end;

-- --
-- -- Validate a URL for safe use in the HTTP API.
-- --
-- -- @since 3.5.2
-- --
-- -- @param string url Request URL.
-- -- @return string|false URL or false on failure.
-- --
-- function wp_http_validate_url( url ) then
--         if ( ! is_string( url ) || "" === url || is_numeric( url ) ) then
--                 return false;
--         end;

--         original_url = url;
--         url          = wp_kses_bad_protocol( url, array( "http", "https" ) );
--         if ( ! url || strtolower( url ) !== strtolower( original_url ) ) then
--                 return false;
--         end;

--         parsed_url = parse_url( url );
--         if ( ! parsed_url || empty( parsed_url["host"] ) ) then
--                 return false;
--         end;

--         if ( isset( parsed_url["user"] ) || isset( parsed_url["pass"] ) ) then
--                 return false;
--         end;

--         if ( false !== strpbrk( parsed_url["host"], ":#?[]" ) ) then
--                 return false;
--         end;

--         parsed_home = parse_url( get_option( "home" ) );
--         same_host   = isset( parsed_home["host"] ) && strtolower( parsed_home["host"] ) === strtolower( parsed_url["host"] );
--         host        = trim( parsed_url["host"], "." );

--         if ( ! same_host ) then
--                 if ( preg_match( "#^(([1-9]?\d|1\d\d|25[0-5]|2[0-4]\d)\.)then3end;([1-9]?\d|1\d\d|25[0-5]|2[0-4]\d)#", host ) ) then
--                         ip = host;
--                 end; else then
--                         ip = gethostbyname( host );
--                         if ( ip === host ) then // Error condition for gethostbyname().
--                                 return false;
--                         end;
--                 end;
--                 if ( ip ) then
--                         parts = array_map( "intval", explode( ".", ip ) );
--                         if ( 127 === parts[0] || 10 === parts[0] || 0 === parts[0]
--                                 || ( 172 === parts[0] && 16 <= parts[1] && 31 >= parts[1] )
--                                 || ( 192 === parts[0] && 168 === parts[1] )
--                         ) then
--                                 // If host appears local, reject unless specifically allowed.
--                                 --
--                                 -- Check if HTTP request is external or not.
--                                 --
--                                 -- Allows to change and allow external requests for the HTTP request.
--                                 --
--                                 -- @since 3.6.0
--                                 --
--                                 -- @param bool   external Whether HTTP request is external or not.
--                                 -- @param string host     Host name of the requested URL.
--                                 -- @param string url      Requested URL.
--                                 --
--                                 if ( ! apply_filters( "http_request_host_is_external", false, host, url ) ) then
--                                         return false;
--                                 end;
--                         end;
--                 end;
--         end;

--         if ( empty( parsed_url["port"] ) ) then
--                 return url;
--         end;

--         port = parsed_url["port"];

--         --
--         -- Controls the list of ports considered safe in HTTP API.
--         --
--         -- Allows to change and allow external requests for the HTTP request.
--         --
--         -- @since 5.9.0
--         --
--         -- @param array  allowed_ports Array of integers for valid ports.
--         -- @param string host          Host name of the requested URL.
--         -- @param string url           Requested URL.
--         --
--         allowed_ports = apply_filters( "http_allowed_safe_ports", array( 80, 443, 8080 ), host, url );
--         if ( is_array( allowed_ports ) && in_array( port, allowed_ports, true ) ) then
--                 return url;
--         end;

--         if ( parsed_home && same_host && isset( parsed_home["port"] ) && parsed_home["port"] === port ) then
--                 return url;
--         end;

--         return false;
-- end;

-- --
-- -- Mark allowed redirect hosts safe for HTTP requests as well.
-- --
-- -- Attached to the {@see "http_request_host_is_external"} filter.
-- --
-- -- @since 3.6.0
-- --
-- -- @param bool   is_external
-- -- @param string host
-- -- @return bool
-- --
-- function allowed_http_request_hosts( is_external, host ) then
--         if ( ! is_external && wp_validate_redirect( "http://" . host ) ) then
--                 is_external = true;
--         end;
--         return is_external;
-- end;

-- --
-- -- Adds any domain in a multisite installation for safe HTTP requests to the
-- -- allowed list.
-- --
-- -- Attached to the {@see "http_request_host_is_external"} filter.
-- --
-- -- @since 3.6.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param bool   is_external
-- -- @param string host
-- -- @return bool
-- --
-- function ms_allowed_http_request_hosts( is_external, host ) then
--         global wpdb;
--         static queried = array();
--         if ( is_external ) then
--                 return is_external;
--         end;
--         if ( get_network().domain === host ) then
--                 return true;
--         end;
--         if ( isset( queried[ host ] ) ) then
--                 return queried[ host ];
--         end;
--         queried[ host ] = (bool) wpdb.get_var( wpdb.prepare( "SELECT domain FROM wpdb.blogs WHERE domain = %s LIMIT 1", host ) );
--         return queried[ host ];
-- end;

   ------------------
   -- Wp_Parse_URL --
   ------------------

   function Wp_Parse_URL (URL       : String;
                          Component : Integer := -1)
                          return Array_Type
   is
      use Php.HTML;
      use Php.Strings;
      use UStrings;

      To_Unset : Array_Type;
      URL_2 : UString := +URL;
   begin
      if "//" = Substr (-URL_2, 0, 2) then
         To_Unset.Append (From_String ("scheme"));
         URL_2 := "placeholder:" & URL_2;

      elsif "/" = Substr (URL, 0, 1) then
         To_Unset.Append (From_String ("scheme"));
         To_Unset.Append (From_String ("host"));
         URL_2 := "placeholder://placeholder" & URL_2;
      end if;

      declare
         Parts : constant Array_Type := Parse_URL (-URL_2);
      begin
         if Parts = Empty_Array then -- false
            -- Parsing failure.
            return Parts;
         end if;

         -- Remove the placeholder values.
         for Key in To_Unset.Iterate loop
            Delete (Ref (Parts, Arrays.Key (Key)));
         end loop;

         return X_Get_Component_From_Parsed_URL_Array (Parts, Component);
      end;
   end Wp_Parse_URL;

   ------------------
   -- Wp_Parse_URL --
   ------------------

   function Wp_Parse_URL (URL       : String;
                          Component : Integer := -1)
                          return String
                          is ("XXX-952");

   -------------------------------------------
   -- X_Get_Component_From_Parsed_URL_Array --
   -------------------------------------------

   function X_Get_Component_From_Parsed_URL_Array (URL_Parts : Array_Type;
                                                   Component : Integer := -1)
                                                   return Array_Type
   is
   begin
      if -1 = Component then
         return URL_Parts;
      end if;

      declare
         Key : constant String :=
           X_Wp_Translate_PHP_URL_Constant_To_Key (Component);
      begin
         if
           "" /= Key and then -- false
--         Is_Array (URL_Parts) and then
           Isset (URL_Parts, Key)
         then
            return As_Array (Get (URL_Parts, Key));
         else
            return Empty_Array; -- null;
         end if;
      end;
   end X_Get_Component_From_Parsed_URL_Array;

   --------------------------------------------
   -- X_Wp_Translate_PHP_URL_Constant_To_Key --
   --------------------------------------------

   function X_Wp_Translate_PHP_URL_Constant_To_Key (Component : Integer)
                                                    return String
   is
      -- Translation : constant Array_Type := To_Array (List => (
      --           PHP_URL_SCHEME   => "scheme",
      --           PHP_URL_HOST     => "host",
      --           PHP_URL_PORT     => "port",
      --           PHP_URL_USER     => "user",
      --           PHP_URL_PASS     => "pass",
      --           PHP_URL_PATH     => "path",
      --           PHP_URL_QUERY    => "query",
      --           PHP_URL_FRAGMENT => "fragment",
      --   );
   begin
      --   if ( isset( translation[ constant ] ) ) then
      --           return translation[ constant ];
      --   else
      --           return false;
      --   end if;
      return "";
   end X_Wp_Translate_PHP_URL_Constant_To_Key;

end Inc_HTTP;
