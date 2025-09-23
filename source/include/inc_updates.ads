
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

   type Update_Counts is
      record
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
   function Wp_Get_Update_Data
            return Update_Counts -- Array_Type
            is ((others => 0));

   procedure Dummy;

end Inc_Updates;
