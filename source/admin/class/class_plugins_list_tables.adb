--
-- List Table API: WP_Plugins_List_Table class
--
-- @package WordPress
-- @subpackage Administration
-- @since 3.1.0
--

with Php.Arrays;
with Php.Echoing;
with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Strings;

with Array_Lists;
with Binder;
with Globals;
with Helpers;
with Lists;
with Logging;
with UStrings;
with Wp_Common;

with Class_Screens;

with Adi_Plugins;
with Adi_Update;

with Inc_Capabilities;
with Inc_Error_Protection;
with Inc_Formatting;
with Inc_Functions;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;

package body Class_Plugins_List_Tables
is
   use Lists;

   -----------------
   -- X_Construct --
   -----------------

   overriding
   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_Plugins_List_Table
   is
      use Php.Lists;
      use Array_Lists;
      use Binder;
      use UStrings;
      use Class_List_Tables;
      use Adi_Update;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;

      This : Wp_Plugins_List_Table := (
        Class_List_Tables.X_Construct (
          To_Array_Type ([
             Build ("plural", "plugins"),
             Build ("screen", (if Isset (Args, "screen")
                               then Get (Args, "screen") else From_Null))
          ])
        )
        with
          Show_Autoupdates => True
      );

      Allowed_Statuses : constant List_Type :=
        ["active", "inactive", "recently_activated", "upgrade", "mustuse",
         "dropins", "search", "paused", "auto-update-enabled",
         "auto-update-disabled"];
   begin
      Logging.Log ("class_plugins_list_table.x_construct", "");
      Globals.Global_Status := +"all";

      if
        Isset (X_REQUEST, "plugin_status") and then
        In_List (Get_As_String (X_REQUEST, "plugin_status"),
                 Allowed_Statuses, True)
      then
         Globals.Global_Status := +Get_As_String (X_REQUEST, "plugin_status");
      end if;

      if Isset (X_REQUEST, "s") then
         Set (X_SERVER, "REQUEST_URI", From_String (
              Add_Query_Arg ("s", Wp_Unslash (Get_As_String (X_REQUEST, "s")))));
      end if;

      Globals.Global_Page := This.Get_Pagenum;

      This.Show_Autoupdates :=
        Wp_Is_Auto_Update_Enabled_For_Type ("plugin") and then
        Current_User_Can ("update_plugins") and then
        (not Is_Multisite or else This.Screen.In_Admin ("network")) and then
        not In_List (-Globals.Global_Status, ["mustuse", "dropins"], True);

      return This;
   end X_Construct;

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

   -----------------
   -- Get_Columns --
   -----------------

   overriding
   function Get_Columns (This : Wp_Plugins_List_Table)
                         return Array_Type
   is
      use Php.Lists;
      use Array_Lists;
      use UStrings;
      use Inc_L10n;

      Checkbox : constant Boolean :=
        not In_List (-Globals.Global_Status, ["mustuse", "dropins"], True);

      Columns : Array_Type :=
        To_Array_Type ([
          Build ("cb",          (if Checkbox
                                 then "<input type=""checkbox"" />" else "")),
          Build ("name",        abs "Plugin"),
          Build ("description", abs "Description")
        ]);
   begin
      if This.Show_Autoupdates then
         Set (Columns, "auto-updates", From_String (abs "Automatic Updates"));
      end if;

      return Columns;
   end Get_Columns;

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

    ------------------
    -- Display_Rows --
    ------------------

   overriding
   procedure Display_Rows (This : in out Wp_Plugins_List_Table)
   is
      use Php.Lists;
      use UStrings;
      use Inc_Load;
   begin
      if
        Is_Multisite and then
        not This.Screen .In_Admin ("network") and then
        In_List (-Globals.Global_Status, ["mustuse", "dropins"], True)
      then
         return;
      end if;

      for A in This.Items.Iterate loop
         declare
            Plugin_File : constant String     := Key (A);
            Plugin_Data : constant Multi_Type := Element (A);
         begin
            This.Single_Row (Build (Plugin_File, Plugin_Data));
         end;
      end loop;
   end Display_Rows;

   ----------------
   -- Single_Row --
   ----------------

   Static_Plugin_Id_Attrs : List_Type; -- Array_Type;

   overriding
   procedure Single_Row (This : in out Wp_Plugins_List_Table;
                         Item : Array_Type)
   is
      use Php.Arrays;
      use Php.Echoing;
      use Php.HTML;
      use Php.Strings;
      use Php.Lists;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Class_List_Tables;
      use Class_Screens;
      use Adi_Plugins;
      use Adi_Update;
      use Inc_Capabilities;
      use Inc_Error_Protection;
      use Inc_Functions;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;

--    global status, page, s, totals;

