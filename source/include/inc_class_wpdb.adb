--
-- WordPress database access abstraction class.
--
-- Original code from {@link http://php.justinvincent.com Justin Vincent
-- (justin@visunet.ie)}
--
-- @package WordPress
-- @subpackage Database
-- @since 0.71
--

with Ada.Text_IO;

with Php.Arrays;
with Php.Errors;
with Php.Files;
with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Multibyte;
with Php.Numerics;
with Php.Preg;
with Php.Strings;
with Php.Types;

with MySQL_Bind;
with MySQLi_Bind;

with Arrays.IO;
with Globals;
with Helpers;

with Inc_Functions;
with Inc_L10n;
with Inc_Load;
with Inc_Plugins;
with Inc_Versions;

package body Inc_Class_Wpdb
is

   type Cb_Func is access function (This : Wpdb_Class;
                                    Query : String)
                                    return String;

   function To_Array (This : Wpdb_Class;
                      Cb   : Cb_Func)
                      return Arrays.Callable
                      is (null);

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

   ------------------
   -- Init_Charset --
   ------------------

   procedure Init_Charset (This : in out Wpdb_Class)
   is
      use Inc_Load;

      Charset : Unbounded_String;
      Collate : Unbounded_String;
   begin
      if
--      Function_Exists ("is_multisite") and then
        Is_Multisite
      then
         Charset := +"utf8";
         if Globals.DB_COLLATE /= "" then
            Collate := +Globals.DB_COLLATE;
         else
            Collate := +"utf8_general_ci";
         end if;
      elsif True then -- Defined ("DB_COLLATE") then
         Collate := +Globals.DB_COLLATE;
      end if;

      if Globals.DB_CHARSET /= "" then
--    if Defined ("DB_CHARSET") then
         Charset := +Globals.DB_CHARSET;
      end if;

      declare
         Charset_Collate : constant Array_Type :=
           This.Determine_Charset (-Charset, -Collate);
      begin
         This.Charset := +Get_As_String (Charset_Collate, "charset");
         This.Collate := +Get_As_String (Charset_Collate, "collate");
      end;
   end Init_Charset;

   -----------------------
   -- Determine_Charset --
   -----------------------

   function Determine_Charset (This    : Wpdb_Class;
                               Charset : String;
                               Collate : String)
                               return Array_Type
   is
      use Php.Strings;

      Charset_2 : Unbounded_String := +Charset;
      Collate_2 : Unbounded_String := +Collate;
   begin
--      if
--        (This.Engine = engine_Mysqli and then not
--        (This.Dbh in mysqli)) or else
--         Empty (This.Dbh)
----      (This.Use_Mysqli and then not
----      (This.Dbh in mysqli)) or else
----       Empty (This.Dbh)
--      then
--         return Compact ("charset", "collate");
--      end if;

      if "utf8" = Charset_2 and then This.Has_Cap ("utf8mb4") then
         Charset_2 := +"utf8mb4";
      end if;

      if "utf8mb4" = Charset_2 and then not This.Has_Cap ("utf8mb4") then
         Charset_2 := +"utf8";
         Collate_2 := +Str_Replace ("utf8mb4_", "utf8_", -Collate_2);
      end if;

      if "utf8mb4" = Charset_2 then
         -- _general_ is outdated, so we can upgrade it to _unicode_, instead.
         if Collate_2 = "" or else "utf8_general_ci" = Collate_2 then -- not
            Collate_2 := +"utf8mb4_unicode_ci";
         else
            Collate_2 := +Str_Replace ("utf8_", "utf8mb4_", -Collate_2);
         end if;
      end if;

      -- _unicode_520_ is a better collation, we should use that when it's available.
      if
        This.Has_Cap ("utf8mb4_520") and then
        "utf8mb4_unicode_ci" = Collate_2
      then
         Collate_2 := +"utf8mb4_unicode_520_ci";
      end if;

      return
        To_Array (List => (
          Build ("charset", -Charset_2),
          Build ("collate", -Collate_2)
        ));
   end Determine_Charset;

   -----------------
   -- Set_Charset --
   -----------------

   procedure Set_Charset (This    : Wpdb_Class;
                          Dbh     : Integer;
                          Charset : String := "";  -- = null
                          Collate : String := "") -- = null
   is
      use Php.Strings;
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;

      Charset_2 : constant String :=
        (if not Isset (Charset)
         then -This.Charset
         else Charset);

      Collate_2 : constant String :=
        (if not Isset (Collate)
         then -This.Collate
         else Collate);
   begin
      if This.Has_Cap ("collation") and then not Empty (Charset_2) then
         declare
            Set_Charset_Succeeded : Boolean := True;
         begin
            case This.Engine is -- if This.Use_Mysqli then

            when Engine_MySQLi =>
               if
--               Function_Exists ("mysqli_set_charset") and then
                 This.Has_Cap ("set_charset")
               then
                  Set_Charset_Succeeded := Mysqli_Set_Charset (Dbh, Charset_2);
               end if;

               if Set_Charset_Succeeded then
                  declare
                     Query : Unbounded_String :=
                       +String (This.Prepare ("SET NAMES %s", To_List (Charset_2)));
                  begin
                     if not Empty (Collate_2) then
                        Append (Query,
                                String (This.Prepare (" COLLATE %s",
                                                      To_List (Collate_2))));
                     end if;
                     Mysqli_Query (Dbh, -Query);
                  end;
               end if;
            when Engine_MySQL =>   --                     else

               if
--               Function_Exists ("mysql_set_charset") and then
                 This.Has_Cap ("set_charset")
               then
                  Set_Charset_Succeeded := Mysql_Set_Charset (Charset_2, Dbh);
               end if;

               if Set_Charset_Succeeded then
                  declare
                     Query : Unbounded_String :=
                       +String (This.Prepare ("SET NAMES %s", To_List (Charset_2)));
                  begin
                     if not Empty (Collate_2) then
                        Append (Query,
                                String (This.Prepare (" COLLATE %s",
                                        To_List (Collate_2))));
                     end if;
                     Mysql_Query (-Query, Dbh);
                  end;
               end if;

            when Engine_SQLite =>
               pragma Assert (False);

            end case;
         end;
      end if;
   end Set_Charset;

   ------------------
   -- Set_SQL_Mode --
   ------------------

   procedure Set_SQL_Mode (This  : Wpdb_Class;
                           Modes : Array_Type := Empty_Array)
   is
      use Ada.Text_IO;
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
      use Inc_Plugins;

      Res       : Array_Type;
      Modes_Str : Unbounded_String;
      Modes_2   : Array_Type := Modes;
   begin
      if Modes_2.Is_Empty then
         case This.Engine is

         when Engine_MySQLi =>
            Res := Mysqli_Query (This.Dbh, "SELECT @@SESSION.sql_mode");

         when Engine_MySQL =>
            Res := Mysql_Query ("SELECT @@SESSION.sql_mode", This.Dbh);

         when Engine_SQLite =>
            Put_Line ("set_sql_mode: no query session");
            Res := Empty_Array;
--          pragma Assert (False);
         end case;

         if Res.Is_Empty then
            return;
         end if;

         case This.Engine is

         when Engine_MySQLi =>
            declare
               Modes_Array : constant List_Type :=
                 Mysqli_Fetch_Array (Res);
            begin
               if Empty (-Modes_Array (1)) then -- [0]
                  return;
               end if;
               Modes_Str := Modes_Array (1); -- [0]
            end;

         when Engine_MySQL =>
            Modes_Str := +Mysql_Result (Res, 0);

         when Engine_SQLite =>
            Put_Line ("set_sql_mode: modes_str");
            Modes_Str := +"";
--          pragma Assert (False);
         end case;

         if Empty (-Modes_Str) then
            return;
         end if;

         Modes_2 := Explode (",", -Modes_Str);
      end if;

      Modes_2 := Array_Change_Key_Case (Modes_2, CASE_UPPER);

      declare
         --
         -- Filters the list of incompatible SQL modes to exclude.
         --
         -- @since 3.9.0
         --
         -- @param array incompatible_modes An array of incompatible modes.
         --
         Incompatible_Modes : constant List_Type :=
           Apply_Filters ("incompatible_sql_modes",
                          This.Incompatible_Modes); -- (array)
      begin
         for A in Modes_2.Iterate loop
            declare
               I    : constant String := Key (A);
               Mode : constant String := As_String (Element (A));
            begin
               if In_List (Mode, Incompatible_Modes, True) then
                  Delete (Ref (Modes_2, I)); -- [i]
               end if;
            end;
         end loop;
      end;

      declare
         Mode : constant String := Implode (",", Modes_2);
      begin
         case This.Engine is
         when Engine_MySQLi =>
            Mysqli_Query (This.Dbh, "SET SESSION sql_mode='" & Mode & "'");
         when Engine_MySQL =>
            Mysql_Query ("SET SESSION sql_mode='" & Mode & "'", This.Dbh);
         when Engine_SQLite =>
            Put_Line ("set_sql_mode: no set session");
