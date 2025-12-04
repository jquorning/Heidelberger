--
-- Typography block support flag.
--
-- @package WordPress
-- @since 5.6.0
--

with Ada.Strings.Unbounded;

with Php.Numerics;
with Php.Preg;
with Php.Types;

with Hb_Common;
with Lists;

with Inc_Functions;
with Inc_Global_Styles_And_Settings;
with Inc_L10n;

package body Block_Typography
is
   use Lists;

   --------------------------------------
   -- Wp_Get_Typography_Value_And_Unit --
   --------------------------------------

   function Wp_Get_Typography_Value_And_Unit
              (Raw_Value : Multi_Type;
               Options   : Array_Type := Empty_Array)
               return Array_Type
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Numerics;
      use Php.Preg;
      use Php.Types;
      use Inc_Functions;
      use Inc_L10n;

      Raw_Value_2 : Multi_Type := Raw_Value;
   begin
      if Kind_Of (Raw_Value) not in Kind_String | Kind_Integer then -- | Kind_Float
         X_Doing_It_Wrong (
           "__FUNCTION__",
           abs "Raw size value must be a string, integer, or float.",
           "6.1.0"
         );
         return Empty_Array; -- null
      end if;

      if Kind_Of (Raw_Value_2) = Kind_Null then
--    if Empty (Raw_Value) then
         return Empty_Array; -- null
      end if;

      -- Converts numbers to pixel values by default.
      if Is_Numeric (As_String (Raw_Value_2)) then
         Raw_Value_2 := From_String (As_String (Raw_Value_2) & "px");
      end if;

      declare
         Defaults : constant Array_Type := To_Array (List => (
           Build ("coerce_to",        ""),
           Build ("root_size_value",  16),
           Build ("acceptable_units", To_List (List => (+"rem", +"px", +"em")))
         ));

         Options_2 : constant Array_Type := Wp_Parse_Args (Options, Defaults);

         Acceptable_Units_Group : constant String :=
           Implode ("|", As_List (Get (Options_2, "acceptable_units")));

         Pattern : constant String :=
           "/^(\d*\.?\d+)(" & Acceptable_Units_Group & "){1,1}/";

         Matches : List_Type;
         Unused  : Natural;
      begin
         Unused := Preg_Match (Pattern, As_String (Raw_Value_2), Matches);

         -- Bails out if not a number value and a px or rem unit.
         if not Isset (-Matches (2)) or else not Isset (-Matches (3)) then
            return Empty_Array; -- null;
         end if;

         declare
            Value : Float  := Float'Value (-Matches (2)); -- (1)
            Unit  : Unbounded_String := Matches (3);      -- (2)

            Coerce_To : constant String :=
              As_String (Get (Options_2, "coerce_to"));

            Root_Size_Value : constant Float  :=
              Float'Value (As_String (Get (Options_2, "root_size_value")));
         begin
            --
            -- Default browser font size. Later, possibly could inject some JS to
            -- compute this
            -- `getComputedStyle( document.querySelector( "html" ) ).fontSize`.
            --
            if
              "px" = Coerce_To and then
              -Unit in "em" | "rem"
            then
               Value := Value * Root_Size_Value;
               Unit  := +Coerce_To;
            end if;

            if
              "px" = Unit and then
              Coerce_To in "em" | "rem"
            then
               Value := Value / Root_Size_Value;
               Unit  := +Coerce_To;
            end if;

            --
            -- No calculation is required if swapping between em and rem yet,
            -- since we assume a root size value. Later we might like to differentiate
            -- between :root font size (rem) and parent element font size (em)
            -- relativity.
            --
            if
              Coerce_To in "em" | "rem" and then
              -Unit in "em" | "rem"
            then
               Unit := +Coerce_To;
            end if;

            return To_Array (List => (
              Build ("value", Round (Value, 3)'Image),
              Build ("unit",  -Unit)
            ));
         end;
      end;
   end Wp_Get_Typography_Value_And_Unit;

   --------------------------------------------
   -- Wp_Get_Computed_Fluid_Typography_Value --
   --------------------------------------------

   function Wp_Get_Computed_Fluid_Typography_Value
               (Args : Array_Type := Empty_Array)
               return String
   is
      use Php;
      use Php.Numerics;

      Maximum_Viewport_Width_Raw : constant Multi_Type :=
        (if Isset (Args, "maximum_viewport_width")
         then Get (Args, "maximum_viewport_width") else Null_Multi_Type); -- null);

      Minimum_Viewport_Width_Raw : Multi_Type :=
        (if Isset (Args, "minimum_viewport_width")
         then Get (Args, "minimum_viewport_width") else Null_Multi_Type); -- null);

      Maximum_Font_Size_Raw : constant Multi_Type :=
        (if Isset (Args, "maximum_font_size")
         then Get (Args, "maximum_font_size") else Null_Multi_Type); -- null);

      Minimum_Font_Size_Raw : constant Multi_Type :=
        (if Isset (Args, "minimum_font_size")
         then Get (Args, "minimum_font_size") else Null_Multi_Type); -- null);

      Scale_Factor : constant Float :=
        (if Isset (Args, "scale_factor")
         then Float'Value (As_String (Get (Args, "scale_factor"))) else 0.0); -- null);

      -- Normalizes the minimum font size in order to use the value for calculations.
      Minimum_Font_Size : constant Array_Type :=
        Wp_Get_Typography_Value_And_Unit (Minimum_Font_Size_Raw);

      --
      -- We get a "preferred" unit to keep units consistent when calculating,
      -- otherwise the result will not be accurate.
      --
      Font_Size_Unit : constant String :=
        (if Isset (Minimum_Font_Size, "unit")
         then As_String (Get (Minimum_Font_Size, "unit")) else "rem");

      -- Normalizes the maximum font size in order to use the value for calculations.
      Maximum_Font_Size : constant Array_Type :=
        Wp_Get_Typography_Value_And_Unit (
          Maximum_Font_Size_Raw,
          To_Array (List => (1 =>
            Build ("coerce_to", Font_Size_Unit)
          ))
        );
   begin
      -- Checks for mandatory min and max sizes, and protects against unsupported
      -- units.
      if
        Maximum_Font_Size = Empty_Array or
        Minimum_Font_Size = Empty_Array
      then
--    if not Maximum_Font_Size or not Minimum_Font_Size then
         return ""; -- null;
      end if;

      declare
         -- Uses rem for accessible fluid target font scaling.
         Minimum_Font_Size_Rem : constant Array_Type :=
           Wp_Get_Typography_Value_And_Unit (
             Minimum_Font_Size_Raw,
             To_Array (List => (1 =>
               Build ("coerce_to", "rem")
             ))
           );

         -- Viewport widths defined for fluid typography. Normalize units.
         Maximum_Viewport_Width : constant Array_Type :=
           Wp_Get_Typography_Value_And_Unit (
             Maximum_Viewport_Width_Raw,
             To_Array (List => (1 =>
               Build ("coerce_to", Font_Size_Unit)
             ))
           );

         Minimum_Viewport_Width : constant Array_Type :=
           Wp_Get_Typography_Value_And_Unit (
             Minimum_Viewport_Width_Raw,
             To_Array (List => (1 =>
               Build ("coerce_to", Font_Size_Unit)
             ))
           );

         --
         -- Build CSS rule.
         -- Borrowed from https://websemantics.uk/tools/responsive-font-calculator/.
         --
         Minimum_Viewport_Width_Value : constant Float :=
           Float'Value (As_String (Get (Minimum_Viewport_Width, "value")));

         Maximum_Viewport_Width_Value : constant Float :=
           Float'Value (As_String (Get (Maximum_Viewport_Width, "value")));

         Minimum_Font_Size_Value : constant Float :=
           Float'Value (As_String (Get (Minimum_Font_Size, "value")));

         Maximum_Font_Size_Value : constant Float :=
           Float'Value (As_String (Get (Maximum_Font_Size, "value")));

         View_Port_Width_Offset : constant String :=
           Round (Minimum_Viewport_Width_Value / 100.0, 3)'Image & Font_Size_Unit;

         Linear_Factor : constant Float :=
           100.0 * ((Maximum_Font_Size_Value - Minimum_Font_Size_Value) /
                    (Maximum_Viewport_Width_Value - Minimum_Viewport_Width_Value));

         Linear_Factor_Scaled_2 : constant Float :=
           Round (Linear_Factor * Scale_Factor, 3);

         Linear_Factor_Scaled : constant Float :=
           (if Linear_Factor_Scaled_2 = 0.0
            then 1.0 else Linear_Factor_Scaled_2);

         Fluid_Target_Font_Size : constant String :=
           Implode ("", Minimum_Font_Size_Rem) &
           " + ((1vw - " & View_Port_Width_Offset &
           ") * " & Linear_Factor_Scaled'Image & ")";
      begin
         return
           "clamp(" & As_String (Minimum_Font_Size_Raw) & ", " &
           Fluid_Target_Font_Size & ", " &
           As_String (Maximum_Font_Size_Raw) & ")";
      end;
   end Wp_Get_Computed_Fluid_Typography_Value;

   ---------------------------------------
   -- Wp_Get_Typography_Font_Size_Value --
   ---------------------------------------

   function Wp_Get_Typography_Font_Size_Value
              (Preset : Array_Type;
               Should_Use_Fluid_Typography : Boolean := False)
               return String
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Numerics;
      use Inc_Global_Styles_And_Settings;
   begin
      if not Isset (Preset, "size") then
         return ""; -- null
      end if;

      --
      -- Catches empty values and 0/"0".
      -- Fluid calculations cannot be performed on 0.
      --
      if Empty (Preset, "size") then
         return As_String (Get (Preset, "size"));
      end if;

      -- Checks if fluid font sizes are activated.
      declare
         Typography_Settings : constant Array_Type :=
           As_Array (Wp_Get_Global_Settings (To_List ("typography")));

         Should_Use_Fluid_Typography_2 : constant Boolean :=
           (if Isset (Typography_Settings, "fluid") and then
               True = As_Boolean (Get (Typography_Settings, "fluid"))
            then True else Should_Use_Fluid_Typography);

         -- Defaults.
         Default_Maximum_Viewport_Width   : constant String  := "1600px";
         Default_Minimum_Viewport_Width   : constant String  := "768px";
         Default_Minimum_Font_Size_Factor : constant Float   := 0.75;
         Default_Scale_Factor             : constant Natural := 1;
         Default_Minimum_Font_Size_Limit  : constant String  := "14px";

         -- Font sizes.
         Fluid_Font_Size_Settings : constant Array_Type :=
           (if Isset (Preset, "fluid")
            then As_Array (Get (Preset, "fluid"))
            else Empty_Array); -- null
      begin
         if not Should_Use_Fluid_Typography_2 then
            return As_String (Get (Preset, "size"));
         end if;

         -- A font size has explicitly bypassed fluid calculations.
         if Fluid_Font_Size_Settings = Empty_Array then -- False
            return As_String (Get (Preset, "size"));
         end if;

         -- Try to grab explicit min and max fluid font sizes.
         declare
            Minimum_Font_Size_Raw : constant Boolean :=
              (if Isset (Fluid_Font_Size_Settings, "min")
               then As_Boolean (Get (Fluid_Font_Size_Settings, "min"))
               else False); -- null

            Maximum_Font_Size_Raw : constant Boolean :=
              (if Isset (Fluid_Font_Size_Settings, "max")
               then As_Boolean (Get (Fluid_Font_Size_Settings, "max"))
               else False); -- null

            -- Font sizes.
            Preferred_Size : constant Array_Type :=
              Wp_Get_Typography_Value_And_Unit (Get (Preset, "size"));

            --
            -- Normalizes the minimum font size limit according to the incoming unit,
            -- in order to perform comparative checks.
            --
            Minimum_Font_Size_Limit : constant Array_Type :=
              Wp_Get_Typography_Value_And_Unit (
                From_String (Default_Minimum_Font_Size_Limit),
                To_Array (List => (1 =>
                  Build ("coerce_to", As_String (Get (Preferred_Size, "unit")))
                ))
              );

            Maximum_Font_Size_Raw_String : Unbounded_String;
            Minimum_Font_Size_Raw_String : Unbounded_String;
         begin
            -- Protects against unsupported units.
            if Empty (Preferred_Size, "unit") then
               return As_String (Get (Preset, "size"));
            end if;

            -- Don't enforce minimum font size if a font size has explicitly set a
            -- min and max value.
            if
              Minimum_Font_Size_Limit.Length in 0 and then
--            not Empty (Minimum_Font_Size_Limit) and then
              (not Minimum_Font_Size_Raw and not Maximum_Font_Size_Raw)
            then
               --
               -- If a minimum size was not passed to this function
               -- and the user-defined font size is lower than
               -- minimum_font_size_limit, do not calculate a fluid value.
               --
               if
                 As_Integer (Get (Preferred_Size, "value")) <=
                 As_Integer (Get (Minimum_Font_Size_Limit, "value"))
               then
                  return As_String (Get (Preset, "size"));
               end if;
            end if;

            -- If no fluid max font size is available use the incoming value.
            if not Maximum_Font_Size_Raw then
               Maximum_Font_Size_Raw_String := +(
                 As_String (Get (Preferred_Size, "value")) &
                 As_String (Get (Preferred_Size, "unit")));
            end if;

            --
            -- If no minimumFontSize is provided, create one using
            -- the given font size multiplied by the min font size scale factor.
            --
            if not Minimum_Font_Size_Raw then
               declare
                  Calculated_Minimum_Font_Size : constant Float :=
                    Round (
                      Float'Value (As_String (Get (Preferred_Size, "value"))) *
                      Default_Minimum_Font_Size_Factor,
                      3
                    );
               begin
                  -- Only use calculated min font size if it's >
                  -- minimum_font_size_limit value.
                  if
                    not Empty (Minimum_Font_Size_Limit) and then
                    Calculated_Minimum_Font_Size <=
                    Float'Value (As_String (Get (Minimum_Font_Size_Limit, "value")))
                  then
                     Minimum_Font_Size_Raw_String := +(
                       As_String (Get (Minimum_Font_Size_Limit, "value")) &
                       As_String (Get (Minimum_Font_Size_Limit, "unit")));
                  else
                     Minimum_Font_Size_Raw_String := +(
                       Calculated_Minimum_Font_Size'Image &
                       As_String (Get (Preferred_Size, "unit")));
                  end if;
               end;
            end if;

            declare
               Fluid_Font_Size_Value : constant String :=
                 Wp_Get_Computed_Fluid_Typography_Value (To_Array (List => (
                   Build ("minimum_viewport_width", Default_Minimum_Viewport_Width),
                   Build ("maximum_viewport_width", Default_Maximum_Viewport_Width),
                   Build ("minimum_font_size",      Minimum_Font_Size_Raw),
                   Build ("maximum_font_size",      Maximum_Font_Size_Raw),
                   Build ("scale_factor",           Default_Scale_Factor)
                 ))
               );
            begin
               if not Empty (Fluid_Font_Size_Value) then
                  return "XXX-008"; -- Fluid_Font_Size_Value;
               end if;
            end;
         end;
      end;
      return As_String (Get (Preset, "size"));
   end Wp_Get_Typography_Font_Size_Value;

end Block_Typography;
