--
-- WordPress Upgrade API
--
-- Most of the functions are pluggable and can be overwritten.
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;

package Adi_Upgrade
is
   use Arrays;

   Wp_Current_DB_Version : Integer := 0;  -- Added by jq

-- -- Include user installation customization script.--
-- if ( file_exists( WP_CONTENT_DIR . "/install.php" ) ) then
--         require WP_CONTENT_DIR . "/install.php";
-- end;

-- -- WordPress Administration API--
-- require_once ABSPATH . "wp-admin/includes/admin.php";

-- -- WordPress Schema API--
-- require_once ABSPATH . "wp-admin/includes/schema.php";

-- if ( ! function_exists( "wp_install" ) ) :

   --
   -- Installs the site.
   --
   -- Runs the required functions to set up and populate the database,
   -- including primary admin user and initial options.
   --
   -- @since 2.1.0
   --
   -- @param string blog_title    Site title.
   -- @param string user_name     User"s username.
   -- @param string user_email    User"s email.
   -- @param bool   is_public     Whether the site is public.
   -- @param string deprecated    Optional. Not used.
   -- @param string user_password Optional. User"s chosen password. Default empty
   --                              (random password).
   -- @param string language      Optional. Language chosen. Default empty.
   -- @return array {
   --     Data for the newly installed site.
   --
   --     @type string url              The URL of the site.
   --     @type int    user_id          The ID of the site owner.
   --     @type string password         The password of the site owner, if their user
   --                                    account didn't already exist.
   --     @type string password_message The explanatory message regarding the password.
   -- }
   --
   function Wp_Install (Blog_Title    : String;
                        User_Name     : String;
                        User_Email    : String;
                        Is_Public     : Boolean;
                        Deprecated    : String := "";
                        User_Password : String := "";
                        Language      : String := "")
                        return Arrays.Array_Type;

-- endif;

-- if ( ! function_exists( "wp_install_defaults" ) ) :
   --
   -- Creates the initial content for a newly-installed site.
   --
   -- Adds the default "Uncategorized" category, the first post (with comment),
   -- first page, and default widgets for default theme for the current version.
   --
   -- @since 2.1.0
   --
   -- @global wpdb       wpdb         WordPress database abstraction object.
   -- @global WP_Rewrite wp_rewrite   WordPress rewrite component.
   -- @global string     table_prefix
   --
   -- @param int user_id User ID.
   --
   procedure Wp_Install_Defaults (User_Id : Integer)
   is null;
--                 global wpdb, wp_rewrite, table_prefix;

