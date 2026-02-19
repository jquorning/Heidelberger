--
-- Dashboard Administration Screen
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;
with Php.Misc;
with Php.Preg;
with Php.Strings;

with Arrays;
with Array_Lists;
with Binder;
with Constants;
with Globals;
with UStrings;
with Wp_Common;

with Adi_Class_Wp_Screens;
with Adi_Dashboard;
with Adi_Screens;
with Adm_Admin;
with Adm_Admin_Header;
with Adm_Admin_Footer;
with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_General_Templates;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Users;
with Inc_Vars;

package body Adm_Index
is
   use Arrays;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Echoing;
      use Php.Preg;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Adi_Class_Wp_Screens;
      use Adi_Dashboard;
      use Adi_Screens;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
      use Inc_Plugins;
      use Inc_Users;
      use Inc_Vars;
   begin
      -- Load WordPress Bootstrap
      Adm_Admin.Run;

      -- Load WordPress dashboard API
--    Adi_Dashboard.Run;

      Wp_Dashboard_Setup;

      Wp_Enqueue_Script ("dashboard");

      if Current_User_Can ("install_plugins")  then
         Wp_Enqueue_Script ("plugin-install");
         Wp_Enqueue_Script ("updates");
      end if;

      if Current_User_Can ("upload_files") then
         Wp_Enqueue_Script ("media-upload");
      end if;

      Add_Thickbox;

      if Wp_Is_Mobile then
         Wp_Enqueue_Script ("jquery-touch-punch");
      end if;

      -- Used in the HTML title tag.
      Globals.Title              := +abs "Dashboard";
      Globals.Global_Parent_File := +"index.php";

      declare
         Screen : constant Wp_Screen := Get_Current_Screen;
      begin
         declare
            Help : constant String :=
              "<p>" & abs "Welcome to your WordPress Dashboard!" & "</p>" &
              "<p>" & abs "The Dashboard is the first place you will come to every time you log into your site. It is where you will find all your WordPress tools. If you need help, just click the &#8220;Help&#8221; tab above the screen title." & "</p>";
         begin
            Screen.Add_Help_Tab (
               To_Array_Type ([
                 Build ("id",      "overview"),
                 Build ("title",   abs "Overview"),
                 Build ("content", Help)
               ])
            );
         end;

         -- Help tabs.
         declare
            Help : constant String :=
              "<p>" & abs "The left-hand navigation menu provides links to all of the WordPress administration screens, with submenu items displayed on hover. You can minimize this menu to a narrow icon strip by clicking on the Collapse Menu arrow at the bottom." & "</p>" &
              "<p>" & abs "Links in the Toolbar at the top of the screen connect your dashboard and the front end of your site, and provide access to your profile and helpful WordPress information." & "</p>";
         begin
            Screen.Add_Help_Tab (
              To_Array_Type ([
                Build ("id",      "help-navigation"),
                Build ("title",   abs "Navigation"),
                Build ("content", Help)
             ])
           );
         end;

         declare
            Help : constant String :=
              "<p>" & abs "You can use the following controls to arrange your Dashboard screen to suit your workflow. This is true on most other administration screens as well." & "</p>" &
              "<p>" & abs "<strong>Screen Options</strong> &mdash; Use the Screen Options tab to choose which Dashboard boxes to show." & "</p>" &
              "<p>" & abs "<strong>Drag and Drop</strong> &mdash; To rearrange the boxes, drag and drop by clicking on the title bar of the selected box and releasing when you see a gray dotted-line rectangle appear in the location you want to place the box." & "</p>" &
              "<p>" & abs "<strong>Box Controls</strong> &mdash; Click the title bar of the box to expand or collapse it. Some boxes added by plugins may have configurable content, and will show a &#8220;Configure&#8221; link in the title bar if you hover over it." & "</p>";
         begin
            Screen.Add_Help_Tab (
              To_Array_Type ([
                Build ("id",      "help-layout"),
                Build ("title",   abs "Layout"),
                Build ("content", Help)
              ])
            );
         end;

         declare
            Help : UString;
         begin
            Append (Help, "<p>" & abs "The boxes on your Dashboard screen are:" & "</p>");

            if Current_User_Can ("edit_theme_options") then
               Append (Help, "<p>" & abs "<strong>Welcome</strong> &mdash; Shows links for some of the most common tasks when setting up a new site." & "</p>");
            end if;

            if Current_User_Can ("view_site_health_checks") then
               Append (Help, "<p>" & abs "<strong>Site Health Status</strong> &mdash; Informs you of any potential issues that should be addressed to improve the performance or security of your website." & "</p>");
            end if;

            if Current_User_Can ("edit_posts") then
               Append (Help, "<p>" & abs "<strong>At a Glance</strong> &mdash; Displays a summary of the content on your site and identifies which theme and version of WordPress you are using." & "</p>");
            end if;

            Append (Help, "<p>" & abs "<strong>Activity</strong> &mdash; Shows the upcoming scheduled posts, recently published posts, and the most recent comments on your posts and allows you to moderate them." & "</p>");

            if Is_Blog_Admin and then Current_User_Can ("edit_posts") then
               Append (Help, "<p>" & abs "<strong>Quick Draft</strong> &mdash; Allows you to create a new post and save it as a draft. Also displays links to the 3 most recent draft posts you've started." & "</p>");
            end if;

            Append (Help, "<p>" & Sprintf (
              -- translators: %s: WordPress Planet URL.
              abs "<strong>WordPress Events and News</strong> &mdash; Upcoming events near you as well as the latest news from the official WordPress project and the <a href=""%s"">WordPress Planet</a>.",
              [1 => abs "https://planet.wordpress.org/"]
            ) & "</p>");

            Screen.Add_Help_Tab (
              To_Array_Type ([
                Build ("id",      "help-content"),
                Build ("title",   abs "Content"),
                Build ("content", -Help)
              ])
            );

            -- unset( help );
         end;

         declare
            Wp_Version : constant String :=
              Get_Bloginfo ("version", "display");

            -- translators: %s: WordPress version.
            Wp_Version_Text : UString :=
              +Sprintf (abs "Version %s", [1 => Wp_Version]);

            Is_Dev_Version : constant Boolean :=
              Preg_Match ("/alpha|beta|RC/", Wp_Version);
         begin
            if not Is_Dev_Version then
               declare
                  Version_URL : constant String :=
                    Sprintf (
                      -- translators: %s: WordPress version.
                      ESC_URL (abs "https://wordpress.org/support/wordpress-version/version-%s/"),
                      [1 => Sanitize_Title (Wp_Version)]
                    );
               begin
                  Wp_Version_Text := +Sprintf (
                    "<a href=""%1s"">%2s</a>",
                    [
                      1 => Version_URL,
                      2 => -Wp_Version_Text
                    ]
                  );
               end;
            end if;

            Screen.Set_Help_Sidebar (
              "<p><strong>" & abs "For more information:" & "</strong></p>" &
              "<p>" & abs "<a href=""https://wordpress.org/support/article/dashboard-screen/"">Documentation on Dashboard</a>" & "</p>" &
              "<p>" & abs "<a href=""https://wordpress.org/support/"">Support</a>" & "</p>" &
              "<p>" & (-Wp_Version_Text) & "</p>"
            );
         end;
      end;

      -- require_once ABSPATH . "wp-admin/admin-header.php";
      Adm_Admin_Header.Run;

      Echo ("<div class=""wrap"">");
      Echo ("        <h1>" & ESC_HTML (-Globals.Title) & "</h1>");

      if not Empty (Binder.XX_GET, "admin_email_remind_later") then
         declare
            -- This filter is documented in wp-login.php
            Remind_Interval : constant Integer :=
              Apply_Filters ("admin_email_remind_interval",
                             3 * Constants.DAY_IN_SECONDS); -- (int)

            Postponed_Time  : constant Integer :=
              Get_Option ("admin_email_lifespan");

            --
            -- Calculate how many seconds it's been since the reminder was postponed.
            -- This allows us to not show it if the query arg is set, but visited due to caches, bookmarks or similar.
            --
            Time_Passed : constant Integer :=
              Php.Misc.Time - (Postponed_Time - Remind_Interval);
         begin
            -- Only show the dashboard notice if it's been less than a minute since the message was postponed.
            if Time_Passed < Constants.MINUTE_IN_SECONDS then

               Echo ("        <div class=""notice notice-success is-dismissible"">");
               Echo ("            <p>");

               Printf (
                 -- translators: %s: Human-readable time interval.
                 abs "The admin email verification page will reappear after %s.",
                 [1 => Human_Time_Diff (Php.Misc.Time + Remind_Interval)]
               );
               Echo ("            </p>");
               Echo ("        </div>");
            end if;
         end;
      end if;

      if
        Has_Action ("welcome_panel") and then
        Current_User_Can ("edit_theme_options")
      then
         declare
            Classes : UString := +"welcome-panel";

            Option : constant Integer :=
              Get_User_Meta (Get_Current_User_Id, "show_welcome_panel", True);

            -- 0 = hide, 1 = toggled to show or single site creator,
            -- 2 = multisite site owner.
            Hide : constant Boolean :=
              (0 = Option or else
               (2 = Option and then
                Wp_Get_Current_User.Prop.User_Email /= Get_Option ("admin_email")));
         begin
            if Hide then
               Append (Classes, " hidden");
            end if;

            Echo ("        <div id=""welcome-panel"" class=""" & ESC_Attr (-Classes) & """>");
            Echo ("                " & Wp_Nonce_Field ("welcome-panel-nonce", "welcomepanelnonce", False));
            Echo ("                <a class=""welcome-panel-close"" href=""" &
                  ESC_URL (Admin_URL ("?welcome=0")) & """ aria-label=""");
            ESC_Attr_E ("Dismiss the welcome panel");
            Echo (""">");
            X_E ("Dismiss");
            Echo ("</a>");

            --
            -- Add content to the welcome panel on the admin dashboard.
            --
            -- To remove the default welcome panel, use remove_action():
            --
            --     remove_action( "welcome_panel", "wp_welcome_panel" );
            --
            -- @since 3.5.0
            --
            Do_Action ("welcome_panel");

            Echo ("        </div>");
         end;
      end if;

      Echo ("        <div id=""dashboard-widgets-wrap"">");
      Wp_Dashboard;
      Echo ("        </div><!-- dashboard-widgets-wrap -->");

      Echo ("</div><!-- wrap -->");

      Wp_Print_Community_Events_Templates;

      Adm_Admin_Footer.Run;

   end Render;

end Adm_Index;
