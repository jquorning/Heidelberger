--
--
--

limited with Arrays;

package Arrayable_Interfaces
is

   type Arrayable_Interface is interface;

   --
   --
   --
   function To_Array (X : Arrayable_Interface)
                     return Arrays.Array_Type
                     is abstract;

   --
   --
   --
   procedure Array_Unshift (X : in out Arrayable_Interface;
                            S : Arrays.Array_Type)
                            is abstract;

end Arrayable_Interfaces;
