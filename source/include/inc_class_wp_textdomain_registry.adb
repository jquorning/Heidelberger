--
-- Locale API: WP_Textdomain_Registry class
--
-- @package WordPress
-- @subpackage i18n
-- @since 6.1.0
--

with Ada.Strings.Unbounded;
-- with Ada.Text_IO; use Ada.Text_IO;

with Arrays;
with Globals;
with Hb_Common;
-- with Php;

with Inc_Formatting;

package body Inc_Class_Wp_Textdomain_Registry
is
   use Ada.Strings.Unbounded;
   use Arrays;
   use Hb_Common;
   use Inc_Formatting;

   ---------
   -- Get --
   ---------

   function Get (This   : in out Wp_Textdomain_Registry;
                 Domain : String;
                 Locale : String)
                 return String
   is
   begin
      if Isset (This.Alll (Domain) (Locale)) then
         return This.Alll (Domain) (Locale);
      end if;

      return This.Get_Path_From_Lang_Dir (Domain, Locale);
   end Get;

   ---------
   -- Has --
   ---------

   function Has (This   : Wp_Textdomain_Registry;
                 Domain : String)
                 return Boolean
   is
   begin
      return
        not Empty (This.Current (Domain)) or else
        This.Alll (Domain).Is_Empty;
--      Empty (This.Alll (Domain));
   end Has;

   ---------
   -- Set --
   ---------

   procedure Set (This   : in out Wp_Textdomain_Registry;
                  Domain : String;
                  Locale : String;
                  Path   : String)
   is
      Path_2 : constant String := (if Path /= ""
                                   then Trailingslashit (Path) else ""); -- False
      Map : String_Maps.Map;
   begin
      Map.Include (Key      => Locale,
                   New_Item => Path_2);

      This.Alll.Include (Key      => Domain,
                         New_Item => Map);

      This.Current.Include (Key      => Domain,
                            New_Item => This.Alll (Domain) (Locale));
   end Set;

   ---------------------
   -- Set_Custom_Path --
   ---------------------

   procedure Set_Custom_Path (This   : in out Wp_Textdomain_Registry;
                              Domain : String;
                              Path   : String)
   is
   begin
      This.Custom_Paths (Domain) := Untrailingslashit (Path);
   end Set_Custom_Path;

   ----------------------------
   -- Get_Path_From_Lang_Dir --
   ----------------------------

   function Get_Path_From_Lang_Dir (This   : in out Wp_Textdomain_Registry;
                                    Domain : String;
                                    Locale : String)
                                    return String
   is
      Locations : List_Type := To_List (List => (
         +Globals.WP_LANG_DIR & "/plugins",
         +Globals.WP_LANG_DIR & "/themes"
      ));
      Mofile : Unbounded_String;
      Path   : Unbounded_String;
   begin
      if Isset (This.Custom_Paths (Domain)) then
         Locations.Append (+This.Custom_Paths (Domain));
      end if;

      Mofile := +"domain-locale.mo";

      for Location of Locations loop
         if This.Cached_Mo_Files (-Location) /= "" then
--       if not Isset (-This.Cached_Mo_Files (Location)) then
            This.Set_Cached_Mo_Files (-Location);
         end if;

         Path := Location & "/" & Mofile;

         if True then
--       if In_Array (-Path, This.Cached_Mo_Files (Location), True) then
            This.Set (Domain, Locale, -Location);

            return Trailingslashit (-Location);
         end if;
      end loop;

      -- If no path is found for the given locale and a custom path has been set
      -- using load_plugin_textdomain/load_theme_textdomain, use that one.
      if "en_US" /= Locale and then Isset (This.Custom_Paths (Domain)) then
         Path := +Trailingslashit (This.Custom_Paths (Domain));
         This.Set (Domain, Locale, -Path);
         return -Path;
      end if;

      This.Set (Domain, Locale, ""); -- False

      return ""; -- False
   end Get_Path_From_Lang_Dir;

   -------------------------
   -- Set_Cached_Mo_Files --
   -------------------------

   procedure Set_Cached_Mo_Files (This : in out Wp_Textdomain_Registry;
                                  Path : String)
   is
      Mo_Files : String_Maps.Map;
   begin
      This.Cached_Mo_Files (Path) := ""; -- String_Maps.Empty_Map;

--    Mo_Files := Php.Glob (Path & "/*.mo");

      if not Mo_Files.Is_Empty then
         null; -- This.Cached_Mo_Files.include (Path, Mo_Files);
      end if;
   end Set_Cached_Mo_Files;

end Inc_Class_Wp_Textdomain_Registry;
