
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
--
-- Collects counts and UI strings for available updates.
--
-- @since 3.3.0
--
-- @return array
--
   function Wp_Get_Update_Data
            return Array_Type
            is (Empty_Array);

   procedure Dummy;

end Inc_Updates;
