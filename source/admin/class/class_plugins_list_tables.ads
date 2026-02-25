--
-- List Table API: WP_Plugins_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Arrays;

with Class_List_Tables;

package Class_Plugins_List_Tables
is
   use Arrays;

   --
   -- Core class used to implement displaying installed plugins in a list table.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table
   --
   type Wp_Plugins_List_Table is new Class_List_Tables.Wp_List_Table with
     record
        --
        -- Whether to show the auto-updates UI.
        --
        -- @since 5.5.0
        --
        -- @var bool True if auto-updates UI is to be shown, false otherwise.
        --
        -- protected
        Show_Autoupdates : Boolean := True;

     end record;

   --
   -- Constructor.
   --
   -- @since 3.1.0
   --
   -- @see WP_List_Table::__construct() for more information on default arguments.
   --
   -- @global string status
   -- @global int    page
   --
   -- @param array args An associative array of arguments.
   --
   overriding
   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_Plugins_List_Table;

        -- --
        -- -- @return array
        -- --
        -- protected function get_table_classes() then
        --         return array( "widefat", this._args["plural"] );
        -- end;

        -- --
        -- -- @return bool
        -- --
        -- public function ajax_user_can() then
        --         return current_user_can( "activate_plugins" );
        -- end;

        -- --
        -- -- @global string status
        -- -- @global array  plugins
        -- -- @global array  totals
        -- -- @global int    page
        -- -- @global string orderby
        -- -- @global string order
        -- -- @global string s
        -- --
        -- public function prepare_items() then
        --         global status, plugins, totals, page, orderby, order, s;

        --         wp_reset_vars( array( "orderby", "order" ) );

        --         --
        --         -- Filters the full array of plugins to list in the Plugins list table.
        --         --
        --         -- @since 3.0.0
        --         --
        --         -- @see get_plugins()
        --         --
        --         -- @param array all_plugins An array of plugins to display in the list table.
        --         --
        --         all_plugins = apply_filters( "all_plugins", get_plugins() );

        --         plugins = array(
        --                 "all"                => all_plugins,
        --                 "search"             => array(),
        --                 "active"             => array(),
        --                 "inactive"           => array(),
        --                 "recently_activated" => array(),
        --                 "upgrade"            => array(),
        --                 "mustuse"            => array(),
        --                 "dropins"            => array(),
        --                 "paused"             => array(),
        --         );
        --         if ( this.show_autoupdates ) then
        --                 auto_updates = (array) get_site_option( "auto_update_plugins", array() );

        --                 plugins["auto-update-enabled"]  = array();
        --                 plugins["auto-update-disabled"] = array();
        --         end;

        --         screen = this.screen;

        --         if ( ! is_multisite() || ( screen.in_admin( "network" ) && current_user_can( "manage_network_plugins" ) ) ) then

        --                 --
        --                 -- Filters whether to display the advanced plugins list table.
        --                 --
        --                 -- There are two types of advanced plugins - must-use and drop-ins -
        --                 -- which can be used in a single site or Multisite network.
        --                 --
        --                 -- The type parameter allows you to differentiate between the type of advanced
        --                 -- plugins to filter the display of. Contexts include "mustuse" and "dropins".
        --                 --
        --                 -- @since 3.0.0
        --                 --
        --                 -- @param bool   show Whether to show the advanced plugins for the specified
        --                 --                     plugin type. Default true.
        --                 -- @param string type The plugin type. Accepts "mustuse", "dropins".
        --                 --
        --                 if ( apply_filters( "show_advanced_plugins", true, "mustuse" ) ) then
        --                         plugins["mustuse"] = get_mu_plugins();
        --                 end;

        --                 -- This action is documented in wp-admin/includes/class-wp-plugins-list-table.php--
        --                 if ( apply_filters( "show_advanced_plugins", true, "dropins" ) ) then
        --                         plugins["dropins"] = get_dropins();
        --                 end;

        --                 if ( current_user_can( "update_plugins" ) ) then
        --                         current = get_site_transient( "update_plugins" );
        --                         foreach ( (array) plugins["all"] as plugin_file => plugin_data ) then
        --                                 if ( isset( current.response[ plugin_file ] ) ) then
        --                                         plugins["all"][ plugin_file ]["update"] = true;
        --                                         plugins["upgrade"][ plugin_file ]       = plugins["all"][ plugin_file ];
        --                                 end;
        --                         end;
        --                 end;
        --         end;

        --         if ( ! screen.in_admin( "network" ) ) then
        --                 show = current_user_can( "manage_network_plugins" );
        --                 --
        --                 -- Filters whether to display network-active plugins alongside plugins active for the current site.
        --                 --
        --                 -- This also controls the display of inactive network-only plugins (plugins with
        --                 -- "Network: true" in the plugin header).
        --                 --
        --                 -- Plugins cannot be network-activated or network-deactivated from this screen.
        --                 --
        --                 -- @since 4.4.0
        --                 --
        --                 -- @param bool show Whether to show network-active plugins. Default is whether the current
        --                 --                   user can manage network plugins (ie. a Super Admin).
        --                 --
        --                 show_network_active = apply_filters( "show_network_active_plugins", show );
        --         end;

        --         if ( screen.in_admin( "network" ) ) then
        --                 recently_activated = get_site_option( "recently_activated", array() );
        --         end; else then
        --                 recently_activated = get_option( "recently_activated", array() );
        --         end;

        --         foreach ( recently_activated as key => time ) then
        --                 if ( time + WEEK_IN_SECONDS < time() ) then
        --                         unset( recently_activated[ key ] );
        --                 end;
        --         end;

        --         if ( screen.in_admin( "network" ) ) then
        --                 update_site_option( "recently_activated", recently_activated );
        --         end; else then
        --                 update_option( "recently_activated", recently_activated );
        --         end;

        --         plugin_info = get_site_transient( "update_plugins" );

        --         foreach ( (array) plugins["all"] as plugin_file => plugin_data ) then
        --                 // Extra info if known. array_merge() ensures plugin_data has precedence if keys collide.
        --                 if ( isset( plugin_info.response[ plugin_file ] ) ) then
        --                         plugin_data = array_merge( (array) plugin_info.response[ plugin_file ], array( "update-supported" => true ), plugin_data );
        --                 end; elseif ( isset( plugin_info.no_update[ plugin_file ] ) ) then
        --                         plugin_data = array_merge( (array) plugin_info.no_update[ plugin_file ], array( "update-supported" => true ), plugin_data );
        --                 end; elseif ( empty( plugin_data["update-supported"] ) ) then
        --                         plugin_data["update-supported"] = false;
        --                 end;

        --                 /*
        --                 -- Create the payload that"s used for the auto_update_plugin filter.
        --                 -- This is the same data contained within plugin_info.(response|no_update) however
        --                 -- not all plugins will be contained in those keys, this avoids unexpected warnings.
        --                 --
        --                 filter_payload = array(
        --                         "id"            => plugin_file,
        --                         "slug"          => "",
        --                         "plugin"        => plugin_file,
        --                         "new_version"   => "",
        --                         "url"           => "",
        --                         "package"       => "",
        --                         "icons"         => array(),
        --                         "banners"       => array(),
        --                         "banners_rtl"   => array(),
        --                         "tested"        => "",
        --                         "requires_php"  => "",
        --                         "compatibility" => new stdClass(),
        --                 );

        --                 filter_payload = (object) wp_parse_args( plugin_data, filter_payload );

        --                 auto_update_forced = wp_is_auto_update_forced_for_item( "plugin", null, filter_payload );

        --                 if ( ! is_null( auto_update_forced ) ) then
        --                         plugin_data["auto-update-forced"] = auto_update_forced;
        --                 end;

        --                 plugins["all"][ plugin_file ] = plugin_data;
        --                 // Make sure that plugins["upgrade"] also receives the extra info since it is used on ?plugin_status=upgrade.
        --                 if ( isset( plugins["upgrade"][ plugin_file ] ) ) then
        --                         plugins["upgrade"][ plugin_file ] = plugin_data;
        --                 end;

        --                 // Filter into individual sections.
        --                 if ( is_multisite() && ! screen.in_admin( "network" ) && is_network_only_plugin( plugin_file ) && ! is_plugin_active( plugin_file ) ) then
        --                         if ( show_network_active ) then
        --                                 // On the non-network screen, show inactive network-only plugins if allowed.
        --                                 plugins["inactive"][ plugin_file ] = plugin_data;
        --                         end; else then
        --                                 // On the non-network screen, filter out network-only plugins as long as they"re not individually active.
        --                                 unset( plugins["all"][ plugin_file ] );
        --                         end;
        --                 end; elseif ( ! screen.in_admin( "network" ) && is_plugin_active_for_network( plugin_file ) ) then
        --                         if ( show_network_active ) then
        --                                 // On the non-network screen, show network-active plugins if allowed.
        --                                 plugins["active"][ plugin_file ] = plugin_data;
        --                         end; else then
        --                                 // On the non-network screen, filter out network-active plugins.
        --                                 unset( plugins["all"][ plugin_file ] );
        --                         end;
        --                 end; elseif ( ( ! screen.in_admin( "network" ) && is_plugin_active( plugin_file ) )
        --                         || ( screen.in_admin( "network" ) && is_plugin_active_for_network( plugin_file ) ) ) then
        --                         // On the non-network screen, populate the active list with plugins that are individually activated.
        --                         // On the network admin screen, populate the active list with plugins that are network-activated.
        --                         plugins["active"][ plugin_file ] = plugin_data;

        --                         if ( ! screen.in_admin( "network" ) && is_plugin_paused( plugin_file ) ) then
        --                                 plugins["paused"][ plugin_file ] = plugin_data;
        --                         end;
        --                 end; else then
        --                         if ( isset( recently_activated[ plugin_file ] ) ) then
        --                                 // Populate the recently activated list with plugins that have been recently activated.
        --                                 plugins["recently_activated"][ plugin_file ] = plugin_data;
        --                         end;
        --                         // Populate the inactive list with plugins that aren"t activated.
        --                         plugins["inactive"][ plugin_file ] = plugin_data;
        --                 end;

        --                 if ( this.show_autoupdates ) then
        --                         enabled = in_array( plugin_file, auto_updates, true ) && plugin_data["update-supported"];
        --                         if ( isset( plugin_data["auto-update-forced"] ) ) then
        --                                 enabled = (bool) plugin_data["auto-update-forced"];
        --                         end;

        --                         if ( enabled ) then
        --                                 plugins["auto-update-enabled"][ plugin_file ] = plugin_data;
        --                         end; else then
        --                                 plugins["auto-update-disabled"][ plugin_file ] = plugin_data;
        --                         end;
        --                 end;
        --         end;

        --         if ( strlen( s ) ) then
        --                 status            = "search";
        --                 plugins["search"] = array_filter( plugins["all"], array( this, "_search_callback" ) );
        --         end;

        --         totals = array();
        --         foreach ( plugins as type => list ) then
        --                 totals[ type ] = count( list );
        --         end;

        --         if ( empty( plugins[ status ] ) && ! in_array( status, array( "all", "search" ), true ) ) then
        --                 status = "all";
        --         end;

        --         this.items = array();
        --         foreach ( plugins[ status ] as plugin_file => plugin_data ) then
        --                 // Translate, don"t apply markup, sanitize HTML.
        --                 this.items[ plugin_file ] = _get_plugin_data_markup_translate( plugin_file, plugin_data, false, true );
        --         end;

        --         total_this_page = totals[ status ];

        --         js_plugins = array();
        --         foreach ( plugins as key => list ) then
        --                 js_plugins[ key ] = array_keys( list );
        --         end;

        --         wp_localize_script(
        --                 "updates",
        --                 "_wpUpdatesItemCounts",
        --                 array(
        --                         "plugins" => js_plugins,
        --                         "totals"  => wp_get_update_data(),
        --                 )
        --         );

        --         if ( ! orderby ) then
        --                 orderby = "Name";
        --         end; else then
        --                 orderby = ucfirst( orderby );
        --         end;

        --         order = strtoupper( order );

        --         uasort( this.items, array( this, "_order_callback" ) );

        --         plugins_per_page = this.get_items_per_page( str_replace( "-", "_", screen.id . "_per_page" ), 999 );

        --         start = ( page - 1 )-- plugins_per_page;

        --         if ( total_this_page > plugins_per_page ) then
        --                 this.items = array_slice( this.items, start, plugins_per_page );
        --         end;

        --         this.set_pagination_args(
        --                 array(
        --                         "total_items" => total_this_page,
        --                         "per_page"    => plugins_per_page,
        --                 )
        --         );
        -- end;

        -- --
        -- -- @global string s URL encoded search term.
        -- --
        -- -- @param array plugin
        -- -- @return bool
        -- --
        -- public function _search_callback( plugin ) then
        --         global s;

        --         foreach ( plugin as value ) then
        --                 if ( is_string( value ) && false !== stripos( strip_tags( value ), urldecode( s ) ) ) then
        --                         return true;
        --                 end;
        --         end;

        --         return false;
        -- end;

        -- --
        -- -- @global string orderby
        -- -- @global string order
        -- -- @param array plugin_a
        -- -- @param array plugin_b
        -- -- @return int
        -- --
        -- public function _order_callback( plugin_a, plugin_b ) then
        --         global orderby, order;

        --         a = plugin_a[ orderby ];
        --         b = plugin_b[ orderby ];

        --         if ( a === b ) then
        --                 return 0;
        --         end;

        --         if ( "DESC" === order ) then
        --                 return strcasecmp( b, a );
        --         end; else then
        --                 return strcasecmp( a, b );
        --         end;
        -- end;

        -- --
        -- -- @global array plugins
        -- --
        -- public function no_items() then
        --         global plugins;

        --         if ( ! empty( _REQUEST["s"] ) ) then
        --                 s = esc_html( wp_unslash( _REQUEST["s"] ) );

        --                 /* translators: %s: Plugin search term.--
        --                 printf( __( "No plugins found for: %s." ), "<strong>" . s . "</strong>" );

        --                 // We assume that somebody who can install plugins in multisite is experienced enough to not need this helper link.
        --                 if ( ! is_multisite() && current_user_can( "install_plugins" ) ) then
        --                         echo " <a href="" . esc_url( admin_url( "plugin-install.php?tab=search&s=" . urlencode( s ) ) ) . "">" . __( "Search for plugins in the WordPress Plugin Directory." ) . "</a>";
        --                 end;
        --         end; elseif ( ! empty( plugins["all"] ) ) then
        --                 _e( "No plugins found." );
        --         end; else then
        --                 _e( "No plugins are currently available." );
        --         end;
        -- end;

        -- --
        -- -- Displays the search box.
        -- --
        -- -- @since 4.6.0
        -- --
        -- -- @param string text     The "submit" button label.
        -- -- @param string input_id ID attribute value for the search input field.
        -- --
        -- public function search_box( text, input_id ) then
        --         if ( empty( _REQUEST["s"] ) && ! this.has_items() ) then
        --                 return;
        --         end;

        --         input_id = input_id . "-search-input";

        --         if ( ! empty( _REQUEST["orderby"] ) ) then
        --                 echo "<input type="hidden" name="orderby" value="" . esc_attr( _REQUEST["orderby"] ) . "" />";
        --         end;
        --         if ( ! empty( _REQUEST["order"] ) ) then
        --                 echo "<input type="hidden" name="order" value="" . esc_attr( _REQUEST["order"] ) . "" />";
        --         end;
        --         ?>
        --         <p class="search-box">
        --                 <label class="screen-reader-text" for="<?php echo esc_attr( input_id ); ?>"><?php echo text; ?>:</label>
        --                 <input type="search" id="<?php echo esc_attr( input_id ); ?>" class="wp-filter-search" name="s" value="<?php _admin_search_query(); ?>" placeholder="<?php esc_attr_e( "Search installed plugins..." ); ?>" />
        --                 <?php submit_button( text, "hide-if-js", "", false, array( "id" => "search-submit" ) ); ?>
        --         </p>
        --         <?php
        -- end;

   --
   -- @global string status
   -- @return array
   --
   overriding
   function Get_Columns (This : Wp_Plugins_List_Table)
                         return Array_Type;
        --         global status;

        --         columns = array(
        --                 "cb"          => ! in_array( status, array( "mustuse", "dropins" ), true ) ? "<input type="checkbox" />" : "",
        --                 "name"        => __( "Plugin" ),
        --                 "description" => __( "Description" ),
        --         );

        --         if ( this.show_autoupdates ) then
        --                 columns["auto-updates"] = __( "Automatic Updates" );
        --         end;

        --         return columns;
        -- end;

        -- --
        -- -- @return array
        -- --
        -- protected function get_sortable_columns() then
        --         return array();
        -- end;

        -- --
        -- -- @global array totals
        -- -- @global string status
        -- -- @return array
        -- --
        -- protected function get_views() then
        --         global totals, status;

        --         status_links = array();
        --         foreach ( totals as type => count ) then
        --                 if ( ! count ) then
        --                         continue;
        --                 end;

        --                 switch ( type ) then
        --                         case "all":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _nx(
        --                                         "All <span class="count">(%s)</span>",
        --                                         "All <span class="count">(%s)</span>",
        --                                         count,
        --                                         "plugins"
        --                                 );
        --                                 break;
        --                         case "active":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Active <span class="count">(%s)</span>",
        --                                         "Active <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                         case "recently_activated":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Recently Active <span class="count">(%s)</span>",
        --                                         "Recently Active <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                         case "inactive":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Inactive <span class="count">(%s)</span>",
        --                                         "Inactive <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                         case "mustuse":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Must-Use <span class="count">(%s)</span>",
        --                                         "Must-Use <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                         case "dropins":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Drop-in <span class="count">(%s)</span>",
        --                                         "Drop-ins <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                         case "paused":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Paused <span class="count">(%s)</span>",
        --                                         "Paused <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                         case "upgrade":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Update Available <span class="count">(%s)</span>",
        --                                         "Update Available <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                         case "auto-update-enabled":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Auto-updates Enabled <span class="count">(%s)</span>",
        --                                         "Auto-updates Enabled <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                         case "auto-update-disabled":
        --                                 /* translators: %s: Number of plugins.--
        --                                 text = _n(
        --                                         "Auto-updates Disabled <span class="count">(%s)</span>",
        --                                         "Auto-updates Disabled <span class="count">(%s)</span>",
        --                                         count
        --                                 );
        --                                 break;
        --                 end;

        --                 if ( "search" !== type ) then
        --                         status_links[ type ] = array(
        --                                 "url"     => add_query_arg( "plugin_status", type, "plugins.php" ),
        --                                 "label"   => sprintf( text, number_format_i18n( count ) ),
        --                                 "current" => type === status,
        --                         );
        --                 end;
        --         end;

        --         return this.get_views_links( status_links );
        -- end;

        -- --
        -- -- @global string status
        -- -- @return array
        -- --
        -- protected function get_bulk_actions() then
        --         global status;

        --         actions = array();

        --         if ( "active" !== status ) then
        --                 actions["activate-selected"] = this.screen.in_admin( "network" ) ? __( "Network Activate" ) : __( "Activate" );
        --         end;

        --         if ( "inactive" !== status && "recent" !== status ) then
        --                 actions["deactivate-selected"] = this.screen.in_admin( "network" ) ? __( "Network Deactivate" ) : __( "Deactivate" );
        --         end;

        --         if ( ! is_multisite() || this.screen.in_admin( "network" ) ) then
        --                 if ( current_user_can( "update_plugins" ) ) then
        --                         actions["update-selected"] = __( "Update" );
        --                 end;

        --                 if ( current_user_can( "delete_plugins" ) && ( "active" !== status ) ) then
        --                         actions["delete-selected"] = __( "Delete" );
        --                 end;

        --                 if ( this.show_autoupdates ) then
        --                         if ( "auto-update-enabled" !== status ) then
        --                                 actions["enable-auto-update-selected"] = __( "Enable Auto-updates" );
        --                         end;
        --                         if ( "auto-update-disabled" !== status ) then
        --                                 actions["disable-auto-update-selected"] = __( "Disable Auto-updates" );
        --                         end;
        --                 end;
        --         end;

        --         return actions;
        -- end;

        -- --
        -- -- @global string status
        -- -- @param string which
        -- --
        -- public function bulk_actions( which = "" ) then
        --         global status;

        --         if ( in_array( status, array( "mustuse", "dropins" ), true ) ) then
        --                 return;
        --         end;

        --         parent::bulk_actions( which );
        -- end;

        -- --
        -- -- @global string status
        -- -- @param string which
        -- --
        -- protected function extra_tablenav( which ) then
        --         global status;

        --         if ( ! in_array( status, array( "recently_activated", "mustuse", "dropins" ), true ) ) then
        --                 return;
        --         end;

        --         echo "<div class="alignleft actions">";

        --         if ( "recently_activated" === status ) then
        --                 submit_button( __( "Clear List" ), "", "clear-recent-list", false );
        --         end; elseif ( "top" === which && "mustuse" === status ) then
        --                 echo "<p>" . sprintf(
        --                         /* translators: %s: mu-plugins directory name.--
        --                         __( "Files in the %s directory are executed automatically." ),
        --                         "<code>" . str_replace( ABSPATH, "/", WPMU_PLUGIN_DIR ) . "</code>"
        --                 ) . "</p>";
        --         end; elseif ( "top" === which && "dropins" === status ) then
        --                 echo "<p>" . sprintf(
        --                         /* translators: %s: wp-content directory name.--
        --                         __( "Drop-ins are single files, found in the %s directory, that replace or enhance WordPress features in ways that are not possible for traditional plugins." ),
        --                         "<code>" . str_replace( ABSPATH, "", WP_CONTENT_DIR ) . "</code>"
        --                 ) . "</p>";
        --         end;
        --         echo "</div>";
        -- end;

        -- --
        -- -- @return string
        -- --
        -- public function current_action() then
        --         if ( isset( _POST["clear-recent-list"] ) ) then
        --                 return "clear-recent-list";
        --         end;

        --         return parent::current_action();
        -- end;

   --
   -- @global string status
   --
   overriding
   procedure Display_Rows (This : in out Wp_Plugins_List_Table);

   --
   -- @global string status
   -- @global int page
   -- @global string s
   -- @global array totals
   --
   -- @param array item
   --
   overriding
   procedure Single_Row (This : in out Wp_Plugins_List_Table;
                         Item : Array_Type);
        --         global status, page, s, totals;
        --         static plugin_id_attrs = array();

        --         list( plugin_file, plugin_data ) = item;

        --         plugin_slug    = isset( plugin_data["slug"] ) ? plugin_data["slug"] : sanitize_title( plugin_data["Name"] );
        --         plugin_id_attr = plugin_slug;

        --         // Ensure the ID attribute is unique.
        --         suffix = 2;
        --         while ( in_array( plugin_id_attr, plugin_id_attrs, true ) ) then
        --                 plugin_id_attr = "plugin_slug-suffix";
        --                 suffix++;
        --         end;

        --         plugin_id_attrs[] = plugin_id_attr;

        --         context = status;
        --         screen  = this.screen;

        --         // Pre-order.
        --         actions = array(
        --                 "deactivate" => "",
        --                 "activate"   => "",
        --                 "details"    => "",
        --                 "delete"     => "",
        --         );

        --         // Do not restrict by default.
        --         restrict_network_active = false;
        --         restrict_network_only   = false;

        --         requires_php = isset( plugin_data["RequiresPHP"] ) ? plugin_data["RequiresPHP"] : null;
        --         requires_wp  = isset( plugin_data["RequiresWP"] ) ? plugin_data["RequiresWP"] : null;

        --         compatible_php = is_php_version_compatible( requires_php );
        --         compatible_wp  = is_wp_version_compatible( requires_wp );

        --         if ( "mustuse" === context ) then
        --                 is_active = true;
        --         end; elseif ( "dropins" === context ) then
        --                 dropins     = _get_dropins();
        --                 plugin_name = plugin_file;

        --                 if ( plugin_file !== plugin_data["Name"] ) then
        --                         plugin_name .= "<br />" . plugin_data["Name"];
        --                 end;

        --                 if ( true === ( dropins[ plugin_file ][1] ) ) then // Doesn"t require a constant.
        --                         is_active   = true;
        --                         description = "<p><strong>" . dropins[ plugin_file ][0] . "</strong></p>";
        --                 end; elseif ( defined( dropins[ plugin_file ][1] ) && constant( dropins[ plugin_file ][1] ) ) then // Constant is true.
        --                         is_active   = true;
        --                         description = "<p><strong>" . dropins[ plugin_file ][0] . "</strong></p>";
        --                 end; else then
        --                         is_active   = false;
        --                         description = "<p><strong>" . dropins[ plugin_file ][0] . " <span class="error-message">" . __( "Inactive:" ) . "</span></strong> " .
        --                                 sprintf(
        --                                         /* translators: 1: Drop-in constant name, 2: wp-config.php--
        --                                         __( "Requires %1s in %2s file." ),
        --                                         "<code>define("" . dropins[ plugin_file ][1] . "", true);</code>",
        --                                         "<code>wp-config.php</code>"
        --                                 ) . "</p>";
        --                 end;

        --                 if ( plugin_data["Description"] ) then
        --                         description .= "<p>" . plugin_data["Description"] . "</p>";
        --                 end;
        --         end; else then
        --                 if ( screen.in_admin( "network" ) ) then
        --                         is_active = is_plugin_active_for_network( plugin_file );
        --                 end; else then
        --                         is_active               = is_plugin_active( plugin_file );
        --                         restrict_network_active = ( is_multisite() && is_plugin_active_for_network( plugin_file ) );
        --                         restrict_network_only   = ( is_multisite() && is_network_only_plugin( plugin_file ) && ! is_active );
        --                 end;

        --                 if ( screen.in_admin( "network" ) ) then
        --                         if ( is_active ) then
        --                                 if ( current_user_can( "manage_network_plugins" ) ) then
        --                                         actions["deactivate"] = sprintf(
        --                                                 "<a href="%s" id="deactivate-%s" aria-label="%s">%s</a>",
        --                                                 wp_nonce_url( "plugins.php?action=deactivate&amp;plugin=" . urlencode( plugin_file ) . "&amp;plugin_status=" . context . "&amp;paged=" . page . "&amp;s=" . s, "deactivate-plugin_" . plugin_file ),
        --                                                 esc_attr( plugin_id_attr ),
        --                                                 /* translators: %s: Plugin name.--
        --                                                 esc_attr( sprintf( _x( "Network Deactivate %s", "plugin" ), plugin_data["Name"] ) ),
        --                                                 __( "Network Deactivate" )
        --                                         );
        --                                 end;
        --                         end; else then
        --                                 if ( current_user_can( "manage_network_plugins" ) ) then
        --                                         if ( compatible_php && compatible_wp ) then
        --                                                 actions["activate"] = sprintf(
        --                                                         "<a href="%s" id="activate-%s" class="edit" aria-label="%s">%s</a>",
        --                                                         wp_nonce_url( "plugins.php?action=activate&amp;plugin=" . urlencode( plugin_file ) . "&amp;plugin_status=" . context . "&amp;paged=" . page . "&amp;s=" . s, "activate-plugin_" . plugin_file ),
        --                                                         esc_attr( plugin_id_attr ),
        --                                                         /* translators: %s: Plugin name.--
        --                                                         esc_attr( sprintf( _x( "Network Activate %s", "plugin" ), plugin_data["Name"] ) ),
        --                                                         __( "Network Activate" )
        --                                                 );
        --                                         end; else then
        --                                                 actions["activate"] = sprintf(
        --                                                         "<span>%s</span>",
        --                                                         _x( "Cannot Activate", "plugin" )
        --                                                 );
        --                                         end;
        --                                 end;

        --                                 if ( current_user_can( "delete_plugins" ) && ! is_plugin_active( plugin_file ) ) then
        --                                         actions["delete"] = sprintf(
        --                                                 "<a href="%s" id="delete-%s" class="delete" aria-label="%s">%s</a>",
        --                                                 wp_nonce_url( "plugins.php?action=delete-selected&amp;checked[]=" . urlencode( plugin_file ) . "&amp;plugin_status=" . context . "&amp;paged=" . page . "&amp;s=" . s, "bulk-plugins" ),
        --                                                 esc_attr( plugin_id_attr ),
        --                                                 /* translators: %s: Plugin name.--
        --                                                 esc_attr( sprintf( _x( "Delete %s", "plugin" ), plugin_data["Name"] ) ),
        --                                                 __( "Delete" )
        --                                         );
        --                                 end;
        --                         end;
        --                 end; else then
        --                         if ( restrict_network_active ) then
        --                                 actions = array(
        --                                         "network_active" => __( "Network Active" ),
        --                                 );
        --                         end; elseif ( restrict_network_only ) then
        --                                 actions = array(
        --                                         "network_only" => __( "Network Only" ),
        --                                 );
        --                         end; elseif ( is_active ) then
        --                                 if ( current_user_can( "deactivate_plugin", plugin_file ) ) then
        --                                         actions["deactivate"] = sprintf(
        --                                                 "<a href="%s" id="deactivate-%s" aria-label="%s">%s</a>",
        --                                                 wp_nonce_url( "plugins.php?action=deactivate&amp;plugin=" . urlencode( plugin_file ) . "&amp;plugin_status=" . context . "&amp;paged=" . page . "&amp;s=" . s, "deactivate-plugin_" . plugin_file ),
        --                                                 esc_attr( plugin_id_attr ),
        --                                                 /* translators: %s: Plugin name.--
        --                                                 esc_attr( sprintf( _x( "Deactivate %s", "plugin" ), plugin_data["Name"] ) ),
        --                                                 __( "Deactivate" )
        --                                         );
        --                                 end;

        --                                 if ( current_user_can( "resume_plugin", plugin_file ) && is_plugin_paused( plugin_file ) ) then
        --                                         actions["resume"] = sprintf(
        --                                                 "<a href="%s" id="resume-%s" class="resume-link" aria-label="%s">%s</a>",
        --                                                 wp_nonce_url( "plugins.php?action=resume&amp;plugin=" . urlencode( plugin_file ) . "&amp;plugin_status=" . context . "&amp;paged=" . page . "&amp;s=" . s, "resume-plugin_" . plugin_file ),
        --                                                 esc_attr( plugin_id_attr ),
        --                                                 /* translators: %s: Plugin name.--
        --                                                 esc_attr( sprintf( _x( "Resume %s", "plugin" ), plugin_data["Name"] ) ),
        --                                                 __( "Resume" )
        --                                         );
        --                                 end;
        --                         end; else then
        --                                 if ( current_user_can( "activate_plugin", plugin_file ) ) then
        --                                         if ( compatible_php && compatible_wp ) then
        --                                                 actions["activate"] = sprintf(
        --                                                         "<a href="%s" id="activate-%s" class="edit" aria-label="%s">%s</a>",
        --                                                         wp_nonce_url( "plugins.php?action=activate&amp;plugin=" . urlencode( plugin_file ) . "&amp;plugin_status=" . context . "&amp;paged=" . page . "&amp;s=" . s, "activate-plugin_" . plugin_file ),
        --                                                         esc_attr( plugin_id_attr ),
        --                                                         /* translators: %s: Plugin name.--
        --                                                         esc_attr( sprintf( _x( "Activate %s", "plugin" ), plugin_data["Name"] ) ),
        --                                                         __( "Activate" )
        --                                                 );
        --                                         end; else then
        --                                                 actions["activate"] = sprintf(
        --                                                         "<span>%s</span>",
        --                                                         _x( "Cannot Activate", "plugin" )
        --                                                 );
        --                                         end;
        --                                 end;

        --                                 if ( ! is_multisite() && current_user_can( "delete_plugins" ) ) then
        --                                         actions["delete"] = sprintf(
        --                                                 "<a href="%s" id="delete-%s" class="delete" aria-label="%s">%s</a>",
        --                                                 wp_nonce_url( "plugins.php?action=delete-selected&amp;checked[]=" . urlencode( plugin_file ) . "&amp;plugin_status=" . context . "&amp;paged=" . page . "&amp;s=" . s, "bulk-plugins" ),
        --                                                 esc_attr( plugin_id_attr ),
        --                                                 /* translators: %s: Plugin name.--
        --                                                 esc_attr( sprintf( _x( "Delete %s", "plugin" ), plugin_data["Name"] ) ),
        --                                                 __( "Delete" )
        --                                         );
        --                                 end;
        --                         end; // End if is_active.
        --                 end; // End if screen.in_admin( "network" ).
        --         end; // End if context.

        --         actions = array_filter( actions );

        --         if ( screen.in_admin( "network" ) ) then

        --                 --
        --                 -- Filters the action links displayed for each plugin in the Network Admin Plugins list table.
        --                 --
        --                 -- @since 3.1.0
        --                 --
        --                 -- @param string[] actions     An array of plugin action links. By default this can include
        --                 --                              "activate", "deactivate", and "delete".
        --                 -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
        --                 -- @param array    plugin_data An array of plugin data. See get_plugin_data()
        --                 --                              and the then@see "plugin_row_meta"end; filter for the list
        --                 --                              of possible values.
        --                 -- @param string   context     The plugin context. By default this can include "all",
        --                 --                              "active", "inactive", "recently_activated", "upgrade",
        --                 --                              "mustuse", "dropins", and "search".
        --                 --
        --                 actions = apply_filters( "network_admin_plugin_action_links", actions, plugin_file, plugin_data, context );

        --                 --
        --                 -- Filters the list of action links displayed for a specific plugin in the Network Admin Plugins list table.
        --                 --
        --                 -- The dynamic portion of the hook name, `plugin_file`, refers to the path
        --                 -- to the plugin file, relative to the plugins directory.
        --                 --
        --                 -- @since 3.1.0
        --                 --
        --                 -- @param string[] actions     An array of plugin action links. By default this can include
        --                 --                              "activate", "deactivate", and "delete".
        --                 -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
        --                 -- @param array    plugin_data An array of plugin data. See get_plugin_data()
        --                 --                              and the then@see "plugin_row_meta"end; filter for the list
        --                 --                              of possible values.
        --                 -- @param string   context     The plugin context. By default this can include "all",
        --                 --                              "active", "inactive", "recently_activated", "upgrade",
        --                 --                              "mustuse", "dropins", and "search".
        --                 --
        --                 actions = apply_filters( "network_admin_plugin_action_links_thenplugin_fileend;", actions, plugin_file, plugin_data, context );

        --         end; else then

        --                 --
        --                 -- Filters the action links displayed for each plugin in the Plugins list table.
        --                 --
        --                 -- @since 2.5.0
        --                 -- @since 2.6.0 The `context` parameter was added.
        --                 -- @since 4.9.0 The "Edit" link was removed from the list of action links.
        --                 --
        --                 -- @param string[] actions     An array of plugin action links. By default this can include
        --                 --                              "activate", "deactivate", and "delete". With Multisite active
        --                 --                              this can also include "network_active" and "network_only" items.
        --                 -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
        --                 -- @param array    plugin_data An array of plugin data. See get_plugin_data()
        --                 --                              and the then@see "plugin_row_meta"end; filter for the list
        --                 --                              of possible values.
        --                 -- @param string   context     The plugin context. By default this can include "all",
        --                 --                              "active", "inactive", "recently_activated", "upgrade",
        --                 --                              "mustuse", "dropins", and "search".
        --                 --
        --                 actions = apply_filters( "plugin_action_links", actions, plugin_file, plugin_data, context );

        --                 --
        --                 -- Filters the list of action links displayed for a specific plugin in the Plugins list table.
        --                 --
        --                 -- The dynamic portion of the hook name, `plugin_file`, refers to the path
        --                 -- to the plugin file, relative to the plugins directory.
        --                 --
        --                 -- @since 2.7.0
        --                 -- @since 4.9.0 The "Edit" link was removed from the list of action links.
        --                 --
        --                 -- @param string[] actions     An array of plugin action links. By default this can include
        --                 --                              "activate", "deactivate", and "delete". With Multisite active
        --                 --                              this can also include "network_active" and "network_only" items.
        --                 -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
        --                 -- @param array    plugin_data An array of plugin data. See get_plugin_data()
        --                 --                              and the then@see "plugin_row_meta"end; filter for the list
        --                 --                              of possible values.
        --                 -- @param string   context     The plugin context. By default this can include "all",
        --                 --                              "active", "inactive", "recently_activated", "upgrade",
        --                 --                              "mustuse", "dropins", and "search".
        --                 --
        --                 actions = apply_filters( "plugin_action_links_thenplugin_fileend;", actions, plugin_file, plugin_data, context );

        --         end;

        --         class       = is_active ? "active" : "inactive";
        --         checkbox_id = "checkbox_" . md5( plugin_file );

        --         if ( restrict_network_active || restrict_network_only || in_array( status, array( "mustuse", "dropins" ), true ) || ! compatible_php ) then
        --                 checkbox = "";
        --         end; else then
        --                 checkbox = sprintf(
        --                         "<label class="screen-reader-text" for="%1s">%2s</label>" .
        --                         "<input type="checkbox" name="checked[]" value="%3s" id="%1s" />",
        --                         checkbox_id,
        --                         /* translators: %s: Plugin name.--
        --                         sprintf( __( "Select %s" ), plugin_data["Name"] ),
        --                         esc_attr( plugin_file )
        --                 );
        --         end;

        --         if ( "dropins" !== context ) then
        --                 description = "<p>" . ( plugin_data["Description"] ? plugin_data["Description"] : "&nbsp;" ) . "</p>";
        --                 plugin_name = plugin_data["Name"];
        --         end;

        --         if ( ! empty( totals["upgrade"] ) && ! empty( plugin_data["update"] )
        --                 || ! compatible_php || ! compatible_wp
        --         ) then
        --                 class .= " update";
        --         end;

        --         paused = ! screen.in_admin( "network" ) && is_plugin_paused( plugin_file );

        --         if ( paused ) then
        --                 class .= " paused";
        --         end;

        --         if ( is_uninstallable_plugin( plugin_file ) ) then
        --                 class .= " is-uninstallable";
        --         end;

        --         printf(
        --                 "<tr class="%s" data-slug="%s" data-plugin="%s">",
        --                 esc_attr( class ),
        --                 esc_attr( plugin_slug ),
        --                 esc_attr( plugin_file )
        --         );

        --         list( columns, hidden, sortable, primary ) = this.get_column_info();

        --         auto_updates      = (array) get_site_option( "auto_update_plugins", array() );
        --         available_updates = get_site_transient( "update_plugins" );

        --         foreach ( columns as column_name => column_display_name ) then
        --                 extra_classes = "";
        --                 if ( in_array( column_name, hidden, true ) ) then
        --                         extra_classes = " hidden";
        --                 end;

        --                 switch ( column_name ) then
        --                         case "cb":
        --                                 echo "<th scope="row" class="check-column">checkbox</th>";
        --                                 break;
        --                         case "name":
        --                                 echo "<td class="plugin-title column-primary"><strong>plugin_name</strong>";
        --                                 echo this.row_actions( actions, true );
        --                                 echo "</td>";
        --                                 break;
        --                         case "description":
        --                                 classes = "column-description desc";

        --                                 echo "<td class="classesthenextra_classesend;">
        --                                         <div class="plugin-description">description</div>
        --                                         <div class="class second plugin-version-author-uri">";

        --                                 plugin_meta = array();
        --                                 if ( ! empty( plugin_data["Version"] ) ) then
        --                                         /* translators: %s: Plugin version number.--
        --                                         plugin_meta[] = sprintf( __( "Version %s" ), plugin_data["Version"] );
        --                                 end;
        --                                 if ( ! empty( plugin_data["Author"] ) ) then
        --                                         author = plugin_data["Author"];
        --                                         if ( ! empty( plugin_data["AuthorURI"] ) ) then
        --                                                 author = "<a href="" . plugin_data["AuthorURI"] . "">" . plugin_data["Author"] . "</a>";
        --                                         end;
        --                                         /* translators: %s: Plugin author name.--
        --                                         plugin_meta[] = sprintf( __( "By %s" ), author );
        --                                 end;

        --                                 // Details link using API info, if available.
        --                                 if ( isset( plugin_data["slug"] ) && current_user_can( "install_plugins" ) ) then
        --                                         plugin_meta[] = sprintf(
        --                                                 "<a href="%s" class="thickbox open-plugin-details-modal" aria-label="%s" data-title="%s">%s</a>",
        --                                                 esc_url(
        --                                                         network_admin_url(
        --                                                                 "plugin-install.php?tab=plugin-information&plugin=" . plugin_data["slug"] .
        --                                                                 "&TB_iframe=true&width=600&height=550"
        --                                                         )
        --                                                 ),
        --                                                 /* translators: %s: Plugin name.--
        --                                                 esc_attr( sprintf( __( "More information about %s" ), plugin_name ) ),
        --                                                 esc_attr( plugin_name ),
        --                                                 __( "View details" )
        --                                         );
        --                                 end; elseif ( ! empty( plugin_data["PluginURI"] ) ) then
        --                                         /* translators: %s: Plugin name.--
        --                                         aria_label = sprintf( __( "Visit plugin site for %s" ), plugin_name );

        --                                         plugin_meta[] = sprintf(
        --                                                 "<a href="%s" aria-label="%s">%s</a>",
        --                                                 esc_url( plugin_data["PluginURI"] ),
        --                                                 esc_attr( aria_label ),
        --                                                 __( "Visit plugin site" )
        --                                         );
        --                                 end;

        --                                 --
        --                                 -- Filters the array of row meta for each plugin in the Plugins list table.
        --                                 --
        --                                 -- @since 2.8.0
        --                                 --
        --                                 -- @param string[] plugin_meta An array of the plugin"s metadata, including
        --                                 --                              the version, author, author URI, and plugin URI.
        --                                 -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
        --                                 -- @param array    plugin_data then
        --                                 --     An array of plugin data.
        --                                 --
        --                                 --     @type string   id               Plugin ID, e.g. `w.org/plugins/[plugin-name]`.
        --                                 --     @type string   slug             Plugin slug.
        --                                 --     @type string   plugin           Plugin basename.
        --                                 --     @type string   new_version      New plugin version.
        --                                 --     @type string   url              Plugin URL.
        --                                 --     @type string   package          Plugin update package URL.
        --                                 --     @type string[] icons            An array of plugin icon URLs.
        --                                 --     @type string[] banners          An array of plugin banner URLs.
        --                                 --     @type string[] banners_rtl      An array of plugin RTL banner URLs.
        --                                 --     @type string   requires         The version of WordPress which the plugin requires.
        --                                 --     @type string   tested           The version of WordPress the plugin is tested against.
        --                                 --     @type string   requires_php     The version of PHP which the plugin requires.
        --                                 --     @type string   upgrade_notice   The upgrade notice for the new plugin version.
        --                                 --     @type bool     update-supported Whether the plugin supports updates.
        --                                 --     @type string   Name             The human-readable name of the plugin.
        --                                 --     @type string   PluginURI        Plugin URI.
        --                                 --     @type string   Version          Plugin version.
        --                                 --     @type string   Description      Plugin description.
        --                                 --     @type string   Author           Plugin author.
        --                                 --     @type string   AuthorURI        Plugin author URI.
        --                                 --     @type string   TextDomain       Plugin textdomain.
        --                                 --     @type string   DomainPath       Relative path to the plugin"s .mo file(s).
        --                                 --     @type bool     Network          Whether the plugin can only be activated network-wide.
        --                                 --     @type string   RequiresWP       The version of WordPress which the plugin requires.
        --                                 --     @type string   RequiresPHP      The version of PHP which the plugin requires.
        --                                 --     @type string   UpdateURI        ID of the plugin for update purposes, should be a URI.
        --                                 --     @type string   Title            The human-readable title of the plugin.
        --                                 --     @type string   AuthorName       Plugin author"s name.
        --                                 --     @type bool     update           Whether there"s an available update. Default null.
        --                                 -- end;
        --                                 -- @param string   status      Status filter currently applied to the plugin list. Possible
        --                                 --                              values are: "all", "active", "inactive", "recently_activated",
        --                                 --                              "upgrade", "mustuse", "dropins", "search", "paused",
        --                                 --                              "auto-update-enabled", "auto-update-disabled".
        --                                 --
        --                                 plugin_meta = apply_filters( "plugin_row_meta", plugin_meta, plugin_file, plugin_data, status );

        --                                 echo implode( " | ", plugin_meta );

        --                                 echo "</div>";

        --                                 if ( paused ) then
        --                                         notice_text = __( "This plugin failed to load properly and is paused during recovery mode." );

        --                                         printf( "<p><span class="dashicons dashicons-warning"></span> <strong>%s</strong></p>", notice_text );

        --                                         error = wp_get_plugin_error( plugin_file );

        --                                         if ( false !== error ) then
        --                                                 printf( "<div class="error-display"><p>%s</p></div>", wp_get_extension_error_description( error ) );
        --                                         end;
        --                                 end;

        --                                 echo "</td>";
        --                                 break;
        --                         case "auto-updates":
        --                                 if ( ! this.show_autoupdates ) then
        --                                         break;
        --                                 end;

        --                                 echo "<td class="column-auto-updatesthenextra_classesend;">";

        --                                 html = array();

        --                                 if ( isset( plugin_data["auto-update-forced"] ) ) then
        --                                         if ( plugin_data["auto-update-forced"] ) then
        --                                                 // Forced on.
        --                                                 text = __( "Auto-updates enabled" );
        --                                         end; else then
        --                                                 text = __( "Auto-updates disabled" );
        --                                         end;
        --                                         action     = "unavailable";
        --                                         time_class = " hidden";
        --                                 end; elseif ( empty( plugin_data["update-supported"] ) ) then
        --                                         text       = "";
        --                                         action     = "unavailable";
        --                                         time_class = " hidden";
        --                                 end; elseif ( in_array( plugin_file, auto_updates, true ) ) then
        --                                         text       = __( "Disable auto-updates" );
        --                                         action     = "disable";
        --                                         time_class = "";
        --                                 end; else then
        --                                         text       = __( "Enable auto-updates" );
        --                                         action     = "enable";
        --                                         time_class = " hidden";
        --                                 end;

        --                                 query_args = array(
        --                                         "action"        => "thenactionend;-auto-update",
        --                                         "plugin"        => plugin_file,
        --                                         "paged"         => page,
        --                                         "plugin_status" => status,
        --                                 );

        --                                 url = add_query_arg( query_args, "plugins.php" );

        --                                 if ( "unavailable" === action ) then
        --                                         html[] = "<span class="label">" . text . "</span>";
        --                                 end; else then
        --                                         html[] = sprintf(
        --                                                 "<a href="%s" class="toggle-auto-update aria-button-if-js" data-wp-action="%s">",
        --                                                 wp_nonce_url( url, "updates" ),
        --                                                 action
        --                                         );

        --                                         html[] = "<span class="dashicons dashicons-update spin hidden" aria-hidden="true"></span>";
        --                                         html[] = "<span class="label">" . text . "</span>";
        --                                         html[] = "</a>";
        --                                 end;

        --                                 if ( ! empty( plugin_data["update"] ) ) then
        --                                         html[] = sprintf(
        --                                                 "<div class="auto-update-time%s">%s</div>",
        --                                                 time_class,
        --                                                 wp_get_auto_update_message()
        --                                         );
        --                                 end;

        --                                 html = implode( "", html );

        --                                 --
        --                                 -- Filters the HTML of the auto-updates setting for each plugin in the Plugins list table.
        --                                 --
        --                                 -- @since 5.5.0
        --                                 --
        --                                 -- @param string html        The HTML of the plugin"s auto-update column content,
        --                                 --                            including toggle auto-update action links and
        --                                 --                            time to next update.
        --                                 -- @param string plugin_file Path to the plugin file relative to the plugins directory.
        --                                 -- @param array  plugin_data An array of plugin data. See get_plugin_data()
        --                                 --                            and the then@see "plugin_row_meta"end; filter for the list
        --                                 --                            of possible values.
        --                                 --
        --                                 echo apply_filters( "plugin_auto_update_setting_html", html, plugin_file, plugin_data );

        --                                 echo "<div class="notice notice-error notice-alt inline hidden"><p></p></div>";
        --                                 echo "</td>";

        --                                 break;
        --                         default:
        --                                 classes = "column_name column-column_name class";

        --                                 echo "<td class="classesthenextra_classesend;">";

        --                                 --
        --                                 -- Fires inside each custom column of the Plugins list table.
        --                                 --
        --                                 -- @since 3.1.0
        --                                 --
        --                                 -- @param string column_name Name of the column.
        --                                 -- @param string plugin_file Path to the plugin file relative to the plugins directory.
        --                                 -- @param array  plugin_data An array of plugin data. See get_plugin_data()
        --                                 --                            and the then@see "plugin_row_meta"end; filter for the list
        --                                 --                            of possible values.
        --                                 --
        --                                 do_action( "manage_plugins_custom_column", column_name, plugin_file, plugin_data );

        --                                 echo "</td>";
        --                 end;
        --         end;

        --         echo "</tr>";

        --         if ( ! compatible_php || ! compatible_wp ) then
        --                 printf(
        --                         "<tr class="plugin-update-tr">" .
        --                         "<td colspan="%s" class="plugin-update colspanchange">" .
        --                         "<div class="update-message notice inline notice-error notice-alt"><p>",
        --                         esc_attr( this.get_column_count() )
        --                 );

        --                 if ( ! compatible_php && ! compatible_wp ) then
        --                         _e( "This plugin does not work with your versions of WordPress and PHP." );
        --                         if ( current_user_can( "update_core" ) && current_user_can( "update_php" ) ) then
        --                                 printf(
        --                                         /* translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.--
        --                                         " " . __( "<a href="%1s">Please update WordPress</a>, and then <a href="%2s">learn more about updating PHP</a>." ),
        --                                         self_admin_url( "update-core.php" ),
        --                                         esc_url( wp_get_update_php_url() )
        --                                 );
        --                                 wp_update_php_annotation( "</p><p><em>", "</em>" );
        --                         end; elseif ( current_user_can( "update_core" ) ) then
        --                                 printf(
        --                                         /* translators: %s: URL to WordPress Updates screen.--
        --                                         " " . __( "<a href="%s">Please update WordPress</a>." ),
        --                                         self_admin_url( "update-core.php" )
        --                                 );
        --                         end; elseif ( current_user_can( "update_php" ) ) then
        --                                 printf(
        --                                         /* translators: %s: URL to Update PHP page.--
        --                                         " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
        --                                         esc_url( wp_get_update_php_url() )
        --                                 );
        --                                 wp_update_php_annotation( "</p><p><em>", "</em>" );
        --                         end;
        --                 end; elseif ( ! compatible_wp ) then
        --                         _e( "This plugin does not work with your version of WordPress." );
        --                         if ( current_user_can( "update_core" ) ) then
        --                                 printf(
        --                                         /* translators: %s: URL to WordPress Updates screen.--
        --                                         " " . __( "<a href="%s">Please update WordPress</a>." ),
        --                                         self_admin_url( "update-core.php" )
        --                                 );
        --                         end;
        --                 end; elseif ( ! compatible_php ) then
        --                         _e( "This plugin does not work with your version of PHP." );
        --                         if ( current_user_can( "update_php" ) ) then
        --                                 printf(
        --                                         /* translators: %s: URL to Update PHP page.--
        --                                         " " . __( "<a href="%s">Learn more about updating PHP</a>." ),
        --                                         esc_url( wp_get_update_php_url() )
        --                                 );
        --                                 wp_update_php_annotation( "</p><p><em>", "</em>" );
        --                         end;
        --                 end;

        --                 echo "</p></div></td></tr>";
        --         end;

        --         --
        --         -- Fires after each row in the Plugins list table.
        --         --
        --         -- @since 2.3.0
        --         -- @since 5.5.0 Added "auto-update-enabled" and "auto-update-disabled"
        --         --              to possible values for `status`.
        --         --
        --         -- @param string plugin_file Path to the plugin file relative to the plugins directory.
        --         -- @param array  plugin_data An array of plugin data. See get_plugin_data()
        --         --                            and the then@see "plugin_row_meta"end; filter for the list
        --         --                            of possible values.
        --         -- @param string status      Status filter currently applied to the plugin list.
        --         --                            Possible values are: "all", "active", "inactive",
        --         --                            "recently_activated", "upgrade", "mustuse", "dropins",
        --         --                            "search", "paused", "auto-update-enabled", "auto-update-disabled".
        --         --
        --         do_action( "after_plugin_row", plugin_file, plugin_data, status );

        --         --
        --         -- Fires after each specific row in the Plugins list table.
        --         --
        --         -- The dynamic portion of the hook name, `plugin_file`, refers to the path
        --         -- to the plugin file, relative to the plugins directory.
        --         --
        --         -- @since 2.7.0
        --         -- @since 5.5.0 Added "auto-update-enabled" and "auto-update-disabled"
        --         --              to possible values for `status`.
        --         --
        --         -- @param string plugin_file Path to the plugin file relative to the plugins directory.
        --         -- @param array  plugin_data An array of plugin data. See get_plugin_data()
        --         --                            and the then@see "plugin_row_meta"end; filter for the list
        --         --                            of possible values.
        --         -- @param string status      Status filter currently applied to the plugin list.
        --         --                            Possible values are: "all", "active", "inactive",
        --         --                            "recently_activated", "upgrade", "mustuse", "dropins",
        --         --                            "search", "paused", "auto-update-enabled", "auto-update-disabled".
        --         --
        --         do_action( "after_plugin_row_thenplugin_fileend;", plugin_file, plugin_data, status );
        -- end;

   --
   -- Gets the name of the primary column for this specific list table.
   --
   -- @since 4.3.0
   --
   -- @return string Unalterable name for the primary column, in this case, "name".
   --
   -- protected
   function Get_Primary_Column_Name (This : Wp_Plugins_List_Table'Class)
                                     return String;
        --         return "name";
        -- end;

end Class_Plugins_List_Tables;
