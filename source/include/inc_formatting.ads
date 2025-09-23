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
-- function sanitize_url( url, protocols = null ) then
   function Sanitize_URL (Url : String)
                          return String
                          is ("XXX-322");

--
-- Sanitizes a string into a slug, which can be used in URLs or HTML attributes.
--
-- By default, converts accent characters to ASCII characters and further
-- limits the output to alphanumeric characters, underscore (_) and dash (-)
-- through the then@see "sanitize_title"end; filter.
--
-- If `title` is empty and `fallback_title` is set, the latter will be used.
--
-- @since 1.0.0
--
-- @param string title          The string to be sanitized.
-- @param string fallback_title Optional. A title to use if title is empty. Default empty.
-- @param string context        Optional. The operation for which the string is sanitized.
--                               When set to "save", the string runs through remove_accents().
--                               Default "save".
-- @return string The sanitized string.
--
   function Sanitize_Title (Title          : String;
                            Fallback_Title : String := "";
                            Context        : String := "save")
                            return String
                            is ("XXX-341");

--
-- Checks and cleans a URL.
--
-- A number of characters are removed from the URL. If the URL is for displaying
-- (the default behaviour) ampersands are also replaced. The then@see "clean_url"end; filter
-- is applied to the returned cleaned URL.
--
-- @since 2.8.0
--
-- @param string   url       The URL to be cleaned.
-- @param string[] protocols Optional. An array of acceptable protocols.
--                            Defaults to return value of wp_allowed_protocols().
-- @param string   _context  Private. Use sanitize_url() for database usage.
-- @return string The cleaned URL after the then@see "clean_url"end; filter is applied.
--                An empty string is returned if `url` specifies a protocol other than
--                those in `protocols`, or if `url` contains an empty string.
--
-- function esc_url( url, protocols = null, _context = "display" ) then
   function ESC_URL (Item : String)
                    return String
                    is (Item & "XXX-513");

--
-- Escapes single quotes, `"`, `<`, `>`, `&`, and fixes line endings.
--
-- Escapes text strings for echoing in JS. It is intended to be used for inline JS
-- (in a tag attribute, for example `onclick="..."`). Note that the strings have to
-- be in single quotes. The then@see "js_escape"end; filter is also applied here.
--
-- @since 2.8.0
--
-- @param string text The text to be escaped.
-- @return string Escaped text.
--
   function Esc_Js (Text : String)
                    return String
                    is ("XXX-341");

--
-- Escaping for HTML blocks.
--
-- @since 2.8.0
--
-- @param string text
-- @return string
--
-- function esc_html( text ) then
   function ESC_HTML (Item : String)
                      return String
                      is (Item & "XXX-514");

--
-- Escaping for HTML attributes.
--
-- @since 2.8.0
--
-- @param string text
-- @return string
--
-- function esc_attr( text ) then
   function ESC_Attr (Item : String)
                      return String
                      is ("XXX-325");

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
   function Trailingslashit (Item : String)
                             return String
                             is ("XXX-335");

--
-- Safely extracts not more than the first count characters from HTML string.
--
-- UTF-8, tags and entities safe prefix extraction. Entities inside will--NOT*
-- be counted as one character. For example &amp; will be counted as 4, &lt; as
-- 3, etc.
--
-- @since 2.5.0
--
-- @param string str   String to get the excerpt from.
-- @param int    count Maximum number of characters to take.
-- @param string more  Optional. What to append if str needs to be trimmed. Defaults to empty string.
-- @return string The excerpt.
--
   function Wp_Html_Excerpt (Str   : String;
                             Count : Integer;
                             More  : String := "") -- = null
                             return String
                             is ("XXX-353");

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
                          return String
                          is ("XXX-402");

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
                         return String
                         is ("XXX-446");

   --
   -- WordPress implementation of PHP sprintf() with filters.
   --
   -- @since 2.5.0
   -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   --
   -- @link https://www.php.net/sprintf
   --
   -- @param string pattern The string which formatted args are inserted.
   -- @param mixed  ...args Arguments to be formatted into the pattern string.
   -- @return string The formatted string.
   --
   -- function wp_sprintf( pattern, ...args ) then
   function Wp_Sprintf (Pattern : String;
                        Arg_1   : String)
                        -- , ...args )
                        return String
                        is (Pattern);

--
-- Removes slashes from a string or recursively removes slashes from strings within an array.
--
-- This should be used to remove slashes from data passed to core API that
-- expects data to be unslashed.
--
-- @since 3.6.0
--
-- @param string|array value String or array of data to unslash.
-- @return string|array Unslashed `value`, in the same type as supplied.
--
-- function wp_unslash( value ) then
   function Wp_Unslash (Item : String)
                        return String
                        is ("XXX-215");

end Inc_Formatting;
