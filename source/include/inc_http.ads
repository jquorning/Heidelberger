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

package Inc_Http
is
   use Arrays;

   procedure Dummy;

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

end Inc_Http;
