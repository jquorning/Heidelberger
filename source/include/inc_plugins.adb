--
-- @package WordPress
-- @subpackage Plugin
-- @since 1.5.0
--

with Ada.Text_IO; use Ada.Text_IO;

with Php.Arrays;
with Php.Lists;
with Php.Preg;
with Php.Strings;

with Arrayable_Arrays;
with Constants;
with Globals;
with Helpers;
with Logging;
with UStrings;

with Class_Hook_Maps;
with Inc_Functions;

package body Inc_Plugins
is

   ----------------
   -- Add_Filter --
   ----------------

   function Add_Filter (Hook_Name     : String;
                        Callback      : Callable;
                        Priority      : Class_Hooks.Priority_Type := 10;
                        Accepted_Args : Integer := 1)
                        return Boolean
   is
      use Globals;
      use Class_Hooks;
      use Class_Hook_Maps;

      Hook : Wp_Hook;
   begin
      if not Hook_Maps.Has_Element (Global_Wp_Filter.Find (Hook_Name)) then
--    if not Isset (Wp_Filter (Hook_Name)) then
         Global_Wp_Filter.Insert (Hook_Name, Hook); -- Tampering with cursor
--       Wp_Filter (Hook_Name) := new WP_Hook();
      end if;

      Global_Wp_Filter (Hook_Name).Add_Filter (Hook_Name, Callback, Priority,
                                               Accepted_Args);

      return True;
   end Add_Filter;

   ----------------
   -- Add_Filter --
   ----------------

   procedure Add_Filter (Hook_Name     : String;
                         Callback      : Callable;
                         Priority      : Class_Hooks.Priority_Type := 10;
                         Accepted_Args : Integer                   := 1)
   is
      Unused : constant Boolean :=
        Add_Filter (Hook_Name, Callback, Priority, Accepted_Args);
   begin
      null;
   end Add_Filter;

   ----------------
   -- Add_Filter --
   ----------------

   procedure Add_Filter (Hook_Name     : String;
                         Callback      : Callable_3;
                         Priority      : Class_Hooks.Priority_Type := 10;
                         Accepted_Args : Integer                   := 1)
   is
   begin
      raise Program_Error with "not implemented";
   end Add_Filter;

   -------------------
   -- Apply_Filters --
   -------------------

   function Apply_Filters
              (Hook_Name : String;
               Value     : Array_Type;
               Args      : Arrayable_Interfaces.Arrayable_Interface'Class)
               return Array_Type
   is
      use Php.Lists;
      use Arrayable_Interfaces;
      use Globals;
      use Globals.Natural_Maps;
      use Class_Hook_Maps.Hook_Maps;

      Args_2 : Arrayable_Interface'Class := Args;
   begin
      Logging.Log ("inc_plugins.apply_filters", Hook_Name);

      if not Has_Element (Global_Wp_Filters.Find (Hook_Name)) then
         Global_Wp_Filters.Insert (Hook_Name, 1);
      else
         Global_Wp_Filters (Hook_Name) :=
           Global_Wp_Filters (Hook_Name) + 1;
      end if;

      -- Do 'all' actions first.
      if Has_Element (Global_Wp_Filter.Find ("all")) then
         Global_Wp_Current_Filter.Append (Hook_Name);

         declare
            All_Args : constant Arrayable_Interface'Class := Args; -- Func_Get_Args;
         begin
            X_Wp_Call_All_Hook (All_Args);
         end;
      end if;

      if not Has_Element (Global_Wp_Filter.Find (Hook_Name)) then
         if Has_Element (Global_Wp_Filter.Find ("all")) then
            List_Pop (Global_Wp_Current_Filter);
         end if;

         return Value;
      end if;

      if not Has_Element (Global_Wp_Filter.Find ("all")) then
         Global_Wp_Current_Filter.Append (Hook_Name);
      end if;

      -- Pass the value to WP_Hook.
      Args_2.Array_Unshift (Value);

      declare
         Filtered : constant Array_Type :=
           Global_Wp_Filter (Hook_Name).Apply_Filters (Value, Args_2);
      begin
         List_Pop (Global_Wp_Current_Filter);
         return Filtered;
      end;
   end Apply_Filters;

-- --
-- -- Calls the callback functions that have been added to a filter hook, specifying arguments in an array.
-- --
-- -- @since 3.0.0
-- --
-- -- @see apply_filters() This function is identical, but the arguments passed to the
-- --                      functions hooked to `hook_name` are supplied using an array.
-- --
-- -- @global WP_Hook[] wp_filter         Stores all of the filters and actions.
-- -- @global int[]     wp_filters        Stores the number of times each filter was triggered.
-- -- @global string[]  wp_current_filter Stores the list of current filters with the current one last.
-- --
-- -- @param string hook_name The name of the filter hook.
-- -- @param array  args      The arguments supplied to the functions hooked to `hook_name`.
-- -- @return mixed The filtered value after all hooked functions are applied to it.
-- --
-- function apply_filters_ref_array( hook_name, args ) then
--         global wp_filter, wp_filters, wp_current_filter;

--         if ( ! isset( wp_filters[ hook_name ] ) ) then
--                 wp_filters[ hook_name ] = 1;
--         end; else then
--                 ++wp_filters[ hook_name ];
--         end;

--         -- Do 'all' actions first.
--         if ( isset( wp_filter['all'] ) ) then
--                 wp_current_filter[] = hook_name;
--                 all_args            = func_get_args(); -- phpcs:ignore PHPCompatibility.FunctionUse.ArgumentFunctionsReportCurrentValue.NeedsInspection
--                 _wp_call_all_hook( all_args );
--         end;

--         if ( ! isset( wp_filter[ hook_name ] ) ) then
--                 if ( isset( wp_filter['all'] ) ) then
--                         array_pop( wp_current_filter );
--                 end;

--                 return args[0];
--         end;

--         if ( ! isset( wp_filter['all'] ) ) then
--                 wp_current_filter[] = hook_name;
--         end;

--         filtered = wp_filter[ hook_name ]->apply_filters( args[0], args );

--         array_pop( wp_current_filter );

--         return filtered;
-- end;

   ----------------
   -- Has_Filter --
   ----------------

   function Has_Filter (Hook_Name : String;
                        Callback  : Callable := null) -- Boolean := False)
                        return Boolean
   is
      use Globals;
      use Class_Hook_Maps.Hook_Maps;
   begin
      if not Has_Element (Global_Wp_Filter.Find (Hook_Name)) then
