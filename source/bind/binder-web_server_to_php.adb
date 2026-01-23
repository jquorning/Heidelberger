--
--
--

with Ada.Strings.Fixed;

with Php.Strings;

with Lists;

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

   Request_URI : constant String := PHP_Self (Position .. PHP_Self'Last);
begin
   Put_Line ("web_server_to_php:");
   Put_Line ("  uri: " & URI (Status));
   Put_Line ("  url: " & URL (Status));
   Put_Line ("  PHP_Self   : " & PHP_Self);
   Put_Line ("  Request_URI: " & Request_URI);

   Set (X_SERVER, "PHP_SELF",        From_String (PHP_Self));
   Set (X_SERVER, "HTTP_USER_AGENT", From_String ("XXX-790"));
   Set (X_SERVER, "SERVER_SOFTWARE", From_String ("Apache"));
   Set (X_SERVER, "REQUEST_URI",     From_String (Request_URI));
   Set (X_SERVER, "HTTP_HOST",       From_String ("XXX-902"));
   Set (X_SERVER, "REQUEST_METHOD",
        From_String (Request_Method'(Method (Status))'Image));

   XX_GET := Empty_Array;
   declare
      use Php.Strings;
      use AWS.URL;
      use Hb_Common;
      use Lists;

      Obj              : constant Object := Parse (URL => URL (Status));
      Parameter_List_2 : constant String := Parameters (Obj);
      Parameter_List   : constant String := Ltrim (Parameter_List_2, "?");
      List             : constant List_Type := Explode ("&", Parameter_List);
   begin
      for A of List loop
         declare
            KV : constant List_Type := Explode ("=", -A);
            First : constant String := -KV (1);
         begin
            if KV.Length in 2 then
               XX_GET.Append (Key   => First,
                              Value => From_String (-KV (2)));
            else
               XX_GET.Append (Key   => First,
                              Value => From_String (""));
            end if;
         end;
      end loop;
   end;

end Web_Server_To_PHP;
