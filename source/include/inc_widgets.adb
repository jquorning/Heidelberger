--
-- Core Widgets API
--
-- This API is used for creating dynamic sidebar without hardcoding functionality into
-- themes
--
-- Includes both internal WordPress routines and theme-use routines.
--
-- This functionality was found in a plugin before the WordPress 2.2 release, which
-- included it in the core from that point on.
--
-- @link https://wordpress.org/support/article/wordpress-widgets/
-- @link https://developer.wordpress.org/themes/functionality/widgets/
--
-- @package WordPress
-- @subpackage Widgets
-- @since 2.2.0
--

with Ada.Strings.Unbounded;

with Hb_Common;
with Php.Echoing;
with Php.Preg;
with Php.Sorting;

with Inc_Class_Wp_Customize_Widgets;
with Inc_Formatting;
with Inc_Functions;
with Inc_Load;
with Inc_Options;
with Inc_Plugins;
with Inc_Themes;

package body Inc_Widgets
is

   ---------------------------
   -- Is_Registered_Sidebar --
   ---------------------------

   function Is_Registered_Sidebar (Sidebar_Id : String)
                                   return Boolean
   is
      use Inc_Class_Wp_Customize_Widgets;
   begin
      return Isset (Global_Wp_Registered_Sidebars, Sidebar_Id);
   end Is_Registered_Sidebar;

   ---------------------
   -- Dynamic_Sidebar --
   ---------------------

   function Dynamic_Sidebar (Index : String := "1") -- 1
                             return Boolean
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Echoing;
      use Inc_Class_Wp_Customize_Widgets;
      use Inc_Formatting;
      use Inc_Load;
      use Inc_Plugins;
--    Global_wp_registered_sidebars
--    Global_wp_registered_widgets;
      Index_2 : Unbounded_String;
   begin
--    if Is_Int (Index) then
--       Index_2 := +"sidebar-index";
--    else
         Index_2 := +Sanitize_Title (Index);
         for A in Global_Wp_Registered_Sidebars.Iterate loop -- (array)
            declare
               Key   : constant String     := Arrays.Key (A);
               Value : constant Array_Type := As_Array (Arrays.Element (A));
            begin
               if Sanitize_Title (Get_As_String (Value, "name")) = Index then
                  Index_2 := +Key;
                  exit;
               end if;
            end;
         end loop;
