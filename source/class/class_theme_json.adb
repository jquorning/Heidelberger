--
-- WP_Theme_JSON class
--
-- @package WordPress
-- @subpackage Theme
-- @since 5.8.0
--

with Php.Arrays;
with Php.Errors;
with Php.JSON;
with Php.Lists;
with Php.Numerics;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Wp_Common;

with Block_Typography;

with Class_Block_Type;
with Class_Block_Type_Registry;
with Class_Theme_JSON_Schema;
with Inc_Blocks;
with Inc_Formatting;
with Inc_Functions;
with Inc_KSES;
with Inc_L10n;
with Inc_Plugins;
with Inc_Themes;

package body Class_Theme_JSON
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Theme_JSON : Array_Type := Empty_Array;
                         Origin     : String     := "theme")
                         return Wp_Theme_JSON
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use UStrings;
--    use Class_Theme_JSON;
      use Inc_Functions;

      This : Wp_Theme_JSON;

      Origin_2 : constant String :=
        (if not In_List (Origin, VALID_ORIGINS, True) -- static::
         then "theme"
         else Origin);

   begin
      This.Theme_JSON := Class_Theme_JSON_Schema.Migrate (Theme_JSON);
      declare
         Valid_Block_Names : constant List_Type :=
           Array_Keys (Get_Blocks_Metadata);

         Valid_Element_Names : constant List_Type :=
           Array_Keys (ELEMENTS);

         Theme_JSON_2 : constant Array_Type :=
           Sanitize (This.Theme_JSON, Valid_Block_Names, Valid_Element_Names);
      begin
         This.Theme_JSON := Maybe_Opt_In_Into_Settings (Theme_JSON_2);

         -- Internally, presets are keyed by origin.
         declare
            Nodes : constant Array_Type := Get_Setting_Nodes (This.Theme_JSON);
         begin
            for Node_2 in Nodes.Iterate loop
               declare
                  Node : constant Array_Type := As_Array (Element (Node_2));
               begin
                  for Preset_Metadata of PRESETS_METADATA loop
                     declare
                        Path : List_Type := As_List (Get (Node, "path"));
                     begin
                        for Subpath of As_List (Get (Preset_Metadata, "path")) loop
                           Path.Append (Subpath);
                        end loop;

                        declare
                           Preset : constant List_Type :=
                             As_List (X_Wp_Array_Get (This.Theme_JSON, Path)); -- null
                        begin
                           if not Preset.Is_Empty then
--                         if null /= Preset then
                              -- If the preset is not already keyed by origin.
                              if Isset (-Preset.First_Element) or else Preset.Is_Empty then -- (0)
--                            if Isset (-Preset.First_Element) or else Empty (Preset) then -- (0)

                                 X_Wp_Array_Set (This.Theme_JSON, Path,
                                                 From_Array (To_Array (List => (1 =>
                                                   Build (Origin, Preset)))));
                              end if;
                           end if;
                        end;
                     end;
                  end loop;
               end;
            end loop;
         end;
      end;
      return This;
   end X_Construct;

   --------------------------------
   -- Maybe_Opt_In_Into_Settings --
   --------------------------------

   function Maybe_Opt_In_Into_Settings (Theme_JSON : Array_Type)
                                        return Array_Type
   is
      New_Theme_JSON : constant Array_Type := Theme_JSON;
   begin
      -- if
      --   Isset (New_Theme_Json ["settings"]["appearanceTools"]) and then
      --   True = New_Theme_Json ["settings"]["appearanceTools"]
      -- then
      --    Do_Opt_In_Into_Settings (New_Theme_Json ["settings"]);
      -- end if;

      -- if
      --   Isset (New_Theme_Json ["settings"]["blocks"] ) and then
      --   Is_Array (New_Theme_Json ["settings"]["blocks"])
      -- then
      --    for Block of New_Theme_Json ["settings"]["blocks"] loop
      --       if
      --         isset( $block["appearanceTools"] ) and then
      --         ( true === $block["appearanceTools"] ) )
      --       then
      --          Do_Opt_In_Into_Settings (Block);
      --       end if;
      --    end loop;
      -- end if;

      return New_Theme_JSON;
   end Maybe_Opt_In_Into_Settings;

   --------------
   -- Sanitize --
   --------------

   function Sanitize (Input               : Array_Type;
                      Valid_Block_Names   : List_Type;
                      Valid_Element_Names : List_Type)
                      return Array_Type
   is
      use Php.Arrays;
      use UStrings;

      Output : Array_Type;
      Styles_Non_Top_Level   : constant Array_Type := VALID_STYLES;
      Schema                 : Array_Type;
      Schema_Styles_Elements : Array_Type;
   begin
      -- if ( ! is_array( $input ) ) then
      --    return $output;
      -- end;

      -- Preserve only the top most level keys.
      Output :=
        Array_Intersect_Key (Input, Array_Flip (VALID_TOP_LEVEL_KEYS));

      --
      -- Remove any rules that are annotated as "top" in VALID_STYLES constant.
      -- Some styles are only meant to be available at the top-level (e.g.: blockGap),
      -- hence, the schema for blocks & elements should not have them.
      --
--      Styles_Non_Top_Level := VALID_STYLES;
      for Section of List_Type'(Array_Keys (Styles_Non_Top_Level)) loop
         -- array_key_exists() needs to be used instead of isset() because the value can be null.
         if
           Array_Key_Exists (-Section, Styles_Non_Top_Level) and then
           Kind_Of (Get (Styles_Non_Top_Level, -Section)) = Kind_Array
--         Is_Array (Styles_Non_Top_Level (Section))
         then
            for Prop of List_Type'(Array_Keys (As_Array (Get (Styles_Non_Top_Level, -Section)))) loop
--          for Prof of Array_Keys (Styles_Non_Top_Level (Section)) loop
               if "top" = As_String (Get (Ref_2 (Styles_Non_Top_Level, -Section, -Prop))) then
--             if "top" = Styles_Non_Top_Level (Section) (Prop) then
                  Delete (Ref_2 (Styles_Non_Top_Level, -Section, -Prop));
--                Unset (Styles_Non_Top_Level (Section) (Prop));
               end if;
            end loop;
         end if;
      end loop;

      -- Build the schema based on valid block & element names.
--      Schema                 : Array_Type;
--      Schema_Styles_Elements : Array_Type;

      --
      -- Set allowed element pseudo selectors based on per element allow list.
      -- Target data structure in schema:
      -- e.g.
      -- - top level elements: `$schema["styles"]["elements"]["link"][":hover"]`.
      -- - block level elements: `$schema["styles"]["blocks"]["core/button"]["elements"]["link"][":hover"]`.
      --
      for Element of Valid_Element_Names loop
         Set (Schema_Styles_Elements, -Element, From_Array (Styles_Non_Top_Level));

         -- TODO: Replace array_key_exists() with isset() check once WordPress drops
         -- support for PHP 5.6. See https://core.trac.wordpress.org/ticket/57067.
         if Array_Key_Exists (-Element, VALID_ELEMENT_PSEUDO_SELECTORS) then
            for
              Pseudo_Selector in
              As_Array (Get (VALID_ELEMENT_PSEUDO_SELECTORS, -Element)).Iterate
            loop
               Set_2 (Schema_Styles_Elements,
                      Key_1 => -Element,
                      Key_2 => As_String (Arrays.Element (Pseudo_Selector)),
                      Value => From_Array (Styles_Non_Top_Level));
            end loop;
         end if;
      end loop;

      declare
         Schema_Styles_Blocks   : Array_Type;
         Schema_Settings_Blocks : Array_Type;
      begin
         for Block of Valid_Block_Names loop
            Set (Schema_Settings_Blocks, -Block, From_Array (VALID_SETTINGS));
            Set (Schema_Styles_Blocks,   -Block, From_Array (Styles_Non_Top_Level));
            Set_2 (Schema_Styles_Blocks,
                   Key_1 => -Block,
                   Key_2 => "elements",
                   Value => From_Array (Schema_Styles_Elements));
         end loop;

         Set   (Schema, "styles",             From_Array (VALID_STYLES));
         Set_2 (Schema, "styles", "blocks",   From_Array (Schema_Styles_Blocks));
         Set_2 (Schema, "styles", "elements", From_Array (Schema_Styles_Elements));
         Set   (Schema, "settings",           From_Array (VALID_SETTINGS));
         Set_2 (Schema, "settings", "blocks", From_Array (Schema_Settings_Blocks));
      end;

      -- Remove anything that"s not present in the schema.
      for Subtree of To_List (List => (+"styles", +"settings")) loop
         if not Isset (Input, -Subtree) then
            goto Continue;
         end if;

         if Kind_Of (Get (Input, -Subtree)) /= Kind_Array then
--       if not Is_Array (Input, -Subtree) then
            Delete (Ref (Output, -Subtree));
            goto Continue;
         end if;

         declare
            Result : constant Array_Type :=
              Remove_Keys_Not_In_Schema (As_Array (Get (Input,  -Subtree)),
                                         As_Array (Get (Schema, -Subtree)));
         begin
            if Empty (Result) then
               Delete (Ref (Output, -Subtree));
            else
               Set (Output, -Subtree, From_Array (Result));
            end if;
         end;

         << Continue >>
      end loop;

      return Output;
   end Sanitize;

   ------------------------
   -- Append_To_Selector --
   ------------------------

   function Append_To_Selector (Selector  : String;
                                To_Append : String;
                                Position  : String := "right")
                                return String
   is
      use Php.Strings;
      use UStrings;

      New_Selectors : List_Type;
      Selectors     : constant List_Type := Explode (",", Selector);
   begin
      for Sel of Selectors loop
         New_Selectors.Append (+(if "right" = Position
                                then (-Sel) & To_Append
                                else To_Append & (-Sel)));
      end loop;
      return Implode (",", New_Selectors);
   end Append_To_Selector;

   -------------------------
   -- Get_Blocks_Metadata --
   -------------------------

   function Get_Blocks_Metadata
            return Array_Type
   is
      use Php.Arrays;
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Class_Block_Type_Registry;

      Registry : constant Wp_Block_Type_Registry :=
        Class_Block_Type_Registry.Get_Instance;

      Blocks_2 : constant Block_Type_Maps.Map := Registry.Get_All_Registered;
      Blocks   : constant Array_Type          := Array_Diff_Key (From_Map (Blocks_2),
                                                                 Blocks_Metadata);
--    Blocks   : Array_Type          := Registry.Get_All_Registered;
   begin
      -- Is there metadata for all currently registered blocks?
      if Empty (Blocks) then
         return Blocks_Metadata;
      end if;

      for B in Blocks.Iterate loop
         declare
            Block_Name : constant String     := Key (B);
            Block_Type : constant Array_Type := As_Array (Element (B));
         begin
            if
              Isset (Block_Type, "__experimentalSelector") and then               -- supports
              Kind_Of (Get (Block_Type, "__experimentalSelector")) = Kind_String  -- supports
