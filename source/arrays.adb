package body Arrays
is
   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   function Build (Key : String; Value : String) return Assoc_Type
   is
   begin
      return (+Key, +Value);
   end Build;

   function Build (Key : String; Value : Integer) return Assoc_Type
   is
   begin
      return (+Key, +Value'Image);
   end Build;

   function Build (Key : String; Value : Array_Type) return Assoc_Type
   is
      A : Assoc_Type;
   begin
      return A;
   end Build;

end Arrays;
