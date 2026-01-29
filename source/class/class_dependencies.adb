--
-- Dependencies API: WP_Dependencies base class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Ada.Text_IO;

with Php.Lists;
with Php.Strings;

with Wp_Common;

package body Class_Dependencies
is

   --------------
   -- Do_Items --
   --------------

   function Do_Items (This    : in out Wp_Dependencies;
                      Handles : List_Type := Empty_List; -- = false,
                      Group   : Integer   := 0) --  = false
                      return List_Type
   is
      use Php.Lists;
      use List_Vectors;

      --
      -- If nothing is passed, print the queue. If a string is passed,
      -- print that item. If an array is passed, print those items.
      --
      Handles_2 : List_Type := (if Handles.Is_Empty
                                then This.Queue else Handles); -- (array)
      Unused : Boolean;
   begin
      Unused := All_Deps (This, Handles_2);

      for A of This.To_Do loop
         declare
            use Class_Dependency;
            use Class_Dependency.Dependency_Maps;

--          Key    : String := -A.Key;
            Handle : constant String := A; -- .Value;
         begin
            if
              not In_List (Handle, This.Done, True) and then
              This.Registered.Find (Handle) /= Dependency_Maps.No_Element
            then
               --
               -- Attempt to process the item. If successful,
               -- add the handle to the done array.
               --
               -- Unset the item from the to_do array.
               --
               if This.Do_Item (Handle, Group) then
                  This.Done.Append (Handle); -- ()
               end if;

--               Unset (This.To_Do (Key));
            end if;
         end;
      end loop;

      return This.Done;
   end Do_Items;

   --------------
   -- Do_Items --
   --------------

   function Do_Items (This    : in out Wp_Dependencies;
                      Handles : Boolean;
                      Group   : Integer := 0) --  = false
                      return List_Type
   is
   begin
      return Do_Items (This, [], Group);
   end Do_Items;

   --------------
   -- Do_Items --
   --------------

   procedure Do_Items (This    : in out Wp_Dependencies;
                       Handles : Boolean;
                       Group   : Integer := 0)
   is
      Unused : constant List_Type :=
        Do_Items (This, Handles, Group);
   begin
      null;
   end Do_Items;

   -------------
   -- Do_Item --
   -------------

   function Do_Item (This   : Wp_Dependencies;
                     Handle : String;
                     Group  : Integer := 0) -- false
                     return Boolean
   is
      use Class_Dependency.Dependency_Maps;
   begin
      return This.Registered.Find (Handle) /= No_Element;
   end Do_Item;

   --------------
   -- All_Deps --
   --------------

   function All_Deps (This      : in out Wp_Dependencies;
                      Handles   : List_Type; -- String_Array;
                      Recursion : Boolean := False;
                      Group     : Integer := 0) -- = false
                      return Boolean
   is
      use Php.Lists;
      use Php.Strings;
      use Wp_Common;
      use List_Vectors;

      Handles_2 : constant List_Type := Handles; -- (array)
   begin
      if Handles_2.Is_Empty then
         return False;
      end if;

      for Handle of Handles_2 loop
         declare
            Handle_Parts : constant List_Type := Explode ("?", Handle);
            Handle_2     : constant String    := Handle_Parts.First_Element; --  (0);
            Queued       : constant Boolean   := In_List (Handle_2, This.To_Do, True);
         begin
            if In_List (Handle_2, This.Done, True) then -- Already done.
               goto Continue;
            end if;

            declare
               use Class_Dependency;
               use Class_Dependency.Dependency_Maps;
--             use String_Vectors;

               Moved : constant Boolean := This.Set_Group (Handle_2, Recursion, Group);
               New_Group  : constant Integer := This.Groups (Handle_2);
               Keep_Going : Boolean := True;
            begin
               if Queued and not Moved then -- Already queued and in the right group.
                  goto Continue;
               end if;

               if This.Registered.Find (Handle_2) = Dependency_Maps.No_Element then
                  Keep_Going := False; -- Item doesn't exist.
               elsif
                 not This.Registered (Handle_2).Deps.Is_Empty and then
