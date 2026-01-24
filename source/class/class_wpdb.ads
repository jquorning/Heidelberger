--
-- These functions are needed to load WordPress.
--
-- @package WordPress
--

with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded;

with Arrays;
with Databases;
with Hb_Common;
with SQLite;
with Lists;

with Inc_Class_Wp_Comments;
with Inc_Class_Wp_Errors;
with Class_Posts;
with Inc_Class_Wp_Users;

package Class_WpDB
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Hb_Common;
   use Lists;

   type Statement_Type is new String;

   package String_Vectors is new
      Ada.Containers.Indefinite_Vectors (Index_Type   => Positive,
                                         Element_Type => String);
   subtype String_List is String_Vectors.Vector;

   package String_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => String);

   type Status_Type is (Create_Alter, Success, Error);

   type Rows_Result_Type is record
      Status : Status_Type;
      Rows   : Natural;
   end record;

   type Wpdb_Class is tagged  -- _class added jq
      record
         --
         -- Whether to show SQL/DB errors.
         --
         -- Default is to show errors if both WP_DEBUG and WP_DEBUG_DISPLAY evaluate
         -- to true.
         --
         -- @since 0.71
         --
         -- @var bool
         --
         M_Show_Errors : Boolean := False;

         --
         -- Whether to suppress errors during the DB bootstrapping. Default false.
         --
         -- @since 2.5.0
         --
         -- @var bool
         --
         X_Suppress_Errors : Boolean := False;
         -- X_ added to avoid conflict with method

         --
         -- The error encountered during the last query.
         --
         -- @since 2.5.0
         --
         -- @var string
         --
         Last_Error : Unbounded_String;

         --
         -- The number of queries made.
         --
         -- @since 1.2.0
         --
         -- @var int
         --
         Num_Queries : Natural := 0;

         --
         -- Count of rows returned by the last query.
         --
         -- @since 0.71
         --
         -- @var int
         --
         Num_Rows : Natural := 0;

         --
         -- Count of rows affected by the last query.
         --
         -- @since 0.71
         --
         -- @var int
         --
         Rows_Affected : Natural := 0;

         --
         -- The ID generated for an AUTO_INCREMENT column by the last query (usually
         -- INSERT).
         --
         -- @since 0.71
         --
         -- @var int
         --
         Insert_Id : Integer := 0;

         --
         -- The last query made.
         --
         -- @since 0.71
         --
         -- @var string
         --
         Last_Query : Unbounded_String;

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
         -- - `null` if a query is yet to be made or if the result has since been
         --          flushed
         -- - `false` if the query returned an error
         --
         -- @since 0.71
         --
         -- @var mysqli_result|resource|bool|null
         --
--        protected
          Result : Databases.Three_State := Databases.None;

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
         -- protected
         Table_Charset : Array_Type;

         --
         -- Whether text fields in the current query need to be sanity checked.
         --
         -- @since 4.2.0
         --
         -- @var bool
         --
         Check_Current_Query : Boolean := True;

         --
         -- Flag to ensure we don't run into recursion problems when checking the
         -- collation.
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
         -- @since 2.5.0 The third element in each query log was added to record the
         --              calling functions.
         -- @since 5.1.0 The fourth element in each query log was added to record the
         --              start time.
         -- @since 5.3.0 The fifth element in each query log was added to record
         --              custom data.
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
         -- You can set this to have multiple WordPress installations in a single
         -- database. The second reason is for possible security precautions.
         --
         -- @since 2.5.0
         --
         -- @var string
         --
         Prefix : Unbounded_String;

         --
         -- WordPress base table prefix.
         --
         -- @since 3.0.0
         --
         -- @var string
         --
         Base_Prefix : Unbounded_String;

         --
         -- Whether the database queries are ready to start executing.
         --
         -- @since 2.3.2
         --
         -- @var bool
         --
         Ready : Boolean := False;

         --
         -- Blog ID.
         --
         -- @since 3.0.0
         --
         -- @var int
         --
         Blogid : Integer := 0;

         --
         -- Site ID.
         --
         -- @since 3.0.0
         --
         -- @var int
         --
         Siteid : Integer := 0;

         --
         -- List of WordPress per-site tables.
         --
         -- @since 2.5.0
         --
         -- @see wpdb::tables()
         -- @var string[]
         --
         M_Tables : List_Type := To_List (List => (
              +"posts",
              +"comments",
              +"links",
              +"options",
              +"postmeta",
              +"terms",
              +"term_taxonomy",
              +"term_relationships",
              +"termmeta",
              +"Commentmeta"));

         -- String_Maps.Map; --  :=
           -- [ -- String_Maps.To_Map ((
           --   Build ("posts",              ""),
           --   Build ("comments",           ""),
           --   Build ("links",              ""),
           --   Build ("options",            ""),
           --   Build ("postmeta",           ""),
           --   Build ("terms",              ""),
           --   Build ("term_taxonomy",      ""),
           --   Build ("term_relationships", ""),
           --   Build ("termmeta",           ""),
           --   Build ("Commentmeta",        "")
           -- ]; -- ));

         --
         -- List of deprecated WordPress tables.
         --
         -- 'categories', 'post2cat', and 'link2cat' were deprecated in 2.3.0,
         -- db version 5539.
         --
         -- @since 2.9.0
         --
         -- @see wpdb::tables()
         -- @var string[]
         --
         Old_Tables : List_Type :=
           To_List (List => (+"categories", +"post2cat", +"link2cat"));

         --
         -- List of WordPress global tables.
         --
         -- @since 3.0.0
         --
         -- @see wpdb::tables()
         -- @var string[]
         --
         Global_Tables : List_Type :=
           To_List (List => (+"users", +"usermeta"));

         --
         -- List of Multisite global tables.
         --
         -- @since 3.0.0
         --
         -- @see wpdb::tables()
         -- @var string[]
         --
         MS_Global_Tables : List_Type :=
           To_List (List => (
             +"blogs",
             +"blogmeta",
             +"signups",
             +"site",
             +"sitemeta",
             +"registration_log"
           ));

         --
         -- List of deprecated WordPress Multisite global tables.
         --
         -- @since 6.1.0
         --
         -- @see wpdb::tables()
         -- @var string[]
         --
         Old_MS_Global_Tables : List_Type :=
           To_List ("sitecategories");

         --
         -- WordPress Comments table.
         --
         -- @since 1.5.0
         --
         -- @var string
         --
         Comments : Unbounded_String;

         --
         -- WordPress Comment Metadata table.
         --
         -- @since 2.9.0
         --
         -- @var string
         --
         Commentmeta : Unbounded_String;

         --
         -- WordPress Links table.
         --
         -- @since 1.5.0
         --
         -- @var string
         --
         Links : Unbounded_String;

         --
         -- WordPress Options table.
         --
         -- @since 1.5.0
         --
         -- @var string
         --
         Options : Unbounded_String :=
           To_Unbounded_String ("options"); -- added
