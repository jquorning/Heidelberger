--
--
--

package Helpers is

   function Image (Value : Natural)
                   return String;
   -- Image of Value without leading space.

   function Image_Hex_4 (Item : Natural)
                         return String;
   -- Four digit hex of Item.

end Helpers;
