--
-- WP_Theme_JSON_Resolver class
--
-- @package WordPress
-- @subpackage Theme
-- @since 5.8.0
--

with Php.Arrays;
with Php.Errors;
with Php.Files;
with Php.HTML;
with Php.JSON;
with Php.Strings;
with Php.Types;

with Constants;
with Helpers;

with Inc_Block_Editors;
-- with Class_Block_Type;
with Class_Block_Type_Registry;
with Class_Posts;
with Class_Querys;
with Class_Theme_JSON_Data;
with Inc_Functions;
with Inc_L10n;
-- with Inc_Plugins;
with Inc_Posts;
with Inc_Themes;

package body Class_Theme_JSON_Resolver
is

   package JSON_Data renames Class_Theme_JSON_Data;

   function Apply_Filters (Name : String;
                           Item : JSON_Data.Wp_Theme_JSON_Data)
                           return JSON_Data.Wp_Theme_JSON_Data
                           is (Item);

   --------------------
   -- Read_JSON_File --
   --------------------

   function Read_JSON_File (File_Path : String)
                            return Array_Type
   is
      use Php.Arrays;
      use Php.Types;
      use Array_Lists;
      use Inc_Functions;
   begin
      if File_Path /= "" then
         if Array_Key_Exists (File_Path, Static_Theme_JSON_File_Cache) then
            return As_Array (Get (Static_Theme_JSON_File_Cache, File_Path));
         end if;

         declare
            Decoded_File : constant Array_Type :=
              Wp_JSON_File_Decode (File_Path, To_Array_Type ([
                                   Build ("associative", True)]));
         begin
            if Is_Array (Decoded_File) then
               Set (Static_Theme_JSON_File_Cache, File_Path, From_Array (Decoded_File));
               return As_Array (Get (Static_Theme_JSON_File_Cache, File_Path));
            end if;
         end;
      end if;

      return Empty_Array;
   end Read_JSON_File;

--         --
--         -- Returns a data structure used in theme.json translation.
--         --
--         -- @since 5.8.0
--         -- @deprecated 5.9.0
--         --
--         -- @return array An array of theme.json fields that are translatable and the keys that are translatable.
--         --
--         public static function get_fields_to_translate() then
--                 _deprecated_function( __METHOD__, "5.9.0" );
--                 return array();
--         end;

   ---------------
   -- Translate --
   ---------------

   function Translate (Theme_JSON : Array_Type;
                       Domain     : String := "default")
                       return Array_Type
   is
      use Inc_Functions;
      use Inc_L10n;
   begin
      if Empty_Array = Static_I18n_Schema then
         declare
            I18n_Schema : Array_Type :=
              Wp_JSON_File_Decode (Constants.X_DIR_X & "/theme-i18n.json");
         begin
            Static_I18n_Schema := (if Empty_Array = I18n_Schema
                                   then Empty_Array else I18n_Schema);
         end;
      end if;

      return
        Translate_Settings_Using_I18n_Schema
          (I18n_Schema => As_String (From_Array (Static_I18n_Schema)),
           Settings    => Theme_JSON,
           Textdomain  => Domain);

   end Translate;

   -------------------
   -- Get_Core_Data --
   -------------------

   function Get_Core_Data
            return Class_Theme_JSON.Wp_Theme_JSON
   is
      use Class_Theme_JSON;
      use Class_Theme_JSON_Data;
--    use Inc_Plugins;
   begin
      if
        Null_Theme_JSON /= Static_Core and then
        Has_Same_Registered_Blocks ("core") -- static::
      then
         return Static_Core;
      end if;

      declare
         Config_3 : constant Array_Type :=
           Read_JSON_File (Constants.X_DIR_X & "/theme.json");     -- static::

         Config_2 : constant Array_Type := Translate (Config_3); -- static::

         --
         -- Filters the default data provided by WordPress for global styles & settings.
         --
         -- @since 6.1.0
         --
         -- @param WP_Theme_JSON_Data Class to access and update the underlying data.
         --
         Data : constant Wp_Theme_JSON_Data := X_Construct (Config_2, "default");

         Theme_JSON : constant Wp_Theme_JSON_Data :=
           Apply_Filters ("wp_theme_json_data_default", Data);
