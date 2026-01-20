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

with Inc_Plugins;

-- with Adi_Menu;
-- with Adi_Nav_Menus;

-- with Inc_Default_Filters;
-- with Inc_Admin_Bar;
-- with Inc_Class_Wp_Admin_Bar;
-- with Inc_Class_Wp_Scripts;
-- with Inc_Class_Wp_Posts;
-- with Inc_Posts;

package body Binder
is
   use Ada.Strings.Unbounded;
   use Hb_Common;

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

      end if;

      PHP_To_Web_Server;

      Inc_Plugins.Dump_Hooks;

      Payload := +Php.Echoing.Get_Echo;
      return AWS.Response.Build ("text/html", Payload);

   exception
      when Redirect_Signal | Php.Errors.Program_Termination =>
         declare
            use Php.HTML;

            Header : constant String := Get_Header;
         begin
            Put_Line ("redirect:");
            Put_Line ("  header: " & Header);
--          return AWS.Response.URL (Location => H);
            return AWS.Response.URL (Location => "XXX-958");
         end;

   end Render;

end Binder;
