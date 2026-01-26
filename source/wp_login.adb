--
-- WordPress User Page
--
-- Handles authentication, registering, resetting passwords, forgot password,
-- and other user handling.
--
-- @package WordPress
--

with Php.Arrays;
with Php.Echoing;
with Php.Errors;
with Php.Files;
with Php.Lists;
with Php.Misc;
with Php.HTML;
with Php.Preg;
with Php.Strings;

with Arrays;
with Binder;
with Globals;
with Lists;
with UStrings;
with Wp_Common;
with Wp_Load;

with Inc_Capabilities;
with Class_Phpass;
with Class_Errors;
with Class_Recovery_Mode_Link_Services;
with Class_Sites;
with Class_Users;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_Functions_Wp_Styles;
with Inc_General_Templates;
with Inc_HTTP;
with Inc_Link_Templates;
with Inc_Load;
with Inc_L10n;
with Inc_Ms_Functions;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Themes;
with Inc_Robots_Templates;
with Inc_Users;

package body Wp_Login
is
   use Arrays;
   use Lists;

   Error         : Class_Errors.Wp_Error;
   Interim_Login : Boolean;
   Action        : UStrings.UString;
   --
   -- Output the login page header.
   --
   -- @since 2.1.0
   --
   -- @global string      error         Login error message set by deprecated
   --                                   pluggable wp_login() function or plugins
   --                                   replacing it.
   -- @global bool|string interim_login Whether interim login modal is being
   --                                   displayed. String "success" upon successful
   --                                   login.
   -- @global string      action        The action that brought the visitor to the
   --                                   login page.
   --
   -- @param string   title    Optional. WordPress login Page title to display in
   --                          the `<title>` element. Default "Log In".
   -- @param string   message  Optional. Message to display in header. Default empty.
   -- @param WP_Error wp_error Optional. The error to pass. Default is a WP_Error
   --                          instance.
   --
   procedure Login_Header (Title      : String := "Log In";
                           Message    : String := "";
                           Wp_Error_X : Class_Errors.Wp_Error :=
                                          Class_Errors.Null_Wp_Error); -- null

   --
   -- Outputs the footer for the login page.
   --
   -- @since 3.1.0
   --
   -- @global bool|string interim_login Whether interim login modal is being
   --                                   displayed. String "success" upon successful
   --                                   login.
   --
   -- @param string input_id Which input to auto-focus.
   --
   procedure Login_Footer (Input_Id : String := "");

   --
   -- Outputs the JavaScript to handle the form shaking on the login page.
   --
   -- @since 3.0.0
   --
   procedure Wp_Shake_JS;

   --
   -- Outputs the viewport meta tag for the login page.
   --
   -- @since 3.7.0
   --
   procedure Wp_Login_Viewport_Meta;

   procedure Action_Confirm_Admin_Email (Errors : Class_Errors.Wp_Error);
   procedure Action_Postpass;
   procedure Action_Logout;
   procedure Action_Lostpassword (Login_Link_Separator : String;
                                  HTTP_Post            : Boolean);
   procedure Action_Resetpass (Login_Link_Separator : String);
   procedure Action_Register (Login_Link_Separator : String;
                              HTTP_Post            : Boolean);
   procedure Action_Checkmail;
   procedure Action_Confirmaction;
   procedure Action_Login (Login_Link_Separator : String);

   ------------------
   -- Login_Header --
   ------------------

   procedure Login_Header (Title      : String := "Log In";
                           Message    : String := "";
                           Wp_Error_X : Class_Errors.Wp_Error :=
                                          Class_Errors.Null_Wp_Error)
   is
      use Php.Echoing;
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Errors;
      use Inc_Formatting;
      use Inc_Functions_Wp_Styles;
      use Inc_General_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Plugins;