--                        new Wp_Theme_JSON_Data (Config_2, "default"));
         Config : constant Array_Type    := Theme_JSON.Get_Data;
         Theme  : constant Wp_Theme_JSON := X_Construct (Config, "default");
      begin
         Static_Core := Theme;

         return Static_Core;
      end;
   end Get_Core_Data;

   --------------------------------
   -- Has_Same_Registered_Blocks --
   --------------------------------

   function Has_Same_Registered_Blocks (Origin : String)
                                        return Boolean
   is
      use Php.Arrays;
--    use Class_Block_Type;
      use Class_Block_Type_Registry;
   begin
      -- Bail out if the origin is invalid.
      if not Isset (Static_Blocks_Cache, Origin) then
         return False;
      end if;

      declare
         Registry : constant Wp_Block_Type_Registry :=
           Class_Block_Type_Registry.Get_Instance; -- :: ()

         Blocks : constant Array_Type := From_Map (Registry.Get_All_Registered);
--       Blocks : Wp_Block_Type_Array := Registry.Get_All_Registered;

         -- Is there metadata for all currently registered blocks?
         Block_Diff : constant Array_Type :=
           Array_Diff_Key (Blocks, As_Array (Get (Static_Blocks_Cache, Origin)));
      begin
         if Empty (Block_Diff) then
            return True;
         end if;

         for A in Blocks.Iterate loop
            declare
               Block_Name : constant String := Key (A);
--             Block_Type : String := Array_Maps.Element (A);
            begin
               Set (Static_Blocks_Cache, Origin, From_Array (Build (Block_Name, True)));
--             Static_Blocks_Cache (Origin) (Block_Name) := True;
            end;
         end loop;
      end;
      return False;
   end Has_Same_Registered_Blocks;

   --------------------
   -- Get_Theme_Data --
   --------------------

   function Get_Theme_Data (Deprecated : Array_Type := Empty_Array;
                            Options    : Array_Type := Empty_Array)
                            return Class_Theme_JSON.Wp_Theme_JSON
   is
      use Array_Lists;
      use Class_Themes;
      use Class_Theme_JSON;
      use Class_Theme_JSON_Data;
      use Inc_Functions;
      use Inc_Themes;

      Options_2 : constant Array_Type :=
        Wp_Parse_Args (Options, To_Array_Type ([
                       Build ("with_supports", True)]));
   begin
      if not Deprecated.Is_Empty then
         X_Deprecated_Argument ("__METHOD__", "5.9.0");
      end if;

      if
        Null_Theme_JSON = Static_Theme or else
        not Has_Same_Registered_Blocks ("theme")
      then -- 2x ::static
         declare
            Theme_JSON_File : constant String  := Get_File_Path_From_Theme ("theme.json"); -- static::
            Wp_Theme        : Class_Themes.Wp_Theme := Inc_Themes.Wp_Get_Theme;
            Theme_JSON_Data : Array_Type;
            Theme_JSON      : Wp_Theme_JSON_Data;
         begin
            if "" /= Theme_JSON_File then
               Theme_JSON_Data := Read_JSON_File (Theme_JSON_File); -- static::
               Theme_JSON_Data := Translate (Theme_JSON_Data, Wp_Theme.Get ("TextDomain")); -- static::
            else
               Theme_JSON_Data := Empty_Array;
            end if;

            --
            -- Filters the data provided by the theme for global styles and settings.
            --
            -- @since 6.1.0
            --
            -- @param WP_Theme_JSON_Data Class to access and update the underlying data.
            --
            declare
               JSON_Data : constant Wp_Theme_JSON_Data := X_Construct (Theme_JSON_Data, "theme");
            begin
               Theme_JSON      := Apply_Filters ("wp_theme_json_data_theme", JSON_Data);
               Theme_JSON_Data := Theme_JSON.Get_Data;
               declare
                  Theme_Data : constant Wp_Theme_JSON := X_Construct (Theme_JSON_Data);
               begin
                  Static_Theme := Theme_Data;
               end;
            end;

            if Wp_Theme.Parent /= Null_Theme then -- ()
               -- Get parent theme.json.
               declare
                  Parent_Theme_JSON_File : constant String :=
                    Get_File_Path_From_Theme ("theme.json", True); -- static::
               begin
                  if "" /= Parent_Theme_JSON_File then
                     declare
                        Parent_Theme_JSON_Data_2 : constant Array_Type :=
                          Read_JSON_File (Parent_Theme_JSON_File); -- static::

                        Parent_Theme_JSON_Data : constant Array_Type :=
                          Translate (Parent_Theme_JSON_Data_2,
                                     Wp_Theme.M_Parent.Get ("TextDomain")); -- static::

                        Parent_Theme : Wp_Theme_JSON :=
                          X_Construct (Parent_Theme_JSON_Data);
