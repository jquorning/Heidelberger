--
-- Widget API: WP_Widget_Factory class
--
-- @package WordPress
-- @subpackage Widgets
-- @since 4.4.0
--

with Ada.Containers.Vectors;

with Arrays;

with Inc_Class_Wp_Widgets;

package Inc_Class_Wp_Widget_Factories
is
   use Arrays;

   subtype Widget_Index is Positive;

   package Widget_Vectors is new
     Ada.Containers.Vectors
       (Index_Type   => Widget_Index,
        Element_Type => Inc_Class_Wp_Widgets.Wp_Widget,
        "="          => Inc_Class_Wp_Widgets."=");

   --
   -- Singleton that registers and instantiates WP_Widget classes.
   --
   -- @since 2.8.0
   -- @since 4.4.0 Moved to its own file from wp-includes/widgets.php
   --
   -- #[AllowDynamicProperties]
   type Wp_Widget_Factory is tagged
      record
         --
         -- Widgets array.
         --
         -- @since 2.8.0
         -- @var array
         --
         Widgets : Widget_Vectors.Vector; -- Array_Type;
      end record;

        --
        -- -- PHP5 constructor.
        -- --
        -- -- @since 4.3.0
        -- --
        -- public function __construct() then
        --         add_action( "widgets_init", array( this, "_register_widgets" ), 100 );
        -- end;

        -- --
        -- -- PHP4 constructor.
        -- --
        -- -- @since 2.8.0
        -- -- @deprecated 4.3.0 Use __construct() instead.
        -- --
        -- -- @see WP_Widget_Factory::__construct()
        -- --
        -- public function WP_Widget_Factory() then
        --         _deprecated_constructor( "WP_Widget_Factory", "4.3.0" );
        --         self::__construct();
        -- end;

        -- --
        -- -- Registers a widget subclass.
        -- --
        -- -- @since 2.8.0
        -- -- @since 4.6.0 Updated the `widget` parameter to also accept a WP_Widget instance object
        -- --              instead of simply a `WP_Widget` subclass name.
        -- --
        -- -- @param string|WP_Widget widget Either the name of a `WP_Widget` subclass or an instance of a `WP_Widget` subclass.
        -- --
        -- public function register( widget ) then
        --         if ( widget instanceof WP_Widget ) then
        --                 this.widgets[ spl_object_hash( widget ) ] = widget;
        --         end; else then
        --                 this.widgets[ widget ] = new widget();
        --         end;
        -- end;

        -- --
        -- -- Un-registers a widget subclass.
        -- --
        -- -- @since 2.8.0
        -- -- @since 4.6.0 Updated the `widget` parameter to also accept a WP_Widget instance object
        -- --              instead of simply a `WP_Widget` subclass name.
        -- --
        -- -- @param string|WP_Widget widget Either the name of a `WP_Widget` subclass or an instance of a `WP_Widget` subclass.
        -- --
        -- public function unregister( widget ) then
        --         if ( widget instanceof WP_Widget ) then
        --                 unset( this.widgets[ spl_object_hash( widget ) ] );
        --         end; else then
        --                 unset( this.widgets[ widget ] );
        --         end;
        -- end;

        -- --
        -- -- Serves as a utility method for adding widgets to the registered widgets global.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @global array wp_registered_widgets
        -- --
        -- public function _register_widgets() then
        --         global wp_registered_widgets;
        --         keys       = array_keys( this.widgets );
        --         registered = array_keys( wp_registered_widgets );
        --         registered = array_map( "_get_widget_id_base", registered );

        --         foreach ( keys as key ) then
        --                 // Don't register new widget if old widget with the same id is already registered.
        --                 if ( in_array( this.widgets[ key ].id_base, registered, true ) ) then
        --                         unset( this.widgets[ key ] );
        --                         continue;
        --                 end;

        --                 this.widgets[ key ]._register();
        --         end;
        -- end;

        -- --
        -- -- Returns the registered WP_Widget object for the given widget type.
        -- --
        -- -- @since 5.8.0
        -- --
        -- -- @param string id_base Widget type ID.
        -- -- @return WP_Widget|null
        -- --
        -- public function get_widget_object( id_base ) then
        --         key = this.get_widget_key( id_base );
        --         if ( "" === key ) then
        --                 return null;
        --         end;

        --         return this.widgets[ key ];
        -- end;

        -- --
        -- -- Returns the registered key for the given widget type.
        -- --
        -- -- @since 5.8.0
        -- --
        -- -- @param string id_base Widget type ID.
        -- -- @return string
        -- --
        -- public function get_widget_key( id_base ) then
        --         foreach ( this.widgets as key => widget_object ) then
        --                 if ( widget_object.id_base === id_base ) then
        --                         return key;
        --                 end;
        --         end;

        --         return "";
        -- end;

end Inc_Class_Wp_Widget_Factories;
