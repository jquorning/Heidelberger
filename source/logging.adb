--
--
--

with Ada.Characters.Handling;
with Ada.Text_IO;

package body Logging
is

   ---------
   -- Log --
   ---------

   procedure Log (Channel : String;
                  Message : String)
   is
      use Ada.Characters.Handling;
      use Ada.Text_IO;

      Upper : constant String := To_Upper (Channel);
   begin
      Put_Line (Upper & ": " & Message);
   end Log;

end Logging;
