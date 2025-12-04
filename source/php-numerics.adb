--
--
--

with Ada.Numerics.Discrete_Random;

package body Php.Numerics
is

   package Natural_Random
   is new Ada.Numerics.Discrete_Random (Natural);

   Generator : Natural_Random.Generator;

   -------------
   -- MT_Rand --
   -------------

   function MT_Rand (Min : Natural;
                     Max : Natural)
                     return Natural
   is
   begin
      return Natural_Random.Random (Generator, Min, Max);
   end MT_Rand;

begin
   Natural_Random.Reset (Generator, 0);
end Php.Numerics;
