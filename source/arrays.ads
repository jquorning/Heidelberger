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

   subtype List_Type  is List_Vectors.Vector;
   Empty_List  : List_Type  renames List_Vectors.Empty_Vector;

   type Array_Kind is (Is_String, Is_Integer, Is_Array, Is_Boolean);
   type Array_Type;
   type Array_Access is access all Array_Type;

   type Array_Record is
      record
         Kind : Array_Kind;
         Str  : Unbounded_String;
         Int  : Integer;
         Arry : Array_Access;
         Bool : Boolean;
      end record;

   package Array_Maps is
      new Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                                  Element_Type => Array_Record);

   type Array_Type is new Array_Maps.Map with null record;

   procedure Include (Arry     : in out Array_Type;
                      Key      : String;
                      New_Item : String);

   function Build (Key   : String;
                   Value : Array_Type)
                   return Array_Type;

   type Array_List is array (Positive range <>) of Array_Type;

   function To_Array (List : Array_List)
            return Array_Type;

   function Exists (Arry : Array_Type;
                    Key  : String)
                    return Boolean
                    is (True);

   function Count (Arry : Array_Type)
                   return Natural
                   is (1);

   function Build (Key   : String;
                   Value : String)
                   return Array_Type;

   function Build (Key   : String;
                   Value : Integer)
                   return Array_Type;

   function Build (Key   : String;
                   Value : Boolean)
                   return Array_Type;

   Empty_Array : Array_Type := (Array_Maps.Empty_Map with null record);

   type Item_List is array (Positive range <>) of Item_Type;

   function To_List (List : Item_List)
                     return List_Type;

   function To_List (Item : String)
                     return List_Type;

   package String_Vectors is
      new Ada.Containers.Indefinite_Vectors (Index_Type   => Positive,
                                             Element_Type => String);

   subtype String_Array is String_Vectors.Vector;
   Empty_String_Array : constant String_Array := String_Vectors.Empty_Vector;

end Arrays;
