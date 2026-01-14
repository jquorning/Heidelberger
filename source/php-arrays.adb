--
--
--

with Hb_Common;

package body Php.Arrays
is

   -----------------
   -- Array_Merge --
   -----------------

   function Array_Merge (Left  : Array_Type;
                         Right : Array_Type)
                         return Array_Type
   is
      Result : Array_Type := Left;
   begin
      for A in Right.Iterate loop
         declare
            Key   : constant String     := Standard.Arrays.Key (A);
            Value : constant Multi_Type := Standard.Arrays.Element (A);
         begin
            if In_Array (Key, Left) then
               Result.Replace (Key, Value);
            else
               Result.Include (Key, Value);
            end if;
         end;
      end loop;
      return Result;
   end Array_Merge;

   -----------------
   -- Array_Merge --
   -----------------

   function Array_Merge (Arry_1 : Array_Type;
                         Arry_2 : Array_Type;
                         Arry_3 : Array_Type)
                         return Array_Type
   is
   begin
      return Array_Merge (Array_Merge (Arry_1, Arry_2), Arry_3);
   end Array_Merge;

   ----------------
   -- Array_Diff --
   ----------------

   function Array_Diff (Left  : Array_Type;
                        Right : Array_Type)
                        return Array_Type
   is
      Result : Array_Type := Left;
   begin
      for A in Right.Iterate loop
         declare
            Key   : constant String := Standard.Arrays.Key (A);
         begin
            if In_Array (Key, Result) then
               Result.Delete (Key);
            end if;
         end;
      end loop;
      return Result;
   end Array_Diff;

   --------------
   -- In_Array --
   --------------

   function In_Array (Needle   : String;
                      Haystack : Array_Type;
                      Strict   : Boolean := False)
                      return Boolean
   is
   begin
      return Has_Element (Haystack.Find (Needle));
   end In_Array;

   ------------------
   -- Array_Values --
   ------------------

   function Array_Values (Arry : Array_Type)
                          return List_Type
   is
      use Hb_Common;

      Result : List_Type;
   begin
      for A in Arry.Iterate loop
         Result.Append (+As_String (Element (A)));
      end loop;
      return Result;
   end Array_Values;

   ----------------
   -- Array_Keys --
   ----------------

   function Array_Keys (Arry : Array_Type)
                        return List_Type
   is
      use Hb_Common;

      Result : List_Type;
   begin
      for A in Arry.Iterate loop
         Result.Append (+Key (A));
      end loop;
      return Result;
   end Array_Keys;

   ----------------------
   -- Array_Key_Exists --
   ----------------------

   function Array_Key_Exists (Key  : String;
                              Arry : Array_Type)
                              return Boolean
   is
   begin
      return Has_Element (Arry.Find (Key));
   end Array_Key_Exists;

   -----------------
   -- Array_Slice --
   -----------------

   function Array_Slice (Arry   : Array_Type;
                         Offset : Natural;
                         Length : Natural)
                         return Array_Type
   is
      Result : Array_Type;
      Index  : Natural := 0;
   begin
      for A in Arry.Iterate loop
         Index := Index + 1;
         if Index in Offset .. Offset + Length then
            Result.Include (Key   => Key (A),
                            Value => Element (A));
         end if;
      end loop;
      return Result;
   end Array_Slice;

   ---------------------
   -- Array_Intersect --
   ---------------------

   function Array_Intersect (Arry    : Array_Type;
                             Array_2 : Array_Type)
                             return Array_Type
   is
      Result : Array_Type;
   begin
      for A in Arry.Iterate loop
         if In_Array (Key (A), Array_2) then
            Result.Include (Key (A), Element (A));
         end if;
      end loop;
      return Result;
   end Array_Intersect;

   -------------------
   -- Array_Reverse --
   -------------------

   function Array_Reverse (Arry          : Array_Type;
                           Preserve_Keys : Boolean := False)
                           return Array_Type
   is
      Result : Array_Type;
   begin
      for A in Arry.Iterate loop
         Result.Prepend (Key   => Key (A),
                        Value => Element (A));
      end loop;
      return Result;
   end Array_Reverse;

   ------------------
   -- Array_Unique --
   ------------------

   function Array_Unique (Arry  : Array_Type;
                          Flags : Unique_Flags := Sort_String)
                          return Array_Type
   is
      Result : Array_Type;
   begin
      for A in Arry.Iterate loop
         if not In_Array (Key (A), Result) then
            Result.Include (Key   => Key (A),
                            Value => Element (A));
         end if;
      end loop;
      return Result;
   end Array_Unique;

   -----------
   -- Isset --
   -----------

   function Isset (Arry : Array_Type;
                   Key  : Integer)
                   return Boolean
   is
   begin
      raise Program_Error with "not implemented";
--    return Has_Key (Arry.Find (Key));
      return False;
   end Isset;

   -----------
   -- Isset --
   -----------

   function Isset (Item : Array_Type)
                   return Boolean
   is
   begin
      return Item /= Empty_Array;
   end Isset;

   -----------
   -- Empty --
   -----------

   function Empty (Table : Array_Type)
                   return Boolean
   is
   begin
      return Table = Empty_Array;
   end Empty;

end Php.Arrays;