--                 -- Default category.
--                 cat_name = __( "Uncategorized" );
--                 /* translators: Default category slug.--
--                 cat_slug = sanitize_title( _x( "Uncategorized", "Default category slug" ) );

--                 cat_id = 1;

--                 wpdb->insert(
--                         wpdb->terms,
--                         array(
--                                 "term_id"    => cat_id,
--                                 "name"       => cat_name,
--                                 "slug"       => cat_slug,
--                                 "term_group" => 0,
--                         )
--                 );
--                 wpdb->insert(
--                         wpdb->term_taxonomy,
--                         array(
--                                 "term_id"     => cat_id,
--                                 "taxonomy"    => "category",
--                                 "description" => "",
--                                 "parent"      => 0,
--                                 "count"       => 1,
--                         )
--                 );
--                 cat_tt_id = wpdb->insert_id;

--                 -- First post.
--                 now             = current_time( "mysql" );
--                 now_gmt         = current_time( "mysql", 1 );
--                 first_post_guid = get_option( "home" ) . "/?p=1";

--                 if ( is_multisite() ) then
--                         first_post = get_site_option( "first_post" );

--                         if ( ! first_post ) then
--                                 first_post = "<!-- wp:paragraph -->\n<p>" .
--                                 /* translators: First post content. %s: Site link.--
--                                 __( "Welcome to %s. This is your first post. Edit or delete it, then start writing!" ) .
--                                 "</p>\n<!-- /wp:paragraph -->";
--                         end;

--                         first_post = sprintf(
--                                 first_post,
--                                 sprintf( "<a href="%s">%s</a>", esc_url( network_home_url() ), get_network()->site_name )
--                         );

--                         -- Back-compat for pre-4.4.
--                         first_post = str_replace( "SITE_URL", esc_url( network_home_url() ), first_post );
--                         first_post = str_replace( "SITE_NAME", get_network()->site_name, first_post );
--                 end; else then
--                         first_post = "<!-- wp:paragraph -->\n<p>" .
--                         /* translators: First post content. %s: Site link.--
--                         __( "Welcome to WordPress. This is your first post. Edit or delete it, then start writing!" ) .
--                         "</p>\n<!-- /wp:paragraph -->";
--                 end;

--                 wpdb->insert(
--                         wpdb->posts,
--                         array(
--                                 "post_author"           => user_id,
--                                 "post_date"             => now,
--                                 "post_date_gmt"         => now_gmt,
--                                 "post_content"          => first_post,
--                                 "post_excerpt"          => "",
--                                 "post_title"            => __( "Hello world!" ),
--                                 /* translators: Default post slug.--
--                                 "post_name"             => sanitize_title( _x( "hello-world", "Default post slug" ) ),
--                                 "post_modified"         => now,
--                                 "post_modified_gmt"     => now_gmt,
--                                 "guid"                  => first_post_guid,
--                                 "comment_count"         => 1,
--                                 "to_ping"               => "",
--                                 "pinged"                => "",
--                                 "post_content_filtered" => "",
--                         )
--                 );

--                 if ( is_multisite() ) then
--                         update_posts_count();
--                 end;

--                 wpdb->insert(
--                         wpdb->term_relationships,
--                         array(
--                                 "term_taxonomy_id" => cat_tt_id,
--                                 "object_id"        => 1,
--                         )
--                 );

--                 -- Default comment.
--                 if ( is_multisite() ) then
--                         first_comment_author = get_site_option( "first_comment_author" );
--                         first_comment_email  = get_site_option( "first_comment_email" );
--                         first_comment_url    = get_site_option( "first_comment_url", network_home_url() );
--                         first_comment        = get_site_option( "first_comment" );
--                 end;

--                 first_comment_author = ! empty( first_comment_author ) ? first_comment_author : __( "A WordPress Commenter" );
--                 first_comment_email  = ! empty( first_comment_email ) ? first_comment_email : "wapuu@wordpress.example";
--                 first_comment_url    = ! empty( first_comment_url ) ? first_comment_url : esc_url( __( "https://wordpress.org/" ) );
--                 first_comment        = ! empty( first_comment ) ? first_comment : sprintf(
--                         /* translators: %s: Gravatar URL.--
--                         __(
--                                 "Hi, this is a comment.
-- To get started with moderating, editing, and deleting comments, please visit the Comments screen in the dashboard.
-- Commenter avatars come from <a href="%s">Gravatar</a>."
--                         ),
--                         esc_url( __( "https://en.gravatar.com/" ) )
--                 );
--                 wpdb->insert(
--                         wpdb->comments,
--                         array(
--                                 "comment_post_ID"      => 1,
--                                 "comment_author"       => first_comment_author,
--                                 "comment_author_email" => first_comment_email,
--                                 "comment_author_url"   => first_comment_url,
--                                 "comment_date"         => now,
--                                 "comment_date_gmt"     => now_gmt,
--                                 "comment_content"      => first_comment,
--                                 "comment_type"         => "comment",
--                         )
--                 );

--                 -- First page.
--                 if ( is_multisite() ) then
--                         first_page = get_site_option( "first_page" );
--                 end;

--                 if ( empty( first_page ) ) then
--                         first_page = "<!-- wp:paragraph -->\n<p>";
--                         /* translators: First page content.--
--                         first_page .= __( "This is an example page. It"s different from a blog post because it will stay in one place and will show up in your site navigation (in most themes). Most people start with an About page that introduces them to potential site visitors. It might say something like this:" );
--                         first_page .= "</p>\n<!-- /wp:paragraph -->\n\n";

--                         first_page .= "<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>";
--                         /* translators: First page content.--
--                         first_page .= __( "Hi there! I"m a bike messenger by day, aspiring actor by night, and this is my website. I live in Los Angeles, have a great dog named Jack, and I like pi&#241;a coladas. (And gettin" caught in the rain.)" );
--                         first_page .= "</p></blockquote>\n<!-- /wp:quote -->\n\n";

--                         first_page .= "<!-- wp:paragraph -->\n<p>";
--                         /* translators: First page content.--
--                         first_page .= __( "...or something like this:" );
--                         first_page .= "</p>\n<!-- /wp:paragraph -->\n\n";

--                         first_page .= "<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>";
--                         /* translators: First page content.--
--                         first_page .= __( "The XYZ Doohickey Company was founded in 1971, and has been providing quality doohickeys to the public ever since. Located in Gotham City, XYZ employs over 2,000 people and does all kinds of awesome things for the Gotham community." );
--                         first_page .= "</p></blockquote>\n<!-- /wp:quote -->\n\n";

--                         first_page .= "<!-- wp:paragraph -->\n<p>";
--                         first_page .= sprintf(
--                                 /* translators: First page content. %s: Site admin URL.--
--                                 __( "As a new WordPress user, you should go to <a href="%s">your dashboard</a> to delete this page and create new pages for your content. Have fun!" ),
--                                 admin_url()
--                         );
--                         first_page .= "</p>\n<!-- /wp:paragraph -->";
--                 end;

--                 first_post_guid = get_option( "home" ) . "/?page_id=2";
--                 wpdb->insert(
--                         wpdb->posts,
--                         array(
--                                 "post_author"           => user_id,
--                                 "post_date"             => now,
--                                 "post_date_gmt"         => now_gmt,
--                                 "post_content"          => first_page,
--                                 "post_excerpt"          => "",
--                                 "comment_status"        => "closed",
--                                 "post_title"            => __( "Sample Page" ),
--                                 /* translators: Default page slug.--
--                                 "post_name"             => __( "sample-page" ),
--                                 "post_modified"         => now,
--                                 "post_modified_gmt"     => now_gmt,
--                                 "guid"                  => first_post_guid,
--                                 "post_type"             => "page",
--                                 "to_ping"               => "",
--                                 "pinged"                => "",
--                                 "post_content_filtered" => "",
--                         )
--                 );
--                 wpdb->insert(
--                         wpdb->postmeta,
--                         array(
--                                 "post_id"    => 2,
--                                 "meta_key"   => "_wp_page_template",
--                                 "meta_value" => "default",
--                         )
--                 );

--                 -- Privacy Policy page.
--                 if ( is_multisite() ) then
--                         -- Disable by default unless the suggested content is provided.
--                         privacy_policy_content = get_site_option( "default_privacy_policy_content" );
--                 end; else then
--                         if ( ! class_exists( "WP_Privacy_Policy_Content" ) ) then
--                                 include_once ABSPATH . "wp-admin/includes/class-wp-privacy-policy-content.php";
--                         end;

--                         privacy_policy_content = WP_Privacy_Policy_Content::get_default_content();
--                 end;

--                 if ( ! empty( privacy_policy_content ) ) then
--                         privacy_policy_guid = get_option( "home" ) . "/?page_id=3";

--                         wpdb->insert(
--                                 wpdb->posts,
--                                 array(
--                                         "post_author"           => user_id,
--                                         "post_date"             => now,
--                                         "post_date_gmt"         => now_gmt,
--                                         "post_content"          => privacy_policy_content,
--                                         "post_excerpt"          => "",
--                                         "comment_status"        => "closed",
--                                         "post_title"            => __( "Privacy Policy" ),
--                                         /* translators: Privacy Policy page slug.--
--                                         "post_name"             => __( "privacy-policy" ),
--                                         "post_modified"         => now,
--                                         "post_modified_gmt"     => now_gmt,
--                                         "guid"                  => privacy_policy_guid,
--                                         "post_type"             => "page",
--                                         "post_status"           => "draft",
--                                         "to_ping"               => "",
--                                         "pinged"                => "",
--                                         "post_content_filtered" => "",
--                                 )
--                         );
--                         wpdb->insert(
--                                 wpdb->postmeta,
--                                 array(
--                                         "post_id"    => 3,
--                                         "meta_key"   => "_wp_page_template",
--                                         "meta_value" => "default",
--                                 )
--                         );
--                         update_option( "wp_page_for_privacy_policy", 3 );
--                 end;

--                 -- Set up default widgets for default theme.
--                 update_option(
--                         "widget_block",
--                         array(
--                                 2              => array( "content" => "<!-- wp:search /-->" ),
--                                 3              => array( "content" => "<!-- wp:group --><div class="wp-block-group"><!-- wp:heading --><h2>" . __( "Recent Posts" ) . "</h2><!-- /wp:heading --><!-- wp:latest-posts /--></div><!-- /wp:group -->" ),
--                                 4              => array( "content" => "<!-- wp:group --><div class="wp-block-group"><!-- wp:heading --><h2>" . __( "Recent Comments" ) . "</h2><!-- /wp:heading --><!-- wp:latest-comments then"displayAvatar":false,"displayDate":false,"displayExcerpt":falseend; /--></div><!-- /wp:group -->" ),
--                                 5              => array( "content" => "<!-- wp:group --><div class="wp-block-group"><!-- wp:heading --><h2>" . __( "Archives" ) . "</h2><!-- /wp:heading --><!-- wp:archives /--></div><!-- /wp:group -->" ),
--                                 6              => array( "content" => "<!-- wp:group --><div class="wp-block-group"><!-- wp:heading --><h2>" . __( "Categories" ) . "</h2><!-- /wp:heading --><!-- wp:categories /--></div><!-- /wp:group -->" ),
--                                 "_multiwidget" => 1,
--                         )
--                 );
--                 update_option(
--                         "sidebars_widgets",
--                         array(
--                                 "wp_inactive_widgets" => array(),
--                                 "sidebar-1"           => array(
--                                         0 => "block-2",
--                                         1 => "block-3",
--                                         2 => "block-4",
--                                 ),
--                                 "sidebar-2"           => array(
--                                         0 => "block-5",
--                                         1 => "block-6",
--                                 ),
--                                 "array_version"       => 3,
--                         )
--                 );

--                 if ( ! is_multisite() ) then
--                         update_user_meta( user_id, "show_welcome_panel", 1 );
--                 end; elseif ( ! is_super_admin( user_id ) && ! metadata_exists( "user", user_id, "show_welcome_panel" ) ) then
--                         update_user_meta( user_id, "show_welcome_panel", 2 );
--                 end;

--                 if ( is_multisite() ) then
--                         -- Flush rules to pick up the new page.
--                         wp_rewrite->init();
--                         wp_rewrite->flush_rules();

--                         user = new WP_User( user_id );
--                         wpdb->update( wpdb->options, array( "option_value" => user->user_email ), array( "option_name" => "admin_email" ) );

--                         -- Remove all perms except for the login user.
--                         wpdb->query( wpdb->prepare( "DELETE FROM wpdb->usermeta WHERE user_id != %d AND meta_key = %s", user_id, table_prefix . "user_level" ) );
--                         wpdb->query( wpdb->prepare( "DELETE FROM wpdb->usermeta WHERE user_id != %d AND meta_key = %s", user_id, table_prefix . "capabilities" ) );

--                         -- Delete any caps that snuck into the previously active blog. (Hardcoded to blog 1 for now.)
--                         -- TODO: Get previous_blog_id.
--                         if ( ! is_super_admin( user_id ) && 1 != user_id ) then
--                                 wpdb->delete(
--                                         wpdb->usermeta,
--                                         array(
--                                                 "user_id"  => user_id,
--                                                 "meta_key" => wpdb->base_prefix . "1_capabilities",
--                                         )
--                                 );
--                         end;
--                 end;
--         end;
-- endif;

   --
   -- Maybe enable pretty permalinks on installation.
   --
   -- If after enabling pretty permalinks don't work, fallback to query-string
   -- permalinks.
   --
   -- @since 4.2.0
   --
   -- @global WP_Rewrite wp_rewrite WordPress rewrite component.
   --
   -- @return bool Whether pretty permalinks are enabled. False otherwise.
   --
   procedure Wp_Install_Maybe_Enable_Pretty_Permalinks
   is null;
--         global wp_rewrite;

--         -- Bail if a permalink structure is already enabled.
--         if ( get_option( "permalink_structure" ) ) then
--                 return true;
--         end;

--         /*
--         -- The Permalink structures to attempt.
--         --
--         -- The first is designed for mod_rewrite or nginx rewriting.
--         --
--         -- The second is PATHINFO-based permalinks for web server configurations
--         -- without a true rewrite module enabled.
--         --
--         permalink_structures = array(
--                 "/%year%/%monthnum%/%day%/%postname%/",
--                 "/index.php/%year%/%monthnum%/%day%/%postname%/",
--         );

--         foreach ( (array) permalink_structures as permalink_structure ) then
--                 wp_rewrite->set_permalink_structure( permalink_structure );

--                 /*
--                 -- Flush rules with the hard option to force refresh of the web-server"s
--                 -- rewrite config file (e.g. .htaccess or web.config).
--                 --
--                 wp_rewrite->flush_rules( true );

--                 test_url = "";

--                 -- Test against a real WordPress post.
--                 first_post = get_page_by_path( sanitize_title( _x( "hello-world", "Default post slug" ) ), OBJECT, "post" );
--                 if ( first_post ) then
--                         test_url = get_permalink( first_post->ID );
--                 end;

--                 /*
--                 -- Send a request to the site, and check whether
--                 -- the "x-pingback" header is returned as expected.
--                 --
--                 -- Uses wp_remote_get() instead of wp_remote_head() because web servers
--                 -- can block head requests.
--                 --
--                 response          = wp_remote_get( test_url, array( "timeout" => 5 ) );
--                 x_pingback_header = wp_remote_retrieve_header( response, "x-pingback" );
--                 pretty_permalinks = x_pingback_header && get_bloginfo( "pingback_url" ) === x_pingback_header;

--                 if ( pretty_permalinks ) then
--                         return true;
--                 end;
--         end;

--         /*
--         -- If it makes it this far, pretty permalinks failed.
--         -- Fallback to query-string permalinks.
--         --
--         wp_rewrite->set_permalink_structure( "" );
--         wp_rewrite->flush_rules( true );

--         return false;
-- end;

-- if ( ! function_exists( "wp_new_blog_notification" ) ) :
   --
   -- Notifies the site admin that the installation of WordPress is complete.
   --
   -- Sends an email to the new administrator that the installation is complete
   -- and provides them with a record of their login credentials.
   --
   -- @since 2.1.0
   --
   -- @param string blog_title Site title.
   -- @param string blog_url   Site URL.
   -- @param int    user_id    Administrator's user ID.
   -- @param string password   Administrator's password. Note that a placeholder
   --                           message is usually passed instead of the actual
   --                           password.
   --
   procedure Wp_New_Blog_Notification (Blog_Title : String;
                                       Blog_URL   : String;
                                       User_Id    : Integer;
                                       Password   : String)
   is null;
--                 user      = new WP_User( user_id );
--                 email     = user->user_email;
--                 name      = user->user_login;
--                 login_url = wp_login_url();

--                 message = sprintf(
--                         /* translators: New site notification email. 1: New site URL, 2: User login, 3: User password or password reset link, 4: Login URL.--
--                         __(
--                                 "Your new WordPress site has been successfully set up at:

-- %1s

-- You can log in to the administrator account with the following information:

-- Username: %2s
-- Password: %3s
-- Log in here: %4s

-- We hope you enjoy your new site. Thanks!

-- --The WordPress Team
-- https://wordpress.org/
-- "
--                         ),
--                         blog_url,
--                         name,
--                         password,
--                         login_url
--                 );

--                 installed_email = array(
--                         "to"      => email,
--                         "subject" => __( "New WordPress Site" ),
--                         "message" => message,
--                         "headers" => "",
--                 );

--                 --
--                 -- Filters the contents of the email sent to the site administrator when WordPress is installed.
--                 --
--                 -- @since 5.6.0
--                 --
--                 -- @param array installed_email then
--                 --     Used to build wp_mail().
--                 --
--                 --     @type string to      The email address of the recipient.
--                 --     @type string subject The subject of the email.
--                 --     @type string message The content of the email.
--                 --     @type string headers Headers.
--                 -- end;
--                 -- @param WP_User user          The site administrator user object.
--                 -- @param string  blog_title    The site title.
--                 -- @param string  blog_url      The site URL.
--                 -- @param string  password      The site administrator"s password. Note that a placeholder message
--                 --                               is usually passed instead of the user"s actual password.
--                 --
--                 installed_email = apply_filters( "wp_installed_email", installed_email, user, blog_title, blog_url, password );

--                 wp_mail(
--                         installed_email["to"],
--                         installed_email["subject"],
--                         installed_email["message"],
--                         installed_email["headers"]
--                 );
--         end;
-- endif;

-- if ( ! function_exists( "wp_upgrade" ) ) :

   --
   -- Runs WordPress Upgrade functions.
   --
   -- Upgrades the database if needed during a site update.
   --
   -- @since 2.1.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global int  wp_db_version         The new database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Wp_Upgrade;

-- endif;

   --
   -- Functions to be called in installation and upgrade scripts.
   --
   -- Contains conditional checks to determine which upgrade scripts to run,
   -- based on database version and WP version being updated-to.
   --
   -- @ignore
   -- @since 1.0.1
   --
   -- @global int wp_current_db_version The old (current) database version.
   -- @global int wp_db_version         The new database version.
   --
   procedure Upgrade_All;

   --
   -- Execute changes made in WordPress 1.0.
   --
   -- @ignore
   -- @since 1.0.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_100;

   --
   -- Execute changes made in WordPress 1.0.1.
   --
   -- @ignore
   -- @since 1.0.1
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_101;

   --
   -- Execute changes made in WordPress 1.2.
   --
   -- @ignore
   -- @since 1.2.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_110;

   --
   -- Execute changes made in WordPress 1.5.
   --
   -- @ignore
   -- @since 1.5.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_130;

   --
   -- Execute changes made in WordPress 2.0.
   --
   -- @ignore
   -- @since 2.0.0
   --
   -- @global wpdb wpdb                  WordPress database abstraction object.
   -- @global int  wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_160;

   --
   -- Execute changes made in WordPress 2.1.
   --
   -- @ignore
   -- @since 2.1.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_210;

   --
   -- Execute changes made in WordPress 2.3.
   --
   -- @ignore
   -- @since 2.3.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_230;

   --
   -- Remove old options from the database.
   --
   -- @ignore
   -- @since 2.3.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_230_Options_Table;

   --
   -- Remove old categories, link2cat, and post2cat database tables.
   --
   -- @ignore
   -- @since 2.3.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_230_Old_Tables;

   --
   -- Upgrade old slugs made in version 2.2.
   --
   -- @ignore
   -- @since 2.2.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_Old_Slugs;

   --
   -- Execute changes made in WordPress 2.5.0.
   --
   -- @ignore
   -- @since 2.5.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_250;

   --
   -- Execute changes made in WordPress 2.5.2.
   --
   -- @ignore
   -- @since 2.5.2
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_252;

   --
   -- Execute changes made in WordPress 2.6.
   --
   -- @ignore
   -- @since 2.6.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_260;

   --
   -- Execute changes made in WordPress 2.7.
   --
   -- @ignore
   -- @since 2.7.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_270;

   --
   -- Execute changes made in WordPress 2.8.
   --
   -- @ignore
   -- @since 2.8.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_280;

   --
   -- Execute changes made in WordPress 2.9.
   --
   -- @ignore
   -- @since 2.9.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_290;

   --
   -- Execute changes made in WordPress 3.0.
   --
   -- @ignore
   -- @since 3.0.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_300;

   --
   -- Execute changes made in WordPress 3.3.
   --
   -- @ignore
   -- @since 3.3.0
   --
   -- @global int   wp_current_db_version The old (current) database version.
   -- @global wpdb  wpdb                  WordPress database abstraction object.
   -- @global array wp_registered_widgets
   -- @global array sidebars_widgets
   --
   procedure Upgrade_330;

   --
   -- Execute changes made in WordPress 3.4.
   --
   -- @ignore
   -- @since 3.4.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_340;

   --
   -- Execute changes made in WordPress 3.5.
   --
   -- @ignore
   -- @since 3.5.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_350;

   --
   -- Execute changes made in WordPress 3.7.
   --
   -- @ignore
   -- @since 3.7.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_370;

   --
   -- Execute changes made in WordPress 3.7.2.
   --
   -- @ignore
   -- @since 3.7.2
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_372;

   --
   -- Execute changes made in WordPress 3.8.0.
   --
   -- @ignore
   -- @since 3.8.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_380;

   --
   -- Execute changes made in WordPress 4.0.0.
   --
   -- @ignore
   -- @since 4.0.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_400;

   --
   -- Execute changes made in WordPress 4.2.0.
   --
   -- @ignore
   -- @since 4.2.0
   --
   procedure Upgrade_420;

   --
   -- Executes changes made in WordPress 4.3.0.
   --
   -- @ignore
   -- @since 4.3.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_430;

   --
   -- Executes comments changes made in WordPress 4.3.0.
   --
   -- @ignore
   -- @since 4.3.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Upgrade_430_Fix_Comments;

   --
   -- Executes changes made in WordPress 4.3.1.
   --
   -- @ignore
   -- @since 4.3.1
   --
   procedure Upgrade_431;

   --
   -- Executes changes made in WordPress 4.4.0.
   --
   -- @ignore
   -- @since 4.4.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_440;

   --
   -- Executes changes made in WordPress 4.5.0.
   --
   -- @ignore
   -- @since 4.5.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_450;

   --
   -- Executes changes made in WordPress 4.6.0.
   --
   -- @ignore
   -- @since 4.6.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_460;

   --
   -- Executes changes made in WordPress 5.0.0.
   --
   -- @ignore
   -- @since 5.0.0
   -- @deprecated 5.1.0
   --
   procedure Upgrade_500;

   --
   -- Executes changes made in WordPress 5.1.0.
   --
   -- @ignore
   -- @since 5.1.0
   --
   procedure Upgrade_510;

   --
   -- Executes changes made in WordPress 5.3.0.
   --
   -- @ignore
   -- @since 5.3.0
   --
   procedure Upgrade_530;

   --
   -- Executes changes made in WordPress 5.5.0.
   --
   -- @ignore
   -- @since 5.5.0
   --
   procedure Upgrade_550;

   --
   -- Executes changes made in WordPress 5.6.0.
   --
   -- @ignore
   -- @since 5.6.0
   --
   procedure Upgrade_560;

   --
   -- Executes changes made in WordPress 5.9.0.
   --
   -- @ignore
   -- @since 5.9.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_590;

   --
   -- Executes changes made in WordPress 6.0.0.
   --
   -- @ignore
   -- @since 6.0.0
   --
   -- @global int wp_current_db_version The old (current) database version.
   --
   procedure Upgrade_600;

   --
   -- Executes network-level upgrade routines.
   --
   -- @since 3.0.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Upgrade_Network
   is null;
--         global wp_current_db_version, wpdb;

--         -- Always clear expired transients.
--         delete_expired_transients( true );

--         -- 2.8.0
--         if ( wp_current_db_version < 11549 ) then
--                 wpmu_sitewide_plugins   = get_site_option( "wpmu_sitewide_plugins" );
--                 active_sitewide_plugins = get_site_option( "active_sitewide_plugins" );
--                 if ( wpmu_sitewide_plugins ) then
--                         if ( ! active_sitewide_plugins ) then
--                                 sitewide_plugins = (array) wpmu_sitewide_plugins;
--                         end; else then
--                                 sitewide_plugins = array_merge( (array) active_sitewide_plugins, (array) wpmu_sitewide_plugins );
--                         end;

--                         update_site_option( "active_sitewide_plugins", sitewide_plugins );
--                 end;
--                 delete_site_option( "wpmu_sitewide_plugins" );
--                 delete_site_option( "deactivated_sitewide_plugins" );

--                 start = 0;
--                 while ( rows = wpdb->get_results( "SELECT meta_key, meta_value FROM thenwpdb->sitemetaend; ORDER BY meta_id LIMIT start, 20" ) ) then
--                         foreach ( rows as row ) then
--                                 value = row->meta_value;
--                                 if ( ! @unserialize( value ) ) then
--                                         value = stripslashes( value );
--                                 end;
--                                 if ( value !== row->meta_value ) then
--                                         update_site_option( row->meta_key, value );
--                                 end;
--                         end;
--                         start += 20;
--                 end;
--         end;

--         -- 3.0.0
--         if ( wp_current_db_version < 13576 ) then
--                 update_site_option( "global_terms_enabled", "1" );
--         end;

--         -- 3.3.0
--         if ( wp_current_db_version < 19390 ) then
--                 update_site_option( "initial_db_version", wp_current_db_version );
--         end;

--         if ( wp_current_db_version < 19470 ) then
--                 if ( false === get_site_option( "active_sitewide_plugins" ) ) then
--                         update_site_option( "active_sitewide_plugins", array() );
--                 end;
--         end;

--         -- 3.4.0
--         if ( wp_current_db_version < 20148 ) then
--                 -- "allowedthemes" keys things by stylesheet. "allowed_themes" keyed things by name.
--                 allowedthemes  = get_site_option( "allowedthemes" );
--                 allowed_themes = get_site_option( "allowed_themes" );
--                 if ( false === allowedthemes && is_array( allowed_themes ) && allowed_themes ) then
--                         converted = array();
--                         themes    = wp_get_themes();
--                         foreach ( themes as stylesheet => theme_data ) then
--                                 if ( isset( allowed_themes[ theme_data->get( "Name" ) ] ) ) then
--                                         converted[ stylesheet ] = true;
--                                 end;
--                         end;
--                         update_site_option( "allowedthemes", converted );
--                         delete_site_option( "allowed_themes" );
--                 end;
--         end;

--         -- 3.5.0
--         if ( wp_current_db_version < 21823 ) then
--                 update_site_option( "ms_files_rewriting", "1" );
--         end;

--         -- 3.5.2
--         if ( wp_current_db_version < 24448 ) then
--                 illegal_names = get_site_option( "illegal_names" );
--                 if ( is_array( illegal_names ) && count( illegal_names ) === 1 ) then
--                         illegal_name  = reset( illegal_names );
--                         illegal_names = explode( " ", illegal_name );
--                         update_site_option( "illegal_names", illegal_names );
--                 end;
--         end;

--         -- 4.2.0
--         if ( wp_current_db_version < 31351 && "utf8mb4" === wpdb->charset ) then
--                 if ( wp_should_upgrade_global_tables() ) then
--                         wpdb->query( "ALTER TABLE wpdb->usermeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))" );
--                         wpdb->query( "ALTER TABLE wpdb->site DROP INDEX domain, ADD INDEX domain(domain(140),path(51))" );
--                         wpdb->query( "ALTER TABLE wpdb->sitemeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))" );
--                         wpdb->query( "ALTER TABLE wpdb->signups DROP INDEX domain_path, ADD INDEX domain_path(domain(140),path(51))" );

--                         tables = wpdb->tables( "global" );

--                         -- sitecategories may not exist.
--                         if ( ! wpdb->get_var( "SHOW TABLES LIKE "thentables["sitecategories"]end;"" ) ) then
--                                 unset( tables["sitecategories"] );
--                         end;

--                         foreach ( tables as table ) then
--                                 maybe_convert_table_to_utf8mb4( table );
--                         end;
--                 end;
--         end;

--         -- 4.3.0
--         if ( wp_current_db_version < 33055 && "utf8mb4" === wpdb->charset ) then
--                 if ( wp_should_upgrade_global_tables() ) then
--                         upgrade = false;
--                         indexes = wpdb->get_results( "SHOW INDEXES FROM wpdb->signups" );
--                         foreach ( indexes as index ) then
--                                 if ( "domain_path" === index->Key_name && "domain" === index->Column_name && 140 != index->Sub_part ) then
--                                         upgrade = true;
--                                         break;
--                                 end;
--                         end;

--                         if ( upgrade ) then
--                                 wpdb->query( "ALTER TABLE wpdb->signups DROP INDEX domain_path, ADD INDEX domain_path(domain(140),path(51))" );
--                         end;

--                         tables = wpdb->tables( "global" );

--                         -- sitecategories may not exist.
--                         if ( ! wpdb->get_var( "SHOW TABLES LIKE "thentables["sitecategories"]end;"" ) ) then
--                                 unset( tables["sitecategories"] );
--                         end;

--                         foreach ( tables as table ) then
--                                 maybe_convert_table_to_utf8mb4( table );
--                         end;
--                 end;
--         end;

--         -- 5.1.0
--         if ( wp_current_db_version < 44467 ) then
--                 network_id = get_main_network_id();
--                 delete_network_option( network_id, "site_meta_supported" );
--                 is_site_meta_supported();
--         end;
-- end;

-- //
-- -- General functions we use to actually do stuff.
-- //

-- --
-- -- Creates a table in the database, if it doesn"t already exist.
-- --
-- -- This method checks for an existing database and creates a new one if it"s not
-- -- already present. It doesn"t rely on MySQL"s "IF NOT EXISTS" statement, but chooses
-- -- to query all tables first and then run the SQL statement creating the table.
-- --
-- -- @since 1.0.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string table_name Database table name.
-- -- @param string create_ddl SQL statement to create table.
-- -- @return bool True on success or if the table already exists. False on failure.
-- --
-- function maybe_create_table( table_name, create_ddl ) then
--         global wpdb;

--         query = wpdb->prepare( "SHOW TABLES LIKE %s", wpdb->esc_like( table_name ) );

--         if ( wpdb->get_var( query ) === table_name ) then
--                 return true;
--         end;

--         -- Didn"t find it, so try to create it.
--         wpdb->query( create_ddl );

--         -- We cannot directly tell that whether this succeeded!
--         if ( wpdb->get_var( query ) === table_name ) then
--                 return true;
--         end;

--         return false;
-- end;

   --
   -- Drops a specified index from a table.
   --
   -- @since 1.0.1
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string table Database table name.
   -- @param string index Index name to drop.
   -- @return true True, when finished.
   --
   procedure Drop_Index (Table : String;
                         Index : String);

   --
   -- Adds an index to a specified table.
   --
   -- @since 1.0.1
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string table Database table name.
   -- @param string index Database table index column.
   -- @return true True, when done with execution.
   --
   procedure Add_Clean_Index (Table : String;
                              Index : String);
--         global wpdb;

--         drop_index( table, index );
--         wpdb->query( "ALTER TABLE `table` ADD INDEX ( `index` )" );

--         return true;
-- end;

-- --
-- -- Adds column to a database table, if it doesn"t already exist.
-- --
-- -- @since 1.3.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param string table_name  Database table name.
-- -- @param string column_name Table column name.
-- -- @param string create_ddl  SQL statement to add column.
-- -- @return bool True on success or if the column already exists. False on failure.
-- --
-- function maybe_add_column( table_name, column_name, create_ddl ) then
--         global wpdb;

--         foreach ( wpdb->get_col( "DESC table_name", 0 ) as column ) then
--                 if ( column === column_name ) then
--                         return true;
--                 end;
--         end;

--         -- Didn"t find it, so try to create it.
--         wpdb->query( create_ddl );

--         -- We cannot directly tell that whether this succeeded!
--         foreach ( wpdb->get_col( "DESC table_name", 0 ) as column ) then
--                 if ( column === column_name ) then
--                         return true;
--                 end;
--         end;

--         return false;
-- end;

   --
   -- If a table only contains utf8 or utf8mb4 columns, convert it to utf8mb4.
   --
   -- @since 4.2.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string table The table to convert.
   -- @return bool True if the table was converted, false if it wasn't.
   --
   procedure Maybe_Convert_Table_To_Utf8mb4 (Table : String)
   is null;
--         global wpdb;

--         results = wpdb->get_results( "SHOW FULL COLUMNS FROM `table`" );
--         if ( ! results ) then
--                 return false;
--         end;

--         foreach ( results as column ) then
--                 if ( column->Collation ) then
--                         list( charset ) = explode( "_", column->Collation );
--                         charset         = strtolower( charset );
--                         if ( "utf8" !== charset && "utf8mb4" !== charset ) then
--                                 -- Don"t upgrade tables that have non-utf8 columns.
--                                 return false;
--                         end;
--                 end;
--         end;

--         table_details = wpdb->get_row( "SHOW TABLE STATUS LIKE "table"" );
--         if ( ! table_details ) then
--                 return false;
--         end;

--         list( table_charset ) = explode( "_", table_details->Collation );
--         table_charset         = strtolower( table_charset );
--         if ( "utf8mb4" === table_charset ) then
--                 return true;
--         end;

--         return wpdb->query( "ALTER TABLE table CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci" );
-- end;

-- --
-- -- Retrieve all options as it was for 1.2.
-- --
-- -- @since 1.2.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @return stdClass List of options.
-- --
-- function get_alloptions_110() then
--         global wpdb;
--         all_options = new stdClass;
--         options     = wpdb->get_results( "SELECT option_name, option_value FROM wpdb->options" );
--         if ( options ) then
--                 foreach ( options as option ) then
--                         if ( "siteurl" === option->option_name || "home" === option->option_name || "category_base" === option->option_name ) then
--                                 option->option_value = untrailingslashit( option->option_value );
--                         end;
--                         all_options->thenoption->option_nameend; = stripslashes( option->option_value );
--                 end;
--         end;
--         return all_options;
-- end;

   --
   -- Utility version of get_option that is private to installation/upgrade.
   --
   -- @ignore
   -- @since 1.5.1
   -- @access private
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string setting Option name.
   -- @return mixed
   --
   function X_Get_Option (Setting : String)
                          return Arrays.Multi_Type;

-- --
-- -- Filters for content to remove unnecessary slashes.
-- --
-- -- @since 1.5.0
-- --
-- -- @param string content The content to modify.
-- -- @return string The de-slashed content.
-- --
-- function deslash( content ) then
--         -- Note: \\\ inside a regex denotes a single backslash.

--         /*
--         -- Replace one or more backslashes followed by a single quote with
--         -- a single quote.
--         --
--         content = preg_replace( "/\\\+"/", """, content );

--         /*
--         -- Replace one or more backslashes followed by a double quote with
--         -- a double quote.
--         --
--         content = preg_replace( "/\\\+"/", """, content );

--         -- Replace one or more backslashes with one backslash.
--         content = preg_replace( "/\\\+/", "\\", content );

--         return content;
-- end;

   --
   -- Modifies the database based on specified SQL statements.
   --
   -- Useful for creating new tables and updating existing tables to a new structure.
   --
   -- @since 1.5.0
   -- @since 6.1.0 Ignores display width for integer data types on MySQL 8.0.17 or
   --              later, to match MySQL behavior. Note: This does not affect MariaDB.
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string[]|string queries Optional. The query to run. Can be multiple
   --                                 queries in an array, or a string of queries
   --                                 separated by semicolons. Default empty string.
   -- @param bool            execute Optional. Whether or not to execute the query
   --                                 right away. Default true.
   -- @return array Strings containing the results of the various update queries.
   --
   function DB_Delta (Queries : String  := "";
                      Execute : Boolean := True)
                      return Array_Type;

-- --
-- -- Updates the database tables to a new schema.
-- --
-- -- By default, updates all the tables to use the latest defined schema, but can also
-- -- be used to update a specific set of tables in wp_get_db_schema().
-- --
-- -- @since 1.5.0
-- --
-- -- @uses dbDelta
-- --
-- -- @param string tables Optional. Which set of tables to update. Default is "all".
-- --
-- function make_db_current( tables = "all" ) then
--         alterations = dbDelta( tables );
--         echo "<ol>\n";
--         foreach ( alterations as alteration ) then
--                 echo "<li>alteration</li>\n";
--         end;
--         echo "</ol>\n";
-- end;

   --
   -- Updates the database tables to a new schema, but without displaying results.
   --
   -- By default, updates all the tables to use the latest defined schema, but can
   -- also be used to update a specific set of tables in wp_get_db_schema().
   --
   -- @since 1.5.0
   --
   -- @see make_db_current()
   --
   -- @param string tables Optional. Which set of tables to update. Default is "all".
   --
   procedure Make_DB_Current_Silent (Tables : String := "all");

-- --
-- -- Creates a site theme from an existing theme.
-- --
-- -- then@internal Missing Long Descriptionend;end;
-- --
-- -- @since 1.5.0
-- --
-- -- @param string theme_name The name of the theme.
-- -- @param string template   The directory name of the theme.
-- -- @return bool
-- --
-- function make_site_theme_from_oldschool( theme_name, template ) then
--         home_path = get_home_path();
--         site_dir  = WP_CONTENT_DIR . "/themes/template";

--         if ( ! file_exists( "home_path/index.php" ) ) then
--                 return false;
--         end;

--         /*
--         -- Copy files from the old locations to the site theme.
--         -- TODO: This does not copy arbitrary include dependencies. Only the standard WP files are copied.
--         --
--         files = array(
--                 "index.php"             => "index.php",
--                 "wp-layout.css"         => "style.css",
--                 "wp-comments.php"       => "comments.php",
--                 "wp-comments-popup.php" => "comments-popup.php",
--         );

--         foreach ( files as oldfile => newfile ) then
--                 if ( "index.php" === oldfile ) then
--                         oldpath = home_path;
--                 end; else then
--                         oldpath = ABSPATH;
--                 end;

--                 -- Check to make sure it"s not a new index.
--                 if ( "index.php" === oldfile ) then
--                         index = implode( "", file( "oldpath/oldfile" ) );
--                         if ( strpos( index, "WP_USE_THEMES" ) !== false ) then
--                                 if ( ! copy( WP_CONTENT_DIR . "/themes/" . WP_DEFAULT_THEME . "/index.php", "site_dir/newfile" ) ) then
--                                         return false;
--                                 end;

--                                 -- Don"t copy anything.
--                                 continue;
--                         end;
--                 end;

--                 if ( ! copy( "oldpath/oldfile", "site_dir/newfile" ) ) then
--                         return false;
--                 end;

--                 chmod( "site_dir/newfile", 0777 );

--                 -- Update the blog header include in each file.
--                 lines = explode( "\n", implode( "", file( "site_dir/newfile" ) ) );
--                 if ( lines ) then
--                         f = fopen( "site_dir/newfile", "w" );

--                         foreach ( lines as line ) then
--                                 if ( preg_match( "/require.*wp-blog-header/", line ) ) then
--                                         line = "//" . line;
--                                 end;

--                                 -- Update stylesheet references.
--                                 line = str_replace( "<?php echo __get_option("siteurl"); ?>/wp-layout.css", "<?php bloginfo("stylesheet_url"); ?>", line );

--                                 -- Update comments template inclusion.
--                                 line = str_replace( "<?php include(ABSPATH . "wp-comments.php"); ?>", "<?php comments_template(); ?>", line );

--                                 fwrite( f, "thenlineend;\n" );
--                         end;
--                         fclose( f );
--                 end;
--         end;

--         -- Add a theme header.
--         header = "/*\nTheme Name: theme_name\nTheme URI: " . __get_option( "siteurl" ) . "\nDescription: A theme automatically created by the update.\nVersion: 1.0\nAuthor: Moi\n*/\n";

