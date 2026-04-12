--
-- Contribute administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;

with Globals;
with UStrings;

with Adm_Admin;
with Adm_Admin_Header;
with Adm_Admin_Footer;

with Inc_Formatting;
with Inc_Link_Templates;
with Inc_L10n;

package body Adm_Contribute
is

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Echoing;
      use UStrings;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_L10n;

   begin
      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      -- Used in the HTML title tag.
      Globals.Global_Title := +X_X ("Get Involved", "page title");

      Adm_Admin_Header.Run;

      Echo ("<div class=""wrap about__container"">");

      Echo ("<div class=""about__header"">");
      Echo ("    <div class=""about__header-title"">");
      Echo ("        <h1>");
      X_E ("Get Involved");
      Echo ("        </h1>");
      Echo ("    </div>");
      Echo ("    <div class=""about__header-text"">");
      X_E ("Be the future of WordPress");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<nav class=""about__header-navigation nav-tab-wrapper wp-clearfix"" aria-label=""");
      ESC_Attr_E ("Secondary menu");
      Echo (""">");
      Echo ("<a href=""about.php"" class=""nav-tab"">"); X_E ("What&#8217;s New"); Echo ("</a>");
      Echo ("<a href=""credits.php"" class=""nav-tab"">"); X_E ("Credits"); Echo ("</a>");
      Echo ("<a href=""freedoms.php"" class=""nav-tab"">"); X_E ("Freedoms"); Echo ("</a>");
      Echo ("<a href=""privacy.php"" class=""nav-tab"">"); X_E ("Privacy"); Echo ("</a>");
      Echo ("<a href=""contribute.php"" class=""nav-tab nav-tab-active"" aria-current=""page"">"); X_E ("Get Involved"); Echo ("</a>");
      Echo ("</nav>");

      Echo ("<div class=""about__section has-2-columns is-wider-right"">");
      Echo ("    <div class=""column"">");
      Echo ("        <img src=""");
      Echo (ESC_URL (Admin_URL ("images/contribute-main.svg?ver=6.5")));
      Echo (""" alt="""" width=""290"" height=""290"" />");
      Echo ("    </div>");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <p>"); X_E ("Do you use WordPress for work, for personal projects, or even just for fun? You can help shape the long-term success of the open source project that powers millions of websites around the world."); Echo ("</p>");
      Echo ("        <p>"); X_E ("Join the diverse WordPress contributor community and connect with other people who are passionate about maintaining a free and open web."); Echo ("</p>");
      Echo ("        <ul>");
      Echo ("            <li>"); X_E ("Be part of a global open source community."); Echo ("</li>");
      Echo ("            <li>"); X_E ("Apply your skills or learn new ones."); Echo ("</li>");
      Echo ("            <li>"); X_E ("Grow your network and make friends."); Echo ("</li>");
      Echo ("        </ul>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-2-columns is-wider-left"">");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <h2 class=""is-smaller-heading"">"); X_E ("No-code contribution"); Echo ("</h2>");
      Echo ("        <p>"); X_E ("WordPress may thrive on technical contributions, but you don&#8217;t have to code to contribute. Here are some of the ways you can make an impact without writing a single line of code:"); Echo ("</p>");
      Echo ("        <ul>");
      Echo ("            <li>"); X_E ("<strong>Share</strong> your knowledge in the WordPress support forums."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Write</strong> or improve documentation for WordPress."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Translate</strong> WordPress into your local language."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Create</strong> and improve WordPress educational materials."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Promote</strong> the WordPress project to your community."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Curate</strong> submissions or take photos for the Photo Directory."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Organize</strong> or participate in local Meetups and WordCamps."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Lend</strong> your creative imagination to the WordPress UI design."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Edit</strong> videos and add captions to WordPress.tv."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Explore</strong> ways to reduce the environmental impact of websites."); Echo ("</li>");
      Echo ("        </ul>");
      Echo ("    </div>");
      Echo ("    <div class=""column"">");
      Echo ("        <img src=""");
      Echo (ESC_URL (Admin_URL ("images/contribute-no-code.svg?ver=6.5")));
      Echo (""" alt="""" width=""290"" height=""290"" />");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-2-columns is-wider-right"">");
      Echo ("    <div class=""column"">");
      Echo ("        <img src=""");
      Echo (ESC_URL (Admin_URL ("images/contribute-code.svg?ver=6.5")));
      Echo (""" alt="""" width=""290"" height=""290"" />");
      Echo ("    </div>");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <h2 class=""is-smaller-heading"">"); X_E ("Code-based contribution"); Echo ("</h2>");
      Echo ("        <p>"); X_E ("If you do code, or want to learn how, you can contribute technically in numerous ways:"); Echo ("</p>");
      Echo ("        <ul>");
      Echo ("            <li>"); X_E ("<strong>Find</strong> and report bugs in the WordPress core software."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Test</strong> new releases and proposed features for the Block Editor."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Write</strong> and submit patches to fix bugs or help build new features."); Echo ("</li>");
      Echo ("            <li>"); X_E ("<strong>Contribute</strong> to the code, improve the UX, and test the WordPress app."); Echo ("</li>");
      Echo ("        </ul>");
      Echo ("        <p>"); X_E ("WordPress embraces new technologies, while being committed to backward compatibility. The WordPress project uses the following languages and libraries:"); Echo ("</p>");
      Echo ("        <ul>");
      Echo ("            <li>"); X_E ("WordPress Core and Block Editor: HTML, CSS, PHP, SQL, JavaScript, and React."); Echo ("</li>");
      Echo ("            <li>"); X_E ("WordPress app: Kotlin, Java, Swift, Objective-C, Vue, Python, and TypeScript."); Echo ("</li>");
      Echo ("        </ul>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section is-feature has-subtle-background-color"">");
      Echo ("    <div class=""column"">");
      Echo ("        <h2>"); X_E ("Shape the future of the web with WordPress"); Echo ("</h2>");
      Echo ("        <p>"); X_E ("Finding the area that aligns with your skills and interests is the first step toward meaningful contribution. With more than 20 Make WordPress teams working on different parts of the open source WordPress project, there&#8217;s a place for everyone, no matter what your skill set is."); Echo ("</p>");
      Echo ("        <p><a href=""");
      Echo (ESC_URL (abs "https://make.wordpress.org/contribute/"));
      Echo (""">"); X_E ("Find your team &rarr;"); Echo ("</a></p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("</div>");

      Adm_Admin_Footer.Run;
   end Render;

end Adm_Contribute;
