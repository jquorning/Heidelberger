--
-- WordPress Upgrade API
--
-- Most of the functions are pluggable and can be overwritten.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Php.Arrays;
with Php.Files;
with Php.Lists;
with Php.Misc;
with Php.Preg;
with Php.Strings;

with Globals;
with Hb_Common;
with Lists;
with Wp_Common;

with Adi_Schemas;

with Inc_Caches;
with Inc_Class_Wp_Errors;
with Inc_Class_Wp_Users;
with Inc_Class_Wpdb;
with Inc_Formatting;
with Inc_Functions;
with Inc_Load;
with Inc_L10n;
with Inc_Ms_Sites;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Rewrites;
with Inc_Users;
with Inc_Versions;

package body Adi_Upgrade
is
   use Lists;

   ----------------
   -- Wp_Install --
   ----------------

   function Wp_Install (Blog_Title    : String;
                        User_Name     : String;
                        User_Email    : String;
                        Is_Public     : Boolean;
                        Deprecated    : String := "";
                        User_Password : String := "";
                        Language      : String := "")
                        return Arrays.Array_Type
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;
      use Hb_Common;
      use Wp_Common;
      use Adi_Schemas;
      use Inc_Caches;
      use Inc_Class_Wp_Users;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
--    use Inc_Plugins;
      use Inc_Rewrites;
      use Inc_Users;
   begin
      if not Empty (Deprecated) then
         X_Deprecated_Argument ("__FUNCTION__", "2.6.0");
      end if;

      Wp_Check_MySQL_Version;
      Wp_Cache_Flush;
      Make_DB_Current_Silent;
      Populate_Options;
      Populate_Roles;

      Update_Option ("blogname",    From_String  (Blog_Title));
      Update_Option ("admin_email", From_String  (User_Email));
      Update_Option ("blog_public", From_Boolean (Is_Public));

      -- Freshness of site - in the future, this could get more specific about
      -- actions taken, perhaps.
      Update_Option ("fresh_site", From_Integer (1));

      if Language /= "" then
         Update_Option ("WPLANG", From_String (Language));
      end if;

      declare
         Guess_URL : constant String := Wp_Guess_URL;
      begin
         Update_Option ("siteurl", From_String (Guess_URL));

         -- If not a public site, don't ping.
         if not Is_Public then
            Update_Option ("default_pingback_flag", From_Integer (0));
         end if;

         --
         -- Create default user. If the user already exists, the user tables are
         -- being shared among sites. Just set the role in that case.
         --
         declare
            User_Id         : Integer := Username_Exists (User_Name);
            User_Password_2 : constant String  := Trim (User_Password);
            Email_Password  : Boolean := False;
            User_Created    : Boolean := False;

            Message : Unbounded_String;
         begin
            if User_Id = 0 and then Empty (User_Password_2) then
               declare
                  User_Password : constant String := Wp_Generate_Password (12, False);
                  User_Id       : constant Integer :=
                    Wp_Create_User (User_Name, User_Password, User_Email);
               begin
                  Update_User_Meta (User_Id,
                                    "default_password_nag",
                                    Empty_Array); -- True);
               end;
               Message        := +abs "<strong><em>Note that password</em></strong> carefully! It is a <em>random</em> password that was generated just for you.";
               Email_Password := True;
               User_Created   := True;
            elsif User_Id = 0 then
               -- Password has been provided.
               Message      := +"<em>" & abs "Your chosen password." & "</em>";
               User_Id      := Wp_Create_User (User_Name, User_Password, User_Email);
               User_Created := True;
            else
               Message := +abs "User already exists. Password inherited.";
            end if;

            declare
               User : Wp_User := X_Construct (User_Id);
            begin
               User.Set_Role ("administrator");

               if User_Created then
                  User.Prop.User_URL := +Guess_URL;
                  Wp_Update_User (User);
               end if;

               Wp_Install_Defaults (User_Id);

               Wp_Install_Maybe_Enable_Pretty_Permalinks;

               Flush_Rewrite_Rules;

               Wp_New_Blog_Notification
                 (Blog_Title, Guess_URL, User_Id,
                  (if Email_Password then User_Password
                   else abs "The password you chose during installation."));

               Wp_Cache_Flush;

               --
               -- Fires after a site is fully installed.
               --
               -- @since 3.9.0
               --
               -- @param WP_User user The site owner.
               --
               Do_Action ("wp_install", User);

               return
                 To_Array (List => (
                   Build ("url",              Guess_URL),
                   Build ("user_id",          User_Id),
                   Build ("password",         User_Password),
                   Build ("password_message", -Message)
                 ));
            end;
         end;
      end;
   end Wp_Install;

   ----------------
   -- Wp_Upgrade --
   ----------------

   procedure Wp_Upgrade
   is
      use Wp_Common;
      use Inc_Caches;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Ms_Sites;
      use Inc_Versions;
