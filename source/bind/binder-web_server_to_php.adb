
separate (Binder)
procedure Web_Server_To_PHP
is
begin
   Set (X_SERVER, "PHP_SELF",        From_String ("/wp-admin/edit.php"));
   Set (X_SERVER, "HTTP_USER_AGENT", From_String ("XXX-790"));
   Set (X_SERVER, "SERVER_SOFTWARE", From_String ("Apache"));
   Set (X_SERVER, "REQUEST_URI",     From_String ("/edit.php"));
   Set (X_SERVER, "HTTP_HOST",       From_String ("XXX-902"));
end Web_Server_To_PHP;