--         To_Unbounded_String ("XXX-968"); -- added

         --
         -- WordPress Post Metadata table.
         --
         -- @since 1.5.0
         --
         -- @var string
         --
         Postmeta : Unbounded_String;

         --
         -- WordPress Posts table.
         --
         -- @since 1.5.0
         --
         -- @var string
         --
         Posts : Unbounded_String;

         --
         -- WordPress Terms table.
         --
         -- @since 2.3.0
         --
         -- @var string
         --
         Terms : Unbounded_String;

         --
         -- WordPress Term Relationships table.
         --
         -- @since 2.3.0
         --
         -- @var string
         --
         Term_Relationships : Unbounded_String;

         --
         -- WordPress Term Taxonomy table.
         --
         -- @since 2.3.0
         --
         -- @var string
         --
         Term_Taxonomy : Unbounded_String;

         --
         -- WordPress Term Meta table.
         --
         -- @since 4.4.0
         --
         -- @var string
         --
         Termmeta : Unbounded_String;

         ---------------------------------
         -- Global and Multisite tables --
         ---------------------------------

         --
         -- WordPress User Metadata table.
         --
         -- @since 2.3.0
         --
         -- @var string
         --
         Usermeta : Unbounded_String;

         --
         -- WordPress Users table.
         --
         -- @since 1.5.0
         --
         -- @var string
         --
         Users : Unbounded_String;

         --
         -- Multisite Blogs table.
         --
         -- @since 3.0.0
         --
         -- @var string
         --
         Blogs : Unbounded_String;

         --
         -- Multisite Blog Metadata table.
         --
         -- @since 5.1.0
         --
         -- @var string
         --
         Blogmeta : Unbounded_String;

         --
         -- Multisite Registration Log table.
         --
         -- @since 3.0.0
         --
         -- @var string
         --
         Registration_Log : Unbounded_String;

         --
         -- Multisite Signups table.
         --
         -- @since 3.0.0
         --
         -- @var string
         --
         Signups : Unbounded_String;

         --
         -- Multisite Sites table.
         --
         -- @since 3.0.0
         --
         -- @var string
         --
         Site : Unbounded_String;

         --
         -- Multisite Sitewide Terms table.
         --
         -- @since 3.0.0
         --
         -- @var string
         --
         Sitecategories : Unbounded_String;

         --
         -- Multisite Site Metadata table.
         --
         -- @since 3.0.0
         --
         -- @var string
         --
         Sitemeta : Unbounded_String;

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
         Field_Types : Array_Type;

         --
         -- Database table columns charset.
         --
         -- @since 2.2.0
         --
         -- @var string
         --
         Charset : Unbounded_String;

         --
         -- Database table columns collate.
         --
         -- @since 2.2.0
         --
         -- @var string
         --
         Collate : Unbounded_String;

         --
         -- Database Username.
         --
         -- @since 2.9.0
         --
         -- @var string
         --
--        protected
         Dbuser : Unbounded_String;

         --
         -- Database Password.
         --
         -- @since 3.1.0
         --
         -- @var string
         --
--        protected
         Dbpassword : Unbounded_String;

         --
         -- Database Name.
         --
         -- @since 3.1.0
         --
         -- @var string
         --
--        protected
         Dbname : Unbounded_String;

         --
         -- Database Host.
         --
         -- @since 3.1.0
         --
         -- @var string
         --
--        protected
         Dbhost : Unbounded_String;

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
         -- protected $dbh;
         Dbh    : Integer;
         Handle : SQLite.Data_Base;

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
--       Is_MySQL : Boolean := False; --  = null;

         --
         -- A list of incompatible SQL modes.
         --
         -- @since 3.9.0
         --
         -- @var string[]
         --
