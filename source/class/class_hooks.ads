--
-- Plugin API: WP_Hook class
--
-- @package WordPress
-- @subpackage Plugin
-- @since 4.7.0
--

private with Ada.Containers.Indefinite_Ordered_Maps;
private with Ada.Containers.Ordered_Maps;
private with Ada.Containers.Vectors;

with Arrays;

package Class_Hooks
is
   use Arrays;

   type Priority_Type is new Natural;

   --
   -- Core class used to implement action and filter hook functionality.
   --
   -- @since 4.7.0
   --
   -- @see Iterator
   -- @see ArrayAccess
   --
   --#[AllowDynamicProperties]
   type Wp_Hook is tagged private;

   --
   -- Adds a callback function to a filter hook.
   --
   -- @since 4.7.0
   --
   -- @param string   hook_name     The name of the filter to add the callback to.
   -- @param callable callback      The callback to be run when the filter is applied.
   -- @param int      priority      The order in which the functions associated with
   --                               a particular filter are executed. Lower numbers
   --                               correspond with earlier execution, and functions
   --                               with the same priority are executed in the order
   --                               in which they were added to the filter.
   -- @param int      accepted_args The number of arguments the function accepts.
   --
   procedure Add_Filter (This          : in out Wp_Hook;
                         Hook_Name     : String;
                         Callback      : Arrays.Callable;
                         Priority      : Priority_Type; -- Integer;
                         Accepted_Args : Integer);

   --
   -- Checks if a specific callback has been registered for this hook.
   --
   -- When using the `callback` argument, this function may return a non-boolean value
   -- that evaluates to false (e.g. 0), so use the `===` operator for testing the
   -- return value.
   --
   -- @since 4.7.0
   --
   -- @param string                      hook_name Optional. The name of the filter
   --                                               hook. Default empty.
   -- @param callable|string|array|false callback  Optional. The callback to check for.
   --                                               This method can be called
   --                                               unconditionally to speculatively
   --                                               check a callback that may or may
   --                                               not exist. Default false.
   -- @return bool|int If `callback` is omitted, returns boolean for whether the hook
   --                   has anything registered. When checking a specific function, the
   --                   priority of that hook is returned, or false if the function is
   --                   not attached.
   --
   function Has_Filter (This      : Wp_Hook;
                        Hook_Name : String := "";
                        Callback  : Callable := null)
                        return Boolean;

   --
   -- Checks if any callbacks have been registered for this hook.
   --
   -- @since 4.7.0
   --
   -- @return bool True if callbacks have been registered for the current hook,
   --               otherwise false.
   --
   function Has_Filters (This : Wp_Hook)
                         return Boolean;

   --
   -- Calls the callback functions that have been added to a filter hook.
   --
   -- @since 4.7.0
   --
   -- @param mixed value The value to filter.
   -- @param array args  Additional parameters to pass to the callback functions.
   --                     This array is expected to include value at index 0.
   -- @return mixed The filtered value after all hooked functions are applied to it.
   --

   function Apply_Filters (This  : in out Wp_Hook;
                           Value : Array_Type;
                           Args  : Array_Type)
                           return Array_Type;

   procedure Apply_Filters (This  : in out Wp_Hook;
                            Value : Array_Type;
                            Args  : Array_Type);

   --
   -- Calls the callback functions that have been added to an action hook.
   --
   -- @since 4.7.0
   --
   -- @param array args Parameters to pass to the callback functions.
   --
   procedure Do_Action (This : in out Wp_Hook;
                        Args : Array_Type);

   --
   -- Processes the functions hooked into the "all" hook.
   --
   -- @since 4.7.0
   --
   -- @param array args Arguments to pass to the hook callbacks. Passed by reference.
   --
   procedure Do_All_Hook (This : in out Wp_Hook;
                          Args : Array_Type);

   --
   -- Handles resetting callback priority keys mid-iteration.
   --
   -- @since 4.7.0
   --
   -- @param false|int new_priority     Optional. The priority of the new filter being
   --                                   added. Default false, for no priority being
   --                                   added.
   -- @param bool      priority_existed Optional. Flag for whether the priority
   --                                   already existed before the new filter was
   --                                   added. Default false.
   --
   -- private
   procedure Resort_Active_Iterations (This             : Wp_Hook;
                                       New_Priority     : Priority_Type := 0; -- false
                                       Priority_Existed : Boolean := False)
                                       is null;

   --
   -- Returns the current element.
   --
   -- @since 4.7.0
   --
   -- @link https://www.php.net/manual/en/iterator.current.php
   --
   -- @return array Of callbacks at current priority.
   --
   -- #[ReturnTypeWillChange]
--   function Current (This : Wp_Hook)
--                     return String;

   --
   -- Moves forward to the next element.
   --
   -- @since 4.7.0
   --
   -- @link https://www.php.net/manual/en/iterator.next.php
   --
   -- @return array Of callbacks at next priority.
   --
   -- #[ReturnTypeWillChange]
--   function Next (This : in out Wp_Hook)
--                  return String;

private

   type Nesting_Type  is new Natural;

   package Index_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Arrays.Array_Type,
         "="          => Arrays."=");

   package Priority_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => Priority_Type,
         Element_Type => Index_Maps.Map,
         "="          => Index_Maps."=");

   package Priority_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Positive,
                              Element_Type => Priority_Type);

   subtype Priority_List is Priority_Vectors.Vector;

   package Nesting_Maps is new
      Ada.Containers.Ordered_Maps
        (Key_Type     => Nesting_Type,
         Element_Type => Priority_List,
         "="          => Priority_Vectors."=");

   subtype Nesting_Map is Nesting_Maps.Map;

   package Priority_Nesting_Maps is new
      Ada.Containers.Ordered_Maps (Key_Type     => Nesting_Type,
                                   Element_Type => Priority_Type);

   subtype Priority_Nesting_Map is Priority_Nesting_Maps.Map;

   -------------
   -- Wp_Hook --
   -------------

   type Wp_Hook is tagged -- implements Iterator, ArrayAccess
      record
         --
         -- Hook callbacks.
         --
         -- @since 4.7.0
         -- @var array
         --
         Callbacks : Priority_Maps.Map;

         --
         -- The priority keys of actively running iterations of a hook.
         --
         -- @since 4.7.0
         -- @var array
         --
         -- private
         Iterations : Nesting_Map; -- List;

         --
         -- The current priority of actively running iterations of a hook.
         --
         -- @since 4.7.0
         -- @var array
         --
         -- private
         Current_Priority : Priority_Nesting_Map;

         --
         -- Number of levels this hook can be recursively called.
         --
         -- @since 4.7.0
         -- @var int
         --
         -- private
         Nesting_Level : Nesting_Type := 0;

         --
         -- Flag for if we"re currently doing an action, rather than a filter.
         --
         -- @since 4.7.0
         -- @var bool
         --
         -- private
         Doing_Action : Boolean := False;

      end record;

end Class_Hooks;
