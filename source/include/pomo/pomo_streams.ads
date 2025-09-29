--
-- Classes, which help reading streams of data from files.
-- Based on the classes from Danilo Segan <danilo@kvota.net>
--
-- @version $Id: streams.php 1157 2015-11-20 04:30:11Z dd32 $
-- @package pomo
-- @subpackage streams
--

with Ada.Strings.Unbounded;

with Hb_Common;

package POMO_Streams
is
   use Ada.Strings.Unbounded;
   use Hb_Common;

   procedure Dummy;

-- if ( ! class_exists( "POMO_Reader", false ) ) :
--        #[AllowDynamicProperties]
   type POMO_Reader is tagged
      record
         endian        : Unbounded_String := +"little";
         X_Pos         : Integer;
         Is_Overloaded : Boolean;
      end record;

-- if ( ! class_exists( "POMO_FileReader", false ) ) :
   type POMO_FileReader is new POMO_Reader with
      record
                --
                -- File pointer resource.
                --
                -- @var resource|false
                --
                X_F : Integer;

      end record;

   --
   -- @param string $filename
   --
   function X_Construct (Filename : String)
                         return POMO_FileReader;

   --
   -- @return bool
   --
   function Is_Resource (This : POMO_FileReader)
                         return Boolean
                         is (True);

end POMO_Streams;
