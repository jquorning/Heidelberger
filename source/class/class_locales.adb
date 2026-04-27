--
-- Locale API: WP_Locale class
--
-- @package WordPress
-- @subpackage i18n
-- @since 4.6.0
--

with Helpers;

package body Class_Locales
is

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
            return Wp_Locale
   is
      This : Wp_Locale;
   begin
      This.Init; -- ();
      This.Register_Globals; -- ();
      return This;
   end X_Construct;

   ----------
   -- Init --
   ----------

   procedure Init (This : Wp_Locale)
   is
   begin
      raise Program_Error with "not implemented";
   end Init;
--                 // The weekdays.
--                 this.weekday[0] = -- translators: Weekday.-- __( 'Sunday' );
--                 this.weekday[1] = -- translators: Weekday.-- __( 'Monday' );
--                 this.weekday[2] = -- translators: Weekday.-- __( 'Tuesday' );
--                 this.weekday[3] = -- translators: Weekday.-- __( 'Wednesday' );
--                 this.weekday[4] = -- translators: Weekday.-- __( 'Thursday' );
--                 this.weekday[5] = -- translators: Weekday.-- __( 'Friday' );
--                 this.weekday[6] = -- translators: Weekday.-- __( 'Saturday' );

--                 // The first letter of each day.
--                 this.weekday_initial[ this.weekday[0] ] = -- translators: One-letter abbreviation of the weekday.-- _x( 'S', 'Sunday initial' );
--                 this.weekday_initial[ this.weekday[1] ] = -- translators: One-letter abbreviation of the weekday.-- _x( 'M', 'Monday initial' );
--                 this.weekday_initial[ this.weekday[2] ] = -- translators: One-letter abbreviation of the weekday.-- _x( 'T', 'Tuesday initial' );
--                 this.weekday_initial[ this.weekday[3] ] = -- translators: One-letter abbreviation of the weekday.-- _x( 'W', 'Wednesday initial' );
--                 this.weekday_initial[ this.weekday[4] ] = -- translators: One-letter abbreviation of the weekday.-- _x( 'T', 'Thursday initial' );
--                 this.weekday_initial[ this.weekday[5] ] = -- translators: One-letter abbreviation of the weekday.-- _x( 'F', 'Friday initial' );
--                 this.weekday_initial[ this.weekday[6] ] = -- translators: One-letter abbreviation of the weekday.-- _x( 'S', 'Saturday initial' );

--                 // Abbreviations for each day.
--                 this.weekday_abbrev[ this.weekday[0] ] = -- translators: Three-letter abbreviation of the weekday.-- __( 'Sun' );
--                 this.weekday_abbrev[ this.weekday[1] ] = -- translators: Three-letter abbreviation of the weekday.-- __( 'Mon' );
--                 this.weekday_abbrev[ this.weekday[2] ] = -- translators: Three-letter abbreviation of the weekday.-- __( 'Tue' );
--                 this.weekday_abbrev[ this.weekday[3] ] = -- translators: Three-letter abbreviation of the weekday.-- __( 'Wed' );
--                 this.weekday_abbrev[ this.weekday[4] ] = -- translators: Three-letter abbreviation of the weekday.-- __( 'Thu' );
--                 this.weekday_abbrev[ this.weekday[5] ] = -- translators: Three-letter abbreviation of the weekday.-- __( 'Fri' );
--                 this.weekday_abbrev[ this.weekday[6] ] = -- translators: Three-letter abbreviation of the weekday.-- __( 'Sat' );

--                 // The months.
--                 this.month['01'] = -- translators: Month name.-- __( 'January' );
--                 this.month['02'] = -- translators: Month name.-- __( 'February' );
--                 this.month['03'] = -- translators: Month name.-- __( 'March' );
--                 this.month['04'] = -- translators: Month name.-- __( 'April' );
--                 this.month['05'] = -- translators: Month name.-- __( 'May' );
--                 this.month['06'] = -- translators: Month name.-- __( 'June' );
--                 this.month['07'] = -- translators: Month name.-- __( 'July' );
--                 this.month['08'] = -- translators: Month name.-- __( 'August' );
--                 this.month['09'] = -- translators: Month name.-- __( 'September' );
--                 this.month['10'] = -- translators: Month name.-- __( 'October' );
--                 this.month['11'] = -- translators: Month name.-- __( 'November' );
--                 this.month['12'] = -- translators: Month name.-- __( 'December' );

