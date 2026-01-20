--
--
--

with Ada.Strings.Unbounded;

with Php.Strings;

package body Php.Misc
is

   function Get_Object_Vars (Arry : Array_Type) return Array_Type is (Empty_Array);

   ---------------------
   -- Version_Compare --
   ---------------------

   function Version_Compare (Version_1 : String;
                             Version_2 : String;
                             Operator  : String)
                             return Boolean
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;

      List_1 : constant List_Type := Explode (".", Version_1);
      List_2 : constant List_Type := Explode (".", Version_2);
   begin
      pragma Assert (Operator = ">=");
      for A in List_1.First_Index .. List_1.Last_Index loop
         if List_1 (A) >= List_2 (A) then
            return True;
         end if;
      end loop;
      return False;
   end Version_Compare;

   --------------------
   -- Call_User_Func --
   --------------------

   function Call_User_Func (Callback : Callable;
                            Args     : String := "")
                            return String
   is
   begin
      Callback.all;
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

end Php.Misc;
