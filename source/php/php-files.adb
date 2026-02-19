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

   function Is_Dir (Filename : String)
                    return Boolean
   is
      use Ada.Directories;
   begin
      return Exists (Filename) and then Kind (Filename) = Directory;
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

end Php.Files;
