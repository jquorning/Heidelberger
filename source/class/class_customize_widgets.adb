--
-- WordPress Customize Widgets classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.9.0
--

with Php.Arrays;
with Php.Echoing;
with Php.HTML;
with Php.Lists;
with Php.Preg;
with Php.Sorting;
with Php.Strings;

with Binder;
with Globals;
with Wp_Common;

with Adi_Posts;
with Adi_Widgets;
--    require_once ABSPATH . "wp-admin/includes/widgets.php";
      -- For next_widget_id_number().

with Cust_Class_Wp_Customize_Sidebar_Block_Editor_Controls;
with Cust_Class_Wp_Customize_Sidebar_Sections;
with Cust_Class_Wp_Widget_Area_Customize_Controls;
with Cust_Class_Wp_Widget_Form_Customize_Controls;

with Inc_Capabilities;
with Class_Block_Editor_Contexts;
with Class_Customize_Controls;
with Class_Customize_Managers;
with Class_Customize_Settings;
with Class_Customize_Sections;
with Class_Widget_Factories;
with Inc_Block_Editors;
with Inc_Formatting;
with Inc_Functions_Wp_Scripts;
with Inc_Functions_Wp_Styles;
with Inc_Functions;
with Inc_General_Templates;
with Inc_L10n;
with Inc_Load;
with Inc_Options;
with Inc_Pluggables;
with Inc_Plugins;
with Inc_Themes;
with Inc_Widgets;

