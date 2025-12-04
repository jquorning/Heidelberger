--
-- Block Editor API.
--
-- @package WordPress
-- @subpackage Editor
-- @since 5.8.0
--

with Ada.Strings.Unbounded;

with Php.Files;
with Php.Lists;
with Php.Misc;

with Globals;
with Hb_Common;

with Inc_Class_Wp_Posts;
with Inc_Functions;
with Inc_Global_Styles_And_Settings;
with Inc_L10n;
with Inc_Media;
with Inc_Options;
with Inc_Plugins;
with Inc_Themes;
with Inc_Class_Wp_Theme_JSON_Resolver;

package body Inc_Block_Editors
is
   use Ada.Strings.Unbounded;

   Static_Default_Editor_Styles_File_Contents_Bool : Boolean := False;
   Static_Default_Editor_Styles_File_Contents      : Unbounded_String;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Array_Type;
               Item      : Inc_Class_Wp_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type
               is (Value);

   function Apply_Filters
              (Hook_Name : String;
               Value     : List_Type; -- Boolean;
               Item      : Inc_Class_Wp_Block_Editor_Contexts.Wp_Block_Editor_Context)                return List_Type -- Boolean
               is (Value);

   function Apply_Filters_Deprecated
              (Hook_Name : String;
               Value     : Array_Type;
               Version   : String;
               X         : String)
               return Array_Type
               is (Value);

   function Apply_Filters_Deprecated
              (Hook_Name : String;
               Value     : List_Type; -- Boolean;
               Version   : String;
               X         : String)
               return List_Type -- Boolean
               is (Value);

   ----------------------------------
   -- Get_Default_Block_Categories --
   ----------------------------------

   function Get_Default_Block_Categories
            return Array_Type
   is
      use Inc_L10n;
   begin
      return
        To_Array (List => (
          To_Array (List => (
            Build ("slug",  "text"),
            Build ("title", X_X ("Text", "block category")),
            Build ("icon",  null)
          )),
          To_Array (List => (
            Build ("slug",  "media"),
            Build ("title", X_X ("Media", "block category")),
            Build ("icon",  null)
          )),
          To_Array (List => (
            Build ("slug",  "design"),
            Build ("title", X_X ("Design", "block category")),
            Build ("icon",  null)
          )),
          To_Array (List => (
            Build ("slug",  "widgets"),
            Build ("title", X_X ("Widgets", "block category")),
            Build ("icon",  null)
          )),
          To_Array (List => (
            Build ("slug",  "theme"),
            Build ("title", X_X ("Theme", "block category")),
            Build ("icon",  null)
          )),
          To_Array (List => (
            Build ("slug",  "embed"),
            Build ("title", X_X ("Embeds", "block category")),
            Build ("icon",  null)
          )),
          To_Array (List => (
            Build ("slug",  "reusable"),
            Build ("title", X_X ("Reusable Blocks", "block category")),
            Build ("icon",  null)
          ))
        ));
   end Get_Default_Block_Categories;

   --------------------------
   -- Get_Block_Categories --
   --------------------------

   function Get_Block_Categories
              (Post_Or_Block_Editor_Context :
                 Inc_Class_Wp_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type
   is
      use Inc_Class_Wp_Block_Editor_Contexts;
      use Inc_Class_Wp_Posts;
--    use Inc_Plugins;

      Block_Categories     : Array_Type := Get_Default_Block_Categories;
      Block_Editor_Context : constant Wp_Block_Editor_Context :=
        (if False -- Post_Or_Block_Editor_Context in Wp_Post -- instanceof
         then X_Construct ( -- new WP_Block_Editor_Context(
                To_Array (List => (1 =>
                  Build ("post", "XXX-019") -- Post_Or_Block_Editor_Context)
                )))
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
                 Empty_Array, -- To_Array (Block_Categories, Post),
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
                 Inc_Class_Wp_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return List_Type
   is
      use Inc_Class_Wp_Posts;
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
                Empty_List, -- array( allowed_block_types, post ),
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
      use Hb_Common;
      use Php;
      use Php.Files;
      use Php.Lists;
      use Php.Misc;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Media;
      use Inc_Options;
      use Inc_Plugins;
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

               Value : constant Array_Type := To_Array (List => (
                 Build ("slug", Image_Size_Slug),
                 Build ("name", Image_Size_Name)));
            begin
               Append (Result, From_Array (Value));
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
        To_Array (List => (
          Build ("thumbnail", abs "Thumbnail"),
          Build ("medium",    abs "Medium"),
          Build ("large",     abs "Large"),
          Build ("full",      abs "Full Size")
        ))
      );

      Available_Image_Sizes : constant Array_Type :=
        Get_Image_Sizes (Image_Size_Names);

      Default_Size : constant String := Get_Option ("image_default_size", "large");

      Image_Default_Size : String :=
        (if In_Array (Default_Size, List_Type'(Array_Keys (Image_Size_Names)), True)
         then Default_Size else "large");

      Image_Dimensions : Array_Type;

      All_Sizes : constant Array_Type :=
        Wp_Get_Registered_Image_Subsizes; -- ()

      -- These styles are used if the "no theme styles" options is triggered
      -- or on themes without their own editor styles.
      Default_Editor_Styles_File : constant String :=
        Globals.ABSPATH & (-Globals.WPINC) &
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
         Default_Editor_Styles := To_Array (List => (1 =>
           To_Array (List => (1 =>
             Build ("css", -Static_Default_Editor_Styles_File_Contents))
           )));
      end if;

      declare
         Editor_Settings : Array_Type := To_Array (List => (
           Build ("alignWide",             Boolean'(Get_Theme_Support ("align-wide"))),
           Build ("allowedBlockTypes",     True),
           Build ("allowedMimeTypes",      Get_Allowed_MIME_Types),
           Build ("defaultEditorStyles",   Default_Editor_Styles),
           Build ("blockCategories",       Get_Default_Block_Categories),
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
         ));

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
      use Hb_Common;
      use Inc_Plugins;

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
             To_List (List => (
                        +"pages",
                        +"calendar",
                        +"archives",
                        +"media_audio",
                        +"media_image",
                        +"media_gallery",
                        +"media_video",
                        +"search",
                        +"text",
                        +"categories",
                        +"recent-posts",
                        +"recent-comments",
                        +"rss",
                        +"tag_cloud",
                        +"custom_html",
                        +"block"
             ))
           ))
          );

      return Editor_Settings;
   end Get_Legacy_Widget_Block_Editor_Settings;

   -------------------------------
   -- Get_Block_Editor_Settings --
   -------------------------------

   function Get_Block_Editor_Settings
              (Custom_Settings      : Array_Type;
               Block_Editor_Context :
                 Inc_Class_Wp_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type
   is
      use Php;
      use Inc_Global_Styles_And_Settings;

      Editor_Settings : constant Array_Type := Array_Merge (
        Get_Default_Block_Editor_Settings, -- (),
        To_Array (List => (
          Build ("allowedBlockTypes", Get_Allowed_Block_Types (Block_Editor_Context)),
          Build ("blockCategories",   Get_Block_Categories (Block_Editor_Context))
        )),
        Custom_Settings
      );

      Global_Styles : Array_Type;

      Presets : Array_List := ( -- To_Array (List =>
        1 => To_Array (List => (
               Build ("css",            "variables"),
               Build ("__unstableType", "presets"),
               Build ("isGlobalStyles", True)
             )),
        2 => To_Array (List => (
               Build ("css",            "presets"),
               Build ("__unstableType", "presets"),
               Build ("isGlobalStyles", True)
             ))
        );
   begin
      for Preset_Style of Presets loop
         declare
            Actual_CSS : constant String :=
              Wp_Get_Global_Stylesheet (As_List (Get (Preset_Style, "css")));
         begin
            if "" /= Actual_CSS then
               Set (Preset_Style, "css", From_String (Actual_CSS));
               Global_Styles.Append (From_Array (Preset_Style));
            end if;
         end;
      end loop;

      if Inc_Class_Wp_Theme_JSON_Resolver.Theme_Has_Support then
         declare
            Block_Classes : Array_Type := To_Array (List => (
              Build ("css",            "styles"),
              Build ("__unstableType", "theme"),
              Build ("isGlobalStyles", True)
            ));
            Actual_CSS : constant String :=
              Wp_Get_Global_Stylesheet (As_List (Get (Block_Classes, "css")));
         begin
            if "" /= Actual_CSS then
               Set (Block_Classes, "css", From_String (Actual_CSS));
               Global_Styles.Append (From_Array (Block_Classes));
            end if;
         end;
      else
         -- If there is no `theme.json` file, ensure base layout styles are still
         -- available.
         declare
            Block_Classes : Array_Type := To_Array (List => (
              Build ("css",            "base-layout-styles"),
              Build ("__unstableType", "base-layout"),
              Build ("isGlobalStyles", True)
            ));
            Actual_CSS : constant String :=
              Wp_Get_Global_Stylesheet (As_List (Get (Block_Classes, "css")));
         begin
            if "" /= Actual_CSS then
               Set (Block_Classes, "css", From_String (Actual_CSS));
               Global_Styles.Append (From_Array (Block_Classes));
            end if;
         end;
      end if;

      raise Program_Error with "not implemented";

        -- editor_settings["styles"] = array_merge( global_styles, get_block_editor_theme_styles() );

        -- editor_settings["__experimentalFeatures"] = wp_get_global_settings();
        -- -- These settings may need to be updated based on data coming from theme.json sources.
        -- if ( isset( editor_settings["__experimentalFeatures"]["color"]["palette"] ) ) then
        --         colors_by_origin          = editor_settings["__experimentalFeatures"]["color"]["palette"];
        --         editor_settings["colors"] = isset( colors_by_origin["custom"] ) ?
        --                 colors_by_origin["custom"] : (
        --                         isset( colors_by_origin["theme"] ) ?
        --                                 colors_by_origin["theme"] :
        --                                 colors_by_origin["default"]
        --                 );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["color"]["gradients"] ) ) then
        --         gradients_by_origin          = editor_settings["__experimentalFeatures"]["color"]["gradients"];
        --         editor_settings["gradients"] = isset( gradients_by_origin["custom"] ) ?
        --                 gradients_by_origin["custom"] : (
        --                         isset( gradients_by_origin["theme"] ) ?
        --                                 gradients_by_origin["theme"] :
        --                                 gradients_by_origin["default"]
        --                 );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["typography"]["fontSizes"] ) ) then
        --         font_sizes_by_origin         = editor_settings["__experimentalFeatures"]["typography"]["fontSizes"];
        --         editor_settings["fontSizes"] = isset( font_sizes_by_origin["custom"] ) ?
        --                 font_sizes_by_origin["custom"] : (
        --                         isset( font_sizes_by_origin["theme"] ) ?
        --                                 font_sizes_by_origin["theme"] :
        --                                 font_sizes_by_origin["default"]
        --                 );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["color"]["custom"] ) ) then
        --         editor_settings["disableCustomColors"] = ! editor_settings["__experimentalFeatures"]["color"]["custom"];
        --         unset( editor_settings["__experimentalFeatures"]["color"]["custom"] );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["color"]["customGradient"] ) ) then
        --         editor_settings["disableCustomGradients"] = ! editor_settings["__experimentalFeatures"]["color"]["customGradient"];
        --         unset( editor_settings["__experimentalFeatures"]["color"]["customGradient"] );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["typography"]["customFontSize"] ) ) then
        --         editor_settings["disableCustomFontSizes"] = ! editor_settings["__experimentalFeatures"]["typography"]["customFontSize"];
        --         unset( editor_settings["__experimentalFeatures"]["typography"]["customFontSize"] );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["typography"]["lineHeight"] ) ) then
        --         editor_settings["enableCustomLineHeight"] = editor_settings["__experimentalFeatures"]["typography"]["lineHeight"];
        --         unset( editor_settings["__experimentalFeatures"]["typography"]["lineHeight"] );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["spacing"]["units"] ) ) then
        --         editor_settings["enableCustomUnits"] = editor_settings["__experimentalFeatures"]["spacing"]["units"];
        --         unset( editor_settings["__experimentalFeatures"]["spacing"]["units"] );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["spacing"]["padding"] ) ) then
        --         editor_settings["enableCustomSpacing"] = editor_settings["__experimentalFeatures"]["spacing"]["padding"];
        --         unset( editor_settings["__experimentalFeatures"]["spacing"]["padding"] );
        -- end;
        -- if ( isset( editor_settings["__experimentalFeatures"]["spacing"]["customSpacingSize"] ) ) then
        --         editor_settings["disableCustomSpacingSizes"] = ! editor_settings["__experimentalFeatures"]["spacing"]["customSpacingSize"];
        --         unset( editor_settings["__experimentalFeatures"]["spacing"]["customSpacingSize"] );
        -- end;

        -- if ( isset( editor_settings["__experimentalFeatures"]["spacing"]["spacingSizes"] ) ) then
        --         spacing_sizes_by_origin         = editor_settings["__experimentalFeatures"]["spacing"]["spacingSizes"];
        --         editor_settings["spacingSizes"] = isset( spacing_sizes_by_origin["custom"] ) ?
        --                 spacing_sizes_by_origin["custom"] : (
        --                         isset( spacing_sizes_by_origin["theme"] ) ?
        --                                 spacing_sizes_by_origin["theme"] :
        --                                 spacing_sizes_by_origin["default"]
        --                 );
        -- end;

        -- editor_settings["__unstableResolvedAssets"]         = _wp_get_iframed_editor_assets();
        -- editor_settings["localAutosaveInterval"]            = 15;
        -- editor_settings["disableLayoutStyles"]              = current_theme_supports( "disable-layout-styles" );
        -- editor_settings["__experimentalDiscussionSettings"] = array(
        --         "commentOrder"         => get_option( "comment_order" ),
        --         "commentsPerPage"      => get_option( "comments_per_page" ),
        --         "defaultCommentsPage"  => get_option( "default_comments_page" ),
        --         "pageComments"         => get_option( "page_comments" ),
        --         "threadComments"       => get_option( "thread_comments" ),
        --         "threadCommentsDepth"  => get_option( "thread_comments_depth" ),
        --         "defaultCommentStatus" => get_option( "default_comment_status" ),
        --         "avatarURL"            => get_avatar_url(
        --                 "",
        --                 array(
        --                         "size"          => 96,
        --                         "force_default" => true,
        --                         "default"       => get_option( "avatar_default" ),
        --                 )
        --         ),
        -- );

        -- --
        -- -- Filters the settings to pass to the block editor for all editor type.
        -- --
        -- -- @since 5.8.0
        -- --
        -- -- @param array                   editor_settings      Default editor settings.
        -- -- @param WP_Block_Editor_Context block_editor_context The current block editor context.
        -- --
        -- editor_settings = apply_filters( "block_editor_settings_all", editor_settings, block_editor_context );

        -- if ( ! empty( block_editor_context->post ) ) then
        --         post = block_editor_context->post;

        --         --
        --         -- Filters the settings to pass to the block editor.
        --         --
        --         -- @since 5.0.0
        --         -- @deprecated 5.8.0 Use the then@see "block_editor_settings_all"end; filter instead.
        --         --
        --         -- @param array   editor_settings Default editor settings.
        --         -- @param WP_Post post            Post being edited.
        --         --
        --         editor_settings = apply_filters_deprecated( "block_editor_settings", array( editor_settings, post ), "5.8.0", "block_editor_settings_all" );
        -- end;

      return Editor_Settings;
   end Get_Block_Editor_Settings;

end Inc_Block_Editors;
