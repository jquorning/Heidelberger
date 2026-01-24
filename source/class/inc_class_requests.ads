--
-- Requests for PHP
--
-- Inspired by Requests for Python.
--
-- Based on concepts from SimplePie_File, RequestCore and WP_Http.
--
-- @package Requests
--

with Ada.Strings.Unbounded;

with Arrays;

with Req_Responses;
with Req_Transports;

package Inc_Class_Requests
is
   use Arrays;

   Requests_Exception : exception;

   --
   -- POST method
   --
   -- @var string
   --
   POST : constant String := "POST";

   --
   -- PUT method
   --
   -- @var string
   --
   PUT : constant String := "PUT";

   --
   -- GET method
   --
   -- @var string
   --
   GET_Method : constant String := "GET";

   --
   -- HEAD method
   --
   -- @var string
   --
   HEAD : constant String := "HEAD";

   --
   -- DELETE method
   --
   -- @var string
   --
   DELETE_Method : constant String := "DELETE";

   --
   -- OPTIONS method
   --
   -- @var string
   --
   OPTIONS : constant String := "OPTIONS";

   --
   -- TRACE method
   --
   -- @var string
   --
   TRACE : constant String := "TRACE";

   --
   -- PATCH method
   --
   -- @link https://tools.ietf.org/html/rfc5789
   -- @var string
   --
   PATCH : constant String := "PATCH";

   --
   -- Default size of buffer size to read streams
   --
   -- @var integer
   --