--    end if;

      declare
         Index : constant String := -Index_2;
         Sidebars_Widgets : constant Array_Type := Wp_Get_Sidebars_Widgets;
      begin
         if
           Empty (Global_Wp_Registered_Sidebars, Index) or else
           Empty (Sidebars_Widgets, Index) or else
           Kind_Of (Get (Sidebars_Widgets, Index)) /= Kind_Array
         then
            -- This action is documented in wp-includes/widget.php
            Do_Action ("dynamic_sidebar_before", Index, False);
            -- This action is documented in wp-includes/widget.php
            Do_Action ("dynamic_sidebar_after", Index, False);
            -- This filter is documented in wp-includes/widget.php
            return Apply_Filters ("dynamic_sidebar_has_widgets", False, Index);
         end if;

         declare
            Sidebar : Array_Type :=
              As_Array (Get (Global_Wp_Registered_Sidebars, Index));

            Did_One : Boolean    := False;
         begin
            Set (Sidebar, "before_sidebar", From_String (
                 Sprintf (
                   Get_As_String (Sidebar, "before_sidebar"),
                   To_List (List => (
                     1 => +Get_As_String (Sidebar, "id"),
                     2 => +Get_As_String (Sidebar, "class")
                   ))
                 )));

            --
            -- Fires before widgets are rendered in a dynamic sidebar.
            --
            -- Note: The action also fires for empty sidebars, and on both the front
            -- end and back end, including the Inactive Widgets sidebar on the Widgets
            -- screen.
            --
            -- @since 3.9.0
            --
            -- @param int|string index       Index, name, or ID of the dynamic sidebar.
            -- @param bool       has_widgets Whether the sidebar is populated with
            --                                widgets. Default true.
            --
            Do_Action ("dynamic_sidebar_before", Index, True);

            if not Is_Admin and then not Empty (Sidebar, "before_sidebar") then
               Echo (Get_As_String (Sidebar, "before_sidebar"));
            end if;

            for Id of As_List (Get (Sidebars_Widgets, Index)) loop -- (array)

               if not Isset (Global_Wp_Registered_Widgets, -Id) then
                  goto Continue;
               end if;

               declare
                  Params : Array_Type :=
                    Array_Merge (
--                    To_Array (
                        Array_Merge (
                          Sidebar,
                          To_Array (List => (
                            Build ("widget_id",   -Id),
                            Build ("widget_name",
                                   As_String (Get (Ref_2 (
                                     Global_Wp_Registered_Widgets,
                                     Key_1 => -Id, Key_2 => "name"))))
                          ))
--                       )
                        ),
                        As_Array (Get (Ref_2 (
                          Global_Wp_Registered_Widgets,
                          Key_1 => -Id,
                          Key_2 => "params")))
                    );

                  -- Substitute HTML `id` and `class` attributes into `before_widget`.
                  Classname_X : Unbounded_String;
                  Callback : Arrays.Callable;
               begin
                  for
                    E in As_Array (Get (Ref_2 (
                      Global_Wp_Registered_Widgets, -Id, "classname"))).Iterate
                  loop
                     declare
                        CN : constant Multi_Type := Element (E);
                     begin
                        if Kind_Of (CN) = Kind_String then
                           Append (Classname_X, "_" & As_String (CN));
--                      elsif Is_Object (CN) then
--                         Append (Classname_X, "_" & Get_Class (CN));
                        end if;
                     end;
                  end loop;
                  Classname_X := +Ltrim (-Classname_X, "_");

                  Set_2 (Params,
                       Key_1 => "[0]",
                       Key_2 => "before_widget",
                       Value => From_String (
                         Sprintf (
                           As_String (Get (Ref_2 (Params,
                                           Key_1 => "[0]",
                                           Key_2 => "before_widget"))),
                           To_List (List => (
                             1 => +Str_Replace ("\\", "_", -Id),
                             2 => Classname_X
                           )))
                      ));

                  --
                  -- Filters the parameters passed to a widget"s display callback.
                  --
                  -- Note: The filter is evaluated on both the front end and back end,
                  -- including for the Inactive Widgets sidebar on the Widgets screen.
                  --
                  -- @since 2.5.0
                  --
                  -- @see register_sidebar()
                  --
                  -- @param array params {
                  --     @type array args  {
                  --         An array of widget display arguments.
                  --
                  --         @type string name          Name of the sidebar the widget
                  --                                     is assigned to.
                  --         @type string id            ID of the sidebar the widget
                  --                                     is assigned to.
                  --         @type string description   The sidebar description.
                  --         @type string class         CSS class applied to the
                  --                                     sidebar container.
                  --         @type string before_widget HTML markup to prepend to each
                  --                                     widget in the sidebar.
                  --         @type string after_widget  HTML markup to append to each
                  --                                     widget in the sidebar.
                  --         @type string before_title  HTML markup to prepend to the
                  --                                     widget title when displayed.
                  --         @type string after_title   HTML markup to append to the
                  --                                     widget title when displayed.
                  --         @type string widget_id     ID of the widget.
                  --         @type string widget_name   Name of the widget.
                  --     }
                  --     @type array widget_args {
                  --         An array of multi-widget arguments.
                  --
                  --         @type int number Number increment used for multiples of
                  --                           the same widget.
                  --     }
                  -- }
                  --
                  Params := Apply_Filters ("dynamic_sidebar_params", Params);

                  Callback := As_Callable (Get (Ref_2 (
                    Global_Wp_Registered_Widgets,
                    Key_1 => -Id,
                    Key_2 => "callback")));

                  --
                  -- Fires before a widget"s display callback is called.
                  --
                  -- Note: The action fires on both the front end and back end,
                  -- including for widgets in the Inactive Widgets sidebar on the
                  -- Widgets screen.
                  --
                  -- The action is not fired for empty sidebars.
                  --
                  -- @since 3.0.0
                  --
                  -- @param array widget {
                  --     An associative array of widget arguments.
                  --
                  --     @type string   name        Name of the widget.
                  --     @type string   id          Widget ID.
                  --     @type callable callback    When the hook is fired on the
                  --                                 front end, `callback` is an array
                  --                                 containing the widget object.
                  --                                 Fired on the back end, `callback`
                  --                                 is "wp_widget_control", see
                  --                                 `_callback`.
                  --     @type array    params      An associative array of
                  --                                 multi-widget arguments.
                  --     @type string   classname   CSS class applied to the widget
                  --                                 container.
                  --     @type string   description The widget description.
                  --     @type array    _callback   When the hook is fired on the back
                  --                                 end, `_callback` is populated
                  --                                 with an array containing the
                  --                                 widget object, see `callback`.
                  -- }
                  --
                  Do_Action ("dynamic_sidebar",
                             Get_As_String (Global_Wp_Registered_Widgets, -Id));

                  if Callback /= null then
