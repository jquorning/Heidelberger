--
-- About This Version administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;
with Php.Strings;

with Arrays;
with Binder;
with Globals;
with Lists;
with UStrings;

with Adm_Admin;
with Adm_Admin_Header;
with Adm_Admin_Footer;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_Load;
with Inc_Link_Templates;
with Inc_L10n;
with Inc_Themes;

package body Adm_About
is
   use Arrays;
   use Lists;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Load;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Themes;

      List_1 : constant List_Type :=
        Explode ("-", Get_Bloginfo ("version"));

      Display_Version : constant String :=
        List_1.First_Element;

      Display_Major_Version : constant String := "6.8";

      Release_Notes_Url : constant String :=
        Sprintf (
          -- translators: %s: WordPress version number.
          abs "https://wordpress.org/documentation/wordpress-version/version-%s/",
          [1 => "6-8"]
        );

      Field_Guide_Url : constant String :=
        Sprintf (
          -- translators: %s: WordPress version number.
          abs "https://make.wordpress.org/core/wordpress-%s-field-guide/",
          [1 => "6-8"]
        );
   begin
      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      -- Used in the HTML title tag.
      -- translators: Page title of the About WordPress page in the admin.
      Globals.Global_Title := +X_X ("About", "page title");

      Adm_Admin_Header.Run;

      Echo ("<div class=""wrap about__container"">");

      Echo ("<div class=""about__header"">");
      Echo ("    <div class=""about__header-title"">");
      Echo ("        <h1>");
      Printf (
        -- translators: %s: Version number.
        abs "WordPress %s",
        [1 => Display_Version]
      );
      Echo ("        </h1>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<nav class=""about__header-navigation nav-tab-wrapper wp-clearfix"" aria-label=""");
      ESC_Attr_E ("Secondary menu");
      Echo (""">");
      Echo ("<a href=""about.php"" class=""nav-tab nav-tab-active"" aria-current=""page"">"); X_E ("What&#8217;s New"); Echo ("</a>");
      Echo ("<a href=""credits.php"" class=""nav-tab"">"); X_E ("Credits"); Echo ("</a>");
      Echo ("<a href=""freedoms.php"" class=""nav-tab"">"); X_E ("Freedoms"); Echo ("</a>");
      Echo ("<a href=""privacy.php"" class=""nav-tab"">"); X_E ("Privacy"); Echo ("</a>");
      Echo ("<a href=""contribute.php"" class=""nav-tab"">"); X_E ("Get Involved"); Echo ("</a>");
      Echo ("</nav>");

      Echo ("<div class=""about__section changelog has-subtle-background-color"">");
      Echo ("    <div class=""column"">");
      Echo ("        <h2>"); X_E ("Maintenance and Security Releases"); Echo ("</h2>");
      Echo ("        <p>");
      Printf (
        -- translators: %s: WordPress version.
        abs "<strong>Version %s</strong> addressed some security issues.",
        [1 => "6.8.3"]
      );
      Printf (
        -- translators: %s: HelpHub URL.
        abs "For more information, see <a href=""%s"">the release notes</a>.",
        [1 => Sprintf (
               -- translators: %s: WordPress version.
               ESC_URL (abs "https://wordpress.org/support/wordpress-version/version-%s/"),
               [1 => Sanitize_Title ("6.8.3")]
             )]
      );
      Echo ("        </p>");
      Echo ("        <p>");
      Printf (
        -- translators: 1: WordPress version number, 2: Plural number of bugs.
        X_N (
          "<strong>Version %1$s</strong> addressed %2$s bug.",
          "<strong>Version %1$s</strong> addressed %2$s bugs.",
          35
        ),
        [1 => "6.8.2",
         2 => "35"]
      );
      Printf (
        -- translators: %s: HelpHub URL.
        abs "For more information, see <a href=""%s"">the release notes</a>.",
        [1 => Sprintf (
               -- translators: %s: WordPress version.
               ESC_URL (abs "https://wordpress.org/support/wordpress-version/version-%s/"),
               [1 => Sanitize_Title ("6.8.2")]
             )]
      );
      Echo ("        </p>");
      Echo ("        <p>");
      Printf (
        -- translators: 1: WordPress version number, 2: Plural number of bugs.
        X_N (
          "<strong>Version %1$s</strong> addressed %2$s bug.",
          "<strong>Version %1$s</strong> addressed %2$s bugs.",
          16
        ),
        [1 => "6.8.1",
         2 => "15"]
      );
      Printf (
        -- translators: %s: HelpHub URL.
        abs "For more information, see <a href=""%s"">the release notes</a>.",
        [1 => Sprintf (
               -- translators: %s: WordPress version.
               ESC_URL (abs "https://wordpress.org/support/wordpress-version/version-%s/"),
               [1 => Sanitize_Title ("6.8.1")]
             )]
      );
      Echo ("        </p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-1-column"">");
      Echo ("    <div class=""column"">");
      Echo ("        <h2>"); X_E ("A release polished to a high sheen."); Echo ("</h2>");
      Echo ("        <p class=""is-subheading"">"); X_E ("WordPress 6.8 polishes and refines the tools you use every day, making your site faster, more secure, and easier to manage."); Echo ("</p>");
      Echo ("        <p>"); X_E ("The Style Book now has a structured layout and works with Classic themes, giving you more control over global styles."); Echo ("</p>");
      Echo ("        <p>"); X_E ("Speculative loading speeds up navigation by preloading links before users navigate to them, bcrypt hashing strengthens password security automatically, and database optimizations improve performance."); Echo ("</p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-2-columns"">");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <h3>"); X_E ("The Style Book gets a cleaner look&#8212;and a few new tricks"); Echo ("</h3>");
      Echo ("        <p>");
      X_E ("The Style Book has a new, structured layout and clearer labels, to make it even easier to edit colors, typography&#8212;almost all your site styles&#8212;in one place.");
      Echo ("        </p>");
      if not Wp_Is_Block_Theme then
         Echo ("        <p>");
         if
           Current_User_Can ("edit_theme_options") and then
           Current_Theme_Supports ("editor-styles")
         then
            Printf (
              -- translators: %s is a direct link to the Style Book.
              abs "Plus, now you can see it in Classic themes that have editor-styles or a theme.json file. Find <a href=""%s"">the Style Book</a> under Appearance &gt; Design and use it to preview your theme&#8217;s evolution, as you edit CSS or make changes in the Customizer.",
              [1 => Add_Query_Arg (Build ("p", "/stylebook"),
                                   Admin_URL ("/site-editor.php"))]
            );
         else
            X_E ("Plus, now you can see it in Classic themes that have editor-styles or a theme.json file. Find the Style Book under Appearance &gt; Design and use it to preview your theme&#8217;s evolution, as you edit CSS or make changes in the Customizer.");
         end if;
         Echo ("        </p>");
      end if;
      Echo ("    </div>");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <img src=""https://s.w.org/images/core/6.8/feature-01.webp?v=23478"" alt="""" height=""436"" width=""436"" />");
      Echo ("        </div>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-2-columns"">");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <img src=""https://s.w.org/images/core/6.8/feature-02.png?v=23478"" alt="""" height=""436"" width=""436"" />");
      Echo ("        </div>");
      Echo ("    </div>");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <h3>"); X_E ("Editor improvements"); Echo ("</h3>");
      Echo ("        <p>"); X_E ("Easier ways to see your options in Data Views, and you can exclude sticky posts from the Query Loop. Plus, you&#8217;ll find lots of little improvements in the editor that smooth your way through everything you build."); Echo ("</p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-2-columns"">");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <h3>"); X_E ("Near-instant page loads, thanks to Speculative Loading"); Echo ("</h3>");
      Echo ("        <p>"); X_E ("In WordPress 6.8, pages load faster than ever. When you or your user hovers over or clicks a link, WordPress may preload the next page, for a smoother, near-instant experience. The system balances speed and efficiency, and you can control how it works, with a plugin or your own code. This feature only works in modern browsers&#8212;older ones will simply ignore it without any impact."); Echo ("</p>");
      Echo ("    </div>");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <img src=""https://s.w.org/images/core/6.8/feature-03.webp?v=23478"" alt="""" height=""436"" width=""436"" />");
      Echo ("        </div>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-2-columns"">");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <img src=""https://s.w.org/images/core/6.8/feature-04.png?v=23478"" alt="""" height=""436"" width=""436"" />");
      Echo ("        </div>");
      Echo ("    </div>");
      Echo ("    <div class=""column is-vertically-aligned-center"">");
      Echo ("        <h3>"); X_E ("Stronger password security with bcrypt"); Echo ("</h3>");
      Echo ("        <p>"); X_E ("Now passwords are harder to crack with bcrypt hashing, which takes a lot more computing power to break. This strengthens overall security, as do other encryption improvements across WordPress. You don&#8217;t need to do anything&#8212;everything updates automatically."); Echo ("</p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<hr class=""is-invisible is-large"" />");

      Echo ("<div class=""about__section has-2-columns"">");
      Echo ("    <div class=""column"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <svg width=""48"" height=""48"" viewBox=""0 0 48 48"" fill=""none"" xmlns=""http://www.w3.org/2000/svg"" aria-hidden=""true"" focusable=""false"">");
      Echo ("                <path fill=""#1e1e1e"" d=""M24 13.84c-.752 0-1.397-.287-1.936-.86a2.902 2.902 0 0 1-.809-2.06c0-.8.27-1.487.809-2.06S23.248 8 24 8c.753 0 1.398.287 1.937.86.54.573.809 1.26.809 2.06s-.27 1.487-.809 2.06-1.184.86-1.937.86ZM19.976 40V18.68a69.562 69.562 0 0 1-4.945-.56 45.877 45.877 0 0 1-4.57-.92l.565-2.4a46.79 46.79 0 0 0 6.356 1.14c2.106.227 4.312.34 6.618.34 2.307 0 4.513-.113 6.62-.34a46.786 46.786 0 0 0 6.355-1.14l.564 2.4c-1.454.373-2.977.68-4.57.92a69.55 69.55 0 0 1-4.945.56V40h-2.256V29.6h-3.535V40h-2.257Z""/>");
      Echo ("            </svg>");
      Echo ("        </div>");
      Echo ("        <h3>"); X_E ("Accessibility improvements"); Echo ("</h3>");
      Echo ("        <p>"); X_E ("100+ accessibility fixes and enhancements touch a broad spectrum of the WordPress experience. This release includes fixes to every bundled theme, improvements to the navigation menu management, the customizer, and simplified labeling. The Block Editor has over 70 improvements to blocks, DataViews, and to its overall user experience."); Echo ("</p>");
      Echo ("    </div>");
      Echo ("    <div class=""column"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <svg width=""48"" height=""48"" viewBox=""0 0 24 24"" fill=""none"" xmlns=""http://www.w3.org/2000/svg"" aria-hidden=""true"" focusable=""false"">");
      Echo ("                <path fill=""#1e1e1e"" d=""M18.1823 11.6392C18.1823 13.0804 17.0139 14.2487 15.5727 14.2487C14.3579 14.2487 13.335 13.4179 13.0453 12.2922L13.0377 12.2625L13.0278 12.2335L12.3985 10.377L12.3942 10.3785C11.8571 8.64997 10.246 7.39405 8.33961 7.39405C5.99509 7.39405 4.09448 9.29465 4.09448 11.6392C4.09448 13.9837 5.99509 15.8843 8.33961 15.8843C8.88499 15.8843 9.40822 15.781 9.88943 15.5923L9.29212 14.0697C8.99812 14.185 8.67729 14.2487 8.33961 14.2487C6.89838 14.2487 5.73003 13.0804 5.73003 11.6392C5.73003 10.1979 6.89838 9.02959 8.33961 9.02959C9.55444 9.02959 10.5773 9.86046 10.867 10.9862L10.8772 10.9836L11.4695 12.7311C11.9515 14.546 13.6048 15.8843 15.5727 15.8843C17.9172 15.8843 19.8178 13.9837 19.8178 11.6392C19.8178 9.29465 17.9172 7.39404 15.5727 7.39404C15.0287 7.39404 14.5066 7.4968 14.0264 7.6847L14.6223 9.20781C14.9158 9.093 15.2358 9.02959 15.5727 9.02959C17.0139 9.02959 18.1823 10.1979 18.1823 11.6392Z""></path>");
      Echo ("            </svg>");
      Echo ("        </div>");
      Echo ("        <h3>"); X_E ("Take a load off the database"); Echo ("</h3>");
      Echo ("        <p>"); X_E ("Work continues on optimizing cache key generation in the <code>WP_Query</code> class. The goal is, as ever, to boost your site&#8217;s performance, in this case by taking some more of the load off your database. This is especially good if you get a lot of traffic."); Echo ("</p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-1-column"">");
      Echo ("    <div class=""column"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <svg width=""48"" height=""48"" viewBox=""0 0 48 48"" fill=""none"" xmlns=""http://www.w3.org/2000/svg"" aria-hidden=""true"" focusable=""false"">");
      Echo ("                <path fill=""#1e1e1e"" d=""M32.455 17.72a1.592 1.592 0 0 1 .599 2.195l-7.637 12.99a1.653 1.653 0 0 1-2.235.589 1.592 1.592 0 0 1-.599-2.195l7.637-12.99a1.653 1.653 0 0 1 2.235-.589ZM13.774 23.21a1.653 1.653 0 0 0-2.236.589 1.592 1.592 0 0 0 .6 2.195l.944.536c.783.444 1.783.18 2.235-.588a1.592 1.592 0 0 0-.599-2.196l-.944-.535ZM16.432 17.72a1.653 1.653 0 0 1 2.236.588l.545.928a1.592 1.592 0 0 1-.599 2.196 1.653 1.653 0 0 1-2.235-.588l-.546-.928a1.592 1.592 0 0 1 .6-2.196ZM25.637 16.5c0-.888-.733-1.607-1.637-1.607s-1.636.72-1.636 1.607v1.071c0 .888.732 1.608 1.636 1.608.904 0 1.637-.72 1.637-1.608V16.5Z""/>");
      Echo ("                <path fill=""#1e1e1e"" fill-rule=""evenodd"" d=""M4.91 27.75C4.91 17.395 13.455 9 24 9s19.091 8.395 19.091 18.75c0 3.909-1.22 7.542-3.305 10.548l-.488.702H8.702l-.488-.702A18.438 18.438 0 0 1 4.91 27.75ZM24 12.214c-8.736 0-15.818 6.956-15.818 15.536 0 2.943.832 5.692 2.277 8.036h27.082a15.25 15.25 0 0 0 2.277-8.036c0-8.58-7.082-15.536-15.818-15.536Z"" clip-rule=""evenodd""/>");
      Echo ("            </svg>");
      Echo ("        </div>");
      Echo ("        <h3>"); X_E ("Performance updates"); Echo ("</h3>");
      Echo ("        <p>"); X_E ("WordPress 6.8 packs a wide range of performance fixes and enhancements to speed up everything from editing to browsing. Beyond speculative loading, WordPress 6.8 pays special attention to the block editor, block type registration, and query caching. Plus, imagine never waiting longer than 50 milliseconds&#8212;for any interaction. In WordPress 6.8, the Interactivity API takes a first step toward that goal."); Echo ("</p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<hr class=""is-invisible is-large"" style=""margin-bottom:calc(2 * var(--gap));"" />");

      Echo ("<div class=""about__section has-2-columns is-wider-left is-feature"" style=""background-color:var(--background);border-radius:var(--border-radius);"">");
      Echo ("    <h3 class=""is-section-header"">"); X_E ("And much more"); Echo ("</h3>");
      Echo ("    <div class=""column"">");
      Echo ("        <p>");
      Printf (
        -- translators: %s: Version number.
        abs "For a comprehensive overview of all the new features and enhancements in WordPress %s, please visit the feature-showcase website.",
        [1 => Display_Major_Version]
      );
      Echo ("        </p>");
      Echo ("    </div>");
      Echo ("    <div class=""column aligncenter"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <a href=""");
      Echo (ESC_URL (abs "https://wordpress.org/download/releases/6-8/"));
      Echo (""" class=""button button-primary button-hero"">"); X_E ("See everything new"); Echo ("</a>");
      Echo ("        </div>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<hr class=""is-large"" style=""margin-top:calc(2 * var(--gap));"" />");

      Echo ("<div class=""about__section has-3-columns"">");
      Echo ("    <div class=""column about__image is-vertically-aligned-top"">");
      Echo ("        <img src=""");
      Echo (ESC_URL (Admin_URL ("images/about-release-badge.svg?ver=6.8")));
      Echo (""" alt="""" height=""280"" width=""280"" />");
      Echo ("    </div>");
      Echo ("    <div class=""column is-vertically-aligned-center"" style=""grid-column-end:span 2"">");
      Echo ("        <h3>");
      Printf (
        -- translators: %s: Version number.
        abs "Learn more about WordPress %s",
        [1 => Display_Major_Version]
      );
      Echo ("        </h3>");
      Echo ("        <p>");
      Printf (
        -- translators: 1: Learn WordPress link, 2: Workshops link.
        abs "<a href=""%1$s"">Learn WordPress</a> is a free resource for new and experienced WordPress users. Learn is stocked with how-to videos on using various features in WordPress, <a href=""%2$s"">interactive workshops</a> for exploring topics in-depth, and lesson plans for diving deep into specific areas of WordPress.",
        [1 => "https://learn.wordpress.org/",
         2 => "https://learn.wordpress.org/online-workshops/"]
      );
      Echo ("        </p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<div class=""about__section has-2-columns"">");
      Echo ("    <div class=""column"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <svg width=""48"" height=""48"" viewBox=""0 0 48 48"" fill=""none"" xmlns=""http://www.w3.org/2000/svg"" aria-hidden=""true"" focusable=""false"">");
      Echo ("                <path fill=""#1e1e1e"" d=""M32 15.5H16v3h16v-3ZM16 22h16v3H16v-3ZM28 28.5H16v3h12v-3Z""/>");
      Echo ("                <path fill=""#1e1e1e"" fill-rule=""evenodd"" d=""M34 8H14a4 4 0 0 0-4 4v24a4 4 0 0 0 4 4h20a4 4 0 0 0 4-4V12a4 4 0 0 0-4-4Zm-20 3h20a1 1 0 0 1 1 1v24a1 1 0 0 1-1 1H14a1 1 0 0 1-1-1V12a1 1 0 0 1 1-1Z"" clip-rule=""evenodd""/>");
      Echo ("            </svg>");
      Echo ("        </div>");
      Echo ("        <h4 style=""margin-top: calc(var(--gap) / 2); margin-bottom: calc(var(--gap) / 2);"">");
      Echo ("            <a href=""");
      Echo (ESC_URL (Release_Notes_Url));
      Echo (""">");
      Printf (
        -- translators: %s: WordPress version number.
        abs "WordPress %s Release Notes",
        [1 => Display_Major_Version]
      );
      Echo ("            </a>");
      Echo ("        </h4>");
      Echo ("        <p>");
      Printf (
        -- translators: %s: WordPress version number.
        abs "Read the WordPress %s Release Notes for information on installation, enhancements, fixed issues, release contributors, learning resources, and the list of file changes.",
        [1 => Display_Major_Version]
      );
      Echo ("        </p>");
      Echo ("    </div>");
      Echo ("    <div class=""column"">");
      Echo ("        <div class=""about__image"">");
      Echo ("            <svg width=""48"" height=""48"" viewBox=""0 0 48 48"" fill=""none"" xmlns=""http://www.w3.org/2000/svg"" aria-hidden=""true"" focusable=""false"">");
      Echo ("                <path fill=""#1e1e1e"" stroke=""#fff"" stroke-width="".5"" d=""M26.5 24.25h13.75v11.5h-14v8h-3.5v-8H12.604L8.09 31.237a1.75 1.75 0 0 1 0-2.474l4.513-4.513H22.75v-4.5h-14V8.25h14v-4h3.5v4h10.146l4.513 4.513a1.75 1.75 0 0 1 0 2.474l-4.513 4.513H26.25v4.5h.25ZM12.25 16v.25h22.704l.073-.073 1.293-1.293a1.25 1.25 0 0 0 0-1.768l-1.293-1.293-.073-.073H12.25V16Zm1.723 16.177.073.073H36.75v-4.5H14.046l-.073.073-1.293 1.293a1.25 1.25 0 0 0 0 1.768l1.293 1.293Z""/>");
      Echo ("            </svg>");
      Echo ("        </div>");
      Echo ("        <h4 style=""margin-top: calc(var(--gap) / 2); margin-bottom: calc(var(--gap) / 2);"">");
      Echo ("            <a href=""");
      Echo (ESC_URL (Field_Guide_Url));
      Echo (""">");
      Printf (
        -- translators: %s: WordPress version number.
        abs "WordPress %s Field Guide",
        [1 => Display_Major_Version]
      );
      Echo ("            </a>");
      Echo ("        </h4>");
      Echo ("        <p>");
      Printf (
        -- translators: %s: WordPress version number.
        abs "Explore the WordPress %s Field Guide. Learn about the changes in this release with detailed developer notes to help you build with WordPress.",
        [1 => Display_Major_Version]
      );
      Echo ("        </p>");
      Echo ("    </div>");
      Echo ("</div>");

      Echo ("<hr class=""is-large"" />");

      Echo ("<div class=""return-to-dashboard"">");
      if Isset (Binder.XX_GET, "updated") and then Current_User_Can ("update_core") then
         Printf (
           "<a href=""%1$s"">%2$s</a> | ",
           [1 => ESC_URL (Self_Admin_URL ("update-core.php")),
            2 => (if Is_Multisite
                  then abs "Go to Updates"
                  else abs "Go to Dashboard &rarr; Updates")]
         );
      end if;
      Printf (
        "<a href=""%1$s"">%2$s</a>",
        [1 => ESC_URL (Self_Admin_URL ("")),
         2 => (if Is_Blog_Admin
               then abs "Go to Dashboard &rarr; Home"
               else abs "Go to Dashboard")]
      );
      Echo ("</div>");
      Echo ("</div>");

      Adm_Admin_Footer.Run;
   end Render;

end Adm_About;
