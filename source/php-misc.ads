--
--
--

with Arrays;
with Lists;

package Php.Misc
is
   use Arrays;
   use Lists;

   PHP_VERSION : constant String := "8.2.29";

   function Version_Compare (Version1 : String;
                             Version2 : String;
                             Operator : String)
                             return Boolean
                             is (True);

   function Env_Exists (Name : String)
                        return Boolean
                        is (False);

   function Get_Env  (Name : String)
                      return String
                      is ("XXX-995");

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

   function Current (List : List_Type)
                     return String
                     is ("XXX-011");

   function Endd (List : List_Type)
                  return String
                  is ("XXX-018");

   function Function_Exists (Func : String)
                             return Boolean
                             is (True);

   function Microtime
            return String
            is ("XXX-964");

   ALL_WITH_BC : constant String := "ALL";

   function Timezone_Identifiers_List (A : String)
            return List_Type
            is (Empty_List);

end Php.Misc;