--         stylelines = file_get_contents( "site_dir/style.css" );
--         if ( stylelines ) then
--                 f = fopen( "site_dir/style.css", "w" );

--                 fwrite( f, header );
--                 fwrite( f, stylelines );
--                 fclose( f );
--         end;

--         return true;
-- end;

-- --
-- -- Creates a site theme from the default theme.
-- --
-- -- then@internal Missing Long Descriptionend;end;
-- --
-- -- @since 1.5.0
-- --
-- -- @param string theme_name The name of the theme.
-- -- @param string template   The directory name of the theme.
-- -- @return void|false
-- --
-- function make_site_theme_from_default( theme_name, template ) then
--         site_dir    = WP_CONTENT_DIR . "/themes/template";
--         default_dir = WP_CONTENT_DIR . "/themes/" . WP_DEFAULT_THEME;

--         -- Copy files from the default theme to the site theme.
--         -- files = array( "index.php", "comments.php", "comments-popup.php", "footer.php", "header.php", "sidebar.php", "style.css" );

--         theme_dir = @opendir( default_dir );
--         if ( theme_dir ) then
--                 while ( ( theme_file = readdir( theme_dir ) ) !== false ) then
--                         if ( is_dir( "default_dir/theme_file" ) ) then
--                                 continue;
--                         end;
--                         if ( ! copy( "default_dir/theme_file", "site_dir/theme_file" ) ) then
--                                 return;
--                         end;
--                         chmod( "site_dir/theme_file", 0777 );
--                 end;

