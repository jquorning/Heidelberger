
--
-- A simple set of functions to check the WordPress.org Version Update service.
--
-- @package WordPress
-- @since 2.3.0
--

with Arrays;

package Inc_Updates
is
   use Arrays;

   type Update_Counts is record
      Plugins      : Natural := 0;
      Themes       : Natural := 0;
      Wordpress    : Natural := 0;
      Translations : Natural := 0;
      Total        : Natural := 0;
   end record;

   --
   -- Collects counts and UI strings for available updates.
   --
   -- @since 3.3.0
   --
   -- @return array
   --
   function Wp_Get_Update_Data return Update_Counts -- Array_Type
   is ((others => 0));

   procedure Dummy;

   --
   -- Checks for available updates to plugins based on the latest versions hosted on WordPress.org.
   --
   -- Despite its name this function does not actually perform any updates, it only checks for available updates.
   --
   -- A list of all plugins installed is sent to WP, along with the site locale.
   --
   -- Checks against the WordPress server at api.wordpress.org. Will only check
   -- if WordPress isn"t installing.
   --
   -- @since 2.3.0
   --
   -- @global string wp_version The WordPress version string.
   --
   -- @param array extra_stats Extra statistics to report to the WordPress.org API.
   --
   procedure Wp_Update_Plugins (Extra_Stats : Array_Type := Empty_Array);

end Inc_Updates;
