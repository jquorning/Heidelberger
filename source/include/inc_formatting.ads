--
-- Main WordPress Formatting API.
--
-- Handles many functions for formatting output.
--
-- @package WordPress
--

with Php;
with Php.HTML;

with Arrays;
with Helpers_2;
with Lists;

package Inc_Formatting
is
   use Arrays;
   use Lists;

   --
   -- Replaces common plain text characters with formatted entities.
   --
   -- Returns given text with transformations of quotes into smart quotes, apostrophes,
   -- dashes, ellipses, the trademark symbol, and the multiplication symbol.
   --
   -- As an example,
   --
   --     "cause today's effort makes it worth tomorrow's "holiday" ...
   --
   -- Becomes:
   --
   --     &#8217;cause today&#8217;s effort makes it worth tomorrow&#8217;s
   --     &#8220;holiday&#8221; &#8230;
   --
   -- Code within certain HTML blocks are skipped.
   --
   -- Do not use this function before the {@see "init"} action hook; everything
   -- will break.
   --
   -- @since 0.71
   --
   -- @global array wp_cockneyreplace Array of formatted entities for certain common
   --                                 phrases.
   -- @global array shortcode_tags
   --
   -- @param string text  The text to be formatted.
   -- @param bool   reset Set to true for unit testing. Translated patterns will reset.
   -- @return string The string replaced with HTML entities.
   --
   function Wp_Texturize (Text  : String;
                          Reset : Boolean := False)
                          return String;

   --
   -- Implements a logic tree to determine whether or not "7"." represents seven feet,
   -- then converts the special char into either a prime char or a closing quote char.
   --
   -- @since 4.3.0
   --
   -- @param string haystack    The plain text to be searched.
   -- @param string needle      The character to search for such as " or ".
   -- @param string prime       The prime char to use for replacement.
   -- @param string open_quote  The opening quote char. Opening quote replacement
   --                           must be accomplished already.
   -- @param string close_quote The closing quote char to use for replacement.
   -- @return string The haystack value after primes and quotes replacements.
   --
   function Wptexturize_Primes (Haystack    : String;
                                Needle      : String;
                                Prime       : String;
                                Open_Quote  : String;
                                Close_Quote : String)
                                return String;

   --
   -- Searches for disabled element tags. Pushes element to stack on tag open
   -- and pops on tag close.
   --
   -- Assumes first char of `text` is tag opening and last char is tag closing.
   -- Assumes second char of `text` is optionally `/` to indicate closing as in
   -- `</html>`.
   --
   -- @since 2.9.0
   -- @access private
   --
   -- @param string   text              Text to check. Must be a tag like `<html>`
   --                                   or `[shortcode]`.
   -- @param string[] stack             Array of open tag elements.
   -- @param string[] disabled_elements Array of tag names to match against. Spaces
   --                                   are not allowed in tag names.
   --
   procedure X_Wptexturize_Pushpop_Element
               (Text              : String;
                Stack             : in out List_Type;
                Disabled_Elements : List_Type);

   --
   -- Retrieves the regular expression for shortcodes.
   --
   -- @access private
   -- @ignore
   -- @since 4.4.0
   --
   -- @param string[] tagnames Array of shortcodes to find.
   -- @return string The regular expression
   --
   function X_Get_Wptexturize_Shortcode_Regex (Tagnames : List_Type)
                                               return String;

   --
   -- Retrieves the combined regular expression for HTML and shortcodes.
   --
   -- @access private
   -- @ignore
   -- @internal This function will be removed in 4.5.0 per Shortcode API Roadmap.
   -- @since 4.4.0
   --
   -- @param string shortcode_regex Optional. The result from
   --                                _get_wptexturize_shortcode_regex().
   -- @return string The regular expression
   --
   function X_Get_Wptexturize_Split_Regex (Shortcode_Regex : String := "")
                                           return String;

   --
   -- Parses a string into variables to be stored in an array.
   --
   -- @since 2.2.1
   --
   -- @param string $string The string to be parsed.
   -- @param array  $array  Variables will be stored in this array.
   --
   procedure Wp_Parse_Str (Str  :     String;
                           Arry : out Array_Type);

   --
   -- Converts lone less than signs.
   --
   -- KSES already converts lone greater than signs.
   --
   -- @since 2.3.0
   --
   -- @param string text Text to be converted.
   -- @return string Converted text.
   --
   function Wp_Pre_KSES_Less_Than (Text : String)
                                   return String;

   --
   -- Callback function used by preg_replace.
   --
   -- @since 2.3.0
   --
   -- @param string[] matches Populated by matches to preg_replace.
   -- @return string The text returned after esc_html if needed.
   --
   function Wp_Pre_KSES_Less_Than_Callback (Matches : List_Type)
                                            return String;

   --
   -- Converts a number of special characters into their HTML entities.
   --
   -- Specifically deals with: `&`, `<`, `>`, `"`, and `"`.
   --
   -- `quote_style` can be set to ENT_COMPAT to encode `"` to
   -- `&quot;`, or ENT_QUOTES to do both. Default is ENT_NOQUOTES where no quotes are
   -- encoded.
   --
   -- @since 1.2.2
   -- @since 5.5.0 `quote_style` also accepts `ENT_XML1`.
   -- @access private
   --
   -- @param string       string        The text which is to be encoded.
   -- @param int|string   quote_style   Optional. Converts double quotes if set to
   --                                   ENT_COMPAT, both single and double if set to
   --                                   ENT_QUOTES or none if set to ENT_NOQUOTES.
   --                                   Converts single and double quotes, as well as
   --                                   converting HTML named entities (that are not
   --                                   also XML named entities) to their code points
   --                                   if set to ENT_XML1. Also compatible with old
   --                                   values; converting single quotes if set to
   --                                   "single", double if set to "double" or both
   --                                   if otherwise set. Default is ENT_NOQUOTES.
   -- @param false|string charset       Optional. The character encoding of the
   --                                   string. Default false.
   -- @param bool         double_encode Optional. Whether to encode existing HTML
   --                                   entities. Default false.
   -- @return string The encoded text with HTML entities.
   --
   function X_Wp_Specialchars
              (Item          : String;
               Quote_Style   : Php.HTML.Flag_Type := Php.HTML.ENT_NOQUOTES;
               Charset       : String  := ""; -- Boolean := False;
               Double_Encode : Boolean := False)
               return String;

   --
   -- Sanitizes an HTML classname to ensure it only contains valid characters.
   --
   -- Strips the string down to A-Z,a-z,0-9,_,-. If this results in an empty
   -- string then it will return the alternative value supplied.
   --
   -- @todo Expand to support the full range of CDATA that a class attribute can
   --       contain.
   --
   -- @since 2.8.0
   --
   -- @param string class    The classname to be sanitized
   -- @param string fallback Optional. The value to return if the sanitization ends
   --                        up as an empty string. Defaults to an empty string.
   -- @return string The sanitized value
   --
   function Sanitize_HTML_Class (Class    : String;
                                 Fallback : String := "")
                                 return String;

   --
   -- Sanitizes a URL for database or redirect usage.
   --
   -- @since 2.3.1
   -- @since 2.8.0 Deprecated in favor of esc_url_raw().
   -- @since 5.9.0 Restored (un-deprecated).
   --
   -- @see esc_url()
   --
   -- @param string   url       The URL to be cleaned.
   -- @param string[] protocols Optional. An array of acceptable protocols.
   --                            Defaults to return value of wp_allowed_protocols().
   -- @return string The cleaned URL after esc_url() is run with the "db" context.
   --
   function Sanitize_URL (URL       : String;
                          Protocols : List_Type := Empty_List)
                          return String;

   --
   -- Sanitizes a string into a slug, which can be used in URLs or HTML attributes.
   --
   -- By default, converts accent characters to ASCII characters and further
   -- limits the output to alphanumeric characters, underscore (_) and dash (-)
   -- through the {@see "sanitize_title"} filter.
   --
   -- If `title` is empty and `fallback_title` is set, the latter will be used.
   --
   -- @since 1.0.0
   --
   -- @param string title          The string to be sanitized.
   -- @param string fallback_title Optional. A title to use if title is empty. Default
   --                              empty.
   -- @param string context        Optional. The operation for which the string is
   --                              sanitized. When set to "save", the string runs
   --                              through remove_accents(). Default "save".
   -- @return string The sanitized string.
   --
   function Sanitize_Title (Title          : String;
                            Fallback_Title : String := "";
                            Context        : String := "save")
                            return String;

   --
   -- Sanitizes a username, stripping out unsafe characters.
   --
   -- Removes tags, octets, entities, and if strict is enabled, will only keep
   -- alphanumeric, _, space, ., -, @. After sanitizing, it passes the username,
   -- raw username (the username in the parameter), and the value of strict as
   -- parameters for the {@see "sanitize_user"} filter.
   --
   -- @since 2.0.0
   --
   -- @param string username The username to be sanitized.
   -- @param bool   strict   Optional. If set limits username to specific characters.
   --                         Default false.
   -- @return string The sanitized username, after passing through filters.
   --
   function Sanitize_User (Username : String;
                           Strict   : Boolean := False)
                           return String;

   --
   -- Sanitizes a title with the "query" context.
   --
   -- Used for querying the database for a value from URL.
   --
   -- @since 3.1.0
   --
   -- @param string title The string to be sanitized.
   -- @return string The sanitized string.
   --
   function Sanitize_Title_For_Query (Title : String)
                                      return String;

   --
   -- Sanitizes a title, replacing whitespace and a few other characters with dashes.
   --
   -- Limits the output to alphanumeric characters, underscore (_) and dash (-).
   -- Whitespace becomes a dash.
   --
   -- @since 1.2.0
   --
   -- @param string title     The title to be sanitized.
   -- @param string raw_title Optional. Not used. Default empty.
   -- @param string context   Optional. The operation for which the string is
   --                          sanitized- When set to "save", additional entities
   --                          are converted to hyphens or stripped entirely. Default
   --                          "display".
   -- @return string The sanitized title.
   --
   function Sanitize_Title_With_Dashes (Title     : String;
                                        Raw_Title : String := "";
                                        Context   : String := "display")
                                        return String;

   --
   -- Performs a deep string replace operation to ensure the values in search are
   -- no longer present.
   --
   -- Repeats the replacement operation until it no longer replaces anything so as
   -- to remove "nested" values e.g. subject = "%0%0%0DDD", search ="%0D",
   -- result ="" rather than the "%0%0DD" that str_replace would return
   --
   -- @since 2.8.1
   -- @access private
   --
   -- @param string|array search  The value being searched for, otherwise known as
   --                              the needle. An array may be used to designate
   --                              multiple needles.
   -- @param string       subject The string being searched and replaced on,
   --                              otherwise known as the haystack.
   -- @return string The string with the replaced values.
   --
   function X_Deep_Replace (Search  : List_Type;
                            Subject : String)
                            return String;

   --
   -- Checks and cleans a URL.
   --
   -- A number of characters are removed from the URL. If the URL is for displaying
   -- (the default behaviour) ampersands are also replaced. The {@see "clean_url"}
   -- filter is applied to the returned cleaned URL.
   --
   -- @since 2.8.0
   --
   -- @param string   url       The URL to be cleaned.
   -- @param string[] protocols Optional. An array of acceptable protocols.
   --                            Defaults to return value of wp_allowed_protocols().
   -- @param string   _context  Private. Use sanitize_url() for database usage.
   -- @return string The cleaned URL after the {@see "clean_url"} filter is applied.
   --                An empty string is returned if `url` specifies a protocol other
   --                than those in `protocols`, or if `url` contains an empty string.
   --
   function ESC_URL (URL       : String;
                     Protocols : List_Type := Empty_List;
                     X_Context : String    := "display")
                    return String;

   --
   -- Sanitizes a URL for database or redirect usage.
   --
   -- This function is an alias for sanitize_url().
   --
   -- @since 2.8.0
   -- @since 6.1.0 Turned into an alias for sanitize_url().
   --
   -- @see sanitize_url()
   --
   -- @param string   url       The URL to be cleaned.
   -- @param string[] protocols Optional. An array of acceptable protocols.
   --                            Defaults to return value of wp_allowed_protocols().
   -- @return string The cleaned URL after sanitize_url() is run.
   --
   function ESC_URL_Raw (URL       : String;
                         Protocols : List_Type := Empty_List) -- null
                         return String;

   --
   -- Navigates through an array, object, or scalar, and removes slashes from
   -- the values.
   --
   -- @since 2.0.0
   --
   -- @param mixed value The value to be stripped.
   -- @return mixed Stripped value.
   --
   function Strip_Slashes_Deep (Value : Array_Type)
                                return Array_Type;

   function Strip_Slashes_Deep (Value : String)
                                return String;

   --
   -- Callback function for `stripslashes_deep()` which strips slashes from strings.
   --
   -- @since 4.4.0
   --
   -- @param mixed value The array or string to be stripped.
   -- @return mixed The stripped value.
   --
   function Strip_Slashes_From_Strings_Only (Value : String)
                                             return String;

   --
   -- Navigates through an array, object, or scalar, and encodes the values to be used
   -- in a URL.
   --
   -- @since 2.2.0
   --
   -- @param mixed value The array or string to be encoded.
   -- @return mixed The encoded value.
   --
   function URL_Encode_Deep (Value : Array_Type)
                             return Array_Type;

   function URL_Encode_Deep (Value : String)
                             return String;

   --
   -- Navigates through an array, object, or scalar, and raw-encodes the values to be
   -- used in a URL.
   --
   -- @since 3.4.0
   --
   -- @param mixed value The array or string to be encoded.
   -- @return mixed The encoded value.
   --
   function Raw_URL_Encode_Deep (Value : Array_Type)
                                 return Array_Type;

   --
   -- Escapes single quotes, `"`, `<`, `>`, `&`, and fixes line endings.
   --
   -- Escapes text strings for echoing in JS. It is intended to be used for inline JS
   -- (in a tag attribute, for example `onclick="..."`). Note that the strings have to
   -- be in single quotes. The {@see "js_escape"} filter is also applied here.
   --
   -- @since 2.8.0
   --
   -- @param string text The text to be escaped.
   -- @return string Escaped text.
   --
   function ESC_JS (Text : String)
                    return String;

   --
   -- Escaping for HTML blocks.
   --
   -- @since 2.8.0
   --
   -- @param string text
   -- @return string
   --
   function ESC_HTML (Item : String)
                      return String;

   --
   -- Escaping for HTML attributes.
   --
   -- @since 2.8.0
   --
   -- @param string text
   -- @return string
   --
   function ESC_Attr (Text : String)
                      return String;

   --
   -- Converts full URL paths to absolute paths.
   --
   -- Removes the http or https protocols and the domain. Keeps the path "/" at the
   -- beginning, so it isn"t a true relative link, but from the web root base.
   --
   -- @since 2.1.0
   -- @since 4.1.0 Support was added for relative URLs.
   --
   -- @param string link Full URL path.
   -- @return string Absolute path.
   --
   function Wp_Make_Link_Relative (Link : String)
                                   return String;

   --
   -- Sanitizes various option values based on the nature of the option.
   --
   -- This is basically a switch statement which will pass value through a number
   -- of functions depending on the option.
   --
   -- @since 2.0.5
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string option The name of the option.
   -- @param string value  The unsanitised value.
   -- @return string Sanitized value.
   --
   function Sanitize_Option (Option : String;
                             Value  : String)
                             return String;

   --
   -- Escapes data for use in a MySQL query.
   --
   -- Usually you should prepare queries using wpdb::prepare().
   -- Sometimes, spot-escaping is required or useful. One example
   -- is preparing an array for use in an IN clause.
   --
   -- NOTE: Since 4.8.3, "%" characters will be replaced with a placeholder string,
   -- this prevents certain SQLi attacks from taking place. This change in behaviour
   -- may cause issues for code that expects the return value of esc_sql() to be
   -- useable for other purposes.
   --
   -- @since 2.8.0
   --
   -- @global wpdb wpdb WordPress database abstraction object.
   --
   -- @param string|array data Unescaped data.
   -- @return string|array Escaped data, in the same type as supplied.
   --
   function ESC_SQL (Data : List_Type)
                     return List_Type
   is (raise Program_Error with "not implemented");

   function ESC_SQL (Data : String)
                     return String;

   --
   -- Checks for invalid UTF8 in a string.
   --
   -- @since 2.8.0
   --
   -- @param string string The text which is to be checked.
   -- @param bool   strip  Optional. Whether to attempt to strip out invalid UTF8.
   --                      Default false.
   -- @return string The checked text.
   --
   function Wp_Check_Invalid_UTF8 (Item  : String;
                                   Strip : Boolean := False)
                                   return String;

   --
   -- Converts all accent characters to ASCII characters.
   --
   -- If there are no accent characters, then the string given is just returned.
   --
   ----*Accent characters converted:**
   --
   -- Currency signs:
   --
   -- |   Code   | Glyph | Replacement |     Description     |
   -- | -------- | ----- | ----------- | ------------------- |
   -- | U+00A3   | £     | (empty)     | British Pound sign  |
   -- | U+20AC   | €     | E           | Euro sign           |
   --
   -- Decompositions for Latin-1 Supplement:
   --
   -- |  Code   | Glyph | Replacement |               Description              |
   -- | ------- | ----- | ----------- | -------------------------------------- |
   -- | U+00AA  | ª     | a           | Feminine ordinal indicator             |
   -- | U+00BA  | º     | o           | Masculine ordinal indicator            |
   -- | U+00C0  | À     | A           | Latin capital letter A with grave      |
   -- | U+00C1  | Á     | A           | Latin capital letter A with acute      |
   -- | U+00C2  | Â     | A           | Latin capital letter A with circumflex |
   -- | U+00C3  | Ã     | A           | Latin capital letter A with tilde      |
   -- | U+00C4  | Ä     | A           | Latin capital letter A with diaeresis  |
   -- | U+00C5  | Å     | A           | Latin capital letter A with ring above |
   -- | U+00C6  | Æ     | AE          | Latin capital letter AE                |
   -- | U+00C7  | Ç     | C           | Latin capital letter C with cedilla    |
   -- | U+00C8  | È     | E           | Latin capital letter E with grave      |
   -- | U+00C9  | É     | E           | Latin capital letter E with acute      |
   -- | U+00CA  | Ê     | E           | Latin capital letter E with circumflex |
   -- | U+00CB  | Ë     | E           | Latin capital letter E with diaeresis  |
   -- | U+00CC  | Ì     | I           | Latin capital letter I with grave      |
   -- | U+00CD  | Í     | I           | Latin capital letter I with acute      |
   -- | U+00CE  | Î     | I           | Latin capital letter I with circumflex |
   -- | U+00CF  | Ï     | I           | Latin capital letter I with diaeresis  |
   -- | U+00D0  | Ð     | D           | Latin capital letter Eth               |
   -- | U+00D1  | Ñ     | N           | Latin capital letter N with tilde      |
   -- | U+00D2  | Ò     | O           | Latin capital letter O with grave      |
   -- | U+00D3  | Ó     | O           | Latin capital letter O with acute      |
   -- | U+00D4  | Ô     | O           | Latin capital letter O with circumflex |
   -- | U+00D5  | Õ     | O           | Latin capital letter O with tilde      |
   -- | U+00D6  | Ö     | O           | Latin capital letter O with diaeresis  |
   -- | U+00D8  | Ø     | O           | Latin capital letter O with stroke     |
   -- | U+00D9  | Ù     | U           | Latin capital letter U with grave      |
   -- | U+00DA  | Ú     | U           | Latin capital letter U with acute      |
   -- | U+00DB  | Û     | U           | Latin capital letter U with circumflex |
   -- | U+00DC  | Ü     | U           | Latin capital letter U with diaeresis  |
   -- | U+00DD  | Ý     | Y           | Latin capital letter Y with acute      |
   -- | U+00DE  | Þ     | TH          | Latin capital letter Thorn             |
   -- | U+00DF  | ß     | s           | Latin small letter sharp s             |
   -- | U+00E0  | à     | a           | Latin small letter a with grave        |
   -- | U+00E1  | á     | a           | Latin small letter a with acute        |
   -- | U+00E2  | â     | a           | Latin small letter a with circumflex   |
   -- | U+00E3  | ã     | a           | Latin small letter a with tilde        |
   -- | U+00E4  | ä     | a           | Latin small letter a with diaeresis    |
   -- | U+00E5  | å     | a           | Latin small letter a with ring above   |
   -- | U+00E6  | æ     | ae          | Latin small letter ae                  |
   -- | U+00E7  | ç     | c           | Latin small letter c with cedilla      |
   -- | U+00E8  | è     | e           | Latin small letter e with grave        |
   -- | U+00E9  | é     | e           | Latin small letter e with acute        |
   -- | U+00EA  | ê     | e           | Latin small letter e with circumflex   |
   -- | U+00EB  | ë     | e           | Latin small letter e with diaeresis    |
   -- | U+00EC  | ì     | i           | Latin small letter i with grave        |
   -- | U+00ED  | í     | i           | Latin small letter i with acute        |
   -- | U+00EE  | î     | i           | Latin small letter i with circumflex   |
   -- | U+00EF  | ï     | i           | Latin small letter i with diaeresis    |
   -- | U+00F0  | ð     | d           | Latin small letter Eth                 |
   -- | U+00F1  | ñ     | n           | Latin small letter n with tilde        |
   -- | U+00F2  | ò     | o           | Latin small letter o with grave        |
   -- | U+00F3  | ó     | o           | Latin small letter o with acute        |
   -- | U+00F4  | ô     | o           | Latin small letter o with circumflex   |
   -- | U+00F5  | õ     | o           | Latin small letter o with tilde        |
   -- | U+00F6  | ö     | o           | Latin small letter o with diaeresis    |
   -- | U+00F8  | ø     | o           | Latin small letter o with stroke       |
   -- | U+00F9  | ù     | u           | Latin small letter u with grave        |
   -- | U+00FA  | ú     | u           | Latin small letter u with acute        |
   -- | U+00FB  | û     | u           | Latin small letter u with circumflex   |
   -- | U+00FC  | ü     | u           | Latin small letter u with diaeresis    |
   -- | U+00FD  | ý     | y           | Latin small letter y with acute        |
   -- | U+00FE  | þ     | th          | Latin small letter Thorn               |
   -- | U+00FF  | ÿ     | y           | Latin small letter y with diaeresis    |
   --
   -- Decompositions for Latin Extended-A:
   --
   -- |  Code   | Glyph | Replacement |                    Description                    |
   -- | ------- | ----- | ----------- | ------------------------------------------------- |
   -- | U+0100  | Ā     | A           | Latin capital letter A with macron                |
   -- | U+0101  | ā     | a           | Latin small letter a with macron                  |
   -- | U+0102  | Ă     | A           | Latin capital letter A with breve                 |
   -- | U+0103  | ă     | a           | Latin small letter a with breve                   |
   -- | U+0104  | Ą     | A           | Latin capital letter A with ogonek                |
   -- | U+0105  | ą     | a           | Latin small letter a with ogonek                  |
   -- | U+01006 | Ć     | C           | Latin capital letter C with acute                 |
   -- | U+0107  | ć     | c           | Latin small letter c with acute                   |
   -- | U+0108  | Ĉ     | C           | Latin capital letter C with circumflex            |
   -- | U+0109  | ĉ     | c           | Latin small letter c with circumflex              |
   -- | U+010A  | Ċ     | C           | Latin capital letter C with dot above             |
   -- | U+010B  | ċ     | c           | Latin small letter c with dot above               |
   -- | U+010C  | Č     | C           | Latin capital letter C with caron                 |
   -- | U+010D  | č     | c           | Latin small letter c with caron                   |
   -- | U+010E  | Ď     | D           | Latin capital letter D with caron                 |
   -- | U+010F  | ď     | d           | Latin small letter d with caron                   |
   -- | U+0110  | Đ     | D           | Latin capital letter D with stroke                |
   -- | U+0111  | đ     | d           | Latin small letter d with stroke                  |
   -- | U+0112  | Ē     | E           | Latin capital letter E with macron                |
   -- | U+0113  | ē     | e           | Latin small letter e with macron                  |
   -- | U+0114  | Ĕ     | E           | Latin capital letter E with breve                 |
   -- | U+0115  | ĕ     | e           | Latin small letter e with breve                   |
   -- | U+0116  | Ė     | E           | Latin capital letter E with dot above             |
   -- | U+0117  | ė     | e           | Latin small letter e with dot above               |
   -- | U+0118  | Ę     | E           | Latin capital letter E with ogonek                |
   -- | U+0119  | ę     | e           | Latin small letter e with ogonek                  |
   -- | U+011A  | Ě     | E           | Latin capital letter E with caron                 |
   -- | U+011B  | ě     | e           | Latin small letter e with caron                   |
   -- | U+011C  | Ĝ     | G           | Latin capital letter G with circumflex            |
   -- | U+011D  | ĝ     | g           | Latin small letter g with circumflex              |
   -- | U+011E  | Ğ     | G           | Latin capital letter G with breve                 |
   -- | U+011F  | ğ     | g           | Latin small letter g with breve                   |
   -- | U+0120  | Ġ     | G           | Latin capital letter G with dot above             |
   -- | U+0121  | ġ     | g           | Latin small letter g with dot above               |
   -- | U+0122  | Ģ     | G           | Latin capital letter G with cedilla               |
   -- | U+0123  | ģ     | g           | Latin small letter g with cedilla                 |
   -- | U+0124  | Ĥ     | H           | Latin capital letter H with circumflex            |
   -- | U+0125  | ĥ     | h           | Latin small letter h with circumflex              |
   -- | U+0126  | Ħ     | H           | Latin capital letter H with stroke                |
   -- | U+0127  | ħ     | h           | Latin small letter h with stroke                  |
   -- | U+0128  | Ĩ     | I           | Latin capital letter I with tilde                 |
   -- | U+0129  | ĩ     | i           | Latin small letter i with tilde                   |
   -- | U+012A  | Ī     | I           | Latin capital letter I with macron                |
   -- | U+012B  | ī     | i           | Latin small letter i with macron                  |
   -- | U+012C  | Ĭ     | I           | Latin capital letter I with breve                 |
   -- | U+012D  | ĭ     | i           | Latin small letter i with breve                   |
   -- | U+012E  | Į     | I           | Latin capital letter I with ogonek                |
   -- | U+012F  | į     | i           | Latin small letter i with ogonek                  |
   -- | U+0130  | İ     | I           | Latin capital letter I with dot above             |
   -- | U+0131  | ı     | i           | Latin small letter dotless i                      |
   -- | U+0132  | Ĳ     | IJ          | Latin capital ligature IJ                         |
   -- | U+0133  | ĳ     | ij          | Latin small ligature ij                           |
   -- | U+0134  | Ĵ     | J           | Latin capital letter J with circumflex            |
   -- | U+0135  | ĵ     | j           | Latin small letter j with circumflex              |
   -- | U+0136  | Ķ     | K           | Latin capital letter K with cedilla               |
   -- | U+0137  | ķ     | k           | Latin small letter k with cedilla                 |
   -- | U+0138  | ĸ     | k           | Latin small letter Kra                            |
   -- | U+0139  | Ĺ     | L           | Latin capital letter L with acute                 |
   -- | U+013A  | ĺ     | l           | Latin small letter l with acute                   |
   -- | U+013B  | Ļ     | L           | Latin capital letter L with cedilla               |
   -- | U+013C  | ļ     | l           | Latin small letter l with cedilla                 |
   -- | U+013D  | Ľ     | L           | Latin capital letter L with caron                 |
   -- | U+013E  | ľ     | l           | Latin small letter l with caron                   |
   -- | U+013F  | Ŀ     | L           | Latin capital letter L with middle dot            |
   -- | U+0140  | ŀ     | l           | Latin small letter l with middle dot              |
   -- | U+0141  | Ł     | L           | Latin capital letter L with stroke                |
   -- | U+0142  | ł     | l           | Latin small letter l with stroke                  |
   -- | U+0143  | Ń     | N           | Latin capital letter N with acute                 |
   -- | U+0144  | ń     | n           | Latin small letter N with acute                   |
   -- | U+0145  | Ņ     | N           | Latin capital letter N with cedilla               |
   -- | U+0146  | ņ     | n           | Latin small letter n with cedilla                 |
   -- | U+0147  | Ň     | N           | Latin capital letter N with caron                 |
   -- | U+0148  | ň     | n           | Latin small letter n with caron                   |
   -- | U+0149  | ŉ     | n           | Latin small letter n preceded by apostrophe       |
   -- | U+014A  | Ŋ     | N           | Latin capital letter Eng                          |
   -- | U+014B  | ŋ     | n           | Latin small letter Eng                            |
   -- | U+014C  | Ō     | O           | Latin capital letter O with macron                |
   -- | U+014D  | ō     | o           | Latin small letter o with macron                  |
   -- | U+014E  | Ŏ     | O           | Latin capital letter O with breve                 |
   -- | U+014F  | ŏ     | o           | Latin small letter o with breve                   |
   -- | U+0150  | Ő     | O           | Latin capital letter O with double acute          |
   -- | U+0151  | ő     | o           | Latin small letter o with double acute            |
   -- | U+0152  | Œ     | OE          | Latin capital ligature OE                         |
   -- | U+0153  | œ     | oe          | Latin small ligature oe                           |
   -- | U+0154  | Ŕ     | R           | Latin capital letter R with acute                 |
   -- | U+0155  | ŕ     | r           | Latin small letter r with acute                   |
   -- | U+0156  | Ŗ     | R           | Latin capital letter R with cedilla               |
   -- | U+0157  | ŗ     | r           | Latin small letter r with cedilla                 |
   -- | U+0158  | Ř     | R           | Latin capital letter R with caron                 |
   -- | U+0159  | ř     | r           | Latin small letter r with caron                   |
   -- | U+015A  | Ś     | S           | Latin capital letter S with acute                 |
   -- | U+015B  | ś     | s           | Latin small letter s with acute                   |
   -- | U+015C  | Ŝ     | S           | Latin capital letter S with circumflex            |
   -- | U+015D  | ŝ     | s           | Latin small letter s with circumflex              |
   -- | U+015E  | Ş     | S           | Latin capital letter S with cedilla               |
   -- | U+015F  | ş     | s           | Latin small letter s with cedilla                 |
   -- | U+0160  | Š     | S           | Latin capital letter S with caron                 |
   -- | U+0161  | š     | s           | Latin small letter s with caron                   |
   -- | U+0162  | Ţ     | T           | Latin capital letter T with cedilla               |
   -- | U+0163  | ţ     | t           | Latin small letter t with cedilla                 |
   -- | U+0164  | Ť     | T           | Latin capital letter T with caron                 |
   -- | U+0165  | ť     | t           | Latin small letter t with caron                   |
   -- | U+0166  | Ŧ     | T           | Latin capital letter T with stroke                |
   -- | U+0167  | ŧ     | t           | Latin small letter t with stroke                  |
   -- | U+0168  | Ũ     | U           | Latin capital letter U with tilde                 |
   -- | U+0169  | ũ     | u           | Latin small letter u with tilde                   |
   -- | U+016A  | Ū     | U           | Latin capital letter U with macron                |
   -- | U+016B  | ū     | u           | Latin small letter u with macron                  |
   -- | U+016C  | Ŭ     | U           | Latin capital letter U with breve                 |
   -- | U+016D  | ŭ     | u           | Latin small letter u with breve                   |
   -- | U+016E  | Ů     | U           | Latin capital letter U with ring above            |
   -- | U+016F  | ů     | u           | Latin small letter u with ring above              |
   -- | U+0170  | Ű     | U           | Latin capital letter U with double acute          |
   -- | U+0171  | ű     | u           | Latin small letter u with double acute            |
   -- | U+0172  | Ų     | U           | Latin capital letter U with ogonek                |
   -- | U+0173  | ų     | u           | Latin small letter u with ogonek                  |
   -- | U+0174  | Ŵ     | W           | Latin capital letter W with circumflex            |
   -- | U+0175  | ŵ     | w           | Latin small letter w with circumflex              |
   -- | U+0176  | Ŷ     | Y           | Latin capital letter Y with circumflex            |
   -- | U+0177  | ŷ     | y           | Latin small letter y with circumflex              |
   -- | U+0178  | Ÿ     | Y           | Latin capital letter Y with diaeresis             |
   -- | U+0179  | Ź     | Z           | Latin capital letter Z with acute                 |
   -- | U+017A  | ź     | z           | Latin small letter z with acute                   |
   -- | U+017B  | Ż     | Z           | Latin capital letter Z with dot above             |
   -- | U+017C  | ż     | z           | Latin small letter z with dot above               |
   -- | U+017D  | Ž     | Z           | Latin capital letter Z with caron                 |
   -- | U+017E  | ž     | z           | Latin small letter z with caron                   |
   -- | U+017F  | ſ     | s           | Latin small letter long s                         |
   -- | U+01A0  | Ơ     | O           | Latin capital letter O with horn                  |
   -- | U+01A1  | ơ     | o           | Latin small letter o with horn                    |
   -- | U+01AF  | Ư     | U           | Latin capital letter U with horn                  |
   -- | U+01B0  | ư     | u           | Latin small letter u with horn                    |
   -- | U+01CD  | Ǎ     | A           | Latin capital letter A with caron                 |
   -- | U+01CE  | ǎ     | a           | Latin small letter a with caron                   |
   -- | U+01CF  | Ǐ     | I           | Latin capital letter I with caron                 |
   -- | U+01D0  | ǐ     | i           | Latin small letter i with caron                   |
   -- | U+01D1  | Ǒ     | O           | Latin capital letter O with caron                 |
   -- | U+01D2  | ǒ     | o           | Latin small letter o with caron                   |
   -- | U+01D3  | Ǔ     | U           | Latin capital letter U with caron                 |
   -- | U+01D4  | ǔ     | u           | Latin small letter u with caron                   |
   -- | U+01D5  | Ǖ     | U           | Latin capital letter U with diaeresis and macron  |
   -- | U+01D6  | ǖ     | u           | Latin small letter u with diaeresis and macron    |
   -- | U+01D7  | Ǘ     | U           | Latin capital letter U with diaeresis and acute   |
   -- | U+01D8  | ǘ     | u           | Latin small letter u with diaeresis and acute     |
   -- | U+01D9  | Ǚ     | U           | Latin capital letter U with diaeresis and caron   |
   -- | U+01DA  | ǚ     | u           | Latin small letter u with diaeresis and caron     |
   -- | U+01DB  | Ǜ     | U           | Latin capital letter U with diaeresis and grave   |
   -- | U+01DC  | ǜ     | u           | Latin small letter u with diaeresis and grave     |
   --
   -- Decompositions for Latin Extended-B:
   --
   -- |   Code   | Glyph | Replacement |                Description                |
   -- | -------- | ----- | ----------- | ----------------------------------------- |
   -- | U+0218   | Ș     | S           | Latin capital letter S with comma below   |
   -- | U+0219   | ș     | s           | Latin small letter s with comma below     |
   -- | U+021A   | Ț     | T           | Latin capital letter T with comma below   |
   -- | U+021B   | ț     | t           | Latin small letter t with comma below     |
   --
   -- Vowels with diacritic (Chinese, Hanyu Pinyin):
   --
   -- |   Code   | Glyph | Replacement |                      Description                      |
   -- | -------- | ----- | ----------- | ----------------------------------------------------- |
   -- | U+0251   | ɑ     | a           | Latin small letter alpha                              |
   -- | U+1EA0   | Ạ     | A           | Latin capital letter A with dot below                 |
   -- | U+1EA1   | ạ     | a           | Latin small letter a with dot below                   |
   -- | U+1EA2   | Ả     | A           | Latin capital letter A with hook above                |
   -- | U+1EA3   | ả     | a           | Latin small letter a with hook above                  |
   -- | U+1EA4   | Ấ     | A           | Latin capital letter A with circumflex and acute      |
   -- | U+1EA5   | ấ     | a           | Latin small letter a with circumflex and acute        |
   -- | U+1EA6   | Ầ     | A           | Latin capital letter A with circumflex and grave      |
   -- | U+1EA7   | ầ     | a           | Latin small letter a with circumflex and grave        |
   -- | U+1EA8   | Ẩ     | A           | Latin capital letter A with circumflex and hook above |
   -- | U+1EA9   | ẩ     | a           | Latin small letter a with circumflex and hook above   |
   -- | U+1EAA   | Ẫ     | A           | Latin capital letter A with circumflex and tilde      |
   -- | U+1EAB   | ẫ     | a           | Latin small letter a with circumflex and tilde        |
   -- | U+1EA6   | Ậ     | A           | Latin capital letter A with circumflex and dot below  |
   -- | U+1EAD   | ậ     | a           | Latin small letter a with circumflex and dot below    |
   -- | U+1EAE   | Ắ     | A           | Latin capital letter A with breve and acute           |
   -- | U+1EAF   | ắ     | a           | Latin small letter a with breve and acute             |
   -- | U+1EB0   | Ằ     | A           | Latin capital letter A with breve and grave           |
   -- | U+1EB1   | ằ     | a           | Latin small letter a with breve and grave             |
   -- | U+1EB2   | Ẳ     | A           | Latin capital letter A with breve and hook above      |
   -- | U+1EB3   | ẳ     | a           | Latin small letter a with breve and hook above        |
   -- | U+1EB4   | Ẵ     | A           | Latin capital letter A with breve and tilde           |
   -- | U+1EB5   | ẵ     | a           | Latin small letter a with breve and tilde             |
   -- | U+1EB6   | Ặ     | A           | Latin capital letter A with breve and dot below       |
   -- | U+1EB7   | ặ     | a           | Latin small letter a with breve and dot below         |
   -- | U+1EB8   | Ẹ     | E           | Latin capital letter E with dot below                 |
   -- | U+1EB9   | ẹ     | e           | Latin small letter e with dot below                   |
   -- | U+1EBA   | Ẻ     | E           | Latin capital letter E with hook above                |
   -- | U+1EBB   | ẻ     | e           | Latin small letter e with hook above                  |
   -- | U+1EBC   | Ẽ     | E           | Latin capital letter E with tilde                     |
   -- | U+1EBD   | ẽ     | e           | Latin small letter e with tilde                       |
   -- | U+1EBE   | Ế     | E           | Latin capital letter E with circumflex and acute      |
   -- | U+1EBF   | ế     | e           | Latin small letter e with circumflex and acute        |
   -- | U+1EC0   | Ề     | E           | Latin capital letter E with circumflex and grave      |
   -- | U+1EC1   | ề     | e           | Latin small letter e with circumflex and grave        |
   -- | U+1EC2   | Ể     | E           | Latin capital letter E with circumflex and hook above |
   -- | U+1EC3   | ể     | e           | Latin small letter e with circumflex and hook above   |
   -- | U+1EC4   | Ễ     | E           | Latin capital letter E with circumflex and tilde      |
   -- | U+1EC5   | ễ     | e           | Latin small letter e with circumflex and tilde        |
   -- | U+1EC6   | Ệ     | E           | Latin capital letter E with circumflex and dot below  |
   -- | U+1EC7   | ệ     | e           | Latin small letter e with circumflex and dot below    |
   -- | U+1EC8   | Ỉ     | I           | Latin capital letter I with hook above                |
   -- | U+1EC9   | ỉ     | i           | Latin small letter i with hook above                  |
   -- | U+1ECA   | Ị     | I           | Latin capital letter I with dot below                 |
   -- | U+1ECB   | ị     | i           | Latin small letter i with dot below                   |
   -- | U+1ECC   | Ọ     | O           | Latin capital letter O with dot below                 |
   -- | U+1ECD   | ọ     | o           | Latin small letter o with dot below                   |
   -- | U+1ECE   | Ỏ     | O           | Latin capital letter O with hook above                |
   -- | U+1ECF   | ỏ     | o           | Latin small letter o with hook above                  |
   -- | U+1ED0   | Ố     | O           | Latin capital letter O with circumflex and acute      |
   -- | U+1ED1   | ố     | o           | Latin small letter o with circumflex and acute        |
   -- | U+1ED2   | Ồ     | O           | Latin capital letter O with circumflex and grave      |
   -- | U+1ED3   | ồ     | o           | Latin small letter o with circumflex and grave        |
   -- | U+1ED4   | Ổ     | O           | Latin capital letter O with circumflex and hook above |
   -- | U+1ED5   | ổ     | o           | Latin small letter o with circumflex and hook above   |
   -- | U+1ED6   | Ỗ     | O           | Latin capital letter O with circumflex and tilde      |
   -- | U+1ED7   | ỗ     | o           | Latin small letter o with circumflex and tilde        |
   -- | U+1ED8   | Ộ     | O           | Latin capital letter O with circumflex and dot below  |
   -- | U+1ED9   | ộ     | o           | Latin small letter o with circumflex and dot below    |
   -- | U+1EDA   | Ớ     | O           | Latin capital letter O with horn and acute            |
   -- | U+1EDB   | ớ     | o           | Latin small letter o with horn and acute              |
   -- | U+1EDC   | Ờ     | O           | Latin capital letter O with horn and grave            |
   -- | U+1EDD   | ờ     | o           | Latin small letter o with horn and grave              |
   -- | U+1EDE   | Ở     | O           | Latin capital letter O with horn and hook above       |
   -- | U+1EDF   | ở     | o           | Latin small letter o with horn and hook above         |
   -- | U+1EE0   | Ỡ     | O           | Latin capital letter O with horn and tilde            |
   -- | U+1EE1   | ỡ     | o           | Latin small letter o with horn and tilde              |
   -- | U+1EE2   | Ợ     | O           | Latin capital letter O with horn and dot below        |
   -- | U+1EE3   | ợ     | o           | Latin small letter o with horn and dot below          |
   -- | U+1EE4   | Ụ     | U           | Latin capital letter U with dot below                 |
   -- | U+1EE5   | ụ     | u           | Latin small letter u with dot below                   |
   -- | U+1EE6   | Ủ     | U           | Latin capital letter U with hook above                |
   -- | U+1EE7   | ủ     | u           | Latin small letter u with hook above                  |
   -- | U+1EE8   | Ứ     | U           | Latin capital letter U with horn and acute            |
   -- | U+1EE9   | ứ     | u           | Latin small letter u with horn and acute              |
   -- | U+1EEA   | Ừ     | U           | Latin capital letter U with horn and grave            |
   -- | U+1EEB   | ừ     | u           | Latin small letter u with horn and grave              |
   -- | U+1EEC   | Ử     | U           | Latin capital letter U with horn and hook above       |
   -- | U+1EED   | ử     | u           | Latin small letter u with horn and hook above         |
   -- | U+1EEE   | Ữ     | U           | Latin capital letter U with horn and tilde            |
   -- | U+1EEF   | ữ     | u           | Latin small letter u with horn and tilde              |
   -- | U+1EF0   | Ự     | U           | Latin capital letter U with horn and dot below        |
   -- | U+1EF1   | ự     | u           | Latin small letter u with horn and dot below          |
   -- | U+1EF2   | Ỳ     | Y           | Latin capital letter Y with grave                     |
   -- | U+1EF3   | ỳ     | y           | Latin small letter y with grave                       |
   -- | U+1EF4   | Ỵ     | Y           | Latin capital letter Y with dot below                 |
   -- | U+1EF5   | ỵ     | y           | Latin small letter y with dot below                   |
   -- | U+1EF6   | Ỷ     | Y           | Latin capital letter Y with hook above                |
   -- | U+1EF7   | ỷ     | y           | Latin small letter y with hook above                  |
   -- | U+1EF8   | Ỹ     | Y           | Latin capital letter Y with tilde                     |
   -- | U+1EF9   | ỹ     | y           | Latin small letter y with tilde                       |
   --
   -- German (`de_DE`), German formal (`de_DE_formal`), German (Switzerland) formal (`de_CH`),
   -- German (Switzerland) informal (`de_CH_informal`), and German (Austria) (`de_AT`) locales:
   --
   -- |   Code   | Glyph | Replacement |               Description               |
   -- | -------- | ----- | ----------- | --------------------------------------- |
   -- | U+00C4   | Ä     | Ae          | Latin capital letter A with diaeresis   |
   -- | U+00E4   | ä     | ae          | Latin small letter a with diaeresis     |
   -- | U+00D6   | Ö     | Oe          | Latin capital letter O with diaeresis   |
   -- | U+00F6   | ö     | oe          | Latin small letter o with diaeresis     |
   -- | U+00DC   | Ü     | Ue          | Latin capital letter U with diaeresis   |
   -- | U+00FC   | ü     | ue          | Latin small letter u with diaeresis     |
   -- | U+00DF   | ß     | ss          | Latin small letter sharp s              |
   --
   -- Danish (`da_DK`) locale:
   --
   -- |   Code   | Glyph | Replacement |               Description               |
   -- | -------- | ----- | ----------- | --------------------------------------- |
   -- | U+00C6   | Æ     | Ae          | Latin capital letter AE                 |
   -- | U+00E6   | æ     | ae          | Latin small letter ae                   |
   -- | U+00D8   | Ø     | Oe          | Latin capital letter O with stroke      |
   -- | U+00F8   | ø     | oe          | Latin small letter o with stroke        |
   -- | U+00C5   | Å     | Aa          | Latin capital letter A with ring above  |
   -- | U+00E5   | å     | aa          | Latin small letter a with ring above    |
   --
   -- Catalan (`ca`) locale:
   --
   -- |   Code   | Glyph | Replacement |               Description               |
   -- | -------- | ----- | ----------- | --------------------------------------- |
   -- | U+00B7   | l·l   | ll          | Flown dot (between two Ls)              |
   --
   -- Serbian (`sr_RS`) and Bosnian (`bs_BA`) locales:
   --
   -- |   Code   | Glyph | Replacement |               Description               |
   -- | -------- | ----- | ----------- | --------------------------------------- |
   -- | U+0110   | Đ     | DJ          | Latin capital letter D with stroke      |
   -- | U+0111   | đ     | dj          | Latin small letter d with stroke        |
   --
   -- @since 1.2.1
   -- @since 4.6.0 Added locale support for `de_CH`, `de_CH_informal`, and `ca`.
   -- @since 4.7.0 Added locale support for `sr_RS`.
   -- @since 4.8.0 Added locale support for `bs_BA`.
   -- @since 5.7.0 Added locale support for `de_AT`.
   -- @since 6.0.0 Added the `locale` parameter.
   -- @since 6.1.0 Added Unicode NFC encoding normalization support.
   --
   -- @param string string Text that might have accent characters.
   -- @param string locale Optional. The locale to use for accent removal. Some
   --                       character replacements depend on the locale being used
   --                       (e.g. "de_DE"). Defaults to the current locale.
   -- @return string Filtered string with replaced "nice" characters.
   --
   function Remove_Accents (Item   : String;
                            Locale : String := "")
                            return String;

   --
   -- Verifies that an email is valid.
   --
   -- Does not grok i18n domains. Not RFC compliant.
   --
   -- @since 0.71
   --
   -- @param string email      Email address to verify.
   -- @param bool   deprecated Deprecated.
   -- @return string|false Valid email address on success, false on failure.
   --
   function Is_Email (Email      : String;
                      Deprecated : Boolean := False)
                      return String;

   --
   -- Determines the difference between two timestamps.
   --
   -- The difference is returned in a human readable format such as "1 hour",
   -- "5 mins", "2 days".
   --
   -- @since 1.5.0
   -- @since 5.3.0 Added support for showing a difference in seconds.
   --
   -- @param int from Unix timestamp from which the difference begins.
   -- @param int to   Optional. Unix timestamp to end the time difference. Default
   --                 becomes time() if not set.
   -- @return string Human readable time difference.
   --
   function Human_Time_Diff (From : Integer;
                             To   : Integer := 0)
                             return String;

   --
   -- Appends a trailing slash.
   --
   -- Will remove trailing forward and backslashes if it exists already before adding
   -- a trailing forward slash. This prevents double slashing a string or path.
   --
   -- The primary use of this is for paths and thus should be used for paths. It is
   -- not restricted to paths and offers no specific path support.
   --
   -- @since 1.2.0
   --
   -- @param string string What to add the trailing slash to.
   -- @return string String with trailing slash added.
   --
   function Trailing_Slash_It (Item : String)
                               return String;

   --
   -- Removes trailing forward slashes and backslashes if they exist.
   --
   -- The primary use of this is for paths and thus should be used for paths. It is
   -- not restricted to paths and offers no specific path support.
   --
   -- @since 2.2.0
   --
   -- @param string string What to remove the trailing slashes from.
   -- @return string String without the trailing slashes.
   --
   function Un_Trailing_Slash_It (Item : String)
                                  return String;

   --
   -- Safely extracts not more than the first count characters from HTML string.
   --
   -- UTF-8, tags and entities safe prefix extraction. Entities inside will *NOT*
   -- be counted as one character. For example &amp; will be counted as 4, &lt; as
   -- 3, etc.
   --
   -- @since 2.5.0
   --
   -- @param string str   String to get the excerpt from.
   -- @param int    count Maximum number of characters to take.
   -- @param string more  Optional. What to append if str needs to be trimmed.
   --                     Defaults to empty string.
   -- @return string The excerpt.
   --
   function Wp_HTML_Excerpt (Str   : String;
                             Count : Integer;
                             More  : String := "")
                             return String;

   --
   -- Strips out all characters not allowed in a locale name.
   --
   -- @since 6.2.1
   --
   -- @param string locale_name The locale name to be sanitized.
   -- @return string The sanitized value.
   --
   function Sanitize_Locale_Name (Locale_Name : String)
                                  return String;

   --
   -- Sanitizes a string key.
   --
   -- Keys are used as internal identifiers. Lowercase alphanumeric characters,
   -- dashes, and underscores are allowed.
   --
   -- @since 3.0.0
   --
   -- @param string key String key.
   -- @return string Sanitized key.
   --
   function Sanitize_Key (Key : String)
                          return String;

   --
   -- i18n-friendly version of basename().
   --
   -- @since 3.1.0
   --
   -- @param string path   A path.
   -- @param string suffix If the filename ends in suffix this will also be cut off.
   -- @return string
   --
   function Wp_Basename (Path   : String;
                         Suffix : String := "")
                         return String;

   --
   -- Maps a function to all non-iterable elements of an array or an object.
   --
   -- This is similar to `array_walk_recursive()` but acts upon objects too.
   --
   -- @since 4.4.0
   --
   -- @param mixed    value    The array, object, or scalar.
   -- @param callable callback The function to map onto value.
   -- @return mixed The value with the callback applied to all non-arrays and
   --               non-objects inside it.
   --
   type Callable is access function (Item : String) return String;

   function Map_Deep (Value    : Array_Type;
                      Callback : Callable)
                      return Array_Type;

   function Map_Deep (Value    : String;
                      Callback : Callable)
                      return String;

   --
   -- WordPress implementation of PHP sprintf() with filters.
   --
   -- @since 2.5.0
   -- @since 5.3.0 Formalized the existing and already documented `...args`
   --              parameter by adding it to the function signature.
   --
   -- @link https://www.php.net/sprintf
   --
   -- @param string pattern The string which formatted args are inserted.
   -- @param mixed  ...args Arguments to be formatted into the pattern string.
   -- @return string The formatted string.
   --
   function Wp_Sprintf (Pattern : String;
                        Arg_1   : List_Type)
                        return String;

   --
   -- Properly strips all HTML tags including script and style
   --
   -- This differs from strip_tags() because it removes the contents of
   -- the `<script>` and `<style>` tags. E.g. `strip_tags(
   -- "<script>something</script>" )` will return "something". wp_strip_all_tags will
   -- return ""
   --
   -- @since 2.9.0
   --
   -- @param string string        String containing HTML tags
   -- @param bool   remove_breaks Optional. Whether to remove left over line breaks
   --               and white space chars
   -- @return string The processed string.
   --
   function Wp_Strip_All_Tags (Item          : String;
                               Remove_Breaks : Boolean := False)
                               return String;

   --
   -- Sanitizes a string from user input or from the database.
   --
   -- - Checks for invalid UTF-8,
   -- - Converts single `<` characters to entities
   -- - Strips all tags
   -- - Removes line breaks, tabs, and extra whitespace
   -- - Strips octets
   --
   -- @since 2.9.0
   --
   -- @see sanitize_textarea_field()
   -- @see wp_check_invalid_utf8()
   -- @see wp_strip_all_tags()
   --
   -- @param string str String to sanitize.
   -- @return string Sanitized string.
   --
   function Sanitize_Text_Field (Str : String)
                                 return String;

   --
   -- Internal helper function to sanitize a string from user input or from the
   -- database.
   --
   -- @since 4.7.0
   -- @access private
   --
   -- @param string str           String to sanitize.
   -- @param bool   keep_newlines Optional. Whether to keep newlines. Default: false.
   -- @return string Sanitized string.
   --
   function X_Sanitize_Text_Fields (Str           : String;
                                    Keep_Newlines : Boolean := False)
                                    return String;

   --
   -- Returns the regexp for common whitespace characters.
   --
   -- By default, spaces include new lines, tabs, nbsp entities, and the UTF-8 nbsp.
   -- This is designed to replace the PCRE \s sequence. In ticket #22692, that
   -- sequence was found to be unreliable due to random inclusion of the A0 byte.
   --
   -- @since 4.0.0
   --
   -- @return string The spaces regexp.
   --
   function Wp_Spaces_Regexp
            return String;

   --
   -- Prints the important emoji-related styles.
   --
   -- @since 4.2.0
   --
   procedure Print_Emoji_Styles;

   function Print_Emoji_Styles
     is new Helpers_2.Generic_Call_Procedure (Print_Emoji_Styles);

   --
   -- Prints the inline Emoji detection script if it is not already printed.
   --
   -- @since 4.2.0
   --
   procedure Print_Emoji_Detection_Script;

   function Print_Emoji_Detection_Script
     is new Helpers_2.Generic_Call_Procedure (Print_Emoji_Detection_Script);

   --
   -- Prints inline Emoji detection script.
   --
   -- @ignore
   -- @since 4.6.0
   -- @access private
   --
   procedure X_Print_Emoji_Detection_Script;

   --
   -- Adds slashes to a string or recursively adds slashes to strings within an array.
   --
   -- This should be used when preparing data for core API that expects slashed data.
   -- This should not be used to escape data going directly into an SQL query.
   --
   -- @since 3.6.0
   -- @since 5.5.0 Non-string values are left untouched.
   --
   -- @param string|array value String or array of data to slash.
   -- @return string|array Slashed `value`, in the same type as supplied.
   --
   function Wp_Slash (Value : String)
                      return String;

   --
   -- Removes slashes from a string or recursively removes slashes from strings
   --  within an array.
   --
   -- This should be used to remove slashes from data passed to core API that
   -- expects data to be unslashed.
   --
   -- @since 3.6.0
   --
   -- @param string|array value String or array of data to unslash.
   -- @return string|array Unslashed `value`, in the same type as supplied.
   --
   function Wp_Unslash (Value : String)
                        return String;

   function Wp_Unslash (Value : String)
                        return List_Type
   is (raise Program_Error with "not implemented");

end Inc_Formatting;