--            Is_String (As_String (Get (Block_Type, "__experimentalSelector")))  -- supports
            then
               Set_2 (Blocks_Metadata,
                      Key_1 => Block_Name,
                      Key_2 => "selector",
                      Value => Get (Block_Type, "__experimentalSelector"));       -- supports
            else
               Set_2 (Blocks_Metadata,
                      Key_1 => Block_Name,
                      Key_2 => "selector",
                      Value => From_String (".wp-block-" &
                                 Str_Replace ("/", "-",
                                   Str_Replace ("core/", "", Block_Name))));
            end if;

            if
              Isset_2 (Block_Type, "color", "__experimentalDuotone") and then         -- supports
              Is_String (
                As_String (
                  Get (Ref_2 (Block_Type, "color", "__experimentalDuotone"))))  -- supports
            then
               Set_2 (Blocks_Metadata,
                      Key_1 => Block_Name,
                      Key_2 => "duotone",
                      Value => Get (Ref_2 (Block_Type, "color", "__experimentalDuotone")));      -- supports
            end if;

            -- Generate block support feature level selectors if opted into
            -- for the current block.
            declare
               Features : Array_Type;
            begin
               for A in BLOCK_SUPPORT_FEATURE_LEVEL_SELECTORS.Iterate loop
                  declare
                     Key     : constant String := Arrays.Key     (A);
                     Feature : constant String := As_String (Element (A));
                  begin
                     if
                       Isset_2 (Block_Type, Key, "__experimentalSelector") and then    -- supports
                       As_Boolean (Get (Ref_2 (Block_Type, Key, "__experimentalSelector"))) -- supports
                     then
                        Set (Features, Feature,
                          From_String (
                            Scope_Selector (
                              As_String (Get (Ref_2 (Blocks_Metadata, Block_Name, "selector"))),
                              As_String (Get (Ref_2 (Block_Type, Key, "__experimentalSelector")))    -- supports
                        )));
                     end if;
                  end;
               end loop;

               if not Empty (Features) then
                  Set_2 (Blocks_Metadata,
                         Key_1 => Block_Name,
                         Key_2 => "features",
                         Value => From_Array (Features)); -- static::
               end if;
            end;

            -- Assign defaults, then overwrite those that the block sets by itself.
            -- If the block selector is compounded, will append the element to each
            -- individual block selector.
            declare
               Block_Selectors : constant List_Type :=
                 Explode (",", As_String (Get (Ref_2 (Blocks_Metadata, Block_Name, "selector"))));
            begin
               for A in ELEMENTS.Iterate loop
                  declare
                     El_Name          : constant String := Key (A);
                     El_Selector      : constant String := As_String (Element (A));
                     Element_Selector : List_Type;
                  begin
                     for Selector  of Block_Selectors loop
                        if Selector = El_Selector then
                           Element_Selector := To_List (El_Selector);
                           exit;
                        end if;
                        Element_Selector.Append
                          (+Append_To_Selector (El_Selector, -Selector & " ", "left"));
                     end loop;
                     Set_3 (Blocks_Metadata,
                            Key_1 => Block_Name,
                            Key_2 => "elements",
                            Key_3 => El_Name,
                            Value => From_String (Implode (",", Element_Selector)));
                  end;
               end loop;
            end;
         end;
      end loop;

      return Blocks_Metadata;
   end Get_Blocks_Metadata;

   -------------------------------
   -- Remove_Keys_Not_In_Schema --
   -------------------------------

   function Remove_Keys_Not_In_Schema (Tree   : Array_Type;
                                       Schema : Array_Type)
                                       return Array_Type
   is
      use Php.Arrays;

      Tree_2 : Array_Type := Array_Intersect_Key (Tree, Schema);
   begin
      for A in Schema.Iterate loop
         declare
            Key  : constant String := Arrays.Key (A);
            Data : Multi_Type      := Element (A);
         begin
            if not Isset (Tree_2, Key) then
               goto Continue;
            end if;

            if
              Kind_Of (Get (Schema, Key)) = Kind_Array and then
              Kind_Of (Get (Tree_2, Key)) = Kind_Array
            then
               Set (Tree_2, Key,
                    From_Array (
                      Remove_Keys_Not_In_Schema (As_Array (Get (Tree_2, Key)),
                                                 As_Array (Get (Schema, Key)))
                   ));

               if Empty (Tree_2, Key) then
                  Delete (Ref (Tree_2, Key));
               end if;

            elsif
              Kind_Of (Get (Schema, Key)) = Kind_Array and then
              Kind_Of (Get (Tree_2, Key)) /= Kind_Array
            then
               Delete (Ref (Tree_2, Key));
            end if;
         end;
         << Continue >>
      end loop;

      return Tree_2;
   end Remove_Keys_Not_In_Schema;

   ------------------
   -- Get_Settings --
   ------------------

   function Get_Settings (This : Wp_Theme_JSON)
                          return Multi_Type
   is
   begin
      if not Isset (This.Theme_JSON, "settings") then
         return Null_Multi_Type;
      else
         return Get (This.Theme_JSON, "settings");
      end if;
   end Get_Settings;

   --------------------
   -- Get_Stylesheet --
   --------------------

   function Get_Stylesheet
              (This    : Wp_Theme_JSON;
               Types   : List_Type := Variables_Styles_Present;
               Origins : List_Type := Empty_List) -- null
               return String
   is
      use Php.Arrays;
      use Php.Lists;
      use UStrings;
      use List_Vectors;

      Origins_2 : List_Type :=
        (if Origins = Empty_List
         then VALID_ORIGINS
         else Origins);

      -- if ( is_string( $types ) ) then
      --    -- Dispatch error and map old arguments to new ones.
      --    _deprecated_argument( __FUNCTION__, "5.9.0" );
      --    if ( "block_styles" === $types ) then
      --       $types = array( "styles", "presets" );
      --    end; elseif ( "css_variables" === $types ) then
      --       $types = array( "variables" );
      --    end; else then
      --       $types = array( "variables", "styles", "presets" );
      --    end;
      -- end;

      Blocks_Metadata : constant Array_Type := Get_Blocks_Metadata;

      Style_Nodes : constant Array_Type :=
        Get_Style_Nodes   (This.Theme_JSON, Blocks_Metadata);

      Setting_Nodes : constant Array_Type :=
        Get_Setting_Nodes (This.Theme_JSON, Blocks_Metadata);

      Stylesheet : UString;
   begin
      if In_List ("variables", Types, True) then
         Append (Stylesheet, This.Get_CSS_Variables (Setting_Nodes, Origins_2));
      end if;

      if In_List ("styles", Types, True) then
         declare
            Root_Block_Key : constant String :=
              Array_Search (ROOT_BLOCK_SELECTOR, Array_Column (Style_Nodes, "selector"), True);
         begin
            if "" /= Root_Block_Key then
--          if False /= Root_Block_Key then
               Append (Stylesheet,
                       This.Get_Root_Layout_Rules (ROOT_BLOCK_SELECTOR,
                                                   As_Array (Get (Style_Nodes, Root_Block_Key))));
            end if;
         end;
         Append (Stylesheet, This.Get_Block_Classes (Style_Nodes));

      elsif In_List ("base-layout-styles", Types, True) then
         -- Base layout styles are provided as part of `styles`, so only output separately if
         -- explicitly requested. For backwards compatibility, the Columns block is explicitly
         -- included, to support a different default gap value.
         declare
            Base_Styles_Nodes : constant array (Positive range <>) of Array_Type :=
             (To_Array (List => (
                Build ("path",     To_List ("styles")),
                Build ("selector", ROOT_BLOCK_SELECTOR)
              )),
              To_Array (List => (
                Build ("path",     To_List (List => (+"styles", +"blocks", +"core/columns"))),
                Build ("selector", ".wp-block-columns"),
                Build ("name",     "core/columns")
              ))
             );
         begin
            for Base_Style_Node of Base_Styles_Nodes loop
               Append (Stylesheet, This.Get_Layout_Styles (Base_Style_Node));
            end loop;
         end;
      end if;

      if In_List ("presets", Types, True) then
         Append (Stylesheet, This.Get_Preset_Classes (Setting_Nodes, Origins_2));
      end if;

      return -Stylesheet;
   end Get_Stylesheet;

   -----------------------
   -- Get_Block_Classes --
   -----------------------

   function Get_Block_Classes (This        : Wp_Theme_JSON;
                               Style_Nodes : Array_Type)
                               return String
   is
      use UStrings;

      Block_Rules : UString;
   begin
      for Metadata_2 in Style_Nodes.Iterate loop
         declare
            Metadata : constant Array_Type := As_Array (Element (Metadata_2));
         begin
            if "" = As_String (Get (Metadata, "selector")) then -- null
               goto Continue;
            end if;
            Append (Block_Rules, This.Get_Styles_For_Block (Metadata)); -- this. added
         end;
         << Continue >>
      end loop;

      return -Block_Rules;
   end Get_Block_Classes;

   -----------------------
   -- Get_Layout_Styles --
   -----------------------

   function Get_Layout_Styles (This           : Wp_Theme_JSON;
                               Block_Metadata : Array_Type)
                               return String
   is
      use UStrings;
      use Php.Arrays;
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use Inc_Functions;
      use Inc_Themes;

      Block_Rules : UString;
      Block_Type  : Class_Block_Type.Wp_Block_Type; -- = null;
   begin
      -- Skip outputting layout styles if explicitly disabled.
      if Current_Theme_Supports ("disable-layout-styles") then
         return -Block_Rules;
      end if;

      if Isset (Block_Metadata, "name") then
         Block_Type :=
           Class_Block_Type_Registry.
             Get_Instance.Get_Registered (As_String (Get (Block_Metadata, "name")));

         if
           not Inc_Blocks.Block_Has_Support (Block_Type, To_List ("__experimentalLayout"), False)
         then
            return -Block_Rules;
         end if;
      end if;

      declare
         Selector : String :=
          (if Isset (Block_Metadata, "selector")
           then As_String (Get (Block_Metadata, "selector")) else "");

         Has_Block_Gap_Support : constant Boolean :=
           Kind_Of (X_Wp_Array_Get (This.Theme_JSON,
                                    To_List (List => (+"settings",
                                                      +"spacing",
                                                      +"blockGap")))) /= Kind_Null;

         Has_Fallback_Gap_Support : constant Boolean := not Has_Block_Gap_Support;
         -- This setting isn"t useful yet: it exists as a placeholder for a future explicit
         -- fallback gap styles support.

         Node : constant Multi_Type :=
           X_Wp_Array_Get (This.Theme_JSON,
                           As_List (Get (Block_Metadata, "path")));

         Layout_Definitions : constant Multi_Type :=
           X_Wp_Array_Get (This.Theme_JSON,
                           To_List (List => (+"settings", +"layout", +"definitions")));

         Layout_Selector_Pattern : constant String := "/^[a-zA-Z0-9\-\.\--+>:\(\)]*$/";
         -- Allow alphanumeric classnames, spaces, wildcard, sibling, child combinator and
         -- pseudo class selectors.
      begin
         -- Gap styles will only be output if the theme has block gap support, or supports
         -- a fallback gap.
         -- Default layout gap styles will be skipped for themes that do not explicitly opt-in
         -- to blockGap with a `true` or `false` value.
         if Has_Block_Gap_Support or Has_Fallback_Gap_Support then
            declare
               use Class_Block_Type;

               Block_Gap_Value : Multi_Type; -- = null;
            begin
               -- Use a fallback gap value if block gap support is not available.
               if not Has_Block_Gap_Support then

                  Block_Gap_Value :=
                    From_String ((if ROOT_BLOCK_SELECTOR = Selector
                                  then "0.5em" else "")); -- Null_Multi_Type);

                  if Block_Type = Null_Wp_Block_Type then
--                if not Empty (Block_Type) then
                     Block_Gap_Value :=
                       X_Wp_Array_Get (Block_Type.Supports,
                                       To_List (List => (+"spacing",
                                                         +"blockGap",
                                                         +"__experimentalDefault"))); -- null
                  end if;
               else
                  Block_Gap_Value :=
                    Get_Property_Value (As_Array (Node),
                                        To_List (List => (+"spacing", +"blockGap")));
               end if;

               -- Support split row / column values and concatenate to a shorthand value.
               if Kind_Of (Block_Gap_Value) = Kind_Array then
--             if Is_Array (Block_Gap_Value) then
                  if
                    Isset (As_Array (Block_Gap_Value), "top") and then
                    Isset (As_Array (Block_Gap_Value), "left")
                  then
                     declare
                        Gap_Row : String :=
                          As_String (Get_Property_Value (As_Array (Node),
                                                         To_List (List => (+"spacing",
                                                                           +"blockGap",
                                                                           +"top"))));

                        Gap_Column : constant String :=
                          As_String (Get_Property_Value (As_Array (Node),
                                                         To_List (List => (+"spacing",
                                                                           +"blockGap",
                                                                           +"left"))));
                     begin
                        Block_Gap_Value :=
                          From_String ((if Gap_Row = Gap_Column
                                        then Gap_Row else Gap_Row & " " & Gap_Column));
                     end;
                  else
                     -- Skip outputting gap value if not all sides are provided.
                     Block_Gap_Value := Null_Multi_Type; -- null
                  end if;
               end if;

               -- If the block should have custom gap, add the gap styles.
               if
                 Kind_Of (Block_Gap_Value) not in Kind_Null | Kind_Boolean | Kind_String