--               This.Registered (Handle_2).Deps /= Empty_String_Array and then
                 List_Diff (This.Registered (Handle_2).Deps,
                            Array_Keys (This.Registered)).Is_Empty
               then
                  Keep_Going := False; -- Item requires dependencies that don't exist.
               elsif
                 not This.Registered (Handle_2).Deps.Is_Empty and then
--               This.Registered (Handle_2).Deps /= Empty_String_Array and then
                 not This.All_Deps (This.Registered (Handle_2).Deps,
                                    Recursion => True,
                                    Group     => New_Group)
               then
                  Keep_Going := False; -- Item requires dependencies that don't exist.
               end if;

               if not Keep_Going then -- Either item or its dependencies don't exist.
                  if Recursion then
                     return False; -- Abort this branch.
                  else
                     goto Continue; -- We're at the top level. Move on to the next one.
                  end if;
               end if;

               if Queued then -- Already grabbed it and its dependencies.
                  goto Continue;
               end if;

               if "" /= Handle_Parts (Handle_Parts.First_Index + 1) then
                  This.Args.Insert
                    (Key      => Handle_2,
                     New_Item => Handle_Parts (Handle_Parts.First_Index + 1));
               end if;

               This.To_Do.Append (Handle_2);
            end;
            << Continue >>
         end;
      end loop;

      return True;
   end All_Deps;

   ---------
   -- Add --
   ---------

   function Add (This   : in out Wp_Dependencies;
                 Handle : String;
                 Src    : String;
                 Deps   : List_Type := Empty_List;
                 Ver    : String    := "";
                 Args   : String    := "")
                 return Boolean
   is
      use Php.Lists;
      use Class_Dependency;
      use Class_Dependency.Dependency_Maps;
      use List_Vectors;
   begin
      if Has_Element (This.Registered.Find (Handle)) then
         return False;
      end if;

      This.Registered.Insert
        (Handle,
         New_Item => X_Wp_Dependency'(X_Construct (Handle, Src, Deps, Ver, Args)));

      -- If the item was enqueued before the details were registered, enqueue it now.
      if List_Key_Exists (Handle, This.Queued_Before_Register) then
         declare
            Position : List_Vectors.Cursor :=
              This.Queued_Before_Register.Find (Handle);
         begin
            if not Has_Element (Position) then
               This.Enqueue ([Handle & "?" & Element (Position)]);
            else
               This.Enqueue ([Handle]);
            end if;

            This.Queued_Before_Register.Delete (Position);
         end;
      end if;

      return True;
   end Add;

   ---------
   -- Add --
   ---------

   procedure Add (This   : in out Wp_Dependencies;
                  Handle : String;
                  Src    : String;
                  Deps   : List_Type := Empty_List;
                  Ver    : String    := "";
                  Args   : String    := "")
   is
      Unused : constant Boolean :=
        Add (This, Handle, Src, Deps, Ver, Args);
   begin
      null;
   end Add;

   --------------
   -- Add_Data --
   --------------

   function Add_Data (This   : in out Wp_Dependencies;
                      Handle : String;
                      Key    : String;
                      Value  : String)
                      return Boolean
   is
   begin
      return Add_Data (This, Handle, Key, List_Type'[Value]);
   end Add_Data;

   --------------
   -- Add_Data --
   --------------

   function Add_Data (This   : in out Wp_Dependencies;
                      Handle : String;
                      Key    : String;
                      Value  : List_Type)
                      return Boolean
   is
      use Class_Dependency.Dependency_Maps;
   begin
      if This.Registered.Find (Handle) = No_Element then
         return False;
      end if;

      declare
         use Class_Dependency;

         S : X_Wp_Dependency renames This.Registered (Handle);
      begin
         return S.Add_Data (Key, Value);
--       return This.Registered (Handle).Add_Data (Key, Value);
      end;
   end Add_Data;

   --------------
   -- Add_Data --
   --------------

   procedure Add_Data (This   : in out Wp_Dependencies;
                       Handle : String;
                       Key    : String;
                       Value  : String)
   is
      Unused : constant Boolean :=
        Add_Data (This, Handle, Key, Value);
   begin
      null;
   end Add_Data;

   --------------
   -- Get_Data --
   --------------

--        public function get_data( handle, key ) then
   function Get_Data (This   : Wp_Dependencies;
                      Handle : String;
                      Key    : String)
                      return String -- Array_Type
   is
      use Php.Strings;
      use Class_Dependency.Dependency_Maps;
   begin
      if This.Registered.Find (Handle) = No_Element then
         return ""; -- False;
      end if;

      if not Isset (This.Registered (Handle).Extra (Key)) then
         return ""; -- False;
      end if;

      return This.Registered (Handle).Extra (Key);
   end Get_Data;

   ------------
   -- Remove --
   ------------

--        public function remove( handles ) then
   procedure Remove (This    : in out Wp_Dependencies;
                     Handles : List_Type)
   is
   begin
      for Handle of Handles loop
         This.Registered.Delete (Handle);
--       Unset (This.Registered (Handle));
      end loop;
   end Remove;

   -------------
   -- Enqueue --
   -------------

   procedure Enqueue (This    : in out Wp_Dependencies;
                      Handles : List_Type)
   is
      use Php.Lists;
      use Php.Strings;
      use List_Vectors;
      use Class_Dependency.Dependency_Maps;
   begin
      for Handle of Handles loop
         declare
            List  : constant List_Type := Explode ("?", Handle);
            First : constant String    := List (1);
         begin
            if
              not In_List (First, This.Queue, True) and then
              Has_Element (This.Registered.Find (First))
            then
               This.Queue.Append (First);

               -- Reset all dependencies so they must be recalculated in
               -- recurse_deps().
               This.All_Queued_Deps.Clear;

               if List.Length in 2 then
                  This.Args (First) := List (2);
               end if;

            elsif not Has_Element (This.Registered.Find (First)) then
               declare
                  Position : List_Vectors.Cursor :=
                    This.Queued_Before_Register.Find (First);
               begin
                  if Has_Element (Position) then
                     This.Queued_Before_Register.Delete (Position);
                  end if;
               end;

               if List.Length in 2 then
                  declare
                     Position : constant List_Vectors.Cursor :=
                       This.Queued_Before_Register.Find (First);

                     Second : constant String := List (2);
                  begin
                     if Has_Element (Position) then
                        This.Queued_Before_Register.Replace_Element
                          (Position, New_Item => Second);
                     else
                        This.Queued_Before_Register.Append
                          (New_Item => Second);
                     end if;
                  end;
               end if;
            end if;
         end;
      end loop;
   end Enqueue;

   -------------
   -- Dequeue --
   -------------

--        public function dequeue( handles ) then
   procedure Dequeue (This    : in out Wp_Dependencies;
                      Handles : List_Type)
   is
      use Php.Lists;
      use Php.Strings;
   begin
      for Handle of Handles loop
         declare
            Handle_2 : constant List_Type := Explode ("?", Handle);
            First    : constant String := Handle_2 (Handle_2.First_Index);
            Key      : constant String :=
               List_Search (First, This.Queue, True);

            Position_1 : List_Vectors.Cursor;
            Position_2 : Class_Dependency.String_Maps.Cursor;
         begin
            if "" /= Key then
               -- Reset all dependencies so they must be recalculated in
               -- recurse_deps().
               This.All_Queued_Deps.Clear; --  := null;

               Position_1 := This.Queue.Find (Key);
               This.Queue.Delete (Position_1);

               Position_2 := This.Args.Find (First);
               This.Args.Delete (Position_2);
--             Unset (This.Queue (Key));
--             Unset (This.Args (Handle_2 (Handle_2.First_Index)));

            elsif List_Key_Exists (First, This.Queued_Before_Register) then
               Position_1 := This.Queued_Before_Register.Find (First);
               This.Queued_Before_Register.Delete (Position_1);
--             Unset (This.Queued_Before_Register (Handle_2 (Handle_2.First_Index)));
            end if;
         end;
      end loop;
   end Dequeue;

   ------------------
   -- Recurse_Deps --
   ------------------

--        protected function recurse_deps( queue, handle ) then
   function Recurse_Deps (This   : in out Wp_Dependencies;
                          Queue  : List_Type; -- String_Array;
                          Handle : String)
                          return Boolean
   is
      use Php.Lists;
      use Class_Dependency;
      use Class_Dependency.Dependency_Maps;
      use List_Vectors;

      Queue_2 : List_Type := Queue;
   begin
      if not This.All_Queued_Deps.Is_Empty then
--         return Isset (This.All_Queued_Deps.Find (Handle));
         return This.All_Queued_Deps.Find (Handle) /= List_Vectors.No_Element;
      end if;

      declare
         All_Deps : List_Type := Queue_2; -- Array_Fill_Keys (Queue_2, True);
--       All_Deps : Array_Type := Array_Fill_Keys (Queue_2, True);
         Queues   : List_Type;
         Done     : List_Type;
      begin
         while not Queue_2.Is_Empty loop
            for Queued of Queue_2 loop
               if
                 Done.Find (Queued) = List_Vectors.No_Element and then
--               not Isset (Done (Queued)) and then
                 This.Registered.Find (Queued) /= Dependency_Maps.No_Element
--               Isset (This.Registered (Queued))
               then
                  declare
                     Deps   : constant List_Type := This.Registered (Queued).Deps;
--                   Deps   : constant String_Array := This.Registered (-Queued).Deps;
                     Unused : Integer;
                  begin
                     if not Deps.Is_Empty then
--                   if Deps /= Empty_String_Array then
                        All_Deps.Append (Deps);
--                      All_Deps.Append ([Deps]);
--                      All_Deps.Append (Array_Fill_Keys (Deps, True));
                        Unused := List_Push (Queues, Deps);
                     end if;
                  end;
                  Done.Append (Queued);
--                Done (Queued) := True;
               end if;
            end loop;
            Queue_2.Append (List_Pop (Queues));
--            Queue_2 := Array_Pop (Queues);
         end loop;

         This.All_Queued_Deps := All_Deps;

         return This.All_Queued_Deps.Find (Handle) /= List_Vectors.No_Element;
--       return Isset (This.All_Queued_Deps (Handle));
      end;
   end Recurse_Deps;

   -----------
   -- Query --
   -----------

--        public function query( handle, status = "registered" ) then
   function Query (This   : in out Wp_Dependencies;
                   Handle : String;
                   Status : String := "registered")
                   return Query_Result -- Boolean
   is
      use Php.Lists;
      use Class_Dependency;
      use Class_Dependency.Dependency_Maps;

      Null_Deps : Class_Dependency.X_Wp_Dependency;
   begin
--                switch ( status ) then
--                        case "registered":
--                        case "scripts": -- Back compat.
      if Status in "registered" | "scripts" then
         if No_Element /= This.Registered.Find (Handle) then
            return (True, This.Registered (Handle));
         end if;
         return (False, Null_Deps);

--                        case "enqueued":
--                        case "queue": -- Back compat.
      elsif Status in "enqueued" | "queue" then
         if In_List (Handle, This.Queue, True) then
            return (True, Null_Deps);
         end if;
         return (This.Recurse_Deps (This.Queue, Handle), Null_Deps);

--                        case "to_do":
--                        case "to_print": -- Back compat.
      elsif Status in "to_do" | "to_print" then
         return (In_List (Handle, This.To_Do, True), Null_Deps);

--                        case "done":
--                        case "printed": -- Back compat.
      elsif Status in "done" | "printed" then
         return (In_List (Handle, This.Done, True), Null_Deps);
      end if;

      return (False, Null_Deps);
   end Query;

   ---------------
   -- Set_Group --
   ---------------

--        public function set_group( handle, recursion, group ) then
   function Set_Group (This      : in out Wp_Dependencies;
                       Handle    : String;
                       Recursion : Boolean;
                       Group     : Integer)
                       return Boolean
   is
      use Class_Dependencies.Integer_Maps;
   begin
      if
        This.Groups.Find (Handle) /= No_Element and then
--      Isset (This.Groups (Handle)) and then
        This.Groups (Handle) <= Group
      then
         return False;
      end if;

      Ada.Text_IO.Put_Line (This'Image);
      This.Groups.Include (Key      => Handle,
                           New_Item => Group);
--    This.Groups.Replace (Handle, Group);
--    This.Groups (Handle) := Group;

      return True;
   end Set_Group;

end Class_Dependencies;
