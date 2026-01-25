--
-- Locale API: WP_Locale class
--
-- @package WordPress
-- @subpackage i18n
-- @since 4.6.0
--

with Arrays;
with UStrings;

package Class_Locales
is
   use Arrays;

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
         Weekday : Array_Type;

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
         Weekday_Initial : Array_Type;

         --
         -- Stores the translated strings for the abbreviated weekday names.
         --
         -- @since 2.1.0
         -- @var string[]
         --
         Weekday_Abbrev : Array_Type;

         --
         -- Stores the translated strings for the full month names.
         --
         -- @since 2.1.0
         -- @var string[]
         --
         Month : Array_Type;

         --
         -- Stores the translated strings for the month names in genitive case, if
         -- the locale specifies.
         --
         -- @since 4.4.0
         -- @var string[]
         --
         Month_Genitive : Array_Type;

         --
         -- Stores the translated strings for the abbreviated month names.
         --
         -- @since 2.1.0
         -- @var string[]
         --
         Month_Abbrev : Array_Type;

         --
         -- Stores the translated strings for 'am' and 'pm'.
         --
         -- Also the capitalized versions.
         --
         -- @since 2.1.0
         -- @var string[]
         --
         Meridiem : Array_Type;

         --
         -- The text direction of the locale language.
         --
         -- Default is left to right 'ltr'.
         --
         -- @since 2.1.0
         -- @var string
         --
         Text_Direction : UStrings.UString :=
           UStrings.To_UString ("ltr");

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
         List_Item_Separator : UStrings.UString;

      end record;

   --
   -- Constructor which calls helper methods to set up object variables.
   --
   -- @since 2.1.0
   --
   function X_Construct
            return Wp_Locale;

   --
   -- Sets up the translated strings and object properties.
   --
   -- The method creates the translatable strings for various
   -- calendar elements. Which allows for specifying locale
   -- specific calendar names and text direction.
   --
   -- @since 2.1.0
   --
   -- @global string text_direction
   -- @global string wp_version     The WordPress version string.
   --
   procedure Init (This : Wp_Locale);

   --
   -- Global variables are deprecated.
   --
   -- For backward compatibility only.
   --
   -- @deprecated For backward compatibility only.
   --
   -- @global array weekday
   -- @global array weekday_initial
   -- @global array weekday_abbrev
   -- @global array month
   -- @global array month_abbrev
   --
   -- @since 2.1.0
   --
   procedure Register_Globals (This : Wp_Locale);

end Class_Locales;
