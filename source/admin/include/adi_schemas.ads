--
-- WordPress Administration Scheme API
--
-- Here we keep the DB structure and option values.
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;

package Adi_Schemas
is
   use Arrays;

   --
   -- Create and modify WordPress roles for WordPress 2.5.
   --
   -- @since 2.5.0
   --
   procedure Populate_Roles_250;

   --
   -- Create and modify WordPress roles for WordPress 2.6.
   --
   -- @since 2.6.0
   --
   procedure Populate_Roles_260;

   --
   -- Create and modify WordPress roles for WordPress 2.7.
   --
   -- @since 2.7.0
   --
   procedure Populate_Roles_270;

   --
   -- Create and modify WordPress roles for WordPress 2.8.
   --
   -- @since 2.8.0
   --
   procedure Populate_Roles_280;

   --
   -- Create and modify WordPress roles for WordPress 3.0.
   --
   -- @since 3.0.0
   --
   procedure Populate_Roles_300;

-- --
-- -- Declare these as global in case schema.php is included from a function.
-- --
-- -- @global wpdb   wpdb            WordPress database abstraction object.
-- -- @global array  wp_queries
-- -- @global string charset_collate
-- --
-- global wpdb, wp_queries, charset_collate;

-- --
-- -- The database character collate.
-- --
-- charset_collate = wpdb->get_charset_collate();

   --
   -- Retrieve the SQL for creating database tables.
   --
   -- @since 3.3.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string scope   Optional. The tables for which to retrieve SQL. Can be
   --                       all, global, ms_global, or blog tables. Defaults to all.
   -- @param int    blog_id Optional. The site ID for which to retrieve SQL. Default
   --                       is the current site ID.
   -- @return string The SQL needed to create the requested tables.
   --
   function Wp_Get_DB_Schema (Scope   : String  := "all";
                              Blog_Id : Integer := 0) -- null
                              return String;

-- // Populate for back compat.
-- wp_queries = wp_get_db_schema( "all" );

   --
   -- Create WordPress options and set the default values.
   --
   -- @since 1.5.0
   -- @since 5.1.0 The options parameter has been added.
   --
   -- @global wpdb wpdb                  WordPress database abstraction object.
   -- @global int  wp_db_version         WordPress database version.
   -- @global int  wp_current_db_version The old (current) database version.
   --
   -- @param array options Optional. Custom option key => value pairs to use.
   --                       Default empty array.
   --
   procedure Populate_Options (Options : Array_Type := Empty_Array);

   --
   -- Execute WordPress role creation for the various WordPress versions.
   --
   -- @since 2.0.0
   --
   procedure Populate_Roles;

-- if ( ! function_exists( "install_network" ) ) :
--         --
--         -- Install Network.
--         --
--         -- @since 3.0.0
--         --
--         function install_network() then
--                 if ( ! defined( "WP_INSTALLING_NETWORK" ) ) then
--                         define( "WP_INSTALLING_NETWORK", true );
--                 end;

--                 dbDelta( wp_get_db_schema( "global" ) );
--         end;
-- endif;

-- --
-- -- Populate network settings.
-- --
-- -- @since 3.0.0
-- --
-- -- @global wpdb       wpdb         WordPress database abstraction object.
-- -- @global object     current_site
-- -- @global WP_Rewrite wp_rewrite   WordPress rewrite component.
-- --
-- -- @param int    network_id        ID of network to populate.
-- -- @param string domain            The domain name for the network. Example: "example.com".
-- -- @param string email             Email address for the network administrator.
-- -- @param string site_name         The name of the network.
-- -- @param string path              Optional. The path to append to the network"s domain name. Default "/".
-- -- @param bool   subdomain_install Optional. Whether the network is a subdomain installation or a subdirectory installation.
-- --                                  Default false, meaning the network is a subdirectory installation.
-- -- @return bool|WP_Error True on success, or WP_Error on warning (with the installation otherwise successful,
-- --                       so the error code must be checked) or failure.
-- --
-- function populate_network( network_id = 1, domain = "", email = "", site_name = "", path = "/", subdomain_install = false ) then
--         global wpdb, current_site, wp_rewrite;

--         errors = new WP_Error();
--         if ( "" === domain ) then
--                 errors->add( "empty_domain", __( "You must provide a domain name." ) );
--         end;
--         if ( "" === site_name ) then
--                 errors->add( "empty_sitename", __( "You must provide a name for your network of sites." ) );
--         end;

