--
-- HTTP response class
--
-- Contains a response from Requests::request()
-- @package Requests
--

package body Req_Responses
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
            return Requests_Response
   is
      This : Requests_Response;
   begin
      return This;
   end X_Construct;

   -----------------
   -- Is_Redirect --
   -----------------

   function Is_Redirect (This : Requests_Response)
                         return Boolean
   is
      Code : constant Integer := This.Status_Code;
   begin
      return Code in 300 .. 303 | 307 | 308 .. 399;
   end Is_Redirect;

end Req_Responses;
