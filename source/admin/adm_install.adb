--
-- WordPress Installer
--
-- @package WordPress
-- @subpackage Administration
--

-- Sanity check.
-- if ( false ) {
--         ?>
-- <!DOCTYPE html>
-- <html>
-- <head>
--         <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
--         <title>Error: PHP is not running</title>
-- </head>
-- <body class="wp-core-ui">
--         <p id="logo"><a href="https://wordpress.org/">WordPress</a></p>
--         <h1>Error: PHP is not running</h1>
--         <p>WordPress requires that your web server is running PHP. Your server does not have PHP installed, or PHP is turned off.</p>
-- </body>
-- </html>
--         <?php
-- }

with Php.Echoing;
with Php.Errors;
with Php.Files;
with Php.HTML;
with Php.Misc;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Arrays;
with Binder;
with Constants;
with Globals;
with UStrings;
with Lists;

with Adi_Templates;
with Adi_Translation_Install;
with Adi_Upgrade;

-- with Class_Locales;
with Class_WpDB;
with Inc_Formatting;
with Inc_Functions;
with Inc_Functions_Wp_Scripts;
with Inc_General_Templates;
with Inc_L10n;
with Inc_Plugins;
with Inc_Pluggables;
with Inc_Vars;
with Inc_Versions;

with Wp_Load;

