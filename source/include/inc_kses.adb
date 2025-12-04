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

with Ada.Strings.Unbounded;

with Php.Lists;
with Php.Numerics;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Hb_Common;

with Inc_Functions;
with Inc_Plugins;

package body Inc_KSES
is

   function Apply_Filters (Hook      : String;
                           Value     : String;
                           HTML      : Array_Type;
                           Protocols : List_Type)
                           return String
                           is (Value);

   function Apply_Filters (Hook    : String;
                           HTML    : Array_Type;
                           Context : String)
                           return Array_Type
                           is (HTML);

   function Apply_Filters (Hook  : String;
                           Value : Boolean;
                           A     : String)
                           return Boolean
                           is (Value);

-- --
-- -- Specifies the default allowable HTML tags.
-- --
-- -- Using `CUSTOM_TAGS` is not recommended and should be considered deprecated. The
-- -- then@see "wp_kses_allowed_html"end; filter is more powerful and supplies context.
-- --
-- -- @see wp_kses_allowed_html()
-- -- @since 1.2.0
-- --
-- -- @var array[]|false Array of default allowable HTML tags, or false to use the defaults.
-- --
-- if ( ! defined( "CUSTOM_TAGS" ) ) then
--         define( "CUSTOM_TAGS", false );
-- end;

-- // Ensure that these variables are added to the global namespace
-- // (e.g. if using namespaces / autoload in the current PHP environment).
-- global $allowedposttags, $allowedtags, $allowedentitynames, $allowedxmlentitynames;

-- if ( ! CUSTOM_TAGS ) then
--         --
--         -- KSES global for default allowable HTML tags.
--         --
--         -- Can be overridden with the `CUSTOM_TAGS` constant.
--         --
--         -- @var array[] $allowedposttags Array of default allowable HTML tags.
--         -- @since 2.0.0
--         --
--         $allowedposttags = array(
--                 "address"    => array(),
--                 "a"          => array(
--                         "href"     => true,
--                         "rel"      => true,
--                         "rev"      => true,
--                         "name"     => true,
--                         "target"   => true,
--                         "download" => array(
--                                 "valueless" => "y",
--                         ),
--                 ),
--                 "abbr"       => array(),
--                 "acronym"    => array(),
--                 "area"       => array(
--                         "alt"    => true,
--                         "coords" => true,
--                         "href"   => true,
--                         "nohref" => true,
--                         "shape"  => true,
--                         "target" => true,
--                 ),
--                 "article"    => array(
--                         "align" => true,
--                 ),
--                 "aside"      => array(
--                         "align" => true,
--                 ),
--                 "audio"      => array(
--                         "autoplay" => true,
--                         "controls" => true,
--                         "loop"     => true,
--                         "muted"    => true,
--                         "preload"  => true,
--                         "src"      => true,
--                 ),
--                 "b"          => array(),
--                 "bdo"        => array(),
--                 "big"        => array(),
--                 "blockquote" => array(
--                         "cite" => true,
--                 ),
--                 "br"         => array(),
--                 "button"     => array(
--                         "disabled" => true,
--                         "name"     => true,
--                         "type"     => true,
--                         "value"    => true,
--                 ),
--                 "caption"    => array(
--                         "align" => true,
--                 ),
--                 "cite"       => array(),
--                 "code"       => array(),
--                 "col"        => array(
--                         "align"   => true,
--                         "char"    => true,
--                         "charoff" => true,
--                         "span"    => true,
--                         "valign"  => true,
--                         "width"   => true,
--                 ),
--                 "colgroup"   => array(
--                         "align"   => true,
--                         "char"    => true,
--                         "charoff" => true,
--                         "span"    => true,
--                         "valign"  => true,
--                         "width"   => true,
--                 ),
--                 "del"        => array(
--                         "datetime" => true,
--                 ),
--                 "dd"         => array(),
--                 "dfn"        => array(),
--                 "details"    => array(
--                         "align" => true,
--                         "open"  => true,
--                 ),
--                 "div"        => array(
--                         "align" => true,
--                 ),
--                 "dl"         => array(),
--                 "dt"         => array(),
--                 "em"         => array(),
--                 "fieldset"   => array(),
--                 "figure"     => array(
--                         "align" => true,
--                 ),
--                 "figcaption" => array(
--                         "align" => true,
--                 ),
--                 "font"       => array(
--                         "color" => true,
--                         "face"  => true,
--                         "size"  => true,
--                 ),
--                 "footer"     => array(
--                         "align" => true,
--                 ),
--                 "h1"         => array(
--                         "align" => true,
--                 ),
--                 "h2"         => array(
--                         "align" => true,
--                 ),
--                 "h3"         => array(
--                         "align" => true,
--                 ),
--                 "h4"         => array(
--                         "align" => true,
--                 ),
--                 "h5"         => array(
--                         "align" => true,
--                 ),
--                 "h6"         => array(
--                         "align" => true,
--                 ),
--                 "header"     => array(
--                         "align" => true,
--                 ),
--                 "hgroup"     => array(
--                         "align" => true,
--                 ),
--                 "hr"         => array(
--                         "align"   => true,
--                         "noshade" => true,
--                         "size"    => true,
--                         "width"   => true,
--                 ),
--                 "i"          => array(),
--                 "img"        => array(
--                         "alt"      => true,
--                         "align"    => true,
--                         "border"   => true,
--                         "height"   => true,
--                         "hspace"   => true,
--                         "loading"  => true,
--                         "longdesc" => true,
--                         "vspace"   => true,
--                         "src"      => true,
--                         "usemap"   => true,
--                         "width"    => true,
--                 ),
--                 "ins"        => array(
--                         "datetime" => true,
--                         "cite"     => true,
--                 ),
--                 "kbd"        => array(),
--                 "label"      => array(
--                         "for" => true,
--                 ),
--                 "legend"     => array(
--                         "align" => true,
--                 ),
--                 "li"         => array(
--                         "align" => true,
--                         "value" => true,
--                 ),
--                 "main"       => array(
--                         "align" => true,
--                 ),
--                 "map"        => array(
--                         "name" => true,
--                 ),
--                 "mark"       => array(),
--                 "menu"       => array(
--                         "type" => true,
--                 ),
--                 "nav"        => array(
--                         "align" => true,
--                 ),
--                 "object"     => array(
--                         "data" => array(
--                                 "required"       => true,
--                                 "value_callback" => "_wp_kses_allow_pdf_objects",
--                         ),
--                         "type" => array(
--                                 "required" => true,
--                                 "values"   => array( "application/pdf" ),
--                         ),
--                 ),
--                 "p"          => array(
--                         "align" => true,
--                 ),
--                 "pre"        => array(
--                         "width" => true,
--                 ),
--                 "q"          => array(
--                         "cite" => true,
--                 ),
--                 "rb"         => array(),
--                 "rp"         => array(),
--                 "rt"         => array(),
--                 "rtc"        => array(),
--                 "ruby"       => array(),
--                 "s"          => array(),
--                 "samp"       => array(),
--                 "span"       => array(
--                         "align" => true,
--                 ),
--                 "section"    => array(
--                         "align" => true,
--                 ),
--                 "small"      => array(),
--                 "strike"     => array(),
--                 "strong"     => array(),
--                 "sub"        => array(),
--                 "summary"    => array(
--                         "align" => true,
--                 ),
--                 "sup"        => array(),
--                 "table"      => array(
--                         "align"       => true,
--                         "bgcolor"     => true,
--                         "border"      => true,
--                         "cellpadding" => true,
--                         "cellspacing" => true,
--                         "rules"       => true,
--                         "summary"     => true,
--                         "width"       => true,
--                 ),
--                 "tbody"      => array(
--                         "align"   => true,
--                         "char"    => true,
--                         "charoff" => true,
--                         "valign"  => true,
--                 ),
--                 "td"         => array(
--                         "abbr"    => true,
--                         "align"   => true,
--                         "axis"    => true,
--                         "bgcolor" => true,
--                         "char"    => true,
--                         "charoff" => true,
--                         "colspan" => true,
--                         "headers" => true,
--                         "height"  => true,
--                         "nowrap"  => true,
--                         "rowspan" => true,
--                         "scope"   => true,
--                         "valign"  => true,
--                         "width"   => true,
--                 ),
--                 "textarea"   => array(
--                         "cols"     => true,
--                         "rows"     => true,
--                         "disabled" => true,
--                         "name"     => true,
--                         "readonly" => true,
--                 ),
--                 "tfoot"      => array(
--                         "align"   => true,
--                         "char"    => true,
--                         "charoff" => true,
--                         "valign"  => true,
--                 ),
--                 "th"         => array(
--                         "abbr"    => true,
--                         "align"   => true,
--                         "axis"    => true,
--                         "bgcolor" => true,
--                         "char"    => true,
--                         "charoff" => true,
--                         "colspan" => true,
--                         "headers" => true,
--                         "height"  => true,
--                         "nowrap"  => true,
--                         "rowspan" => true,
--                         "scope"   => true,
--                         "valign"  => true,
--                         "width"   => true,
--                 ),
--                 "thead"      => array(
--                         "align"   => true,
--                         "char"    => true,
--                         "charoff" => true,
--                         "valign"  => true,
--                 ),
--                 "title"      => array(),
--                 "tr"         => array(
--                         "align"   => true,
--                         "bgcolor" => true,
--                         "char"    => true,
--                         "charoff" => true,
--                         "valign"  => true,
--                 ),
--                 "track"      => array(
--                         "default" => true,
--                         "kind"    => true,
--                         "label"   => true,
--                         "src"     => true,
--                         "srclang" => true,
--                 ),
--                 "tt"         => array(),
--                 "u"          => array(),
--                 "ul"         => array(
--                         "type" => true,
--                 ),
--                 "ol"         => array(
--                         "start"    => true,
--                         "type"     => true,
--                         "reversed" => true,
--                 ),
--                 "var"        => array(),
--                 "video"      => array(
--                         "autoplay"    => true,
--                         "controls"    => true,
--                         "height"      => true,
--                         "loop"        => true,
--                         "muted"       => true,
--                         "playsinline" => true,
--                         "poster"      => true,
--                         "preload"     => true,
--                         "src"         => true,
--                         "width"       => true,
--                 ),
--         );

