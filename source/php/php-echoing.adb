--
--
--

with Ada.Strings.Bounded;

with Php.Strings;

package body Php.Echoing
is
   use Lists;

   package Bounded_Strings is
     new Ada.Strings.Bounded.Generic_Bounded_Length (Max => 500_000);
   use Bounded_Strings;

   Echo_Buffer : Bounded_String;

   ----------
   -- Echo --
   ----------

   procedure Echo (Item : String)
   is
   begin
      Append (Echo_Buffer, Item);
   end Echo;

   ----------
   -- Echo --
   ----------

   procedure Printf (Format : String;
                     Args   : List_Type)
   is
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
      Echo_Buffer := Null_Bounded_String;
   end Clear_Echo;

   ----------
   -- Echo --
   ----------

   function Get_Echo
            return String
   is
   begin
      return To_String (Echo_Buffer);
   end Get_Echo;

begin
   Clear_Echo;
end Php.Echoing;
