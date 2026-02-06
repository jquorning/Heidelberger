--
--
--

with Ada.Containers.Vectors;

with Arrays;

package Array_Lists
is
   use Arrays;

   package Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Array_Type);

   subtype Array_List is Vectors.Vector;

   Empty_Array_List : constant Array_List := Vectors.Empty_Vector;

   --
   --
   --
   function To_Array_Type (List : Array_List)
                           return Array_Type;

end Array_Lists;
