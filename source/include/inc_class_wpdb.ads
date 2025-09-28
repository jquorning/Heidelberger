
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded;

with Arrays;
with Inc_Class_Wp_Posts;

package Inc_Class_Wpdb
is
   use Ada.Strings.Unbounded;
   use Arrays;

   package String_Vectors is new
      Ada.Containers.Indefinite_Vectors (Index_Type   => Positive,
                                         Element_Type => String);
   subtype String_List is String_Vectors.Vector;

   type Wpdb_Class is tagged  -- _class added jq
      record

        --
        -- Whether to show SQL/DB errors.
        --
        -- Default is to show errors if both WP_DEBUG and WP_DEBUG_DISPLAY evaluate to true.
        --
        -- @since 0.71
        --
        -- @var bool
        --
--        public $show_errors = false;

        --
        -- Whether to suppress errors during the DB bootstrapping. Default false.
        --
        -- @since 2.5.0
        --
        -- @var bool
        --
--        public $suppress_errors = false;

        --
        -- The error encountered during the last query.
        --
        -- @since 2.5.0
        --
        -- @var string
        --
--        public $last_error = '';

        --
        -- The number of queries made.
        --
        -- @since 1.2.0
        --
        -- @var int
        --
--        public $num_queries = 0;

        --
        -- Count of rows returned by the last query.
        --
        -- @since 0.71
        --
        -- @var int
        --
--        public $num_rows = 0;

        --
        -- Count of rows affected by the last query.
        --
        -- @since 0.71
        --
        -- @var int
        --
--        public $rows_affected = 0;

        --
        -- The ID generated for an AUTO_INCREMENT column by the last query (usually INSERT).
        --
        -- @since 0.71
        --
        -- @var int
        --
--        public $insert_id = 0;

        --
        -- The last query made.
        --
        -- @since 0.71
        --
        -- @var string
        --
--        public $last_query;

        --
        -- Results of the last query.
        --
        -- @since 0.71
        --
        -- @var stdClass[]|null
        --
        Last_Result : String_List;

        --
        -- Database query result.
        --
        -- Possible values:
        --
        -- - For successful SELECT, SHOW, DESCRIBE, or EXPLAIN queries:
        --   - `mysqli_result` instance when the `mysqli` driver is in use
        --   - `resource` when the older `mysql` driver is in use
        -- - `true` for other query types that were successful
        -- - `null` if a query is yet to be made or if the result has since been flushed
        -- - `false` if the query returned an error
        --
        -- @since 0.71
        --
        -- @var mysqli_result|resource|bool|null
        --
--        protected $result;

        --
        -- Cached column info, for sanity checking data before inserting.
        --
        -- @since 4.2.0
        --
        -- @var array
        --
--        protected $col_meta = array();
        Col_Meta : Array_Type;

        --
        -- Calculated character sets keyed by table name.
        --
        -- @since 4.2.0
        --
        -- @var string[]
        --
--        protected $table_charset = array();

        --
        -- Whether text fields in the current query need to be sanity checked.
        --
        -- @since 4.2.0
        --
        -- @var bool
        --
        Check_Current_Query : Boolean := True;

        --
        -- Flag to ensure we don't run into recursion problems when checking the collation.
        --
        -- @since 4.2.0
        --
        -- @see wpdb::check_safe_collation()
        -- @var bool
        --
        Checking_Collation : Boolean := False;

        --
        -- Saved info on the table column.
        --
        -- @since 0.71
        --
        -- @var array
        --
--        protected $col_info;

        --
        -- Log of queries that were executed, for debugging purposes.
        --
        -- @since 1.5.0
        -- @since 2.5.0 The third element in each query log was added to record the calling functions.
        -- @since 5.1.0 The fourth element in each query log was added to record the start time.
        -- @since 5.3.0 The fifth element in each query log was added to record custom data.
        --
        -- @var array[] then
        --     Array of arrays containing information about queries that were executed.
        --
        --     @type array ...$0 then
        --         Data for each query.
        --
        --         @type string $0 The query's SQL.
        --         @type float  $1 Total time spent on the query, in seconds.
        --         @type string $2 Comma-separated list of the calling functions.
        --         @type float  $3 Unix timestamp of the time at the start of the query.
        --         @type array  $4 Custom query data.
        --     end;
        -- end;
        --
