--
-- Core Translation API
--
-- @package WordPress
-- @subpackage i18n
-- @since 1.2.0
--

with Php.Arrays;
with Php.Echoing;
with Php.Files;
with Php.Strings;
with Php.Types;

with Array_Vectors;
with Binder;
with Constants;
with Globals;
with Wp_Common;

with Adi_Translation_Install;
with Class_Locale_Switchers;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_Plugins;
with Inc_Load;
with Inc_Options;
with Inc_Themes;

package body Inc_L10n is

   Global_Wp_Locale_Switcher : Class_Locale_Switchers.Wp_Locale_Switcher;

   function "abs" (Item : String) return String is (Item);

   ----------------
   -- Array_Keys --
   ----------------

   function Array_Keys (Map : String_Maps.Map)
                        return List_Type
   is
      List : List_Type;
   begin
      for A in Map.Iterate loop
         List.Append (String_Maps.Key (A));
      end loop;
      return List;
   end Array_Keys;

   ----------------
   -- Get_Locale --
   ----------------

   function Get_Locale
            return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Load;
      use Inc_Options;
      use Inc_Plugins;
--    global locale, wp_local_package;
   begin
      if Global_Locale /= "" then
--    if Isset (Global_Locale) then
         -- This filter is documented in wp-includes/l10n.php
         return Apply_Filters ("locale", -Global_Locale);
      end if;

      if Global_Wp_Local_Package /= "" then
--    if Isset (Global_Wp_Local_Package) then
         Global_Locale := Global_Wp_Local_Package;
      end if;

      -- WPLANG was defined in wp-config.
      if Constants.WPLANG /= "" then
         Global_Locale := +Constants.WPLANG;
      end if;

      -- If multisite, check options.
      if Is_Multisite then
         declare
            MS_Locale : UString;
         begin
            -- Don't check blog option when installing.
            if Wp_Installing then
               MS_Locale := +As_String (Get_Site_Option ("WPLANG"));
            else
               MS_Locale := +Get_Option ("WPLANG");
               if "" = MS_Locale then
--             if False = MS_Locale then
                  MS_Locale := +As_String (Get_Site_Option ("WPLANG"));
               end if;
            end if;

            if "" /= MS_Locale then
--          if False /= MS_Locale then
               Global_Locale := MS_Locale;
            end if;
         end;
      else
         declare
            DB_Locale : constant String := Get_Option ("WPLANG");
         begin
            if "" /= DB_Locale then
--          if False /= DB_Locale then
               Global_Locale := +DB_Locale;
            end if;
         end;
      end if;

      if Empty (-Global_Locale) then
         Global_Locale := +"en_US";
      end if;

      --
      -- Filters the locale ID of the WordPress installation.
      --
      -- @since 1.5.0
      --
      -- @param string locale The locale ID.
      --
      return Apply_Filters ("locale", -Global_Locale);
   end Get_Locale;

-- --
-- -- Retrieves the locale of a user.
-- --
-- -- If the user has a locale set to a non-empty string then it will be
-- -- returned. Otherwise it returns the locale of get_locale().
-- --
-- -- @since 4.7.0
-- --
-- -- @param int|WP_User user User"s ID or a WP_User object. Defaults to current user.
-- -- @return string The locale of the user.
-- --
-- function get_user_locale( user = 0 ) then
--         user_object = false;

--         if ( 0 === user && function_exists( "wp_get_current_user" ) ) then
--                 user_object = wp_get_current_user();
--         end; elseif ( user instanceof WP_User ) then
--                 user_object = user;
--         end; elseif ( user && is_numeric( user ) ) then
--                 user_object = get_user_by( "id", user );
--         end;

--         if ( ! user_object ) then
--                 return get_locale();
--         end;

--         locale = user_object.locale;

--         return locale ? locale : get_locale();
-- end;

   ----------------------
   -- Determine_Locale --
   ----------------------

   function Determine_Locale
            return String
   is
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Load;
      use Inc_Plugins;

      --
      -- Filters the locale for the current request prior to the default determination
      -- process.
      --
      -- Using this filter allows to override the default logic, effectively
      -- short-circuiting the function.
      --
      -- @since 5.0.0
      --
      -- @param string|null locale The locale to return and short-circuit. Default
      --                    null.
      --
      Determined_Locale : constant String :=
        Apply_Filters ("pre_determine_locale", ""); -- null
   begin
      if
        not Empty (Determined_Locale) and then
        Php.Types.Is_String (Determined_Locale)
      then
         return Determined_Locale;
      end if;

      declare
         Determined_Locale_2 : constant String :=
           (if Is_Admin then Get_User_Locale
            else             Get_Locale);

         Determined_Locale_3 : UString := +Determined_Locale_2;
      begin
         if
           Isset (XX_GET, "_locale") and then
           "user" = As_String (Get (XX_GET, "_locale")) and then
           Wp_Is_JSON_Request
         then
            Determined_Locale_3 := +Get_User_Locale;
         end if;

         declare
            Wp_Lang : constant String :=
              (if Isset (XX_GET, "wp_lang")  -- not Empty (XX_GET, "wp_lang")
                 then Sanitize_Locale_Name
                        (Wp_Unslash (Get_As_String (XX_GET, "wp_lang")))
               elsif Isset (X_COOKIE, "wp_lang") -- not Empty (X_COOKIE, "wp_lang")
                 then Sanitize_Locale_Name
                        (Wp_Unslash (Get_As_String (X_COOKIE, "wp_lang")))
               else "");
         begin
            if
              not Empty (Wp_Lang) and then
              not Empty (Globals.GLOBALS, "pagenow") and then
              "wp-login.php" = As_String (Get (Globals.GLOBALS, "pagenow"))
            then
               Determined_Locale_3 := +Wp_Lang;
            end if;
         end;

         --
         -- Filters the locale for the current request.
         --
         -- @since 5.0.0
         --
         -- @param string locale The locale.
         --
         return Apply_Filters ("determine_locale", -Determined_Locale_3);
      end;
   end Determine_Locale;

-- --
-- -- Retrieves the translation of text.
-- --
-- -- If there is no translation, or the text domain isn"t loaded, the original text is returned.
-- --
-- ----Note:* Don"t use translate() directly, use __() or related functions.
-- --
-- -- @since 2.2.0
-- -- @since 5.5.0 Introduced gettext-thendomainend; filter.
-- --
-- -- @param string text   Text to translate.
-- -- @param string domain Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                       Default "default".
-- -- @return string Translated text.
-- --
-- function translate( text, domain = "default" ) then
--         translations = get_translations_for_domain( domain );
--         translation  = translations.translate( text );

--         --
--         -- Filters text with its translation.
--         --
--         -- @since 2.0.11
--         --
--         -- @param string translation Translated text.
--         -- @param string text        Text to translate.
--         -- @param string domain      Text domain. Unique identifier for retrieving translated strings.
--         --
--         translation = apply_filters( "gettext", translation, text, domain );

--         --
--         -- Filters text with its translation for a domain.
--         --
--         -- The dynamic portion of the hook name, `domain`, refers to the text domain.
--         --
--         -- @since 5.5.0
--         --
--         -- @param string translation Translated text.
--         -- @param string text        Text to translate.
--         -- @param string domain      Text domain. Unique identifier for retrieving translated strings.
--         --
--         translation = apply_filters( "gettext_thendomainend;", translation, text, domain );

--         return translation;
-- end;

-- --
-- -- Removes last item on a pipe-delimited string.
-- --
-- -- Meant for removing the last item in a string, such as "Role name|User role". The original
-- -- string will be returned if no pipe "|" characters are found in the string.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string string A pipe-delimited string.
-- -- @return string Either string or everything before the last pipe.
-- --
-- function before_last_bar( string ) then
--         last_bar = strrpos( string, "|" );
--         if ( false === last_bar ) then
--                 return string;
--         end; else then
--                 return substr( string, 0, last_bar );
--         end;
-- end;

   ------------------------------------
   -- Translate_With_Gettext_Context --
   ------------------------------------

   function Translate_With_Gettext_Context (Text    : String;
                                            Context : String;
                                            Domain  : String := "default")
                                            return String
   is
      use Wp_Common;
