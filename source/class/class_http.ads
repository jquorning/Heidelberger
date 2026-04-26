--
-- HTTP API: WP_Http class
--
-- @package WordPress
-- @subpackage HTTP
-- @since 2.7.0
--

-- if ( ! class_exists( "Requests" ) ) then
--         require ABSPATH . WPINC . "/class-requests.php";

--         Requests::register_autoloader();
--         Requests::set_certificate_path( "/etc/ssl/certs/ca-certificates.crt" );
-- end;

with Arrays;

with Class_Errors;

package Class_HTTP
is
   use Arrays;

   --
   -- Core class used for managing HTTP transports and making HTTP requests.
   --
   -- This class is used to consistently make outgoing HTTP requests easy for
   -- developers while still being compatible with the many PHP configurations
   -- under which WordPress runs.
   --
   -- Debugging includes several actions, which pass different variables for
   -- debugging the HTTP API.
   --
   -- @since 2.7.0
   --
   -- #[AllowDynamicProperties]
   type Wp_HTTP is tagged
     record
        null;
     end record;

        -- -- Aliases for HTTP response codes.
        -- const HTTP_CONTINUE       = 100;
        -- const SWITCHING_PROTOCOLS = 101;
        -- const PROCESSING          = 102;
        -- const EARLY_HINTS         = 103;

        -- const OK                            = 200;
        -- const CREATED                       = 201;
        -- const ACCEPTED                      = 202;
        -- const NON_AUTHORITATIVE_INFORMATION = 203;
        -- const NO_CONTENT                    = 204;
        -- const RESET_CONTENT                 = 205;
        -- const PARTIAL_CONTENT               = 206;
        -- const MULTI_STATUS                  = 207;
        -- const IM_USED                       = 226;

        -- const MULTIPLE_CHOICES   = 300;
        -- const MOVED_PERMANENTLY  = 301;
        -- const FOUND              = 302;
        -- const SEE_OTHER          = 303;
        -- const NOT_MODIFIED       = 304;
        -- const USE_PROXY          = 305;
        -- const RESERVED           = 306;
        -- const TEMPORARY_REDIRECT = 307;
        -- const PERMANENT_REDIRECT = 308;

        -- const BAD_REQUEST                     = 400;
        -- const UNAUTHORIZED                    = 401;
        -- const PAYMENT_REQUIRED                = 402;
        -- const FORBIDDEN                       = 403;
        -- const NOT_FOUND                       = 404;
        -- const METHOD_NOT_ALLOWED              = 405;
        -- const NOT_ACCEPTABLE                  = 406;
        -- const PROXY_AUTHENTICATION_REQUIRED   = 407;
        -- const REQUEST_TIMEOUT                 = 408;
        -- const CONFLICT                        = 409;
        -- const GONE                            = 410;
        -- const LENGTH_REQUIRED                 = 411;
        -- const PRECONDITION_FAILED             = 412;
        -- const REQUEST_ENTITY_TOO_LARGE        = 413;
        -- const REQUEST_URI_TOO_LONG            = 414;
        -- const UNSUPPORTED_MEDIA_TYPE          = 415;
        -- const REQUESTED_RANGE_NOT_SATISFIABLE = 416;
        -- const EXPECTATION_FAILED              = 417;
        -- const IM_A_TEAPOT                     = 418;
        -- const MISDIRECTED_REQUEST             = 421;
        -- const UNPROCESSABLE_ENTITY            = 422;
        -- const LOCKED                          = 423;
        -- const FAILED_DEPENDENCY               = 424;
        -- const UPGRADE_REQUIRED                = 426;
        -- const PRECONDITION_REQUIRED           = 428;
        -- const TOO_MANY_REQUESTS               = 429;
        -- const REQUEST_HEADER_FIELDS_TOO_LARGE = 431;
        -- const UNAVAILABLE_FOR_LEGAL_REASONS   = 451;

        -- const INTERNAL_SERVER_ERROR           = 500;
        -- const NOT_IMPLEMENTED                 = 501;
        -- const BAD_GATEWAY                     = 502;
        -- const SERVICE_UNAVAILABLE             = 503;
        -- const GATEWAY_TIMEOUT                 = 504;
        -- const HTTP_VERSION_NOT_SUPPORTED      = 505;
        -- const VARIANT_ALSO_NEGOTIATES         = 506;
        -- const INSUFFICIENT_STORAGE            = 507;
        -- const NOT_EXTENDED                    = 510;
        -- const NETWORK_AUTHENTICATION_REQUIRED = 511;

   --
   -- Send an HTTP request to a URI.
   --
   -- Please note: The only URI that are supported in the HTTP Transport implementation
   -- are the HTTP and HTTPS protocols.
   --
   -- @since 2.7.0
   --
   -- @param string       url  The request URL.
   -- @param string|array args {
   --     Optional. Array or string of HTTP request arguments.
   --
   --     @type string       method              Request method. Accepts "GET",
   --                                             "POST", "HEAD", "PUT", "DELETE",
   --                                             "TRACE", "OPTIONS", or "PATCH".
   --                                             Some transports technically allow
   --                                             others, but should not be assumed.
   --                                             Default "GET".
   --     @type float        timeout             How long the connection should stay
   --                                             open in seconds. Default 5.
   --     @type int          redirection         Number of allowed redirects. Not
   --                                             supported by all transports.
   --                                             Default 5.
   --     @type string       httpversion         Version of the HTTP protocol to use.
   --                                             Accepts "1.0" and "1.1".
   --                                             Default "1.0".
   --     @type string       user-agent          User-agent value sent.
   --                                             Default "WordPress/" .
   --                                             get_bloginfo( "version" ) . "; " .
   --                                             get_bloginfo( "url" ).
   --     @type bool         reject_unsafe_urls  Whether to pass URLs through
   --                                             wp_http_validate_url().
   --                                             Default false.
   --     @type bool         blocking            Whether the calling code requires the
   --                                             result of the request.
   --                                             If set to false, the request will be
   --                                             sent to the remote server, and
   --                                             processing returned to the calling
   --                                             code immediately, the caller will
   --                                             know if the request succeeded or
   --                                             failed, but will not receive any
   --                                             response from the remote server.
   --                                             Default true.
   --     @type string|array headers             Array or string of headers to send
   --                                             with the request.
   --                                             Default empty array.
   --     @type array        cookies             List of cookies to send with the
   --                                             request. Default empty array.
   --     @type string|array body                Body to send with the request.
   --                                             Default null.
   --     @type bool         compress            Whether to compress the body when
   --                                             sending the request.
   --                                             Default false.
   --     @type bool         decompress          Whether to decompress a compressed
   --                                             response. If set to false and
   --                                             compressed content is returned in
   --                                             the response anyway, it will
   --                                             need to be separately decompressed.
   --                                             Default true.
   --     @type bool         sslverify           Whether to verify SSL for the
   --                                             request. Default true.
   --     @type string       sslcertificates     Absolute path to an SSL certificate
   --                                             .crt file. Default
   --                                             "/etc/ssl/certs/ca-certificates.crt"
   --     @type bool         stream              Whether to stream to a file. If set
   --                                             to true and no filename was
   --                                             given, it will be dropped it in the
   --                                             WP temp dir and its name will
   --                                             be set using the basename of the
   --                                             URL. Default false.
   --     @type string       filename            Filename of the file to write to when
   --                                             streaming. stream must be
   --                                             set to true. Default null.
   --     @type int          limit_response_size Size in bytes to limit the response
   --                                             to. Default null.
   --
   -- }
   -- @return array|WP_Error Array containing "headers", "body", "response",
   --                        "cookies", "filename". A WP_Error instance upon error.
   --
   type Response_Result is record
      Success : Boolean;
      Arry    : Array_Type;
      Error   : Class_Errors.Wp_Error;
   end record;

   function Request (This : Wp_HTTP;
                     URL  : String;
                     Args : Array_Type := Empty_Array)
                     return Response_Result; -- Array_Type;

        -- --
        -- -- Normalizes cookies for using in Requests.
        -- --
        -- -- @since 4.6.0
        -- --
        -- -- @param array cookies Array of cookies to send with the request.
        -- -- @return Requests_Cookie_Jar Cookie holder object.
        -- --
        -- public static function normalize_cookies( cookies ) then
        --         cookie_jar = new Requests_Cookie_Jar();

        --         foreach ( cookies as name => value ) then
        --                 if ( value instanceof WP_Http_Cookie ) then
        --                         attributes                 = array_filter(
        --                                 value.get_attributes(),
        --                                 static function( attr ) then
        --                                         return null !== attr;
        --                                 end;
        --                         );
        --                         cookie_jar[ value.name ] = new Requests_Cookie( value.name, value.value, attributes, array( "host-only" => value.host_only ) );
        --                 end; elseif ( is_scalar( value ) ) then
        --                         cookie_jar[ name ] = new Requests_Cookie( name, value );
        --                 end;
        --         end;

        --         return cookie_jar;
        -- end;

        -- --
        -- -- Match redirect behaviour to browser handling.
        -- --
        -- -- Changes 302 redirects from POST to GET to match browser handling. Per
        -- -- RFC 7231, user agents can deviate from the strict reading of the
        -- -- specification for compatibility purposes.
        -- --
        -- -- @since 4.6.0
        -- --
        -- -- @param string            location URL to redirect to.
        -- -- @param array             headers  Headers for the redirect.
        -- -- @param string|array      data     Body to send with the request.
        -- -- @param array             options  Redirect request options.
        -- -- @param Requests_Response original Response object.
        -- --
        -- public static function browser_redirect_compatibility( location, headers, data, &options, original ) then
        --         -- Browser compatibility.
        --         if ( 302 === original.status_code ) then
        --                 options["type"] = Requests::GET;
        --         end;
        -- end;

        -- --
        -- -- Validate redirected URLs.
        -- --
        -- -- @since 4.7.5
        -- --
        -- -- @throws Requests_Exception On unsuccessful URL validation.
        -- -- @param string location URL to redirect to.
        -- --
        -- public static function validate_redirects( location ) then
        --         if ( ! wp_http_validate_url( location ) ) then
        --                 throw new Requests_Exception( __( "A valid URL was not provided." ), "wp_http.redirect_failed_validation" );
        --         end;
        -- end;

   --
   -- Tests which transports are capable of supporting the request.
   --
   -- @since 3.2.0
   --
   -- @param array  args Request arguments.
   -- @param string url  URL to request.
   -- @return string|false Class name for the first transport that claims to support
   --                      the request. False if no transport claims to support the
   --                      request.
   --
   function X_Get_First_Available_Transport (This : Wp_HTTP;
                                             Args : Array_Type;
                                             URL  : String := "") -- null
                                             return String;

        -- --
        -- -- Dispatches a HTTP request to a supporting transport.
        -- --
        -- -- Tests each transport in order to find a transport which matches the request arguments.
        -- -- Also caches the transport instance to be used later.
        -- --
        -- -- The order for requests is cURL, and then PHP Streams.
        -- --
        -- -- @since 3.2.0
        -- -- @deprecated 5.1.0 Use WP_Http::request()
        -- -- @see WP_Http::request()
        -- --
        -- -- @param string url  URL to request.
        -- -- @param array  args Request arguments.
        -- -- @return array|WP_Error Array containing "headers", "body", "response", "cookies", "filename".
        -- --                        A WP_Error instance upon error.
        -- --
        -- private function _dispatch_request( url, args ) then
        --         static transports = array();

        --         class = this._get_first_available_transport( args, url );
        --         if ( ! class ) then
        --                 return new WP_Error( "http_failure", __( "There are no HTTP transports available which can complete the requested request." ) );
        --         end;

        --         -- Transport claims to support request, instantiate it and give it a whirl.
        --         if ( empty( transports[ class ] ) ) then
        --                 transports[ class ] = new class;
        --         end;

        --         response = transports[ class ].request( url, args );

        --         -- This action is documented in wp-includes/class-wp-http.php--
        --         do_action( "http_api_debug", response, "response", class, args, url );

        --         if ( is_wp_error( response ) ) then
        --                 return response;
        --         end;

        --         -- This filter is documented in wp-includes/class-wp-http.php--
        --         return apply_filters( "http_response", response, args, url );
        -- end;

   --
   -- Uses the POST HTTP method.
   --
   -- Used for sending data that is expected to be in the body.
   --
   -- @since 2.7.0
   --
   -- @param string       url  The request URL.
   -- @param string|array args Optional. Override the defaults.
   -- @return array|WP_Error Array containing "headers", "body", "response",
   --                        "cookies", "filename".
   --                        A WP_Error instance upon error.
   --
   function Post (This : Wp_HTTP;
                  URL  : String;
                  Args : Array_Type := Empty_Array)
                  return Array_Type;

   --
   -- Uses the GET HTTP method.
   --
   -- Used for sending data that is expected to be in the body.
   --
   -- @since 2.7.0
   --
   -- @param string       url  The request URL.
   -- @param string|array args Optional. Override the defaults.
   -- @return array|WP_Error Array containing "headers", "body", "response", "cookies", "filename".
   --                        A WP_Error instance upon error.
   --
   function Get (This : Wp_HTTP;
                 URL  : String;
                 Args : Array_Type := Empty_Array)
                 return Array_Type;

        -- --
        -- -- Uses the HEAD HTTP method.
        -- --
        -- -- Used for sending data that is expected to be in the body.
        -- --
        -- -- @since 2.7.0
        -- --
        -- -- @param string       url  The request URL.
        -- -- @param string|array args Optional. Override the defaults.
        -- -- @return array|WP_Error Array containing "headers", "body", "response", "cookies", "filename".
        -- --                        A WP_Error instance upon error.
        -- --
        -- public function head( url, args = array() ) then
        --         defaults    = array( "method" => "HEAD" );
        --         parsed_args = wp_parse_args( args, defaults );
        --         return this.request( url, parsed_args );
        -- end;

        -- --
        -- -- Parses the responses and splits the parts into headers and body.
        -- --
        -- -- @since 2.7.0
        -- --
        -- -- @param string response The full response string.
        -- -- @return array then
        -- --     Array with response headers and body.
        -- --
        -- --     @type string headers HTTP response headers.
        -- --     @type string body    HTTP response body.
        -- -- end;
        -- --
        -- public static function processResponse( response ) then -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.MethodNameInvalid
        --         response = explode( "\r\n\r\n", response, 2 );

        --         return array(
        --                 "headers" => response[0],
        --                 "body"    => isset( response[1] ) ? response[1] : "",
        --         );
        -- end;

   --
   -- Transforms header string into an array.
   --
   -- @since 2.7.0
   --
   -- @param string|array headers The original headers. If a string is passed, it will
   --                              be converted to an array. If an array is passed,
   --                              then it is assumed to be raw header data with
   --                              numeric keys with the headers as the values. No
   --                              headers must be passed that were already processed.
   -- @param string       url     Optional. The URL that was requested. Default empty.
   -- @return array {
   --     Processed string headers. If duplicate headers are encountered,
   --     then a numbered array is returned as the value of that header-key.
   --
   --     @type array            response {
   --         @type int    code    The response status code. Default 0.
   --         @type string message The response message. Default empty.
   --     }
   --     @type array            newheaders The processed header data as a
   --                                        multidimensional array.
   --     @type WP_Http_Cookie[] cookies    If the original headers contain the
   --                                        "Set-Cookie" key, an array containing
   --                                        `WP_Http_Cookie` objects is returned.
   -- }
   --
   -- public static
   function Process_Headers (Headers : Array_Type;
                             URL     : String := "")
                             return Array_Type;

        -- --
        -- -- Takes the arguments for a ::request() and checks for the cookie array.
        -- --
        -- -- If it"s found, then it upgrades any basic name => value pairs to WP_Http_Cookie instances,
        -- -- which are each parsed into strings and added to the Cookie: header (within the arguments array).
        -- -- Edits the array by reference.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @param array r Full array of args passed into ::request()
        -- --
        -- public static function buildCookieHeader( &r ) then -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.MethodNameInvalid
        --         if ( ! empty( r["cookies"] ) ) then
        --                 -- Upgrade any name => value cookie pairs to WP_HTTP_Cookie instances.
        --                 foreach ( r["cookies"] as name => value ) then
        --                         if ( ! is_object( value ) ) then
        --                                 r["cookies"][ name ] = new WP_Http_Cookie(
        --                                         array(
        --                                                 "name"  => name,
        --                                                 "value" => value,
        --                                         )
        --                                 );
        --                         end;
        --                 end;

        --                 cookies_header = "";
        --                 foreach ( (array) r["cookies"] as cookie ) then
        --                         cookies_header .= cookie.getHeaderValue() . "; ";
        --                 end;

        --                 cookies_header         = substr( cookies_header, 0, -2 );
        --                 r["headers"]["cookie"] = cookies_header;
        --         end;
        -- end;

        -- --
        -- -- Decodes chunk transfer-encoding, based off the HTTP 1.1 specification.
        -- --
        -- -- Based off the HTTP http_encoding_dechunk function.
        -- --
        -- -- @link https://tools.ietf.org/html/rfc2616#section-19.4.6 Process for chunked decoding.
        -- --
        -- -- @since 2.7.0
        -- --
        -- -- @param string body Body content.
        -- -- @return string Chunked decoded body on success or raw body on failure.
        -- --
        -- public static function chunkTransferDecode( body ) then -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.MethodNameInvalid
        --         -- The body is not chunked encoded or is malformed.
        --         if ( ! preg_match( "/^([0-9a-f]+)[^\r\n]*\r\n/i", trim( body ) ) ) then
        --                 return body;
        --         end;

        --         parsed_body = "";

        --         -- We"ll be altering body, so need a backup in case of error.
        --         body_original = body;

        --         while ( true ) then
        --                 has_chunk = (bool) preg_match( "/^([0-9a-f]+)[^\r\n]*\r\n/i", body, match );
        --                 if ( ! has_chunk || empty( match[1] ) ) then
        --                         return body_original;
        --                 end;

        --                 length       = hexdec( match[1] );
        --                 chunk_length = strlen( match[0] );

        --                 -- Parse out the chunk of data.
        --                 parsed_body .= substr( body, chunk_length, length );

        --                 -- Remove the chunk from the raw data.
        --                 body = substr( body, length + chunk_length );

        --                 -- End of the document.
        --                 if ( "0" === trim( body ) ) then
        --                         return parsed_body;
        --                 end;
        --         end;
        -- end;

   --
   -- Determines whether an HTTP API request to the given URL should be blocked.
   --
   -- Those who are behind a proxy and want to prevent access to certain hosts may
   -- do so. This will prevent plugins from working and core functionality, if you
   -- don't include `api.wordpress.org`.
   --
   -- You block external URL requests by defining `WP_HTTP_BLOCK_EXTERNAL` as true
   -- in your `wp-config.php` file and this will only allow localhost and your site
   -- to make requests. The constant `WP_ACCESSIBLE_HOSTS` will allow additional
   -- hosts to go through for requests. The format of the `WP_ACCESSIBLE_HOSTS`
   -- constant is a comma separated list of hostnames to allow, wildcard domains
   -- are supported, eg `*.wordpress.org` will allow for all subdomains of
   -- `wordpress.org` to be contacted.
   --
   -- @since 2.8.0
   --
   -- @link https://core.trac.wordpress.org/ticket/8927 Allow preventing external
   -- requests.
   -- @link https://core.trac.wordpress.org/ticket/14636 Allow wildcard domains in
   -- WP_ACCESSIBLE_HOSTS
   --
   -- @param string uri URI of url.
   -- @return bool True to block, false to allow.
   --
   function Block_Request (This : Wp_HTTP;
                           URI  : String)
                           return Boolean;

        -- --
        -- -- Used as a wrapper for PHP"s parse_url() function that handles edgecases in < PHP 5.4.7.
        -- --
        -- -- @deprecated 4.4.0 Use wp_parse_url()
        -- -- @see wp_parse_url()
        -- --
        -- -- @param string url The URL to parse.
        -- -- @return bool|array False on failure; Array of URL components on success;
        -- --                    See parse_url()"s return values.
        -- --
        -- protected static function parse_url( url ) then
        --         _deprecated_function( __METHOD__, "4.4.0", "wp_parse_url()" );
        --         return wp_parse_url( url );
        -- end;

        -- --
        -- -- Converts a relative URL to an absolute URL relative to a given URL.
        -- --
        -- -- If an Absolute URL is provided, no processing of that URL is done.
        -- --
        -- -- @since 3.4.0
        -- --
        -- -- @param string maybe_relative_path The URL which might be relative.
        -- -- @param string url                 The URL which maybe_relative_path is relative to.
        -- -- @return string An Absolute URL, in a failure condition where the URL cannot be parsed, the relative URL will be returned.
        -- --
        -- public static function make_absolute_url( maybe_relative_path, url ) then
   function Make_Absolute_URL
     (Maybe_Relative_Path : String; URL : String) return String
   is (raise Program_Error with "not implemented");
        --         if ( empty( url ) ) then
        --                 return maybe_relative_path;
        --         end;

        --         url_parts = wp_parse_url( url );
        --         if ( ! url_parts ) then
        --                 return maybe_relative_path;
        --         end;

        --         relative_url_parts = wp_parse_url( maybe_relative_path );
        --         if ( ! relative_url_parts ) then
        --                 return maybe_relative_path;
        --         end;

        --         -- Check for a scheme on the "relative" URL.
        --         if ( ! empty( relative_url_parts["scheme"] ) ) then
        --                 return maybe_relative_path;
        --         end;

        --         absolute_path = url_parts["scheme"] . "://";

        --         -- Schemeless URLs will make it this far, so we check for a host in the relative URL
        --         -- and convert it to a protocol-URL.
        --         if ( isset( relative_url_parts["host"] ) ) then
        --                 absolute_path .= relative_url_parts["host"];
        --                 if ( isset( relative_url_parts["port"] ) ) then
        --                         absolute_path .= ":" . relative_url_parts["port"];
        --                 end;
        --         end; else then
        --                 absolute_path .= url_parts["host"];
        --                 if ( isset( url_parts["port"] ) ) then
        --                         absolute_path .= ":" . url_parts["port"];
        --                 end;
        --         end;

        --         -- Start off with the absolute URL path.
        --         path = ! empty( url_parts["path"] ) ? url_parts["path"] : "/";

        --         -- If it"s a root-relative path, then great.
        --         if ( ! empty( relative_url_parts["path"] ) && "/" === relative_url_parts["path"][0] ) then
        --                 path = relative_url_parts["path"];

        --                 -- Else it"s a relative path.
        --         end; elseif ( ! empty( relative_url_parts["path"] ) ) then
        --                 -- Strip off any file components from the absolute path.
        --                 path = substr( path, 0, strrpos( path, "/" ) + 1 );

        --                 -- Build the new path.
        --                 path .= relative_url_parts["path"];

        --                 -- Strip all /path/../ out of the path.
        --                 while ( strpos( path, "../" ) > 1 ) then
        --                         path = preg_replace( "![^/]+/\.\./!", "", path );
        --                 end;

        --                 -- Strip any final leading ../ from the path.
        --                 path = preg_replace( "!^/(\.\./)+!", "", path );
        --         end;

        --         -- Add the query string.
        --         if ( ! empty( relative_url_parts["query"] ) ) then
        --                 path .= "?" . relative_url_parts["query"];
        --         end;

        --         return absolute_path . "/" . ltrim( path, "/" );
        -- end;

        -- --
        -- -- Handles an HTTP redirect and follows it if appropriate.
        -- --
        -- -- @since 3.7.0
        -- --
        -- -- @param string url      The URL which was requested.
        -- -- @param array  args     The arguments which were used to make the request.
        -- -- @param array  response The response of the HTTP request.
        -- -- @return array|false|WP_Error An HTTP API response array if the redirect is successfully followed,
        -- --                              false if no redirect is present, or a WP_Error object if there"s an error.
        -- --
        -- public static function handle_redirects( url, args, response ) then
        --         -- If no redirects are present, or, redirects were not requested, perform no action.
        --         if ( ! isset( response["headers"]["location"] ) || 0 === args["_redirection"] ) then
        --                 return false;
        --         end;

        --         -- Only perform redirections on redirection http codes.
        --         if ( response["response"]["code"] > 399 || response["response"]["code"] < 300 ) then
        --                 return false;
        --         end;

        --         -- Don"t redirect if we"ve run out of redirects.
        --         if ( args["redirection"]-- <= 0 ) then
        --                 return new WP_Error( "http_request_failed", __( "Too many redirects." ) );
        --         end;

        --         redirect_location = response["headers"]["location"];

        --         -- If there were multiple Location headers, use the last header specified.
        --         if ( is_array( redirect_location ) ) then
        --                 redirect_location = array_pop( redirect_location );
        --         end;

        --         redirect_location = WP_Http::make_absolute_url( redirect_location, url );

        --         -- POST requests should not POST to a redirected location.
        --         if ( "POST" === args["method"] ) then
        --                 if ( in_array( response["response"]["code"], array( 302, 303 ), true ) ) then
        --                         args["method"] = "GET";
        --                 end;
        --         end;

        --         -- Include valid cookies in the redirect process.
        --         if ( ! empty( response["cookies"] ) ) then
        --                 foreach ( response["cookies"] as cookie ) then
        --                         if ( cookie.test( redirect_location ) ) then
        --                                 args["cookies"][] = cookie;
        --                         end;
        --                 end;
        --         end;

        --         return wp_remote_request( redirect_location, args );
        -- end;

        -- --
        -- -- Determines if a specified string represents an IP address or not.
        -- --
        -- -- This function also detects the type of the IP address, returning either
        -- -- "4" or "6" to represent a IPv4 and IPv6 address respectively.
        -- -- This does not verify if the IP is a valid IP, only that it appears to be
        -- -- an IP address.
        -- --
        -- -- @link http://home.deds.nl/~aeron/regex/ for IPv6 regex.
        -- --
        -- -- @since 3.7.0
        -- --
        -- -- @param string maybe_ip A suspected IP address.
        -- -- @return int|false Upon success, "4" or "6" to represent a IPv4 or IPv6 address, false upon failure
        -- --
        -- public static function is_ip_address( maybe_ip ) then
        --         if ( preg_match( "/^\dthen1,3end;\.\dthen1,3end;\.\dthen1,3end;\.\dthen1,3end;/", maybe_ip ) ) then
        --                 return 4;
        --         end;

        --         if ( false !== strpos( maybe_ip, ":" ) && preg_match( "/^(((?=.*(::))(?!.*\3.+\3))\3?|([\dA-F]then1,4end;(\3|:\b|)|\2))(?4)then5end;((?4)then2end;|(((2[0-4]|1\d|[1-9])?\d|25[0-5])\.?\b)then4end;)/i", trim( maybe_ip, " []" ) ) ) then
        --                 return 6;
        --         end;

        --         return false;
        -- end;

end Class_HTTP;
