
with Ada.Characters.Latin_1;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Arrays;

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

   function Array_Filter (List : List_Type) return List_Type is (Empty_List);

   function Count (Item : String)
                   return Natural
                   is (7);

   function Get (List : List_Type;
                 Key  : String)
                 return String
                 is ("XXX-220");

   function Get (A   : String;
                 Key : String)
                 return String
                 is ("XXX-251");

   function Empty (A : String)
                   return Boolean
                   is (A'Length = 0);

   function Empty (Table : Array_Type) return Boolean;

   procedure Unset (A : String) is null;

   procedure Unset (A : Multi_Type) is null;

   type Walker_Type is access procedure;

   function Isset (Item : Array_Type) return Boolean;
   function Isset (Item : String) return Boolean;

   function X_Isset (Arry : Array_Type; Value : String) return Boolean is (True);

   function Isset (Arry : List_Type;
                   Key  : String)
                   return Boolean
                   is (True);

   function Isset (Arry : Array_Type;
                   Key  : Integer)
                   return Boolean
                   is (True);

   package String_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => String);

end Hb_Common;
