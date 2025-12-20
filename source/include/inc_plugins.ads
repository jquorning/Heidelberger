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

with Arrays;
with Lists;

with Inc_Class_Wp_Admin_Bar;
with Inc_Class_Wp_Errors;
with Inc_Class_Wp_Hooks;
with Inc_Class_Wp_Roles;
with Inc_Class_Wp_Styles;
with Inc_Class_Wp_Taxonomy;

package Inc_Plugins
is
   use Arrays;
   use Lists;
   use Inc_Class_Wp_Hooks;

   type Callable_2 is access function return Array_Type;
   type Callable_3 is access function (New_Status      : String;
                                       Post_Id         : Integer;
                                       Previous_Status : String)
                                       return String;
   type Callable_5 is access function (Arry : Array_Type)
                                       return Array_Type;

   --
   -- Checks if any action has been registered for a hook.
   --
   -- When using the `callback` argument, this function may return a non-boolean value
   -- that evaluates to false (e.g. 0), so use the `===` operator for testing the
   -- return value.
   --
   -- @since 2.5.0
   --
   -- @see has_filter() has_action() is an alias of has_filter().
   --
   -- @param string                      hook_name The name of the action hook.
   -- @param callable|string|array|false callback  Optional. The callback to check for.
   --                                               This function can be called
   --                                               unconditionally to speculatively
   --                                               check a callback that may or may
   --                                               not exist. Default false.
   -- @return bool|int If `callback` is omitted, returns boolean for whether the hook
   --                  has anything registered. When checking a specific function,
   --                  the priority of that hook is returned, or false if the function
   --                  is not attached.
   --
   function Has_Action (Hook_Name : String;
                        Callback  : Callable := null) -- false
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
                        Priority      : Priority_Type := 10;
                        Accepted_Args : Integer       := 1)
                        return Boolean;

   procedure Add_Filter (Hook_Name     : String;
                         Callback      : Callable;
                         Priority      : Priority_Type := 10;
                         Accepted_Args : Integer       := 1);

   procedure Add_Filter (Hook_Name     : String;
                         Callback      : Callable_2;
                         Priority      : Priority_Type := 10;
                         Accepted_Args : Integer       := 1);

   procedure Add_Filter (Hook_Name     : String;
                         Callback      : Callable_3;
                         Priority      : Priority_Type := 10;
                         Accepted_Args : Integer       := 1);

   procedure Add_Filter (Hook_Name     : String;
                         Callback      : Callable_5;
                         Priority      : Priority_Type := 10;
                         Accepted_Args : Integer       := 1);

   --
   -- Calls the callback functions that have been added to a filter hook.
   --
   -- This function invokes all functions attached to filter hook `hook_name`.
   -- It is possible to create new filter hooks by simply calling this function,
   -- specifying the name of the new hook using the `hook_name` parameter.
   --
   -- The function also allows for multiple additional arguments to be passed to hooks.
   --
   -- Example usage:
   --
   --     -- The filter callback function.
   --     function example_callback( string, arg1, arg2 ) then
   --         -- (maybe) modify string.
   --         return string;
   --     end;
   --     add_filter( 'example_filter', 'example_callback', 10, 3 );
   --
   --     --
   --     -- Apply the filters by calling the 'example_callback()' function
   --     -- that's hooked onto `example_filter` above.
   --     --
   --     -- - 'example_filter' is the filter hook.
   --     -- - 'filter me' is the value being filtered.
   --     -- - arg1 and arg2 are the additional arguments passed to the callback.
   --     value = apply_filters( 'example_filter', 'filter me', arg1, arg2 );
   --
   -- @since 0.71
   -- @since 6.0.0 Formalized the existing and already documented `...args` parameter
   --              by adding it to the function signature.
   --
   -- @global WP_Hook[] wp_filter         Stores all of the filters and actions.
   -- @global int[]     wp_filters        Stores the number of times each filter was
   --                                     triggered.
   -- @global string[]  wp_current_filter Stores the list of current filters with
   --                                     the current one last.
   --
   -- @param string hook_name The name of the filter hook.
   -- @param mixed  value     The value to filter.
   -- @param mixed  ...args   Additional parameters to pass to the callback functions.
   -- @return mixed The filtered value after all hooked functions are applied to it.
   --
   -- function apply_filters( hook_name, value, ...args ) then

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Args      : Array_Type)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String := "";
                           X         : String := "")
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Arg_3     : Array_Type;
                           Arg_4     : Array_Type := Empty_Array)
                           return Array_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : String := "")
                           return Array_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           List      : List_Type)
                           return Array_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : String;
                           I         : Integer)
                           return Array_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : Array_Type)
                           return Array_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Right     : Integer := 0)
                           return Array_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : List_Type;
                           Right     : Integer := 0)
                           return List_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           Arg_2     : Positive;
                           Arg_3     : String;
                           Arg_4     : Boolean;
                           Arg_5     : String)
                           return Integer
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String := "";
                           P         : Array_Type)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String;
                           P         : List_Type)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean)
                           return Boolean
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           B         : String;
                           D         : String)
                           return Boolean
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           S         : String;
                           B         : Boolean)
                           return Boolean
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           B         : Integer := 0)
                           return Integer
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           B         : Integer;
                           S         : Boolean;
                           E         : Boolean)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           C         : String)
                           return Boolean
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Integer)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Raw       : String;
                           Strict    : Boolean)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Path      : String;
                           Scheme    : String;
                           Blog      : Integer)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Integer;
                           Context   : String;
                           Allow     : Boolean)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           V         : Array_Type;
                           Trans     : String)
                           return Integer
                           is (Value);

   --
   -- Checks if any filter has been registered for a hook.
   --
   -- When using the `callback` argument, this function may return a non-boolean value
   -- that evaluates to false (e.g. 0), so use the `===` operator for testing the
   -- return value.
   --
   -- @since 2.5.0
   --
   -- @global WP_Hook[] wp_filter Stores all of the filters and actions.
   --
   -- @param string                      hook_name The name of the filter hook.
   -- @param callable|string|array|false callback  Optional. The callback to check for.
   --                                               This function can be called
   --                                               unconditionally to speculatively
   --                                               check a callback that may or may
   --                                               not exist. Default false.
   -- @return bool|int If `callback` is omitted, returns boolean for whether the hook
   --                  has anything registered. When checking a specific function, the
   --                  priority of that hook is returned, or false if the function is
   --                  not attached.
   --
   function Has_Filter (Hook_Name : String;
                        Callback  : Boolean := False)
                        return Boolean;

   --
   -- Returns whether or not a filter hook is currently being processed.
   --
   -- The function current_filter() only returns the most recent filter being executed.
   -- did_filter() returns the number of times a filter has been applied during
   -- the current request.
   --
   -- This function allows detection for any filter currently being executed
   -- (regardless of whether it's the most recent filter to fire, in the case of
   -- hooks called from hook callbacks) to be verified.
   --
   -- @since 3.9.0
   --
   -- @see current_filter()
   -- @see did_filter()
   -- @global string[] wp_current_filter Current filter.
   --
   -- @param string|null hook_name Optional. Filter hook to check. Defaults to null,
   --                               which checks if any filter is currently being run.
   -- @return bool Whether the filter is currently in the stack.
   --
   function Doing_Filter (Hook_Name : String := "") -- null
                          return Boolean;

   --
   -- Removes a callback function from a filter hook.
   --
   -- This can be used to remove default functions attached to a specific filter
   -- hook and possibly replace them with a substitute.
   --
   -- To remove a hook, the `callback` and `priority` arguments must match
   -- when the hook was added. This goes for both filters and actions. No warning
   -- will be given on removal failure.
   --
   -- @since 1.2.0
   --
   -- @global WP_Hook[] wp_filter Stores all of the filters and actions.
   --
   -- @param string                hook_name The filter hook to which the function
   --                                        to be removed is hooked.
   -- @param callable|string|array callback  The callback to be removed from running
   --                                        when the filter is applied. This
   --                                        function can be called unconditionally
   --                                        to speculatively remove a callback that
   --                                        may or may not exist.
   -- @param int                   priority  Optional. The exact priority used when
   --                                        adding the original filter callback.
   --                                        Default 10.
   -- @return bool Whether the function existed before it was removed.
   --
   -- function remove_filter( hook_name, callback, priority = 10 ) then
   procedure Remove_Filter (Hook_Name : String;
                            Callback  : String;
                            Priority  : Integer := 10)
                            is null;
   procedure Remove_Filter (Hook_Name : String;
                            Callback  : Callable;
                            Priority  : Integer := 10)
                            is null;
   function Remove_Filter (Hook_Name : String;
                           Callback  : Callable;
                           Priority  : Integer := 10)
                           return Boolean
                           is (False);

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
                        Arg_2     : String := "";
                        Arg_3     : String := "");
   --                  , ...arg )

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String;
                        Arg_3     : Boolean)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String;
                        Arg_3     : Integer)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Net       : Natural)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type;
                        Option    : String)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Natural;
                        Option    : String)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type;
                        Net       : Natural)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Args      : Array_Type)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Tax       : String;
                        Arg_3     : List_Type;
                        Tax_2     : Inc_Class_Wp_Taxonomy.Wp_Taxonomy)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Role      : Inc_Class_Wp_Roles.Wp_Roles)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Code      : String;
                        Message   : String;
                        Data      : String;
                        Error     : Inc_Class_Wp_Errors.Wp_Error)
                        is null;

   procedure Do_Action (Hook_Name  : String;
                        Value      : Array_Type;
                        Expiration : Integer;
                        Transient  : String)
                        is null;

   procedure Do_Action (Hook_Name  : String;
                        Transient  : String;
                        Value      : Array_Type;
                        Expiration : Integer)
                        is null;

   --
   -- Removes a callback function from an action hook.
   --
   -- This can be used to remove default functions attached to a specific action
   -- hook and possibly replace them with a substitute.
   --
   -- To remove a hook, the `callback` and `priority` arguments must match
   -- when the hook was added. This goes for both filters and actions. No warning
   -- will be given on removal failure.
   --
   -- @since 1.2.0
   --
   -- @param string                hook_name The action hook to which the function to
   --                                         be removed is hooked.
   -- @param callable|string|array callback  The name of the function which should be
   --                                         removed. This function can be called
   --                                         unconditionally to speculatively remove
   --                                         a callback that may or may not exist.
   -- @param int                   priority  Optional. The exact priority used when
   --                                         adding the original action callback.
   --                                         Default 10.
   -- @return bool Whether the function is removed.
   --
   function Remove_Action (Hook_Name : String;
                           Callback  : Callable;
                           Priority  : Integer := 10)
                           return Boolean;

   procedure Remove_Action (Hook_Name : String;
                            Callback  : Callable;
                            Priority  : Integer := 10);

   --
   -- Returns whether or not an action hook is currently being processed.
   --
   -- The function current_action() only returns the most recent action being executed.
   -- did_action() returns the number of times an action has been fired during
   -- the current request.
   --
   -- This function allows detection for any action currently being executed
   -- (regardless of whether it's the most recent action to fire, in the case of
   -- hooks called from hook callbacks) to be verified.
   --
   -- @since 3.9.0
   --
   -- @see current_action()
   -- @see did_action()
   --
   -- @param string|null hook_name Optional. Action hook to check. Defaults to null,
   --                               which checks if any action is currently being run.
   -- @return bool Whether the action is currently in the stack.
   --
   function Doing_Action (Hook_Name : String := "") -- null
                          return Boolean;

   --
   -- @since 2.1.0
   --
   -- @global int[] wp_actions Stores the number of times each action was triggered.
   --
   -- @param string hook_name The name of the action hook.
   -- @return int The number of times the action hook has been fired.
   --
   function Did_Action (Hook_Name : String)
            return Boolean
            is (True);

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
                                   Args        : List_Type;
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
   -- @param int      priority        Optional. Used to specify the order in which the
   --                                 functions associated with a particular action
   --                                 are executed. Lower numbers correspond with
   --                                 earlier execution, and functions with the same
   --                                 priority are executed in the order in which they
   --                                 were added to the action. Default 10.
   -- @param int      accepted_args   Optional. The number of arguments the function
   --                                 accepts. Default 1.
   -- @return true Always returns true.
   --
   type Callable_4 is access procedure;

   procedure Add_Action (Hook_Name     : String;
                         Callback      : Callable; -- _4;
                         Priority      : Priority_Type := 10;
                         Accepted_Args : Integer       := 1);

   -- procedure Add_Action (Hook_Name     : String;
   --                       Callback      : String;
   --                       Priority      : Priority_Type := 10;
   --                       Accepted_Args : Integer       := 1);

   --
   -- Calls the 'all' hook, which will process the functions hooked into it.
   --
   -- The 'all' hook passes all of the arguments or parameters that were used for
   -- the hook, which this function was called for.
   --
   -- This function is used internally for apply_filters(), do_action(), and
   -- do_action_ref_array() and is not meant to be used from outside those
   -- functions. This function does not check for the existence of the all hook, so
   -- it will fail unless the all hook exists prior to this function call.
   --
   -- @since 2.5.0
   -- @access private
   --
   -- @global WP_Hook[] wp_filter Stores all of the filters and actions.
   --
   -- @param array args The collected parameters from the hook that was called.
   --
   procedure X_Wp_Call_All_Hook (Args : Array_Type);

end Inc_Plugins;