--                if Is_Callable (Callback) then
                     declare
                        Unused : constant String :=
                           Call_User_Func_Array (Callback, Params);
                     begin
                        Did_One := True;
                     end;
                  end if;
               end;
               << Continue >>
            end loop;

            if not Is_Admin and then not Empty (Sidebar, "after_sidebar") then
               Echo (Get_As_String (Sidebar, "after_sidebar"));
            end if;

            --
            -- Fires after widgets are rendered in a dynamic sidebar.
            --
            -- Note: The action also fires for empty sidebars, and on both the front
            -- end and back end, including the Inactive Widgets sidebar on the Widgets
            -- screen.
            --
            -- @since 3.9.0
            --
            -- @param int|string index       Index, name, or ID of the dynamic sidebar.
            -- @param bool       has_widgets Whether the sidebar is populated with
            --                                widgets. Default true.
            --
            Do_Action ("dynamic_sidebar_after", Index, True);

            --
            -- Filters whether a sidebar has widgets.
            --
            -- Note: The filter is also evaluated for empty sidebars, and on both the
            -- front end and back end, including the Inactive Widgets sidebar on the
            --  Widgets screen.
            --
            -- @since 3.9.0
            --
            -- @param bool       did_one Whether at least one widget was rendered in
            --                            the sidebar. Default false.
            -- @param int|string index   Index, name, or ID of the dynamic sidebar.
            --
            return Apply_Filters ("dynamic_sidebar_has_widgets", Did_One, Index);
         end;
      end;
   end Dynamic_Sidebar;

   procedure Dynamic_Sidebar (Index : String := "1") -- 1
   is
      Unused : constant Boolean := Dynamic_Sidebar;
   begin
      null;
   end Dynamic_Sidebar;

   ----------------------
   -- Is_Active_Widget --
   ----------------------

   function Is_Active_Widget (Callback      : Callable; -- Boolean := False;
                              Widget_Id     : String  := ""; -- False
                              Id_Base       : String  := ""; -- Boolean := False;
                              Skip_Inactive : Boolean := True)
                              return String
   is
      use Php;
      use Inc_Class_Wp_Customize_Widgets;

      Sidebars_Widgets : constant Array_Type := Wp_Get_Sidebars_Widgets;
   begin
      if Is_Array (Sidebars_Widgets) then
         for A in Sidebars_Widgets.Iterate loop
            declare
               Sidebar : constant String := Key (A);
               Widgets : constant Multi_Type := Element (A);
            begin
               if
                 Skip_Inactive and
                 ("wp_inactive_widgets" = Sidebar or else
                  "orphaned_widgets" = Substr (Sidebar, 0, 16))
               then
                  goto Continue;
               end if;

               if Kind_Of (Widgets) = Kind_Array then
                  for B in As_Array (Widgets).Iterate loop
                     declare
                        Widget : constant String := Key (B);
                     begin
                        if
                          (Callback /= null
                           and then
                             Isset_2 (Global_Wp_Registered_Widgets,
                                      Key_1 => Widget, Key_2 => "callback")
                           and then
                             As_Callable (Get (Ref_2 (
                               Global_Wp_Registered_Widgets,
                               Key_1 => Widget, Key_2 => "callback")))
                             = Callback)
                        or else
                          (Id_Base /= "" and then
                           X_Get_Widget_Id_Base (Widget) = Id_Base)
                        then
                           if
                             Widget_Id /= "" or else
                             Widget_Id =
                             As_String (Get (Ref_2 (Global_Wp_Registered_Widgets,
                                                    Key_1 => Widget, Key_2 => "id")))
                           then
                              return Sidebar;
                           end if;
                        end if;
                     end;
                  end loop;
               end if;
               << Continue >>
            end;
         end loop;
      end if;
      return ""; -- False;
   end Is_Active_Widget;

   -----------------------------
   -- Wp_Get_Sidebars_Widgets --
   -----------------------------

   function Wp_Get_Sidebars_Widgets (Deprecated : Boolean := True)
                                     return Array_Type
   is
      use Php;
      use Inc_Class_Wp_Customize_Widgets;
      use Inc_Functions;
      use Inc_Load;
      use Inc_Options;
      use Inc_Plugins;
   begin
      if True /= Deprecated then
         X_Deprecated_Argument ("__FUNCTION__", "2.8.1");
      end if;