--          pragma Assert (False);
         end case;
      end;
   end Set_SQL_Mode;

   ----------------
   -- Set_Prefix --
   ----------------

   function Set_Prefix (This            : in out Wpdb_Class;
                        Prefix          : String;
                        Set_Table_Names : Boolean := True)
                        return String
   is
      use Php.Preg;
      use Php.Strings;

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

   -----------------
   -- Set_Blog_Id --
   -----------------

   function Set_Blog_Id (This       : in out Wpdb_Class;
                         Blog_Id    : Integer;
                         Network_Id : Integer := 0)
                         return Integer
   is
   begin
      if Network_Id /= 0 then
--    if not Empty (Network_Id) then
         This.Siteid := Network_Id;
      end if;

      declare
         Old_Blog_Id : constant Integer := This.Blogid;
      begin
         This.Blogid := Blog_Id;

         This.Prefix := +This.Get_Blog_Prefix;

         for A in This.Tables ("blog").Iterate loop
            declare
               Table          : constant String := Key (A);
               Prefixed_Table : constant String := As_String (Element (A));
            begin
               Set_Table (This, Table, Prefixed_Table);
            end;
         end loop;

         for A in This.Tables ("old").Iterate loop
            declare
               Table          : constant String := Key (A);
               Prefixed_Table : constant String := As_String (Element (A));
            begin
               Set_Table (This, Table, Prefixed_Table);
            end;
         end loop;

         return Old_Blog_Id;
      end;
   end Set_Blog_Id;

   ---------------------
   -- Get_Blog_Prefix --
   ---------------------

   function Get_Blog_Prefix (This    : Wpdb_Class;
                             Blog_Id : Integer := 0)
                             return String
   is
      use Inc_Load;
   begin
      if Is_Multisite then
         declare
            Blog_Id_2 : constant Integer := (if Blog_Id = 0
                                             then This.Blogid
                                             else 0);
         begin
            if
              Globals.MULTISITE and then
              Blog_Id_2 in 0 | 1
            then
               return -This.Base_Prefix;
            else
               return -This.Base_Prefix & Helpers.Image (Blog_Id_2) & "_";
            end if;
         end;
      else
         return -This.Base_Prefix;
      end if;
   end Get_Blog_Prefix;

   ------------
   -- Tables --
   ------------

   function Tables (This    : Wpdb_Class;
                    Scope   : String  := "all";
                    Prefix  : Boolean := True;
                    Blog_Id : Integer := 0)
                    return Array_Type
   is
      use Php.Arrays;
      use Php.Lists;
      use Inc_Load;

      function To_Array (List : List_Type)
                         return Array_Type
                         is (raise Program_Error with "not implemented");

      Tables_2 : Array_Type;
   begin
      if Scope in "all" then
         Tables_2 := Array_Merge (To_Array (This.Global_Tables),
                                  To_Array (This.M_Tables));
         if Is_Multisite then
            Tables_2 := Array_Merge (Tables_2,
                                     To_Array (This.MS_Global_Tables));
         end if;

      elsif Scope in "blog" then
         Tables_2 := To_Array (This.M_Tables);

      elsif Scope in "global" then
         Tables_2 := To_Array (This.Global_Tables);
         if Is_Multisite then
            Tables_2 := Array_Merge (Tables_2,
                                     To_Array (This.MS_Global_Tables));
         end if;

      elsif Scope in "ms_global" then
         Tables_2 := To_Array (This.MS_Global_Tables);

      elsif Scope in "old" then
         Tables_2 := To_Array (This.Old_Tables);
         if Is_Multisite then
            Tables_2 := Array_Merge (Tables_2,
                                     To_Array (This.Old_MS_Global_Tables));
         end if;

      else
         return Empty_Array;
      end if; -- case

      if Prefix then
         declare
            Blog_Id_2 : constant Integer :=
              (if Blog_Id = 0
               then This.Blogid
               else Blog_Id);

            Blog_Prefix : constant String := This.Get_Blog_Prefix (Blog_Id_2);
            Base_Prefix : constant String := -This.Base_Prefix;

            Global_Tables : constant List_Type :=
              List_Merge (This.Global_Tables, This.MS_Global_Tables);
         begin
            for A in Tables_2.Iterate loop
               declare
--                K     : String     := Key (A);
                  Table : constant String := Key (A);
--                Table : Array_Type := As_Array (Element (A));
               begin
                  if In_List (Table, Global_Tables, True) then
                     Set (Tables_2, Table, From_String (Base_Prefix & Table));
                  else
                     Set (Tables_2, Table, From_String (
                          Get_As_String (Tables_2, Table) & Blog_Prefix & Table));
                  end if;
--                Delete (Ref (Tables_2, K));
               end;
            end loop;

            if
              Isset (Tables_2, "users") and then
              Globals.CUSTOM_USER_TABLE /= ""
            then
               Set (Tables_2, "users",
                    From_String (Globals.CUSTOM_USER_TABLE));
            end if;

            if
              Isset (Tables_2, "usermeta") and then
              Globals.CUSTOM_USER_META_TABLE /= ""
            then
               Set (Tables_2, "usermeta",
                    From_String (Globals.CUSTOM_USER_META_TABLE));
            end if;
         end;
      end if;

      return Tables_2;
   end Tables;

   -------------
   -- Selectt --
   -------------

   procedure Selectt (This : in out Wpdb_Class;
                      DB   : String;
                      Dbh  : Integer) --  = null
   is
      use Ada.Text_IO;
      use Php.HTML;
      use Php.Strings;
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Plugins;

      Success : Boolean;
   begin
      -- if Is_Null (Dbh) then
      --    Dbh := This.Dbh;
      -- end if;

      case This.Engine is
      when Engine_MySQLi =>
         Success := Mysqli_Select_DB (Dbh, DB);
      when Engine_MySQL =>
         Success := Mysql_Select_DB (DB, Dbh);
      when Engine_SQLite =>
         Put_Line ("selectt: no select_db");
         Success := False;
--       pragma Assert (False);
      end case;

      if not Success then
         This.Ready := False;
         if not Did_Action ("template_redirect") then
            Wp_Load_Translations_Early;
            declare
               Message : constant String :=
                 "<h1>" & abs "Cannot select database" & "</h1>\n" &
                 "<p>" & Sprintf (
                   -- translators: %s: Database name.
                   abs "The database server could be connected to (which means your username and password is okay) but the %s database could not be selected.",
                   To_List ("<code>" & HTML_Special_Chars (DB, ENT_QUOTES) & "</code>")
                 ) & "</p>\n" &

                 "<ul>\n" &
                 "<li>" & abs "Are you sure it exists?" & "</li>\n" &

                 "<li>" & Sprintf (
                   -- translators: 1: Database user, 2: Database name.
                   abs "Does the user %1s have permission to use the %2s database?",
                   To_List (List => (
                     1 => +"<code>" &
                          HTML_Special_Chars (-This.Dbuser, ENT_QUOTES) &
                          "</code>",
                     2 => +"<code>" &
                          HTML_Special_Chars (DB, ENT_QUOTES) & "</code>"
                   ))
                 ) & "</li>\n" &

                 "<li>" & Sprintf (
                   -- translators: %s: Database name.
                   abs "On some systems the name of your database is prefixed with your username, so it would be like <code>username_%1s</code>. Could that be the problem?",
                   To_List (HTML_Special_Chars (DB, ENT_QUOTES))
                 ) & "</li>\n" &

                 "</ul>\n" &

                 "<p>" & Sprintf (
                   -- translators: %s: Support forums URL.
                   abs "If you do not know how to set up a database you should <strong>contact your host</strong>. If all else fails you may find help at the <a href=""%s"">WordPress Support Forums</a>.",
                   To_List (abs "https://wordpress.org/support/forums/")
                 ) & "</p>\n";
            begin
               This.Bail (Message, "db_select_fail");
            end;
         end if;
      end if;
   end Selectt;

   --      Do not use, deprecated.

   --      Use esc_sql() or wpdb::prepare() instead.

   --      @since 2.8.0
   --      @deprecated 3.6.0 Use wpdb::prepare()
   --      @see wpdb::prepare()
   --      @see esc_sql()

   --      @param string string
   --      @return string

   --      public function _weak_escape(string) then
   --              if (func_num_args() === 1 && function_exists("_deprecated_function")) then
   --                      _deprecated_function(__METHOD__, "3.6.0", "wpdb::prepare() or esc_sql()");
   --              end;
   --              return addslashes(string);

   --      end;

   -------------------
   -- X_Real_Escape --
   -------------------

   function X_Real_Escape (This : Wpdb_Class;
                           Item : String)
                           return String
   is
      use Php.Strings;
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
      use Inc_Functions;
      use Inc_Load;
      use Inc_L10n;

      Escaped : Unbounded_String;
   begin