--                      Parent_Theme := new WP_Theme_JSON( parent_theme_json_data );
                     begin
                        --
                        -- Merge the child theme.json into the parent theme.json.
                        -- The child theme takes precedence over the parent.
                        --
                        Parent_Theme.Merge (Static_Theme); -- static::
                        Static_Theme := Parent_Theme;      -- static::
                     end;
                  end if;
               end;
            end if;
         end;
      end if;

      if "" = Get_As_String (Options_2, "with_supports") then -- not
         return Static_Theme; -- static::
      end if;

      --
      -- We want the presets and settings declared in theme.json
      -- to override the ones declared via theme supports.
      -- So we take theme supports, transform it to theme.json shape
      -- and merge the static::theme upon that.
      --
      declare
         Theme_Support_Data : Array_Type :=
           Class_Theme_JSON.Get_From_Editor_Settings (
             Inc_Block_Editors.Get_Default_Block_Editor_Settings);
      begin
         if not Theme_Has_Support then -- static::
            declare
               Default_Palette   : Boolean;
               Default_Gradients : Boolean;
            begin
               if not Isset_2 (Theme_Support_Data, "settings", "color") then
                  Set_2 (Theme_Support_Data,
                         Key_1 => "settings",
                         Key_2 => "color",
                         Value => From_Array (Empty_Array));
               end if;

               Default_Palette := False;
               if Current_Theme_Supports ("default-color-palette") then
                  Default_Palette := True;
               end if;

               if not Isset_3 (Theme_Support_Data, "settings", "color", "palette") then
                  -- If the theme does not have any palette, we still want to show
                  -- the core one.
                  Default_Palette := True;
               end if;
               Set_3 (Theme_Support_Data,
                      Key_1 => "settings",
                      Key_2 => "color",
                      Key_3 => "defaultPalette",
                      Value => From_Boolean (Default_Palette));

               Default_Gradients := False;
               if Current_Theme_Supports ("default-gradient-presets") then
                  Default_Gradients := True;
               end if;

               if not Isset_3 (Theme_Support_Data, "settings", "color", "gradients") then
                  -- If the theme does not have any gradients, we still want to show the core ones.
                  Default_Gradients := True;
               end if;
               Set_3 (Theme_Support_Data,
                      Key_1 => "settings",
                      Key_2 => "color",
                      Key_3 => "defaultGradients",
                      Value => From_Boolean (Default_Gradients));

               -- Classic themes without a theme.json don't support global duotone.
               Set_3 (Theme_Support_Data,
                      Key_1 => "settings",
                      Key_2 => "color",
                      Key_3 => "defaultDuotone",
                      Value => From_Boolean (False));
            end;
         end if;

         declare
            With_Theme_Supports : Wp_Theme_JSON := X_Construct (Theme_Support_Data);
