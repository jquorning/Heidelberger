--
--
--

with Ada.Containers.Indefinite_Vectors;

package Lists is

   subtype Item_Type is String; -- UStrings.UString;

   package List_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Index_Type   => Positive,
        Element_Type => Item_Type,
        "="          => Standard."=");

   -- package List_Vectors is
   --    new Ada.Containers.Vectors (Index_Type   => Positive,
   --                                Element_Type => Item_Type,
   --                                "="          => UStrings."=");

   subtype List_Type is List_Vectors.Vector;

   procedure Append (List : in out List_Type;
                     Item : String);
   -- Append Item to List.

   -- procedure Append (List : in out List_Type;
   --                   Item : UStrings.UString);
   -- -- Append Item to List.

   Empty_List : List_Type renames List_Vectors.Empty_Vector;

-- type Item_List is array (Positive range <>)
--   of UStrings.UString; -- Lists.Item_Type;

-- function To_List (List : Item_List)
--                   return Lists.List_Type;

   function To_List (Item : String)
                     return Lists.List_Type;

end Lists;
