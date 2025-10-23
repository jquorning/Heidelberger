--
-- Plugin API: WP_Hook class
--
-- @package WordPress
-- @subpackage Plugin
-- @since 4.7.0
--

with Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;

with Hb_Common;

with Inc_Plugins;

package body Inc_Class_Wp_Hooks
is

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
      use Inc_Plugins;
      use Hb_Common;
      use Php;

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

--         --
--         -- Checks if a specific callback has been registered for this hook.
--         --
--         -- When using the `callback` argument, this function may return a non-boolean value
--         -- that evaluates to false (e.g. 0), so use the `===` operator for testing the return value.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string                      hook_name Optional. The name of the filter hook. Default empty.
--         -- @param callable|string|array|false callback  Optional. The callback to check for.
--         --                                               This method can be called unconditionally to speculatively check
--         --                                               a callback that may or may not exist. Default false.
--         -- @return bool|int If `callback` is omitted, returns boolean for whether the hook has
--         --                  anything registered. When checking a specific function, the priority
--         --                  of that hook is returned, or false if the function is not attached.
--         --
--         public function has_filter( hook_name = "", callback = false ) then
--                 if ( false === callback ) then
--                         return this.has_filters();
--                 end;

--                 function_key = _wp_filter_build_unique_id( hook_name, callback, false );

--                 if ( ! function_key ) then
--                         return false;
--                 end;

--                 foreach ( this.callbacks as priority => callbacks ) then
--                         if ( isset( callbacks[ function_key ] ) ) then
--                                 return priority;
--                         end;
--                 end;

--                 return false;
--         end;

--         --
--         -- Checks if any callbacks have been registered for this hook.
--         --
--         -- @since 4.7.0
--         --
--         -- @return bool True if callbacks have been registered for the current hook, otherwise false.
--         --
--         public function has_filters() then
--                 foreach ( this.callbacks as callbacks ) then
--                         if ( callbacks ) then
--                                 return true;
--                         end;
--                 end;

--                 return false;
--         end;

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
      Nesting_Level : Nesting_Type; -- Natural;
      Num_Args      : Natural;
      Value_2       : Unbounded_String := +Value;
   begin
Put_Line ("#Apply_Filters method");
--       if not This.Callbacks then
-- --    if not This.Callbacks then
--          return Value;
--       end if;

      Nesting_Level := This.Nesting_Level;

      This.Nesting_Level :=
        This.Nesting_Level + 1;

      This.Iterations (Nesting_Level) := Array_Keys (This.Callbacks);
      Num_Args                        := Arrays.Count (Args);

      loop
--       This.Current_Priority (Nesting_Level) :=
--         Current (This.Iterations (Nesting_Level));

         declare
            Priority : constant Priority_Type :=
              This.Current_Priority (Nesting_Level);
         begin

            for The_X of This.Callbacks (Priority) loop
               -- if not This.Doing_Action then
               --    Args_2 (Args_2.First_Index) := Value_2;
               -- end if;

               declare
                  Accepted_Args : constant Natural  :=
                    Get_Integer (The_X, "accepted_args");

                  User_Function : constant Callable :=
                    Get_Func (The_X, "function");
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
         exit when True; -- not Next (This.Iterations (Nesting_Level));
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
Put_Line ("#Do_Action method");
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
Put_Line ("#Do_All_Hook method");
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
                  Func   : constant Callable := Get_Func (The_X, "function");
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
--         -- Normalizes filters set up before WordPress has initialized to WP_Hook objects.
--         --
--         -- The `filters` parameter should be an array keyed by hook name, with values
--         -- containing either:
--         --
--         --  - A `WP_Hook` instance
--         --  - An array of callbacks keyed by their priorities
--         --
--         -- Examples:
--         --
--         --     filters = array(
--         --         "wp_fatal_error_handler_enabled" => array(
--         --             10 => array(
--         --                 array(
--         --                     "accepted_args" => 0,
--         --                     "function"      => function() then
--         --                         return false;
--         --                     end;,
--         --                 ),
--         --             ),
--         --         ),
--         --     );
--         --
--         -- @since 4.7.0
--         --
--         -- @param array filters Filters to normalize. See documentation above for details.
--         -- @return WP_Hook[] Array of normalized filters.
--         --
--         public static function build_preinitialized_hooks( filters ) then
--                 -- @var WP_Hook[] normalized
--                 normalized = array();

--                 foreach ( filters as hook_name => callback_groups ) then
--                         if ( is_object( callback_groups ) && callback_groups instanceof WP_Hook ) then
--                                 normalized[ hook_name ] = callback_groups;
--                                 continue;
--                         end;

--                         hook = new WP_Hook();

--                         -- Loop through callback groups.
--                         foreach ( callback_groups as priority => callbacks ) then

--                                 -- Loop through callbacks.
--                                 foreach ( callbacks as cb ) then
--                                         hook.add_filter( hook_name, cb["function"], priority, cb["accepted_args"] );
--                                 end;
--                         end;

--                         normalized[ hook_name ] = hook;
--                 end;

--                 return normalized;
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