--         // Check for network collision.
--         network_exists = false;
--         if ( is_multisite() ) then
--                 if ( get_network( (int) network_id ) ) then
--                         errors->add( "siteid_exists", __( "The network already exists." ) );
--                 end;
--         end; else then
--                 if ( network_id == wpdb->get_var( wpdb->prepare( "SELECT id FROM wpdb->site WHERE id = %d", network_id ) ) ) then
--                         errors->add( "siteid_exists", __( "The network already exists." ) );
--                 end;
--         end;

--         if ( ! is_email( email ) ) then
--                 errors->add( "invalid_email", __( "You must provide a valid email address." ) );
--         end;

--         if ( errors->has_errors() ) then
--                 return errors;
--         end;

--         if ( 1 == network_id ) then
--                 wpdb->insert(
--                         wpdb->site,
--                         array(
--                                 "domain" => domain,
--                                 "path"   => path,
--                         )
--                 );
--                 network_id = wpdb->insert_id;
--         end; else then
--                 wpdb->insert(
--                         wpdb->site,
--                         array(
--                                 "domain" => domain,
--                                 "path"   => path,
--                                 "id"     => network_id,
--                         )
--                 );
--         end;

--         populate_network_meta(
--                 network_id,
--                 array(
--                         "admin_email"       => email,
--                         "site_name"         => site_name,
--                         "subdomain_install" => subdomain_install,
--                 )
--         );

--         site_user = get_userdata( (int) wpdb->get_var( wpdb->prepare( "SELECT meta_value FROM wpdb->sitemeta WHERE meta_key = %s AND site_id = %d", "admin_user_id", network_id ) ) );

