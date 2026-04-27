--
-- WordPress Options Administration API.
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Php.Echoing;

with Arrays;
with UStrings;

with Inc_Functions;
with Inc_Link_Templates;

package body Adi_Options is
   use Arrays;

   -- --
   -- -- Output JavaScript to toggle display of additional settings if avatars are disabled.
   -- --
   -- -- @since 4.2.0
   -- --
   -- function options_discussion_add_js() then
   --         ?>
   --         <script>
   --         (function()then
   --                 var parent = ( "#show_avatars" ),
   --                         children = ( ".avatar-settings" );
   --                 parent.on( "change", function()then
   --                         children.toggleClass( "hide-if-js", ! this.checked );
   --                 end;);
   --         end;)(jQuery);
   --         </script>
   --         <?php
   -- end;

   --
   -- Display JavaScript on the page.
   --
   -- @since 3.5.0
   --
   procedure Options_General_Add_JS is
      use Php.Echoing;
      use UStrings;
      use Inc_Functions;
      use Inc_Link_Templates;

      procedure E (Item : String);

      procedure E (Item : String) is
      begin
         Echo (Item & NL);
      end E;

   begin
      E ("<script type=""text/javascript"">");
      E ("        jQuery( function($) {");
      E
        ("                var $siteName = $( '#wp-admin-bar-site-name' ).children( 'a' ).first(),");
      E
        ("                        siteIconPreview = $('#site-icon-preview-site-title'),");
      E
        ("                        homeURL = ( "
         & Wp_JSON_Encode (From_String (Get_Home_URL))
         & " || '' ).replace( /^(https?:\/\/)?(www\.)?/, '' );");
      E ("");
      E ("                $( '#blogname' ).on( 'input', function() {");
      E
        ("                        var title = $.trim( $( this ).val() ) || homeURL;");
      E ("");
      E ("                        // Truncate to 40 characters.");
      E ("                        if ( 40 < title.length ) {");
      E
        ("                                title = title.substring( 0, 40 ) + '\u2026';");
      E ("                        }");
      E ("");
      E ("                        siteName.text( title );");
      E ("                        siteIconPreview.text( title );");
      E ("                });");
      E ("");
      E
        ("                $( 'input[name=""date_format""]' ).on( 'click', function() {");
      E
        ("                        if ( 'date_format_custom_radio' !== $(this).attr( 'id' ) )");
      E
        ("                                $( 'input[name='date_format_custom']' ).val( $( this ).val() ).closest( 'fieldset' ).find( '.example' ).text( $( this ).parent( 'label' ).children( '.format-i18n' ).text() );");
      E ("                });");
      E ("");
      E
        ("                $( 'input[name=""date_format_custom""]' ).on( 'click input', function() {");
      E
        ("                        $( '#date_format_custom_radio' ).prop( 'checked', true );");
      E ("                });");
      E ("");
      E
        ("                $( 'input[name=""time_format""]' ).on( 'click', function() {");
      E
        ("                        if ( 'time_format_custom_radio' !== $(this).attr( 'id' ) )");
      E
        ("                                $( 'input[name=""time_format_custom""]' ).val( $( this ).val() ).closest( 'fieldset' ).find( '.example' ).text( $( this ).parent( 'label' ).children( '.format-i18n' ).text() );");
      E ("                });");
      E ("");
      E
        ("                $( 'input[name=""time_format_custom""]' ).on( 'click input', function() {");
      E
        ("                        $( '#time_format_custom_radio' ).prop( 'checked', true );");
      E ("                });");
      E ("");
      E
        ("                $( 'input[name=""date_format_custom""], input[name=""time_format_custom""]' ).on( 'input', function() {");
      E ("                        var format = $( this ),");
      E
        ("                                fieldset = format.closest( 'fieldset' ),");
      E
        ("                                example = fieldset.find( '.example' ),");
      E
        ("                                spinner = fieldset.find( '.spinner' );");
      E ("");
      E
        ("                        // Debounce the event callback while users are typing.");
      E ("                        clearTimeout( $.data( this, 'timer' ) );");
      E
        ("                        $( this ).data( 'timer', setTimeout( function() {");
      E ("                                // If custom date is not empty.");
      E ("                                if ( format.val() ) {");
      E
        ("                                        spinner.addClass( 'is-active' );");
      E ("");
      E ("                                        $.post( ajaxurl, {");
      E
        ("                                                action: 'date_format_custom' === format.attr( 'name' ) ? 'date_format' : 'time_format',");
      E
        ("                                                date    : format.val()");
      E
        ("                                        }, function( d ) { spinner.removeClass( 'is-active' ); example.text( d ); } );");
      E ("                                }");
      E ("                        }, 500 ) );");
      E ("                } );");
      E (TAB0);
      E (TAB2 & "                var languageSelect = $( '#WPLANG' );");
      E (TAB2 & "                $( 'form' ).on( 'submit', function() {");
      E (TAB3 & "                        /*");
      E
        (TAB3 & "                         * Don't show a spinner for English and installed languages,");
      E (TAB3 & "                         * as there is nothing to download.");
      E (TAB3 & "                         */");
      E
        (TAB3 & "                        if ( ! languageSelect.find( 'option:selected' ).data( 'installed' ) ) {");
      E
        (TAB4 & "                                $( '#submit', this ).after( '<span class=""spinner language-install-spinner is-active"" />' );");
      E (TAB3 & "                        }");
      E (TAB2 & "                });");
      E (TAB1 & "        } );");
      E (TAB0 & "</script>");
   end Options_General_Add_JS;

   -- --
   -- -- Display JavaScript on the page.
   -- --
   -- -- @since 3.5.0
   -- --
   -- function options_reading_add_js() then
   --         ?>
   -- <script type="text/javascript">
   --         jQuery( function() then
   --                 var section = ("#front-static-pages"),
   --                         staticPage = section.find("input:radio[value="page"]"),
   --                         selects = section.find("select"),
   --                         check_disabled = function()then
   --                                 selects.prop( "disabled", ! staticPage.prop("checked") );
   --                         end;;
   --                 check_disabled();
   --                 section.find( "input:radio" ).on( "change", check_disabled );
   --         end; );
   -- </script>
   --         <?php
   -- end;

   -- --
   -- -- Render the site charset setting.
   -- --
   -- -- @since 3.5.0
   -- --
   -- function options_reading_blog_charset() then
   --         echo "<input name="blog_charset" type="text" id="blog_charset" value="" . esc_attr( get_option( "blog_charset" ) ) . "" class="regular-text" />";
   --         echo "<p class="description">" . __( "The <a href="https://wordpress.org/documentation/article/wordpress-glossary/#character-set">character encoding</a> of your site (UTF-8 is recommended)" ) . "</p>";
   -- end;

end Adi_Options;