--    if not Is_Scalar (Item) then
--       return "";
--    end;

      if This.Dbh /= 0 then
         case This.Engine is
         when Engine_MySQLi =>
            Escaped := +MySQLi_Real_Escape_String (This.Dbh, Item);
         when Engine_MySQL =>
            Escaped := +MySQL_Real_Escape_String (Item, This.Dbh);
         when Engine_SQLite =>
            pragma Assert (False);
         end case;
      else
         declare
            Class : constant String := "XXX-898"; -- := Get_Class (This);
         begin
            Wp_Load_Translations_Early;
            -- translators: %s: Database access abstraction class, usually wpdb or a class extending wpdb.
            X_Doing_It_Wrong (
              Class,
              Sprintf (abs "%s must set a database connection for use with escaping.",
                       To_List (Class)),
              "3.6.0");
         end;
         Escaped := +Add_Slashes (Item);
      end if;

      return String (This.Add_Placeholder_Escape (Statement_Type (-Escaped)));
   end X_Real_Escape;

   --------------
   -- X_Escape --
   --------------

   function X_Escape (This : Wpdb_Class;
                      Data : String)
                      return String
   is
   begin
      -- if (is_array(data)) then
      --    for (data as k => v) loop
      --       if (is_array(v)) then
      --          data[ k ] = this._escape(v);
      --       else
      --          data[ k ] = this._real_escape(v);
      --       end if;
      --    end loop;
      -- else
      --    data = this._real_escape(data);
      return This.X_Real_Escape (Data);
      -- end if;

      -- return data;
   end X_Escape;

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

   -------------
   -- Prepare --
   -------------

   function Prepare (Db    : Wpdb_Class;
                     Query : String;
                     Args  : List_Type) --, ...args)
                     return Statement_Type
   is
      use Php.Preg;
      use Php.Strings;
      use Inc_Functions;
      use Inc_L10n;

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
            Allowed_Format : constant String :=
               "(?:[1-9][0-9]*[$])?[-+0-9]*(?: |0|\'.)?[-+0-9]*(?:\.[0-9]+)?";

            --
            -- If a %s placeholder already has quotes around it, removing the
            -- existing quotes and re-inserting them ensures the quotes are consistent.
            --
            -- For backward compatibility, this is only applied to %s, and not to
            -- placeholders like %1s, which are frequently used in the middle of
            -- longer strings, or as table name placeholders.
            --
            Query_3 : constant String := Str_Replace ("'%s'", "%s", Query);
            -- Strip any existing single quotes.

            Query_4 : constant String := Str_Replace ("""%s""", "%s", Query_3);
            -- Strip any existing double quotes.

            Query_5 : constant String := Preg_Replace ("/(?<!%)%s/", "'%s'", Query_4);
            -- Quote the strings, avoiding escaped strings like %%s.

            Query_6 : constant String :=
              Preg_Replace ("/(?<!%)(%(" & Allowed_Format & ")?f)/", "%\\2F",
                            Query_5);

            -- Force floats to be locale-unaware.
            Query_7 : constant String :=
              Preg_Replace ("/%(?:%|$|(?!(" & Allowed_Format & ")?[sdF]))/",
                            "%%\\1", Query_6);
            -- Escape any unescaped percents.

            -- Count the number of valid placeholders in the query.
            Matches : Array_Type;

            Placeholders : constant Integer :=
              Preg_Match_All ("/(^|[^%]|(%%)+)%(" & Allowed_Format & ")?[sdF]/",
                              Query_7, Matches);

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
                  -- If we don't have the right number of placeholders,
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
                        1 => +Helpers.Image (Placeholders),
                        2 => +Helpers.Image (Args_Count)
                      ))
                    ),
                    "4.8.3");

                  --
                  -- If we don't have enough arguments to match the placeholders,
                  -- return an empty string to avoid a fatal error on PHP 8.
                  --
                  if Args_Count < Placeholders then
                     declare
--                      use Array_Maps;

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

--          Array_Walk (Args, Func"Access);
--          To_Array (Db, "escape_by_ref"));

            declare
               Query_8 : constant Statement_Type :=
                 Statement_Type (Vsprintf (Query_7, Args));

               Query_9 : constant Statement_Type :=
                 Db.Add_Placeholder_Escape (Query_8);
            begin
               Ada.Text_IO.Put_Line (
                 "inc_class_wpdb.prepare: " & String (Query_9));

               return Query_9;
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

   -----------
   -- Flush --
   -----------

   procedure Flush (This : in out Wpdb_Class)
   is
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
   begin
      This.Last_Result   := String_Vectors.Empty_Vector;
--      This.Col_Info      := null;
      This.Last_Query    := +""; -- null;
      This.Rows_Affected := 0;
      This.Num_Rows      := 0;
      This.Last_Error    := +"";

--      if
--        This.Use_Mysqli and then
--        This.Result in Mysqli_Result     -- instanceof
--      then
      case This.Engine is

      when Engine_MySQLi =>
         Mysqli_Free_Result (This.Result);
         This.Result := Databases.None; -- null;

         -- Sanity check before using the handle.
         if
           This.Dbh = 0 -- or else
--         Empty (This.Dbh) or else
--         not (This.Dbh in Mysqli)      -- instanceof
         then
            return;
         end if;

         -- Clear out any results from a multi-query.
         while Mysqli_More_Results (This.Dbh) loop
            Mysqli_Next_Result (This.Dbh);
         end loop;

      when Engine_MySQL =>
--      elsif Is_Resource (This.Result) then
         Mysql_Free_Result (This.Result);
      when Engine_SQLite =>
         null;
--       raise Program_Error with "not implemented";

      end case;
--    end if;
   end Flush;

   ----------------
   -- DB_Connect --
   ----------------

   function DB_Connect (This       : in out Wpdb_Class;
                        Allow_Bail : Boolean := True)
                        return Boolean
   is
      use Php.Errors;
      use Php.Files;
      use Php.HTML;
      use Php.Strings;
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
      use Inc_Load;
      use Inc_L10n;
   begin
      This.Engine := Databases.Engine_SQLite; -- Engine_MySQL;
--    This.Is_MySQL := True;

      --
      -- Deprecated in 3.9+ when using MySQLi. No equivalent
      -- new_link parameter exists for mysqli_* functions.
      --
      declare
         New_Link     : constant Boolean := False;
         -- defined("MYSQL_NEW_LINK") ? MYSQL_NEW_LINK : true;
         Client_Flags : constant Integer := 0;
         -- defined("MYSQL_CLIENT_FLAGS") ? MYSQL_CLIENT_FLAGS : 0;
      begin
--       if This.Use_Mysqli then
         case This.Engine is

         when Engine_MySQLi =>
            --
            -- Set the MySQLi error reporting off because WordPress handles its own.
            -- This is due to the default value change from `MYSQLI_REPORT_OFF`
            -- to `MYSQLI_REPORT_ERROR|MYSQLI_REPORT_STRICT` in PHP 8.1.
            --
            Mysqli_Report (MYSQLI_REPORT_OFF);

            This.Dbh := Mysqli_Init; -- ();

            declare
               Host    : Unbounded_String := This.Dbhost;
               Port    : constant Natural  := 0;   -- Duration := null;
               Socket  : constant String   := ""; -- Duration := null;
               Is_IPv6 : constant Boolean  := False;
               Host_Data : constant Array_Type := This.Parse_DB_Host (-This.Dbhost);
            begin
               -- if Host_Data then
               --    List : List_Type;
               --    (Host, Port, Socket, Is_IPv6) := Host_Data;
               -- end if;

               --
               -- If using the `mysqlnd` library, the IPv6 address needs to be enclosed
               -- in square brackets, whereas it doesn't while using the `libmysqlclient`
               -- library.
               -- @see https://bugs.php.net/bug.php?id=67563
               --
               if Is_IPv6 then -- and then Extension_Loaded ("mysqlnd") then
                  Host := +"[host]";
               end if;

               if Globals.WP_DEBUG then
                  Mysqli_Real_Connect
                    (This.Dbh, -Host, -This.Dbuser, -This.Dbpassword,
                     "", -- null,
                     Port, Socket, Client_Flags);
               else
                  -- phpcs:ignore WordPress.PHP.NoSilencedErrors.Discouraged
                  -- @
                  Mysqli_Real_Connect
                    (This.Dbh, -Host, -This.Dbuser, -This.Dbpassword,
                     "", -- null,
                     Port, Socket, Client_Flags);
               end if;
            end;

            if False then -- if This.Dbh.Connect_Errno then
               This.Dbh := 0; -- null;

               --
               -- It's possible ext/mysqli is misconfigured. Fall back to ext/mysql if:
               --  - We haven't previously connected, and
               --  - WP_USE_EXT_MYSQL isn"t set to false, and
               --  - ext/mysql is loaded.
               --
               declare
                  Attempt_Fallback : Boolean := True;
               begin
                  if This.Has_Connected then
                     Attempt_Fallback := False;

                  elsif False then -- Defined ("WP_USE_EXT_MYSQL") and then not WP_USE_EXT_MYSQL then
                     Attempt_Fallback := False;

                  elsif True then -- not Function_Exists ("mysql_connect") then
                     Attempt_Fallback := False;
                  end if;

                  if Attempt_Fallback then
