--
-- Loads the WordPress environment and template.
--
-- @package WordPress
--

with Globals;

with Inc_Functions;
with Inc_Template_Loader;

with Wp_Load;

package body Wp_Blog_Header
is

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Globals;
      use Inc_Functions;
   begin
      if not Global_Wp_Did_Header then
--    if not Isset (Global_Wp_Did_Header) then

         Global_Wp_Did_Header := True;

         -- Load the WordPress library.
         Wp_Load.Run;

         -- Set up the WordPress query.
         Wp;

         -- Load the theme template.
         Inc_Template_Loader.Render;

      end if;
   end Render;

end Wp_Blog_Header;
