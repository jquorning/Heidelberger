--
--
--

package Php.Files
is

   function File_Exists (Filename : String)
                         return Boolean
                         is (True);

   function Filesize (Filename : String)
                      return Natural
                      is (999);

   function Is_Dir (Filename : String)
                    return Boolean
                    is (False);

   function Is_File (Filename : String)
                     return Boolean
                     is (False);

   function Basename (Path : String;
                      Suffix : String := "")
                      return String
                      is ("XXX-521");

   function Is_Readable (Filename : String)
                         return Boolean
                         is (True);

   function Dirname (Path   : String;
                     Levels : Positive := 1)
                     return String
                     is ("XXX-702");

   function Realpath (Path : String)
            return String
            is ("XXX-779");

end Php.Files;
