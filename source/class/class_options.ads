--
-- This was added by jq to handle options table.
--

with Ada.Containers.Vectors;

with UStrings;

package Class_Options
is

   type Wp_Options is tagged
     record
        Option_Name : UStrings.UString;

        Dupes : Natural; -- Pseudo column
     end record;

   package Options_Vectors is new
     Ada.Containers.Vectors (Index_Type   => Positive,
                             Element_Type => Wp_Options);

   subtype Options_List is Options_Vectors.Vector;

   Empty_Options_List : constant Options_List :=
     Options_Vectors.Empty_Vector;

end Class_Options;
