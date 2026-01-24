--
--
--

with Class_Session_Tokens;

package Class_Session_Tokens_Factory
is

   --
   --
   --
   function Get_Instance (User_Id : Integer)
                          return Class_Session_Tokens.Wp_Session_Tokens'Class;

end Class_Session_Tokens_Factory;