--                   This.Use_Mysqli := False;
                     return This.DB_Connect (Allow_Bail);
                  end if;
               end;
            end if;

         when Engine_MySQL =>
--       else
            if Globals.WP_DEBUG then
               This.Dbh :=
                 Mysql_Connect (-This.Dbhost, -This.Dbuser, -This.Dbpassword,
                                New_Link, Client_Flags);
            else
               -- phpcs:ignore WordPress.PHP.NoSilencedErrors.Discouraged
               This.Dbh := -- @
                 Mysql_Connect (-This.Dbhost, -This.Dbuser, -This.Dbpassword,
                                New_Link, Client_Flags);
            end if;

         when Engine_SQLite =>
            This.Handle := SQLite.Open (File_Name => "heidelberger.sqlite");
            This.Dbh    := -1;

         end case;
      end;

      if This.Dbh = 0 and then Allow_Bail then -- not
         Wp_Load_Translations_Early;

         -- Load custom DB error template, if present.
         if File_Exists ((-Globals.WP_CONTENT_DIR) & "/db-error.php") then
--          require_once WP_CONTENT_DIR & "/db-error.php";
            Die; -- ();
         end if;

         declare
            Message : constant String :=
              "<h1>" & abs "Error establishing a database connection" & "</h1>\n" &

              "<p>" & Sprintf (
                -- translators: 1: wp-config.php, 2: Database host.
                abs "This either means that the username and password information in your %1s file is incorrect or that contact with the database server at %2s could not be established. This could mean your host&#8217;s database server is down.",
                To_List (List => (
                  1 => +"<code>wp-config.php</code>",
                  2 => +"<code>" & HTML_Special_Chars (-This.Dbhost, ENT_QUOTES) & "</code>"
                ))
              ) & "</p>\n" &

              "<ul>\n" &
              "<li>" & abs "Are you sure you have the correct username and password?" & "</li>\n" &
              "<li>" & abs "Are you sure you have typed the correct hostname?" & "</li>\n" &
              "<li>" & abs "Are you sure the database server is running?" & "</li>\n" &
              "</ul>\n" &

              "<p>" & Sprintf (
                 -- translators: %s: Support forums URL.
                 abs "If you are unsure what these terms mean you should probably contact your host. If you still need help you can always visit the <a href=""%s"">WordPress Support Forums</a>.",
                 To_List (abs "https://wordpress.org/support/forums/")
               ) & "</p>\n";
         begin
            This.Bail (Message, "db_connect_fail");
         end;

         return False;

      elsif This.Dbh /= 0 then
         if not This.Has_Connected then
            This.Init_Charset;
         end if;

         This.Has_Connected := True;

         This.Set_Charset (This.Dbh);

         This.Ready := True;
         This.Set_SQL_Mode;
         This.Selectt (-This.Dbname, This.Dbh);

         return True;
      end if;

      return False;
   end DB_Connect;

   -------------------
   -- Parse_DB_Host --
   -------------------

   function Parse_DB_Host (This : Wpdb_Class;
                           Host : String)
                           return Array_Type
   is
   begin
      raise Program_Error with "not implemented";
      return Empty_Array;
   end Parse_DB_Host;
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

   ----------------------
   -- Check_Connection --
   ----------------------

   function Check_Connection (This       : Wpdb_Class;
                              Allow_Bail : Boolean := True)
                              return Boolean
   is
   begin
      raise Program_Error with "not implemented";
      return False;
   end Check_Connection;
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

   -----------
   -- Query --
   -----------

   function Query (This  : in out Wpdb_Class;
                   Query : Statement_Type)
                   return Integer
   is
      use Php.Preg;
