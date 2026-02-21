--
-- Multisite WordPress API
--
-- @package WordPress
-- @subpackage Multisite
-- @since 3.0.0
--

with Arrays;

with Inc_Options;

package body Inc_Ms_Functions
is
   use Arrays;

-- --
-- -- Gets the network"s site and user counts.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @return int() then
-- --     Site and user count for the network.
-- --
-- --     @type int blogs Number of sites on the network.
-- --     @type int users Number of users on the network.
-- -- end;
-- --
-- function get_sitestats() then
--         stats := array(
--                 "blogs" => get_blog_count(),
--                 "users" => get_user_count(),
--         );

--         return stats;
-- end;

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
-- function get_active_blog_for_user( user_id ) then
--         blogs := get_blogs_of_user( user_id );
--         if ( empty( blogs ) ) then
--                 return;
--         end;

--         if ( ! is_multisite() ) then
--                 return blogs( get_current_blog_id() );
--         end;

--         primary_blog := get_user_meta( user_id, "primary_blog", true );
--         first_blog   := current( blogs );
--         if ( false !== primary_blog ) then
--                 if ( ! isset( blogs( primary_blog ) ) ) then
--                         update_user_meta( user_id, "primary_blog", first_blog.userblog_id );
--                         primary := get_site( first_blog.userblog_id );
--                 end; else then
--                         primary := get_site( primary_blog );
--                 end;
--         end; else then
--                 // TODO: Review this call to add_user_to_blog too - to get here the user must have a role on this blog?
--                 result := add_user_to_blog( first_blog.userblog_id, user_id, "subscriber" );

--                 if ( ! is_wp_error( result ) ) then
--                         update_user_meta( user_id, "primary_blog", first_blog.userblog_id );
--                         primary := first_blog;
--                 end;
--         end;

--         if ( ( ! is_object( primary ) ) || ( 1 == primary.archived || 1 == primary.spam || 1 == primary.deleted ) ) then
--                 blogs := get_blogs_of_user( user_id, true ); // If a user"s primary blog is shut down, check their other blogs.
--                 ret   := false;
--                 if ( is_array( blogs ) && count( blogs ) > 0 ) then
--                         foreach ( (array) blogs as blog_id => blog ) then
--                                 if ( get_current_network_id() != blog.site_id ) then
--                                         continue;
--                                 end;
--                                 details := get_site( blog_id );
--                                 if ( is_object( details ) && 0 == details.archived && 0 == details.spam && 0 == details.deleted ) then
--                                         ret := details;
--                                         if ( get_user_meta( user_id, "primary_blog", true ) != blog_id ) then
--                                                 update_user_meta( user_id, "primary_blog", blog_id );
--                                         end;
--                                         if ( ! get_user_meta( user_id, "source_domain", true ) ) then
--                                                 update_user_meta( user_id, "source_domain", details.domain );
--                                         end;
--                                         break;
--                                 end;
--                         end;
--                 end; else then
--                         return;
--                 end;
--                 return ret;
--         end; else then
--                 return primary;
--         end;
-- end;

   --------------------
   -- Get_Blog_Count --
   --------------------

   function Get_Blog_Count (Network_Id : Integer := 0) -- := null
                            return Natural
   is
      use Inc_Options;
   begin
      return As_Integer (Get_Network_Option (Network_Id, "blog_count"));
   end Get_Blog_Count;

-- --
-- -- Gets a blog post from any site on the network.
-- --
-- -- This function is similar to get_post(), except that it can retrieve a post
-- -- from any site on the network, not just the current site.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int blog_id ID of the blog.
-- -- @param int post_id ID of the post being looked for.
-- -- @return WP_Post|null WP_Post object on success, null on failure
-- --
-- function get_blog_post( blog_id, post_id ) then
--         switch_to_blog( blog_id );
--         post := get_post( post_id );
--         restore_current_blog();

--         return post;
-- end;

-- --
-- -- Adds a user to a blog, along with specifying the user"s role.
-- --
-- -- Use the {@see "add_user_to_blog"} action to fire an event when users are added to a blog.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int    blog_id ID of the blog the user is being added to.
-- -- @param int    user_id ID of the user being added.
-- -- @param string role    The role you want the user to have.
-- -- @return true|WP_Error True on success or a WP_Error object if the user doesn"t exist
-- --                       or could not be added.
-- --
-- function add_user_to_blog( blog_id, user_id, role ) then
--         switch_to_blog( blog_id );

--         user := get_userdata( user_id );

--         if ( ! user ) then
--                 restore_current_blog();
--                 return new WP_Error( "user_does_not_exist", __( "The requested user does not exist." ) );
--         end;

--         --
--         -- Filters whether a user should be added to a site.
--         --
--         -- @since 4.9.0
--         --
--         -- @param true|WP_Error retval  True if the user should be added to the site, error
--         --                               object otherwise.
--         -- @param int           user_id User ID.
--         -- @param string        role    User role.
--         -- @param int           blog_id Site ID.
--         --
--         can_add_user := apply_filters( "can_add_user_to_blog", true, user_id, role, blog_id );

--         if ( true !== can_add_user ) then
--                 restore_current_blog();

--                 if ( is_wp_error( can_add_user ) ) then
--                         return can_add_user;
--                 end;

--                 return new WP_Error( "user_cannot_be_added", __( "User cannot be added to this site." ) );
--         end;

--         if ( ! get_user_meta( user_id, "primary_blog", true ) ) then
--                 update_user_meta( user_id, "primary_blog", blog_id );
--                 site := get_site( blog_id );
--                 update_user_meta( user_id, "source_domain", site.domain );
--         end;

--         user.set_role( role );

--         --
--         -- Fires immediately after a user is added to a site.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param int    user_id User ID.
--         -- @param string role    User role.
--         -- @param int    blog_id Blog ID.
--         --
--         do_action( "add_user_to_blog", user_id, role, blog_id );

--         clean_user_cache( user_id );
--         wp_cache_delete( blog_id . "_user_count", "blog-details" );

--         restore_current_blog();

--         return true;
-- end;

-- --
-- -- Removes a user from a blog.
-- --
-- -- Use the {@see "remove_user_from_blog"} action to fire an event when
-- -- users are removed from a blog.
-- --
-- -- Accepts an optional `reassign` parameter, if you want to
-- -- reassign the user"s blog posts to another user upon removal.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int user_id  ID of the user being removed.
-- -- @param int blog_id  Optional. ID of the blog the user is being removed from. Default 0.
-- -- @param int reassign Optional. ID of the user to whom to reassign posts. Default 0.
-- -- @return true|WP_Error True on success or a WP_Error object if the user doesn"t exist.
-- --
-- function remove_user_from_blog( user_id, blog_id := 0, reassign := 0 ) then
--         global wpdb;

--         switch_to_blog( blog_id );
--         user_id := (int) user_id;

--         --
--         -- Fires before a user is removed from a site.
--         --
--         -- @since MU (3.0.0)
--         -- @since 5.4.0 Added the `reassign` parameter.
--         --
--         -- @param int user_id  ID of the user being removed.
--         -- @param int blog_id  ID of the blog the user is being removed from.
--         -- @param int reassign ID of the user to whom to reassign posts.
--         --
--         do_action( "remove_user_from_blog", user_id, blog_id, reassign );

--         // If being removed from the primary blog, set a new primary
--         // if the user is assigned to multiple blogs.
--         primary_blog := get_user_meta( user_id, "primary_blog", true );
--         if ( primary_blog == blog_id ) then
--                 new_id     := "";
--                 new_domain := "";
--                 blogs      := get_blogs_of_user( user_id );
--                 foreach ( (array) blogs as blog ) then
--                         if ( blog.userblog_id == blog_id ) then
--                                 continue;
--                         end;
--                         new_id     := blog.userblog_id;
--                         new_domain := blog.domain;
--                         break;
--                 end;

--                 update_user_meta( user_id, "primary_blog", new_id );
--                 update_user_meta( user_id, "source_domain", new_domain );
--         end;

--         user := get_userdata( user_id );
--         if ( ! user ) then
--                 restore_current_blog();
--                 return new WP_Error( "user_does_not_exist", __( "That user does not exist." ) );
--         end;

--         user.remove_all_caps();

--         blogs := get_blogs_of_user( user_id );
--         if ( count( blogs ) == 0 ) then
--                 update_user_meta( user_id, "primary_blog", "" );
--                 update_user_meta( user_id, "source_domain", "" );
--         end;

--         if ( reassign ) then
--                 reassign := (int) reassign;
--                 post_ids := wpdb.get_col( wpdb.prepare( "SELECT ID FROM wpdb.posts WHERE post_author := %d", user_id ) );
--                 link_ids := wpdb.get_col( wpdb.prepare( "SELECT link_id FROM wpdb.links WHERE link_owner := %d", user_id ) );

--                 if ( ! empty( post_ids ) ) then
--                         wpdb.query( wpdb.prepare( "UPDATE wpdb.posts SET post_author := %d WHERE post_author := %d", reassign, user_id ) );
--                         array_walk( post_ids, "clean_post_cache" );
--                 end;

--                 if ( ! empty( link_ids ) ) then
--                         wpdb.query( wpdb.prepare( "UPDATE wpdb.links SET link_owner := %d WHERE link_owner := %d", reassign, user_id ) );
--                         array_walk( link_ids, "clean_bookmark_cache" );
--                 end;
--         end;

--         restore_current_blog();

--         return true;
-- end;

-- --
-- -- Gets the permalink for a post on another blog.
-- --
-- -- @since MU (3.0.0) 1.0
-- --
-- -- @param int blog_id ID of the source blog.
-- -- @param int post_id ID of the desired post.
-- -- @return string The post"s permalink
-- --
-- function get_blog_permalink( blog_id, post_id ) then
--         switch_to_blog( blog_id );
--         link := get_permalink( post_id );
--         restore_current_blog();

--         return link;
-- end;

-- --
-- -- Gets a blog"s numeric ID from its URL.
-- --
-- -- On a subdirectory installation like example.com/blog1/,
-- -- domain will be the root "example.com" and path the
-- -- subdirectory "/blog1/". With subdomains like blog1.example.com,
-- -- domain is "blog1.example.com" and path is "/".
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string domain
-- -- @param string path   Optional. Not required for subdomain installations.
-- -- @return int 0 if no blog found, otherwise the ID of the matching blog
-- --
-- function get_blog_id_from_url( domain, path := "/" ) then
--         domain := strtolower( domain );
--         path   := strtolower( path );
--         id     := wp_cache_get( md5( domain . path ), "blog-id-cache" );

--         if ( -1 == id ) then // Blog does not exist.
--                 return 0;
--         end; elseif ( id ) then
--                 return (int) id;
--         end;

--         args   := array(
--                 "domain"                 => domain,
--                 "path"                   => path,
--                 "fields"                 => "ids",
--                 "number"                 => 1,
--                 "update_site_meta_cache" => false,
--         );
--         result := get_sites( args );
--         id     := array_shift( result );

--         if ( ! id ) then
--                 wp_cache_set( md5( domain . path ), -1, "blog-id-cache" );
--                 return 0;
--         end;

--         wp_cache_set( md5( domain . path ), id, "blog-id-cache" );

--         return id;
-- end;

-- //
-- // Admin functions.
-- //

-- --
-- -- Checks an email address against a list of banned domains.
-- --
-- -- This function checks against the Banned Email Domains list
-- -- at wp-admin/network/settings.php. The check is only run on
-- -- self-registrations; user creation at wp-admin/network/users.php
-- -- bypasses this check.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string user_email The email provided by the user at registration.
-- -- @return bool True when the email address is banned, false otherwise.
-- --
-- function is_email_address_unsafe( user_email ) then
--         banned_names := get_site_option( "banned_email_domains" );
--         if ( banned_names && ! is_array( banned_names ) ) then
--                 banned_names := explode( "\n", banned_names );
--         end;

--         is_email_address_unsafe := false;

--         if ( banned_names && is_array( banned_names ) && false !== strpos( user_email, "@", 1 ) ) then
--                 banned_names     := array_map( "strtolower", banned_names );
--                 normalized_email := strtolower( user_email );

