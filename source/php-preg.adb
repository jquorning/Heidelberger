--
--
--

with Hb_Common;

with GNAT.Regpat;

package body Php.Preg
is

   ----------------
   -- Preg_Match --
   ----------------

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Matches : out List_Type;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Integer
   is
      use GNAT.Regpat;
      use Hb_Common;

      Re : constant Pattern_Matcher := Compile (Pattern);
      Result : Match_Array (0 .. Paren_Count (Re));
   begin
      Match (Re, Subject, Result);
      if Result (0) = No_Match then
         return 0;
      else
         for A in 1 .. Paren_Count (Re) loop
            declare
               M : String renames Subject (Result (A).First .. Result (A).Last);
            begin
               Matches.Append (+M);
            end;
         end loop;
         return Paren_Count (Re);
      end if;
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Matches : out Array_Type;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Integer
   is
   begin
      raise Program_Error with "not implemented";
      return 999;
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Boolean
   is
      Unused : List_Type;
      Count : constant Natural :=
         Preg_Match (Pattern, Subject, Unused, Flags, Offset);
   begin
      return Count /= 0;
   end Preg_Match;

end Php.Preg;
