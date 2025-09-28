--
-- The plugin API is located in this file, which allows for creating actions
-- and filters and hooking functions, and methods. The functions or methods will
-- then be run when the action or filter is called.
--
-- The API callback examples reference functions, but can be methods of classes.
-- To hook methods, you'll need to pass an array one of two ways.
--
-- Any of the syntaxes explained in the PHP documentation for the
-- {@link https://www.php.net/manual/en/language.pseudo-types.php#language.types.callback 'callback'} type are valid.
--
-- Also see the {@link https://developer.wordpress.org/plugins/ Plugin API} for
-- more information and examples on how to use a lot of these functions.
--
-- This file should have no external dependencies.
--
-- @package WordPress
-- @subpackage Plugin
-- @since 1.5.0
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrays;

with Inc_Class_Wp_Admin_Bar;
with Inc_Class_Wp_Hooks;
with Inc_Class_Wp_Styles;

package Inc_Plugins
is
   use Arrays;

   subtype Callable is Inc_Class_Wp_Hooks.Callable;
   type Callable_2 is access function return Array_Type;
   type Callable_3 is access function (New_Status      : String;
                                       Post_Id         : Integer;
                                       Previous_Status : String)
                                       return String;

   package Hook_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Inc_Class_Wp_Hooks.Wp_Hook,
         "="          => Inc_Class_Wp_Hooks."=");

   Wp_Filter : Hook_Maps.Map;
--
-- Checks if any action has been registered for a hook.
--
-- When using the `callback` argument, this function may return a non-boolean value
-- that evaluates to false (e.g. 0), so use the `===` operator for testing the return value.
--
-- @since 2.5.0
--
-- @see has_filter() has_action() is an alias of has_filter().
--
-- @param string                      hook_name The name of the action hook.
-- @param callable|string|array|false callback  Optional. The callback to check for.
--                                               This function can be called unconditionally to speculatively check
--                                               a callback that may or may not exist. Default false.
-- @return bool|int If `callback` is omitted, returns boolean for whether the hook has
--                  anything registered. When checking a specific function, the priority
--                  of that hook is returned, or false if the function is not attached.
--
   function Has_Action (Hook_Name : String)
                        --, callback = false )
                        return Boolean
                        is (True);

--
-- Calls the callback functions that have been added to an action hook, specifying arguments in an array.
--
-- @since 2.1.0
--
-- @see do_action() This function is identical, but the arguments passed to the
--                  functions hooked to `hook_name` are supplied using an array.
--
-- @global WP_Hook[] wp_filter         Stores all of the filters and actions.
-- @global int[]     wp_actions        Stores the number of times each action was triggered.
-- @global string[]  wp_current_filter Stores the list of current filters with the current one last.
--
-- @param string hook_name The name of the action to be executed.
-- @param array  args      The arguments supplied to the functions hooked to `hook_name`.
--
   procedure Do_Action_Ref_Array (Hook_Name : String;
                                  Args      : Array_Type) is null;
   procedure Do_Action_Ref_Array (Hook_Name : String;
                                  Args      : Inc_Class_Wp_Styles.Wp_Styles)
                                  is null;
   procedure Do_Action_Ref_Array (Hook_Name : String;
                                  Args      : Inc_Class_Wp_Admin_Bar.Wp_Admin_Bar)
                                  is null;

