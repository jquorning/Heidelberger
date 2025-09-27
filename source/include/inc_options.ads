with Arrays;

package Inc_Options
is
   use Arrays;

   --
   -- Retrieves an option value based on an option name.
   --
   -- If the option does not exist, and a default value is not provided,
   -- boolean false is returned. This could be used to check whether you need
   -- to initialize an option during installation of a plugin, however that
   -- can be done better by using add_option() which will not overwrite
   -- existing options.
   --
   -- Not initializing an option and using boolean `false` as a return value
   -- is a bad practice as it triggers an additional database query.
   --
   -- The type of the returned value can be different from the type that was passed
   -- when saving or updating the option. If the option value was serialized,
   -- then it will be unserialized when it is returned. In this case the type will
   -- be the same. For example, storing a non-scalar value like an array will
   -- return the same array.
   --
   -- In most cases non-string scalar and null values will be converted and returned
   -- as string equivalents.
   --
   -- Exceptions:
   --
   -- 1. When the option has not been saved in the database, the `default` value
   --    is returned if provided. If not, boolean `false` is returned.
   -- 2. When one of the Options API filters is used: {@see "pre_option_option"},
   --    {@see "default_option_option"}, or {@see "option_option"}, the returned
   --    value may not match the expected type.
   -- 3. When the option has just been saved in the database, and get_option()
   --    is used right after, non-string scalar and null values are not converted to
   --    string equivalents and the original type is returned.
   --
   -- Examples:
   --
   -- When adding options like this: `add_option( "my_option_name", "value" )`
   -- and then retrieving them with `get_option( "my_option_name" )`, the returned
   -- values will be:
   --
   --   - `false` returns `string(0) ""`
   --   - `true`  returns `string(1) "1"`
   --   - `0`     returns `string(1) "0"`
   --   - `1`     returns `string(1) "1"`
   --   - `"0"`   returns `string(1) "0"`
   --   - `"1"`   returns `string(1) "1"`
   --   - `null`  returns `string(0) ""`
   --
   -- When adding options with non-scalar values like
   -- `add_option( "my_array", array( false, "str", null ) )`, the returned value
   -- will be identical to the original as it is serialized before saving
   -- it in the database:
   --
   --     array(3) then
   --         [0] => bool(false)
   --         [1] => string(3) "str"
   --         [2] => NULL
   --     end;
   --
   -- @since 1.5.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string option  Name of the option to retrieve. Expected to not be SQL-escaped.
   -- @param mixed  default Optional. Default value to return if the option does not exist.
   -- @return mixed Value of the option. A value of any type may be returned, including
   --               scalar (string, boolean, float, integer), null, array, object.
   --               Scalar and null values will be returned as strings as long as they originate
   --               from a database stored option value. If there is no option in the database,
   --               boolean `false` is returned.
   --
--   function get_option( option, default = false ) then
   function Get_Option (Option : String)
                        return Array_Type
                        is (Empty_Array);

   function Get_Option (Option : String)
                        return Integer
                        is (1);

   function Get_Option (Option : String)
                        return String;

   --
   -- Saves and restores user interface settings stored in a cookie.
   --
   -- Checks if the current user-settings cookie is updated and stores it. When no
   -- cookie exists (different browser used), adds the last saved cookie restoring
   -- the settings.
   --
   -- @since 2.7.0
   --
   procedure Wp_User_Settings
             is null;

--
-- Updates the value of an option that was already added.
--
-- You do not need to serialize values. If the value needs to be serialized,
-- then it will be serialized before it is inserted into the database.
-- Remember, resources cannot be serialized or added as an option.
--
-- If the option does not exist, it will be created.

-- This function is designed to work with or without a logged-in user. In terms of security,
-- plugin developers should check the current user"s capabilities before updating any options.
--
-- @since 1.0.0
-- @since 4.2.0 The `autoload` parameter was added.
--
-- @global wpdb wpdb WordPress database abstraction object.
--
-- @param string      option   Name of the option to update. Expected to not be SQL-escaped.
-- @param mixed       value    Option value. Must be serializable if non-scalar. Expected to not be SQL-escaped.
-- @param string|bool autoload Optional. Whether to load the option when WordPress starts up. For existing options,
--                              `autoload` can only be updated using `update_option()` if `value` is also changed.
--                              Accepts "yes"|true to enable or "no"|false to disable. For non-existent options,
--                              the default value is "yes". Default null.
-- @return bool True if the value was updated, false otherwise.
--
   function Update_Option (Option   : String;
                           Value    : Boolean;
                           Autoload : Boolean := False) -- = null
                           return Boolean
                           is (False);
   --
   -- Retrieves user interface setting value based on setting name.
   --
   -- @since 2.7.0
   --
   -- @param string       name    The name of the setting.
   -- @param string|false default Optional. Default value to return when name is not set. Default false.
   -- @return mixed The last saved user setting or the default value/false if it doesn"t exist.
   --
   function Get_User_Setting (Name    : String;
                              Default : Boolean := False)
                              return String
                              is ("XXX-601");

--
-- Retrieves the value of a transient.
--
-- If the transient does not exist, does not have a value, or has expired,
-- then the return value will be false.
--
-- @since 2.8.0
--
-- @param string transient Transient name. Expected to not be SQL-escaped.
-- @return mixed Value of transient.
--
   function Get_Transient (Transient : String)
                           return String is ("XXX-302");

   --
   -- Retrieves the value of a site transient.
   --
   -- If the transient does not exist, does not have a value, or has expired,
   -- then the return value will be false.
   --
   -- @since 2.9.0
   --
   -- @see get_transient()
   --
   -- @param string transient Transient name. Expected to not be SQL-escaped.
   -- @return mixed Value of transient.
   --
   function Get_Site_Transient (Transient : String)
                                return Array_Type
                                is (Empty_Array);

   procedure Dummy;

end Inc_Options;
