--
-- Requests for PHP
--
-- Inspired by Requests for Python.
--
-- Based on concepts from SimplePie_File, RequestCore and WP_Http.
--
-- @package Requests
--

with Php.Arrays;
with Php.Files;
with Php.Lists;
with Php.Preg;
with Php.Strings;

with Lists;

package body Class_Requests
is
   use Lists;

   -------------
   -- Request --
   -------------

   function Request (URL     : String;
                     Headers : Array_Type := Empty_Array;
                     Data    : Array_Type := Empty_Array;
                     Typ     : String     := GET_Method; -- self::GET,;
                     Options : Array_Type := Empty_Array)
                     return Req_Responses.Requests_Response
   is
      use Php.Arrays;
      use Php.Strings;

      URL_2     : String     := URL;
      Headers_2 : Array_Type := Headers;
      Data_2    : Array_Type := Data;
      Typ_2     : String     := Typ;
      Options_2 : Array_Type := Options;
      Unused : Array_Type;
      Transport : access Req_Transports.Requests_Transport;
   begin
      if Empty (Options_2, "type") then
         Set (Options_2, "type", From_String (Typ));
      end if;

      Options_2 := Array_Merge (Get_Default_Options, Options_2); -- self::

      Unused := Set_Defaults (URL_2, Headers_2, Data_2, Typ_2, Options_2); -- self::

--    options["hooks"].dispatch("requests.before_request", array(&url, &headers, &data, &type, &options));

      if not Empty (Options_2, "transport") then
         declare
            Transport2 : String := Get_As_String (Options_2, "transport");
         begin
            if Kind_Of (Get (Options_2, "transport")) in Kind_String then
               null;
--             Transport := new Transport2; -- ()
            end if;
         end;
      else
         declare
            Need_SSL : constant Boolean := Stripos (URL_2, "https://") = 0;

            Capabilities : Array_Type := To_Array (List => (1 =>
              Build ("ssl", Need_SSL)));

         begin
            null;
--          Transport := Get_Transport (Capabilities); -- self::
         end;
      end if;

      declare
         Response : constant String := "XXX-974";
--         Transport.Request (URL_2, Headers_2, Data_2, Options_2);
      begin

