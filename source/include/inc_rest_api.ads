--
-- REST API functions.
--
-- @package WordPress
-- @subpackage REST_API
-- @since 4.4.0
--

with Arrays;

package Inc_REST_API
is
   use Arrays;

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

   --
   -- Sets the "additionalProperties" to false by default for all object definitions
   -- in the schema.
   --
   -- @since 5.5.0
   -- @since 5.6.0 Support the "patternProperties" keyword.
   --
   -- @param array $schema The schema to modify.
   -- @return array The modified schema.
   --
   function REST_Default_Additional_Properties_To_False
              (Schema : Array_Type)
               return Array_Type;

end Inc_REST_API;
