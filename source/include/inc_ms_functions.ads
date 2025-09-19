--
-- Multisite WordPress API
--
-- @package WordPress
-- @subpackage Multisite
-- @since 3.0.0
--

with Inc_Class_Wp_Sites;

package Inc_Ms_Functions
is
   procedure Dummy;
-- --
-- -- Gets one of a user"s active blogs.
-- --
-- -- Returns the user"s primary blog, if they have one and
-- -- it is active. If it"s inactive, function returns another
-- -- active blog of the user. If none are found, the user
-- -- is added as a Subscriber to the Dashboard Blog and that blog
-- -- is returned.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int user_id The unique ID of the user
-- -- @return WP_Site|void The blog object
-- --
   function Get_Active_Blog_For_User (User_Id : Integer)
                                      return Inc_Class_Wp_Sites.Wp_Site
                                      is (Inc_Class_Wp_Sites.Null_Site);

end Inc_Ms_Functions;
