--
-- Option API
--
-- @package WordPress
-- @subpackage Option
--

with Ada.Strings.Unbounded;
with Ada.Text_IO;

with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Binder;
with Globals;
with UStrings;
with Helpers;
with Wp_Common;

with Inc_Caches;
with Class_WpDB;
with Inc_Formatting;
with Inc_Functions;
with Inc_Load;
with Inc_Link_Templates;
with Inc_L10n;
with Inc_Plugins;
with Inc_Users;

package body Inc_Options
is

   ----------------
   -- Get_Option --
   ----------------

   function Get_Option (Option  : String;
                        Default : Multi_Type := From_String (""))
                        return Multi_Type -- String
   is
      use Php.Lists;
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Wp_Common;
      use Inc_Caches;
      use Class_WpDB;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Load;
--    use Inc_Plugins;

      -- Distinguish between `false` as a default, and not passing one.
      Passed_Default : constant Boolean :=
        Kind_Of (Default) in Kind_String and then As_String (Default) /= "";
      -- Func_Num_Args > 1; -- ()

      Value : Multi_Type;
   begin
      Ada.Text_IO.Put_Line ("Get_Option: " & Option);
      -- if Option = "html_type" then
      --    return "text/html";
      -- elsif Option = "blog_charset" then
      --    return "UTF-8";
      -- else
      --    return "XXX-222";
      -- end if;

      -- if ( is_scalar( option ) ) then
      --    option = trim( option );
      -- end if;

      -- if ( empty( option ) ) then
      --    return ""; -- False;
      -- end if;

      --
      -- Until a proper _deprecated_option() function can be introduced,
      -- redirect requests to deprecated keys to the new, correct ones.
      --
      declare
         Deprecated_Keys : constant Array_Type := To_Array (List => (
           Build ("blacklist_keys",    "disallowed_keys"),
           Build ("comment_whitelist", "comment_previously_approved")
         ));
      begin
         if
           Isset (Deprecated_Keys, Option) and then
           not Wp_Installing
         then
            X_Deprecated_Argument (
              "__FUNCTION__",
              "5.5.0",
              Sprintf (
                -- translators: 1: Deprecated option key, 2: New option key.
                abs "The ""%1s"" option key has been renamed to ""%2s"".",
                To_List (List => (
                  1 => +Option,
                  2 => +Get_As_String (Deprecated_Keys, Option)
                ))
              )
            );
            return Get_Option (Get_As_String (Deprecated_Keys, Option), Default);
         end if;
      end;

      --
      -- Filters the value of an existing option before it is retrieved.
      --
      -- The dynamic portion of the hook name, `option`, refers to the option name.
      --
      -- Returning a value other than false from the filter will short-circuit
      -- retrieval and return that value instead.
      --
      -- @since 1.5.0
      -- @since 4.4.0 The `option` parameter was added.
      -- @since 4.9.0 The `default` parameter was added.
      --
      -- @param mixed  pre_option The value to return instead of the option value.
      --                           This differs from `default`, which is used as the
      --                           fallback value in the event the option doesn"t
      --                           exist elsewhere in get_option().
      --                           Default false (to skip past the short-circuit).
      -- @param string option     Option name.
      -- @param mixed  default    The fallback value to return if the option does not
      --                           exist. Default false.
      --
      declare
         Pre_2 : constant Multi_Type :=
           Apply_Filters ("pre_option_" & Option, From_Boolean (False),
                          Option, Default);

         --
         -- Filters the value of all existing options before it is retrieved.
         --
         -- Returning a truthy value from the filter will effectively short-circuit
         -- retrieval and return the passed value instead.
         --
         -- @since 6.1.0
         --
         -- @param mixed  pre_option  The value to return instead of the option value.
         --                            This differs from `default`, which is used as
         --                            the fallback value in the event the option
         --                            doesn't exist elsewhere in get_option().
         --                            Default false (to skip past the short-circuit).
         -- @param string option      Name of the option.
         -- @param mixed  default     The fallback value to return if the option does
         --                            not exist. Default false.
         --
         Pre : constant Multi_Type :=
           Apply_Filters ("pre_option", Pre_2, Option, Default);
      begin
         if From_Boolean (False) /= Pre then
            return Pre;
         end if;
      end;

      -- if Defined ("WP_SETUP_CONFIG") then
      --    return false;
      -- end if;

      if not Wp_Installing then
         declare
            Found : Boolean;
            -- Prevent non-existent options from triggering multiple queries.
            Notoptions : Array_Type := Wp_Cache_Get ("notoptions", "options",
                                                     Found => Found);
         begin
            -- Prevent non-existent `notoptions` key from triggering multiple
            -- key lookups.
            if not Is_Array (Notoptions) then
               Notoptions := Empty_Array;
               Wp_Cache_Set ("notoptions", Notoptions, "options");
            end if;

            if Isset (Notoptions, Option) then
               --
               -- Filters the default value for an option.
               --
               -- The dynamic portion of the hook name, `option`, refers to the
               -- option name.
               --
               -- @since 3.4.0
               -- @since 4.4.0 The `option` parameter was added.
               -- @since 4.7.0 The `passed_default` parameter was added to distinguish
               --              between a `false` value and the default parameter value.
               --
               -- @param mixed  default The default value to return if the option does
               --                        not exist in the database.
               -- @param string option  Option name.
               -- @param bool   passed_default Was `get_option()` passed a default
               --                               value?
               --
               return
                 Apply_Filters ("default_option_" & Option,
                                Default, Option, Passed_Default);
            end if;

            declare
               Alloptions : constant Array_Type := Wp_Load_Alloptions;
               Found      : Boolean;
            begin
               if Isset (Alloptions, Option) then
                  Value := Get (Alloptions, Option);
               else
                  Value := Wp_Cache_Get (Option, "options", Found => Found);

                  if From_Boolean (False) = Value then
                     declare
                        Success : Boolean;

                        Statement : constant Statement_Type :=
                          Globals.WpDB.Prepare (
                            "SELECT option_value"              &
                            " FROM " & (-Globals.WpDB.Options) &
                            " WHERE option_name = %s LIMIT 1",
                            To_List (Option));

                        Row : constant Array_Type :=
                          Globals.WpDB.Get_Row (Statement, Success => Success);
                     begin
                        -- Has to be get_row() instead of get_var() because of
                        -- funkiness with 0, false, null values.
                        if Is_Object (Row) then
--                         Value := Row.Option_Value;
                           Wp_Cache_Add (Option, Value, "options");

                        else
                           -- Option does not exist, so we must cache its
                           -- non-existence.
                           if not Is_Array (Notoptions) then
                              Notoptions := Empty_Array;
                           end if;

                           Set (Notoptions, Option, From_Boolean (True));
                           Wp_Cache_Set ("notoptions", Notoptions, "options");

                           -- This filter is documented in wp-includes/option.php
                           return
                             Apply_Filters ("default_option_" & Option,
                                            Default, Option, Passed_Default);
                        end if;
                     end;
                  end if;
               end if;
            end;
         end; --  if;

      else
         declare
            Success  : Boolean;
            Suppress : constant Boolean := Globals.WpDB.Suppress_Errors; -- ();

            Statement : constant Statement_Type :=
              Globals.WpDB.Prepare (
                "SELECT option_value FROM " & (-Globals.WpDB.Options) & " " &
                "WHERE option_name = %s LIMIT 1", To_List (Option));

            Row : constant Array_Type :=
              Globals.WpDB.Get_Row (Statement, Success => Success);

         begin
            Globals.WpDB.Suppress_Errors (Suppress);

            if Is_Object (Row) then
               null;
--             Value := Row.Option_Value;
               Value := Get (Row, "option_value");
            else
               -- This filter is documented in wp-includes/option.php
               return
                 Apply_Filters ("default_option_" & Option,
                                Default, Option, Passed_Default);
            end if;
         end;
      end if;

      -- If home is not set, use siteurl.
      if "home" = Option and then "" = As_String (Value) then
         return Get_Option ("siteurl");
      end if;

      if
        In_List (Option, To_List (List => (+"siteurl", +"home", +"category_base",
                                           +"tag_base")), True)
      then
         Value := From_String (Un_Trailing_Slash_It (As_String (Value)));
      end if;

      --
      -- Filters the value of an existing option.
      --
      -- The dynamic portion of the hook name, `option`, refers to the option name.
      --
      -- @since 1.5.0 As "option_" . setting
      -- @since 3.0.0
      -- @since 4.4.0 The `option` parameter was added.
      --
      -- @param mixed  value  Value of the option. If stored serialized, it will be
      --                       unserialized prior to being returned.
      -- @param string option Option name.
      --
      return Apply_Filters ("option_" & Option,
                            Maybe_Unserialize (As_String (Value)), Option);
   end Get_Option;

   ----------------
   -- Get_Option --
   ----------------

   function Get_Option (Option  : String;
                        Default : Array_Type := Empty_Array)
                        return Array_Type
   is
      Result : constant Multi_Type :=
        Get_Option (Option, From_Array (Default));
   begin
      case Kind_Of (Result) is
      when Kind_Null   =>  return Empty_Array;
      when Kind_Array  =>  return Empty_Array;
      when Kind_String =>  return Empty_Array;
      when others =>
         null;
      end case;
      return As_Array (Result);
   end Get_Option;

   ----------------
   -- Get_Option --
   ----------------

   function Get_Option (Option  : String;
                        Default : String := "")
                        return List_Type
   is
      Result : constant Multi_Type :=
        Get_Option (Option, From_String (Default));
   begin
      return As_List (Result);
   end Get_Option;

   ----------------
   -- Get_Option --
   ----------------

   function Get_Option (Option  : String;
                        Default : Integer := 0)
                        return Integer
   is
      Result : constant Multi_Type :=
        Get_Option (Option, From_Integer (Default));
   begin
      return As_Integer (Result);
   end Get_Option;

   ----------------
   -- Get_Option --
   ----------------

   function Get_Option (Option  : String;
                        Default : String := "")
                        return String
   is
      Result : constant Multi_Type :=
        Get_Option (Option, From_String (Default));
   begin
      return As_String (Result);
   end Get_Option;

   ----------------
   -- Get_Option --
   ----------------

   function Get_Option (Option  : String;
                        Default : String := "")
                        return Boolean
   is
      Result : constant Multi_Type :=
        Get_Option (Option, From_String (Default));
   begin
      return As_Boolean (Result);
   end Get_Option;

   -------------------------------
   -- Wp_Protect_Special_Option --
   -------------------------------

   procedure Wp_Protect_Special_Option (Option : String)
   is
      use Php.Strings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
   begin
      if Option in "alloptions" | "notoptions" then
         Wp_Die (
           Sprintf (
             -- translators: %s: Option name.
             abs "%s is a protected WP option and may not be modified",
             To_List (ESC_HTML (Option))
           )
         );
      end if;
   end Wp_Protect_Special_Option;