--    global error, interim_login, action;
      Wp_Error_2 : Wp_Error := Wp_Error_X;
   begin
      -- Don't index any of these forms.
      Add_Filter ("wp_robots",
                  Inc_Robots_Templates.Wp_Robots_Sensitive_Page'Access);
      Add_Action ("login_head",
                  Inc_General_Templates.Wp_Strict_Cross_Origin_Referrer'Access);

      Add_Action ("login_head", Wp_Login_Viewport_Meta'Access);

      if not Is_Wp_Error (Error) then
         Wp_Error_2 := X_Construct; --  = new WP_Error();
      end if;

      -- Shake it!
      declare
         Shake_Error_Codes_2 : constant List_Type := To_List (List => (
           +"empty_password", +"empty_email", +"invalid_email", +"invalidcombo",
           +"empty_username", +"invalid_username", +"incorrect_password",
           +"retrieve_password_email_failure"));

         --
         -- Filters the error codes array for shaking the login form.
         --
         -- @since 3.0.0
         --
         -- @param string[] shake_error_codes Error codes that shake the login form.
         --
         Shake_Error_Codes : constant List_Type :=
           Apply_Filters ("shake_error_codes", Shake_Error_Codes_2);
      begin
         if
           not Shake_Error_Codes.Is_Empty and then
--         Shake_Error_Codes and then
           Wp_Error_2.Has_Errors and then
           In_List (Error.Get_Error_Code, Shake_Error_Codes, True)
         then
            Add_Action ("login_footer", Wp_Shake_JS'Access, 12);
         end if;
      end;

      declare
         Login_Title_4 : constant String :=
           Get_Bloginfo ("name", "display");

         -- translators: Login screen title. 1: Login screen name, 2: Network or site name.
         Login_Title_3 : constant String :=
           Sprintf (abs "%1s &lsaquo; %2s &#8212; WordPress",
                    To_List (List => (
                      1 => +Title,
                      2 => +Login_Title_4
                    )));

         Login_Title_2 : constant String :=
           (if Wp_Is_Recovery_Mode
              -- translators: %s: Login screen title.
              then Sprintf (abs "Recovery Mode &#8212; %s", To_List (Login_Title_3))
            else Login_Title_3);

         --
         -- Filters the title tag content for login page.
         --
         -- @since 4.9.0
         --
         -- @param string login_title The page title, with extra context added.
         -- @param string title       The original page title.
         --
         Login_Title : constant String :=
           Apply_Filters ("login_title", Login_Title_2, Title);
      begin
         Echo ("<!DOCTYPE html>" & NL);
         Echo ("<html ");
         Language_Attributes;
         Echo (">" & NL);
         Echo ("<head>"  & NL);
         Echo ("  <meta http-equiv=""Content-Type"" content=" &
               Get_Bloginfo ("html_type") & "; charset=" &
               Get_Bloginfo ("charset") & " />" & NL);
         Echo ("  <title>" & Login_Title & "</title>" & NL);
      end;

      Wp_Enqueue_Style ("login");

      --
      -- Remove all stored post data on logging out.
      -- This could be added by add_action("login_head"...) like wp_shake_js(),
      -- but maybe better if it"s not removable by plugins.
      --
      if "loggedout" = Error.Get_Error_Code then
         Echo ("       <script>if('sessionStorage' in window){try{for(var key in sessionStorage){if(key.indexOf('wp-autosave-')!=-1){sessionStorage.removeItem(key)}}}catch(e){}};</script>" & NL);
      end if;

      --
      -- Enqueue scripts and styles for the login page.
      --
      -- @since 3.1.0
      --
      Do_Action ("login_enqueue_scripts");

      --
      -- Fires in the login page header after scripts are enqueued.
      --
      -- @since 2.1.0
      --
      Do_Action ("login_head");

      declare
         Login_Header_URL_2 : constant String :=
           abs "https://wordpress.org/";

         --
         -- Filters link URL of the header logo above login form.
         --
         -- @since 2.1.0
         --
         -- @param string login_header_url Login header logo URL.
         --
         Login_Header_URL : constant String :=
           Apply_Filters ("login_headerurl", Login_Header_URL_2);

         Login_Header_Title_2 : constant String := "";

         --
         -- Filters the title attribute of the header logo above login form.
         --
         -- @since 2.1.0
         -- @deprecated 5.2.0 Use then@see "login_headertext"end; instead.
         --
         -- @param string login_header_title Login header logo title attribute.
         --
         Login_Header_Title : constant String :=
           Apply_Filters_Deprecated (
             "login_headertitle",
             To_List (Login_Header_Title_2), -- array(
             "5.2.0",
             "login_headertext",
             abs "Usage of the title attribute on the login logo is not recommended for accessibility reasons. Use the link text instead."
           );

         Login_Header_Text_2 : constant String :=
           (if Empty (Login_Header_Title)
            then abs "Powered by WordPress"
            else Login_Header_Title);

         --
         -- Filters the link text of the header logo above the login form.
         --
         -- @since 5.2.0
         --
         -- @param string login_header_text The login header logo link text.
         --
         Login_Header_Text : constant String :=
           Apply_Filters ("login_headertext", Login_Header_Text_2);

         Classes : List_Type :=
           To_List (List => (+"login-action-" & Action, +"wp-core-ui"));
      begin
         if Is_RTL then
            Classes.Append (+"rtl");
         end if;

         if Interim_Login then
            Classes.Append (+"interim-login");

            Echo ("    <style type=""text/css"">html{background-color: transparent;}</style>" & NL);

            if Interim_Login then
--          if "success" = Interim_Login then
               Classes.Append (+"interim-login-success");
            end if;
         end if;

         Classes.Append (+" locale-" &
                         Sanitize_HTML_Class (
                           Strtolower (
                             Str_Replace ("_", "-", Get_Locale))));

         --
         -- Filters the login page body classes.
         --
         -- @since 3.5.0
         --
         -- @param string[] classes An array of body classes.
         -- @param string   action  The action that brought the visitor to the
         --                         login page.
         --
         Classes := Apply_Filters ("login_body_class", Classes, -Action);

         Echo ("</head>" & NL);
         Echo ("<body class=""login no-js " &
               ESC_Attr (Implode (" ", Classes)) &
               """>" & NL);
         Echo ("<script type=""text/javascript"">" & NL &
               "  document.body.className = document.body.className.replace('no-js','js');" & NL);
         Echo ("</script>" & NL);

         --
         -- Fires in the login page header after the body tag is opened.
         --
         -- @since 4.6.0
         --
         Do_Action ("login_header");

         Echo ("<div id=""login"">" & NL);
         Echo ("  <h1><a href=""" &
               ESC_URL (Login_Header_URL) & """>" &
               Login_Header_Text & "</a></h1>" & NL);
      end;

      declare
         --
         -- Filters the message to display above the login form.
         --
         -- @since 2.1.0
         --
         -- @param string message Login message text.
         --
         Message_2 : constant String :=
           Apply_Filters ("login_message", Message);
      begin
         if not Empty (Message_2) then
            Echo (Message_2 & NL);
         end if;

         -- In case a plugin uses error rather than the wp_errors object.
         -- if not Empty (Error) then
         --    Wp_Error_2.Add ("error", Error);
         --    Unset (Error);
         -- end if;
      end;

      if Wp_Error_2.Has_Errors then
         declare
            Errors   : UString;
            Messages : UString;
         begin
            for Code of Wp_Error_2.Get_Error_Codes loop
               declare
                  Severity : constant String := Wp_Error_2.Get_Error_Data (-Code);
               begin
                  for Error_Message of Wp_Error_2.Get_Error_Messages (-Code) loop
                     if "message" = Severity then
                        Append (Messages, "  " & Error_Message & "<br />" & NL);
                     else
                        Append (Errors, "    " & Error_Message & "<br />" & NL);
                     end if;
                  end loop;
               end;
            end loop;

            if not Empty (-Errors) then
               --
               -- Filters the error messages displayed above the login form.
               --
               -- @since 2.1.0
               --
               -- @param string errors Login error message.
               --
               Echo ("<div id=""login_error"">" &
                     Apply_Filters ("login_errors", -Errors) &
                     "</div>" & NL);
            end if;

            if not Empty (-Messages) then
               --
               -- Filters instructional messages displayed above the login form.
               --
               -- @since 2.5.0
               --
               -- @param string messages Login messages.
               --
               Echo ("<p class=""message"" id=""login-message"">" &
                     Apply_Filters ("login_messages", -Messages) &
                     "</p>" & NL);
            end if;
         end;
      end if;
   end Login_Header;

   ------------------
   -- Login_Footer --
   ------------------

   procedure Login_Footer (Input_Id : String := "")
   is
      use Php.Echoing;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Plugins;
--    global interim_login;
   begin
      -- Don't allow interim logins to navigate away from the page.
      if not Interim_Login then
         Echo ("<p id=""backtoblog"">");
         declare
            HTML_Link : constant String :=
              Sprintf (
                "<a href=""%s"">%s</a>",
                To_List (List => (
                  1 => +ESC_URL (Home_URL ("/")),
                  2 => +Sprintf (
                          -- translators: %s: Site title.
                          X_X ("&larr; Go to %s", "site"),
                          To_List (Get_Bloginfo ("title", "display"))
                        )
                )));
         begin
            --
            -- Filter the "Go to site" link displayed in the login page footer.
            --
            -- @since 5.7.0
            --
            -- @param string link HTML link to the home URL of the current site.
            --
            Echo (Apply_Filters ("login_site_html_link", HTML_Link));
            Echo ("    </p>");

            The_Privacy_Policy_Link ("<div class=""privacy-policy-page-link"">",
                                     "</div>");
         end;
      end if;

      Echo ("  </div>"); -- <?php -- End of <div id="login">. ?>

      if
         not Interim_Login and then
         --
         -- Filters the Languages select input activation on the login screen.
         --
         -- @since 5.9.0
         --
         -- @param bool Whether to display the Languages select input on the
         --             login screen.
         --
         Apply_Filters ("login_display_language_dropdown", True)
      then
         declare
            Languages : constant Array_Type := Get_Available_Languages;
         begin
            if not Languages.Is_Empty then
               Echo ("      <div class=""language-switcher"">" & NL);
               Echo ("        <form id=""language-switcher"" action="""""" method=""get"">" & NL);

               Echo ("          <label for=""language-switcher-locales"">" & NL);
               Echo ("            <span class=""dashicons dashicons-translation"" aria-hidden=""true""></span>" & NL);
               Echo ("            <span class=""screen-reader-text"">");
               X_E ("Language");
               Echo ("</span>" & NL);
               Echo ("          </label>" & NL);

               declare
                  Args : constant Array_Type := To_Array (List => (
                    Build ("id",                          "language-switcher-locales"),
                    Build ("name",                        "wp_lang"),
                    Build ("selected",                    Determine_Locale),
                    Build ("show_available_translations", False),
                    Build ("explicit_option_en_us",       True),
                    Build ("languages",                   Languages)
                  ));
               begin
                  --
                  -- Filters default arguments for the Languages select input on the login screen.
                  --
                  -- The arguments get passed to the wp_dropdown_languages() function.
                  --
                  -- @since 5.9.0
                  --
                  -- @param array args Arguments for the Languages select input on the login screen.
                  --
                  Wp_Dropdown_Languages (Apply_Filters ("login_language_dropdown_args", Args));
               end;

               if Interim_Login then
                  Echo ("<input type=""hidden"" name=""interim-login"" value=""1"" />");
               end if;

               if
                 Isset (XX_GET, "redirect_to") and then
                 "" /= Get_As_String (XX_GET, "redirect_to")
               then
                  Echo ("<input type=""hidden"" name=""redirect_to"" value=""" & Sanitize_URL (Get_As_String (XX_GET, "redirect_to")) & """ />");
               end if;

               if
                 Isset (XX_GET, "action") and then
                 "" /= Get_As_String (XX_GET, "action")
               then
                  Echo ("<input type=""hidden"" name=""action"" value=""" &
                        ESC_Attr (Get_As_String (XX_GET, "action")) & """ />");
               end if;

               Echo ("<input type=""submit"" class=""button"" value=""");
               ESC_Attr_E ("Change");
               Echo (""">");

               Echo ("</form>");
               Echo ("</div>");
            end if;
         end;
      end if;

      if not Empty (Input_Id) then
         Echo ("<script type=""text/javascript"">" & NL);
         Echo ("  try{document.getElementById('" & Input_Id & "').focus();}catch(e){}" & NL);
         Echo ("  if(typeof wpOnload==='function')wpOnload();" & NL);
         Echo ("</script>" & NL);
      end if;

      --
      -- Fires in the login page footer.
      --
      -- @since 3.1.0
      --
      Do_Action ("login_footer");

      Echo ("<div class=""clear""></div>" & NL);
      Echo ("</body>" & NL);
      Echo ("</html>" & NL);
   end Login_Footer;

   -----------------
   -- Wp_Shake_JS --
   -----------------

   procedure Wp_Shake_JS
   is
      use Php.Echoing;
      use UStrings;
   begin
      Echo ("  <script type=""text/javascript"">" & NL);
      Echo ("    document.querySelector('form').classList.add('shake');" & NL);
      Echo ("  </script>" & NL);
   end Wp_Shake_JS;

   ----------------------------
   -- Wp_Login_Viewpost_Meta --
   ----------------------------

   procedure Wp_Login_Viewport_Meta
   is
      use Php.Echoing;
   begin
      Echo ("<meta name=""viewport"" content=""width=device-width"" />");
   end Wp_Login_Viewport_Meta;

   --------------------------------
   -- Action_Confirm_Admin_Email --
   --------------------------------

   procedure Action_Confirm_Admin_Email (Errors : Class_Errors.Wp_Error)
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Capabilities;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
      use Inc_Plugins;

      Admin_Email : UString;
   begin
      --
      -- Note that `is_user_logged_in()` will return false immediately after logging in
      -- as the current user is not set, see wp-includes/pluggable.php.
      -- However this action runs on a redirect after logging in.
      --
      if not Is_User_Logged_In then
         Wp_Safe_Redirect (Wp_Login_URL);
         Die; -- exit;
      end if;

      declare
         Redirect_To : constant String :=
           (if not Empty (X_REQUEST, "redirect_to")
            then Get_As_String (X_REQUEST, "redirect_to")
            else Admin_URL);

         Remind_Interval : Integer;
      begin
         if Current_User_Can ("manage_options") then
            Admin_Email := +Get_Option ("admin_email");
         else
            Wp_Safe_Redirect (Redirect_To);
            Die; -- exit;
         end if;

         declare
         begin
            --
            -- Filters the interval for dismissing the admin email confirmation screen.
            --
            -- If `0` (zero) is returned, the "Remind me later" link will not be
            -- displayed.
            --
            -- @since 5.3.1
            --
            -- @param int interval Interval time (in seconds). Default is 3 days.
            --
            Remind_Interval :=
              Integer'(Apply_Filters ("admin_email_remind_interval",
                                      3 * Globals.DAY_IN_SECONDS));

            if not Empty (XX_GET, "remind_me_later") then
               if
                 0 = Wp_Verify_Nonce (Get_As_String (XX_GET, "remind_me_later"),
                                      "remind_me_later_nonce")
               then
--             if not Wp_Verify_Nonce (Get_As_String (XX_GET, "remind_me_later"), "remind_me_later_nonce") then
                  Wp_Safe_Redirect (Wp_Login_URL);
                  Die; -- exit;
               end if;

               if Remind_Interval > 0 then
                  Update_Option ("admin_email_lifespan",
                                 From_Integer (Php.Misc.Time + Remind_Interval));
               end if;

               declare
                  Redirect_To_2 : constant String :=
                    Add_Query_Arg ("admin_email_remind_later", "1", Redirect_To);
                    -- "1" was 1 -- jq
               begin
                  Wp_Safe_Redirect (Redirect_To_2);
               end;
               Die; -- exit;
            end if;

            if not Empty (X_POST, "correct-admin-email") then
               if
                 0 = Check_Admin_Referer ("confirm_admin_email",
                                          "confirm_admin_email_nonce")
               then
--             if not Check_Admin_Referer ("confirm_admin_email", "confirm_admin_email_nonce") then
                  Wp_Safe_Redirect (Wp_Login_URL);
                  Die; -- exit;
               end if;

               --
               -- Filters the interval for redirecting the user to the admin email
               -- confirmation screen.
               --
               -- If `0` (zero) is returned, the user will not be redirected.
               --
               -- @since 5.3.0
               --
               -- @param int interval Interval time (in seconds). Default is 6 months.
               --
               declare
                  Admin_Email_Check_Interval : constant Integer :=
                    Integer'(Apply_Filters ("admin_email_check_interval",
                                            6 * Globals.MONTH_IN_SECONDS));
               begin
                  if Admin_Email_Check_Interval > 0 then
                     Update_Option
                       ("admin_email_lifespan",
                        From_Integer (Php.Misc.Time + Admin_Email_Check_Interval));
                  end if;
               end;
               Wp_Safe_Redirect (Redirect_To);
               Die; -- exit;
            end if;
         end;

         Login_Header (abs "Confirm your administration email", "", Errors);

         --
         -- Fires before the admin email confirm form.
         --
         -- @since 5.3.0
         --
         -- @param WP_Error errors A `WP_Error` object containing any errors generated
         --                         by using invalid credentials. Note that the error
         --                         object may not contain any errors.
         --
         Do_Action ("admin_email_confirm", Errors);

         Echo ("<form class=""admin-email-confirm-form"" " &
               "name=""admin-email-confirm-form"" action=""" &
               ESC_URL (Site_URL ("wp-login.php?action=confirm_admin_email",
                                  "login_post")) &
               """ method=""post"">");

         --
         -- Fires inside the admin-email-confirm-form form tags, before the hidden
         -- fields.
         --
         -- @since 5.3.0
         --
         Do_Action ("admin_email_confirm_form");

         Wp_Nonce_Field ("confirm_admin_email", "confirm_admin_email_nonce");

         Echo ("<input type=""hidden"" name=""" & Redirect_To &
               """ value=""" & ESC_Attr (Redirect_To) & """ />");

         Echo ("<h1 class=""admin-email__heading"">");
         X_E ("Administration email verification");
         Echo ("</h1>" & NL);
         Echo ("<p class=""admin-email__details"">");
         X_E ("Please verify that the <strong>administration email</strong> for this website is still correct.");

         declare            -- translators: URL to the WordPress help section about admin email.
            Admin_Email_Help_URL : constant String :=
              abs "https://wordpress.org/support/article/settings-general-screen/#email-address";

            -- translators: Accessibility text.
            Accessibility_Text : constant String :=
               Sprintf ("<span class=""screen-reader-text""> %s</span>",
                        To_List (abs "(opens in a new tab)"));
         begin
            Printf (
              "<a href=""%s"" rel=""noopener"" target=""_blank"">%s%s</a>",
              To_List (List => (
                1 => +ESC_URL (Admin_Email_Help_URL),
                2 => +abs "Why is this important?",
                3 => +Accessibility_Text
              ))
            );
         end;

         Echo ("</p>" & NL);
         Echo ("<p class=""admin-email__details"">");

         Printf (
           -- translators: %s: Admin email address.
           abs "Current administration email: %s",
           To_List ("<strong>" & ESC_HTML (-Admin_Email) & "</strong>")
         );

         Echo ("</p>" & NL);
         Echo ("<p class=""admin-email__details"">");
         X_E ("This email may be different from your personal email address.");
         Echo ("</p>" & NL);

         Echo ("<div class=""admin-email__actions"">" & NL);
         Echo ("  <div class=""admin-email__actions-primary"">" & NL);

         declare
            Change_Link_2 : constant String :=
              Admin_URL ("options-general.php");

            Change_Link : constant String :=
              Add_Query_Arg ("highlight", "confirm_admin_email", Change_Link_2);
         begin
            Echo ("    <a class=""button button-large"" href=""" &
                  ESC_URL (Change_Link) & ">");
            X_E ("Update");
            Echo ("</a>" & NL);
            Echo ("    <input type=""submit"" name=""correct-admin-email"" " &
                  "id=""correct-admin-email"" " &
                  "class=""button button-primary button-large"" value=""");
            ESC_Attr_E ("The email is correct");
            Echo (" />" & NL);
            Echo ("  </div>" & NL);
         end;

         if Remind_Interval > 0 then
            Echo ("  <div class=""admin-email__actions-secondary"">" & NL);
            declare
               Remind_Me_Link_2 : constant String :=
                 Wp_Login_URL (Redirect_To);

               Remind_Me_Link : constant String :=
                 Add_Query_Arg (
                   To_Array (List => (
                     Build ("action", "confirm_admin_email"),
                     Build ("remind_me_later",
                            Wp_Create_Nonce ("remind_me_later_nonce"))
                   )),
                   Remind_Me_Link_2
                 );
            begin
               Echo ("<a href=""" & ESC_URL (Remind_Me_Link) & """>");
               X_E ("Remind me later");
               Echo ("</a>" & NL);
               Echo ("</div>" & NL);
            end;
         end if;
         Echo ("        </div>" & NL);
         Echo ("</form>" & NL);

         Login_Footer;
      end;
   end Action_Confirm_Admin_Email;

   ---------------------
   -- Action_Postpass --
   ---------------------

   procedure Action_Postpass
   is
      use Php.Arrays;
      use Php.Errors;
      use Php.HTML;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Class_Phpass;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Plugins;
      use Inc_Pluggables;
   begin
      if not Array_Key_Exists ("post_password", X_POST) then
         Wp_Safe_Redirect (Wp_Get_Referer);
         Die; -- exit;
      end if;

      declare
         Hasher : constant Password_Hash := X_Construct (8, True);
--       Hasher : Duration := new PasswordHash (8, True);

         --
         -- Filters the life span of the post password cookie.
         --
         -- By default, the cookie expires 10 days from creation. To turn this
         -- into a session cookie, return 0.
         --
         -- @since 3.7.0
         --
         -- @param int expires The expiry time, as passed to setcookie().
         --
         Expire : constant Integer :=
           Apply_Filters ("post_password_expires",
                          Php.Misc.Time + 10 * Globals.DAY_IN_SECONDS);

         Referer : constant String := Wp_Get_Referer;

         Secure  : constant Boolean :=
           (if Referer /= ""
            then ("https" = Parse_URL (Referer, PHP_URL_SCHEME))
            else False);
      begin
         Set_Cookie
           ("wp-postpass_" & (-Globals.COOKIEHASH),
            Hasher.HashPassword (Wp_Unslash (Get_As_String (X_POST, "post_password"))),
            Expire, -Globals.COOKIEPATH, -Globals.COOKIE_DOMAIN, Secure);
      end;
      Wp_Safe_Redirect (Wp_Get_Referer);
      Die; -- exit;
   end Action_Postpass;

   -------------------
   -- Action_Logout --
   -------------------

   procedure Action_Logout
   is
      use Php.Errors;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Class_Users;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      Check_Admin_Referer ("log-out");
      declare
         User : constant Wp_User := Wp_Get_Current_User;

         Redirect_To           : UString;
         Requested_Redirect_To : UString;
      begin
         Wp_Logout;

         if not Empty (X_REQUEST, "redirect_to") then
            Redirect_To           := +Get_As_String (X_REQUEST, "redirect_to");
            Requested_Redirect_To := Redirect_To;
         else
            Redirect_To := +Add_Query_Arg (
              To_Array (List => (
                Build ("loggedout", "true"),
                Build ("wp_lang",   Get_User_Locale (User))
              )),
              Wp_Login_URL
            );

            Requested_Redirect_To := +"";
         end if;

         --
         -- Filters the log out redirect URL.
         --
         -- @since 4.2.0
         --
         -- @param string  redirect_to           The redirect destination URL.
         -- @param string  requested_redirect_to The requested redirect destination
         --                                      URL passed as a parameter.
         -- @param WP_User user                  The WP_User object for the user
         --                                      that's logging out.
         --
         declare
            Redirect_To_2 : constant String :=
              Apply_Filters ("logout_redirect", -Redirect_To,
                             -Requested_Redirect_To, User);
         begin
            Wp_Safe_Redirect (Redirect_To_2);
         end;
      end;
      Die; -- exit;
   end Action_Logout;

   -------------------------
   -- Action_Lostpassword --
   -------------------------

   procedure Action_Lostpassword (Login_Link_Separator : String;
                                  HTTP_Post            : Boolean)
   is
      use Php.Errors;
      use Php.Echoing;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
      use Inc_Plugins;
      use Inc_Users;

      Errors : Success_Error_Type;
   begin
      if HTTP_Post then
         Errors := Retrieve_Password;

         if not Errors.Success then
--       if not Is_Wp_Error (Errors) then
            declare
               Redirect_To : constant String :=
                 (if not Empty (X_REQUEST, "redirect_to")
                  then Get_As_String (X_REQUEST, "redirect_to")
                  else "wp-login.php?checkemail=confirm");
            begin
               Wp_Safe_Redirect (Redirect_To);
            end;
            Die; -- exit;
         end if;
      end if;

      if Isset (XX_GET, "error") then
         if "invalidkey" = Get_As_String (XX_GET, "error") then
            Errors.Error.Add ("invalidkey",
                        abs "<strong>Error:</strong> Your password reset link appears to be invalid. Please request a new link below.");
         elsif "expiredkey" = Get_As_String (XX_GET, "error") then
            Errors.Error.Add ("expiredkey",
                        abs "<strong>Error:</strong> Your password reset link has expired. Please request a new link below.");
         end if;
      end if;

      declare
         Lostpassword_Redirect : String :=
           (if not Empty (X_REQUEST, "redirect_to")
            then Get_As_String (X_REQUEST, "redirect_to") else "");

         --
         -- Filters the URL redirected to after submitting the
         -- lostpassword/retrievepassword form.
         --
         -- @since 3.0.0
         --
         -- @param string lostpassword_redirect The redirect destination URL.
         --
         Redirect_To : constant String :=
           Apply_Filters ("lostpassword_redirect", Lostpassword_Redirect);

         User_Login : UString;
      begin
         --
         -- Fires before the lost password form.
         --
         -- @since 1.5.1
         -- @since 5.1.0 Added the `errors` parameter.
         --
         -- @param WP_Error errors A `WP_Error` object containing any errors generated
         --                        by using invalid credentials. Note that the error
         --                        object may not contain any errors.
         --
         Do_Action ("lost_password", Errors.Error);

         Login_Header (abs "Lost Password", "<p class=""message"">" &
                       abs "Please enter your username or email address. You will receive an email message with instructions on how to reset your password." & "</p>",
                       Errors.Error);

         User_Login := +"";

         if
           Isset (X_POST, "user_login") and then
           Kind_Of (Get (X_POST, "user_login")) = Kind_String
         then
            User_Login := +Wp_Unslash (Get_As_String (X_POST, "user_login"));
         end if;

         Echo ("<form name=""lostpasswordform"" id=""lostpasswordform"" action=""" &
               ESC_URL (Network_Site_URL ("wp-login.php?action=lostpassword",
                                          "login_post")) &
               """ method=""post"">" & NL);
         Echo ("        <p>" & NL);
         Echo ("          <label for=""user_login"">");
         X_E ("Username or Email Address");
         Echo ("</label>" & NL);
         Echo ("            <input type=""text"" name=""user_login"" " &
               "id=""user_login"" class=""input"" value=""" &
               ESC_Attr (-User_Login) & """ size=""20"" autocapitalize=""off"" " &
               "autocomplete=""username"" />" & NL);
         Echo ("        </p>" & NL);

         --
         -- Fires inside the lostpassword form tags, before the hidden fields.
         --
         -- @since 2.1.0
         --
         Do_Action ("lostpassword_form");

         Echo ("        <input type=""hidden"" name=""redirect_to"" value=""" &
               ESC_Attr (Redirect_To) & """ />" & NL);
         Echo ("        <p class=""submit"">" & NL);
         Echo ("          <input type=""submit"" name=""wp-submit"" " &
               "id=""wp-submit"" class=""button button-primary button-large"" " &
               "value=""""");
         ESC_Attr_E ("Get New Password");
         Echo (""" />" & NL);
         Echo ("        </p>" & NL);
         Echo ("</form>" & NL);

         Echo ("<p id=""nav"">" & NL);
         Echo ("  <a href=""" & ESC_URL (Wp_Login_URL) & """>");
         X_E ("Log in");
         Echo ("</a>" & NL);
      end;

      if Get_Option ("users_can_register") then
         declare
            Registration_URL : constant String :=
              Sprintf ("<a href=""%s"">%s</a>",
                       To_List (List => (
                         1 => +ESC_URL (Wp_Registration_URL),
                         2 => +abs "Register"
                       )));
         begin
            Echo (ESC_HTML (Login_Link_Separator));

            -- This filter is documented in wp-includes/general-template.php
            Echo (Apply_Filters ("register", Registration_URL));
         end;
      end if;

      Echo ("</p>" & NL);

      Login_Footer ("user_login");
   end Action_Lostpassword;

   ----------------------
   -- Action_Resetpass --
   ----------------------

   procedure Action_Resetpass (Login_Link_Separator : String)
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Class_Errors;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Plugins;
      use Inc_Pluggables;
      use Inc_Options;
      use Inc_Users;

      List : constant List_Type :=
        Explode ("?", Wp_Unslash (Get_As_String (X_SERVER, "REQUEST_URI")));

      RP_Path   : constant String := -List (1);
      RP_Cookie : constant String := "wp-resetpass-" & (-Globals.COOKIEHASH);
      RP_Login  : UString;
      RP_Key    : UString;

      User   : User_Error_Type;
      Errors : Wp_Error;
   begin
      if Isset (XX_GET, "key") and then Isset (XX_GET, "login") then
         declare
            Value : constant String :=
              Sprintf ("%s:%s",
                       To_List (List => (
                         1 => +Wp_Unslash (Get_As_String (XX_GET, "login")),
                         2 => +Wp_Unslash (Get_As_String (XX_GET, "key"))
                      )));
         begin
            Set_Cookie (RP_Cookie, Value, 0, RP_Path,
                        -Globals.COOKIE_DOMAIN, Is_SSL, True);

            Wp_Safe_Redirect (Remove_Query_Arg (To_List (List => (+"key", +"login"))));
            Die; -- exit;
         end;
      end if;

      if
        Isset (X_COOKIE, RP_Cookie) and then
        0 < Strpos (Get_As_String (X_COOKIE, RP_Cookie), ":")
      then
         declare
            List : constant List_Type :=
              Explode (":", Wp_Unslash (Get_As_String (X_COOKIE, RP_Cookie)),
                       Limit => 2);
         begin
            RP_Login := List (1);
            RP_Key   := List (2);

            User := Check_Password_Reset_Key (-RP_Key, -RP_Login);

            if
               Isset (X_POST, "pass1") and then
               not Php.Misc.Hash_Equals (-RP_Key, Get_As_String (X_POST, "rp_key"))
            then
               User.Success := False;
            end if;
         end;
      else
         User.Success := False;
      end if;

      if not User.Success then
--    if not User or else Is_Wp_Error (User) then
         Set_Cookie (RP_Cookie, " ",
                     Php.Misc.Time - Globals.YEAR_IN_SECONDS,
                     RP_Path, -Globals.COOKIE_DOMAIN, Is_SSL, True);

         if
           not User.Success and then
           User.Error.Get_Error_Code = "expired_key"
         then
--       if User and then User.Get_Error_Code = "expired_key" then
            Wp_Redirect (
              Site_URL ("wp-login.php?action=lostpassword&error=expiredkey"));
         else
            Wp_Redirect (
              Site_URL ("wp-login.php?action=lostpassword&error=invalidkey"));
         end if;

         Die; -- exit;
      end if;

      Errors := X_Construct; -- new WP_Error();

      -- Check if password is one or all empty spaces.
      if not Empty (Get_As_String (X_POST, "pass1")) then
         Set (X_POST, "pass1", From_String (
              Trim (Get_As_String (X_POST, "pass1"))));

         if Empty (Get_As_String (X_POST, "pass1")) then
            Errors.Add ("password_reset_empty_space",
                        abs "The password cannot be a space or all spaces.");
         end if;
      end if;

      -- Check if password fields do not match.
      if
        not Empty (Get_As_String (X_POST, "pass1")) and then
        Trim (Get_As_String (X_POST, "pass2")) /=
        Get_As_String (X_POST, "pass1")
      then
         Errors.Add ("password_reset_mismatch",
                     abs "<strong>Error:</strong> The passwords do not match.");
      end if;

      --
      -- Fires before the password reset procedure is validated.
      --
      -- @since 3.5.0
      --
      -- @param WP_Error         errors WP Error object.
      -- @param WP_User|WP_Error user   WP_User object if the login and reset key
      --                                match. WP_Error object otherwise.
      --
      Do_Action ("validate_password_reset", Errors, User);

      if
        not Errors.Has_Errors and then
        Isset (X_POST, "pass1") and then
        not Empty (X_POST, "pass1")
      then
         Reset_Password (User.User, Get_As_String (X_POST, "pass1"));
         Set_Cookie (RP_Cookie, " ",
                     Php.Misc.Time - Globals.YEAR_IN_SECONDS,
                     RP_Path, -Globals.COOKIE_DOMAIN, Is_SSL, True);

         Login_Header (abs "Password Reset",
                       "<p class=""message reset-pass"">" &
                       abs "Your password has been reset." &
                       " <a href=""" &
                       ESC_URL (Wp_Login_URL) & """>" &
                       abs "Log in" & "</a></p>");
         Login_Footer;
         Die; -- exit;
      end if;

      Wp_Enqueue_Script ("utils");
      Wp_Enqueue_Script ("user-profile");

      Login_Header (abs "Reset Password",
                    "<p class=""message reset-pass"">" &
                    abs "Enter your new password below or generate one." &
                    "</p>", Errors);

      Echo ("<form name=""resetpassform"" id=""resetpassform"" action=""" &
            ESC_URL (Network_Site_URL ("wp-login.php?action=resetpass", "login_post")) & """ method=""post"" autocomplete=""off"">" & NL);
      Echo ("  <input type=""hidden"" id=""user_login"" value=""" &
            ESC_Attr (-RP_Login) & """ autocomplete=""off"" />" & NL);

      Echo ("    <div class=""user-pass1-wrap"">" & NL);
      Echo ("      <p>" & NL);
      Echo ("        <label for=""pass1"">");
      X_E ("New password");
      Echo ("</label>" & NL);
      Echo ("      </p>" & NL);

      Echo ("      <div class=""wp-pwd"">" & NL);
      Echo ("        <input type=""password"" data-reveal=""1"" data-pw=""" &
            ESC_Attr (Wp_Generate_Password (16)) &
            """ name=""pass1"" id=""pass1"" class=""input password-input"" size=""24"" value="""" autocomplete=""new-password"" aria-describedby=""pass-strength-result"" />" & NL);

      Echo ("          <button type=""button"" class=""button button-secondary wp-hide-pw hide-if-no-js"" data-toggle=""0"" aria-label=""");
      ESC_Attr_E ("Hide password");
      Echo (""">" & NL);
      Echo ("            <span class=""dashicons dashicons-hidden"" aria-hidden=""true""></span>" & NL);
      Echo ("          </button>" & NL);
      Echo ("          <div id=""pass-strength-result"" class=""hide-if-no-js"" aria-live=""polite"">");
      X_E ("Strength indicator");
      Echo ("</div>" & NL);
      Echo ("      </div>" & NL);
      Echo ("      <div class=""pw-weak"">" & NL);
      Echo ("        <input type=""checkbox"" name=""pw_weak"" id=""pw-weak"" class=""pw-checkbox"" />" & NL);
      Echo ("        <label for=""pw-weak"">");
      X_E ("Confirm use of weak password");
      Echo ("</label>" & NL);
      Echo ("      </div>" & NL);
      Echo ("    </div>" & NL);

      Echo ("    <p class=""user-pass2-wrap"">" & NL);
      Echo ("      <label for=""pass2"">");
      X_E ("Confirm new password");
      Echo ("</label>" & NL);
      Echo ("      <input type=""password"" name=""pass2"" id=""pass2"" " &
            "class=""input"" size=""20"" value="""" " &
            "autocomplete=""new-password"" />" & NL);
      Echo ("    </p>" & NL);

      Echo ("    <p class=""description indicator-hint"">" &
            Wp_Get_Password_Hint & "</p>" & NL);
      Echo ("    <br class=""clear"" />" & NL);

      --
      -- Fires following the "Strength indicator" meter in the user password reset
      -- form.
      --
      -- @since 3.9.0
      --
      -- @param WP_User user User object of the user whose password is being reset.
      --
      Do_Action ("resetpass_form", User.User);

      Echo ("    <input type=""hidden"" name=""rp_key"" value=""" &
            ESC_Attr (-RP_Key) & """ />" & NL);
      Echo ("    <p class=""submit reset-pass-submit"">" & NL);
      Echo ("      <button type=""button"" " &
            "class=""button wp-generate-pw hide-if-no-js skip-aria-expanded"">");
      X_E ("Generate Password");
      Echo ("</button>" & NL);
      Echo ("      <input type=""submit"" name=""wp-submit"" id=""wp-submit"" " &
            "class=""button button-primary button-large"" value=""");
      ESC_Attr_E ("Save Password");
      Echo (""" />" & NL);
      Echo ("    </p>" & NL);
      Echo ("</form>" & NL);

      Echo ("<p id=""nav"">" & NL);
      Echo ("  <a href=""" & ESC_URL (Wp_Login_URL) & """>");
      X_E ("Log in");
      Echo ("</a>" & NL);

      if Get_Option ("users_can_register") then
         declare
            Registration_URL : constant String :=
              Sprintf ("<a href=""%s"">%s</a>",
                       To_List (List => (
                         1 => +ESC_URL (Wp_Registration_URL),
                         2 => +abs "Register"
                      )));
         begin
            Echo (ESC_HTML (Login_Link_Separator));
            -- This filter is documented in wp-includes/general-template.php
            Echo (Apply_Filters ("register", Registration_URL));
         end;
      end if;

      Echo ("</p>" & NL);

      Login_Footer ("pass1");
   end Action_Resetpass;

   ---------------------
   -- Action_Register --
   ---------------------

   procedure Action_Register (Login_Link_Separator : String;
                              HTTP_Post            : Boolean)
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Pluggables;
      use Inc_Plugins;
      use Inc_Users;
   begin
      if Is_Multisite then
         --
         -- Filters the Multisite sign up URL.
         --
         -- @since 3.0.0
         --
         -- @param string sign_up_url The sign up URL.
         --
         Wp_Redirect (Apply_Filters ("wp_signup_location",
                                     Network_Site_URL ("wp-signup.php")));
         Die; -- exit;
      end if;

      if "" = Get_Option ("users_can_register") then
         Wp_Redirect (Site_URL ("wp-login.php?registration=disabled"));
         Die; -- exit;
      end if;

      declare
         User_Login : UString;
         User_Email : UString;
         Errors     : User_Id_Error_Type;
      begin
         if HTTP_Post then
            if
              Isset (X_POST, "user_login") and then
              Kind_Of (Get (X_POST, "user_login")) = Kind_String
            then
               User_Login := +Wp_Unslash (Get_As_String (X_POST, "user_login"));
            end if;

            if
              Isset (X_POST, "user_email") and then
              Kind_Of (Get (X_POST, "user_email")) = Kind_String
            then
               User_Email := +Wp_Unslash (Get_As_String (X_POST, "user_email"));
            end if;

--            declare
               Errors := -- : User_Id_Error_Type :=
                 Register_New_User (-User_Login, -User_Email);
--            begin
               if Errors.Success then
--             if not Is_Wp_Error (Errors) then
                  declare
                     Redirect_To : constant String :=
                       (if not Empty (X_POST, "redirect_to")
                        then Get_As_String (X_POST, "redirect_to")
                        else "wp-login.php?checkemail=registered");
                  begin
                     Wp_Safe_Redirect (Redirect_To);
                     Die; -- exit;
                  end;
               end if;
--            end;
         end if;

         declare
            Registration_Redirect : constant String :=
              (if not Empty (X_REQUEST, "redirect_to")
               then Get_As_String (X_REQUEST, "redirect_to")
               else "");

            --
            -- Filters the registration redirect URL.
            --
            -- @since 3.0.0
            -- @since 5.9.0 Added the `errors` parameter.
            --
            -- @param string       registration_redirect The redirect destination URL.
            -- @param int|WP_Error errors                User id if registration was
            --                                           successful, WP_Error object
            --                                           otherwise.
            --
            Redirect_To : constant String :=
              Apply_Filters ("registration_redirect",
                             Registration_Redirect, Errors);
         begin
            Login_Header (abs "Registration Form",
                          "<p class=""message register"">" &
                          abs "Register For This Site" & "</p>",
                          Errors.Error);

            Echo ("<form name=""registerform"" id=""registerform"" action=""" &
                  ESC_URL (Site_URL ("wp-login.php?action=register",
                                     "login_post")) &
                  """ method=""post"" novalidate=""novalidate"">" & NL);
            Echo ("<p>" & NL);
            Echo ("  <label for=""user_login"">");
            X_E ("Username");
            Echo ("</label>" & NL);
            Echo ("  <input type=""text"" name=""user_login"" id=""user_login"" " &
                  "class=""input"" value=""" &
                  ESC_Attr (Wp_Unslash (-User_Login)) &
                  """ size=""20"" autocapitalize=""off"" " &
                  "autocomplete=""username"" />" & NL);
            Echo ("</p>" & NL);
            Echo ("<p>" & NL);
            Echo ("  <label for=""user_email"">");
            X_E ("Email");
            Echo ("</label>" & NL);
            Echo ("  <input type=""email"" name=""user_email"" id=""user_email"" " &
                  "class=""input"" value=""" &
                  ESC_Attr (Wp_Unslash (-User_Email)) &
                  """ size=""25"" autocomplete=""email"" />" & NL);
            Echo ("</p>" & NL);

            --
            -- Fires following the "Email" field in the user registration form.
            --
            -- @since 2.1.0
            --
            Do_Action ("register_form");

            Echo ("<p id=""reg_passmail"">" & NL);
            Echo ("  ");
            X_E ("Registration confirmation will be emailed to you.");
            Echo (NL);
            Echo ("</p>" & NL);
            Echo ("<br class=""clear"" />" & NL);
            Echo ("<input type=""hidden"" name=""redirect_to"" value=""" &
                  ESC_Attr (Redirect_To) & " />" & NL);
            Echo ("<p class=""submit"">" & NL);
            Echo ("  <input type=""submit"" name=""wp-submit"" id=""wp-submit"" " &
                  "class=""button button-primary button-large"" value=""");
            ESC_Attr_E ("Register");
            Echo (""" />" & NL);
            Echo ("</p>" & NL);
            Echo ("</form>" & NL);

            Echo ("<p id=""nav"">" & NL);
            Echo ("  <a href=""" & ESC_URL (Wp_Login_URL) & """>");
            X_E ("Log in");
            Echo ("</a>" & NL);

            Echo ("  " & ESC_HTML (Login_Link_Separator) & NL);
            declare
               HTML_Link : constant String :=
                 Sprintf ("<a href=""%s"">%s</a>",
                          To_List (List => (
                            1 => +ESC_URL (Wp_Lostpassword_URL),
                            2 => +abs "Lost your password?"
                         )));
            begin
               -- This filter is documented in wp-login.php
               Echo (Apply_Filters ("lost_password_html_link", HTML_Link) & NL);
            end;

            Echo ("</p>" & NL);

            Login_Footer ("user_login");
         end;
      end;
   end Action_Register;

   ----------------------
   -- Action_Checkmail --
   ----------------------

   procedure Action_Checkmail
   is
      use Php.Strings;
      use Binder;
      use Wp_Common;
      use Class_Errors;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_L10n;

      Redirect_To : constant String := Admin_URL;
      Errors      : Wp_Error := X_Construct; -- new WP_Error();
   begin
      if "confirm" = Get_As_String (XX_GET, "checkemail") then
         Errors.Add (
           "confirm",
           Sprintf (
             -- translators: %s: Link to the login page.
             abs "Check your email for the confirmation link, then visit the <a href=""%s"">login page</a>.",
             To_List (Wp_Login_URL)
           ),
           "message"
         );
      elsif "registered" = Get_As_String (XX_GET, "checkemail") then
         Errors.Add (
           "registered",
           Sprintf (
             -- translators: %s: Link to the login page.
             abs "Registration complete. Please check your email, then visit the <a href=""%s"">login page</a>.",
             To_List (Wp_Login_URL)
           ),
           "message"
         );
      end if;

      -- This action is documented in wp-login.php--
      Errors := Apply_Filters ("wp_login_errors", Errors, Redirect_To);

      Login_Header (abs "Check your email", "", Errors);
      Login_Footer;
   end Action_Checkmail;

   --------------------------
   -- Action_Confirmaction --
   --------------------------

   procedure Action_Confirmaction
   is
      use Php.Errors;
      use Binder;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Plugins;
      use Inc_Users;
   begin
      if not Isset (XX_GET, "request_id") then
         Wp_Die (abs "Missing request ID.");
      end if;

      if not Isset (XX_GET, "confirm_key") then
         Wp_Die (abs "Missing confirm key.");
      end if;

      declare
         Request_Id : constant String := Get_As_String (XX_GET, "request_id");

         Key : constant String :=
           Sanitize_Text_Field (Wp_Unslash (Get_As_String (XX_GET, "confirm_key")));

         Result : constant Success_Error_Type :=
           Wp_Validate_User_Request_Key (Request_Id, Key);
      begin
         if not Result.Success then
--       if Is_Wp_Error (Result) then
            Wp_Die ("XXX-976"); -- (Result.Error);
         end if;

         --
         -- Fires an action hook when the account action has been confirmed by the user.
         --
         -- Using this you can assume the user has agreed to perform the action by
         -- clicking on the link in the confirmation email.
         --
         -- After firing this action hook the page will redirect to wp-login a callback
         -- redirects or exits first.
         --
         -- @since 4.9.6
         --
         -- @param int request_id Request ID.
         --
         Do_Action ("user_request_action_confirmed", Request_Id);

         declare
            Message : constant String :=
              X_Wp_Privacy_Account_Request_Confirmed_Message
                (Integer'Value (Request_Id));
         begin
            Login_Header (abs "User action confirmed.", Message);
            Login_Footer;
            Die; -- exit;
         end;
      end;
   end Action_Confirmaction;

   ------------------
   -- Action_Login --
   ------------------

   procedure Action_Login (Login_Link_Separator : String)
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.HTML;
      use Php.Preg;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Lists.List_Vectors;
      use Wp_Common;
      use Inc_Capabilities;
      use Class_Errors;
      use Class_Sites;
      use Class_Users;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_General_Templates;
      use Inc_HTTP;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_Ms_Functions;
      use Inc_L10n;
      use Inc_Options;
      use Inc_Plugins;
      use Inc_Pluggables;
      use Inc_Themes;
      use Inc_Users;

      Secure_Cookie   : Boolean;
      Customize_Login : constant Boolean := Isset (X_REQUEST, "customize-login");
      Redirect_To     : UString;
      Errors          : Wp_Error;
      User_Login      : UString;
   begin
      if Customize_Login then
         Wp_Enqueue_Script ("customize-base");
      end if;

      -- If the user wants SSL but the session is not SSL, force a secure cookie.
      if
        not Empty (X_POST, "log") and then
        not Force_SSL_Admin
      then
         declare
            User_Name : constant String :=
              Sanitize_User (Wp_Unslash (Get_As_String (X_POST, "log")));

            User : Wp_User := Get_User_By ("login", User_Name);
         begin
            if
              User = Null_User and then
              0 /= Strpos (User_Name, "@")
            then
--          if not User and then Strpos (User_Name, "@") then
               User := Get_User_By ("email", User_Name);
            end if;

            if User /= Null_User then
               if Get_User_Option ("use_ssl", User.Id) then
                  Secure_Cookie := True;
                  Force_SSL_Admin (True);
               end if;
            end if;
         end;
      end if;

      if Isset (X_REQUEST, "redirect_to") then
         Redirect_To := +Get_As_String (X_REQUEST, "redirect_to");
         -- Redirect to HTTPS if user wants SSL.
         if
           Secure_Cookie and then
           0 /= Strpos (-Redirect_To, "wp-admin")   -- false
         then
            Redirect_To := +Preg_Replace ("|^http://|", "https://", -Redirect_To);
         end if;
      else
         Redirect_To := +Admin_URL;
      end if;

      declare
         Reauth : constant Boolean :=
           (if Empty (X_REQUEST, "reauth") then False else True);

         User : User_Error_Type := Wp_Signon (Empty_Array, Secure_Cookie);
      begin
         if Empty (X_COOKIE, -Globals.LOGGED_IN_COOKIE) then
            if Headers_Sent then -- ()
               User.Success := False;
               User.Error := X_Construct ( -- new Wp_Error (
                 "test_cookie",
                 Sprintf (
                   -- translators: 1: Browser cookie documentation URL, 2: Support forums URL.
                   abs "<strong>Error:</strong> Cookies are blocked due to unexpected output. For help, please see <a href=""%1s"">this documentation</a> or try the <a href=""%2s"">support forums</a>.",
                   To_List (List => (
                     1 => +abs "https://wordpress.org/support/article/cookies/",
                     2 => +abs "https://wordpress.org/support/forums/"
                   ))
                 )
               );
            elsif
              Isset (X_POST, "testcookie") and then
              Empty (X_COOKIE, -Globals.TEST_COOKIE)
            then
               -- If cookies are disabled, we can't log in even with a valid user
               -- and password.
               User.Success := False;
               User.Error := X_Construct ( -- new Wp_Error (
                 "test_cookie",
                 Sprintf (
                   -- translators: %s: Browser cookie documentation URL.
                   abs "<strong>Error:</strong> Cookies are blocked or not supported by your browser. You must <a href=""%s"">enable cookies</a> to use WordPress.",
                   To_List (abs "https://wordpress.org/support/article/cookies/#enable-cookies-in-your-browser")
                 )
               );
            end if;
         end if;

         declare
            Requested_Redirect_To : constant String :=
              (if Isset (X_REQUEST, "redirect_to")
               then Get_As_String (X_REQUEST, "redirect_to")
               else "");
         begin
            --
            -- Filters the login redirect URL.
            --
            -- @since 3.0.0
            --
            -- @param string           redirect_to           The redirect destination
            --                                               URL.
            -- @param string           requested_redirect_to The requested redirect
            --                                               destination URL passed as
            --                                               a parameter.
            -- @param WP_User|WP_Error user                  WP_User object if login
            --                                               was successful, WP_Error
            --                                               object otherwise.
            --
            Redirect_To :=
              +Apply_Filters ("login_redirect", -Redirect_To,
                              Requested_Redirect_To, User);

            if User.Success and then not Reauth then
--          if not Is_Wp_Error (User) and then not Reauth then
               if Interim_Login then
                  declare
                     Message       : constant String :=
                       "<p class=""message"">" &
                       abs "You have logged in successfully." & "</p>";

--                   Interim_Login : String := "success";
                  begin
                     Login_Header ("", Message);

                     Echo ("</div>" & NL);

                     -- This action is documented in wp-login.php
                     Do_Action ("login_footer");

                     if Customize_Login then
                        Echo ("<script type=""text/javascript"">" &
                              "setTimeout( function(){ " &
                              "  new wp.customize.Messenger({ url: " &
                              Wp_Customize_URL & ", channel: ""login"" })" &
                              ".send('login') }, 1000 );" &
                              "</script>" & NL);
                     end if;

                     Echo ("</body></html>" & NL);

                     Die; -- exit;
                  end;
               end if;

               -- Check if it is time to add a redirect to the admin email
               -- confirmation screen.
               if
                 User.Success     and then
--               Is_A (User, "WP_User") and then
                 User.User.Exists and then
                 User.User.Has_Cap ("manage_options")
               then
                  declare
                     Admin_Email_Lifespan : constant Integer :=
                       Get_Option ("admin_email_lifespan");

                     --
                     -- If `0` (or anything "falsey" as it is cast to int) is
                     -- returned, the user will not be redirected to the admin email
                     -- confirmation screen.
                     --
                     -- This filter is documented in wp-login.php
                     Admin_Email_Check_Interval : constant Integer :=
                       Apply_Filters ("admin_email_check_interval",
                                      6 * Globals.MONTH_IN_SECONDS);
                  begin
                     if
                       Admin_Email_Check_Interval > 0 and then
                       Php.Misc.Time > Admin_Email_Lifespan
                     then
                        Redirect_To :=
                          +Add_Query_Arg (
                             To_Array (List => (
                               Build ("action",  "confirm_admin_email"),
                               Build ("wp_lang", Get_User_Locale (User.User))
                             )),
                             Wp_Login_URL (-Redirect_To)
                           );
                     end if;
                  end;
               end if;

               if
                 Empty (-Redirect_To) or else
                 "wp-admin/" = Redirect_To or else
                 Admin_URL = Redirect_To
               then
                  -- If the user doesn't belong to a blog, send them to user admin.
                  -- If the user can't edit posts, send them to their profile.
                  if
                    Is_Multisite and then
                    Get_Active_Blog_For_User (User.User.Id) = Null_Site and then -- not
                    not Is_Super_Admin (User.User.Id)
                  then
                     Redirect_To := +User_Admin_URL;

                  elsif
                    Is_Multisite and then
                    not User.User.Has_Cap ("read")
                  then
                     Redirect_To := +Get_Dashboard_URL (User.User.Id);

                  elsif not User.User.Has_Cap ("edit_posts") then
                     Redirect_To :=
                       +(if User.User.Has_Cap ("read")
                         then Admin_URL ("profile.php")
                         else Home_URL);
                  end if;

                  Wp_Redirect (-Redirect_To);
                  Die; -- exit;
               end if;

               Wp_Safe_Redirect (-Redirect_To);
               Die; -- exit;
            end if;

            Errors := User.Error;
            -- Clear errors if loggedout is set.
            if not Empty (XX_GET, "loggedout") or else Reauth then
               Errors := X_Construct; -- new Wp_Error ();
            end if;

            if
              X_POST.Is_Empty and then
--            Empty (X_POST) and then
              Errors.Get_Error_Codes =
                To_List (List => (+"empty_username", +"empty_password"))
            then
               Errors := X_Construct ("", ""); -- new Wp_Error ("", "");
            end if;

            if Interim_Login then
               if not Errors.Has_Errors then
                  Errors.Add ("expired", abs "Your session has expired. Please log in to continue where you left off.", "message");
               end if;
            else
               -- Some parts of this script use the main login form to display a
               -- message.
               if
                 Isset (XX_GET, "loggedout") and then
                 "" /= Get_As_String (XX_GET, "loggedout")
               then
                  Errors.Add ("loggedout", abs "You are now logged out.", "message");
               elsif
                 Isset (XX_GET, "registration") and then
                 "disabled" = Get_As_String (XX_GET, "registration")
               then
                  Errors.Add ("registerdisabled",
                              abs "<strong>Error:</strong> User registration is currently not allowed.");
               elsif 0 /= Strpos (-Redirect_To, "about.php?updated") then
                  Errors.Add ("updated", abs "<strong>You have successfully updated WordPress!</strong> Please log back in to see what&#8217;s new.", "message");
               elsif
                 Class_Recovery_Mode_Link_Services.LOGIN_ACTION_ENTERED =  -- ::
                 Action
               then
                  Errors.Add ("enter_recovery_mode", abs "Recovery Mode Initialized. Please log in to continue.", "message");
               elsif
                 Isset (XX_GET, "redirect_to") and then
                 0 /= Strpos (Get_As_String (XX_GET, "redirect_to"), -- false
                              "wp-admin/authorize-application.php")
               then
                  declare
                     Query_Component : constant String :=
                       Wp_Parse_URL (Get_As_String (XX_GET, "redirect_to"),
                                     PHP_URL_QUERY);

                     Query   : Array_Type;
                     Message : UString;
                  begin
                     if Query_Component /= "" then
                        Parse_Str (Query_Component, Query);
                     end if;

                     if not Empty (Query, "app_name") then
                        -- translators: 1: Website name, 2: Application name.
                        Message := +Sprintf ("Please log in to %1s to authorize %2s to connect to your account.",
                          To_List (List => (
                            1 => +Get_Bloginfo ("name", "display"),
                            2 => +"<strong>" & ESC_HTML (Get_As_String (Query, "app_name")) & "</strong>"
                          )));
                     else
                        -- translators: %s: Website name.
                        Message := +Sprintf ("Please log in to %s to proceed with authorization.",
                          To_List (Get_Bloginfo ("name", "display")));
                     end if;

                     Errors.Add ("authorize_application", -Message, "message");
                  end;
               end if;
            end if;

            --
            -- Filters the login page errors.
            --
            -- @since 3.6.0
            --
            -- @param WP_Error errors      WP Error object.
            -- @param string   redirect_to Redirect destination URL.
            --
            Errors := Apply_Filters ("wp_login_errors", Errors, -Redirect_To);

            -- Clear any stale cookies.
            if Reauth then
               Wp_Clear_Auth_Cookie;
            end if;

            Login_Header (abs "Log In", "", Errors);

            if Isset (X_POST, "log") then
               User_Login :=
                +(if "incorrect_password" = Errors.Get_Error_Code or else
                     "empty_password" = Errors.Get_Error_Code
                  then ESC_Attr (Wp_Unslash (Get_As_String (X_POST, "log")))
                  else "");
            end if;

            declare
               Rememberme : constant Boolean := not Empty (X_POST, "rememberme");

               Aria_Describedby : UString;
               Has_Errors       : constant Boolean := Errors.Has_Errors;
            begin
               if Has_Errors then
                  Aria_Describedby := +" aria-describedby=""login_error""";
               end if;

               if Has_Errors and then "message" = Errors.Get_Error_Data then
                  Aria_Describedby := +" aria-describedby=""login-message""";
               end if;

               Wp_Enqueue_Script ("user-profile");

               Echo ("<form name=""loginform"" id=""loginform"" action=""" &
                     ESC_URL (Site_URL ("wp-login.php", "login_post")) &
                     """ method=""post"">" & NL);
               Echo ("<p>" & NL);
               Echo ("  <label for=""user_login"">");
               X_E ("Username or Email Address");
               Echo ("</label>" & NL);
               Echo ("  <input type=""text"" name=""log"" id=""user_login""" &
                     (-Aria_Describedby) & " class=""input"" value=""" &
                     ESC_Attr (-User_Login) &
                     """ size=""20"" autocapitalize=""off"" " &
                     "autocomplete=""username"" />" & NL);
               Echo ("</p>" & NL);

               Echo ("<div class=""user-pass-wrap"">" & NL);
               Echo ("  <label for=""user_pass"">");
               X_E ("Password");
               Echo ("</label>" & NL);
               Echo ("  <div class=""wp-pwd"">" & NL);
               Echo ("    <input type=""password"" name=""pwd"" id=""user_pass""" &
                     (-Aria_Describedby) &
                     " class=""input password-input"" value="""" size=""20"" " &
                     "autocomplete=""current-password"" />" & NL);
               Echo ("    <button type=""button"" " &
                     "class=""button button-secondary wp-hide-pw hide-if-no-js"" " &
                     "data-toggle=""0"" aria-label=""");
               ESC_Attr_E ("Show password");
               Echo (""">" & NL);
               Echo ("      <span class=""dashicons dashicons-visibility"" " &
                     "aria-hidden=""true""></span>" & NL);
               Echo ("    </button>" & NL);
               Echo ("  </div>" & NL);
               Echo ("</div>" & NL);

               --
               -- Fires following the "Password" field in the login form.
               --
               -- @since 2.1.0
               --
               Do_Action ("login_form");

               Echo ("<p class=""forgetmenot""><input name=""rememberme"" " &
                     "type=""checkbox"" id=""rememberme"" value=""forever"" " &
                     Checked (Rememberme) & " /> <label for=""rememberme"">");
               ESC_HTML_E ("Remember Me");
               Echo ("</label></p>" & NL);
               Echo ("<p class=""submit"">" & NL);
               Echo ("  <input type=""submit"" name=""wp-submit"" id=""wp-submit"" " &
                     "class=""button button-primary button-large"" value=""");
               ESC_Attr_E ("Log In");
               Echo (""" />" & NL);

               if Interim_Login then
                  Echo ("  <input type=""hidden"" name=""interim-login"" " &
                        "value=""1"" />" & NL);
               else
                  Echo ("  <input type=""hidden"" name=""redirect_to"" value=""" &
                        ESC_Attr (-Redirect_To) & """ />" & NL);
               end if;

               if Customize_Login then
                  Echo ("  <input type=""hidden"" name=""customize-login"" " &
                        "value=""1"" />" & NL);
               end if;

               Echo ("  <input type=""hidden"" name=""testcookie"" " &
                     "value=""1"" />" & NL);
               Echo ("</p>" & NL);
               Echo ("</form>" & NL);

               if not Interim_Login then
                  Echo ("<p id=""nav"">" & NL);

                  if Get_Option ("users_can_register") /= "" then
                     declare
                        Registration_URL : constant String :=
                          Sprintf ("<a href=""%s"">%s</a>",
                                   To_List (List => (
                                     1 => +ESC_URL (Wp_Registration_URL),
                                     2 => +abs "Register"
                                   )));
                     begin
                        -- This filter is documented in
                        -- wp-includes/general-template.php
                        Echo (Apply_Filters ("register", Registration_URL));

                        Echo (ESC_HTML (Login_Link_Separator));
                     end;
                  end if;

                  declare
                     HTML_Link : constant String :=
                       Sprintf ("<a href=""%s"">%s</a>",
                         To_List (List => (
                           1 => +ESC_URL (Wp_Lostpassword_URL),
                           2 => +abs "Lost your password?"
                         )));
                  begin
                     --
                     -- Filters the link that allows the user to reset the lost
                     -- password.
                     --
                     -- @since 6.1.0
                     --
                     -- @param string html_link HTML link to the lost password form.
                     --
                     Echo (Apply_Filters ("lost_password_html_link", HTML_Link));
                  end;

                  Echo ("</p>" & NL);
               end if;

               declare
                  Login_Script : UString;
               begin
                  Append (Login_Script, "function wp_attempt_focus() {");
                  Append (Login_Script, "setTimeout( function() {");
                  Append (Login_Script, "try {");

                  if User_Login /= "" then
--                if User_Login then
                     Append
                       (Login_Script,
                        "d = document.getElementById( 'user_pass' ); d.value = "";");
                  else
                     Append
                       (Login_Script,
                        "d = document.getElementById( 'user_login' );");

                     if Errors.Get_Error_Code = "invalid_username" then
                        Append (Login_Script, "d.value = "";");
                     end if;
                  end if;

                  Append (Login_Script, "d.focus(); d.select();");
                  Append (Login_Script, "} catch( er ) {}");
                  Append (Login_Script, "}, 200);");
                  Append (Login_Script, "}" & NL); -- End of wp_attempt_focus().

                  --
                  -- Filters whether to print the call to `wp_attempt_focus()` on the
                  -- login screen.
                  --
                  -- @since 4.8.0
                  --
                  -- @param bool print Whether to print the function call. Default
                  --                   true.
                  --
                  if
                    Apply_Filters ("enable_login_autofocus", True) and then
                    Error = Null_Wp_Error
--                  not Error
                  then
                     Append (Login_Script, "wp_attempt_focus();" & NL);
                  end if;

                  -- Run `wpOnload()` if defined.
                  Append (Login_Script, "if ( typeof wpOnload === 'function' ) { wpOnload() }");

                  Echo ("<script type=""text/javascript"">" & NL);
                  Echo ("  " & (-Login_Script) & NL);
                  Echo ("</script>" & NL);

                  if Interim_Login then
                     Echo ("<script type=""text/javascript"">" & NL);
                     Echo ("      ( function() {" & NL);
                     Echo ("              try {" & NL);
                     Echo ("                      var i, links = document.getElementsByTagName( 'a' );" & NL);
                     Echo ("                      for ( i in links ) {" & NL);
                     Echo ("                              if ( links[i].href ) {" & NL);
                     Echo ("                                      links[i].target = '_blank';" & NL);
                     Echo ("                                      links[i].rel = 'noopener';" & NL);
                     Echo ("                              }" & NL);
                     Echo ("                      }" & NL);
                     Echo ("              } catch( er ) {}" & NL);
                     Echo ("      }());" & NL);
                     Echo ("</script>" & NL);
                  end if;

                  Login_Footer;
               end;
            end;
         end;
      end;
   end Action_Login;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Php.Files;
      use Php.HTML;
      use Php.Lists;
      use Php.Strings;
      use Binder;
      use UStrings;
      use Wp_Common;
      use Class_Errors;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Link_Templates;
      use Inc_Load;
      use Inc_Options;
      use Inc_Pluggables;
      use Inc_Plugins;
   begin
      -- Make sure that the WordPress bootstrap has run before continuing.
      Wp_Load.Run;

      -- Redirect to HTTPS login if forced to use SSL.
      if Force_SSL_Admin and then not Is_SSL then
         if 0 = Strpos (Get_As_String (X_SERVER, "REQUEST_URI"), "http") then
            Wp_Safe_Redirect (
              Set_URL_Scheme (Get_As_String (X_SERVER, "REQUEST_URI"), "https"));
            return; --    exit;
         else
            Wp_Safe_Redirect ("https://" &
                              Get_As_String (X_SERVER, "HTTP_HOST") &
                              Get_As_String (X_SERVER, "REQUEST_URI"));
            return; --     exit;
         end if;
      end if;

      --
      -- Main part: check the request and redirect or display a form based on the
      -- current action.
      --
      Action :=
        +(if Isset (X_REQUEST, "action")
          then Get_As_String (X_REQUEST, "action")
          else "login");

      declare
         Errors : Wp_Error; -- = new WP_Error();

         Default_Actions : constant List_Type := To_List (List => (
           +"confirm_admin_email",
           +"postpass",
           +"logout",
           +"lostpassword",
           +"retrievepassword",
           +"resetpass",
           +"rp",
           +"register",
           +"checkemail",
           +"confirmaction",
           +"login",
           +Class_Recovery_Mode_Link_Services.LOGIN_ACTION_ENTERED -- ::
         ));
      begin
         if Isset (XX_GET, "key") then
            Action := +"resetpass";
         end if;

         if Isset (XX_GET, "checkemail") then
            Action := +"checkemail";
         end if;

         -- Validate action so as to default to the login screen.
         if
           not In_List (-Action, Default_Actions, True) and then
           False = Has_Filter ("login_form_" & (-Action))
         then
            Action := +"login";
         end if;

         Nocache_Headers;

         Header ("Content-Type: " &
                 Get_Bloginfo ("html_type") & "; charset=" &
                 Get_Bloginfo ("charset"));

         if Globals.RELOCATE_DEF and then Globals.RELOCATE then -- Move flag is set.
            if
              Isset (X_SERVER, "PATH_INFO") and then
              (Get_As_String (X_SERVER, "PATH_INFO") /=
               Get_As_String (X_SERVER, "PHP_SELF"))
            then
               Set (X_SERVER, "PHP_SELF", From_String (
                    Str_Replace (Get_As_String (X_SERVER, "PATH_INFO"), "",
                                 Get_As_String (X_SERVER, "PHP_SELF"))));
            end if;

            declare
               URL : constant String :=
                 Dirname (Set_URL_Scheme ("http://" &
                                          Get_As_String (X_SERVER, "HTTP_HOST") &
                                          Get_As_String (X_SERVER, "PHP_SELF")));
            begin
               if Get_Option ("siteurl") /= URL then
                  Update_Option ("siteurl", From_String (URL));
               end if;
            end;
         end if;

         -- Set a cookie now to see if they are supported by the browser.
         declare
            Secure : constant Boolean :=
              "https" = Parse_URL (Wp_Login_URL, PHP_URL_SCHEME);
         begin
            Set_Cookie (-Globals.TEST_COOKIE, "WP Cookie check", 0,
                        -Globals.COOKIEPATH, -Globals.COOKIE_DOMAIN, Secure);

            if Globals.SITECOOKIEPATH /= Globals.COOKIEPATH then
               Set_Cookie (-Globals.TEST_COOKIE, "WP Cookie check", 0,
                           -Globals.SITECOOKIEPATH, -Globals.COOKIE_DOMAIN, Secure);
            end if;

            if Isset (XX_GET, "wp_lang") then
               Set_Cookie ("wp_lang",
                           Sanitize_Text_Field (Get_As_String (XX_GET, "wp_lang")), 0,
                           -Globals.COOKIEPATH, -Globals.COOKIE_DOMAIN, Secure);
            end if;
         end;

         --
         -- Fires when the login form is initialized.
         --
         -- @since 3.2.0
         --
         Do_Action ("login_init");

         --
         -- Fires before a specified login form action.
         --
         -- The dynamic portion of the hook name, `action`, refers to the action
         -- that brought the visitor to the login form.
         --
         -- Possible hook names include:
         --
         --  - `login_form_checkemail`
         --  - `login_form_confirm_admin_email`
         --  - `login_form_confirmaction`
         --  - `login_form_entered_recovery_mode`
         --  - `login_form_login`
         --  - `login_form_logout`
         --  - `login_form_lostpassword`
         --  - `login_form_postpass`
         --  - `login_form_register`
         --  - `login_form_resetpass`
         --  - `login_form_retrievepassword`
         --  - `login_form_rp`
         --
         -- @since 2.8.0
         --
         Do_Action ("login_form_" & (-Action));

         Interim_Login :=
           Isset (X_REQUEST, "interim-login");

         declare
            HTTP_Post : constant Boolean :=
              "POST" = Get_As_String (X_SERVER, "REQUEST_METHOD");

            --
            -- Filters the separator used between login form navigation links.
            --
            -- @since 4.9.0
            --
            -- @param string login_link_separator The separator used between login
            --                                    form navigation links.
            --
            Login_Link_Separator : constant String :=
              Apply_Filters ("login_link_separator", " | ");
         begin
            if Action = "confirm_admin_email" then
               Action_Confirm_Admin_Email (Errors);

            elsif Action = "postpass" then
               Action_Postpass;

            elsif Action = "logout" then
               Action_Logout;

            elsif
              Action = "lostpassword" or
              Action = "retrievepassword"
            then
               Action_Lostpassword (Login_Link_Separator,
                                    HTTP_Post);

            elsif Action = "resetpass" or Action = "rp" then
               Action_Resetpass (Login_Link_Separator);

            elsif Action = "register" then
               Action_Register (Login_Link_Separator,
                                HTTP_Post);

            elsif Action = "checkemail" then
               Action_Checkmail;

            elsif Action = "confirmaction" then
               Action_Confirmaction;

            elsif Action = "login" or True then -- Default
               Action_Login (Login_Link_Separator);
            end if;
         end;
      end;
   end Render;

end Wp_Login;