--          With_Theme_Supports = new WP_Theme_JSON( theme_support_data );
         begin
            With_Theme_Supports.Merge (Static_Theme); -- static::
            return With_Theme_Supports;
         end;
      end;
   end Get_Theme_Data;

   --------------------
   -- Get_Block_Data --
   --------------------

   function Get_Block_Data
            return Class_Theme_JSON.Wp_Theme_JSON
   is
      use Array_Lists;
      use Class_Block_Type_Registry;
      use Class_Theme_JSON;
      use Class_Theme_JSON_Data;
      use Inc_Functions;

      Registry : constant Wp_Block_Type_Registry :=
        Class_Block_Type_Registry.Get_Instance;

      Blocks   : constant Array_Type := From_Map (Registry.Get_All_Registered);
      Config   : Array_Type := To_Array_Type ([Build ("version", 2)]);
   begin
      if
        Null_Theme_JSON /= Static_Blocks and then
        Has_Same_Registered_Blocks ("blocks")
      then
         return Static_Blocks;
      end if;

      for A in Blocks.Iterate loop
         declare
            Block_Name : constant String     := Key (A);
            Block_Type : constant Multi_Type := Element (A);
         begin
            if Isset (As_Array (Block_Type), "__experimentalStyle") then -- supports
               Set_3 (Config,
                      Key_1 => "styles",
                      Key_2 => "blocks",
                      Key_3 => Block_Name,
                      Value => From_Array (
                        Remove_JSON_Comments (As_Array (Get (As_Array (Block_Type),
                                              "__experimentalStyle")))));
            end if;

            if
              Isset_3 (As_Array (Block_Type), "spacing", "blockGap", "__experimentalDefault")
              and then -- supports
              "" = As_String (X_Wp_Array_Get (Config,
                                              List_Type'["styles", "blocks",
                                                         Block_Name,
                                                         "spacing", "blockGap"]))
