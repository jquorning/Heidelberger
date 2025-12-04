--
--
--

with Ada.Strings.Unbounded;

with Hb_Common;

package body Php.Lists
is

   --------------
   -- In_Array --
   --------------

   function In_Array (Needle   : String;
                      Haystack : List_Type;
                      Strict   : Boolean := False)
                      return Boolean
   is
      use Ada.Strings.Unbounded;
   begin
      for A of Haystack loop
         if Needle = A then
            return True;
         end if;
      end loop;
      return False;
   end In_Array;

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
