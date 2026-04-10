--
-- Dependencies API: WP_Scripts class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Php.Echoing;
with Php.HTML;
with Php.Lists;
with Php.Preg;
with Php.Strings;
with Php.Types;

with Arrayable_Interfaces;
with Globals;
with Wp_Common;

with Class_Dependency;
with Inc_Formatting;
with Inc_Functions;
with Inc_L10n;
with Inc_Load;
with Inc_Plugins;
with Inc_Script_Loader;
with Inc_Themes;

package body Class_Scripts
is

   --
   --
   --
   function Dummy_Init (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
                        return Array_Type;

   ----------------
   -- Dummy_Init --
   ----------------

   function Dummy_Init (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
                        return Array_Type
   is
      pragma Unreferenced (Arry);
   begin
      Init (Globals.Global_Wp_Scripts);
      return Empty_Array;
   end Dummy_Init;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
            return Wp_Scripts
   is
      use Inc_Plugins;

      This : Wp_Scripts;
   begin
      This.Init;
      Add_Action ("init", Dummy_Init'Access, 0); -- To_Array (This, "init"), 0);
      return This;
   end X_Construct;

   ----------
   -- Init --
   ----------

   procedure Init (This : in out Wp_Scripts)
   is
      use UStrings;
      use Inc_Plugins;
   begin
      if
--      Function_Exists ("is_admin") and then
        not Inc_Load.Is_Admin and then
--      Function_Exists ("current_theme_supports") and then
        not Inc_Themes.Current_Theme_Supports ("html5", "script")
      then
         This.Type_Attr := +" type=""text/javascript""";
      end if;

      --
      -- Fires when the WP_Scripts instance is initialized.
      --
      -- @since 2.6.0
      --
      -- @param WP_Scripts wp_scripts WP_Scripts instance (passed by reference).
      --
      Do_Action_Ref_Array ("wp_default_scripts", This);
   end Init;

   -------------------
   -- Print_Scripts --
   -------------------

   function Print_Scripts (This    : in out Wp_Scripts;
                           Handles : List_Type  := Empty_List;
                           Group   : Group_Type := No_Group)
                           return List_Type
   is
   begin
      return This.Do_Items (Handles, Group);
   end Print_Scripts;

   -----------------------
   -- Print_Script_L10n --
   -----------------------

   function Print_Scripts_L10n (This    : Wp_Scripts;
                                Handle  : String;
                                Display : Boolean := True)
                                return String
   is
      use Inc_Functions;
   begin
      X_Deprecated_Function ("__FUNCTION__", "3.3.0",
                             "WP_Scripts::print_extra_script()");
      return This.Print_Extra_Script (Handle, Display);
   end Print_Scripts_L10n;

   ------------------------
   -- Print_Extra_Script --
   ------------------------

   function Print_Extra_Script (This    : Wp_Scripts;
                                Handle  : String;
                                Display : Boolean := True)
                                return String
   is
      use Php.Echoing;
      use UStrings;
      use Inc_Formatting;

      Output : constant String := This.Get_Data (Handle, "data");
   begin
      if Output = "" then
         return "";  -- "" added jq
      end if;

      if not Display then
         return Output;
      end if;

      Printf ("<script%s id=""%s-js-extra"">" & NL,
              [
                1 => -This.Type_Attr,
                2 => ESC_Attr (Handle)
              ]);

      -- CDATA is not needed for HTML 5.
      if This.Type_Attr /= "" then
         Echo ("/* <![CDATA[ */" & NL);
      end if;

      Echo (Output & NL);

      if This.Type_Attr /= "" then
         Echo ("/* ]]> */" & NL);
      end if;

      Echo ("</script>" & NL);

      return ""; -- True;
   end Print_Extra_Script;

   -------------
   -- Do_Item --
   -------------

   overriding
   function Do_Item (This   : in out Wp_Scripts;
                     Handle : String;
                     Group  : Group_Type := No_Group)
                     return Boolean
   is
      use Php.Echoing;
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Class_Dependencies;
      use Class_Dependency;
      use Class_Dependency.String_Maps;
      use Inc_Functions;
      use Inc_Formatting;
   begin
      if not Do_Item (Wp_Dependencies (This), Handle) then
         return False;
      end if;

      if 0 = Group and then This.Groups (Handle) > 0 then
         This.In_Footer.Append (Handle);
         return False;
      end if;

      if 0 = Group and then In_List (Handle, This.In_Footer, True) then
         This.In_Footer := List_Diff (This.In_Footer, Handle);
      end if;

      Label_2 :
      declare
         Obj : constant X_Wp_Dependency := This.Registered (Handle);

         Ver_2 : constant String :=
           (if "" = Obj.Ver then ""
            else (if Obj.Ver /= ""
                  then -Obj.Ver else -This.Default_Version));

         Ver : constant String :=
           (if Has_Element (This.Args.Find (Handle))
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
            then "<!--[if " & Conditional & "]>" & NL else "");

         Cond_After : constant String :=
            (if Conditional /= "" then "<![endif]-->" & NL else "");

         Before_Handle_2 : constant String :=
            This.Print_Inline_Script (Handle, "before", False);

         After_Handle_2 : constant String :=
            This.Print_Inline_Script (Handle, "after", False);

         Before_Handle : constant String :=
           (if Before_Handle_2 /= "" then
              Sprintf (
                "<script%s id=""%s-js-before"">" & NL & "%s" & NL & "</script>" & NL,
                [
                  1 => -This.Type_Attr,
                  2 => ESC_Attr (Handle),
                  3 => Before_Handle_2
                ])
            else Before_Handle_2);

         After_Handle : constant String :=
           (if After_Handle_2 /= "" then
              Sprintf (
                "<script%s id=""%s-js-after"">" & NL & "%s" & NL & "</script>" & NL,
                [
                  1 => -This.Type_Attr,
                  2 => ESC_Attr (Handle),
                  3 => After_Handle_2
                ])
            else After_Handle_2);

         Inline_Script_Tag : constant String :=
           (if Before_Handle /= "" or else After_Handle /= ""
            then Cond_Before & Before_Handle & After_Handle & Cond_After
            else "");

         -- Prevent concatenation of scripts if the text domain is defined
         -- to ensure the dependency order is respected.
         Translations_Stop_Concat : constant Boolean :=
            Obj.Textdomain /= "";

         Translations_2 : constant String :=
            This.Print_Translations (Handle, False);

         Translations : constant String :=
           (if Translations_2 /= "" then
              Sprintf (
                "<script%s id=""%s-js-translations"">" & NL & "%s" & NL & "</script>" & NL,
                [
                  1 => -This.Type_Attr,
                  2 => ESC_Attr (Handle),
                  3 => Translations_2
                ])
            else Translations_2);
      begin
         if This.Do_Concat then
            --
            -- Filters the script loader source.
            --
            -- @since 2.2.0
            --
            -- @param string src    Script loader source path.
            -- @param string handle Script handle.
            --
            declare
               Srce : constant String :=
                  Apply_Filters ("script_loader_src", Src, Handle);
            begin
               if This.In_Default_Dir (Srce)
                 and then (Before_Handle /= ""
                           or else After_Handle /= ""
                           or else Translations_Stop_Concat)
               then
                  This.Do_Concat := False;

                  -- Have to print the so-far concatenated scripts right
                  -- away to maintain the right order.
                  Inc_Script_Loader.X_Print_Scripts;
                  This.Reset;
               elsif This.In_Default_Dir (Srce) and then Conditional = "" then
                  Append
                    (This.Print_Code, This.Print_Extra_Script (Handle, False));
                  Append (This.Concat, Handle & ",");
                  Append (This.Concat_Version, Handle & Ver);
                  return True;
               else
                  Append (This.Ext_Handles, Handle & ",");
                  Append (This.Ext_Version, Handle & Ver);
               end if;
            end;
         end if;

         declare
            Unused : UString;
            Has_Conditional_Data : constant Boolean :=
               Conditional /= "" and then
               "" = This.Get_Data (Handle, "data");
         begin

            if Has_Conditional_Data then
               Echo (Cond_Before);
            end if;

            Unused := +This.Print_Extra_Script (Handle);

            if Has_Conditional_Data then
               Echo (Cond_After);
            end if;
         end;
         -- A single item may alias a set of items, by having dependencies,
         -- but no source.
         if Src = "" then
            if Inline_Script_Tag /= "" then
               if This.Do_Concat then
                  Append (This.Print_HTML, Inline_Script_Tag);
               else
                  Echo (Inline_Script_Tag);
               end if;
            end if;
            return True;
         end if;

         declare
            Unused_Matches : List_Type;

            Src_2 : constant String :=
              (if
                 0 /= Preg_Match ("|^(https?:)?//|", Src, Unused_Matches) and then
                 not (This.Content_URL /= "" and then
                 0 = Strpos (Src, -This.Content_URL))
               then -This.Base_URL & Src
               else Src);

            Src_3 : constant String :=
              (if not Empty (Ver)
               then Add_Query_Arg ("ver", Ver, Src)
               else Src_2);

            -- This filter is documented in wp-includes/class-wp-scripts.php
            Src_4 : constant String :=
              ESC_URL (Apply_Filters ("script_loader_src", Src_3, Handle));
         begin
            if Src_4 = "" then
               return True;
            end if;

            declare
               Tag_4 : constant String :=
                 Translations & Cond_Before & Before_Handle;

               Tag_3 : constant String := Tag_4 &
                 Sprintf (
                   "<script%s src=""%s"" id=""%s-js""></script>" & NL,
                   [
                     1 => -This.Type_Attr,
                     2 => Src_4,
                     3 => ESC_Attr (Handle)
                   ]);

               Tag_2 : constant String :=
                  Tag_3 & After_Handle & Cond_After;

               --
               -- Filters the HTML script tag of an enqueued script.
               --
               -- @since 4.1.0
               --
               -- @param string tag    The `<script>` tag for the enqueued
               --                      script.
               -- @param string handle The script"s registered handle.
               -- @param string src    The script"s source URL.
               --
               Tag : constant String :=
                 Apply_Filters ("script_loader_tag", Tag_2, Handle, Src_4);
            begin
               if This.Do_Concat then
                  Append (This.Print_HTML, Tag);
               else
                  Echo (Tag);
               end if;
            end;
         end;
      end Label_2;
      return True;
   end Do_Item;

   -----------------------
   -- Add_Inline_Script --
   -----------------------

   function Add_Inline_Script (This     : in out Wp_Scripts;
                               Handle   : String;
                               Data     : String;
                               Position : String := "after")
                               return Boolean
   is
   begin
      if Data /= "" then
         return False;
      end if;

      declare
         Position_2 : constant String :=
           (if "after" /= Position
            then "before" else Position);

         Script_2 : constant String :=
           This.Get_Data (Handle, Position_2);

         Script : constant String := Script_2 & Data;
      begin
         return This.Add_Data (Handle, Position_2, Script);
      end;
   end Add_Inline_Script;

   -----------------------
   -- Add_Inline_Script --
   -----------------------

   procedure Add_Inline_Script (This     : in out Wp_Scripts;
                                Handle   : String;
                                Data     : String;
                                Position : String := "after")
   is
      Unused : constant Boolean :=
        Add_Inline_Script (This, Handle, Data, Position);
   begin
      null;
   end Add_Inline_Script;

   -------------------------
   -- Print_Inline_Script --
   -------------------------

   function Print_Inline_Script (This     : Wp_Scripts;
                                 Handle   : String;
                                 Position : String  := "after";
                                 Display  : Boolean := True)
                                 return String
   is
      use Php.Echoing;
      use Php.Strings;
      use UStrings;
      use Inc_Formatting;

      Output_2 : constant String := This.Get_Data (Handle, Position);
   begin
      if Output_2 = "" then
         return ""; -- False;
      end if;

      declare
         Output : constant String := Trim (Implode (NL, Output_2), NL);
      begin
         if Display then
            Printf ("<script%s id=""%s-js-%s"">" & NL & "%s" & NL & "</script>" & NL,
                    [
                      1 => -This.Type_Attr,
                      2 => ESC_Attr (Handle),
                      3 => ESC_Attr (Position),
                      4 => Output
                    ]);
         end if;

         return Output;
      end;
   end Print_Inline_Script;

   --------------
   -- Localize --
   --------------

   function Localize (This        : in out Wp_Scripts;
                      Handle      : String;
                      Object_Name : String;
                      L10n        : Array_Type)
                      return Boolean
   is
      use Php.HTML;
      use Php.Strings;
      use Php.Types;
      use UStrings;
      use Inc_Functions;
      use Inc_L10n;

      L10n_2 : Array_Type := L10n;

      Handle_2 : constant String :=
        (if "jquery" = Handle then "jquery-core" else Handle);

      -- back compat, preserve the code in "l10n_print_after" if present.
      After : constant String :=
        (if Is_Array (L10n_2) and then Isset (L10n_2, "l10n_print_after")
         then Get_As_String (L10n_2, "l10n_print_after")
         else "");
--         Unset (L10n_2 ("l10n_print_after"));
   begin
      if not Is_Array (L10n_2) then
         X_Doing_It_Wrong
           ("__METHOD__",
            Sprintf (
              -- translators: 1: l10n, 2: wp_add_inline_script()--
              abs "The %1s parameter must be an array. To pass arbitrary data to scripts, use the %2s function instead.",
              [
                1 => "<code>l10n</code>",
                2 => "<code>wp_add_inline_script()</code>"
              ]
            ),
            "5.7.0");

         -- if L10n_2.Is_Empty then
         --    -- This should really not be needed, but is necessary for backward
         --    -- compatibility.
         --    L10n_2 := To_Array (L10n_2);
         -- end if;
      end if;

--      if Is_String (L10n_2) then
--         L10n_2 := Html_Entity_Decode (L10n_2, ENT_QUOTES, "UTF-8");
--      elsif Is_Array (L10n_2) then
         for A in L10n_2.Iterate loop --  as key => value ) loop
            declare
               Key   : constant String := Arrays.Key (A);
               Value : constant String := Get_As_String (L10n_2, Key);
               -- Array_Maps.Element (A); -- -A.Value;
            begin
--               if not Is_Scalar (Value) then
--                  goto Continue_1;
--               end if;

               Set (L10n_2, Key,
                    From_String (HTML_Entity_Decode (Value, ENT_QUOTES, "UTF-8")));
            end;
--            << Continue_1 >>
         end loop;
--      end if;

      declare
         Script_3 : constant String :=
            "var object_name = " & Wp_JSON_Encode (From_Array (L10n_2)) & ";";

         Script_2 : constant String :=
           (if not Empty (After)
            then Script_3 & NL & After & ";"
            else Script_3);

         Data : constant String := This.Get_Data (Handle_2, "data");

         Script : constant String :=
           (if Data /= ""
            then Data & NL & Script_2
            else Script_2);
      begin
         return This.Add_Data (Handle_2, "data", Script);
      end;
   end Localize;

   --------------
   -- Localize --
   --------------

   procedure Localize (This        : in out Wp_Scripts;
                       Handle      : String;
                       Object_Name : String;
                       L10n        : Array_Type)
   is
      Unused : constant Boolean :=
        Localize (This, Handle, Object_Name, L10n);
   begin
      null;
   end Localize;

   ---------------
   -- Set_Group --
   ---------------

   function Set_Group (This      : in out Wp_Scripts;
                       Handle    : String;
                       Recursion : Boolean;
                       Group     : Group_Type := No_Group)
                       return Boolean
   is
      use UStrings;
      use Class_Dependencies;

      Grp : Group_Type;
   begin
      Grp := (if -This.Registered (Handle).Args = "1" then 1 else 0);

      if No_Group /= Group and then Grp > Group then
         Grp := Group;
      end if;

      return Set_Group (Wp_Dependencies'Class (This), Handle, Recursion, Grp);
   end Set_Group;

   ----------------------
   -- Set_Translations --
   ----------------------

   function Set_Translations (This   : Wp_Scripts;
                              Handle : String;
                              Domain : String := "default";
                              Path   : String := "")
                              return Boolean
   is
      use Php.Lists;
      use Class_Dependency;
      use Class_Dependency.Dependency_Maps;
   begin
--      if not Isset (This.Registered (Handle)) then
      if not Has_Element (This.Registered.Find (Handle)) then
         return False;
      end if;

      -- @var \_WP_Dependency obj
      declare
         Obj : X_Wp_Dependency := This.Registered (Handle);
      begin
         if not In_List ("wp-i18n", Obj.Deps, True) then
            Obj.Deps.Append ("wp-i18n");
         end if;

         return Obj.Set_Translations (Domain, Path);
      end;
   end Set_Translations;

   ----------------------
   -- Set_Translations --
   ----------------------

   procedure Set_Translations (This   : Wp_Scripts;
                               Handle : String;
                               Domain : String := "default";
                               Path   : String := "")
   is
      Unused : constant Boolean :=
        Set_Translations (This, Handle, Domain, Path);
   begin
      null;
   end Set_Translations;

   ------------------------
   -- Print_Translations --
   ------------------------

   function Print_Translations (This    : Wp_Scripts;
                                Handle  : String;
                                Display : Boolean := True)
                                return String
   is
      use Php.Echoing;
      use UStrings;
      use Class_Dependency;
      use Class_Dependency.Dependency_Maps;
      use Inc_Formatting;

      use Inc_L10n;
   begin
      if
        Has_Element (This.Registered.Find (Handle)) or else
        This.Registered (Handle).Textdomain = ""
      then
         return ""; -- False;
      end if;

      declare
         Regist : constant Dependency_Maps.Cursor := This.Registered.Find (Handle);
         Domain : constant String := -Element (Regist).Textdomain;

         Path   : constant String :=
           (if Element (Regist).Translations_Path /= ""
            then -Element (Regist).Translations_Path else "");

         JSON_Translations : constant String :=
            Load_Script_Textdomain (Handle, Domain, Path);
      begin
         if JSON_Translations = "" then
            return "";
         end if;

         declare
            Output : constant String :=
              "( function( domain, translations ) {"  &
              "        var localeData = translations.locale_data[ domain ] || " &
              "translations.locale_data.messages;" &
              "        localeData[""].domain = domain;" &
              "        wp.i18n.setLocaleData( localeData, domain );" &
              "} )( """ & Domain & """, " & JSON_Translations & " );";
         begin
            if Display then
               Printf ("<script%s id=""%s-js-translations"">" & NL & "%s" & NL &
                       "</script>" & NL,
                       [
                         1 => -This.Type_Attr,
                         2 => ESC_Attr (Handle),
                         3 => Output
                       ]);
            end if;

            return Output;
         end;
      end;
   end Print_Translations;

   --------------
   -- All_Deps --
   --------------

   function All_Deps (This      : in out Wp_Scripts;
                      Handles   : List_Type;
                      Recursion : Boolean    := False;
                      Group     : Group_Type := No_Group)
                      return Boolean
   is
      use Wp_Common;
      use Class_Dependencies;

      Result : constant Boolean :=
        All_Deps (Wp_Dependencies (This), Handles, Recursion, Group);
      -- Parent
   begin
      if not Recursion then
         --
         -- Filters the list of script dependencies left to print.
         --
         -- @since 2.3.0
         --
         -- @param string() to_do An array of script dependency handles.
         --
         This.To_Do := Apply_Filters ("print_scripts_array", This.To_Do);
      end if;
      return Result;
   end All_Deps;

   -------------------
   -- Do_Head_Items --
   -------------------

   function Do_Head_Items (This : in out Wp_Scripts)
                           return List_Type
   is
      Unused : constant List_Type :=
        Do_Items (This, False, Group => 0);
   begin
      return This.Done;
   end Do_Head_Items;

   -------------------
   -- Do_Head_Items --
   -------------------

   procedure Do_Head_Items (This : in out Wp_Scripts)
   is
      Unused : constant List_Type := Do_Head_Items (This);
   begin
      null;
   end Do_Head_Items;

   ---------------------
   -- Do_Footer_Items --
   ---------------------

   function Do_Footer_Items (This : in out Wp_Scripts)
                             return List_Type
   is
      Unused : constant List_Type :=
        Do_Items (This, False, Group => 1);
   begin
      return This.Done;
   end Do_Footer_Items;

   ---------------------
   -- Do_Footer_Items --
   ---------------------

   procedure Do_Footer_Items (This : in out Wp_Scripts)
   is
      Unused : constant List_Type := Do_Footer_Items (This);
   begin
      null;
   end Do_Footer_Items;

   --------------------
   -- In_Default_Dir --
   --------------------

   function In_Default_Dir (This : Wp_Scripts;
                            Src  : String)
                            return Boolean
   is
      use Php.Strings;
      use Globals;
      use UStrings;
   begin
      if This.Default_Dirs.Is_Empty then
         return True;
      end if;

      if 1 = Strpos (Src, "/" & (-WPINC) & "/js/l10n") then
         return False;
      end if;

      for Test of This.Default_Dirs loop
         if 1 = Strpos (Src, Test) then
            return True;
         end if;
      end loop;
      return False;
   end In_Default_Dir;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out Wp_Scripts)
   is
      use UStrings;
   begin
      This.Do_Concat      := False;
      This.Print_Code     := Null_UString;
      This.Concat         := Null_UString;
      This.Concat_Version := Null_UString;
      This.Print_HTML     := Null_UString;
      This.Ext_Version    := Null_UString;
      This.Ext_Handles    := Null_UString;
   end Reset;

end Class_Scripts;
