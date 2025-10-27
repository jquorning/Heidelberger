with Arrays;

package Inc_Elab_Plugins
is

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
                                         Callback  : Arrays.Callable;
                                         Priority  : Integer)
                                         return String;

end Inc_Elab_Plugins;
