--
-- Screen API: WP_Screen class
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Ada.Text_IO; use Ada.Text_IO;

with Hb_Common;
with Php;

package body Adi_Class_Wp_Screens
is
   procedure Dummy is null;

   ---------
   -- Get --
   ---------

   function Get (Hook_Name : String := "")
                 return Wp_Screen
   is
      S : Wp_Screen;
   begin
      return S;
   end Get;
--                 if ( $hook_name instanceof WP_Screen ) then
--                         return $hook_name;
--                 end;

--                 $id              = "";
--                 $post_type       = null;
--                 $taxonomy        = null;
--                 $in_admin        = false;
--                 $action          = "";
--                 $is_block_editor = false;

--                 if ( $hook_name ) then
--                         $id = $hook_name;
--                 end; elseif ( ! empty( $GLOBALS["hook_suffix"] ) ) then
--                         $id = $GLOBALS["hook_suffix"];
--                 end;

--                 // For those pesky meta boxes.
--                 if ( $hook_name && post_type_exists( $hook_name ) ) then
--                         $post_type = $id;
--                         $id        = "post"; // Changes later. Ends up being $base.
--                 end; else then
--                         if ( ".php" === substr( $id, -4 ) ) then
--                                 $id = substr( $id, 0, -4 );
--                         end;

--                         if ( in_array( $id, array( "post-new", "link-add", "media-new", "user-new" ), true ) ) then
--                                 $id     = substr( $id, 0, -4 );
--                                 $action = "add";
--                         end;
--                 end;

--                 if ( ! $post_type && $hook_name ) then
--                         if ( "-network" === substr( $id, -8 ) ) then
--                                 $id       = substr( $id, 0, -8 );
--                                 $in_admin = "network";
--                         end; elseif ( "-user" === substr( $id, -5 ) ) then
--                                 $id       = substr( $id, 0, -5 );
--                                 $in_admin = "user";
--                         end;

--                         $id = sanitize_key( $id );
--                         if ( "edit-comments" !== $id && "edit-tags" !== $id && "edit-" === substr( $id, 0, 5 ) ) then
--                                 $maybe = substr( $id, 5 );
--                                 if ( taxonomy_exists( $maybe ) ) then
--                                         $id       = "edit-tags";
--                                         $taxonomy = $maybe;
--                                 end; elseif ( post_type_exists( $maybe ) ) then
--                                         $id        = "edit";
--                                         $post_type = $maybe;
--                                 end;
--                         end;

--                         if ( ! $in_admin ) then
--                                 $in_admin = "site";
--                         end;
--                 end; else then
--                         if ( defined( "WP_NETWORK_ADMIN" ) && WP_NETWORK_ADMIN ) then
--                                 $in_admin = "network";
--                         end; elseif ( defined( "WP_USER_ADMIN" ) && WP_USER_ADMIN ) then
--                                 $in_admin = "user";
--                         end; else then
--                                 $in_admin = "site";
--                         end;
--                 end;

--                 if ( "index" === $id ) then
--                         $id = "dashboard";
--                 end; elseif ( "front" === $id ) then
--                         $in_admin = false;
--                 end;

--                 $base = $id;

--                 // If this is the current screen, see if we can be more accurate for post types and taxonomies.
--                 if ( ! $hook_name ) then
--                         if ( isset( $_REQUEST["post_type"] ) ) then
--                                 $post_type = post_type_exists( $_REQUEST["post_type"] ) ? $_REQUEST["post_type"] : false;
--                         end;
--                         if ( isset( $_REQUEST["taxonomy"] ) ) then
--                                 $taxonomy = taxonomy_exists( $_REQUEST["taxonomy"] ) ? $_REQUEST["taxonomy"] : false;
--                         end;

--                         switch ( $base ) then
--                                 case "post":
--                                         if ( isset( $_GET["post"] ) && isset( $_POST["post_ID"] ) && (int) $_GET["post"] !== (int) $_POST["post_ID"] ) then
--                                                 wp_die( __( "A post ID mismatch has been detected." ), __( "Sorry, you are not allowed to edit this item." ), 400 );
--                                         end; elseif ( isset( $_GET["post"] ) ) then
--                                                 $post_id = (int) $_GET["post"];
--                                         end; elseif ( isset( $_POST["post_ID"] ) ) then
--                                                 $post_id = (int) $_POST["post_ID"];
--                                         end; else then
--                                                 $post_id = 0;
--                                         end;

--                                         if ( $post_id ) then
--                                                 $post = get_post( $post_id );
--                                                 if ( $post ) then
--                                                         $post_type = $post->post_type;

--                                                         -- This filter is documented in wp-admin/post.php--
--                                                         $replace_editor = apply_filters( "replace_editor", false, $post );

--                                                         if ( ! $replace_editor ) then
--                                                                 $is_block_editor = use_block_editor_for_post( $post );
--                                                         end;
--                                                 end;
--                                         end;
--                                         break;
--                                 case "edit-tags":
--                                 case "term":
--                                         if ( null === $post_type && is_object_in_taxonomy( "post", $taxonomy ? $taxonomy : "post_tag" ) ) then
--                                                 $post_type = "post";
--                                         end;
--                                         break;
--                                 case "upload":
--                                         $post_type = "attachment";
--                                         break;
--                         end;
--                 end;

