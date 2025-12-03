--
-- WordPress Customize Widgets classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.9.0
--

with Ada.Strings.Unbounded;

with Arrays;
with Hb_Common;

with Cust_Class_Wp_Customize_Partials;

with Inc_Class_Wp_Dependencies;

limited with Inc_Class_Wp_Customize_Managers;

package Inc_Class_Wp_Customize_Widgets
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Hb_Common;

   Capability_Error : exception;

   Global_Wp_Registered_Widgets  : Array_Type;
   Global_Wp_Scripts       : Inc_Class_Wp_Dependencies.Wp_Dependencies; -- Array_Type;
   Global_Wp_Registered_Sidebars : Array_Type;
   Global_Sidebars_Widgets : Array_Type;

   --
   -- Customize Widgets class.
   --
   -- Implements widget management in the Customizer.
   --
   -- @since 3.9.0
   --
   -- @see WP_Customize_Manager
   --
   -- #[AllowDynamicProperties]
   type Wp_Customize_Widgets is tagged
      record
         --
         -- WP_Customize_Manager instance.
         --
         -- @since 3.9.0
         -- @var WP_Customize_Manager
         --
--       Manager : access Wp_Customize_Manager;
         Manager : access Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager;
--       Manager : Inc_Class_Wp_Customize_Managers_Indirect.Customize_Manager;
--       Manager : Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager;

         --
         -- All id_bases for widgets defined in core.
         --
         -- @since 3.9.0
         -- @var array
         --
         -- protected
         Core_Widget_Id_Bases : List_Type := To_List (List => (
                +"archives",
                +"calendar",
                +"categories",
                +"custom_html",
                +"links",
                +"media_audio",
                +"media_image",
                +"media_video",
                +"meta",
                +"nav_menu",
                +"pages",
                +"recent-comments",
                +"recent-posts",
                +"rss",
                +"search",
                +"tag_cloud",
                +"text"
         ));

         --
         -- @since 3.9.0
         -- @var array
         --
         -- protected
         Rendered_Sidebars : Array_Type;

         --
         -- @since 3.9.0
         -- @var array
         --
         -- protected
         Rendered_Widgets : Array_Type;

         --
         -- @since 3.9.0
         -- @var array
         --
         -- protected
         Old_Sidebars_Widgets : Array_Type;

         --
         -- Mapping of widget ID base to whether it supports selective refresh.
         --
         -- @since 4.5.0
         -- @var array
         --
         -- protected
         Selective_Refreshable_Widgets : Array_Type;

         --
         -- Mapping of setting type to setting ID pattern.
         --
         -- @since 4.2.0
         -- @var array
         --
         -- protected
         Setting_Id_Patterns : Array_Type := To_Array (List => (
               Build ("widget_instance",
                      "/^widget_(?P<id_base>.+?)(?:\[(?P<widget_number>\d+)\])?/"),
               Build ("sidebar_widgets",
                      "/^sidebars_widgets\[(?P<sidebar_id>.+?)\]/")
        ));

   --
   -- These were originally member of the file and not the object (jq)
   --

   --
   -- Keep track of the number of times that dynamic_sidebar() was called for a given
   -- sidebar index.
   --
   -- This helps facilitate the uncommon scenario where a single sidebar is rendered
   -- multiple times on a template.
   --
   -- @since 4.5.0
   -- @var array
   --
--   protected
         Sidebar_Instance_Count : Array_Type; --  = array();

   --
   -- The current request"s sidebar_instance_number context.
   --
   -- @since 4.5.0
   -- @var int|null
   --
--   protected
         Context_Sidebar_Instance_Number_Set : Boolean := False;
         Context_Sidebar_Instance_Number     : Integer;

   --
   -- Current sidebar ID being rendered.
   --
   -- @since 4.5.0
   -- @var array
   --
--   protected
         Current_Dynamic_Sidebar_Id_Stack : List_Type; -- Array_Type;

   --
   -- List of the tag names seen for before_widget strings.
   --
   -- This is used in the {@see "filter_wp_kses_allowed_html"} filter to ensure
   -- that the data-* attributes can be allowed.
   --
   -- @since 4.5.0
   -- @var array
   --
