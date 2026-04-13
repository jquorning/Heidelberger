--
-- Credits administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;

with Globals;
with UStrings;

with GNATCOLL.JSON;

with Adi_Credits;
with Adm_Admin;
with Adm_Admin_Header;
with Adm_Admin_Footer;

with Inc_Formatting;
with Inc_L10n;

package body Adm_Credits
is

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Echoing;
      use UStrings;
      use GNATCOLL.JSON;
      use Adi_Credits;
      use Inc_Formatting;
      use Inc_L10n;

      Credits : constant JSON_Value := Wp_Credits;
   begin
      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      -- Used in the HTML title tag.
      Globals.Global_Title := +abs "Credits";

      Adm_Admin_Header.Run;

      Echo ("<div class=""wrap about__container"">");

      Echo ("<div class=""about__header"">");
      Echo ("    <div class=""about__header-title"">");
      Echo ("        <h1>");
      X_E ("Contributors");
      Echo ("        </h1>");
      Echo ("    </div>");
      Echo ("    <div class=""about__header-text"">");
      X_E ("Created by a worldwide team of passionate individuals");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<nav class=""about__header-navigation nav-tab-wrapper wp-clearfix"" aria-label=""");
      ESC_Attr_E ("Secondary menu");
      Echo (""">");
      Echo ("<a href=""about.php"" class=""nav-tab"">"); X_E ("What&#8217;s New"); Echo ("</a>");
      Echo ("<a href=""credits.php"" class=""nav-tab nav-tab-active"" aria-current=""page"">"); X_E ("Credits"); Echo ("</a>");
      Echo ("<a href=""freedoms.php"" class=""nav-tab"">"); X_E ("Freedoms"); Echo ("</a>");
      Echo ("<a href=""privacy.php"" class=""nav-tab"">"); X_E ("Privacy"); Echo ("</a>");
      Echo ("<a href=""contribute.php"" class=""nav-tab"">"); X_E ("Get Involved"); Echo ("</a>");
      Echo ("</nav>");

      Echo ("<div class=""about__section has-1-column has-gutters"">");
      Echo ("    <div class=""column aligncenter"">");
      if Credits.Is_Empty then
         Echo ("        <p>");
         Printf (
           -- translators: 1: https://wordpress.org/about/
           abs "WordPress is created by a <a href=""%1$s"">worldwide team</a> of passionate individuals.",
           [1 => abs "https://wordpress.org/about/"]
         );
         Echo ("<br />");
         Echo ("        <a href=""");
         Echo (ESC_URL (abs "https://make.wordpress.org/contribute/"));
         Echo (""">"); X_E ("Get involved in WordPress."); Echo ("</a>");
         Echo ("        </p>");
      else
         Echo ("        <p>");
         X_E ("Want to see your name in lights on this page?");
         Echo ("<br />");
         Echo ("        <a href=""");
         Echo (ESC_URL (abs "https://make.wordpress.org/contribute/"));
         Echo (""">"); X_E ("Get involved in WordPress."); Echo ("</a>");
         Echo ("        </p>");
      end if;
      Echo ("    </div>");
      Echo ("</div>");

      if Credits.Is_Empty then
         Echo ("</div>");
         Adm_Admin_Footer.Run;
         return;
      end if;

      Echo ("<hr class=""is-large"" />");

      Echo ("<div class=""about__section"">");
      Echo ("    <div class=""column is-edge-to-edge"">");
      declare
         Groups    : constant JSON_Value := Credits.Get ("groups");
         Core_Devs : constant JSON_Value := Groups.Get ("core-developers");
      begin
         Wp_Credits_Section_Title (Core_Devs);
         Wp_Credits_Section_List (Credits, "core-developers");
         Wp_Credits_Section_List (Credits, "contributing-developers");
      end;
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<hr />");

      Echo ("<div class=""about__section"">");
      Echo ("    <div class=""column"">");
      declare
         Groups : constant JSON_Value := Credits.Get ("groups");
         Props  : constant JSON_Value := Groups.Get ("props");
      begin
         Wp_Credits_Section_Title (Props);
         Wp_Credits_Section_List (Credits, "props");
      end;
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<hr />");

      declare
         Groups          : constant JSON_Value := Credits.Get ("groups");
         Has_Translators : constant Boolean    := Groups.Has_Field ("translators");
         Has_Validators  : constant Boolean    := Groups.Has_Field ("validators");
      begin
         if Has_Translators or else Has_Validators then
            Echo ("<div class=""about__section"">");
            Echo ("    <div class=""column"">");
            Wp_Credits_Section_Title (Groups.Get ("validators"));
            Wp_Credits_Section_List (Credits, "validators");
            Wp_Credits_Section_List (Credits, "translators");
            Echo ("    </div>");
            Echo ("</div>");
            Echo ("<hr />");
         end if;
      end;

      Echo ("<div class=""about__section"">");
      Echo ("    <div class=""column"">");
      declare
         Groups    : constant JSON_Value := Credits.Get ("groups");
         Libraries : constant JSON_Value := Groups.Get ("libraries");
      begin
         Wp_Credits_Section_Title (Libraries);
         Wp_Credits_Section_List (Credits, "libraries");
      end;
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("</div>");

      Adm_Admin_Footer.Run;
   end Render;

end Adm_Credits;
