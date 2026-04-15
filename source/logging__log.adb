--
--
--

with Ada.Characters.Handling;
with Ada.Real_Time;
with Ada.Text_IO;

with Php.Lists;

with Lists;

package body Logging
is

   procedure Put_Timestamp;

   Silenced  : Lists.List_Type;
   Epoch     : Ada.Real_Time.Time;
   Timestamp : Boolean := False;

   -------------------
   -- Put_Timestamp --
   -------------------

   procedure Put_Timestamp is
      use Ada.Real_Time;
      use Ada.Text_IO;

      package Duration_IO is new Ada.Text_IO.Fixed_IO (Duration);

      Span  : constant Time_Span := Clock - Epoch;
      Dur   : constant Duration := To_Duration (Span);
      Image : String (1 .. 7);
   begin
      Duration_IO.Put (Image, Dur, Aft => 3);
      Image (4) := 's'; -- sec unit
      Put (Image (3 .. Image'Last));
      Put ("m");   -- milisec unit
   end Put_Timestamp;

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
         if Timestamp then
            Put_Timestamp;
            Put (" ");
         end if;
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

   --------------
   -- Add_Time --
   --------------

   procedure Add_Time is
   begin
      Timestamp := True;
      Epoch := Ada.Real_Time.Clock;
   end Add_Time;

end Logging;
