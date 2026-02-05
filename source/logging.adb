--
--
--

with Ada.Characters.Handling;
with Ada.Text_IO;

with Php.Lists;

with Lists;

package body Logging
is

   Silenced : Lists.List_Type;

   ---------
   -- Log --
   ---------

   procedure Log (Channel : String;
                  Message : String)
   is
      use Ada.Characters.Handling;
      use Ada.Text_IO;
      use Php.Lists;

      Upper : constant String := To_Upper (Channel);
   begin
      if not In_List (Channel, Silenced) then
         Put_Line (Upper & ": " & Message);
      end if;
   end Log;

   -------------
   -- Silence --
   -------------

   procedure Silence (Channel : String)
   is
   begin
      Silenced.Append (Channel);
   end Silence;

end Logging;
