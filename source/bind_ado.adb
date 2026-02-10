--
--
--

with ADO.Connections.Mysql;
with ADO.Sessions.Factory;
with ADO.Statements;

with Php.Arrays;

with Helpers;
with Logging;
with UStrings;

package body Bind_ADO
is
   Factor  : ADO.Sessions.Factory.Session_Factory;
   Session : ADO.Sessions.Session;
   Results : Array_Lists.Array_List;

   ----------------
   -- Initialize --
   ----------------

   function Initialize
            return Integer
   is
   begin
      ADO.Connections.Mysql.Initialize;
      return 1;
   end Initialize;

   -----------------
   -- Fetch_Array --
   -----------------

   function Fetch_Array (Res : Array_Lists.Array_List)
                         return Array_Type
   is
   begin
      return Res.First_Element;
   end Fetch_Array;

   ------------------
   -- Fetch_Object --
   ------------------

   function Fetch_Object (Result : Databases.Three_State)
                          return Natural
   is
   begin
      Logging.Log ("ado.fetch_object", "");
      return 0;
   end Fetch_Object;

   -----------
   -- Query --
   -----------

   function Query (Dbh   : Integer;
                   Query : String)
                   return Databases.Three_State
   is
      pragma Unreferenced (Dbh);
      use Array_Lists;

      Unused : constant Array_List :=
        Bind_ADO.Query (0, Query);
   begin
      return Databases.True;
   end Query;

   -----------
   -- Query --
   -----------

   function Query (Dbh   : Integer;
                   Query : String)
                   return Array_Lists.Array_List
   is
      pragma Unreferenced (Dbh);
      use ADO;
      use Php.Arrays;
      use Array_Lists;
      use UStrings;

      Stmt : ADO.Statements.Query_Statement :=
        Session.Create_Statement (Query);

      Column_Count : Natural;
   begin
      Logging.Log ("ado.query2", Query);

      Results := Empty_Array_List;
      Stmt.Execute;

      while Stmt.Has_Elements loop
         declare
            Columns : Array_Type;
         begin
            Column_Count := Stmt.Get_Column_Count;
            for Column in 0 .. Column_Count - 1 loop
               declare
                  Col_Name : constant String :=
                    Stmt.Get_Column_Name (Column);

                  Col_Value : constant Nullable_String :=
                    Stmt.Get_Nullable_String (Column);
               begin
                  Columns := Array_Merge (Columns,
                                          Build (Col_Name, -Col_Value.Value));
               end;
            end loop;
            Results.Append (Columns);
         end;
         Stmt.Next;
      end loop;

      return Results;
   end Query;

   -----------
   -- Query --
   -----------

   procedure Query (Dbh   : Integer;
                    Query : String)
   is
      pragma Unreferenced (Dbh);
      use Array_Lists;

      Unused : constant Array_List :=
        Bind_ADO.Query (0, Query);
   begin
      null;
   end Query;

   ------------------
   -- Real_Connect --
   ------------------

   procedure Real_Connect
              (Dbh    : Integer;
               Host   : String;
               User   : String;
               Pw     : String;
               Ss     : String;
               Post   : Natural;
               Socket : String;
               Flags  : Integer)
   is
      use ADO.Sessions;
   begin
      Logging.Log ("ado.connect", "");
      Logging.Log ("ado.connect", "host: " & Host);
      Logging.Log ("ado.connect", "user: " & User);
      Logging.Log ("ado.connect", "pw  : " & Pw);
      Logging.Log ("ado.connect", "ss  : " & Ss);
      Logging.Log ("ado.connect", "post: " & Helpers.Image (Post));
      Logging.Log ("ado.connect", "sock: " & Socket);
      Logging.Log ("ado.connect", "flag: " & Helpers.Image (Flags));

      declare
         Create_String : constant String :=
           "mysql://" & Host & "/" & "wordpress?user=" & User & "&password=" & Pw;
      begin
         Factory.Create (Factor, Create_String);
         Session := Factor.Get_Session;
      end;
   end Real_Connect;

   ---------------------
   -- Get_Server_Info --
   ---------------------

   function Get_Server_Info
            return String
   is
   begin
      return "10.11.14";
   end Get_Server_Info;

end Bind_ADO;
