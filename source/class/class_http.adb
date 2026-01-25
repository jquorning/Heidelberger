--
-- HTTP API: WP_Http class
--
-- @package WordPress
-- @subpackage HTTP
-- @since 2.7.0
--

with Php.Arrays;
with Php.Files;
with Php.HTML;
with Php.Lists;
with Php.Preg;
with Php.Strings;

with Globals;
with UStrings;
with Lists;
with Wp_Common;

with Class_Requests;
with Class_HTTP_Requests_Responses;
with Class_HTTP_Proxys;
with Inc_Functions;
with Inc_General_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Plugins;

with Req_Responses;

package body Class_HTTP
is
   use Lists;

   -------------
   -- Request --
   -------------

   function Request (This : Wp_Http;
                     URL  : String;
                     Args : Array_Type := Empty_Array)
                     return Response_Result -- Array_Type
   is
      use Php.Files;
      use Php.HTML;
      use Wp_Common;
      use Class_Errors;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Plugins;

      Defaults : Array_Type := To_Array (List => (
        Build ("method",              "GET"),
        --
        -- Filters the timeout value for an HTTP request.
        --
        -- @since 2.7.0
        -- @since 5.1.0 The `url` parameter was added.
        --
        -- @param float  timeout_value Time in seconds until a request times out.
        --                              Default 5.
        -- @param string url           The request URL.
        --
        Build ("timeout",
               Integer'(Apply_Filters ("http_request_timeout", 5, URL))),
        --
        -- Filters the number of redirects allowed during an HTTP request.
        --
        -- @since 2.7.0
        -- @since 5.1.0 The `url` parameter was added.
        --
        -- @param int    redirect_count Number of redirects allowed. Default 5.
        -- @param string url            The request URL.
        --
        Build ("redirection",
               Integer'(Apply_Filters ("http_request_redirection_count", 5, URL))),
        --
        -- Filters the version of the HTTP protocol used in a request.
        --
        -- @since 2.7.0
        -- @since 5.1.0 The `url` parameter was added.
        --
        -- @param string version Version of HTTP used. Accepts "1.0" and "1.1".
        --                        Default "1.0".
        -- @param string url     The request URL.
        --
        Build ("httpversion",
               Apply_Filters ("http_request_version", "1.0", URL)),
        --
        -- Filters the user agent value sent with an HTTP request.
        --
        -- @since 2.7.0
        -- @since 5.1.0 The `url` parameter was added.
        --
        -- @param string user_agent WordPress user agent string.
        -- @param string url        The request URL.
        --
        Build ("user-agent",
               Apply_Filters ("http_headers_useragent", "WordPress/" &
                              Get_Bloginfo ("version") & "; " &
                              Get_Bloginfo ("url"), URL)),
        --
        -- Filters whether to pass URLs through wp_http_validate_url() in an HTTP
        -- request.
        --
        -- @since 3.6.0
        -- @since 5.1.0 The `url` parameter was added.
        --
        -- @param bool   pass_url Whether to pass URLs through wp_http_validate_url().
        --                        Default false.
        -- @param string url      The request URL.
        --
        Build ("reject_unsafe_urls",
               Apply_Filters ("http_request_reject_unsafe_urls", False, URL)),
        Build ("blocking",            True),
        Build ("headers",             Empty_Array),
        Build ("cookies",             Empty_Array),
        Build ("body",                Null_Value),
        Build ("compress",            False),
        Build ("decompress",          True),
        Build ("sslverify",           True),
        Build ("sslcertificates",     "/etc/ssl/certs/ca-certificates.crt"),
        Build ("stream",              False),
        Build ("filename",            Null_Value),
        Build ("limit_response_size", Null_Value)
      ));

      -- Pre-parse for the HEAD checks.
      Args_2 : constant Array_Type := Wp_Parse_Args (Args);

      Response : Response_Result;
   begin
      -- By default, HEAD requests do not cause redirections.
      if
        Isset (Args_2, "method") and then
        "HEAD" = Get_As_String (Args_2, "method")
      then
         Set (Defaults, "redirection", From_Integer (0));
      end if;

      declare
         Parsed_Args : Array_Type := Wp_Parse_Args (Args_2, Defaults);
         --
         -- Filters the arguments used in an HTTP request.
         --
         -- @since 2.7.0
         --
         -- @param array  parsed_args An array of HTTP request arguments.
         -- @param string url         The request URL.
         --
      begin
         Parsed_Args := Apply_Filters ("http_request_args", Parsed_Args, URL);

         -- The transports decrement this, store a copy of the original value for
         -- loop purposes.
         if not Isset (Parsed_Args, "_redirection") then
            Set (Parsed_Args, "_redirection", Get (Parsed_Args, "redirection"));
         end if;

         --
         -- Filters the preemptive return value of an HTTP request.
         --
         -- Returning a non-false value from the filter will short-circuit the HTTP
         -- request and return early with that value. A filter should return one of:
         --
         --  - An array containing "headers", "body", "response", "cookies", and
         --    "filename" elements
         --  - A WP_Error instance
         --  - boolean false to avoid short-circuiting the response
         --
         -- Returning any other value may result in unexpected behaviour.
         --
         -- @since 2.9.0
         --
         -- @param false|array|WP_Error preempt     A preemptive return value of an
         --                                          HTTP request. Default false.
         -- @param array                parsed_args HTTP request arguments.
         -- @param string               url         The request URL.
         --
         declare
            Pre : constant Response_Result := -- Array_Type :=
              Apply_Filters ("pre_http_request", False,
                             Parsed_Args, URL);
         begin
            if Pre.Arry /= Empty_Array then -- false
               return Pre;
            end if;
         end;

         -- if True then -- Function_Exists ("wp_kses_bad_protocol") then
         --    if Get_As_String (Parsed_Args, "reject_unsafe_urls") /= "" then
         --       URL := Wp_HTTP_Validate_URL (URL);
         --    end if;
         --    if URL then
         --       URL :=
         --         Wp_KSES_Bad_Protocol (URL,
         --                               To_List (List => (+"http", +"https", +"ssl")));
         --    end if;
         -- end if;

         declare
            Parsed_URL : constant Array_Type := Parse_URL (URL);
         begin
            if
              URL = "" or else -- Empty (URL) or else
              "" = Get_As_String (Parsed_URL, "scheme") -- Empty
            then
               Response.Success := False;
               Response.Error :=
                 X_Construct ("http_request_failed",
                              abs "A valid URL was not provided.");

               -- This action is documented in wp-includes/class-wp-http.php
               Do_Action ("http_api_debug", Response, "response", "Requests",
                          Parsed_Args, URL);
               return Response;
            end if;
         end;

         if This.Block_Request (URL) then
            Response.Error :=
              X_Construct ("http_request_not_executed",
                           abs "User has blocked requests through HTTP.");

            -- This action is documented in wp-includes/class-wp-http.php
            Do_Action ("http_api_debug", Response, "response", "Requests",
                       Parsed_Args, URL);
            return Response;
         end if;

         -- If we are streaming to a file but no filename was given drop it in the WP
         -- temp dir and pick its name using the basename of the url.
         if Get_As_String (Parsed_Args, "stream") /= "" then
            if Empty (Parsed_Args, "filename") then
               Set (Parsed_Args, "filename",
                    From_String (Get_Temp_Dir & Basename (URL)));
            end if;

            -- Force some settings if we are streaming to a file and check for
            -- existence and perms of destination directory.
            Set (Parsed_Args, "blocking", From_Boolean (True));
            if
              not Wp_Is_Writable (Dirname (Get_As_String (Parsed_Args, "filename")))
            then
               Response.Success := False;
               Response.Error   :=
                 X_Construct ("http_request_failed",
                              abs "Destination directory for file streaming does not exist or is not writable.");

               -- This action is documented in wp-includes/class-wp-http.php
               Do_Action ("http_api_debug", Response, "response", "Requests",
                          Parsed_Args, URL);
               return Response;
            end if;
         end if;

         if Is_Null (Get (Parsed_Args, "headers")) then
            Set (Parsed_Args, "headers", From_Array (Empty_Array));
         end if;

         -- WP allows passing in headers as a string, weirdly.
         if Kind_Of (Get (Parsed_Args, "headers")) not in Kind_Array then
            declare
               Processed_Headers : constant Array_Type :=
                 Process_Headers (As_Array (Get (Parsed_Args, "headers")));
                 -- wp_http::
            begin
               Set (Parsed_Args, "headers", Get (Processed_Headers, "headers"));
            end;
         end if;

         declare
            -- Setup arguments.
            Headers : constant Array_Type := As_Array (Get (Parsed_Args, "headers"));
            Data    : constant Array_Type := As_Array (Get (Parsed_Args, "body"));
            Typ     : constant String := Get_As_String (Parsed_Args, "method");
            Options : Array_Type := To_Array (List => (
                        Build ("timeout",   Get_As_String (Parsed_Args, "timeout")),
                        Build ("useragent", Get_As_String (Parsed_Args, "user-agent")),
                        Build ("blocking",  Get_As_String (Parsed_Args, "blocking"))
--           Build ("hooks",     new Wp_Http_Requests_Hooks (URL, Parsed_Args))
            ));
         begin
            -- Ensure redirects follow browser behaviour.
--          options["hooks"].Register ("requests.before_redirect", array (get_class(), "browser_redirect_compatibility"));

            -- Validate redirected URLs.
--            if
--              Function_Exists ("wp_kses_bad_protocol") and then
--              parsed_args["reject_unsafe_urls"]
--            then
--               options["hooks"].Register ("requests.before_redirect",
--                                          array( get_class(), "validate_redirects"));
--            end if;

            if Get_As_String (Parsed_Args, "stream") /= "" then -- Get_As_String added
               Set (Options, "filename", Get (Parsed_Args, "filename"));
            end if;

            if Empty (Parsed_Args, "redirection") then
               Set (Options, "follow_redirects", From_Boolean (False));
            else
               Set (Options, "redirects", Get (Parsed_Args, "redirection"));
            end if;

            -- Use byte limit, if we can.
            if Isset (Parsed_Args, "limit_response_size") then
               Set (Options, "max_bytes", Get (Parsed_Args, "limit_response_size"));
            end if;

            -- If we've got cookies, use and convert them to Requests_Cookie.
            if not Empty (Parsed_Args, "cookies") then
               null;
--             Set (Options, "cookies", WP_Http::normalize_cookies( parsed_args["cookies"] ));
            end if;

            -- SSL certificate handling.
            if not Empty (Parsed_Args, "sslverify") then -- empty added
               Set (Options, "verify",     From_Boolean (False));
               Set (Options, "verifyname", From_Boolean (False));
            else
               Set (Options, "verify", Get (Parsed_Args, "sslcertificates"));
            end if;

            -- All non-GET/HEAD requests should put the arguments in the form body.
            if Typ not in "HEAD" | "GET" then
               Set (Options, "data_format", From_String ("body"));
            end if;

            --
            -- Filters whether SSL should be verified for non-local requests.
            --
            -- @since 2.8.0
            -- @since 5.1.0 The `url` parameter was added.
            --
            -- @param bool   ssl_verify Whether to verify the SSL connection.
            --                           Default true.
            -- @param string url        The request URL.
            --
            Set (Options, "verify",
                 Apply_Filters ("https_ssl_verify", Get (Options, "verify"), URL));

            -- Check for proxies.
            declare
               use Class_HTTP_Proxys;

               Proxy : Wp_HTTP_Proxy; --  := X_Construct;
            begin
               if
                 Proxy.Is_Enabled and then
                 Proxy.Send_Through_Proxy (URL)
               then
                  null;
                  -- options["proxy"] := new Requests_Proxy_HTTP( proxy.Host & ":" & Proxy.Port);

                  -- if Proxy.Use_Authentication then
                  --    Set (Options, "proxy"].use_authentication := True;
                  --    Set (Options, "proxy"].user               := Proxy.Username;
                  --    Set (Options, "proxy"].pass               := Proxy.Password;
                  -- end if;
               end if;
            end;

            -- Avoid issues where mbstring.func_overload is enabled.
            MB_String_Binary_Safe_Encoding;

            declare
--             use Class_Requests;
               use Class_HTTP_Requests_Responses;
               use Req_Responses;

               Requests_ResponseX : constant Requests_Response :=
                 Class_Requests.Request (URL, Headers, Data, Typ, Options);
                 -- Requests::

               -- Convert the response into an array.
               HTTP_Response : constant Wp_HTTP_Requests_Response :=
                 X_Construct (Requests_ResponseX,
                              Get_As_String (Parsed_Args, "filename"));

--               Response : constant Array_Type := HTTP_Response.To_Array; -- ()
            begin
               Response.Success := True;
               Response.Arry    := HTTP_Response.To_Array; -- ()
               -- Add the original object to the array.
--             Set (Response, "http_response", HTTP_Response);
            exception
               when E : others => --    end; catch ( Requests_Exception e ) then
                  Response.Error := -- : constant Wp_Error :=
                    X_Construct ("http_request_failed",
                                 "XXX-979"); -- E.Getmessage);
            end;

            Reset_MB_String_Encoding;

            --
            -- Fires after an HTTP API response is received and before the response
            -- is returned.
            --
            -- @since 2.8.0
            --
            -- @param array|WP_Error response    HTTP response or WP_Error object.
            -- @param string         context     Context under which the hook is fired.
            -- @param string         class       HTTP transport used.
            -- @param array          parsed_args HTTP request arguments.
            -- @param string         url         The request URL.
            --
            Do_Action ("http_api_debug", Response, "response", "Requests",
                       Parsed_Args, URL);

            if Is_Wp_Error (Response.Arry) then
               return Response;
            end if;

            if not Empty (Parsed_Args, "blocking") then -- Empty added
               return (Success => True,
                       Error   => Null_Wp_Error,
                       Arry    =>
               To_Array (List => (
                 Build ("headers",       Empty_Array),
                 Build ("body",          ""),
                 Build ("response",      To_Array (List => (
                   Build ("code",    False),
                   Build ("message", False)
                 ))),
                 Build ("cookies",       Empty_Array),
                 Build ("http_response", Null_Value)
               )));
            end if;

            --
            -- Filters a successful HTTP API response immediately before the
            -- response is returned.
            --
            -- @since 2.9.0
            --
            -- @param array  response    HTTP response.
            -- @param array  parsed_args HTTP request arguments.
            -- @param string url         The request URL.
            --
            return Apply_Filters ("http_response", Response,
                                  Parsed_Args, URL);
         end;
      end;
   end Request;

   -------------------------------------
   -- X_Get_First_Available_Transport --
   -------------------------------------

   function X_Get_First_Available_Transport (This : Wp_Http;
                                             Args : Array_Type;
                                             URL  : String := "") -- null
                                             return String
   is
      use Php.Lists;
--    use Php.Misc;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
--    use Inc_Plugins;

      Transports : constant List_Type :=
        To_List (List => (+"curl", +"streams"));

      --
      -- Filters which HTTP transports are available and in what order.
      --
      -- @since 3.7.0
      --
      -- @param string[] transports Array of HTTP transports to check. Default array
      --                             contains "curl" and "streams", in that order.
      -- @param array    args       HTTP request arguments.
      -- @param string   url        The URL to request.
      --
      Request_Order : constant List_Type :=
        Apply_Filters ("http_api_transports", Transports, Args, URL);
   begin
      -- Loop over each transport on each HTTP request looking for one which will
      -- serve this request's needs.
      for Transport of Request_Order loop
         declare
            Transport_2 : String :=
              (if In_List (-Transport, Transports, True)
               then UC_First (-Transport)
               else -Transport);

            Class : constant String := "WP_Http_" & Transport_2;
         begin
            -- Check to see if this transport is a possibility, calls the
            -- transport statically.
            if
              False
--            not Call_User_Func (To_Array (List => (1 => Build (Class, "test"))),
--                                Args, URL)
            then
               goto Continue;
            end if;

            return Class;
         end;
         << Continue >>
      end loop;

      return ""; -- False;
   end X_Get_First_Available_Transport;

   ----------
   -- Post --
   ----------

   function Post (This : Wp_Http;
                  URL  : String;
                  Args : Array_Type := Empty_Array)
                  return Array_Type
   is
      use Inc_Functions;

      Defaults : constant Array_Type :=
        To_Array (List => (1 =>
          Build ("method", "POST")));

      Parsed_Args : constant Array_Type :=
        Wp_Parse_Args (Args, Defaults);
   begin
      return This.Request (URL, Parsed_Args).Arry; -- arry added
   end Post;

   ---------------------
   -- Process_Headers --
   ---------------------

   function Process_Headers (Headers : Array_Type;
                             URL     : String := "")
                             return Array_Type
   is
      use Php.Arrays;
      use Php.Strings;
      use UStrings;

      -- -- Split headers, one per array element.
      -- if ( is_string( headers ) ) then
      --    -- Tolerate line terminator: CRLF = LF (RFC 2616 19.3).
      --    headers = str_replace( "\r\n", "\n", headers );
      --    --
      --    -- Unfold folded header fields. LWS = [CRLF] 1*( SP | HT )
      --    -- <US-ASCII SP, space (32)>,
      --    -- <US-ASCII HT, horizontal-tab (9)> (RFC 2616 2.2).
      --    --
      --    headers = preg_replace( "/\n[ \t]/", " ", headers );
      --    -- Create the headers array.
      --    headers = explode( "\n", headers );
      -- end if;

      Response : Array_Type := To_Array (List => (
        Build ("code",    0),
        Build ("message", "")
      ));

      Headers_2 : Array_Type := Headers;
   begin
      --
      -- If a redirection has taken place, The headers for each page request may
      -- have been passed. In this case, determine the final HTTP header and parse
      -- from there.
      --
      for I in reverse 0 .. Count (Headers_2) loop
         if
           not Empty (Headers_2, "[I]") and then
           0 = Strpos (Get_As_String (Headers_2, "[I]"), ":")
         then
            Headers_2 := Array_Splice (Headers_2, I);
            exit; -- break;
         end if;
      end loop;

      declare
         Cookies     : Array_Type;
         New_Headers : Array_Type;
      begin
         for A in Headers_2.Iterate loop -- (array)
            declare
               Temp_Header : String := Key (A);
            begin
               if Temp_Header = "" then -- empty
                  goto Continue;
               end if;

               if 0 = Strpos (Temp_Header, ":") then
                  declare
                     Stack : List_Type := Explode (" ", Temp_Header, 3);
                  begin
                     Stack.Append (+"");
                     Set (Response, "code",    From_String (-Stack (2)));
                     Set (Response, "message", From_String (-Stack (3)));
--                   list( , response["code"], response["message"]) := Stack;
                     goto Continue;
                  end;
               end if;

               declare
                  List : constant List_Type := Explode (":", Temp_Header, 2);

                  Key   : constant String := Strtolower (-List (1));
                  Value : constant String := Trim (-List (2));
               begin
                  if Isset (New_Headers, Key) then
                     if Kind_Of (Get (New_Headers, Key)) not in Kind_Array then
--                   if not Is_Array (Get (New_Headers, Key)) then
                        Set (New_Headers, Key,
                             From_Array (As_Array (Get (New_Headers, Key))));
                     end if;
                     Append (New_Headers, Key => Key, Value => From_String (Value));
                  else
                     Set (New_Headers, Key, From_String (Value));
                  end if;

                  if "set-cookie" = Key then
                     null;
--                   Cookies.Append (new Wp_Http_Cookie (value, URL));
                  end if;
               end;
            end;
            << Continue >>
         end loop;

         -- Cast the Response Code to an int.
         Set (Response, "code",
              From_Integer (As_Integer (Get (Response, "code"))));

         return To_Array (List => (
                        Build ("response", Response),
                        Build ("headers",  New_Headers),
                        Build ("cookies",  Cookies)
                ));
      end;
   end Process_Headers;

   -------------------
   -- Block_Request --
   -------------------

   Static_Accessible_Hosts : List_Type; -- null;
   Static_Wildcard_Regex   : UStrings.UString; -- array();

   function Block_Request (This : Wp_Http;
                           URI  : String)
                           return Boolean
   is
      use UStrings;
      use Php.Lists;
      use Php.HTML;
      use Php.Preg;
      use Php.Strings;
      use Inc_Options;
      use UStrings;
      use Inc_Plugins;
   begin
      -- We don't need to block requests, because nothing is blocked.
      if
--     not defined( "WP_HTTP_BLOCK_EXTERNAL" ) or else
        not Globals.WP_HTTP_BLOCK_EXTERNAL
      then
         return False;
      end if;

      declare
         Check : constant Array_Type := Parse_URL (URI);
      begin
         if Check = Empty_Array then
            return True;
         end if;

         declare
            Home : constant Array_Type := Parse_URL (Get_Option ("siteurl"));
         begin
            -- Don't block requests back to ourselves by default.
            if
              "localhost" = Get_As_String (Check, "host") or else
              (Isset (Home, "host") and then
               Get_As_String (Home, "host") = Get_As_String (Check, "host"))
            then
               --
               -- Filters whether to block local HTTP API requests.
               --
               -- A local request is one to `localhost` or to the same host as the
               -- site itself.
               --
               -- @since 2.8.0
               --
               -- @param bool block Whether to block local requests. Default false.
               --
               return Apply_Filters ("block_local_requests", False);
            end if;

            if Globals.WP_ACCESSIBLE_HOSTS /= "" then
--          if not Defined ("WP_ACCESSIBLE_HOSTS") then
               return True;
            end if;

            if Static_Accessible_Hosts.Is_Empty then -- null =
               Static_Accessible_Hosts :=
                 Preg_Split ("|,\s*|", -Globals.WP_ACCESSIBLE_HOSTS);

               if 0 /= Strpos (-Globals.WP_ACCESSIBLE_HOSTS, "*") then
                  declare
                     Wildcard_Regex : List_Type;
                  begin
                     for Host of Static_Accessible_Hosts loop
                        Wildcard_Regex.Append
                          (+Str_Replace ("\*", ".+", Preg_Quote (-Host, "/")));
                     end loop;
                     Static_Wildcard_Regex :=
                       +"/^(" & Implode ("|", Wildcard_Regex) & ")/i";
                  end;
               end if;
            end if;

            if not Empty (-Static_Wildcard_Regex) then
               return not Preg_Match (-Static_Wildcard_Regex,
                                      Get_As_String (Check, "host"));
            else
               return not In_List (Get_As_String (Check, "host"),
                                   Static_Accessible_Hosts, True);
               -- Inverse logic, if it's in the array, then don't block it.
            end if;
         end;
      end;
   end Block_Request;

end Class_HTTP;
