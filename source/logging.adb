--
--
--

with Ada.Text_IO;

package body Logging
is

   ---------
   -- Log --
   ---------

   procedure Log (Channel : String;
                  Message : String)
   is
      use Ada.Text_IO;
   begin
      Put_Line (Channel & ": " & Message);
   end Log;

end Logging;
