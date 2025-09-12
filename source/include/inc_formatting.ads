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


end Inc_Formatting;
