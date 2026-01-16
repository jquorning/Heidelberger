--
-- Session API: WP_Session_Tokens class
--
-- @package WordPress
-- @subpackage Session
-- @since 4.7.0
--

with Php.Misc;
with Php.Numerics;

with Inc_Plugins;

package body Inc_Class_Wp_Session_Tokens
is

   -----------------
   -- X_Construct --
   -----------------

   procedure X_Construct (This    : out Wp_Session_Tokens'Class;
                          User_Id : Integer)
   is
   begin
      This.User_Id := User_Id;
   end X_Construct;

   ----------------
   -- Hash_Token --
   ----------------

   function Hash_Token (This  : Wp_Session_Tokens;
                        Token : String)
                        return String
   is
      use Php.Misc;
      use Php.Numerics;
   begin
      -- If ext/hash is not present, use sha1() instead.
      if Function_Exists ("hash") then
         return Hash ("sha256", Token);
      else
         return SHA1 (Token);
      end if;
   end Hash_Token;

   ------------
   -- Verify --
   ------------

   function Verify (This  : Wp_Session_Tokens;
                    Token : String)
                    return Boolean
   is
      Verifier : constant String := This.Hash_Token (Token);
   begin
      return This.Get_Session (Verifier) /= Empty_Array; -- (bool)
   end Verify;

end Inc_Class_Wp_Session_Tokens;
