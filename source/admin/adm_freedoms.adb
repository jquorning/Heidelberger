--
-- Your Rights administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;
with Php.Errors;
with Php.Strings;

with Arrays;
with Binder;
with Globals;
with Lists;
with UStrings;

with Adm_Admin;
with Adm_Admin_Footer;
with Adm_Admin_Header;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_General_Templates;
with Inc_Link_Templates;
with Inc_L10n;
with Inc_Pluggables;

package body Adm_Freedoms
is
   use Arrays;
   use Lists;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.Strings;
      use UStrings;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Pluggables;

      List : constant List_Type :=
        Explode ("-", Get_Bloginfo ("version"));

      Display_Version : constant String :=
        List.First_Element;
      pragma Unreferenced (Display_Version);
   begin
      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      -- This file was used to also display the Privacy tab on the About screen from 4.9.6 until 5.3.0.
      if Isset (Binder.XX_GET, "privacy-notice") then
         Wp_Redirect (Admin_URL ("privacy.php"), 301);
         Die;
      end if;

      -- Used in the HTML title tag.
      Globals.Global_Title := +abs "Freedoms";

      Adm_Admin_Header.Run;

      Echo ("<div class=""wrap about__container"">");

      Echo ("  <div class=""about__header"">");
      Echo ("          <div class=""about__header-title"">");
      Echo ("                  <h1>");
      X_E ("The Four Freedoms");
      Echo ("                  </h1>");
      Echo ("          </div>");

      Echo ("          <div class=""about__header-text"">");
      X_E ("WordPress is free and open source software");
      Echo ("          </div>");

      Echo ("          <nav class=""about__header-navigation nav-tab-wrapper wp-clearfix"" aria-label=""");  ESC_Attr_E ("Secondary menu"); Echo (""">");
      Echo ("                  <a href=""about.php"" class=""nav-tab"">");  X_E ("What&#8217;s New");  Echo ("</a>");
      Echo ("                  <a href=""credits.php"" class=""nav-tab"">");  X_E ("Credits");  Echo ("</a>");
      Echo ("                  <a href=""freedoms.php"" class=""nav-tab nav-tab-active"" aria-current=""page"">");  X_E ("Freedoms");  Echo ("</a>");
      Echo ("                  <a href=""privacy.php"" class=""nav-tab"">");  X_E ("Privacy");  Echo ("</a>");
      Echo ("          </nav>");
      Echo ("  </div>");

      Echo ("  <div class=""about__section is-feature"">");
      Echo ("          <p class=""about-description"">");
      Printf (
        -- translators: %s: https://wordpress.org/about/license/
        abs "WordPress comes with some awesome, worldview-changing rights courtesy of its <a href=""%s"">license</a>, the GPL.",
        [abs "https://wordpress.org/about/license/"]
      );
      Echo ("          </p>");
      Echo ("  </div>");

      Echo ("  <div class=""about__section has-2-columns"">");
      Echo ("          <div class=""column aligncenter"">");
      Echo ("                  <img class=""freedom-image"" src=""" & ESC_URL (Admin_URL ("images/freedom-1.svg?ver=6.1")) & """ alt="""" />");
      Echo ("                  <h2 class=""is-smaller-heading"">");  X_E ("The 1st Freedom"); Echo ("</h2>");
      Echo ("                  <p>");  X_E ("To run the program for any purpose.");  Echo ("</p>");
      Echo ("          </div>");
      Echo ("          <div class=""column aligncenter"">");
      Echo ("                  <img class=""freedom-image"" src=""" & ESC_URL (Admin_URL ("images/freedom-2.svg?ver=6.1")) & """ alt="""" />");
      Echo ("                  <h2 class=""is-smaller-heading"">");  X_E ("The 2nd Freedom");  Echo ("</h2>");
      Echo ("                  <p>");  X_E ("To study how the program works and change it to make it do what you wish.");  Echo ("</p>");
      Echo ("          </div>");
      Echo ("          <div class=""column aligncenter"">");
      Echo ("                  <img class=""freedom-image"" src=""" & ESC_URL (Admin_URL ("images/freedom-3.svg?ver=6.1")) & """ alt="""" />");
      Echo ("                  <h2 class=""is-smaller-heading"">");  X_E ("The 3rd Freedom");  Echo ("</h2>");
      Echo ("                  <p>");  X_E ("To redistribute.");  Echo ("</p>");
      Echo ("          </div>");
      Echo ("          <div class=""column aligncenter"">");
      Echo ("                  <img class=""freedom-image"" src=""" & ESC_URL (Admin_URL ("images/freedom-4.svg?ver=6.1")) & """ alt="""" />");
      Echo ("                  <h2 class=""is-smaller-heading"">");  X_E ("The 4th Freedom");  Echo ("</h2>");
      Echo ("                  <p>");  X_E ("To distribute copies of your modified versions to others.");  Echo ("</p>");
      Echo ("          </div>");
      Echo ("  </div>");

      Echo ("  <div class=""about__section has-1-column"">");
      Echo ("          <div class=""column"">");
      Echo ("                  <p>");
      Printf (
        -- translators: %s: https://wordpressfoundation.org/trademark-policy/
        abs "WordPress grows when people like you tell their friends about it, and the thousands of businesses and services that are built on and around WordPress share that fact with their users. We are flattered every time someone spreads the good word, just make sure to <a href=""%s"">check out our trademark guidelines</a> first.",
        ["https://wordpressfoundation.org/trademark-policy/"]
      );

      Echo ("                  </p>");

      Echo ("                  <p>");

      declare
         Plugins_URL : String := (if Current_User_Can ("activate_plugins") then Admin_URL ("plugins.php") else abs "https://wordpress.org/plugins/");
         Themes_URL  : String := (if Current_User_Can ("switch_themes") then Admin_URL ("themes.php") else abs "https://wordpress.org/themes/");
      begin
         Printf (
           -- translators: 1: URL to Plugins screen, 2: URL to Themes screen, 3: https://wordpress.org/about/license/
           abs "Every plugin and theme in WordPress.org&#8217;s directory is 100%% GPL or a similarly free and compatible license, so you can feel safe finding <a href=""%1$s"">plugins</a> and <a href=""%2$s"">themes</a> there. If you get a plugin or theme from another source, make sure to <a href=""%3$s"">ask them if it&#8217;s GPL</a> first. If they do not respect the WordPress license, it is not recommended to use them.",
           [
             1 => Plugins_URL,
             2 => Themes_URL,
             3 => abs "https://wordpress.org/about/license/"
           ]
         );
      end;

      Echo ("                  </p>");
      Echo ("          </div>");
      Echo ("  </div>");

      Echo ("</div>");

      Adm_Admin_Footer.Run;
   end Render;

end Adm_Freedoms;
