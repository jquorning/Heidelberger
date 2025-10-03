with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;

with GNAT.Regexp;
with GNAT.Regpat;

with Hb_Common;

package body Php
is
   use Ada.Strings.Unbounded;

   function Get_Object_Vars (Arry : Array_Type) return Array_Type is (Empty_Array);

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
      use GNAT.Regexp;
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

   -------------
   -- Explode --
   -------------

   function Explode (Separator : String;
                     Item      : String)
                     return List_Type
   is
      use Ada.Strings.Fixed;
      use Hb_Common;

      Pos : constant Natural := Index (Item, Separator);
      Res : List_Type;
   begin
      Res.Append (+Item (Item'First .. Pos - 1));
      Res.Append (+Item (Pos + Separator'Length .. Item'Last));

      return Res;
   end Explode;

   -----------------------------------------------------------------------------

   Echo_Buffer : Unbounded_String;

   ----------
   -- Echo --
   ----------

   procedure Echo (Item : String)
   is
   begin
      Append (Echo_Buffer, Item);
   end Echo;

   ----------
   -- Echo --
   ----------

   procedure Printf (Format : String;
                     Arg_1  : String)
   is
      use Hb_Common;

      Item : constant String := Printf (Format, Arg_1);
   begin
      Append (Echo_Buffer, Item);
   end Printf;

   ----------
   -- Echo --
   ----------

   procedure Clear_Echo
   is
   begin
      Echo_Buffer := Null_Unbounded_String;
   end Clear_Echo;

   ----------
   -- Echo --
   ----------

   function Get_Echo
            return String
   is
      use Hb_Common;
   begin
      return -Echo_Buffer;
   end Get_Echo;

end Php;
