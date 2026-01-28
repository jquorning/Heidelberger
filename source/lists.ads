--
--
--

with Ada.Containers.Indefinite_Vectors;

package Lists is

   subtype Item_Type is String;

   package List_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Index_Type   => Positive,
        Element_Type => Item_Type,
        "="          => Standard."=");

   subtype List_Type is List_Vectors.Vector;

   procedure Append (List : in out List_Type;
                     Item : String);
   -- Append Item to List.

end Lists;
