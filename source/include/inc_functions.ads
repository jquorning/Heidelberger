with Arrays;

with Inc_Class_Wp_Terms;
with Inc_Taxonomys;

package Inc_Functions
is
   use Arrays;

--
-- Plucks a certain field out of each object or array in an array.
--
-- This has the same functionality and prototype of
-- array_column() (PHP 5.5) but also supports objects.
--
-- @since 3.1.0
-- @since 4.0.0 $index_key parameter added.
-- @since 4.7.0 Uses `WP_List_Util` class.
--
-- @param array      $list      List of objects or arrays.
-- @param int|string $field     Field from the object to place instead of the entire object.
-- @param int|string $index_key Optional. Field from the object to use as keys for the new array.
--                              Default null.
-- @return array Array of found values. If `$index_key` is set, an array of found values with keys
--               corresponding to `$index_key`. If `$index_key` is null, array keys from the original
--               `$list` will be preserved in the results.
--
   function Wp_List_Pluck (List      : Array_Type;
                           Field     : String;
                           Index_Key : String := "")  -- null)
                           return Array_Type;
   function Wp_List_Pluck (List      : Inc_Class_Wp_Terms.Wp_Term_Array;
                           Field     : String;
                           Index_Key : String := "")  -- null)
                           return Array_Type is (Empty_Array);
--
-- Marks something as being incorrectly called.
--
-- There is a hook then@see 'doing_it_wrong_run'end; that will be called that can be used
-- to get the backtrace up to what file and function called the deprecated
-- function.
--
-- The current behavior is to trigger a user error if `WP_DEBUG` is true.
--
-- @since 3.1.0
-- @since 5.4.0 This function is no longer marked as "private".
--
-- @param string $function The function that was called.
-- @param string $message  A message explaining what has been done incorrectly.
-- @param string $version  The version of WordPress where the message was added.
--
   procedure X_Doing_It_Wrong (Funct   : String;
                               Message : String;
                               Version : String);

--
-- Merges user defined arguments into defaults array.
--
-- This function is used throughout WordPress to allow for both string or array
-- to be merged into another array.
--
-- @since 2.2.0
-- @since 2.3.0 `$args` can now also be an object.
--
-- @param string|array|object $args     Value to merge with $defaults.
-- @param array               $defaults Optional. Array that serves as the defaults.
--                                      Default empty array.
-- @return array Merged user defined values with defaults.
--
   function Wp_Parse_Args (Args     : Array_Type;
                           Defaults : Array_Type := Empty_Array)
                           return Array_Type;
--
-- Returns an array of single-use query variable names that can be removed from a URL.
--
-- @since 4.4.0
--
-- @return string[] An array of query variable names to remove from the URL.
--
   function Wp_Removable_Query_Args
            return String_Array
            is (Empty_String_Array);

--
-- Determines whether a site is the main site of the current network.
--
-- @since 3.0.0
-- @since 4.9.0 The `$network_id` parameter was added.
--
-- @param int $site_id    Optional. Site ID to test. Defaults to current site.
-- @param int $network_id Optional. Network ID of the network to check for.
--                        Defaults to current network.
-- @return bool True if $site_id is the main site of the network, or if not
--              running Multisite.
--
   function Is_Main_Site (Site_Id    : Integer := 0; -- = null,
                          Network_Id : Integer := 0) -- = null
                          return Boolean is (False);

--
-- Converts float number to format based on the locale.
--
-- @since 2.3.0
--
-- @global WP_Locale $wp_locale WordPress date and time locale object.
--
-- @param float $number   The number to convert based on locale.
-- @param int   $decimals Optional. Precision of the number of decimal places. Default 0.
-- @return string Converted number in string format.
--
   function Number_Format_I18n (Number   : Float;
                                Decimals : Integer := 0)
                                return String
                                is ("XXX-302");
--
-- Removes an item or items from a query string.
--
-- @since 1.5.0
--
-- @param string|string[] $key   Query key or keys to remove.
-- @param false|string    $query Optional. When false uses the current URL. Default false.
-- @return string New URL query string.
--
   function Remove_Query_Arg (Key   : String;
                              Query : String := "") -- False)
                              return String
                              is ("XXX-304");
   function Remove_Query_Arg (Key   : String_Array;
                              Query : String := "") -- False)
                              return String
                              is ("XXX-305");


end Inc_Functions;