--            null = X_Wp_Array_Get (Config, list_type'["styles", "blocks", Block_Name, "spacing", "blockGap"], null)
            then
               -- Ensure an empty placeholder value exists for the block, if it
               -- provides a default blockGap value. The real blockGap value to be
               --  used will be determined when the styles are rendered for output.
               Set_5 (Config,
                      Key_1 => "styles",
                      Key_2 => "blocks",
                      Key_3 => Block_Name,
                      Key_4 => "spacing",
                      Key_5 => "blockGap",
                      Value => Null_Multi_Type);
            end if;
         end;
      end loop;

      --
      -- Filters the data provided by the blocks for global styles & settings.
      --
      -- @since 6.1.0
      --
      -- @param WP_Theme_JSON_Data Class to access and update the underlying data.
      --
      declare
         Theme_JSON_Data : constant Wp_Theme_JSON_Data := X_Construct (Config, "blocks");

         Theme_JSON      : constant Wp_Theme_JSON_Data :=
           Apply_Filters ("wp_theme_json_data_blocks", Theme_JSON_Data);

         Config          : constant Array_Type := Theme_JSON.Get_Data;
         Theme_Blocks    : constant Wp_Theme_JSON := X_Construct (Config, "blocks");
      begin
         Static_Blocks := Theme_Blocks;
      end;
      return Static_Blocks;
   end Get_Block_Data;

   --------------------------
   -- Remove_JSON_Comments --
   --------------------------

   function Remove_JSON_Comments (Arry : Array_Type)
                                  return Array_Type
   is
--    use UStrings;

      Arry_2 : Array_Type := Arry;
   begin
--    Unset (Arry_2["//"]);
      for A in Arry_2.Iterate loop
         declare
            K : constant String     := Key (A);
            V : constant Multi_Type := Element (A);
         begin
            if Kind_Of (V) = Kind_Array then
--          if Is_Array (V) then
               Set (Arry_2, K, From_Array (Remove_JSON_Comments (As_Array (V))));
            end if;
         end;
      end loop;

      return Arry_2;
   end Remove_JSON_Comments;

   -----------------------------------------
   -- Get_User_Data_From_Wp_Global_Styles --
   -----------------------------------------

   function Get_User_Data_From_Wp_Global_Styles
     (Theme              : Class_Themes.Wp_Theme;
      Create_Post        : Boolean   := False;
      Post_Status_Filter : List_Type := ["publish"])
      return Array_Type
   is
      use Php.HTML;
      use Php.Strings;
      use Array_Lists;
      use Class_Posts;
      use Class_Themes;
      use Class_Querys;
      use Inc_Posts;
      use Inc_Themes;

      Theme_2 : Wp_Theme := (if Theme not in Wp_Theme
                             then Wp_Get_Theme
                             else Theme);
   begin
      --
      -- Bail early if the theme does not support a theme.json.
      --
      -- Since WP_Theme_JSON_Resolver::theme_has_support() only supports the active
      -- theme, the extra condition for whether theme is the active theme is
      -- present here.
      --
      if
        Theme_2.Get_Stylesheet = Get_Stylesheet and then
        not Theme_Has_Support
      then
         return Empty_Array;
      end if;

      declare
         User_CPT         : Array_Type;
         Post_Type_Filter : constant String := "wp_global_styles";
         Stylesheet       : constant String := Theme_2.Get_Stylesheet;

         Args : constant Array_Type := To_Array_Type ([
            Build ("posts_per_page",      1),
            Build ("orderby",             "date"),
            Build ("order",               "desc"),
            Build ("post_type",           Post_Type_Filter),
            Build ("post_status",
                   Post_Status_Filter (Post_Status_Filter.First_Index)),
            Build ("ignore_sticky_posts", True),
            Build ("no_found_rows",       True),
            Build ("tax_query",
                                To_Array_Type ([
                                        Build ("taxonomy", "wp_theme"),
                                        Build ("field",    "name"),
                                        Build ("terms",    Stylesheet)
                                ])
                        )
         ]);

         Global_Style_Query : Wp_Query; -- new ()
         Recent_Posts       : constant Post_Array := Global_Style_Query.Query (Args);
      begin
         if Recent_Posts.Length in 1 then
            User_CPT :=
              Get_Post (Recent_Posts (Recent_Posts.First_Index), "ARRAY_A");
         elsif Create_Post then
            declare
               CPT_Post_Id : Post_Id_Type;
            begin
               CPT_Post_Id :=
                 Wp_Insert_Post (To_Array_Type ([
                   Build ("post_content",
                          "{""version"": " &
                          Helpers.Image (Class_Theme_JSON.LATEST_SCHEMA) &
                          ", ""isGlobalStylesUserThemeJSON"": true }"),
                   Build ("post_status",  "publish"),
                   Build ("post_title",   "Custom Styles"),
                   -- Do not make string translatable,
                   -- see https://core.trac.wordpress.org/ticket/54518.
                   Build ("post_type",    Post_Type_Filter),
                   Build ("post_name",
                          Sprintf ("wp-global-styles-%s",
                                   [1 => URL_Encode (Stylesheet)])),
                   Build ("tax_input",    To_Array_Type ([
                      Build ("wp_theme", Stylesheet) -- To_Array (Stylesheet))
                   ]))
                 ]),
                True);

               -- if not Is_Wp_Error (CPT_Post_Id) then
               --    User_CPT := Get_Post (CPT_Post_Id, "ARRAY_A");
               -- end if;
            end;
         end if;

         return User_CPT;
      end;
   end Get_User_Data_From_Wp_Global_Styles;

   -------------------
   -- Get_User_Data --
   -------------------

   function Get_User_Data
            return Class_Theme_JSON.Wp_Theme_JSON
   is
