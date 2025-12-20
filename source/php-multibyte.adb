package body Php.Multibyte
is
   function MB_Strlen (Item     : String;
                       Encoding : String)
                       return Natural
                       is (raise Program_Error with "not implemented");

   function MB_Substr (Item     : String;
                       Start    : Natural;
                       Length   : Natural;
                       Encoding : String)
                       return String
                       is (raise Program_Error with "not implemented");

   procedure MB_Internal_Encoding (Encoding : String)
                                   is null;

   function MB_Internal_Encoding
            return String
            is (raise Program_Error with "not implemented");

end Php.Multibyte;
