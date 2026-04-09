--
--
--
with Ada.Strings.Fixed;

with AWS.MIME;

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
   -- PHP_To_Web_Server --
   -----------------------

   procedure PHP_To_Web_Server
   is separate;

   ----------------
   -- Serializer --
   ----------------

   protected Serializer is
      entry Aquire;
      entry Release;
   private
      Busy : Boolean := False;
   end Serializer;

   protected body Serializer is

      entry Aquire when not Busy is
      begin
         Busy := True;
      end Aquire;

      entry Release when True is
      begin
         Busy := False;
      end Release;
   end Serializer;

   ------------
   -- Render --
   ------------

   function Render (Request : in AWS.Status.Data) return AWS.Response.Data is
      use Ada.Strings.Fixed;
      use AWS.MIME;
      use UStrings;

      type MIME_Type is (HTML, CSS, SVG, Javascript);
      MIME : MIME_Type := HTML;

      function To_MIME (MIME : MIME_Type) return String;
      procedure Release;

      function To_MIME (MIME : MIME_Type) return String is
      begin
         return
           (case MIME is
              when HTML       => Text_HTML,
              when CSS        => Text_CSS,
              when SVG        => Image_SVG,
              when Javascript => Text_Javascript);
      end To_MIME;

      procedure Release is
      begin
         Logging.Log ("release", "before");
         Serializer.Release;
         Logging.Log ("release", "after");
      end Release;

      URI     : constant String := AWS.Status.URI (Request);
      URL     : constant String := AWS.Status.URL (Request);
      Payload : UString;
   begin
      Logging.Log ("aquire", "before");
      Serializer.Aquire;
      Logging.Log ("aquire", "after");

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
         MIME := Javascript;
         Adm_Load_Scripts.Run;

      elsif Index (URL, "/wp-admin/load-styles.php") /= 0 then
         MIME := CSS;
         Adm_Load_Styles.Run;

      elsif Index (URL, "/wp-admin/upgrade.php") /= 0 then
         Adm_Upgrade.Render;

      elsif Index (URI, "/wp-admin/images") /= 0 then
         Logging.Log ("render", URI);
         MIME := SVG;
         declare
            use Templates_Parser;

            Payload : constant String := Parse (Filename => "./" & URI);
         begin
            Release;
            return AWS.Response.Build (To_MIME (SVG), Payload);
         end;

      elsif Index (URI, "/wp-includes/css") /= 0
        or else Index (URI, "/wp-admin/css") /= 0
      then
         declare
            use Templates_Parser;

            Payload : constant String := Parse (Filename => URI);
         begin
            Logging.Log ("Render", URI);

            Release;
            return AWS.Response.Build (To_MIME (CSS), Payload);
         end;

      elsif Index (URL, "/wp-admin") /= 0 then
         Adm_Index.Render;

      elsif URL = "/" or URL = "" then
         Wp_Index.Render;

      elsif Index (URL, "/wp-login.php") /= 0 then
         Wp_Login.Render;

      end if;

      PHP_To_Web_Server;

      Payload := +Php.Echoing.Get_Echo;
      Release;
      return AWS.Response.Build (To_MIME (MIME), Payload);

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

               Release;
               return AWS.Response.Build (To_MIME (HTML), Php.Echoing.Get_Echo);
            end if;

            Release;
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

            Release;
            return AWS.Response.URL (Location => Location);
         end;

   end Render;

end Binder;
