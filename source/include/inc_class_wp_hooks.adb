--
-- Plugin API: WP_Hook class
--
-- @package WordPress
-- @subpackage Plugin
-- @since 4.7.0
--

with Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;

with Arrays.Io;
with Hb_Common;

with Inc_Elab_Hooks;
with Inc_Elab_Plugins;
with Inc_Plugins;

package body Inc_Class_Wp_Hooks
is

   ----------------
   -- Array_Keys --
   ----------------

   function Array_Keys (Map : Priority_Maps.Map)
                        return List_Type
   is
      use Hb_Common;
      use Priority_Maps;

      Result : List_Type;
   begin
      for A in Map.Iterate loop
         Result.Append (+Priority_Type'Image (Key (A)));
      end loop;
      return Result;
   end Array_Keys;

   ----------------
   -- Add_Filter --
   ----------------

   procedure Add_Filter (This          : in out Wp_Hook;
                         Hook_Name     : String;
                         Callback      : Arrays.Callable;
                         Priority      : Priority_Type;
                         Accepted_Args : Integer)
   is
      use Ada.Containers;
      use Hb_Common;
      use Php;
      use Inc_Elab_Plugins;
      use Inc_Plugins;

      Index : constant String :=
        X_Wp_Filter_Build_Unique_Id (Hook_Name, Callback, Integer (Priority));

      Priority_Existed : constant Boolean :=
        Priority_Maps.Has_Element (This.Callbacks.Find (Priority));

      Item : constant Array_Type := Arrays.To_Array ((
        Build ("function",      Callback),
        Build ("accepted_args", Accepted_Args)
      ));

      Map : Index_Maps.Map;
   begin
      Map.Include (Key => Index, New_Item => Item);
      This.Callbacks.Include (Key => Priority, New_Item => Map);
--    This.Callbacks (Priority) (Idx) := Item;

      -- If we're adding a new priority to the list, put them back in sorted order.
      if not Priority_Existed and then This.Callbacks.Length > 1 then
         null; -- Ksort (This.Callbacks, SORT_NUMERIC);
      end if;

      if This.Nesting_Level > 0 then
         This.Resort_Active_Iterations (Priority, Priority_Existed);
      end if;
   end Add_Filter;

--         --
--         -- Handles resetting callback priority keys mid-iteration.
--         --
--         -- @since 4.7.0
--         --
--         -- @param false|int new_priority     Optional. The priority of the new filter being added. Default false,
--         --                                    for no priority being added.
--         -- @param bool      priority_existed Optional. Flag for whether the priority already existed before the new
--         --                                    filter was added. Default false.
--         --
--         private function resort_active_iterations( new_priority = false, priority_existed = false ) then
--                 new_priorities = array_keys( this.callbacks );

--                 -- If there are no remaining hooks, clear out all running iterations.
--                 if ( ! new_priorities ) then
--                         foreach ( this.iterations as index => iteration ) then
--                                 this.iterations[ index ] = new_priorities;
--                         end;

--                         return;
--                 end;

--                 min = min( new_priorities );

--                 foreach ( this.iterations as index => &iteration ) then
--                         current = current( iteration );

--                         -- If we"re already at the end of this iteration, just leave the array pointer where it is.
--                         if ( false === current ) then
--                                 continue;
--                         end;

--                         iteration = new_priorities;

--                         if ( current < min ) then
--                                 array_unshift( iteration, current );
--                                 continue;
--                         end;

--                         while ( current( iteration ) < current ) then
--                                 if ( false === next( iteration ) ) then
--                                         break;
--                                 end;
--                         end;

--                         -- If we have a new priority that didn"t exist, but ::apply_filters() or ::do_action() thinks it"s the current priority...
--                         if ( new_priority === this.current_priority[ index ] && ! priority_existed ) then
--                                 --
--                                 -- ...and the new priority is the same as what this.iterations thinks is the previous
--                                 -- priority, we need to move back to it.
--                                 --

--                                 if ( false === current( iteration ) ) then
--                                         -- If we"ve already moved off the end of the array, go back to the last element.
--                                         prev = end( iteration );
--                                 end; else then
--                                         -- Otherwise, just go back to the previous element.
--                                         prev = prev( iteration );
--                                 end;

--                                 if ( false === prev ) then
--                                         -- Start of the array. Reset, and go about our day.
--                                         reset( iteration );
--                                 end; elseif ( new_priority !== prev ) then
--                                         -- Previous wasn"t the same. Move forward again.
--                                         next( iteration );
--                                 end;
--                         end;
--                 end;

--                 unset( iteration );
--         end;

--         --
--         -- Removes a callback function from a filter hook.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string                hook_name The filter hook to which the function to be removed is hooked.
--         -- @param callable|string|array callback  The callback to be removed from running when the filter is applied.
--         --                                         This method can be called unconditionally to speculatively remove
--         --                                         a callback that may or may not exist.
--         -- @param int                   priority  The exact priority used when adding the original filter callback.
--         -- @return bool Whether the callback existed before it was removed.
--         --
--         public function remove_filter( hook_name, callback, priority ) then
--                 function_key = _wp_filter_build_unique_id( hook_name, callback, priority );

--                 exists = isset( this.callbacks[ priority ][ function_key ] );

--                 if ( exists ) then
--                         unset( this.callbacks[ priority ][ function_key ] );

--                         if ( ! this.callbacks[ priority ] ) then
--                                 unset( this.callbacks[ priority ] );

--                                 if ( this.nesting_level > 0 ) then
--                                         this.resort_active_iterations();
--                                 end;
--                         end;
--                 end;

--                 return exists;
--         end;

   ----------------
   -- Has_Filter --
   ----------------

   function Has_Filter (This      : Wp_Hook;
                        Hook_Name : String := "";
                        Callback  : Boolean := False)
                        return Boolean
   is
      use Inc_Elab_Plugins;
   begin
      if False = Callback then
         return This.Has_Filters; -- ()
      end if;

--       declare
--          Function_Key : String :=
--            X_Wp_Filter_Build_Unique_Id (Hook_Name, Callback, False);
--       begin

--          if Function_Key = "" then
--             return False;
--          end if;

--          for A in This.Callbacks.Iterate loop
--             declare
--                Priority  : Priority_Type  := Priority_Maps.Key (A);
--                Callbacks : Index_Maps.Map := Priority_Maps.Element (A);
--             begin
--                if Index_Maps.Has_Element (Callbacks.Find (Function_Key)) then
-- --             if Isset (Callbacks (Function_Key)) then
--                   return Priority;
--                end if;
--             end;
--          end loop;
--       end;

      return False;
   end Has_Filter;

   -----------------
   -- Has_Filters --
   -----------------

   function Has_Filters (This : Wp_Hook)
                         return Boolean
   is
   begin
      for Callbacks of This.Callbacks loop
         if not Callbacks.Is_Empty then
--       if Callbacks then
            return True;
         end if;
      end loop;

      return False;
   end Has_Filters;

--         --
--         -- Removes all callbacks from the current filter.
--         --
--         -- @since 4.7.0
--         --
--         -- @param int|false priority Optional. The priority number to remove. Default false.
--         --
--         public function remove_all_filters( priority = false ) then
--                 if ( ! this.callbacks ) then
--                         return;
--                 end;

--                 if ( false === priority ) then
--                         this.callbacks = array();
--                 end; elseif ( isset( this.callbacks[ priority ] ) ) then
--                         unset( this.callbacks[ priority ] );
--                 end;

--                 if ( this.nesting_level > 0 ) then
--                         this.resort_active_iterations();
--                 end;
--         end;

   -------------------
   -- Apply_Filters --
   -------------------

   function Apply_Filters (This  : in out Wp_Hook;
                           Value : String;
                           Args  : Array_Type) -- Args_Type) -- Array_Type)
                           return String
   is
      use Hb_Common;
      use Php;

      Args_2        : constant Array_Type := Args;
      Nesting_Level : Nesting_Type;
      Num_Args      : Natural;
      Value_2       : Unbounded_String := +Value;
   begin
      if This.Callbacks.Is_Empty then
         return Value;
      end if;

      Nesting_Level := This.Nesting_Level;

      This.Nesting_Level :=
        This.Nesting_Level + 1;

      if This.Iterations.Last_Index < Nesting_Level then
         This.Iterations.Append (Array_Keys (This.Callbacks));
      else
         This.Iterations (Nesting_Level) := Array_Keys (This.Callbacks);
      end if;
