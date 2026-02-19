--
-- Base HTTP transport
--
-- @package Requests
-- @subpackage Transport
--

with AWS.Client;
with AWS.Headers;
with AWS.Response;

-- with Arrays.IO;
with Logging;
with UStrings;

package body Req_Transports
is

   -------------
   -- Request --
   -------------

   function Request (This    : in out Requests_Transport;
                     URL     : String;
                     Headers : Array_Type := Empty_Array;
                     Data    : Array_Type := Empty_Array;
                     Options : Array_Type := Empty_Array)
                     return String
   is
      use UStrings;
   begin
      Logging.Log ("request", URL);
      -- Arrays.IO.Dump (Headers);
      -- Arrays.IO.Dump (Data);
      -- Arrays.IO.Dump (Options);

      declare
         Data : constant AWS.Response.Data := AWS.Client.Get (URL);
         Head : constant AWS.Headers.List  := AWS.Response.Header (Data);
         Buf  : UString;
      begin
         Append (Buf, "HTTP/1.1 200 OK" & CR & LF);
         Append (Buf, CR & LF);
         Append (Buf, UString'(AWS.Response.Message_Body (Data)));

         return -Buf;
      end;
   end Request;

end Req_Transports;
