
with Ada.Strings.Fixed;
with Ada.Text_IO;

with AWS.Config.Set;
--  with AWS.Response;
--  with AWS.Services.Page_Server;
with AWS.Services.Dispatchers.URI;
with AWS.Server;
--  with AWS.Status;

with HB_Edit;
with HB_Edit_Tags;
with HB_Post;

package body HB_Server is

   Server_Name : constant String := "Heidelberger";

   procedure Register_Dispatcher;

   Server     : AWS.Server.HTTP;
   Dispatcher : AWS.Services.Dispatchers.URI.Handler;

   -------------------------
   -- Register_Dispatcher --
   -------------------------

   procedure Register_Dispatcher
   is
      use AWS.Services.Dispatchers.URI;
   begin
      Register (Dispatcher, "/hb-admin/edit",      HB_Edit.Render'Access);
      Register (Dispatcher, "/hb-admin/edit-tags", HB_Edit_Tags.Render'Access);
      Register (Dispatcher, "/hb-admin/post",      HB_Post.Render'Access);
   end Register_Dispatcher;

   -----------
   -- Start --
   -----------

   procedure Start
   is
      use Ada.Text_IO;
      use AWS.Config;

      Server_Config : Object := Default_Config;
   begin
      Set.Server_Name    (Server_Config, Server_Name);
      Set.Server_Port    (Server_Config, 8080);
      Set.Max_Connection (Server_Config, 5);
      Set.Reuse_Address  (Server_Config, True);

      Register_Dispatcher;

      AWS.Server.Start (Web_Server => Server,
                        Dispatcher => Dispatcher,
                        Config     => Server_Config);

      Put_Line ("Server was started.");
      Put_Line ("Web address: http://localhost:" &
                Ada.Strings.Fixed.Trim ("8080",
                                        Side => Ada.Strings.Left) &
                "/index.html");
      Put_Line ("Press ""Q"" for quit.");
   end Start;

   --------------
   -- Shutdown --
   --------------

   procedure Shutdown
   is
      use Ada.Text_IO;
   begin
      Put ("Shutting down server...");
      AWS.Server.Shutdown (Web_Server => Server);
   end Shutdown;

   ----------
   -- Wait --
   ----------

   procedure Wait
   is
   begin
      AWS.Server.Wait (Mode => AWS.Server.Q_Key_Pressed);
   end Wait;

end HB_Server;
