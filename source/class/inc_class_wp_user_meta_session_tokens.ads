--
-- Session API: WP_User_Meta_Session_Tokens class
--
-- @package WordPress
-- @subpackage Session
-- @since 4.7.0
--

with Arrays;

with Inc_Class_Wp_Session_Tokens;

package Inc_Class_Wp_User_Meta_Session_Tokens
is
   use Arrays;

   --
   -- Meta-based user sessions token manager.
   --
   -- @since 4.0.0
   --
   -- @see WP_Session_Tokens
   --
   type Wp_User_Meta_Session_Tokens is
      new Inc_Class_Wp_Session_Tokens.Wp_Session_Tokens
      with null record;

   --
   --
   --
   function X_Construct (User_Id : Integer)
                         return Wp_User_Meta_Session_Tokens;

   --
   -- Retrieves all sessions of the user.
   --
   -- @since 4.0.0
   --
   -- @return array Sessions of the user.
   --
   -- protected
   function Get_Sessions (This : Wp_User_Meta_Session_Tokens)
                          return Array_Type;

        -- --
        -- -- Converts an expiration to an array of session information.
        -- --
        -- -- @param mixed session Session or expiration.
        -- -- @return array Session.
        -- --
        -- protected function prepare_session( session ) then
        --         if ( is_int( session ) ) then
        --                 return array( "expiration" => session );
        --         end;

        --         return session;
        -- end;

   --
   -- Retrieves a session based on its verifier (token hash).
   --
   -- @since 4.0.0
   --
   -- @param string verifier Verifier for the session to retrieve.
   -- @return array|null The session, or null if it does not exist
   --
   -- protected
   function Get_Session (This : Wp_User_Meta_Session_Tokens;
                         Verifier : String)
                         return Array_Type;
        --         sessions = this.get_sessions();

        --         if ( isset( sessions[ verifier ] ) ) then
        --                 return sessions[ verifier ];
        --         end;

        --         return null;
        -- end;

        -- --
        -- -- Updates a session based on its verifier (token hash).
        -- --
        -- -- @since 4.0.0
        -- --
        -- -- @param string verifier Verifier for the session to update.
        -- -- @param array  session  Optional. Session. Omitting this argument destroys the session.
        -- --
        -- protected function update_session( verifier, session = null ) then
        --         sessions = this.get_sessions();

        --         if ( session ) then
        --                 sessions[ verifier ] = session;
        --         end; else then
        --                 unset( sessions[ verifier ] );
        --         end;

        --         this.update_sessions( sessions );
        -- end;

        -- --
        -- -- Updates the user"s sessions in the usermeta table.
        -- --
        -- -- @since 4.0.0
        -- --
        -- -- @param array sessions Sessions.
        -- --
        -- protected function update_sessions( sessions ) then
        --         if ( sessions ) then
        --                 update_user_meta( this.user_id, "session_tokens", sessions );
        --         end; else then
        --                 delete_user_meta( this.user_id, "session_tokens" );
        --         end;
        -- end;

        -- --
        -- -- Destroys all sessions for this user, except the single session with the given verifier.
        -- --
        -- -- @since 4.0.0
        -- --
        -- -- @param string verifier Verifier of the session to keep.
        -- --
        -- protected function destroy_other_sessions( verifier ) then
        --         session = this.get_session( verifier );
        --         this.update_sessions( array( verifier => session ) );
        -- end;

        -- --
        -- -- Destroys all session tokens for the user.
        -- --
        -- -- @since 4.0.0
        -- --
        -- protected function destroy_all_sessions() then
        --         this.update_sessions( array() );
        -- end;

        -- --
        -- -- Destroys all sessions for all users.
        -- --
        -- -- @since 4.0.0
        -- --
        -- public static function drop_sessions() then
        --         delete_metadata( "user", 0, "session_tokens", false, true );
        -- end;

end Inc_Class_Wp_User_Meta_Session_Tokens;
