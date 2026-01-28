--
--
--

package body Lists
is

   ------------
   -- Append --
   ------------

   procedure Append (List : in out List_Type;
                     Item : String)
   is
   begin
      List_Vectors.Append (List, Item);
   end Append;

end Lists;
