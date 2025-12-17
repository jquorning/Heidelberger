--
--
--

with Arrays;
with Lists;

with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Users;

package Inc_Functions
is
   use Arrays;
   use Lists;

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
   -- Sorts an array of objects or arrays based on one or more orderby arguments.
   --
   -- @since 4.7.0
   --
   -- @param array        list          An array of objects or arrays to sort.
   -- @param string|array orderby       Optional. Either the field name to order by or
   --                                    an array of multiple orderby fields as
   --                                    orderby => order.
   -- @param string       order         Optional. Either "ASC" or "DESC". Only used
   --                                    if orderby is a string.
   -- @param bool         preserve_keys Optional. Whether to preserve keys. Default
   --                                    false.
   -- @return array The sorted array.
   --
   function Wp_List_Sort (List          : List_Type;
                          Orderby       : String := ""; -- = array(),
                          Order         : String := "ASC";
                          Preserve_Keys : Boolean := False)
                          return List_Type
                          is (raise Program_Error with "not implemented");

   --
   -- Filters/validates a variable as a boolean.
   --
   -- Alternative to `filter_var( var, FILTER_VALIDATE_BOOLEAN )`.
   --
   -- @since 4.0.0
   --
   -- @param mixed var Boolean value to validate.
   -- @return bool Whether the value is validated.
   --
   function Wp_Validate_Boolean (Var : Multi_Type)
                                 return Boolean;

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
   -- Normalizes a filesystem path.
   --
   -- On windows systems, replaces backslashes with forward slashes
   -- and forces upper-case drive letters.
   -- Allows for two leading slashes for Windows network shares, but
   -- ensures that all other duplicate slashes are reduced to a single.
   --
   -- @since 3.9.0
   -- @since 4.4.0 Ensures upper-case drive letters on Windows systems.
   -- @since 4.5.0 Allows for Windows network shares.
   -- @since 4.9.7 Allows for PHP file wrappers.
   --
   -- @param string $path Path to normalize.
   -- @return string Normalized path.
   --
   function Wp_Normalize_Path (Path : String)
                               return String;

   --
   -- Retrieves the list of mime types and file extensions.
   --
   -- @since 3.5.0
   -- @since 4.2.0 Support was added for GIMP (.xcf) files.
   -- @since 4.9.2 Support was added for Flac (.flac) files.
   -- @since 4.9.6 Support was added for AAC (.aac) files.
   --
   -- @return string[] Array of mime types keyed by the file extension regex
   --                   corresponding to those types.
   --
   function Wp_Get_MIME_Types
            return Array_Type;

   --
   -- Retrieves the list of allowed mime types and file extensions.
   --
   -- @since 2.8.6
   --
   -- @param int|WP_User user Optional. User to check. Defaults to current user.
   -- @return string[] Array of mime types keyed by the file extension regex
   --                  corresponding to those types.
   --
   function Get_Allowed_MIME_Types
     (User : Inc_Class_Wp_Users.Wp_User := Inc_Class_Wp_Users.Null_User)
      return Array_Type;

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
   -- Converts a comma- or space-separated list of scalar values to an array.
   --
   -- @since 5.1.0
   --
   -- @param array|string list List of values.
   -- @return array Array of values.
   --
   function Wp_Parse_List (List : List_Type)
                           return List_Type;

   --
   -- Cleans up an array, comma- or space-separated list of IDs.
   --
   -- @since 3.0.0
   -- @since 5.1.0 Refactored to use wp_parse_list().
   --
   -- @param array|string list List of IDs.
   -- @return int[] Sanitized array of IDs.
   --
   function Wp_Parse_Id_List (List : List_Type)
                              return List_Type;

   --
   -- Extracts a slice of an array, given a list of keys.
   --
   -- @since 3.1.0
   --
   -- @param array array The original array.
   -- @param array keys  The list of keys.
   -- @return array The array slice.
   --
   function Wp_Array_Slice_Assoc (Arry : Array_Type;
                                  Keys : List_Type)
                                  return Array_Type;

   --
   -- Accesses an array in depth based on a path of keys.
   --
   -- It is the PHP equivalent of JavaScript's `lodash.get()` and mirroring it may
   -- help other components retain some symmetry between client and server
   -- implementations.
   --
   -- Example usage:
   --
   --     $array = array(
   --         'a' => array(
   --             'b' => array(
   --                 'c' => 1,
   --             ),
   --         ),
   --     );
   --     _wp_array_get( $array, array( 'a', 'b', 'c' ) );
   --
   -- @internal
   --
   -- @since 5.6.0
   -- @access private
   --
   -- @param array $array   An array from which we want to retrieve some information.
   -- @param array $path    An array of keys describing the path with which to
   --                       retrieve information.
   -- @param mixed $default Optional. The return value if the path does not exist
   --                       within the array, or if `$array` or `$path` are not
   --                       arrays. Default null.
   -- @return mixed The value from the path specified.
   --
   -- function X_Wp_Array_Get (Arry    : Array_Type;
   --                          Path    : List_Type;
   --                          Default : String := "") -- null
   --                          return String;

   -- function X_Wp_Array_Get (Arry    : Array_Type;
   --                          Path    : List_Type;
   --                          Default : String := "") -- null
   --                          return List_Type;

   -- function X_Wp_Array_Get (Arry    : Array_Type;
   --                          Path    : List_Type;
   --                          Default : String := "") -- null
   --                          return Array_Type;

   function X_Wp_Array_Get (Arry    : Array_Type;
                            Path    : List_Type;
                            Default : Multi_Type := Null_Multi_Type)
                            return Multi_Type;

   --
   -- Sets an array in depth based on a path of keys.
   --
   -- It is the PHP equivalent of JavaScript's `lodash.set()` and mirroring it may help other
   -- components retain some symmetry between client and server implementations.
   --
   -- Example usage:
   --
   --     $array = array();
   --     _wp_array_set( $array, array( 'a', 'b', 'c', 1 ) );
   --
   --     $array becomes:
   --     array(
   --         'a' => array(
   --             'b' => array(
   --                 'c' => 1,
   --             ),
   --         ),
   --     );
   --
   -- @internal
   --
   -- @since 5.8.0
   -- @access private
   --
   -- @param array $array An array that we want to mutate to include a specific value
   --                      in a path.
   -- @param array $path  An array of keys describing the path that we want to mutate.
   -- @param mixed $value The value that will be set.
   --
   procedure X_Wp_Array_Set (Arry  : in out Array_Type;
                             Path  : List_Type;
                             Value : Multi_Type);

   --
   -- This function is trying to replicate what
   -- lodash's kebabCase (JS library) does in the client.
   --
   -- The reason we need this function is that we do some processing
   -- in both the client and the server (e.g.: we generate
   -- preset classes from preset slugs) that needs to
   -- create the same output.
   --
   -- We can't remove or update the client's library due to backward compatibility
   -- (some of the output of lodash's kebabCase is saved in the post content).
   -- We have to make the server behave like the client.
   --
   -- Changes to this function should follow updates in the client
   -- with the same logic.
   --
   -- @link https://github.com/lodash/lodash/blob/4.17/dist/lodash.js#L14369
   -- @link https://github.com/lodash/lodash/blob/4.17/dist/lodash.js#L278
   -- @link https://github.com/lodash-php/lodash-php/blob/master/src/String/kebabCase.php
   -- @link https://github.com/lodash-php/lodash-php/blob/master/src/internal/unicodeWords.php
   --
   -- @param string $string The string to kebab-case.
   --
   -- @return string kebab-cased-string.
   --
   function X_Wp_To_Kebab_Case (Item : String)
                                return String;

   --
   -- Returns an array of single-use query variable names that can be removed from a
   -- URL.
   --
   -- @since 4.4.0
   --
   -- @return string[] An array of query variable names to remove from the URL.
   --
   -- function Wp_Removable_Query_Args
   --          return String_Array
   --          is (Empty_String_Array);

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
   -- Reads and decodes a JSON file.
   --
   -- @since 5.9.0
   --
   -- @param string $filename Path to the JSON file.
   -- @param array  $options  {
   --     Optional. Options to be used with `json_decode()`.
   --
   --     @type bool $associative Optional. When `true`, JSON objects will be returned as
   --                             associative arrays. When `false`, JSON objects will be returned
   --                             as objects.
   -- }
   --
   -- @return mixed Returns the value encoded in JSON in appropriate PHP type.
   --               `null` is returned if the file is not found, or its content can't be decoded.
   --
   function Wp_JSON_File_Decode (Filename : String;
                                 Options  : Array_Type := Empty_Array)
                                 return Array_Type;

   --
   -- Determines whether to force SSL used for the Administration Screens.
   --
   -- @since 2.6.0
   --
   -- @param string|bool force Optional. Whether to force SSL in admin screens.
   --                           Default null.
   -- @return bool True if forced, false if not forced.
   --
   function Force_SSL_Admin (Force : Boolean := False) -- = null )
                             return Boolean;

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
   -- Retrieves a list of protocols to allow in HTML attributes.
   --
   -- @since 3.3.0
   -- @since 4.3.0 Added 'webcal' to the protocols array.
   -- @since 4.7.0 Added 'urn' to the protocols array.
   -- @since 5.3.0 Added 'sms' to the protocols array.
   -- @since 5.6.0 Added 'irc6' and 'ircs' to the protocols array.
   --
   -- @see wp_kses()
   -- @see esc_url()
   --
   -- @return string[] Array of allowed protocols. Defaults to an array containing
   --                  'http', 'https', 'ftp', 'ftps', 'mailto', 'news', 'irc',
   --                  'irc6', 'ircs', 'gopher', 'nntp', 'feed', 'telnet', 'mms',
   --                  'rtsp', 'sms', 'svn', 'tel', 'fax', 'xmpp', 'webcal', and 'urn'.
   --                  This covers all common link protocols, except for 'javascript'
   --                  which should not be allowed for untrusted users.
   --
   function Wp_Allowed_Protocols
            return List_Type;

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
   --
   -- Gets last changed date for the specified cache group.
   --
   -- @since 4.7.0
   --
   -- @param string $group Where the cache contents are grouped.
   -- @return string UNIX timestamp with microseconds representing when the group
   --                was last changed.
   --
   function Wp_Cache_Get_Last_Changed (Group : String)
                                       return String
                                       is ("XXX-979");

   --
   -- Tests if a given path is a stream URL
   --
   -- @since 3.5.0
   --
   -- @param string $path The resource path or URL.
   -- @return bool True if the path is a stream URL.
   --
   function Wp_Is_Stream (Path : String)
                          return Boolean;

   --
   -- Generates a random UUID (version 4).
   --
   -- @since 4.7.0
   --
   -- @return string UUID.
   --
   function Wp_Generate_UUID4
            return String;

   --
   -- Validates that a UUID is valid.
   --
   -- @since 4.9.0
   --
   -- @param mixed uuid    UUID to check.
   -- @param int   version Specify which version of UUID to check against. Default is
   --                       none, to accept any UUID version. Otherwise, only version
   --                       allowed is `4`.
   -- @return bool The string is a valid UUID or false on failure.
   --
   function Wp_Is_UUID (UUID    : String;
                        Version : Integer := 0) -- null
                        return Boolean;

   --
   -- Strips close comment and close php tags from file headers used by WP.
   --
   -- @since 2.8.0
   -- @access private
   --
   -- @see https://core.trac.wordpress.org/ticket/8497
   --
   -- @param string $str Header comment to clean up.
   -- @return string
   --
   function X_Cleanup_Header_Comment (Str : String)
                                      return String;

   --
   -- Retrieves metadata from a file.
   --
   -- Searches for metadata in the first 8 KB of a file, such as a plugin or theme.
   -- Each piece of metadata must be on its own line. Fields can not span multiple
   -- lines, the value will get cut at the end of the first line.
   --
   -- If the file data is not within that first 8 KB, then the author should correct
   -- their plugin file and move the data headers to the top.
   --
   -- @link https://codex.wordpress.org/File_Header
   --
   -- @since 2.9.0
   --
   -- @param string $file            Absolute path to the file.
   -- @param array  $default_headers List of headers, in the format
   --                                 `array( 'HeaderKey' => 'Header Name' )`.
   -- @param string $context         Optional. If specified adds filter hook
   --                                 {@see 'extra_$context_headers'}.
   --                                Default empty.
   -- @return string[] Array of file header values keyed by header name.
   --
   function Get_File_Data (File            : String;
                           Default_Headers : Array_Type;
                           Context         : String := "")
                           return Array_Type;

   --
   -- Returns true.
   --
   -- Useful for returning true to filters easily.
   --
   -- @since 3.0.0
   --
   -- @see __return_false()
   --
   -- @return true True.
   --
   function X_Return_True
            return Boolean;

   --
   -- Returns false.
   --
   -- Useful for returning false to filters easily.
   --
   -- @since 3.0.0
   --
   -- @see __return_true()
   --
   -- @return false False.
   --
   function X_Return_False
            return Boolean;

   --
   -- Returns 0.
   --
   -- Useful for returning 0 to filters easily.
   --
   -- @since 3.0.0
   --
   -- @return int 0.
   --
   function X_Return_Zero
            return Integer;

   --
   -- Returns an empty array.
   --
   -- Useful for returning an empty array to filters easily.
   --
   -- @since 3.0.0
   --
   -- @return array Empty array.
   --
   function X_Return_Empty_Array
            return Array_Type;

end Inc_Functions;
