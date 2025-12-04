--
-- APIs to interact with global settings & styles.
--
-- @package WordPress
--

with Ada.Strings.Unbounded;

with Hb_Common;
with Globals;
with Php.Strings;

with Inc_Class_Wp_Theme_JSON;
with Inc_Class_Wp_Theme_JSON_Resolver;
with Inc_Functions;
with Inc_Functions_Wp_Styles;
with Inc_Load;
with Inc_Options;
with Inc_Script_Loader;
with Inc_Themes;

package body Inc_Global_Styles_And_Settings
is

   ----------------------------
   -- Wp_Get_Global_Settings --
   ----------------------------

   function Wp_Get_Global_Settings (Path    : List_Type  := Empty_List;
                                    Context : Array_Type := Empty_Array)
                                    return Multi_Type -- Array_Type
   is
      use Hb_Common;
      use Php;
      use Inc_Functions;

      Path_2 : constant List_Type :=
        (if not Empty (Context, "block_name")
         then Array_Merge (To_List (List => (
                +"blocks", +As_String (Get (Context, "block_name")))),
                           Path)
         else Path);

      Origin : constant String :=
        (if
           Isset (Context, "origin") and then
           "base" = As_String (Get (Context, "origin"))
         then "theme"
         else "custom");

      Settings : constant Multi_Type :=
        Inc_Class_Wp_Theme_JSON_Resolver.Get_Merged_Data (Origin).Get_Settings; -- ()

   begin
      return X_Wp_Array_Get (As_Array (Settings), Path_2, Settings);
   end Wp_Get_Global_Settings;

-- --
-- -- Gets the styles resulting of merging core, theme, and user data.
-- --
-- -- @since 5.9.0
-- --
-- -- @param array path    Path to the specific style to retrieve. Optional.
-- --                       If empty, will return all styles.
-- -- @param array context then
-- --     Metadata to know where to retrieve the path from. Optional.
-- --
-- --     @type string block_name Which block to retrieve the styles from.
-- --                              If empty, it"ll return the styles for the global context.
-- --     @type string origin     Which origin to take data from.
-- --                              Valid values are "all" (core, theme, and user) or "base" (core and theme).
-- --                              If empty or unknown, "all" is used.
-- -- end;
-- -- @return array The styles to retrieve.
-- --
-- function wp_get_global_styles( path = array(), context = array() ) then
--         if ( ! empty( context["block_name"] ) ) then
--                 path = array_merge( array( "blocks", context["block_name"] ), path );
--         end;

--         origin = "custom";
--         if ( isset( context["origin"] ) && "base" === context["origin"] ) then
--                 origin = "theme";
--         end;

--         styles = WP_Theme_JSON_Resolver::get_merged_data( origin )->get_raw_data()["styles"];

--         return _wp_array_get( styles, path, styles );
-- end;

   ------------------------------
   -- Wp_Get_Global_Stylesheet --
   ------------------------------

   function Wp_Get_Global_Stylesheet (Types : List_Type := Empty_List)
                                      return String
   is
      use Ada.Strings.Unbounded;
      use Php;
      use Hb_Common;
      use Inc_Class_Wp_Theme_JSON;

      -- Return cached value if it can be used and exists.
      -- It's cached by theme to make sure that theme switching clears the cache.
      Can_Use_Cached : constant Boolean :=
                Types.Is_Empty   and then
                not Globals.WP_DEBUG     and then
                not Globals.SCRIPT_DEBUG and then
                not Globals.REST_REQUEST and then
                not Inc_Load.Is_Admin;

      Transient_Name : constant String :=
        "global_styles_" & Inc_Themes.Get_Stylesheet;
   begin
      if Can_Use_Cached then
         declare
            Cached : constant String :=
              Inc_Options.Get_Transient (Transient_Name);
         begin
            if Cached /= "" then
               return Cached;
            end if;
         end;
      end if;

      declare
         Tree : constant Wp_Theme_JSON :=
           Inc_Class_Wp_Theme_JSON_Resolver.Get_Merged_Data;

         Supports_Theme_JSON : constant Boolean :=
           Inc_Class_Wp_Theme_JSON_Resolver.Theme_Has_Support;

         Types_2 : List_Type :=
           (if Types.Is_Empty and then not Supports_Theme_JSON
              then To_List (List => (+"variables", +"presets", +"base-layout-styles"))
            elsif Types.Is_Empty
              then To_List (List => (+"variables", +"styles", +"presets"))
            else   Types
           );
         --
         -- If variables are part of the stylesheet, then add them.
         -- This is so themes without a theme.json still work as before 5.9:
         -- they can override the default presets.
         -- See https://core.trac.wordpress.org/ticket/54782
         --
         Styles_Variables : Unbounded_String;
         Styles_REST      : Unbounded_String;
      begin
         if In_Array ("variables", Types_2, True) then
            --
            -- Only use the default, theme, and custom origins. Why?
            -- Because styles for `blocks` origin are added at a later phase
            -- (i.e. in the render cycle). Here, only the ones in use are rendered.
            -- @see wp_add_global_styles_for_blocks
            --
            declare
               Origins : constant List_Type :=
                 To_List (List => (+"default", +"theme", +"custom"));
            begin
               Styles_Variables := +Tree.Get_Stylesheet (To_List ("variables"),
                                                         Origins);
               Types_2          := Array_Diff (Types_2, To_List ("variables"));
            end;
         end if;

         --
         -- For the remaining types (presets, styles), we do consider origins:
         --
         -- - themes without theme.json: only the classes for the presets defined by
         --   core
         -- - themes with theme.json: the presets and styles classes, both from core
         --   and the theme
         --
         if not Types_2.Is_Empty then
            --
            -- Only use the default, theme, and custom origins. Why?
            -- Because styles for `blocks` origin are added at a later phase
            -- (i.e. in the render cycle). Here, only the ones in use are rendered.
            -- @see wp_add_global_styles_for_blocks
            --
            declare
               Origins : List_Type :=
                 (if Supports_Theme_JSON
                    then To_List (List => (+"default", +"theme", +"custom"))
                    else To_List ("default"));
            begin
               Styles_REST := +Tree.Get_Stylesheet (Types_2, Origins);
            end;
         end if;

         declare
            Stylesheet : constant String := -(Styles_Variables & Styles_REST);
         begin
            if Can_Use_Cached then
               -- Cache for a minute.
               -- This cache doesn't need to be any longer, we only want to avoid
               -- spikes on high-traffic sites.
               Inc_Options.Set_Transient (Transient_Name, Stylesheet,
                                          Globals.MINUTE_IN_SECONDS);
            end if;

            return Stylesheet;
         end;
      end;
   end Wp_Get_Global_Stylesheet;

