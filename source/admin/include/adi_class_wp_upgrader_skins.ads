--
-- Upgrader API: WP_Upgrader_Skin class
--
-- @package WordPress
-- @subpackage Upgrader
-- @since 4.6.0
--

with Arrays;

limited with Adi_Class_Wp_Upgraders;

package Adi_Class_Wp_Upgrader_Skins
is
   use Arrays;

   --
   -- Generic Skin for the WordPress Upgrader classes. This skin is designed to be
   -- extended for specific purposes.
   --
   -- @since 2.8.0
   -- @since 4.6.0 Moved to its own file from
   --               wp-admin/includes/class-wp-upgrader-skins.php.
   --
   -- #[AllowDynamicProperties]
   type Wp_Upgrader_Skin is tagged
      record
         --
         -- Holds the upgrader data.
         --
         -- @since 2.8.0
         --
         -- @var WP_Upgrader
         --
         Upgrader : access Adi_Class_Wp_Upgraders.Wp_Upgrader;

         --
         -- Whether header is done.
         --
         -- @since 2.8.0
         --
         -- @var bool
         --
         Done_Header : Boolean := False;

         --
         -- Whether footer is done.
         --
         -- @since 2.8.0
         --
         -- @var bool
         --
         Done_Footer : Boolean := False;

         --
         -- Holds the result of an upgrade.
         --
         -- @since 2.8.0
         --
         -- @var string|bool|WP_Error
         --
