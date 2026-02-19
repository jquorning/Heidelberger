--
--
--

with Arrays;

package Php.JSON
is
   use Arrays;

   function JSON_Encode (Value : Multi_Type;
                         Flags : Integer := 0;
                         Depth : Integer := 512)
                         return String;

   function JSON_Decode (JSON        : String;
                         Associative : Boolean := False)
                         return Array_Type;

   JSON_ERROR_NONE : constant Integer := 0; -- Arbitrary value

   function JSON_Last_Error
            return Integer
            is (JSON_ERROR_NONE);

   function JSON_Last_Error_Msg
            return String
            is ("XXX-979");

   function Serialize (Value : Multi_Type)
                       return String
   is (raise Program_Error with "not implemented");

   function Unserialize (Data : String)
                         return Multi_Type
   is (raise Program_Error with "not implemented");

end Php.JSON;