--    use Inc_Plugins;
      use POMO_Translations;

      Trans         : constant Translations := Get_Translations_For_Domain (Domain);
      Translation_3 : constant String       := Trans.Translate (Text, Context);

      --
      -- Filters text with its translation based on context information.
      --
      -- @since 2.8.0
      --
      -- @param string translation Translated text.
      -- @param string text        Text to translate.
      -- @param string context     Context information for the translators.
      -- @param string domain      Text domain. Unique identifier for retrieving
      --                            translated strings.
      --
      Translation_2 : constant String :=
        Apply_Filters ("gettext_with_context", Translation_3, Text, Context, Domain);

      --
      -- Filters text with its translation based on context information for a domain.
      --
      -- The dynamic portion of the hook name, `domain`, refers to the text domain.
      --
      -- @since 5.5.0
      --
      -- @param string translation Translated text.
      -- @param string text        Text to translate.
      -- @param string context     Context information for the translators.
      -- @param string domain      Text domain. Unique identifier for retrieving
      --                            translated strings.
      --
      Translation : constant String :=
        Apply_Filters ("gettext_with_context_" & Domain,
                       Translation_2, Text, Context, Domain);

   begin
      return Translation;
   end Translate_With_Gettext_Context;

-- --
-- -- Retrieves the translation of text.
-- --
-- -- If there is no translation, or the text domain isn"t loaded, the original text is returned.
-- --
-- -- @since 2.1.0
-- --
-- -- @param string text   Text to translate.
-- -- @param string domain Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                       Default "default".
-- -- @return string Translated text.
-- --
-- function __( text, domain = "default" ) then
--         return translate( text, domain );
-- end;

   -----------------
   -- ESC_Attr_XX --
   -----------------

   function ESC_Attr_XX (Text   : String;
                         Domain : String := "default")
                         return String
   is
      use Inc_Formatting;
   begin
      return ESC_Attr (Translate (Text, Domain));
   end ESC_Attr_XX;

-- --
-- -- Retrieves the translation of text and escapes it for safe use in HTML output.
-- --
-- -- If there is no translation, or the text domain isn"t loaded, the original text
-- -- is escaped and returned.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string text   Text to translate.
-- -- @param string domain Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                       Default "default".
-- -- @return string Translated text.
-- --
-- function esc_html__( text, domain = "default" ) then
--         return esc_html( translate( text, domain ) );
-- end;

   ---------
   -- X_E --
   ---------

   procedure X_E (Text   : String;
                  Domain : String := "default")
   is
      use Php.Echoing;
   begin
      Echo (Translate (Text, Domain));
   end X_E;

   ----------------
   -- Esc_Attr_E --
   ----------------

   procedure ESC_Attr_E (Text   : String;
                         Domain : String := "default")
   is
      use Php.Echoing;
      use Inc_Formatting;
   begin
      Echo (ESC_Attr (Translate (Text, Domain)));
   end ESC_Attr_E;

   ----------------
   -- ESC_HTML_E --
   ----------------

   procedure ESC_HTML_E (Text   : String;
                         Domain : String := "default")
   is
      use Php.Echoing;
      use Inc_Formatting;
   begin
      Echo (ESC_HTML (Translate (Text, Domain)));
   end ESC_HTML_E;

   ---------
   -- X_X --
   ---------

   function X_X (Text    : String;
                 Context : String;
                 Domain  : String := "default")
                 return String
   is
   begin
      return Translate_With_Gettext_Context (Text, Context, Domain);
   end X_X;

-- --
-- -- Displays translated string with gettext context.
-- --
-- -- @since 3.0.0
-- --
-- -- @param string text    Text to translate.
-- -- @param string context Context information for the translators.
-- -- @param string domain  Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                        Default "default".
-- --
-- function _ex( text, context, domain = "default" ) then
--         echo _x( text, context, domain );
-- end;

   ----------------
   -- ESC_Attr_X --
   ----------------

   function ESC_Attr_X (Text    : String;
                        Context : String;
                        Domain  : String := "default")
                        return String
   is
      use Inc_Formatting;
   begin
      return ESC_Attr (Translate_With_Gettext_Context (Text, Context, Domain));
   end ESC_Attr_X;

-- --
-- -- Translates string with gettext context, and escapes it for safe use in HTML output.
-- --
-- -- If there is no translation, or the text domain isn"t loaded, the original text
-- -- is escaped and returned.
-- --
-- -- @since 2.9.0
-- --
-- -- @param string text    Text to translate.
-- -- @param string context Context information for the translators.
-- -- @param string domain  Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                        Default "default".
-- -- @return string Translated text.
-- --
-- function esc_html_x( text, context, domain = "default" ) then
--         return esc_html( translate_with_gettext_context( text, context, domain ) );
-- end;

-- --
-- -- Translates and retrieves the singular or plural form based on the supplied number.
-- --
-- -- Used when you want to use the appropriate form of a string based on whether a
-- -- number is singular or plural.
-- --
-- -- Example:
-- --
-- --     printf( _n( "%s person", "%s people", count, "text-domain" ), number_format_i18n( count ) );
-- --
-- -- @since 2.8.0
-- -- @since 5.5.0 Introduced ngettext-thendomainend; filter.
-- --
-- -- @param string single The text to be used if the number is singular.
-- -- @param string plural The text to be used if the number is plural.
-- -- @param int    number The number to compare against to use either the singular or plural form.
-- -- @param string domain Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                       Default "default".
-- -- @return string The translated singular or plural form.
-- --
-- function _n( single, plural, number, domain = "default" ) then
--         translations = get_translations_for_domain( domain );
--         translation  = translations.translate_plural( single, plural, number );

--         --
--         -- Filters the singular or plural form of a string.
--         --
--         -- @since 2.2.0
--         --
--         -- @param string translation Translated text.
--         -- @param string single      The text to be used if the number is singular.
--         -- @param string plural      The text to be used if the number is plural.
--         -- @param int    number      The number to compare against to use either the singular or plural form.
--         -- @param string domain      Text domain. Unique identifier for retrieving translated strings.
--         --
--         translation = apply_filters( "ngettext", translation, single, plural, number, domain );

--         --
--         -- Filters the singular or plural form of a string for a domain.
--         --
--         -- The dynamic portion of the hook name, `domain`, refers to the text domain.
--         --
--         -- @since 5.5.0
--         --
--         -- @param string translation Translated text.
--         -- @param string single      The text to be used if the number is singular.
--         -- @param string plural      The text to be used if the number is plural.
--         -- @param int    number      The number to compare against to use either the singular or plural form.
--         -- @param string domain      Text domain. Unique identifier for retrieving translated strings.
--         --
--         translation = apply_filters( "ngettext_thendomainend;", translation, single, plural, number, domain );

--         return translation;
-- end;

-- --
-- -- Translates and retrieves the singular or plural form based on the supplied number, with gettext context.
-- --
-- -- This is a hybrid of _n() and _x(). It supports context and plurals.
-- --
-- -- Used when you want to use the appropriate form of a string with context based on whether a
-- -- number is singular or plural.
-- --
-- -- Example of a generic phrase which is disambiguated via the context parameter:
-- --
-- --     printf( _nx( "%s group", "%s groups", people, "group of people", "text-domain" ), number_format_i18n( people ) );
-- --     printf( _nx( "%s group", "%s groups", animals, "group of animals", "text-domain" ), number_format_i18n( animals ) );
-- --
-- -- @since 2.8.0
-- -- @since 5.5.0 Introduced ngettext_with_context-thendomainend; filter.
-- --
-- -- @param string single  The text to be used if the number is singular.
-- -- @param string plural  The text to be used if the number is plural.
-- -- @param int    number  The number to compare against to use either the singular or plural form.
-- -- @param string context Context information for the translators.
-- -- @param string domain  Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                        Default "default".
-- -- @return string The translated singular or plural form.
-- --
-- function _nx( single, plural, number, context, domain = "default" ) then
--         translations = get_translations_for_domain( domain );
--         translation  = translations.translate_plural( single, plural, number, context );