--                 closedir( theme_dir );
--         end;

--         -- Rewrite the theme header.
--         stylelines = explode( "\n", implode( "", file( "site_dir/style.css" ) ) );
--         if ( stylelines ) then
--                 f = fopen( "site_dir/style.css", "w" );

--                 foreach ( stylelines as line ) then
--                         if ( strpos( line, "Theme Name:" ) !== false ) then
--                                 line = "Theme Name: " . theme_name;
--                         end; elseif ( strpos( line, "Theme URI:" ) !== false ) then
--                                 line = "Theme URI: " . __get_option( "url" );
--                         end; elseif ( strpos( line, "Description:" ) !== false ) then
--                                 line = "Description: Your theme.";
--                         end; elseif ( strpos( line, "Version:" ) !== false ) then
--                                 line = "Version: 1";
--                         end; elseif ( strpos( line, "Author:" ) !== false ) then
--                                 line = "Author: You";
--                         end;
--                         fwrite( f, line . "\n" );
--                 end;
--                 fclose( f );
--         end;

--         -- Copy the images.
--         umask( 0 );
--         if ( ! mkdir( "site_dir/images", 0777 ) ) then
--                 return false;
--         end;

--         images_dir = @opendir( "default_dir/images" );
--         if ( images_dir ) then
--                 while ( ( image = readdir( images_dir ) ) !== false ) then
--                         if ( is_dir( "default_dir/images/image" ) ) then
--                                 continue;
--                         end;
--                         if ( ! copy( "default_dir/images/image", "site_dir/images/image" ) ) then
--                                 return;
--                         end;
--                         chmod( "site_dir/images/image", 0777 );
--                 end;

