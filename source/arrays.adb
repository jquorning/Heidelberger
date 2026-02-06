--
--
--

with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Helpers;
with Logging;

package body Arrays
is
   use UStrings;

   ---------
   -- "=" --
   ---------

   function "=" (Left, Right : Multi_Type)
                 return Boolean
   is
      use Lists.List_Vectors;
   begin
      if Left.Kind /= Right.Kind then
         return False;
      end if;

      case Left.Kind is
      when Kind_Null     => return True;
      when Kind_Boolean  => return Left.Bool = Right.Bool;
      when Kind_Integer  => return Left.Int  = Right.Int;
      when Kind_String   => return Left.Str  = Right.Str;
      when Kind_List     => return Left.List = Right.List;
      when Kind_Array    => return Left.Arry = Right.Arry;
      when Kind_Callable => return Left.Func = Right.Func;
      end case;
   end "=";

   -- ------------
   -- -- Append --
   -- ------------

   -- procedure Append (Arry  : in out Array_Type;
   --                   Value : Multi_Type)
   -- is
   -- begin
   --    Array_Maps.Insert (Array_Maps.Map (Arry), "XXX-011", Value);
   -- end Append;

   ------------
   -- Append --
   ------------

   procedure Append (Arry  : in out Array_Type;
                     Key   : String;
                     Value : Multi_Type)
   is
   begin
      Array_Maps.Include (Array_Maps.Map (Arry), Key, Value);
   end Append;

   --------------
   -- Append_2 --
   --------------

   procedure Append_2 (Arry  : in out Array_Type;
                       Key_1 : String;
                       Key_2 : String;
                       Value : Multi_Type)
   is
      Array_2 : Array_Type := Element (Arry.Find (Key_1)).Arry.Holder.all;
   begin
      Array_Maps.Include (Array_Maps.Map (Array_2), Key_2, Value);
   end Append_2;

   ------------
   -- Delete --
   ------------

   procedure Delete (Arry  : in out Array_Type;
                     Key   : String)
   is
   begin
      Array_Maps.Delete (Array_Maps.Map (Arry), Key);
   end Delete;

   -------------
   -- Include --
   -------------

   procedure Include (Arry  : in out Array_Type;
                      Key   : String;
                      Value : Multi_Type)
   is
   begin
      Array_Maps.Include (Array_Maps.Map (Arry), Key, Value);
   end Include;

   -------------
   -- Prepend --
   -------------

   procedure Prepend (Arry  : in out Array_Type;
                      Key   : String;
                      Value : Multi_Type)
   is
   begin
      Array_Maps.Insert (Array_Maps.Map (Arry), Key, Value);
   end Prepend;

   -------------
   -- Replace --
   -------------

   procedure Replace (Arry  : in out Array_Type;
                      Key   : String;
                      Value : Multi_Type)
   is
   begin
      Array_Maps.Replace (Array_Maps.Map (Arry), Key, Value);
   end Replace;

   --------------
   -- Is_Empty --
   --------------

   function Is_Empty (Arry : Array_Type)
                      return Boolean
   is
   begin
      return Array_Maps.Is_Empty (Array_Maps.Map (Arry));
   end Is_Empty;

   -----------------
   -- Has_Element --
   -----------------

   function Has_Element (Position : Cursor)
                         return Boolean
   is
   begin
      return Array_Maps.Has_Element (Array_Maps.Cursor (Position));
   end Has_Element;

   ---------
   -- Key --
   ---------

   function Key (Position : Cursor)
                 return String
   is
   begin
      return Array_Maps.Key (Array_Maps.Cursor (Position));
   end Key;

   -------------
   -- Element --
   -------------

   function Element (Position : Cursor)
                     return Multi_Type
   is
   begin
      return Array_Maps.Element (Array_Maps.Cursor (Position));
   end Element;

   -----------
   -- Ref_0 --
   -----------

   function Ref_0 (Arry : Array_Type)
                   return Array_Type -- Cursor
   is
   begin
      return Arry;
