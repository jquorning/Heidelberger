
--
-- The plugin API is located in this file, which allows for creating actions
-- and filters and hooking functions, and methods. The functions or methods will
-- then be run when the action or filter is called.
--
-- The API callback examples reference functions, but can be methods of classes.
-- To hook methods, you'll need to pass an array one of two ways.
--
-- Any of the syntaxes explained in the PHP documentation for the
-- {@link https://www.php.net/manual/en/language.pseudo-types.php#language.types.callback 'callback'}
-- type are valid.
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

with Inc_Class_Wp_Admin_Bar;
with Inc_Class_Wp_Styles;

package Inc_Plugins
is
   use Arrays;
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
                                  Args      : Array_type) is null;
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