--        public $queries;

        --
        -- The number of times to retry reconnecting before dying. Default 5.
        --
        -- @since 3.9.0
        --
        -- @see wpdb::check_connection()
        -- @var int
        --
--        protected $reconnect_retries = 5;

        --
        -- WordPress table prefix.
        --
        -- You can set this to have multiple WordPress installations in a single database.
        -- The second reason is for possible security precautions.
        --
        -- @since 2.5.0
        --
        -- @var string
        --
--        public $prefix = '';

        --
        -- WordPress base table prefix.
        --
        -- @since 3.0.0
        --
        -- @var string
        --
--        public $base_prefix;

        --
        -- Whether the database queries are ready to start executing.
        --
        -- @since 2.3.2
        --
        -- @var bool
        --
--        public $ready = false;

        --
        -- Blog ID.
        --
        -- @since 3.0.0
        --
        -- @var int
        --
--        public $blogid = 0;

        --
        -- Site ID.
        --
        -- @since 3.0.0
        --
        -- @var int
        --
--        public $siteid = 0;

        --
        -- List of WordPress per-site tables.
        --
        -- @since 2.5.0
        --
        -- @see wpdb::tables()
        -- @var string[]
        --
--        public $tables = array(
--                'posts',
--                'comments',
--                'links',
--                'options',
--                'postmeta',
--                'terms',
--                'term_taxonomy',
--                'term_relationships',
--                'termmeta',
--                'commentmeta',
--        );

        --
        -- List of deprecated WordPress tables.
        --
        -- 'categories', 'post2cat', and 'link2cat' were deprecated in 2.3.0, db version 5539.
        --
        -- @since 2.9.0
        --
        -- @see wpdb::tables()
        -- @var string[]
        --
--        public $old_tables = array( 'categories', 'post2cat', 'link2cat' );

        --
        -- List of WordPress global tables.
        --
        -- @since 3.0.0
        --
        -- @see wpdb::tables()
        -- @var string[]
        --
--        public $global_tables = array( 'users', 'usermeta' );

        --
        -- List of Multisite global tables.
        --
        -- @since 3.0.0
        --
        -- @see wpdb::tables()
        -- @var string[]
        --
--        public $ms_global_tables = array(
--                'blogs',
--                'blogmeta',
--                'signups',
--                'site',
--                'sitemeta',
--                'registration_log',
--        );

        --
        -- List of deprecated WordPress Multisite global tables.
        --
        -- @since 6.1.0
        --
        -- @see wpdb::tables()
        -- @var string[]
        --
--        public $old_ms_global_tables = array( 'sitecategories' );

        --
        -- WordPress Comments table.
        --
        -- @since 1.5.0
        --
        -- @var string
        --
--        public $comments;

        --
        -- WordPress Comment Metadata table.
        --
        -- @since 2.9.0
        --
        -- @var string
        --
--        public $commentmeta;

        --
        -- WordPress Links table.
        --
        -- @since 1.5.0
        --
        -- @var string
        --
--        public $links;

        --
        -- WordPress Options table.
        --
        -- @since 1.5.0
        --
        -- @var string
        --
--        public $options;

        --
        -- WordPress Post Metadata table.
        --
        -- @since 1.5.0
        --
        -- @var string
        --
--        public $postmeta;

        --
        -- WordPress Posts table.
        --
        -- @since 1.5.0
        --
        -- @var string
        --
--        public $posts;

        --
        -- WordPress Terms table.
        --
        -- @since 2.3.0
        --
        -- @var string
        --
--        public $terms;

        --
        -- WordPress Term Relationships table.
        --
        -- @since 2.3.0
        --
        -- @var string
        --
--        public $term_relationships;

        --
        -- WordPress Term Taxonomy table.
        --
        -- @since 2.3.0
        --
        -- @var string
        --
