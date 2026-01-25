--
-- Class for working with MO files
--
-- @version Id: mo.php 1157 2015-11-20 04:30:11Z dd32
-- @package pomo
-- @subpackage mo
--

with UStrings;

with POMO_Streams;
with POMO_Translations;

-- require_once __DIR__ . '/translations.php';
-- require_once __DIR__ . '/streams.php';

package POMO_MO
is

-- if ( ! class_exists( 'MO', false ) ) :
   type MO is new POMO_Translations.Gettext_Translations with
      record
         --
         -- Number of plural forms.
         --
         -- @var int
         --
         XX_Nplurals : Integer := 2; -- conflict

         --
         -- Loaded MO file.
         --
         -- @var string
         --
         -- private
         Filename : UStrings.UString;

      end record;

   --
   -- Fills up with the entries from MO file filename
   --
   -- @param string filename MO file to load
   -- @return bool True if the import from file was successful, otherwise false.
   --
   function Import_From_File (This     : in out MO;
                              Filename : String)
                              return Boolean;

   --
   -- @param POMO_FileReader reader
   -- @return bool True if the import was successful, otherwise false.
   --
   function Import_From_Reader (This   : in out MO;
                                Reader : POMO_Streams.POMO_FileReader)
                                return Boolean
                                is (False);

end POMO_MO;