--    return Array_Maps.Map (Array_Maps.Map (Arry));
   end Ref_0;

   ---------
   -- Ref --
   ---------

   function Ref (Arry : Array_Type;
                 Key  : String)
                 return Cursor
   is
   begin
      return Arry.Find (Key);
   end Ref;

   -----------
   -- Ref_2 --
   -----------

   function Ref_2 (Arry  : Array_Type;
                   Key_1 : String;
                   Key_2 : String)
                   return Cursor
   is
      Rec_1 : constant Cursor := Ref (Arry, Key_1);
   begin
      return Arrays.Element (Rec_1).Arry.Holder.Find (Key_2);
   end Ref_2;

   -----------
   -- Ref_3 --
   -----------

   function Ref_3 (Arry   : Array_Type;
                   Key_1  : String;
                   Key_2  : String;
                   Key_3  : String)
                   return Cursor
   is
      Rec_2 : constant Cursor := Ref_2 (Arry, Key_1, Key_2);
   begin
      return Arrays.Element (Rec_2).Arry.Holder.Find (Key_3);
   end Ref_3;

   -----------
   -- Ref_4 --
   -----------

   function Ref_4 (Arry   : Array_Type;
                   Key_1  : String;
                   Key_2  : String;
                   Key_3  : String;
                   Key_4  : String)
                   return Cursor
   is
      Rec_3 : constant Cursor := Ref_3 (Arry, Key_1, Key_2, Key_3);
   begin
      return Arrays.Element (Rec_3).Arry.Holder.Find (Key_4);
   end Ref_4;

   -----------
   -- Ref_5 --
   -----------

   function Ref_5 (Arry   : Array_Type;
                   Key_1  : String;
                   Key_2  : String;
                   Key_3  : String;
                   Key_4  : String;
                   Key_5  : String)
                   return Cursor
   is
      Rec_4 : constant Cursor := Ref_4 (Arry, Key_1, Key_2, Key_3, Key_4);
   begin
      return Arrays.Element (Rec_4).Arry.Holder.Find (Key_5);
   end Ref_5;

   -------------
   -- Kind_Of --
   -------------

   function Kind_Of (Arry : Multi_Type)
                     return Array_Kind
   is
   begin
      return Arry.Kind;
   end Kind_Of;

   -----------
   -- Empty --
   -----------

   function Empty (Obj : Cursor)
                   return Boolean
   is
   begin
      return Kind_Of (Get (Obj)) = Kind_Null;
   end Empty;

   --------------
   -- As_Array --
   --------------

   function As_Array (Arry : Multi_Type)
                      return Array_Type
   is
   begin
      pragma Assert (Arry.Kind = Kind_Array);
