--
--
--

with Ada.Strings.Unbounded;
with Ada.Text_IO;

with Hb_Common;

with GNAT.Regpat;

package body Php.Preg
is

-- Pattern_Error : exception;

   type Marks_Type is record
      First : Natural;
      Last  : Natural;
      Flags : GNAT.Regpat.Regexp_Flags;
   end record;

   function Find_Marks (Pattern : String)
                        return Marks_Type;
   -- Find RegExp pattern in WordPress pattern.

   function Remove_Space (Pattern : String)
                          return String;
   -- Return Pattern without spaces.

   function Replace (Replacement : String;
                     Subject     : String;
                     Matches     : GNAT.Regpat.Match_Array)
                     return String;

   ----------------
   -- Find_Marks --
   ----------------

   function Find_Marks (Pattern : String)
                        return Marks_Type
   is
      use Ada.Text_IO;
      use GNAT.Regpat;

      Mark   : constant Character := Pattern (Pattern'First);
      Option : Natural;
      Result : Marks_Type;
      Flags  : Regexp_Flags renames Result.Flags;
   begin
      Result.First := Pattern'First + 1;
      for A in reverse Pattern'Range loop
         if Pattern (A) = Mark then
            Result.Last := A - 1;
            Option      := A + 1;
            exit;
         end if;
      end loop;

      Flags := No_Flags;
      for Flag of Pattern (Option .. Pattern'Last) loop
         case Flag is
         when 'i' =>
            Flags := Flags and Case_Insensitive;

         when 's' =>
            Put_Line ("DOTALL ignored in:");
            Put_Line ("  " & Pattern);

         when 'x' =>
            Put_Line ("EXTENDED ignored in:");
            Put_Line ("  " & Pattern);

         when others =>
            raise Program_Error with "not implemented";
         end case;
      end loop;

      return Result;
   end Find_Marks;

   -------------
   -- Replace --
   -------------

   function Replace (Replacement : String;
                     Subject     : String;
                     Matches     : GNAT.Regpat.Match_Array)
                     return String
   is
      use Ada.Strings.Unbounded;
      use GNAT.Regpat;
      use Hb_Common;

      Buffer : Unbounded_String;
      Index  : Natural := Replacement'First;
   begin
      while Index <= Replacement'Last loop
         if Replacement (Index) = '$' then
            declare
               M : constant Natural :=
                 Natural'Value (Replacement (Index + 1 .. Index + 1));
            begin
               if Matches (M) = No_Match then
                  null;
               else
                  Append (Buffer,
                          Subject (Matches (M).First .. Matches (M).Last));
               end if;
            end;
            Index := Index + 2;
         else
            Append (Buffer, Replacement (Index));
            Index := Index + 1;
         end if;
      end loop;
      return -Buffer;
   end Replace;

   ------------------
   -- Preg_Replace --
   ------------------

   function Preg_Replace (Pattern     : String;
                          Replacement : String;
                          Subject     : String;
                          Limit       : Integer := -1;
                          Count       : out Natural)
                          return String
   is
   begin
      raise Program_Error with "not implemented";
      return "XXX-899";
   end Preg_Replace;

   ------------------
   -- Preg_Replace --
   ------------------

   function Preg_Replace (Pattern     : String;
                          Replacement : String;
                          Subject     : String)
                          return String
   is
      use Ada.Text_IO;
      use GNAT.Regpat;
   begin
      declare
         Marks : constant Marks_Type :=
           Find_Marks (Pattern);

         Re : constant Pattern_Matcher :=
           Compile (Pattern (Marks.First .. Marks.Last),
                    Flags => Marks.Flags);

         Result : Match_Array (0 .. Paren_Count (Re));
      begin
         Match (Re, Subject, Result);

         return Replace (Replacement, Subject, Result);
      end;

   exception
      when Expression_Error =>
         Put_Line ("  EXCEPTION: Expression_Error");
         return Subject;
   end Preg_Replace;

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
      use Ada.Text_IO;
      use GNAT.Regpat;
      use Hb_Common;

      Marks : constant Marks_Type :=
        Find_Marks (Pattern);

      Re : constant Pattern_Matcher :=
        Compile (Pattern (Marks.First .. Marks.Last),
                 Flags => Marks.Flags);

      Result : Match_Array (0 .. Paren_Count (Re));
   begin
      Put_Line ("preg_match:");
--    Put_Line ("  marks:");
--    Put_Line (Marks'Image);

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

   ----------------
   -- Preg_Match --
   ----------------

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Integer
   is
      Unused : List_Type;
      Count : constant Natural :=
         Preg_Match (Pattern, Subject, Unused, Flags, Offset);
   begin
      return Count;
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   procedure Preg_Match (Pattern : String;
                         Subject : String;
                         Matches : out List_Type;
                         Flags   : Integer := 0;
                         Offset  : Integer := 0)
   is
      Unused_Result : Integer;
   begin
      Unused_Result :=
        Preg_Match (Pattern, Subject, Matches, Flags, Offset);
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   procedure Preg_Match (Pattern : String;
                         Subject : String;
                         Matches : out Array_Type;
                         Flags   : Integer := 0;
                         Offset  : Integer := 0)
   is
      Unused_Result : Integer;
   begin
      Unused_Result :=
        Preg_Match (Pattern, Subject, Matches, Flags, Offset);
   end Preg_Match;

   --------------------
   -- Preg_Match_All --
   --------------------

   function Preg_Match_All (Pattern : String;
                            Subject : String;
                            Matches : out Array_Type;
                            Flags   : Integer := 0;
                            Offset  : Integer := 0)
                            return Integer
   is
      use Ada.Text_IO;
   begin
      Put_Line ("preg_match_all:");
      Put_Line ("  pattern: " & Pattern);
      Put_Line ("  subject: " & Subject);
      return 0;
   end Preg_Match_All;

   --------------------
   -- Preg_Match_All --
   --------------------

   procedure Preg_Match_All (Pattern : String;
                             Subject : String;
                             Matches : out List_Type;
                             Flags   : Integer := 0;
                             Offset  : Integer := 0)
   is
   begin
      raise Program_Error with "not implemented";
   end Preg_Match_All;

   ----------------
   -- Preg_Split --
   ----------------

   function Preg_Split (Pattern : String;
                        Subject : String;
                        Limit   : Integer   := -1;
                        Flags   : Flag_Type := 0)
                        return List_Type
   is
      use Ada.Text_IO;

--    Marks : constant Marks_Type := Find_Marks (Pattern);
   begin
      Put_Line ("preg_split:");
      Put_Line ("  pattern: " & Pattern);
--    Put_Line ("    pyned: " & Pattern (First .. Last));
--    Put_Line ("    flags: " & Pattern (Option .. Pattern'Last));
      Put_Line ("  subject: " & Subject);
      raise Program_Error with "not implemented";
      return Empty_List;
   end Preg_Split;

   ------------------
   -- Remove_Space --
   ------------------

   function Remove_Space (Pattern : String)
                          return String
   is
      Result : String (Pattern'Range);
      Last   : Natural := Result'First - 1;
   begin
      for A of Pattern loop
         if A = ' ' then
            null;
         else
            Last := Last + 1;
            Result (Last) := A;
         end if;
      end loop;
      return Result (Result'First .. Last);
   end Remove_Space;

   ---------------------------
   -- Preg_Replace_Callback --
   ---------------------------

   function Preg_Replace_Callback (Pattern  : String;
                                   Callback : Callable_10;
                                   Subject  : String)
                                   return String
   is
      use Ada.Text_IO;
      use GNAT.Regpat;

      Pattern_2 : constant String     := Remove_Space (Pattern);
      Marks     : constant Marks_Type := Find_Marks (Pattern_2);

      Re : constant Pattern_Matcher :=
        Compile (Pattern_2 (Marks.First .. Marks.Last),
                 Flags => Marks.Flags);

      Result : Match_Array (0 .. Paren_Count (Re));
   begin
      Match (Re, Subject, Result);

      Put_Line ("preg_replace_callback:");
      Put_Line ("  pattern: " & Pattern_2);
      Put_Line ("    pyned: " & Pattern_2 (Marks.First .. Marks.Last));
      Put_Line ("  subject: " & Subject);
--    raise Program_Error with "not implemented";
      return Subject;
--    return "XXX-968";
   end Preg_Replace_Callback;

end Php.Preg;
