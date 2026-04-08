--
--
--
with Ada.Strings.Fixed;

with Php.Echoing;
with Php.Errors;
with Php.HTML;

with Templates_Parser;

with Logging;
with UStrings;

with Adm_About;
with Adm_Credits;
with Adm_Edit;
with Adm_Edit_Tags;
with Adm_Freedoms;
with Adm_Index;
with Adm_Install;
with Adm_Load_Scripts;
with Adm_Load_Styles;
with Adm_Plugins;
with Adm_Post;
with Adm_Privacy;
with Adm_Themes;
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

   function Render (Request : in AWS.Status.Data) return AWS.Response.Data is
      use Ada.Strings.Fixed;
      use UStrings;

      URI     : constant String := AWS.Status.URI (Request);
      URL     : constant String := AWS.Status.URL (Request);
      Payload : UString;
   begin
      Php.Echoing.Clear_Echo;

      Web_Server_To_PHP (Status => Request);

      if Index (URL, "/wp-admin/credits.php") /= 0 then
         Adm_Credits.Render;

      elsif Index (URL, "/wp-admin/privacy.php") /= 0 then
         Adm_Privacy.Run;

      elsif Index (URL, "/wp-admin/about.php") /= 0 then
         Adm_About.Render;

      elsif Index (URL, "/wp-admin/freedoms.php") /= 0 then
         Adm_Freedoms.Render;

      elsif Index (URL, "/wp-admin/edit.php") /= 0 then
         Adm_Edit.Render;

      elsif Index (URL, "/wp-admin/edit-tags.php") /= 0 then
         Adm_Edit_Tags.Render;

      elsif Index (URL, "/wp-admin/install.php") /= 0 then
         Adm_Install.Run;

      elsif Index (URL, "/wp-admin/plugins.php") /= 0 then
         Adm_Plugins.Render;

      elsif Index (URL, "/wp-admin/post.php") /= 0 then
         Adm_Post.Render;

      elsif Index (URL, "/wp-admin/themes.php") /= 0 then
         Adm_Themes.Render;

      elsif Index (URL, "/wp-admin/load-scripts.php") /= 0 then
         Adm_Load_Scripts.Run;

      elsif Index (URL, "/wp-admin/load-styles.php") /= 0 then
         Adm_Load_Styles.Run;

      elsif Index (URL, "/wp-admin/upgrade.php") /= 0 then
         Adm_Upgrade.Render;

      elsif Index (URI, "/wp-admin/images") /= 0 then
         declare
            use Templates_Parser;

            Payload : constant String := Parse (Filename => URI);
         begin
            return AWS.Response.Build ("image/svg", Payload);
         end;

      elsif Index (URI, "/wp-includes/css") /= 0
        or else Index (URI, "/wp-admin/css") /= 0
      then
         declare
            use Templates_Parser;

            Payload : constant String := Parse (Filename => URI);
         begin
            Logging.Log ("Render", URI);
            return AWS.Response.Build ("text/css", Payload);
         end;

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
      when Php.Errors.PHP_Program_Termination =>
         Logging.Log ("binder", "php_program_termination");
         Logging.Log ("binder", "doing redirect");
         declare
            use Php.HTML;

            Header   : constant String := Get_Header;
            Position : constant Natural := Index (Header, " ");
            Location : constant String := Header (Position + 1 .. Header'Last);
         begin
            Logging.Log ("binder", "header: " & Header);
            Logging.Log ("binder", "locati: " & Location);
            if Location /= "Location:" then
               Logging.Log ("binder", "location not found -- baffeled!");
               return AWS.Response.Build ("text/html", Php.Echoing.Get_Echo);
            end if;
            return AWS.Response.URL (Location => Location);
         end;
         --       return AWS.Response.Build ("text/html", Php.Echoing.Get_Echo);

      when Redirect_Signal =>
         Logging.Log ("binder", "redirect");
         declare
            use Php.HTML;

            Header   : constant String := Get_Header;
            Position : constant Natural := Index (Header, " ");
            Location : constant String := Header (Position + 1 .. Header'Last);
         begin
            Logging.Log ("binder", "redirect:");
            Logging.Log ("binder", "  header: " & Header);
            Logging.Log ("binder", "  locati: " & Location);

            return AWS.Response.URL (Location => Location);
         end;

   end Render;

end Binder;