--                 switch ( $base ) then
--                         case "post":
--                                 if ( null === $post_type ) then
--                                         $post_type = "post";
--                                 end;

--                                 // When creating a new post, use the default block editor support value for the post type.
--                                 if ( empty( $post_id ) ) then
--                                         $is_block_editor = use_block_editor_for_post_type( $post_type );
--                                 end;

--                                 $id = $post_type;
--                                 break;
--                         case "edit":
--                                 if ( null === $post_type ) then
--                                         $post_type = "post";
--                                 end;
--                                 $id .= "-" . $post_type;
--                                 break;
--                         case "edit-tags":
--                         case "term":
--                                 if ( null === $taxonomy ) then
--                                         $taxonomy = "post_tag";
--                                 end;
--                                 // The edit-tags ID does not contain the post type. Look for it in the request.
--                                 if ( null === $post_type ) then
--                                         $post_type = "post";
--                                         if ( isset( $_REQUEST["post_type"] ) && post_type_exists( $_REQUEST["post_type"] ) ) then
--                                                 $post_type = $_REQUEST["post_type"];
--                                         end;
--                                 end;

--                                 $id = "edit-" . $taxonomy;
--                                 break;
--                 end;

--                 if ( "network" === $in_admin ) then
--                         $id   .= "-network";
--                         $base .= "-network";
--                 end; elseif ( "user" === $in_admin ) then
--                         $id   .= "-user";
--                         $base .= "-user";
--                 end;

--                 if ( isset( self::$_registry[ $id ] ) ) then
--                         $screen = self::$_registry[ $id ];
--                         if ( get_current_screen() === $screen ) then
--                                 return $screen;
--                         end;
--                 end; else then
--                         $screen     = new self();
--                         $screen->id = $id;
--                 end;

--                 $screen->base            = $base;
--                 $screen->action          = $action;
--                 $screen->post_type       = (string) $post_type;
--                 $screen->taxonomy        = (string) $taxonomy;
--                 $screen->is_user         = ( "user" === $in_admin );
--                 $screen->is_network      = ( "network" === $in_admin );
--                 $screen->in_admin        = $in_admin;
--                 $screen->is_block_editor = $is_block_editor;

--                 self::$_registry[ $id ] = $screen;

--                 return $screen;
--         end;

--         --
--         -- Makes the screen object the current screen.
--         --
--         -- @see set_current_screen()
--         -- @since 3.3.0
--         --
--         -- @global WP_Screen $current_screen WordPress current screen object.
--         -- @global string    $typenow        The post type of the current screen.
--         -- @global string    $taxnow         The taxonomy of the current screen.
--         --
--         public function set_current_screen() then
--                 global $current_screen, $taxnow, $typenow;

--                 $current_screen = $this;
--                 $typenow        = $this->post_type;
--                 $taxnow         = $this->taxonomy;

--                 --
--                 -- Fires after the current screen has been set.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param WP_Screen $current_screen Current WP_Screen object.
--                 --
--                 do_action( "current_screen", $current_screen );
--         end;

--         --
--         -- Constructor
--         --
--         -- @since 3.3.0
--         --
--         private function __construct() thenend;

--         --
--         -- Indicates whether the screen is in a particular admin.
--         --
--         -- @since 3.5.0
--         --
--         -- @param string $admin The admin to check against (network | user | site).
--         --                      If empty any of the three admins will result in true.
--         -- @return bool True if the screen is in the indicated admin, false otherwise.
--         --
--         public function in_admin( $admin = null ) then
--                 if ( empty( $admin ) ) then
--                         return (bool) $this->in_admin;
--                 end;

--                 return ( $admin === $this->in_admin );
--         end;

--         --
--         -- Sets or returns whether the block editor is loading on the current screen.
--         --
--         -- @since 5.0.0
--         --
--         -- @param bool $set Optional. Sets whether the block editor is loading on the current screen or not.
--         -- @return bool True if the block editor is being loaded, false otherwise.
--         --
--         public function is_block_editor( $set = null ) then
--                 if ( null !== $set ) then
--                         $this->is_block_editor = (bool) $set;
--                 end;

--                 return $this->is_block_editor;
--         end;

--         --
--         -- Sets the old string-based contextual help for the screen for backward compatibility.
--         --
--         -- @since 3.3.0
--         --
--         -- @param WP_Screen $screen A screen object.
--         -- @param string    $help   Help text.
--         --
--         public static function add_old_compat_help( $screen, $help ) then
--                 self::$_old_compat_help[ $screen->id ] = $help;
--         end;

--         --
--         -- Sets the parent information for the screen.
--         --
--         -- This is called in admin-header.php after the menu parent for the screen has been determined.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string $parent_file The parent file of the screen. Typically the $parent_file global.
--         --
--         public function set_parentage( $parent_file ) then
--                 $this->parent_file         = $parent_file;
--                 list( $this->parent_base ) = explode( "?", $parent_file );
--                 $this->parent_base         = str_replace( ".php", "", $this->parent_base );
--         end;

