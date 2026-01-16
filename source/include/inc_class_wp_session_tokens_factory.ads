--
--
--

with Inc_Class_Wp_Session_Tokens;

package Inc_Class_Wp_Session_Tokens_Factory
is

   --
   --
   --
   function Get_Instance (User_Id : Integer)
                          return Inc_Class_Wp_Session_Tokens.Wp_Session_Tokens'Class;

end Inc_Class_Wp_Session_Tokens_Factory;
