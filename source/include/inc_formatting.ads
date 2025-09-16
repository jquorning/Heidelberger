with Arrays;

package Inc_Formatting
is
   use Arrays;

--
-- Replaces common plain text characters with formatted entities.
--
-- Returns given text with transformations of quotes into smart quotes, apostrophes,
-- dashes, ellipses, the trademark symbol, and the multiplication symbol.
--
-- As an example,
--
--     "cause today"s effort makes it worth tomorrow"s "holiday" ...
--
-- Becomes:
--
--     &#8217;cause today&#8217;s effort makes it worth tomorrow&#8217;s &#8220;holiday&#8221; &#8230;
--
-- Code within certain HTML blocks are skipped.
--
-- Do not use this function before the {@see "init"end; action hook; everything will break.
--
-- @since 0.71
--
-- @global array wp_cockneyreplace Array of formatted entities for certain common phrases.
-- @global array shortcode_tags
--
-- @param string text  The text to be formatted.
-- @param bool   reset Set to true for unit testing. Translated patterns will reset.
-- @return string The string replaced with HTML entities.
--
   function Wptexturize (Text  : String;
                         Reset : Boolean := False)
                         return String
                         is ("XXX-310");

--
-- Parses a string into variables to be stored in an array.
--
-- @since 2.2.1
--
-- @param string $string The string to be parsed.
-- @param array  $array  Variables will be stored in this array.
--
   procedure Wp_Parse_Str (Str  :     String;
                           Arry : out Array_type);

--
-- Sanitizes an HTML classname to ensure it only contains valid characters.
--
-- Strips the string down to A-Z,a-z,0-9,_,-. If this results in an empty
-- string then it will return the alternative value supplied.
--
-- @todo Expand to support the full range of CDATA that a class attribute can contain.
--
-- @since 2.8.0
--
-- @param string class    The classname to be sanitized
-- @param string fallback Optional. The value to return if the sanitization ends up as an empty string.
--  Defaults to an empty string.
-- @return string The sanitized value
--
   function Sanitize_Html_Class (Class    : String;
                                 Fallback : String := "")
                                 return String
                                 is ("XXX-304");

end Inc_Formatting;
