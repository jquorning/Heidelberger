--
-- WordPress Error API.
--
-- @package WordPress
--

with Arrays;
with Lists;

package Inc_Class_Wp_Errors
is
   use Arrays;
   use Lists;

   --
   -- WordPress Error class.
   --
   -- Container for checking for WordPress errors and error messages. Return
   -- WP_Error and use is_wp_error() to check if this class is returned. Many
   -- core WordPress functions pass this class in the event of an error and
   -- if not handled properly will result in code errors.
   --
   -- @since 2.1.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Error is tagged
      record
         --
         -- Stores the list of errors.
         --
         -- @since 2.1.0
         -- @var array
         --
         Errors : Array_Type;

         --
         -- Stores the most recently added data for each error code.
         --
         -- @since 2.1.0
         -- @var array
         --
         Error_Data : Array_Type;

         --
         -- Stores previously added data added for error codes, oldest-to-newest by
         --  code.
         --
         -- @since 5.6.0
         -- @var array[]
         --
         -- protected
         Additional_Data : Array_Type;

      end record;

   --
   -- Initializes the error.
   --
   -- If `code` is empty, the other parameters will be ignored.
   -- When `code` is not empty, `message` will be used even if
   -- it is empty. The `data` parameter will be used only if it
   -- is not empty.
   --
   -- Though the class is constructed with a single error code and
   -- message, multiple codes can be added using the `add()` method.
   --
   -- @since 2.1.0
   --
   -- @param string|int code    Error code.
   -- @param string     message Error message.
   -- @param mixed      data    Optional. Error data.
   --
   function X_Construct (Code    : String := "";
                         Message : String := "";
                         Data    : String := "")
                         return Wp_Error;

   --
   -- Retrieves all error codes.
   --
   -- @since 2.1.0
   --
   -- @return array List of error codes, if available.
   --
   function Get_Error_Codes (This : Wp_Error)
                             return List_Type;

   --
   -- Retrieves the first error code available.
   --
   -- @since 2.1.0
   --
   -- @return string|int Empty string, if no error codes.
   --
   function Get_Error_Code (This : Wp_Error)
                            return String;

   --
   -- Retrieves all error messages, or the error messages for the given error code.
   --
   -- @since 2.1.0
   --
   -- @param string|int code Optional. Retrieve messages matching code, if exists.
   -- @return string[] Error strings on success, or empty array if there are none.
   --
   function Get_Error_Messages (This : Wp_Error;
                                Code : String := "")
                                return List_Type;

        -- --
        -- -- Gets a single error message.
        -- --
        -- -- This will get the first message available for the code. If no code is
        -- -- given then the first code available will be used.
        -- --
        -- -- @since 2.1.0
        -- --
        -- -- @param string|int code Optional. Error code to retrieve message.
        -- -- @return string The error message.
        -- --
        -- public function get_error_message( code = '' ) then
        --         if ( empty( code ) ) then
        --                 code = this->get_error_code();
        --         end;
        --         messages = this->get_error_messages( code );
        --         if ( empty( messages ) ) then
        --                 return '';
        --         end;
        --         return messages[0];
        -- end;

   --
   -- Retrieves the most recently added error data for an error code.
   --
   -- @since 2.1.0
   --
   -- @param string|int code Optional. Error code.
   -- @return mixed Error data, if it exists.
   --
   function Get_Error_Data (This : Wp_Error;
                            Code : String := "")
                            return String;

   --
   -- Verifies if the instance contains errors.
   --
   -- @since 5.1.0
   --
   -- @return bool If the instance contains errors.
   --
   function Has_Errors (This : Wp_Error)
                        return Boolean;
        --         if ( ! empty( this->errors ) ) then
        --                 return true;
        --         end;
        --         return false;
        -- end;

   --
   -- Adds an error or appends an additional message to an existing error.
   --
   -- @since 2.1.0
   --
   -- @param string|int code    Error code.
   -- @param string     message Error message.
   -- @param mixed      data    Optional. Error data.
   --
   procedure Add (This    : in out Wp_Error;
                  Code    : String;
                  Message : String;
                  Data    : String := "");

   --
   -- Adds data to an error with the given code.
   --
   -- @since 2.1.0
   -- @since 5.6.0 Errors can now contain more than one item of error data. then@see WP_Error::additional_dataend;.
   --
   -- @param mixed      data Error data.
   -- @param string|int code Error code.
   --
   procedure Add_Data (This : in out Wp_Error;
                       Data : String;
                       Code : String := "");

        -- --
        -- -- Retrieves all error data for an error code in the order in which the data was added.
        -- --
        -- -- @since 5.6.0
        -- --
        -- -- @param string|int code Error code.
        -- -- @return mixed[] Array of error data, if it exists.
        -- --
        -- public function get_all_error_data( code = '' ) then
        --         if ( empty( code ) ) then
        --                 code = this->get_error_code();
        --         end;

        --         data = array();

        --         if ( isset( this->additional_data[ code ] ) ) then
        --                 data = this->additional_data[ code ];
        --         end;

        --         if ( isset( this->error_data[ code ] ) ) then
        --                 data[] = this->error_data[ code ];
        --         end;

        --         return data;
        -- end;

        -- --
        -- -- Removes the specified error.
        -- --
        -- -- This function removes all error messages associated with the specified
        -- -- error code, along with any error data for that code.
        -- --
        -- -- @since 4.1.0
        -- --
        -- -- @param string|int code Error code.
        -- --
        -- public function remove( code ) then
        --         unset( this->errors[ code ] );
        --         unset( this->error_data[ code ] );
        --         unset( this->additional_data[ code ] );
        -- end;

        -- --
        -- -- Merges the errors in the given error object into this one.
        -- --
        -- -- @since 5.6.0
        -- --
        -- -- @param WP_Error error Error object to merge.
        -- --
        -- public function merge_from( WP_Error error ) then
        --         static::copy_errors( error, this );
        -- end;

        -- --
        -- -- Exports the errors in this object into the given one.
        -- --
        -- -- @since 5.6.0
        -- --
        -- -- @param WP_Error error Error object to export into.
        -- --
        -- public function export_to( WP_Error error ) then
        --         static::copy_errors( this, error );
        -- end;

        -- --
        -- -- Copies errors from one WP_Error instance to another.
        -- --
        -- -- @since 5.6.0
        -- --
        -- -- @param WP_Error from The WP_Error to copy from.
        -- -- @param WP_Error to   The WP_Error to copy to.
        -- --
        -- protected static function copy_errors( WP_Error from, WP_Error to ) then
        --         foreach ( from->get_error_codes() as code ) then
        --                 foreach ( from->get_error_messages( code ) as error_message ) then
        --                         to->add( code, error_message );
        --                 end;

        --                 foreach ( from->get_all_error_data( code ) as data ) then
        --                         to->add_data( data, code );
        --                 end;
        --         end;
        -- end;

   Null_Wp_Error : constant Wp_Error :=
     (Errors          => Empty_Array,
      Error_Data      => Empty_Array,
      Additional_Data => Empty_Array);

end Inc_Class_Wp_Errors;
