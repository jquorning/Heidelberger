--
--
--

with Arrays;
with Databases;

package MySQL_Bind
is

   function Mysql_Init
            return Integer
   is (raise Program_Error with "not implemented");

   procedure Mysql_Real_Connect
   is null;

   procedure Mysql_Free_Result (Result : Databases.Three_State)
   is null;

   function Mysql_Connect
              ( -- Dbh    : Integer;
               Host   : String;
               User   : String;
               Pw     : String;
               Links  : Boolean; -- String;
--             Port   : Natural;
--             Socket : String;
               Flags  : Integer)
            return Integer
   is (raise Program_Error with "not implemented");

   function Mysql_Affected_Rows (Dbh : Integer)
                                 return Natural
   is (raise Program_Error with "not implemented");

   function Mysql_Insert_Id (Dbh : Integer)
                             return Natural
   is (raise Program_Error with "not implemented");

   function Mysql_Fetch_Object (Result : Databases.Three_State)
                                return Natural
   is (raise Program_Error with "not implemented");

   function Mysql_Errno (Dbh : Integer)
                         return Natural
   is (raise Program_Error with "not implemented");

   function Mysql_Query (Dbh   : Integer;
                         Query : String)
                         return Databases.Three_State
   is (raise Program_Error with "not implemented");

   function Mysql_Query (Query : String;
                         Dbh   : Integer)
                         return Arrays.Array_Type
   is (raise Program_Error with "not implemented");

   procedure Mysql_Query (Query : String;
                          Dbh   : Integer)
   is null;

   function MySQL_Real_Escape_String (Item : String;
                                      Dbh  : Integer)
                                      return String
   is (raise Program_Error with "not implemented");

   function Mysql_Set_Charset (Charset : String;
                               Dbh     : Integer)
                               return Boolean
   is (raise Program_Error with "not implemented");

   function Mysql_Result (Res : Arrays.Array_Type;
                          Dymmy : Integer)
                          return String
                          is ("XXX-897");

   function Mysql_Select_DB (DB  : String;
                             Dbh : Integer)
                             return Boolean
                             is (False);

   function Mysql_Get_Client_Info
            return String
            is ("XXX-886");

   function Mysql_Error (Dbh : Integer)
                         return String
                         is ("");

   function Mysql_Error
            return String
            is ("");

   function MySQL_Get_Server_Info (Dbh : Integer)
                                   return String
                                   is ("10.11.14");
-- is (raise Program_Error with "not implemented");

   function Mysql_Ping (Dbh : Integer)
                        return Boolean
                        is (False);

end MySQL_Bind;
