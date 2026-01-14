--
--
--

with Arrays;
with Lists;

package Php.Preg
is
   use Arrays;
   use Lists;

   function Preg_Replace (Left  : String;
                          Right : String)
                          return Integer
   is (raise Program_Error with "not implemented");

   function Preg_Replace (Left  : String;
                          Mid   : String;
                          Right : Array_Type)
                          return Integer
   is (raise Program_Error with "not implemented");

   function Preg_Replace (Pattern     : String;
                          Replacement : String;
                          Subject     : String;
                          Limit       : Integer := -1;
                          Count       : out Natural)
                          return String;

   function Preg_Replace (Pattern     : String;
                          Replacement : String;
                          Subject     : String)
                          return String;

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Matches : out List_Type;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Integer;

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Matches : out Array_Type;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Integer;

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Boolean;

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Integer;

   procedure Preg_Match (Pattern : String;
                         Subject : String;
                         Matches : out List_Type;
                         Flags   : Integer := 0;
                         Offset  : Integer := 0);

   procedure Preg_Match (Pattern : String;
                         Subject : String;
                         Matches : out Array_Type;
                         Flags   : Integer := 0;
                         Offset  : Integer := 0);

   function Preg_Match_All (Pattern : String;
                            Subject : String;
                            Matches : out Array_Type;
                            Flags   : Integer := 0;
                            Offset  : Integer := 0)
                            return Integer;

   procedure Preg_Match_All (Pattern : String;
                             Subject : String;
                             Matches : out List_Type;
                             Flags   : Integer := 0;
                             Offset  : Integer := 0);

   type Flag_Type is new Natural;
   PREG_SPLIT_DELIM_CAPTURE : Flag_Type := 16#0001#;
   PREG_SPLIT_NO_EMPTY      : Flag_Type := 16#0002#;

   function Preg_Split (Pattern : String;
                        Subject : String;
                        Limit   : Integer   := -1;
                        Flags   : Flag_Type := 0)
                        return List_Type;

   function Preg_Quote (Str       : String;
                        Delimiter : String := "")
                        return String
   is (raise Program_Error with "not implemented");

   type Callable_10 is access function (Item : List_Type)
                              return String;

   function Preg_Replace_Callback (Pattern  : String;
                                   Callback : Callable_10;
                                   Subject  : String)
                                   return String;

end Php.Preg;
