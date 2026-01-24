--
--
--

with Ada.Containers;
with Ada.Strings.Unbounded;

with UStrings;

package body Php.Lists
is

   -------------
   -- In_List --
   -------------

   function In_List (Needle   : String;
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
   end In_List;

   ----------------
   -- List_Merge --
   ----------------

   function List_Merge (Left, Right : List_Type)
                        return List_Type
   is
      use UStrings;

      Result : List_Type := Left;
   begin
      for A of Right loop
         if In_List (-A, Left) then
            null;
         else
            Result.Append (A);
         end if;
      end loop;
      return Result;
   end List_Merge;

   ----------------
   -- List_Diff --
   ---------------

   function List_Diff (Left, Right : List_Type)
                       return List_Type
   is
      use UStrings;

      Result : List_Type := Left;
   begin
      for A of Right loop
         Result := List_Diff (Result, -A);
      end loop;
      return Result;
   end List_Diff;

   ----------------
   -- List_Diff --
   ---------------

   function List_Diff (Left  : List_Type;
                       Right : String)
                       return List_Type
   is
      use UStrings;
      use List_Vectors;

      Result : List_Type := Left;
      Pos : List_Vectors.Cursor := Result.Find (+Right);
   begin
      if List_Vectors.Has_Element (Pos) then
         Result.Delete (Pos);
      else
         null;
      end if;
      return Result;
   end List_Diff;

   -----------------
   -- List_Filter --
   -----------------

   function List_Filter (List     : List_Type;
                         Callback : Filter_Callback := null)
                         return List_Type
   is
      use UStrings;

      Result : List_Type;
   begin
      for A of List loop
         if Callback = null then
            null;
         elsif Callback (-A) then
            Result.Append (A);
         end if;
      end loop;
      return Result;
   end List_Filter;

   ---------------
   -- List_Fill --
   ---------------

   function List_Fill (Start_Index : Integer;
                       Count       : Integer;
                       Value       : Multi_Type)
                       return List_Type
   is
      use UStrings;

      Result : List_Type;
   begin
      for A in 1 .. Count loop
         Result.Append (+As_String (Value));
      end loop;
      return Result;
   end List_Fill;

   ----------------
   -- List_Shift --
   ----------------

   procedure List_Shift (List : in out List_Type)
   is
   begin
      List.Delete_Last;
   end List_Shift;

   ----------------
   -- List_Shift --
   ----------------

   function List_Shift (List : in out List_Type)
                        return String
   is
      use UStrings;

      First : constant String := -List.First_Element;
   begin
      List_Shift (List);
      return First;
   end List_Shift;

   ------------------
   -- List_Unshift --
   ------------------

   procedure List_Unshift (List : in out List_Type;
                           Item : String)
   is
      use UStrings;
   begin
      List.Append (+Item);
   end List_Unshift;

   ---------------
   -- List_Keys --
   ---------------

   function List_Keys (List : List_Type)
                       return List_Type
   is
   begin
      return List;
   end List_Keys;

   ---------------------
   -- List_Key_Exists --
   ---------------------

   function List_Key_Exists (Key  : String;
                             List : List_Type)
                             return Boolean
   is
      use UStrings;
   begin
      return List_Vectors.Has_Element (List.Find (+Key));
   end List_Key_Exists;

   ------------------
   -- List_Combine --
   ------------------

   function List_Combine (Keys   : List_Type;
                          Values : List_Type)
                          return Array_Type
   is
      use type Ada.Containers.Count_Type;
      use UStrings;

      Result   : Array_Type;
      Keys_2   : List_Type := Keys;
      Values_2 : List_Type := Values;
   begin
      pragma Assert (Keys.Length = Values.Length);
      while Keys_2.Length not in 0 loop
         Result.Append (Key   => -Keys_2.First_Element,
                        Value => From_String (-Values_2.First_Element));
         List_Shift (Keys_2);
         List_Shift (Values_2);
      end loop;
      return Result;
   end List_Combine;

   --------------
   -- List_Pop --
   --------------

   function List_Pop (List : in out List_Type)
                      return String
   is
      use UStrings;

      Result : constant String := -List.Last_Element;
   begin
      List_Pop (List);
      return Result;
   end List_Pop;

   --------------
   -- List_Pop --
   --------------

   procedure List_Pop (List : in out List_Type)
   is
   begin
      List.Delete_Last;
   end List_Pop;

   ---------------
   -- List_Push --
   ---------------

   procedure List_Push (List  : in out List_Type;
                        Value : String)
   is
      use UStrings;
   begin
      List.Append (+Value);
   end List_Push;

   ---------------
   -- List_Push --
   ---------------

   function List_Push (List  : List_Type;
                       Value : String)
                       return List_Type
   is
      use UStrings;

      Result : List_Type := List;
   begin
      Result.Append (+Value);
      return Result;
   end List_Push;

   --------------------
   -- List_Intersect --
   --------------------

   function List_Intersect (List   : List_Type;
                            List_2 : List_Type)
                            return List_Type
   is
      use UStrings;

      Result : List_Type;
   begin
      for A of List_2 loop
         if In_List (-A, List) then
            Result.Append (A);
         end if;
      end loop;
      return Result;
   end List_Intersect;

   ------------------
   -- List_Reverse --
   ------------------

   function List_Reverse (List : List_Type)
                          return List_Type
   is
      use List_Vectors;

      Result : List_Type := List;
   begin
      Reverse_Elements (Result);
      return Result;
   end List_Reverse;

   -----------
   -- Isset --
   -----------

   function Isset (List : List_Type;
                   Key  : String)
                   return Boolean
   is
      use UStrings;
      use List_Vectors;
   begin
      return Has_Element (List.Find (+Key));
   end Isset;

end Php.Lists;