--         --
--         -- Adds an option for the screen.
--         --
--         -- Call this in template files after admin.php is loaded and before admin-header.php is loaded
--         -- to add screen options.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string $option Option ID.
--         -- @param mixed  $args   Option-dependent arguments.
--         --
--         public function add_option( $option, $args = array() ) then
--                 $this->_options[ $option ] = $args;
--         end;

--         --
--         -- Removes an option from the screen.
--         --
--         -- @since 3.8.0
--         --
--         -- @param string $option Option ID.
--         --
--         public function remove_option( $option ) then
--                 unset( $this->_options[ $option ] );
--         end;

--         --
--         -- Removes all options from the screen.
--         --
--         -- @since 3.8.0
--         --
--         public function remove_options() then
--                 $this->_options = array();
--         end;

--         --
--         -- Gets the options registered for the screen.
--         --
--         -- @since 3.8.0
--         --
--         -- @return array Options with arguments.
--         --
--         public function get_options() then
--                 return $this->_options;
--         end;

--         --
--         -- Gets the arguments for an option for the screen.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string       $option Option name.
--         -- @param string|false $key    Optional. Specific array key for when the option is an array.
--         --                             Default false.
--         -- @return string The option value if set, null otherwise.
--         --
--         public function get_option( $option, $key = false ) then
--                 if ( ! isset( $this->_options[ $option ] ) ) then
--                         return null;
--                 end;
--                 if ( $key ) then
--                         if ( isset( $this->_options[ $option ][ $key ] ) ) then
--                                 return $this->_options[ $option ][ $key ];
--                         end;
--                         return null;
--                 end;
--                 return $this->_options[ $option ];
--         end;

--         --
--         -- Gets the help tabs registered for the screen.
--         --
--         -- @since 3.4.0
--         -- @since 4.4.0 Help tabs are ordered by their priority.
--         --
--         -- @return array Help tabs with arguments.
--         --
--         public function get_help_tabs() then
--                 $help_tabs = $this->_help_tabs;

--                 $priorities = array();
--                 foreach ( $help_tabs as $help_tab ) then
--                         if ( isset( $priorities[ $help_tab["priority"] ] ) ) then
--                                 $priorities[ $help_tab["priority"] ][] = $help_tab;
--                         end; else then
--                                 $priorities[ $help_tab["priority"] ] = array( $help_tab );
--                         end;
--                 end;

--                 ksort( $priorities );

--                 $sorted = array();
--                 foreach ( $priorities as $list ) then
--                         foreach ( $list as $tab ) then
--                                 $sorted[ $tab["id"] ] = $tab;
--                         end;
--                 end;

--                 return $sorted;
--         end;

--         --
--         -- Gets the arguments for a help tab.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string $id Help Tab ID.
--         -- @return array Help tab arguments.
--         --
--         public function get_help_tab( $id ) then
--                 if ( ! isset( $this->_help_tabs[ $id ] ) ) then
--                         return null;
--                 end;
--                 return $this->_help_tabs[ $id ];
--         end;

--         --
--         -- Adds a help tab to the contextual help for the screen.
--         --
--         -- Call this on the `load-$pagenow` hook for the relevant screen,
--         -- or fetch the `$current_screen` object, or use get_current_screen()
--         -- and then call the method from the object.
--         --
--         -- You may need to filter `$current_screen` using an if or switch statement
--         -- to prevent new help tabs from being added to ALL admin screens.
--         --
--         -- @since 3.3.0
--         -- @since 4.4.0 The `$priority` argument was added.
--         --
--         -- @param array $args then
--         --     Array of arguments used to display the help tab.
--         --
--         --     @type string   $title    Title for the tab. Default false.
--         --     @type string   $id       Tab ID. Must be HTML-safe and should be unique for this menu.
--         --                              It is NOT allowed to contain any empty spaces. Default false.
--         --     @type string   $content  Optional. Help tab content in plain text or HTML. Default empty string.
--         --     @type callable $callback Optional. A callback to generate the tab content. Default false.
--         --     @type int      $priority Optional. The priority of the tab, used for ordering. Default 10.
--         -- end;
--         --
--         public function add_help_tab( $args ) then
--                 $defaults = array(
--                         "title"    => false,
--                         "id"       => false,
--                         "content"  => "",
--                         "callback" => false,
--                         "priority" => 10,
--                 );
--                 $args     = wp_parse_args( $args, $defaults );

--                 $args["id"] = sanitize_html_class( $args["id"] );

--                 // Ensure we have an ID and title.
--                 if ( ! $args["id"] || ! $args["title"] ) then
--                         return;
--                 end;

--                 // Allows for overriding an existing tab with that ID.
--                 $this->_help_tabs[ $args["id"] ] = $args;
--         end;

--         --
--         -- Removes a help tab from the contextual help for the screen.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string $id The help tab ID.
--         --
--         public function remove_help_tab( $id ) then
--                 unset( $this->_help_tabs[ $id ] );
--         end;