--    use Php.Types;
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Plugins;
   begin
      if not This.Ready then
         This.Check_Current_Query := True;
         return -1; -- false;
      end if;

      --
      -- Filters the database query.
      --
      -- Some queries are made before the plugins have been loaded,
      -- and thus cannot be filtered with this method.
      --
      -- @since 2.1.0
      --
      -- @param string query Database query.
      --
      declare
         Query_2 : constant String := Apply_Filters ("query", String (Query));
      begin
         if Query_2 = "" then -- not
            This.Insert_Id := 0;
            return -1; -- false;
         end if;

         This.Flush;

         -- Log how the function was called.
         This.Func_Call := +"\db.query(""" & Query_2 & """)";

         -- If we're writing to the database, make sure the query will write safely.
         if This.Check_Current_Query and then not This.Check_ASCII (Query_2) then
            declare
               Stripped_Query : constant String :=
                 This.Strip_Invalid_Text_From_Query (Query_2);
            begin
               -- strip_invalid_text_from_query() can perform queries, so we need
               -- to flush again, just to make sure everything is clear.
               This.Flush;
               if Stripped_Query /= Query_2 then
                  This.Insert_Id  := 0;
                  This.Last_Query := +Query_2;

                  Wp_Load_Translations_Early;

                  This.Last_Error :=
                    +abs "WordPress database error: Could not perform query because it contains invalid data.";

                  return -1; -- false;
               end if;
            end;
         end if;

         This.Check_Current_Query := True;

         -- Keep track of the last query for debug.
         This.Last_Query := +Query_2;

         This.X_Do_Query (Query_2);

         -- Database server has gone away, try to reconnect.
         declare
            Mysql_Errno : Integer := 0;
            Ret_Val     : Integer;
            Return_Val  : Natural;
         begin
            if This.Dbh = 0 then
--          if not Empty (This.Dbh) then
--             if This.Use_Mysqli then
               case This.Engine is

               when Engine_MySQLi =>
--                  if This.Dbh in Mysqli then -- instanceof
                     Mysql_Errno := Mysqli_Errno (This.Dbh);
--                  else
                     -- dbh is defined, but isn't a real connection.
                     -- Something has gone horribly wrong, let's try a reconnect.
                     Mysql_Errno := 2006;
--                  end if;

               when Engine_MySQL =>
--                if Is_Resource (This.Dbh) then
                     Mysql_Errno := MySQL_Bind.Mysql_Errno (This.Dbh);
--                else
--                   Mysql_Errno := 2006;
--                end if;

               when Engine_SQLite =>
                  raise Program_Error with "not implemented";

               end case;
            end if;

            if This.Dbh /= 0 or else 2006 = Mysql_Errno then
--          if Empty (This.Dbh) or else 2006 = Mysql_Errno then
               if This.Check_Connection then -- ()
                  This.X_Do_Query (Query_2);
               else
                  This.Insert_Id := 0;
                  return -1; --  false;
               end if;
            end if;

            -- If there is an error then take note of it.
--          if This.Use_Mysqli then
            case This.Engine is

            when Engine_MySQLi =>
--               if This.Dbh in mysqli then -- instanceof
                  This.Last_Error := +Mysqli_Error (This.Dbh);
--               else
--                  This.Last_Error :=
--                    +abs "Unable to retrieve the error message from MySQL";
--               end if;

            when Engine_MySQL =>
--               if Is_Resource (This.Dbh) then
                  This.Last_Error := +Mysql_Error (This.Dbh);
--               else
--                  This.Last_Error :=
--                    +abs "Unable to retrieve the error message from MySQL";
--               end if;

            when Engine_SQLite =>
               raise Program_Error with "not implemented";

            end case;

            if This.Last_Error /= "" then
--          if This.Last_Error then
               -- Clear insert_id on a subsequent failed insert.
               if
                 This.Insert_Id /= 0 and then
                 Preg_Match ("/^\s*(insert|replace)\s/i", Query_2)
               then
                  This.Insert_Id := 0;
               end if;

               This.Print_Error;
               return -1; -- false;
            end if;

            if Preg_Match ("/^\s*(create|alter|truncate|drop)\s/i", Query_2) then
               Return_Val := 999; -- This.Result;

            elsif Preg_Match ("/^\s*(insert|delete|update|replace)\s/i", Query_2) then
               case This.Engine is
               when Engine_MySQLi =>
                  This.Rows_Affected := Mysqli_Affected_Rows (This.Dbh);
               when Engine_MySQL =>
                  This.Rows_Affected := Mysql_Affected_Rows (This.Dbh);
               when Engine_SQLite =>
                  raise Program_Error with "not implemented";
               end case;

               -- Take note of the insert_id.
               if Preg_Match ("/^\s*(insert|replace)\s/i", Query_2) then
                  case This.Engine is
                  when Engine_MySQLi =>
                     This.Insert_Id := Mysqli_Insert_Id (This.Dbh);
                  when Engine_MySQL =>
                     This.Insert_Id := Mysql_Insert_Id (This.Dbh);
                  when Engine_SQLite =>
                     raise Program_Error with "not implemented";
                  end case;
               end if;

               -- Return number of rows affected.
               Return_Val := This.Rows_Affected;
            else
               declare
                  Num_Rows : Natural := 0;
               begin
                  case This.Engine is

                  when Engine_MySQLi =>
--                  if
--                    This.Use_Mysqli and then
--                    This.Result in Mysqli_Result    -- instanceof
--                  then
                     declare
                        Row : Natural;
                     begin
                        while Row = Mysqli_Fetch_Object (This.Result) loop
--                         This.Last_Result (Num_Rows) := Row;
                           Num_Rows := Num_Rows + 1;
                        end loop;
                     end;

                  when Engine_MySQL =>
--                  elsif Is_Resource (This.Result) then
                     declare
                        Row : Natural;
                     begin
                        while Row = Mysql_Fetch_Object (This.Result) loop
--                         This.Last_Result (Num_Rows) := Row;
                           Num_Rows := Num_Rows + 1;
                        end loop;
                     end;

                  when Engine_SQLite =>
                     raise Program_Error with "not implemented";
                  end case;

                  -- Log and return the number of rows selected.
                  This.Num_Rows := Num_Rows;
                  Return_Val    := Num_Rows;
               end;
            end if;
            return Return_Val;
         end;
      end;
   end Query;

   -----------
   -- Query --
   -----------

   procedure Query (Db    : in out Wpdb_Class;
                    Query : Statement_Type)
   is
      Unused : constant Integer := Db.Query (Query);
   begin
      null;
   end Query;

   ----------------
   -- X_Do_Query --
   ----------------

   procedure X_Do_Query (This  : in out Wpdb_Class;
                         Query : String)
   is
      use Ada.Text_IO;
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
   begin
      Put_Line ("x_do_query:");
      Put_Line ("  query: " & Query);
      -- if (defined("SAVEQUERIES") && SAVEQUERIES) then
      --    this.timer_start();
      -- end if;

      if This.Dbh /= 0 then
         case This.Engine is
         when Engine_MySQLi =>
--    if not Empty (This.Dbh) and then This.Use_Mysqli then
            This.Result := Mysqli_Query (This.Dbh, Query);
         when Engine_MySQL => --  This.Dbh /= 0 then
--    elsif not Empty (This.Dbh) then
            This.Result := Mysql_Query (This.Dbh, Query);

         when Engine_SQLite =>
            declare
               use SQLite;

               Command : constant Statement :=
                 Prepare (This.Handle, Query); --  & ";"); -- ";" added
            begin
               Step (Command);
            end;

         end case;
      end if;
      This.Num_Queries := This.Num_Queries + 1;

      -- if (defined("SAVEQUERIES") && SAVEQUERIES) then
      --    this.Log_Query (
      --       query,
      --       this.timer_stop(),
      --       this.get_caller(),
      --       this.time_start,
      --       array()
      --    );
      -- end if;
   end X_Do_Query;

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

   ------------------------
   -- Placeholder_Escape --
   ------------------------

   Static_Placeholder : Unbounded_String;

   function Placeholder_Escape (This : Wpdb_Class)
                                return String
   is
      use Php.Numerics;
      use Inc_Plugins;
--                static_placeholder;
   begin
      if Static_Placeholder = "" then -- not
         -- If ext/hash is not present, compat.php's hash_hmac() does not support
         -- sha256.
         declare
            Algo : constant String :=
              (if True -- Function_Exists ("hash")
               then "sha256" else "sha1");

            -- Old WP installs may not have AUTH_SALT defined.
            Salt : constant String :=
              (if True -- Defined ("AUTH_SALT") and then AUTH_SALT
               then Globals.AUTH_SALT else Rand'Image); -- (string)
         begin
            Static_Placeholder :=
              +"{" & Hash_HMAC (Algo, Uniqid (Salt, True), Salt) & "}";
         end;
      end if;

      --
      -- Add the filter to remove the placeholder escaper. Uses priority 0, so that
      -- anything else attached to this filter will receive the query with the
      -- placeholder string removed.
      --
      if
        False = Has_Filter ("query",
                            To_Array (This, Remove_Placeholder_Escape'Access))
      then
         Add_Filter ("query",
                     To_Array (This, Remove_Placeholder_Escape'Access), 0);
      end if;

      return -Static_Placeholder;
   end Placeholder_Escape;

   ----------------------------
   -- Add_Placeholder_Escape --
   ----------------------------

   function Add_Placeholder_Escape (This  : Wpdb_Class;
                                    Query : Statement_Type)
                                    return Statement_Type
   is
      use Php.Strings;
   begin
      --
      -- To prevent returning anything that even vaguely resembles a placeholder,
      -- we clobber every % we can find.
      --
      return Statement_Type (
        Str_Replace ("%", This.Placeholder_Escape, String (Query)));
   end Add_Placeholder_Escape;

   -------------------------------
   -- Remove_Placeholder_Escape --
   -------------------------------

   function Remove_Placeholder_Escape (This  : Wpdb_Class;
                                       Query : String)
                                       return String
   is
      use Php.Strings;
   begin
      return Str_Replace (This.Placeholder_Escape, "%", Query);
   end Remove_Placeholder_Escape;

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
        not In_List (Strtoupper (Typ),
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
      use Inc_L10n;

      Data_2 : Array_Type := Data;
   begin
      Ada.Text_IO.Put_Line ("process_fields:");

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

      Arrays.IO.Dump (Data_2);
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
      use Php.Strings;

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
               Set (Value_2, "format", From_String (List_Shift (Formats)));
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

   function Process_Field_Charsets (This  : in out Wpdb_Class;
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

   function Process_Field_Lengths (This  : in out Wpdb_Class;
                                   Data  : Array_Type;
                                   Table : String)
                                   return Array_Type
   is
--    use Inc_Load;

      Data_2 : Array_Type := Data;
   begin
      Ada.Text_IO.Put_Line ("process_field_lengths: data:");
      Arrays.IO.Dump (Data);

      for A in Data_2.Iterate loop
         declare
            Field : constant String := Key (A);
            Value : Array_Type      := As_Array (Element (A));
         begin
            if Get_As_String (Value, "format") in "%d" | "%f" then
               --
               -- We can skip this field if we know it isn't a string.
               -- This checks %d/%f versus ! %s because its sprintf() could take more.
               --
               Set (Value, "length", From_Boolean (False));
            else
               Set (Value, "length",
                    From_Array (This.Get_Col_Length (Table, Field)));

               Arrays.IO.Dump (Value);
--               if Is_Wp_Error (Get_As_String (Value, "length")) then
--                  return Empty_Array; -- false;
--               end if;
            end if;

            Set (Data_2, Field, From_Array (Value));
         end;
      end loop;

      return Data_2;
   end Process_Field_Lengths;

   -------------
   -- Get_Var --
   -------------

   function Get_Var (This  : in out Wpdb_Class;
                     Query : Statement_Type := ""; -- null
                     X     : Integer        := 0;
                     Y     : Integer        := 1)
                     return String
   is
      use Ada.Text_IO;
   begin
      This.Func_Call :=
        +("\db.get_var(\" & String (Query) & "\" & X'Image & Y'Image & "");
      Put_Line ("\db.get_var(\" & String (Query) & "\" & X'Image & Y'Image & "");

      if Query /= "" then
         if
           This.Check_Current_Query and then
           This.Check_Safe_Collation (Query)
         then
            This.Check_Current_Query := False;
         end if;

         This.Query (Query);
      end if;

      -- Added
      if This.Last_Result.Is_Empty then
         return "XXX-885";
      end if;

      return This.Last_Result (Y);
      -- declare
      --    -- Extract var out of cached results based on x,y vals.
      --    Values : constant Array_Type :=
      --      (if not Empty (This.Last_Result (Y))
      --       then Array_Values (Get_Object_Vars (This.Last_Result (Y)))
      --       else Empty_Array);
      -- begin
      --    -- If there is a value return it, else return null.
      --    return
      --      (if Isset (Values, X) and then "" /= Get_As_String (Values, X)
      --       then Get_As_String (Values, X)
      --       else ""); -- null);
      -- end;
   end Get_Var;

   -------------
   -- Get_Row --
   -------------

   procedure Get_Row (Db      : in out Wpdb_Class;
                      Query   : Statement_Type; -- := ""; -- = null,
--                    Output  : String         := ""; -- = OBJECT,
--                    Y       : Natural        := 0;
                      Success : out Boolean)
--                     return String
   is
--    use Php.Strings;

      Unused_Result : Integer;
   begin
      Success := True;
      Db.Func_Call := +("\db.get_row(\" & String (Query) & ",output,y)"); -- \

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
         return; --  ""; --  null;
      end if;
   end Get_Row;

   -------------
   -- Get_Row --
   -------------

   function Get_Row (Db      : in out Wpdb_Class;
                     Query   : Statement_Type; --  := ""; -- = null,
--                   Output  : String         := ""; -- = OBJECT,
                     Y       : Natural        := 0;
                     Success : out Boolean)
                     return String
   is
   begin
      Get_Row (Db, Query, Success);
      if not Success then
         return "";
      end if;

      if Db.Last_Result.Last_Index < Y then
--    if not Isset (Db.Last_Result (Y)) then
         Success := False;
         return ""; --  null;
      end if;

--    if "OBJECT" = Output then
         return (if Db.Last_Result (Y) /= ""
                 then Db.Last_Result (Y) else ""); -- null
      -- elsif "ARRAY_A" = Output then
      --    return (if Db.Last_Result (Y) /= ""
      --            then Get_Object_Vars (Db.Last_Result (Y)) else "");
      -- elsif "ARRAY_N" = Output then
      --    return (if Db.Last_Result (Y) /= ""
      --            then Array_Values (Get_Object_Vars (Db.Last_Result (Y))) else "");
--    elsif "OBJECT" = Strtoupper (Output) then
--       -- Back compat for OBJECT being previously case-insensitive.
--       return (if Db.Last_Result (Y) /= ""
--               then Db.Last_Result (Y) else "");
--    else
--       Db.Print_Error (" db.get_row(string query, output type, int offset) -- Output type must be one of: OBJECT, ARRAY_A, ARRAY_N");
--    end if;
--    return "";
   end Get_Row;

   -------------
   -- Get_Row --
   -------------

   function Get_Row (Db      : in out Wpdb_Class;
                     Query   : Statement_Type;
                     Y       : Natural        := 0;
                     Success : out Boolean)
                     return Array_Type
   is
   begin
      Get_Row (Db, Query, Success);
      if not Success then
         return Empty_Array; -- "";
      end if;

--    if not Isset (Db.Last_Result (Y)) then
      if Y not in Db.Last_Result.First_Index .. Db.Last_Result.Last_Index then
         Success := False;
         return Empty_Array; -- ""; --  null;
      end if;

      if Db.Last_Result (Y) = "" then
         return Empty_Array;
      else
         return Empty_Array; -- Get_Object_Vars (Db.Last_Result (Y));
      end if;
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

   ----------------
   -- Get_Result --
   ----------------

   procedure Get_Results (This  : in out Wpdb_Class;
                          Query : Statement_Type) --  ""; -- null
   is
   begin
      This.Func_Call := +"\db.get_results(""" & String (Query) & """";
      --  & Output & ")";

      if Query /= "" then
         if
           This.Check_Current_Query and then
           This.Check_Safe_Collation (Query)
         then
            This.Check_Current_Query := False;
         end if;

         This.Query (Query);
      else
         return; --  Empty_Array; -- null
      end if;
   end Get_Results;

   -----------------
   -- Get_Results --
   -----------------

   function Get_Results (This   : in out Wpdb_Class;
                         Query  : Statement_Type; -- String := ""; -- null
                         Output : String := "OBJECT")
                         return Array_Type
   is
      use Ada.Text_IO;
   begin
      Put_Line ("get_results: ");
      Put_Line ("  output: " & Output);
      Get_Results (This, Query);
      pragma Assert (Output = "OBJECT");
                -- new_array = array();
                -- if (OBJECT === output) then
      -- Return an integer-keyed array of row objects.
--    return This.Last_Result;
      declare
         Result : Array_Type;
      begin
         for A of This.Last_Result loop
            Result.Append (From_String (A));
         end loop;
         return Result;
      end;
                -- end; elseif (OBJECT_K === output) then
                --         // Return an array of row objects with keys from column 1.
                --         // (Duplicates are discarded.)
                --         if (this.last_result) then
                --                 foreach (this.last_result as row) then
                --                         var_by_ref = get_object_vars(row);
                --                         key        = array_shift(var_by_ref);
                --                         if (! isset(new_array[ key ])) then
                --                                 new_array[ key ] = row;
                --                         end;
                --                 end;
                --         end;
                --         return new_array;
                -- end; elseif (ARRAY_A === output || ARRAY_N === output) then
                --         // Return an integer-keyed array of...
                --         if (this.last_result) then
                --                 foreach ((array) this.last_result as row) then
                --                         if (ARRAY_N === output) then
                --                                 // ...integer-keyed row arrays.
                --                                 new_array[] = array_values(get_object_vars(row));
                --                         end; else then
                --                                 // ...column name-keyed row arrays.
                --                                 new_array[] = get_object_vars(row);
                --                         end;
                --                 end;
                --         end;
                --         return new_array;
                -- end; elseif (strtoupper(output) === OBJECT) then
                --         // Back compat for OBJECT being previously case-insensitive.
                --         return this.last_result;
                -- end;
                -- return null;
   end Get_Results;

   -----------------------
   -- Get_Table_Charset --
   -----------------------

   function Get_Table_Charset (This  : in out Wpdb_Class;
                               Table : String)
                               return String
   is
      use Ada.Containers;
      use Ada.Text_IO;
      use Php.Lists;
      use Php.Strings;
      use Inc_Plugins;

      Tablekey : constant String := Strtolower (Table);

      --
      -- Filters the table charset value before the DB is checked.
      --
      -- Returning a non-null value from the filter will effectively short-circuit
      -- checking the DB for the charset, returning that value instead.
      --
      -- @since 4.2.0
      --
      -- @param string|WP_Error|null charset The character set to use, WP_Error object
      --                                      if it couldn't be found. Default null.
      -- @param string               table   The name of the table being checked.
      --
      Charset : Unbounded_String :=
        +Apply_Filters ("pre_get_table_charset", "", -- null,
                        Table);
   begin
      Put_Line ("get_table_charset:");
      Put_Line ("  table: " & Tablekey);
      Put_Line ("  charset: " & (-Charset));

      if "" /= Charset then -- null
         return -Charset;
      end if;

      if Isset (This.Table_Charset, Tablekey) then
         return Get_As_String (This.Table_Charset, Tablekey);
      end if;

      declare
         Charsets : Array_Type;
         Columns  : Array_Type;

         Table_Parts : constant List_Type  := Explode (".", Table);
         Table       : constant String     := "`" & Implode ("`.`", Table_Parts) & "`";

         Results     : constant Array_Type :=
           This.Get_Results (Statement_Type ("SHOW FULL COLUMNS FROM " & Table));
      begin
         if Results = Empty_Array then -- not
            return "";
            -- new Wp_Error ("wpdb_get_table_charset_failure",
            --               abs "Could not retrieve table charset.");
         end if;

         -- for A in Results.Iterate loop
         --    declare
         --       Column : String := Key (A);
         --    begin
         --       Set (Columns, Strtolower (Column.Field), From_String (Column));
         --    end;
         -- end loop;

         -- Set (This.Col_Meta, Tablekey, From_Array (Columns));

         -- for Column of Columns loop
         --    if not Empty (Column.Collation) then
         --       declare
         --          List : List_Type := Explode ("_", Column.Collation);
         --       begin
         --          Charset := List.First_Element;

         --          -- If the current connection can't support utf8mb4 characters,
         --          -- let's only send 3-byte utf8 characters.
         --          if "utf8mb4" = Charset and then not This.Has_Cap ("utf8mb4") then
         --             Charset := +"utf8";
         --          end if;

         --          Set (Charsets, Strtolower (-Charset), From_Boolean (True));
         --       end;
         --    end if;

         --    declare
         --       List : List_Type := Explode ("(", Column.Typ);
         --       Typ  : String := -List.First_Element;

         --       Blob : constant List_Type :=
         --         To_List (List => (+"BINARY", +"VARBINARY", +"TINYBLOB",
         --                           +"MEDIUMBLOB", +"BLOB", +"LONGBLOB"));
         --    begin
         --       -- A binary/blob means the whole query gets treated like this.
         --       if In_List (Strtoupper (Typ), Blob, True) then
         --          Set (This.Table_Charset, Tablekey, From_String ("binary"));
         --          return "binary";
         --       end if;
         --    end;
         -- end loop;

         -- utf8mb3 is an alias for utf8.
         if Isset (Charsets, "utf8mb3") then
            Set (Charsets, "utf8", From_Boolean (True));
            Delete (Ref (Charsets, "utf8mb3"));
         end if;

         -- Check if we have more than one charset in play.
         declare
            Count : Count_Type := Charsets.Length;
         begin
            if Count in 1 then
               Charset := +As_String (Charsets.First_Element); -- Key (Charsets);
            elsif Count in 0 then
               -- No charsets, assume this table can store whatever.
               Charset := +""; -- false;
            else
               -- More than one charset. Remove latin1 if present and recalculate.
               Delete (Ref (Charsets, "latin1"));
               Count := Charsets.Length;

               if 1 = Count then
                  -- Only one charset (besides latin1).
                  Charset := +As_String (Charsets.First_Element); -- Key (Charsets);
               elsif
                 Count in 2 and then
                 Isset (Charsets, "utf8") and then
                 Isset (Charsets, "utf8mb4")
               then
                  -- Two charsets, but they're utf8 and utf8mb4, use utf8.
                  Charset := +"utf8";
               else
                  -- Two mixed character sets. ascii.
                  Charset := +"ascii";
               end if;
            end if;
         end;
         Set (This.Table_Charset, Tablekey, From_String (-Charset));
         return -Charset;
      end;
   end Get_Table_Charset;

   ---------------------
   -- Get_Col_Charset --
   ---------------------

   function Get_Col_Charset (This   : in out Wpdb_Class;
                             Table  : String;
                             Column : String)
                             return String
   is
      use Php.Strings;
      use Databases;
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
      if This.Engine not in Engine_MySQL then
--    if not This.Is_MySQL then
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

   function Get_Col_Length (This   : in out Wpdb_Class;
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
      if False then
--    if not This.Is_MySQL then      -- YYY
--    if Empty (This.Is_MySQL) then
         return Empty_Array; -- False;
      end if;

      if Empty (This.Col_Meta, Tablekey) then
--    if Empty (Get_As_String (This.Col_Meta, Tablekey)) then
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

    --------------------------
    -- Check_Safe_Collation --
    --------------------------

   function Check_Safe_Collation (This  : in out Wpdb_Class;
                                  Query : Statement_Type)
                                  return Boolean
   is
      use Ada.Text_IO;
      use Php.Preg;
      use Php.Strings;

      Query_2 : constant Statement_Type :=
        Statement_Type (Ltrim (String (Query), "\r\n\t ("));

      Unused_Matches : List_Type;
   begin
      if This.Checking_Collation then
         return True;
      end if;

      -- We don't need to check the collation for queries that don't read data.
      if
        0 /= Preg_Match ("/^(?:SHOW|DESCRIBE|DESC|EXPLAIN|CREATE)\s/i",
                         String (Query_2), Unused_Matches)
      then
         return True;
      end if;

      -- All-ASCII queries don't need extra checking.
      if This.Check_ASCII (String (Query_2)) then
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

            -- Tables with no collation, or latin1 only, don't need extra checking.
            if "" = Collation or else "latin1" = Collation then -- false =
               return True;
            end if;
         end;

         Table := Strtolower (Table);
         Put_Line ("check_safe_collation :");
         Put_Line ("  " & Table);
         Put_Line (This.Col_Meta'Image);

         if "" = As_String (Get (This.Col_Meta, Table)) then
            return False;
         end if;

         -- If any of the columns don't have one of these collations, it needs
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
      use Databases;
      use Inc_Functions;

      Data_2          : Array_Type := Data;
      DB_Check_String : Boolean    := False;
   begin
      Arrays.IO.Dump (Data_2);
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
                           case This.Engine is
                           when Engine_MySQLi =>
                              Connection_Charset := +"XXX-998";
--                              Mysqli_Character_Set_Name (This.Dbh);
                           when Engine_MySQL =>
                              Connection_Charset := +"XXX-999";
--                              Mysql_Client_Encoding;
                           when Engine_SQLite =>
                              raise Program_Error with "not implemented";
                           end case;
                        end if;

                        if Kind_Of (Get (Value, "length")) = Kind_Array then
                           declare
                              Length : constant String :=
                                Sprintf ("%.0f",
                                         To_List (As_String (Get (Ref_2 (Value,
                                                                Key_1 => "length",
                                                                Key_2 => "length")))));
                           begin
                              Set (Queries, Col, From_String (String (
                                   This.Prepare (
                                     "CONVERT(LEFT(CONVERT(%s USING " &
                                     (-Charset) & "), " & Length &
                                     ") USING " & (-Connection_Charset) &
                                     ")",
                                     To_List (Get_As_String (Value, "value"))
                                   )
                                  )));
                           end;
                        elsif "binary" /= Charset then
                           -- If we don't have a length, there's no need to convert
                           -- binary - it will always return the same result.
                           Set (Queries, Col, From_String (String (
                                This.Prepare (
                                  "CONVERT(CONVERT(%s USING " &
                                  (-Charset) & ") USING " &
                                  (-Connection_Charset) & ")",
                                  To_List (Get_As_String (Value, "value"))
                                )
                               )));
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
                    This.Get_Row
                      (Statement_Type ("SELECT " & Implode (", ", SQL)),
--                     Output  => "ARRAY_A",
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

   -----------------------------------
   -- Strip_Invalid_Text_From_Query --
   -----------------------------------

   function Strip_Invalid_Text_From_Query (This  : Wpdb_Class;
                                           Query : String)
                                           return String
   is
   begin
      return Query;
   end Strip_Invalid_Text_From_Query;
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

   --------------------------
   -- Get_Table_From_Query --
   --------------------------

   function Get_Table_From_Query (This  : Wpdb_Class;
                                  Query : Statement_Type)
                                  return String
   is
      use Ada.Text_IO;
      use Php.Preg;
      use Php.Strings;

      -- Remove characters that can legally trail the table name.
      Query_2 : constant String := Rtrim (String (Query), ";/-#");

      -- Allow (select...) union [...] style queries. Use the first query's table name.
      Query_3 : constant String := Ltrim (Query_2, "\r\n\t (");

      -- Strip everything between parentheses except nested selects.
      Query_4 : constant String :=
        Preg_Replace ("/\((?!\s*select)[^(]*?\)/is", "()", Query_3);

      Maybe : List_Type;
   begin
      Put_Line ("get_table_from_query: ");
      Put_Line ("  query: " & String (Query));

      -- Quickly match most common queries.
      if
        Preg_Match (
          "/^\s*(?:"
          & "SELECT.*?\s+FROM"
          & "|INSERT(?:\s+LOW_PRIORITY|\s+DELAYED|\s+HIGH_PRIORITY)?(?:\s+IGNORE)?(?:\s+INTO)?"
          & "|REPLACE(?:\s+LOW_PRIORITY|\s+DELAYED)?(?:\s+INTO)?"
          & "|UPDATE(?:\s+LOW_PRIORITY)?(?:\s+IGNORE)?"
          & "|DELETE(?:\s+LOW_PRIORITY|\s+QUICK|\s+IGNORE)*(?:.+?FROM)?"
          & ")\s+((?:[0-9a-zA-Z_.`-]|[\xC2-\xDF][\x80-\xBF])+)/is",
          Query_4,
          Maybe) /= 0
      then
         return Str_Replace ("`", "", -Maybe (1)); -- [1]
      end if;

      -- SHOW TABLE STATUS and SHOW TABLES WHERE Name = "wp_posts"
      if
        Preg_Match (
          "/^\s*SHOW\s+(?:TABLE\s+STATUS|(?:FULL\s+)?TABLES).+WHERE\s+Name\s*=\s*('|\')((?:[0-9a-zA-Z_.-]|[\xC2-\xDF][\x80-\xBF])+)\\1/is",
          Query_4, Maybe) /= 0
      then
         return -Maybe (2); -- [2];
      end if;

      --
      -- SHOW TABLE STATUS LIKE and SHOW TABLES LIKE "wp\_123\_%"
      -- This quoted LIKE operand seldom holds a full table name.
      -- It is usually a pattern for matching a prefix so we just
      -- strip the trailing % and unescape the _ to get "wp_123_"
      -- which drop-ins can use for routing these SQL statements.
      --
      if
        Preg_Match (
          "/^\s*SHOW\s+(?:TABLE\s+STATUS|(?:FULL\s+)?TABLES)\s+(?:WHERE\s+Name\s+)?LIKE\s*('|\')((?:[\\\\0-9a-zA-Z_.-]|[\xC2-\xDF][\x80-\xBF])+)%?\\1/is",
          Query_4, Maybe) /= 0
      then
         return Str_Replace ("\\_", "_", -Maybe (2)); -- [2]);
      end if;

      -- Big pattern for the rest of the table-related queries.
      if
        Preg_Match (
          "/^\s*(?:"
          & "(?:EXPLAIN\s+(?:EXTENDED\s+)?)?SELECT.*?\s+FROM"
          & "|DESCRIBE|DESC|EXPLAIN|HANDLER"
          & "|(?:LOCK|UNLOCK)\s+TABLE(?:S)?"
          & "|(?:RENAME|OPTIMIZE|BACKUP|RESTORE|CHECK|CHECKSUM|ANALYZE|REPAIR).*\s+TABLE"
          & "|TRUNCATE(?:\s+TABLE)?"
          & "|CREATE(?:\s+TEMPORARY)?\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?"
          & "|ALTER(?:\s+IGNORE)?\s+TABLE"
          & "|DROP\s+TABLE(?:\s+IF\s+EXISTS)?"
          & "|CREATE(?:\s+\w+)?\s+INDEX.*\s+ON"
          & "|DROP\s+INDEX.*\s+ON"
          & "|LOAD\s+DATA.*INFILE.*INTO\s+TABLE"
          & "|(?:GRANT|REVOKE).*ON\s+TABLE"
          & "|SHOW\s+(?:.*FROM|.*TABLE)"
          & ")\s+\(*\s*((?:[0-9a-zA-Z_.`-]|[\xC2-\xDF][\x80-\xBF])+)\s*\)*/is",
          Query_4,
          Maybe) /= 0
      then
         return Str_Replace ("`", "", -Maybe (1)); -- [1]);
      end if;

      return ""; -- False;
   end Get_Table_From_Query;

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

   ----------
   -- Bail --
   ----------

   procedure Bail (This       : in out Wpdb_Class;
                   Message    : String;
                   Error_Code : String := "500")
   is
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
      use Inc_Functions;
   begin
      if This.Show_Errors then
         declare
            Error : Unbounded_String;
         begin
            case This.Engine is

            when Engine_MySQLi =>
               if True then
--             if This.Dbh in Mysqli then
                  Error := +Mysqli_Error (This.Dbh);
               elsif Mysqli_Connect_Errno  then
                  Error := +Mysqli_Connect_Error;
               end if;

            when Engine_MySQL =>
               if True then
--             if Is_Resource (This.Dbh) then
                  Error := +Mysql_Error (This.Dbh);
               else
                  Error := +Mysql_Error;
               end if;

            when Engine_SQLite =>
               pragma Assert (False);
               Error := +"";
            end case;

            if Error /= "" then
               Wp_Die ("<p><code>" & Error_Code & "</code></p>\n" & Message);
            end if;
         end;
         Wp_Die (Message);

      else
--       if Class_Exists ("WP_Error", False) then
--          This.Error := new Wp_Error (Error_Code, Message);
--       else
         This.Error := +Message;
--       end if;

         return; --  False;
      end if;
   end Bail;

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

   ----------------------------
   -- Check_Database_Version --
   ----------------------------

   function Check_Database_Version (This : Wpdb_Class)
            return Inc_Class_Wp_Errors.Wp_Error
   is
      use Php.Misc;
      use Php.Strings;
      use Inc_Class_Wp_Errors;
      use Inc_L10n;
      use Inc_Versions;
--    global wp_version, required_mysql_version;
   begin
      -- Make sure the server has the required MySQL version.
      if Version_Compare (This.DB_Version, Required_MySQL_Version, "<") then
         -- translators: 1: WordPress version number, 2: Minimum required MySQL version number.
         return X_Construct
           ("database_version",
            Sprintf (abs "<strong>Error:</strong> WordPress %1s requires MySQL %2s or higher",
            To_List (List => (
              1 => +Wp_Version,
              2 => +Required_MySQL_Version
            ))
          ));
      end if;

      return Null_Wp_Error;
   end Check_Database_Version;

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

   -------------------------
   -- Get_Charset_Collate --
   -------------------------

   function Get_Charset_Collate (This : Wpdb_Class)
                                 return String
   is
      use Php.Strings;

      Charset_Collate : Unbounded_String;
   begin
      if not Empty (-This.Charset) then
         Charset_Collate := +"DEFAULT CHARACTER SET " & This.Charset;
      end if;

      if not Empty (-This.Collate) then
         Append (Charset_Collate, " COLLATE " & This.Collate);
      end if;

      return -Charset_Collate;
   end Get_Charset_Collate;

   -------------
   -- Has_Cap --
   -------------

   function Has_Cap (This   : Wpdb_Class;
                     DB_Cap : String)
                     return Boolean
   is
      use Php.Misc;
      use Php.Preg;
      use Php.Strings;
      use MySQL_Bind;
      use MySQLi_Bind;
      use Databases;

      DB_Server_Info_2 : constant String := This.DB_Server_Info;
      DB_Version_2     : constant String := This.DB_Version;

      -- Account for MariaDB version being prefixed with "5.5.5-" on older
      -- PHP versions.
      Is_MariaDB : constant Boolean :=
        "5.5.5" = DB_Version_2                     and then
        Str_Contains (DB_Server_Info_2, "MariaDB") and then
        PHP_VERSION_ID < 80016;      -- PHP 8.0.15 or older.

      DB_Server_Info : constant String :=
        (if Is_MariaDB then
           -- Strip the "5.5.5-" prefix and set the version to the correct value.
           Preg_Replace ("/^5\.5\.5-(.*)/", "$1", DB_Server_Info_2)
         else DB_Server_Info_2);

      DB_Version : constant String :=
        (if Is_MariaDB then
           Preg_Replace ("/[^0-9.].*/", "", DB_Server_Info_2)
         else DB_Server_Info_2);

      DB_Cap_Lower : constant String := Strtolower (DB_Cap);
   begin
      if DB_Cap_Lower in
        "collation"    | -- @since 2.5.0
        "group_concat" | -- @since 2.7.0
        "subqueries"     -- @since 2.7.0
      then
         return Version_Compare (DB_Version, "4.1", ">=");

      elsif DB_Cap_Lower in "set_charset" then
         return Version_Compare (DB_Version, "5.0.7", ">=");

      elsif DB_Cap_Lower in "utf8mb4" then      -- @since 4.1.0
         if Version_Compare (DB_Version, "5.5.3", "<") then
            return False;
         end if;

         declare
            Client_Version : constant String :=
              (case This.Engine is
               when Engine_MySQLi => Mysqli_Get_Client_Info,
               when Engine_MySQL  => Mysql_Get_Client_Info,
               when Engine_SQLite => "10.11.14");
         begin
            --
            -- libmysql has supported utf8mb4 since 5.5.3, same as the MySQL server.
            -- mysqlnd has supported utf8mb4 since 5.0.9.
            --
            if 0 /= Strpos (Client_Version, "mysqlnd") then
               declare
                  Client_Version_2 : constant String :=
                    Preg_Replace ("/^\D+([\d.]+).*/", "1", Client_Version);
               begin
                  return Version_Compare (Client_Version_2, "5.0.9", ">=");
               end;
            else
               return Version_Compare (Client_Version, "5.5.3", ">=");
            end if;
         end;

      elsif DB_Cap_Lower in "utf8mb4_520" then -- @since 4.6.0
         return Version_Compare (DB_Version, "5.6", ">=");
      end if;

      return False;
   end Has_Cap;

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
      use Databases;
      use MySQL_Bind;
      use MySQLi_Bind;
   begin
      return
        (case This.Engine is
         when Engine_MySQLi => MySQLi_Get_Server_Info (This.Dbh),
         when Engine_MySQL  => MySQL_Get_Server_Info (This.Dbh),
         when Engine_SQLite => "10.11.14");
   end DB_Server_Info;

   ---------------
   -- Set_Table --
   ---------------

   procedure Set_Table (This  : in out Wpdb_Class;
                        Table : String;
                        Value : String)
   is
      use Ada.Text_IO;
   begin
      if Table = "options" then
         This.Options := +Value;
      end if;

      Put_Line ("set_table: " & Table);
      pragma Assert (False);
   end Set_Table;

begin
   -- Globals.WpDB.M_Tables.Include ("posts",              "");
   -- Globals.WpDB.M_Tables.Include ("comments",           "");
   -- Globals.WpDB.M_Tables.Include ("links",              "");
   -- Globals.WpDB.M_Tables.Include ("options",            "");
   -- Globals.WpDB.M_Tables.Include ("postmeta",           "");
   -- Globals.WpDB.M_Tables.Include ("terms",              "");
   -- Globals.WpDB.M_Tables.Include ("term_taxonomy",      "");
   -- Globals.WpDB.M_Tables.Include ("term_relationships", "");
   -- Globals.WpDB.M_Tables.Include ("termmeta",           "");
   -- Globals.WpDB.M_Tables.Include ("commentmeta",        "");
   null;
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
end Inc_Class_Wpdb;
