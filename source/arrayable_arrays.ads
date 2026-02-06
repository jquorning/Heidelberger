--
--
--

with Arrayable_Interfaces;
with Arrays;

package Arrayable_Arrays
is

   --
   --
   --
   type Arrayable_Array is
     new Arrayable_Interfaces.Arrayable_Interface
     with record
        Container : Arrays.Array_Type;
     end record;

   --
   --
   --
   overriding
   function To_Array (X : Arrayable_Array)
                      return Arrays.Array_Type;

   --
   --
   --
   overriding
   procedure Array_Unshift (X : in out Arrayable_Array;
                            S : Arrays.Array_Type);

   Empty_Arrayable : constant Arrayable_Array :=
     (Container => Arrays.Empty_Array);

end Arrayable_Arrays;
