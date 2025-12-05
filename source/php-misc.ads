--
--
--

with Arrays;
with Lists;

package Php.Misc
is
   use Arrays;
   use Lists;

   function Compact (Var_Name  : String;
                     Var_Names : String)
                     return Array_Type
                     is (Empty_Array);

   function Time return Natural
   is (9999);

   function GMdate (Format    : String;
                    Timestamp : Integer)
                    return String
                    is ("XXX-025");

   function Get_Object_Vars (Arry : Array_Type) return Array_Type;

   function Key (Arry : Array_Type)
                 return String
                 is ("XXX-024");

   function Stream_Get_Wrappers
            return List_Type
            is (Empty_List);

   function Call_User_Func (Callback : Callable;
                            Args     : String := "")
                            return String;

   function Call_User_Func_Array (Callback : Callable;
                                  Args     : Array_Type)
                                  return String;

   function Func_Get_Args
            return Array_Type;

   function MD5 (Item   : String;
                 Binary : Boolean := False)
                 return String
                 is ("XXX-937");

   function Serialize (Value : String)
                       return String
                       is ("XXX-978");

   function Current (List : List_Type)
                     return String
                     is ("XXX-011");

   function Endd (List : List_Type)
                  return String
                  is ("XXX-018");

   function Function_Exists (Func : String)
                             return Boolean
                             is (True);

end Php.Misc;
