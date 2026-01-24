--
-- HTTP API: WP_HTTP_Response class
--
-- @package WordPress
-- @subpackage HTTP
-- @since 4.4.0
--

package Class_HTTP_Responses
is

   --
   -- Core class used to prepare HTTP responses.
   --
   -- @since 4.4.0
   --
   -- #[AllowDynamicProperties]
   type Wp_HTTP_Response is tagged
     record
        --
        -- Response data.
        --
        -- @since 4.4.0
        -- @var mixed
        --
--        public data;

        --
        -- Response headers.
        --
        -- @since 4.4.0
        -- @var array
        --
--        public headers;

        --
        -- Response status.
        --
        -- @since 4.4.0
        -- @var int
        --
--        public status;

        null;

     end record;

        -- --
        -- -- Constructor.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @param mixed data    Response data. Default null.
        -- -- @param int   status  Optional. HTTP status code. Default 200.
        -- -- @param array headers Optional. HTTP header map. Default empty array.
        -- --
        -- public function __construct( data = null, status = 200, headers = array() ) then
        --         this.set_data( data );
        --         this.set_status( status );
        --         this.set_headers( headers );
        -- end;

        -- --
        -- -- Retrieves headers associated with the response.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @return array Map of header name to header value.
        -- --
        -- public function get_headers() then
        --         return this.headers;
        -- end;

        -- --
        -- -- Sets all header values.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @param array headers Map of header name to header value.
        -- --
        -- public function set_headers( headers ) then
        --         this.headers = headers;
        -- end;

        -- --
        -- -- Sets a single HTTP header.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @param string key     Header name.
        -- -- @param string value   Header value.
        -- -- @param bool   replace Optional. Whether to replace an existing header of the same name.
        -- --                        Default true.
        -- --
        -- public function header( key, value, replace = true ) then
        --         if ( replace || ! isset( this.headers[ key ] ) ) then
        --                 this.headers[ key ] = value;
        --         end; else then
        --                 this.headers[ key ] .= ", " . value;
        --         end;
        -- end;

        -- --
        -- -- Retrieves the HTTP return code for the response.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @return int The 3-digit HTTP status code.
        -- --
        -- public function get_status() then
        --         return this.status;
        -- end;

        -- --
        -- -- Sets the 3-digit HTTP status code.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @param int code HTTP status.
        -- --
        -- public function set_status( code ) then
        --         this.status = absint( code );
        -- end;

        -- --
        -- -- Retrieves the response data.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @return mixed Response data.
        -- --
        -- public function get_data() then
        --         return this.data;
        -- end;

        -- --
        -- -- Sets the response data.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @param mixed data Response data.
        -- --
        -- public function set_data( data ) then
        --         this.data = data;
        -- end;

        -- --
        -- -- Retrieves the response data for JSON serialization.
        -- --
        -- -- It is expected that in most implementations, this will return the same as get_data(),
        -- -- however this may be different if you want to do custom JSON data handling.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @return mixed Any JSON-serializable value.
        -- --
        -- public function jsonSerialize() then // phpcs:ignore WordPress.NamingConventions.ValidFunctionName.MethodNameInvalid
        --         return this.get_data();
        -- end;

end Class_HTTP_Responses;