--                list( plugin_file, plugin_data ) = item;
      Plugin_File : constant String := "XXX";
      Plugin_Data : Array_Type;

      Plugin_Slug : String := (if Isset (Plugin_Data, "slug") then Get_As_String (Plugin_Data, "slug") else Sanitize_Title (Get_As_String (Plugin_Data, "Name")));
      Plugin_Id_Attr : UString := +Plugin_Slug;

      -- Ensure the ID attribute is unique.
      Suffix : Natural := 2;
   begin
      while In_List (-Plugin_Id_Attr, Static_Plugin_Id_Attrs, True) loop
         Plugin_Id_Attr := +"plugin_slug-" & Helpers.Image (Suffix);
         Suffix := Suffix + 1;
      end loop;

      Static_Plugin_Id_Attrs.Append (-Plugin_Id_Attr);

      declare
         Context : constant String := -Globals.Global_Status;
         Screen  : constant Wp_Screen := This.Screen;

         -- Pre-order.
         Actions : Array_Type :=
           To_Array_Type ([
             Build ("deactivate", ""),
             Build ("activate",   ""),
             Build ("details",    ""),
             Build ("delete",     "")
           ]);

         -- Do not restrict by default.
         Restrict_Network_Active : Boolean := False;
         Restrict_Network_Only   : Boolean := False;

         Requires_PHP : constant String :=
           (if Isset (Plugin_Data, "RequiresPHP")
            then Get_As_String (Plugin_Data, "RequiresPHP") else ""); -- null

         Requires_Wp  : constant String :=
           (if Isset (Plugin_Data, "RequiresWP")
            then Get_As_String (Plugin_Data, "RequiresWP") else ""); -- null

         Compatible_PHP : constant Boolean := Is_PHP_Version_Compatible (Requires_PHP);
         Compatible_Wp  : constant Boolean := Is_Wp_Version_Compatible  (Requires_Wp);

         Is_Active : Boolean;
         Plugin_Name : UString;
         Description : UString;
      begin
         if "mustuse" = Context then
            Is_Active := True;
         elsif "dropins" = Context then
            declare
               Dropins : constant Array_Type := X_Get_Dropins;
            begin
               Plugin_Name := +Plugin_File;

               if Plugin_File /= Get_As_String (Plugin_Data, "Name") then
                  Append (Plugin_Name, "<br />" & Get_As_String (Plugin_Data, "Name"));
               end if;

               if True = As_Boolean (Get (Ref_2 (Dropins, Plugin_File, "[1]"))) then -- Doesn't require a constant.
                  Is_Active   := True;
                  Description := +"<p><strong>" & As_String (Get (Ref_2 (Dropins, Plugin_File, "[0]"))) & "</strong></p>";
