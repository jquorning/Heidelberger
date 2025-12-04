--
--
--

with Hb_Common;

package body Php.Lists
is

   -----------------
   -- Array_Shift --
   -----------------

   procedure Array_Shift (List : in out List_Type)
   is
   begin
      List.Delete_Last;
   end Array_Shift;

   -----------------
   -- Array_Shift --
   -----------------

   function Array_Shift (List : in out List_Type)
                         return String
   is
      use Hb_Common;

      First : constant String := -List.First_Element;
   begin
      Array_Shift (List);
      return First;
   end Array_Shift;

end Php.Lists;