-- --
-- -- Returns a string containing the SVGs to be referenced as filters (duotone).
-- --
-- -- @since 5.9.1
-- --
-- -- @return string
-- --
-- function wp_get_global_styles_svg_filters() then
--         -- Return cached value if it can be used and exists.
--         -- It's cached by theme to make sure that theme switching clears the cache.
--         can_use_cached = (
--                 ( ! defined( "WP_DEBUG" ) || ! WP_DEBUG ) &&
--                 ( ! defined( "SCRIPT_DEBUG" ) || ! SCRIPT_DEBUG ) &&
--                 ( ! defined( "REST_REQUEST" ) || ! REST_REQUEST ) &&
--                 ! is_admin()
--         );
--         transient_name = "global_styles_svg_filters_" . get_stylesheet();
--         if ( can_use_cached ) then
--                 cached = get_transient( transient_name );
--                 if ( cached ) then
--                         return cached;
--                 end;
--         end;

--         supports_theme_json = WP_Theme_JSON_Resolver::theme_has_support();

--         origins = array( "default", "theme", "custom" );
--         if ( ! supports_theme_json ) then
--                 origins = array( "default" );
--         end;

--         tree = WP_Theme_JSON_Resolver::get_merged_data();
--         svgs = tree->get_svg_filters( origins );

--         if ( can_use_cached ) then
--                 // Cache for a minute, same as wp_get_global_stylesheet.
--                 set_transient( transient_name, svgs, MINUTE_IN_SECONDS );
--         end;

--         return svgs;
-- end;

   function Filter_Core (Item : String) return Boolean;

   function Filter_Core (Item : String) return Boolean
   is
   begin
      if Php.Strings.Strpos (Item, "core/") /= 0 then
         return True;
      end if;
      return False;
   end Filter_Core;

   -------------------------------------
   -- Wp_Add_Global_Styles_For_Blocks --
   -------------------------------------

   procedure Wp_Add_Global_Styles_For_Blocks
   is
      use Ada.Strings.Unbounded;
      use Hb_Common;
      use Php;
      use Php.Strings;
      use Inc_Class_Wp_Theme_JSON;
      use Inc_Functions_Wp_Styles;
      use Inc_Script_Loader;

      Tree        : constant Wp_Theme_JSON :=
        Inc_Class_Wp_Theme_JSON_Resolver.Get_Merged_Data;

      Block_Nodes : constant Array_Type := Tree.Get_Styles_Block_Nodes;
   begin
      for Metadata_2 in Block_Nodes.Iterate loop
         declare
            Metadata  : constant Array_Type := As_Array (Element (Metadata_2));
            Block_CSS : constant String := Tree.Get_Styles_For_Block (Metadata);
         begin
            if not Wp_Should_Load_Separate_Core_Block_Assets then
               Wp_Add_Inline_Style ("global-styles", Block_CSS);
               goto Continue;
            end if;

            declare
               Stylesheet_Handle : Unbounded_String := +"global-styles";
            begin
               if Isset (Metadata, "name") then
                  --
                  -- These block styles are added on block_render.
                  -- This hooks inline CSS to them so that they are loaded conditionally
                  -- based on whether or not the block is used on the page.
                  --
                  if Str_Starts_With (As_String (Get (Metadata, "name")), "core/") then
                     declare
                        Block_Name : constant String :=
                          Str_Replace ("core/", "", As_String (Get (Metadata, "name")));
                     begin
                        Stylesheet_Handle := +"wp-block-" & Block_Name;
                     end;
                  end if;
                  Wp_Add_Inline_Style (-Stylesheet_Handle, Block_CSS);
               end if;

               -- The likes of block element styles from theme.json do not have
               -- metadata["name"] set.
               if
                 not Isset (Metadata, "name") and then
                 not Empty (As_String (Get (Metadata, "path")))
               then
                  declare
                     Result : constant List_Type :=
                       Array_Values (
                         Array_Filter (
                           As_Array (Get (Metadata, "path")),
                           Filter_Core'Access
                       ));
                     Result_0 : constant String := -Result (Result.First_Index); -- (0)
                  begin
                     if Isset (Result_0) then
                        if Str_Starts_With (Result_0, "core/") then
                           declare
                              Block_Name : constant String :=
                                Str_Replace ("core/", "", Result_0);
                           begin
                              Stylesheet_Handle := +"wp-block-" & Block_Name;
                           end;
                        end if;
                        Wp_Add_Inline_Style (-Stylesheet_Handle, Block_CSS);
                     end if;
                  end;
               end if;
            end;
            << Continue >>
         end;
      end loop;
   end Wp_Add_Global_Styles_For_Blocks;

end Inc_Global_Styles_And_Settings;
