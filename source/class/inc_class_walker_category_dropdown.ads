--
-- Taxonomy API: Walker_CategoryDropdown class
--
-- @package WordPress
-- @subpackage Template
-- @since 4.4.0
--

with Class_Walker;

package Inc_Class_Walker_Category_Dropdown
is

   --
   -- Core class used to create an HTML dropdown list of Categories.
   --
   -- @since 2.1.0
   --
   -- @see Walker
   --
   type Walker_CategoryDropdown is new Class_Walker.Walker with
      record
         --
         -- What the class handles.
         --
         -- @since 2.1.0
         -- @var string
         --
         -- @see Walker::$tree_type
         --
--       Tree_Type : Unbounded_String := To_Unbounded_String ("category");

         --
         -- Database fields to use.
         --
         -- @since 2.1.0
         -- @todo Decouple this
         -- @var string[]
         --
         -- @see Walker::$db_fields
         --
--       DB_Fields : Array_Type := To_Array ((
--           Build ("parent", "parent"),
--           Build ("id",     "term_id")
--       ));
         null;
      end record;

   -- By jq
   function X_Construct
            return Walker_CategoryDropdown;

end Inc_Class_Walker_Category_Dropdown;