--         --
--         -- Removes all help tabs from the contextual help for the screen.
--         --
--         -- @since 3.3.0
--         --
--         public function remove_help_tabs() then
--                 $this->_help_tabs = array();
--         end;

--         --
--         -- Gets the content from a contextual help sidebar.
--         --
--         -- @since 3.4.0
--         --
--         -- @return string Contents of the help sidebar.
--         --
--         public function get_help_sidebar() then
--                 return $this->_help_sidebar;
--         end;

--         --
--         -- Adds a sidebar to the contextual help for the screen.
--         --
--         -- Call this in template files after admin.php is loaded and before admin-header.php is loaded
--         -- to add a sidebar to the contextual help.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string $content Sidebar content in plain text or HTML.
--         --
--         public function set_help_sidebar( $content ) then
--                 $this->_help_sidebar = $content;
--         end;

--         --
--         -- Gets the number of layout columns the user has selected.
--         --
--         -- The layout_columns option controls the max number and default number of
--         -- columns. This method returns the number of columns within that range selected
--         -- by the user via Screen Options. If no selection has been made, the default
--         -- provisioned in layout_columns is returned. If the screen does not support
--         -- selecting the number of layout columns, 0 is returned.
--         --
--         -- @since 3.4.0
--         --
--         -- @return int Number of columns to display.
--         --
--         public function get_columns() then
--                 return $this->columns;
--         end;

--         --
--         -- Gets the accessible hidden headings and text used in the screen.
--         --
--         -- @since 4.4.0
--         --
--         -- @see set_screen_reader_content() For more information on the array format.
--         --
--         -- @return array An associative array of screen reader text strings.
--         --
--         public function get_screen_reader_content() then
--                 return $this->_screen_reader_content;
--         end;

--         --
--         -- Gets a screen reader text string.
--         --
--         -- @since 4.4.0
--         --
--         -- @param string $key Screen reader text array named key.
--         -- @return string Screen reader text string.
--         --
--         public function get_screen_reader_text( $key ) then
--                 if ( ! isset( $this->_screen_reader_content[ $key ] ) ) then
--                         return null;
--                 end;
--                 return $this->_screen_reader_content[ $key ];
--         end;

--         --
--         -- Adds accessible hidden headings and text for the screen.
--         --
--         -- @since 4.4.0
--         --
--         -- @param array $content then
--         --     An associative array of screen reader text strings.
--         --
--         --     @type string $heading_views      Screen reader text for the filter links heading.
--         --                                      Default "Filter items list".
--         --     @type string $heading_pagination Screen reader text for the pagination heading.
--         --                                      Default "Items list navigation".
--         --     @type string $heading_list       Screen reader text for the items list heading.
--         --                                      Default "Items list".
--         -- end;
--         --
--         public function set_screen_reader_content( $content = array() ) then
--                 $defaults = array(
--                         "heading_views"      => __( "Filter items list" ),
--                         "heading_pagination" => __( "Items list navigation" ),
--                         "heading_list"       => __( "Items list" ),
--                 );
--                 $content  = wp_parse_args( $content, $defaults );

--                 $this->_screen_reader_content = $content;
--         end;

--         --
--         -- Removes all the accessible hidden headings and text for the screen.
--         --
--         -- @since 4.4.0
--         --
--         public function remove_screen_reader_content() then
--                 $this->_screen_reader_content = array();
--         end;

--         --
--         -- Renders the screen"s help section.
--         --
--         -- This will trigger the deprecated filters for backward compatibility.
--         --
--         -- @since 3.3.0
--         --
--         -- @global string $screen_layout_columns
--         --
--         public function render_screen_meta() then

--                 --
--                 -- Filters the legacy contextual help list.
--                 --
--                 -- @since 2.7.0
--                 -- @deprecated 3.3.0 Use {@see get_current_screen()->add_help_tab()} or
--                 --                   {@see get_current_screen()->remove_help_tab()} instead.
--                 --
--                 -- @param array     $old_compat_help Old contextual help.
--                 -- @param WP_Screen $screen          Current WP_Screen instance.
--                 --
--                 self::$_old_compat_help = apply_filters_deprecated(
--                         "contextual_help_list",
--                         array( self::$_old_compat_help, $this ),
--                         "3.3.0",
--                         "get_current_screen()->add_help_tab(), get_current_screen()->remove_help_tab()"
--                 );

--                 $old_help = isset( self::$_old_compat_help[ $this->id ] ) ? self::$_old_compat_help[ $this->id ] : "";

--                 --
--                 -- Filters the legacy contextual help text.
--                 --
--                 -- @since 2.7.0
--                 -- @deprecated 3.3.0 Use {@see get_current_screen()->add_help_tab()} or
--                 --                   {@see get_current_screen()->remove_help_tab()} instead.
--                 --
--                 -- @param string    $old_help  Help text that appears on the screen.
--                 -- @param string    $screen_id Screen ID.
--                 -- @param WP_Screen $screen    Current WP_Screen instance.
--                 --
--                 $old_help = apply_filters_deprecated(
--                         "contextual_help",
--                         array( $old_help, $this->id, $this ),
--                         "3.3.0",
--                         "get_current_screen()->add_help_tab(), get_current_screen()->remove_help_tab()"
--                 );

