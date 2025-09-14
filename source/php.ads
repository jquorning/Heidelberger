with Arrays;
with Inc_Class_Posts;

package Php
is
   use Arrays;

   function Get_Object_Vars (Arry : Array_Type) return Array_Type;
   function Get_Object_Vars (Object : Inc_Class_Posts.Wp_Post)
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

   function Is_Object (Post : Inc_Class_Posts.Wp_Post) return Boolean is (True);
   function Is_Object (Arry : Array_Type) return Boolean is (False);
   function Is_Array  (Arry : Array_Type) return Boolean is (True);

   function Array_Merge (Left, Right : Array_Type) return Array_Type
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
                      Strict   : Boolean)
                      return Boolean is (True);
   function In_Array (Needle   : String;
                      Haystack : List_Type;
                      Strict   : Boolean)
                      return Boolean is (False);
   function Ltrim (Item : String; Xx : String) return String is (Item);

   function Explode (Item  : String;
                     Table : Array_Type)
                     return Array_Type
                     is (Empty_Array);

   function Explode (Item : String;
                     List : List_Type)
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

   procedure Array_Unshift (Arry : in out Array_Type;
                            S    : String) is null;

   function Urlencode (Item : String) return String is ("XXX-301");

   function Is_Int (A : Integer)   return Boolean is (True);
   function Is_String (A : String) return Boolean is (True);

end Php;
