--
--
--

with Class_Session_Tokens;
with Class_Users;

package Class_Session_Tokens_Factory
is

   --
   --
   --
   function Get_Instance (User_Id : Class_Users.User_Id_Type)
                          return Class_Session_Tokens.Wp_Session_Tokens'Class;

end Class_Session_Tokens_Factory;