--       options["hooks"].dispatch("requests.before_parse", array(&response, url, headers, data, type, options));

         return Parse_Response (Response, URL_2, Headers_2, Data_2, Options_2);
         -- self::
      end;
   end Request;

   ------------------------
   -- Get_Default_Option --
   ------------------------

   function Get_Default_Options (Multirequest : Boolean := False)
                                 return Array_Type
   is
      Defaults : Array_Type := To_Array (List => (
        Build ("timeout",          10),
        Build ("connect_timeout",  10),
        Build ("useragent",        "php-requests/" & VERSION), -- self::, change case
        Build ("protocol_version", "1.1"), -- "" added
        Build ("redirected",       0),
        Build ("redirects",        10),
        Build ("follow_redirects", True),
        Build ("blocking",         True),
        Build ("type",             GET_Method), -- self::
        Build ("filename",         False),
        Build ("auth",             False),
        Build ("proxy",            False),
        Build ("cookies",          False),
        Build ("max_bytes",        False),
        Build ("idn",              True),
        Build ("hooks",            Null_Value),
        Build ("transport",        Null_Value),
        Build ("verify",           Get_Certificate_Path), -- self::
        Build ("verifyname",       True)
      ));
   begin
      if Multirequest then
         Set (Defaults, "complete", From_Null);
      end if;
      return Defaults;
   end Get_Default_Options;

   --------------------------
   -- Get_Certificate_Path --
   --------------------------

   function Get_Certificate_Path
            return String
   is
      use Php.Files;
      use Php.Strings;
      use UStrings;
   begin
      if not Empty (-Certificate_Path) then -- self::
         return -Certificate_Path; -- self::
      end if;

      return Dirname ("__FILE__") & "/Requests/Transport/cacert.pem";
   end Get_Certificate_Path;

   ------------------
   -- Set_Defaults --
   ------------------

   function Set_Defaults (URL     : in out String;           -- all &
                          Headers : in out Array_Type;
                          Data    : in out Array_Type;
                          Typ     : in out String;
                          Options : in out Array_Type)
                          return Array_Type
   is
      use Php.Lists;
      use Php.Strings;
   begin
      -- if (!preg_match("/^http(s)?:\/\//i", url, matches)) then
      --    throw new Requests_Exception
      --      ("Only HTTP(S) requests are handled.", "nonhttp", url);
      -- end;

      -- if (empty(options["hooks"])) then
      --    options["hooks"] = new Requests_Hooks();
      -- end;

      -- if (is_array(options["auth"])) then
      --    options["auth"] = new Requests_Auth_Basic(options["auth"]);
      -- end;
      -- if (options["auth"] !== false) then
      --    options["auth"].register(options["hooks"]);
      -- end;

      -- if (is_string(options["proxy"]) || is_array(options["proxy"])) then
      --    options["proxy"] = new Requests_Proxy_HTTP(options["proxy"]);
      -- end;
      -- if (options["proxy"] !== false) then
      --    options["proxy"].register(options["hooks"]);
      -- end;

      -- if (is_array(options["cookies"])) then
      --    options["cookies"] = new Requests_Cookie_Jar(options["cookies"]);
      -- elsif (empty(options["cookies"])) then
      --    options["cookies"] = new Requests_Cookie_Jar();
      -- end;
      -- if (options["cookies"] !== false) then
      --    options["cookies"].register(options["hooks"]);
      -- end;

      -- if (options["idn"] !== false) then
      --    iri       = new Requests_IRI(url);
      --    iri.host = Requests_IDNAEncoder::encode(iri.ihost);
      --    url       = iri.uri;
      -- end;

      -- Massage the type to ensure we support it.
      Typ := Strtoupper (Typ);

      if not Isset (Options, "data_format") then
         if
           In_List (Typ, [HEAD, GET_Method, DELETE_Method], True)
           -- 3x self::
         then
            Set (Options, "data_format", From_String ("query"));
         else
            Set (Options, "data_format", From_String ("body"));
         end if;
      end if;
      return Options;
   end Set_Defaults;

   --------------------
   -- Parse_Response --
   --------------------

   function Parse_Response (Headers     : String;
                            URL         : String;
                            Req_Headers : Array_Type;
                            Req_Data    : Array_Type;
                            Options     : Array_Type)
                            return Req_Responses.Requests_Response
   is
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use UStrings;

      Options_2 : Array_Type := Options;

      Return2 : Req_Responses.Requests_Response :=
        Req_Responses.X_Construct;       -- new
   begin
      if not As_Boolean (Get (Options_2, "blocking")) then
         return Return2;
      end if;

      Return2.Raw  := +Headers;
      Return2.URL  := +URL; -- (string)
      Return2.Bodi := +"";

      if not As_Boolean (Get (Options_2, "filename")) then
         declare
            Pos : constant Natural := Strpos (Headers, "\r\n\r\n");
         begin
            if Pos = 0 then
               -- Crap!
               raise Requests_Exception
                 with "Missing header/body separator" &
                      "requests.no_crlf_separator";
            end if;

            declare
               Headers : String := Substr (-Return2.Raw, 0, Pos);
               -- Headers will always be separated from the body by two new
               -- lines - `\n\r\n\r`.
               Bodi : constant String := Substr (-Return2.Raw, Pos + 4);
            begin
               if not Empty (Bodi) then
                  Return2.Bodi := +Bodi;
               end if;
            end;
         end;
      end if;

      -- Pretend CRLF = LF for compatibility (RFC 2616, section 19.3)
      declare
         Headers_2 : constant String := Str_Replace ("\r\n", "\n", Headers);
         -- Unfold headers (replace [CRLF] 1*( SP | HT ) with SP)
         -- as per RFC 2616 (section 2.2)
         Headers_3 : constant String := Preg_Replace ("/\n[ \t]/", " ", Headers_2);

         Headers_4 : List_Type := Explode ("\n", Headers_3);
         Matches   : List_Type;
         Unused    : Natural;
      begin
         Unused := Preg_Match ("#^HTTP/(1\.\d)[ \t]+(\d+)#i",
                               List_Shift (Headers_4), Matches);

         if Matches.Is_Empty then
            raise Requests_Exception
              with "Response could not be parsed" &
                   "noversion"; -- , headers_4);
         end if;

         Return2.Protocol_Version := +Matches (1); -- (float)
         Return2.Status_Code      := Integer'Value (Matches (2));   -- (int)

         if Return2.Status_Code in 200 .. 300 - 1 then
            Return2.Success := True;
         end if;

         for Header of Headers_4 loop
            declare
               List : List_Type := Explode (":", Header, 2);

               Key   : constant String := List (1);
               Value : constant String := Trim (List (2));
               Unused : UString;
            begin
               Unused := +Preg_Replace ("#(\s+)#i", " ", Value);
               Set (Return2.Headers, Key, From_String (Value));
            end;
         end loop;

         if Isset (Return2.Headers, "transfer-encoding") then
            raise Program_Error with "not implemented";
