--
-- WordPress Credits Administration API.
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Ada.Strings.Unbounded;
with Ada.Text_IO;

with Arrays;
with Globals;
with Hb_Common;
with Lists;
with Php.Echoing;
with Php.Strings;

with Inc_Formatting;
with Inc_Options;
with Inc_Versions;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_HTTP;

package body Adi_Credits
is
   use Ada.Strings.Unbounded;
   use Ada.Text_IO;
   use Arrays;
   use Hb_Common;
   use Inc_L10n;
   use Lists;
   use Php;

   function Get_File (Filename : String)
                      return Unbounded_String;

   --
   -- Retrieve the contributor credits.
   --
   -- @since 3.2.0
   -- @since 5.6.0 Added the `version` and `locale` parameters.
   --
   -- @param string version WordPress version. Defaults to the current version.
   -- @param string locale  WordPress locale. Defaults to the current user"s locale.
   -- @return array|false A list of all of the contributors, or false on error.
   --
   function Wp_Credits (Version : String := "";
                        Locale  : String := "")
                        return JSON_Value
   is
      use Inc_Options;

      Version_2 : Unbounded_String := +Version;
      Locale_2  : Unbounded_String := +Locale;
      Results   : Inc_Options.String_Maps.Map; -- Array_Type;
   begin
      if Version = "" then
         -- Include an unmodified wp_version.
--         require ABSPATH . WPINC . "/version.php";

         Version_2 := +Inc_Versions.Wp_Version;
      end if;

      if Locale = "" then
         Locale_2 := +Get_User_Locale; -- ()
      end if;

      Results := Get_Site_Transient ("wordpress_credits_" & Locale);

      if True
