--
--
--

with Arrays;

package Php.JSON
is
   use Arrays;

   function JSON_Encode (Value : Multi_Type)
                         return String
                         is ("XXX-007");

   function JSON_Decode (JSON        : String;
                         Associative : Boolean := False)
                         return Array_Type
                         is (Empty_Array);

   JSON_ERROR_NONE : constant Integer := 0; -- Arbitrary value

   function JSON_Last_Error
            return Integer
            is (JSON_ERROR_NONE);

   function JSON_Last_Error_Msg
            return String
            is ("XXX-979");

end Php.JSON;