--   protected
         Before_Widget_Tags_Seen : Array_Type;

         --
         -- Current sidebar being rendered.
         --
         -- @since 4.5.0
         -- @var string|null
         --
         -- protected
         Rendering_Widget_Id : Unbounded_String;

         --
         -- Current widget being rendered.
         --
         -- @since 4.5.0
         -- @var string|null
         --
         -- protected
         Rendering_Sidebar_Id : Unbounded_String;

      end record;

   --
   -- Initial loader.
   --
   -- @since 3.9.0
   --
   -- @param WP_Customize_Manager manager Customizer bootstrap instance.
   --
   function X_Construct
               (Manager : access Inc_Class_Wp_Customize_Managers.Wp_Customize_Manager)
                return Wp_Customize_Widgets;

   --
   -- List whether each registered widget can be use selective refresh.
   --
   -- If the theme does not support the customize-selective-refresh-widgets feature,
   -- then this will always return an empty array.
   --
   -- @since 4.5.0
   --
   -- @global WP_Widget_Factory wp_widget_factory
   --
   -- @return array Mapping of id_base to support. If theme doesn"t support
   --               selective refresh, an empty array is returned.
   --
   function Get_Selective_Refreshable_Widgets (This : in out Wp_Customize_Widgets)
                                               return Array_Type;
        --         global wp_widget_factory;
        --         if ( ! current_theme_supports( "customize-selective-refresh-widgets" ) ) then
        --                 return array();
        --         end;
        --         if ( ! isset( this.selective_refreshable_widgets ) ) then
        --                 this.selective_refreshable_widgets = array();
        --                 foreach ( wp_widget_factory.widgets as wp_widget ) then
        --                         this.selective_refreshable_widgets[ wp_widget.id_base ] = ! empty( wp_widget.widget_options["customize_selective_refresh"] );
        --                 end;
        --         end;
        --         return this.selective_refreshable_widgets;
        -- end;

   --
   -- Determines if a widget supports selective refresh.
   --
   -- @since 4.5.0
   --
   -- @param string id_base Widget ID Base.
   -- @return bool Whether the widget can be selective refreshed.
   --
   function Is_Widget_Selective_Refreshable (This    : in out Wp_Customize_Widgets;
                                             Id_Base : String)
                                             return Boolean;
        --         selective_refreshable_widgets = this.get_selective_refreshable_widgets();
        --         return ! empty( selective_refreshable_widgets[ id_base ] );
        -- end;

   --
   -- Retrieves the widget setting type given a setting ID.
   --
   -- @since 4.2.0
   --
   -- @param string setting_id Setting ID.
   -- @return string|void Setting type.
   --
   -- protected
   function Get_Setting_Type (This       : Wp_Customize_Widgets;
                              Setting_Id : String)
                              return String;
        --         static cache = array();
        --         if ( isset( cache[ setting_id ] ) ) then
        --                 return cache[ setting_id ];
        --         end;
        --         foreach ( this.setting_id_patterns as type => pattern ) then
        --                 if ( preg_match( pattern, setting_id ) ) then
        --                         cache[ setting_id ] = type;
        --                         return type;
        --                 end;
        --         end;
        -- end;

   --
   -- Inspects the incoming customized data for any widget settings, and dynamically
   -- adds them up-front so widgets will be initialized properly.
   --
   -- @since 4.2.0
   --
   procedure Register_Settings (This : in out Wp_Customize_Widgets);

   --
   -- Determines the arguments for a dynamically-created setting.
   --
   -- @since 4.2.0
   --
   -- @param false|array args       The arguments to the WP_Customize_Setting
   --                                constructor.
   -- @param string      setting_id ID for dynamic setting, usually coming from
   --                               `_POST["customized"]`.
   -- @return array|false Setting arguments, false otherwise.
   --
   function Filter_Customize_Dynamic_Setting_Args
              (This       : in out Wp_Customize_Widgets;
               Args       : Array_Type;
               Setting_Id : String)
               return Array_Type;

   procedure Filter_Customize_Dynamic_Setting_Args
               (This : in out Wp_Customize_Widgets);

        -- --
        -- -- Retrieves an unslashed post value or return a default.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @param string name          Post value.
        -- -- @param mixed  default_value Default post value.
        -- -- @return mixed Unslashed post value or default value.
        -- --
        -- protected function get_post_value( name, default_value = null ) then
        --         if ( ! isset( _POST[ name ] ) ) then
        --                 return default_value;
        --         end;

        --         return wp_unslash( _POST[ name ] );
        -- end;

   --
   -- Override sidebars_widgets for theme switch.
   --
   -- When switching a theme via the Customizer, supply any previously-configured
   -- sidebars_widgets from the target theme as the initial sidebars_widgets
   -- setting. Also store the old theme"s existing settings so that they can
   -- be passed along for storing in the sidebars_widgets theme_mod when the
   -- theme gets switched.
   --
   -- @since 3.9.0
   --
   -- @global array sidebars_widgets
   -- @global array _wp_sidebars_widgets
   --
   procedure Override_Sidebars_Widgets_For_Theme_Switch
               (This : in out Wp_Customize_Widgets);

   --
   -- Filters old_sidebars_widgets_data Customizer setting.
   --
   -- When switching themes, filter the Customizer setting old_sidebars_widgets_data
   -- to supply initial $sidebars_widgets before they were overridden by
   -- retrieve_widgets(). The value for old_sidebars_widgets_data gets set in the old
   -- theme's sidebars_widgets theme_mod.
   --
   -- @since 3.9.0
   --
   -- @see WP_Customize_Widgets::handle_theme_switch()
   --
   -- @param array $old_sidebars_widgets
   -- @return array
   --
   function Filter_Customize_Value_Old_Sidebars_Widgets_Data
              (This                 : Wp_Customize_Widgets;
               Old_Sidebars_Widgets : Array_Type)
               return Array_Type;

   procedure Filter_Customize_Value_Old_Sidebars_Widgets_Data
               (This : in out Wp_Customize_Widgets);

   --
   -- Filters sidebars_widgets option for theme switch.
   --
   -- When switching themes, the retrieve_widgets() function is run when the
   -- Customizer initializes, and then the new sidebars_widgets here get supplied as
   -- the default value for the sidebars_widgets option.
   --
   -- @since 3.9.0
   --
   -- @see WP_Customize_Widgets::handle_theme_switch()
   -- @global array sidebars_widgets
   --
   -- @param array sidebars_widgets
   -- @return array
   --
   function Filter_Option_Sidebars_Widgets_For_Theme_Switch
              (This             : Wp_Customize_Widgets;
               Sidebars_Widgets : Array_Type)
               return Array_Type;

   procedure Filter_Option_Sidebars_Widgets_For_Theme_Switch
              (This : in out Wp_Customize_Widgets);
        --         sidebars_widgets                  = GLOBALS["sidebars_widgets"];
        --         sidebars_widgets["array_version"] = 3;
        --         return sidebars_widgets;
        -- end;

   --
   -- Ensures all widgets get loaded into the Customizer.
   --
   -- Note: these actions are also fired in wp_ajax_update_widget().
   --
   -- @since 3.9.0
   --
   procedure Customize_Controls_Init (This : in out Wp_Customize_Widgets);

   --
   -- Ensures widgets are available for all types of previews.
   --
   -- When in preview, hook to {@see "customize_register"} for settings after
   -- WordPress is loaded so that all filters have been initialized (e.g. Widget
   -- Visibility).
   --
   -- @since 3.9.0
   --
   procedure Schedule_Customize_Register (This : in out Wp_Customize_Widgets);

   --
   -- Registers Customizer settings and controls for all sidebars and widgets.
   --
   -- @since 3.9.0
   --
   -- @global array wp_registered_widgets
   -- @global array wp_registered_widget_controls
   -- @global array wp_registered_sidebars
   --
   procedure Customize_Register (This : in out Wp_Customize_Widgets);
        --         global wp_registered_widgets, wp_registered_widget_controls, wp_registered_sidebars;

        --         use_widgets_block_editor = wp_use_widgets_block_editor();

        --         add_filter( "sidebars_widgets", array( this, "preview_sidebars_widgets" ), 1 );

        --         sidebars_widgets = array_merge(
        --                 array( "wp_inactive_widgets" => array() ),
        --                 array_fill_keys( array_keys( wp_registered_sidebars ), array() ),
        --                 wp_get_sidebars_widgets()
        --         );

        --         new_setting_ids = array();

        --         /*
        --         -- Register a setting for all widgets, including those which are active,
        --         -- inactive, and orphaned since a widget may get suppressed from a sidebar
        --         -- via a plugin (like Widget Visibility).
        --         --
        --         foreach ( array_keys( wp_registered_widgets ) as widget_id ) then
        --                 setting_id   = this.get_setting_id( widget_id );
        --                 setting_args = this.get_setting_args( setting_id );
        --                 if ( ! this.manager.get_setting( setting_id ) ) then
        --                         this.manager.add_setting( setting_id, setting_args );
        --                 end;
        --                 new_setting_ids[] = setting_id;
        --         end;

        --         /*
        --         -- Add a setting which will be supplied for the theme"s sidebars_widgets
        --         -- theme_mod when the theme is switched.
        --         --
        --         if ( ! this.manager.is_theme_active() ) then
        --                 setting_id   = "old_sidebars_widgets_data";
        --                 setting_args = this.get_setting_args(
        --                         setting_id,
        --                         array(
        --                                 "type"  => "global_variable",
        --                                 "dirty" => true,
        --                         )
        --                 );
        --                 this.manager.add_setting( setting_id, setting_args );
        --         end;

        --         this.manager.add_panel(
        --                 "widgets",
        --                 array(
        --                         "type"                     => "widgets",
        --                         "title"                    => __( "Widgets" ),
        --                         "description"              => __( "Widgets are independent sections of content that can be placed into widgetized areas provided by your theme (commonly called sidebars)." ),
        --                         "priority"                 => 110,
        --                         "active_callback"          => array( this, "is_panel_active" ),
        --                         "auto_expand_sole_section" => true,
        --                         "theme_supports"           => "widgets",
        --                 )
        --         );

        --         foreach ( sidebars_widgets as sidebar_id => sidebar_widget_ids ) then
        --                 if ( empty( sidebar_widget_ids ) ) then
        --                         sidebar_widget_ids = array();
        --                 end;

        --                 is_registered_sidebar = is_registered_sidebar( sidebar_id );
        --                 is_inactive_widgets   = ( "wp_inactive_widgets" === sidebar_id );
        --                 is_active_sidebar     = ( is_registered_sidebar && ! is_inactive_widgets );

        --                 // Add setting for managing the sidebar's widgets.
        --                 if ( is_registered_sidebar || is_inactive_widgets ) then
        --                         setting_id   = sprintf( "sidebars_widgets[%s]", sidebar_id );
        --                         setting_args = this.get_setting_args( setting_id );
        --                         if ( ! this.manager.get_setting( setting_id ) ) then
        --                                 if ( ! this.manager.is_theme_active() ) then
        --                                         setting_args["dirty"] = true;
        --                                 end;
        --                                 this.manager.add_setting( setting_id, setting_args );
        --                         end;
        --                         new_setting_ids[] = setting_id;

        --                         // Add section to contain controls.
        --                         section_id = sprintf( "sidebar-widgets-%s", sidebar_id );
        --                         if ( is_active_sidebar ) then

        --                                 section_args = array(
        --                                         "title"      => wp_registered_sidebars[ sidebar_id ]["name"],
        --                                         "priority"   => array_search( sidebar_id, array_keys( wp_registered_sidebars ), true ),
        --                                         "panel"      => "widgets",
        --                                         "sidebar_id" => sidebar_id,
        --                                 );

        --                                 if ( use_widgets_block_editor ) then
        --                                         section_args["description"] = "";
        --                                 end; else then
        --                                         section_args["description"] = wp_registered_sidebars[ sidebar_id ]["description"];
        --                                 end;

        --                                 --
        --                                 -- Filters Customizer widget section arguments for a given sidebar.
        --                                 --
        --                                 -- @since 3.9.0
        --                                 --
        --                                 -- @param array      section_args Array of Customizer widget section arguments.
        --                                 -- @param string     section_id   Customizer section ID.
        --                                 -- @param int|string sidebar_id   Sidebar ID.
        --                                 --
        --                                 section_args = apply_filters( "customizer_widgets_section_args", section_args, section_id, sidebar_id );

        --                                 section = new WP_Customize_Sidebar_Section( this.manager, section_id, section_args );
        --                                 this.manager.add_section( section );

        --                                 if ( use_widgets_block_editor ) then
        --                                         control = new WP_Sidebar_Block_Editor_Control(
        --                                                 this.manager,
        --                                                 setting_id,
        --                                                 array(
        --                                                         "section"     => section_id,
        --                                                         "sidebar_id"  => sidebar_id,
        --                                                         "label"       => section_args["title"],
        --                                                         "description" => section_args["description"],
        --                                                 )
        --                                         );
        --                                 end; else then
        --                                         control = new WP_Widget_Area_Customize_Control(
        --                                                 this.manager,
        --                                                 setting_id,
        --                                                 array(
        --                                                         "section"    => section_id,
        --                                                         "sidebar_id" => sidebar_id,
        --                                                         "priority"   => count( sidebar_widget_ids ), // place "Add Widget" and "Reorder" buttons at end.
        --                                                 )
        --                                         );
        --                                 end;

        --                                 this.manager.add_control( control );

        --                                 new_setting_ids[] = setting_id;
        --                         end;
        --                 end;

        --                 if ( ! use_widgets_block_editor ) then
        --                         // Add a control for each active widget (located in a sidebar).
        --                         foreach ( sidebar_widget_ids as i => widget_id ) then

        --                                 // Skip widgets that may have gone away due to a plugin being deactivated.
        --                                 if ( ! is_active_sidebar || ! isset( wp_registered_widgets[ widget_id ] ) ) then
        --                                         continue;
        --                                 end;

        --                                 registered_widget = wp_registered_widgets[ widget_id ];
        --                                 setting_id        = this.get_setting_id( widget_id );
        --                                 id_base           = wp_registered_widget_controls[ widget_id ]["id_base"];

        --                                 control = new WP_Widget_Form_Customize_Control(
        --                                         this.manager,
        --                                         setting_id,
        --                                         array(
        --                                                 "label"          => registered_widget["name"],
        --                                                 "section"        => section_id,
        --                                                 "sidebar_id"     => sidebar_id,
        --                                                 "widget_id"      => widget_id,
        --                                                 "widget_id_base" => id_base,
        --                                                 "priority"       => i,
        --                                                 "width"          => wp_registered_widget_controls[ widget_id ]["width"],
        --                                                 "height"         => wp_registered_widget_controls[ widget_id ]["height"],
        --                                                 "is_wide"        => this.is_wide_widget( widget_id ),
        --                                         )
        --                                 );
        --                                 this.manager.add_control( control );
        --                         end;
        --                 end;
        --         end;

        --         if ( this.manager.settings_previewed() ) then
        --                 foreach ( new_setting_ids as new_setting_id ) then
        --                         this.manager.get_setting( new_setting_id ).preview();
        --                 end;
        --         end;
        -- end;

   --
   -- Determines whether the widgets panel is active, based on whether there are
   -- sidebars registered.
   --
   -- @since 4.4.0
   --
   -- @see WP_Customize_Panel::active_callback
   --
   -- @global array wp_registered_sidebars
   -- @return bool Active.
   --
   function Is_Panel_Active (This : Wp_Customize_Widgets)
                             return Boolean;
        --         global wp_registered_sidebars;
        --         return ! empty( wp_registered_sidebars );
        -- end;
   procedure Is_Panel_Active (This : in out Wp_Customize_Widgets)
   is null;

   --
   -- Converts a widget_id into its corresponding Customizer setting ID (option name).
   --
   -- @since 3.9.0
   --
   -- @param string widget_id Widget ID.
   -- @return string Maybe-parsed widget ID.
   --
   function Get_Setting_Id (This      : Wp_Customize_Widgets;
                            Widget_Id : String)
                            return String;
        --         parsed_widget_id = this.parse_widget_id( widget_id );
        --         setting_id       = sprintf( "widget_%s", parsed_widget_id["id_base"] );

        --         if ( ! is_null( parsed_widget_id["number"] ) ) then
        --                 setting_id .= sprintf( "[%d]", parsed_widget_id["number"] );
        --         end;
        --         return setting_id;
        -- end;

   --
   -- Determines whether the widget is considered "wide".
   --
   -- Core widgets which may have controls wider than 250, but can still be shown
   -- in the narrow Customizer panel. The RSS and Text widgets in Core, for example,
   -- have widths of 400 and yet they still render fine in the Customizer panel.
   --
   -- This method will return all Core widgets as being not wide, but this can be
   -- overridden with the then@see "is_wide_widget_in_customizer"end; filter.
   --
   -- @since 3.9.0
   --
   -- @global array wp_registered_widget_controls
   --
   -- @param string widget_id Widget ID.
   -- @return bool Whether or not the widget is a "wide" widget.
   --
   function Is_Wide_Widget (This      : Wp_Customize_Widgets;
                            Widget_Id : String)
                            return Boolean;
        --         global wp_registered_widget_controls;

        --         parsed_widget_id = this.parse_widget_id( widget_id );
        --         width            = wp_registered_widget_controls[ widget_id ]["width"];
        --         is_core          = in_array( parsed_widget_id["id_base"], this.core_widget_id_bases, true );
        --         is_wide          = ( width > 250 && ! is_core );

        --         --
        --         -- Filters whether the given widget is considered "wide".
        --         --
        --         -- @since 3.9.0
        --         --
        --         -- @param bool   is_wide   Whether the widget is wide, Default false.
        --         -- @param string widget_id Widget ID.
        --         --
        --         return apply_filters( "is_wide_widget_in_customizer", is_wide, widget_id );
        -- end;

   --
   -- Converts a widget ID into its id_base and number components.
   --
   -- @since 3.9.0
   --
   -- @param string widget_id Widget ID.
   -- @return array Array containing a widget"s id_base and number components.
   --
   function Parse_Widget_Id (This      : Wp_Customize_Widgets;
                             Widget_Id : String)
                             return Array_Type;
        --         parsed = array(
        --                 "number"  => null,
        --                 "id_base" => null,
        --         );

        --         if ( preg_match( "/^(.+)-(\d+)/", widget_id, matches ) ) then
        --                 parsed["id_base"] = matches[1];
        --                 parsed["number"]  = (int) matches[2];
        --         end; else then
        --                 // Likely an old single widget.
        --                 parsed["id_base"] = widget_id;
        --         end;
        --         return parsed;
        -- end;

        -- --
        -- -- Converts a widget setting ID (option path) to its id_base and number components.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @param string setting_id Widget setting ID.
        -- -- @return array|WP_Error Array containing a widget"s id_base and number components,
        -- --                        or a WP_Error object.
        -- --
        -- public function parse_widget_setting_id( setting_id ) then
        --         if ( ! preg_match( "/^(widget_(.+?))(?:\[(\d+)\])?/", setting_id, matches ) ) then
        --                 return new WP_Error( "widget_setting_invalid_id" );
        --         end;

        --         id_base = matches[2];
        --         number  = isset( matches[3] ) ? (int) matches[3] : null;

        --         return compact( "id_base", "number" );
        -- end;

   --
   -- Calls admin_print_styles-widgets.php and admin_print_styles hooks to
   -- allow custom styles from plugins.
   --
   -- @since 3.9.0
   --
   procedure Print_Styles (This : in out Wp_Customize_Widgets);

   --
   -- Calls admin_print_scripts-widgets.php and admin_print_scripts hooks to
   -- allow custom scripts from plugins.
   --
   -- @since 3.9.0
   --
   procedure Print_Scripts (This : in out Wp_Customize_Widgets);

   --
   -- Enqueues scripts and styles for Customizer panel and export data to JavaScript.
   --
   -- @since 3.9.0
   --
   -- @global WP_Scripts wp_scripts
   -- @global array wp_registered_sidebars
   -- @global array wp_registered_widgets
   --
   procedure Enqueue_Scripts (This : in out Wp_Customize_Widgets);

   --
   -- Renders the widget form control templates into the DOM.
   --
   -- @since 3.9.0
   --
   procedure Output_Widget_Control_Templates (This : in out Wp_Customize_Widgets);

   --
   -- Calls admin_print_footer_scripts and admin_print_scripts hooks to
   -- allow custom scripts from plugins.
   --
   -- @since 3.9.0
   --
   procedure Print_Footer_Scripts (This : in out Wp_Customize_Widgets);

   --
   -- Retrieves common arguments to supply when constructing a Customizer setting.
   --
   -- @since 3.9.0
   --
   -- @param string id        Widget setting ID.
   -- @param array  overrides Array of setting overrides.
   -- @return array Possibly modified setting arguments.
   --
   function Get_Setting_Args (This      : in out Wp_Customize_Widgets;
                              Id        : String;
                              Overrides : Array_Type := Empty_Array)
                              return Array_Type;
        --         args = array(
        --                 "type"       => "option",
        --                 "capability" => "edit_theme_options",
        --                 "default"    => array(),
        --         );

        --         if ( preg_match( this.setting_id_patterns["sidebar_widgets"], id, matches ) ) then
        --                 args["sanitize_callback"]    = array( this, "sanitize_sidebar_widgets" );
        --                 args["sanitize_js_callback"] = array( this, "sanitize_sidebar_widgets_js_instance" );
        --                 args["transport"]            = current_theme_supports( "customize-selective-refresh-widgets" ) ? "postMessage" : "refresh";
        --         end; elseif ( preg_match( this.setting_id_patterns["widget_instance"], id, matches ) ) then
        --                 id_base                      = matches["id_base"];
        --                 args["sanitize_callback"]    = function( value ) use ( id_base ) then
        --                         return this.sanitize_widget_instance( value, id_base );
        --                 end;;
        --                 args["sanitize_js_callback"] = function( value ) use ( id_base ) then
        --                         return this.sanitize_widget_js_instance( value, id_base );
        --                 end;;
        --                 args["transport"]            = this.is_widget_selective_refreshable( matches["id_base"] ) ? "postMessage" : "refresh";
        --         end;

        --         args = array_merge( args, overrides );

        --         --
        --         -- Filters the common arguments supplied when constructing a Customizer setting.
        --         --
        --         -- @since 3.9.0
        --         --
        --         -- @see WP_Customize_Setting
        --         --
        --         -- @param array  args Array of Customizer setting arguments.
        --         -- @param string id   Widget setting ID.
        --         --
        --         return apply_filters( "widget_customizer_setting_args", args, id );
        -- end;

   --
   -- Ensures sidebar widget arrays only ever contain widget IDS.
   --
   -- Used as the "sanitize_callback" for each sidebars_widgets setting.
   --
   -- @since 3.9.0
   --
   -- @param string[] widget_ids Array of widget IDs.
   -- @return string[] Array of sanitized widget IDs.
   --
   function Sanitize_Sidebar_Widgets (This       : Wp_Customize_Widgets;
                                      Widget_Ids : List_Type)
                                      return List_Type;

   procedure Sanitize_Sidebar_Widgets (This : in out Wp_Customize_Widgets);

   --
   -- Builds up an index of all available widgets for use in Backbone models.
   --
   -- @since 3.9.0
   --
   -- @global array wp_registered_widgets
   -- @global array wp_registered_widget_controls
   --
   -- @see wp_list_widgets()
   --
   -- @return array List of available widgets.
   --
   function Get_Available_Widgets (This : in out Wp_Customize_Widgets)
                                   return Array_Type;
        --         static available_widgets = array();
        --         if ( ! empty( available_widgets ) ) then
        --                 return available_widgets;
        --         end;

        --         global wp_registered_widgets, wp_registered_widget_controls;
        --         require_once ABSPATH . "wp-admin/includes/widgets.php"; // For next_widget_id_number().

        --         sort = wp_registered_widgets;
        --         usort( sort, array( this, "_sort_name_callback" ) );
        --         done = array();

        --         foreach ( sort as widget ) then
        --                 if ( in_array( widget["callback"], done, true ) ) then // We already showed this multi-widget.
        --                         continue;
        --                 end;

        --                 sidebar = is_active_widget( widget["callback"], widget["id"], false, false );
        --                 done[]  = widget["callback"];

        --                 if ( ! isset( widget["params"][0] ) ) then
        --                         widget["params"][0] = array();
        --                 end;

        --                 available_widget = widget;
        --                 unset( available_widget["callback"] ); // Not serializable to JSON.

        --                 args = array(
        --                         "widget_id"   => widget["id"],
        --                         "widget_name" => widget["name"],
        --                         "_display"    => "template",
        --                 );

        --                 is_disabled     = false;
        --                 is_multi_widget = ( isset( wp_registered_widget_controls[ widget["id"] ]["id_base"] ) && isset( widget["params"][0]["number"] ) );
        --                 if ( is_multi_widget ) then
        --                         id_base            = wp_registered_widget_controls[ widget["id"] ]["id_base"];
        --                         args["_temp_id"]   = "id_base-__i__";
        --                         args["_multi_num"] = next_widget_id_number( id_base );
        --                         args["_add"]       = "multi";
        --                 end; else then
        --                         args["_add"] = "single";

        --                         if ( sidebar && "wp_inactive_widgets" !== sidebar ) then
        --                                 is_disabled = true;
        --                         end;
        --                         id_base = widget["id"];
        --                 end;

        --                 list_widget_controls_args = wp_list_widget_controls_dynamic_sidebar(
        --                         array(
        --                                 0 => args,
        --                                 1 => widget["params"][0],
        --                         )
        --                 );
        --                 control_tpl               = this.get_widget_control( list_widget_controls_args );

        --                 // The properties here are mapped to the Backbone Widget model.
        --                 available_widget = array_merge(
        --                         available_widget,
        --                         array(
        --                                 "temp_id"      => isset( args["_temp_id"] ) ? args["_temp_id"] : null,
        --                                 "is_multi"     => is_multi_widget,
        --                                 "control_tpl"  => control_tpl,
        --                                 "multi_number" => ( "multi" === args["_add"] ) ? args["_multi_num"] : false,
        --                                 "is_disabled"  => is_disabled,
        --                                 "id_base"      => id_base,
        --                                 "transport"    => this.is_widget_selective_refreshable( id_base ) ? "postMessage" : "refresh",
        --                                 "width"        => wp_registered_widget_controls[ widget["id"] ]["width"],
        --                                 "height"       => wp_registered_widget_controls[ widget["id"] ]["height"],
        --                                 "is_wide"      => this.is_wide_widget( widget["id"] ),
        --                         )
        --                 );

        --                 available_widgets[] = available_widget;
        --         end;

        --         return available_widgets;
        -- end;

        -- --
        -- -- Naturally orders available widgets by name.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @param array widget_a The first widget to compare.
        -- -- @param array widget_b The second widget to compare.
        -- -- @return int Reorder position for the current widget comparison.
        -- --
        -- protected function _sort_name_callback( widget_a, widget_b ) then
        --         return strnatcasecmp( widget_a["name"], widget_b["name"] );
        -- end;

   --
   -- Retrieves the widget control markup.
   --
   -- @since 3.9.0
   --
   -- @param array args Widget control arguments.
   -- @return string Widget control form HTML markup.
   --
   function Get_Widget_Control (This : Wp_Customize_Widgets;
                                Args : Array_Type)
                                return String;
        --         args[0]["before_form"]           = "<div class="form">";
        --         args[0]["after_form"]            = "</div><!-- .form -.";
        --         args[0]["before_widget_content"] = "<div class="widget-content">";
        --         args[0]["after_widget_content"]  = "</div><!-- .widget-content -.";
        --         ob_start();
        --         wp_widget_control( ...args );
        --         control_tpl = ob_get_clean();
        --         return control_tpl;
        -- end;

        -- --
        -- -- Retrieves the widget control markup parts.
        -- --
        -- -- @since 4.4.0
        -- --
        -- -- @param array args Widget control arguments.
        -- -- @return array then
        -- --     @type string control Markup for widget control wrapping form.
        -- --     @type string content The contents of the widget form itself.
        -- -- end;
        -- --
        -- public function get_widget_control_parts( args ) then
        --         args[0]["before_widget_content"] = "<div class="widget-content">";
        --         args[0]["after_widget_content"]  = "</div><!-- .widget-content -.";
        --         control_markup                   = this.get_widget_control( args );

        --         content_start_pos = strpos( control_markup, args[0]["before_widget_content"] );
        --         content_end_pos   = strrpos( control_markup, args[0]["after_widget_content"] );

        --         control  = substr( control_markup, 0, content_start_pos + strlen( args[0]["before_widget_content"] ) );
        --         control .= substr( control_markup, content_end_pos );
        --         content  = trim(
        --                 substr(
        --                         control_markup,
        --                         content_start_pos + strlen( args[0]["before_widget_content"] ),
        --                         content_end_pos - content_start_pos - strlen( args[0]["before_widget_content"] )
        --                 )
        --         );

        --         return compact( "control", "content" );
        -- end;

   --
   -- Adds hooks for the Customizer preview.
   --
   -- @since 3.9.0
   --
   procedure Customize_Preview_Init (This : in out Wp_Customize_Widgets);

   --
   -- Refreshes the nonce for widget updates.
   --
   -- @since 4.2.0
   --
   -- @param array nonces Array of nonces.
   -- @return array Array of nonces.
   --
   function Refresh_Nonces (This   : Wp_Customize_Widgets;
                            Nonces : Array_Type)
                            return Array_Type;

   procedure Refresh_Nonces (This : in out Wp_Customize_Widgets);

   --
   -- Tells the script loader to load the scripts and styles of custom blocks
   -- if the widgets block editor is enabled.
   --
   -- @since 5.8.0
   --
   -- @param bool is_block_editor_screen Current decision about loading block assets.
   -- @return bool Filtered decision about loading block assets.
   --
   function Should_Load_Block_Editor_Scripts_And_Styles
              (This                   : Wp_Customize_Widgets;
               Is_Block_Editor_Screen : Boolean)
               return Boolean;

   procedure Should_Load_Block_Editor_Scripts_And_Styles
               (This : in out Wp_Customize_Widgets);

   --
   -- When previewing, ensures the proper previewing widgets are used.
   --
   -- Because wp_get_sidebars_widgets() gets called early at then@see "init" end; (via
   -- wp_convert_widget_settings()) and can set global variable `_wp_sidebars_widgets`
   -- to the value of `get_option( "sidebars_widgets" )` before the Customizer preview
   -- filter is added, it has to be reset after the filter has been added.
   --
   -- @since 3.9.0
   --
   -- @param array sidebars_widgets List of widgets for the current sidebar.
   -- @return array
   --
   function Preview_Sidebars_Widgets (This             : Wp_Customize_Widgets;
                                      Sidebars_Widgets : Array_Type)
                                      return Array_Type;
   procedure Preview_Sidebars_Widgets (This : in out Wp_Customize_Widgets);
        --         sidebars_widgets = get_option( "sidebars_widgets", array() );

        --         unset( sidebars_widgets["array_version"] );
        --         return sidebars_widgets;
        -- end;

   --
   -- Enqueues scripts for the Customizer preview.
   --
   -- @since 3.9.0
   --
   procedure Customize_Preview_Enqueue (This : in out Wp_Customize_Widgets);

   --
   -- Inserts default style for highlighted widget at early point so theme
   -- stylesheet can override.
   --
   -- @since 3.9.0
   --
   procedure Print_Preview_CSS (This : in out Wp_Customize_Widgets);

   --
   -- Communicates the sidebars that appeared on the page at the very end of the page,
   -- and at the very end of the wp_footer,
   --
   -- @since 3.9.0
   --
   -- @global array wp_registered_sidebars
   -- @global array wp_registered_widgets
   --
   procedure Export_Preview_Data (This : in out Wp_Customize_Widgets);
        --         global wp_registered_sidebars, wp_registered_widgets;

        --         switched_locale = switch_to_locale( get_user_locale() );

        --         l10n = array(
        --                 "widgetTooltip" => __( "Shift-click to edit this widget." ),
        --         );

        --         if ( switched_locale ) then
        --                 restore_previous_locale();
        --         end;

        --         rendered_sidebars = array_filter( this.rendered_sidebars );
        --         rendered_widgets  = array_filter( this.rendered_widgets );

        --         // Prepare Customizer settings to pass to JavaScript.
        --         settings = array(
        --                 "renderedSidebars"            => array_fill_keys( array_keys( rendered_sidebars ), true ),
        --                 "renderedWidgets"             => array_fill_keys( array_keys( rendered_widgets ), true ),
        --                 "registeredSidebars"          => array_values( wp_registered_sidebars ),
        --                 "registeredWidgets"           => wp_registered_widgets,
        --                 "l10n"                        => l10n,
        --                 "selectiveRefreshableWidgets" => this.get_selective_refreshable_widgets(),
        --         );

        --         foreach ( settings["registeredWidgets"] as &registered_widget ) then
        --                 unset( registered_widget["callback"] ); // May not be JSON-serializeable.
        --         end;

        --         ?>
        --         <script type="text/javascript">
        --                 var _wpWidgetCustomizerPreviewSettings = <?php echo wp_json_encode( settings ); ?>;
        --         </script>
        --         <?php
        -- end;

   --
   -- Tracks the widgets that were rendered.
   --
   -- @since 3.9.0
   --
   -- @param array widget Rendered widget to tally.
   --
   procedure Tally_Rendered_Widgets (This   : in out Wp_Customize_Widgets;
                                     Widget : Array_Type);

   procedure Tally_Rendered_Widgets (This : in out Wp_Customize_Widgets);

        -- --
        -- -- Determine if a widget is rendered on the page.
        -- --
        -- -- @since 4.0.0
        -- --
        -- -- @param string widget_id Widget ID to check.
        -- -- @return bool Whether the widget is rendered.
        -- --
        -- public function is_widget_rendered( widget_id ) then
        --         return ! empty( this.rendered_widgets[ widget_id ] );
        -- end;

        -- --
        -- -- Determines if a sidebar is rendered on the page.
        -- --
        -- -- @since 4.0.0
        -- --
        -- -- @param string sidebar_id Sidebar ID to check.
        -- -- @return bool Whether the sidebar is rendered.
        -- --
        -- public function is_sidebar_rendered( sidebar_id ) then
        --         return ! empty( this.rendered_sidebars[ sidebar_id ] );
        -- end;

   --
   -- Tallies the sidebars rendered via is_active_sidebar().
   --
   -- Keep track of the times that is_active_sidebar() is called in the template,
   -- and assume that this means that the sidebar would be rendered on the template
   -- if there were widgets populating it.
   --
   -- @since 3.9.0
   --
   -- @param bool   is_active  Whether the sidebar is active.
   -- @param string sidebar_id Sidebar ID.
   -- @return bool Whether the sidebar is active.
   --
   function Tally_Sidebars_Via_Is_Active_Sidebar_Calls
              (This       : in out Wp_Customize_Widgets;
               Is_Active  : Boolean;
               Sidebar_Id : String)
               return Boolean;

   procedure Tally_Sidebars_Via_Is_Active_Sidebar_Calls
               (This : in out Wp_Customize_Widgets);

   --
   -- Tallies the sidebars rendered via dynamic_sidebar().
   --
   -- Keep track of the times that dynamic_sidebar() is called in the template,
   -- and assume this means the sidebar would be rendered on the template if
   -- there were widgets populating it.
   --
   -- @since 3.9.0
   --
   -- @param bool   has_widgets Whether the current sidebar has widgets.
   -- @param string sidebar_id  Sidebar ID.
   -- @return bool Whether the current sidebar has widgets.
   --
   function Tally_Sidebars_Via_Dynamic_Sidebar_Calls
              (This        : in out Wp_Customize_Widgets;
               Has_Widgets : Boolean;
               Sidebar_Id  : String)
               return Boolean;

   procedure Tally_Sidebars_Via_Dynamic_Sidebar_Calls
               (This : in out Wp_Customize_Widgets);

        -- --
        -- -- Retrieves MAC for a serialized widget instance string.
        -- --
        -- -- Allows values posted back from JS to be rejected if any tampering of the
        -- -- data has occurred.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @param string serialized_instance Widget instance.
        -- -- @return string MAC for serialized widget instance.
        -- --
        -- protected function get_instance_hash_key( serialized_instance ) then
        --         return wp_hash( serialized_instance );
        -- end;

        -- --
        -- -- Sanitizes a widget instance.
        -- --
        -- -- Unserialize the JS-instance for storing in the options. It"s important that this filter
        -- -- only get applied to an instance--once*.
        -- --
        -- -- @since 3.9.0
        -- -- @since 5.8.0 Added the `id_base` parameter.
        -- --
        -- -- @global WP_Widget_Factory wp_widget_factory
        -- --
        -- -- @param array  value   Widget instance to sanitize.
        -- -- @param string id_base Optional. Base of the ID of the widget being sanitized. Default null.
        -- -- @return array|void Sanitized widget instance.
        -- --
        -- public function sanitize_widget_instance( value, id_base = null ) then
        --         global wp_widget_factory;

        --         if ( array() === value ) then
        --                 return value;
        --         end;

        --         if ( isset( value["raw_instance"] ) && id_base && wp_use_widgets_block_editor() ) then
        --                 widget_object = wp_widget_factory.get_widget_object( id_base );
        --                 if ( ! empty( widget_object.widget_options["show_instance_in_rest"] ) ) then
        --                         if ( "block" === id_base && ! current_user_can( "unfiltered_html" ) ) then
        --                                 /*
        --                                 -- The content of the "block" widget is not filtered on the fly while editing.
        --                                 -- Filter the content here to prevent vulnerabilities.
        --                                 --
        --                                 value["raw_instance"]["content"] = wp_kses_post( value["raw_instance"]["content"] );
        --                         end;

        --                         return value["raw_instance"];
        --                 end;
        --         end;

        --         if (
        --                 empty( value["is_widget_customizer_js_value"] ) ||
        --                 empty( value["instance_hash_key"] ) ||
        --                 empty( value["encoded_serialized_instance"] )
        --         ) then
        --                 return;
        --         end;

        --         decoded = base64_decode( value["encoded_serialized_instance"], true );
        --         if ( false === decoded ) then
        --                 return;
        --         end;

        --         if ( ! hash_equals( this.get_instance_hash_key( decoded ), value["instance_hash_key"] ) ) then
        --                 return;
        --         end;

        --         instance = unserialize( decoded );
        --         if ( false === instance ) then
        --                 return;
        --         end;

        --         return instance;
        -- end;

        -- --
        -- -- Converts a widget instance into JSON-representable format.
        -- --
        -- -- @since 3.9.0
        -- -- @since 5.8.0 Added the `id_base` parameter.
        -- --
        -- -- @global WP_Widget_Factory wp_widget_factory
        -- --
        -- -- @param array  value   Widget instance to convert to JSON.
        -- -- @param string id_base Optional. Base of the ID of the widget being sanitized. Default null.
        -- -- @return array JSON-converted widget instance.
        -- --
        -- public function sanitize_widget_js_instance( value, id_base = null ) then
        --         global wp_widget_factory;

        --         if ( empty( value["is_widget_customizer_js_value"] ) ) then
        --                 serialized = serialize( value );

        --                 js_value = array(
        --                         "encoded_serialized_instance"   => base64_encode( serialized ),
        --                         "title"                         => empty( value["title"] ) ? "" : value["title"],
        --                         "is_widget_customizer_js_value" => true,
        --                         "instance_hash_key"             => this.get_instance_hash_key( serialized ),
        --                 );

        --                 if ( id_base && wp_use_widgets_block_editor() ) then
        --                         widget_object = wp_widget_factory.get_widget_object( id_base );
        --                         if ( ! empty( widget_object.widget_options["show_instance_in_rest"] ) ) then
        --                                 js_value["raw_instance"] = (object) value;
        --                         end;
        --                 end;

        --                 return js_value;
        --         end;

        --         return value;
        -- end;

   --
   -- Strips out widget IDs for widgets which are no longer registered.
   --
   -- One example where this might happen is when a plugin orphans a widget
   -- in a sidebar upon deactivation.
   --
   -- @since 3.9.0
   --
   -- @global array wp_registered_widgets
   --
   -- @param array widget_ids List of widget IDs.
   -- @return array Parsed list of widget IDs.
   --
   function Sanitize_Sidebar_Widgets_JS_Instance (This : Wp_Customize_Widgets;
                                                  Widget_Ids : Array_Type)
                                                  return Array_Type;

   procedure Sanitize_Sidebar_Widgets_JS_Instance
               (This : in out Wp_Customize_Widgets);
        -- --
        -- -- Finds and invokes the widget update and control callbacks.
        -- --
        -- -- Requires that `_POST` be populated with the instance data.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @global array wp_registered_widget_updates
        -- -- @global array wp_registered_widget_controls
        -- --
        -- -- @param string widget_id Widget ID.
        -- -- @return array|WP_Error Array containing the updated widget information.
        -- --                        A WP_Error object, otherwise.
        -- --
        -- public function call_widget_update( widget_id ) then
        --         global wp_registered_widget_updates, wp_registered_widget_controls;

        --         setting_id = this.get_setting_id( widget_id );

        --         /*
        --         -- Make sure that other setting changes have previewed since this widget
        --         -- may depend on them (e.g. Menus being present for Navigation Menu widget).
        --         --
        --         if ( ! did_action( "customize_preview_init" ) ) then
        --                 foreach ( this.manager.settings() as setting ) then
        --                         if ( setting.id !== setting_id ) then
        --                                 setting.preview();
        --                         end;
        --                 end;
        --         end;

        --         this.start_capturing_option_updates();
        --         parsed_id   = this.parse_widget_id( widget_id );
        --         option_name = "widget_" . parsed_id["id_base"];

        --         /*
        --         -- If a previously-sanitized instance is provided, populate the input vars
        --         -- with its values so that the widget update callback will read this instance
        --         --
        --         added_input_vars = array();
        --         if ( ! empty( _POST["sanitized_widget_setting"] ) ) then
        --                 sanitized_widget_setting = json_decode( this.get_post_value( "sanitized_widget_setting" ), true );
        --                 if ( false === sanitized_widget_setting ) then
        --                         this.stop_capturing_option_updates();
        --                         return new WP_Error( "widget_setting_malformed" );
        --                 end;

        --                 instance = this.sanitize_widget_instance( sanitized_widget_setting, parsed_id["id_base"] );
        --                 if ( is_null( instance ) ) then
        --                         this.stop_capturing_option_updates();
        --                         return new WP_Error( "widget_setting_unsanitized" );
        --                 end;

        --                 if ( ! is_null( parsed_id["number"] ) ) then
        --                         value                         = array();
        --                         value[ parsed_id["number"] ] = instance;
        --                         key                           = "widget-" . parsed_id["id_base"];
        --                         _REQUEST[ key ]              = wp_slash( value );
        --                         _POST[ key ]                 = _REQUEST[ key ];
        --                         added_input_vars[]            = key;
        --                 end; else then
        --                         foreach ( instance as key => value ) then
        --                                 _REQUEST[ key ]   = wp_slash( value );
        --                                 _POST[ key ]      = _REQUEST[ key ];
        --                                 added_input_vars[] = key;
        --                         end;
        --                 end;
        --         end;

        --         // Invoke the widget update callback.
        --         foreach ( (array) wp_registered_widget_updates as name => control ) then
        --                 if ( name === parsed_id["id_base"] && is_callable( control["callback"] ) ) then
        --                         ob_start();
        --                         call_user_func_array( control["callback"], control["params"] );
        --                         ob_end_clean();
        --                         break;
        --                 end;
        --         end;

        --         // Clean up any input vars that were manually added.
        --         foreach ( added_input_vars as key ) then
        --                 unset( _POST[ key ] );
        --                 unset( _REQUEST[ key ] );
        --         end;

        --         // Make sure the expected option was updated.
        --         if ( 0 !== this.count_captured_options() ) then
        --                 if ( this.count_captured_options() > 1 ) then
        --                         this.stop_capturing_option_updates();
        --                         return new WP_Error( "widget_setting_too_many_options" );
        --                 end;

        --                 updated_option_name = key( this.get_captured_options() );
        --                 if ( updated_option_name !== option_name ) then
        --                         this.stop_capturing_option_updates();
        --                         return new WP_Error( "widget_setting_unexpected_option" );
        --                 end;
        --         end;

        --         // Obtain the widget instance.
        --         option = this.get_captured_option( option_name );
        --         if ( null !== parsed_id["number"] ) then
        --                 instance = option[ parsed_id["number"] ];
        --         end; else then
        --                 instance = option;
        --         end;

        --         /*
        --         -- Override the incoming _POST["customized"] for a newly-created widget"s
        --         -- setting with the new instance so that the preview filter currently
        --         -- in place from WP_Customize_Setting::preview() will use this value
        --         -- instead of the default widget instance value (an empty array).
        --         --
        --         this.manager.set_post_value( setting_id, this.sanitize_widget_js_instance( instance, parsed_id["id_base"] ) );

        --         // Obtain the widget control with the updated instance in place.
        --         ob_start();
        --         form = wp_registered_widget_controls[ widget_id ];
        --         if ( form ) then
        --                 call_user_func_array( form["callback"], form["params"] );
        --         end;
        --         form = ob_get_clean();

        --         this.stop_capturing_option_updates();

        --         return compact( "instance", "form" );
        -- end;

        -- --
        -- -- Updates widget settings asynchronously.
        -- --
        -- -- Allows the Customizer to update a widget using its form, but return the new
        -- -- instance info via Ajax instead of saving it to the options table.
        -- --
        -- -- Most code here copied from wp_ajax_save_widget().
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @see wp_ajax_save_widget()
        -- --
        -- public function wp_ajax_update_widget() then

        --         if ( ! is_user_logged_in() ) then
        --                 wp_die( 0 );
        --         end;

        --         check_ajax_referer( "update-widget", "nonce" );

        --         if ( ! current_user_can( "edit_theme_options" ) ) then
        --                 wp_die( -1 );
        --         end;

        --         if ( empty( _POST["widget-id"] ) ) then
        --                 wp_send_json_error( "missing_widget-id" );
        --         end;

        --         -- This action is documented in wp-admin/includes/ajax-actions.php--
        --         do_action( "load-widgets.php" ); // phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

        --         -- This action is documented in wp-admin/includes/ajax-actions.php--
        --         do_action( "widgets.php" ); // phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

        --         -- This action is documented in wp-admin/widgets.php--
        --         do_action( "sidebar_admin_setup" );

        --         widget_id = this.get_post_value( "widget-id" );
        --         parsed_id = this.parse_widget_id( widget_id );
        --         id_base   = parsed_id["id_base"];

        --         is_updating_widget_template = (
        --                 isset( _POST[ "widget-" . id_base ] )
        --                 &&
        --                 is_array( _POST[ "widget-" . id_base ] )
        --                 &&
        --                 preg_match( "/__i__|%i%/", key( _POST[ "widget-" . id_base ] ) )
        --         );
        --         if ( is_updating_widget_template ) then
        --                 wp_send_json_error( "template_widget_not_updatable" );
        --         end;

        --         updated_widget = this.call_widget_update( widget_id ); // => theninstance,formend;
        --         if ( is_wp_error( updated_widget ) ) then
        --                 wp_send_json_error( updated_widget.get_error_code() );
        --         end;

        --         form     = updated_widget["form"];
        --         instance = this.sanitize_widget_js_instance( updated_widget["instance"], id_base );

        --         wp_send_json_success( compact( "form", "instance" ) );
        -- end;

        -- /*
        -- -- Selective Refresh Methods
        -- --

   --
   -- Filters arguments for dynamic widget partials.
   --
   -- @since 4.5.0
   --
   -- @param array|false partial_args Partial arguments.
   -- @param string      partial_id   Partial ID.
   -- @return array (Maybe) modified partial arguments.
   --
   function Customize_Dynamic_Partial_Args (This         : Wp_Customize_Widgets;
                                            Partial_Args : Array_Type;
                                            Partial_Id   : String)
                                            return Array_Type;

   procedure Customize_Dynamic_Partial_Args
               (This : in out Wp_Customize_Widgets);

   --
   -- Adds hooks for selective refresh.
   --
   -- @since 4.5.0
   --
   procedure Selective_Refresh_Init (This : in out Wp_Customize_Widgets);

   --
   -- Inject selective refresh data attributes into widget container elements.
   --
   -- @since 4.5.0
   --
   -- @param array params {
   --     Dynamic sidebar params.
   --
   --     @type array args        Sidebar args.
   --     @type array widget_args Widget args.
   -- }
   -- @see WP_Customize_Nav_Menus::filter_wp_nav_menu_args()
   --
   -- @return array Params.
   --
   function Filter_Dynamic_Sidebar_Params (This   : in out Wp_Customize_Widgets;
                                           Params : Array_Type)
                                           return Array_Type;

   procedure Filter_Dynamic_Sidebar_Params (This : in out Wp_Customize_Widgets);

   --
   -- Ensures the HTML data-* attributes for selective refresh are allowed by kses.
   --
   -- This is needed in case the `before_widget` is run through wp_kses() when printed.
   --
   -- @since 4.5.0
   --
   -- @param array allowed_html Allowed HTML.
   -- @return array (Maybe) modified allowed HTML.
   --
   function Filter_Wp_KSES_Allowed_Data_Attributes
              (This         : Wp_Customize_Widgets;
               Allowed_HTML : Array_Type)
               return Array_Type;

   procedure Filter_Wp_KSES_Allowed_Data_Attributes
               (This : in out Wp_Customize_Widgets);

   --
   -- Begins keeping track of the current sidebar being rendered.
   --
   -- Insert marker before widgets are rendered in a dynamic sidebar.
   --
   -- @since 4.5.0
   --
   -- @param int|string index Index, name, or ID of the dynamic sidebar.
   --
   procedure Start_Dynamic_Sidebar (This  : in out Wp_Customize_Widgets;
                                    Index : String);

   procedure Start_Dynamic_Sidebar (This : in out Wp_Customize_Widgets);

   --
   -- Finishes keeping track of the current sidebar being rendered.
   --
   -- Inserts a marker after widgets are rendered in a dynamic sidebar.
   --
   -- @since 4.5.0
   --
   -- @param int|string index Index, name, or ID of the dynamic sidebar.
   --
   procedure End_Dynamic_Sidebar (This  : in out Wp_Customize_Widgets;
                                  Index : String);

   procedure End_Dynamic_Sidebar (This : in out Wp_Customize_Widgets);

   --
   -- Filters sidebars_widgets to ensure the currently-rendered widget is the only
   -- widget in the current sidebar.
   --
   -- @since 4.5.0
   --
   -- @param array sidebars_widgets Sidebars widgets.
   -- @return array Filtered sidebars widgets.
   --
   function Filter_Sidebars_Widgets_For_Rendering_Widget
              (This             : in out Wp_Customize_Widgets;
               Sidebars_Widgets : Array_Type)
               return Array_Type;

   procedure Filter_Sidebars_Widgets_For_Rendering_Widget
              (This : in out Wp_Customize_Widgets);

   procedure Filter_Sidebars_Widgets_For_Rendering_Widget;

   --
   -- Renders a specific widget using the supplied sidebar arguments.
   --
   -- @since 4.5.0
   --
   -- @see dynamic_sidebar()
   --
   -- @param WP_Customize_Partial partial Partial.
   -- @param array                context {
   --     Sidebar args supplied as container context.
   --
   --     @type string sidebar_id              ID for sidebar for widget to render
   --                                           into.
   --     @type int    sidebar_instance_number Disambiguating instance number.
   -- }
   -- @return string|false
   --
   function Render_Widget_Partial
             (This    : in out Wp_Customize_Widgets;
              Partial : Cust_Class_Wp_Customize_Partials.Wp_Customize_Partial;
              Context : Array_Type)
              return String;

   procedure Render_Widget_Partial
               (This : in out Wp_Customize_Widgets);

   -----------------------------
   -- Option Update Capturing --
   -----------------------------

        -- --
        -- -- List of captured widget option updates.
        -- --
        -- -- @since 3.9.0
        -- -- @var array _captured_options Values updated while option capture is happening.
        -- --
        -- protected _captured_options = array();

        -- --
        -- -- Whether option capture is currently happening.
        -- --
        -- -- @since 3.9.0
        -- -- @var bool _is_current Whether option capture is currently happening or not.
        -- --
        -- protected _is_capturing_option_updates = false;

        -- --
        -- -- Determines whether the captured option update should be ignored.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @param string option_name Option name.
        -- -- @return bool Whether the option capture is ignored.
        -- --
        -- protected function is_option_capture_ignored( option_name ) then
        --         return ( 0 === strpos( option_name, "_transient_" ) );
        -- end;

        -- --
        -- -- Retrieves captured widget option updates.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @return array Array of captured options.
        -- --
        -- protected function get_captured_options() then
        --         return this._captured_options;
        -- end;

        -- --
        -- -- Retrieves the option that was captured from being saved.
        -- --
        -- -- @since 4.2.0
        -- --
        -- -- @param string option_name   Option name.
        -- -- @param mixed  default_value Optional. Default value to return if the option does not exist. Default false.
        -- -- @return mixed Value set for the option.
        -- --
        -- protected function get_captured_option( option_name, default_value = false ) then
        --         if ( array_key_exists( option_name, this._captured_options ) ) then
        --                 value = this._captured_options[ option_name ];
        --         end; else then
        --                 value = default_value;
        --         end;
        --         return value;
        -- end;

        -- --
        -- -- Retrieves the number of captured widget option updates.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @return int Number of updated options.
        -- --
        -- protected function count_captured_options() then
        --         return count( this._captured_options );
        -- end;

        -- --
        -- -- Begins keeping track of changes to widget options, caching new values.
        -- --
        -- -- @since 3.9.0
        -- --
        -- protected function start_capturing_option_updates() then
        --         if ( this._is_capturing_option_updates ) then
        --                 return;
        --         end;

        --         this._is_capturing_option_updates = true;

        --         add_filter( "pre_update_option", array( this, "capture_filter_pre_update_option" ), 10, 3 );
        -- end;

        -- --
        -- -- Pre-filters captured option values before updating.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @param mixed  new_value   The new option value.
        -- -- @param string option_name Name of the option.
        -- -- @param mixed  old_value   The old option value.
        -- -- @return mixed Filtered option value.
        -- --
        -- public function capture_filter_pre_update_option( new_value, option_name, old_value ) then
        --         if ( this.is_option_capture_ignored( option_name ) ) then
        --                 return new_value;
        --         end;

        --         if ( ! isset( this._captured_options[ option_name ] ) ) then
        --                 add_filter( "pre_option_thenoption_nameend;", array( this, "capture_filter_pre_get_option" ) );
        --         end;

        --         this._captured_options[ option_name ] = new_value;

        --         return old_value;
        -- end;

        -- --
        -- -- Pre-filters captured option values before retrieving.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @param mixed value Value to return instead of the option value.
        -- -- @return mixed Filtered option value.
        -- --
        -- public function capture_filter_pre_get_option( value ) then
        --         option_name = preg_replace( "/^pre_option_/", "", current_filter() );

        --         if ( isset( this._captured_options[ option_name ] ) ) then
        --                 value = this._captured_options[ option_name ];

        --                 -- This filter is documented in wp-includes/option.php--
        --                 value = apply_filters( "option_" . option_name, value, option_name );
        --         end;

        --         return value;
        -- end;

        -- --
        -- -- Undoes any changes to the options since options capture began.
        -- --
        -- -- @since 3.9.0
        -- --
        -- protected function stop_capturing_option_updates() then
        --         if ( ! this._is_capturing_option_updates ) then
        --                 return;
        --         end;

        --         remove_filter( "pre_update_option", array( this, "capture_filter_pre_update_option" ), 10 );

        --         foreach ( array_keys( this._captured_options ) as option_name ) then
        --                 remove_filter( "pre_option_thenoption_nameend;", array( this, "capture_filter_pre_get_option" ) );
        --         end;

        --         this._captured_options            = array();
        --         this._is_capturing_option_updates = false;
        -- end;

        -- --
        -- -- then@internal Missing Summaryend;
        -- --
        -- -- See the then@see "customize_dynamic_setting_args"end; filter.
        -- --
        -- -- @since 3.9.0
        -- -- @deprecated 4.2.0 Deprecated in favor of the then@see "customize_dynamic_setting_args"end; filter.
        -- --
        -- public function setup_widget_addition_previews() then
        --         _deprecated_function( __METHOD__, "4.2.0", "customize_dynamic_setting_args" );
        -- end;

        -- --
        -- -- then@internal Missing Summaryend;
        -- --
        -- -- See the then@see "customize_dynamic_setting_args"end; filter.
        -- --
        -- -- @since 3.9.0
        -- -- @deprecated 4.2.0 Deprecated in favor of the then@see "customize_dynamic_setting_args"end; filter.
        -- --
        -- public function prepreview_added_sidebars_widgets() then
        --         _deprecated_function( __METHOD__, "4.2.0", "customize_dynamic_setting_args" );
        -- end;

        -- --
        -- -- then@internal Missing Summaryend;
        -- --
        -- -- See the then@see "customize_dynamic_setting_args"end; filter.
        -- --
        -- -- @since 3.9.0
        -- -- @deprecated 4.2.0 Deprecated in favor of the then@see "customize_dynamic_setting_args"end; filter.
        -- --
        -- public function prepreview_added_widget_instance() then
        --         _deprecated_function( __METHOD__, "4.2.0", "customize_dynamic_setting_args" );
        -- end;

        -- --
        -- -- then@internal Missing Summaryend;
        -- --
        -- -- See the then@see "customize_dynamic_setting_args"end; filter.
        -- --
        -- -- @since 3.9.0
        -- -- @deprecated 4.2.0 Deprecated in favor of the then@see "customize_dynamic_setting_args"end; filter.
        -- --
        -- public function remove_prepreview_filters() then
        --         _deprecated_function( __METHOD__, "4.2.0", "customize_dynamic_setting_args" );
        -- end;

end Inc_Class_Wp_Customize_Widgets;
