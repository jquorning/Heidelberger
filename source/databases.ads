--
--
--

package Databases
is
   type Engine_Type is (
     Engine_MySQL,
     Engine_MySQLi,
     Engine_SQLite);

   type Three_State is (None, False, True);

end Databases;
