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

package Inc_Http
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

end Inc_Http;