-- --
-- -- Prints option value after sanitizing for forms.
-- --
-- -- @since 1.5.0
-- --
-- -- @param string option Option name.
-- --
-- function form_option( option ) then
--         echo esc_attr( get_option( option ) );
-- end;

   ------------------------
   -- Wp_Load_Alloptions --
   ------------------------

   function Wp_Load_Alloptions (Force_Cache : Boolean := False)
            return Array_Type
   is
      use UStrings;
      use Inc_Caches;
      use Class_WpDB;
      use Inc_Load;
      use Inc_Plugins;

      Unused_Found : Boolean;
      Alloptions   : Array_Type;
   begin
      if not Wp_Installing or else not Is_Multisite then
         Alloptions :=
           Wp_Cache_Get ("alloptions", "options", Force_Cache, Unused_Found);
      else
         Alloptions := Empty_Array; -- false;
      end if;

      if Alloptions.Is_Empty then
         declare
            Unused   : Boolean;
            Suppress : constant Boolean := Globals.WpDB.Suppress_Errors;

            Alloptions_DB : Array_Type :=
              Globals.WpDB.Get_Results (Statement_Type (
                "SELECT option_name, option_value FROM " &
                (-Globals.WpDB.Options) & " WHERE autoload = ""yes"""));
         begin
            if Alloptions_DB.Is_Empty then
               Alloptions_DB := Globals.WpDB.Get_Results (Statement_Type (
                 "SELECT option_name, option_value FROM " &
                 (-Globals.WpDB.Options) & ""));
            end if;

            Unused := Globals.WpDB.Suppress_Errors (Suppress);

            Alloptions := Empty_Array;
            for A in Alloptions_DB.Iterate loop
               declare
                  Arry : constant Array_Type := As_Array (Element (A));

                  Option_Name  : constant String :=
                    As_String (Get (Arry, "option_name"));

                  Option_Value : constant String :=
                    As_String (Get (Arry, "option_value"));
               begin
                  Set (Alloptions, Option_Name,
                       Value => From_String (Option_Value));
               end;
--             Alloptions (A.Option_Name) := A.Option_Value;
            end loop;

            if not Wp_Installing or else not Is_Multisite then
               --
               -- Filters all options before caching them.
               --
               -- @since 4.9.0
               --
               -- @param array alloptions Array with all options.
               --
               Alloptions := Apply_Filters ("pre_cache_alloptions", Alloptions);

               Wp_Cache_Add ("alloptions", From_Array (Alloptions), "options",
                             Success => Unused);
            end if;
         end;
      end if;

      --
      -- Filters all options after retrieving them.
      --
      -- @since 4.9.0
      --
      -- @param array alloptions Array with all options.
      --
      return Apply_Filters ("alloptions", Alloptions);
   end Wp_Load_Alloptions;

-- --
-- -- Loads and caches certain often requested site options if is_multisite() and a persistent cache is not being used.
-- --
-- -- @since 3.0.0
-- --
-- -- @global wpdb wpdb WordPress database abstraction object.
-- --
-- -- @param int network_id Optional site ID for which to query the options. Defaults to the current site.
-- --
-- function wp_load_core_site_options( network_id = null ) then
--         global wpdb;

--         if ( ! is_multisite() || wp_using_ext_object_cache() || wp_installing() ) then
--                 return;
--         end;

--         if ( empty( network_id ) ) then
--                 network_id = get_current_network_id();
--         end;

--         core_options = array( "site_name", "siteurl", "active_sitewide_plugins", "_site_transient_timeout_theme_roots", "_site_transient_theme_roots", "site_admins", "can_compress_scripts", "global_terms_enabled", "ms_files_rewriting" );

--         core_options_in = """ . implode( "", "", core_options ) . """;
--         options         = wpdb->get_results( wpdb->prepare( "SELECT meta_key, meta_value FROM wpdb->sitemeta WHERE meta_key IN (core_options_in) AND site_id = %d", network_id ) );

--         data = array();
--         foreach ( options as option ) then
--                 key                = option->meta_key;
--                 cache_key          = "thennetwork_idend;:key";
--                 option->meta_value = maybe_unserialize( option->meta_value );

--                 data[ cache_key ] = option->meta_value;
--         end;
--         wp_cache_set_multiple( data, "site-options" );
-- end;

   -------------------
   -- Update_Option --
   -------------------

   function Update_Option (Option   : String;
                           Value    : Multi_Type;
                           Autoload : Boolean := False)
                           return Boolean
   is
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Wp_Common;
      use Inc_Caches;
      use Inc_Functions;
      use Inc_Formatting;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Plugins;
   begin
      -- if Is_Scalar (Option) then
      --    Option := Trim (Option);
      -- end if;

      -- if Empty (Option) then
      --    return False;
      -- end if;

      --
      -- Until a proper _deprecated_option() function can be introduced,
      -- redirect requests to deprecated keys to the new, correct ones.
      --
      declare
         Deprecated_Keys : constant Array_Type := To_Array (List => (
           Build ("blacklist_keys",    "disallowed_keys"),
           Build ("comment_whitelist", "comment_previously_approved")
         ));
      begin
         if Isset (Deprecated_Keys, Option) and then not Wp_Installing then
            X_Deprecated_Argument (
              "__FUNCTION__",
              "5.5.0",
              Sprintf (
                -- translators: 1: Deprecated option key, 2: New option key.
                abs "The ""%1s"" option key has been renamed to ""%2s"".",
                To_List (List => (
                  1 => +Option,
                  2 => +Get_As_String (Deprecated_Keys, Option)
                ))
              )
            );
            return Update_Option
              (Get_As_String (Deprecated_Keys, Option), Value, Autoload);
         end if;
      end;

      Wp_Protect_Special_Option (Option);

--      if Is_Object (Value) then
--         Value := clone value;
--      end if;

      declare
         Value_2 : Multi_Type :=
           From_String (Sanitize_Option (Option, As_String (Value)));

         Old_Value : constant Multi_Type := Get_Option (Option);

         Serialized_Value : Multi_Type;
      begin
         --
         -- Filters a specific option before its value is (maybe) serialized and
         -- updated.
         --
         -- The dynamic portion of the hook name, `option`, refers to the option name.
         --
         -- @since 2.6.0
         -- @since 4.4.0 The `option` parameter was added.
         --
         -- @param mixed  value     The new, unserialized option value.
         -- @param mixed  old_value The old option value.
         -- @param string option    Option name.
         --
         Value_2 :=
           Apply_Filters ("pre_update_option_" & Option, Value_2, Old_Value, Option);

         --
         -- Filters an option before its value is (maybe) serialized and updated.
         --
         -- @since 3.9.0
         --
         -- @param mixed  value     The new, unserialized option value.
         -- @param string option    Name of the option.
         -- @param mixed  old_value The old option value.
         --
         Value_2 := Apply_Filters ("pre_update_option", Value_2, Option, Old_Value);

         --
         -- If the new and old values are the same, no need to update.
         --
         -- Unserialized values will be adequate in most cases. If the unserialized
         -- data differs, the (maybe) serialized data is checked to avoid
         -- unnecessary database calls for otherwise identical object instances.
         --
         -- See https://core.trac.wordpress.org/ticket/38903
         --
         if
           Value_2 = Old_Value or else
           Maybe_Serialize (As_String (Value_2)) =
           Maybe_Serialize (As_String (Old_Value))
         then
            return False;
         end if;

         -- This filter is documented in wp-includes/option.php
         if
           Apply_Filters ("default_option_" & Option, From_Boolean (False),
                          Option, From_Boolean (False)) = Old_Value
         then
            -- Default setting for new options is "yes".
            -- if ( null === autoload ) then
            --    autoload = "yes";
            -- end if;

            return Add_Option (Option, Value_2, "", Autoload);
         end if;

         Serialized_Value := Maybe_Serialize (As_String (Value_2));

         --
         -- Fires immediately before an option value is updated.
         --
         -- @since 2.9.0
         --
         -- @param string option    Name of the option to update.
         -- @param mixed  old_value The old option value.
         -- @param mixed  value     The new option value.
         --
         Do_Action ("update_option", Option, Old_Value, Value_2);

         declare
            use Class_WpDB;

            Update_Args : Array_Type := To_Array (List => (1 =>
              Build ("option_value", As_String (Serialized_Value))
            ));
            Result : Rows_Result_Type;
         begin
            if not Autoload then -- ( null !== autoload ) then
               Set (Update_Args, "autoload", From_Boolean (Autoload));
               -- ( "no" === autoload || false === autoload ) ? "no" : "yes";
            end if;

            Result :=
              Globals.WpDB.Update (-Globals.WpDB.Options,
                                   Update_Args,
                                   To_Array (List => (1 =>
                                     Build ("option_name", Option)
                                  )));
            if Result.Status = Error then
               return False;
            end if;
         end;

         declare
            Found : Boolean;

            Notoptions : constant Array_Type :=
              Wp_Cache_Get ("notoptions", "options", Found => Found);
         begin
            if Is_Array (Notoptions) and then Isset (Notoptions, Option) then
               Delete (Ref (Notoptions, Option));
               Wp_Cache_Set ("notoptions", Notoptions, "options");
            end if;
         end;

         if not Wp_Installing then
            declare
               Alloptions : Array_Type := Wp_Load_Alloptions (True);
            begin
               if Isset (Alloptions, Option) then
                  Set (Alloptions, Option, Serialized_Value);
                  Wp_Cache_Set ("alloptions", Alloptions, "options");
               else
                  Wp_Cache_Set (Option, As_Array (Serialized_Value), "options");
               end if;
            end;
         end if;

         --
         -- Fires after the value of a specific option has been successfully updated.
         --
         -- The dynamic portion of the hook name, `option`, refers to the option name.
         --
         -- @since 2.0.1
         -- @since 4.4.0 The `option` parameter was added.
         --
         -- @param mixed  old_value The old option value.
         -- @param mixed  value     The new option value.
         -- @param string option    Option name.
         --
         Do_Action ("update_option_" & Option, Old_Value, Value_2, Option);

         --
         -- Fires after the value of an option has been successfully updated.
         --
         -- @since 2.9.0
         --
         -- @param string option    Name of the updated option.
         -- @param mixed  old_value The old option value.
         -- @param mixed  value     The new option value.
         --
         Do_Action ("updated_option", Option, Old_Value, Value_2);
      end;
      return True;
   end Update_Option;

   procedure Update_Option (Option   : String;
                            Value    : Multi_Type;
                            Autoload : Boolean := False)
   is
      Unused : constant Boolean :=
        Update_Option (Option, Value, Autoload);
   begin
      null;
   end Update_Option;

   ----------------
   -- Add_Option --
   ----------------

   function Add_Option (Option     : String;
                        Value      : Multi_Type := From_String ("");
                        Deprecated : String     := "";
                        Autoload   : Boolean    := True)
                        return Boolean
   is
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Inc_Caches;
      use Class_WpDB;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Plugins;

      Value_2 : Multi_Type;
   begin
      -- if ( ! empty( deprecated ) ) then
      --    x_deprecated_argument( __FUNCTION__, "2.3.0" );
      -- end if;

      -- if ( is_scalar( option ) ) then
      --    option = trim( option );
      -- end if;

      -- if ( empty( option ) ) then
      --    return false;
      -- end if;

      --
      -- Until a proper _deprecated_option() function can be introduced,
      -- redirect requests to deprecated keys to the new, correct ones.
      --
      declare
         Deprecated_Keys : constant Array_Type := To_Array (List => (
           Build ("blacklist_keys",    "disallowed_keys"),
           Build ("comment_whitelist", "comment_previously_approved")
         ));
      begin
         if Isset (Deprecated_Keys, Option) and then not Wp_Installing then
            X_Deprecated_Argument (
              "__FUNCTION__",
              "5.5.0",
              Sprintf (
                -- translators: 1: Deprecated option key, 2: New option key.
                abs "The ""%1s"" option key has been renamed to ""%2s"".",
                To_List (List => (
                  1 => +Option,
                  2 => +Get_As_String (Deprecated_Keys, Option)
                ))
              )
            );
            return Add_Option (Get_As_String (Deprecated_Keys, Option),
                               Value, Deprecated, Autoload);
         end if;
      end;

      Wp_Protect_Special_Option (Option);

      -- if ( is_object( value ) ) then
      --    value = clone value;
      -- end if;

      Value_2 := From_String (Sanitize_Option (Option, As_String (Value)));

      -- Make sure the option doesn't already exist.
      -- We can check the "notoptions" cache before we ask for a DB query.
      declare
         Found : Boolean;

         Notoptions : constant Array_Type :=
           Wp_Cache_Get ("notoptions", "options", Found => Found);
      begin
         if not Is_Array (Notoptions) or else not Isset (Notoptions, Option) then
            -- This filter is documented in wp-includes/option.php
            if
              Apply_Filters ("default_option_" & Option, False, Option, False)
              /= Get_Option (Option)
            then
               return False;
            end if;
         end if;
      end;

      declare
         Serialized_Value : constant Multi_Type :=
           Maybe_Serialize (As_String (Value_2));
