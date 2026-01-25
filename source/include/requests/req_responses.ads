--
-- HTTP response class
--
-- Contains a response from Requests::request()
-- @package Requests
--

with Arrays;
with Lists;
with UStrings;

package Req_Responses
is
   use Arrays;
   use Lists;

   --
   -- HTTP response class
   --
   -- Contains a response from Requests::request()
   -- @package Requests
   --
   type Requests_Response is tagged
     record
        --
        -- Response body
        --
        -- @var string
        --
        Bodi : UStrings.UString;

        --
        -- Raw HTTP data from the transport
        --
        -- @var string
        --
        Raw : UStrings.UString;

        --
        -- Headers, as an associative array
        --
        -- @var Requests_Response_Headers Array-like object representing headers
        --
        Headers : Array_Type;

        --
        -- Status code, false if non-blocking
        --
        -- @var integer|boolean
        --
        Status_Code : Integer := 0; --  = false;

        --
        -- Protocol version, false if non-blocking
        --
        -- @var float|boolean
        --
        Protocol_Version : UStrings.UString; --  = false;

        --
        -- Whether the request succeeded or not
        --
        -- @var boolean
        --
        Success : Boolean := False;

        --
        -- Number of redirects the request used
        --
        -- @var integer
        --
        Redirects : Natural := 0;

        --
        -- URL requested
        --
        -- @var string
        --
        URL : UStrings.UString;

        --
        -- Previous requests (from redirects)
        --
        -- @var array Array of Requests_Response objects
        --
        History : List_Type;

        -- --
        -- -- Cookies from the request
        -- --
        -- -- @var Requests_Cookie_Jar Array-like object representing a cookie jar
        -- --
        -- public cookies = array();
     end record;

   --
   -- Constructor
   --
   function X_Construct
            return Requests_Response;

   --
   --
   -- Is the response a redirect?
   --
   -- @return boolean True if redirect (3xx status), false if not.
   --
   function Is_Redirect (This : Requests_Response)
                         return Boolean;

        -- --
        -- -- Throws an exception if the request was not successful
        -- --
        -- -- @throws Requests_Exception If `allow_redirects` is false, and code is 3xx (`response.no_redirects`)
        -- -- @throws Requests_Exception_HTTP On non-successful status code. Exception class corresponds to code (e.g. then@see Requests_Exception_HTTP_404end;)
        -- -- @param boolean allow_redirects Set to false to throw on a 3xx as well
        -- --
        -- public function throw_for_status(allow_redirects = true) then
        --         if (this.is_redirect()) then
        --                 if (!allow_redirects) then
        --                         throw new Requests_Exception("Redirection not allowed", "response.no_redirects", this);
        --                 end;
        --         end;
        --         elseif (!this.success) then
        --                 exception = Requests_Exception_HTTP::get_class(this.status_code);
        --                 throw new exception(null, this);
        --         end;
        -- end;

end Req_Responses;
