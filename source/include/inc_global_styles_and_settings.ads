--
-- APIs to interact with global settings & styles.
--
-- @package WordPress
--

with Arrays;

package Inc_Global_Styles_And_Settings
is
   use Arrays;

   --
   -- Gets the settings resulting of merging core, theme, and user data.
   --
   -- @since 5.9.0
   --
   -- @param array path    Path to the specific setting to retrieve. Optional.
   --                       If empty, will return all settings.
   -- @param array context {
   --     Metadata to know where to retrieve the path from. Optional.
   --
   --     @type string block_name Which block to retrieve the settings from.
   --                              If empty, it"ll return the settings for the global
   --                              context.
   --     @type string origin     Which origin to take data from.
   --                              Valid values are "all" (core, theme, and user) or
   --                              "base" (core and theme). If empty or unknown,
   --                              "all" is used.
   -- }
   -- @return array The settings to retrieve.
   --
   function Wp_Get_Global_Settings (Path    : List_Type  := Empty_List;
                                    Context : Array_Type := Empty_Array)
                                    return Multi_Type; -- Array_Type;

   --
   -- Returns the stylesheet resulting of merging core, theme, and user data.
   --
   -- @since 5.9.0
   --
   -- @param array types Types of styles to load. Optional.
   --                     It accepts "variables", "styles", "presets" as values.
   --                     If empty, it"ll load all for themes with theme.json support
   --                     and only [ "variables", "presets" ] for themes without
   --                     theme.json support.
   -- @return string Stylesheet.
   --
   function Wp_Get_Global_Stylesheet (Types : List_Type := Empty_List) -- Array_Type := Empty_Array)
                                      return String;

   --
   -- Adds global style rules to the inline style for each block.
   --
   -- @since 6.1.0
   --
   procedure Wp_Add_Global_Styles_For_Blocks;

end Inc_Global_Styles_And_Settings;
