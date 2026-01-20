--
--
--

with Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Hb_Common;

package body Php.HTML
is

   Static_Header : Ada.Strings.Unbounded.Unbounded_String;

   ----------------
   -- Get_Header --
   ----------------

   function Get_Header
            return String
   is
      use Hb_Common;
   begin
      Put_Line ("get_header:");
      Put_Line ("  " & (-Static_Header));
      return -Static_Header;
   end Get_Header;

   ------------
   -- Header --
   ------------

   procedure Header (Header        : String;
                     Replace       : Boolean := True;
                     Response_Code : Integer := 0)
   is
      use Hb_Common;
   begin
      Static_Header := +Header;
   end Header;

   --------------------
   -- Raw_URL_Encode --
   --------------------

   function Raw_URL_Encode (Item : String)
                            return String
   is
   begin
      Put_Line ("raw_url_encode: " & Item);
      return Item;
   end Raw_URL_Encode;

   ----------------
   -- URL_Encode --
   ----------------

   function URL_Encode (Item : String)
                        return String
   is
   begin
      return Item;
   end URL_Encode;

end Php.HTML;
