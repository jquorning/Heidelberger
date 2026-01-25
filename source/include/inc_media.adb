
--
-- WordPress API for media display.
--
-- @package WordPress
-- @subpackage Media
--

with Php.Arrays;
with Php.Ini;
with Php.Lists;
with Php.Strings;

with UStrings;
with Globals;
with Wp_Common;

with Inc_Formatting;
with Inc_Load;
with Inc_Options;
with Inc_Plugins;
with Inc_Posts;
with Inc_Querys;

package body Inc_Media
is

   Global_Wp_Additional_Image_Sizes : Array_Type;

   function Apply_Filters (Hook  : String;
                           Value : Natural;
                           U     : Natural;
                           P     : Natural)
                           return Natural
                           is (Value);

   -----------------------------------
   -- Wp_Get_Additional_Image_Sizes --
   -----------------------------------

   function Wp_Get_Additional_Image_Sizes
            return Array_Type
   is
   begin
      if Empty_Array = Global_Wp_Additional_Image_Sizes then
         Global_Wp_Additional_Image_Sizes := Empty_Array;
      end if;

      return Global_Wp_Additional_Image_Sizes;
   end Wp_Get_Additional_Image_Sizes;

-- --
-- -- Scales down the default size of an image.
-- --
-- -- This is so that the image is a better fit for the editor and theme.
-- --
-- -- The `size` parameter accepts either an array or a string. The supported string
-- -- values are "thumb" or "thumbnail" for the given thumbnail size or defaults at
-- -- 128 width and 96 height in pixels. Also supported for the string value is
-- -- "medium", "medium_large" and "full". The "full" isn"t actually supported, but any value other
-- -- than the supported will result in the content_width size or 500 if that is
-- -- not set.
-- --
-- -- Finally, there is a filter named {@see "editor_max_image_size"}, that will be
-- -- called on the calculated array for width and height, respectively.
-- --
-- -- @since 2.5.0
-- --
-- -- @global int content_width
-- --
-- -- @param int          width   Width of the image in pixels.
-- -- @param int          height  Height of the image in pixels.
-- -- @param string|int[] size    Optional. Image size. Accepts any registered image size name, or an array
-- --                              of width and height values in pixels (in that order). Default "medium".
-- -- @param string       context Optional. Could be "display" (like in a theme) or "edit"
-- --                              (like inserting into an editor). Default null.
-- -- @return int[] then
-- --     An array of width and height values.
-- --
-- --     @type int 0 The maximum width in pixels.
-- --     @type int 1 The maximum height in pixels.
-- -- end;
-- --
-- function image_constrain_size_for_editor( width, height, size = "medium", context = null ) then
--         global content_width;

--         _wp_additional_image_sizes = wp_get_additional_image_sizes();

--         if ( not context ) then
--                 context = is_admin() ? "edit" : "display";
--         end;

--         if ( is_array( size ) ) then
--                 max_width  = size[0];
--                 max_height = size[1];
--         end; elseif ( "thumb" === size || "thumbnail" === size ) then
--                 max_width  = (int) get_option( "thumbnail_size_w" );
--                 max_height = (int) get_option( "thumbnail_size_h" );
--                 -- Last chance thumbnail size defaults.
--                 if ( not max_width and then not max_height ) then
--                         max_width  = 128;
--                         max_height = 96;
--                 end;
--         end; elseif ( "medium" === size ) then
--                 max_width  = (int) get_option( "medium_size_w" );
--                 max_height = (int) get_option( "medium_size_h" );

--         end; elseif ( "medium_large" === size ) then
--                 max_width  = (int) get_option( "medium_large_size_w" );
--                 max_height = (int) get_option( "medium_large_size_h" );