package body Class_Customize_Widgets
is

   Global_Wp_Widget_Factory : -- Widget_Vectors.Vector;
     Class_Widget_Factories.Wp_Widget_Factory;

   Global_Wp_Registered_Widget_Controls : Array_Type;

   type Proc_Access is access procedure (This : in out Wp_Customize_Widgets);

   function To_Array (This : Wp_Customize_Widgets;
                      CB   : Proc_Access)
                      return Callable;

   function To_Array (This : Wp_Customize_Widgets;
                      CB   : Proc_Access)
                      return Callable
   is
   begin
      return null;
   end To_Array;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct
               (Manager : access Class_Customize_Managers.Wp_Customize_Manager)
                return Wp_Customize_Widgets
   is
      use Inc_Capabilities;
      use Inc_Plugins;

      This : Wp_Customize_Widgets;
   begin
      This.Manager := Manager;

      -- See https://github.com/xwp/wp-customize-snapshots/blob/962586659688a5b1fd9ae93618b7ce2d4e7a421c/php/class-customize-snapshot-manager.php#L420-L449
      Add_Filter ("customize_dynamic_setting_args",
                  To_Array (This, Filter_Customize_Dynamic_Setting_Args'Access),
                  10, 2);
      Add_Action ("widgets_init",
                  To_Array (This, Register_Settings'Access), 95);
      Add_Action ("customize_register",
                  To_Array (This, Schedule_Customize_Register'Access), 1);

      -- Skip remaining hooks when the user can't manage widgets anyway.
      if not Current_User_Can ("edit_theme_options") then
         raise Capability_Error;
--       return;
      end if;

      Add_Action ("wp_loaded",
                  To_Array (This, Override_Sidebars_Widgets_For_Theme_Switch'Access));
      Add_Action ("customize_controls_init",
                  To_Array (This, Customize_Controls_Init'Access));
      Add_Action ("customize_controls_enqueue_scripts",
                  To_Array (This, Enqueue_Scripts'Access));
      Add_Action ("customize_controls_print_styles",
                  To_Array (This, Print_Styles'Access));
      Add_Action ("customize_controls_print_scripts",
                  To_Array (This, Print_Scripts'Access));
      Add_Action ("customize_controls_print_footer_scripts",
                  To_Array (This, Print_Footer_Scripts'Access));
      Add_Action ("customize_controls_print_footer_scripts",
                  To_Array (This, Output_Widget_Control_Templates'Access));
      Add_Action ("customize_preview_init",
                  To_Array (This, Customize_Preview_Init'Access));
      Add_Filter ("customize_refresh_nonces",
                  To_Array (This, Refresh_Nonces'Access));
      Add_Filter ("should_load_block_editor_scripts_and_styles",
                  To_Array (This, Should_Load_Block_Editor_Scripts_And_Styles'Access));

      Add_Action ("dynamic_sidebar",
                  To_Array (This, Tally_Rendered_Widgets'Access));
      Add_Filter ("is_active_sidebar",
                  To_Array (This, Tally_Sidebars_Via_Is_Active_Sidebar_Calls'Access),
                  10, 2);
      Add_Filter ("dynamic_sidebar_has_widgets",
                  To_Array (This, Tally_Sidebars_Via_Dynamic_Sidebar_Calls'Access),
                  10, 2);

      -- Selective Refresh.
      Add_Filter ("customize_dynamic_partial_args",
                  To_Array (This, Customize_Dynamic_Partial_Args'Access), 10, 2);
      Add_Action ("customize_preview_init",
                  To_Array (This, Selective_Refresh_Init'Access));

      return This;
   end X_Construct;

   ---------------------------------------
   -- Get_Selective_Refreshable_Widgets --
   ---------------------------------------

   function Get_Selective_Refreshable_Widgets (This : in out Wp_Customize_Widgets)
                                               return Array_Type
   is
      use Inc_Themes;
--                global wp_widget_factory;
   begin
      if not Current_Theme_Supports ("customize-selective-refresh-widgets") then
         return Empty_Array;
      end if;

--      if not Isset (This.Selective_Refreshable_Widgets) then
         This.Selective_Refreshable_Widgets := Empty_Array;
         for Wp_Widget of Global_Wp_Widget_Factory.Widgets loop
            Set (This.Selective_Refreshable_Widgets, -Wp_Widget.Id_Base,
                 From_Boolean (not Empty (Wp_Widget.Widget_Options,
                                          "customize_selective_refresh")));
         end loop;
--      end if;
      return This.Selective_Refreshable_Widgets;
   end Get_Selective_Refreshable_Widgets;

   -------------------------------------
   -- Is_Widget_Selective_Refreshable --
   -------------------------------------

   function Is_Widget_Selective_Refreshable (This    : in out Wp_Customize_Widgets;
                                             Id_Base : String)
                                             return Boolean
   is
      Selective_Refreshable_Widgets : constant Array_Type :=
        This.Get_Selective_Refreshable_Widgets;
   begin
      return not Empty (Selective_Refreshable_Widgets, Id_Base);
   end Is_Widget_Selective_Refreshable;

   ----------------------
   -- Get_Setting_Type --
   ----------------------

   Static_Cache : Array_Type;

   function Get_Setting_Type (This       : Wp_Customize_Widgets;
                              Setting_Id : String)
                              return String
   is
      use Php.Preg;
   begin
      if Isset (Static_Cache, Setting_Id) then
         return As_String (Get (Static_Cache, Setting_Id));
      end if;

      for A in This.Setting_Id_Patterns.Iterate loop
         declare
            Typ     : constant String := Key (A);
            Pattern : constant String := As_String (Element (A));
         begin
            if Preg_Match (Pattern, Setting_Id) then
               Set (Static_Cache, Setting_Id, From_String (Typ));
               return Typ;
            end if;
         end;
      end loop;
      return ""; -- added
   end Get_Setting_Type;

   -----------------------
   -- Register_Settings --
   -----------------------

   procedure Register_Settings (This : in out Wp_Customize_Widgets)
   is
      use Binder;
      use Php.Arrays;
      use Php.Lists;
      use Inc_Formatting;

      Widget_Setting_Ids   : List_Type;
      Incoming_Setting_Ids : constant List_Type :=
        Array_Keys (This.Manager.Unsanitized_Post_Values); -- ()
   begin
      for Setting_Id of Incoming_Setting_Ids loop
         if "" /= This.Get_Setting_Type (-Setting_Id) then -- not is_null
            Widget_Setting_Ids.Append (Setting_Id);
         end if;
      end loop;

      if
        This.Manager.Doing_AJAX ("update-widget") and then
        Isset (X_REQUEST, "widget-id")
      then
         Widget_Setting_Ids.Append
           (+This.Get_Setting_Id (
               Wp_Unslash (As_String (Get (X_REQUEST, "widget-id")))));
      end if;

      declare
         use Class_Customize_Managers;

         Settings : constant Setting_Lists.Vector :=
           This.Manager.Add_Dynamic_Settings (List_Unique (Widget_Setting_Ids));
      begin
         if This.Manager.Settings_Previewed then
            for Setting of Settings loop
               declare
                  Setting_2 : Wp_Customize_Setting := Setting;
               begin
                  Setting_2.Preview;
               end;
            end loop;
         end if;
      end;
   end Register_Settings;

   -------------------------------------------
   -- Filter_Customize_Dynamic_Setting_Args --
   -------------------------------------------

   function Filter_Customize_Dynamic_Setting_Args
              (This       : in out Wp_Customize_Widgets;
               Args       : Array_Type;
               Setting_Id : String)
               return Array_Type
   is
      Args_2 : Array_Type := Args;
   begin
      if "" /= This.Get_Setting_Type (Setting_Id) then
         Args_2 := This.Get_Setting_Args (Setting_Id);
      end if;
      return Args_2;
   end Filter_Customize_Dynamic_Setting_Args;

   procedure Filter_Customize_Dynamic_Setting_Args
     (This : in out Wp_Customize_Widgets)
   is
   begin
      null;
   end Filter_Customize_Dynamic_Setting_Args;

   ------------------------------------------------
   -- Override_Sidebars_Widgets_For_Theme_Switch --
   ------------------------------------------------

   procedure Override_Sidebars_Widgets_For_Theme_Switch
               (This : in out Wp_Customize_Widgets)
   is
      use Inc_Plugins;
      use Inc_Widgets;
   begin
      if
        This.Manager.Doing_AJAX or else
        This.Manager.Is_Theme_Active
      then
         return;
      end if;

      This.Old_Sidebars_Widgets := Wp_Get_Sidebars_Widgets; -- ()
      Add_Filter ("customize_value_old_sidebars_widgets_data",
                  To_Array (This,
                            Filter_Customize_Value_Old_Sidebars_Widgets_Data'Access));
      This.Manager.Set_Post_Value ("old_sidebars_widgets_data",
                                   This.Old_Sidebars_Widgets);
      -- Override any value cached in changeset.

      -- retrieve_widgets() looks at the global sidebars_widgets.
      Global_Sidebars_Widgets := This.Old_Sidebars_Widgets;
      Global_Sidebars_Widgets := Retrieve_Widgets ("customize");
      Add_Filter ("option_sidebars_widgets",
                  To_Array (This,
                            Filter_Option_Sidebars_Widgets_For_Theme_Switch'Access),
                  1);

      -- Reset global cache var used by wp_get_sidebars_widgets().
      Delete (Ref (Globals.GLOBALS, "_wp_sidebars_widgets"));
   end Override_Sidebars_Widgets_For_Theme_Switch;

   ------------------------------------------------------
   -- Filter_Customize_Value_Old_Sidebars_Widgets_Data --
   ------------------------------------------------------

   function Filter_Customize_Value_Old_Sidebars_Widgets_Data
              (This                 : Wp_Customize_Widgets;
               Old_Sidebars_Widgets : Array_Type)
               return Array_Type
   is
   begin
      return This.Old_Sidebars_Widgets;
   end Filter_Customize_Value_Old_Sidebars_Widgets_Data;

   procedure Filter_Customize_Value_Old_Sidebars_Widgets_Data
               (This : in out Wp_Customize_Widgets)
   is null;

   -----------------------------------------------------
   -- Filter_Option_Sidebars_Widgets_For_Theme_Switch --
   -----------------------------------------------------

   function Filter_Option_Sidebars_Widgets_For_Theme_Switch
              (This             : Wp_Customize_Widgets;
               Sidebars_Widgets : Array_Type)
               return Array_Type
   is
      Sidebars_Widgets_2 : Array_Type :=
        As_Array (Get (Globals.GLOBALS, "sidebars_widgets"));
   begin
      Set (Sidebars_Widgets_2, "array_version", From_Integer (3));
      return Sidebars_Widgets_2;
   end Filter_Option_Sidebars_Widgets_For_Theme_Switch;

   procedure Filter_Option_Sidebars_Widgets_For_Theme_Switch
              (This : in out Wp_Customize_Widgets)
   is null;

   ----------------------------
   -- Customize_Preview_Init --
   ----------------------------

   procedure Customize_Controls_Init (This : in out Wp_Customize_Widgets)
   is
      use Inc_Plugins;
   begin
      -- This action is documented in wp-admin/includes/ajax-actions.php
      Do_Action ("load-widgets.php");
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      -- This action is documented in wp-admin/includes/ajax-actions.php
      Do_Action ("widgets.php");
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      -- This action is documented in wp-admin/widgets.php
      Do_Action ("sidebar_admin_setup");
   end Customize_Controls_Init;

   ---------------------------------
   -- Schedule_Customize_Register --
   ---------------------------------

   procedure Schedule_Customize_Register (This : in out Wp_Customize_Widgets)
   is
      use Inc_Load;
      use Inc_Plugins;
   begin
      if Is_Admin then
         This.Customize_Register; -- ()
      else
         Add_Action ("wp", To_Array (This, Customize_Register'Access));
      end if;
   end Schedule_Customize_Register;

   ------------------------
   -- Customize_Register --
   ------------------------

   procedure Customize_Register (This : in out Wp_Customize_Widgets)
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;
      use UStrings;
      use Wp_Common;
      use Inc_L10n;
      use Inc_Plugins;
      use Inc_Widgets;

      Use_Widgets_Block_Editor : constant Boolean :=
        Wp_Use_Widgets_Block_Editor;

      Sidebars_Widgets : Array_Type;
      New_Setting_Ids  : List_Type;
   begin
      Add_Filter ("sidebars_widgets",
                  To_Array (This, Preview_Sidebars_Widgets'Access), 1);

      Sidebars_Widgets :=
        Array_Merge (
          Arry_1 => To_Array (List => (1 =>
                      Build ("wp_inactive_widgets", Empty_Array))),
          Arry_2 => Array_Fill_Keys (
                      Array_Keys (Global_Wp_Registered_Sidebars),
                      From_Array (Empty_Array)),
          Arry_3 => Wp_Get_Sidebars_Widgets -- ()
        );

      --
      -- Register a setting for all widgets, including those which are active,
      -- inactive, and orphaned since a widget may get suppressed from a sidebar
      -- via a plugin (like Widget Visibility).
      --
      for Widget_Id of List_Type'(Array_Keys (Global_Wp_Registered_Widgets)) loop
         declare
            use Class_Customize_Settings;

            Setting_Id   : constant String     := This.Get_Setting_Id (-Widget_Id);
            Setting_Args : constant Array_Type := This.Get_Setting_Args (Setting_Id);
         begin
            if Null_Setting = This.Manager.Get_Setting (Setting_Id) then -- not
               This.Manager.Add_Setting (Setting_Id, Setting_Args);
            end if;
            New_Setting_Ids.Append (+Setting_Id);
         end;
      end loop;

      --
      -- Add a setting which will be supplied for the theme's sidebars_widgets
      -- theme_mod when the theme is switched.
      --
      if not This.Manager.Is_Theme_Active then -- ()
         declare
            Setting_Id   : constant String := "old_sidebars_widgets_data";
            Setting_Args : constant Array_Type :=
              This.Get_Setting_Args (
                Setting_Id,
                To_Array (List => (
                  Build ("type",  "global_variable"),
                  Build ("dirty", True)
                ))
              );
         begin
            This.Manager.Add_Setting (Setting_Id, Setting_Args);
         end;
      end if;

      This.Manager.Add_Panel (
        "widgets",
        To_Array (List => (
          Build ("type",                     "widgets"),
          Build ("title",                    abs "Widgets"),
          Build ("description",              abs "Widgets are independent sections of content that can be placed into widgetized areas provided by your theme (commonly called sidebars)."),
          Build ("priority",                 110),
          Build ("active_callback",          To_Array (This, Is_Panel_Active'Access)),
          Build ("auto_expand_sole_section", True),
          Build ("theme_supports",           "widgets")
        ))
      );

      for A in Sidebars_Widgets.Iterate loop
         declare
            Sidebar_Id         : constant String     := Key (A);
            Sidebar_Widget_Ids : Array_Type := As_Array (Element (A));
         begin
            if Sidebar_Widget_Ids.Is_Empty then
               Sidebar_Widget_Ids := Empty_Array;
            end if;

            declare
               Is_Registered_Sidebar : constant Boolean :=
                 Inc_Widgets.Is_Registered_Sidebar (Sidebar_Id);

               Is_Inactive_Widgets   : constant Boolean :=
                 "wp_inactive_widgets" = Sidebar_Id;

               Is_Active_Sidebar     : constant Boolean :=
                 Is_Registered_Sidebar and not Is_Inactive_Widgets;

               Section_Id : UString;
            begin
               -- Add setting for managing the sidebar's widgets.
               if Is_Registered_Sidebar or Is_Inactive_Widgets then
                  declare
                     use Class_Customize_Settings;

                     Setting_Id : constant String :=
                       Sprintf ("sidebars_widgets[%s]", To_List (Sidebar_Id));

                     Setting_Args : Array_Type := This.Get_Setting_Args (Setting_Id);
                  begin
                     if Null_Setting = This.Manager.Get_Setting (Setting_Id) then -- not
                        if not This.Manager.Is_Theme_Active then -- ()
                           Set (Setting_Args, "dirty", From_Boolean (True));
                        end if;
                        This.Manager.Add_Setting (Setting_Id, Setting_Args);
                     end if;
                     New_Setting_Ids.Append (+Setting_Id);

                     -- Add section to contain controls.
--                     declare
--                        Section_Id : String :=
--                          Sprintf ("sidebar-widgets-%s", To_List (Sidebar_Id));
                     begin
                        Section_Id :=
                          +Sprintf ("sidebar-widgets-%s", To_List (Sidebar_Id));

                        if Is_Active_Sidebar then
                           declare
                              Section_Args : Array_Type := To_Array (List => (
                                Build ("title",
                                       As_String (Get (Ref_2 (Global_Wp_Registered_Sidebars,
                                                              Key_1 => Sidebar_Id,
                                                              Key_2 => "name")))),
                                Build ("priority",
                                       List_Search
                                         (Sidebar_Id,
                                          List_Type'(Array_Keys (Global_Wp_Registered_Sidebars)), True)),
                                Build ("panel",      "widgets"),
                                Build ("sidebar_id", Sidebar_Id)
                              ));
                           begin
                              if Use_Widgets_Block_Editor then
                                 Set (Section_Args, "description", From_String (""));
                              else
                                 Set (Section_Args, "description",
                                      Get (Ref_2 (Global_Wp_Registered_Sidebars,
                                                  Key_1 => Sidebar_Id,
                                                  Key_2 => "description")));
                              end if;

                              --
                              -- Filters Customizer widget section arguments for a
                              -- given sidebar.
                              --
                              -- @since 3.9.0
                              --
                              -- @param array      section_args Array of Customizer
                              --                                 widget section
                              --                                 arguments.
                              -- @param string     section_id   Customizer section ID.
                              -- @param int|string sidebar_id   Sidebar ID.
                              --
                              Section_Args :=
                                Apply_Filters ("customizer_widgets_section_args",
                                               Section_Args, -Section_Id, Sidebar_Id);

                              declare
                                 use Cust_Class_Wp_Customize_Sidebar_Sections;
                                 use Class_Customize_Sections;

                                 Section : constant Wp_Customize_Sidebar_Section :=
                                   X_Construct (This.Manager,
                                                -Section_Id, Section_Args);
                              begin
                                 This.Manager.Add_Section
                                   (Wp_Customize_Section (Section));
--                               This.Manager.Add_Section (Section);
                              end;

                              if Use_Widgets_Block_Editor then
                                 declare
                                    use Cust_Class_Wp_Customize_Sidebar_Block_Editor_Controls;
                                    use Class_Customize_Controls;

                                    Control : constant Wp_Sidebar_Block_Editor_Control :=
                                      X_Construct (
                                        This.Manager,
                                        Setting_Id,
                                        To_Array (List => (
                                          Build ("section",     -Section_Id),
                                          Build ("sidebar_id",  Sidebar_Id),
                                          Build ("label",       As_String (Get (Section_Args, "title"))),
                                          Build ("description", As_String (Get (Section_Args, "description")))
                                        ))
                                      );
                                 begin
                                    This.Manager.Add_Control
                                      (Wp_Customize_Control (Control));
                                 end;
                              else
                                 declare
                                    use Cust_Class_Wp_Widget_Area_Customize_Controls;
                                    use Class_Customize_Controls;

                                    Control : constant Wp_Widget_Area_Customize_Control :=
                                      X_Construct (
                                        This.Manager,
                                        Setting_Id,
                                        To_Array (List => (
                                          Build ("section",    -Section_Id),
                                          Build ("sidebar_id", Sidebar_Id),
                                          Build ("priority",   Natural (Sidebar_Widget_Ids.Length))
                                          -- place "Add Widget" and "Reorder" buttons at end.
                                        ))
                                      );
                                 begin
                                    This.Manager.Add_Control
                                      (Wp_Customize_Control (Control));
                                 end;
                              end if;
                              New_Setting_Ids.Append (+Setting_Id);
                           end;
                        end if;
                     end;
                  end;
               end if;

               if not Use_Widgets_Block_Editor then
                  -- Add a control for each active widget (located in a sidebar).
                  for A in Sidebar_Widget_Ids.Iterate loop
                     declare
                        I         : constant String := Key (A);
                        Widget_Id : constant String := As_String (Element (A));
                     begin
                        -- Skip widgets that may have gone away due to a plugin being
                        -- deactivated.
                        if
                          not Is_Active_Sidebar or not
                          Isset (Global_Wp_Registered_Widgets, Widget_Id)
                        then
                           goto Continue;
                        end if;

                        declare
                           use Cust_Class_Wp_Widget_Form_Customize_Controls;
                           use Class_Customize_Controls;

                           Registered_Widget : constant Array_Type :=
                             As_Array (Get (Global_Wp_Registered_Widgets, Widget_Id));

                           Setting_Id : constant String  :=
                             This.Get_Setting_Id (Widget_Id);

                           Id_Base : constant String  :=
                             As_String (Get (Ref_2 (
                                         Global_Wp_Registered_Widget_Controls,
                                         Key_1 => Widget_Id,
                                         Key_2 => "id_base")));

                           Width : constant String :=
                             As_String (Get (Ref_2 (
                                         Global_Wp_Registered_Widget_Controls,
                                         Key_1 => Widget_Id,
                                         Key_2 => "width")));

                           Height : constant String :=
                             As_String (Get (Ref_2 (
                                         Global_Wp_Registered_Widget_Controls,
                                         Key_1 => Widget_Id,
                                         Key_2 => "height")));

                           Control : constant Wp_Widget_Form_Customize_Control :=
                             X_Construct (
                               This.Manager,
                               Setting_Id,
                               To_Array (List => (
                                 Build ("label",          As_String (Get (Registered_Widget, "name"))),
                                 Build ("section",        -Section_Id),
                                 Build ("sidebar_id",     Sidebar_Id),
                                 Build ("widget_id",      Widget_Id),
                                 Build ("widget_id_base", Id_Base),
                                 Build ("priority",       I),
                                 Build ("width",          Width),
                                 Build ("height",         Height),
                                 Build ("is_wide",        This.Is_Wide_Widget (Widget_Id))
                               ))
                             );
                        begin
                           This.Manager.Add_Control
                             (Wp_Customize_Control (Control));
                        end;
                     end;
                     << Continue >>
                  end loop;
               end if;
            end;
         end;
      end loop;

      if This.Manager.Settings_Previewed then -- ()
         for New_Setting_Id of New_Setting_Ids loop
            declare
               use Class_Customize_Settings;

               Setting : Wp_Customize_Setting :=
                 This.Manager.Get_Setting (-New_Setting_Id);
            begin
               Setting.Preview;
            end;
         end loop;
      end if;
   end Customize_Register;

   ---------------------
   -- Is_Panel_Active --
   ---------------------

   function Is_Panel_Active (This : Wp_Customize_Widgets)
                             return Boolean
   is
   begin
      return not Global_Wp_Registered_Sidebars.Is_Empty;
   end Is_Panel_Active;

   --------------------
   -- Get_Setting_Id --
   --------------------

   function Get_Setting_Id (This      : Wp_Customize_Widgets;
                            Widget_Id : String)
                            return String
   is
      use Php.Strings;
      use UStrings;
      use Wp_Common;

      Parsed_Widget_Id : constant Array_Type := This.Parse_Widget_Id (Widget_Id);

      Id_Base : constant String := As_String (Get (Parsed_Widget_Id, "id_base"));
      Number  : constant String := As_String (Get (Parsed_Widget_Id, "number"));

      Setting_Id : UString := +Sprintf ("widget_%s", To_List (Id_Base));
   begin
      if "" /= Number then -- not is_null
         Append (Setting_Id, Sprintf ("[%d]", To_List (Number)));
      end if;
      return -Setting_Id;
   end Get_Setting_Id;

   --------------------
   -- Is_Wide_Widget --
   --------------------

   function Is_Wide_Widget (This      : Wp_Customize_Widgets;
                            Widget_Id : String)
                            return Boolean
   is
      use Php.Lists;
      use Wp_Common;
      use Inc_Plugins;

      Parsed_Widget_Id : constant Array_Type := This.Parse_Widget_Id (Widget_Id);

      Width : constant Natural :=
        As_Integer (Get (Ref_2 (Global_Wp_Registered_Widget_Controls,
                                Key_1 => Widget_Id, Key_2 => "width")));
      Is_Core : constant Boolean :=
        In_List (As_String (Get (Parsed_Widget_Id, "id_base")),
                 This.Core_Widget_Id_Bases, True);

      Is_Wide : constant Boolean := Width > 250 and not Is_Core;
   begin
      --
      -- Filters whether the given widget is considered "wide".
      --
      -- @since 3.9.0
      --
      -- @param bool   is_wide   Whether the widget is wide, Default false.
      -- @param string widget_id Widget ID.
      --
      return Apply_Filters ("is_wide_widget_in_customizer", Is_Wide, Widget_Id);
   end Is_Wide_Widget;

   ---------------------
   -- Parse_Widget_Id --
   ---------------------

   function Parse_Widget_Id (This      : Wp_Customize_Widgets;
                             Widget_Id : String)
                             return Array_Type
   is
      use Php.Preg;

      Parsed : Array_Type := To_Array (List => (
        Build ("number",  Null_Value),
        Build ("id_base", Null_Value)
      ));
      Matches : List_Type;
   begin
      if Preg_Match ("/^(.+)-(\d+)/", Widget_Id, Matches) /= 0 then
         Set (Parsed, "id_base", From_String (-Matches (1)));                  -- [1]
         Set (Parsed, "number",  From_Integer (Integer'Value (-Matches (2)))); -- [2]
      else
         -- Likely an old single widget.
         Set (Parsed, "id_base", From_String (Widget_Id));
      end if;
      return Parsed;
   end Parse_Widget_Id;

   ------------------
   -- Print_Styles --
   ------------------

   procedure Print_Styles (This : in out Wp_Customize_Widgets)
   is
      use Inc_Plugins;
   begin
      -- This action is documented in wp-admin/admin-header.php
      Do_Action ("admin_print_styles-widgets.php");
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      -- This action is documented in wp-admin/admin-header.php
      Do_Action ("admin_print_styles");
   end Print_Styles;

   -------------------
   -- Print_Scripts --
   -------------------

   procedure Print_Scripts (This : in out Wp_Customize_Widgets)
   is
      use Inc_Plugins;
   begin
      -- This action is documented in wp-admin/admin-header.php
      Do_Action ("admin_print_scripts-widgets.php");
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      -- This action is documented in wp-admin/admin-header.php
      Do_Action ("admin_print_scripts");
   end Print_Scripts;

   ---------------------
   -- Enqueue_Scripts --
   ---------------------

   procedure Enqueue_Scripts (This : in out Wp_Customize_Widgets)
   is
      use Php.Arrays;
      use Php.HTML;
      use Php.Strings;
      use UStrings;
      use Inc_Functions_Wp_Scripts;
      use Inc_Functions_Wp_Styles;
      use Inc_Functions;
      use Inc_General_Templates;
      use Inc_Plugins;
      use Inc_L10n;
      use Inc_Widgets;

--    global wp_scripts,
--    global wp_registered_sidebars,
--    global wp_registered_widgets;
      Available_Widgets : List_Type; -- Array_Type;
   begin
      Wp_Enqueue_Style  ("customize-widgets");
      Wp_Enqueue_Script ("customize-widgets");

      -- This action is documented in wp-admin/admin-header.php
      Do_Action ("admin_enqueue_scripts", "widgets.php");

      --
      -- Export available widgets with control_tpl removed from model
      -- since plugins need templates to be in the DOM.
      --
      for A in This.Get_Available_Widgets.Iterate loop -- ()
         declare
            use List_Vectors;

            Available_Widget : constant String := Key (A);
            Position : List_Vectors.Cursor :=
              Available_Widgets.Find (+"control_tpl");
         begin
            Available_Widgets.Delete (Position);
            Available_Widgets.Append (+Available_Widget);
         end;
      end loop;

      declare
         Widget_Reorder_Nav_TPL : constant String :=
           Sprintf (
             "<div class=""widget-reorder-nav""><span class=""move-widget"" tabindex=""0"">%1s</span><span class=""move-widget-down"" tabindex=""0"">%2s</span><span class=""move-widget-up"" tabindex=""0"">%3s</span></div>",
             To_List (List => (
               1 => +abs "Move to another area&hellip;",
               2 => +abs "Move down",
               3 => +abs "Move up"
           )));

         Move_Widget_Area_TPL : constant String :=
           Str_Replace (
             To_List (List => (1 => +"{description}",
                               2 => +"{btn}")),
             To_List (List => (
               1 => +abs "Select an area to move this widget into:",
               2 => +X_X ("Move", "Move widget")
             )),
             "<div class=""move-widget-area"">" & NL &
             "    <p class=""description"">{description}</p>" & NL &
             "    <ul class=""widget-area-select"">" & NL &
--           "        <% _.each( sidebars, function ( sidebar ){ %>" & NL &
--           "                <li class="" data-id="<%- sidebar.id %>" title="<%- sidebar.description %>" tabindex="0"><%- sidebar.name %></li>" & NL &
--           "        <% }); %>" & NL &
             "    </ul>" & NL &
             "    <div class=""move-widget-actions"">" & NL &
             "        <button class=""move-widget-btn button"" type=""button"">{btn}</button>" & NL &
             "    </div>" & NL &
             "</div>" & NL
           );

         --
         -- Gather all strings in PHP that may be needed by JS on the client.
         -- Once JS i18n is implemented (in #20491), this can be removed.
         --
         Some_Non_Rendered_Areas_Messages : Array_Type;
         Registered_Sidebar_Count : Natural;
         No_Areas_Shown_Message : UString;
      begin
         Set (Some_Non_Rendered_Areas_Messages, "(1)", -- [1]
              From_String (HTML_Entity_Decode (
                abs "Your theme has 1 other widget area, but this particular page does not display it.",
                ENT_QUOTES,
                Get_Bloginfo ("charset")
              )));
         Registered_Sidebar_Count := Natural (Global_Wp_Registered_Sidebars.Length);

         for Non_Rendered_Count in 2 .. Registered_Sidebar_Count - 1 loop
            Set (Some_Non_Rendered_Areas_Messages, "(Non_Rendered_Count)",  -- []
                 From_String (HTML_Entity_Decode (
                   Sprintf (
                     -- translators: %s: The number of other widget areas registered but not rendered.
                     X_N (
                       "Your theme has %s other widget area, but this particular page does not display it.",
                       "Your theme has %s other widget areas, but this particular page does not display them.",
                       Non_Rendered_Count
                     ),
                     To_List (Number_Format_I18n (Float (Non_Rendered_Count)))
                   ),
                   ENT_QUOTES,
                   Get_Bloginfo ("charset")
                 )));
         end loop;

         if 1 = Registered_Sidebar_Count then
            No_Areas_Shown_Message :=
              +HTML_Entity_Decode (
                Sprintf (
                  abs "Your theme has 1 widget area, but this particular page does not display it.",
                  Args => Empty_List
                ),
                ENT_QUOTES,
                Get_Bloginfo ("charset")
              );
         else
            No_Areas_Shown_Message :=
              +HTML_Entity_Decode (
                Sprintf (
                  -- translators: %s: The total number of widget areas registered.
                  X_N (
                    "Your theme has %s widget area, but this particular page does not display it.",
                    "Your theme has %s widget areas, but this particular page does not display them.",
                    Registered_Sidebar_Count
                  ),
                  To_List (Number_Format_I18n (Float (Registered_Sidebar_Count)))
                ),
                ENT_QUOTES,
                Get_Bloginfo ("charset")
              );
         end if;

         declare
            Settings : constant Array_Type := To_Array (List => (
              Build ("registeredSidebars",
                     Array_Type'(Array_Values (Global_Wp_Registered_Sidebars))),
              Build ("registeredWidgets",   Global_Wp_Registered_Widgets),
              Build ("availableWidgets",    Available_Widgets),
              -- @todo Merge this with registered_widgets.
              Build ("l10n",                        To_Array (List => (
                Build ("saveBtnLabel",     abs "Apply"),
                Build ("saveBtnTooltip",
                       abs "Save and preview changes before publishing them."),
                Build ("removeBtnLabel",   abs "Remove"),
                Build ("removeBtnTooltip",
                       abs "Keep widget settings and move it to the inactive widgets"),
                Build ("error",
                       abs "An error has occurred. Please reload the page and try again."),
                Build ("widgetMovedUp",    abs "Widget moved up"),
                Build ("widgetMovedDown",  abs "Widget moved down"),
                Build ("navigatePreview",  abs "You can navigate to other pages on your site while using the Customizer to view and edit the widgets displayed on those pages."),
                Build ("someAreasShown",   Some_Non_Rendered_Areas_Messages),
                Build ("noAreasShown",     -No_Areas_Shown_Message),
                Build ("reorderModeOn",    abs "Reorder mode enabled"),
                Build ("reorderModeOff",   abs "Reorder mode closed"),
                Build ("reorderLabelOn",   ESC_Attr_XX ("Reorder widgets")),
                -- translators: %d: The number of widgets found.
                Build ("widgetsFound",     abs "Number of widgets found: %d"),
                Build ("noWidgetsFound",   abs "No widgets found.")
              ))),
              Build ("tpl",                         To_Array (List => (
                Build ("widgetReorderNav", Widget_Reorder_Nav_TPL),
                Build ("moveWidgetArea",   Move_Widget_Area_TPL)
              ))),
              Build ("selectiveRefreshableWidgets",
                     This.Get_Selective_Refreshable_Widgets)
            ));

            Registered : constant Array_Type :=
              As_Array (Get (Settings, "registeredWidgets"));
         begin
            for Registered_Widget in Registered.Iterate loop -- & []
               null;
--             Registered_Widget.Delete ("callback");
               -- May not be JSON-serializeable.
            end loop;

            Global_Wp_Scripts.Add_Data (
              "customize-widgets",
              "data",
              Sprintf ("var _wpCustomizeWidgetsSettings = %s;",
                       To_List (Wp_JSON_Encode (From_Array (Settings))))
              );
         end;

         --
         -- TODO: Update "wp-customize-widgets" to not rely so much on things in
         -- "customize-widgets". This will let us skip most of the above and not
         -- enqueue "customize-widgets" which saves bytes.
         --
         if Wp_Use_Widgets_Block_Editor then
            declare
               use Adi_Posts;
               use Inc_Block_Editors;
               use Class_Block_Editor_Contexts;

               Block_Editor_Context : constant Wp_Block_Editor_Context :=
                 X_Construct (
                   To_Array (List => (1 =>
                     Build ("name", "core/customize-widgets")
                   ))
                 );

               Editor_Settings : constant Array_Type := Get_Block_Editor_Settings (
                 Get_Legacy_Widget_Block_Editor_Settings, -- ()
                 Block_Editor_Context
               );
            begin
               Wp_Add_Inline_Script (
                 "wp-customize-widgets",
                 Sprintf (
                   "wp.domReady( function() {" & NL &
                   "   wp.customizeWidgets.initialize( ""widgets-customizer"", %s );" & NL &
                   "} );" & NL,
                   To_List (Wp_JSON_Encode (From_Array (Editor_Settings)))
                 )
               );

               -- Preload server-registered block schemas.
               Wp_Add_Inline_Script (
                 "wp-blocks",
                 "wp.blocks.unstable__bootstrapServerSideBlockDefinitions(" &
                 Wp_JSON_Encode (From_Array (
                   Get_Block_Editor_Server_Block_Settings)) &
                 ");" & NL
               );

               Wp_Add_Inline_Script (
                 "wp-blocks",
                 Sprintf ("wp.blocks.setCategories( %s );",
                          To_List (Wp_JSON_Encode (From_Array (
                                     Get_Block_Categories (Block_Editor_Context))))),
                 "after"
               );

               Wp_Enqueue_Script ("wp-customize-widgets");
               Wp_Enqueue_Style  ("wp-customize-widgets");

               -- This action is documented in edit-form-blocks.php
               Do_Action ("enqueue_block_editor_assets");
            end;
         end if;
      end;
   end Enqueue_Scripts;

   -------------------------------------
   -- Output_Widget_Control_Templates --
   -------------------------------------

   procedure Output_Widget_Control_Templates (This : in out Wp_Customize_Widgets)
   is
      use Php.Echoing;
      use Inc_Formatting;
      use Inc_L10n;
   begin
      Echo ("<div id=""widgets-left""><!-- compatibility with JS which looks for widget templates here -->" & NL);
      Echo ("<div id=""available-widgets"">" & NL);
      Echo ("    <div class=""customize-section-title"">" & NL);
      Echo ("        <button class=""customize-section-back"" tabindex=""-1"">" & NL);
      Echo ("            <span class=""screen-reader-text"">");
      X_E ("Back");
      Echo ("</span>" & NL);
      Echo ("        </button>" & NL);
      Echo ("        <h3>" & NL);
      Echo ("            <span class=""customize-action"">" & NL);
      -- translators: &#9656; is the unicode right-pointing triangle. %s: Section title in the Customizer.
      Printf (abs "Customizing &#9656; %s",
              To_List (ESC_HTML (-This.Manager.Get_Panel ("widgets").Title)));
      Echo ("            </span>" & NL);
      Echo ("            ");
      X_E ("Add a Widget");
      Echo ("        </h3>" & NL);
      Echo ("    </div>" & NL);
      Echo ("    <div id=""available-widgets-filter"">" & NL);
      Echo ("       <label class=""screen-reader-text"" for=""widgets-search"">");
      X_E ("Search Widgets");
      Echo ("</label>" & NL);
      Echo ("       <input type=""text"" id=""widgets-search"" placeholder=""");
      ESC_Attr_E ("Search widgets&hellip;");
      Echo (""" aria-describedby=""widgets-search-desc"" />" & NL);
      Echo ("       <div class=""search-icon"" aria-hidden=""true""></div>" & NL);
      Echo ("        <button type=""button"" class=""clear-results""><span class=""screen-reader-text"">");
      X_E ("Clear Results");
      Echo ("</span></button>" & NL);
      Echo ("        <p class=""screen-reader-text"" id=""widgets-search-desc"">");
      X_E ("The search results will be updated as you type.");
      Echo ("</p>" & NL);
      Echo ("    </div>" & NL);
      Echo ("    <div id=""available-widgets-list"">" & NL);
      for A in This.Get_Available_Widgets.Iterate loop
         declare
            Available_Widget : constant Array_Type :=
              As_Array (Arrays.Element (A));

            Id  : constant String :=
              ESC_Attr (As_String (Get (Available_Widget, "id"))); -- []

            TPL : constant String :=
              As_String (Get (Available_Widget, "control_tpl")); -- []
         begin
            Echo ("        <div id=""widget-tpl-" & Id &
                  " data-widget-id=""" & Id &
                  """ class=""widget-tpl " & Id &
                  " tabindex=""0"">" & NL);
            Echo (TPL);
            Echo ("        </div>" & NL);
         end;
      end loop;
      Echo ("    <p class=""no-widgets-found-message"">");
      X_E ("No widgets found.");
      Echo ("</p>" & NL);
      Echo ("    </div><!-- #available-widgets-list -->" & NL);
      Echo ("</div><!-- #available-widgets -->" & NL);
      Echo ("</div><!-- #widgets-left -->" & NL);
   end Output_Widget_Control_Templates;

   --------------------------
   -- Print_Footer_Scripts --
   --------------------------

   procedure Print_Footer_Scripts (This : in out Wp_Customize_Widgets)
   is
      use Inc_Plugins;
   begin
      -- This action is documented in wp-admin/admin-footer.php
      Do_Action ("admin_print_footer_scripts-widgets.php");
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores

      -- This action is documented in wp-admin/admin-footer.php
      Do_Action ("admin_print_footer_scripts");

      -- This action is documented in wp-admin/admin-footer.php
      Do_Action ("admin_footer-widgets.php");
      -- phpcs:ignore WordPress.NamingConventions.ValidHookName.UseUnderscores
   end Print_Footer_Scripts;

   ----------------------
   -- Set_Setting_Args --
   ----------------------

   function Get_Setting_Args (This      : in out Wp_Customize_Widgets;
                              Id        : String;
                              Overrides : Array_Type := Empty_Array)
                              return Array_Type
   is
      use Php.Arrays;
      use Php.Preg;
      use Wp_Common;
      use Inc_Plugins;
      use Inc_Themes;

      Args : Array_Type := To_Array (List => (
        Build ("type",       "option"),
        Build ("capability", "edit_theme_options"),
        Build ("default",    Empty_Array)
      ));

      Pattern_Widgets : constant String :=
        As_String (Get (This.Setting_Id_Patterns, "sidebar_widgets"));

      Pattern_Instance : constant String :=
        As_String (Get (This.Setting_Id_Patterns, "widget_instance"));

      Matches : List_Type;
   begin
      if Preg_Match (Pattern_Widgets, Id, Matches) /= 0 then
         Set (Args, "sanitize_callback", From_Callable (
              To_Array (This, Sanitize_Sidebar_Widgets'Access)));

         Set (Args, "sanitize_js_callback", From_Callable (
              To_Array (This, Sanitize_Sidebar_Widgets_JS_Instance'Access)));

         Set (Args, "transport", From_String
              (if Current_Theme_Supports ("customize-selective-refresh-widgets")
               then "postMessage" else "refresh"));

      elsif Preg_Match (Pattern_Instance, Id, Matches) /= 0 then
         declare
            Id_Base : constant String := "XXX-013";
            -- As_String (Get (Matches, "id_base"));
         begin
            -- args["sanitize_callback"]    = function( value ) use ( id_base ) {
            --    return this.sanitize_widget_instance( value, id_base );
            -- };
            -- args["sanitize_js_callback"] = function( value ) use ( id_base ) {
            --    return this.sanitize_widget_js_instance( value, id_base );
            -- };
            Set (Args, "transport", From_String
                 (if This.Is_Widget_Selective_Refreshable (Id_Base) -- matches["id_base"])
                  then "postMessage" else "refresh"));
         end;
      end if;

      Args := Array_Merge (Args, Overrides);

      --
      -- Filters the common arguments supplied when constructing a Customizer setting.
      --
      -- @since 3.9.0
      --
      -- @see WP_Customize_Setting
      --
      -- @param array  args Array of Customizer setting arguments.
      -- @param string id   Widget setting ID.
      --
      return Apply_Filters ("widget_customizer_setting_args", Args, Id);
   end Get_Setting_Args;

   ------------------------------
   -- Sanitize_Sidebar_Widgets --
   ------------------------------

   function Sanitize_Sidebar_Widgets (This       : Wp_Customize_Widgets;
                                      Widget_Ids : List_Type)
                                      return List_Type
   is
      use Php.Lists;
      use Php.Strings;
      use Php.Preg;

      Widget_Ids_2 : constant List_Type :=
        List_Map (Strval'Access, Widget_Ids); -- (arrays)

      Sanitized_Widget_Ids : List_Type;
   begin
      for Widget_Id of Widget_Ids_2 loop
         Sanitized_Widget_Ids.Append
           (+Preg_Replace ("/[^a-z0-9_\-]/", "", -Widget_Id));
      end loop;
      return Sanitized_Widget_Ids;
   end Sanitize_Sidebar_Widgets;

   procedure Sanitize_Sidebar_Widgets (This : in out Wp_Customize_Widgets)
   is null;

   ---------------------------
   -- Get_Available_Widgets --
   ---------------------------

   Static_Available_Widgets : Array_Type;

   function Get_Available_Widgets (This : in out Wp_Customize_Widgets)
                                   return Array_Type
   is
      use Php.Arrays;
      use Php.Sorting;
      use Adi_Widgets;
      use Inc_Widgets;

--    global wp_registered_widgets, wp_registered_widget_controls;
   begin
      if not Static_Available_Widgets.Is_Empty then
         return Static_Available_Widgets;
      end if;

      declare
         Sort : Array_Type := Global_Wp_Registered_Widgets;
         Done : Array_Type;
      begin
         USort (Sort, Adi_Widgets.X_Sort_Name_Callback'Access);
--       USort (Sort, To_array (This, "_sort_name_callback"));

         for A in Sort.Iterate loop
            declare
               Widget : Array_Type := As_Array (Element (A));
            begin
               if
                 In_Array (As_String (Get (Widget, "callback")),
                           Done, True)
               then
                  -- We already showed this multi-widget.
                  goto Continue;
               end if;

               declare
                  Sidebar : constant String :=
                    Is_Active_Widget (As_Callable (Get (Widget, "callback")),
                                      As_String (Get (Widget, "id")),
                                      "", False); -- "" was False
               begin
                  Done.Append (Get (Widget, "callback"));

                  if not Isset_2 (Widget, "params", "[0]") then
                     Set_2 (Widget, "params", "[0]", From_Array (Empty_Array));
                  end if;

                  declare
                     Available_Widget : Array_Type := Widget;
                  begin
                     Delete (Ref (Available_Widget, "callback"));
                     -- Not serializable to JSON.
                     declare
                        Args : Array_Type := To_Array (List => (
                          Build ("widget_id",   As_String (Get (Widget, "id"))),
                          Build ("widget_name", As_String (Get (Widget, "name"))),
                          Build ("_display",    "template")
                        ));

                        Is_Disabled : Boolean := False;

                        Key_Id : constant String :=
                           As_String (Get (Widget, "id"));

                        Is_Multi_Widget : constant Boolean :=
                          Isset_2 (Global_Wp_Registered_Widget_Controls,
                                   Key_Id, "id_base") and then
                          Isset_3 (Widget, "params", "[0]", "number");

                        Id_Base : UString;
                     begin
                        if Is_Multi_Widget then
                           Id_Base := +As_String (
                             Get (Ref_2 (Global_Wp_Registered_Widget_Controls,
                                         Key_Id, "id_base")));
                           Set (Args, "_temp_id",
                                From_String ((-Id_Base) & "-__i__"));

                           Set (Args, "_multi_num",
                                From_Integer (Next_Widget_Id_Number (-Id_Base)));

                           Set (Args, "_add", From_String ("multi"));
                        else
                           Set (Args, "_add", From_String ("single"));

                           if
                             Sidebar /= "" and then
                             Sidebar /= "wp_inactive_widgets"
                           then
                              Is_Disabled := True;
                           end if;
                           Id_Base := +As_String (Get (Widget, "id"));
                        end if;

                        declare
                           List_Widget_Controls_Args : constant Array_Type :=
                              Wp_List_Widget_Controls_Dynamic_Sidebar (
                                To_Array (List => (
                                  Build ("0", Args), -- "" added
                                  Build ("1",
                                         As_String (Get (Ref_2 (Widget, "params", "[0]"))))
                                ))
                              );

                           Control_TPL : constant String :=
                             This.Get_Widget_Control (List_Widget_Controls_Args);

                           Id : constant String := As_String (Get (Widget, "id"));

                           Width : constant String :=
                             As_String (Get (Ref_2 (Global_Wp_Registered_Widget_Controls,
                                                     Key_1 => Id, Key_2 => "width")));

                           Height : constant String :=
                             As_String (Get (Ref_2 (Global_Wp_Registered_Widget_Controls,
                                                     Key_1 => Id, Key_2 => "height")));
                        begin
                           -- The properties here are mapped to the Backbone Widget
                           -- model.
                           Available_Widget :=
                             Array_Merge (
                               Available_Widget,
                               To_Array (List => (

                                 Build ("temp_id",
                                        (if Isset (Args, "_temp_id")
                                         then As_String (Get (Args, "_temp_id"))
                                         else "")), -- null

                                 Build ("is_multi",     Is_Multi_Widget),
                                 Build ("control_tpl",  Control_TPL),

                                 Build ("multi_number",
                                        (if "multi" = As_String (Get (Args, "_add"))
                                         then As_String (Get (Args, "_multi_num"))
                                         else "")), -- False

                                 Build ("is_disabled",  Is_Disabled),
                                 Build ("id_base",      -Id_Base),
                                 Build ("transport",
                                        (if This.Is_Widget_Selective_Refreshable (-Id_Base)
                                         then "postMessage" else "refresh")),
                                 Build ("width",        Width),
                                 Build ("height",       Height),
                                 Build ("is_wide",      This.Is_Wide_Widget (Id))
                               ))
                             );

                           Static_Available_Widgets.Append
                             (From_Array (Available_Widget));
                        end;
                     end;
                  end;
               end;
            end;
            << Continue >>
         end loop;
      end;
      return Static_Available_Widgets;
   end Get_Available_Widgets;

   ------------------------
   -- Get_Widget_Control --
   ------------------------

   function Get_Widget_Control (This : Wp_Customize_Widgets;
                                Args : Array_Type)
                                return String
   is
   begin
      -- args[0]["before_form"]           = "<div class=""form"">";
      -- args[0]["after_form"]            = "</div><!-- .form -->";
      -- args[0]["before_widget_content"] = "<div class=""widget-content"">";
      -- args[0]["after_widget_content"]  = "</div><!-- .widget-content -->";
      -- ob_start();
      -- wp_widget_control( ...args );
      -- control_tpl = ob_get_clean();
      -- return control_tpl;
      return "XXX-014";
   end Get_Widget_Control;

   ----------------------------
   -- Customize_Preview_Init --
   ----------------------------

   procedure Customize_Preview_Init (This : in out Wp_Customize_Widgets)
   is
      use Inc_Plugins;
   begin
      Add_Action ("wp_enqueue_scripts",
                  To_Array (This, Customize_Preview_Enqueue'Access));

      Add_Action ("wp_print_styles",
                  To_Array (This, Print_Preview_CSS'Access), 1);

      Add_Action ("wp_footer",
                  To_Array (This, Export_Preview_Data'Access), 20);
   end Customize_Preview_Init;

   --------------------
   -- Refresh_Nonces --
   --------------------

   function Refresh_Nonces (This   : Wp_Customize_Widgets;
                            Nonces : Array_Type)
                            return Array_Type
   is
      use Inc_Pluggables;

      Nonces_2 : Array_Type := Nonces;
   begin
      Set (Nonces_2, "update-widget", From_String (
           Wp_Create_Nonce ("update-widget")));

      return Nonces_2;
   end Refresh_Nonces;

   procedure Refresh_Nonces (This : in out Wp_Customize_Widgets)
   is
   begin
      null;
   end Refresh_Nonces;

   -------------------------------------------------
   -- Should_Load_Block_Editor_Scripts_And_Styles --
   -------------------------------------------------

   function Should_Load_Block_Editor_Scripts_And_Styles
              (This                   : Wp_Customize_Widgets;
               Is_Block_Editor_Screen : Boolean)
               return Boolean
   is
      use Inc_Widgets;
   begin
      if Wp_Use_Widgets_Block_Editor then
         return True;
      end if;

      return Is_Block_Editor_Screen;
   end Should_Load_Block_Editor_Scripts_And_Styles;

   procedure Should_Load_Block_Editor_Scripts_And_Styles
               (This : in out Wp_Customize_Widgets)
   is null;

   ------------------------------
   -- Preview_Sidebars_Widgets --
   ------------------------------

   function Preview_Sidebars_Widgets (This             : Wp_Customize_Widgets;
                                      Sidebars_Widgets : Array_Type)
                                      return Array_Type
   is
      use Inc_Options;

      Sidebars_Widgets_2 : constant Array_Type :=
        Get_Option ("sidebars_widgets", Empty_Array);
   begin
      Delete (Ref (Sidebars_Widgets_2, "array_version"));
      return Sidebars_Widgets_2;
   end Preview_Sidebars_Widgets;

   procedure Preview_Sidebars_Widgets (This : in out Wp_Customize_Widgets)
   is null;

   -------------------------------
   -- Customize_Preview_Enqueue --
   -------------------------------

   procedure Customize_Preview_Enqueue (This : in out Wp_Customize_Widgets)
   is
      use Inc_Functions_Wp_Scripts;
   begin
      Wp_Enqueue_Script ("customize-preview-widgets");
   end Customize_Preview_Enqueue;

   -----------------------
   -- Print_Preview_CSS --
   -----------------------

   procedure Print_Preview_CSS (This : in out Wp_Customize_Widgets)
   is
      use Php.Echoing;
   begin
      Echo ("<style>" & NL);
      Echo (".widget-customizer-highlighted-widget {" & NL);
      Echo ("        outline: none;" & NL);
      Echo ("        -webkit-box-shadow: 0 0 2px rgba(30, 140, 190, 0.8);" & NL);
      Echo ("        box-shadow: 0 0 2px rgba(30, 140, 190, 0.8);" & NL);
      Echo ("        position: relative;" & NL);
      Echo ("        z-index: 1;" & NL);
      Echo ("}" & NL);
      Echo ("</style>" & NL);
   end Print_Preview_CSS;

   -------------------------
   -- Export_Preview_Data --
   -------------------------

   procedure Export_Preview_Data (This : in out Wp_Customize_Widgets)
   is
      use Php.Arrays;
      use Php.Echoing;
      use Inc_Functions;
      use Inc_L10n;

      Switched_Locale : constant Boolean :=
        Switch_To_Locale (Get_User_Locale);

      L10n : constant Array_Type := To_Array (List => (1 =>
        Build ("widgetTooltip", abs "Shift-click to edit this widget.")
      ));
   begin
      if Switched_Locale then
         Restore_Previous_Locale;
      end if;

      declare
         Rendered_Sidebars : constant Array_Type :=
           Array_Filter (This.Rendered_Sidebars);

         Rendered_Widgets  : constant Array_Type :=
           Array_Filter (This.Rendered_Widgets);

         -- Prepare Customizer settings to pass to JavaScript.
         Settings : constant Array_Type := To_Array (List => (
           Build ("renderedSidebars",
                  Array_Fill_Keys (Array_Keys (Rendered_Sidebars),
                                   From_Boolean (True))),

           Build ("renderedWidgets",
                  Array_Fill_Keys (Array_Keys (Rendered_Widgets),
                                   From_Boolean (True))),

           Build ("registeredSidebars",
                  Array_Type'(Array_Values (Global_Wp_Registered_Sidebars))),

           Build ("registeredWidgets",   Global_Wp_Registered_Widgets),
           Build ("l10n",                L10n),
           Build ("selectiveRefreshableWidgets",
                  This.Get_Selective_Refreshable_Widgets)
         ));
      begin
         for
           A in
           As_Array (Get (Settings, "registeredWidgets")).Iterate
         loop -- &
            declare
               Registered_Widget : constant Multi_Type := Element (A);
            begin
               Delete (Ref (As_Array (Registered_Widget), "callback"));
               -- May not be JSON-serializeable.
            end;
         end loop;

         Echo ("<script type=""text/javascript"">" & NL);
         Echo ("        var _wpWidgetCustomizerPreviewSettings = " &
               Wp_JSON_Encode (From_Array (Settings)) & ";" & NL);
         Echo ("</script>" & NL);
      end;
   end Export_Preview_Data;

   ----------------------------
   -- Tally_Rendered_Widgets --
   ----------------------------

   procedure Tally_Rendered_Widgets (This   : in out Wp_Customize_Widgets;
                                     Widget : Array_Type)
   is
      Id : constant String := As_String (Get (Widget, "id"));
   begin
      Set (This.Rendered_Widgets, Id, From_Boolean (True));
   end Tally_Rendered_Widgets;

   procedure Tally_Rendered_Widgets (This : in out Wp_Customize_Widgets)
   is null;

   ------------------------------------------------
   -- Tally_Sidebars_Via_Is_Active_Sidebar_Calls --
   ------------------------------------------------

   function Tally_Sidebars_Via_Is_Active_Sidebar_Calls
              (This       : in out Wp_Customize_Widgets;
               Is_Active  : Boolean;
               Sidebar_Id : String)
               return Boolean
   is
      use Inc_Widgets;
   begin
      if Is_Registered_Sidebar (Sidebar_Id) then
         Set (This.Rendered_Sidebars, Sidebar_Id, From_Boolean (True)); -- []
      end if;

      --
      -- We may need to force this to true, and also force-true the value
      -- for "dynamic_sidebar_has_widgets" if we want to ensure that there
      -- is an area to drop widgets into, if the sidebar is empty.
      --
      return Is_Active;
   end Tally_Sidebars_Via_Is_Active_Sidebar_Calls;

   procedure Tally_Sidebars_Via_Is_Active_Sidebar_Calls
               (This : in out Wp_Customize_Widgets)
   is null;

   ----------------------------------------------
   -- Tally_Sidebars_Via_Dynamic_Sidebar_Calls --
   ----------------------------------------------

   function Tally_Sidebars_Via_Dynamic_Sidebar_Calls
              (This        : in out Wp_Customize_Widgets;
               Has_Widgets : Boolean;
               Sidebar_Id  : String)
               return Boolean
   is
      use Inc_Widgets;
   begin
      if Is_Registered_Sidebar (Sidebar_Id) then
         Set (This.Rendered_Sidebars, Sidebar_Id, From_Boolean (True)); -- []
      end if;

      --
      -- We may need to force this to true, and also force-true the value
      -- for "is_active_sidebar" if we want to ensure there is an area to
      -- drop widgets into, if the sidebar is empty.
      --
      return Has_Widgets;
   end Tally_Sidebars_Via_Dynamic_Sidebar_Calls;

   procedure Tally_Sidebars_Via_Dynamic_Sidebar_Calls
               (This : in out Wp_Customize_Widgets)
   is null;

   -------------------------------------------
   -- Sanitize_Sidebar_Widgets_JS_Instance --
   ------------------------------------------

   function Sanitize_Sidebar_Widgets_JS_Instance (This : Wp_Customize_Widgets;
                                                  Widget_Ids : Array_Type)
                                                  return Array_Type
   is
      use Php.Arrays;

      Widget_Ids_2 : constant Array_Type :=
        Array_Values (
          Array_Intersect (Widget_Ids,
                           Array_Keys (Global_Wp_Registered_Widgets)));
   begin
      return Widget_Ids_2;
   end Sanitize_Sidebar_Widgets_JS_Instance;

   procedure Sanitize_Sidebar_Widgets_JS_Instance
               (This : in out Wp_Customize_Widgets)
   is null;

   ------------------------------------
   -- Customize_Dynamic_Partial_Args --
   ------------------------------------

   function Customize_Dynamic_Partial_Args (This         : Wp_Customize_Widgets;
                                            Partial_Args : Array_Type;
                                            Partial_Id   : String)
                                            return Array_Type
   is
      use Php.Arrays;
      use Php.Preg;
      use Inc_Themes;

      Matches : List_Type;
      Partial_Args_2 : Array_Type;
   begin
      if not Current_Theme_Supports ("customize-selective-refresh-widgets") then
         return Partial_Args;
      end if;

      if Preg_Match ("/^widget\[(?P<widget_id>.+)\]/", Partial_Id, Matches) /= 0 then
         if Empty_Array = Partial_Args then
            Partial_Args_2 := Empty_Array;
         end if;

         Partial_Args_2 :=
           Array_Merge (
             Partial_Args,
             To_Array (List => (
               Build ("type",                "widget"),
               Build ("render_callback",
                      To_Array (This, Render_Widget_Partial'Access)),
               Build ("container_inclusive", True),
               Build ("settings",
                      This.Get_Setting_Id ("XXX-016")),
                      -- Matches ("widget_id"))), -- []
               Build ("capability",          "edit_theme_options")
             ))
           );
      end if;

      return Partial_Args_2;
   end Customize_Dynamic_Partial_Args;

   procedure Customize_Dynamic_Partial_Args (This : in out Wp_Customize_Widgets)
   is null;

   ----------------------------
   -- Selective_Refresh_Init --
   ----------------------------

   procedure Selective_Refresh_Init (This : in out Wp_Customize_Widgets)
   is
      use Inc_Themes;
      use Inc_Plugins;
   begin
      if not Current_Theme_Supports ("customize-selective-refresh-widgets") then
         return;
      end if;

      Add_Filter ("dynamic_sidebar_params",
                  To_Array (This, Filter_Dynamic_Sidebar_Params'Access));

      Add_Filter ("wp_kses_allowed_html",
                  To_Array (This, Filter_Wp_KSES_Allowed_Data_Attributes'Access));

      Add_Action ("dynamic_sidebar_before",
                  To_Array (This, Start_Dynamic_Sidebar'Access));

      Add_Action ("dynamic_sidebar_after",
                  To_Array (This, End_Dynamic_Sidebar'Access));
   end Selective_Refresh_Init;

   -----------------------------------
   -- Filter_Dynamic_Sidebar_Params --
   -----------------------------------

   function Filter_Dynamic_Sidebar_Params (This   : in out Wp_Customize_Widgets;
                                           Params : Array_Type)
                                           return Array_Type
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Preg;
      use Php.Strings;
      use Inc_Formatting;
      use Inc_Functions;
      use Inc_Widgets;

      Params_2 : Array_Type := Params;

      Sidebar_Args : Array_Type := Array_Merge (
        To_Array (List => (
          Build ("before_widget", ""),
          Build ("after_widget",  "")
        )),
        As_Array (Get (Params_2, "[0]"))
      );

      -- Skip widgets not in a registered sidebar or ones which lack a proper wrapper
      -- element to attach the data-* attributes to.
      Matches : Array_Type;

      Is_Valid : constant Boolean :=
        Isset (Sidebar_Args, "id") and then
        Is_Registered_Sidebar (As_String (Get (Sidebar_Args, "id"))) and then
        (Isset (This.Current_Dynamic_Sidebar_Id_Stack, "[0]") and then
         Get (This.Current_Dynamic_Sidebar_Id_Stack, "[0]")
         = As_String (Get (Sidebar_Args, "id"))) and then
         Preg_Match ("#^<(?P<tag_name>\w+)#",
                     As_String (Get (Sidebar_Args, "before_widget")),
                     Matches) /= 0;
   begin
      if not Is_Valid then
         return Params_2;
      end if;

      Set (This.Before_Widget_Tags_Seen,
           Key   => As_String (Get (Matches, "tag_name")),
           Value => From_Boolean (True));

      declare
         Context : Array_Type :=
           To_Array (List => (1 =>
             Build ("sidebar_id", As_String (Get (Sidebar_Args, "id")))
           ));

--         Attributes : Unbounded_String;
      begin
         if This.Context_Sidebar_Instance_Number_Set then
            Set (Context, "sidebar_instance_number",
                 From_Integer (This.Context_Sidebar_Instance_Number));
         elsif
           Isset (Sidebar_Args, "id") and then
           Isset (This.Sidebar_Instance_Count,
                  As_String (Get (Sidebar_Args, "id")))
         then
            Set (Context, "sidebar_instance_number",
                 Get (This.Sidebar_Instance_Count,
                      As_String (Get (Sidebar_Args, "id"))));
         end if;

         declare
            Widget_Id : constant String :=
              As_String (Get (Sidebar_Args, "widget_id"));

            Before_Widget : constant String :=
              As_String (Get (Sidebar_Args, "before_widget"));

            Attributes : constant String :=
              Sprintf (" data-customize-partial-id=""%s""",
                       To_List (ESC_Attr ("widget[" & Widget_Id & "]"))) &

              " data-customize-partial-type=""widget""" &

              Sprintf (" data-customize-partial-placement-context=""%s""",
                       To_List (ESC_Attr (Wp_JSON_Encode (From_Array (Context))))) &

              Sprintf (" data-customize-widget-id=""%s""",
                       To_List (ESC_Attr (Widget_Id)));
         begin
            Set (Sidebar_Args, "before_widget",
                 From_String (Preg_Replace ("#^(<\w+)#", "1 " & Attributes,
                               Before_Widget)));

            Set (Params_2, "[0]", From_Array (Sidebar_Args));

            return Params_2;
         end;
      end;
   end Filter_Dynamic_Sidebar_Params;

   procedure Filter_Dynamic_Sidebar_Params (This : in out Wp_Customize_Widgets)
   is null;

   --------------------------------------------
   -- Filter_Wp_KSES_Allowed_Data_Attributes --
   --------------------------------------------

   function Filter_Wp_KSES_Allowed_Data_Attributes
              (This         : Wp_Customize_Widgets;
               Allowed_HTML : Array_Type)
               return Array_Type
   is
      use Php.Arrays;

      Allowed_HTML_2 : Array_Type := Allowed_HTML;
   begin
      for Tag_Name of List_Type'(Array_Keys (This.Before_Widget_Tags_Seen)) loop
--       if List_Vectors.Has_Element (Allowed_HTML_2.Find (-Tag_Name)) then
         if not Isset (Allowed_HTML_2, -Tag_Name) then
            Set (Allowed_HTML_2, -Tag_Name, From_Array (Empty_Array));
         end if;

         Set (Allowed_HTML_2, -Tag_Name, From_Array (
              Array_Merge (
                As_Array (Get (Allowed_HTML_2, -Tag_Name)),
                Array_Fill_Keys (
                  To_List (List => (
                    +"data-customize-partial-id",
                    +"data-customize-partial-type",
                    +"data-customize-partial-placement-context",
                    +"data-customize-partial-widget-id",
                    +"data-customize-partial-options"
                  )),
                  From_Boolean (True)
                )
              )));
      end loop;
      return Allowed_HTML_2;
   end Filter_Wp_KSES_Allowed_Data_Attributes;

   procedure Filter_Wp_KSES_Allowed_Data_Attributes
               (This : in out Wp_Customize_Widgets)
   is null;

   ---------------------------
   -- Start_Dynamic_Sidebar --
   ---------------------------

   procedure Start_Dynamic_Sidebar (This  : in out Wp_Customize_Widgets;
                                    Index : String)
   is
      use Php.Echoing;
      use Php.Lists;
      use Inc_Formatting;
   begin
      List_Unshift (This.Current_Dynamic_Sidebar_Id_Stack, Index);

      if not Isset (This.Sidebar_Instance_Count, Index) then
         Set (This.Sidebar_Instance_Count, Index, From_Integer (0));
      end if;

      Set (This.Sidebar_Instance_Count, Index, From_Integer (
           As_Integer (Get (This.Sidebar_Instance_Count, Index)) + 1));

      if not This.Manager.Selective_Refresh.Is_Render_Partials_Request then -- ()
         Printf ("\n<!--dynamic_sidebar_before:%s:%d-->\n",
                 To_List (List => (
                   1 => +ESC_HTML (Index),
                   2 => +As_String (Get (This.Sidebar_Instance_Count, Index)))
                 ));
      end if;
   end Start_Dynamic_Sidebar;

   procedure Start_Dynamic_Sidebar (This : in out Wp_Customize_Widgets)
   is null;

   -------------------------
   -- End_Dynamic_Sidebar --
   -------------------------

   procedure End_Dynamic_Sidebar (This  : in out Wp_Customize_Widgets;
                                  Index : String)
   is
      use Php.Echoing;
      use Php.Lists;
      use Inc_Formatting;
   begin
      List_Shift (This.Current_Dynamic_Sidebar_Id_Stack);

      if not This.Manager.Selective_Refresh.Is_Render_Partials_Request then
         Printf ("\n<!--dynamic_sidebar_after:%s:%d-->\n",
                 To_List (List => (
                   1 => +ESC_HTML (Index),
                   2 => +As_String (Get (This.Sidebar_Instance_Count, Index))
                 ))
                );
      end if;
   end End_Dynamic_Sidebar;

   procedure End_Dynamic_Sidebar (This : in out Wp_Customize_Widgets)
   is null;

   --------------------------------------------------
   -- Filter_Sidebars_Widgets_For_Rendering_Widget --
   --------------------------------------------------

   function Filter_Sidebars_Widgets_For_Rendering_Widget
              (This             : in out Wp_Customize_Widgets;
               Sidebars_Widgets : Array_Type)
               return Array_Type
   is
      Widgets : Array_Type := Sidebars_Widgets;
   begin
      Set (Widgets, -This.Rendering_Sidebar_Id, -- array(
           From_String (-This.Rendering_Widget_Id));
      return Widgets;
   end Filter_Sidebars_Widgets_For_Rendering_Widget;

   procedure Filter_Sidebars_Widgets_For_Rendering_Widget
              (This : in out Wp_Customize_Widgets)
   is null;

   procedure Filter_Sidebars_Widgets_For_Rendering_Widget
   is null;

   ---------------------------
   -- Render_Widget_Partial --
   ---------------------------

   function Render_Widget_Partial
              (This    : in out Wp_Customize_Widgets;
               Partial : Cust_Class_Wp_Customize_Partials.Wp_Customize_Partial;
               Context : Array_Type)
               return String
   is
      use Php.Echoing;
      use Php.Lists;
      use Inc_Plugins;
      use Inc_Widgets;

      Id_Data   : Array_Type      := Partial.Id_Data; -- ()
      List      : List_Type       := As_List (Get (Id_Data, "keys"));
      Widget_Id : constant String := List_Shift (List);
   begin
      Set (Id_Data, From_List (List));

      if
--      not Is_Array (Context)        or else
        Empty (Context, "sidebar_id") or else
        not Is_Registered_Sidebar (As_String (Get (Context, "sidebar_id")))
      then
         return ""; -- false;
      end if;

      This.Rendering_Sidebar_Id := +As_String (Get (Context, "sidebar_id"));

      if Isset (Context, "sidebar_instance_number") then
         This.Context_Sidebar_Instance_Number :=
           As_Integer (Get (Context, "sidebar_instance_number"));
      end if;

      -- Filter sidebars_widgets so that only the queried widget is in the sidebar.
      This.Rendering_Widget_Id := +Widget_Id;

      declare
         Filter_Callback : constant Arrays.Callable :=
           To_Array (This, Filter_Sidebars_Widgets_For_Rendering_Widget'Access);
      begin
         Add_Filter ("sidebars_widgets", Filter_Callback, 1000);

         -- Render the widget.
         OB_Start;
         This.Rendering_Sidebar_Id := +As_String (Get (Context, "sidebar_id"));
         Dynamic_Sidebar (-This.Rendering_Sidebar_Id);
         declare
            Container : constant String := OB_Get_Clean;
         begin
            -- Reset variables for next partial render.
            Remove_Filter ("sidebars_widgets",
                           Filter_Sidebars_Widgets_For_Rendering_Widget'Access,
                           1000);
--          Remove_Filter ("sidebars_widgets", Filter_Callback, 1000);

            This.Context_Sidebar_Instance_Number_Set := False;
            This.Context_Sidebar_Instance_Number     := 0;
            This.Rendering_Sidebar_Id                := +""; -- null
            This.Rendering_Widget_Id                 := +""; -- null

            return Container;
         end;
      end;
   end Render_Widget_Partial;

   procedure Render_Widget_Partial
               (This : in out Wp_Customize_Widgets)
   is null;

end Class_Customize_Widgets;
