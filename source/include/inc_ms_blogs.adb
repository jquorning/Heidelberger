--
-- Site/blog functions that work with the blogs table and related data.
--
-- @package WordPress
-- @subpackage Multisite
-- @since MU (3.0.0)
--

-- require_once ABSPATH . WPINC . "/ms-site.php";
-- require_once ABSPATH . WPINC . "/ms-network.php";

with Inc_Capabilities;
with Inc_Class_Wp_Roles;
with Class_Users;
with Inc_Load;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;

package body Inc_Ms_Blogs
is

-- --
-- -- Update the last_updated field for the current site.
-- --
-- -- @since MU (3.0.0)
-- --
-- function wpmu_update_blogs_date() then
--         site_id = get_current_blog_id();

--         update_blog_details( site_id, array( "last_updated" => current_time( "mysql", true ) ) );
--         --
--         -- Fires after the blog details are updated.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param int blog_id Site ID.
--         --
--         do_action( "wpmu_blog_updated", site_id );
-- end;

-- --
-- -- Get a full blog URL, given a blog ID.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int blog_id Blog ID.
-- -- @return string Full URL of the blog if found. Empty string if not.
-- --
-- function get_blogaddress_by_id( blog_id ) then
--         bloginfo = get_site( (int) blog_id );

--         if ( empty( bloginfo ) ) then
--                 return "";
--         end;

--         scheme = parse_url( bloginfo.home, PHP_URL_SCHEME );
--         scheme = empty( scheme ) ? "http" : scheme;

--         return esc_url( scheme . "://" . bloginfo.domain . bloginfo.path );
-- end;

-- --
-- -- Get a full blog URL, given a blog name.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string blogname The (subdomain or directory) name
-- -- @return string
-- --
-- function get_blogaddress_by_name( blogname ) then
--         if ( is_subdomain_install() ) then
--                 if ( "main" === blogname ) then
--                         blogname = "www";
--                 end;
--                 url = rtrim( network_home_url(), "/" );
--                 if ( ! empty( blogname ) ) then
--                         url = preg_replace( "|^([^\.]+://)|", "then1end;" . blogname . ".", url );
--                 end;
--         end; else then
--                 url = network_home_url( blogname );
--         end;
--         return esc_url( url . "/" );
-- end;

-- --
-- -- Retrieves a site"s ID given its (subdomain or directory) slug.
-- --
-- -- @since MU (3.0.0)
-- -- @since 4.7.0 Converted to use `get_sites()`.
-- --
-- -- @param string slug A site"s slug.
-- -- @return int|null The site ID, or null if no site is found for the given slug.
-- --
-- function get_id_from_blogname( slug ) then
--         current_network = get_network();
--         slug            = trim( slug, "/" );

--         if ( is_subdomain_install() ) then
--                 domain = slug . "." . preg_replace( "|^www\.|", "", current_network.domain );
--                 path   = current_network.path;
--         end; else then
--                 domain = current_network.domain;
--                 path   = current_network.path . slug . "/";
--         end;

--         site_ids = get_sites(
--                 array(
--                         "number"                 => 1,
--                         "fields"                 => "ids",
--                         "domain"                 => domain,
--                         "path"                   => path,
--                         "update_site_meta_cache" => false,
--                 )
--         );

--         if ( empty( site_ids ) ) then
--                 return null;
--         end;

--         return array_shift( site_ids );
-- end;

   ----------------------
   -- Get_Blog_Details --
   ----------------------

   function Get_Blog_Details (Fields  : String  := ""; -- null
                              Get_All : Boolean := True)
                              return Inc_Class_Wp_Sites.Wp_Site
   is (raise Program_Error with "not implemented");
--         global wpdb;

