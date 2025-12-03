--
-- Disable error reporting.
--
-- Set this to error_reporting( -1 ) for debugging.
--

with Ada.Strings.Unbounded;

with Arrays;
with Binder;
with Hb_Common;
with Globals;
with Lists;
with Php;

with Adi_Noop;

with Inc_Class_Wp_Dependency;
with Inc_Class_Wp_Scripts;
with Inc_Script_Loader;
with Inc_Versions;
-- require ABSPATH . "wp-admin/includes/noop.php";
-- require ABSPATH . WPINC . "/script-loader.php";
-- require ABSPATH . WPINC . "/version.php";

package body Adm_Load_Scripts
is
   use Lists;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Ada.Strings.Unbounded;
      use Arrays;
      use Binder;
      use Globals;
      use Hb_Common;
      use Php;
      use Inc_Script_Loader;

      Protocol : Unbounded_String;
      Load     : Unbounded_String;
      Outt     : Unbounded_String;
      Load_2   : List_Type;
      Wp_Scripts : Inc_Class_Wp_Scripts.Wp_Scripts;
      Expires_Offset : Natural;
   begin
      Error_Reporting (0);

-- Set ABSPATH for execution.
-- if ( ! defined( 'ABSPATH' ) ) then
--         define( 'ABSPATH', dirname( __DIR__ ) . '/' );
-- end;

      WPINC := +"wp-includes";

      Protocol := +As_String (Get (X_SERVER, "SERVER_PROTOCOL"));
      if
        not In_Array (-Protocol,
                      To_List (List => (+"HTTP/1.1", +"HTTP/2",
                                        +"HTTP/2.0", +"HTTP/3")), True)
      then
         Protocol := +"HTTP/1.0";
      end if;

      Load := +As_String (Get (XX_GET, "load"));
-- if ( is_array( load ) ) then
--         ksort( load );
--         load = implode( "", load );
-- end;

      Load   := +Preg_Replace ("/[^a-z0-9,_-]+/i", "", -Load);
      Load_2 := Array_Unique (Explode (",", -Load));

      if Empty (-Load) then
         Header (-Protocol & " 400 Bad Request");
         return; -- exit;
      end if;

      Expires_Offset := 31536000; -- 1 year.
      Outt           := +"";

      Wp_Default_Scripts          (Wp_Scripts);
      Wp_Default_Packages_Vendor  (Wp_Scripts);
      Wp_Default_Packages_Scripts (Wp_Scripts);

      if
        Isset (X_SERVER, "HTTP_IF_NONE_MATCH") and then
        Stripslashes (As_String (Get (X_SERVER, "HTTP_IF_NONE_MATCH"))) = Inc_Versions.Wp_Version
      then
         Header (-Protocol & " 304 Not Modified");
         return; -- exit;
      end if;

      for Handle of Load_2 loop
         declare
            use Inc_Class_Wp_Dependency.Dependency_Maps;

            Path : Unbounded_String;
         begin
            if not Has_Element (Wp_Scripts.Registered.Find (-Handle)) then
               goto Continue;
            end if;

            Path := ABSPATH & Wp_Scripts.Registered (-Handle).Src;
            Append (Outt, Adi_Noop.Get_File (-Path) & NL);
         end;
         << Continue >>
      end loop;

      Header ("Etag: " & Inc_Versions.Wp_Version);
      Header ("Content-Type: application/javascript; charset=UTF-8");
--    Header ("Expires: " & gmdate( "D, d M Y H:i:s", time() + Expires_offset ) & " GMT" );
      Header ("Cache-Control: public, max-age=" & Expires_Offset'Image);

      Echo (-Outt);
      -- exit;
   end Run;

end Adm_Load_Scripts;
