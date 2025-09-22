--
-- Taxonomy API: Core category-specific functionality
--
-- @package WordPress
-- @subpackage Taxonomy
--

package Inc_Categories
is
   procedure Dummy;

   --
   -- Retrieves the name of a category from its ID.
   --
   -- @since 1.0.0
   --
   -- @param int cat_id Category ID.
   -- @return string Category name, or an empty string if the category doesn"t exist.
   --
   function Get_Cat_Name (Cat_Id : Integer)
                          return String
                          is ("XXX-448");

end Inc_Categories;
