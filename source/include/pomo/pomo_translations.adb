--
-- Class for a set of entries for translation and their associated headers
--
-- @version $Id: translations.php 1157 2015-11-20 04:30:11Z dd32 $
-- @package pomo
-- @subpackage translations
--

with Hb_Common;

package body POMO_Translations
is
   procedure Dummy is null;

-- -- require_once __DIR__ . "/plural-forms.php";
-- -- require_once __DIR__ . "/entry.php";

-- if ( ! class_exists( "Translations", false ) ) :
--         #[AllowDynamicProperties]
--         class Translations then
--                 public entries = array();
--                 public headers = array();

--                 --
--                 -- Add entry to the PO structure
--                 --
--                 -- @param array|Translation_Entry entry
--                 -- @return bool true on success, false if the entry doesn"t have a key
--                 --
--                 public function add_entry( entry ) then
--                         if ( is_array( entry ) ) then
--                                 entry = new Translation_Entry( entry );
--                         end;
--                         key = entry->key();
--                         if ( false === key ) then
--                                 return false;
--                         end;
--                         this->entries[ key ] = &entry;
--                         return true;
--                 end;

--                 --
--                 -- @param array|Translation_Entry entry
--                 -- @return bool
--                 --
--                 public function add_entry_or_merge( entry ) then
--                         if ( is_array( entry ) ) then
--                                 entry = new Translation_Entry( entry );
--                         end;
--                         key = entry->key();
--                         if ( false === key ) then
--                                 return false;
--                         end;
--                         if ( isset( this->entries[ key ] ) ) then
--                                 this->entries[ key ]->merge_with( entry );
--                         end; else then
--                                 this->entries[ key ] = &entry;
--                         end;
--                         return true;
--                 end;

--                 --
--                 -- Sets header PO header to value
--                 --
--                 -- If the header already exists, it will be overwritten
--                 --
--                 -- TODO: this should be out of this class, it is gettext specific
--                 --
--                 -- @param string header header name, without trailing :
--                 -- @param string value header value, without trailing \n
--                 --
--                 public function set_header( header, value ) then
--                         this->headers[ header ] = value;
--                 end;

--                 --
--                 -- @param array headers
--                 --
--                 public function set_headers( headers ) then
--                         foreach ( headers as header => value ) then
--                                 this->set_header( header, value );
--                         end;
--                 end;

--                 --
--                 -- @param string header
--                 --
--                 public function get_header( header ) then
--                         return isset( this->headers[ header ] ) ? this->headers[ header ] : false;
--                 end;

   ---------------------
   -- Translate_Entry --
   ---------------------

   function Translate_Entry (This  : Translations;
                             Entri : POMO_Entries.Translation_Entry)
                             return POMO_Entries.Translation_Entry -- String
   is
--    use Hb_Common;

      Key : constant String := Entri.Key; -- ();
   begin
      return
        (if Isset (This.Entries, Key)
         then POMO_Entries.Null_Translation_Entry -- This.Entries (Key)
         else POMO_Entries.Null_Translation_Entry); -- False);
   end Translate_Entry;

   ---------------
   -- Translate --
   ---------------

   function Translate (This     : Translations;
                       Singular : String;
                       Context  : String := "") -- null
                       return String
   is
      use Hb_Common;
      use POMO_Entries;

      Entri : constant Translation_Entry :=
        X_Construct (
          To_Array (List => (
            Build ("singular", Singular),
            Build ("context",  Context)
          ))
        );
      Translated : constant Translation_Entry := This.Translate_Entry (Entri);
--    Translated : constant String := This.Translate_Entry (Entri);
   begin
      return
        (if
          Translated /= Null_Translation_Entry and then
          not Empty (Translated.Translations)
         then As_String (Translated.Translations.First_Element) else Singular);
--       then Translated.Translations (0) else Singular);
   end Translate;

