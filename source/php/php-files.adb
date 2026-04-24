--
--
--

with Ada.Directories;

with Dir_Iterators.Recursive;
with Logging;
with UStrings;

package body Php.Files
is

   -----------------
   -- File_Exists --
   -----------------

   function File_Exists (Filename : String)
                         return Boolean
   is
   begin
      return Filename /= "" and then Ada.Directories.Exists (Filename);
   end File_Exists;

   ------------
   -- Is_Dir --
   ------------

   function Is_Dir (Filename : String) return Boolean is
      use Ada.Directories;
   begin
      return
        Filename /= ""
        and then Exists (Filename)
        and then Kind (Filename) = Directory;
   end Is_Dir;

   -------------
   -- Is_File --
   -------------

   function Is_File (Filename : String)
                     return Boolean
   is
      use Ada.Directories;
   begin
      return Exists (Filename) and then Kind (Filename) = Ordinary_File;
   end Is_File;

   --------------
   -- Basename --
   --------------

   function Basename (Path   : String;
                      Suffix : String := "")
                      return String
   is
      use Ada.Directories;
   begin
      return Base_Name (Path);
   end Basename;

   -----------------
   -- Is_Readable --
   -----------------

   function Is_Readable (Filename : String)
                         return Boolean
   is
   begin
      return Is_File (Filename);
   end Is_Readable;

   -----------------
   -- Is_Writable --
   -----------------

   function Is_Writable (Filename : String)
                         return Boolean
   is
   begin
      Logging.Log ("is_writable", Filename);
      return True;
   end Is_Writable;

   -------------
   -- Dirname --
   -------------

   function Dirname (Path   : String;
                     Levels : Positive := 1)
                     return String
   is
      use Ada.Directories;
      use UStrings;

      Path_2 : UString := +Path;
   begin
      Logging.Log ("dirname", "path  : " & Path);
      Logging.Log ("dirname", "levels: " & Levels'Image);

      if Path = "" then
         return Path;
      end if;

      for Level in 1 .. Levels loop
         Path_2 := +Containing_Directory (-Path_2);
      end loop;
      return -Path_2;
   end Dirname;

   --------------
   -- Realpath --
   --------------

   function Realpath (Path : String) return String is
      use Ada.Directories;
   begin
      return Full_Name (Path);
   end Realpath;

   -------------
   -- Scandir --
   -------------

   function Scandir (Directory : String) return List_Type is
      use Ada.Directories;

      Search : Search_Type;

      Filter : constant Filter_Type :=
        (Ada.Directories.Directory => True,
         Ordinary_File             => True,
         Special_File              => False);

      Result : List_Type;
   begin
      Logging.Log ("php.files.scandir", "dir: " & Directory);

      Start_Search (Search, Directory, Pattern => "*", Filter => Filter);
      while More_Entries (Search) loop
         declare
            Item : Directory_Entry_Type;
         begin
            Get_Next_Entry (Search, Item);
            Result.Append (Ada.Directories.Simple_Name (Item));
         end;
      end loop;
      End_Search (Search);
      -- Logging.Log ("php.files.scandir", Result'Image);
      return Result;
   end Scandir;

   ----------
   -- Glob --
   ----------

   function Glob (Pattern : String;
                  Flags   : Integer := 0)
                  return List_Type
   is
      use Dir_Iterators.Recursive;

      Dir_Walk : constant Recursive_Dir_Walk := Walk (Pattern);

   begin
      Logging.Log ("glob", Pattern);

      for Dir_Entry of Dir_Walk loop
         Logging.Log ("glob", Ada.Directories.Full_Name (Dir_Entry));
      end loop;
      return Empty_List;
   end Glob;

   ------------
   -- Glob_2 --
   ------------

   function Glob_2 (Path      : String;
                    Extension : String)
                    return List_Type
   is
      use Ada.Directories;
      use Dir_Iterators.Recursive;

      Dir_Walk : constant Recursive_Dir_Walk := Walk (Path);
      Result   : List_Type;
   begin
      Logging.Log ("glob_2", Path);

      for Dir_Entry of Dir_Walk loop
         declare
            Simple : constant String := Simple_Name (Dir_Entry);
         begin
            if Ada.Directories.Extension (Simple) = Extension then
               Result.Append (Simple);
            end if;
         end;
      end loop;
      return Result;
   end Glob_2;

   -----------------------
   -- File_Get_Contents --
   -----------------------

   function File_Get_Contents
     (Filename         : String;
      Use_Include_Path : Boolean := False;
      Context          : Resource := null;
      Offset           : Integer := 0;
      Length           : Integer := 0) return String
   is
      use Ada.Text_IO;
      use UStrings;

      File   : Ada.Text_IO.File_Type;
      Buffer : UString;
   begin
      Open (File, In_File, Filename);
      while not End_Of_File (File) loop
         Append (Buffer, Get_Line (File));
         Append (Buffer, NL);
      end loop;
      Close (File);
      return -Buffer;
   end File_Get_Contents;

   -------------
   -- Is_Open --
   -------------

   function Is_Open (File : File_Type) return Boolean is
   begin
      return Ada.Text_IO.Is_Open (File.File);
   end Is_Open;

   -----------
   -- Fopen --
   -----------

   function Fopen (Filename : String; Mode : String) return File_Type is
      use Ada.Text_IO;

      A_Mode : constant Ada.Text_IO.File_Mode :=
        (if Mode = "r"
         then In_File
         elsif Mode = "w"
         then Out_File
         else raise Program_Error with "not implemented");
   begin
      Logging.Log ("php.fopen", Filename);
      return Result : File_Type do
         Ada.Text_IO.Open (Result.File, A_Mode, Filename);
      end return;
   exception
      when Name_Error =>
         Logging.Log ("php.fopen", "excpeption name_error");
         return Result : File_Type do
            null;
         end return;
   end Fopen;

   ------------
   -- Fwrite --
   ------------

   procedure Fwrite (File : in out File_Type; Data : String) is
   begin
      raise Program_Error with "not implemented";
   end Fwrite;

   ------------
   -- Fclose --
   ------------

   procedure Fclose (File : in out File_Type) is
   begin
      Ada.Text_IO.Close (File.File);
   end Fclose;

   ---------------
   -- Fileowner --
   ---------------

   function Fileowner (Filename : String) return Integer is
   begin
      Logging.Log ("php.fileowner", "not implemented");
      return 999;
   end Fileowner;

   ------------
   -- unlink --
   ------------

   procedure Unlink (Filename : String) is
   begin
      Logging.Log ("php.unlink", "not implemented");
   end Unlink;

end Php.Files;
