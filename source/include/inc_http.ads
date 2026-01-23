--
-- Core HTTP Request API
--
-- Standardizes the HTTP requests for WordPress. Handles cookies, gzip encoding and decoding, chunk
-- decoding, if HTTP 1.1 and various other difficult HTTP protocol implementations.
--
-- @package WordPress
-- @subpackage HTTP
--

with Arrays;
-- with Lists;

package Inc_HTTP
is
   use Arrays;
-- use Lists;

   --
   -- Returns the initialized WP_Http Object
   --
   -- @since 2.7.0
   -- @access private
   --
   -- @return WP_Http HTTP Transport object.
   --
--   function X_Wp_HTTP_Get_Object
--            return Wp_Http;

   --
   -- Performs an HTTP request using the GET method and returns its response.
   --
   -- @since 2.7.0
   --
   -- @see wp_remote_request() For more information on the response array format.
   -- @see WP_Http::request() For default arguments information.
   --
   -- @param string url  URL to retrieve.
   -- @param array  args Optional. Request arguments. Default empty array.
   -- @return array|WP_Error The response or WP_Error on failure.
   --
   function Wp_Remote_Get (Url  : String;
                           Args : Array_Type := Empty_Array)
                           return Array_Type
                           is (Empty_Array);

   --
   -- Performs an HTTP request using the POST method and returns its response.
   --
   -- @since 2.7.0
   --
   -- @see wp_remote_request() For more information on the response array format.
   -- @see WP_Http::request() For default arguments information.
   --
   -- @param string url  URL to retrieve.
   -- @param array  args Optional. Request arguments. Default empty array.
   -- @return array|WP_Error The response or WP_Error on failure.
   --
   function Wp_Remote_Post (URL  : String;
                            Args : Array_Type := Empty_Array)
                            return Array_Type;

   --
   -- Determines if there is an HTTP Transport that can process this request.
   --
   -- @since 3.2.0
   --
   -- @param array  capabilities Array of capabilities to test or a
   --                             wp_remote_request() args array.
   -- @param string url          Optional. If given, will check if the URL requires
   --                             SSL and adds that requirement to the capabilities
   --                             array.
   --
   -- @return bool
   --
   function Wp_HTTP_Supports (Capabilities : Array_Type := Empty_Array;
   -- List_Type := Empty_List;
                              URL          : String := "") -- null
                              return Boolean;

   --
   -- A wrapper for PHP"s parse_url() function that handles consistency in the
   -- return values across PHP versions.
   --
   -- PHP 5.4.7 expanded parse_url()"s ability to handle non-absolute URLs, including
   -- schemeless and relative URLs with "://" in the path. This function works around
   -- those limitations providing a standard output on PHP 5.2~5.4+.
   --
   -- Secondly, across various PHP versions, schemeless URLs containing a ":" in the
   -- query are being handled inconsistently. This function works around those
   -- differences as well.
   --
   -- @since 4.4.0
   -- @since 4.7.0 The `component` parameter was added for parity with PHP"s
   --              `parse_url()`.
   --
   -- @link https://www.php.net/manual/en/function.parse-url.php
   --
   -- @param string url       The URL to parse.
   -- @param int    component The specific component to retrieve. Use one of the PHP
   --                          predefined constants to specify which one.
   --                          Defaults to -1 (= return all parts as an array).
   -- @return mixed False on parse failure; Array of URL components on success;
   --               When a specific component has been requested: null if the component
   --               doesn't exist in the given URL; a string or - in the case of
   --               PHP_URL_PORT - integer when it does. See parse_url()'s return
   --               values.
   --
   function Wp_Parse_URL (URL       : String;
                          Component : Integer := -1)
                          return Array_Type;

   function Wp_Parse_URL (URL       : String;
                          Component : Integer := -1)
                          return String;

   --
   -- Retrieve a specific component from a parsed URL array.
   --
   -- @internal
   --
   -- @since 4.7.0
   -- @access private
   --
   -- @link https://www.php.net/manual/en/function.parse-url.php
   --
   -- @param array|false url_parts The parsed URL. Can be false if the URL failed
   --                               to parse.
   -- @param int         component The specific component to retrieve. Use one of the
   --                               PHP predefined constants to specify which one.
   --                               Defaults to -1 (= return all parts as an array).
   -- @return mixed False on parse failure; Array of URL components on success;
   --               When a specific component has been requested: null if the component
   --               doesn't exist in the given URL; a string or - in the case of
   --               PHP_URL_PORT - integer when it does. See parse_url()'s return
   --               values.
   --
   function X_Get_Component_From_Parsed_URL_Array (URL_Parts : Array_Type;
                                                   Component : Integer := -1)
                                                   return Array_Type;

   --
   -- Translate a PHP_URL_* constant to the named array keys PHP uses.
   --
   -- @internal
   --
   -- @since 4.7.0
   -- @access private
   --
   -- @link https://www.php.net/manual/en/url.constants.php
   --
   -- @param int constant PHP_URL_* constant.
   -- @return string|false The named key or false.
   --
   function X_Wp_Translate_PHP_URL_Constant_To_Key (Component : Integer)
                                                    return String;

   --
   -- Retrieve only the body from the raw response.
   --
   -- @since 2.7.0
   --
   -- @param array|WP_Error response HTTP response.
   -- @return string The body of the response. Empty string if no body or incorrect
   --                 parameter given.
   --
   function Wp_Remote_Retrieve_Body (Response : Array_Type)
                                     return String;

end Inc_HTTP;