--         --
--         -- @var array[] $allowedtags Array of KSES allowed HTML elements.
--         -- @since 1.0.0
--         --
--         $allowedtags = array(
--                 "a"          => array(
--                         "href"  => true,
--                         "title" => true,
--                 ),
--                 "abbr"       => array(
--                         "title" => true,
--                 ),
--                 "acronym"    => array(
--                         "title" => true,
--                 ),
--                 "b"          => array(),
--                 "blockquote" => array(
--                         "cite" => true,
--                 ),
--                 "cite"       => array(),
--                 "code"       => array(),
--                 "del"        => array(
--                         "datetime" => true,
--                 ),
--                 "em"         => array(),
--                 "i"          => array(),
--                 "q"          => array(
--                         "cite" => true,
--                 ),
--                 "s"          => array(),
--                 "strike"     => array(),
--                 "strong"     => array(),
--         );

--         --
--         -- @var string[] $allowedentitynames Array of KSES allowed HTML entity names.
--         -- @since 1.0.0
--         --
--         $allowedentitynames = array(
--                 "nbsp",
--                 "iexcl",
--                 "cent",
--                 "pound",
--                 "curren",
--                 "yen",
--                 "brvbar",
--                 "sect",
--                 "uml",
--                 "copy",
--                 "ordf",
--                 "laquo",
--                 "not",
--                 "shy",
--                 "reg",
--                 "macr",
--                 "deg",
--                 "plusmn",
--                 "acute",
--                 "micro",
--                 "para",
--                 "middot",
--                 "cedil",
--                 "ordm",
--                 "raquo",
--                 "iquest",
--                 "Agrave",
--                 "Aacute",
--                 "Acirc",
--                 "Atilde",
--                 "Auml",
--                 "Aring",
--                 "AElig",
--                 "Ccedil",
--                 "Egrave",
--                 "Eacute",
--                 "Ecirc",
--                 "Euml",
--                 "Igrave",
--                 "Iacute",
--                 "Icirc",
--                 "Iuml",
--                 "ETH",
--                 "Ntilde",
--                 "Ograve",
--                 "Oacute",
--                 "Ocirc",
--                 "Otilde",
--                 "Ouml",
--                 "times",
--                 "Oslash",
--                 "Ugrave",
--                 "Uacute",
--                 "Ucirc",
--                 "Uuml",
--                 "Yacute",
--                 "THORN",
--                 "szlig",
--                 "agrave",
--                 "aacute",
--                 "acirc",
--                 "atilde",
--                 "auml",
--                 "aring",
--                 "aelig",
--                 "ccedil",
--                 "egrave",
--                 "eacute",
--                 "ecirc",
--                 "euml",
--                 "igrave",
--                 "iacute",
--                 "icirc",
--                 "iuml",
--                 "eth",
--                 "ntilde",
--                 "ograve",
--                 "oacute",
--                 "ocirc",
--                 "otilde",
--                 "ouml",
--                 "divide",
--                 "oslash",
--                 "ugrave",
--                 "uacute",
--                 "ucirc",
--                 "uuml",
--                 "yacute",
--                 "thorn",
--                 "yuml",
--                 "quot",
--                 "amp",
--                 "lt",
--                 "gt",
--                 "apos",
--                 "OElig",
--                 "oelig",
--                 "Scaron",
--                 "scaron",
--                 "Yuml",
--                 "circ",
--                 "tilde",
--                 "ensp",
--                 "emsp",
--                 "thinsp",
--                 "zwnj",
--                 "zwj",
--                 "lrm",
--                 "rlm",
--                 "ndash",
--                 "mdash",
--                 "lsquo",
--                 "rsquo",
--                 "sbquo",
--                 "ldquo",
--                 "rdquo",
--                 "bdquo",
--                 "dagger",
--                 "Dagger",
--                 "permil",
--                 "lsaquo",
--                 "rsaquo",
--                 "euro",
--                 "fnof",
--                 "Alpha",
--                 "Beta",
--                 "Gamma",
--                 "Delta",
--                 "Epsilon",
--                 "Zeta",
--                 "Eta",
--                 "Theta",
--                 "Iota",
--                 "Kappa",
--                 "Lambda",
--                 "Mu",
--                 "Nu",
--                 "Xi",
--                 "Omicron",
--                 "Pi",
--                 "Rho",
--                 "Sigma",
--                 "Tau",
--                 "Upsilon",
--                 "Phi",
--                 "Chi",
--                 "Psi",
--                 "Omega",
--                 "alpha",
--                 "beta",
--                 "gamma",
--                 "delta",
--                 "epsilon",
--                 "zeta",
--                 "eta",
--                 "theta",
--                 "iota",
--                 "kappa",
--                 "lambda",
--                 "mu",
--                 "nu",
--                 "xi",
--                 "omicron",
--                 "pi",
--                 "rho",
--                 "sigmaf",
--                 "sigma",
--                 "tau",
--                 "upsilon",
--                 "phi",
--                 "chi",
--                 "psi",
--                 "omega",
--                 "thetasym",
--                 "upsih",
--                 "piv",
--                 "bull",
--                 "hellip",
--                 "prime",
--                 "Prime",
--                 "oline",
--                 "frasl",
--                 "weierp",
--                 "image",
--                 "real",
--                 "trade",
--                 "alefsym",
--                 "larr",
--                 "uarr",
--                 "rarr",
--                 "darr",
--                 "harr",
--                 "crarr",
--                 "lArr",
--                 "uArr",
--                 "rArr",
--                 "dArr",
--                 "hArr",
--                 "forall",
--                 "part",
--                 "exist",
--                 "empty",
--                 "nabla",
--                 "isin",
--                 "notin",
--                 "ni",
--                 "prod",
--                 "sum",
--                 "minus",
--                 "lowast",
--                 "radic",
--                 "prop",
--                 "infin",
--                 "ang",
--                 "and",
--                 "or",
--                 "cap",
--                 "cup",
--                 "int",
--                 "sim",
--                 "cong",
--                 "asymp",
--                 "ne",
--                 "equiv",
--                 "le",
--                 "ge",
--                 "sub",
--                 "sup",
--                 "nsub",
--                 "sube",
--                 "supe",
--                 "oplus",
--                 "otimes",
--                 "perp",
--                 "sdot",
--                 "lceil",
--                 "rceil",
--                 "lfloor",
--                 "rfloor",
--                 "lang",
--                 "rang",
--                 "loz",
--                 "spades",
--                 "clubs",
--                 "hearts",
--                 "diams",
--                 "sup1",
--                 "sup2",
--                 "sup3",
--                 "frac14",
--                 "frac12",
--                 "frac34",
--                 "there4",
--         );

--         --
--         -- @var string[] $allowedxmlentitynames Array of KSES allowed XML entity names.
--         -- @since 5.5.0
--         --
--         $allowedxmlentitynames = array(
--                 "amp",
--                 "lt",
--                 "gt",
--                 "apos",
--                 "quot",
--         );

--         $allowedposttags = array_map( "_wp_add_global_attributes", $allowedposttags );
-- end; else then
--         $allowedtags     = wp_kses_array_lc( $allowedtags );
--         $allowedposttags = wp_kses_array_lc( $allowedposttags );
-- end;

   -------------
   -- Wp_KSES --
   -------------

   function Wp_KSES (Item              : String;
                     Allowed_HTML      : Array_Type;
                     Allowed_Protocols : List_Type := Empty_List)
                     return String
   is
      use Inc_Functions;

      Allowed_Protocols_2 : constant List_Type :=
        (if Allowed_Protocols.Is_Empty
         then Wp_Allowed_Protocols
         else Allowed_Protocols);

      String_3 : constant String :=
        Wp_KSES_No_Null (Item, To_Array (List => (1 =>
                                 Build ("slash_zero", "keep"))));

      String_2 : constant String :=
        Wp_KSES_Normalize_Entities (String_3);

      String_1 : constant String :=
        Wp_KSES_Hook (String_2, Allowed_HTML, Allowed_Protocols);
   begin
      return Wp_KSES_Split (String_1, Allowed_HTML, Allowed_Protocols);
   end Wp_KSES;

-- --
-- -- Filters one HTML attribute and ensures its value is allowed.
-- --
-- -- This function can escape data in some situations where `wp_kses()` must strip the whole attribute.
-- --
-- -- @since 4.2.3
-- --
-- -- @param string $string  The "whole" attribute, including name and value.
-- -- @param string $element The HTML element name to which the attribute belongs.
-- -- @return string Filtered attribute.
-- --
-- function wp_kses_one_attr( $string, $element ) then
--         $uris              = wp_kses_uri_attributes();
--         $allowed_html      = wp_kses_allowed_html( "post" );
--         $allowed_protocols = wp_allowed_protocols();
--         $string            = wp_kses_no_null( $string, array( "slash_zero" => "keep" ) );

--         // Preserve leading and trailing whitespace.
--         $matches = array();
--         preg_match( "/^\s*/", $string, $matches );
--         $lead = $matches[0];
--         preg_match( "/\s*$/", $string, $matches );
--         $trail = $matches[0];
--         if ( empty( $trail ) ) then
--                 $string = substr( $string, strlen( $lead ) );
--         end; else then
--                 $string = substr( $string, strlen( $lead ), -strlen( $trail ) );
--         end;

--         // Parse attribute name and value from input.
--         $split = preg_split( "/\s*=\s*/", $string, 2 );
--         $name  = $split[0];
--         if ( count( $split ) == 2 ) then
--                 $value = $split[1];

