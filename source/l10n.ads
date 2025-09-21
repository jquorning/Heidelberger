with Arrays;

package L10n
is
   use Arrays;

   function "abs" (Item : String) return String;
   function Plural (Single : String; Plural : String; Argument : String) return String;
   function Gettext (Item : String) return String;
   function E_E (Item : String) return String is ("XXX-103");
   function Ex_Ex (Item : String; Arg : String := "") return String is ("XXX-104");
   function X_X (Item : String; A2 : String) return String is ("XXX-231");
   function N_N (Single : String; Plural : String; Switch : Natural)
                return String is ("XXX-232");
   function Esc_Attr_E (Item : String) return String is (Item & "XXX-309");
   function Esc_Attr_X (Item : String) return String is (Item & "XXX-310");

   function Load_Script_Textdomain (Handle : String;
                                    Domain : String;
                                    Path   : String)
                                    return String
                                    is ("XXX-311");

   function N_N_Noop (Arg_1, Arg_2 : String)
                      return Array_type
                      is (Empty_Array);

end L10n;