--    global wp_current_db_version, wp_db_version, wpdb;
   begin
      Wp_Current_DB_Version := As_Integer (X_Get_Option ("db_version"));

      -- We are up to date. Nothing to do.
      if Wp_DB_Version = Wp_Current_DB_Version then
         return;
      end if;

      if not Is_Blog_Installed then
         return;
      end if;

      Wp_Check_MySQL_Version;
      Wp_Cache_Flush;
      Pre_Schema_Upgrade;
      Make_DB_Current_Silent;
      Upgrade_All;

      if Is_Multisite and then Is_Main_Site then
         Upgrade_Network;
      end if;

      Wp_Cache_Flush;

      if Is_Multisite then
         Update_Site_Meta (Get_Current_Blog_Id, "db_version",
                           From_Integer (Wp_DB_Version));

         Update_Site_Meta (Get_Current_Blog_Id, "db_last_updated",
                           From_String (Php.Misc.Microtime));
      end if;

      --
      -- Fires after a site is fully upgraded.
      --
      -- @since 3.9.0
      --
      -- @param int wp_db_version         The new wp_db_version.
      -- @param int wp_current_db_version The old (current) wp_db_version.
      --
      Do_Action ("wp_upgrade", Wp_DB_Version, Wp_Current_DB_Version);
   end Wp_Upgrade;

   -----------------
   -- Upgrade_All --
   -----------------

   procedure Upgrade_All
   is
      use Adi_Schemas;
      use Inc_Options;
      use Inc_Versions;
--    global wp_current_db_version, wp_db_version;
   begin
      Wp_Current_DB_Version := As_Integer (X_Get_Option ("db_version"));

      -- We are up to date. Nothing to do.
      if Wp_DB_Version = Wp_Current_DB_Version then
         return;
      end if;

      -- If the version is not set in the DB, try to guess the version.
      if Wp_Current_DB_Version = 0 then -- ???
--    if Empty (Wp_Current_DB_Version) then
         Wp_Current_DB_Version := 0;

         -- If the template option exists, we have 1.5.
         declare
            Template : constant Multi_Type :=
              X_Get_Option ("template");
         begin
            if Kind_Of (Template) /= Kind_Null then
--          if not Empty (Template) then
               Wp_Current_DB_Version := 2541;
            end if;
         end;
      end if;

      if Wp_Current_DB_Version < 6039 then
         Upgrade_230_Options_Table;
      end if;

      Populate_Options;

      if Wp_Current_DB_Version < 2541 then
         Upgrade_100;
         Upgrade_101;
         Upgrade_110;
         Upgrade_130;
      end if;

      if Wp_Current_DB_Version < 3308 then
         Upgrade_160;
      end if;

      if Wp_Current_DB_Version < 4772 then
         Upgrade_210;
      end if;

      if Wp_Current_DB_Version < 4351 then
         Upgrade_Old_Slugs;
      end if;

      if Wp_Current_DB_Version < 5539 then
         Upgrade_230;
      end if;

      if Wp_Current_DB_Version < 6124 then
         Upgrade_230_Old_Tables;
      end if;

      if Wp_Current_DB_Version < 7499 then
         Upgrade_250;
      end if;

      if Wp_Current_DB_Version < 7935 then
         Upgrade_252;
      end if;

      if Wp_Current_DB_Version < 8201 then
         Upgrade_260;
      end if;

      if Wp_Current_DB_Version < 8989 then
         Upgrade_270;
      end if;

      if Wp_Current_DB_Version < 10360 then
         Upgrade_280;
      end if;

      if Wp_Current_DB_Version < 11958 then
         Upgrade_290;
      end if;

      if Wp_Current_DB_Version < 15260 then
         Upgrade_300;
      end if;

      if Wp_Current_DB_Version < 19389 then
         Upgrade_330;
      end if;

      if Wp_Current_DB_Version < 20080 then
         Upgrade_340;
      end if;

      if Wp_Current_DB_Version < 22422 then
         Upgrade_350;
      end if;

      if Wp_Current_DB_Version < 25824 then
         Upgrade_370;
      end if;

      if Wp_Current_DB_Version < 26148 then
         Upgrade_372;
      end if;

      if Wp_Current_DB_Version < 26691 then
         Upgrade_380;
      end if;

      if Wp_Current_DB_Version < 29630 then
         Upgrade_400;
      end if;

      if Wp_Current_DB_Version < 33055 then
         Upgrade_430;
      end if;

      if Wp_Current_DB_Version < 33056 then
         Upgrade_431;
      end if;

      if Wp_Current_DB_Version < 35700 then
         Upgrade_440;
      end if;

      if Wp_Current_DB_Version < 36686 then
         Upgrade_450;
      end if;

      if Wp_Current_DB_Version < 37965 then
         Upgrade_460;
      end if;

      if Wp_Current_DB_Version < 44719 then
         Upgrade_510;
      end if;

      if Wp_Current_DB_Version < 45744 then
         Upgrade_530;
      end if;

      if Wp_Current_DB_Version < 48575 then
         Upgrade_550;
      end if;

      if Wp_Current_DB_Version < 49752 then
         Upgrade_560;
      end if;

      if Wp_Current_DB_Version < 51917 then
         Upgrade_590;
      end if;

      if Wp_Current_DB_Version < 53011 then
         Upgrade_600;
      end if;

      Maybe_Disable_Link_Manager;

      Maybe_Disable_Automattic_Widgets;

      Update_Option ("db_version",  From_Integer (Wp_DB_Version));
      Update_Option ("db_upgraded", From_Boolean (True));
   end Upgrade_All;

   ------------------
   -- X_Get_Option --
   ------------------

   function X_Get_Option (Setting : String)
                          return Arrays.Multi_Type
   is
      use Php.Lists;
      use Hb_Common;
      use Inc_Formatting;
      use Inc_Functions;
   begin
      if "home" = Setting and then Globals.WP_HOME_DEF then
         return From_String (Un_Trailing_Slash_It (Globals.WP_HOME));
      end if;

      if "siteurl" = Setting and then Globals.WP_SITEURL_DEF then
         return From_String (Un_Trailing_Slash_It (Globals.WP_SITEURL));
      end if;

      declare
         Option : constant String :=
           Globals.WpDB.Get_Var (
             Globals.WpDB.Prepare (
               "SELECT option_value FROM " & (-Globals.WpDB.Options) &
               " WHERE option_name = %s", To_List (Setting)));
      begin
         if "home" = Setting and then Option = "" then -- not
            return X_Get_Option ("siteurl");
         end if;

         if
           In_List (Setting, To_List (List => (+"siteurl", +"home",
                                               +"category_base", +"tag_base")), True)
         then
            return Maybe_Unserialize (Un_Trailing_Slash_It (Option));
         end if;

         return Maybe_Unserialize (Option);
      end;
   end X_Get_Option;

   --------------
   -- DB_Delta --
   --------------

   function DB_Delta (Queries : String  := "";
                      Execute : Boolean := True)
                      return Array_Type
   is
      use Ada.Strings.Unbounded;
      use Php.Arrays;
      use Php.Lists;
      use Php.Misc;
      use Php.Preg;
      use Php.Strings;
      use Globals;
      use Hb_Common;
      use Adi_Schemas;
      use Inc_Class_Wpdb;
      use Inc_Plugins;

      List : constant List_Type := To_List (List => (+"", +"all", +"blog",
                                                     +"global", +"ms_global"));
      Queries_2 : constant String :=
         (if In_List (Queries, List, True)
          then Wp_Get_DB_Schema (Queries)
          else Queries);

      -- Separate individual queries into an array.