--                 --
--                 -- Given the number of items, returns the 0-based index of the plural form to use
--                 --
--                 -- Here, in the base Translations class, the common logic for English is implemented:
--                 --  0 if there is one element, 1 otherwise
--                 --
--                 -- This function should be overridden by the subclasses. For example MO/PO can derive the logic
--                 -- from their headers.
--                 --
--                 -- @param int count number of items
--                 --
--                 public function select_plural_form( count ) then
--                         return 1 == count ? 0 : 1;
--                 end;

--                 --
--                 -- @return int
--                 --
--                 public function get_plural_forms_count() then
--                         return 2;
--                 end;

--                 --
--                 -- @param string singular
--                 -- @param string plural
--                 -- @param int    count
--                 -- @param string context
--                 --
--                 public function translate_plural( singular, plural, count, context = null ) then
--                         entry              = new Translation_Entry(
--                                 array(
--                                         "singular" => singular,
--                                         "plural"   => plural,
--                                         "context"  => context,
--                                 )
--                         );
--                         translated         = this->translate_entry( entry );
--                         index              = this->select_plural_form( count );
--                         total_plural_forms = this->get_plural_forms_count();
--                         if ( translated && 0 <= index && index < total_plural_forms &&
--                                 is_array( translated->translations ) &&
--                                 isset( translated->translations[ index ] ) ) then
--                                 return translated->translations[ index ];
--                         end; else then
--                                 return 1 == count ? singular : plural;
--                         end;
--                 end;

--                 --
--                 -- Merge other in the current object.
--                 --
--                 -- @param Object other Another Translation object, whose translations will be merged in this one (passed by reference).
--                 --
--                 public function merge_with( &other ) then
--                         foreach ( other->entries as entry ) then
--                                 this->entries[ entry->key() ] = entry;
--                         end;
--                 end;

--                 --
--                 -- @param object other
--                 --
--                 public function merge_originals_with( &other ) then
--                         foreach ( other->entries as entry ) then
--                                 if ( ! isset( this->entries[ entry->key() ] ) ) then
--                                         this->entries[ entry->key() ] = entry;
--                                 end; else then
--                                         this->entries[ entry->key() ]->merge_with( entry );
--                                 end;
--                         end;
--                 end;
--         end;

--                 -- The gettext implementation of select_plural_form.
--                 --
--                 -- It lives in this class, because there are more than one descendand, which will use it and
--                 -- they can"t share it effectively.
--                 --
--                 -- @param int count
--                 --
--                 public function gettext_select_plural_form( count ) then
--                         if ( ! isset( this->_gettext_select_plural_form ) || is_null( this->_gettext_select_plural_form ) ) then
--                                 list( nplurals, expression )     = this->nplurals_and_expression_from_header( this->get_header( "Plural-Forms" ) );
--                                 this->_nplurals                   = nplurals;
--                                 this->_gettext_select_plural_form = this->make_plural_form_function( nplurals, expression );
--                         end;
--                         return call_user_func( this->_gettext_select_plural_form, count );
--                 end;

--                 --
--                 -- @param string header
--                 -- @return array
--                 --
--                 public function nplurals_and_expression_from_header( header ) then
--                         if ( preg_match( "/^\s*nplurals\s*=\s*(\d+)\s*;\s+plural\s*=\s*(.+)/", header, matches ) ) then
--                                 nplurals   = (int) matches[1];
--                                 expression = trim( matches[2] );
--                                 return array( nplurals, expression );
--                         end; else then
--                                 return array( 2, "n != 1" );
--                         end;
--                 end;

--                 --
--                 -- Makes a function, which will return the right translation index, according to the
--                 -- plural forms header
--                 --
--                 -- @param int    nplurals
--                 -- @param string expression
--                 --
--                 public function make_plural_form_function( nplurals, expression ) then
--                         try then
--                                 handler = new Plural_Forms( rtrim( expression, ";" ) );
--                                 return array( handler, "get" );
--                         end; catch ( Exception e ) then
--                                 // Fall back to default plural-form function.
--                                 return this->make_plural_form_function( 2, "n != 1" );
--                         end;
--                 end;

