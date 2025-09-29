--
-- Classes, which help reading streams of data from files.
-- Based on the classes from Danilo Segan <danilo@kvota.net>
--
-- @version $Id: streams.php 1157 2015-11-20 04:30:11Z dd32 $
-- @package pomo
-- @subpackage streams
--

package body POMO_Streams
is
   procedure Dummy is null;

-- if ( ! class_exists( "POMO_Reader", false ) ) :
--         #[AllowDynamicProperties]
--         class POMO_Reader then

--                 public $endian = "little";
--                 public $_pos;
--                 public $is_overloaded;

   -- --
   -- -- PHP5 constructor.
   -- --
   -- function x_construct() then
   --                      if ( function_exists( "mb_substr" )
   --                              && ( (int) ini_get( "mbstring.func_overload" ) & 2 ) -- phpcs:ignore PHPCompatibility.IniDirectives.RemovedIniDirectives.mbstring_func_overloadDeprecated
   --                      ) then
   --                              $this->is_overloaded = true;
   --                      end; else then
   --                              $this->is_overloaded = false;
   --                      end;

   --                      $this->_pos = 0;
   --              end;

--                 --
--                 -- PHP4 constructor.
--                 --
--                 -- @deprecated 5.4.0 Use __construct() instead.
--                 --
--                 -- @see POMO_Reader::__construct()
--                 --
--                 public function POMO_Reader() then
--                         _deprecated_constructor( self::class, "5.4.0", static::class );
--                         self::__construct();
--                 end;

--                 --
--                 -- Sets the endianness of the file.
--                 --
--                 -- @param string $endian Set the endianness of the file. Accepts "big", or "little".
--                 --
--                 public function setEndian( $endian ) then -- phpcs:ignore WordPress.NamingConventions.ValidFunctionName.MethodNameInvalid
--                         $this->endian = $endian;
--                 end;

--                 --
--                 -- Reads a 32bit Integer from the Stream
--                 --
--                 -- @return mixed The integer, corresponding to the next 32 bits from
--                 --  the stream of false if there are not enough bytes or on error
--                 --
--                 public function readint32() then
--                         $bytes = $this->read( 4 );
--                         if ( 4 != $this->strlen( $bytes ) ) then
--                                 return false;
--                         end;
--                         $endian_letter = ( "big" === $this->endian ) ? "N" : "V";
--                         $int           = unpack( $endian_letter, $bytes );
--                         return reset( $int );
--                 end;

--                 --
--                 -- Reads an array of 32-bit Integers from the Stream
--                 --
--                 -- @param int $count How many elements should be read
--                 -- @return mixed Array of integers or false if there isn"t
--                 --  enough data or on error
--                 --
--                 public function readint32array( $count ) then
--                         $bytes = $this->read( 4-- $count );
--                         if ( 4-- $count != $this->strlen( $bytes ) ) then
--                                 return false;
--                         end;
--                         $endian_letter = ( "big" === $this->endian ) ? "N" : "V";
--                         return unpack( $endian_letter . $count, $bytes );
--                 end;

--                 --
--                 -- @param string $string
--                 -- @param int    $start
--                 -- @param int    $length
--                 -- @return string
--                 --
--                 public function substr( $string, $start, $length ) then
--                         if ( $this->is_overloaded ) then
--                                 return mb_substr( $string, $start, $length, "ascii" );
--                         end; else then
--                                 return substr( $string, $start, $length );
--                         end;
--                 end;

--                 --
--                 -- @param string $string
--                 -- @return int
--                 --
--                 public function strlen( $string ) then
--                         if ( $this->is_overloaded ) then
--                                 return mb_strlen( $string, "ascii" );
--                         end; else then
--                                 return strlen( $string );
--                         end;
--                 end;

--                 --
--                 -- @param string $string
--                 -- @param int    $chunk_size
--                 -- @return array
--                 --
--                 public function str_split( $string, $chunk_size ) then
--                         if ( ! function_exists( "str_split" ) ) then
--                                 $length = $this->strlen( $string );
--                                 $out    = array();
--                                 for ( $i = 0; $i < $length; $i += $chunk_size ) then
--                                         $out[] = $this->substr( $string, $i, $chunk_size );
--                                 end;
--                                 return $out;
--                         end; else then
--                                 return str_split( $string, $chunk_size );
--                         end;
--                 end;

--                 --
--                 -- @return int
--                 --
--                 public function pos() then
--                         return $this->_pos;
--                 end;

--                 --
--                 -- @return true
--                 --
--                 public function is_resource() then
--                         return true;
--                 end;

--                 --
--                 -- @return true
--                 --
--                 public function close() then
--                         return true;
--                 end;
--         end;
-- endif;

-- if ( ! class_exists( "POMO_FileReader", false ) ) :
--         class POMO_FileReader extends POMO_Reader then

--                 --
--                 -- File pointer resource.
--                 --
--                 -- @var resource|false
--                 --
--                 public $_f;

   --
   -- @param string $filename
   --
   function X_Construct (Filename : String)
                         return POMO_FileReader
   is
      This : POMO_FileReader;
   begin
--                        parent::__construct();
--                        $this->_f = fopen( $filename, "rb" );
      return This;
   end X_Construct;

