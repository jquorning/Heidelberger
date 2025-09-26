with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;

with Hb_Common;

package body Php
is
   use Ada.Strings.Unbounded;

   function Get_Object_Vars (Arry : Array_Type) return Array_Type is (Empty_Array);

   -------------
   -- Explode --
   -------------

   function Explode (Separator : String;
                     Item      : String)
                     return List_Type
   is
      use Ada.Strings.Fixed;
      use Hb_Common;

      Pos : constant Natural := Index (Item, Separator);
      Res : List_Type;
   begin
      Res.Append (+Item (Item'First .. Pos - 1));
      Res.Append (+Item (Pos + Separator'Length .. Item'Last));

      return Res;
   end Explode;

   -----------------------------------------------------------------------------

   Echo_Buffer : Unbounded_String;

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
                     Arg_1  : String)
   is
      use Hb_Common;

      Item : constant String := Printf (Format, Arg_1);
   begin
      Append (Echo_Buffer, Item);
   end Printf;

   ----------
   -- Echo --
   ----------

   procedure Clear_Echo
   is
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

end Php;