--        public $term_taxonomy;

        --
        -- WordPress Term Meta table.
        --
        -- @since 4.4.0
        --
        -- @var string
        --
--        public $termmeta;

        --
        -- Global and Multisite tables
        --

        --
        -- WordPress User Metadata table.
        --
        -- @since 2.3.0
        --
        -- @var string
        --
--        public $usermeta;

        --
        -- WordPress Users table.
        --
        -- @since 1.5.0
        --
        -- @var string
        --
--        public $users;

        --
        -- Multisite Blogs table.
        --
        -- @since 3.0.0
        --
        -- @var string
        --
--        public $blogs;

        --
        -- Multisite Blog Metadata table.
        --
        -- @since 5.1.0
        --
        -- @var string
        --
--        public $blogmeta;

        --
        -- Multisite Registration Log table.
        --
        -- @since 3.0.0
        --
        -- @var string
        --
--        public $registration_log;

        --
        -- Multisite Signups table.
        --
        -- @since 3.0.0
        --
        -- @var string
        --
--        public $signups;

        --
        -- Multisite Sites table.
        --
        -- @since 3.0.0
        --
        -- @var string
        --
--        public $site;

        --
        -- Multisite Sitewide Terms table.
        --
        -- @since 3.0.0
        --
        -- @var string
        --
--        public $sitecategories;

        --
        -- Multisite Site Metadata table.
        --
        -- @since 3.0.0
        --
        -- @var string
        --
--        public $sitemeta;

        --
        -- Format specifiers for DB columns.
        --
        -- Columns not listed here default to %s. Initialized during WP load.
        -- Keys are column names, values are format types: 'ID' => '%d'.
        --
        -- @since 2.8.0
        --
        -- @see wpdb::prepare()
        -- @see wpdb::insert()
        -- @see wpdb::update()
        -- @see wpdb::delete()
        -- @see wp_set_wpdb_vars()
        -- @var array
        --
--        public $field_types = array();

        --
        -- Database table columns charset.
        --
        -- @since 2.2.0
        --
        -- @var string
        --
--        public $charset;

        --
        -- Database table columns collate.
        --
        -- @since 2.2.0
        --
        -- @var string
        --
--        public $collate;

        --
        -- Database Username.
        --
        -- @since 2.9.0
        --
        -- @var string
        --
--        protected $dbuser;

        --
        -- Database Password.
        --
        -- @since 3.1.0
        --
        -- @var string
        --
--        protected $dbpassword;

        --
        -- Database Name.
        --
        -- @since 3.1.0
        --
        -- @var string
        --
--        protected $dbname;

        --
        -- Database Host.
        --
        -- @since 3.1.0
        --
        -- @var string
        --
--        protected $dbhost;

        --
        -- Database handle.
        --
        -- Possible values:
        --
        -- - `mysqli` instance when the `mysqli` driver is in use
        -- - `resource` when the older `mysql` driver is in use
        -- - `null` if the connection is yet to be made or has been closed
        -- - `false` if the connection has failed
        --
        -- @since 0.71
        --
        -- @var mysqli|resource|false|null
        --
--        protected $dbh;

        --
        -- A textual description of the last query/get_row/get_var call.
        --
        -- @since 3.0.0
        --
        -- @var string
        --
        Func_Call : Unbounded_String;

        --
        -- Whether MySQL is used as the database engine.
        --
        -- Set in wpdb::db_connect() to true, by default. This is used when checking
        -- against the required MySQL version for WordPress. Normally, a replacement
        -- database drop-in (db.php) will skip these checks, but setting this to true
        -- will force the checks to occur.
        --
        -- @since 3.3.0
        --
        -- @var bool
        --
--        public $is_mysql = null;

        --
        -- A list of incompatible SQL modes.
        --
        -- @since 3.9.0
        --
        -- @var string[]
        --
--        protected $incompatible_modes = array(
--                'NO_ZERO_DATE',
--                'ONLY_FULL_GROUP_BY',
--                'STRICT_TRANS_TABLES',
--                'STRICT_ALL_TABLES',
--                'TRADITIONAL',
--                'ANSI',
--        );

        --
        -- Whether to use mysqli over mysql. Default false.
        --
        -- @since 3.9.0
        --
        -- @var bool
        --
