--
--
--

with Ada.Strings.Fixed;
with Ada.Strings.Equal_Case_Insensitive;
with Ada.Strings.Less_Case_Insensitive;
with Ada.Strings.Maps;
with Ada.Strings.Unbounded;

package body Php.Strings
is

   ------------
   -- Strstr --
   ------------

   function Strstr (Haystack      : String;
                    Needle        : String;
                    Before_Needle : Boolean := False)
                    return String
   is
      use Ada.Strings.Fixed;

      Pos : constant Natural := Index (Needle, Haystack);
   begin
      if Pos = 0 then
         return Haystack;
      else
         if Before_Needle then
            return Haystack (Haystack'First .. Pos - 1);
         else
            return Haystack (Pos .. Haystack'Last);
         end if;
      end if;
   end Strstr;

   ------------
   -- Strpos --
   ------------

   function Strpos (Item    : String;
                    Pattern : String)
                    return Natural
   is
      use Ada.Strings.Fixed;
   begin
      return Index (Source  => Item,
                    Pattern => Pattern);
   end Strpos;

   -----------------
   -- Str_Replace --
   -----------------

   function Str_Replace (Search  : String;
                         Replace : String;
                         Subject : String)
                         return String
   is
      use Ada.Strings.Fixed;
      Pos : constant Natural := Index (Search, Subject);
   begin
      if Pos = 0 then
         return Subject;
      else
         return
           Subject (Subject'First .. Pos - 1) &
           Replace &
           Str_Replace (Search, Replace,
                        Subject => Subject (Pos + Subject'Length .. Subject'Last));
      end if;
   end Str_Replace;

   ------------
   -- Substr --
   ------------

   function Substr (Str    : String;
                    Offset : Integer;
                    Length : Integer := 0)
                    return String
   is
   begin
      raise Debug;
      return Str;
   end Substr;

   -------------------
   -- Strnatcasecmp --
   -------------------

   function Strnatcasecmp (Left, Right : String)
                           return Integer
   is
      use Ada.Strings;

      EQ : constant Boolean := Equal_Case_Insensitive (Left, Right);
      LT : constant Boolean := Less_Case_Insensitive (Left, Right);
   begin
      return (case LT is
              when False => (case EQ is
                             when False => 1,
                             when True  => 0),
              when True  => -1);
   end Strnatcasecmp;

   ----------------
   -- Addslashes --
   ----------------

   function Addslashes (Item : String)
            return String
   is
      use Ada.Strings;
      use Ada.Strings.Maps;

      Needles : constant Character_Set :=
         To_Set (''') and To_Set ('"') and To_Set ('\') and To_Set (ASCII.NUL);
      First : Positive;
      Last  : Natural;
   begin
      Fixed.Find_Token (Source => Item,
                        Set    => Needles,
                        Test   => Inside,
                        First  => First,
                        Last   => Last);
      if Last = 0 then
         return Item;
      else
         return
           Item (Item'First .. First - 1) & "\" & Item (First) &
           Addslashes (Item (Last + 1 .. Item'Last));
      end if;
   end Addslashes;

   ------------
   -- Printf --
   ------------

   function Printf (Format : String;
                    Args   : List_Type)
                    return String
   is
      use Ada.Strings.Unbounded;

      Buffer : Unbounded_String;
      A : Natural := Format'First;
      B : Natural := Args.First_Index;
   begin
      while A <= Format'Last loop
         if Format (A) = '%' then
            if Format (A + 1) in 's' | 'd' then
               Append (Buffer, Args (B));
               B := B + 1;
               A := A + 2;
            elsif Format (A + 2) in 's' | 'd' then
               Append (Buffer, Args (B));
               B := B + 1;
               A := A + 3;
            end if;
         else
            Append (Buffer, Format (A));
            A := A + 1;
         end if;
      end loop;
      return To_String (Buffer);
   end Printf;

   -------------
   -- Sprintf --
   -------------

   function Sprintf (Format : String;
                     Args   : List_Type)
                     return String
   is (Printf (Format, Args));

   --------------
   -- Vsprintf --
   --------------

   function Vsprintf (Format : String;
                      Args   : List_Type)
                      return String
   is (Printf (Format, Args));

end Php.Strings;