--
-- Gets the basename of a plugin.
--
-- This method extracts the name of a plugin from its filename.
--
-- @since 1.5.0
--
-- @global array wp_plugin_paths
--
-- @param string file The filename of plugin.
-- @return string The name of a plugin.
--
   function Plugin_Basename (File : String)
                             return String
                             is ("XXX-461");

   --
   -- Adds a callback function to a filter hook.
   --
   -- WordPress offers filter hooks to allow plugins to modify
   -- various types of internal data at runtime.
   --
   -- A plugin can modify data by binding a callback to a filter hook. When the filter
   -- is later applied, each bound callback is run in order of priority, and given
   -- the opportunity to modify a value by returning a new value.
   --
   -- The following example shows how a callback function is bound to a filter hook.
   --
   -- Note that `example` is passed to the callback, (maybe) modified, then returned:
   --
   --     function example_callback( example ) then
   --         -- Maybe modify example in some way.
   --         return example;
   --     end;
   --     add_filter( 'example_filter', 'example_callback' );
   --
   -- Bound callbacks can accept from none to the total number of arguments passed as
   -- parameters in the corresponding apply_filters() call.
   --
   -- In other words, if an apply_filters() call passes four total arguments,
   -- callbacks bound to it can accept none (the same as 1) of the arguments or up
   -- to four. The important part is that the `accepted_args` value must reflect the
   -- number of arguments the bound callback--actually* opted to accept. If no
   -- arguments were accepted by the callback that is considered to be thesame as
   -- accepting 1 argument. For example:
   --
   --     -- Filter call.
   --     value = apply_filters( 'hook', value, arg2, arg3 );
   --
   --     -- Accepting zero/one arguments.
   --     function example_callback() then
   --         ...
   --         return 'some value';
   --     end;
   --     add_filter( 'hook', 'example_callback' );
   --     -- Where priority is default 10, accepted_args is default 1.
   --
   --     -- Accepting two arguments (three possible).
   --     function example_callback( value, arg2 ) then
   --         ...
   --         return maybe_modified_value;
   --     end;
   --     add_filter( 'hook', 'example_callback', 10, 2 );
   --     -- Where priority is 10, accepted_args is 2.
   --
   ----Note:* The function will return true whether or not the callback is valid.
   -- It is up to you to take care. This is done for optimization purposes, so
   -- everything is as quick as possible.
   --
   -- @since 0.71
   --
   -- @global WP_Hook[] wp_filter A multidimensional array of all hooks and the
   --                             callbacks hooked to them.
   --
   -- @param string   hook_name     The name of the filter to add the callback to.
   -- @param callable callback      The callback to be run when the filter is applied.
   -- @param int      priority      Optional. Used to specify the order in which the
   --                               functions associated with a particular filter are
   --                               executed.
   --                               Lower numbers correspond with earlier execution,
   --                               and functions with the same priority are executed
   --                               in the order in which they were added to the
   --                               filter. Default 10.
   -- @param int      accepted_args Optional. The number of arguments the function
   --                               accepts. Default 1.
   -- @return true Always returns true.
   --
   function Add_Filter (Hook_Name     : String;
                        Callback      : Callable;
                        Priority      : Integer := 10;
                        Accepted_Args : Integer := 1)
                        return Boolean;

   procedure Add_Filter (Hook_Name     : String;
                         Callback      : Callable_2;
                         Priority      : Integer := 10;
                         Accepted_Args : Integer := 1)
                         is null;

   procedure Add_Filter (Hook_Name     : String;
                         Callback      : Callable_3;
                         Priority      : Integer := 10;
                         Accepted_Args : Integer := 1)
                         is null;

   --
   -- Adds a callback function to an action hook.
   --
   -- Actions are the hooks that the WordPress core launches at specific points
   -- during execution, or when specific events occur. Plugins can specify that
   -- one or more of its PHP functions are executed at these points, using the
   -- Action API.
   --
   -- @since 1.2.0
   --
   -- @param string   hook_name       The name of the action to add the callback to.
   -- @param callable callback        The callback to be run when the action is called.
   -- @param int      priority        Optional. Used to specify the order in which
   --                                 the functions associated with a particular
   --                                 action are executed. Lower numbers correspond
   --                                 with earlier execution, and functions with the
   --                                 same priority are executed in the order in
   --                                 which they were added to the action. Default 10.
   -- @param int      accepted_args   Optional. The number of arguments the function
   --                                 accepts. Default 1.
   -- @return true Always returns true.
   --
   function Add_Action (Hook_Name     : String;
                        Callback      : Callable;
                        Priority      : Integer := 10;
                        Accepted_Args : Integer := 1)
                        return Boolean;

   --
   -- Calls the callback functions that have been added to an action hook.
   --
   -- This function invokes all functions attached to action hook `hook_name`.
   -- It is possible to create new action hooks by simply calling this function,
   -- specifying the name of the new hook using the `hook_name` parameter.
   --
   -- You can pass extra arguments to the hooks, much like you can with
   -- `apply_filters()`.
   --
   -- Example usage:
   --
   --     -- The action callback function.
   --     function example_callback( arg1, arg2 ) {
   --         -- (maybe) do something with the args.
   --     }
   --     add_action( 'example_action', 'example_callback', 10, 2 );
   --
   --     --
   --     -- Trigger the actions by calling the 'example_callback()' function
   --     -- that's hooked onto `example_action` above.
   --     --
   --     -- - 'example_action' is the action hook.
   --     -- - arg1 and arg2 are the additional arguments passed to the callback.
   --     do_action( 'example_action', arg1, arg2 );
   --
   -- @since 1.2.0
   -- @since 5.3.0 Formalized the existing and already documented `...arg` parameter
   --              by adding it to the function signature.
   --
   -- @global WP_Hook[] wp_filter         Stores all of the filters and actions.
   -- @global int[]     wp_actions        Stores the number of times each action was
   --                                     triggered.
   -- @global string[]  wp_current_filter Stores the list of current filters with the
   --                                     current one last.
   --
   -- @param string hook_name The name of the action to be executed.
   -- @param mixed  ...arg    Optional. Additional arguments which are passed on to the
   --                         functions hooked to the action. Default empty.
   --
   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String := "");
   --                  , ...arg )

