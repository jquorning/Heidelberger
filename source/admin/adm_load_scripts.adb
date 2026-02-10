--
-- Disable error reporting.
--
-- Set this to error_reporting( -1 ) for debugging.
--

with Php.Echoing;
with Php.Errors;
with Php.HTML;
with Php.Lists;
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

with Class_Dependency;
with Class_Scripts;
with Inc_Script_Loader;
with Inc_Versions;
-- require ABSPATH . "wp-admin/includes/noop.php";
-- require ABSPATH . WPINC . "/script-loader.php";
-- require ABSPATH . WPINC . "/version.php";

package body Adm_Load_Scripts
is
   use Arrays;
   use Lists;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use Binder;
      use Constants;
      use Globals;
      use UStrings;
      use Inc_Script_Loader;

      Protocol : UString;
      Load     : UString;
      Outt     : UString;
      Load_2   : List_Type;
      Wp_Scripts : Class_Scripts.Wp_Scripts := Class_Scripts.X_Construct;
      Expires_Offset : Natural;
   begin
      Error_Reporting (ERROR_NONE);

-- Set ABSPATH for execution.
-- if ( ! defined( 'ABSPATH' ) ) then
--         define( 'ABSPATH', dirname( __DIR__ ) . '/' );
-- end;

      WPINC := +"wp-includes";

      Protocol := +Get_As_String (X_SERVER, "SERVER_PROTOCOL");
      if
        not In_List (-Protocol,
                     ["HTTP/1.1", "HTTP/2", "HTTP/2.0", "HTTP/3"], True)
      then
         Protocol := +"HTTP/1.0";
      end if;

      Load := +Get_As_String (XX_GET, "load");
-- if ( is_array( load ) ) then
--         ksort( load );
--         load = implode( "", load );
-- end;

      Load   := +Preg_Replace ("/[^a-z0-9,_-]+/i", "", -Load);
      Load_2 := List_Unique (Explode (",", -Load));

      if Empty (-Load) then
         Header (-Protocol & " 400 Bad Request");
         return; -- exit;
      end if;

      Expires_Offset := 31536000; -- 1 year.
      Outt           := Null_UString;

      Wp_Default_Scripts          (Wp_Scripts);
      Wp_Default_Packages_Vendor  (Wp_Scripts);
      Wp_Default_Packages_Scripts (Wp_Scripts);

      if
        Isset (X_SERVER, "HTTP_IF_NONE_MATCH") and then
        Strip_Slashes (Get_As_String (X_SERVER, "HTTP_IF_NONE_MATCH")) =
        Inc_Versions.Wp_Version
      then
         Header (-Protocol & " 304 Not Modified");
         return; -- exit;
      end if;

      for Handle of Load_2 loop
         declare
            use Class_Dependency.Dependency_Maps;

            Path : UString;
         begin
            if not Has_Element (Wp_Scripts.Registered.Find (Handle)) then
               goto Continue;
            end if;

            Path := ABSPATH & Wp_Scripts.Registered (Handle).Src;
            Append (Outt, Adi_Noop.Get_File (-Path) & NL);
         end;
         << Continue >>
      end loop;

      Header ("Etag: " & Inc_Versions.Wp_Version);
      Header ("Content-Type: application/javascript; charset=UTF-8");
--    Header ("Expires: " & gmdate( "D, d M Y H:i:s", time() + Expires_offset ) & " GMT" );
      Header ("Cache-Control: public, max-age=" & Helpers.Image (Expires_Offset));

      Echo (-Outt);
      -- exit;
   end Run;

end Adm_Load_Scripts;
