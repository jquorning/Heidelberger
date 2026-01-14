
with Ada.Characters.Latin_1;
with Ada.Strings.Unbounded;

package Hb_Common
is
   use Ada.Strings.Unbounded;

   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   function "-" (Item : Unbounded_String) return String
      renames To_String;

   NL     : constant String := "" & Ada.Characters.Latin_1.LF;
   TAB    : constant String := "" & Ada.Characters.Latin_1.HT;
   NL_TAB : constant String := NL & TAB;

   procedure Dummy;

end Hb_Common;
