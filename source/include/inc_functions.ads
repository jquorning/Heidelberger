with Arrays;

with Inc_Class_Wp_Terms;

package Inc_Functions
is
   use Arrays;

   Program_Die : exception;

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
   -- @param int|string $field     Field from the object to place instead of the
   --                              entire object.
   -- @param int|string $index_key Optional. Field from the object to use as keys for
   --                              the new array. Default null.
   -- @return array Array of found values. If `$index_key` is set, an array of found
   --               values with keys corresponding to `$index_key`. If `$index_key`
   --               is null, array keys from the original `$list` will be preserved
   --               in the results.
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
   -- Builds URL query based on an associative and, or indexed array.
   --
   -- This is a convenient function for easily building url queries. It sets the
   -- separator to '&' and uses _http_build_query() function.
   --
   -- @since 2.3.0
   --
   -- @see _http_build_query() Used to build the query
   -- @link https://www.php.net/manual/en/function.http-build-query.php for more on
   --       what http_build_query() does.
   --
   -- @param array $data URL-encode key/value pairs.
   -- @return string URL-encoded string.
   --
   function Build_Query (Data : Array_Type)
                         return String;

   --
   -- From php.net (modified by Mark Jaquith to behave like the native PHP5 function).
   --
   -- @since 3.2.0
   -- @access private
   --
   -- @see https://www.php.net/manual/en/function.http-build-query.php
   --
   -- @param array|object $data      An array or object of data. Converted to array.
   -- @param string       $prefix    Optional. Numeric index. If set, start parameter
   --                                numbering with it. Default null.
   -- @param string       $sep       Optional. Argument separator; defaults to
   --                                'arg_separator.output'. Default null.
   -- @param string       $key       Optional. Used to prefix key name. Default empty.
   -- @param bool         $urlencode Optional. Whether to use urlencode() in the
   --                                result. Default true.
   -- @return string The query string.
   --
   function X_HTTP_Build_Query (Data      : Array_Type;
                                Prefix    : String := ""; -- null
                                Sep       : String := ""; -- null
                                Key       : String := "";
                                URLencode : Boolean := True)
                                return String;

   --
   -- Retrieves a modified URL query string.
   --
   -- You can rebuild the URL and append query variables to the URL query by using
   -- this function. There are two ways to use this function; either a single key
   -- and value, or an associative array.
   --
   -- Using a single key and value:
   --
   --     add_query_arg( 'key', 'value', 'http://example.com' );
   --
   -- Using an associative array:
   --
   --     add_query_arg( array(
   --         'key1' => 'value1',
   --         'key2' => 'value2',
   --     ), 'http://example.com' );
   --
   -- Omitting the URL from either use results in the current URL being used
   -- (the value of `$_SERVER['REQUEST_URI']`).
   --
   -- Values are expected to be encoded appropriately with urlencode() or
   -- rawurlencode().
   --
   -- Setting any query variable's value to boolean false removes the key (see
   -- remove_query_arg()).
   --
   -- Important: The return value of add_query_arg() is not escaped by default.
   -- Output should be late-escaped with esc_url() or similar to help prevent
   -- vulnerability to cross-site scripting (XSS) attacks.
   --
   -- @since 1.5.0
   -- @since 5.3.0 Formalized the existing and already documented parameters
   --              by adding `...$args` to the function signature.
   --
   -- @param string|array $key   Either a query variable key, or an associative
   --                            array of query variables.
   -- @param string       $value Optional. Either a query variable value, or a URL
   --                            to act upon.
   -- @param string       $url   Optional. A URL to act upon.
   -- @return string New URL query string (unescaped).
   --
   -- function add_query_arg( ...$args ) then

   function Add_Query_Arg (Key   : String;
                           Value : String;
                           URL   : String := "")
                           return String;

   function Add_Query_Arg (Key   : List_Type;
                           Value : String;
                           URL   : String := "")
                           return String;

   function Add_Query_Arg (Key   : Array_Type;
                           Value : String;
                           URL   : String := "")
                           return String;

   --
   -- Walks the array while sanitizing the contents.
   --
   -- @since 0.71
   -- @since 5.5.0 Non-string values are left untouched.
   --
   -- @param array $array Array to walk while sanitizing contents.
   -- @return array Sanitized $array.
   --
   function Add_Magic_Quotes (Arry : Array_Type)
            return Array_Type;

   --
   -- Marks a function as deprecated and inform when it has been used.
   --
   -- There is a hook {@see 'deprecated_function_run'} that will be called that can
   -- be used to get the backtrace up to what file and function called the deprecated
   -- function.
   --
   -- The current behavior is to trigger a user error if `WP_DEBUG` is true.
   --
   -- This function is to be used in every function that is deprecated.
   --
   -- @since 2.5.0
   -- @since 5.4.0 This function is no longer marked as "private".
   -- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to
   --              default to E_USER_NOTICE).
   --
   -- @param string $function    The function that was called.
   -- @param string $version     The version of WordPress that deprecated the function.
   -- @param string $replacement Optional. The function that should have been called.
   --                            Default empty.
   --
   procedure X_Deprecated_Function (Funct       : String;
                                    Version     : String;
                                    Replacement : String := "")
                                    is null;

   --
   -- Sets the headers to prevent caching for the different browsers.
   --
   -- Different browsers support different nocache headers, so several
   -- headers must be sent so that all of them get the point that no
   -- caching should occur.
   --
   -- @since 2.0.0
   --
   -- @see wp_get_nocache_headers()
   --
   procedure Nocache_Headers is null;

   --
   -- Retrieves URL with nonce added to URL query.
   --
   -- @since 2.0.4
   --
   -- @param string     $actionurl URL to add nonce action.
   -- @param int|string $action    Optional. Nonce action name. Default -1.
   -- @param string     $name      Optional. Nonce name. Default '_wpnonce'.
   -- @return string Escaped URL with nonce action added.
   --
   function Wp_Nonce_Url (Actionurl : String;
                          Action    : String := "-1";
                          Name      : String := "_wpnonce")
                          return String
                          is ("XXX-466");

   --
   -- Retrieves or display nonce hidden field for forms.
   --
   -- The nonce field is used to validate that the contents of the form came from
   -- the location on the current site and not somewhere else. The nonce does not
   -- offer absolute protection, but should protect against most cases. It is very
   -- important to use nonce field in forms.
   --
   -- The $action and $name are optional, but if you want to have better security,
   -- it is strongly suggested to set those two parameters. It is easier to just
   -- call the function without any parameters, because validation of the nonce
   -- doesn't require any parameters, but since crackers know what the default is
   -- it won't be difficult for them to find a way around your nonce and cause
   -- damage.
   --
   -- The input name will be whatever $name value you gave. The input value will be
   -- the nonce creation value.
   --
   -- @since 2.0.4
   --
   -- @param int|string $action  Optional. Action name. Default -1.
   -- @param string     $name    Optional. Nonce name. Default '_wpnonce'.
   -- @param bool       $referer Optional. Whether to set the referer field for
   --                             validation. Default true.
   -- @param bool       $echo    Optional. Whether to display or return hidden form
   --                             field. Default true.
   -- @return string Nonce field HTML markup.
   --
   function Wp_Nonce_Field (Action  : String  := "-1"; -- = -1
                            Name    : String  := "_wpnonce";
                            Referer : Boolean := True;
                            Echo    : Boolean := True)
                            return String;

   --
   -- Retrieves or displays referer hidden field for forms.
   --
   -- The referer link is the current Request URI from the server super global. The
   -- input name is '_wp_http_referer', in case you wanted to check manually.
   --
   -- @since 2.0.4
   --
   -- @param bool $echo Optional. Whether to echo or return the referer field. Default
   --                              true.
   -- @return string Referer field HTML markup.
   --
   function Wp_Referer_Field (Echo : Boolean := True)
                              return String;

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
   -- @since 5.4.0 The error type is now classified as E_USER_DEPRECATED (used to
   --              default to E_USER_NOTICE).
   --
   -- @param string $function The function that was called.
   -- @param string $version  The version of WordPress that deprecated the argument
   --                         used.
   -- @param string $message  Optional. A message regarding the change. Default empty.
   --
   procedure X_Deprecated_Argument (Funct   : String;
                                    Version : String;
                                    Message : String := "")
                                    is null;

   --
   -- Retrieves referer from '_wp_http_referer' or HTTP referer.
   --
   -- If it's the same as the current request URL, will return false.
   --
   -- @since 2.0.4
   --
   -- @return string|false Referer URL on success, false on failure.
   --
   function Wp_Get_Referer
            return String
            is ("XXX-465");

   --
   -- Marks something as being incorrectly called.
   --
   -- There is a hook {@see 'doing_it_wrong_run'} that will be called that can be used
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
   function Wp_Parse_Args (Args     : String;
                           Defaults : Array_Type := Empty_Array)
                           return Array_Type;

   function Wp_Parse_Args (Args     : Array_Type;
                           Defaults : Array_Type := Empty_Array)
                           return Array_Type;

   function Wp_Parse_Args (Args     : Boolean;
                           Defaults : Array_Type := Empty_Array)
                           return Array_Type;

   --
   -- Returns an array of single-use query variable names that can be removed from a
   -- URL.
   --
   -- @since 4.4.0
   --
   -- @return string[] An array of query variable names to remove from the URL.
   --
   function Wp_Removable_Query_Args
            return String_Array
            is (Empty_String_Array);

   function Wp_Removable_Query_Args
            return List_Type
            is (Empty_List);

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
   -- @param int   $decimals Optional. Precision of the number of decimal places.
   --                        Default 0.
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
   -- @param false|string    $query Optional. When false uses the current URL. Default
   --                               false.
   -- @return string New URL query string.
   --
   function Remove_Query_Arg (Key   : String;
                              Query : String := "") -- False)
                              return String;

   function Remove_Query_Arg (Key   : List_Type;
                              Query : String := "")
                              return String;

   --
   -- Validates a file name and path against an allowed set of rules.
   --
   -- A return value of `1` means the file path contains directory traversal.
   --
   -- A return value of `2` means the file path contains a Windows drive path.
   --
   -- A return value of `3` means the file is not in the allowed files list.
   --
   -- @since 1.2.0
   --
   -- @param string   $file          File path.
   -- @param string[] $allowed_files Optional. Array of allowed files.
   -- @return int 0 means nothing is wrong, greater than 0 means something was wrong.
   --
   function Validate_File (File          : String;
                           Allowed_Files : Array_Type := Empty_Array)
                           return Integer
                           is (0);

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
   -- @since 4.1.0 The `$title` and `$args` parameters were changed to optionally
   --              accept an integer to be used as the response code.
   -- @since 5.1.0 The `$link_url`, `$link_text`, and `$exit` arguments were added.
   -- @since 5.3.0 The `$charset` argument was added.
   -- @since 5.5.0 The `$text_direction` argument has a priority over
   --              get_language_attributes() in the default handler.
   --
   -- @global WP_Query $wp_query WordPress Query object.
   --
   -- @param string|WP_Error  $message Optional. Error message. If this is a WP_Error
   --                                  object, and not an Ajax or XML-RPC request, the
   --                                  error's messages are used. Default empty.
   -- @param string|int       $title   Optional. Error title. If `$message` is a
   --                                  `WP_Error` object, error data with the key
   --                                  'title' may be used to specify the title. If
   --                                  `$title` is an integer, then it is treated as
   --                                  the response code. Default empty.
   -- @param string|array|int $args {
   --     Optional. Arguments to control behavior. If `$args` is an integer, then it
   --     is treated as the response code. Default empty array.
   --
   --     @type int    $response       The HTTP response code. Default 200 for Ajax
   --                                  requests, 500 otherwise.
   --     @type string $link_url       A URL to include a link to. Only works in
   --                                  combination with $link_text. Default empty
   --                                  string.
   --     @type string $link_text      A label for the link to include. Only works in
   --                                  combination with $link_url. Default empty
   --                                  string.
   --     @type bool   $back_link      Whether to include a link to go back. Default
   --                                  false.
   --     @type string $text_direction The text direction. This is only useful
   --                                  internally, when WordPress is still loading and
   --                                  the site's locale is not set up yet. Accepts
   --                                  'rtl' and 'ltr'. Default is the value of
   --                                  is_rtl().
   --     @type string $charset        Character set of the HTML output. Default
   --                                  'utf-8'.
   --     @type string $code           Error code to use. Default is 'wp_die', or the
   --                                  main error code if $message is a WP_Error.
   --     @type bool   $exit           Whether to exit the process after completion.
   --                                  Default true.
   -- }
   --
   procedure Wp_Die (Message : String  := "";
                     Title   : String  := "";
                     Code    : Integer := 0); -- , $args = array()

   --
   -- Guesses the URL for the site.
   --
   -- Will remove wp-admin links to retrieve only return URLs not in the wp-admin
   -- directory.
   --
   -- @since 2.6.0
   --
   -- @return string The guessed URL.
   --
   function Wp_Guess_URL
            return String;

   --
   -- Attempts to raise the PHP memory limit for memory intensive processes.
   --
   -- Only allows raising the existing limit and prevents lowering it.
   --
   -- @since 4.6.0
   --
   -- @param string $context Optional. Context in which the function is called.
   --                        Accepts either 'admin', 'image', or an arbitrary other
   --                        context. If an arbitrary context is passed, the similarly
   --                         arbitrary {@see '$context_memory_limit'} filter will be
   --                        invoked. Default 'admin'.
   -- @return int|string|false The limit that was set or false on failure.
   --
   function Wp_Raise_Memory_Limit (Context : String := "admin")
                                   return Integer
                                   is (0);

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
   function Wp_JSON_Encode (Data    : Array_Type;
                            Options : Integer := 0;
                            Depth   : Integer := 512)
                            return String
                            is ("XXX-306");

   function Wp_JSON_Encode (Data    : Boolean;
                            Options : Integer := 0;
                            Depth   : Integer := 512)
                            return String
                            is ("XXX-305");

end Inc_Functions;