--    use UStrings;
      use Php.Arrays;
      use Php.Errors;
      use Php.JSON;
      use Php.Types;
      use Class_Theme_JSON;
      use Class_Theme_JSON_Data;
      use Inc_Themes;
   begin
      if
        Null_Theme_JSON /= Static_User and then
        Has_Same_Registered_Blocks ("user")
      then
         return Static_User;
      end if;

      declare
         Config   : Array_Type;
         User_CPT : constant Array_Type := Get_User_Data_From_Wp_Global_Styles (Wp_Get_Theme);
      begin
         if Array_Key_Exists ("post_content", User_CPT) then
            declare
               Decoded_Data : constant Array_Type :=
                 JSON_Decode (Get_As_String (User_CPT, "post_content"), True);

               JSON_Decoding_Error : constant Integer := JSON_Last_Error;
            begin
               if JSON_ERROR_NONE /= JSON_Decoding_Error then
                  Trigger_Error
                    ("Error when decoding a theme.json schema for user data. " &
                     JSON_Last_Error_Msg);
                  --
                  -- Filters the data provided by the user for global styles &
                  -- settings.
                  --
                  -- @since 6.1.0
                  --
                  -- @param WP_Theme_JSON_Data Class to access and update the
                  --                           underlying data.
                  --
                  declare
                     AAA : constant Wp_Theme_JSON_Data := X_Construct (Config, "custom");

                     Theme_JSON : constant Wp_Theme_JSON_Data :=
                       Apply_Filters ("wp_theme_json_data_user", AAA);

                     Config     : constant Array_Type    := Theme_JSON.Get_Data;
                     BBB        : constant Wp_Theme_JSON := X_Construct (Config, "custom");
                  begin
                     return BBB;
                  end;
               end if;

               -- Very important to verify that the flag isGlobalStylesUserThemeJSON
               -- is true. If it's not true then the content was not escaped and is
               -- not safe.
               if
                 Is_Array (Decoded_Data) and then
                 Isset (Decoded_Data, "isGlobalStylesUserThemeJSON") and then
                 Get_As_String (Decoded_Data, "isGlobalStylesUserThemeJSON") /= ""
               then
                  Delete (Ref (Decoded_Data, "isGlobalStylesUserThemeJSON"));
--                Unset (Decoded_Data ("isGlobalStylesUserThemeJSON"));
                  Config := Decoded_Data;
               end if;
            end;
         end if;

         -- This filter is documented in wp-includes/class-wp-theme-json-resolver.php
         declare
            AAA : constant Wp_Theme_JSON_Data := X_Construct (Config, "custom");

            Theme_JSON : constant Wp_Theme_JSON_Data :=
              Apply_Filters ("wp_theme_json_data_user", AAA);

            Config : constant Array_Type    := Theme_JSON.Get_Data;
            BBB    : constant Wp_Theme_JSON := X_Construct (Config, "custom");
         begin
            Static_User := BBB;
         end;
      end;
      return Static_User;
   end Get_User_Data;

   ---------------------
   -- Get_Merged_Data --
   ---------------------

   function Get_Merged_Data (Origin : String := "custom")
                             return Class_Theme_JSON.Wp_Theme_JSON
   is
      use Class_Theme_JSON;

      Result : Wp_Theme_JSON := Get_Core_Data; -- static::
   begin
      -- if Is_Array (Origin) then
      --    X_Deprecated_Argument ("__FUNCTION__", "5.9.0");
      -- end if;

      Result.Merge (Get_Block_Data); -- static::
      Result.Merge (Get_Theme_Data); -- static::

      if "custom" = Origin then
         Result.Merge (Get_User_Data); -- static::
      end if;

      -- Generate the default spacingSizes array based on the merged
      -- spacingScale settings.
      Result.Set_Spacing_Sizes;

      return Result;
   end Get_Merged_Data;