--                 // Default help only if there is no old-style block of text and no new-style help tabs.
--                 if ( empty( $old_help ) && ! $this->get_help_tabs() ) then

--                         --
--                         -- Filters the default legacy contextual help text.
--                         --
--                         -- @since 2.8.0
--                         -- @deprecated 3.3.0 Use {@see get_current_screen()->add_help_tab()} or
--                         --                   {@see get_current_screen()->remove_help_tab()} instead.
--                         --
--                         -- @param string $old_help_default Default contextual help text.
--                         --
--                         $default_help = apply_filters_deprecated(
--                                 "default_contextual_help",
--                                 array( "" ),
--                                 "3.3.0",
--                                 "get_current_screen()->add_help_tab(), get_current_screen()->remove_help_tab()"
--                         );
--                         if ( $default_help ) then
--                                 $old_help = "<p>" . $default_help . "</p>";
--                         end;
--                 end;

--                 if ( $old_help ) then
--                         $this->add_help_tab(
--                                 array(
--                                         "id"      => "old-contextual-help",
--                                         "title"   => __( "Overview" ),
--                                         "content" => $old_help,
--                                 )
--                         );
--                 end;

--                 $help_sidebar = $this->get_help_sidebar();

--                 $help_class = "hidden";
--                 if ( ! $help_sidebar ) then
--                         $help_class .= " no-sidebar";
--                 end;

--                 // Time to render!
--                 ?>
--                 <div id="screen-meta" class="metabox-prefs">

--                         <div id="contextual-help-wrap" class="<?php echo esc_attr( $help_class ); ?>" tabindex="-1" aria-label="<?php esc_attr_e( "Contextual Help Tab" ); ?>">
--                                 <div id="contextual-help-back"></div>
--                                 <div id="contextual-help-columns">
--                                         <div class="contextual-help-tabs">
--                                                 <ul>
--                                                 <?php
--                                                 $class = " class="active"";
--                                                 foreach ( $this->get_help_tabs() as $tab ) :
--                                                         $link_id  = "tab-link-then$tab["id"]end;";
--                                                         $panel_id = "tab-panel-then$tab["id"]end;";
--                                                         ?>

--                                                         <li id="<?php echo esc_attr( $link_id ); ?>"<?php echo $class; ?>>
--                                                                 <a href="<?php echo esc_url( "#$panel_id" ); ?>" aria-controls="<?php echo esc_attr( $panel_id ); ?>">
--                                                                         <?php echo esc_html( $tab["title"] ); ?>
--                                                                 </a>
--                                                         </li>
--                                                         <?php
--                                                         $class = "";
--                                                 endforeach;
--                                                 ?>
--                                                 </ul>
--                                         </div>

--                                         <?php if ( $help_sidebar ) : ?>
--                                         <div class="contextual-help-sidebar">
--                                                 <?php echo $help_sidebar; ?>
--                                         </div>
--                                         <?php endif; ?>

--                                         <div class="contextual-help-tabs-wrap">
--                                                 <?php
--                                                 $classes = "help-tab-content active";
--                                                 foreach ( $this->get_help_tabs() as $tab ) :
--                                                         $panel_id = "tab-panel-then$tab["id"]end;";
--                                                         ?>

--                                                         <div id="<?php echo esc_attr( $panel_id ); ?>" class="<?php echo $classes; ?>">
--                                                                 <?php
--                                                                 // Print tab content.
--                                                                 echo $tab["content"];

--                                                                 // If it exists, fire tab callback.
--                                                                 if ( ! empty( $tab["callback"] ) ) then
--                                                                         call_user_func_array( $tab["callback"], array( $this, $tab ) );
--                                                                 end;
--                                                                 ?>
--                                                         </div>
--                                                         <?php
--                                                         $classes = "help-tab-content";
--                                                 endforeach;
--                                                 ?>
--                                         </div>
--                                 </div>
--                         </div>
--                 <?php
--                 // Setup layout columns.

--                 --
--                 -- Filters the array of screen layout columns.
--                 --
--                 -- This hook provides back-compat for plugins using the back-compat
--                 -- Filters instead of add_screen_option().
--                 --
--                 -- @since 2.8.0
--                 --
--                 -- @param array     $empty_columns Empty array.
--                 -- @param string    $screen_id     Screen ID.
--                 -- @param WP_Screen $screen        Current WP_Screen instance.
--                 --
--                 $columns = apply_filters( "screen_layout_columns", array(), $this->id, $this );

--                 if ( ! empty( $columns ) && isset( $columns[ $this->id ] ) ) then
--                         $this->add_option( "layout_columns", array( "max" => $columns[ $this->id ] ) );
--                 end;

--                 if ( $this->get_option( "layout_columns" ) ) then
--                         $this->columns = (int) get_user_option( "screen_layout_$this->id" );

--                         if ( ! $this->columns && $this->get_option( "layout_columns", "default" ) ) then
--                                 $this->columns = $this->get_option( "layout_columns", "default" );
--                         end;
--                 end;
--                 $GLOBALS["screen_layout_columns"] = $this->columns; // Set the global for back-compat.

