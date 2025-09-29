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

with Inc_Class_Wp_Textdomain_Registry;
with POMO_MO;

package Inc_L10n
is
   use Arrays;

   package String_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => POMO_MO.MO,
                                              "="          => POMO_MO."=");

   package String_Sets is new
      Ada.Containers.Indefinite_Ordered_Sets (Element_Type => String);

   Textdomain_Registry : Inc_Class_Wp_Textdomain_Registry.Wp_Textdomain_Registry;
   L10n                : String_Maps.Map;
   L10n_Unloaded       : String_Sets.Set;
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

   function "abs" (Item : String) return String;
   function Plural (Single : String; Plural : String; Argument : String) return String;
   function Gettext (Item : String) return String;
   function X_E (Item : String) return String is (Item & " XXX-103");
   function X_Ex (Item : String; Arg : String := "") return String is ("XXX-104");
   function X_X (Item : String; A2 : String)
                 return String
                 is (Item & " XXX-231 " & A2);
   function X_N (Single : String; Plural : String; Switch : Natural)
                return String is ("XXX-232");
   function Esc_Attr_E (Item : String) return String is (Item & "XXX-309");
   function Esc_Attr_X (Item : String) return String is (Item & "XXX-514");

   function Load_Script_Textdomain (Handle : String;
                                    Domain : String;
                                    Path   : String)
                                    return String
                                    is ("XXX-311");

   function X_N_Noop (Arg_1, Arg_2 : String)
                      return Array_Type
                      is (Empty_Array);

   function Get_User_Locale (User : Integer := 0)
                             return String
                             is ("da_DK");
   function Translate (Text   : String;
                       Domain : String := "default")
                       return String
                       is (Text);

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
            return String
            is ("XXX-704");

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

end Inc_L10n;