--    pragma Assert (Arry.Arry.Holder.Element /= null);

      -- if Arry.Arry.Holder.Is_Empty then
      --    declare
      --       Item : Multi_Type := Null_Multi_Type;
      --       Array_1 : Array_Type := Null_Array_Type;
      --    begin
      --       Array_1.Kind := Kind_Array;
      --       Array_1.Holder := To_Holder (new Map);
      --       return Array_1;
      --    end;
      -- end if;
      return Arry.Arry.Holder.all;
   end As_Array;

   -------------
   -- As_List --
   -------------

   function As_List (Arry : Multi_Type)
                     return Lists.List_Type
   is
   begin
      case Arry.Kind is

      when Kind_List =>
         return Arry.List;

      when Kind_String =>
         return [-Arry.Str];

      when others =>
         pragma Assert (False);
      end case;

   end As_List;

   ---------------
   -- As_String --
   ---------------

   function As_String (Arry : Multi_Type)
                      return String
   is
      use Ada.Text_IO;
   begin
      case Arry.Kind is
      when Kind_String  => return -Arry.Str;
      when Kind_Integer => return Helpers.Image (Arry.Int);
      when Kind_Boolean => return (if Arry.Bool then "true" else "false");
      when Kind_Null    => return "(null)";
      when Kind_Array   => return "(array)";
      when others =>
         Put_Line ("as_string: ");
         Put_Line ("  kind: " & Kind_Of (Arry)'Image);
         pragma Assert (False);
         return "";
      end case;
   end As_String;

   ----------------
   -- As_Integer --
   ----------------

   function As_Integer (Arry : Multi_Type)
                       return Integer
   is
   begin
      case Kind_Of (Arry) is
      when Kind_Integer => return Arry.Int;
      when Kind_Null    => return 0;
      when Kind_String  => return 0; -- Integer'Value (-Arry.Str);
      when others       => pragma Assert (False);
      end case;
   end As_Integer;

   ----------------
   -- As_Boolean --
   ----------------

   function As_Boolean (Arry : Multi_Type)
                       return Boolean
   is
      use Ada.Text_IO;
   begin
      case Kind_Of (Arry) is
      when Kind_Boolean =>  return Arry.Bool;
      when Kind_Null    =>  return False;
      when others =>
         Put_Line ("as_boolean:");
         Put_Line ("  kind: " & Kind_Of (Arry)'Image);
         pragma Assert (False);
         return False;
      end case;
   end As_Boolean;

   -----------------
   -- As_Callable --
   -----------------

   function As_Callable (Arry : Multi_Type)
                         return Callable
   is
   begin
      pragma Assert (Arry.Kind = Kind_Callable);

      return Arry.Func;
   end As_Callable;

   -------------
   -- Is_Null --
   -------------

   function Is_Null (Arry : Multi_Type)
                     return Boolean
   is
   begin
      return Kind_Of (Arry) = Kind_Null;
   end Is_Null;

   ----------------
   -- From_Array --
   ----------------

   function From_Array (Value : Array_Type)
                        return Multi_Type
   is
      M : Multi_Type;
   begin
      M.Kind := Kind_Array;
      if not Value.Is_Empty then
         M.Arry.Holder := Value.First_Element.Arry.Holder;
      end if;
      return M;
   end From_Array;

   ---------------
   -- From_List --
   ---------------

   function From_List (Value : Lists.List_Type)
                       return Multi_Type
   is
      M : Multi_Type;
   begin
      M.Kind := Kind_List;
      M.List.Append (Value);
      return M;
   end From_List;

   -----------------
   -- From_String --
   -----------------

   function From_String (Value : String)
                         return Multi_Type
   is
      M : Multi_Type;
   begin
      M.Kind := Kind_String;
      M.Str  := +Value;
      return M;
   end From_String;

   ------------------
   -- From_Integer --
   ------------------

   function From_Integer (Value : Integer)
                          return Multi_Type
   is
      M : Multi_Type;
   begin
      M.Kind := Kind_Integer;
      M.Int  := +Value;
      return M;
   end From_Integer;

   -------------------
   -- From_Callable --
   -------------------

   function From_Callable (Value : Callable)
                           return Multi_Type
   is
      M : Multi_Type;
   begin
      M.Kind := Kind_Callable;
      M.Func := Value;
      return M;
   end From_Callable;

   ------------------
   -- From_Boolean --
   ------------------

   function From_Boolean (Value : Boolean)
                          return Multi_Type
   is
      M : Multi_Type;
   begin
      M.Kind := Kind_Boolean;
      M.Bool := Value;
      return M;
   end From_Boolean;

   ---------------
   -- From_Null --
   ---------------

   function From_Null return Multi_Type
   is
      M : Multi_Type;
   begin
      M.Kind := Kind_Null;
      return M;
   end From_Null;

   ---------
   -- Get --
   ---------

   function Get (Arry : Multi_Type)
                 return String
   is
   begin
      return As_String (Arry);
   end Get;

   ---------
   -- Get --
   ---------

   function Get (Position : Cursor)
                 return Multi_Type
   is
   begin
      if Has_Element (Position) then
         return Element (Position);
      else
         return From_Null;
      end if;
   end Get;

   ---------
   -- Get --
   ---------

   function Get (Arry : Array_Type;
                 Key  : String)
                 return Multi_Type
   is
      Source : constant Cursor := Ref (Arry, Key);
   begin
      return Get (Source);
   end Get;

   ---------
   -- Get --
   ---------

   function Get (Position : Cursor;
                 Key      : String)
                 return Multi_Type
   is
   begin
      return Get (As_Array (Element (Position)), Key);
   end Get;

   -------------------
   -- Get_As_String --
   -------------------

   function Get_As_String (Arry : Array_Type;
                           Key  : String)
                           return String
   is
      M : constant Multi_Type := Get (Arry, Key);
   begin
      return As_String (M);
      -- case Kind_Of (M) is
      -- when Kind_String =>
      --    return As_String (M);
      -- when Kind_Integer =>
      --    return Helpers.Image (As_Integer (M));
      -- when Kind_Null =>
      --    return "";
      -- when others =>
      --    pragma Assert (False);
      -- end case;
   end Get_As_String;

   ------------
   -- Assign --
   ------------

   procedure Assign (Target : in out Array_Type;
                     Source : Cursor)
   is
      Multi : constant Multi_Type := Get (Source);
   begin
      Set (Target, Multi);
   end Assign;

   ---------
   -- Set --
   ---------

   procedure Set (Arry  : in out Array_Type;
                  Value : Multi_Type)
   is
   begin
      Append (Arry, "XXX-011", Value);
   end Set;

   ---------
   -- Set --
   ---------

   procedure Set (Arry  : in out Array_Type;
                  Key   : String;
                  Value : Multi_Type)
   is
--    Position : Cursor := Arry.Find (Key);
   begin
--    if not Has_Element (Position) then
--       Append (Arry, Key, From_Array (Empty_Array));
--       Position := Arry.Find (Key);
--    end if;
--    Set (Element (Position).Arry.all, Value);
      Include (Arry, Key, Value);
   end Set;

   -----------
   -- Set_2 --
   -----------

   procedure Set_2 (Arry  : in out Array_Type;
                    Key_1 : String;
                    Key_2 : String;
                    Value : Multi_Type)
   is
      Level_1 : Cursor := Arry.Find (Key_1);
   begin
      if not Has_Element (Level_1) then
         Arry.Insert (Key_1, From_Array (Empty_Array));
         Level_1 := Arry.Find (Key_1);
      end if;

      declare
         Array_1 : Array_Type := As_Array (Element (Level_1));
         Level_2 : Cursor := Array_1.Find (Key_2);
      begin
         if not Has_Element (Level_2) then
            Array_1.Insert (Key_2, From_Array (Empty_Array));
            Level_2 := Array_1.Find (Key_2);
         end if;

         declare
            Array_2 : Array_Type := As_Array (Element (Level_2));
         begin
            Set (Array_2, Value);
         end;
      end;
   end Set_2;

   -----------
   -- Set_3 --
   -----------

   procedure Set_3 (Arry  : in out Array_Type;
                    Key_1 : String;
                    Key_2 : String;
                    Key_3 : String;
                    Value : Multi_Type)
   is
      Level_1 : Cursor := Arry.Find (Key_1);
   begin
      if not Has_Element (Level_1) then
         Arry.Insert (Key_1, From_Array (Empty_Array));
         Level_1 := Arry.Find (Key_1);
      end if;

      declare
         Array_1 : Array_Type := As_Array (Element (Level_1));
         Level_2 : Cursor := Array_1.Find (Key_2);
      begin
         if not Has_Element (Level_2) then
            Array_1.Insert (Key_2, From_Array (Empty_Array));
            Level_2 := Array_1.Find (Key_2);
         end if;

         declare
            Array_2 : Array_Type := As_Array (Element (Level_2));
            Level_3 : Cursor := Array_2.Find (Key_3);
         begin
            if not Has_Element (Level_3) then
               Array_2.Insert (Key_3, From_Array (Empty_Array));
               Level_3 := Array_2.Find (Key_3);
            end if;

            declare
               Array_3 : Array_Type := As_Array (Element (Level_3));
            begin
               Set (Array_3, Value);
            end;
         end;
      end;
   end Set_3;

   -----------
   -- Set_4 --
   -----------

   procedure Set_4 (Arry  : in out Array_Type;
                    Key_1 : String;
                    Key_2 : String;
                    Key_3 : String;
                    Key_4 : String;
                    Value : Multi_Type)
   is
      -- Array_2 : constant Array_Access :=
      --   Element (Arry.Find (Key_1)).Arry;
   begin
      raise Program_Error with "not implemented";
      -- pragma Assert (Array_2 /= null);
      -- declare
      --    Array_3 : constant Array_Access := Element (Array_2.Find (Key_2)).Arry;
      -- begin
      --    pragma Assert (Array_3 /= null);
      --    declare
      --       Array_4 : constant Array_Access := Element (Array_3.Find (Key_3)).Arry;
      --    begin
      --       pragma Assert (Array_4 /= null);
      --       declare
      --          Array_5 : constant Array_Access :=
      --            Element (Array_4.Find (Key_4)).Arry;
      --       begin
      --          pragma Assert (Array_5 /= null);
      --          Set (Array_5.all, Value);
      --       end;
      --    end;
      -- end;
   end Set_4;

   -----------
   -- Set_5 --
   -----------

   procedure Set_5 (Arry  : in out Array_Type;
                    Key_1 : String;
                    Key_2 : String;
                    Key_3 : String;
                    Key_4 : String;
                    Key_5 : String;
                    Value : Multi_Type)
   is
--    Array_2 : constant Array_Access := Element (Arry.Find (Key_1)).Arry;
   begin
      raise Program_Error with "not implemented";
      -- pragma Assert (Array_2 /= null);
      -- declare
      --    Array_3 : constant Array_Access := Element (Array_2.Find (Key_2)).Arry;
      -- begin
      --    pragma Assert (Array_3 /= null);
      --    declare
      --       Array_4 : constant Array_Access := Element (Array_3.Find (Key_3)).Arry;
      --    begin
      --       pragma Assert (Array_4 /= null);
      --       declare
      --          Array_5 : constant Array_Access := Element (Array_3.Find (Key_4)).Arry;
      --       begin
      --          pragma Assert (Array_5 /= null);
      --          declare
      --             Array_6 : constant Array_Access :=
      --               Element (Array_5.Find (Key_5)).Arry;
      --          begin
      --             pragma Assert (Array_6 /= null);
      --             Set (Array_6.all, Value);
      --          end;
      --       end;
      --    end;
      -- end;
   end Set_5;

   -----------
   -- Isset --
   -----------

   function Isset (Position : Cursor;
                   Key      : String)
                   return Boolean
   is
   begin
      return Isset (As_Array (Element (Position)), Key);
   end Isset;

   -----------
   -- Isset --
   -----------

   function Isset (Arry : Array_Type;
                   Key  : String)
                   return Boolean
   is
   begin
      return Has_Element (Arry.Find (Key));
   end Isset;

   -------------
   -- Isset_2 --
   -------------

   function Isset_2 (Arry  : Array_Type;
                     Key_1 : String;
                     Key_2 : String)
                     return Boolean
   is
   begin
      if not Isset (Arry, Key_1) then
         return False;
      end if;

      declare
         Multi : constant Multi_Type := Get (Arry, Key_1);
      begin
         return Has_Element (As_Array (Multi).Find (Key_2));
      end;
   end Isset_2;

   -------------
   -- Isset_3 --
   -------------

   function Isset_3 (Arry  : Array_Type;
                     Key_1 : String;
                     Key_2 : String;
                     Key_3 : String)
                     return Boolean
   is
   begin
      if not Isset_2 (Arry, Key_1, Key_2) then
         return False;
      end if;

      declare
         Multi : constant Multi_Type := Get (Ref_2 (Arry, Key_1, Key_2));
      begin
         return Has_Element (As_Array (Multi).Find (Key_3));
      end;
   end Isset_3;

   -------------
   -- Isset_4 --
   -------------

   function Isset_4 (Arry  : Array_Type;
                     Key_1 : String;
                     Key_2 : String;
                     Key_3 : String;
                     Key_4 : String)
                     return Boolean
   is
   begin
      if not Isset_3 (Arry, Key_1, Key_2, Key_3) then
         return False;
      end if;

      declare
         Multi : constant Multi_Type := Get (Ref_3 (Arry, Key_1, Key_2, Key_3));
      begin
         return Has_Element (As_Array (Multi).Find (Key_4));
      end;
   end Isset_4;

   -------------
   -- Isset_5 --
   -------------

   function Isset_5 (Arry  : Array_Type;
                     Key_1 : String;
                     Key_2 : String;
                     Key_3 : String;
                     Key_4 : String;
                     Key_5 : String)
                     return Boolean
   is
   begin
      if not Isset_4 (Arry, Key_1, Key_2, Key_3, Key_4) then
         return False;
      end if;

      declare
         Multi : constant Multi_Type := Get (Ref_4 (Arry, Key_1, Key_2, Key_3, Key_4));
      begin
         return Has_Element (As_Array (Multi).Find (Key_5));
      end;
   end Isset_5;

   -------------
   -- Isset_6 --
   -------------

   function Isset_6 (Arry  : Array_Type;
                     Key_1 : String;
                     Key_2 : String;
                     Key_3 : String;
                     Key_4 : String;
                     Key_5 : String;
                     Key_6 : String)
                     return Boolean
   is
   begin
      if not Isset_5 (Arry, Key_1, Key_2, Key_3, Key_4, Key_5) then
         return False;
      end if;

      declare
         Multi : constant Multi_Type :=
           Get (Ref_5 (Arry, Key_1, Key_2, Key_3, Key_4, Key_5));
      begin
         return Has_Element (As_Array (Multi).Find (Key_6));
      end;
   end Isset_6;

   ------------
   -- Delete --
   ------------

   procedure Delete (Position : Cursor)
   is
   begin
--    Array_Maps.Delete (Map, Cursor);
      null;
   end Delete;

   ----------
   -- Find --
   ----------

   function Find (Arry : Array_Type;
                  Key  : String)
                  return Cursor
   is
      Map : Array_Maps.Map renames Array_Maps.Map (Arry);
      Pos : constant Array_Maps.Cursor := Array_Maps.Find (Map, Key);
   begin
      return Arrays.Cursor (Pos);
   end Find;

   ---------------
   -- First_Key --
   ---------------

   function First_Key (Arry : Array_Type)
                       return String
   is
   begin
      return Array_Maps.First_Key (Array_Maps.Map (Arry));
   end First_Key;

   -------------------
   -- First_Element --
   -------------------

   function First_Element (Arry : Array_Type)
                           return Multi_Type
   is
   begin
      return Array_Maps.First_Element (Array_Maps.Map (Arry));
   end First_Element;

   ------------------
   -- Last_Element --
   ------------------

   function Last_Element (Arry : Array_Type)
                          return Multi_Type
   is
   begin
      return Array_Maps.Last_Element (Array_Maps.Map (Arry));
   end Last_Element;

   ------------
   -- Length --
   ------------

   function Length (Arry : Array_Type)
                    return Natural
   is
   begin
      return Natural (Array_Maps.Length (Array_Maps.Map (Arry)));
   end Length;

   -----------
   -- Empty --
   -----------

   function Empty (Arry : Array_Type;
                   Key  : String)
                   return Boolean
   is
   begin
      return not Array_Maps.Has_Element (Arry.Find (Key));
   end Empty;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : Array_Type)
                   return Array_Type
   is
      Map : Array_Type;
      Item : Multi_Type;
   begin
      Item.Kind := Kind_Array;
      Item.Arry.Holder := new Array_Type'(Value);
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : Multi_Type)
                   return Array_Type
   is
      Map : Array_Type;
   begin
      Map.Insert (Key => Key, New_Item => Value);
      return Map;
   end Build;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : Lists.List_Type)
                   return Array_Type
   is
      Item : Multi_Type;
      Map  : Array_Type;
   begin
      Item.Kind := Kind_List;
      Item.List := Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : String)
                   return Array_Type
   is
      Item : Multi_Type;
      Map  : Array_Type;
   begin
      Item.Kind := Kind_String;
      Item.Str  := +Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : Integer)
                   return Array_Type
   is
      Item : Multi_Type;
      Map  : Array_Type;
   begin
      Item.Kind := Kind_Integer;
      Item.Int  := Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : Boolean)
                   return Array_Type
   is
      Item : Multi_Type;
      Map  : Array_Type;
   begin
      Item.Kind := Kind_Boolean;
      Item.Bool := Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : Callable)
                   return Array_Type
   is
      Item : Multi_Type;
      Map  : Array_Type;
   begin
      Item.Kind := Kind_Callable;
      Item.Func := Value;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   -----------
   -- Build --
   -----------

   function Build (Key   : String;
                   Value : Null_Type)
                   return Array_Type
   is
      Item : Multi_Type;
      Map  : Array_Type;
   begin
      Item.Kind := Kind_Null;
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   --------------
   -- To_Array --
   --------------

   function To_Array (List : Array_List_2)
            return Array_Type
   is
      use Array_Maps;

      Result : Array_Type;
   begin
      for A of List loop
         for B in A.Iterate loop
            Result.Include (Key   => Key     (B),
                            Value => Element (B));
         end loop;
      end loop;
      return Result;
   end To_Array;

   -----------
   -- First --
   -----------

   function First (Container : Array_Type) return Cursor
   is
   begin
      return Arrays.Cursor (Array_Maps.First (Array_Maps.Map (Container)));
   end First;

   ----------
   -- Next --
   ----------

   function Next (Container : Array_Type;
                  Position  : Cursor) return Cursor
   is
   begin
      return Arrays.Cursor (Array_Maps.Next (Array_Maps.Cursor (Position)));
   end Next;

   -----------
   -- First --
   -----------

   overriding
   function First (Object : Iterator) return Cursor is
   begin
      return First (Object.Container.all);
   end First;

   ----------
   -- Next --
   ----------

   overriding function Next
     (Object   : Iterator;
      Position : Cursor) return Cursor is
   begin
      return Next (Object.Container.all, Position);
   end Next;

   -------------
   -- Iterate --
   -------------

   function Iterate (Container : Array_Type)
                     return Map_Iterator_Interfaces.Forward_Iterator'Class
   is
      Fi : Iterator;
   begin
      Fi.Container := Container'Unrestricted_Access;
      return Fi;
   end Iterate;

   ----------------
   -- Initialize --
   ----------------

   overriding
   procedure Initialize (Holder : in out Array_Holder)
   is
   begin
      Holder.Holder := null;
   end Initialize;

   ------------
   -- Adjust --
   ------------

   overriding
   procedure Adjust (Holder : in out Array_Holder)
   is
   begin
      if Holder.Holder = null then
         return;
      end if;

      for E of Holder.Holder.all loop
         null;
