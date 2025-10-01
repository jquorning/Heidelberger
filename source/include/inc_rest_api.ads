--
-- REST API functions.
--
-- @package WordPress
-- @subpackage REST_API
-- @since 4.4.0
--

package Inc_REST_API
is
   procedure Dummy;

   --
   -- Retrieves the URL to a REST endpoint on a site.
   --
   -- Note: The returned URL is NOT escaped.
   --
   -- @since 4.4.0
   --
   -- @todo Check if this is even necessary
   -- @global WP_Rewrite $wp_rewrite WordPress rewrite component.
   --
   -- @param int|null $blog_id Optional. Blog ID. Default of null returns URL for
   --                          current blog.
   -- @param string   $path    Optional. REST route. Default '/'.
   -- @param string   $scheme  Optional. Sanitization scheme. Default 'rest'.
   -- @return string Full URL to the endpoint.
   --
   function Get_REST_URL (Blog_Id : Integer := 0; -- null
                          Path    : String  := "/";
                          Scheme  : String  := "rest")
                          return String
                          is ("XXX-781");

end Inc_REST_API;
