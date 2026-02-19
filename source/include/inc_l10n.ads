--
-- Core Translation API
--
-- @package WordPress
-- @subpackage i18n
-- @since 1.2.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Indefinite_Ordered_Sets;

with Arrays;
with Lists;
with UStrings;

with Class_Textdomain_Registry;
with Class_Users;
with POMO_MO;
with POMO_Translations;

package Inc_L10n
is
   use Arrays;
   use Lists;

   package String_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => POMO_MO.MO,
                                              "="          => POMO_MO."=");

   -- package String_Maps is new
   --    Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
   --                                            Element_Type => POMO_Translations.Translations,
   --                                            "="          => POMO_Translations."=");

   package String_Sets is new
      Ada.Containers.Indefinite_Ordered_Sets (Element_Type => String);

   Textdomain_Registry : Class_Textdomain_Registry.Wp_Textdomain_Registry;
   L10n                : String_Maps.Map;
   L10n_Unloaded       : String_Sets.Set;

   Global_Locale           : UStrings.UString;
   Global_Wp_Local_Package : UStrings.UString;

   function Array_Keys (Map : String_Maps.Map)
                        return List_Type;

   --
   -- Retrieves the current locale.
   --
   -- If the locale is set, then it will filter the locale in the {@see "locale"}
   -- filter hook and return the value.
   --
   -- If the locale is not set already, then the WPLANG constant is used if it is
   -- defined. Then it is filtered through the {@see "locale"} filter hook and
   -- the value for the locale global set and the locale is returned.
   --
   -- The process to get the locale should only be done once, but the locale will
   -- always be filtered using the {@see "locale"} hook.
   --
   -- @since 1.5.0
   --
   -- @global string locale           The current locale.
   -- @global string wp_local_package Locale code of the package.
   --
   -- @return string The locale of the blog or from the {@see "locale"} hook.
   --
   function Get_Locale
            return String;

   --
   -- Retrieves the locale of a user.
   --
   -- If the user has a locale set to a non-empty string then it will be
   -- returned. Otherwise it returns the locale of get_locale().
   --
   -- @since 4.7.0
   --
   -- @param int|WP_User user User's ID or a WP_User object. Defaults to current user.
   -- @return string The locale of the user.
   --
   function Get_User_Locale (User : Integer := 0)
                             return String
                             is ("en_US");

   function Get_User_Locale (User : Class_Users.Wp_User)
                             return String
                             is ("en_US");

   --
   -- Determines the current locale desired for the request.
   --
   -- @since 5.0.0
   --
   -- @global string pagenow The filename of the current screen.
   --
   -- @return string The determined locale.
   --
   function Determine_Locale
            return String;

   --
   -- Retrieves the translation of text in the context defined in context.
   --
   -- If there is no translation, or the text domain isn"t loaded, the original text
   -- is returned.
   --
   -- * Note:* Don't use translate_with_gettext_context() directly, use _x() or
   -- related functions.
   --
   -- @since 2.8.0
   -- @since 5.5.0 Introduced gettext_with_context-thendomainend; filter.
   --
   -- @param string text    Text to translate.
   -- @param string context Context information for the translators.
   -- @param string domain  Optional. Text domain. Unique identifier for retrieving
   --                        translated strings. Default "default".
   -- @return string Translated text on success, original text on failure.
   --
   function Translate_With_Gettext_Context (Text    : String;
                                            Context : String;
                                            Domain  : String := "default")
                                            return String;

   --
   -- Retrieves the translation of text and escapes it for safe use in an attribute.
   --
   -- If there is no translation, or the text domain isn't loaded, the original text
   -- is returned.
   --
   -- @since 2.8.0
   --
   -- @param string text   Text to translate.
   -- @param string domain Optional. Text domain. Unique identifier for retrieving
   --                      translated strings. Default "default".
   -- @return string Translated text on success, original text on failure.
   --
   function ESC_Attr_XX (Text   : String;
                         Domain : String := "default")
                         return String;

   --
   -- Retrieves the translation of text.
   --
   -- If there is no translation, or the text domain isn't loaded, the original text
   -- is returned.
   --
   -- *Note:* Don't use translate() directly, use __() or related functions.
   --
   -- @since 2.2.0
   -- @since 5.5.0 Introduced gettext-thendomainend; filter.
   --
   -- @param string text   Text to translate.
   -- @param string domain Optional. Text domain. Unique identifier for retrieving
   --                       translated strings. Default "default".
   -- @return string Translated text.
   --
   function Translate (Text   : String;
                       Domain : String := "default")
                       return String
                       is (Text);

   --
   -- Retrieves the translation of text.
   --
   -- If there is no translation, or the text domain isn"t loaded, the original text
   -- is returned.
   --
   -- @since 2.1.0
   --
   -- @param string text   Text to translate.
   -- @param string domain Optional. Text domain. Unique identifier for retrieving
   --                       translated strings. Default "default".
   -- @return string Translated text.
   --
   function X (Text   : String;
               Domain : String := "default")
               return String
               is (Text);

   function "abs" (Item : String) return String;

   --
   -- Translates string with gettext context, and escapes it for safe use in an
   -- attribute.
   --
   -- If there is no translation, or the text domain isn"t loaded, the original text
   -- is escaped and returned.
   --
   -- @since 2.8.0
   --
   -- @param string text    Text to translate.
   -- @param string context Context information for the translators.
   -- @param string domain  Optional. Text domain. Unique identifier for retrieving
   --                        translated strings. Default "default".
   -- @return string Translated text.
   --
   function ESC_Attr_X (Text    : String;
                        Context : String;
                        Domain  : String := "default")
                        return String;

   --
   -- Displays translated text.
   --
   -- @since 1.2.0
   --
   -- @param string text   Text to translate.
   -- @param string domain Optional. Text domain. Unique identifier for retrieving
   --                       translated strings. Default "default".
   --
   procedure X_E (Text   : String;
                  Domain : String := "default");

   --
   -- Displays translated text that has been escaped for safe use in an attribute.
   --
   -- Encodes `< > & " "` (less than, greater than, ampersand, double quote, single
   -- quote). Will never double encode entities.
   --
   -- If you need the value for use in PHP, use esc_attr__().
   --
   -- @since 2.8.0
   --
   -- @param string text   Text to translate.
   -- @param string domain Optional. Text domain. Unique identifier for retrieving
   --                       translated strings. Default "default".
   --
   procedure ESC_Attr_E (Text   : String;
                         Domain : String := "default");

   --
   -- Displays translated text that has been escaped for safe use in HTML output.
   --
   -- If there is no translation, or the text domain isn"t loaded, the original text
   -- is escaped and displayed.
   --
   -- If you need the value for use in PHP, use esc_html__().
   --
   -- @since 2.8.0
   --
   -- @param string text   Text to translate.
   -- @param string domain Optional. Text domain. Unique identifier for retrieving
   --                       translated strings. Default "default".
   --
   procedure ESC_HTML_E (Text   : String;
                         Domain : String := "default");

   --
   -- Retrieves translated string with gettext context.
   --
   -- Quite a few times, there will be collisions with similar translatable text
   -- found in more than two places, but with different translated context.
   --
   -- By including the context in the pot file, translators can translate the two
   -- strings differently.
   --
   -- @since 2.8.0
   --
   -- @param string text    Text to translate.
   -- @param string context Context information for the translators.
   -- @param string domain  Optional. Text domain. Unique identifier for retrieving
   --                        translated strings. Default "default".
   -- @return string Translated context string without pipe.
   --
   function X_X (Text    : String;
                 Context : String;
                 Domain  : String := "default")
                 return String;

   --
   -- Displays translated string with gettext context.
   --
   -- @since 3.0.0
   --
   -- @param string text    Text to translate.
   -- @param string context Context information for the translators.
   -- @param string domain  Optional. Text domain. Unique identifier for retrieving
   --                        translated strings. Default "default".
   --
   procedure X_Ex (Text    : String;
                   Context : String;
                   Domain  : String := "default")
                   is null;

   --
   -- Translates and retrieves the singular or plural form based on the supplied
   -- number.
   --
   -- Used when you want to use the appropriate form of a string based on whether a
   -- number is singular or plural.
   --
   -- Example:
   --
   --     printf( _n( "%s person", "%s people", count, "text-domain" ),
   --            number_format_i18n( count ) );
   --
   -- @since 2.8.0
   -- @since 5.5.0 Introduced ngettext-{domain} filter.
   --
   -- @param string single The text to be used if the number is singular.
   -- @param string plural The text to be used if the number is plural.
   -- @param int    number The number to compare against to use either the singular
   --                       or plural form.
   -- @param string domain Optional. Text domain. Unique identifier for retrieving
   --                       translated strings. Default "default".
   -- @return string The translated singular or plural form.
   --
   function X_N (Single : String;
                 Plural : String;
                 Number : Integer;
                 Domain : String := "default")
                 return String
                 is ("XXX-232");

   --
   -- Translates and retrieves the singular or plural form based on the supplied
   -- number, with gettext context.
   --
   -- This is a hybrid of _n() and _x(). It supports context and plurals.
   --
   -- Used when you want to use the appropriate form of a string with context based
   -- on whether a number is singular or plural.
   --
   -- Example of a generic phrase which is disambiguated via the context parameter:
   --
   --     printf( _nx( "%s group", "%s groups", people, "group of people",
   --                  "text-domain" ), number_format_i18n( people ) );
   --     printf( _nx( "%s group", "%s groups", animals, "group of animals",
   --                  "text-domain" ), number_format_i18n( animals ) );
   --
   -- @since 2.8.0
   -- @since 5.5.0 Introduced ngettext_with_context-thendomainend; filter.
   --
   -- @param string single  The text to be used if the number is singular.
   -- @param string plural  The text to be used if the number is plural.
   -- @param int    number  The number to compare against to use either the singular
   --                        or plural form.
   -- @param string context Context information for the translators.
   -- @param string domain  Optional. Text domain. Unique identifier for retrieving
   --                        translated strings. Default "default".
   -- @return string The translated singular or plural form.
   --
   function X_Nx (Single  : String;
                  Plural  : String;
                  Number  : String;
                  Context : String;
                  Domain  : String := "default")
                  return String
                  is ("XXX-902");

   function X_N_Noop (Arg_1, Arg_2 : String)
                      return Array_Type
                      is (Empty_Array);

   --
   -- Registers plural strings in POT file, but does not translate them.
   --
   -- Used when you want to keep structures with translatable plural
   -- strings and use them later when the number is known.
   --
   -- Example:
   --
   --     message = _n_noop( "%s post", "%s posts", "text-domain" );
   --     ...
   --     printf( translate_nooped_plural( message, count, "text-domain" ),
   --             number_format_i18n( count ) );
   --
   -- @since 2.5.0
   --
   -- @param string singular Singular form to be localized.
   -- @param string plural   Plural form to be localized.
   -- @param string domain   Optional. Text domain. Unique identifier for retrieving
   --                         translated strings. Default null.
   -- @return array {
   --     Array of translation information for the strings.
   --
   --     @type string      0        Singular form to be localized. No longer used.
   --     @type string      1        Plural form to be localized. No longer used.
   --     @type string      singular Singular form to be localized.
   --     @type string      plural   Plural form to be localized.
   --     @type null        context  Context information for the translators.
   --     @type string|null domain   Text domain.
   -- }
   --
   function X_N_Noop (Singular : String;
                      Plural   : String;
                      Domain   : String := "default") -- null
                      return List_Type -- String_Array
                      is (Empty_List);