--    This.Iterations (Nesting_Level) := Array_Keys (This.Callbacks);
      Num_Args                        := Arrays.Count (Args);

      loop
         if This.Current_Priority.Last_Index < Nesting_Level then
            This.Current_Priority.Append (
              This.Callbacks.First_Key);
         end if;
--       This.Current_Priority (Nesting_Level) :=
--         Current (This.Iterations (Nesting_Level));

         declare
            Priority : constant Priority_Type :=
              This.Current_Priority (Nesting_Level);
         begin
-- Put_Line ("  Priority: " & Priority'Image);
-- for A in This.Callbacks.Iterate loop
--    Put_Line ("  " & Priority_Maps.Key (A)'Image);
--    for B in Priority_Maps.Element (A).Iterate loop
--       Put ("    " & Index_Maps.Key (B));
--       Put ("  ");
-- --    Put ("  " & Array_Maps.Key (Index_Maps.Element (B)));
--       New_Line;
--    end loop;
-- end loop;
            for The_X of This.Callbacks (Priority) loop
               -- if not This.Doing_Action then
               --    Args_2 (Args_2.First_Index) := Value_2;
               -- end if;

               declare
                  Accepted_Args : constant Natural  :=
                    As_Integer (Get (The_X, "accepted_args"));

                  User_Function : constant Callable :=
                    As_Callable (Get (The_X, "function"));
               begin
                  -- Avoid the array_slice() if possible.
                  if 0 = Accepted_Args then
                     Value_2 := +Call_User_Func (User_Function);
                  elsif Accepted_Args >= Num_Args then
                     Value_2 := +Call_User_Func_Array (User_Function, Args_2);
                  else
                     Value_2 :=
                       +Call_User_Func_Array (
                          User_Function,
                          Array_Slice (Args_2, 0, Accepted_Args)); -- (int)
                  end if;
               end;
            end loop;
         end;
         exit when True;
--       exit when not Next (This.Iterations (Nesting_Level).Element);
      end loop;

      This.Iterations      .Delete (Nesting_Level);
      This.Current_Priority.Delete (Nesting_Level);
--    Unset (This.Iterations (Nesting_Level));
--    Unset (This.Current_Priority (Nesting_Level));

      This.Nesting_Level :=
        This.Nesting_Level - 1;

      return -Value_2;
   end Apply_Filters;

   procedure Apply_Filters (This  : in out Wp_Hook;
                            Value : String;
                            Args  : Array_Type)
   is
      Unused : constant String := Apply_Filters (This, Value, Args);
   begin
      null;
   end Apply_Filters;

   ---------------
   -- Do_Action --
   ---------------

   procedure Do_Action (This : in out Wp_Hook;
                        Args : Array_Type)
   is
   begin
      This.Doing_Action := True;
      This.Apply_Filters ("", Args);

      -- If there are recursive calls to the current action, we haven't finished it
      -- until we get to the last one.
      if This.Nesting_Level = 0 then
         This.Doing_Action := False;
      end if;
   end Do_Action;

   -----------------
   -- Do_All_Hook --
   -----------------

   procedure Do_All_Hook (This : in out Wp_Hook;
                          Args : Array_Type)
   is
      use Hb_Common;
      use Php;

      Nesting_Level : constant Nesting_Type := This.Nesting_Level;
   begin
      This.Nesting_Level := This.Nesting_Level + 1;
      This.Iterations (Nesting_Level) := Array_Keys (This.Callbacks);

      loop
         declare
            Priority : constant Priority_Type := 0;
            -- Current (This.Iterations (Nesting_Level));
         begin
            for The_X of This.Callbacks (Priority) loop
               declare
                  Unused : Unbounded_String;
                  Func   : constant Callable := As_Callable (Get (The_X, "function"));
               begin
                  Unused := +Call_User_Func_Array (Func, Args);
               end;
            end loop;
         end;
         exit when True; -- not Next (This.Iterations (Nesting_Level));
      end loop;

      This.Iterations.Delete (Nesting_Level);
--    Unset (This.Iterations (Nesting_Level));
      This.Nesting_Level := This.Nesting_Level - 1;
   end Do_All_Hook;

--         --
--         -- Return the current priority level of the currently running iteration of the hook.
--         --
--         -- @since 4.7.0
--         --
--         -- @return int|false If the hook is running, return the current priority level.
--         --                   If it isn't running, return false.
--         --
--         public function current_priority() then
--                 if ( false === current( this.iterations ) ) then
--                         return false;
--                 end;

--                 return current( current( this.iterations ) );
--         end;

--         --
--         -- Determines whether an offset value exists.
--         --
--         -- @since 4.7.0
--         --
--         -- @link https://www.php.net/manual/en/arrayaccess.offsetexists.php
--         --
--         -- @param mixed offset An offset to check for.
--         -- @return bool True if the offset exists, false otherwise.
--         --
--         #[ReturnTypeWillChange]
--         public function offsetExists( offset ) then
--                 return isset( this.callbacks[ offset ] );
--         end;

--         --
--         -- Retrieves a value at a specified offset.
--         --
--         -- @since 4.7.0
--         --
--         -- @link https://www.php.net/manual/en/arrayaccess.offsetget.php
--         --
--         -- @param mixed offset The offset to retrieve.
--         -- @return mixed If set, the value at the specified offset, null otherwise.
--         --
--         #[ReturnTypeWillChange]
--         public function offsetGet( offset ) then
--                 return isset( this.callbacks[ offset ] ) ? this.callbacks[ offset ] : null;
--         end;

--         --
--         -- Sets a value at a specified offset.
--         --
--         -- @since 4.7.0
--         --
--         -- @link https://www.php.net/manual/en/arrayaccess.offsetset.php
--         --
--         -- @param mixed offset The offset to assign the value to.
--         -- @param mixed value The value to set.
--         --
--         #[ReturnTypeWillChange]
--         public function offsetSet( offset, value ) then
--                 if ( is_null( offset ) ) then
--                         this.callbacks[] = value;
--                 end; else then
--                         this.callbacks[ offset ] = value;
--                 end;
--         end;

--         --
--         -- Unsets a specified offset.
--         --
--         -- @since 4.7.0
--         --
--         -- @link https://www.php.net/manual/en/arrayaccess.offsetunset.php
--         --
--         -- @param mixed offset The offset to unset.
--         --
--         #[ReturnTypeWillChange]
--         public function offsetUnset( offset ) then
--                 unset( this.callbacks[ offset ] );
--         end;

   -------------
   -- Current --
   -------------

   -- #[ReturnTypeWillChange]
   -- public function current() then
   function Current (This : Wp_Hook)
                     return String
   is
   begin
      return ""; -- Php.Current (This.Callbacks);
   end Current;

   ----------
   -- Next --
   ----------

   -- #[ReturnTypeWillChange]
   -- public function next() then
   function Next (This : in out Wp_Hook)
                  return String
   is
   begin
      return ""; -- Php.Next (This.Callbacks);
   end Next;

--         --
--         -- Returns the key of the current element.
--         --
--         -- @since 4.7.0
--         --
--         -- @link https://www.php.net/manual/en/iterator.key.php
--         --
--         -- @return mixed Returns current priority on success, or NULL on failure
--         --
--         #[ReturnTypeWillChange]
--         public function key() then
--                 return key( this.callbacks );
--         end;

--         --
--         -- Checks if current position is valid.
--         --
--         -- @since 4.7.0
--         --
--         -- @link https://www.php.net/manual/en/iterator.valid.php
--         --
--         -- @return bool Whether the current position is valid.
--         --
--         #[ReturnTypeWillChange]
--         public function valid() then
--                 return key( this.callbacks ) !== null;
--         end;

--         --
--         -- Rewinds the Iterator to the first element.
--         --
--         -- @since 4.7.0
--         --
--         -- @link https://www.php.net/manual/en/iterator.rewind.php
--         --
--         #[ReturnTypeWillChange]
--         public function rewind() then
--                 reset( this.callbacks );
--         end;

-- end;

end Inc_Class_Wp_Hooks;