--         --
--         -- Filters the singular or plural form of a string with gettext context.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string translation Translated text.
--         -- @param string single      The text to be used if the number is singular.
--         -- @param string plural      The text to be used if the number is plural.
--         -- @param int    number      The number to compare against to use either the singular or plural form.
--         -- @param string context     Context information for the translators.
--         -- @param string domain      Text domain. Unique identifier for retrieving translated strings.
--         --
--         translation = apply_filters( "ngettext_with_context", translation, single, plural, number, context, domain );

--         --
--         -- Filters the singular or plural form of a string with gettext context for a domain.
--         --
--         -- The dynamic portion of the hook name, `domain`, refers to the text domain.
--         --
--         -- @since 5.5.0
--         --
--         -- @param string translation Translated text.
--         -- @param string single      The text to be used if the number is singular.
--         -- @param string plural      The text to be used if the number is plural.
--         -- @param int    number      The number to compare against to use either the singular or plural form.
--         -- @param string context     Context information for the translators.
--         -- @param string domain      Text domain. Unique identifier for retrieving translated strings.
--         --
--         translation = apply_filters( "ngettext_with_context_thendomainend;", translation, single, plural, number, context, domain );

--         return translation;
-- end;

-- --
-- -- Registers plural strings in POT file, but does not translate them.
-- --
-- -- Used when you want to keep structures with translatable plural
-- -- strings and use them later when the number is known.
-- --
-- -- Example:
-- --
-- --     message = _n_noop( "%s post", "%s posts", "text-domain" );
-- --     ...
-- --     printf( translate_nooped_plural( message, count, "text-domain" ), number_format_i18n( count ) );
-- --
-- -- @since 2.5.0
-- --
-- -- @param string singular Singular form to be localized.
-- -- @param string plural   Plural form to be localized.
-- -- @param string domain   Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                         Default null.
-- -- @return array then
-- --     Array of translation information for the strings.
-- --
-- --     @type string      0        Singular form to be localized. No longer used.
-- --     @type string      1        Plural form to be localized. No longer used.
-- --     @type string      singular Singular form to be localized.
-- --     @type string      plural   Plural form to be localized.
-- --     @type null        context  Context information for the translators.
-- --     @type string|null domain   Text domain.
-- -- end;
-- --
-- function _n_noop( singular, plural, domain = null ) then
--         return array(
--                 0          => singular,
--                 1          => plural,
--                 "singular" => singular,
--                 "plural"   => plural,
--                 "context"  => null,
--                 "domain"   => domain,
--         );
-- end;

-- --
-- -- Registers plural strings with gettext context in POT file, but does not translate them.
-- --
-- -- Used when you want to keep structures with translatable plural
-- -- strings and use them later when the number is known.
-- --
-- -- Example of a generic phrase which is disambiguated via the context parameter:
-- --
-- --     messages = array(
-- --          "people"  => _nx_noop( "%s group", "%s groups", "people", "text-domain" ),
-- --          "animals" => _nx_noop( "%s group", "%s groups", "animals", "text-domain" ),
-- --     );
-- --     ...
-- --     message = messages[ type ];
-- --     printf( translate_nooped_plural( message, count, "text-domain" ), number_format_i18n( count ) );
-- --
-- -- @since 2.8.0
-- --
-- -- @param string singular Singular form to be localized.
-- -- @param string plural   Plural form to be localized.
-- -- @param string context  Context information for the translators.
-- -- @param string domain   Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                         Default null.
-- -- @return array then
-- --     Array of translation information for the strings.
-- --
-- --     @type string      0        Singular form to be localized. No longer used.
-- --     @type string      1        Plural form to be localized. No longer used.
-- --     @type string      2        Context information for the translators. No longer used.
-- --     @type string      singular Singular form to be localized.
-- --     @type string      plural   Plural form to be localized.
-- --     @type string      context  Context information for the translators.
-- --     @type string|null domain   Text domain.
-- -- end;
-- --
-- function _nx_noop( singular, plural, context, domain = null ) then
--         return array(
--                 0          => singular,
--                 1          => plural,
--                 2          => context,
--                 "singular" => singular,
--                 "plural"   => plural,
--                 "context"  => context,
--                 "domain"   => domain,
--         );
-- end;

-- --
-- -- Translates and returns the singular or plural form of a string that"s been registered
-- -- with _n_noop() or _nx_noop().
-- --
-- -- Used when you want to use a translatable plural string once the number is known.
-- --
-- -- Example:
-- --
-- --     message = _n_noop( "%s post", "%s posts", "text-domain" );
-- --     ...
-- --     printf( translate_nooped_plural( message, count, "text-domain" ), number_format_i18n( count ) );
-- --
-- -- @since 3.1.0
-- --
-- -- @param array  nooped_plural then
-- --     Array that is usually a return value from _n_noop() or _nx_noop().
-- --
-- --     @type string      singular Singular form to be localized.
-- --     @type string      plural   Plural form to be localized.
-- --     @type string|null context  Context information for the translators.
-- --     @type string|null domain   Text domain.
-- -- end;
-- -- @param int    count         Number of objects.
-- -- @param string domain        Optional. Text domain. Unique identifier for retrieving translated strings. If nooped_plural contains
-- --                              a text domain passed to _n_noop() or _nx_noop(), it will override this value. Default "default".
-- -- @return string Either singular or plural translated text.
-- --
-- function translate_nooped_plural( nooped_plural, count, domain = "default" ) then
--         if ( nooped_plural["domain"] ) then
--                 domain = nooped_plural["domain"];
--         end;

--         if ( nooped_plural["context"] ) then
--                 return _nx( nooped_plural["singular"], nooped_plural["plural"], count, nooped_plural["context"], domain );
--         end; else then
--                 return _n( nooped_plural["singular"], nooped_plural["plural"], count, domain );
--         end;
-- end;

   ---------------------
   -- Load_Textdomain --
   ---------------------

   procedure Load_Textdomain (Domain : String;
                              Mofile : String;
                              Locale : String := "")
   is
      Unused : constant Boolean :=
        Load_Textdomain (Domain, Mofile, Locale);
   begin
      null;
   end Load_Textdomain;

   function Load_Textdomain (Domain : String;
                             Mofile : String;
                             Locale : String := "") -- null
                             return Boolean
   is
      use Php.Files;
      use UStrings;
      use Wp_Common;
      use Inc_Plugins;

-- @var WP_Textdomain_Registry wp_textdomain_registry
--    global (l10n, l10n_unloaded, Wp_Textdomain_Registry);
      Mofile_2        : UString;
      Plugin_Override : Boolean;
      Locale_2        : UString := +Locale;
   begin
--    l10n_unloaded := (array) l10n_unloaded;

      --
      -- Filters whether to override the .mo file loading.
      --
      -- @since 2.9.0
      --
      -- @param bool   override Whether to override the .mo file loading. Default
      --                        false.
      -- @param string domain   Text domain. Unique identifier for retrieving
      --                        translated strings.
      -- @param string mofile   Path to the MO file.
      --
      Plugin_Override := Apply_Filters ("override_load_textdomain",
                                        False, Domain, Mofile);

      if Plugin_Override then
         L10n_Unloaded.Delete (Domain);
