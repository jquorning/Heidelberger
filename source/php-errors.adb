--
--
--

with Php.Echoing;

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

end Php.Errors;
