--
-- WP_Theme Class
--
-- @package WordPress
-- @subpackage Theme
-- @since 3.4.0

with Php.Arrays;
with Php.Files;
with Php.HTML;
with Php.Lists;
with Php.Misc;
with Php.Strings;
with Php.Types;

with Helpers;
with Lists;
with Logging;
with Wp_Common;

with Adi_Themes;

with Inc_Caches;
with Inc_Error_Protection;
with Inc_Functions;
with Inc_Formatting;
with Inc_KSES;
with Inc_L10n;
with Inc_Load;
with Inc_Ms_Blogs;
with Inc_Options;
with Inc_Themes;

package body Class_Themes
is
   use Lists;

   Wp_Theme_Directories : Array_Type;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
     (Theme_Dir  : String;
      Theme_Root : String;
      X_Child    : in out Wp_Theme) -- _Access := null)
      return Wp_Theme
   is
      use Php.Arrays;
      use Php.Files;
      use Php.Misc;
      use Php.Strings;
      use Php.Types;
      use Array_Lists;
      use UStrings;
      use Wp_Common;
      use Inc_Caches;
      use Class_Errors;
      use Inc_Error_Protection;
      use Inc_Functions;
      use Inc_Formatting;
      use Inc_L10n;
      use Inc_Load;
      use Inc_Themes;

      This                : Wp_Theme;
      Cache               : Array_Type;
      Theme_File          : UString;
      Theme_Root_Template : UString;
   begin
      -- Initialize caching on first run.
      if not Static_Persistently_Cache then
         --    if not Isset (Static_Persistently_Cache) then
         -- This action is documented in wp-includes/theme.php
         Static_Persistently_Cache := -- self::
           Apply_Filters ("wp_cache_themes_persistently", False, "WP_Theme");

         if Static_Persistently_Cache then
            Wp_Cache_Add_Global_Groups ("themes");
         -- if Is_Int (Static_Persistently_Cache) then
         --    Static_Cache_Expiration := Static_Persistently_Cache;
         -- end if;

         else
            Wp_Cache_Add_Non_Persistent_Groups ("themes");
         end if;
      end if;

      This.Theme_Root := +Theme_Root;
      This.Stylesheet := +Theme_Dir;

      -- Correct a situation where the theme is 'some-directory/some-theme' but
      -- 'some-directory' was passed in as part of the theme root instead.
      if not In_Array (Theme_Root, Wp_Theme_Directories, True)
        and then -- (array)
        In_Array (Dirname (Theme_Root), Wp_Theme_Directories, True) -- (array)
      then
         This.Stylesheet :=
           Basename (-This.Theme_Root) & "/" & This.Stylesheet;
         This.Theme_Root := +Dirname (Theme_Root);
      end if;

      This.Cache_Hash := +MD5 (-(This.Theme_Root & "/" & This.Stylesheet));
      Theme_File := This.Stylesheet & "/style.css";

      Cache := As_Array (This.Cache_Get ("theme"));

      if Is_Array (Cache) then
         for Key of List_Type'["errors", "headers", "template"] loop
            if Isset (Cache, Key) then
               --             Append (Ref (This, -Key), Ref (Cache, -Key)); -- []
               null;
            end if;
         end loop;

         if This.Errors /= Null_Wp_Error then
            return Null_Theme;
         end if;

         if Isset (Cache, "theme_root_template") then
            Theme_Root_Template :=
              +Get_As_String (Cache, "theme_root_template");
         end if;

      elsif not File_Exists (-(This.Theme_Root & "/" & Theme_File)) then

         Set (This.Headers, "Name", From_String (-This.Stylesheet));

         if not File_Exists (-(This.Theme_Root & "/" & This.Stylesheet)) then
            This.M_Errors :=
              Wp_Error'
                (X_Construct
                   ("theme_not_found",
                    Sprintf
                      (
                       -- translators: %s: Theme directory name.
                       abs "The theme directory ""%s"" does not exist.",
                       [1 => ESC_HTML (-This.Stylesheet)])));
         else
            This.M_Errors :=
              Wp_Error'
                (X_Construct
                   ("theme_no_stylesheet", "Stylesheet is missing."));
         end if;

         This.Template := This.Stylesheet;
         This.Cache_Add
           ("theme",
            To_Array_Type
              ([Build ("headers", This.Headers),
                --           Build ("errors",     This.Errors),
                Build ("stylesheet", -This.Stylesheet),
                Build ("template", -This.Template)]));

         if not File_Exists (-This.Theme_Root) then
            -- Don't cache this one.
            This.M_Errors.Add
              ("theme_root_missing",
               abs "<strong>Error:</strong> The themes directory is either empty or does not exist. Please check your installation.");
         end if;
         return Null_Theme;

      elsif not Is_Readable (-(This.Theme_Root & "/" & Theme_File)) then

         Set (This.Headers, "Name", From_String (-This.Stylesheet));

         This.M_Errors :=
           Wp_Error'
             (X_Construct
                ("theme_stylesheet_not_readable",
                 abs "Stylesheet is not readable."));
         This.Template := This.Stylesheet;
         This.Cache_Add
           ("theme",
            To_Array_Type
              ([Build ("headers", This.Headers),
                --           Build ("errors",     -This.Errors),
                Build ("stylesheet", -This.Stylesheet),
                Build ("template", -This.Template)]));
         return Null_Theme;

      else
         This.Headers :=
           Get_File_Data
             (-(This.Theme_Root & "/" & Theme_File),
              Static_File_Headers,
              "theme");
         declare
            -- Default themes always trump their pretenders.
            -- Properly identify default themes that are inside a directory within
            -- wp-content/themes.
            Default_Theme_Slug : constant String :=
              Array_Search
                (Get_As_String (This.Headers, "Name"),
                 Static_Default_Themes,
                 True);
         begin
            if Default_Theme_Slug /= "" then
               if Basename (-This.Stylesheet) /= Default_Theme_Slug then
                  Set
                    (This.Headers,
                     "Name",
                     Value => From_String ("/" & (-This.Stylesheet)));
               end if;
            end if;
         end;
      end if;

      if
      --      This.Template = "" and then
      --      not This.Template and then
                                           This
                                           .Template
        = "(no-template)"
        and then This.Stylesheet = +Get_As_String (This.Headers, "Template")
      then
         This.M_Errors :=
           Wp_Error'
             (X_Construct
                ("theme_child_invalid",
                 Sprintf
                   (
                    -- translators: %s: Template.
                    abs "The theme defines itself as its parent theme. Please check the %s header.",
                    [1 => "<code>Template</code>"])));
         This.Cache_Add
           ("theme",
            To_Array_Type
              ([Build ("headers", This.Headers),
                --           Build ("errors",     -This.Errors),
                Build ("stylesheet", -This.Stylesheet)]));
         return Null_Theme;

      end if;

      -- (If template is set from cache [and there are no errors], we know it's good.)
      if This.Template = "" then
         This.Template := +Get_As_String (This.Headers, "Template");
      end if;

      if This.Template = "" then
         This.Template := This.Stylesheet;
         declare
            Theme_Path : constant String :=
              -(This.Theme_Root & "/" & This.Stylesheet);
         begin
            if not File_Exists (Theme_Path & "/templates/index.html")
              and then not File_Exists
                             (Theme_Path & "/block-templates/index.html")
              -- Deprecated path support since 5.9.0.
              and then not File_Exists (Theme_Path & "/index.Php")
            then
               declare
                  Error_Message : constant String :=
                    Sprintf
                      (
                       -- translators: 1: templates/index.html, 2: index.php, 3: Documentation URL, 4: Template, 5: style.css
                       abs "Template is missing. Standalone themes need to have a %1s or %2s template file. <a href=""%3s"">Child themes</a> need to have a %4s header in the %5s stylesheet.",
                       [1 => "<code>templates/index.html</code>",
                        2 => "<code>index.php</code>",
                        3 =>
                          abs "https://developer.wordpress.org/themes/advanced-topics/child-themes/",
                        4 => "<code>Template</code>",
                        5 => "<code>style.css</code>"]);
               begin
                  This.M_Errors :=
                    Wp_Error'(X_Construct ("theme_no_index", Error_Message));
               end;
               This.Cache_Add
                 ("theme",
                  To_Array_Type
                    ([Build ("headers", This.Headers),
                      --                 Build ("errors",     -This.Errors),
                      Build ("stylesheet", -This.Stylesheet),
                      Build ("template", -This.Template)]));
               return Null_Theme;
            end if;
         end;
      end if;

      -- If we got our data from cache, we can assume that 'template' is pointing to
      -- the right place.
      if not Is_Array (Cache)
        and then This.Template /= This.Stylesheet
        and then not File_Exists
                       (-(This.Theme_Root
                          & "/"
                          & This.Template
                          & "/index.php"))
      then
         declare
            -- If we're in a directory of themes inside /themes, look for the parent
            -- nearby. wp-content/themes/directory-of-themes/*
            Parent_Dir  : constant String := Dirname (-This.Stylesheet);
            Directories : constant Array_Type := Search_Theme_Directories;
         begin
            if "." /= Parent_Dir
              and then File_Exists
                         (-(This.Theme_Root
                            & "/"
                            & Parent_Dir
                            & "/"
                            & This.Template
                            & "/index.php"))
            then
               This.Template := Parent_Dir & "/" & This.Template;
            elsif not Directories.Is_Empty
              and then Isset (Get_As_String (Directories, -This.Template))
            then
               -- Look for the template in the search_theme_directories() results, in
               -- case it is in another theme root.
               -- We don't look into directories of themes, just the theme root.
               Theme_Root_Template :=
                 +As_String
                    (Get
                       (As_Array (Get (Directories, -This.Template)),
                        "theme_root"));
            --             Theme_Root_Template := Directories (-This.Template) ("theme_root");
            else
               -- Parent theme is missing.
               This.M_Errors :=
                 Wp_Error'
                   (X_Construct
                      ("theme_no_parent",
                       Sprintf
                         (
                          -- translators: %s: Theme directory name.
                          abs "The parent theme is missing. Please install the ""%s"" parent theme.",
                          [1 => ESC_HTML (-This.Template)])));
               This.Cache_Add
                 ("theme",
                  To_Array_Type
                    ([Build ("headers", This.Headers),
                      --                 Build ("errors",     -This.Errors),
                      Build ("stylesheet", -This.Stylesheet),
                      Build ("template", -This.Template)]));
               This.M_Parent :=
                 new Wp_Theme'
                   (X_Construct (-This.Template, -This.Theme_Root, This));
               return Null_Theme;
            end if;
         end;
      end if;

      -- Set the parent, if we're a child theme.
      if This.Template /= This.Stylesheet then
         -- If we are a parent, then there is a problem. Only two generations
         -- allowed! Cancel things out.
         if X_Child in Wp_Theme
           and then      -- instaceof
           X_Child.Template = This.Stylesheet
         then
            X_Child.M_Parent := null;
            X_Child.M_Errors :=
              Wp_Error'
                (X_Construct
                   ("theme_parent_invalid",
                    Sprintf
                      (
                       -- translators: %s: Theme directory name.
                       abs "The ""%s"" theme is not a valid parent theme.",
                       [1 => ESC_HTML (-X_Child.Template)])));
            X_Child.Cache_Add
              ("theme",
               To_Array_Type
                 ([Build ("headers", X_Child.Headers),
                   --              Build ("errors",     X_Child.Errors),
                   Build ("stylesheet", -X_Child.Stylesheet),
                   Build ("template", -X_Child.Template)]));
            -- The two themes actually reference each other with the Template header.
            if X_Child.Stylesheet = This.Template then
               This.M_Errors :=
                 Wp_Error'
                   (X_Construct
                      ("theme_parent_invalid",
                       Sprintf
                         (
                          -- translators: %s: Theme directory name.--
                          abs "The ""%s"" theme is not a valid parent theme.",
                          [1 => ESC_HTML (-This.Template)])));
               This.Cache_Add
                 ("theme",
                  To_Array_Type
                    ([Build ("headers", This.Headers),
                      --                 Build ("errors",     -This.Errors),
                      Build ("stylesheet", -This.Stylesheet),
                      Build ("template", -This.Template)]));
            end if;
            return Null_Theme;
         end if;

         -- Set the parent. Pass the current instance so we can do the crazy checks
         -- above and assess errors.
         This.M_Parent :=
           new Wp_Theme'
             (X_Construct
                (-This.Template,
                 (if Theme_Root_Template /= ""
                  -- (if Isset (Theme_Root_Template)
                  then -Theme_Root_Template
                  else -This.Theme_Root),
                 This));
      end if;

      if Wp_Paused_Themes.Get (-This.Stylesheet) /= Empty_Array
        and then (not Is_Wp_Error (This.Errors)
                  or else not Isset (This.Errors.Errors, "theme_paused"))
      then
         This.M_Errors :=
           Wp_Error'
             (X_Construct
                ("theme_paused",
                 abs "This theme failed to load properly and was paused within the admin backend."));
      end if;

      -- We're good. If we didn't retrieve from cache, set it.
      if not Is_Array (Cache) then
         Cache :=
           To_Array_Type
             ([Build ("headers", This.Headers),
               --         Build ("errors",     -This.Errors),
               Build ("stylesheet", -This.Stylesheet),
               Build ("template", -This.Template)]);
         -- If the parent theme is in another root, we'll want to cache this. Avoids
         -- an entire branch of filesystem calls above.
         if Theme_Root_Template /= "" then
            --       if Isset (Theme_Root_Template) then
            Set
              (Cache,
               "theme_root_template",
               From_String (-Theme_Root_Template));
         end if;
         This.Cache_Add ("theme", Cache);
      end if;

      return This;
   end X_Construct;

   ------------
   -- Errors --
   ------------

   function Errors (This : Wp_Theme) return Class_Errors.Wp_Error is
   begin
      return This.M_Errors;
   --    return (if Is_Wp_Error (This.Errors) then This.Errors else False);
   end Errors;

   ------------
   -- Exists --
   ------------

   function Exists (This : Wp_Theme) return Boolean is
      use Php.Lists;
      use Class_Errors;
   begin
      return
        not (This.Errors /= Null_Wp_Error
             and then In_List
                        ("theme_not_found",
                         This.Errors.Get_Error_Codes,
                         True));
   end Exists;

   ------------
   -- Parent --
   ------------

   function Parent (This : Wp_Theme) return Wp_Theme is
   begin
      return (if This.M_Parent /= null then This.M_Parent.all else Null_Theme);
   --    return (if Isset (This.M_Parent) then This.Parent else False);
   end Parent;

   ---------------
   -- Cache_Add --
   ---------------

   function Cache_Add
     (This : Wp_Theme; Key : String; Data : Array_Type) return Boolean
   is
      use UStrings;
      use Inc_Caches;

      Result : Boolean;
   begin
      Wp_Cache_Add
        (Key & "-" & (-This.Cache_Hash),
         From_Array (Data),
         "themes",
         Static_Cache_Expiration,
         Success => Result);
      return Result;
   end Cache_Add;

   ---------------
   -- Cache_Add --
   ---------------

   procedure Cache_Add (This : Wp_Theme; Key : String; Data : Array_Type) is
      Unused : Boolean;
   begin
      Unused := This.Cache_Add (Key, Data);
   end Cache_Add;

   ---------------
   -- Cache_Add --
   ---------------

   procedure Cache_Add (This : Wp_Theme; Key : String; Data : String) is
   begin
      raise Program_Error with "not implemented";
   end Cache_Add;

   ---------------
   -- Cache_Get --
   ---------------

   function Cache_Get (This : Wp_Theme; Key : String) return Multi_Type is
      use UStrings;
      use Inc_Caches;

      Found : Boolean;
   begin
      return
        From_Array (Wp_Cache_Get
          (Key & "-" & (-This.Cache_Hash), "themes", Found => Found));
   end Cache_Get;

   ---------
   -- Get --
   ---------

   function Get (This : in out Wp_Theme; Header : String) return Multi_Type is
      use Php.Arrays;
      use Php.Types;
   begin
      if not Isset (This.Headers, Header) then
         return From_Null; -- False;

      end if;

      if not Isset (This.Headers_Sanitized) then
         This.Headers_Sanitized := As_Array (This.Cache_Get ("headers"));
         if not Is_Array (This.Headers_Sanitized) then
            This.Headers_Sanitized := Empty_Array;
         end if;
      end if;

      if Isset (This.Headers_Sanitized, Header) then
         return Get (This.Headers_Sanitized, Header);
      end if;

      -- If themes are a persistent group, sanitize everything and cache it. One
      -- cache add is better than many cache sets.
      if Static_Persistently_Cache then
         -- self::
         for X_Header of List_Type'(Array_Keys (This.Headers)) loop
            Set
              (This.Headers_Sanitized,
               X_Header,
               From_String
                 (This.Sanitize_Header
                    (X_Header, Get_As_String (This.Headers, X_Header))));
         end loop;
         This.Cache_Add ("headers", This.Headers_Sanitized);
      else
         Set
           (This.Headers_Sanitized,
            Header,
            From_String
              (This.Sanitize_Header
                 (Header, Get_As_String (This.Headers, Header))));
      end if;

      return Get (This.Headers_Sanitized, Header);
   end Get;

   -------------
   -- Display --
   -------------

   function Display
     (This      : in out Wp_Theme;
      Header    : String;
      Markup    : Boolean := True;
      Translate : Boolean := True) return String
   is
      Value : constant String := As_String (This.Get (Header));
   begin
      if Value = "" then -- False
         return ""; -- False;
      end if;

      declare
         Translate_2 : constant Boolean :=
           (if Translate and then (Value = "" or else not This.Load_Textdomain)
            then False
            else Translate);

         Value_2 : String :=
           (if Translate_2
            then This.Translate_Header (Header, Value)
            else Value);

         Value_3 : constant String :=
           (if Markup
            then This.Markup_Header (Header, Value_2, Translate_2)
            else Value_2);
      begin
         return Value_3;
      end;
   end Display;

   ---------------------
   -- Sanitize_Header --
   ---------------------

   function Sanitize_Header
     (This : Wp_Theme; Header : String; Value : String) return String
   is
      use Php.Lists;
      use Php.Strings;
      use Array_Lists;
      use UStrings;
      use Inc_Formatting;
      use Inc_KSES;

      Value_2 : UString;
      Value_3 : List_Type;
   begin
      if Header in "Status" | "Name" then
         if Header = "Status" then
            if Value = "" then
               Value_2 := +"publish";
               goto Break;
            end if;
         end if;

         declare
            -- static
            Header_Tags : constant Array_Type :=
              To_Array_Type
                ([Build ("abbr", To_Array_Type ([Build ("title", True)])),
                  Build ("acronym", To_Array_Type ([Build ("title", True)])),
                  Build ("code", True),
                  Build ("em", True),
                  Build ("strong", True)]);
         begin
            Value_2 := +Wp_KSES (Value, Header_Tags);
         end;
         <<Break>>

      elsif Header in "Author" | "Description" then
         -- There shouldn't be anchor tags in Author, but some themes like to be
         -- challenging.
         declare
            -- static
            Header_Tags_With_A : constant Array_Type :=
              To_Array_Type
                ([Build
                    ("a",
                     To_Array_Type
                       ([Build ("href", True), Build ("title", True)])),
                  Build ("abbr", To_Array_Type ([Build ("title", True)])),
                  Build ("acronym", To_Array_Type ([Build ("title", True)])),
                  Build ("code", True),
                  Build ("em", True),
                  Build ("strong", True)]);
         begin
            Value_2 := +Wp_KSES (Value, Header_Tags_With_A);
         end;

      elsif Header in "ThemeURI" | "AuthorURI" then
         Value_2 := +Sanitize_URL (Value);

      elsif Header = "Tags" then
         Value_3 :=
           List_Filter
             (List_Map (Trim'Access, Explode (",", Strip_Tags (Value))));

      elsif Header in "Version" | "RequiresWP" | "RequiresPHP" | "UpdateURI"
      then
         Value_2 := +Strip_Tags (Value);

      end if;

      return -Value_2;
   end Sanitize_Header;

   -------------------
   -- Markup_Header --
   -------------------

   Static_Comma : UStrings.UString; -- null

   function Markup_Header
     (This      : in out Wp_Theme;
      Header    : String;
      Value     : String;
      Translate : Boolean) return String
   is
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;
      use Inc_L10n;

      Value_2 : UString := +Value;
   begin
      if Header = "Name" then
         if Value = "" then
            Value_2 := +ESC_HTML (This.Get_Stylesheet);
         end if;

      elsif Header = "Description" then
         Value_2 := +Wp_Texturize (Value);

      elsif Header = "Author" then
         if As_String (This.Get ("AuthorURI")) /= "" then
            Value_2 :=
              +Sprintf
                 ("<a href=""%1s"">%2s</a>",
                  [1 => This.Display ("AuthorURI", True, Translate),
                   2 => Value]);
         elsif Value = "" then
            Value_2 := +abs "Anonymous";
         end if;

      elsif Header = "Tags" then
         declare
            Comma : UString renames Static_Comma;
         begin
            if Comma = "" then
               Comma := +Wp_Get_List_Item_Separator;
            end if;
            Value_2 := +Implode (-Comma, Value);
         end;

      elsif Header in "ThemeURI" | "AuthorURI" then
         Value_2 := +ESC_URL (Value);
      end if;

      return -Value_2;
   end Markup_Header;

   ----------------------
   -- Translate_Header --
   ----------------------

   Static_Tags_List : Array_Type;

   function Translate_Header
     (This : in out Wp_Theme; Header : String; Value : String) return String
   is
      use Php.Misc;
      use Array_Lists;
      use UStrings;
      use Adi_Themes;
      use Inc_L10n;
   begin
      if Header = "Name" then
         -- Cached for sorting reasons.
         if This.Name_Translated = "" then
            return -This.Name_Translated;
         end if;

         This.Name_Translated := +Translate (Value, As_String (This.Get ("TextDomain")));

         return -This.Name_Translated;

      elsif Header = "Tags" then
         if Value = ""
           or else not Function_Exists ("get_theme_feature_list")
         then
            return Value;
         end if;

         declare
            Tags_List : Array_Type renames Static_Tags_List;
         begin
            if Tags_List.Is_Empty then
               Tags_List :=
                 To_Array_Type
                   ([
                     -- As of 4.6, deprecated tags which are only used to provide translation for older themes.
                     Build ("black", abs "Black"),
                     Build ("blue", abs "Blue"),
                     Build ("brown", abs "Brown"),
                     Build ("gray", abs "Gray"),
                     Build ("green", abs "Green"),
                     Build ("orange", abs "Orange"),
                     Build ("pink", abs "Pink"),
                     Build ("purple", abs "Purple"),
                     Build ("red", abs "Red"),
                     Build ("silver", abs "Silver"),
                     Build ("tan", abs "Tan"),
                     Build ("white", abs "White"),
                     Build ("yellow", abs "Yellow"),
                     Build ("dark", X_X ("Dark", "color scheme")),
                     Build ("light", X_X ("Light", "color scheme")),
                     Build ("fixed-layout", abs "Fixed Layout"),
                     Build ("fluid-layout", abs "Fluid Layout"),
                     Build ("responsive-layout", abs "Responsive Layout"),
                     Build ("blavatar", abs "Blavatar"),
                     Build ("photoblogging", abs "Photoblogging"),
                     Build ("seasonal", abs "Seasonal")]);

               declare
                  Feature_List : constant Array_Type :=
                    Get_Theme_Feature_List (False); -- No API.
               begin
                  for Tags in Feature_List.Iterate loop
                     -- tags_list += tags;
                     null;
                  end loop;
               end;

            end if;

            -- for Tag of Value loop
            --    -- &
            --    if Isset (Tags_List, Tag) then
            --       Tag := Get (Tags_List, Tag);
            --    elsif Isset (Tag_Map, Tag) then
            --       -- self::
            --       Tag := Get (Tags_List, Get_As_String (Tag_Map, Tag));
            --    end if;
            -- end loop;

         end;

         return Value;
      else
         return Translate (Value, As_String (This.Get ("TextDomain")));
         -- Value := Translate (Value, This.Get ("TextDomain"));
      end if;
      -- return Value;
   end Translate_Header;

   --------------------
   -- Get_Stylesheet --
   --------------------

   function Get_Stylesheet (This : Wp_Theme) return String is
      use UStrings;
   begin
      return -This.Stylesheet;
   end Get_Stylesheet;

   ------------------
   -- Get_Template --
   ------------------

   function Get_Template (This : Wp_Theme) return String is
      use UStrings;
   begin
      return -This.Template;
   end Get_Template;

   ------------------------------
   -- Get_Stylesheet_Directory --
   ------------------------------

   function Get_Stylesheet_Directory (This : Wp_Theme) return String is
      use Php.Lists;
      use UStrings;
      use Class_Errors;
   begin
      if This.Errors /= Null_Wp_Error
        and then In_List
                   ("theme_root_missing", This.Errors.Get_Error_Codes, True)
      then
         return "";
      end if;

      return -(This.Theme_Root & "/" & This.Stylesheet);
   end Get_Stylesheet_Directory;

   ----------------------------
   -- Get_Template_Directory --
   ----------------------------

   function Get_Template_Directory (This : Wp_Theme) return String is
      use UStrings;

      Theme_Root : constant String :=
        (if This.Parent /= Null_Theme
         then -This.Parent.Theme_Root
         else -This.Theme_Root);
   begin
      return -(Theme_Root & "/" & This.Template);
   end Get_Template_Directory;

   ----------------------------------
   -- Get_Stylesheet_Directory_URI --
   ----------------------------------

   function Get_Stylesheet_Directory_URI (This : in out Wp_Theme) return String
   is
      use Php.HTML;
      use Php.Strings;
      use UStrings;
   begin
      return
        This.Get_Theme_Root_URI
        & '/'
        & Str_Replace ("%2F", "/", Raw_URL_Encode (-This.Stylesheet));
   end Get_Stylesheet_Directory_URI;

   ------------------------
   -- Get_Theme_Root_URI --
   ------------------------

   function Get_Theme_Root_URI (This : in out Wp_Theme) return String is
      use UStrings;
      use Inc_Themes;
   begin
      if This.Theme_Root_URI = "" then
         -- not Isset (This.Theme_Root_URI) then
         This.Theme_Root_URI :=
           +Get_Theme_Root_URI (-This.Stylesheet, -This.Theme_Root);
      end if;
      return -This.Theme_Root_URI;
   end Get_Theme_Root_URI;

   --------------------
   -- Get_Screenshot --
   --------------------

   function Get_Screenshot
     (This : in out Wp_Theme; URI : String := "uri") return String
   is
      use Php.Files;

      Screenshot : constant String :=
        As_String (This.Cache_Get ("screenshot"));
   begin
      if Screenshot /= "" then
         if "relative" = URI then
            return Screenshot;
         end if;
         return This.Get_Stylesheet_Directory_URI & '/' & Screenshot;
      -- elsif 0 = Screenshot then
      --   return False;

      end if;

      for Ext of List_Type'["png", "gif", "jpg", "jpeg", "webp"] loop
         if File_Exists (This.Get_Stylesheet_Directory & "/screenshot." & Ext)
         then
            This.Cache_Add ("screenshot", "screenshot." & Ext);
            if "relative" = URI then
               return "screenshot." & Ext;
            end if;
            return
              This.Get_Stylesheet_Directory_URI & '/' & "screenshot." & Ext;
         end if;
      end loop;

      This.Cache_Add ("screenshot", "0"); -- was 0
      return ""; -- False;
   end Get_Screenshot;

   ---------------------
   -- Load_Textdomain --
   ---------------------

   function Load_Textdomain (This : in out Wp_Theme) return Boolean is
      use UStrings;
      use Inc_L10n;
   begin
      if This.Textdomain_Loaded then
         -- isset
         return This.Textdomain_Loaded;
      end if;

      declare
         Textdomain : constant String := As_String (This.Get ("TextDomain"));
      begin
         if Textdomain = "" then
            This.Textdomain_Loaded := False;
            return False;
         end if;

         if Is_Textdomain_Loaded (Textdomain) then
            This.Textdomain_Loaded := True;
            return True;
         end if;

         declare
            Path       : UString := +This.Get_Stylesheet_Directory;
            Domainpath : constant String := As_String (This.Get ("DomainPath"));
         begin
            if Domainpath /= "" then
               Append (Path, Domainpath);
            else
               Append (Path, "/languages");
            end if;

            This.Textdomain_Loaded :=
              Load_Theme_Textdomain (Textdomain, -Path);
            return This.Textdomain_Loaded;
         end;
      end;
   end Load_Textdomain;

   ----------------
   -- Is_Allowed --
   ----------------

   function Is_Allowed
     (This    : Wp_Theme;
      Check   : String := "both";
      Blog_Id : Integer := 0) -- null
      return Boolean
   is (raise Program_Error with "not implemented");
   --                 if ( ! is_multisite() ) then
   --                         return true;
   --                 end;

   --                 if ( 'both' === check || 'network' === check ) then
   --                         allowed = self::get_allowed_on_network();
   --                         if ( ! empty( allowed[ this->get_stylesheet() ] ) ) then
   --                                 return true;
   --                         end;
   --                 end;

   --                 if ( 'both' === check || 'site' === check ) then
   --                         allowed = self::get_allowed_on_site( blog_id );
   --                         if ( ! empty( allowed[ this->get_stylesheet() ] ) ) then
   --                                 return true;
   --                         end;
   --                 end;

   --                 return false;
   --         end;

   --------------------
   -- Is_Block_Theme --
   --------------------

   function Is_Block_Theme (This : Wp_Theme) return Boolean is
      use Php.Files;

      Paths_To_Index_Block_Template : List_Type :=
        [This.Get_File_Path ("/block-templates/index.html"),
         This.Get_File_Path ("/templates/index.html")];
   begin
      for Path_To_Index_Block_Template of Paths_To_Index_Block_Template loop
         if Is_File (Path_To_Index_Block_Template)
           and then Is_Readable (Path_To_Index_Block_Template)
         then
            return True;
         end if;
      end loop;

      return False;
   end Is_Block_Theme;

   -------------------
   -- Get_File_Path --
   -------------------

   function Get_File_Path (This : Wp_Theme; File : String := "") return String
   is
      use Php.Files;
      use Php.Strings;
      use UStrings;
      use Wp_Common;

      File_2 : constant String := Ltrim (File, "/");

      Stylesheet_Directory : constant String := This.Get_Stylesheet_Directory;
      Template_Directory   : constant String := This.Get_Template_Directory;

      Path : UString;
   begin
      if Empty (File_2) then
         Path := +Stylesheet_Directory;
      elsif File_Exists (Stylesheet_Directory & "/" & File_2) then
         Path := +Stylesheet_Directory & "/" & File_2;
      else
         Path := +Template_Directory & "/" & File_2;
      end if;

      -- This filter is documented in wp-includes/link-template.php
      return Apply_Filters ("theme_file_path", -Path, File_2);
   end Get_File_Path;

   ----------------------------
   -- Get_Core_Default_Theme --
   ----------------------------

   function Get_Core_Default_Theme return Wp_Theme is
      use Php.Arrays;
      use Inc_Themes;
   begin
      for A in Array_Reverse (Static_Default_Themes).Iterate loop
         declare
            Slug  : constant String := Key (A);
            --          Name  : Multi_Type := Element (A);
            Theme : constant Wp_Theme := Wp_Get_Theme (Slug);
         begin
            if Theme.Exists then
               return Theme;
            end if;
         end;
      end loop;
      return Null_Theme; -- False;
   end Get_Core_Default_Theme;

   -----------------
   -- Get_Allowed --
   -----------------

   function Get_Allowed
     (Blog_Id : Integer := 0) -- null
      return Stylesheet_Names
   is
      use Php.Arrays;
      use Wp_Common;

      --
      -- Filters the array of themes allowed on the network.
      --
      -- Site is provided as context so that a list of network allowed themes can
      -- be filtered further.
      --
      -- @since 4.5.0
      --
      -- @param string[] allowed_themes An array of theme stylesheet names.
      -- @param int      blog_id        ID of the site.
      --
      Network : constant Stylesheet_Names := -- List_Type :=
        Apply_Filters
          ("network_allowed_themes", Get_Allowed_On_Network, Blog_Id);
   begin
      return Array_Merge (Network, Get_Allowed_On_Site (Blog_Id));
      -- return Network + Get_Allowed_On_Site (Blog_Id);
   end Get_Allowed;

   ----------------------------
   -- Get_Allowed_On_Network --
   ----------------------------

   Static_Allowed_Themes : Stylesheet_Names; -- List_Type; -- Array_Type;

   function Get_Allowed_On_Network return Stylesheet_Names is
      use Wp_Common;
      use Inc_Options;

      Allowed_Themes : Stylesheet_Names renames Static_Allowed_Themes;
   begin
      if Allowed_Themes.Is_Empty then
         -- if not Isset (Allowed_Themes) then
         Allowed_Themes := As_Array (Get_Site_Option ("allowedthemes"));
      end if;

      --
      -- Filters the array of themes allowed on the network.
      --
      -- @since MU (3.0.0)
      --
      -- @param string[] allowed_themes An array of theme stylesheet names.
      --
      Allowed_Themes := Apply_Filters ("allowed_themes", Allowed_Themes);

      return Allowed_Themes;
   end Get_Allowed_On_Network;

   ----------------------------
   -- Get_Allowed_On_Network --
   ----------------------------

   Static_Allowed_Themes_On_Network : Array_Type;

   function Get_Allowed_On_Site
     (Blog_Id : Integer := 0) -- null
      return Stylesheet_Names
   is
      use Wp_Common;
      use Inc_Load;
      use Inc_Ms_Blogs;
      use Inc_Options;
      use Inc_Themes;

      Blog_Id_2 : constant Integer :=
        (if Blog_Id = 0 or else not Is_Multisite
         then Get_Current_Blog_Id
         else Blog_Id);

      Blog : constant String := Helpers.Image (Blog_Id_2);

      Allowed_Themes : Array_Type renames Static_Allowed_Themes_On_Network;
   begin

      if Isset (Allowed_Themes, Blog) then
         --
         -- Filters the array of themes allowed on the site.
         --
         -- @since 4.5.0
         --
         -- @param string[] allowed_themes An array of theme stylesheet names.
         -- @param int      blog_id        ID of the site. Defaults to current site.
         --
         return
           Apply_Filters
             ("site_allowed_themes",
              As_Array (Get (Allowed_Themes, Blog)),
              Blog_Id_2);
      end if;

      declare
         Current : constant Boolean := Get_Current_Blog_Id = Blog_Id_2;
      begin
         if Current then
            Set (Allowed_Themes, Blog, Get_Option ("allowedthemes"));
         else
            Switch_To_Blog (Blog_Id_2);
            Set (Allowed_Themes, Blog, Get_Option ("allowedthemes"));
            Restore_Current_Blog;
         end if;

         -- This is all super old MU back compat joy.
         -- 'allowedthemes' keys things by stylesheet. 'allowed_themes' keyed things by name.
         if False = As_Boolean (Get (Allowed_Themes, Blog)) then
            if Current then
               Set (Allowed_Themes, Blog, Get_Option ("allowed_themes"));
            else
               Switch_To_Blog (Blog_Id);
               Set (Allowed_Themes, Blog, Get_Option ("allowed_themes"));
               Restore_Current_Blog;
            end if;

            if not Is_Array (Get (Allowed_Themes, Blog))
              or else Empty (Allowed_Themes, Blog)
            then
               Set (Allowed_Themes, Blog, From_Array (Empty_Array));
            else
               declare
                  Converted : Array_Type;
                  Themes    : constant Theme_Array := Wp_Get_Themes;
               begin
                  Logging.Log ("get_allowed_on_site", "loop not implemented");
                  -- for A in Themes.Iterate loop
                  --    declare
                  --       Stylesheet : constant String := Key (A);
                  --       Theme_Data : constant Multi_Type := Element (A);
                  --    begin
                  --       if Isset_2
                  --            (Allowed_Themes,
                  --             Blog,
                  --             "XXX-B09") -- Theme_Data.Get ("Name"))
                  --       then
                  --          Set (Converted, Stylesheet, From_Boolean (True));
                  --       end if;
                  --    end;
                  -- end loop;
                  Set (Allowed_Themes, Blog, From_Array (Converted));
               end;
            end if;

            -- Set the option so we never have to go through this pain again.
            if Is_Admin and then As_Boolean (Get (Allowed_Themes, Blog)) then
               if Current then
                  Update_Option ("allowedthemes", Get (Allowed_Themes, Blog));
                  Delete_Option ("allowed_themes");
               else
                  Switch_To_Blog (Blog_Id_2);
                  Update_Option ("allowedthemes", Get (Allowed_Themes, Blog));
                  Delete_Option ("allowed_themes");
                  Restore_Current_Blog;
               end if;
            end if;
         end if;
      end;
      -- This filter is documented in wp-includes/class-wp-theme.php
      return
        Apply_Filters
          ("site_allowed_themes",
           As_Array (Get (Allowed_Themes, Blog)),
           Blog_Id);
   end Get_Allowed_On_Site;

   --------------------------
   -- Delete_Pattern_Cache --
   --------------------------

   procedure Delete_Pattern_Cache (This : Wp_Theme) is
      use UStrings;
      use Inc_Options;
   begin
      Delete_Site_Transient ("wp_theme_files_patterns-" & (-This.Cache_Hash));
   end Delete_Pattern_Cache;

   ------------------
   -- Sort_By_Name --
   ------------------

   procedure Sort_By_Name (Themes : in out Theme_Array) is -- Array_Type) is
   begin
      Logging.Log ("sort_by_name", "not implemented");
   end Sort_By_Name;
--                 if ( 0 === strpos( get_user_locale(), 'en_' ) ) then
--                         uasort( themes, array( 'WP_Theme', '_name_sort' ) );
--                 end; else then
--                         foreach ( themes as key => theme ) then
--                                 theme->translate_header( 'Name', theme->headers['Name'] );
--                         end;
--                         uasort( themes, array( 'WP_Theme', '_name_sort_i18n' ) );
--                 end;
--         end;

   --------------
   -- As_Multi --
   --------------

   function As_Multi (Theme : Wp_Theme) return Multi_Type is
      use Array_Lists;
      use UStrings;

      Result : constant Array_Type :=
        To_Array_Type
          ([Build ("update", Theme.Update),
            Build ("theme_root", -Theme.Theme_Root),
            Build ("headers", Theme.Headers),
            Build ("headers_sanitized", Theme.Headers_Sanitized),
            Build ("name_translated", -Theme.Name_Translated),
            Build ("errors", "not implemented"),
            Build ("stylesheet", -Theme.Stylesheet),
            Build ("template", -Theme.Template),
            -- M_Parent           null,
            Build ("theme_root_uri", -Theme.Theme_Root_URI),
            Build ("textdomain_loaded", Theme.Textdomain_Loaded),
            Build ("cache_hash", -Theme.Cache_Hash)]);
   begin
      return From_Array (Result);
   end As_Multi;

end Class_Themes;
