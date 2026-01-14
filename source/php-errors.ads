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

   procedure Error_Reporting (Error_Level : Integer := 0)
             is null;

   E_USER_NOTICE  : constant Integer := 47;  -- Arbitraty
   E_USER_WARNING : constant Integer := 48;

   procedure Trigger_Error (Message     : String;
                            Error_Level : Integer := E_USER_NOTICE)
                            is null;

end Php.Errors;