--    if not Isset (Wp_Filter (Hook_Name)) then
         return False;
      end if;

      return Global_Wp_Filter (Hook_Name).Has_Filter (Hook_Name, Callback);
   end Has_Filter;

-- --
-- -- Removes a callback function from a filter hook.
-- --
-- -- This can be used to remove default functions attached to a specific filter
-- -- hook and possibly replace them with a substitute.
-- --
-- -- To remove a hook, the `callback` and `priority` arguments must match
-- -- when the hook was added. This goes for both filters and actions. No warning
-- -- will be given on removal failure.
-- --
-- -- @since 1.2.0
-- --
-- -- @global WP_Hook[] wp_filter Stores all of the filters and actions.
-- --
-- -- @param string                hook_name The filter hook to which the function to be removed is hooked.
-- -- @param callable|string|array callback  The callback to be removed from running when the filter is applied.
-- --                                         This function can be called unconditionally to speculatively remove
-- --                                         a callback that may or may not exist.
-- -- @param int                   priority  Optional. The exact priority used when adding the original
-- --                                         filter callback. Default 10.
-- -- @return bool Whether the function existed before it was removed.
-- --
-- function remove_filter( hook_name, callback, priority = 10 ) then
--         global wp_filter;

--         r = false;

--         if ( isset( wp_filter[ hook_name ] ) ) then
--                 r = wp_filter[ hook_name ]->remove_filter( hook_name, callback, priority );

--                 if ( ! wp_filter[ hook_name ]->callbacks ) then
--                         unset( wp_filter[ hook_name ] );
--                 end;
--         end;

--         return r;
-- end;

-- --
-- -- Removes all of the callback functions from a filter hook.
-- --
-- -- @since 2.7.0
-- --
-- -- @global WP_Hook[] wp_filter Stores all of the filters and actions.
-- --
-- -- @param string    hook_name The filter to remove callbacks from.
-- -- @param int|false priority  Optional. The priority number to remove them from.
-- --                             Default false.
-- -- @return true Always returns true.
-- --
-- function remove_all_filters( hook_name, priority = false ) then
--         global wp_filter;

--         if ( isset( wp_filter[ hook_name ] ) ) then
--                 wp_filter[ hook_name ]->remove_all_filters( priority );

