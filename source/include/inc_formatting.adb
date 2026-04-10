--
-- Main WordPress Formatting API.
--
-- Handles many functions for formatting output.
--
-- @package WordPress
--

with Ada.Text_IO;

with Php.Arrays;
with Php.Echoing;
with Php.Files;
with Php.Lists;
with Php.Misc;
with Php.Multibyte;
with Php.Numerics;
with Php.Preg;
with Php.Types;
with Php.Strings;

with Array_Lists;
with Constants;
with Globals;
with UStrings;
with Wp_Common;

with Inc_Functions;
with Inc_General_Templates;
with Inc_HTTP;
with Inc_KSES;
with Inc_Link_Templates;
with Inc_L10n;
with Inc_Options;
with Inc_Script_Loader;
with Inc_Themes;

package body Inc_Formatting
is

   Global_Wp_Cockneyreplace : Array_Type;
   Global_Shortcode_Tags    : Array_Type;

   ------------------
   -- Wp_Texturize --
   ------------------

   function Wp_Texturize (Text  : String;
                          Reset : Boolean := False)
                          return String
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use Array_Lists;
      use Wp_Common;
      use Inc_L10n;

      -- static
      Static_Characters    : List_Type;
      Static_Replacements  : List_Type;
      Dynamic_Characters   : Array_Type;
      Dynamic_Replacements : Array_Type;
        --         default_no_texturize_tags       = null,
        --         default_no_texturize_shortcodes = null,
      Run_Texturize : Boolean := True;
        --         apos                            = null,
        --         prime                           = null,
        --         double_prime                    = null,
        --         opening_quote                   = null,
        --         closing_quote                   = null,
        --         opening_single_quote            = null,
        --         closing_single_quote            = null,

      -- translators: Opening curly double quote.
      Opening_Quote : constant String :=
        X_X ("&#8220;", "opening curly double quote");

      -- translators: Closing curly double quote.
      Closing_Quote : constant String :=
        X_X ("&#8221;", "closing curly double quote");

      -- translators: Apostrophe, for example in "cause or can't.
      Apos : constant String :=
        X_X ("&#8217;", "apostrophe");

      -- translators: Prime, for example in 9" (nine feet).
      Prime : constant String :=
        X_X ("&#8242;", "prime");

      -- translators: Double prime, for example in 9" (nine inches).
      Double_Prime : constant String :=
        X_X ("&#8243;", "double prime");

      -- translators: Opening curly single quote.
      Opening_Single_Quote : constant String :=
        X_X ("&#8216;", "opening curly single quote");

      -- translators: Closing curly single quote.
      Closing_Single_Quote : constant String :=
        X_X ("&#8217;", "closing curly single quote");

      -- translators: En dash.
      En_Dash : constant String :=
        X_X ("&#8211;", "en dash");

      -- translators: Em dash.
      Em_Dash : constant String :=
        X_X ("&#8212;", "em dash");

      Default_No_Texturize_Tags : constant List_Type :=
        ["pre", "code", "kbd", "style", "script", "tt"];

      Default_No_Texturize_Shortcodes : constant List_Type :=
        ["code"];

      Open_Q_Flag  : constant String := "<!--oq-->";
      Open_Sq_Flag : constant String := "<!--osq-->";
      Apos_Flag    : constant String := "<!--apos-->";

      Cockney        : List_Type;
      Cockneyreplace : List_Type;

      Dynamic : Array_Type;
      Spaces  : constant String := Wp_Spaces_Regexp;

   begin
      -- If there's nothing to do, just stop.
      if Empty (Text) or else False = Run_Texturize then
         return Text;
      end if;

      -- Set up static variables. Run once only.
      if Reset or else Static_Characters.Is_Empty then -- not isset
         --
         -- Filters whether to skip running wptexturize().
         --
         -- Returning false from the filter will effectively short-circuit
         -- wptexturize() and return the original text passed to the function instead.
         --
         -- The filter runs only once, the first time wptexturize() is called.
         --
         -- @since 4.0.0
         --
         -- @see wptexturize()
         --
         -- @param bool run_texturize Whether to short-circuit wptexturize().
         --
         Run_Texturize := Apply_Filters ("run_wptexturize", Run_Texturize);
         if False = Run_Texturize then
            return Text;
         end if;

         -- If a plugin has provided an autocorrect array, use it.
         if Isset (Global_Wp_Cockneyreplace) then
            Cockney        := Array_Keys   (Global_Wp_Cockneyreplace);
            Cockneyreplace := Array_Values (Global_Wp_Cockneyreplace);
         else
            --
            -- translators: This is a comma-separated list of words that defy the
            -- syntax of quotations in normal use for example... "We do not have
            -- enough words yet"... is a typical quoted phrase. But when we write
            -- lines of code "til we have enough of "em, then we need to insert
            -- apostrophes instead of quotes.
            --
            Cockney :=
              Explode (
                ",",
                X_X (
                  "'tain't,'twere,'twas,'tis,'twill,'til,'bout,'nuff,'round,'cause,'em",
                  "Comma-separated list of words to texturize in your language"
                )
              );

            Cockneyreplace :=
              Explode (
                ",",
                X_X (
                  "&#8217;tain&#8217;t,&#8217;twere,&#8217;twas,&#8217;tis,&#8217;twill,&#8217;til,&#8217;bout,&#8217;nuff,&#8217;round,&#8217;cause,&#8217;em",
                  "Comma-separated list of replacement words in your language"
                )
              );
         end if;

         Static_Characters :=
           List_Merge (List_Type'["...", "``", "\\", " (tm)"],
                       Cockney);

         Static_Replacements :=
           List_Merge (
             List_Type'["&#8230;", Opening_Quote, Closing_Quote, " &#8482;"],
             Cockneyreplace);

         -- Pattern-based replacements of characters.
         -- Sort the remaining patterns into several arrays for performance tuning.
         Dynamic_Characters := To_Array_Type ([
           Build ("apos",  Empty_Array),
           Build ("quote", Empty_Array),
           Build ("dash",  Empty_Array)
         ]);

         Dynamic_Replacements := To_Array_Type ([
           Build ("apos",  Empty_Array),
           Build ("quote", Empty_Array),
           Build ("dash",  Empty_Array)
         ]);

         Dynamic := Empty_Array;