--        private $use_mysqli = false;

        --
        -- Whether we've managed to successfully connect at some point.
        --
        -- @since 3.9.0
        --
        -- @var bool
        --
--        private $has_connected = false;

        --
        -- Time when the last query was performed.
        --
        -- Only set when `SAVEQUERIES` is defined and truthy.
        --
        -- @since 1.5.0
        --
        -- @var float
        --
--        public $time_start = null;

        --
        -- The last SQL error that was encountered.
        --
        -- @since 2.5.0
        --
        -- @var WP_Error|string
        --
--        public $error = null;

      end record;

   --
   -- Checks if a string is ASCII.
   --
   -- The negative regex is faster for non-ASCII strings, as it allows
   -- the search to finish as soon as it encounters a non-ASCII character.
   --
   -- @since 4.2.0
   --
   -- @param string string String to check.
   -- @return bool True if ASCII, false if not.
   --
   -- protected function check_ascii(string) then
   function Check_Ascii (This : Wpdb_Class;
                         Item : String)
                         return Boolean is (False);
   --
   -- Checks if the query is accessing a collation considered safe on the current
   -- version of MySQL.
   --
   -- @since 4.2.0
   --
   -- @param string $query The query to check.
   -- @return bool True if the collation is safe, false if it isn't.
   --
   -- protected function check_safe_collation( $query ) then
   function Check_Safe_Collation (This  : in out Wpdb_Class;
                                  Query : String)
                                  return Boolean;
   --
   -- Performs a database query, using current database connection.
   --
   -- More information can be found on the documentation page.
   --
   -- @since 0.71
   --
   -- @link https://developer.wordpress.org/reference/classes/wpdb/
   --
   -- @param string $query Database query.
   -- @return int|bool Boolean true for CREATE, ALTER, TRUNCATE and DROP queries.
   --                          Number of rows affected/selected for all other
   --                          queries. Boolean false on error.
   --
   function Query (Db    : Wpdb_Class;
                   Query : String)
                   return Integer
                   is (0);

   --
   -- Adds a placeholder escape string, to escape anything that resembles a printf()
   -- placeholder.
   --
   -- @since 4.8.3
   --
   -- @param string $query The query to escape.
   -- @return string The query with the placeholder escape string inserted where
   --                necessary.
   --
   function Add_Placeholder_Escape (Db    : Wpdb_Class;
                                    Query : String)
                                    return String is ("XXX-206");

   --
   -- Prepares a SQL query for safe execution.
   --
   -- Uses sprintf()-like syntax. The following placeholders can be used in the
   -- query string:
   --
   -- - %d (integer)
   -- - %f (float)
   -- - %s (string)
   --
   -- All placeholders MUST be left unquoted in the query string. A corresponding
   -- argument MUST be passed for each placeholder.
   --
   -- Note: There is one exception to the above: for compatibility with old behavior,
   -- numbered or formatted string placeholders (eg, `%1$s`, `%5s`) will not have
   -- quotes added by this function, so should be passed with appropriate quotes
   -- around them.
   --
   -- Literal percentage signs (`%`) in the query string must be written as `%%`.
   -- Percentage wildcards (for example, to use in LIKE syntax) must be passed via
   -- a substitution argument containing the complete LIKE string, these cannot be
   -- inserted directly in the query string. Also see wpdb::esc_like().
   --
   -- Arguments may be passed as individual arguments to the method, or as a single
   -- array containing all arguments. A combination of the two is not supported.
   --
   -- Examples:
   --
   --     $wpdb->prepare(
   --         "SELECT-- FROM `table` WHERE `column` = %s AND `field` = %d OR `other_field` LIKE %s",
   --         array( 'foo', 1337, '%bar' )
   --     );
   --
   --     $wpdb->prepare(
   --         "SELECT DATE_FORMAT(`field`, '%%c') FROM `table` WHERE `column` = %s",
   --         'foo'
   --     );
   --
   -- @since 2.3.0
   -- @since 5.3.0 Formalized the existing and already documented `...$args` parameter
   --              by updating the function signature. The second parameter was changed
   --              from `$args` to `...$args`.
   --
   -- @link https://www.php.net/sprintf Description of syntax.
   --
   -- @param string      $query   Query statement with sprintf()-like placeholders.
   -- @param array|mixed $args    The array of variables to substitute into the
   --                             query's placeholders
   --                             if being called with an array of arguments, or the
   --                             first variable to substitute into the query's
   --                             placeholders if being called with individual
   --                             arguments.
   -- @param mixed       ...$args Further variables to substitute into the query's
   --                             placeholders
   --                             if being called with individual arguments.
   -- @return string|void Sanitized query string, if there is a query to prepare.
   --
   function Prepare (Db    : Wpdb_Class;
                     Query : String;
                     Args  : Array_Type) --, ...$args )
                     return String;
   function Prepare (Db    : Wpdb_Class;
                     Query : String;
                     Arg_1 : String;
                     Arg_2 : String := "") --, ...$args )
                     return String
                     is ("XXX-212");

   --
   -- Prints SQL/DB error.
   --
   -- @since 0.71
   --
   -- @global array $EZSQL_ERROR Stores error information of query and error string.
   --
   -- @param string $str The error to display.
   -- @return void|false Void if the showing of errors is enabled, false if disabled.
   --
   procedure Print_Error (Db  : Wpdb_Class;
                          Str : String := "") is null;

   --
   -- Retrieves one row from the database.
   --
   -- Executes a SQL query and returns the row from the SQL result.
   --
   -- @since 0.71
   --
   -- @param string|null $query  SQL query.
   -- @param string      $output Optional. The required return type. One of OBJECT,
   --                            ARRAY_A, or ARRAY_N, which
   --                            correspond to an stdClass object, an associative
   --                            array, or a numeric array,
   --                            respectively. Default OBJECT.
   -- @param int         $y      Optional. Row to return. Indexed from 0.
   -- @return array|object|null|void Database query result in format specified by
   --                                $output or null on failure.
   --
   procedure Get_Row (Db      : in out Wpdb_Class;
                      Post    : Inc_Class_Wp_Posts.Wp_Post;
                      Query   : String  := ""; -- = null,
                      Output  : String  := ""; -- = OBJECT,
                      Y       : Natural := 0;
                      Success : out Boolean) is null;
                      -- return Array_Type;
   --
   -- Retrieves one column from the database.
   --
   -- Executes a SQL query and returns the column from the SQL result.
   -- If the SQL result contains more than one column, the column specified is
   -- returned.
   -- If query is null, the specified column from the previous SQL result is returned.
   --
   -- @since 0.71
   --
   -- @param string|null query Optional. SQL query. Defaults to previous query.
   -- @param int         x     Optional. Column to return. Indexed from 0.
   -- @return array Database query result. Array indexed from 0 by SQL result row
   --               number.
   --
   function Get_Col (Db    : in out Wpdb_Class;
                     Query : String  := "";  -- null;
                     X     : Integer := 0)
                     return List_Type
                     is (Empty_List);

   --
   -- Retrieves the character set for the given table.
   --
   -- @since 4.2.0
   --
   -- @param string table Table name.
   -- @return string|WP_Error Table character set, WP_Error object if it couldn't
   --                         be found.
   --
   -- protected function get_table_charset(table) then
   function Get_Table_Charset (This  : Wpdb_Class;
                               Table : String)
                               return String
                               is ("XXX-205");

   --
   -- Finds the first table name referenced in a query.
   --
   -- @since 4.2.0
   --
   -- @param string query The query to search.
   -- @return string|false The table name found, or false if a table couldn"t be found.
   --
   -- protected function get_table_from_query(query) then
   function Get_Table_From_Query (This  : Wpdb_Class;
                                  Query : String)
                                  return String
                                  is ("XXX-203");

end Inc_Class_Wpdb;
