with Arrays;
with Inc_Class_Wp_Posts;

package Php
is
   use Arrays;

   function Get_Object_Vars (Arry : Array_Type) return Array_Type;
   function Get_Object_Vars (Object : Inc_Class_Wp_Posts.Wp_Post)
                             return Array_Type is (Empty_Array);

   function Strpos (Item    : String;
                    Pattern : String)
                    return Natural;

   function Stripos (Heystack : String; Needle : String) return Natural
      is (1);

   function Str_Replace (Search  : String;
                         Replace : String;
                         Item    : String) return String is ("XXX-112");

   function Str_Replace (Search  : List_Type;
                         Replace : String;
                         Item    : String) return String is ("XXX-221");

   function Preg_Replace (Left : String; Right : String) return Integer is (1);

   -- function Preg_Replace (Pattern     : String;
   --                        Replacement : String;
   --                        Subject     : String)
   --                        return String
   --                        is ("XXX-230");

   function Preg_Replace (Left : String; Mid : String; Right : Array_Type)
       return Integer is (1);

   function Preg_Replace (Pattern     : String;
                          Replacement : String;
                          Subject     : String) return String is (Subject);

   function Preg_Match (Pattern : String;
                        Subject : String;
                        Matches : out List_Type;
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
                            Matches : out List_Type;
                            Flags   : Integer := 0;
                            Offset  : Integer := 0)
                            return Integer is (1);

   function Is_Object (Post : Inc_Class_Wp_Posts.Wp_Post) return Boolean is (True);
   function Is_Object (Arry : Array_Type) return Boolean is (False);
   function Is_Array  (Arry : Array_Type) return Boolean is (True);
   function Is_Array  (List : List_Type) return Boolean is (True);

   function Array_Merge (Left, Right : Array_Type) return Array_Type
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

   function Strtoupper (Item : String) return String is (Item);
   function Strtolower (Item : String) return String is (Item);

   function Max (Arry : Array_Type) return Integer is (1);

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
                      return Boolean is (False);

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
                     Item      : String)
                     return List_Type;

   function Implode (Separator : String;
                     Arry      : Array_Type)
                     return String is ("XXX-206");

   function Implode (Separator : String;
                     Arry      : String)
                     return String is ("XXX-206");

   function Implode (Separator : String;
                     List      : List_Type)
                     return String is ("XXX-307");

   function Compact (Var_Name  : String;
                     Var_Names : String)
                     return Array_Type
                     is (Empty_Array);

   procedure Array_Unshift (Arry : in out Array_Type;
                            S    : String) is null;

   function Urlencode (Item : String) return String is ("XXX-301");

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

   function Is_Dir (Filename : String)
                    return Boolean
                    is (False);

   function Substr (Str    : String;
                    Offset : Integer;
                    Length : Integer := 0)
                    return String
                    is ("XXX-309");

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

   function Html_Entity_Decode (Item     : String;
                                Flags    : Flag_Type;
                                Encoding : String := "")
                                return String
                                is ("XXX-312");

   function Htmlentities (Item          : String;
                          Flags         : Flag_Type := ENT_QUOTES;
                          Encoding      : String  := "";
                          Double_Encode : Boolean := True)
                          return String
                          is ("XXX-462");

   function Htmlspecialchars (Item          : String;
                              Flags         : Flag_Type := ENT_QUOTES +
                                                           ENT_SUBSTITUTE +
                                                           ENT_HTML401;
                              Encoding      : String := "";
                              Double_Encode : Boolean := True)
                              return String
                              is (Item);

   function Array_Keys (Arry : Array_Type)
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

   function Array_Fill_Keys (Keys  : Array_Type;
                             Value : Boolean)
                             return Array_Type
                             is (Empty_Array);

   function Array_Filter (Arry     : Array_Type;
                          Callback : Integer := 0)
                          return List_Type
                          is (Empty_List);

   function Array_Pop (Arry : Array_Type)
                       return Integer
                       is (1);

   function Array_Pop (Arry : List_Type)
                       return String
                       is ("XXX-332");

   function Array_Push (Arry  : Array_Type;
                        Value : Integer)
                        return Integer
                        is (1);

   function Array_Push (Arry  : List_Type;
                        Value : String)
                        return List_Type
                        is (Empty_List);

   function Array_Push (Arry  : List_Type;
                        Value : String_Array) -- Integer)
                        return Integer
                        is (1);

   function Array_Push (Arry  : List_Type;
                        Value : List_Type) -- Integer)
                        return Integer
                        is (1);

   function Is_Numeric (Value : String)
                        return Boolean
                        is (False);

   function Is_File (Filename : String)
                     return Boolean
                     is (False);

   type Unique_Flags is (Sort_String);

   function Array_Unique (Arry  : Array_Type;
                          Flags : Unique_Flags := Sort_String)
                          return Array_Type
                          is (Empty_Array);

   function Array_Unique (Arry  : List_Type;
                          Flags : Unique_Flags := Sort_String)
                          return List_Type
                          is (Empty_List);

   function Array_Intersect (Arry    : Array_Type;
                             Array_2 : Array_Type)
                             return Array_Type
                             is (Empty_Array);

   function Array_Intersect (List   : List_Type;
                             List_2 : List_Type)
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

   function Strip_Tags (Item :        String;
                        Allowed_Tags : Array_Type := Empty_Array)
                        return String
                        is ("XXX-600");

   function Ini_Get (Option : String)
                     return String
                     is ("XXX-602");

   function Ini_Get (Option : String)
                     return Boolean
                     is (True);

   function JSON_Decode (JSON : String)
                         return Array_Type
                         is (Empty_Array);

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

   function Addslash (Item : String)
            return String
            is ("XXX-713");

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

   function File_Get_Contents (Filename : String)
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

   -------------------
   -- Echo handling --
   -------------------

   procedure Echo (Item : String);

   procedure Printf (Format : String;
                     Args   : List_Type);

   procedure Clear_Echo;
   function Get_Echo
            return String;

end Php;
