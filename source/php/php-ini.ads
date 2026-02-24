--
--
--

package Php.Ini
is

   function Ini_Get (Option : String)
                     return String
                     is ("XXX-602");

   function Ini_Get (Option : String)
                     return Integer
                     is (997);

   function Ini_Get (Option : String)
                     return Boolean
                     is (True);

   procedure Ini_Set (Option : String;
                      Value  : Boolean)
   is null;

end Php.Ini;
