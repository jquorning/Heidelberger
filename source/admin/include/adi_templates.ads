
with Ada.Containers.Vectors;

with Arrays;

with Hb_Common;

with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Posts;

package Adi_Templates
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

   --
   -- Echoes a submit button, with provided text and appropriate class(es).
   --
   -- @since 3.1.0
   --
   -- @see get_submit_button()
   --
   -- @param string       text             The text of the button (defaults to "Save Changes")
   -- @param string       type             Optional. The type and CSS class(es) of the button. Core values
   --                                       include "primary", "small", and "large". Default "primary".
   -- @param string       name             The HTML name of the submit button. Defaults to "submit". If no
   --                                       id attribute is given in other_attributes below, name will be
   --                                       used as the Button's id.
   -- @param bool         wrap             True if the output button should be wrapped in a paragraph tag,
   --                                       false otherwise. Defaults to true.
   -- @param array|string other_attributes Other attributes that should be output with the button, mapping
   --                                       attributes to their values, such as setting tabindex to 1, etc.
   --                                       These key/value attribute pairs will be output as attribute="value",
   --                                       where attribute is the key. Other attributes can also be provided
   --                                       as a string such as "tabindex="1"", though the array format is
   --                                       preferred. Default null.
   --
   procedure Submit_Button (Text             : String     := ""; -- null;
                            Typ              : String     := "primary";
                            Name             : String     := "submit";
                            Wrap             : Boolean    := True;
                            Other_Attributes : Array_Type := Empty_Array);

   --
   -- Returns a submit button, with provided text and appropriate class.
   --
   -- @since 3.1.0
   --
   -- @param string       text             Optional. The text of the button. Default "Save Changes".
   -- @param string       type             Optional. The type and CSS class(es) of the button. Core values
   --                                       include "primary", "small", and "large". Default "primary large".
   -- @param string       name             Optional. The HTML name of the submit button. Defaults to "submit".
   --                                       If no id attribute is given in other_attributes below, `name` will
   --                                       be used as the Button's id. Default "submit".
   -- @param bool         wrap             Optional. True if the output button should be wrapped in a paragraph
   --                                       tag, false otherwise. Default true.
   -- @param array|string other_attributes Optional. Other attributes that should be output with the button,
   --                                       mapping attributes to their values, such as `array ("tabindex" => "1")`.
   --                                       These attributes will be output as `attribute="value"`, such as
   --                                       `tabindex="1"`. Other attributes can also be provided as a string such
   --                                       as `tabindex="1"`, though the array format is typically cleaner.
   --                                       Default empty.
   -- @return string Submit button HTML.
   --
   function Get_Submit_Button (Text             : String     := "";
                               Typ              : String     := "primary large";
                               Name             : String     := "submit";
                               Wrap             : Boolean    := True;
                               Other_Attributes : Array_Type := Empty_Array)
                               return String;

end Adi_Templates;
