--
-- WordPress Administration Update API
--
-- @package WordPress
-- @subpackage Administration
--

with Wp_Common;

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

   ----------------------------------------
   -- Wp_Is_Auto_Update_Enabled_For_Type --
   ----------------------------------------

   function Wp_Is_Auto_Update_Enabled_For_Type (Typ : String)
                                                return Boolean
   is
      use Wp_Common;

      -- if ( ! class_exists( "WP_Automatic_Updater" ) ) then
      --    require_once ABSPATH . "wp-admin/includes/class-wp-automatic-updater.php";
      -- end if;

--    updater = new WP_Automatic_Updater();
      Enabled : Boolean := not False; -- updater.is_disabled();
   begin
      if  Typ in "plugin" then
         --
         -- Filters whether plugins auto-update is enabled.
         --
         -- @since 5.5.0
         --
         -- @param bool enabled True if plugins auto-update is enabled, false otherwise.
         --
         return Apply_Filters ("plugins_auto_update_enabled", Enabled);
      elsif Typ in "theme" then
         --
         -- Filters whether themes auto-update is enabled.
         --
         -- @since 5.5.0
         --
         -- @param bool enabled True if themes auto-update is enabled, false otherwise.
         --
         return Apply_Filters ("themes_auto_update_enabled", Enabled);
      end if;

      return False;
   end Wp_Is_Auto_Update_Enabled_For_Type;

end Adi_Update;
