--
--
--

with Arrays;

package Php.Errors
is
   use Arrays;

   function Error_Get_Last
            return Array_Type
            is (Empty_Array);

   Program_Termination : exception;

   procedure Die (Reason : String := "");

   E_USER_NOTICE  : constant Integer := 47;  -- Arbitraty
   E_USER_WARNING : constant Integer := 48;

   procedure Error_Reporting (Error_Level : Integer := 0);

   procedure Trigger_Error (Message     : String;
                            Error_Level : Integer := E_USER_NOTICE);

end Php.Errors;