--        protected
         Incompatible_Modes : List_Type :=
           To_List (List => (
               +"NO_ZERO_DATE",
               +"ONLY_FULL_GROUP_BY",
               +"STRICT_TRANS_TABLES",
               +"STRICT_ALL_TABLES",
               +"TRADITIONAL",
               +"ANSI"
         ));

         --
         -- Added by jq
         --
         Engine : Databases.Engine_Type;

         --
         -- Whether to use mysqli over mysql. Default false.
         --
         -- @since 3.9.0
         --
         -- @var bool
         --
         -- private
--         Use_Mysqli : Boolean := False;

         --
         -- Whether we've managed to successfully connect at some point.
         --
         -- @since 3.9.0
         --
         -- @var bool
         --
         -- private
         Has_Connected : Boolean := False;

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
         Error : Unbounded_String; --  = null;

      end record;

   --
   -- Connects to the database server and selects a database.
   --
   -- Does the actual setting up
   -- of the class properties and connection to the database.
   --
   -- @since 2.0.8
   --
   -- @link https://core.trac.wordpress.org/ticket/3354
   --
   -- @param string dbuser     Database user.
   -- @param string dbpassword Database password.
   -- @param string dbname     Database name.
   -- @param string dbhost     Database host.
   --
   function X_Construct (Dbuser     : String;
                         Dbpassword : String;
                         Dbname     : String;
                         Dbhost     : String)
                         return Wpdb_Class;

   --
   -- Sets this.charset and this.collate.
   --
   -- @since 3.1.0
   --
   procedure Init_Charset (This : in out Wpdb_Class);

   --
   -- Determines the best charset and collation to use given a charset and collation.
   --
   -- For example, when able, utf8mb4 should be used instead of utf8.
   --
   -- @since 4.6.0
   --
   -- @param string charset The character set to check.
   -- @param string collate The collation to check.
   -- @return array {
   --     The most appropriate character set and collation to use.
   --
   --     @type string charset Character set.
   --     @type string collate Collation.
   -- }
   --
   function Determine_Charset (This    : Wpdb_Class;
                               Charset : String;
                               Collate : String)
                               return Array_Type;

   --
   -- Sets the connection's character set.
   --
   -- @since 3.1.0
   --
   -- @param mysqli|resource dbh     The connection returned by `mysqli_connect()`
   --                                or `mysql_connect()`.
   -- @param string          charset Optional. The character set. Default null.
   -- @param string          collate Optional. The collation. Default null.
   --
   procedure Set_Charset (This    : Wpdb_Class;
                          Dbh     : Integer;
                          Charset : String := "";  -- = null
                          Collate : String := ""); -- = null

   --
   -- Changes the current SQL mode, and ensures its WordPress compatibility.
   --
   -- If no modes are passed, it will ensure the current MySQL server modes are
   -- compatible.
   --
   -- @since 3.9.0
   --
   -- @param array modes Optional. A list of SQL modes to set. Default empty array.
   --
   procedure Set_SQL_Mode (This  : Wpdb_Class;
                           Modes : Array_Type := Empty_Array);

   --
   -- Gets blog prefix.
   --
   -- @since 3.0.0
   --
   -- @param int blog_id Optional.
   -- @return string Blog prefix.
   --
   function Get_Blog_Prefix (This    : Wpdb_Class;
                             Blog_Id : Integer := 0)
                             return String;

   --
   -- Returns an array of WordPress tables.
   --
   -- Also allows for the `CUSTOM_USER_TABLE` and `CUSTOM_USER_META_TABLE` to override
   -- the WordPress users and usermeta tables that would otherwise be determined by
   -- the prefix.
   --
   -- The `scope` argument can take one of the following:
   --
   -- - "all" - returns "all" and "global" tables. No old tables are returned.
   -- - "blog" - returns the blog-level tables for the queried blog.
   -- - "global" - returns the global tables for the installation, returning multisite
   --                 tables only on multisite.
   -- - "ms_global" - returns the multisite global tables, regardless if current
   --                 installation is multisite.
   -- - "old" - returns tables which are deprecated.
   --
   -- @since 3.0.0
   -- @since 6.1.0 `old` now includes deprecated multisite global tables only on
   --              multisite.
   --
   -- @uses wpdb::tables
   -- @uses wpdb::old_tables
   -- @uses wpdb::global_tables
   -- @uses wpdb::ms_global_tables
   -- @uses wpdb::old_ms_global_tables
   --
   -- @param string scope   Optional. Possible values include "all", "global",
   --                        "ms_global", "blog", or "old" tables. Default "all".
   -- @param bool   prefix  Optional. Whether to include table prefixes. If blog
   --                        prefix is requested, then the custom users and usermeta
   --                        tables will be mapped. Default true.
   -- @param int    blog_id Optional. The blog_id to prefix. Used only when prefix is
   --                        requested. Defaults to `wpdb::blogid`.
   -- @return string[] Table names. When a prefix is requested, the key is the
   --                  unprefixed table name.
   --
   function Tables (This    : Wpdb_Class;
                    Scope   : String  := "all";
                    Prefix  : Boolean := True;
                    Blog_Id : Integer := 0)
                    return Array_Type;

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
   function Check_ASCII (This : Wpdb_Class;
                         Item : String)
                         return Boolean is (False);

   --
   -- Connects to and selects database.
   --
   -- If `allow_bail` is false, the lack of database connection will need to be
   -- handled manually.
   --
   -- @since 3.0.0
   -- @since 3.9.0 allow_bail parameter added.
   --
   -- @param bool allow_bail Optional. Allows the function to bail. Default true.
   -- @return bool True with a successful connection, false on failure.
   --
   function DB_Connect (This       : in out Wpdb_Class;
                        Allow_Bail : Boolean := True)
                        return Boolean;

   --
   -- Parses the DB_HOST setting to interpret it for mysqli_real_connect().
   --
   -- mysqli_real_connect() doesn"t support the host param including a port or socket
   -- like mysql_connect() does. This duplicates how mysql_connect() detects a port
   -- and/or socket file.
   --
   -- @since 4.9.0
   --
   -- @param string host The DB_HOST setting to parse.
   -- @return array|false {
   --     Array containing the host, the port, the socket and
   --     whether it is an IPv6 address, in that order.
   --     False if the host couldn"t be parsed.
   --
   --     @type string      0 Host name.
   --     @type string|null 1 Port.
   --     @type string|null 2 Socket.
   --     @type bool        3 Whether it is an IPv6 address.
   -- }
   --
   function Parse_DB_Host (This : Wpdb_Class;
                           Host : String)
                           return Array_Type;

   --
   -- Checks that the connection to the database is still up. If not, try to reconnect.
   --
   -- If this function is unable to reconnect, it will forcibly die, or if called
   -- after the {@see "template_redirect"} hook has been fired, return false instead.
   --
   -- If `allow_bail` is false, the lack of database connection will need to be
   -- handled manually.
   --
   -- @since 3.9.0
   --
   -- @param bool allow_bail Optional. Allows the function to bail. Default true.
   -- @return bool|void True if the connection is up.
   --
   function Check_Connection (This       : Wpdb_Class;
                              Allow_Bail : Boolean := True)
                              return Boolean;

   --
   -- Checks if the query is accessing a collation considered safe on the current
   -- version of MySQL.
   --
   -- @since 4.2.0
   --
   -- @param string $query The query to check.
   -- @return bool True if the collation is safe, false if it isn't.
   --
   -- protected
   function Check_Safe_Collation (This  : in out Wpdb_Class;
                                  Query : Statement_Type)
                                  return Boolean;

   --
   -- Strips any invalid characters based on value/charset pairs.
   --
   -- @since 4.2.0
   --
   -- @param array data Array of value arrays. Each value array has the keys "value"
   --                    and "charset". An optional "ascii" key can be set to false
   --                    to avoid redundant ASCII checks.
   -- @return array|WP_Error The data parameter, with invalid characters removed from
   --                        each value. This works as a passthrough: any additional
   --                        keys such as "field" are retained in each value array. If
   --                        we cannot remove invalid characters, a WP_Error object is
   --                        returned.
   --
   -- protected
   function Strip_Invalid_Text (This : in out Wpdb_Class;
                                Data : Array_Type)
                                return Array_Type;

   --
   -- Strips any invalid characters from the query.
   --
   -- @since 4.2.0
   --
   -- @param string query Query to convert.
   -- @return string|WP_Error The converted query, or a WP_Error object if the
   --                          conversion fails.
   --
   -- protected
   function Strip_Invalid_Text_From_Query (This  : Wpdb_Class;
                                           Query : String)
                                           return String;

   --
   -- Deletes a row in the table.
   --
   -- Examples:
   --
   --     wpdb::delete("table", array("ID" => 1))
   --     wpdb::delete("table", array("ID" => 1), array("%d"))
   --
   -- @since 3.4.0
   --
   -- @see wpdb::prepare()
   -- @see wpdb::field_types
   -- @see wp_set_wpdb_vars()
   --
   -- @param string       table        Table name.
   -- @param array        where        A named array of WHERE clauses
   --                                   (in column => value pairs).
   --                                   Multiple clauses will be joined with ANDs.
   --                                   Both where columns and where values should be
   --                                   "raw". Sending a null value will create an
   --                                   IS NULL comparison - the corresponding
   --                                   format will be ignored in this case.
   -- @param array|string where_format Optional. An array of formats to be mapped to
   --                                   each of the values in where. If string, that
   --                                   format will be used for all of the items in
   --                                   where. A format is one of "%d", "%f", "%s"
   --                                   (integer, float, string). If omitted, all
   --                                   values in data will be treated as strings
   --                                   unless otherwise specified in
   --                                   wpdb::field_types.
   -- @return int|false The number of rows deleted, or false on error.
   --
   function Delete (This         : in out Wpdb_Class;
                    Table        : String;
                    Where        : Array_Type;
                    Where_Format : String := "") -- null
                    return Rows_Result_Type;

   --
   -- Processes arrays of field/value pairs and field formats.
   --
   -- This is a helper method for wpdb"s CRUD methods, which take field/value pairs
   -- for inserts, updates, and where clauses. This method first pairs each value
   -- with a format. Then it determines the charset of that field, using that
   -- to determine if any invalid text would be stripped. If text is stripped,
   -- then field processing is rejected and the query fails.
   --
   -- @since 4.2.0
   --
   -- @param string table  Table name.
   -- @param array  data   Field/value pair.
   -- @param mixed  format Format for each field.
   -- @return array|false An array of fields that contain paired value and formats.
   --                     False for invalid values.
   --
   -- protected
   function Process_Fields (This   : in out Wpdb_Class;
                            Table  : String;
                            Data   : Array_Type;
                            Format : String) -- Multi_Type
                            return Array_Type;

   --
   -- Prepares arrays of value/format pairs as passed to wpdb CRUD methods.
   --
   -- @since 4.2.0
   --
   -- @param array data   Array of fields to values.
   -- @param mixed format Formats to be mapped to the values in data.
   -- @return array Array, keyed by field names with values being an array
   --               of "value" and "format" keys.
   --
   -- protected
   function Process_Field_Formats (This   : Wpdb_Class;
                                   Data   : Array_Type;
                                   Format : String)
                                   return Array_Type;

   --
   -- Adds field charsets to field/value/format arrays generated by
   -- wpdb::process_field_formats().
   --
   -- @since 4.2.0
   --
   -- @param array  data  As it comes from the wpdb::process_field_formats() method.
   -- @param string table Table name.
   -- @return array|false The same array as data with additional "charset" keys.
   --                     False on failure.
   --
   -- protected
   function Process_Field_Charsets (This  : in out Wpdb_Class;
                                    Data  : Array_Type;
                                    Table : String)
                                    return Array_Type;

   --
   -- For string fields, records the maximum string length that field can safely save.
   --
   -- @since 4.2.1
   --
   -- @param array  data  As it comes from the wpdb::process_field_charsets() method.
   -- @param string table Table name.
   -- @return array|false The same array as data with additional "length" keys, or
   --                     false if any of the values were too long for their
   --                     corresponding field.
   --
   -- protected
   function Process_Field_Lengths (This  : in out Wpdb_Class;
                                   Data  : Array_Type;
                                   Table : String)
                                   return Array_Type;

   --
   -- Updates a row in the table.
   --
   -- Examples:
   --
   --     wpdb::update("table", array("column" => "foo", "field" => "bar"),
   --                           array("ID" => 1))
   --     wpdb::update("table", array("column" => "foo", "field" => 1337),
   --                           array("ID" => 1), array("%s", "%d"), array("%d"))
   --
   -- @since 2.5.0
   --
   -- @see wpdb::prepare()
   -- @see wpdb::field_types
   -- @see wp_set_wpdb_vars()
   --
   -- @param string       table        Table name.
   -- @param array        data         Data to update (in column => value pairs).
   --                                   Both data columns and data values should be
   --                                   "raw" (neither should be SQL escaped).
   --                                   Sending a null value will cause the column to
   --                                   be set to NULL - the corresponding
   --                                   format is ignored in this case.
   -- @param array        where        A named array of WHERE clauses
   --                                   (in column => value pairs).
   --                                   Multiple clauses will be joined with ANDs.
   --                                   Both where columns and where values should be
   --                                   "raw". Sending a null value will create an
   --                                   IS NULL comparison - the corresponding
   --                                   format will be ignored in this case.
   -- @param array|string format       Optional. An array of formats to be mapped to
   --                                   each of the values in data. If string, that
   --                                   format will be used for all of the values in
   --                                   data. A format is one of "%d", "%f", "%s"
   --                                   (integer, float, string). If omitted, all
   --                                   values in data will be treated as strings
   --                                   unless otherwise specified in
   --                                   wpdb::field_types.
   -- @param array|string where_format Optional. An array of formats to be mapped to
   --                                   each of the values in where. If string, that
   --                                   format will be used for all of the items in
   --                                   where. A format is one of "%d", "%f", "%s"
   --                                   (integer, float, string). If omitted, all
   --                                   values in where will be treated as strings.
   --
   -- @return int|false The number of rows updated, or false on error.
   --
   function Update (This         : in out Wpdb_Class;
                    Table        : String;
                    Data         : Array_Type;
                    Where        : Array_Type;
                    Format       : String := ""; -- null
                    Where_Format : String := "") -- null
                    return Rows_Result_Type;

   --
   -- Inserts a row into the table.
   --
   -- Examples:
   --
   --     wpdb::insert("table", array("column" => "foo", "field" => "bar"))
   --     wpdb::insert("table", array("column" => "foo", "field" => 1337),
   --                           array("%s", "%d"))
   --
   -- @since 2.5.0
   --
   -- @see wpdb::prepare()
   -- @see wpdb::field_types
   -- @see wp_set_wpdb_vars()
   --
   -- @param string       table  Table name.
   -- @param array        data   Data to insert (in column => value pairs).
   --                             Both data columns and data values should be "raw"
   --                             (neither should be SQL escaped). Sending a null
   --                             value will cause the column to be set to NULL - the
   --                             corresponding format is ignored in this case.
   -- @param array|string format Optional. An array of formats to be mapped to each of
   --                             the value in data. If string, that format will be
   --                             used for all of the values in data. A format is one
   --                             of "%d", "%f", "%s" (integer, float, string).
   --                             If omitted, all values in data will be treated as
   --                             strings unless otherwise specified in
   --                             wpdb::field_types.
   -- @return int|false The number of rows inserted, or false on error.
   --
   function Insert (This   : in out Wpdb_Class;
                    Table  : String;
                    Data   : Array_Type;
                    Format : String := "") -- null
                    return Rows_Result_Type;

   --
   -- Helper function for insert and replace.
   --
   -- Runs an insert or replace query based on type argument.
   --
   -- @since 3.0.0
   --
   -- @see wpdb::prepare()
   -- @see wpdb::field_types
   -- @see wp_set_wpdb_vars()
   --
   -- @param string       table  Table name.
   -- @param array        data   Data to insert (in column => value pairs).
   --                             Both data columns and data values should be "raw"
   --                             (neither should be SQL escaped). Sending a null
   --                             value will cause the column to be set to NULL - the
   --                             corresponding format is ignored in this case.
   -- @param array|string format Optional. An array of formats to be mapped to each of
   --                             the value in data. If string, that format will be
   --                             used for all of the values in data. A format is one
   --                             of "%d", "%f", "%s" (integer, float, string). If
   --                             omitted, all values in data will be treated as
   --                             strings unless otherwise specified in
   --                             wpdb::field_types.
   -- @param string       type   Optional. Type of operation. Possible values include
   --                             "INSERT" or "REPLACE". Default "INSERT".
   -- @return int|false The number of rows affected, or false on error.
   --
   function X_Insert_Replace_Helper (This   : in out Wpdb_Class;
                                     Table  : String;
                                     Data   : Array_Type;
                                     Format : String := ""; -- null
                                     Typ    : String := "INSERT")
                                     return Rows_Result_Type;

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

   function Query (This  : in out Wpdb_Class;
                   Query : Statement_Type)
                   return Rows_Result_Type;

   procedure Query (Database : in out Wpdb_Class;
                    Query    : Statement_Type);

   --
   -- Internal function to perform the mysql_query() call.
   --
   -- @since 3.9.0
   --
   -- @see wpdb::query()
   --
   -- @param string query The query to run.
   --
   -- private
   procedure X_Do_Query (This  : in out Wpdb_Class;
                         Query : String);

   --
   -- Generates and returns a placeholder escape string for use in queries returned
   -- by ::prepare().
   --
   -- @since 4.8.3
   --
   -- @return string String to escape placeholders.
   --
   function Placeholder_Escape (This : Wpdb_Class)
                                return String;

   --
   -- Removes the placeholder escape strings from a query.
   --
   -- @since 4.8.3
   --
   -- @param string query The query from which the placeholder will be removed.
   -- @return string The query with the placeholder removed.
   --
   function Remove_Placeholder_Escape (This  : Wpdb_Class;
                                       Query : String)
                                       return String;

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
   function Add_Placeholder_Escape (This  : Wpdb_Class;
                                    Query : Statement_Type)
                                    return Statement_Type;

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
   --         "SELECT * FROM `table` WHERE `column` = %s AND `field` = %d OR
   --         `other_field` LIKE %s",
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
                     Args  : List_Type) --, ...$args )
                     return Statement_Type; -- String;

   --
   -- Enables showing of database errors.
   --
   -- This function should be used only to enable showing of errors.
   -- wpdb::hide_errors() should be used instead for hiding errors.
   --
   -- @since 0.71
   --
   -- @see wpdb::hide_errors()
   --
   -- @param bool show Optional. Whether to show errors. Default true.
   -- @return bool Whether showing of errors was previously active.
   --
   function Show_Errors (This : in out Wpdb_Class;
                         Show : Boolean := True)
                         return Boolean;

   procedure Show_Errors (This : in out Wpdb_Class;
                          Show : Boolean := True);

   --
   -- Disables showing of database errors.
   --
   -- By default database errors are not shown.
   --
   -- @since 0.71
   --
   -- @see wpdb::show_errors()
   --
   -- @return bool Whether showing of errors was previously active.
   --
   procedure Hide_Errors (This : in out Wpdb_Class);

   --
   -- First half of escaping for `LIKE` special characters `%` and `_` before
   -- preparing for SQL.
   --
   -- Use this only before wpdb::prepare() or esc_sql(). Reversing the order is
   -- very bad for security.
   --
   -- Example Prepared Statement:
   --
   --     wild = "%";
   --     find = "only 43% of planets";
   --     like = wild . wpdb.esc_like(find) . wild;
   --     sql  = wpdb.prepare("SELECT * FROM wpdb.posts
   --                          WHERE post_content LIKE %s", like);
   --
   -- Example Escape Chain:
   --
   --     sql  = esc_sql(wpdb.esc_like(input));
   --
   -- @since 4.0.0
   --
   -- @param string text The raw text to be escaped. The input typed by the user
   --                     should have no extra or deleted slashes.
   -- @return string Text in the form of a LIKE phrase. The output is not SQL safe.
   --                Call wpdb::prepare() or wpdb::_real_escape() next.
   --
   function ESC_Like (This : Wpdb_Class;
                      Text : String)
                      return String;

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
   -- Enables or disables suppressing of database errors.
   --
   -- By default database errors are suppressed.
   --
   -- @since 2.5.0
   --
   -- @see wpdb::hide_errors()
   --
   -- @param bool suppress Optional. Whether to suppress errors. Default true.
   -- @return bool Whether suppressing of errors was previously active.
   --
   function Suppress_Errors (This     : in out Wpdb_Class;
                             Suppress : Boolean := True)
                             return Boolean;

   procedure Suppress_Errors (This     : in out Wpdb_Class;
                              Suppress : Boolean := True);

   --
   -- Kills cached query results.
   --
   -- @since 0.71
   --
   procedure Flush (This : in out Wpdb_Class);

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
                      Query   : Statement_Type; --  := ""; -- = null,
--                    Output  : String         := ""; -- = OBJECT,
--                    Y       : Natural        := 0;
                      Success : out Boolean);
