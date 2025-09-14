with Arrays;

package Inc_Formatting
is
   use Arrays;
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
