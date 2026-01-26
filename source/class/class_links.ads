--
-- This was added by jq to handle links table.
--

with Ada.Containers.Vectors;

with UStrings;

package Class_Links
is

   type Wp_Links is tagged
     record
        Link_Id          : Integer;
        Link_Name        : UStrings.UString;
        Link_Description : UStrings.UString;
     end record;

   package Links_Vectors is new
     Ada.Containers.Vectors (Index_Type   => Positive,
                             Element_Type => Wp_Links);

   subtype Links_List is Links_Vectors.Vector;

   Empty_Links_List : constant Links_List :=
     Links_Vectors.Empty_Vector;

end Class_Links;
