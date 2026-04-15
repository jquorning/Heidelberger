--
-- WordPress Credits Administration API.
--
-- @package WordPress
-- @subpackage Administration
-- @since 4.4.0
--

with Php.Arrays;
with Php.Echoing;
with Php.JSON;
with Php.Strings;

with Array_Lists;
-- with Constants;
with Globals;

with Inc_Formatting;
with Inc_HTTP;
with Inc_Options;
with Inc_L10n;
with Inc_Link_Templates;
with Inc_Versions;

package body Adi_Credits
is

   procedure Wp_Credits_Build_Object_Link_Wrap
     (Arry  : in out Array_Type;
      Key   : String;
      Value : Multi_Type;
      Arg   : Multi_Type);

   procedure Wp_Credits_Add_Profile_Link_Wrap
     (Arry  : in out Array_Type;
      Key   : String;
      Value : Multi_Type;
      Arg   : Multi_Type);

   ----------------
   -- Wp_Credits --
   ----------------

   function Wp_Credits
     (Version : String := "";
      Locale  : String := "") return Credits_Type
   is
      use Php.JSON;
      use Php.Strings;
      use Array_Lists;
      use Inc_HTTP;
      use Inc_Link_Templates;
      use Inc_L10n;
      use Inc_Options;

      Version_2 : constant String :=
        (if Version = "" then Inc_Versions.Wp_Version else Version);

      Locale_2 : constant String :=
        (if Locale = "" then Get_User_Locale else Locale);

      Results : constant Multi_Type :=
        Get_Site_Transient ("wordpress_credits_" & Locale_2);
   begin
      if not Is_Array (Results)
        or else Str_Contains (Version, "-")
        or else (Isset_2 (As_Array (Results), "data", "version")
                 and then not Str_Starts_With
                                (Version_2,
                                 As_String
                                   (Get
                                      (Ref_2
                                         (As_Array (Results),
                                          "data",
                                          "version")))))
      then
         declare
            URL_2 : constant String :=
              "http://api.wordpress.org/core/credits/1.1/?version="
              & Version_2
              & "&locale="
              & Locale_2;

            Options : constant Array_Type :=
              To_Array_Type
                ([Build
                    ("user-agent",
                     "WordPress/" & Version_2 & "; " & Home_URL ("/"))]);

            URL : constant String :=
              (if Wp_HTTP_Supports (To_Array_Type ([Build ("ssl", "")]))
               then Set_URL_Scheme (URL_2, "https")
               else URL_2);

            Response : constant Array_Type := Wp_Remote_Get (URL, Options);
         begin
            if 200 /= Wp_Remote_Retrieve_Response_Code (Response) then
               return From_Null;
            end if;

            declare
               JSON : constant Multi_Type :=
                 JSON_Decode (Wp_Remote_Retrieve_Body (Response));
            begin
               -- Set_Site_Transient
               --   ("wordpress_credits_" & Locale_2,
               --    Array_List'[1 => As_Array (Results)],
               --    Constants.DAY_IN_SECONDS);

               return JSON;
            end;
         end;
      end if;

      return From_Null;
   end Wp_Credits;

   -----------------------------------
   -- X_Wp_Credits_Add_Profile_Link --
   -----------------------------------

   procedure X_Wp_Credits_Add_Profile_Link
     (Display_Name : in out UStrings.UString;
      Username     : String;
      Profiles     : String)
   is
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;
   begin
      Display_Name :=
        +"<a href="""
        & ESC_URL (Sprintf (Profiles, [1 => Username]))
        & """>"
        & ESC_HTML (-Display_Name)
        & "</a>";
   end X_Wp_Credits_Add_Profile_Link;

   --------------------------------------
   -- Wp_Credits_Add_Profile_Link_Wrap --
   --------------------------------------

   procedure Wp_Credits_Add_Profile_Link_Wrap
     (Arry  : in out Array_Type;
      Key   : String;
      Value : Multi_Type;
      Arg   : Multi_Type)
   is
      use UStrings;

      Display_Name : UString := +As_String (Value);
   begin
      X_Wp_Credits_Add_Profile_Link
        (Display_Name => Display_Name,
         Username     => Key,
         Profiles     => As_String (Arg));

      Replace (Arry, Key, From_String (-Display_Name));
   end Wp_Credits_Add_Profile_Link_Wrap;

   ---------------------------------------
   -- Wp_Credits_Build_Object_Link_Wrap --
   ---------------------------------------

   procedure Wp_Credits_Build_Object_Link_Wrap
     (Arry  : in out Array_Type;
      Key   : String;
      Value : Multi_Type;
      Arg   : Multi_Type)
   is
      pragma Unreferenced (Arg);
   begin
      Replace
        (Arry,
         Key,
         From_String (X_Wp_Credits_Build_Object_Link (Data => Value)));
   end Wp_Credits_Build_Object_Link_Wrap;

   ------------------------------------
   -- X_Wp_Credits_Build_Object_Link --
   ------------------------------------

   function X_Wp_Credits_Build_Object_Link (Data : Multi_Type)
                                            return String
   is
      use Inc_Formatting;

      URL  : constant String := Get_As_String (As_Array (Data), "2");
      Name : constant String := Get_As_String (As_Array (Data), "1");
      Href : constant String := ESC_URL (URL);
      Link : constant String := ESC_HTML (Name);
   begin
      return "<a href=""" & Href & """>" & Link & "</a>";
   end X_Wp_Credits_Build_Object_Link;

   ------------------------------
   -- Wp_Credits_Section_Title --
   ------------------------------

   procedure Wp_Credits_Section_Title (Group_Data : Group_Data_Type)
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;
      use Inc_L10n;
   begin
      if Length (Group_Data) = 0 then
         return;
      end if;

      declare
         Name : constant Multi_Type := Get (Group_Data, "name");

         Placeholders : constant Multi_Type :=
           Get (Group_Data, "placeholders");
      begin
         if not Is_Null (Name) then
            if "Translators" = As_String (Name) then
               -- Considered a special slug in the API response. (Also,
               -- will never be returned for en_US.)
               Globals.Global_Title :=
                 +X_X ("Translators",
                       "Translate this to be the equivalent of English Translators in your language for the credits page Translators section");

            elsif Is_Array (Placeholders) then
               Globals.Global_Title :=
                 +Vsprintf
                    (Translate (As_String (Name)),
                     [1 => As_String (Get (As_Array (Placeholders), "1"))]);
            else
               Globals.Global_Title := +Translate (As_String (Name));
            end if;

            Echo ("<h2 class=""wp-people-group-title"">" &
                  ESC_HTML (-Globals.Global_Title) & "</h2>" & NL);
         end if;
      end;
   end Wp_Credits_Section_Title;

   -----------------------------
   -- Wp_Credits_Section_List --
   -----------------------------

   procedure Wp_Credits_Section_List
     (Credits : Group_Data_Type; Slug : String := "")
   is
      use Php.Arrays;
      use Php.Echoing;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_L10n;

      Groups : constant Array_Type := As_Array (Get (Credits, "groups"));

      Group_Data : Array_Type :=
        (if Isset (Groups, Slug)
         then As_Array (Get (Groups, Slug))
         else Arrays.Empty_Array);

      Credits_Data : constant Array_Type := As_Array (Get (Credits, "data"));
   begin
      if Length (Group_Data) = 0 then
         return;
      end if;

      -- Shuffle

      declare
--         Group_Data : Array_Type := As_Array (Get (Group, Slug));
         Typ        : constant String := As_String (Get (Group_Data, "type"));
      begin
         if Typ = "list" then
            declare
               Group_Data_Data : Array_Type :=
                 As_Array (Get (Group_Data, "data"));

               Profiles : constant String :=
                 Get_As_String (Credits_Data, "profiles");
            begin
               Array_Walk
                 (Group_Data_Data,
                  Wp_Credits_Add_Profile_Link_Wrap'Access,
                  From_String (Profiles));
               -- echo '<p class="wp-credits-list">' . wp_sprintf( '%l.', $group_data['data'] ) . "</p>\n\n";

               -- Echo
               --   ("<p class=""wp-credits-list"">"
               --    & Wp_Sprintf ("%l.", [1 => Get_As_String (Data, "data")])
               --    & ".</p>"
               --    & NL
               --    & NL);

               Echo ("<p class=""wp-credits-list"">");
               -- Loop added
               for A in Group_Data_Data.Iterate loop
                  Echo (Sprintf ("%s, ", [1 => As_String (Element (A))]));
               end loop;
               Echo (".</p>" & NL & NL);
            end;

         elsif Typ = "libraries" then
            declare
               Data : Array_Type := As_Array (Get (Group_Data, "data"));
            begin
               Array_Walk (Data, Wp_Credits_Build_Object_Link_Wrap'Access);
               -- echo '<p class="wp-credits-list">' . wp_sprintf( '%l.', $group_data['data'] ) . "</p>\n\n";

               -- Echo
               --   ("<p class=""wp-credits-list"">"
               --    -- & Sprintf ("%s, ", [1 => As_String (Element (A))])
               --    & Wp_Sprintf ("%l.", [1 => Get_As_String (Data, "data")])
               --    & ".</p>"
               --    & NL
               --    & NL);

               Echo ("<p class=""wp-credits-list"">");
               -- Loop added
               for A in Data.Iterate loop
                  Echo (Sprintf ("%s, ", [1 => As_String (Element (A))]));
               end loop;
               Echo (".</p>");
            end;

         else
            -- compact or default: avatar grid
            declare
               Compact : constant Boolean := False; -- Typ = "compact";

               Classes : constant String :=
                 "wp-people-group " & (if Compact then "compact" else "");

               Profiles : constant String :=
                 Get_As_String (Credits_Data, "profiles");
            begin
               Echo
                 ("<ul class="""
                  & Classes
                  & """ id=""wp-people-group-"
                  & Slug
                  & """>"
                  & NL);

               for P in As_Array (Get (Group_Data, "data")).Iterate
               loop
                  declare
                     Person_Data : constant Array_Type :=
                       As_Array (Element (P));
                  begin
                     Echo
                       ("<li class=""wp-person"" id=""wp-person-"
                        & ESC_Attr (Get_As_String (Person_Data, "3"))
                        & """>"
                        & NL_TAB);
                     Echo
                       ("<a href="""
                        & ESC_URL
                            (Sprintf
                               (Profiles, [Get_As_String (Person_Data, "3")]))
                        & """ class=""web"">");
                     declare
                        Size : constant Integer :=
                          (if Compact then 80 else 160);

                        Data : constant Array_Type :=
                          Get_Avatar_Data
                            (Get_As_String (Person_Data, "2")
                             & "@md5.gravatar.com",
                             To_Array_Type ([Build ("size", Size)]));

                        Data2x : constant Array_Type :=
                          Get_Avatar_Data
                            (Get_As_String (Person_Data, "2")
                             & "@md5.gravatar.com",
                             To_Array_Type ([Build ("size", Size * 2)]));
                     begin
                        Echo
                          ("<span class=""wp-person-avatar""><img src="""
                           & ESC_URL (Get_As_String (Data, "url"))
                           & """ srcset="""
                           & ESC_URL (Get_As_String (Data2x, "url"))
                           & " 2x"" class=""gravatar"" alt="""" /></span>"
                           & NL);
                        Echo
                          (ESC_HTML (Get_As_String (Person_Data, "1"))
                           & "</a>"
                           & NL_TAB);
                     end;

                     if not Compact
                       and then Get_As_String (Person_Data, "4") /= ""
                     then
                        Echo
                          ("<span class=""title"">"
                           & Translate (Get_As_String (Person_Data, "4"))
                           & "</span>"
                           & NL);
                     end if;
                  end;
                  Echo ("</li>" & NL);
               end loop;
               Echo ("</ul>" & NL);
            end;
         end if;
      end;
   end Wp_Credits_Section_List;

end Adi_Credits;
