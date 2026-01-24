--
--
--
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Php.Echoing;
with Php.Errors;
with Php.HTML;

with Hb_Common;

-- with Adm_Admin;
-- with Adm_Admin_Header;
with Adm_Credits;
with Adm_Edit;
with Adm_Edit_Tags;
with Adm_Install;
with Adm_Load_Scripts;
with Adm_Load_Styles;
-- with Adm_Menu_Header;
-- with Adm_Menu;
-- with Adm_Nav_Menus;
with Adm_Post;
with Adm_Privacy;
with Adm_Upgrade;
with Wp_Login;
-- with Inc_Plugins;

-- with Adi_Menu;
-- with Adi_Nav_Menus;

-- with Inc_Default_Filters;
-- with Inc_Admin_Bar;
-- with Class_Admin_Bar;
-- with Class_Scripts;
-- with Inc_Class_Wp_Posts;
-- with Inc_Posts;

package body Binder
is

   -----------------------
   -- Web_Server_To_PHP --
   -----------------------

   procedure Web_Server_To_PHP (Status : AWS.Status.Data)
   is separate;

   -----------------------
   -- PHH_To_Web_Server --
   -----------------------

   procedure PHP_To_Web_Server
   is separate;

   ------------
   -- Render --
   ------------

   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data
   is
      use Ada.Strings.Fixed;
      use Ada.Strings.Unbounded;
      use Hb_Common;

      URL     : constant String := AWS.Status.URL (Request);
      Payload : Unbounded_String;
   begin
      Web_Server_To_PHP (Status => Request);

      if Index (URL, "/wp-admin/credits.php") /= 0 then
         Adm_Credits.Render;

      elsif Index (URL, "/wp-admin/privacy.php") /= 0 then
         Adm_Privacy.Run;

      elsif Index (URL, "/wp-admin/edit.php") /= 0 then
         Adm_Edit.Render;

      elsif Index (URL, "/wp-admin/edit-tags.php") /= 0 then
         Adm_Edit_Tags.Render;

      elsif Index (URL, "/wp-admin/install.php") /= 0 then
         Adm_Install.Run;

      elsif Index (URL, "/wp-admin/post.php") /= 0 then
         Adm_Post.Render;

      elsif Index (URL, "/wp-admin/load-scripts.php") /= 0 then
         Adm_Load_Scripts.Run;

      elsif Index (URL, "/wp-admin/load-styles.php") /= 0 then
         Adm_Load_Styles.Run;

      elsif Index (URL, "/wp-admin/upgrade.php") /= 0 then
         Adm_Upgrade.Render;

      elsif Index (URL, "/wp-login.php") /= 0 then
         Wp_Login.Render;

      end if;

      PHP_To_Web_Server;

--    Inc_Plugins.Dump_Hooks;

      Payload := +Php.Echoing.Get_Echo;
      return AWS.Response.Build ("text/html", Payload);

   exception
      when Php.Errors.Program_Termination =>
         return AWS.Response.Build ("text/html", Php.Echoing.Get_Echo);

      when Redirect_Signal =>
         declare
            use Php.HTML;

            Header   : constant String  := Get_Header;
            Position : constant Natural := Index (Header, " ");
            Location : constant String  := Header (Position + 1 .. Header'Last);
         begin
            Put_Line ("redirect:");
            Put_Line ("  header: " & Header);
            Put_Line ("  locati: " & Location);

            return AWS.Response.URL (Location => Location);
         end;

   end Render;

end Binder;
