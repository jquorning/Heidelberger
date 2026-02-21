--
-- WordPress Administration Update API
--
-- @package WordPress
-- @subpackage Administration
--

package body Adi_Update
is

   ------------------------------
   -- Update_Right_Now_Message --
   ------------------------------

   procedure Update_Right_Now_Message
   is
   begin
      raise Program_Error with "not implemented";
   end Update_Right_Now_Message;

--         theme_name = wp_get_theme();
--         if ( current_user_can( "switch_themes" ) ) then
--                 theme_name = sprintf( "<a href="themes.php">%1s</a>", theme_name );
--         end;

--         msg = "";

--         if ( current_user_can( "update_core" ) ) then
--                 cur = get_preferred_from_update_core();

--                 if ( isset( cur.response ) && "upgrade" === cur.response ) then
--                         msg .= sprintf(
--                                 "<a href="%s" class="button" aria-describedby="wp-version">%s</a> ",
--                                 network_admin_url( "update-core.php" ),
--                                 /* translators: %s: WordPress version number, or "Latest" string.--
--                                 sprintf( __( "Update to %s" ), cur.current ? cur.current : __( "Latest" ) )
--                         );
--                 end;
--         end;

--         /* translators: 1: Version number, 2: Theme name.--
--         content = __( "WordPress %1s running %2s theme." );

--         --
--         -- Filters the text displayed in the "At a Glance" dashboard widget.
--         --
--         -- Prior to 3.8.0, the widget was named "Right Now".
--         --
--         -- @since 4.4.0
--         --
--         -- @param string content Default text.
--         --
--         content = apply_filters( "update_right_now_text", content );

--         msg .= sprintf( "<span id="wp-version">" . content . "</span>", get_bloginfo( "version", "display" ), theme_name );

--         echo "<p id="wp-version-message">msg</p>";
-- end;

end Adi_Update;
