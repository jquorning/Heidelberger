--
-- WP_Theme Class
--
-- @package WordPress
-- @subpackage Theme
-- @since 3.4.0

with Php.Arrays;
with Php.Files;
with Php.Lists;
with Php.Misc;
with Php.Strings;
with Php.Types;

with Hb_Common;
with Lists;

with Inc_Caches;
with Inc_Error_Protection;
with Inc_Functions;
with Inc_Formatting;
with Inc_KSES;
with Inc_L10n;
with Inc_Load;
with Inc_Themes;

package body Class_Themes
is
   use Lists;

   function Apply_Filters (Name  : String;
                           Value : Boolean;
                           S     : String)
                           return Boolean
                           is (False);

   Wp_Theme_Directories : Array_Type;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Theme_Dir  : String;
                         Theme_Root : String;
                         X_Child    : in out Wp_Theme) -- _Access := null)
                         return Wp_Theme
   is
      use Hb_Common;
      use Php;
      use Php.Arrays;
      use Php.Files;
      use Php.Misc;
      use Php.Strings;
      use Php.Types;
      use Inc_Caches;
      use Class_Errors;
      use Inc_Error_Protection;
      use Inc_Functions;
      use Inc_Formatting;
      use Inc_L10n;
      use Inc_Load;
      use Inc_Themes;

      This  : Wp_Theme;
      Cache : Array_Type;
      Theme_File          : Unbounded_String;
      Theme_Root_Template : Unbounded_String;
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
      if
        not In_Array (Theme_Root, Wp_Theme_Directories, True) and then -- (array)
        In_Array (Dirname (Theme_Root), Wp_Theme_Directories, True) -- (array)
      then
         This.Stylesheet := Basename (-This.Theme_Root) & "/" & This.Stylesheet;
         This.Theme_Root := +Dirname (Theme_Root);
      end if;

      This.Cache_Hash := +MD5 (-(This.Theme_Root & "/" & This.Stylesheet));
      Theme_File      := This.Stylesheet & "/style.css";

      Cache := This.Cache_Get ("theme");

      if Is_Array (Cache) then
         for Key of To_List (List => (+"errors", +"headers", +"template")) loop
            if Isset (Cache, -Key) then
--             Append (Ref (This, -Key), Ref (Cache, -Key)); -- []
               null;
            end if;
         end loop;

         if This.Errors /= Null_Wp_Error then
            return Null_Theme;
         end if;

         if Isset (Cache, "theme_root_template") then
            Theme_Root_Template := +As_String (Get (Cache, "theme_root_template"));
         end if;

      elsif not File_Exists (-(This.Theme_Root & "/" & Theme_File)) then

         Set (This.Headers, "Name", From_String (-This.Stylesheet));

         if not File_Exists (-(This.Theme_Root & "/" & This.Stylesheet)) then
            This.M_Errors :=
              Wp_Error'(X_Construct (
                "theme_not_found",
                Sprintf (
                  -- translators: %s: Theme directory name.
                  abs "The theme directory ""%s"" does not exist.",
                  To_List (ESC_HTML (-This.Stylesheet))
                )
              ));
         else
            This.M_Errors := Wp_Error'(X_Construct
              ("theme_no_stylesheet",
               "Stylesheet is missing."));
         end if;

         This.Template := This.Stylesheet;
         This.Cache_Add (
           "theme",
           To_Array (List => (
             Build ("headers",    This.Headers),
--           Build ("errors",     This.Errors),
             Build ("stylesheet", -This.Stylesheet),
             Build ("template",   -This.Template)
           ))
         );

         if not File_Exists (-This.Theme_Root) then
            -- Don't cache this one.
            This.M_Errors.Add
              ("theme_root_missing",
               abs "<strong>Error:</strong> The themes directory is either empty or does not exist. Please check your installation.");
         end if;
         return Null_Theme;

      elsif not Is_Readable (-(This.Theme_Root &  "/" & Theme_File)) then

         Set (This.Headers, "Name", From_String (-This.Stylesheet));

         This.M_Errors :=
           Wp_Error'(X_Construct ("theme_stylesheet_not_readable",
                                  abs "Stylesheet is not readable."));
         This.Template         := This.Stylesheet;
         This.Cache_Add (
           "theme",
           To_Array (List => (
             Build ("headers",    This.Headers),
--           Build ("errors",     -This.Errors),
             Build ("stylesheet", -This.Stylesheet),
             Build ("template",   -This.Template)
           ))
         );
         return Null_Theme;

      else
         This.Headers :=
           Get_File_Data (-(This.Theme_Root & "/" & Theme_File),
                          Static_File_Headers,
                          "theme");
         declare
            -- Default themes always trump their pretenders.
            -- Properly identify default themes that are inside a directory within
            -- wp-content/themes.
            Default_Theme_Slug : constant String :=
              Array_Search (As_String (Get (This.Headers, "Name")),
                            Static_Default_Themes,
                            True);
         begin
            if Default_Theme_Slug /= "" then
               if Basename (-This.Stylesheet) /= Default_Theme_Slug then
                  Set (This.Headers, "Name",
                       Value => From_String ("/" & (-This.Stylesheet)));
               end if;
            end if;
         end;
      end if;

      if
        This.Template = "" and then
