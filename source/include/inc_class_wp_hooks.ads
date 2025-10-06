--
-- Plugin API: WP_Hook class
--
-- @package WordPress
-- @subpackage Plugin
-- @since 4.7.0
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrays;

package Inc_Class_Wp_Hooks
is
   package Dd_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Arrays.Array_Type,
         "="          => Arrays."="); -- .Array_Maps."=");

   package Ee_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => Integer,
         Element_Type => Dd_Maps.Map,
         "="          => Dd_Maps."=");

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
         Callbacks : Ee_Maps.Map; -- Arrays.Array_Type;

         --
         -- The priority keys of actively running iterations of a hook.
         --
         -- @since 4.7.0
         -- @var array
         --
--        private iterations = array();

         --
         -- The current priority of actively running iterations of a hook.
         --
         -- @since 4.7.0
         -- @var array
         --
--        private current_priority = array();

         --
         -- Number of levels this hook can be recursively called.
         --
         -- @since 4.7.0
         -- @var int
         --
--        private
         Nesting_Level : Natural := 0;

         --
         -- Flag for if we"re currently doing an action, rather than a filter.
         --
         -- @since 4.7.0
         -- @var bool
         --
--        private
         Doing_Action : Boolean := False;

      end record;

   type Callable is access procedure;

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
                         Callback      : Callable;
                         Priority      : Integer;
                         Accepted_Args : Integer);

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
                                       New_Priority     : Integer := 0; -- false
                                       Priority_Existed : Boolean := False)
                                       is null;

end Inc_Class_Wp_Hooks;
