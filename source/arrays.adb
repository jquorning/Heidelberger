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
      return Build (Key, "XXX-791");
   end Build;

   --------------
   -- To_Array --
   --------------

   function To_Array (List : Assoc_List)
            return Array_Type
   is
      Result : Array_Type;
   begin
      for A of List loop
         Result.Include (Key      => To_String (A.Key),
                         New_Item => To_String (A.Value));
      end loop;
      return Result;
   end To_Array;

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

   function To_List (Item : String)
                     return List_Type
   is (To_List (List => (1 => To_Unbounded_String (Item))));

end Arrays;
