--
--
--

with Ada.Numerics.Discrete_Random;
with Ada.Strings.Fixed;
with Ada.Strings.Maps;
with Ada.Strings.Unbounded;
with Ada.Strings.Equal_Case_Insensitive;
with Ada.Strings.Less_Case_Insensitive;

with Hb_Common;

package body Php
is
   use Ada.Strings.Unbounded;

   package Natural_Random
   is new Ada.Numerics.Discrete_Random (Natural);

   Generator : Natural_Random.Generator;

   function Get_Object_Vars (Arry : Array_Type) return Array_Type is (Empty_Array);

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

   -----------
   -- USort --
   -----------

   procedure USort (Arry     : in out Array_Type;
                    Callback : USort_Comparator)
   is
   begin
      raise Program_Error with "not implemented";
   end USort;

   -------------
   -- MT_Rand --
   -------------

   function MT_Rand (Min : Natural;
                     Max : Natural)
                     return Natural
   is
   begin
      return Natural_Random.Random (Generator, Min, Max);
   end MT_Rand;

   --------------
   -- In_Array --
   --------------

   function In_Array (Needle   : String;
                      Haystack : List_Type;
                      Strict   : Boolean := False)
                      return Boolean
   is
   begin
      for A of Haystack loop
         if Needle = A then
            return True;
         end if;
      end loop;
      return False;
   end In_Array;

   -------------
   -- Explode --
   -------------

   function Explode (Separator : String;
                     Item      : String;
                     Limit     : Integer := Integer'Last)
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

   -------------
   -- Implode --
   -------------

   function Implode (Separator : String;
                     Arry      : Array_Type)
                     return String
   is
      use Hb_Common;

      Ret   : Unbounded_String;
      First : Boolean := True;
   begin
      for A in Arry.Iterate loop
         if not First then
            Append (Ret, Separator);
         end if;
         Append (Ret, Key (A));
         First := False;
      end loop;
      return -Ret;
   end Implode;

   -----------------
   -- Array_Shift --
   -----------------

   procedure Array_Shift (List : in out List_Type)
   is
   begin
      List.Delete_Last;
   end Array_Shift;

   -----------------
   -- Array_Shift --
   -----------------

   function Array_Shift (List : in out List_Type)
                         return String
   is
      use Hb_Common;

      First : constant String := -List.First_Element;
   begin
      Array_Shift (List);
      return First;
   end Array_Shift;

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
--    Unused : constant String := Callback.all; --  ("XXX-990"); --  (Args);
   begin
      Callback.all;
      return "XXX-991";
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

begin
   Natural_Random.Reset (Generator, 0);
end Php;
