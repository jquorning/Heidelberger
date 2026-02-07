--
-- WordPress Translation Installation Administration API
--
-- @package WordPress
-- @subpackage Administration
--

with Arrays;

with Class_Errors;

package Adi_Translation_Install
is
   use Arrays;

   --
   -- Retrieve translations from WordPress Translation API.
   --
   -- @since 4.0.0
   --
   -- @param string       type Type of translations. Accepts "plugins", "themes",
   --                           "core".
   -- @param array|object args Translation API arguments. Optional.
   -- @return array|WP_Error On success an associative array of translations,
   --                         WP_Error on failure.
   --
   type Trans_Result is record
     Success : Boolean;
     Arry    : Array_Type;
     Error   : Class_Errors.Wp_Error;
   end record;

   function Translations_API (Typ  : String;
                              Args : Array_Type := Empty_Array) -- null
                              return Trans_Result; -- Array_Type;

   --
   -- Get available translations from the WordPress.org API.
   --
   -- @since 4.0.0
   --
   -- @see translations_api()
   --
   -- @return array[] Array of translations, each an array of data, keyed by the
   --                 language. If the API response results in an error, an empty
   --                 array will be returned.
   --
   function Wp_Get_Available_Translations
            return Array_Type;
--         if ( ! wp_installing() ) then
--                 translations = get_site_transient( "available_translations" );
--                 if ( false !== translations ) then
--                         return translations;
--                 end;
--         end;

--         -- Include an unmodified wp_version.
--         require ABSPATH . WPINC . "/version.php";

--         api = translations_api( "core", array( "version" => wp_version ) );

--         if ( is_wp_error( api ) || empty( api["translations"] ) ) then
--                 return array();
--         end;

--         translations = array();
--         -- Key the array with the language code for now.
--         foreach ( api["translations"] as translation ) then
--                 translations[ translation["language"] ] = translation;
--         end;

--         if ( ! defined( "WP_INSTALLING" ) ) then
--                 set_site_transient( "available_translations", translations, 3-- HOUR_IN_SECONDS );
--         end;

--         return translations;
-- end;

   --
   -- Output the select form for the language selection on the installation screen.
   --
   -- @since 4.0.0
   --
   -- @global string wp_local_package Locale code of the package.
   --
   -- @param array[] languages Array of available languages (populated via the
   --                           Translation API).
   --
   procedure Wp_Install_Language_Form (Languages : Array_Type);
--         global wp_local_package;

--         installed_languages = get_available_languages();

--         echo "<label class="screen-reader-text" for="language">Select a default language</label>\n";
--         echo "<select size="14" name="language" id="language">\n";
--         echo "<option value="" lang="en" selected="selected" data-continue="Continue" data-installed="1">English (United States)</option>";
--         echo "\n";

--         if ( ! empty( wp_local_package ) && isset( languages[ wp_local_package ] ) ) then
--                 if ( isset( languages[ wp_local_package ] ) ) then
--                         language = languages[ wp_local_package ];
--                         printf(
--                                 "<option value="%s" lang="%s" data-continue="%s"%s>%s</option>" . "\n",
--                                 esc_attr( language["language"] ),
--                                 esc_attr( current( language["iso"] ) ),
--                                 esc_attr( language["strings"]["continue"] ? language["strings"]["continue"] : "Continue" ),
--                                 in_array( language["language"], installed_languages, true ) ? " data-installed="1"" : "",
--                                 esc_html( language["native_name"] )
--                         );

--                         unset( languages[ wp_local_package ] );
--                 end;
--         end;

--         foreach ( languages as language ) then
--                 printf(
--                         "<option value="%s" lang="%s" data-continue="%s"%s>%s</option>" . "\n",
--                         esc_attr( language["language"] ),
--                         esc_attr( current( language["iso"] ) ),
--                         esc_attr( language["strings"]["continue"] ? language["strings"]["continue"] : "Continue" ),
--                         in_array( language["language"], installed_languages, true ) ? " data-installed="1"" : "",
--                         esc_html( language["native_name"] )
--                 );
--         end;
--         echo "</select>\n";
--         echo "<p class="step"><span class="spinner"></span><input id="language-continue" type="submit" class="button button-primary button-large" value="Continue" /></p>";
-- end;

   --
   -- Download a language pack.
   --
   -- @since 4.0.0
   --
   -- @see wp_get_available_translations()
   --
   -- @param string download Language code to download.
   -- @return string|false Returns the language code if successfully downloaded
   --                      (or already installed), or false on failure.
   --
   function Wp_Download_Language_Pack (Download : String)
                                       return String;

   --
   -- Check if WordPress has access to the filesystem without asking for
   -- credentials.
   --
   -- @since 4.0.0
   --
   -- @return bool Returns true on success, false on failure.
   --
   function Wp_Can_Install_Language_Pack
            return Boolean;

end Adi_Translation_Install;
