
package body Hb_Common
is
   function To_Array (Item : String) return Array_Type is (Empty_Array);

   -- function Apply_Filters (Item : String;
   --                         S : String;
   --                         D : String := "";
   --                         X : String := "")
   --    return String is ("XXX-105");

   -- function Apply_Filters (Item : String; a : Array_Type; V : String; N : String)
   --    return Array_Type is (Empty_Array);

   function Empty (Table : Array_Type) return Boolean is (True);

   function Add_Query_Arg (Item : String; N : Natural; Sb : Unbounded_String)
      return Unbounded_String is (Null_Unbounded_String);
   function Add_Query_Arg (Item : String; N : String) return String is ("XXX-78");
   function Add_Query_Arg (List : Array_Type; Sb : Unbounded_String)
      return Unbounded_String is (Null_Unbounded_String);

   function Absint (Item : Assoc_List) return String is ("1");

   function Array_Filter (List : Array_Type) return Assoc_List is
      AL : constant Assoc_List := (1 .. 0 => <>);
   begin
      return AL;
   end Array_Filter;

   procedure Add_Filter (Arg_1, Arg_2 : String; Arg_3, Arg_4 : Integer) is null;
   procedure Remove_Filter (Arg_1, Arg_2 : String; Arg_3 : Integer) is null;

   ---------
   -- Set --
   ---------

   procedure Set (Arr   : in out Array_Type;
                  Key   : String;
                  Value : String)
   is
   begin
      Arr.Include (Key => Key, New_Item => Value);
   end Set;

   function Count (Item : String) return String is ("XXX 8");

   -- function Apply_Filters (Item : String; S : Assoc_List; D : Assoc_List)
   --    return Assoc_List
   -- is
   --    Al : constant Assoc_List := (1 .. 0 => <>);
   -- begin
   --    return Al;
   -- end Apply_Filters;

   function "abs" (List : Array_Type) return String is ("XXX 12");

   function Count (Al : Assoc_List) return Natural is (1);

   ---------
   -- Get --
   ---------

   function Get (Arr   : Array_Type;
                 Key   : String;
                 Arg_2 : String := "")
                 return String
   is
      use Array_Maps;
   begin
      pragma Assert (Arr.Find (Key) /= No_Element);
      pragma Assert (Element (Arr.Find (Key)).Kind = Is_String);
      return To_String (Array_Maps.Element (Arr.Find (Key)).Str);
   end Get;

   -----------
   -- Empty --
   -----------

   function Empty (Arry : Array_Type;
                   Key  : String)
                   return Boolean
   is
      use Array_Maps;
   begin
      return not Has_Element (Arry.Find (Key));
   end Empty;

   -----------
   -- Isset --
   -----------

   function Isset (Item : Array_Type)
                   return Boolean
                   is (True);

   function Isset (Item : String)
                   return Boolean
                   is (True);

   function Isset (Arry : Array_Type;
                   Key  : String)
                   return Boolean
   is
   begin
      return Array_Maps.Has_Element (Arry.Find (Key));
   end Isset;

end Hb_Common;
