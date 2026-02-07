--
-- WordPress Customize Setting classes
--
-- @package WordPress
-- @subpackage Customize
-- @since 3.4.0
--

with Php.Arrays;
with Php.Lists;
with Php.Types;

with Array_Lists;
with Wp_Common;

with Inc_Load;
with Inc_L10n;
with Inc_Options;
with Inc_Plugins;
with Inc_Themes;

with Class_Customize_Managers;

package body Class_Customize_Settings
is

   type Proc_Access is access procedure (This : in out Wp_Customize_Setting);

   function To_Array (This : in out Wp_Customize_Setting;
                      CB   : Proc_Access)
                      return Callable;

   function From_Object (This : in out Wp_Customize_Setting)
                         return Multi_Type;

   --------------
   -- To_Array --
   --------------

   function To_Array (This : in out Wp_Customize_Setting;
                      CB   : Proc_Access)
                      return Callable
   is
   begin
      raise Program_Error with "not implemented";
      return null;
   end To_Array;

   -----------------
   -- From_Object --
   -----------------

   function From_Object (This : in out Wp_Customize_Setting)
                         return Multi_Type
   is
   begin
      return From_Null;
   end From_Object;

   -------------
   -- Preview --
   -------------

   procedure Preview (This : in out Wp_Customize_Setting)
   is
      use UStrings;
      use Wp_Common;
      use Inc_Load;
      use Inc_Plugins;
   begin
      if This.X_Previewed_Blog_Id in 0 then
