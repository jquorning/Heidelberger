--
--
--

package Helpers_2 is

   generic
      type Item_Type is range <>;
   function Generic_Image (Item : Item_Type)
                           return String;
   -- Image of Value without leading space.

end Helpers_2;
