--
-- WordPress Administration Template Footer
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Hb_Common;
with Globals;
with Lists;
with Php;

with Inc_L10n;
with Inc_Plugins;

-- -- Don't load directly.
-- if ( ! defined( 'ABSPATH' ) ) {
--         die( '-1' );
-- }

package body Adm_Admin_Footer
is
   use Ada.Strings.Unbounded;
   use Hb_Common;
   use Lists;
   use Php;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Inc_L10n;
      use Inc_Plugins;
      --
      -- @global string $hook_suffix
      --
--    global $hook_suffix;
      Text : Unbounded_String;
   begin
      Echo ("<div class=""clear""></div></div><!-- wpbody-content -->" & NL);
      Echo ("<div class=""clear""></div></div><!-- wpbody -->" & NL);
      Echo ("<div class=""clear""></div></div><!-- wpcontent -->" & NL);
      Echo (NL);
      Echo ("<div id=""wpfooter"" role=""contentinfo"">" & NL);

      --
      -- Fires after the opening tag for the admin footer.
      --
      -- @since 2.5.0
      --
      Do_Action ("in_admin_footer");

      Echo ("  <p id=""footer-left"" class=""alignleft"">" & NL);

      Text := +Sprintf (
        -- translators: %s: https://wordpress.org/
        abs "Thank you for creating with <a href=""%s"">WordPress</a>.",
        To_List (abs "https://wordpress.org/"));

      --
      -- Filters the "Thank you" text displayed in the admin footer.
      --
      -- @since 2.8.0
      --
      -- @param string $text The content that will be printed.
      --
      Echo (Apply_Filters ("admin_footer_text", "<span id=""footer-thankyou"">" &
                           (-Text) & "</span>"));
      Echo ("  </p>" & NL);
      Echo ("  <p id=""footer-upgrade"" class=""alignright"">" & NL);

      --
      -- Filters the version/update text displayed in the admin footer.
      --
      -- WordPress prints the current version and update information,
      -- using core_update_footer() at priority 10.
      --
      -- @since 2.3.0
      --
      -- @see core_update_footer()
      --
      -- @param string $content The content that will be printed.
      --
      Echo (Apply_Filters ("update_footer", "") & NL);

      Echo ("  </p>" & NL);
      Echo ("  <div class=""clear""></div>" & NL);
      Echo ("</div>" & NL);

      --
      -- Prints scripts or data before the default footer scripts.
      --
      -- @since 1.2.0
      --
      -- @param string $data The data to print.
      --
      Do_Action ("admin_footer", "");

      --
      -- Prints scripts and data queued for the footer.
      --
      -- The dynamic portion of the hook name, `$hook_suffix`,
      -- refers to the global hook suffix of the current page.
      --
      -- @since 4.6.0
      --
      Do_Action ("admin_print_footer_scripts-" & (-Globals.Hook_Suffix));
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      --
      -- Prints any scripts and data queued for the footer.
      --
      -- @since 2.8.0
      --
      Do_Action ("admin_print_footer_scripts");

      --
      -- Prints scripts or data after the default footer scripts.
      --
      -- The dynamic portion of the hook name, `$hook_suffix`,
      -- refers to the global hook suffix of the current page.
      --
      -- @since 2.8.0
      --
      Do_Action ("admin_footer-" & (-Globals.Hook_Suffix));
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      -- get_site_option() won't exist when auto upgrading from <= 2.7.
-- if ( function_exists( 'get_site_option' )
--         && false === get_site_option( 'can_compress_scripts' )
-- ) {
--         compression_test();
-- }

      Echo ("<div class=""clear""></div></div><!-- wpwrap -->" & NL);
      Echo ("<script type=""text/javascript"">if(typeof wpOnload==='function')wpOnload();</script>" & NL);
      Echo ("</body>" & NL);
      Echo ("</html>" & NL);
   end Run;

end Adm_Admin_Footer;
