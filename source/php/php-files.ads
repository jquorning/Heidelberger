--
--
--

private with Ada.Directories;
with Ada.Text_IO;

with Arrays;
with Lists;

package Php.Files
is
   use Arrays;
   use Lists;

   function File_Exists (Filename : String)
                         return Boolean;

   function Filesize (Filename : String)
                      return Natural
   is (raise Program_Error with "not implemented");

   function Is_Dir (Filename : String)
                    return Boolean;

   function Is_File (Filename : String)
                     return Boolean;

   function Basename (Path : String;
                      Suffix : String := "")
                      return String;

   function Is_Readable (Filename : String)
                         return Boolean;

   function Is_Writable (Filename : String)
                         return Boolean;

   function Dirname (Path   : String;
                     Levels : Positive := 1)
                     return String;

   function Copy (From : String;
                  To   : String)
                  return Boolean
   is (raise Program_Error with "not implemented");

   function File (Filename : String)
                  return List_Type
   is (raise Program_Error with "not implemented");

   type Dir_Handle is tagged limited private; -- tagged null record;

   function Is_Good (Handle : Dir_Handle)
                     return Boolean;

   function Opendir (Directory : String)
                     return Dir_Handle;

   function Readdir (Handle : in out Dir_Handle)
                     return String;

   procedure Closedir (Handle : in out Dir_Handle);

   function Realpath (Path : String)
            return String;

   function Scandir (Directory : String) return List_Type;

   --
   --
   --
   function Glob (Pattern : String;
                  Flags   : Integer := 0)
                  return List_Type;

   --
   --
   --
   function Glob_2 (Path      : String;
                    Extension : String)
                    return List_Type;

   type Resource is access all Integer;

   function File_Get_Contents (Filename         : String;
                               Use_Include_Path : Boolean  := False;
                               Context          : Resource := null;
                               Offset           : Integer  := 0;
                               Length           : Integer  := 0)
            return String;

   function Sys_Get_Temp_Dir
            return String
            is ("XXX-977");

   type Permission_Mask is mod 8 ** 6;

   procedure Umask (Mask : Permission_Mask)
   is null;

   function Umask
            return Permission_Mask
   is (raise Program_Error with "not implemented");

   procedure Chmod (Filename   : String;
                    Permission : Permission_Mask)
   is null;

   function Mkdir (Directoy   : String;
                   Permission : Permission_Mask;
                   Recursive  : Boolean := False)
                   return Boolean
   is (raise Program_Error with "not implemented");

   type File_Type is record
      File : Ada.Text_IO.File_Type;
   end record;

   function Is_Open (File : File_Type) return Boolean;
   -- Not a PHP function

   function Fopen (Filename : String;
                   Mode     : String)
                   return File_Type;

   procedure Fwrite (File : in out File_Type;
                     Data : String);

   procedure Fclose (File : in out File_Type);

   function Stat (Filename : String)
                  return Array_Type
   is (raise Program_Error with "not implemented");

   function Fileowner (Filename : String) return Integer;

   procedure Unlink (Filename : String);

private

   type Dir_Handle is tagged limited record
      Handle : Ada.Directories.Search_Type;
   end record;

end Php.Files;
