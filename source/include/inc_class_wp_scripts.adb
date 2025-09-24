--
-- Dependencies API: WP_Scripts class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Ada.Containers;

with Globals;
with Hb_Common;
with Php;

with Inc_Class_Wp_Dependency;
with Inc_Formatting;
with Inc_Functions;
with Inc_L10n;
with Inc_Load;
with Inc_Plugins;
with Inc_Script_Loader;
with Inc_Themes;

package body Inc_Class_Wp_Scripts
is
   use Hb_Common;
   use Inc_L10n;
   use Php;

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
--    Add_Action ("init", To_Array (This, "init"), 0);
      return This;
   end X_Construct;

   ----------
   -- Init --
   ----------

   procedure Init (This : in out Wp_Scripts)
   is
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
--    Do_Action_Ref_Array ("wp_default_scripts", This); -- to_array (&this)
   end Init;

   -------------------
   -- Print_Scripts --
   -------------------

   function Print_Scripts (This    : in out Wp_Scripts;
                           Handles : List_Type := Empty_List;
                           Group   : Integer      := 0) -- False)
                           return String_Array
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
      use Inc_Formatting;

      Output : constant Unbounded_String := +this.Get_Data (Handle, "data");
      Unused : Unbounded_String;
   begin
      if Output = "" then
         return "";  -- "" added jq
      end if;

      if not Display then
         return -Output;
      end if;

      Unused := +Printf ("<script%s id=""%s-js-extra"">\n", -This.Type_Attr,
                         Esc_Attr (Handle));

      -- CDATA is not needed for HTML 5.
      if This.Type_Attr /= "" then
         Echo ("/* <![CDATA[--\n");
      end if;

      Echo ("output\n");

      if This.Type_Attr /= "" then
         echo ("/* ]]>--\n");
      end if;

      Echo ("</script>\n");

      return ""; -- True;
   end Print_Extra_Script;

   -------------
   -- Do_Item --
   -------------

   function Do_Item (This   : in out Wp_Scripts;
                     Handle : String;
                     Group  : Boolean := False)
                     return Boolean
   is
      use Inc_Functions;
      use Inc_Formatting;
      use Inc_Class_Wp_Dependency;
      use Inc_Class_Wp_Dependency.String_Maps;
   begin