--         if ( is_array( fields ) ) then
--                 if ( isset( fields["blog_id"] ) ) then
--                         blog_id = fields["blog_id"];
--                 end; elseif ( isset( fields["domain"] ) && isset( fields["path"] ) ) then
--                         key  = md5( fields["domain"] . fields["path"] );
--                         blog = wp_cache_get( key, "blog-lookup" );
--                         if ( false !== blog ) then
--                                 return blog;
--                         end;
--                         if ( "www." === substr( fields["domain"], 0, 4 ) ) then
--                                 nowww = substr( fields["domain"], 4 );
--                                 blog  = wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.blogs WHERE domain IN (%s,%s) AND path = %s ORDER BY CHAR_LENGTH(domain) DESC", nowww, fields["domain"], fields["path"] ) );
--                         end; else then
--                                 blog = wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.blogs WHERE domain = %s AND path = %s", fields["domain"], fields["path"] ) );
--                         end;
--                         if ( blog ) then
--                                 wp_cache_set( blog.blog_id . "short", blog, "blog-details" );
--                                 blog_id = blog.blog_id;
--                         end; else then
--                                 return false;
--                         end;
--                 end; elseif ( isset( fields["domain"] ) && is_subdomain_install() ) then
--                         key  = md5( fields["domain"] );
--                         blog = wp_cache_get( key, "blog-lookup" );
--                         if ( false !== blog ) then
--                                 return blog;
--                         end;
--                         if ( "www." === substr( fields["domain"], 0, 4 ) ) then
--                                 nowww = substr( fields["domain"], 4 );
--                                 blog  = wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.blogs WHERE domain IN (%s,%s) ORDER BY CHAR_LENGTH(domain) DESC", nowww, fields["domain"] ) );
--                         end; else then
--                                 blog = wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.blogs WHERE domain = %s", fields["domain"] ) );
--                         end;
--                         if ( blog ) then
--                                 wp_cache_set( blog.blog_id . "short", blog, "blog-details" );
--                                 blog_id = blog.blog_id;
--                         end; else then
--                                 return false;
--                         end;
--                 end; else then
--                         return false;
--                 end;
--         end; else then
--                 if ( ! fields ) then
--                         blog_id = get_current_blog_id();
--                 end; elseif ( ! is_numeric( fields ) ) then
--                         blog_id = get_id_from_blogname( fields );
--                 end; else then
--                         blog_id = fields;
--                 end;
--         end;

--         blog_id = (int) blog_id;

--         all     = get_all ? "" : "short";
--         details = wp_cache_get( blog_id . all, "blog-details" );

--         if ( details ) then
--                 if ( ! is_object( details ) ) then
--                         if ( -1 == details ) then
--                                 return false;
--                         end; else then
--                                 // Clear old pre-serialized objects. Cache clients do better with that.
--                                 wp_cache_delete( blog_id . all, "blog-details" );
--                                 unset( details );
--                         end;
--                 end; else then
--                         return details;
--                 end;
--         end;

--         // Try the other cache.
--         if ( get_all ) then
--                 details = wp_cache_get( blog_id . "short", "blog-details" );
--         end; else then
--                 details = wp_cache_get( blog_id, "blog-details" );
--                 // If short was requested and full cache is set, we can return.
--                 if ( details ) then
--                         if ( ! is_object( details ) ) then
--                                 if ( -1 == details ) then
--                                         return false;
--                                 end; else then
--                                         // Clear old pre-serialized objects. Cache clients do better with that.
--                                         wp_cache_delete( blog_id, "blog-details" );
--                                         unset( details );
--                                 end;
--                         end; else then
--                                 return details;
--                         end;
--                 end;
--         end;

--         if ( empty( details ) ) then
--                 details = WP_Site::get_instance( blog_id );
--                 if ( ! details ) then
--                         // Set the full cache.
--                         wp_cache_set( blog_id, -1, "blog-details" );
--                         return false;
--                 end;
--         end;

--         if ( ! details instanceof WP_Site ) then
--                 details = new WP_Site( details );
--         end;

--         if ( ! get_all ) then
--                 wp_cache_set( blog_id . all, details, "blog-details" );
--                 return details;
--         end;

--         switched_blog = false;

--         if ( get_current_blog_id() !== blog_id ) then
--                 switch_to_blog( blog_id );
--                 switched_blog = true;
--         end;

--         details.blogname   = get_option( "blogname" );
--         details.siteurl    = get_option( "siteurl" );
--         details.post_count = get_option( "post_count" );
--         details.home       = get_option( "home" );

--         if ( switched_blog ) then
--                 restore_current_blog();
--         end;

