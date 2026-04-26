--
-- WordPress Plugin Administration API: WP_Plugin_Dependencies class
--
-- @package WordPress
-- @subpackage Administration
-- @since 6.5.0
--

with Arrays;
with Lists;

package Class_Plugin_Dependencies is
   use Arrays;
   use Lists;

   --
   -- Core class for installing plugin dependencies.
   --
   -- It is designed to add plugin dependencies as designated in the
   -- `Requires Plugins` header to a new view in the plugins install page.
   --
   type Wp_Plugin_Dependencies is tagged private;

   --
   -- Initializes by fetching plugin header and plugin API data.
   --
   -- @since 6.5.0
   --
   -- public static
   procedure Initialize;

   --
   -- Determines whether the plugin has plugins that depend on it.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The plugin's filepath, relative to the plugins directory.
   -- @return bool Whether the plugin has plugins that depend on it.
   --
   -- public static
--   function Has_Dependents (Plugin_File : String) return Boolean;

   --
   -- Determines whether the plugin has plugin dependencies.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- @return bool Whether a plugin has plugin dependencies.
   --
   -- public static
--   function Has_Dependencies (Plugin_File : String) return Boolean;

   --
   -- Determines whether the plugin has active dependents.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- @return bool Whether the plugin has active dependents.
   --
   -- public static
--   function Has_Active_Dependents (Plugin_File : String) return Boolean;

   --
   -- Gets filepaths of plugins that require the dependency.
   --
   -- @since 6.5.0
   --
   -- @param string slug The dependency's slug.
   -- @return array An array of dependent plugin filepaths, relative to the plugins directory.
   --
   -- public static
--   function Get_Dependents (Slug : String) return Array_Type;

   --
   -- Gets the slugs of plugins that the dependent requires.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The dependent plugin's filepath, relative to the plugins directory.
   -- @return array An array of dependency plugin slugs.
   --
   -- public static
--   function Get_Dependencies (Plugin_File : String) return Array_Type;

   --
   -- Gets a dependent plugin"s filepath.
   --
   -- @since 6.5.0
   --
   -- @param string slug  The dependent plugin's slug.
   -- @return string|false The dependent plugin's filepath, relative to the plugins directory,
   --                      or false if the plugin has no dependencies.
   --
   -- public static
--   function Get_Dependent_Filepath (Slug : String) return String;

   --
   -- Determines whether the plugin has unmet dependencies.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The plugin's filepath, relative to the plugins directory.
   -- @return bool Whether the plugin has unmet dependencies.
   --
   -- public static
--   function Has_Unmet_Dependencies (Plugin_File : String) return Boolean;

   --
   -- Determines whether the plugin has a circular dependency.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The plugin's filepath, relative to the plugins directory.
   -- @return bool Whether the plugin has a circular dependency.
   --
   -- public static
--   function Has_Circular_Dependency (Plugin_File : String) return Boolean;

   --
   -- Gets the names of plugins that require the plugin.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The plugin's filepath, relative to the plugins directory.
   -- @return array An array of dependent names.
   --
   -- public static
--   function Get_Dependent_Names (Plugin_File : String) return Array_Type;

   --
   -- Gets the names of plugins required by the plugin.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The dependent plugin's filepath, relative to the plugins directory.
   -- @return array An array of dependency names.
   --
   -- public static
--   function Get_Dependency_Names (Plugin_File : String) return Array_Type;

   --
   -- Gets the filepath for a dependency, relative to the plugin"s directory.
   --
   -- @since 6.5.0
   --
   -- @param string slug The dependency's slug.
   -- @return string|false If installed, the dependency's filepath relative to the plugins directory, otherwise false.
   --
   -- public static
   function Get_Dependency_Filepath (Slug : String) return String;

   --
   -- Returns API data for the dependency.
   --
   -- @since 6.5.0
   --
   -- @param string slug The dependency's slug.
   -- @return array|false The dependency's API data on success, otherwise false.
   --
   -- public static
   function Get_Dependency_Data (Slug : String) return Array_Type;

   --
   -- Displays an admin notice if dependencies are not installed.
   --
   -- @since 6.5.0
   --
   -- public static
   procedure Display_Admin_Notice_For_Unmet_Dependencies;

   --
   -- Displays an admin notice if circular dependencies are installed.
   --
   -- @since 6.5.0
   --
   -- public static
   procedure Display_Admin_Notice_For_Circular_Dependencies;

   --
   -- Checks plugin dependencies after a plugin is installed via AJAX.
   --
   -- @since 6.5.0
   --
   -- public static
--   procedure Check_Plugin_Dependencies_During_Ajax;