--         /*
--         -- When upgrading from single to multisite, assume the current site will
--         -- become the main site of the network. When using populate_network()
--         -- to create another network in an existing multisite environment, skip
--         -- these steps since the main site of the new network has not yet been
--         -- created.
--         --
--         if ( ! is_multisite() ) then
--                 current_site            = new stdClass;
--                 current_site->domain    = domain;
--                 current_site->path      = path;
--                 current_site->site_name = ucfirst( domain );
--                 wpdb->insert(
--                         wpdb->blogs,
--                         array(
--                                 "site_id"    => network_id,
--                                 "blog_id"    => 1,
--                                 "domain"     => domain,
--                                 "path"       => path,
--                                 "registered" => current_time( "mysql" ),
--                         )
--                 );
--                 current_site->blog_id = wpdb->insert_id;
--                 update_user_meta( site_user->ID, "source_domain", domain );
--                 update_user_meta( site_user->ID, "primary_blog", current_site->blog_id );

--                 // Unable to use update_network_option() while populating the network.
--                 wpdb->insert(
--                         wpdb->sitemeta,
--                         array(
--                                 "site_id"    => network_id,
--                                 "meta_key"   => "main_site",
--                                 "meta_value" => current_site->blog_id,
--                         )
--                 );

--                 if ( subdomain_install ) then
--                         wp_rewrite->set_permalink_structure( "/%year%/%monthnum%/%day%/%postname%/" );
--                 end; else then
--                         wp_rewrite->set_permalink_structure( "/blog/%year%/%monthnum%/%day%/%postname%/" );
--                 end;

--                 flush_rewrite_rules();

--                 if ( ! subdomain_install ) then
--                         return true;
--                 end;

--                 vhost_ok = false;
--                 errstr   = "";
--                 hostname = substr( md5( time() ), 0, 6 ) . "." . domain; // Very random hostname!
--                 page     = wp_remote_get(
--                         "http://" . hostname,
--                         array(
--                                 "timeout"     => 5,
--                                 "httpversion" => "1.1",
--                         )
--                 );
--                 if ( is_wp_error( page ) ) then
--                         errstr = page->get_error_message();
--                 end; elseif ( 200 == wp_remote_retrieve_response_code( page ) ) then
--                                 vhost_ok = true;
--                 end;

--                 if ( ! vhost_ok ) then
--                         msg = "<p><strong>" . __( "Warning! Wildcard DNS may not be configured correctly!" ) . "</strong></p>";

--                         msg .= "<p>" . sprintf(
--                                 /* translators: %s: Host name.--
--                                 __( "The installer attempted to contact a random hostname (%s) on your domain." ),
--                                 "<code>" . hostname . "</code>"
--                         );
--                         if ( ! empty( errstr ) ) then
--                                 /* translators: %s: Error message.--
--                                 msg .= " " . sprintf( __( "This resulted in an error message: %s" ), "<code>" . errstr . "</code>" );
--                         end;
--                         msg .= "</p>";

--                         msg .= "<p>" . sprintf(
--                                 /* translators: %s: Asterisk symbol (*).--
--                                 __( "To use a subdomain configuration, you must have a wildcard entry in your DNS. This usually means adding a %s hostname record pointing at your web server in your DNS configuration tool." ),
--                                 "<code>*</code>"
--                         ) . "</p>";

--                         msg .= "<p>" . __( "You can still use your site but any subdomain you create may not be accessible. If you know your DNS is correct, ignore this message." ) . "</p>";

--                         return new WP_Error( "no_wildcard_dns", msg );
--                 end;
--         end;

--         return true;
-- end;

-- --
-- -- Creates WordPress network meta and sets the default values.
-- --
-- -- @since 5.1.0
-- --
-- -- @global wpdb wpdb          WordPress database abstraction object.
-- -- @global int  wp_db_version WordPress database version.
-- --
-- -- @param int   network_id Network ID to populate meta for.
-- -- @param array meta       Optional. Custom meta key => value pairs to use. Default empty array.
-- --
-- function populate_network_meta( network_id, array meta = array() ) then
--         global wpdb, wp_db_version;

--         network_id = (int) network_id;

--         email             = ! empty( meta["admin_email"] ) ? meta["admin_email"] : "";
--         subdomain_install = isset( meta["subdomain_install"] ) ? (int) meta["subdomain_install"] : 0;

--         // If a user with the provided email does not exist, default to the current user as the new network admin.
--         site_user = ! empty( email ) ? get_user_by( "email", email ) : false;
--         if ( false === site_user ) then
--                 site_user = wp_get_current_user();
--         end;

--         if ( empty( email ) ) then
--                 email = site_user->user_email;
--         end;

--         template       = get_option( "template" );
--         stylesheet     = get_option( "stylesheet" );
--         allowed_themes = array( stylesheet => true );

--         if ( template != stylesheet ) then
--                 allowed_themes[ template ] = true;
--         end;

--         if ( WP_DEFAULT_THEME != stylesheet && WP_DEFAULT_THEME != template ) then
--                 allowed_themes[ WP_DEFAULT_THEME ] = true;
--         end;

--         // If WP_DEFAULT_THEME doesn"t exist, also include the latest core default theme.
--         if ( ! wp_get_theme( WP_DEFAULT_THEME )->exists() ) then
--                 core_default = WP_Theme::get_core_default_theme();
--                 if ( core_default ) then
--                         allowed_themes[ core_default->get_stylesheet() ] = true;
--                 end;
--         end;

--         if ( function_exists( "clean_network_cache" ) ) then
--                 clean_network_cache( network_id );
--         end; else then
--                 wp_cache_delete( network_id, "networks" );
--         end;

--         if ( ! is_multisite() ) then
--                 site_admins = array( site_user->user_login );
--                 users       = get_users(
--                         array(
--                                 "fields" => array( "user_login" ),
--                                 "role"   => "administrator",
--                         )
--                 );
--                 if ( users ) then
--                         foreach ( users as user ) then
--                                 site_admins[] = user->user_login;
--                         end;

--                         site_admins = array_unique( site_admins );
--                 end;
--         end; else then
--                 site_admins = get_site_option( "site_admins" );
--         end;

--         /* translators: Do not translate USERNAME, SITE_NAME, BLOG_URL, PASSWORD: those are placeholders.--
--         welcome_email = __(
--                 "Howdy USERNAME,

-- Your new SITE_NAME site has been successfully set up at:
-- BLOG_URL

-- You can log in to the administrator account with the following information:

-- Username: USERNAME
-- Password: PASSWORD
-- Log in here: BLOG_URLwp-login.php

-- We hope you enjoy your new site. Thanks!

-- --The Team @ SITE_NAME"
--         );

--         misc_exts        = array(
--                 // Images.
--                 "jpg",
--                 "jpeg",
--                 "png",
--                 "gif",
--                 "webp",
--                 // Video.
--                 "mov",
--                 "avi",
--                 "mpg",
--                 "3gp",
--                 "3g2",
--                 // "audio".
--                 "midi",
--                 "mid",
--                 // Miscellaneous.
--                 "pdf",
--                 "doc",
--                 "ppt",
--                 "odt",
--                 "pptx",
--                 "docx",
--                 "pps",
--                 "ppsx",
--                 "xls",
--                 "xlsx",
--                 "key",
--         );
--         audio_exts       = wp_get_audio_extensions();
--         video_exts       = wp_get_video_extensions();
--         upload_filetypes = array_unique( array_merge( misc_exts, audio_exts, video_exts ) );

--         sitemeta = array(
--                 "site_name"                   => __( "My Network" ),
--                 "admin_email"                 => email,
--                 "admin_user_id"               => site_user->ID,
--                 "registration"                => "none",
--                 "upload_filetypes"            => implode( " ", upload_filetypes ),
--                 "blog_upload_space"           => 100,
--                 "fileupload_maxk"             => 1500,
--                 "site_admins"                 => site_admins,
--                 "allowedthemes"               => allowed_themes,
--                 "illegal_names"               => array( "www", "web", "root", "admin", "main", "invite", "administrator", "files" ),
--                 "wpmu_upgrade_site"           => wp_db_version,
--                 "welcome_email"               => welcome_email,
--                 /* translators: %s: Site link.--
--                 "first_post"                  => __( "Welcome to %s. This is your first post. Edit or delete it, then start writing!" ),
--                 // @todo - Network admins should have a method of editing the network siteurl (used for cookie hash).
--                 "siteurl"                     => get_option( "siteurl" ) . "/",
--                 "add_new_users"               => "0",
--                 "upload_space_check_disabled" => is_multisite() ? get_site_option( "upload_space_check_disabled" ) : "1",
--                 "subdomain_install"           => subdomain_install,
--                 "ms_files_rewriting"          => is_multisite() ? get_site_option( "ms_files_rewriting" ) : "0",
--                 "user_count"                  => get_site_option( "user_count" ),
--                 "initial_db_version"          => get_option( "initial_db_version" ),
--                 "active_sitewide_plugins"     => array(),
--                 "WPLANG"                      => get_locale(),
--         );
--         if ( ! subdomain_install ) then
--                 sitemeta["illegal_names"][] = "blog";
--         end;

--         sitemeta = wp_parse_args( meta, sitemeta );

--         --
--         -- Filters meta for a network on creation.
--         --
--         -- @since 3.7.0
--         --
--         -- @param array sitemeta   Associative array of network meta keys and values to be inserted.
--         -- @param int   network_id ID of network to populate.
--         --
--         sitemeta = apply_filters( "populate_network_meta", sitemeta, network_id );

--         insert = "";
--         foreach ( sitemeta as meta_key => meta_value ) then
--                 if ( is_array( meta_value ) ) then
--                         meta_value = serialize( meta_value );
--                 end;
--                 if ( ! empty( insert ) ) then
--                         insert .= ", ";
--                 end;
--                 insert .= wpdb->prepare( "( %d, %s, %s)", network_id, meta_key, meta_value );
--         end;
--         wpdb->query( "INSERT INTO wpdb->sitemeta ( site_id, meta_key, meta_value ) VALUES " . insert ); // phpcs:ignore WordPress.DB.PreparedSQL.NotPrepared
-- end;

-- --
-- -- Creates WordPress site meta and sets the default values.
-- --
-- -- @since 5.1.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int   site_id Site ID to populate meta for.
-- -- @param array meta    Optional. Custom meta key => value pairs to use. Default empty array.
-- --
-- function populate_site_meta( site_id, array meta = array() ) then
--         global wpdb;

--         site_id = (int) site_id;

--         if ( ! is_site_meta_supported() ) then
--                 return;
--         end;

--         if ( empty( meta ) ) then
--                 return;
--         end;

--         --
--         -- Filters meta for a site on creation.
--         --
--         -- @since 5.2.0
--         --
--         -- @param array meta    Associative array of site meta keys and values to be inserted.
--         -- @param int   site_id ID of site to populate.
--         --
--         site_meta = apply_filters( "populate_site_meta", meta, site_id );

--         insert = "";
--         foreach ( site_meta as meta_key => meta_value ) then
--                 if ( is_array( meta_value ) ) then
--                         meta_value = serialize( meta_value );
--                 end;
--                 if ( ! empty( insert ) ) then
--                         insert .= ", ";
--                 end;
--                 insert .= wpdb->prepare( "( %d, %s, %s)", site_id, meta_key, meta_value );
--         end;

--         wpdb->query( "INSERT INTO wpdb->blogmeta ( blog_id, meta_key, meta_value ) VALUES " . insert ); // phpcs:ignore WordPress.DB.PreparedSQL.NotPrepared

--         wp_cache_delete( site_id, "blog_meta" );
--         wp_cache_set_sites_last_changed();
-- end;

end Adi_Schemas;
