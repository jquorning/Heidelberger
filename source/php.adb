--
--
--

with Ada.Strings.Unbounded;

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
