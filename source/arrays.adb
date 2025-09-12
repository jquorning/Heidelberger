package body Arrays
is
   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   function Build (Key : String; Value : String) return Assoc_Type
   is
   begin
      return (+Key, +Value);
   end Build;

end Arrays;
