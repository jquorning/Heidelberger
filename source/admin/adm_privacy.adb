--
-- Privacy administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Php.Echoing;

with Globals;
with UStrings;

with Templates_Parser;

with Adm_Admin;
with Adm_Admin_Footer;
with Adm_Admin_Header;

with Inc_Formatting;
with Inc_L10n;
with Inc_Link_Templates;

-- WordPress Administration Bootstrap
-- require_once __DIR__ . '/admin.php';
package body Adm_Privacy
is

   ---------
   -- Run --
   ---------

   procedure Run
   is
      use Php.Echoing;
      use UStrings;
      use Inc_L10n;

--    Display_Version : List_Type;
      Admin_Header : UString;
   begin
      Adm_Admin.Run;

      -- Used in the HTML title tag.
      Globals.Global_Title := +abs "Privacy";

--    Display_Version :=
--      Explode ("-", Inc_General_Templates.Get_Bloginfo ("version"));

      Clear_Echo;
      Adm_Admin_Header.Run;
      Admin_Header := +Get_Echo;
-- require_once ABSPATH . 'wp-admin/admin-header.php';

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

            procedure Set (Var : String; Value : String) is
            begin
               Insert (Translations, Assoc (Var, Value));
            end Set;

         begin
            if Var_Name = "VAR_privacy_h1" then
               Clear_Echo;
               X_E ("Privacy");
               Set ("VAR_privacy_h1", Get_Echo);

            elsif Var_Name = "VAR_privacy_header" then
               Clear_Echo;
               X_E ("We take privacy and transparency very seriously");
               Set ("VAR_privacy_header", Get_Echo);

            elsif Var_Name = "VAR_privacy_secondary_menu" then
               Clear_Echo;
               ESC_Attr_E ("Secondary menu");
               Set ("VAR_privacy_secondary_menu", Get_Echo);

            elsif Var_Name = "VAR_privacy_about" then
               Clear_Echo;
               X_E ("What&#8217;s New");
               Set ("VAR_privacy_about", Get_Echo);

            elsif Var_Name = "VAR_privacy_credits" then
               Clear_Echo;
               X_E ("Credits");
               Set ("VAR_privacy_credits", Get_Echo);

            elsif Var_Name = "VAR_privacy_freedoms" then
               Clear_Echo;
               X_E ("Freedoms");
               Set ("VAR_privacy_freedoms", Get_Echo);

            elsif Var_Name = "VAR_privacy_privacy" then
               Clear_Echo;
               X_E ("Privacy");
               Set ("VAR_privacy_privacy", Get_Echo);

            elsif Var_Name = "VAR_privacy_image" then
               Clear_Echo;
               Echo (Inc_Formatting.ESC_URL (
                       Inc_Link_Templates.Admin_URL ("images/privacy.svg?ver=6.1")));
               Set ("VAR_privacy_image", Get_Echo);

            elsif Var_Name = "VAR_privacy_text_1" then
               Clear_Echo;
               X_E ("From time to time, your WordPress site may send data to WordPress.org &#8212; including, but not limited to &#8212; the version of WordPress you are using, and a list of installed plugins and themes.");
               Set ("VAR_privacy_text_1", Get_Echo);

            elsif Var_Name = "VAR_privacy_text_2" then
               Clear_Echo;
               Printf (
                 -- translators: %s: https://wordpress.org/about/stats/
                 abs "This data is used to provide general enhancements to WordPress, which includes helping to protect your site by finding and automatically installing new updates. It is also used to calculate statistics, such as those shown on the <a href=""%s"">WordPress.org stats page</a>.",
                 [1 => abs "https://wordpress.org/about/stats/"]);
               Set ("VAR_privacy_text_2", Get_Echo);

            elsif Var_Name = "VAR_privacy_text_3" then
               Clear_Echo;
               Printf (
                 -- translators: %s: https://wordpress.org/about/privacy/
                 abs "We take privacy and transparency very seriously. To learn more about what data we collect, and how we use it, please visit <a href=""%s"">our Privacy Policy</a>.",
                 [1 => abs "https://wordpress.org/about/privacy/"]);
               Set ("VAR_privacy_text_3", Get_Echo);

            else
               raise Program_Error with "var_name not handled: " & Var_Name;

            end if;
         end Value;

         Lazy : aliased My_Lazy;
         Payload : constant UString :=
            Templates_Parser.Parse ("page/admin/privacy.thtml",
--                                  Translation,
                                    Lazy_Tag => Lazy'Unchecked_Access);
      begin
         Clear_Echo;
         Echo (-Admin_Header);
         Echo (-Payload);
      end;
      Adm_Admin_Footer.Run;
   end Run;

end Adm_Privacy;