--      if not parent::Do_Item (handle) then
--         return False;
--      end if;

      if False = Group then -- and then This.Groups (Handle) > 0 then
         This.In_Footer.Append (+Handle); -- []
         return False;
      end if;

      if False = Group and then In_Array (Handle, This.In_Footer, True) then
         This.In_Footer := Array_Diff (This.In_Footer, Handle); -- (array)
      end if;

      declare
         Obj : X_Wp_Dependency := This.Registered (Handle);
         Ver : Unbounded_String;
      begin
         if "" = Obj.Ver then
            Ver := +"";
         else
            Ver := (if Obj.Ver /= "" then Obj.Ver else This.Default_Version);
         end if;

         if This.Args.Find (Handle) /= No_Element then
            Ver := (if Ver /= "" then Ver & "&amp;" & (+This.Args (Handle))
                                 else +This.Args (Handle));
         end if;

         Label_2 :
         declare
            Src : Unbounded_String := Obj.Src;

            Conditional : constant Boolean :=
               Boolean'Value ((if Obj.Extra.Find ("conditional") /=
                                  String_Maps.No_Element
                               then Obj.Extra ("conditional") else "false"));

            Cond_Before : constant String :=
               (if Conditional then "<!--[if " & Conditional'Image & "]>\n" else "");

            Cond_After  : constant String :=
               (if Conditional then "<![endif]-->\n" else "");

            Before_Handle : Unbounded_String :=
               +This.Print_Inline_Script (Handle, "before", False);

            After_Handle  : Unbounded_String :=
               +This.Print_Inline_Script (Handle, "after",  False);

            Unused_Matches : Array_Type;
         begin

            if Before_Handle /= "" then
               Before_Handle :=
                  +Sprintf ("<script%s id=""%s-js-before"">\n%s\n</script>\n",
                            -This.Type_Attr, Esc_Attr (Handle), -Before_Handle);
            end if;

            if After_Handle /= "" then
               After_Handle :=
                  +Sprintf ("<script%s id=""%s-js-after"">\n%s\n</script>\n",
                            -This.Type_Attr, Esc_Attr (Handle), -After_Handle);
            end if;

            declare
               Inline_Script_Tag : Unbounded_String;
            begin
               if Before_Handle /= "" or else After_Handle /= "" then
                  Inline_Script_Tag :=
                     Cond_Before & Before_Handle & After_Handle & Cond_After;
               else
                  Inline_Script_Tag := +"";
               end if;

               --
               -- Prevent concatenation of scripts if the text domain is defined
               -- to ensure the dependency order is respected.
               --
               Label_1 :
               declare
                  Translations_Stop_Concat : constant Boolean :=
                     Obj.Textdomain /= "";

                  Translations : Unbounded_String :=
                     +This.Print_Translations (Handle, False);
               begin
                  if Translations /= "" then
                     Translations := +Sprintf (
                        "<script%s id=""%s-js-translations"">\n%s\n</script>\n",
                        -this.Type_attr, Esc_Attr (Handle), -Translations);
                  end if;

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
                           Apply_Filters ("script_loader_src", -Src, Handle);
                     begin
                        if
                          This.In_Default_Dir (Srce) and then
                          (Before_Handle /= "" or else After_Handle /= "" or else
                          Translations_Stop_Concat)
                        then
                           This.Do_Concat := False;

                           -- Have to print the so-far concatenated scripts right
                           -- away to maintain the right order.
                           Inc_Script_Loader.X_Print_Scripts; -- ();
                           This.Reset; -- ();
                        elsif
                          This.In_Default_Dir (Srce) and then
                          Conditional
                        then
                           Append (This.Print_Code,
                                   This.Print_Extra_Script (Handle, False));
                           Append (This.Concat,         "handle,");
                           Append (This.Concat_Version, "handlever");
                           return True;
                        else
                           Append (This.Ext_Handles, "handle,");
                           Append (This.Ext_Version, "handlever");
                        end if;
                     end;
                  end if;

                  declare
                     Unused : Unbounded_String;
                     Has_Conditional_Data : constant Boolean :=
                        Conditional and then
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
                           Append (this.Print_Html, Inline_Script_Tag);
                        else
                           echo (-Inline_Script_Tag);
                        end if;
                     end if;
                     return True;
                  end if;

                  if
                    0 /= Preg_Match ("|^(https?:)?//|", -Src, Unused_Matches)
                    and then not (This.Content_Url /= "" and then
                    0 = Strpos (-Src, -This.Content_Url))
                  then
                     Src := This.Base_Url & Src;
                  end if;

                  if not Empty (-Ver) then
                     Src := +Add_Query_Arg ("ver", -Ver, -Src);
                  end if;

                  -- This filter is documented in wp-includes/class-wp-scripts.php
                  Src := +Esc_Url (Apply_Filters ("script_loader_src", -Src,
                                                  Handle));

                  if Src = "" then
                     return True;
                  end if;

                  declare
                     Tag : Unbounded_String :=
                        Translations & Cond_Before & Before_Handle;
                  begin
                     Append (Tag,
                        Sprintf ("<script%s src=""%s"" id=""%s-js""></script>\n",
                                 -This.Type_Attr, -Src, Esc_Attr (Handle)));
                     Append (Tag, After_Handle & Cond_After);

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
                     Tag := +Apply_Filters
                        ("script_loader_tag", -Tag, Handle, -Src);

                     if This.Do_Concat then
                        Append (This.Print_Html, Tag);
                     else
                        Echo (-Tag);
                     end if;
                  end;
               end Label_1;
            end;
         end Label_2;

         return True;
      end;
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
      Position_2 : Unbounded_String := +Position;
   begin
      if Data /= "" then
         return False;
      end if;

      if "after" /= Position_2 then
         Position_2 := +"before";
      end if;

      declare
         use Array_Vectors;

         Script : Unbounded_String := +This.Get_Data (Handle, -Position_2); -- (array)
      begin
         Append (Script, Data);  -- ()
         return This.Add_Data (Handle, -Position_2, -Script);
      end;
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
      use Inc_Functions;
      use Inc_Formatting;

      Output : Unbounded_String := +This.Get_Data (Handle, Position);
      Unused : Unbounded_String;
   begin
      if Output = "" then
         return ""; -- False;
      end if;

      Output := +Trim (Implode ("\n", -Output), "\n");

      if Display then
         Unused := +Printf ("<script%s id=""%s-js-%s"">\n%s\n</script>\n",
                 -This.Type_Attr, Esc_Attr (Handle), Esc_Attr (Position), -Output);
      end if;

      return -Output;
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
      use Inc_Functions;
      use Array_Vectors;

      L10n_2   : Array_Type := L10n;
      After    : Array_Type;
      Handle_2 : Unbounded_String := +Handle;
   begin
      if "jquery" = Handle_2 then
         Handle_2 := +"jquery-core";
      end if;

      -- back compat, preserve the code in "l10n_print_after" if present.
      if Is_Array (L10n_2) and then Isset (L10n_2, "l10n_print_after") then
         After := Get (L10n_2, "l10n_print_after");
--         Unset (L10n_2 ("l10n_print_after"));
      end if;

      if not Is_Array (L10n_2) then
         X_Doing_It_Wrong
           ("__METHOD__",
            Sprintf (
                     -- translators: 1: l10n, 2: wp_add_inline_script()--
                     abs "The %1s parameter must be an array. To pass arbitrary data to scripts, use the %2s function instead.",
                     "<code>l10n</code>",
                     "<code>wp_add_inline_script()</code>"
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
         for A of L10n_2 loop --  as key => value ) loop
            declare
               Key   : constant String := -A.Key;
               Value : constant String := -A.Value;
            begin
--               if not Is_Scalar (Value) then
--                  goto Continue_1;
--               end if;

               Set (L10n_2, Key, Html_Entity_Decode (Value, ENT_QUOTES, "UTF-8"));
            end;
--            << Continue_1 >>
         end loop;
--      end if;

      declare
         Script : Unbounded_String :=
            +"var object_name = " & Wp_Json_Encode (L10n_2) & ";";
      begin
         if not Empty (After) then
            Append (Script, "\nafter;");
         end if;

         declare
            Data : constant String := This.Get_Data (-Handle_2, "data");
         begin
            if Data /= "" then
               Script := +"data\nscript";
            end if;
         end;

         return This.Add_Data (-Handle_2, "data", -Script);
      end;
   end Localize;

   ---------------
   -- Set_Group --
   ---------------

   function Set_Group (This      : in out Wp_Scripts;
                       Handle    : String;
                       Recursion : Boolean;
                       Group     : Integer := 0) -- Boolean := False)
                       return Boolean
   is
      use Ada.Containers;
      use Array_Vectors;

      Grp : Integer;
   begin
      if
        not This.Registered (Handle).Args.Is_Empty and then
        1 = This.Registered (Handle).Args.Length
      then
         Grp := 1;
      else
         Grp := 1; -- Integer'Value (This.Get_Data (Handle, "group"));
      end if;

      if 0 /= Group and then Grp > Group then
         Grp := Group;
      end if;

      return True; -- parent::Set_Group (Handle, Recursion, Grp);
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
      use Inc_Class_Wp_Dependency.Dependency_Maps;
   begin
--      if not Isset (This.Registered (Handle)) then
      if This.Registered.Find (Handle) = No_Element then
         return False;
      end if;

      -- @var \_WP_Dependency obj
      declare
         use Inc_Class_Wp_Dependency;
--         use String_
         Obj : X_Wp_Dependency := This.Registered (Handle);
      begin
         if not In_Array ("wp-i18n", Obj.Deps, True) then
            Obj.Deps.Append ("wp-i18n");  -- ()
         end if;

         return Obj.Set_Translations (Domain, Path);
      end;
   end Set_Translations;

   ------------------------
   -- Print_Translations --
   ------------------------

   function Print_Translations (This    : Wp_Scripts;
                                Handle  : String;
                                Display : Boolean := True)
                                return String
   is
      use Inc_Functions;
      use Inc_Class_Wp_Dependency.Dependency_Maps;
   begin
      if
        This.Registered.find (Handle) /= No_Element or else
        This.Registered (Handle).Textdomain = ""
      then
         return ""; -- False;
      end if;

      declare
         use Inc_Formatting;

         Regist : constant Cursor := This.Registered.Find (Handle);
         Domain : constant String := -Element (Regist).Textdomain;
--       Domain : String   := -This.Registered (Handle).Textdomain;
--         Path   : Unbounded_String;
         Path   : String   := (if Element (Regist).Translations_Path /= ""
                               then -Element (Regist).Translations_Path else "");
         Json_Translations : constant String :=
            Load_Script_Textdomain (Handle, Domain, Path);
         Output : Unbounded_String;
         Unused : Unbounded_String;
      begin
         if Json_Translations = "" then
            return "";
         end if;

         Output :=
           +"( function( domain, translations ) {"  &
            "        var localeData = translations.locale_data( domain ) || translations.locale_data.messages;" &
            "        localeData("").domain = domain;" &
            "        wp.i18n.setLocaleData( localeData, domain );" &
            "} )( ""{domain}"", {json_translations} );";

         if Display then
            Unused := +Printf ("<script%s id=""%s-js-translations"">\n%s\n</script>\n",
                              -This.Type_Attr, Esc_Attr (Handle), -Output);
         end if;

         return -Output;
      end;
   end Print_Translations;

   --------------
   -- All_Deps --
   --------------

   function All_Deps (This      : in out Wp_Scripts;
                      Handles   : String;
                      Recursion : Boolean := False;
                      Group     : Boolean := False)
                      return Boolean
   is
      R : constant Boolean := False; -- Parent::All_Deps (Handles, Recursion, Group);
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
      return R;
   end All_Deps;

   -------------------
   -- Do_Head_Items --
   -------------------

   function Do_Head_Items (This : in out Wp_Scripts)
                           return String_Array
   is
      Unused : String_Array := Do_Items (This, False, Group => 0);
   begin
      return This.Done;
   end Do_Head_Items;

   ---------------------
   -- Do_Footer_Items --
   ---------------------

   function Do_Footer_Items (This : in out Wp_Scripts)
                             return String_Array
   is
      Unused : String_Array := Do_Items (This, False, Group => 1);
   begin
      return This.Done;
   end Do_Footer_Items;

   --------------------
   -- In_Default_Dir --
   --------------------

   function In_Default_Dir (This : Wp_Scripts;
                            Src  : String)
                            return Boolean
   is
      use Globals;
   begin
      if This.Default_Dirs.Is_Empty then
         return True;
      end if;

      if 0 = Strpos (Src, "/" & WPINC & "/js/l10n") then
         return False;
      end if;

      for Test of This.Default_Dirs loop -- (array)
         if 0 = Strpos (Src, -Test) then
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
   begin
      This.Do_Concat      := False;
      This.Print_Code     := +"";
      This.Concat         := +"";
      This.Concat_Version := +"";
      This.Print_Html     := +"";
      This.Ext_Version    := +"";
      This.Ext_Handles    := +"";
   end Reset;

end Inc_Class_Wp_Scripts;
