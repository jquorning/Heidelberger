--
--
--

package Php.Strings
is

   function Strstr (Haystack      : String;
                    Needle        : String;
                    Before_Needle : Boolean := False)
                    return String;

   function Strpos (Item    : String;
                    Pattern : String)
                    return Natural;

   function Stripos (Heystack : String;
                     Needle   : String)
                     return Natural
                     is (999);

   function Str_Replace (Search  : String;
                         Replace : String;
                         Subject : String)
                         return String;

   function Str_Replace (Search  : List_Type;
                         Replace : List_Type;
                         Subject : String)
                         return String
                         is ("XXX-020");

   function Str_Replace (Search  : List_Type;
                         Replace : String;
                         Subject : String)
                         return String
                         is ("XXX-221");

   function Str_Repeat (Item  : String;
                        Times : Natural)
                        return String
                        is ("XXX-010");

   function Substr (Str    : String;
                    Offset : Integer;
                    Length : Integer := 0)
                    return String;

   function Strlen (Item : String)
                    return Natural
                    is (Item'Length);

   function Str_Starts_With (Haystack : String;
                             Needle   : String)
                             return Boolean
                             is (True);

   function Str_Contains (Haystack : String;
                          Needle   : String)
                          return Boolean
                          is (False);

   function Strtoupper (Item : String) return String is (Item);
   function Strtolower (Item : String) return String is (Item);
   function UCfirst    (Item : String) return String is (Item);

   function Strncmp (Left, Right : String;
                     Length : Integer)
                     return Integer
                     is (1);

   function Strnatcasecmp (Left, Right : String)
                           return Integer;

   function Ltrim (Item       : String;
                   Characters : String := "")
                   return String is (Item);

   function Rtrim (Item       : String;
                   Characters : String := "")
                   return String is (Item);

   function Trim (Item : String; Characters : String := "")
                  return String is (Item);

   function Sprintf (Format : String;
                     Args   : List_Type)
                     return String;

   function Vsprintf (Format : String;
                      Args   : List_Type)
                      return String;

   function Strtok (Item  : String;
                    Token : String)
                    return String
                    is ("XXX-783");

   function Str_Split (Item   : String;
                       Length : Natural := 1)
                       return Array_Type
                       is (Empty_Array);

   function Stristr (Haystack      : String;
                     Needle        : String;
                     Before_Needle : Boolean := False)
                     return Boolean  -- string|false
                     is (False);

   function Strip_Tags (Item         : String;
                        Allowed_Tags : Array_Type := Empty_Array)
                        return String
                        is ("XXX-600");

   function Glob (Pattern : String;
                  Flags   : Integer := 0)
                  return List_Type
                  is (Empty_List);

   function Addslashes (Item : String)
            return String;

   function Printf (Format : String;
                    Args   : List_Type)
                    return String;

   function Explode (Item  : String;
                     Table : Array_Type)
                     return Array_Type
                     is (Empty_Array);

   function Explode (Item : String;
                     List : List_Type)
                     return List_Type
                     is (Empty_List);

   function Explode (Separator : String;
                     Item      : String;
                     Limit     : Integer := Integer'Last)
                     return List_Type;

   function Implode (Separator : String;
                     Arry      : Array_Type)
                     return String;

   function Implode (Separator : String;
                     Arry      : String)
                     return String is ("XXX-208");

   function Implode (Separator : String;
                     List      : List_Type)
                     return String is ("XXX-307");

end Php.Strings;
