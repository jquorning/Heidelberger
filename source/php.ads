with Arrays;
with Inc_Class_Wp_Posts;

package Php
is
   use Arrays;

   function Get_Object_Vars (Arry : Array_Type) return Array_Type;
   function Get_Object_Vars (Object : Inc_Class_Wp_Posts.Wp_Post)
                             return Array_Type is (Empty_Array);

   function Strpos (Item : String; Pattern : String) return Natural
      is (1);

   function Str_Replace (Search  : String;
                         replace : String;
                         Item    : String) return String is ("XXX-112");

   function Str_Replace (Search  : List_Type;
                         replace : String;
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
                        Matches : out Array_Type;
                        Flags   : Integer := 0;
                        Offset  : Integer := 0)
                        return Integer is (1);

   function Preg_Match_All (Pattern : String;
                            Subject : String;
                            Matches : out Array_Type;
                            Flags   : Integer := 0;
                            Offset  : Integer := 0)
                            return Integer is (1);

   function Vsprintf (Format : String;
                      Arg    : Array_Type) return String is (Format);

   function Is_Object (Post : Inc_Class_Wp_Posts.Wp_Post) return Boolean is (True);
   function Is_Object (Arry : Array_Type) return Boolean is (False);
   function Is_Array  (Arry : Array_Type) return Boolean is (True);

   function Array_Merge (Left, Right : Array_Type) return Array_Type
      is (Left);
   function Array_Diff (Left, Right : Array_Type) return Array_Type
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

   function Array_Map (Item : String; Table : Array_Type)
                       return List_Type is (Empty_List);

   function In_Array (Needle   : String;
                      Haystack : Array_Type;
                      Strict   : Boolean := False)
                      return Boolean is (True);
   function In_Array (Needle   : String;
                      Haystack : List_Type;
                      Strict   : Boolean := False)
                      return Boolean is (False);
   function Ltrim (Item : String; Xx : String) return String is (Item);

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
                     return List_Type
                     is (Empty_List);

--   function Implode (Item : String; Table : Array_Type) return String;
--   function Implode (Item : String; Item_2 : Unbounded_String) return String;

   function Implode (Separator : String;
                     Arry      : Array_Type)
                     return String is ("XXX-206");

   function Implode (Separator : String;
                     Arry      : String)
                     return String is ("XXX-206");

   function Implode (Separator : String;
                     List      : List_Type)
                     return String is ("XXX-307");

   procedure Array_Unshift (Arry : in out Array_Type;
                            S    : String) is null;

   function Urlencode (Item : String) return String is ("XXX-301");

   function Is_Int (A : Integer)   return Boolean is (True);
   function Is_String (A : String) return Boolean is (True);

   function Array_Values (Arry : Array_Type)
                          return List_Type
                          is (Empty_List);

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

   type Flag_Type is (Ent_Quotes, Ent_Substitute, Ent_Html404);
   -- Shold be or'ed together instead

   function Html_Entity_Decode (Item     : String;
                                Flags    : Flag_Type;
                                Encoding : String := "")
                                return String
                                is ("XXX-312");

   function Htmlentities (Item          : String;
                          Flags         : Flag_Type := Ent_Quotes;
                          Encoding      : String  := "";
                          Double_Encode : Boolean := True)
                          return String
                          is ("XXX-462");

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
                        Value : String_Array) -- Integer)
                        return Integer
                        is (1);

   function Is_Numeric (Value : String)
                        return Boolean
                        is (False);

   function Is_File (Filename : String)
                     return Boolean
                     is (False);

end Php;
