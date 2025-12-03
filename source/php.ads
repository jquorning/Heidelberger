--
--
--

with Arrays;
with Lists;

with Inc_Class_Wp_Posts;

package Php
is
   use Arrays;
   use Lists;

   Debug : exception;

   function Get_Object_Vars (Arry : Array_Type) return Array_Type;
   function Get_Object_Vars (Object : Inc_Class_Wp_Posts.Wp_Post)
                             return Array_Type is (Empty_Array);

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

   function Is_Object (Post : Inc_Class_Wp_Posts.Wp_Post) return Boolean is (True);
   function Is_Object (Arry : Array_Type) return Boolean is (False);
   function Is_Array  (Arry : Array_Type) return Boolean is (True);
   function Is_Array  (List : List_Type) return Boolean is (True);

   function Array_Merge (Left, Right : Array_Type) return Array_Type
      is (Left);

   function Array_Merge (Arry_1, Arry_2, Arry_3 : Array_Type)
            return Array_Type
   is (Array_Merge (Array_Merge (Arry_1, Arry_2), Arry_3));

   function Array_Merge_Recursive (Left, Right : Array_Type)
                                   return Array_Type
                                   is (Left);

   function Array_Merge (Left, Right : List_Type) return List_Type
      is (Left);

   function Array_Diff (Left, Right : Array_Type) return Array_Type
      is (Left);

   function Array_Diff (Left, Right : List_Type) return List_Type
      is (Left);

   function Array_Diff (Left  : List_Type;
                        Right : String) return List_Type
      is (Left);

   function Array_Diff_Key (Arry : Array_Type;
                            That : Array_Type)
                            return Array_Type
                            is (Empty_Array);

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

   function Max (Arry : Array_Type) return Integer is (1);
   function Hexdec (Hex : String) return Integer is (99);

   function MT_Rand (Min : Natural;
                     Max : Natural)
                     return Natural;

--   type Func_Type is access function return Array_Type;
--   procedure Array_Walk (Arry     : Array_Type;
--                         Callback : Func_Type;
--                         Arg      : Array_Type := Empty_Array);
   function Array_Map (Item  : String;
                       Table : Array_Type)
                       return Array_Type is (Empty_Array);

   function Array_Map (Item  : String;
                       Table : Array_Type)
                       return List_Type is (Empty_List);

   function Array_Map (Item : String;
                       List : List_Type)
                       return List_Type is (Empty_List);

   function In_Array (Needle   : String;
                      Haystack : Array_Type;
                      Strict   : Boolean := False)
                      return Boolean is (False);

   function In_Array (Needle   : String;
                      Haystack : List_Type;
                      Strict   : Boolean := False)
                      return Boolean;

   function Ltrim (Item       : String;
                   Characters : String := "")
                   return String is (Item);

   function Rtrim (Item       : String;
                   Characters : String := "")
                   return String is (Item);

   function Trim (Item : String; Characters : String := "")
                  return String is (Item);

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

   function Compact (Var_Name  : String;
                     Var_Names : String)
                     return Array_Type
                     is (Empty_Array);

   procedure Array_Shift (List : in out List_Type);
   function Array_Shift (List : in out List_Type)
                         return String;

