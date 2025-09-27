--
-- Locale API: WP_Locale class
--
-- @package WordPress
-- @subpackage i18n
-- @since 4.6.0
--

with Ada.Strings.Unbounded;

with Arrays;

package Inc_Class_Wp_Locale
is
   use Ada.Strings.Unbounded;
   use Arrays;

   procedure Dummy;
   --
   -- Core class used to store translated data for a locale.
   --
   -- @since 2.1.0
   -- @since 4.6.0 Moved to its own file from wp-includes/locale.php.
   --
-- #[AllowDynamicProperties]
   type Wp_Locale is tagged
      record
         --
         -- Stores the translated strings for the full weekday names.
         --
         -- @since 2.1.0
         -- @var string[]
         --
--        public weekday;

         --
         -- Stores the translated strings for the one character weekday names.
         --
         -- There is a hack to make sure that Tuesday and Thursday, as well
         -- as Sunday and Saturday, don't conflict. See init() method for more.
         --
         -- @see WP_Locale::init() for how to handle the hack.
         --
         -- @since 2.1.0
         -- @var string[]
         --
--        public weekday_initial;

         --
         -- Stores the translated strings for the abbreviated weekday names.
         --
         -- @since 2.1.0
         -- @var string[]
         --
--        public weekday_abbrev;

         --
         -- Stores the translated strings for the full month names.
         --
         -- @since 2.1.0
         -- @var string[]
         --
--        public month;

         --
         -- Stores the translated strings for the month names in genitive case, if
         -- the locale specifies.
         --
         -- @since 4.4.0
         -- @var string[]
         --
--        public month_genitive;

         --
         -- Stores the translated strings for the abbreviated month names.
         --
         -- @since 2.1.0
         -- @var string[]
         --
--        public month_abbrev;

         --
         -- Stores the translated strings for 'am' and 'pm'.
         --
         -- Also the capitalized versions.
         --
         -- @since 2.1.0
         -- @var string[]
         --
--        public meridiem;

         --
         -- The text direction of the locale language.
         --
         -- Default is left to right 'ltr'.
         --
         -- @since 2.1.0
         -- @var string
         --
--        public text_direction = 'ltr';

         --
         -- The thousands separator and decimal point values used for localizing
         -- numbers.
         --
         -- @since 2.3.0
         -- @var array
         --
         Number_Format : Array_Type;

         --
         -- The separator string used for localizing list item separator.
         --
         -- @since 6.0.0
         -- @var string
         --
         List_Item_Separator : Unbounded_String;

      end record;

end Inc_Class_Wp_Locale;
