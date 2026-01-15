--
--
--

with Arrays;
with Databases;
with Lists;

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

   function Mysqli_Query (Dbh   : Integer;
                          Query : String)
                          return Arrays.Array_Type
   is (raise Program_Error with "not implemented");

   procedure Mysqli_Query (Dbh   : Integer;
                           Query : String)
   is null;

   function MySQLi_Real_Escape_String (Dhb  : Integer;
                                       Item : String)
                                       return String
   is (raise Program_Error with "not implemented");

   function Mysqli_Set_Charset (Dbh     : Integer;
                                Charset : String)
                                return Boolean
   is (raise Program_Error with "not implemented");

   function Mysqli_Fetch_Array (Res : Arrays.Array_Type)
                                return Lists.List_Type
                                is (Lists.Empty_List);

   function Mysqli_Select_DB (Dbh : Integer;
                               DB : String)
                              return Boolean
                              is (False);

   function Mysqli_Get_Client_Info
            return String
            is ("XXX-887");

end MySQLi_Bind;
