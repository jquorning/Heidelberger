--
-- Base HTTP transport
--
-- @package Requests
-- @subpackage Transport
--

with Arrays;

package Req_Transports
is
   use Arrays;

   --
   -- Base HTTP transport
   --
   -- @package Requests
   -- @subpackage Transport
   --
   type Requests_Transport is tagged null record; -- interface; --  then

   --
   -- Perform a request
   --
   -- @param string url URL to request
   -- @param array        headers Associative array of request headers
   -- @param string|array data    Data to send either as the POST body, or as
   --                             parameters in the URL for a GET/HEAD
   -- @param array        options Request options, see {@see Requests::response()}
   --                             for documentation
   -- @return string Raw HTTP result
   --
   function Request (This    : in out Requests_Transport;
                     URL     : String;
                     Headers : Array_Type := Empty_Array;
                     Data    : Array_Type := Empty_Array;
                     Options : Array_Type := Empty_Array)
                     return String;

        -- --
        -- -- Send multiple requests simultaneously
        -- --
        -- -- @param array requests Request data (array of 'url', 'headers', 'data', 'options') as per then@see Requests_Transport::requestend;
        -- -- @param array options Global options, see then@see Requests::response()end; for documentation
        -- -- @return array Array of Requests_Response objects (may contain Requests_Exception or string responses as well)
        -- --
        -- public function request_multiple(requests, options);

        -- --
        -- -- Self-test whether the transport can be used
        -- -- @return bool
        -- --
        -- public static function test();

end Req_Transports;
