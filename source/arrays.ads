with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Arrays
is
   use Ada.Strings.Unbounded;

   package Integer_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Integer);
   subtype Integer_Array is Integer_Vectors.Vector;
   Empty_Integer_Array : constant Integer_Array := Integer_Vectors.Empty_Vector;

   subtype Key_Type   is Unbounded_String;
   subtype Value_Type is Unbounded_String;
   subtype Item_Type  is Unbounded_String;

   type Assoc_Type is
      record
         Key   : Key_Type;
         Value : Value_Type;
      end record;

   package List_Vectors is
      new Ada.Containers.Vectors (Index_Type   => Positive,
                                  Element_Type => Item_Type);

   -- package Array_Vectors is
   --    new Ada.Containers.Vectors (Index_Type   => Positive,
   --                                Element_Type => Assoc_Type);

   package Array_Maps is
      new Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                                  Element_Type => String);
   package Array_Vectors renames Array_Maps;

   subtype List_Type  is List_Vectors.Vector;
   subtype Array_Type is Array_Maps.Map;
-- subtype Array_Type is Array_Vectors.Vector;

   Empty_List  : List_Type  renames List_Vectors.Empty_Vector;
   Empty_Array : Array_Type renames Array_Maps.Empty_Map;
-- Empty_Array : Array_Type renames Array_Vectors.Empty_Vector;

   function Build (Key : String; Value : String)     return Assoc_Type;
   function Build (Key : String; Value : Integer)    return Assoc_Type;
   function Build (Key : String; Value : Boolean)    return Assoc_Type
   is (Build (Key, Boolean'Image (Value)));

   function Build (Key : String; Value : Array_Type) return Assoc_Type;

   type Assoc_List is array (Positive range <>) of Assoc_Type;
   function To_Array (List : Assoc_List) return Array_Type
      is (Empty_Array);

   function Exists (Arry : Array_Type; Key : String) return Boolean is (True);
--   function Array_Keys (Arry : Array_Type) return List_Type is (Empty_List);
   function Count (Arry : Array_Type) return Natural is (1);

   type Item_List is array (Positive range <>) of Item_Type;

   function To_List (List : Item_List)
                     return List_Type
                     is (Empty_List);

   function To_List (Item : String)
                     return List_Type
                     is (Empty_List);

   package String_Vectors is
      new Ada.Containers.Indefinite_Vectors (Index_Type   => Positive,
                                             Element_Type => String);

   subtype String_Array is String_Vectors.Vector;
   Empty_String_Array : constant String_Array := String_Vectors.Empty_Vector;

end Arrays;