--                 closedir( images_dir );
--         end;
-- end;

-- --
-- -- Creates a site theme.
-- --
-- -- then@internal Missing Long Descriptionend;end;
-- --
-- -- @since 1.5.0
-- --
-- -- @return string|false
-- --
-- function make_site_theme() then
--         -- Name the theme after the blog.
--         theme_name = __get_option( "blogname" );
--         template   = sanitize_title( theme_name );
--         site_dir   = WP_CONTENT_DIR . "/themes/template";

--         -- If the theme already exists, nothing to do.
--         if ( is_dir( site_dir ) ) then
--                 return false;
--         end;

--         -- We must be able to write to the themes dir.
--         if ( ! is_writable( WP_CONTENT_DIR . "/themes" ) ) then
--                 return false;
--         end;

--         umask( 0 );
--         if ( ! mkdir( site_dir, 0777 ) ) then
--                 return false;
--         end;

--         if ( file_exists( ABSPATH . "wp-layout.css" ) ) then
--                 if ( ! make_site_theme_from_oldschool( theme_name, template ) ) then
--                         -- TODO: rm -rf the site theme directory.
--                         return false;
--                 end;
--         end; else then
--                 if ( ! make_site_theme_from_default( theme_name, template ) ) then
--                         -- TODO: rm -rf the site theme directory.
--                         return false;
--                 end;
--         end;