--          Return2.Bodi := Decode_Chunked (Return2.Bodi); -- self::
--          Delete (Ref (Return2.Headers, "transfer-encoding"));
         end if;

         if Isset (Return2.Headers, "content-encoding") then
            raise Program_Error with "not implemented";
--          Return2.Bodi := Decompress (Return2.Bodi); -- self::
         end if;

         -- fsockopen and cURL compatibility
         if Isset (Return2.Headers, "connection") then
            Delete (Ref (Return2.Headers, "connection"));
         end if;

--       options["hooks"].dispatch ("requests.before_redirect_check",
--                                  array(&return, req_headers, req_data, options));

         if
           Return2.Is_Redirect and then         -- ()
           As_Boolean (Get (Options_2, "follow_redirects")) = True
         then
            if
              Isset (Return2.Headers, "location") and then
              As_Integer (Get (Options_2, "redirected")) <
              As_Integer (Get (Options_2, "redirects"))
            then
               if Return2.Status_Code = 303 then
                  Set (Options_2, "type", From_String (GET_Method));
               end if;

               Set (Options_2, "redirected",
                    From_Integer (As_Integer (Get (Options_2, "redirected")) + 1));

               declare
                  Location : constant String :=
                    Get_As_String (Return2.Headers, "location");
               begin
                  if
                    Strpos (Location, "http://") /= 0 and then
                    Strpos (Location, "https://") /= 0
                  then
                     null;
                     -- -- relative redirect, for compatibility make it absolute
                     -- declare
                     --    Location_2 : Duration :=
                     --      Absolutize (URL, Location); -- Requests_IRI::
                     -- begin
                     --    Location := Location_2.URI;
                     -- end;
                  end if;

                  -- hook_args = array(
                  --         &location,
                  --         &req_headers,
                  --         &req_data,
                  --         &options,
                  --         return,
                  -- );
                  -- options["hooks"].dispatch("requests.before_redirect", hook_args);
                  declare
                     use Req_Responses;

                     Redirected : constant Requests_Response :=
                       Request (Location, Req_Headers, Req_Data,
                                Get_As_String (Options, "type"), Options); -- self::
                  begin
--                   Redirected.History.Append (Return2);
                     return Redirected;
                  end;
               end;

            elsif
              As_Integer (Get (Options_2, "redirected")) >=
              As_Integer (Get (Options_2, "redirects"))
            then
               raise Requests_Exception
                 with "Too many redirects" &
                      "toomanyredirects"; -- , Return2);
            end if;
         end if;

         Return2.Redirects := As_Integer (Get (Options_2, "redirected"));

--       options["hooks"].dispatch ("requests.after_request",
--                                  array(&return, req_headers, req_data, options));
      end;
      return Return2;
   end Parse_Response;

end Class_Requests;