--       Autoload         = ( "no" === autoload || false === autoload ) ? "no" : "yes";
      begin
         --
         -- Fires before an option is added.
         --
         -- @since 2.9.0
         --
         -- @param string option Name of the option to add.
         -- @param mixed  value  Value of the option.
         --
         Do_Action ("add_option", Option, Value_2);

         declare
            Statement : constant Statement_Type :=
              Globals.WpDB.Prepare (
                "INSERT INTO `wpdb->options` (`option_name`, `option_value`, " &
                "`autoload`) " &
                "VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE `option_name` = " &
                "VALUES(`option_name`), `option_value` = " &
                "VALUES(`option_value`), `autoload` = VALUES(`autoload`)",
                To_List (List => (
                  1 => +Option,
                  2 => +As_String (Serialized_Value),
                  3 => +Boolean'Image (Autoload))));

            Result : constant Rows_Result_Type :=
              Globals.WpDB.Query (Statement);
         begin
            if Result.Status = Error then
               return False;
            end if;
         end;

         if Wp_Installing then
            if Autoload then
               declare
                  Alloptions : Array_Type := Wp_Load_Alloptions (True);
               begin
                  Set (Alloptions, Option, Serialized_Value);
                  Wp_Cache_Set ("alloptions", Alloptions, "options");
               end;
            else
               Wp_Cache_Set (Option, As_Array (Serialized_Value), "options");
            end if;
         end if;

         -- This option exists now.
         declare
            Found : Boolean;

            Notoptions : constant Array_Type :=
              Wp_Cache_Get ("notoptions", "options", Found => Found);
              -- Yes, again... we need it to be fresh.
         begin
            if Is_Array (Notoptions) and then Isset (Notoptions, Option) then
               Delete (Ref (Notoptions, Option));
               Wp_Cache_Set ("notoptions", Notoptions, "options");
            end if;
         end;

         --
         -- Fires after a specific option has been added.
         --
         -- The dynamic portion of the hook name, `option`, refers to the option name.
         --
         -- @since 2.5.0 As "add_option_thennameend;"
         -- @since 3.0.0
         --
         -- @param string option Name of the option to add.
         -- @param mixed  value  Value of the option.
         --
         Do_Action ("add_option_" & Option, Option, Value);

         --
         -- Fires after an option has been added.
         --
         -- @since 2.9.0
         --
         -- @param string option Name of the added option.
         -- @param mixed  value  Value of the option.
         --
         Do_Action ("added_option", Option, Value);
      end;
      return True;
   end Add_Option;

   procedure Add_Option (Option     : String;
                         Value      : Multi_Type := From_String ("");
                         Deprecated : String     := "";
                         Autoload   : Boolean    := True) -- "yes"
   is
      Unused : constant Boolean :=
        Add_Option (Option, Value, Deprecated, Autoload);
   begin
      null;
   end Add_Option;

   -------------------
   -- Delete_Option --
   -------------------

   function Delete_Option (Option : String)
                           return Boolean
   is
      use Php.Types;
      use UStrings;
      use Inc_Caches;
      use Class_WpDB;
      use Inc_Load;
      use Inc_Plugins;
   begin
      -- if Is_Scalar (Option) then
      --    Option := Trim (Option);
      -- end if;

      -- if Empty (Option) then
      --    return False;
      -- end if;

      Wp_Protect_Special_Option (Option);

      -- Get the ID, if no ID then return.
      declare
         Success_2 : Boolean;

         Statement : constant Statement_Type :=
           Globals.WpDB.Prepare (
             "SELECT autoload FROM wpdb->options " &
             "WHERE option_name = %s", To_List (Option));

         Row : constant Boolean :=
           Globals.WpDB.Get_Row (Statement, Success => Success_2) /= 0;

         Result : Rows_Result_Type;
      begin
         if not Row then -- Is_Null (Row) then
            return False;
         end if;

         --
         -- Fires immediately before an option is deleted.
         --
         -- @since 2.9.0
         --
         -- @param string option Name of the option to delete.
         --
         Do_Action ("delete_option", Option);

         Result :=
           Globals.WpDB.Delete (
             -Globals.WpDB.Options,
             To_Array (List => (1 =>
               Build ("option_name", Option)))
           );

         if not Wp_Installing then
            if False then -- Row.Autoload then -- "yes"
               declare
                  Alloptions : constant Array_Type := Wp_Load_Alloptions (True);
               begin
                  if Is_Array (Alloptions) and then Isset (Alloptions, Option) then
                     Delete (Ref (Alloptions, Option));
                     Wp_Cache_Set ("alloptions", Alloptions, "options");
                  end if;
               end;
            else
               Wp_Cache_Delete (Option, "options");
            end if;
         end if;

         if Result.Status in Success | Create_Alter then
            --
            -- Fires after a specific option has been deleted.
            --
            -- The dynamic portion of the hook name, `option`, refers to the option
            -- name.
            --
            -- @since 3.0.0
            --
            -- @param string option Name of the deleted option.
            --
            Do_Action ("delete_option_" & Option, Option);

            --
            -- Fires after an option has been deleted.
            --
            -- @since 2.9.0
            --
            -- @param string option Name of the deleted option.
            --
            Do_Action ("deleted_option", Option);

            return True;
         end if;
      end;

      return False;
   end Delete_Option;

   procedure Delete_Option (Option : String)
   is
      Unused : constant Boolean := Delete_Option (Option);
   begin
      null;
   end Delete_Option;

-- --
-- -- Deletes a transient.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string transient Transient name. Expected to not be SQL-escaped.
-- -- @return bool True if the transient was deleted, false otherwise.
-- --
-- function delete_transient( transient ) then

--         --
--         -- Fires immediately before a specific transient is deleted.
--         --
--         -- The dynamic portion of the hook name, `transient`, refers to the transient name.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string transient Transient name.
--         --
--         do_action( "delete_transient_thentransientend;", transient );

--         if ( wp_using_ext_object_cache() || wp_installing() ) then
--                 result = wp_cache_delete( transient, "transient" );
--         end; else then
--                 option_timeout = "_transient_timeout_" . transient;
--                 option         = "_transient_" . transient;
--                 result         = delete_option( option );

--                 if ( result ) then
--                         delete_option( option_timeout );
--                 end;
--         end;

--         if ( result ) then

--                 --
--                 -- Fires after a transient is deleted.
--                 --
--                 -- @since 3.0.0
--                 --
--                 -- @param string transient Deleted transient name.
--                 --
--                 do_action( "deleted_transient", transient );
--         end;

--         return result;
-- end;

   -------------------
   -- Get_Transient --
   -------------------

   function Get_Transient (Transient : String)
                           return Multi_Type
   is
      use Php.Misc;
      use Wp_Common;
      use Inc_Caches;
      use Inc_Load;
--    use Inc_Plugins;

      --
      -- Filters the value of an existing transient before it is retrieved.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      -- name.
      --
      -- Returning a value other than false from the filter will short-circuit
      -- retrieval and return that value instead.
      --
      -- @since 2.8.0
      -- @since 4.4.0 The `transient` parameter was added
      --
      -- @param mixed  pre_transient The default value to return if the transient does
      --                              not exist. Any value other than false will
      --                              short-circuit the retrieval of the transient,
      --                              and return that value.
      -- @param string transient     Transient name.
      --
      Pre : constant Multi_Type :=
        Apply_Filters ("pre_transient_" & Transient,
                       From_Boolean (False), Transient);

      Value : Multi_Type;
      Value_Bool : Boolean := True;
      Found : Boolean;
   begin
      if From_Boolean (False) /= Pre then
         return Pre;
      end if;

      if Wp_Using_Ext_Object_Cache or else Wp_Installing  then
         Value := Wp_Cache_Get (Transient, "transient", Found => Found);
      else
         declare
            Transient_Option : constant String := "_transient_" & Transient;
         begin
            if not Wp_Installing then
               -- If option is not in alloptions, it is not autoloaded and thus has
               -- a timeout.
               declare
                  Alloptions : constant Array_Type := Wp_Load_Alloptions;
               begin
                  if not Isset (Alloptions, Transient_Option) then
                     declare
                        Transient_Timeout : constant String :=
                          "_transient_timeout_" & Transient;

                        Timeout : constant Natural :=
                          Get_Option (Transient_Timeout);
                     begin
                        if 0 /= Timeout and then Timeout < Time then -- false
                           Delete_Option (Transient_Option);
                           Delete_Option (Transient_Timeout);
                           Value_Bool := False;
                        end if;
                     end;
                  end if;
               end;
            end if;

            if not Value_Bool then
               Value := Get_Option (Transient_Option);
            end if;
         end;
      end if;

      --
      -- Filters an existing transient"s value.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      -- name.
      --
      -- @since 2.8.0
      -- @since 4.4.0 The `transient` parameter was added
      --
      -- @param mixed  value     Value of transient.
      -- @param string transient Transient name.
      --
      return Apply_Filters ("transient_" & Transient, Value, Transient);
   end Get_Transient;

   -------------------
   -- Set_Transient --
   -------------------

   function Set_Transient (Transient  : String;
                           Value      : Multi_Type;
                           Expiration : Integer := 0)
                           return Boolean
   is
      use Php.Misc;
      use Wp_Common;
      use Inc_Caches;
      use Inc_Load;
      use Inc_Plugins;

--    expiration = (int) expiration;

      --
      -- Filters a specific transient before its value is set.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      -- name.
      --
      -- @since 3.0.0
      -- @since 4.2.0 The `expiration` parameter was added.
      -- @since 4.4.0 The `transient` parameter was added.
      --
      -- @param mixed  value      New value of transient.
      -- @param int    expiration Time until expiration in seconds.
      -- @param string transient  Transient name.
      --
      Value_2 : constant Multi_Type :=
        Apply_Filters ("pre_set_transient_" & Transient, Value,
                       Expiration, Transient);

      --
      -- Filters the expiration for a transient before its value is set.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      -- name.
      --
      -- @since 4.4.0
      --
      -- @param int    expiration Time until expiration in seconds. Use 0 for no
      --                           expiration.
      -- @param mixed  value      New value of transient.
      -- @param string transient  Transient name.
      --
      Expiration_2 : constant Integer :=
        Apply_Filters ("expiration_of_transient_" & Transient, Expiration,
                       Value_2, Transient);

      Result : Boolean;
   begin
      if Wp_Using_Ext_Object_Cache or else Wp_Installing then
         Wp_Cache_Set (Transient, Value_2, "transient", Expiration, Success => Result);
      else
         declare
            Transient_Timeout : constant String := "_transient_timeout_" & Transient;
            Transient_Option  : constant String := "_transient_" & Transient;
         begin
            if False = Get_Option (Transient_Option) then
               declare
                  Autoload : Boolean := True; -- "yes";
               begin
                  if Expiration_2 /= 0 then
                     Autoload := False; -- "no";
                     Add_Option (Transient_Timeout,
                                 From_Integer (Time + Expiration_2), "",
                                 Autoload => False); -- "no"
                  end if;
                  Result := Add_Option (Transient_Option, Value_2, "", Autoload);
               end;
            else
               -- If expiration is requested, but the transient has no timeout option,
               -- delete, then re-create transient rather than update.
               declare
                  Update : Boolean := True;
               begin
                  if Expiration_2 /= 0 then
                     if False = Get_Option (Transient_Timeout) then
                        Delete_Option (Transient_Option);
                        Add_Option (Transient_Timeout,
                                    From_Integer (Time + Expiration_2), "",
                                    Autoload => False); -- "no"
                        Result := Add_Option (Transient_Option, Value_2, "",
                                              Autoload => False); -- "no"
                        Update := False;
                     else
                        Update_Option (Transient_Timeout,
                                       From_Integer (Time + Expiration_2));
                     end if;
                  end if;

                  if Update then
                     Result := Update_Option (Transient_Option, Value_2);
                  end if;
               end;
            end if;
         end;
      end if;

      if Result then
         --
         -- Fires after the value for a specific transient has been set.
         --
         -- The dynamic portion of the hook name, `transient`, refers to the transient
         -- name.
         --
         -- @since 3.0.0
         -- @since 3.6.0 The `value` and `expiration` parameters were added.
         -- @since 4.4.0 The `transient` parameter was added.
         --
         -- @param mixed  value      Transient value.
         -- @param int    expiration Time until expiration in seconds.
         -- @param string transient  The name of the transient.
         --
         Do_Action ("set_transient_" & Transient, Value_2,
                    Expiration_2, Transient);

         --
         -- Fires after the value for a transient has been set.
         --
         -- @since 3.0.0
         -- @since 3.6.0 The `value` and `expiration` parameters were added.
         --
         -- @param string transient  The name of the transient.
         -- @param mixed  value      Transient value.
         -- @param int    expiration Time until expiration in seconds.
         --
         Do_Action ("setted_transient", Transient, Value_2, Expiration_2);
      end if;

      return Result;
   end Set_Transient;

   procedure Set_Transient (Transient  : String;
                            Value      : Multi_Type;
                            Expiration : Integer := 0)
   is
      Unused : constant Boolean := Set_Transient (Transient, Value, Expiration);
   begin
      null;
   end Set_Transient;

   --------------------------------
   -- Delete_Expired_Transitents --
   --------------------------------

   procedure Delete_Expired_Transients (Force_DB : Boolean := False)
   is
      use Globals;
      use UStrings;
      use Inc_Functions;
      use Inc_Load;
--    global wpdb;
   begin
      if not Force_DB and then Wp_Using_Ext_Object_Cache then
         return;
      end if;

      WpDB.Query (
        WpDB.Prepare (
          "DELETE a, b FROM {wpdb->options} a, {wpdb->options} b " &
          "WHERE a.option_name LIKE %s " &
          "AND a.option_name NOT LIKE %s " &
          "AND b.option_name = CONCAT( '_transient_timeout_', SUBSTRING( a.option_name, 12 ) ) " &
          "AND b.option_value < %d",
          To_List (List => (
            1 => +(WpDB.ESC_Like ("_transient_") & "%"),
            2 => +(WpDB.ESC_Like ("_transient_timeout_") & "%"),
            3 => +Helpers.Image (Php.Misc.Time)
          ))
        ));

      if not Is_Multisite then
         -- Single site stores site transients in the options table.
         WpDB.Query (
           WpDB.Prepare (
             "DELETE a, b FROM {wpdb->options} a, {wpdb->options} b " &
             "WHERE a.option_name LIKE %s " &
             "AND a.option_name NOT LIKE %s " &
             "AND b.option_name = CONCAT('_site_transient_timeout_', SUBSTRING( a.option_name, 17 ) ) " &
             "AND b.option_value < %d",
             To_List (List => (
               1 => +(WpDB.ESC_Like ("_site_transient_") & "%"),
               2 => +(WpDB.ESC_Like ("_site_transient_timeout_") & "%"),
               3 => +Helpers.Image (Php.Misc.Time)
             ))
           ));
      elsif Is_Multisite and then Is_Main_Site and then Is_Main_Network then
         -- Multisite stores site transients in the sitemeta table.
         WpDB.Query (
           WpDB.Prepare (
             "DELETE a, b FROM {wpdb->sitemeta} a, {wpdb->sitemeta} b " &
             "WHERE a.meta_key LIKE %s " &
             "AND a.meta_key NOT LIKE %s " &
             "AND b.meta_key = CONCAT('_site_transient_timeout_', SUBSTRING( a.meta_key, 17 ) ) " &
             "AND b.meta_value < %d",
             To_List (List => (
               1 => +(WpDB.ESC_Like ("_site_transient_") & "%"),
               2 => +(WpDB.ESC_Like ("_site_transient_timeout_") & "%"),
               3 => +Helpers.Image (Php.Misc.Time)
             ))
           ));
      end if;
   end Delete_Expired_Transients;

   ----------------------
   -- Wp_User_Settings --
   ----------------------

   procedure Wp_User_Settings
   is
      use Php.HTML;
      use Php.Misc;
      use Php.Preg;
      use Binder;
      use Globals;
      use UStrings;
      use Inc_Load;
      use Inc_Link_Templates;
      use Inc_Users;
   begin
      if not Is_Admin or else Wp_Doing_AJAX then
         return;
      end if;

      declare
         User_Id : constant Integer := Get_Current_User_Id;
         User    : constant String  := Helpers.Image (User_Id);
      begin
         if User_Id = 0 then -- not
            return;
         end if;

         if not Is_User_Member_Of_Blog then
            return;
         end if;

         declare
            Settings : constant String :=
              Get_User_Option ("user-settings", User_Id); -- (string)
         begin
            if Isset (X_COOKIE, "wp-settings-" & User) then
               declare
                  Cookie : constant String :=
                    Preg_Replace ("/[^A-Za-z0-9=&_]/", "",
                                  Get_As_String (X_COOKIE, "wp-settings-" & User));
               begin
                  -- No change or both empty.
                  if Cookie = Settings then
                     return;
                  end if;

                  declare
                     Last_Saved : constant Natural :=
                       Get_User_Option ("user-settings-time", User_Id); -- (int)

                     Current : constant Natural :=
                        (if Isset (X_COOKIE, "wp-settings-time-" & User)
                         then Natural'Value (Preg_Replace ("/[^0-9]/", "",
                              Get_As_String (X_COOKIE,  "wp-settings-time-" & User)))
                         else 0);
                  begin
                     -- The cookie is newer than the saved value. Update the
                     -- user_option and leave the cookie as-is.
                     if Current > Last_Saved then
                        Update_User_Option (User_Id, "user-settings",
                                            From_String (Cookie), False);
                        Update_User_Option (User_Id, "user-settings-time",
                                            From_Integer (Time - 5), False);
                        return;
                     end if;
                  end;
               end;
            end if;

            -- The cookie is not set in the current browser or the saved value
            -- is newer.
            declare
               Secure : constant Boolean :=
                 ("https" = Parse_URL (Admin_URL, PHP_URL_SCHEME));
            begin
               Set_Cookie ("wp-settings-" & User, Settings,
                           Time + YEAR_IN_SECONDS, -SITECOOKIEPATH, "", Secure);
               Set_Cookie ("wp-settings-time-" & User, Helpers.Image (Time),
                           Time + YEAR_IN_SECONDS, -SITECOOKIEPATH, "", Secure);
            end;
            Set (X_COOKIE, "wp-settings-" & User, From_String (Settings));
         end;
      end;
   end Wp_User_Settings;

   ----------------------
   -- Get_User_Setting --
   ----------------------

   function Get_User_Setting (Name    : String;
                              Default : String := "")
                              return Multi_Type
   is
      All_User_Settings : constant Array_Type := Get_All_User_Settings;
   begin
      return
        (if Isset (All_User_Settings, Name)
         then Get (All_User_Settings, Name)
         else From_String (Default));
   end Get_User_Setting;

-- --
-- -- Adds or updates user interface setting.
-- --
-- -- Both `name` and `value` can contain only ASCII letters, numbers, hyphens, and underscores.
-- --
-- -- This function has to be used before any output has started as it calls `setcookie()`.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string name  The name of the setting.
-- -- @param string value The value for the setting.
-- -- @return bool|null True if set successfully, false otherwise.
-- --                   Null if the current user is not a member of the site.
-- --
-- function set_user_setting( name, value ) then
--         if ( headers_sent() ) then
--                 return false;
--         end;

--         all_user_settings          = get_all_user_settings();
--         all_user_settings[ name ] = value;

--         return wp_set_all_user_settings( all_user_settings );
-- end;

   -------------------------
   -- Delete_User_Setting --
   -------------------------

   function Delete_User_Setting (Names : String)
                                 return Boolean
   is
      use Php.HTML;
      use UStrings;
   begin
      if Headers_Sent then
         return False;
      end if;

      declare
         All_User_Settings : constant Array_Type := Get_All_User_Settings;
         Names_2           : constant List_Type  := To_List (Names); -- (array) names;
         Deleted           : Boolean    := False;
      begin
         for Name of Names_2 loop
            if Isset (All_User_Settings, -Name) then
               Delete (Ref (All_User_Settings, -Name));
               Deleted := True;
            end if;
         end loop;

         if Deleted then
            return Wp_Set_All_User_Settings (All_User_Settings);
         end if;
      end;
      return False;
   end Delete_User_Setting;

   -------------------------
   -- Delete_User_Setting --
   -------------------------

   procedure Delete_User_Setting (Names : String)
   is
      Unused : constant Boolean := Delete_User_Setting (Names);
   begin
      null;
   end Delete_User_Setting;

   ---------------------------
   -- Get_All_User_Settings --
   ---------------------------
   Global_X_Updated_User_Settings : Array_Type;

   function Get_All_User_Settings
            return Array_Type
   is
      use Php.HTML;
      use Php.Preg;
      use Php.Types;
      use Php.Strings;
      use Binder;
      use Inc_Users;

      User_Id : constant Natural := Get_Current_User_Id;
      User    : constant String  := Helpers.Image (User_Id);
   begin
      if User_Id = 0 then
         return Empty_Array;
      end if;

      if
--      Isset (Global_X_Updated_User_Settings) and then
        Is_Array (Global_X_Updated_User_Settings)
      then
         return Global_X_Updated_User_Settings;
      end if;

      declare
         User_Settings : Array_Type;
      begin
         if Isset (X_COOKIE, "wp-settings-" & User) then
            declare
               Cookie : constant String :=
                 Preg_Replace ("/[^A-Za-z0-9=&_-]/", "",
                               Get_As_String (X_COOKIE, "wp-settings-" & User));
            begin
               if Strpos (Cookie, "=") /= 0 then -- "=" cannot be 1st char.
                  Parse_Str (Cookie, User_Settings);
               end if;
            end;
         else
            declare
               Option : constant String :=
                 Get_User_Option ("user-settings", User_Id);
            begin
--             if Option and then Is_String (Option) then
               Parse_Str (Option, User_Settings);
--             end if;
            end;
         end if;

         Global_X_Updated_User_Settings := User_Settings;
         return User_Settings;
      end;
   end Get_All_User_Settings;

   ------------------------------
   -- Wp_Set_All_User_Settings --
   ------------------------------

   function Wp_Set_All_User_Settings (User_Settings : Array_Type)
                                      return Boolean
   is
      use Ada.Strings.Unbounded;
      use Php.HTML;
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Inc_Users;
--    global _updated_user_settings;

      User_Id  : constant Integer := Get_Current_User_Id;
      Settings : Unbounded_String;
   begin
      if User_Id = 0 then
         return False;
      end if;

      if not Is_User_Member_Of_Blog then
         return False; -- was just return;
      end if;

      for A in User_Settings.Iterate loop
         declare
            Name    : constant String := Key (A);
            Value   : constant String := As_String (Element (A));

            X_Name  : constant String :=
              Preg_Replace ("/[^A-Za-z0-9_-]+/", "", Name);

            X_Value : constant String :=
              Preg_Replace ("/[^A-Za-z0-9_-]+/", "", Value);
         begin
            if not Empty (X_Name) then
               Append (Settings, X_Name & "=" & X_Value & "&");
            end if;
         end;
      end loop;

      Settings := +Rtrim (-Settings, "&");
      Parse_Str (-Settings, Global_X_Updated_User_Settings);

      Update_User_Option (User_Id, "user-settings",
                          From_String (-Settings), False);
      Update_User_Option (User_Id, "user-settings-time",
                          From_Integer (Php.Misc.Time), False);

      return True;
   end Wp_Set_All_User_Settings;

   ------------------------------
   -- Wp_Set_All_User_Settings --
   ------------------------------

   procedure Wp_Set_All_User_Settings (User_Settings : Array_Type)
   is
      Unused : constant Boolean :=
        Wp_Set_All_User_Settings (User_Settings);
   begin
      null;
   end Wp_Set_All_User_Settings;

-- --
-- -- Deletes the user settings of the current user.
-- --
-- -- @since 2.7.0
-- --
-- function delete_all_user_settings() then
--         user_id = get_current_user_id();
--         if ( ! user_id ) then
--                 return;
--         end;

--         update_user_option( user_id, "user-settings", "", false );
--         setcookie( "wp-settings-" . user_id, " ", time() - YEAR_IN_SECONDS, SITECOOKIEPATH );
-- end;

   ---------------------
   -- Get_Site_Option --
   ---------------------

   function Get_Site_Option (Option     : String;
                             Default    : Multi_Type := From_Boolean (False);
                             Deprecated : Boolean := True)
                             return Multi_Type
   is
      pragma Unreferenced (Deprecated);
   begin
      return Get_Network_Option (0, -- null,
                                 Option, Default);
   end Get_Site_Option;

   ---------------------
   -- Add_Site_Option --
   ---------------------

   function Add_Site_Option (Option : String;
                             Value  : Multi_Type)
                             return Boolean
   is
   begin
      return Add_Network_Option (0, Option, Value); -- null
   end Add_Site_Option;

   procedure Add_Site_Option (Option : String;
                              Value  : Multi_Type)
   is
      Unused : constant Boolean := Add_Site_Option (Option, Value);
   begin
      null;
   end Add_Site_Option;

   ------------------------
   -- Delete_Site_Option --
   ------------------------

   function Delete_Site_Option (Option : String)
                                return Boolean
   is
   begin
      return Delete_Network_Option (0, Option); -- null
   end Delete_Site_Option;

   procedure Delete_Site_Option (Option : String)
   is
      Unused : constant Boolean := Delete_Site_Option (Option);
   begin
      null;
   end Delete_Site_Option;

   ------------------------
   -- Update_Site_Option --
   ------------------------

   function Update_Site_Option (Option : String;
                                Value  : Multi_Type)
                                return Boolean
   is
   begin
      return Update_Network_Option (0, Option, Value); -- null
   end Update_Site_Option;

   procedure Update_Site_Option (Option : String;
                                 Value  : Multi_Type)
   is
      Unused : constant Boolean := Update_Site_Option (Option, Value);
   begin
      null;
   end Update_Site_Option;

   ------------------------
   -- Get_Network_Option --
   ------------------------

   function Get_Network_Option (Network_Id : Integer;
                                Option     : String;
                                Default    : Multi_Type := From_Boolean (False))
                                return Multi_Type
   is
      use Php.Types;
      use UStrings;
      use Wp_Common;
      use Inc_Caches;
      use Class_WpDB;
      use Inc_Functions;
      use Inc_Load;
--    use Inc_Plugins;

      Network_Id_2 : Integer;
      Pre : Multi_Type;
   begin
      if Network_Id /= 0 and then not Is_Number (Network_Id) then
         return From_Boolean (False);
      end if;

--    network_id = (int) network_id;

      -- Fallback to the current network if a network ID is not specified.
      if Network_Id = 0 then
         Network_Id_2 := Get_Current_Network_Id;
      end if;

      --
      -- Filters the value of an existing network option before it is retrieved.
      --
      -- The dynamic portion of the hook name, `option`, refers to the option name.
      --
      -- Returning a value other than false from the filter will short-circuit
      -- retrieval and return that value instead.
      --
      -- @since 2.9.0 As "pre_site_option_" . key
      -- @since 3.0.0
      -- @since 4.4.0 The `option` parameter was added.
      -- @since 4.7.0 The `network_id` parameter was added.
      -- @since 4.9.0 The `default` parameter was added.
      --
      -- @param mixed  pre_option The value to return instead of the option value.
      --                           This differs from `default`, which is used as the
      --                           fallback value in the event the option doesn't
      --                           exist elsewhere in get_network_option(). Default
      --                           false (to skip past the short-circuit).
      -- @param string option     Option name.
      -- @param int    network_id ID of the network.
      -- @param mixed  default    The fallback value to return if the option does not
      --                           exist. Default false.
      --
      Pre := Apply_Filters ("pre_site_option_" & Option, From_Boolean (False),
                            Option, Network_Id_2, Default);

      if From_Boolean (False) /= Pre then
         return Pre;
      end if;

      declare
         Found : Boolean;
         -- Prevent non-existent options from triggering multiple queries.
         Notoptions_Key : constant String := "network_id:notoptions";
         Notoptions     : Array_Type :=
           Wp_Cache_Get (Notoptions_Key, "site-options", Found => Found);
         Value : Multi_Type;
      begin
         if Is_Array (Notoptions) and then Isset (Notoptions, Option) then
            --
            -- Filters the value of a specific default network option.
            --
            -- The dynamic portion of the hook name, `option`, refers to the option
            -- name.
            --
            -- @since 3.4.0
            -- @since 4.4.0 The `option` parameter was added.
            -- @since 4.7.0 The `network_id` parameter was added.
            --
            -- @param mixed  default    The value to return if the site option does
            --                           not exist in the database.
            -- @param string option     Option name.
            -- @param int    network_id ID of the network.
            --
            return Apply_Filters ("default_site_option_" & Option, Default,
                                  Option, Network_Id_2);
         end if;

         if not Is_Multisite then
            -- This filter is documented in wp-includes/option.php
            declare
               Default_2 : constant Multi_Type :=
                 Apply_Filters ("default_site_option_" & Option,
                                Default, Option, Network_Id);
            begin
               Value := Get_Option (Option, Default_2);
            end;
         else
            declare
               Cache_Key : constant String := "network_id:option";
               Found : Boolean;
            begin
               Value := Wp_Cache_Get (Cache_Key, "site-options", Found => Found);

               if
                 Kind_Of (Value) in Kind_Null or else -- not Isset (Value) or else
                 From_Boolean (False) = Value
               then
                  declare
                     Success : Boolean;

                     Statement : constant Statement_Type :=
                       Globals.WpDB.Prepare (
                         "SELECT meta_value FROM wpdb->sitemeta " &
                         "WHERE meta_key = %s AND site_id = %d",
                         To_List (List => (
                           1 => +Option,
                           2 => +Helpers.Image (Network_Id_2)
                         ))
                       );

                     Row : constant Array_Type :=
                       Globals.WpDB.Get_Row (Statement, Success => Success);
                  begin
                     -- Has to be get_row() instead of get_var() because of
                     -- funkiness with 0, false, null values.
                     if Is_Object (Row) then
--                      Value := Row.Meta_Value;
                        Value := Maybe_Unserialize (As_String (Value));
                        Wp_Cache_Set (Cache_Key, As_Array (Value), "site-options");
                     else
                        if not Is_Array (Notoptions) then
                           Notoptions := Empty_Array;
                        end if;

                        Set (Notoptions, Option, From_Boolean (True));
                        Wp_Cache_Set (Notoptions_Key, Notoptions, "site-options");

                        -- This filter is documented in wp-includes/option.php
                        Value := Apply_Filters ("default_site_option_" & Option,
                                                Default, Option, Network_Id_2);
                     end if;
                  end;
               end if;
            end;
         end if;

         if not Is_Array (Notoptions) then
            Notoptions := Empty_Array;
            Wp_Cache_Set (Notoptions_Key, Notoptions, "site-options");
         end if;

         --
         -- Filters the value of an existing network option.
         --
         -- The dynamic portion of the hook name, `option`, refers to the option name.
         --
         -- @since 2.9.0 As "site_option_" . key
         -- @since 3.0.0
         -- @since 4.4.0 The `option` parameter was added.
         -- @since 4.7.0 The `network_id` parameter was added.
         --
         -- @param mixed  value      Value of network option.
         -- @param string option     Option name.
         -- @param int    network_id ID of the network.
         --
         return Apply_Filters ("site_option_" & Option, Value, Option, Network_Id_2);
      end;
   end Get_Network_Option;

   ------------------------
   -- Add_Network_Option --
   ------------------------

   function Add_Network_Option (Network_Id : Integer;
                                Option     : String;
                                Value      : Multi_Type)
                                return Boolean
   is
      use Php.Types;
      use UStrings;
      use Wp_Common;
      use Inc_Caches;
      use Class_WpDB;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Plugins;

      Network_Id_2 : Natural    := Network_Id;
      Value_2      : Multi_Type := Value;
   begin
      if Network_Id_2 = 0 and then not Is_Number (Network_Id_2) then
         return False;
      end if;

--    network_id = (int) network_id;

      -- Fallback to the current network if a network ID is not specified.
      if Network_Id_2 = 0 then
         Network_Id_2 := Get_Current_Network_Id;
      end if;

      Wp_Protect_Special_Option (Option);

      --
      -- Filters the value of a specific network option before it is added.
      --
      -- The dynamic portion of the hook name, `option`, refers to the option name.
      --
      -- @since 2.9.0 As "pre_add_site_option_" . key
      -- @since 3.0.0
      -- @since 4.4.0 The `option` parameter was added.
      -- @since 4.7.0 The `network_id` parameter was added.
      --
      -- @param mixed  value      Value of network option.
      -- @param string option     Option name.
      -- @param int    network_id ID of the network.
      --
      Value_2 := Apply_Filters ("pre_add_site_option_" & Option, Value_2,
                                Option, Network_Id_2);
      declare
         Notoptions_Key : constant String := "network_id:notoptions";
         Cache_Key      : constant String := "network_id:option";

         Unused   : Boolean;
         Result_2 : Rows_Result_Type;
      begin
         if not Is_Multisite then
            Unused := Add_Option (Option, Value_2, "", Autoload => False); -- "no"
         else
            declare
               Found : Boolean;

               -- Make sure the option doesn't already exist.
               -- We can check the "notoptions" cache before we ask for a DB query.
               Notoptions : constant Array_Type :=
                 Wp_Cache_Get (Notoptions_Key, "site-options", Found => Found);
            begin
               if
                 not Is_Array (Notoptions) or else
                 not Isset (Notoptions, Option)
               then
                  if
                    From_Boolean (False) /=
                    Get_Network_Option (Network_Id_2, Option, From_Boolean (False))
                  then
                     return False;
                  end if;
               end if;
            end;

            Value_2 := From_String (Sanitize_Option (Option, As_String (Value_2)));

            declare
               Serialized_Value : constant Multi_Type :=
                 Maybe_Serialize (As_String (Value_2));
            begin
               Result_2 :=
                 Globals.WpDB.Insert (
                   -Globals.WpDB.Sitemeta,
                   To_Array (List => (
                     Build ("site_id",    Network_Id_2),
                     Build ("meta_key",   Option),
                     Build ("meta_value", As_String (Serialized_Value))
                   ))
                 );
            end;

            if Result_2.Status = Error then
               return False;
            end if;

            Wp_Cache_Set (Cache_Key, As_Array (Value_2), "site-options");

            declare
               Found : Boolean;

               -- This option exists now.
               Notoptions : constant Array_Type :=
                 Wp_Cache_Get (Notoptions_Key, "site-options", Found => Found);
               -- Yes, again... we need it to be fresh.
            begin
               if Is_Array (Notoptions) and then Isset (Notoptions, Option) then
                  Delete (Ref (Notoptions, Option));
                  Wp_Cache_Set (Notoptions_Key, Notoptions, "site-options");
               end if;
            end;
         end if;

         if Result_2.Status in Success | Create_Alter then
            --
            -- Fires after a specific network option has been successfully added.
            --
            -- The dynamic portion of the hook name, `option`, refers to the option
            -- name.
            --
            -- @since 2.9.0 As "add_site_option_thenkeyend;"
            -- @since 3.0.0
            -- @since 4.7.0 The `network_id` parameter was added.
            --
            -- @param string option     Name of the network option.
            -- @param mixed  value      Value of the network option.
            -- @param int    network_id ID of the network.
            --
            Do_Action ("add_site_option_" & Option, Option, Value_2, Network_Id_2);

            --
            -- Fires after a network option has been successfully added.
            --
            -- @since 3.0.0
            -- @since 4.7.0 The `network_id` parameter was added.
            --
            -- @param string option     Name of the network option.
            -- @param mixed  value      Value of the network option.
            -- @param int    network_id ID of the network.
            --
            Do_Action ("add_site_option", Option, Value_2, Network_Id_2);

            return True;
         end if;
      end;
      return False;
   end Add_Network_Option;

   ---------------------------
   -- Delete_Network_Option --
   ---------------------------

   function Delete_Network_Option (Network_Id : Integer;
                                   Option     : String)
                                   return Boolean
   is
      use Php.Types;
      use UStrings;
      use Inc_Caches;
      use Class_WpDB;
      use Inc_Load;
      use Inc_Plugins;

      Network_Id_2 : Integer := Network_Id;
      Unused : Boolean;
      Result : Rows_Result_Type;
   begin
      if Network_Id /= 0 and then not Is_Number (Network_Id) then
         return False;
      end if;

--    network_id = (int) network_id;

      -- Fallback to the current network if a network ID is not specified.
      if Network_Id = 0 then
         Network_Id_2 := Get_Current_Network_Id;
      end if;

      --
      -- Fires immediately before a specific network option is deleted.
      --
      -- The dynamic portion of the hook name, `option`, refers to the option name.
      --
      -- @since 3.0.0
      -- @since 4.4.0 The `option` parameter was added.
      -- @since 4.7.0 The `network_id` parameter was added.
      --
      -- @param string option     Option name.
      -- @param int    network_id ID of the network.
      --
      Do_Action ("pre_delete_site_option_" & Option, Option, Network_Id_2);

      if not Is_Multisite then
         Unused := Delete_Option (Option);
      else
         declare
            Success : Boolean;

            Statement : constant Statement_Type :=
              Globals.WpDB.Prepare (
                "SELECT meta_id FROM {wpdb->sitemeta} " &
                "WHERE meta_key = %s AND site_id = %d",
                To_List (List => (
                  1 => +Option,
                  2 => +Helpers.Image (Network_Id_2)
                ))
              );

            Row : constant Array_Type :=
              Globals.WpDB.Get_Row (Statement, Success => Success);

            Cache_Key : constant String := "network_id:option";
         begin
            if
              Row = Empty_Array -- or else -- Is_Null (Row) or else
--            not Row.Meta_Id
            then
               return False;
            end if;
            Wp_Cache_Delete (Cache_Key, "site-options");

            Result :=
              Globals.WpDB.Delete (
                -Globals.WpDB.Sitemeta,
                To_Array (List => (
                  Build ("meta_key", Option),
                  Build ("site_id",  Network_Id_2)
                ))
              );
         end;
      end if;

      if Result.Status in Success | Create_Alter then
         --
         -- Fires after a specific network option has been deleted.
         --
         -- The dynamic portion of the hook name, `option`, refers to the option name.
         --
         -- @since 2.9.0 As "delete_site_option_thenkeyend;"
         -- @since 3.0.0
         -- @since 4.7.0 The `network_id` parameter was added.
         --
         -- @param string option     Name of the network option.
         -- @param int    network_id ID of the network.
         --
         Do_Action ("delete_site_option_" & Option, Option, Network_Id_2);

         --
         -- Fires after a network option has been deleted.
         --
         -- @since 3.0.0
         -- @since 4.7.0 The `network_id` parameter was added.
         --
         -- @param string option     Name of the network option.
         -- @param int    network_id ID of the network.
         --
         Do_Action ("delete_site_option", Option, Network_Id_2);

         return True;
      end if;

      return False;
   end Delete_Network_Option;

   ---------------------------
   -- Update_Network_Option --
   ---------------------------

   function Update_Network_Option (Network_Id : Integer;
                                   Option     : String;
                                   Value      : Multi_Type)
                                   return Boolean
   is
      use Php.Types;
      use UStrings;
      use Wp_Common;
      use Inc_Caches;
      use Class_WpDB;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Plugins;

      Network_Id_2 : Natural := Network_Id;
   begin
      if Network_Id /= 0 and then not Is_Number (Network_Id) then
         return False;
      end if;

--    network_id = (int) network_id;

      -- Fallback to the current network if a network ID is not specified.
      if Network_Id = 0 then
         Network_Id_2 := Get_Current_Network_Id;
      end if;

      Wp_Protect_Special_Option (Option);

      declare
         Old_Value : constant Multi_Type :=
           Get_Network_Option (Network_Id_2, Option, From_Boolean (False));

         Value_2 : Multi_Type := Value;
      begin
         --
         -- Filters a specific network option before its value is updated.
         --
         -- The dynamic portion of the hook name, `option`, refers to the option name.
         --
         -- @since 2.9.0 As "pre_update_site_option_" . key
         -- @since 3.0.0
         -- @since 4.4.0 The `option` parameter was added.
         -- @since 4.7.0 The `network_id` parameter was added.
         --
         -- @param mixed  value      New value of the network option.
         -- @param mixed  old_value  Old value of the network option.
         -- @param string option     Option name.
         -- @param int    network_id ID of the network.
         --
         Value_2 := Apply_Filters ("pre_update_site_option_" & Option,
                                   Value_2, Old_Value, Option, Network_Id_2);

         --
         -- If the new and old values are the same, no need to update.
         --
         -- Unserialized values will be adequate in most cases. If the unserialized
         -- data differs, the (maybe) serialized data is checked to avoid
         -- unnecessary database calls for otherwise identical object instances.
         --
         -- See https://core.trac.wordpress.org/ticket/44956
         --
         if
           Value_2 = Old_Value or else
           Maybe_Serialize (As_String (Value_2)) =
           Maybe_Serialize (As_String (Old_Value))
         then
            return False;
         end if;

         if From_Boolean (False) = Old_Value then
            return Add_Network_Option (Network_Id_2, Option, Value_2);
         end if;

         declare
            Found : Boolean;

            Notoptions_Key : constant String := "network_id:notoptions";

            Notoptions     : constant Array_Type :=
              Wp_Cache_Get (Notoptions_Key, "site-options", Found => Found);

            Result : Rows_Result_Type;
            Unused : Boolean;
         begin
            if Is_Array (Notoptions) and then Isset (Notoptions, Option) then
               Delete (Ref (Notoptions, Option));
               Wp_Cache_Set (Notoptions_Key, Notoptions, "site-options");
            end if;

            if not Is_Multisite then
               Unused := Update_Option (Option, Value_2, Autoload => False); -- "no"
            else
               Value_2 := From_String (Sanitize_Option (Option, As_String (Value_2)));

               declare
                  Serialized_Value : constant Multi_Type :=
                    Maybe_Serialize (As_String (Value_2));
               begin
                  Result :=
                    Globals.WpDB.Update (
                      -Globals.WpDB.Sitemeta,
                      To_Array (List => (1 => Build ("meta_value",
                                                     As_String (Serialized_Value)))),
                      To_Array (List => (
                        Build ("site_id",  Network_Id_2),
                        Build ("meta_key", Option)
                      ))
                    );
               end;

               if Result.Status in Success | Create_Alter then
                  declare
                     Cache_Key : constant String := "network_id:option";
                  begin
                     Wp_Cache_Set (Cache_Key, As_Array (Value_2), "site-options");
                  end;
               end if;
            end if;

            if Result.Status in Success | Create_Alter then
               --
               -- Fires after the value of a specific network option has been
               -- successfully updated.
               --
               -- The dynamic portion of the hook name, `option`, refers to the
               -- option name.
               --
               -- @since 2.9.0 As "update_site_option_thenkeyend;"
               -- @since 3.0.0
               -- @since 4.7.0 The `network_id` parameter was added.
               --
               -- @param string option     Name of the network option.
               -- @param mixed  value      Current value of the network option.
               -- @param mixed  old_value  Old value of the network option.
               -- @param int    network_id ID of the network.
               --
               Do_Action ("update_site_option_" & Option, Option,
                          Value_2, Old_Value, Network_Id_2);

               --
               -- Fires after the value of a network option has been successfully
               -- updated.
               --
               -- @since 3.0.0
               -- @since 4.7.0 The `network_id` parameter was added.
               --
               -- @param string option     Name of the network option.
               -- @param mixed  value      Current value of the network option.
               -- @param mixed  old_value  Old value of the network option.
               -- @param int    network_id ID of the network.
               --
               Do_Action ("update_site_option", Option,
                          Value_2, Old_Value, Network_Id_2);

               return True;
            end if;
         end;
      end;
      return False;
   end Update_Network_Option;

   ---------------------------
   -- Delete_Site_Transient --
   ---------------------------

   procedure Delete_Site_Transient (Transient : String)
   is
      use Inc_Caches;
      use Inc_Load;
      use Inc_Plugins;

      Result : Boolean;
   begin
      --
      -- Fires immediately before a specific site transient is deleted.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      -- name.
      --
      -- @since 3.0.0
      --
      -- @param string transient Transient name.
      --
      Do_Action ("delete_site_transient_" & Transient, Transient);

      if
        Wp_Using_Ext_Object_Cache or else
        Wp_Installing
      then
         Result := Wp_Cache_Delete (Transient, "site-transient");
      else
         declare
            Option_Timeout : constant String :=
              "_site_transient_timeout_" & Transient;

            Option : constant String := "_site_transient_" & Transient;
         begin
            Result := Delete_Site_Option (Option);

            if Result then
               Delete_Site_Option (Option_Timeout);
            end if;
         end;
      end if;

      if Result then
         --
         -- Fires after a transient is deleted.
         --
         -- @since 3.0.0
         --
         -- @param string transient Deleted transient name.
         --
         Do_Action ("deleted_site_transient", Transient);
      end if;

--    return Result;
   end Delete_Site_Transient;

-- --
-- -- Retrieves the value of a site transient.
-- --
-- -- If the transient does not exist, does not have a value, or has expired,
-- -- then the return value will be false.
-- --
-- -- @since 2.9.0
-- --
-- -- @see get_transient()
-- --
-- -- @param string transient Transient name. Expected to not be SQL-escaped.
-- -- @return mixed Value of transient.
-- --
-- function get_site_transient( transient ) then
   function Get_Site_Transient (Transient : String)
                                return String_Maps.Map
   is
      use Ada.Strings.Unbounded;
      use Php.Lists;
      use Php.Misc;
      use Php.Strings;
      use UStrings;
      use Inc_Caches;
      use Inc_Load;

      Found : Boolean;
      Value : Unbounded_String; -- Array_Type;
   begin
      --
      -- Filters the value of an existing site transient before it is retrieved.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      --  name.
      --
      -- Returning a value other than boolean false will short-circuit retrieval and
      -- return that value instead.
      --
      -- @since 2.9.0
      -- @since 4.4.0 The `transient` parameter was added.
      --
      -- @param mixed  pre_site_transient The default value to return if the site
      --                                  transient does not exist. Any value other
      --                                  than false will short-circuit the retrieval
      --                                  of the transient, and return that value.
      -- @param string transient          Transient name.
      --
--    Pre := Apply_Filters ("pre_site_transient_" & Transient, False, Transient);

      -- -- if False /= Pre then
      -- --    return Pre;
      -- -- end if;

      if
        Wp_Using_Ext_Object_Cache -- or else
--      Wp_Installing
      then
         Value := +Wp_Cache_Get (Transient, "site-transient", Found => Found);
      else
         -- Core transients that do not have a timeout. Listed here so querying
         -- timeouts can be avoided.
         declare
            No_Timeout : constant List_Type :=
              To_List (List => (+"update_core",
                                +"update_plugins",
                                +"update_themes"));
            Transient_Option : constant String := "_site_transient_" & Transient;
         begin
            if not In_List (Transient, No_Timeout, True) then
               declare
                  Transient_Timeout : constant String :=
                    "_site_transient_timeout_" & Transient;

                  Timeout : constant Natural := 0; -- ???
--                  As_Integer (Get_Site_Option (Transient_Timeout));
               begin
                  if 0 /= Timeout and then Timeout < Time then -- false =
                     Delete_Site_Option (Transient_Option);
                     Delete_Site_Option (Transient_Timeout);
                     Value := +""; -- False;
                  end if;
               end;
            end if;

            if not Isset (-Value) then
               Value := +As_String (Get_Site_Option (Transient_Option));
            end if;
         end;
      end if;

      --
      -- Filters the value of an existing site transient.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      --  name.
      --
      -- @since 2.9.0
      -- @since 4.4.0 The `transient` parameter was added.
      --
      -- @param mixed  value     Value of site transient.
      -- @param string transient Transient name.
      --
      declare
         use Inc_Plugins;

         M : String_Maps.Map;
         R : constant String :=
           Apply_Filters ("site_transient_" & Transient, -Value, Transient);
      begin
         M.Include (R, R);
         return M;
      end;
   end Get_Site_Transient;

   ------------------------
   -- Set_Site_Transient --
   ------------------------

   function Set_Site_Transient (Transient  : String;
                                Value      : Array_Type;
                                Expiration : Integer := 0)
                                return Boolean
   is
      use Php.Misc;
      use Inc_Caches;
      use Inc_Load;
      use Inc_Plugins;

      --
      -- Filters the value of a specific site transient before it is set.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the
      -- transient name.
      --
      -- @since 3.0.0
      -- @since 4.4.0 The `transient` parameter was added.
      --
      -- @param mixed  value     New value of site transient.
      -- @param string transient Transient name.
      --
      Value_2 : constant Array_Type :=
        Apply_Filters ("pre_set_site_transient_" & Transient, Value, Transient);

--    expiration = (int) expiration;

      --
      -- Filters the expiration for a site transient before its value is set.
      --
      -- The dynamic portion of the hook name, `transient`, refers to the transient
      -- name.
      --
      -- @since 4.4.0
      --
      -- @param int    expiration Time until expiration in seconds. Use 0 for no
      --                           expiration.
      -- @param mixed  value      New value of site transient.
      -- @param string transient  Transient name.
      --
      Expiration_2 : constant Integer :=
        Apply_Filters ("expiration_of_site_transient_" & Transient,
                       Expiration, Value_2, Transient);

      Result : Boolean;
   begin
      if Wp_Using_Ext_Object_Cache or else Wp_Installing then
         Wp_Cache_Set (Transient, From_Array (Value_2),
                       "site-transient", Expiration_2, Success => Result);
      else
         declare
            Transient_Timeout : constant String :=
              "_site_transient_timeout_" & Transient;

            Option : constant String := "_site_transient_" & Transient;
         begin
            if From_Boolean (False) = Get_Site_Option (Option) then
               if Expiration_2 /= 0 then
                  Add_Site_Option (Transient_Timeout,
                                   From_Integer (Time + Expiration_2));
               end if;
               Result := Add_Site_Option (Option, From_Array (Value_2));
            else
               if Expiration_2 /= 0 then
                  Update_Site_Option (Transient_Timeout,
                                      From_Integer (Time + Expiration_2));
               end if;
               Result := Update_Site_Option (Option, From_Array (Value_2));
            end if;
         end;
      end if;

      if Result then
         --
         -- Fires after the value for a specific site transient has been set.
         --
         -- The dynamic portion of the hook name, `transient`, refers to the
         -- transient name.
         --
         -- @since 3.0.0
         -- @since 4.4.0 The `transient` parameter was added
         --
         -- @param mixed  value      Site transient value.
         -- @param int    expiration Time until expiration in seconds.
         -- @param string transient  Transient name.
         --
         Do_Action ("set_site_transient_" & Transient,
                    Value_2, Expiration_2, Transient);

         --
         -- Fires after the value for a site transient has been set.
         --
         -- @since 3.0.0
         --
         -- @param string transient  The name of the site transient.
         -- @param mixed  value      Site transient value.
         -- @param int    expiration Time until expiration in seconds.
         --
         Do_Action ("setted_site_transient", Transient,
                    Value_2, Expiration_2);
      end if;

      return Result;
   end Set_Site_Transient;

   procedure Set_Site_Transient (Transient  : String;
                                 Value      : Array_Type;
                                 Expiration : Integer := 0)
   is
      Unused : constant Boolean :=
        Set_Site_Transient (Transient, Value, Expiration);
   begin
      null;
   end Set_Site_Transient;

-- --
-- -- Registers default settings available in WordPress.
-- --
-- -- The settings registered here are primarily useful for the REST API, so this
-- -- does not encompass all settings available in WordPress.
-- --
-- -- @since 4.7.0
-- -- @since 6.0.1 The `show_on_front`, `page_on_front`, and `page_for_posts` options were added.
-- --
-- function register_initial_settings() then
--         register_setting(
--                 "general",
--                 "blogname",
--                 array(
--                         "show_in_rest" => array(
--                                 "name" => "title",
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "Site title." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "blogdescription",
--                 array(
--                         "show_in_rest" => array(
--                                 "name" => "description",
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "Site tagline." ),
--                 )
--         );

--         if ( ! is_multisite() ) then
--                 register_setting(
--                         "general",
--                         "siteurl",
--                         array(
--                                 "show_in_rest" => array(
--                                         "name"   => "url",
--                                         "schema" => array(
--                                                 "format" => "uri",
--                                         ),
--                                 ),
--                                 "type"         => "string",
--                                 "description"  => __( "Site URL." ),
--                         )
--                 );
--         end;

--         if ( ! is_multisite() ) then
--                 register_setting(
--                         "general",
--                         "admin_email",
--                         array(
--                                 "show_in_rest" => array(
--                                         "name"   => "email",
--                                         "schema" => array(
--                                                 "format" => "email",
--                                         ),
--                                 ),
--                                 "type"         => "string",
--                                 "description"  => __( "This address is used for admin purposes, like new user notification." ),
--                         )
--                 );
--         end;

--         register_setting(
--                 "general",
--                 "timezone_string",
--                 array(
--                         "show_in_rest" => array(
--                                 "name" => "timezone",
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "A city in the same timezone as you." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "date_format",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "string",
--                         "description"  => __( "A date format for all date strings." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "time_format",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "string",
--                         "description"  => __( "A time format for all time strings." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "start_of_week",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "A day number of the week that the week should start on." ),
--                 )
--         );

--         register_setting(
--                 "general",
--                 "WPLANG",
--                 array(
--                         "show_in_rest" => array(
--                                 "name" => "language",
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "WordPress locale code." ),
--                         "default"      => "en_US",
--                 )
--         );

--         register_setting(
--                 "writing",
--                 "use_smilies",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "boolean",
--                         "description"  => __( "Convert emoticons like :-) and :-P to graphics on display." ),
--                         "default"      => true,
--                 )
--         );

--         register_setting(
--                 "writing",
--                 "default_category",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "Default post category." ),
--                 )
--         );

--         register_setting(
--                 "writing",
--                 "default_post_format",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "string",
--                         "description"  => __( "Default post format." ),
--                 )
--         );

--         register_setting(
--                 "reading",
--                 "posts_per_page",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "Blog pages show at most." ),
--                         "default"      => 10,
--                 )
--         );

