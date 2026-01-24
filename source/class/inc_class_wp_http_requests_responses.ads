--
-- HTTP API: WP_HTTP_Requests_Response class
--
-- @package WordPress
-- @subpackage HTTP
-- @since 4.6.0
--

with Ada.Strings.Unbounded;

with Arrays;
with Lists;

with Inc_Class_Wp_HTTP_Responses;

with Req_Responses;

package Inc_Class_Wp_HTTP_Requests_Responses
is
   use Arrays;
   use Lists;

   --
   -- Core wrapper object for a Requests_Response for standardisation.
   --
   -- @since 4.6.0
   --
   -- @see WP_HTTP_Response
   --
   type Wp_HTTP_Requests_Response is
     new Inc_Class_Wp_HTTP_Responses.Wp_HTTP_Response with
     record
        --
        -- Requests Response object.
        --
        -- @since 4.6.0
        -- @var Requests_Response
        --
        -- protected
        Response : Req_Responses.Requests_Response;

        --
        -- Filename the response was saved to.
        --
        -- @since 4.6.0
        -- @var string|null
        --
        -- protected
        Filename : Ada.Strings.Unbounded.Unbounded_String;

     end record;

   --
   -- Constructor.
   --
   -- @since 4.6.0
   --
   -- @param Requests_Response response HTTP response.
   -- @param string            filename Optional. File name. Default empty.
   --
   function X_Construct (Response : Req_Responses.Requests_Response;
                         Filename : String := "")
                         return Wp_HTTP_Requests_Response;

        -- --
        -- -- Retrieves the response object for the request.
        -- --
        -- -- @since 4.6.0
        -- --
        -- -- @return Requests_Response HTTP response.
        -- --
        -- public function get_response_object() then
        --         return this.response;
        -- end;

   --
   -- Retrieves headers associated with the response.
   --
   -- @since 4.6.0
   --
   -- @return \Requests_Utility_CaseInsensitiveDictionary Map of header name to
   --         header value.
   --
   function Get_Headers (This : Wp_HTTP_Requests_Response)
                         return String;

        -- --
        -- -- Sets all header values.
        -- --
        -- -- @since 4.6.0
        -- --
        -- -- @param array headers Map of header name to header value.
        -- --
        -- public function set_headers( headers ) then
        --         this.response.headers = new Requests_Response_Headers( headers );
        -- end;

        -- --
        -- -- Sets a single HTTP header.
        -- --
        -- -- @since 4.6.0
        -- --
        -- -- @param string key     Header name.
        -- -- @param string value   Header value.
        -- -- @param bool   replace Optional. Whether to replace an existing header of the same name.
        -- --                        Default true.
        -- --
        -- public function header( key, value, replace = true ) then
        --         if ( replace ) then
        --                 unset( this.response.headers[ key ] );
        --         end;

        --         this.response.headers[ key ] = value;
        -- end;

   --
   -- Retrieves the HTTP return code for the response.
   --
   -- @since 4.6.0
   --
   -- @return int The 3-digit HTTP status code.
   --
   function Get_Status (This : Wp_HTTP_Requests_Response)
                        return Integer;

        -- --
        -- -- Sets the 3-digit HTTP status code.
        -- --
        -- -- @since 4.6.0
        -- --
        -- -- @param int code HTTP status.
        -- --
        -- public function set_status( code ) then
        --         this.response.status_code = absint( code );
        -- end;

   --
   -- Retrieves the response data.
   --
   -- @since 4.6.0
   --
   -- @return string Response data.
   --
   function Get_Data (This : Wp_HTTP_Requests_Response)
                      return String;

        -- --
        -- -- Sets the response data.
        -- --
        -- -- @since 4.6.0
        -- --
        -- -- @param string data Response data.
        -- --
        -- public function set_data( data ) then
        --         this.response.body = data;
        -- end;

   --
   -- Retrieves cookies from the response.
   --
   -- @since 4.6.0
   --
   -- @return WP_HTTP_Cookie[] List of cookie objects.
   --
   function Get_Cookies (This : Wp_HTTP_Requests_Response)
                         return List_Type;

   --
   -- Converts the object to a WP_Http response array.
   --
   -- @since 4.6.0
   --
   -- @return array WP_Http response array, per WP_Http::request().
   --
   function To_Array (This : Wp_HTTP_Requests_Response)
                      return Array_Type;
        --         return array(
        --                 "headers"  => this.get_headers(),
        --                 "body"     => this.get_data(),
        --                 "response" => array(
        --                         "code"    => this.get_status(),
        --                         "message" => get_status_header_desc( this.get_status() ),
        --                 ),
        --                 "cookies"  => this.get_cookies(),
        --                 "filename" => this.filename,
        --         );
        -- end;

end Inc_Class_Wp_HTTP_Requests_Responses;
