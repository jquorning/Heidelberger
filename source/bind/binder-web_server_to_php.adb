--
--
--

with Ada.Strings.Fixed;

with AWS.Status;

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
   -- "/wp-admin/edit.php"));
   Set (X_SERVER, "HTTP_USER_AGENT", From_String ("XXX-790"));
   Set (X_SERVER, "SERVER_SOFTWARE", From_String ("Apache"));
   Set (X_SERVER, "REQUEST_URI",     From_String (Request_URI));
   -- "/edit.php"));
   Set (X_SERVER, "HTTP_HOST",       From_String ("XXX-902"));
end Web_Server_To_PHP;
