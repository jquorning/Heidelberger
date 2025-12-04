--
--
--

package Php.Types
is

   function Is_Object (Arry : Array_Type) return Boolean is (False);
   function Is_Array  (Arry : Array_Type) return Boolean is (True);
   function Is_Array  (List : List_Type) return Boolean is (True);

   function Is_Int (A : Integer)   return Boolean is (True);
   function Is_String (A : String) return Boolean is (True);

   function Is_Numeric (Value : String)
                        return Boolean
                        is (False);

   function Is_Numeric (Value : Integer)
                        return Boolean
                        is (True);

end Php.Types;
