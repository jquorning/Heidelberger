--
-- Option API
--
-- @package WordPress
-- @subpackage Option
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrays;
with Lists;

package Inc_Options
is
   use Arrays;
   use Lists;

   package String_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => String);

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
   --     array(3) {
   --         [0] => bool(false)
   --         [1] => string(3) "str"
   --         [2] => NULL
   --     }
   --
   -- @since 1.5.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string option  Name of the option to retrieve. Expected to not be
   --                       SQL-escaped.
   -- @param mixed  default Optional. Default value to return if the option does not
   --                       exist.
   -- @return mixed Value of the option. A value of any type may be returned, including
   --               scalar (string, boolean, float, integer), null, array, object.
   --               Scalar and null values will be returned as strings as long as
   --               they originate from a database stored option value. If there is
   --               no option in the database, boolean `false` is returned.
   --
   function Get_Option (Option  : String;
                        Default : Multi_Type := From_String (""))
                        return Multi_Type;

   function Get_Option (Option  : String;
                        Default : Array_Type := Empty_Array)
                        return Array_Type;

   function Get_Option (Option  : String;
                        Default : String := "")
                        return List_Type;

   function Get_Option (Option  : String;
                        Default : Integer := 0)
                        return Integer;

   function Get_Option (Option  : String;
                        Default : String := "")
                        return String;

   function Get_Option (Option  : String;
                        Default : String := "")
                        return Boolean;

   --
   -- Protects WordPress special option from being modified.
   --
   -- Will die if option is in protected list. Protected options are "alloptions"
   -- and "notoptions" options.
   --
   -- @since 2.2.0
   --
   -- @param string option Option name.
   --
   procedure Wp_Protect_Special_Option (Option : String);

   --
   -- Loads and caches all autoloaded options, if available or all options.
   --
   -- @since 2.2.0
   -- @since 5.3.1 The `force_cache` parameter was added.
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param bool force_cache Optional. Whether to force an update of the local cache
   --                          from the persistent cache. Default false.
   -- @return array List of all options.
   --
   function Wp_Load_Alloptions (Force_Cache : Boolean := False)
                                return Array_Type;

   --
   -- Removes option by name. Prevents removal of protected WordPress options.
   --
   -- @since 1.2.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string option Name of the option to delete. Expected to not be
   --                       SQL-escaped.
   -- @return bool True if the option was deleted, false otherwise.
   --
   function Delete_Option (Option : String)
                           return Boolean;

   procedure Delete_Option (Option : String);

   --
   -- Saves and restores user interface settings stored in a cookie.
   --
   -- Checks if the current user-settings cookie is updated and stores it. When no
   -- cookie exists (different browser used), adds the last saved cookie restoring
   -- the settings.
   --
   -- @since 2.7.0
   --
   procedure Wp_User_Settings;

   --
   -- Retrieve an option value for the current network based on name of option.
   --
   -- @since 2.8.0
   -- @since 4.4.0 The `use_cache` parameter was deprecated.
   -- @since 4.4.0 Modified into wrapper for get_network_option()
   --
   -- @see get_network_option()
   --
   -- @param string option     Name of the option to retrieve. Expected to not be
   --                          SQL-escaped.
   -- @param mixed  default    Optional. Value to return if the option doesn't exist.
   --                          Default false.
   -- @param bool   deprecated Whether to use cache. Multisite only. Always set to
   --                          true.
   -- @return mixed Value set for the option.
   --
   function Get_Site_Option (Option     : String;
                             Default    : Multi_Type := From_Boolean (False);
                             Deprecated : Boolean    := True)
                             return Multi_Type;

   -- function Get_Site_Option (Option     : String;
   --                           Default    : Boolean := False;
   --                           Deprecated : Boolean := True)
   --                           return Boolean
   --                           is (True);

   -- function Get_Site_Option (Option  : String;
   --                           Default : List_Type)
   --                           return Array_Type
   --                           is (Empty_Array);

   -- function Get_Site_Option (Option  : String;
   --                           Default : List_Type)
   --                           return List_Type
   --                           is ([]);

   -- function Get_Site_Option (Option  : String;
   --                           Default : List_Type := Empty_List)
   --                           return Natural
   --                           is (999);

   --
   -- Adds a new option for the current network.
   --
   -- Existing options will not be updated. Note that prior to 3.3 this wasn't the
   -- case.
   --
   -- @since 2.8.0
   -- @since 4.4.0 Modified into wrapper for add_network_option()
   --
   -- @see add_network_option()
   --
   -- @param string option Name of the option to add. Expected to not be SQL-escaped.
   -- @param mixed  value  Option value, can be anything. Expected to not be
   --                       SQL-escaped.
   -- @return bool True if the option was added, false otherwise.
   --
   function Add_Site_Option (Option : String;
                             Value  : Multi_Type)
                             return Boolean;

   procedure Add_Site_Option (Option : String;
                              Value  : Multi_Type);

   --
   -- Removes a option by name for the current network.
   --
   -- @since 2.8.0
   -- @since 4.4.0 Modified into wrapper for delete_network_option()
   --
   -- @see delete_network_option()
   --
   -- @param string option Name of the option to delete. Expected to not be
   --                       SQL-escaped.
   -- @return bool True if the option was deleted, false otherwise.
   --
   function Delete_Site_Option (Option : String)
                                return Boolean;

   procedure Delete_Site_Option (Option : String);

   --
   -- Retrieves a network's option value based on the option name.
   --
   -- @since 4.4.0
   --
   -- @see get_option()
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int    network_id ID of the network. Can be null to default to the
   --                          current network ID.
   -- @param string option     Name of the option to retrieve. Expected to not be
   --                          SQL-escaped.
   -- @param mixed  default    Optional. Value to return if the option doesn't exist.
   --                          Default false.
   -- @return mixed Value set for the option.
   --
   function Get_Network_Option (Network_Id : Integer;
                                Option     : String;
                                Default    : Multi_Type := From_Boolean (False))
                                return Multi_Type;

   --
   -- Adds a new network option.
   --
   -- Existing options will not be updated.
   --
   -- @since 4.4.0
   --
   -- @see add_option()
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int    network_id ID of the network. Can be null to default to the
   --                           current network ID.
   -- @param string option     Name of the option to add. Expected to not be
   --                           SQL-escaped.
   -- @param mixed  value      Option value, can be anything. Expected to not be
   --                           SQL-escaped.
   -- @return bool True if the option was added, false otherwise.
   --
   function Add_Network_Option (Network_Id : Integer;
                                Option     : String;
                                Value      : Multi_Type)
                                return Boolean;

   --
   -- Removes a network option by name.
   --
   -- @since 4.4.0
   --
   -- @see delete_option()
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int    network_id ID of the network. Can be null to default to the
   --                           current network ID.
   -- @param string option     Name of the option to delete. Expected to not be
   --                           SQL-escaped.
   -- @return bool True if the option was deleted, false otherwise.
   --
   function Delete_Network_Option (Network_Id : Integer;
                                   Option     : String)
                                   return Boolean;

   --
   -- Updates the value of a network option that was already added.
   --
   -- @since 4.4.0
   --
   -- @see update_option()
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param int    network_id ID of the network. Can be null to default to the
   --                           current network ID.
   -- @param string option     Name of the option. Expected to not be SQL-escaped.
   -- @param mixed  value      Option value. Expected to not be SQL-escaped.
   -- @return bool True if the value was updated, false otherwise.
   --
   function Update_Network_Option (Network_Id : Integer;
                                   Option     : String;
                                   Value      : Multi_Type)
                                   return Boolean;

   --
   -- Deletes a site transient.
   --
   -- @since 2.9.0
   --
   -- @param string transient Transient name. Expected to not be SQL-escaped.
   -- @return bool True if the transient was deleted, false otherwise.
   --
   procedure Delete_Site_Transient (Transient : String);

   --
   -- Updates the value of an option that was already added.
   --
   -- You do not need to serialize values. If the value needs to be serialized,
   -- then it will be serialized before it is inserted into the database.
   -- Remember, resources cannot be serialized or added as an option.
   --
   -- If the option does not exist, it will be created.
   --
   -- This function is designed to work with or without a logged-in user. In terms of
   -- security, plugin developers should check the current user"s capabilities before
   -- updating any options.
   --
   -- @since 1.0.0
   -- @since 4.2.0 The `autoload` parameter was added.
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string      option   Name of the option to update. Expected to not be
   --                             SQL-escaped.
   -- @param mixed       value    Option value. Must be serializable if non-scalar.
   --                             Expected to not be SQL-escaped.
   -- @param string|bool autoload Optional. Whether to load the option when WordPress
   --                             starts up. For existing options, `autoload` can only
   --                             be updated using `update_option()` if `value` is
   --                             also changed. Accepts "yes"|true to enable or
   --                             "no"|false to disable. For non-existent options,
   --                             the default value is "yes". Default null.
   -- @return bool True if the value was updated, false otherwise.
   --
   function Update_Option (Option   : String;
                           Value    : Multi_Type;
                           Autoload : Boolean := False)
                           return Boolean;

   procedure Update_Option (Option   : String;
                            Value    : Multi_Type;
                            Autoload : Boolean := False);

   -- function Update_Option (Option   : String;
   --                         Value    : Boolean;
   --                         Autoload : Boolean := False) -- = null
   --                         return Boolean
   --                         is (False);

   -- procedure Update_Option (Option   : String;
   --                          Value    : Array_Type;
   --                          Autoload : Boolean := False) -- = null
   --                          is null;

   -- procedure Update_Option (Option   : String;
   --                          Value    : String;
   --                          Autoload : Boolean := False) -- = null
   --                          is null;

   --
   -- Adds a new option.
   --
   -- You do not need to serialize values. If the value needs to be serialized,
   -- then it will be serialized before it is inserted into the database.
   -- Remember, resources cannot be serialized or added as an option.
   --
   -- You can create options without values and then update the values later.
   -- Existing options will not be updated and checks are performed to ensure that you
   -- aren't adding a protected WordPress option. Care should be taken to not name
   -- options the same as the ones which are protected.
   --
   -- @since 1.0.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string      option     Name of the option to add. Expected to not be
   --                                SQL-escaped.
   -- @param mixed       value      Optional. Option value. Must be serializable if
   --                                non-scalar. Expected to not be SQL-escaped.
   -- @param string      deprecated Optional. Description. Not used anymore.
   -- @param string|bool autoload   Optional. Whether to load the option when
   --                                WordPress starts up. Default is enabled. Accepts
   --                                "no" to disable for legacy reasons.
   -- @return bool True if the option was added, false otherwise.
   --
   function Add_Option (Option     : String;
                        Value      : Multi_Type := From_String ("");
                        Deprecated : String     := "";
                        Autoload   : Boolean    := True) -- "yes"
                        return Boolean;

   procedure Add_Option (Option     : String;
                         Value      : Multi_Type := From_String ("");
                         Deprecated : String     := "";
                         Autoload   : Boolean    := True); -- "yes"

   --
   -- Updates the value of an option that was already added for the current network.
   --
   -- @since 2.8.0
   -- @since 4.4.0 Modified into wrapper for update_network_option()
   --
   -- @see update_network_option()
   --
   -- @param string option Name of the option. Expected to not be SQL-escaped.
   -- @param mixed  value  Option value. Expected to not be SQL-escaped.
   -- @return bool True if the value was updated, false otherwise.
   --
   function Update_Site_Option (Option : String;
                                Value  : Multi_Type)
                                return Boolean;

   procedure Update_Site_Option (Option : String;
                                 Value  : Multi_Type);

   --
   -- Retrieves user interface setting value based on setting name.
   --
   -- @since 2.7.0
   --
   -- @param string       name    The name of the setting.
   -- @param string|false default Optional. Default value to return when name is not
   --                             set. Default false.
   -- @return mixed The last saved user setting or the default value/false if it
   --               doesn't exist.
   --
   function Get_User_Setting (Name    : String;
                              Default : String := "")
                              return Multi_Type;

   --
   -- Deletes user interface settings.
   --
   -- Deleting settings would reset them to the defaults.
   --
   -- This function has to be used before any output has started as it calls
   -- `setcookie()`.
   --
   -- @since 2.7.0
   --
   -- @param string names The name or array of names of the setting to be deleted.
   -- @return bool|null True if deleted successfully, false otherwise.
   --                   Null if the current user is not a member of the site.
   --
   function Delete_User_Setting (Names : String)
                                 return Boolean;

   procedure Delete_User_Setting (Names : String);

   --
   -- Retrieves all user interface settings.
   --
   -- @since 2.7.0
   --
   -- @global array _updated_user_settings
   --
   -- @return array The last saved user settings or empty array.
   --
   function Get_All_User_Settings
            return Array_Type;

   --
   -- Private. Sets all user interface settings.
   --
   -- @since 2.8.0
   -- @access private
   --
   -- @global array _updated_user_settings
   --
   -- @param array user_settings User settings.
   -- @return bool|null True if set successfully, false if the current user could
   --                   not be found. Null if the current user is not a member of
   --                   the site.
   --
   function Wp_Set_All_User_Settings (User_Settings : Array_Type)
                                      return Boolean;

   procedure Wp_Set_All_User_Settings (User_Settings : Array_Type);

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
                           return Multi_Type;

   --
   -- Sets/updates the value of a transient.
   --
   -- You do not need to serialize values. If the value needs to be serialized,
   -- then it will be serialized before it is set.
   --
   -- @since 2.8.0
   --
   -- @param string transient  Transient name. Expected to not be SQL-escaped.
   --                           Must be 172 characters or fewer in length.
   -- @param mixed  value      Transient value. Must be serializable if non-scalar.
   --                           Expected to not be SQL-escaped.
   -- @param int    expiration Optional. Time until expiration in seconds. Default 0
   --                           (no expiration).
   -- @return bool True if the value was set, false otherwise.
   --
   function Set_Transient (Transient  : String;
                           Value      : Multi_Type;
                           Expiration : Integer := 0)
                           return Boolean;

   procedure Set_Transient (Transient  : String;
                            Value      : Multi_Type;
                            Expiration : Integer := 0);

   --
   -- Deletes all expired transients.
   --
   -- Note that this function won"t do anything if an external object cache is in use.
   --
   -- The multi-table delete syntax is used to delete the transient record
   -- from table a, and the corresponding transient_timeout record from table b.
   --
   -- @since 4.9.0
   --
   -- @param bool force_db Optional. Force cleanup to run against the database even
   --                       when an external object cache is used.
   --
   procedure Delete_Expired_Transients (Force_DB : Boolean := False);

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
                                return String_Maps.Map;

   --
   -- Sets/updates the value of a site transient.
   --
   -- You do not need to serialize values. If the value needs to be serialized,
   -- then it will be serialized before it is set.
   --
   -- @since 2.9.0
   --
   -- @see set_transient()
   --
   -- @param string transient  Transient name. Expected to not be SQL-escaped. Must be
   --                           167 characters or fewer in length.
   -- @param mixed  value      Transient value. Expected to not be SQL-escaped.
   -- @param int    expiration Optional. Time until expiration in seconds. Default
   --                           0 (no expiration).
   -- @return bool True if the value was set, false otherwise.
   --
   function Set_Site_Transient (Transient  : String;
                                Value      : Array_Type;
                                Expiration : Integer := 0)
                                return Boolean;

   procedure Set_Site_Transient (Transient  : String;
                                 Value      : Array_Type;
                                 Expiration : Integer := 0);

end Inc_Options;