--               null /= Block_Gap_Value and then
--               False /= Block_Gap_Value and then
--               "" /= Block_Gap_Value
               then
                  for A in As_Array (Layout_Definitions).Iterate loop
                     declare
                        Layout_Definition_Key : constant String     := Key (A);
                        Layout_Definition     : constant Multi_Type := Element (A);
                     begin
                        -- Allow outputting fallback gap styles for flex layout type when block
                        -- gap support isn't available.
                        if not Has_Block_Gap_Support and "flex" /= Layout_Definition_Key then
                           goto Continue;
                        end if;

                        declare
                           use Inc_Formatting;

                           Class_Name : constant String :=
                             Sanitize_Title (
                               As_String (X_Wp_Array_Get (As_Array (Layout_Definition),
                                                          To_List ("className"))));

                           Spacing_Rules : constant Array_Type :=
                             As_Array (X_Wp_Array_Get (As_Array (Layout_Definition),
                                                       To_List ("spacingStyles")));
                        begin

                           if
                             not Empty (Class_Name) and then
                             not Empty (Spacing_Rules)
                           then
                              for Spacing_Rule_2 in Spacing_Rules.Iterate loop
                                 declare
                                    Spacing_Rule : constant Array_Type :=
                                      As_Array (Element (Spacing_Rule_2));

                                    Declarations : Array_Type;
                                 begin
                                    if
                                       Isset (Spacing_Rule, "selector") and then
                                       Preg_Match (Layout_Selector_Pattern,
                                                   As_String (Get (Spacing_Rule, "selector"))) and then
                                       not Empty (As_String (Get (Spacing_Rule, "rules")))
                                    then
                                       -- Iterate over each of the styling rules and substitute
                                       -- non-string values such as `null` with the real `blockGap`
                                       -- value.
                                       for B in As_Array (Get (Spacing_Rule, "rules")).Iterate loop
                                          declare
                                             CSS_Property : constant String := Key (B);

                                             CSS_Value : constant Multi_Type := Element (B);

                                             Current_CSS_Value : Multi_Type :=
                                               (if Kind_Of (CSS_Value) = Kind_String
                                                then CSS_Value else Block_Gap_Value);
                                          begin
                                             if
                                               Is_Safe_CSS_Declaration
                                                 (CSS_Property,
                                                  As_String (Current_CSS_Value))
                                             then
                                                Append (Declarations,
                                                        From_Array (To_Array (List => (
                                                  Build ("name",  CSS_Property),
                                                  Build ("value", As_String (Current_CSS_Value))
                                                ))));
                                             end if;
                                          end;
                                       end loop;

                                       declare
                                          Format          : UString;
                                          Layout_Selector : UString;
                                       begin
                                          if not Has_Block_Gap_Support then
                                             -- For fallback gap styles, use lower specificity, to
                                             -- ensure styles do not unintentionally override theme
                                             -- styles.
                                             Format := +(if ROOT_BLOCK_SELECTOR = Selector
                                                         then ":where(.%2$s%3$s)"
                                                         else ":where(%1$s.%2$s%3$s)");

                                             Layout_Selector := +Sprintf (
                                                -Format,
                                                To_List (List => (
                                                  1 => +Selector,
                                                  2 => +Class_Name,
                                                  3 => +As_String (Get (Spacing_Rule, "selector"))))
                                             );
                                          else
                                             Format := +(if ROOT_BLOCK_SELECTOR = Selector
                                                         then "%s .%s%s" else "%s.%s%s");

                                             Layout_Selector := +Sprintf (
                                               -Format,
                                               To_List (List => (
                                                 1 => +Selector,
                                                 2 => +Class_Name,
                                                 3 => +As_String (Get (Spacing_Rule, "selector"))))
                                             );
                                          end if;
                                          Append (Block_Rules,
                                                  To_Ruleset (-Layout_Selector, Declarations));
                                       end;
                                    end if;
                                 end;
                              end loop;
                           end if;
                        end;
                     end;

                     << Continue >>
                  end loop;
               end if;
            end;
         end if;

         -- Output base styles.
         if
            ROOT_BLOCK_SELECTOR = Selector
         then
            declare
               Valid_Display_Modes : constant List_Type :=
                 To_List (List => (+"block", +"flex", +"grid"));
            begin
               for Layout_Definition_2 in As_Array (Layout_Definitions).Iterate loop
                  declare
                     use Inc_Formatting;

                     Layout_Definition : constant Array_Type :=
                       As_Array (Element (Layout_Definition_2));

                     Class_Name : constant String :=
                       Sanitize_Title (
                         As_String (X_Wp_Array_Get (Layout_Definition,
                                                    To_List ("className")))); -- False

                     Base_Style_Rules : constant Multi_Type :=
                       X_Wp_Array_Get (Layout_Definition,
                                       To_List ("baseStyles")); -- Empty_Array
                  begin
                     if
                        not Empty (Class_Name) and then
                        not Empty (As_String (Base_Style_Rules))
                     then
                        -- Output display mode. This requires special handling as `display` is
                        -- not exposed in `safe_style_css_filter`.
                        if
                          not Empty (As_String (Get (Layout_Definition, "displayMode"))) and then
                          Kind_Of (Get (Layout_Definition, "displayMode")) = Kind_String and then
                          In_List (As_String (Get (Layout_Definition, "displayMode")),
                                   Valid_Display_Modes, True)
                        then
                           declare
                              Layout_Selector : constant String := Sprintf (
                                "%s .%s",
                                To_List (List => (
                                  1 => +Selector,
                                  2 => +Class_Name
                                ))
                              );
                           begin
                              Append (Block_Rules, To_Ruleset (
                                Layout_Selector,
                                To_Array (List => (1 =>
                                  To_Array (List => (
                                    Build ("name",  "display"),
                                    Build ("value", As_String (Get (Layout_Definition,
                                                                    "displayMode")))
                                  ))
                                ))
                              ));
                           end;
                        end if;

                        for Base_Style_Rule_2 in As_Array (Base_Style_Rules).Iterate loop
                           declare
                              Base_Style_Rule : constant Array_Type := As_Array (Element (Base_Style_Rule_2));
                              Declarations    : Array_Type;
                           begin
                              if
                                 Isset (Base_Style_Rule, "selector") and then
                                 Preg_Match (Layout_Selector_Pattern,
                                             As_String (Get (Base_Style_Rule, "selector"))) and then
                                 not Empty (As_String (Get (Base_Style_Rule, "rules")))
                              then
                                 for E in As_Array (Get (Base_Style_Rule, "rules")).Iterate loop
                                    declare
                                       CSS_Property : constant String := Key (E);

                                       CSS_Value : constant String := As_String (Element (E));
                                    begin
                                       if
                                         Is_Safe_CSS_Declaration (CSS_Property,
                                                                  CSS_Value)
                                       then
                                          Append (Declarations,
                                            From_Array (To_Array (List => (
                                              Build ("name",  CSS_Property),
                                              Build ("value", CSS_Value)
                                            ))));
                                       end if;
                                    end;
                                 end loop;

                                 declare
                                    Layout_Selector : constant String := Sprintf (
                                      "%s .%s%s",
                                      To_List (List => (
                                        1 => +Selector,
                                        2 => +Class_Name,
                                        3 => +As_String (Get (Base_Style_Rule, "selector"))
                                      )));
                                 begin
                                    Append (Block_Rules,
                                            To_Ruleset (Layout_Selector, Declarations));
                                 end;
                              end if;
                           end;
                        end loop;
                     end if;
                  end;
               end loop;
            end;
         end if;
         return -Block_Rules;
      end;
   end Get_Layout_Styles;

   ------------------------
   -- Get_Preset_Classes --
   ------------------------

   function Get_Preset_Classes (This          : Wp_Theme_JSON;
                                Setting_Nodes : Array_Type;
                                Origins       : List_Type)
                                return String
   is
      use UStrings;
      use Inc_Functions;

      Preset_Rules : UString;
   begin
      for Metadata_2 in Setting_Nodes.Iterate loop
         declare
            Metadata : constant Array_Type := As_Array (Element (Metadata_2));
         begin
            if "" = Get_As_String (Metadata, "selector") then -- null
               goto Continue;
            end if;

            declare
               Selector : constant String := Get_As_String (Metadata, "selector");

               Node : constant Multi_Type :=
                 X_Wp_Array_Get (This.Theme_JSON,
                                 As_List (Get (Metadata, "path")));
            begin
               Append (Preset_Rules,
                       Compute_Preset_Classes (As_Array (Node),
                       Selector, Origins));
            end;
         end;
         << Continue >>
      end loop;

      return -Preset_Rules;
   end Get_Preset_Classes;

   -----------------------
   -- Get_CSS_Variables --
   -----------------------

   function Get_CSS_Variables (This    : Wp_Theme_JSON;
                               Nodes   : Array_Type;
                               Origins : List_Type)
                               return String
   is
      use UStrings;
      use Inc_Functions;

      Stylesheet : UString;
   begin
      for Metadata_2 in Nodes.Iterate loop
         declare
            Metadata : constant Array_Type := As_Array (Element (Metadata_2));
         begin
            if "" = Get_As_String (Metadata, "selector") then -- null
               goto Continue;
            end if;

            declare
               Selector : constant String := Get_As_String (Metadata, "selector");

               Node : constant Multi_Type :=
                 X_Wp_Array_Get (This.Theme_JSON,
                                 As_List (Get (Metadata, "path")));

               Declarations : Array_Type :=
                 Compute_Preset_Vars (As_Array (Node), Origins);

               Theme_Vars_Declarations : constant Array_Type :=
                 Compute_Theme_Vars (As_Array (Node));
            begin
               for Theme_Vars_Declaration in Theme_Vars_Declarations.Iterate loop
                  Append (Declarations, Element (Theme_Vars_Declaration));
               end loop;

               Append (Stylesheet, To_Ruleset (Selector, Declarations));
            end;
         end;
         << Continue >>
      end loop;

      return -Stylesheet;
   end Get_CSS_Variables;

   ----------------
   -- To_Ruleset --
   ----------------

   function Reduce_Callback (Carry   : String;
                             Element : Array_Type)
                             return String;

   function Reduce_Callback (Carry   : String;
                             Element : Array_Type)
                             return String
   is
   begin
      return Carry &
        As_String (Get (Element, "name")) & ": " &
        As_String (Get (Element, "value")) & ";";
   end Reduce_Callback;

   function To_Ruleset (Selector     : String;
                        Declarations : Array_Type)
                        return String
   is
      use Php.Arrays;
   begin
      if Empty (Declarations) then
         return "";
      end if;

      declare
         Declaration_Block : constant String :=
            Array_Reduce (
              Declarations,
              Reduce_Callback'Access,
              ""
            );
      begin
         return Selector & "{" & Declaration_Block & "}";
      end;
   end To_Ruleset;

   ----------------------------
   -- Compute_Preset_Classes --
   ----------------------------

   function Compute_Preset_Classes (Settings : Array_Type;
                                    Selector : String;
                                    Origins  : List_Type)
                                    return String
   is
      use UStrings;

      Selector_2 : constant String :=
        (if ROOT_BLOCK_SELECTOR = Selector
         then ""
         else Selector);
      -- Classes at the global level do not need any CSS prefixed,
      -- and we don't want to increase its specificity.

      Stylesheet : UString;
   begin
      for Preset_Metadata of PRESETS_METADATA loop
         declare
            Slugs : constant Array_Type := Get_Settings_Slugs (Settings, Preset_Metadata, Origins);
         begin
            for A in As_Array (Get (Preset_Metadata, "classes")).Iterate loop
               declare
                  Class    : constant String := Key (A);
                  Property : constant String := As_String (Element (A));
               begin
                  for Slug_2 in Slugs.Iterate loop
                     declare
                        Slug : constant String := As_String (Element (Slug_2));

                        CSS_Var : constant String :=
                          Replace_Slug_In_String (
                            As_String (Get (Preset_Metadata, "css_vars")), Slug);

                        Class_Name  : constant String :=
                          Replace_Slug_In_String (Class, Slug);
                     begin
                        Append (Stylesheet,
                                To_Ruleset (
                                  Append_To_Selector (Selector, Class_Name),
                                  To_Array (List => (1 =>
                                    To_Array (List => (
                                      Build ("name",  Property),
                                      Build ("value", "var(" & CSS_Var & ") !important")
                                    ))
                                  ))
                                ));
                     end;
                  end loop;
               end;
            end loop;
         end;
      end loop;

      return -Stylesheet;
   end Compute_Preset_Classes;

   --------------------
   -- Scope_Selector --
   --------------------

   function Scope_Selector (Scope    : String;
                            Selector : String)
                            return String
   is
      use Php.Strings;
      use UStrings;

      Scopes    : constant List_Type := Explode (",", Scope);
      Selectors : constant List_Type := Explode (",", Selector);

      Selectors_Scoped : List_Type;
   begin
      for Outer of Scopes loop
         for Inner of Selectors loop
            declare
               Trim_Inner : constant String := Trim (-Inner);
               Trim_Outer : constant String := Trim (-Outer);
               Concat     : constant String := Trim_Outer & " " & Trim_Inner;
            begin
               Selectors_Scoped.Append (+Concat);
            end;
         end loop;
      end loop;

      return Implode (", ", Selectors_Scoped);
   end Scope_Selector;

   ----------------------------
   -- Replace_Slug_In_String --
   ----------------------------

   function Replace_Slug_In_String (Input : String;
                                    Slug  : String)
                                    return String
   is
   begin
      return "XXX-002";