--         --
--         -- Filters a blog"s details.
--         --
--         -- @since MU (3.0.0)
--         -- @deprecated 4.7.0 Use {@see "site_details"} instead.
--         --
--         -- @param WP_Site details The blog details.
--         --
--         details = apply_filters_deprecated( "blog_details", array( details ), "4.7.0", "site_details" );

--         wp_cache_set( blog_id . all, details, "blog-details" );

--         key = md5( details.domain . details.path );
--         wp_cache_set( key, details, "blog-lookup" );

--         return details;
-- end;

-- --
-- -- Clear the blog details cache.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int blog_id Optional. Blog ID. Defaults to current blog.
-- --
-- function refresh_blog_details( blog_id = 0 ) then
--         blog_id = (int) blog_id;
--         if ( ! blog_id ) then
--                 blog_id = get_current_blog_id();
--         end;

--         clean_blog_cache( blog_id );
-- end;

-- --
-- -- Update the details for a blog. Updates the blogs table for a given blog ID.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int   blog_id Blog ID.
-- -- @param array details Array of details keyed by blogs table field names.
-- -- @return bool True if update succeeds, false otherwise.
-- --
-- function update_blog_details( blog_id, details = array() ) then
--         global wpdb;

--         if ( empty( details ) ) then
--                 return false;
--         end;

--         if ( is_object( details ) ) then
--                 details = get_object_vars( details );
--         end;

--         site = wp_update_site( blog_id, details );

--         if ( is_wp_error( site ) ) then
--                 return false;
--         end;

--         return true;
-- end;

-- --
-- -- Cleans the site details cache for a site.
-- --
-- -- @since 4.7.4
-- --
-- -- @param int site_id Optional. Site ID. Default is the current site ID.
-- --
-- function clean_site_details_cache( site_id = 0 ) then
--         site_id = (int) site_id;
--         if ( ! site_id ) then
--                 site_id = get_current_blog_id();
--         end;

--         wp_cache_delete( site_id, "site-details" );
--         wp_cache_delete( site_id, "blog-details" );
-- end;

   ---------------------
   -- Get_Blog_Option --
   ---------------------

   function Get_Blog_Option (Id      : Integer;
                             Option  : String;
                             Default : Array_Type := Empty_Array) -- false
                             return Array_Type
   is
      use Inc_Load;
      use Inc_Options;
      use Inc_Plugins;

      Id_2 : constant Integer :=
        (if Id = 0
         then Get_Current_Blog_Id
         else Id);

      Value : Array_Type;
   begin
      if Get_Current_Blog_Id = Id_2 then
         return Get_Option (Option, Default);
      end if;

      Switch_To_Blog (Id_2);
      Value := Get_Option (Option, Default);
      Restore_Current_Blog; -- ()

      --
      -- Filters a blog option value.
      --
      -- The dynamic portion of the hook name, `option`, refers to the blog
      -- option name.
      --
      -- @since 3.5.0
      --
      -- @param string  value The option value.
      -- @param int     id    Blog ID.
      --
      return Apply_Filters ("blog_option_" & Option, Value, Id_2);
   end Get_Blog_Option;

-- --
-- -- Add a new option for a given blog ID.
-- --
-- -- You do not need to serialize values. If the value needs to be serialized, then
-- -- it will be serialized before it is inserted into the database. Remember,
-- -- resources can not be serialized or added as an option.
-- --
-- -- You can create options without values and then update the values later.
-- -- Existing options will not be updated and checks are performed to ensure that you
-- -- aren"t adding a protected WordPress option. Care should be taken to not name
-- -- options the same as the ones which are protected.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int    id     A blog ID. Can be null to refer to the current blog.
-- -- @param string option Name of option to add. Expected to not be SQL-escaped.
-- -- @param mixed  value  Optional. Option value, can be anything. Expected to not be SQL-escaped.
-- -- @return bool True if the option was added, false otherwise.
-- --
-- function add_blog_option( id, option, value ) then
--         id = (int) id;

--         if ( empty( id ) ) then
--                 id = get_current_blog_id();
--         end;