-- function Array_Shift (Arry : in out Array_Type)
--                       return Multi_Type;

   procedure Array_Unshift (Arry : in out Array_Type;
                            S    : String) is null;

   procedure Array_Unshift (List : in out List_Type;
                            Item : String)
                            is null;

   function Time return Natural
   is (9999);

   function URLencode (Item : String) return String is ("XXX-301");

   function Is_Int (A : Integer)   return Boolean is (True);
   function Is_String (A : String) return Boolean is (True);

   function Array_Values (Arry : Array_Type)
                          return List_Type
                          is (Empty_List);

   function Array_Values (Arry : Array_Type)
                          return Array_Type
                          is (Empty_Array);

   function File_Exists (Filename : String)
                         return Boolean
                         is (True);

   function Filesize (Filename : String)
                      return Natural
                      is (999);

   function Is_Dir (Filename : String)
                    return Boolean
                    is (False);

   function Stripslashes (Item : String)
                          return String
                          is (Item);

   type Flag_Type is new Natural;

   ENT_QUOTES     : constant Flag_Type := 16#0001#;
   ENT_SUBSTITUTE : constant Flag_Type := 16#0002#;
   ENT_HTML404    : constant Flag_Type := 16#0004#;
   ENT_NOQUOTES   : constant Flag_Type := 16#0008#;
   ENT_XML1       : constant Flag_Type := 16#0010#;
   ENT_HTML401    : constant Flag_Type := 16#0020#;
   -- Shold be or'ed together instead

   function HTML_Entity_Decode (Item     : String;
                                Flags    : Flag_Type;
                                Encoding : String := "")
                                return String
                                is ("XXX-312");

   function HTMLentities (Item          : String;
                          Flags         : Flag_Type := ENT_QUOTES;
                          Encoding      : String  := "";
                          Double_Encode : Boolean := True)
                          return String
                          is ("XXX-462");

   function HTMLspecialchars (Item          : String;
                              Flags         : Flag_Type := ENT_QUOTES +
                                                           ENT_SUBSTITUTE +
                                                           ENT_HTML401;
                              Encoding      : String := "";
                              Double_Encode : Boolean := True)
                              return String
                              is (Item);

   function Array_Keys (Arry : Array_Type)
                        return Array_Type
                        is (Empty_Array);

   function Array_Keys (Arry : Array_Type)
                        return List_Type
                        is (Empty_List);

   function Array_Keys (List : List_Type)
                        return List_Type
                        is (Empty_List);

   function Array_Keys (Arry         : Array_Type;
                        Filter_Value : String;
                        Strict       : Boolean := False)
                        return List_Type
                        is (Empty_List);

   function Array_Key_Exists (Key  : String;
                              Arry : Array_Type)
                              return Boolean
                              is (False);

   function Array_Key_Exists (Key  : String;
                              Arry : List_Type)
                              return Boolean
                              is (False);

   function Array_Search (Needle   : String;
                          Haystack : Array_Type;
                          Strict   : Boolean := False)
                          return String
                          is ("XXX-315");

   function Array_Search (Needle   : String;
                          Haystack : Array_Type;
                          Strict   : Boolean := False)
                          return Integer
                          is (99);

   function Array_Search (Needle   : String;
                          Haystack : List_Type;
                          Strict   : Boolean := False)
                          return String
                          is ("XXX-012");

   function Array_Intersect_Key (Arry   : Array_Type;
                                 Arry_2 : Array_Type)
                                 return Array_Type
                                 is (Empty_Array);

   function Array_Flip (Arry : Array_Type)
                        return Array_Type
                        is (Empty_Array);

   function Array_Flip (Arry : List_Type)
                        return Array_Type
                        is (Empty_Array);

   function Array_Fill_Keys (Keys  : Array_Type;
                             Value : Boolean)
                             return Array_Type
                             is (Empty_Array);

   function Array_Fill_Keys (Keys  : List_Type;
                             Value : Multi_Type)
                             return Array_Type
                             is (Empty_Array);

   ARRAY_FILTER_USE_KEY  : constant Integer := 47; -- arbitrary value
   ARRAY_FILTER_USE_BOTH : constant Integer := 48; -- arbitrary value

   type Filter_Callback_1 is access function (Item : String)
                                              return Boolean;
   type Filter_Callback_2 is access function (Item : Array_Type)
                                              return Boolean;

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_1 := null;
                          Mode     : Integer           := 0)
                          return Array_Type
                          is (Empty_Array);

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_1 := null;
                          Mode     : Integer          := 0)
                          return List_Type
                          is (Empty_List);

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_2; --  := null;
                          Mode     : Integer           := 0)
                          return Array_Type
                          is (Empty_Array);

   type Reduce_Callback is access function (Carry : String;
                                            Acc   : Array_Type)
                                            return String;

   function Array_Reduce (Arry     : Array_Type;
                          Callback : Reduce_Callback;
                          Initial  : String)
                          return String
                          is ("XXX-006");

   function Array_Combine (Keys   : Array_Type;
                           Values : Array_Type)
                           return Array_Type
                           is (Empty_Array);

   function Array_Combine (Keys   : List_Type;
                           Values : List_Type)
                           return Array_Type
                           is (Empty_Array);

   function Array_Column (Arry       : Array_Type;
                          Column_Key : String)
                          return Array_Type
                          is (Empty_Array);

   function Array_Pop (Arry : Array_Type)
                       return Integer
                       is (1);

   function Array_Pop (Arry : List_Type)
                       return String
                       is ("XXX-332");

   procedure Array_Pop (Arry : List_Type)
                        is null;

   function Array_Push (Arry  : Array_Type;
                        Value : Integer)
                        return Integer
                        is (1);

   procedure Array_Push (Arry  : Array_Type;
                         Value : String)
                         is null;

   function Array_Push (Arry  : List_Type;
                        Value : String)
                        return List_Type
                        is (Empty_List);

