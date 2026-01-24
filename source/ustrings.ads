--
--
--

with Ada.Characters.Latin_1;
with Ada.Strings.Unbounded;

package UStrings
is

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   function "+" (Item : String) return UString
      renames Ada.Strings.Unbounded.To_Unbounded_String;

   function "-" (Item : UString) return String
      renames Ada.Strings.Unbounded.To_String;

   NL     : constant String := "" & Ada.Characters.Latin_1.LF;
   TAB    : constant String := "" & Ada.Characters.Latin_1.HT;
   NL_TAB : constant String := NL & TAB;

end UStrings;
