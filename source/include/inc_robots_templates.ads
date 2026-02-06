--
-- Robots template functions.
--
-- @package WordPress
-- @subpackage Robots
-- @since 5.7.0
--

with Arrayable_Interfaces;
with Arrays;
with Helpers_2;

package Inc_Robots_Templates
is
   use Arrays;

   --
   -- Displays the robots meta tag as necessary.
   --
   -- Gathers robots directives to include for the current context, using the
   -- {@see "wp_robots"} filter. The directives are then sanitized, and the
   -- robots meta tag is output if there is at least one relevant directive.
   --
   -- @since 5.7.0
   -- @since 5.7.1 No longer prevents specific directives to occur together.
   --
   procedure Wp_Robots;

   function Wp_Robots
     is new Helpers_2.Generic_Call_Procedure (Wp_Robots);

-- --
-- -- Adds `noindex` to the robots meta tag if required by the site configuration.
-- --
-- -- If a blog is marked as not being public then noindex will be output to
-- -- tell web robots not to index the page content. Add this to the
-- -- then@see "wp_robots"end; filter.
-- --
-- -- Typical usage is as a then@see "wp_robots"end; callback:
-- --
-- --     add_filter( "wp_robots", "wp_robots_noindex" );
-- --
-- -- @since 5.7.0
-- --
-- -- @see wp_robots_no_robots()
-- --
-- -- @param array robots Associative array of robots directives.
-- -- @return array Filtered robots directives.
-- --
-- function wp_robots_noindex( array robots ) then
--         if ( ! get_option( "blog_public" ) ) then
--                 return wp_robots_no_robots( robots );
--         end;

--         return robots;
-- end;

-- --
-- -- Adds `noindex` to the robots meta tag for embeds.
-- --
-- -- Typical usage is as a then@see "wp_robots"end; callback:
-- --
-- --     add_filter( "wp_robots", "wp_robots_noindex_embeds" );
-- --
-- -- @since 5.7.0
-- --
-- -- @see wp_robots_no_robots()
-- --
-- -- @param array robots Associative array of robots directives.
-- -- @return array Filtered robots directives.
-- --
-- function wp_robots_noindex_embeds( array robots ) then
--         if ( is_embed() ) then
--                 return wp_robots_no_robots( robots );
--         end;

--         return robots;
-- end;

-- --
-- -- Adds `noindex` to the robots meta tag if a search is being performed.
-- --
-- -- If a search is being performed then noindex will be output to
-- -- tell web robots not to index the page content. Add this to the
-- -- then@see "wp_robots"end; filter.
-- --
-- -- Typical usage is as a then@see "wp_robots"end; callback:
-- --
-- --     add_filter( "wp_robots", "wp_robots_noindex_search" );
-- --
-- -- @since 5.7.0
-- --
-- -- @see wp_robots_no_robots()
-- --
-- -- @param array robots Associative array of robots directives.
-- -- @return array Filtered robots directives.
-- --
-- function wp_robots_noindex_search( array robots ) then
--         if ( is_search() ) then
--                 return wp_robots_no_robots( robots );
--         end;

--         return robots;
-- end;

-- --
-- -- Adds `noindex` to the robots meta tag.
-- --
-- -- This directive tells web robots not to index the page content.
-- --
-- -- Typical usage is as a then@see "wp_robots"end; callback:
-- --
-- --     add_filter( "wp_robots", "wp_robots_no_robots" );
-- --
-- -- @since 5.7.0
-- --
-- -- @param array robots Associative array of robots directives.
-- -- @return array Filtered robots directives.
-- --
-- function wp_robots_no_robots( array robots ) then
--         robots["noindex"] = true;

--         if ( get_option( "blog_public" ) ) then
--                 robots["follow"] = true;
--         end; else then
--                 robots["nofollow"] = true;
--         end;

--         return robots;
-- end;

   --
   -- Adds `noindex` and `noarchive` to the robots meta tag.
   --
   -- This directive tells web robots not to index or archive the page content and
   -- is recommended to be used for sensitive pages.
   --
   -- Typical usage is as a then@see "wp_robots"end; callback:
   --
   --     add_filter( "wp_robots", "wp_robots_sensitive_page" );
   --
   -- @since 5.7.0
   --
   -- @param array robots Associative array of robots directives.
   -- @return array Filtered robots directives.
   --
   function Wp_Robots_Sensitive_Page (Robots : Array_Type)
                                      return Array_Type;

   function Wp_Robots_Sensitive_Page
              (Robots : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Array_Type;

-- procedure Wp_Robots_Sensitive_Page; -- For Add_Filer -- jq

   --
   -- Adds `max-image-preview:large` to the robots meta tag.
   --
   -- This directive tells web robots that large image previews are allowed to be
   -- displayed, e.g. in search engines, unless the blog is marked as not being public.
   --
   -- Typical usage is as a {@see "wp_robots"} callback:
   --
   --     add_filter( "wp_robots", "wp_robots_max_image_preview_large" );
   --
   -- @since 5.7.0
   --
   -- @param array robots Associative array of robots directives.
   -- @return array Filtered robots directives.
   --
   function Wp_Robots_Max_Image_Preview_Large (Robots : Array_Type)
                                               return Array_Type;

   function Wp_Robots_Max_Image_Preview_Large
              (Robots : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Array_Type;

end Inc_Robots_Templates;
