
with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Text_Io;

with Arrays;
with Globals;
with Hb_Common;
with Php;

with Gnatcoll.Json;
with Templates_Parser;

with Adi_Credits;
with Inc_General_Templates;
with Inc_L10n;

package body Adm_Credits
is
   use Ada.Strings.Unbounded;
   use Ada.Text_Io;
   use Arrays;
   use Hb_Common;
   use Inc_L10n;
   use Php;

   subtype Json_Value is Gnatcoll.Json.Json_Value;

   function Translation
      return Templates_Parser.Translate_Table;

   ------------
   -- Render --
   ------------

   procedure Render
   is
      List            : constant List_Type :=
         Explode ("-", Inc_General_Templates.Get_Bloginfo ("version"));

      Display_Version : constant String     := "XXX-512"; -- -List.First_Element;
      Credits         : constant Json_Value := Adi_Credits.Wp_Credits; -- ()
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
               Set ("VAR_credits_contributors", X_E ("Contributors"));

            elsif Var_Name = "VAR_credits_header" then
               Clear_Echo;
               Printf (
                  -- translators: %s: Version number.
                  abs "WordPress %s was created by a worldwide team of passionate individuals",
                  Display_Version);
               Set ("VAR_credits_header", Get_Echo);

            elsif Var_Name = "VAR_credits_about" then
               Set ("VAR_credits_about", X_E ("What&#8217;s New"));

            elsif Var_Name = "VAR_credits_credits" then
               Set ("VAR_credits_credits", X_E ("Credits"));

            elsif Var_Name = "VAR_credits_freedoms" then
               Set ("VAR_credits_freedoms", X_E ("Freedoms"));

            elsif Var_Name = "VAR_credits_privacy" then
               Set ("VAR_credits_privacy", X_E ("Privacy"));

            elsif Var_Name = "VAR_credits_not_credits" then
               Set ("VAR_credits_not_credits", Credits.Is_Empty);

            elsif Var_Name = "VAR_credits_created" then
               Clear_Echo;
               Printf (
                  -- translators: 1: https://wordpress.org/about/
                  abs "WordPress is created by a <a href=""%1$s"">worldwide team</a> of passionate individuals.",
                  abs "https://wordpress.org/about/");
               Set ("VAR_credits_created", Get_Echo);

            elsif Var_Name = "VAR_credits_see_your_name" then
               Set ("VAR_credits_see_your_name",
                    X_E ("Want to see your name in lights on this page?"));

            elsif Var_Name = "VAR_credits_core_developers" then
               Clear_Echo;

               declare
                  Groups    : Json_Value := Credits.Get ("groups");
                  Core_Devs : Json_Value := Groups. Get ("core-developers");
               begin
                  Wp_Credits_Section_Title (Core_Devs);
                  Wp_Credits_Section_List  (Credits, "core-developers");
                  Wp_Credits_Section_List  (Credits, "contributing-developers");
               end;
               Set ("VAR_credits_core_developers", Get_Echo);

            elsif Var_Name = "VAR_credits_props" then
               Clear_Echo;

               declare
                  Groups : Json_Value := Credits.Get ("groups");
                  Props  : Json_Value := Groups. Get ("props");
               begin
                  Wp_Credits_Section_Title (Props);
                  Wp_Credits_Section_List  (Credits, "props");
               end;
               Set ("VAR_credits_props", Get_Echo);

            elsif Var_Name = "VAR_credits_validators" then
               Clear_Echo;

               declare
                  Groups     : Json_Value := Credits.Get ("groups");
                  Validators : Json_Value := Groups. Get ("validators");
               begin
                  Wp_Credits_Section_Title (Validators);
                  Wp_Credits_Section_List  (Credits, "validators");
                  Wp_Credits_Section_List  (Credits, "translators");
               end;
               Set ("VAR_credits_validators", Get_Echo);

            elsif Var_Name = "VAR_credits_libraries" then
               Clear_Echo;

               declare
                  Groups    : Json_Value := Credits.Get ("groups");
                  Libraries : Json_Value := Groups. Get ("libraries");
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
            null;
--            Printf (-Payload);
            Clear_Echo;
            Echo (-Payload);
--            return AWS.Response.Build ("text/html", Payload);
         end;
--   exception
--      when Occurrence : others =>
--         Put_Line (Ada.Exceptions.Exception_Information (Occurrence));
--         raise;

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