--                    return String;

   function Get_Row (Db      : in out Wpdb_Class;
                     Query   : Statement_Type; --  := ""; -- = null,
--                   Output  : String         := ""; -- = OBJECT,
                     Y       : Natural        := 0;
                     Success : out Boolean)
                     return String;

   function Get_Row (Db      : in out Wpdb_Class;
                     Query   : Statement_Type;
                     Y       : Natural        := 0;
                     Success : out Boolean)
                     return Array_Type;

   function Get_Row (Db      : in out Wpdb_Class;
                     Query   : Statement_Type; -- := ""; -- = null,
                     Output  : String         := ""; -- = OBJECT,
                     Y       : Natural        := 0;
                     Success : out Boolean)
                     return Natural
                     is (0);
--                   is (raise Program_Error with "not implemented");

   function Get_Row (Db      : in out Wpdb_Class;
                     Query   : Statement_Type; -- := ""; -- = null,
                     Output  : String         := ""; -- = OBJECT,
                     Y       : Natural        := 0;
                     Success : out Boolean)
                     return Inc_Class_Wp_Comments.Wp_Comment
                     is (Inc_Class_Wp_Comments.Null_Comment);

   function Get_Row (Db      : in out Wpdb_Class;
                     Query   : Statement_Type; -- := ""; -- = null,
                     Output  : String         := ""; -- = OBJECT,
                     Y       : Natural        := 0;
                     Success : out Boolean)
                     return Class_Posts.Wp_Post
                     is (Class_Posts.Null_Post);

   function Get_Row (Db      : in out Wpdb_Class;
                     Query   : Statement_Type; --  := ""; -- = null,
                     Output  : String         := ""; -- = OBJECT,
                     Y       : Natural        := 0;
                     Success : out Boolean)
                     return Inc_Class_Wp_Users.Wp_User
                     is (Inc_Class_Wp_Users.Null_User);

   --
   -- Retrieves the character set for the given column.
   --
   -- @since 4.2.0
   --
   -- @param string table  Table name.
   -- @param string column Column name.
   -- @return string|false|WP_Error Column character set as a string. False if the
   --                               column has no character set. WP_Error object if
   --                               there was an error.
   --
   function Get_Col_Charset (This   : in out Wpdb_Class;
                             Table  : String;
                             Column : String)
                             return String;

   --
   -- Retrieves the maximum string length allowed in a given column.
   --
   -- The length may either be specified as a byte length or a character length.
   --
   -- @since 4.2.1
   --
   -- @param string table  Table name.
   -- @param string column Column name.
   -- @return array|false|WP_Error {
   --     Array of column length information, false if the column has no length (for
   --     example, numeric column), WP_Error object if there was an error.
   --
   --     @type int    length The column length.
   --     @type string type   One of "byte" or "char".
   -- }
   --
   function Get_Col_Length (This   : in out Wpdb_Class;
                            Table  : String;
                            Column : String)
                            return Array_Type;

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
                     Query : Statement_Type := "";  -- null;
                     X     : Integer        := 0)
                     return List_Type
                     is (Empty_List);

   --
   -- Retrieves an entire SQL result set from the database (i.e., many rows).
   --
   -- Executes a SQL query and returns the entire SQL result.
   --
   -- @since 0.71
   --
   -- @param string query  SQL query.
   -- @param string output Optional. Any of ARRAY_A | ARRAY_N | OBJECT | OBJECT_K
   --                      constants. With one of the first three, return an array of
   --                      rows indexed from 0 by SQL result row number. Each row is
   --                      an associative array (column => value, ...), a numerically
   --                      indexed array (0 => value, ...), or an object (.column =
   --                      value), respectively. With OBJECT_K. return an associative
   --                      array of row objects keyed by the value of each row's
   --                      first column"s value. Duplicate keys are discarded.
   -- @return array|object|null Database query results.
   --
   procedure Get_Results (This   : in out Wpdb_Class;
                          Query  : Statement_Type);  -- "" -- null

   function Get_Results (This   : in out Wpdb_Class;
                         Query  : Statement_Type; --  := ""; -- null
                         Output : String := "OBJECT")
                         return Array_Type;

   function Get_Results (This   : Wpdb_Class;
                         Query  : String := ""; -- null
                         Output : String := "OBJECT")
                         return Class_Posts.Post_Array
                         is (Class_Posts.Empty_Post_Array);

   --
   -- Retrieves the character set for the given table.
   --
   -- @since 4.2.0
   --
   -- @param string table Table name.
   -- @return string|WP_Error Table character set, WP_Error object if it couldn't
   --                         be found.
   --
   -- protected

   type String_Error_Type is record
      Success : Boolean;
      Item    : Ada.Strings.Unbounded.Unbounded_String;
      Error   : Inc_Class_Wp_Errors.Wp_Error;
   end record;

   function Get_Table_Charset (This  : in out Wpdb_Class;
                               Table : String)
                               return String_Error_Type;

   --
   -- Finds the first table name referenced in a query.
   --
   -- @since 4.2.0
   --
   -- @param string query The query to search.
   -- @return string|false The table name found, or false if a table couldn"t be found.
   --
   -- protected
   function Get_Table_From_Query (This  : Wpdb_Class;
                                  Query : Statement_Type)
                                  return String;

   --
   -- Wraps errors in a nice header and footer and dies.
   --
   -- Will not die if wpdb::show_errors is false.
   --
   -- @since 1.5.0
   --
   -- @param string message    The error message.
   -- @param string error_code Optional. A computer-readable string to identify
   --                           the error. Default "500".
   -- @return void|false Void if the showing of errors is enabled, false if disabled.
   --
   procedure Bail (This       : in out Wpdb_Class;
                   Message    : String;
                   Error_Code : String := "500");

   --
   -- Retrieves the database character collate.
   --
   -- @since 3.5.0
   --
   -- @return string The database character collate.
   --
   function Get_Charset_Collate (This : Wpdb_Class)
                                 return String;

   --
   -- Determines whether the database or WPDB supports a particular feature.
   --
   -- Capability sniffs for the database server and current version of WPDB.
   --
   -- Database sniffs are based on the version of MySQL the site is using.
   --
   -- WPDB sniffs are added as new features are introduced to allow theme and plugin
   -- developers to determine feature support. This is to account for drop-ins which
   -- may introduce feature support at a different time to WordPress.
   --
   -- @since 2.7.0
   -- @since 4.1.0 Added support for the "utf8mb4" feature.
   -- @since 4.6.0 Added support for the "utf8mb4_520" feature.
   --
   -- @see wpdb::db_version()
   --
   -- @param string db_cap The feature to check for. Accepts "collation",
   --                       "group_concat", "subqueries", "set_charset", "utf8mb4",
   --                       or "utf8mb4_520".
   -- @return bool True when the database feature is supported, false otherwise.
   --
   function Has_Cap (This   : Wpdb_Class;
                     DB_Cap : String)
                     return Boolean;

   --
   -- Determines whether MySQL database is at least the required minimum version.
   --
   -- @since 2.5.0
   --
   -- @global string wp_version             The WordPress version string.
   -- @global string required_mysql_version The required MySQL version string.
   -- @return void|WP_Error
   --
   function Check_Database_Version (This : Wpdb_Class)
            return Inc_Class_Wp_Errors.Wp_Error;

   --
   -- Sets the table prefix for the WordPress tables.
   --
   -- @since 2.5.0
   --
   -- @param string prefix          Alphanumeric name for the new prefix.
   -- @param bool   set_table_names Optional. Whether the table names, e.g.
   --                               wpdb::posts, should be updated or not. Default
   --                               true.
   -- @return string|WP_Error Old prefix or WP_Error on error.
   --
   function Set_Prefix (This            : in out Wpdb_Class;
                        Prefix          : String;
                        Set_Table_Names : Boolean := True)
                        return String;

   --
   -- Sets blog ID.
   --
   -- @since 3.0.0
   --
   -- @param int blog_id
   -- @param int network_id Optional.
   -- @return int Previous blog ID.
   --
   function Set_Blog_Id (This       : in out Wpdb_Class;
                         Blog_Id    : Integer;
                         Network_Id : Integer := 0)
                         return Integer;

   --
   -- Selects a database using the current or provided database connection.
   --
   -- The database name will be changed based on the current database connection.
   -- On failure, the execution will bail and display a DB error.
   --
   -- @since 0.71
   --
   -- @param string          db  Database name.
   -- @param mysqli|resource dbh Optional database connection.
   --
   procedure Selectt (This : in out Wpdb_Class;
                      DB   : String;
                      Dbh  : Integer); --  = null) then

   --
   -- Real escape, using mysqli_real_escape_string() or mysql_real_escape_string().
   --
   -- @since 2.8.0
   --
   -- @see mysqli_real_escape_string()
   -- @see mysql_real_escape_string()
   --
   -- @param string string String to escape.
   -- @return string Escaped string.
   --
   function X_Real_Escape (This : Wpdb_Class;
                           Item : String)
                           return String;

   --
   -- Escapes data. Works on arrays.
   --
   -- @since 2.8.0
   --
   -- @uses wpdb::_real_escape()
   --
   -- @param string|array data Data to escape.
   -- @return string|array Escaped data, in the same type as supplied.
   --
   function X_Escape (This : Wpdb_Class;
                      Data : String)
                      return String;

   --
   -- Retrieves one variable from the database.
   --
   -- Executes a SQL query and returns the value from the SQL result.
   -- If the SQL result contains more than one column and/or more than one row,
   -- the value in the column and row specified is returned. If query is null,
   -- the value in the specified column and row from the previous SQL result is
   -- returned.
   --
   -- @since 0.71
   --
   -- @param string|null query Optional. SQL query. Defaults to null, use the result
   --                          from the previous query.
   -- @param int         x     Optional. Column of value to return. Indexed from 0.
   -- @param int         y     Optional. Row of value to return. Indexed from 0.
   -- @return string|null Database query result (as string), or null on failure.
   --
   function Get_Var (This  : in out Wpdb_Class;
                     Query : Statement_Type := ""; -- null
                     X     : Integer        := 0;
                     Y     : Integer        := 1)
                     return String;

   --
   -- Retrieves the database server version.
   --
   -- @since 2.7.0
   --
   -- @return string|null Version number on success, null on failure.
   --
   function DB_Version (This : Wpdb_Class)
                        return String;

   --
   -- Retrieves full database server information.
   --
   -- @since 5.5.0
   --
   -- @return string|false Server info on success, false on failure.
   --
   function DB_Server_Info (This : Wpdb_Class)
            return String;

   --
   -- To_Array
   --
   function To_Array (Db : Wpdb_Class;
                      S  : String)
                      return Array_Type
                      is (Empty_Array);

   -- Added
   procedure Set_Table (This  : in out Wpdb_Class;
                        Table : String;
                        Value : String);

end Class_WpDB;
