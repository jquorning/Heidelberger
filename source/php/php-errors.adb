--
--
--

with Php.Echoing;

with Logging;

package body Php.Errors
is

   ---------
   -- Die --
   ---------

   procedure Die (Reason : String := "")
   is
      use Php.Echoing;
   begin
      Echo (Reason);
      raise PHP_Program_Termination;
   end Die;

   ---------------------
   -- Error_Reporting --
   ---------------------

   procedure Error_Reporting (Error_Level : Error_Level_Type := ERROR_NONE)
   is
   begin
      Logging.Log ("error_reporting", Error_Level'Image);
   end Error_Reporting;

   ---------------------
   -- Error_Reporting --
   ---------------------

   function Error_Reporting return Error_Level_Type
   is (others => True);

   -------------------
   -- Trigger_Error --
   -------------------

   procedure Trigger_Error
               (Message     : String;
                Error_Level : Error_Level_Type := E_USER_NOTICE)
   is
   begin
      Logging.Log ("trigger_error", Error_Level'Image);
      Logging.Log ("trigger_error", Message);
   end Trigger_Error;

end Php.Errors;