--      not This.Template and then
        This.Stylesheet = +As_String (Get (This.Headers, "Template"))
      then
         This.M_Errors :=
           Wp_Error'(X_Construct (
             "theme_child_invalid",
             Sprintf (
               -- translators: %s: Template.
               abs "The theme defines itself as its parent theme. Please check the %s header.",
               To_List ("<code>Template</code>")
             )
           ));
         This.Cache_Add (
           "theme",
           To_Array (List => (
             Build ("headers",    This.Headers),
--           Build ("errors",     -This.Errors),
             Build ("stylesheet", -This.Stylesheet)
           ))
         );
         return Null_Theme;

      end if;

      -- (If template is set from cache [and there are no errors], we know it's good.)
      if This.Template = "" then
         This.Template := +As_String (Get (This.Headers, "Template"));
      end if;

      if This.Template = "" then
         This.Template := This.Stylesheet;
         declare
            Theme_Path : constant String := -(This.Theme_Root & "/" & This.Stylesheet);
         begin
            if
              not File_Exists (Theme_Path & "/templates/index.html")
              and then not File_Exists (Theme_Path & "/block-templates/index.html")
              -- Deprecated path support since 5.9.0.
              and then not File_Exists (Theme_Path & "/index.Php")
            then
               declare
                  Error_Message : constant String := Sprintf (
                    -- translators: 1: templates/index.html, 2: index.php, 3: Documentation URL, 4: Template, 5: style.css
                    abs "Template is missing. Standalone themes need to have a %1s or %2s template file. <a href=""%3s"">Child themes</a> need to have a %4s header in the %5s stylesheet.",
                    To_List (List => (
                      1 => +"<code>templates/index.html</code>",
                      2 => +"<code>index.php</code>",
                      3 => +abs "https://developer.wordpress.org/themes/advanced-topics/child-themes/",
                      4 => +"<code>Template</code>",
                      5 => +"<code>style.css</code>"
                    ))
                  );
               begin
                  This.M_Errors := Wp_Error'(X_Construct ("theme_no_index",
                                                          Error_Message));
               end;
               This.Cache_Add (
                 "theme",
                 To_Array (List => (
                   Build ("headers",    This.Headers),
--                 Build ("errors",     -This.Errors),
                   Build ("stylesheet", -This.Stylesheet),
                   Build ("template",   -This.Template)
                 ))
               );
               return Null_Theme;
            end if;
         end;
      end if;

      -- If we got our data from cache, we can assume that 'template' is pointing to
      -- the right place.
      if
        not Is_Array (Cache) and then
        This.Template /= This.Stylesheet and then
        not File_Exists (-(This.Theme_Root & "/" & This.Template & "/index.php"))
      then
         declare
            -- If we're in a directory of themes inside /themes, look for the parent
            -- nearby. wp-content/themes/directory-of-themes/*
            Parent_Dir  : constant String     := Dirname (-This.Stylesheet);
            Directories : constant Array_Type := Search_Theme_Directories;
         begin
            if
              "." /= Parent_Dir and then
              File_Exists (-(This.Theme_Root & "/" & Parent_Dir & "/" &
                             This.Template & "/index.php"))
            then
               This.Template := Parent_Dir & "/" & This.Template;
            elsif
              not Directories.Is_Empty and then
              Isset (As_String (Get (Directories, -This.Template)))
            then
               -- Look for the template in the search_theme_directories() results, in
               -- case it is in another theme root.
               -- We don't look into directories of themes, just the theme root.
               Theme_Root_Template :=
                 +As_String (Get (As_Array (Get (Directories, -This.Template)), "theme_root"));
--             Theme_Root_Template := Directories (-This.Template) ("theme_root");
            else
               -- Parent theme is missing.
               This.M_Errors := Wp_Error'(X_Construct (
                 "theme_no_parent",
                 Sprintf (
                   -- translators: %s: Theme directory name.
                   abs "The parent theme is missing. Please install the ""%s"" parent theme.",
                   To_List (ESC_HTML (-This.Template))
                 )
               ));
               This.Cache_Add (
                 "theme",
                 To_Array (List => (
                   Build ("headers",    This.Headers),
--                 Build ("errors",     -This.Errors),
                   Build ("stylesheet", -This.Stylesheet),
                   Build ("template",   -This.Template)
                 ))
               );
               This.M_Parent :=
                 new Wp_Theme'(X_Construct (-This.Template, -This.Theme_Root, This));
               return Null_Theme;
            end if;
         end;
      end if;

      -- Set the parent, if we're a child theme.
      if This.Template /= This.Stylesheet then
         -- If we are a parent, then there is a problem. Only two generations
         -- allowed! Cancel things out.
         if
           X_Child in Wp_Theme and then      -- instaceof
           X_Child.Template = This.Stylesheet
         then
            X_Child.M_Parent := null;
            X_Child.M_Errors := Wp_Error'(X_Construct (
              "theme_parent_invalid",
              Sprintf (
                -- translators: %s: Theme directory name.
                abs "The ""%s"" theme is not a valid parent theme.",
                To_List (ESC_HTML (-X_Child.Template))
              )
            ));
            X_Child.Cache_Add (
              "theme",
              To_Array (List => (
                Build ("headers",    X_Child.Headers),
--              Build ("errors",     X_Child.Errors),
                Build ("stylesheet", -X_Child.Stylesheet),
                Build ("template",   -X_Child.Template)
              ))
            );
            -- The two themes actually reference each other with the Template header.
            if X_Child.Stylesheet = This.Template then
               This.M_Errors := Wp_Error'(X_Construct (
                 "theme_parent_invalid",
                 Sprintf (
                   -- translators: %s: Theme directory name.--
                   abs "The ""%s"" theme is not a valid parent theme.",
                   To_List (ESC_HTML (-This.Template))
                 )
               ));
               This.Cache_Add (
                 "theme",
                 To_Array (List => (
                   Build ("headers",    This.Headers),
--                 Build ("errors",     -This.Errors),
                   Build ("stylesheet", -This.Stylesheet),
                   Build ("template",   -This.Template)
                 ))
               );
            end if;
            return Null_Theme;
         end if;

         -- Set the parent. Pass the current instance so we can do the crazy checks
         -- above and assess errors.
         This.M_Parent :=
           new Wp_Theme'(X_Construct (-This.Template,
                                      (if Theme_Root_Template /= ""
--                                    (if Isset (Theme_Root_Template)
                                       then -Theme_Root_Template
                                       else -This.Theme_Root),
                                      This));
      end if;

      if
        Wp_Paused_Themes.Get (-This.Stylesheet) /= Empty_Array and then          -- ()
        (not Is_Wp_Error (This.Errors) or else
         not Isset (This.Errors.Errors, "theme_paused"))
      then
         This.M_Errors := Wp_Error'(X_Construct (
           "theme_paused",
           abs "This theme failed to load properly and was paused within the admin backend."));
      end if;

      -- We're good. If we didn't retrieve from cache, set it.
      if not Is_Array (Cache) then
         Cache := To_Array (List => (
           Build ("headers",    This.Headers),
--         Build ("errors",     -This.Errors),
           Build ("stylesheet", -This.Stylesheet),
           Build ("template",   -This.Template)
         ));
         -- If the parent theme is in another root, we'll want to cache this. Avoids
         -- an entire branch of filesystem calls above.
         if Theme_Root_Template /= "" then
--       if Isset (Theme_Root_Template) then
            Set (Cache, "theme_root_template", From_String (-Theme_Root_Template));
         end if;
         This.Cache_Add ("theme", Cache);
      end if;

      return This;
   end X_Construct;

   ------------
   -- Errors --
   ------------

   function Errors (This : Wp_Theme)
                    return Class_Errors.Wp_Error
   is
   begin
      return This.M_Errors;
--    return (if Is_Wp_Error (This.Errors) then This.Errors else False);
   end Errors;

   ------------
   -- Exists --
   ------------

   function Exists (This : Wp_Theme)
                    return Boolean
   is
      use Php.Lists;
      use Class_Errors;
   begin
      return not
        (This.Errors /= Null_Wp_Error and then
         In_List ("theme_not_found", This.Errors.Get_Error_Codes, True));
   end Exists;

   ------------
   -- Parent --
   ------------

   function Parent (This : Wp_Theme)
                    return Wp_Theme
   is
   begin
      return (if This.M_Parent /= null
              then This.M_Parent.all
              else Null_Theme);
--    return (if Isset (This.M_Parent) then This.Parent else False);
   end Parent;

   ---------------
   -- Cache_Add --
   ---------------

   function Cache_Add (This : Wp_Theme;
                       Key  : String;
                       Data : Array_Type)
                       return Boolean
   is
      use Hb_Common;
      use Inc_Caches;

      Result : Boolean;
   begin
      Wp_Cache_Add (Key & "-" & (-This.Cache_Hash), From_Array (Data), "themes",
                   Static_Cache_Expiration, Success => Result);
      return Result;
   end Cache_Add;

   procedure Cache_Add (This : Wp_Theme;
                        Key  : String;
                        Data : Array_Type)
   is
      Unused : Boolean;
   begin
      Unused := This.Cache_Add (Key, Data);
   end Cache_Add;

   ---------------
   -- Cache_Get --
   ---------------

   function Cache_Get (This : Wp_Theme;
                       Key  : String)
                       return Array_Type
   is
      use Hb_Common;
      use Inc_Caches;

      Found : Boolean;
   begin
      return Wp_Cache_Get (Key & "-" & (-This.Cache_Hash),
                           "themes", Found => Found);
   end Cache_Get;

   ---------
   -- Get --
   ---------

   function Get (This   : in out Wp_Theme;
                 Header : String)
                 return String
   is
      use Hb_Common;
      use Php;
      use Php.Arrays;
      use Php.Types;
   begin
      if not Isset (This.Headers, Header) then
         return ""; -- False;
      end if;

      if not Isset (This.Headers_Sanitized) then
         This.Headers_Sanitized := This.Cache_Get ("headers");
         if not Is_Array (This.Headers_Sanitized) then
            This.Headers_Sanitized := Empty_Array;
         end if;
      end if;

      if Isset (This.Headers_Sanitized, Header) then
         return As_String (Get (This.Headers_Sanitized, Header));
      end if;

      -- If themes are a persistent group, sanitize everything and cache it. One
      -- cache add is better than many cache sets.
      if Static_Persistently_Cache then -- self::
         for X_Header of List_Type'(Array_Keys (This.Headers)) loop
            Set (This.Headers_Sanitized, -X_Header,
                 From_String (
                   This.Sanitize_Header (-X_Header, As_String (Get (This.Headers, -X_Header)))));
         end loop;
         This.Cache_Add ("headers", This.Headers_Sanitized);
      else
         Set (This.Headers_Sanitized, Header,
              From_String (
                This.Sanitize_Header (Header, As_String (Get (This.Headers, Header)))));
      end if;

      return As_String (Get (This.Headers_Sanitized, Header));
   end Get;

   ---------------------
   -- Sanitize_Header --
   ---------------------

   function Sanitize_Header (This   : Wp_Theme;
                             Header : String;
                             Value  : String)
                             return String
   is
      use Hb_Common;
      use Php;
      use Php.Lists;
      use Php.Strings;
      use Inc_Formatting;
      use Inc_KSES;

      Value_2 : Unbounded_String;
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
            Header_Tags : constant Array_Type := To_Array (List => (
              Build ("abbr",    To_Array (List => (1 => Build ("title", True)))),
              Build ("acronym", To_Array (List => (1 => Build ("title", True)))),
              Build ("code",    True),
              Build ("em",      True),
              Build ("strong",  True)
            ));
         begin
            Value_2 := +Wp_KSES (Value, Header_Tags);
         end;
         << Break >>

      elsif Header in "Author" | "Description" then
         -- There shouldn"t be anchor tags in Author, but some themes like to be
         -- challenging.
         declare
            -- static
            Header_Tags_With_A : constant Array_Type := To_Array (List => (
              Build ("a",       To_Array (List => (
                Build ("href",  True),
                Build ("title", True)
              ))),
              Build ("abbr",    To_Array (List => (1 => Build ("title", True)))),
              Build ("acronym", To_Array (List => (1 => Build ("title", True)))),
              Build ("code",    True),
              Build ("em",      True),
              Build ("strong",  True)
            ));
         begin
            Value_2 := +Wp_KSES (Value, Header_Tags_With_A);
         end;

      elsif Header in "ThemeURI" | "AuthorURI" then
         Value_2 := +Sanitize_URL (Value);

      elsif Header = "Tags" then
         Value_3 :=
           List_Filter (List_Map (Trim'Access, Explode (",", Strip_Tags (Value))));

      elsif Header in "Version" | "RequiresWP" | "RequiresPHP" | "UpdateURI" then
         Value_2 := +Strip_Tags (Value);

      end if;

      return -Value_2;
   end Sanitize_Header;

   --------------------
   -- Get_Stylesheet --
   --------------------

   function Get_Stylesheet (This : Wp_Theme)
                            return String
   is
      use Hb_Common;
   begin
      return -This.Stylesheet;
   end Get_Stylesheet;

   ------------------
   -- Get_Template --
   ------------------

   function Get_Template (This : Wp_Theme)
                          return String
   is
      use Hb_Common;
   begin
      return -This.Template;
   end Get_Template;

   ----------------------------
   -- Get_Core_Default_Theme --
   ----------------------------

   function Get_Core_Default_Theme
            return Wp_Theme
   is
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

end Class_Themes;
