--
--
--

with Databases;

package MySQLi_Bind
is

   type Mysqli        is tagged null record;
   type Mysqli_Result is tagged null record;

   function Mysqli_Init
            return Integer
   is (raise Program_Error with "not implemented");

   function Mysqli_More_Results (Dbh : Integer)
                                 return Boolean
   is (raise Program_Error with "not implemented");

   procedure Mysqli_Next_Result (Dbh : Integer)
   is null;

   MYSQLI_REPORT_OFF : constant Integer := 1;

   procedure Mysqli_Report (Ss : Integer)
   is null;

   procedure Mysqli_Real_Connect
              (Dbh    : Integer;
               Host   : String;
               User   : String;
               Pw     : String;
               Ss     : String;
               Post   : Natural;
               Socket : String;
               Flags  : Integer)
   is null;

   function Mysqli_Error (Dbh : Integer)
                          return String
   is (raise Program_Error with "not implemented");

   function Mysqli_Affected_Rows (Dbh : Integer)
                                 return Natural
   is (raise Program_Error with "not implemented");

   function Mysqli_Insert_Id (Dbh : Integer)
                              return Natural
   is (raise Program_Error with "not implemented");

   function Mysqli_Fetch_Object (Result : Databases.Three_State)
                                 return Natural
   is (raise Program_Error with "not implemented");

   function Mysqli_Errno (Dbh : Integer)
                          return Natural
   is (raise Program_Error with "not implemented");

   procedure Mysqli_Free_Result (Result : Databases.Three_State)
   is null;

   function Mysqli_Connect
            return Integer
   is (raise Program_Error with "not implemented");

   function Mysqli_Query (Dbh   : Integer;
                          Query : String)
                          return Databases.Three_State
   is (raise Program_Error with "not implemented");

   function MySQLi_Real_Escape_String (Dhb  : Integer;
                                       Item : String)
                                       return String
   is (raise Program_Error with "not implemented");

end MySQLi_Bind;
