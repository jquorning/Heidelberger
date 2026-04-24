--
--
--

with Ada.Characters.Latin_1;
with Ada.Strings.Unbounded;

package UStrings is

   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

   Null_UString : constant UString :=
     Ada.Strings.Unbounded.Null_Unbounded_String;

   function "+" (Item : String) return UString
   renames Ada.Strings.Unbounded.To_Unbounded_String;

   function "-" (Item : UString) return String
   renames Ada.Strings.Unbounded.To_String;

   function To_UString (Item : String) return UString
   renames Ada.Strings.Unbounded.To_Unbounded_String;

   function To_String (Item : UString) return String
   renames Ada.Strings.Unbounded.To_String;

   function "=" (Left, Right : UString) return Boolean
   renames Ada.Strings.Unbounded."=";

   function "=" (Left : UString; Right : String) return Boolean
   renames Ada.Strings.Unbounded."=";

   function "=" (Left : String; Right : UString) return Boolean
   renames Ada.Strings.Unbounded."=";

   function "&" (Left, Right : UString) return UString
   renames Ada.Strings.Unbounded."&";

   function "&" (Left : UString; Right : String) return UString
   renames Ada.Strings.Unbounded."&";

   function "&" (Left : String; Right : UString) return UString
   renames Ada.Strings.Unbounded."&";

   procedure Append (Item : in out UString; Value : String)
   renames Ada.Strings.Unbounded.Append;

   procedure Append (Item : in out UString; Value : UString)
   renames Ada.Strings.Unbounded.Append;

   procedure Append (Item : in out UString; Value : Character)
   renames Ada.Strings.Unbounded.Append;

   function Element (Item : UString; Position : Natural) return Character
   renames Ada.Strings.Unbounded.Element;

   function Length (Item : UString) return Natural
   renames Ada.Strings.Unbounded.Length;

   procedure Set_UString (Item : out UString; Value : String)
   renames Ada.Strings.Unbounded.Set_Unbounded_String;

   NL     : constant String := "" & Ada.Characters.Latin_1.LF;
   TAB    : constant String := "" & Ada.Characters.Latin_1.HT;
   CR     : constant String := "" & Ada.Characters.Latin_1.CR;
   LF     : constant String := "" & Ada.Characters.Latin_1.LF;
   NL_TAB : constant String := NL & TAB;

   TAB0 : constant String := "";
   TAB1 : constant String := TAB;
   TAB2 : constant String := TAB & TAB;
   TAB3 : constant String := TAB & TAB & TAB;
   TAB4 : constant String := TAB & TAB & TAB & TAB;
   TAB5 : constant String := TAB & TAB & TAB & TAB & TAB;
   TAB6 : constant String := TAB & TAB & TAB & TAB & TAB & TAB;
   TAB7 : constant String := TAB & TAB & TAB & TAB & TAB & TAB & TAB;
   TAB8 : constant String := TAB & TAB & TAB & TAB & TAB & TAB & TAB & TAB;

end UStrings;
