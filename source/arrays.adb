
package body Arrays
is

   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   function "-" (Item : Unbounded_String) return String
      renames To_String;

   ------------
   -- Append --
   ------------

   procedure Append (List : in out List_Type;
                     Item : String)
   is
   begin
      List.Append (+Item);
   end Append;

   ------------
   -- Append --
   ------------

   procedure Append (Arry  : in out Array_Type;
                     Value : Multi_Type)
   is
   begin
      Array_Maps.Insert (Array_Maps.Map (Arry), "XXX-011", Value);
   end Append;

   ------------
   -- Append --
   ------------

   procedure Append (Arry  : in out Array_Type;
                     Key   : String;
                     Value : Multi_Type)
   is
--    Position : Cursor := Arry.Find (Key);
   begin
--    if not Has_Element (Position) then
--       Append (Arry, Key, From_Array (Empty_Array));
--       Position := Arry.Find (Key);
--    end if;
--    Append (Element (Position).Arry.all, Value);
      Include (Arry, Key, Value);
   end Append;

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
      return Arrays.Element (Rec_1).Arry.Find (Key_2);
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
      return Arrays.Element (Rec_2).Arry.Find (Key_3);
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
      return Arrays.Element (Rec_3).Arry.Find (Key_4);
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
      return Arrays.Element (Rec_4).Arry.Find (Key_5);
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

   --------------
   -- As_Array --
   --------------

   function As_Array (Arry : Multi_Type)
                      return Array_Type
   is
   begin
      pragma Assert (Arry.Kind = Kind_Array);
      pragma Assert (Arry.Arry /= null);

      return Arry.Arry.all;
   end As_Array;

   -------------
   -- As_List --
   -------------

   function As_List (Arry : Multi_Type)
                     return List_Type
   is
   begin
      pragma Assert (Arry.Kind = Kind_List);
      pragma Assert (Arry.List /= null);

      return Arry.List.all;
   end As_List;

   ---------------
   -- As_String --
   ---------------

   function As_String (Arry : Multi_Type)
                      return String
   is
   begin
      pragma Assert (Arry.Kind = Kind_String);

      return -Arry.Str;
   end As_String;

   ----------------
   -- As_Integer --
   ----------------

   function As_Integer (Arry : Multi_Type)
                       return Integer
   is
   begin
      pragma Assert (Arry.Kind = Kind_Integer);

      return Arry.Int;
   end As_Integer;

   ----------------
   -- As_Boolean --
   ----------------

   function As_Boolean (Arry : Multi_Type)
                       return Boolean
   is
   begin
      pragma Assert (Arry.Kind = Kind_Boolean);

      return Arry.Bool;
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
      M.Kind     := Kind_Array;
      M.Arry     := new Array_Type;
      M.Arry.all := Value;
      return M;
   end From_Array;

   ---------------
   -- From_List --
   ---------------

   function From_List (Value : List_Type)
                       return Multi_Type
   is
      M : Multi_Type;
   begin
      M.Kind     := Kind_List;
      M.List.all := Value;
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

   ---------
   -- Get --
   ---------

   function Get (Arry : Multi_Type)
                 return String
   is
   begin
      return As_String (Arry);
   end Get;

   function Get (Position : Cursor)
                 return Multi_Type
   is
   begin
      return Element (Position);
   end Get;

   function Get (Arry : Array_Type;
                 Key  : String)
                 return Multi_Type
   is
      Source : constant Cursor := Ref (Arry, Key);
   begin
      return Get (Source);
   end Get;

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
      Append (Arry, Value);
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
      Array_2 : constant Array_Access := Element (Arry.Find (Key_1)).Arry;
   begin
      pragma Assert (Array_2 /= null);
      declare
         Array_3 : constant Array_Access := Element (Array_2.Find (Key_2)).Arry;
      begin
         pragma Assert (Array_3 /= null);
         Set (Array_3.all, Value);
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
      Array_2 : constant Array_Access := Element (Arry.Find (Key_1)).Arry;
   begin
      pragma Assert (Array_2 /= null);
      declare
         Array_3 : constant Array_Access := Element (Array_2.Find (Key_2)).Arry;
      begin
         pragma Assert (Array_3 /= null);
         declare
            Array_4 : constant Array_Access := Element (Array_3.Find (Key_3)).Arry;
         begin
            pragma Assert (Array_4 /= null);
            Set (Array_4.all, Value);
         end;
      end;
   end Set_3;

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
      Array_2 : constant Array_Access := Element (Arry.Find (Key_1)).Arry;
   begin
      pragma Assert (Array_2 /= null);
      declare
         Array_3 : constant Array_Access := Element (Array_2.Find (Key_2)).Arry;
      begin
         pragma Assert (Array_3 /= null);
         declare
            Array_4 : constant Array_Access := Element (Array_3.Find (Key_3)).Arry;
         begin
            pragma Assert (Array_4 /= null);
            declare
               Array_5 : constant Array_Access := Element (Array_3.Find (Key_4)).Arry;
            begin
               pragma Assert (Array_5 /= null);
               declare
                  Array_6 : constant Array_Access :=
                    Element (Array_5.Find (Key_5)).Arry;
               begin
                  pragma Assert (Array_6 /= null);
                  Set (Array_6.all, Value);
               end;
            end;
         end;
      end;
   end Set_5;

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
                    return Ada.Containers.Count_Type
   is
   begin
      return Array_Maps.Length (Array_Maps.Map (Arry));
   end Length;

   --------------
   -- Get_List --
   --------------

   function Get_List (Arry : Array_Type;
                      Key  : String)
                      return List_Type
                      is (Empty_List);

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
      Item : Multi_Type;
      Map  : Array_Type;
   begin
      Item.Kind := Kind_Array;
      Item.Arry := new Array_Type'(Value);
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

   function Build (Key   : String;
                   Value : List_Type)
                   return Array_Type
   is
      Item : Multi_Type;
      Map  : Array_Type;
   begin
      Item.Kind := Kind_List;
      Item.List := new List_Type'(Value);
      Map.Insert (Key => Key, New_Item => Item);
      return Map;
   end Build;

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

   -- ------------------------
   -- -- Constant_Reference --
   -- ------------------------

   -- function Constant_Reference (Container : aliased in Array_Type;
   --                              Position  : Cursor)
   --                              return Constant_Reference_Type
   -- is
   -- begin
   --    return Arrays.Constant_Reference_Type (
   --      Array_Maps.Constant_Reference (Container => Array_Maps.Map (Container),
   --                                     Position  => Array_Maps.Cursor (Position)));
   -- end Constant_Reference;

   -- ---------------
   -- -- Reference --
   -- ---------------

   -- function Reference (Container : aliased in out Array_Type;
   --                     Position  : Cursor)
   --                     return Reference_Type
   -- is
   -- begin
   --    return Arrays.Reference_Type (
   --      Array_Maps.Reference (Container => Array_Maps.Map (Container),
   --                            Position  => Array_Maps.Cursor (Position)));
   -- end Reference;

   -- function Constant_Reference (Container : aliased in Array_Type;
   --                              Key       : Key_Type)
   --                              return Constant_Reference_Type
   -- is
   -- begin
   --    return Arrays.Constant_Reference_Type (
   --      Array_Maps.Constant_Reference (Container => Array_Maps.Map (Container),
   --                                     Key       => -Key));
   -- end Constant_Reference;

   -- function Reference (Container : aliased in out Array_Type;
   --                     Key       : Key_Type)
   --                     return Reference_Type
   -- is
   -- begin
   --    return Arrays.Reference_Type (
   --      Array_Maps.Reference (Container => Array_Maps.Map (Container),
   --                            Key       => -Key));
   -- end Reference;

   -----------
   -- First --
   -----------

   overriding
   function First (Object : Iterator) return Cursor is
   begin
      return First (Object.Container.all);
      -- if Object.Node = null then
      --    return Arrays.Cursor (Object.Container.First);
      -- else
      --    return Cursor'(Object.Container, Object.Node);
      -- end if;
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
      Fi : Iterator; -- Map_Iterator_Interfaces.Forward_Iterator'Class :=
--        Iterate (Array_Maps.Map (Container));
   begin
      Fi.Container := Container'Unrestricted_Access;
      return Fi; -- Array_Maps.
   end Iterate;

   -- function Iterate (Container : Array_Type)
   --                   return Map_Iterator_Interfaces.Forward_Iterator'Class
   -- is
   -- begin
   --    return It : Map_Iterator_Interfaces.Forward_Iterator do
   --       It.Container := Container'Unrestricted_Access;
   --       It.Position  := No_Element;
   --    end return;
   -- end Iterate;

end Arrays;
