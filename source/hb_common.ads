
with Ada.Characters.Latin_1;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wpdb;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;
with Inc_Class_Wp_Terms;
with Inc_Taxonomys;

package Hb_Common
is
   use Ada.Strings.Unbounded;
   use Arrays;

   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   function "-" (Item : Unbounded_String) return String
      renames To_String;

   NL     : constant String := "" & Ada.Characters.Latin_1.LF;
   TAB    : constant String := "" & Ada.Characters.Latin_1.HT;
   NL_TAB : constant String := NL & TAB;

   function To_Array (Item : String) return Array_Type;
   function To_Array (Db : Inc_Class_Wpdb.Wpdb_Class;
                      S  : String)
                      return Array_Type is (Empty_Array);

   function Array_Filter (List : Array_Type) return Assoc_List;
   function Array_Filter (List : Array_Type) return Array_Type is (Empty_Array);
   function Array_Filter (List : List_Type) return List_Type is (Empty_List);

   procedure Set (Arr : in out Array_Type; Key : String; Value : String);
   procedure Set (Arr : in out Array_Type; Key : String; Value : Array_Type)
     is null;
   procedure Set_Integer (Arr   : in out Array_Type;
                          Key   : String;
                          Value : Integer)
                          is null;

   function Count (Item : String) return String;

   function Apply_Filters (Item : String;
                           S : String;
                           D : String;
                           X : Assoc_List)
                           return String
                           is ("XXX-220");

   function Apply_Filters (Item : String;
                           S    : String;
                           D    : String := "";
                           X    : String := "")
                           return String;

   function Apply_Filters (Item : String;
                           S    : Assoc_List;
                           D    : Assoc_List)
                           return Assoc_List;

   function Apply_Filters (Hook_Name : String;
                           A         : Array_Type;
                           B         : Array_Type)
                           return Array_Type
                           is (Empty_Array);

   function Apply_Filters (Item : String;
                           A    : Array_Type;
                           V    : String;
                           N    : String)
                           return Array_Type;

   function Apply_Filters (Item  : String;
                           Left  : Array_Type;
                           Right : Integer)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           Value     : Inc_Class_Wp_Terms.Wp_Term_Array;
                           Id        : String;
                           Taxonomy  : String)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);

   function Apply_Filters (Hook_Name : String;
                           Value     : access Integer;
                           Arg_2     : Positive;
                           Arg_3     : String;
                           Arg_4     : Boolean;
                           Arg_5     : String)
                           return Integer is (1);

   function Apply_Filters (Hook_Name : String;
                           Arg_2     : Array_Type;
                           Arg_3     : Array_Type;
                           Arg_4     : Array_Type)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           A1 : Inc_Class_Wp_Terms.Wp_Term_Array;
                           A2 : String;
                           A3 : String;
                           A4 : Array_Type)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);

   function Apply_Filters (Hook_Name : String;
                           S         : String;
                           D         : String;
                           P         : Array_Type)
                           return String
                           is ("XXX-221");

   function Apply_Filters (Hook_Name : String;
                           S         : String;
                           D         : String;
                           P         : List_Type)
                           return String
                           is ("XXX-230");

   function Apply_Filters (Hook_Name : String;
                           List      : List_Type)
                           return List_Type
                           is (Empty_List);

   function Apply_Filters (Hook_Name : String;
                           Arg       : Boolean)
                           return Boolean
                           is (True);

   function Printf (Format : String;
                    Arg_1  : String;
                    Arg_2  : String := "";
                    Arg_3  : String := "";
                    Arg_4  : String := "")
                    return String
                    is (Format & " XXX-310 " & Arg_1);

   function Sprintf (Format : String;
                     Arg_1 : String;
                     Arg_2 : String := "";
                     Arg_3 : String := "")
      return String is (Format & "XXX-201");

   function Count (Al : Assoc_List) return Natural;

   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "") return String;
   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "")
                 return Array_Type;

   function Get_2 (Arry : Array_Type; Key_1, Key_2 : String)
                  return String is ("XXX-303");

   function Get_List (Arry : Array_Type; Key : String)
                      return List_Type
                      is (Empty_List);

   function Get (List : List_Type;
                 Key  : String)
                 return String
                 is ("XXX-220");

   function Get_Integer (Arry : Array_Type;
                         Key  : String)
                         return Integer
                         is (1);

   function Get (A   : String;
                 Key : String)
                 return String
                 is ("XXX-251");

   function Get (Post : Inc_Class_Wp_Post_Type.Wp_Post_Type;
                 Key  : String)
                 return String is ("XXX-250");

   function Is_Wp_Error (Ret : Boolean) return Boolean is (True);

   function Wp_Is_Mobile return Boolean is (False);

   function Empty (A : String) return Boolean is (True);
   function Empty (Table : Array_Type) return Boolean;
   function Empty (Arry : Array_Type; Key : String) return Boolean is (False);

   function Apply_Filters (Item : String; S : String; D : Inc_Class_Wp_Posts.Wp_Post)
      return Boolean is (True);
   function Apply_Filters (Hook_Name : String;
                           Arg_2     : Array_Type;
                           Id        : Inc_Class_Wp_Posts.Post_Id)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           Arg_2     : Array_Type)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name  : String;
                           A1         : Inc_Class_Wp_Terms.Wp_Term_Array;
                           A2, A3, A4 : Array_Type)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);
   function Apply_Filters (Hook_Name : String;
                           A         : Boolean;
                           B         : String;
                           D         : String)
                           return String
                           is ("XXX-701");

   function Apply_Filters (Hook_Name : String;
                           A         : Boolean;
                           B         : String;
                           D         : Boolean)
                           return Boolean
                           is (False);

   procedure Unset (A : String) is null;

   type Walker_Type is access procedure;

   function In_Array (Key  : String;
                      Arry : String_Array;
                      S    : Boolean)
                      return Boolean is (True);

   function Isset (Item : Array_Type) return Boolean;
   function Isset (Item : String) return Boolean;

   function X_Isset (Arry : Array_Type; Value : String) return Boolean is (True);

   function Isset (Arry : Array_Type;
                   Key  : String)
                   return Boolean;

   function Isset (Arry : Array_Type;
                   Key  : Integer)
                   return Boolean
                   is (True);

   package String_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => String);

end Hb_Common;