--                 list( email_local_part, email_domain ) := explode( "@", normalized_email );

--                 foreach ( banned_names as banned_domain ) then
--                         if ( ! banned_domain ) then
--                                 continue;
--                         end;

--                         if ( email_domain == banned_domain ) then
--                                 is_email_address_unsafe := true;
--                                 break;
--                         end;

--                         dotted_domain := ".banned_domain";
--                         if ( substr( normalized_email, -strlen( dotted_domain ) ) === dotted_domain ) then
--                                 is_email_address_unsafe := true;
--                                 break;
--                         end;
--                 end;
--         end;

--         --
--         -- Filters whether an email address is unsafe.
--         --
--         -- @since 3.5.0
--         --
--         -- @param bool   is_email_address_unsafe Whether the email address is "unsafe". Default false.
--         -- @param string user_email              User email address.
--         --
--         return apply_filters( "is_email_address_unsafe", is_email_address_unsafe, user_email );
-- end;

-- --
-- -- Sanitizes and validates data required for a user sign-up.
-- --
-- -- Verifies the validity and uniqueness of user names and user email addresses,
-- -- and checks email addresses against allowed and disallowed domains provided by
-- -- administrators.
-- --
-- -- The {@see "wpmu_validate_user_signup"} hook provides an easy way to modify the sign-up
-- -- process. The value result, which is passed to the hook, contains both the user-provided
-- -- info and the error messages created by the function. {@see "wpmu_validate_user_signup"}
-- -- allows you to process the data in any way you"d like, and unset the relevant errors if
-- -- necessary.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string user_name  The login name provided by the user.
-- -- @param string user_email The email provided by the user.
-- -- @return array then
-- --     The array of user name, email, and the error messages.
-- --
-- --     @type string   user_name     Sanitized and unique username.
-- --     @type string   orig_username Original username.
-- --     @type string   user_email    User email address.
-- --     @type WP_Error errors        WP_Error object containing any errors found.
-- -- end;
-- --
-- function wpmu_validate_user_signup( user_name, user_email ) then
--         global wpdb;

--         errors := new WP_Error();

--         orig_username := user_name;
--         user_name     := preg_replace( "/\s+/", "", sanitize_user( user_name, true ) );

--         if ( user_name != orig_username || preg_match( "/(^a-z0-9)/", user_name ) ) then
--                 errors.add( "user_name", __( "Usernames can only contain lowercase letters (a-z) and numbers." ) );
--                 user_name := orig_username;
--         end;

--         user_email := sanitize_email( user_email );

--         if ( empty( user_name ) ) then
--                 errors.add( "user_name", __( "Please enter a username." ) );
--         end;

--         illegal_names := get_site_option( "illegal_names" );
--         if ( ! is_array( illegal_names ) ) then
--                 illegal_names := array( "www", "web", "root", "admin", "main", "invite", "administrator" );
--                 add_site_option( "illegal_names", illegal_names );
--         end;
--         if ( in_array( user_name, illegal_names, true ) ) then
--                 errors.add( "user_name", __( "Sorry, that username is not allowed." ) );
--         end;

--         -- This filter is documented in wp-includes/user.php--
--         illegal_logins := (array) apply_filters( "illegal_user_logins", array() );

--         if ( in_array( strtolower( user_name ), array_map( "strtolower", illegal_logins ), true ) ) then
--                 errors.add( "user_name", __( "Sorry, that username is not allowed." ) );
--         end;

--         if ( ! is_email( user_email ) ) then
--                 errors.add( "user_email", __( "Please enter a valid email address." ) );
--         end; elseif ( is_email_address_unsafe( user_email ) ) then
--                 errors.add( "user_email", __( "You cannot use that email address to signup. There are problems with them blocking some emails from WordPress. Please use another email provider." ) );
--         end;

--         if ( strlen( user_name ) < 4 ) then
--                 errors.add( "user_name", __( "Username must be at least 4 characters." ) );
--         end;

--         if ( strlen( user_name ) > 60 ) then
--                 errors.add( "user_name", __( "Username may not be longer than 60 characters." ) );
--         end;

--         // All numeric?
--         if ( preg_match( "/^(0-9)*/", user_name ) ) then
--                 errors.add( "user_name", __( "Sorry, usernames must have letters too!" ) );
--         end;

--         limited_email_domains := get_site_option( "limited_email_domains" );
--         if ( is_array( limited_email_domains ) && ! empty( limited_email_domains ) ) then
--                 limited_email_domains := array_map( "strtolower", limited_email_domains );
--                 emaildomain           := strtolower( substr( user_email, 1 + strpos( user_email, "@" ) ) );
--                 if ( ! in_array( emaildomain, limited_email_domains, true ) ) then
--                         errors.add( "user_email", __( "Sorry, that email address is not allowed!" ) );
--                 end;
--         end;

--         // Check if the username has been used already.
--         if ( username_exists( user_name ) ) then
--                 errors.add( "user_name", __( "Sorry, that username already exists!" ) );
--         end;

