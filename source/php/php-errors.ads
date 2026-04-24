--
--
--

with Arrays;

package Php.Errors
is
   use Arrays;

   function Error_Get_Last return Array_Type
   is (Empty_Array);

   PHP_Program_Termination : exception;

   procedure Die (Reason : String := "");

   type Error_Level_Type is record
      User_Notice       : Boolean;
      Warning           : Boolean;
      Core_Error        : Boolean;
      Core_Warning      : Boolean;
      Compile_Error     : Boolean;
      Error             : Boolean;
      Parse             : Boolean;
      User_Error        : Boolean;
      User_Warning      : Boolean;
      Recoverable_Error : Boolean;
   end record;

   ERROR_ALL      : constant Error_Level_Type := (others => True);
   ERROR_NONE     : constant Error_Level_Type := (others => False);

   E_USER_NOTICE  : constant Error_Level_Type :=
     (User_Notice => True, others => False);

   E_USER_WARNING : constant Error_Level_Type :=
     (User_Warning => True, others => False);

   E_USER_ERROR   : constant Error_Level_Type :=
     (User_Error => True, others => False);

   procedure Error_Reporting (Error_Level : Error_Level_Type := ERROR_NONE);
   function Error_Reporting return Error_Level_Type;

   procedure Trigger_Error
     (Message : String; Error_Level : Error_Level_Type := E_USER_NOTICE);

end Php.Errors;