--         --
--         -- Returns the ID of the custom post type
--         -- that stores user data.
--         --
--         -- @since 5.9.0
--         --
--         -- @return integer|null
--         --
--         public static function get_user_global_styles_post_id() then
--                 if ( null !== static::user_custom_post_type_id ) then
--                         return static::user_custom_post_type_id;
--                 end;

--                 user_cpt = static::get_user_data_from_wp_global_styles( wp_get_theme(), true );

--                 if ( array_key_exists( "ID", user_cpt ) ) then
--                         static::user_custom_post_type_id = user_cpt["ID"];
--                 end;

--                 return static::user_custom_post_type_id;
--         end;

   -----------------------
   -- Theme_Has_Support --
   -----------------------

   function Theme_Has_Support
            return Boolean
   is
--    use UStrings;
   begin
      if not Theme_Has_Support then -- static::
         Static_Theme_Has_Support :=
           Get_File_Path_From_Theme ("theme.json") /= "" or else
           Get_File_Path_From_Theme ("theme.json", True) /= "";
      end if;

      return Theme_Has_Support;
   end Theme_Has_Support;

   ------------------------------
   -- Get_File_Path_From_Theme --
   ------------------------------

   function Get_File_Path_From_Theme (File_Name : String;
                                      Template  : Boolean := False)
                                      return String
   is
      use Php.Files;
      use Inc_Themes;

      Path : constant String :=
         (if Template
          then Get_Template_Directory
          else Get_Stylesheet_Directory);

      Candidate : constant String := Path & "/" & File_Name;
   begin
      return (if Is_Readable (Candidate) then Candidate else "");
   end Get_File_Path_From_Theme;

--         --
--         -- Cleans the cached data so it can be recalculated.
--         --
--         -- @since 5.8.0
--         -- @since 5.9.0 Added the `user`, `user_custom_post_type_id`,
--         --              and `i18n_schema` variables to reset.
--         -- @since 6.1.0 Added the `blocks` and `blocks_cache` variables
--         --              to reset.
--         --
--         public static function clean_cached_data() then
--                 static::core                     = null;
--                 static::blocks                   = null;
--                 static::blocks_cache             = array(
--                         "core"   => array(),
--                         "blocks" => array(),
--                         "theme"  => array(),
--                         "user"   => array(),
--                 );
--                 static::theme                    = null;
--                 static::user                     = null;
--                 static::user_custom_post_type_id = null;
--                 static::theme_has_support        = null;
--                 static::i18n_schema              = null;
--         end;

--         --
--         -- Returns the style variations defined by the theme.
--         --
--         -- @since 6.0.0
--         --
--         -- @return array
--         --
--         public static function get_style_variations() then
--                 variations     = array();
--                 base_directory = get_stylesheet_directory() . "/styles";
--                 if ( is_dir( base_directory ) ) then
--                         nested_files      = new RecursiveIteratorIterator( new RecursiveDirectoryIterator( base_directory ) );
--                         nested_html_files = iterator_to_array( new RegexIterator( nested_files, "/^.+\.json/i", RecursiveRegexIterator::GET_MATCH ) );
--                         ksort( nested_html_files );
--                         foreach ( nested_html_files as path => file ) then
--                                 decoded_file = wp_json_file_decode( path, array( "associative" => true ) );
--                                 if ( is_array( decoded_file ) ) then
--                                         translated = static::translate( decoded_file, wp_get_theme()->get( "TextDomain" ) );
--                                         variation  = ( new WP_Theme_JSON( translated ) )->get_raw_data();
--                                         if ( empty( variation["title"] ) ) then
--                                                 variation["title"] = basename( path, ".json" );
--                                         end;
--                                         variations[] = variation;
--                                 end;
--                         end;
--                 end;
--                 return variations;
--         end;

-- end;

end Class_Theme_JSON_Resolver;
