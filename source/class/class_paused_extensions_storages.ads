--
-- Error Protection API: WP_Paused_Extensions_Storage class
--
-- @package WordPress
-- @since 5.2.0
--

with Arrays;
with UStrings;

package Class_Paused_Extensions_Storages
is
   use Arrays;

   --
   -- Core class used for storing paused extensions.
   --
   -- @since 5.2.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Paused_Extensions_Storage is tagged
      record
         --
         -- Type of extension. Used to key extension storage.
         --
         -- @since 5.2.0
         -- @var string
         --
         -- protected
         Typ : UStrings.UString;

      end record;

   --
   -- Constructor.
   --
   -- @since 5.2.0
   --
   -- @param string extension_type Extension type. Either 'plugin' or 'theme'.
   --
   function X_Construct (Extension_Type : String)
                         return Wp_Paused_Extensions_Storage;

--         --
--         -- Records an extension error.
--         --
--         -- Only one error is stored per extension, with subsequent errors for the same extension overriding the
--         -- previously stored error.
--         --
--         -- @since 5.2.0
--         --
--         -- @param string extension Plugin or theme directory name.
--         -- @param array  error     then
--         --     Error information returned by `error_get_last()`.
--         --
--         --     @type int    type    The error type.
--         --     @type string file    The name of the file in which the error occurred.
--         --     @type int    line    The line number in which the error occurred.
--         --     @type string message The error message.
--         -- end;
--         -- @return bool True on success, false on failure.
--         --
--         public function set( extension, error ) then
--                 if ( ! this->is_api_loaded() ) then
--                         return false;
--                 end;

--                 option_name = this->get_option_name();

--                 if ( ! option_name ) then
--                         return false;
--                 end;

--                 paused_extensions = (array) get_option( option_name, array() );

--                 // Do not update if the error is already stored.
--                 if ( isset( paused_extensions[ this->type ][ extension ] ) && paused_extensions[ this->type ][ extension ] === error ) then
--                         return true;
--                 end;

--                 paused_extensions[ this->type ][ extension ] = error;

--                 return update_option( option_name, paused_extensions );
--         end;

   --
   -- Forgets a previously recorded extension error.
   --
   -- @since 5.2.0
   --
   -- @param string extension Plugin or theme directory name.
   -- @return bool True on success, false on failure.
   --
   function Delete (This : Wp_Paused_Extensions_Storage; Extension : String) return Boolean;
   procedure Delete (This : Wp_Paused_Extensions_Storage; Extension : String);
--                 if ( ! this->is_api_loaded() ) then
--                         return false;
--                 end;

--                 option_name = this->get_option_name();

--                 if ( ! option_name ) then
--                         return false;
--                 end;

--                 paused_extensions = (array) get_option( option_name, array() );

--                 // Do not delete if no error is stored.
--                 if ( ! isset( paused_extensions[ this->type ][ extension ] ) ) then
--                         return true;
--                 end;

--                 unset( paused_extensions[ this->type ][ extension ] );

--                 if ( empty( paused_extensions[ this->type ] ) ) then
--                         unset( paused_extensions[ this->type ] );
--                 end;

--                 // Clean up the entire option if we're removing the only error.
--                 if ( ! paused_extensions ) then
--                         return delete_option( option_name );
--                 end;

--                 return update_option( option_name, paused_extensions );
--         end;

   --
   -- Gets the error for an extension, if paused.
   --
   -- @since 5.2.0
   --
   -- @param string extension Plugin or theme directory name.
   -- @return array|null Error that is stored, or null if the extension is not paused.
   --
   function Get (This      : Wp_Paused_Extensions_Storage;
                 Extension : String)
            return Array_Type;

   --
   -- Gets the paused extensions with their errors.
   --
   -- @since 5.2.0
   --
   -- @return array then
   --     Associative array of errors keyed by extension slug.
   --
   --     @type array ...0 Error information returned by `error_get_last()`.
   -- end;
   --
   function Get_All (This : Wp_Paused_Extensions_Storage)
                     return Array_Type;
--                 if ( ! this->is_api_loaded() ) then
--                         return array();
--                 end;

--                 option_name = this->get_option_name();

--                 if ( ! option_name ) then
--                         return array();
--                 end;

--                 paused_extensions = (array) get_option( option_name, array() );

--                 return isset( paused_extensions[ this->type ] ) ? paused_extensions[ this->type ] : array();
--         end;

--         --
--         -- Remove all paused extensions.
--         --
--         -- @since 5.2.0
--         --
--         -- @return bool
--         --
--         public function delete_all() then
--                 if ( ! this->is_api_loaded() ) then
--                         return false;
--                 end;

--                 option_name = this->get_option_name();

--                 if ( ! option_name ) then
--                         return false;
--                 end;

--                 paused_extensions = (array) get_option( option_name, array() );

--                 unset( paused_extensions[ this->type ] );

--                 if ( ! paused_extensions ) then
--                         return delete_option( option_name );
--                 end;

--                 return update_option( option_name, paused_extensions );
--         end;

   --
   -- Checks whether the underlying API to store paused extensions is loaded.
   --
   -- @since 5.2.0
   --
   -- @return bool True if the API is loaded, false otherwise.
   --
   -- protected
   function Is_API_Loaded (This : Wp_Paused_Extensions_Storage)
                           return Boolean;

   --
   -- Get the option name for storing paused extensions.
   --
   -- @since 5.2.0
   --
   -- @return string
   --
   -- protected
   function Get_Option_Name (This : Wp_Paused_Extensions_Storage)
                             return String;
--                 if ( ! wp_recovery_mode()->is_active() ) then
--                         return '';
--                 end;

--                 session_id = wp_recovery_mode()->get_session_id();
--                 if ( empty( session_id ) ) then
--                         return '';
--                 end;

--                 return "thensession_idend;_paused_extensions";
--         end;

   Null_Paused_Extensions_Storage : constant Wp_Paused_Extensions_Storage :=
     (Typ => UStrings.Null_UString);

end Class_Paused_Extensions_Storages;
