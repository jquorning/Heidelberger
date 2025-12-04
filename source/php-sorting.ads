--
--
--

package Php.Sorting
is

   procedure Sort (List : in out List_Type)
   is null;

   type USort_Comparator is access function (A, B : Multi_Type)
                                             return Integer;

   procedure USort (Arry     : in out Array_Type;
                    Callback : USort_Comparator);

   SORT_REGULAR : constant Integer := 47; -- arbitrary

   procedure Ksort (Arry  : in out Array_Type;
                    Flags : Integer := SORT_REGULAR)
                    is null;

end Php.Sorting;
