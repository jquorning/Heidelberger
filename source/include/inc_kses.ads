--
-- kses 0.2.2 - HTML/XHTML filter that only allows some elements and attributes
-- Copyright (C) 2002, 2003, 2005  Ulf Harnhammar
--
-- This program is free software and open source software; you can redistribute
-- it and/or modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation; either version 2 of the License,
-- or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
-- more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
-- http://www.gnu.org/licenses/gpl.html
--
-- [kses strips evil scripts!]
--
-- Added wp_ prefix to avoid conflicts with existing kses users
--
-- @version 0.2.2
-- @copyright (C) 2002, 2003, 2005
-- @author Ulf Harnhammar <http://advogato.org/person/metaur/>
--
-- @package External
-- @subpackage KSES
--

with Arrays;
with Lists;

package Inc_KSES
is
   use Arrays;
   use Lists;

   --
   -- Filters text content and strips out disallowed HTML.
   --
   -- This function makes sure that only the allowed HTML element names, attribute
   -- names, attribute values, and HTML entities will occur in the given text string.
   --
   -- This function expects unslashed data.
   --
   -- @see wp_kses_post() for specifically filtering post content and fields.
   -- @see wp_allowed_protocols() for the default allowed protocols in link URLs.
   --
   -- @since 1.0.0
   --
   -- @param string         $string            Text content to filter.
   -- @param array[]|string $allowed_html      An array of allowed HTML elements and
   --                                          attributes, or a context name such as
   --                                          "post". See wp_kses_allowed_html()
   --                                          for the list of accepted context names.
   -- @param string[]       $allowed_protocols Optional. Array of allowed URL
   --                                          protocols.
   --                                          Defaults to the result of
   --                                          wp_allowed_protocols().
   -- @return string Filtered content containing only the allowed HTML.
   --
   function Wp_KSES (Item              : String;
                     Allowed_HTML      : Array_Type;
                     Allowed_Protocols : List_Type := [])
                     return String;

   --
   -- Returns an array of allowed HTML tags and attributes for a given context.
   --
   -- @since 3.5.0
   -- @since 5.0.1 `form` removed as allowable HTML tag.
   --
   -- @global array $allowedposttags
   -- @global array $allowedtags
   -- @global array $allowedentitynames
   --
   -- @param string|array $context The context for which to retrieve tags. Allowed
   --                              values are "post", "strip", "data", "entities", or
   --                              the name of a field filter such as
   --                              "pre_user_description", or an array of allowed HTML
   --                              elements and attributes.
   -- @return array Array of allowed HTML tags and their allowed attributes.
   --
   function Wp_KSES_Allowed_HTML (Context : Array_Type := Empty_Array) -- ""
                                  return Array_Type;

   --
   -- You add any KSES hooks here.
   --
   -- There is currently only one KSES WordPress hook, {@see "pre_kses"}, and it is
   -- called here. All parameters are passed to the hooks and expected to receive a
   -- string.
   --
   -- @since 1.0.0
   --
   -- @param string         $string            Content to filter through KSES.
   -- @param array[]|string $allowed_html      An array of allowed HTML elements and
   --                                          attributes, or a context name such as
   --                                          "post". See wp_kses_allowed_html()
   --                                          for the list of accepted context names.
   -- @param string[]       $allowed_protocols Array of allowed URL protocols.
   -- @return string Filtered content through then@see "pre_kses"end; hook.
   --
   function Wp_KSES_Hook (Item              : String;
                          Allowed_HTML      : Array_Type;
                          Allowed_Protocols : List_Type)
                          return String;

   --
   -- Searches for HTML tags, no matter how malformed.
   --
   -- It also matches stray `>` characters.
   --
   -- @since 1.0.0
   --
   -- @global array[]|string $pass_allowed_html      An array of allowed HTML elements
   --                                                and attributes, or a context name
   --                                                such as "post".
   -- @global string[]       $pass_allowed_protocols Array of allowed URL protocols.
   --
   -- @param string         $string            Content to filter.
   -- @param array[]|string $allowed_html      An array of allowed HTML elements and
   --                                          attributes, or a context name such as
   --                                          "post". See wp_kses_allowed_html() for
   --                                          the list of accepted context names.
   -- @param string[]       $allowed_protocols Array of allowed URL protocols.
   -- @return string Content with fixed HTML tags
   --
   function Wp_KSES_Split (Item              :  String;
                           Allowed_HTML      : Array_Type;
                           Allowed_Protocols : List_Type)
                           return String;

   --
   -- Returns an array of HTML attribute names whose value contains a URL.
   --
   -- This function returns a list of all HTML attributes that must contain
   -- a URL according to the HTML specification.
   --
   -- This list includes URI attributes both allowed and disallowed by KSES.
   --
   -- @link https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes
   --
   -- @since 5.0.1
   --
   -- @return string[] HTML attribute names whose value contains a URL.
   --
   function Wp_KSES_URI_Attributes
            return List_Type;

   --
   -- Callback for `wp_kses_split()`.
   --
   -- @since 3.1.0
   -- @access private
   -- @ignore
   --
   -- @global array[]|string $pass_allowed_html      An array of allowed HTML elements
   --                                                and attributes, or a context name
   --                                                such as "post".
   -- @global string[]       $pass_allowed_protocols Array of allowed URL protocols.
   --
   -- @param array $match preg_replace regexp matches
   -- @return string
   --
   function X_Wp_KSES_Split_Callback (Match : List_Type)
                                      return String;

   --
   -- Callback for `wp_kses_split()` for fixing malformed HTML tags.
   --
   -- This function does a lot of work. It rejects some very malformed things like
   -- `<:::>`. It returns an empty string, if the element isn"t allowed (look ma, no
   -- `strip_tags()`!). Otherwise it splits the tag into an element and an attribute
   -- list.
   --
   -- After the tag is split into an element and an attribute list, it is run
   -- through another filter which will remove illegal attributes and once that is
   -- completed, will be returned.
   --
   -- @access private
   -- @ignore
   -- @since 1.0.0
   --
   -- @param string         $string            Content to filter.
   -- @param array[]|string $allowed_html      An array of allowed HTML elements and
   --                                          attributes, or a context name such as
   --                                          "post". See wp_kses_allowed_html()
   --                                          for the list of accepted context names.
   -- @param string[]       $allowed_protocols Array of allowed URL protocols.
   -- @return string Fixed HTML element
   --
   function Wp_KSES_Split2 (Item              : String;
                            Allowed_HTML      : Array_Type;
                            Allowed_Protocols : List_Type)
                            return String;

   --
   -- Removes all attributes, if none are allowed for this element.
   --
   -- If some are allowed it calls `wp_kses_hair()` to split them further, and then
   -- it builds up new HTML code from the data that `wp_kses_hair()` returns. It also
   -- removes `<` and `>` characters, if there are any left. One more thing it does
   -- is to check if the tag has a closing XHTML slash, and if it does, it puts one
   -- in the returned code as well.
   --
   -- An array of allowed values can be defined for attributes. If the attribute value
   -- doesn"t fall into the list, the attribute will be removed from the tag.
   --
   -- Attributes can be marked as required. If a required attribute is not present,
   -- KSES will remove all attributes from the tag. As KSES doesn"t match opening and
   -- closing tags, it"s not possible to safely remove the tag itself, the safest
   -- fallback is to strip all attributes from the tag, instead.
   --
   -- @since 1.0.0
   -- @since 5.9.0 Added support for an array of allowed values for attributes.
   --              Added support for required attributes.
   --
   -- @param string         $element           HTML element/tag.
   -- @param string         $attr              HTML attributes from HTML element to
   --                                          closing HTML element tag.
   -- @param array[]|string $allowed_html      An array of allowed HTML elements and
   --                                          attributes, or a context name such as
   --                                           "post". See wp_kses_allowed_html()
   --                                          for the list of accepted context names.
   -- @param string[]       $allowed_protocols Array of allowed URL protocols.
   -- @return string Sanitized HTML element.
   --
   function Wp_KSES_Attr (Element           : String;
                          Attr              : String;
                          Allowed_HTML      : Array_Type;
                          Allowed_Protocols : List_Type)
                          return String;

   --
   -- Determines whether an attribute is allowed.
   --
   -- @since 4.2.3
   -- @since 5.0.0 Added support for `data-*` wildcard attributes.
   --
   -- @param string $name         The attribute name. Passed by reference. Returns
   --                              empty string when not allowed.
   -- @param string $value        The attribute value. Passed by reference. Returns a
   --                              filtered value.
   -- @param string $whole        The `name=value` input. Passed by reference. Returns
   --                              filtered input.
   -- @param string $vless        Whether the attribute is valueless. Use "y" or "n".
   -- @param string $element      The name of the element to which this attribute
   --                              belongs.
   -- @param array  $allowed_html The full list of allowed elements and attributes.
   -- @return bool Whether or not the attribute is allowed.
   --
   function Wp_KSES_Attr_Check (Name         : in out String;
                                Value        : in out String;
                                Whole        : in out String;
                                Vless        : String;
                                Element      : String;
                                Allowed_HTML : Array_Type)
                                return Boolean;

   --
   -- Builds an attribute list from string containing attributes.
   --
   -- This function does a lot of work. It parses an attribute list into an array
   -- with attribute data, and tries to do the right thing even if it gets weird
   -- input. It will add quotes around attribute values that don"t have any quotes
   -- or apostrophes around them, to make it easier to produce HTML code that will
   -- conform to W3C"s HTML specification. It will also remove bad URL protocols
   -- from attribute values. It also reduces duplicate attributes by using the
   -- attribute defined first (`foo="bar" foo="baz"` will result in `foo="bar"`).
   --
   -- @since 1.0.0
   --
   -- @param string   $attr              Attribute list from HTML element to closing
   --                                     HTML element tag.
   -- @param string[] $allowed_protocols Array of allowed URL protocols.
   -- @return array[] Array of attribute information after parsing.
   --
   function Wp_KSES_Hair (Attr              : String;
                          Allowed_Protocols : List_Type)
                          return Array_Type;

   --
   -- Performs different checks for attribute values.
   --
   -- The currently implemented checks are "maxlen", "minlen", "maxval", "minval",
   -- and "valueless".
   --
   -- @since 1.0.0
   --
   -- @param string $value      Attribute value.
   -- @param string $vless      Whether the attribute is valueless. Use "y" or "n".
   -- @param string $checkname  What $checkvalue is checking for.
   -- @param mixed  $checkvalue What constraint the value should pass.
   -- @return bool Whether check passes.
   --
   function Wp_KSES_Check_Attr_Val (Value      : String;
                                    Vless      : String;
                                    Checkname  : String;
                                    Checkvalue : String)
                                    return Boolean;

   --
   -- Sanitizes a string and removed disallowed URL protocols.
   --
   -- This function removes all non-allowed protocols from the beginning of the
   -- string. It ignores whitespace and the case of the letters, and it does
   -- understand HTML entities. It does its work recursively, so it won"t be
   -- fooled by a string like `javascript:javascript:alert(57)`.
   --
   -- @since 1.0.0
   --
   -- @param string   $string            Content to filter bad protocols from.
   -- @param string[] $allowed_protocols Array of allowed URL protocols.
   -- @return string Filtered content.
   --
   function Wp_KSES_Bad_Protocol (Item              : String;
                                  Allowed_Protocols : List_Type)
                                  return String;

   --
   -- Removes any invalid control characters in a text string.
   --
   -- Also removes any instance of the `\0` string.
   --
   -- @since 1.0.0
   --
   -- @param string $string  Content to filter null characters from.
   -- @param array  $options Set "slash_zero" => "keep" when "\0" is allowed. Default
   --                         is "remove".
   -- @return string Filtered content.
   --
   function Wp_KSES_No_Null (Item    : String;
                             Options : Array_Type := Empty_Array) -- null
                             return String;

   --
   -- Strips slashes from in front of quotes.
   --
   -- This function changes the character sequence `\"` to just `"`. It leaves all
   -- other slashes alone. The quoting from `preg_replace(//e)` requires this.
   --
   -- @since 1.0.0
   --
   -- @param string $string String to strip slashes from.
   -- @return string Fixed string with quoted slashes.
   --
   function Wp_KSES_Stripslashes (Item : String)
                                  return String;

   --
   -- Handles parsing errors in `wp_kses_hair()`.
   --
   -- The general plan is to remove everything to and including some whitespace,
   -- but it deals with quotes and apostrophes as well.
   --
   -- @since 1.0.0
   --
   -- @param string $string
   -- @return string
   --
   function Wp_KSES_HTML_Error (Item : String)
                                return String;

   --
   -- Sanitizes content from bad protocols and other characters.
   --
   -- This function searches for URL protocols at the beginning of the string, while
   -- handling whitespace and HTML entities.
   --
   -- @since 1.0.0
   --
   -- @param string   $string            Content to check for bad protocols.
   -- @param string[] $allowed_protocols Array of allowed URL protocols.
   -- @param int      $count             Depth of call recursion to this function.
   -- @return string Sanitized content.
   --
   function Wp_KSES_Bad_Protocol_Once (Item              : String;
                                       Allowed_Protocols : List_Type;
                                       Count             : Natural := 1)
                                       return String;

   --
   -- Callback for `wp_kses_bad_protocol_once()` regular expression.
   --
   -- This function processes URL protocols, checks to see if they"re in the
   -- list of allowed protocols or not, and returns different data depending
   -- on the answer.
   --
   -- @access private
   -- @ignore
   -- @since 1.0.0
   --
   -- @param string   $string            URI scheme to check against the list of
   --                                     allowed protocols.
   -- @param string[] $allowed_protocols Array of allowed URL protocols.
   -- @return string Sanitized content.
   --
   function Wp_KSES_Bad_Protocol_Once2 (Item              : String;
                                        Allowed_Protocols : List_Type)
                                        return String;

   --
   -- Converts all numeric HTML entities to their named counterparts.
   --
   -- This function decodes numeric HTML entities (`&#65;` and `&#x41;`).
   -- It doesn"t do anything with named entities like `&auml;`, but we don"t
   -- need them in the allowed URL protocols system anyway.
   --
   -- @since 1.0.0
   --
   -- @param string $string Content to change entities.
   -- @return string Content after decoded entities.
   --
   function Wp_KSES_Decode_Entities (Item : String)
                                     return String;

   --
   -- Regex callback for `wp_kses_decode_entities()`.
   --
   -- @since 2.9.0
   -- @access private
   -- @ignore
   --
   -- @param array $match preg match
   -- @return string
   --
   function X_Wp_KSES_Decode_Entities_Chr (Match : List_Type)
                                           return String;

   --
   -- Regex callback for `wp_kses_decode_entities()`.
   --
   -- @since 2.9.0
   -- @access private
   -- @ignore
   --
   -- @param array $match preg match
   -- @return string
   --
   function X_Wp_KSES_Decode_Entities_Chr_Hexdec (Match : List_Type)
                                                  return String;

   --
   -- Filters an inline style attribute and removes disallowed rules.
   --
   -- @since 2.8.1
   -- @since 4.4.0 Added support for `min-height`, `max-height`, `min-width`, and
   --               `max-width`.
   -- @since 4.6.0 Added support for `list-style-type`.
   -- @since 5.0.0 Added support for `background-image`.
   -- @since 5.1.0 Added support for `text-transform`.
   -- @since 5.2.0 Added support for `background-position` and `grid-template-columns`.
   -- @since 5.3.0 Added support for `grid`, `flex` and `column` layout properties.
   --              Extended `background-*` support for individual properties.
   -- @since 5.3.1 Added support for gradient backgrounds.
   -- @since 5.7.1 Added support for `object-position`.
   -- @since 5.8.0 Added support for `calc()` and `var()` values.
   -- @since 6.1.0 Added support for `min()`, `max()`, `minmax()`, `clamp()`,
   --              nested `var()` values, and assigning values to CSS variables.
   --              Added support for `object-fit`, `gap`, `column-gap`, `row-gap`,
   --               and `flex-wrap`. Extended `margin-*` and `padding-*` support for
   --               logical properties.
   --
   -- @param string $css        A string of CSS rules.
   -- @param string $deprecated Not used.
   -- @return string Filtered string of CSS rules.
   --
   function SafeCSS_Filter_Attr (CSS        : String;
                                 Deprecated : String := "")
                                 return String;

   --
   -- Converts and fixes HTML entities.
   --
   -- This function normalizes HTML entities. It will convert `AT&T` to the correct
   -- `AT&amp;T`, `&#00058;` to `&#058;`, `&#XYZZY;` to `&amp;#XYZZY;` and so on.
   --
   -- When `$context` is set to "xml", HTML entities are converted to their code
   -- points.  For example, `AT&T&hellip;&#XYZZY;` is converted to
   -- `AT&amp;T…&amp;#XYZZY;`.
   --
   -- @since 1.0.0
   -- @since 5.5.0 Added `$context` parameter.
   --
   -- @param string $string  Content to normalize entities.
   -- @param string $context Context for normalization. Can be either "html" or "xml".
   --                        Default "html".
   -- @return string Content with normalized entities.
   --
   function Wp_KSES_Normalize_Entities (Item    : String;
                                        Context : String := "html")
                                        return String
                                        is (Item);

end Inc_KSES;
