--
-- Site/blog functions that work with the blogs table and related data.
--
-- @package WordPress
-- @subpackage Multisite
-- @since MU (3.0.0)
--

with Arrays;

with Inc_Class_Wp_Sites;

package Inc_Ms_Blogs
is
   use Arrays;

   --
   -- Retrieve the details for a blog from the blogs table and blog options.
   --
   -- @since MU (3.0.0)
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int|string|array fields  Optional. A blog ID, a blog slug, or an array
   --                                 of fields to query against. If not specified
   --                                 the current blog ID is used.
   -- @param bool             get_all Whether to retrieve all details or only the
   --                                 details in the blogs table. Default is true.
   -- @return WP_Site|false Blog details on success. False on failure.
   --
   function Get_Blog_Details (Fields  : String  := ""; -- null
                              Get_All : Boolean := True)
                              return Inc_Class_Wp_Sites.Wp_Site;

   --
   -- Switch the current blog.
   --
   -- This function is useful if you need to pull posts, or other information,
   -- from other blogs. You can switch back afterwards using restore_current_blog().
   --
   -- Things that aren"t switched:
   --  - plugins. See #14941
   --
   -- @see restore_current_blog()
   -- @since MU (3.0.0)
   --
   -- @global wpdb            wpdb               WordPress database abstraction object.
   -- @global int             blog_id
   -- @global array           _wp_switched_stack
   -- @global bool            switched
   -- @global string          table_prefix
   -- @global WP_Object_Cache wp_object_cache
   --
   -- @param int  new_blog_id The ID of the blog to switch to. Default: current blog.
   -- @param bool deprecated  Not used.
   -- @return true Always returns true.
   --
   function Switch_To_Blog (New_Blog_Id : Integer;
                            Deprecated  : Boolean := False) -- = null
                            return Boolean
                            is (True);

   procedure Switch_To_Blog (New_Blog_Id : Integer;
                             Deprecated  : Boolean := False) -- = null
                             is null;

   --
   -- Restore the current blog, after calling switch_to_blog().
   --
   -- @see switch_to_blog()
   -- @since MU (3.0.0)
   --
   -- @global wpdb            wpdb               WordPress database abstraction object.
   -- @global array           _wp_switched_stack
   -- @global int             blog_id
   -- @global bool            switched
   -- @global string          table_prefix
   -- @global WP_Object_Cache wp_object_cache
   --
   -- @return bool True on success, false if we"re already on the current blog.
   --
   function Restore_Current_Blog
            return Boolean
            is (True);

   procedure Restore_Current_Blog
             is null;

   --
   -- Switches the initialized roles and current user capabilities to another site.
   --
   -- @since 4.9.0
   --
   -- @param int new_site_id New site ID.
   -- @param int old_site_id Old site ID.
   --
   procedure Wp_Switch_Roles_And_User (New_Site_Id : Integer;
                                       Old_Site_Id : Integer);

   --
   -- Retrieve option value for a given blog id based on name of option.
   --
   -- If the option does not exist or does not have a value, then the return value
   -- will be false. This is useful to check whether you need to install an option
   -- and is commonly used during installation of plugin options and to test
   -- whether upgrading is required.
   --
   -- If the option was serialized then it will be unserialized when it is returned.
   --
   -- @since MU (3.0.0)
   --
   -- @param int    id      A blog ID. Can be null to refer to the current blog.
   -- @param string option  Name of option to retrieve. Expected to not be SQL-escaped.
   -- @param mixed  default Optional. Default value to return if the option does not
   --                        exist.
   -- @return mixed Value set for the option.
   --
   function Get_Blog_Option (Id      : Integer;
                             Option  : String;
                             Default : Array_Type := Empty_Array) -- false
                             return Array_Type;

end Inc_Ms_Blogs;