--    return Strtr (Heystack => Input,
--                  Needle   => array( "$slug" => $slug ));
   end Replace_Slug_In_String;

   -------------------------
   -- Compute_Preset_Vars --
   -------------------------

   function Compute_Preset_Vars (Settings : Array_Type;
                                 Origins  : List_Type)
                                 return Array_Type
   is
      Declarations : Array_Type;
   begin
      for Preset_Metadata of PRESETS_METADATA loop
         declare
            Values_By_Slug : constant Array_Type :=
              Get_Settings_Values_By_Slug (Settings, Preset_Metadata, Origins);
         begin
            for A in Values_By_Slug.Iterate loop
               declare
                  Slug  : constant String := Key (A);
                  Value : constant String := As_String (Element (A));
               begin
                  Append (Declarations, From_Array (To_Array (List => (
                    Build ("name",
                      Replace_Slug_In_String (
                        As_String (Get (Preset_Metadata, "css_vars")), Slug)),
                    Build ("value", Value)
                  ))));
               end;
            end loop;
         end;
      end loop;

      return Declarations;
   end Compute_Preset_Vars;

   --------------------------------
   -- Get_Settings_Value_By_Slug --
   --------------------------------

   function Get_Settings_Values_By_Slug (Settings        : Array_Type;
                                         Preset_Metadata : Array_Type;
                                         Origins         : List_Type)
                                         return Array_Type
   is
      use UStrings;
      use Inc_Functions;

      Preset_Per_Origin : constant Multi_Type :=
        X_Wp_Array_Get (Settings, As_List (Get (Preset_Metadata, "path")));

      Result : Array_Type;
   begin
      for Origin of Origins loop
         if not Isset (As_Array (Preset_Per_Origin), -Origin) then
            goto Continue_2;
         end if;

         for Preset_2 in As_Array (Get (As_Array (Preset_Per_Origin), -Origin)).Iterate loop
            declare
               Preset : Array_Type renames As_Array (Element (Preset_2));
               Slug   : constant String := X_Wp_To_Kebab_Case (As_String (Get (Preset, "slug")));
               Value  : UString;
            begin
               if
                 Isset (As_Array (Get (Preset_Metadata, "value_key")),
                        As_String (Get (Preset, As_String (Get (Preset_Metadata, "value_key")))))
               then
                  declare
                     Value_Key : constant String := As_String (Get (Preset_Metadata, "value_key"));
                  begin
                     Value := +As_String (Get (Preset, Value_Key));
                  end;
               -- elsif
               --   Isset (Preset_Metadata, "value_func") and then
               --   Is_Callable (Preset_Metadata, "value_func")
               -- then
               --    declare
               --       Value_Func : Callable := Get_Func (Preset_Metadata, "value_func");
               --    begin
               --       Value := Call_User_Func (Value_Func, Preset);
               --    end;
               else
                  -- If we don"t have a value, then don"t add it to the result.
                  goto Continue_1;
               end if;

               Set (Result, Slug, From_String (-Value));
            end;
            << Continue_1 >>
         end loop;
         << Continue_2 >>
      end loop;
      return Result;
   end Get_Settings_Values_By_Slug;

   ------------------------
   -- Get_Settings_Slugs --
   ------------------------

   function Get_Settings_Slugs (Settings        : Array_Type;
                                Preset_Metadata : Array_Type;
                                Origins         : List_Type := Empty_List) -- null
                                return Array_Type
   is
      use UStrings;
      use Inc_Functions;
      use List_Vectors;

      Origins_2 : List_Type :=
        (if Empty_List = Origins
         then VALID_ORIGINS
         else Origins);

      Preset_Per_Origin : constant Array_Type :=
        As_Array (
          X_Wp_Array_Get (Settings, As_List (Get (Preset_Metadata, "path"))));

      Result : Array_Type;
   begin
      for Origin of Origins_2 loop
         if not Isset (Preset_Per_Origin, -Origin) then
            goto Continue;
         end if;

         for Preset_2 in As_Array (Get (Preset_Per_Origin, -Origin)).Iterate loop
            declare
               Preset : Array_Type renames As_Array (Element (Preset_2));
               Slug   : constant String := X_Wp_To_Kebab_Case (As_String (Get (Preset, "slug")));
            begin
               -- Use the array as a set so we don"t get duplicates.
               Set (Result, Slug, From_String (Slug));
            end;
         end loop;
         << Continue >>
      end loop;
      return Result;
   end Get_Settings_Slugs;

   ------------------------
   -- Compute_Theme_Vars --
   ------------------------

   function Compute_Theme_Vars (Settings : Array_Type)
                                return Array_Type
   is
      use Inc_Functions;

      Declarations  : Array_Type;

      Custom_Values : constant Array_Type :=
        As_Array (
          X_Wp_Array_Get (Settings, To_List ("custom")));

      CSS_Vars : constant Array_Type := Flatten_Tree (Custom_Values);
   begin
      for A in CSS_Vars.Iterate loop
         declare
            Key   : constant String := Arrays.Key (A);
            Value : constant String := As_String (Element (A));
         begin
            Append (Declarations, From_Array (To_Array (List => (
              Build ("name",  "--wp--custom--" & Key),
              Build ("value", Value)
            ))));
         end;
      end loop;

      return Declarations;
   end Compute_Theme_Vars;

   ------------------
   -- Flatten_Tree --
   ------------------

   function Flatten_Tree (Tree   : Array_Type;
                          Prefix : String := "";
                          Token  : String := "--")
                          return Array_Type
   is
      use Php.Strings;
      use Inc_Functions;

      Result : Array_Type;
   begin
      for A in Tree.Iterate loop
         declare
            Property : constant String     := Key (A);
            Value    : constant Multi_Type := Element (A);

            New_Key : constant String := Prefix & Str_Replace (
              "/",
              "-",
              Strtolower (X_Wp_To_Kebab_Case (Property))
            );
         begin
            if Kind_Of (Value) = Kind_Array then
