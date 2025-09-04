
with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

with GNAT.Directory_Operations;

with AWS.Config.Set;
with AWS.Response;
with AWS.Services.Page_Server;
with AWS.Services.Directory;
with AWS.Server;
with AWS.Status;

package body HB_Server is

   Http_Server : AWS.Server.HTTP;

   function Callback (Request : AWS.Status.Data)
                      return AWS.Response.Data;

   --------------
   -- Callback --
   --------------

   function Callback (Request : AWS.Status.Data) return AWS.Response.Data
   is
      use Ada.Directories;
      use Ada.Strings.Unbounded;
      use GNAT.Directory_Operations;
      use AWS.Services.Directory;

      Uri : constant String := AWS.Status.URI (D => Request);
   begin
      return AWS.Services.Page_Server.Callback (Request => Request);
   end Callback;

   -----------
   -- Start --
   -----------

   procedure Start
   is
      use Ada.Text_IO;
      use AWS.Config;

      Server_Config : Object := Default_Config;
   begin
      Set.Server_Name    (Server_Config, "Heidelberger");
      Set.Server_Port    (Server_Config, 8080);
      Set.Max_Connection (Server_Config, 5);
      Set.Reuse_Address  (Server_Config, True);

      AWS.Server.Start (Web_Server => Http_Server,
                        Callback   => Callback'Access,
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
      AWS.Server.Shutdown (Web_Server => Http_Server);
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
