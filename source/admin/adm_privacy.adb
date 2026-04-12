--
-- Privacy administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;

with Globals;
with UStrings;

with Adm_Admin;
with Adm_Admin_Footer;
with Adm_Admin_Header;

with Inc_Formatting;
with Inc_L10n;
with Inc_Link_Templates;

package body Adm_Privacy
is

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Php.Echoing;
      use UStrings;
      use Inc_Formatting;
      use Inc_L10n;
      use Inc_Link_Templates;
   begin
      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      -- Used in the HTML title tag.
      Globals.Global_Title := +abs "Privacy";

      Adm_Admin_Header.Run;

      Echo ("<div class=""wrap about__container"">");

      Echo ("<div class=""about__header"">");
      Echo ("    <div class=""about__header-title"">");
      Echo ("        <h1>");
      X_E ("Privacy");
      Echo ("        </h1>");
      Echo ("    </div>");
      Echo ("    <div class=""about__header-text"">");
      X_E ("WordPress.org takes privacy and transparency very seriously");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<nav class=""about__header-navigation nav-tab-wrapper wp-clearfix"" aria-label=""");
      ESC_Attr_E ("Secondary menu");
      Echo (""">");
      Echo ("<a href=""about.php"" class=""nav-tab"">"); X_E ("What&#8217;s New"); Echo ("</a>");
      Echo ("<a href=""credits.php"" class=""nav-tab"">"); X_E ("Credits"); Echo ("</a>");
      Echo ("<a href=""freedoms.php"" class=""nav-tab"">"); X_E ("Freedoms"); Echo ("</a>");
      Echo ("<a href=""privacy.php"" class=""nav-tab nav-tab-active"" aria-current=""page"">"); X_E ("Privacy"); Echo ("</a>");
      Echo ("<a href=""contribute.php"" class=""nav-tab"">"); X_E ("Get Involved"); Echo ("</a>");
      Echo ("</nav>");

      Echo ("<div class=""about__section has-2-columns is-wider-right"">");
      Echo ("    <div class=""column about__image"">");
      Echo ("        <img class=""privacy-image"" src=""");
      Echo (ESC_URL (Admin_URL ("images/privacy.svg?ver=6.5")));
      Echo (""" alt="""" />");
      Echo ("    </div>");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <p>"); X_E ("From time to time, your WordPress site may send data to WordPress.org &#8212; including, but not limited to &#8212; the version you are using, and a list of installed plugins and themes."); Echo ("</p>");
      Echo ("        <p>");
      Printf (
        -- translators: %s: https://wordpress.org/about/stats/
        abs "This data is used to provide general enhancements to WordPress, which includes helping to protect your site by finding and automatically installing new updates. It is also used to calculate statistics, such as those shown on the <a href=""%s"">WordPress.org stats page</a>.",
        [1 => abs "https://wordpress.org/about/stats/"]);
      Echo ("        </p>");
      Echo ("        <p>");
      Printf (
        -- translators: %s: https://wordpress.org/about/privacy/
        abs "WordPress.org takes privacy and transparency very seriously. To learn more about what data is collected, and how it is used, please visit <a href=""%s"">the WordPress.org Privacy Policy</a>.",
        [1 => abs "https://wordpress.org/about/privacy/"]);
      Echo ("        </p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("</div>");

      Adm_Admin_Footer.Run;
   end Run;

end Adm_Privacy;