--                    is (Empty_String_Array);

   --
   -- Loads a .mo file into the text domain domain.
   --
   -- If the text domain already exists, the translations will be merged. If both
   -- sets have the same string, the translation from the original value will be taken.
   --
   -- On success, the .mo file will be placed in the l10n global by domain
   -- and will be a MO object.
   --
   -- @since 1.5.0
   -- @since 6.1.0 Added the `locale` parameter.
   --
   -- @global MO[]                   l10n                   An array of all currently
   --                                                       loaded text domains.
   -- @global MO[]                   l10n_unloaded          An array of all text
   --                                                       domains that have been
   --                                                       unloaded again.
   -- @global WP_Textdomain_Registry wp_textdomain_registry WordPress Textdomain
   --                                                       Registry.
   --
   -- @param string domain Text domain. Unique identifier for retrieving translated
   --                                   strings.
   -- @param string mofile Path to the .mo file.
   -- @param string locale Optional. Locale. Default is the current locale.
   -- @return bool True on success, false on failure.
   --
   procedure Load_Textdomain (Domain : String;
                              Mofile : String;
                              Locale : String := "");

   function Load_Textdomain (Domain : String;
                             Mofile : String;
                             Locale : String := "") -- null
                             return Boolean;

   --
   -- Loads plugin and theme text domains just-in-time.
   --
   -- When a textdomain is encountered for the first time, we try to load
   -- the translation file from `wp-content/languages`, removing the need
   -- to call load_plugin_textdomain() or load_theme_textdomain().
   --
   -- @since 4.6.0
   -- @access private
   --
   -- @global MO[]                   l10n_unloaded          An array of all text
   --                                                        domains that have been
   --                                                        unloaded again.
   -- @global WP_Textdomain_Registry wp_textdomain_registry WordPress Textdomain
   --                                                        Registry.
   --
   -- @param string domain Text domain. Unique identifier for retrieving translated
   --                      strings.
   -- @return bool True when the textdomain is successfully loaded, false otherwise.
   --
   function X_Load_Textdomain_Just_In_Time (Domain : String)
                                            return Boolean;

   --
   -- Returns the Translations instance for a text domain.
   --
   -- If there isn"t one, returns empty Translations instance.
   --
   -- @since 2.8.0
   --
   -- @global MO[] l10n An array of all currently loaded text domains.
   --
   -- @param string domain Text domain. Unique identifier for retrieving translated
   --                       strings.
   -- @return Translations|NOOP_Translations A Translations instance.
   --
   function Get_Translations_For_Domain (Domain : String)
                                         return POMO_Translations.Translations;

   procedure Get_Translations_For_Domain (Domain : String);

   --
   -- Gets all available languages based on the presence of *.mo files in a given
   -- directory.
   --
   -- The default directory is WP_LANG_DIR.
   --
   -- @since 3.0.0
   -- @since 4.7.0 The results are now filterable with the
   --               {@see "get_available_languages"} filter.
   --
   -- @param string dir A directory to search for language files.
   --                    Default WP_LANG_DIR.
   -- @return string[] An array of language codes or an empty array if no languages
   --                   are present. Language codes are formed by stripping the .mo
   --                   extension from the language file names.
   --
   function Get_Available_Languages (Dir : String := "") -- null
                                     return List_Type;

   --
   -- Displays or returns a Language selector.
   --
   -- @since 4.0.0
   -- @since 4.3.0 Introduced the `echo` argument.
   -- @since 4.7.0 Introduced the `show_option_site_default` argument.
   -- @since 5.1.0 Introduced the `show_option_en_us` argument.
   -- @since 5.9.0 Introduced the `explicit_option_en_us` argument.
   --
   -- @see get_available_languages()
   -- @see wp_get_available_translations()
   --
   -- @param string|array args {
   --     Optional. Array or string of arguments for outputting the language selector.
   --
   --     @type string   id                           ID attribute of the select
   --                                                 element. Default "locale".
   --     @type string   name                         Name attribute of the select
   --                                                 element. Default "locale".
   --     @type array    languages                    List of installed languages,
   --                                                 contain only the locales.
   --                                                 Default empty array.
   --     @type array    translations                 List of available translations.
   --                                                 Default result of
   --                                                 wp_get_available_translations().
   --     @type string   selected                     Language which should be
   --                                                 selected. Default empty.
   --     @type bool|int echo                         Whether to echo the generated
   --                                                 markup. Accepts 0, 1, or their
   --                                                 boolean equivalents. Default 1.
   --     @type bool     show_available_translations  Whether to show available
   --                                                 translations. Default true.
   --     @type bool     show_option_site_default     Whether to show an option to
   --                                                 fall back to the site's locale.
   --                                                 Default false.
   --     @type bool     show_option_en_us            Whether to show an option for
   --                                                 English (United States). Default
   --                                                 true.
   --     @type bool     explicit_option_en_us        Whether the English (United
   --                                                 States) option uses an explicit
   --                                                 value of en_US instead of an
   --                                                 empty value. Default false.
   -- }
   -- @return string HTML dropdown list of languages.
   --
   function Wp_Dropdown_Languages
              (Args : Array_Type := Empty_Array)
               return String;

   procedure Wp_Dropdown_Languages (Args : Array_Type);

   --
   -- Unloads translations for a text domain.
   --
   -- @since 3.0.0
   -- @since 6.1.0 Added the `reloadable` parameter.
   --
   -- @global MO[] l10n          An array of all currently loaded text domains.
   -- @global MO[] l10n_unloaded An array of all text domains that have been unloaded
   --                            again.
   --
   -- @param string domain     Text domain. Unique identifier for retrieving
   --                          translated strings.
   -- @param bool   reloadable Whether the text domain can be loaded just-in-time
   --                          again.
   -- @return bool Whether textdomain was unloaded.
   --
   procedure Unload_Textdomain (Domain     : String;
                                Reloadable : Boolean := False);

   function Unload_Textdomain (Domain     : String;
                               Reloadable : Boolean := False)
                               return Boolean;

   --
   -- Loads default translated strings based on locale.
   --
   -- Loads the .mo file in WP_LANG_DIR constant path from WordPress root.
   -- The translated (.mo) file is named based on the locale.
   --
   -- @see load_textdomain()
   --
   -- @since 1.5.0
   --
   -- @param string locale Optional. Locale to load. Default is the value of
   --                      get_locale().
   -- @return bool Whether the textdomain was loaded.
   --
   function Load_Default_Textdomain (Locale : String := "") -- null
                                     return Boolean;
   procedure Load_Default_Textdomain (Locale : String := ""); -- null

   --
   -- Loads the script translated strings.
   --
   -- @since 5.0.0
   -- @since 5.0.2 Uses load_script_translations() to load translation data.
   -- @since 5.1.0 The `domain` parameter was made optional.
   --
   -- @see WP_Scripts::set_translations()
   --
   -- @param string handle Name of the script to register a translation domain to.
   -- @param string domain Optional. Text domain. Default "default".
   -- @param string path   Optional. The full file path to the directory containing
   --                       translation files.
   -- @return string|false The translated strings in JSON encoding on success,
   --                      false if the script textdomain could not be loaded.
   --
   function Load_Script_Textdomain (Handle : String;
                                    Domain : String;
                                    Path   : String)
                                    return String
                                    is ("XXX-311");

   --
   -- Determines whether the current locale is right-to-left (RTL).
   --
   -- For more information on this and similar theme functions, check out
   -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
   -- Conditional Tags} article in the Theme Developer Handbook.
   --
   -- @since 3.0.0
   --
   -- @global WP_Locale wp_locale WordPress date and time locale object.
   --
   -- @return bool Whether locale is RTL.
   --
   function Is_RTL
            return Boolean
            is (False);

   --
   -- Switches the translations according to the given locale.
   --
   -- @since 4.7.0
   --
   -- @global WP_Locale_Switcher wp_locale_switcher WordPress locale switcher object.
   --
   -- @param string locale The locale.
   -- @return bool True on success, false on failure.
   --
   function Switch_To_Locale (Locale : String)
                              return Boolean;

   --
   -- Restores the translations according to the previous locale.
   --
   -- @since 4.7.0
   --
   -- @global WP_Locale_Switcher wp_locale_switcher WordPress locale switcher object.
   --
   -- @return string|false Locale on success, false on error.
   --
   function Restore_Previous_Locale
            return String;

   procedure Restore_Previous_Locale;

   --
   -- Translates the provided settings value using its i18n schema.
   --
   -- @since 5.9.0
   -- @access private
   --
   -- @param string|string[]|array[]|object i18n_schema I18n schema for the setting.
   -- @param string|string[]|array[]        settings    Value for the settings.
   -- @param string                         textdomain  Textdomain to use with
   --                                                   translations.
   --
   -- @return string|string[]|array[] Translated settings.
   --
   function Translate_Settings_Using_I18n_Schema (I18n_Schema : String; -- Array_Type;
                                                  Settings    : Array_Type;
                                                  Textdomain  : String)
                                                  return Array_Type;

end Inc_L10n;
