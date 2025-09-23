
with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Text_Io;

with Arrays;
with Globals;
with Hb_Common;
with L10n;
with Php;

with Gnatcoll.Json;
with Templates_Parser;

with Adi_Credits;
with Inc_General_Templates;

package body Adm_Credits
is
   use Ada.Strings.Unbounded;
   use Ada.Text_Io;
   use Arrays;
   use Hb_Common;
   use L10n;
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

            procedure Set (Var : String; Value : String) is
            begin
               Insert (Translations, Assoc (Var, Value));
            end Set;

            use Adi_Credits;
         begin
            if Var_Name = "VAR_credits_contributors" then
               Set ("VAR_credits_contributors", E_E ("Contributors"));

            elsif Var_Name = "VAR_credits_header" then
               Clear_Echo;
               Printf (
                  -- translators: %s: Version number.
                  abs "WordPress %s was created by a worldwide team of passionate individuals",
                  Display_Version);
               Set ("VAR_credits_header", Get_Echo);

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
