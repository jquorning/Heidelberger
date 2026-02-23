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

   type Error_Level_Type is
     record
        User_Notice  : Boolean;
--      User_Warning : Boolean;
        Warning      : Boolean;
        CORE_ERROR : Boolean;
        CORE_WARNING : Boolean;
        COMPILE_ERROR : Boolean;
        ERROR : Boolean;
--      WARNING : Boolean;
        PARSE : Boolean;
        USER_ERROR : Boolean;
        USER_WARNING : Boolean;
        RECOVERABLE_ERROR : Boolean;
     end record;

   ERROR_ALL      : constant Error_Level_Type := (others => True);
   ERROR_NONE     : constant Error_Level_Type := (others => False);
   E_USER_NOTICE  : constant Error_Level_Type := (User_Notice => True,
                                                  others      => False);
   E_USER_WARNING : constant Error_Level_Type := (User_Warning => True,
                                                  others       => False);

   procedure Error_Reporting (Error_Level : Error_Level_Type := ERROR_NONE);
   function Error_Reporting return Error_Level_Type;

   procedure Trigger_Error
               (Message     : String;
                Error_Level : Error_Level_Type := E_USER_NOTICE);

end Php.Errors;
