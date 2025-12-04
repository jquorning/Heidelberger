--
--
--

with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;

with Hb_Common;

package body Php
is
   use Ada.Strings.Unbounded;

   function Get_Object_Vars (Arry : Array_Type) return Array_Type is (Empty_Array);

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

end Php;
