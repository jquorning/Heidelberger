--
-- Credits administration panel.
--
-- @package WordPress
-- @subpackage Administration
--

with Ada.Strings.Unbounded;

with Globals;
with Hb_Common;
with Lists;
with Php;

with GNATCOLL.JSON;
with Templates_Parser;

with Adi_Credits;
with Inc_General_Templates;
with Inc_L10n;

package body Adm_Credits
is
   use Lists;

   subtype JSON_Value is GNATCOLL.JSON.JSON_Value;

   function Translation
      return Templates_Parser.Translate_Table;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Inc_L10n;

      List : constant List_Type :=
         Explode ("-", Inc_General_Templates.Get_Bloginfo ("version"));

      Display_Version : constant String     := -List.First_Element;
      Credits         : constant JSON_Value := Adi_Credits.Wp_Credits; -- ()
   begin
      Globals.Title := +abs "Credits";

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

            use Adi_Credits;
         begin
            if Var_Name = "VAR_credits_contributors" then
               Clear_Echo;
               X_E ("Contributors");
               Set ("VAR_credits_contributors", Get_Echo);

            elsif Var_Name = "VAR_credits_header" then
               Clear_Echo;
               Printf (
                  -- translators: %s: Version number.
                  abs "WordPress %s was created by a worldwide team of passionate individuals",
                  To_List (Display_Version));
               Set ("VAR_credits_header", Get_Echo);

            elsif Var_Name = "VAR_credits_about" then
               Clear_Echo;
               X_E ("What&#8217;s New");
               Set ("VAR_credits_about", Get_Echo);

            elsif Var_Name = "VAR_credits_credits" then
               Clear_Echo;
               X_E ("Credits");
               Set ("VAR_credits_credits", Get_Echo);

            elsif Var_Name = "VAR_credits_freedoms" then
               Clear_Echo;
               X_E ("Freedoms");
               Set ("VAR_credits_freedoms", Get_Echo);

            elsif Var_Name = "VAR_credits_privacy" then
               Clear_Echo;
               X_E ("Privacy");
               Set ("VAR_credits_privacy", Get_Echo);

            elsif Var_Name = "VAR_credits_not_credits" then
               Set ("VAR_credits_not_credits", Credits.Is_Empty);

            elsif Var_Name = "VAR_credits_created" then
               Clear_Echo;
               Printf (
                  -- translators: 1: https://wordpress.org/about/
                  abs "WordPress is created by a <a href=""%1$s"">worldwide team</a> of passionate individuals.",
                  To_List (abs "https://wordpress.org/about/"));
               Set ("VAR_credits_created", Get_Echo);

            elsif Var_Name = "VAR_credits_see_your_name" then
               Clear_Echo;
               X_E ("Want to see your name in lights on this page?");
               Set ("VAR_credits_see_your_name", Get_Echo);

            elsif Var_Name = "VAR_credits_core_developers" then
               Clear_Echo;
               declare
                  Groups    : constant JSON_Value := Credits.Get ("groups");
                  Core_Devs : constant JSON_Value := Groups. Get ("core-developers");
               begin
                  Wp_Credits_Section_Title (Core_Devs);
                  Wp_Credits_Section_List  (Credits, "core-developers");
                  Wp_Credits_Section_List  (Credits, "contributing-developers");
               end;
               Set ("VAR_credits_core_developers", Get_Echo);

            elsif Var_Name = "VAR_credits_props" then
               Clear_Echo;

               declare
                  Groups : constant JSON_Value := Credits.Get ("groups");
                  Props  : constant JSON_Value := Groups. Get ("props");
               begin
                  Wp_Credits_Section_Title (Props);
                  Wp_Credits_Section_List  (Credits, "props");
               end;
               Set ("VAR_credits_props", Get_Echo);

            elsif Var_Name = "VAR_credits_validators" then
               Clear_Echo;

               declare
                  Groups     : constant JSON_Value := Credits.Get ("groups");
                  Validators : constant JSON_Value := Groups. Get ("validators");
               begin
                  Wp_Credits_Section_Title (Validators);
                  Wp_Credits_Section_List  (Credits, "validators");
                  Wp_Credits_Section_List  (Credits, "translators");
               end;
               Set ("VAR_credits_validators", Get_Echo);

            elsif Var_Name = "VAR_credits_libraries" then
               Clear_Echo;

               declare
                  Group     : constant JSON_Value := Credits.Get ("groups");
                  Libraries : constant JSON_Value := Group.Get ("libraries");
               begin
                  Wp_Credits_Section_Title (Libraries);
                  Wp_Credits_Section_List  (Credits, "libraries");
               end;
               Set ("VAR_credits_validators", Get_Echo);
            end if;
         end Value;

         Lazy    : aliased My_Lazy;
         Payload : constant Unbounded_String :=
            Templates_Parser.Parse ("page/admin/credits.thtml",
                                    Translation,
                                    Lazy_Tag => Lazy'Unchecked_Access);
      begin
         Clear_Echo;
         Echo (-Payload);
      end;
   end Render;

   ------------------
   -- Translations --
   ------------------

   function Translation
      return Templates_Parser.Translate_Table
   is
      use Templates_Parser;

      Table : constant Translate_Table :=
         (Assoc ("MANUAL_TOC",         "TOC"),
          Assoc ("MANUAL_INDEX",       "INDEX"),
          Assoc ("MANUAL_AUTH_SEARCH", "SEARCH"));
   begin
      return Table;
   end Translation;

end Adm_Credits;
