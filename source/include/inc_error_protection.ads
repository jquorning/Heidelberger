--
-- Error Protection API: Functions
--
-- @package WordPress
-- @since 5.2.0
--

with Class_Paused_Extensions_Storages;
with Class_Recovery_Mode;

package Inc_Error_Protection
is
   use Class_Paused_Extensions_Storages;

-- --
-- -- Get the instance for storing paused plugins.
-- --
-- -- @return WP_Paused_Extensions_Storage
-- --
-- function wp_paused_plugins() then
--         static storage = null;

--         if ( null === storage ) then
--                 storage = new WP_Paused_Extensions_Storage( "plugin" );
--         end;

--         return storage;
-- end;

   --
   -- Get the instance for storing paused extensions.
   --
   -- @return WP_Paused_Extensions_Storage
   --
   function Wp_Paused_Themes
            return Wp_Paused_Extensions_Storage;

-- --
-- -- Get a human readable description of an extension"s error.
-- --
-- -- @since 5.2.0
-- --
-- -- @param array error Error details from `error_get_last()`.
-- -- @return string Formatted error description.
-- --
-- function wp_get_extension_error_description( error ) then
--         constants   = get_defined_constants( true );
--         constants   = isset( constants["Core"] ) ? constants["Core"] : constants["internal"];
--         core_errors = array();

--         foreach ( constants as constant => value ) then
--                 if ( 0 === strpos( constant, "E_" ) ) then
--                         core_errors[ value ] = constant;
--                 end;
--         end;

--         if ( isset( core_errors[ error["type"] ] ) ) then
--                 error["type"] = core_errors[ error["type"] ];
--         end;

--         /* translators: 1: Error type, 2: Error line number, 3: Error file name, 4: Error message.--
--         error_message = __( "An error of type %1s was caused in line %2s of the file %3s. Error message: %4s" );

--         return sprintf(
--                 error_message,
--                 "<code>thenerror["type"]end;</code>",
--                 "<code>thenerror["line"]end;</code>",
--                 "<code>thenerror["file"]end;</code>",
--                 "<code>thenerror["message"]end;</code>"
--         );
-- end;

-- --
-- -- Registers the shutdown handler for fatal errors.
-- --
-- -- The handler will only be registered if then@see wp_is_fatal_error_handler_enabled()end; returns true.
-- --
-- -- @since 5.2.0
-- --
-- function wp_register_fatal_error_handler() then
--         if ( ! wp_is_fatal_error_handler_enabled() ) then
--                 return;
--         end;

--         handler = null;
--         if ( defined( "WP_CONTENT_DIR" ) && is_readable( WP_CONTENT_DIR . "/fatal-error-handler.php" ) ) then
--                 handler = include WP_CONTENT_DIR . "/fatal-error-handler.php";
--         end;

--         if ( ! is_object( handler ) || ! is_callable( array( handler, "handle" ) ) ) then
--                 handler = new WP_Fatal_Error_Handler();
--         end;

--         register_shutdown_function( array( handler, "handle" ) );
-- end;

-- --
-- -- Checks whether the fatal error handler is enabled.
-- --
-- -- A constant `WP_DISABLE_FATAL_ERROR_HANDLER` can be set in `wp-config.php` to disable it, or alternatively the
-- -- then@see "wp_fatal_error_handler_enabled"end; filter can be used to modify the return value.
-- --
-- -- @since 5.2.0
-- --
-- -- @return bool True if the fatal error handler is enabled, false otherwise.
-- --
-- function wp_is_fatal_error_handler_enabled() then
--         enabled = ! defined( "WP_DISABLE_FATAL_ERROR_HANDLER" ) || ! WP_DISABLE_FATAL_ERROR_HANDLER;

--         --
--         -- Filters whether the fatal error handler is enabled.
--         --
--         ----*Important:** This filter runs before it can be used by plugins. It cannot
--         -- be used by plugins, mu-plugins, or themes. To use this filter you must define
--         -- a `wp_filter` global before WordPress loads, usually in `wp-config.php`.
--         --
--         -- Example:
--         --
--         --     GLOBALS["wp_filter"] = array(
--         --         "wp_fatal_error_handler_enabled" => array(
--         --             10 => array(
--         --                 array(
--         --                     "accepted_args" => 0,
--         --                     "function"      => function() then
--         --                         return false;
--         --                     end;,
--         --                 ),
--         --             ),
--         --         ),
--         --     );
--         --
--         -- Alternatively you can use the `WP_DISABLE_FATAL_ERROR_HANDLER` constant.
--         --
--         -- @since 5.2.0
--         --
--         -- @param bool enabled True if the fatal error handler is enabled, false otherwise.
--         --
--         return apply_filters( "wp_fatal_error_handler_enabled", enabled );
-- end;

   --
   -- Access the WordPress Recovery Mode instance.
   --
   -- @since 5.2.0
   --
   -- @return WP_Recovery_Mode
   --
   function X_Wp_Recovery_Mode    -- X_ added
            return Class_Recovery_Mode.Wp_Recovery_Mode;

end Inc_Error_Protection;
