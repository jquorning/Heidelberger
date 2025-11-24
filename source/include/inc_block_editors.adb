--
-- Block Editor API.
--
-- @package WordPress
-- @subpackage Editor
-- @since 5.8.0
--

with Ada.Strings.Unbounded;

with Globals;
with Hb_Common;
with Php;

with Inc_Functions;
with Inc_L10n;
with Inc_Media;
with Inc_Options;
with Inc_Plugins;
with Inc_Themes;

package body Inc_Block_Editors
is
   use Ada.Strings.Unbounded;

   Static_Default_Editor_Styles_File_Contents_Bool : Boolean := False;
   Static_Default_Editor_Styles_File_Contents      : Unbounded_String;

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

   ---------------------------------------
   -- Get_Default_Block_Editor_Settings --
   ---------------------------------------

   function Get_Default_Block_Editor_Settings
            return Array_Type
   is
      use Hb_Common;
      use Php;
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
        (if In_Array (Default_Size, Array_Keys (Image_Size_Names), True)
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
           Build ("alignWide",             Get_Theme_Support ("align-wide")),
           Build ("allowedBlockTypes",     True),
           Build ("allowedMimeTypes",      Get_Allowed_MIME_Types),
           Build ("defaultEditorStyles",   Default_Editor_Styles),
           Build ("blockCategories",       Get_Default_Block_Categories),
           Build ("disableCustomColors",
             Get_Theme_Support ("disable-custom-colors")),
           Build ("disableCustomFontSizes",
             Get_Theme_Support ("disable-custom-font-sizes")),
           Build ("disableCustomGradients",
             Get_Theme_Support ("disable-custom-gradients")),
           Build ("disableLayoutStyles",
             Get_Theme_Support ("disable-layout-styles")),
           Build ("enableCustomLineHeight",
             Get_Theme_Support ("custom-line-height")),
           Build ("enableCustomSpacing",
             Get_Theme_Support ("custom-spacing")),
           Build ("enableCustomUnits",
             Get_Theme_Support ("custom-units")),

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

end Inc_Block_Editors;
