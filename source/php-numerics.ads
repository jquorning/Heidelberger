--
--
--

with Arrays;

package Php.Numerics
is
   use Arrays;

   function Max (Arry : Array_Type) return Integer is (1);
   function Hexdec (Hex : String) return Integer is (99);

   function MT_Rand (Min : Natural;
                     Max : Natural)
                     return Natural;

   function Round (Num       : Float;
                   Precision : Integer)
                   return Float
                   is (99.99);

end Php.Numerics;