--         register_setting(
--                 "reading",
--                 "show_on_front",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "string",
--                         "description"  => __( "What to show on the front page" ),
--                 )
--         );

--         register_setting(
--                 "reading",
--                 "page_on_front",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "The ID of the page that should be displayed on the front page" ),
--                 )
--         );

--         register_setting(
--                 "reading",
--                 "page_for_posts",
--                 array(
--                         "show_in_rest" => true,
--                         "type"         => "integer",
--                         "description"  => __( "The ID of the page that should display the latest posts" ),
--                 )
--         );

--         register_setting(
--                 "discussion",
--                 "default_ping_status",
--                 array(
--                         "show_in_rest" => array(
--                                 "schema" => array(
--                                         "enum" => array( "open", "closed" ),
--                                 ),
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "Allow link notifications from other blogs (pingbacks and trackbacks) on new articles." ),
--                 )
--         );

--         register_setting(
--                 "discussion",
--                 "default_comment_status",
--                 array(
--                         "show_in_rest" => array(
--                                 "schema" => array(
--                                         "enum" => array( "open", "closed" ),
--                                 ),
--                         ),
--                         "type"         => "string",
--                         "description"  => __( "Allow people to submit comments on new posts." ),
--                 )
--         );
-- end;

-- --
-- -- Registers a setting and its data.
-- --
-- -- @since 2.7.0
-- -- @since 3.0.0 The `misc` option group was deprecated.
-- -- @since 3.5.0 The `privacy` option group was deprecated.
-- -- @since 4.7.0 `args` can be passed to set flags on the setting, similar to `register_meta()`.
-- -- @since 5.5.0 `new_whitelist_options` was renamed to `new_allowed_options`.
-- --              Please consider writing more inclusive code.
-- --
-- -- @global array new_allowed_options
-- -- @global array wp_registered_settings
-- --
-- -- @param string option_group A settings group name. Should correspond to an allowed option key name.
-- --                             Default allowed option key names include "general", "discussion", "media",
-- --                             "reading", "writing", and "options".
-- -- @param string option_name The name of an option to sanitize and save.
-- -- @param array  args then
-- --     Data used to describe the setting when registered.
-- --
-- --     @type string     type              The type of data associated with this setting.
-- --                                         Valid values are "string", "boolean", "integer", "number", "array", and "object".
-- --     @type string     description       A description of the data attached to this setting.
-- --     @type callable   sanitize_callback A callback function that sanitizes the option"s value.
-- --     @type bool|array show_in_rest      Whether data associated with this setting should be included in the REST API.
-- --                                         When registering complex settings, this argument may optionally be an
-- --                                         array with a "schema" key.
-- --     @type mixed      default           Default value when calling `get_option()`.
-- -- end;
-- --
-- function register_setting( option_group, option_name, args = array() ) then
--         global new_allowed_options, wp_registered_settings;

