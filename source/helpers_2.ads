--
--
--

with Arrayable_Interfaces;
with Arrays;

package Helpers_2 is

   generic
      type Item_Type is range <>;
   function Generic_Image (Item : Item_Type)
                           return String;
   -- Image of Value without leading space.

   generic
      with procedure Procedur;
   function Generic_Call_Procedure
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Arrays.Array_Type;

end Helpers_2;
