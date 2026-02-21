--
-- Multisite WordPress API
--
-- @package WordPress
-- @subpackage Multisite
-- @since 3.0.0
--

with Class_Sites;
with Class_Users;

package Inc_Ms_Functions
is

   --
   -- Gets the number of active sites on the installation.
   --
   -- The count is cached and updated twice daily. This is not a live count.
   --
   -- @since MU (3.0.0)
   -- @since 3.7.0 The `network_id` parameter has been deprecated.
   -- @since 4.8.0 The `network_id` parameter is now being used.
   --
   -- @param int|null network_id ID of the network. Default is the current network.
   -- @return int Number of active sites on the network.
   --
   function Get_Blog_Count (Network_Id : Integer := 0) -- := null
                            return Natural;

   --
   -- Gets one of a user's active blogs.
   --
   -- Returns the user's primary blog, if they have one and
   -- it is active. If it's inactive, function returns another
   -- active blog of the user. If none are found, the user
   -- is added as a Subscriber to the Dashboard Blog and that blog
   -- is returned.
   --
   -- @since MU (3.0.0)
   --
   -- @param int user_id The unique ID of the user
   -- @return WP_Site|void The blog object
   --
   function Get_Active_Blog_For_User (User_Id : Class_Users.User_Id_Type)
                                      return Class_Sites.Wp_Site
                                      is (Class_Sites.Null_Site);

end Inc_Ms_Functions;