--       Spaces  := Wp_Spaces_Regexp;

         -- "99" and "99" are ambiguous among other patterns; assume it's an
         -- abbreviated year at the end of a quotation.
         if "'" /= Apos or "'" /= Closing_Single_Quote then
            declare
               Key : constant String := "/\'(\d\d)\'(?=\Z|[.,:;!?)end;\-\]]|&gt;|" & Spaces & ")/";
            begin
               Set (Dynamic, Key,
                    From_String (Apos_Flag & "$1" & Closing_Single_Quote));
            end;
         end if;

         if "'" /= Apos or "'" /= Closing_Quote then
            declare
               Key : constant String := "/\'(\d\d)'(?=\Z|[.,:;!?)end;\-\]]|&gt;|" & Spaces & ")/";
            begin
               Set (Dynamic, Key,
                    From_String (Apos_Flag & "$1" & Closing_Quote));
            end;
         end if;

         -- "99 "99s "99"s (apostrophe)  But never "9 or "99% or "999 or "99.0.
         if "'" /= Apos then
            declare
               Key : constant String := "/\'(?=\d\d(?:\Z|(?![%\d]|[.,]\d)))/";
            begin
               Set (Dynamic, Key, From_String (Apos_Flag));
            end;
         end if;

         -- Quoted numbers like "0.42".
         if "'" /= Opening_Single_Quote and "'" /= Closing_Single_Quote then
            declare
               Key : constant String := "/(?<=\A|" & Spaces & ")\'(\d[.,\d]*)\'/";
            begin
               Set (Dynamic, Key,
                    From_String (Open_Sq_Flag & "$1" & Closing_Single_Quote));
            end;
         end if;

         -- Single quote at start, or preceded by (, then, <, [, ", -, or spaces.
         if "'" /= Opening_Single_Quote then
            declare
               Key : constant String := "/(?<=\A|[([{""\-]|&lt;|" & Spaces & ")\'/";
            begin
               Set (Dynamic, Key, From_String (Open_Sq_Flag));
            end;
         end if;

         -- Apostrophe in a word. No spaces, double apostrophes, or other punctuation.
         if "'" /= Apos then
            declare
               Key : constant String :=
                 "/(?<!" & Spaces & ")\'(?!\Z|[.,:;!?""\'(){}[\]\-]|&[lg]t;|" &
                 Spaces & ")/";
            begin
               Set (Dynamic, Key, From_String (Apos_Flag));
            end;
         end if;

         Set (Dynamic_Characters,   "apos", From_List (Array_Keys   (Dynamic)));
         Set (Dynamic_Replacements, "apos", From_List (Array_Values (Dynamic)));
         Dynamic := Empty_Array;

         -- Quoted numbers like "42".
         if "'" /= Opening_Quote and "'" /= Closing_Quote then
            declare
               Key : constant String := "/(?<=\A|" & Spaces & ")'(\d[.,\d]*)'/";
            begin
               Set (Dynamic, Key,
                    From_String (Open_Q_Flag & "$1" & Closing_Quote));
            end;
         end if;

         -- Double quote at start, or preceded by (, then, <, [, -, or spaces, and
         -- not followed by spaces.
         if "'" /= Opening_Quote then
            declare
               Key : constant String :=
                 "/(?<=\A|[([then\-]|&lt;|" & Spaces & ")'(?!" & Spaces & ")/";
            begin
               Set (Dynamic, Key, From_String (Open_Q_Flag));
            end;
         end if;

         Set (Dynamic_Characters,   "quote", From_List (Array_Keys   (Dynamic)));
         Set (Dynamic_Replacements, "quote", From_List (Array_Values (Dynamic)));
         Dynamic := Empty_Array;

         -- Dashes and spaces.
         Set (Dynamic, "/---/", From_String (Em_Dash));
         Set (Dynamic, "/(?<=^|" & Spaces & ")--(?=|" & Spaces & ")/",
              From_String (Em_Dash));

         Set (Dynamic, "/(?<!xn)--/", From_String (En_Dash));
         Set (Dynamic, "/(?<=^|" & Spaces & ")-(?=|" & Spaces & ")/",
              From_String (En_Dash));

         Set (Dynamic_Characters,   "dash", From_List (Array_Keys   (Dynamic)));
         Set (Dynamic_Replacements, "dash", From_List (Array_Values (Dynamic)));
      end if;

      -- Must do this every time in case plugins use these filters in a context
      -- sensitive manner.

      declare
         --
         -- Filters the list of HTML elements not to texturize.
         --
         -- @since 2.8.0
         --
         -- @param string[] default_no_texturize_tags An array of HTML element names.
         --
         No_Texturize_Tags : constant List_Type :=
           Apply_Filters ("no_texturize_tags", Default_No_Texturize_Tags);

         --
         -- Filters the list of shortcodes not to texturize.
         --
         -- @since 2.8.0
         --
         -- @param string[] default_no_texturize_shortcodes An array of shortcode
         -- names.
         --
         No_Texturize_Shortcodes : constant List_Type :=
           Apply_Filters ("no_texturize_shortcodes", Default_No_Texturize_Shortcodes);

         No_Texturize_Tags_Stack       : List_Type;
         No_Texturize_Shortcodes_Stack : List_Type;

         Matches : List_Type;
      begin
         -- Look for shortcodes and HTML elements.
         Preg_Match_All ("@\[/?([^<>&/\[\]\x00-\x20=]++)@", Text, Matches);

         declare
            Tagnames : constant List_Type :=
              List_Intersect (Array_Keys (Global_Shortcode_Tags),
                              [Matches (2)]);

            Found_Shortcodes : constant Boolean := not Tagnames.Is_Empty;
            Shortcode_Regex  : constant String :=
              (if Found_Shortcodes
               then X_Get_Wptexturize_Shortcode_Regex (Tagnames) else "");

            Regex : constant String :=
              X_Get_Wptexturize_Split_Regex (Shortcode_Regex);

            Textarr : List_Type := -- constant List_Type :=
              Preg_Split (Regex, Text, No_Limit,
                          (PREG_SPLIT_DELIM_CAPTURE | PREG_SPLIT_NO_EMPTY => True));
         begin
            for Curl of Textarr loop -- &
               -- Only call _wptexturize_pushpop_element if curl is a delimiter.
               declare
--                  Curl  : String := Curl_0;
                  First : constant Character := Curl (1);
               begin

                  if '<' = First then
                     if "<!--" = Substr (Curl, 0, 4) then
                        -- This is an HTML comment delimiter.
                        goto Continue;
                     else
                        -- This is an HTML element delimiter.

                        -- Replace each & with &#038; unless it already looks like
                        -- an entity.
                        Curl :=
                          Preg_Replace ("/&(?!#(?:\d+|x[a-f0-9]+);|[a-z1-4]{1,8};)/i",
                                        "&#038;", Curl);

                        X_Wptexturize_Pushpop_Element (Curl,
                                                       No_Texturize_Tags_Stack,
                                                       No_Texturize_Tags);
                     end if;

                  elsif "" = Trim (Curl) then
                     -- This is a newline between delimiters. Performance improves
                     -- when we check this.
                     goto Continue;

                  elsif
                    '[' = First and Found_Shortcodes and
                    1 = Preg_Match ("/^" & Shortcode_Regex & "/", Curl)
                  then
                     -- This is a shortcode delimiter.

                     if "[[" /= Substr (Curl, 0, 2) and "]]" /= Substr (Curl, -2) then
                        -- Looks like a normal shortcode.
                        X_Wptexturize_Pushpop_Element (Curl,
                                                       No_Texturize_Shortcodes_Stack,
                                                       No_Texturize_Shortcodes);
                     else
                        -- Looks like an escaped shortcode.
                        goto Continue;
                     end if;

                  elsif
                    No_Texturize_Shortcodes_Stack.Is_Empty and
                    No_Texturize_Tags_Stack.Is_Empty
                  then
                     -- This is neither a delimiter, nor is this content inside of
                     -- no_texturize pairs. Do texturize.
                     Curl := Str_Replace (Static_Characters,
                                          Static_Replacements, Curl);

                     if 0 /= Strpos (Curl, "'") then  -- false
                        Curl :=
                          Preg_Replace (Get_As_String (Dynamic_Characters, "apos"),
                                        Get_As_String (Dynamic_Replacements, "apos"),
                                        Curl);
                        Curl := Wptexturize_Primes (Curl, "'", Prime, Open_Sq_Flag,
                                                    Closing_Single_Quote);
                        Curl := Str_Replace (Apos_Flag, Apos, Curl);
                        Curl := Str_Replace (Open_Sq_Flag, Opening_Single_Quote, Curl);
                     end if;

                     if 0 /= Strpos (Curl, "'") then  -- false
                        Curl :=
                          Preg_Replace (Get_As_String (Dynamic_Characters, "quote"),
                                        Get_As_String (Dynamic_Replacements, "quote"),
                                        Curl);
                        Curl := Wptexturize_Primes (Curl, "'", Double_Prime,
                                                    Open_Q_Flag, Closing_Quote);
                        Curl := Str_Replace (Open_Q_Flag, Opening_Quote, Curl);
                     end if;

                     if 0 /= Strpos (Curl, "-") then
                        -- false
                        Curl :=
                          Preg_Replace
                            (Pattern     =>
                               As_List (Get (Dynamic_Characters, "dash")),
                             Replacement =>
                               As_List (Get (Dynamic_Replacements, "dash")),
                             Subject     => Curl);
                     end if;

                     -- 9x9 (times), but never 0x9999.
                     if 1 = Preg_Match ("/(?<=\d)x\d/", Curl) then
                        -- Searching for a digit is 10 times more expensive than for
                        -- the x, so we avoid doing this one!
                        Curl := Preg_Replace
                           ("/\b(\d(?(?<=0)[\d\.,]+|[\d\.,]*))x(\d[\d\.,]*)\b/",
                            "1&#215;2", Curl);
                     end if;

                     -- Replace each & with &#038; unless it already looks like
                     -- an entity.
                     Curl :=
                       Preg_Replace ("/&(?!#(?:\d+|x[a-f0-9]+);|[a-z1-4]{1,8};)/i",
                                     "&#038;", Curl);
                  end if;
               end;
               << Continue >>
            end loop;

            return Implode ("", Textarr);
         end;
      end;
   end Wp_Texturize;

   ------------------------
   -- Wptexturize_Primes --
   ------------------------

   function Wptexturize_Primes (Haystack    : String;
                                Needle      : String;
                                Prime       : String;
                                Open_Quote  : String;
                                Close_Quote : String)
                                return String
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;

      Spaces           : constant String := Wp_Spaces_Regexp;
      Flag             : constant String := "<!--wp-prime-or-quote-->";

      Quote_Pattern    : constant String :=
        "/" & Needle & "(?=\\Z|[.,:;!?)}\\-\\]]|&gt;|" & Spaces & ")/";

      Prime_Pattern    : constant String := "/(?<=\\d)" & Needle & "/";
      Flag_After_Digit : constant String := "/(?<=\\d)" & Flag & "/";
      Flag_No_Digit    : constant String := "/(?<!\\d)" & Flag & "/";

      Sentences : constant List_Type := Explode (Open_Quote, Haystack);
      Sentence_6 : UString;
   begin
      for A in Sentences.First_Index .. Sentences.Last_Index loop
         declare
            Index    : constant Integer := A;
            Sentence : constant String  := Sentences (A);     -- &
         begin
            if 0 = Strpos (Sentence, Needle) then
               goto Continue;
            elsif 0 /= Index and then 0 = Substr_Count (Sentence, Close_Quote) then
               declare
                  Count      : Natural;
                  Sentence_2 : constant String :=
                    Preg_Replace (Quote_Pattern, Flag, Sentence, No_Limit, Count);
               begin
                  if Count > 1 then
                     -- This sentence appears to have multiple closing quotes.
                     -- Attempt Vulcan logic.
                     declare
                        Count_2    : Natural;
                        Sentence_3 : UString :=
                          +Preg_Replace (Flag_No_Digit, Close_Quote,
                                         Sentence_2, No_Limit, Count_2);
                     begin
                        if 0 = Count_2 then
                           -- Try looking for a quote followed by a period.
                           declare
                              Count_3 : constant Natural :=
                                Substr_Count (-Sentence_3, Flag & ".");
                              Pos     : Natural;
                           begin
                              if Count_3 > 0 then
                                 -- Assume the rightmost quote-period match is the end
                                 -- of quotation.
                                 Pos := Strrpos (-Sentence_3, Flag & ".");
                              else
                                 -- When all else fails, make the rightmost candidate
                                 -- a closing quote. This is most likely to be
                                 -- problematic in the context of bug #18549.
                                 Pos := Strrpos (-Sentence_3, Flag);
                              end if;

                              Sentence_3 :=
                                +Substr_Replace (-Sentence_3, Close_Quote,
                                                 Pos, Strlen (Flag));
                           end;
                        end if;
                        -- Use conventional replacement on any remaining primes and
                        -- quotes.
                        declare
                           Sentence_4 : constant String :=
                             Preg_Replace (Prime_Pattern, Prime, -Sentence_3);

                           Sentence_5 : constant String :=
                             Preg_Replace (Flag_After_Digit, Prime, Sentence_4);
                        begin
                           Sentence_6 := +Str_Replace (Flag, Close_Quote, Sentence_5);
                        end;
                     end;

                  elsif 1 = Count then
                     -- Found only one closing quote candidate, so give it priority
                     -- over primes.
                     declare
                        Sentence_4 : constant String :=
                          Str_Replace (Flag, Close_Quote, Sentence_2);
                     begin
                        Sentence_6 := +Preg_Replace (Prime_Pattern, Prime, Sentence_4);
                     end;
                  else
                     -- No closing quotes found. Just run primes pattern.
                     Sentence_6 := +Preg_Replace (Prime_Pattern, Prime, Sentence_2);
                  end if;
               end;
            else
               declare
                  Sentence_4 : constant String :=
                    Preg_Replace (Prime_Pattern, Prime, Sentence);
               begin
                  Sentence_6 := +Preg_Replace (Quote_Pattern, Close_Quote, Sentence_4);
               end;
            end if;

            if "'" = Needle and 0 /= Strpos (-Sentence_6, "'") then
               Sentence_6 := +Str_Replace ("'", Close_Quote, -Sentence_6);
            end if;
         end;
         << Continue >>
      end loop;

      return Implode (Open_Quote, -Sentence_6);
   end Wptexturize_Primes;

   -----------------------------------
   -- X_Wptexturize_Pushpop_Element --
   -----------------------------------

   procedure X_Wptexturize_Pushpop_Element
               (Text              : String;
                Stack             : in out List_Type;
                Disabled_Elements : List_Type)
   is
      use Php.Lists;
      use Php.Strings;

      Opening_Tag : Boolean;
      Name_Offset : Integer;
   begin
      -- Is it an opening tag or closing tag?
      if Text'Length >= 1 and then '/' /= Text (Text'First) then
--    if Isset (Text (1)) and '/' /= Text (1) then
         Opening_Tag := True;
         Name_Offset := 1;
      elsif Stack.Is_Empty then
         -- Stack is empty. Just stop.
         return;
      else
         Opening_Tag := False;
         Name_Offset := 2;
      end if;

      -- Parse out the tag name.
      declare
         Space : Integer := Strpos (Text, " ");
      begin
         if 0 = Space then -- false
            Space := -1;
         else
            Space := Space - Name_Offset;
         end if;

         declare
            Tag : constant String := Substr (Text, Name_Offset, Space);
         begin
            -- Handle disabled tags.
            if In_List (Tag, Disabled_Elements, True) then
               if Opening_Tag then
                  --
                  -- This disables texturize until we find a closing tag of our type
                  -- (e.g. <pre>) even if there was invalid nesting before that.
                  --
                  -- Example: in the case <pre>sadsadasd</code>"baba"</pre>
                  --          "baba" won't be texturized.
                  --

                  List_Push (Stack, Tag);
               elsif Stack.Last_Element = Tag then
                  List_Pop (Stack);
               end if;
            end if;
         end;
      end;
   end X_Wptexturize_Pushpop_Element;

-- --
-- -- Replaces double line breaks with paragraph elements.
-- --
-- -- A group of regex replaces used to identify text formatted with newlines and
-- -- replace double line breaks with HTML paragraph tags. The remaining line breaks
-- -- after conversion become `<br />` tags, unless `br` is set to "0" or "false".
-- --
-- -- @since 0.71
-- --
-- -- @param string text The text which has to be formatted.
-- -- @param bool   br   Optional. If set, this will convert all remaining line breaks
-- --                     after paragraphing. Line breaks within `<script>`, `<style>`,
-- --                     and `<svg>` tags are not affected. Default true.
-- -- @return string Text which has been converted into correct paragraph tags.
-- --
-- function wpautop( text, br = true ) then
--         pre_tags = array();

--         if ( trim( text ) === "" ) then
--                 return "";
--         end;

--         // Just to make things a little easier, pad the end.
--         text = text . "\n";

--         /*
--         -- Pre tags shouldn"t be touched by autop.
--         -- Replace pre tags with placeholders and bring them back after autop.
--         --
--         if ( strpos( text, "<pre" ) !== false ) then
--                 text_parts = explode( "</pre>", text );
--                 last_part  = array_pop( text_parts );
--                 text       = "";
--                 i          = 0;

--                 foreach ( text_parts as text_part ) then
--                         start = strpos( text_part, "<pre" );

--                         // Malformed HTML?
--                         if ( false === start ) then
--                                 text .= text_part;
--                                 continue;
--                         end;

--                         name              = "<pre wp-pre-tag-i></pre>";
--                         pre_tags[ name ] = substr( text_part, start ) . "</pre>";

--                         text .= substr( text_part, 0, start ) . name;
--                         i++;
--                 end;

--                 text .= last_part;
--         end;
--         // Change multiple <br>"s into two line breaks, which will turn into paragraphs.
--         text = preg_replace( "|<br\s*/?>\s*<br\s*/?>|", "\n\n", text );

--         allblocks = "(?:table|thead|tfoot|caption|col|colgroup|tbody|tr|td|th|div|dl|dd|dt|ul|ol|li|pre|form|map|area|blockquote|address|math|style|p|h[1-6]|hr|fieldset|legend|section|article|aside|hgroup|header|footer|nav|figure|figcaption|details|menu|summary)";

--         // Add a double line break above block-level opening tags.
--         text = preg_replace( "!(<" . allblocks . "[\s/>])!", "\n\n1", text );

--         // Add a double line break below block-level closing tags.
--         text = preg_replace( "!(</" . allblocks . ">)!", "1\n\n", text );

--         // Add a double line break after hr tags, which are self closing.
--         text = preg_replace( "!(<hr\s*?/?>)!", "1\n\n", text );

--         // Standardize newline characters to "\n".
--         text = str_replace( array( "\r\n", "\r" ), "\n", text );

--         // Find newlines in all elements and add placeholders.
--         text = wp_replace_in_html_tags( text, array( "\n" => " <!-- wpnl --> " ) );

--         // Collapse line breaks before and after <option> elements so they don"t get autop"d.
--         if ( strpos( text, "<option" ) !== false ) then
--                 text = preg_replace( "|\s*<option|", "<option", text );
--                 text = preg_replace( "|</option>\s*|", "</option>", text );
--         end;

--         /*
--         -- Collapse line breaks inside <object> elements, before <param> and <embed> elements
--         -- so they don"t get autop"d.
--         --
--         if ( strpos( text, "</object>" ) !== false ) then
--                 text = preg_replace( "|(<object[^>]*>)\s*|", "1", text );
--                 text = preg_replace( "|\s*</object>|", "</object>", text );
--                 text = preg_replace( "%\s*(</?(?:param|embed)[^>]*>)\s*%", "1", text );
--         end;

--         /*
--         -- Collapse line breaks inside <audio> and <video> elements,
--         -- before and after <source> and <track> elements.
--         --
--         if ( strpos( text, "<source" ) !== false || strpos( text, "<track" ) !== false ) then
--                 text = preg_replace( "%([<\[](?:audio|video)[^>\]]*[>\]])\s*%", "1", text );
--                 text = preg_replace( "%\s*([<\[]/(?:audio|video)[>\]])%", "1", text );
--                 text = preg_replace( "%\s*(<(?:source|track)[^>]*>)\s*%", "1", text );
--         end;

--         // Collapse line breaks before and after <figcaption> elements.
--         if ( strpos( text, "<figcaption" ) !== false ) then
--                 text = preg_replace( "|\s*(<figcaption[^>]*>)|", "1", text );
--                 text = preg_replace( "|</figcaption>\s*|", "</figcaption>", text );
--         end;

--         // Remove more than two contiguous line breaks.
--         text = preg_replace( "/\n\n+/", "\n\n", text );

--         // Split up the contents into an array of strings, separated by double line breaks.
--         paragraphs = preg_split( "/\n\s*\n/", text, -1, PREG_SPLIT_NO_EMPTY );

--         // Reset text prior to rebuilding.
--         text = "";

--         // Rebuild the content as a string, wrapping every bit with a <p>.
--         foreach ( paragraphs as paragraph ) then
--                 text .= "<p>" . trim( paragraph, "\n" ) . "</p>\n";
--         end;

--         // Under certain strange conditions it could create a P of entirely whitespace.
--         text = preg_replace( "|<p>\s*</p>|", "", text );

--         // Add a closing <p> inside <div>, <address>, or <form> tag if missing.
--         text = preg_replace( "!<p>([^<]+)</(div|address|form)>!", "<p>1</p></2>", text );

--         // If an opening or closing block element tag is wrapped in a <p>, unwrap it.
--         text = preg_replace( "!<p>\s*(</?" . allblocks . "[^>]*>)\s*</p>!", "1", text );

--         // In some cases <li> may get wrapped in <p>, fix them.
--         text = preg_replace( "|<p>(<li.+?)</p>|", "1", text );

--         // If a <blockquote> is wrapped with a <p>, move it inside the <blockquote>.
--         text = preg_replace( "|<p><blockquote([^>]*)>|i", "<blockquote1><p>", text );
--         text = str_replace( "</blockquote></p>", "</p></blockquote>", text );

--         // If an opening or closing block element tag is preceded by an opening <p> tag, remove it.
--         text = preg_replace( "!<p>\s*(</?" . allblocks . "[^>]*>)!", "1", text );

--         // If an opening or closing block element tag is followed by a closing <p> tag, remove it.
--         text = preg_replace( "!(</?" . allblocks . "[^>]*>)\s*</p>!", "1", text );

--         // Optionally insert line breaks.
--         if ( br ) then
--                 // Replace newlines that shouldn"t be touched with a placeholder.
--                 text = preg_replace_callback( "/<(script|style|svg).*?<\/\\1>/s", "_autop_newline_preservation_helper", text );

--                 // Normalize <br>
--                 text = str_replace( array( "<br>", "<br/>" ), "<br />", text );

--                 // Replace any new line characters that aren"t preceded by a <br /> with a <br />.
--                 text = preg_replace( "|(?<!<br />)\s*\n|", "<br />\n", text );

--                 // Replace newline placeholders with newlines.
--                 text = str_replace( "<WPPreserveNewline />", "\n", text );
--         end;

--         // If a <br /> tag is after an opening or closing block tag, remove it.
--         text = preg_replace( "!(</?" . allblocks . "[^>]*>)\s*<br />!", "1", text );

--         // If a <br /> tag is before a subset of opening or closing block tags, remove it.
--         text = preg_replace( "!<br />(\s*</?(?:p|li|div|dl|dd|dt|th|pre|td|ul|ol)[^>]*>)!", "1", text );
--         text = preg_replace( "|\n</p>|", "</p>", text );

--         // Replace placeholder <pre> tags with their original content.
--         if ( ! empty( pre_tags ) ) then
--                 text = str_replace( array_keys( pre_tags ), array_values( pre_tags ), text );
--         end;

--         // Restore newlines in all elements.
--         if ( false !== strpos( text, "<!-- wpnl -->" ) ) then
--                 text = str_replace( array( " <!-- wpnl --> ", "<!-- wpnl -->" ), "\n", text );
--         end;

--         return text;
-- end;

-- --
-- -- Separates HTML elements and comments from the text.
-- --
-- -- @since 4.2.4
-- --
-- -- @param string input The text which has to be formatted.
-- -- @return string[] Array of the formatted text.
-- --
-- function wp_html_split( input ) then
--         return preg_split( get_html_split_regex(), input, -1, PREG_SPLIT_DELIM_CAPTURE );
-- end;

-- --
-- -- Retrieves the regular expression for an HTML element.
-- --
-- -- @since 4.4.0
-- --
-- -- @return string The regular expression
-- --
-- function get_html_split_regex() then
--         static regex;

--         if ( ! isset( regex ) ) then
--                 // phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound -- don"t remove regex indentation
--                 comments =
--                         "!"             // Start of comment, after the <.
--                         . "(?:"         // Unroll the loop: Consume everything until --> is found.
--                         .     "-(?!->)" // Dash not followed by end of comment.
--                         .     "[^\-]*+" // Consume non-dashes.
--                         . ")*+"         // Loop possessively.
--                         . "(?:-->)?";   // End of comment. If not found, match all input.

--                 cdata =
--                         "!\[CDATA\["    // Start of comment, after the <.
--                         . "[^\]]*+"     // Consume non-].
--                         . "(?:"         // Unroll the loop: Consume everything until ]]> is found.
--                         .     "](?!]>)" // One ] not followed by end of comment.
--                         .     "[^\]]*+" // Consume non-].
--                         . ")*+"         // Loop possessively.
--                         . "(?:]]>)?";   // End of comment. If not found, match all input.

--                 escaped =
--                         "(?="             // Is the element escaped?
--                         .    "!--"
--                         . "|"
--                         .    "!\[CDATA\["
--                         . ")"
--                         . "(?(?=!-)"      // If yes, which type?
--                         .     comments
--                         . "|"
--                         .     cdata
--                         . ")";

--                 regex =
--                         "/("                // Capture the entire match.
--                         .     "<"           // Find start of element.
--                         .     "(?"          // Conditional expression follows.
--                         .         escaped  // Find end of escaped element.
--                         .     "|"           // ...else...
--                         .         "[^>]*>?" // Find end of normal element.
--                         .     ")"
--                         . ")/";
--                 // phpcs:enable
--         end;

--         return regex;
-- end;

   -----------------------------------
   -- X_Get_Wptexturize_Split_Regex --
   -----------------------------------

   Static_HTML_Regex : UStrings.UString;

   function X_Get_Wptexturize_Split_Regex (Shortcode_Regex : String := "")
                                           return String
   is
      use UStrings;
   begin
      if Static_HTML_Regex = "" then
--    if not Isset (Static_HTML_Regex) then
         -- phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound
         -- don't remove regex indentation
         declare
            Comment_Regex : constant String :=
              "!"             -- Start of comment, after the <.
              & "(?:"         -- Unroll the loop: Consume everything until -->
                              -- is found.
              &     "-(?!->)" -- Dash not followed by end of comment.
              &     "[^\-]*+" -- Consume non-dashes.
              & ")*+"         -- Loop possessively.
              & "(?:-->)?";   -- End of comment. If not found, match all input.
         begin
            -- Needs replaced with wp_html_split() per Shortcode API Roadmap.
            Static_HTML_Regex :=
              +"<"                  -- Find start of element.
               & "(?(?=!--)"        -- Is this a comment?
               &     Comment_Regex  -- Find end of comment.
               & "|"
               &     "[^>]*>?"      -- Find end of element. If not found, match
                                    -- all input.
               & ")";
         end;
         -- phpcs:enable
      end if;

      declare
         Regex : constant String :=
           (if Shortcode_Regex = ""
            then "/(" & (-Static_HTML_Regex) & ")/"
            else "/(" & (-Static_HTML_Regex) & "|" & Shortcode_Regex & ")/");
      begin
         return Regex;
      end;
   end X_Get_Wptexturize_Split_Regex;

   ---------------------------------------
   -- X_Get_Wptexturize_Shortcode_Regex --
   ---------------------------------------

   function X_Get_Wptexturize_Shortcode_Regex (Tagnames : List_Type)
                                               return String
   is
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;

      Tagregexp_2 : constant String :=
        Implode ("|", List_Map (Preg_Quote'Access, Tagnames));

      Tagregexp : constant String :=
        "(?:" & Tagregexp_2 & ")(?=[\\s\\]\\/])"; -- Excerpt of get_shortcode_regex().

      -- phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound
      -- don't remove regex indentation
      Regex : constant String :=
        "\["                -- Find start of shortcode.
        & "[\/\[]?"         -- Shortcodes may begin with [/ or [[.
        & Tagregexp         -- Only match registered shortcodes, because performance.
        & "(?:"
        &     "[^\[\]<>]+"  -- Shortcodes do not contain other shortcodes.
        --                     Quantifier critical.
        & "|"
        &     "<[^\[\]>]*>" -- HTML elements permitted. Prevents matching ] before >.
        & ")*+"             -- Possessive critical.
        & "\]"              -- Find end of shortcode.
        & "\]?";            -- Shortcodes may end with ]].
        -- phpcs:enable
   begin
      return Regex;
   end X_Get_Wptexturize_Shortcode_Regex;

-- --
-- -- Replaces characters or phrases within HTML elements only.
-- --
-- -- @since 4.2.3
-- --
-- -- @param string haystack      The text which has to be formatted.
-- -- @param array  replace_pairs In the form array("from" => "to", ...).
-- -- @return string The formatted text.
-- --
-- function wp_replace_in_html_tags( haystack, replace_pairs ) then
--         // Find all elements.
--         textarr = wp_html_split( haystack );
--         changed = false;

--         // Optimize when searching for one item.
--         if ( 1 === count( replace_pairs ) ) then
--                 // Extract needle and replace.
--                 foreach ( replace_pairs as needle => replace ) then
--                 end;

--                 // Loop through delimiters (elements) only.
--                 for ( i = 1, c = count( textarr ); i < c; i += 2 ) then
--                         if ( false !== strpos( textarr[ i ], needle ) ) then
--                                 textarr[ i ] = str_replace( needle, replace, textarr[ i ] );
--                                 changed       = true;
--                         end;
--                 end;
--         end; else then
--                 // Extract all needles.
--                 needles = array_keys( replace_pairs );

--                 // Loop through delimiters (elements) only.
--                 for ( i = 1, c = count( textarr ); i < c; i += 2 ) then
--                         foreach ( needles as needle ) then
--                                 if ( false !== strpos( textarr[ i ], needle ) ) then
--                                         textarr[ i ] = strtr( textarr[ i ], replace_pairs );
--                                         changed       = true;
--                                         // After one strtr() break out of the foreach loop and look at next element.
--                                         break;
--                                 end;
--                         end;
--                 end;
--         end;

--         if ( changed ) then
--                 haystack = implode( textarr );
--         end;

--         return haystack;
-- end;

-- --
-- -- Newline preservation help function for wpautop().
-- --
-- -- @since 3.1.0
-- -- @access private
-- --
-- -- @param array matches preg_replace_callback matches array
-- -- @return string
-- --
-- function _autop_newline_preservation_helper( matches ) then
--         return str_replace( "\n", "<WPPreserveNewline />", matches[0] );
-- end;

-- --
-- -- Don"t auto-p wrap shortcodes that stand alone.
-- --
-- -- Ensures that shortcodes are not wrapped in `<p>...</p>`.
-- --
-- -- @since 2.9.0
-- --
-- -- @global array shortcode_tags
-- --
-- -- @param string text The content.
-- -- @return string The filtered content.
-- --
-- function shortcode_unautop( text ) then
--         global shortcode_tags;

--         if ( empty( shortcode_tags ) || ! is_array( shortcode_tags ) ) then
--                 return text;
--         end;

--         tagregexp = implode( "|", array_map( "preg_quote", array_keys( shortcode_tags ) ) );
--         spaces    = wp_spaces_regexp();

--         // phpcs:disable Squiz.Strings.ConcatenationSpacing.PaddingFound,WordPress.WhiteSpace.PrecisionAlignment.Found -- don"t remove regex indentation
--         pattern =
--                 "/"
--                 . "<p>"                              // Opening paragraph.
--                 . "(?:" . spaces . ")*+"            // Optional leading whitespace.
--                 . "("                                // 1: The shortcode.
--                 .     "\\["                          // Opening bracket.
--                 .     "(tagregexp)"                 // 2: Shortcode name.
--                 .     "(?![\\w-])"                   // Not followed by word character or hyphen.
--                                                                                          // Unroll the loop: Inside the opening shortcode tag.
--                 .     "[^\\]\\/]*"                   // Not a closing bracket or forward slash.
--                 .     "(?:"
--                 .         "\\/(?!\\])"               // A forward slash not followed by a closing bracket.
--                 .         "[^\\]\\/]*"               // Not a closing bracket or forward slash.
--                 .     ")*?"
--                 .     "(?:"
--                 .         "\\/\\]"                   // Self closing tag and closing bracket.
--                 .     "|"
--                 .         "\\]"                      // Closing bracket.
--                 .         "(?:"                      // Unroll the loop: Optionally, anything between the opening and closing shortcode tags.
--                 .             "[^\\[]*+"             // Not an opening bracket.
--                 .             "(?:"
--                 .                 "\\[(?!\\/\\2\\])" // An opening bracket not followed by the closing shortcode tag.
--                 .                 "[^\\[]*+"         // Not an opening bracket.
--                 .             ")*+"
--                 .             "\\[\\/\\2\\]"         // Closing shortcode tag.
--                 .         ")?"
--                 .     ")"
--                 . ")"
--                 . "(?:" . spaces . ")*+"            // Optional trailing whitespace.
--                 . "<\\/p>"                           // Closing paragraph.
--                 . "/";
--         // phpcs:enable

--         return preg_replace( pattern, "1", text );
-- end;

-- --
-- -- Checks to see if a string is utf8 encoded.
-- --
-- -- NOTE: This function checks for 5-Byte sequences, UTF8
-- --       has Bytes Sequences with a maximum length of 4.
-- --
-- -- @author bmorel at ssi dot fr (modified)
-- -- @since 1.2.1
-- --
-- -- @param string str The string to be checked
-- -- @return bool True if str fits a UTF-8 model, false otherwise.
-- --
-- function seems_utf8( str ) then
--         mbstring_binary_safe_encoding();
--         length = strlen( str );
--         reset_mbstring_encoding();
--         for ( i = 0; i < length; i++ ) then
--                 c = ord( str[ i ] );
--                 if ( c < 0x80 ) then
--                         n = 0; // 0bbbbbbb
--                 end; elseif ( ( c & 0xE0 ) == 0xC0 ) then
--                         n = 1; // 110bbbbb
--                 end; elseif ( ( c & 0xF0 ) == 0xE0 ) then
--                         n = 2; // 1110bbbb
--                 end; elseif ( ( c & 0xF8 ) == 0xF0 ) then
--                         n = 3; // 11110bbb
--                 end; elseif ( ( c & 0xFC ) == 0xF8 ) then
--                         n = 4; // 111110bb
--                 end; elseif ( ( c & 0xFE ) == 0xFC ) then
--                         n = 5; // 1111110b
--                 end; else then
--                         return false; // Does not match any model.
--                 end;
--                 for ( j = 0; j < n; j++ ) then // n bytes matching 10bbbbbb follow ?
--                         if ( ( ++i == length ) || ( ( ord( str[ i ] ) & 0xC0 ) != 0x80 ) ) then
--                                 return false;
--                         end;
--                 end;
--         end;
--         return true;
-- end;

   Static_X_Charset_Set : Boolean := False;
   Static_X_Charset     : UStrings.UString;

   -----------------------
   -- X_Wp_Specialchars --
   -----------------------

   function X_Wp_Specialchars
              (Item          : String;
               Quote_Style   : Php.HTML.Flag_Type := Php.HTML.ENT_NOQUOTES;
               Charset       : String  := "";
               Double_Encode : Boolean := False)
               return String
   is
      use Php.HTML;
      use Php.Lists;
      use Php.Preg;
      use UStrings;

      Quote_Style_2 : Php.HTML.Flag_Type := Quote_Style;
      X_Quote_Style : Php.HTML.Flag_Type := Quote_Style_2;
      Charset_2     : UString := +Charset;
      Item_2        : UString := +Item;
   begin
      if 0 = Item'Length then
         return "";
      end if;

      -- Don't bother if there are no specialchars - saves some processing.
      if not Preg_Match ("/[&<>'\']/", Item) then
         return Item;
      end if;

      -- Account for the previous behaviour of the function when the quote_style is
      -- not an accepted value.
      if False then -- Empty (Quote_Style) then
         Quote_Style_2 := ENT_NOQUOTES;
      elsif ENT_XML1 = Quote_Style_2 then
         Quote_Style_2 := ENT_QUOTES + ENT_XML1; -- or
      elsif True
--      not In_Array (Quote_Style,
--                    list_type'[ENT_NOQUOTES, ENT_COMPAT, ENT_QUOTES,
--                                      "single", "double"], True)
      then
         Quote_Style_2 := ENT_QUOTES;
      end if;

      -- Store the site charset as a static to avoid multiple calls to
      -- wp_load_alloptions().
      if Charset = "" then
--       static _charset = null;
         if not Static_X_Charset_Set then
            declare
               Alloptions : constant Array_Type :=
                 Inc_Options.Wp_Load_Alloptions; -- ()
            begin
               Static_X_Charset :=
                 +(if Isset (Alloptions, "blog_charset")
                   then Get_As_String (Alloptions, "blog_charset") else "");
            end;
            Static_X_Charset_Set := True;
         end if;
         Charset_2 := Static_X_Charset;
      end if;

      if
        In_List (-Charset_2, List_Type'["utf8", "utf-8", "UTF8"], True)
      then
         Charset_2 := +"UTF-8";
      end if;

      X_Quote_Style := Quote_Style;

      -- if "double" = Quote_Style then
      --    Quote_Style   := ENT_COMPAT;
      --    X_Quote_Style := ENT_COMPAT;
      -- elsif "single" = Quote_Style then
      --    Quote_Style := ENT_NOQUOTES;
      -- end if;

      if not Double_Encode then
         -- Guarantee every &entity; is valid, convert &garbage; into &amp;garbage;
         -- This is required for PHP < 5.4.0 because ENT_HTML401 flag is unavailable.
         Item_2 :=
           +Inc_KSES.Wp_KSES_Normalize_Entities (-Item_2,
                                        (if Quote_Style mod ENT_XML1 /= 16#0000#
                                         then "xml" else "html"));
      end if;

      Item_2 := +HTML_Special_Chars (-Item_2, Quote_Style, Charset, Double_Encode);

      -- -- Back-compat.
      -- if "single" = X_Quote_Style then
      --    Item_2 := +Str_Replace ("'", "&#039;", -Item_2);
      -- end if;

      return -Item_2;
   end X_Wp_Specialchars;

-- --
-- -- Converts a number of HTML entities into their special characters.
-- --
-- -- Specifically deals with: `&`, `<`, `>`, `"`, and `"`.
-- --
-- -- `quote_style` can be set to ENT_COMPAT to decode `"` entities,
-- -- or ENT_QUOTES to do both `"` and `"`. Default is ENT_NOQUOTES where no quotes are decoded.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string     string The text which is to be decoded.
-- -- @param string|int quote_style Optional. Converts double quotes if set to ENT_COMPAT,
-- --                                both single and double if set to ENT_QUOTES or
-- --                                none if set to ENT_NOQUOTES.
-- --                                Also compatible with old _wp_specialchars() values;
-- --                                converting single quotes if set to "single",
-- --                                double if set to "double" or both if otherwise set.
-- --                                Default is ENT_NOQUOTES.
-- -- @return string The decoded text without HTML entities.
-- --
-- function wp_specialchars_decode( string, quote_style = ENT_NOQUOTES ) then
--         string = (string) string;

--         if ( 0 === strlen( string ) ) then
--                 return "";
--         end;

--         // Don"t bother if there are no entities - saves a lot of processing.
--         if ( strpos( string, "&" ) === false ) then
--                 return string;
--         end;

--         // Match the previous behaviour of _wp_specialchars() when the quote_style is not an accepted value.
--         if ( empty( quote_style ) ) then
--                 quote_style = ENT_NOQUOTES;
--         end; elseif ( ! in_array( quote_style, array( 0, 2, 3, "single", "double" ), true ) ) then
--                 quote_style = ENT_QUOTES;
--         end;

--         // More complete than get_html_translation_table( HTML_SPECIALCHARS ).
--         single      = array(
--                 "&#039;" => "\"",
--                 "&#x27;" => "\"",
--         );
--         single_preg = array(
--                 "/&#0*39;/"   => "&#039;",
--                 "/&#x0*27;/i" => "&#x27;",
--         );
--         double      = array(
--                 "&quot;" => """,
--                 "&#034;" => """,
--                 "&#x22;" => """,
--         );
--         double_preg = array(
--                 "/&#0*34;/"   => "&#034;",
--                 "/&#x0*22;/i" => "&#x22;",
--         );
--         others      = array(
--                 "&lt;"   => "<",
--                 "&#060;" => "<",
--                 "&gt;"   => ">",
--                 "&#062;" => ">",
--                 "&amp;"  => "&",
--                 "&#038;" => "&",
--                 "&#x26;" => "&",
--         );
--         others_preg = array(
--                 "/&#0*60;/"   => "&#060;",
--                 "/&#0*62;/"   => "&#062;",
--                 "/&#0*38;/"   => "&#038;",
--                 "/&#x0*26;/i" => "&#x26;",
--         );

--         if ( ENT_QUOTES === quote_style ) then
--                 translation      = array_merge( single, double, others );
--                 translation_preg = array_merge( single_preg, double_preg, others_preg );
--         end; elseif ( ENT_COMPAT === quote_style || "double" === quote_style ) then
--                 translation      = array_merge( double, others );
--                 translation_preg = array_merge( double_preg, others_preg );
--         end; elseif ( "single" === quote_style ) then
--                 translation      = array_merge( single, others );
--                 translation_preg = array_merge( single_preg, others_preg );
--         end; elseif ( ENT_NOQUOTES === quote_style ) then
--                 translation      = others;
--                 translation_preg = others_preg;
--         end;

--         // Remove zero padding on numeric entities.
--         string = preg_replace( array_keys( translation_preg ), array_values( translation_preg ), string );

--         // Replace characters according to translation table.
--         return strtr( string, translation );
-- end;

   Static_Is_UTF8      : Boolean := False;
   Static_Is_UTF8_Bool : Boolean := False;

   ---------------------------
   -- Wp_Check_Invalid_UTF8 --
   ---------------------------

   function Wp_Check_Invalid_UTF8 (Item  : String;
                                   Strip : Boolean := False)
                                   return String
   is
      use Php.Lists;
      use Inc_Options;

   begin
      if 0 = Item'Length then
         return "";
      end if;

      -- Store the site charset as a static to avoid multiple calls to get_option().
--    static is_utf8 = null;
      if not Static_Is_UTF8_Bool then
         Static_Is_UTF8 :=
           In_List (Get_Option ("blog_charset"),
                    List_Type'["utf8", "utf-8", "UTF8", "UTF-8"], True);
         Static_Is_UTF8_Bool := True;
      end if;

      if not Static_Is_UTF8 then
         return Item;
      end if;

      -- Check for support for utf8 in the installed PCRE library once and store the
      -- result in a static.
      -- static utf8_pcre = null;
      -- if ( ! isset( utf8_pcre ) ) then
      --    -- phpcs:ignore WordPress.PHP.NoSilencedErrors.Discouraged
      --    utf8_pcre = @preg_match( "/^./u", "a" );
      -- end if;

      -- We Can't demand utf8 in the PCRE installation, so just return the string in
      -- those cases.
      -- if ( ! utf8_pcre ) then
      return Item;
      -- end if;

      -- phpcs:ignore WordPress.PHP.NoSilencedErrors.Discouraged
      -- preg_match fails when it encounters invalid UTF8 in string.
      -- if ( 1 === @preg_match( "/^./us", string ) ) then
      --    return string;
      -- end if;

      -- Attempt to strip the bad chars if requested (not recommended).
      -- if Strip then -- and then function_exists( "iconv" ) ) then
      --    return Wp_Iconv.Iconv ("utf-8", "utf-8", Item);
      -- end if;

--    return "";
   end Wp_Check_Invalid_UTF8;

-- --
-- -- Encodes the Unicode values to be used in the URI.
-- --
-- -- @since 1.5.0
-- -- @since 5.8.3 Added the `encode_ascii_characters` parameter.
-- --
-- -- @param string utf8_string             String to encode.
-- -- @param int    length                  Max length of the string
-- -- @param bool   encode_ascii_characters Whether to encode ascii characters such as < " "
-- -- @return string String with Unicode encoded for URI.
-- --
-- function utf8_uri_encode( utf8_string, length = 0, encode_ascii_characters = false ) then
--         unicode        = "";
--         values         = array();
--         num_octets     = 1;
--         unicode_length = 0;

--         mbstring_binary_safe_encoding();
--         string_length = strlen( utf8_string );
--         reset_mbstring_encoding();

--         for ( i = 0; i < string_length; i++ ) then

--                 value = ord( utf8_string[ i ] );

--                 if ( value < 128 ) then
--                         char                = chr( value );
--                         encoded_char        = encode_ascii_characters ? rawurlencode( char ) : char;
--                         encoded_char_length = strlen( encoded_char );
--                         if ( length && ( unicode_length + encoded_char_length ) > length ) then
--                                 break;
--                         end;
--                         unicode        .= encoded_char;
--                         unicode_length += encoded_char_length;
--                 end; else then
--                         if ( count( values ) == 0 ) then
--                                 if ( value < 224 ) then
--                                         num_octets = 2;
--                                 end; elseif ( value < 240 ) then
--                                         num_octets = 3;
--                                 end; else then
--                                         num_octets = 4;
--                                 end;
--                         end;

--                         values[] = value;

--                         if ( length && ( unicode_length + ( num_octets-- 3 ) ) > length ) then
--                                 break;
--                         end;
--                         if ( count( values ) == num_octets ) then
--                                 for ( j = 0; j < num_octets; j++ ) then
--                                         unicode .= "%" . dechex( values[ j ] );
--                                 end;

--                                 unicode_length += num_octets-- 3;

--                                 values     = array();
--                                 num_octets = 1;
--                         end;
--                 end;
--         end;

--         return unicode;
-- end;

   --------------------
   -- Remove_Accents --
   --------------------

   function Remove_Accents (Item   : String;
                            Locale : String := "")
                            return String
                            is (Item & "XXX-009");
--         if ( ! preg_match( "/[\x80-\xff]/", string ) ) then
--                 return string;
--         end;

--         if ( seems_utf8( string ) ) then

--                 // Unicode sequence normalization from NFD (Normalization Form Decomposed)
--                 // to NFC (Normalization Form [Pre]Composed), the encoding used in this function.
--                 if ( function_exists( "normalizer_is_normalized" )
--                         && function_exists( "normalizer_normalize" )
--                 ) then
--                         if ( ! normalizer_is_normalized( string ) ) then
--                                 string = normalizer_normalize( string );
--                         end;
--                 end;

--                 chars = array(
--                         // Decompositions for Latin-1 Supplement.
--                         "ª" => "a",
--                         "º" => "o",
--                         "À" => "A",
--                         "Á" => "A",
--                         "Â" => "A",
--                         "Ã" => "A",
--                         "Ä" => "A",
--                         "Å" => "A",
--                         "Æ" => "AE",
--                         "Ç" => "C",
--                         "È" => "E",
--                         "É" => "E",
--                         "Ê" => "E",
--                         "Ë" => "E",
--                         "Ì" => "I",
--                         "Í" => "I",
--                         "Î" => "I",
--                         "Ï" => "I",
--                         "Ð" => "D",
--                         "Ñ" => "N",
--                         "Ò" => "O",
--                         "Ó" => "O",
--                         "Ô" => "O",
--                         "Õ" => "O",
--                         "Ö" => "O",
--                         "Ù" => "U",
--                         "Ú" => "U",
--                         "Û" => "U",
--                         "Ü" => "U",
--                         "Ý" => "Y",
--                         "Þ" => "TH",
--                         "ß" => "s",
--                         "à" => "a",
--                         "á" => "a",
--                         "â" => "a",
--                         "ã" => "a",
--                         "ä" => "a",
--                         "å" => "a",
--                         "æ" => "ae",
--                         "ç" => "c",
--                         "è" => "e",
--                         "é" => "e",
--                         "ê" => "e",
--                         "ë" => "e",
--                         "ì" => "i",
--                         "í" => "i",
--                         "î" => "i",
--                         "ï" => "i",
--                         "ð" => "d",
--                         "ñ" => "n",
--                         "ò" => "o",
--                         "ó" => "o",
--                         "ô" => "o",
--                         "õ" => "o",
--                         "ö" => "o",
--                         "ø" => "o",
--                         "ù" => "u",
--                         "ú" => "u",
--                         "û" => "u",
--                         "ü" => "u",
--                         "ý" => "y",
--                         "þ" => "th",
--                         "ÿ" => "y",
--                         "Ø" => "O",
--                         // Decompositions for Latin Extended-A.
--                         "Ā" => "A",
--                         "ā" => "a",
--                         "Ă" => "A",
--                         "ă" => "a",
--                         "Ą" => "A",
--                         "ą" => "a",
--                         "Ć" => "C",
--                         "ć" => "c",
--                         "Ĉ" => "C",
--                         "ĉ" => "c",
--                         "Ċ" => "C",
--                         "ċ" => "c",
--                         "Č" => "C",
--                         "č" => "c",
--                         "Ď" => "D",
--                         "ď" => "d",
--                         "Đ" => "D",
--                         "đ" => "d",
--                         "Ē" => "E",
--                         "ē" => "e",
--                         "Ĕ" => "E",
--                         "ĕ" => "e",
--                         "Ė" => "E",
--                         "ė" => "e",
--                         "Ę" => "E",
--                         "ę" => "e",
--                         "Ě" => "E",
--                         "ě" => "e",
--                         "Ĝ" => "G",
--                         "ĝ" => "g",
--                         "Ğ" => "G",
--                         "ğ" => "g",
--                         "Ġ" => "G",
--                         "ġ" => "g",
--                         "Ģ" => "G",
--                         "ģ" => "g",
--                         "Ĥ" => "H",
--                         "ĥ" => "h",
--                         "Ħ" => "H",
--                         "ħ" => "h",
--                         "Ĩ" => "I",
--                         "ĩ" => "i",
--                         "Ī" => "I",
--                         "ī" => "i",
--                         "Ĭ" => "I",
--                         "ĭ" => "i",
--                         "Į" => "I",
--                         "į" => "i",
--                         "İ" => "I",
--                         "ı" => "i",
--                         "Ĳ" => "IJ",
--                         "ĳ" => "ij",
--                         "Ĵ" => "J",
--                         "ĵ" => "j",
--                         "Ķ" => "K",
--                         "ķ" => "k",
--                         "ĸ" => "k",
--                         "Ĺ" => "L",
--                         "ĺ" => "l",
--                         "Ļ" => "L",
--                         "ļ" => "l",
--                         "Ľ" => "L",
--                         "ľ" => "l",
--                         "Ŀ" => "L",
--                         "ŀ" => "l",
--                         "Ł" => "L",
--                         "ł" => "l",
--                         "Ń" => "N",
--                         "ń" => "n",
--                         "Ņ" => "N",
--                         "ņ" => "n",
--                         "Ň" => "N",
--                         "ň" => "n",
--                         "ŉ" => "n",
--                         "Ŋ" => "N",
--                         "ŋ" => "n",
--                         "Ō" => "O",
--                         "ō" => "o",
--                         "Ŏ" => "O",
--                         "ŏ" => "o",
--                         "Ő" => "O",
--                         "ő" => "o",
--                         "Œ" => "OE",
--                         "œ" => "oe",
--                         "Ŕ" => "R",
--                         "ŕ" => "r",
--                         "Ŗ" => "R",
--                         "ŗ" => "r",
--                         "Ř" => "R",
--                         "ř" => "r",
--                         "Ś" => "S",
--                         "ś" => "s",
--                         "Ŝ" => "S",
--                         "ŝ" => "s",
--                         "Ş" => "S",
--                         "ş" => "s",
--                         "Š" => "S",
--                         "š" => "s",
--                         "Ţ" => "T",
--                         "ţ" => "t",
--                         "Ť" => "T",
--                         "ť" => "t",
--                         "Ŧ" => "T",
--                         "ŧ" => "t",
--                         "Ũ" => "U",
--                         "ũ" => "u",
--                         "Ū" => "U",
--                         "ū" => "u",
--                         "Ŭ" => "U",
--                         "ŭ" => "u",
--                         "Ů" => "U",
--                         "ů" => "u",
--                         "Ű" => "U",
--                         "ű" => "u",
--                         "Ų" => "U",
--                         "ų" => "u",
--                         "Ŵ" => "W",
--                         "ŵ" => "w",
--                         "Ŷ" => "Y",
--                         "ŷ" => "y",
--                         "Ÿ" => "Y",
--                         "Ź" => "Z",
--                         "ź" => "z",
--                         "Ż" => "Z",
--                         "ż" => "z",
--                         "Ž" => "Z",
--                         "ž" => "z",
--                         "ſ" => "s",
--                         // Decompositions for Latin Extended-B.
--                         "Ș" => "S",
--                         "ș" => "s",
--                         "Ț" => "T",
--                         "ț" => "t",
--                         // Euro sign.
--                         "€" => "E",
--                         // GBP (Pound) sign.
--                         "£" => "",
--                         // Vowels with diacritic (Vietnamese).
--                         // Unmarked.
--                         "Ơ" => "O",
--                         "ơ" => "o",
--                         "Ư" => "U",
--                         "ư" => "u",
--                         // Grave accent.
--                         "Ầ" => "A",
--                         "ầ" => "a",
--                         "Ằ" => "A",
--                         "ằ" => "a",
--                         "Ề" => "E",
--                         "ề" => "e",
--                         "Ồ" => "O",
--                         "ồ" => "o",
--                         "Ờ" => "O",
--                         "ờ" => "o",
--                         "Ừ" => "U",
--                         "ừ" => "u",
--                         "Ỳ" => "Y",
--                         "ỳ" => "y",
--                         // Hook.
--                         "Ả" => "A",
--                         "ả" => "a",
--                         "Ẩ" => "A",
--                         "ẩ" => "a",
--                         "Ẳ" => "A",
--                         "ẳ" => "a",
--                         "Ẻ" => "E",
--                         "ẻ" => "e",
--                         "Ể" => "E",
--                         "ể" => "e",
--                         "Ỉ" => "I",
--                         "ỉ" => "i",
--                         "Ỏ" => "O",
--                         "ỏ" => "o",
--                         "Ổ" => "O",
--                         "ổ" => "o",
--                         "Ở" => "O",
--                         "ở" => "o",
--                         "Ủ" => "U",
--                         "ủ" => "u",
--                         "Ử" => "U",
--                         "ử" => "u",
--                         "Ỷ" => "Y",
--                         "ỷ" => "y",
--                         // Tilde.
--                         "Ẫ" => "A",
--                         "ẫ" => "a",
--                         "Ẵ" => "A",
--                         "ẵ" => "a",
--                         "Ẽ" => "E",
--                         "ẽ" => "e",
--                         "Ễ" => "E",
--                         "ễ" => "e",
--                         "Ỗ" => "O",
--                         "ỗ" => "o",
--                         "Ỡ" => "O",
--                         "ỡ" => "o",
--                         "Ữ" => "U",
--                         "ữ" => "u",
--                         "Ỹ" => "Y",
--                         "ỹ" => "y",
--                         // Acute accent.
--                         "Ấ" => "A",
--                         "ấ" => "a",
--                         "Ắ" => "A",
--                         "ắ" => "a",
--                         "Ế" => "E",
--                         "ế" => "e",
--                         "Ố" => "O",
--                         "ố" => "o",
--                         "Ớ" => "O",
--                         "ớ" => "o",
--                         "Ứ" => "U",
--                         "ứ" => "u",
--                         // Dot below.
--                         "Ạ" => "A",
--                         "ạ" => "a",
--                         "Ậ" => "A",
--                         "ậ" => "a",
--                         "Ặ" => "A",
--                         "ặ" => "a",
--                         "Ẹ" => "E",
--                         "ẹ" => "e",
--                         "Ệ" => "E",
--                         "ệ" => "e",
--                         "Ị" => "I",
--                         "ị" => "i",
--                         "Ọ" => "O",
--                         "ọ" => "o",
--                         "Ộ" => "O",
--                         "ộ" => "o",
--                         "Ợ" => "O",
--                         "ợ" => "o",
--                         "Ụ" => "U",
--                         "ụ" => "u",
--                         "Ự" => "U",
--                         "ự" => "u",
--                         "Ỵ" => "Y",
--                         "ỵ" => "y",
--                         // Vowels with diacritic (Chinese, Hanyu Pinyin).
--                         "ɑ" => "a",
--                         // Macron.
--                         "Ǖ" => "U",
--                         "ǖ" => "u",
--                         // Acute accent.
--                         "Ǘ" => "U",
--                         "ǘ" => "u",
--                         // Caron.
--                         "Ǎ" => "A",
--                         "ǎ" => "a",
--                         "Ǐ" => "I",
--                         "ǐ" => "i",
--                         "Ǒ" => "O",
--                         "ǒ" => "o",
--                         "Ǔ" => "U",
--                         "ǔ" => "u",
--                         "Ǚ" => "U",
--                         "ǚ" => "u",
--                         // Grave accent.
--                         "Ǜ" => "U",
--                         "ǜ" => "u",
--                 );

--                 // Used for locale-specific rules.
--                 if ( empty( locale ) ) then
--                         locale = get_locale();
--                 end;

--                 /*
--                 -- German has various locales (de_DE, de_CH, de_AT, ...) with formal and informal variants.
--                 -- There is no 3-letter locale like "def", so checking for "de" instead of "de_" is safe,
--                 -- since "de" itself would be a valid locale too.
--                 --
--                 if ( str_starts_with( locale, "de" ) ) then
--                         chars["Ä"] = "Ae";
--                         chars["ä"] = "ae";
--                         chars["Ö"] = "Oe";
--                         chars["ö"] = "oe";
--                         chars["Ü"] = "Ue";
--                         chars["ü"] = "ue";
--                         chars["ß"] = "ss";
--                 end; elseif ( "da_DK" === locale ) then
--                         chars["Æ"] = "Ae";
--                         chars["æ"] = "ae";
--                         chars["Ø"] = "Oe";
--                         chars["ø"] = "oe";
--                         chars["Å"] = "Aa";
--                         chars["å"] = "aa";
--                 end; elseif ( "ca" === locale ) then
--                         chars["l·l"] = "ll";
--                 end; elseif ( "sr_RS" === locale || "bs_BA" === locale ) then
--                         chars["Đ"] = "DJ";
--                         chars["đ"] = "dj";
--                 end;

--                 string = strtr( string, chars );
--         end; else then
--                 chars = array();
--                 // Assume ISO-8859-1 if not UTF-8.
--                 chars["in"] = "\x80\x83\x8a\x8e\x9a\x9e"
--                         . "\x9f\xa2\xa5\xb5\xc0\xc1\xc2"
--                         . "\xc3\xc4\xc5\xc7\xc8\xc9\xca"
--                         . "\xcb\xcc\xcd\xce\xcf\xd1\xd2"
--                         . "\xd3\xd4\xd5\xd6\xd8\xd9\xda"
--                         . "\xdb\xdc\xdd\xe0\xe1\xe2\xe3"
--                         . "\xe4\xe5\xe7\xe8\xe9\xea\xeb"
--                         . "\xec\xed\xee\xef\xf1\xf2\xf3"
--                         . "\xf4\xf5\xf6\xf8\xf9\xfa\xfb"
--                         . "\xfc\xfd\xff";

--                 chars["out"] = "EfSZszYcYuAAAAAACEEEEIIIINOOOOOOUUUUYaaaaaaceeeeiiiinoooooouuuuyy";

--                 string              = strtr( string, chars["in"], chars["out"] );
--                 double_chars        = array();
--                 double_chars["in"]  = array( "\x8c", "\x9c", "\xc6", "\xd0", "\xde", "\xdf", "\xe6", "\xf0", "\xfe" );
--                 double_chars["out"] = array( "OE", "oe", "AE", "DH", "TH", "ss", "ae", "dh", "th" );
--                 string              = str_replace( double_chars["in"], double_chars["out"], string );
--         end;

--         return string;
-- end;

-- --
-- -- Sanitizes a filename, replacing whitespace with dashes.
-- --
-- -- Removes special characters that are illegal in filenames on certain
-- -- operating systems and special characters requiring special escaping
-- -- to manipulate at the command line. Replaces spaces and consecutive
-- -- dashes with a single dash. Trims period, dash and underscore from beginning
-- -- and end of filename. It is not guaranteed that this function will return a
-- -- filename that is allowed to be uploaded.
-- --
-- -- @since 2.1.0
-- --
-- -- @param string filename The filename to be sanitized.
-- -- @return string The sanitized filename.
-- --
-- function sanitize_file_name( filename ) then
--         filename_raw = filename;
--         filename     = remove_accents( filename );

--         special_chars = array( "?", "[", "]", "/", "\\", "=", "<", ">", ":", ";", ",", """, """, "&", "", "#", "*", "(", ")", "|", "~", "`", "!", "then", "end;", "%", "+", "’", "«", "»", "”", "“", chr( 0 ) );

--         // Check for support for utf8 in the installed PCRE library once and store the result in a static.
--         static utf8_pcre = null;
--         if ( ! isset( utf8_pcre ) ) then
--                 // phpcs:ignore WordPress.PHP.NoSilencedErrors.Discouraged
--                 utf8_pcre = @preg_match( "/^./u", "a" );
--         end;

--         if ( ! seems_utf8( filename ) ) then
--                 _ext     = pathinfo( filename, PATHINFO_EXTENSION );
--                 _name    = pathinfo( filename, PATHINFO_FILENAME );
--                 filename = sanitize_title_with_dashes( _name ) . "." . _ext;
--         end;

--         if ( utf8_pcre ) then
--                 filename = preg_replace( "#\xthen00a0end;#siu", " ", filename );
--         end;

--         --
--         -- Filters the list of characters to remove from a filename.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string[] special_chars Array of characters to remove.
--         -- @param string   filename_raw  The original filename to be sanitized.
--         --
--         special_chars = apply_filters( "sanitize_file_name_chars", special_chars, filename_raw );

--         filename = str_replace( special_chars, "", filename );
--         filename = str_replace( array( "%20", "+" ), "-", filename );
--         filename = preg_replace( "/[\r\n\t -]+/", "-", filename );
--         filename = trim( filename, ".-_" );

--         if ( false === strpos( filename, "." ) ) then
--                 mime_types = wp_get_mime_types();
--                 filetype   = wp_check_filetype( "test." . filename, mime_types );
--                 if ( filetype["ext"] === filename ) then
--                         filename = "unnamed-file." . filetype["ext"];
--                 end;
--         end;

--         // Split the filename into a base and extension[s].
--         parts = explode( ".", filename );

--         // Return if only one extension.
--         if ( count( parts ) <= 2 ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "sanitize_file_name", filename, filename_raw );
--         end;

--         // Process multiple extensions.
--         filename  = array_shift( parts );
--         extension = array_pop( parts );
--         mimes     = get_allowed_mime_types();

--         /*
--         -- Loop over any intermediate extensions. Postfix them with a trailing underscore
--         -- if they are a 2 - 5 character long alpha string not in the allowed extension list.
--         --
--         foreach ( (array) parts as part ) then
--                 filename .= "." . part;

--                 if ( preg_match( "/^[a-zA-Z]then2,5end;\d?/", part ) ) then
--                         allowed = false;
--                         foreach ( mimes as ext_preg => mime_match ) then
--                                 ext_preg = "!^(" . ext_preg . ")!i";
--                                 if ( preg_match( ext_preg, part ) ) then
--                                         allowed = true;
--                                         break;
--                                 end;
--                         end;
--                         if ( ! allowed ) then
--                                 filename .= "_";
--                         end;
--                 end;
--         end;

--         filename .= "." . extension;

--         --
--         -- Filters a sanitized filename string.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string filename     Sanitized filename.
--         -- @param string filename_raw The filename prior to sanitization.
--         --
--         return apply_filters( "sanitize_file_name", filename, filename_raw );
-- end;

   -------------------
   -- Sanitize_User --
   -------------------

   function Sanitize_User (Username : String;
                           Strict   : Boolean := False)
                           return String
   is
      use Php.Preg;
      use Php.Strings;
      use Wp_Common;

      Raw_Username : constant String := Username;
      Username_2   : constant String := Wp_Strip_All_Tags (Username);
      Username_3   : constant String := Remove_Accents (Username_2);

      -- Kill octets.
      Username_4   : constant String :=
        Preg_Replace ("|%([a-fA-F0-9][a-fA-F0-9])|", "", Username_3);

      -- Kill entities.
      Username_5 : constant String := Preg_Replace ("/&.+?;/", "", Username_4);

      -- If strict, reduce to ASCII for max portability.
      Username_6 : constant String :=
        (if Strict
         then Preg_Replace ("|[^a-z0-9 _.\-@]|i", "", Username_5)
         else Username_5);

      Username_7 : constant String := Trim (Username_6);

      -- Consolidate contiguous whitespace.
      Username_8 : constant String := Preg_Replace ("|\s+|", " ", Username_7);
   begin
      --
      -- Filters a sanitized username string.
      --
      -- @since 2.0.1
      --
      -- @param string username     Sanitized username.
      -- @param string raw_username The username prior to sanitization.
      -- @param bool   strict       Whether to limit the sanitization to specific
      --                            characters.
      --
      return Apply_Filters ("sanitize_user", Username_8, Raw_Username, Strict);
   end Sanitize_User;

   ------------------
   -- Sanitize_Key --
   ------------------

   function Sanitize_Key (Key : String)
                          return String
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Wp_Common;

      Sanitized_Key : UString;
   begin
--    if Is_Scalar (Key) then
      Sanitized_Key := +Strtolower (Key);
      Sanitized_Key := +Preg_Replace ("/[^a-z0-9_\-]/", "", -Sanitized_Key);
--    end if;

      --
      -- Filters a sanitized key string.
      --
      -- @since 3.0.0
      --
      -- @param string sanitized_key Sanitized key.
      -- @param string key           The key prior to sanitization.
      --
      return Apply_Filters ("sanitize_key", -Sanitized_Key, Key);
   end Sanitize_Key;

   --------------------
   -- Sanitize_Title --
   --------------------

   function Sanitize_Title (Title          : String;
                            Fallback_Title : String := "";
                            Context        : String := "save")
                            return String
   is
      use Wp_Common;

      Raw_Title : constant String := Title;

      Title_2 : constant String :=
        (if "save" = Context
         then Remove_Accents (Title)
         else Title);

      --
      -- Filters a sanitized title string.
      --
      -- @since 1.2.0
      --
      -- @param string title     Sanitized title.
      -- @param string raw_title The title prior to sanitization.
      -- @param string context   The context for which the title is being sanitized.
      --
      Title_3 : constant String :=
        Apply_Filters ("sanitize_title", Title_2, Raw_Title, Context);

      Title_4 : constant String :=
        (if "" = Title_3 -- or else False = Title_3
         then Fallback_Title
         else Title_3);
   begin
      return Title_4;
   end Sanitize_Title;

   ------------------------------
   -- Sanitize_Title_For_Query --
   ------------------------------

   function Sanitize_Title_For_Query (Title : String)
                                      return String
   is
   begin
      return Sanitize_Title (Title, "", "query");
   end Sanitize_Title_For_Query;

-- --
-- -- Sanitizes a title, replacing whitespace and a few other characters with dashes.
-- --
-- -- Limits the output to alphanumeric characters, underscore (_) and dash (-).
-- -- Whitespace becomes a dash.
-- --
-- -- @since 1.2.0
-- --
-- -- @param string title     The title to be sanitized.
-- -- @param string raw_title Optional. Not used. Default empty.
-- -- @param string context   Optional. The operation for which the string is sanitized.
-- --                          When set to "save", additional entities are converted to hyphens
-- --                          or stripped entirely. Default "display".
-- -- @return string The sanitized title.
-- --
-- function sanitize_title_with_dashes( title, raw_title = "", context = "display" ) then
   function Sanitize_Title_With_Dashes (Title     : String;
                                        Raw_Title : String := "";
                                        Context   : String := "display")
                                        return String
                                        is (Title);
--         title = strip_tags( title );
--         // Preserve escaped octets.
--         title = preg_replace( "|%([a-fA-F0-9][a-fA-F0-9])|", "---1---", title );
--         // Remove percent signs that are not part of an octet.
--         title = str_replace( "%", "", title );
--         // Restore octets.
--         title = preg_replace( "|---([a-fA-F0-9][a-fA-F0-9])---|", "%1", title );

--         if ( seems_utf8( title ) ) then
--                 if ( function_exists( "mb_strtolower" ) ) then
--                         title = mb_strtolower( title, "UTF-8" );
--                 end;
--                 title = utf8_uri_encode( title, 200 );
--         end;

--         title = strtolower( title );

--         if ( "save" === context ) then
--                 // Convert &nbsp, &ndash, and &mdash to hyphens.
--                 title = str_replace( array( "%c2%a0", "%e2%80%93", "%e2%80%94" ), "-", title );
--                 // Convert &nbsp, &ndash, and &mdash HTML entities to hyphens.
--                 title = str_replace( array( "&nbsp;", "&#160;", "&ndash;", "&#8211;", "&mdash;", "&#8212;" ), "-", title );
--                 // Convert forward slash to hyphen.
--                 title = str_replace( "/", "-", title );

--                 // Strip these characters entirely.
--                 title = str_replace(
--                         array(
--                                 // Soft hyphens.
--                                 "%c2%ad",
--                                 // &iexcl and &iquest.
--                                 "%c2%a1",
--                                 "%c2%bf",
--                                 // Angle quotes.
--                                 "%c2%ab",
--                                 "%c2%bb",
--                                 "%e2%80%b9",
--                                 "%e2%80%ba",
--                                 // Curly quotes.
--                                 "%e2%80%98",
--                                 "%e2%80%99",
--                                 "%e2%80%9c",
--                                 "%e2%80%9d",
--                                 "%e2%80%9a",
--                                 "%e2%80%9b",
--                                 "%e2%80%9e",
--                                 "%e2%80%9f",
--                                 // Bullet.
--                                 "%e2%80%a2",
--                                 // &copy, &reg, &deg, &hellip, and &trade.
--                                 "%c2%a9",
--                                 "%c2%ae",
--                                 "%c2%b0",
--                                 "%e2%80%a6",
--                                 "%e2%84%a2",
--                                 // Acute accents.
--                                 "%c2%b4",
--                                 "%cb%8a",
--                                 "%cc%81",
--                                 "%cd%81",
--                                 // Grave accent, macron, caron.
--                                 "%cc%80",
--                                 "%cc%84",
--                                 "%cc%8c",
--                                 // Non-visible characters that display without a width.
--                                 "%e2%80%8b", // Zero width space.
--                                 "%e2%80%8c", // Zero width non-joiner.
--                                 "%e2%80%8d", // Zero width joiner.
--                                 "%e2%80%8e", // Left-to-right mark.
--                                 "%e2%80%8f", // Right-to-left mark.
--                                 "%e2%80%aa", // Left-to-right embedding.
--                                 "%e2%80%ab", // Right-to-left embedding.
--                                 "%e2%80%ac", // Pop directional formatting.
--                                 "%e2%80%ad", // Left-to-right override.
--                                 "%e2%80%ae", // Right-to-left override.
--                                 "%ef%bb%bf", // Byte order mark.
--                                 "%ef%bf%bc", // Object replacement character.
--                         ),
--                         "",
--                         title
--                 );

--                 // Convert non-visible characters that display with a width to hyphen.
--                 title = str_replace(
--                         array(
--                                 "%e2%80%80", // En quad.
--                                 "%e2%80%81", // Em quad.
--                                 "%e2%80%82", // En space.
--                                 "%e2%80%83", // Em space.
--                                 "%e2%80%84", // Three-per-em space.
--                                 "%e2%80%85", // Four-per-em space.
--                                 "%e2%80%86", // Six-per-em space.
--                                 "%e2%80%87", // Figure space.
--                                 "%e2%80%88", // Punctuation space.
--                                 "%e2%80%89", // Thin space.
--                                 "%e2%80%8a", // Hair space.
--                                 "%e2%80%a8", // Line separator.
--                                 "%e2%80%a9", // Paragraph separator.
--                                 "%e2%80%af", // Narrow no-break space.
--                         ),
--                         "-",
--                         title
--                 );

--                 // Convert &times to "x".
--                 title = str_replace( "%c3%97", "x", title );
--         end;

--         // Kill entities.
--         title = preg_replace( "/&.+?;/", "", title );
--         title = str_replace( ".", "-", title );

--         title = preg_replace( "/[^%a-z0-9 _-]/", "", title );
--         title = preg_replace( "/\s+/", "-", title );
--         title = preg_replace( "|-+|", "-", title );
--         title = trim( title, "-" );

--         return title;
-- end;

-- --
-- -- Ensures a string is a valid SQL "order by" clause.
-- --
-- -- Accepts one or more columns, with or without a sort order (ASC / DESC).
-- -- e.g. "column_1", "column_1, column_2", "column_1 ASC, column_2 DESC" etc.
-- --
-- -- Also accepts "RAND()".
-- --
-- -- @since 2.5.1
-- --
-- -- @param string orderby Order by clause to be validated.
-- -- @return string|false Returns orderby if valid, false otherwise.
-- --
-- function sanitize_sql_orderby( orderby ) then
--         if ( preg_match( "/^\s*(([a-z0-9_]+|`[a-z0-9_]+`)(\s+(ASC|DESC))?\s*(,\s*(?=[a-z0-9_`])|))+/i", orderby ) || preg_match( "/^\s*RAND\(\s*\)\s*/i", orderby ) ) then
--                 return orderby;
--         end;
--         return false;
-- end;

   -------------------------
   -- Sanitize_HTML_Class --
   -------------------------

   function Sanitize_HTML_Class (Class    : String;
                                 Fallback : String := "")
                                 return String
   is
      use Php.Preg;
      use Wp_Common;

      -- Strip out any %-encoded octets.
      Sanitized_1 : constant String :=
        Preg_Replace ("|%[a-fA-F0-9][a-fA-F0-9]|", "", Class);

      -- Limit to A-Z, a-z, 0-9, "_", "-".
      Sanitized : constant String :=
        Preg_Replace ("/[^A-Za-z0-9_-]/", "", Sanitized_1);
   begin
      if "" = Sanitized and Fallback /= "" then
         return Sanitize_HTML_Class (Fallback);
      end if;

      --
      -- Filters a sanitized HTML class string.
      --
      -- @since 2.8.0
      --
      -- @param string sanitized The sanitized HTML class.
      -- @param string class     HTML class before sanitization.
      -- @param string fallback  The fallback string.
      --
      return Apply_Filters ("sanitize_html_class", Sanitized, Class, Fallback);
   end Sanitize_HTML_Class;

   --------------------------
   -- Sanitize_Locale_Name --
   --------------------------

   function Sanitize_Locale_Name (Locale_Name : String)
                                  return String
   is
      use Php.Preg;
      use Wp_Common;

      -- Limit to A-Z, a-z, 0-9, "_", "-".
      Sanitized : constant String :=
        Preg_Replace ("/[^A-Za-z0-9_-]/", "", Locale_Name);
   begin
      --
      -- Filters a sanitized locale name string.
      --
      -- @since 6.2.1
      --
      -- @param string sanitized   The sanitized locale name.
      -- @param string locale_name The locale name before sanitization.
      --
      return Apply_Filters ("sanitize_locale_name", Sanitized, Locale_Name);
   end Sanitize_Locale_Name;

-- --
-- -- Converts lone & characters into `&#038;` (a.k.a. `&amp;`)
-- --
-- -- @since 0.71
-- --
-- -- @param string content    String of characters to be converted.
-- -- @param string deprecated Not used.
-- -- @return string Converted string.
-- --
-- function convert_chars( content, deprecated = "" ) then
--         if ( ! empty( deprecated ) ) then
--                 _deprecated_argument( __FUNCTION__, "0.71" );
--         end;

--         if ( strpos( content, "&" ) !== false ) then
--                 content = preg_replace( "/&([^#])(?![a-z1-4]then1,8end;;)/i", "&#038;1", content );
--         end;

--         return content;
-- end;

-- --
-- -- Converts invalid Unicode references range to valid range.
-- --
-- -- @since 4.3.0
-- --
-- -- @param string content String with entities that need converting.
-- -- @return string Converted string.
-- --
-- function convert_invalid_entities( content ) then
--         wp_htmltranswinuni = array(
--                 "&#128;" => "&#8364;", // The Euro sign.
--                 "&#129;" => "",
--                 "&#130;" => "&#8218;", // These are Windows CP1252 specific characters.
--                 "&#131;" => "&#402;",  // They would look weird on non-Windows browsers.
--                 "&#132;" => "&#8222;",
--                 "&#133;" => "&#8230;",
--                 "&#134;" => "&#8224;",
--                 "&#135;" => "&#8225;",
--                 "&#136;" => "&#710;",
--                 "&#137;" => "&#8240;",
--                 "&#138;" => "&#352;",
--                 "&#139;" => "&#8249;",
--                 "&#140;" => "&#338;",
--                 "&#141;" => "",
--                 "&#142;" => "&#381;",
--                 "&#143;" => "",
--                 "&#144;" => "",
--                 "&#145;" => "&#8216;",
--                 "&#146;" => "&#8217;",
--                 "&#147;" => "&#8220;",
--                 "&#148;" => "&#8221;",
--                 "&#149;" => "&#8226;",
--                 "&#150;" => "&#8211;",
--                 "&#151;" => "&#8212;",
--                 "&#152;" => "&#732;",
--                 "&#153;" => "&#8482;",
--                 "&#154;" => "&#353;",
--                 "&#155;" => "&#8250;",
--                 "&#156;" => "&#339;",
--                 "&#157;" => "",
--                 "&#158;" => "&#382;",
--                 "&#159;" => "&#376;",
--         );

--         if ( strpos( content, "&#1" ) !== false ) then
--                 content = strtr( content, wp_htmltranswinuni );
--         end;

--         return content;
-- end;

-- --
-- -- Balances tags if forced to, or if the "use_balanceTags" option is set to true.
-- --
-- -- @since 0.71
-- --
-- -- @param string text  Text to be balanced
-- -- @param bool   force If true, forces balancing, ignoring the value of the option. Default false.
-- -- @return string Balanced text
-- --
-- function balanceTags( text, force = false ) then  // phpcs:ignore WordPress.NamingConventions.ValidFunctionName.FunctionNameInvalid
--         if ( force || (int) get_option( "use_balanceTags" ) === 1 ) then
--                 return force_balance_tags( text );
--         end; else then
--                 return text;
--         end;
-- end;

-- --
-- -- Balances tags of string using a modified stack.
-- --
-- -- @since 2.0.4
-- -- @since 5.3.0 Improve accuracy and add support for custom element tags.
-- --
-- -- @author Leonard Lin <leonard@acm.org>
-- -- @license GPL
-- -- @copyright November 4, 2001
-- -- @version 1.1
-- -- @todo Make better - change loop condition to text in 1.2
-- -- @internal Modified by Scott Reilly (coffee2code) 02 Aug 2004
-- --      1.1  Fixed handling of append/stack pop order of end text
-- --           Added Cleaning Hooks
-- --      1.0  First Version
-- --
-- -- @param string text Text to be balanced.
-- -- @return string Balanced text.
-- --
-- function force_balance_tags( text ) then
--         tagstack  = array();
--         stacksize = 0;
--         tagqueue  = "";
--         newtext   = "";
--         // Known single-entity/self-closing tags.
--         single_tags = array( "area", "base", "basefont", "br", "col", "command", "embed", "frame", "hr", "img", "input", "isindex", "link", "meta", "param", "source", "track", "wbr" );
--         // Tags that can be immediately nested within themselves.
--         nestable_tags = array( "article", "aside", "blockquote", "details", "div", "figure", "object", "q", "section", "span" );

--         // WP bug fix for comments - in case you REALLY meant to type "< !--".
--         text = str_replace( "< !--", "<    !--", text );
--         // WP bug fix for LOVE <3 (and other situations with "<" before a number).
--         text = preg_replace( "#<([0-9]then1end;)#", "&lt;1", text );

--         --
--         -- Matches supported tags.
--         --
--         -- To get the pattern as a string without the comments paste into a PHP
--         -- REPL like `php -a`.
--         --
--         -- @see https://html.spec.whatwg.org/#elements-2
--         -- @see https://html.spec.whatwg.org/multipage/custom-elements.html#valid-custom-element-name
--         --
--         -- @example
--         -- ~# php -a
--         -- php > s = [paste copied contents of expression below including parentheses];
--         -- php > echo s;
--         --
--         tag_pattern = (
--                 "#<" . // Start with an opening bracket.
--                 "(/?)" . // Group 1 - If it"s a closing tag it"ll have a leading slash.
--                 "(" . // Group 2 - Tag name.
--                         // Custom element tags have more lenient rules than HTML tag names.
--                         "(?:[a-z](?:[a-z0-9._]*)-(?:[a-z0-9._-]+)+)" .
--                                 "|" .
--                         // Traditional tag rules approximate HTML tag names.
--                         "(?:[\w:]+)" .
--                 ")" .
--                 "(?:" .
--                         // We either immediately close the tag with its ">" and have nothing here.
--                         "\s*" .
--                         "(/?)" . // Group 3 - "attributes" for empty tag.
--                                 "|" .
--                         // Or we must start with space characters to separate the tag name from the attributes (or whitespace).
--                         "(\s+)" . // Group 4 - Pre-attribute whitespace.
--                         "([^>]*)" . // Group 5 - Attributes.
--                 ")" .
--                 ">#" // End with a closing bracket.
--         );

--         while ( preg_match( tag_pattern, text, regex ) ) then
--                 full_match        = regex[0];
--                 has_leading_slash = ! empty( regex[1] );
--                 tag_name          = regex[2];
--                 tag               = strtolower( tag_name );
--                 is_single_tag     = in_array( tag, single_tags, true );
--                 pre_attribute_ws  = isset( regex[4] ) ? regex[4] : "";
--                 attributes        = trim( isset( regex[5] ) ? regex[5] : regex[3] );
--                 has_self_closer   = "/" === substr( attributes, -1 );

--                 newtext .= tagqueue;

--                 i = strpos( text, full_match );
--                 l = strlen( full_match );

--                 // Clear the shifter.
--                 tagqueue = "";
--                 if ( has_leading_slash ) then // End tag.
--                         // If too many closing tags.
--                         if ( stacksize <= 0 ) then
--                                 tag = "";
--                                 // Or close to be safe tag = "/" . tag.

--                                 // If stacktop value = tag close value, then pop.
--                         end; elseif ( tagstack[ stacksize - 1 ] === tag ) then // Found closing tag.
--                                 tag = "</" . tag . ">"; // Close tag.
--                                 array_pop( tagstack );
--                                 stacksize--;
--                         end; else then // Closing tag not at top, search for it.
--                                 for ( j = stacksize - 1; j >= 0; j-- ) then
--                                         if ( tagstack[ j ] === tag ) then
--                                                 // Add tag to tagqueue.
--                                                 for ( k = stacksize - 1; k >= j; k-- ) then
--                                                         tagqueue .= "</" . array_pop( tagstack ) . ">";
--                                                         stacksize--;
--                                                 end;
--                                                 break;
--                                         end;
--                                 end;
--                                 tag = "";
--                         end;
--                 end; else then // Begin tag.
--                         if ( has_self_closer ) then // If it presents itself as a self-closing tag...
--                                 // ...but it isn"t a known single-entity self-closing tag, then don"t let it be treated as such
--                                 // and immediately close it with a closing tag (the tag will encapsulate no text as a result).
--                                 if ( ! is_single_tag ) then
--                                         attributes = trim( substr( attributes, 0, -1 ) ) . "></tag";
--                                 end;
--                         end; elseif ( is_single_tag ) then // Else if it"s a known single-entity tag but it doesn"t close itself, do so.
--                                 pre_attribute_ws = " ";
--                                 attributes      .= "/";
--                         end; else then // It"s not a single-entity tag.
--                                 // If the top of the stack is the same as the tag we want to push, close previous tag.
--                                 if ( stacksize > 0 && ! in_array( tag, nestable_tags, true ) && tagstack[ stacksize - 1 ] === tag ) then
--                                         tagqueue = "</" . array_pop( tagstack ) . ">";
--                                         stacksize--;
--                                 end;
--                                 stacksize = array_push( tagstack, tag );
--                         end;

--                         // Attributes.
--                         if ( has_self_closer && is_single_tag ) then
--                                 // We need some space - avoid <br/> and prefer <br />.
--                                 pre_attribute_ws = " ";
--                         end;

--                         tag = "<" . tag . pre_attribute_ws . attributes . ">";
--                         // If already queuing a close tag, then put this tag on too.
--                         if ( ! empty( tagqueue ) ) then
--                                 tagqueue .= tag;
--                                 tag       = "";
--                         end;
--                 end;
--                 newtext .= substr( text, 0, i ) . tag;
--                 text     = substr( text, i + l );
--         end;

--         // Clear tag queue.
--         newtext .= tagqueue;

--         // Add remaining text.
--         newtext .= text;

--         while ( x = array_pop( tagstack ) ) then
--                 newtext .= "</" . x . ">"; // Add remaining tags to close.
--         end;

--         // WP fix for the bug with HTML comments.
--         newtext = str_replace( "< !--", "<!--", newtext );
--         newtext = str_replace( "<    !--", "< !--", newtext );

--         return newtext;
-- end;

-- --
-- -- Acts on text which is about to be edited.
-- --
-- -- The content is run through esc_textarea(), which uses htmlspecialchars()
-- -- to convert special characters to HTML entities. If `richedit` is set to true,
-- -- it is simply a holder for the {@see "format_to_edit"} filter.
-- --
-- -- @since 0.71
-- -- @since 4.4.0 The `richedit` parameter was renamed to `rich_text` for clarity.
-- --
-- -- @param string content   The text about to be edited.
-- -- @param bool   rich_text Optional. Whether `content` should be considered rich text,
-- --                          in which case it would not be passed through esc_textarea().
-- --                          Default false.
-- -- @return string The text after the filter (and possibly htmlspecialchars()) has been run.
-- --
-- function format_to_edit( content, rich_text = false ) then
--         --
--         -- Filters the text to be formatted for editing.
--         --
--         -- @since 1.2.0
--         --
--         -- @param string content The text, prior to formatting for editing.
--         --
--         content = apply_filters( "format_to_edit", content );
--         if ( ! rich_text ) then
--                 content = esc_textarea( content );
--         end;
--         return content;
-- end;

-- --
-- -- Add leading zeros when necessary.
-- --
-- -- If you set the threshold to "4" and the number is "10", then you will get
-- -- back "0010". If you set the threshold to "4" and the number is "5000", then you
-- -- will get back "5000".
-- --
-- -- Uses sprintf to append the amount of zeros based on the threshold parameter
-- -- and the size of the number. If the number is large enough, then no zeros will
-- -- be appended.
-- --
-- -- @since 0.71
-- --
-- -- @param int number     Number to append zeros to if not greater than threshold.
-- -- @param int threshold  Digit places number needs to be to not have zeros added.
-- -- @return string Adds leading zeros to number if needed.
-- --
-- function zeroise( number, threshold ) then
--         return sprintf( "%0" . threshold . "s", number );
-- end;

-- --
-- -- Adds backslashes before letters and before a number at the start of a string.
-- --
-- -- @since 0.71
-- --
-- -- @param string string Value to which backslashes will be added.
-- -- @return string String with backslashes inserted.
-- --
-- function backslashit( string ) then
--         if ( isset( string[0] ) && string[0] >= "0" && string[0] <= "9" ) then
--                 string = "\\\\" . string;
--         end;
--         return addcslashes( string, "A..Za..z" );
-- end;

   -----------------------
   -- Trailing_Slash_It --
   -----------------------

   function Trailing_Slash_It (Item : String)
                               return String
   is
   begin
      return Un_Trailing_Slash_It (Item) & "/";
   end Trailing_Slash_It;

   --------------------------
   -- Un_Trailing_Slash_It --
   --------------------------

   function Un_Trailing_Slash_It (Item : String)
                                  return String
   is
      use Php.Strings;
   begin
      return Rtrim (Item, "/\\");
   end Un_Trailing_Slash_It;

-- --
-- -- Adds slashes to a string or recursively adds slashes to strings within an array.
-- --
-- -- @since 0.71
-- --
-- -- @param string|array gpc String or array of data to slash.
-- -- @return string|array Slashed `gpc`.
-- --
-- function addslashes_gpc( gpc ) then
--         return wp_slash( gpc );
-- end;

   ------------------------
   -- Strip_Slashes_Deep --
   ------------------------

   function Strip_Slashes_Deep (Value : Array_Type)
                                return Array_Type
   is
   begin
      return Map_Deep (Value, Strip_Slashes_From_Strings_Only'Access);
   end Strip_Slashes_Deep;

   ------------------------
   -- Strip_Slashes_Deep --
   ------------------------

   function Strip_Slashes_Deep (Value : String)
                                return String
   is
   begin
      return Map_Deep (Value, Strip_Slashes_From_Strings_Only'Access);
   end Strip_Slashes_Deep;

   -------------------------------------
   -- Strip_Slashes_From_Strings_Only --
   -------------------------------------

   function Strip_Slashes_From_Strings_Only (Value : String)
                                             return String
   is
      use Php.Strings;
      use Php.Types;
   begin
      return
        (if Is_String (Value)
         then Strip_Slashes (Value)
         else Value);
   end Strip_Slashes_From_Strings_Only;

   ---------------------
   -- URL_Encode_Deep --
   ---------------------

   function URL_Encode_Deep (Value : Array_Type)
                             return Array_Type
   is
   begin
      return Map_Deep (Value, Php.HTML.URL_Encode'Access);
   end URL_Encode_Deep;

   ---------------------
   -- URL_Encode_Deep --
   ---------------------

   function URL_Encode_Deep (Value : String)
                             return String
   is
   begin
      return Map_Deep (Value, Php.HTML.URL_Encode'Access);
   end URL_Encode_Deep;

   -------------------------
   -- Raw_URL_Encode_Deep --
   -------------------------

   function Raw_URL_Encode_Deep (Value : Array_Type)
                                 return Array_Type
   is
      use Php.HTML;
   begin
      return Map_Deep (Value, Raw_URL_Encode'Access);
   end Raw_URL_Encode_Deep;

-- --
-- -- Navigates through an array, object, or scalar, and decodes URL-encoded values
-- --
-- -- @since 4.4.0
-- --
-- -- @param mixed value The array or string to be decoded.
-- -- @return mixed The decoded value.
-- --
-- function urldecode_deep( value ) then
--         return map_deep( value, "urldecode" );
-- end;

-- --
-- -- Converts email addresses characters to HTML entities to block spam bots.
-- --
-- -- @since 0.71
-- --
-- -- @param string email_address Email address.
-- -- @param int    hex_encoding  Optional. Set to 1 to enable hex encoding.
-- -- @return string Converted email address.
-- --
-- function antispambot( email_address, hex_encoding = 0 ) then
--         email_no_spam_address = "";
--         for ( i = 0, len = strlen( email_address ); i < len; i++ ) then
--                 j = rand( 0, 1 + hex_encoding );
--                 if ( 0 == j ) then
--                         email_no_spam_address .= "&#" . ord( email_address[ i ] ) . ";";
--                 end; elseif ( 1 == j ) then
--                         email_no_spam_address .= email_address[ i ];
--                 end; elseif ( 2 == j ) then
--                         email_no_spam_address .= "%" . zeroise( dechex( ord( email_address[ i ] ) ), 2 );
--                 end;
--         end;

--         return str_replace( "@", "&#64;", email_no_spam_address );
-- end;

-- --
-- -- Callback to convert URI match to HTML A element.
-- --
-- -- This function was backported from 2.5.0 to 2.3.2. Regex callback for make_clickable().
-- --
-- -- @since 2.3.2
-- -- @access private
-- --
-- -- @param array matches Single Regex Match.
-- -- @return string HTML A element with URI address.
-- --
-- function _make_url_clickable_cb( matches ) then
--         url = matches[2];

--         if ( ")" === matches[3] && strpos( url, "(" ) ) then
--                 // If the trailing character is a closing parethesis, and the URL has an opening parenthesis in it,
--                 // add the closing parenthesis to the URL. Then we can let the parenthesis balancer do its thing below.
--                 url   .= matches[3];
--                 suffix = "";
--         end; else then
--                 suffix = matches[3];
--         end;

--         // Include parentheses in the URL only if paired.
--         while ( substr_count( url, "(" ) < substr_count( url, ")" ) ) then
--                 suffix = strrchr( url, ")" ) . suffix;
--                 url    = substr( url, 0, strrpos( url, ")" ) );
--         end;

--         url = esc_url( url );
--         if ( empty( url ) ) then
--                 return matches[0];
--         end;

--         if ( "comment_text" === current_filter() ) then
--                 rel = "nofollow ugc";
--         end; else then
--                 rel = "nofollow";
--         end;

--         --
--         -- Filters the rel value that is added to URL matches converted to links.
--         --
--         -- @since 5.3.0
--         --
--         -- @param string rel The rel value.
--         -- @param string url The matched URL being converted to a link tag.
--         --
--         rel = apply_filters( "make_clickable_rel", rel, url );
--         rel = esc_attr( rel );

--         return matches[1] . "<a href=\"url\" rel=\"rel\">url</a>" . suffix;
-- end;

-- --
-- -- Callback to convert URL match to HTML A element.
-- --
-- -- This function was backported from 2.5.0 to 2.3.2. Regex callback for make_clickable().
-- --
-- -- @since 2.3.2
-- -- @access private
-- --
-- -- @param array matches Single Regex Match.
-- -- @return string HTML A element with URL address.
-- --
-- function _make_web_ftp_clickable_cb( matches ) then
--         ret  = "";
--         dest = matches[2];
--         dest = "http://" . dest;

--         // Removed trailing [.,;:)] from URL.
--         last_char = substr( dest, -1 );
--         if ( in_array( last_char, array( ".", ",", ";", ":", ")" ), true ) === true ) then
--                 ret  = last_char;
--                 dest = substr( dest, 0, strlen( dest ) - 1 );
--         end;

--         dest = esc_url( dest );
--         if ( empty( dest ) ) then
--                 return matches[0];
--         end;

--         if ( "comment_text" === current_filter() ) then
--                 rel = "nofollow ugc";
--         end; else then
--                 rel = "nofollow";
--         end;

--         -- This filter is documented in wp-includes/formatting.php--
--         rel = apply_filters( "make_clickable_rel", rel, dest );
--         rel = esc_attr( rel );

--         return matches[1] . "<a href=\"dest\" rel=\"rel\">dest</a>ret";
-- end;

-- --
-- -- Callback to convert email address match to HTML A element.
-- --
-- -- This function was backported from 2.5.0 to 2.3.2. Regex callback for make_clickable().
-- --
-- -- @since 2.3.2
-- -- @access private
-- --
-- -- @param array matches Single Regex Match.
-- -- @return string HTML A element with email address.
-- --
-- function _make_email_clickable_cb( matches ) then
--         email = matches[2] . "@" . matches[3];
--         return matches[1] . "<a href=\"mailto:email\">email</a>";
-- end;

-- --
-- -- Converts plaintext URI to HTML links.
-- --
-- -- Converts URI, www and ftp, and email addresses. Finishes by fixing links
-- -- within links.
-- --
-- -- @since 0.71
-- --
-- -- @param string text Content to convert URIs.
-- -- @return string Content with converted URIs.
-- --
-- function make_clickable( text ) then
--         r               = "";
--         textarr         = preg_split( "/(<[^<>]+>)/", text, -1, PREG_SPLIT_DELIM_CAPTURE ); // Split out HTML tags.
--         nested_code_pre = 0; // Keep track of how many levels link is nested inside <pre> or <code>.
--         foreach ( textarr as piece ) then

--                 if ( preg_match( "|^<code[\s>]|i", piece ) || preg_match( "|^<pre[\s>]|i", piece ) || preg_match( "|^<script[\s>]|i", piece ) || preg_match( "|^<style[\s>]|i", piece ) ) then
--                         nested_code_pre++;
--                 end; elseif ( nested_code_pre && ( "</code>" === strtolower( piece ) || "</pre>" === strtolower( piece ) || "</script>" === strtolower( piece ) || "</style>" === strtolower( piece ) ) ) then
--                         nested_code_pre--;
--                 end;

--                 if ( nested_code_pre || empty( piece ) || ( "<" === piece[0] && ! preg_match( "|^<\s*[\w]then1,20end;+://|", piece ) ) ) then
--                         r .= piece;
--                         continue;
--                 end;

--                 // Long strings might contain expensive edge cases...
--                 if ( 10000 < strlen( piece ) ) then
--                         // ...break it up.
--                         foreach ( _split_str_by_whitespace( piece, 2100 ) as chunk ) then // 2100: Extra room for scheme and leading and trailing paretheses.
--                                 if ( 2101 < strlen( chunk ) ) then
--                                         r .= chunk; // Too big, no whitespace: bail.
--                                 end; else then
--                                         r .= make_clickable( chunk );
--                                 end;
--                         end;
--                 end; else then
--                         ret = " piece "; // Pad with whitespace to simplify the regexes.

--                         url_clickable = "~
--                                 ([\\s(<.,;:!?])                                # 1: Leading whitespace, or punctuation.
--                                 (                                              # 2: URL.
--                                         [\\w]then1,20end;+://                                # Scheme and hier-part prefix.
--                                         (?=\Sthen1,2000end;\s)                               # Limit to URLs less than about 2000 characters long.
--                                         [\\w\\x80-\\xff#%\\~/@\\[\\]*(+=&-]*+         # Non-punctuation URL character.
--                                         (?:                                            # Unroll the Loop: Only allow puctuation URL character if followed by a non-punctuation URL character.
--                                                 [\".,;:!?)]                                    # Punctuation URL character.
--                                                 [\\w\\x80-\\xff#%\\~/@\\[\\]*(+=&-]++         # Non-punctuation URL character.
--                                         )*
--                                 )
--                                 (\)?)                                          # 3: Trailing closing parenthesis (for parethesis balancing post processing).
--                         ~xS";
--                         // The regex is a non-anchored pattern and does not have a single fixed starting character.
--                         // Tell PCRE to spend more time optimizing since, when used on a page load, it will probably be used several times.

--                         ret = preg_replace_callback( url_clickable, "_make_url_clickable_cb", ret );

--                         ret = preg_replace_callback( "#([\s>])((www|ftp)\.[\w\\x80-\\xff\#%&~/.\-;:=,?@\[\]+]+)#is", "_make_web_ftp_clickable_cb", ret );
--                         ret = preg_replace_callback( "#([\s>])([.0-9a-z_+-]+)@(([0-9a-z-]+\.)+[0-9a-z]then2,end;)#i", "_make_email_clickable_cb", ret );

--                         ret = substr( ret, 1, -1 ); // Remove our whitespace padding.
--                         r  .= ret;
--                 end;
--         end;

--         // Cleanup of accidental links within links.
--         return preg_replace( "#(<a([ \r\n\t]+[^>]+?>|>))<a [^>]+?>([^>]+?)</a></a>#i", "13</a>", r );
-- end;

-- --
-- -- Breaks a string into chunks by splitting at whitespace characters.
-- --
-- -- The length of each returned chunk is as close to the specified length goal as possible,
-- -- with the caveat that each chunk includes its trailing delimiter.
-- -- Chunks longer than the goal are guaranteed to not have any inner whitespace.
-- --
-- -- Joining the returned chunks with empty delimiters reconstructs the input string losslessly.
-- --
-- -- Input string must have no null characters (or eventual transformations on output chunks must not care about null characters)
-- --
-- --     _split_str_by_whitespace( "1234 67890 1234 67890a cd 1234   890 123456789 1234567890a    45678   1 3 5 7 90 ", 10 ) ==
-- --     array (
-- --         0 => "1234 67890 ",  // 11 characters: Perfect split.
-- --         1 => "1234 ",        //  5 characters: "1234 67890a" was too long.
-- --         2 => "67890a cd ",   // 10 characters: "67890a cd 1234" was too long.
-- --         3 => "1234   890 ",  // 11 characters: Perfect split.
-- --         4 => "123456789 ",   // 10 characters: "123456789 1234567890a" was too long.
-- --         5 => "1234567890a ", // 12 characters: Too long, but no inner whitespace on which to split.
-- --         6 => "   45678   ",  // 11 characters: Perfect split.
-- --         7 => "1 3 5 7 90 ",  // 11 characters: End of string.
-- --     );
-- --
-- -- @since 3.4.0
-- -- @access private
-- --
-- -- @param string string The string to split.
-- -- @param int    goal   The desired chunk length.
-- -- @return array Numeric array of chunks.
-- --
-- function _split_str_by_whitespace( string, goal ) then
--         chunks = array();

--         string_nullspace = strtr( string, "\r\n\t\v\f ", "\000\000\000\000\000\000" );

--         while ( goal < strlen( string_nullspace ) ) then
--                 pos = strrpos( substr( string_nullspace, 0, goal + 1 ), "\000" );

--                 if ( false === pos ) then
--                         pos = strpos( string_nullspace, "\000", goal + 1 );
--                         if ( false === pos ) then
--                                 break;
--                         end;
--                 end;

--                 chunks[]         = substr( string, 0, pos + 1 );
--                 string           = substr( string, pos + 1 );
--                 string_nullspace = substr( string_nullspace, pos + 1 );
--         end;

--         if ( string ) then
--                 chunks[] = string;
--         end;

--         return chunks;
-- end;

-- --
-- -- Callback to add a rel attribute to HTML A element.
-- --
-- -- Will remove already existing string before adding to prevent invalidating (X)HTML.
-- --
-- -- @since 5.3.0
-- --
-- -- @param array  matches Single match.
-- -- @param string rel     The rel attribute to add.
-- -- @return string HTML A element with the added rel attribute.
-- --
-- function wp_rel_callback( matches, rel ) then
--         text = matches[1];
--         atts = wp_kses_hair( matches[1], wp_allowed_protocols() );

--         if ( ! empty( atts["href"] ) ) then
--                 if ( in_array( strtolower( wp_parse_url( atts["href"]["value"], PHP_URL_SCHEME ) ), array( "http", "https" ), true ) ) then
--                         if ( strtolower( wp_parse_url( atts["href"]["value"], PHP_URL_HOST ) ) === strtolower( wp_parse_url( home_url(), PHP_URL_HOST ) ) ) then
--                                 return "<a text>";
--                         end;
--                 end;
--         end;

--         if ( ! empty( atts["rel"] ) ) then
--                 parts     = array_map( "trim", explode( " ", atts["rel"]["value"] ) );
--                 rel_array = array_map( "trim", explode( " ", rel ) );
--                 parts     = array_unique( array_merge( parts, rel_array ) );
--                 rel       = implode( " ", parts );
--                 unset( atts["rel"] );

--                 html = "";
--                 foreach ( atts as name => value ) then
--                         if ( isset( value["vless"] ) && "y" === value["vless"] ) then
--                                 html .= name . " ";
--                         end; else then
--                                 html .= "thennameend;=\"" . esc_attr( value["value"] ) . "" ";
--                         end;
--                 end;
--                 text = trim( html );
--         end;
--         return "<a text rel=\"" . esc_attr( rel ) . "">";
-- end;

-- --
-- -- Adds `rel="nofollow"` string to all HTML A elements in content.
-- --
-- -- @since 1.5.0
-- --
-- -- @param string text Content that may contain HTML A elements.
-- -- @return string Converted content.
-- --
-- function wp_rel_nofollow( text ) then
--         // This is a pre-save filter, so text is already escaped.
--         text = stripslashes( text );
--         text = preg_replace_callback(
--                 "|<a (.+?)>|i",
--                 static function( matches ) then
--                         return wp_rel_callback( matches, "nofollow" );
--                 end;,
--                 text
--         );
--         return wp_slash( text );
-- end;

-- --
-- -- Callback to add `rel="nofollow"` string to HTML A element.
-- --
-- -- @since 2.3.0
-- -- @deprecated 5.3.0 Use wp_rel_callback()
-- --
-- -- @param array matches Single match.
-- -- @return string HTML A Element with `rel="nofollow"`.
-- --
-- function wp_rel_nofollow_callback( matches ) then
--         return wp_rel_callback( matches, "nofollow" );
-- end;

-- --
-- -- Adds `rel="nofollow ugc"` string to all HTML A elements in content.
-- --
-- -- @since 5.3.0
-- --
-- -- @param string text Content that may contain HTML A elements.
-- -- @return string Converted content.
-- --
-- function wp_rel_ugc( text ) then
--         // This is a pre-save filter, so text is already escaped.
--         text = stripslashes( text );
--         text = preg_replace_callback(
--                 "|<a (.+?)>|i",
--                 static function( matches ) then
--                         return wp_rel_callback( matches, "nofollow ugc" );
--                 end;,
--                 text
--         );
--         return wp_slash( text );
-- end;

-- --
-- -- Adds `rel="noopener"` to all HTML A elements that have a target.
-- --
-- -- @since 5.1.0
-- -- @since 5.6.0 Removed "noreferrer" relationship.
-- --
-- -- @param string text Content that may contain HTML A elements.
-- -- @return string Converted content.
-- --
-- function wp_targeted_link_rel( text ) then
--         // Don"t run (more expensive) regex if no links with targets.
--         if ( stripos( text, "target" ) === false || stripos( text, "<a " ) === false || is_serialized( text ) ) then
--                 return text;
--         end;

--         script_and_style_regex = "/<(script|style).*?<\/\\1>/si";

--         preg_match_all( script_and_style_regex, text, matches );
--         extra_parts = matches[0];
--         html_parts  = preg_split( script_and_style_regex, text );

--         foreach ( html_parts as &part ) then
--                 part = preg_replace_callback( "|<a\s([^>]*target\s*=[^>]*)>|i", "wp_targeted_link_rel_callback", part );
--         end;

--         text = "";
--         for ( i = 0; i < count( html_parts ); i++ ) then
--                 text .= html_parts[ i ];
--                 if ( isset( extra_parts[ i ] ) ) then
--                         text .= extra_parts[ i ];
--                 end;
--         end;

--         return text;
-- end;

-- --
-- -- Callback to add `rel="noopener"` string to HTML A element.
-- --
-- -- Will not duplicate an existing "noopener" value to avoid invalidating the HTML.
-- --
-- -- @since 5.1.0
-- -- @since 5.6.0 Removed "noreferrer" relationship.
-- --
-- -- @param array matches Single match.
-- -- @return string HTML A Element with `rel="noopener"` in addition to any existing values.
-- --
-- function wp_targeted_link_rel_callback( matches ) then
--         link_html          = matches[1];
--         original_link_html = link_html;

--         // Consider the HTML escaped if there are no unescaped quotes.
--         is_escaped = ! preg_match( "/(^|[^\\\\])[\""]/", link_html );
--         if ( is_escaped ) then
--                 // Replace only the quotes so that they are parsable by wp_kses_hair(), leave the rest as is.
--                 link_html = preg_replace( "/\\\\([\""])/", "1", link_html );
--         end;

--         atts = wp_kses_hair( link_html, wp_allowed_protocols() );

--         --
--         -- Filters the rel values that are added to links with `target` attribute.
--         --
--         -- @since 5.1.0
--         --
--         -- @param string rel       The rel values.
--         -- @param string link_html The matched content of the link tag including all HTML attributes.
--         --
--         rel = apply_filters( "wp_targeted_link_rel", "noopener", link_html );

--         // Return early if no rel values to be added or if no actual target attribute.
--         if ( ! rel || ! isset( atts["target"] ) ) then
--                 return "<a original_link_html>";
--         end;

--         if ( isset( atts["rel"] ) ) then
--                 all_parts = preg_split( "/\s/", "thenatts["rel"]["value"]end; rel", -1, PREG_SPLIT_NO_EMPTY );
--                 rel       = implode( " ", array_unique( all_parts ) );
--         end;

--         atts["rel"]["whole"] = "rel="" . esc_attr( rel ) . """;
--         link_html            = implode( " ", array_column( atts, "whole" ) );

--         if ( is_escaped ) then
--                 link_html = preg_replace( "/[\""]/", "\\\\0", link_html );
--         end;

--         return "<a link_html>";
-- end;

-- --
-- -- Adds all filters modifying the rel attribute of targeted links.
-- --
-- -- @since 5.1.0
-- --
-- function wp_init_targeted_link_rel_filters() then
--         filters = array(
--                 "title_save_pre",
--                 "content_save_pre",
--                 "excerpt_save_pre",
--                 "content_filtered_save_pre",
--                 "pre_comment_content",
--                 "pre_term_description",
--                 "pre_link_description",
--                 "pre_link_notes",
--                 "pre_user_description",
--         );

--         foreach ( filters as filter ) then
--                 add_filter( filter, "wp_targeted_link_rel" );
--         end;
-- end;

-- --
-- -- Removes all filters modifying the rel attribute of targeted links.
-- --
-- -- @since 5.1.0
-- --
-- function wp_remove_targeted_link_rel_filters() then
--         filters = array(
--                 "title_save_pre",
--                 "content_save_pre",
--                 "excerpt_save_pre",
--                 "content_filtered_save_pre",
--                 "pre_comment_content",
--                 "pre_term_description",
--                 "pre_link_description",
--                 "pre_link_notes",
--                 "pre_user_description",
--         );

--         foreach ( filters as filter ) then
--                 remove_filter( filter, "wp_targeted_link_rel" );
--         end;
-- end;

-- --
-- -- Converts one smiley code to the icon graphic file equivalent.
-- --
-- -- Callback handler for convert_smilies().
-- --
-- -- Looks up one smiley code in the wpsmiliestrans global array and returns an
-- -- `<img>` string for that smiley.
-- --
-- -- @since 2.8.0
-- --
-- -- @global array wpsmiliestrans
-- --
-- -- @param array matches Single match. Smiley code to convert to image.
-- -- @return string Image string for smiley.
-- --
-- function translate_smiley( matches ) then
--         global wpsmiliestrans;

--         if ( count( matches ) == 0 ) then
--                 return "";
--         end;

--         smiley = trim( reset( matches ) );
--         img    = wpsmiliestrans[ smiley ];

--         matches    = array();
--         ext        = preg_match( "/\.([^.]+)/", img, matches ) ? strtolower( matches[1] ) : false;
--         image_exts = array( "jpg", "jpeg", "jpe", "gif", "png", "webp" );

--         // Don"t convert smilies that aren"t images - they"re probably emoji.
--         if ( ! in_array( ext, image_exts, true ) ) then
--                 return img;
--         end;

--         --
--         -- Filters the Smiley image URL before it"s used in the image element.
--         --
--         -- @since 2.9.0
--         --
--         -- @param string smiley_url URL for the smiley image.
--         -- @param string img        Filename for the smiley image.
--         -- @param string site_url   Site URL, as returned by site_url().
--         --
--         src_url = apply_filters( "smilies_src", includes_url( "images/smilies/img" ), img, site_url() );

--         return sprintf( "<img src="%s" alt="%s" class="wp-smiley" style="height: 1em; max-height: 1em;" />", esc_url( src_url ), esc_attr( smiley ) );
-- end;

-- --
-- -- Converts text equivalent of smilies to images.
-- --
-- -- Will only convert smilies if the option "use_smilies" is true and the global
-- -- used in the function isn"t empty.
-- --
-- -- @since 0.71
-- --
-- -- @global string|array wp_smiliessearch
-- --
-- -- @param string text Content to convert smilies from text.
-- -- @return string Converted content with text smilies replaced with images.
-- --
-- function convert_smilies( text ) then
--         global wp_smiliessearch;
--         output = "";
--         if ( get_option( "use_smilies" ) && ! empty( wp_smiliessearch ) ) then
--                 // HTML loop taken from texturize function, could possible be consolidated.
--                 textarr = preg_split( "/(<.*>)/U", text, -1, PREG_SPLIT_DELIM_CAPTURE ); // Capture the tags as well as in between.
--                 stop    = count( textarr ); // Loop stuff.

--                 // Ignore proessing of specific tags.
--                 tags_to_ignore       = "code|pre|style|script|textarea";
--                 ignore_block_element = "";

--                 for ( i = 0; i < stop; i++ ) then
--                         content = textarr[ i ];

--                         // If we"re in an ignore block, wait until we find its closing tag.
--                         if ( "" === ignore_block_element && preg_match( "/^<(" . tags_to_ignore . ")[^>]*>/", content, matches ) ) then
--                                 ignore_block_element = matches[1];
--                         end;

--                         // If it"s not a tag and not in ignore block.
--                         if ( "" === ignore_block_element && strlen( content ) > 0 && "<" !== content[0] ) then
--                                 content = preg_replace_callback( wp_smiliessearch, "translate_smiley", content );
--                         end;

--                         // Did we exit ignore block?
--                         if ( "" !== ignore_block_element && "</" . ignore_block_element . ">" === content ) then
--                                 ignore_block_element = "";
--                         end;

--                         output .= content;
--                 end;
--         end; else then
--                 // Return default text.
--                 output = text;
--         end;
--         return output;
-- end;

   --------------
   -- Is_Email --
   --------------

   function Is_Email (Email      : String;
                      Deprecated : Boolean := False)
                      return String
                      is (raise Program_Error with "not implemented");
--         if ( ! empty( deprecated ) ) then
--                 _deprecated_argument( __FUNCTION__, "3.0.0" );
--         end;

--         // Test for the minimum length the email can be.
--         if ( strlen( email ) < 6 ) then
--                 --
--                 -- Filters whether an email address is valid.
--                 --
--                 -- This filter is evaluated under several different contexts, such as "email_too_short",
--                 -- "email_no_at", "local_invalid_chars", "domain_period_sequence", "domain_period_limits",
--                 -- "domain_no_periods", "sub_hyphen_limits", "sub_invalid_chars", or no specific context.
--                 --
--                 -- @since 2.8.0
--                 --
--                 -- @param string|false is_email The email address if successfully passed the is_email() checks, false otherwise.
--                 -- @param string       email    The email address being checked.
--                 -- @param string       context  Context under which the email was tested.
--                 --
--                 return apply_filters( "is_email", false, email, "email_too_short" );
--         end;

--         // Test for an @ character after the first position.
--         if ( strpos( email, "@", 1 ) === false ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "is_email", false, email, "email_no_at" );
--         end;

--         // Split out the local and domain parts.
--         list( local, domain ) = explode( "@", email, 2 );

--         // LOCAL PART
--         // Test for invalid characters.
--         if ( ! preg_match( "/^[a-zA-Z0-9!#%&\"*+\/=?^_`then|end;~\.-]+/", local ) ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "is_email", false, email, "local_invalid_chars" );
--         end;

--         // DOMAIN PART
--         // Test for sequences of periods.
--         if ( preg_match( "/\.then2,end;/", domain ) ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "is_email", false, email, "domain_period_sequence" );
--         end;

--         // Test for leading and trailing periods and whitespace.
--         if ( trim( domain, " \t\n\r\0\x0B." ) !== domain ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "is_email", false, email, "domain_period_limits" );
--         end;

--         // Split the domain into subs.
--         subs = explode( ".", domain );

--         // Assume the domain will have at least two subs.
--         if ( 2 > count( subs ) ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "is_email", false, email, "domain_no_periods" );
--         end;

--         // Loop through each sub.
--         foreach ( subs as sub ) then
--                 // Test for leading and trailing hyphens and whitespace.
--                 if ( trim( sub, " \t\n\r\0\x0B-" ) !== sub ) then
--                         -- This filter is documented in wp-includes/formatting.php--
--                         return apply_filters( "is_email", false, email, "sub_hyphen_limits" );
--                 end;

--                 // Test for invalid characters.
--                 if ( ! preg_match( "/^[a-z0-9-]+/i", sub ) ) then
--                         -- This filter is documented in wp-includes/formatting.php--
--                         return apply_filters( "is_email", false, email, "sub_invalid_chars" );
--                 end;
--         end;

--         // Congratulations, your email made it!
--         -- This filter is documented in wp-includes/formatting.php--
--         return apply_filters( "is_email", email, email, null );
-- end;

-- --
-- -- Converts to ASCII from email subjects.
-- --
-- -- @since 1.2.0
-- --
-- -- @param string string Subject line.
-- -- @return string Converted string to ASCII.
-- --
-- function wp_iso_descrambler( string ) then
--         /* this may only work with iso-8859-1, I"m afraid--
--         if ( ! preg_match( "#\=\?(.+)\?Q\?(.+)\?\=#i", string, matches ) ) then
--                 return string;
--         end; else then
--                 subject = str_replace( "_", " ", matches[2] );
--                 return preg_replace_callback( "#\=([0-9a-f]then2end;)#i", "_wp_iso_convert", subject );
--         end;
-- end;

-- --
-- -- Helper function to convert hex encoded chars to ASCII.
-- --
-- -- @since 3.1.0
-- -- @access private
-- --
-- -- @param array match The preg_replace_callback matches array.
-- -- @return string Converted chars.
-- --
-- function _wp_iso_convert( match ) then
--         return chr( hexdec( strtolower( match[1] ) ) );
-- end;

-- --
-- -- Given a date in the timezone of the site, returns that date in UTC.
-- --
-- -- Requires and returns a date in the Y-m-d H:i:s format.
-- -- Return format can be overridden using the format parameter.
-- --
-- -- @since 1.2.0
-- --
-- -- @param string string The date to be converted, in the timezone of the site.
-- -- @param string format The format string for the returned date. Default "Y-m-d H:i:s".
-- -- @return string Formatted version of the date, in UTC.
-- --
-- function get_gmt_from_date( string, format = "Y-m-d H:i:s" ) then
--         datetime = date_create( string, wp_timezone() );

--         if ( false === datetime ) then
--                 return gmdate( format, 0 );
--         end;

--         return datetime->setTimezone( new DateTimeZone( "UTC" ) )->format( format );
-- end;

-- --
-- -- Given a date in UTC or GMT timezone, returns that date in the timezone of the site.
-- --
-- -- Requires a date in the Y-m-d H:i:s format.
-- -- Default return format of "Y-m-d H:i:s" can be overridden using the `format` parameter.
-- --
-- -- @since 1.2.0
-- --
-- -- @param string string The date to be converted, in UTC or GMT timezone.
-- -- @param string format The format string for the returned date. Default "Y-m-d H:i:s".
-- -- @return string Formatted version of the date, in the site"s timezone.
-- --
-- function get_date_from_gmt( string, format = "Y-m-d H:i:s" ) then
--         datetime = date_create( string, new DateTimeZone( "UTC" ) );

--         if ( false === datetime ) then
--                 return gmdate( format, 0 );
--         end;

--         return datetime->setTimezone( wp_timezone() )->format( format );
-- end;

-- --
-- -- Given an ISO 8601 timezone, returns its UTC offset in seconds.
-- --
-- -- @since 1.5.0
-- --
-- -- @param string timezone Either "Z" for 0 offset or "±hhmm".
-- -- @return int|float The offset in seconds.
-- --
-- function iso8601_timezone_to_offset( timezone ) then
--         // timezone is either "Z" or "[+|-]hhmm".
--         if ( "Z" === timezone ) then
--                 offset = 0;
--         end; else then
--                 sign    = ( "+" === substr( timezone, 0, 1 ) ) ? 1 : -1;
--                 hours   = (int) substr( timezone, 1, 2 );
--                 minutes = (int) substr( timezone, 3, 4 ) / 60;
--                 offset  = sign-- HOUR_IN_SECONDS-- ( hours + minutes );
--         end;
--         return offset;
-- end;

-- --
-- -- Given an ISO 8601 (Ymd\TH:i:sO) date, returns a MySQL DateTime (Y-m-d H:i:s) format used by post_date[_gmt].
-- --
-- -- @since 1.5.0
-- --
-- -- @param string date_string Date and time in ISO 8601 format {@link https://en.wikipedia.org/wiki/ISO_8601}.
-- -- @param string timezone    Optional. If set to "gmt" returns the result in UTC. Default "user".
-- -- @return string|false The date and time in MySQL DateTime format - Y-m-d H:i:s, or false on failure.
-- --
-- function iso8601_to_datetime( date_string, timezone = "user" ) then
--         timezone    = strtolower( timezone );
--         wp_timezone = wp_timezone();
--         datetime    = date_create( date_string, wp_timezone ); // Timezone is ignored if input has one.

--         if ( false === datetime ) then
--                 return false;
--         end;

--         if ( "gmt" === timezone ) then
--                 return datetime->setTimezone( new DateTimeZone( "UTC" ) )->format( "Y-m-d H:i:s" );
--         end;

--         if ( "user" === timezone ) then
--                 return datetime->setTimezone( wp_timezone )->format( "Y-m-d H:i:s" );
--         end;

--         return false;
-- end;

-- --
-- -- Strips out all characters that are not allowable in an email.
-- --
-- -- @since 1.5.0
-- --
-- -- @param string email Email address to filter.
-- -- @return string Filtered email address.
-- --
-- function sanitize_email( email ) then
--         // Test for the minimum length the email can be.
--         if ( strlen( email ) < 6 ) then
--                 --
--                 -- Filters a sanitized email address.
--                 --
--                 -- This filter is evaluated under several contexts, including "email_too_short",
--                 -- "email_no_at", "local_invalid_chars", "domain_period_sequence", "domain_period_limits",
--                 -- "domain_no_periods", "domain_no_valid_subs", or no context.
--                 --
--                 -- @since 2.8.0
--                 --
--                 -- @param string sanitized_email The sanitized email address.
--                 -- @param string email           The email address, as provided to sanitize_email().
--                 -- @param string|null message    A message to pass to the user. null if email is sanitized.
--                 --
--                 return apply_filters( "sanitize_email", "", email, "email_too_short" );
--         end;

--         // Test for an @ character after the first position.
--         if ( strpos( email, "@", 1 ) === false ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "sanitize_email", "", email, "email_no_at" );
--         end;

--         // Split out the local and domain parts.
--         list( local, domain ) = explode( "@", email, 2 );

--         // LOCAL PART
--         // Test for invalid characters.
--         local = preg_replace( "/[^a-zA-Z0-9!#%&\"*+\/=?^_`then|end;~\.-]/", "", local );
--         if ( "" === local ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "sanitize_email", "", email, "local_invalid_chars" );
--         end;

--         // DOMAIN PART
--         // Test for sequences of periods.
--         domain = preg_replace( "/\.then2,end;/", "", domain );
--         if ( "" === domain ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "sanitize_email", "", email, "domain_period_sequence" );
--         end;

--         // Test for leading and trailing periods and whitespace.
--         domain = trim( domain, " \t\n\r\0\x0B." );
--         if ( "" === domain ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "sanitize_email", "", email, "domain_period_limits" );
--         end;

--         // Split the domain into subs.
--         subs = explode( ".", domain );

--         // Assume the domain will have at least two subs.
--         if ( 2 > count( subs ) ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "sanitize_email", "", email, "domain_no_periods" );
--         end;

--         // Create an array that will contain valid subs.
--         new_subs = array();

--         // Loop through each sub.
--         foreach ( subs as sub ) then
--                 // Test for leading and trailing hyphens.
--                 sub = trim( sub, " \t\n\r\0\x0B-" );

--                 // Test for invalid characters.
--                 sub = preg_replace( "/[^a-z0-9-]+/i", "", sub );

--                 // If there"s anything left, add it to the valid subs.
--                 if ( "" !== sub ) then
--                         new_subs[] = sub;
--                 end;
--         end;

--         // If there aren"t 2 or more valid subs.
--         if ( 2 > count( new_subs ) ) then
--                 -- This filter is documented in wp-includes/formatting.php--
--                 return apply_filters( "sanitize_email", "", email, "domain_no_valid_subs" );
--         end;

--         // Join valid subs into the new domain.
--         domain = implode( ".", new_subs );

--         // Put the email back together.
--         sanitized_email = local . "@" . domain;

--         // Congratulations, your email made it!
--         -- This filter is documented in wp-includes/formatting.php--
--         return apply_filters( "sanitize_email", sanitized_email, email, null );
-- end;

   ---------------------
   -- Human_Time_Diff --
   ---------------------

   function Human_Time_Diff (From : Integer;
                             To   : Integer := 0)
                             return String
   is
      use Php.Misc;
      use Php.Numerics;
      use Php.Strings;
      use Constants;
      use UStrings;
      use Wp_Common;
      use Inc_L10n;

      package Float_IO is new Ada.Text_IO.Float_IO (Float);

      function Round (Value    : Natural;
                      Dividend : Natural)
                      return Float;

      function To_String (Value : Float)
                          return String;

      -----------
      -- Round --
      -----------

      function Round (Value    : Natural;
                      Dividend : Natural)
                      return Float
      is
      begin
         return Float'Max (1.0, Round (Float (Value) / Float (Dividend)));
      end Round;

      ---------------
      -- To_String --
      ---------------

      function To_String (Value : Float)
                          return String
      is
         Image : String (1 .. 10);
      begin
         Float_IO.Put (Image, Value, Aft => 0, Exp => 0);
         return Trim (Image);
      end To_String;

      To_2 : constant Integer :=
        (if To = 0 then Time else To);

      Diff   : constant Natural := abs (To_2 - From);
--    Diff_F : constant Float   := Float (Diff);

      Since : UString;
   begin
      if Diff < MINUTE_IN_SECONDS then
         declare
            Secs : constant Float := Round (Diff, 1);
         begin
            -- translators: Time difference between two dates, in seconds.
            -- translators: %s: Number of seconds.
            Since := +Sprintf (X_N ("%s second", "%s seconds", Integer (Secs)),
                               [1 => To_String (Secs)]);
         end;

      elsif Diff in MINUTE_IN_SECONDS .. HOUR_IN_SECONDS then
         declare
            Mins : constant Float := Round (Diff, MINUTE_IN_SECONDS);
         begin
            -- translators: Time difference between two dates, in minutes (min=minute).
            -- translators: %s: Number of minutes.
            Since := +Sprintf (X_N ("%s min", "%s mins", Integer (Mins)),
                               [1 => To_String (Mins)]);
         end;

      elsif Diff in HOUR_IN_SECONDS .. DAY_IN_SECONDS then
         declare
            Hours : constant Float := Round (Diff, HOUR_IN_SECONDS);
         begin
            -- translators: Time difference between two dates, in hours.
            -- translators: %s: Number of hours.
            Since := +Sprintf (X_N ("%s hour", "%s hours", Integer (Hours)),
                               [1 => To_String (Hours)]);
         end;

      elsif Diff in DAY_IN_SECONDS .. WEEK_IN_SECONDS then
         declare
            Days : constant Float := Round (Diff, DAY_IN_SECONDS);
         begin
            -- translators: Time difference between two dates, in days.
            -- translators: %s: Number of days.
            Since := +Sprintf (X_N ("%s day", "%s days", Integer (Days)),
                               [1 => To_String (Days)]);
         end;

      elsif Diff in WEEK_IN_SECONDS .. MONTH_IN_SECONDS then
         declare
            Weeks : constant Float := Round (Diff, WEEK_IN_SECONDS);
         begin
            -- translators: Time difference between two dates, in weeks.
            -- translators: %s: Number of weeks.
            Since := +Sprintf (X_N ("%s week", "%s weeks", Integer (Weeks)),
                               [1 => To_String (Weeks)]);
         end;

      elsif Diff in MONTH_IN_SECONDS .. YEAR_IN_SECONDS then
         declare
            Months : constant Float := Round (Diff, MONTH_IN_SECONDS);
         begin
            -- translators: Time difference between two dates, in months.
            -- translators: %s: Number of months.
            Since := +Sprintf (X_N ("%s month", "%s months", Integer (Months)),
                               [1 => To_String (Months)]);
         end;

      elsif Diff >= YEAR_IN_SECONDS then
         declare
            Years : constant Float := Round (Diff, YEAR_IN_SECONDS);
         begin
            -- translators: Time difference between two dates, in years.
            -- translators: %s: Number of years.
            Since := +Sprintf (X_N ("%s year", "%s years", Integer (Years)),
                               [1 => To_String (Years)]);
         end;
      end if;

      --
      -- Filters the human readable difference between two timestamps.
      --
      -- @since 4.0.0
      --
      -- @param string since The difference in human readable text.
      -- @param int    diff  The difference in seconds.
      -- @param int    from  Unix timestamp from which the difference begins.
      -- @param int    to    Unix timestamp to end the time difference.
      --
      return Apply_Filters ("human_time_diff", -Since, Diff, From, To);
   end Human_Time_Diff;

-- --
-- -- Generates an excerpt from the content, if needed.
-- --
-- -- Returns a maximum of 55 words with an ellipsis appended if necessary.
-- --
-- -- The 55 word limit can be modified by plugins/themes using the {@see "excerpt_length"} filter
-- -- The " [&hellip;]" string can be modified by plugins/themes using the {@see "excerpt_more"} filter
-- --
-- -- @since 1.5.0
-- -- @since 5.2.0 Added the `post` parameter.
-- --
-- -- @param string             text Optional. The excerpt. If set to empty, an excerpt is generated.
-- -- @param WP_Post|object|int post Optional. WP_Post instance or Post ID/object. Default null.
-- -- @return string The excerpt.
-- --
-- function wp_trim_excerpt( text = "", post = null ) then
--         raw_excerpt = text;

--         if ( "" === trim( text ) ) then
--                 post = get_post( post );
--                 text = get_the_content( "", false, post );

--                 text = strip_shortcodes( text );
--                 text = excerpt_remove_blocks( text );

--                 -- This filter is documented in wp-includes/post-template.php--
--                 text = apply_filters( "the_content", text );
--                 text = str_replace( "]]>", "]]&gt;", text );

--                 /* translators: Maximum number of words used in a post excerpt.--
--                 excerpt_length = (int) _x( "55", "excerpt_length" );

--                 --
--                 -- Filters the maximum number of words in a post excerpt.
--                 --
--                 -- @since 2.7.0
--                 --
--                 -- @param int number The maximum number of words. Default 55.
--                 --
--                 excerpt_length = (int) apply_filters( "excerpt_length", excerpt_length );

--                 --
--                 -- Filters the string in the "more" link displayed after a trimmed excerpt.
--                 --
--                 -- @since 2.9.0
--                 --
--                 -- @param string more_string The string shown within the more link.
--                 --
--                 excerpt_more = apply_filters( "excerpt_more", " " . "[&hellip;]" );
--                 text         = wp_trim_words( text, excerpt_length, excerpt_more );
--         end;

--         --
--         -- Filters the trimmed excerpt string.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string text        The trimmed text.
--         -- @param string raw_excerpt The text prior to trimming.
--         --
--         return apply_filters( "wp_trim_excerpt", text, raw_excerpt );
-- end;

-- --
-- -- Trims text to a certain number of words.
-- --
-- -- This function is localized. For languages that count "words" by the individual
-- -- character (such as East Asian languages), the num_words argument will apply
-- -- to the number of individual characters.
-- --
-- -- @since 3.3.0
-- --
-- -- @param string text      Text to trim.
-- -- @param int    num_words Number of words. Default 55.
-- -- @param string more      Optional. What to append if text needs to be trimmed. Default "&hellip;".
-- -- @return string Trimmed text.
-- --
-- function wp_trim_words( text, num_words = 55, more = null ) then
--         if ( null === more ) then
--                 more = __( "&hellip;" );
--         end;

--         original_text = text;
--         text          = wp_strip_all_tags( text );
--         num_words     = (int) num_words;

--         /*
--         -- translators: If your word count is based on single characters (e.g. East Asian characters),
--         -- enter "characters_excluding_spaces" or "characters_including_spaces". Otherwise, enter "words".
--         -- Do not translate into your own language.
--         --
--         if ( strpos( _x( "words", "Word count type. Do not translate!" ), "characters" ) === 0 && preg_match( "/^utf\-?8/i", get_option( "blog_charset" ) ) ) then
--                 text = trim( preg_replace( "/[\n\r\t ]+/", " ", text ), " " );
--                 preg_match_all( "/./u", text, words_array );
--                 words_array = array_slice( words_array[0], 0, num_words + 1 );
--                 sep         = "";
--         end; else then
--                 words_array = preg_split( "/[\n\r\t ]+/", text, num_words + 1, PREG_SPLIT_NO_EMPTY );
--                 sep         = " ";
--         end;

--         if ( count( words_array ) > num_words ) then
--                 array_pop( words_array );
--                 text = implode( sep, words_array );
--                 text = text . more;
--         end; else then
--                 text = implode( sep, words_array );
--         end;

--         --
--         -- Filters the text content after words have been trimmed.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string text          The trimmed text.
--         -- @param int    num_words     The number of words to trim the text to. Default 55.
--         -- @param string more          An optional string to append to the end of the trimmed text, e.g. &hellip;.
--         -- @param string original_text The text before it was trimmed.
--         --
--         return apply_filters( "wp_trim_words", text, num_words, more, original_text );
-- end;

-- --
-- -- Converts named entities into numbered entities.
-- --
-- -- @since 1.5.1
-- --
-- -- @param string text The text within which entities will be converted.
-- -- @return string Text with converted entities.
-- --
-- function ent2ncr( text ) then

--         --
--         -- Filters text before named entities are converted into numbered entities.
--         --
--         -- A non-null string must be returned for the filter to be evaluated.
--         --
--         -- @since 3.3.0
--         --
--         -- @param string|null converted_text The text to be converted. Default null.
--         -- @param string      text           The text prior to entity conversion.
--         --
--         filtered = apply_filters( "pre_ent2ncr", null, text );
--         if ( null !== filtered ) then
--                 return filtered;
--         end;

--         to_ncr = array(
--                 "&quot;"     => "&#34;",
--                 "&amp;"      => "&#38;",
--                 "&lt;"       => "&#60;",
--                 "&gt;"       => "&#62;",
--                 "|"          => "&#124;",
--                 "&nbsp;"     => "&#160;",
--                 "&iexcl;"    => "&#161;",
--                 "&cent;"     => "&#162;",
--                 "&pound;"    => "&#163;",
--                 "&curren;"   => "&#164;",
--                 "&yen;"      => "&#165;",
--                 "&brvbar;"   => "&#166;",
--                 "&brkbar;"   => "&#166;",
--                 "&sect;"     => "&#167;",
--                 "&uml;"      => "&#168;",
--                 "&die;"      => "&#168;",
--                 "&copy;"     => "&#169;",
--                 "&ordf;"     => "&#170;",
--                 "&laquo;"    => "&#171;",
--                 "&not;"      => "&#172;",
--                 "&shy;"      => "&#173;",
--                 "&reg;"      => "&#174;",
--                 "&macr;"     => "&#175;",
--                 "&hibar;"    => "&#175;",
--                 "&deg;"      => "&#176;",
--                 "&plusmn;"   => "&#177;",
--                 "&sup2;"     => "&#178;",
--                 "&sup3;"     => "&#179;",
--                 "&acute;"    => "&#180;",
--                 "&micro;"    => "&#181;",
--                 "&para;"     => "&#182;",
--                 "&middot;"   => "&#183;",
--                 "&cedil;"    => "&#184;",
--                 "&sup1;"     => "&#185;",
--                 "&ordm;"     => "&#186;",
--                 "&raquo;"    => "&#187;",
--                 "&frac14;"   => "&#188;",
--                 "&frac12;"   => "&#189;",
--                 "&frac34;"   => "&#190;",
--                 "&iquest;"   => "&#191;",
--                 "&Agrave;"   => "&#192;",
--                 "&Aacute;"   => "&#193;",
--                 "&Acirc;"    => "&#194;",
--                 "&Atilde;"   => "&#195;",
--                 "&Auml;"     => "&#196;",
--                 "&Aring;"    => "&#197;",
--                 "&AElig;"    => "&#198;",
--                 "&Ccedil;"   => "&#199;",
--                 "&Egrave;"   => "&#200;",
--                 "&Eacute;"   => "&#201;",
--                 "&Ecirc;"    => "&#202;",
--                 "&Euml;"     => "&#203;",
--                 "&Igrave;"   => "&#204;",
--                 "&Iacute;"   => "&#205;",
--                 "&Icirc;"    => "&#206;",
--                 "&Iuml;"     => "&#207;",
--                 "&ETH;"      => "&#208;",
--                 "&Ntilde;"   => "&#209;",
--                 "&Ograve;"   => "&#210;",
--                 "&Oacute;"   => "&#211;",
--                 "&Ocirc;"    => "&#212;",
--                 "&Otilde;"   => "&#213;",
--                 "&Ouml;"     => "&#214;",
--                 "&times;"    => "&#215;",
--                 "&Oslash;"   => "&#216;",
--                 "&Ugrave;"   => "&#217;",
--                 "&Uacute;"   => "&#218;",
--                 "&Ucirc;"    => "&#219;",
--                 "&Uuml;"     => "&#220;",
--                 "&Yacute;"   => "&#221;",
--                 "&THORN;"    => "&#222;",
--                 "&szlig;"    => "&#223;",
--                 "&agrave;"   => "&#224;",
--                 "&aacute;"   => "&#225;",
--                 "&acirc;"    => "&#226;",
--                 "&atilde;"   => "&#227;",
--                 "&auml;"     => "&#228;",
--                 "&aring;"    => "&#229;",
--                 "&aelig;"    => "&#230;",
--                 "&ccedil;"   => "&#231;",
--                 "&egrave;"   => "&#232;",
--                 "&eacute;"   => "&#233;",
--                 "&ecirc;"    => "&#234;",
--                 "&euml;"     => "&#235;",
--                 "&igrave;"   => "&#236;",
--                 "&iacute;"   => "&#237;",
--                 "&icirc;"    => "&#238;",
--                 "&iuml;"     => "&#239;",
--                 "&eth;"      => "&#240;",
--                 "&ntilde;"   => "&#241;",
--                 "&ograve;"   => "&#242;",
--                 "&oacute;"   => "&#243;",
--                 "&ocirc;"    => "&#244;",
--                 "&otilde;"   => "&#245;",
--                 "&ouml;"     => "&#246;",
--                 "&divide;"   => "&#247;",
--                 "&oslash;"   => "&#248;",
--                 "&ugrave;"   => "&#249;",
--                 "&uacute;"   => "&#250;",
--                 "&ucirc;"    => "&#251;",
--                 "&uuml;"     => "&#252;",
--                 "&yacute;"   => "&#253;",
--                 "&thorn;"    => "&#254;",
--                 "&yuml;"     => "&#255;",
--                 "&OElig;"    => "&#338;",
--                 "&oelig;"    => "&#339;",
--                 "&Scaron;"   => "&#352;",
--                 "&scaron;"   => "&#353;",
--                 "&Yuml;"     => "&#376;",
--                 "&fnof;"     => "&#402;",
--                 "&circ;"     => "&#710;",
--                 "&tilde;"    => "&#732;",
--                 "&Alpha;"    => "&#913;",
--                 "&Beta;"     => "&#914;",
--                 "&Gamma;"    => "&#915;",
--                 "&Delta;"    => "&#916;",
--                 "&Epsilon;"  => "&#917;",
--                 "&Zeta;"     => "&#918;",
--                 "&Eta;"      => "&#919;",
--                 "&Theta;"    => "&#920;",
--                 "&Iota;"     => "&#921;",
--                 "&Kappa;"    => "&#922;",
--                 "&Lambda;"   => "&#923;",
--                 "&Mu;"       => "&#924;",
--                 "&Nu;"       => "&#925;",
--                 "&Xi;"       => "&#926;",
--                 "&Omicron;"  => "&#927;",
--                 "&Pi;"       => "&#928;",
--                 "&Rho;"      => "&#929;",
--                 "&Sigma;"    => "&#931;",
--                 "&Tau;"      => "&#932;",
--                 "&Upsilon;"  => "&#933;",
--                 "&Phi;"      => "&#934;",
--                 "&Chi;"      => "&#935;",
--                 "&Psi;"      => "&#936;",
--                 "&Omega;"    => "&#937;",
--                 "&alpha;"    => "&#945;",
--                 "&beta;"     => "&#946;",
--                 "&gamma;"    => "&#947;",
--                 "&delta;"    => "&#948;",
--                 "&epsilon;"  => "&#949;",
--                 "&zeta;"     => "&#950;",
--                 "&eta;"      => "&#951;",
--                 "&theta;"    => "&#952;",
--                 "&iota;"     => "&#953;",
--                 "&kappa;"    => "&#954;",
--                 "&lambda;"   => "&#955;",
--                 "&mu;"       => "&#956;",
--                 "&nu;"       => "&#957;",
--                 "&xi;"       => "&#958;",
--                 "&omicron;"  => "&#959;",
--                 "&pi;"       => "&#960;",
--                 "&rho;"      => "&#961;",
--                 "&sigmaf;"   => "&#962;",
--                 "&sigma;"    => "&#963;",
--                 "&tau;"      => "&#964;",
--                 "&upsilon;"  => "&#965;",
--                 "&phi;"      => "&#966;",
--                 "&chi;"      => "&#967;",
--                 "&psi;"      => "&#968;",
--                 "&omega;"    => "&#969;",
--                 "&thetasym;" => "&#977;",
--                 "&upsih;"    => "&#978;",
--                 "&piv;"      => "&#982;",
--                 "&ensp;"     => "&#8194;",
--                 "&emsp;"     => "&#8195;",
--                 "&thinsp;"   => "&#8201;",
--                 "&zwnj;"     => "&#8204;",
--                 "&zwj;"      => "&#8205;",
--                 "&lrm;"      => "&#8206;",
--                 "&rlm;"      => "&#8207;",
--                 "&ndash;"    => "&#8211;",
--                 "&mdash;"    => "&#8212;",
--                 "&lsquo;"    => "&#8216;",
--                 "&rsquo;"    => "&#8217;",
--                 "&sbquo;"    => "&#8218;",
--                 "&ldquo;"    => "&#8220;",
--                 "&rdquo;"    => "&#8221;",
--                 "&bdquo;"    => "&#8222;",
--                 "&dagger;"   => "&#8224;",
--                 "&Dagger;"   => "&#8225;",
--                 "&bull;"     => "&#8226;",
--                 "&hellip;"   => "&#8230;",
--                 "&permil;"   => "&#8240;",
--                 "&prime;"    => "&#8242;",
--                 "&Prime;"    => "&#8243;",
--                 "&lsaquo;"   => "&#8249;",
--                 "&rsaquo;"   => "&#8250;",
--                 "&oline;"    => "&#8254;",
--                 "&frasl;"    => "&#8260;",
--                 "&euro;"     => "&#8364;",
--                 "&image;"    => "&#8465;",
--                 "&weierp;"   => "&#8472;",
--                 "&real;"     => "&#8476;",
--                 "&trade;"    => "&#8482;",
--                 "&alefsym;"  => "&#8501;",
--                 "&crarr;"    => "&#8629;",
--                 "&lArr;"     => "&#8656;",
--                 "&uArr;"     => "&#8657;",
--                 "&rArr;"     => "&#8658;",
--                 "&dArr;"     => "&#8659;",
--                 "&hArr;"     => "&#8660;",
--                 "&forall;"   => "&#8704;",
--                 "&part;"     => "&#8706;",
--                 "&exist;"    => "&#8707;",
--                 "&empty;"    => "&#8709;",
--                 "&nabla;"    => "&#8711;",
--                 "&isin;"     => "&#8712;",
--                 "&notin;"    => "&#8713;",
--                 "&ni;"       => "&#8715;",
--                 "&prod;"     => "&#8719;",
--                 "&sum;"      => "&#8721;",
--                 "&minus;"    => "&#8722;",
--                 "&lowast;"   => "&#8727;",
--                 "&radic;"    => "&#8730;",
--                 "&prop;"     => "&#8733;",
--                 "&infin;"    => "&#8734;",
--                 "&ang;"      => "&#8736;",
--                 "&and;"      => "&#8743;",
--                 "&or;"       => "&#8744;",
--                 "&cap;"      => "&#8745;",
--                 "&cup;"      => "&#8746;",
--                 "&int;"      => "&#8747;",
--                 "&there4;"   => "&#8756;",
--                 "&sim;"      => "&#8764;",
--                 "&cong;"     => "&#8773;",
--                 "&asymp;"    => "&#8776;",
--                 "&ne;"       => "&#8800;",
--                 "&equiv;"    => "&#8801;",
--                 "&le;"       => "&#8804;",
--                 "&ge;"       => "&#8805;",
--                 "&sub;"      => "&#8834;",
--                 "&sup;"      => "&#8835;",
--                 "&nsub;"     => "&#8836;",
--                 "&sube;"     => "&#8838;",
--                 "&supe;"     => "&#8839;",
--                 "&oplus;"    => "&#8853;",
--                 "&otimes;"   => "&#8855;",
--                 "&perp;"     => "&#8869;",
--                 "&sdot;"     => "&#8901;",
--                 "&lceil;"    => "&#8968;",
--                 "&rceil;"    => "&#8969;",
--                 "&lfloor;"   => "&#8970;",
--                 "&rfloor;"   => "&#8971;",
--                 "&lang;"     => "&#9001;",
--                 "&rang;"     => "&#9002;",
--                 "&larr;"     => "&#8592;",
--                 "&uarr;"     => "&#8593;",
--                 "&rarr;"     => "&#8594;",
--                 "&darr;"     => "&#8595;",
--                 "&harr;"     => "&#8596;",
--                 "&loz;"      => "&#9674;",
--                 "&spades;"   => "&#9824;",
--                 "&clubs;"    => "&#9827;",
--                 "&hearts;"   => "&#9829;",
--                 "&diams;"    => "&#9830;",
--         );

--         return str_replace( array_keys( to_ncr ), array_values( to_ncr ), text );
-- end;

-- --
-- -- Formats text for the editor.
-- --
-- -- Generally the browsers treat everything inside a textarea as text, but
-- -- it is still a good idea to HTML entity encode `<`, `>` and `&` in the content.
-- --
-- -- The filter {@see "format_for_editor"} is applied here. If `text` is empty the
-- -- filter will be applied to an empty string.
-- --
-- -- @since 4.3.0
-- --
-- -- @see _WP_Editors::editor()
-- --
-- -- @param string text           The text to be formatted.
-- -- @param string default_editor The default editor for the current user.
-- --                               It is usually either "html" or "tinymce".
-- -- @return string The formatted text after filter is applied.
-- --
-- function format_for_editor( text, default_editor = null ) then
--         if ( text ) then
--                 text = htmlspecialchars( text, ENT_NOQUOTES, get_option( "blog_charset" ) );
--         end;

--         --
--         -- Filters the text after it is formatted for the editor.
--         --
--         -- @since 4.3.0
--         --
--         -- @param string text           The formatted text.
--         -- @param string default_editor The default editor for the current user.
--         --                               It is usually either "html" or "tinymce".
--         --
--         return apply_filters( "format_for_editor", text, default_editor );
-- end;

   --------------------
   -- X_Deep_Replace --
   --------------------

   function X_Deep_Replace (Search  : List_Type;
                            Subject : String)
                            return String
   is
      use Php.Strings;
      use UStrings;

      Sub   : UString := +Subject;
      Count : Natural := 1;
   begin
      while Count /= 0 loop
         Sub := +Str_Replace (Search  => Search,
                              Replace => "",
                              Subject => -Sub,
                              Count   => Count);
      end loop;

      return -Sub;
   end X_Deep_Replace;

   -------------
   -- ESC_SQL --
   -------------

   function ESC_SQL (Data : String)
                     return String
   is
      use Globals;
   begin
      return WpDB.X_Escape (Data);
   end ESC_SQL;

   -------------
   -- ESC_URL --
   -------------

   function ESC_URL (URL       : String;
                     Protocols : List_Type := Empty_List;
                     X_Context : String    := "display")
                    return String
   is
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Functions;
      use Inc_HTTP;
      use Inc_KSES;

      function Display (URL : String)
                        return String;

      -------------
      -- Display --
      -------------

      function Display (URL : String)
                        return String
      is
         URL_2 : constant String := Wp_KSES_Normalize_Entities     (URL);
         URL_3 : constant String := Str_Replace ("&amp;", "&#038;", URL_2);
         URL_4 : constant String := Str_Replace ("'",     "&#039;", URL_3);
      begin
         return URL_4;
      end Display;

      Original_URL : constant String := URL;
   begin
      if "" = URL then
         return URL;
      end if;

      declare
         URL_2 : constant String := Str_Replace (" ", "%20", Ltrim (URL));

         URL_3 : constant String :=
           Preg_Replace
             ("|[^a-z0-9-~+_.?#=!&;,/:%@\|*\'()\[\]\\x80-\\xff]|i", "", URL_2);

         Strip : constant List_Type := ["%0d", "%0a", "%0D", "%0A"];

         URL_4 : constant String :=
           (if 0 /= Stripos (URL_3, "mailto:")
            then X_Deep_Replace (Strip, URL_3)
            else URL_3);

         URL_5 : constant String := Str_Replace (";//", "://", URL_4);

         -- If the URL doesn't appear to contain a scheme, we presume
         -- it needs http:// prepended (unless it's a relative link
         -- starting with /, # or ?, or a PHP file).
         Cond : constant Boolean :=
           Strpos (URL_5, ":") = 0
           and then not In_List
                          (URL_5 (URL_5'First) & "",
                           List_Type'["/", "#", "?"],
                           True)
           and then not Preg_Match ("/^[a-z0-9-]+?\.php/i", URL_5);

         URL_6 : constant String :=
           (if Cond then "http://" & URL_5 else URL_5);

         -- Replace ampersands and single quotes only when displaying.
         URL_7 : constant String :=
           (if "display" = X_Context then Display (URL_6) else URL_6);

         URL_8 : UString := +URL_7;
      begin
         if "" = URL_3 then
            -- Yes, URL_3
            return URL_3;
         end if;

         if 0 /= Strpos (URL_7, "[") or else 0 /= Strpos (URL_7, "]") then
            declare
               Parsed : constant Array_Type := Wp_Parse_URL (URL_7);
               Front  : UString;
            begin
               if Isset (Parsed, "scheme") then
                  Append (Front, Get_As_String (Parsed, "scheme") & "://");
               elsif '/' = URL_7 (URL_7'First) then
                  -- [0]
                  Append (Front, "//");
               end if;

               if Isset (Parsed, "user") then
                  Append (Front, Get_As_String (Parsed, "user"));
               end if;

               if Isset (Parsed, "pass") then
                  Append (Front, ":" & Get_As_String (Parsed, "pass"));
               end if;

               if Isset (Parsed, "user") or else Isset (Parsed, "pass") then
                  Append (Front, "@");
               end if;

               if Isset (Parsed, "host") then
                  Append (Front, Get_As_String (Parsed, "host"));
               end if;

               if Isset (Parsed, "port") then
                  Append (Front, ":" & Get_As_String (Parsed, "port"));
               end if;

               declare
                  End_Dirty : constant String :=
                    Str_Replace (-Front, "", URL_7);
                  End_Clean : constant String :=
                    Str_Replace
                      (List_Type'["[", "]"],
                       List_Type'["%5B", "%5D"],
                       End_Dirty);
               begin
                  URL_8 := +Str_Replace (End_Dirty, End_Clean, URL_7);
               end;
            end;
         end if;

         declare
            URL_9             : constant String := -URL_8;
            Good_Protocol_URL : UString;
         begin
            if URL_9'Length >= 1 and then '/' = URL_9 (URL_9'First) then
               Good_Protocol_URL := +URL_9;
            else
               declare
                  Protocols_2 : constant List_Type :=
                    (if Protocols in [] -- not Is_Array (Protocols)
                     then
                       Wp_Allowed_Protocols
                     else Protocols);
               begin
                  Good_Protocol_URL :=
                    +Wp_KSES_Bad_Protocol (URL_9, Protocols_2);
                  if Strtolower (-Good_Protocol_URL) /= Strtolower (URL_9) then
                     return "";
                  end if;
               end;
            end if;

            --
            -- Filters a string cleaned and escaped for output as a URL.
            --
            -- @since 2.3.0
            --
            -- @param string good_protocol_url The cleaned URL to be returned.
            -- @param string original_url      The URL prior to cleaning.
            -- @param string _context          If "display", replace ampersands
            --                                  and single quotes only.
            --
            return
              Apply_Filters
                ("clean_url", -Good_Protocol_URL, Original_URL, X_Context);
         end;
      end;
   end ESC_URL;

   -----------------
   -- ESC_URL_Raw --
   -----------------

   function ESC_URL_Raw (URL       : String;
                         Protocols : List_Type := Empty_List) -- null
                         return String
   is
   begin
      return Sanitize_URL (URL, Protocols);
   end ESC_URL_Raw;

   ------------------
   -- Sanitize_URL --
   ------------------

   function Sanitize_URL (URL       : String;
                          Protocols : List_Type := Empty_List)
                          return String
   is
   begin
      return ESC_URL (URL, Protocols, "db");
   end Sanitize_URL;

-- --
-- -- Converts entities, while preserving already-encoded entities.
-- --
-- -- @link https://www.php.net/htmlentities Borrowed from the PHP Manual user notes.
-- --
-- -- @since 1.2.2
-- --
-- -- @param string myHTML The text to be converted.
-- -- @return string Converted text.
-- --
-- function htmlentities2( myHTML ) then
--         translation_table              = get_html_translation_table( HTML_ENTITIES, ENT_QUOTES );
--         translation_table[ chr( 38 ) ] = "&";
--         return preg_replace( "/&(?![A-Za-z]then0,4end;\wthen2,3end;;|#[0-9]then2,3end;;)/", "&amp;", strtr( myHTML, translation_table ) );
-- end;

   ------------
   -- ESC_JS --
   ------------

   function ESC_JS (Text : String)
                    return String
   is
      use Php.Strings;
      use Php.HTML;
      use Php.Preg;
      use Wp_Common;

      Safe_Text_5 : constant String := Wp_Check_Invalid_UTF8 (Text);
      Safe_Text_4 : constant String := X_Wp_Specialchars (Safe_Text_5, ENT_COMPAT);

      Safe_Text_3 : constant String :=
        Preg_Replace ("/&#(x)?0*(?(1)27|39);?/i", "'", Strip_Slashes (Safe_Text_4));

      Safe_Text_2 : constant String := Str_Replace ("\r", "", Safe_Text_3);

      Safe_Text   : constant String :=
        Str_Replace ("\n", "\\n", Add_Slashes (Safe_Text_2));
   begin
      --
      -- Filters a string cleaned and escaped for output in JavaScript.
      --
      -- Text passed to esc_js() is stripped of invalid or special characters,
      -- and properly slashed for output.
      --
      -- @since 2.0.6
      --
      -- @param string safe_text The text after it has been escaped.
      -- @param string text      The text prior to being escaped.
      --
      return Apply_Filters ("js_escape", Safe_Text, Text);
   end ESC_JS;

--
-- Escaping for HTML blocks.
--
-- @since 2.8.0
--
-- @param string text
-- @return string
--
   --------------
   -- Esc_Html --
   --------------

   function ESC_HTML (Item : String)
                      return String
   is
--      Safe_Text = Wp_Check_Invalid_Utf8 (Text);
--      Safe_Text = X_Wp_Specialchars (Safe_Text, ENT_QUOTES);
   begin
       --
       -- Filters a string cleaned and escaped for output in HTML.
       --
       -- Text passed to esc_html() is stripped of invalid or special characters
       -- before output.
       --
       -- @since 2.8.0
       --
       -- @param string safe_text The text after it has been escaped.
       -- @param string text      The text prior to being escaped.
       --
--       return Apply_Filters ("esc_html", Safe_Text, Text);
      return Item;
   end ESC_HTML;

   --------------
   -- ESC_Attr --
   --------------

   function ESC_Attr (Text : String)
                      return String
   is
      use Wp_Common;

      Safe_Text_2 : constant String := Wp_Check_Invalid_UTF8 (Text);

      Safe_Text   : constant String :=
        X_Wp_Specialchars (Safe_Text_2, Php.HTML.ENT_QUOTES);
   begin
      --
      -- Filters a string cleaned and escaped for output in an HTML attribute.
      --
      -- Text passed to esc_attr() is stripped of invalid or special characters
      -- before output.
      --
      -- @since 2.0.6
      --
      -- @param string safe_text The text after it has been escaped.
      -- @param string text      The text prior to being escaped.
      --
      return Apply_Filters ("attribute_escape", Safe_Text, Text);
   end ESC_Attr;

-- --
-- -- Escaping for textarea values.
-- --
-- -- @since 3.1.0
-- --
-- -- @param string text
-- -- @return string
-- --
-- function esc_textarea( text ) then
--         safe_text = htmlspecialchars( text, ENT_QUOTES, get_option( "blog_charset" ) );
--         --
--         -- Filters a string cleaned and escaped for output in a textarea element.
--         --
--         -- @since 3.1.0
--         --
--         -- @param string safe_text The text after it has been escaped.
--         -- @param string text      The text prior to being escaped.
--         --
--         return apply_filters( "esc_textarea", safe_text, text );
-- end;

-- --
-- -- Escaping for XML blocks.
-- --
-- -- @since 5.5.0
-- --
-- -- @param string text Text to escape.
-- -- @return string Escaped text.
-- --
-- function esc_xml( text ) then
--         safe_text = wp_check_invalid_utf8( text );

--         cdata_regex = "\<\!\[CDATA\[.*?\]\]\>";
--         regex       = <<<EOF
-- /
--         (?=.*?thencdata_regexend;)                 # lookahead that will match anything followed by a CDATA Section
--         (?<non_cdata_followed_by_cdata>(.*?)) # the "anything" matched by the lookahead
--         (?<cdata>(thencdata_regexend;))            # the CDATA Section matched by the lookahead

-- |                                             # alternative

--         (?<non_cdata>(.*))                    # non-CDATA Section
-- /sx
-- EOF;

--         safe_text = (string) preg_replace_callback(
--                 regex,
--                 static function( matches ) then
--                         if ( ! isset( matches[0] ) ) then
--                                 return "";
--                         end;

--                         if ( isset( matches["non_cdata"] ) ) then
--                                 // escape HTML entities in the non-CDATA Section.
--                                 return _wp_specialchars( matches["non_cdata"], ENT_XML1 );
--                         end;

--                         // Return the CDATA Section unchanged, escape HTML entities in the rest.
--                         return _wp_specialchars( matches["non_cdata_followed_by_cdata"], ENT_XML1 ) . matches["cdata"];
--                 end;,
--                 safe_text
--         );

--         --
--         -- Filters a string cleaned and escaped for output in XML.
--         --
--         -- Text passed to esc_xml() is stripped of invalid or special characters
--         -- before output. HTML named character references are converted to their
--         -- equivalent code points.
--         --
--         -- @since 5.5.0
--         --
--         -- @param string safe_text The text after it has been escaped.
--         -- @param string text      The text prior to being escaped.
--         --
--         return apply_filters( "esc_xml", safe_text, text );
-- end;

-- --
-- -- Escapes an HTML tag name.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string tag_name
-- -- @return string
-- --
-- function tag_escape( tag_name ) then
--         safe_tag = strtolower( preg_replace( "/[^a-zA-Z0-9_:]/", "", tag_name ) );
--         --
--         -- Filters a string cleaned and escaped for output as an HTML tag.
--         --
--         -- @since 2.8.0
--         --
--         -- @param string safe_tag The tag name after it has been escaped.
--         -- @param string tag_name The text before it was escaped.
--         --
--         return apply_filters( "tag_escape", safe_tag, tag_name );
-- end;

   ---------------------------
   -- Wp_Make_Link_Relative --
   ---------------------------

   function Wp_Make_Link_Relative (Link : String)
                                   return String
   is
      use Php.Preg;
   begin
      return Preg_Replace ("|^(https?:)?//[^/]+(/?.*)|i", "2", Link);
   end Wp_Make_Link_Relative;

   ---------------------
   -- Sanitize_Option --
   ---------------------

   function Sanitize_Option (Option : String;
                             Value  : String)
                             return String
   is
      use Ada.Text_IO;
   begin
      Put_Line ("sanitize_option: option: " & Option & "  value: " & Value);
      Put_Line ("sanitize_option: not implemented");
      return Value;
   end Sanitize_Option;

--         global wpdb;

--         original_value = value;
--         error          = null;

--         switch ( option ) then
--                 case "admin_email":
--                 case "new_admin_email":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 value = sanitize_email( value );
--                                 if ( ! is_email( value ) ) then
--                                         error = __( "The email address entered did not appear to be a valid email address. Please enter a valid email address." );
--                                 end;
--                         end;
--                         break;

--                 case "thumbnail_size_w":
--                 case "thumbnail_size_h":
--                 case "medium_size_w":
--                 case "medium_size_h":
--                 case "medium_large_size_w":
--                 case "medium_large_size_h":
--                 case "large_size_w":
--                 case "large_size_h":
--                 case "mailserver_port":
--                 case "comment_max_links":
--                 case "page_on_front":
--                 case "page_for_posts":
--                 case "rss_excerpt_length":
--                 case "default_category":
--                 case "default_email_category":
--                 case "default_link_category":
--                 case "close_comments_days_old":
--                 case "comments_per_page":
--                 case "thread_comments_depth":
--                 case "users_can_register":
--                 case "start_of_week":
--                 case "site_icon":
--                 case "fileupload_maxk":
--                         value = absint( value );
--                         break;

--                 case "posts_per_page":
--                 case "posts_per_rss":
--                         value = (int) value;
--                         if ( empty( value ) ) then
--                                 value = 1;
--                         end;
--                         if ( value < -1 ) then
--                                 value = abs( value );
--                         end;
--                         break;

--                 case "default_ping_status":
--                 case "default_comment_status":
--                         // Options that if not there have 0 value but need to be something like "closed".
--                         if ( "0" == value || "" === value ) then
--                                 value = "closed";
--                         end;
--                         break;

--                 case "blogdescription":
--                 case "blogname":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( value !== original_value ) then
--                                 value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", wp_encode_emoji( original_value ) );
--                         end;

--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 value = esc_html( value );
--                         end;
--                         break;

--                 case "blog_charset":
--                         value = preg_replace( "/[^a-zA-Z0-9_-]/", "", value ); // Strips slashes.
--                         break;

--                 case "blog_public":
--                         // This is the value if the settings checkbox is not checked on POST. Don"t rely on this.
--                         if ( null === value ) then
--                                 value = 1;
--                         end; else then
--                                 value = (int) value;
--                         end;
--                         break;

--                 case "date_format":
--                 case "time_format":
--                 case "mailserver_url":
--                 case "mailserver_login":
--                 case "mailserver_pass":
--                 case "upload_path":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 value = strip_tags( value );
--                                 value = wp_kses_data( value );
--                         end;
--                         break;

--                 case "ping_sites":
--                         value = explode( "\n", value );
--                         value = array_filter( array_map( "trim", value ) );
--                         value = array_filter( array_map( "sanitize_url", value ) );
--                         value = implode( "\n", value );
--                         break;

--                 case "gmt_offset":
--                         value = preg_replace( "/[^0-9:.-]/", "", value ); // Strips slashes.
--                         break;

--                 case "siteurl":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 if ( preg_match( "#http(s?)://(.+)#i", value ) ) then
--                                         value = sanitize_url( value );
--                                 end; else then
--                                         error = __( "The WordPress address you entered did not appear to be a valid URL. Please enter a valid URL." );
--                                 end;
--                         end;
--                         break;

--                 case "home":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 if ( preg_match( "#http(s?)://(.+)#i", value ) ) then
--                                         value = sanitize_url( value );
--                                 end; else then
--                                         error = __( "The Site address you entered did not appear to be a valid URL. Please enter a valid URL." );
--                                 end;
--                         end;
--                         break;

--                 case "WPLANG":
--                         allowed = get_available_languages();
--                         if ( ! is_multisite() && defined( "WPLANG" ) && "" !== WPLANG && "en_US" !== WPLANG ) then
--                                 allowed[] = WPLANG;
--                         end;
--                         if ( ! in_array( value, allowed, true ) && ! empty( value ) ) then
--                                 value = get_option( option );
--                         end;
--                         break;

--                 case "illegal_names":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 if ( ! is_array( value ) ) then
--                                         value = explode( " ", value );
--                                 end;

--                                 value = array_values( array_filter( array_map( "trim", value ) ) );

--                                 if ( ! value ) then
--                                         value = "";
--                                 end;
--                         end;
--                         break;

--                 case "limited_email_domains":
--                 case "banned_email_domains":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 if ( ! is_array( value ) ) then
--                                         value = explode( "\n", value );
--                                 end;

--                                 domains = array_values( array_filter( array_map( "trim", value ) ) );
--                                 value   = array();

--                                 foreach ( domains as domain ) then
--                                         if ( ! preg_match( "/(--|\.\.)/", domain ) && preg_match( "|^([a-zA-Z0-9-\.])+|", domain ) ) then
--                                                 value[] = domain;
--                                         end;
--                                 end;
--                                 if ( ! value ) then
--                                         value = "";
--                                 end;
--                         end;
--                         break;

--                 case "timezone_string":
--                         allowed_zones = timezone_identifiers_list( DateTimeZone::ALL_WITH_BC );
--                         if ( ! in_array( value, allowed_zones, true ) && ! empty( value ) ) then
--                                 error = __( "The timezone you have entered is not valid. Please select a valid timezone." );
--                         end;
--                         break;

--                 case "permalink_structure":
--                 case "category_base":
--                 case "tag_base":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 value = sanitize_url( value );
--                                 value = str_replace( "http://", "", value );
--                         end;

--                         if ( "permalink_structure" === option && null === error
--                                 && "" !== value && ! preg_match( "/%[^\/%]+%/", value )
--                         ) then
--                                 error = sprintf(
--                                         /* translators: %s: Documentation URL.--
--                                         __( "A structure tag is required when using custom permalinks. <a href="%s">Learn more</a>" ),
--                                         __( "https://wordpress.org/support/article/using-permalinks/#choosing-your-permalink-structure" )
--                                 );
--                         end;
--                         break;

--                 case "default_role":
--                         if ( ! get_role( value ) && get_role( "subscriber" ) ) then
--                                 value = "subscriber";
--                         end;
--                         break;

--                 case "moderation_keys":
--                 case "disallowed_keys":
--                         value = wpdb->strip_invalid_text_for_column( wpdb->options, "option_value", value );
--                         if ( is_wp_error( value ) ) then
--                                 error = value->get_error_message();
--                         end; else then
--                                 value = explode( "\n", value );
--                                 value = array_filter( array_map( "trim", value ) );
--                                 value = array_unique( value );
--                                 value = implode( "\n", value );
--                         end;
--                         break;
--         end;

--         if ( null !== error ) then
--                 if ( "" === error && is_wp_error( value ) ) then
--                         /* translators: 1: Option name, 2: Error code.--
--                         error = sprintf( __( "Could not sanitize the %1s option. Error code: %2s" ), option, value->get_error_code() );
--                 end;

--                 value = get_option( option );
--                 if ( function_exists( "add_settings_error" ) ) then
--                         add_settings_error( option, "invalid_thenoptionend;", error );
--                 end;
--         end;

--         --
--         -- Filters an option value following sanitization.
--         --
--         -- @since 2.3.0
--         -- @since 4.3.0 Added the `original_value` parameter.
--         --
--         -- @param string value          The sanitized option value.
--         -- @param string option         The option name.
--         -- @param string original_value The original value passed to the function.
--         --
--         return apply_filters( "sanitize_option_thenoptionend;", value, option, original_value );
-- end;

   --------------
   -- Max_Deep --
   --------------

   function Map_Deep (Value    : Array_Type;
                      Callback : Callable)
                      return Array_Type
   is
      Result : Array_Type;
   begin
      for A in Value.Iterate loop
         declare
            K : constant String     := Key (A);
            V : constant Multi_Type := Element (A);
         begin
            if Kind_Of (V) = Kind_Array then
               Result.Append (K, From_Array (Map_Deep (As_Array (V), Callback)));
            else
               Result.Append (K, V);
            end if;
         end;
      end loop;
      return Result;

         -- end; elseif ( is_object( value ) ) then
         --         object_vars = get_object_vars( value );
         --         foreach ( object_vars as property_name => property_value ) then
         --              value->property_name = map_deep( property_value, callback );
         --         end;
         -- end; else then
         --         value = call_user_func( callback, value );
         -- end;

         -- return value;
   end Map_Deep;

   --------------
   -- Max_Deep --
   --------------

   function Map_Deep (Value    : String;
                      Callback : Callable)
                      return String
   is
   begin
      return Callback (Value);
   end Map_Deep;

--    function Map_Deep (Value    : String;
--                       Callback : Callable)
--                       return String
--    is
--       Value_2 : Array_Type;
--    begin
--       -- if ( is_array( value ) ) then
--       for A in Value.Iterate loop
--          declare
--             Index : constant String       := Array_Maps.Key     (A);
--             Item  : constant Multi_Type := Array_Maps.Element (A);
--          begin
--             Value_2.Include (Key      => Index,
--                              New_Item => Map_Deep (Item.Arry.all, Callback));
-- --          value[ index ] = map_deep( item, callback );
--          end;
--       end loop;
--       return Value_2;
--    end Max_Deep;

--
-- Parses a string into variables to be stored in an array.
--
-- @since 2.2.1
--
-- @param string string The string to be parsed.
-- @param array  array  Variables will be stored in this array.
--
   procedure Wp_Parse_Str (Str  : String;
                           Arry : out Array_Type)
   is
   begin
      null;
--        Parse_Str (Str, Arry);

      --
      -- Filters the array of variables derived from a parsed string.
      --
      -- @since 2.2.1
      --
      -- @param array array The array populated with variables.
      --
--      Arry := Apply_Filters ("wp_parse_str", Arry);
   end Wp_Parse_Str;

   ---------------------------
   -- Wp_Pre_KSES_Less_Than --
   ---------------------------

   function Wp_Pre_KSES_Less_Than (Text : String)
                                   return String
   is
      use Php.Preg;
   begin
      return
        Preg_Replace_Callback ("%<[^>]*?((?=<)|>|)%",
                               Wp_Pre_KSES_Less_Than_Callback'Access,
                               Text);
   end Wp_Pre_KSES_Less_Than;

   ------------------------------------
   -- Wp_Pre_KSES_Less_Than_Callback --
   ------------------------------------

   function Wp_Pre_KSES_Less_Than_Callback (Matches : List_Type)
                                            return String
   is
      use Php.Strings;
   begin
      if 0 = Strpos (Matches (1), ">") then -- false, [0]
         return ESC_HTML (Matches (1)); -- [0]
      end if;
      return Matches (1); -- [0]
   end Wp_Pre_KSES_Less_Than_Callback;

-- --
-- -- Removes non-allowable HTML from parsed block attribute values when filtering
-- -- in the post context.
-- --
-- -- @since 5.3.1
-- --
-- -- @param string         string            Content to be run through KSES.
-- -- @param array[]|string allowed_html      An array of allowed HTML elements
-- --                                          and attributes, or a context name
-- --                                          such as "post".
-- -- @param string[]       allowed_protocols Array of allowed URL protocols.
-- -- @return string Filtered text to run through KSES.
-- --
-- function wp_pre_kses_block_attributes( string, allowed_html, allowed_protocols ) then
--         /*
--         -- `filter_block_content` is expected to call `wp_kses`. Temporarily remove
--         -- the filter to avoid recursion.
--         --
--         remove_filter( "pre_kses", "wp_pre_kses_block_attributes", 10 );
--         string = filter_block_content( string, allowed_html, allowed_protocols );
--         add_filter( "pre_kses", "wp_pre_kses_block_attributes", 10, 3 );

--         return string;
-- end;

-- --
-- -- WordPress implementation of PHP sprintf() with filters.
-- --
-- -- @since 2.5.0
-- -- @since 5.3.0 Formalized the existing and already documented `...args` parameter
-- --              by adding it to the function signature.
-- --
-- -- @link https://www.php.net/sprintf
-- --
-- -- @param string pattern The string which formatted args are inserted.
-- -- @param mixed  ...args Arguments to be formatted into the pattern string.
-- -- @return string The formatted string.
-- --
-- function wp_sprintf( pattern, ...args ) then
--         len       = strlen( pattern );
--         start     = 0;
--         result    = "";
--         arg_index = 0;
--         while ( len > start ) then
--                 // Last character: append and break.
--                 if ( strlen( pattern ) - 1 == start ) then
--                         result .= substr( pattern, -1 );
--                         break;
--                 end;

--                 // Literal %: append and continue.
--                 if ( "%%" === substr( pattern, start, 2 ) ) then
--                         start  += 2;
--                         result .= "%";
--                         continue;
--                 end;

--                 // Get fragment before next %.
--                 end = strpos( pattern, "%", start + 1 );
--                 if ( false === end ) then
--                         end = len;
--                 end;
--                 fragment = substr( pattern, start, end - start );

--                 // Fragment has a specifier.
--                 if ( "%" === pattern[ start ] ) then
--                         // Find numbered arguments or take the next one in order.
--                         if ( preg_match( "/^%(\d+)\/", fragment, matches ) ) then
--                                 index    = matches[1] - 1; // 0-based array vs 1-based sprintf() arguments.
--                                 arg      = isset( args[ index ] ) ? args[ index ] : "";
--                                 fragment = str_replace( "%thenmatches[1]end;", "%", fragment );
--                         end; else then
--                                 arg = isset( args[ arg_index ] ) ? args[ arg_index ] : "";
--                                 ++arg_index;
--                         end;

--                         --
--                         -- Filters a fragment from the pattern passed to wp_sprintf().
--                         --
--                         -- If the fragment is unchanged, then sprintf() will be run on the fragment.
--                         --
--                         -- @since 2.5.0
--                         --
--                         -- @param string fragment A fragment from the pattern.
--                         -- @param string arg      The argument.
--                         --
--                         _fragment = apply_filters( "wp_sprintf", fragment, arg );
--                         if ( _fragment != fragment ) then
--                                 fragment = _fragment;
--                         end; else then
--                                 fragment = sprintf( fragment, (string) arg );
--                         end;
--                 end;

--                 // Append to result and move to next fragment.
--                 result .= fragment;
--                 start   = end;
--         end;

--         return result;
-- end;

-- --
-- -- Localizes list items before the rest of the content.
-- --
-- -- The "%l" must be at the first characters can then contain the rest of the
-- -- content. The list items will have ", ", ", and", and " and " added depending
-- -- on the amount of list items in the args parameter.
-- --
-- -- @since 2.5.0
-- --
-- -- @param string pattern Content containing "%l" at the beginning.
-- -- @param array  args    List items to prepend to the content and replace "%l".
-- -- @return string Localized list items and rest of the content.
-- --
-- function wp_sprintf_l( pattern, args ) then
--         // Not a match.
--         if ( "%l" !== substr( pattern, 0, 2 ) ) then
--                 return pattern;
--         end;

--         // Nothing to work with.
--         if ( empty( args ) ) then
--                 return "";
--         end;

--         --
--         -- Filters the translated delimiters used by wp_sprintf_l().
--         -- Placeholders (%s) are included to assist translators and then
--         -- removed before the array of strings reaches the filter.
--         --
--         -- Please note: Ampersands and entities should be avoided here.
--         --
--         -- @since 2.5.0
--         --
--         -- @param array delimiters An array of translated delimiters.
--         --
--         l = apply_filters(
--                 "wp_sprintf_l",
--                 array(
--                         /* translators: Used to join items in a list with more than 2 items.--
--                         "between"          => sprintf( __( "%1s, %2s" ), "", "" ),
--                         /* translators: Used to join last two items in a list with more than 2 times.--
--                         "between_last_two" => sprintf( __( "%1s, and %2s" ), "", "" ),
--                         /* translators: Used to join items in a list with only 2 items.--
--                         "between_only_two" => sprintf( __( "%1s and %2s" ), "", "" ),
--                 )
--         );

--         args   = (array) args;
--         result = array_shift( args );
--         if ( count( args ) == 1 ) then
--                 result .= l["between_only_two"] . array_shift( args );
--         end;

--         // Loop when more than two args.
--         i = count( args );
--         while ( i ) then
--                 arg = array_shift( args );
--                 i--;
--                 if ( 0 == i ) then
--                         result .= l["between_last_two"] . arg;
--                 end; else then
--                         result .= l["between"] . arg;
--                 end;
--         end;

--         return result . substr( pattern, 2 );
-- end;

   ---------------------
   -- Wp_HTML_Excerpt --
   ---------------------

   function Wp_HTML_Excerpt (Str   : String;
                             Count : Integer;
                             More  : String := "")
                             return String
   is
      use Php.Multibyte;
      use Php.Strings;
      use Php.Preg;

      Str_2   : constant String := Wp_Strip_All_Tags (Str, True);
      Excerpt : constant String := MB_Substr (Str_2, 0, Count);

      -- Remove part of an entity at the end.
      Excerpt_2 : constant String :=
        Preg_Replace ("/&[^;\s]{0,6}/", "", Excerpt);

      Excerpt_3 : constant String :=
        (if Str_2 /= Excerpt_2
         then Trim (Excerpt_2) & More
         else Excerpt_2);
   begin
      return Excerpt_3;
   end Wp_HTML_Excerpt;

-- --
-- -- Adds a base URL to relative links in passed content.
-- --
-- -- By default it supports the "src" and "href" attributes. However this can be
-- -- changed via the 3rd param.
-- --
-- -- @since 2.7.0
-- --
-- -- @global string _links_add_base
-- --
-- -- @param string content String to search for links in.
-- -- @param string base    The base URL to prefix to links.
-- -- @param array  attrs   The attributes which should be processed.
-- -- @return string The processed content.
-- --
-- function links_add_base_url( content, base, attrs = array( "src", "href" ) ) then
--         global _links_add_base;
--         _links_add_base = base;
--         attrs           = implode( "|", (array) attrs );
--         return preg_replace_callback( "!(attrs)=(["\"])(.+?)\\2!i", "_links_add_base", content );
-- end;

-- --
-- -- Callback to add a base URL to relative links in passed content.
-- --
-- -- @since 2.7.0
-- -- @access private
-- --
-- -- @global string _links_add_base
-- --
-- -- @param string m The matched link.
-- -- @return string The processed link.
-- --
-- function _links_add_base( m ) then
--         global _links_add_base;
--         // 1 = attribute name  2 = quotation mark  3 = URL.
--         return m[1] . "=" . m[2] .
--                 ( preg_match( "#^(\wthen1,20end;):#", m[3], protocol ) && in_array( protocol[1], wp_allowed_protocols(), true ) ?
--                         m[3] :
--                         WP_Http::make_absolute_url( m[3], _links_add_base )
--                 )
--                 . m[2];
-- end;

-- --
-- -- Adds a Target attribute to all links in passed content.
-- --
-- -- This function by default only applies to `<a>` tags, however this can be
-- -- modified by the 3rd param.
-- --
-- ----NOTE:* Any current target attributed will be stripped and replaced.
-- --
-- -- @since 2.7.0
-- --
-- -- @global string _links_add_target
-- --
-- -- @param string   content String to search for links in.
-- -- @param string   target  The Target to add to the links.
-- -- @param string[] tags    An array of tags to apply to.
-- -- @return string The processed content.
-- --
-- function links_add_target( content, target = "_blank", tags = array( "a" ) ) then
--         global _links_add_target;
--         _links_add_target = target;
--         tags              = implode( "|", (array) tags );
--         return preg_replace_callback( "!<(tags)((\s[^>]*)?)>!i", "_links_add_target", content );
-- end;

-- --
-- -- Callback to add a target attribute to all links in passed content.
-- --
-- -- @since 2.7.0
-- -- @access private
-- --
-- -- @global string _links_add_target
-- --
-- -- @param string m The matched link.
-- -- @return string The processed link.
-- --
-- function _links_add_target( m ) then
--         global _links_add_target;
--         tag  = m[1];
--         link = preg_replace( "|( target=([\""])(.*?)\2)|i", "", m[2] );
--         return "<" . tag . link . " target="" . esc_attr( _links_add_target ) . "">";
-- end;

-- --
-- -- Normalizes EOL characters and strips duplicate whitespace.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string str The string to normalize.
-- -- @return string The normalized string.
-- --
-- function normalize_whitespace( str ) then
--         str = trim( str );
--         str = str_replace( "\r", "\n", str );
--         str = preg_replace( array( "/\n+/", "/[ \t]+/" ), array( "\n", " " ), str );
--         return str;
-- end;

   -----------------------
   -- Wp_Strip_All_Tags --
   -----------------------

   function Wp_Strip_All_Tags (Item          : String;
                               Remove_Breaks : Boolean := False)
                               return String
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;

      Item_3 : constant String :=
        Preg_Replace ("@<(script|style)[^>]*?>.*?</\\1>@si", "", Item);

      Item_2 : constant String := Strip_Tags (Item_3);
      Item_1 : UString := +Item_2;
   begin
      if Remove_Breaks then
         Item_1 := +Preg_Replace ("/[\r\n\t ]+/", " ", Item_2);
      end if;

      return Trim (-Item_1);
   end Wp_Strip_All_Tags;

   -------------------------
   -- Sanitize_Text_Field --
   -------------------------

   function Sanitize_Text_Field (Str : String)
                                 return String
   is
      use Wp_Common;

      Filtered : constant String :=
        X_Sanitize_Text_Fields (Str, False);
   begin
      --
      -- Filters a sanitized text field string.
      --
      -- @since 2.9.0
      --
      -- @param string filtered The sanitized string.
      -- @param string str      The string prior to being sanitized.
      --
      return Apply_Filters ("sanitize_text_field", Filtered, Str);
   end Sanitize_Text_Field;

-- --
-- -- Sanitizes a multiline string from user input or from the database.
-- --
-- -- The function is like sanitize_text_field(), but preserves
-- -- new lines (\n) and other whitespace, which are legitimate
-- -- input in textarea elements.
-- --
-- -- @see sanitize_text_field()
-- --
-- -- @since 4.7.0
-- --
-- -- @param string str String to sanitize.
-- -- @return string Sanitized string.
-- --
-- function sanitize_textarea_field( str ) then
--         filtered = _sanitize_text_fields( str, true );

--         --
--         -- Filters a sanitized textarea field string.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string filtered The sanitized string.
--         -- @param string str      The string prior to being sanitized.
--         --
--         return apply_filters( "sanitize_textarea_field", filtered, str );
-- end;

   ---------------------------
   -- X_Sanitize_Text_Field --
   ---------------------------

   function X_Sanitize_Text_Fields (Str           : String;
                                    Keep_Newlines : Boolean := False)
                                    return String
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      -- if ( is_object( str ) || is_array( str ) ) then
      --    return "";
      -- end if;

      -- str = (string) str;

      Filtered : UString := +Wp_Check_Invalid_UTF8 (Str);
      Found    : Boolean := False;
      Match    : List_Type;
   begin
      if Strpos (-Filtered, "<") /= 0 then -- false
         Filtered := +Wp_Pre_KSES_Less_Than (-Filtered);
         -- This will strip extra whitespace for us.
         Filtered := +Wp_Strip_All_Tags (-Filtered, False);

         -- Use HTML entities in a special case to make sure no later
         -- newline stripping stage could lead to a functional tag.
         Filtered := +Str_Replace ("<\n", "&lt;\n", -Filtered);
      end if;

      if not Keep_Newlines then
         Filtered := +Preg_Replace ("/[\r\n\t ]+/", " ", -Filtered);
      end if;
      Filtered := +Trim (-Filtered);

      while Preg_Match ("/%[a-f0-9]{2}/i", -Filtered, Match) /= 0 loop
         Filtered := +Str_Replace (Match (1), "", -Filtered); -- [0]
         Found    := True;
      end loop;

      if Found then
         -- Strip out the whitespace that may now exist after removing the octets.
         Filtered := +Trim (Preg_Replace ("/ +/", " ", -Filtered));
      end if;

      return -Filtered;
   end X_Sanitize_Text_Fields;

   -----------------
   -- Wp_Basename --
   -----------------

   function Wp_Basename (Path   : String;
                         Suffix : String := "")
                         return String
   is
      use Php.Files;
      use Php.HTML;
      use Php.Strings;
   begin
      return
        URL_Decode (
          Basename (
            Str_Replace (List_Type'["%2F", "%5C"], "/",
                         URL_Encode (Path)),
            Suffix));
   end Wp_Basename;

-- // phpcs:disable WordPress.WP.CapitalPDangit.Misspelled, WordPress.NamingConventions.ValidFunctionName.FunctionNameInvalid -- 8-)
-- --
-- -- Forever eliminate "Wordpress" from the planet (or at least the little bit we can influence).
-- --
-- -- Violating our coding standards for a good function name.
-- --
-- -- @since 3.0.0
-- --
-- -- @param string text The text to be modified.
-- -- @return string The modified text.
-- --
-- function capital_P_dangit( text ) then
--         // Simple replacement for titles.
--         current_filter = current_filter();
--         if ( "the_title" === current_filter || "wp_title" === current_filter ) then
--                 return str_replace( "Wordpress", "WordPress", text );
--         end;
--         // Still here? Use the more judicious replacement.
--         static dblq = false;
--         if ( false === dblq ) then
--                 dblq = _x( "&#8220;", "opening curly double quote" );
--         end;
--         return str_replace(
--                 array( " Wordpress", "&#8216;Wordpress", dblq . "Wordpress", ">Wordpress", "(Wordpress" ),
--                 array( " WordPress", "&#8216;WordPress", dblq . "WordPress", ">WordPress", "(WordPress" ),
--                 text
--         );
-- end;
-- // phpcs:enable

-- --
-- -- Sanitizes a mime type
-- --
-- -- @since 3.1.3
-- --
-- -- @param string mime_type Mime type.
-- -- @return string Sanitized mime type.
-- --
-- function sanitize_mime_type( mime_type ) then
--         sani_mime_type = preg_replace( "/[^-+*.a-zA-Z0-9\/]/", "", mime_type );
--         --
--         -- Filters a mime type following sanitization.
--         --
--         -- @since 3.1.3
--         --
--         -- @param string sani_mime_type The sanitized mime type.
--         -- @param string mime_type      The mime type prior to sanitization.
--         --
--         return apply_filters( "sanitize_mime_type", sani_mime_type, mime_type );
-- end;

-- --
-- -- Sanitizes space or carriage return separated URLs that are used to send trackbacks.
-- --
-- -- @since 3.4.0
-- --
-- -- @param string to_ping Space or carriage return separated URLs
-- -- @return string URLs starting with the http or https protocol, separated by a carriage return.
-- --
-- function sanitize_trackback_urls( to_ping ) then
--         urls_to_ping = preg_split( "/[\r\n\t ]/", trim( to_ping ), -1, PREG_SPLIT_NO_EMPTY );
--         foreach ( urls_to_ping as k => url ) then
--                 if ( ! preg_match( "#^https?://.#i", url ) ) then
--                         unset( urls_to_ping[ k ] );
--                 end;
--         end;
--         urls_to_ping = array_map( "sanitize_url", urls_to_ping );
--         urls_to_ping = implode( "\n", urls_to_ping );
--         --
--         -- Filters a list of trackback URLs following sanitization.
--         --
--         -- The string returned here consists of a space or carriage return-delimited list
--         -- of trackback URLs.
--         --
--         -- @since 3.4.0
--         --
--         -- @param string urls_to_ping Sanitized space or carriage return separated URLs.
--         -- @param string to_ping      Space or carriage return separated URLs before sanitization.
--         --
--         return apply_filters( "sanitize_trackback_urls", urls_to_ping, to_ping );
-- end;

   --------------
   -- Wp_Slash --
   --------------

   function Wp_Slash (Value : String)
                      return String
   is
      use Php.Strings;
   begin
--    if ( is_array( value ) ) then
--       value = array_map( "wp_slash", value );
--    end if;

--    if ( is_string( value ) ) then
      return Add_Slashes (Value);
--    end if;

--    return Value;
   end Wp_Slash;

   ----------------
   -- Wp_Unslash --
   ----------------

   function Wp_Unslash (Value : String)
                        return String
   is
   begin
      return Strip_Slashes_Deep (Value);
   end Wp_Unslash;

-- --
-- -- Extracts and returns the first URL from passed content.
-- --
-- -- @since 3.6.0
-- --
-- -- @param string content A string which might contain a URL.
-- -- @return string|false The found URL.
-- --
-- function get_url_in_content( content ) then
--         if ( empty( content ) ) then
--                 return false;
--         end;

--         if ( preg_match( "/<a\s[^>]*?href=([\""])(.+?)\1/is", content, matches ) ) then
--                 return sanitize_url( matches[2] );
--         end;

--         return false;
-- end;

   ----------------------
   -- Wp_Spaces_Regexp --
   ----------------------

   Static_Spaces : UStrings.UString;

   function Wp_Spaces_Regexp
            return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;
   begin
      if Empty (Static_Spaces) then
         --
         -- Filters the regexp for common whitespace characters.
         --
         -- This string is substituted for the \s sequence as needed in regular
         -- expressions. For websites not written in English, different characters
         -- may represent whitespace. For websites not encoded in UTF-8, the 0xC2 0xA0
         -- sequence may not be in use.
         --
         -- @since 4.0.0
         --
         -- @param string spaces Regexp pattern for matching common whitespace
         --                      characters.
         --
         Static_Spaces :=
           +Apply_Filters ("wp_spaces_regexp", "[\r\n\t ]|\xC2\xA0|&nbsp;");
      end if;

      return -Static_Spaces;
   end Wp_Spaces_Regexp;

   ------------------------
   -- Print_Emoji_Styles --
   ------------------------

   Static_Printed : Boolean := False;

   procedure Print_Emoji_Styles is
      use Php.Echoing;
      use UStrings;
      use Inc_Themes;
   begin
      if Static_Printed then
         return;
      end if;
      Static_Printed := True;

      declare
         Type_Attr : constant String :=
           (if Current_Theme_Supports ("html5", "style")
            then ""
            else " type=""text/css""");
      begin
         Echo ("<style" & Type_Attr & ">" & NL);
         Echo ("img.wp-smiley," & NL);
         Echo ("img.emoji {" & NL);
         Echo ("        display: inline !important;" & NL);
         Echo ("        border: none !important;" & NL);
         Echo ("        box-shadow: none !important;" & NL);
         Echo ("        height: 1em !important;" & NL);
         Echo ("        width: 1em !important;" & NL);
         Echo ("        margin: 0 0.07em !important;" & NL);
         Echo ("        vertical-align: -0.1em !important;" & NL);
         Echo ("        background: none !important;" & NL);
         Echo ("        padding: 0 !important;" & NL);
         Echo ("}" & NL);
         Echo ("</style>" & NL);
      end;
   end Print_Emoji_Styles;

   ----------------------------------
   -- Print_Emoji_Detection_Script --
   ----------------------------------

   Static_Emoji_Detection_Printed : Boolean := False;

   procedure Print_Emoji_Detection_Script is
   begin
      if Static_Emoji_Detection_Printed then
         return;
      end if;

      Static_Emoji_Detection_Printed := True;

      X_Print_Emoji_Detection_Script;
   end Print_Emoji_Detection_Script;

   ------------------------------------
   -- X_Print_Emoji_Detection_Script --
   ------------------------------------

   procedure X_Print_Emoji_Detection_Script is
      use Php.Files;
      use Php.Strings;
      use Array_Lists;
      use Constants;
      use UStrings;
      use Wp_Common;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Script_Loader;

      Settings : Array_Type :=
        To_Array_Type
          ([
            --
            -- Filters the URL where emoji png images are hosted.
            --
            -- @since 4.2.0
            --
            -- @param string url The emoji base URL for png images.
            --
            Build
              ("baseUrl",
               Apply_Filters
                 ("emoji_url",
                  "https://s.w.org/images/core/emoji/14.0.0/72x72/")),

            --
            -- Filters the extension of the emoji png files.
            --
            -- @since 4.2.0
            --
            -- @param string extension The emoji extension for png files. Default .png.
            --
            Build ("ext", Apply_Filters ("emoji_ext", ".png")),

            --
            -- Filters the URL where emoji SVG images are hosted.
            --
            -- @since 4.6.0
            --
            -- @param string url The emoji base URL for svg images.
            --
            Build
              ("svgUrl",
               Apply_Filters
                 ("emoji_svg_url",
                  "https://s.w.org/images/core/emoji/14.0.0/svg/")),

            --
            -- Filters the extension of the emoji SVG files.
            --
            -- @since 4.6.0
            --
            -- @param string extension The emoji extension for svg files. Default .svg.
            --
            Build ("svgExt", Apply_Filters ("emoji_svg_ext", ".svg"))]);

      Version : constant String := "ver=" & Get_Bloginfo ("version");
   begin
      if SCRIPT_DEBUG then
         Set
           (Settings,
            "source",
            From_Array
              (To_Array_Type
                 ([
                   -- This filter is documented in wp-includes/class-wp-scripts.php
                   Build
                     ("wpemoji",
                      Apply_Filters
                        ("script_loader_src",
                         Includes_URL ("js/wp-emoji.js?" & Version),
                         "wpemoji")),
                   -- This filter is documented in wp-includes/class-wp-scripts.php
                   Build
                     ("twemoji",
                      Apply_Filters
                        ("script_loader_src",
                         Includes_URL ("js/twemoji.js?" & Version),
                         "twemoji"))])));
      else
         Set
           (Settings,
            "source",
            From_Array
              (To_Array_Type
                 ([
                   -- This filter is documented in wp-includes/class-wp-scripts.php
                   Build
                     ("concatemoji",
                      Apply_Filters
                        ("script_loader_src",
                         Includes_URL
                           ("js/wp-emoji-release.min.js?" & Version),
                         "concatemoji"))])));
      end if;

      Wp_Print_Inline_Script_Tag
        (Sprintf
           ("window._wpemojiSettings = %s;",
            [Wp_JSON_Encode (From_Array (Settings))])
         & "\n"
         & File_Get_Contents
             (Sprintf
                (ABSPATH
                 & (-Globals.WPINC)
                 & "/js/wp-emoji-loader"
                 & Wp_Scripts_Get_Suffix
                 & ".js",
                 [])));
   end X_Print_Emoji_Detection_Script;

-- --
-- -- Converts emoji characters to their equivalent HTML entity.
-- --
-- -- This allows us to store emoji in a DB using the utf8 character set.
-- --
-- -- @since 4.2.0
-- --
-- -- @param string content The content to encode.
-- -- @return string The encoded content.
-- --
-- function wp_encode_emoji( content ) then
--         emoji = _wp_emoji_list( "partials" );

--         foreach ( emoji as emojum ) then
--                 emoji_char = html_entity_decode( emojum );
--                 if ( false !== strpos( content, emoji_char ) ) then
--                         content = preg_replace( "/emoji_char/", emojum, content );
--                 end;
--         end;

--         return content;
-- end;

-- --
-- -- Converts emoji to a static img element.
-- --
-- -- @since 4.2.0
-- --
-- -- @param string text The content to encode.
-- -- @return string The encoded content.
-- --
-- function wp_staticize_emoji( text ) then
--         if ( false === strpos( text, "&#x" ) ) then
--                 if ( ( function_exists( "mb_check_encoding" ) && mb_check_encoding( text, "ASCII" ) ) || ! preg_match( "/[^\x00-\x7F]/", text ) ) then
--                         // The text doesn"t contain anything that might be emoji, so we can return early.
--                         return text;
--                 end; else then
--                         encoded_text = wp_encode_emoji( text );
--                         if ( encoded_text === text ) then
--                                 return encoded_text;
--                         end;

--                         text = encoded_text;
--                 end;
--         end;

--         emoji = _wp_emoji_list( "entities" );

--         // Quickly narrow down the list of emoji that might be in the text and need replacing.
--         possible_emoji = array();
--         foreach ( emoji as emojum ) then
--                 if ( false !== strpos( text, emojum ) ) then
--                         possible_emoji[ emojum ] = html_entity_decode( emojum );
--                 end;
--         end;

--         if ( ! possible_emoji ) then
--                 return text;
--         end;

--         -- This filter is documented in wp-includes/formatting.php--
--         cdn_url = apply_filters( "emoji_url", "https://s.w.org/images/core/emoji/14.0.0/72x72/" );

--         -- This filter is documented in wp-includes/formatting.php--
--         ext = apply_filters( "emoji_ext", ".png" );

--         output = "";
--         /*
--         -- HTML loop taken from smiley function, which was taken from texturize function.
--         -- It"ll never be consolidated.
--         --
--         -- First, capture the tags as well as in between.
--         --
--         textarr = preg_split( "/(<.*>)/U", text, -1, PREG_SPLIT_DELIM_CAPTURE );
--         stop    = count( textarr );

--         // Ignore processing of specific tags.
--         tags_to_ignore       = "code|pre|style|script|textarea";
--         ignore_block_element = "";

--         for ( i = 0; i < stop; i++ ) then
--                 content = textarr[ i ];

--                 // If we"re in an ignore block, wait until we find its closing tag.
--                 if ( "" === ignore_block_element && preg_match( "/^<(" . tags_to_ignore . ")>/", content, matches ) ) then
--                         ignore_block_element = matches[1];
--                 end;

--                 // If it"s not a tag and not in ignore block.
--                 if ( "" === ignore_block_element && strlen( content ) > 0 && "<" !== content[0] && false !== strpos( content, "&#x" ) ) then
--                         foreach ( possible_emoji as emojum => emoji_char ) then
--                                 if ( false === strpos( content, emojum ) ) then
--                                         continue;
--                                 end;

--                                 file = str_replace( ";&#x", "-", emojum );
--                                 file = str_replace( array( "&#x", ";" ), "", file );

--                                 entity = sprintf( "<img src="%s" alt="%s" class="wp-smiley" style="height: 1em; max-height: 1em;" />", cdn_url . file . ext, emoji_char );

--                                 content = str_replace( emojum, entity, content );
--                         end;
--                 end;

--                 // Did we exit ignore block?
--                 if ( "" !== ignore_block_element && "</" . ignore_block_element . ">" === content ) then
--                         ignore_block_element = "";
--                 end;

--                 output .= content;
--         end;

--         // Finally, remove any stray U+FE0F characters.
--         output = str_replace( "&#xfe0f;", "", output );

--         return output;
-- end;

-- --
-- -- Converts emoji in emails into static images.
-- --
-- -- @since 4.2.0
-- --
-- -- @param array mail The email data array.
-- -- @return array The email data array, with emoji in the message staticized.
-- --
-- function wp_staticize_emoji_for_email( mail ) then
--         if ( ! isset( mail["message"] ) ) then
--                 return mail;
--         end;

--         /*
--         -- We can only transform the emoji into images if it"s a `text/html` email.
--         -- To do that, here"s a cut down version of the same process that happens
--         -- in wp_mail() - get the `Content-Type` from the headers, if there is one,
--         -- then pass it through the {@see "wp_mail_content_type"} filter, in case
--         -- a plugin is handling changing the `Content-Type`.
--         --
--         headers = array();
--         if ( isset( mail["headers"] ) ) then
--                 if ( is_array( mail["headers"] ) ) then
--                         headers = mail["headers"];
--                 end; else then
--                         headers = explode( "\n", str_replace( "\r\n", "\n", mail["headers"] ) );
--                 end;
--         end;

--         foreach ( headers as header ) then
--                 if ( strpos( header, ":" ) === false ) then
--                         continue;
--                 end;

--                 // Explode them out.
--                 list( name, content ) = explode( ":", trim( header ), 2 );

--                 // Cleanup crew.
--                 name    = trim( name );
--                 content = trim( content );

--                 if ( "content-type" === strtolower( name ) ) then
--                         if ( strpos( content, ";" ) !== false ) then
--                                 list( type, charset ) = explode( ";", content );
--                                 content_type           = trim( type );
--                         end; else then
--                                 content_type = trim( content );
--                         end;
--                         break;
--                 end;
--         end;

--         // Set Content-Type if we don"t have a content-type from the input headers.
--         if ( ! isset( content_type ) ) then
--                 content_type = "text/plain";
--         end;

--         -- This filter is documented in wp-includes/pluggable.php--
--         content_type = apply_filters( "wp_mail_content_type", content_type );

--         if ( "text/html" === content_type ) then
--                 mail["message"] = wp_staticize_emoji( mail["message"] );
--         end;

--         return mail;
-- end;

-- --
-- -- Returns arrays of emoji data.
-- --
-- -- These arrays are automatically built from the regex in twemoji.js - if they need to be updated,
-- -- you should update the regex there, then run the `npm run grunt precommit:emoji` job.
-- --
-- -- @since 4.9.0
-- -- @access private
-- --
-- -- @param string type Optional. Which array type to return. Accepts "partials" or "entities", default "entities".
-- -- @return array An array to match all emoji that WordPress recognises.
-- --
-- function _wp_emoji_list( type = "entities" ) then
--         // Do not remove the START/END comments - they"re used to find where to insert the arrays.

--         // START: emoji arrays

-- !! Two very long lines removed here jq

--         // END: emoji arrays

--         if ( "entities" === type ) then
--                 return entities;
--         end;

--         return partials;
-- end;

-- --
-- -- Shortens a URL, to be used as link text.
-- --
-- -- @since 1.2.0
-- -- @since 4.4.0 Moved to wp-includes/formatting.php from wp-admin/includes/misc.php and added length param.
-- --
-- -- @param string url    URL to shorten.
-- -- @param int    length Optional. Maximum length of the shortened URL. Default 35 characters.
-- -- @return string Shortened URL.
-- --
-- function url_shorten( url, length = 35 ) then
--         stripped  = str_replace( array( "https://", "http://", "www." ), "", url );
--         short_url = untrailingslashit( stripped );

--         if ( strlen( short_url ) > length ) then
--                 short_url = substr( short_url, 0, length - 3 ) . "&hellip;";
--         end;
--         return short_url;
-- end;

-- --
-- -- Sanitizes a hex color.
-- --
-- -- Returns either "", a 3 or 6 digit hex color (with #), or nothing.
-- -- For sanitizing values without a #, see sanitize_hex_color_no_hash().
-- --
-- -- @since 3.4.0
-- --
-- -- @param string color
-- -- @return string|void
-- --
-- function sanitize_hex_color( color ) then
--         if ( "" === color ) then
--                 return "";
--         end;

--         // 3 or 6 hex digits, or the empty string.
--         if ( preg_match( "|^#([A-Fa-f0-9]then3end;)then1,2end;|", color ) ) then
--                 return color;
--         end;
-- end;

-- --
-- -- Sanitizes a hex color without a hash. Use sanitize_hex_color() when possible.
-- --
-- -- Saving hex colors without a hash puts the burden of adding the hash on the
-- -- UI, which makes it difficult to use or upgrade to other color types such as
-- -- rgba, hsl, rgb, and HTML color names.
-- --
-- -- Returns either "", a 3 or 6 digit hex color (without a #), or null.
-- --
-- -- @since 3.4.0
-- --
-- -- @param string color
-- -- @return string|null
-- --
-- function sanitize_hex_color_no_hash( color ) then
--         color = ltrim( color, "#" );

--         if ( "" === color ) then
--                 return "";
--         end;

--         return sanitize_hex_color( "#" . color ) ? color : null;
-- end;

-- --
-- -- Ensures that any hex color is properly hashed.
-- -- Otherwise, returns value untouched.
-- --
-- -- This method gshould only be necessary if using sanitize_hex_color_no_hash().
-- --
-- -- @since 3.4.0
-- --
-- -- @param string color
-- -- @return string
-- --
-- function maybe_hash_hex_color( color ) then
--         unhashed = sanitize_hex_color_no_hash( color );
--         if ( unhashed ) then
--                 return "#" . unhashed;
--         end;

--         return color;
-- end;

end Inc_Formatting;
