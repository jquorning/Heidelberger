--
-- Dependencies API: WP_Styles class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Php.Echoing;
with Php.Preg;
with Php.Strings;

with Arrays;
with Wp_Common;

with Class_Dependency;
with Inc_Formatting;
with Inc_Functions;
with Inc_Themes;
with Inc_Load;
with Inc_Plugins;

package body Class_Styles
is
   use Arrays;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
      return Wp_Styles
   is
      use UStrings;
      use Inc_Load;
      use Inc_Themes;
      use Inc_Plugins;

      This : Wp_Styles;
   begin
      if
--      function_exists( "is_admin" ) and then
        not Is_Admin and then
--      function_exists( "current_theme_supports" ) and then
        not Current_Theme_Supports ("html5", "style")
      then
         This.Type_Attr := +" type=""text/css""";
      end if;

      --
      -- Fires when the WP_Styles instance is initialized.
      --
      -- @since 2.6.0
      --
      -- @param WP_Styles wp_styles WP_Styles instance (passed by reference).
      --
      Do_Action_Ref_Array ("wp_default_styles", This);
      return This;
   end X_Construct;

   -------------
   -- Do_Item --
   -------------

   overriding
   function Do_Item (This   : in out Wp_Styles;
                     Handle : String;
                     Group  : Integer := 0)
                     return Boolean
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Dependencies;
      use Class_Dependency;
      use Inc_Formatting;
   begin
      if not Do_Item (Wp_Dependencies (This), Handle) then
         return False;
      end if;

      declare
         Obj : constant X_Wp_Dependency := This.Registered (Handle);

         Ver_2 : constant String :=
           (if Obj.Ver /= "" then -Obj.Ver else -This.Default_Version);

         Has_Arg : constant Boolean :=
           This.Args.Contains (Handle) and then This.Args (Handle) /= "";

         Ver : constant String :=
           (if Has_Arg
            then (if Ver_2 /= ""
                  then Ver_2 & "&amp;" & This.Args (Handle)
                  else This.Args (Handle))
            else Ver_2);

         Src : constant String := -Obj.Src;

         Conditional : constant String :=
           (if Isset (Obj.Extra, "conditional")
            then Get_As_String (Obj.Extra, "conditional")
            else "");

         Cond_Before : constant String :=
           (if Conditional /= ""
            then "<!--[if " & Conditional & "]>" & NL
            else "");

         Cond_After  : constant String :=
           (if Conditional /= ""
            then "<![endif]-->" & NL
            else "");

         Inline_Style : constant String :=
           This.Print_Inline_Style (Handle, False);

         Inline_Style_Tag : constant String :=
           (if Inline_Style /= ""
            then Sprintf (
                   "<style id=""%s-inline-css""%s>" & NL &
                   "%s" & NL & "</style>" & NL,
                   [
                     1 => ESC_Attr (Handle),
                     2 => -This.Type_Attr,
                     3 => Inline_Style
                   ])
            else "");

      begin
         if This.Do_Concat then
            if
              This.In_Default_Dir (Src) and then
              Conditional = ""          and then
              not Isset (Obj.Extra, "alt")
            then
               Append (This.Concat,         Handle & ",");
               Append (This.Concat_Version, Handle & Ver);

               Append (This.Print_Code, Inline_Style);

               return True;
            end if;
         end if;

         -- A single item may alias a set of items, by having dependencies, but
         -- no source.
         if Src = "" then
            if Inline_Style_Tag /= "" then
               if This.Do_Concat then
                  Append (This.Print_HTML, Inline_Style_Tag);
               else
                  Echo (Inline_Style_Tag);
               end if;
            end if;

            return True;
         end if;

         declare
            Media : constant String :=
              (if Isset (-Obj.Args)
               then ESC_Attr (-Obj.Args)
               else "all");

            Href : constant String := This.X_CSS_Href (Src, Ver, Handle);

            Rel : constant String :=
              (if
                 Isset (Obj.Extra, "alt") and then
                 Get_As_String (Obj.Extra, "alt") /= ""
               then "alternate stylesheet" else "stylesheet");

            Title : constant String :=
              (if Isset (Obj.Extra, "title")
               then Sprintf (" title=""%s""",
                             [1 => ESC_Attr (Get_As_String (Obj.Extra, "title"))])
               else "");

            Tag_2 : constant String :=
              Sprintf (
                "<link rel=""%s"" id=""%s-css""%s href=""%s""%s media=""%s"" />" & NL,
                [
                  1 => Rel,
                  2 => Handle,
                  3 => Title,
                  4 => Href,
                  5 => -This.Type_Attr,
                  6 => Media
                ]
              );

            Tag      : UString;
            RTL_Href : UString;
         begin
            if Href = "" then
               return True;
            end if;

            --
            -- Filters the HTML link tag of an enqueued style.
            --
            -- @since 2.6.0
            -- @since 4.3.0 Introduced the `href` parameter.
            -- @since 4.5.0 Introduced the `media` parameter.
            --
            -- @param string tag    The link tag for the enqueued style.
            -- @param string handle The style"s registered handle.
            -- @param string href   The stylesheet"s source URL.
            -- @param string media  The stylesheet"s media attribute.
            --
            Tag := +Apply_Filters ("style_loader_tag", Tag_2, Handle, Href, Media);

            if
              "rtl" = This.Text_Direction and then
              Isset (Obj.Extra, "rtl")    and then
              Get_As_String (Obj.Extra, "rtl") /= ""
            then
               if
                 Kind_Of (Get (Obj.Extra, "rtl")) in Kind_Boolean or else
                 "replace" = Get_As_String (Obj.Extra, "rtl")
               then
                  declare
                     Suffix : constant String :=
                       (if Isset (Obj.Extra, "suffix")
                        then Get_As_String (Obj.Extra, "suffix") else "");
                  begin
                     RTL_Href :=
                       +Str_Replace (Suffix & ".css", "-rtl" & Suffix & ".css",
                                     This.X_CSS_Href (Src, Ver, Handle & "-rtl"));
                  end;
               else
                  RTL_Href := +This.X_CSS_Href (Get_As_String (Obj.Extra, "rtl"),
                                                Ver, Handle & "-rtl");
               end if;

               declare
                  RTL_Tag_2 : constant String :=
                    Sprintf (
                      "<link rel=""%s"" id=""%s-rtl-css""%s href=""%s""%s " &
                      "media=""%s"" />" & NL,
                      [
                        1 => Rel,
                        2 => Handle,
                        3 => Title,
                        4 => -RTL_Href,
                        5 => -This.Type_Attr,
                        6 => Media
                      ]);

                  -- This filter is documented in wp-includes/class-wp-styles.php--
                  RTL_Tag : constant String :=
                    Apply_Filters ("style_loader_tag", RTL_Tag_2,
                                   Handle, -RTL_Href, Media);
               begin
                  if "replace" = Get_As_String (Obj.Extra, "rtl") then
                     Tag := +RTL_Tag;
                  else
                     Append (Tag, RTL_Tag);
                  end if;
               end;
            end if;

            if This.Do_Concat then
               Append (This.Print_HTML, Cond_Before);
               Append (This.Print_HTML, Tag);
               if Inline_Style_Tag /= "" then
                  Append (This.Print_HTML, Inline_Style_Tag);
               end if;
               Append (This.Print_HTML, Cond_After);
            else
               Echo (Cond_Before);
               Echo (-Tag);
               This.Print_Inline_Style (Handle);
               Echo (Cond_After);
            end if;
         end;
      end;
      return True;
   end Do_Item;

   ----------------------
   -- Add_Inline_Style --
   ----------------------

   function Add_Inline_Style (This   : in out Wp_Styles;
                              Handle : String;
                              Code   : String)
                              return Boolean
   is
      use Lists.List_Vectors;
   begin
      if Code = "" then
         return False;
      end if;

      declare
         After_2 : constant List_Type := This.Get_Data (Handle, "after");
         After   : constant List_Type := After_2 & Code;
      begin
         -- if After.Is_Empty then
         --    After := Empty_List;
         -- end if;

         -- After.Append (Code);

         return This.Add_Data (Handle, "after", After);
      end;
   end Add_Inline_Style;

   ------------------------
   -- Print_Inline_Style --
   ------------------------

   function Print_Inline_Style (This    : Wp_Styles;
                                Handle  : String;
                                Display : Boolean := True)
                                return String
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;

      Output_2 : constant List_Type := This.Get_Data (Handle, "after");
   begin
      if Output_2.Is_Empty then
         return ""; -- False;
      end if;

      declare
         Output : constant String := Implode (NL, Output_2);
      begin
         if not Display then
            return Output;
         end if;

         Printf (
           "<style id=""%s-inline-css""%s>" & NL & "%s" & NL & "</style>" & NL,
           [
             1 => ESC_Attr (Handle),
             2 => -This.Type_Attr,
             3 => Output
           ]);
      end;
      return "(true)";
   end Print_Inline_Style;

   ------------------------
   -- Print_Inline_Style --
   ------------------------

   procedure Print_Inline_Style (This    : Wp_Styles;
                                 Handle  : String;
                                 Display : Boolean := True)
   is
      Unused : constant String := Print_Inline_Style (This, Handle, Display);
   begin
      null;
   end Print_Inline_Style;

   --------------
   -- All_Deps --
   --------------

   overriding
   function All_Deps (This      : in out Wp_Styles;
                      Handles   : List_Type;
                      Recursion : Boolean := False;
                      Group     : Integer := 0) -- false
                      return Boolean
   is
      use Wp_Common;
      use Class_Dependencies;

      Result : constant Boolean :=
        All_Deps (Wp_Dependencies (This), Handles, Recursion, Group);
   begin
      if not Recursion then
         --
         -- Filters the array of enqueued styles before processing for output.
         --
         -- @since 2.6.0
         --
         -- @param string[] to_do The list of enqueued style handles about to be
         --                       processed.
         --
         This.To_Do := Apply_Filters ("print_styles_array", This.To_Do);
      end if;
      return Result;
   end All_Deps;

   ----------------
   -- X_CSS_Href --
   ----------------

   function X_CSS_Href (This   : Wp_Styles;
                        Src    : String;
                        Ver    : String;
                        Handle : String)
                        return String
   is
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_Formatting;
      use Inc_Functions;

      Src_2 : constant String :=
         (if
--          not Is_Bool (Src) and then
            not Preg_Match ("|^(https?:)?//|", Src) and then
            not (This.Content_URL /= "" and then
                 0 = Strpos (Src, -This.Content_URL))
          then -This.Base_URL & Src
          else Src);

      Src_3 : constant String :=
        (if not Empty (Ver)
         then Add_Query_Arg ("ver", Ver, Src_2)
         else Src_2);

      --
      -- Filters an enqueued style's fully-qualified URL.
      --
      -- @since 2.6.0
      --
      -- @param string src    The source URL of the enqueued style.
      -- @param string handle The style"s registered handle.
      --
      Src_4 : constant String :=
        Apply_Filters ("style_loader_src", Src_3, Handle);
   begin
      return ESC_URL (Src_4);
   end X_CSS_Href;

   --------------------
   -- Id_Default_Dir --
   --------------------

   function In_Default_Dir (This : Wp_Styles;
                            Src  : String)
                            return Boolean
   is
      use Php.Strings;
   begin
      if This.Default_Dirs.Is_Empty then
         return True;
      end if;

      for Test of This.Default_Dirs loop -- (array)
         if 0 = Strpos (Src, Test) then
            return True;
         end if;
      end loop;
      return False;
   end In_Default_Dir;

   ---------------------
   -- Do_Footer_Items --
   ---------------------

   procedure Do_Footer_Items (This : in out Wp_Styles)
   is
      Unused : constant List_Type :=
         Do_Footer_Items (This);
   begin
      null;
   end Do_Footer_Items;

   ---------------------
   -- Do_Footer_Items --
   ---------------------

   function Do_Footer_Items (This : in out Wp_Styles)
            return List_Type
   is
   begin
      This.Do_Items (False, 1);
      return This.Done;
   end Do_Footer_Items;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out Wp_Styles)
   is
      use UStrings;
   begin
      This.Do_Concat      := False;
      This.Concat         := Null_UString;
      This.Concat_Version := Null_UString;
      This.Print_HTML     := Null_UString;
   end Reset;

end Class_Styles;