--   function Array_Push (Arry  : List_Type;
--                        Value : String_Array) -- Integer)
--                        return Integer
--                        is (1);

   function Array_Push (Arry  : List_Type;
                        Value : List_Type) -- Integer)
                        return Integer
                        is (1);

   function Array_Slice (Arry   : Array_Type;
                         Offset : Natural;
                         Length : Natural)
                         return Array_Type;

   function Array_Splice (Arry   : in out Array_Type;
                          Offset : Integer;
                          Length : Integer := 0)
                          return Array_Type
                          is (Empty_Array);

   function Is_Numeric (Value : String)
                        return Boolean
                        is (False);

   function Is_Numeric (Value : Integer)
                        return Boolean
                        is (True);

   function Is_File (Filename : String)
                     return Boolean
                     is (False);

   function Key (Arry : Array_Type)
                 return String
                 is ("XXX-024");

   procedure Sort (List : in out List_Type)
   is null;

   type USort_Comparator is access function (A, B : Multi_Type)
                                             return Integer;

   procedure USort (Arry     : in out Array_Type;
                    Callback : USort_Comparator);

   SORT_REGULAR : constant Integer := 47; -- arbitrary

   procedure Ksort (Arry  : in out Array_Type;
                    Flags : Integer := SORT_REGULAR)
                    is null;

   type Unique_Flags is (Sort_String);

   function Array_Unique (Arry  : Array_Type;
                          Flags : Unique_Flags := Sort_String)
                          return Array_Type
                          is (Empty_Array);

   function Array_Unique (Arry  : List_Type;
                          Flags : Unique_Flags := Sort_String)
                          return List_Type
                          is (Empty_List);

   function Array_Unique (Arry  : List_Type;
                          Flags : Unique_Flags := Sort_String)
                          return Array_Type
                          is (Empty_Array);

   function Array_Intersect (Arry    : Array_Type;
                             Array_2 : Array_Type)
                             return Array_Type
                             is (Empty_Array);

   function Array_Intersect (List   : List_Type;
                             List_2 : List_Type)
                             return List_Type
                             is (Empty_List);

   function Array_Reverse (Arry          : Array_Type;
                           Preserve_Keys : Boolean := False)
                           return Array_Type
                           is (Empty_Array);

   function Array_Reverse (List : List_Type)
                           return List_Type
                           is (Empty_List);

   function Array_Replace_Recursive (Arry    : Array_Type;
                                     Array_2 : Array_Type)
                                     return Array_Type
                                     is (Empty_Array);

   function Basename (Path : String;
                      Suffix : String := "")
                      return String
                      is ("XXX-521");

   function Is_Readable (Filename : String)
                         return Boolean
                         is (True);

   function Stream_Get_Wrappers
            return List_Type
            is (Empty_List);

   function Stristr (Haystack      : String;
                     Needle        : String;
                     Before_Needle : Boolean := False)
                     return Boolean  -- string|false
                     is (False);

   procedure Header (Header        : String;
                     Replace       : Boolean := True;
                     Response_Code : Integer := 0)
                     is null;

   function Error_Get_Last
            return Array_Type
            is (Empty_Array);

   function Strip_Tags (Item         : String;
                        Allowed_Tags : Array_Type := Empty_Array)
                        return String
                        is ("XXX-600");

   function Ini_Get (Option : String)
                     return String
                     is ("XXX-602");

   function Ini_Get (Option : String)
                     return Boolean
                     is (True);

   function JSON_Encode (Value : Multi_Type)
                         return String
                         is ("XXX-007");

   function JSON_Decode (JSON        : String;
                         Associative : Boolean := False)
                         return Array_Type
                         is (Empty_Array);

   JSON_ERROR_NONE : constant Integer := 0; -- Arbitrary value

   function JSON_Last_Error
            return Integer
            is (JSON_ERROR_NONE);

   function JSON_Last_Error_Msg
            return String
            is ("XXX-979");

   E_USER_NOTICE : constant Integer := 47;  -- Arbitraty

   procedure Trigger_Error (Message     : String;
                            Error_Level : Integer := E_USER_NOTICE)
                            is null;

   procedure Die (Reason : String := "")
             is null;

   function Dirname (Path   : String;
                     Levels : Positive := 1)
                     return String
                     is ("XXX-702");

   function Glob (Pattern : String;
                  Flags   : Integer := 0)
                  return List_Type
                  is (Empty_List);

   function Addslashes (Item : String)
            return String;

   function Printf (Format : String;
                    Args   : List_Type)
                    return String;

   function Sprintf (Format : String;
                     Args   : List_Type)
                     return String;

   function Vsprintf (Format : String;
                      Args   : List_Type)
                      return String;

   function Realpath (Path : String)
            return String
            is ("XXX-779");

   type Resource is access all Integer;

   function File_Get_Contents (Filename         : String;
                               Use_Include_Path : Boolean  := False;
                               Context          : Resource := null;
                               Offset           : Integer  := 0;
                               Length           : Integer  := 0)
            return String
            is ("XXX-780");

   procedure Error_Reporting (Error_Level : Integer := 0)
             is null;

   PHP_URL_SCHEME : constant Integer := 1; -- XXX guess

   function Parse_URL (URL       : String;
                       Component : Integer := -1)
            return String
            is ("XXX-781");

   function Strtok (Item  : String;
                    Token : String)
                    return String
                    is ("XXX-783");

   function Str_Split (Item   : String;
                       Length : Natural := 1)
                       return Array_Type
                       is (Empty_Array);

   function Call_User_Func (Callback : Callable;
                            Args     : String := "")
                            return String;

   function Call_User_Func_Array (Callback : Callable;
                                  Args     : Array_Type)
                                  return String;

   function Func_Get_Args
            return Array_Type;

   function MD5 (Item   : String;
                 Binary : Boolean := False)
                 return String
                 is ("XXX-937");

   function Serialize (Value : String)
                       return String
                       is ("XXX-978");

   function RawURLencode (Item : String)
                          return String
                          is ("XXX-977");

   function URLdecode (Item : String)
                       return String
                       is ("XXX-976");

   function Round (Num       : Float;
                   Precision : Integer)
                   return Float
                   is (99.99);

   function Current (List : List_Type)
                     return String
                     is ("XXX-011");

   function Endd (List : List_Type)
                  return String
                  is ("XXX-018");

   function Function_Exists (Func : String)
                             return Boolean
                             is (True);

   -------------------
   -- Echo handling --
   -------------------

   procedure Echo (Item : String);

   procedure Printf (Format : String;
                     Args   : List_Type);

   procedure Clear_Echo;
   function Get_Echo
            return String;

   procedure OB_Start
   is null;

   function OB_Get_Clean
            return String
            is ("XXX-015");

end Php;