--    global_x_wp_sidebars_widgets
--    global_sidebars_widgets;

      -- If loading from front page, consult _wp_sidebars_widgets rather than options
      -- to see if wp_convert_widget_settings() has made manipulations in memory.
      if not Is_Admin then
         if Global_X_Wp_Sidebars_Widgets = Empty_Array then
--       if Empty (Global_X_Wp_Sidebars_Widgets) then
            Global_X_Wp_Sidebars_Widgets :=
              Get_Option ("sidebars_widgets", Empty_Array);
         end if;

         Global_Sidebars_Widgets := Global_X_Wp_Sidebars_Widgets;
      else
         Global_Sidebars_Widgets := Get_Option ("sidebars_widgets", Empty_Array);
      end if;

      if
        Is_Array (Global_Sidebars_Widgets) and then
        Isset (Global_Sidebars_Widgets, "array_version")
      then
         Delete (Ref (Global_Sidebars_Widgets, "array_version"));
      end if;

      --
      -- Filters the list of sidebars and their widgets.
      --
      -- @since 2.7.0
      --
      -- @param array sidebars_widgets An associative array of sidebars and their
      -- widgets.
      --
      return Apply_Filters ("sidebars_widgets", Global_Sidebars_Widgets);
   end Wp_Get_Sidebars_Widgets;

   -----------------------------
   -- Wp_Set_Sidebars_Widgets --
   -----------------------------

   procedure Wp_Set_Sidebars_Widgets (Sidebars_Widgets : Array_Type)
   is
      use Inc_Options;

      Sidebars_Widgets_2 : Array_Type := Sidebars_Widgets;
   begin
      -- Clear cached value used in wp_get_sidebars_widgets().
      Global_X_Wp_Sidebars_Widgets := Empty_Array; -- null;

      if not Isset (Sidebars_Widgets_2, "array_version") then
         Set (Sidebars_Widgets_2, "array_version", From_Integer (3));
      end if;

      Update_Option ("sidebars_widgets", Sidebars_Widgets_2);
   end Wp_Set_Sidebars_Widgets;

   --------------------------
   -- X_Get_Widget_Id_Base --
   --------------------------

   function X_Get_Widget_Id_Base (Id : String)
                                  return String
   is
      use Php;
      use Php.Preg;
   begin
      return Preg_Replace ("/-[0-9]+/", "", Id);
   end X_Get_Widget_Id_Base;

   ----------------------
   -- Retrieve_Widgets --
   ----------------------

   function Retrieve_Widgets (Theme_Changed : String := "") -- false
                              return Array_Type
   is
      use List_Vectors;
      use Hb_Common;
      use Php;
      use Php.Preg;
      use Php.Sorting;
      use Inc_Class_Wp_Customize_Widgets;
