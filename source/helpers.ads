--
--
--

with Helpers_2;

package Helpers is

   function Image is new Helpers_2.Generic_Image (Integer);
   --

   function Image_Hex_4 (Item : Natural)
                         return String;
   -- Four digit hex of Item.

end Helpers;
