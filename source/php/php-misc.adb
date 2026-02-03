--
--
--

with Php.Strings;

package body Php.Misc
is

   function Get_Object_Vars (Arry : Array_Type)
                             return Array_Type
                             is (Empty_Array);

   ---------------------
   -- Version_Compare --
   ---------------------

   function Version_Compare (Version_1 : String;
                             Version_2 : String;
                             Operator  : String)
                             return Boolean
   is
      use Php.Strings;

      List_1 : constant List_Type := Explode (".", Version_1);
      List_2 : constant List_Type := Explode (".", Version_2);

      Last   : constant Natural   :=
        Natural'Min (List_1.Last_Index, List_2.Last_Index);
   begin
      if Operator = ">=" then
         for A in List_1.First_Index .. Last loop
            declare
               Left  : constant Natural := Natural'Value (List_1 (A));
               Right : constant Natural := Natural'Value (List_2 (A));
            begin
               if Left >= Right then
                  return True;
               else
                  return False;
               end if;
            end;
         end loop;
         return False;

      elsif Operator = "<" then
         for A in List_1.First_Index .. Last loop
            declare
               Left  : constant Natural := Natural'Value (List_1 (A));
               Right : constant Natural := Natural'Value (List_2 (A));
            begin
               if Left < Right then
                  return True;
               elsif Left > Right then
                  return False;
               end if;
            end;
         end loop;
         return False;

      else
         pragma Assert (False);
      end if;
   end Version_Compare;

   --------------------
   -- Call_User_Func --
   --------------------

   function Call_User_Func (Callback : Callable;
                            Args     : Array_Type := Empty_Array)
                            return Array_Type
   is
   begin
      return Callback (Args);
   end Call_User_Func;

   --------------------------
   -- Call_User_Func_Array --
   --------------------------

   function Call_User_Func_Array (Callback : Callable;
                                  Args     : Array_Type)
                                  return Array_Type
   is
   begin
      return Callback (Args);
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
