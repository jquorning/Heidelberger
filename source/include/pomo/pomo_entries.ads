--
-- Contains Translation_Entry class
--
-- @version Id: entry.php 1157 2015-11-20 04:30:11Z dd32
-- @package pomo
-- @subpackage entry
--

with Arrays;
with UStrings;

package POMO_Entries
is
   use Arrays;

-- if ( ! class_exists( "Translation_Entry", false ) ) :

--         --
--         -- Translation_Entry class encapsulates a translatable string.
--         --
--         #[AllowDynamicProperties]
   type Translation_Entry is tagged
      record
         --
         -- Whether the entry contains a string and its plural form, default is false.
         --
         -- @var bool
         --
         Is_Plural : Boolean := False;

         Context             : UStrings.UString; -- null;
         Singular            : UStrings.UString; -- null;
         Plural              : UStrings.UString; -- null;
         Translations        : Array_Type;
         Translator_Comments : UStrings.UString;
         Extracted_Comments  : UStrings.UString;
         References          : Array_Type;
         Flags               : Array_Type;
      end record;

   --
   -- @param array args {
   --     Arguments array, supports the following keys:
   --
   --     @type string singular            The string to translate, if omitted an
   --                                       empty entry will be created.
   --     @type string plural              The plural form of the string, setting
   --                                       this will set `is_plural` to true.
   --     @type array  translations        Translations of the string and possibly
   --                                       its plural forms.
   --     @type string context             A string differentiating two equal strings
   --                                       used in different contexts.
   --     @type string translator_comments Comments left by translators.
   --     @type string extracted_comments  Comments left by developers.
   --     @type array  references          Places in the code this string is used, in
   --                                       relative_to_root_path/file.php:linenum form.
   --     @type array  flags               Flags like php-format.
   -- }
   --
   function X_Construct (Args : Array_Type := Empty_Array)
                         return Translation_Entry;
--                         // If no singular -- empty object.
--                         if ( ! isset( args["singular"] ) ) then
--                                 return;
--                         end;
--                         // Get member variable values from args hash.
--                         foreach ( args as varname => value ) then
--                                 this->varname = value;
--                         end;
--                         if ( isset( args["plural"] ) && args["plural"] ) then
--                                 this->is_plural = true;
--                         end;
--                         if ( ! is_array( this->translations ) ) then
--                                 this->translations = array();
--                         end;
--                         if ( ! is_array( this->references ) ) then
--                                 this->references = array();
--                         end;
--                         if ( ! is_array( this->flags ) ) then
--                                 this->flags = array();
--                         end;
--                 end;

--                 --
--                 -- PHP4 constructor.
--                 --
--                 -- @deprecated 5.4.0 Use __construct() instead.
--                 --
--                 -- @see Translation_Entry::__construct()
--                 --
--                 public function Translation_Entry( args = array() ) then
--                         _deprecated_constructor( self::class, "5.4.0", static::class );
--                         self::__construct( args );
--                 end;

   --
   -- Generates a unique key for this entry.
   --
   -- @return string|false The key or false if the entry is null.
   --
   function Key (This : Translation_Entry)
                 return String;
--                         if ( null === this->singular ) then
--                                 return false;
--                         end;

--                         // Prepend context and EOT, like in MO files.
--                         key = ! this->context ? this->singular : this->context . "\4" . this->singular;
--                         // Standardize on \n line endings.
--                         key = str_replace( array( "\r\n", "\r" ), "\n", key );

--                         return key;
--                 end;

--                 --
--                 -- @param object other
--                 --
--                 public function merge_with( &other ) then
--                         this->flags      = array_unique( array_merge( this->flags, other->flags ) );
--                         this->references = array_unique( array_merge( this->references, other->references ) );
--                         if ( this->extracted_comments != other->extracted_comments ) then
--                                 this->extracted_comments .= other->extracted_comments;
--                         end;

--                 end;
--         end;

-- endif;

   Null_Translation_Entry : constant Translation_Entry :=
     (Is_Plural                   => False,
      Context | Singular | Plural => UStrings.Null_UString,
      Translations                => Empty_Array,
      Translator_Comments         => UStrings.Null_UString,
      Extracted_Comments          => UStrings.Null_UString,
      References | Flags          => Empty_Array
   );

end POMO_Entries;
