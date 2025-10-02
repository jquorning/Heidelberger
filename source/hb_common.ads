
with Ada.Characters.Latin_1;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wpdb;

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

-- function To_Array (Item : String) return Array_Type;
   function To_Array (Db : Inc_Class_Wpdb.Wpdb_Class;
                      S  : String)
                      return Array_Type is (Empty_Array);

   function Array_Filter (List : Array_Type) return Assoc_List;
   function Array_Filter (List : Array_Type) return Array_Type is (Empty_Array);
   function Array_Filter (List : List_Type) return List_Type is (Empty_List);

   procedure Set (Arr   : in out Array_Type;
                  Key   : String;
                  Value : String);

   procedure Set (Arr : in out Array_Type; Key : String; Value : Array_Type)
     is null;
   procedure Set_Integer (Arr   : in out Array_Type;
                          Key   : String;
                          Value : Integer)
                          is null;

   function Count (Item : String)
                   return Natural
                   is (7);

   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "")
                 return String;

   function Get_Array (Arr : Array_Type; Key : String) -- ; Arg_2 : String := "")
                       return Array_Type
                       is (Empty_Array);

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

   function Is_Wp_Error (Ret : Boolean) return Boolean is (True);

   function Empty (A : String) return Boolean is (True);
   function Empty (Table : Array_Type) return Boolean;
   function Empty (Arry : Array_Type; Key : String) return Boolean is (False);

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
