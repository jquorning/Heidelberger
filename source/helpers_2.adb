--
--
--

with Ada.Text_IO;

package body Helpers_2 is

   -----------
   -- Image --
   -----------

   function Generic_Image (Item : Item_Type)
                           return String
   is
      Img : constant String := Item_Type'Image (Item);
   begin
      if Img (Img'First) = ' ' then
         return Img (Img'First + 1 .. Img'Last);
      else
         return Img;
      end if;
   end Generic_Image;

end Helpers_2;