--                 // Add screen options.
--                 if ( $this->show_screen_options() ) then
--                         $this->render_screen_options();
--                 end;
--                 ?>
--                 </div>
--                 <?php
--                 if ( ! $this->get_help_tabs() && ! $this->show_screen_options() ) then
--                         return;
--                 end;
--                 ?>
--                 <div id="screen-meta-links">
--                 <?php if ( $this->show_screen_options() ) : ?>
--                         <div id="screen-options-link-wrap" class="hide-if-no-js screen-meta-toggle">
--                         <button type="button" id="show-settings-link" class="button show-settings" aria-controls="screen-options-wrap" aria-expanded="false"><?php _e( "Screen Options" ); ?></button>
--                         </div>
--                         <?php
--                 endif;
--                 if ( $this->get_help_tabs() ) :
--                         ?>
--                         <div id="contextual-help-link-wrap" class="hide-if-no-js screen-meta-toggle">
--                         <button type="button" id="contextual-help-link" class="button show-settings" aria-controls="contextual-help-wrap" aria-expanded="false"><?php _e( "Help" ); ?></button>
--                         </div>
--                 <?php endif; ?>
--                 </div>
--                 <?php
--         end;

--         --
--         -- @global array $wp_meta_boxes
--         --
--         -- @return bool
--         --
--         public function show_screen_options() then
--                 global $wp_meta_boxes;

--                 if ( is_bool( $this->_show_screen_options ) ) then
--                         return $this->_show_screen_options;
--                 end;

--                 $columns = get_column_headers( $this );

--                 $show_screen = ! empty( $wp_meta_boxes[ $this->id ] ) || $columns || $this->get_option( "per_page" );

--                 $this->_screen_settings = "";

--                 if ( "post" === $this->base ) then
--                         $expand                 = "<fieldset class="editor-expand hidden"><legend>" . __( "Additional settings" ) . "</legend><label for="editor-expand-toggle">";
--                         $expand                .= "<input type="checkbox" id="editor-expand-toggle"" . checked( get_user_setting( "editor_expand", "on" ), "on", false ) . " />";
--                         $expand                .= __( "Enable full-height editor and distraction-free functionality." ) . "</label></fieldset>";
--                         $this->_screen_settings = $expand;
--                 end;

--                 --
--                 -- Filters the screen settings text displayed in the Screen Options tab.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string    $screen_settings Screen settings.
--                 -- @param WP_Screen $screen          WP_Screen object.
--                 --
--                 $this->_screen_settings = apply_filters( "screen_settings", $this->_screen_settings, $this );

--                 if ( $this->_screen_settings || $this->_options ) then
--                         $show_screen = true;
--                 end;

--                 --
--                 -- Filters whether to show the Screen Options tab.
--                 --
--                 -- @since 3.2.0
--                 --
--                 -- @param bool      $show_screen Whether to show Screen Options tab.
--                 --                               Default true.
--                 -- @param WP_Screen $screen      Current WP_Screen instance.
--                 --
--                 $this->_show_screen_options = apply_filters( "screen_options_show_screen", $show_screen, $this );
--                 return $this->_show_screen_options;
--         end;

--         --
--         -- Renders the screen options tab.
--         --
--         -- @since 3.3.0
--         --
--         -- @param array $options then
--         --     Options for the tab.
--         --
--         --     @type bool $wrap Whether the screen-options-wrap div will be included. Defaults to true.
--         -- end;
--         --
--         public function render_screen_options( $options = array() ) then
--                 $options = wp_parse_args(
--                         $options,
--                         array(
--                                 "wrap" => true,
--                         )
--                 );

--                 $wrapper_start = "";
--                 $wrapper_end   = "";
--                 $form_start    = "";
--                 $form_end      = "";

--                 // Output optional wrapper.
--                 if ( $options["wrap"] ) then
--                         $wrapper_start = "<div id="screen-options-wrap" class="hidden" tabindex="-1" aria-label="" . esc_attr__( "Screen Options Tab" ) . "">";
--                         $wrapper_end   = "</div>";
--                 end;

--                 // Don"t output the form and nonce for the widgets accessibility mode links.
--                 if ( "widgets" !== $this->base ) then
--                         $form_start = "\n<form id="adv-settings" method="post">\n";
--                         $form_end   = "\n" . wp_nonce_field( "screen-options-nonce", "screenoptionnonce", false, false ) . "\n</form>\n";
--                 end;

--                 echo $wrapper_start . $form_start;

--                 $this->render_meta_boxes_preferences();
--                 $this->render_list_table_columns_preferences();
--                 $this->render_screen_layout();
--                 $this->render_per_page_options();
--                 $this->render_view_mode();
--                 echo $this->_screen_settings;

--                 --
--                 -- Filters whether to show the Screen Options submit button.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param bool      $show_button Whether to show Screen Options submit button.
--                 --                               Default false.
--                 -- @param WP_Screen $screen      Current WP_Screen instance.
--                 --
--                 $show_button = apply_filters( "screen_options_show_submit", false, $this );

