--
-- This was added by jq to handle obsolete post2cat table.
--

with Ada.Containers.Vectors;

package Class_Post2cat
is

   type Wp_Post2cat is tagged
     record
        Post_Id  : Integer;
     end record;

   package Post2cat_Vectors is new
     Ada.Containers.Vectors (Index_Type   => Positive,
                             Element_Type => Wp_Post2cat);

   subtype Post2cat_List is Post2cat_Vectors.Vector;

   Empty_Post2cat_List : constant Post2cat_List :=
     Post2cat_Vectors.Empty_Vector;

end Class_Post2cat;