--                 if ( ! wp_filter[ hook_name ]->has_filters() ) then
--                         unset( wp_filter[ hook_name ] );
--                 end;
--         end;

--         return true;
-- end;

   --------------------
   -- Current_Filter --
   --------------------

   function Current_Filter
            return String
   is
      use Globals;
   begin
      -- Added by jq
      if Global_Wp_Current_Filter.Is_Empty then
         Logging.Log ("current_filter", "global_wp_current_filter is empty");
         return "";
      else
         return Global_Wp_Current_Filter.Last_Element; -- end()
      end if;
   end Current_Filter;

   -----------------
   -- Doing_Filer --
   -----------------

   function Doing_Filter (Hook_Name : String := "") -- null
                          return Boolean
   is
      use Php.Lists;
      use Globals;
   begin
      if "" = Hook_Name then
         return not Global_Wp_Current_Filter.Is_Empty;
--       return not Empty (Wp_Current_Filter);
      end if;

      return In_List (Hook_Name, Global_Wp_Current_Filter, True);

   end Doing_Filter;

-- --
-- -- Retrieves the number of times a filter has been applied during the current request.
-- --
-- -- @since 6.1.0
-- --
-- -- @global int[] wp_filters Stores the number of times each filter was triggered.
-- --
-- -- @param string hook_name The name of the filter hook.
-- -- @return int The number of times the filter hook has been applied.
-- --
-- function did_filter( hook_name ) then
--         global wp_filters;

--         if ( ! isset( wp_filters[ hook_name ] ) ) then
--                 return 0;
--         end;

--         return wp_filters[ hook_name ];
-- end;

   ----------------
   -- Add_Action --
   ----------------

   procedure Add_Action (Hook_Name     : String;
                         Callback      : Callable;
                         Priority      : Class_Hooks.Priority_Type := 10;
                         Accepted_Args : Integer                   := 1)
   is
      Unused : constant Boolean :=
        Add_Filter (Hook_Name, Callback, Priority, Accepted_Args);
   begin
      null;
   end Add_Action;

   ---------------
   -- Do_Action --
   ---------------

   procedure Do_Action
               (Hook_Name : String;
                Args      : Arrayable_Interfaces.Arrayable_Interface'Class)
                -- Arg_2     : String := "";
                -- Arg_3     : String := "")
   is
      use Php.Lists;
      use Arrayable_Interfaces;
      use Globals;
      use Globals.Count_Maps;
      use Class_Hook_Maps.Hook_Maps;
   begin
      Logging.Log ("do_action", Hook_Name);
      --  & ": '" & Arg_2 & "' '" & Arg_3 & "'");

      if not Has_Element (Global_Wp_Actions.Find (Hook_Name)) then
--    if not Isset (Wp_Actions, Hook_Name) then
         Global_Wp_Actions.Insert (Hook_Name, 1);
      else
         Global_Wp_Actions.Include (Hook_Name,
                                    Global_Wp_Actions (Hook_Name) + 1);
      end if;

      -- Do 'all' actions first.
      if Has_Element (Global_Wp_Filter.Find ("all")) then
--    if Isset (Wp_Filter, "all") then
         Global_Wp_Current_Filter.Append (Hook_Name);
         declare
            All_Args : constant Arrayable_Interface'Class := Args; -- Func_Get_Args;
         begin
            X_Wp_Call_All_Hook (All_Args);
         end;
      end if;

      if not Has_Element (Global_Wp_Filter.Find (Hook_Name)) then
--    if not Isset (Wp_Filter, Hook_Name) then
         if Has_Element (Global_Wp_Filter.Find ("all")) then
--       if Isset (Wp_Filter, "all") then
            List_Pop (Global_Wp_Current_Filter);
         end if;

         return;
      end if;

      if not Has_Element (Global_Wp_Filter.Find ("all")) then
         Global_Wp_Current_Filter.Append (Hook_Name);
      end if;

      declare
         Arg_2 : constant Arrayable_Interface'Class := Args; -- Func_Get_Args;
      begin