--             elsif defined( dropins[ plugin_file ][1]) and then constant( dropins[ plugin_file ][1]) then -- Constant is true.
--             elsif defined( dropins[ plugin_file ][1]) and then constant( dropins[ plugin_file ][1]) then -- Constant is true.
--                Is_Active   := True;
--                Description := +"<p><strong>" & dropins[ plugin_file ][0] & "</strong></p>");
               else
                  Is_Active   := False;
                  Description := +"<p><strong>" & As_String (Get (Ref_2 (Dropins, Plugin_File, "[0]"))) & " <span class=""error-message"">" & abs "Inactive:" & "</span></strong> " &
                  Sprintf (
                    -- translators: 1: Drop-in constant name, 2: wp-config.php
                    abs "Requires %1s in %2s file.",
                    [
                      1 => "<code>define(""" &
                           As_String (Get (Ref_2 (Dropins, Plugin_File, "[1]"))) &
                           """, true);</code>",
                      2 => "<code>wp-config.php</code>"
                    ]
                  ) & "</p>";
               end if;

               if Get_As_String (Plugin_Data, "Description") /= "" then
                  Append (Description, "<p>" & Get_As_String (Plugin_Data, "Description") & "</p>");
               end if;
            end;
         else
            if Screen.In_Admin ("network") then
               Is_Active := Is_Plugin_Active_For_Network (Plugin_File);
            else
               Is_Active               := Is_Plugin_Active (Plugin_File);
               Restrict_Network_Active := (Is_Multisite and then Is_Plugin_Active_For_Network (Plugin_File));
               Restrict_Network_Only   := (Is_Multisite and then Is_Network_Only_Plugin (Plugin_File) and then not Is_Active);
            end if;

            if Screen.In_Admin ("network") then
               if Is_Active then
                  if Current_User_Can ("manage_network_plugins") then
                     Set (Actions, "deactivate", From_String (
                          Sprintf (
                            "<a href=""%s"" id=""deactivate-%s"" aria-label=""%s"">%s</a>",
                            [
                              1 => Wp_Nonce_URL ("plugins.php?action=deactivate&amp;plugin=" & URL_Encode (Plugin_File) & "&amp;plugin_status=" & Context & "&amp;paged=" & Helpers.Image (Globals.Global_Page) & "&amp;s=" & (-Globals.Global_S), "deactivate-plugin_" & Plugin_File),
                              2 => ESC_Attr (-Plugin_Id_Attr),
                              -- translators: %s: Plugin name.--
                              3 => ESC_Attr (Sprintf (X_X ("Network Deactivate %s", "plugin"), [Get_As_String (Plugin_Data, "Name")])),
                              4 => abs "Network Deactivate"
                            ]
                          )));
                  end if;

               else
                  if Current_User_Can ("manage_network_plugins") then
                     if Compatible_PHP and then Compatible_Wp then
                        Set (Actions, "activate", From_String (
                             Sprintf (
                               "<a href=""%s"" id=""activate-%s"" class=""edit"" aria-label=""%s"">%s</a>",
                               [
                                 1 => Wp_Nonce_URL ("plugins.php?action=activate&amp;plugin=" & URL_Encode (Plugin_File) & "&amp;plugin_status=" & Context & "&amp;paged=" & Helpers.Image (Globals.Global_Page) & "&amp;s=" & (-Globals.Global_S), "activate-plugin_" & Plugin_File),
                                 2 => ESC_Attr (-Plugin_Id_Attr),
                                 -- translators: %s: Plugin name.
                                 3 => ESC_Attr (Sprintf (X_X ("Network Activate %s", "plugin"), [Get_As_String (Plugin_Data, "Name")])),
                                 4 => abs "Network Activate"
                               ]
                              )));
                     else
                        Set (Actions, "activate", From_String (
                             Sprintf (
                               "<span>%s</span>",
                               [1 => X_X ("Cannot Activate", "plugin")]
                            )));
                     end if;
                  end if;

                  if
                    Current_User_Can ("delete_plugins") and then
                    not Is_Plugin_Active (Plugin_File)
                  then
                     Set (Actions, "delete", From_String (
                          Sprintf (
                            "<a href=""%s"" id=""delete-%s"" class=""delete"" aria-label=""%s"">%s</a>",
                            [
                              1 => Wp_Nonce_URL ("plugins.php?action=delete-selected&amp;checked[]=" & URL_Encode (Plugin_File) & "&amp;plugin_status=" & Context & "&amp;paged=" & Helpers.Image (Globals.Global_Page) & "&amp;s=" & (-Globals.Global_S), "bulk-plugins"),
                              2 => ESC_Attr (-Plugin_Id_Attr),
                              -- translators: %s: Plugin name.
                              3 => ESC_Attr (Sprintf (X_X ("Delete %s", "plugin"), [Get_As_String (Plugin_Data, "Name")])),
                              4 => abs "Delete"
                            ]
                           )));
                  end if;
               end if;

            else
               if Restrict_Network_Active then
                  Actions := To_Array_Type ([
                    Build ("network_active", abs "Network Active")
                  ]);
               elsif Restrict_Network_Only then
                  Actions := To_Array_Type ([
                    Build ("network_only", abs "Network Only")
                  ]);
               elsif Is_Active then
                  if Current_User_Can ("deactivate_plugin", Plugin_File) then
                     Set (Actions, "deactivate", From_String (
                          Sprintf (
                            "<a href=""%s"" id=""deactivate-%s"" aria-label=""%s"">%s</a>",
                            [
                              1 => Wp_Nonce_URL ("plugins.php?action=deactivate&amp;plugin=" & URL_Encode (Plugin_File) & "&amp;plugin_status=" & Context & "&amp;paged=" & Helpers.Image (Globals.Global_Page) & "&amp;s=" & (-Globals.Global_S), "deactivate-plugin_" & Plugin_File),
                              2 => ESC_Attr (-Plugin_Id_Attr),
                              -- translators: %s: Plugin name.
                              3 => ESC_Attr (Sprintf (X_X ("Deactivate %s", "plugin"), [Get_As_String (Plugin_Data, "Name")])),
                              4 => abs "Deactivate"
                            ]
                           )));
                  end if;

                  if
                    Current_User_Can ("resume_plugin", Plugin_File) and then
                    Is_Plugin_Paused (Plugin_File)
                  then
                     Set (Actions, "resume", From_String (
                          Sprintf (
                            "<a href=""%s"" id=""resume-%s"" class=""resume-link"" aria-label=""%s"">%s</a>",
                            [
                              1 => Wp_Nonce_URL ("plugins.php?action=resume&amp;plugin=" & URL_Encode (Plugin_File) & "&amp;plugin_status=" & Context & "&amp;paged=" & Helpers.Image (Globals.Global_Page) & "&amp;s=" & (-Globals.Global_S), "resume-plugin_" & Plugin_File),
                              2 => ESC_Attr (-Plugin_Id_Attr),
                              -- translators: %s: Plugin name.
                              3 => ESC_Attr (Sprintf (X_X ("Resume %s", "plugin"), [Get_As_String (Plugin_Data, "Name")])),
                              4 => abs "Resume"
                            ]
                           )));
                  end if;

               else
                  if Current_User_Can ("activate_plugin", Plugin_File) then
                     if Compatible_PHP and then Compatible_Wp then
                        Set (Actions, "activate", From_String (
                             Sprintf (
                               "<a href=""%s"" id=""activate-%s"" class=""edit"" aria-label=""%s"">%s</a>",
                             [
                               1 => Wp_Nonce_URL ("plugins.php?action=activate&amp;plugin=" & URL_Encode (Plugin_File) & "&amp;plugin_status=" & Context & "&amp;paged=" & Helpers.Image (Globals.Global_Page) & "&amp;s=" & (-Globals.Global_S), "activate-plugin_" & Plugin_File),
                               2 => ESC_Attr (-Plugin_Id_Attr),
                               -- translators: %s: Plugin name.
                               3 => ESC_Attr (Sprintf (X_X ("Activate %s", "plugin"), [Get_As_String (Plugin_Data, "Name")])),
                               4 => abs "Activate"
                             ]
                            )));
                     else
                        Set (Actions, "activate", From_String (
                             Sprintf (
                               "<span>%s</span>",
                               [X_X ("Cannot Activate", "plugin")]
                             )));
                     end if;
                  end if;

                  if not Is_Multisite and then Current_User_Can ("delete_plugins") then
                     Set (Actions, "delete", From_String (
                          Sprintf (
                            "<a href=""%s"" id=""delete-%s"" class=""delete"" aria-label=""%s"">%s</a>",
                            [
                              1 => Wp_Nonce_URL ("plugins.php?action=delete-selected&amp;checked[]=" & URL_Encode (Plugin_File) & "&amp;plugin_status=" & Context & "&amp;paged=" & Helpers.Image (Globals.Global_Page) & "&amp;s=" & (-Globals.Global_S), "bulk-plugins"),
                              2 => ESC_Attr (-Plugin_Id_Attr),
                              -- translators: %s: Plugin name.
                              3 => ESC_Attr (Sprintf (X_X ("Delete %s", "plugin"), [Get_As_String (Plugin_Data, "Name")])),
                              4 => abs "Delete"
                            ]
                           )));
                  end if;
               end if; -- End if is_active.
            end if; -- End if screen.in_admin("network").
         end if; -- End if context.

         Actions := Array_Filter (Actions);

         if Screen.In_Admin ("network") then
            --
               -- Filters the action links displayed for each plugin in the Network Admin Plugins list table.
               --
               -- @since 3.1.0
               --
               -- @param string[] actions     An array of plugin action links. By default this can include
               --                              "activate", "deactivate", and "delete".
               -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
               -- @param array    plugin_data An array of plugin data. See get_plugin_data()
               --                              and the then@see "plugin_row_meta"end; filter for the list
               --                              of possible values.
               -- @param string   context     The plugin context. By default this can include "all",
               --                              "active", "inactive", "recently_activated", "upgrade",
               --                              "mustuse", "dropins", and "search".
               --
            Actions := Apply_Filters ("network_admin_plugin_action_links", Actions, Plugin_File, Plugin_Data, Context);

               --
               -- Filters the list of action links displayed for a specific plugin in the Network Admin Plugins list table.
               --
               -- The dynamic portion of the hook name, `plugin_file`, refers to the path
               -- to the plugin file, relative to the plugins directory.
               --
               -- @since 3.1.0
               --
               -- @param string[] actions     An array of plugin action links. By default this can include
               --                              "activate", "deactivate", and "delete".
               -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
               -- @param array    plugin_data An array of plugin data. See get_plugin_data()
               --                              and the then@see "plugin_row_meta"end; filter for the list
               --                              of possible values.
               -- @param string   context     The plugin context. By default this can include "all",
               --                              "active", "inactive", "recently_activated", "upgrade",
               --                              "mustuse", "dropins", and "search".
               --
               Actions := Apply_Filters ("network_admin_plugin_action_links_" & Plugin_File, Actions, Plugin_File, Plugin_Data, Context);

         else
               --
               -- Filters the action links displayed for each plugin in the Plugins list table.
               --
               -- @since 2.5.0
               -- @since 2.6.0 The `context` parameter was added.
               -- @since 4.9.0 The "Edit" link was removed from the list of action links.
               --
               -- @param string[] actions     An array of plugin action links. By default this can include
               --                              "activate", "deactivate", and "delete". With Multisite active
               --                              this can also include "network_active" and "network_only" items.
               -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
               -- @param array    plugin_data An array of plugin data. See get_plugin_data()
               --                              and the then@see "plugin_row_meta"end; filter for the list
               --                              of possible values.
               -- @param string   context     The plugin context. By default this can include "all",
               --                              "active", "inactive", "recently_activated", "upgrade",
               --                              "mustuse", "dropins", and "search".
               --
               Actions := Apply_Filters ("plugin_action_links", Actions, Plugin_File, Plugin_Data, Context);

               --
               -- Filters the list of action links displayed for a specific plugin in the Plugins list table.
               --
               -- The dynamic portion of the hook name, `plugin_file`, refers to the path
               -- to the plugin file, relative to the plugins directory.
               --
               -- @since 2.7.0
               -- @since 4.9.0 The "Edit" link was removed from the list of action links.
               --
               -- @param string[] actions     An array of plugin action links. By default this can include
               --                              "activate", "deactivate", and "delete". With Multisite active
               --                              this can also include "network_active" and "network_only" items.
               -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
               -- @param array    plugin_data An array of plugin data. See get_plugin_data()
               --                              and the then@see "plugin_row_meta"end; filter for the list
               --                              of possible values.
               -- @param string   context     The plugin context. By default this can include "all",
               --                              "active", "inactive", "recently_activated", "upgrade",
               --                              "mustuse", "dropins", and "search".
               --
            Actions := Apply_Filters ("plugin_action_links_" & Plugin_File, Actions, Plugin_File, Plugin_Data, Context);

         end if;

         declare
            Class : UString := +(if Is_Active then "active" else "inactive");

            Checkbox_Id : constant String :=
              "checkbox_" & Php.Misc.MD5 (Plugin_File);

            Checkbox : UString;
         begin
            if
               Restrict_Network_Active or else
               Restrict_Network_Only or else
               In_List (-Globals.Global_Status, ["mustuse", "dropins"], True) or else
               not Compatible_PHP
            then
               Checkbox := +"";
            else
               Checkbox :=
                 +Sprintf (
                    "<label class=""screen-reader-text"" for=""%1s"">%2s</label>" &
                    "<input type=""checkbox"" name=""checked[]"" value=""%3s"" id=""%1s"" />",
                    [
                      1 => Checkbox_Id,
                      -- translators: %s: Plugin name.
                      2 => Sprintf (abs "Select %s", [Get_As_String (Plugin_Data, "Name")]),
                      3 => ESC_Attr (Plugin_File)
                    ]
                  );
            end if;

            if "dropins" /= Context then
               Description := +"<p>" & (if Get_As_String (Plugin_Data, "Description") /= "" then Get_As_String (Plugin_Data, "Description") else "&nbsp;") & "</p>";
               Plugin_Name := +Get_As_String (Plugin_Data, "Name");
            end if;

            if
              (not Empty (Globals.Global_Totals, "upgrade") and then
              not Empty (Plugin_Data, "update")) or else
              not Compatible_PHP or else not Compatible_Wp
            then
               Append (Class, " update");
            end if;

            declare
               Paused : constant Boolean :=
                 not Screen.In_Admin ("network") and then
                 Is_Plugin_Paused (Plugin_File);
            begin
               if Paused then
                  Append (Class, " paused");
               end if;

               if Is_Uninstallable_Plugin (Plugin_File) then
                  Append (Class, " is-uninstallable");
               end if;

               Printf (
                 "<tr class=""%s"" data-slug=""%s"" data-plugin=""%s"">",
                 [
                   1 => ESC_Attr (-Class),
                   2 => ESC_Attr (Plugin_Slug),
                   3 => ESC_Attr (Plugin_File)
                 ]
               );

               declare
                  List : constant Columns_Type := This.Get_Column_Info;

                  Columns  : constant Array_Type := List.Columns;
                  Hidden   : constant Array_Type := List.Hidden;
--                Sortable : constant Array_Type := List.Sortable;
--                Primary  : constant Ustring    := List.Primary;

                  Auto_Updates : constant Array_Type :=
                    As_Array (Get_Site_Option ("auto_update_plugins",
                                               From_Array (Empty_Array)));

--                Available_Updates : Duration := Get_Site_Transient ("update_plugins"); -- XXX used?
               begin
                  for A in Columns.Iterate loop
                     declare
                        Column_Name         : constant String     := Key (A);
--                      Column_Display_Name : constant Multi_Type := Element (A);
                        Extra_Classes       : UString;
                        Classes             : UString;
                     begin
                        Extra_Classes := +"";
                        if In_Array (Column_Name, Hidden, True) then
                           Extra_Classes := +" hidden";
                        end if;

                        if Column_Name in "cb" then
                           Echo ("<th scope=""row"" class=""check-column"">checkbox</th>");

                        elsif Column_Name in "name" then
                           Echo ("<td class=""plugin-title column-primary""><strong>" & (-Plugin_Name) & "</strong>");
                           Echo (This.Row_Actions (Actions, True));
                           Echo ("</td>");

                        elsif Column_Name in "description" then
                           Classes := +"column-description desc";

                           Echo ("<td class=""classes" & (-Extra_Classes) & " "">" &
                                 "<div class=""plugin-description"">" &
                                 (-Description) & "</div>" &
                                 "<div class=""class second plugin-version-author-uri"">");

                           declare
                              Plugin_Meta : UString; -- Array_Type;
                           begin
                              if not Empty (Plugin_Data, "Version") then
                                 -- translators: %s: Plugin version number.
                                 Append (Plugin_Meta, Sprintf (abs "Version %s", [Get_As_String (Plugin_Data, "Version")]));
                              end if;

                              if not Empty (Plugin_Data, "Author") then
                                 declare
                                    Author : UString := +Get_As_String (Plugin_Data, "Author");
                                 begin
                                    if not Empty (Plugin_Data, "AuthorURI") then
                                       Author := +"<a href=""""" & Get_As_String (Plugin_Data, "AuthorURI") & """>" & Get_As_String (Plugin_Data, "Author") & "</a>";
                                    end if;
                                    -- translators: %s: Plugin author name.
                                    Append (Plugin_Meta, Sprintf (abs "By %s", [-Author]));
                                 end;
                              end if;

                              -- Details link using API info, if available.
                              if
                                Isset (Plugin_Data, "slug") and then
                                Current_User_Can ("install_plugins")
                              then
                                 Append (Plugin_Meta, Sprintf (
                                   "<a href=""%s"" class=""thickbox open-plugin-details-modal"" aria-label=""%s"" data-title=""%s"">%s</a>",
                                   [
                                     1 => ESC_URL (
                                         Network_Admin_URL (
                                           "plugin-install.php?tab=plugin-information&plugin=" & Get_As_String (Plugin_Data, "slug") &
                                           "&TB_iframe=true&width=600&height=550"
                                         )
                                       ),
                                     -- translators: %s: Plugin name.
                                     2 => ESC_Attr (Sprintf (abs "More information about %s", [-Plugin_Name])),
                                     3 => ESC_Attr (-Plugin_Name),
                                     4 => abs "View details"
                                   ]
                                 ));

                              elsif not Empty (Plugin_Data, "PluginURI") then
                                 declare
                                    -- translators: %s: Plugin name.
                                    Aria_Label : constant String := Sprintf (abs "Visit plugin site for %s", [-Plugin_Name]);

                                 begin
                                    Append (Plugin_Meta, Sprintf (
                                      "<a href=""%s"" aria-label=""%s"">%s</a>",
                                      [
                                        1 => ESC_URL (Get_As_String (Plugin_Data, "PluginURI")),
                                        2 => ESC_Attr (Aria_Label),
                                        3 => abs "Visit plugin site"
                                      ]
                                    ));
                                 end;
                              end if;

                              --
                              -- Filters the array of row meta for each plugin in the Plugins list table.
                              --
                              -- @since 2.8.0
                              --
                              -- @param string[] plugin_meta An array of the plugin"s metadata, including
                              --                              the version, author, author URI, and plugin URI.
                              -- @param string   plugin_file Path to the plugin file relative to the plugins directory.
                              -- @param array    plugin_data {
                              --     An array of plugin data.
                              --
                              --     @type string   id               Plugin ID, e.g. `w.org/plugins/[plugin-name]`.
                              --     @type string   slug             Plugin slug.
                              --     @type string   plugin           Plugin basename.
                              --     @type string   new_version      New plugin version.
                              --     @type string   url              Plugin URL.
                              --     @type string   package          Plugin update package URL.
                              --     @type string[] icons            An array of plugin icon URLs.
                              --     @type string[] banners          An array of plugin banner URLs.
                              --     @type string[] banners_rtl      An array of plugin RTL banner URLs.
                              --     @type string   requires         The version of WordPress which the plugin requires.
                              --     @type string   tested           The version of WordPress the plugin is tested against.
                              --     @type string   requires_php     The version of PHP which the plugin requires.
                              --     @type string   upgrade_notice   The upgrade notice for the new plugin version.
                              --     @type bool     update-supported Whether the plugin supports updates.
                              --     @type string   Name             The human-readable name of the plugin.
                              --     @type string   PluginURI        Plugin URI.
                              --     @type string   Version          Plugin version.
                              --     @type string   Description      Plugin description.
                              --     @type string   Author           Plugin author.
                              --     @type string   AuthorURI        Plugin author URI.
                              --     @type string   TextDomain       Plugin textdomain.
                              --     @type string   DomainPath       Relative path to the plugin"s .mo file(s).
                              --     @type bool     Network          Whether the plugin can only be activated network-wide.
                              --     @type string   RequiresWP       The version of WordPress which the plugin requires.
                              --     @type string   RequiresPHP      The version of PHP which the plugin requires.
                              --     @type string   UpdateURI        ID of the plugin for update purposes, should be a URI.
                              --     @type string   Title            The human-readable title of the plugin.
                              --     @type string   AuthorName       Plugin author"s name.
                              --     @type bool     update           Whether there"s an available update. Default null.
                              -- }
                              -- @param string   status      Status filter currently applied to the plugin list. Possible
                              --                              values are: "all", "active", "inactive", "recently_activated",
                              --                              "upgrade", "mustuse", "dropins", "search", "paused",
                              --                              "auto-update-enabled", "auto-update-disabled".
                              --
                              Plugin_Meta := +Apply_Filters ("plugin_row_meta", -Plugin_Meta, Plugin_File, Plugin_Data, -Globals.Global_Status);

                              Echo (Implode (" | ", -Plugin_Meta));

                              Echo ("</div>");
                           end;

                           if Paused then
                              declare
                                 Notice_Text : constant String := abs "This plugin failed to load properly and is paused during recovery mode.";
                              begin
                                 Printf ("<p><span class=""dashicons dashicons-warning""></span> <strong>%s</strong></p>", [Notice_Text]);
                              end;

                              declare
                                 Error : constant List_Type := Wp_Get_Plugin_Error (Plugin_File);
                              begin
                                 if not Error.Is_Empty then
      --                         if False /= Error then
                                    Printf ("<div class=""error-display""><p>%s</p></div>",
                                            [Wp_Get_Extension_Error_Description (Error)]);
                                 end if;
                              end;
                           end if;

                           Echo ("</td>");

                        elsif Column_Name in "auto-updates" then
                           if not This.Show_Autoupdates then
                              goto Break;
                           end if;

                           Echo ("<td class=""column-auto-updates" & (-Extra_Classes) & ">");
                           declare
                              HTML : UString; -- Array_Type;
                              Text : UString;
                              Action : UString;
                              Time_Class : UString;
                           begin
                              if Isset (Plugin_Data, "auto-update-forced") then
                                 if
                                   As_Boolean (Get (Plugin_Data, "auto-update-forced"))
                                 then
                                    -- Forced on.
                                    Text := +abs "Auto-updates enabled";
                                 else
                                    Text := +abs "Auto-updates disabled";
                                 end if;
                                 Action     := +"unavailable";
                                 Time_Class := +" hidden";

                              elsif Empty (Plugin_Data, "update-supported") then
                                 Text       := +"";
                                 Action     := +"unavailable";
                                 Time_Class := +" hidden";

                              elsif In_Array (Plugin_File, Auto_Updates, True) then
                                 Text       := +abs "Disable auto-updates";
                                 Action     := +"disable";
                                 Time_Class := +"";

                              else
                                 Text       := +abs "Enable auto-updates";
                                 Action     := +"enable";
                                 Time_Class := +" hidden";
                              end if;

                              declare
                                 Query_Args : constant Array_Type :=
                                   To_Array_Type ([
                                     Build ("action",        (-Action) & "-auto-update"),
                                     Build ("plugin",        Plugin_File),
                                     Build ("paged",         Globals.Global_Page),
                                     Build ("plugin_status", -Globals.Global_Status)
                                   ]);

                                 URL : constant String := Add_Query_Arg (Query_Args, "plugins.php");
                              begin
                                 if "unavailable" = Action then
                                    Append (HTML, "<span class=""label"">" & Text & "</span>");
                                 else
                                    Append (HTML, Sprintf (
                                      "<a href=""%s"" class=""toggle-auto-update aria-button-if-js"" data-wp-action=""%s"">",
                                      [
                                        1 => Wp_Nonce_URL (URL, "updates"),
                                        2 => -Action
                                      ]
                                    ));

                                    Append (HTML, "<span class=""dashicons dashicons-update spin hidden"" aria-hidden=""true""></span>");
                                    Append (HTML, "<span class=""label"">" & Text & "</span>");
                                    Append (HTML, "</a>");
                                 end if;
                              end;

                              if not Empty (Plugin_Data, "update") then
                                 Append (HTML, Sprintf (
                                    "<div class=""auto-update-time%s"">%s</div>",
                                    [
                                      1 => -Time_Class,
                                      2 => Wp_Get_Auto_Update_Message
                                    ]
                                  ));
                              end if;

                              declare
                                 HTML_2 : constant String := Implode ("", -HTML);
                              begin
                                 --
                                 -- Filters the HTML of the auto-updates setting for each plugin in the Plugins list table.
                                 --
                                 -- @since 5.5.0
                                 --
                                 -- @param string html        The HTML of the plugin"s auto-update column content,
                                 --                            including toggle auto-update action links and
                                 --                            time to next update.
                                 -- @param string plugin_file Path to the plugin file relative to the plugins directory.
                                 -- @param array  plugin_data An array of plugin data. See get_plugin_data()
                                 --                            and the then@see "plugin_row_meta"end; filter for the list
                                 --                            of possible values.
                                 --
                                 Echo (Apply_Filters ("plugin_auto_update_setting_html", HTML_2, Plugin_File, Plugin_Data));

                                 Echo ("<div class=""notice notice-error notice-alt inline hidden""><p></p></div>");
                                 Echo ("</td>");
                              end;
                           end;
                           << Break >>

                        else
                           Classes := +"column_name column-column_name class";

                           Echo ("<td class=""classes" & (-Extra_Classes) & """>");

                           --
                           -- Fires inside each custom column of the Plugins list table.
                           --
                           -- @since 3.1.0
                           --
                           -- @param string column_name Name of the column.
                           -- @param string plugin_file Path to the plugin file relative to the plugins directory.
                           -- @param array  plugin_data An array of plugin data. See get_plugin_data()
                           --                            and the then@see "plugin_row_meta"end; filter for the list
                           --                            of possible values.
                           --
                           Do_Action ("manage_plugins_custom_column", Column_Name, Plugin_File, Plugin_Data);

                           Echo ("</td>");
                        end if; -- Case
                     end;
                  end loop;
               end;
            end;
            Echo ("</tr>");

            if not Compatible_PHP or else not Compatible_Wp then
               Printf (
                 "<tr class=""plugin-update-tr"">" &
                 "<td colspan=""%s"" class=""plugin-update colspanchange"">" &
                 "<div class=""update-message notice inline notice-error notice-alt""><p>",
                 [1 => ESC_Attr (Helpers.Image (This.Get_Column_Count))]
               );

               if not Compatible_PHP and then not Compatible_Wp then
                  X_E ("This plugin does not work with your versions of WordPress and PHP.");
                  if Current_User_Can ("update_core") and then Current_User_Can ("update_php") then
                     Printf (
                       -- translators: 1: URL to WordPress Updates screen, 2: URL to Update PHP page.
                       " " & abs "<a href=""%1s"">Please update WordPress</a>, and then <a href=""%2s"">learn more about updating PHP</a>.",
                       [
                         1 => Self_Admin_URL ("update-core.php"),
                         2 => ESC_URL (Wp_Get_Update_PHP_URL)
                       ]
                     );
                     Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");

                  elsif Current_User_Can ("update_core") then
                     Printf (
                       -- translators: %s: URL to WordPress Updates screen.
                       " " & abs "<a href=""%s"">Please update WordPress</a>.",
                       [1 => Self_Admin_URL ("update-core.php")]
                     );

                  elsif Current_User_Can ("update_php") then
                     Printf (
                       -- translators: %s: URL to Update PHP page.
                       " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                       [1 => ESC_URL (Wp_Get_Update_PHP_URL)]
                     );
                     Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
                  end if;

               elsif not Compatible_Wp then
                  X_E ("This plugin does not work with your version of WordPress.");
                  if Current_User_Can ("update_core") then
                     Printf (
                       -- translators: %s: URL to WordPress Updates screen.
                       " " & abs "<a href=""%s"">Please update WordPress</a>.",
                       [1 => Self_Admin_URL ("update-core.php")]
                     );
                  end if;

               elsif not Compatible_PHP then
                  X_E ("This plugin does not work with your version of PHP.");
                  if Current_User_Can ("update_php") then
                     Printf (
                        -- translators: %s: URL to Update PHP page.
                        " " & abs "<a href=""%s"">Learn more about updating PHP</a>.",
                        [1 => ESC_URL (Wp_Get_Update_PHP_URL)]
                     );
                     Wp_Update_PHP_Annotation ("</p><p><em>", "</em>");
                  end if;
               end if;

               Echo ("</p></div></td></tr>");
            end if;

            --
            -- Fires after each row in the Plugins list table.
            --
            -- @since 2.3.0
            -- @since 5.5.0 Added "auto-update-enabled" and "auto-update-disabled"
            --              to possible values for `status`.
            --
            -- @param string plugin_file Path to the plugin file relative to the plugins directory.
            -- @param array  plugin_data An array of plugin data. See get_plugin_data()
            --                            and the then@see "plugin_row_meta"end; filter for the list
            --                            of possible values.
            -- @param string status      Status filter currently applied to the plugin list.
            --                            Possible values are: "all", "active", "inactive",
            --                            "recently_activated", "upgrade", "mustuse", "dropins",
            --                            "search", "paused", "auto-update-enabled", "auto-update-disabled".
            --
            Do_Action ("after_plugin_row", Plugin_File, Plugin_Data, -Globals.Global_Status);

            --
            -- Fires after each specific row in the Plugins list table.
            --
            -- The dynamic portion of the hook name, `plugin_file`, refers to the path
            -- to the plugin file, relative to the plugins directory.
            --
            -- @since 2.7.0
            -- @since 5.5.0 Added "auto-update-enabled" and "auto-update-disabled"
            --              to possible values for `status`.
            --
            -- @param string plugin_file Path to the plugin file relative to the plugins directory.
            -- @param array  plugin_data An array of plugin data. See get_plugin_data()
            --                            and the then@see "plugin_row_meta"end; filter for the list
            --                            of possible values.
            -- @param string status      Status filter currently applied to the plugin list.
            --                            Possible values are: "all", "active", "inactive",
            --                            "recently_activated", "upgrade", "mustuse", "dropins",
            --                            "search", "paused", "auto-update-enabled", "auto-update-disabled".
            --
            Do_Action ("after_plugin_row_" & Plugin_File, Plugin_File, Plugin_Data, -Globals.Global_Status);
         end;
      end;
   end Single_Row;

   -----------------------------
   -- Get_Primary_Column_Name --
   -----------------------------

   function Get_Primary_Column_Name (This : Wp_Plugins_List_Table'Class)
                                     return String
   is
   begin
      Logging.Log ("get_primary_column_name", "");
      return "name";
   end Get_Primary_Column_Name;

end Class_Plugins_List_Tables;
