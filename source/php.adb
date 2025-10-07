with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

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

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : Callable)
                   return Array_Type
   is
      Item : Array_Record;
      Map  : Array_Type;
   begin
      Item.Kind := Is_Callable;
      Item.Func := Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   --------------
   -- Get_Func --
   --------------

   function Get_Func (Arry : Array_Type;
                      Key  : String)
                      return Callable
   is
      use Array_Maps;
   begin
      pragma Assert (Arry.Find (Key) /= No_Element);
      pragma Assert (Element (Arry.Find (Key)).Kind = Is_Callable);
      return Array_Maps.Element (Arry.Find (Key)).Func;
   end Get_Func;

   -----------------
   -- Array_Slice --
   -----------------

   function Array_Slice (Arry   : Array_Type;
                         Offset : Natural;
                         Length : Natural)
                         return Array_Type
   is
   begin
      return Arry;
   end Array_Slice;

   --------------------
   -- Call_User_Func --
   --------------------

   function Call_User_Func (Callback : Callable;
                            Args     : String := "")
                            return String
   is
   begin
      return ""; -- Callback.all (Args);
   end Call_User_Func;

   --------------------------
   -- Call_User_Func_Array --
   --------------------------

   function Call_User_Func_Array (Callback : Callable;
                                  Args     : Array_Type)
                                  return String
   is
   begin
      return ""; -- Callback.all (Args);
   end Call_User_Func_Array;

   -------------------
   -- Func_Get_Args --
   -------------------

   function Func_Get_Args
            return Array_Type
   is
   begin
      return Empty_Array;
   end Func_Get_Args;

   ------------
   -- Printf --
   ------------

   function Printf (Format : String;
                    Args   : List_Type)
                    return String
   is
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

   function Sprintf (Format : String;
                     Args   : List_Type)
                     return String
   is (Printf (Format, Args));

   function Vsprintf (Format : String;
                      Args   : List_Type)
                      return String
   is (Printf (Format, Args));

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
                     Args   : List_Type)
   is
      use Hb_Common;

      Item : constant String := Printf (Format, Args);
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