--         if ( get_current_blog_id() == id ) then
--                 return add_option( option, value );
--         end;

--         switch_to_blog( id );
--         return = add_option( option, value );
--         restore_current_blog();

--         return return;
-- end;

-- --
-- -- Removes option by name for a given blog ID. Prevents removal of protected WordPress options.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int    id     A blog ID. Can be null to refer to the current blog.
-- -- @param string option Name of option to remove. Expected to not be SQL-escaped.
-- -- @return bool True if the option was deleted, false otherwise.
-- --
-- function delete_blog_option( id, option ) then
--         id = (int) id;

--         if ( empty( id ) ) then
--                 id = get_current_blog_id();
--         end;

--         if ( get_current_blog_id() == id ) then
--                 return delete_option( option );
--         end;

--         switch_to_blog( id );
--         return = delete_option( option );
--         restore_current_blog();

--         return return;
-- end;

-- --
-- -- Update an option for a particular blog.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int    id         The blog ID.
-- -- @param string option     The option key.
-- -- @param mixed  value      The option value.
-- -- @param mixed  deprecated Not used.
-- -- @return bool True if the value was updated, false otherwise.
-- --
-- function update_blog_option( id, option, value, deprecated = null ) then
--         id = (int) id;

--         if ( null !== deprecated ) then
--                 _deprecated_argument( __FUNCTION__, "3.1.0" );
--         end;

--         if ( get_current_blog_id() == id ) then
--                 return update_option( option, value );
--         end;

--         switch_to_blog( id );
--         return = update_option( option, value );
--         restore_current_blog();

--         return return;
-- end;

-- --
-- -- Switch the current blog.
-- --
-- -- This function is useful if you need to pull posts, or other information,
-- -- from other blogs. You can switch back afterwards using restore_current_blog().
-- --
-- -- Things that aren"t switched:
-- --  - plugins. See #14941
-- --
-- -- @see restore_current_blog()
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb            wpdb               WordPress database abstraction object.
-- -- @global int             blog_id
-- -- @global array           _wp_switched_stack
-- -- @global bool            switched
-- -- @global string          table_prefix
-- -- @global WP_Object_Cache wp_object_cache
-- --
-- -- @param int  new_blog_id The ID of the blog to switch to. Default: current blog.
-- -- @param bool deprecated  Not used.
-- -- @return true Always returns true.
-- --
-- function switch_to_blog( new_blog_id, deprecated = null ) then
--         global wpdb;

--         prev_blog_id = get_current_blog_id();
--         if ( empty( new_blog_id ) ) then
--                 new_blog_id = prev_blog_id;
--         end;

--         GLOBALS["_wp_switched_stack"][] = prev_blog_id;