--       Adjust (E.Arry);
         -- if E.Arry.Holder /= null then
         --    Logging.Log ("arrays.adjust", "Not null sub-array");
         -- end if;
      end loop;

      Holder.Holder := new Array_Type'(Copy (Holder.Holder.all));
   end Adjust;

   --------------
   -- Finalize --
   --------------

   overriding
   procedure Finalize (Holder : in out Array_Holder)
   is
      procedure Free is new
        Ada.Unchecked_Deallocation (Object => Array_Type,
                                    Name   => Array_Access);
   begin
      if Holder.Holder = null then
         return;
      end if;

      for E of Holder.Holder.all loop
         null;
--       Finalize (E.Arry);
         -- if E.Arry.Holder /= null then
         --    Logging.Log ("arrays.finalize", "Not null sub-array");
         -- end if;
      end loop;

      declare
         Arry : Array_Access := Holder.Holder;
      begin
         if Arry /= null then
--          Free (Arry);
            Holder.Holder := null;
         end if;
      end;
   end Finalize;

   -----------------
   -- Empty_Array --
   -----------------

   function Empty_Array
            return Array_Type
   is
      Item : Multi_Type;
      Arry : Array_Type;
   begin
      Item.Kind := Kind_Array;
      Item.Arry.Holder := new Array_Type'(Null_Array_Type);
      Arry.Append (Key => "XXX-929", Value => Item);
      return Arry;
   end Empty_Array;

   ---------------------
   -- Null_Multi_Type --
   ---------------------

   function Null_Multi_Type return Multi_Type
   is
   begin
      return
        (Kind => Kind_Null,
         Str  => UStrings.Null_UString,
         Int  => 0,
         Arry => Empty_Holder,
         List => Lists.Empty_List,
         Func => null,
         Bool => False);
   end Null_Multi_Type;

end Arrays;
