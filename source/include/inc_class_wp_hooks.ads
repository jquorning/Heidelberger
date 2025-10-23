--
-- Plugin API: WP_Hook class
--
-- @package WordPress
-- @subpackage Plugin
-- @since 4.7.0
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

with Arrays;
with Php;

package Inc_Class_Wp_Hooks
is
   use Ada.Strings.Unbounded;
   use Arrays;

   type Nesting_Type  is new Natural;
   type Priority_Type is new Natural;

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

   function Array_Keys (Map : Priority_Maps.Map)
                        return List_Type;

   package List_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Nesting_Type,
                              Element_Type => List_Type,
                              "="          => List_Vectors."=");

   package Priority_Vectors is new
      Ada.Containers.Vectors (Index_Type   => Nesting_Type,
                              Element_Type => Priority_Type);

   --
   -- Core class used to implement action and filter hook functionality.
   --
   -- @since 4.7.0
   --
   -- @see Iterator
   -- @see ArrayAccess
   --
   --#[AllowDynamicProperties]
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
         Iterations : List_Vectors.Vector; -- Array_Type;

         --
         -- The current priority of actively running iterations of a hook.
         --
         -- @since 4.7.0
         -- @var array
         --
         -- private
         Current_Priority : Priority_Vectors.Vector; -- Array_Type;

         --
         -- Number of levels this hook can be recursively called.
         --
         -- @since 4.7.0
         -- @var int
         --
         -- private
         Nesting_Level : Nesting_Type := 0; -- Natural := 0;

         --
         -- Flag for if we"re currently doing an action, rather than a filter.
         --
         -- @since 4.7.0
         -- @var bool
         --
         -- private
         Doing_Action : Boolean := False;

      end record;

-- type Callable is access procedure;

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
   -- Calls the callback functions that have been added to a filter hook.
   --
   -- @since 4.7.0
   --
   -- @param mixed value The value to filter.
   -- @param array args  Additional parameters to pass to the callback functions.
   --                     This array is expected to include value at index 0.
   -- @return mixed The filtered value after all hooked functions are applied to it.
   --

   -- type Args_Type is
   --    record
   --       Text_1    : Unbounded_String;
   --       Text_2    : Unbounded_String;
   --       Array_1   : Array_Type;
   --       Array_2   : Array_Type;
   --       Integer_1 : Integer;
   --       Integer_2 : Integer;
   --       Bool      : Boolean;
   --       List      : List_Type;
   --    end record;

   function Apply_Filters (This  : in out Wp_Hook;
                           Value : String;
                           Args  : Array_Type) -- Args_Type) -- Array_Type)
                           return String;

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
   function Current (This : Wp_Hook)
                     return String;

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
   function Next (This : in out Wp_Hook)
                  return String;

end Inc_Class_Wp_Hooks;
