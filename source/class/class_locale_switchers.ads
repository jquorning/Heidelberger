--
-- Locale API: WP_Locale_Switcher class
--
-- @package WordPress
-- @subpackage i18n
-- @since 4.7.0
--

with Ada.Strings.Unbounded;

with Lists;

package Class_Locale_Switchers
is
   use Ada.Strings.Unbounded;
   use Lists;

   --
   -- Core class used for switching locales.
   --
   -- @since 4.7.0
   --
   -- #[AllowDynamicProperties]
   type Wp_Locale_Switcher is tagged
      record
         --
         -- Locale stack.
         --
         -- @since 4.7.0
         -- @var string[]
         --
         -- private
         Locales : List_Type;

         --
         -- Original locale.
         --
         -- @since 4.7.0
         -- @var string
         --
         -- private
         Original_Locale : Unbounded_String;

         --
         -- Holds all available languages.
         --
         -- @since 4.7.0
         -- @var string[] An array of language codes (file names without the .mo
         -- extension).
         --
         -- private
         Available_Languages : List_Type;

      end record;

        -- --
        -- -- Constructor.
        -- --
        -- -- Stores the original locale as well as a list of all available languages.
        -- --
        -- -- @since 4.7.0
        -- --
        -- public function __construct() then
        --         this.original_locale     = determine_locale();
        --         this.available_languages = array_merge( array( "en_US" ), get_available_languages() );
        -- end;

        -- --
        -- -- Initializes the locale switcher.
        -- --
        -- -- Hooks into the then@see "locale"end; filter to change the locale on the fly.
        -- --
        -- -- @since 4.7.0
        -- --
        -- public function init() then
        --         add_filter( "locale", array( this, "filter_locale" ) );
        -- end;

   --
   -- Switches the translations according to the given locale.
   --
   -- @since 4.7.0
   --
   -- @param string locale The locale to switch to.
   -- @return bool True on success, false on failure.
   --
   function Switch_To_Locale (This   : in out Wp_Locale_Switcher;
                              Locale : String)
                              return Boolean;

   --
   -- Restores the translations according to the previous locale.
   --
   -- @since 4.7.0
   --
   -- @return string|false Locale on success, false on failure.
   --
   function Restore_Previous_Locale (This : in out Wp_Locale_Switcher)
                                     return String;
        --         previous_locale = array_pop( this.locales );

        --         if ( null === previous_locale ) then
        --                 // The stack is empty, bail.
        --                 return false;
        --         end;

        --         locale = end( this.locales );

        --         if ( ! locale ) then
        --                 // There"s nothing left in the stack: go back to the original locale.
        --                 locale = this.original_locale;
        --         end;

        --         this.change_locale( locale );

        --         --
        --         -- Fires when the locale is restored to the previous one.
        --         --
        --         -- @since 4.7.0
        --         --
        --         -- @param string locale          The new locale.
        --         -- @param string previous_locale The previous locale.
        --         --
        --         do_action( "restore_previous_locale", locale, previous_locale );

        --         return locale;
        -- end;

        -- --
        -- -- Restores the translations according to the original locale.
        -- --
        -- -- @since 4.7.0
        -- --
        -- -- @return string|false Locale on success, false on failure.
        -- --
        -- public function restore_current_locale() then
        --         if ( empty( this.locales ) ) then
        --                 return false;
        --         end;

        --         this.locales = array( this.original_locale );

        --         return this.restore_previous_locale();
        -- end;

        -- --
        -- -- Whether switch_to_locale() is in effect.
        -- --
        -- -- @since 4.7.0
        -- --
        -- -- @return bool True if the locale has been switched, false otherwise.
        -- --
        -- public function is_switched() then
        --         return ! empty( this.locales );
        -- end;

        -- --
        -- -- Filters the locale of the WordPress installation.
        -- --
        -- -- @since 4.7.0
        -- --
        -- -- @param string locale The locale of the WordPress installation.
        -- -- @return string The locale currently being switched to.
        -- --
        -- public function filter_locale( locale ) then
        --         switched_locale = end( this.locales );

        --         if ( switched_locale ) then
        --                 return switched_locale;
        --         end;

        --         return locale;
        -- end;

   --
   -- Load translations for a given locale.
   --
   -- When switching to a locale, translations for this locale must be loaded from
   -- scratch.
   --
   -- @since 4.7.0
   --
   -- @global Mo[] l10n An array of all currently loaded text domains.
   --
   -- @param string locale The locale to load translations for.
   --
   -- private
   procedure Load_Translations (This   : Wp_Locale_Switcher;
                                Locale : String);
        --         global l10n;

        --         domains = l10n ? array_keys( l10n ) : array();

        --         load_default_textdomain( locale );

        --         foreach ( domains as domain ) then
        --                 // The default text domain is handled by `load_default_textdomain()`.
        --                 if ( "default" === domain ) then
        --                         continue;
        --                 end;

        --                 // Unload current text domain but allow them to be reloaded
        --                 // after switching back or to another locale.
        --                 unload_textdomain( domain, true );
        --                 get_translations_for_domain( domain );
        --         end;
        -- end;

   --
   -- Changes the site"s locale to the given one.
   --
   -- Loads the translations, changes the global `wp_locale` object and updates
   -- all post type labels.
   --
   -- @since 4.7.0
   --
   -- @global WP_Locale wp_locale WordPress date and time locale object.
   --
   -- @param string locale The locale to change to.
   --
   -- private
   procedure Change_Locale (This   : Wp_Locale_Switcher;
                            Locale : String);

end Class_Locale_Switchers;