--                 if ( $show_button ) then
--                         submit_button( __( "Apply" ), "primary", "screen-options-apply", true );
--                 end;

--                 echo $form_end . $wrapper_end;
--         end;

--         --
--         -- Renders the meta boxes preferences.
--         --
--         -- @since 4.4.0
--         --
--         -- @global array $wp_meta_boxes
--         --
--         public function render_meta_boxes_preferences() then
--                 global $wp_meta_boxes;

--                 if ( ! isset( $wp_meta_boxes[ $this->id ] ) ) then
--                         return;
--                 end;
--                 ?>
--                 <fieldset class="metabox-prefs">
--                 <legend><?php _e( "Screen elements" ); ?></legend>
--                 <p>
--                         <?php _e( "Some screen elements can be shown or hidden by using the checkboxes." ); ?>
--                         <?php _e( "They can be expanded and collapsed by clickling on their headings, and arranged by dragging their headings or by clicking on the up and down arrows." ); ?>
--                 </p>
--                 <?php

--                 meta_box_prefs( $this );

--                 if ( "dashboard" === $this->id && has_action( "welcome_panel" ) && current_user_can( "edit_theme_options" ) ) then
--                         if ( isset( $_GET["welcome"] ) ) then
--                                 $welcome_checked = empty( $_GET["welcome"] ) ? 0 : 1;
--                                 update_user_meta( get_current_user_id(), "show_welcome_panel", $welcome_checked );
--                         end; else then
--                                 $welcome_checked = (int) get_user_meta( get_current_user_id(), "show_welcome_panel", true );
--                                 if ( 2 === $welcome_checked && wp_get_current_user()->user_email !== get_option( "admin_email" ) ) then
--                                         $welcome_checked = false;
--                                 end;
--                         end;
--                         echo "<label for="wp_welcome_panel-hide">";
--                         echo "<input type="checkbox" id="wp_welcome_panel-hide"" . checked( (bool) $welcome_checked, true, false ) . " />";
--                         echo _x( "Welcome", "Welcome panel" ) . "</label>\n";
--                 end;
--                 ?>
--                 </fieldset>
--                 <?php
--         end;

--         --
--         -- Renders the list table columns preferences.
--         --
--         -- @since 4.4.0
--         --
--         public function render_list_table_columns_preferences() then

--                 $columns = get_column_headers( $this );
--                 $hidden  = get_hidden_columns( $this );

--                 if ( ! $columns ) then
--                         return;
--                 end;

--                 $legend = ! empty( $columns["_title"] ) ? $columns["_title"] : __( "Columns" );
--                 ?>
--                 <fieldset class="metabox-prefs">
--                 <legend><?php echo $legend; ?></legend>
--                 <?php
--                 $special = array( "_title", "cb", "comment", "media", "name", "title", "username", "blogname" );

--                 foreach ( $columns as $column => $title ) then
--                         // Can"t hide these for they are special.
--                         if ( in_array( $column, $special, true ) ) then
--                                 continue;
--                         end;

--                         if ( empty( $title ) ) then
--                                 continue;
--                         end;