--         /*
--         -- If we"re switching to the same blog id that we"re on,
--         -- set the right vars, do the associated actions, but skip
--         -- the extra unnecessary work
--         --
--         if ( new_blog_id == prev_blog_id ) then
--                 --
--                 -- Fires when the blog is switched.
--                 --
--                 -- @since MU (3.0.0)
--                 -- @since 5.4.0 The `context` parameter was added.
--                 --
--                 -- @param int    new_blog_id  New blog ID.
--                 -- @param int    prev_blog_id Previous blog ID.
--                 -- @param string context      Additional context. Accepts "switch" when called from switch_to_blog()
--                 --                             or "restore" when called from restore_current_blog().
--                 --
--                 do_action( "switch_blog", new_blog_id, prev_blog_id, "switch" );

--                 GLOBALS["switched"] = true;

--                 return true;
--         end;

--         wpdb.set_blog_id( new_blog_id );
--         GLOBALS["table_prefix"] = wpdb.get_blog_prefix();
--         GLOBALS["blog_id"]      = new_blog_id;

--         if ( function_exists( "wp_cache_switch_to_blog" ) ) then
--                 wp_cache_switch_to_blog( new_blog_id );
--         end; else then
--                 global wp_object_cache;

--                 if ( is_object( wp_object_cache ) && isset( wp_object_cache.global_groups ) ) then
--                         global_groups = wp_object_cache.global_groups;
--                 end; else then
--                         global_groups = false;
--                 end;

--                 wp_cache_init();

--                 if ( function_exists( "wp_cache_add_global_groups" ) ) then
--                         if ( is_array( global_groups ) ) then
--                                 wp_cache_add_global_groups( global_groups );
--                         end; else then
--                                 wp_cache_add_global_groups(
--                                         array(
--                                                 "blog-details",
--                                                 "blog-id-cache",
--                                                 "blog-lookup",
--                                                 "blog_meta",
--                                                 "global-posts",
--                                                 "networks",
--                                                 "sites",
--                                                 "site-details",
--                                                 "site-options",
--                                                 "site-transient",
--                                                 "rss",
--                                                 "users",
--                                                 "useremail",
--                                                 "userlogins",
--                                                 "usermeta",
--                                                 "user_meta",
--                                                 "userslugs",
--                                         )
--                                 );
--                         end;

--                         wp_cache_add_non_persistent_groups( array( "counts", "plugins" ) );
--                 end;
--         end;

--         -- This filter is documented in wp-includes/ms-blogs.php--
--         do_action( "switch_blog", new_blog_id, prev_blog_id, "switch" );

--         GLOBALS["switched"] = true;

--         return true;
-- end;

-- --
-- -- Restore the current blog, after calling switch_to_blog().
-- --
-- -- @see switch_to_blog()
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb            wpdb               WordPress database abstraction object.
-- -- @global array           _wp_switched_stack
-- -- @global int             blog_id
-- -- @global bool            switched
-- -- @global string          table_prefix
-- -- @global WP_Object_Cache wp_object_cache
-- --
-- -- @return bool True on success, false if we"re already on the current blog.
-- --
-- function restore_current_blog() then
--         global wpdb;

--         if ( empty( GLOBALS["_wp_switched_stack"] ) ) then
--                 return false;
--         end;

--         new_blog_id  = array_pop( GLOBALS["_wp_switched_stack"] );
--         prev_blog_id = get_current_blog_id();

--         if ( new_blog_id == prev_blog_id ) then
--                 -- This filter is documented in wp-includes/ms-blogs.php--
--                 do_action( "switch_blog", new_blog_id, prev_blog_id, "restore" );

--                 // If we still have items in the switched stack, consider ourselves still "switched".
--                 GLOBALS["switched"] = ! empty( GLOBALS["_wp_switched_stack"] );

--                 return true;
--         end;

--         wpdb.set_blog_id( new_blog_id );
--         GLOBALS["blog_id"]      = new_blog_id;
--         GLOBALS["table_prefix"] = wpdb.get_blog_prefix();

--         if ( function_exists( "wp_cache_switch_to_blog" ) ) then
--                 wp_cache_switch_to_blog( new_blog_id );
--         end; else then
--                 global wp_object_cache;

--                 if ( is_object( wp_object_cache ) && isset( wp_object_cache.global_groups ) ) then
--                         global_groups = wp_object_cache.global_groups;
--                 end; else then
--                         global_groups = false;
--                 end;

--                 wp_cache_init();

--                 if ( function_exists( "wp_cache_add_global_groups" ) ) then
--                         if ( is_array( global_groups ) ) then
--                                 wp_cache_add_global_groups( global_groups );
--                         end; else then
--                                 wp_cache_add_global_groups(
--                                         array(
--                                                 "blog-details",
--                                                 "blog-id-cache",
--                                                 "blog-lookup",
--                                                 "blog_meta",
--                                                 "global-posts",
--                                                 "networks",
--                                                 "sites",
--                                                 "site-details",
--                                                 "site-options",
--                                                 "site-transient",
--                                                 "rss",
--                                                 "users",
--                                                 "useremail",
--                                                 "userlogins",
--                                                 "usermeta",
--                                                 "user_meta",
--                                                 "userslugs",
--                                         )
--                                 );
--                         end;

--                         wp_cache_add_non_persistent_groups( array( "counts", "plugins" ) );
--                 end;
--         end;

--         -- This filter is documented in wp-includes/ms-blogs.php--
--         do_action( "switch_blog", new_blog_id, prev_blog_id, "restore" );

--         // If we still have items in the switched stack, consider ourselves still "switched".
--         GLOBALS["switched"] = ! empty( GLOBALS["_wp_switched_stack"] );

--         return true;
-- end;

   ------------------------------
   -- Wp_Switch_Roles_And_User --
   ------------------------------

   procedure Wp_Switch_Roles_And_User (New_Site_Id : Integer;
                                       Old_Site_Id : Integer)
   is
      use Inc_Capabilities;
      use Inc_Pluggables;
      use Inc_Plugins;
   begin
      if New_Site_Id = Old_Site_Id then
         return;
      end if;

      if not Did_Action ("init") then
         return;
      end if;

      declare
         use Inc_Class_Wp_Roles;

         Roles : Wp_Roles := Wp_Roles_X;
      begin
         Roles.For_Site (New_Site_Id); -- ()
      end;

      declare
         use Class_Users;

         User : Wp_User := Wp_Get_Current_User;
      begin
         User.For_Site (New_Site_Id); -- ()
      end;
   end Wp_Switch_Roles_And_User;

-- --
-- -- Determines if switch_to_blog() is in effect
-- --
-- -- @since 3.5.0
-- --
-- -- @global array _wp_switched_stack
-- --
-- -- @return bool True if switched, false otherwise.
-- --
-- function ms_is_switched() then
--         return ! empty( GLOBALS["_wp_switched_stack"] );
-- end;

-- --
-- -- Check if a particular blog is archived.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int id Blog ID.
-- -- @return string Whether the blog is archived or not.
-- --
-- function is_archived( id ) then
--         return get_blog_status( id, "archived" );
-- end;

-- --
-- -- Update the "archived" status of a particular blog.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int    id       Blog ID.
-- -- @param string archived The new status.
-- -- @return string archived
-- --
-- function update_archived( id, archived ) then
--         update_blog_status( id, "archived", archived );
--         return archived;
-- end;

-- --
-- -- Update a blog details field.
-- --
-- -- @since MU (3.0.0)
-- -- @since 5.1.0 Use wp_update_site() internally.
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int    blog_id    Blog ID.
-- -- @param string pref       Field name.
-- -- @param string value      Field value.
-- -- @param null   deprecated Not used.
-- -- @return string|false value
-- --
-- function update_blog_status( blog_id, pref, value, deprecated = null ) then
--         global wpdb;

--         if ( null !== deprecated ) then
--                 _deprecated_argument( __FUNCTION__, "3.1.0" );
--         end;

--         allowed_field_names = array( "site_id", "domain", "path", "registered", "last_updated", "public", "archived", "mature", "spam", "deleted", "lang_id" );

--         if ( ! in_array( pref, allowed_field_names, true ) ) then
--                 return value;
--         end;

--         result = wp_update_site(
--                 blog_id,
--                 array(
--                         pref => value,
--                 )
--         );

--         if ( is_wp_error( result ) ) then
--                 return false;
--         end;

--         return value;
-- end;

-- --
-- -- Get a blog details field.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int    id   Blog ID.
-- -- @param string pref Field name.
-- -- @return bool|string|null value
-- --
-- function get_blog_status( id, pref ) then
--         global wpdb;

--         details = get_site( id );
--         if ( details ) then
--                 return details.pref;
--         end;

--         return wpdb.get_var( wpdb.prepare( "SELECT %s FROM thenwpdb.blogsend; WHERE blog_id = %d", pref, id ) );
-- end;

-- --
-- -- Get a list of most recently updated blogs.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param mixed deprecated Not used.
-- -- @param int   start      Optional. Number of blogs to offset the query. Used to build LIMIT clause.
-- --                          Can be used for pagination. Default 0.
-- -- @param int   quantity   Optional. The maximum number of blogs to retrieve. Default 40.
-- -- @return array The list of blogs.
-- --
-- function get_last_updated( deprecated = "", start = 0, quantity = 40 ) then
--         global wpdb;

--         if ( ! empty( deprecated ) ) then
--                 _deprecated_argument( __FUNCTION__, "MU" ); // Never used.
--         end;

--         return wpdb.get_results( wpdb.prepare( "SELECT blog_id, domain, path FROM wpdb.blogs WHERE site_id = %d AND public = "1" AND archived = "0" AND mature = "0" AND spam = "0" AND deleted = "0" AND last_updated != "0000-00-00 00:00:00" ORDER BY last_updated DESC limit %d, %d", get_current_network_id(), start, quantity ), ARRAY_A );
-- end;

-- --
-- -- Handler for updating the site"s last updated date when a post is published or
-- -- an already published post is changed.
-- --
-- -- @since 3.3.0
-- --
-- -- @param string  new_status The new post status.
-- -- @param string  old_status The old post status.
-- -- @param WP_Post post       Post object.
-- --
-- function _update_blog_date_on_post_publish( new_status, old_status, post ) then
--         post_type_obj = get_post_type_object( post.post_type );
--         if ( ! post_type_obj || ! post_type_obj.public ) then
--                 return;
--         end;

--         if ( "publish" !== new_status && "publish" !== old_status ) then
--                 return;
--         end;

--         // Post was freshly published, published post was saved, or published post was unpublished.

--         wpmu_update_blogs_date();
-- end;

-- --
-- -- Handler for updating the current site"s last updated date when a published
-- -- post is deleted.
-- --
-- -- @since 3.4.0
-- --
-- -- @param int post_id Post ID
-- --
-- function _update_blog_date_on_post_delete( post_id ) then
--         post = get_post( post_id );

--         post_type_obj = get_post_type_object( post.post_type );
--         if ( ! post_type_obj || ! post_type_obj.public ) then
--                 return;
--         end;

--         if ( "publish" !== post.post_status ) then
--                 return;
--         end;

--         wpmu_update_blogs_date();
-- end;

-- --
-- -- Handler for updating the current site"s posts count when a post is deleted.
-- --
-- -- @since 4.0.0
-- --
-- -- @param int post_id Post ID.
-- --
-- function _update_posts_count_on_delete( post_id ) then
--         post = get_post( post_id );

--         if ( ! post || "publish" !== post.post_status || "post" !== post.post_type ) then
--                 return;
--         end;

--         update_posts_count();
-- end;

-- --
-- -- Handler for updating the current site"s posts count when a post status changes.
-- --
-- -- @since 4.0.0
-- -- @since 4.9.0 Added the `post` parameter.
-- --
-- -- @param string  new_status The status the post is changing to.
-- -- @param string  old_status The status the post is changing from.
-- -- @param WP_Post post       Post object
-- --
-- function _update_posts_count_on_transition_post_status( new_status, old_status, post = null ) then
--         if ( new_status === old_status ) then
--                 return;
--         end;

--         if ( "post" !== get_post_type( post ) ) then
--                 return;
--         end;

--         if ( "publish" !== new_status && "publish" !== old_status ) then
--                 return;
--         end;

--         update_posts_count();
-- end;

-- --
-- -- Count number of sites grouped by site status.
-- --
-- -- @since 5.3.0
-- --
-- -- @param int network_id Optional. The network to get counts for. Default is the current network ID.
-- -- @return int[] then
-- --     Numbers of sites grouped by site status.
-- --
-- --     @type int all      The total number of sites.
-- --     @type int public   The number of public sites.
-- --     @type int archived The number of archived sites.
-- --     @type int mature   The number of mature sites.
-- --     @type int spam     The number of spam sites.
-- --     @type int deleted  The number of deleted sites.
-- -- end;
-- --
-- function wp_count_sites( network_id = null ) then
--         if ( empty( network_id ) ) then
--                 network_id = get_current_network_id();
--         end;

--         counts = array();
--         args   = array(
--                 "network_id"    => network_id,
--                 "number"        => 1,
--                 "fields"        => "ids",
--                 "no_found_rows" => false,
--         );

--         q             = new WP_Site_Query( args );
--         counts["all"] = q.found_sites;

--         _args    = args;
--         statuses = array( "public", "archived", "mature", "spam", "deleted" );

--         foreach ( statuses as status ) then
--                 _args            = args;
--                 _args[ status ] = 1;

--                 q                 = new WP_Site_Query( _args );
--                 counts[ status ] = q.found_sites;
--         end;

--         return counts;
-- end;

end Inc_Ms_Blogs;