--          if Is_Array (Value) then
               declare
                  New_Prefix : constant String := New_Key & Token;

                  Flattened_Subtree : constant Array_Type :=
                    Flatten_Tree (As_Array (Value), New_Prefix, Token);
               begin
                  for B in Flattened_Subtree.Iterate loop
                     declare
                        Subtree_Key   : constant String := Key (B);
                        Subtree_Value : constant String := As_String (Element (B));
                     begin
                        Set (Result, Subtree_Key, From_String (Subtree_Value));
                     end;
                  end loop;
               end;
            else
               Set (Result, New_Key, Value);
            end if;
         end;
      end loop;
      return Result;
   end Flatten_Tree;

   ----------------------
   -- Get_Setting_Node --
   ----------------------

   function Get_Setting_Nodes (Theme_JSON : Array_Type;
                               Selectors  : Array_Type := Empty_Array)
                               return Array_Type
   is
      use UStrings;

      Nodes : Array_Type;
   begin
      if not Isset (Theme_JSON, "settings") then
         return Nodes;
      end if;

      -- Top-level.
      Append (Nodes, From_Array (To_Array (List => (
        Build ("path",     To_List ("settings")),
        Build ("selector", ROOT_BLOCK_SELECTOR)
      ))));

      -- Calculate paths for blocks.
      if not Isset_2 (Theme_JSON, "settings", "blocks") then
         return Nodes;
      end if;

      declare
         Blocks : constant Array_Type :=
           As_Array (Get (Ref_2 (Theme_JSON, "settings", "blocks")));
      begin
         for A in Blocks.Iterate loop
            declare
               Name : constant String := Key (A);
               Node : Multi_Type      := Element (A);

               Selector : UString; -- null
            begin
               if Isset_2 (Selectors, Name, "selector") then
                  Selector := +As_String (Get (Ref_2 (Selectors, Name, "selector")));
               end if;

               Append (Nodes, From_Array (To_Array (List => (
                 Build ("path",     To_List (List => (+"settings", +"blocks", +Name))),
                 Build ("selector", -Selector)
              ))));
            end;
         end loop;
      end;

      return Nodes;
   end Get_Setting_Nodes;

   ---------------------
   -- Get_Style_Nodes --
   ---------------------

   function Get_Style_Nodes (Theme_JSON : Array_Type;
                             Selectors  : Array_Type := Empty_Array)
                             return Array_Type
   is
      use Php.Arrays;
      use UStrings;
      use Wp_Common;
      use Inc_Plugins;

      Nodes : Array_Type;
   begin
      if not Isset (Theme_JSON, "styles") then
         return Nodes;
      end if;

      -- Top-level.
      Append (Nodes, From_Array (To_Array (List => (
        Build ("path",     To_List ("styles")),
        Build ("selector", ROOT_BLOCK_SELECTOR)
      ))));

      if Isset_2 (Theme_JSON, "styles", "elements") then
         for A in ELEMENTS.Iterate loop
            declare
               Element  : constant String := Key (A);
               Selector : Multi_Type      := Arrays.Element (A);
            begin
               if not Isset_3 (Theme_JSON, "styles", "elements", Element) then
                  goto Continue;
               end if;

               Append (Nodes, From_Array (To_Array (List => (
                 Build ("path",     To_List (List => (+"styles", +"elements", +Element))),
                 Build ("selector", As_String (Get (ELEMENTS, Element)))
               ))));

               -- Handle any pseudo selectors for the element.
               -- TODO: Replace array_key_exists() with isset() check once WordPress drops
               -- support for PHP 5.6. See https://core.trac.wordpress.org/ticket/57067.
               if Array_Key_Exists (Element, VALID_ELEMENT_PSEUDO_SELECTORS) then
                  for
                    Pseudo_Selector_2 in
                    As_Array (Get (VALID_ELEMENT_PSEUDO_SELECTORS, Element)).Iterate
                  loop
                     declare
                        Pseudo_Selector : constant String :=
                          As_String (Arrays.Element (Pseudo_Selector_2));
                     begin
                        if
                          Isset_4 (Theme_JSON,
                                   "styles", "elements",
                                   Element, Pseudo_Selector)
                        then
                           Append (Nodes, From_Array (To_Array (List => (
                             Build ("path",     To_List (List => (+"styles", +"elements", +Element))),
                             Build ("selector",
                                    Append_To_Selector (As_String (Get (ELEMENTS, Element)),
                                                        Pseudo_Selector))
                           ))));
                        end if;
                     end;
                  end loop;
               end if;
            end;
            << Continue >>
         end loop;
      end if;

      -- Blocks.
      if not Isset_2 (Theme_JSON, "styles", "blocks") then
         return Nodes;
      end if;

      declare
         Block_Nodes : constant Array_Type := Get_Block_Nodes (Theme_JSON);
      begin
         for Block_Node in Block_Nodes.Iterate loop
            Append (Nodes, Element (Block_Node));
         end loop;
      end;

      --
      -- Filters the list of style nodes with metadata.
      --
      -- This allows for things like loading block CSS independently.
      --
      -- @since 6.1.0
      --
      -- @param array $nodes Style nodes with metadata.
      --
      return Apply_Filters ("wp_theme_json_get_style_nodes", Nodes);
   end Get_Style_Nodes;

   -----------------------------------
   -- Update_Separator_Declarations --
   -----------------------------------

   function Update_Separator_Declarations (Declarations : Array_Type)
                                           return Array_Type
   is
      use UStrings;

      Declarations_2       : Array_Type := Declarations;
      Background_Color     : UString;
      Border_Color_Matches : Boolean := False;
      Text_Color_Matches   : Boolean := False;
   begin
      for Declaration_2 in Declarations_2.Iterate loop
         declare
            Declaration : constant Array_Type :=
              As_Array (Element (Declaration_2));
         begin
            if
              "background-color" = As_String (Get (Declaration, "name")) and then
              Background_Color = "" and then
              Isset (Declaration, "value")
            then
               Background_Color := +As_String (Get (Declaration, "value"));

            elsif "border-color" = As_String (Get (Declaration, "name")) then
               Border_Color_Matches := True;

            elsif "color" = As_String (Get (Declaration, "name")) then
               Text_Color_Matches := True;
            end if;
         end;

         if
           Background_Color /= "" and
           Border_Color_Matches   and
           Text_Color_Matches
         then
            exit;
         end if;
      end loop;

      if
        Background_Color /= ""   and
        not Border_Color_Matches and
        not Text_Color_Matches
      then
         Append (Declarations_2, From_Array (To_Array (List => (
           Build ("name",  "color"),
           Build ("value", -Background_Color)
         ))));
      end if;

      return Declarations_2;
   end Update_Separator_Declarations;

   ----------------------------
   -- Get_Styles_Block_Nodes --
   ----------------------------

   function Get_Styles_Block_Nodes (This : Wp_Theme_JSON)
                                    return Array_Type
   is
   begin
      return Get_Block_Nodes (This.Theme_JSON);
   end Get_Styles_Block_Nodes;

   ---------------------
   -- Get_Block_Nodes --
   ---------------------

   function Get_Block_Nodes (Theme_JSON : Array_Type)
                             return Array_Type
   is
      use Php.Arrays;
      use UStrings;

      Selectors : constant Array_Type := Get_Blocks_Metadata;
      Nodes     : Array_Type;
   begin
      if not Isset (Theme_JSON, "styles") then
         return Nodes;
      end if;

      -- Blocks.
      if not Isset_2 (Theme_JSON, "styles", "blocks") then
         return Nodes;
      end if;

      for A in As_Array (Get (Ref_2 (Theme_JSON, "styles", "blocks"))).Iterate loop
         declare
            Name : constant String := Key (A);
            Node : Multi_Type      := Element (A);

            Selector          : UString; -- null
            Duotone_Selector  : UString; -- null
            Feature_Selectors : UString; -- null
         begin
            if Isset_2 (Selectors, Name, "selector") then
               Selector := +As_String (Get (Ref_2 (Selectors, Name, "selector")));
            end if;

            if Isset_2 (Selectors, Name, "duotone") then
               Duotone_Selector := +As_String (Get (Ref_2 (Selectors, Name, "duotone")));
            end if;

            if Isset_2 (Selectors, Name, "features") then
               Feature_Selectors := +As_String (Get (Ref_2 (Selectors, Name, "features")));
            end if;

            Append (Nodes, From_Array (To_Array (List => (
              Build ("name",     Name),
              Build ("path",     To_List (List => (+"styles", +"blocks", +Name))),
              Build ("selector", -Selector),
              Build ("duotone",  -Duotone_Selector),
              Build ("features", -Feature_Selectors)
            ))));

            if Isset_4 (Theme_JSON, "styles", "blocks", Name, "elements") then
               for
                 B in
                   As_Array (Get (Ref_4 (Theme_JSON, "styles", "blocks", Name, "elements"))).Iterate
               loop
                  declare
                     Element : constant String := Key (B);
                     Node    : Multi_Type      := Arrays.Element (B);
                  begin
                     Append (Nodes, From_Array (To_Array (List => (
                       Build ("path",     To_List (List =>
                         (+"styles", +"blocks", +Name, +"elements", +Element))),
                       Build ("selector", As_String (Get (Ref_3 (Selectors, Name, "elements", Element))))
                     ))));

                     -- Handle any pseudo selectors for the element.
                     -- TODO: Replace array_key_exists() with isset() check once WordPress drops
                     -- support for PHP 5.6. See https://core.trac.wordpress.org/ticket/57067.
                     if Array_Key_Exists (Element, VALID_ELEMENT_PSEUDO_SELECTORS) then
                        for
                          Pseudo_Selector_2 in
                            As_Array (Get (VALID_ELEMENT_PSEUDO_SELECTORS, Element)).Iterate
                        loop
                           declare
                              Pseudo_Selector : constant String :=
                                As_String (Arrays.Element (Pseudo_Selector_2));
                           begin
                              if
                                Isset_6 (Theme_JSON, "styles", "blocks", Name,
                                         "elements", Element, Pseudo_Selector)
                              then
                                 Append (Nodes, From_Array (To_Array (List => (
                                   Build ("path",     To_List (List =>
                                     (+"styles", +"blocks", +Name, +"elements", +Element))),
                                   Build ("selector",
                                     Append_To_Selector (
                                       As_String (Get (Ref_3 (Selectors, Name, "elements", Element))),
                                       Pseudo_Selector))
                                 ))));
                              end if;
                           end;
                        end loop;
                     end if;
                  end;
               end loop;
            end if;
         end;
      end loop;

      return Nodes;
   end Get_Block_Nodes;

   ----------------------------
   -- Filter_Pseudo_Selector --
   ----------------------------

   function Filter_Pseudo_Selector (Pseudo_Selector : String)
                                    return Boolean;

   function Filter_Pseudo_Selector (Pseudo_Selector : String)
                                    return Boolean --  use ( selector )
   is
      use Php.Strings;

      Selector : constant String := "XXX-002";
   begin
      return Str_Contains (Selector, Pseudo_Selector);
   end Filter_Pseudo_Selector;

   --------------------------
   -- Get_Styles_For_Block --
   --------------------------

   function Get_Styles_For_Block (This           : Wp_Theme_JSON;
                                  Block_Metadata : Array_Type)
                                  return String
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Inc_Functions;

      Node : constant Array_Type :=
        As_Array (
          X_Wp_Array_Get (This.Theme_JSON, As_List (Get (Block_Metadata, "path"))));

      Use_Root_Padding : constant Boolean :=
        Isset_2 (This.Theme_JSON, "settings", "useRootPaddingAwareAlignments") and then
        True = As_Boolean (Get (Ref_2 (This.Theme_JSON, "settings", "useRootPaddingAwareAlignments")));

      Selector : constant String := As_String (Get (Block_Metadata, "selector"));

      Settings : constant Array_Type  :=
        As_Array (X_Wp_Array_Get (This.Theme_JSON, To_List ("settings")));

      --
      -- Process style declarations for block support features the current
      -- block contains selectors for. Values for a feature with a custom
      -- selector are filtered from the theme.json node before it is
      -- processed as normal.
      --
      Feature_Declarations : Array_Type;
   begin
      if not Empty (As_String (Get (Block_Metadata, "features"))) then
         for A in As_Array (Get (Block_Metadata, "features")).Iterate loop
            declare
               Feature_Name     : constant String     := Key (A);
               Feature_Selector : constant Multi_Type := Element (A);
            begin
               if not Empty (As_String (Get (Node, Feature_Name))) then
                  declare
                     -- Create temporary node containing only the feature data
                     -- to leverage existing `compute_style_properties` function.
                     Feature : constant Array_Type :=
                       To_Array (List => (1 =>
                         Build (Feature_Name, As_String (Get (Node, Feature_Name)))));

                     -- Generate the feature"s declarations only.
                     New_Feature_Declarations : constant Array_Type :=
                       Compute_Style_Properties (Feature, Settings, Empty_Array, -- null
                                                 This.Theme_JSON);
                  begin
                     -- Merge new declarations with any that already exist for
                     -- the feature selector. This may occur when multiple block
                     -- support features use the same custom selector.
                     if Isset (Feature_Declarations, As_String (Feature_Selector)) then
                        null;
                        -- for
                        --   New_Feature_Declaration of
                        --   New_Feature_Declarations
                        -- loop
                        --    null;
                        --    -- Feature_Declarations (Feature_Selector).Append (Feature_Declaration);
                        -- end loop;
                     else
                        Set (Feature_Declarations, As_String (Feature_Selector),
                             From_Array (New_Feature_Declarations));
                     end if;
                  end;
                  -- Remove the feature from the block"s node now the
                  -- styles will be included under the feature level selector.
                  Delete (Ref (Node, Feature_Name));
               end if;
            end;
         end loop;
      end if;

      --
      -- Get a reference to element name from path.
      -- block_metadata["path"] = array( "styles","elements","link" );
      -- Make sure that block_metadata["path"] describes an element node, like
      -- [ "styles", "element", "link" ].
      -- Skip non-element paths like just ["styles"].
      --
      declare
         Is_Processing_Element : constant Boolean :=
           In_List ("elements", As_List (Get (Block_Metadata, "path")), True);

         Current_Element : String :=
           (if Is_Processing_Element
            then As_String (Get (Ref_2 (Block_Metadata, "path",
                             Integer'Image (Count (As_Array (Get (Block_Metadata, "path"))) - 1))))
            else ""); -- null

         -- TODO: Replace array_key_exists() with isset() check once WordPress drops
         -- support for PHP 5.6. See https://core.trac.wordpress.org/ticket/57067.
         Element_Pseudo_Allowed : Array_Type :=
            (if Array_Key_Exists (Current_Element, VALID_ELEMENT_PSEUDO_SELECTORS)
             then As_Array (Get (VALID_ELEMENT_PSEUDO_SELECTORS, Current_Element))
             else Empty_Array);

         --
         -- Check for allowed pseudo classes (e.g. ":hover") from the selector ("a:hover").
         -- This also resets the array keys.
         --
         Pseudo_Matches : constant Array_Type :=
           Array_Values (
             Array_Filter (
               Element_Pseudo_Allowed,
               Filter_Pseudo_Selector'Access
             )
           );

         Pseudo_Selector : String :=
           (if Isset (Pseudo_Matches, 0)
            then As_String (Pseudo_Matches.First_Element)  -- (0)
            else ""); -- null

         Declarations : Array_Type;
      begin
         --
         -- If the current selector is a pseudo selector that"s defined in the allow list for
         -- the current element then compute the style properties for it.
         -- Otherwise just compute the styles for the default selector as normal.
         --
         if Pseudo_Selector /= "" and then Isset (Node, Pseudo_Selector) and then
            -- TODO: Replace array_key_exists() with isset() check once WordPress drops
            -- support for PHP 5.6. See https://core.trac.wordpress.org/ticket/57067.
            Array_Key_Exists (Current_Element, VALID_ELEMENT_PSEUDO_SELECTORS)
            and then In_Array (Pseudo_Selector,
                               As_Array (Get (VALID_ELEMENT_PSEUDO_SELECTORS, Current_Element)), True)
         then
            Declarations :=
              Compute_Style_Properties (As_Array (Get (Node, Pseudo_Selector)),
                                        Settings, Empty_Array, -- null
                                        This.Theme_JSON, Selector, Use_Root_Padding);
         else
            Declarations :=
              Compute_Style_Properties (Node, Settings, Empty_Array, This.Theme_JSON, -- null
                                        Selector, Use_Root_Padding);
         end if;

         declare
            Block_Rules : UString;
            Declarations_Duotone : Array_Type;
         begin
            --
            -- 1. Separate the declarations that use the general selector
            -- from the ones using the duotone selector.
            --
            for A in Declarations.Iterate loop
               declare
                  Index       : constant String     := Key (A);
                  Declaration : constant Multi_Type := Element (A);
               begin
                  if "filter" = As_String (Get (As_Array (Declaration), "name")) then
                     Delete (Ref (Declarations, Index));
                     Append (Declarations_Duotone, Declaration);
                  end if;
               end;
            end loop;

            -- Update declarations if there are separators with only background color defined.
            if ".wp-block-separator" = Selector then
               Declarations := Update_Separator_Declarations (Declarations);
            end  if;

            -- 2. Generate and append the rules that use the general selector.
            Append (Block_Rules, To_Ruleset (Selector, Declarations));

            -- 3. Generate and append the rules that use the duotone selector.
            if Isset (Block_Metadata, "duotone") and then not Empty (Declarations_Duotone) then
               declare
                  Selector_Duotone : constant String :=
                    Scope_Selector (As_String (Get (Block_Metadata, "selector")),
                                    As_String (Get (Block_Metadata, "duotone")));
               begin
                  Append (Block_Rules, To_Ruleset (Selector_Duotone,
                                                   Declarations_Duotone));
               end;
            end if;

            -- 4. Generate Layout block gap styles.
            if
              ROOT_BLOCK_SELECTOR /= Selector and then
              not Empty (As_String (Get (Block_Metadata, "name")))
            then
               Append (Block_Rules, This.Get_Layout_Styles (Block_Metadata));
            end if;

            -- 5. Generate and append the feature level rulesets.
            for B in Feature_Declarations.Iterate loop
               declare
                  Feature_Selector : constant String := Key (B);

                  Individual_Feature_Declarations : constant Multi_Type := Element (B);
               begin
                  Append (Block_Rules, To_Ruleset (Feature_Selector,
                                                   As_Array (Individual_Feature_Declarations)));
               end;
            end loop;

            return -Block_Rules;
         end;
      end;
   end Get_Styles_For_Block;

   ------------------------------
   -- Compute_Style_Properties --
   ------------------------------

   function Compute_Style_Properties
              (Styles           : Array_Type;
               Settings         : Array_Type := Empty_Array;
               Properties       : Array_Type := Empty_Array; -- null
               Theme_JSON       : Array_Type := Empty_Array; -- null
               Selector         : String     := "";          -- null
               Use_Root_Padding : Boolean    := False)       -- null
                                      return Array_Type
   is
      use Php.Arrays;
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Inc_Functions;

      Properties_2 : Array_Type :=
        (if Empty_Array = Properties
         then PROPERTIES_METADATA
         else Properties);

      Declarations : Array_Type;
      Root_Variable_Duplicates : List_Type;
   begin
      if Empty (Styles) then
         return Declarations;
      end if;

      for A in Properties.Iterate loop
         declare
            CSS_Property : constant String     := Key (A);
            Value_Path   : constant Multi_Type := Element (A);

            Value : constant Multi_Type :=
              Get_Property_Value (Styles, As_List (Value_Path), Theme_JSON);
         begin
            if
              Str_Starts_With (CSS_Property, "--wp--style--root--") and then
              (ROOT_BLOCK_SELECTOR /= Selector or else not Use_Root_Padding)
            then
               goto Continue;
            end if;
            -- Root-level padding styles don't currently support strings with CSS
            -- shorthand values.
            -- This may change: https://github.com/WordPress/gutenberg/issues/40132.
            if
              "--wp--style--root--padding" = CSS_Property and then
              Kind_Of (Value) = Kind_String
            then
               goto Continue;
            end if;

            if
              Str_Starts_With (CSS_Property, "--wp--style--root--") and then
              Use_Root_Padding
            then
               Append (Root_Variable_Duplicates,
                       Substr (CSS_Property, Strlen ("--wp--style--root--")));
            end if;

            -- Look up protected properties, keyed by value path.
            -- Skip protected properties that are explicitly set to `null`.
            if Kind_Of (Value_Path) = Kind_List then
               declare
                  Path_String : constant String := Implode (".", As_List (Value_Path));
               begin
                  if
                    -- TODO: Replace array_key_exists() with isset() check once WordPress drops
                    -- support for PHP 5.6. See https://core.trac.wordpress.org/ticket/57067.
                    Array_Key_Exists (Path_String, PROTECTED_PROPERTIES) and then
                    As_String (X_Wp_Array_Get (Settings,
                                               As_List (Get (PROTECTED_PROPERTIES,
                                               Path_String)))) = ""
                  then
                     goto Continue;
                  end if;
               end;
            end if;

            -- Skip if empty and not "0" or value represents array of longhand values.
            declare
               Has_Missing_Value : constant Boolean :=
                 Kind_Of (Value) = Kind_Null and then Kind_Of (Value) /= Kind_Integer;
            begin
               if Has_Missing_Value or else Kind_Of (Value) = Kind_Array then
                  goto Continue;
               end if;
            end;

            declare
               use Block_Typography;

               Value_2 : UString := +As_String (Value);
            begin
               -- Calculates fluid typography rules where available.
               if "font-size" = CSS_Property then
                  --
                  -- wp_get_typography_font_size_value() will check
                  -- if fluid typography has been activated and also
                  -- whether the incoming value can be converted to a fluid value.
                  -- Values that already have a clamp() function will not pass the test,
                  -- and therefore the original value will be returned.
                  --
                  Value_2 :=
                    +Wp_Get_Typography_Font_Size_Value (To_Array (List => (1 =>
                      Build ("size", As_String (Value)))));
               end if;

               Append (Declarations, From_Array (To_Array (List => (
                 Build ("name",  CSS_Property),
                 Build ("value", -Value_2)
               ))));
            end;
         end;
         << Continue >>
      end loop;

      -- If a variable value is added to the root, the corresponding property should be removed.
      for Duplicate of Root_Variable_Duplicates loop
         declare
            Discard : Integer :=
              Array_Search (-Duplicate, Array_Column (Declarations, "name"), True);

            Unused : Array_Type;
         begin
            if Is_Number (Discard) then
               Unused := Array_Splice (Declarations, Discard, 1);
            end if;
         end;
      end loop;

      return Declarations;
   end Compute_Style_Properties;

   ------------------------
   -- Get_Property_Value --
   ------------------------

   function Get_Property_Value (Styles     : Array_Type;
                                Path       : List_Type;
                                Theme_JSON : Array_Type := Empty_Array) -- null
                                return Multi_Type
   is
      use Php.JSON;
      use Php.Strings;
      use UStrings;
      use Inc_Functions;
      use Inc_L10n;

      Value : Multi_Type := X_Wp_Array_Get (Styles, Path);
   begin
      -- if "" = Value then -- or null = value then
      --    -- No need to process the value further.
      --    return "";
      -- end if;

      --
      -- This converts references to a path to the value at that path
      -- where the values is an array with a "ref" key, pointing to a path.
      -- For example: then "ref": "style.color.background" end; => "#fff".
      --
      if Kind_Of (Value) = Kind_Array and then Isset (As_Array (Value), "ref") then
         declare
            Value_Path : constant List_Type    :=
              Explode (".", As_String (Get (As_Array (Value), "ref")));

            Ref_Value  : constant Multi_Type := X_Wp_Array_Get (Theme_JSON, Value_Path);
         begin
            -- Only use the ref value if we find anything.
            if Kind_Of (Ref_Value) /= Kind_Null and then Kind_Of (Ref_Value) = Kind_String then
               Value := Ref_Value;
            end if;

            if
              Kind_Of (Ref_Value) = Kind_Array and then
              Isset (As_Array (Ref_Value), "ref")
            then
               declare
                  Path_String      : constant String := JSON_Encode (From_List (Path));
                  Ref_Value_String : constant String := JSON_Encode (Ref_Value);
               begin
                  X_Doing_It_Wrong (
                    "get_property_value",
                    Sprintf (
                      -- translators: 1: theme.json, 2: Value name, 3: Value path, 4: Another value name.
                      abs "Your %1s file uses a dynamic value (%2s) for the path at %3s. However, the value at %3s is also a dynamic value (pointing to %4s) and pointing to another dynamic value is not supported. Please update %3s to point directly to %4s.",
                      To_List (List => (
                        1 => +"theme.json",
                        2 => +Ref_Value_String,
                        3 => +Path_String,
                        4 => +As_String (Get (As_Array (Ref_Value), "ref"))))
                    ),
                    "6.1.0"
                  );
               end;
            end if;
         end;
      end if;

      if Kind_Of (Value) = Kind_Array then
         return Value;
      end if;

      -- Convert custom CSS properties.
      declare
         Prefix     : constant String  := "var:";
         Prefix_Len : constant Integer := Strlen (Prefix);
         Token_In   : constant String  := "|";
         Token_Out  : constant String  := "--";
      begin
         if 0 = Strncmp (As_String (Value), Prefix, Prefix_Len) then
            declare
               Unwrapped_Name : String := Str_Replace (
                 Token_In,
                 Token_Out,
                 Substr (As_String (Value), Prefix_Len)
               );
               Value : String := "var(--wp--unwrapped_name)";
            begin
               null;
            end;
         end if;
      end;
      return Value;
   end Get_Property_Value;

   ---------------------------
   -- Get_Root_Layout_Rules --
   ---------------------------

   function Get_Root_Layout_Rules (This           : Wp_Theme_JSON;
                                   Selector       : String;
                                   Block_Metadata : Array_Type)
                                   return String
   is
      use UStrings;
      use Inc_Functions;

      CSS              : UString;

      Settings : constant Array_Type :=
        As_Array (X_Wp_Array_Get (This.Theme_JSON, To_List ("settings")));

      Use_Root_Padding : constant Boolean :=
        Isset_2 (This.Theme_JSON, "settings", "useRootPaddingAwareAlignments") and then
        True = As_Boolean (Get (Ref_2 (This.Theme_JSON, "settings", "useRootPaddingAwareAlignments")));
   begin
      --
      -- Reset default browser margin on the root body element.
      -- This is set on the root selector--*before** generating the ruleset
      -- from the `theme.json`. This is to ensure that if the `theme.json` declares
      -- `margin` in its `spacing` declaration for the `body` element then these
      -- user-generated values take precedence in the CSS cascade.
      -- @link https://github.com/WordPress/gutenberg/issues/36147.
      --
      Append (CSS, "body { margin: 0;");

      --
      -- If there are content and wide widths in theme.json, output them
      -- as custom properties on the body element so all blocks can use them.
      --
      if
        Isset_2 (Settings, "layout", "contentSize") or
        Isset_2 (Settings, "layout", "wideSize")
      then
         declare
            Content_Size_2 : constant String :=
              As_String (if Isset_2 (Settings, "layout", "contentSize")
                         then Get (Ref_2 (Settings, "layout", "contentSize"))
                         else Get (Ref_2 (Settings, "layout", "wideSize")));

            Content_Size : String :=
              (if Is_Safe_CSS_Declaration ("max-width", Content_Size_2)
               then Content_Size_2 else "initial");

            Wide_Size_2 : constant String :=
              As_String (if Isset_2 (Settings, "layout", "wideSize")
                         then Get (Ref_2 (Settings, "layout", "wideSize"))
                         else Get (Ref_2 (Settings, "layout", "contentSize")));

            Wide_Size : String :=
              (if Is_Safe_CSS_Declaration ("max-width", Wide_Size_2)
               then Wide_Size_2 else "initial");
         begin
            Append (CSS, "--wp--style--global--content-size: " & Content_Size & ";");
            Append (CSS, "--wp--style--global--wide-size: " & Wide_Size & ";");
         end;
      end if;

      Append (CSS, " }");

      if Use_Root_Padding then
         -- Top and bottom padding are applied to the outer block container.
         Append (CSS, ".wp-site-blocks { padding-top: var(--wp--style--root--padding-top); padding-bottom: var(--wp--style--root--padding-bottom); }");
         -- Right and left padding are applied to the first container with `.has-global-padding` class.
         Append (CSS, ".has-global-padding { padding-right: var(--wp--style--root--padding-right); padding-left: var(--wp--style--root--padding-left); }");
         -- Nested containers with `.has-global-padding` class do not get padding.
         Append (CSS, ".has-global-padding :where(.has-global-padding) { padding-right: 0; padding-left: 0; }");
         -- Alignfull children of the container with left and right padding have negative margins so they can still be full width.
         Append (CSS, ".has-global-padding > .alignfull { margin-right: calc(var(--wp--style--root--padding-right)-- -1); margin-left: calc(var(--wp--style--root--padding-left)-- -1); }");
         -- The above rule is negated for alignfull children of nested containers.
         Append (CSS, ".has-global-padding :where(.has-global-padding) > .alignfull { margin-right: 0; margin-left: 0; }");
         -- Some of the children of alignfull blocks without content width should also get padding: text blocks and non-alignfull container blocks.
         Append (CSS, ".has-global-padding > .alignfull:where(:not(.has-global-padding)) > :where([class*=""wp-block-""]:not(.alignfull):not([class*=""__""]),p,h1,h2,h3,h4,h5,h6,ul,ol) then padding-right: var(--wp--style--root--padding-right); padding-left: var(--wp--style--root--padding-left); }");
         -- The above rule also has to be negated for blocks inside nested `.has-global-padding` blocks.
         Append (CSS, ".has-global-padding :where(.has-global-padding) > .alignfull:where(:not(.has-global-padding)) > :where([class*=""wp-block-""]:not(.alignfull):not([class*=""__""]),p,h1,h2,h3,h4,h5,h6,ul,ol) then padding-right: 0; padding-left: 0; }");
      end if;

      Append (CSS, ".wp-site-blocks > .alignleft { float: left; margin-right: 2em; }");
      Append (CSS, ".wp-site-blocks > .alignright { float: right; margin-left: 2em; }");
      Append (CSS, ".wp-site-blocks > .aligncenter { justify-content: center; margin-left: auto; margin-right: auto; }");

      declare
         Block_Gap_Value : Multi_Type :=
           X_Wp_Array_Get (This.Theme_JSON,
                           To_List (List => (+"styles", +"spacing", +"blockGap")),
                           From_String ("0.5em"));

         Has_Block_Gap_Support : constant Boolean :=
           X_Wp_Array_Get (This.Theme_JSON,
                           To_List (List => (+"settings", +"spacing", +"blockGap")))
                           /= Null_Multi_Type; -- null;
      begin
         if Has_Block_Gap_Support then
            declare
               Block_Gap_Value_2 : constant String :=
                 As_String (Get_Property_Value (This.Theme_JSON,
                            To_List (List => (+"styles", +"spacing", +"blockGap"))));
            begin
               Append (CSS, ".wp-site-blocks >-- { margin-block-start: 0; margin-block-end: 0; }");
               Append (CSS, ".wp-site-blocks >-- +-- { margin-block-start: " & Block_Gap_Value_2 & "; }");

               -- For backwards compatibility, ensure the legacy block gap CSS variable is still available.
               Append (CSS, Selector & " { --wp--style--block-gap: " & Block_Gap_Value_2 & "; }");
            end;
         end if;
         Append (CSS, This.Get_Layout_Styles (Block_Metadata));
      end;
      return -CSS;
   end Get_Root_Layout_Rules;

   --------------------------
   -- Get_Metadata_Boolean --
   --------------------------

   function Get_Metadata_Boolean (Data    : Array_Type;
                                  Path    : List_Type;
                                  Default : Boolean := False)
                                  return Boolean
   is
      use Inc_Functions;
   begin
--    if ( is_bool( $path ) ) then
--       return $path;
--    end if;

--    if ( is_array( $path ) ) then
      declare
         Value : constant Multi_Type := X_Wp_Array_Get (Data, Path);
      begin
         if Kind_Of (Value) /= Kind_Null then
            return As_Boolean (Value);
         end if;
      end;
--    end if;

      return Default;
   end Get_Metadata_Boolean;

   -----------
   -- Merge --
   -----------

   procedure Merge (This     : in out Wp_Theme_JSON;
                    Incoming : Wp_Theme_JSON)
   is
      use Php.Arrays;
      use UStrings;
      use Inc_Functions;

      Incoming_Data : constant Array_Type := Incoming.Get_Raw_Data;
   begin
      This.Theme_JSON := Array_Replace_Recursive (This.Theme_JSON, Incoming_Data);

      --
      -- The array_replace_recursive algorithm merges at the leaf level,
      -- but we don"t want leaf arrays to be merged, so we overwrite it.
      --
      -- For leaf values that are sequential arrays it will use the numeric indexes for
      -- replacement. We rather replace the existing with the incoming value, if it
      -- exists. This is the case of spacing.units.
      --
      -- For leaf values that are associative arrays it will merge them as expected.
      -- This is also not the behavior we want for the current associative arrays
      -- (presets). We rather replace the existing with the incoming value, if it
      -- exists. This happens, for example, when we merge data from theme.json upon
      -- existing theme supports or when we merge anything coming from the same source
      -- twice. This is the case of color.palette, color.gradients, color.duotone,
      -- typography.fontSizes, or typography.fontFamilies.
      --
      -- Additionally, for some preset types, we also want to make sure the
      -- values they introduce don"t conflict with default values. We do so
      -- by checking the incoming slugs for theme presets and compare them
      -- with the equivalent default presets: if a slug is present as a default
      -- we remove it from the theme presets.
      --
      declare
         Nodes        : constant Array_Type := Get_Setting_Nodes (Incoming_Data);
         Slugs_Global : constant Array_Type := Get_Default_Slugs (This.Theme_JSON,
                                                                  To_List ("settings"));
      begin
         for Node_2 in Nodes.Iterate loop
            declare
               Node    : constant Multi_Type := Element (Node_2);
               -- Replace the spacing.units.
               Path    : UString := +As_String (Get (As_Array (Node), "path"));
               Content : Multi_Type;
            begin
               Append (Path, "spacing");
               Append (Path, "units");

               Content := X_Wp_Array_Get (Incoming_Data, To_List (-Path));

               if Isset (As_Array (Content)) then
                  X_Wp_Array_Set (This.Theme_JSON, To_List (-Path), Content);
               end if;

               -- Replace the presets.
               for Preset of PRESETS_METADATA loop
                  declare
                     Override_Preset : constant Boolean :=
                       not Get_Metadata_Boolean
                             (As_Array (Get (This.Theme_JSON, "settings")),
                              As_List (Get (Preset, "prevent_override")),
                              True);
                  begin
                     for Origin of VALID_ORIGINS loop
                        declare
                           Base_Path : UString :=
                             +As_String (Get (As_Array (Node), "path"));
                        begin
                           for Leaf in As_Array (Get (Preset, "path")).Iterate loop
                              Append (Base_Path, As_String (Element (Leaf)));
                           end loop;

                           Path    := Base_Path;
                           Append (Path, Origin);

                           Content := X_Wp_Array_Get (Incoming_Data, To_List (-Path));
                           if not Isset (As_Array (Content)) then
                              goto Continue;
                           end if;

                           if
                             "theme" = Origin and then
                             As_Boolean (Get (Preset, "use_default_names"))
                           then
                              for A in As_Array (Content).Iterate loop
                                 declare
                                    Key  : constant String := Arrays.Key (A);
                                    Item : constant Multi_Type := Arrays.Element (A);
                                 begin
                                    if not Isset (As_Array (Item), "name") then
                                       declare
                                          Name : constant String :=
                                            Get_Name_From_Defaults (This, -- added
                                              As_String (Get (As_Array (Item), "slug")),
                                                   To_List (-Base_Path));

                                          Content_Array : Array_Type :=
                                            As_Array (Content);
                                       begin
                                          if "" /= Name then -- null
                                             Set_2 (Content_Array,
                                                    Key_1 => Key,
                                                    Key_2 => "name",
                                                    Value => From_String (Name));
                                          end if;
                                       end;
                                    end if;
                                 end;
                              end loop;
                           end if;

                           if
                             ("theme" /= Origin) or else
                             ("theme" = Origin and then Override_Preset)
                           then
                              X_Wp_Array_Set (This.Theme_JSON, To_List (-Path),
                                              Content);
                           else
                              declare
                                 Slugs_Node : constant Array_Type :=
                                   Get_Default_Slugs (This.Theme_JSON,
                                                      As_List (Get (As_Array (Node), "path")));

                                 Slugs : constant Array_Type :=
                                   Array_Merge_Recursive (Slugs_Global, Slugs_Node);

                                 Slugs_For_Preset : constant Multi_Type :=
                                   X_Wp_Array_Get (Slugs, As_List (Get (Preset, "path")));
                              begin
                                 Content :=
                                   From_List (Filter_Slugs (As_Array (Content),
                                              As_Array (Slugs_For_Preset)));
                                 X_Wp_Array_Set (This.Theme_JSON,
                                                 To_List (-Path),
                                                 Content);
                              end;
                           end if;
                        end;

                        << Continue >>
                     end loop;
                  end;
               end loop;
            end;
         end loop;
      end;
   end Merge;

   -----------------------
   -- Get_Default_Slugs --
   -----------------------

   function Get_Default_Slugs (Data      : Array_Type;
                               Node_Path : List_Type)
                               return Array_Type
   is
      use Php.Arrays;
      use UStrings;
      use Inc_Functions;

      Slugs : Array_Type;
   begin
      for Metadata of PRESETS_METADATA loop
         declare
            Path : List_Type := Node_Path;
         begin
            for Leaf in As_Array (Get (Metadata, "path")).Iterate loop
               Path.Append (+As_String (Element (Leaf)));
            end loop;
            Path.Append (+"default");

            declare
               Preset : constant Multi_Type := X_Wp_Array_Get (Data, Path);
               Slugs_For_Preset : List_Type;
            begin
               if not Isset (As_Array (Preset)) then
                  goto Continue;
               end if;

               for Item in As_Array (Preset).Iterate loop
                  declare
                     Arry : constant Array_Type := As_Array (Element (Item));
                  begin
                     if Isset (Arry, "slug") then
                        Append (Slugs_For_Preset, As_String (Get (Arry, "slug")));
                     end if;
                  end;
               end loop;

               X_Wp_Array_Set (Slugs,
                               As_List (Get (Metadata, "path")),
                               From_List (Slugs_For_Preset));

            end;
         end;
         << Continue >>
      end loop;

      return Slugs;
   end Get_Default_Slugs;

   ----------------------------
   -- Get_Name_From_Defaults --
   ----------------------------

   function Get_Name_From_Defaults (This      : Wp_Theme_JSON;
                                    Slug      : String;
                                    Base_Path : List_Type)
                                    return String
   is
      use UStrings;
      use Inc_Functions;

      Path : List_Type := Base_Path;

      Default_Content : Multi_Type;
   begin
      Path.Append (+"default");
      Default_Content := X_Wp_Array_Get (This.Theme_JSON, Path);

      if Kind_Of (Default_Content) = Kind_Null then
--    if not Default_Content then
         return ""; -- null
      end if;

      for Item_2 in As_Array (Default_Content).Iterate loop
         declare
            Item : constant Array_Type := As_Array (Element (Item_2));
         begin
            if Slug = As_String (Get (Item, "slug")) then
               return As_String (Get (Item, "name"));
            end if;
         end;
      end loop;
      return ""; -- null
   end Get_Name_From_Defaults;

   ------------------
   -- Filter_Slugs --
   ------------------

   function Filter_Slugs (Node  : Array_Type;
                          Slugs : Array_Type)
                          return List_Type -- Array_Type
   is
      use Php.Arrays;

      New_Node : List_Type;
   begin
--    if Empty (Slugs) then
--       return Node;
--    end if;

      for Value_2 in Node.Iterate loop
         declare
            Value : constant Multi_Type := Element (Value_2);
         begin
            if
              Isset (As_Array (Value), "slug") and then
              not In_Array (As_String (Get (As_Array (Value), "slug")), Slugs, True)
            then
               Append (New_Node, As_String (Value));
            end if;
         end;
      end loop;

      return New_Node;
   end Filter_Slugs;

   -----------------------------
   -- Is_Safe_CSS_Declaration --
   -----------------------------

   function Is_Safe_CSS_Declaration (Property_Name  : String;
                                     Property_Value : String)
                                     return Boolean
   is
      use Php.Strings;
      use Inc_Formatting;
      use Inc_KSES;

      Style_To_Validate : constant String := Property_Name & ": " & Property_Value;
      Filtered          : constant String := ESC_HTML (SafeCSS_Filter_Attr (Style_To_Validate));
   begin
      return not Empty (Trim (Filtered));
   end Is_Safe_CSS_Declaration;

   ------------------
   -- Get_Raw_Data --
   ------------------

   function Get_Raw_Data (This : Wp_Theme_JSON)
                          return Array_Type
   is
   begin
      return This.Theme_JSON;
   end Get_Raw_Data;

   ------------------------------
   -- Get_From_Editor_Settings --
   ------------------------------

   function Get_From_Editor_Settings (Settings : Array_Type)
                                      return Array_Type
   is
      use Php.Types;
      use UStrings;

      Theme_Settings : Array_Type := To_Array (List => (
        Build ("version",  LATEST_SCHEMA),
        Build ("settings", Empty_Array)
      ));
   begin
      -- Deprecated theme supports.
      if Isset (Settings, "disableCustomColors") then
         if not Isset_2 (Theme_Settings, "settings", "color") then
            Set_2 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "color",
                   Value => From_Array (Empty_Array));
         end if;
         Set_3 (Theme_Settings,
                Key_1 => "settings",
                Key_2 => "color",
                Key_3 => "custom",
                Value => From_Boolean (
                  not As_Boolean (Get (Settings, "disableCustomColors"))));
      end if;

      if Isset (Settings, "disableCustomGradients") then
         if not Isset_2 (Theme_Settings, "settings", "color") then
            Set_2 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "color",
                   Value => From_Array (Empty_Array));
         end if;
         Set_3 (Theme_Settings,
                Key_1 => "settings",
                Key_2 => "color",
                Key_3 => "customGradient",
                Value => From_Boolean (
                  not As_Boolean (Get (Settings, "disableCustomGradients"))));
      end if;

      if Isset (Settings, "disableCustomFontSizes") then
         if not Isset_2 (Theme_Settings, "settings", "typography") then
            Set_2 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "typography",
                   Value => From_Array (Empty_Array));
         end if;
         Set_3 (Theme_Settings,
                Key_1 => "settings",
                Key_2 => "typography",
                Key_3 => "customFontSize",
                Value => From_Boolean (
                  not As_Boolean (Get (Settings, "disableCustomFontSizes"))));
      end if;

      if Isset (Settings, "enableCustomLineHeight") then
         if not Isset_2 (Theme_Settings, "settings", "typography") then
            Set_2 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "typography",
                   Value => From_Array (Empty_Array));
         end if;
         Set_3 (Theme_Settings,
                Key_1 => "settings",
                Key_2 => "typography",
                Key_3 => "lineHeight",
                Value => Get (Settings, "enableCustomLineHeight"));
      end if;

      if Isset (Settings, "enableCustomUnits") then
         if not Isset_2 (Theme_Settings, "settings", "spacing") then
            Set_2 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "spacing",
                   Value => From_Array (Empty_Array));
         end if;
         Set_3 (Theme_Settings,
                Key_1 => "settings",
                Key_2 => "spacing",
                Key_3 => "units",
                Value => From_List
                  (if True = As_Boolean (Get (Settings, "enableCustomUnits"))
                   then To_List (List => (+"px", +"em", +"rem", +"vh", +"vw", +"%"))
                   else To_List (As_String (Get (Settings, "enableCustomUnits")))));
      end if;

      if Isset (Settings, "colors") then
         if not Isset_2 (Theme_Settings, "settings", "color") then
            Set_2 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "color",
                   Value => From_Array (Empty_Array));
         end if;
         Set_3 (Theme_Settings,
                Key_1 => "settings",
                Key_2 => "color",
                Key_3 => "palette",
                Value => Get (Settings, "colors"));
      end if;

      if Isset (Settings, "gradients") then
         if not Isset_2 (Theme_Settings, "settings", "color") then
            Set_2 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "color",
                   Value => From_Array (Empty_Array));
         end if;
         Set_3 (Theme_Settings,
                Key_1 => "settings",
                Key_2 => "color",
                Key_3 => "gradients",
                Value => Get (Settings, "gradients"));
      end if;

      if Isset (Settings, "fontSizes") then
         declare
            Font_Sizes : Array_Type := As_Array (Get (Settings, "fontSizes"));
         begin
            -- Back-compatibility for presets without units.
            for A in Font_Sizes.Iterate loop
               declare
                  Key       : constant String := Arrays.Key (A);
                  Font_Size : constant Multi_Type := Arrays.Element (A);
               begin
                  if Is_Numeric (As_String (Get (As_Array (Font_Size), "size"))) then
                     Set_2 (Font_Sizes,
                            Key_1 => Key,
                            Key_2 => "size",
                            Value => From_String (As_String (
                              Get (As_Array (Font_Size), "size")) & "px"));
                  end if;
               end;
            end loop;

            if not Isset_2 (Theme_Settings, "settings", "typography") then
               Set_2 (Theme_Settings,
                      Key_1 => "settings",
                      Key_2 => "typography",
                      Value => From_Array (Empty_Array));
            end if;
            Set_3 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "typography",
                   Key_3 => "fontSizes",
                   Value => From_Array (Font_Sizes));
         end;
      end if;

      if Isset (Settings, "enableCustomSpacing") then
         if not Isset_2 (Theme_Settings, "settings", "spacing") then
            Set_2 (Theme_Settings,
                   Key_1 => "settings",
                   Key_2 => "spacing",
                   Value => From_Array (Empty_Array));
         end if;
         Set_3 (Theme_Settings,
                Key_1 => "settings",
                Key_2 => "spacing",
                Key_3 => "padding",
                Value => Get (Settings, "enableCustomSpacing"));
      end if;

      return Theme_Settings;
   end Get_From_Editor_Settings;

   -----------------------
   -- Set_Spacing_Sizes --
   -----------------------

   procedure Set_Spacing_Sizes (This : in out Wp_Theme_JSON)
   is
      use Php.Arrays;
      use Php.Errors;
      use Php.Numerics;
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;

      Spacing_Scale : constant Array_Type :=
        As_Array (X_Wp_Array_Get
          (This.Theme_JSON,
           To_List (List => (+"settings", +"spacing", +"spacingScale"))));
   begin
      if
        not Isset (Spacing_Scale, "steps")
        or else not Is_Numeric (As_String (Get (Spacing_Scale, "steps")))
        or else not Isset (Spacing_Scale, "mediumStep")
        or else not Isset (Spacing_Scale, "unit")
        or else not Isset (Spacing_Scale, "operator")
        or else not Isset (Spacing_Scale, "increment")
        or else not Isset (Spacing_Scale, "steps")
        or else not Is_Numeric (As_String (Get (Spacing_Scale, "increment")))
        or else not Is_Numeric (As_String (Get (Spacing_Scale, "mediumStep")))
        or else ("+" /= As_String (Get (Spacing_Scale, "operator")) and then
                 "*" /= As_String (Get (Spacing_Scale, "operator")))
      then
         if not Empty (Spacing_Scale) then
            Trigger_Error (
              abs "Some of the theme.json settings.spacing.spacingScale values are invalid",
              E_USER_NOTICE);
         end if;
         return; --  null;
      end if;

      -- If theme authors want to prevent the generation of the core spacing scale
      -- they can set their theme.json spacingScale.steps to 0.
      if 0 = As_Integer (Get (Spacing_Scale, "steps")) then
         return; --  null;
      end if;

      declare
         Unit : String :=
           (if "%" = As_String (Get (Spacing_Scale, "unit")) then "%"
            else Sanitize_Title (As_String (Get (Spacing_Scale, "unit"))));

         Current_Step    : Natural := As_Integer (Get (Spacing_Scale, "mediumStep"));

         Steps_Mid_Point : constant Natural :=
           Natural (Round (Float (As_Integer (Get (Spacing_Scale, "steps"))) / 2.0, 0));

         X_Small_Count   : Natural := 0; -- null
         Below_Sizes     : Array_Type;
         Slug            : Natural := 40;
         Remainder       : Natural := 0;
         Increment       : constant Natural := As_Integer (Get (Spacing_Scale, "increment"));
         Below_Midpoint_Count : Natural;
      begin

         Below_Midpoint_Count := Steps_Mid_Point - 1;
         while
            As_Integer (Get (Spacing_Scale, "steps")) > 1 and
            Slug > 0 and
            Below_Midpoint_Count > 0
         loop
            if "+" = As_String (Get (Spacing_Scale, "operator")) then
               Current_Step := Current_Step - Increment;
            elsif Increment > 1 then
               Current_Step := Current_Step / Increment;
            else
               Current_Step := Current_Step * Increment;
            end  if;

            if Current_Step <= 0 then
               Remainder := Below_Midpoint_Count;
               exit;
            end if;

            Append (Below_Sizes, From_Array (To_Array (List => (
               -- translators: %s: Digit to indicate multiple of sizing, eg. 2X-Small.
               Build ("name", (if Below_Midpoint_Count = Steps_Mid_Point - 1
                               then abs "Small"
                               else Sprintf (abs "%sX-Small",
                                             To_List (Natural'Image (X_Small_Count))))),
               Build ("slug", Natural'Image (Slug)),
               Build ("size", Float'Image (Round (Float (Current_Step), 2)) & Unit)
            ))));

            if Below_Midpoint_Count = Steps_Mid_Point - 2 then
               X_Small_Count := 2;
            end if;

            if Below_Midpoint_Count < Steps_Mid_Point - 2 then
               X_Small_Count := X_Small_Count + 1;
            end if;

            Slug := Slug - 10;
            Below_Midpoint_Count := Below_Midpoint_Count - 1;
         end loop;

         Below_Sizes := Array_Reverse (Below_Sizes);

         Append (Below_Sizes, From_Array (To_Array (List => (
            Build ("name", abs "Medium"),
            Build ("slug", "50"),
            Build ("size", As_String (Get (Spacing_Scale, "mediumStep")) & Unit)
         ))));

         declare
            Current_Step  : Natural := As_Integer (Get (Spacing_Scale, "mediumStep"));
            X_Large_Count : Natural := 0; -- null
            Above_Sizes   : Array_Type;
            Slug          : Natural := 60;

            Steps_Above   : constant Natural :=
              (As_Integer (Get (Spacing_Scale, "steps")) - Steps_Mid_Point) + Remainder;

            Above_Midpoint_Count : Natural;
         begin
            Above_Midpoint_Count := 0;
            while
              Above_Midpoint_Count < Steps_Above
            loop
               Current_Step := (if "+" = As_String (Get (Spacing_Scale, "operator"))
                                then Current_Step + Increment
                                else (if Increment >= 1
                                      then Current_Step * Increment
                                      else Current_Step / Increment));

               Append (Above_Sizes, From_Array (To_Array (List => (
                 -- translators: %s: Digit to indicate multiple of sizing, eg. 2X-Large.
                 Build ("name", (if 0 = Above_Midpoint_Count
                                 then abs "Large"
                                 else Sprintf (abs "%sX-Large",
                                               To_List (Natural'Image (X_Large_Count))))),
                 Build ("slug", Natural'Image (Slug)),
                 Build ("size", Float'Image (Round (Float (Current_Step), 2)) & Unit)
               ))));

               if 1 = Above_Midpoint_Count then
                  X_Large_Count := 2;
               end if;

               if Above_Midpoint_Count > 1 then
                  X_Large_Count := X_Large_Count + 1;
               end if;

               Slug := Slug + 10;
               Above_Midpoint_Count := Above_Midpoint_Count + 1;
            end loop;

            declare
               Spacing_Sizes : Array_Type := Below_Sizes;
            begin
               for Above_Sizes_Item in Above_Sizes.Iterate loop
                  Append (Spacing_Sizes, Element (Above_Sizes_Item));
               end loop;

               -- If there are 7 or less steps in the scale revert to numbers for
               -- labels instead of t-shirt sizes.
               if As_Integer (Get (Spacing_Scale, "steps")) <= 7 then
                  for Spacing_Sizes_Count in 0 .. Count (Spacing_Sizes) - 1 loop
                     Set_2 (Spacing_Sizes,
                            Key_1 => Natural'Image (Spacing_Sizes_Count),
                            Key_2 => "name",
                            Value =>
                              From_String (Natural'Image (Spacing_Sizes_Count + 1)));
                  end loop;
               end if;

               X_Wp_Array_Set (This.Theme_JSON,
                               To_List (List => (+"settings", +"spacing",
                                                 +"spacingSizes", +"default")),
                               From_Array (Spacing_Sizes));
            end;
         end;
      end;
   end Set_Spacing_Sizes;

end Class_Theme_JSON;
