--
--
--

with Ada.Text_IO;

with Php.Echoing;

with Helpers;

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
      raise Program_Termination;
   end Die;

   ---------------------
   -- Error_Reporting --
   ---------------------

   procedure Error_Reporting (Error_Level : Integer := 0)
   is
      use Ada.Text_IO;
   begin
      Put_Line ("error_reporting: " & Helpers.Image (Error_Level));
   end Error_Reporting;

   -------------------
   -- Trigger_Error --
   -------------------

   procedure Trigger_Error (Message     : String;
                            Error_Level : Integer := E_USER_NOTICE)
   is
      use Ada.Text_IO;
   begin
      Put_Line ("trigger_error:" & Helpers.Image (Error_Level));
      Put_Line (Message);
   end Trigger_Error;

end Php.Errors;
