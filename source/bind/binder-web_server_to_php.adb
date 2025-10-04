
separate (Binder)
procedure Web_Server_To_PHP
is
begin
   Set (X_SERVER, "PHP_SELF",        "/wp-admin/edit.php");
   Set (X_SERVER, "HTTP_USER_AGENT", "XXX-790");
   Set (X_SERVER, "SERVER_SOFTWARE", "Apache");
   Set (X_SERVER, "REQUEST_URI",     "/edit.php");
   Set (X_SERVER, "HTTP_HOST",       "XXX-902");
end Web_Server_To_PHP;
