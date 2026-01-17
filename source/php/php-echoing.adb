--
--
--

with Ada.Strings.Unbounded;

with Php.Strings;

with Hb_Common;

package body Php.Echoing
is
   use Lists;

   Echo_Buffer : Ada.Strings.Unbounded.Unbounded_String;

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
      use Ada.Strings.Unbounded;
   begin
      Echo_Buffer := Null_Unbounded_String;
   end Clear_Echo;

   ----------
   -- Echo --
   ----------

   function Get_Echo
            return String
   is
      use Hb_Common;
   begin
      return -Echo_Buffer;
   end Get_Echo;

end Php.Echoing;