--                 // Remove quotes surrounding $value.
--                 // Also guarantee correct quoting in $string for this one attribute.
--                 if ( "" === $value ) then
--                         $quote = "";
--                 end; else then
--                         $quote = $value[0];
--                 end;
--                 if ( """ === $quote || """ === $quote ) then
--                         if ( substr( $value, -1 ) != $quote ) then
--                                 return "";
--                         end;
--                         $value = substr( $value, 1, -1 );
--                 end; else then
--                         $quote = """;
--                 end;

--                 // Sanitize quotes, angle braces, and entities.
--                 $value = esc_attr( $value );

--                 // Sanitize URI values.
--                 if ( in_array( strtolower( $name ), $uris, true ) ) then
--                         $value = wp_kses_bad_protocol( $value, $allowed_protocols );
--                 end;

--                 $string = "$name=$quote$value$quote";
--                 $vless  = "n";
--         end; else then
--                 $value = "";
--                 $vless = "y";
--         end;

--         // Sanitize attribute by name.
--         wp_kses_attr_check( $name, $value, $string, $vless, $element, $allowed_html );

--         // Restore whitespace.
--         return $lead . $string . $trail;
-- end;

   --------------------------
   -- Wp_KSES_Allowed_HTML --
   --------------------------

   function Wp_KSES_Allowed_HTML (Context : Array_Type := Empty_Array) -- ""
                                  return Array_Type
   is
      use Php;
      use Php.Types;
--        global $allowedposttags, $allowedtags, $allowedentitynames;
   begin
      if Is_Array (Context) then
         declare
            -- When `$context` is an array it's actually an array of allowed HTML
            -- elements and attributes.
            HTML    : constant Array_Type := Context;
            Context : constant String     := "explicit";

            --
            -- Filters the HTML tags that are allowed for a given context.
            --
            -- HTML tags and attribute names are case-insensitive in HTML but must be
            -- added to the KSES allow list in lowercase. An item added to the allow
            -- list in upper or mixed case will not recognized as permitted by KSES.
            --
            -- @since 3.5.0
            --
            -- @param array[] $html    Allowed HTML tags.
            -- @param string  $context Context name.
            --
         begin
            return Apply_Filters ("wp_kses_allowed_html", HTML, Context);
         end;
      end if;

      return Empty_Array; -- added

        -- switch ( $context ) then
        --         case "post":
        --                 -- This filter is documented in wp-includes/kses.php--
        --                 $tags = apply_filters( "wp_kses_allowed_html", $allowedposttags, $context );

        --                 -- 5.0.1 removed the `<form>` tag, allow it if a filter is allowing it's sub-elements `<input>` or `<select>`.
        --                 if ( ! CUSTOM_TAGS && ! isset( $tags["form"] ) && ( isset( $tags["input"] ) || isset( $tags["select"] ) ) ) then
        --                         $tags = $allowedposttags;

        --                         $tags["form"] = array(
        --                                 "action"         => true,
        --                                 "accept"         => true,
        --                                 "accept-charset" => true,
        --                                 "enctype"        => true,
        --                                 "method"         => true,
        --                                 "name"           => true,
        --                                 "target"         => true,
        --                         );

        --                         -- This filter is documented in wp-includes/kses.php--
        --                         $tags = apply_filters( "wp_kses_allowed_html", $tags, $context );
        --                 end;

        --                 return $tags;

        --         case "user_description":
        --         case "pre_user_description":
        --                 $tags             = $allowedtags;
        --                 $tags["a"]["rel"] = true;
        --                 -- This filter is documented in wp-includes/kses.php--
        --                 return apply_filters( "wp_kses_allowed_html", $tags, $context );

        --         case "strip":
        --                 -- This filter is documented in wp-includes/kses.php--
        --                 return apply_filters( "wp_kses_allowed_html", array(), $context );

        --         case "entities":
        --                 -- This filter is documented in wp-includes/kses.php--
        --                 return apply_filters( "wp_kses_allowed_html", $allowedentitynames, $context );

        --         case "data":
        --         default:
        --                 -- This filter is documented in wp-includes/kses.php--
        --                 return apply_filters( "wp_kses_allowed_html", $allowedtags, $context );
        -- end;
   end Wp_KSES_Allowed_HTML;

   ------------------
   -- Wp_KSES_Hook --
   ------------------

   function Wp_KSES_Hook (Item              : String;
                          Allowed_HTML      : Array_Type;
                          Allowed_Protocols : List_Type)
                          return String
   is
--    use Inc_Plugins;
   begin
      --
      -- Filters content to be run through KSES.
      --
      -- @since 2.3.0
      --
      -- @param string         $string            Content to filter through KSES.
      -- @param array[]|string $allowed_html      An array of allowed HTML elements
      --                                          and attributes, or a context name
      --                                          such as "post". See
      --                                          wp_kses_allowed_html() for the list
      --                                          of accepted context names.
      -- @param string[]       $allowed_protocols Array of allowed URL protocols.
      --
      return Apply_Filters ("pre_kses", Item, Allowed_HTML, Allowed_Protocols);
   end Wp_KSES_Hook;

-- --
-- -- Returns the version number of KSES.
-- --
-- -- @since 1.0.0
-- --
-- -- @return string KSES version number.
-- --
-- function wp_kses_version() then
--         return "0.2.2";
-- end;

   Pass_Allowed_HTML      : Array_Type;
   Pass_Allowed_Protocols : List_Type;

   -------------------
   -- Wp_KSES_Split --
   -------------------

   function Wp_KSES_Split (Item              :  String;
                           Allowed_HTML      : Array_Type;
                           Allowed_Protocols : List_Type)
                           return String
   is
      use Php;
      use Php.Preg;
   begin
      Pass_Allowed_HTML      := Allowed_HTML;
      Pass_Allowed_Protocols := Allowed_Protocols;

      return Preg_Replace_Callback ("%(<!--.*?(-->|$))|(<[^>]*(>|$)|>)%",
                                    X_Wp_KSES_Split_Callback'Access, Item);
   end Wp_KSES_Split;

   ----------------------------
   -- Wp_KSES_URI_Attributes --
   ----------------------------

   function Wp_KSES_URI_Attributes
            return List_Type
   is
      use Hb_Common;
      use Inc_Plugins;

      URI_Attributes_2 : constant List_Type := To_List (List => (
                +"action",
                +"archive",
                +"background",
                +"cite",
                +"classid",
                +"codebase",
                +"data",
                +"formaction",
                +"href",
                +"icon",
                +"longdesc",
                +"manifest",
                +"poster",
                +"profile",
                +"src",
                +"usemap",
                +"xmlns"
      ));

      --
      -- Filters the list of attributes that are required to contain a URL.
      --
      -- Use this filter to add any `data-` attributes that are required to be
      -- validated as a URL.
      --
      -- @since 5.0.1
      --
      -- @param string[] $uri_attributes HTML attribute names whose value contains
      --                                  a URL.
      --
      URI_Attributes : constant List_Type :=
        Apply_Filters ("wp_kses_uri_attributes", URI_Attributes_2);
   begin
      return URI_Attributes;
   end Wp_KSES_URI_Attributes;

   ------------------------------
   -- X_Wp_KSES_Split_Callback --
   ------------------------------

   function X_Wp_KSES_Split_Callback (Match : List_Type)
                                      return String
   is
      use Hb_Common;
   begin
      return
        Wp_KSES_Split2 (-Match.First_Element, -- (0),
                        Pass_Allowed_HTML,
                        Pass_Allowed_Protocols);

   end X_Wp_KSES_Split_Callback;

   --------------------
   -- Wp_KSES_Split2 --
   --------------------

   function Wp_KSES_Split2 (Item              : String;
                            Allowed_HTML      : Array_Type;
                            Allowed_Protocols : List_Type)
                            return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Preg;
      use Php.Strings;
      use Php.Types;

      String_2  : Unbounded_String := +Wp_KSES_Stripslashes (Item);
      Newstring : Unbounded_String;
   begin
      -- It matched a ">" character.
      if "<" /= Substr (-String_2, 0, 1) then
         return "&gt;";
      end if;

      -- Allow HTML comments.
      if "<!--" = Substr (-String_2, 0, 4) then
         String_2 := +Str_Replace (To_List (List => (+"<!--", +"-->")), "", -String_2);

         loop
            Newstring := +Wp_KSES (-String_2, Allowed_HTML, Allowed_Protocols);
            exit when Newstring /= String_2;
            String_2 := Newstring;
         end loop;

         if "" = String_2 then
            return "";
         end if;

         -- Prevent multiple dashes in comments.
         String_2 := +Preg_Replace ("/--+/", "-", -String_2);

         -- Prevent three dashes closing a comment.
         String_2 := +Preg_Replace ("/-$/", "", -String_2);
         return "<!--" & (-String_2) & "-->";
      end if;

      -- It's seriously malformed.
      declare
         Matches : List_Type;
         Num     : constant Integer :=
           Preg_Match ("%^<\s*(/\s*)?([a-zA-Z0-9-]+)([^>]*)>?$%",
                       -String_2, Matches);
      begin
         if Num = 0 then
            return "";
         end if;

         declare
            Slash    : constant String := Trim (-Matches (1));
            Elem     : constant String := -Matches (2);
            Attrlist : constant String := -Matches (3);

            Allowed_HTML_2 : constant Array_Type :=
              (if not Is_Array (Allowed_HTML)
               then Wp_KSES_Allowed_HTML (Allowed_HTML)
               else Allowed_HTML);
         begin

            -- They are using a not allowed HTML element.
            if not Isset (Allowed_HTML_2, Strtolower (Elem)) then
               return "";
            end if;

            -- No attributes are allowed for closing elements.
            if "" /= Slash then
               return "</" & Elem & ">";
            end if;

            return Wp_KSES_Attr (Elem, Attrlist,
                                 Allowed_HTML_2, Allowed_Protocols);
         end;
      end;
   end Wp_KSES_Split2;

   -------------------
   -- Filter_Limits --
   -------------------

   function Filter_Limits (Required_Attr_Limits : Array_Type)
                           return Boolean;

   function Filter_Limits (Required_Attr_Limits : Array_Type)
                           return Boolean
   is
--    use Hb_Common;
   begin
      return
         Isset (Required_Attr_Limits, "required") and then
         True = As_Boolean (Get (Required_Attr_Limits, "required"));
   end Filter_Limits;

   ------------------
   -- Wp_KSES_Attr --
   ------------------

   function Wp_KSES_Attr (Element           : String;
                          Attr              : String;
                          Allowed_HTML      : Array_Type;
                          Allowed_Protocols : List_Type)
                          return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Preg;
      use Php.Strings;
      use Php.Types;

      Allowed_HTML_2 : constant Array_Type :=
        (if not Is_Array (Allowed_HTML)
         then Wp_KSES_Allowed_HTML (Allowed_HTML)
         else Allowed_HTML);

      -- Is there a closing XHTML slash at the end of the attributes?
      XHTML_Slash : constant String :=
        (if Preg_Match ("%\s*/\s*$%", Attr)
        then " /" else "");

      -- Are any attributes allowed at all for this element?
      Element_Low : constant String := Strtolower (Element);
   begin
      if
        Empty (Allowed_HTML_2, Element_Low) or else
        True = As_Boolean (Get (Allowed_HTML_2, Element_Low))
      then
         return "<" & Element & XHTML_Slash & " & >";
      end if;

      declare
         -- Split it.
         Attrarr : constant Array_Type := Wp_KSES_Hair (Attr, Allowed_Protocols);

         -- Check if there are attributes that are required.
         Required_Attrs : constant Array_Type :=
           Array_Filter (Arry     => As_Array (Get (Allowed_HTML, Element_Low)),
                         Callback => Filter_Limits'Access);

         --
         -- If a required attribute check fails, we can return nothing for a
         -- self-closing tag, but for a non-self-closing tag the best option is to
         -- return the element with attributes, as KSES doesn't handle matching the
         -- relevant closing tag.
         --
         Stripped_Tag : constant String := (if Empty (XHTML_Slash)
                                            then "<" & Element & ">" else "");

         Attr2 : Unbounded_String;
      begin
         -- Go through $attrarr, and save the allowed attributes for this element in
         -- $attr2.
         for Arreach in Attrarr.Iterate loop
            declare
               Arry     : constant Array_Type := As_Array (Arrays.Element (Arreach));
               Name     :          String     := As_String (Get (Arry, "name"));
               Value    :          String     := As_String (Get (Arry, "value"));
               Whole    :          String     := As_String (Get (Arry, "whole"));
               Vless    : constant String     := As_String (Get (Arry, "vless"));
               Name_Low : constant String     := Strtolower (Name);

               -- Check if this attribute is required.
               Required : constant Boolean := Isset (Required_Attrs, Name_Low);
            begin
               if
                 Wp_KSES_Attr_Check (Name, Value, Whole, Vless,
                                     Element, Allowed_HTML)
               then
                  Append (Attr2, " " & Whole);

                  -- If this was a required attribute, we can mark it as found.
                  if Required then
                     Delete (Ref (Required_Attrs, Name_Low));
--                   Unset (Required_Attrs (Name_Low));
                     null;
                  end if;

               elsif Required then
                  -- This attribute was required, but didn"t pass the check. The entire
                  -- tag is not allowed.
                  return Stripped_Tag;
               end if;
            end;
         end loop;

         -- If some required attributes weren't set, the entire tag is not allowed.
         if not Required_Attrs.Is_Empty then
--       if not Empty (Required_Attrs) then
            return Stripped_Tag;
         end if;

         declare
            -- Remove any "<" or ">" characters.
            Attr3 : constant String := Preg_Replace ("/[<>]/", "", -Attr2);
         begin
            return "<" & Element & Attr3 & XHTML_Slash & ">";
         end;
      end;
   end Wp_KSES_Attr;

   ------------------------
   -- Wp_KSES_Attr_Check --
   ------------------------

   function Wp_KSES_Attr_Check (Name         : in out String;
                                Value        : in out String;
                                Whole        : in out String;
                                Vless        : String;
                                Element      : String;
                                Allowed_HTML : Array_Type)
                                return Boolean
   is
      use Hb_Common;
      use Php;
      use Php.Preg;
      use Php.Strings;

      Name_Low    : constant String := Strtolower (Name);
      Element_Low : constant String := Strtolower (Element);

      Allowed_Attr : Array_Type :=
        As_Array (Get (Allowed_HTML, Element_Low));
   begin
      if not Isset (Allowed_HTML, Element_Low) then
         Name  := "";
         Value := "";
         Whole := "";
         return False;
      end if;

      if
        not Isset (Allowed_Attr, Name_Low) or else
        "" = As_String (Get (Allowed_Attr, Name_Low))
      then
         --
         -- Allow `data-*` attributes.
         --
         -- When specifying `$allowed_html`, the attribute name should be set as
         -- `data-*` (not to be mixed with the HTML 4.0 `data` attribute, see
         -- https://www.w3.org/TR/html40/struct/objects.html#adef-data).
         --
         -- Note: the attribute name should only contain `A-Za-z0-9_-` chars,
         -- double hyphens `--` are not accepted by WordPress.
         --
         declare
            Match : List_Type;
         begin
            if
              Strpos (Name_Low, "data-") = 0     and then
              not Empty (Allowed_Attr, "data-*") and then
              0 /= Preg_Match ("/^data(?:-[a-z0-9_]+)+$/", Name_Low, Match)
            then
               --
               -- Add the whole attribute name to the allowed attributes and set any
               -- restrictions for the `data-*` attribute values for the current
               -- element.
               --
               Set (Allowed_Attr,
                    Key   => -Match (1),    -- (0)
                    Value => Get (Allowed_Attr, "data-*"));
            else
               Name  := "";
               Value := "";
               Whole := "";
               return False;
            end if;
         end;
      end if;

      if "style" = Name_Low then
         declare
            New_Value : constant String := SafeCSS_Filter_Attr (Value);
         begin
            if Empty (New_Value) then
               Name  := "";
               Value := "";
               Whole := "";
               return False;
            end if;

            Whole := Str_Replace (Value, New_Value, Whole);
            Value := New_Value;
         end;
      end if;

      declare
         Rec : constant Multi_Type :=
           Arrays.Element (Allowed_Attr.Find (Name_Low));
      begin
         if Kind_Of (Rec) = Kind_Array then
--       if Is_Array (Allowed_Attr (Name_Low)) then
            -- There are some checks.
            for A in As_Array (Rec).Iterate loop
--          for A in Allowed_Attr (Name_Low).Iterate loop
               declare
                  Currkey : constant String := Key (A);
                  Currval : constant String := As_String (Arrays.Element (A));
               begin
                  if not Wp_KSES_Check_Attr_Val (Value, Vless, Currkey, Currval) then
                     Name  := "";
                     Value := "";
                     Whole := "";
                     return False;
                  end if;
               end;
            end loop;
         end if;
      end;
      return True;
   end Wp_KSES_Attr_Check;

   ------------------
   -- Wp_KSES_Hair --
   ------------------

   function Wp_KSES_Hair (Attr              : String;
                          Allowed_Protocols : List_Type)
                          return Array_Type
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;

      Attr_2   : Unbounded_String := +Attr;
      Attrarr  : Array_Type;
      Mode     : Natural range 0 .. 2 := 0;
      Attrname : Unbounded_String;
      URIs     : constant List_Type := Wp_KSES_URI_Attributes;
      Working  : Boolean;
   begin
      -- Loop through the whole attribute list.

      while Length (Attr_2) /= 0 loop
         Working := False; -- Was the last operation successful?

         case Mode is

         when 0 =>
            declare
               Match : List_Type;
            begin
               if 0 /= Preg_Match ("/^([_a-zA-Z][-_a-zA-Z0-9:.]*)/", -Attr_2, Match) then
                  Attrname := Match (1);
                  Working  := True;
                  Mode     := 1;
                  Attr_2   := +Preg_Replace ("/^[_a-zA-Z][-_a-zA-Z0-9:.]*/", "", -Attr_2);
               end if;
            end;

         when 1 =>
            if Preg_Match ("/^\s*=\s*/", Attr) then -- Equals sign.
               Working := True;
               Mode    := 2;
               Attr_2  := +Preg_Replace ("/^\s*=\s*/", "", -Attr_2);

            elsif Preg_Match ("/^\s+/", -Attr_2) then -- Valueless.
               Working := True;
               Mode    := 0;
               if False = Array_Key_Exists (-Attrname, Attrarr) then
                  Set (Attrarr, -Attrname, From_Array (To_Array (List => (
                       Build ("name",  -Attrname),
                       Build ("value", ""),
                       Build ("whole", -Attrname),
                       Build ("vless", "y")
                  ))));
               end if;
               Attr_2 := +Preg_Replace ("/^\s+/", "", -Attr_2);
            end if;

         when 2 =>
            declare
               Match   : List_Type;
               Thisval : Unbounded_String;
            begin
               if 0 /= Preg_Match ("%^'([^']*)'(\s+|/?$)%", -Attr_2, Match) then
                  -- "value"
                  Thisval := Match (1);
                  if In_Array (Strtolower (-Attrname), URIs, True) then
                     Thisval := +Wp_KSES_Bad_Protocol (-Thisval, Allowed_Protocols);
                  end if;

                  if False = Array_Key_Exists (-Attrname, Attrarr) then
                     Set (Attrarr, -Attrname, From_Array (To_Array (List => (
                       Build ("name",  -Attrname),
                       Build ("value", -Thisval),
                       Build ("whole", -("""" & Attrname & "=\""" & Thisval & "\""")),
                       Build ("vless", "n")
                     ))));
                  end if;
                  Working := True;
                  Mode    := 0;
                  Attr_2  := +Preg_Replace ("/^'[^']*'(\s+|$)/", "", -Attr_2);

               elsif 0 /= Preg_Match ("%^'([^']*)'(\s+|/?$)%", -Attr_2, Match) then
                  -- "value"
                  Thisval := Match (1);
                  if In_Array (Strtolower (-Attrname), URIs, True) then
                     Thisval := +Wp_KSES_Bad_Protocol (-Thisval, Allowed_Protocols);
                  end if;

                  if False = Array_Key_Exists (-Attrname, Attrarr) then
                     Set (Attrarr, -Attrname, From_Array (To_Array (List => (
                       Build ("name",  -Attrname),
                       Build ("value", -Thisval),
                       Build ("whole", -("""" & Attrname & "=""" & Thisval & """")),
                       Build ("vless", "n")
                     ))));
                  end if;
                  Working := True;
                  Mode    := 0;
                  Attr_2  := +Preg_Replace ("/^'[^']*'(\s+|$)/", "", -Attr_2);

               elsif 0 /= Preg_Match ("%^([^\s\""]+)(\s+|/?$)%", -Attr_2, Match) then
                  -- value
                  Thisval := Match (1);
                  if In_Array (Strtolower (-Attrname), URIs, True) then
                     Thisval := +Wp_KSES_Bad_Protocol (-Thisval, Allowed_Protocols);
                  end if;

                  if False = Array_Key_Exists (-Attrname, Attrarr) then
                     Set (Attrarr, -Attrname, From_Array (To_Array (List => (
                       Build ("name",  -Attrname),
                       Build ("value", -Thisval),
                       Build ("whole", -("""" & Attrname & "=\""" & Thisval & "\""")),
                       Build ("vless", "n")
                     ))));
                  end if;
                  -- We add quotes to conform to W3C's HTML spec.
                  Working := True;
                  Mode    := 0;
                  Attr_2  := +Preg_Replace ("%^[^\s\""]+(\s+|$)%", "", -Attr_2);
               end if;
            end;
         end case;

         if not Working then -- Not well-formed, remove and try again.
            Attr_2 := +Wp_KSES_HTML_Error (-Attr_2);
            Mode   := 0;
         end if;

      end loop; -- End while.

      if 1 = Mode and then False = Array_Key_Exists (-Attrname, Attrarr) then
         -- Special case, for when the attribute list ends with a valueless
         -- attribute like "selected".
         Set (Attrarr, -Attrname, From_Array (To_Array (List => (
           Build ("name",  -Attrname),
           Build ("value", ""),
           Build ("whole", -Attrname),
           Build ("vless", "y")
         ))));
      end if;

      return Attrarr;
   end Wp_KSES_Hair;

-- --
-- -- Finds all attributes of an HTML element.
-- --
-- -- Does not modify input.  May return "evil" output.
-- --
-- -- Based on `wp_kses_split2()` and `wp_kses_attr()`.
-- --
-- -- @since 4.2.3
-- --
-- -- @param string $element HTML element.
-- -- @return array|false List of attributes found in the element. Returns false on failure.
-- --
-- function wp_kses_attr_parse( $element ) then
--         $valid = preg_match( "%^(<\s*)(/\s*)?([a-zA-Z0-9]+\s*)([^>]*)(>?)$%", $element, $matches );
--         if ( 1 !== $valid ) then
--                 return false;
--         end;

--         $begin  = $matches[1];
--         $slash  = $matches[2];
--         $elname = $matches[3];
--         $attr   = $matches[4];
--         $end    = $matches[5];

--         if ( "" !== $slash ) then
--                 // Closing elements do not get parsed.
--                 return false;
--         end;

--         // Is there a closing XHTML slash at the end of the attributes?
--         if ( 1 === preg_match( "%\s*/\s*$%", $attr, $matches ) ) then
--                 $xhtml_slash = $matches[0];
--                 $attr        = substr( $attr, 0, -strlen( $xhtml_slash ) );
--         end; else then
--                 $xhtml_slash = "";
--         end;

--         // Split it.
--         $attrarr = wp_kses_hair_parse( $attr );
--         if ( false === $attrarr ) then
--                 return false;
--         end;

--         // Make sure all input is returned by adding front and back matter.
--         array_unshift( $attrarr, $begin . $slash . $elname );
--         array_push( $attrarr, $xhtml_slash . $end );

--         return $attrarr;
-- end;

-- --
-- -- Builds an attribute list from string containing attributes.
-- --
-- -- Does not modify input.  May return "evil" output.
-- -- In case of unexpected input, returns false instead of stripping things.
-- --
-- -- Based on `wp_kses_hair()` but does not return a multi-dimensional array.
-- --
-- -- @since 4.2.3
-- --
-- -- @param string $attr Attribute list from HTML element to closing HTML element tag.
-- -- @return array|false List of attributes found in $attr. Returns false on failure.
-- --
-- function wp_kses_hair_parse( $attr ) then
--         if ( "" === $attr ) then
--                 return array();
--         end;

--         // phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound -- don"t remove regex indentation
--         $regex =
--                 "(?:"
--                 .     "[_a-zA-Z][-_a-zA-Z0-9:.]*" // Attribute name.
--                 . "|"
--                 .     "\[\[?[^\[\]]+\]\]?"        // Shortcode in the name position implies unfiltered_html.
--                 . ")"
--                 . "(?:"               // Attribute value.
--                 .     "\s*=\s*"       // All values begin with "=".
--                 .     "(?:"
--                 .         ""[^"]*""   // Double-quoted.
--                 .     "|"
--                 .         ""[^"]*""   // Single-quoted.
--                 .     "|"
--                 .         "[^\s"\"]+" // Non-quoted.
--                 .         "(?:\s|$)"  // Must have a space.
--                 .     ")"
--                 . "|"
--                 .     "(?:\s|$)"      // If attribute has no value, space is required.
--                 . ")"
--                 . "\s*";              // Trailing space is optional except as mentioned above.
--         // phpcs:enable

--         // Although it is possible to reduce this procedure to a single regexp,
--         // we must run that regexp twice to get exactly the expected result.

--         $validation = "%^($regex)+$%";
--         $extraction = "%$regex%";

--         if ( 1 === preg_match( $validation, $attr ) ) then
--                 preg_match_all( $extraction, $attr, $attrarr );
--                 return $attrarr[0];
--         end; else then
--                 return false;
--         end;
-- end;

   ----------------------------
   -- Wp_KSES_Check_Attr_Val --
   ----------------------------

   function Wp_KSES_Check_Attr_Val (Value      : String;
                                    Vless      : String;
                                    Checkname  : String;
                                    Checkvalue : String)
                                    return Boolean
   is
      use Php;
      use Php.Preg;
      use Php.Strings;

      Ok : Boolean := True;
      Check_Low : constant String := Strtolower (Checkname);
   begin
      if Check_Low = "maxlen" then
         --
         -- The maxlen check makes sure that the attribute value has a length not
         -- greater than the given value. This can be used to avoid Buffer Overflows
         -- in WWW clients and various Internet servers.
         --
         if Value'Length > Integer'Value (Checkvalue) then
            Ok := False;
         end if;

      elsif Check_Low = "minlen" then
         --
         -- The minlen check makes sure that the attribute value has a length not
         -- smaller than the given value.
         --
         if Value'Length < Integer'Value (Checkvalue) then
            Ok := False;
         end if;

      elsif Check_Low = "maxval" then
         --
         -- The maxval check does two things: it checks that the attribute value is
         -- an integer from 0 and up, without an excessive amount of zeroes or
         -- whitespace (to avoid Buffer Overflows). It also checks that the attribute
         -- value is not greater than the given value.
         -- This check can be used to avoid Denial of Service attacks.
         --
         if not Preg_Match ("/^\s{0,6}[0-9]{1,6}\s{0,6}$/", Value) then
            Ok := False;
         end if;
         if Value > Checkvalue then
            Ok := False;
         end if;

      elsif Check_Low = "minval" then
         --
         -- The minval check makes sure that the attribute value is a positive integer,
         -- and that it is not smaller than the given value.
         --
         if not Preg_Match ("/^\s{0,6}[0-9]{1,6}\s{0,6}$/", Value) then
            Ok := False;
         end if;
         if Value < Checkvalue then
            Ok := False;
         end if;

      elsif Check_Low = "valueless" then
         --
         -- The valueless check makes sure if the attribute has a value
         -- (like `<a href="blah">`) or not (`<option selected>`). If the given value
         -- is a "y" or a "Y", the attribute must not have a value.
         -- If the given value is an "n" or an "N", the attribute must have a value.
         --
         if Strtolower (Checkvalue) /= Vless then
            Ok := False;
         end if;

      -- elsif Check_Low = "values" then
      --    --
      --    -- The values check is used when you want to make sure that the attribute
      --    -- has one of the given values.
      --    --
      --    if False = Array_Search (Strtolower (Value), Checkvalue, True) then
      --       Ok := False;
      --    end if;

      -- elsif Check_Low = "value_callback" then
      --    --
      --    -- The value_callback check is used when you want to make sure that the
      --    -- attribute value is accepted by the callback function.
      --    --
      --    if not Call_User_Func (Checkvalue, Value) then
      --       Ok := False;
      --    end if;

      end if; -- End switch.

      return Ok;
   end Wp_KSES_Check_Attr_Val;

   --------------------------
   -- Wp_KSES_Bad_Protocol --
   --------------------------

   function Wp_KSES_Bad_Protocol (Item              : String;
                                  Allowed_Protocols : List_Type)
                                  return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;

      Item_2          : Unbounded_String := +Wp_KSES_No_Null (Item);
      Iterations      : Natural := 0;
      Original_String : Unbounded_String;
   begin
      loop
         Original_String := Item_2;
         Item_2          := +Wp_KSES_Bad_Protocol_Once (-Item_2, Allowed_Protocols);

         exit when Original_String = Item_2;
         Iterations := Iterations + 1;
         exit when Iterations >= 6;
      end loop;

      if Original_String /= Item_2 then
         return "";
      end if;

      return -Item_2;
   end Wp_KSES_Bad_Protocol;

   ---------------------
   -- Wp_KSES_No_Null --
   ---------------------

   function Wp_KSES_No_Null (Item    : String;
                             Options : Array_Type := Empty_Array) -- null
                             return String
   is
--    use Hb_Common;
      use Php;
      use Php.Preg;

      Options_2 : constant Array_Type :=
        (if not Isset (Options, "slash_zero")
         then To_Array (List => (1 => Build ("slash_zero", "remove")))
         else Options);

      String_2 : constant String :=
        Preg_Replace ("/[\x00-\x08\x0B\x0C\x0E-\x1F]/", "", Item);

      String_3 : constant String :=
        (if "remove" = As_String (Get (Options_2, "slash_zero"))
         then Preg_Replace ("/\\\\+0+/", "", String_2)
         else String_2);
   begin
      return String_3;
   end Wp_KSES_No_Null;

   --------------------------
   -- wp_KSES_Stripslashes --
   --------------------------

   function Wp_KSES_Stripslashes (Item : String)
                                  return String
   is
      use Php;
      use Php.Preg;
   begin
      return Preg_Replace ("%\\\\'%", """", Item);
   end Wp_KSES_Stripslashes;

-- --
-- -- Converts the keys of an array to lowercase.
-- --
-- -- @since 1.0.0
-- --
-- -- @param array $inarray Unfiltered array.
-- -- @return array Fixed array with all lowercase keys.
-- --
-- function wp_kses_array_lc( $inarray ) then
--         $outarray = array();

--         foreach ( (array) $inarray as $inkey => $inval ) then
--                 $outkey              = strtolower( $inkey );
--                 $outarray[ $outkey ] = array();

--                 foreach ( (array) $inval as $inkey2 => $inval2 ) then
--                         $outkey2                         = strtolower( $inkey2 );
--                         $outarray[ $outkey ][ $outkey2 ] = $inval2;
--                 end;
--         end;

--         return $outarray;
-- end;

   ------------------------
   -- Wp_KSES_HTML_Error --
   ------------------------

   function Wp_KSES_HTML_Error (Item : String)
                                return String
   is
      use Php;
      use Php.Preg;
   begin
      return Preg_Replace ("/^(""[^""]*(""|$)|\""[^\""]*(\""|$)|\S)*\s*/",
                           "", Item);
   end Wp_KSES_HTML_Error;

   -------------------------------
   -- Wp_KSES_Bad_Protocol_Once --
   -------------------------------

   function Wp_KSES_Bad_Protocol_Once (Item              : String;
                                       Allowed_Protocols : List_Type;
                                       Count             : Natural := 1)
                                       return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Preg;
      use Php.Strings;

      Count_2 : Natural := Count;

      Item_3 : constant String :=
        Preg_Replace ("/(&#0*58(?![;0-9])|&#x0*3a(?![;a-f0-9]))/i", "$1;", Item);

      Item_2 : constant List_Type :=
        Preg_Split ("/:|&#0*58;|&#x0*3a;|&colon;/i", Item_3, 2);

      Item_4 : Unbounded_String;
   begin
      if
        Isset (-Item_2 (1)) and then
        not Preg_Match ("%/\?%", -Item_2 (1)) -- (0)
      then
         Item_4 := +Trim (-Item_2 (2)); -- (1)
         declare
            Protocol : constant String :=
              Wp_KSES_Bad_Protocol_Once2 (-Item_2 (1), -- (0)
                                          Allowed_Protocols);
         begin
            if "feed:" = Protocol then
               if Count > 2 then
                  return "";
               end if;
               Count_2 := Count_2 + 1;
               Item_4 := +Wp_KSES_Bad_Protocol_Once (-Item_4, Allowed_Protocols,
                                                     Count_2);
               if Empty (-Item_4) then
                  return -Item_4;
               end if;
            end if;
            Item_4 := Protocol & Item_4;
         end;
      end if;

      return -Item_4;
   end Wp_KSES_Bad_Protocol_Once;

   --------------------------------
   -- Wp_KSES_Bad_Protocol_Once2 --
   --------------------------------

   function Wp_KSES_Bad_Protocol_Once2 (Item              : String;
                                        Allowed_Protocols : List_Type)
                                        return String
   is
      use Hb_Common;
      use Php;
      use Php.Preg;
      use Php.Strings;

      String_5 : constant String := Wp_KSES_Decode_Entities (Item);
      String_4 : constant String := Preg_Replace ("/\s/", "", String_5);
      String_3 : constant String := Wp_KSES_No_Null (String_4);
      String_2 : constant String := Strtolower (String_3);

      Allowed : Boolean := False;
   begin
      for One_Protocol of Allowed_Protocols loop
         if Strtolower (-One_Protocol) = String_2 then
            Allowed := True;
            exit;
         end if;
      end loop;

      if Allowed then
         return String_2 & ":";
      else
         return "";
      end if;
   end Wp_KSES_Bad_Protocol_Once2;

-- --
-- -- Converts and fixes HTML entities.
-- --
-- -- This function normalizes HTML entities. It will convert `AT&T` to the correct
-- -- `AT&amp;T`, `&#00058;` to `&#058;`, `&#XYZZY;` to `&amp;#XYZZY;` and so on.
-- --
-- -- When `$context` is set to "xml", HTML entities are converted to their code points.  For
-- -- example, `AT&T&hellip;&#XYZZY;` is converted to `AT&amp;T…&amp;#XYZZY;`.
-- --
-- -- @since 1.0.0
-- -- @since 5.5.0 Added `$context` parameter.
-- --
-- -- @param string $string  Content to normalize entities.
-- -- @param string $context Context for normalization. Can be either "html" or "xml".
-- --                        Default "html".
-- -- @return string Content with normalized entities.
-- --
-- function wp_kses_normalize_entities( $string, $context = "html" ) then
--         // Disarm all entities by converting & to &amp;
--         $string = str_replace( "&", "&amp;", $string );

--         // Change back the allowed entities in our list of allowed entities.
--         if ( "xml" === $context ) then
--                 $string = preg_replace_callback( "/&amp;([A-Za-z]then2,8end;[0-9]then0,2end;);/", "wp_kses_xml_named_entities", $string );
--         end; else then
--                 $string = preg_replace_callback( "/&amp;([A-Za-z]then2,8end;[0-9]then0,2end;);/", "wp_kses_named_entities", $string );
--         end;
--         $string = preg_replace_callback( "/&amp;#(0*[0-9]then1,7end;);/", "wp_kses_normalize_entities2", $string );
--         $string = preg_replace_callback( "/&amp;#[Xx](0*[0-9A-Fa-f]then1,6end;);/", "wp_kses_normalize_entities3", $string );

--         return $string;
-- end;

-- --
-- -- Callback for `wp_kses_normalize_entities()` regular expression.
-- --
-- -- This function only accepts valid named entity references, which are finite,
-- -- case-sensitive, and highly scrutinized by HTML and XML validators.
-- --
-- -- @since 3.0.0
-- --
-- -- @global array $allowedentitynames
-- --
-- -- @param array $matches preg_replace_callback() matches array.
-- -- @return string Correctly encoded entity.
-- --
-- function wp_kses_named_entities( $matches ) then
--         global $allowedentitynames;

--         if ( empty( $matches[1] ) ) then
--                 return "";
--         end;

--         $i = $matches[1];
--         return ( ! in_array( $i, $allowedentitynames, true ) ) ? "&amp;$i;" : "&$i;";
-- end;

-- --
-- -- Callback for `wp_kses_normalize_entities()` regular expression.
-- --
-- -- This function only accepts valid named entity references, which are finite,
-- -- case-sensitive, and highly scrutinized by XML validators.  HTML named entity
-- -- references are converted to their code points.
-- --
-- -- @since 5.5.0
-- --
-- -- @global array $allowedentitynames
-- -- @global array $allowedxmlentitynames
-- --
-- -- @param array $matches preg_replace_callback() matches array.
-- -- @return string Correctly encoded entity.
-- --
-- function wp_kses_xml_named_entities( $matches ) then
--         global $allowedentitynames, $allowedxmlentitynames;

--         if ( empty( $matches[1] ) ) then
--                 return "";
--         end;

--         $i = $matches[1];

--         if ( in_array( $i, $allowedxmlentitynames, true ) ) then
--                 return "&$i;";
--         end; elseif ( in_array( $i, $allowedentitynames, true ) ) then
--                 return html_entity_decode( "&$i;", ENT_HTML5 );
--         end;

--         return "&amp;$i;";
-- end;

-- --
-- -- Callback for `wp_kses_normalize_entities()` regular expression.
-- --
-- -- This function helps `wp_kses_normalize_entities()` to only accept 16-bit
-- -- values and nothing more for `&#number;` entities.
-- --
-- -- @access private
-- -- @ignore
-- -- @since 1.0.0
-- --
-- -- @param array $matches `preg_replace_callback()` matches array.
-- -- @return string Correctly encoded entity.
-- --
-- function wp_kses_normalize_entities2( $matches ) then
--         if ( empty( $matches[1] ) ) then
--                 return "";
--         end;

--         $i = $matches[1];
--         if ( valid_unicode( $i ) ) then
--                 $i = str_pad( ltrim( $i, "0" ), 3, "0", STR_PAD_LEFT );
--                 $i = "&#$i;";
--         end; else then
--                 $i = "&amp;#$i;";
--         end;

--         return $i;
-- end;

-- --
-- -- Callback for `wp_kses_normalize_entities()` for regular expression.
-- --
-- -- This function helps `wp_kses_normalize_entities()` to only accept valid Unicode
-- -- numeric entities in hex form.
-- --
-- -- @since 2.7.0
-- -- @access private
-- -- @ignore
-- --
-- -- @param array $matches `preg_replace_callback()` matches array.
-- -- @return string Correctly encoded entity.
-- --
-- function wp_kses_normalize_entities3( $matches ) then
--         if ( empty( $matches[1] ) ) then
--                 return "";
--         end;

--         $hexchars = $matches[1];
--         return ( ! valid_unicode( hexdec( $hexchars ) ) ) ? "&amp;#x$hexchars;" : "&#x" . ltrim( $hexchars, "0" ) . ";";
-- end;

-- --
-- -- Determines if a Unicode codepoint is valid.
-- --
-- -- @since 2.7.0
-- --
-- -- @param int $i Unicode codepoint.
-- -- @return bool Whether or not the codepoint is a valid Unicode codepoint.
-- --
-- function valid_unicode( $i ) then
--         return ( 0x9 == $i || 0xa == $i || 0xd == $i ||
--                         ( 0x20 <= $i && $i <= 0xd7ff ) ||
--                         ( 0xe000 <= $i && $i <= 0xfffd ) ||
--                         ( 0x10000 <= $i && $i <= 0x10ffff ) );
-- end;

   -----------------------------
   -- Wp_KSES_Decode_Entities --
   -----------------------------

   function Wp_KSES_Decode_Entities (Item : String)
                                     return String
   is
      use Php;
      use Php.Preg;

      String_3 : constant String :=
        Preg_Replace_Callback ("/&#([0-9]+);/",
                               X_Wp_KSES_Decode_Entities_Chr'Access,
                               Item);

      String_2 : constant String :=
        Preg_Replace_Callback ("/&#[Xx]([0-9A-Fa-f]+);/",
                               X_Wp_KSES_Decode_Entities_Chr_Hexdec'Access,
                               String_3);
   begin
      return String_2;
   end Wp_KSES_Decode_Entities;

   ---------------------------------------
   -- X_Wp_KSES_Decode_Entities_Chr_Chr --
   ---------------------------------------

   function X_Wp_KSES_Decode_Entities_Chr (Match : List_Type)
                                           return String
   is
      use Hb_Common;
   begin
      return Integer'Image (Integer'Value (-Match (2))); -- (1)
   end X_Wp_KSES_Decode_Entities_Chr;

   ------------------------------------------
   -- X_Wp_KSES_Decode_Entities_Chr_Hexdec --
   ------------------------------------------

   function X_Wp_KSES_Decode_Entities_Chr_Hexdec (Match : List_Type)
                                                  return String
   is
      use Hb_Common;
      use Php;
      use Php.Numerics;
   begin
      return Integer'Image (Hexdec (-Match (2))); -- (1)
   end X_Wp_KSES_Decode_Entities_Chr_Hexdec;

-- --
-- -- Sanitize content with allowed HTML KSES rules.
-- --
-- -- This function expects slashed data.
-- --
-- -- @since 1.0.0
-- --
-- -- @param string $data Content to filter, expected to be escaped with slashes.
-- -- @return string Filtered content.
-- --
-- function wp_filter_kses( $data ) then
--         return addslashes( wp_kses( stripslashes( $data ), current_filter() ) );
-- end;

-- --
-- -- Sanitize content with allowed HTML KSES rules.
-- --
-- -- This function expects unslashed data.
-- --
-- -- @since 2.9.0
-- --
-- -- @param string $data Content to filter, expected to not be escaped.
-- -- @return string Filtered content.
-- --
-- function wp_kses_data( $data ) then
--         return wp_kses( $data, current_filter() );
-- end;

-- --
-- -- Sanitizes content for allowed HTML tags for post content.
-- --
-- -- Post content refers to the page contents of the "post" type and not `$_POST`
-- -- data from forms.
-- --
-- -- This function expects slashed data.
-- --
-- -- @since 2.0.0
-- --
-- -- @param string $data Post content to filter, expected to be escaped with slashes.
-- -- @return string Filtered post content with allowed HTML tags and attributes intact.
-- --
-- function wp_filter_post_kses( $data ) then
--         return addslashes( wp_kses( stripslashes( $data ), "post" ) );
-- end;

-- --
-- -- Sanitizes global styles user content removing unsafe rules.
-- --
-- -- @since 5.9.0
-- --
-- -- @param string $data Post content to filter.
-- -- @return string Filtered post content with unsafe rules removed.
-- --
-- function wp_filter_global_styles_post( $data ) then
--         $decoded_data        = json_decode( wp_unslash( $data ), true );
--         $json_decoding_error = json_last_error();
--         if (
--                 JSON_ERROR_NONE === $json_decoding_error &&
--                 is_array( $decoded_data ) &&
--                 isset( $decoded_data["isGlobalStylesUserThemeJSON"] ) &&
--                 $decoded_data["isGlobalStylesUserThemeJSON"]
--         ) then
--                 unset( $decoded_data["isGlobalStylesUserThemeJSON"] );

--                 $data_to_encode = WP_Theme_JSON::remove_insecure_properties( $decoded_data );

--                 $data_to_encode["isGlobalStylesUserThemeJSON"] = true;
--                 return wp_slash( wp_json_encode( $data_to_encode ) );
--         end;
--         return $data;
-- end;

-- --
-- -- Sanitizes content for allowed HTML tags for post content.
-- --
-- -- Post content refers to the page contents of the "post" type and not `$_POST`
-- -- data from forms.
-- --
-- -- This function expects unslashed data.
-- --
-- -- @since 2.9.0
-- --
-- -- @param string $data Post content to filter.
-- -- @return string Filtered post content with allowed HTML tags and attributes intact.
-- --
-- function wp_kses_post( $data ) then
--         return wp_kses( $data, "post" );
-- end;

-- --
-- -- Navigates through an array, object, or scalar, and sanitizes content for
-- -- allowed HTML tags for post content.
-- --
-- -- @since 4.4.2
-- --
-- -- @see map_deep()
-- --
-- -- @param mixed $data The array, object, or scalar value to inspect.
-- -- @return mixed The filtered content.
-- --
-- function wp_kses_post_deep( $data ) then
--         return map_deep( $data, "wp_kses_post" );
-- end;

-- --
-- -- Strips all HTML from a text string.
-- --
-- -- This function expects slashed data.
-- --
-- -- @since 2.1.0
-- --
-- -- @param string $data Content to strip all HTML from.
-- -- @return string Filtered content without any HTML.
-- --
-- function wp_filter_nohtml_kses( $data ) then
--         return addslashes( wp_kses( stripslashes( $data ), "strip" ) );
-- end;

-- --
-- -- Adds all KSES input form content filters.
-- --
-- -- All hooks have default priority. The `wp_filter_kses()` function is added to
-- -- the "pre_comment_content" and "title_save_pre" hooks.
-- --
-- -- The `wp_filter_post_kses()` function is added to the "content_save_pre",
-- -- "excerpt_save_pre", and "content_filtered_save_pre" hooks.
-- --
-- -- @since 2.0.0
-- --
-- function kses_init_filters() then
--         // Normal filtering.
--         add_filter( "title_save_pre", "wp_filter_kses" );

--         // Comment filtering.
--         if ( current_user_can( "unfiltered_html" ) ) then
--                 add_filter( "pre_comment_content", "wp_filter_post_kses" );
--         end; else then
--                 add_filter( "pre_comment_content", "wp_filter_kses" );
--         end;

--         // Global Styles filtering: Global Styles filters should be executed before normal post_kses HTML filters.
--         add_filter( "content_save_pre", "wp_filter_global_styles_post", 9 );
--         add_filter( "content_filtered_save_pre", "wp_filter_global_styles_post", 9 );

--         // Post filtering.
--         add_filter( "content_save_pre", "wp_filter_post_kses" );
--         add_filter( "excerpt_save_pre", "wp_filter_post_kses" );
--         add_filter( "content_filtered_save_pre", "wp_filter_post_kses" );
-- end;

-- --
-- -- Removes all KSES input form content filters.
-- --
-- -- A quick procedural method to removing all of the filters that KSES uses for
-- -- content in WordPress Loop.
-- --
-- -- Does not remove the `kses_init()` function from then@see "init"end; hook (priority is
-- -- default). Also does not remove `kses_init()` function from then@see "set_current_user"end;
-- -- hook (priority is also default).
-- --
-- -- @since 2.0.6
-- --
-- function kses_remove_filters() then
--         // Normal filtering.
--         remove_filter( "title_save_pre", "wp_filter_kses" );

--         // Comment filtering.
--         remove_filter( "pre_comment_content", "wp_filter_post_kses" );
--         remove_filter( "pre_comment_content", "wp_filter_kses" );

--         // Global Styles filtering.
--         remove_filter( "content_save_pre", "wp_filter_global_styles_post", 9 );
--         remove_filter( "content_filtered_save_pre", "wp_filter_global_styles_post", 9 );

--         // Post filtering.
--         remove_filter( "content_save_pre", "wp_filter_post_kses" );
--         remove_filter( "excerpt_save_pre", "wp_filter_post_kses" );
--         remove_filter( "content_filtered_save_pre", "wp_filter_post_kses" );
-- end;

-- --
-- -- Sets up most of the KSES filters for input form content.
-- --
-- -- First removes all of the KSES filters in case the current user does not need
-- -- to have KSES filter the content. If the user does not have `unfiltered_html`
-- -- capability, then KSES filters are added.
-- --
-- -- @since 2.0.0
-- --
-- function kses_init() then
--         kses_remove_filters();

--         if ( ! current_user_can( "unfiltered_html" ) ) then
--                 kses_init_filters();
--         end;
-- end;

   -------------------------
   -- SaveCSS_Filter_Attr --
   -------------------------

   function SafeCSS_Filter_Attr (CSS        : String;
                                 Deprecated : String := "")
                                 return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use Inc_Functions;
      use Inc_Plugins;

      -- if ( ! empty( $deprecated ) ) then
      --         _deprecated_argument( __FUNCTION__, "2.8.1" ); // Never implemented.
      -- end;

      CSS_2 : constant String := Wp_KSES_No_Null (CSS);
      CSS_3 : constant String :=
        Str_Replace (To_List (List => (+"\n", +"\r", +"\t")), "", CSS_2);

      Allowed_Protocols : constant List_Type := Wp_Allowed_Protocols;

      CSS_Array : constant List_Type := Explode (";", Trim (CSS_3));

      --
      -- Filters the list of allowed CSS attributes.
      --
      -- @since 2.8.1
      --
      -- @param string[] $attr Array of allowed CSS attributes.
      --
      Allowed_Attr : List_Type := Apply_Filters (
        "safe_style_css",
        To_List (List => (
                        +"background",
                        +"background-color",
                        +"background-image",
                        +"background-position",
                        +"background-size",
                        +"background-attachment",
                        +"background-blend-mode",

                        +"border",
                        +"border-radius",
                        +"border-width",
                        +"border-color",
                        +"border-style",
                        +"border-right",
                        +"border-right-color",
                        +"border-right-style",
                        +"border-right-width",
                        +"border-bottom",
                        +"border-bottom-color",
                        +"border-bottom-left-radius",
                        +"border-bottom-right-radius",
                        +"border-bottom-style",
                        +"border-bottom-width",
                        +"border-bottom-right-radius",
                        +"border-bottom-left-radius",
                        +"border-left",
                        +"border-left-color",
                        +"border-left-style",
                        +"border-left-width",
                        +"border-top",
                        +"border-top-color",
                        +"border-top-left-radius",
                        +"border-top-right-radius",
                        +"border-top-style",
                        +"border-top-width",
                        +"border-top-left-radius",
                        +"border-top-right-radius",

                        +"border-spacing",
                        +"border-collapse",
                        +"caption-side",

                        +"columns",
                        +"column-count",
                        +"column-fill",
                        +"column-gap",
                        +"column-rule",
                        +"column-span",
                        +"column-width",

                        +"color",
                        +"filter",
                        +"font",
                        +"font-family",
                        +"font-size",
                        +"font-style",
                        +"font-variant",
                        +"font-weight",
                        +"letter-spacing",
                        +"line-height",
                        +"text-align",
                        +"text-decoration",
                        +"text-indent",
                        +"text-transform",

                        +"height",
                        +"min-height",
                        +"max-height",

                        +"width",
                        +"min-width",
                        +"max-width",

                        +"margin",
                        +"margin-right",
                        +"margin-bottom",
                        +"margin-left",
                        +"margin-top",
                        +"margin-block-start",
                        +"margin-block-end",
                        +"margin-inline-start",
                        +"margin-inline-end",

                        +"padding",
                        +"padding-right",
                        +"padding-bottom",
                        +"padding-left",
                        +"padding-top",
                        +"padding-block-start",
                        +"padding-block-end",
                        +"padding-inline-start",
                        +"padding-inline-end",

                        +"flex",
                        +"flex-basis",
                        +"flex-direction",
                        +"flex-flow",
                        +"flex-grow",
                        +"flex-shrink",
                        +"flex-wrap",

                        +"gap",
                        +"column-gap",
                        +"row-gap",

                        +"grid-template-columns",
                        +"grid-auto-columns",
                        +"grid-column-start",
                        +"grid-column-end",
                        +"grid-column-gap",
                        +"grid-template-rows",
                        +"grid-auto-rows",
                        +"grid-row-start",
                        +"grid-row-end",
                        +"grid-row-gap",
                        +"grid-gap",

                        +"justify-content",
                        +"justify-items",
                        +"justify-self",
                        +"align-content",
                        +"align-items",
                        +"align-self",

                        +"clear",
                        +"cursor",
                        +"direction",
                        +"float",
                        +"list-style-type",
                        +"object-fit",
                        +"object-position",
                        +"overflow",
                        +"vertical-align",

                        -- Custom CSS properties.
                        +"--*"
        ))
      );

      --
      -- CSS attributes that accept URL data types.
      --
      -- This is in accordance to the CSS spec and unrelated to
      -- the sub-set of supported attributes above.
      --
      -- See: https://developer.mozilla.org/en-US/docs/Web/CSS/url
      --
      CSS_URL_Data_Types : constant List_Type := To_List (List => (
                +"background",
                +"background-image",

                +"cursor",

                +"list-style",
                +"list-style-image"
      ));

      --
      -- CSS attributes that accept gradient data types.
      --
      --
      CSS_Gradient_Data_Types : constant List_Type := To_List (List => (
                +"background",
                +"background-image"
      ));

      CSS_4 : Unbounded_String;
   begin
      if Allowed_Attr.Is_Empty then
         return CSS_3;
      end if;

      for CSS_Item_2 of CSS_Array loop
         if "" = CSS_Item_2 then
            goto Continue;
         end if;

         declare
            CSS_Item        : constant String  := Trim (-CSS_Item_2);
            CSS_Test_String : Unbounded_String := +CSS_Item;
            Found           : Boolean := False;
            URL_Attr        : Boolean := False;
            Gradient_Attr   : Boolean := False;
            Is_Custom_Var   : Boolean := False;
            Parts : List_Type;
         begin
            if Strpos (CSS_Item, ":") = 0 then
               Found := True;
            else
               Parts := Explode (":", CSS_Item, 2);

               declare
                  CSS_Selector : constant String    := Trim (-Parts (1)); -- (0)
               begin
                  -- Allow assigning values to CSS variables.
                  if
                    In_Array ("--*", Allowed_Attr, True) and then
                    Preg_Match ("/^--[a-zA-Z0-9-_]+$/", CSS_Selector)
                  then
                     Allowed_Attr.Append (+CSS_Selector);
                     Is_Custom_Var  := True;
                  end if;

                  if In_Array (CSS_Selector, Allowed_Attr, True) then
                     Found         := True;
                     URL_Attr      := In_Array (CSS_Selector,
                                                CSS_URL_Data_Types, True);
                     Gradient_Attr := In_Array (CSS_Selector,
                                                CSS_Gradient_Data_Types, True);
                  end if;

                  if Is_Custom_Var then
                     declare
                        CSS_Value : constant String := Trim (-Parts (2)); -- (1)
                     begin
                        URL_Attr      := Str_Starts_With (CSS_Value, "url(");
                        Gradient_Attr := Str_Contains (CSS_Value, "-gradient(");
                     end;
                  end if;
               end;
            end if;

            if Found and URL_Attr then
               -- Simplified: matches the sequence `url(*)`.
               declare
                  URL_Matches : Array_Type;
                  Unused      : Integer;
               begin
                  Unused :=
                    Preg_Match_All ("/url\([^)]+\)/", -Parts (2), URL_Matches); -- (1)

                  Match_Loop :
                  for A in URL_Matches.Iterate loop -- (1) loop -- (0)
                     declare
                        URL_Match  : constant String := Key (A);
                        URL_Pieces : List_Type;
                     begin
                        -- Clean up the URL from each of the matches above.
                        Unused := Preg_Match ("/^url\(\s*([\""\""]?)(.*)(\g1)\s*\)$/",
                                              URL_Match, URL_Pieces);

                        if Empty (-URL_Pieces (3)) then -- (2)
                           Found := False;
                           exit Match_Loop;
                        end if;

                        declare
                           URL : constant String := Trim (-URL_Pieces (3)); -- (2)
                        begin
                           if
                             Empty (URL) or else
                             Wp_KSES_Bad_Protocol (URL, Allowed_Protocols) /= URL
                           then
                              Found := False;
                              exit Match_Loop;
                           else
                              -- Remove the whole `url(*)` bit that was matched above
                              -- from the CSS.
                              CSS_Test_String := +Str_Replace (URL_Match, "",
                                                               -CSS_Test_String);
                           end if;
                        end;
                     end;
                  end loop Match_Loop;
               end;
            end if;

            if Found and then Gradient_Attr then
               declare
                  CSS_Value : constant String := Trim (-Parts (2));  -- (1)
               begin
                  if
                    Preg_Match
                      ("/^(repeating-)?(linear|radial|conic)-gradient\(([^()]|rgb[a]?\([^()]*\))*\)$/", CSS_Value)
                  then
                     -- Remove the whole `gradient` bit that was matched above from
                     -- the CSS.
                     CSS_Test_String := +Str_Replace (CSS_Value, "", -CSS_Test_String);
                  end if;
               end;
            end if;

            if Found then
               --
               -- Allow CSS functions like var(), calc(), etc. by removing them from
               -- the test string. Nested functions and parentheses are also removed,
               -- so long as the parentheses are balanced.
               --
               CSS_Test_String :=
                 +Preg_Replace (
                   "/\b(?:var|calc|min|max|minmax|clamp)(\((?:[^()]|(?1))*\))/",
                   "",
                   -CSS_Test_String
                 );

               declare
                  --
                  -- Disallow CSS containing \ ( & end; = or comments, except for
                  -- within url(), var(), calc(), etc.  which were removed from the
                  -- test string above.
                  --
                  Allow_CSS_2 : constant Boolean :=
                    not Preg_Match ("%[\\\(&=end;]|/\*%", -CSS_Test_String);

                  --
                  -- Filters the check for unsafe CSS in `safecss_filter_attr`.
                  --
                  -- Enables developers to determine whether a section of CSS should be
                  -- allowed or discarded. By default, the value will be false if the
                  -- part contains \ ( & end; = or comments.
                  -- Return true to allow the CSS part to be included in the output.
                  --
                  -- @since 5.5.0
                  --
                  -- @param bool   $allow_css       Whether the CSS in the test
                  --                                 string is considered safe.
                  -- @param string $css_test_string The CSS string to test.
                  --
                  Allow_CSS : constant Boolean :=
                    Apply_Filters ("safecss_filter_attr_allow_css",
                                   Allow_CSS_2, -CSS_Test_String);
               begin
                  -- Only add the CSS part if it passes the regex check.
                  if Allow_CSS then
                     if "" /= CSS_4 then
                        Append (CSS_4, ";");
                     end if;

                     Append (CSS_4, CSS_Item);
                  end if;
               end;
            end if;
         end;
         << Continue >>
      end loop;

      return -CSS_4;
   end SafeCSS_Filter_Attr;

-- --
-- -- Helper function to add global attributes to a tag in the allowed HTML list.
-- --
-- -- @since 3.5.0
-- -- @since 5.0.0 Added support for `data-*` wildcard attributes.
-- -- @since 6.0.0 Added `dir`, `lang`, and `xml:lang` to global attributes.
-- --
-- -- @access private
-- -- @ignore
-- --
-- -- @param array $value An array of attributes.
-- -- @return array The array of attributes with global attributes added.
-- --
-- function _wp_add_global_attributes( $value ) then
--         $global_attributes = array(
--                 "aria-describedby" => true,
--                 "aria-details"     => true,
--                 "aria-label"       => true,
--                 "aria-labelledby"  => true,
--                 "aria-hidden"      => true,
--                 "class"            => true,
--                 "data-*"           => true,
--                 "dir"              => true,
--                 "id"               => true,
--                 "lang"             => true,
--                 "style"            => true,
--                 "title"            => true,
--                 "role"             => true,
--                 "xml:lang"         => true,
--         );

--         if ( true === $value ) then
--                 $value = array();
--         end;

--         if ( is_array( $value ) ) then
--                 return array_merge( $value, $global_attributes );
--         end;

--         return $value;
-- end;

-- --
-- -- Helper function to check if this is a safe PDF URL.
-- --
-- -- @since 5.9.0
-- -- @access private
-- -- @ignore
-- --
-- -- @param string $url The URL to check.
-- -- @return bool True if the URL is safe, false otherwise.
-- --
-- function _wp_kses_allow_pdf_objects( $url ) then
--         // We're not interested in URLs that contain query strings or fragments.
--         if ( str_contains( $url, "?" ) || str_contains( $url, "#" ) ) then
--                 return false;
--         end;

--         // If it doesn"t have a PDF extension, it"s not safe.
--         if ( ! str_ends_with( $url, ".pdf" ) ) then
--                 return false;
--         end;

--         // If the URL host matches the current site"s media URL, it"s safe.
--         $upload_info = wp_upload_dir( null, false );
--         $parsed_url  = wp_parse_url( $upload_info["url"] );
--         $upload_host = isset( $parsed_url["host"] ) ? $parsed_url["host"] : "";
--         $upload_port = isset( $parsed_url["port"] ) ? ":" . $parsed_url["port"] : "";

--         if ( str_starts_with( $url, "http://$upload_host$upload_port/" )
--                 || str_starts_with( $url, "https://$upload_host$upload_port/" )
--         ) then
--                 return true;
--         end;

--         return false;
-- end;

end Inc_KSES;
