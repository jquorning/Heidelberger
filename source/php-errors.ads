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

   E_USER_NOTICE : constant Integer := 47;  -- Arbitraty

   procedure Trigger_Error (Message     : String;
                            Error_Level : Integer := E_USER_NOTICE)
                            is null;

end Php.Errors;
