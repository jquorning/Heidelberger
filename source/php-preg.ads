--
--
--

package Php.Preg
is

   function Preg_Replace (Left  : String;
                          Right : String)
                          return Integer
                          is (1);

   function Preg_Replace (Left  : String;
                          Mid   : String;
                          Right : Array_Type)
                          return Integer
                          is (1);

   function Preg_Replace (Pattern     : String;
                          Replacement : String;
                          Subject     : String)
                          return String
                          is (Subject);

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

   function Preg_Match_All (Pattern : String;
                            Subject : String;
                            Matches : out Array_Type;
                            Flags   : Integer := 0;
                            Offset  : Integer := 0)
                            return Integer is (1);

   function Preg_Split (Pattern : String;
                        Subject : String;
                        Limit   : Integer := -1)
                        return List_Type
                        is (Empty_List);

   function Preg_Quote (Str       : String;
                        Delimiter : String := "")
                        return String
                        is ("XXX-985");

   type Callable_10 is access function (Item : List_Type)
                              return String;

   function Preg_Replace_Callback (Pattern  : String;
                                   Callback : Callable_10;
                                   Subject  : String)
                                   return String
                                   is ("XXX-001");

end Php.Preg;
