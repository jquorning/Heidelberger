--
--
--

with Logging;

package body Php.Sorting
is

   -----------
   -- USort --
   -----------

   procedure USort (Arry     : in out Array_Type;
                    Callback : USort_Comparator)
   is
   begin
      raise Program_Error with "not implemented";
   end USort;

   ------------
   -- USSort --
   ------------

   procedure UASort (Arry : in out Array_Type) is
      -- ; Callback :
   begin
      Logging.Log ("uasort", "not implemented");
   end UASort;

end Php.Sorting;