--                 // The months, genitive.
--                 this.month_genitive['01'] = -- translators: Month name, genitive.-- _x( 'January', 'genitive' );
--                 this.month_genitive['02'] = -- translators: Month name, genitive.-- _x( 'February', 'genitive' );
--                 this.month_genitive['03'] = -- translators: Month name, genitive.-- _x( 'March', 'genitive' );
--                 this.month_genitive['04'] = -- translators: Month name, genitive.-- _x( 'April', 'genitive' );
--                 this.month_genitive['05'] = -- translators: Month name, genitive.-- _x( 'May', 'genitive' );
--                 this.month_genitive['06'] = -- translators: Month name, genitive.-- _x( 'June', 'genitive' );
--                 this.month_genitive['07'] = -- translators: Month name, genitive.-- _x( 'July', 'genitive' );
--                 this.month_genitive['08'] = -- translators: Month name, genitive.-- _x( 'August', 'genitive' );
--                 this.month_genitive['09'] = -- translators: Month name, genitive.-- _x( 'September', 'genitive' );
--                 this.month_genitive['10'] = -- translators: Month name, genitive.-- _x( 'October', 'genitive' );
--                 this.month_genitive['11'] = -- translators: Month name, genitive.-- _x( 'November', 'genitive' );
--                 this.month_genitive['12'] = -- translators: Month name, genitive.-- _x( 'December', 'genitive' );

