--
--
--

package body Php.Arrays
is

   -----------------
   -- Array_Slice --
   -----------------

   function Array_Slice (Arry   : Array_Type;
                         Offset : Natural;
                         Length : Natural)
                         return Array_Type
   is
   begin
      return Arry;
   end Array_Slice;

end Php.Arrays;
