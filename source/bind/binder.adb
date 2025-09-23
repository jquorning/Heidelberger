with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
with Ada.Text_Io;

with Adm_Credits;
with Php;
with Hb_Common;

package body Binder
is
   use Ada.Text_Io;
   use Ada.Strings.Unbounded;
   use Hb_Common;

   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data
   is
      use Ada.Strings.Fixed;

      Url     : constant String := Aws.Status.Url (Request);
      Payload : Unbounded_String;
   begin
--      Put_Line ("url: " & Url);

      if Index (Url, "/wp-admin/credits.php") /= 0 then
         Adm_Credits.Render;
         Payload := +Php.Get_Echo;
         return AWS.Response.Build ("text/html", Payload);
      end if;

      return AWS.Response.Build ("text/html", "Not avaliable");
   end Render;

end Binder;
