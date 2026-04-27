--
-- General settings administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Calendar;
with Php.Echoing;
with Php.Lists;
with Php.Misc;
with Php.Strings;

with Arrays;
with Array_Lists;
with Constants;
with Globals;
with Helpers;
with Lists;
with UStrings;
with Wp_Common;

with Adi_Options;
with Adi_Plugins;
with Adi_Screens;
with Adi_Templates;
with Adi_Translation_Install;

with Adm_Admin;
with Adm_Admin_Footer;
with Adm_Admin_Header;

with Class_Posts;

with Inc_Capabilities;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_General_Templates;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Media;
with Inc_Ms_Networks;
with Inc_Options;
with Inc_Plugins;
with Inc_Posts;

package body Adm_Options_General is
   use Arrays;
   use Lists;

   function Defined (Value : String) return Boolean is (True);
   function Defined (Value : String) return String is ("(true)");

   ------------
   -- Render --
   ------------

   procedure Render is
      use Php.Calendar;
      use Php.Echoing;
      use Php.Lists;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Adi_Plugins;
      use Adi_Screens;
      use Adi_Templates;
      use Adi_Translation_Install;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Media;
      use Inc_Ms_Networks;
      use Inc_Options;
      use Inc_Plugins;
      use Inc_Posts;

      -- translators: Date and time format for exact current time, mainly about timezones, see https://www.php.net/manual/datetime.format.php
      Timezone_Format : constant String :=
        X_X ("Y-m-d H:i:s", "timezone date format");
   begin

      -- WordPress Administration Bootstrap
      Adm_Admin.Run;

      -- WordPress Translation Installation API
      -- require_once ABSPATH . "wp-admin/includes/translation-install.php";

      if not Current_User_Can ("manage_options") then
         Wp_Die
           (abs "Sorry, you are not allowed to manage options for this site.");
      end if;

      -- Used in the HTML title tag.
      Globals.Global_Title := +abs "General Settings";
      Globals.Global_Parent_File := +"options-general.php";

      Add_Action ("admin_head", Adi_Options.Options_General_Add_JS'Access);

      declare
         Options_Help : UString :=
           +"<p>"
           & abs "The fields on this screen determine some of the basics of your site setup."
           & "</p>"
           & "<p>"
           & abs "Most themes show the site title at the top of every page, in the title bar of the browser, and as the identifying name for syndicated feeds. Many themes also show the tagline."
           & "</p>";
      begin
         if not Is_Multisite then
            Append
              (Options_Help,
               "<p>"
               & abs "Two terms you will want to know are the WordPress URL and the site URL. The WordPress URL is where the core WordPress installation files are, and the site URL is the address a visitor uses in the browser to go to your site."
               & "</p>"
               & "<p>"
               & Sprintf
                   (
                    -- translators: %s: Documentation URL.
                    abs "Though the terms refer to two different concepts, in practice, they can be the same address or different. For example, you can have the core WordPress installation files in the root directory (<code>https://example.com</code>), in which case the two URLs would be the same. Or the <a href=""%s"">WordPress files can be in a subdirectory</a> (<code>https://example.com/wordpress</code>). In that case, the WordPress URL and the site URL would be different.",
                    [abs "https://developer.wordpress.org/advanced-administration/server/wordpress-in-directory/"])
               & "</p>"
               & "<p>"
               & Sprintf
                   (
                    -- translators: 1: http://, 2: https://
                    abs "Both WordPress URL and site URL can start with either %1s or %2s. A URL starting with %2s requires an SSL certificate, so be sure that you have one before changing to %2s. With %2s, a padlock will appear next to the address in the browser address bar. Both %2s and the padlock signal that your site meets some basic security requirements, which can build trust with your visitors and with search engines.",
                    [1 => "<code>http://</code>",
                     2 => "<code>https://</code>"])
               & "</p>"
               & "<p>"
               & abs "If you want site visitors to be able to register themselves, check the membership box. If you want the site administrator to register every new user, leave the box unchecked. In either case, you can set a default user role for all new users."
               & "</p>");
         end if;

         Append
           (Options_Help,
            "<p>"
            & abs "You can set the language, and WordPress will automatically download and install the translation files (available if your filesystem is writable)."
            & "</p>"
            & "<p>"
            & abs "UTC means Coordinated Universal Time."
            & "</p>"
            & "<p>"
            & abs "You must click the Save Changes button at the bottom of the screen for new settings to take effect."
            & "</p>");

         Get_Current_Screen.Add_Help_Tab
           (To_Array_Type
              ([Build ("id", "overview"),
                Build ("title", abs "Overview"),
                Build ("content", -Options_Help)]));
      end;

      Get_Current_Screen.Set_Help_Sidebar
        ("<p><strong>"
         & abs "For more information:"
         & "</strong></p>"
         & "<p>"
         & abs "<a href=""https://wordpress.org/documentation/article/settings-general-screen/"">Documentation on General Settings</a>"
         & "</p>"
         & "<p>"
         & abs "<a href=""https://wordpress.org/support/forums/"">Support forums</a>"
         & "</p>");

      Adm_Admin_Header.Run;

      Echo ("<div class=""wrap"">");
      Echo ("<h1>" & ESC_HTML (-Globals.Global_Title) & "</h1>");

      Echo
        ("<form method=""post"" action=""options.php"" novalidate=""novalidate"">");
      Settings_Fields ("general");

      Echo ("<table class=""form-table"" role=""presentation"">");

      Echo ("<tr>");
      Echo ("<th scope=""row""><label for=""blogname"">");
      X_E ("Site Title");
      Echo ("</label></th>");
      Echo
        ("<td><input name=""blogname"" type=""text"" id=""blogname"" value=""");
      Form_Option ("blogname");
      Echo (""" class=""regular-text"" /></td>");
      Echo ("</tr>");

      declare
         Sample_Tagline : constant String :=
           (if not Is_Multisite
            then
              -- translators: Site tagline.
              abs "Just another WordPress site"
            else
              -- translators: %s: Network title.
              Sprintf (abs "Just another %s site", [-Get_Network.Site_Name]));

         Tagline_Description : constant String :=
           Sprintf
             (
              -- translators: %s: Site tagline example.
              abs "In a few words, explain what this site is about. Example: &#8220;%s.&#8221;",
              [Sample_Tagline]);
      begin
         Echo ("<tr>");
         Echo ("<th scope=""row""><label for=""blogdescription"">");
         X_E ("Tagline");
         Echo ("</label></th>");
         Echo
           ("<td><input name=""blogdescription"" type=""text"" id=""blogdescription"" aria-describedby=""tagline-description"" value=""");
         Form_Option ("blogdescription");
         Echo (""" class=""regular-text"" />");
         Echo
           ("<p class=""description"" id=""tagline-description"">"
            & Tagline_Description
            & "</p></td>");
         Echo ("</tr>");
      end;

      if Current_User_Can ("upload_files") then
         Echo ("<tr class=""hide-if-no-js site-icon-section"">");
         Echo ("<th scope=""row"">");
         X_E ("Site Icon");
         Echo ("</th>");
         Echo ("<td>");

         Wp_Enqueue_Media;
         Wp_Enqueue_Script ("site-icon");

         declare
            Classes_For_Upload_Button : constant String :=
              "upload-button button-add-media button-add-site-icon";

            Classes_For_Update_Button : constant String := "button";

            Classes_For_Wrapper          : UString;
            Classes_For_Button           : UString;
            Classes_For_Button_On_Change : UString;
         begin
            if Has_Site_Icon then
               Append (Classes_For_Wrapper, " has-site-icon");
               Classes_For_Button := +Classes_For_Update_Button;
               Classes_For_Button_On_Change := +Classes_For_Upload_Button;
            else
               Append (Classes_For_Wrapper, " hidden");
               Classes_For_Button := +Classes_For_Upload_Button;
               Classes_For_Button_On_Change := +Classes_For_Update_Button;
            end if;

            -- Handle alt text for site icon on page load.
            declare
               Site_Icon_Id           : constant Integer :=
                 Integer'(Get_Option ("site_icon"));
               App_Icon_Alt_Value     : UString;
               Browser_Icon_Alt_Value : UString;

               Site_Icon_URL : constant String := Get_Site_Icon_URL;
            begin
               if Site_Icon_Id /= 0 then
                  declare
                     Img_Alt : constant String :=
                       Get_Post_Meta
                         (Class_Posts.Post_Id_Type (Site_Icon_Id),
                          "_wp_attachment_image_alt",
                          True);

                     Filename : constant String := Wp_Basename (Site_Icon_URL);

                     App_Icon_Alt_Value : String :=
                       Sprintf
                         (
                          -- translators: %s: The selected image filename.
                          abs "App icon preview: The current image has no alternative text. The file name is: %s",
                          [Filename]);

                     Browser_Icon_Alt_Value : String :=
                       Sprintf
                         (
                          -- translators: %s: The selected image filename.
                          abs "Browser icon preview: The current image has no alternative text. The file name is: %s",
                          [Filename]);
                  begin
                     if Img_Alt /= "" then
                        App_Icon_Alt_Value :=
                          Sprintf
                            (
                             -- translators: %s: The selected image alt text.
                             abs "App icon preview: Current image: %s",
                             [Img_Alt]);

                        Browser_Icon_Alt_Value :=
                          Sprintf
                            (
                             -- translators: %s: The selected image alt text.
                             abs "Browser icon preview: Current image: %s",
                             [Img_Alt]);
                     end if;
                  end;
               end if;

               Echo (TAB1 & "<style>" & NL);
               Echo (TAB1 & ":root {" & NL);
               Echo
                 (TAB2 & "--site-icon-url: url( "
                  & ESC_URL (Site_Icon_URL)
                  & " );" & NL);
               Echo (TAB1 & "}" & NL);
               Echo (TAB1 & "</style>" & NL);

               Echo
                 (TAB1 & "<div id=""site-icon-preview"" class=""site-icon-preview settings "
                  & ESC_Attr (-Classes_For_Wrapper)
                  & """>" & NL);
               Echo (TAB2 & " <div class=""direction-wrap"">" & NL);
               Echo
                 (TAB3 & "<img id=""app-icon-preview"" src="""
                  & ESC_URL (Site_Icon_URL)
                  & """ class=""app-icon-preview"" alt="""
                  & ESC_Attr (-App_Icon_Alt_Value)
                  & """ />" & NL);
               Echo
                 (TAB3 & "<div class=""site-icon-preview-browser"">" & NL);
               Echo
                 (TAB4 & "<svg role=""img"" aria-hidden=""true"" fill=""none"" xmlns=""http://www.w3.org/2000/svg"" class=""browser-buttons""><path fill-rule=""evenodd"" clip-rule=""evenodd"" d=""M0 20a6 6 0 1 1 12 0 6 6 0 0 1-12 0Zm18 0a6 6 0 1 1 12 0 6 6 0 0 1-12 0Zm24-6a6 6 0 1 0 0 12 6 6 0 0 0 0-12Z"" /></svg>" & NL);
               Echo
                 (TAB4 & "<div class=""site-icon-preview-tab"">" & NL);
               Echo
                 (TAB5 & "<img id=""browser-icon-preview"" src="""
                  & ESC_URL (Site_Icon_URL)
                  & """ class=""browser-icon-preview"" alt="""
                  & ESC_Attr (-Browser_Icon_Alt_Value)
                  & """ />" & NL);
               Echo
                 (TAB5 & "<div class=""site-icon-preview-site-title"" id=""site-icon-preview-site-title"" aria-hidden=""true"">");
               Bloginfo ("name");
               Echo ("</div>" & NL);
               Echo
                 (TAB6 & "<svg role=""img"" aria-hidden=""true"" fill=""none"" xmlns=""http://www.w3.org/2000/svg"" class=""close-button"">" & NL);
               Echo
                 (TAB7 & " <path d=""M12 13.0607L15.7123 16.773L16.773 15.7123L13.0607 12L16.773 8.28772L15.7123 7.22706L12 10.9394L8.28771 7.22705L7.22705 8.28771L10.9394 12L7.22706 15.7123L8.28772 16.773L12 13.0607Z"" />" & NL);
               Echo (TAB6 & " </svg>" & NL);
               Echo (TAB5 & "</div>" & NL);
               Echo (TAB4 & "</div>" & NL);
               Echo (TAB3 & "</div>" & NL);
               Echo (TAB2 & "</div>" & NL);
               Echo (TAB1 & "</div>" & NL);
            end;

            Echo
              (TAB1 & "<input type=""hidden"" name=""site_icon"" id=""site_icon_hidden_field"" value=""");
            Form_Option ("site_icon");
            Echo (""" />" & NL);
            Echo (TAB1 & "<div class=""site-icon-action-buttons"">" & NL);
            Echo (TAB2 & "<button type=""button""" & NL);
            Echo (TAB3 & "id=""choose-from-library-button""" & NL);
            Echo
              (TAB3 & "class="""
               & ESC_Attr (-Classes_For_Button)
               & """" & NL);
            Echo
              (TAB3 & "data-alt-classes="""
               & ESC_Attr (-Classes_For_Button_On_Change)
               & """" & NL);
            Echo (TAB3 & "data-size=""512""" & NL);
            Echo (TAB3 & "data-choose-text=""");
            ESC_Attr_E ("Choose a Site Icon");
            Echo ("""" & NL);
            Echo (TAB3 & "data-update-text=""");
            ESC_Attr_E ("Change Site Icon");
            Echo ("""" & NL);
            Echo (TAB3 & "data-update=""");
            ESC_Attr_E ("Set as Site Icon");
            Echo ("""" & NL);
            Echo
              (TAB3 & "data-state="""
               & ESC_Attr (Boolean'Image (Has_Site_Icon))
               & """" & NL);

            Echo (TAB2 & " >");
            if Has_Site_Icon then
               X_E ("Change Site Icon");
            else
               X_E ("Choose a Site Icon");
            end if;
            Echo (TAB2 & "</button>" & NL);
            Echo (TAB2 & "<button " & NL);
            Echo (TAB3 & "id=""js-remove-site-icon""" & NL);
            Echo (TAB3 & "type=""button""" & NL);
            Echo
              (TAB3
               & (if Has_Site_Icon
                  then
                    "class=""button button-secondary reset remove-site-icon"""
                  else "class=""button button-secondary reset hidden"""));
            Echo (TAB2 & " >" & NL);
            Echo (TAB3);
            X_E ("Remove Site Icon");
            Echo (TAB2 & "</button>" & NL);
            Echo (TAB1 & "</div>" & NL);
         end;

         Echo (TAB1 & "<p class=""description"">" & NL);
         Printf
           (
            -- translators: 1: pixel value for icon size. 2: pixel value for icon size.
            abs "The Site Icon is what you see in browser tabs, bookmark bars, and within the WordPress mobile apps. It should be square and at least <code>%1s by %2s</code> pixels.",
            [1 => "512", 2 => "512"]);
         Echo (TAB1 & "</p>" & NL);

         Echo (TAB0 & "</td>" & NL);
         Echo (TAB0 & "</tr>" & NL);

      end if;
      -- End Site Icon

      if not Is_Multisite then
         declare
            Wp_Site_URL_Class : UString;
            Wp_Home_Class     : UString;
         begin
            if Defined ("WP_SITEURL") then
               Wp_Site_URL_Class := +" disabled";
            end if;
            if Defined ("WP_HOME") then
               Wp_Home_Class := +" disabled";
            end if;

            Echo ("<tr>");
            Echo ("<th scope=""row""><label for=""siteurl"">");
            X_E ("WordPress Address (URL)");
            Echo ("</label></th>");
            Echo
              ("<td><input name=""siteurl"" type=""url"" id=""siteurl"" value=""");
            Form_Option ("siteurl");
            Echo
              (""""
               & Disabled (Defined ("WP_SITEURL"))
               & " class=""regular-text code"
               & (-Wp_Site_URL_Class)
               & """ /></td>");
            Echo ("</tr>");

            Echo ("<tr>");
            Echo ("<th scope=""row""><label for=""home"">");
            X_E ("Site Address (URL)");
            Echo ("</label></th>");
            Echo
              ("<td><input name=""home"" type=""url"" id=""home"" aria-describedby=""home-description"" value=""");
            Form_Option ("home");
            Echo
              (""""
               & Disabled (Defined ("WP_HOME"))
               & " class=""regular-text code"
               & (-Wp_Home_Class)
               & """ />");
         end;

         if not Defined ("WP_HOME") then
            Echo ("<p class=""description"" id=""home-description"">");
            Printf
              (
               -- translators: %s: Documentation URL.
               abs "Enter the same address here unless you <a href=""%s"">want your site home page to be different from your WordPress installation directory</a>.",
               [abs "https://developer.wordpress.org/advanced-administration/server/wordpress-in-directory/"]);

            Echo ("</p>");
         end if;
         Echo ("</td>");
         Echo ("</tr>");

      end if;

      Echo ("<tr>");
      Echo ("<th scope=""row""><label for=""new_admin_email"">");
      X_E ("Administration Email Address");
      Echo ("</label></th>");
      Echo
        ("<td><input name=""new_admin_email"" type=""email"" id=""new_admin_email"" aria-describedby=""new-admin-email-description"" value=""");
      Form_Option ("admin_email");
      Echo (""" class=""regular-text ltr"" />");
      Echo ("<p class=""description"" id=""new-admin-email-description"">");
      X_E
        ("This address is used for admin purposes. If you change this, an email will be sent to your new address to confirm it. <strong>The new address will not become active until confirmed.</strong>");
      Echo ("</p>");

      declare
         New_Admin_Email : constant String := Get_Option ("new_admin_email");
      begin
         if New_Admin_Email /= ""
           and then Get_Option ("admin_email") /= New_Admin_Email
         then
            declare
               Pending_Admin_Email_Message : UString :=
                 +Sprintf
                    (
                     -- translators: %s: New admin email.
                     abs "There is a pending change of the admin email to %s.",
                     ["<code>" & ESC_HTML (New_Admin_Email) & "</code>"]);
            begin
               Append
                 (Pending_Admin_Email_Message,
                  Sprintf
                    (" <a href=""%1s"">%2s</a>",
                     [1 =>
                        ESC_URL
                          (Wp_Nonce_URL
                             (Admin_URL
                                ("options.php?dismiss=new_admin_email"),
                              "dismiss-"
                              & Helpers.Image (Get_Current_Blog_Id)
                              & "-new_admin_email")),
                      2 => abs "Cancel"]));

               Wp_Admin_Notice
                 (-Pending_Admin_Email_Message,
                  To_Array_Type
                    ([Build
                        ("additional_classes",
                         List_Type'["updated", "inline"])]));
            end;
         end if;
      end;

      Echo ("</td>");
      Echo ("</tr>");

      if not Is_Multisite then

         Echo ("<tr>");
         Echo ("<th scope=""row"">");
         X_E ("Membership");
         Echo ("</th>");
         Echo ("<td> <fieldset><legend class=""screen-reader-text""><span>");

         -- translators: Hidden accessibility text.
         X_E ("Membership");

         Echo ("</span></legend><label for=""users_can_register"">");
         Echo
           ("<input name=""users_can_register"" type=""checkbox"" id=""users_can_register"" value=""1"" "
            & Checked ("1", Get_Option ("users_can_register"))
            & " />");
         Echo ("        ");
         X_E ("Anyone can register");
         Echo ("</label>");
         Echo ("</fieldset></td>");
         Echo ("</tr>");

         Echo ("<tr>");
         Echo ("<th scope=""row""><label for=""default_role"">");
         X_E ("New User Default Role");
         Echo ("</label></th>");
         Echo ("<td>");
         Echo ("<select name=""default_role"" id=""default_role"">");
         Wp_Dropdown_Roles (Get_Option ("default_role"));
         Echo ("</select>");
         Echo ("</td>");
         Echo ("</tr>");

      end if;

      declare
         Languages    : List_Type := Get_Available_Languages;
         Translations : constant Array_Type := Wp_Get_Available_Translations;
      begin
         if not Is_Multisite
           and then Defined ("WPLANG")
           and then "" /= Constants.WPLANG
           and then "en_US" /= Constants.WPLANG
           and then not In_List (Constants.WPLANG, Languages, True)
         then
            Append (Languages, Constants.WPLANG);
         end if;
         if not Languages.Is_Empty or else not Translations.Is_Empty then

            Echo (TAB1 & "<tr>" & NL);
            Echo (TAB2 & "<th scope=""row""><label for=""WPLANG"">");
            X_E ("Site Language");
            Echo
              ("<span class=""dashicons dashicons-translation"" aria-hidden=""true""></span></label></th>");
            Echo (TAB2 & "<td>" & NL);

            declare
               Locale_2 : constant String := Get_Locale;

               Locale : constant String :=
                 (if not In_List (Locale_2, Languages, True)
                  then ""
                  else Locale_2);
            begin
               Wp_Dropdown_Languages
                 (To_Array_Type
                    ([Build ("name", "WPLANG"),
                      Build ("id", "WPLANG"),
                      Build ("selected", Locale),
                      Build ("languages", Languages),
                      Build ("translations", Translations),
                      Build
                        ("show_available_translations",
                         Current_User_Can ("install_languages")
                         and then Wp_Can_Install_Language_Pack)]));

               -- Add note about deprecated WPLANG constant.
               if Defined ("WPLANG")
                 and then ("" /= Constants.WPLANG)
                 and then Constants.WPLANG /= Locale
               then
                  X_Deprecated_Argument
                    ("define()",
                     "4.0.0",
                     -- translators: 1: WPLANG, 2: wp-config.php
                     Sprintf
                       (abs "The %1s constant in your %2s file is no longer needed.",
                        ["WPLANG", "wp-config.php"]));
               end if;
            end;

            Echo (TAB2 & "</td>" & NL);
            Echo (TAB1 & "</tr>" & NL);

         end if;
      end;

      Echo (TAB0 & "<tr>" & NL);

      declare
         Current_Offset : constant String := Get_Option ("gmt_offset");

         Check_Zone_Info : Boolean := True;

         TZ_String_3 : constant String := Get_Option ("timezone_string");

         -- Remove old Etc mappings. Fallback to gmt_offset.
         TZ_String_2 : constant String :=
           (if Str_Contains (TZ_String_3, "Etc/GMT") then "" else TZ_String_3);

         -- Create a UTC+- zone if no timezone string exists.
         TZ_String : constant String :=
           (if Empty (TZ_String_2)
            then
              (if 0 = Integer'Value (Current_Offset)
               then "UTC+0"
               elsif Integer'Value (Current_Offset) < 0
               then "UTC" & Current_Offset
               else "UTC+" & Current_Offset)
            else TZ_String_2);
      begin
         if Empty (TZ_String_2) then
            Check_Zone_Info := False;
         end if;

         Echo (TAB0 & "<th scope=""row""><label for=""timezone_string"">");
         X_E ("Timezone");
         Echo ("</label></th>" & NL);
         Echo (TAB0 & "<td>" & NL);

         Echo
           (TAB0 & "<select id=""timezone_string"" name=""timezone_string"" aria-describedby=""timezone-description"">" & NL);
         Echo (TAB1 & Wp_Timezone_Choice (TZ_String, Get_User_Locale));
         Echo ("</select>" & NL);

         Echo (TAB0 & "<p class=""description"" id=""timezone-description"">" & NL);

         Printf
           (
            -- translators: %s: UTC abbreviation
            abs "Choose either a city in the same timezone as you or a %s (Coordinated Universal Time) time offset.",
            ["<abbr>UTC</abbr>"]);

         Echo (TAB0 & "</p>" & NL);

         Echo (TAB0 & "<p class=""timezone-info"">" & NL);
         Echo (TAB1 & "<span id=""utc-time"">" & NL);

         Printf
           (
            -- translators: %s: UTC time.
            abs "Universal time is %s.",
            ["<code>"
             & Date_I18n
                 (Timezone_Format,
                  0, -- False,
                  True)
             & "</code>"]);

         Echo (TAB1 & "</span>" & NL);
         if Get_Option ("timezone_string") or else not Empty (Current_Offset)
         then
            Echo (TAB1 & "<span id=""local-time"">" & NL);

            Printf
              (
               -- translators: %s: Local time.
               abs "Local time is %s.",
               ["<code>" & Date_I18n (Timezone_Format) & "</code>"]);

            Echo (TAB1 & "</span>" & NL);
         end if;
         Echo (TAB0 & "</p>" & NL);

         if Check_Zone_Info and then TZ_String /= "" then
            Echo (TAB0 & "<p class=""timezone-info"">" & NL);
            Echo (TAB0 & "<span>" & NL);

            declare
               Zone : constant Date_Time_Zone := X_Construct (TZ_String);

               Now : constant Date_Time := X_Construct ("now", Zone);

               DST : constant Boolean := Now.Format ("I") /= "";
            begin
               if DST then
                  X_E ("This timezone is currently in daylight saving time.");
               else
                  X_E ("This timezone is currently in standard time.");
               end if;
            end;

            Echo (TAB1 & "<br />" & NL);

            if In_List
                 (TZ_String,
                  Php.Misc.Timezone_Identifiers_List (Php.Misc.ALL_WITH_BC),
                  True)
            then
               declare
                  Transitions : constant Array_Type :=
                    Php.Misc.Timezone_Transitions_Get
                      (Php.Misc.Timezone_Open (TZ_String), Php.Misc.Time);
               begin
                  -- 0 index is the state at current time, 1 index is the next transition, if any.
                  if not Empty (Transitions.First_Key) then
                     Echo (" ");
                     declare
                        Message : constant String :=
                          (if False
                           then -- transitions[1]["isdst"] then XXX
                             -- translators: %s: Date and time.
                             abs "Daylight saving time begins on: %s."
                           else
                             -- translators: %s: Date and time.
                             abs "Standard time begins on: %s.");
                     begin
                        Printf
                          (Message,
                           ["<code>"
                            & "XXX-E93"
                            -- & Wp_Date
                            --     (abs "F j, Y" & " " & abs "g:i a",
                            --      "XXX-E93" -- transitions[1]["ts"]
                            --     )
                            & "</code>"]);
                     end;
                  else
                     X_E
                       ("This timezone does not observe daylight saving time.");
                  end if;
               end;
            end if;

            Echo (TAB1 & "</span>" & NL);
            Echo (TAB0 & "</p>" & NL);
         end if;
         Echo (TAB0 & "</td>" & NL);
         Echo (TAB0 & "</tr>" & NL);
      end;

      Echo (TAB0 & "<tr>" & NL);
      Echo (TAB0 & "<th scope=""row"">");
      X_E ("Date Format");
      Echo ("</th>" & NL);
      Echo (TAB0 & "<td>" & NL);
      Echo (TAB1 & "<fieldset><legend class=""screen-reader-text""><span>" & NL);
      -- translators: Hidden accessibility text.
      X_E ("Date Format");
      Echo (TAB1 & "</span></legend>" & NL);

      --
      -- Filters the default date formats.
      --
      -- @since 2.7.0
      -- @since 4.0.0 Replaced the `Y/m/d` format with `Y-m-d` (ISO date standard YYYY-MM-DD).
      -- @since 6.8.0 Added the `d.m.Y` format.
      --
      -- @param string[] default_date_formats Array of default date formats.
      --
      declare
         Date_Formats : constant List_Type :=
           List_Unique
             (Apply_Filters
                ("date_formats",
                 List_Type'
                   [abs "F j, Y", "Y-m-d", "m/d/Y", "d/m/Y", "d.m.Y"]));

         Custom : Boolean := True;
      begin
         for Format of Date_Formats loop
            Echo
              (TAB1 & "<label><input type=""radio"" name=""date_format"" value="""
               & ESC_Attr (Format)
               & """");
            if Get_Option ("date_format") = Format then
               -- checked() uses "==" rather than "===".
               Echo (" checked=""checked""");
               Custom := False;
            end if;
            Echo
              (" /> <span class=""date-time-text format-i18n"">"
               & Date_I18n (Format)
               & "</span><code>"
               & ESC_HTML (Format)
               & "</code></label><br />" & NL);
         end loop;

         Echo
           ("<label><input type=""radio"" name=""date_format"" id=""date_format_custom_radio"" value=""\c\u\s\t\o\m""");
         Echo (Checked (Custom));
         Echo
           ("/> <span class=""date-time-text date-time-custom-text"">"
            & abs "Custom:"
            & "<span class=""screen-reader-text""> "
            &
            -- translators: Hidden accessibility text.
                                                       abs "enter a custom date format in the following field"
            & "</span></span></label>"
            & "<label for=""date_format_custom"" class=""screen-reader-text"">"
            &
            -- translators: Hidden accessibility text.
                                                       abs "Custom date format:"
            & "</label>"
            & "<input type=""text"" name=""date_format_custom"" id=""date_format_custom"" value="""
            & ESC_Attr (Get_Option ("date_format"))
            & """ class=""small-text"" />"
            & "<br />"
            & "<p><strong>"
            & abs "Preview:"
            & "</strong> <span class=""example"">"
            & Date_I18n (Get_Option ("date_format"))
            & "</span>"
            & "<span class=""spinner""></span>" & NL
            & "</p>");

         Echo (TAB1 & "</fieldset>" & NL);
         Echo (TAB0 & "</td>" & NL);
         Echo (TAB0 & "</tr>" & NL);
      end;

      Echo (TAB0 & "<tr>" & NL);
      Echo (TAB0 & "<th scope=""row"">");
      X_E ("Time Format");
      Echo ("</th>" & NL);
      Echo (TAB0 & "<td>" & NL);
      Echo (TAB1 & "<fieldset><legend class=""screen-reader-text""><span>");
      -- translators: Hidden accessibility text.
      X_E ("Time Format");
      Echo (TAB1 & "</span></legend>" & NL);

      --
      -- Filters the default time formats.
      --
      -- @since 2.7.0
      --
      -- @param string[] default_time_formats Array of default time formats.
      --
      declare
         Time_Formats : constant List_Type :=
           List_Unique
             (Apply_Filters
                ("time_formats", List_Type'[abs "g:i a", "g:i A", "H:i"]));

         Custom : Boolean := True;
      begin
         for Format of Time_Formats loop
            Echo
              (TAB1 & "<label><input type=""radio"" name=""time_format"" value="""
               & ESC_Attr (Format)
               & """");
            if Get_Option ("time_format") = Format then
               -- checked() uses "==" rather than "===".
               Echo (" checked=""checked""");
               Custom := False;
            end if;
            Echo
              (" /> <span class=""date-time-text format-i18n"">"
               & Date_I18n (Format)
               & "</span><code>"
               & ESC_HTML (Format)
               & "</code></label><br />" & NL);
         end loop;

         Echo
           ("<label><input type=""radio"" name=""time_format"" id=""time_format_custom_radio"" value=""\c\u\s\t\o\m""");
         Echo (Checked (Custom));
         Echo
           ("/> <span class=""date-time-text date-time-custom-text"">"
            & abs "Custom:"
            & "<span class=""screen-reader-text""> "
            &
            -- translators: Hidden accessibility text.
                                                       abs "enter a custom time format in the following field"
            & "</span></span></label>"
            & "<label for=""time_format_custom"" class=""screen-reader-text"">"
            &
            -- translators: Hidden accessibility text.
                                                       abs "Custom time format:"
            & "</label>"
            & "<input type=""text"" name=""time_format_custom"" id=""time_format_custom"" value="""
            & ESC_Attr (Get_Option ("time_format"))
            & """ class=""small-text"" />"
            & "<br />"
            & "<p><strong>"
            & abs "Preview:"
            & "</strong> <span class=""example"">"
            & Date_I18n (Get_Option ("time_format"))
            & "</span>"
            & "<span class=""spinner""></span>" & NL
            & "</p>");

         Echo
           (TAB1 & "<p class=""date-time-doc"">"
            & abs "<a href=""https://wordpress.org/documentation/article/customize-date-and-time-format/"">Documentation on date and time formatting</a>."
            & "</p>" & NL);

         Echo ("        </fieldset>");
         Echo ("</td>");
         Echo ("</tr>");
      end;

      Echo ("<tr>");
      Echo ("<th scope=""row""><label for=""start_of_week"">");
      X_E ("Week Starts On");
      Echo ("</label></th>");
      Echo ("<td><select name=""start_of_week"" id=""start_of_week"">");

      --
      -- @global WP_Locale wp_locale WordPress date and time locale object.
      --
      -- global wp_locale;

      for Day_Index in 0 .. 6 loop
         declare
            Selected : constant String :=
              (if Integer'(Get_Option ("start_of_week")) = Day_Index
               then "selected=""selected"""
               else "");
         begin
            Echo
              (NL & TAB1 & "<option value="""
               & ESC_Attr (Helpers.Image (Day_Index))
               & """ " & Selected & ">"
               & Globals.Wp_Locale.Get_Weekday (Day_Index)
               & "</option>");
         end;
      end loop;

      Echo ("</select></td>");
      Echo ("</tr>");
      Do_Settings_Fields ("general", "default");
      Echo ("</table>");

      Do_Settings_Sections ("general");

      Submit_Button;
      Echo ("</form>");

      Echo ("</div>");

      Adm_Admin_Footer.Run;
   end Render;

end Adm_Options_General;
