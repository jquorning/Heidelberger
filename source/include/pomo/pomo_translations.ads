--
-- Class for a set of entries for translation and their associated headers
--
-- @version $Id: translations.php 1157 2015-11-20 04:30:11Z dd32 $
-- @package pomo
-- @subpackage translations
--

with Arrays;

with POMO_Entries;

-- require_once __DIR__ . '/plural-forms.php';
-- require_once __DIR__ . '/entry.php';

package POMO_Translations
is
   use Arrays;

   procedure Dummy;

-- if ( ! class_exists( 'Translations', false ) ) :
--        #[AllowDynamicProperties]
   type Translations is tagged
     record
        Entries : Array_Type;
        Headers : Array_Type;
     end record;

   --
   -- @param Translation_Entry entry
   --
   function Translate_Entry (This  : Translations;
                             Entri : POMO_Entries.Translation_Entry)
--                           Entri : in out POMO_Entries.Translation_Entry)
                             return POMO_Entries.Translation_Entry; -- String

   --
   -- @param string $singular
   -- @param string $context
   -- @return string
   --
   function Translate (This     : Translations;
                       Singular : String;
                       Context  : String := "") -- null
                       return String;

   --
   -- Merge $other in the current object.
   --
   -- @param Object $other Another Translation object, whose translations will be
   --                      merged in this one (passed by reference).
   --
   procedure Merge_With (This : in out Translations;
                         That : Translations)
                         is null;

   Null_Translations : constant Translations :=
     (Empty_Array, Empty_Array);

   type Gettext_Translations is new Translations with
      record
         --
         -- Number of plural forms.
         --
         -- @var int
         --
         X_Nplurals : Integer;

         --
         -- Callback to retrieve the plural form.
         --
         -- @var callable
         --
         -- public $_gettext_select_plural_form;

      end record;

end POMO_Translations;
