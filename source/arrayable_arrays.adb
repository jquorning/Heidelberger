--
--
--

with Php.Arrays;

package body Arrayable_Arrays
is

   ------------------
   -- To_Arrayable --
   ------------------

   overriding
   function To_Array (X : Arrayable_Array)
                      return Arrays.Array_Type
   is
   begin
      return X.Container;
   end To_Array;

   -------------------
   -- Array_Unshift --
   -------------------

   overriding
   procedure Array_Unshift (X : in out Arrayable_Array;
                            S : Arrays.Array_Type)
   is
      use Php.Arrays;
   begin
      Array_Unshift (X.Container, S);
   end Array_Unshift;

end Arrayable_Arrays;