--                 // Abbreviations for each month.
--                 this.month_abbrev[ this.month['01'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Jan', 'January abbreviation' );
--                 this.month_abbrev[ this.month['02'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Feb', 'February abbreviation' );
--                 this.month_abbrev[ this.month['03'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Mar', 'March abbreviation' );
--                 this.month_abbrev[ this.month['04'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Apr', 'April abbreviation' );
--                 this.month_abbrev[ this.month['05'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'May', 'May abbreviation' );
--                 this.month_abbrev[ this.month['06'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Jun', 'June abbreviation' );
--                 this.month_abbrev[ this.month['07'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Jul', 'July abbreviation' );
--                 this.month_abbrev[ this.month['08'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Aug', 'August abbreviation' );
--                 this.month_abbrev[ this.month['09'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Sep', 'September abbreviation' );
--                 this.month_abbrev[ this.month['10'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Oct', 'October abbreviation' );
--                 this.month_abbrev[ this.month['11'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Nov', 'November abbreviation' );
--                 this.month_abbrev[ this.month['12'] ] = -- translators: Three-letter abbreviation of the month.-- _x( 'Dec', 'December abbreviation' );

--                 // The meridiems.
--                 this.meridiem['am'] = __( 'am' );
--                 this.meridiem['pm'] = __( 'pm' );
--                 this.meridiem['AM'] = __( 'AM' );
--                 this.meridiem['PM'] = __( 'PM' );

--                 // Numbers formatting.
--                 // See https://www.php.net/number_format

--                 -- translators: thousands_sep argument for https://www.php.net/number_format, default is ','--
--                 thousands_sep = __( 'number_format_thousands_sep' );

--                 // Replace space with a non-breaking space to avoid wrapping.
--                 thousands_sep = str_replace( ' ', '&nbsp;', thousands_sep );

--                 this.number_format['thousands_sep'] = ( 'number_format_thousands_sep' === thousands_sep ) ? ',' : thousands_sep;

--                 -- translators: dec_point argument for https://www.php.net/number_format, default is '.'--
--                 decimal_point = __( 'number_format_decimal_point' );

--                 this.number_format['decimal_point'] = ( 'number_format_decimal_point' === decimal_point ) ? '.' : decimal_point;

--                 -- translators: used between list items, there is a space after the comma--
--                 this.list_item_separator = __( ', ' );

--                 // Set text direction.
--                 if ( isset( GLOBALS['text_direction'] ) ) then
--                         this.text_direction = GLOBALS['text_direction'];

--                         -- translators: 'rtl' or 'ltr'. This sets the text direction for WordPress.--
--                 end; elseif ( 'rtl' === _x( 'ltr', 'text direction' ) ) then
--                         this.text_direction = 'rtl';
--                 end;
--         end;

   -----------------
   -- Get_Weekday --
   -----------------

   function Get_Weekday
     (This : Wp_Locale; Weekday_Number : Integer) return String is
   begin
      return Get_As_String (This.Weekday, Helpers.Image (Weekday_Number));
   end Get_Weekday;

--         --
--         -- Retrieves the translated weekday initial.
--         --
--         -- The weekday initial is retrieved by the translated
--         -- full weekday word. When translating the weekday initial
--         -- pay attention to make sure that the starting letter does
--         -- not conflict.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string weekday_name Full translated weekday word.
--         -- @return string Translated weekday initial.
--         --
--         public function get_weekday_initial( weekday_name ) then
--                 return this.weekday_initial[ weekday_name ];
--         end;

--         --
--         -- Retrieves the translated weekday abbreviation.
--         --
--         -- The weekday abbreviation is retrieved by the translated
--         -- full weekday word.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string weekday_name Full translated weekday word.
--         -- @return string Translated weekday abbreviation.
--         --
--         public function get_weekday_abbrev( weekday_name ) then
--                 return this.weekday_abbrev[ weekday_name ];
--         end;

--         --
--         -- Retrieves the full translated month by month number.
--         --
--         -- The month_number parameter has to be a string
--         -- because it must have the '0' in front of any number
--         -- that is less than 10. Starts from '01' and ends at
--         -- '12'.
--         --
--         -- You can use an integer instead and it will add the
--         -- '0' before the numbers less than 10 for you.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string|int month_number '01' through '12'.
--         -- @return string Translated full month name.
--         --
--         public function get_month( month_number ) then
--                 return this.month[ zeroise( month_number, 2 ) ];
--         end;

--         --
--         -- Retrieves translated version of month abbreviation string.
--         --
--         -- The month_name parameter is expected to be the translated or
--         -- translatable version of the month.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string month_name Translated month to get abbreviated version.
--         -- @return string Translated abbreviated month.
--         --
--         public function get_month_abbrev( month_name ) then
--                 return this.month_abbrev[ month_name ];
--         end;

--         --
--         -- Retrieves translated version of meridiem string.
--         --
--         -- The meridiem parameter is expected to not be translated.
--         --
--         -- @since 2.1.0
--         --
--         -- @param string meridiem Either 'am', 'pm', 'AM', or 'PM'. Not translated version.
--         -- @return string Translated version
--         --
--         public function get_meridiem( meridiem ) then
--                 return this.meridiem[ meridiem ];
--         end;

   ----------------------
   -- Register_Globals --
   ----------------------

   procedure Register_Globals (This : Wp_Locale)
   is
   begin
      raise Program_Error with "not implemented";
                -- GLOBALS['weekday']         = this.weekday;
                -- GLOBALS['weekday_initial'] = this.weekday_initial;
                -- GLOBALS['weekday_abbrev']  = this.weekday_abbrev;
                -- GLOBALS['month']           = this.month;
                -- GLOBALS['month_abbrev']    = this.month_abbrev;
   end Register_Globals;

--         --
--         -- Checks if current locale is RTL.
--         --
--         -- @since 3.0.0
--         -- @return bool Whether locale is RTL.
--         --
--         public function is_rtl() then
--                 return 'rtl' === this.text_direction;
--         end;

--         --
--         -- Registers date/time format strings for general POT.
--         --
--         -- Private, unused method to add some date/time formats translated
--         -- on wp-admin/options-general.php to the general POT that would
--         -- otherwise be added to the admin POT.
--         --
--         -- @since 3.6.0
--         --
--         public function _strings_for_pot() then
--                 -- translators: Localized date format, see https://www.php.net/manual/datetime.format.php--
--                 __( 'F j, Y' );
--                 -- translators: Localized time format, see https://www.php.net/manual/datetime.format.php--
--                 __( 'g:i a' );
--                 -- translators: Localized date and time format, see https://www.php.net/manual/datetime.format.php--
--                 __( 'F j, Y g:i a' );
--         end;

--         --
--         -- Retrieves the localized list item separator.
--         --
--         -- @since 6.0.0
--         --
--         -- @return string Localized list item separator.
--         --
--         public function get_list_item_separator() then
--                 return this.list_item_separator;
--         end;
-- end;

end Class_Locales;
