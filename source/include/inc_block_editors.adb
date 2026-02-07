--
-- Block Editor API.
--
-- @package WordPress
-- @subpackage Editor
-- @since 5.8.0
--

with Php.Arrays;
with Php.Echoing;
with Php.Files;
with Php.Lists;
with Php.Misc;
with Php.Preg;

with Constants;
with Globals;
with UStrings;
with Wp_Common;

with Class_Block_Type_Registry;
with Class_Posts;
with Class_Theme_JSON_Resolver;
with Inc_Functions;
with Inc_Global_Styles_And_Settings;
with Inc_HTTP;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Media;
with Inc_Options;
with Inc_Themes;

package body Inc_Block_Editors
is

   Static_Default_Editor_Styles_File_Contents_Bool : Boolean := False;
   Static_Default_Editor_Styles_File_Contents      : UStrings.UString;

   ----------------------------------
   -- Get_Default_Block_Categories --
   ----------------------------------

   function Get_Default_Block_Categories
            return Array_Lists.Array_List
   is
      use Array_Lists;
      use Inc_L10n;
   begin
      return
        [
          To_Array_Type ([
            Build ("slug",  "text"),
            Build ("title", X_X ("Text", "block category")),
            Build ("icon",  null)
          ]),
          To_Array_Type ([
            Build ("slug",  "media"),
            Build ("title", X_X ("Media", "block category")),
            Build ("icon",  null)
          ]),
          To_Array_Type ([
            Build ("slug",  "design"),
            Build ("title", X_X ("Design", "block category")),
            Build ("icon",  null)
          ]),
          To_Array_Type ([
            Build ("slug",  "widgets"),
            Build ("title", X_X ("Widgets", "block category")),
            Build ("icon",  null)
          ]),
          To_Array_Type ([
            Build ("slug",  "theme"),
            Build ("title", X_X ("Theme", "block category")),
            Build ("icon",  null)
          ]),
          To_Array_Type ([
            Build ("slug",  "embed"),
            Build ("title", X_X ("Embeds", "block category")),
            Build ("icon",  null)
          ]),
          To_Array_Type ([
            Build ("slug",  "reusable"),
            Build ("title", X_X ("Reusable Blocks", "block category")),
            Build ("icon",  null)
          ])
        ];
   end Get_Default_Block_Categories;

   --------------------------
   -- Get_Block_Categories --
   --------------------------

   function Get_Block_Categories
              (Post_Or_Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Lists.Array_List
   is
      use Array_Lists;
      use Wp_Common;
      use Class_Block_Editor_Contexts;
      use Class_Posts;

      Block_Categories     : Array_List := Get_Default_Block_Categories;
      Block_Editor_Context : constant Wp_Block_Editor_Context :=
        (if False -- Post_Or_Block_Editor_Context in Wp_Post -- instanceof
         then X_Construct ( -- new WP_Block_Editor_Context(
                To_Array_Type ([
                  Build ("post", "XXX-019") -- Post_Or_Block_Editor_Context)
                ]))
         else Post_Or_Block_Editor_Context);

      --
      -- Filters the default array of categories for block types.
      --
      -- @since 5.8.0
      --
      -- @param array[]                 block_categories     Array of categories for
      --                                                      block types.
      -- @param WP_Block_Editor_Context block_editor_context The current block editor
      --                                                      context.
      --
   begin
      Block_Categories :=
        Apply_Filters ("block_categories_all", Block_Categories, Block_Editor_Context);

      if Block_Editor_Context.Post = null then
--    if not Empty (Block_Editor_Context.Post) then
         declare
            Post : not null access Wp_Post := Block_Editor_Context.Post;
         begin
            --
            -- Filters the default array of categories for block types.
            --
            -- @since 5.0.0
            -- @deprecated 5.8.0 Use the {@see "block_categories_all"} filter instead.
            --
            -- @param array[] block_categories Array of categories for block types.
            -- @param WP_Post post             Post being loaded.
            --
            Block_Categories :=
              Apply_Filters_Deprecated
                ("block_categories",
                 Empty_Array_List, -- To_Array (Block_Categories, Post),
                 "5.8.0", "block_categories_all");
         end;
      end if;

      return Block_Categories;
   end Get_Block_Categories;

   -----------------------------
   -- Get_Allowed_Block_Types --
   -----------------------------

   function Get_Allowed_Block_Types
              (Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return List_Type
   is
      use Wp_Common;
      use Class_Posts;
--    use Inc_Plugins;

      Allowed_Block_Types : List_Type; -- Boolean := True;
   begin
      --
      -- Filters the allowed block types for all editor types.
      --
      -- @since 5.8.0
      --
      -- @param bool|string[]           allowed_block_types  Array of block type
      --                                                      slugs, or boolean to
      --                                                      enable/disable all.
      --                                                      Default true (all
      --                                                      registered block types
      --                                                      supported).
      -- @param WP_Block_Editor_Context block_editor_context The current block editor
      --                                                      context.
      --
      Allowed_Block_Types :=
        Apply_Filters ("allowed_block_types_all",
                       Allowed_Block_Types, Block_Editor_Context);

      if Block_Editor_Context.Post = null then
--    if not Empty (Block_Editor_Context.Post) then
         declare
            Post : not null access Wp_Post := Block_Editor_Context.Post;
         begin
            --
            -- Filters the allowed block types for the editor.
            --
            -- @since 5.0.0
            -- @deprecated 5.8.0 Use the {@see "allowed_block_types_all"} filter
            --                    instead.
            --
            -- @param bool|string[] allowed_block_types Array of block type slugs, or
            --                                           boolean to enable/disable all.
            --                                           Default true (all registered
            --                                           block types supported)
            -- @param WP_Post       post                The post resource data.
            --
            Allowed_Block_Types :=
              Apply_Filters_Deprecated (
                "allowed_block_types",
                [], -- array( allowed_block_types, post ),
                "5.8.0", "allowed_block_types_all");
         end;
      end if;

      return Allowed_Block_Types;
   end Get_Allowed_Block_Types;

   ---------------------------------------
   -- Get_Default_Block_Editor_Settings --
   ---------------------------------------

   function Get_Default_Block_Editor_Settings
            return Array_Type
   is
      use Php.Arrays;
      use Php.Files;
      use Php.Lists;
      use Php.Misc;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Media;
      use Inc_Options;
      use Inc_Themes;

      function Get_Image_Sizes (Names : Array_Type)
                                return Array_Type;

      ---------------------
      -- Get_Image_Sizes --
      ---------------------

      function Get_Image_Sizes (Names : Array_Type)
                                return Array_Type
      is
         Result : Array_Type;
      begin
         for A in Names.Iterate loop
            declare
               Image_Size_Slug : constant String := Key (A);
               Image_Size_Name : constant String := As_String (Element (A));

               Value : constant Array_Type := To_Array_Type ([
                 Build ("slug", Image_Size_Slug),
                 Build ("name", Image_Size_Name)
               ]);
            begin
               Append (Result, Key => "XXX-891", Value => From_Array (Value));
            end;
         end loop;
         return Result;
      end Get_Image_Sizes;

      -- Media settings.
      Max_Upload_Size : constant Natural := Wp_Max_Upload_Size; -- ()
      -- -- wp_max_upload_size() can be expensive, so only call it when relevant
      -- -- for the current user.
      -- if Current_User_Can ("upload_files") then
      --    Max_Upload_Size := Wp_Max_Upload_Size; -- ();
      --    if not Max_Upload_Size then
      --       Max_Upload_Size := 0;
      --    end if;
      -- end if;

      -- This filter is documented in wp-admin/includes/media.php--
      Image_Size_Names : constant Array_Type := Apply_Filters (
        "image_size_names_choose",
        To_Array_Type ([
          Build ("thumbnail", abs "Thumbnail"),
          Build ("medium",    abs "Medium"),
          Build ("large",     abs "Large"),
          Build ("full",      abs "Full Size")
        ])
      );

      Available_Image_Sizes : constant Array_Type :=
        Get_Image_Sizes (Image_Size_Names);

      Default_Size : constant String := Get_Option ("image_default_size", "large");

      Image_Default_Size : String :=
        (if In_List (Default_Size, List_Type'(Array_Keys (Image_Size_Names)), True)
         then Default_Size else "large");

      Image_Dimensions : Array_Type;

      All_Sizes : constant Array_Type :=
        Wp_Get_Registered_Image_Subsizes; -- ()

      -- These styles are used if the "no theme styles" options is triggered
      -- or on themes without their own editor styles.
      Default_Editor_Styles_File : constant String :=
        Constants.ABSPATH & (-Globals.WPINC) &
        "/css/dist/block-editor/default-editor-styles.css";

      Default_Editor_Styles : Array_Type;
   begin
      if
        not Static_Default_Editor_Styles_File_Contents_Bool and then
        File_Exists (Default_Editor_Styles_File)
      then
         Static_Default_Editor_Styles_File_Contents :=
           +File_Get_Contents (Default_Editor_Styles_File);
         Static_Default_Editor_Styles_File_Contents_Bool := True;
      end if;

      if Static_Default_Editor_Styles_File_Contents_Bool then
         Default_Editor_Styles := To_Array_Type ([
           To_Array_Type ([
             Build ("css", -Static_Default_Editor_Styles_File_Contents)
           ])
         ]);
      end if;

      declare
         Editor_Settings : Array_Type := To_Array_Type ([
           Build ("alignWide",             Boolean'(Get_Theme_Support ("align-wide"))),
           Build ("allowedBlockTypes",     True),
           Build ("allowedMimeTypes",      Get_Allowed_MIME_Types),
           Build ("defaultEditorStyles",   Default_Editor_Styles),
           Build ("blockCategories",
             To_Array_Type (Get_Default_Block_Categories)),
           Build ("disableCustomColors",
             Boolean'(Get_Theme_Support ("disable-custom-colors"))),
           Build ("disableCustomFontSizes",
             Boolean'(Get_Theme_Support ("disable-custom-font-sizes"))),
           Build ("disableCustomGradients",
             Boolean'(Get_Theme_Support ("disable-custom-gradients"))),
           Build ("disableLayoutStyles",
             Boolean'(Get_Theme_Support ("disable-layout-styles"))),
           Build ("enableCustomLineHeight",
             Boolean'(Get_Theme_Support ("custom-line-height"))),
           Build ("enableCustomSpacing",
             Boolean'(Get_Theme_Support ("custom-spacing"))),
           Build ("enableCustomUnits",
             Boolean'(Get_Theme_Support ("custom-units"))),

           Build ("isRTL",                            Is_RTL),
           Build ("imageDefaultSize",                 Image_Default_Size),
           Build ("imageDimensions",                  Image_Dimensions),
           Build ("imageEditing",                     True),
           Build ("imageSizes",                       Available_Image_Sizes),
           Build ("maxUploadFileSize",                Max_Upload_Size),
           -- The following flag is required to enable the new Gallery block
           -- format on the mobile apps in 5.9.
           Build ("__unstableGalleryWithImageBlocks", True)
         ]);

         -- Theme settings.
         Color_Palette : constant String :=
           Current (Get_Theme_Support ("editor-color-palette")); -- (array)

         Font_Sizes : constant String :=
           Current (Get_Theme_Support ("editor-font-sizes")); -- (array)

         Gradient_Presets : constant String :=
           Current (Get_Theme_Support ("editor-gradient-presets")); -- (array)
      begin
         if "" /= Color_Palette then
            Set (Editor_Settings, "colors", From_String (Color_Palette));
         end if;

         if "" /= Font_Sizes then
            Set (Editor_Settings, "fontSizes", From_String (Font_Sizes));
         end if;

         if "" /= Gradient_Presets then
            Set (Editor_Settings, "gradients", From_String (Gradient_Presets));
         end if;

         return Editor_Settings;
      end;
   end Get_Default_Block_Editor_Settings;

   ---------------------------------------------
   -- Get_Legacy_Widget_Block_Editor_Settings --
   ---------------------------------------------

   function Get_Legacy_Widget_Block_Editor_Settings
            return Array_Type
   is
      use Wp_Common;

      Editor_Settings : Array_Type;
   begin
      --
      -- Filters the list of widget-type IDs that should--*not** be offered by the
      -- Legacy Widget block.
      --
      -- Returning an empty array will make all widgets available.
      --
      -- @since 5.8.0
      --
      -- @param string[] widgets An array of excluded widget-type IDs.
      --
      Set (Editor_Settings, "widgetTypesToHideFromLegacyWidgetBlock",
           From_List (Apply_Filters (
             "widget_types_to_hide_from_legacy_widget_block",
             List_Type'[
               "pages",
               "calendar",
               "archives",
               "media_audio",
               "media_image",
               "media_gallery",
               "media_video",
               "search",
               "text",
               "categories",
               "recent-posts",
               "recent-comments",
               "rss",
               "tag_cloud",
               "custom_html",
               "block"
             ]
           ))
          );

      return Editor_Settings;
   end Get_Legacy_Widget_Block_Editor_Settings;

   ------------------------------------
   -- X_Wp_Get_Iframed_Editor_Assets --
   ------------------------------------

   function X_Wp_Get_Iframed_Editor_Assets
            return Array_Type
   is
      use Php.Echoing;
      use Php.Lists;
      use Array_Lists;
      use UStrings;
      use Class_Block_Type_Registry;
      use Inc_Themes;
--    global pagenow;

      Scripts_2 : UString;
      Styles_2  : UString;

      Script_Handles : List_Type;

      Style_Handles : List_Type :=
        [
          "wp-block-editor",
          "wp-block-library",
          "wp-edit-blocks"
        ];
   begin
      if Current_Theme_Supports ("wp-block-styles") then
         Style_Handles.Append ("wp-block-library-theme");
      end if;

      if
        Globals.Pagenow = "widgets.php" or else
        Globals.Pagenow = "customize.php"
      then
         Style_Handles.Append ("wp-widgets");
         Style_Handles.Append ("wp-edit-widgets");
      end if;

      declare
         Block_Registry : constant Wp_Block_Type_Registry :=
           Class_Block_Type_Registry.Get_Instance;
      begin
         for Block_Type of Block_Registry.Get_All_Registered loop
            Style_Handles :=
              List_Merge (
                Style_Handles,
                Block_Type.Style_Handles,
                Block_Type.Editor_Style_Handles
              );

            Script_Handles :=
              List_Merge (
                Script_Handles,
                Block_Type.Script_Handles
              );
         end loop;
      end;

      Style_Handles := List_Unique (Style_Handles);

      declare
         Done : constant List_Type := Globals.Global_Wp_Styles.Done;
      begin
         OB_Start;

         -- We do not need reset styles for the iframed editor.
         Globals.Global_Wp_Styles.Done := ["wp-reset-editor-styles"];
         Globals.Global_Wp_Styles.Do_Items (Style_Handles);
         Globals.Global_Wp_Styles.Done := Done;
      end;

      Styles_2 := +OB_Get_Clean;

      Script_Handles := List_Unique (Script_Handles);

      declare
         Done : constant List_Type := Globals.Global_Wp_Scripts.Done;
      begin
         OB_Start;

         Globals.Global_Wp_Scripts.Done := Empty_List;
         Globals.Global_Wp_Scripts.Do_Items (Script_Handles);
         Globals.Global_Wp_Scripts.Done := Done;
      end;

      Scripts_2 := +OB_Get_Clean;

      return
        To_Array_Type ([
          Build ("styles",  From_String (-Styles_2)),
          Build ("scripts", From_String (-Scripts_2))
        ]);
   end X_Wp_Get_Iframed_Editor_Assets;

   -------------------------------
   -- Get_Block_Editor_Settings --
   -------------------------------

   function Get_Block_Editor_Settings
              (Custom_Settings      : Array_Type;
               Block_Editor_Context :
                 Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type
   is
      use Php.Arrays;
      use Array_Lists;
      use Array_Lists.Vectors;
      use Wp_Common;
      use Class_Posts;
      use Inc_Global_Styles_And_Settings;
      use Inc_Link_Templates;
      use Inc_Options;
      use Inc_Themes;

      Editor_Settings : Array_Type := Array_Merge (
        Get_Default_Block_Editor_Settings,
        To_Array_Type ([
          Build ("allowedBlockTypes", Get_Allowed_Block_Types (Block_Editor_Context)),
          Build ("blockCategories",
            To_Array_Type (Get_Block_Categories (Block_Editor_Context)))
        ]),
        Custom_Settings
      );

      Presets : constant Array_List := [
        To_Array_Type ([
          Build ("css",            "variables"),
          Build ("__unstableType", "presets"),
          Build ("isGlobalStyles", True)
        ]),
        To_Array_Type ([
          Build ("css",            "presets"),
          Build ("__unstableType", "presets"),
          Build ("isGlobalStyles", True)
        ])
      ];

      Global_Styles : Array_List;
   begin
      for Preset_Style of Presets loop
         declare
            Actual_CSS : constant String :=
              Wp_Get_Global_Stylesheet (As_List (Get (Preset_Style, "css")));

            Preset_Style_2 : Array_Type := Preset_Style;
         begin
            if "" /= Actual_CSS then
               Set (Preset_Style_2, "css", From_String (Actual_CSS));
               Global_Styles.Append (Preset_Style_2);
            end if;
         end;
      end loop;

      if Class_Theme_JSON_Resolver.Theme_Has_Support then
         declare
            Block_Classes : Array_Type := To_Array_Type ([
              Build ("css",            "styles"),
              Build ("__unstableType", "theme"),
              Build ("isGlobalStyles", True)
            ]);
            Actual_CSS : constant String :=
              Wp_Get_Global_Stylesheet (As_List (Get (Block_Classes, "css")));
         begin
            if "" /= Actual_CSS then
               Set (Block_Classes, "css", From_String (Actual_CSS));
               Global_Styles.Append (Block_Classes);
            end if;
         end;
      else
         -- If there is no `theme.json` file, ensure base layout styles are still
         -- available.
         declare
            Block_Classes : Array_Type := To_Array_Type ([
              Build ("css",            "base-layout-styles"),
              Build ("__unstableType", "base-layout"),
              Build ("isGlobalStyles", True)
            ]);
            Actual_CSS : constant String :=
              Wp_Get_Global_Stylesheet (As_List (Get (Block_Classes, "css")));
         begin
            if "" /= Actual_CSS then
               Set (Block_Classes, "css", From_String (Actual_CSS));
               Global_Styles.Append (Block_Classes);
            end if;
         end;
      end if;

      Set (Editor_Settings, "styles", From_Array (
           To_Array_Type (Global_Styles & Get_Block_Editor_Theme_Styles)));
--         Array_Merge (Global_Styles, Get_Block_Editor_Theme_Styles)));

      Set (Editor_Settings, "__experimentalFeatures",
           Wp_Get_Global_Settings);

      -- These settings may need to be updated based on data coming from theme.json
      -- sources.
      if Isset_3 (Editor_Settings, "__experimentalFeatures", "color", "palette") then
         declare
            Colors_By_Origin : constant Arrays.Cursor :=
              Ref_3 (Editor_Settings, "__experimentalFeatures", "color", "palette");
         begin
            Set (Editor_Settings, "colors",
                 (if Isset (Colors_By_Origin, "custom")
                  then Get (Colors_By_Origin, "custom")
                   else
                     (if Isset (Colors_By_Origin, "theme")
                      then Get (Colors_By_Origin, "theme")
                      else Get (Colors_By_Origin, "default"))
                 ));
         end;
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures",
                 "color", "gradients")
      then
         declare
            Gradients_By_Origin : constant Arrays.Cursor :=
              Ref_3 (Editor_Settings, "__experimentalFeatures", "color", "gradients");
         begin
            Set (Editor_Settings, "gradients",
                 (if Isset (Gradients_By_Origin, "custom")
                  then Get (Gradients_By_Origin, "custom")
                  else
                    (if Isset (Gradients_By_Origin, "theme")
                     then Get (Gradients_By_Origin, "theme")
                     else Get (Gradients_By_Origin, "default"))
                ));
         end;
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures",
                 "typography", "fontSizes")
      then
         declare
            Font_Sizes_By_Origin : constant Arrays.Cursor :=
              Ref_3 (Editor_Settings, "__experimentalFeatures",
                     "typography", "fontSizes");
         begin
            Set (Editor_Settings, "fontSizes",
                 (if Isset (Font_Sizes_By_Origin, "custom")
                  then Get (Font_Sizes_By_Origin, "custom")
                  else
                    (if Isset (Font_Sizes_By_Origin, "theme")
                     then Get (Font_Sizes_By_Origin, "theme")
                     else Get (Font_Sizes_By_Origin, "default"))
                 ));
         end;
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures", "color", "custom")
      then
         Set (Editor_Settings, "disableCustomColors", From_Boolean (
              not As_Boolean (Get (Ref_3 (Editor_Settings, "__experimentalFeatures",
                                          "color", "custom")))));
         Delete (Ref_3 (Editor_Settings, "__experimentalFeatures",
                        "color", "custom"));
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures", "color", "customGradient")
      then
         Set (Editor_Settings, "disableCustomGradients", From_Boolean (
              not As_Boolean (Get (Ref_3 (Editor_Settings, "__experimentalFeatures",
                                   "color", "customGradient")))));
         Delete (Ref_3 (Editor_Settings, "__experimentalFeatures",
                        "color", "customGradient"));
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures",
                 "typography", "customFontSize")
      then
         Set (Editor_Settings, "disableCustomFontSizes", From_Boolean (
              not As_Boolean (Get (Ref_3 (Editor_Settings, "__experimentalFeatures",
                                   "typography", "customFontSize")))));
         Delete (Ref_3 (Editor_Settings, "__experimentalFeatures",
                        "typography", "customFontSize"));
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures",
                 "typography", "lineHeight")
      then
         Set (Editor_Settings, "enableCustomLineHeight", From_Integer (
              As_Integer (Get (Ref_3 (Editor_Settings, "__experimentalFeatures",
                                     "typography", "lineHeight")))));
         Delete (Ref_3 (Editor_Settings, "__experimentalFeatures",
                        "typography", "lineHeight"));
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures",
                 "spacing", "units")
      then
         Set (Editor_Settings, "enableCustomUnits", From_String (
              As_String (Get (Ref_3 (Editor_Settings, "__experimentalFeatures",
                                     "spacing", "units")))));
         Delete (Ref_3 (Editor_Settings, "__experimentalFeatures",
                        "spacing", "units"));
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures",
                 "spacing", "padding")
      then
         Set (Editor_Settings, "enableCustomSpacing", From_Integer (
              As_Integer (Get (Ref_3 (Editor_Settings, "__experimentalFeatures",
                                      "spacing", "padding")))));
         Delete (Ref_3 (Editor_Settings, "__experimentalFeatures",
                        "spacing", "padding"));
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures",
                 "spacing", "customSpacingSize")
      then
         Set (Editor_Settings, "disableCustomSpacingSizes", From_Boolean (
              not As_Boolean (Get (Ref_3 (Editor_Settings, "__experimentalFeatures",
                                          "spacing", "customSpacingSize")))));
         Delete (Ref_3 (Editor_Settings, "__experimentalFeatures",
                        "spacing", "customSpacingSize"));
      end if;

      if
        Isset_3 (Editor_Settings, "__experimentalFeatures",
                 "spacing", "spacingSizes")
      then
         declare
            Spacing_Sizes_By_Origin : constant Arrays.Cursor :=
              Ref_3 (Editor_Settings, "__experimentalFeatures",
                     "spacing", "spacingSizes");
         begin
            Set (Editor_Settings, "spacingSizes",
                 (if Isset (Spacing_Sizes_By_Origin, "custom")
                  then Get (Spacing_Sizes_By_Origin, "custom")
                  else
                    (if Isset (Spacing_Sizes_By_Origin, "theme")
                     then Get (Spacing_Sizes_By_Origin, "theme")
                     else Get (Spacing_Sizes_By_Origin, "default"))
                 ));
         end;
      end if;

      Set (Editor_Settings, "__unstableResolvedAssets", From_Array (
           X_Wp_Get_Iframed_Editor_Assets));

      Set (Editor_Settings, "localAutosaveInterval", From_Integer (15));

      Set (Editor_Settings, "disableLayoutStyles", From_Boolean (
           Current_Theme_Supports ("disable-layout-styles")));

      Set (Editor_Settings, "__experimentalDiscussionSettings", From_Array (
           To_Array_Type ([
             Build ("commentOrder",        String'(Get_Option ("comment_order"))),
             Build ("commentsPerPage",     String'(Get_Option ("comments_per_page"))),
             Build ("defaultCommentsPage",
                    String'(Get_Option ("default_comments_page"))),
             Build ("pageComments",         String'(Get_Option ("page_comments"))),
             Build ("threadComments",       String'(Get_Option ("thread_comments"))),
             Build ("threadCommentsDepth",
                    String'(Get_Option ("thread_comments_depth"))),
             Build ("defaultCommentStatus",
                    String'(Get_Option ("default_comment_status"))),
             Build ("avatarURL",
               Get_Avatar_URL (
                 "",
                 To_Array_Type ([
                   Build ("size",          96),
                   Build ("force_default", True),
                   Build ("default",       String'(Get_Option ("avatar_default")))
                 ])
               ))
           ])
          ));

      --
      -- Filters the settings to pass to the block editor for all editor type.
      --
      -- @since 5.8.0
      --
      -- @param array                   editor_settings      Default editor settings.
      -- @param WP_Block_Editor_Context block_editor_context The current block editor
      --                                                     context.
      --
      Editor_Settings :=
        Apply_Filters ("block_editor_settings_all", Editor_Settings,
                       Block_Editor_Context);

      if Block_Editor_Context.Post.all = Null_Post then
--    if not Empty (Block_Editor_Context.Post) then
         declare
            Post : constant Wp_Post := Block_Editor_Context.Post.all;
         begin
            --
            -- Filters the settings to pass to the block editor.
            --
            -- @since 5.0.0
            -- @deprecated 5.8.0 Use the {@see "block_editor_settings_all"}
            --                   filter instead.
            --
            -- @param array   editor_settings Default editor settings.
            -- @param WP_Post post            Post being edited.
            --
            Editor_Settings :=
              Apply_Filters_Deprecated ("block_editor_settings",
                                        Editor_Settings,
                                        Post,
--                                      To_Array (Editor_Settings, Post),
                                        "5.8.0", "block_editor_settings_all");
         end;
      end if;

      return Editor_Settings;
   end Get_Block_Editor_Settings;

   -----------------------------------
   -- Get_Block_Editor_Theme_Styles --
   -----------------------------------

   Global_Editor_Styles : List_Type; -- Array_Vectors.Array_Vector;

   function Get_Block_Editor_Theme_Styles
            return Array_Lists.Array_List
   is
      use Php.Files;
      use Php.Preg;
      use Array_Lists;
      use Inc_HTTP;
      use Inc_Themes;
      use Inc_Load;
      use Inc_Link_Templates;
--    global editor_styles;

      Styles : Array_List;
   begin
      if
        not Global_Editor_Styles.Is_Empty and then
        Current_Theme_Supports ("editor-styles")
      then
         for Style of Global_Editor_Styles loop
            if Preg_Match ("~^(https?:)?//~", Style) then
               declare
                  Response : constant Array_Type := Wp_Remote_Get (Style);
               begin
                  if not Is_Wp_Error (Response) then
                     Styles.Append (To_Array_Type ([
                       Build ("css",            Wp_Remote_Retrieve_Body (Response)),
                       Build ("__unstableType", "theme"),
                       Build ("isGlobalStyles", False)
                     ]));
                  end if;
               end;
            else
               declare
                  File : constant String := Get_Theme_File_Path (Style);
               begin
                  if Is_File (File) then
                     Styles.Append (To_Array_Type ([
                       Build ("css",            File_Get_Contents (File)),
                       Build ("baseURL",        Get_Theme_File_URI (Style)),
                       Build ("__unstableType", "theme"),
                       Build ("isGlobalStyles", False)
                     ]));
                  end if;
               end;
            end if;
         end loop;
      end if;

      return Styles;
   end Get_Block_Editor_Theme_Styles;

end Inc_Block_Editors;