--         // Check if the email address has been used already.
--         if ( email_exists( user_email ) ) then
--                 errors.add(
--                         "user_email",
--                         sprintf(
--                                 /* translators: %s: Link to the login page.--
--                                 __( "<strong>Error:</strong> This email address is already registered. <a href="%s">Log in</a> with this address or choose another one." ),
--                                 wp_login_url()
--                         )
--                 );
--         end;

--         // Has someone already signed up for this username?
--         signup := wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.signups WHERE user_login := %s", user_name ) );
--         if ( signup instanceof stdClass ) then
--                 registered_at := mysql2date( "U", signup.registered );
--                 now           := time();
--                 diff          := now - registered_at;
--                 // If registered more than two days ago, cancel registration and let this signup go through.
--                 if ( diff > 2-- DAY_IN_SECONDS ) then
--                         wpdb.delete( wpdb.signups, array( "user_login" => user_name ) );
--                 end; else then
--                         errors.add( "user_name", __( "That username is currently reserved but may be available in a couple of days." ) );
--                 end;
--         end;

--         signup := wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.signups WHERE user_email := %s", user_email ) );
--         if ( signup instanceof stdClass ) then
--                 diff := time() - mysql2date( "U", signup.registered );
--                 // If registered more than two days ago, cancel registration and let this signup go through.
--                 if ( diff > 2-- DAY_IN_SECONDS ) then
--                         wpdb.delete( wpdb.signups, array( "user_email" => user_email ) );
--                 end; else then
--                         errors.add( "user_email", __( "That email address has already been used. Please check your inbox for an activation email. It will become available in a couple of days if you do nothing." ) );
--                 end;
--         end;

--         result := array(
--                 "user_name"     => user_name,
--                 "orig_username" => orig_username,
--                 "user_email"    => user_email,
--                 "errors"        => errors,
--         );

--         --
--         -- Filters the validated user registration details.
--         --
--         -- This does not allow you to override the username or email of the user during
--         -- registration. The values are solely used for validation and error handling.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param array result then
--         --     The array of user name, email, and the error messages.
--         --
--         --     @type string   user_name     Sanitized and unique username.
--         --     @type string   orig_username Original username.
--         --     @type string   user_email    User email address.
--         --     @type WP_Error errors        WP_Error object containing any errors found.
--         -- end;
--         --
--         return apply_filters( "wpmu_validate_user_signup", result );
-- end;

-- --
-- -- Processes new site registrations.
-- --
-- -- Checks the data provided by the user during blog signup. Verifies
-- -- the validity and uniqueness of blog paths and domains.
-- --
-- -- This function prevents the current user from registering a new site
-- -- with a blogname equivalent to another user"s login name. Passing the
-- -- user parameter to the function, where user is the other user, is
-- -- effectively an override of this limitation.
-- --
-- -- Filter {@see "wpmu_validate_blog_signup"} if you want to modify
-- -- the way that WordPress validates new site signups.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb   wpdb   WordPress database abstraction object.
-- -- @global string domain
-- --
-- -- @param string         blogname   The blog name provided by the user. Must be unique.
-- -- @param string         blog_title The blog title provided by the user.
-- -- @param WP_User|string user       Optional. The user object to check against the new site name.
-- -- @return array then
-- --     Array of domain, path, blog name, blog title, user and error messages.
-- --
-- --     @type string         domain     Domain for the site.
-- --     @type string         path       Path for the site. Used in subdirectory installations.
-- --     @type string         blogname   The unique site name (slug).
-- --     @type string         blog_title Blog title.
-- --     @type string|WP_User user       By default, an empty string. A user object if provided.
-- --     @type WP_Error       errors     WP_Error containing any errors found.
-- -- end;
-- --
-- function wpmu_validate_blog_signup( blogname, blog_title, user := "" ) then
--         global wpdb, domain;

--         current_network := get_network();
--         base            := current_network.path;

--         blog_title := strip_tags( blog_title );

--         errors        := new WP_Error();
--         illegal_names := get_site_option( "illegal_names" );
--         if ( false == illegal_names ) then
--                 illegal_names := array( "www", "web", "root", "admin", "main", "invite", "administrator" );
--                 add_site_option( "illegal_names", illegal_names );
--         end;

--         /*
--         -- On sub dir installations, some names are so illegal, only a filter can
--         -- spring them from jail.
--         --
--         if ( ! is_subdomain_install() ) then
--                 illegal_names := array_merge( illegal_names, get_subdirectory_reserved_names() );
--         end;

--         if ( empty( blogname ) ) then
--                 errors.add( "blogname", __( "Please enter a site name." ) );
--         end;

--         if ( preg_match( "/(^a-z0-9)+/", blogname ) ) then
--                 errors.add( "blogname", __( "Site names can only contain lowercase letters (a-z) and numbers." ) );
--         end;

--         if ( in_array( blogname, illegal_names, true ) ) then
--                 errors.add( "blogname", __( "That name is not allowed." ) );
--         end;

--         --
--         -- Filters the minimum site name length required when validating a site signup.
--         --
--         -- @since 4.8.0
--         --
--         -- @param int length The minimum site name length. Default 4.
--         --
--         minimum_site_name_length := apply_filters( "minimum_site_name_length", 4 );

--         if ( strlen( blogname ) < minimum_site_name_length ) then
--                 /* translators: %s: Minimum site name length.--
--                 errors.add( "blogname", sprintf( _n( "Site name must be at least %s character.", "Site name must be at least %s characters.", minimum_site_name_length ), number_format_i18n( minimum_site_name_length ) ) );
--         end;

--         // Do not allow users to create a site that conflicts with a page on the main blog.
--         if ( ! is_subdomain_install() && wpdb.get_var( wpdb.prepare( "SELECT post_name FROM " . wpdb.get_blog_prefix( current_network.site_id ) . "posts WHERE post_type := "page" AND post_name := %s", blogname ) ) ) then
--                 errors.add( "blogname", __( "Sorry, you may not use that site name." ) );
--         end;

--         // All numeric?
--         if ( preg_match( "/^(0-9)*/", blogname ) ) then
--                 errors.add( "blogname", __( "Sorry, site names must have letters too!" ) );
--         end;

--         --
--         -- Filters the new site name during registration.
--         --
--         -- The name is the site"s subdomain or the site"s subdirectory
--         -- path depending on the network settings.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param string blogname Site name.
--         --
--         blogname := apply_filters( "newblogname", blogname );

--         blog_title := wp_unslash( blog_title );

--         if ( empty( blog_title ) ) then
--                 errors.add( "blog_title", __( "Please enter a site title." ) );
--         end;

--         // Check if the domain/path has been used already.
--         if ( is_subdomain_install() ) then
--                 mydomain := blogname . "." . preg_replace( "|^www\.|", "", domain );
--                 path     := base;
--         end; else then
--                 mydomain := domain;
--                 path     := base . blogname . "/";
--         end;
--         if ( domain_exists( mydomain, path, current_network.id ) ) then
--                 errors.add( "blogname", __( "Sorry, that site already exists!" ) );
--         end;

--         /*
--         -- Do not allow users to create a site that matches an existing user"s login name,
--         -- unless it"s the user"s own username.
--         --
--         if ( username_exists( blogname ) ) then
--                 if ( ! is_object( user ) || ( is_object( user ) && ( user.user_login != blogname ) ) ) then
--                         errors.add( "blogname", __( "Sorry, that site is reserved!" ) );
--                 end;
--         end;

--         // Has someone already signed up for this domain?
--         // TODO: Check email too?
--         signup := wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.signups WHERE domain := %s AND path := %s", mydomain, path ) );
--         if ( signup instanceof stdClass ) then
--                 diff := time() - mysql2date( "U", signup.registered );
--                 // If registered more than two days ago, cancel registration and let this signup go through.
--                 if ( diff > 2-- DAY_IN_SECONDS ) then
--                         wpdb.delete(
--                                 wpdb.signups,
--                                 array(
--                                         "domain" => mydomain,
--                                         "path"   => path,
--                                 )
--                         );
--                 end; else then
--                         errors.add( "blogname", __( "That site is currently reserved but may be available in a couple days." ) );
--                 end;
--         end;

--         result := array(
--                 "domain"     => mydomain,
--                 "path"       => path,
--                 "blogname"   => blogname,
--                 "blog_title" => blog_title,
--                 "user"       => user,
--                 "errors"     => errors,
--         );

--         --
--         -- Filters site details and error messages following registration.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param array result then
--         --     Array of domain, path, blog name, blog title, user and error messages.
--         --
--         --     @type string         domain     Domain for the site.
--         --     @type string         path       Path for the site. Used in subdirectory installations.
--         --     @type string         blogname   The unique site name (slug).
--         --     @type string         blog_title Blog title.
--         --     @type string|WP_User user       By default, an empty string. A user object if provided.
--         --     @type WP_Error       errors     WP_Error containing any errors found.
--         -- end;
--         --
--         return apply_filters( "wpmu_validate_blog_signup", result );
-- end;

-- --
-- -- Records site signup information for future activation.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string domain     The requested domain.
-- -- @param string path       The requested path.
-- -- @param string title      The requested site title.
-- -- @param string user       The user"s requested login name.
-- -- @param string user_email The user"s email address.
-- -- @param array  meta       Optional. Signup meta data. By default, contains the requested privacy setting and lang_id.
-- --
-- function wpmu_signup_blog( domain, path, title, user, user_email, meta := array() ) then
--         global wpdb, wp_hasher;

--         key := substr( md5( time() . wp_rand() . domain ), 0, 16 );

--         if ( empty( wp_hasher ) ) then
--                 require_once ABSPATH . WPINC . "/class-phpass.php";
--                 wp_hasher := new PasswordHash( 8, true );
--         end;

--         hashed := time() . ":" . wp_hasher.HashPassword( key );

--         --
--         -- Filters the metadata for a site signup.
--         --
--         -- The metadata will be serialized prior to storing it in the database.
--         --
--         -- @since 4.8.0
--         --
--         -- @param array  meta       Signup meta data. Default empty array.
--         -- @param string domain     The requested domain.
--         -- @param string path       The requested path.
--         -- @param string title      The requested site title.
--         -- @param string user       The user"s requested login name.
--         -- @param string user_email The user"s email address.
--         -- @param string key        The user"s activation key.
--     -- @param string hashed     The user"s hashed activation key.
--         --
--         meta := apply_filters( "signup_site_meta", meta, domain, path, title, user, user_email, key, hashed );

--         wpdb.insert(
--                 wpdb.signups,
--                 array(
--                         "domain"         => domain,
--                         "path"           => path,
--                         "title"          => title,
--                         "user_login"     => user,
--                         "user_email"     => user_email,
--                         "registered"     => current_time( "mysql", true ),
--                         "activation_key" => hashed,
--                         "meta"           => serialize( meta ),
--                 )
--         );

--         --
--         -- Fires after site signup information has been written to the database.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string domain     The requested domain.
--         -- @param string path       The requested path.
--         -- @param string title      The requested site title.
--         -- @param string user       The user"s requested login name.
--         -- @param string user_email The user"s email address.
--         -- @param string key        The user"s activation key.
--         -- @param array  meta       Signup meta data. By default, contains the requested privacy setting and lang_id.
--     -- @param int    signup_id  Signup ID.
--     -- @param string hashed     The user"s hashed activation key.
--         --
--         do_action( "after_signup_site", domain, path, title, user, user_email, key, meta, wpdb.insert_id, hashed );
-- end;

-- --
-- -- Records user signup information for future activation.
-- --
-- -- This function is used when user registration is open but
-- -- new site registration is not.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string user       The user"s requested login name.
-- -- @param string user_email The user"s email address.
-- -- @param array  meta       Optional. Signup meta data. Default empty array.
-- --
-- function wpmu_signup_user( user, user_email, meta := array() ) then
--         global wpdb, wp_hasher;

--         // Format data.
--         user       := preg_replace( "/\s+/", "", sanitize_user( user, true ) );
--         user_email := sanitize_email( user_email );
--         key        := substr( md5( time() . wp_rand() . user_email ), 0, 16 );

--     if ( empty( wp_hasher ) ) then
--         require_once ABSPATH . WPINC . "/class-phpass.php";
--         wp_hasher := new PasswordHash( 8, true );
--     end;

--     hashed := time() . ":" . wp_hasher.HashPassword( key );

--         --
--         -- Filters the metadata for a user signup.
--         --
--         -- The metadata will be serialized prior to storing it in the database.
--         --
--         -- @since 4.8.0
--         --
--         -- @param array  meta       Signup meta data. Default empty array.
--         -- @param string user       The user"s requested login name.
--         -- @param string user_email The user"s email address.
--         -- @param string key        The user"s activation key.
--     -- @param string hashed     The user"s hashed activation key.
--         --
--         meta := apply_filters( "signup_user_meta", meta, user, user_email, key, hashed );

--         wpdb.insert(
--                 wpdb.signups,
--                 array(
--                         "domain"         => "",
--                         "path"           => "",
--                         "title"          => "",
--                         "user_login"     => user,
--                         "user_email"     => user_email,
--                         "registered"     => current_time( "mysql", true ),
--                         "activation_key" => hashed,
--                         "meta"           => serialize( meta ),
--                 )
--         );

--         --
--         -- Fires after a user"s signup information has been written to the database.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string user       The user"s requested login name.
--         -- @param string user_email The user"s email address.
--         -- @param string key        The user"s activation key.
--         -- @param array  meta       Signup meta data. Default empty array.
--     -- @param int    signup_id  Signup ID.
--     -- @param string hashed     The user"s hashed activation key.
--         --
--         do_action( "after_signup_user", user, user_email, key, meta, wpdb.insert_id, hashed );
-- end;

-- --
-- -- Sends a confirmation request email to a user when they sign up for a new site. The new site will not become active
-- -- until the confirmation link is clicked.
-- --
-- -- This is the notification function used when site registration
-- -- is enabled.
-- --
-- -- Filter {@see "wpmu_signup_blog_notification"} to bypass this function or
-- -- replace it with your own notification behavior.
-- --
-- -- Filter {@see "wpmu_signup_blog_notification_email"} and
-- -- {@see "wpmu_signup_blog_notification_subject"} to change the content
-- -- and subject line of the email sent to newly registered users.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string domain     The new blog domain.
-- -- @param string path       The new blog path.
-- -- @param string title      The site title.
-- -- @param string user_login The user"s login name.
-- -- @param string user_email The user"s email address.
-- -- @param string key        The activation key created in wpmu_signup_blog()
-- -- @param array  meta       Optional. Signup meta data. By default, contains the requested privacy setting and lang_id.
-- -- @param int    signup_id  Signup ID.
-- -- @return bool
-- --
-- function wpmu_signup_blog_notification( domain, path, title, user_login, user_email, key, meta := array(), signup_id ) then
--         --
--         -- Filters whether to bypass the new site email notification.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param string|false domain     Site domain, or false to prevent the email from sending.
--         -- @param string       path       Site path.
--         -- @param string       title      Site title.
--         -- @param string       user_login User login name.
--         -- @param string       user_email User email address.
--         -- @param string       key        Activation key created in wpmu_signup_blog().
--         -- @param array        meta       Signup meta data. By default, contains the requested privacy setting and lang_id.
--         --
--         if ( ! apply_filters( "wpmu_signup_blog_notification", domain, path, title, user_login, user_email, key, meta ) ) then
--                 return false;
--         end;

--         // Send email with activation link.
--         if ( ! is_subdomain_install() || get_current_network_id() != 1 ) then
--                 activate_url := network_site_url( "wp-activate.php?key=key&signup_id=signup_id" );
--         end; else then
--                 activate_url := "http://thendomainend;thenpathend;wp-activate.php?key=key&signup_id=signup_id"; // @todo use--_url() API
--         end;

--         activate_url := esc_url( activate_url );

--         admin_email := get_site_option( "admin_email" );

--         if ( "" === admin_email ) then
--                 admin_email := "support@" . wp_parse_url( network_home_url(), PHP_URL_HOST );
--         end;

--         from_name       := ( "" !== get_site_option( "site_name" ) ) ? esc_html( get_site_option( "site_name" ) ) : "WordPress";
--         message_headers := "From: \"thenfrom_nameend;\" <thenadmin_emailend;>\n" . "Content-Type: text/plain; charset="" . get_option( "blog_charset" ) . "\"\n";

--         user            := get_user_by( "login", user_login );
--         switched_locale := switch_to_locale( get_user_locale( user ) );

--         message := sprintf(
--                 --
--                 -- Filters the message content of the new blog notification email.
--                 --
--                 -- Content should be formatted for transmission via wp_mail().
--                 --
--                 -- @since MU (3.0.0)
--                 --
--                 -- @param string content    Content of the notification email.
--                 -- @param string domain     Site domain.
--                 -- @param string path       Site path.
--                 -- @param string title      Site title.
--                 -- @param string user_login User login name.
--                 -- @param string user_email User email address.
--                 -- @param string key        Activation key created in wpmu_signup_blog().
--                 -- @param array  meta       Signup meta data. By default, contains the requested privacy setting and lang_id.
--                 --
--                 apply_filters(
--                         "wpmu_signup_blog_notification_email",
--                         /* translators: New site notification email. 1: Activation URL, 2: New site URL.--
--                         __( "To activate your site, please click the following link:\n\n%1\s\n\nAfter you activate, you will receive--another email* with your login.\n\nAfter you activate, you can visit your site here:\n\n%2\s" ),
--                         domain,
--                         path,
--                         title,
--                         user_login,
--                         user_email,
--                         key,
--                         meta
--                 ),
--                 activate_url,
--                 esc_url( "http://thendomainend;thenpathend;" ),
--                 key
--         );

--         subject := sprintf(
--                 --
--                 -- Filters the subject of the new blog notification email.
--                 --
--                 -- @since MU (3.0.0)
--                 --
--                 -- @param string subject    Subject of the notification email.
--                 -- @param string domain     Site domain.
--                 -- @param string path       Site path.
--                 -- @param string title      Site title.
--                 -- @param string user_login User login name.
--                 -- @param string user_email User email address.
--                 -- @param string key        Activation key created in wpmu_signup_blog().
--                 -- @param array  meta       Signup meta data. By default, contains the requested privacy setting and lang_id.
--                 --
--                 apply_filters(
--                         "wpmu_signup_blog_notification_subject",
--                         /* translators: New site notification email subject. 1: Network title, 2: New site URL.--
--                         _x( "(%1s) Activate %2s", "New site notification email subject" ),
--                         domain,
--                         path,
--                         title,
--                         user_login,
--                         user_email,
--                         key,
--                         meta
--                 ),
--                 from_name,
--                 esc_url( "http://" . domain . path )
--         );

--         wp_mail( user_email, wp_specialchars_decode( subject ), message, message_headers );

--         if ( switched_locale ) then
--                 restore_previous_locale();
--         end;

--         return true;
-- end;

-- --
-- -- Sends a confirmation request email to a user when they sign up for a new user account (without signing up for a site
-- -- at the same time). The user account will not become active until the confirmation link is clicked.
-- --
-- -- This is the notification function used when no new site has
-- -- been requested.
-- --
-- -- Filter {@see "wpmu_signup_user_notification"} to bypass this function or
-- -- replace it with your own notification behavior.
-- --
-- -- Filter {@see "wpmu_signup_user_notification_email"} and
-- -- {@see "wpmu_signup_user_notification_subject"} to change the content
-- -- and subject line of the email sent to newly registered users.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string user_login The user"s login name.
-- -- @param string user_email The user"s email address.
-- -- @param string key        The activation key created in wpmu_signup_user()
-- -- @param array  meta       Optional. Signup meta data. Default empty array.
-- -- @param int    signup_id  Signup ID.
-- -- @return bool
-- --
-- function wpmu_signup_user_notification( user_login, user_email, key, meta := array(), signup_id ) then
--         --
--         -- Filters whether to bypass the email notification for new user sign-up.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param string user_login User login name.
--         -- @param string user_email User email address.
--         -- @param string key        Activation key created in wpmu_signup_user().
--         -- @param array  meta       Signup meta data. Default empty array.
--         --
--         if ( ! apply_filters( "wpmu_signup_user_notification", user_login, user_email, key, meta ) ) then
--                 return false;
--         end;

--         user            := get_user_by( "login", user_login );
--         switched_locale := switch_to_locale( get_user_locale( user ) );

--         // Send email with activation link.
--         admin_email := get_site_option( "admin_email" );

--         if ( "" === admin_email ) then
--                 admin_email := "support@" . wp_parse_url( network_home_url(), PHP_URL_HOST );
--         end;

--         from_name       := ( "" !== get_site_option( "site_name" ) ) ? esc_html( get_site_option( "site_name" ) ) : "WordPress";
--         message_headers := "From: \"thenfrom_nameend;\" <thenadmin_emailend;>\n" . "Content-Type: text/plain; charset="" . get_option( "blog_charset" ) . "\"\n";
--         message         := sprintf(
--                 --
--                 -- Filters the content of the notification email for new user sign-up.
--                 --
--                 -- Content should be formatted for transmission via wp_mail().
--                 --
--                 -- @since MU (3.0.0)
--                 --
--                 -- @param string content    Content of the notification email.
--                 -- @param string user_login User login name.
--                 -- @param string user_email User email address.
--                 -- @param string key        Activation key created in wpmu_signup_user().
--                 -- @param array  meta       Signup meta data. Default empty array.
--                 --
--                 apply_filters(
--                         "wpmu_signup_user_notification_email",
--                         /* translators: New user notification email. %s: Activation URL.--
--                         __( "To activate your user, please click the following link:\n\n%s\n\nAfter you activate, you will receive--another email* with your login." ),
--                         user_login,
--                         user_email,
--                         key,
--                         meta
--                 ),
--         site_url( "wp-activate.php?key=key&signup_id=signup_id" )
--         );

--         subject := sprintf(
--                 --
--                 -- Filters the subject of the notification email of new user signup.
--                 --
--                 -- @since MU (3.0.0)
--                 --
--                 -- @param string subject    Subject of the notification email.
--                 -- @param string user_login User login name.
--                 -- @param string user_email User email address.
--                 -- @param string key        Activation key created in wpmu_signup_user().
--                 -- @param array  meta       Signup meta data. Default empty array.
--                 --
--                 apply_filters(
--                         "wpmu_signup_user_notification_subject",
--                         /* translators: New user notification email subject. 1: Network title, 2: New user login.--
--                         _x( "(%1s) Activate %2s", "New user notification email subject" ),
--                         user_login,
--                         user_email,
--                         key,
--                         meta
--                 ),
--                 from_name,
--                 user_login
--         );

--         wp_mail( user_email, wp_specialchars_decode( subject ), message, message_headers );

--         if ( switched_locale ) then
--                 restore_previous_locale();
--         end;

--         return true;
-- end;

-- --
-- -- Activates a signup.
-- --
-- -- Hook to {@see "wpmu_activate_user"} or {@see "wpmu_activate_blog"} for events
-- -- that should happen only when users or sites are self-created (since
-- -- those actions are not called when users and sites are created
-- -- by a Super Admin).
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string key The activation key provided to the user.
-- -- @param int signup_id The Signup ID.
-- -- @return array|WP_Error An array containing information about the activated user and/or blog
-- --
-- function wpmu_activate_signup( key, signup_id ) then
--         global wpdb, wp_hasher;

--     signup := wpdb.get_row( wpdb.prepare( "SELECT-- FROM wpdb.signups WHERE activation_key := %s OR signup_id := %d", key, signup_id ) );

--         if ( empty( signup ) ) then
--         return new WP_Error( "invalid_id", __( "Invalid signup ID." ) );
--     end;
--         // If the key requested matches the actual key in the database, it"s a legacy one.
--     if ( key === signup.activation_key ) then
--         return new WP_Error( "expired_key", __( "Invalid key" ) );
--     end;

--     // The format of the new keys is <timestamp>:<hashed_key>.
--     if ( false === strpos( signup.activation_key, ":" ) ) then
--                 return new WP_Error( "invalid_key", __( "Invalid activation key." ) );
--         end;
--     if ( empty( wp_hasher ) ) then
--         require_once ABSPATH . WPINC . "/class-phpass.php";
--         wp_hasher := new PasswordHash( 8, true );
--     end;

--     list( pass_request_time, signup_key ) := explode( ":", signup.activation_key, 2 );

--     if ( ! wp_hasher.CheckPassword( key, signup_key ) ) then
--         return new WP_Error( "invalid_key", __( "Invalid activation key." ) );
--     end;

--     --
--     -- Filters the expiration time of signup activation keys.
--     --
--     -- @since 5.0
--     --
--     -- @param int expiration_duration The expiration time in seconds.
--     --
--     expiration_duration := apply_filters( "activate_signup_expiration", DAY_IN_SECONDS );
--     expiration_time     := pass_request_time + expiration_duration;

--     if ( time() > expiration_time ) then
--             return new WP_Error( "expired_key", __( "Invalid key" ) );
--     end;
--         if ( signup.active ) then
--                 if ( empty( signup.domain ) ) then
--                         return new WP_Error( "already_active", __( "The user is already active." ), signup );
--                 end; else then
--                         return new WP_Error( "already_active", __( "The site is already active." ), signup );
--                 end;
--         end;

--         meta     := maybe_unserialize( signup.meta );
--         password := wp_generate_password( 12, false );

--         user_id := username_exists( signup.user_login );

--         if ( ! user_id ) then
--                 user_id := wpmu_create_user( signup.user_login, password, signup.user_email );
--         end; else then
--                 user_already_exists := true;
--         end;

--         if ( ! user_id ) then
--                 return new WP_Error( "create_user", __( "Could not create user" ), signup );
--         end;

--         now := current_time( "mysql", true );

--         if ( empty( signup.domain ) ) then
--                 wpdb.update(
--                         wpdb.signups,
--                         array(
--                                 "active"    => 1,
--                                 "activated" => now,
--                         ),
--                         array( "activation_key" => key )
--                 );

--                 if ( isset( user_already_exists ) ) then
--                         return new WP_Error( "user_already_exists", __( "That username is already activated." ), signup );
--                 end;

--                 --
--                 -- Fires immediately after a new user is activated.
--                 --
--                 -- @since MU (3.0.0)
--                 --
--                 -- @param int    user_id  User ID.
--                 -- @param string password User password.
--                 -- @param array  meta     Signup meta data.
--                 --
--                 do_action( "wpmu_activate_user", user_id, password, meta );

--                 return array(
--                         "user_id"  => user_id,
--                         "password" => password,
--                         "meta"     => meta,
--                 );
--         end;

--         blog_id := wpmu_create_blog( signup.domain, signup.path, signup.title, user_id, meta, get_current_network_id() );

--         // TODO: What to do if we create a user but cannot create a blog?
--         if ( is_wp_error( blog_id ) ) then
--                 /*
--                 -- If blog is taken, that means a previous attempt to activate this blog
--                 -- failed in between creating the blog and setting the activation flag.
--                 -- Let"s just set the active flag and instruct the user to reset their password.
--                 --
--                 if ( "blog_taken" === blog_id.get_error_code() ) then
--                         blog_id.add_data( signup );
--                         wpdb.update(
--                                 wpdb.signups,
--                                 array(
--                                         "active"    => 1,
--                                         "activated" => now,
--                                 ),
--                                 array( "activation_key" => key )
--                         );
--                 end;
--                 return blog_id;
--         end;

--         wpdb.update(
--                 wpdb.signups,
--                 array(
--                         "active"    => 1,
--                         "activated" => now,
--                 ),
--                 array( "activation_key" => key )
--         );

--         --
--         -- Fires immediately after a site is activated.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param int    blog_id       Blog ID.
--         -- @param int    user_id       User ID.
--         -- @param string password      User password.
--         -- @param string signup_title  Site title.
--         -- @param array  meta          Signup meta data. By default, contains the requested privacy setting and lang_id.
--         --
--         do_action( "wpmu_activate_blog", blog_id, user_id, password, signup.title, meta );

--         return array(
--                 "blog_id"  => blog_id,
--                 "user_id"  => user_id,
--                 "password" => password,
--                 "title"    => signup.title,
--                 "meta"     => meta,
--         );
-- end;

-- --
-- -- Deletes an associated signup entry when a user is deleted from the database.
-- --
-- -- @since 5.5.0
-- --
-- -- @param int      id       ID of the user to delete.
-- -- @param int|null reassign ID of the user to reassign posts and links to.
-- -- @param WP_User  user     User object.
-- --
-- function wp_delete_signup_on_user_delete( id, reassign, user ) then
--         global wpdb;

--         wpdb.delete( wpdb.signups, array( "user_login" => user.user_login ) );
-- end;

-- --
-- -- Creates a user.
-- --
-- -- This function runs when a user self-registers as well as when
-- -- a Super Admin creates a new user. Hook to {@see "wpmu_new_user"} for events
-- -- that should affect all new users, but only on Multisite (otherwise
-- -- use {@see "user_register"}).
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string user_name The new user"s login name.
-- -- @param string password  The new user"s password.
-- -- @param string email     The new user"s email address.
-- -- @return int|false Returns false on failure, or int user_id on success
-- --
-- function wpmu_create_user( user_name, password, email ) then
--         user_name := preg_replace( "/\s+/", "", sanitize_user( user_name, true ) );

--         user_id := wp_create_user( user_name, password, email );
--         if ( is_wp_error( user_id ) ) then
--                 return false;
--         end;

--         // Newly created users have no roles or caps until they are added to a blog.
--         delete_user_option( user_id, "capabilities" );
--         delete_user_option( user_id, "user_level" );

--         --
--         -- Fires immediately after a new user is created.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param int user_id User ID.
--         --
--         do_action( "wpmu_new_user", user_id );

--         return user_id;
-- end;

-- --
-- -- Creates a site.
-- --
-- -- This function runs when a user self-registers a new site as well
-- -- as when a Super Admin creates a new site. Hook to {@see "wpmu_new_blog"}
-- -- for events that should affect all new sites.
-- --
-- -- On subdirectory installations, domain is the same as the main site"s
-- -- domain, and the path is the subdirectory name (eg "example.com"
-- -- and "/blog1/"). On subdomain installations, domain is the new subdomain +
-- -- root domain (eg "blog1.example.com"), and path is "/".
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string domain     The new site"s domain.
-- -- @param string path       The new site"s path.
-- -- @param string title      The new site"s title.
-- -- @param int    user_id    The user ID of the new site"s admin.
-- -- @param array  options    Optional. Array of key=>value pairs used to set initial site options.
-- --                           If valid status keys are included ("public", "archived", "mature",
-- --                           "spam", "deleted", or "lang_id") the given site status(es) will be
-- --                           updated. Otherwise, keys and values will be used to set options for
-- --                           the new site. Default empty array.
-- -- @param int    network_id Optional. Network ID. Only relevant on multi-network installations.
-- -- @return int|WP_Error Returns WP_Error object on failure, the new site ID on success.
-- --
-- function wpmu_create_blog( domain, path, title, user_id, options := array(), network_id := 1 ) then
--         defaults := array(
--                 "public" => 0,
--         );
--         options  := wp_parse_args( options, defaults );

--         title   := strip_tags( title );
--         user_id := (int) user_id;

--         // Check if the domain has been used already. We should return an error message.
--         if ( domain_exists( domain, path, network_id ) ) then
--                 return new WP_Error( "blog_taken", __( "Sorry, that site already exists!" ) );
--         end;

--         if ( ! wp_installing() ) then
--                 wp_installing( true );
--         end;

--         allowed_data_fields := array( "public", "archived", "mature", "spam", "deleted", "lang_id" );

--         site_data := array_merge(
--                 array(
--                         "domain"     => domain,
--                         "path"       => path,
--                         "network_id" => network_id,
--                 ),
--                 array_intersect_key( options, array_flip( allowed_data_fields ) )
--         );

--         // Data to pass to wp_initialize_site().
--         site_initialization_data := array(
--                 "title"   => title,
--                 "user_id" => user_id,
--                 "options" => array_diff_key( options, array_flip( allowed_data_fields ) ),
--         );

--         blog_id := wp_insert_site( array_merge( site_data, site_initialization_data ) );

--         if ( is_wp_error( blog_id ) ) then
--                 return blog_id;
--         end;

--         wp_cache_set( "last_changed", microtime(), "sites" );

--         return blog_id;
-- end;

-- --
-- -- Notifies the network admin that a new site has been activated.
-- --
-- -- Filter {@see "newblog_notify_siteadmin"} to change the content of
-- -- the notification email.
-- --
-- -- @since MU (3.0.0)
-- -- @since 5.1.0 blog_id now supports input from the {@see "wp_initialize_site"} action.
-- --
-- -- @param WP_Site|int blog_id    The new site"s object or ID.
-- -- @param string      deprecated Not used.
-- -- @return bool
-- --
-- function newblog_notify_siteadmin( blog_id, deprecated := "" ) then
--         if ( is_object( blog_id ) ) then
--                 blog_id := blog_id.blog_id;
--         end;

--         if ( "yes" !== get_site_option( "registrationnotification" ) ) then
--                 return false;
--         end;

--         email := get_site_option( "admin_email" );

--         if ( is_email( email ) == false ) then
--                 return false;
--         end;

--         options_site_url := esc_url( network_admin_url( "settings.php" ) );

--         switch_to_blog( blog_id );
--         blogname := get_option( "blogname" );
--         siteurl  := site_url();
--         restore_current_blog();

--         msg := sprintf(
--                 /* translators: New site notification email. 1: Site URL, 2: User IP address, 3: URL to Network Settings screen.--
--                 __(
--                         "New Site: %1s
-- URL: %2s
-- Remote IP address: %3s

-- Disable these notifications: %4s"
--                 ),
--                 blogname,
--                 siteurl,
--                 wp_unslash( _SERVER("REMOTE_ADDR") ),
--                 options_site_url
--         );
--         --
--         -- Filters the message body of the new site activation email sent
--         -- to the network administrator.
--         --
--         -- @since MU (3.0.0)
--         -- @since 5.4.0 The `blog_id` parameter was added.
--         --
--         -- @param string     msg     Email body.
--         -- @param int|string blog_id The new site"s ID as an integer or numeric string.
--         --
--         msg := apply_filters( "newblog_notify_siteadmin", msg, blog_id );

--         /* translators: New site notification email subject. %s: New site URL.--
--         wp_mail( email, sprintf( __( "New Site Registration: %s" ), siteurl ), msg );

--         return true;
-- end;

-- --
-- -- Notifies the network admin that a new user has been activated.
-- --
-- -- Filter {@see "newuser_notify_siteadmin"} to change the content of
-- -- the notification email.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int user_id The new user"s ID.
-- -- @return bool
-- --
-- function newuser_notify_siteadmin( user_id ) then
--         if ( "yes" !== get_site_option( "registrationnotification" ) ) then
--                 return false;
--         end;

--         email := get_site_option( "admin_email" );

--         if ( is_email( email ) == false ) then
--                 return false;
--         end;

--         user := get_userdata( user_id );

--         options_site_url := esc_url( network_admin_url( "settings.php" ) );

--         msg := sprintf(
--                 /* translators: New user notification email. 1: User login, 2: User IP address, 3: URL to Network Settings screen.--
--                 __(
--                         "New User: %1s
-- Remote IP address: %2s

-- Disable these notifications: %3s"
--                 ),
--                 user.user_login,
--                 wp_unslash( _SERVER("REMOTE_ADDR") ),
--                 options_site_url
--         );

--         --
--         -- Filters the message body of the new user activation email sent
--         -- to the network administrator.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param string  msg  Email body.
--         -- @param WP_User user WP_User instance of the new user.
--         --
--         msg := apply_filters( "newuser_notify_siteadmin", msg, user );

--         /* translators: New user notification email subject. %s: User login.--
--         wp_mail( email, sprintf( __( "New User Registration: %s" ), user.user_login ), msg );

--         return true;
-- end;

-- --
-- -- Checks whether a site name is already taken.
-- --
-- -- The name is the site"s subdomain or the site"s subdirectory
-- -- path depending on the network settings.
-- --
-- -- Used during the new site registration process to ensure
-- -- that each site name is unique.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string domain     The domain to be checked.
-- -- @param string path       The path to be checked.
-- -- @param int    network_id Optional. Network ID. Relevant only on multi-network installations.
-- -- @return int|null The site ID if the site name exists, null otherwise.
-- --
-- function domain_exists( domain, path, network_id := 1 ) then
--         path   := trailingslashit( path );
--         args   := array(
--                 "network_id"             => network_id,
--                 "domain"                 => domain,
--                 "path"                   => path,
--                 "fields"                 => "ids",
--                 "number"                 => 1,
--                 "update_site_meta_cache" => false,
--         );
--         result := get_sites( args );
--         result := array_shift( result );

--         --
--         -- Filters whether a site name is taken.
--         --
--         -- The name is the site"s subdomain or the site"s subdirectory
--         -- path depending on the network settings.
--         --
--         -- @since 3.5.0
--         --
--         -- @param int|null result     The site ID if the site name exists, null otherwise.
--         -- @param string   domain     Domain to be checked.
--         -- @param string   path       Path to be checked.
--         -- @param int      network_id Network ID. Relevant only on multi-network installations.
--         --
--         return apply_filters( "domain_exists", result, domain, path, network_id );
-- end;

-- --
-- -- Notifies the site administrator that their site activation was successful.
-- --
-- -- Filter {@see "wpmu_welcome_notification"} to disable or bypass.
-- --
-- -- Filter {@see "update_welcome_email"} and {@see "update_welcome_subject"} to
-- -- modify the content and subject line of the notification email.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int    blog_id  Site ID.
-- -- @param int    user_id  User ID.
-- -- @param string password User password, or "N/A" if the user account is not new.
-- -- @param string title    Site title.
-- -- @param array  meta     Optional. Signup meta data. By default, contains the requested privacy setting and lang_id.
-- -- @return bool Whether the email notification was sent.
-- --
-- function wpmu_welcome_notification( blog_id, user_id, password, title, meta := array() ) then
--         current_network := get_network();

--         --
--         -- Filters whether to bypass the welcome email sent to the site administrator after site activation.
--         --
--         -- Returning false disables the welcome email.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param int|false blog_id  Site ID, or false to prevent the email from sending.
--         -- @param int       user_id  User ID of the site administrator.
--         -- @param string    password User password, or "N/A" if the user account is not new.
--         -- @param string    title    Site title.
--         -- @param array     meta     Signup meta data. By default, contains the requested privacy setting and lang_id.
--         --
--         if ( ! apply_filters( "wpmu_welcome_notification", blog_id, user_id, password, title, meta ) ) then
--                 return false;
--         end;

--         user := get_userdata( user_id );

--         switched_locale := switch_to_locale( get_user_locale( user ) );

--         welcome_email := get_site_option( "welcome_email" );
--         if ( false == welcome_email ) then
--                 /* translators: Do not translate USERNAME, SITE_NAME, BLOG_URL, PASSWORD: those are placeholders.--
--                 welcome_email := __(
--                         "Howdy USERNAME,

-- Your new SITE_NAME site has been successfully set up at:
-- BLOG_URL

-- You can log in to the administrator account with the following information:

-- Username: USERNAME
-- Password: PASSWORD
-- Log in here: BLOG_URLwp-login.php

-- We hope you enjoy your new site. Thanks!

-- --The Team @ SITE_NAME"
--                 );
--         end;

--         url := get_blogaddress_by_id( blog_id );

--         welcome_email := str_replace( "SITE_NAME", current_network.site_name, welcome_email );
--         welcome_email := str_replace( "BLOG_TITLE", title, welcome_email );
--         welcome_email := str_replace( "BLOG_URL", url, welcome_email );
--         welcome_email := str_replace( "USERNAME", user.user_login, welcome_email );
--         welcome_email := str_replace( "PASSWORD", password, welcome_email );

--         --
--         -- Filters the content of the welcome email sent to the site administrator after site activation.
--         --
--         -- Content should be formatted for transmission via wp_mail().
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param string welcome_email Message body of the email.
--         -- @param int    blog_id       Site ID.
--         -- @param int    user_id       User ID of the site administrator.
--         -- @param string password      User password, or "N/A" if the user account is not new.
--         -- @param string title         Site title.
--         -- @param array  meta          Signup meta data. By default, contains the requested privacy setting and lang_id.
--         --
--         welcome_email := apply_filters( "update_welcome_email", welcome_email, blog_id, user_id, password, title, meta );

--         admin_email := get_site_option( "admin_email" );

--         if ( "" === admin_email ) then
--                 admin_email := "support@" . wp_parse_url( network_home_url(), PHP_URL_HOST );
--         end;

--         from_name       := ( "" !== get_site_option( "site_name" ) ) ? esc_html( get_site_option( "site_name" ) ) : "WordPress";
--         message_headers := "From: \"thenfrom_nameend;\" <thenadmin_emailend;>\n" . "Content-Type: text/plain; charset="" . get_option( "blog_charset" ) . "\"\n";
--         message         := welcome_email;

--         if ( empty( current_network.site_name ) ) then
--                 current_network.site_name := "WordPress";
--         end;

--         /* translators: New site notification email subject. 1: Network title, 2: New site title.--
--         subject := __( "New %1s Site: %2s" );

--         --
--         -- Filters the subject of the welcome email sent to the site administrator after site activation.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param string subject Subject of the email.
--         --
--         subject := apply_filters( "update_welcome_subject", sprintf( subject, current_network.site_name, wp_unslash( title ) ) );

--         wp_mail( user.user_email, wp_specialchars_decode( subject ), message, message_headers );

--         if ( switched_locale ) then
--                 restore_previous_locale();
--         end;

--         return true;
-- end;

-- --
-- -- Notifies the Multisite network administrator that a new site was created.
-- --
-- -- Filter {@see "send_new_site_email"} to disable or bypass.
-- --
-- -- Filter {@see "new_site_email"} to filter the contents.
-- --
-- -- @since 5.6.0
-- --
-- -- @param int site_id Site ID of the new site.
-- -- @param int user_id User ID of the administrator of the new site.
-- -- @return bool Whether the email notification was sent.
-- --
-- function wpmu_new_site_admin_notification( site_id, user_id ) then
--         site  := get_site( site_id );
--         user  := get_userdata( user_id );
--         email := get_site_option( "admin_email" );

--         if ( ! site || ! user || ! email ) then
--                 return false;
--         end;

--         --
--         -- Filters whether to send an email to the Multisite network administrator when a new site is created.
--         --
--         -- Return false to disable sending the email.
--         --
--         -- @since 5.6.0
--         --
--         -- @param bool    send Whether to send the email.
--         -- @param WP_Site site Site object of the new site.
--         -- @param WP_User user User object of the administrator of the new site.
--         --
--         if ( ! apply_filters( "send_new_site_email", true, site, user ) ) then
--                 return false;
--         end;

--         switched_locale := false;
--         network_admin   := get_user_by( "email", email );

--         if ( network_admin ) then
--                 // If the network admin email address corresponds to a user, switch to their locale.
--                 switched_locale := switch_to_locale( get_user_locale( network_admin ) );
--         end; else then
--                 // Otherwise switch to the locale of the current site.
--                 switched_locale := switch_to_locale( get_locale() );
--         end;

--         subject := sprintf(
--                 /* translators: New site notification email subject. %s: Network title.--
--                 __( "(%s) New Site Created" ),
--                 get_network().site_name
--         );

--         message := sprintf(
--                 /* translators: New site notification email. 1: User login, 2: Site URL, 3: Site title.--
--                 __(
--                         "New site created by %1s

-- Address: %2s
-- Name: %3s"
--                 ),
--                 user.user_login,
--                 get_site_url( site.id ),
--                 get_blog_option( site.id, "blogname" )
--         );

--         header := sprintf(
--                 "From: "%1s" <%2s>",
--                 _x( "Site Admin", "email "From" field" ),
--                 email
--         );

--         new_site_email := array(
--                 "to"      => email,
--                 "subject" => subject,
--                 "message" => message,
--                 "headers" => header,
--         );

--         --
--         -- Filters the content of the email sent to the Multisite network administrator when a new site is created.
--         --
--         -- Content should be formatted for transmission via wp_mail().
--         --
--         -- @since 5.6.0
--         --
--         -- @param array new_site_email then
--         --     Used to build wp_mail().
--         --
--         --     @type string to      The email address of the recipient.
--         --     @type string subject The subject of the email.
--         --     @type string message The content of the email.
--         --     @type string headers Headers.
--         -- end;
--         -- @param WP_Site site         Site object of the new site.
--         -- @param WP_User user         User object of the administrator of the new site.
--         --
--         new_site_email := apply_filters( "new_site_email", new_site_email, site, user );

--         wp_mail(
--                 new_site_email("to"),
--                 wp_specialchars_decode( new_site_email("subject") ),
--                 new_site_email("message"),
--                 new_site_email("headers")
--         );

--         if ( switched_locale ) then
--                 restore_previous_locale();
--         end;

--         return true;
-- end;

-- --
-- -- Notifies a user that their account activation has been successful.
-- --
-- -- Filter {@see "wpmu_welcome_user_notification"} to disable or bypass.
-- --
-- -- Filter {@see "update_welcome_user_email"} and {@see "update_welcome_user_subject"} to
-- -- modify the content and subject line of the notification email.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int    user_id  User ID.
-- -- @param string password User password.
-- -- @param array  meta     Optional. Signup meta data. Default empty array.
-- -- @return bool
-- --
-- function wpmu_welcome_user_notification( user_id, password, meta := array() ) then
--         current_network := get_network();

--         --
--         -- Filters whether to bypass the welcome email after user activation.
--         --
--         -- Returning false disables the welcome email.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param int    user_id  User ID.
--         -- @param string password User password.
--         -- @param array  meta     Signup meta data. Default empty array.
--         --
--         if ( ! apply_filters( "wpmu_welcome_user_notification", user_id, password, meta ) ) then
--                 return false;
--         end;

--         welcome_email := get_site_option( "welcome_user_email" );

--         user := get_userdata( user_id );

--         switched_locale := switch_to_locale( get_user_locale( user ) );

--         --
--         -- Filters the content of the welcome email after user activation.
--         --
--         -- Content should be formatted for transmission via wp_mail().
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param string welcome_email The message body of the account activation success email.
--         -- @param int    user_id       User ID.
--         -- @param string password      User password.
--         -- @param array  meta          Signup meta data. Default empty array.
--         --
--         welcome_email := apply_filters( "update_welcome_user_email", welcome_email, user_id, password, meta );
--         welcome_email := str_replace( "SITE_NAME", current_network.site_name, welcome_email );
--         welcome_email := str_replace( "USERNAME", user.user_login, welcome_email );
--         welcome_email := str_replace( "PASSWORD", password, welcome_email );
--         welcome_email := str_replace( "LOGINLINK", wp_login_url(), welcome_email );

--         admin_email := get_site_option( "admin_email" );

--         if ( "" === admin_email ) then
--                 admin_email := "support@" . wp_parse_url( network_home_url(), PHP_URL_HOST );
--         end;

--         from_name       := ( "" !== get_site_option( "site_name" ) ) ? esc_html( get_site_option( "site_name" ) ) : "WordPress";
--         message_headers := "From: \"thenfrom_nameend;\" <thenadmin_emailend;>\n" . "Content-Type: text/plain; charset="" . get_option( "blog_charset" ) . "\"\n";
--         message         := welcome_email;

--         if ( empty( current_network.site_name ) ) then
--                 current_network.site_name := "WordPress";
--         end;

--         /* translators: New user notification email subject. 1: Network title, 2: New user login.--
--         subject := __( "New %1s User: %2s" );

--         --
--         -- Filters the subject of the welcome email after user activation.
--         --
--         -- @since MU (3.0.0)
--         --
--         -- @param string subject Subject of the email.
--         --
--         subject := apply_filters( "update_welcome_user_subject", sprintf( subject, current_network.site_name, user.user_login ) );

--         wp_mail( user.user_email, wp_specialchars_decode( subject ), message, message_headers );

--         if ( switched_locale ) then
--                 restore_previous_locale();
--         end;

--         return true;
-- end;

-- --
-- -- Gets the current network.
-- --
-- -- Returns an object containing the "id", "domain", "path", and "site_name"
-- -- properties of the network being viewed.
-- --
-- -- @see wpmu_current_site()
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global WP_Network current_site
-- --
-- -- @return WP_Network
-- --
-- function get_current_site() then
--         global current_site;
--         return current_site;
-- end;

-- --
-- -- Gets a user"s most recent post.
-- --
-- -- Walks through each of a user"s blogs to find the post with
-- -- the most recent post_date_gmt.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int user_id
-- -- @return array Contains the blog_id, post_id, post_date_gmt, and post_gmt_ts
-- --
-- function get_most_recent_post_of_user( user_id ) then
--         global wpdb;

--         user_blogs       := get_blogs_of_user( (int) user_id );
--         most_recent_post := array();

--         // Walk through each blog and get the most recent post
--         // published by user_id.
--         foreach ( (array) user_blogs as blog ) then
--                 prefix      := wpdb.get_blog_prefix( blog.userblog_id );
--                 recent_post := wpdb.get_row( wpdb.prepare( "SELECT ID, post_date_gmt FROM thenprefixend;posts WHERE post_author := %d AND post_type := "post" AND post_status := "publish" ORDER BY post_date_gmt DESC LIMIT 1", user_id ), ARRAY_A );

--                 // Make sure we found a post.
--                 if ( isset( recent_post("ID") ) ) then
--                         post_gmt_ts := strtotime( recent_post("post_date_gmt") );

--                         /*
--                         -- If this is the first post checked
--                         -- or if this post is newer than the current recent post,
--                         -- make it the new most recent post.
--                         --
--                         if ( ! isset( most_recent_post("post_gmt_ts") ) || ( post_gmt_ts > most_recent_post("post_gmt_ts") ) ) then
--                                 most_recent_post := array(
--                                         "blog_id"       => blog.userblog_id,
--                                         "post_id"       => recent_post("ID"),
--                                         "post_date_gmt" => recent_post("post_date_gmt"),
--                                         "post_gmt_ts"   => post_gmt_ts,
--                                 );
--                         end;
--                 end;
--         end;

--         return most_recent_post;
-- end;

-- //
-- // Misc functions.
-- //

-- --
-- -- Checks an array of MIME types against a list of allowed types.
-- --
-- -- WordPress ships with a set of allowed upload filetypes,
-- -- which is defined in wp-includes/functions.php in
-- -- get_allowed_mime_types(). This function is used to filter
-- -- that list against the filetypes allowed provided by Multisite
-- -- Super Admins at wp-admin/network/settings.php.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param array mimes
-- -- @return array
-- --
-- function check_upload_mimes( mimes ) then
--         site_exts  := explode( " ", get_site_option( "upload_filetypes", "jpg jpeg png gif" ) );
--         site_mimes := array();
--         foreach ( site_exts as ext ) then
--                 foreach ( mimes as ext_pattern => mime ) then
--                         if ( "" !== ext && false !== strpos( ext_pattern, ext ) ) then
--                                 site_mimes( ext_pattern ) := mime;
--                         end;
--                 end;
--         end;
--         return site_mimes;
-- end;

-- --
-- -- Updates a blog"s post count.
-- --
-- -- WordPress MS stores a blog"s post count as an option so as
-- -- to avoid extraneous COUNTs when a blog"s details are fetched
-- -- with get_site(). This function is called when posts are published
-- -- or unpublished to make sure the count stays current.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string deprecated Not used.
-- --
-- function update_posts_count( deprecated := "" ) then
--         global wpdb;
--         update_option( "post_count", (int) wpdb.get_var( "SELECT COUNT(ID) FROM thenwpdb.postsend; WHERE post_status := "publish" and post_type := "post"" ) );
-- end;

-- --
-- -- Logs the user email, IP, and registration date of a new site.
-- --
-- -- @since MU (3.0.0)
-- -- @since 5.1.0 Parameters now support input from the {@see "wp_initialize_site"} action.
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param WP_Site|int blog_id The new site"s object or ID.
-- -- @param int|array   user_id User ID, or array of arguments including "user_id".
-- --
-- function wpmu_log_new_registrations( blog_id, user_id ) then
--         global wpdb;

--         if ( is_object( blog_id ) ) then
--                 blog_id := blog_id.blog_id;
--         end;

--         if ( is_array( user_id ) ) then
--                 user_id := ! empty( user_id("user_id") ) ? user_id("user_id") : 0;
--         end;

--         user := get_userdata( (int) user_id );
--         if ( user ) then
--                 wpdb.insert(
--                         wpdb.registration_log,
--                         array(
--                                 "email"           => user.user_email,
--                                 "IP"              => preg_replace( "/(^0-9., )/", "", wp_unslash( _SERVER("REMOTE_ADDR") ) ),
--                                 "blog_id"         => blog_id,
--                                 "date_registered" => current_time( "mysql" ),
--                         )
--                 );
--         end;
-- end;

-- --
-- -- Ensures that the current site"s domain is listed in the allowed redirect host list.
-- --
-- -- @see wp_validate_redirect()
-- -- @since MU (3.0.0)
-- --
-- -- @param array|string deprecated Not used.
-- -- @return string() then
-- --     An array containing the current site"s domain.
-- --
-- --     @type string 0 The current site"s domain.
-- -- end;
-- --
-- function redirect_this_site( deprecated := "" ) then
--         return array( get_network().domain );
-- end;

-- --
-- -- Checks whether an upload is too big.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @blessed
-- --
-- -- @param array upload
-- -- @return string|array If the upload is under the size limit, upload is returned. Otherwise returns an error message.
-- --
-- function upload_is_file_too_big( upload ) then
--         if ( ! is_array( upload ) || defined( "WP_IMPORTING" ) || get_site_option( "upload_space_check_disabled" ) ) then
--                 return upload;
--         end;

--         if ( strlen( upload("bits") ) > ( KB_IN_BYTES-- get_site_option( "fileupload_maxk", 1500 ) ) ) then
--                 /* translators: %s: Maximum allowed file size in kilobytes.--
--                 return sprintf( __( "This file is too big. Files must be less than %s KB in size." ) . "<br />", get_site_option( "fileupload_maxk", 1500 ) );
--         end;

--         return upload;
-- end;

-- --
-- -- Adds a nonce field to the signup page.
-- --
-- -- @since MU (3.0.0)
-- --
-- function signup_nonce_fields() then
--         id := mt_rand();
--         echo "<input type="hidden" name="signup_form_id" value="thenidend;" />";
--         wp_nonce_field( "signup_form_" . id, "_signup_form", false );
-- end;

-- --
-- -- Processes the signup nonce created in signup_nonce_fields().
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param array result
-- -- @return array
-- --
-- function signup_nonce_check( result ) then
--         if ( ! strpos( _SERVER("PHP_SELF"), "wp-signup.php" ) ) then
--                 return result;
--         end;

--         if ( ! wp_verify_nonce( _POST("_signup_form"), "signup_form_" . _POST("signup_form_id") ) ) then
--                 result("errors").add( "invalid_nonce", __( "Unable to submit this form, please try again." ) );
--         end;

--         return result;
-- end;

-- --
-- -- Corrects 404 redirects when NOBLOGREDIRECT is defined.
-- --
-- -- @since MU (3.0.0)
-- --
-- function maybe_redirect_404() then
--         if ( is_main_site() && is_404() && defined( "NOBLOGREDIRECT" ) ) then
--                 --
--                 -- Filters the redirect URL for 404s on the main site.
--                 --
--                 -- The filter is only evaluated if the NOBLOGREDIRECT constant is defined.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string no_blog_redirect The redirect URL defined in NOBLOGREDIRECT.
--                 --
--                 destination := apply_filters( "blog_redirect_404", NOBLOGREDIRECT );

--                 if ( destination ) then
--                         if ( "%siteurl%" === destination ) then
--                                 destination := network_home_url();
--                         end;

--                         wp_redirect( destination );
--                         exit;
--                 end;
--         end;
-- end;

-- --
-- -- Adds a new user to a blog by visiting /newbloguser/thenkeyend;/.
-- --
-- -- This will only work when the user"s details are saved as an option
-- -- keyed as "new_user_thenkeyend;", where "thenkeyend;" is a hash generated for the user to be
-- -- added, as when a user is invited through the regular WP Add User interface.
-- --
-- -- @since MU (3.0.0)
-- --
-- function maybe_add_existing_user_to_blog() then
--         if ( false === strpos( _SERVER("REQUEST_URI"), "/newbloguser/" ) ) then
--                 return;
--         end;

--         parts := explode( "/", _SERVER("REQUEST_URI") );
--         key   := array_pop( parts );

--         if ( "" === key ) then
--                 key := array_pop( parts );
--         end;

--         details := get_option( "new_user_" . key );
--         if ( ! empty( details ) ) then
--                 delete_option( "new_user_" . key );
--         end;

--         if ( empty( details ) || is_wp_error( add_existing_user_to_blog( details ) ) ) then
--                 wp_die(
--                         sprintf(
--                                 /* translators: %s: Home URL.--
--                                 __( "An error occurred adding you to this site. Go to the <a href="%s">homepage</a>." ),
--                                 home_url()
--                         )
--                 );
--         end;

--         wp_die(
--                 sprintf(
--                         /* translators: 1: Home URL, 2: Admin URL.--
--                         __( "You have been added to this site. Please visit the <a href="%1s">homepage</a> or <a href="%2s">log in</a> using your username and password." ),
--                         home_url(),
--                         admin_url()
--                 ),
--                 __( "WordPress &rsaquo; Success" ),
--                 array( "response" => 200 )
--         );
-- end;

-- --
-- -- Adds a user to a blog based on details from maybe_add_existing_user_to_blog().
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param array|false details then
-- --     User details. Must at least contain values for the keys listed below.
-- --
-- --     @type int    user_id The ID of the user being added to the current blog.
-- --     @type string role    The role to be assigned to the user.
-- -- end;
-- -- @return true|WP_Error|void True on success or a WP_Error object if the user doesn"t exist
-- --                            or could not be added. Void if details array was not provided.
-- --
-- function add_existing_user_to_blog( details := false ) then
--         if ( is_array( details ) ) then
--                 blog_id := get_current_blog_id();
--                 result  := add_user_to_blog( blog_id, details("user_id"), details("role") );

--                 --
--                 -- Fires immediately after an existing user is added to a site.
--                 --
--                 -- @since MU (3.0.0)
--                 --
--                 -- @param int           user_id User ID.
--                 -- @param true|WP_Error result  True on success or a WP_Error object if the user doesn"t exist
--                 --                               or could not be added.
--                 --
--                 do_action( "added_existing_user", details("user_id"), result );

--                 return result;
--         end;
-- end;

-- --
-- -- Adds a newly created user to the appropriate blog
-- --
-- -- To add a user in general, use add_user_to_blog(). This function
-- -- is specifically hooked into the {@see "wpmu_activate_user"} action.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @see add_user_to_blog()
-- --
-- -- @param int    user_id  User ID.
-- -- @param string password User password. Ignored.
-- -- @param array  meta     Signup meta data.
-- --
-- function add_new_user_to_blog( user_id, password, meta ) then
--         if ( ! empty( meta("add_to_blog") ) ) then
--                 blog_id := meta("add_to_blog");
--                 role    := meta("new_role");
--                 remove_user_from_blog( user_id, get_network().site_id ); // Remove user from main blog.

--                 result := add_user_to_blog( blog_id, user_id, role );

--                 if ( ! is_wp_error( result ) ) then
--                         update_user_meta( user_id, "primary_blog", blog_id );
--                 end;
--         end;
-- end;

-- --
-- -- Corrects From host on outgoing mail to match the site domain
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param PHPMailer phpmailer The PHPMailer instance (passed by reference).
-- --
-- function fix_phpmailer_messageid( phpmailer ) then
--         phpmailer.Hostname := get_network().domain;
-- end;

-- --
-- -- Determines whether a user is marked as a spammer, based on user login.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string|WP_User user Optional. Defaults to current user. WP_User object,
-- --                             or user login name as a string.
-- -- @return bool
-- --
-- function is_user_spammy( user := null ) then
--         if ( ! ( user instanceof WP_User ) ) then
--                 if ( user ) then
--                         user := get_user_by( "login", user );
--                 end; else then
--                         user := wp_get_current_user();
--                 end;
--         end;

--         return user && isset( user.spam ) && 1 == user.spam;
-- end;

-- --
-- -- Updates this blog"s "public" setting in the global blogs table.
-- --
-- -- Public blogs have a setting of 1, private blogs are 0.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param int old_value
-- -- @param int value     The new public value
-- --
-- function update_blog_public( old_value, value ) then
--         update_blog_status( get_current_blog_id(), "public", (int) value );
-- end;

-- --
-- -- Determines whether users can self-register, based on Network settings.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @return bool
-- --
-- function users_can_register_signup_filter() then
--         registration := get_site_option( "registration" );
--         return ( "all" === registration || "user" === registration );
-- end;

-- --
-- -- Ensures that the welcome message is not empty. Currently unused.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @param string text
-- -- @return string
-- --
-- function welcome_user_msg_filter( text ) then
--         if ( ! text ) then
--                 remove_filter( "site_option_welcome_user_email", "welcome_user_msg_filter" );

--                 /* translators: Do not translate USERNAME, PASSWORD, LOGINLINK, SITE_NAME: those are placeholders.--
--                 text := __(
--                         "Howdy USERNAME,

-- Your new account is set up.

-- You can log in with the following information:
-- Username: USERNAME
-- Password: PASSWORD
-- LOGINLINK

-- Thanks!

-- --The Team @ SITE_NAME"
--                 );
--                 update_site_option( "welcome_user_email", text );
--         end;
--         return text;
-- end;

-- --
-- -- Determines whether to force SSL on content.
-- --
-- -- @since 2.8.5
-- --
-- -- @param bool force
-- -- @return bool True if forced, false if not forced.
-- --
-- function force_ssl_content( force := "" ) then
--         static forced_content := false;

--         if ( ! force ) then
--                 old_forced     := forced_content;
--                 forced_content := force;
--                 return old_forced;
--         end;

--         return forced_content;
-- end;

-- --
-- -- Formats a URL to use https.
-- --
-- -- Useful as a filter.
-- --
-- -- @since 2.8.5
-- --
-- -- @param string url URL
-- -- @return string URL with https as the scheme
-- --
-- function filter_SSL( url ) then  // phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionNameInvalid
--         if ( ! is_string( url ) ) then
--                 return get_bloginfo( "url" ); // Return home blog URL with proper scheme.
--         end;

--         if ( force_ssl_content() && is_ssl() ) then
--                 url := set_url_scheme( url, "https" );
--         end;

--         return url;
-- end;

-- --
-- -- Schedules update of the network-wide counts for the current network.
-- --
-- -- @since 3.1.0
-- --
-- function wp_schedule_update_network_counts() then
--         if ( ! is_main_site() ) then
--                 return;
--         end;

--         if ( ! wp_next_scheduled( "update_network_counts" ) && ! wp_installing() ) then
--                 wp_schedule_event( time(), "twicedaily", "update_network_counts" );
--         end;
-- end;

-- --
-- -- Updates the network-wide counts for the current network.
-- --
-- -- @since 3.1.0
-- -- @since 4.8.0 The `network_id` parameter has been added.
-- --
-- -- @param int|null network_id ID of the network. Default is the current network.
-- --
-- function wp_update_network_counts( network_id := null ) then
--         wp_update_network_user_counts( network_id );
--         wp_update_network_site_counts( network_id );
-- end;

-- --
-- -- Updates the count of sites for the current network.
-- --
-- -- If enabled through the {@see "enable_live_network_counts"} filter, update the sites count
-- -- on a network when a site is created or its status is updated.
-- --
-- -- @since 3.7.0
-- -- @since 4.8.0 The `network_id` parameter has been added.
-- --
-- -- @param int|null network_id ID of the network. Default is the current network.
-- --
-- function wp_maybe_update_network_site_counts( network_id := null ) then
--         is_small_network := ! wp_is_large_network( "sites", network_id );

--         --
--         -- Filters whether to update network site or user counts when a new site is created.
--         --
--         -- @since 3.7.0
--         --
--         -- @see wp_is_large_network()
--         --
--         -- @param bool   small_network Whether the network is considered small.
--         -- @param string context       Context. Either "users" or "sites".
--         --
--         if ( ! apply_filters( "enable_live_network_counts", is_small_network, "sites" ) ) then
--                 return;
--         end;

--         wp_update_network_site_counts( network_id );
-- end;

-- --
-- -- Updates the network-wide users count.
-- --
-- -- If enabled through the {@see "enable_live_network_counts"} filter, update the users count
-- -- on a network when a user is created or its status is updated.
-- --
-- -- @since 3.7.0
-- -- @since 4.8.0 The `network_id` parameter has been added.
-- --
-- -- @param int|null network_id ID of the network. Default is the current network.
-- --
-- function wp_maybe_update_network_user_counts( network_id := null ) then
--         is_small_network := ! wp_is_large_network( "users", network_id );

--         -- This filter is documented in wp-includes/ms-functions.php--
--         if ( ! apply_filters( "enable_live_network_counts", is_small_network, "users" ) ) then
--                 return;
--         end;

--         wp_update_network_user_counts( network_id );
-- end;

-- --
-- -- Updates the network-wide site count.
-- --
-- -- @since 3.7.0
-- -- @since 4.8.0 The `network_id` parameter has been added.
-- --
-- -- @param int|null network_id ID of the network. Default is the current network.
-- --
-- function wp_update_network_site_counts( network_id := null ) then
--         network_id := (int) network_id;
--         if ( ! network_id ) then
--                 network_id := get_current_network_id();
--         end;

--         count := get_sites(
--                 array(
--                         "network_id"             => network_id,
--                         "spam"                   => 0,
--                         "deleted"                => 0,
--                         "archived"               => 0,
--                         "count"                  => true,
--                         "update_site_meta_cache" => false,
--                 )
--         );

--         update_network_option( network_id, "blog_count", count );
-- end;

-- --
-- -- Updates the network-wide user count.
-- --
-- -- @since 3.7.0
-- -- @since 4.8.0 The `network_id` parameter has been added.
-- -- @since 6.0.0 This function is now a wrapper for wp_update_user_counts().
-- --
-- -- @param int|null network_id ID of the network. Default is the current network.
-- --
-- function wp_update_network_user_counts( network_id := null ) then
--         wp_update_user_counts( network_id );
-- end;

-- --
-- -- Returns the space used by the current site.
-- --
-- -- @since 3.5.0
-- --
-- -- @return int Used space in megabytes.
-- --
-- function get_space_used() then
--         --
--         -- Filters the amount of storage space used by the current site, in megabytes.
--         --
--         -- @since 3.5.0
--         --
--         -- @param int|false space_used The amount of used space, in megabytes. Default false.
--         --
--         space_used := apply_filters( "pre_get_space_used", false );

--         if ( false === space_used ) then
--                 upload_dir := wp_upload_dir();
--                 space_used := get_dirsize( upload_dir("basedir") ) / MB_IN_BYTES;
--         end;

--         return space_used;
-- end;

-- --
-- -- Returns the upload quota for the current blog.
-- --
-- -- @since MU (3.0.0)
-- --
-- -- @return int Quota in megabytes
-- --
-- function get_space_allowed() then
--         space_allowed := get_option( "blog_upload_space" );

--         if ( ! is_numeric( space_allowed ) ) then
--                 space_allowed := get_site_option( "blog_upload_space" );
--         end;

--         if ( ! is_numeric( space_allowed ) ) then
--                 space_allowed := 100;
--         end;

--         --
--         -- Filters the upload quota for the current site.
--         --
--         -- @since 3.7.0
--         --
--         -- @param int space_allowed Upload quota in megabytes for the current blog.
--         --
--         return apply_filters( "get_space_allowed", space_allowed );
-- end;

-- --
-- -- Determines if there is any upload space left in the current blog"s quota.
-- --
-- -- @since 3.0.0
-- --
-- -- @return int of upload space available in bytes
-- --
-- function get_upload_space_available() then
--         allowed := get_space_allowed();
--         if ( allowed < 0 ) then
--                 allowed := 0;
--         end;
--         space_allowed := allowed-- MB_IN_BYTES;
--         if ( get_site_option( "upload_space_check_disabled" ) ) then
--                 return space_allowed;
--         end;

--         space_used := get_space_used()-- MB_IN_BYTES;

--         if ( ( space_allowed - space_used ) <= 0 ) then
--                 return 0;
--         end;

--         return space_allowed - space_used;
-- end;

-- --
-- -- Determines if there is any upload space left in the current blog"s quota.
-- --
-- -- @since 3.0.0
-- -- @return bool True if space is available, false otherwise.
-- --
-- function is_upload_space_available() then
--         if ( get_site_option( "upload_space_check_disabled" ) ) then
--                 return true;
--         end;

--         return (bool) get_upload_space_available();
-- end;

-- --
-- -- Filters the maximum upload file size allowed, in bytes.
-- --
-- -- @since 3.0.0
-- --
-- -- @param int size Upload size limit in bytes.
-- -- @return int Upload size limit in bytes.
-- --
-- function upload_size_limit_filter( size ) then
--         fileupload_maxk         := (int) get_site_option( "fileupload_maxk", 1500 );
--         max_fileupload_in_bytes := KB_IN_BYTES-- fileupload_maxk;

--         if ( get_site_option( "upload_space_check_disabled" ) ) then
--                 return min( size, max_fileupload_in_bytes );
--         end;

--         return min( size, max_fileupload_in_bytes, get_upload_space_available() );
-- end;

-- --
-- -- Determines whether or not we have a large network.
-- --
-- -- The default criteria for a large network is either more than 10,000 users or more than 10,000 sites.
-- -- Plugins can alter this criteria using the {@see "wp_is_large_network"} filter.
-- --
-- -- @since 3.3.0
-- -- @since 4.8.0 The `network_id` parameter has been added.
-- --
-- -- @param string   using      "sites or "users". Default is "sites".
-- -- @param int|null network_id ID of the network. Default is the current network.
-- -- @return bool True if the network meets the criteria for large. False otherwise.
-- --
-- function wp_is_large_network( using := "sites", network_id := null ) then
--         network_id := (int) network_id;
--         if ( ! network_id ) then
--                 network_id := get_current_network_id();
--         end;

--         if ( "users" === using ) then
--                 count := get_user_count( network_id );

--                 is_large_network := wp_is_large_user_count( network_id );

--                 --
--                 -- Filters whether the network is considered large.
--                 --
--                 -- @since 3.3.0
--                 -- @since 4.8.0 The `network_id` parameter has been added.
--                 --
--                 -- @param bool   is_large_network Whether the network has more than 10000 users or sites.
--                 -- @param string component        The component to count. Accepts "users", or "sites".
--                 -- @param int    count            The count of items for the component.
--                 -- @param int    network_id       The ID of the network being checked.
--                 --
--                 return apply_filters( "wp_is_large_network", is_large_network, "users", count, network_id );
--         end;

--         count := get_blog_count( network_id );

--         -- This filter is documented in wp-includes/ms-functions.php--
--         return apply_filters( "wp_is_large_network", count > 10000, "sites", count, network_id );
-- end;

-- --
-- -- Retrieves a list of reserved site on a sub-directory Multisite installation.
-- --
-- -- @since 4.4.0
-- --
-- -- @return string() Array of reserved names.
-- --
-- function get_subdirectory_reserved_names() then
--         names := array(
--                 "page",
--                 "comments",
--                 "blog",
--                 "files",
--                 "feed",
--                 "wp-admin",
--                 "wp-content",
--                 "wp-includes",
--                 "wp-json",
--                 "embed",
--         );

--         --
--         -- Filters reserved site names on a sub-directory Multisite installation.
--         --
--         -- @since 3.0.0
--         -- @since 4.4.0 "wp-admin", "wp-content", "wp-includes", "wp-json", and "embed" were added
--         --              to the reserved names list.
--         --
--         -- @param string() subdirectory_reserved_names Array of reserved names.
--         --
--         return apply_filters( "subdirectory_reserved_names", names );
-- end;

-- --
-- -- Sends a confirmation request email when a change of network admin email address is attempted.
-- --
-- -- The new network admin address will not become active until confirmed.
-- --
-- -- @since 4.9.0
-- --
-- -- @param string old_value The old network admin email address.
-- -- @param string value     The proposed new network admin email address.
-- --
-- function update_network_option_new_admin_email( old_value, value ) then
--         if ( get_site_option( "admin_email" ) === value || ! is_email( value ) ) then
--                 return;
--         end;

--         hash            := md5( value . time() . mt_rand() );
--         new_admin_email := array(
--                 "hash"     => hash,
--                 "newemail" => value,
--         );
--         update_site_option( "network_admin_hash", new_admin_email );

--         switched_locale := switch_to_locale( get_user_locale() );

--         /* translators: Do not translate USERNAME, ADMIN_URL, EMAIL, SITENAME, SITEURL: those are placeholders.--
--         email_text := __(
--                 "Howdy ###USERNAME###,

-- You recently requested to have the network admin email address on
-- your network changed.

-- If this is correct, please click on the following link to change it:
-- ###ADMIN_URL###

-- You can safely ignore and delete this email if you do not want to
-- take this action.

-- This email has been sent to ###EMAIL###

-- Regards,
-- All at ###SITENAME###
-- ###SITEURL###"
--         );

--         --
--         -- Filters the text of the email sent when a change of network admin email address is attempted.
--         --
--         -- The following strings have a special meaning and will get replaced dynamically:
--         -- ###USERNAME###  The current user"s username.
--         -- ###ADMIN_URL### The link to click on to confirm the email change.
--         -- ###EMAIL###     The proposed new network admin email address.
--         -- ###SITENAME###  The name of the network.
--         -- ###SITEURL###   The URL to the network.
--         --
--         -- @since 4.9.0
--         --
--         -- @param string email_text      Text in the email.
--         -- @param array  new_admin_email then
--         --     Data relating to the new network admin email address.
--         --
--         --     @type string hash     The secure hash used in the confirmation link URL.
--         --     @type string newemail The proposed new network admin email address.
--         -- end;
--         --
--         content := apply_filters( "new_network_admin_email_content", email_text, new_admin_email );

--         current_user := wp_get_current_user();
--         content      := str_replace( "###USERNAME###", current_user.user_login, content );
--         content      := str_replace( "###ADMIN_URL###", esc_url( network_admin_url( "settings.php?network_admin_hash=" . hash ) ), content );
--         content      := str_replace( "###EMAIL###", value, content );
--         content      := str_replace( "###SITENAME###", wp_specialchars_decode( get_site_option( "site_name" ), ENT_QUOTES ), content );
--         content      := str_replace( "###SITEURL###", network_home_url(), content );

--         wp_mail(
--                 value,
--                 sprintf(
--                         /* translators: Email change notification email subject. %s: Network title.--
--                         __( "(%s) Network Admin Email Change Request" ),
--                         wp_specialchars_decode( get_site_option( "site_name" ), ENT_QUOTES )
--                 ),
--                 content
--         );

--         if ( switched_locale ) then
--                 restore_previous_locale();
--         end;
-- end;

-- --
-- -- Sends an email to the old network admin email address when the network admin email address changes.
-- --
-- -- @since 4.9.0
-- --
-- -- @param string option_name The relevant database option name.
-- -- @param string new_email   The new network admin email address.
-- -- @param string old_email   The old network admin email address.
-- -- @param int    network_id  ID of the network.
-- --
-- function wp_network_admin_email_change_notification( option_name, new_email, old_email, network_id ) then
--         send := true;

--         // Don't send the notification to the default "admin_email" value.
--         if ( "you@example.com" === old_email ) then
--                 send := false;
--         end;

--         --
--         -- Filters whether to send the network admin email change notification email.
--         --
--         -- @since 4.9.0
--         --
--         -- @param bool   send       Whether to send the email notification.
--         -- @param string old_email  The old network admin email address.
--         -- @param string new_email  The new network admin email address.
--         -- @param int    network_id ID of the network.
--         --
--         send := apply_filters( "send_network_admin_email_change_email", send, old_email, new_email, network_id );

--         if ( ! send ) then
--                 return;
--         end;

--         /* translators: Do not translate OLD_EMAIL, NEW_EMAIL, SITENAME, SITEURL: those are placeholders.--
--         email_change_text := __(
--                 "Hi,

-- This notice confirms that the network admin email address was changed on ###SITENAME###.

-- The new network admin email address is ###NEW_EMAIL###.

-- This email has been sent to ###OLD_EMAIL###

-- Regards,
-- All at ###SITENAME###
-- ###SITEURL###"
--         );

--         email_change_email := array(
--                 "to"      => old_email,
--                 /* translators: Network admin email change notification email subject. %s: Network title.--
--                 "subject" => __( "(%s) Network Admin Email Changed" ),
--                 "message" => email_change_text,
--                 "headers" => "",
--         );
--         // Get network name.
--         network_name := wp_specialchars_decode( get_site_option( "site_name" ), ENT_QUOTES );

--         --
--         -- Filters the contents of the email notification sent when the network admin email address is changed.
--         --
--         -- @since 4.9.0
--         --
--         -- @param array email_change_email then
--         --     Used to build wp_mail().
--         --
--         --     @type string to      The intended recipient.
--         --     @type string subject The subject of the email.
--         --     @type string message The content of the email.
--         --         The following strings have a special meaning and will get replaced dynamically:
--         --         - ###OLD_EMAIL### The old network admin email address.
--         --         - ###NEW_EMAIL### The new network admin email address.
--         --         - ###SITENAME###  The name of the network.
--         --         - ###SITEURL###   The URL to the site.
--         --     @type string headers Headers.
--         -- end;
--         -- @param string old_email  The old network admin email address.
--         -- @param string new_email  The new network admin email address.
--         -- @param int    network_id ID of the network.
--         --
--         email_change_email := apply_filters( "network_admin_email_change_email", email_change_email, old_email, new_email, network_id );

--         email_change_email("message") := str_replace( "###OLD_EMAIL###", old_email, email_change_email("message") );
--         email_change_email("message") := str_replace( "###NEW_EMAIL###", new_email, email_change_email("message") );
--         email_change_email("message") := str_replace( "###SITENAME###", network_name, email_change_email("message") );
--         email_change_email("message") := str_replace( "###SITEURL###", home_url(), email_change_email("message") );

--         wp_mail(
--                 email_change_email("to"),
--                 sprintf(
--                         email_change_email("subject"),
--                         network_name
--                 ),
--                 email_change_email("message"),
--                 email_change_email("headers")
--         );
-- end;

end Inc_Ms_Functions;
