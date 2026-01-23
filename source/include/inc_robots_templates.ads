--
-- Robots template functions.
--
-- @package WordPress
-- @subpackage Robots
-- @since 5.7.0
--

with Arrays;

package Inc_Robots_Templates
is
   use Arrays;

-- --
-- -- Displays the robots meta tag as necessary.
-- --
-- -- Gathers robots directives to include for the current context, using the
-- -- then@see "wp_robots"end; filter. The directives are then sanitized, and the
-- -- robots meta tag is output if there is at least one relevant directive.
-- --
-- -- @since 5.7.0
-- -- @since 5.7.1 No longer prevents specific directives to occur together.
-- --
-- function wp_robots() then
--         --
--         -- Filters the directives to be included in the "robots" meta tag.
--         --
--         -- The meta tag will only be included as necessary.
--         --
--         -- @since 5.7.0
--         --
--         -- @param array robots Associative array of directives. Every key must be the name of the directive, and the
--         --                      corresponding value must either be a string to provide as value for the directive or a
--         --                      boolean `true` if it is a boolean directive, i.e. without a value.
--         --
--         robots = apply_filters( "wp_robots", array() );

--         robots_strings = array();
--         foreach ( robots as directive => value ) then
--                 if ( is_string( value ) ) then
--                         // If a string value, include it as value for the directive.
--                         robots_strings[] = "thendirectiveend;:thenvalueend;";
--                 end; elseif ( value ) then
--                         // Otherwise, include the directive if it is truthy.
--                         robots_strings[] = directive;
--                 end;
--         end;

--         if ( empty( robots_strings ) ) then
--                 return;
--         end;

--         echo "<meta name="robots" content="" . esc_attr( implode( ", ", robots_strings ) ) . "" />\n";
-- end;

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

-- --
-- -- Adds `max-image-preview:large` to the robots meta tag.
-- --
-- -- This directive tells web robots that large image previews are allowed to be
-- -- displayed, e.g. in search engines, unless the blog is marked as not being public.
-- --
-- -- Typical usage is as a then@see "wp_robots"end; callback:
-- --
-- --     add_filter( "wp_robots", "wp_robots_max_image_preview_large" );
-- --
-- -- @since 5.7.0
-- --
-- -- @param array robots Associative array of robots directives.
-- -- @return array Filtered robots directives.
-- --
-- function wp_robots_max_image_preview_large( array robots ) then
--         if ( get_option( "blog_public" ) ) then
--                 robots["max-image-preview"] = "large";
--         end;
--         return robots;
-- end;

end Inc_Robots_Templates;
