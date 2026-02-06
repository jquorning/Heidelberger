--
--
--

package body Helpers_2 is

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

end Helpers_2;