--    use Inc_Themes;

--    global wp_registered_sidebars, sidebars_widgets, wp_registered_widgets;
      Registered_Sidebars_Keys : List_Type :=
        Array_Keys (Global_Wp_Registered_Sidebars);

      Registered_Widgets_Ids : constant List_Type :=
        Array_Keys (Global_Wp_Registered_Widgets);
   begin
      if True then
--    if not Is_Array (Get_Theme_Mod ("sidebars_widgets")) then
         if Empty (Global_Sidebars_Widgets) then
            return Empty_Array;
         end if;

         Delete (Ref (Global_Sidebars_Widgets, "array_version"));

         declare
            Sidebars_Widgets_Keys : List_Type := Array_Keys (Global_Sidebars_Widgets);
         begin
            Sort (Sidebars_Widgets_Keys);
            Sort (Registered_Sidebars_Keys);

            if Sidebars_Widgets_Keys = Registered_Sidebars_Keys then
               Global_Sidebars_Widgets :=
                 X_Wp_Remove_Unregistered_Widgets (Global_Sidebars_Widgets,
                                                   Registered_Widgets_Ids);

               return Global_Sidebars_Widgets;
            end if;
         end;
      end if;

      -- Discard invalid, theme-specific widgets from sidebars.
      Global_Sidebars_Widgets :=
        X_Wp_Remove_Unregistered_Widgets (Global_Sidebars_Widgets,
                                          Registered_Widgets_Ids);
      Global_Sidebars_Widgets := Wp_Map_Sidebars_Widgets (Global_Sidebars_Widgets);

      -- Find hidden/lost multi-widget instances.
      declare
         Shown_Widgets : constant Array_Type :=
           Array_Merge (Array_Values (Global_Sidebars_Widgets), Empty_Array); -- ...

         Lost_Widgets : constant Array_Type :=
           Array_Diff (Empty_Array, -- Registered_Widgets_Ids,
                       Shown_Widgets);
      begin
         for A in Lost_Widgets.Iterate loop
            declare
               Key       : constant String := Arrays.Key (A);
               Widget_Id : constant String := As_String (Arrays.Element (A));

               Number    : constant String :=
                 Preg_Replace ("/.+?-([0-9]+)/", "1", Widget_Id);
            begin
               -- Only keep active and default widgets.
               if Is_Numeric (Number) and then Integer'Value (Number) < 2 then
                  Delete (Ref (Lost_Widgets, Key));
               end if;
            end;
         end loop;

         Set (Global_Sidebars_Widgets, "wp_inactive_widgets",
              From_Array (
                Array_Merge (Lost_Widgets,
                             As_Array (Get (Global_Sidebars_Widgets,
                                            "wp_inactive_widgets")))
             ));
      end;

      if "customize" /= Theme_Changed then
         -- Update the widgets settings in the database.
         Wp_Set_Sidebars_Widgets (Global_Sidebars_Widgets);
      end if;

      return Global_Sidebars_Widgets;
   end Retrieve_Widgets;

   -----------------------------
   -- Wp_Map_Sidebars_Widgets --
   -----------------------------

   function Wp_Map_Sidebars_Widgets (Existing_Sidebars_Widgets : Array_Type)
                                     return Array_Type
   is
      use Hb_Common;
      use Php;
      use Inc_Class_Wp_Customize_Widgets;
      use Inc_Themes;
