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

end Array_Vectors;
