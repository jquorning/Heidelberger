--
--
--

package body Lists
is
   use Ada.Strings.Unbounded;

   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   ------------
   -- Append --
   ------------

   procedure Append (List : in out List_Type;
                     Item : String)
   is
   begin
      List.Append (+Item);
   end Append;

   -------------
   -- To_List --
   -------------

   function To_List (List : Item_List)
                     return List_Type
   is
      Result : List_Type;
   begin
      for A of List loop
         Result.Append (A);
      end loop;
      return Result;
   end To_List;

   -------------
   -- To_List --
   -------------

   function To_List (Item : String)
                     return List_Type
   is (To_List (List => (1 => +Item)));

end Lists;