--    if not Isset (This.X_Previewed_Blog_Id) then
         This.X_Previewed_Blog_Id := Get_Current_Blog_Id;
      end if;

      -- Prevent re-previewing an already-previewed setting.
      if This.Is_Previewed then
         return; -- True;
      end if;

      declare
         Id_Base : constant String  :=
           Get_As_String (This.Id_Data, "base");

         Is_Multidimensional : constant Boolean :=
           not Empty (This.Id_Data, "keys");

         Multidimensional_Filter : constant Callable := -- Array_Type :=
           To_Array (This, X_Multidimensional_Preview_Filter'Access);

         --
         -- Check if the setting has a pre-existing value (an isset check),
         -- and if doesn"t have any incoming post value. If both checks are true,
         -- then the preview short-circuits because there is nothing that needs
         -- to be previewed.
         --
         Undefined : Multi_Type; --  := new stdClass();

         Needs_Preview : Boolean  :=
           As_String (Undefined) /= This.Post_Value (As_String (Undefined));

         Value : Multi_Type; -- UString; --  := null;
      begin
         -- Since no post value was defined, check if we have an initial value set.
         if not Needs_Preview then
            if This.Is_Multidimensional_Aggregated then
               declare
                  Root : constant Array_Type :=
                    As_Array (Get (Ref_3 (Aggregated_Multidimensionals,
                                   Key_1 => -This.Typ,
                                   Key_2 => Id_Base,
                                   Key_3 => "root_value")));
               begin
                  Value :=
                    This.Multidimensional_Get (Root,
                                               As_List (Get (This.Id_Data, "keys")),
                                               Undefined);
               end;
            else
               declare
                  Default : constant String := -This.Default;
               begin
                  This.Default := +As_String (Undefined);
                  -- Temporarily set default to undefined so we can detect if existing
                  -- value is set.
                  Value        := From_String (This.Value);
                  This.Default := +Default;
               end;
            end if;
            Needs_Preview := Undefined = Value;
            -- Because the default needs to be supplied.
         end if;

         -- If the setting does not need previewing now, defer to when it has a
         -- value to preview.
         if not Needs_Preview then
            if
              not Has_Action ("customize_post_value_set_" & (-This.Id),
                              To_Array (This, Preview'Access))
            then
               Add_Action ("customize_post_value_set_" & (-This.Id),
                           To_Array (This, Preview'Access));
            end if;
            return; -- False;
         end if;

         -- switch ( this.typ ) then
         if This.Typ = "theme_mod" then
            if not Is_Multidimensional then
               Add_Filter ("theme_mod_" & Id_Base,
                           To_Array (This, X_Preview_Filter'Access));
            else
               if
                 Empty (Ref_3 (Aggregated_Multidimensionals,
                               Key_1 => -This.Typ,
                               Key_2 => Id_Base,
                               Key_3 => "previewed_instances"))
               then
                  -- Only add this filter once for this ID base.
                  Add_Filter ("theme_mod_" & Id_Base, Multidimensional_Filter);
               end if;
               Set_4 (Aggregated_Multidimensionals,
                      Key_1 => -This.Typ,
                      Key_2 => Id_Base,
                      Key_3 => "previewed_instances",
                      Key_4 => -This.Id,
                      Value => From_Object (This));
            end if;

         elsif This.Typ = "option" then
            if not Is_Multidimensional then
               Add_Filter ("pre_option_" & Id_Base,
                           To_Array (This, X_Preview_Filter'Access));
            else
               if
                 Empty (Ref_3 (Aggregated_Multidimensionals,
                               Key_1 => -This.Typ,
                               Key_2 => Id_Base,
                               Key_3 => "previewed_instances"))
               then
                  -- Only add these filters once for this ID base.
                  Add_Filter ("option_" & Id_Base, Multidimensional_Filter);
                  Add_Filter ("default_option_" & Id_Base, Multidimensional_Filter);
               end if;
               Set_4 (Aggregated_Multidimensionals,
                      Key_1 => -This.Typ,
                      Key_2 => Id_Base,
                      Key_3 => "previewed_instances",
                      Key_4 => -This.Id,
                      Value => From_Object (This));
            end if;

         else
            --
            -- Fires when the WP_Customize_Setting::preview() method is called for
            -- settings not handled as theme_mods or options.
            --
            -- The dynamic portion of the hook name, `this.id`, refers to the
            -- setting ID.
            --
            -- @since 3.4.0
            --
            -- @param WP_Customize_Setting setting WP_Customize_Setting instance.
            --
            Do_Action ("customize_preview_" & (-This.Id), This);

            --
            -- Fires when the WP_Customize_Setting::preview() method is called for
            -- settings not handled as theme_mods or options.
            --
            -- The dynamic portion of the hook name, `this.type`, refers to the
            -- setting type.
            --
            -- @since 4.1.0
            --
            -- @param WP_Customize_Setting setting WP_Customize_Setting instance.
            --
            Do_Action ("customize_preview_" & (-This.Typ), This);
         end if; -- switch
         -- end switch;
      end;

      This.Is_Previewed := True;

      return; --  True;
   end Preview;

   ----------------------
   -- X_Preview_Filter --
   ----------------------

   function X_Preview_Filter (This     : in out Wp_Customize_Setting;
                              Original : String)
                              return String
   is
      use UStrings;
   begin
      if not This.Is_Current_Blog_Previewed then
         return Original;
      end if;

      declare
         Undefined  : constant String := "XXX-021"; -- new stdClass(); -- Symbol hack.
         Post_Value : constant String := This.Post_Value (Undefined);
         Value      : UString;
      begin
         if Undefined /= Post_Value then
            Value := +Post_Value;
         else
            --
            -- Note that we don't use original here because preview() will
            -- not add the filter in the first place if it has an initial value
            -- and there is no post value.
            --
            Value := This.Default;
         end if;
         return -Value;
      end;
   end X_Preview_Filter;

   procedure X_Preview_Filter (This : in out Wp_Customize_Setting)
   is
      Unused : constant String := X_Preview_Filter (This, "XXX-022");
   begin
      null;
   end X_Preview_Filter;

   -------------------------------
   -- Is_Current_Blog_Previewed --
   -------------------------------

   function Is_Current_Blog_Previewed (This : Wp_Customize_Setting)
                                       return Boolean
   is
      use Inc_Load;
   begin
      if This.X_Previewed_Blog_Id in 0 then -- not isset
         return False;
      end if;
      return Get_Current_Blog_Id = This.X_Previewed_Blog_Id;
   end Is_Current_Blog_Previewed;

   ---------------------------------------
   -- X_Multidimensional_Preview_Filter --
   ---------------------------------------

   function X_Multidimensional_Preview_Filter
              (This : in out Wp_Customize_Setting;
               Original : String)
               return String
   is
      use UStrings;
   begin
      if not This.Is_Current_Blog_Previewed then
         return Original;
      end if;

      declare
         Id_Base : constant String := Get_As_String (This.Id_Data, "base");
      begin
         -- If no settings have been previewed yet (which should not be the case,
         -- since this is), just pass through the original value.
         if
           Empty (Ref_3 (Aggregated_Multidimensionals,
                         Key_1 => -This.Typ,
                         Key_2 => Id_Base,
                         Key_3 => "previewed_instances"))
         then
            return Original;
         end if;

         declare
            Previewed_Instances : constant Array_Type :=
              As_Array (Get (Ref_3 (Aggregated_Multidimensionals,
                               Key_1 => -This.Typ,
                               Key_2 => Id_Base,
                               Key_3 => "previewed_instances")));
         begin
            for A in Previewed_Instances.Iterate loop
               declare
                  Previewed_Setting : Wp_Customize_Setting; -- (from a somehow)
               begin
                  -- Skip applying previewed value for any settings that have already
                  -- been applied.
                  if not
                    Empty (Ref_4 (Aggregated_Multidimensionals,
                                  Key_1 => -This.Typ,
                                  Key_2 => Id_Base,
                                  Key_3 => "preview_applied_instances",
                                  Key_4 => -Previewed_Setting.Id))
                  then
                     goto Continue;
                  end if;

                  -- Do the replacements of the posted/default sub value into the root
                  -- value.
                  declare
                     Value : constant String :=
                       Previewed_Setting.Post_Value (-Previewed_Setting.Default);

                     Root_2 : constant Array_Type :=
                       As_Array (Get (
                         Ref_3 (Aggregated_Multidimensionals,
                                Key_1 => -Previewed_Setting.Typ,
                                Key_2 => Id_Base,
                                Key_3 => "root_value")));

                     Root : constant Array_Type :=
                       Previewed_Setting.Multidimensional_Replace
                         (Root_2,
                          As_List (Get (Previewed_Setting.Id_Data, "keys")),
                          From_String (Value));
                  begin
                     Set_3 (Aggregated_Multidimensionals,
                            Key_1 => -Previewed_Setting.Typ,
                            Key_2 => Id_Base,
                            Key_3 => "root_value",
                            Value => From_Array (Root));

                     -- Mark this setting having been applied so that it will
                     -- be skipped when the filter is called again.
                     Set_4 (Aggregated_Multidimensionals,
                            Key_1 => -Previewed_Setting.Typ,
                            Key_2 => Id_Base,
                            Key_3 => "preview_applied_instances",
                            Key_4 => -Previewed_Setting.Id,
                            Value => From_Boolean (True));
                  end;
               end;
               << Continue >>
            end loop;
         end;

         return
           As_String (Get (
             Ref_3 (Aggregated_Multidimensionals,
                    Key_1 => -This.Typ,
                    Key_2 => Id_Base,
                    Key_3 => "root_value")));
      end;
   end X_Multidimensional_Preview_Filter;

   procedure X_Multidimensional_Preview_Filter (This : in out Wp_Customize_Setting)
   is
      Unused : constant String :=
        X_Multidimensional_Preview_Filter (This, "XXX-022");
   begin
      null;
   end X_Multidimensional_Preview_Filter;

   ----------------
   -- Post_Value --
   ----------------

   function Post_Value (This          : Wp_Customize_Setting;
                        Default_Value : String := "") -- null
                        return String
   is
   begin
      return This.Manager.Post_Value (This, Default_Value);
   end Post_Value;

   --------------
   -- Sanitize --
   --------------

   function Sanitize (This  : Wp_Customize_Setting;
                      Value : Multi_Type)
                      return Multi_Type
   is
      use UStrings;
      use Wp_Common;
--    use Inc_Plugins;
   begin
      --
      -- Filters a Customize setting value in un-slashed form.
      --
      -- @since 3.4.0
      --
      -- @param mixed                value   Value of the setting.
      -- @param WP_Customize_Setting setting WP_Customize_Setting instance.
      --
      return Apply_Filters ("customize_sanitize_" & (-This.Id), Value, This);
   end Sanitize;

   --------------
   -- Validate --
   --------------

   function Validate (This  : Wp_Customize_Setting;
                      Value : Multi_Type)
                      return Validate_Result
   is
      use UStrings;
      use Wp_Common;
      use Class_Errors;
      use Inc_L10n;
      use Inc_Load;
--    use Inc_Plugins;
   begin
      -- if Is_Wp_Error (Value) then
      --    return Value;
      -- end if;

      if Kind_Of (Value) = Kind_Null then
         return
           (Success => False,
            Error   => X_Construct ("invalid_value", abs "Invalid value."));
      end if;

      declare
         Validity : Wp_Error := X_Construct;
      begin
         --
         -- Validates a Customize setting value.
         --
         -- Plugins should amend the `validity` object via its `WP_Error::add()`
         -- method.
         --
         -- The dynamic portion of the hook name, `this.ID`, refers to the setting ID.
         --
         -- @since 4.6.0
         --
         -- @param WP_Error             validity Filtered from `true` to `WP_Error`
         --                                       when invalid.
         -- @param mixed                value    Value of the setting.
         -- @param WP_Customize_Setting setting  WP_Customize_Setting instance.
         --
         Validity :=
           Apply_Filters ("customize_validate_" & (-This.Id), Validity, Value, This);

         if Is_Wp_Error (Validity) and then not Validity.Has_Errors then
            return
              (Success => False,
               Error   => Validity);
         end if;
         return
           (Success => True,
            Error   => Validity);
      end;
   end Validate;

   -----------
   -- Value --
   -----------

   function Value (This : Wp_Customize_Setting)
                   return String
   is
      use UStrings;
      use Wp_Common;
--    use Inc_Plugins;

      Id_Base      : constant String := Get_As_String (This.Id_Data, "base");
      Is_Core_Type : constant Boolean := -This.Typ in "option" | "theme_mod";
      Value_2 : UString;
   begin
      if
        not Is_Core_Type and then
        not This.Is_Multidimensional_Aggregated
      then
         -- Use post value if previewed and a post value is present.
         if This.Is_Previewed then
            Value_2 := +This.Post_Value; --  (null);

            if Value_2 /= "" then -- null /=
               return -Value_2;
            end if;
         end if;

         Value_2 := +This.Get_Root_Value (-This.Default);

         --
         -- Filters a Customize setting value not handled as a theme_mod or option.
         --
         -- The dynamic portion of the hook name, `id_base`, refers to
         -- the base slug of the setting name, initialized from `this.id_data["base"]`.
         --
         -- For settings handled as theme_mods or options, see those corresponding
         -- functions for available hooks.
         --
         -- @since 3.4.0
         -- @since 4.6.0 Added the `this` setting instance as the second parameter.
         --
         -- @param mixed                default_value The setting default value.
         --                                            Default empty.
         -- @param WP_Customize_Setting setting       The setting instance.
         --
         Value_2 := +Apply_Filters ("customize_value_" & Id_Base, -Value_2, This);

      elsif This.Is_Multidimensional_Aggregated then
         declare
            Root_Value : constant Array_Type :=
              As_Array (Get (
                Ref_3 (Aggregated_Multidimensionals,
                       Key_1 => -This.Typ,
                       Key_2 => Id_Base,
                       Key_3 => "root_value")));

            Value_3 : constant Multi_Type :=
              This.Multidimensional_Get (
                 Root_Value,
                 As_List (Get (This.Id_Data, "keys")),
                 From_String (-This.Default));
         begin
            -- Ensure that the post value is used if the setting is previewed, since
            -- preview filters aren't applying on cached root_value.
            if This.Is_Previewed then
               Value_2 := +This.Post_Value (As_String (Value_3));
            end if;
         end;
      else
         Value_2 := +This.Get_Root_Value (-This.Default);
      end if;
      return -Value_2;
   end Value;

   --------------------
   -- Get_Root_Value --
   --------------------

   function Get_Root_Value (This          : Wp_Customize_Setting;
                            Default_Value : String := "") -- null
                            return String
   is
      use UStrings;
      use Inc_Options;
      use Inc_Themes;

      Id_Base : constant String := Get_As_String (This.Id_Data, "base");
   begin
      if "option" = This.Typ then
         return Get_Option (Id_Base, Default_Value);
      elsif "theme_mod" = This.Typ then
         return Get_Theme_Mod (Id_Base, Default_Value);
      else
         --
         -- Any WP_Customize_Setting subclass implementing aggregate multidimensional
         -- will need to override this method to obtain the data from the appropriate
         -- location.
         --
         return Default_Value;
      end if;
   end Get_Root_Value;

   ----------------------
   -- Multidimensional --
   ----------------------

   function Multidimensional (This   : Wp_Customize_Setting;
                              Root   : in out Array_Type;
                              Keys   : List_Type; -- String;
                              Create : Boolean := False)
                              return Array_Type
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Types;
      use Array_Lists;

      Keys_2 : List_Type := Keys;
   begin
      if Create and Empty (Root) then
         Root := Empty_Array;
      end if;

      if not Isset (Root) or else Keys_2.Is_Empty then
         return Empty_Array;
      end if;

      declare
         Last : constant String := List_Pop (Keys_2);
         Node : Array_Type := Root; -- &
      begin
         for Key of Keys_2 loop
            if Create and then not Isset (Node, Key) then
               Set (Node, Key, From_Array (Empty_Array));
            end if;

            if not Is_Array (Node) or else not Isset (Node, Key) then
               return Empty_Array;
            end if;

            Node := As_Array (Get (Node, Key)); -- &
         end loop;

         if Create then
            if not Is_Array (Node) then
               -- Account for an array overriding a string or object value.
               Node := Empty_Array;
            end if;

            if not Isset (Node, Last) then
               Set (Node, Last, From_Array (Empty_Array));
            end if;
         end if;

         if not Isset (Node, Last) then
            return Empty_Array;
         end if;

         return To_Array_Type ([
           Build ("root", Root), -- &
           Build ("node", Node), -- &
           Build ("key",  Last)
         ]);
      end;
   end Multidimensional;

   ------------------------------
   -- Multidimensional_Replace --
   ------------------------------

   function Multidimensional_Replace (This  : Wp_Customize_Setting;
                                      Root  : Array_Type; -- String;
                                      Keys  : List_Type;  -- String
                                      Value : Multi_Type) -- String)
                                      return Array_Type -- String
   is
      use Php.Arrays;

      Root_2 : Array_Type := Root;
   begin
      case Kind_Of (Value) is
      when Kind_Null =>
--    if not Isset (Value) then
         return Root_2;
      when Kind_List =>
--      elsif Keys.Is_Empty then -- If there are no keys, we're replacing the root.
         return As_Array (Value);
--    end if;
      when others =>
         null;
      end case;

      declare
         Result : Array_Type :=
           This.Multidimensional (Root_2, Keys, True);
      begin
         if Isset (Result) then
            Set_2 (Result,
                   Key_1 => "node",
                   Key_2 => Get_As_String (Result, "key"),
                   Value => Value);
         end if;
      end;
      return Root_2;
   end Multidimensional_Replace;

   --------------------------
   -- Multidimensional_Get --
   --------------------------

   function Multidimensional_Get
              (This : Wp_Customize_Setting;
               Root : Array_Type; -- Multi_Type; -- Array_Type;
               Keys : List_Type;  -- Multi_Type; -- Array_Type;
               Default_Value : Multi_Type := From_Null) -- String := "") -- null
               return Multi_Type -- String
   is
      use Php.Arrays;
   begin
      if Keys.Length in 0 then -- If there are no keys, test the root.
         return
           (if Isset (Root)
            then From_Array (Root)
            else Default_Value);
      end if;

      declare
         Root_2 : Array_Type := Root;
         Result : constant Array_Type :=
           This.Multidimensional (Root_2, Keys);
      begin
         return
           (if Isset (Result)
            then Get (Ref_2 (Result,
                             Key_1 => "node",
                             Key_2 => Get_As_String (Result, "key")))
            else Default_Value);
      end;

   end Multidimensional_Get;

end Class_Customize_Settings;
