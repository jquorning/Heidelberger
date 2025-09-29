--
-- Locale API: WP_Textdomain_Registry class
--
-- @package WordPress
-- @subpackage i18n
-- @since 6.1.0
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrays;

package Inc_Class_Wp_Textdomain_Registry
is
   use Arrays;

   package String_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => String);

   package Alll_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => String_Maps.Map,
                                              "="          => String_Maps."=");
   --
   -- Core class used for registering text domains.
   --
   -- @since 6.1.0
   --
-- #[AllowDynamicProperties]
   type Wp_Textdomain_Registry is tagged
      record
         --
         -- List of domains and all their language directory paths for each locale.
         --
         -- @since 6.1.0
         --
         -- @var array
         --
--         protected
         Alll : Alll_Maps.Map;

         --
         -- List of domains and their language directory path for the current (most
         -- recent) locale.
         --
         -- @since 6.1.0
         --
         -- @var array
         --
--         protected
         Current : String_Maps.Map;

         --
         -- List of domains and their custom language directory paths.
         --
         -- @see load_plugin_textdomain()
         -- @see load_theme_textdomain()
         --
         -- @since 6.1.0
         --
         -- @var array
         --
--         protected
         Custom_Paths : String_Maps.Map;

         --
         -- Holds a cached list of available .mo files to improve performance.
         --
         -- @since 6.1.0
         --
         -- @var array
         --
--         protected
         Cached_Mo_Files : String_Maps.Map;

      end record;

   --
   -- Returns the languages directory path for a specific domain and locale.
   --
   -- @since 6.1.0
   --
   -- @param string domain Text domain.
   -- @param string locale Locale.
   --
   -- @return string|false MO file path or false if there is none available.
   --
   function Get (This   : in out Wp_Textdomain_Registry;
                 Domain : String;
                 Locale : String)
                 return String;

   --
   -- Determines whether any MO file paths are available for the domain.
   --
   -- This is the case if a path has been set for the current locale,
   -- or if there is no information stored yet, in which case
   -- {@see _load_textdomain_just_in_time()} will fetch the information first.
   --
   -- @since 6.1.0
   --
   -- @param string domain Text domain.
   -- @return bool Whether any MO file paths are available for the domain.
   --
   function Has (This   : Wp_Textdomain_Registry;
                 Domain : String)
                 return Boolean;

   --
   -- Sets the language directory path for a specific domain and locale.
   --
   -- Also sets the "current" property for direct access
   -- to the path for the current (most recent) locale.
   --
   -- @since 6.1.0
   --
   -- @param string       domain Text domain.
   -- @param string       locale Locale.
   -- @param string|false path   Language directory path or false if there is none
   --                            available.
   --
   procedure Set (This   : in out Wp_Textdomain_Registry;
                  Domain : String;
                  Locale : String;
                  Path   : String);

   --
   -- Sets the custom path to the plugin"s/theme"s languages directory.
   --
   -- Used by {@see load_plugin_textdomain()} and {@see load_theme_textdomain()}.
   --
   -- @param string domain Text domain.
   -- @param string path   Language directory path.
   --
   procedure Set_Custom_Path (This   : in out Wp_Textdomain_Registry;
                              Domain : String;
                              Path   : String);

private

   --
   -- Gets the path to the language directory for the current locale.
   --
   -- Checks the plugins and themes language directories as well as any
   -- custom directory set via {@see load_plugin_textdomain()} or {@see
   -- load_theme_textdomain()}.
   --
   -- @since 6.1.0
   --
   -- @see _get_path_to_translation_from_lang_dir()
   --
   -- @param string domain Text domain.
   -- @param string locale Locale.
   -- @return string|false Language directory path or false if there is none available.
   --
   -- private
   function Get_Path_From_Lang_Dir (This   : in out Wp_Textdomain_Registry;
                                    Domain : String;
                                    Locale : String)
                                    return String;

   --
   -- Reads and caches all available MO files from a given directory.
   --
   -- @since 6.1.0
   --
   -- @param string path Language directory path.
   --
   -- private
   procedure Set_Cached_Mo_Files (This : in out Wp_Textdomain_Registry;
                                  Path : String);

end Inc_Class_Wp_Textdomain_Registry;