--
-- Fires functions attached to a deprecated action hook.
--
-- When an action hook is deprecated, the do_action() call is replaced with
-- do_action_deprecated(), which triggers a deprecation notice and then fires
-- the original hook.
--
-- @since 4.6.0
--
-- @see _deprecated_hook()
--
-- @param string hook_name   The name of the action hook.
-- @param array  args        Array of additional function arguments to be passed to do_action().
-- @param string version     The version of WordPress that deprecated the hook.
-- @param string replacement Optional. The hook that should have been used. Default empty.
-- @param string message     Optional. A message regarding the change. Default empty.
--
   procedure Do_Action_Deprecated (Hook_Name   : String;
                                   Args        : Array_Type;
                                   Version     : String;
                                   Replacement : String := "";
                                   Message     : String := "")
                                   is null;

--
-- Adds a callback function to an action hook.
--
-- Actions are the hooks that the WordPress core launches at specific points
-- during execution, or when specific events occur. Plugins can specify that
-- one or more of its PHP functions are executed at these points, using the
-- Action API.
--
-- @since 1.2.0
--
-- @param string   hook_name       The name of the action to add the callback to.
-- @param callable callback        The callback to be run when the action is called.
-- @param int      priority        Optional. Used to specify the order in which the functions
--                                  associated with a particular action are executed.
--                                  Lower numbers correspond with earlier execution,
--                                  and functions with the same priority are executed
--                                  in the order in which they were added to the action. Default 10.
-- @param int      accepted_args   Optional. The number of arguments the function accepts. Default 1.
-- @return true Always returns true.
--
--   type Callable is null record;

   procedure Add_Action (Hook_Name     : String;
                         Callback      : String; -- Callable;
                         Priority      : Integer := 10;
                         Accepted_Args : Integer := 1)
                         is null;

   procedure Dummy;

   --
   -- Builds Unique ID for storage and retrieval.
   --
   -- The old way to serialize the callback caused issues and this function is the
   -- solution. It works by checking for objects and creating a new property in
   -- the class to keep track of the object and new objects of the same class that
   -- need to be added.
   --
   -- It also allows for the removal of actions and filters for objects after they
   -- change class properties. It is possible to include the property wp_filter_id
   -- in your class and set it to "null" or a number to bypass the workaround.
   -- However this will prevent you from adding new classes and any new classes
   -- will overwrite the previous hook by the same class.
   --
   -- Functions and static method callbacks are just returned as strings and
   -- shouldn't have any speed penalty.
   --
   -- @link https://core.trac.wordpress.org/ticket/3875
   --
   -- @since 2.2.3
   -- @since 5.3.0 Removed workarounds for spl_object_hash().
   --              `hook_name` and `priority` are no longer used,
   --              and the function always returns a string.
   --
   -- @access private
   --
   -- @param string                hook_name Unused. The name of the filter to build
   --                                        ID for.
   -- @param callable|string|array callback  The callback to generate ID for. The
   --                                        callback may or may not exist.
   -- @param int                   priority  Unused. The order in which the functions
   --                                        associated with a particular action are
   --                                        executed.
   -- @return string Unique function ID for usage as array key.
   --
   function X_Wp_Filter_Build_Unique_Id (Hook_Name : String;
                                         Callback  : Callable;
                                         Priority  : Integer)
                                         return String;

end Inc_Plugins;
