--
--
--

with Php.Arrays;

package body Array_Lists
is

   -------------------
   -- To_Array_Type --
   -------------------

   function To_Array_Type (List : Array_List)
                           return Array_Type
   is
      use Php.Arrays;

      Result : Array_Type;
   begin
      for A of List loop
         Result := Array_Merge (Result, A);
      end loop;
      return Result;
   end To_Array_Type;

end Array_Lists;
