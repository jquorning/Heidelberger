--
-- Filesystem API: Top-level functionality
--
-- Functions for reading, writing, modifying, and deleting files on the file system.
-- Includes functionality for theme-specific files as well as operations for uploading,
-- archiving, and rendering output when necessary.
--
-- @package WordPress
-- @subpackage Filesystem
-- @since 2.3.0
--

with Php.Strings;

with Arrays;
with Binder;
with Globals;
with UStrings;

with Inc_Formatting;
with Inc_Link_Templates;
with Inc_Options;

package body Adi_Files
is
   use Arrays;

   -------------------
   -- Get_Home_Path --
   -------------------

   function Get_Home_Path
            return String
   is
      use Php.Strings;
      use Binder;
      use Globals;
      use UStrings;
      use Inc_Formatting;
      use Inc_Link_Templates;
      use Inc_Options;

      Home     : constant String :=
        Set_URL_Scheme (Get_Option ("home"), "http");

      Site_URL : constant String :=
        Set_URL_Scheme (Get_Option ("siteurl"), "http");

      Home_Path : UString;
   begin
      if not Empty (Home) and then 0 /= Strcasecmp (Home, Site_URL) then
         declare
            Wp_Path_Rel_To_Home : constant String :=
              Str_Ireplace (Home, "", Site_URL); -- siteurl - home

            Pos : constant Natural :=
              Strripos (
                Str_Replace ("\\", "/",
                             Get_As_String (X_SERVER, "SCRIPT_FILENAME")),
                             Trailing_Slash_It (Wp_Path_Rel_To_Home));

            Home_Path_1 : constant String :=
              Substr (Get_As_String (X_SERVER, "SCRIPT_FILENAME"), 0, Pos);
         begin
            Home_Path := +Trailing_Slash_It (Home_Path_1);
         end;
      else
         Home_Path := +ABSPATH;
      end if;

      return Str_Replace ("\\", "/", -Home_Path);
   end Get_Home_Path;

end Adi_Files;
