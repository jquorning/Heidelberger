--
--
--

with Arrays;
with Array_Lists;
with Databases;

package Bind_ADO
is
   use Arrays;

   type Mysqli        is tagged null record;
   type Mysqli_Result is tagged null record;

   function Initialize
            return Integer;

   function More_Results (Dbh : Integer)
                          return Boolean
                          is (False);

   procedure Next_Result (Dbh : Integer)
   is null;

   MYSQLI_REPORT_OFF : constant Integer := 1;

   procedure Mysqli_Report (Ss : Integer)
   is null;

   procedure Real_Connect
              (Dbh    : Integer;
               Host   : String;
               User   : String;
               Pw     : String;
               Ss     : String;
               Post   : Natural;
               Socket : String;
               Flags  : Integer);

   function Mysqli_Affected_Rows (Dbh : Integer)
                                 return Natural
   is (raise Program_Error with "not implemented");

   function Mysqli_Insert_Id (Dbh : Integer)
                              return Natural
   is (raise Program_Error with "not implemented");

   function Fetch_Object (Result : Databases.Three_State)
                          return Natural;

   function Mysqli_Errno (Dbh : Integer)
                          return Natural
   is (raise Program_Error with "not implemented");

   procedure Mysqli_Free_Result (Result : Databases.Three_State)
   is null;

   function Mysqli_Connect
            return Integer
   is (raise Program_Error with "not implemented");

   function Query (Dbh   : Integer;
                   Query : String)
                   return Databases.Three_State;

   function Query (Dbh   : Integer;
                   Query : String)
                   return Array_Lists.Array_List;

   procedure Query (Dbh   : Integer;
                    Query : String);

   function MySQLi_Real_Escape_String (Dhb  : Integer;
                                       Item : String)
                                       return String
   is (raise Program_Error with "not implemented");

   function Mysqli_Set_Charset (Dbh     : Integer;
                                Charset : String)
                                return Boolean
   is (raise Program_Error with "not implemented");

   function Fetch_Array (Res : Array_Lists.Array_List)
                         return Array_Type;

   function Select_DB (Dbh : Integer;
                       DB : String)
                       return Boolean
                       is (True);

   function Mysqli_Get_Client_Info
            return String
            is ("XXX-887");

   function Mysqli_Error (Dbh : Integer)
                          return String
                          is ("");

   function Mysqli_Connect_Error
            return String
            is ("");

   function Mysqli_Connect_Errno
            return Boolean
            is (True);

   function Get_Server_Info
            return String;

   function Ping (Dbh : Integer)
                  return Boolean
                  is (True);

end Bind_ADO;
