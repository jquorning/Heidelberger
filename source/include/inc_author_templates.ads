--
-- Author Template functions for use in themes.
--
-- These functions must be used within the WordPress Loop.
--
-- @link https://codex.wordpress.org/Author_Templates
--
-- @package WordPress
-- @subpackage Template
--

package Inc_Author_Templates
is
   procedure Dummy;
--
-- Retrieves the URL to the author page for the user with the ID provided.
--
-- @since 2.1.0
--
-- @global WP_Rewrite $wp_rewrite WordPress rewrite component.
--
-- @param int    $author_id       Author ID.
-- @param string $author_nicename Optional. The author's nicename (slug). Default empty.
-- @return string The URL to the author's page.
--
   function Get_Author_Posts_Url (Author_Id       : Integer;
                                  Author_Nicename : String := "")
                                  return String
                                  is ("XXX-370");

end Inc_Author_Templates;