--         public result = false;

         --
         -- Holds the options of an upgrade.
         --
         -- @since 2.8.0
         --
         -- @var array
         --
         Options : Array_Type;

      end record;

   --
   -- Constructor.
   --
   -- Sets up the generic skin for the WordPress Upgrader classes.
   --
   -- @since 2.8.0
   --
   -- @param array args Optional. The WordPress upgrader skin arguments to
   --                    override default options. Default empty array.
   --
   function X_Construct (Args : Array_Type := Empty_Array)
                         return Wp_Upgrader_Skin;

   --
   -- @since 2.8.0
   --
   -- @param WP_Upgrader upgrader
   --
   procedure Set_Upgrader (This     : in out Wp_Upgrader_Skin;
                           Upgrader : access Adi_Class_Wp_Upgraders.Wp_Upgrader);

   --
   -- @since 3.0.0
   --
   procedure Add_Strings (This : in out Wp_Upgrader_Skin)
   is null; -- True this time

        -- --
        -- -- Sets the result of an upgrade.
        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @param string|bool|WP_Error result The result of an upgrade.
        -- --
        -- public function set_result( result ) then
        --         this.result = result;
        -- end;

        -- --
        -- -- Displays a form to the user to request for their FTP/SSH details in order
        -- -- to connect to the filesystem.
        -- --
        -- -- @since 2.8.0
        -- -- @since 4.6.0 The `context` parameter default changed from `false` to an empty string.
        -- --
        -- -- @see request_filesystem_credentials()
        -- --
        -- -- @param bool|WP_Error error                        Optional. Whether the current request has failed to connect,
        -- --                                                    or an error object. Default false.
        -- -- @param string        context                      Optional. Full path to the directory that is tested
        -- --                                                    for being writable. Default empty.
        -- -- @param bool          allow_relaxed_file_ownership Optional. Whether to allow Group/World writable. Default false.
        -- -- @return bool True on success, false on failure.
        -- --
        -- public function request_filesystem_credentials( error = false, context = "", allow_relaxed_file_ownership = false ) then
        --         url = this.options["url"];
        --         if ( ! context ) then
        --                 context = this.options["context"];
        --         end;
        --         if ( ! empty( this.options["nonce"] ) ) then
        --                 url = wp_nonce_url( url, this.options["nonce"] );
        --         end;

        --         extra_fields = array();

        --         return request_filesystem_credentials( url, "", error, context, extra_fields, allow_relaxed_file_ownership );
        -- end;

        -- --
        -- -- @since 2.8.0
        -- --
        -- public function header() then
        --         if ( this.done_header ) then
        --                 return;
        --         end;
        --         this.done_header = true;
        --         echo "<div class="wrap">";
        --         echo "<h1>" . this.options["title"] . "</h1>";
        -- end;

        -- --
        -- -- @since 2.8.0
        -- --
        -- public function footer() then
        --         if ( this.done_footer ) then
        --                 return;
        --         end;
        --         this.done_footer = true;
        --         echo "</div>";
        -- end;

        -- --
        -- -- @since 2.8.0
        -- --
        -- -- @param string|WP_Error errors Errors.
        -- --
        -- public function error( errors ) then
        --         if ( ! this.done_header ) then
        --                 this.header();
        --         end;
        --         if ( is_string( errors ) ) then
        --                 this.feedback( errors );
        --         end; elseif ( is_wp_error( errors ) && errors.has_errors() ) then
        --                 foreach ( errors.get_error_messages() as message ) then
        --                         if ( errors.get_error_data() && is_string( errors.get_error_data() ) ) then
        --                                 this.feedback( message . " " . esc_html( strip_tags( errors.get_error_data() ) ) );
        --                         end; else then
        --                                 this.feedback( message );
        --                         end;
        --                 end;
        --         end;
        -- end;

        -- --
        -- -- @since 2.8.0
        -- -- @since 5.9.0 Renamed `string` (a PHP reserved keyword) to `feedback` for PHP 8 named parameter support.
        -- --
        -- -- @param string feedback Message data.
        -- -- @param mixed  ...args  Optional text replacements.
        -- --
        -- public function feedback( feedback, ...args ) then
        --         if ( isset( this.upgrader.strings[ feedback ] ) ) then
        --                 feedback = this.upgrader.strings[ feedback ];
        --         end;

        --         if ( strpos( feedback, "%" ) !== false ) then
        --                 if ( args ) then
        --                         args     = array_map( "strip_tags", args );
        --                         args     = array_map( "esc_html", args );
        --                         feedback = vsprintf( feedback, args );
        --                 end;
        --         end;
        --         if ( empty( feedback ) ) then
        --                 return;
        --         end;
        --         show_message( feedback );
        -- end;

        -- --
        -- -- Action to perform before an update.
        -- --
        -- -- @since 2.8.0
        -- --
        -- public function before() thenend;

        -- --
        -- -- Action to perform following an update.
        -- --
        -- -- @since 2.8.0
        -- --
        -- public function after() thenend;

        -- --
        -- -- Output JavaScript that calls function to decrement the update counts.
        -- --
        -- -- @since 3.9.0
        -- --
        -- -- @param string type Type of update count to decrement. Likely values include "plugin",
        -- --                     "theme", "translation", etc.
        -- --
        -- protected function decrement_update_count( type ) then
        --         if ( ! this.result || is_wp_error( this.result ) || "up_to_date" === this.result ) then
        --                 return;
        --         end;

        --         if ( defined( "IFRAME_REQUEST" ) ) then
        --                 echo "<script type="text/javascript">
        --                                 if ( window.postMessage && JSON ) then
        --                                         window.parent.postMessage( JSON.stringify( then action: "decrementUpdateCount", upgradeType: "" . type . "" end; ), window.location.protocol + "//" + window.location.hostname );
        --                                 end;
        --                         </script>";
        --         end; else then
        --                 echo "<script type="text/javascript">
        --                                 (function( wp ) then
        --                                         if ( wp && wp.updates && wp.updates.decrementCount ) then
        --                                                 wp.updates.decrementCount( "" . type . "" );
        --                                         end;
        --                                 end;)( window.wp );
        --                         </script>";
        --         end;
        -- end;

        -- --
        -- -- @since 3.0.0
        -- --
        -- public function bulk_header() thenend;

        -- --
        -- -- @since 3.0.0
        -- --
        -- public function bulk_footer() thenend;

        -- --
        -- -- Hides the `process_failed` error message when updating by uploading a zip file.
        -- --
        -- -- @since 5.5.0
        -- --
        -- -- @param WP_Error wp_error WP_Error object.
        -- -- @return bool
        -- --
        -- public function hide_process_failed( wp_error ) then
        --         return false;
        -- end;

end Adi_Class_Wp_Upgrader_Skins;
