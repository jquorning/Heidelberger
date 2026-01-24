--
-- Disable error reporting.
--
-- Set this to error_reporting( -1 ) for debugging.
--

with UStrings;

package Adm_Load_Scripts
is
   use UStrings;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      Protocol : Unbounded_String;
      Load     : Unbounded_String;
      Expires_Offset : Natural;
      Outt     : Unbounded_String;
   begin
      Error_Reporting (0);

-- Set ABSPATH for execution.
-- if ( ! defined( 'ABSPATH' ) ) then
--         define( 'ABSPATH', dirname( __DIR__ ) . '/' );
-- end;

      WPINC := +"wp-includes";

      Protocol := Get (X_SERVER, "SERVER_PROTOCOL");
      if
        not In_Array (-Protocol,
                      To_List (List => (+"HTTP/1.1", +"HTTP/2",
                                        +"HTTP/2.0", +"HTTP/3")), True)
      then
         Protocol := +"HTTP/1.0";
      end if;

      Load := +Get (XX_GET, "load");
-- if ( is_array( load ) ) then
--         ksort( load );
--         load = implode( "", load );
-- end;

      Load := +Preg_Replace ("/[^a-z0-9,_-]+/i", "", -Load);
      Load := +Array_Unique (Explode (",", -Load));

      if Empty (-Load) then
         Header (Protocol & " 400 Bad Request" );
         return; -- exit;
      end;

-- require ABSPATH . "wp-admin/includes/noop.php";
-- require ABSPATH . WPINC . "/script-loader.php";
-- require ABSPATH . WPINC . "/version.php";

      Expires_Offset := 31536000; -- 1 year.
      outt           := +"";

      wp_scripts = new WP_Scripts();
      Wp_Default_Scripts          (Wp_Scripts);
      Wp_Default_Packages_Vendor  (Wp_Scripts);
      Wp_Default_Packages_Scripts (Wp_Scripts);

      if
        Isset (X_SERVER, "HTTP_IF_NONE_MATCH") and then
        Stripslashes (Get (X_SERVER, "HTTP_IF_NONE_MATCH")) = Wp_Version
      then
         Header (Protocol & " 304 Not Modified");
         return; -- exit;
      end if;

      for Handle of Load loop
         if not Array_Key_Exists (-handle, Wp_Scripts.Registered) then
            goto Continue;
         end if;

         Path := ABSPATH & Wp_Scripts.Registered (Handle).Src;
         Append (Outt, Get_File (Path) & Nl;
      end loop;

      Header ("Etag: " & Wp_Version);
      Header ("Content-Type: application/javascript; charset=UTF-8" );
--    Header ("Expires: " & gmdate( "D, d M Y H:i:s", time() + Expires_offset ) & " GMT" );
      Header ("Cache-Control: public, max-age=" & Expires_Offset'Image);

      Echo (-Outt);
      -- exit;
   end Run;

end Adm_Load_Scripts;
