with Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

with Php;
with Hb_Common;

with Adm_Credits;
with Adm_Edit;
with Adm_Edit_Tags;
with Adm_Post;
with Adm_Menu_Header;
with Adm_Admin;
with Adm_Menu;

with Adi_Nav_Menus;
with Adm_Nav_Menus;
with Adm_Admin_Header;
with Adi_Menu;

with Inc_Default_Filters;
with Inc_Admin_Bar;
with Inc_Class_Wp_Admin_Bar;
with Inc_Class_Wp_Scripts;
with Inc_Class_Wp_Posts;
with Inc_Posts;

package body Binder
is
   use Ada.Strings.Unbounded;
   use Hb_Common;

   -----------------------
   -- Web_Server_To_PHP --
   -----------------------

   procedure Web_Server_To_PHP
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
      Web_Server_To_PHP;

      if Index (URL, "/wp-admin/credits.php") /= 0 then
         Adm_Credits.Render;

      elsif Index (URL, "/wp-admin/edit.php") /= 0 then
         Adm_Edit.Render;

      elsif Index (URL, "/wp-admin/edit-tags.php") /= 0 then
         Adm_Edit_Tags.Render;

      elsif Index (URL, "/wp-admin/post.php") /= 0 then
         Adm_Post.Render;

      end if;

      PHP_To_Web_Server;

      Payload := +Php.Get_Echo;
      return AWS.Response.Build ("text/html", Payload);
   end Render;

end Binder;