--                 --
--                 -- PHP4 constructor.
--                 --
--                 -- @deprecated 5.4.0 Use __construct() instead.
--                 --
--                 -- @see POMO_FileReader::__construct()
--                 --
--                 public function POMO_FileReader( $filename ) then
--                         _deprecated_constructor( self::class, "5.4.0", static::class );
--                         self::__construct( $filename );
--                 end;

--                 --
--                 -- @param int $bytes
--                 -- @return string|false Returns read string, otherwise false.
--                 --
--                 public function read( $bytes ) then
--                         return fread( $this->_f, $bytes );
--                 end;

--                 --
--                 -- @param int $pos
--                 -- @return bool
--                 --
--                 public function seekto( $pos ) then
--                         if ( -1 == fseek( $this->_f, $pos, SEEK_SET ) ) then
--                                 return false;
--                         end;
--                         $this->_pos = $pos;
--                         return true;
--                 end;

--                 --
--                 -- @return bool
--                 --
--                 public function is_resource() then
--                         return is_resource( $this->_f );
--                 end;

--                 --
--                 -- @return bool
--                 --
--                 public function feof() then
--                         return feof( $this->_f );
--                 end;

--                 --
--                 -- @return bool
--                 --
--                 public function close() then
--                         return fclose( $this->_f );
--                 end;

--                 --
--                 -- @return string
--                 --
--                 public function read_all() then
--                         return stream_get_contents( $this->_f );
--                 end;
--         end;
-- endif;

-- if ( ! class_exists( "POMO_StringReader", false ) ) :
--         --
--         -- Provides file-like methods for manipulating a string instead
--         -- of a physical file.
--         --
--         class POMO_StringReader extends POMO_Reader then

--                 public $_str = "";

--                 --
--                 -- PHP5 constructor.
--                 --
--                 public function __construct( $str = "" ) then
--                         parent::__construct();
--                         $this->_str = $str;
--                         $this->_pos = 0;
--                 end;

--                 --
--                 -- PHP4 constructor.
--                 --
--                 -- @deprecated 5.4.0 Use __construct() instead.
--                 --
--                 -- @see POMO_StringReader::__construct()
--                 --
--                 public function POMO_StringReader( $str = "" ) then
--                         _deprecated_constructor( self::class, "5.4.0", static::class );
--                         self::__construct( $str );
--                 end;

--                 --
--                 -- @param string $bytes
--                 -- @return string
--                 --
--                 public function read( $bytes ) then
--                         $data        = $this->substr( $this->_str, $this->_pos, $bytes );
--                         $this->_pos += $bytes;
--                         if ( $this->strlen( $this->_str ) < $this->_pos ) then
--                                 $this->_pos = $this->strlen( $this->_str );
--                         end;
--                         return $data;
--                 end;

--                 --
--                 -- @param int $pos
--                 -- @return int
--                 --
--                 public function seekto( $pos ) then
--                         $this->_pos = $pos;
--                         if ( $this->strlen( $this->_str ) < $this->_pos ) then
--                                 $this->_pos = $this->strlen( $this->_str );
--                         end;
--                         return $this->_pos;
--                 end;

--                 --
--                 -- @return int
--                 --
--                 public function length() then
--                         return $this->strlen( $this->_str );
--                 end;

--                 --
--                 -- @return string
--                 --
--                 public function read_all() then
--                         return $this->substr( $this->_str, $this->_pos, $this->strlen( $this->_str ) );
--                 end;

--         end;
-- endif;

-- if ( ! class_exists( "POMO_CachedFileReader", false ) ) :
--         --
--         -- Reads the contents of the file in the beginning.
--         --
--         class POMO_CachedFileReader extends POMO_StringReader then
--                 --
--                 -- PHP5 constructor.
--                 --
--                 public function __construct( $filename ) then
--                         parent::__construct();
--                         $this->_str = file_get_contents( $filename );
--                         if ( false === $this->_str ) then
--                                 return false;
--                         end;
--                         $this->_pos = 0;
--                 end;

--                 --
--                 -- PHP4 constructor.
--                 --
--                 -- @deprecated 5.4.0 Use __construct() instead.
--                 --
--                 -- @see POMO_CachedFileReader::__construct()
--                 --
--                 public function POMO_CachedFileReader( $filename ) then
--                         _deprecated_constructor( self::class, "5.4.0", static::class );
--                         self::__construct( $filename );
--                 end;
--         end;
-- endif;

-- if ( ! class_exists( "POMO_CachedIntFileReader", false ) ) :
--         --
--         -- Reads the contents of the file in the beginning.
--         --
--         class POMO_CachedIntFileReader extends POMO_CachedFileReader then
--                 --
--                 -- PHP5 constructor.
--                 --
--                 public function __construct( $filename ) then
--                         parent::__construct( $filename );
--                 end;

--                 --
--                 -- PHP4 constructor.
--                 --
--                 -- @deprecated 5.4.0 Use __construct() instead.
--                 --
--                 -- @see POMO_CachedIntFileReader::__construct()
--                 --
--                 public function POMO_CachedIntFileReader( $filename ) then
--                         _deprecated_constructor( self::class, "5.4.0", static::class );
--                         self::__construct( $filename );
--                 end;
--         end;
-- endif;

end POMO_Streams;
