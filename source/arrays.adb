package body Arrays
is
   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   -------------
   -- Include --
   -------------

   procedure Include (Arry     : in out Array_Type;
                      Key      : String;
                      New_Item : String)
   is
      Item : Array_Record;
   begin
      Item.Kind := Is_String;
      Item.Str  := +New_Item;
      Arry.Include (Key, Item);
   end Include;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : String)
                   return Array_Type
   is
      Item : Array_Record;
      Map  : Array_Type;
   begin
      Item.Kind := Is_String;
      Item.Str  := +Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   function Build (Key   : String;
                   Value : Integer)
                   return Array_Type
   is
      Item : Array_Record;
      Map  : Array_Type;
   begin
      Item.Kind := Is_Integer;
      Item.Int  := Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   function Build (Key   : String;
                   Value : Array_Type)
                   return Array_Type
   is
      Item : Array_Record;
      Map  : Array_Type;
   begin
      Item.Kind := Is_Array;
      Item.Arry := new Array_Type'(Value);
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   function Build (Key   : String;
                   Value : Boolean)
                   return Array_Type
   is
      Item : Array_Record;
      Map  : Array_Type;
   begin
      Item.Kind := Is_Boolean;
      Item.Bool := Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   function Build (Key   : String;
                   Value : Null_Type)
                   return Array_Type
   is
      Item : Array_Record;
      Map  : Array_Type;
   begin
      Item.Kind := Is_Null;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   --------------
   -- To_Array --
   --------------

   function To_Array (List : Array_List)
            return Array_Type
   is
      use Array_Maps;

      Result : Array_Type;
   begin
      for A of List loop
         for B in A.Iterate loop
            Result.Insert (Key      => Key     (B),
                           New_Item => Element (B));
         end loop;
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
