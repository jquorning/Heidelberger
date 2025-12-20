--
-- WordPress database access abstraction class.
--
-- Original code from {@link http://php.justinvincent.com Justin Vincent (justin@visunet.ie)end;
--
-- @package WordPress
-- @subpackage Database
-- @since 0.71
--

with Ada.Text_IO;

with Php.Arrays;
with Php.Lists;
with Php.Multibyte;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Hb_Common;

with Inc_Functions;
with Inc_L10n;
with Inc_Load;
with Inc_Plugins;

package body Inc_Class_Wpdb
is
   use Php;
   use Hb_Common;
   use Inc_L10n;
--
-- @since 0.71
--
-- define("EZSQL_VERSION", "WP1.25");

--
-- @since 0.71
--
-- define("OBJECT", "OBJECT");
-- // phpcs:ignore Generic.NamingConventions.UpperCaseConstantName.ConstantNotUpperCase
-- define("object", "OBJECT"); // Back compat.

--
-- @since 2.5.0
--
-- define("OBJECT_K", "OBJECT_K");

--
-- @since 0.71
--
-- define("ARRAY_A", "ARRAY_A");

--
-- @since 0.71
--
-- define("ARRAY_N", "ARRAY_N");

--
-- WordPress database access abstraction class.
--
-- This class is used to interact with a database without needing to use raw SQL statements.
-- By default, WordPress uses this class to instantiate the global wpdb object, providing
-- access to the WordPress database.
--
-- It is possible to replace this class with your own by setting the wpdb global variable
-- in wp-content/db.php file to your class. The wpdb class will still be included, so you can
-- extend it or simply use your own.
--
-- @link https://developer.wordpress.org/reference/classes/wpdb/
--
-- @since 0.71
--
-- #[AllowDynamicProperties]

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Dbuser     : String;
                         Dbpassword : String;
                         Dbname     : String;
                         Dbhost     : String)
                         return Wpdb_Class
   is
      This   : Wpdb_Class;
      Unused : Boolean;
   begin
      -- if WP_DEBUG and then WP_DEBUG_DISPLAY then
      --    This.Show_Errors; -- ()
      -- end;

      -- Use the `mysqli` extension if it exists unless `WP_USE_EXT_MYSQL` is
      -- defined as true.
      -- if (function_exists("mysqli_connect")) then
      --    this.use_mysqli = true;
      --    if (defined("WP_USE_EXT_MYSQL")) then
      --       this.use_mysqli = ! WP_USE_EXT_MYSQL;
      --    end if;
      -- end if;

      This.Dbuser     := +Dbuser;
      This.Dbpassword := +Dbpassword;
      This.Dbname     := +Dbname;
      This.Dbhost     := +Dbhost;

      -- wp-config.php creation will manually connect when ready.
      -- if (defined("WP_SETUP_CONFIG")) then
      --    return;
      -- end if;

      Unused := This.DB_Connect; -- ()

      return This;
   end X_Construct;

        --
        -- Makes private properties readable for backward compatibility.
        --
        -- @since 3.5.0
        --
        -- @param string name The private member to get, and optionally process.
        -- @return mixed The private member.
        --
        -- public function __get(name) then
        --         if ("col_info" === name) then
        --                 this.load_col_info();
        --         end;

        --         return this.name;
        -- end;

        --
        -- Makes private properties settable for backward compatibility.
        --
        -- @since 3.5.0
        --
        -- @param string name  The private member to set.
        -- @param mixed  value The value to set.
        --
        -- public function __set(name, value) then
        --         protected_members = array(
        --                 "col_meta",
        --                 "table_charset",
        --                 "check_current_query",
        --        );
        --         if (in_array(name, protected_members, true)) then
        --                 return;
        --         end;
        --         this.name = value;
        -- end;

        --
        -- Makes private properties check-able for backward compatibility.
        --
        -- @since 3.5.0
        --
        -- @param string name The private member to check.
        -- @return bool If the member is set or not.
        --
        -- public function __isset(name) then
        --         return isset(this.name);
        -- end;

        --
        -- Makes private properties un-settable for backward compatibility.
        --
        -- @since 3.5.0
        --
        -- @param string name  The private member to unset
        --
        -- public function __unset(name) then
        --         unset(this.name);
        -- end;

        --
        -- Sets this.charset and this.collate.
        --
        -- @since 3.1.0
        --
        -- public function init_charset() then
        --         charset = "";
        --         collate = "";

        --         if (function_exists("is_multisite") && is_multisite()) then
        --                 charset = "utf8";
        --                 if (defined("DB_COLLATE") && DB_COLLATE) then
        --                         collate = DB_COLLATE;
        --                 end; else then
        --                         collate = "utf8_general_ci";
        --                 end;
        --         end; elseif (defined("DB_COLLATE")) then
        --                 collate = DB_COLLATE;
        --         end;

        --         if (defined("DB_CHARSET")) then
        --                 charset = DB_CHARSET;
        --         end;

        --         charset_collate = this.determine_charset(charset, collate);

        --         this.charset = charset_collate["charset"];
        --         this.collate = charset_collate["collate"];
        -- end;

        --
        -- Determines the best charset and collation to use given a charset and collation.
        --
        -- For example, when able, utf8mb4 should be used instead of utf8.
        --
        -- @since 4.6.0
        --
        -- @param string charset The character set to check.
        -- @param string collate The collation to check.
        -- @return array then
        --     The most appropriate character set and collation to use.
        --
        --     @type string charset Character set.
        --     @type string collate Collation.
        -- end;
        --
        -- public function determine_charset(charset, collate) then
        --         if ((this.use_mysqli && ! (this.dbh instanceof mysqli)) || empty(this.dbh)) then
        --                 return compact("charset", "collate");
        --         end;

        --         if ("utf8" === charset && this.has_cap("utf8mb4")) then
        --                 charset = "utf8mb4";
        --         end;

        --         if ("utf8mb4" === charset && ! this.has_cap("utf8mb4")) then
        --                 charset = "utf8";
        --                 collate = str_replace("utf8mb4_", "utf8_", collate);
        --         end;

        --         if ("utf8mb4" === charset) then
        --                 // _general_ is outdated, so we can upgrade it to _unicode_, instead.
        --                 if (! collate || "utf8_general_ci" === collate) then
        --                         collate = "utf8mb4_unicode_ci";
        --                 end; else then
        --                         collate = str_replace("utf8_", "utf8mb4_", collate);
        --                 end;
        --         end;

        --         // _unicode_520_ is a better collation, we should use that when it"s available.
        --         if (this.has_cap("utf8mb4_520") && "utf8mb4_unicode_ci" === collate) then
        --                 collate = "utf8mb4_unicode_520_ci";
        --         end;

        --         return compact("charset", "collate");
        -- end;

        --
        -- Sets the connection"s character set.
        --
        -- @since 3.1.0
        --
        -- @param mysqli|resource dbh     The connection returned by `mysqli_connect()` or `mysql_connect()`.
        -- @param string          charset Optional. The character set. Default null.
        -- @param string          collate Optional. The collation. Default null.
        --
        -- public function set_charset(dbh, charset = null, collate = null) then
        --         if (! isset(charset)) then
        --                 charset = this.charset;
        --         end;
        --         if (! isset(collate)) then
        --                 collate = this.collate;
        --         end;
        --         if (this.has_cap("collation") && ! empty(charset)) then
        --                 set_charset_succeeded = true;

        --                 if (this.use_mysqli) then
        --                         if (function_exists("mysqli_set_charset") && this.has_cap("set_charset")) then
        --                                 set_charset_succeeded = mysqli_set_charset(dbh, charset);
        --                         end;

        --                         if (set_charset_succeeded) then
        --                                 query = this.prepare("SET NAMES %s", charset);
        --                                 if (! empty(collate)) then
        --                                         query .= this.prepare(" COLLATE %s", collate);
        --                                 end;
        --                                 mysqli_query(dbh, query);
        --                         end;
        --                 end; else then
        --                         if (function_exists("mysql_set_charset") && this.has_cap("set_charset")) then
        --                                 set_charset_succeeded = mysql_set_charset(charset, dbh);
        --                         end;
        --                         if (set_charset_succeeded) then
        --                                 query = this.prepare("SET NAMES %s", charset);
        --                                 if (! empty(collate)) then
        --                                         query .= this.prepare(" COLLATE %s", collate);
        --                                 end;
        --                                 mysql_query(query, dbh);
        --                         end;
        --                 end;
        --         end;
        -- end;

        --
        -- Changes the current SQL mode, and ensures its WordPress compatibility.
        --
        -- If no modes are passed, it will ensure the current MySQL server modes are compatible.
        --
        -- @since 3.9.0
        --
        -- @param array modes Optional. A list of SQL modes to set. Default empty array.
        --
        -- public function set_sql_mode(modes = array()) then
        --         if (empty(modes)) then
        --                 if (this.use_mysqli) then
        --                         res = mysqli_query(this.dbh, "SELECT @@SESSION.sql_mode");
        --                 end; else then
        --                         res = mysql_query("SELECT @@SESSION.sql_mode", this.dbh);
        --                 end;

        --                 if (empty(res)) then
        --                         return;
        --                 end;

        --                 if (this.use_mysqli) then
        --                         modes_array = mysqli_fetch_array(res);
        --                         if (empty(modes_array[0])) then
        --                                 return;
        --                         end;
        --                         modes_str = modes_array[0];
        --                 end; else then
        --                         modes_str = mysql_result(res, 0);
        --                 end;

        --                 if (empty(modes_str)) then
        --                         return;
        --                 end;

        --                 modes = explode(",", modes_str);
        --         end;

        --         modes = array_change_key_case(modes, CASE_UPPER);

        --         --
        --         -- Filters the list of incompatible SQL modes to exclude.
        --         --
        --         -- @since 3.9.0
        --         --
        --         -- @param array incompatible_modes An array of incompatible modes.
        --         --
        --         incompatible_modes = (array) apply_filters("incompatible_sql_modes", this.incompatible_modes);

        --         foreach (modes as i => mode) then
        --                 if (in_array(mode, incompatible_modes, true)) then
        --                         unset(modes[ i ]);
        --                 end;
        --         end;

        --         modes_str = implode(",", modes);

        --         if (this.use_mysqli) then
        --                 mysqli_query(this.dbh, "SET SESSION sql_mode="modes_str"");
        --         end; else then
        --                 mysql_query("SET SESSION sql_mode="modes_str"", this.dbh);
        --         end;
        -- end;

   ----------------
   -- Set_Prefix --
   ----------------

   function Set_Prefix (This            : in out Wpdb_Class;
                        Prefix          : String;
                        Set_Table_Names : Boolean := True)
                        return String
   is
      use Php.Preg;

      Old_Prefix   : Unbounded_String;
      Unused_Match : List_Type;
   begin
      if 0 = Preg_Match ("|[^a-z0-9_]|i", Prefix, Unused_Match) then
         return "";