--                 if ( (int) content_width > 0 ) then
--                         max_width = min( (int) content_width, max_width );
--                 end;
--         end; elseif ( "large" === size ) then
--                 /*
--                 -- We"re inserting a large size image into the editor. If it"s a really
--                 -- big image we"ll scale it down to fit reasonably within the editor
--                 -- itself, and within the theme"s content width if it"s known. The user
--                 -- can resize it in the editor if they wish.
--                 --
--                 max_width  = (int) get_option( "large_size_w" );
--                 max_height = (int) get_option( "large_size_h" );

--                 if ( (int) content_width > 0 ) then
--                         max_width = min( (int) content_width, max_width );
--                 end;
--         end; elseif ( not empty( _wp_additional_image_sizes ) and then in_array( size, array_keys( _wp_additional_image_sizes ), true ) ) then
--                 max_width  = (int) _wp_additional_image_sizes[ size ]["width"];
--                 max_height = (int) _wp_additional_image_sizes[ size ]["height"];
--                 -- Only in admin. Assume that theme authors know what they"re doing.
--                 if ( (int) content_width > 0 and then "edit" === context ) then
--                         max_width = min( (int) content_width, max_width );
--                 end;
--         end; else then -- size === "full" has no constraint.
--                 max_width  = width;
--                 max_height = height;
--         end;

--         --
--         -- Filters the maximum image size dimensions for the editor.
--         --
--         -- @since 2.5.0
--         --
--         -- @param int[]        max_image_size then
--         --     An array of width and height values.
--         --
--         --     @type int 0 The maximum width in pixels.
--         --     @type int 1 The maximum height in pixels.
--         -- end;
--         -- @param string|int[] size     Requested image size. Can be any registered image size name, or
--         --                               an array of width and height values in pixels (in that order).
--         -- @param string       context  The context the image is being resized for.
--         --                               Possible values are "display" (like in a theme)
--         --                               or "edit" (like inserting into an editor).
--         --
--         list( max_width, max_height ) = apply_filters( "editor_max_image_size", array( max_width, max_height ), size, context );

--         return wp_constrain_dimensions( width, height, max_width, max_height );
-- end;

-- --
-- -- Retrieves width and height attributes using given width and height values.
-- --
-- -- Both attributes are required in the sense that both parameters must have a
-- -- value, but are optional in that if you set them to false or null, then they
-- -- will not be added to the returned string.
-- --
-- -- You can set the value using a string, but it will only take numeric values.
-- -- If you wish to put "px" after the numbers, then it will be stripped out of
-- -- the return.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int|string width  Image width in pixels.
-- -- @param int|string height Image height in pixels.
-- -- @return string HTML attributes for width and, or height.
-- --
-- function image_hwstring( width, height ) then
--         out = "";
--         if ( width ) then
--                 out .= "width="" . (int) width . "" ";
--         end;
--         if ( height ) then
--                 out .= "height="" . (int) height . "" ";
--         end;
--         return out;
-- end;

   --------------------
   -- Image_Downsize --
   --------------------

-- function image_downsize( id, size = "medium" ) then
--         is_image = wp_attachment_is_image( id );

--         --
--         -- Filters whether to preempt the output of image_downsize().
--         --
--         -- Returning a truthy value from the filter will effectively short-circuit
--         -- down-sizing the image, returning that value instead.
--         --
--         -- @since 2.5.0
--         --
--         -- @param bool|array   downsize Whether to short-circuit the image downsize.
--         -- @param int          id       Attachment ID for image.
--         -- @param string|int[] size     Requested image size. Can be any registered image size name, or
--         --                               an array of width and height values in pixels (in that order).
--         --
--         out = apply_filters( "image_downsize", false, id, size );

--         if ( out ) then
--                 return out;
--         end;

--         img_url          = wp_get_attachment_url( id );
--         meta             = wp_get_attachment_metadata( id );
--         width            = 0;
--         height           = 0;
--         is_intermediate  = false;
--         img_url_basename = wp_basename( img_url );

--         -- If the file isn"t an image, attempt to replace its URL with a rendered image from its meta.
--         -- Otherwise, a non-image type could be returned.
--         if ( not is_image ) then
--                 if ( not empty( meta["sizes"]["full"] ) ) then
--                         img_url          = str_replace( img_url_basename, meta["sizes"]["full"]["file"], img_url );
--                         img_url_basename = meta["sizes"]["full"]["file"];
--                         width            = meta["sizes"]["full"]["width"];
--                         height           = meta["sizes"]["full"]["height"];
--                 end; else then
--                         return false;
--                 end;
--         end;

--         -- Try for a new style intermediate size.
--         intermediate = image_get_intermediate_size( id, size );

--         if ( intermediate ) then
--                 img_url         = str_replace( img_url_basename, intermediate["file"], img_url );
--                 width           = intermediate["width"];
--                 height          = intermediate["height"];
--                 is_intermediate = true;
--         end; elseif ( "thumbnail" === size and then not empty( meta["thumb"] ) and then is_string( meta["thumb"] ) ) then
--                 -- Fall back to the old thumbnail.
--                 imagefile = get_attached_file( id );
--                 thumbfile = str_replace( wp_basename( imagefile ), wp_basename( meta["thumb"] ), imagefile );

--                 if ( file_exists( thumbfile ) ) then
--                         info = wp_getimagesize( thumbfile );

--                         if ( info ) then
--                                 img_url         = str_replace( img_url_basename, wp_basename( thumbfile ), img_url );
--                                 width           = info[0];
--                                 height          = info[1];
--                                 is_intermediate = true;
--                         end;
--                 end;
--         end;

--         if ( not width and then not height and then isset( meta["width"], meta["height"] ) ) then
--                 -- Any other type: use the real image.
--                 width  = meta["width"];
--                 height = meta["height"];
--         end;

--         if ( img_url ) then
--                 -- We have the actual image size, but might need to further constrain it if content_width is narrower.
--                 list( width, height ) = image_constrain_size_for_editor( width, height, size );

--                 return array( img_url, width, height, is_intermediate );
--         end;

--         return false;
-- end;

-- --
-- -- Registers a new image size.
-- --
-- -- @since 2.9.0
-- --
-- -- @global array _wp_additional_image_sizes Associative array of additional image sizes.
-- --
-- -- @param string     name   Image size identifier.
-- -- @param int        width  Optional. Image width in pixels. Default 0.
-- -- @param int        height Optional. Image height in pixels. Default 0.
-- -- @param bool|array crop   Optional. Image cropping behavior. If false, the image will be scaled (default),
-- --                           If true, image will be cropped to the specified dimensions using center positions.
-- --                           If an array, the image will be cropped using the array to specify the crop location.
-- --                           Array values must be in the format: array( x_crop_position, y_crop_position ) where:
-- --                               - x_crop_position accepts: "left", "center", or "right".
-- --                               - y_crop_position accepts: "top", "center", or "bottom".
-- --
-- function add_image_size( name, width = 0, height = 0, crop = false ) then
--         global _wp_additional_image_sizes;

--         _wp_additional_image_sizes[ name ] = array(
--                 "width"  => absint( width ),
--                 "height" => absint( height ),
--                 "crop"   => crop,
--         );
-- end;

-- --
-- -- Checks if an image size exists.
-- --
-- -- @since 3.9.0
-- --
-- -- @param string name The image size to check.
-- -- @return bool True if the image size exists, false if not.
-- --
-- function has_image_size( name ) then
--         sizes = wp_get_additional_image_sizes();
--         return isset( sizes[ name ] );
-- end;

-- --
-- -- Removes a new image size.
-- --
-- -- @since 3.9.0
-- --
-- -- @global array _wp_additional_image_sizes
-- --
-- -- @param string name The image size to remove.
-- -- @return bool True if the image size was successfully removed, false on failure.
-- --
-- function remove_image_size( name ) then
--         global _wp_additional_image_sizes;

--         if ( isset( _wp_additional_image_sizes[ name ] ) ) then
--                 unset( _wp_additional_image_sizes[ name ] );
--                 return true;
--         end;

--         return false;
-- end;

-- --
-- -- Registers an image size for the post thumbnail.
-- --
-- -- @since 2.9.0
-- --
-- -- @see add_image_size() for details on cropping behavior.
-- --
-- -- @param int        width  Image width in pixels.
-- -- @param int        height Image height in pixels.
-- -- @param bool|array crop   Optional. Whether to crop images to specified width and height or resize.
-- --                           An array can specify positioning of the crop area. Default false.
-- --
-- function set_post_thumbnail_size( width = 0, height = 0, crop = false ) then
--         add_image_size( "post-thumbnail", width, height, crop );
-- end;

-- --
-- -- Gets an img tag for an image attachment, scaling it down if requested.
-- --
-- -- The {@see "get_image_tag_class"} filter allows for changing the class name for the
-- -- image without having to use regular expressions on the HTML content. The
-- -- parameters are: what WordPress will use for the class, the Attachment ID,
-- -- image align value, and the size the image should be.
-- --
-- -- The second filter, {@see "get_image_tag"}, has the HTML content, which can then be
-- -- further manipulated by a plugin to change all attribute values and even HTML
-- -- content.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int          id    Attachment ID.
-- -- @param string       alt   Image description for the alt attribute.
-- -- @param string       title Image description for the title attribute.
-- -- @param string       align Part of the class name for aligning the image.
-- -- @param string|int[] size  Optional. Image size. Accepts any registered image size name, or an array of
-- --                            width and height values in pixels (in that order). Default "medium".
-- -- @return string HTML IMG element for given image attachment?
-- --
-- function get_image_tag( id, alt, title, align, size = "medium" ) then

--         list( img_src, width, height ) = image_downsize( id, size );
--         hwstring                         = image_hwstring( width, height );

--         title = title ? "title="" . esc_attr( title ) . "" " : "";

--         size_class = is_array( size ) ? implode( "x", size ) : size;
--         class      = "align" . esc_attr( align ) . " size-" . esc_attr( size_class ) . " wp-image-" . id;

--         --
--         -- Filters the value of the attachment"s image tag class attribute.
--         --
--         -- @since 2.6.0
--         --
--         -- @param string       class CSS class name or space-separated list of classes.
--         -- @param int          id    Attachment ID.
--         -- @param string       align Part of the class name for aligning the image.
--         -- @param string|int[] size  Requested image size. Can be any registered image size name, or
--         --                            an array of width and height values in pixels (in that order).
--         --
--         class = apply_filters( "get_image_tag_class", class, id, align, size );

--         html = "<img src="" . esc_url( img_src ) . "" alt="" . esc_attr( alt ) . "" " . title . hwstring . "class="" . class . "" />";

--         --
--         -- Filters the HTML content for the image tag.
--         --
--         -- @since 2.6.0
--         --
--         -- @param string       html  HTML content for the image.
--         -- @param int          id    Attachment ID.
--         -- @param string       alt   Image description for the alt attribute.
--         -- @param string       title Image description for the title attribute.
--         -- @param string       align Part of the class name for aligning the image.
--         -- @param string|int[] size  Requested image size. Can be any registered image size name, or
--         --                            an array of width and height values in pixels (in that order).
--         --
--         return apply_filters( "get_image_tag", html, id, alt, title, align, size );
-- end;

-- --
-- -- Calculates the new dimensions for a down-sampled image.
-- --
-- -- If either width or height are empty, no constraint is applied on
-- -- that dimension.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int current_width  Current width of the image.
-- -- @param int current_height Current height of the image.
-- -- @param int max_width      Optional. Max width in pixels to constrain to. Default 0.
-- -- @param int max_height     Optional. Max height in pixels to constrain to. Default 0.
-- -- @return int[] then
-- --     An array of width and height values.
-- --
-- --     @type int 0 The width in pixels.
-- --     @type int 1 The height in pixels.
-- -- end;
-- --
-- function wp_constrain_dimensions( current_width, current_height, max_width = 0, max_height = 0 ) then
--         if ( not max_width and then not max_height ) then
--                 return array( current_width, current_height );
--         end;

--         width_ratio  = 1.0;
--         height_ratio = 1.0;
--         did_width    = false;
--         did_height   = false;

--         if ( max_width > 0 and then current_width > 0 and then current_width > max_width ) then
--                 width_ratio = max_width / current_width;
--                 did_width   = true;
--         end;

--         if ( max_height > 0 and then current_height > 0 and then current_height > max_height ) then
--                 height_ratio = max_height / current_height;
--                 did_height   = true;
--         end;

--         -- Calculate the larger/smaller ratios.
--         smaller_ratio = min( width_ratio, height_ratio );
--         larger_ratio  = max( width_ratio, height_ratio );

--         if ( (int) round( current_width-- larger_ratio ) > max_width || (int) round( current_height-- larger_ratio ) > max_height ) then
--                 -- The larger ratio is too big. It would result in an overflow.
--                 ratio = smaller_ratio;
--         end; else then
--                 -- The larger ratio fits, and is likely to be a more "snug" fit.
--                 ratio = larger_ratio;
--         end;

--         -- Very small dimensions may result in 0, 1 should be the minimum.
--         w = max( 1, (int) round( current_width-- ratio ) );
--         h = max( 1, (int) round( current_height-- ratio ) );

--         /*
--         -- Sometimes, due to rounding, we"ll end up with a result like this:
--         -- 465x700 in a 177x177 box is 117x176... a pixel short.
--         -- We also have issues with recursive calls resulting in an ever-changing result.
--         -- Constraining to the result of a constraint should yield the original result.
--         -- Thus we look for dimensions that are one pixel shy of the max value and bump them up.
--         --

--         -- Note: did_width means it is possible smaller_ratio == width_ratio.
--         if ( did_width and then w === max_width - 1 ) then
--                 w = max_width; -- Round it up.
--         end;

--         -- Note: did_height means it is possible smaller_ratio == height_ratio.
--         if ( did_height and then h === max_height - 1 ) then
--                 h = max_height; -- Round it up.
--         end;

--         --
--         -- Filters dimensions to constrain down-sampled images to.
--         --
--         -- @since 4.1.0
--         --
--         -- @param int[] dimensions     then
--         --     An array of width and height values.
--         --
--         --     @type int 0 The width in pixels.
--         --     @type int 1 The height in pixels.
--         -- end;
--         -- @param int   current_width  The current width of the image.
--         -- @param int   current_height The current height of the image.
--         -- @param int   max_width      The maximum width permitted.
--         -- @param int   max_height     The maximum height permitted.
--         --
--         return apply_filters( "wp_constrain_dimensions", array( w, h ), current_width, current_height, max_width, max_height );
-- end;

-- --
-- -- Retrieves calculated resize dimensions for use in WP_Image_Editor.
-- --
-- -- Calculates dimensions and coordinates for a resized image that fits
-- -- within a specified width and height.
-- --
-- -- Cropping behavior is dependent on the value of crop:
-- -- 1. If false (default), images will not be cropped.
-- -- 2. If an array in the form of array( x_crop_position, y_crop_position ):
-- --    - x_crop_position accepts "left" "center", or "right".
-- --    - y_crop_position accepts "top", "center", or "bottom".
-- --    Images will be cropped to the specified dimensions within the defined crop area.
-- -- 3. If true, images will be cropped to the specified dimensions using center positions.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int        orig_w Original width in pixels.
-- -- @param int        orig_h Original height in pixels.
-- -- @param int        dest_w New width in pixels.
-- -- @param int        dest_h New height in pixels.
-- -- @param bool|array crop   Optional. Whether to crop image to specified width and height or resize.
-- --                           An array can specify positioning of the crop area. Default false.
-- -- @return array|false Returned array matches parameters for `imagecopyresampled()`. False on failure.
-- --
-- function image_resize_dimensions( orig_w, orig_h, dest_w, dest_h, crop = false ) then

--         if ( orig_w <= 0 || orig_h <= 0 ) then
--                 return false;
--         end;
--         -- At least one of dest_w or dest_h must be specific.
--         if ( dest_w <= 0 and then dest_h <= 0 ) then
--                 return false;
--         end;

--         --
--         -- Filters whether to preempt calculating the image resize dimensions.
--         --
--         -- Returning a non-null value from the filter will effectively short-circuit
--         -- image_resize_dimensions(), returning that value instead.
--         --
--         -- @since 3.4.0
--         --
--         -- @param null|mixed null   Whether to preempt output of the resize dimensions.
--         -- @param int        orig_w Original width in pixels.
--         -- @param int        orig_h Original height in pixels.
--         -- @param int        dest_w New width in pixels.
--         -- @param int        dest_h New height in pixels.
--         -- @param bool|array crop   Whether to crop image to specified width and height or resize.
--         --                           An array can specify positioning of the crop area. Default false.
--         --
--         output = apply_filters( "image_resize_dimensions", null, orig_w, orig_h, dest_w, dest_h, crop );

--         if ( null not== output ) then
--                 return output;
--         end;

--         -- Stop if the destination size is larger than the original image dimensions.
--         if ( empty( dest_h ) ) then
--                 if ( orig_w < dest_w ) then
--                         return false;
--                 end;
--         end; elseif ( empty( dest_w ) ) then
--                 if ( orig_h < dest_h ) then
--                         return false;
--                 end;
--         end; else then
--                 if ( orig_w < dest_w and then orig_h < dest_h ) then
--                         return false;
--                 end;
--         end;

--         if ( crop ) then
--                 /*
--                 -- Crop the largest possible portion of the original image that we can size to dest_w x dest_h.
--                 -- Note that the requested crop dimensions are used as a maximum bounding box for the original image.
--                 -- If the original image"s width or height is less than the requested width or height
--                 -- only the greater one will be cropped.
--                 -- For example when the original image is 600x300, and the requested crop dimensions are 400x400,
--                 -- the resulting image will be 400x300.
--                 --
--                 aspect_ratio = orig_w / orig_h;
--                 new_w        = min( dest_w, orig_w );
--                 new_h        = min( dest_h, orig_h );

--                 if ( not new_w ) then
--                         new_w = (int) round( new_h-- aspect_ratio );
--                 end;

--                 if ( not new_h ) then
--                         new_h = (int) round( new_w / aspect_ratio );
--                 end;

--                 size_ratio = max( new_w / orig_w, new_h / orig_h );

--                 crop_w = round( new_w / size_ratio );
--                 crop_h = round( new_h / size_ratio );

--                 if ( not is_array( crop ) || count( crop ) not== 2 ) then
--                         crop = array( "center", "center" );
--                 end;

--                 list( x, y ) = crop;

--                 if ( "left" === x ) then
--                         s_x = 0;
--                 end; elseif ( "right" === x ) then
--                         s_x = orig_w - crop_w;
--                 end; else then
--                         s_x = floor( ( orig_w - crop_w ) / 2 );
--                 end;

--                 if ( "top" === y ) then
--                         s_y = 0;
--                 end; elseif ( "bottom" === y ) then
--                         s_y = orig_h - crop_h;
--                 end; else then
--                         s_y = floor( ( orig_h - crop_h ) / 2 );
--                 end;
--         end; else then
--                 -- Resize using dest_w x dest_h as a maximum bounding box.
--                 crop_w = orig_w;
--                 crop_h = orig_h;

--                 s_x = 0;
--                 s_y = 0;

--                 list( new_w, new_h ) = wp_constrain_dimensions( orig_w, orig_h, dest_w, dest_h );
--         end;

--         if ( wp_fuzzy_number_match( new_w, orig_w ) and then wp_fuzzy_number_match( new_h, orig_h ) ) then
--                 -- The new size has virtually the same dimensions as the original image.

--                 --
--                 -- Filters whether to proceed with making an image sub-size with identical dimensions
--                 -- with the original/source image. Differences of 1px may be due to rounding and are ignored.
--                 --
--                 -- @since 5.3.0
--                 --
--                 -- @param bool proceed The filtered value.
--                 -- @param int  orig_w  Original image width.
--                 -- @param int  orig_h  Original image height.
--                 --
--                 proceed = (bool) apply_filters( "wp_image_resize_identical_dimensions", false, orig_w, orig_h );

--                 if ( not proceed ) then
--                         return false;
--                 end;
--         end;

--         -- The return array matches the parameters to imagecopyresampled().
--         -- int dst_x, int dst_y, int src_x, int src_y, int dst_w, int dst_h, int src_w, int src_h
--         return array( 0, 0, (int) s_x, (int) s_y, (int) new_w, (int) new_h, (int) crop_w, (int) crop_h );
-- end;

-- --
-- -- Resizes an image to make a thumbnail or intermediate size.
-- --
-- -- The returned array has the file size, the image width, and image height. The
-- -- {@see "image_make_intermediate_size"} filter can be used to hook in and change the
-- -- values of the returned array. The only parameter is the resized file path.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string file   File path.
-- -- @param int    width  Image width.
-- -- @param int    height Image height.
-- -- @param bool   crop   Optional. Whether to crop image to specified width and height or resize.
-- --                       Default false.
-- -- @return array|false Metadata array on success. False if no image was created.
-- --
-- function image_make_intermediate_size( file, width, height, crop = false ) then
--         if ( width || height ) then
--                 editor = wp_get_image_editor( file );

--                 if ( is_wp_error( editor ) || is_wp_error( editor->resize( width, height, crop ) ) ) then
--                         return false;
--                 end;

--                 resized_file = editor->save();

--                 if ( not is_wp_error( resized_file ) and then resized_file ) then
--                         unset( resized_file["path"] );
--                         return resized_file;
--                 end;
--         end;
--         return false;
-- end;

-- --
-- -- Helper function to test if aspect ratios for two images match.
-- --
-- -- @since 4.6.0
-- --
-- -- @param int source_width  Width of the first image in pixels.
-- -- @param int source_height Height of the first image in pixels.
-- -- @param int target_width  Width of the second image in pixels.
-- -- @param int target_height Height of the second image in pixels.
-- -- @return bool True if aspect ratios match within 1px. False if not.
-- --
-- function wp_image_matches_ratio( source_width, source_height, target_width, target_height ) then
--         /*
--         -- To test for varying crops, we constrain the dimensions of the larger image
--         -- to the dimensions of the smaller image and see if they match.
--         --
--         if ( source_width > target_width ) then
--                 constrained_size = wp_constrain_dimensions( source_width, source_height, target_width );
--                 expected_size    = array( target_width, target_height );
--         end; else then
--                 constrained_size = wp_constrain_dimensions( target_width, target_height, source_width );
--                 expected_size    = array( source_width, source_height );
--         end;

--         -- If the image dimensions are within 1px of the expected size, we consider it a match.
--         matched = ( wp_fuzzy_number_match( constrained_size[0], expected_size[0] ) and then wp_fuzzy_number_match( constrained_size[1], expected_size[1] ) );

--         return matched;
-- end;

-- --
-- -- Retrieves the image"s intermediate size (resized) path, width, and height.
-- --
-- -- The size parameter can be an array with the width and height respectively.
-- -- If the size matches the "sizes" metadata array for width and height, then it
-- -- will be used. If there is no direct match, then the nearest image size larger
-- -- than the specified size will be used. If nothing is found, then the function
-- -- will break out and return false.
-- --
-- -- The metadata "sizes" is used for compatible sizes that can be used for the
-- -- parameter size value.
-- --
-- -- The url path will be given, when the size parameter is a string.
-- --
-- -- If you are passing an array for the size, you should consider using
-- -- add_image_size() so that a cropped version is generated. It"s much more
-- -- efficient than having to find the closest-sized image and then having the
-- -- browser scale down the image.
-- --
-- -- @since 2.5.0
-- --
-- -- @param int          post_id Attachment ID.
-- -- @param string|int[] size    Optional. Image size. Accepts any registered image size name, or an array
-- --                              of width and height values in pixels (in that order). Default "thumbnail".
-- -- @return array|false then
-- --     Array of file relative path, width, and height on success. Additionally includes absolute
-- --     path and URL if registered size is passed to `size` parameter. False on failure.
-- --
-- --     @type string file   Path of image relative to uploads directory.
-- --     @type int    width  Width of image in pixels.
-- --     @type int    height Height of image in pixels.
-- --     @type string path   Absolute filesystem path of image.
-- --     @type string url    URL of image.
-- -- end;
-- --
-- function image_get_intermediate_size( post_id, size = "thumbnail" ) then
--         imagedata = wp_get_attachment_metadata( post_id );

--         if ( not size || not is_array( imagedata ) || empty( imagedata["sizes"] ) ) then
--                 return false;
--         end;

--         data = array();

--         -- Find the best match when "size" is an array.
--         if ( is_array( size ) ) then
--                 candidates = array();

--                 if ( not isset( imagedata["file"] ) and then isset( imagedata["sizes"]["full"] ) ) then
--                         imagedata["height"] = imagedata["sizes"]["full"]["height"];
--                         imagedata["width"]  = imagedata["sizes"]["full"]["width"];
--                 end;

--                 foreach ( imagedata["sizes"] as _size => data ) then
--                         -- If there"s an exact match to an existing image size, short circuit.
--                         if ( (int) data["width"] === (int) size[0] and then (int) data["height"] === (int) size[1] ) then
--                                 candidates[ data["width"]-- data["height"] ] = data;
--                                 break;
--                         end;

--                         -- If it"s not an exact match, consider larger sizes with the same aspect ratio.
--                         if ( data["width"] >= size[0] and then data["height"] >= size[1] ) then
--                                 -- If "0" is passed to either size, we test ratios against the original file.
--                                 if ( 0 === size[0] || 0 === size[1] ) then
--                                         same_ratio = wp_image_matches_ratio( data["width"], data["height"], imagedata["width"], imagedata["height"] );
--                                 end; else then
--                                         same_ratio = wp_image_matches_ratio( data["width"], data["height"], size[0], size[1] );
--                                 end;

--                                 if ( same_ratio ) then
--                                         candidates[ data["width"]-- data["height"] ] = data;
--                                 end;
--                         end;
--                 end;

--                 if ( not empty( candidates ) ) then
--                         -- Sort the array by size if we have more than one candidate.
--                         if ( 1 < count( candidates ) ) then
--                                 ksort( candidates );
--                         end;

--                         data = array_shift( candidates );
--                         /*
--                        -- When the size requested is smaller than the thumbnail dimensions, we
--                        -- fall back to the thumbnail size to maintain backward compatibility with
--                        -- pre 4.6 versions of WordPress.
--                        --
--                 end; elseif ( not empty( imagedata["sizes"]["thumbnail"] ) and then imagedata["sizes"]["thumbnail"]["width"] >= size[0] and then imagedata["sizes"]["thumbnail"]["width"] >= size[1] ) then
--                         data = imagedata["sizes"]["thumbnail"];
--                 end; else then
--                         return false;
--                 end;

--                 -- Constrain the width and height attributes to the requested values.
--                 list( data["width"], data["height"] ) = image_constrain_size_for_editor( data["width"], data["height"], size );

--         end; elseif ( not empty( imagedata["sizes"][ size ] ) ) then
--                 data = imagedata["sizes"][ size ];
--         end;

--         -- If we still don"t have a match at this point, return false.
--         if ( empty( data ) ) then
--                 return false;
--         end;

--         -- Include the full filesystem path of the intermediate file.
--         if ( empty( data["path"] ) and then not empty( data["file"] ) and then not empty( imagedata["file"] ) ) then
--                 file_url     = wp_get_attachment_url( post_id );
--                 data["path"] = path_join( dirname( imagedata["file"] ), data["file"] );
--                 data["url"]  = path_join( dirname( file_url ), data["file"] );
--         end;

--         --
--         -- Filters the output of image_get_intermediate_size()
--         --
--         -- @since 4.4.0
--         --
--         -- @see image_get_intermediate_size()
--         --
--         -- @param array        data    Array of file relative path, width, and height on success. May also include
--         --                              file absolute path and URL.
--         -- @param int          post_id The ID of the image attachment.
--         -- @param string|int[] size    Requested image size. Can be any registered image size name, or
--         --                              an array of width and height values in pixels (in that order).
--         --
--         return apply_filters( "image_get_intermediate_size", data, post_id, size );
-- end;

   ----------------------------------
   -- Get_Intermediate_Image_Sizes --
   ----------------------------------

   function Get_Intermediate_Image_Sizes
            return List_Type
   is
      use UStrings;
      use Php;
      use Php.Arrays;
      use Php.Lists;
      use Inc_Plugins;

      Default_Sizes_2 : constant List_Type := To_List (List => (
        +"thumbnail", +"medium", +"medium_large", +"large"));

      Additional_Sizes : constant Array_Type := Wp_Get_Additional_Image_Sizes;

      Default_Sizes : constant List_Type :=
        (if not Empty (Additional_Sizes)
         then List_Merge (Default_Sizes_2, Array_Keys (Additional_Sizes))
         else Default_Sizes_2);

   begin
      --
      -- Filters the list of intermediate image sizes.
      --
      -- @since 2.5.0
      --
      -- @param string[] default_sizes An array of intermediate image size names.
      --                                Defaults are "thumbnail", "medium",
      --                                "medium_large", "large".
      --
      return Apply_Filters ("intermediate_image_sizes", Default_Sizes);
   end Get_Intermediate_Image_Sizes;

   --------------------------------------
   -- Wp_Get_Registered_Image_Subsizes --
   --------------------------------------

   function Wp_Get_Registered_Image_Subsizes
            return Array_Type
   is
      use UStrings;
--    use Php;
      use Inc_Options;

      Additional_Sizes : constant Array_Type :=
        Wp_Get_Additional_Image_Sizes;

      All_Sizes : Array_Type;
   begin
      for Size_Name_2 of Get_Intermediate_Image_Sizes loop
         declare
            Size_Name : constant String := -Size_Name_2;

            Size_Data : Array_Type := To_Array (List => (
              Build ("width",  0),
              Build ("height", 0),
              Build ("crop",   False)
            ));
         begin
            if Isset_2 (Additional_Sizes, Size_Name, "width") then
               -- For sizes added by plugins and themes.
               Set (Size_Data, "width",
                    Value => Get (Ref_2 (Additional_Sizes, Size_Name, "width")));
            else
               -- For default sizes set in options.
               Set (Size_Data, "width",
                    Value => From_Integer (Get_Option (Size_Name & "_size_w")));
            end if;

            if Isset_2 (Additional_Sizes, Size_Name, "height") then
               Set (Size_Data, "height",
                    Value => Get (Ref_2 (Additional_Sizes, Size_Name, "height")));
            else
               Set (Size_Data, "height",
                    Value => From_Integer (Get_Option (Size_Name & "_size_h")));
            end if;

            if
              Empty (Size_Data, "width") and then
              Empty (Size_Data, "height")
            then
               -- This size isn't set.
               goto Continue;
            end if;

            if Isset_2 (Additional_Sizes, Size_Name, "crop") then
               Set (Size_Data, "crop",
                    Value => Get (Ref_2 (Additional_Sizes, Size_Name, "crop")));
            else
               Set (Size_Data, "crop",
                    Value => From_Boolean (Get_Option (Size_Name & "_crop")));
            end if;

            if
              Kind_Of (Get (Size_Data, "crop")) /= Kind_Array or else
              Empty (Size_Data, "crop")
            then
               Set (Size_Data, "crop",
                    Value => From_Boolean (As_Boolean (Get (Size_Data, "crop"))));
            end if;

            Set (All_Sizes, Key => Size_Name,
                 Value => From_Array (Size_Data));
         end;
         << Continue >>
      end loop;

      return All_Sizes;
   end Wp_Get_Registered_Image_Subsizes;

   ---------------------------------
   -- Wp_Get_Attachment_Image_Src --
   ---------------------------------

   function Wp_Get_Attachment_Image_Src
              (Attachment_Id : Integer;
               Size          : String  := "thumbnail";
               Icon          : Boolean := False)
               return Image_Src_Type
   is
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Plugins;
      use Inc_Posts;

      -- Get a thumbnail or intermediate image if there is one.
      Image  : Image_Src_Type := Image_Downsize (Attachment_Id, Size);
      Width  : Natural := 0;
      Height : Natural := 0;
   begin
      if Image.Source = "" then
--    if not Image then
         declare
            Src : UString; -- Boolean := False;
         begin
            if Icon then
               Src := +Wp_MIME_Type_Icon (Attachment_Id);

               if Src /= "" then
                  declare
                     -- This filter is documented in wp-includes/post.php
                     Icon_Dir : constant String :=
                       Apply_Filters ("icon_dir",
                                      -(Globals.ABSPATH & Globals.WPINC) &
                                      "/images/media");

                     Src_File : constant String :=
                       Icon_Dir & "/" & Wp_Basename (-Src);

                     List : constant List_Type := Wp_Getimagesize (Src_File);
                  begin
                     Width  := Integer'Value (-List (1));
                     Height := Integer'Value (-List (2));
                  end;
               end if;
            end if;

            if Src /= "" and then Width /= 0 and then Height /= 0 then
               Image := (Source  => Src,
                         Width   => Width,
                         Height  => Height,
                         Resized => False);
            end if;
         end;
      end if;

      --
      -- Filters the attachment image source result.
      --
      -- @since 4.3.0
      --
      -- @param array|false  image         {
      --     Array of image data, or boolean false if no image is available.
      --
      --     @type string 0 Image source URL.
      --     @type int    1 Image width in pixels.
      --     @type int    2 Image height in pixels.
      --     @type bool   3 Whether the image is a resized image.
      -- }
      -- @param int          attachment_id Image attachment ID.
      -- @param string|int[] size          Requested image size. Can be any registered
      --                                   image size name, or an array of width and
      --                                   height values in pixels (in that order).
      -- @param bool         icon          Whether the image should be treated as
      --                                   an icon.
      --
      return Apply_Filters ("wp_get_attachment_image_src", Image,
                            Attachment_Id, Size, Icon);
   end Wp_Get_Attachment_Image_Src;

-- --
-- -- Gets an HTML img element representing an image attachment.
-- --
-- -- While `size` will accept an array, it is better to register a size with
-- -- add_image_size() so that a cropped version is generated. It"s much more
-- -- efficient than having to find the closest-sized image and then having the
-- -- browser scale down the image.
-- --
-- -- @since 2.5.0
-- -- @since 4.4.0 The `srcset` and `sizes` attributes were added.
-- -- @since 5.5.0 The `loading` attribute was added.
-- -- @since 6.1.0 The `decoding` attribute was added.
-- --
-- -- @param int          attachment_id Image attachment ID.
-- -- @param string|int[] size          Optional. Image size. Accepts any registered image size name, or an array
-- --                                    of width and height values in pixels (in that order). Default "thumbnail".
-- -- @param bool         icon          Optional. Whether the image should be treated as an icon. Default false.
-- -- @param string|array attr then
-- --     Optional. Attributes for the image markup.
-- --
-- --     @type string       src      Image attachment URL.
-- --     @type string       class    CSS class name or space-separated list of classes.
-- --                                  Default `attachment-size_class size-size_class`,
-- --                                  where `size_class` is the image size being requested.
-- --     @type string       alt      Image description for the alt attribute.
-- --     @type string       srcset   The "srcset" attribute value.
-- --     @type string       sizes    The "sizes" attribute value.
-- --     @type string|false loading  The "loading" attribute value. Passing a value of false
-- --                                  will result in the attribute being omitted for the image.
-- --                                  Defaults to "lazy", depending on wp_lazy_loading_enabled().
-- --     @type string       decoding The "decoding" attribute value. Possible values are
-- --                                  "async" (default), "sync", or "auto".
-- -- end;
-- -- @return string HTML img element or empty string on failure.
-- --
-- function wp_get_attachment_image( attachment_id, size = "thumbnail", icon = false, attr = "" ) then
--         html  = "";
--         image = wp_get_attachment_image_src( attachment_id, size, icon );

--         if ( image ) then
--                 list( src, width, height ) = image;

--                 attachment = get_post( attachment_id );
--                 hwstring   = image_hwstring( width, height );
--                 size_class = size;

--                 if ( is_array( size_class ) ) then
--                         size_class = implode( "x", size_class );
--                 end;

--                 default_attr = array(
--                         "src"      => src,
--                         "class"    => "attachment-size_class size-size_class",
--                         "alt"      => trim( strip_tags( get_post_meta( attachment_id, "_wp_attachment_image_alt", true ) ) ),
--                         "decoding" => "async",
--                 );

--                 -- Add `loading` attribute.
--                 if ( wp_lazy_loading_enabled( "img", "wp_get_attachment_image" ) ) then
--                         default_attr["loading"] = wp_get_loading_attr_default( "wp_get_attachment_image" );
--                 end;

--                 attr = wp_parse_args( attr, default_attr );

--                 -- If the default value of `lazy` for the `loading` attribute is overridden
--                 -- to omit the attribute for this image, ensure it is not included.
--                 if ( array_key_exists( "loading", attr ) and then not attr["loading"] ) then
--                         unset( attr["loading"] );
--                 end;

--                 -- Generate "srcset" and "sizes" if not already present.
--                 if ( empty( attr["srcset"] ) ) then
--                         image_meta = wp_get_attachment_metadata( attachment_id );

--                         if ( is_array( image_meta ) ) then
--                                 size_array = array( absint( width ), absint( height ) );
--                                 srcset     = wp_calculate_image_srcset( size_array, src, image_meta, attachment_id );
--                                 sizes      = wp_calculate_image_sizes( size_array, src, image_meta, attachment_id );

--                                 if ( srcset and then ( sizes || not empty( attr["sizes"] ) ) ) then
--                                         attr["srcset"] = srcset;

--                                         if ( empty( attr["sizes"] ) ) then
--                                                 attr["sizes"] = sizes;
--                                         end;
--                                 end;
--                         end;
--                 end;

--                 --
--                 -- Filters the list of attachment image attributes.
--                 --
--                 -- @since 2.8.0
--                 --
--                 -- @param string[]     attr       Array of attribute values for the image markup, keyed by attribute name.
--                 --                                 See wp_get_attachment_image().
--                 -- @param WP_Post      attachment Image attachment post.
--                 -- @param string|int[] size       Requested image size. Can be any registered image size name, or
--                 --                                 an array of width and height values in pixels (in that order).
--                 --
--                 attr = apply_filters( "wp_get_attachment_image_attributes", attr, attachment, size );

--                 attr = array_map( "esc_attr", attr );
--                 html = rtrim( "<img hwstring" );

--                 foreach ( attr as name => value ) then
--                         html .= " name=" . """ . value . """;
--                 end;

--                 html .= " />";
--         end;

--         --
--         -- Filters the HTML img element representing an image attachment.
--         --
--         -- @since 5.6.0
--         --
--         -- @param string       html          HTML img element or empty string on failure.
--         -- @param int          attachment_id Image attachment ID.
--         -- @param string|int[] size          Requested image size. Can be any registered image size name, or
--         --                                    an array of width and height values in pixels (in that order).
--         -- @param bool         icon          Whether the image should be treated as an icon.
--         -- @param string[]     attr          Array of attribute values for the image markup, keyed by attribute name.
--         --                                    See wp_get_attachment_image().
--         --
--         return apply_filters( "wp_get_attachment_image", html, attachment_id, size, icon, attr );
-- end;

   ---------------------------------
   -- Wp_Get_Attachment_Image_URL --
   ---------------------------------

   function Wp_Get_Attachment_Image_URL
              (Attachment_Id : Integer;
               Size          : String  := "thumbnail";
               Icon          : Boolean := False)
               return String
   is
      use Php.Strings;
      use UStrings;

      Image : constant Image_Src_Type :=
        Wp_Get_Attachment_Image_Src (Attachment_Id, Size, Icon);
   begin
      return
        (if Isset (-Image.Source)
         then -Image.Source else ""); -- False
   end Wp_Get_Attachment_Image_URL;

-- --
-- -- Gets the attachment path relative to the upload directory.
-- --
-- -- @since 4.4.1
-- -- @access private
-- --
-- -- @param string file Attachment file name.
-- -- @return string Attachment path relative to the upload directory.
-- --
-- function _wp_get_attachment_relative_path( file ) then
--         dirname = dirname( file );

--         if ( "." === dirname ) then
--                 return "";
--         end;

--         if ( false not== strpos( dirname, "wp-content/uploads" ) ) then
--                 -- Get the directory name relative to the upload directory (back compat for pre-2.7 uploads).
--                 dirname = substr( dirname, strpos( dirname, "wp-content/uploads" ) + 18 );
--                 dirname = ltrim( dirname, "/" );
--         end;

--         return dirname;
-- end;

-- --
-- -- Gets the image size as array from its meta data.
-- --
-- -- Used for responsive images.
-- --
-- -- @since 4.4.0
-- -- @access private
-- --
-- -- @param string size_name  Image size. Accepts any registered image size name.
-- -- @param array  image_meta The image meta data.
-- -- @return array|false then
-- --     Array of width and height or false if the size isn"t present in the meta data.
-- --
-- --     @type int 0 Image width.
-- --     @type int 1 Image height.
-- -- end;
-- --
-- function _wp_get_image_size_from_meta( size_name, image_meta ) then
--         if ( "full" === size_name ) then
--                 return array(
--                         absint( image_meta["width"] ),
--                         absint( image_meta["height"] ),
--                 );
--         end; elseif ( not empty( image_meta["sizes"][ size_name ] ) ) then
--                 return array(
--                         absint( image_meta["sizes"][ size_name ]["width"] ),
--                         absint( image_meta["sizes"][ size_name ]["height"] ),
--                 );
--         end;

--         return false;
-- end;

-- --
-- -- Retrieves the value for an image attachment"s "srcset" attribute.
-- --
-- -- @since 4.4.0
-- --
-- -- @see wp_calculate_image_srcset()
-- --
-- -- @param int          attachment_id Image attachment ID.
-- -- @param string|int[] size          Optional. Image size. Accepts any registered image size name, or an array of
-- --                                    width and height values in pixels (in that order). Default "medium".
-- -- @param array        image_meta    Optional. The image meta data as returned by "wp_get_attachment_metadata()".
-- --                                    Default null.
-- -- @return string|false A "srcset" value string or false.
-- --
-- function wp_get_attachment_image_srcset( attachment_id, size = "medium", image_meta = null ) then
--         image = wp_get_attachment_image_src( attachment_id, size );

--         if ( not image ) then
--                 return false;
--         end;

--         if ( not is_array( image_meta ) ) then
--                 image_meta = wp_get_attachment_metadata( attachment_id );
--         end;

--         image_src  = image[0];
--         size_array = array(
--                 absint( image[1] ),
--                 absint( image[2] ),
--         );

--         return wp_calculate_image_srcset( size_array, image_src, image_meta, attachment_id );
-- end;

-- --
-- -- A helper function to calculate the image sources to include in a "srcset" attribute.
-- --
-- -- @since 4.4.0
-- --
-- -- @param int[]  size_array    then
-- --     An array of width and height values.
-- --
-- --     @type int 0 The width in pixels.
-- --     @type int 1 The height in pixels.
-- -- end;
-- -- @param string image_src     The "src" of the image.
-- -- @param array  image_meta    The image meta data as returned by "wp_get_attachment_metadata()".
-- -- @param int    attachment_id Optional. The image attachment ID. Default 0.
-- -- @return string|false The "srcset" attribute value. False on error or when only one source exists.
-- --
-- function wp_calculate_image_srcset( size_array, image_src, image_meta, attachment_id = 0 ) then
--         --
--         -- Pre-filters the image meta to be able to fix inconsistencies in the stored data.
--         --
--         -- @since 4.5.0
--         --
--         -- @param array  image_meta    The image meta data as returned by "wp_get_attachment_metadata()".
--         -- @param int[]  size_array    then
--         --     An array of requested width and height values.
--         --
--         --     @type int 0 The width in pixels.
--         --     @type int 1 The height in pixels.
--         -- end;
--         -- @param string image_src     The "src" of the image.
--         -- @param int    attachment_id The image attachment ID or 0 if not supplied.
--         --
--         image_meta = apply_filters( "wp_calculate_image_srcset_meta", image_meta, size_array, image_src, attachment_id );

--         if ( empty( image_meta["sizes"] ) || not isset( image_meta["file"] ) || strlen( image_meta["file"] ) < 4 ) then
--                 return false;
--         end;

--         image_sizes = image_meta["sizes"];

--         -- Get the width and height of the image.
--         image_width  = (int) size_array[0];
--         image_height = (int) size_array[1];

--         -- Bail early if error/no width.
--         if ( image_width < 1 ) then
--                 return false;
--         end;

--         image_basename = wp_basename( image_meta["file"] );

--         /*
--         -- WordPress flattens animated GIFs into one frame when generating intermediate sizes.
--         -- To avoid hiding animation in user content, if src is a full size GIF, a srcset attribute is not generated.
--         -- If src is an intermediate size GIF, the full size is excluded from srcset to keep a flattened GIF from becoming animated.
--         --
--         if ( not isset( image_sizes["thumbnail"]["mime-type"] ) || "image/gif" not== image_sizes["thumbnail"]["mime-type"] ) then
--                 image_sizes[] = array(
--                         "width"  => image_meta["width"],
--                         "height" => image_meta["height"],
--                         "file"   => image_basename,
--                 );
--         end; elseif ( strpos( image_src, image_meta["file"] ) ) then
--                 return false;
--         end;

--         -- Retrieve the uploads sub-directory from the full size image.
--         dirname = _wp_get_attachment_relative_path( image_meta["file"] );

--         if ( dirname ) then
--                 dirname = trailingslashit( dirname );
--         end;

--         upload_dir    = wp_get_upload_dir();
--         image_baseurl = trailingslashit( upload_dir["baseurl"] ) . dirname;

--         /*
--         -- If currently on HTTPS, prefer HTTPS URLs when we know they"re supported by the domain
--         -- (which is to say, when they share the domain name of the current request).
--         --
--         if ( is_ssl() and then "https" not== substr( image_baseurl, 0, 5 ) and then parse_url( image_baseurl, PHP_URL_HOST ) === _SERVER["HTTP_HOST"] ) then
--                 image_baseurl = set_url_scheme( image_baseurl, "https" );
--         end;

--         /*
--         -- Images that have been edited in WordPress after being uploaded will
--         -- contain a unique hash. Look for that hash and use it later to filter
--         -- out images that are leftovers from previous versions.
--         --
--         image_edited = preg_match( "/-e[0-9]then13end;/", wp_basename( image_src ), image_edit_hash );

--         --
--         -- Filters the maximum image width to be included in a "srcset" attribute.
--         --
--         -- @since 4.4.0
--         --
--         -- @param int   max_width  The maximum image width to be included in the "srcset". Default "2048".
--         -- @param int[] size_array then
--         --     An array of requested width and height values.
--         --
--         --     @type int 0 The width in pixels.
--         --     @type int 1 The height in pixels.
--         -- end;
--         --
--         max_srcset_image_width = apply_filters( "max_srcset_image_width", 2048, size_array );

--         -- Array to hold URL candidates.
--         sources = array();

--         --
--         -- To make sure the ID matches our image src, we will check to see if any sizes in our attachment
--         -- meta match our image_src. If no matches are found we don"t return a srcset to avoid serving
--         -- an incorrect image. See #35045.
--         --
--         src_matched = false;

--         /*
--         -- Loop through available images. Only use images that are resized
--         -- versions of the same edit.
--         --
--         foreach ( image_sizes as image ) then
--                 is_src = false;

--                 -- Check if image meta isn"t corrupted.
--                 if ( not is_array( image ) ) then
--                         continue;
--                 end;

--                 -- If the file name is part of the `src`, we"ve confirmed a match.
--                 if ( not src_matched and then false not== strpos( image_src, dirname . image["file"] ) ) then
--                         src_matched = true;
--                         is_src      = true;
--                 end;

--                 -- Filter out images that are from previous edits.
--                 if ( image_edited and then not strpos( image["file"], image_edit_hash[0] ) ) then
--                         continue;
--                 end;

--                 /*
--                 -- Filters out images that are wider than "max_srcset_image_width" unless
--                 -- that file is in the "src" attribute.
--                 --
--                 if ( max_srcset_image_width and then image["width"] > max_srcset_image_width and then not is_src ) then
--                         continue;
--                 end;

--                 -- If the image dimensions are within 1px of the expected size, use it.
--                 if ( wp_image_matches_ratio( image_width, image_height, image["width"], image["height"] ) ) then
--                         -- Add the URL, descriptor, and value to the sources array to be returned.
--                         source = array(
--                                 "url"        => image_baseurl . image["file"],
--                                 "descriptor" => "w",
--                                 "value"      => image["width"],
--                         );

--                         -- The "src" image has to be the first in the "srcset", because of a bug in iOS8. See #35030.
--                         if ( is_src ) then
--                                 sources = array( image["width"] => source ) + sources;
--                         end; else then
--                                 sources[ image["width"] ] = source;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters an image"s "srcset" sources.
--         --
--         -- @since 4.4.0
--         --
--         -- @param array  sources then
--         --     One or more arrays of source data to include in the "srcset".
--         --
--         --     @type array width then
--         --         @type string url        The URL of an image source.
--         --         @type string descriptor The descriptor type used in the image candidate string,
--         --                                  either "w" or "x".
--         --         @type int    value      The source width if paired with a "w" descriptor, or a
--         --                                  pixel density value if paired with an "x" descriptor.
--         --     end;
--         -- end;
--         -- @param array size_array     then
--         --     An array of requested width and height values.
--         --
--         --     @type int 0 The width in pixels.
--         --     @type int 1 The height in pixels.
--         -- end;
--         -- @param string image_src     The "src" of the image.
--         -- @param array  image_meta    The image meta data as returned by "wp_get_attachment_metadata()".
--         -- @param int    attachment_id Image attachment ID or 0.
--         --
--         sources = apply_filters( "wp_calculate_image_srcset", sources, size_array, image_src, image_meta, attachment_id );

--         -- Only return a "srcset" value if there is more than one source.
--         if ( not src_matched || not is_array( sources ) || count( sources ) < 2 ) then
--                 return false;
--         end;

--         srcset = "";

--         foreach ( sources as source ) then
--                 srcset .= str_replace( " ", "%20", source["url"] ) . " " . source["value"] . source["descriptor"] . ", ";
--         end;

--         return rtrim( srcset, ", " );
-- end;

-- --
-- -- Retrieves the value for an image attachment"s "sizes" attribute.
-- --
-- -- @since 4.4.0
-- --
-- -- @see wp_calculate_image_sizes()
-- --
-- -- @param int          attachment_id Image attachment ID.
-- -- @param string|int[] size          Optional. Image size. Accepts any registered image size name, or an array of
-- --                                    width and height values in pixels (in that order). Default "medium".
-- -- @param array        image_meta    Optional. The image meta data as returned by "wp_get_attachment_metadata()".
-- --                                    Default null.
-- -- @return string|false A valid source size value for use in a "sizes" attribute or false.
-- --
-- function wp_get_attachment_image_sizes( attachment_id, size = "medium", image_meta = null ) then
--         image = wp_get_attachment_image_src( attachment_id, size );

--         if ( not image ) then
--                 return false;
--         end;

--         if ( not is_array( image_meta ) ) then
--                 image_meta = wp_get_attachment_metadata( attachment_id );
--         end;

--         image_src  = image[0];
--         size_array = array(
--                 absint( image[1] ),
--                 absint( image[2] ),
--         );

--         return wp_calculate_image_sizes( size_array, image_src, image_meta, attachment_id );
-- end;

-- --
-- -- Creates a "sizes" attribute value for an image.
-- --
-- -- @since 4.4.0
-- --
-- -- @param string|int[] size          Image size. Accepts any registered image size name, or an array of
-- --                                    width and height values in pixels (in that order).
-- -- @param string       image_src     Optional. The URL to the image file. Default null.
-- -- @param array        image_meta    Optional. The image meta data as returned by "wp_get_attachment_metadata()".
-- --                                    Default null.
-- -- @param int          attachment_id Optional. Image attachment ID. Either `image_meta` or `attachment_id`
-- --                                    is needed when using the image size name as argument for `size`. Default 0.
-- -- @return string|false A valid source size value for use in a "sizes" attribute or false.
-- --
-- function wp_calculate_image_sizes( size, image_src = null, image_meta = null, attachment_id = 0 ) then
--         width = 0;

--         if ( is_array( size ) ) then
--                 width = absint( size[0] );
--         end; elseif ( is_string( size ) ) then
--                 if ( not image_meta and then attachment_id ) then
--                         image_meta = wp_get_attachment_metadata( attachment_id );
--                 end;

--                 if ( is_array( image_meta ) ) then
--                         size_array = _wp_get_image_size_from_meta( size, image_meta );
--                         if ( size_array ) then
--                                 width = absint( size_array[0] );
--                         end;
--                 end;
--         end;

--         if ( not width ) then
--                 return false;
--         end;

--         -- Setup the default "sizes" attribute.
--         sizes = sprintf( "(max-width: %1dpx) 100vw, %1dpx", width );

--         --
--         -- Filters the output of "wp_calculate_image_sizes()".
--         --
--         -- @since 4.4.0
--         --
--         -- @param string       sizes         A source size value for use in a "sizes" attribute.
--         -- @param string|int[] size          Requested image size. Can be any registered image size name, or
--         --                                    an array of width and height values in pixels (in that order).
--         -- @param string|null  image_src     The URL to the image file or null.
--         -- @param array|null   image_meta    The image meta data as returned by wp_get_attachment_metadata() or null.
--         -- @param int          attachment_id Image attachment ID of the original image or 0.
--         --
--         return apply_filters( "wp_calculate_image_sizes", sizes, size, image_src, image_meta, attachment_id );
-- end;

-- --
-- -- Determines if the image meta data is for the image source file.
-- --
-- -- The image meta data is retrieved by attachment post ID. In some cases the post IDs may change.
-- -- For example when the website is exported and imported at another website. Then the
-- -- attachment post IDs that are in post_content for the exported website may not match
-- -- the same attachments at the new website.
-- --
-- -- @since 5.5.0
-- --
-- -- @param string image_location The full path or URI to the image file.
-- -- @param array  image_meta     The attachment meta data as returned by "wp_get_attachment_metadata()".
-- -- @param int    attachment_id  Optional. The image attachment ID. Default 0.
-- -- @return bool Whether the image meta is for this image file.
-- --
-- function wp_image_file_matches_image_meta( image_location, image_meta, attachment_id = 0 ) then
--         match = false;

--         -- Ensure the image_meta is valid.
--         if ( isset( image_meta["file"] ) and then strlen( image_meta["file"] ) > 4 ) then
--                 -- Remove query args in image URI.
--                 list( image_location ) = explode( "?", image_location );

--                 -- Check if the relative image path from the image meta is at the end of image_location.
--                 if ( strrpos( image_location, image_meta["file"] ) === strlen( image_location ) - strlen( image_meta["file"] ) ) then
--                         match = true;
--                 end; else then
--                         -- Retrieve the uploads sub-directory from the full size image.
--                         dirname = _wp_get_attachment_relative_path( image_meta["file"] );

--                         if ( dirname ) then
--                                 dirname = trailingslashit( dirname );
--                         end;

--                         if ( not empty( image_meta["original_image"] ) ) then
--                                 relative_path = dirname . image_meta["original_image"];

--                                 if ( strrpos( image_location, relative_path ) === strlen( image_location ) - strlen( relative_path ) ) then
--                                         match = true;
--                                 end;
--                         end;

--                         if ( not match and then not empty( image_meta["sizes"] ) ) then
--                                 foreach ( image_meta["sizes"] as image_size_data ) then
--                                         relative_path = dirname . image_size_data["file"];

--                                         if ( strrpos( image_location, relative_path ) === strlen( image_location ) - strlen( relative_path ) ) then
--                                                 match = true;
--                                                 break;
--                                         end;
--                                 end;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters whether an image path or URI matches image meta.
--         --
--         -- @since 5.5.0
--         --
--         -- @param bool   match          Whether the image relative path from the image meta
--         --                               matches the end of the URI or path to the image file.
--         -- @param string image_location Full path or URI to the tested image file.
--         -- @param array  image_meta     The image meta data as returned by "wp_get_attachment_metadata()".
--         -- @param int    attachment_id  The image attachment ID or 0 if not supplied.
--         --
--         return apply_filters( "wp_image_file_matches_image_meta", match, image_location, image_meta, attachment_id );
-- end;

-- --
-- -- Determines an image"s width and height dimensions based on the source file.
-- --
-- -- @since 5.5.0
-- --
-- -- @param string image_src     The image source file.
-- -- @param array  image_meta    The image meta data as returned by "wp_get_attachment_metadata()".
-- -- @param int    attachment_id Optional. The image attachment ID. Default 0.
-- -- @return array|false Array with first element being the width and second element being the height,
-- --                     or false if dimensions cannot be determined.
-- --
-- function wp_image_src_get_dimensions( image_src, image_meta, attachment_id = 0 ) then
--         dimensions = false;

--         -- Is it a full size image?
--         if (
--                 isset( image_meta["file"] ) and then
--                 strpos( image_src, wp_basename( image_meta["file"] ) ) not== false
--         ) then
--                 dimensions = array(
--                         (int) image_meta["width"],
--                         (int) image_meta["height"],
--                 );
--         end;

--         if ( not dimensions and then not empty( image_meta["sizes"] ) ) then
--                 src_filename = wp_basename( image_src );

--                 foreach ( image_meta["sizes"] as image_size_data ) then
--                         if ( src_filename === image_size_data["file"] ) then
--                                 dimensions = array(
--                                         (int) image_size_data["width"],
--                                         (int) image_size_data["height"],
--                                 );

--                                 break;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters the "wp_image_src_get_dimensions" value.
--         --
--         -- @since 5.7.0
--         --
--         -- @param array|false dimensions    Array with first element being the width
--         --                                   and second element being the height, or
--         --                                   false if dimensions could not be determined.
--         -- @param string      image_src     The image source file.
--         -- @param array       image_meta    The image meta data as returned by
--         --                                   "wp_get_attachment_metadata()".
--         -- @param int         attachment_id The image attachment ID. Default 0.
--         --
--         return apply_filters( "wp_image_src_get_dimensions", dimensions, image_src, image_meta, attachment_id );
-- end;

-- --
-- -- Adds "srcset" and "sizes" attributes to an existing "img" element.
-- --
-- -- @since 4.4.0
-- --
-- -- @see wp_calculate_image_srcset()
-- -- @see wp_calculate_image_sizes()
-- --
-- -- @param string image         An HTML "img" element to be filtered.
-- -- @param array  image_meta    The image meta data as returned by "wp_get_attachment_metadata()".
-- -- @param int    attachment_id Image attachment ID.
-- -- @return string Converted "img" element with "srcset" and "sizes" attributes added.
-- --
-- function wp_image_add_srcset_and_sizes( image, image_meta, attachment_id ) then
--         -- Ensure the image meta exists.
--         if ( empty( image_meta["sizes"] ) ) then
--                 return image;
--         end;

--         image_src         = preg_match( "/src="([^"]+)"/", image, match_src ) ? match_src[1] : "";
--         list( image_src ) = explode( "?", image_src );

--         -- Return early if we couldn"t get the image source.
--         if ( not image_src ) then
--                 return image;
--         end;

--         -- Bail early if an image has been inserted and later edited.
--         if ( preg_match( "/-e[0-9]then13end;/", image_meta["file"], img_edit_hash ) and then
--                 strpos( wp_basename( image_src ), img_edit_hash[0] ) === false ) then

--                 return image;
--         end;

--         width  = preg_match( "/ width="([0-9]+)"/", image, match_width ) ? (int) match_width[1] : 0;
--         height = preg_match( "/ height="([0-9]+)"/", image, match_height ) ? (int) match_height[1] : 0;

--         if ( width and then height ) then
--                 size_array = array( width, height );
--         end; else then
--                 size_array = wp_image_src_get_dimensions( image_src, image_meta, attachment_id );
--                 if ( not size_array ) then
--                         return image;
--                 end;
--         end;

--         srcset = wp_calculate_image_srcset( size_array, image_src, image_meta, attachment_id );

--         if ( srcset ) then
--                 -- Check if there is already a "sizes" attribute.
--                 sizes = strpos( image, " sizes=" );

--                 if ( not sizes ) then
--                         sizes = wp_calculate_image_sizes( size_array, image_src, image_meta, attachment_id );
--                 end;
--         end;

--         if ( srcset and then sizes ) then
--                 -- Format the "srcset" and "sizes" string and escape attributes.
--                 attr = sprintf( " srcset="%s"", esc_attr( srcset ) );

--                 if ( is_string( sizes ) ) then
--                         attr .= sprintf( " sizes="%s"", esc_attr( sizes ) );
--                 end;

--                 -- Add the srcset and sizes attributes to the image markup.
--                 return preg_replace( "/<img ([^>]+?)[\/ ]*>/", "<img 1" . attr . " />", image );
--         end;

--         return image;
-- end;

-- --
-- -- Determines whether to add the `loading` attribute to the specified tag in the specified context.
-- --
-- -- @since 5.5.0
-- -- @since 5.7.0 Now returns `true` by default for `iframe` tags.
-- --
-- -- @param string tag_name The tag name.
-- -- @param string context  Additional context, like the current filter name
-- --                         or the function name from where this was called.
-- -- @return bool Whether to add the attribute.
-- --
-- function wp_lazy_loading_enabled( tag_name, context ) then
--         -- By default add to all "img" and "iframe" tags.
--         -- See https://html.spec.whatwg.org/multipage/embedded-content.html#attr-img-loading
--         -- See https://html.spec.whatwg.org/multipage/iframe-embed-object.html#attr-iframe-loading
--         default = ( "img" === tag_name || "iframe" === tag_name );

--         --
--         -- Filters whether to add the `loading` attribute to the specified tag in the specified context.
--         --
--         -- @since 5.5.0
--         --
--         -- @param bool   default  Default value.
--         -- @param string tag_name The tag name.
--         -- @param string context  Additional context, like the current filter name
--         --                         or the function name from where this was called.
--         --
--         return (bool) apply_filters( "wp_lazy_loading_enabled", default, tag_name, context );
-- end;

-- --
-- -- Filters specific tags in post content and modifies their markup.
-- --
-- -- Modifies HTML tags in post content to include new browser and HTML technologies
-- -- that may not have existed at the time of post creation. These modifications currently
-- -- include adding `srcset`, `sizes`, and `loading` attributes to `img` HTML tags, as well
-- -- as adding `loading` attributes to `iframe` HTML tags.
-- -- Future similar optimizations should be added/expected here.
-- --
-- -- @since 5.5.0
-- -- @since 5.7.0 Now supports adding `loading` attributes to `iframe` tags.
-- --
-- -- @see wp_img_tag_add_width_and_height_attr()
-- -- @see wp_img_tag_add_srcset_and_sizes_attr()
-- -- @see wp_img_tag_add_loading_attr()
-- -- @see wp_iframe_tag_add_loading_attr()
-- --
-- -- @param string content The HTML content to be filtered.
-- -- @param string context Optional. Additional context to pass to the filters.
-- --                        Defaults to `current_filter()` when not set.
-- -- @return string Converted content with images modified.
-- --
-- function wp_filter_content_tags( content, context = null ) then
--         if ( null === context ) then
--                 context = current_filter();
--         end;

--         add_img_loading_attr    = wp_lazy_loading_enabled( "img", context );
--         add_iframe_loading_attr = wp_lazy_loading_enabled( "iframe", context );

--         if ( not preg_match_all( "/<(img|iframe)\s[^>]+>/", content, matches, PREG_SET_ORDER ) ) then
--                 return content;
--         end;

--         -- List of the unique `img` tags found in content.
--         images = array();

--         -- List of the unique `iframe` tags found in content.
--         iframes = array();

--         foreach ( matches as match ) then
--                 list( tag, tag_name ) = match;

--                 switch ( tag_name ) then
--                         case "img":
--                                 if ( preg_match( "/wp-image-([0-9]+)/i", tag, class_id ) ) then
--                                         attachment_id = absint( class_id[1] );

--                                         if ( attachment_id ) then
--                                                 -- If exactly the same image tag is used more than once, overwrite it.
--                                                 -- All identical tags will be replaced later with "str_replace()".
--                                                 images[ tag ] = attachment_id;
--                                                 break;
--                                         end;
--                                 end;
--                                 images[ tag ] = 0;
--                                 break;
--                         case "iframe":
--                                 iframes[ tag ] = 0;
--                                 break;
--                 end;
--         end;

--         -- Reduce the array to unique attachment IDs.
--         attachment_ids = array_unique( array_filter( array_values( images ) ) );

--         if ( count( attachment_ids ) > 1 ) then
--                 /*
--                 -- Warm the object cache with post and meta information for all found
--                 -- images to avoid making individual database calls.
--                 --
--                 _prime_post_caches( attachment_ids, false, true );
--         end;

--         -- Iterate through the matches in order of occurrence as it is relevant for whether or not to lazy-load.
--         foreach ( matches as match ) then
--                 -- Filter an image match.
--                 if ( isset( images[ match[0] ] ) ) then
--                         filtered_image = match[0];
--                         attachment_id  = images[ match[0] ];

--                         -- Add "width" and "height" attributes if applicable.
--                         if ( attachment_id > 0 and then false === strpos( filtered_image, " width=" ) and then false === strpos( filtered_image, " height=" ) ) then
--                                 filtered_image = wp_img_tag_add_width_and_height_attr( filtered_image, context, attachment_id );
--                         end;

--                         -- Add "srcset" and "sizes" attributes if applicable.
--                         if ( attachment_id > 0 and then false === strpos( filtered_image, " srcset=" ) ) then
--                                 filtered_image = wp_img_tag_add_srcset_and_sizes_attr( filtered_image, context, attachment_id );
--                         end;

--                         -- Add "loading" attribute if applicable.
--                         if ( add_img_loading_attr and then false === strpos( filtered_image, " loading=" ) ) then
--                                 filtered_image = wp_img_tag_add_loading_attr( filtered_image, context );
--                         end;

--                         -- Add "decoding=async" attribute unless a "decoding" attribute is already present.
--                         if ( not str_contains( filtered_image, " decoding=" ) ) then
--                                 filtered_image = wp_img_tag_add_decoding_attr( filtered_image, context );
--                         end;

--                         --
--                         -- Filters an img tag within the content for a given context.
--                         --
--                         -- @since 6.0.0
--                         --
--                         -- @param string filtered_image Full img tag with attributes that will replace the source img tag.
--                         -- @param string context        Additional context, like the current filter name or the function name from where this was called.
--                         -- @param int    attachment_id  The image attachment ID. May be 0 in case the image is not an attachment.
--                         --
--                         filtered_image = apply_filters( "wp_content_img_tag", filtered_image, context, attachment_id );

--                         if ( filtered_image not== match[0] ) then
--                                 content = str_replace( match[0], filtered_image, content );
--                         end;

--                         /*
--                         -- Unset image lookup to not run the same logic again unnecessarily if the same image tag is used more than
--                         -- once in the same blob of content.
--                         --
--                         unset( images[ match[0] ] );
--                 end;

--                 -- Filter an iframe match.
--                 if ( isset( iframes[ match[0] ] ) ) then
--                         filtered_iframe = match[0];

--                         -- Add "loading" attribute if applicable.
--                         if ( add_iframe_loading_attr and then false === strpos( filtered_iframe, " loading=" ) ) then
--                                 filtered_iframe = wp_iframe_tag_add_loading_attr( filtered_iframe, context );
--                         end;

--                         if ( filtered_iframe not== match[0] ) then
--                                 content = str_replace( match[0], filtered_iframe, content );
--                         end;

--                         /*
--                         -- Unset iframe lookup to not run the same logic again unnecessarily if the same iframe tag is used more
--                         -- than once in the same blob of content.
--                         --
--                         unset( iframes[ match[0] ] );
--                 end;
--         end;

--         return content;
-- end;

-- --
-- -- Adds `loading` attribute to an `img` HTML tag.
-- --
-- -- @since 5.5.0
-- --
-- -- @param string image   The HTML `img` tag where the attribute should be added.
-- -- @param string context Additional context to pass to the filters.
-- -- @return string Converted `img` tag with `loading` attribute added.
-- --
-- function wp_img_tag_add_loading_attr( image, context ) then
--         -- Get loading attribute value to use. This must occur before the conditional check below so that even images that
--         -- are ineligible for being lazy-loaded are considered.
--         value = wp_get_loading_attr_default( context );

--         -- Images should have source and dimension attributes for the `loading` attribute to be added.
--         if ( false === strpos( image, " src="" ) || false === strpos( image, " width="" ) || false === strpos( image, " height="" ) ) then
--                 return image;
--         end;

--         --
--         -- Filters the `loading` attribute value to add to an image. Default `lazy`.
--         --
--         -- Returning `false` or an empty string will not add the attribute.
--         -- Returning `true` will add the default value.
--         --
--         -- @since 5.5.0
--         --
--         -- @param string|bool value   The `loading` attribute value. Returning a falsey value will result in
--         --                             the attribute being omitted for the image.
--         -- @param string      image   The HTML `img` tag to be filtered.
--         -- @param string      context Additional context about how the function was called or where the img tag is.
--         --
--         value = apply_filters( "wp_img_tag_add_loading_attr", value, image, context );

--         if ( value ) then
--                 if ( not in_array( value, array( "lazy", "eager" ), true ) ) then
--                         value = "lazy";
--                 end;

--                 return str_replace( "<img", "<img loading="" . esc_attr( value ) . """, image );
--         end;

--         return image;
-- end;

-- --
-- -- Adds `decoding` attribute to an `img` HTML tag.
-- --
-- -- The `decoding` attribute allows developers to indicate whether the
-- -- browser can decode the image off the main thread (`async`), on the
-- -- main thread (`sync`) or as determined by the browser (`auto`).
-- --
-- -- By default WordPress adds `decoding="async"` to images but developers
-- -- can use the {@see "wp_img_tag_add_decoding_attr"} filter to modify this
-- -- to remove the attribute or set it to another accepted value.
-- --
-- -- @since 6.1.0
-- --
-- -- @param string image   The HTML `img` tag where the attribute should be added.
-- -- @param string context Additional context to pass to the filters.
-- --
-- -- @return string Converted `img` tag with `decoding` attribute added.
-- --
-- function wp_img_tag_add_decoding_attr( image, context ) then
--         -- Only apply the decoding attribute to images that have a src attribute that
--         -- starts with a double quote, ensuring escaped JSON is also excluded.
--         if ( false === strpos( image, " src="" ) ) then
--                 return image;
--         end;

--         --
--         -- Filters the `decoding` attribute value to add to an image. Default `async`.
--         --
--         -- Returning a falsey value will omit the attribute.
--         --
--         -- @since 6.1.0
--         --
--         -- @param string|false|null value   The `decoding` attribute value. Returning a falsey value
--         --                                   will result in the attribute being omitted for the image.
--         --                                   Otherwise, it may be: "async" (default), "sync", or "auto".
--         -- @param string            image   The HTML `img` tag to be filtered.
--         -- @param string            context Additional context about how the function was called
--         --                                   or where the img tag is.
--         --
--         value = apply_filters( "wp_img_tag_add_decoding_attr", "async", image, context );

--         if ( in_array( value, array( "async", "sync", "auto" ), true ) ) then
--                 image = str_replace( "<img ", "<img decoding="" . esc_attr( value ) . "" ", image );
--         end;

--         return image;
-- end;

-- --
-- -- Adds `width` and `height` attributes to an `img` HTML tag.
-- --
-- -- @since 5.5.0
-- --
-- -- @param string image         The HTML `img` tag where the attribute should be added.
-- -- @param string context       Additional context to pass to the filters.
-- -- @param int    attachment_id Image attachment ID.
-- -- @return string Converted "img" element with "width" and "height" attributes added.
-- --
-- function wp_img_tag_add_width_and_height_attr( image, context, attachment_id ) then
--         image_src         = preg_match( "/src="([^"]+)"/", image, match_src ) ? match_src[1] : "";
--         list( image_src ) = explode( "?", image_src );

--         -- Return early if we couldn"t get the image source.
--         if ( not image_src ) then
--                 return image;
--         end;

--         --
--         -- Filters whether to add the missing `width` and `height` HTML attributes to the img tag. Default `true`.
--         --
--         -- Returning anything else than `true` will not add the attributes.
--         --
--         -- @since 5.5.0
--         --
--         -- @param bool   value         The filtered value, defaults to `true`.
--         -- @param string image         The HTML `img` tag where the attribute should be added.
--         -- @param string context       Additional context about how the function was called or where the img tag is.
--         -- @param int    attachment_id The image attachment ID.
--         --
--         add = apply_filters( "wp_img_tag_add_width_and_height_attr", true, image, context, attachment_id );

--         if ( true === add ) then
--                 image_meta = wp_get_attachment_metadata( attachment_id );
--                 size_array = wp_image_src_get_dimensions( image_src, image_meta, attachment_id );

--                 if ( size_array ) then
--                         hw = trim( image_hwstring( size_array[0], size_array[1] ) );
--                         return str_replace( "<img", "<img thenhwend;", image );
--                 end;
--         end;

--         return image;
-- end;

-- --
-- -- Adds `srcset` and `sizes` attributes to an existing `img` HTML tag.
-- --
-- -- @since 5.5.0
-- --
-- -- @param string image         The HTML `img` tag where the attribute should be added.
-- -- @param string context       Additional context to pass to the filters.
-- -- @param int    attachment_id Image attachment ID.
-- -- @return string Converted "img" element with "loading" attribute added.
-- --
-- function wp_img_tag_add_srcset_and_sizes_attr( image, context, attachment_id ) then
--         --
--         -- Filters whether to add the `srcset` and `sizes` HTML attributes to the img tag. Default `true`.
--         --
--         -- Returning anything else than `true` will not add the attributes.
--         --
--         -- @since 5.5.0
--         --
--         -- @param bool   value         The filtered value, defaults to `true`.
--         -- @param string image         The HTML `img` tag where the attribute should be added.
--         -- @param string context       Additional context about how the function was called or where the img tag is.
--         -- @param int    attachment_id The image attachment ID.
--         --
--         add = apply_filters( "wp_img_tag_add_srcset_and_sizes_attr", true, image, context, attachment_id );

--         if ( true === add ) then
--                 image_meta = wp_get_attachment_metadata( attachment_id );
--                 return wp_image_add_srcset_and_sizes( image, image_meta, attachment_id );
--         end;

--         return image;
-- end;

-- --
-- -- Adds `loading` attribute to an `iframe` HTML tag.
-- --
-- -- @since 5.7.0
-- --
-- -- @param string iframe  The HTML `iframe` tag where the attribute should be added.
-- -- @param string context Additional context to pass to the filters.
-- -- @return string Converted `iframe` tag with `loading` attribute added.
-- --
-- function wp_iframe_tag_add_loading_attr( iframe, context ) then
--         -- Iframes with fallback content (see `wp_filter_oembed_result()`) should not be lazy-loaded because they are
--         -- visually hidden initially.
--         if ( false not== strpos( iframe, " data-secret="" ) ) then
--                 return iframe;
--         end;

--         -- Get loading attribute value to use. This must occur before the conditional check below so that even iframes that
--         -- are ineligible for being lazy-loaded are considered.
--         value = wp_get_loading_attr_default( context );

--         -- Iframes should have source and dimension attributes for the `loading` attribute to be added.
--         if ( false === strpos( iframe, " src="" ) || false === strpos( iframe, " width="" ) || false === strpos( iframe, " height="" ) ) then
--                 return iframe;
--         end;

--         --
--         -- Filters the `loading` attribute value to add to an iframe. Default `lazy`.
--         --
--         -- Returning `false` or an empty string will not add the attribute.
--         -- Returning `true` will add the default value.
--         --
--         -- @since 5.7.0
--         --
--         -- @param string|bool value   The `loading` attribute value. Returning a falsey value will result in
--         --                             the attribute being omitted for the iframe.
--         -- @param string      iframe  The HTML `iframe` tag to be filtered.
--         -- @param string      context Additional context about how the function was called or where the iframe tag is.
--         --
--         value = apply_filters( "wp_iframe_tag_add_loading_attr", value, iframe, context );

--         if ( value ) then
--                 if ( not in_array( value, array( "lazy", "eager" ), true ) ) then
--                         value = "lazy";
--                 end;

--                 return str_replace( "<iframe", "<iframe loading="" . esc_attr( value ) . """, iframe );
--         end;

--         return iframe;
-- end;

-- --
-- -- Adds a "wp-post-image" class to post thumbnails. Internal use only.
-- --
-- -- Uses the {@see "begin_fetch_post_thumbnail_html"} and {@see "end_fetch_post_thumbnail_html"}
-- -- action hooks to dynamically add/remove itself so as to only filter post thumbnails.
-- --
-- -- @ignore
-- -- @since 2.9.0
-- --
-- -- @param string[] attr Array of thumbnail attributes including src, class, alt, title, keyed by attribute name.
-- -- @return string[] Modified array of attributes including the new "wp-post-image" class.
-- --
-- function _wp_post_thumbnail_class_filter( attr ) then
--         attr["class"] .= " wp-post-image";
--         return attr;
-- end;

-- --
-- -- Adds "_wp_post_thumbnail_class_filter" callback to the "wp_get_attachment_image_attributes"
-- -- filter hook. Internal use only.
-- --
-- -- @ignore
-- -- @since 2.9.0
-- --
-- -- @param string[] attr Array of thumbnail attributes including src, class, alt, title, keyed by attribute name.
-- --
-- function _wp_post_thumbnail_class_filter_add( attr ) then
--         add_filter( "wp_get_attachment_image_attributes", "_wp_post_thumbnail_class_filter" );
-- end;

-- --
-- -- Removes the "_wp_post_thumbnail_class_filter" callback from the "wp_get_attachment_image_attributes"
-- -- filter hook. Internal use only.
-- --
-- -- @ignore
-- -- @since 2.9.0
-- --
-- -- @param string[] attr Array of thumbnail attributes including src, class, alt, title, keyed by attribute name.
-- --
-- function _wp_post_thumbnail_class_filter_remove( attr ) then
--         remove_filter( "wp_get_attachment_image_attributes", "_wp_post_thumbnail_class_filter" );
-- end;

-- add_shortcode( "wp_caption", "img_caption_shortcode" );
-- add_shortcode( "caption", "img_caption_shortcode" );

-- --
-- -- Builds the Caption shortcode output.
-- --
-- -- Allows a plugin to replace the content that would otherwise be returned. The
-- -- filter is {@see "img_caption_shortcode"} and passes an empty string, the attr
-- -- parameter and the content parameter values.
-- --
-- -- The supported attributes for the shortcode are "id", "caption_id", "align",
-- -- "width", "caption", and "class".
-- --
-- -- @since 2.6.0
-- -- @since 3.9.0 The `class` attribute was added.
-- -- @since 5.1.0 The `caption_id` attribute was added.
-- -- @since 5.9.0 The `content` parameter default value changed from `null` to `""`.
-- --
-- -- @param array  attr then
-- --     Attributes of the caption shortcode.
-- --
-- --     @type string id         ID of the image and caption container element, i.e. `<figure>` or `<div>`.
-- --     @type string caption_id ID of the caption element, i.e. `<figcaption>` or `<p>`.
-- --     @type string align      Class name that aligns the caption. Default "alignnone". Accepts "alignleft",
-- --                              "aligncenter", alignright", "alignnone".
-- --     @type int    width      The width of the caption, in pixels.
-- --     @type string caption    The caption text.
-- --     @type string class      Additional class name(s) added to the caption container.
-- -- end;
-- -- @param string content Optional. Shortcode content. Default empty string.
-- -- @return string HTML content to display the caption.
-- --
-- function img_caption_shortcode( attr, content = "" ) then
--         -- New-style shortcode with the caption inside the shortcode with the link and image tags.
--         if ( not isset( attr["caption"] ) ) then
--                 if ( preg_match( "#((?:<a [^>]+>\s*)?<img [^>]+>(?:\s*</a>)?)(.*)#is", content, matches ) ) then
--                         content         = matches[1];
--                         attr["caption"] = trim( matches[2] );
--                 end;
--         end; elseif ( strpos( attr["caption"], "<" ) not== false ) then
--                 attr["caption"] = wp_kses( attr["caption"], "post" );
--         end;

--         --
--         -- Filters the default caption shortcode output.
--         --
--         -- If the filtered output isn"t empty, it will be used instead of generating
--         -- the default caption template.
--         --
--         -- @since 2.6.0
--         --
--         -- @see img_caption_shortcode()
--         --
--         -- @param string output  The caption output. Default empty.
--         -- @param array  attr    Attributes of the caption shortcode.
--         -- @param string content The image element, possibly wrapped in a hyperlink.
--         --
--         output = apply_filters( "img_caption_shortcode", "", attr, content );

--         if ( not empty( output ) ) then
--                 return output;
--         end;

--         atts = shortcode_atts(
--                 array(
--                         "id"         => "",
--                         "caption_id" => "",
--                         "align"      => "alignnone",
--                         "width"      => "",
--                         "caption"    => "",
--                         "class"      => "",
--                 ),
--                 attr,
--                 "caption"
--         );

--         atts["width"] = (int) atts["width"];

--         if ( atts["width"] < 1 || empty( atts["caption"] ) ) then
--                 return content;
--         end;

--         id          = "";
--         caption_id  = "";
--         describedby = "";

--         if ( atts["id"] ) then
--                 atts["id"] = sanitize_html_class( atts["id"] );
--                 id         = "id="" . esc_attr( atts["id"] ) . "" ";
--         end;

--         if ( atts["caption_id"] ) then
--                 atts["caption_id"] = sanitize_html_class( atts["caption_id"] );
--         end; elseif ( atts["id"] ) then
--                 atts["caption_id"] = "caption-" . str_replace( "_", "-", atts["id"] );
--         end;

--         if ( atts["caption_id"] ) then
--                 caption_id  = "id="" . esc_attr( atts["caption_id"] ) . "" ";
--                 describedby = "aria-describedby="" . esc_attr( atts["caption_id"] ) . "" ";
--         end;

--         class = trim( "wp-caption " . atts["align"] . " " . atts["class"] );

--         html5 = current_theme_supports( "html5", "caption" );
--         -- HTML5 captions never added the extra 10px to the image width.
--         width = html5 ? atts["width"] : ( 10 + atts["width"] );

--         --
--         -- Filters the width of an image"s caption.
--         --
--         -- By default, the caption is 10 pixels greater than the width of the image,
--         -- to prevent post content from running up against a floated image.
--         --
--         -- @since 3.7.0
--         --
--         -- @see img_caption_shortcode()
--         --
--         -- @param int    width    Width of the caption in pixels. To remove this inline style,
--         --                         return zero.
--         -- @param array  atts     Attributes of the caption shortcode.
--         -- @param string content  The image element, possibly wrapped in a hyperlink.
--         --
--         caption_width = apply_filters( "img_caption_shortcode_width", width, atts, content );

--         style = "";

--         if ( caption_width ) then
--                 style = "style="width: " . (int) caption_width . "px" ";
--         end;

--         if ( html5 ) then
--                 html = sprintf(
--                         "<figure %s%s%sclass="%s">%s%s</figure>",
--                         id,
--                         describedby,
--                         style,
--                         esc_attr( class ),
--                         do_shortcode( content ),
--                         sprintf(
--                                 "<figcaption %sclass="wp-caption-text">%s</figcaption>",
--                                 caption_id,
--                                 atts["caption"]
--                         )
--                 );
--         end; else then
--                 html = sprintf(
--                         "<div %s%sclass="%s">%s%s</div>",
--                         id,
--                         style,
--                         esc_attr( class ),
--                         str_replace( "<img ", "<img " . describedby, do_shortcode( content ) ),
--                         sprintf(
--                                 "<p %sclass="wp-caption-text">%s</p>",
--                                 caption_id,
--                                 atts["caption"]
--                         )
--                 );
--         end;

--         return html;
-- end;

-- add_shortcode( "gallery", "gallery_shortcode" );

-- --
-- -- Builds the Gallery shortcode output.
-- --
-- -- This implements the functionality of the Gallery Shortcode for displaying
-- -- WordPress images on a post.
-- --
-- -- @since 2.5.0
-- -- @since 2.8.0 Added the `attr` parameter to set the shortcode output. New attributes included
-- --              such as `size`, `itemtag`, `icontag`, `captiontag`, and columns. Changed markup from
-- --              `div` tags to `dl`, `dt` and `dd` tags. Support more than one gallery on the
-- --              same page.
-- -- @since 2.9.0 Added support for `include` and `exclude` to shortcode.
-- -- @since 3.5.0 Use get_post() instead of global `post`. Handle mapping of `ids` to `include`
-- --              and `orderby`.
-- -- @since 3.6.0 Added validation for tags used in gallery shortcode. Add orientation information to items.
-- -- @since 3.7.0 Introduced the `link` attribute.
-- -- @since 3.9.0 `html5` gallery support, accepting "itemtag", "icontag", and "captiontag" attributes.
-- -- @since 4.0.0 Removed use of `extract()`.
-- -- @since 4.1.0 Added attribute to `wp_get_attachment_link()` to output `aria-describedby`.
-- -- @since 4.2.0 Passed the shortcode instance ID to `post_gallery` and `post_playlist` filters.
-- -- @since 4.6.0 Standardized filter docs to match documentation standards for PHP.
-- -- @since 5.1.0 Code cleanup for WPCS 1.0.0 coding standards.
-- -- @since 5.3.0 Saved progress of intermediate image creation after upload.
-- -- @since 5.5.0 Ensured that galleries can be output as a list of links in feeds.
-- -- @since 5.6.0 Replaced order-style PHP type conversion functions with typecasts. Fix logic for
-- --              an array of image dimensions.
-- --
-- -- @param array attr then
-- --     Attributes of the gallery shortcode.
-- --
-- --     @type string       order      Order of the images in the gallery. Default "ASC". Accepts "ASC", "DESC".
-- --     @type string       orderby    The field to use when ordering the images. Default "menu_order ID".
-- --                                    Accepts any valid SQL ORDERBY statement.
-- --     @type int          id         Post ID.
-- --     @type string       itemtag    HTML tag to use for each image in the gallery.
-- --                                    Default "dl", or "figure" when the theme registers HTML5 gallery support.
-- --     @type string       icontag    HTML tag to use for each image"s icon.
-- --                                    Default "dt", or "div" when the theme registers HTML5 gallery support.
-- --     @type string       captiontag HTML tag to use for each image"s caption.
-- --                                    Default "dd", or "figcaption" when the theme registers HTML5 gallery support.
-- --     @type int          columns    Number of columns of images to display. Default 3.
-- --     @type string|int[] size       Size of the images to display. Accepts any registered image size name, or an array
-- --                                    of width and height values in pixels (in that order). Default "thumbnail".
-- --     @type string       ids        A comma-separated list of IDs of attachments to display. Default empty.
-- --     @type string       include    A comma-separated list of IDs of attachments to include. Default empty.
-- --     @type string       exclude    A comma-separated list of IDs of attachments to exclude. Default empty.
-- --     @type string       link       What to link each image to. Default empty (links to the attachment page).
-- --                                    Accepts "file", "none".
-- -- end;
-- -- @return string HTML content to display gallery.
-- --
-- function gallery_shortcode( attr ) then
--         post = get_post();

--         static instance = 0;
--         instance++;

--         if ( not empty( attr["ids"] ) ) then
--                 -- "ids" is explicitly ordered, unless you specify otherwise.
--                 if ( empty( attr["orderby"] ) ) then
--                         attr["orderby"] = "post__in";
--                 end;
--                 attr["include"] = attr["ids"];
--         end;

--         --
--         -- Filters the default gallery shortcode output.
--         --
--         -- If the filtered output isn"t empty, it will be used instead of generating
--         -- the default gallery template.
--         --
--         -- @since 2.5.0
--         -- @since 4.2.0 The `instance` parameter was added.
--         --
--         -- @see gallery_shortcode()
--         --
--         -- @param string output   The gallery output. Default empty.
--         -- @param array  attr     Attributes of the gallery shortcode.
--         -- @param int    instance Unique numeric ID of this gallery shortcode instance.
--         --
--         output = apply_filters( "post_gallery", "", attr, instance );

--         if ( not empty( output ) ) then
--                 return output;
--         end;

--         html5 = current_theme_supports( "html5", "gallery" );
--         atts  = shortcode_atts(
--                 array(
--                         "order"      => "ASC",
--                         "orderby"    => "menu_order ID",
--                         "id"         => post ? post->ID : 0,
--                         "itemtag"    => html5 ? "figure" : "dl",
--                         "icontag"    => html5 ? "div" : "dt",
--                         "captiontag" => html5 ? "figcaption" : "dd",
--                         "columns"    => 3,
--                         "size"       => "thumbnail",
--                         "include"    => "",
--                         "exclude"    => "",
--                         "link"       => "",
--                 ),
--                 attr,
--                 "gallery"
--         );

--         id = (int) atts["id"];

--         if ( not empty( atts["include"] ) ) then
--                 _attachments = get_posts(
--                         array(
--                                 "include"        => atts["include"],
--                                 "post_status"    => "inherit",
--                                 "post_type"      => "attachment",
--                                 "post_mime_type" => "image",
--                                 "order"          => atts["order"],
--                                 "orderby"        => atts["orderby"],
--                         )
--                 );

--                 attachments = array();
--                 foreach ( _attachments as key => val ) then
--                         attachments[ val->ID ] = _attachments[ key ];
--                 end;
--         end; elseif ( not empty( atts["exclude"] ) ) then
--                 post_parent_id = id;
--                 attachments = get_children(
--                         array(
--                                 "post_parent"    => id,
--                                 "exclude"        => atts["exclude"],
--                                 "post_status"    => "inherit",
--                                 "post_type"      => "attachment",
--                                 "post_mime_type" => "image",
--                                 "order"          => atts["order"],
--                                 "orderby"        => atts["orderby"],
--                         )
--                 );
--         end; else then
--                 post_parent_id = id;
--                 attachments = get_children(
--                         array(
--                                 "post_parent"    => id,
--                                 "post_status"    => "inherit",
--                                 "post_type"      => "attachment",
--                                 "post_mime_type" => "image",
--                                 "order"          => atts["order"],
--                                 "orderby"        => atts["orderby"],
--                         )
--                 );
--         end;

--         if ( not empty( post_parent_id ) ) then
--                 post_parent = get_post( post_parent_id );

--                 -- terminate the shortcode execution if user cannot read the post or password-protected
--                 if (
--                 ( not is_post_publicly_viewable( post_parent->ID ) and then not current_user_can( "read_post", post_parent->ID ) )
--                 || post_password_required( post_parent ) ) then
--                         return "";
--                 end;
--         end;

--         if ( empty( attachments ) ) then
--                 return "";
--         end;

--         if ( is_feed() ) then
--                 output = "\n";
--                 foreach ( attachments as att_id => attachment ) then
--                         if ( not empty( atts["link"] ) ) then
--                                 if ( "none" === atts["link"] ) then
--                                         output .= wp_get_attachment_image( att_id, atts["size"], false, attr );
--                                 end; else then
--                                         output .= wp_get_attachment_link( att_id, atts["size"], false );
--                                 end;
--                         end; else then
--                                 output .= wp_get_attachment_link( att_id, atts["size"], true );
--                         end;
--                         output .= "\n";
--                 end;
--                 return output;
--         end;

--         itemtag    = tag_escape( atts["itemtag"] );
--         captiontag = tag_escape( atts["captiontag"] );
--         icontag    = tag_escape( atts["icontag"] );
--         valid_tags = wp_kses_allowed_html( "post" );
--         if ( not isset( valid_tags[ itemtag ] ) ) then
--                 itemtag = "dl";
--         end;
--         if ( not isset( valid_tags[ captiontag ] ) ) then
--                 captiontag = "dd";
--         end;
--         if ( not isset( valid_tags[ icontag ] ) ) then
--                 icontag = "dt";
--         end;

--         columns   = (int) atts["columns"];
--         itemwidth = columns > 0 ? floor( 100 / columns ) : 100;
--         float     = is_rtl() ? "right" : "left";

--         selector = "gallery-theninstanceend;";

--         gallery_style = "";

--         --
--         -- Filters whether to print default gallery styles.
--         --
--         -- @since 3.1.0
--         --
--         -- @param bool print Whether to print default gallery styles.
--         --                    Defaults to false if the theme supports HTML5 galleries.
--         --                    Otherwise, defaults to true.
--         --
--         if ( apply_filters( "use_default_gallery_style", not html5 ) ) then
--                 type_attr = current_theme_supports( "html5", "style" ) ? "" : " type="text/css"";

--                 gallery_style = "
--                 <stylethentype_attrend;>
--                         #thenselectorend; then
--                                 margin: auto;
--                         end;
--                         #thenselectorend; .gallery-item then
--                                 float: thenfloatend;;
--                                 margin-top: 10px;
--                                 text-align: center;
--                                 width: thenitemwidthend;%;
--                         end;
--                         #thenselectorend; img then
--                                 border: 2px solid #cfcfcf;
--                         end;
--                         #thenselectorend; .gallery-caption then
--                                 margin-left: 0;
--                         end;
--                         /* see gallery_shortcode() in wp-includes/media.php--
--                 </style>\n\t\t";
--         end;

--         size_class  = sanitize_html_class( is_array( atts["size"] ) ? implode( "x", atts["size"] ) : atts["size"] );
--         gallery_div = "<div id="selector" class="gallery galleryid-thenidend; gallery-columns-thencolumnsend; gallery-size-thensize_classend;">";

--         --
--         -- Filters the default gallery shortcode CSS styles.
--         --
--         -- @since 2.5.0
--         --
--         -- @param string gallery_style Default CSS styles and opening HTML div container
--         --                              for the gallery shortcode output.
--         --
--         output = apply_filters( "gallery_style", gallery_style . gallery_div );

--         i = 0;

--         foreach ( attachments as id => attachment ) then

--                 attr = ( trim( attachment->post_excerpt ) ) ? array( "aria-describedby" => "selector-id" ) : "";

--                 if ( not empty( atts["link"] ) and then "file" === atts["link"] ) then
--                         image_output = wp_get_attachment_link( id, atts["size"], false, false, false, attr );
--                 end; elseif ( not empty( atts["link"] ) and then "none" === atts["link"] ) then
--                         image_output = wp_get_attachment_image( id, atts["size"], false, attr );
--                 end; else then
--                         image_output = wp_get_attachment_link( id, atts["size"], true, false, false, attr );
--                 end;

--                 image_meta = wp_get_attachment_metadata( id );

--                 orientation = "";

--                 if ( isset( image_meta["height"], image_meta["width"] ) ) then
--                         orientation = ( image_meta["height"] > image_meta["width"] ) ? "portrait" : "landscape";
--                 end;

--                 output .= "<thenitemtagend; class="gallery-item">";
--                 output .= "
--                         <thenicontagend; class="gallery-icon thenorientationend;">
--                                 image_output
--                         </thenicontagend;>";

--                 if ( captiontag and then trim( attachment->post_excerpt ) ) then
--                         output .= "
--                                 <thencaptiontagend; class="wp-caption-text gallery-caption" id="selector-id">
--                                 " . wptexturize( attachment->post_excerpt ) . "
--                                 </thencaptiontagend;>";
--                 end;

--                 output .= "</thenitemtagend;>";

--                 if ( not html5 and then columns > 0 and then 0 === ++i % columns ) then
--                         output .= "<br style="clear: both" />";
--                 end;
--         end;

--         if ( not html5 and then columns > 0 and then 0 not== i % columns ) then
--                 output .= "
--                         <br style="clear: both" />";
--         end;

--         output .= "
--                 </div>\n";

--         return output;
-- end;

-- --
-- -- Outputs the templates used by playlists.
-- --
-- -- @since 3.9.0
-- --
-- function wp_underscore_playlist_templates() then
--         ?>
-- <script type="text/html" id="tmpl-wp-playlist-current-item">
--         <# if ( data.thumb and then data.thumb.src ) then #>
--                 <img src="thenthen data.thumb.src end;end;" alt="" />
--         <# end; #>
--         <div class="wp-playlist-caption">
--                 <span class="wp-playlist-item-meta wp-playlist-item-title">
--                 <?php
--                         /* translators: %s: Playlist item title.--
--                         printf( _x( "&#8220;%s&#8221;", "playlist item title" ), "thenthen data.title end;end;" );
--                 ?>
--                 </span>
--                 <# if ( data.meta.album ) then #><span class="wp-playlist-item-meta wp-playlist-item-album">thenthen data.meta.album end;end;</span><# end; #>
--                 <# if ( data.meta.artist ) then #><span class="wp-playlist-item-meta wp-playlist-item-artist">thenthen data.meta.artist end;end;</span><# end; #>
--         </div>
-- </script>
-- <script type="text/html" id="tmpl-wp-playlist-item">
--         <div class="wp-playlist-item">
--                 <a class="wp-playlist-caption" href="thenthen data.src end;end;">
--                         thenthen data.index ? ( data.index + ". " ) : "" end;end;
--                         <# if ( data.caption ) then #>
--                                 thenthen data.caption end;end;
--                         <# end; else then #>
--                                 <span class="wp-playlist-item-title">
--                                 <?php
--                                         /* translators: %s: Playlist item title.--
--                                         printf( _x( "&#8220;%s&#8221;", "playlist item title" ), "thenthenthen data.title end;end;end;" );
--                                 ?>
--                                 </span>
--                                 <# if ( data.artists and then data.meta.artist ) then #>
--                                 <span class="wp-playlist-item-artist"> &mdash; thenthen data.meta.artist end;end;</span>
--                                 <# end; #>
--                         <# end; #>
--                 </a>
--                 <# if ( data.meta.length_formatted ) then #>
--                 <div class="wp-playlist-item-length">thenthen data.meta.length_formatted end;end;</div>
--                 <# end; #>
--         </div>
-- </script>
--         <?php
-- end;

-- --
-- -- Outputs and enqueues default scripts and styles for playlists.
-- --
-- -- @since 3.9.0
-- --
-- -- @param string type Type of playlist. Accepts "audio" or "video".
-- --
-- function wp_playlist_scripts( type ) then
--         wp_enqueue_style( "wp-mediaelement" );
--         wp_enqueue_script( "wp-playlist" );
--         ?>
-- <not--[if lt IE 9]><script>document.createElement("<?php echo esc_js( type ); ?>");</script><not[endif]-->
--         <?php
--         add_action( "wp_footer", "wp_underscore_playlist_templates", 0 );
--         add_action( "admin_footer", "wp_underscore_playlist_templates", 0 );
-- end;

-- --
-- -- Builds the Playlist shortcode output.
-- --
-- -- This implements the functionality of the playlist shortcode for displaying
-- -- a collection of WordPress audio or video files in a post.
-- --
-- -- @since 3.9.0
-- --
-- -- @global int content_width
-- --
-- -- @param array attr then
-- --     Array of default playlist attributes.
-- --
-- --     @type string  type         Type of playlist to display. Accepts "audio" or "video". Default "audio".
-- --     @type string  order        Designates ascending or descending order of items in the playlist.
-- --                                 Accepts "ASC", "DESC". Default "ASC".
-- --     @type string  orderby      Any column, or columns, to sort the playlist. If ids are
-- --                                 passed, this defaults to the order of the ids array ("post__in").
-- --                                 Otherwise default is "menu_order ID".
-- --     @type int     id           If an explicit ids array is not present, this parameter
-- --                                 will determine which attachments are used for the playlist.
-- --                                 Default is the current post ID.
-- --     @type array   ids          Create a playlist out of these explicit attachment IDs. If empty,
-- --                                 a playlist will be created from all type attachments of id.
-- --                                 Default empty.
-- --     @type array   exclude      List of specific attachment IDs to exclude from the playlist. Default empty.
-- --     @type string  style        Playlist style to use. Accepts "light" or "dark". Default "light".
-- --     @type bool    tracklist    Whether to show or hide the playlist. Default true.
-- --     @type bool    tracknumbers Whether to show or hide the numbers next to entries in the playlist. Default true.
-- --     @type bool    images       Show or hide the video or audio thumbnail (Featured Image/post
-- --                                 thumbnail). Default true.
-- --     @type bool    artists      Whether to show or hide artist name in the playlist. Default true.
-- -- end;
-- --
-- -- @return string Playlist output. Empty string if the passed type is unsupported.
-- --
-- function wp_playlist_shortcode( attr ) then
--         global content_width;
--         post = get_post();

--         static instance = 0;
--         instance++;

--         if ( not empty( attr["ids"] ) ) then
--                 -- "ids" is explicitly ordered, unless you specify otherwise.
--                 if ( empty( attr["orderby"] ) ) then
--                         attr["orderby"] = "post__in";
--                 end;
--                 attr["include"] = attr["ids"];
--         end;

--         --
--         -- Filters the playlist output.
--         --
--         -- Returning a non-empty value from the filter will short-circuit generation
--         -- of the default playlist output, returning the passed value instead.
--         --
--         -- @since 3.9.0
--         -- @since 4.2.0 The `instance` parameter was added.
--         --
--         -- @param string output   Playlist output. Default empty.
--         -- @param array  attr     An array of shortcode attributes.
--         -- @param int    instance Unique numeric ID of this playlist shortcode instance.
--         --
--         output = apply_filters( "post_playlist", "", attr, instance );

--         if ( not empty( output ) ) then
--                 return output;
--         end;

--         atts = shortcode_atts(
--                 array(
--                         "type"         => "audio",
--                         "order"        => "ASC",
--                         "orderby"      => "menu_order ID",
--                         "id"           => post ? post->ID : 0,
--                         "include"      => "",
--                         "exclude"      => "",
--                         "style"        => "light",
--                         "tracklist"    => true,
--                         "tracknumbers" => true,
--                         "images"       => true,
--                         "artists"      => true,
--                 ),
--                 attr,
--                 "playlist"
--         );

--         id = (int) atts["id"];

--         if ( "audio" not== atts["type"] ) then
--                 atts["type"] = "video";
--         end;

--         args = array(
--                 "post_status"    => "inherit",
--                 "post_type"      => "attachment",
--                 "post_mime_type" => atts["type"],
--                 "order"          => atts["order"],
--                 "orderby"        => atts["orderby"],
--         );

--         if ( not empty( atts["include"] ) ) then
--                 args["include"] = atts["include"];
--                 _attachments    = get_posts( args );

--                 attachments = array();
--                 foreach ( _attachments as key => val ) then
--                         attachments[ val->ID ] = _attachments[ key ];
--                 end;
--         end; elseif ( not empty( atts["exclude"] ) ) then
--                 args["post_parent"] = id;
--                 args["exclude"]     = atts["exclude"];
--                 attachments         = get_children( args );
--         end; else then
--                 args["post_parent"] = id;
--                 attachments         = get_children( args );
--         end;

--         if ( not empty( args["post_parent"] ) ) then
--                 post_parent = get_post( id );

--                 -- terminate the shortcode execution if user cannot read the post or password-protected
--                 if ( not current_user_can( "read_post", post_parent->ID ) || post_password_required( post_parent ) ) then
--                         return "";
--                 end;
--         end;

--         if ( empty( attachments ) ) then
--                 return "";
--         end;

--         if ( is_feed() ) then
--                 output = "\n";
--                 foreach ( attachments as att_id => attachment ) then
--                         output .= wp_get_attachment_link( att_id ) . "\n";
--                 end;
--                 return output;
--         end;

--         outer = 22; -- Default padding and border of wrapper.

--         default_width  = 640;
--         default_height = 360;

--         theme_width  = empty( content_width ) ? default_width : ( content_width - outer );
--         theme_height = empty( content_width ) ? default_height : round( ( default_height-- theme_width ) / default_width );

--         data = array(
--                 "type"         => atts["type"],
--                 -- Don"t pass strings to JSON, will be truthy in JS.
--                 "tracklist"    => wp_validate_boolean( atts["tracklist"] ),
--                 "tracknumbers" => wp_validate_boolean( atts["tracknumbers"] ),
--                 "images"       => wp_validate_boolean( atts["images"] ),
--                 "artists"      => wp_validate_boolean( atts["artists"] ),
--         );

--         tracks = array();
--         foreach ( attachments as attachment ) then
--                 url   = wp_get_attachment_url( attachment->ID );
--                 ftype = wp_check_filetype( url, wp_get_mime_types() );
--                 track = array(
--                         "src"         => url,
--                         "type"        => ftype["type"],
--                         "title"       => attachment->post_title,
--                         "caption"     => attachment->post_excerpt,
--                         "description" => attachment->post_content,
--                 );

--                 track["meta"] = array();
--                 meta          = wp_get_attachment_metadata( attachment->ID );
--                 if ( not empty( meta ) ) then

--                         foreach ( wp_get_attachment_id3_keys( attachment ) as key => label ) then
--                                 if ( not empty( meta[ key ] ) ) then
--                                         track["meta"][ key ] = meta[ key ];
--                                 end;
--                         end;

--                         if ( "video" === atts["type"] ) then
--                                 if ( not empty( meta["width"] ) and then not empty( meta["height"] ) ) then
--                                         width        = meta["width"];
--                                         height       = meta["height"];
--                                         theme_height = round( ( height-- theme_width ) / width );
--                                 end; else then
--                                         width  = default_width;
--                                         height = default_height;
--                                 end;

--                                 track["dimensions"] = array(
--                                         "original" => compact( "width", "height" ),
--                                         "resized"  => array(
--                                                 "width"  => theme_width,
--                                                 "height" => theme_height,
--                                         ),
--                                 );
--                         end;
--                 end;

--                 if ( atts["images"] ) then
--                         thumb_id = get_post_thumbnail_id( attachment->ID );
--                         if ( not empty( thumb_id ) ) then
--                                 list( src, width, height ) = wp_get_attachment_image_src( thumb_id, "full" );
--                                 track["image"]               = compact( "src", "width", "height" );
--                                 list( src, width, height ) = wp_get_attachment_image_src( thumb_id, "thumbnail" );
--                                 track["thumb"]               = compact( "src", "width", "height" );
--                         end; else then
--                                 src            = wp_mime_type_icon( attachment->ID );
--                                 width          = 48;
--                                 height         = 64;
--                                 track["image"] = compact( "src", "width", "height" );
--                                 track["thumb"] = compact( "src", "width", "height" );
--                         end;
--                 end;

--                 tracks[] = track;
--         end;
--         data["tracks"] = tracks;

--         safe_type  = esc_attr( atts["type"] );
--         safe_style = esc_attr( atts["style"] );

--         ob_start();

--         if ( 1 === instance ) then
--                 --
--                 -- Prints and enqueues playlist scripts, styles, and JavaScript templates.
--                 --
--                 -- @since 3.9.0
--                 --
--                 -- @param string type  Type of playlist. Possible values are "audio" or "video".
--                 -- @param string style The "theme" for the playlist. Core provides "light" and "dark".
--                 --
--                 do_action( "wp_playlist_scripts", atts["type"], atts["style"] );
--         end;
--         ?>
-- <div class="wp-playlist wp-<?php echo safe_type; ?>-playlist wp-playlist-<?php echo safe_style; ?>">
--         <?php if ( "audio" === atts["type"] ) : ?>
--                 <div class="wp-playlist-current-item"></div>
--         <?php endif; ?>
--         <<?php echo safe_type; ?> controls="controls" preload="none" width="<?php echo (int) theme_width; ?>"
--                 <?php
--                 if ( "video" === safe_type ) then
--                         echo " height="", (int) theme_height, """;
--                 end;
--                 ?>
--         ></<?php echo safe_type; ?>>
--         <div class="wp-playlist-next"></div>
--         <div class="wp-playlist-prev"></div>
--         <noscript>
--         <ol>
--                 <?php
--                 foreach ( attachments as att_id => attachment ) then
--                         printf( "<li>%s</li>", wp_get_attachment_link( att_id ) );
--                 end;
--                 ?>
--         </ol>
--         </noscript>
--         <script type="application/json" class="wp-playlist-script"><?php echo wp_json_encode( data ); ?></script>
-- </div>
--         <?php
--         return ob_get_clean();
-- end;
-- add_shortcode( "playlist", "wp_playlist_shortcode" );

-- --
-- -- Provides a No-JS Flash fallback as a last resort for audio / video.
-- --
-- -- @since 3.6.0
-- --
-- -- @param string url The media element URL.
-- -- @return string Fallback HTML.
-- --
-- function wp_mediaelement_fallback( url ) then
--         --
--         -- Filters the Mediaelement fallback output for no-JS.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string output Fallback output for no-JS.
--         -- @param string url    Media file URL.
--         --
--         return apply_filters( "wp_mediaelement_fallback", sprintf( "<a href="%1s">%1s</a>", esc_url( url ) ), url );
-- end;

-- --
-- -- Returns a filtered list of supported audio formats.
-- --
-- -- @since 3.6.0
-- --
-- -- @return string[] Supported audio formats.
-- --
-- function wp_get_audio_extensions() then
--         --
--         -- Filters the list of supported audio formats.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string[] extensions An array of supported audio formats. Defaults are
--         --                            "mp3", "ogg", "flac", "m4a", "wav".
--         --
--         return apply_filters( "wp_audio_extensions", array( "mp3", "ogg", "flac", "m4a", "wav" ) );
-- end;

-- --
-- -- Returns useful keys to use to lookup data from an attachment"s stored metadata.
-- --
-- -- @since 3.9.0
-- --
-- -- @param WP_Post attachment The current attachment, provided for context.
-- -- @param string  context    Optional. The context. Accepts "edit", "display". Default "display".
-- -- @return string[] Key/value pairs of field keys to labels.
-- --
-- function wp_get_attachment_id3_keys( attachment, context = "display" ) then
--         fields = array(
--                 "artist" => __( "Artist" ),
--                 "album"  => __( "Album" ),
--         );

--         if ( "display" === context ) then
--                 fields["genre"]            = __( "Genre" );
--                 fields["year"]             = __( "Year" );
--                 fields["length_formatted"] = _x( "Length", "video or audio" );
--         end; elseif ( "js" === context ) then
--                 fields["bitrate"]      = __( "Bitrate" );
--                 fields["bitrate_mode"] = __( "Bitrate Mode" );
--         end;

--         --
--         -- Filters the editable list of keys to look up data from an attachment"s metadata.
--         --
--         -- @since 3.9.0
--         --
--         -- @param array   fields     Key/value pairs of field keys to labels.
--         -- @param WP_Post attachment Attachment object.
--         -- @param string  context    The context. Accepts "edit", "display". Default "display".
--         --
--         return apply_filters( "wp_get_attachment_id3_keys", fields, attachment, context );
-- end;
-- --
-- -- Builds the Audio shortcode output.
-- --
-- -- This implements the functionality of the Audio Shortcode for displaying
-- -- WordPress mp3s in a post.
-- --
-- -- @since 3.6.0
-- --
-- -- @param array  attr then
-- --     Attributes of the audio shortcode.
-- --
-- --     @type string src      URL to the source of the audio file. Default empty.
-- --     @type string loop     The "loop" attribute for the `<audio>` element. Default empty.
-- --     @type string autoplay The "autoplay" attribute for the `<audio>` element. Default empty.
-- --     @type string preload  The "preload" attribute for the `<audio>` element. Default "none".
-- --     @type string class    The "class" attribute for the `<audio>` element. Default "wp-audio-shortcode".
-- --     @type string style    The "style" attribute for the `<audio>` element. Default "width: 100%;".
-- -- end;
-- -- @param string content Shortcode content.
-- -- @return string|void HTML content to display audio.
-- --
-- function wp_audio_shortcode( attr, content = "" ) then
--         post_id = get_post() ? get_the_ID() : 0;

--         static instance = 0;
--         instance++;

--         --
--         -- Filters the default audio shortcode output.
--         --
--         -- If the filtered output isn"t empty, it will be used instead of generating the default audio template.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string html     Empty variable to be replaced with shortcode markup.
--         -- @param array  attr     Attributes of the shortcode. @see wp_audio_shortcode()
--         -- @param string content  Shortcode content.
--         -- @param int    instance Unique numeric ID of this audio shortcode instance.
--         --
--         override = apply_filters( "wp_audio_shortcode_override", "", attr, content, instance );

--         if ( "" not== override ) then
--                 return override;
--         end;

--         audio = null;

--         default_types = wp_get_audio_extensions();
--         defaults_atts = array(
--                 "src"      => "",
--                 "loop"     => "",
--                 "autoplay" => "",
--                 "preload"  => "none",
--                 "class"    => "wp-audio-shortcode",
--                 "style"    => "width: 100%;",
--         );
--         foreach ( default_types as type ) then
--                 defaults_atts[ type ] = "";
--         end;

--         atts = shortcode_atts( defaults_atts, attr, "audio" );

--         primary = false;
--         if ( not empty( atts["src"] ) ) then
--                 type = wp_check_filetype( atts["src"], wp_get_mime_types() );

--                 if ( not in_array( strtolower( type["ext"] ), default_types, true ) ) then
--                         return sprintf( "<a class="wp-embedded-audio" href="%s">%s</a>", esc_url( atts["src"] ), esc_html( atts["src"] ) );
--                 end;

--                 primary = true;
--                 array_unshift( default_types, "src" );
--         end; else then
--                 foreach ( default_types as ext ) then
--                         if ( not empty( atts[ ext ] ) ) then
--                                 type = wp_check_filetype( atts[ ext ], wp_get_mime_types() );

--                                 if ( strtolower( type["ext"] ) === ext ) then
--                                         primary = true;
--                                 end;
--                         end;
--                 end;
--         end;

--         if ( not primary ) then
--                 audios = get_attached_media( "audio", post_id );

--                 if ( empty( audios ) ) then
--                         return;
--                 end;

--                 audio       = reset( audios );
--                 atts["src"] = wp_get_attachment_url( audio->ID );

--                 if ( empty( atts["src"] ) ) then
--                         return;
--                 end;

--                 array_unshift( default_types, "src" );
--         end;

--         --
--         -- Filters the media library used for the audio shortcode.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string library Media library used for the audio shortcode.
--         --
--         library = apply_filters( "wp_audio_shortcode_library", "mediaelement" );

--         if ( "mediaelement" === library and then did_action( "init" ) ) then
--                 wp_enqueue_style( "wp-mediaelement" );
--                 wp_enqueue_script( "wp-mediaelement" );
--         end;

--         --
--         -- Filters the class attribute for the audio shortcode output container.
--         --
--         -- @since 3.6.0
--         -- @since 4.9.0 The `atts` parameter was added.
--         --
--         -- @param string class CSS class or list of space-separated classes.
--         -- @param array  atts  Array of audio shortcode attributes.
--         --
--         atts["class"] = apply_filters( "wp_audio_shortcode_class", atts["class"], atts );

--         html_atts = array(
--                 "class"    => atts["class"],
--                 "id"       => sprintf( "audio-%d-%d", post_id, instance ),
--                 "loop"     => wp_validate_boolean( atts["loop"] ),
--                 "autoplay" => wp_validate_boolean( atts["autoplay"] ),
--                 "preload"  => atts["preload"],
--                 "style"    => atts["style"],
--         );

--         -- These ones should just be omitted altogether if they are blank.
--         foreach ( array( "loop", "autoplay", "preload" ) as a ) then
--                 if ( empty( html_atts[ a ] ) ) then
--                         unset( html_atts[ a ] );
--                 end;
--         end;

--         attr_strings = array();

--         foreach ( html_atts as k => v ) then
--                 attr_strings[] = k . "="" . esc_attr( v ) . """;
--         end;

--         html = "";

--         if ( "mediaelement" === library and then 1 === instance ) then
--                 html .= "<not--[if lt IE 9]><script>document.createElement("audio");</script><not[endif]-->\n";
--         end;

--         html .= sprintf( "<audio %s controls="controls">", implode( " ", attr_strings ) );

--         fileurl = "";
--         source  = "<source type="%s" src="%s" />";

--         foreach ( default_types as fallback ) then
--                 if ( not empty( atts[ fallback ] ) ) then
--                         if ( empty( fileurl ) ) then
--                                 fileurl = atts[ fallback ];
--                         end;

--                         type  = wp_check_filetype( atts[ fallback ], wp_get_mime_types() );
--                         url   = add_query_arg( "_", instance, atts[ fallback ] );
--                         html .= sprintf( source, type["type"], esc_url( url ) );
--                 end;
--         end;

--         if ( "mediaelement" === library ) then
--                 html .= wp_mediaelement_fallback( fileurl );
--         end;

--         html .= "</audio>";

--         --
--         -- Filters the audio shortcode output.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string html    Audio shortcode HTML output.
--         -- @param array  atts    Array of audio shortcode attributes.
--         -- @param string audio   Audio file.
--         -- @param int    post_id Post ID.
--         -- @param string library Media library used for the audio shortcode.
--         --
--         return apply_filters( "wp_audio_shortcode", html, atts, audio, post_id, library );
-- end;
-- add_shortcode( "audio", "wp_audio_shortcode" );

-- --
-- -- Returns a filtered list of supported video formats.
-- --
-- -- @since 3.6.0
-- --
-- -- @return string[] List of supported video formats.
-- --
-- function wp_get_video_extensions() then
--         --
--         -- Filters the list of supported video formats.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string[] extensions An array of supported video formats. Defaults are
--         --                             "mp4", "m4v", "webm", "ogv", "flv".
--         --
--         return apply_filters( "wp_video_extensions", array( "mp4", "m4v", "webm", "ogv", "flv" ) );
-- end;

-- --
-- -- Builds the Video shortcode output.
-- --
-- -- This implements the functionality of the Video Shortcode for displaying
-- -- WordPress mp4s in a post.
-- --
-- -- @since 3.6.0
-- --
-- -- @global int content_width
-- --
-- -- @param array  attr then
-- --     Attributes of the shortcode.
-- --
-- --     @type string src      URL to the source of the video file. Default empty.
-- --     @type int    height   Height of the video embed in pixels. Default 360.
-- --     @type int    width    Width of the video embed in pixels. Default content_width or 640.
-- --     @type string poster   The "poster" attribute for the `<video>` element. Default empty.
-- --     @type string loop     The "loop" attribute for the `<video>` element. Default empty.
-- --     @type string autoplay The "autoplay" attribute for the `<video>` element. Default empty.
-- --     @type string muted    The "muted" attribute for the `<video>` element. Default false.
-- --     @type string preload  The "preload" attribute for the `<video>` element.
-- --                            Default "metadata".
-- --     @type string class    The "class" attribute for the `<video>` element.
-- --                            Default "wp-video-shortcode".
-- -- end;
-- -- @param string content Shortcode content.
-- -- @return string|void HTML content to display video.
-- --
-- function wp_video_shortcode( attr, content = "" ) then
--         global content_width;
--         post_id = get_post() ? get_the_ID() : 0;

--         static instance = 0;
--         instance++;

--         --
--         -- Filters the default video shortcode output.
--         --
--         -- If the filtered output isn"t empty, it will be used instead of generating
--         -- the default video template.
--         --
--         -- @since 3.6.0
--         --
--         -- @see wp_video_shortcode()
--         --
--         -- @param string html     Empty variable to be replaced with shortcode markup.
--         -- @param array  attr     Attributes of the shortcode. @see wp_video_shortcode()
--         -- @param string content  Video shortcode content.
--         -- @param int    instance Unique numeric ID of this video shortcode instance.
--         --
--         override = apply_filters( "wp_video_shortcode_override", "", attr, content, instance );

--         if ( "" not== override ) then
--                 return override;
--         end;

--         video = null;

--         default_types = wp_get_video_extensions();
--         defaults_atts = array(
--                 "src"      => "",
--                 "poster"   => "",
--                 "loop"     => "",
--                 "autoplay" => "",
--                 "muted"    => "false",
--                 "preload"  => "metadata",
--                 "width"    => 640,
--                 "height"   => 360,
--                 "class"    => "wp-video-shortcode",
--         );

--         foreach ( default_types as type ) then
--                 defaults_atts[ type ] = "";
--         end;

--         atts = shortcode_atts( defaults_atts, attr, "video" );

--         if ( is_admin() ) then
--                 -- Shrink the video so it isn"t huge in the admin.
--                 if ( atts["width"] > defaults_atts["width"] ) then
--                         atts["height"] = round( ( atts["height"]-- defaults_atts["width"] ) / atts["width"] );
--                         atts["width"]  = defaults_atts["width"];
--                 end;
--         end; else then
--                 -- If the video is bigger than the theme.
--                 if ( not empty( content_width ) and then atts["width"] > content_width ) then
--                         atts["height"] = round( ( atts["height"]-- content_width ) / atts["width"] );
--                         atts["width"]  = content_width;
--                 end;
--         end;

--         is_vimeo      = false;
--         is_youtube    = false;
--         yt_pattern    = "#^https?:--(?:www\.)?(?:youtube\.com/watch|youtu\.be/)#";
--         vimeo_pattern = "#^https?:--(.+\.)?vimeo\.com/.*#";

--         primary = false;
--         if ( not empty( atts["src"] ) ) then
--                 is_vimeo   = ( preg_match( vimeo_pattern, atts["src"] ) );
--                 is_youtube = ( preg_match( yt_pattern, atts["src"] ) );

--                 if ( not is_youtube and then not is_vimeo ) then
--                         type = wp_check_filetype( atts["src"], wp_get_mime_types() );

--                         if ( not in_array( strtolower( type["ext"] ), default_types, true ) ) then
--                                 return sprintf( "<a class="wp-embedded-video" href="%s">%s</a>", esc_url( atts["src"] ), esc_html( atts["src"] ) );
--                         end;
--                 end;

--                 if ( is_vimeo ) then
--                         wp_enqueue_script( "mediaelement-vimeo" );
--                 end;

--                 primary = true;
--                 array_unshift( default_types, "src" );
--         end; else then
--                 foreach ( default_types as ext ) then
--                         if ( not empty( atts[ ext ] ) ) then
--                                 type = wp_check_filetype( atts[ ext ], wp_get_mime_types() );
--                                 if ( strtolower( type["ext"] ) === ext ) then
--                                         primary = true;
--                                 end;
--                         end;
--                 end;
--         end;

--         if ( not primary ) then
--                 videos = get_attached_media( "video", post_id );
--                 if ( empty( videos ) ) then
--                         return;
--                 end;

--                 video       = reset( videos );
--                 atts["src"] = wp_get_attachment_url( video->ID );
--                 if ( empty( atts["src"] ) ) then
--                         return;
--                 end;

--                 array_unshift( default_types, "src" );
--         end;

--         --
--         -- Filters the media library used for the video shortcode.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string library Media library used for the video shortcode.
--         --
--         library = apply_filters( "wp_video_shortcode_library", "mediaelement" );
--         if ( "mediaelement" === library and then did_action( "init" ) ) then
--                 wp_enqueue_style( "wp-mediaelement" );
--                 wp_enqueue_script( "wp-mediaelement" );
--                 wp_enqueue_script( "mediaelement-vimeo" );
--         end;

--         -- MediaElement.js has issues with some URL formats for Vimeo and YouTube,
--         -- so update the URL to prevent the ME.js player from breaking.
--         if ( "mediaelement" === library ) then
--                 if ( is_youtube ) then
--                         -- Remove `feature` query arg and force SSL - see #40866.
--                         atts["src"] = remove_query_arg( "feature", atts["src"] );
--                         atts["src"] = set_url_scheme( atts["src"], "https" );
--                 end; elseif ( is_vimeo ) then
--                         -- Remove all query arguments and force SSL - see #40866.
--                         parsed_vimeo_url = wp_parse_url( atts["src"] );
--                         vimeo_src        = "https://" . parsed_vimeo_url["host"] . parsed_vimeo_url["path"];

--                         -- Add loop param for mejs bug - see #40977, not needed after #39686.
--                         loop        = atts["loop"] ? "1" : "0";
--                         atts["src"] = add_query_arg( "loop", loop, vimeo_src );
--                 end;
--         end;

--         --
--         -- Filters the class attribute for the video shortcode output container.
--         --
--         -- @since 3.6.0
--         -- @since 4.9.0 The `atts` parameter was added.
--         --
--         -- @param string class CSS class or list of space-separated classes.
--         -- @param array  atts  Array of video shortcode attributes.
--         --
--         atts["class"] = apply_filters( "wp_video_shortcode_class", atts["class"], atts );

--         html_atts = array(
--                 "class"    => atts["class"],
--                 "id"       => sprintf( "video-%d-%d", post_id, instance ),
--                 "width"    => absint( atts["width"] ),
--                 "height"   => absint( atts["height"] ),
--                 "poster"   => esc_url( atts["poster"] ),
--                 "loop"     => wp_validate_boolean( atts["loop"] ),
--                 "autoplay" => wp_validate_boolean( atts["autoplay"] ),
--                 "muted"    => wp_validate_boolean( atts["muted"] ),
--                 "preload"  => atts["preload"],
--         );

--         -- These ones should just be omitted altogether if they are blank.
--         foreach ( array( "poster", "loop", "autoplay", "preload", "muted" ) as a ) then
--                 if ( empty( html_atts[ a ] ) ) then
--                         unset( html_atts[ a ] );
--                 end;
--         end;

--         attr_strings = array();
--         foreach ( html_atts as k => v ) then
--                 attr_strings[] = k . "="" . esc_attr( v ) . """;
--         end;

--         html = "";

--         if ( "mediaelement" === library and then 1 === instance ) then
--                 html .= "<not--[if lt IE 9]><script>document.createElement("video");</script><not[endif]-->\n";
--         end;

--         html .= sprintf( "<video %s controls="controls">", implode( " ", attr_strings ) );

--         fileurl = "";
--         source  = "<source type="%s" src="%s" />";

--         foreach ( default_types as fallback ) then
--                 if ( not empty( atts[ fallback ] ) ) then
--                         if ( empty( fileurl ) ) then
--                                 fileurl = atts[ fallback ];
--                         end;
--                         if ( "src" === fallback and then is_youtube ) then
--                                 type = array( "type" => "video/youtube" );
--                         end; elseif ( "src" === fallback and then is_vimeo ) then
--                                 type = array( "type" => "video/vimeo" );
--                         end; else then
--                                 type = wp_check_filetype( atts[ fallback ], wp_get_mime_types() );
--                         end;
--                         url   = add_query_arg( "_", instance, atts[ fallback ] );
--                         html .= sprintf( source, type["type"], esc_url( url ) );
--                 end;
--         end;

--         if ( not empty( content ) ) then
--                 if ( false not== strpos( content, "\n" ) ) then
--                         content = str_replace( array( "\r\n", "\n", "\t" ), "", content );
--                 end;
--                 html .= trim( content );
--         end;

--         if ( "mediaelement" === library ) then
--                 html .= wp_mediaelement_fallback( fileurl );
--         end;
--         html .= "</video>";

--         width_rule = "";
--         if ( not empty( atts["width"] ) ) then
--                 width_rule = sprintf( "width: %dpx;", atts["width"] );
--         end;
--         output = sprintf( "<div style="%s" class="wp-video">%s</div>", width_rule, html );

--         --
--         -- Filters the output of the video shortcode.
--         --
--         -- @since 3.6.0
--         --
--         -- @param string output  Video shortcode HTML output.
--         -- @param array  atts    Array of video shortcode attributes.
--         -- @param string video   Video file.
--         -- @param int    post_id Post ID.
--         -- @param string library Media library used for the video shortcode.
--         --
--         return apply_filters( "wp_video_shortcode", output, atts, video, post_id, library );
-- end;
-- add_shortcode( "video", "wp_video_shortcode" );

-- --
-- -- Gets the previous image link that has the same post parent.
-- --
-- -- @since 5.8.0
-- --
-- -- @see get_adjacent_image_link()
-- --
-- -- @param string|int[] size Optional. Image size. Accepts any registered image size name, or an array
-- --                           of width and height values in pixels (in that order). Default "thumbnail".
-- -- @param string|false text Optional. Link text. Default false.
-- -- @return string Markup for previous image link.
-- --
-- function get_previous_image_link( size = "thumbnail", text = false ) then
--         return get_adjacent_image_link( true, size, text );
-- end;

-- --
-- -- Displays previous image link that has the same post parent.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string|int[] size Optional. Image size. Accepts any registered image size name, or an array
-- --                           of width and height values in pixels (in that order). Default "thumbnail".
-- -- @param string|false text Optional. Link text. Default false.
-- --
-- function previous_image_link( size = "thumbnail", text = false ) then
--         echo get_previous_image_link( size, text );
-- end;

-- --
-- -- Gets the next image link that has the same post parent.
-- --
-- -- @since 5.8.0
-- --
-- -- @see get_adjacent_image_link()
-- --
-- -- @param string|int[] size Optional. Image size. Accepts any registered image size name, or an array
-- --                           of width and height values in pixels (in that order). Default "thumbnail".
-- -- @param string|false text Optional. Link text. Default false.
-- -- @return string Markup for next image link.
-- --
-- function get_next_image_link( size = "thumbnail", text = false ) then
--         return get_adjacent_image_link( false, size, text );
-- end;

-- --
-- -- Displays next image link that has the same post parent.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string|int[] size Optional. Image size. Accepts any registered image size name, or an array
-- --                           of width and height values in pixels (in that order). Default "thumbnail".
-- -- @param string|false text Optional. Link text. Default false.
-- --
-- function next_image_link( size = "thumbnail", text = false ) then
--         echo get_next_image_link( size, text );
-- end;

-- --
-- -- Gets the next or previous image link that has the same post parent.
-- --
-- -- Retrieves the current attachment object from the post global.
-- --
-- -- @since 5.8.0
-- --
-- -- @param bool         prev Optional. Whether to display the next (false) or previous (true) link. Default true.
-- -- @param string|int[] size Optional. Image size. Accepts any registered image size name, or an array
-- --                           of width and height values in pixels (in that order). Default "thumbnail".
-- -- @param bool         text Optional. Link text. Default false.
-- -- @return string Markup for image link.
-- --
-- function get_adjacent_image_link( prev = true, size = "thumbnail", text = false ) then
--         post        = get_post();
--         attachments = array_values(
--                 get_children(
--                         array(
--                                 "post_parent"    => post->post_parent,
--                                 "post_status"    => "inherit",
--                                 "post_type"      => "attachment",
--                                 "post_mime_type" => "image",
--                                 "order"          => "ASC",
--                                 "orderby"        => "menu_order ID",
--                         )
--                 )
--         );

--         foreach ( attachments as k => attachment ) then
--                 if ( (int) attachment->ID === (int) post->ID ) then
--                         break;
--                 end;
--         end;

--         output        = "";
--         attachment_id = 0;

--         if ( attachments ) then
--                 k = prev ? k - 1 : k + 1;

--                 if ( isset( attachments[ k ] ) ) then
--                         attachment_id = attachments[ k ]->ID;
--                         attr          = array( "alt" => get_the_title( attachment_id ) );
--                         output        = wp_get_attachment_link( attachment_id, size, true, false, text, attr );
--                 end;
--         end;

--         adjacent = prev ? "previous" : "next";

--         --
--         -- Filters the adjacent image link.
--         --
--         -- The dynamic portion of the hook name, `adjacent`, refers to the type of adjacency,
--         -- either "next", or "previous".
--         --
--         -- Possible hook names include:
--         --
--         --  - `next_image_link`
--         --  - `previous_image_link`
--         --
--         -- @since 3.5.0
--         --
--         -- @param string output        Adjacent image HTML markup.
--         -- @param int    attachment_id Attachment ID
--         -- @param string|int[] size    Requested image size. Can be any registered image size name, or
--         --                              an array of width and height values in pixels (in that order).
--         -- @param string text          Link text.
--         --
--         return apply_filters( "thenadjacentend;_image_link", output, attachment_id, size, text );
-- end;

-- --
-- -- Displays next or previous image link that has the same post parent.
-- --
-- -- Retrieves the current attachment object from the post global.
-- --
-- -- @since 2.5.0
-- --
-- -- @param bool         prev Optional. Whether to display the next (false) or previous (true) link. Default true.
-- -- @param string|int[] size Optional. Image size. Accepts any registered image size name, or an array
-- --                           of width and height values in pixels (in that order). Default "thumbnail".
-- -- @param bool         text Optional. Link text. Default false.
-- --
-- function adjacent_image_link( prev = true, size = "thumbnail", text = false ) then
--         echo get_adjacent_image_link( prev, size, text );
-- end;

-- --
-- -- Retrieves taxonomies attached to given the attachment.
-- --
-- -- @since 2.5.0
-- -- @since 4.7.0 Introduced the `output` parameter.
-- --
-- -- @param int|array|object attachment Attachment ID, data array, or data object.
-- -- @param string           output     Output type. "names" to return an array of taxonomy names,
-- --                                     or "objects" to return an array of taxonomy objects.
-- --                                     Default is "names".
-- -- @return string[]|WP_Taxonomy[] List of taxonomies or taxonomy names. Empty array on failure.
-- --
-- function get_attachment_taxonomies( attachment, output = "names" ) then
--         if ( is_int( attachment ) ) then
--                 attachment = get_post( attachment );
--         end; elseif ( is_array( attachment ) ) then
--                 attachment = (object) attachment;
--         end;

--         if ( not is_object( attachment ) ) then
--                 return array();
--         end;

--         file     = get_attached_file( attachment->ID );
--         filename = wp_basename( file );

--         objects = array( "attachment" );

--         if ( false not== strpos( filename, "." ) ) then
--                 objects[] = "attachment:" . substr( filename, strrpos( filename, "." ) + 1 );
--         end;

--         if ( not empty( attachment->post_mime_type ) ) then
--                 objects[] = "attachment:" . attachment->post_mime_type;

--                 if ( false not== strpos( attachment->post_mime_type, "/" ) ) then
--                         foreach ( explode( "/", attachment->post_mime_type ) as token ) then
--                                 if ( not empty( token ) ) then
--                                         objects[] = "attachment:token";
--                                 end;
--                         end;
--                 end;
--         end;

--         taxonomies = array();

--         foreach ( objects as object ) then
--                 taxes = get_object_taxonomies( object, output );

--                 if ( taxes ) then
--                         taxonomies = array_merge( taxonomies, taxes );
--                 end;
--         end;

--         if ( "names" === output ) then
--                 taxonomies = array_unique( taxonomies );
--         end;

--         return taxonomies;
-- end;

-- --
-- -- Retrieves all of the taxonomies that are registered for attachments.
-- --
-- -- Handles mime-type-specific taxonomies such as attachment:image and attachment:video.
-- --
-- -- @since 3.5.0
-- --
-- -- @see get_taxonomies()
-- --
-- -- @param string output Optional. The type of taxonomy output to return. Accepts "names" or "objects".
-- --                       Default "names".
-- -- @return string[]|WP_Taxonomy[] Array of names or objects of registered taxonomies for attachments.
-- --
-- function get_taxonomies_for_attachments( output = "names" ) then
--         taxonomies = array();

--         foreach ( get_taxonomies( array(), "objects" ) as taxonomy ) then
--                 foreach ( taxonomy->object_type as object_type ) then
--                         if ( "attachment" === object_type || 0 === strpos( object_type, "attachment:" ) ) then
--                                 if ( "names" === output ) then
--                                         taxonomies[] = taxonomy->name;
--                                 end; else then
--                                         taxonomies[ taxonomy->name ] = taxonomy;
--                                 end;
--                                 break;
--                         end;
--                 end;
--         end;

--         return taxonomies;
-- end;

-- --
-- -- Determines whether the value is an acceptable type for GD image functions.
-- --
-- -- In PHP 8.0, the GD extension uses GdImage objects for its data structures.
-- -- This function checks if the passed value is either a resource of type `gd`
-- -- or a GdImage object instance. Any other type will return false.
-- --
-- -- @since 5.6.0
-- --
-- -- @param resource|GdImage|false image A value to check the type for.
-- -- @return bool True if image is either a GD image resource or GdImage instance,
-- --              false otherwise.
-- --
-- function is_gd_image( image ) then
--         if ( is_resource( image ) and then "gd" === get_resource_type( image )
--                 || is_object( image ) and then image instanceof GdImage
--         ) then
--                 return true;
--         end;

--         return false;
-- end;

-- --
-- -- Creates new GD image resource with transparency support.
-- --
-- -- @todo Deprecate if possible.
-- --
-- -- @since 2.9.0
-- --
-- -- @param int width  Image width in pixels.
-- -- @param int height Image height in pixels.
-- -- @return resource|GdImage|false The GD image resource or GdImage instance on success.
-- --                                False on failure.
-- --
-- function wp_imagecreatetruecolor( width, height ) then
--         img = imagecreatetruecolor( width, height );

--         if ( is_gd_image( img )
--                 and then function_exists( "imagealphablending" ) and then function_exists( "imagesavealpha" )
--         ) then
--                 imagealphablending( img, false );
--                 imagesavealpha( img, true );
--         end;

--         return img;
-- end;

-- --
-- -- Based on a supplied width/height example, returns the biggest possible dimensions based on the max width/height.
-- --
-- -- @since 2.9.0
-- --
-- -- @see wp_constrain_dimensions()
-- --
-- -- @param int example_width  The width of an example embed.
-- -- @param int example_height The height of an example embed.
-- -- @param int max_width      The maximum allowed width.
-- -- @param int max_height     The maximum allowed height.
-- -- @return int[] then
-- --     An array of maximum width and height values.
-- --
-- --     @type int 0 The maximum width in pixels.
-- --     @type int 1 The maximum height in pixels.
-- -- end;
-- --
-- function wp_expand_dimensions( example_width, example_height, max_width, max_height ) then
--         example_width  = (int) example_width;
--         example_height = (int) example_height;
--         max_width      = (int) max_width;
--         max_height     = (int) max_height;

--         return wp_constrain_dimensions( example_width-- 1000000, example_height-- 1000000, max_width, max_height );
-- end;

   ------------------------
   -- Wp_Max_Upload_Size --
   ------------------------

   function Wp_Max_Upload_Size
            return Natural
   is
      use Php;
      use Php.Ini;
      use Inc_Load;
--    use Inc_Plugins;

      U_Bytes : constant Natural :=
        Wp_Convert_Hr_To_Bytes (Ini_Get ("upload_max_filesize"));

      P_Bytes : constant Natural :=
        Wp_Convert_Hr_To_Bytes (Ini_Get ("post_max_size"));
   begin
      --
      -- Filters the maximum upload size allowed in php.ini.
      --
      -- @since 2.5.0
      --
      -- @param int size    Max upload size limit in bytes.
      -- @param int u_bytes Maximum upload filesize in bytes.
      -- @param int p_bytes Maximum size of POST data in bytes.
      --
      return
        Apply_Filters ("upload_size_limit",
                       Natural'Min (U_Bytes, P_Bytes), U_Bytes, P_Bytes);
   end Wp_Max_Upload_Size;

-- --
-- -- Returns a WP_Image_Editor instance and loads file into it.
-- --
-- -- @since 3.5.0
-- --
-- -- @param string path Path to the file to load.
-- -- @param array  args Optional. Additional arguments for retrieving the image editor.
-- --                     Default empty array.
-- -- @return WP_Image_Editor|WP_Error The WP_Image_Editor object on success,
-- --                                  a WP_Error object otherwise.
-- --
-- function wp_get_image_editor( path, args = array() ) then
--         args["path"] = path;

--         -- If the mime type is not set in args, try to extract and set it from the file.
--         if ( not isset( args["mime_type"] ) ) then
--                 file_info = wp_check_filetype( args["path"] );

--                 -- If file_info["type"] is false, then we let the editor attempt to
--                 -- figure out the file type, rather than forcing a failure based on extension.
--                 if ( isset( file_info ) and then file_info["type"] ) then
--                         args["mime_type"] = file_info["type"];
--                 end;
--         end;

--         -- Check and set the output mime type mapped to the input type.
--         if ( isset( args["mime_type"] ) ) then
--                 -- This filter is documented in wp-includes/class-wp-image-editor.php--
--                 output_format = apply_filters( "image_editor_output_format", array(), path, args["mime_type"] );
--                 if ( isset( output_format[ args["mime_type"] ] ) ) then
--                         args["output_mime_type"] = output_format[ args["mime_type"] ];
--                 end;
--         end;

--         implementation = _wp_image_editor_choose( args );

--         if ( implementation ) then
--                 editor = new implementation( path );
--                 loaded = editor->load();

--                 if ( is_wp_error( loaded ) ) then
--                         return loaded;
--                 end;

--                 return editor;
--         end;

--         return new WP_Error( "image_no_editor", __( "No editor could be selected." ) );
-- end;

-- --
-- -- Tests whether there is an editor that supports a given mime type or methods.
-- --
-- -- @since 3.5.0
-- --
-- -- @param string|array args Optional. Array of arguments to retrieve the image editor supports.
-- --                           Default empty array.
-- -- @return bool True if an eligible editor is found; false otherwise.
-- --
-- function wp_image_editor_supports( args = array() ) then
--         return (bool) _wp_image_editor_choose( args );
-- end;

-- --
-- -- Tests which editors are capable of supporting the request.
-- --
-- -- @ignore
-- -- @since 3.5.0
-- --
-- -- @param array args Optional. Array of arguments for choosing a capable editor. Default empty array.
-- -- @return string|false Class name for the first editor that claims to support the request.
-- --                      False if no editor claims to support the request.
-- --
-- function _wp_image_editor_choose( args = array() ) then
--         require_once ABSPATH . WPINC . "/class-wp-image-editor.php";
--         require_once ABSPATH . WPINC . "/class-wp-image-editor-gd.php";
--         require_once ABSPATH . WPINC . "/class-wp-image-editor-imagick.php";
--         --
--         -- Filters the list of image editing library classes.
--         --
--         -- @since 3.5.0
--         --
--         -- @param string[] image_editors Array of available image editor class names. Defaults are
--         --                                "WP_Image_Editor_Imagick", "WP_Image_Editor_GD".
--         --
--         implementations = apply_filters( "wp_image_editors", array( "WP_Image_Editor_Imagick", "WP_Image_Editor_GD" ) );
--         supports_input  = false;

--         foreach ( implementations as implementation ) then
--                 if ( not call_user_func( array( implementation, "test" ), args ) ) then
--                         continue;
--                 end;

--                 -- Implementation should support the passed mime type.
--                 if ( isset( args["mime_type"] ) and then
--                         not call_user_func(
--                                 array( implementation, "supports_mime_type" ),
--                                 args["mime_type"]
--                         ) ) then
--                         continue;
--                 end;

--                 -- Implementation should support requested methods.
--                 if ( isset( args["methods"] ) and then
--                         array_diff( args["methods"], get_class_methods( implementation ) ) ) then

--                         continue;
--                 end;

--                 -- Implementation should ideally support the output mime type as well if set and different than the passed type.
--                 if (
--                         isset( args["mime_type"] ) and then
--                         isset( args["output_mime_type"] ) and then
--                         args["mime_type"] not== args["output_mime_type"] and then
--                         not call_user_func( array( implementation, "supports_mime_type" ), args["output_mime_type"] )
--                 ) then
--                         -- This implementation supports the imput type but not the output type.
--                         -- Keep looking to see if we can find an implementation that supports both.
--                         supports_input = implementation;
--                         continue;
--                 end;

--                 -- Favor the implementation that supports both input and output mime types.
--                 return implementation;
--         end;

--         return supports_input;
-- end;

-- --
-- -- Prints default Plupload arguments.
-- --
-- -- @since 3.4.0
-- --
-- function wp_plupload_default_settings() then
--         wp_scripts = wp_scripts();

--         data = wp_scripts->get_data( "wp-plupload", "data" );
--         if ( data and then false not== strpos( data, "_wpPluploadSettings" ) ) then
--                 return;
--         end;

--         max_upload_size    = wp_max_upload_size();
--         allowed_extensions = array_keys( get_allowed_mime_types() );
--         extensions         = array();
--         foreach ( allowed_extensions as extension ) then
--                 extensions = array_merge( extensions, explode( "|", extension ) );
--         end;

--         /*
--         -- Since 4.9 the `runtimes` setting is hardcoded in our version of Plupload to `html5,html4`,
--         -- and the `flash_swf_url` and `silverlight_xap_url` are not used.
--         --
--         defaults = array(
--                 "file_data_name" => "async-upload", -- Key passed to _FILE.
--                 "url"            => admin_url( "async-upload.php", "relative" ),
--                 "filters"        => array(
--                         "max_file_size" => max_upload_size . "b",
--                         "mime_types"    => array( array( "extensions" => implode( ",", extensions ) ) ),
--                 ),
--         );

--         /*
--         -- Currently only iOS Safari supports multiple files uploading,
--         -- but iOS 7.x has a bug that prevents uploading of videos when enabled.
--         -- See #29602.
--         --
--         if ( wp_is_mobile() and then strpos( _SERVER["HTTP_USER_AGENT"], "OS 7_" ) not== false and then
--                 strpos( _SERVER["HTTP_USER_AGENT"], "like Mac OS X" ) not== false ) then

--                 defaults["multi_selection"] = false;
--         end;

--         -- Check if WebP images can be edited.
--         if ( not wp_image_editor_supports( array( "mime_type" => "image/webp" ) ) ) then
--                 defaults["webp_upload_error"] = true;
--         end;

--         --
--         -- Filters the Plupload default settings.
--         --
--         -- @since 3.4.0
--         --
--         -- @param array defaults Default Plupload settings array.
--         --
--         defaults = apply_filters( "plupload_default_settings", defaults );

--         params = array(
--                 "action" => "upload-attachment",
--         );

--         --
--         -- Filters the Plupload default parameters.
--         --
--         -- @since 3.4.0
--         --
--         -- @param array params Default Plupload parameters array.
--         --
--         params = apply_filters( "plupload_default_params", params );

--         params["_wpnonce"] = wp_create_nonce( "media-form" );

--         defaults["multipart_params"] = params;

--         settings = array(
--                 "defaults"      => defaults,
--                 "browser"       => array(
--                         "mobile"    => wp_is_mobile(),
--                         "supported" => _device_can_upload(),
--                 ),
--                 "limitExceeded" => is_multisite() and then not is_upload_space_available(),
--         );

--         script = "var _wpPluploadSettings = " . wp_json_encode( settings ) . ";";

--         if ( data ) then
--                 script = "data\nscript";
--         end;

--         wp_scripts->add_data( "wp-plupload", "data", script );
-- end;

-- --
-- -- Prepares an attachment post object for JS, where it is expected
-- -- to be JSON-encoded and fit into an Attachment model.
-- --
-- -- @since 3.5.0
-- --
-- -- @param int|WP_Post attachment Attachment ID or object.
-- -- @return array|void then
-- --     Array of attachment details, or void if the parameter does not correspond to an attachment.
-- --
-- --     @type string alt                   Alt text of the attachment.
-- --     @type string author                ID of the attachment author, as a string.
-- --     @type string authorName            Name of the attachment author.
-- --     @type string caption               Caption for the attachment.
-- --     @type array  compat                Containing item and meta.
-- --     @type string context               Context, whether it"s used as the site icon for example.
-- --     @type int    date                  Uploaded date, timestamp in milliseconds.
-- --     @type string dateFormatted         Formatted date (e.g. June 29, 2018).
-- --     @type string description           Description of the attachment.
-- --     @type string editLink              URL to the edit page for the attachment.
-- --     @type string filename              File name of the attachment.
-- --     @type string filesizeHumanReadable Filesize of the attachment in human readable format (e.g. 1 MB).
-- --     @type int    filesizeInBytes       Filesize of the attachment in bytes.
-- --     @type int    height                If the attachment is an image, represents the height of the image in pixels.
-- --     @type string icon                  Icon URL of the attachment (e.g. /wp-includes/images/media/archive.png).
-- --     @type int    id                    ID of the attachment.
-- --     @type string link                  URL to the attachment.
-- --     @type int    menuOrder             Menu order of the attachment post.
-- --     @type array  meta                  Meta data for the attachment.
-- --     @type string mime                  Mime type of the attachment (e.g. image/jpeg or application/zip).
-- --     @type int    modified              Last modified, timestamp in milliseconds.
-- --     @type string name                  Name, same as title of the attachment.
-- --     @type array  nonces                Nonces for update, delete and edit.
-- --     @type string orientation           If the attachment is an image, represents the image orientation
-- --                                         (landscape or portrait).
-- --     @type array  sizes                 If the attachment is an image, contains an array of arrays
-- --                                         for the images sizes: thumbnail, medium, large, and full.
-- --     @type string status                Post status of the attachment (usually "inherit").
-- --     @type string subtype               Mime subtype of the attachment (usually the last part, e.g. jpeg or zip).
-- --     @type string title                 Title of the attachment (usually slugified file name without the extension).
-- --     @type string type                  Type of the attachment (usually first part of the mime type, e.g. image).
-- --     @type int    uploadedTo            Parent post to which the attachment was uploaded.
-- --     @type string uploadedToLink        URL to the edit page of the parent post of the attachment.
-- --     @type string uploadedToTitle       Post title of the parent of the attachment.
-- --     @type string url                   Direct URL to the attachment file (from wp-content).
-- --     @type int    width                 If the attachment is an image, represents the width of the image in pixels.
-- -- end;
-- --
-- --
-- function wp_prepare_attachment_for_js( attachment ) then
--         attachment = get_post( attachment );

--         if ( not attachment ) then
--                 return;
--         end;

--         if ( "attachment" not== attachment->post_type ) then
--                 return;
--         end;

--         meta = wp_get_attachment_metadata( attachment->ID );
--         if ( false not== strpos( attachment->post_mime_type, "/" ) ) then
--                 list( type, subtype ) = explode( "/", attachment->post_mime_type );
--         end; else then
--                 list( type, subtype ) = array( attachment->post_mime_type, "" );
--         end;

--         attachment_url = wp_get_attachment_url( attachment->ID );
--         base_url       = str_replace( wp_basename( attachment_url ), "", attachment_url );

--         response = array(
--                 "id"            => attachment->ID,
--                 "title"         => attachment->post_title,
--                 "filename"      => wp_basename( get_attached_file( attachment->ID ) ),
--                 "url"           => attachment_url,
--                 "link"          => get_attachment_link( attachment->ID ),
--                 "alt"           => get_post_meta( attachment->ID, "_wp_attachment_image_alt", true ),
--                 "author"        => attachment->post_author,
--                 "description"   => attachment->post_content,
--                 "caption"       => attachment->post_excerpt,
--                 "name"          => attachment->post_name,
--                 "status"        => attachment->post_status,
--                 "uploadedTo"    => attachment->post_parent,
--                 "date"          => strtotime( attachment->post_date_gmt )-- 1000,
--                 "modified"      => strtotime( attachment->post_modified_gmt )-- 1000,
--                 "menuOrder"     => attachment->menu_order,
--                 "mime"          => attachment->post_mime_type,
--                 "type"          => type,
--                 "subtype"       => subtype,
--                 "icon"          => wp_mime_type_icon( attachment->ID ),
--                 "dateFormatted" => mysql2date( __( "F j, Y" ), attachment->post_date ),
--                 "nonces"        => array(
--                         "update" => false,
--                         "delete" => false,
--                         "edit"   => false,
--                 ),
--                 "editLink"      => false,
--                 "meta"          => false,
--         );

--         author = new WP_User( attachment->post_author );

--         if ( author->exists() ) then
--                 author_name            = author->display_name ? author->display_name : author->nickname;
--                 response["authorName"] = html_entity_decode( author_name, ENT_QUOTES, get_bloginfo( "charset" ) );
--                 response["authorLink"] = get_edit_user_link( author->ID );
--         end; else then
--                 response["authorName"] = __( "(no author)" );
--         end;

--         if ( attachment->post_parent ) then
--                 post_parent = get_post( attachment->post_parent );
--                 if ( post_parent ) then
--                         response["uploadedToTitle"] = post_parent->post_title ? post_parent->post_title : __( "(no title)" );
--                         response["uploadedToLink"]  = get_edit_post_link( attachment->post_parent, "raw" );
--                 end;
--         end;

--         attached_file = get_attached_file( attachment->ID );

--         if ( isset( meta["filesize"] ) ) then
--                 bytes = meta["filesize"];
--         end; elseif ( file_exists( attached_file ) ) then
--                 bytes = wp_filesize( attached_file );
--         end; else then
--                 bytes = "";
--         end;

--         if ( bytes ) then
--                 response["filesizeInBytes"]       = bytes;
--                 response["filesizeHumanReadable"] = size_format( bytes );
--         end;

--         context             = get_post_meta( attachment->ID, "_wp_attachment_context", true );
--         response["context"] = ( context ) ? context : "";

--         if ( current_user_can( "edit_post", attachment->ID ) ) then
--                 response["nonces"]["update"] = wp_create_nonce( "update-post_" . attachment->ID );
--                 response["nonces"]["edit"]   = wp_create_nonce( "image_editor-" . attachment->ID );
--                 response["editLink"]         = get_edit_post_link( attachment->ID, "raw" );
--         end;

--         if ( current_user_can( "delete_post", attachment->ID ) ) then
--                 response["nonces"]["delete"] = wp_create_nonce( "delete-post_" . attachment->ID );
--         end;

--         if ( meta and then ( "image" === type || not empty( meta["sizes"] ) ) ) then
--                 sizes = array();

--                 -- This filter is documented in wp-admin/includes/media.php--
--                 possible_sizes = apply_filters(
--                         "image_size_names_choose",
--                         array(
--                                 "thumbnail" => __( "Thumbnail" ),
--                                 "medium"    => __( "Medium" ),
--                                 "large"     => __( "Large" ),
--                                 "full"      => __( "Full Size" ),
--                         )
--                 );
--                 unset( possible_sizes["full"] );

--                 /*
--                 -- Loop through all potential sizes that may be chosen. Try to do this with some efficiency.
--                 -- First: run the image_downsize filter. If it returns something, we can use its data.
--                 -- If the filter does not return something, then image_downsize() is just an expensive way
--                 -- to check the image metadata, which we do second.
--                 --
--                 foreach ( possible_sizes as size => label ) then

--                         -- This filter is documented in wp-includes/media.php--
--                         downsize = apply_filters( "image_downsize", false, attachment->ID, size );

--                         if ( downsize ) then
--                                 if ( empty( downsize[3] ) ) then
--                                         continue;
--                                 end;

--                                 sizes[ size ] = array(
--                                         "height"      => downsize[2],
--                                         "width"       => downsize[1],
--                                         "url"         => downsize[0],
--                                         "orientation" => downsize[2] > downsize[1] ? "portrait" : "landscape",
--                                 );
--                         end; elseif ( isset( meta["sizes"][ size ] ) ) then
--                                 -- Nothing from the filter, so consult image metadata if we have it.
--                                 size_meta = meta["sizes"][ size ];

--                                 -- We have the actual image size, but might need to further constrain it if content_width is narrower.
--                                 -- Thumbnail, medium, and full sizes are also checked against the site"s height/width options.
--                                 list( width, height ) = image_constrain_size_for_editor( size_meta["width"], size_meta["height"], size, "edit" );

--                                 sizes[ size ] = array(
--                                         "height"      => height,
--                                         "width"       => width,
--                                         "url"         => base_url . size_meta["file"],
--                                         "orientation" => height > width ? "portrait" : "landscape",
--                                 );
--                         end;
--                 end;

--                 if ( "image" === type ) then
--                         if ( not empty( meta["original_image"] ) ) then
--                                 response["originalImageURL"]  = wp_get_original_image_url( attachment->ID );
--                                 response["originalImageName"] = wp_basename( wp_get_original_image_path( attachment->ID ) );
--                         end;

--                         sizes["full"] = array( "url" => attachment_url );

--                         if ( isset( meta["height"], meta["width"] ) ) then
--                                 sizes["full"]["height"]      = meta["height"];
--                                 sizes["full"]["width"]       = meta["width"];
--                                 sizes["full"]["orientation"] = meta["height"] > meta["width"] ? "portrait" : "landscape";
--                         end;

--                         response = array_merge( response, sizes["full"] );
--                 end; elseif ( meta["sizes"]["full"]["file"] ) then
--                         sizes["full"] = array(
--                                 "url"         => base_url . meta["sizes"]["full"]["file"],
--                                 "height"      => meta["sizes"]["full"]["height"],
--                                 "width"       => meta["sizes"]["full"]["width"],
--                                 "orientation" => meta["sizes"]["full"]["height"] > meta["sizes"]["full"]["width"] ? "portrait" : "landscape",
--                         );
--                 end;

--                 response = array_merge( response, array( "sizes" => sizes ) );
--         end;

--         if ( meta and then "video" === type ) then
--                 if ( isset( meta["width"] ) ) then
--                         response["width"] = (int) meta["width"];
--                 end;
--                 if ( isset( meta["height"] ) ) then
--                         response["height"] = (int) meta["height"];
--                 end;
--         end;

--         if ( meta and then ( "audio" === type || "video" === type ) ) then
--                 if ( isset( meta["length_formatted"] ) ) then
--                         response["fileLength"]              = meta["length_formatted"];
--                         response["fileLengthHumanReadable"] = human_readable_duration( meta["length_formatted"] );
--                 end;

--                 response["meta"] = array();
--                 foreach ( wp_get_attachment_id3_keys( attachment, "js" ) as key => label ) then
--                         response["meta"][ key ] = false;

--                         if ( not empty( meta[ key ] ) ) then
--                                 response["meta"][ key ] = meta[ key ];
--                         end;
--                 end;

--                 id = get_post_thumbnail_id( attachment->ID );
--                 if ( not empty( id ) ) then
--                         list( src, width, height ) = wp_get_attachment_image_src( id, "full" );
--                         response["image"]            = compact( "src", "width", "height" );
--                         list( src, width, height ) = wp_get_attachment_image_src( id, "thumbnail" );
--                         response["thumb"]            = compact( "src", "width", "height" );
--                 end; else then
--                         src               = wp_mime_type_icon( attachment->ID );
--                         width             = 48;
--                         height            = 64;
--                         response["image"] = compact( "src", "width", "height" );
--                         response["thumb"] = compact( "src", "width", "height" );
--                 end;
--         end;

--         if ( function_exists( "get_compat_media_markup" ) ) then
--                 response["compat"] = get_compat_media_markup( attachment->ID, array( "in_modal" => true ) );
--         end;

--         if ( function_exists( "get_media_states" ) ) then
--                 media_states = get_media_states( attachment );
--                 if ( not empty( media_states ) ) then
--                         response["mediaStates"] = implode( ", ", media_states );
--                 end;
--         end;

--         --
--         -- Filters the attachment data prepared for JavaScript.
--         --
--         -- @since 3.5.0
--         --
--         -- @param array       response   Array of prepared attachment data. @see wp_prepare_attachment_for_js().
--         -- @param WP_Post     attachment Attachment object.
--         -- @param array|false meta       Array of attachment meta data, or false if there is none.
--         --
--         return apply_filters( "wp_prepare_attachment_for_js", response, attachment, meta );
-- end;

-- --
-- -- Enqueues all scripts, styles, settings, and templates necessary to use
-- -- all media JS APIs.
-- --
-- -- @since 3.5.0
-- --
-- -- @global int       content_width
-- -- @global wpdb      wpdb          WordPress database abstraction object.
-- -- @global WP_Locale wp_locale     WordPress date and time locale object.
-- --
-- -- @param array args then
-- --     Arguments for enqueuing media scripts.
-- --
-- --     @type int|WP_Post post Post ID or post object.
-- -- end;
-- --
-- function wp_enqueue_media( args = array() ) then
--         -- Enqueue me just once per page, please.
--         if ( did_action( "wp_enqueue_media" ) ) then
--                 return;
--         end;

--         global content_width, wpdb, wp_locale;

--         defaults = array(
--                 "post" => null,
--         );
--         args     = wp_parse_args( args, defaults );

--         -- We"re going to pass the old thickbox media tabs to `media_upload_tabs`
--         -- to ensure plugins will work. We will then unset those tabs.
--         tabs = array(
--                 -- handler action suffix => tab label
--                 "type"     => "",
--                 "type_url" => "",
--                 "gallery"  => "",
--                 "library"  => "",
--         );

--         -- This filter is documented in wp-admin/includes/media.php--
--         tabs = apply_filters( "media_upload_tabs", tabs );
--         unset( tabs["type"], tabs["type_url"], tabs["gallery"], tabs["library"] );

--         props = array(
--                 "link"  => get_option( "image_default_link_type" ), -- DB default is "file".
--                 "align" => get_option( "image_default_align" ),     -- Empty default.
--                 "size"  => get_option( "image_default_size" ),      -- Empty default.
--         );

--         exts      = array_merge( wp_get_audio_extensions(), wp_get_video_extensions() );
--         mimes     = get_allowed_mime_types();
--         ext_mimes = array();
--         foreach ( exts as ext ) then
--                 foreach ( mimes as ext_preg => mime_match ) then
--                         if ( preg_match( "#" . ext . "#i", ext_preg ) ) then
--                                 ext_mimes[ ext ] = mime_match;
--                                 break;
--                         end;
--                 end;
--         end;

--         --
--         -- Allows showing or hiding the "Create Audio Playlist" button in the media library.
--         --
--         -- By default, the "Create Audio Playlist" button will always be shown in
--         -- the media library.  If this filter returns `null`, a query will be run
--         -- to determine whether the media library contains any audio items.  This
--         -- was the default behavior prior to version 4.8.0, but this query is
--         -- expensive for large media libraries.
--         --
--         -- @since 4.7.4
--         -- @since 4.8.0 The filter"s default value is `true` rather than `null`.
--         --
--         -- @link https://core.trac.wordpress.org/ticket/31071
--         --
--         -- @param bool|null show Whether to show the button, or `null` to decide based
--         --                        on whether any audio files exist in the media library.
--         --
--         show_audio_playlist = apply_filters( "media_library_show_audio_playlist", true );
--         if ( null === show_audio_playlist ) then
--                 show_audio_playlist = wpdb->get_var(
--                         "
--                         SELECT ID
--                         FROM wpdb->posts
--                         WHERE post_type = "attachment"
--                         AND post_mime_type LIKE "audio%"
--                         LIMIT 1
--                 "
--                 );
--         end;

--         --
--         -- Allows showing or hiding the "Create Video Playlist" button in the media library.
--         --
--         -- By default, the "Create Video Playlist" button will always be shown in
--         -- the media library.  If this filter returns `null`, a query will be run
--         -- to determine whether the media library contains any video items.  This
--         -- was the default behavior prior to version 4.8.0, but this query is
--         -- expensive for large media libraries.
--         --
--         -- @since 4.7.4
--         -- @since 4.8.0 The filter"s default value is `true` rather than `null`.
--         --
--         -- @link https://core.trac.wordpress.org/ticket/31071
--         --
--         -- @param bool|null show Whether to show the button, or `null` to decide based
--         --                        on whether any video files exist in the media library.
--         --
--         show_video_playlist = apply_filters( "media_library_show_video_playlist", true );
--         if ( null === show_video_playlist ) then
--                 show_video_playlist = wpdb->get_var(
--                         "
--                         SELECT ID
--                         FROM wpdb->posts
--                         WHERE post_type = "attachment"
--                         AND post_mime_type LIKE "video%"
--                         LIMIT 1
--                 "
--                 );
--         end;

--         --
--         -- Allows overriding the list of months displayed in the media library.
--         --
--         -- By default (if this filter does not return an array), a query will be
--         -- run to determine the months that have media items.  This query can be
--         -- expensive for large media libraries, so it may be desirable for sites to
--         -- override this behavior.
--         --
--         -- @since 4.7.4
--         --
--         -- @link https://core.trac.wordpress.org/ticket/31071
--         --
--         -- @param stdClass[]|null months An array of objects with `month` and `year`
--         --                                properties, or `null` for default behavior.
--         --
--         months = apply_filters( "media_library_months_with_files", null );
--         if ( not is_array( months ) ) then
--                 months = wpdb->get_results(
--                         wpdb->prepare(
--                                 "
--                         SELECT DISTINCT YEAR( post_date ) AS year, MONTH( post_date ) AS month
--                         FROM wpdb->posts
--                         WHERE post_type = %s
--                         ORDER BY post_date DESC
--                 ",
--                                 "attachment"
--                         )
--                 );
--         end;
--         foreach ( months as month_year ) then
--                 month_year->text = sprintf(
--                         /* translators: 1: Month, 2: Year.--
--                         __( "%1s %2d" ),
--                         wp_locale->get_month( month_year->month ),
--                         month_year->year
--                 );
--         end;

--         --
--         -- Filters whether the Media Library grid has infinite scrolling. Default `false`.
--         --
--         -- @since 5.8.0
--         --
--         -- @param bool infinite Whether the Media Library grid has infinite scrolling.
--         --
--         infinite_scrolling = apply_filters( "media_library_infinite_scrolling", false );

--         settings = array(
--                 "tabs"              => tabs,
--                 "tabUrl"            => add_query_arg( array( "chromeless" => true ), admin_url( "media-upload.php" ) ),
--                 "mimeTypes"         => wp_list_pluck( get_post_mime_types(), 0 ),
--                 -- This filter is documented in wp-admin/includes/media.php--
--                 "captions"          => not apply_filters( "disable_captions", "" ),
--                 "nonce"             => array(
--                         "sendToEditor"           => wp_create_nonce( "media-send-to-editor" ),
--                         "setAttachmentThumbnail" => wp_create_nonce( "set-attachment-thumbnail" ),
--                 ),
--                 "post"              => array(
--                         "id" => 0,
--                 ),
--                 "defaultProps"      => props,
--                 "attachmentCounts"  => array(
--                         "audio" => ( show_audio_playlist ) ? 1 : 0,
--                         "video" => ( show_video_playlist ) ? 1 : 0,
--                 ),
--                 "oEmbedProxyUrl"    => rest_url( "oembed/1.0/proxy" ),
--                 "embedExts"         => exts,
--                 "embedMimes"        => ext_mimes,
--                 "contentWidth"      => content_width,
--                 "months"            => months,
--                 "mediaTrash"        => MEDIA_TRASH ? 1 : 0,
--                 "infiniteScrolling" => ( infinite_scrolling ) ? 1 : 0,
--         );

--         post = null;
--         if ( isset( args["post"] ) ) then
--                 post             = get_post( args["post"] );
--                 settings["post"] = array(
--                         "id"    => post->ID,
--                         "nonce" => wp_create_nonce( "update-post_" . post->ID ),
--                 );

--                 thumbnail_support = current_theme_supports( "post-thumbnails", post->post_type ) and then post_type_supports( post->post_type, "thumbnail" );
--                 if ( not thumbnail_support and then "attachment" === post->post_type and then post->post_mime_type ) then
--                         if ( wp_attachment_is( "audio", post ) ) then
--                                 thumbnail_support = post_type_supports( "attachment:audio", "thumbnail" ) || current_theme_supports( "post-thumbnails", "attachment:audio" );
--                         end; elseif ( wp_attachment_is( "video", post ) ) then
--                                 thumbnail_support = post_type_supports( "attachment:video", "thumbnail" ) || current_theme_supports( "post-thumbnails", "attachment:video" );
--                         end;
--                 end;

--                 if ( thumbnail_support ) then
--                         featured_image_id                   = get_post_meta( post->ID, "_thumbnail_id", true );
--                         settings["post"]["featuredImageId"] = featured_image_id ? featured_image_id : -1;
--                 end;
--         end;

--         if ( post ) then
--                 post_type_object = get_post_type_object( post->post_type );
--         end; else then
--                 post_type_object = get_post_type_object( "post" );
--         end;

--         strings = array(
--                 -- Generic.
--                 "mediaFrameDefaultTitle"      => __( "Media" ),
--                 "url"                         => __( "URL" ),
--                 "addMedia"                    => __( "Add media" ),
--                 "search"                      => __( "Search" ),
--                 "select"                      => __( "Select" ),
--                 "cancel"                      => __( "Cancel" ),
--                 "update"                      => __( "Update" ),
--                 "replace"                     => __( "Replace" ),
--                 "remove"                      => __( "Remove" ),
--                 "back"                        => __( "Back" ),
--                 /*
--                 -- translators: This is a would-be plural string used in the media manager.
--                 -- If there is not a word you can use in your language to avoid issues with the
--                 -- lack of plural support here, turn it into "selected: %d" then translate it.
--                 --
--                 "selected"                    => __( "%d selected" ),
--                 "dragInfo"                    => __( "Drag and drop to reorder media files." ),

--                 -- Upload.
--                 "uploadFilesTitle"            => __( "Upload files" ),
--                 "uploadImagesTitle"           => __( "Upload images" ),

--                 -- Library.
--                 "mediaLibraryTitle"           => __( "Media Library" ),
--                 "insertMediaTitle"            => __( "Add media" ),
--                 "createNewGallery"            => __( "Create a new gallery" ),
--                 "createNewPlaylist"           => __( "Create a new playlist" ),
--                 "createNewVideoPlaylist"      => __( "Create a new video playlist" ),
--                 "returnToLibrary"             => __( "&#8592; Go to library" ),
--                 "allMediaItems"               => __( "All media items" ),
--                 "allDates"                    => __( "All dates" ),
--                 "noItemsFound"                => __( "No items found." ),
--                 "insertIntoPost"              => post_type_object->labels->insert_into_item,
--                 "unattached"                  => _x( "Unattached", "media items" ),
--                 "mine"                        => _x( "Mine", "media items" ),
--                 "trash"                       => _x( "Trash", "noun" ),
--                 "uploadedToThisPost"          => post_type_object->labels->uploaded_to_this_item,
--                 "warnDelete"                  => __( "You are about to permanently delete this item from your site.\nThis action cannot be undone.\n "Cancel" to stop, "OK" to delete." ),
--                 "warnBulkDelete"              => __( "You are about to permanently delete these items from your site.\nThis action cannot be undone.\n "Cancel" to stop, "OK" to delete." ),
--                 "warnBulkTrash"               => __( "You are about to trash these items.\n  "Cancel" to stop, "OK" to delete." ),
--                 "bulkSelect"                  => __( "Bulk select" ),
--                 "trashSelected"               => __( "Move to Trash" ),
--                 "restoreSelected"             => __( "Restore from Trash" ),
--                 "deletePermanently"           => __( "Delete permanently" ),
--                 "errorDeleting"               => __( "Error in deleting the attachment." ),
--                 "apply"                       => __( "Apply" ),
--                 "filterByDate"                => __( "Filter by date" ),
--                 "filterByType"                => __( "Filter by type" ),
--                 "searchLabel"                 => __( "Search" ),
--                 "searchMediaLabel"            => __( "Search media" ),          -- Backward compatibility pre-5.3.
--                 "searchMediaPlaceholder"      => __( "Search media items..." ), -- Placeholder (no ellipsis), backward compatibility pre-5.3.
--                 /* translators: %d: Number of attachments found in a search.--
--                 "mediaFound"                  => __( "Number of media items found: %d" ),
--                 "noMedia"                     => __( "No media items found." ),
--                 "noMediaTryNewSearch"         => __( "No media items found. Try a different search." ),

--                 -- Library Details.
--                 "attachmentDetails"           => __( "Attachment details" ),

--                 -- From URL.
--                 "insertFromUrlTitle"          => __( "Insert from URL" ),

--                 -- Featured Images.
--                 "setFeaturedImageTitle"       => post_type_object->labels->featured_image,
--                 "setFeaturedImage"            => post_type_object->labels->set_featured_image,

--                 -- Gallery.
--                 "createGalleryTitle"          => __( "Create gallery" ),
--                 "editGalleryTitle"            => __( "Edit gallery" ),
--                 "cancelGalleryTitle"          => __( "&#8592; Cancel gallery" ),
--                 "insertGallery"               => __( "Insert gallery" ),
--                 "updateGallery"               => __( "Update gallery" ),
--                 "addToGallery"                => __( "Add to gallery" ),
--                 "addToGalleryTitle"           => __( "Add to gallery" ),
--                 "reverseOrder"                => __( "Reverse order" ),

--                 -- Edit Image.
--                 "imageDetailsTitle"           => __( "Image details" ),
--                 "imageReplaceTitle"           => __( "Replace image" ),
--                 "imageDetailsCancel"          => __( "Cancel edit" ),
--                 "editImage"                   => __( "Edit image" ),

--                 -- Crop Image.
--                 "chooseImage"                 => __( "Choose image" ),
--                 "selectAndCrop"               => __( "Select and crop" ),
--                 "skipCropping"                => __( "Skip cropping" ),
--                 "cropImage"                   => __( "Crop image" ),
--                 "cropYourImage"               => __( "Crop your image" ),
--                 "cropping"                    => __( "Cropping&hellip;" ),
--                 /* translators: 1: Suggested width number, 2: Suggested height number.--
--                 "suggestedDimensions"         => __( "Suggested image dimensions: %1s by %2s pixels." ),
--                 "cropError"                   => __( "There has been an error cropping your image." ),

--                 -- Edit Audio.
--                 "audioDetailsTitle"           => __( "Audio details" ),
--                 "audioReplaceTitle"           => __( "Replace audio" ),
--                 "audioAddSourceTitle"         => __( "Add audio source" ),
--                 "audioDetailsCancel"          => __( "Cancel edit" ),

--                 -- Edit Video.
--                 "videoDetailsTitle"           => __( "Video details" ),
--                 "videoReplaceTitle"           => __( "Replace video" ),
--                 "videoAddSourceTitle"         => __( "Add video source" ),
--                 "videoDetailsCancel"          => __( "Cancel edit" ),
--                 "videoSelectPosterImageTitle" => __( "Select poster image" ),
--                 "videoAddTrackTitle"          => __( "Add subtitles" ),

--                 -- Playlist.
--                 "playlistDragInfo"            => __( "Drag and drop to reorder tracks." ),
--                 "createPlaylistTitle"         => __( "Create audio playlist" ),
--                 "editPlaylistTitle"           => __( "Edit audio playlist" ),
--                 "cancelPlaylistTitle"         => __( "&#8592; Cancel audio playlist" ),
--                 "insertPlaylist"              => __( "Insert audio playlist" ),
--                 "updatePlaylist"              => __( "Update audio playlist" ),
--                 "addToPlaylist"               => __( "Add to audio playlist" ),
--                 "addToPlaylistTitle"          => __( "Add to Audio Playlist" ),

--                 -- Video Playlist.
--                 "videoPlaylistDragInfo"       => __( "Drag and drop to reorder videos." ),
--                 "createVideoPlaylistTitle"    => __( "Create video playlist" ),
--                 "editVideoPlaylistTitle"      => __( "Edit video playlist" ),
--                 "cancelVideoPlaylistTitle"    => __( "&#8592; Cancel video playlist" ),
--                 "insertVideoPlaylist"         => __( "Insert video playlist" ),
--                 "updateVideoPlaylist"         => __( "Update video playlist" ),
--                 "addToVideoPlaylist"          => __( "Add to video playlist" ),
--                 "addToVideoPlaylistTitle"     => __( "Add to video Playlist" ),

--                 -- Headings.
--                 "filterAttachments"           => __( "Filter media" ),
--                 "attachmentsList"             => __( "Media list" ),
--         );

--         --
--         -- Filters the media view settings.
--         --
--         -- @since 3.5.0
--         --
--         -- @param array   settings List of media view settings.
--         -- @param WP_Post post     Post object.
--         --
--         settings = apply_filters( "media_view_settings", settings, post );

--         --
--         -- Filters the media view strings.
--         --
--         -- @since 3.5.0
--         --
--         -- @param string[] strings Array of media view strings keyed by the name they"ll be referenced by in JavaScript.
--         -- @param WP_Post  post    Post object.
--         --
--         strings = apply_filters( "media_view_strings", strings, post );

--         strings["settings"] = settings;

--         -- Ensure we enqueue media-editor first, that way media-views
--         -- is registered internally before we try to localize it. See #24724.
--         wp_enqueue_script( "media-editor" );
--         wp_localize_script( "media-views", "_wpMediaViewsL10n", strings );

--         wp_enqueue_script( "media-audiovideo" );
--         wp_enqueue_style( "media-views" );
--         if ( is_admin() ) then
--                 wp_enqueue_script( "mce-view" );
--                 wp_enqueue_script( "image-edit" );
--         end;
--         wp_enqueue_style( "imgareaselect" );
--         wp_plupload_default_settings();

--         require_once ABSPATH . WPINC . "/media-template.php";
--         add_action( "admin_footer", "wp_print_media_templates" );
--         add_action( "wp_footer", "wp_print_media_templates" );
--         add_action( "customize_controls_print_footer_scripts", "wp_print_media_templates" );

--         --
--         -- Fires at the conclusion of wp_enqueue_media().
--         --
--         -- @since 3.5.0
--         --
--         do_action( "wp_enqueue_media" );
-- end;

-- --
-- -- Retrieves media attached to the passed post.
-- --
-- -- @since 3.6.0
-- --
-- -- @param string      type Mime type.
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- -- @return WP_Post[] Array of media attached to the given post.
-- --
-- function get_attached_media( type, post = 0 ) then
--         post = get_post( post );

--         if ( not post ) then
--                 return array();
--         end;

--         args = array(
--                 "post_parent"    => post->ID,
--                 "post_type"      => "attachment",
--                 "post_mime_type" => type,
--                 "posts_per_page" => -1,
--                 "orderby"        => "menu_order",
--                 "order"          => "ASC",
--         );

--         --
--         -- Filters arguments used to retrieve media attached to the given post.
--         --
--         -- @since 3.6.0
--         --
--         -- @param array   args Post query arguments.
--         -- @param string  type Mime type of the desired media.
--         -- @param WP_Post post Post object.
--         --
--         args = apply_filters( "get_attached_media_args", args, type, post );

--         children = get_children( args );

--         --
--         -- Filters the list of media attached to the given post.
--         --
--         -- @since 3.6.0
--         --
--         -- @param WP_Post[] children Array of media attached to the given post.
--         -- @param string    type     Mime type of the media desired.
--         -- @param WP_Post   post     Post object.
--         --
--         return (array) apply_filters( "get_attached_media", children, type, post );
-- end;

-- --
-- -- Checks the HTML content for a audio, video, object, embed, or iframe tags.
-- --
-- -- @since 3.6.0
-- --
-- -- @param string   content A string of HTML which might contain media elements.
-- -- @param string[] types   An array of media types: "audio", "video", "object", "embed", or "iframe".
-- -- @return string[] Array of found HTML media elements.
-- --
-- function get_media_embedded_in_content( content, types = null ) then
--         html = array();

--         --
--         -- Filters the embedded media types that are allowed to be returned from the content blob.
--         --
--         -- @since 4.2.0
--         --
--         -- @param string[] allowed_media_types An array of allowed media types. Default media types are
--         --                                      "audio", "video", "object", "embed", and "iframe".
--         --
--         allowed_media_types = apply_filters( "media_embedded_in_content_allowed_types", array( "audio", "video", "object", "embed", "iframe" ) );

--         if ( not empty( types ) ) then
--                 if ( not is_array( types ) ) then
--                         types = array( types );
--                 end;

--                 allowed_media_types = array_intersect( allowed_media_types, types );
--         end;

--         tags = implode( "|", allowed_media_types );

--         if ( preg_match_all( "#<(?P<tag>" . tags . ")[^<]*?(?:>[\s\S]*?<\/(?P=tag)>|\s*\/>)#", content, matches ) ) then
--                 foreach ( matches[0] as match ) then
--                         html[] = match;
--                 end;
--         end;

--         return html;
-- end;

-- --
-- -- Retrieves galleries from the passed post"s content.
-- --
-- -- @since 3.6.0
-- --
-- -- @param int|WP_Post post Post ID or object.
-- -- @param bool        html Optional. Whether to return HTML or data in the array. Default true.
-- -- @return array A list of arrays, each containing gallery data and srcs parsed
-- --               from the expanded shortcode.
-- --
-- function get_post_galleries( post, html = true ) then
--         post = get_post( post );

--         if ( not post ) then
--                 return array();
--         end;

--         if ( not has_shortcode( post->post_content, "gallery" ) and then not has_block( "gallery", post->post_content ) ) then
--                 return array();
--         end;

--         galleries = array();
--         if ( preg_match_all( "/" . get_shortcode_regex() . "/s", post->post_content, matches, PREG_SET_ORDER ) ) then
--                 foreach ( matches as shortcode ) then
--                         if ( "gallery" === shortcode[2] ) then
--                                 srcs = array();

--                                 shortcode_attrs = shortcode_parse_atts( shortcode[3] );
--                                 if ( not is_array( shortcode_attrs ) ) then
--                                         shortcode_attrs = array();
--                                 end;

--                                 -- Specify the post ID of the gallery we"re viewing if the shortcode doesn"t reference another post already.
--                                 if ( not isset( shortcode_attrs["id"] ) ) then
--                                         shortcode[3] .= " id="" . (int) post->ID . """;
--                                 end;

--                                 gallery = do_shortcode_tag( shortcode );
--                                 if ( html ) then
--                                         galleries[] = gallery;
--                                 end; else then
--                                         preg_match_all( "#src=([\""])(.+?)\1#is", gallery, src, PREG_SET_ORDER );
--                                         if ( not empty( src ) ) then
--                                                 foreach ( src as s ) then
--                                                         srcs[] = s[2];
--                                                 end;
--                                         end;

--                                         galleries[] = array_merge(
--                                                 shortcode_attrs,
--                                                 array(
--                                                         "src" => array_values( array_unique( srcs ) ),
--                                                 )
--                                         );
--                                 end;
--                         end;
--                 end;
--         end;

--         if ( has_block( "gallery", post->post_content ) ) then
--                 post_blocks = parse_blocks( post->post_content );

--                 while ( block = array_shift( post_blocks ) ) then
--                         has_inner_blocks = not empty( block["innerBlocks"] );

--                         -- Skip blocks with no blockName and no innerHTML.
--                         if ( not block["blockName"] ) then
--                                 continue;
--                         end;

--                         -- Skip non-Gallery blocks.
--                         if ( "core/gallery" not== block["blockName"] ) then
--                                 -- Move inner blocks into the root array before skipping.
--                                 if ( has_inner_blocks ) then
--                                         array_push( post_blocks, ...block["innerBlocks"] );
--                                 end;
--                                 continue;
--                         end;

--                         -- New Gallery block format as HTML.
--                         if ( has_inner_blocks and then html ) then
--                                 block_html  = wp_list_pluck( block["innerBlocks"], "innerHTML" );
--                                 galleries[] = "<figure>" . implode( " ", block_html ) . "</figure>";
--                                 continue;
--                         end;

--                         srcs = array();

--                         -- New Gallery block format as an array.
--                         if ( has_inner_blocks ) then
--                                 attrs = wp_list_pluck( block["innerBlocks"], "attrs" );
--                                 ids   = wp_list_pluck( attrs, "id" );

--                                 foreach ( ids as id ) then
--                                         url = wp_get_attachment_url( id );

--                                         if ( is_string( url ) and then not in_array( url, srcs, true ) ) then
--                                                 srcs[] = url;
--                                         end;
--                                 end;

--                                 galleries[] = array(
--                                         "ids" => implode( ",", ids ),
--                                         "src" => srcs,
--                                 );

--                                 continue;
--                         end;

--                         -- Old Gallery block format as HTML.
--                         if ( html ) then
--                                 galleries[] = block["innerHTML"];
--                                 continue;
--                         end;

--                         -- Old Gallery block format as an array.
--                         ids = not empty( block["attrs"]["ids"] ) ? block["attrs"]["ids"] : array();

--                         -- If present, use the image IDs from the JSON blob as canonical.
--                         if ( not empty( ids ) ) then
--                                 foreach ( ids as id ) then
--                                         url = wp_get_attachment_url( id );

--                                         if ( is_string( url ) and then not in_array( url, srcs, true ) ) then
--                                                 srcs[] = url;
--                                         end;
--                                 end;

--                                 galleries[] = array(
--                                         "ids" => implode( ",", ids ),
--                                         "src" => srcs,
--                                 );

--                                 continue;
--                         end;

--                         -- Otherwise, extract srcs from the innerHTML.
--                         preg_match_all( "#src=([\""])(.+?)\1#is", block["innerHTML"], found_srcs, PREG_SET_ORDER );

--                         if ( not empty( found_srcs[0] ) ) then
--                                 foreach ( found_srcs as src ) then
--                                         if ( isset( src[2] ) and then not in_array( src[2], srcs, true ) ) then
--                                                 srcs[] = src[2];
--                                         end;
--                                 end;
--                         end;

--                         galleries[] = array( "src" => srcs );
--                 end;
--         end;

--         --
--         -- Filters the list of all found galleries in the given post.
--         --
--         -- @since 3.6.0
--         --
--         -- @param array   galleries Associative array of all found post galleries.
--         -- @param WP_Post post      Post object.
--         --
--         return apply_filters( "get_post_galleries", galleries, post );
-- end;

-- --
-- -- Checks a specified post"s content for gallery and, if present, return the first
-- --
-- -- @since 3.6.0
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global post.
-- -- @param bool        html Optional. Whether to return HTML or data. Default is true.
-- -- @return string|array Gallery data and srcs parsed from the expanded shortcode.
-- --
-- function get_post_gallery( post = 0, html = true ) then
--         galleries = get_post_galleries( post, html );
--         gallery   = reset( galleries );

--         --
--         -- Filters the first-found post gallery.
--         --
--         -- @since 3.6.0
--         --
--         -- @param array       gallery   The first-found post gallery.
--         -- @param int|WP_Post post      Post ID or object.
--         -- @param array       galleries Associative array of all found post galleries.
--         --
--         return apply_filters( "get_post_gallery", gallery, post, galleries );
-- end;

-- --
-- -- Retrieves the image srcs from galleries from a post"s content, if present.
-- --
-- -- @since 3.6.0
-- --
-- -- @see get_post_galleries()
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global `post`.
-- -- @return array A list of lists, each containing image srcs parsed.
-- --               from an expanded shortcode
-- --
-- function get_post_galleries_images( post = 0 ) then
--         galleries = get_post_galleries( post, false );
--         return wp_list_pluck( galleries, "src" );
-- end;

-- --
-- -- Checks a post"s content for galleries and return the image srcs for the first found gallery.
-- --
-- -- @since 3.6.0
-- --
-- -- @see get_post_gallery()
-- --
-- -- @param int|WP_Post post Optional. Post ID or WP_Post object. Default is global `post`.
-- -- @return string[] A list of a gallery"s image srcs in order.
-- --
-- function get_post_gallery_images( post = 0 ) then
--         gallery = get_post_gallery( post, false );
--         return empty( gallery["src"] ) ? array() : gallery["src"];
-- end;

-- --
-- -- Maybe attempts to generate attachment metadata, if missing.
-- --
-- -- @since 3.9.0
-- --
-- -- @param WP_Post attachment Attachment object.
-- --
-- function wp_maybe_generate_attachment_metadata( attachment ) then
--         if ( empty( attachment ) || empty( attachment->ID ) ) then
--                 return;
--         end;

--         attachment_id = (int) attachment->ID;
--         file          = get_attached_file( attachment_id );
--         meta          = wp_get_attachment_metadata( attachment_id );

--         if ( empty( meta ) and then file_exists( file ) ) then
--                 _meta = get_post_meta( attachment_id );
--                 _lock = "wp_generating_att_" . attachment_id;

--                 if ( not array_key_exists( "_wp_attachment_metadata", _meta ) and then not get_transient( _lock ) ) then
--                         set_transient( _lock, file );
--                         wp_update_attachment_metadata( attachment_id, wp_generate_attachment_metadata( attachment_id, file ) );
--                         delete_transient( _lock );
--                 end;
--         end;
-- end;

-- --
-- -- Tries to convert an attachment URL into a post ID.
-- --
-- -- @since 4.0.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string url The URL to resolve.
-- -- @return int The found post ID, or 0 on failure.
-- --
-- function attachment_url_to_postid( url ) then
--         global wpdb;

--         dir  = wp_get_upload_dir();
--         path = url;

--         site_url   = parse_url( dir["url"] );
--         image_path = parse_url( path );

--         -- Force the protocols to match if needed.
--         if ( isset( image_path["scheme"] ) and then ( image_path["scheme"] not== site_url["scheme"] ) ) then
--                 path = str_replace( image_path["scheme"], site_url["scheme"], path );
--         end;

--         if ( 0 === strpos( path, dir["baseurl"] . "/" ) ) then
--                 path = substr( path, strlen( dir["baseurl"] . "/" ) );
--         end;

--         sql = wpdb->prepare(
--                 "SELECT post_id, meta_value FROM wpdb->postmeta WHERE meta_key = "_wp_attached_file" AND meta_value = %s",
--                 path
--         );

--         results = wpdb->get_results( sql );
--         post_id = null;

--         if ( results ) then
--                 -- Use the first available result, but prefer a case-sensitive match, if exists.
--                 post_id = reset( results )->post_id;

--                 if ( count( results ) > 1 ) then
--                         foreach ( results as result ) then
--                                 if ( path === result->meta_value ) then
--                                         post_id = result->post_id;
--                                         break;
--                                 end;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters an attachment ID found by URL.
--         --
--         -- @since 4.2.0
--         --
--         -- @param int|null post_id The post_id (if any) found by the function.
--         -- @param string   url     The URL being looked up.
--         --
--         return (int) apply_filters( "attachment_url_to_postid", post_id, url );
-- end;

-- --
-- -- Returns the URLs for CSS files used in an iframe-sandbox"d TinyMCE media view.
-- --
-- -- @since 4.0.0
-- --
-- -- @return string[] The relevant CSS file URLs.
-- --
-- function wpview_media_sandbox_styles() then
--         version        = "ver=" . get_bloginfo( "version" );
--         mediaelement   = includes_url( "js/mediaelement/mediaelementplayer-legacy.min.css?version" );
--         wpmediaelement = includes_url( "js/mediaelement/wp-mediaelement.css?version" );

--         return array( mediaelement, wpmediaelement );
-- end;

-- --
-- -- Registers the personal data exporter for media.
-- --
-- -- @param array[] exporters An array of personal data exporters, keyed by their ID.
-- -- @return array[] Updated array of personal data exporters.
-- --
-- function wp_register_media_personal_data_exporter( exporters ) then
--         exporters["wordpress-media"] = array(
--                 "exporter_friendly_name" => __( "WordPress Media" ),
--                 "callback"               => "wp_media_personal_data_exporter",
--         );

--         return exporters;
-- end;

-- --
-- -- Finds and exports attachments associated with an email address.
-- --
-- -- @since 4.9.6
-- --
-- -- @param string email_address The attachment owner email address.
-- -- @param int    page          Attachment page.
-- -- @return array An array of personal data.
-- --
-- function wp_media_personal_data_exporter( email_address, page = 1 ) then
--         -- Limit us to 50 attachments at a time to avoid timing out.
--         number = 50;
--         page   = (int) page;

--         data_to_export = array();

--         user = get_user_by( "email", email_address );
--         if ( false === user ) then
--                 return array(
--                         "data" => data_to_export,
--                         "done" => true,
--                 );
--         end;

--         post_query = new WP_Query(
--                 array(
--                         "author"         => user->ID,
--                         "posts_per_page" => number,
--                         "paged"          => page,
--                         "post_type"      => "attachment",
--                         "post_status"    => "any",
--                         "orderby"        => "ID",
--                         "order"          => "ASC",
--                 )
--         );

--         foreach ( (array) post_query->posts as post ) then
--                 attachment_url = wp_get_attachment_url( post->ID );

--                 if ( attachment_url ) then
--                         post_data_to_export = array(
--                                 array(
--                                         "name"  => __( "URL" ),
--                                         "value" => attachment_url,
--                                 ),
--                         );

--                         data_to_export[] = array(
--                                 "group_id"          => "media",
--                                 "group_label"       => __( "Media" ),
--                                 "group_description" => __( "User&#8217;s media data." ),
--                                 "item_id"           => "post-thenpost->IDend;",
--                                 "data"              => post_data_to_export,
--                         );
--                 end;
--         end;

--         done = post_query->max_num_pages <= page;

--         return array(
--                 "data" => data_to_export,
--                 "done" => done,
--         );
-- end;

-- --
-- -- Adds additional default image sub-sizes.
-- --
-- -- These sizes are meant to enhance the way WordPress displays images on the front-end on larger,
-- -- high-density devices. They make it possible to generate more suitable `srcset` and `sizes` attributes
-- -- when the users upload large images.
-- --
-- -- The sizes can be changed or removed by themes and plugins but that is not recommended.
-- -- The size "names" reflect the image dimensions, so changing the sizes would be quite misleading.
-- --
-- -- @since 5.3.0
-- -- @access private
-- --
-- function _wp_add_additional_image_sizes() then
--         -- 2x medium_large size.
--         add_image_size( "1536x1536", 1536, 1536 );
--         -- 2x large size.
--         add_image_size( "2048x2048", 2048, 2048 );
-- end;

-- --
-- -- Callback to enable showing of the user error when uploading .heic images.
-- --
-- -- @since 5.5.0
-- --
-- -- @param array[] plupload_settings The settings for Plupload.js.
-- -- @return array[] Modified settings for Plupload.js.
-- --
-- function wp_show_heic_upload_error( plupload_settings ) then
--         plupload_settings["heic_upload_error"] = true;
--         return plupload_settings;
-- end;

   ---------------------
   -- Wp_Getimagesize --
   ---------------------

-- function wp_getimagesize( filename, array &image_info = null ) then
--         -- Don't silence errors when in debug mode, unless running unit tests.
--         if ( defined( "WP_DEBUG" ) and then WP_DEBUG
--                 and then not defined( "WP_RUN_CORE_TESTS" )
--         ) then
--                 if ( 2 === func_num_args() ) then
--                         info = getimagesize( filename, image_info );
--                 end; else then
--                         info = getimagesize( filename );
--                 end;
--         end; else then
--                 /*
--                 -- Silencing notice and warning is intentional.
--                 --
--                 -- getimagesize() has a tendency to generate errors, such as
--                 -- "corrupt JPEG data: 7191 extraneous bytes before marker",
--                 -- even when it"s able to provide image size information.
--                 --
--                 -- See https://core.trac.wordpress.org/ticket/42480
--                 --
--                 if ( 2 === func_num_args() ) then
--                         -- phpcs:ignore WordPress.PHP.NoSilencedErrors
--                         info = @getimagesize( filename, image_info );
--                 end; else then
--                         -- phpcs:ignore WordPress.PHP.NoSilencedErrors
--                         info = @getimagesize( filename );
--                 end;
--         end;

--         if ( false not== info ) then
--                 return info;
--         end;

--         -- For PHP versions that don't support WebP images,
--         -- extract the image size info from the file headers.
--         if ( "image/webp" === wp_get_image_mime( filename ) ) then
--                 webp_info = wp_get_webp_info( filename );
--                 width     = webp_info["width"];
--                 height    = webp_info["height"];

--                 -- Mimic the native return format.
--                 if ( width and then height ) then
--                         return array(
--                                 width,
--                                 height,
--                                 IMAGETYPE_WEBP,
--                                 sprintf(
--                                         "width="%d" height="%d"",
--                                         width,
--                                         height
--                                 ),
--                                 "mime" => "image/webp",
--                         );
--                 end;
--         end;

--         -- The image could not be parsed.
--         return false;
-- end;

   ---------------------
   -- Wp_Getimagesize --
   ---------------------

   function Wp_Getimagesize (Filename : String)
                             return List_Type
   is
      Unused_Info : Array_Type;
   begin
      return Wp_Getimagesize (Filename, Unused_Info);
   end Wp_Getimagesize;

-- --
-- -- Extracts meta information about a WebP file: width, height, and type.
-- --
-- -- @since 5.8.0
-- --
-- -- @param string filename Path to a WebP file.
-- -- @return array then
-- --     An array of WebP image information.
-- --
-- --     @type int|false    width  Image width on success, false on failure.
-- --     @type int|false    height Image height on success, false on failure.
-- --     @type string|false type   The WebP type: one of "lossy", "lossless" or "animated-alpha".
-- --                                False on failure.
-- -- end;
-- --
-- function wp_get_webp_info( filename ) then
--         width  = false;
--         height = false;
--         type   = false;

--         if ( "image/webp" not== wp_get_image_mime( filename ) ) then
--                 return compact( "width", "height", "type" );
--         end;

--         magic = file_get_contents( filename, false, null, 0, 40 );

--         if ( false === magic ) then
--                 return compact( "width", "height", "type" );
--         end;

--         -- Make sure we got enough bytes.
--         if ( strlen( magic ) < 40 ) then
--                 return compact( "width", "height", "type" );
--         end;

--         -- The headers are a little different for each of the three formats.
--         -- Header values based on WebP docs, see https://developers.google.com/speed/webp/docs/riff_container.
--         switch ( substr( magic, 12, 4 ) ) then
--                 -- Lossy WebP.
--                 case "VP8 ":
--                         parts  = unpack( "v2", substr( magic, 26, 4 ) );
--                         width  = (int) ( parts[1] & 0x3FFF );
--                         height = (int) ( parts[2] & 0x3FFF );
--                         type   = "lossy";
--                         break;
--                 -- Lossless WebP.
--                 case "VP8L":
--                         parts  = unpack( "C4", substr( magic, 21, 4 ) );
--                         width  = (int) ( parts[1] | ( ( parts[2] & 0x3F ) << 8 ) ) + 1;
--                         height = (int) ( ( ( parts[2] & 0xC0 ) >> 6 ) | ( parts[3] << 2 ) | ( ( parts[4] & 0x03 ) << 10 ) ) + 1;
--                         type   = "lossless";
--                         break;
--                 -- Animated/alpha WebP.
--                 case "VP8X":
--                         -- Pad 24-bit int.
--                         width = unpack( "V", substr( magic, 24, 3 ) . "\x00" );
--                         width = (int) ( width[1] & 0xFFFFFF ) + 1;
--                         -- Pad 24-bit int.
--                         height = unpack( "V", substr( magic, 27, 3 ) . "\x00" );
--                         height = (int) ( height[1] & 0xFFFFFF ) + 1;
--                         type   = "animated-alpha";
--                         break;
--         end;

--         return compact( "width", "height", "type" );
-- end;

   ---------------------------------
   -- Wp_Get_Loading_Attr_Default --
   ---------------------------------

   function Wp_Get_Loading_Attr_Default (Context : String)
                                         return String
   is
      use Inc_Load;
      use Inc_Querys;
   begin
      -- Only elements with "the_content" or "the_post_thumbnail" context have
      -- special handling.
      if "the_content" /= Context and then "the_post_thumbnail" /= Context then
         return "lazy";
      end if;

      -- Only elements within the main query loop have special handling.
      if
        Is_Admin        or else
        not In_The_Loop or else
        not Is_Main_Query
      then
         return "lazy";
      end if;

      -- Increase the counter since this is a main query content element.
      declare
         Content_Media_Count : constant Integer :=
           Wp_Increase_Content_Media_Count;
      begin
         -- If the count so far is below the threshold, return `false` so that the
         -- `loading` attribute is omitted.
         if Content_Media_Count <= Wp_Omit_Loading_Attr_Threshold then
            return ""; -- false
         end if;
      end;

      -- For elements after the threshold, lazy-load them as usual.
      return "lazy";
   end Wp_Get_Loading_Attr_Default;

   ------------------------------------
   -- Wp_Omit_Loading_Attr_Threshold --
   ------------------------------------

   Static_Omit_Threshold_Set : Boolean := False;
   Static_Omit_Threshold     : Integer;

   function Wp_Omit_Loading_Attr_Threshold (Force : Boolean := False)
                                            return Integer
   is
      use Inc_Plugins;
   begin
      -- This function may be called multiple times. Run the filter only once per
      -- page load.
      if not Static_Omit_Threshold_Set or else Force then
--    if not Isset (Static_Omit_Threshold) or else Force then
         Static_Omit_Threshold_Set := True;
         --
         -- Filters the threshold for how many of the first content media elements
         -- to not lazy-load.
         --
         -- For these first content media elements, the `loading` attribute will
         -- be omitted. By default, this is the case for only the very first content
         -- media element.
         --
         --
         -- @since 5.9.0
         --
         -- @param int omit_threshold The number of media elements where the
         --                           `loading` attribute will not be added. Default 1.
         --
         Static_Omit_Threshold :=
           Apply_Filters ("wp_omit_loading_attr_threshold", 1);
      end if;

      return Static_Omit_Threshold;
   end Wp_Omit_Loading_Attr_Threshold;

   -------------------------------------
   -- Wp_Increase_Content_Media_Count --
   -------------------------------------

   Static_Content_Media_Count : Integer := 0;

   function Wp_Increase_Content_Media_Count (Amount : Integer := 1)
                                             return Integer
   is
   begin
      Static_Content_Media_Count := @ + Amount;

      return Static_Content_Media_Count;
   end Wp_Increase_Content_Media_Count;

end Inc_Media;
