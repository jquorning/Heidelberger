--
--
--

with Ada.Containers.Vectors;

package Integer_Vectors
is

   package Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Integer);

   subtype Integer_Array is Vectors.Vector;

   Empty_Integer_Array : constant Integer_Array := Vectors.Empty_Vector;

end Integer_Vectors;
