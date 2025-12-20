package Php.Multibyte
is
   function MB_Strlen (Item     : String;
                       Encoding : String)
                       return Natural;

   function MB_Substr (Item     : String;
                       Start    : Natural;
                       Length   : Natural;
                       Encoding : String)
                       return String;

   procedure MB_Internal_Encoding (Encoding : String);
   function MB_Internal_Encoding return String;

end Php.Multibyte;
