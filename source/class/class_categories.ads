--
-- This was added by jq to handle obsolete categories table.
--

with Ada.Containers.Vectors;

with UStrings;

package Class_Categories
is

   type Wp_Categories is tagged
     record
        Cat_Id            : Integer;
        Cat_Name          : UStrings.UString;
        Category_Nicename : UStrings.UString;
     end record;

   package Categories_Vectors is new
     Ada.Containers.Vectors (Index_Type   => Positive,
                             Element_Type => Wp_Categories);

   subtype Categories_List is Categories_Vectors.Vector;

   Empty_Categories_List : constant Categories_List :=
     Categories_Vectors.Empty_Vector;

end Class_Categories;
