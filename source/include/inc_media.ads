--
-- WordPress API for media display.
--
-- @package WordPress
-- @subpackage Media
--

with Arrays;

with Inc_Class_Wp_Taxonomy;
with Inc_Taxonomys;

package Inc_Media
is
   use Arrays;

   --
   -- Retrieves additional image sizes.
   --
   -- @since 4.7.0
   --
   -- @global array _wp_additional_image_sizes
   --
   -- @return array Additional images size data.
   --
   function Wp_Get_Additional_Image_Sizes
            return Array_Type;

   --
   -- Retrieves all of the taxonomies that are registered for attachments.
   --
   -- Handles mime-type-specific taxonomies such as attachment:image and
   -- attachment:video.
   --
   -- @since 3.5.0
   --
   -- @see get_taxonomies()
   --
   -- @param string output Optional. The type of taxonomy output to return. Accepts
   --                       "names" or "objects". Default "names".
   -- @return string[]|WP_Taxonomy[] Array of names or objects of registered
   --                                taxonomies for attachments.
   --
   type Wp_Taxonomy_Array is array (Positive range <>)
     of Inc_Class_Wp_Taxonomy.Wp_Taxonomy;

   Empty_Taxonomy_Array : constant Wp_Taxonomy_Array := (1 .. 0 => <>);

   function Get_Taxonomies_For_Attachments (Output : String := "names")
                                            return Wp_Taxonomy_Array
                                            is (Empty_Taxonomy_Array);

   --
   -- Determines whether to add the `loading` attribute to the specified tag in the
   -- specified context.
   --
   -- @since 5.5.0
   -- @since 5.7.0 Now returns `true` by default for `iframe` tags.
   --
   -- @param string tag_name The tag name.
   -- @param string context  Additional context, like the current filter name
   --                         or the function name from where this was called.
   -- @return bool Whether to add the attribute.
   --
   function Wp_Lazy_Loading_Enabled (Tag_Name : String;
                                     Context  : String)
                                     return Boolean
                                     is (True);

   --
   -- Determines the maximum upload size allowed in php.ini.
   --
   -- @since 2.5.0
   --
   -- @return int Allowed upload size.
   --
   function Wp_Max_Upload_Size
            return Natural;

   --
   -- Gets the available intermediate image size names.
   --
   -- @since 3.0.0
   --
   -- @return string[] An array of image size names.
   --
   function Get_Intermediate_Image_Sizes
            return List_Type;

   --
   -- Returns a normalized list of all currently registered image sub-sizes.
   --
   -- @since 5.3.0
   -- @uses wp_get_additional_image_sizes()
   -- @uses get_intermediate_image_sizes()
   --
   -- @return array[] Associative array of arrays of image sub-size information,
   --                 keyed by image size name.
   --
   function Wp_Get_Registered_Image_Subsizes
            return Array_Type;

end Inc_Media;
