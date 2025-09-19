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
-- Marks a function as deprecated and inform when it has been used.
--
-- There is a hook then@see 'deprecated_function_run'end; that will be called that can be used
-- to get the backtrace up to what file and function called the deprecated
-- function.
--
-- The current behavior is to trigger a user error if `WP_DEBUG` is true.
--
-- This function is to be used in every function that is deprecated.
--
-- @since 2.5.0
-- @since 5.4.0 This function is no longer marked as "private".
-- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to default to E_USER_NOTICE).
--
-- @param string $function    The function that was called.
-- @param string $version     The version of WordPress that deprecated the function.
-- @param string $replacement Optional. The function that should have been called. Default empty.
--
   procedure X_Deprecated_Function (Funct       : String;
                                    Version     : String;
                                    Replacement : String := "")
                                    is null;


--
-- Marks a function argument as deprecated and inform when it has been used.
--
-- This function is to be used whenever a deprecated function argument is used.
-- Before this function is called, the argument must be checked for whether it was
-- used by comparing it to its default value or evaluating whether it is empty.
-- For example:
--
--     if ( ! empty( $deprecated ) ) then
--         _deprecated_argument( __FUNCTION__, '3.0.0' );
--     end;
--
-- There is a hook deprecated_argument_run that will be called that can be used
-- to get the backtrace up to what file and function used the deprecated
-- argument.
--
-- The current behavior is to trigger a user error if WP_DEBUG is true.
--
-- @since 3.0.0
-- @since 5.4.0 This function is no longer marked as "private".
-- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to default to E_USER_NOTICE).
--
-- @param string $function The function that was called.
-- @param string $version  The version of WordPress that deprecated the argument used.
-- @param string $message  Optional. A message regarding the change. Default empty.
--
   procedure X_Deprecated_Argument (Funct   : String;
                                    Version : String;
                                    Message : String := "")
                                    is null;

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

--
-- Kills WordPress execution and displays HTML page with an error message.
--
-- This function complements the `die()` PHP function. The difference is that
-- HTML will be displayed to the user. It is recommended to use this function
-- only when the execution should not continue any further. It is not recommended
-- to call this function very often, and try to handle as many errors as possible
-- silently or more gracefully.
--
-- As a shorthand, the desired HTTP response code may be passed as an integer to
-- the `$title` parameter (the default title would apply) or the `$args` parameter.
--
-- @since 2.0.4
-- @since 4.1.0 The `$title` and `$args` parameters were changed to optionally accept
--              an integer to be used as the response code.
-- @since 5.1.0 The `$link_url`, `$link_text`, and `$exit` arguments were added.
-- @since 5.3.0 The `$charset` argument was added.
-- @since 5.5.0 The `$text_direction` argument has a priority over get_language_attributes()
--              in the default handler.
--
-- @global WP_Query $wp_query WordPress Query object.
--
-- @param string|WP_Error  $message Optional. Error message. If this is a WP_Error object,
--                                  and not an Ajax or XML-RPC request, the error's messages are used.
--                                  Default empty.
-- @param string|int       $title   Optional. Error title. If `$message` is a `WP_Error` object,
--                                  error data with the key 'title' may be used to specify the title.
--                                  If `$title` is an integer, then it is treated as the response
--                                  code. Default empty.
-- @param string|array|int $args {
--     Optional. Arguments to control behavior. If `$args` is an integer, then it is treated
--     as the response code. Default empty array.
--
--     @type int    $response       The HTTP response code. Default 200 for Ajax requests, 500 otherwise.
--     @type string $link_url       A URL to include a link to. Only works in combination with $link_text.
--                                  Default empty string.
--     @type string $link_text      A label for the link to include. Only works in combination with $link_url.
--                                  Default empty string.
--     @type bool   $back_link      Whether to include a link to go back. Default false.
--     @type string $text_direction The text direction. This is only useful internally, when WordPress is still
--                                  loading and the site's locale is not set up yet. Accepts 'rtl' and 'ltr'.
--                                  Default is the value of is_rtl().
--     @type string $charset        Character set of the HTML output. Default 'utf-8'.
--     @type string $code           Error code to use. Default is 'wp_die', or the main error code if $message
--                                  is a WP_Error.
--     @type bool   $exit           Whether to exit the process after completion. Default true.
-- }
--
   procedure Wp_Die (Message : String  := "";
                     Title   : String  := "";
                     Code    : Integer := 0) -- , $args = array() ) then
                     is null;
--
-- Encodes a variable into JSON, with some sanity checks.
--
-- @since 4.1.0
-- @since 5.3.0 No longer handles support for PHP < 5.6.
--
-- @param mixed $data    Variable (usually an array or object) to encode as JSON.
-- @param int   $options Optional. Options to be passed to json_encode(). Default 0.
-- @param int   $depth   Optional. Maximum depth to walk through $data. Must be
--                       greater than 0. Default 512.
-- @return string|false The JSON encoded string, or false if it cannot be encoded.
--
   function Wp_Json_Encode (Data    : Array_Type;
                            Options : Integer := 0;
                            Depth   : Integer := 512)
                            return String
                            is ("XXX-305");

end Inc_Functions;
