--
--
--

with Php.Echoing;
with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Preg;
with Php.Strings;

with Arrays;
with Binder;
with Constants;
with Globals;
with Helpers;
with UStrings;
with Lists;

with Adi_Noop;
-- with Class_Styles;
with Class_Dependency;
with Inc_Script_Loader;
with Inc_Versions;
-- require ABSPATH . 'wp-admin/includes/noop.php';
-- require ABSPATH . WPINC . '/theme.php';
-- require ABSPATH . WPINC . '/class-wp-theme-json-resolver.php';
-- require ABSPATH . WPINC . '/global-styles-and-settings.php';
-- require ABSPATH . WPINC . '/script-loader.php';
-- require ABSPATH . WPINC . '/version.php';

package body Adm_Load_Styles
is
   use Lists;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Arrays;
      use Binder;
      use Globals;
      use Constants;
      use Helpers;
      use UStrings;
      use Php.Echoing;
      use Php.HTML;
      use Php.Lists;
      use Php.Misc;
      use Php.Preg;
      use Php.Strings;
      use Class_Dependency;

      Protocol : UString;
      Load     : UString;
      Load_2   : List_Type;
      RTL      : Boolean;
      Outt     : UString;

      Wp_Styles : Class_Styles.Wp_Styles;

      Expires_Offset : Natural;
   begin
-- --
-- -- Disable error reporting.
-- --
-- -- Set this to error_reporting( -1 ) for debugging.
-- --
-- error_reporting( 0 );

-- -- Set ABSPATH for execution.
-- if ( ! defined( 'ABSPATH' ) ) {
--         define( 'ABSPATH', dirname( __DIR__ ) . '/' );
-- }

      WPINC          := +"wp-includes";
      WP_CONTENT_DIR := +ABSPATH & "wp-content";

      Protocol := +As_String (Get (X_SERVER, "SERVER_PROTOCOL"));
      if not In_List (-Protocol, List_Type'["HTTP/1.1", "HTTP/2",
                                            "HTTP/2.0", "HTTP/3"], True)
      then
         Protocol := +"HTTP/1.0";
      end if;

      Load := +As_String (Get (XX_GET, "load"));
-- if ( is_array( load ) ) then
--         ksort( load );
--         load := implode( "", load );
-- end;

      Load   := +Preg_Replace ("/[^a-z0-9,_-]+/i", "", -Load);
      Load_2 := List_Unique (Explode (",", -Load));

      if Empty (-Load) then
         Header ((-Protocol) & " 400 Bad Request");
         return; -- exit;
      end if;

      RTL            := Isset (XX_GET, "dir") and then
                        "rtl" = Get_As_String (XX_GET, "dir");
      Expires_Offset := 31536000; -- 1 year.
      Outt           := +"";

      Inc_Script_Loader.Wp_Default_Styles (Wp_Styles);

      if
        Isset (X_SERVER, "HTTP_IF_NONE_MATCH") and then
        Strip_Slashes (Get_As_String (X_SERVER, "HTTP_IF_NONE_MATCH")) =
        Inc_Versions.Wp_Version
      then
         Header ((-Protocol) & " 304 Not Modified");
         return; -- exit;
      end if;

      for Handle of Load_2 loop
         declare
            use Dependency_Maps;

            Style   : X_Wp_Dependency renames Wp_Styles.Registered (Handle);
            Content : UString;
            Path    : UString;
         begin

            if not Has_Element (Wp_Styles.Registered.Find (Handle)) then
--          if not Array_Key_Exists (-Handle, Wp_Styles.Registered) then
               goto Continue;
            end if;

            if Empty (-Style.Src) then
               goto Continue;
            end if;

            Path := ABSPATH & Style.Src;

            if RTL and then not Empty (Style.Extra ("rtl")) then
               -- All default styles have fully independent RTL files.
               Path := +Str_Replace (".min.css", "-rtl.min.css", -Path);
            end if;

            Content := +Adi_Noop.Get_File (-Path) & NL; -- "\n";

            if Strpos (-Style.Src, "/" & (-WPINC) & "/css/") = 0 then

               Content := +Str_Replace (
                             "../images/", "../" & (-WPINC) & "/images/",
                             -Content);

               Content := +Str_Replace (
                             "../js/tinymce/", "../" & (-WPINC) & "/js/tinymce/",
                             -Content);

               Content := +Str_Replace (
                             "../fonts/", "../" & (-WPINC) & "/fonts/",
                             -Content);
               Append (Outt, Content);
            else
               Append (Outt, Str_Replace ("../images/", "images/", -Content));
            end if;
         end;
         << Continue >>
      end loop;

      Header ("Etag: " & Inc_Versions.Wp_Version);
      Header ("Content-Type: text/css; charset=UTF-8");
      Header ("Expires: " &
              GMdate ("D, d M Y H:i:s", Time + Expires_Offset) &
              " GMT");
      Header ("Cache-Control: public, max-age=" & Image (Expires_Offset));

      Echo (-Outt);
   end Run;

end Adm_Load_Styles;
