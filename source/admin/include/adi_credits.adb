--
-- WordPress Credits Administration API.
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Ada.Strings.Unbounded;
with Ada.Text_Io;

with Arrays;
with Globals;
with Hb_Common;
with Php;

with Inc_Formatting;
with Inc_Options;
with Inc_Versions;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Http;

package body Adi_Credits
is
   use Ada.Strings.Unbounded;
   use Ada.Text_Io;
   use Arrays;
   use Hb_Common;
   use Inc_L10n;
   use Php;

--   procedure Print_Them (Name  : Utf8_String;
--                         Value : Json_Value);
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
                        return Json_Value -- Array_Type
   is
      use Inc_Formatting;
      use Inc_Options;

      Version_2 : Unbounded_String := +Version;
      Locale_2  : Unbounded_String := +Locale;
      Results   : Array_Type;
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
            Url : Unbounded_String :=
               +"http://api.wordpress.org/core/credits/1.1/?version=" &
               (-Version_2) & "&locale=" & (-Locale_2) & """";

            Options : Array_Type :=
               Arrays.To_Array ((1 => Build ("user-agent", "WordPress/" &
                          (-Version_2) & "; " & Inc_Link_Templates.Home_Url ("/"))));

            Response : Array_Type; -- Unbounded_String;
            Json     : Json_Value;
         begin
--            if Wp_Http_Supports (To_Array ("ssl")) then
--               url := Set_Url_Scheme (Url, "https");
--            end if;

            Response := Inc_Http.Wp_Remote_Get (-Url, Options);

--            if
--              Is_Wp_Error (Response) or else
--              200 /= Wp_Remote_Retrieve_Response_Code (Response)
--            then
--               return False;
--            end if;

             -- Added for dev jq
             Json := Read (Get_File ("dev.json"));

--            Json := Json_Decode (Wp_Remote_Retrieve_Body (Response), True);
--          Results := Json_Decode (Wp_Remote_Retrieve_Body (Response), True);
--            if not Is_Array (Results) then
--               return false;
--            end if;

--            Set_Site_Transient ("wordpress_credits_" & Locale_2,
--                                Results, DAY_IN_SECONDS);
            return Json;
         end;
      end if;

      return Json_Null; -- Results;
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
      use Inc_Formatting;
   begin
      Display_Name := "<a href=""" & Esc_Url (Sprintf (Profiles, Username)) &
                      """>" & Esc_Html (Display_Name) & "</a>";
   end X_Wp_Credits_Add_Profile_Link;

   --
   -- Retrieve the link to an external library used in WordPress.
   --
   -- @access private
   -- @since 3.2.0
   --
   -- @param string data External library data (passed by reference).
   --
   function X_Wp_Credits_Build_Object_Link (Data : Json_Array) -- in out String)
                                            return String
--   procedure X_Wp_Credits_Build_Object_Link (Data : in out String)
   is
      use Inc_Formatting;

      Url  : constant String := Get (Data, 2).Get; -- Data (1);
      Name : constant String := Get (Data, 1).Get; -- Data (0);
      Href : constant String := Esc_Url (Url);
      Link : constant String := Esc_Html (Name);
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
   procedure Wp_Credits_Section_Title (Group_Data : Json_Value)
   is
      use Inc_Formatting;
   begin
--      if 0 = Count (Group_Data) then
--         return;
--      end if;

      declare
         Name         : constant Json_Value := Get (Group_Data, "name");
         Placeholders : constant Json_Value := Get (Group_Data, "placeholders");
      begin
          if Name.Kind = Json_String_Type then
            if "Translators" = String'(Name.Get) then
               -- Considered a special slug in the API response. (Also, will never be
               -- returned for en_US.)
               Globals.Title := +X_X ("Translators",
                                      "Translate this to be the equivalent of English Translators in your language for the credits page Translators section");
            elsif Placeholders.Kind = Json_Array_Type then  -- Isset
               -- phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
               Globals.Title := +Vsprintf (Translate (Name.Get), Arrays.Empty_Array); -- Placeholders.Get);
            else
               -- phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
               Globals.Title := +Translate (Name.Get);
            end if;

            Echo ("<h2 class=""wp-people-group-title"">" & Esc_Html (-Globals.Title) &
                  "</h2>" & Nl);
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
   procedure Wp_Credits_Section_List (Credits : Json_Value;
                                      -- Array_Type := Empty_Array;
                                      Slug    : String     := "")
   is
   begin
   declare
      use Gnatcoll.Json;
      use Inc_Formatting;

      Group : Json_Value := Get (Credits, "groups");
      Slugs : Json_Value := Get (Group,   Slug);

      Group_Data   : Json_Value := Slugs;
      Credits_Data : Json_Value := Get (Slugs, "data");
      -- Group_Data : Array_type := (if Isset (Credits ("groups") (Slug))
      --                             then Credits ("groups") (Slug) else Empty_Array);
      -- Credits_Data : String := Credits ("data");
      Typ  : Json_Value := Get (Slugs, "type");
   begin
--      if 0 = Count (Group_Data) then
--         return;
--      end if;

--      if not Empty (Group_Data ("shuffle")) then
--         Shuffle (Group_Data ("data")); -- We were going to sort by ability to pronounce "hierarchical," but that wouldn"t be fair to Matt.
--      end if;

      if "list" = String'(Typ.Get) then
         declare
            Data : Json_Value := Get (Group_Data, "data");
         begin
--         Array_Walk (Group_Data ("data"), "_wp_credits_add_profile_link", Credits_Data ("profiles"));
--         echo ("<p class=""wp-credits-list"">" & Wp_Sprintf ("%l.", Data) &
--               "</p>\n\n");
--         echo ("<p class=""wp-credits-list"">" & Wp_Sprintf ("%l.", Group_Data ("data")) & "</p>\n\n");
            null;
         end;
      elsif "libraries" = String'(Typ.Get) then
         declare
            Data : Json_Array := Get (Group_Data, "data");
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
            Compact : Boolean := "compact" = String'(Get (Group_Data, "type").Get);
            Classes : String  := "wp-people-group " & (if compact then "compact" else "");

            procedure Print_Them (Name  : Utf8_String;
                                  Value : Json_Value)
            is
               Person_Data : Json_Array := Get (Value);
            begin
               Echo ("<li class=""wp-person"" id=""wp-person-" &
                     Esc_Attr (Get (Person_Data, 3).Get) & """>" & Nl_Tab); -- (2)
               Echo ("<a href=""" &
                     Esc_Url (Sprintf ("%s", -- Get (Credits_Data, "profiles").Get,
                                       Get (Person_Data, 2).Get)) &
                     """ class=""web"">");
               declare
                  use Inc_Link_Templates;

                  Size   : constant Integer := (if Compact then 80 else 160);
                  Data   : Array_Type := Get_Avatar_Data (Get (Person_Data, 2).Get & "@md5.gravatar.com", Arrays.To_Array ((1 => Build ("size", Size))));     -- (1)
                  Data2x : Array_Type := Get_Avatar_Data (Get (Person_Data, 2).Get & "@md5.gravatar.com", Arrays.To_Array ((1 => Build ("size", Size * 2)))); -- (1)
               begin
                  Echo ("<span class=""wp-person-avatar""><img src=""" &
                        Esc_Url (Get (Data,   "url")) & """ srcset=""" &
                        Esc_Url (Get (Data2x, "url")) &
                        " 2x"" class=""gravatar"" alt="""" /></span>" & Nl);
                  Echo (Esc_Html (Get (Person_Data, 1).Get) & "</a>" & Nl_Tab); -- (0)
               end;

               if not Compact and then String'(Get (Person_Data, 4).Get) /= "" then
                  -- phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
                  Echo ("<span class=""title"">" & Translate (Get (Person_Data, 4).Get) & "</span>" & Nl); -- (3)
               end if;
               echo ("</li>" & Nl);

            end Print_Them;

         begin
            Echo ("<ul class=""" & Classes & """ id=""wp-people-group-" & Slug & """>" & Nl);

            Map_Json_Object (Get (Group_Data, "data"), Cb => Print_Them'Access);

--             for Person_Data of Get (Group_Data, "data") loop
-- --               Echo ("<li class=""wp-person"" id=""wp-person-" &
-- --                     Esc_Attr (String'(Get (Person_Data, 3))) & """>" & "\n\t"); -- (2)
-- --               Echo ("<a href=""" & Esc_Url (Sprintf (Credits_Data ("profiles"), Person_Data (2))) & """ class=""web"">");

--                declare
--                   use Inc_Link_Templates;

--                   Size   : constant Integer := (if Compact then 80 else 160);
--                   Data   : Array_Type; -- := Get_Avatar_Data (Person_Data (1) & "@md5.gravatar.com", To_Array ((1 => Build ("size", Size))));
--                   Data2x : Array_Type; -- := Get_Avatar_Data (Person_Data (1) & "@md5.gravatar.com", To_Array ((1 => Build ("size", Size * 2))));
--                begin
--                   Echo ("<span class=""wp-person-avatar""><img src=""" &
--                         Esc_Url (Get (Data,   "url")) & """ srcset=""" &
--                         Esc_Url (Get (Data2x, "url")) &
--                         " 2x"" class=""gravatar"" alt="""" /></span>" & "\n");
-- --                  Echo (Esc_Html (Person_Data (0)) & "</a>\n\t");
--                end;

-- --               if not Compact and then not Empty (Person_Data (3)) then
-- --                  -- phpcs:ignore WordPress.WP.I18n.LowLevelTranslationFunction,WordPress.WP.I18n.NonSingularStringLiteralText
-- --                  Echo ("<span class=""title"">" & Translate (Person_Data (3)) & "</span>\n");
-- --               end if;
--                echo ("</li>\n");
--             end loop;
         end;
         echo ("</ul>" & Nl);

      end if;
      end;
   end Wp_Credits_Section_List;

   --------------
   -- Get_File --
   --------------

   function Get_File (Filename : String)
                      return Unbounded_String
   is
      use Ada.Text_Io;

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
