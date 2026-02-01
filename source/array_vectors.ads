--
--
--

with Ada.Containers.Vectors;

with Arrays;

package Array_Vectors
is
   use Arrays;

   package Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Array_Type);

   subtype Array_Vector is Vectors.Vector;

   Empty_Vector : constant Array_Vector := Vectors.Empty_Vector;

end Array_Vectors;
