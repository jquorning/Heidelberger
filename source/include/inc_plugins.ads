package Inc_Plugins
is

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

end Inc_Plugins;
