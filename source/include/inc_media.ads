--
-- WordPress API for media display.
--
-- @package WordPress
-- @subpackage Media
--

with Arrays;
with Lists;
with UStrings;

with Class_Taxonomy;

package Inc_Media
is
   use Arrays;
   use Lists;

   type Image_Src_Type is
     record
        Source  : UStrings.UString;
        Width   : Integer;
        Height  : Integer;
        Resized : Boolean;
     end record;

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
   -- Scales an image to fit a particular size (such as "thumb" or "medium").
   --
   -- The URL might be the original image, or it might be a resized version. This
   -- function won"t create a new resized copy, it will just return an already
   -- resized one if it exists.
   --
   -- A plugin may use the {@see "image_downsize"} filter to hook into and offer image
   -- resizing services for images. The hook must return an array with the same
   -- elements that are normally returned from the function.
   --
   -- @since 2.5.0
   --
   -- @param int          id   Attachment ID for image.
   -- @param string|int[] size Optional. Image size. Accepts any registered image
   --                          size name, or an array of width and height values in
   --                          pixels (in that order). Default "medium".
   -- @return array|false {
   --     Array of image data, or boolean false if no image is available.
   --
   --     @type string 0 Image source URL.
   --     @type int    1 Image width in pixels.
   --     @type int    2 Image height in pixels.
   --     @type bool   3 Whether the image is a resized image.
   -- }
   --
   function Image_Downsize (Id   : Integer;
                            Size : String := "medium")
                            return Image_Src_Type
   is (Source  => UStrings.Null_UString,
       Width   => 0,
       Height  => 0,
       Resized => False);

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
     of Class_Taxonomy.Wp_Taxonomy;

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

   --
   -- Retrieves an image to represent an attachment.
   --
   -- @since 2.5.0
   --
   -- @param int          attachment_id Image attachment ID.
   -- @param string|int[] size          Optional. Image size. Accepts any registered
   --                                   image size name, or an array of width and
   --                                   height values in pixels (in that order).
   --                                   Default "thumbnail".
   -- @param bool         icon          Optional. Whether the image should fall back
   --                                   to a mime type icon. Default false.
   -- @return array|false {
   --     Array of image data, or boolean false if no image is available.
   --
   --     @type string 0 Image source URL.
   --     @type int    1 Image width in pixels.
   --     @type int    2 Image height in pixels.
   --     @type bool   3 Whether the image is a resized image.
   -- }
   --

   function Wp_Get_Attachment_Image_Src
              (Attachment_Id : Integer;
               Size          : String  := "thumbnail";
               Icon          : Boolean := False)
               return Image_Src_Type;

   --
   -- Gets the URL of an image attachment.
   --
   -- @since 4.4.0
   --
   -- @param int          attachment_id Image attachment ID.
   -- @param string|int[] size          Optional. Image size. Accepts any registered
   --                                   image size name, or an array of width and
   --                                   height values in pixels (in that order).
   --                                   Default "thumbnail".
   -- @param bool         icon          Optional. Whether the image should be treated
   --                                   as an icon. Default false.
   -- @return string|false Attachment URL or false if no image is available. If `size`
   --                      does not match any registered image size, the original
   --                      image URL will be returned.
   --
   function Wp_Get_Attachment_Image_URL
              (Attachment_Id : Integer;
               Size          : String  := "thumbnail";
               Icon          : Boolean := False)
               return String;

   --
   -- Gets the default value to use for a `loading` attribute on an element.
   --
   -- This function should only be called for a tag and context if lazy-loading is
   -- generally enabled.
   --
   -- The function usually returns "lazy", but uses certain heuristics to guess
   -- whether the current element is likely to appear above the fold, in which case
   -- it returns a boolean `false`, which will lead to the `loading` attribute being
   -- omitted on the element. The purpose of this refinement is to avoid lazy-loading
   -- elements that are within the initial viewport, which can have a negative
   -- performance impact.
   --
   -- Under the hood, the function uses {@see wp_increase_content_media_count()}
   -- every time it is called for an element within the main content. If the element
   -- is the very first content element, the `loading` attribute will be omitted. This
   -- default threshold of 1 content element to omit the `loading` attribute for can
   -- be customized using the {@see "wp_omit_loading_attr_threshold"} filter.
   --
   -- @since 5.9.0
   --
   -- @param string context Context for the element for which the `loading` attribute
   --                       value is requested.
   -- @return string|bool The default `loading` attribute value. Either "lazy",
   --                     "eager", or a boolean `false`, to indicate that the
   --                     `loading` attribute should be skipped.
   --
   function Wp_Get_Loading_Attr_Default (Context : String)
                                         return String;

   --
   -- Gets the threshold for how many of the first content media elements to not
   -- lazy-load.
   --
   -- This function runs the {@see "wp_omit_loading_attr_threshold"} filter, which
   -- uses a default threshold value of 1. The filter is only run once per page load,
   -- unless the `force` parameter is used.
   --
   -- @since 5.9.0
   --
   -- @param bool force Optional. If set to true, the filter will be (re-)applied
   --                   even if it already has been before. Default false.
   -- @return int The number of content media elements to not lazy-load.
   --
   function Wp_Omit_Loading_Attr_Threshold (Force : Boolean := False)
                                            return Integer;

   --
   -- Increases an internal content media count variable.
   --
   -- @since 5.9.0
   -- @access private
   --
   -- @param int amount Optional. Amount to increase by. Default 1.
   -- @return int The latest content media count, after the increase.
   --
   function Wp_Increase_Content_Media_Count (Amount : Integer := 1)
                                             return Integer;

   --
   -- Allows PHP's getimagesize() to be debuggable when necessary.
   --
   -- @since 5.7.0
   -- @since 5.8.0 Added support for WebP images.
   --
   -- @param string filename   The file path.
   -- @param array  image_info Optional. Extended image information (passed by
   --                          reference).
   -- @return array|false Array of image information or false on failure.
   --
   function Wp_Getimagesize (Filename   : String;
                             Image_Info : out Array_Type) -- null
                             return List_Type
                             is (Empty_List);

   function Wp_Getimagesize (Filename : String)
                             return List_Type;

end Inc_Media;