private
        --
        -- Gets data for installed plugins.
        --
        -- @since 6.5.0
        --
        -- @return array An array of plugin data.
        --
        -- protected static
   function Get_Plugins return Array_Type;

   --
   -- Reads and stores dependency slugs from a plugin"s "Requires Plugins" header.
   --
   -- @since 6.5.0
   --
   -- protected static
   procedure Read_Dependencies_From_Plugin_Headers;

   --
   -- Sanitizes slugs.
   --
   -- @since 6.5.0
   --
   -- @param string slugs A comma-separated string of plugin dependency slugs.
   -- @return array An array of sanitized plugin dependency slugs.
   --
   -- protected static
   function Sanitize_Dependency_Slugs (Slugs : String) return Array_Type;

   --
   -- Gets the filepath of installed dependencies.
   -- If a dependency is not installed, the filepath defaults to false.
   --
   -- @since 6.5.0
   --
   -- @return array An array of install dependencies filepaths, relative to the plugins directory.
   --
   -- protected static
   function Get_Dependency_Filepaths return Array_Type;

   --
   -- Retrieves and stores dependency plugin data from the WordPress.org Plugin API.
   --
   -- @since 6.5.0
   --
   -- @global string pagenow The filename of the current screen.
   --
   -- @return array|void An array of dependency API data, or void on early exit.
   --
   -- protected static
   function Get_Dependency_API_Data return Array_Type;

   procedure Get_Dependency_API_Data;

   --
   -- Gets plugin directory names.
   --
   -- @since 6.5.0
   --
   -- @return array An array of plugin directory names.
   --
   -- protected static
   function Get_Plugin_Dirnames return Array_Type;

   --
   -- Gets circular dependency data.
   --
   -- @since 6.5.0
   --
   -- @return array[] An array of circular dependency pairings.
   --
   -- protected static
   function Get_Circular_Dependencies return Array_Type;

   --
   -- Checks for circular dependencies.
   --
   -- @since 6.5.0
   --
   -- @param array dependents   Array of dependent plugins.
   -- @param array dependencies Array of plugins dependencies.
   -- @return array A circular dependency pairing, or an empty array if none exists.
   --
   -- protected static
   function Check_For_Circular_Dependencies
     (Dependents : Array_Type; Dependencies : Array_Type) return Array_Type;

   --
   -- Converts a plugin filepath to a slug.
   --
   -- @since 6.5.0
   --
   -- @param string plugin_file The plugin"s filepath, relative to the plugins directory.
   -- @return string The plugin"s slug.
   --
   -- protected static
   function Convert_To_Slug (Plugin_File : String) return String;

   --
   -- Core class for installing plugin dependencies.
   --
   -- It is designed to add plugin dependencies as designated in the
   -- `Requires Plugins` header to a new view in the plugins install page.
   --
   type Wp_Plugin_Dependencies is tagged record

      --
      -- Holds "get_plugins()".
      --
      -- @since 6.5.0
      --
      -- @var array
      --
      -- protected static
      Plugins : Array_Type;

      --
      -- Holds plugin directory names to compare with cache.
      --
      -- @since 6.5.0
      --
      -- @var array
      --
      -- protected static
      Plugin_Dirnames : Array_Type;

      --
      -- Holds sanitized plugin dependency slugs.
      --
      -- Keyed on the dependent plugin"s filepath,
      -- relative to the plugins directory.
      --
      -- @since 6.5.0
      --
      -- @var array
      --
      -- protected static
      Dependencies : Array_Type;

      --
      -- Holds an array of sanitized plugin dependency slugs.
      --
      -- @since 6.5.0
      --
      -- @var array
      --
      -- protected static
      Dependency_Slugs : Array_Type;

      --
      -- Holds an array of dependent plugin slugs.
      --
      -- Keyed on the dependent plugin's filepath,
      -- relative to the plugins directory.
      --
      -- @since 6.5.0
      --
      -- @var array
      --
      -- protected static
      Dependent_Slugs : Array_Type;

      --
      -- Holds "plugins_api()" data for plugin dependencies.
      --
      -- @since 6.5.0
      --
      -- @var array
      --
      -- protected static
      Dependency_API_Data : Array_Type;

      --
      -- Holds plugin dependency filepaths, relative to the plugins directory.
      --
      -- Keyed on the dependency's slug.
      --
      -- @since 6.5.0
      --
      -- @var string[]
      --
      -- protected static
      Dependency_Filepaths : Array_Type;

      --
      -- An array of circular dependency pairings.
      --
      -- @since 6.5.0
      --
      -- @var array[]
      --
      -- protected static
      Circular_Dependencies_Pairs : Array_Type;

      --
      -- An array of circular dependency slugs.
      --
      -- @since 6.5.0
      --
      -- @var string[]
      --
      -- protected static
      Circular_Dependencies_Slugs : List_Type;

      --
      -- Whether Plugin Dependencies have been initialized.
      --
      -- @since 6.5.0
      --
      -- @var bool
      --
      -- protected static
      Initialized : Boolean := False;
   end record;

   Self : Wp_Plugin_Dependencies;

end Class_Plugin_Dependencies;
