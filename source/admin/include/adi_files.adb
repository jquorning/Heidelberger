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

with Php.Echoing;
with Php.Strings;

with Binder;
with Constants;
with UStrings;

with Inc_Formatting;
with Inc_Link_Templates;
with Inc_Options;

package body Adi_Files
is

   -------------------
   -- Get_Home_Path --
   -------------------

   function Get_Home_Path
            return String
   is
      use Php.Strings;
      use Binder;
      use Constants;
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

   ---------------------------------------------------
   -- Wp_Print_Request_Filesystem_Credentials_Modal --
   ---------------------------------------------------

   procedure Wp_Print_Request_Filesystem_Credentials_Modal
   is
      use Php.Echoing;
      use Inc_Link_Templates;

      Filesystem_Method : String := Get_Filesystem_Method;
      Filesystem_Credentials_Are_Stored : Boolean;
      Request_Filesystem_Credentials_2  : Boolean;
   begin
      OB_Start;

      Filesystem_Credentials_Are_Stored :=
        Request_Filesystem_Credentials (Self_Admin_URL);

      OB_End_Clean;

      Request_Filesystem_Credentials_2 :=
        ("direct" /= Filesystem_Method and then
         not Filesystem_Credentials_Are_Stored);

      if not Request_Filesystem_Credentials_2 then
         return;
      end if;

      Echo ("<div id=""request-filesystem-credentials-dialog"" class=""notification-dialog-wrap request-filesystem-credentials-dialog"">");
      Echo ("  <div class=""notification-dialog-background""></div>");
      Echo ("  <div class=""notification-dialog"" role=""dialog"" aria-labelledby=""request-filesystem-credentials-title"" tabindex=""0"">");
      Echo ("    <div class=""request-filesystem-credentials-dialog-content"">");
      Echo ("      " & Boolean'Image (Request_Filesystem_Credentials (Site_URL)));
      Echo ("    </div>");
      Echo ("  </div>");
      Echo ("</div>");

   end Wp_Print_Request_Filesystem_Credentials_Modal;

end Adi_Files;
