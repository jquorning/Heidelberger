--
-- Session API: WP_User_Meta_Session_Tokens class
--
-- @package WordPress
-- @subpackage Session
-- @since 4.7.0
--

with Php.Types;

with Inc_Users;

package body Class_User_Meta_Session_Tokens
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (User_Id : Class_Users.User_Id_Type)
                         return Wp_User_Meta_Session_Tokens
   is
      This : Wp_User_Meta_Session_Tokens;
   begin
      Class_Session_Tokens.X_Construct (This, User_Id);
      return This;
   end X_Construct;

   ------------------
   -- Get_Sessions --
   ------------------

   function Get_Sessions (This : Wp_User_Meta_Session_Tokens)
                          return Array_Type
   is
      use Php.Types;
      use Inc_Users;

      Sessions : constant Array_Type :=
        Get_User_Meta (This.User_Id, "session_tokens", True);
   begin
      if not Is_Array (Sessions) then
         return Empty_Array;
      end if;

      raise Program_Error with "not implemented";
--    Sessions := Array_Map (array( this, "prepare_session" ), Sessions);
--    return Array_Filter (Sessions, array( this, "is_still_valid"));
   end Get_Sessions;

   -----------------
   -- Get_Session --
   -----------------

   function Get_Session (This     : Wp_User_Meta_Session_Tokens;
                         Verifier : String)
                         return Array_Type
   is
      Sessions : constant Array_Type := This.Get_Sessions;
   begin
      if Isset (Sessions, Verifier) then
         return As_Array (Get (Sessions, Verifier));
      end if;

      return Empty_Array; -- null;
   end Get_Session;

end Class_User_Meta_Session_Tokens;
