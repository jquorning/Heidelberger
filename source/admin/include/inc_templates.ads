
with Ada.Containers.Vectors;

with Arrays;

with Hb_Common;

with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Posts;

package INC_Templates
is
   use Hb_Common;
   use Arrays;

--
-- Category Checklists.
--

--
-- Outputs an unordered list of checkbox input elements labeled with category names.
--
-- @since 2.5.1
--
-- @see wp_terms_checklist()
--
-- @param int         $post_id              Optional. Post to generate a categories checklist for. Default 0.
--                                          $selected_cats must not be an array. Default 0.
-- @param int         $descendants_and_self Optional. ID of the category to output along with its descendants.
--                                          Default 0.
-- @param int[]|false $selected_cats        Optional. Array of category IDs to mark as checked. Default false.
-- @param int[]|false $popular_cats         Optional. Array of category IDs to receive the "popular-category" class.
--                                          Default false.
-- @param Walker      $walker               Optional. Walker object to use to build the output.
--                                          Default is a Walker_Category_Checklist instance.
-- @param bool        $checked_ontop        Optional. Whether to move checked items out of the hierarchy and to
--                                          the top of the list. Default true.
--
   procedure Wp_Category_Checklist (Post_Id              : Integer     := 0;
                                    Descendants_And_Self : Integer     := 0;
                                    Selected_Cats        : Array_Type  := Empty_Array;
                                    Popular_Cats         : Array_type  := Empty_Array;
                                    Walker               : Walker_Type := null;
                                    Checked_Ontop        : Boolean     := True);

--
-- Outputs an unordered list of checkbox input elements labelled with term names.
--
-- Taxonomy-independent version of wp_category_checklist().
--
-- @since 3.0.0
-- @since 4.4.0 Introduced the `echo` argument.
--
-- @param int          post_id Optional. Post ID. Default 0.
-- @param array|string args then
--     Optional. Array or string of arguments for generating a terms checklist. Default empty array.
--
--     @type int    descendants_and_self ID of the category to output along with its descendants.
--                                        Default 0.
--     @type int[]  selected_cats        Array of category IDs to mark as checked. Default false.
--     @type int[]  popular_cats         Array of category IDs to receive the "popular-category" class.
--                                        Default false.
--     @type Walker walker               Walker object to use to build the output. Default empty which
--                                        results in a Walker_Category_Checklist instance being used.
--     @type string taxonomy             Taxonomy to generate the checklist for. Default "category".
--     @type bool   checked_ontop        Whether to move checked items out of the hierarchy and to
--                                        the top of the list. Default true.
--     @type bool   echo                 Whether to echo the generated markup. False to return the markup instead
--                                        of echoing it. Default true.
-- end;
-- @return string HTML list of input elements.
--
   function Wp_Terms_Checklist (Post_Id : Integer := 0;
                                Args    : Array_Type) return String;



   function Get_Media_States (Post : Inc_Class_Wp_Posts.Wp_Post) return List_Type;

   -- package Term_Arrays is new
   --    Ada.Containers.Vectors (Index_Type   => Positive,
   --                            Element_Type => Inc_Class_Wp_Terms.Wp_Term,
   --                            "="          => Inc_Class_Wp_Terms."=");

   -- subtype Wp_Term_Array is Term_Arrays.Vector;

   -- Empty_Term_Array : constant Wp_Term_Array := Term_Arrays.Empty_Vector;

end INC_Templates;