--      if not Is_Array (Queries) then
      Queries_3 : constant List_Type := Explode (";", Queries_2);
      Queries_4 : constant List_Type := List_Filter (Queries_3);
--      end if;

      --
      -- Filters the dbDelta SQL queries.
      --
      -- @since 3.3.0
      --
      -- @param string[] queries An array of dbDelta SQL queries.
      --
      Queries_5 : constant List_Type :=
        Apply_Filters ("dbdelta_queries", Queries_4);

      C_Queries  : Array_Type; -- Creation queries.
      I_Queries  : Array_Type; -- Insertion queries.
      For_Update : Array_Type;
      Matches    : List_Type;
   begin
      -- Create a tablename index for an array (cqueries) of queries.
      for Qry of Queries_5 loop
         if Preg_Match ("|CREATE TABLE ([^ ]*)|", -Qry, Matches) /= 0 then
            declare
               M : constant String := -Matches (1); -- [1]
            begin
               Set (C_Queries,  Trim (M, "`"), From_String (-Qry));
               Set (For_Update, M,             From_String ("Created table " & M));
            end;

         elsif Preg_Match ("|CREATE DATABASE ([^ ]*)|", -Qry, Matches) /= 0 then
            Array_Unshift (C_Queries, -Qry);

         elsif Preg_Match ("|INSERT INTO ([^ ]*)|", -Qry, Matches) /= 0 then
            I_Queries.Append (From_String (-Qry));

         elsif Preg_Match ("|UPDATE ([^ ]*)|", -Qry, Matches) /= 0 then
            I_Queries.Append (From_String (-Qry));

         else
            null;  -- Unrecognized query type.
         end if;
      end loop;

      --
      -- Filters the dbDelta SQL queries for creating tables and/or databases.
      --
      -- Queries filterable via this hook contain "CREATE TABLE" or
      -- "CREATE DATABASE".
      --
      -- @since 3.3.0
      --
      -- @param string[] cqueries An array of dbDelta create SQL queries.
      --
      C_Queries := Apply_Filters ("dbdelta_create_queries", C_Queries);

      --
      -- Filters the dbDelta SQL queries for inserting or updating.
      --
      -- Queries filterable via this hook contain "INSERT INTO" or "UPDATE".
      --
      -- @since 3.3.0
      --
      -- @param string[] iqueries An array of dbDelta insert or update SQL queries.
      --
      I_Queries := Apply_Filters ("dbdelta_insert_queries", I_Queries);

      declare
         Text_Fields : constant List_Type :=
           To_List (List => (+"tinytext", +"text", +"mediumtext", +"longtext"));

         Blob_Fields : constant List_Type :=
           To_List (List => (+"tinyblob", +"blob", +"mediumblob", +"longblob"));

         Int_Fields  : constant List_Type :=
           To_List (List => (+"tinyint", +"smallint", +"mediumint",
                             +"int", +"integer", +"bigint"));

         Global_Tables  : constant Array_Type := WpDB.Tables ("global");
         DB_Version     : constant String     := WpDB.DB_Version;
         DB_Server_Info : constant String     := WpDB.DB_Server_Info;
      begin
         for A in C_Queries.Iterate loop
            declare
               Table : constant String := Key (A);
               Qry   : constant String := As_String (Element (A));
            begin
               -- Upgrade global tables only for the main site. Don't upgrade at all
               -- if conditions are not optimal.
               if
                 In_Array (Table, Global_Tables, True) and then
                 not Wp_Should_Upgrade_Global_Tables
               then
                  Delete (Ref (C_Queries,  Table));
                  Delete (Ref (For_Update, Table));
                  goto Continue;
               end if;

               declare
                  -- Fetch the table column structure from the database.
                  Suppress : constant Boolean := WpDB.Suppress_Errors;

                  Tablefields : constant Array_Type :=
                    WpDB.Get_Results (Statement_Type ("DESCRIBE " & Table & ";"));
               begin
                  WpDB.Suppress_Errors (Suppress);

                  if Tablefields.Is_Empty then -- not
                     goto Continue;
                  end if;

                  declare
                     -- Clear the field and index arrays.
                     C_Fields                 : Array_Type;
                     Indices                  : List_Type;
                     Indices_Without_Subparts : List_Type;
                     Match_2 : List_Type;
                  begin
                     -- Get all of the field names in the query from between the
                     -- parentheses.
                     Preg_Match ("|\((.*)\)|ms", Qry, Match_2);
                     declare
                        Qryline : constant String := Trim (-Match_2 (1));

                        -- Separate field lines into an array.
                        Flds : constant List_Type := Explode ("\n", Qryline);
                     begin
                        -- For every field line specified in the query.
                        for Fld_0 of Flds loop
                           declare
                              Fld : constant String := Trim (-Fld_0, " \t\n\r\0\x0B,");
                              -- Default trim characters, plus ",".
                              Fvals : List_Type;
                           begin
                              -- Extract the field name.
                              Preg_Match ("|^([^ ]*)|", Fld, Fvals);
                              declare
                                 Fieldname : constant String :=
                                   Trim (-Fvals (1), "`");

                                 Fieldname_Lowercased : constant String :=
                                   Strtolower (Fieldname);

                                 -- Verify the found field name.
                                 Validfield    : Boolean := True;
                                 Index_Matches : Array_Type;
                              begin
                                 if Fieldname_Lowercased in
                                   ""
                                 | "primary"
                                 | "index"
                                 | "fulltext"
                                 | "unique"
                                 | "key"
                                 | "spatial"
                                 then
                                    Validfield := False;

                                    --
                                    -- Normalize the index definition.
                                    --
                                    -- This is done so the definition can be compared
                                    -- against the result of a `SHOW INDEX FROM
                                    -- table_name` query which returns the current
                                    -- table index information.
                                    --

                                    -- Extract type, name and columns from the definition.
                                    -- phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound
                                    -- don't remove regex indentation
                                    Preg_Match (
                                      "/^"
                                      &   "(?P<index_type>"             -- 1) Type of the index.
                                      &       "PRIMARY\s+KEY|(?:UNIQUE|FULLTEXT|SPATIAL)\s+(?:KEY|INDEX)|KEY|INDEX"
                                      &   ")"
                                      &   "\s+"                         -- Followed by at least one white space character.
                                      &   "(?:"                         -- Name of the index. Optional if type is PRIMARY KEY.
                                      &       "`?"                      -- Name can be escaped with a backtick.
                                      &           "(?P<index_name>"     -- 2) Name of the index.
                                      &               "(?:[0-9a-zA-Z_-]|[\xC2-\xDF][\x80-\xBF])+"
                                      &           ")"
                                      &       "`?"                      -- Name can be escaped with a backtick.
                                      &       "\s+"                     -- Followed by at least one white space character.
                                      &   ")*"
                                      &   "\("                          -- Opening bracket for the columns.
                                      &       "(?P<index_columns>"
                                      &           ".+?"                 -- 3) Column names, index prefixes, and orders.
                                      &       ")"
                                      &   "\)"                          -- Closing bracket for the columns.
                                      & "/im",
                                      Fld,
                                      Index_Matches
                                    );

                                    -- phpcs:enable
                                    declare
                                       -- Uppercase the index type and normalize space characters.
                                       Index_Type_2 : constant String :=
                                         Strtoupper (Preg_Replace ("/\s+/", " ", Trim (Get_As_String (Index_Matches, "index_type"))));

                                       -- "INDEX" is a synonym for "KEY", standardize on "KEY".
                                       Index_Type : constant String :=
                                         Str_Replace ("INDEX", "KEY", Index_Type_2);

                                       -- Escape the index name with backticks. An index for a primary key has no name.
                                       Index_Name : constant String :=
                                         (if "PRIMARY KEY" = Index_Type then ""
                                          else "`" & Strtolower (Get_As_String (Index_Matches, "index_name")) & "`");

                                       -- Parse the columns. Multiple columns are
                                       -- separated by a comma.
                                       To_Trim : constant List_Type :=
                                         Explode (",", Get_As_String (Index_Matches, "index_columns"));

                                       Index_Columns : constant Array_Type :=
                                         Array_Map (Trim'Access, To_Trim);

                                       Index_Columns_Without_Subparts : Array_Type :=
                                         Index_Columns;
                                    begin
                                       -- Normalize columns.
                                       for B in Index_Columns.Iterate loop
                                          declare
                                             Id : constant String := Key (B);

                                             Index_Column : constant String :=
                                               As_String (Element (B)); -- &

                                             Index_Column_Matches : Array_Type;
                                          begin
                                             -- Extract column name and number of indexed characters (sub_part).
                                             -- phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound
                                             -- don't remove regex indentation
                                             Preg_Match (
                                               "/"
                                               &   "`?"                      -- Name can be escaped with a backtick.
                                               &       "(?P<column_name>"    -- 1) Name of the column.
                                               &           "(?:[0-9a-zA-Z_-]|[\xC2-\xDF][\x80-\xBF])+"
                                               &       ")"
                                               &   "`?"                      -- Name can be escaped with a backtick.
                                               &   "(?:"                     -- Optional sub part.
                                               &       "\s*"                 -- Optional white space character between name and opening bracket.
                                               &       "\("                  -- Opening bracket for the sub part.
                                               &           "\s*"             -- Optional white space character after opening bracket.
                                               &           "(?P<sub_part>"
                                               &               "\d+"         -- 2) Number of indexed characters.
                                               &           ")"
                                               &           "\s*"             -- Optional white space character before closing bracket.
                                               &       "\)"                  -- Closing bracket for the sub part.
                                               &   ")?"
                                               & "/",
                                               Index_Column,
                                               Index_Column_Matches
                                             );

                                             -- phpcs:enable
                                             declare
                                                -- Escape the column name with backticks.
                                                Index_Column : Unbounded_String :=
                                                  +("`" & Get_As_String (Index_Column_Matches, "column_name") & "`");
                                             begin
                                                -- We don't need to add the subpart to index_columns_without_subparts
                                                Set (Index_Columns_Without_Subparts, Id,
                                                     From_String (-Index_Column));

                                                -- Append the optional sup part with the number of indexed characters.
                                                if Isset (Index_Column_Matches, "sub_part") then
                                                   Append (Index_Column, "(" & Get_As_String (Index_Column_Matches, "sub_part") & ")");
                                                end if;
                                             end;
                                          end;
                                       end loop;

                                       -- Build the normalized index definition and add
                                       -- it to the list of indices.
                                       Append (Indices,
                                               Index_Type & " " & Index_Name &
                                               " (" & Implode (",", Index_Columns) & ")");

                                       Append (Indices_Without_Subparts,
                                               Index_Type & " " & Index_Name &
                                               " (" & Implode (",", Index_Columns_Without_Subparts) & ")");

                                       -- Destroy no longer needed variables.
                                       -- unset( index_column, index_column_matches, index_matches, index_type, index_name, index_columns, index_columns_without_subparts );

                                       -- Break;
                                    end;

                                 end if; -- case;

                                 -- If it's a valid field, add it to the field array.
                                 if Validfield then
                                    Set (C_Fields, Fieldname_Lowercased,
                                         From_String (Fld));
                                 end if;
                              end;
                           end;
                        end loop;
                     end;

                     -- For every field in the table.
                     for Tablefield_0 in Tablefields.Iterate loop
                        declare
                           Tablefield : constant Array_Type :=
                             As_Array (Element (Tablefield_0));

                           Tablefield_Field_Lowercased : constant String :=
                             Strtolower (Get_As_String (Tablefield, "Field"));

                           Tablefield_Type_Lowercased : constant String :=
                             Strtolower (Get_As_String (Tablefield, "Type"));

                           Tablefield_Type_Without_Parentheses : constant String :=
                             Preg_Replace (
                               "/"
                               & "(.+)"       -- Field type, e.g. `int`.
                               & "\(\d*\)"    -- Display width.
                               & "(.*)"       -- Optional attributes, e.g. `unsigned`.
                               & "/",
                               "12",
                               Tablefield_Type_Lowercased
                             );

                           -- Get the type without attributes, e.g. `int`.
                           Tablefield_Type_Base : constant String :=
                             Strtok (Tablefield_Type_Without_Parentheses, " ");
                        begin
                           -- If the table field exists in the field array...
                           if Array_Key_Exists (Tablefield_Field_Lowercased, C_Fields) then
                              declare
                                 Matches : List_Type;
                              begin
                                 -- Get the field type from the query.
                                 Preg_Match
                                   ("|`?" & Get_As_String (Tablefield, "Field") & "`? ([^ ]*( unsigned)?)|i",
                                    Get_As_String (C_Fields, Tablefield_Field_Lowercased), Matches);
                                 declare
                                    Fieldtype : constant String := -Matches (1);

                                    Fieldtype_Lowercased : constant String :=
                                      Strtolower (Fieldtype);

                                    Fieldtype_Without_Parentheses : constant String :=
                                      Preg_Replace (
                                        "/"
                                        & "(.+)"       -- Field type, e.g. `int`.
                                        & "\(\d*\)"    -- Display width.
                                        & "(.*)"       -- Optional attributes, e.g. `unsigned`.
                                        & "/",
                                        "12",
                                        Fieldtype_Lowercased
                                      );

                                    -- Get the type without attributes, e.g. `int`.
                                    Fieldtype_Base : constant String :=
                                      Strtok (Fieldtype_Without_Parentheses, " ");
                                 begin
                                    -- Is actual field type different from the field
                                    -- type in query?
                                    if Get_As_String (Tablefield, "Type") /= Fieldtype then
                                       declare
                                          Do_Change : Boolean := True;
                                       begin
                                          if
                                            In_List (Fieldtype_Lowercased, Text_Fields, True) and then
                                            In_List (Tablefield_Type_Lowercased, Text_Fields, True)
                                          then
                                             if
                                               List_Search (Fieldtype_Lowercased, Text_Fields, True) <
                                               List_Search (Tablefield_Type_Lowercased, Text_Fields, True)
                                             then
                                                Do_Change := False;
                                             end if;
                                          end if;

                                          if
                                            In_List (Fieldtype_Lowercased, Blob_Fields, True) and then
                                            In_List (Tablefield_Type_Lowercased, Blob_Fields, True)
                                          then
                                             if
                                               List_Search (Fieldtype_Lowercased, Blob_Fields, True) <
                                               List_Search (Tablefield_Type_Lowercased, Blob_Fields, True)
                                             then
                                                Do_Change := False;
                                             end if;
                                          end if;

                                          if
                                            In_List (Fieldtype_Base, Int_Fields, True) and then
                                            In_List (Tablefield_Type_Base, Int_Fields, True) and then
                                            Fieldtype_Without_Parentheses = Tablefield_Type_Without_Parentheses
                                          then
                                             --
                                             -- MySQL 8.0.17 or later does not support display width for integer data types,
                                             -- so if display width is the only difference, it can be safely ignored.
                                             -- Note: This is specific to MySQL and does not affect MariaDB.
                                             --
                                             if
                                               Version_Compare (DB_Version, "8.0.17", ">=") and then
                                               not Str_Contains (DB_Server_Info, "MariaDB")
                                             then
                                                Do_Change := False;
                                             end if;
                                          end if;

                                          if Do_Change then
                                             -- Add a query to change the column type.
                                             C_Queries.Append (From_String (
                                               "ALTER TABLE " & Table &
                                               " CHANGE COLUMN `" & Get_As_String (Tablefield, "Field") & "` " &
                                               Get_As_String (C_Fields, Tablefield_Field_Lowercased)));

                                             Set (For_Update,
                                                  Table & "." & Get_As_String (Tablefield, "Field"),
                                                  From_String (
                                                  "Changed type of " & Table & "." & Get_As_String (Tablefield, "Field") &
                                                  " from " & Get_As_String (Tablefield, "Type") & " to " & Fieldtype));
                                          end if;
                                       end;
                                    end if;

                                    -- Get the default value from the array.
                                    if
                                      Preg_Match ("| DEFAULT '(.*?)'|i",
                                                  Get_As_String (C_Fields, Tablefield_Field_Lowercased), Matches) /= 0
                                    then
                                       declare
                                          Default_Value : constant String :=
                                            -Matches (1);
                                       begin
                                          if Get_As_String (Tablefield, "Default") /= Default_Value then
                                             -- Add a query to change the column's
                                             -- default value
                                             C_Queries.Append (From_String (
                                               "ALTER TABLE " & Table &
                                               " ALTER COLUMN `" & Get_As_String (Tablefield, "Field") &
                                               "` SET DEFAULT '" & Default_Value & "'"));

                                             Set (For_Update,
                                                  Table & "." & Get_As_String (Tablefield, "Field"),
                                                  From_String (
                                                  "Changed default value of " & Table & "." & Get_As_String (Tablefield, "Field") &
                                                  " from " & Get_As_String (Tablefield, "Default") & " to " & Default_Value));
                                          end if;
                                       end;
                                    end if;

                                    -- Remove the field from the array (so it's not
                                    -- added).
                                    Delete (Ref (C_Fields, Tablefield_Field_Lowercased));
                                 end;
                              end;
                           else
                              null;
                              -- This field exists in the table, but not in the
                              -- creation queries?
                           end if;
                        end;
                     end loop;

                     -- For every remaining field specified for the table.
                     for E in C_Fields.Iterate loop
                        declare
                           Fieldname : constant String := Key (E);
                           Fielddef  : constant String := As_String (Element (E));
                        begin
                           -- Push a query line into cqueries that adds the field to
                           -- that table.
                           C_Queries.Append (From_String (
                             "ALTER TABLE " & Table & " ADD COLUMN " & Fielddef));

                           Set (For_Update,
                                Table & "." & Fieldname,
                                From_String (
                                  "Added column " & Table & "." & Fieldname));
                        end;
                     end loop;

                     -- Index stuff goes here. Fetch the table index structure from
                     -- the database.
                     declare
                        Tableindices : constant Array_Type :=
                          WpDB.Get_Results (Statement_Type (
                            "SHOW INDEX FROM " & Table & ";"));
                     begin
                        if not Tableindices.Is_Empty then
                           declare
                              -- Clear the index array.
                              Index_Ary : Array_Type;
                           begin
                              -- For every index in the table.
                              for Tableindex_0 in Tableindices.Iterate loop
                                 declare
                                    Tableindex : constant Array_Type :=
                                      As_Array (Element (Tableindex_0));

                                    Keyname : constant String :=
                                      Strtolower (Get_As_String (Tableindex, "Key_Name"));
                                 begin
                                    -- Add the index to the index data array.
                                    Append_2
                                      (Index_Ary,
                                       Key_1 => Keyname,
                                       Key_2 => "columns",
                                       Value => From_Array (To_Array (List => (
                                         Build ("fieldname", Get_As_String (Tableindex, "Column_Name")),
                                         Build ("subpart",   Get_As_String (Tableindex, "Sub_Part"))
                                       )))
                                      );

                                    Set_2 (Index_Ary, Keyname, "unique",
                                           Value => From_Boolean
                                                    (if "0" = Get_As_String (Tableindex, "Non_Unique")
                                                     then True else False));
                                    Set_2 (Index_Ary, Keyname, "index_type",
                                           Value => From_String (
                                             Get_As_String (Tableindex, "Index_Type")));
                                 end;
                              end loop;

                              -- For each actual index in the index array.
                              for F in Index_Ary.Iterate loop
                                 declare
                                    Index_Name : constant String := Key (F);

                                    Index_Data : constant Array_Type :=
                                      As_Array (Element (F));

                                    Index_String  : Unbounded_String;
                                    Index_Columns : Unbounded_String;
                                 begin
                                    -- Build a create string to compare to the query.
                                    if "primary" = Index_Name then
                                       Append (Index_String, "PRIMARY ");

                                    elsif Get_As_String (Index_Data, "unique") /= "" then
                                       Append (Index_String, "UNIQUE ");
                                    end if;

                                    if "FULLTEXT" = Strtoupper (Get_As_String (Index_Data, "index_type")) then
                                       Append (Index_String, "FULLTEXT ");
                                    end if;

                                    if "SPATIAL" = Strtoupper (Get_As_String (Index_Data, "index_type")) then
                                       Append (Index_String, "SPATIAL ");
                                    end if;

                                    Append (Index_String, "KEY ");
                                    if "primary" /= Index_Name then
                                       Append (Index_String, "`" & Index_Name & "`");
                                    end if;

                                    -- For each column in the index.
                                    for
                                      Column_Data_0 in
                                      As_Array (Get (Index_Data, "columns")).Iterate
                                    loop
                                       declare
                                          Column_Data : constant Multi_Type :=
                                            Element (Column_Data_0);
                                       begin
                                          if "" /= Index_Columns then
                                             Append (Index_Columns, ",");
                                          end if;

                                          -- Add the field to the column list string.
                                          Append (Index_Columns,
                                                  String'("`" & Get_As_String (As_Array (Column_Data), "fieldname") & "`"));
                                       end;
                                    end loop;

                                    -- Add the column list to the index create string.
                                    Append (Index_String, " (" & Index_Columns & ")");

                                    -- Check if the index definition exists, ignoring
                                    -- subparts.
                                    declare
                                       A_Index : constant String :=
                                         List_Search (-Index_String, Indices_Without_Subparts, True);
                                    begin
                                       if A_Index /= "" then
--                                     if False /= A_Index then
                                          -- If the index already exists (even with
                                          -- different subparts), we don't need to
                                          -- create it.
                                          null;
--                                        Delete (Ref (Indices_Without_Subparts, A_Index));
--                                        Delete (Ref (Indices, A_Index));
                                       end if;
                                    end;
                                 end;
                              end loop;
                           end;
                        end if;

                        -- For every remaining index specified for the table.
                        for Index of Indices loop -- (array)
                           -- Push a query line into cqueries that adds the index to that table.
                           C_Queries.Append (From_String (
                             -("ALTER TABLE " & Table & " ADD " & Index)));

                           For_Update.Append (From_String (
                             -("Added " & Index & " " & Table & " " & Index)));
                        end loop;

                        -- Remove the original table creation query from processing.
                        Delete (Ref (C_Queries,  Table));
                        Delete (Ref (For_Update, Table));
                     end;
                  end;
               end;
            end;
            << Continue >>
         end loop;

         declare
            All_Queries : constant Array_Type :=
              Array_Merge (C_Queries, I_Queries);
         begin
            if Execute then
               for Q in All_Queries.Iterate loop
                  declare
                     Query : constant Multi_Type := Element (Q);
                  begin
                     WpDB.Query (Statement_Type (As_String (Query)));
                  end;
               end loop;
            end if;
         end;

         return For_Update;
      end;
   end DB_Delta;

   ----------------------------
   -- Make_DB_Current_Silent --
   ----------------------------

   procedure Make_DB_Current_Silent (Tables : String := "all")
   is
      Unused : constant Array_Type := DB_Delta (Tables);
   begin
      null;
   end Make_DB_Current_Silent;

   ----------------------------
   -- Wp_Check_MySQL_Version --
   ----------------------------

   procedure Wp_Check_MySQL_Version
   is
      use Inc_Class_Wp_Errors;
      use Inc_Functions;
      use Inc_Load;

      Result : constant Wp_Error :=
        Globals.WpDB.Check_Database_Version;
   begin
      if Is_Wp_Error (Result) then
         Wp_Die (Result.Get_Error_Code); -- Get_Error_Code added
      end if;
   end Wp_Check_MySQL_Version;

   --------------------------------------
   -- Maybe_Disable_Automattic_Widgets --
   --------------------------------------

   procedure Maybe_Disable_Automattic_Widgets
   is
      use Php.Arrays;
      use Php.Files;
      use Hb_Common;
      use Inc_Options;

      Plugins : constant List_Type := Empty_List;  -- ???
--      As_List (X_Get_Option ("active_plugins"));
   begin
      for Plugin of Plugins loop -- (array)
         if "widgets.php" = Basename (-Plugin) then
--          Array_Splice (Plugins, Array_Search (-Plugin, Plugins, True), 1); -- ???
            Update_Option ("active_plugins", From_List (Plugins));
            exit;
         end if;
      end loop;
   end Maybe_Disable_Automattic_Widgets;

   --------------------------------
   -- Maybe_Disable_Link_Manager --
   --------------------------------

   procedure Maybe_Disable_Link_Manager
   is
      use Globals;
      use Inc_Options;
--    global wp_current_db_version, wpdb;
   begin
      if
        Wp_Current_DB_Version >= 22006 and then
        Get_Option ("link_manager_enabled") and then
        "" = WpDB.Get_Var ("SELECT link_id FROM wpdb->links LIMIT 1") -- not
      then
         Update_Option ("link_manager_enabled", From_Integer (0));
      end if;
   end Maybe_Disable_Link_Manager;

   -----------------------
   -- Pre_Scema_Upgrade --
   -----------------------

   procedure Pre_Schema_Upgrade
   is
      use Globals;
      use Hb_Common;
      use Inc_Class_Wpdb;
      use Inc_Load;
--    global wp_current_db_version, wpdb;
   begin
      -- Upgrade versions prior to 2.9.
      if Wp_Current_DB_Version < 11557 then
         -- Delete duplicate options. Keep the option with the highest option_id.
         WpDB.Query ("DELETE o1 FROM wpdb->options AS o1 JOIN wpdb->options AS o2 USING (`option_name`) WHERE o2.option_id > o1.option_id");

         -- Drop the old primary key and add the new.
         WpDB.Query ("ALTER TABLE wpdb->options DROP PRIMARY KEY, ADD PRIMARY KEY(option_id)");

         -- Drop the old option_name index. dbDelta() Doesn't do the drop.
         WpDB.Query ("ALTER TABLE wpdb->options DROP INDEX option_name");
      end if;

      -- Multisite schema upgrades.
      if
        Wp_Current_DB_Version < 25448 and then
        Is_Multisite and then
        Wp_Should_Upgrade_Global_Tables
      then
         -- Upgrade versions prior to 3.7.
         if Wp_Current_DB_Version < 25179 then
            -- New primary key for signups.
            WpDB.Query ("ALTER TABLE wpdb->signups ADD signup_id BIGINT(20) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST");
            WpDB.Query ("ALTER TABLE wpdb->signups DROP INDEX domain");
         end if;

         if Wp_Current_DB_Version < 25448 then
            -- Convert archived from enum to tinyint.
            WpDB.Query ("ALTER TABLE wpdb->blogs CHANGE COLUMN archived archived varchar(1) NOT NULL default '0'");
            WpDB.Query ("ALTER TABLE wpdb->blogs CHANGE COLUMN archived archived tinyint(2) NOT NULL default 0");
         end if;
      end if;

      -- Upgrade versions prior to 4.2.
      if Wp_Current_DB_Version < 31351 then
         if
           not Is_Multisite and then
           Wp_Should_Upgrade_Global_Tables
         then
            WpDB.Query ("ALTER TABLE wpdb->usermeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         end if;
         WpDB.Query ("ALTER TABLE wpdb->terms DROP INDEX slug, ADD INDEX slug(slug(191))");
         WpDB.Query ("ALTER TABLE wpdb->terms DROP INDEX name, ADD INDEX name(name(191))");
         WpDB.Query ("ALTER TABLE wpdb->commentmeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         WpDB.Query ("ALTER TABLE wpdb->postmeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
         WpDB.Query ("ALTER TABLE wpdb->posts DROP INDEX post_name, ADD INDEX post_name(post_name(191))");
      end if;

      -- Upgrade versions prior to 4.4.
      if Wp_Current_DB_Version < 34978 then
         -- If compatible termmeta table is found, use it, but enforce a proper
         -- index and update collation.
         if
           "" /= WpDB.Get_Var
             (Statement_Type ("SHOW TABLES LIKE '" & (-WpDB.Termmeta) & "'"))
         and then
           WpDB.Get_Results (Statement_Type (
             "SHOW INDEX FROM " & (-WpDB.Termmeta) &
             " WHERE Column_name = 'meta_key'")) /= Empty_Array
         then
            WpDB.Query ("ALTER TABLE wpdb->termmeta DROP INDEX meta_key, ADD INDEX meta_key(meta_key(191))");
            Maybe_Convert_Table_To_Utf8mb4 (-WpDB.Termmeta);
         end if;
      end if;
   end Pre_Schema_Upgrade;

   -------------------------------------
   -- Wp_Should_Upgrade_Global_Tables --
   -------------------------------------

   function Wp_Should_Upgrade_Global_Tables
            return Boolean
   is
      use Inc_Functions;
      use Inc_Plugins;

      -- Assume global tables should be upgraded.
      Should_Upgrade : Boolean := True;
   begin
      -- Return false early if explicitly not upgrading.
      if Globals.DO_NOT_UPGRADE_GLOBAL_TABLES then
         return False;
      end if;

      -- Set to false if not on main network (does not matter if not multi-network).
      if not Is_Main_Network then
         Should_Upgrade := False;
      end if;

      -- Set to false if not on main site of current network (does not matter if
      -- not multi-site).
      if not Is_Main_Site then
         Should_Upgrade := False;
      end if;

      --
      -- Filters if upgrade routines should be run on global tables.
      --
      -- @since 4.3.0
      --
      -- @param bool should_upgrade Whether to run the upgrade routines on
      -- global tables.
      --
      return Apply_Filters ("wp_should_upgrade_global_tables", Should_Upgrade);
   end Wp_Should_Upgrade_Global_Tables;

end Adi_Upgrade;
