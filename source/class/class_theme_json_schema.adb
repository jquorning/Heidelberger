--
-- WP_Theme_JSON_Schema class
--
-- @package WordPress
-- @subpackage Theme
-- @since 5.9.0
--

with Php.Lists;
with Php.Strings;

with Class_Theme_JSON;
with Inc_Functions;

package body Class_Theme_JSON_Schema
is

   -------------
   -- Migrate --
   -------------

   function Migrate (Theme_JSON : Array_Type)
                     return Array_Type
   is
      use Array_Lists;

      Theme_JSON_2 : Array_Type := Theme_JSON;
   begin
      if not Isset (Theme_JSON, "version") then
         Theme_JSON_2 := To_Array_Type ([
           Build ("version", Class_Theme_JSON.LATEST_SCHEMA)
         ]);
      end if;

      if 1 = As_Integer (Get (Theme_JSON, "version")) then
         Theme_JSON_2 := Migrate_V1_To_V2 (Theme_JSON);
      end if;

      return Theme_JSON_2;
   end Migrate;

   ----------------------
   -- Migrate_V1_To_V2 --
   ----------------------

   function Migrate_V1_To_V2 (Old : Array_Type)
                              return Array_Type
   is
      -- Copy everything.
      New_2 : Array_Type := Old;
   begin
      -- Overwrite the things that changed.
      if Isset (Old, "settings") then
         Set (New_2, "settings",
              From_Array (
                Rename_Paths (As_Array (Get (Old, "settings")),
                              V1_TO_V2_RENAMED_PATHS)));
      end if;

      -- Set the new version.
      Set (New_2, "version", From_Integer (2));

      return New_2;
   end Migrate_V1_To_V2;

   ------------------
   -- Rename_Paths --
   ------------------

   function Rename_Paths (Settings        : Array_Type;
                          Paths_To_Rename : Array_Type)
                          return Array_Type
   is
      New_Settings : Array_Type := Settings;
   begin
      -- Process any renamed/moved paths within default settings.
      Rename_Settings (New_Settings, Paths_To_Rename);

      -- Process individual block settings.
      if
        Isset (New_Settings, "blocks") and then
        Kind_Of (Get (New_Settings, "blocks")) = Kind_Array
        -- Is_Array (Get (New_Settings, "blocks"))
      then
         for Block_Settings in As_Array (Get (New_Settings, "blocks")).Iterate loop
            -- This will not work (jq)
            declare
               Block_Settings_2 : Array_Type := As_Array (Element (Block_Settings));
            begin
               Rename_Settings (Block_Settings_2, Paths_To_Rename);
            end;
         end loop;
      end if;

      return New_Settings;
   end Rename_Paths;

   ---------------------
   -- Rename_Settings --
   ---------------------

   procedure Rename_Settings (Settings        : in out Array_Type;
                              Paths_To_Rename : Array_Type)
   is
      use Php.Strings;
      use Inc_Functions;
   begin
      for A in Paths_To_Rename.Iterate loop
         declare
            Original : constant String := Key (A);
            Renamed  : constant String := As_String (Element (A));

            Original_Path : constant List_Type := Explode (".", Original);
            Renamed_Path  : constant List_Type := Explode (".", Renamed);

            Current_Value : constant Multi_Type :=
              X_Wp_Array_Get (Settings, Original_Path, From_Null);
         begin
            if Kind_Of (Current_Value) /= Kind_Null then
               X_Wp_Array_Set (Settings, Renamed_Path, Current_Value);
               Unset_Setting_By_Path (Settings, Original_Path);
            end if;
         end;
      end loop;
   end Rename_Settings;

   ---------------------------
   -- Unset_Setting_By_Path --
   ---------------------------

   procedure Unset_Setting_By_Path (Settings : in out Array_Type;
                                    Path     : List_Type)
   is
      use Php.Lists;

      Path_2       : List_Type  := Path;
      Tmp_Settings : Array_Type := Settings;
      -- phpcs:ignore VariableAnalysis.CodeAnalysis.VariableAnalysis.UnusedVariable

      Last_Key : constant String := List_Pop (Path_2);
   begin
      for Key of Path_2 loop
         Tmp_Settings := As_Array (Get (Tmp_Settings, Key));
      end loop;

      Delete (Ref (Tmp_Settings, Last_Key));
--    unset( $tmp_settings[ $last_key ] );
   end Unset_Setting_By_Path;

end Class_Theme_JSON_Schema;