--       unset( l10n_unloaded[ domain ] );

         return True;
      end if;

      --
      -- Fires before the MO translation file is loaded.
      --
      -- @since 2.9.0
      --
      -- @param string domain Text domain. Unique identifier for retrieving
      --                      translated strings.
      -- @param string mofile Path to the .mo file.
      --
      Do_Action ("load_textdomain", Domain, Mofile);

      --
      -- Filters MO file path for loading translations for a specific text domain.
      --
      -- @since 2.9.0
      --
      -- @param string mofile Path to the MO file.
      -- @param string domain Text domain. Unique identifier for retrieving
      --                      translated strings.
      --
      Mofile_2 := +Apply_Filters ("load_textdomain_mofile", Mofile, Domain);

      if not Is_Readable (-Mofile_2) then
         return False;
      end if;

      if Locale = "" then
         Locale_2 := +Determine_Locale; -- ()
      end if;

      declare
         MO : POMO_MO.MO; -- = new MO();
      begin
         if not MO.Import_From_File (-Mofile_2) then
            Textdomain_Registry.Set (Domain, -Locale_2, "false"); -- False

            return False;
         end if;

--       if Isset (L10n (Domain)) then
            MO.Merge_With (L10n (Domain));
--       end if;

--       Unset (L10n_Unloaded (Domain));

         L10n (Domain) := MO; -- &mo;
      end;

      Textdomain_Registry.Set (Domain, -Locale_2, Php.Files.Dirname (-Mofile_2));

      return True;
   end Load_Textdomain;

   -----------------------
   -- Unload_Textdomain --
   -----------------------

   procedure Unload_Textdomain (Domain     : String;
                                Reloadable : Boolean := False)
   is
      Unused : constant Boolean :=
        Unload_Textdomain (Domain, Reloadable);
   begin
      null;
   end Unload_Textdomain;

   -----------------------
   -- Unload_Textdomain --
   -----------------------

   function Unload_Textdomain (Domain     : String;
                               Reloadable : Boolean := False)
                               return Boolean
   is
--    use UStrings;
      use Wp_Common;
      use Inc_Plugins;

--         global l10n, l10n_unloaded;
      Plugin_Override : Boolean;
   begin
--    l10n_unloaded := (array) l10n_unloaded;

      --
      -- Filters whether to override the text domain unloading.
      --
      -- @since 3.0.0
      -- @since 6.1.0 Added the `reloadable` parameter.
      --
      -- @param bool   override   Whether to override the text domain unloading.
      --                          Default false.
      -- @param string domain     Text domain. Unique identifier for retrieving
      --                          translated strings.
      -- @param bool   reloadable Whether the text domain can be loaded just-in-time
      --                          again.
      --
      Plugin_Override := Apply_Filters ("override_unload_textdomain",
                                        False, Domain, Reloadable);

      if Plugin_Override then
         if not Reloadable then
            L10n_Unloaded.Include (Domain); --  := True;
         end if;

         return True;
      end if;

      --
      -- Fires before the text domain is unloaded.
      --
      -- @since 3.0.0
      -- @since 6.1.0 Added the `reloadable` parameter.
      --
      -- @param string domain     Text domain. Unique identifier for retrieving
      --                          translated strings.
      -- @param bool   reloadable Whether the text domain can be loaded just-in-time
      --                          again.
      --
      Do_Action ("unload_textdomain", Domain, Reloadable);

      if L10n.Contains (Domain) then
--    if Isset (L10n (Domain)) then
         L10n.Delete (Domain);
--       Unset (L10n (Domain));

         if not Reloadable then
            L10n_Unloaded.Include (Domain); -- := True;
         end if;

         return True;
      end if;

      return False;
   end Unload_Textdomain;

-- --
-- -- Loads default translated strings based on locale.
-- --
-- -- Loads the .mo file in WP_LANG_DIR constant path from WordPress root.
-- -- The translated (.mo) file is named based on the locale.
-- --
-- -- @see load_textdomain()
-- --
-- -- @since 1.5.0
-- --
-- -- @param string locale Optional. Locale to load. Default is the value of get_locale().
-- -- @return bool Whether the textdomain was loaded.
-- --
-- function load_default_textdomain( locale = null ) then
   function Load_Default_Textdomain (Locale : String := "") -- null
                                     return Boolean
   is
      use Constants;
      use Globals;
      use Inc_Load;

      Locale_2 : constant String := (if Locale = ""
                                     then Determine_Locale
                                     else Locale);
   begin
      -- Unload previously loaded strings so we can switch translations.
      Unload_Textdomain ("default");

      declare
         Retur : constant Boolean :=
           Load_Textdomain ("default", WP_LANG_DIR & "/locale.mo", Locale_2);
      begin
         if
           (Is_Multisite or else
            WP_INSTALLING_NETWORK) and then
            not Php.Files.File_Exists (WP_LANG_DIR & "/admin-locale.mo")
         then
            Load_Textdomain ("default",
                             WP_LANG_DIR & "/ms-locale.mo", Locale_2);
            return Retur;
         end if;

         if
           Is_Admin              or else
           Globals.WP_INSTALLING or else
           WP_REPAIRING
         then
            Load_Textdomain ("default",
                             WP_LANG_DIR & "/admin-locale.mo", Locale_2);
         end if;

         if
           Is_Network_Admin or else
           WP_INSTALLING_NETWORK
         then
            Load_Textdomain ("default",
                             WP_LANG_DIR & "/admin-network-locale.mo", Locale_2);
         end if;

         return Retur;
      end;
   end Load_Default_Textdomain;

   procedure Load_Default_Textdomain (Locale : String := "")
   is
      Unused : constant Boolean := Load_Default_Textdomain (Locale);
   begin
      null;
   end Load_Default_Textdomain;

-- --
-- -- Loads a plugin"s translated strings.
-- --
-- -- If the path is not given then it will be the root of the plugin directory.
-- --
-- -- The .mo file should be named based on the text domain with a dash, and then the locale exactly.
-- --
-- -- @since 1.5.0
-- -- @since 4.6.0 The function now tries to load the .mo file from the languages directory first.
-- --
-- -- @param string       domain          Unique identifier for retrieving translated strings
-- -- @param string|false deprecated      Optional. Deprecated. Use the plugin_rel_path parameter instead.
-- --                                      Default false.
-- -- @param string|false plugin_rel_path Optional. Relative path to WP_PLUGIN_DIR where the .mo file resides.
-- --                                      Default false.
-- -- @return bool True when textdomain is successfully loaded, false otherwise.
-- --
-- function load_plugin_textdomain( domain, deprecated = false, plugin_rel_path = false ) then
--         -- @var WP_Textdomain_Registry wp_textdomain_registry--
--         global wp_textdomain_registry;

--         --
--         -- Filters a plugin"s locale.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string locale The plugin"s current locale.
--         -- @param string domain Text domain. Unique identifier for retrieving translated strings.
--         --
--         locale = apply_filters( "plugin_locale", determine_locale(), domain );

--         mofile = domain . "-" . locale . ".mo";

--         // Try to load from the languages directory first.
--         if ( load_textdomain( domain, WP_LANG_DIR . "/plugins/" . mofile, locale ) ) then
--                 return true;
--         end;

--         if ( false !== plugin_rel_path ) then
--                 path = WP_PLUGIN_DIR . "/" . trim( plugin_rel_path, "/" );
--         end; elseif ( false !== deprecated ) then
--                 _deprecated_argument( __FUNCTION__, "2.7.0" );
--                 path = ABSPATH . trim( deprecated, "/" );
--         end; else then
--                 path = WP_PLUGIN_DIR;
--         end;

--         wp_textdomain_registry.set_custom_path( domain, path );

--         return load_textdomain( domain, path . "/" . mofile, locale );
-- end;

