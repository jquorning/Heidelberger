--
-- Contains Translation_Entry class
--
-- @version Id: entry.php 1157 2015-11-20 04:30:11Z dd32
-- @package pomo
-- @subpackage entry
--

with Php.Strings;
with Php.Types;

with Lists;

package body POMO_Entries
is
   use Lists;

   procedure Set (Item  : in out Translation_Entry;
                  Key   : String;
                  Value : Multi_Type)
                  is null;

   -----------------
   -- X_Construct --
   -----------------

   function X_Construct (Args : Array_Type := Empty_Array)
                         return Translation_Entry
   is
      use Php.Types;

      This : Translation_Entry;
   begin
      -- If no singular - empty object.
      if not Isset (Args, "singular") then
         return Null_Translation_Entry; -- was return;
      end if;

      -- Get member variable values from args hash.
      for A in Args.Iterate loop
         declare
            Varname : constant String     := Key     (A);
            Value   : constant Multi_Type := Element (A);
         begin
            Set (This, Varname, Value);
         end;
      end loop;

      if
        Isset (Args, "plural") and then
        As_String (Get (Args, "plural")) /= ""
      then
         This.Is_Plural := True;
      end if;

      if not Is_Array (This.Translations) then
         This.Translations := Empty_Array;
      end if;

      if not Is_Array (This.References) then
         This.References := Empty_Array;
      end if;

      if not Is_Array (This.Flags) then
         This.Flags := Empty_Array;
      end if;

      return This;
   end X_Construct;

   ---------
   -- Key --
   ---------

   function Key (This : Translation_Entry)
                 return String
   is
      use Php.Strings;
      use UStrings;
   begin
      if Null_UString = This.Singular then
         return ""; -- False;
      end if;

      declare
         -- Prepend context and EOT, like in MO files.
         Key_2 : constant String :=
           -(if This.Context = ""
             then This.Singular
             else This.Context & "\4" & This.Singular);

         -- Standardize on \n line endings.
         Key_3 : constant String :=
           Str_Replace (To_List (List => (+"\r\n", +"\r")), "\n", Key_2);
      begin
         return Key_3;
      end;
   end Key;

end POMO_Entries;