--         -- Make the new site theme active.
--         current_template = __get_option( "template" );
--         if ( WP_DEFAULT_THEME == current_template ) then
--                 update_option( "template", template );
--                 update_option( "stylesheet", template );
--         end;
--         return template;
-- end;

-- --
-- -- Translate user level to user role name.
-- --
-- -- @since 2.0.0
-- --
-- -- @param int level User level.
-- -- @return string User role name.
-- --
-- function translate_level_to_role( level ) then
--         switch ( level ) then
--                 case 10:
--                 case 9:
--                 case 8:
--                         return "administrator";
--                 case 7:
--                 case 6:
--                 case 5:
--                         return "editor";
--                 case 4:
--                 case 3:
--                 case 2:
--                         return "author";
--                 case 1:
--                         return "contributor";
--                 case 0:
--                 default:
--                         return "subscriber";
--         end;
-- end;

   --
   -- Checks the version of the installed MySQL binary.
   --
   -- @since 2.1.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   procedure Wp_Check_MySQL_Version;

   --
   -- Disables the Automattic widgets plugin, which was merged into core.
   --
   -- @since 2.2.0
   --
   procedure Maybe_Disable_Automattic_Widgets;

   --
   -- Disables the Link Manager on upgrade if, at the time of upgrade, no links exist
   -- in the DB.
   --
   -- @since 3.5.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Maybe_Disable_Link_Manager;

   --
   -- Runs before the schema is upgraded.
   --
   -- @since 2.9.0
   --
   -- @global int  wp_current_db_version The old (current) database version.
   -- @global wpdb wpdb                  WordPress database abstraction object.
   --
   procedure Pre_Schema_Upgrade;

   --
   -- Determine if global tables should be upgraded.
   --
   -- This function performs a series of checks to ensure the environment allows
   -- for the safe upgrading of global WordPress database tables. It is necessary
   -- because global tables will commonly grow to millions of rows on large
   -- installations, and the ability to control their upgrade routines can be
   -- critical to the operation of large networks.
   --
   -- In a future iteration, this function may use `wp_is_large_network()` to more-
   -- intelligently prevent global table upgrades. Until then, we make sure
   -- WordPress is on the main site of the main network, to avoid running queries
   -- more than once in multi-site or multi-network environments.
   --
   -- @since 4.3.0
   --
   -- @return bool Whether to run the upgrade routines on global tables.
   --
   function Wp_Should_Upgrade_Global_Tables
            return Boolean;

end Adi_Upgrade;