-- --
-- -- Loads the translated strings for a plugin residing in the mu-plugins directory.
-- --
-- -- @since 3.0.0
-- -- @since 4.6.0 The function now tries to load the .mo file from the languages directory first.
-- --
-- -- @global WP_Textdomain_Registry wp_textdomain_registry WordPress Textdomain Registry.
-- --
-- -- @param string domain             Text domain. Unique identifier for retrieving translated strings.
-- -- @param string mu_plugin_rel_path Optional. Relative to `WPMU_PLUGIN_DIR` directory in which the .mo
-- --                                   file resides. Default empty string.
-- -- @return bool True when textdomain is successfully loaded, false otherwise.
-- --
-- function load_muplugin_textdomain( domain, mu_plugin_rel_path = "" ) then
--         -- @var WP_Textdomain_Registry wp_textdomain_registry--
--         global wp_textdomain_registry;

--         -- This filter is documented in wp-includes/l10n.php--
--         locale = apply_filters( "plugin_locale", determine_locale(), domain );

--         mofile = domain . "-" . locale . ".mo";

--         // Try to load from the languages directory first.
--         if ( load_textdomain( domain, WP_LANG_DIR . "/plugins/" . mofile, locale ) ) then
--                 return true;
--         end;

--         path = WPMU_PLUGIN_DIR . "/" . ltrim( mu_plugin_rel_path, "/" );

--         wp_textdomain_registry.set_custom_path( domain, path );

--         return load_textdomain( domain, path . "/" . mofile, locale );
-- end;

-- --
-- -- Loads the theme"s translated strings.
-- --
-- -- If the current locale exists as a .mo file in the theme"s root directory, it
-- -- will be included in the translated strings by the domain.
-- --
-- -- The .mo files must be named based on the locale exactly.
-- --
-- -- @since 1.5.0
-- -- @since 4.6.0 The function now tries to load the .mo file from the languages directory first.
-- --
-- -- @global WP_Textdomain_Registry wp_textdomain_registry WordPress Textdomain Registry.
-- --
-- -- @param string       domain Text domain. Unique identifier for retrieving translated strings.
-- -- @param string|false path   Optional. Path to the directory containing the .mo file.
-- --                             Default false.
-- -- @return bool True when textdomain is successfully loaded, false otherwise.
-- --
-- function load_theme_textdomain( domain, path = false ) then
--         -- @var WP_Textdomain_Registry wp_textdomain_registry--
--         global wp_textdomain_registry;

--         --
--         -- Filters a theme"s locale.
--         --
--         -- @since 3.0.0
--         --
--         -- @param string locale The theme"s current locale.
--         -- @param string domain Text domain. Unique identifier for retrieving translated strings.
--         --
--         locale = apply_filters( "theme_locale", determine_locale(), domain );

--         mofile = domain . "-" . locale . ".mo";

--         // Try to load from the languages directory first.
--         if ( load_textdomain( domain, WP_LANG_DIR . "/themes/" . mofile, locale ) ) then
--                 return true;
--         end;

--         if ( ! path ) then
--                 path = get_template_directory();
--         end;

--         wp_textdomain_registry.set_custom_path( domain, path );

--         return load_textdomain( domain, path . "/" . locale . ".mo", locale );
-- end;

-- --
-- -- Loads the child themes translated strings.
-- --
-- -- If the current locale exists as a .mo file in the child themes
-- -- root directory, it will be included in the translated strings by the domain.
-- --
-- -- The .mo files must be named based on the locale exactly.
-- --
-- -- @since 2.9.0
-- --
-- -- @param string       domain Text domain. Unique identifier for retrieving translated strings.
-- -- @param string|false path   Optional. Path to the directory containing the .mo file.
-- --                             Default false.
-- -- @return bool True when the theme textdomain is successfully loaded, false otherwise.
-- --
-- function load_child_theme_textdomain( domain, path = false ) then
--         if ( ! path ) then
--                 path = get_stylesheet_directory();
--         end;
--         return load_theme_textdomain( domain, path );
-- end;

-- --
-- -- Loads the script translated strings.
-- --
-- -- @since 5.0.0
-- -- @since 5.0.2 Uses load_script_translations() to load translation data.
-- -- @since 5.1.0 The `domain` parameter was made optional.
-- --
-- -- @see WP_Scripts::set_translations()
-- --
-- -- @param string handle Name of the script to register a translation domain to.
-- -- @param string domain Optional. Text domain. Default "default".
-- -- @param string path   Optional. The full file path to the directory containing translation files.
-- -- @return string|false The translated strings in JSON encoding on success,
-- --                      false if the script textdomain could not be loaded.
-- --
-- function load_script_textdomain( handle, domain = "default", path = "" ) then
--         wp_scripts = wp_scripts();

--         if ( ! isset( wp_scripts.registered[ handle ] ) ) then
--                 return false;
--         end;

--         path   = untrailingslashit( path );
--         locale = determine_locale();

--         // If a path was given and the handle file exists simply return it.
--         file_base       = "default" === domain ? locale : domain . "-" . locale;
--         handle_filename = file_base . "-" . handle . ".json";

--         if ( path ) then
--                 translations = load_script_translations( path . "/" . handle_filename, handle, domain );

--                 if ( translations ) then
--                         return translations;
--                 end;
--         end;

--         src = wp_scripts.registered[ handle ].src;

--         if ( ! preg_match( "|^(https?:)?//|", src ) && ! ( wp_scripts.content_url && 0 === strpos( src, wp_scripts.content_url ) ) ) then
--                 src = wp_scripts.base_url . src;
--         end;

--         relative       = false;
--         languages_path = WP_LANG_DIR;

--         src_url     = wp_parse_url( src );
--         content_url = wp_parse_url( content_url() );
--         plugins_url = wp_parse_url( plugins_url() );
--         site_url    = wp_parse_url( site_url() );

--         // If the host is the same or it"s a relative URL.
--         if (
--                 ( ! isset( content_url["path"] ) || strpos( src_url["path"], content_url["path"] ) === 0 ) &&
--                 ( ! isset( src_url["host"] ) || ! isset( content_url["host"] ) || src_url["host"] === content_url["host"] )
--         ) then
--                 // Make the src relative the specific plugin or theme.
--                 if ( isset( content_url["path"] ) ) then
--                         relative = substr( src_url["path"], strlen( content_url["path"] ) );
--                 end; else then
--                         relative = src_url["path"];
--                 end;
--                 relative = trim( relative, "/" );
--                 relative = explode( "/", relative );

--                 languages_path = WP_LANG_DIR . "/" . relative[0];

--                 relative = array_slice( relative, 2 ); // Remove plugins/<plugin name> or themes/<theme name>.
--                 relative = implode( "/", relative );
--         end; elseif (
--                 ( ! isset( plugins_url["path"] ) || strpos( src_url["path"], plugins_url["path"] ) === 0 ) &&
--                 ( ! isset( src_url["host"] ) || ! isset( plugins_url["host"] ) || src_url["host"] === plugins_url["host"] )
--         ) then
--                 // Make the src relative the specific plugin.
--                 if ( isset( plugins_url["path"] ) ) then
--                         relative = substr( src_url["path"], strlen( plugins_url["path"] ) );
--                 end; else then
--                         relative = src_url["path"];
--                 end;
--                 relative = trim( relative, "/" );
--                 relative = explode( "/", relative );

--                 languages_path = WP_LANG_DIR . "/plugins";

--                 relative = array_slice( relative, 1 ); // Remove <plugin name>.
--                 relative = implode( "/", relative );
--         end; elseif ( ! isset( src_url["host"] ) || ! isset( site_url["host"] ) || src_url["host"] === site_url["host"] ) then
--                 if ( ! isset( site_url["path"] ) ) then
--                         relative = trim( src_url["path"], "/" );
--                 end; elseif ( ( strpos( src_url["path"], trailingslashit( site_url["path"] ) ) === 0 ) ) then
--                         // Make the src relative to the WP root.
--                         relative = substr( src_url["path"], strlen( site_url["path"] ) );
--                         relative = trim( relative, "/" );
--                 end;
--         end;

