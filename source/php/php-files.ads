--
--
--

with Lists;

package Php.Files
is
   use Lists;

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

   function Is_Writable (Filename : String)
                         return Boolean
                         is (False);

   function Dirname (Path   : String;
                     Levels : Positive := 1)
                     return String
                     is ("XXX-702");

   function Mkdir (Directoy   : String;
                   Permission : Integer)
                   return Boolean
   is (raise Program_Error with "not implemented");

   function Copy (From : String;
                  To   : String)
                  return Boolean
   is (raise Program_Error with "not implemented");

   function File (Filename : String)
                  return List_Type
   is (raise Program_Error with "not implemented");

   type Dir_Handle is tagged null record;

   function Is_Good (Handle : Dir_Handle)
                     return Boolean
   is (raise Program_Error with "not implemented");

   function Opendir (Directory : String)
                     return Dir_Handle
   is (raise Program_Error with "not implemented");

   function Readdir (Handle : in out Dir_Handle)
                     return String
   is (raise Program_Error with "not implemented");

   procedure Closedir (Handle : in out Dir_Handle)
   is null;

   function Realpath (Path : String)
            return String
            is ("XXX-779");

   function Glob (Pattern : String;
                  Flags   : Integer := 0)
                  return List_Type
                  is (Empty_List);

   type Resource is access all Integer;

   function File_Get_Contents (Filename         : String;
                               Use_Include_Path : Boolean  := False;
                               Context          : Resource := null;
                               Offset           : Integer  := 0;
                               Length           : Integer  := 0)
            return String
            is ("XXX-780");

   function Sys_Get_Temp_Dir
            return String
            is ("XXX-977");

   procedure Umask (Make : Integer)
   is null;

   procedure Chmod (Filename   : String;
                    Permission : Integer)
   is null;

   type File_Type is null record;

   function Fopen (Filename : String;
                   Mode     : String)
                   return File_Type
   is (raise Program_Error with "not implemented");

   procedure Fwrite (File : in out File_Type;
                     Data : String)
   is null;

   procedure Fclose (File : in out File_Type)
   is null;

end Php.Files;
