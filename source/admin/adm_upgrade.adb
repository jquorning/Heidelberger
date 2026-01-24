--
-- Upgrade WordPress Page.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Php.Echoing;
with Php.Errors;
with Php.Files;
with Php.HTML;
with Php.Misc;
with Php.Strings;

with Templates_Parser;

with Arrays;
with Binder;
with Databases;
with Globals;
with UStrings;
with Lists;

with Adi_Upgrade;
with Inc_Formatting;
with Inc_Functions;
with Inc_General_Templates;
with Inc_L10n;
with Inc_Options;
with Inc_Pluggables;
with Inc_Versions;
with Wp_Load;

package body Adm_Upgrade
is
   use Arrays;
   use Lists;

   type Step_Value is range 0 .. 1;

   procedure Build_Update_Message (Wp_Version    : String;
                                   PHP_Compat    : Boolean;
                                   MySQL_Compat  : Boolean;
                                   PHP_Version   : String;
                                   MySQL_Version : String);

   procedure Build_Update_Switch (Step : Step_Value);

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Ada.Strings.Unbounded;
      use Php.Echoing;
      use Php.HTML;
      use Php.Files;
      use Php.Misc;
      use Databases;
      use UStrings;
      use Adi_Upgrade;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_L10n;
      use Inc_Options;
      -- global wp_version, required_php_version, required_mysql_version, wpdb;

      Step : Step_Value;

      PHP_Version   : constant String  := Php.Misc.PHP_VERSION;
      MySQL_Version : constant String  := Globals.WpDB.DB_Version;

      PHP_Compat : constant Boolean :=
        Version_Compare (PHP_Version,
                         Inc_Versions.Required_PHP_Version, ">=");

      MySQL_Compat : constant Boolean :=
        (if
           File_Exists ((-Globals.WP_CONTENT_DIR) & "/db.php") and then
           Globals.WpDB.Engine not in Engine_MySQL
--         Empty (Globals.WpDB.Is_MySQL)
         then True
         else Version_Compare (MySQL_Version,
                               Inc_Versions.Required_MySQL_Version, ">="));
   begin
      --
      -- We are upgrading WordPress.
      --
      -- @since 1.5.1
      -- @var bool
      --
      Globals.WP_INSTALLING := True;
      -- define( 'WP_INSTALLING', true );

      -- Load WordPress Bootstrap
      -- require dirname( __DIR__ ) . '/wp-load.php';
      Wp_Load.Run;

      Nocache_Headers;

      Delete_Site_Transient ("update_core");

      if Isset (Binder.XX_GET, "step") then
         if Get_As_String (Binder.XX_GET, "step") = "upgrade_db" then
            -- Do it. No output.
            Wp_Upgrade;
            Php.Errors.Die ("0");
         else
            Step := Step_Value (As_Integer (Get (Binder.XX_GET, "step")));
         end if;
      else
         Step := 0;
      end if;

      Header ("Content-Type: " & Get_Option ("html_type") &
              "; charset=" & Get_Option ("blog_charset"));

      declare
         use Templates_Parser;

         type My_Lazy is new Dynamic.Lazy_Tag with null record;

         overriding
         procedure Value (Lazy_Tag     : access My_Lazy;
                          Var_Name     : in     String;
                          Translations : in out Translate_Set);

         overriding
         procedure Value (Lazy_Tag     : access My_Lazy;
                          Var_Name     : in     String;
                          Translations : in out Translate_Set)
         is
            procedure Set (Var : String; Value : String);
            procedure Set (Var : String; Value : Boolean);

            procedure Set (Var : String; Value : String) is
            begin
               Insert (Translations, Assoc (Var, Value));
            end Set;

            procedure Set (Var : String; Value : Boolean) is
            begin
               Insert (Translations, Assoc (Var, Value));
            end Set;

         begin
            if Var_Name = "VAR_upgrade_language_attributes" then
               Set ("VAR_upgrade_language_attributes",
                    Get_Language_Attributes);

            elsif Var_Name = "VAR_upgrade_bloginfo" then
               Set ("VAR_upgrade_bloginfo",
                    Get_Bloginfo ("html_type"));

            elsif Var_Name = "VAR_upgrade_charset" then
               Set ("VAR_upgrade_charset",
                    String'(Get_Option ("blog_charset")));

            elsif Var_Name = "VAR_upgrade_title" then
               Clear_Echo;
               X_E ("WordPress &rsaquo; Update");
               Set ("VAR_upgrade_title", Get_Echo);

            elsif Var_Name = "VAR_upgrade_admin_css" then
               Clear_Echo;
               Wp_Admin_CSS ("install", True);
               Set ("VAR_upgrade_admin_css", Get_Echo);

            elsif Var_Name = "VAR_upgrade_logo" then
               Set ("VAR_upgrade_logo",
                    ESC_URL (abs "https://wordpress.org/"));

            elsif Var_Name = "VAR_upgrade_wordpress" then
               Clear_Echo;
               X_E ("WordPress");
               Set ("VAR_upgrade_wordpress", Get_Echo);

            elsif Var_Name = "VAR_upgrade_cond_installed" then
               declare
                  Cond : constant Boolean :=
                    Integer'(Get_Option ("db_version")) =
                    Inc_Versions.Wp_DB_Version or else
                    not Is_Blog_Installed;
               begin
                  Set ("VAR_upgrade_cond_installed", Cond);
               end;

            elsif Var_Name = "VAR_upgrade_h1_not_required" then
               Clear_Echo;
               X_E ("No Update Required");
               Set ("VAR_upgrade_h1_not_required", Get_Echo);

            elsif Var_Name = "VAR_upgrade_up_to_date" then
               Clear_Echo;
               X_E ("Your WordPress database is already up to date!");
               Set ("VAR_upgrade_up_to_date", Get_Echo);

            elsif Var_Name = "VAR_upgrade_step_href" then
               Set ("VAR_upgrade_step_href",
                    String'(Get_Option ("home")));

            elsif Var_Name = "VAR_upgrade_step_continue" then
               Clear_Echo;
               X_E ("Continue");
               Set ("VAR_upgrade_step_continue", Get_Echo);

            elsif Var_Name = "VAR_upgrade_cond_not_compat" then
               declare
                  Cond : constant Boolean :=
                    not PHP_Compat or not MySQL_Compat;
               begin
                  Set ("VAR_upgrade_cond_not_compat", Cond);
               end;

            elsif Var_Name = "VAR_upgrade_update" then
               Clear_Echo;

               Build_Update_Message (Wp_Version    => Inc_Versions.Wp_Version,
                                     PHP_Compat    => PHP_Compat,
                                     MySQL_Compat  => MySQL_Compat,
                                     PHP_Version   => PHP_Version,
                                     MySQL_Version => MySQL_Version);

               Set ("VAR_upgrade_update", Get_Echo);

            elsif Var_Name = "VAR_upgrade_switch_step" then
               Clear_Echo;
               Build_Update_Switch (Step);
               Set ("VAR_upgrade_switch_step", Get_Echo);

            else
               raise Program_Error with "Unhandled var_name: " & Var_Name;
            end if;
         end Value;

         Lazy    : aliased My_Lazy;
         Payload : constant String :=
            Templates_Parser.Parse ("page/admin/upgrade.thtml",
                                    Lazy_Tag => Lazy'Unchecked_Access);
      begin
         Clear_Echo;
         Echo (Payload);
      end;
   end Render;

   --------------------------
   -- Build_Update_Message --
   --------------------------

   procedure Build_Update_Message (Wp_Version    : String;
                                   PHP_Compat    : Boolean;
                                   MySQL_Compat  : Boolean;
                                   PHP_Version   : String;
                                   MySQL_Version : String)
   is
      use Ada.Strings.Unbounded;
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;

      Version_URL : constant String :=
        Sprintf (
          -- translators: %s: WordPress version.
          ESC_URL (abs "https://wordpress.org/support/wordpress-version/version-%s/"),
          To_List (Sanitize_Title (Wp_Version))
        );

      PHP_Update_Message_2 : constant String :=
        "</p><p>" &
        Sprintf (
          -- translators: %s: URL to Update PHP page.
          abs "<a href=""%s"">Learn more about updating PHP</a>.",
          To_List (ESC_URL (Wp_Get_Update_PHP_URL))
        );

      Annotation : constant String :=
        Wp_Get_Update_PHP_Annotation;

      PHP_Update_Message : constant String :=
        (if Annotation /= ""
           then PHP_Update_Message_2 & "</p><p><em>" & Annotation & "</em>"
         else PHP_Update_Message_2);

      Message : Unbounded_String;
   begin
      if not MySQL_Compat and not PHP_Compat then
         Message :=
           +Sprintf (
              -- translators: 1: URL to WordPress release notes, 2: WordPress version number, 3: Minimum required PHP version number, 4: Minimum required MySQL version number, 5: Current PHP version number, 6: Current MySQL version number.
              abs "You cannot update because <a href=""%1s"">WordPress %2s</a> requires PHP version %3s or higher and MySQL version %4s or higher. You are running PHP version %5s and MySQL version %6s.",
              To_List (List => (
                1 => +Version_URL,
                2 => +Wp_Version,
                3 => +Inc_Versions.Required_PHP_Version,
                4 => +Inc_Versions.Required_MySQL_Version,
                5 => +PHP_Version,
                6 => +MySQL_Version
              ))
           ) & PHP_Update_Message;

      elsif not PHP_Compat then
         Message :=
           +Sprintf (
              -- translators: 1: URL to WordPress release notes, 2: WordPress version number, 3: Minimum required PHP version number, 4: Current PHP version number.
              abs "You cannot update because <a href=""%1s"">WordPress %2s</a> requires PHP version %3s or higher. You are running version %4s.",
              To_List (List => (
                1 => +Version_URL,
                2 => +Wp_Version,
                3 => +Inc_Versions.Required_PHP_Version,
                4 => +PHP_Version
              ))
            ) & PHP_Update_Message;

      elsif not MySQL_Compat then
         Message :=
           +Sprintf (
              -- translators: 1: URL to WordPress release notes, 2: WordPress version number, 3: Minimum required MySQL version number, 4: Current MySQL version number.
              abs "You cannot update because <a href=""%1s"">WordPress %2s</a> requires MySQL version %3s or higher. You are running version %4s.",
              To_List (List => (
                1 => +Version_URL,
                2 => +Wp_Version,
                3 => +Inc_Versions.Required_MySQL_Version,
                4 => +MySQL_Version
              ))
            );
      end if;

      Echo ("<p>" & (-Message) & "</p>");
   end Build_Update_Message;

   -------------------------
   -- Build_Update_Switch --
   -------------------------

   procedure Build_Update_Switch (Step : Step_Value)
   is
      use Php.Echoing;
      use Php.HTML;
      use Adi_Upgrade;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_L10n;
      use Inc_Pluggables;
   begin
      case Step is

      when 0 =>
         declare
            Referer : constant String := Wp_Get_Referer;
            Goback  : constant String :=
              (if Referer /= ""
                 then URL_Encode (Sanitize_URL (Referer))
               else "");
         begin
            Echo ("<h1>");
            X_E ("Database Update Required");
            Echo ("</h1>");
            Echo ("<p>");
            X_E ("WordPress has been updated! Next and final step is to update your database to the newest version.");
            Echo ("</p>");
            Echo ("<p>");
            X_E ("The database update process may take a little while, so please be patient.");
            Echo ("</p>");
            Echo ("<p class=""step""><a class=""button button-large button-primary"" href=""upgrade.php?step=1&backto=" & Goback & """>");
            X_E ("Update WordPress Database");
            Echo ("</a></p>");
         end;

      when 1 =>
         Wp_Upgrade;

         declare
            Backto_3 : constant String :=
              (if not Empty (Binder.XX_GET, "backto")
               then Wp_Unslash (URL_Decode (Get_As_String (Binder.XX_GET, "backto")))
               else As_String (X_Get_Option ("home")) & '/');

            Backto_2 : constant String := ESC_URL (Backto_3);

            Backto : constant String :=
              Wp_Validate_Redirect (Backto_2, As_String (X_Get_Option ("home")) & '/');
         begin
            Echo ("<h1>");
            X_E ("Update Complete");
            Echo ("</h1>");
            Echo ("<p>");
            X_E ("Your WordPress database has been successfully updated!");
            Echo ("</p>");
            Echo ("<p class=""step""><a class=""button button-large"" href=""" & Backto & """>");
            X_E ("Continue");
            Echo ("</a></p>");
         end;

      end case;
   end Build_Update_Switch;

end Adm_Upgrade;
