--
-- WP_Theme_JSON_Schema class
--
-- @package WordPress
-- @subpackage Theme
-- @since 5.9.0
--

with Arrays;
with Lists;

package Inc_Class_Wp_Theme_JSON_Schema
is
   use Arrays;
   use Lists;

   --
   -- Class that migrates a given theme.json structure to the latest schema.
   --
   -- This class is for internal core usage and is not supposed to be used by
   -- extenders (plugins and/or themes).
   -- This is a low-level API that may need to do breaking changes. Please,
   -- use get_global_settings, get_global_styles, and get_global_stylesheet instead.
   --
   -- @since 5.9.0
   -- @access private
   --
   -- #[AllowDynamicProperties]
   type Wp_Theme_JSON_Schema is tagged
      record
         null;
      end record;

   --
   -- Maps old properties to their new location within the schema"s settings.
   -- This will be applied at both the defaults and individual block levels.
   --
   V1_TO_V2_RENAMED_PATHS : constant Array_Type := To_Array (List => (
     Build ("border.customRadius",         "border.radius"),
     Build ("spacing.customMargin",        "spacing.margin"),
     Build ("spacing.customPadding",       "spacing.padding"),
     Build ("typography.customLineHeight", "typography.lineHeight")
   ));

   --
   -- Function that migrates a given theme.json structure to the last version.
   --
   -- @since 5.9.0
   --
   -- @param array $theme_json The structure to migrate.
   --
   -- @return array The structure in the last version.
   --
   -- public static
   function Migrate (Theme_JSON : Array_Type)
                     return Array_Type;

   --
   -- Removes the custom prefixes for a few properties
   -- that were part of v1:
   --
   -- "border.customRadius"         => "border.radius",
   -- "spacing.customMargin"        => "spacing.margin",
   -- "spacing.customPadding"       => "spacing.padding",
   -- "typography.customLineHeight" => "typography.lineHeight",
   --
   -- @since 5.9.0
   --
   -- @param array $old Data to migrate.
   --
   -- @return array Data without the custom prefixes.
   --
   -- private static
   function Migrate_V1_To_V2 (Old : Array_Type)
                              return Array_Type;

   --
   -- Processes the settings subtree.
   --
   -- @since 5.9.0
   --
   -- @param array $settings        Array to process.
   -- @param array $paths_to_rename Paths to rename.
   --
   -- @return array The settings in the new format.
   --
   -- private static
   function Rename_Paths (Settings        : Array_Type;
                          Paths_To_Rename : Array_Type)
                          return Array_Type;

   --
   -- Processes a settings array, renaming or moving properties.
   --
   -- @since 5.9.0
   --
   -- @param array $settings        Reference to settings either defaults or an
   --                               individual block's.
   -- @param array $paths_to_rename Paths to rename.
   --
   -- private static
   procedure Rename_Settings (Settings        : in out Array_Type;
                              Paths_To_Rename : Array_Type);

   --
   -- Removes a property from within the provided settings by its path.
   --
   -- @since 5.9.0
   --
   -- @param array $settings Reference to the current settings array.
   -- @param array $path Path to the property to be removed.
   --
   -- @return void
   --
   -- private static
   procedure Unset_Setting_By_Path (Settings : in out Array_Type;
                                    Path     : List_Type);

end Inc_Class_Wp_Theme_JSON_Schema;