--         --
--         -- Filters the relative path of scripts used for finding translation files.
--         --
--         -- @since 5.0.2
--         --
--         -- @param string|false relative The relative path of the script. False if it could not be determined.
--         -- @param string       src      The full source URL of the script.
--         --
--         relative = apply_filters( "load_script_textdomain_relative_path", relative, src );

--         // If the source is not from WP.
--         if ( false === relative ) then
--                 return load_script_translations( false, handle, domain );
--         end;

--         // Translations are always based on the unminified filename.
--         if ( substr( relative, -7 ) === ".min.js" ) then
--                 relative = substr( relative, 0, -7 ) . ".js";
--         end;

--         md5_filename = file_base . "-" . md5( relative ) . ".json";

--         if ( path ) then
--                 translations = load_script_translations( path . "/" . md5_filename, handle, domain );

--                 if ( translations ) then
--                         return translations;
--                 end;
--         end;

--         translations = load_script_translations( languages_path . "/" . md5_filename, handle, domain );

--         if ( translations ) then
--                 return translations;
--         end;

--         return load_script_translations( false, handle, domain );
-- end;

-- --
-- -- Loads the translation data for the given script handle and text domain.
-- --
-- -- @since 5.0.2
-- --
-- -- @param string|false file   Path to the translation file to load. False if there isn"t one.
-- -- @param string       handle Name of the script to register a translation domain to.
-- -- @param string       domain The text domain.
-- -- @return string|false The JSON-encoded translated strings for the given script handle and text domain.
-- --                      False if there are none.
-- --
-- function load_script_translations( file, handle, domain ) then
--         --
--         -- Pre-filters script translations for the given file, script handle and text domain.
--         --
--         -- Returning a non-null value allows to override the default logic, effectively short-circuiting the function.
--         --
--         -- @since 5.0.2
--         --
--         -- @param string|false|null translations JSON-encoded translation data. Default null.
--         -- @param string|false      file         Path to the translation file to load. False if there isn"t one.
--         -- @param string            handle       Name of the script to register a translation domain to.
--         -- @param string            domain       The text domain.
--         --
--         translations = apply_filters( "pre_load_script_translations", null, file, handle, domain );

--         if ( null !== translations ) then
--                 return translations;
--         end;

--         --
--         -- Filters the file path for loading script translations for the given script handle and text domain.
--         --
--         -- @since 5.0.2
--         --
--         -- @param string|false file   Path to the translation file to load. False if there isn"t one.
--         -- @param string       handle Name of the script to register a translation domain to.
--         -- @param string       domain The text domain.
--         --
--         file = apply_filters( "load_script_translation_file", file, handle, domain );

--         if ( ! file || ! is_readable( file ) ) then
--                 return false;
--         end;

--         translations = file_get_contents( file );

--         --
--         -- Filters script translations for the given file, script handle and text domain.
--         --
--         -- @since 5.0.2
--         --
--         -- @param string translations JSON-encoded translation data.
--         -- @param string file         Path to the translation file that was loaded.
--         -- @param string handle       Name of the script to register a translation domain to.
--         -- @param string domain       The text domain.
--         --
--         return apply_filters( "load_script_translations", translations, file, handle, domain );
-- end;

   ------------------------------------
   -- X_Load_Textdomain_Just_In_Time --
   ------------------------------------

   function X_Load_Textdomain_Just_In_Time (Domain : String)
                                            return Boolean
   is
      use Php.Strings;
      use Class_Textdomain_Registry;
      use Inc_Formatting;
      use Inc_Themes;
      -- @var WP_Textdomain_Registry wp_textdomain_registry
--    global l10n_unloaded, wp_textdomain_registry;

--    l10n_unloaded = (array) l10n_unloaded;
   begin
      -- Short-circuit if domain is "default" which is reserved for core.
      if
        "default" = Domain or else
        String_Sets.Has_Element (L10n_Unloaded.Find (Domain))
--      Isset (L10n_Unloaded (Domain))
      then
         return False;
      end if;

      if not Textdomain_Registry.Has (Domain) then -- wp_
--    if not Wp_Textdomain_Registry.Has (Domain) then
         return False;
      end if;

      declare
         Locale : constant String := Determine_Locale; -- ();
         Path   : constant String := Textdomain_Registry.Get (Domain, Locale); -- wp_
      begin
         if Path = "" then
            return False;
         end if;

         -- Themes with their language directory outside of WP_LANG_DIR have a
         -- different file name.
         declare
            Template_Directory : constant String :=
              Trailing_Slash_It (Get_Template_Directory);

            Stylesheet_Directory : constant String :=
              Trailing_Slash_It (Get_Stylesheet_Directory);

            Starts_With : constant Boolean :=
              Str_Starts_With (Path, Template_Directory) or else
              Str_Starts_With (Path, Stylesheet_Directory);

            Mofile : constant String :=
              (if Starts_With
               then Path & Locale & ".mo"
               else Path & Domain & "-" & Locale & ".mo");
         begin
            return Load_Textdomain (Domain, Mofile, Locale);
         end;
      end;
   end X_Load_Textdomain_Just_In_Time;

   ---------------------------------
   -- Get_Translations_For_Domain --
   ---------------------------------

   Static_NOOP_Translations : constant POMO_Translations.Translations :=
     POMO_Translations.Null_Translations;

   function Get_Translations_For_Domain (Domain : String)
                                         return POMO_Translations.Translations
   is
--    use UStrings;
      use POMO_Translations;
--    global l10n;
   begin
      if
        String_Maps.Has_Element (L10n.Find (Domain)) or else
        (X_Load_Textdomain_Just_In_Time (Domain) and then
         String_Maps.Has_Element (L10n.Find (Domain)))
      then
         null;
--       return String_Maps.Element (L10n.Find (Domain));
--       return L10n (Domain);
      end if;

      -- if Null_Translations = Static_NOOP_Translations then
      --    Static_NOOP_Translations := new NOOP_Translations;
      -- end if;

      return Static_NOOP_Translations;
   end Get_Translations_For_Domain;

   procedure Get_Translations_For_Domain (Domain : String)
   is
      Unused : constant POMO_Translations.Translations :=
        Get_Translations_For_Domain (Domain);
   begin
      null;
   end Get_Translations_For_Domain;

-- --
-- -- Determines whether there are translations for the text domain.
-- --
-- -- @since 3.0.0
-- --
-- -- @global MO[] l10n An array of all currently loaded text domains.
-- --
-- -- @param string domain Text domain. Unique identifier for retrieving translated strings.
-- -- @return bool Whether there are translations.
-- --
-- function is_textdomain_loaded( domain ) then
--         global l10n;
--         return isset( l10n[ domain ] );
-- end;

-- --
-- -- Translates role name.
-- --
-- -- Since the role names are in the database and not in the source there
-- -- are dummy gettext calls to get them into the POT file and this function
-- -- properly translates them back.
-- --
-- -- The before_last_bar() call is needed, because older installations keep the roles
-- -- using the old context format: "Role name|User role" and just skipping the
-- -- content after the last bar is easier than fixing them in the DB. New installations
-- -- won"t suffer from that problem.
-- --
-- -- @since 2.8.0
-- -- @since 5.2.0 Added the `domain` parameter.
-- --
-- -- @param string name   The role name.
-- -- @param string domain Optional. Text domain. Unique identifier for retrieving translated strings.
-- --                       Default "default".
-- -- @return string Translated role name on success, original name on failure.
-- --
-- function translate_user_role( name, domain = "default" ) then
--         return translate_with_gettext_context( before_last_bar( name ), "User role", domain );
-- end;

   -----------------------------
   -- Get_Available_Languages --
   -----------------------------

   function Get_Available_Languages (Dir : String := "") -- null
                                     return Array_Type
   is
      use Php.Files;
      use Php.Strings;
      use Wp_Common;
      use Inc_Plugins;

      Languages  : Array_Type;

      Lang_Files : constant List_Type :=
        Glob ((if Dir = "" -- Is_Null (Dir)
               then Constants.WP_LANG_DIR
               else Dir) & "/*.mo");
   begin
      if not Lang_Files.Is_Empty then
         for Lang_File of Lang_Files loop
            declare
               Lang_File_2 : constant String := Basename (Lang_File, ".mo");
            begin
               if
                 0 /= Strpos (Lang_File_2, "continents-cities") and then
                 0 /= Strpos (Lang_File_2, "ms-") and then
                 0 /= Strpos (Lang_File_2, "admin-")
               then
                  Languages.Append (From_String (Lang_File_2));
               end if;
            end;
         end loop;
      end if;

      --
      -- Filters the list of available language codes.
      --
      -- @since 4.7.0
      --
      -- @param string[] languages An array of available language codes.
      -- @param string   dir       The directory where the language files were found.
      --
      return Apply_Filters ("get_available_languages", Languages, Dir);
   end Get_Available_Languages;

