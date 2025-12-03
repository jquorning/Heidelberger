--
--
--

with Ada.Text_IO;

package body Helpers is

   -----------
   -- Image --
   -----------

   function Image (Value : Natural)
                   return String
   is
      Img : constant String := Natural'Image (Value);
   begin
      if Img (Img'First) = ' ' then
         return Img (Img'First + 1 .. Img'Last);
      else
         return Img;
      end if;
   end Image;

   -----------------
   -- Image_Hex_4 --
   -----------------

   function Image_Hex_4 (Item : Natural)
                         return String
   is
      package Hex_IO is new Ada.Text_IO.Integer_IO (Natural);
      Image : String (1 .. 8); -- "16#BABE#"
   begin
      Hex_IO.Default_Width := 4;
      Hex_IO.Put (Image, Item, Base => 16);
      return Image (4 .. 7);
   end Image_Hex_4;

end Helpers;
