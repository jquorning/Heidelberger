with Arrays;

package Php.Multibyte
is
   use Arrays;

   function MB_Strlen (Item     : String;
                       Encoding : String)
                       return Natural;

   function MB_Substr (Item     : String;
                       Start    : Natural;
                       Length   : Natural;
                       Encoding : String := "")
                       return String;

   procedure MB_Internal_Encoding (Encoding : String);
   function MB_Internal_Encoding return String;

   function MB_Detect_Encoding (Item      : String;
                                Encodings : Array_Type;
                                Strict    : Boolean := False)
                                return String
                                is ("XXX-963");

   function MB_Detect_Order (Encoding : String := "")
                             return Array_Type
                             is (Empty_Array);

   function MB_Convert_Encoding (Item          : String;
                                 To_Encoding   : String;
                                 From_Encoding : String := "")
                                 return String;

end Php.Multibyte;