-- --
-- -- Gets installed translations.
-- --
-- -- Looks in the wp-content/languages directory for translations of
-- -- plugins or themes.
-- --
-- -- @since 3.7.0
-- --
-- -- @param string type What to search for. Accepts "plugins", "themes", "core".
-- -- @return array Array of language data.
-- --
-- function wp_get_installed_translations( type ) then
--         if ( "themes" !== type && "plugins" !== type && "core" !== type ) then
--                 return array();
--         end;

--         dir = "core" === type ? "" : "/type";

--         if ( ! is_dir( WP_LANG_DIR ) ) then
--                 return array();
--         end;

--         if ( dir && ! is_dir( WP_LANG_DIR . dir ) ) then
--                 return array();
--         end;

--         files = scandir( WP_LANG_DIR . dir );
--         if ( ! files ) then
--                 return array();
--         end;

--         language_data = array();

--         foreach ( files as file ) then
--                 if ( "." === file[0] || is_dir( WP_LANG_DIR . "dir/file" ) ) then
--                         continue;
--                 end;
--                 if ( substr( file, -3 ) !== ".po" ) then
--                         continue;
--                 end;
--                 if ( ! preg_match( "/(?:(.+)-)?([a-z]then2,3end;(?:_[A-Z]then2end;)?(?:_[a-z0-9]+)?).po/", file, match ) ) then
--                         continue;
--                 end;
--                 if ( ! in_array( substr( file, 0, -3 ) . ".mo", files, true ) ) then
--                         continue;
--                 end;

--                 list( , textdomain, language ) = match;
--                 if ( "" === textdomain ) then
--                         textdomain = "default";
--                 end;
--                 language_data[ textdomain ][ language ] = wp_get_pomo_file_data( WP_LANG_DIR . "dir/file" );
--         end;
--         return language_data;
-- end;

