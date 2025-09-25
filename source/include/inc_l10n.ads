--
-- Core Translation API
--
-- @package WordPress
-- @subpackage i18n
-- @since 1.2.0
--

with Arrays;

package Inc_L10n
is
   use Arrays;

   function "abs" (Item : String) return String;
   function Plural (Single : String; Plural : String; Argument : String) return String;
   function Gettext (Item : String) return String;
   function X_E (Item : String) return String is (Item & " XXX-103");
   function X_Ex (Item : String; Arg : String := "") return String is ("XXX-104");
   function X_X (Item : String; A2 : String)
                 return String
                 is (Item & " XXX-231 " & A2);
   function X_N (Single : String; Plural : String; Switch : Natural)
                return String is ("XXX-232");
   function Esc_Attr_E (Item : String) return String is (Item & "XXX-309");
   function Esc_Attr_X (Item : String) return String is (Item & "XXX-514");

   function Load_Script_Textdomain (Handle : String;
                                    Domain : String;
                                    Path   : String)
                                    return String
                                    is ("XXX-311");

   function X_N_Noop (Arg_1, Arg_2 : String)
                      return Array_Type
                      is (Empty_Array);

   function Get_User_Locale (User : Integer := 0)
                             return String
                             is ("da_DK");
   function Translate (Text   : String;
                       Domain : String := "default")
                       return String
                       is (Text);
end Inc_L10n;