--                         /*
--                         -- The Comments column uses HTML in the display name with some screen
--                         -- reader text. Make sure to strip tags from the Comments column
--                         -- title and any other custom column title plugins might add.
--                         --
--                         $title = wp_strip_all_tags( $title );

--                         $id = "$column-hide";
--                         echo "<label>";
--                         echo "<input class="hide-column-tog" name="" . $id . "" type="checkbox" id="" . $id . "" value="" . $column . """ . checked( ! in_array( $column, $hidden, true ), true, false ) . " />";
--                         echo "$title</label>\n";
--                 end;
--                 ?>
--                 </fieldset>
--                 <?php
--         end;

--         --
--         -- Renders the option for number of columns on the page.
--         --
--         -- @since 3.3.0
--         --
--         public function render_screen_layout() then
--                 if ( ! $this->get_option( "layout_columns" ) ) then
--                         return;
--                 end;

--                 $screen_layout_columns = $this->get_columns();
--                 $num                   = $this->get_option( "layout_columns", "max" );

--                 ?>
--                 <fieldset class="columns-prefs">
--                 <legend class="screen-layout"><?php _e( "Layout" ); ?></legend>
--                 <?php for ( $i = 1; $i <= $num; ++$i ) : ?>
--                         <label class="columns-prefs-<?php echo $i; ?>">
--                         <input type="radio" name="screen_columns" value="<?php echo esc_attr( $i ); ?>" <?php checked( $screen_layout_columns, $i ); ?> />
--                         <?php
--                                 printf(
--                                         /* translators: %s: Number of columns on the page.--
--                                         _n( "%s column", "%s columns", $i ),
--                                         number_format_i18n( $i )
--                                 );
--                         ?>
--                         </label>
--                 <?php endfor; ?>
--                 </fieldset>
--                 <?php
--         end;

--         --
--         -- Renders the items per page option.
--         --
--         -- @since 3.3.0
--         --
--         public function render_per_page_options() then
--                 if ( null === $this->get_option( "per_page" ) ) then
--                         return;
--                 end;

--                 $per_page_label = $this->get_option( "per_page", "label" );
--                 if ( null === $per_page_label ) then
--                         $per_page_label = __( "Number of items per page:" );
--                 end;

--                 $option = $this->get_option( "per_page", "option" );
--                 if ( ! $option ) then
--                         $option = str_replace( "-", "_", "then$this->idend;_per_page" );
--                 end;

--                 $per_page = (int) get_user_option( $option );
--                 if ( empty( $per_page ) || $per_page < 1 ) then
--                         $per_page = $this->get_option( "per_page", "default" );
--                         if ( ! $per_page ) then
--                                 $per_page = 20;
--                         end;
--                 end;

--                 if ( "edit_comments_per_page" === $option ) then
--                         $comment_status = isset( $_REQUEST["comment_status"] ) ? $_REQUEST["comment_status"] : "all";

--                         -- This filter is documented in wp-admin/includes/class-wp-comments-list-table.php--
--                         $per_page = apply_filters( "comments_per_page", $per_page, $comment_status );
--                 end; elseif ( "categories_per_page" === $option ) then
--                         -- This filter is documented in wp-admin/includes/class-wp-terms-list-table.php--
--                         $per_page = apply_filters( "edit_categories_per_page", $per_page );
--                 end; else then
--                         -- This filter is documented in wp-admin/includes/class-wp-list-table.php--
--                         $per_page = apply_filters( "then$optionend;", $per_page );
--                 end;

--                 // Back compat.
--                 if ( isset( $this->post_type ) ) then
--                         -- This filter is documented in wp-admin/includes/post.php--
--                         $per_page = apply_filters( "edit_posts_per_page", $per_page, $this->post_type );
--                 end;

--                 // This needs a submit button.
--                 add_filter( "screen_options_show_submit", "__return_true" );

--                 ?>
--                 <fieldset class="screen-options">
--                 <legend><?php _e( "Pagination" ); ?></legend>
--                         <?php if ( $per_page_label ) : ?>
--                                 <label for="<?php echo esc_attr( $option ); ?>"><?php echo $per_page_label; ?></label>
--                                 <input type="number" step="1" min="1" max="999" class="screen-per-page" name="wp_screen_options[value]"
--                                         id="<?php echo esc_attr( $option ); ?>" maxlength="3"
--                                         value="<?php echo esc_attr( $per_page ); ?>" />
--                         <?php endif; ?>
--                                 <input type="hidden" name="wp_screen_options[option]" value="<?php echo esc_attr( $option ); ?>" />
--                 </fieldset>
--                 <?php
--         end;

--         --
--         -- Renders the list table view mode preferences.
--         --
--         -- @since 4.4.0
--         --
--         -- @global string $mode List table view mode.
--         --
--         public function render_view_mode() then
--                 global $mode;

--                 $screen = get_current_screen();

--                 // Currently only enabled for posts and comments lists.
--                 if ( "edit" !== $screen->base && "edit-comments" !== $screen->base ) then
--                         return;
--                 end;

--                 $view_mode_post_types = get_post_types( array( "show_ui" => true ) );

--                 --
--                 -- Filters the post types that have different view mode options.
--                 --
--                 -- @since 4.4.0
--                 --
--                 -- @param string[] $view_mode_post_types Array of post types that can change view modes.
--                 --                                       Default post types with show_ui on.
--                 --
--                 $view_mode_post_types = apply_filters( "view_mode_post_types", $view_mode_post_types );

--                 if ( "edit" === $screen->base && ! in_array( $this->post_type, $view_mode_post_types, true ) ) then
--                         return;
--                 end;

--                 if ( ! isset( $mode ) ) then
--                         $mode = get_user_setting( "posts_list_mode", "list" );
--                 end;

--                 // This needs a submit button.
--                 add_filter( "screen_options_show_submit", "__return_true" );
--                 ?>
--                 <fieldset class="metabox-prefs view-mode">
--                         <legend><?php _e( "View mode" ); ?></legend>
--                         <label for="list-view-mode">
--                                 <input id="list-view-mode" type="radio" name="mode" value="list" <?php checked( "list", $mode ); ?> />
--                                 <?php _e( "Compact view" ); ?>
--                         </label>
--                         <label for="excerpt-view-mode">
--                                 <input id="excerpt-view-mode" type="radio" name="mode" value="excerpt" <?php checked( "excerpt", $mode ); ?> />
--                                 <?php _e( "Extended view" ); ?>
--                         </label>
--                 </fieldset>
--                 <?php
--         end;

   ----------------------------------
   -- Render_Screen_Reader_Content --
   ----------------------------------

   procedure Render_Screen_Reader_Content (This : Wp_Screen;
                                           Key  : String := "";
                                           Tag  : String := "h2")
   is
      use Hb_Common;
      use Php;
   begin
      if not Isset (This.X_Screen_Reader_Content, Key) then
         return;
      end if;

      Echo ("<" & Tag & " class=""screen-reader-text"">" &
            As_String (Get (This.X_Screen_Reader_Content, Key)) &
            "</" & Tag & ">");
   end Render_Screen_Reader_Content;

end Adi_Class_Wp_Screens;
