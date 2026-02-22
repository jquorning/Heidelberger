--
--
--

with Ada.Strings.Unbounded;

with Php.Strings;

with UStrings;

package body Php.Echoing
is
   use Lists;

   Echo_Buffer : UStrings.UString;

   ----------
   -- Echo --
   ----------

   procedure Echo (Item : String)
   is
      use Ada.Strings.Unbounded;
   begin
      Append (Echo_Buffer, Item);
   end Echo;

   ----------
   -- Echo --
   ----------

   procedure Printf (Format : String;
                     Args   : List_Type)
   is
      use Ada.Strings.Unbounded;
      use Php.Strings;

      Item : constant String := Printf (Format, Args);
   begin
      Append (Echo_Buffer, Item);
   end Printf;

   ----------
   -- Echo --
   ----------

   procedure Clear_Echo
   is
   begin
      Echo_Buffer :=
        Ada.Strings.Unbounded.To_Unbounded_String (Length => Default_Buffer_Length);
   end Clear_Echo;

   ----------
   -- Echo --
   ----------

   function Get_Echo
            return String
   is
      use UStrings;
   begin
      return -Echo_Buffer;
   end Get_Echo;

begin
   Clear_Echo;
end Php.Echoing;