--         /*
--         -- In 5.5.0, the `new_whitelist_options` global variable was renamed to `new_allowed_options`.
--         -- Please consider writing more inclusive code.
--         --
--         GLOBALS["new_whitelist_options"] = &new_allowed_options;

--         defaults = array(
--                 "type"              => "string",
--                 "group"             => option_group,
--                 "description"       => "",
--                 "sanitize_callback" => null,
--                 "show_in_rest"      => false,
--         );

--         // Back-compat: old sanitize callback is added.
--         if ( is_callable( args ) ) then
--                 args = array(
--                         "sanitize_callback" => args,
--                 );
--         end;

--         --
--         -- Filters the registration arguments when registering a setting.
--         --
--         -- @since 4.7.0
--         --
--         -- @param array  args         Array of setting registration arguments.
--         -- @param array  defaults     Array of default arguments.
--         -- @param string option_group Setting group.
--         -- @param string option_name  Setting name.
--         --
--         args = apply_filters( "register_setting_args", args, defaults, option_group, option_name );

--         args = wp_parse_args( args, defaults );

--         // Require an item schema when registering settings with an array type.
--         if ( false !== args["show_in_rest"] && "array" === args["type"] && ( ! is_array( args["show_in_rest"] ) || ! isset( args["show_in_rest"]["schema"]["items"] ) ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( "When registering an "array" setting to show in the REST API, you must specify the schema for each array item in "show_in_rest.schema.items"." ), "5.4.0" );
--         end;

--         if ( ! is_array( wp_registered_settings ) ) then
--                 wp_registered_settings = array();
--         end;

--         if ( "misc" === option_group ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "3.0.0",
--                         sprintf(
--                                 /* translators: %s: misc--
--                                 __( "The "%s" options group has been removed. Use another settings group." ),
--                                 "misc"
--                         )
--                 );
--                 option_group = "general";
--         end;

--         if ( "privacy" === option_group ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "3.5.0",
--                         sprintf(
--                                 /* translators: %s: privacy--
--                                 __( "The "%s" options group has been removed. Use another settings group." ),
--                                 "privacy"
--                         )
--                 );
--                 option_group = "reading";
--         end;

--         new_allowed_options[ option_group ][] = option_name;

--         if ( ! empty( args["sanitize_callback"] ) ) then
--                 add_filter( "sanitize_option_thenoption_nameend;", args["sanitize_callback"] );
--         end;
--         if ( array_key_exists( "default", args ) ) then
--                 add_filter( "default_option_thenoption_nameend;", "filter_default_option", 10, 3 );
--         end;

--         --
--         -- Fires immediately before the setting is registered but after its filters are in place.
--         --
--         -- @since 5.5.0
--         --
--         -- @param string option_group Setting group.
--         -- @param string option_name  Setting name.
--         -- @param array  args         Array of setting registration arguments.
--         --
--         do_action( "register_setting", option_group, option_name, args );

--         wp_registered_settings[ option_name ] = args;
-- end;

-- --
-- -- Unregisters a setting.
-- --
-- -- @since 2.7.0
-- -- @since 4.7.0 `sanitize_callback` was deprecated. The callback from `register_setting()` is now used instead.
-- -- @since 5.5.0 `new_whitelist_options` was renamed to `new_allowed_options`.
-- --              Please consider writing more inclusive code.
-- --
-- -- @global array new_allowed_options
-- -- @global array wp_registered_settings
-- --
-- -- @param string   option_group The settings group name used during registration.
-- -- @param string   option_name  The name of the option to unregister.
-- -- @param callable deprecated   Optional. Deprecated.
-- --
-- function unregister_setting( option_group, option_name, deprecated = "" ) then
--         global new_allowed_options, wp_registered_settings;

--         /*
--         -- In 5.5.0, the `new_whitelist_options` global variable was renamed to `new_allowed_options`.
--         -- Please consider writing more inclusive code.
--         --
--         GLOBALS["new_whitelist_options"] = &new_allowed_options;

--         if ( "misc" === option_group ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "3.0.0",
--                         sprintf(
--                                 /* translators: %s: misc--
--                                 __( "The "%s" options group has been removed. Use another settings group." ),
--                                 "misc"
--                         )
--                 );
--                 option_group = "general";
--         end;

--         if ( "privacy" === option_group ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "3.5.0",
--                         sprintf(
--                                 /* translators: %s: privacy--
--                                 __( "The "%s" options group has been removed. Use another settings group." ),
--                                 "privacy"
--                         )
--                 );
--                 option_group = "reading";
--         end;

--         pos = array_search( option_name, (array) new_allowed_options[ option_group ], true );

--         if ( false !== pos ) then
--                 unset( new_allowed_options[ option_group ][ pos ] );
--         end;

--         if ( "" !== deprecated ) then
--                 _deprecated_argument(
--                         __FUNCTION__,
--                         "4.7.0",
--                         sprintf(
--                                 /* translators: 1: sanitize_callback, 2: register_setting()--
--                                 __( "%1s is deprecated. The callback from %2s is used instead." ),
--                                 "<code>sanitize_callback</code>",
--                                 "<code>register_setting()</code>"
--                         )
--                 );
--                 remove_filter( "sanitize_option_thenoption_nameend;", deprecated );
--         end;

--         if ( isset( wp_registered_settings[ option_name ] ) ) then
--                 // Remove the sanitize callback if one was set during registration.
--                 if ( ! empty( wp_registered_settings[ option_name ]["sanitize_callback"] ) ) then
--                         remove_filter( "sanitize_option_thenoption_nameend;", wp_registered_settings[ option_name ]["sanitize_callback"] );
--                 end;

--                 // Remove the default filter if a default was provided during registration.
--                 if ( array_key_exists( "default", wp_registered_settings[ option_name ] ) ) then
--                         remove_filter( "default_option_thenoption_nameend;", "filter_default_option", 10 );
--                 end;

--                 --
--                 -- Fires immediately before the setting is unregistered and after its filters have been removed.
--                 --
--                 -- @since 5.5.0
--                 --
--                 -- @param string option_group Setting group.
--                 -- @param string option_name  Setting name.
--                 --
--                 do_action( "unregister_setting", option_group, option_name );

--                 unset( wp_registered_settings[ option_name ] );
--         end;
-- end;

-- --
-- -- Retrieves an array of registered settings.
-- --
-- -- @since 4.7.0
-- --
-- -- @global array wp_registered_settings
-- --
-- -- @return array List of registered settings, keyed by option name.
-- --
-- function get_registered_settings() then
--         global wp_registered_settings;

--         if ( ! is_array( wp_registered_settings ) ) then
--                 return array();
--         end;

--         return wp_registered_settings;
-- end;

-- --
-- -- Filters the default value for the option.
-- --
-- -- For settings which register a default setting in `register_setting()`, this
-- -- function is added as a filter to `default_option_thenoptionend;`.
-- --
-- -- @since 4.7.0
-- --
-- -- @param mixed  default        Existing default value to return.
-- -- @param string option         Option name.
-- -- @param bool   passed_default Was `get_option()` passed a default value?
-- -- @return mixed Filtered default value.
-- --
-- function filter_default_option( default, option, passed_default ) then
--         if ( passed_default ) then
--                 return default;
--         end;

--         registered = get_registered_settings();
--         if ( empty( registered[ option ] ) ) then
--                 return default;
--         end;

--         return registered[ option ]["default"];
-- end;

end Inc_Options;
