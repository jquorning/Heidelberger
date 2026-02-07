--
-- Taxonomy API: Walker_CategoryDropdown class
--
-- @package WordPress
-- @subpackage Template
-- @since 4.4.0
--

with Class_Walker;

package Class_Walker_Category_Dropdown
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
--       Tree_Type : UString := To_UString ("category");

         --
         -- Database fields to use.
         --
         -- @since 2.1.0
         -- @todo Decouple this
         -- @var string[]
         --
         -- @see Walker::$db_fields
         --
--       DB_Fields : Array_Type := To_Array_Type ([
--           Build ("parent", "parent"),
--           Build ("id",     "term_id")
--       ]);
         null;
      end record;

   -- By jq
   function X_Construct
            return Walker_CategoryDropdown;

end Class_Walker_Category_Dropdown;
