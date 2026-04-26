--
--
--

with Ada.Containers;

with GNAT.Regpat;

with Php.Arrays;

with Logging;
with UStrings;

package body Php.Preg
is

-- Pattern_Error : exception;

   type Marks_Type is record
      First : Natural;
      Last  : Natural;
      Flags : GNAT.Regpat.Regexp_Flags;
   end record;

   function Find_Marks (Pattern : String) return Marks_Type;
   -- Find RegExp pattern in WordPress pattern.

   function Remove_Space (Pattern : String) return String;
   -- Return Pattern without spaces.

   function Replace
     (Replacement : String;
      Subject     : String;
      Matches     : GNAT.Regpat.Match_Array) return String;

   ----------------
   -- Find_Marks --
   ----------------

   function Find_Marks (Pattern : String) return Marks_Type is
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
            Option := A + 1;
            exit;
         end if;
      end loop;

      Flags := GNAT.Regpat.No_Flags;
      for Flag of Pattern (Option .. Pattern'Last) loop
         case Flag is
            when 'i'    =>
               Flags := Flags or Case_Insensitive;

            when 's'    =>
               Logging.Log ("find_marks", "DOTALL ignored in: " & Pattern);

            when 'x'    =>
               Logging.Log ("find_marks", "EXTENDED ignored in: " & Pattern);

            when others =>
               Logging.Log
                 ("find_marks", Flag & " not implemented in: " & Pattern);
               raise Program_Error with "not implemented";
         end case;
      end loop;

      return Result;
   end Find_Marks;

   ------------------
   -- Preg_Replace --
   ------------------

   procedure Preg_Replace
     (Pattern     : List_Type;
      Replacement : List_Type;
      Subject     : List_Type;
      Limit       : Limit_Type := No_Limit;
      Count       : out Natural;
      Result      : out List_Type)
   is
      use type Ada.Containers.Count_Type;
   begin
      Logging.Log ("preg_replace_base", "not implemented");
      Logging.Log ("preg_replace_base", "pattern    : " & Pattern'Image);
      Logging.Log ("preg_replace_base", "replacement: " & Replacement'Image);
      Logging.Log ("preg_replace_base", "subject    : " & Subject'Image);

      pragma Assert (Pattern.Length = Replacement.Length);
      pragma Assert (Pattern.Length = Subject.Length);
      pragma Assert (1 = Pattern.First_Index);
      pragma Assert (1 = Replacement.First_Index);
      pragma Assert (1 = Subject.First_Index);
      pragma Assert (Limit = No_Limit);

      Count := 0;
      Result := Empty_List;
   end Preg_Replace;

   -------------
   -- Replace --
   -------------

   function Replace
     (Replacement : String;
      Subject     : String;
      Matches     : GNAT.Regpat.Match_Array) return String
   is
      use GNAT.Regpat;
      use UStrings;

      Repl  : UString;
      Index : Natural := Replacement'First;
   begin
      -- Build substitution string from Replacement, expanding $N references
      while Index <= Replacement'Last loop
         if Replacement (Index) = '$' then
            declare
               M : constant Natural :=
                 Natural'Value (Replacement (Index + 1 .. Index + 1));
            begin
               if Matches (M) /= No_Match then
                  Append
                    (Repl, Subject (Matches (M).First .. Matches (M).Last));
               end if;
            end;
            Index := Index + 2;
         else
            Append (Repl, Replacement (Index));
            Index := Index + 1;
         end if;
      end loop;

      -- Return: text before match + substitution + text after match
      if Matches (0) = No_Match then
         return Subject;
      end if;
      declare
         Before : constant String :=
           (if Matches (0).First > Subject'First
            then Subject (Subject'First .. Matches (0).First - 1)
            else "");
         After  : constant String :=
           (if Matches (0).Last < Subject'Last
            then Subject (Matches (0).Last + 1 .. Subject'Last)
            else "");
      begin
         return Before & (-Repl) & After;
      end;
   end Replace;

   ------------------
   -- Preg_Replace --
   ------------------

   function Preg_Replace
     (Pattern     : String;
      Replacement : String;
      Subject     : String;
      Limit       : Limit_Type := No_Limit;
      Count       : out Natural) return String is
   begin
      raise Program_Error with "not implemented";
      return "XXX-899";
   end Preg_Replace;

   ------------------
   -- Preg_Replace --
   ------------------

   function Preg_Replace
     (Pattern : List_Type; Replacement : List_Type; Subject : String)
      return String
   is
      use type Ada.Containers.Count_Type;
      use UStrings;

      Buffer : UString := +Subject;
   begin
      pragma Assert (Pattern.Length = Replacement.Length);
      pragma Assert (1 = Pattern.First_Index);
      pragma Assert (1 = Replacement.First_Index);

      for A in Pattern.First_Index .. Pattern.Last_Index loop
         Buffer :=
           +Preg_Replace
              (Pattern     => Pattern (A),
               Replacement => Replacement (A),
               Subject     => -Buffer);
      end loop;

      return -Buffer;
   end Preg_Replace;

   ------------------
   -- Preg_Replace --
   ------------------

   function Preg_Replace
     (Pattern : String; Replacement : String; Subject : String) return String
   is
      use GNAT.Regpat;
   begin
      Logging.Log ("preg_replace", "");
      Logging.Log ("preg_replace", "  pattern    : " & Pattern);
      Logging.Log ("preg_replace", "  replacement: " & Replacement);
      Logging.Log ("preg_replace", "  subject    : " & Subject);

      declare
         Marks : constant Marks_Type := Find_Marks (Pattern);

         Re : constant Pattern_Matcher :=
           Compile (Pattern (Marks.First .. Marks.Last), Flags => Marks.Flags);

         Result : Match_Array (0 .. Paren_Count (Re));
      begin
         Match (Re, Subject, Result);

         if Result'Length in 1 then
            return Subject;
         else
            return Replace (Replacement, Subject, Result);
         end if;
      end;

   exception
      when Expression_Error =>
         Logging.Log ("preg_replace", "  EXCEPTION in: " & Pattern);
         return Subject;
   end Preg_Replace;

   ----------------
   -- Preg_Match --
   ----------------

   function Preg_Match
     (Pattern : String;
      Subject : String;
      Matches : out List_Type;
      Flags   : Integer := 0;
      Offset  : Integer := 0) return Integer
   is
      use GNAT.Regpat;
   begin
      Logging.Log ("preg_match", "");

      pragma Assert (Offset = 0);
      pragma Assert (Flags = 0);

      declare
         Marks  : constant Marks_Type := Find_Marks (Pattern);
         Re     : constant Pattern_Matcher :=
           Compile (Pattern (Marks.First .. Marks.Last), Flags => Marks.Flags);
         Result : Match_Array (0 .. Paren_Count (Re));
      begin
         Match (Re, Subject, Result);
         if Result (0) = No_Match then
            return 0;
         else
            for A in 1 .. Paren_Count (Re) loop
               if Result (A) /= No_Match then
                  declare
                     M : String renames
                       Subject (Result (A).First .. Result (A).Last);
                  begin
                     Matches.Append (M);
                  end;
               end if;
            end loop;
            return Paren_Count (Re);
         end if;
      end;

   exception
      when others =>
         Logging.Log ("preg_match", "EXCEPTION in: " & Pattern);
         return 0;
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   function Preg_Match
     (Pattern : String;
      Subject : String;
      Matches : out Array_Type;
      Flags   : Integer := 0;
      Offset  : Integer := 0) return Integer is
   begin
      raise Program_Error with "not implemented";
      return 999;
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   function Preg_Match
     (Pattern : String;
      Subject : String;
      Flags   : Integer := 0;
      Offset  : Integer := 0) return Boolean
   is
      Unused : List_Type;
      Count  : constant Natural :=
        Preg_Match (Pattern, Subject, Unused, Flags, Offset);
   begin
      return Count /= 0;
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   function Preg_Match
     (Pattern : String;
      Subject : String;
      Flags   : Integer := 0;
      Offset  : Integer := 0) return Integer
   is
      Unused : List_Type;
      Count  : constant Natural :=
        Preg_Match (Pattern, Subject, Unused, Flags, Offset);
   begin
      return Count;
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   procedure Preg_Match
     (Pattern : String;
      Subject : String;
      Matches : out List_Type;
      Flags   : Integer := 0;
      Offset  : Integer := 0)
   is
      Unused_Result : Integer;
   begin
      Unused_Result := Preg_Match (Pattern, Subject, Matches, Flags, Offset);
   end Preg_Match;

   ----------------
   -- Preg_Match --
   ----------------

   procedure Preg_Match
     (Pattern : String;
      Subject : String;
      Matches : out Array_Type;
      Flags   : Integer := 0;
      Offset  : Integer := 0)
   is
      Unused_Result : Integer;
   begin
      Unused_Result := Preg_Match (Pattern, Subject, Matches, Flags, Offset);
   end Preg_Match;

   --------------------
   -- Preg_Match_All --
   --------------------

   procedure Preg_Match_All
     (Pattern : String;
      Subject : String;
      Matches : out Array_Type;
      Flags   : Flag_Type := No_Flags;
      Count   : out Natural) is
   begin
      Logging.Log ("preg_match_all", "not implemented");
      Logging.Log ("preg_match_all", "pattern: " & Pattern);
      Logging.Log ("preg_match_all", "subject: " & Subject);

      pragma Assert (Flags = No_Flags);

      Matches := Empty_Array;
      Count := 0;
   end Preg_Match_All;

   --------------------
   -- Preg_Match_All --
   --------------------

   procedure Preg_Match_All
     (Pattern : String;
      Subject : String;
      Matches : out List_Type;
      Flags   : Flag_Type := No_Flags;
      Offset  : Integer := 0)
   is
      use Php.Arrays;

      Result : Array_Type;
      Count  : Natural;
   begin
      pragma Assert (Offset = 0);

      Preg_Match_All (Pattern, Subject, Result, Flags, Count);

      Matches := Array_Values (Result);
      Logging.Log ("preg_match_all", "insert bogus values");
      Append (Matches, "(bogus-value-1)");
      Append (Matches, "(bogus-value-2)");
   end Preg_Match_All;

   --------------------
   -- Preg_Match_All --
   --------------------

   function Preg_Match_All
     (Pattern : String;
      Subject : String;
      Matches : out Array_Type;
      Flags   : Flag_Type := No_Flags;
      Offset  : Integer := 0) return Integer
   is
      Count : Natural;
   begin
      pragma Assert (Offset = 0);

      Preg_Match_All (Pattern, Subject, Matches, Flags, Count);
      return Count;
   end Preg_Match_All;

   ----------------
   -- Preg_Split --
   ----------------

   function Preg_Split
     (Pattern : String;
      Subject : String;
      Limit   : Limit_Type := No_Limit;
      Flags   : Flag_Type := No_Flags) return List_Type
   is
      use GNAT.Regpat;

      Delim_Capture : constant Boolean := Flags.PREG_SPLIT_DELIM_CAPTURE;
      No_Empty      : constant Boolean := Flags.PREG_SPLIT_NO_EMPTY;

      procedure Maybe_Append (List : in out List_Type; S : String);

      procedure Maybe_Append (List : in out List_Type; S : String) is
      begin
         if not No_Empty or else S'Length > 0 then
            List.Append (S);
         end if;
      end Maybe_Append;

   begin
      Logging.Log ("preg_split", "  pattern: " & Pattern);
      Logging.Log ("preg_split", "  subject: " & Subject);

      declare
         Marks    : constant Marks_Type := Find_Marks (Pattern);
         Engine   : constant Pattern_Matcher :=
           Compile (Pattern (Marks.First .. Marks.Last), Flags => Marks.Flags);
         N_Parens : constant Natural := Paren_Count (Engine);
         Result   : Match_Array (0 .. N_Parens);
         List     : List_Type;
         Pos      : Integer := Subject'First;
         Count    : Integer := 0;
      begin
         while Pos <= Subject'Last loop
            exit when Limit >= 0 and then Count >= Integer (Limit) - 1;

            Match (Engine, Subject, Result, Pos);
            exit when Result (0) = No_Match;

            -- Text before this match
            Maybe_Append
              (List,
               (if Result (0).First > Pos
                then Subject (Pos .. Result (0).First - 1)
                else ""));

            -- Captured groups if PREG_SPLIT_DELIM_CAPTURE
            if Delim_Capture then
               for I in 1 .. N_Parens loop
                  if Result (I) /= No_Match then
                     Maybe_Append
                       (List, Subject (Result (I).First .. Result (I).Last));
                  elsif not No_Empty then
                     List.Append ("");
                  end if;
               end loop;
            end if;

            Count := Count + 1;

            -- Advance past match; step 1 forward on zero-length match
            Pos :=
              (if Result (0).Last >= Result (0).First
               then Result (0).Last + 1
               else Result (0).First + 1);
         end loop;

         -- Remaining text after last match
         if Pos <= Subject'Last then
            Maybe_Append (List, Subject (Pos .. Subject'Last));
         elsif not No_Empty then
            List.Append ("");
         end if;

         Logging.Log ("preg_split", List'Image);
         return List;
      end;

   exception
      when others =>
         Logging.Log ("preg_split", "EXCEPTION in: " & Pattern);
         declare
            Fallback : List_Type;
         begin
            Maybe_Append (Fallback, Subject);
            return Fallback;
         end;
   end Preg_Split;

   ------------------
   -- Remove_Space --
   ------------------

   function Remove_Space (Pattern : String) return String is
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

   ----------------
   -- Preg_Quote --
   ----------------

   function Preg_Quote (Str : String; Delimiter : String := "") return String
   is
   begin
      Logging.Log ("preg_quote", "not implemented");
      return Str & "XXX-E94";
   end Preg_Quote;

   ---------------------------
   -- Preg_Replace_Callback --
   ---------------------------

   function Preg_Replace_Callback
     (Pattern : String; Callback : Callable_10; Subject : String) return String
   is
      use GNAT.Regpat;

      Pattern_2 : constant String := Remove_Space (Pattern);
      Marks     : constant Marks_Type := Find_Marks (Pattern_2);

      Re : constant Pattern_Matcher :=
        Compile (Pattern_2 (Marks.First .. Marks.Last), Flags => Marks.Flags);

      Result : Match_Array (0 .. Paren_Count (Re));
   begin
      Match (Re, Subject, Result);

      Logging.Log ("preg_replace_callback", "not implemented");
      Logging.Log ("preg_replace_callback", "  pattern: " & Pattern_2);
      Logging.Log
        ("preg_replace_callback",
         "    pyned: " & Pattern_2 (Marks.First .. Marks.Last));
      Logging.Log ("preg_replace_callback", "  subject: " & Subject);

      return Subject;
   end Preg_Replace_Callback;

end Php.Preg;
