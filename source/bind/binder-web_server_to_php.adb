--
--
--

with Ada.Strings.Fixed;

with Php.HTML;
with Php.Strings;

with Lists;
with Logging;
with UStrings;

with AWS.Headers.Values;
with AWS.Status;
with AWS.URL;

separate (Binder)
procedure Web_Server_To_PHP (Status : AWS.Status.Data)
is
   use AWS.Status;

   PHP_Self : constant String := URI (Status);

   Position : constant Natural :=
     Ada.Strings.Fixed.Index (PHP_Self, "/",
                              Going => Ada.Strings.Backward);

   Request_URI : constant String :=
     PHP_Self (Position .. PHP_Self'Last);

   Obj : constant AWS.URL.Object :=
     AWS.URL.Parse (AWS.Status.URL (Status));

   HTTP_Host : constant String :=
     AWS.URL.Host (Obj) & ":" & AWS.URL.Port (Obj);
begin
   Logging.Log ("web_server_to_php", "uri: " & URI (Status));
   Logging.Log ("web_server_to_php", "url: " & URL (Status));
   Logging.Log ("web_server_to_php", "PHP_Self   : " & PHP_Self);
   Logging.Log ("web_server_to_php", "Request_URI: " & Request_URI);

   Set (X_SERVER, "PHP_SELF",        From_String (PHP_Self));
   Set (X_SERVER, "HTTP_USER_AGENT", From_String ("XXX-790"));
   Set (X_SERVER, "SERVER_SOFTWARE", From_String ("Apache"));
   Set (X_SERVER, "REQUEST_URI",     From_String (Request_URI));
   Set (X_SERVER, "HTTP_HOST",       From_String (HTTP_Host));
   Set (X_SERVER, "REQUEST_METHOD",
        From_String (Request_Method'(Method (Status))'Image));

   -- Set cookies
   declare
      use AWS.Headers;
      use UStrings;

      Lst  : constant List       := Header (Status);
      Cook : constant String     := Get_Values (Lst, "Cookie");
      S    : constant Values.Set := Values.Split (Cook);
   begin
      X_COOKIE := Empty_Array;
      for A of S loop
         Set (X_COOKIE, -A.Name, From_String (-A.Value));
      end loop;
   end;

   XX_GET := Empty_Array;
   declare
      use Ada.Strings.Fixed;
      use Php.HTML;
      use Php.Strings;
      use AWS.URL;
      use Lists;

      Obj              : constant Object := Parse (URL => URL (Status));
      Parameter_List_2 : constant String := Parameters (Obj);
      Parameter_List   : constant String := Ltrim (Parameter_List_2, "?");

      List : constant List_Type := Explode ("&", URL_Decode (Parameter_List));
   begin
      for A of List loop
         declare
            KV    : constant List_Type := Explode ("=", A);
            Key   : constant String := KV (1);
            Value : constant String := (if KV.Length in 2 then KV (2) else "");

            Bracket : constant Natural := Index (Key, "[");
         begin
            if Bracket > 0 and then Key (Key'Last) = ']' then
               -- PHP array-style key: foo[bar]=val → XX_GET["foo"]["bar"] = val
               declare
                  Outer : constant String := Key (Key'First .. Bracket - 1);
                  Inner : constant String := Key (Bracket + 1 .. Key'Last - 1);
                  Sub   : Array_Type :=
                    (if Isset (XX_GET, Outer)
                     then As_Array (Get (XX_GET, Outer))
                     else Empty_Array);
               begin
                  Set (Sub, Inner, From_String (Value));
                  Set (XX_GET, Outer, From_Array (Sub));
               end;
            else
               Set (XX_GET, Key, From_String (Value));
            end if;
         end;
      end loop;
   end;

end Web_Server_To_PHP;