--       Arg.Include (Arg_2, "");
--       Arg.Include (Arg_3, "");
        -- if ( empty( arg ) ) then
        --         arg[] = '';
        -- end; elseif ( is_array( arg[0] ) && 1 === count( arg[0] ) && isset( arg[0][0] ) && is_object( arg[0][0] ) ) then
        --         -- Backward compatibility for PHP4-style passing of `array( &this )` as action `arg`.
        --         arg[0] = arg[0][0];
        -- end;

         Global_Wp_Filter (Hook_Name).Do_Action (Arg_2);
      end;
      List_Pop (Global_Wp_Current_Filter);
   end Do_Action;

   -------------------------
   -- Do_Action_Ref_Array --
   -------------------------

   procedure Do_Action_Ref_Array
               (Hook_Name : String;
                Args      : in out Arrayable_Interfaces.Arrayable_Interface'Class)
   is
      use Php.Lists;
      use Arrayable_Interfaces;
      use Globals;
      use Globals.Count_Maps;
      use Class_Hook_Maps.Hook_Maps;
   begin
      Logging.Log ("do_action_ref_array", Hook_Name);

      if not Has_Element (Global_Wp_Actions.Find (Hook_Name)) then
         Global_Wp_Actions.Insert (Hook_Name, 1);
      else
         Global_Wp_Actions.Include (Hook_Name,
                                    Global_Wp_Actions (Hook_Name) + 1);
      end if;

      -- Do 'all' actions first.
      if Has_Element (Global_Wp_Filter.Find ("all")) then
         Global_Wp_Current_Filter.Append (Hook_Name);
         declare
            All_Args : constant Arrayable_Interface'Class := Args; -- Func_Get_Args;
         begin
            X_Wp_Call_All_Hook (All_Args);
         end;
      end if;

      if not Has_Element (Global_Wp_Filter.Find (Hook_Name)) then
         if Has_Element (Global_Wp_Filter.Find ("all")) then
            List_Pop (Global_Wp_Current_Filter);
         end if;

         return;
      end if;

      if not Has_Element (Global_Wp_Filter.Find ("all")) then
         Global_Wp_Current_Filter.Append (Hook_Name);
      end if;

      Global_Wp_Filter (Hook_Name).Do_Action (Args);

      List_Pop (Global_Wp_Current_Filter);
   end Do_Action_Ref_Array;

   -- -------------------------
   -- -- Do_Action_Ref_Array --
   -- -------------------------

   -- procedure Do_Action_Ref_Array
   --             (Hook_Name : String;
   --              Args      : in out Class_Dependencies.Wp_Dependencies'Class)
   -- is
   --    use Php.Lists;
   --    use Globals;
   --    use Globals.Count_Maps;
   --    use Class_Hook_Maps.Hook_Maps;
   -- begin
   --    Logging.Log ("do_action_ref_array", Hook_Name);

   --    if not Has_Element (Global_Wp_Actions.Find (Hook_Name)) then
   --       Global_Wp_Actions.Include (Hook_Name, 1);
   --    else
   --       Global_Wp_Actions.Include (Hook_Name,
   --                                  Global_Wp_Actions (Hook_Name) + 1);
   --    end if;

   --    -- Do 'all' actions first.
   --    if Has_Element (Global_Wp_Filter.Find ("all")) then
   --       Global_Wp_Current_Filter.Append (Hook_Name);
   --       declare
   --          All_Args : Array_Type; --            := Func_Get_Args;
   --       begin
   --          X_Wp_Call_All_Hook (All_Args);
   --       end;
   --    end if;

   --    if not Has_Element (Global_Wp_Filter.Find (Hook_Name)) then
   --       if Has_Element (Global_Wp_Filter.Find ("all")) then
   --          List_Pop (Global_Wp_Current_Filter);
   --       end if;

   --       return;
   --    end if;

   --    if not Has_Element (Global_Wp_Filter.Find ("all")) then
   --       Global_Wp_Current_Filter.Append (Hook_Name);
   --    end if;

   --    Global_Wp_Filter (Hook_Name).Do_Action (Args);

   --    List_Pop (Global_Wp_Current_Filter);
   -- end Do_Action_Ref_Array;

   -- -------------------------
   -- -- Do_Action_Ref_Array --
   -- -------------------------

   -- procedure Do_Action_Ref_Array (Hook_Name : String;
   --                                Args      : Class_Admin_Bar.Wp_Admin_Bar)
   -- is
   --    Args_2 : Array_Type;
   -- begin
   --    Do_Action_Ref_Array (Hook_Name, Args_2);
   -- end Do_Action_Ref_Array;

   ----------------
   -- Has_Action --
   ----------------

   function Has_Action (Hook_Name : String;
                        Callback  : Callable := null)
                        return Boolean
   is
   begin
      return Has_Filter (Hook_Name, Callback);
   end Has_Action;

   -------------------
   -- Remove_Action --
   -------------------

   function Remove_Action (Hook_Name : String;
                           Callback  : Callable;
                           Priority  : Integer := 10)
                           return Boolean
   is
   begin
      return Remove_Filter (Hook_Name, Callback, Priority);
   end Remove_Action;

   procedure Remove_Action (Hook_Name : String;
                            Callback  : Callable;
                            Priority  : Integer := 10)
   is
      Unused : constant Boolean :=
        Remove_Action (Hook_Name, Callback, Priority);
   begin
      null;
   end Remove_Action;

-- --
-- -- Removes all of the callback functions from an action hook.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string    hook_name The action to remove callbacks from.
-- -- @param int|false priority  Optional. The priority number to remove them from.
-- --                             Default false.
-- -- @return true Always returns true.
-- --
-- function remove_all_actions( hook_name, priority = false ) then
--         return remove_all_filters( hook_name, priority );
-- end;

   --------------------
   -- Current_Action --
   --------------------

   function Current_Action return String is
   begin
      return Current_Filter;
   end Current_Action;

   ------------------
   -- Doing_Action --
   ------------------

   function Doing_Action (Hook_Name : String := "") -- null
                          return Boolean
   is
   begin
      return Doing_Filter (Hook_Name);
   end Doing_Action;

   ----------------
   -- Did_Action --
   ----------------

   function Did_Action (Hook_Name : String)
                        return Boolean
   is
      use Globals;
      use Globals.Count_Maps;
   begin
      if not Has_Element (Global_Wp_Actions.Find (Hook_Name)) then
--    if not Isset (Wp_Actions, Hook_Name) then
         return False; -- 0;
      end if;

      return Global_Wp_Actions (Hook_Name) /= 0;
   end Did_Action;

   -----------------------------
   -- Apply_Filers_Deprecated --
   -----------------------------

   function Apply_Filters_Deprecated (Hook_Name   : String;
                                      Args        : List_Type;
                                      Version     : String;
                                      Replacement : String := "";
                                      Message     : String := "")
                                      return String
   is
      use Inc_Functions;
   begin
      Logging.Log ("apply_filters_deprecated", Hook_Name);

      if not Has_Filter (Hook_Name) then
         return Args (1); -- [0]
      end if;

      X_Deprecated_Hook (Hook_Name, Version, Replacement, Message);

      return Apply_Filters_Ref_Array (Hook_Name, Args);
   end Apply_Filters_Deprecated;

   --------------------------
   -- Do_Action_Deprecated --
   --------------------------

   procedure Do_Action_Deprecated (Hook_Name   : String;
                                   Args        : List_Type;
                                   Version     : String;
                                   Replacement : String := "";
                                   Message     : String := "")
   is
      use Arrayable_Arrays;
      use Inc_Functions;

      Arry : Arrayable_Array;
   begin
      Logging.Log ("do_action_deprecated", Hook_Name);

      if not Has_Action (Hook_Name) then
         return;
      end if;

      X_Deprecated_Hook (Hook_Name, Version, Replacement, Message);

      Do_Action_Ref_Array (Hook_Name, Arry); -- Args);
   end Do_Action_Deprecated;

   -----------------------------------------
   ---- Functions for handling plugins. ----
   -----------------------------------------

   ---------------------
   -- Plugin_Basename --
   ---------------------

   Global_Wp_Plugin_Paths : Array_Type;

   function Plugin_Basename (File : String)
                             return String
   is
      use Php.Arrays;
      use Php.Preg;
      use Php.Strings;
      use UStrings;
      use Inc_Functions;

      -- wp_plugin_paths contains normalized paths.
      File_2 : UString := +Wp_Normalize_Path (File);
   begin
      Arsort (Global_Wp_Plugin_Paths);

      for A in Global_Wp_Plugin_Paths.Iterate loop
         declare
            Dir     : constant String := Key (A);
            Realdir : constant String := As_String (Element (A));
         begin
            if Strpos (-File_2, Realdir) = 0 then
               File_2 := +(Dir & Substr (-File_2, Strlen (Realdir)));
            end if;
         end;
      end loop;

      declare
         Plugin_Dir    : constant String :=
           Wp_Normalize_Path (-Constants.WP_PLUGIN_DIR);

         MU_Plugin_Dir : constant String :=
           Wp_Normalize_Path (-Constants.WPMU_PLUGIN_DIR);
      begin
         -- Get relative path from plugins directory.
         File_2 :=
           +Preg_Replace ("#^" & Preg_Quote (Plugin_Dir, "#") &
                          "/|^" & Preg_Quote (MU_Plugin_Dir, "#") & "/#",
                          "", -File_2);
      end;
      File_2 := +Trim (-File_2, "/");
      return -File_2;
   end Plugin_Basename;

-- --
-- -- Register a plugin's real path.
-- --
-- -- This is used in plugin_basename() to resolve symlinked paths.
-- --
-- -- @since 3.9.0
-- --
-- -- @see wp_normalize_path()
-- --
-- -- @global array wp_plugin_paths
-- --
-- -- @param string file Known path to the file.
-- -- @return bool Whether the path was able to be registered.
-- --
-- function wp_register_plugin_realpath( file ) then
--         global wp_plugin_paths;

--         -- Normalize, but store as static to avoid recalculation of a constant value.
--         static wp_plugin_path = null, wpmu_plugin_path = null;

--         if ( ! isset( wp_plugin_path ) ) then
--                 wp_plugin_path   = wp_normalize_path( WP_PLUGIN_DIR );
--                 wpmu_plugin_path = wp_normalize_path( WPMU_PLUGIN_DIR );
--         end;

--         plugin_path     = wp_normalize_path( dirname( file ) );
--         plugin_realpath = wp_normalize_path( dirname( realpath( file ) ) );

--         if ( plugin_path === wp_plugin_path || plugin_path === wpmu_plugin_path ) then
--                 return false;
--         end;

--         if ( plugin_path !== plugin_realpath ) then
--                 wp_plugin_paths[ plugin_path ] = plugin_realpath;
--         end;

--         return true;
-- end;

-- --
-- -- Get the filesystem directory path (with trailing slash) for the plugin __FILE__ passed in.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string file The filename of the plugin (__FILE__).
-- -- @return string the filesystem path of the directory that contains the plugin.
-- --
-- function plugin_dir_path( file ) then
--         return trailingslashit( dirname( file ) );
-- end;

-- --
-- -- Get the URL directory path (with trailing slash) for the plugin __FILE__ passed in.
-- --
-- -- @since 2.8.0
-- --
-- -- @param string file The filename of the plugin (__FILE__).
-- -- @return string the URL path of the directory that contains the plugin.
-- --
-- function plugin_dir_url( file ) then
--         return trailingslashit( plugins_url( '', file ) );
-- end;

-- --
-- -- Set the activation hook for a plugin.
-- --
-- -- When a plugin is activated, the action 'activate_PLUGINNAME' hook is
-- -- called. In the name of this hook, PLUGINNAME is replaced with the name
-- -- of the plugin, including the optional subdirectory. For example, when the
-- -- plugin is located in wp-content/plugins/sampleplugin/sample.php, then
-- -- the name of this hook will become 'activate_sampleplugin/sample.php'.
-- --
-- -- When the plugin consists of only one file and is (as by default) located at
-- -- wp-content/plugins/sample.php the name of this hook will be
-- -- 'activate_sample.php'.
-- --
-- -- @since 2.0.0
-- --
-- -- @param string   file     The filename of the plugin including the path.
-- -- @param callable callback The function hooked to the 'activate_PLUGIN' action.
-- --
-- function register_activation_hook( file, callback ) then
--         file = plugin_basename( file );
--         add_action( 'activate_' . file, callback );
-- end;

-- --
-- -- Sets the deactivation hook for a plugin.
-- --
-- -- When a plugin is deactivated, the action 'deactivate_PLUGINNAME' hook is
-- -- called. In the name of this hook, PLUGINNAME is replaced with the name
-- -- of the plugin, including the optional subdirectory. For example, when the
-- -- plugin is located in wp-content/plugins/sampleplugin/sample.php, then
-- -- the name of this hook will become 'deactivate_sampleplugin/sample.php'.
-- --
-- -- When the plugin consists of only one file and is (as by default) located at
-- -- wp-content/plugins/sample.php the name of this hook will be
-- -- 'deactivate_sample.php'.
-- --
-- -- @since 2.0.0
-- --
-- -- @param string   file     The filename of the plugin including the path.
-- -- @param callable callback The function hooked to the 'deactivate_PLUGIN' action.
-- --
-- function register_deactivation_hook( file, callback ) then
--         file = plugin_basename( file );
--         add_action( 'deactivate_' . file, callback );
-- end;

-- --
-- -- Sets the uninstallation hook for a plugin.
-- --
-- -- Registers the uninstall hook that will be called when the user clicks on the
-- -- uninstall link that calls for the plugin to uninstall itself. The link won't
-- -- be active unless the plugin hooks into the action.
-- --
-- -- The plugin should not run arbitrary code outside of functions, when
-- -- registering the uninstall hook. In order to run using the hook, the plugin
-- -- will have to be included, which means that any code laying outside of a
-- -- function will be run during the uninstallation process. The plugin should not
-- -- hinder the uninstallation process.
-- --
-- -- If the plugin can not be written without running code within the plugin, then
-- -- the plugin should create a file named 'uninstall.php' in the base plugin
-- -- folder. This file will be called, if it exists, during the uninstallation process
-- -- bypassing the uninstall hook. The plugin, when using the 'uninstall.php'
-- -- should always check for the 'WP_UNINSTALL_PLUGIN' constant, before
-- -- executing.
-- --
-- -- @since 2.7.0
-- --
-- -- @param string   file     Plugin file.
-- -- @param callable callback The callback to run when the hook is called. Must be
-- --                           a static method or function.
-- --
-- function register_uninstall_hook( file, callback ) then
--         if ( is_array( callback ) && is_object( callback[0] ) ) then
--                 _doing_it_wrong( __FUNCTION__, __( 'Only a static class method or function can be used in an uninstall hook.' ), '3.1.0' );
--                 return;
--         end;

--         /*
--         -- The option should not be autoloaded, because it is not needed in most
--         -- cases. Emphasis should be put on using the 'uninstall.php' way of
--         -- uninstalling the plugin.
--         --
--         uninstallable_plugins = (array) get_option( 'uninstall_plugins' );
--         plugin_basename       = plugin_basename( file );

--         if ( ! isset( uninstallable_plugins[ plugin_basename ] ) || uninstallable_plugins[ plugin_basename ] !== callback ) then
--                 uninstallable_plugins[ plugin_basename ] = callback;
--                 update_option( 'uninstall_plugins', uninstallable_plugins );
--         end;
-- end;

   ------------------------
   -- X_Wp_Call_All_Hook --
   ------------------------

   procedure X_Wp_Call_All_Hook
               (Args : Arrayable_Interfaces.Arrayable_Interface'Class)
   is
      use Globals;
--    global wp_filter;
   begin
      Global_Wp_Filter ("all").Do_All_Hook (Args);
   end X_Wp_Call_All_Hook;

   ----------------
   -- Dump_Hooks --
   ----------------

   procedure Dump_Hooks
   is
      use Globals;
      use Globals.Count_Maps;
      use Globals.Natural_Maps;
      use Class_Hooks;
      use Class_Hook_Maps.Hook_Maps;
   begin
      Put_Line ("dump_hooks:");

      Put_Line ("  global_wp_actions:");
      for A in Global_Wp_Actions.Iterate loop
         declare
            K : constant String  := Key (A);
            V : constant Natural := Element (A);
         begin
            Put_Line ("    " & K & ": " & Helpers.Image (V));
         end;
      end loop;

      Put_Line ("  global_wp_filters:");
      for A in Global_Wp_Filters.Iterate loop
         declare
            K : constant String  := Key (A);
            V : constant Natural := Element (A);
         begin
            Put_Line ("    " & K & ": " & Helpers.Image (V));
         end;
      end loop;

      Put_Line ("  global_wp_current_filter:");
      for A of Global_Wp_Current_Filter loop
         Put_Line ("    " & A);
      end loop;

      Put_Line ("  global_wp_filter:");
      for A in Global_Wp_Filter.Iterate loop
         declare
            K : constant String  := Key (A);
            V : constant Wp_Hook := Element (A);
         begin
            Put_Line ("    " & K); --  & ": " & Helpers.Image (V));
         end;
      end loop;
   end Dump_Hooks;

begin

   Globals.Global_Wp_Filter :=
     Class_Hook_Maps.Build_Preinitialized_Hooks (Globals.Global_Wp_Filter);

end Inc_Plugins;