--        global wp_registered_sidebars;

      New_Sidebars_Widgets : Array_Type := To_Array (List => (1 =>
        Build ("wp_inactive_widgets", Empty_Array)
      ));
   begin
      -- Short-circuit if there are no sidebars to map.
      if
        not Is_Array (Existing_Sidebars_Widgets) or else
        Existing_Sidebars_Widgets = Empty_Array
      then
         return New_Sidebars_Widgets;
      end if;

      for A in Existing_Sidebars_Widgets.Iterate loop
         declare
            Sidebar : constant String := Key (A);
            Widgets : constant Multi_Type := Element (A);
         begin
            if
              "wp_inactive_widgets" = Sidebar or else
              "orphaned_widgets" = Substr (Sidebar, 0, 16)
            then
               Set (New_Sidebars_Widgets, "wp_inactive_widgets",
                    From_Array (
                      Array_Merge (As_Array (Get (New_Sidebars_Widgets,
                                                  "wp_inactive_widgets")),
                                   As_Array (Widgets))));
               Delete (Ref (Existing_Sidebars_Widgets, Sidebar));
            end if;
         end;
      end loop;

      -- If old and new theme have just one sidebar, map it and we're done.
      if
        1 = Count (Existing_Sidebars_Widgets) and then
        1 = Count (Global_Wp_Registered_Sidebars)
      then
         Set (New_Sidebars_Widgets, Php.Key (Global_Wp_Registered_Sidebars),
              From_Integer (Array_Pop (Existing_Sidebars_Widgets)));

         return New_Sidebars_Widgets;
      end if;

      -- Map locations with the same slug.
      declare
         Existing_Sidebars : constant List_Type :=
           Array_Keys (Existing_Sidebars_Widgets);
      begin
         for A in Global_Wp_Registered_Sidebars.Iterate loop
            declare
               Sidebar : constant String := Key (A);
               Name    : Multi_Type := Element (A);
            begin
               if In_Array (Sidebar, Existing_Sidebars, True) then
                  Set (New_Sidebars_Widgets, Sidebar,
                       Get (Existing_Sidebars_Widgets, Sidebar));
                  Delete (Ref (Existing_Sidebars_Widgets, Sidebar));
               elsif not Array_Key_Exists (Sidebar, New_Sidebars_Widgets) then
                  Set (New_Sidebars_Widgets, Sidebar,
                       From_Array (Empty_Array));
               end if;
            end;
         end loop;
      end;

      -- If there are more sidebars, try to map them.
      if not Existing_Sidebars_Widgets.Is_Empty then
         --
         -- If old and new theme both have sidebars that contain phrases
         -- from within the same group, make an educated guess and map it.
         --
         declare
            Common_Slug_Groups : constant array (Positive range <>) of List_Type :=
            -- Array_Type := To_Array (List => (
              (
              1 => To_List (List => (+"sidebar", +"primary", +"main", +"right")),
              2 => To_List (List => (+"second", +"left")),
              3 => To_List (List => (+"sidebar-2", +"footer", +"bottom")),
              4 => To_List (List => (+"header", +"top"))
              );
         begin
            -- Go through each group...
            for Slug_Group of Common_Slug_Groups loop

               -- ...and see if any of these slugs...
               for Slug of Slug_Group loop

                  -- ...and any of the new sidebars...
                  for A in Global_Wp_Registered_Sidebars.Iterate loop
                     declare
                        New_Sidebar : constant String := Key (A);
                        Args        : Multi_Type := Element (A);
                     begin

                        -- ...actually match!
                        if
                          0 = Stripos (New_Sidebar, -Slug) and then
                          0 = Stripos (-Slug, New_Sidebar)
                        then
                           goto Continue_1;
                        end if;

                        -- Then see if any of the existing sidebars...
                        for B in Existing_Sidebars_Widgets.Iterate loop
                           declare
                              Sidebar : constant String := Key (B);
                              Widgets : Multi_Type := Element (B);
                           begin

                              -- ...and any slug in the same group...
                              for Slug of Slug_Group loop

                                 -- ... have a match as well.
                                 if
                                   0 = Stripos (Sidebar, -Slug) and then
                                   0 = Stripos (-Slug, Sidebar)
                                 then
                                    goto Continue_2;
                                 end if;

                                 -- Make sure this sidebar wasn't mapped and removed previously.
                                 if not Empty (Existing_Sidebars_Widgets, Sidebar) then

                                    -- We have a match that can be mapped!
                                    Set (New_Sidebars_Widgets, New_Sidebar,
                                         From_Array (
                                           Array_Merge (As_Array (Get (New_Sidebars_Widgets, New_Sidebar)),
                                                        As_Array (Get (Existing_Sidebars_Widgets, Sidebar)))));

                                    -- Remove the mapped sidebar so it can't be mapped again.
                                    Delete (Ref (Existing_Sidebars_Widgets, Sidebar));

                                    -- Go back and check the next new sidebar.
                                    goto Continue_1; -- 3?
                                 end if;
                                 << Continue_2 >>
                              end loop; -- End foreach ( slug_group as slug ).
                           end;
                        end loop; -- End foreach ( existing_sidebars_widgets as sidebar => widgets ).
                     end;
                     << Continue_1 >>
                  end loop; -- End foreach ( wp_registered_sidebars as new_sidebar => args ).
               end loop; -- End foreach ( slug_group as slug ).
            end loop; -- End foreach ( common_slug_groups as slug_group ).
         end;
      end if;

      -- Move any left over widgets to inactive sidebar.
      for W in Existing_Sidebars_Widgets.Iterate loop
         declare
            Widgets : constant Multi_Type := Element (W);
         begin
            if
              Kind_Of (Widgets) = Kind_Array -- and then
--            not Empty (Widgets)
            then
               Set (New_Sidebars_Widgets, "wp_inactive_widgets",
                    From_Array (
                      Array_Merge (As_Array (Get (
                        New_Sidebars_Widgets,
                        "wp_inactive_widgets")),
                                   As_Array (Widgets))));
            end if;
         end;
      end loop;

      -- Sidebars_widgets settings from when this theme was previously active.
      declare
         Old_Sidebars_Widgets_2 : constant Array_Type :=
           Get_Theme_Mod ("sidebars_widgets");

         Old_Sidebars_Widgets : Array_Type :=
           (if Isset (Old_Sidebars_Widgets_2, "data")
            then As_Array (Get (Old_Sidebars_Widgets_2, "data"))
            else Empty_Array); -- False
      begin

         if Is_Array (Old_Sidebars_Widgets) then

            -- Remove empty sidebars, no need to map those.
            Old_Sidebars_Widgets := Array_Filter (Old_Sidebars_Widgets);

            -- Only check sidebars that are empty or have not been mapped to yet.
            for A in New_Sidebars_Widgets.Iterate loop
               declare
                  New_Sidebar : constant String := Key (A);
                  New_Widgets : constant String := As_String (Element (A));
               begin
                  if
                    Array_Key_Exists (New_Sidebar, Old_Sidebars_Widgets) and then
                    not Empty (New_Widgets)
                  then
                     Delete (Ref (Old_Sidebars_Widgets, New_Sidebar));
                  end if;
               end;
            end loop;

            -- Remove orphaned widgets, we're only interested in previously
            -- active sidebars.
            for A in Old_Sidebars_Widgets.Iterate loop
               declare
                  Sidebar : constant String := Key (A);
--                Widgets : String := Element (A);
               begin
                  if "orphaned_widgets" = Substr (Sidebar, 0, 16) then
                     Delete (Ref (Old_Sidebars_Widgets, Sidebar));
                  end if;
               end;
            end loop;

            Old_Sidebars_Widgets :=
              X_Wp_Remove_Unregistered_Widgets (Old_Sidebars_Widgets);

            if not Empty (Old_Sidebars_Widgets) then

               -- Go through each remaining sidebar...
               for A in Old_Sidebars_Widgets.Iterate loop
                  declare
                     Old_Sidebar : constant String := Key (A);
                     Old_Widgets : constant Array_Type := As_Array (Element (A));
                  begin

                     -- ...and check every new sidebar...
                     for B in New_Sidebars_Widgets.Iterate loop
                        declare
                           New_Sidebar : constant String := Key (B);
                           New_Widgets : constant List_Type := As_List (Element (B));
                        begin

                           -- ...for every widget we're trying to revive.
                           for E in Old_Widgets.Iterate loop
                              declare
                                 Key       : constant String := Arrays.Key (E);
                                 Widget_Id : constant String :=
                                   As_String (Arrays.Element (E));

                                 Active_Key : constant String :=
                                   Array_Search (Widget_Id, New_Widgets, True);
                              begin

                                 -- If the widget is used elsewhere...
                                 if "" /= Active_Key then

                                    -- ...and that elsewhere is inactive widgets...
                                    if "wp_inactive_widgets" = New_Sidebar then

                                       -- ...remove it from there and keep the active
                                       -- version...
                                       Delete (Ref_2 (New_Sidebars_Widgets,
                                                     "wp_inactive_widgets",
                                                     Active_Key));
                                    else

                                       -- ...otherwise remove it from the old sidebar
                                       -- and keep it in the new one.
                                       Delete (Ref_2 (Old_Sidebars_Widgets,
                                                      Old_Sidebar, Key));
                                    end if;
                                 end if; -- End if ( active_key ).
                              end;
                           end loop; -- End foreach ( old_widgets as key => widget_id ).
                        end;
                     end loop; -- End foreach ( new_sidebars_widgets as new_sidebar => new_widgets ).
                  end;
               end loop; -- End foreach ( old_sidebars_widgets as old_sidebar => old_widgets ).
            end if; -- End if ( ! empty( old_sidebars_widgets ) ).

            -- Restore widget settings from when theme was previously active.
            New_Sidebars_Widgets :=
             Array_Merge (New_Sidebars_Widgets, Old_Sidebars_Widgets);
         end if;
      end;

      return New_Sidebars_Widgets;
   end Wp_Map_Sidebars_Widgets;

   --------------------------------------
   -- X_Wp_Remove_Unregistered_Widgets --
   --------------------------------------

   function X_Wp_Remove_Unregistered_Widgets
              (Sidebars_Widgets   : Array_Type;
               Allowed_Widget_Ids : List_Type := Empty_List)
               return Array_Type
   is
      use Php;

      Sidebars_Widgets_2 : Array_Type := Sidebars_Widgets;
   begin
      -- if Empty (Allowed_Widget_Ids) then
      --    Allowed_Widget_Ids := Array_Keys (GLOBALS["wp_registered_widgets"]);
      -- end if;

      for A in Sidebars_Widgets_2.Iterate loop
         declare
            Sidebar : constant String     := Key (A);
            Widgets : constant Multi_Type := Element (A);
         begin
            if Kind_Of (Widgets) = Kind_Array then
               Set (Sidebars_Widgets_2, Sidebar,
                    From_List (
                      Array_Intersect (As_List (Widgets), Allowed_Widget_Ids)));
            end if;
         end;
      end loop;

      return Sidebars_Widgets_2;
   end X_Wp_Remove_Unregistered_Widgets;

   ---------------------------------
   -- Wp_Use_Widgets_Block_Editor --
   ---------------------------------

   function Wp_Use_Widgets_Block_Editor
            return Boolean
   is
      use Inc_Plugins;
      use Inc_Themes;
   begin
      --
      -- Filters whether to use the block editor to manage widgets.
      --
      -- @since 5.8.0
      --
      -- @param bool use_widgets_block_editor Whether to use the block editor to
      --                                       manage widgets.
      --
      return
        Apply_Filters (
           "use_widgets_block_editor",
           Boolean'(Get_Theme_Support ("widgets-block-editor"))
        );
   end Wp_Use_Widgets_Block_Editor;

end Inc_Widgets;
