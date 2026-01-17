--
--
--

package body Php.Misc
is

   function Get_Object_Vars (Arry : Array_Type) return Array_Type is (Empty_Array);

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
