--
-- Front to the WordPress application. This file doesn't do anything, but loads
-- wp-blog-header.php which does and tells WordPress to load the theme.
--
-- @package WordPress
--

with Constants;

with Wp_Blog_Header;

package body Wp_Index
is

   --
   --
   --
   procedure Render
   is
   begin
      --
      -- Tells WordPress to load the WordPress theme and output it.
      --
      -- @var bool
      --
      Constants.WP_USE_THEMES := True;

      -- Loads the WordPress Environment and Template
      Wp_Blog_Header.Render;
   end Render;

end Wp_Index;
