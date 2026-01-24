--
--
--

with Inc_Class_Wp_User_Meta_Session_Tokens;
with Inc_Plugins;

package body Class_Session_Tokens_Factory
is

   ------------------
   -- Get_Instance --
   ------------------

   function Get_Instance (User_Id : Integer)
                          return Class_Session_Tokens.Wp_Session_Tokens'Class
   is
      use Inc_Class_Wp_User_Meta_Session_Tokens;
      use Inc_Plugins;

      --
      -- Filters the class name for the session token manager.
      --
      -- @since 4.0.0
      --
      -- @param string session Name of class to use as the manager.
      --                        Default 'WP_User_Meta_Session_Tokens'.
      --
      Manager : constant String :=
        Apply_Filters ("session_token_manager", "WP_User_Meta_Session_Tokens");
   begin
      if Manager = "WP_User_Meta_Session_Tokens" then
         return X_Construct (User_Id);
      else
         pragma Assert (False);
      end if;
--    return new Manager (User_Id);
   end Get_Instance;

end Class_Session_Tokens_Factory;
