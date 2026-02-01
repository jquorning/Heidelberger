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

   --
   -- Retrieves the requested data of the author of the current post.
   --
   -- Valid values for the `field` parameter include:
   --
   -- - admin_color
   -- - aim
   -- - comment_shortcuts
   -- - description
   -- - display_name
   -- - first_name
   -- - ID
   -- - jabber
   -- - last_name
   -- - nickname
   -- - plugins_last_view
   -- - plugins_per_page
   -- - rich_editing
   -- - syntax_highlighting
   -- - user_activation_key
   -- - user_description
   -- - user_email
   -- - user_firstname
   -- - user_lastname
   -- - user_level
   -- - user_login
   -- - user_nicename
   -- - user_pass
   -- - user_registered
   -- - user_status
   -- - user_url
   -- - yim
   --
   -- @since 2.8.0
   --
   -- @global WP_User authordata The current author"s data.
   --
   -- @param string    field   Optional. The user field to retrieve. Default empty.
   -- @param int|false user_id Optional. User ID.
   -- @return string The author's field from the current author"s DB object,
   --                otherwise an empty string.
   --
   function Get_The_Author_Meta (Field   : String  := "";
                                 User_Id : Integer := 0) -- false
                                 return String;

end Inc_Author_Templates;
