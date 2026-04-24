--
--
--

package body Helpers_2
is
   use Lists;

   -------------------
   -- Generic_Image --
   -------------------

   function Generic_Image (Item : Item_Type)
                           return String
   is
      Img : constant String := Item_Type'Image (Item);
   begin
      if Img (Img'First) = ' ' then
         return Img (Img'First + 1 .. Img'Last);
      else
         return Img;
      end if;
   end Generic_Image;

   ----------------------------
   -- Generic_Call_Procedure --
   ----------------------------

   function Generic_Call_Procedure
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Arrays.Array_Type
   is
      pragma Unreferenced (Arry);
   begin
      Procedur;
      return Arrays.Empty_Array;
   end Generic_Call_Procedure;

   ------------------------------
   -- Generic_Call_Procedure_2 --
   ------------------------------

   function Generic_Call_Procedure_2
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Arrays.Array_Type
   is
      pragma Unreferenced (Arry);

      Unused : constant List_Type := Func (Empty_List);
   begin
      return Arrays.Empty_Array;
   end Generic_Call_Procedure_2;

   ------------------------------
   -- Generic_Call_Procedure_3 --
   ------------------------------

   function Generic_Call_Procedure_3
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Arrays.Array_Type
   is
      pragma Unreferenced (Arry);
   begin
      Procedur ("(not implemented)");
      return Arrays.Empty_Array;
   end Generic_Call_Procedure_3;

   ------------------------------
   -- Generic_Call_Procedure_4 --
   ------------------------------

   function Generic_Call_Procedure_4
              (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Arrays.Array_Type
   is
      pragma Unreferenced (Arry);
   begin
      Procedur (Item => False);
      return Arrays.Empty_Array;
   end Generic_Call_Procedure_4;

end Helpers_2;
