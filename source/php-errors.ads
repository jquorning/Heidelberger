--
--
--

package Php.Errors
is

   function Error_Get_Last
            return Array_Type
            is (Empty_Array);

   procedure Die (Reason : String := "")
             is null;

   procedure Error_Reporting (Error_Level : Integer := 0)
             is null;

end Php.Errors;