--       return new Wp_Error ("invalid_db_prefix", "Invalid database prefix");
      end if;

      Old_Prefix := +(if Inc_Load.Is_Multisite then "" else Prefix);

      if Isset (-This.Base_Prefix) then
         Old_Prefix := This.Base_Prefix;
      end if;

      This.Base_Prefix := +Prefix;

      if Set_Table_Names then

         -- for A of This.Tables ("global") loop
         --    declare
         --       use String_Maps;

         --       Table          : constant String := Key   (A);
         --       Prefixed_Table : constant String := Value (A);
         --    begin
         --       null; -- This (Table) := Prefixed_Table;
         --    end;
         -- end loop;

         if Inc_Load.Is_Multisite and then This.Blogid = 0 then
            return -Old_Prefix;
         end if;

         This.Prefix := +This.Get_Blog_Prefix; -- ()

         -- for A of This.Tables ("blog") loop
         --    declare
         --       use String_Maps;

         --       Table          : constant String := Key   (A);
         --       Prefixed_Table : constant String := Value (A);
         --    begin
         --       null; -- Set (This, Table, Prefixed_Table);
         --    end;
         -- end loop;

         -- for A of This.Tables ("old") loop
         --    declare
         --       use String_Maps;

         --       Table          : constant String := Key   (A);
         --       Prefixed_Table : constant String := Value (A);
         --    begin
         --       null; -- Set (This, Table, Prefixed_Table);
         --    end;
         -- end loop;

      end if;
      return -Old_Prefix;
   end Set_Prefix;

        --
        -- Sets blog ID.
        --
        -- @since 3.0.0
        --
        -- @param int blog_id
        -- @param int network_id Optional.
        -- @return int Previous blog ID.
        --
        -- public function set_blog_id(blog_id, network_id = 0) then
        --         if (! empty(network_id)) then
        --                 this.siteid = network_id;
        --         end;

        --         old_blog_id  = this.blogid;
        --         this.blogid = blog_id;

        --         this.prefix = this.get_blog_prefix();

        --         foreach (this.tables("blog") as table => prefixed_table) then
        --                 this.table = prefixed_table;
        --         end;

        --         foreach (this.tables("old") as table => prefixed_table) then
        --                 this.table = prefixed_table;
        --         end;

        --         return old_blog_id;
        -- end;

        --
        -- Gets blog prefix.
        --
        -- @since 3.0.0
        --
        -- @param int blog_id Optional.
        -- @return string Blog prefix.
        --
        -- public function get_blog_prefix(blog_id = null) then
        --         if (is_multisite()) then
        --                 if (null === blog_id) then
        --                         blog_id = this.blogid;
        --                 end;

        --                 blog_id = (int) blog_id;

        --                 if (defined("MULTISITE") && (0 === blog_id || 1 === blog_id)) then
        --                         return this.base_prefix;
        --                 end; else then
        --                         return this.base_prefix . blog_id . "_";
        --                 end;
        --         end; else then
        --                 return this.base_prefix;
        --         end;
        -- end;

        --
        -- Returns an array of WordPress tables.
        --
        -- Also allows for the `CUSTOM_USER_TABLE` and `CUSTOM_USER_META_TABLE` to override the WordPress users
        -- and usermeta tables that would otherwise be determined by the prefix.
        --
        -- The `scope` argument can take one of the following:
        --
        -- - "all" - returns "all" and "global" tables. No old tables are returned.
        -- - "blog" - returns the blog-level tables for the queried blog.
        -- - "global" - returns the global tables for the installation, returning multisite tables only on multisite.
        -- - "ms_global" - returns the multisite global tables, regardless if current installation is multisite.
        -- - "old" - returns tables which are deprecated.
        --
        -- @since 3.0.0
        -- @since 6.1.0 `old` now includes deprecated multisite global tables only on multisite.
        --
        -- @uses wpdb::tables
        -- @uses wpdb::old_tables
        -- @uses wpdb::global_tables
        -- @uses wpdb::ms_global_tables
        -- @uses wpdb::old_ms_global_tables
        --
        -- @param string scope   Optional. Possible values include "all", "global", "ms_global", "blog",
        --                        or "old" tables. Default "all".
        -- @param bool   prefix  Optional. Whether to include table prefixes. If blog prefix is requested,
        --                        then the custom users and usermeta tables will be mapped. Default true.
        -- @param int    blog_id Optional. The blog_id to prefix. Used only when prefix is requested.
        --                        Defaults to `wpdb::blogid`.
        -- @return string[] Table names. When a prefix is requested, the key is the unprefixed table name.
        --
        -- public function tables(scope = "all", prefix = true, blog_id = 0) then
        --         switch (scope) then
        --                 case "all":
        --                         tables = array_merge(this.global_tables, this.tables);
        --                         if (is_multisite()) then
        --                                 tables = array_merge(tables, this.ms_global_tables);
        --                         end;
        --                         break;
        --                 case "blog":
        --                         tables = this.tables;
        --                         break;
        --                 case "global":
        --                         tables = this.global_tables;
        --                         if (is_multisite()) then
        --                                 tables = array_merge(tables, this.ms_global_tables);
        --                         end;
        --                         break;
        --                 case "ms_global":
        --                         tables = this.ms_global_tables;
        --                         break;
        --                 case "old":
        --                         tables = this.old_tables;
        --                         if (is_multisite()) then
        --                                 tables = array_merge(tables, this.old_ms_global_tables);
        --                         end;
        --                         break;
        --                 default:
        --                         return array();
        --         end;

        --         if (prefix) then
        --                 if (! blog_id) then
        --                         blog_id = this.blogid;
        --                 end;
        --                 blog_prefix   = this.get_blog_prefix(blog_id);
        --                 base_prefix   = this.base_prefix;
        --                 global_tables = array_merge(this.global_tables, this.ms_global_tables);
        --                 foreach (tables as k => table) then
        --                         if (in_array(table, global_tables, true)) then
        --                                 tables[ table ] = base_prefix . table;
        --                         end; else then
        --                                 tables[ table ] = blog_prefix . table;
        --                         end;
        --                         unset(tables[ k ]);
        --                 end;

        --                 if (isset(tables["users"]) && defined("CUSTOM_USER_TABLE")) then
        --                         tables["users"] = CUSTOM_USER_TABLE;
        --                 end;

        --                 if (isset(tables["usermeta"]) && defined("CUSTOM_USER_META_TABLE")) then
        --                         tables["usermeta"] = CUSTOM_USER_META_TABLE;
        --                 end;
        --         end;

        --         return tables;
        -- end;

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
        -- public function select(db, dbh = null) then
        --         if (is_null(dbh)) then
        --                 dbh = this.dbh;
        --         end;

        --         if (this.use_mysqli) then
        --                 success = mysqli_select_db(dbh, db);
        --         end; else then
        --                 success = mysql_select_db(db, dbh);
        --         end;
        --         if (! success) then
        --                 this.ready = false;
        --                 if (! did_action("template_redirect")) then
        --                         wp_load_translations_early();

        --                         message = "<h1>" . __("Cannot select database") . "</h1>\n";

        --                         message .= "<p>" . sprintf(
        --                                 /* translators: %s: Database name.--
        --                                 __("The database server could be connected to (which means your username and password is okay) but the %s database could not be selected."),
        --                                 "<code>" . htmlspecialchars(db, ENT_QUOTES) . "</code>"
        --                        ) . "</p>\n";

        --                         message .= "<ul>\n";
        --                         message .= "<li>" . __("Are you sure it exists?") . "</li>\n";

        --                         message .= "<li>" . sprintf(
        --                                 /* translators: 1: Database user, 2: Database name.--
        --                                 __("Does the user %1s have permission to use the %2s database?"),
        --                                 "<code>" . htmlspecialchars(this.dbuser, ENT_QUOTES) . "</code>",
        --                                 "<code>" . htmlspecialchars(db, ENT_QUOTES) . "</code>"
        --                        ) . "</li>\n";

        --                         message .= "<li>" . sprintf(
        --                                 /* translators: %s: Database name.--
        --                                 __("On some systems the name of your database is prefixed with your username, so it would be like <code>username_%1s</code>. Could that be the problem?"),
        --                                 htmlspecialchars(db, ENT_QUOTES)
        --                        ) . "</li>\n";

        --                         message .= "</ul>\n";

        --                         message .= "<p>" . sprintf(
        --                                 /* translators: %s: Support forums URL.--
        --                                 __("If you do not know how to set up a database you should <strong>contact your host</strong>. If all else fails you may find help at the <a href="%s">WordPress Support Forums</a>."),
        --                                 __("https://wordpress.org/support/forums/")
        --                        ) . "</p>\n";

        --                         this.bail(message, "db_select_fail");
        --                 end;
        --         end;
        -- end;

        --
        -- Do not use, deprecated.
        --
        -- Use esc_sql() or wpdb::prepare() instead.
        --
        -- @since 2.8.0
        -- @deprecated 3.6.0 Use wpdb::prepare()
        -- @see wpdb::prepare()
        -- @see esc_sql()
        --
        -- @param string string
        -- @return string
        --
        -- public function _weak_escape(string) then
        --         if (func_num_args() === 1 && function_exists("_deprecated_function")) then
        --                 _deprecated_function(__METHOD__, "3.6.0", "wpdb::prepare() or esc_sql()");
        --         end;
        --         return addslashes(string);
        -- end;

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
        -- public function _real_escape(string) then
        --         if (! is_scalar(string)) then
        --                 return "";
        --         end;

        --         if (this.dbh) then
        --                 if (this.use_mysqli) then
        --                         escaped = mysqli_real_escape_string(this.dbh, string);
        --                 end; else then
        --                         escaped = mysql_real_escape_string(string, this.dbh);
        --                 end;
        --         end; else then
        --                 class = get_class(this);

        --                 wp_load_translations_early();
        --                 /* translators: %s: Database access abstraction class, usually wpdb or a class extending wpdb.--
        --                 _doing_it_wrong(class, sprintf(__("%s must set a database connection for use with escaping."), class), "3.6.0");

        --                 escaped = addslashes(string);
        --         end;

        --         return this.add_placeholder_escape(escaped);
        -- end;

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
        -- public function _escape(data) then
        --         if (is_array(data)) then
        --                 foreach (data as k => v) then
        --                         if (is_array(v)) then
        --                                 data[ k ] = this._escape(v);
        --                         end; else then
        --                                 data[ k ] = this._real_escape(v);
        --                         end;
        --                 end;
        --         end; else then
        --                 data = this._real_escape(data);
        --         end;

        --         return data;
        -- end;

        --
        -- Do not use, deprecated.
        --
        -- Use esc_sql() or wpdb::prepare() instead.
        --
        -- @since 0.71
        -- @deprecated 3.6.0 Use wpdb::prepare()
        -- @see wpdb::prepare()
        -- @see esc_sql()
        --
        -- @param string|array data Data to escape.
        -- @return string|array Escaped data, in the same type as supplied.
        --
        -- public function escape(data) then
        --         if (func_num_args() === 1 && function_exists("_deprecated_function")) then
        --                 _deprecated_function(__METHOD__, "3.6.0", "wpdb::prepare() or esc_sql()");
        --         end;
        --         if (is_array(data)) then
        --                 foreach (data as k => v) then
        --                         if (is_array(v)) then
        --                                 data[ k ] = this.escape(v, "recursive");
        --                         end; else then
        --                                 data[ k ] = this._weak_escape(v, "internal");
        --                         end;
        --                 end;
        --         end; else then
        --                 data = this._weak_escape(data, "internal");
        --         end;

        --         return data;
        -- end;

        --
        -- Escapes content by reference for insertion into the database, for security.
        --
        -- @uses wpdb::_real_escape()
        --
        -- @since 2.3.0
        --
        -- @param string string String to escape.
        --
        -- public function escape_by_ref(&string) then
        --         if (! is_float(string)) then
        --                 string = this._real_escape(string);
        --         end;
        -- end;

        --
        -- Prepares a SQL query for safe execution.
        --
        -- Uses sprintf()-like syntax. The following placeholders can be used in the query string:
        --
        -- - %d (integer)
        -- - %f (float)
        -- - %s (string)
        --
        -- All placeholders MUST be left unquoted in the query string. A corresponding argument
        -- MUST be passed for each placeholder.
        --
        -- Note: There is one exception to the above: for compatibility with old behavior,
        -- numbered or formatted string placeholders (eg, `%1s`, `%5s`) will not have quotes
        -- added by this function, so should be passed with appropriate quotes around them.
        --
        -- Literal percentage signs (`%`) in the query string must be written as `%%`. Percentage wildcards
        -- (for example, to use in LIKE syntax) must be passed via a substitution argument containing
        -- the complete LIKE string, these cannot be inserted directly in the query string.
        -- Also see wpdb::esc_like().
        --
        -- Arguments may be passed as individual arguments to the method, or as a single array
        -- containing all arguments. A combination of the two is not supported.
        --
        -- Examples:
        --
        --     wpdb.prepare(
        --         "SELECT-- FROM `table` WHERE `column` = %s AND `field` = %d OR `other_field` LIKE %s",
        --         array("foo", 1337, "%bar")
        --    );
        --
        --     wpdb.prepare(
        --         "SELECT DATE_FORMAT(`field`, "%%c") FROM `table` WHERE `column` = %s",
        --         "foo"
        --    );
        --
        -- @since 2.3.0
        -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
        --              by updating the function signature. The second parameter was changed
        --              from `args` to `...args`.
        --
        -- @link https://www.php.net/sprintf Description of syntax.
        --
        -- @param string      query   Query statement with sprintf()-like placeholders.
        -- @param array|mixed args    The array of variables to substitute into the query"s placeholders
        --                             if being called with an array of arguments, or the first variable
        --                             to substitute into the query"s placeholders if being called with
        --                             individual arguments.
        -- @param mixed       ...args Further variables to substitute into the query"s placeholders
        --                             if being called with individual arguments.
        -- @return string|void Sanitized query string, if there is a query to prepare.
        --
        -- public function prepare(query, ...args)

   function Prepare (Db    : Wpdb_Class;
                     Query : String;
                     Args  : List_Type) --, ...args)
                     return String
   is
      use Php.Preg;
      use Php.Strings;
      use Inc_Functions;

      function Func return Array_Type;

      function Func return Array_Type
      is
      begin
         return To_Array (Db, "escape_by_ref");
      end Func;

   begin
      Ada.Text_IO.Put_Line ("inc_class_wpdb.prepare: " & Query);

      if Query = "" then
         return "";  -- "" added jq
      end if;

      -- This is not meant to be foolproof
      -- but it will catch obviously incorrect usage.
      if Strpos (Query, "%") = 0 then
         Inc_Load.Wp_Load_Translations_Early;  -- ();
         X_Doing_It_Wrong (
            "wpdb::prepare",
            Sprintf (
               -- translators: %s: wpdb::prepare()
               abs "The query argument of %s must have a placeholder.",
               To_List ("wpdb::prepare()")
            ),
            "3.9.0");
      end if;

      -- If args were passed as an array (as in vsprintf), move them up.
      declare
         Passed_As_Array : constant Boolean := False;
      begin
--                if (isset(args[0]) && is_array(args[0]) && 1 === count(args)) then
--                        passed_as_array = true;
--                        args            = args[0];
--                end;

                -- foreach (args as arg) then
                --         if (! is_scalar(arg) && ! is_null(arg)) then
                --                 Wp_Load_Translations_Early; -- ();
                --                 _doing_it_wrong(
                --                         "wpdb::prepare",
                --                         sprintf(
                --                                 /* translators: %s: Value type.--
                --                                 __("Unsupported value type (%s)."),
                --                                 gettype(arg)
                --                        ),
                --                         "4.8.2"
                --                );
                --         end if;
                -- end loop;

      --
      -- Specify the formatting allowed in a placeholder. The following are allowed:
      --
      -- - Sign specifier, e.g. +d
      -- - Numbered placeholders, e.g. %1s
      -- - Padding specifier, including custom padding characters, e.g. %05s, %"#5s
      -- - Alignment specifier, e.g. %05-s
      -- - Precision specifier, e.g. %.2f
      --
         declare
            Allowed_Format : String :=
               "(?:[1-9][0-9]*[])?[-+0-9]*(?: |0|\'.)?[-+0-9]*(?:\.[0-9]+)?";
            Query_2 : Unbounded_String;
         begin
            --
            -- If a %s placeholder already has quotes around it, removing the
            -- existing quotes and re-inserting them ensures the quotes are consistent.
            --
            -- For backward compatibility, this is only applied to %s, and not to
            -- placeholders like %1s, which are frequently used in the middle of
            -- longer strings, or as table name placeholders.
            --
            Query_2 := +Str_Replace ("'%s'", "%s", Query);
            -- Strip any existing single quotes.

            Query_2 := +Str_Replace ("""%s""", "%s", -Query_2);
            -- Strip any existing double quotes.

            Query_2 := +Preg_Replace ("/(?<!%)%s/", "'%s'", -Query_2);
            -- Quote the strings, avoiding escaped strings like %%s.

            Query_2 := +Preg_Replace ("/(?<!%)(%(allowed_format)?f)/", "%\\2F",
                                      -Query_2);
            -- Force floats to be locale-unaware.

            Query_2 := +Preg_Replace ("/%(?:%||(?!(allowed_format)?[sdF]))/",
                                      "%%\\1", -Query_2);
            -- Escape any unescaped percents.
            declare
               -- Count the number of valid placeholders in the query.
               Matches : Array_Type;
               Placeholders : constant Integer :=
                  Preg_Match_All ("/(^|[^%]|(%%)+)%(allowed_format)?[sdF]/",
                                  -Query_2, Matches);
               Args_Count : constant Natural := Natural (List_Vectors.Length (Args));
            begin
               if Args_Count /= Placeholders then
                  if 1 = Placeholders and then Passed_As_Array then
                     -- If the passed query only expected one argument, but the wrong
                     -- number of arguments were sent as an array, bail.
                     Inc_Load.Wp_Load_Translations_Early; -- ();
                     X_Doing_It_Wrong (
                        "wpdb::prepare",
                        abs "The query only expected one placeholder, but an array of multiple placeholders was sent.",
                        "4.9.0");

                     return "";
                  else
                     --
                     -- If we don"t have the right number of placeholders,
                     -- but they were passed as individual arguments,
                     -- or we were expecting multiple arguments in an array, throw
                     -- a warning.
                     --
                     Inc_Load.Wp_Load_Translations_Early; -- ();
                     X_Doing_It_Wrong (
                        "wpdb::prepare",
                        Sprintf (
                           -- translators: 1: Number of placeholders, 2: Number of
                           -- arguments passed.
                           abs "The query does not contain the correct number of placeholders (%1d) for the number of arguments passed (%2d).",
                           To_List (List => (
                             1 => +Placeholders'Image,
                             2 => +Args_Count'Image))),
                        "4.8.3");

                     --
                     -- If we don"t have enough arguments to match the placeholders,
                     -- return an empty string to avoid a fatal error on PHP 8.
                     --
                     if Args_Count < Placeholders then
                        declare
--                         use Array_Maps;

                           Max_Numbered_Placeholder : constant Integer :=
                             (if True -- Matches (3) /= "" -- not in 0  -- not empty
                              then 99 -- Max (Array_Map
                                       -- ("intval",
                                       --  Empty_Array & Matches (3)))
--              Table => To_Array (List => (1 => Build (Element (Matches, 3)))))
                              else 0);
                        begin
                           if
                             Max_Numbered_Placeholder = 0 or else -- not
                             Args_Count < Max_Numbered_Placeholder
                           then
                              return "";
                           end if;
                        end;
                     end if;
                  end if;
               end if;

--             Array_Walk (Args, Func"Access);
--             To_Array (Db, "escape_by_ref"));

               Query_2 := +Vsprintf (-Query_2, Args);

               return Db.Add_Placeholder_Escape (-Query_2);
            end;
         end;
      end;
   end Prepare;

   --------------
   -- ESC_Like --
   --------------

   function ESC_Like (This : Wpdb_Class;
                      Text : String)
                      return String
   is
      use Php.Strings;
   begin
      return Add_C_Slashes (Text, "_%\\");
   end ESC_Like;

        --
        -- Prints SQL/DB error.
        --
        -- @since 0.71
        --
        -- @global array EZSQL_ERROR Stores error information of query and error string.
        --
        -- @param string str The error to display.
        -- @return void|false Void if the showing of errors is enabled, false if disabled.
        --
        -- public function print_error(str = "") then
        --         global EZSQL_ERROR;

        --         if (! str) then
        --                 if (this.use_mysqli) then
        --                         str = mysqli_error(this.dbh);
        --                 end; else then
        --                         str = mysql_error(this.dbh);
        --                 end;
        --         end;
        --         EZSQL_ERROR[] = array(
        --                 "query"     => this.last_query,
        --                 "error_str" => str,
        --        );

        --         if (this.suppress_errors) then
        --                 return false;
        --         end;

        --         caller = this.get_caller();
        --         if (caller) then
        --                 // Not translated, as this will only appear in the error log.
        --                 error_str = sprintf("WordPress database error %1s for query %2s made by %3s", str, this.last_query, caller);
        --         end; else then
        --                 error_str = sprintf("WordPress database error %1s for query %2s", str, this.last_query);
        --         end;

        --         error_log(error_str);

        --         // Are we showing errors?
        --         if (! this.show_errors) then
        --                 return false;
        --         end;

        --         wp_load_translations_early();

        --         // If there is an error then take note of it.
        --         if (is_multisite()) then
        --                 msg = sprintf(
        --                         "%s [%s]\n%s\n",
        --                         __("WordPress database error:"),
        --                         str,
        --                         this.last_query
        --                );

        --                 if (defined("ERRORLOGFILE")) then
        --                         error_log(msg, 3, ERRORLOGFILE);
        --                 end;
        --                 if (defined("DIEONDBERROR")) then
        --                         wp_die(msg);
        --                 end;
        --         end; else then
        --                 str   = htmlspecialchars(str, ENT_QUOTES);
        --                 query = htmlspecialchars(this.last_query, ENT_QUOTES);

        --                 printf(
        --                         "<div id="error"><p class="wpdberror"><strong>%s</strong> [%s]<br /><code>%s</code></p></div>",
        --                         __("WordPress database error:"),
        --                         str,
        --                         query
        --                );
        --         end;
        -- end;

   -----------------
   -- Show_Errors --
   -----------------

   function Show_Errors (This : in out Wpdb_Class;
                         Show : Boolean := True)
                         return Boolean
   is
      Errors : constant Boolean := This.M_Show_Errors;
   begin
      This.M_Show_Errors := Show;
      return Errors;
   end Show_Errors;

   procedure Show_Errors (This : in out Wpdb_Class;
                          Show : Boolean := True)
   is
      Unused : constant Boolean := Show_Errors (This, Show);
   begin
      null;
   end Show_Errors;

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
        -- public function hide_errors() then
        --         show              = this.show_errors;
        --         this.show_errors = false;
        --         return show;
        -- end;

   ---------------------
   -- Suppress_Errors --
   ---------------------

   function Suppress_Errors (This     : in out Wpdb_Class;
                             Suppress : Boolean := True)
                             return Boolean
   is
      Errors : constant Boolean := This.X_Suppress_Errors;
   begin
      This.X_Suppress_Errors := Suppress; -- (bool)
      return Errors;
   end Suppress_Errors;

   procedure Suppress_Errors (This     : in out Wpdb_Class;
                              Suppress : Boolean := True)
   is
      Unused : constant Boolean := Suppress_Errors (This, Suppress);
   begin
      null;
   end Suppress_Errors;

        --
        -- Kills cached query results.
        --
        -- @since 0.71
        --
        -- public function flush() then
        --         this.last_result   = array();
        --         this.col_info      = null;
        --         this.last_query    = null;
        --         this.rows_affected = 0;
        --         this.num_rows      = 0;
        --         this.last_error    = "";

        --         if (this.use_mysqli && this.result instanceof mysqli_result) then
        --                 mysqli_free_result(this.result);
        --                 this.result = null;

        --                 // Sanity check before using the handle.
        --                 if (empty(this.dbh) || ! (this.dbh instanceof mysqli)) then
        --                         return;
        --                 end;

        --                 // Clear out any results from a multi-query.
        --                 while (mysqli_more_results(this.dbh)) then
        --                         mysqli_next_result(this.dbh);
        --                 end;
        --         end; elseif (is_resource(this.result)) then
        --                 mysql_free_result(this.result);
        --         end;
        -- end;

        --
        -- Connects to and selects database.
        --
        -- If `allow_bail` is false, the lack of database connection will need to be handled manually.
        --
        -- @since 3.0.0
        -- @since 3.9.0 allow_bail parameter added.
        --
        -- @param bool allow_bail Optional. Allows the function to bail. Default true.
        -- @return bool True with a successful connection, false on failure.
        --
        -- public function db_connect(allow_bail = true) then
   function DB_Connect (This       : in out Wpdb_Class;
                        Allow_Bail : Boolean := True)
                        return Boolean
                        is (False);
--   is
--   begin
        --         this.is_mysql = true;

        --         /*
        --         -- Deprecated in 3.9+ when using MySQLi. No equivalent
        --         -- new_link parameter exists for mysqli_* functions.
        --         --
        --         new_link     = defined("MYSQL_NEW_LINK") ? MYSQL_NEW_LINK : true;
        --         client_flags = defined("MYSQL_CLIENT_FLAGS") ? MYSQL_CLIENT_FLAGS : 0;

        --         if (this.use_mysqli) then
        --                 /*
        --                 -- Set the MySQLi error reporting off because WordPress handles its own.
        --                 -- This is due to the default value change from `MYSQLI_REPORT_OFF`
        --                 -- to `MYSQLI_REPORT_ERROR|MYSQLI_REPORT_STRICT` in PHP 8.1.
        --                 --
        --                 mysqli_report(MYSQLI_REPORT_OFF);

        --                 this.dbh = mysqli_init();

        --                 host    = this.dbhost;
        --                 port    = null;
        --                 socket  = null;
        --                 is_ipv6 = false;

        --                 host_data = this.parse_db_host(this.dbhost);
        --                 if (host_data) then
        --                         list(host, port, socket, is_ipv6) = host_data;
        --                 end;

        --                 /*
        --                 -- If using the `mysqlnd` library, the IPv6 address needs to be enclosed
        --                 -- in square brackets, whereas it doesn"t while using the `libmysqlclient` library.
        --                 -- @see https://bugs.php.net/bug.php?id=67563
        --                 --
        --                 if (is_ipv6 && extension_loaded("mysqlnd")) then
        --                         host = "[host]";
        --                 end;

        --                 if (WP_DEBUG) then
        --                         mysqli_real_connect(this.dbh, host, this.dbuser, this.dbpassword, null, port, socket, client_flags);
        --                 end; else then
        --                         // phpcs:ignore WordPress.PHP.NoSilencedErrors.Discouraged
        --                         @mysqli_real_connect(this.dbh, host, this.dbuser, this.dbpassword, null, port, socket, client_flags);
        --                 end;

        --                 if (this.dbh.connect_errno) then
        --                         this.dbh = null;

        --                         /*
        --                         -- It"s possible ext/mysqli is misconfigured. Fall back to ext/mysql if:
        --                         --  - We haven"t previously connected, and
        --                         --  - WP_USE_EXT_MYSQL isn"t set to false, and
        --                         --  - ext/mysql is loaded.
        --                         --
        --                         attempt_fallback = true;

        --                         if (this.has_connected) then
        --                                 attempt_fallback = false;
        --                         end; elseif (defined("WP_USE_EXT_MYSQL") && ! WP_USE_EXT_MYSQL) then
        --                                 attempt_fallback = false;
        --                         end; elseif (! function_exists("mysql_connect")) then
        --                                 attempt_fallback = false;
        --                         end;

        --                         if (attempt_fallback) then
        --                                 this.use_mysqli = false;
        --                                 return this.db_connect(allow_bail);
        --                         end;
        --                 end;
        --         end; else then
        --                 if (WP_DEBUG) then
        --                         this.dbh = mysql_connect(this.dbhost, this.dbuser, this.dbpassword, new_link, client_flags);
        --                 end; else then
        --                         // phpcs:ignore WordPress.PHP.NoSilencedErrors.Discouraged
        --                         this.dbh = @mysql_connect(this.dbhost, this.dbuser, this.dbpassword, new_link, client_flags);
        --                 end;
        --         end;

        --         if (! this.dbh && allow_bail) then
        --                 wp_load_translations_early();

        --                 // Load custom DB error template, if present.
        --                 if (file_exists(WP_CONTENT_DIR . "/db-error.php")) then
        --                         require_once WP_CONTENT_DIR . "/db-error.php";
        --                         die();
        --                 end;

        --                 message = "<h1>" . __("Error establishing a database connection") . "</h1>\n";

        --                 message .= "<p>" . sprintf(
        --                         /* translators: 1: wp-config.php, 2: Database host.--
        --                         __("This either means that the username and password information in your %1s file is incorrect or that contact with the database server at %2s could not be established. This could mean your host&#8217;s database server is down."),
        --                         "<code>wp-config.php</code>",
        --                         "<code>" . htmlspecialchars(this.dbhost, ENT_QUOTES) . "</code>"
        --                ) . "</p>\n";

        --                 message .= "<ul>\n";
        --                 message .= "<li>" . __("Are you sure you have the correct username and password?") . "</li>\n";
        --                 message .= "<li>" . __("Are you sure you have typed the correct hostname?") . "</li>\n";
        --                 message .= "<li>" . __("Are you sure the database server is running?") . "</li>\n";
        --                 message .= "</ul>\n";

        --                 message .= "<p>" . sprintf(
        --                         /* translators: %s: Support forums URL.--
        --                         __("If you are unsure what these terms mean you should probably contact your host. If you still need help you can always visit the <a href="%s">WordPress Support Forums</a>."),
        --                         __("https://wordpress.org/support/forums/")
        --                ) . "</p>\n";

        --                 this.bail(message, "db_connect_fail");

        --                 return false;
        --         end; elseif (this.dbh) then
        --                 if (! this.has_connected) then
        --                         this.init_charset();
        --                 end;

        --                 this.has_connected = true;

        --                 this.set_charset(this.dbh);

        --                 this.ready = true;
        --                 this.set_sql_mode();
        --                 this.select(this.dbname, this.dbh);

        --                 return true;
        --         end;

        --         return false;
        -- end;

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
        -- @return array|false then
        --     Array containing the host, the port, the socket and
        --     whether it is an IPv6 address, in that order.
        --     False if the host couldn"t be parsed.
        --
        --     @type string      0 Host name.
        --     @type string|null 1 Port.
        --     @type string|null 2 Socket.
        --     @type bool        3 Whether it is an IPv6 address.
        -- end;
        --
        -- public function parse_db_host(host) then
        --         socket  = null;
        --         is_ipv6 = false;

        --         // First peel off the socket parameter from the right, if it exists.
        --         socket_pos = strpos(host, ":/");
        --         if (false !== socket_pos) then
        --                 socket = substr(host, socket_pos + 1);
        --                 host   = substr(host, 0, socket_pos);
        --         end;

        --         // We need to check for an IPv6 address first.
        --         // An IPv6 address will always contain at least two colons.
        --         if (substr_count(host, ":") > 1) then
        --                 pattern = "#^(?:\[)?(?P<host>[0-9a-fA-F:]+)(?:\]:(?P<port>[\d]+))?#";
        --                 is_ipv6 = true;
        --         end; else then
        --                 // We seem to be dealing with an IPv4 address.
        --                 pattern = "#^(?P<host>[^:/]*)(?::(?P<port>[\d]+))?#";
        --         end;

        --         matches = array();
        --         result  = preg_match(pattern, host, matches);

        --         if (1 !== result) then
        --                 // Couldn"t parse the address, bail.
        --                 return false;
        --         end;

        --         host = ! empty(matches["host"]) ? matches["host"] : "";
        --         // MySQLi port cannot be a string; must be null or an integer.
        --         port = ! empty(matches["port"]) ? absint(matches["port"]) : null;

        --         return array(host, port, socket, is_ipv6);
        -- end;

        --
        -- Checks that the connection to the database is still up. If not, try to reconnect.
        --
        -- If this function is unable to reconnect, it will forcibly die, or if called
        -- after the {@see "template_redirect"} hook has been fired, return false instead.
        --
        -- If `allow_bail` is false, the lack of database connection will need to be handled manually.
        --
        -- @since 3.9.0
        --
        -- @param bool allow_bail Optional. Allows the function to bail. Default true.
        -- @return bool|void True if the connection is up.
        --
        -- public function check_connection(allow_bail = true) then
        --         if (this.use_mysqli) then
        --                 if (! empty(this.dbh) && mysqli_ping(this.dbh)) then
        --                         return true;
        --                 end;
        --         end; else then
        --                 if (! empty(this.dbh) && mysql_ping(this.dbh)) then
        --                         return true;
        --                 end;
        --         end;

        --         error_reporting = false;

        --         // Disable warnings, as we don"t want to see a multitude of "unable to connect" messages.
        --         if (WP_DEBUG) then
        --                 error_reporting = error_reporting();
        --                 error_reporting(error_reporting & ~E_WARNING);
        --         end;

        --         for (tries = 1; tries <= this.reconnect_retries; tries++) then
        --                 // On the last try, re-enable warnings. We want to see a single instance
        --                 // of the "unable to connect" message on the bail() screen, if it appears.
        --                 if (this.reconnect_retries === tries && WP_DEBUG) then
        --                         error_reporting(error_reporting);
        --                 end;

        --                 if (this.db_connect(false)) then
        --                         if (error_reporting) then
        --                                 error_reporting(error_reporting);
        --                         end;

        --                         return true;
        --                 end;

        --                 sleep(1);
        --         end;

        --         // If template_redirect has already happened, it"s too late for wp_die()/dead_db().
        --         // Let"s just return and hope for the best.
        --         if (did_action("template_redirect")) then
        --                 return false;
        --         end;

        --         if (! allow_bail) then
        --                 return false;
        --         end;

        --         wp_load_translations_early();

        --         message = "<h1>" . __("Error reconnecting to the database") . "</h1>\n";

        --         message .= "<p>" . sprintf(
        --                 /* translators: %s: Database host.--
        --                 __("This means that the contact with the database server at %s was lost. This could mean your host&#8217;s database server is down."),
        --                 "<code>" . htmlspecialchars(this.dbhost, ENT_QUOTES) . "</code>"
        --        ) . "</p>\n";

        --         message .= "<ul>\n";
        --         message .= "<li>" . __("Are you sure the database server is running?") . "</li>\n";
        --         message .= "<li>" . __("Are you sure the database server is not under particularly heavy load?") . "</li>\n";
        --         message .= "</ul>\n";

        --         message .= "<p>" . sprintf(
        --                 /* translators: %s: Support forums URL.--
        --                 __("If you are unsure what these terms mean you should probably contact your host. If you still need help you can always visit the <a href="%s">WordPress Support Forums</a>."),
        --                 __("https://wordpress.org/support/forums/")
        --        ) . "</p>\n";

        --         // We weren"t able to reconnect, so we better bail.
        --         this.bail(message, "db_connect_fail");

        --         // Call dead_db() if bail didn"t die, because this database is no more.
        --         // It has ceased to be (at least temporarily).
        --         dead_db();
        -- end;

        --
        -- Performs a database query, using current database connection.
        --
        -- More information can be found on the documentation page.
        --
        -- @since 0.71
        --
        -- @link https://developer.wordpress.org/reference/classes/wpdb/
        --
        -- @param string query Database query.
        -- @return int|bool Boolean true for CREATE, ALTER, TRUNCATE and DROP queries. Number of rows
        --                  affected/selected for all other queries. Boolean false on error.
        --
        -- public function query(query) then
        --         if (! this.ready) then
        --                 this.check_current_query = true;
        --                 return false;
        --         end;

        --         --
        --         -- Filters the database query.
        --         --
        --         -- Some queries are made before the plugins have been loaded,
        --         -- and thus cannot be filtered with this method.
        --         --
        --         -- @since 2.1.0
        --         --
        --         -- @param string query Database query.
        --         --
        --         query = apply_filters("query", query);

        --         if (! query) then
        --                 this.insert_id = 0;
        --                 return false;
        --         end;

        --         this.flush();

        --         // Log how the function was called.
        --         this.func_call = "\db.query(\"query\")";

        --         // If we"re writing to the database, make sure the query will write safely.
        --         if (this.check_current_query && ! this.check_ascii(query)) then
        --                 stripped_query = this.strip_invalid_text_from_query(query);
        --                 // strip_invalid_text_from_query() can perform queries, so we need
        --                 // to flush again, just to make sure everything is clear.
        --                 this.flush();
        --                 if (stripped_query !== query) then
        --                         this.insert_id  = 0;
        --                         this.last_query = query;

        --                         wp_load_translations_early();

        --                         this.last_error = __("WordPress database error: Could not perform query because it contains invalid data.");

        --                         return false;
        --                 end;
        --         end;

        --         this.check_current_query = true;

        --         // Keep track of the last query for debug.
        --         this.last_query = query;

        --         this._do_query(query);

        --         // Database server has gone away, try to reconnect.
        --         mysql_errno = 0;
        --         if (! empty(this.dbh)) then
        --                 if (this.use_mysqli) then
        --                         if (this.dbh instanceof mysqli) then
        --                                 mysql_errno = mysqli_errno(this.dbh);
        --                         end; else then
        --                                 // dbh is defined, but isn"t a real connection.
        --                                 // Something has gone horribly wrong, let"s try a reconnect.
        --                                 mysql_errno = 2006;
        --                         end;
        --                 end; else then
        --                         if (is_resource(this.dbh)) then
        --                                 mysql_errno = mysql_errno(this.dbh);
        --                         end; else then
        --                                 mysql_errno = 2006;
        --                         end;
        --                 end;
        --         end;

        --         if (empty(this.dbh) || 2006 === mysql_errno) then
        --                 if (this.check_connection()) then
        --                         this._do_query(query);
        --                 end; else then
        --                         this.insert_id = 0;
        --                         return false;
        --                 end;
        --         end;

        --         // If there is an error then take note of it.
        --         if (this.use_mysqli) then
        --                 if (this.dbh instanceof mysqli) then
        --                         this.last_error = mysqli_error(this.dbh);
        --                 end; else then
        --                         this.last_error = __("Unable to retrieve the error message from MySQL");
        --                 end;
        --         end; else then
        --                 if (is_resource(this.dbh)) then
        --                         this.last_error = mysql_error(this.dbh);
        --                 end; else then
        --                         this.last_error = __("Unable to retrieve the error message from MySQL");
        --                 end;
        --         end;

        --         if (this.last_error) then
        --                 // Clear insert_id on a subsequent failed insert.
        --                 if (this.insert_id && preg_match("/^\s*(insert|replace)\s/i", query)) then
        --                         this.insert_id = 0;
        --                 end;

        --                 this.print_error();
        --                 return false;
        --         end;

        --         if (preg_match("/^\s*(create|alter|truncate|drop)\s/i", query)) then
        --                 return_val = this.result;
        --         end; elseif (preg_match("/^\s*(insert|delete|update|replace)\s/i", query)) then
        --                 if (this.use_mysqli) then
        --                         this.rows_affected = mysqli_affected_rows(this.dbh);
        --                 end; else then
        --                         this.rows_affected = mysql_affected_rows(this.dbh);
        --                 end;
        --                 // Take note of the insert_id.
        --                 if (preg_match("/^\s*(insert|replace)\s/i", query)) then
        --                         if (this.use_mysqli) then
        --                                 this.insert_id = mysqli_insert_id(this.dbh);
        --                         end; else then
        --                                 this.insert_id = mysql_insert_id(this.dbh);
        --                         end;
        --                 end;
        --                 // Return number of rows affected.
        --                 return_val = this.rows_affected;
        --         end; else then
        --                 num_rows = 0;
        --                 if (this.use_mysqli && this.result instanceof mysqli_result) then
        --                         while (row = mysqli_fetch_object(this.result)) then
        --                                 this.last_result[ num_rows ] = row;
        --                                 num_rows++;
        --                         end;
        --                 end; elseif (is_resource(this.result)) then
        --                         while (row = mysql_fetch_object(this.result)) then
        --                                 this.last_result[ num_rows ] = row;
        --                                 num_rows++;
        --                         end;
        --                 end;

        --                 // Log and return the number of rows selected.
        --                 this.num_rows = num_rows;
        --                 return_val     = num_rows;
        --         end;

        --         return return_val;
        -- end;

        --
        -- Internal function to perform the mysql_query() call.
        --
        -- @since 3.9.0
        --
        -- @see wpdb::query()
        --
        -- @param string query The query to run.
        --
        -- private function _do_query(query) then
        --         if (defined("SAVEQUERIES") && SAVEQUERIES) then
        --                 this.timer_start();
        --         end;

        --         if (! empty(this.dbh) && this.use_mysqli) then
        --                 this.result = mysqli_query(this.dbh, query);
        --         end; elseif (! empty(this.dbh)) then
        --                 this.result = mysql_query(query, this.dbh);
        --         end;
        --         this.num_queries++;

        --         if (defined("SAVEQUERIES") && SAVEQUERIES) then
        --                 this.log_query(
        --                         query,
        --                         this.timer_stop(),
        --                         this.get_caller(),
        --                         this.time_start,
        --                         array()
        --                );
        --         end;
        -- end;

        --
        -- Logs query data.
        --
        -- @since 5.3.0
        --
        -- @param string query           The query"s SQL.
        -- @param float  query_time      Total time spent on the query, in seconds.
        -- @param string query_callstack Comma-separated list of the calling functions.
        -- @param float  query_start     Unix timestamp of the time at the start of the query.
        -- @param array  query_data      Custom query data.
        --
        -- public function log_query(query, query_time, query_callstack, query_start, query_data) then
        --         --
        --         -- Filters the custom data to log alongside a query.
        --         --
        --         -- Caution should be used when modifying any of this data, it is recommended that any additional
        --         -- information you need to store about a query be added as a new associative array element.
        --         --
        --         -- @since 5.3.0
        --         --
        --         -- @param array  query_data      Custom query data.
        --         -- @param string query           The query"s SQL.
        --         -- @param float  query_time      Total time spent on the query, in seconds.
        --         -- @param string query_callstack Comma-separated list of the calling functions.
        --         -- @param float  query_start     Unix timestamp of the time at the start of the query.
        --         --
        --         query_data = apply_filters("log_query_custom_data", query_data, query, query_time, query_callstack, query_start);

        --         this.queries[] = array(
        --                 query,
        --                 query_time,
        --                 query_callstack,
        --                 query_start,
        --                 query_data,
        --        );
        -- end;

        --
        -- Generates and returns a placeholder escape string for use in queries returned by ::prepare().
        --
        -- @since 4.8.3
        --
        -- @return string String to escape placeholders.
        --
        -- public function placeholder_escape() then
        --         static placeholder;

        --         if (! placeholder) then
        --                 // If ext/hash is not present, compat.php"s hash_hmac() does not support sha256.
        --                 algo = function_exists("hash") ? "sha256" : "sha1";
        --                 // Old WP installs may not have AUTH_SALT defined.
        --                 salt = defined("AUTH_SALT") && AUTH_SALT ? AUTH_SALT : (string) rand();

        --                 placeholder = "then" . hash_hmac(algo, uniqid(salt, true), salt) . "end;";
        --         end;

        --         /*
        --         -- Add the filter to remove the placeholder escaper. Uses priority 0, so that anything
        --         -- else attached to this filter will receive the query with the placeholder string removed.
        --         --
        --         if (false === has_filter("query", array(this, "remove_placeholder_escape"))) then
        --                 add_filter("query", array(this, "remove_placeholder_escape"), 0);
        --         end;

        --         return placeholder;
        -- end;

        --
        -- Adds a placeholder escape string, to escape anything that resembles a printf() placeholder.
        --
        -- @since 4.8.3
        --
        -- @param string query The query to escape.
        -- @return string The query with the placeholder escape string inserted where necessary.
        --
        -- public function add_placeholder_escape(query) then
        --         /*
        --         -- To prevent returning anything that even vaguely resembles a placeholder,
        --         -- we clobber every % we can find.
        --         --
        --         return str_replace("%", this.placeholder_escape(), query);
        -- end;

        --
        -- Removes the placeholder escape strings from a query.
        --
        -- @since 4.8.3
        --
        -- @param string query The query from which the placeholder will be removed.
        -- @return string The query with the placeholder removed.
        --
        -- public function remove_placeholder_escape(query) then
        --         return str_replace(this.placeholder_escape(), "%", query);
        -- end;

   ------------
   -- Insert --
   ------------

   function Insert (This   : in out Wpdb_Class;
                    Table  : String;
                    Data   : Array_Type;
                    Format : String := "") -- null
                    return Natural
   is
   begin
      return This.X_Insert_Replace_Helper (Table, Data, Format, "INSERT");
   end Insert;

        --
        -- Replaces a row in the table.
        --
        -- Examples:
        --
        --     wpdb::replace("table", array("column" => "foo", "field" => "bar"))
        --     wpdb::replace("table", array("column" => "foo", "field" => 1337), array("%s", "%d"))
        --
        -- @since 3.0.0
        --
        -- @see wpdb::prepare()
        -- @see wpdb::field_types
        -- @see wp_set_wpdb_vars()
        --
        -- @param string       table  Table name.
        -- @param array        data   Data to insert (in column => value pairs).
        --                             Both data columns and data values should be "raw" (neither should be SQL escaped).
        --                             Sending a null value will cause the column to be set to NULL - the corresponding
        --                             format is ignored in this case.
        -- @param array|string format Optional. An array of formats to be mapped to each of the value in data.
        --                             If string, that format will be used for all of the values in data.
        --                             A format is one of "%d", "%f", "%s" (integer, float, string).
        --                             If omitted, all values in data will be treated as strings unless otherwise
        --                             specified in wpdb::field_types.
        -- @return int|false The number of rows affected, or false on error.
        --
        -- public function replace(table, data, format = null) then
        --         return this._insert_replace_helper(table, data, format, "REPLACE");
        -- end;

   -----------------------------
   -- X_Insert_Replace_Helper --
   -----------------------------

   function X_Insert_Replace_Helper (This   : in out Wpdb_Class;
                                     Table  : String;
                                     Data   : Array_Type;
                                     Format : String := ""; -- null
                                     Typ    : String := "INSERT")
                                     return Natural
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;

      Data_2 : Array_Type;
   begin
      This.Insert_Id := 0;

      if
        not In_Array (Strtoupper (Typ),
                      To_List (List => (+"REPLACE", +"INSERT")), True)
      then
         return 0; -- false;
      end if;

      Data_2 := This.Process_Fields (Table, Data, Format);
      if Empty_Array = Data_2 then -- false
         return 0; -- false;
      end if;

      declare
         Formats : List_Type;
         Values  : List_Type;
      begin
         for A in Data_2.Iterate loop
            declare
               Value : constant Array_Type := As_Array (Element (A));
            begin
               if Kind_Of (Get (Value, "value")) = Kind_Null then
                  Formats.Append (+"NULL");
                  goto Continue;
               end if;

               Formats.Append (+Get_As_String (Value, "format"));
               Values.Append  (+Get_As_String (Value, "value"));
            end;
            << Continue >>
         end loop;

         declare
            Fields_2 : constant String :=
              "`" & Implode ("`, `", List_Type'(Array_Keys (Data_2))) & "`";

            Formats_2 : constant String := Implode (", ", Formats);

            SQL : constant String :=
              Typ & " INTO `" & Table & "` (" & Fields_2 &
              ") VALUES (" & Formats_2 & ")";
         begin
            This.Check_Current_Query := False;
            return This.Query (This.Prepare (SQL, Values));
         end;
      end;
   end X_Insert_Replace_Helper;

   ------------
   -- Update --
   ------------

   function Update (This         : in out Wpdb_Class;
                    Table        : String;
                    Data         : Array_Type;
                    Where        : Array_Type;
                    Format       : String := ""; -- null
                    Where_Format : String := "") -- null
                    return Natural
   is
      use Php.Strings;
      use Php.Types;

      Data_2  : Array_Type;
      Where_2 : Array_Type;
   begin
      if not Is_Array (Data) or not Is_Array (Where) then
         return 0; -- False;
      end if;

      Data_2 := This.Process_Fields (Table, Data, Format);
      if Empty_Array = Data_2 then -- false
         return 0; -- False;
      end if;

      Where_2 := This.Process_Fields (Table, Where, Where_Format);
      if Empty_Array = Where_2 then -- false
         return 0; -- false;
      end if;

      declare
         Fields     : List_Type; -- = array();
         Conditions : List_Type; -- = array();
         Values     : List_Type; -- = array();
      begin
         for A in Data.Iterate loop
            declare
               Field : constant String := Key (A);
               Value : constant Array_Type := As_Array (Element (A));
            begin
               if Kind_Of (Get (Value, "value")) = Kind_Null then
                  Fields.Append (+"`" & Field & "` = NULL");
                  goto Continue_1;
               end if;

               Fields.Append
                 (+"`" & Field & "` = " & Get_As_String (Value, "format"));

               Values.Append (+Get_As_String (Value, "value"));
            end;
            << Continue_1 >>
         end loop;

         for B in Where_2.Iterate loop
            declare
               Field : constant String := Key (B);
               Value : constant Array_Type := As_Array (Element (B));
            begin
               if Kind_Of (Get (Value, "value")) = Kind_Null then
                  Conditions.Append (+"`" & Field & "` IS NULL");
                  goto Continue_2;
               end if;

               Conditions.Append
                 (+"`" & Field & "` = " & Get_As_String (Value, "format"));

               Values.Append (+Get_As_String (Value, "value"));
            end;
            << Continue_2 >>
         end loop;

         declare
            Fields_2     : constant String := Implode (", ", Fields);
            Conditions_2 : constant String := Implode (" AND ", Conditions);

            SQL : constant String :=
              "UPDATE `" & Table & "` SET " & Fields_2 & " WHERE " & Conditions_2;
         begin
            This.Check_Current_Query := False;
            return This.Query (This.Prepare (SQL, Values));
         end;
      end;
   end Update;

   ------------
   -- Delete --
   ------------

   function Delete (This         : in out Wpdb_Class;
                    Table        : String;
                    Where        : Array_Type;
                    Where_Format : String := "") -- null
                    return Integer
   is
      use Php.Strings;
      use Php.Types;
   begin
      if not Is_Array (Where) then
         return 0; -- False;
      end if;

      declare
         Where_2 : constant Array_Type :=
           This.Process_Fields (Table, Where, Where_Format);
      begin
         if Empty_Array = Where_2 then -- false
            return 0; -- False;
         end if;

         declare
            Conditions : List_Type; -- Array_Type;
            Values     : List_Type; -- Array_Type;
         begin
            for A in Where_2.Iterate loop
               declare
                  Field  : constant String     := Key (A);
                  Value  : constant Array_Type := As_Array (Element (A));
               begin
                  if Kind_Of (Get (Value, "value")) = Kind_Null then
                     Conditions.Append (+"`" & Field & "` IS NULL");
                     goto Continue;
                  end if;
                  Conditions.Append (+"`" & Field & "` = " &
                                     Get_As_String (Value, "format"));
                  Values.Append (+Get_As_String (Value, "value"));
               end;
               << Continue >>
            end loop;

            declare
               Conditions_2 : constant String := Implode (" AND ", Conditions);

               SQL : constant String :=
                 "DELETE FROM `" & Table & "` WHERE " & Conditions_2;
            begin
               This.Check_Current_Query := False;
               return This.Query (This.Prepare (SQL, Values));
            end;
         end;
      end;
   end Delete;

   --------------------
   -- Process_Fields --
   --------------------

   function Process_Fields (This   : in out Wpdb_Class;
                            Table  : String;
                            Data   : Array_Type;
                            Format : String) -- Multi_Type
                            return Array_Type
   is
      use Php.Strings;
      use Inc_Load;

      Data_2 : Array_Type := Data;
   begin
      Data_2 := This.Process_Field_Formats (Data_2, Format);
      if Empty_Array = Data_2 then -- false
         return Empty_Array; -- False;
      end if;

      Data_2 := This.Process_Field_Charsets (Data_2, Table);
      if Empty_Array = Data_2 then -- false
         return Empty_Array; -- False;
      end if;

      Data_2 := This.Process_Field_Lengths (Data_2, Table);
      if Empty_Array = Data_2 then -- false
         return Empty_Array; -- False;
      end if;

      declare
         Converted_Data : constant Array_Type :=
           This.Strip_Invalid_Text (Data_2);
      begin
         if Data_2 /= Converted_Data then
            declare
               Problem_Fields : List_Type;
            begin
               for A in Data_2.Iterate loop
                  declare
                     Field : constant String     := Key (A);
                     Value : constant Multi_Type := Element (A);
                  begin
                     if Value /= Get (Converted_Data, Field) then
                        Problem_Fields.Append (+Field);
                     end if;
                  end;
               end loop;

               Wp_Load_Translations_Early;

               if Problem_Fields.Length in 1 then
                  This.Last_Error := +Sprintf (
                    -- translators: %s: Database field where the error occurred.
                    abs "WordPress database error: Processing the value for the following field failed: %s. The supplied value may be too long or contains invalid data.",
                    To_List (-Problem_Fields.First_Element) -- Reset (Problem_Fields)
                  );
               else
                  This.Last_Error := +Sprintf (
                    -- translators: %s: Database fields where the error occurred.
                    abs "WordPress database error: Processing the values for the following fields failed: %s. The supplied values may be too long or contain invalid data.",
                    To_List (Implode (", ", Problem_Fields))
                  );
               end if;
            end;
            return Empty_Array; -- False;
         end if;
      end;
      return Data_2;
   end Process_Fields;

   ---------------------------
   -- Process_Field_Formats --
   ---------------------------

   function Process_Field_Formats (This   : Wpdb_Class;
                                   Data   : Array_Type;
                                   Format : String)
                                   return Array_Type
   is
      use Php.Lists;

      Data_2           : Array_Type := Data;
      Formats          : List_Type  := To_List (Format); -- (array)
      Original_Formats : constant List_Type  := Formats;
   begin
      for A in Data_2.Iterate loop
         declare
            Field : constant String := Key (A);
            Value : constant String := As_String (Element (A));

            Value_2 : Array_Type := To_Array (List => (
              Build ("value",  Value),
              Build ("format", "%s")
            ));
         begin
            if not Empty (Format) then
               Set (Value_2, "format", From_String (Array_Shift (Formats)));
               if Kind_Of (Get (Value_2, "format")) in Kind_Null then -- not
                  Set (Value_2, "format",
                       From_String (-Original_Formats.First_Element)); -- Reset
               end if;
            elsif Isset (This.Field_Types, Field) then
               Set (Value_2, "format", Get (This.Field_Types, Field));
            end if;

            Set (Data_2, Field, From_Array (Value_2));
         end;
      end loop;

      return Data_2;
   end Process_Field_Formats;

   ----------------------------
   -- Process_Field_Charsets --
   ----------------------------

   function Process_Field_Charsets (This  : Wpdb_Class;
                                    Data  : Array_Type;
                                    Table : String)
                                    return Array_Type
   is
      use Inc_Load;

      Data_2 : Array_Type := Data;
   begin
      for A in Data_2.Iterate loop
         declare
            Field : constant String := Key (A);
            Value : Array_Type      := As_Array (Element (A));
         begin
            if Get_As_String (Value, "format") in "%d" | "%f" then
               --
               -- We can skip this field if we know it isn"t a string.
               -- This checks %d/%f versus ! %s because its sprintf() could take more.
               --
               Set (Value, "charset", From_Boolean (False));
            else
               Set (Value, "charset",
                    From_String (This.Get_Col_Charset (Table, Field)));

               if Is_Wp_Error (Get_As_String (Value, "charset")) then
                  return Empty_Array; -- False;
               end if;
            end if;

            Set (Data_2, Field, From_Array (Value));
         end;
      end loop;

      return Data_2;
   end Process_Field_Charsets;

   ---------------------------
   -- Process_Field_Lengths --
   ---------------------------

   function Process_Field_Lengths (This  : Wpdb_Class;
                                   Data  : Array_Type;
                                   Table : String)
                                   return Array_Type
   is
      use Inc_Load;

      Data_2 : Array_Type := Data;
   begin
      for A in Data_2.Iterate loop
         declare
            Field : constant String := Key (A);
            Value : Array_Type      := As_Array (Element (A));
         begin
            if Get_As_String (Value, "format") in "%d" | "%f" then
               --
               -- We can skip this field if we know it isn"t a string.
               -- This checks %d/%f versus ! %s because its sprintf() could take more.
               --
               Set (Value, "length", From_Boolean (False));
            else
               Set (Value, "length",
                    From_Array (This.Get_Col_Length (Table, Field)));

               if Is_Wp_Error (Get_As_String (Value, "length")) then
                  return Empty_Array; -- false;
               end if;
            end if;

            Set (Data_2, Field, From_Array (Value));
         end;
      end loop;

      return Data_2;
   end Process_Field_Lengths;

        --
        -- Retrieves one variable from the database.
        --
        -- Executes a SQL query and returns the value from the SQL result.
        -- If the SQL result contains more than one column and/or more than one row,
        -- the value in the column and row specified is returned. If query is null,
        -- the value in the specified column and row from the previous SQL result is returned.
        --
        -- @since 0.71
        --
        -- @param string|null query Optional. SQL query. Defaults to null, use the result from the previous query.
        -- @param int         x     Optional. Column of value to return. Indexed from 0.
        -- @param int         y     Optional. Row of value to return. Indexed from 0.
        -- @return string|null Database query result (as string), or null on failure.
        --
        -- public function get_var(query = null, x = 0, y = 0) then
        --         this.func_call = "\db.get_var(\"query\", x, y)";

        --         if (query) then
        --                 if (this.check_current_query && this.check_safe_collation(query)) then
        --                         this.check_current_query = false;
        --                 end;

        --                 this.query(query);
        --         end;

        --         // Extract var out of cached results based on x,y vals.
        --         if (! empty(this.last_result[ y ])) then
        --                 values = array_values(get_object_vars(this.last_result[ y ]));
        --         end;

        --         // If there is a value return it, else return null.
        --         return (isset(values[ x ]) && "" !== values[ x ]) ? values[ x ] : null;
        -- end;

        --
        -- Retrieves one row from the database.
        --
        -- Executes a SQL query and returns the row from the SQL result.
        --
        -- @since 0.71
        --
        -- @param string|null query  SQL query.
        -- @param string      output Optional. The required return type. One of OBJECT, ARRAY_A, or ARRAY_N, which
        --                            correspond to an stdClass object, an associative array, or a numeric array,
        --                            respectively. Default OBJECT.
        -- @param int         y      Optional. Row to return. Indexed from 0.
        -- @return array|object|null|void Database query result in format specified by output or null on failure.
        --
--        public function get_row(query = null, output = OBJECT, y = 0)
   procedure Get_Row (Db      : in out Wpdb_Class;
                      Post    : Inc_Class_Wp_Posts.Wp_Post;
                      Query   : String  := ""; -- = null,
                      Output  : String  := ""; -- = OBJECT,
                      Y       : Natural := 0;
                      Success : out Boolean)
   is
      Unused : constant String :=
        Get_Row (Db      => Db,
                 Post    => Post,
                 Query   => Query,
                 Output  => Output,
                 Y       => Y,
                 Success => Success);
   begin
      null;
   end Get_Row;

   function Get_Row (Db      : in out Wpdb_Class;
                     Post    : Inc_Class_Wp_Posts.Wp_Post;
                     Query   : String  := ""; -- = null,
                     Output  : String  := ""; -- = OBJECT,
                     Y       : Natural := 0;
                     Success : out Boolean)
                     return String
   is
      use Php.Strings;

      Unused_Result : Integer;
   begin
      Success := True;
      Db.Func_Call := +("\db.get_row(\" & Query & ",output,y)"); -- \

      if Query /= "" then
         if
           Db.Check_Current_Query and then
           Db.Check_Safe_Collation (Query)
         then
            Db.Check_Current_Query := False;
         end if;

         Unused_Result := Db.Query (Query);
      else
         Success := False;
         return ""; --  null;
      end if;

      if not Isset (Db.Last_Result (Y)) then
         Success := False;
         return ""; --  null;
      end if;

      if "OBJECT" = Output then
         return (if Db.Last_Result (Y) /= ""
                 then Db.Last_Result (Y) else ""); -- null
      -- elsif "ARRAY_A" = Output then
      --    return (if Db.Last_Result (Y) /= ""
      --            then Get_Object_Vars (Db.Last_Result (Y)) else "");
      -- elsif "ARRAY_N" = Output then
      --    return (if Db.Last_Result (Y) /= ""
      --            then Array_Values (Get_Object_Vars (Db.Last_Result (Y))) else "");
      elsif "OBJECT" = Strtoupper (Output) then
         -- Back compat for OBJECT being previously case-insensitive.
         return (if Db.Last_Result (Y) /= ""
                 then Db.Last_Result (Y) else "");
      else
         Db.Print_Error (" db.get_row(string query, output type, int offset) -- Output type must be one of: OBJECT, ARRAY_A, ARRAY_N");
      end if;
      return "";
   end Get_Row;

        --
        -- Retrieves one column from the database.
        --
        -- Executes a SQL query and returns the column from the SQL result.
        -- If the SQL result contains more than one column, the column specified is returned.
        -- If query is null, the specified column from the previous SQL result is returned.
        --
        -- @since 0.71
        --
        -- @param string|null query Optional. SQL query. Defaults to previous query.
        -- @param int         x     Optional. Column to return. Indexed from 0.
        -- @return array Database query result. Array indexed from 0 by SQL result row number.
        --
        -- public function get_col(query = null, x = 0) then
        --         if (query) then
        --                 if (this.check_current_query && this.check_safe_collation(query)) then
        --                         this.check_current_query = false;
        --                 end;

        --                 this.query(query);
        --         end;

        --         new_array = array();
        --         // Extract the column values.
        --         if (this.last_result) then
        --                 for (i = 0, j = count(this.last_result); i < j; i++) then
        --                         new_array[ i ] = this.get_var(null, x, i);
        --                 end;
        --         end;
        --         return new_array;
        -- end;

        --
        -- Retrieves an entire SQL result set from the database (i.e., many rows).
        --
        -- Executes a SQL query and returns the entire SQL result.
        --
        -- @since 0.71
        --
        -- @param string query  SQL query.
        -- @param string output Optional. Any of ARRAY_A | ARRAY_N | OBJECT | OBJECT_K constants.
        --                       With one of the first three, return an array of rows indexed
        --                       from 0 by SQL result row number. Each row is an associative array
        --                       (column => value, ...), a numerically indexed array (0 => value, ...),
        --                       or an object (.column = value), respectively. With OBJECT_K,
        --                       return an associative array of row objects keyed by the value
        --                       of each row"s first column"s value. Duplicate keys are discarded.
        -- @return array|object|null Database query results.
        --
        -- public function get_results(query = null, output = OBJECT) then
        --         this.func_call = "\db.get_results(\"query\", output)";

        --         if (query) then
        --                 if (this.check_current_query && this.check_safe_collation(query)) then
        --                         this.check_current_query = false;
        --                 end;

        --                 this.query(query);
        --         end; else then
        --                 return null;
        --         end;

        --         new_array = array();
        --         if (OBJECT === output) then
        --                 // Return an integer-keyed array of row objects.
        --                 return this.last_result;
        --         end; elseif (OBJECT_K === output) then
        --                 // Return an array of row objects with keys from column 1.
        --                 // (Duplicates are discarded.)
        --                 if (this.last_result) then
        --                         foreach (this.last_result as row) then
        --                                 var_by_ref = get_object_vars(row);
        --                                 key        = array_shift(var_by_ref);
        --                                 if (! isset(new_array[ key ])) then
        --                                         new_array[ key ] = row;
        --                                 end;
        --                         end;
        --                 end;
        --                 return new_array;
        --         end; elseif (ARRAY_A === output || ARRAY_N === output) then
        --                 // Return an integer-keyed array of...
        --                 if (this.last_result) then
        --                         foreach ((array) this.last_result as row) then
        --                                 if (ARRAY_N === output) then
        --                                         // ...integer-keyed row arrays.
        --                                         new_array[] = array_values(get_object_vars(row));
        --                                 end; else then
        --                                         // ...column name-keyed row arrays.
        --                                         new_array[] = get_object_vars(row);
        --                                 end;
        --                         end;
        --                 end;
        --                 return new_array;
        --         end; elseif (strtoupper(output) === OBJECT) then
        --                 // Back compat for OBJECT being previously case-insensitive.
        --                 return this.last_result;
        --         end;
        --         return null;
        -- end;

        --
        -- Retrieves the character set for the given table.
        --
        -- @since 4.2.0
        --
        -- @param string table Table name.
        -- @return string|WP_Error Table character set, WP_Error object if it couldn"t be found.
        --
        -- protected function get_table_charset(table) then
        --         tablekey = strtolower(table);

        --         --
        --         -- Filters the table charset value before the DB is checked.
        --         --
        --         -- Returning a non-null value from the filter will effectively short-circuit
        --         -- checking the DB for the charset, returning that value instead.
        --         --
        --         -- @since 4.2.0
        --         --
        --         -- @param string|WP_Error|null charset The character set to use, WP_Error object
        --         --                                      if it couldn"t be found. Default null.
        --         -- @param string               table   The name of the table being checked.
        --         --
        --         charset = apply_filters("pre_get_table_charset", null, table);
        --         if (null !== charset) then
        --                 return charset;
        --         end;

        --         if (isset(this.table_charset[ tablekey ])) then
        --                 return this.table_charset[ tablekey ];
        --         end;

        --         charsets = array();
        --         columns  = array();

        --         table_parts = explode(".", table);
        --         table       = "`" . implode("`.`", table_parts) . "`";
        --         results     = this.get_results("SHOW FULL COLUMNS FROM table");
        --         if (! results) then
        --                 return new WP_Error("wpdb_get_table_charset_failure", __("Could not retrieve table charset."));
        --         end;

        --         foreach (results as column) then
        --                 columns[ strtolower(column.Field) ] = column;
        --         end;

        --         this.col_meta[ tablekey ] = columns;

        --         foreach (columns as column) then
        --                 if (! empty(column.Collation)) then
        --                         list(charset) = explode("_", column.Collation);

        --                         // If the current connection can"t support utf8mb4 characters, let"s only send 3-byte utf8 characters.
        --                         if ("utf8mb4" === charset && ! this.has_cap("utf8mb4")) then
        --                                 charset = "utf8";
        --                         end;

        --                         charsets[ strtolower(charset) ] = true;
        --                 end;

        --                 list(type) = explode("(", column.Type);

        --                 // A binary/blob means the whole query gets treated like this.
        --                 if (in_array(strtoupper(type), array("BINARY", "VARBINARY", "TINYBLOB", "MEDIUMBLOB", "BLOB", "LONGBLOB"), true)) then
        --                         this.table_charset[ tablekey ] = "binary";
        --                         return "binary";
        --                 end;
        --         end;

        --         // utf8mb3 is an alias for utf8.
        --         if (isset(charsets["utf8mb3"])) then
        --                 charsets["utf8"] = true;
        --                 unset(charsets["utf8mb3"]);
        --         end;

        --         // Check if we have more than one charset in play.
        --         count = count(charsets);
        --         if (1 === count) then
        --                 charset = key(charsets);
        --         end; elseif (0 === count) then
        --                 // No charsets, assume this table can store whatever.
        --                 charset = false;
        --         end; else then
        --                 // More than one charset. Remove latin1 if present and recalculate.
        --                 unset(charsets["latin1"]);
        --                 count = count(charsets);
        --                 if (1 === count) then
        --                         // Only one charset (besides latin1).
        --                         charset = key(charsets);
        --                 end; elseif (2 === count && isset(charsets["utf8"], charsets["utf8mb4"])) then
        --                         // Two charsets, but they"re utf8 and utf8mb4, use utf8.
        --                         charset = "utf8";
        --                 end; else then
        --                         // Two mixed character sets. ascii.
        --                         charset = "ascii";
        --                 end;
        --         end;

        --         this.table_charset[ tablekey ] = charset;
        --         return charset;
        -- end;

   ---------------------
   -- Get_Col_Charset --
   ---------------------

   function Get_Col_Charset (This   : Wpdb_Class;
                             Table  : String;
                             Column : String)
                             return String
   is
      use Php.Strings;
      use Inc_Load;
      use Inc_Plugins;

      Tablekey  : constant String := Strtolower (Table);
      Columnkey : constant String := Strtolower (Column);

      --
      -- Filters the column charset value before the DB is checked.
      --
      -- Passing a non-null value to the filter will short-circuit
      -- checking the DB for the charset, returning that value instead.
      --
      -- @since 4.2.0
      --
      -- @param string|null charset The character set to use. Default null.
      -- @param string      table   The name of the table being checked.
      -- @param string      column  The name of the column being checked.
      --
      Charset : constant String :=
        Apply_Filters ("pre_get_col_charset", "", Table, Column);     -- null
   begin
      if "" /= Charset then
         return Charset;
      end if;

      -- Skip this entirely if this isn't a MySQL database.
      if not This.Is_MySQL then
--    if Empty (This.Is_MySQL) then
         return ""; -- False;
      end if;

      if Empty (This.Table_Charset, Tablekey) then
         -- This primes column information for us.
         declare
            Table_Charset : constant String := This.Get_Table_Charset (Table);
         begin
            if Is_Wp_Error (Table_Charset) then
               return Table_Charset;
            end if;
         end;
      end if;

      -- If still no column information, return the table charset.
      if Empty (This.Col_Meta, Tablekey) then
         return Get_As_String (This.Table_Charset, Tablekey);
      end if;

      -- If this column Doesn't exist, return the table charset.
      if
        Empty (As_String (Get (Ref_2 (This.Col_Meta,
                                      Key_1 => Tablekey,
                                      Key_2 => Columnkey))))
      then
         return Get_As_String (This.Table_Charset, Tablekey);
      end if;

      -- -- Return false when It's not a string column.
      -- if
      --   Empty (Ref_2 (This.Col_Meta, Key_1 => Tablekey, Key_2 => Columnkey).Collation)
      -- then
      --    return ""; -- false;
      -- end if;

      declare
         L : List_Type; --  :=
--           Explode ("_", As_String (Ref_2 (This.Col_Meta, Tablekey, Columnkey).Collation));
         Charset : constant String := -L.First_Element;
      begin
         return Charset;
      end;
   end Get_Col_Charset;

   --------------------
   -- Get_Col_Length --
   --------------------

   function Get_Col_Length (This   : Wpdb_Class;
                            Table  : String;
                            Column : String)
                            return Array_Type
   is
      use Php.Strings;
      use Inc_Load;

      Tablekey  : constant String := Strtolower (Table);
      Columnkey : constant String := Strtolower (Column);
   begin
      -- Skip this entirely if this isn't a MySQL database.
      if not This.Is_MySQL then
--    if Empty (This.Is_MySQL) then
         return Empty_Array; -- False;
      end if;

      if Empty (Get_As_String (This.Col_Meta, Tablekey)) then
         -- This primes column information for us.
         declare
            Table_Charset : constant String := This.Get_Table_Charset (Table);
         begin
            if Is_Wp_Error (Table_Charset) then
               return Empty_Array; -- Table_Charset;
            end if;
         end;
      end if;

      if Empty (As_String (Get (Ref_2 (This.Col_Meta, Tablekey, Columnkey)))) then
         return Empty_Array; -- false;
      end if;

      declare
         Typeinfo : List_Type; --  :=
--           Explode ("(", As_String (Get (Ref_2 (This.Col_Meta,
--                                                Key_1 => Tablekey,
--                                                Key_2 => Columnkey))).Typ);
         Typ : constant String := Strtolower (-Typeinfo.First_Element); -- [0]
         Length : Natural;
      begin
         if not Empty (-Typeinfo (2)) then -- [1]
            Length := Natural'Value (Trim (-Typeinfo (2), ")")); -- [1]
         else
            Length := 0; -- False;
         end if;

         if Typ in "char" | "varchar" then
            return To_Array (List => (
              Build ("type",   "char"),
              Build ("length", Length) -- (int)
            ));

         elsif Typ in "binary" | "varbinary" then
            return To_Array (List => (
              Build ("type",   "byte"),
              Build ("length", Length) -- (int)
            ));

         elsif Typ in "tinyblob" | "tinytext" then
            return To_Array (List => (
              Build ("type",   "byte"),
              Build ("length", 255)        -- 2^8 - 1
            ));

         elsif Typ in "blob" | "text" then
            return To_Array (List => (
              Build ("type",   "byte"),
              Build ("length", 65535)      -- 2^16 - 1
            ));

         elsif Typ in "mediumblob" | "mediumtext" then
            return To_Array (List => (
              Build ("type",   "byte"),
              Build ("length", 16777215)   -- 2^24 - 1
            ));

         elsif Typ in "longblob" | "longtext" then
            return To_Array (List => (
              Build ("type",   "byte"),
              Build ("length", Integer'Last) -- 4294967295) -- 2^32 - 1
            ));

         else
            return Empty_Array; -- false;
         end if;
      end;
   end Get_Col_Length;

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
        --         if (function_exists("mb_check_encoding")) then
        --                 if (mb_check_encoding(string, "ASCII")) then
        --                         return true;
        --                 end;
        --         end; elseif (! preg_match("/[^\x00-\x7F]/", string)) then
        --                 return true;
        --         end;

        --         return false;
        -- end;

        --
        -- Checks if the query is accessing a collation considered safe on the current version of MySQL.
        --
        -- @since 4.2.0
        --
        -- @param string query The query to check.
        -- @return bool True if the collation is safe, false if it isn"t.
        --
        -- protected function check_safe_collation(query) then

   function Check_Safe_Collation (This  : in out Wpdb_Class;
                                  Query : String)
                                  return Boolean
   is
      use Php.Preg;
      use Php.Strings;

      Query_2        : constant String := Ltrim (Query, "\r\n\t (");
      Unused_Matches : List_Type;
   begin
      if This.Checking_Collation then
         return True;
      end if;

      -- We don"t need to check the collation for queries that don"t read data.
      if
        0 /= Preg_Match ("/^(?:SHOW|DESCRIBE|DESC|EXPLAIN|CREATE)\s/i",
                         Query_2, Unused_Matches)
      then
         return True;
      end if;

      -- All-ASCII queries don"t need extra checking.
      if This.Check_ASCII (Query_2) then
         return True;
      end if;

      declare
         Table : String := This.Get_Table_From_Query (Query_2);
      begin
         if Table = "" then  -- not Table then
            return False;
         end if;

         This.Checking_Collation := True;
         declare
            Collation : constant String := This.Get_Table_Charset (Table);
         begin
            This.Checking_Collation := False;

            -- Tables with no collation, or latin1 only, don"t need extra checking.
            if "" = Collation or else "latin1" = Collation then -- false =
               return True;
            end if;
         end;

         Table := Strtolower (Table);
         if "" = As_String (Get (This.Col_Meta, Table)) then
            return False;
         end if;

         -- If any of the columns don"t have one of these collations, it needs
         -- more sanity checking.
         declare
            Safe_Collations : List_Type := To_List (List =>
                       (+"utf8_bin",
                        +"utf8_general_ci",
                        +"utf8mb3_bin",
                        +"utf8mb3_general_ci",
                        +"utf8mb4_bin",
                        +"utf8mb4_general_ci")
            );
         begin
            null;
            -- for Col of Value_Of (This.Col_Meta, Key => Table) loop
            --    if Empty (Get (Col, Collation)) then
            --       goto Continue;
            --    end if;

            --    if not In_Array (Col.Collation, Safe_Collations, True) then
            --       return False;
            --    end if;
            --    << Continue >>
            -- end loop;
         end;
      end;
      return True;
   end Check_Safe_Collation;

   ------------------------
   -- Strip_Invalid_Text --
   ------------------------

   function Strip_Invalid_Text (This : in out Wpdb_Class;
                                Data : Array_Type)
                                return Array_Type
   is
      use Php.Arrays;
      use Php.Multibyte;
      use Php.Preg;
      use Php.Strings;
      use Php.Types;
      use Inc_Functions;

      Data_2          : Array_Type := Data;
      DB_Check_String : Boolean    := False;
   begin
      for B in Data_2.Iterate loop -- &value
         declare
            Value   : Array_Type := As_Array (Element (B));
            Charset : constant String := Get_As_String (Value, "charset");
            Length  : Natural;
            Truncate_By_Byte_Length : Boolean;
         begin
            if Kind_Of (Get (Value, "length")) = Kind_Array then
               Length := As_Integer (Get (Ref_2 (Value,
                                                 Key_1 => "length",
                                                 Key_2 => "length")));
               Truncate_By_Byte_Length :=
                 "byte" = As_String (Get (Ref_2 (Value,
                                                 Key_1 => "length",
                                                 Key_2 => "type")));
            else
               Length := 0; -- False;
               -- Since we have no length, we'll never truncate. Initialize the
               -- variable to false. True would take us through an unnecessary
               -- (for this case) codepath below.
               Truncate_By_Byte_Length := False;
            end if;

            -- There's no charset to work with.
            if "" = Charset then -- false
               goto Continue;
            end if;

            -- Column isn't a string.
            if not Is_String (Get_As_String (Value, "value")) then
               goto Continue;
            end if;

            declare
               Needs_Validation : Boolean := True;
            begin
               if
                 -- latin1 can store any byte sequence.
                 "latin1" = Charset or else
                 -- ASCII is always OK.
                 (not Isset (Value, "ascii") and then
                  This.Check_ASCII (Get_As_String (Value, "value")))
               then
                  Truncate_By_Byte_Length := True;
                  Needs_Validation        := False;
               end if;

               if Truncate_By_Byte_Length then
                  MB_String_Binary_Safe_Encoding;
                  if
                    0 /= Length and then -- false
                    Strlen (Get_As_String (Value, "value")) > Length
                  then
                     Set (Value, "value",
                          From_String (
                            Substr (Get_As_String (Value, "value"), 0, Length)));
                  end if;
                  Reset_MB_String_Encoding;

                  if not Needs_Validation then
                     goto Continue;
                  end if;
               end if;
            end;

            -- utf8 can be handled by regex, which is a bunch faster than a DB lookup.
            if
              Charset in "utf8" | "utf8mb3" | "utf8mb4" -- and then
--            Function_Exists ("mb_strlen")
            then
               declare
                  Regex : Unbounded_String := -- +"/
                   +"(" &
                    "        (?: [\x00-\x7F]                  # single-byte sequences   0xxxxxxx " &
                    "        |   [\xC2-\xDF][\x80-\xBF]       # double-byte sequences   110xxxxx 10xxxxxx " &
                    "        |   \xE0[\xA0-\xBF][\x80-\xBF]   # triple-byte sequences   1110xxxx 10xxxxxx-- 2 " &
                    "        |   [\xE1-\xEC][\x80-\xBF]{2} "  &
                    "        |   \xED[\x80-\x9F][\x80-\xBF] " &
                    "        |   [\xEE-\xEF][\x80-\xBF]{2}";
               begin
                  if "utf8mb4" = Charset then
                     Append (Regex,
                       "        |    \xF0[\x90-\xBF][\x80-\xBF]{2} # four-byte sequences   11110xxx 10xxxxxx-- 3 " &
                       "        |    [\xF1-\xF3][\x80-\xBF]{3} " &
                       "        |    \xF4[\x80-\x8F][\x80-\xBF]{2} ");
                  end if;

                  Append (Regex,
                    "){1,40}                          # ...one or more times " &
                    ") " &
                    " | .                                  # anything else " &
                    "/x");
                  Set (Value, "value", From_String (
                       Preg_Replace (-Regex, "1", Get_As_String (Value, "value"))));
               end;

               if
                 0 /= Length and then -- false
                 MB_Strlen (Get_As_String (Value, "value"), "UTF-8") > Length
               then
                  Set (Value, "value", From_String (
                       MB_Substr (Get_As_String (Value, "value"),
                                  0, Length, "UTF-8")));
               end if;
               goto Continue;
            end if;

            -- We couldn't use any local conversions, send it to the DB.
            Set (Value, "db", From_Boolean (True));
            DB_Check_String := True;
         end;
         << Continue >>
      end loop;
--    Unset (Value); -- Remove by reference.

      if DB_Check_String then
         declare
            Queries : Array_Type;
         begin
            for A in Data_2.Iterate loop
               declare
                  Col   : constant String     := Key (A);
                  Value : constant Array_Type := As_Array (Element (A));
               begin
                  if Kind_Of (Get (Value, "db")) not in Kind_Null then
--                if not Empty (Value, "db") then
                     declare
                        Charset            : Unbounded_String;
                        Connection_Charset : Unbounded_String;
                     begin
                        -- We're going to need to truncate by characters or bytes,
                        -- depending on the length value we have.
                        if
                          Isset_2 (Value, "length", "type") and then
                          "byte" = As_String (Get (Ref_2 (Value,
                                                          Key_1 => "length",
                                                          Key_2 => "type")))
                        then
                           -- Using binary causes LEFT() to truncate by bytes.
                           Charset := +"binary";
                        else
                           Charset := +Get_As_String (Value, "charset");
                        end if;

                        if This.Charset /= "" then
                           Connection_Charset := This.Charset;
                        else
                           if This.Use_Mysqli then
                              Connection_Charset := +"XXX-998";
--                              Mysqli_Character_Set_Name (This.Dbh);
                           else
                              Connection_Charset := +"XXX-999";
--                              Mysql_Client_Encoding;
                           end if;
                        end if;

                        if Kind_Of (Get (Value, "length")) = Kind_Array then
                           declare
                              Length : constant String :=
                                Sprintf ("%.0f",
                                         To_List (As_String (Get (Ref_2 (Value,
                                                                Key_1 => "length",
                                                                Key_2 => "length")))));
                           begin
                              Set (Queries, Col, From_String (
                                   This.Prepare ("CONVERT(LEFT(CONVERT(%s USING " &
                                                 (-Charset) & "), " & Length &
                                                 ") USING " & (-Connection_Charset) &
                                                 ")",
                                                 Get_As_String (Value, "value"))));
                           end;
                        elsif "binary" /= Charset then
                           -- If we don't have a length, there's no need to convert
                           -- binary - it will always return the same result.
                           Set (Queries, Col, From_String (
                                This.Prepare ("CONVERT(CONVERT(%s USING " &
                                              (-Charset) & ") USING " &
                                              (-Connection_Charset) & ")",
                                              Get_As_String (Value, "value"))));
                        end if;
                     end;
                     Delete (Ref_2 (Data_2, Key_1 => Col, Key_2 => "db"));
                  end if;
               end;
            end loop;

            declare
               SQL : List_Type; -- = array();
            begin
               for A in Queries.Iterate loop
                  declare
--                   Column : constant String := Key (A);
                     Query  : constant String := As_String (Element (A));
                  begin
                     if Query = "" then -- not
                        goto Continue_2;
                     end if;

                     SQL.Append (+Query & " AS x_column");
                  end;
                  << Continue_2 >>
               end loop;

               This.Check_Current_Query := False;
               declare
                  Success : Boolean;

                  Row : constant Array_Type :=
                    This.Get_Row ("SELECT " & Implode (", ", SQL), "ARRAY_A",
                                  Success => Success);
               begin
                  if Row = Empty_Array then -- not
                     raise Constraint_Error with "wpdb_strip_invalid_text_failure";
--                   return Wp_Error ("wpdb_strip_invalid_text_failure",
--                                    abs "Could not strip invalid text.");
                  end if;

                  for E in Array_Keys (Data_2).Iterate loop
                     declare
                        Column : constant String := Key (E);
                     begin
                        if Isset (Row, "x_column") then
                           Set_2 (Data_2,
                                  Key_1 => Column,
                                  Key_2 => "value",
                                  Value => From_String (
                                             Get_As_String (Row, "x_column")));
                        end if;
                     end;
                  end loop;
               end;
            end;
         end;
      end if;

      return Data_2;
   end Strip_Invalid_Text;

        --
        -- Strips any invalid characters from the query.
        --
        -- @since 4.2.0
        --
        -- @param string query Query to convert.
        -- @return string|WP_Error The converted query, or a WP_Error object if the conversion fails.
        --
        -- protected function strip_invalid_text_from_query(query) then
        --         -- We don"t need to check the collation for queries that don"t read data.
        --         trimmed_query = ltrim(query, "\r\n\t (");
        --         if (preg_match("/^(?:SHOW|DESCRIBE|DESC|EXPLAIN|CREATE)\s/i", trimmed_query)) then
        --                 return query;
        --         end;

        --         table = this.get_table_from_query(query);
        --         if (table) then
        --                 charset = this.get_table_charset(table);
        --                 if (is_wp_error(charset)) then
        --                         return charset;
        --                 end;

        --                 -- We can"t reliably strip text from tables containing binary/blob columns.
        --                 if ("binary" === charset) then
        --                         return query;
        --                 end;
        --         end; else then
        --                 charset = this.charset;
        --         end;

        --         data = array(
        --                 "value"   => query,
        --                 "charset" => charset,
        --                 "ascii"   => false,
        --                 "length"  => false,
        --        );

        --         data = this.strip_invalid_text(array(data));
        --         if (is_wp_error(data)) then
        --                 return data;
        --         end;

        --         return data[0]["value"];
        -- end;

        --
        -- Strips any invalid characters from the string for a given table and column.
        --
        -- @since 4.2.0
        --
        -- @param string table  Table name.
        -- @param string column Column name.
        -- @param string value  The text to check.
        -- @return string|WP_Error The converted string, or a WP_Error object if the conversion fails.
        --
        -- public function strip_invalid_text_for_column(table, column, value) then
        --         if (! is_string(value)) then
        --                 return value;
        --         end;

        --         charset = this.get_col_charset(table, column);
        --         if (! charset) then
        --                 -- Not a string column.
        --                 return value;
        --         end; elseif (is_wp_error(charset)) then
        --                 -- Bail on real errors.
        --                 return charset;
        --         end;

        --         data = array(
        --                 column => array(
        --                         "value"   => value,
        --                         "charset" => charset,
        --                         "length"  => this.get_col_length(table, column),
        --                ),
        --        );

        --         data = this.strip_invalid_text(data);
        --         if (is_wp_error(data)) then
        --                 return data;
        --         end;

        --         return data[ column ]["value"];
        -- end;

        --
        -- Finds the first table name referenced in a query.
        --
        -- @since 4.2.0
        --
        -- @param string query The query to search.
        -- @return string|false The table name found, or false if a table couldn"t be found.
        --
        -- protected function get_table_from_query(query) then
        --         -- Remove characters that can legally trail the table name.
        --         query = rtrim(query, ";/-#");

        --         -- Allow (select...) union [...] style queries. Use the first query"s table name.
        --         query = ltrim(query, "\r\n\t (");

        --         -- Strip everything between parentheses except nested selects.
        --         query = preg_replace("/\((?!\s*select)[^(]*?\)/is", "()", query);

        --         -- Quickly match most common queries.
        --         if (preg_match(
        --                 "/^\s*(?:"
        --                         . "SELECT.*?\s+FROM"
        --                         . "|INSERT(?:\s+LOW_PRIORITY|\s+DELAYED|\s+HIGH_PRIORITY)?(?:\s+IGNORE)?(?:\s+INTO)?"
        --                         . "|REPLACE(?:\s+LOW_PRIORITY|\s+DELAYED)?(?:\s+INTO)?"
        --                         . "|UPDATE(?:\s+LOW_PRIORITY)?(?:\s+IGNORE)?"
        --                         . "|DELETE(?:\s+LOW_PRIORITY|\s+QUICK|\s+IGNORE)*(?:.+?FROM)?"
        --                 . ")\s+((?:[0-9a-zA-Z_.`-]|[\xC2-\xDF][\x80-\xBF])+)/is",
        --                 query,
        --                 maybe
        --        )) then
        --                 return str_replace("`", "", maybe[1]);
        --         end;

        --         -- SHOW TABLE STATUS and SHOW TABLES WHERE Name = "wp_posts"
        --         if (preg_match("/^\s*SHOW\s+(?:TABLE\s+STATUS|(?:FULL\s+)?TABLES).+WHERE\s+Name\s*=\s*("|\")((?:[0-9a-zA-Z_.-]|[\xC2-\xDF][\x80-\xBF])+)\\1/is", query, maybe)) then
        --                 return maybe[2];
        --         end;

        --         /*
        --         -- SHOW TABLE STATUS LIKE and SHOW TABLES LIKE "wp\_123\_%"
        --         -- This quoted LIKE operand seldom holds a full table name.
        --         -- It is usually a pattern for matching a prefix so we just
        --         -- strip the trailing % and unescape the _ to get "wp_123_"
        --         -- which drop-ins can use for routing these SQL statements.
        --         --
        --         if (preg_match("/^\s*SHOW\s+(?:TABLE\s+STATUS|(?:FULL\s+)?TABLES)\s+(?:WHERE\s+Name\s+)?LIKE\s*("|\")((?:[\\\\0-9a-zA-Z_.-]|[\xC2-\xDF][\x80-\xBF])+)%?\\1/is", query, maybe)) then
        --                 return str_replace("\\_", "_", maybe[2]);
        --         end;

        --         -- Big pattern for the rest of the table-related queries.
        --         if (preg_match(
        --                 "/^\s*(?:"
        --                         . "(?:EXPLAIN\s+(?:EXTENDED\s+)?)?SELECT.*?\s+FROM"
        --                         . "|DESCRIBE|DESC|EXPLAIN|HANDLER"
        --                         . "|(?:LOCK|UNLOCK)\s+TABLE(?:S)?"
        --                         . "|(?:RENAME|OPTIMIZE|BACKUP|RESTORE|CHECK|CHECKSUM|ANALYZE|REPAIR).*\s+TABLE"
        --                         . "|TRUNCATE(?:\s+TABLE)?"
        --                         . "|CREATE(?:\s+TEMPORARY)?\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?"
        --                         . "|ALTER(?:\s+IGNORE)?\s+TABLE"
        --                         . "|DROP\s+TABLE(?:\s+IF\s+EXISTS)?"
        --                         . "|CREATE(?:\s+\w+)?\s+INDEX.*\s+ON"
        --                         . "|DROP\s+INDEX.*\s+ON"
        --                         . "|LOAD\s+DATA.*INFILE.*INTO\s+TABLE"
        --                         . "|(?:GRANT|REVOKE).*ON\s+TABLE"
        --                         . "|SHOW\s+(?:.*FROM|.*TABLE)"
        --                 . ")\s+\(*\s*((?:[0-9a-zA-Z_.`-]|[\xC2-\xDF][\x80-\xBF])+)\s*\)*/is",
        --                 query,
        --                 maybe
        --        )) then
        --                 return str_replace("`", "", maybe[1]);
        --         end;

        --         return false;
        -- end;

        --
        -- Loads the column metadata from the last query.
        --
        -- @since 3.5.0
        --
        -- protected function load_col_info() then
        --         if (this.col_info) then
        --                 return;
        --         end;

        --         if (this.use_mysqli) then
        --                 num_fields = mysqli_num_fields(this.result);
        --                 for (i = 0; i < num_fields; i++) then
        --                         this.col_info[ i ] = mysqli_fetch_field(this.result);
        --                 end;
        --         end; else then
        --                 num_fields = mysql_num_fields(this.result);
        --                 for (i = 0; i < num_fields; i++) then
        --                         this.col_info[ i ] = mysql_fetch_field(this.result, i);
        --                 end;
        --         end;
        -- end;

        --
        -- Retrieves column metadata from the last query.
        --
        -- @since 0.71
        --
        -- @param string info_type  Optional. Possible values include "name", "table", "def", "max_length",
        --                           "not_null", "primary_key", "multiple_key", "unique_key", "numeric",
        --                           "blob", "type", "unsigned", "zerofill". Default "name".
        -- @param int    col_offset Optional. 0: col name. 1: which table the col"s in. 2: col"s max length.
        --                           3: if the col is numeric. 4: col"s type. Default -1.
        -- @return mixed Column results.
        --
        -- public function get_col_info(info_type = "name", col_offset = -1) then
        --         this.load_col_info();

        --         if (this.col_info) then
        --                 if (-1 === col_offset) then
        --                         i         = 0;
        --                         new_array = array();
        --                         foreach ((array) this.col_info as col) then
        --                                 new_array[ i ] = col.theninfo_typeend;;
        --                                 i++;
        --                         end;
        --                         return new_array;
        --                 end; else then
        --                         return this.col_info[ col_offset ].theninfo_typeend;;
        --                 end;
        --         end;
        -- end;

        --
        -- Starts the timer, for debugging purposes.
        --
        -- @since 1.5.0
        --
        -- @return true
        --
        -- public function timer_start() then
        --         this.time_start = microtime(true);
        --         return true;
        -- end;

        --
        -- Stops the debugging timer.
        --
        -- @since 1.5.0
        --
        -- @return float Total time spent on the query, in seconds.
        --
        -- public function timer_stop() then
        --         return (microtime(true) - this.time_start);
        -- end;

        --
        -- Wraps errors in a nice header and footer and dies.
        --
        -- Will not die if wpdb::show_errors is false.
        --
        -- @since 1.5.0
        --
        -- @param string message    The error message.
        -- @param string error_code Optional. A computer-readable string to identify the error.
        --                           Default "500".
        -- @return void|false Void if the showing of errors is enabled, false if disabled.
        --
        -- public function bail(message, error_code = "500") then
        --         if (this.show_errors) then
        --                 error = "";

        --                 if (this.use_mysqli) then
        --                         if (this.dbh instanceof mysqli) then
        --                                 error = mysqli_error(this.dbh);
        --                         end; elseif (mysqli_connect_errno()) then
        --                                 error = mysqli_connect_error();
        --                         end;
        --                 end; else then
        --                         if (is_resource(this.dbh)) then
        --                                 error = mysql_error(this.dbh);
        --                         end; else then
        --                                 error = mysql_error();
        --                         end;
        --                 end;

        --                 if (error) then
        --                         message = "<p><code>" . error . "</code></p>\n" . message;
        --                 end;

        --                 wp_die(message);
        --         end; else then
        --                 if (class_exists("WP_Error", false)) then
        --                         this.error = new WP_Error(error_code, message);
        --                 end; else then
        --                         this.error = message;
        --                 end;

        --                 return false;
        --         end;
        -- end;

        --
        -- Closes the current database connection.
        --
        -- @since 4.5.0
        --
        -- @return bool True if the connection was successfully closed,
        --              false if it wasn"t, or if the connection doesn"t exist.
        --
        -- public function close() then
        --         if (! this.dbh) then
        --                 return false;
        --         end;

        --         if (this.use_mysqli) then
        --                 closed = mysqli_close(this.dbh);
        --         end; else then
        --                 closed = mysql_close(this.dbh);
        --         end;

        --         if (closed) then
        --                 this.dbh           = null;
        --                 this.ready         = false;
        --                 this.has_connected = false;
        --         end;

        --         return closed;
        -- end;

        --
        -- Determines whether MySQL database is at least the required minimum version.
        --
        -- @since 2.5.0
        --
        -- @global string wp_version             The WordPress version string.
        -- @global string required_mysql_version The required MySQL version string.
        -- @return void|WP_Error
        --
        -- public function check_database_version() then
        --         global wp_version, required_mysql_version;
        --         -- Make sure the server has the required MySQL version.
        --         if (version_compare(this.db_version(), required_mysql_version, "<")) then
        --                 /* translators: 1: WordPress version number, 2: Minimum required MySQL version number.--
        --                 return new WP_Error("database_version", sprintf(__("<strong>Error:</strong> WordPress %1s requires MySQL %2s or higher"), wp_version, required_mysql_version));
        --         end;
        -- end;

        --
        -- Determines whether the database supports collation.
        --
        -- Called when WordPress is generating the table scheme.
        --
        -- Use `wpdb::has_cap("collation")`.
        --
        -- @since 2.5.0
        -- @deprecated 3.5.0 Use wpdb::has_cap()
        --
        -- @return bool True if collation is supported, false if not.
        --
        -- public function supports_collation() then
        --         _deprecated_function(__FUNCTION__, "3.5.0", "wpdb::has_cap(\"collation\")");
        --         return this.has_cap("collation");
        -- end;

        --
        -- Retrieves the database character collate.
        --
        -- @since 3.5.0
        --
        -- @return string The database character collate.
        --
        -- public function get_charset_collate() then
        --         charset_collate = "";

        --         if (! empty(this.charset)) then
        --                 charset_collate = "DEFAULT CHARACTER SET this.charset";
        --         end;
        --         if (! empty(this.collate)) then
        --                 charset_collate .= " COLLATE this.collate";
        --         end;

        --         return charset_collate;
        -- end;

        --
        -- Determines whether the database or WPDB supports a particular feature.
        --
        -- Capability sniffs for the database server and current version of WPDB.
        --
        -- Database sniffs are based on the version of MySQL the site is using.
        --
        -- WPDB sniffs are added as new features are introduced to allow theme and plugin
        -- developers to determine feature support. This is to account for drop-ins which may
        -- introduce feature support at a different time to WordPress.
        --
        -- @since 2.7.0
        -- @since 4.1.0 Added support for the "utf8mb4" feature.
        -- @since 4.6.0 Added support for the "utf8mb4_520" feature.
        --
        -- @see wpdb::db_version()
        --
        -- @param string db_cap The feature to check for. Accepts "collation", "group_concat",
        --                       "subqueries", "set_charset", "utf8mb4", or "utf8mb4_520".
        -- @return bool True when the database feature is supported, false otherwise.
        --
        -- public function has_cap(db_cap) then
        --         db_version     = this.db_version();
        --         db_server_info = this.db_server_info();

        --         -- Account for MariaDB version being prefixed with "5.5.5-" on older PHP versions.
        --         if ("5.5.5" === db_version && str_contains(db_server_info, "MariaDB")
        --                 && PHP_VERSION_ID < 80016 -- PHP 8.0.15 or older.
        --        ) then
        --                 -- Strip the "5.5.5-" prefix and set the version to the correct value.
        --                 db_server_info = preg_replace("/^5\.5\.5-(.*)/", "1", db_server_info);
        --                 db_version     = preg_replace("/[^0-9.].*/", "", db_server_info);
        --         end;

        --         switch (strtolower(db_cap)) then
        --                 case "collation":    -- @since 2.5.0
        --                 case "group_concat": -- @since 2.7.0
        --                 case "subqueries":   -- @since 2.7.0
        --                         return version_compare(db_version, "4.1", ">=");
        --                 case "set_charset":
        --                         return version_compare(db_version, "5.0.7", ">=");
        --                 case "utf8mb4":      -- @since 4.1.0
        --                         if (version_compare(db_version, "5.5.3", "<")) then
        --                                 return false;
        --                         end;
        --                         if (this.use_mysqli) then
        --                                 client_version = mysqli_get_client_info();
        --                         end; else then
        --                                 client_version = mysql_get_client_info();
        --                         end;

        --                         /*
        --                         -- libmysql has supported utf8mb4 since 5.5.3, same as the MySQL server.
        --                         -- mysqlnd has supported utf8mb4 since 5.0.9.
        --                         --
        --                         if (false !== strpos(client_version, "mysqlnd")) then
        --                                 client_version = preg_replace("/^\D+([\d.]+).*/", "1", client_version);
        --                                 return version_compare(client_version, "5.0.9", ">=");
        --                         end; else then
        --                                 return version_compare(client_version, "5.5.3", ">=");
        --                         end;
        --                 case "utf8mb4_520": -- @since 4.6.0
        --                         return version_compare(db_version, "5.6", ">=");
        --         end;

        --         return false;
        -- end;

        --
        -- Retrieves a comma-separated list of the names of the functions that called wpdb.
        --
        -- @since 2.5.0
        --
        -- @return string Comma-separated list of the calling functions.
        --
        -- public function get_caller() then
        --         return wp_debug_backtrace_summary(__CLASS__);
        -- end;

   ----------------
   -- DB_Version --
   ----------------

   function DB_Version (This : Wpdb_Class)
                        return String
   is
      use Php.Preg;
   begin
      return Preg_Replace ("/[^0-9.].*/", "", This.DB_Server_Info);
   end DB_Version;

   --------------------
   -- DB_Server_Info --
   --------------------

   function DB_Server_Info (This : Wpdb_Class)
            return String
   is
   begin
      -- if This.Use_MySQLi then
      --    Server_Info := MySQLi_Get_Server_Info (This.Dbh);
      -- end; else then
      --    Server_Info := MySQL_Get_Server_Info (This.Dbh);
      -- end if;

      return "XXX-990"; -- Server_Info;
   end DB_Server_Info;

end Inc_Class_Wpdb;