-- --
-- -- Extracts headers from a PO file.
-- --
-- -- @since 3.7.0
-- --
-- -- @param string po_file Path to PO file.
-- -- @return string[] Array of PO file header values keyed by header name.
-- --
-- function wp_get_pomo_file_data( po_file ) then
--         headers = get_file_data(
--                 po_file,
--                 array(
--                         "POT-Creation-Date"  => ""POT-Creation-Date",
--                         "PO-Revision-Date"   => ""PO-Revision-Date",
--                         "Project-Id-Version" => ""Project-Id-Version",
--                         "X-Generator"        => ""X-Generator",
--                 )
--         );
--         foreach ( headers as header => value ) then
--                 // Remove possible contextual "\n" and closing double quote.
--                 headers[ header ] = preg_replace( "~(\\\n)?"~", "", value );
--         end;
--         return headers;
-- end;

   ---------------------------
   -- Wp_Dropdown_Languages --
   ---------------------------

   function Wp_Dropdown_Languages (Args : Array_Type := Empty_Array)
                                   return String
   is
      use Php.Echoing;
      use Php.Strings;
      use Array_Vectors;
      use UStrings;
      use Adi_Translation_Install;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;

      Parsed_Args : Array_Type :=
        Wp_Parse_Args (
          Args,
          To_Array (List => (
            Build ("id",                          "locale"),
            Build ("name",                        "locale"),
            Build ("languages",                   Empty_List),
            Build ("translations",                Empty_Array),
            Build ("selected",                    ""),
            Build ("echo",                        1),
            Build ("show_available_translations", True),
            Build ("show_option_site_default",    False),
            Build ("show_option_en_us",           True),
            Build ("explicit_option_en_us",       False)
          ))
        );
   begin
      -- Bail if no ID or no name.
      if
        not Isset (Parsed_Args, "id") or else
        not Isset (Parsed_Args, "name")
      then
--    if not parsed_args["id"] or else not parsed_args["name"] then
         return "";
      end if;

      -- English (United States) uses an empty string for the value attribute.
      if
        "en_US" = Get_As_String (Parsed_Args, "selected") and then
        not Isset (Parsed_Args, "explicit_option_en_us")
      then
         Set (Parsed_Args, "selected", From_String (""));
      end if;

      declare
         Translations_2 : constant Array_Type :=
           As_Array (Get (Parsed_Args, "translations"));

         Translations : Array_Type :=
           (if Translations_2.Is_Empty
            then Wp_Get_Available_Translations
            else Translations_2);

         Languages : Array_Vector;
      begin
         --
         -- parsed_args["languages"] should only contain the locales. Find the
         -- locale in translations to get the native name. Fall back to locale.
         --
         for Locale of As_List (Get (Parsed_Args, "languages")) loop
            if Isset (Translations, Locale) then
               declare
                  Translation : constant Array_Type :=
                    As_Array (Get (Translations, Locale));
               begin
                  Languages.Append (To_Array (List => (
                    Build ("language",    Get_As_String (Translation, "language")),
                    Build ("native_name", Get_As_String (Translation, "native_name")),
                    Build ("lang",        Get_As_String (Translation, "iso"))
                    -- current ???
                  )));

                  -- Remove installed language from available translations.
                  Delete (Ref (Translations, Locale));
               end;
            else
               Languages.Append (To_Array (List => (
                 Build ("language",    Locale),
                 Build ("native_name", Locale),
                 Build ("lang",        "")
               )));
            end if;
         end loop;

         declare
            Translations_Available : constant Boolean :=
              not Translations.Is_Empty and then
              As_Boolean (Get (Parsed_Args, "show_available_translations"));

            -- Holds the HTML markup.
            Structure : List_Type;
         begin
            -- List installed languages.
            if Translations_Available then
               Structure.Append ("<optgroup label=""" &
                                 ESC_Attr_X ("Installed", "translations") & """>");
            end if;

            -- Site default.
            if As_Boolean (Get (Parsed_Args, "show_option_site_default")) then
               Structure.Append (
                 Sprintf (
                   "<option value=""site-default"" data-installed=""1""%s>%s</option>",
                   [
                     1 => Selected ("site-default",
                                    Get_As_String (Parsed_Args, "selected"),
                                    False),
                     2 => X_X ("Site Default", "default site language")
                   ]
                ));
            end if;

            if As_Boolean (Get (Parsed_Args, "show_option_en_us")) then
               declare
                  Value : constant String :=
                    (if As_Boolean (Get (Parsed_Args, "explicit_option_en_us"))
                     then "en_US" else "");
               begin
                  Structure.Append (
                    Sprintf (
                      "<option value=""%s"" lang=""en"" data-installed=""1""%s>" &
                      "English (United States)</option>",
                      [
                        1 => ESC_Attr (Value),
                        2 => Selected ("",
                                       Get_As_String (Parsed_Args, "selected"),
                                       False)
                      ]
                    ));
               end;
            end if;

            -- List installed languages.
            for Language of Languages loop
               Structure.Append (
                 Sprintf (
                   "<option value=""%s"" lang=""%s""%s data-installed=""1"">" &
                   "%s</option>",
                   [
                     1 => ESC_Attr (Get_As_String (Language, "language")),
                     2 => ESC_Attr (Get_As_String (Language, "lang")),
                     3 => Selected (Get_As_String (Language, "language"),
                                    Get_As_String (Parsed_Args, "selected"),
                                    False),
                     4 => ESC_HTML (Get_As_String (Language, "native_name"))
                   ]
                 ));
            end loop;

            if Translations_Available then
               Structure.Append ("</optgroup>");
            end if;

            -- List available translations.
            if Translations_Available then
               Structure.Append ("<optgroup label=""" &
                                 ESC_Attr_X ("Available", "translations") & """>");

               for T in Translations.Iterate loop
                  declare
                     Translation : constant Array_Type := As_Array (Element (T));
                  begin
                     Structure.Append (
                       Sprintf (
                         "<option value=""%s"" lang=""%s""%s>%s</option>",
                         [
                           1 => ESC_Attr (Get_As_String (Translation, "language")),
                           2 => ESC_Attr (Get_As_String (Translation, "iso")),
                           -- Current ???
                           3 => Selected (Get_As_String (Translation, "language"),
                                          Get_As_String (Parsed_Args, "selected"),
                                          False),
                           4 => ESC_HTML (Get_As_String (Translation, "native_name"))
                         ]
                       ));
                  end;
               end loop;
               Structure.Append ("</optgroup>");
            end if;

            -- Combine the output string.
            declare
               Output : UString :=
                 +Sprintf (
                   "<select name=""%s"" id=""%s"">",
                   [
                     1 => ESC_Attr (Get_As_String (Parsed_Args, "name")),
                     2 => ESC_Attr (Get_As_String (Parsed_Args, "id"))
                   ]
                 );
            begin
               Append (Output, Implode ("\n", Structure));
               Append (Output, "</select>");

               if As_Boolean (Get (Parsed_Args, "echo")) then
                  Echo (-Output);
               end if;

               return -Output;
            end;
         end;
      end;
   end Wp_Dropdown_Languages;

   ---------------------------
   -- Wp_Dropdown_Languages --
   ---------------------------

   procedure Wp_Dropdown_Languages (Args : Array_Type := Empty_Array)
   is
      Unused : constant String := Wp_Dropdown_Languages (Args);
   begin
      null;
   end Wp_Dropdown_Languages;

-- --
-- -- Determines whether the current locale is right-to-left (RTL).
-- --
-- -- For more information on this and similar theme functions, check out
-- -- the {@link https://developer.wordpress.org/themes/basics/conditional-tags/
-- -- Conditional Tags}  article in the Theme Developer Handbook.
-- --
-- -- @since 3.0.0
-- --
-- -- @global WP_Locale wp_locale WordPress date and time locale object.
-- --
-- -- @return bool Whether locale is RTL.
-- --
-- function is_rtl() then
--         global wp_locale;
--         if ( ! ( wp_locale instanceof WP_Locale ) ) then
--                 return false;
--         end;
--         return wp_locale.is_rtl();
-- end;

   ----------------------
   -- Switch_To_Locale --
   ----------------------

   function Switch_To_Locale (Locale : String)
                              return Boolean
   is
      -- @var WP_Locale_Switcher wp_locale_switcher
--        global wp_locale_switcher;
   begin
      return Global_Wp_Locale_Switcher.Switch_To_Locale (Locale);
   end Switch_To_Locale;

   -----------------------------
   -- Restore_Previous_Locale --
   -----------------------------

   function Restore_Previous_Locale
            return String
   is
      -- @var WP_Locale_Switcher wp_locale_switcher
--        global wp_locale_switcher;
   begin
      return Global_Wp_Locale_Switcher.Restore_Previous_Locale; -- ()
   end Restore_Previous_Locale;

   procedure Restore_Previous_Locale
   is
      Unused : constant String := Restore_Previous_Locale;
   begin
      null;
   end Restore_Previous_Locale;

-- --
-- -- Restores the translations according to the original locale.
-- --
-- -- @since 4.7.0
-- --
-- -- @global WP_Locale_Switcher wp_locale_switcher WordPress locale switcher object.
-- --
-- -- @return string|false Locale on success, false on error.
-- --
-- function restore_current_locale() then
--         /* @var WP_Locale_Switcher wp_locale_switcher--
--         global wp_locale_switcher;

--         return wp_locale_switcher.restore_current_locale();
-- end;

-- --
-- -- Determines whether switch_to_locale() is in effect.
-- --
-- -- @since 4.7.0
-- --
-- -- @global WP_Locale_Switcher wp_locale_switcher WordPress locale switcher object.
-- --
-- -- @return bool True if the locale has been switched, false otherwise.
-- --
-- function is_locale_switched() then
--         /* @var WP_Locale_Switcher wp_locale_switcher--
--         global wp_locale_switcher;

--         return wp_locale_switcher.is_switched();
-- end;

   ------------------------------------------
   -- Translate_Settings_Using_I18n_Schema --
   ------------------------------------------

   function Translate_Settings_Using_I18n_Schema (I18n_Schema : String; -- Array_Type;
                                                  Settings    : Array_Type;
                                                  Textdomain  : String)
                                                  return Array_Type
   is
      use Php.Arrays;
      use Php.Strings;
   begin
      if
        Empty (I18n_Schema) or else
        Empty (Settings)    or else
        Empty (Textdomain)
      then
         return Settings;
      end if;

--       if
--         Is_String (I18n_Schema) -- and then
-- --      Is_String (Settings)
--       then
--          return
--            Translate_With_Gettext_Context (Settings, I18n_Schema, Textdomain);
--       end if;

      -- if
      --   Is_Array (I18n_Schema) and then
      --   Is_Array (Settings)
      -- then
      --    declare
      --       Translated_Settings : List_Type; Array_Type;
      --    begin
      --       for Value of Settings loop
      --          Translated_Settings.Append (
      --            Translate_Settings_Using_I18n_Schema (
      --              I18n_Schema.First_Element.Arry.all, Value.Arry.all, Textdomain));
      --           I18n_Schema (0), Value, Textdomain));
      --       end loop;
      --       return Translated_Settings;
      --    end;
      -- end if;

      -- if
      --   Is_Object (I18n_Schema) and then
      --   Is_Array (Settings)
      -- then
      --    declare
      --       Group_Key           : String := "*";
      --       Translated_Settings : Array_Type;
      --    begin
      --       for A in Settings.Iterate loop
      --          declare
      --             Key   : String := Key (A);
      --             Value : String := Element (A);
      --          begin
      --             if Isset (I18n_Schema, Key) then
      --                Set (Translated_Settings, Key,
      --                     Translate_Settings_Using_I18n_Schema (I18n_Schema.key,
      --                                                           Value, Textdomain));
      --             elsif Isset (I18n_Schema, Group_Key) then
      --                Set (Translated_Settings, Key,
      --                     Translate_Settings_Using_I18n_Schema (I18n_Schema.Group_Key,
      --                                                           Value, Textdomain));
      --             else
      --                Set (Translated_Settings, Key, Value);
      --             end if;
      --          end;
      --       end loop;
      --       return Translated_Settings;
      --    end;
      -- end if;
      -- return Settings;

      return Empty_Array; -- added
   end Translate_Settings_Using_I18n_Schema;

-- --
-- -- Retrieves the list item separator based on the locale.
-- --
-- -- @since 6.0.0
-- --
-- -- @global WP_Locale wp_locale WordPress date and time locale object.
-- --
-- -- @return string Locale-specific list item separator.
-- --
-- function wp_get_list_item_separator() then
--         global wp_locale;

--         return wp_locale.get_list_item_separator();
-- end;

end Inc_L10n;