package body Adm_Install
is

   --
   --
   --
   procedure Step_0 (Language : String;
                     Scripts  : in out Lists.List_Type);

   --
   --
   --
   procedure Step_1 (Language : String;
                     Scripts  : in out Lists.List_Type);

   --
   --
   --
   procedure Step_2 (Language : String;
                     Scripts  : in out Lists.List_Type);

   --------------------
   -- Display_Header --
   --------------------

   procedure Display_Header (Body_Classes : String := "")
   is
      use Php.Echoing;
      use Php.HTML;
      use UStrings;
      use Inc_General_Templates;
      use Inc_L10n;

      Body_Classes_2 : UString := +Body_Classes;
   begin
      Header ("Content-Type: text/html; charset=utf-8");
      if Is_RTL then
         Append (Body_Classes_2, "rtl");
      end if;

      if Body_Classes_2 /= "" then
         Body_Classes_2 := " " & Body_Classes_2;
      end if;

      Echo ("<!DOCTYPE html>" & NL);
      Echo ("<html ");
      Language_Attributes;
      Echo (">" & NL);
      Echo ("<head>" & NL);
      Echo ("    <meta name=""viewport"" content=""width=device-width"" />" & NL);
      Echo ("    <meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />" & NL);
      Echo ("    <meta name=""robots"" content=""noindex,nofollow"" />" & NL);
      Echo ("    <title>");
      X_E ("WordPress &rsaquo; Installation");
      Echo ("</title>" & NL);
      Echo ("    ");
      Wp_Admin_CSS ("install", Force_Echo => True);
      Echo (NL);
      Echo ("</head>" & NL);
      Echo ("<body class=""wp-core-ui" & (-Body_Classes_2) & """>" & NL);
      Echo ("<p id=""logo"">");
      X_E ("WordPress");
      Echo ("</p>" & NL);
   end Display_Header;

   ------------------------
   -- Display_Setup_Form --
   ------------------------

   procedure Display_Setup_Form (Error : String := "") -- null
   is
      use Php.Echoing;
      use Php.Strings;
      use Arrays;
      use Binder;
      use UStrings;
      use Lists;
      use Adi_Templates;
      use Class_WpDB;
      use Inc_Formatting;
      use Inc_General_Templates;
      use Inc_L10n;
      use Inc_Plugins;
      use Inc_Pluggables;

      Statement : constant Statement_Type :=
        Globals.WpDB.Prepare ("SHOW TABLES LIKE %s",
                              To_List (Globals.WpDB.ESC_Like (-Globals.WpDB.Users)));

      User_Table : constant Boolean :=
        (Globals.WpDB.Get_Var (Statement) /= ""); -- null);

      -- Ensure that sites appear in search engines by default.
      Blog_Public : Integer := 1;
   begin
      if Isset (X_POST, "weblog_title") then
         Blog_Public := (if Isset (X_POST, "blog_public")
                         then As_Integer (Get (X_POST, "blog_public"))
                         else Blog_Public);
      end if;

      declare
         Weblog_Title : constant String :=
           (if Isset (X_POST, "weblog_title")
            then Trim (Wp_Unslash (Get_As_String (X_POST, "weblog_title"))) else "");

         User_Name : constant String :=
           (if Isset (X_POST, "user_name")
            then Trim (Wp_Unslash (Get_As_String (X_POST, "user_name")))    else "");

         Admin_Email : constant String :=
           (if Isset (X_POST, "admin_email")
            then Trim (Wp_Unslash (Get_As_String (X_POST, "admin_email")))  else "");
      begin
         if Error /= "" then
--       if not Is_Null (Error) then
            Echo ("<h1>");
            X_Ex ("Welcome", "Howdy");
            Echo ("</h1>" & NL);
            Echo ("<p class=""message"">" & Error & "</p>" & NL);
         end if;

         Echo ("<form id=""setup"" method=""post"" action=""install.php?step=2"" novalidate=""novalidate"">" & NL);
         Echo ("        <table class=""form-table"" role=""presentation"">" & NL);
         Echo ("                <tr>" & NL);
         Echo ("                        <th scope=""row""><label for=""weblog_title"">");
         X_E ("Site Title");
         Echo ("</label></th>" & NL);
         Echo ("                        <td><input name=""weblog_title"" type=""text"" id=""weblog_title"" size=""25"" value=""" & ESC_Attr (Weblog_Title) & """ /></td>" & NL);
         Echo ("                </tr>" & NL);
         Echo ("                <tr>" & NL);
         Echo ("                        <th scope=""row""><label for=""user_login"">");
         X_E ("Username");
         Echo ("</label></th>" & NL);
         Echo ("                        <td>" & NL);

         if User_Table then
            X_E ("User(s) already exists.");
            Echo ("<input name=""user_name"" type=""hidden"" value=""admin"" />" & NL);
         else
            Echo ("<input name=""user_name"" type=""text"" id=""user_login"" size=""25"" value=""" & ESC_Attr (Sanitize_User (User_Name, True)) & """ />" & NL);
            Echo ("<p>");
            X_E ("Usernames can have only alphanumeric characters, spaces, underscores, hyphens, periods, and the @ symbol.");
            Echo ("</p>" & NL);
         end if;

         Echo ("                        </td>" & NL);
         Echo ("                </tr>" & NL);
         if not User_Table then
            Echo ("                <tr class=""form-field form-required user-pass1-wrap"">" & NL);
            Echo ("                        <th scope=""row"">" & NL);
            Echo ("                                <label for=""pass1"">" & NL);
            Echo ("                                        ");
            X_E ("Password");
            Echo (NL);
            Echo ("                                </label>" & NL);
            Echo ("                        </th>" & NL);
            Echo ("                        <td>" & NL);
            Echo ("                            <div class=""wp-pwd"">" & NL);
            declare
               Initial_Password : String :=
                 (if Isset (X_POST, "admin_password")
                  then Strip_Slashes (Get_As_String (X_POST, "admin_password"))
                  else Wp_Generate_Password (18));
            begin
               Echo ("                                        <input type=""password"" name=""admin_password"" id=""pass1"" class=""regular-text"" autocomplete=""new-password"" data-reveal=""1"" data-pw=""" & ESC_Attr (Initial_Password) & """ aria-describedby=""pass-strength-result"" />" & NL);
            end;
            Echo ("                                        <button type=""button"" class=""button wp-hide-pw hide-if-no-js"" data-start-masked=""" & Boolean'Image (Isset (X_POST, "admin_password")) & """ data-toggle=""0"" aria-label=""");
            ESC_Attr_E ("Hide password");
            Echo (""">" & NL); -- (int)
            Echo ("                                                <span class=""dashicons dashicons-hidden""></span>" & NL);
            Echo ("                                                <span class=""text"">");
            X_E ("Hide");
            Echo ("</span>" & NL);
            Echo ("                                        </button>" & NL);
            Echo ("                                        <div id=""pass-strength-result"" aria-live=""polite""></div>" & NL);
            Echo ("                                </div>" & NL);
            Echo ("                                <p><span class=""description important hide-if-no-js"">" & NL);
            Echo ("                                <strong>");
            X_E ("Important:");
            Echo ("</strong>" & NL);
            -- translators: The non-breaking space prevents 1Password from thinking the text "log in" should trigger a password save prompt.
            Echo ("                                ");
            X_E ("You will need this password to log&nbsp;in. Please store it in a secure location.");
            Echo ("</span></p>" & NL);
            Echo ("                        </td>" & NL);
            Echo ("                </tr>" & NL);
            Echo ("                <tr class=""form-field form-required user-pass2-wrap hide-if-js"">" & NL);
            Echo ("                        <th scope=""row"">" & NL);
            Echo ("                                <label for=""pass2"">");
            X_E ("Repeat Password");
            Echo (NL);
            Echo ("                                        <span class=""description"">");
            X_E ("(required)");
            Echo ("</span>" & NL);
            Echo ("                                </label>" & NL);
            Echo ("                        </th>" & NL);
            Echo ("                        <td>" & NL);
            Echo ("                                <input name=""admin_password2"" type=""password"" id=""pass2"" autocomplete=""new-password"" />" & NL);
            Echo ("                        </td>" & NL);
            Echo ("                </tr>" & NL);
            Echo ("                <tr class=""pw-weak"">" & NL);
            Echo ("                        <th scope=""row"">");
            X_E ("Confirm Password");
            Echo ("</th>" & NL);
            Echo ("                        <td>" & NL);
            Echo ("                                <label>" & NL);
            Echo ("                                        <input type=""checkbox"" name=""pw_weak"" class=""pw-checkbox"" />" & NL);
            Echo ("                                        ");
            X_E ("Confirm use of weak password");
            Echo (NL);
            Echo ("                                </label>" & NL);
            Echo ("                        </td>" & NL);
            Echo ("                </tr>" & NL);
         end if;
         Echo ("                <tr>" & NL);
         Echo ("                        <th scope=""row""><label for=""admin_email"">");
         X_E ("Your Email");
         Echo ("</label></th>" & NL);
         Echo ("                        <td><input name=""admin_email"" type=""email"" id=""admin_email"" size=""25"" value=""" & ESC_Attr (Admin_Email) & """ />" & NL);
         Echo ("                        <p>");
         X_E ("Double-check your email address before continuing.");
         Echo ("</p></td>" & NL);
         Echo ("                </tr>" & NL);
         Echo ("                <tr>" & NL);
         Echo ("                        <th scope=""row"">");
         if Has_Action ("blog_privacy_selector") then
            X_E ("Site visibility");
         else
            X_E ("Search engine visibility");
         end if;
         Echo ("</th>" & NL);
         Echo ("                        <td>" & NL);
         Echo ("                                <fieldset>" & NL);
         Echo ("                                        <legend class=""screen-reader-text""><span>");
         if Has_Action ("blog_privacy_selector") then
            X_E ("Site visibility");
         else
            X_E ("Search engine visibility");
         end if;
         Echo (" </span></legend>" & NL);

         if Has_Action ("blog_privacy_selector") then
            Echo ("                                                <input id=""blog-public"" type=""radio"" name=""blog_public"" value=""1"" " & Checked (1, Blog_Public) & " />" & NL);
            Echo ("                                                <label for=""blog-public"">");
            X_E ("Allow search engines to index this site");
            Echo ("</label><br />" & NL);
            Echo ("                                                <input id=""blog-norobots"" type=""radio"" name=""blog_public"" value=""0"" " & Checked (0, Blog_Public) & " />" & NL);
            Echo ("                                                <label for=""blog-norobots"">");
            X_E ("Discourage search engines from indexing this site");
            Echo ("</label>" & NL);
            Echo ("                                                <p class=""description"">");
            X_E ("Note: Neither of these options blocks access to your site &mdash; it is up to search engines to honor your request.");
            Echo ("</p>" & NL);

            -- This action is documented in wp-admin/options-reading.php
            Do_Action ("blog_privacy_selector");
         else
            Echo ("                                                <label for=""blog_public""><input name=""blog_public"" type=""checkbox"" id=""blog_public"" value=""0"" " & Checked (0, Blog_Public) & " />" & NL);
            Echo ("                                                ");
            X_E ("Discourage search engines from indexing this site");
            Echo ("</label>" & NL);
            Echo ("                                                <p class=""description"">");
            X_E ("It is up to search engines to honor this request.");
            Echo ("</p>" & NL);
         end if;
         Echo ("                                </fieldset>" & NL);
         Echo ("                        </td>" & NL);
         Echo ("                </tr>" & NL);
         Echo ("        </table>" & NL);
         Echo ("        <p class=""step"">");
         Submit_Button (abs "Install WordPress", "large", "Submit", False,
                        To_Array (List => (1 => Build ("id", "submit"))));
         Echo ("</p>" & NL);
         Echo ("        <input type=""hidden"" name=""language"" value=""" & (if Isset (X_REQUEST, "language") then ESC_Attr (Get_As_String (X_REQUEST, "language")) else "") & " />" & NL);
         Echo ("</form>" & NL);
      end;
   end Display_Setup_Form;

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Php.Echoing;
      use Php.Errors;
      use Php.Files;
      use Php.Preg;
      use Php.Strings;
      use Php.Types;
      use Arrays;
      use Binder;
      use UStrings;
      use Lists;
--    use Class_Locales;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Functions_Wp_Scripts;
      use Inc_General_Templates;
      use Inc_L10n;
      use Inc_Vars;
      use Inc_Versions;
   begin
      --
      -- We are installing WordPress.
      --
      -- @since 1.5.1
      -- @var bool
      --
      Globals.WP_INSTALLING := True;
-- define( 'WP_INSTALLING', true );

-- Load WordPress Bootstrap
-- require_once dirname( __DIR__ ) . '/wp-load.php';
      Wp_Load.Run;

-- Load WordPress Administration Upgrade API
-- require_once ABSPATH . 'wp-admin/includes/upgrade.php';

-- Load WordPress Translation Install API
-- require_once ABSPATH . 'wp-admin/includes/translation-install.php';

-- Load wpdb
-- require_once ABSPATH . WPINC . '/class-wpdb.php';

-- nocache_headers();

-- $step = isset( $_GET['step'] ) ? (int) $_GET['step'] : 0;

      -- Let's check to make sure WP isn't already installed.
      if Is_Blog_Installed then
         Display_Header;
         Die (
           "<h1>" & abs "Already Installed" & "</h1>" &
           "<p>" & abs "You appear to have already installed WordPress. To reinstall please clear your old database tables first." & "</p>" &
           "<p class=""step""><a href=""" & ESC_URL (Wp_Login_URL) & """ class=""button button-large"">" & abs "Log In" & "</a></p>" &
           "</body></html>"
         );
      end if;

      --
      -- @global string $wp_version             The WordPress version string.
      -- @global string $required_php_version   The required PHP version string.
      -- @global string $required_mysql_version The required MySQL version string.
      -- @global wpdb   $wpdb                   WordPress database abstraction object.
      --
      -- global $wp_version, $required_php_version, $required_mysql_version, $wpdb;
      declare
         use Php.Misc;

         Php_Version   : constant String := Php.Misc.PHP_VERSION;
         Mysql_Version : constant String := Globals.WpDB.DB_Version; -- ();

         Php_Compat : constant Boolean :=
           Version_Compare (Php_Version, Required_PHP_Version, ">=");

         Mysql_Compat : constant Boolean :=
           Version_Compare (Mysql_Version, Required_MySQL_Version, ">=") or else
           File_Exists ((-Globals.WP_CONTENT_DIR) & "/db.php");

         Version_URL : constant String := Sprintf (
           -- translators: %s: WordPress version.
           ESC_URL (abs "https://wordpress.org/support/wordpress-version/version-%s/"),
           To_List (Sanitize_Title (Wp_Version))
         );

         Php_Update_Message : UString := +"</p><p>" & Sprintf (
           -- translators: %s: URL to Update PHP page.
           abs "<a href=""%s"">Learn more about updating PHP</a>.",
           To_List (ESC_URL (Wp_Get_Update_PHP_URL))
         );

         Annotation : constant String := Wp_Get_Update_PHP_Annotation;
         Compat : UString;
      begin
         if Annotation /= "" then
            Append (Php_Update_Message, "</p><p><em>" & Annotation & "</em>");
         end if;

         if not Mysql_Compat and then not Php_Compat then
            Compat := +Sprintf (
                -- translators: 1: URL to WordPress release notes, 2: WordPress version number, 3: Minimum required PHP version number, 4: Minimum required MySQL version number, 5: Current PHP version number, 6: Current MySQL version number.
                abs "You cannot install because <a href=""%1$s"">WordPress %2$s</a> requires PHP version %3$s or higher and MySQL version %4$s or higher. You are running PHP version %5$s and MySQL version %6$s.",
                [
                  1 => Version_URL,
                  2 => Wp_Version,
                  3 => Required_PHP_Version,
                  4 => Required_MySQL_Version,
                  5 => Php_Version,
                  6 => Mysql_Version
                ]
             ) & Php_Update_Message;

         elsif not Php_Compat then
            Compat := +Sprintf (
                -- translators: 1: URL to WordPress release notes, 2: WordPress version number, 3: Minimum required PHP version number, 4: Current PHP version number.
                abs "You cannot install because <a href=""%1$s"">WordPress %2$s</a> requires PHP version %3$s or higher. You are running version %4$s.",
                [
                  1 => Version_URL,
                  2 => Wp_Version,
                  3 => Required_PHP_Version,
                  4 => Php_Version
                ]
            ) & Php_Update_Message;

         elsif not Mysql_Compat then
            Compat := +Sprintf (
                -- translators: 1: URL to WordPress release notes, 2: WordPress version number, 3: Minimum required MySQL version number, 4: Current MySQL version number.
                abs "You cannot install because <a href=""%1$s"">WordPress %2$s</a> requires MySQL version %3$s or higher. You are running version %4$s.",
                [
                  1 => Version_URL,
                  2 => Wp_Version,
                  3 => Required_MySQL_Version,
                  4 => Mysql_Version
                ]
             );
         end if;

         if not Mysql_Compat or else not Php_Compat then
            Display_Header;
            Die ("<h1>" & abs "Requirements Not Met" & "</h1><p>" &
                 (-Compat) & "</p></body></html>");
         end if;

         if
           not Is_String (-Globals.WpDB.Base_Prefix) or else
           "" = Globals.WpDB.Base_Prefix
         then
            Display_Header;
            Die (
              "<h1>" & abs "Configuration Error" & "</h1>" &
              "<p>" &
              Sprintf (
                -- translators: %s: wp-config.php
                abs "Your %s file has an empty database table prefix, which is not supported.",
                To_List ("<code>wp-config.php</code>")
              ) & "</p></body></html>"
            );
         end if;

         -- Set error message if DO_NOT_UPGRADE_GLOBAL_TABLES isn't set as it will
         -- break install.
         if Constants.DO_NOT_UPGRADE_GLOBAL_TABLES then -- defined
            Display_Header;
            Die (
              "<h1>" & abs "Configuration Error" & "</h1>" &
              "<p>" &
              Sprintf (
                -- translators: %s: DO_NOT_UPGRADE_GLOBAL_TABLES
                abs "The constant %s cannot be defined when installing WordPress.",
                To_List ("<code>DO_NOT_UPGRADE_GLOBAL_TABLES</code>")
              ) & "</p></body></html>"
            );
         end if;

         --
         -- @global string    $wp_local_package Locale code of the package.
         -- @global WP_Locale $wp_locale        WordPress date and time locale object.
         --
         declare

            Scripts_To_Print : List_Type := To_List ("jquery");

            Language : UString;
            Step : constant Integer :=
              (if Isset (XX_GET, "step")
               then As_Integer (Get (XX_GET, "step"))
               else 0);

         begin
            if not Empty (X_REQUEST, "language") then
               Language := +Preg_Replace ("/[^a-zA-Z0-9_]/", "",
                                          Get_As_String (X_REQUEST, "language"));
            elsif Isset (Globals.GLOBALS, "wp_local_package") then
               Language := +Get_As_String (Globals.GLOBALS, "wp_local_package");
            end if;

            case Step is
            when 0 =>  -- Step 0.
               Step_0 (Language => -Language,
                       Scripts  => Scripts_To_Print);
               -- Dropthrough
               Step_1 (Language => -Language,
                       Scripts  => Scripts_To_Print);

            when 1 => -- Step 1, direct link or from language chooser.
               Step_1 (Language => -Language,
                       Scripts  => Scripts_To_Print);

            when 2 =>
               Step_2 (Language => -Language,
                       Scripts  => Scripts_To_Print);

            when others =>
               null;
            end case;

            if not Wp_Is_Mobile then
               Echo ("<script type=""text/javascript"">var t = document.getElementById('weblog_title'); if (t){ t.focus(); }</script>" & NL);
            end if;

            Wp_Print_Scripts (Scripts_To_Print);

            Echo ("<script type=""text/javascript"">" & NL);
            Echo ("jQuery( function( $ ) {" & NL);
            Echo ("        $( '.hide-if-no-js' ).removeClass( 'hide-if-no-js' );" & NL);
            Echo ("} );" & NL);
            Echo ("</script>" & NL);
            Echo ("</body>" & NL);
            Echo ("</html>" & NL);
         end;
      end;

   end Run;

   ------------
   -- Step_0 --
   ------------

   procedure Step_0 (Language : String;
                     Scripts  : in out Lists.List_Type)
   is
      use Php.Echoing;
      use Php.Strings;
      use Arrays;
      use Adi_Translation_Install;
   begin
      if Wp_Can_Install_Language_Pack and then Empty (Language) then
         declare
            Languages : constant Array_Type :=
              Wp_Get_Available_Translations;
         begin
            if not Languages.Is_Empty then
               Scripts.Append ("language-chooser");
               Display_Header ("language-chooser");
               Echo ("<form id=""setup"" method=""post"" action=""?step=1"">");
               Wp_Install_Language_Form (Languages);
               Echo ("</form>");
               return;
            end if;
         end;
      end if;
   end Step_0;

   ------------
   -- Step_1 --
   ------------

   procedure Step_1 (Language : String;
                     Scripts  : in out Lists.List_Type)
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Lists;
      use Adi_Translation_Install;
      use Inc_L10n;
   begin
      if not Empty (Language) then
         declare
            Loaded_Language : constant String :=
              Wp_Download_Language_Pack (Language);
         begin
            if Loaded_Language /= "" then
               Load_Default_Textdomain (Loaded_Language);
--             Set (Globals.GLOBALS, "wp_locale", new Wp_Locale);
            end if;
         end;
      end if;
      Append (Scripts, "user-profile");

      Display_Header;
      Echo ("<h1>");
      X_Ex ("Welcome", "Howdy");
      Echo ("</h1>" & NL);
      Echo ("<p>");
      X_E ("Welcome to the famous five-minute WordPress installation process! Just fill in the information below and you&#8217;ll be on your way to using the most extendable and powerful personal publishing platform in the world.");
      Echo ("</p>" & NL);

      Echo ("<h2>");
      X_E ("Information needed");
      Echo ("</h2>" & NL);
      Echo ("<p>");
      X_E ("Please provide the following information. Do not worry, you can always change these settings later.");
      Echo ("</p>" & NL);
      Display_Setup_Form;
   end Step_1;

   ------------
   -- Step_2 --
   ------------

   procedure Step_2 (Language : String;
                     Scripts  : in out Lists.List_Type)
   is
      use Php.Echoing;
      use Php.Strings;
      use Arrays;
      use Binder;
      use UStrings;
      use Lists;
      use Adi_Upgrade;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_L10n;

      Loaded_Language : UString;
   begin
      if
        not Empty (Language) and then
        Load_Default_Textdomain (Language)
      then
         Loaded_Language := +Language;
--       Set (Globals.GLOBALS, "wp_locale", new Wp_Locale);
      else
         Loaded_Language := +"en_US";
      end if;

      if not Empty (-Globals.WpDB.Error) then
         Wp_Die ("XXX-996"); -- Globals.WpDB.Error.Get_Error_Message);
      end if;
      Append (Scripts, "user-profile");

      Display_Header;
      -- Fill in the data we gathered.
      declare
         Weblog_Title : constant String :=
           (if Isset (X_POST, "weblog_title")
            then Trim (Wp_Unslash (Get_As_String (X_POST, "weblog_title")))
            else "");

         User_Name : constant String :=
           (if Isset (X_POST, "user_name")
            then Trim (Wp_Unslash (Get_As_String (X_POST, "user_name")))
            else "");

         Admin_Password : constant String :=
           (if Isset (X_POST, "admin_password")
            then Wp_Unslash (Get_As_String (X_POST, "admin_password"))
            else "");

         Admin_Password_Check : constant String :=
           (if Isset (X_POST, "admin_password2")
            then Wp_Unslash (Get_As_String (X_POST, "admin_password2"))
            else "");

         Admin_Email : constant String :=
           (if Isset (X_POST, "admin_email")
            then Trim (Wp_Unslash (Get_As_String (X_POST, "admin_email")))
            else "");

         Public : constant Boolean :=
           (if Isset (X_POST, "blog_public")
            then As_Integer (Get (X_POST, "blog_public")) /= 0
            else True);

         Error : Boolean := False;
      begin
         -- Check email address.
         if Empty (User_Name) then
            -- TODO: Poka-yoke.
            Display_Setup_Form (abs "Please provide a valid username.");
            Error := True;

         elsif Sanitize_User (User_Name, True) /= User_Name then
            Display_Setup_Form (abs "The username you provided has invalid characters.");
            Error := True;

         elsif Admin_Password /= Admin_Password_Check then
            -- TODO: Poka-yoke.
            Display_Setup_Form (abs "Your passwords do not match. Please try again.");
            Error := True;

         elsif Empty (Admin_Email) then
            -- TODO: Poka-yoke.
            Display_Setup_Form (abs "You must provide an email address.");
            Error := True;

         elsif Is_Email (Admin_Email) = "" then -- not
            -- TODO: Poka-yoke.
            Display_Setup_Form (abs "Sorry, that is not a valid email address. Email addresses look like <code>username@example.com</code>.");
            Error := True;
         end if;

         if False = Error then
            Globals.WpDB.Show_Errors;
            declare
               Result : constant Array_Type :=
                 Wp_Install (Weblog_Title, User_Name,
                             Admin_Email, Public, "",
                             Wp_Slash (Admin_Password),
                             -Loaded_Language);
            begin
               -- Setup upload directories for Debian #430781
               Globals.WpDB.Query ("UPDATE $wpdb->options set option_value = '$upload_path' where option_name = 'upload_path'");
               Globals.WpDB.Query ("UPDATE $wpdb->options set option_value = '$upload_url_path' where option_name = 'upload_url_path'");

               Echo ("<h1>");
               X_E ("Success!");
               Echo ("</h1>" & NL);

               Echo ("<p>");
               X_E ("WordPress has been installed. Thank you, and enjoy!");
               Echo ("</p>" & NL);

               Echo ("<table class=""form-table install-success"">" & NL);
               Echo ("        <tr>" & NL);
               Echo ("                <th>");
               X_E ("Username");
               Echo ("</th>" & NL);
               Echo ("                <td>" & ESC_HTML (Sanitize_User (User_Name, True)) & "</td>" & NL);
               Echo ("        </tr>" & NL);
               Echo ("        <tr>" & NL);
               Echo ("                <th>");
               X_E ("Password");
               Echo ("</th>" & NL);
               Echo ("                     <td>" & NL);
               Echo ("                        ");
               if
                 not Empty (Result, "password") and then
                 Empty (Admin_Password_Check)
               then
                  Echo ("                                <code>" & ESC_HTML (Get_As_String (Result, "password")) & "</code><br />" & NL);
               end if;
               Echo ("                        <p>" & Get_As_String (Result, "password_message") & "</p>" & NL);
               Echo ("                </td>" & NL);
               Echo ("        </tr>" & NL);
               Echo ("</table>" & NL);

               Echo ("<p class=""step""><a href=""" & ESC_URL (Wp_Login_URL) & """ class=""button button-large"">");
               X_E ("Log In");
               Echo ("</a></p>" & NL);
            end;
         end if;
      end;
   end Step_2;

end Adm_Install;