-- const BUFFER_SIZE = 1160;

   --
   -- Current version of Requests
   --
   -- @var string
   --
   VERSION : constant String := "1.8.1";

   --
   -- Requests for PHP
   --
   -- Inspired by Requests for Python.
   --
   -- Based on concepts from SimplePie_File, RequestCore and WP_Http.
   --
   -- @package Requests
   --
   type Requests is tagged
     record
        null;
     end record;

        -- --
        -- -- This is a static class, do not instantiate it
        -- --
        -- -- @codeCoverageIgnore
        -- --
        -- private function __construct() thenend;

        -- --
        -- -- Autoloader for Requests
        -- --
        -- -- Register this with then@see register_autoloader()end; if you"d like to avoid
        -- -- having to create your own.
        -- --
        -- -- (You can also use `spl_autoload_register` directly if you"d prefer.)
        -- --
        -- -- @codeCoverageIgnore
        -- --
        -- -- @param string class Class name to load
        -- --
        -- public static function autoloader(class) then
        --         -- Check that the class starts with "Requests"
        --         if (strpos(class, "Requests") !== 0) then
        --                 return;
        --         end;

        --         file = str_replace("_", "/", class);
        --         if (file_exists(dirname(__FILE__) . "/" . file . ".php")) then
        --                 require_once dirname(__FILE__) . "/" . file . ".php";
        --         end;
        -- end;

        -- --
        -- -- Register the built-in autoloader
        -- --
        -- -- @codeCoverageIgnore
        -- --
        -- public static function register_autoloader() then
        --         spl_autoload_register(array("Requests", "autoloader"));
        -- end;

        -- --
        -- -- Register a transport
        -- --
        -- -- @param string transport Transport class to add, must support the Requests_Transport interface
        -- --
        -- public static function add_transport(transport) then
        --         if (empty(self::transports)) then
        --                 self::transports = array(
        --                         "Requests_Transport_cURL",
        --                         "Requests_Transport_fsockopen",
        --                 );
        --         end;

        --         self::transports = array_merge(self::transports, array(transport));
        -- end;

   --
   -- Get a working transport
   --
   -- @throws Requests_Exception If no valid transport is found (`notransport`)
   -- @return Requests_Transport
   --
   -- protected static
   function Get_Transport (Capabilities : Array_Type := Empty_Array)
                           return Req_Transports.Requests_Transport
                           is (raise Program_Error with "not implemented");
        --         -- Caching code, don"t bother testing coverage
        --         -- @codeCoverageIgnoreStart
        --         -- array of capabilities as a string to be used as an array key
        --         ksort(capabilities);
        --         cap_string = serialize(capabilities);

        --         -- Don"t search for a transport if it"s already been done for these capabilities
        --         if (isset(self::transport[cap_string]) && self::transport[cap_string] !== null) then
        --                 class = self::transport[cap_string];
        --                 return new class();
        --         end;
        --         -- @codeCoverageIgnoreEnd

        --         if (empty(self::transports)) then
        --                 self::transports = array(
        --                         "Requests_Transport_cURL",
        --                         "Requests_Transport_fsockopen",
        --                 );
        --         end;

        --         -- Find us a working transport
        --         foreach (self::transports as class) then
        --                 if (!class_exists(class)) then
        --                         continue;
        --                 end;

        --                 result = call_user_func(array(class, "test"), capabilities);
        --                 if (result) then
        --                         self::transport[cap_string] = class;
        --                         break;
        --                 end;
        --         end;
        --         if (self::transport[cap_string] === null) then
        --                 throw new Requests_Exception("No working transports found", "notransport", self::transports);
        --         end;

        --         class = self::transport[cap_string];
        --         return new class();
        -- end;

        -- --#@+
        -- -- @see request()
        -- -- @param string url
        -- -- @param array headers
        -- -- @param array options
        -- -- @return Requests_Response
        -- --
        -- --
        -- -- Send a GET request
        -- --
        -- public static function get(url, headers = array(), options = array()) then
        --         return self::request(url, headers, null, self::GET, options);
        -- end;

        -- --
        -- -- Send a HEAD request
        -- --
        -- public static function head(url, headers = array(), options = array()) then
        --         return self::request(url, headers, null, self::HEAD, options);
        -- end;

        -- --
        -- -- Send a DELETE request
        -- --
        -- public static function delete(url, headers = array(), options = array()) then
        --         return self::request(url, headers, null, self::DELETE, options);
        -- end;

        -- --
        -- -- Send a TRACE request
        -- --
        -- public static function trace(url, headers = array(), options = array()) then
        --         return self::request(url, headers, null, self::TRACE, options);
        -- end;
        -- --#@-*/

        -- --#@+
        -- -- @see request()
        -- -- @param string url
        -- -- @param array headers
        -- -- @param array data
        -- -- @param array options
        -- -- @return Requests_Response
        -- --
        -- --
        -- -- Send a POST request
        -- --
        -- public static function post(url, headers = array(), data = array(), options = array()) then
        --         return self::request(url, headers, data, self::POST, options);
        -- end;
        -- --
        -- -- Send a PUT request
        -- --
        -- public static function put(url, headers = array(), data = array(), options = array()) then
        --         return self::request(url, headers, data, self::PUT, options);
        -- end;

        -- --
        -- -- Send an OPTIONS request
        -- --
        -- public static function options(url, headers = array(), data = array(), options = array()) then
        --         return self::request(url, headers, data, self::OPTIONS, options);
        -- end;

        -- --
        -- -- Send a PATCH request
        -- --
        -- -- Note: Unlike then@see postend; and then@see putend;, `headers` is required, as the
        -- -- specification recommends that should send an ETag
        -- --
        -- -- @link https://tools.ietf.org/html/rfc5789
        -- --
        -- public static function patch(url, headers, data = array(), options = array()) then
        --         return self::request(url, headers, data, self::PATCH, options);
        -- end;
        -- --#@-*/

   --
   -- Main interface for HTTP requests
   --
   -- This method initiates a request and sends it via a transport before
   -- parsing.
   --
   -- The `options` parameter takes an associative array with the following
   -- options:
   --
   -- - `timeout`: How long should we wait for a response?
   --    Note: for cURL, a minimum of 1 second applies, as DNS resolution
   --    operates at second-resolution only.
   --    (float, seconds with a millisecond precision, default: 10, example: 0.01)
   -- - `connect_timeout`: How long should we wait while trying to connect?
   --    (float, seconds with a millisecond precision, default: 10, example: 0.01)
   -- - `useragent`: Useragent to send to the server
   --    (string, default: php-requests/version)
   -- - `follow_redirects`: Should we follow 3xx redirects?
   --    (boolean, default: true)
   -- - `redirects`: How many times should we redirect before erroring?
   --    (integer, default: 10)
   -- - `blocking`: Should we block processing on this request?
   --    (boolean, default: true)
   -- - `filename`: File to stream the body to instead.
   --    (string|boolean, default: false)
   -- - `auth`: Authentication handler or array of user/password details to use
   --    for Basic authentication
   --    (Requests_Auth|array|boolean, default: false)
   -- - `proxy`: Proxy details to use for proxy by-passing and authentication
   --    (Requests_Proxy|array|string|boolean, default: false)
   -- - `max_bytes`: Limit for the response body size.
   --    (integer|boolean, default: false)
   -- - `idn`: Enable IDN parsing
   --    (boolean, default: true)
   -- - `transport`: Custom transport. Either a class name, or a
   --    transport object. Defaults to the first working transport from
   --    then@see getTransport()end;
   --    (string|Requests_Transport, default: then@see getTransport()end;)
   -- - `hooks`: Hooks handler.
   --    (Requests_Hooker, default: new Requests_Hooks())
   -- - `verify`: Should we verify SSL certificates? Allows passing in a custom
   --    certificate file as a string. (Using true uses the system-wide root
   --    certificate store instead, but this may have different behaviour
   --    across transports.)
   --    (string|boolean, default: library/Requests/Transport/cacert.pem)
   -- - `verifyname`: Should we verify the common name in the SSL certificate?
   --    (boolean, default: true)
   -- - `data_format`: How should we send the `data` parameter?
   --    (string, one of "query" or "body", default: "query" for
   --    HEAD/GET/DELETE, "body" for POST/PUT/OPTIONS/PATCH)
   --
   -- @throws Requests_Exception On invalid URLs (`nonhttp`)
   --
   -- @param string url URL to request
   -- @param array headers Extra headers to send with the request
   -- @param array|null data Data to send either as a query string for GET/HEAD
   --                         requests, or in the body for POST requests
   -- @param string type HTTP request type (use Requests constants)
   -- @param array options Options for the request (see description for more
   --                       information)
   -- @return Requests_Response
   --
   -- public static
   function Request ( -- This    : Requests;
                     URL     : String;
                     Headers : Array_Type := Empty_Array;
                     Data    : Array_Type := Empty_Array;
                     Typ     : String     := GET_Method; -- self::GET
                     Options : Array_Type := Empty_Array)
                     return Req_Responses.Requests_Response;

        -- --
        -- -- Send multiple HTTP requests simultaneously
        -- --
        -- -- The `requests` parameter takes an associative or indexed array of
        -- -- request fields. The key of each request can be used to match up the
        -- -- request with the returned data, or with the request passed into your
        -- -- `multiple.request.complete` callback.
        -- --
        -- -- The request fields value is an associative array with the following keys:
        -- --
        -- -- - `url`: Request URL Same as the `url` parameter to
        -- --    then@see Requests::requestend;
        -- --    (string, required)
        -- -- - `headers`: Associative array of header fields. Same as the `headers`
        -- --    parameter to then@see Requests::requestend;
        -- --    (array, default: `array()`)
        -- -- - `data`: Associative array of data fields or a string. Same as the
        -- --    `data` parameter to then@see Requests::requestend;
        -- --    (array|string, default: `array()`)
        -- -- - `type`: HTTP request type (use Requests constants). Same as the `type`
        -- --    parameter to then@see Requests::requestend;
        -- --    (string, default: `Requests::GET`)
        -- -- - `cookies`: Associative array of cookie name to value, or cookie jar.
        -- --    (array|Requests_Cookie_Jar)
        -- --
        -- -- If the `options` parameter is specified, individual requests will
        -- -- inherit options from it. This can be used to use a single hooking system,
        -- -- or set all the types to `Requests::POST`, for example.
        -- --
        -- -- In addition, the `options` parameter takes the following global options:
        -- --
        -- -- - `complete`: A callback for when a request is complete. Takes two
        -- --    parameters, a Requests_Response/Requests_Exception reference, and the
        -- --    ID from the request array (Note: this can also be overridden on a
        -- --    per-request basis, although that"s a little silly)
        -- --    (callback)
        -- --
        -- -- @param array requests Requests data (see description for more information)
        -- -- @param array options Global and default options (see then@see Requests::requestend;)
        -- -- @return array Responses (either Requests_Response or a Requests_Exception object)
        -- --
        -- public static function request_multiple(requests, options = array()) then
        --         options = array_merge(self::get_default_options(true), options);

        --         if (!empty(options["hooks"])) then
        --                 options["hooks"].register("transport.internal.parse_response", array("Requests", "parse_multiple"));
        --                 if (!empty(options["complete"])) then
        --                         options["hooks"].register("multiple.request.complete", options["complete"]);
        --                 end;
        --         end;

        --         foreach (requests as id => &request) then
        --                 if (!isset(request["headers"])) then
        --                         request["headers"] = array();
        --                 end;
        --                 if (!isset(request["data"])) then
        --                         request["data"] = array();
        --                 end;
        --                 if (!isset(request["type"])) then
        --                         request["type"] = self::GET;
        --                 end;
        --                 if (!isset(request["options"])) then
        --                         request["options"]         = options;
        --                         request["options"]["type"] = request["type"];
        --                 end;
        --                 else then
        --                         if (empty(request["options"]["type"])) then
        --                                 request["options"]["type"] = request["type"];
        --                         end;
        --                         request["options"] = array_merge(options, request["options"]);
        --                 end;

        --                 self::set_defaults(request["url"], request["headers"], request["data"], request["type"], request["options"]);

        --                 -- Ensure we only hook in once
        --                 if (request["options"]["hooks"] !== options["hooks"]) then
        --                         request["options"]["hooks"].register("transport.internal.parse_response", array("Requests", "parse_multiple"));
        --                         if (!empty(request["options"]["complete"])) then
        --                                 request["options"]["hooks"].register("multiple.request.complete", request["options"]["complete"]);
        --                         end;
        --                 end;
        --         end;
        --         unset(request);

        --         if (!empty(options["transport"])) then
        --                 transport = options["transport"];

        --                 if (is_string(options["transport"])) then
        --                         transport = new transport();
        --                 end;
        --         end;
        --         else then
        --                 transport = self::get_transport();
        --         end;
        --         responses = transport.request_multiple(requests, options);

        --         foreach (responses as id => &response) then
        --                 -- If our hook got messed with somehow, ensure we end up with the
        --                 -- correct response
        --                 if (is_string(response)) then
        --                         request = requests[id];
        --                         self::parse_multiple(response, request);
        --                         request["options"]["hooks"].dispatch("multiple.request.complete", array(&response, id));
        --                 end;
        --         end;

        --         return responses;
        -- end;

   --
   -- Get the default options
   --
   -- @see Requests::request() for values returned by this method
   -- @param boolean multirequest Is this a multirequest?
   -- @return array Default option values
   --
   -- protected static
   function Get_Default_Options (Multirequest : Boolean := False)
                                 return Array_Type;

   --
   -- Get default certificate path.
   --
   -- @return string Default certificate path.
   --
   -- public static
   function Get_Certificate_Path
            return String;

        -- --
        -- -- Set default certificate path.
        -- --
        -- -- @param string path Certificate path, pointing to a PEM file.
        -- --
        -- public static function set_certificate_path(path) then
        --         self::certificate_path = path;
        -- end;

   --
   -- Set the default values
   --
   -- @param string     url     URL to request
   -- @param array      headers Extra headers to send with the request
   -- @param array|null data    Data to send either as a query string for GET/HEAD
   --                            requests, or in the body for POST requests
   -- @param string     type    HTTP request type
   -- @param array      options Options for the request
   -- @return array options
   --
   -- protected static
   function Set_Defaults (URL     : in out String;           -- all &
                          Headers : in out Array_Type;
                          Data    : in out Array_Type;
                          Typ     : in out String;
                          Options : in out Array_Type)
                          return Array_Type;
        --         if (!preg_match("/^http(s)?:\/\//i", url, matches)) then
        --                 throw new Requests_Exception("Only HTTP(S) requests are handled.", "nonhttp", url);
        --         end;

        --         if (empty(options["hooks"])) then
        --                 options["hooks"] = new Requests_Hooks();
        --         end;

        --         if (is_array(options["auth"])) then
        --                 options["auth"] = new Requests_Auth_Basic(options["auth"]);
        --         end;
        --         if (options["auth"] !== false) then
        --                 options["auth"].register(options["hooks"]);
        --         end;

        --         if (is_string(options["proxy"]) || is_array(options["proxy"])) then
        --                 options["proxy"] = new Requests_Proxy_HTTP(options["proxy"]);
        --         end;
        --         if (options["proxy"] !== false) then
        --                 options["proxy"].register(options["hooks"]);
        --         end;

        --         if (is_array(options["cookies"])) then
        --                 options["cookies"] = new Requests_Cookie_Jar(options["cookies"]);
        --         end;
        --         elseif (empty(options["cookies"])) then
        --                 options["cookies"] = new Requests_Cookie_Jar();
        --         end;
        --         if (options["cookies"] !== false) then
        --                 options["cookies"].register(options["hooks"]);
        --         end;

        --         if (options["idn"] !== false) then
        --                 iri       = new Requests_IRI(url);
        --                 iri.host = Requests_IDNAEncoder::encode(iri.ihost);
        --                 url       = iri.uri;
        --         end;

        --         -- Massage the type to ensure we support it.
        --         type = strtoupper(type);

        --         if (!isset(options["data_format"])) then
        --                 if (in_array(type, array(self::HEAD, self::GET, self::DELETE), true)) then
        --                         options["data_format"] = "query";
        --                 end;
        --                 else then
        --                         options["data_format"] = "body";
        --                 end;
        --         end;
        -- end;

   --
   -- HTTP response parser
   --
   -- @throws Requests_Exception On missing head/body separator
   --          (`requests.no_crlf_separator`)
   -- @throws Requests_Exception On missing head/body separator (`noversion`)
   -- @throws Requests_Exception On missing head/body separator (`toomanyredirects`)
   --
   -- @param string headers     Full response text including headers and body
   -- @param string url         Original request URL
   -- @param array  req_headers Original headers array passed to {@link request()},
   --                           in case we need to follow redirects
   -- @param array  req_data    Original data array passed to {@link request()}, in
   --                           case we need to follow redirects
   -- @param array  options     Original options array passed to {@link request()}, in
   --                           case we need to follow redirects
   -- @return Requests_Response
   --
   -- protected static
   function Parse_Response (Headers     : String;
                            URL         : String;
                            Req_Headers : Array_Type;
                            Req_Data    : Array_Type;
                            Options     : Array_Type)
                            return Req_Responses.Requests_Response;

        -- --
        -- -- Callback for `transport.internal.parse_response`
        -- --
        -- -- Internal use only. Converts a raw HTTP response to a Requests_Response
        -- -- while still executing a multiple request.
        -- --
        -- -- @param string response Full response text including headers and body (will be overwritten with Response instance)
        -- -- @param array request Request data as passed into then@see Requests::request_multiple()end;
        -- -- @return null `response` is either set to a Requests_Response instance, or a Requests_Exception object
        -- --
        -- public static function parse_multiple(&response, request) then
        --         try then
        --                 url      = request["url"];
        --                 headers  = request["headers"];
        --                 data     = request["data"];
        --                 options  = request["options"];
        --                 response = self::parse_response(response, url, headers, data, options);
        --         end;
        --         catch (Requests_Exception e) then
        --                 response = e;
        --         end;
        -- end;

        -- --
        -- -- Decoded a chunked body as per RFC 2616
        -- --
        -- -- @see https://tools.ietf.org/html/rfc2616#section-3.6.1
        -- -- @param string data Chunked body
        -- -- @return string Decoded body
        -- --
        -- protected static function decode_chunked(data) then
        --         if (!preg_match("/^([0-9a-f]+)(?:;(?:[\w-]*)(?:=(?:(?:[\w-]*)*|"(?:[^\r\n])*"))?)*\r\n/i", trim(data))) then
        --                 return data;
        --         end;

        --         decoded = "";
        --         encoded = data;

        --         while (true) then
        --                 is_chunked = (bool) preg_match("/^([0-9a-f]+)(?:;(?:[\w-]*)(?:=(?:(?:[\w-]*)*|"(?:[^\r\n])*"))?)*\r\n/i", encoded, matches);
        --                 if (!is_chunked) then
        --                         -- Looks like it"s not chunked after all
        --                         return data;
        --                 end;

        --                 length = hexdec(trim(matches[1]));
        --                 if (length === 0) then
        --                         -- Ignore trailer headers
        --                         return decoded;
        --                 end;

        --                 chunk_length = strlen(matches[0]);
        --                 decoded     .= substr(encoded, chunk_length, length);
        --                 encoded      = substr(encoded, chunk_length + length + 2);

        --                 if (trim(encoded) === "0" || empty(encoded)) then
        --                         return decoded;
        --                 end;
        --         end;

        --         -- We"ll never actually get down here
        --         -- @codeCoverageIgnoreStart
        -- end;
        -- -- @codeCoverageIgnoreEnd

        -- --
        -- -- Convert a key => value array to a "key: value" array for headers
        -- --
        -- -- @param array array Dictionary of header values
        -- -- @return array List of headers
        -- --
        -- public static function flatten(array) then
        --         return = array();
        --         foreach (array as key => value) then
        --                 return[] = sprintf("%s: %s", key, value);
        --         end;
        --         return return;
        -- end;

        -- --
        -- -- Convert a key => value array to a "key: value" array for headers
        -- --
        -- -- @codeCoverageIgnore
        -- -- @deprecated Misspelling of then@see Requests::flattenend;
        -- -- @param array array Dictionary of header values
        -- -- @return array List of headers
        -- --
        -- public static function flattern(array) then
        --         return self::flatten(array);
        -- end;

        -- --
        -- -- Decompress an encoded body
        -- --
        -- -- Implements gzip, compress and deflate. Guesses which it is by attempting
        -- -- to decode.
        -- --
        -- -- @param string data Compressed data in one of the above formats
        -- -- @return string Decompressed string
        -- --
        -- public static function decompress(data) then
        --         if (substr(data, 0, 2) !== "\x1f\x8b" && substr(data, 0, 2) !== "\x78\x9c") then
        --                 -- Not actually compressed. Probably cURL ruining this for us.
        --                 return data;
        --         end;

        --         if (function_exists("gzdecode")) then
        --                 -- phpcs:ignore PHPCompatibility.FunctionUse.NewFunctions.gzdecodeFound -- Wrapped in function_exists() for PHP 5.2.
        --                 decoded = @gzdecode(data);
        --                 if (decoded !== false) then
        --                         return decoded;
        --                 end;
        --         end;

        --         if (function_exists("gzinflate")) then
        --                 decoded = @gzinflate(data);
        --                 if (decoded !== false) then
        --                         return decoded;
        --                 end;
        --         end;

        --         decoded = self::compatible_gzinflate(data);
        --         if (decoded !== false) then
        --                 return decoded;
        --         end;

        --         if (function_exists("gzuncompress")) then
        --                 decoded = @gzuncompress(data);
        --                 if (decoded !== false) then
        --                         return decoded;
        --                 end;
        --         end;

        --         return data;
        -- end;

        -- --
        -- -- Decompression of deflated string while staying compatible with the majority of servers.
        -- --
        -- -- Certain Servers will return deflated data with headers which PHP"s gzinflate()
        -- -- function cannot handle out of the box. The following function has been created from
        -- -- various snippets on the gzinflate() PHP documentation.
        -- --
        -- -- Warning: Magic numbers within. Due to the potential different formats that the compressed
        -- -- data may be returned in, some "magic offsets" are needed to ensure proper decompression
        -- -- takes place. For a simple progmatic way to determine the magic offset in use, see:
        -- -- https://core.trac.wordpress.org/ticket/18273
        -- --
        -- -- @since 2.8.1
        -- -- @link https://core.trac.wordpress.org/ticket/18273
        -- -- @link https://secure.php.net/manual/en/function.gzinflate.php#70875
        -- -- @link https://secure.php.net/manual/en/function.gzinflate.php#77336
        -- --
        -- -- @param string gz_data String to decompress.
        -- -- @return string|bool False on failure.
        -- --
        -- public static function compatible_gzinflate(gz_data) then
        --         -- Compressed data might contain a full zlib header, if so strip it for
        --         -- gzinflate()
        --         if (substr(gz_data, 0, 3) === "\x1f\x8b\x08") then
        --                 i   = 10;
        --                 flg = ord(substr(gz_data, 3, 1));
        --                 if (flg > 0) then
        --                         if (flg & 4) then
        --                                 list(xlen) = unpack("v", substr(gz_data, i, 2));
        --                                 i         += 2 + xlen;
        --                         end;
        --                         if (flg & 8) then
        --                                 i = strpos(gz_data, "\0", i) + 1;
        --                         end;
        --                         if (flg & 16) then
        --                                 i = strpos(gz_data, "\0", i) + 1;
        --                         end;
        --                         if (flg & 2) then
        --                                 i += 2;
        --                         end;
        --                 end;
        --                 decompressed = self::compatible_gzinflate(substr(gz_data, i));
        --                 if (decompressed !== false) then
        --                         return decompressed;
        --                 end;
        --         end;

        --         -- If the data is Huffman Encoded, we must first strip the leading 2
        --         -- byte Huffman marker for gzinflate()
        --         -- The response is Huffman coded by many compressors such as
        --         -- java.util.zip.Deflater, Ruby’s Zlib::Deflate, and .NET"s
        --         -- System.IO.Compression.DeflateStream.
        --         //
        --         -- See https://decompres.blogspot.com/ for a quick explanation of this
        --         -- data type
        --         huffman_encoded = false;

        --         -- low nibble of first byte should be 0x08
        --         list(, first_nibble) = unpack("h", gz_data);

        --         -- First 2 bytes should be divisible by 0x1F
        --         list(, first_two_bytes) = unpack("n", gz_data);

        --         if (first_nibble === 0x08 && (first_two_bytes % 0x1F) === 0) then
        --                 huffman_encoded = true;
        --         end;

        --         if (huffman_encoded) then
        --                 decompressed = @gzinflate(substr(gz_data, 2));
        --                 if (decompressed !== false) then
        --                         return decompressed;
        --                 end;
        --         end;

        --         if (substr(gz_data, 0, 4) === "\x50\x4b\x03\x04") then
        --                 -- ZIP file format header
        --                 -- Offset 6: 2 bytes, General-purpose field
        --                 -- Offset 26: 2 bytes, filename length
        --                 -- Offset 28: 2 bytes, optional field length
        --                 -- Offset 30: Filename field, followed by optional field, followed
        --                 -- immediately by data
        --                 list(, general_purpose_flag) = unpack("v", substr(gz_data, 6, 2));

        --                 -- If the file has been compressed on the fly, 0x08 bit is set of
        --                 -- the general purpose field. We can use this to differentiate
        --                 -- between a compressed document, and a ZIP file
        --                 zip_compressed_on_the_fly = ((0x08 & general_purpose_flag) === 0x08);

        --                 if (!zip_compressed_on_the_fly) then
        --                         -- Don"t attempt to decode a compressed zip file
        --                         return gz_data;
        --                 end;

        --                 -- Determine the first byte of data, based on the above ZIP header
        --                 -- offsets:
        --                 first_file_start = array_sum(unpack("v2", substr(gz_data, 26, 4)));
        --                 decompressed     = @gzinflate(substr(gz_data, 30 + first_file_start));
        --                 if (decompressed !== false) then
        --                         return decompressed;
        --                 end;
        --                 return false;
        --         end;

        --         -- Finally fall back to straight gzinflate
        --         decompressed = @gzinflate(gz_data);
        --         if (decompressed !== false) then
        --                 return decompressed;
        --         end;

        --         -- Fallback for all above failing, not expected, but included for
        --         -- debugging and preventing regressions and to track stats
        --         decompressed = @gzinflate(substr(gz_data, 2));
        --         if (decompressed !== false) then
        --                 return decompressed;
        --         end;

        --         return false;
        -- end;

        -- public static function match_domain(host, reference) then
        --         -- Check for a direct match
        --         if (host === reference) then
        --                 return true;
        --         end;

        --         -- Calculate the valid wildcard match if the host is not an IP address
        --         -- Also validates that the host has 3 parts or more, as per Firefox"s
        --         -- ruleset.
        --         parts = explode(".", host);
        --         if (ip2long(host) === false && count(parts) >= 3) then
        --                 parts[0] = "*";
        --                 wildcard = implode(".", parts);
        --                 if (wildcard === reference) then
        --                         return true;
        --                 end;
        --         end;

        --         return false;
        -- end;

   --
   -- Selected transport name
   --
   -- Use {@see get_transport()} instead
   --
   -- @var array
   --
   -- public static
   Transport : Array_Type;

private

   --
   -- Registered transport classes
   --
   -- @var array
   --
   -- protected static
   Transports : Array_Type;

   --
   -- Default certificate path.
   --
   -- @see Requests::get_certificate_path()
   -- @see Requests::set_certificate_path()
   --
   -- @var string
   --
   -- protected static
   Certificate_Path : Ada.Strings.Unbounded.Unbounded_String;

end Inc_Class_Requests;
