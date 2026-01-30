--
--
--

with Arrays;
with Lists;
with UStrings;

package Php.Strings
is
   use Arrays;
   use Lists;

   function Empty (A : String)
                   return Boolean
                   is (A'Length = 0);

   function Empty (A : UStrings.UString)
                   return Boolean
                   is (UStrings.Length (A) in 0);

   function Isset (Item : String)
                   return Boolean;

   function Strstr (Haystack      : String;
                    Needle        : String;
                    Before_Needle : Boolean := False)
                    return String;

   function Strpos (Item    : String;
                    Pattern : String)
                    return Natural;

   function Strrpos (Haystack : String;
                     Needle   : String)
                     return Natural;

   function Strripos (Haystack : String;
                      Needle   : String)
                      return Natural
   is (raise Program_Error with "not implemented");

   function Stripos (Haystack : String;
                     Needle   : String)
                     return Natural;

   function Substr_Count (Haystack : String;
                          Needle   : String)
                          return Natural;

   function Substr_Replace (Item    : String;
                            Replace : String;
                            Offset  : Natural;
                            Length  : Natural)
                            return String;

   STR_PAD_RIGHT : constant Integer := 1;
   STR_PAD_LEFT  : constant Integer := 2;

   function Str_Pad (Item       : String;
                     Length     : Integer;
                     Pad_String : Character := ' ';
                     Pad_Type   : Integer   := STR_PAD_RIGHT)
                     return String;

   function Str_Replace (Search  : String;
                         Replace : String;
                         Subject : String)
                         return String;

   function Str_Ireplace (Search  : String;
                          Replace : String;
                          Subject : String)
                          return String
   is (raise Program_Error with "not implemented");

   function Str_Replace (Search  : List_Type;
                         Replace : List_Type;
                         Subject : String)
                         return String;

   function Str_Replace (Search  : List_Type;
                         Replace : String;
                         Subject : String)
                         return String;

   function Str_Replace (Search  : List_Type;
                         Replace : String;
                         Subject : String;
                         Count   : out Natural)
                         return String;

   function Str_Repeat (Item  : String;
                        Times : Natural)
                        return String;

   function Substr (Item   : String;
                    Offset : Integer;
                    Length : Integer := Integer'First)
                    return String;

   function Strlen (Item : String)
                    return Natural;

   function Str_Starts_With (Haystack : String;
                             Needle   : String)
                             return Boolean;

   function Str_Contains (Haystack : String;
                          Needle   : String)
                          return Boolean;

   function Strtoupper (Item : String) return String;
   function Strtolower (Item : String) return String;
   function UC_First   (Item : String) return String;

   function Strncmp (Left   : String;
                     Right  : String;
                     Length : Integer)
                     return Integer;

   function Strnatcasecmp (Left, Right : String)
                           return Integer;

   Default_Characters : constant String :=
     " " & ASCII.LF & ASCII.CR & ASCII.HT & ASCII.VT & ASCII.NUL;

   function Ltrim (Item       : String;
                   Characters : String := Default_Characters)
                   return String;

   function Rtrim (Item       : String;
                   Characters : String := Default_Characters)
                   return String;

   function Trim (Item       : String;
                  Characters : String := Default_Characters)
                  return String;

--   function Trim (Item : String)
--                  return String;

   function Sprintf (Format : String;
                     Args   : List_Type)
                     return String;

   function Vsprintf (Format : String;
                      Args   : List_Type)
                      return String;

   function Strtok (Item  : String;
                    Token : String)
                    return String;

   function Strpbrk (Item       : String;
                     Characters : String)
                     return String;

   function Str_Split (Item   : String;
                       Length : Natural := 1)
                       return Array_Type;

   function Strval (Value : String)
                    return String
                    is (Value);

   function Stristr (Haystack      : String;
                     Needle        : String;
                     Before_Needle : Boolean := False)
                     return Boolean;  -- string|false

   function Strcasecmp (Left, Right : String)
                        return Natural
   is (raise Program_Error with "not implemented");

   function Strip_Tags (Item         : String;
                        Allowed_Tags : Array_Type := Empty_Array)
                        return String;

   function Add_Slashes (Item : String)
            return String;

   function Add_C_Slashes (Item       : String;
                           Characters : String)
                           return String;

   function Strip_Slashes (Item : String)
                          return String;

   function Printf (Format : String;
                    Args   : List_Type)
                    return String;

   function Implode (Separator : String;
                     Arry      : Array_Type)
                     return String;

   function Implode (Separator : String;
                     Arry      : String)
                     return String;

   function Implode (Separator : String;
                     List      : List_Type)
                     return String;

   function Explode (Separator : String;
                     Item      : String;
                     Limit     : Integer := Integer'Last)
                     return List_Type;

   function Explode (Separator : String;
                     Item      : String;
                     Limit     : Integer := Integer'Last)
                     return Array_Type;

end Php.Strings;