--                 --
--                 -- Adds parentheses to the inner parts of ternary operators in
--                 -- plural expressions, because PHP evaluates ternary oerators from left to right
--                 --
--                 -- @param string expression the expression without parentheses
--                 -- @return string the expression with parentheses added
--                 --
--                 public function parenthesize_plural_exression( expression ) then
--                         expression .= ";";
--                         res         = "";
--                         depth       = 0;
--                         for ( i = 0; i < strlen( expression ); ++i ) then
--                                 char = expression[ i ];
--                                 switch ( char ) then
--                                         case "?":
--                                                 res .= " ? (";
--                                                 depth++;
--                                                 break;
--                                         case ":":
--                                                 res .= ") : (";
--                                                 break;
--                                         case ";":
--                                                 res  .= str_repeat( ")", depth ) . ";";
--                                                 depth = 0;
--                                                 break;
--                                         default:
--                                                 res .= char;
--                                 end;
--                         end;
--                         return rtrim( res, ";" );
--                 end;

--                 --
--                 -- @param string translation
--                 -- @return array
--                 --
--                 public function make_headers( translation ) then
--                         headers = array();
--                         // Sometimes \n"s are used instead of real new lines.
--                         translation = str_replace( "\n", "\n", translation );
--                         lines       = explode( "\n", translation );
--                         foreach ( lines as line ) then
--                                 parts = explode( ":", line, 2 );
--                                 if ( ! isset( parts[1] ) ) then
--                                         continue;
--                                 end;
--                                 headers[ trim( parts[0] ) ] = trim( parts[1] );
--                         end;
--                         return headers;
--                 end;

--                 --
--                 -- @param string header
--                 -- @param string value
--                 --
--                 public function set_header( header, value ) then
--                         parent::set_header( header, value );
--                         if ( "Plural-Forms" === header ) then
--                                 list( nplurals, expression )     = this->nplurals_and_expression_from_header( this->get_header( "Plural-Forms" ) );
--                                 this->_nplurals                   = nplurals;
--                                 this->_gettext_select_plural_form = this->make_plural_form_function( nplurals, expression );
--                         end;
--                 end;
--         end;
-- endif;

-- if ( ! class_exists( "NOOP_Translations", false ) ) :
--         --
--         -- Provides the same interface as Translations, but doesn't do anything
--         --
--         #[AllowDynamicProperties]
--         class NOOP_Translations then
--                 public entries = array();
--                 public headers = array();

--                 public function add_entry( entry ) then
--                         return true;
--                 end;

--                 --
--                 -- @param string header
--                 -- @param string value
--                 --
--                 public function set_header( header, value ) then
--                 end;

--                 --
--                 -- @param array headers
--                 --
--                 public function set_headers( headers ) then
--                 end;

--                 --
--                 -- @param string header
--                 -- @return false
--                 --
--                 public function get_header( header ) then
--                         return false;
--                 end;

--                 --
--                 -- @param Translation_Entry entry
--                 -- @return false
--                 --
--                 public function translate_entry( &entry ) then
--                         return false;
--                 end;

--                 --
--                 -- @param string singular
--                 -- @param string context
--                 --
--                 public function translate( singular, context = null ) then
--                         return singular;
--                 end;

--                 --
--                 -- @param int count
--                 -- @return bool
--                 --
--                 public function select_plural_form( count ) then
--                         return 1 == count ? 0 : 1;
--                 end;

--                 --
--                 -- @return int
--                 --
--                 public function get_plural_forms_count() then
--                         return 2;
--                 end;

--                 --
--                 -- @param string singular
--                 -- @param string plural
--                 -- @param int    count
--                 -- @param string context
--                 --
--                 public function translate_plural( singular, plural, count, context = null ) then
--                         return 1 == count ? singular : plural;
--                 end;

--                 --
--                 -- @param object other
--                 --
--                 public function merge_with( &other ) then
--                 end;
--         end;
-- endif;

end POMO_Translations;
