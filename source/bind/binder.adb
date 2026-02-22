--
--
--
with Ada.Strings.Fixed;

with Php.Echoing;
with Php.Errors;
with Php.HTML;

with Logging;
with UStrings;

with Adm_About;
with Adm_Credits;
with Adm_Edit;
with Adm_Edit_Tags;
with Adm_Index;
with Adm_Install;
with Adm_Load_Scripts;
with Adm_Load_Styles;
with Adm_Post;
with Adm_Privacy;
with Adm_Upgrade;

with Wp_Index;
with Wp_Login;

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
      use UStrings;

      URL     : constant String := AWS.Status.URL (Request);
      Payload : UString;
   begin
      Web_Server_To_PHP (Status => Request);

      if Index (URL, "/wp-admin/credits.php") /= 0 then
         Adm_Credits.Render;

      elsif Index (URL, "/wp-admin/privacy.php") /= 0 then
         Adm_Privacy.Run;

      elsif Index (URL, "/wp-admin/about.php") /= 0 then
         Adm_About.Render;

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

      elsif Index (URL, "/wp-admin") /= 0 then
         Adm_Index.Render;

      elsif URL = "/" or URL = "" then
         Wp_Index.Render;

      elsif Index (URL, "/wp-login.php") /= 0 then
         Wp_Login.Render;

      end if;

      PHP_To_Web_Server;

--    Inc_Plugins.Dump_Hooks;

      Payload := +Php.Echoing.Get_Echo;
      return AWS.Response.Build ("text/html", Payload);

   exception
      when Php.Errors.Program_Termination =>
         Logging.Log ("binder", "program_termination");
         Logging.Log ("binder", "doing redirect");
         declare
            use Php.HTML;

            Header   : constant String  := Get_Header;
            Position : constant Natural := Index (Header, " ");
            Location : constant String  := Header (Position + 1 .. Header'Last);
         begin
            Logging.Log ("binder", "redirect:");
            Logging.Log ("binder", "  header: " & Header);
            Logging.Log ("binder", "  locati: " & Location);

            return AWS.Response.URL (Location => Location);
         end;
         return AWS.Response.Build ("text/html", Php.Echoing.Get_Echo);

      when Redirect_Signal =>
         Logging.Log ("binder", "redirect");
         declare
            use Php.HTML;

            Header   : constant String  := Get_Header;
            Position : constant Natural := Index (Header, " ");
            Location : constant String  := Header (Position + 1 .. Header'Last);
         begin
            Logging.Log ("binder", "redirect:");
            Logging.Log ("binder", "  header: " & Header);
            Logging.Log ("binder", "  locati: " & Location);

            return AWS.Response.URL (Location => Location);
         end;

   end Render;

end Binder;
