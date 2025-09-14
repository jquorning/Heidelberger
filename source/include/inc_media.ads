
--
-- WordPress API for media display.
--
-- @package WordPress
-- @subpackage Media
--

with Inc_Class_Wp_Taxonomy;
with Inc_Taxonomys;

package Inc_Media
is
   procedure Dummy;
--
-- Retrieves all of the taxonomies that are registered for attachments.
--
-- Handles mime-type-specific taxonomies such as attachment:image and attachment:video.
--
-- @since 3.5.0
--
-- @see get_taxonomies()
--
-- @param string output Optional. The type of taxonomy output to return. Accepts "names" or "objects".
--                       Default "names".
-- @return string[]|WP_Taxonomy[] Array of names or objects of registered taxonomies for attachments.
--
   type Wp_Taxonomy_Array is array (Positive range <>)
     of Inc_Class_Wp_Taxonomy.Wp_Taxonomy;

   Empty_Taxonomy_Array : constant Wp_Taxonomy_Array := (1 .. 0 => <>);

   function Get_Taxonomies_For_Attachments (Output : String := "names")
                                            return Wp_Taxonomy_Array
                                            is (Empty_Taxonomy_Array);

end Inc_Media;