--        not Is_Array (Results)
--        or else 0 /= Strpos (Version, "-")
--        or else (Isset (Results ("data") ("version")) and then
--                 Strpos (-Version_2, Results ("data") ("version")) /= 0)
      then
         declare
            URL : constant Unbounded_String :=
               +"http://api.wordpress.org/core/credits/1.1/?version=" &
               (-Version_2) & "&locale=" & (-Locale_2) & """";

            Options : constant Array_Type :=
               Arrays.To_Array ((1 => Build ("user-agent", "WordPress/" &
                          (-Version_2) & "; " & Inc_Link_Templates.Home_URL ("/"))));

            Response : Array_Type;
            JSON     : JSON_Value;
         begin
--            if Wp_Http_Supports (To_Array ("ssl")) then
--               url := Set_Url_Scheme (Url, "https");
--            end if;

            Response := Inc_HTTP.Wp_Remote_Get (-URL, Options);

--            if
--              Is_Wp_Error (Response) or else
--              200 /= Wp_Remote_Retrieve_Response_Code (Response)
--            then
--               return False;
--            end if;

            -- Added for dev jq
            JSON := Read (Get_File ("dev.json"));

--            Json := Json_Decode (Wp_Remote_Retrieve_Body (Response), True);
--          Results := Json_Decode (Wp_Remote_Retrieve_Body (Response), True);
--            if not Is_Array (Results) then
--               return false;
--            end if;

--            Set_Site_Transient ("wordpress_credits_" & Locale_2,
--                                Results, DAY_IN_SECONDS);
            return JSON;
         end;
      end if;

      return JSON_Null; -- Results;
   end Wp_Credits;

   --
   -- Retrieve the link to a contributor's WordPress.org profile page.
   --
   -- @access private
   -- @since 3.2.0
   --
   -- @param string display_name  The contributor"s display name (passed by reference).
   -- @param string username      The contributor"s username.
   -- @param string profiles      URL to the contributor"s WordPress.org profile page.
   --
   procedure X_Wp_Credits_Add_Profile_Link (Display_Name : in out String;
                                            Username     : String;
                                            Profiles     : String)
   is
      use Php.Strings;
      use Inc_Formatting;
   begin
      Display_Name := "<a href=""" & ESC_URL (Sprintf (Profiles, To_List (Username))) &
                      """>" & ESC_HTML (Display_Name) & "</a>";
   end X_Wp_Credits_Add_Profile_Link;

   --
   -- Retrieve the link to an external library used in WordPress.
   --
   -- @access private
   -- @since 3.2.0
   --
   -- @param string data External library data (passed by reference).
   --
   function X_Wp_Credits_Build_Object_Link (Data : JSON_Array)
                                            return String
--   procedure X_Wp_Credits_Build_Object_Link (Data : in out String)
   is
      use Inc_Formatting;

      Url  : constant String := Get (Data, 2).Get; -- Data (1);
      Name : constant String := Get (Data, 1).Get; -- Data (0);
      Href : constant String := ESC_URL (Url);
      Link : constant String := ESC_HTML (Name);
   begin
      return "<a href=""" & Href & """>" & Link & "</a>";
   end X_Wp_Credits_Build_Object_Link;

   --
   -- Displays the title for a given group of contributors.
   --
   -- @since 5.3.0
   --
   -- @param array group_data The current contributor group.
   --
   procedure Wp_Credits_Section_Title (Group_Data : JSON_Value)
   is
      use Php.Echoing;
      use Php.Strings;
      use Inc_Formatting;
   begin
--      if 0 = Count (Group_Data) then
--         return;
--      end if;

      declare
         Name         : constant JSON_Value := Get (Group_Data, "name");
         Placeholders : constant JSON_Value := Get (Group_Data, "placeholders");
      begin
         if Name.Kind = JSON_String_Type then
            if "Translators" = String'(Name.Get) then
               -- Considered a special slug in the API response. (Also, will never be
               -- returned for en_US.)
               Globals.Title := +X_X ("Translators",
                                      "Translate this to be the equivalent of English Translators in your language for the credits page Translators section");
            elsif Placeholders.Kind = JSON_Array_Type then  -- Isset
               -- phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
               Globals.Title := +Vsprintf (Translate (Name.Get), To_List ("XXX-913")); -- Placeholders.Get);
--             Globals.Title := +Vsprintf (Translate (Name.Get), Arrays.Empty_List); -- Placeholders.Get);
            else
               -- phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
               Globals.Title := +Translate (Name.Get);
            end if;

            Echo ("<h2 class=""wp-people-group-title"">" & ESC_HTML (-Globals.Title) &
                  "</h2>" & NL);
         end if;
      end;
   end Wp_Credits_Section_Title;

   --
   -- Displays a list of contributors for a given group.
   --
   -- @since 5.3.0
   --
   -- @param array  credits The credits groups returned from the API.
   -- @param string slug    The current group to display.
   --
   procedure Wp_Credits_Section_List (Credits : JSON_Value;
                                      Slug    : String     := "")
   is
      use Php.Echoing;
      use Php.Strings;
      use Inc_Formatting;

      Group : constant JSON_Value := Get (Credits, "groups");
      Slugs : constant JSON_Value := Get (Group,   Slug);

      Group_Data   : constant JSON_Value := Slugs;
      Credits_Data : constant JSON_Value := Get (Slugs, "data");
      -- Group_Data : Array_type := (if Isset (Credits ("groups") (Slug))
      --                             then Credits ("groups") (Slug) else Empty_Array);
      -- Credits_Data : String := Credits ("data");
      Typ  : constant JSON_Value := Get (Slugs, "type");
   begin
--      if 0 = Count (Group_Data) then
--         return;
--      end if;

--      if not Empty (Group_Data ("shuffle")) then
--         Shuffle (Group_Data ("data")); -- We were going to sort by ability to pronounce "hierarchical," but that wouldn"t be fair to Matt.
--      end if;

      if "list" = String'(Typ.Get) then
         declare
            Data : JSON_Value := Get (Group_Data, "data");
         begin
--         Array_Walk (Group_Data ("data"), "_wp_credits_add_profile_link", Credits_Data ("profiles"));
--         echo ("<p class=""wp-credits-list"">" & Wp_Sprintf ("%l.", Data) &
--               "</p>\n\n");
--         echo ("<p class=""wp-credits-list"">" & Wp_Sprintf ("%l.", Group_Data ("data")) & "</p>\n\n");
            null;
         end;
      elsif "libraries" = String'(Typ.Get) then
         declare
            Data : constant JSON_Array := Get (Group_Data, "data");
         begin
            for A of Data loop
--               Echo (X_Wp_Credits_Build_Object_Link (A));
               null;
            end loop;
--       Array_Walk (Group_Data ("data"), "_wp_credits_build_object_link");
--            Echo ("<p class=""wp-credits-list"">" &
--                  Wp_Sprintf ("%l.", Group_Data ("data")) & "</p>\n\n");
         end;

      else
         declare
            Compact : constant Boolean :=
               "compact" = String'(Get (Group_Data, "type").Get);

            Classes : constant String :=
               "wp-people-group " & (if Compact then "compact" else "");

            procedure Print_Them (Name  : UTF8_String;
                                  Value : JSON_Value);

            procedure Print_Them (Name  : UTF8_String;
                                  Value : JSON_Value)
            is
               Person_Data : constant JSON_Array := Get (Value);
            begin
               Echo ("<li class=""wp-person"" id=""wp-person-" &
                     ESC_Attr (Get (Person_Data, 3).Get) & """>" & NL_TAB); -- (2)
               Echo ("<a href=""" &
                     ESC_URL (Sprintf ("%s", -- Get (Credits_Data, "profiles").Get,
                                       To_List (Get (Person_Data, 2).Get))) &
                     """ class=""web"">");
               declare
                  use Inc_Link_Templates;

                  Size   : constant Integer := (if Compact then 80 else 160);
                  Data   : constant Array_Type :=
                     Get_Avatar_Data (Get (Person_Data, 2).Get & "@md5.gravatar.com",
                                      Arrays.To_Array ((1 =>
                                         Build ("size", Size))));     -- (1)

                  Data2x : constant Array_Type :=
                     Get_Avatar_Data (Get (Person_Data, 2).Get & "@md5.gravatar.com",
                                      Arrays.To_Array ((1 =>
                                         Build ("size", Size * 2)))); -- (1)
               begin
                  Echo ("<span class=""wp-person-avatar""><img src=""" &
                        ESC_URL (Get_As_String (Data,   "url")) & """ srcset=""" &
                        ESC_URL (Get_As_String (Data2x, "url")) &
                        " 2x"" class=""gravatar"" alt="""" /></span>" & NL);
                  Echo (ESC_HTML (Get (Person_Data, 1).Get) & "</a>" & NL_TAB); -- (0)
               end;
               if not Compact and then String'(Get (Person_Data, 4).Get) /= "" then
                  -- phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
                  Echo ("<span class=""title"">" & Translate (Get (Person_Data, 4).Get) & "</span>" & NL); -- (3)
               end if;
               Echo ("</li>" & NL);
            end Print_Them;

         begin
            Echo ("<ul class=""" & Classes & """ id=""wp-people-group-" &
                  Slug & """>" & NL);

            Map_JSON_Object (Get (Group_Data, "data"), CB => Print_Them'Access);

--             for Person_Data of Get (Group_Data, "data") loop
-- --               Echo ("<li class=""wp-person"" id=""wp-person-" &
-- --                     Esc_Attr (String'(Get (Person_Data, 3))) & """>" & "\n\t"); -- (2)
-- --               Echo ("<a href=""" & ESC_URL (Sprintf (Credits_Data ("profiles"), Person_Data (2))) & """ class=""web"">");

--                declare
--                   use Inc_Link_Templates;

--                   Size   : constant Integer := (if Compact then 80 else 160);
--                   Data   : Array_Type; -- := Get_Avatar_Data (Person_Data (1) & "@md5.gravatar.com", To_Array ((1 => Build ("size", Size))));
--                   Data2x : Array_Type; -- := Get_Avatar_Data (Person_Data (1) & "@md5.gravatar.com", To_Array ((1 => Build ("size", Size * 2))));
--                begin
--                   Echo ("<span class=""wp-person-avatar""><img src=""" &
--                         ESC_URL (Get (Data,   "url")) & """ srcset=""" &
--                         ESC_URL (Get (Data2x, "url")) &
--                         " 2x"" class=""gravatar"" alt="""" /></span>" & "\n");
-- --                  Echo (ESC_HTML (Person_Data (0)) & "</a>\n\t");
--                end;

-- --               if not Compact and then not Empty (Person_Data (3)) then
-- --                  -- phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
-- --                  Echo ("<span class=""title"">" & Translate (Person_Data (3)) & "</span>\n");
-- --               end if;
--                echo ("</li>\n");
--             end loop;
         end;
         Echo ("</ul>" & NL);
      end if;
   end Wp_Credits_Section_List;

   --------------
   -- Get_File --
   --------------

   function Get_File (Filename : String)
                      return Unbounded_String
   is
      File   : File_Type;
      Buffer : Unbounded_String;
   begin
      Open (File, In_File, Filename);
      while not End_Of_File (File) loop
         Append (Buffer, Get_Line (File));
      end loop;
      Close (File);
      return Buffer;
   end Get_File;

end Adi_Credits;
