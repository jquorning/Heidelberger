--
-- Dependencies API: WP_Dependencies base class
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrayable_Interfaces;
with Arrays;
with Lists;

with Class_Dependency;

package Class_Dependencies
-- with SPARK_Mode => On
is
   use Lists;

   type Group_Type is new Integer range -1 .. Integer'Last;
   No_Group : constant Group_Type := -1;

   package Group_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                              Element_Type => Group_Type);
   subtype Group_Map is Group_Maps.Map;

   --
   -- Core base class extended to register items.
   --
   -- @since 2.6.0
   --
   -- @see _WP_Dependency
   --
   -- #[AllowDynamicProperties]
   type Wp_Dependencies is
      new Arrayable_Interfaces.Arrayable_Interface
      with record
        --
        -- An array of all registered dependencies keyed by handle.
        --
        -- @since 2.6.8
        --
        -- @var _WP_Dependency[]
        --
        Registered : Class_Dependency.Dependency_Map;

        --
        -- An array of handles of queued dependencies.
        --
        -- @since 2.6.8
        --
        -- @var string[]
        --
        Queue : List_Type;

        --
        -- An array of handles of dependencies to queue.
        --
        -- @since 2.6.0
        --
        -- @var string[]
        --
        To_Do : List_Type;

        --
        -- An array of handles of dependencies already queued.
        --
        -- @since 2.6.0
        --
        -- @var string[]
        --
        Done : List_Type;

        --
        -- An array of additional arguments passed when a handle is registered.
        --
        -- Arguments are appended to the item query string.
        --
        -- @since 2.6.0
        --
        -- @var array
        --
        Args : Class_Dependency.String_Map;

        --
        -- An array of dependency groups to enqueue.
        --
        -- Each entry is keyed by handle and represents the integer group level or
        -- boolean false if the handle has no group.
        --
        -- @since 2.8.0
        --
        -- @var (int|false)[]
        --
        Groups : Group_Map;

        --
        -- A handle group to enqueue.
        --
        -- @since 2.8.0
        --
        -- @deprecated 4.5.0
        -- @var int
        --
--        Group : Integer := 0;

        --
        -- Cached lookup array of flattened queued items and dependencies.
        --
        -- @since 5.4.0
        --
        -- @var array
        --
--        private
        All_Queued_Deps : List_Type;

        --
        -- List of assets enqueued before details were registered.
        --
        -- @since 5.9.0
        --
        -- @var array
        --
--      private
        Queued_Before_Register : List_Type;

      end record;

   --
   -- Processes the items and dependencies.
   --
   -- Processes the items passed to it or the queue, and their dependencies.
   --
   -- @since 2.6.0
   -- @since 2.8.0 Added the `$group` parameter.
   --
   -- @param string|string[]|false $handles Optional. Items to be processed: queue
   --                                      (false), single item (string), or multiple
   --                                      items (array of strings).
   --                                       Default false.
   -- @param int|false             $group   Optional. Group level: level (int), no
   --                                       group (false).
   -- @return string[] Array of handles of items that have been processed.
   --
   function Do_Items (This    : in out Wp_Dependencies;
                      Handles : List_Type  := Empty_List; -- = false,
                      Group   : Group_Type := No_Group)
                      return List_Type
                      with Side_Effects;

   function Do_Items (This    : in out Wp_Dependencies;
                      Handles : Boolean;
                      Group   : Group_Type := No_Group)
                      return List_Type
                      with Side_Effects;
--                    is ([]);

   procedure Do_Items (This    : in out Wp_Dependencies;
                       Handles : List_Type;
                       Group   : Group_Type := No_Group);

   procedure Do_Items (This    : in out Wp_Dependencies;
                       Handles : Boolean;
                       Group   : Group_Type := No_Group);

   --
   -- Processes a dependency.
   --
   -- @since 2.6.0
   -- @since 5.5.0 Added the `$group` parameter.
   --
   -- @param string    $handle Name of the item. Should be unique.
   -- @param int|false $group  Optional. Group level: level (int), no group (false).
   --                          Default false.
   -- @return bool True on success, false if not set.
   --
   function Do_Item (This   : in out Wp_Dependencies;
                     Handle : String;
                     Group  : Group_Type := No_Group)
                     return Boolean;

   --
   -- Determines dependencies.
   --
   -- Recursively builds an array of items to process taking
   -- dependencies into account. Does NOT catch infinite loops.
   --
   -- @since 2.1.0
   -- @since 2.6.0 Moved from `WP_Scripts`.
   -- @since 2.8.0 Added the `$group` parameter.
   --
   -- @param string|string[] $handles   Item handle (string) or item handles (array
   --                                   of strings).
   -- @param bool            $recursion Optional. Internal flag that function is
   --                                   calling itself.
   --                                   Default false.
   -- @param int|false       $group     Optional. Group level: level (int), no group
   --                                   (false). Default false.
   -- @return bool True on success, false on failure.
   --
   function All_Deps (This      : in out Wp_Dependencies;
                      Handles   : List_Type; -- String_Array;
                      Recursion : Boolean    := False;
                      Group     : Group_Type := No_Group)
                      return Boolean
                      with Side_Effects;

   --
   -- Register an item.
   --
   -- Registers the item if no item of that name already exists.
   --
   -- @since 2.1.0
   -- @since 2.6.0 Moved from `WP_Scripts`.
   --
   -- @param string           $handle Name of the item. Should be unique.
   -- @param string|false     $src    Full URL of the item, or path of the item
   --                                 relative to the WordPress root directory. If
   --                                 source is set to false,
   --                                 item is an alias of other items it depends on.
   -- @param string[]         $deps   Optional. An array of registered item handles
   --                                 this item depends on. Default empty array.
   -- @param string|bool|null $ver    Optional. String specifying item version
   --                                 number, if it has one, which is added to the
   --                                 URL as a query string for cache busting purposes.
   --                                 If version is set to false, a version number is
   --                                 automatically added equal to current installed
   --                                 WordPress version. If set to null, no version
   --                                 is added.
   -- @param mixed            $args   Optional. Custom property of the item. NOT the
   --                                 class property $args.
   --                                 Examples: $media, $in_footer.
   -- @return bool Whether the item has been registered. True on success, false on
   --              failure.
   --
   function Add (This   : in out Wp_Dependencies;
                 Handle : String;
                 Src    : String;
                 Deps   : List_Type := Empty_List;
                 Ver    : String    := "";
                 Args   : String    := "")
                 return Boolean;

   procedure Add (This   : in out Wp_Dependencies;
                  Handle : String;
                  Src    : String;
                  Deps   : List_Type := Empty_List;
                  Ver    : String    := "";
                  Args   : String    := "");

   procedure Add (This   : in out Wp_Dependencies;
                  Handle : String;
                  Src    : String;
                  Deps   : List_Type := Empty_List;
                  Ver    : String    := "";
                  Args   : Integer);

   procedure Add (This   : in out Wp_Dependencies;
                  Handle : String;
                  Src    : Boolean;
                  Deps   : List_Type := Empty_List;
                  Ver    : String    := "";
                  Args   : Integer   := 0);

   --
   -- Add extra item data.
   --
   -- Adds data to a registered item.
   --
   -- @since 2.6.0
   --
   -- @param string $handle Name of the item. Should be unique.
   -- @param string $key    The data key.
   -- @param mixed  $value  The data value.
   -- @return bool True on success, false on failure.
   --
   function Add_Data (This   : in out Wp_Dependencies;
                      Handle : String;
                      Key    : String;
                      Value  : String)
                      return Boolean
                      with Side_Effects;

   function Add_Data (This   : in out Wp_Dependencies;
                      Handle : String;
                      Key    : String;
                      Value  : List_Type)
                      return Boolean
                      with Side_Effects;

   procedure Add_Data (This   : in out Wp_Dependencies;
                       Handle : String;
                       Key    : String;
                       Value  : String);

   --
   -- Get extra item data.
   --
   -- Gets data associated with a registered item.
   --
   -- @since 3.3.0
   --
   -- @param string $handle Name of the item. Should be unique.
   -- @param string $key    The data key.
   -- @return mixed Extra item data (string), false otherwise.
   --
   function Get_Data (This : Wp_Dependencies;
                      Handle : String;
                      Key    : String)
                      return String;

   function Get_Data (This : Wp_Dependencies;
                      Handle : String;
                      Key    : String)
                      return List_Type
                      is (Empty_List);

   --
   -- Un-register an item or items.
   --
   -- @since 2.1.0
   -- @since 2.6.0 Moved from `WP_Scripts`.
   --
   -- @param string|string[] $handles Item handle (string) or item handles (array of
   --                                 strings).
   --
   procedure Remove (This    : in out Wp_Dependencies;
                     Handles : List_Type); -- String_Array);

   --
   -- Queue an item or items.
   --
   -- Decodes handles and arguments, then queues handles and stores
   -- arguments in the class property $args. For example in extending
   -- classes, $args is appended to the item url as a query string.
   -- Note $args is NOT the $args property of items in the $registered array.
   --
   -- @since 2.1.0
   -- @since 2.6.0 Moved from `WP_Scripts`.
   --
   -- @param string|string[] $handles Item handle (string) or item handles (array
   --                                 of strings).
   --
   procedure Enqueue (This    : in out Wp_Dependencies;
                      Handles : List_Type); -- String_Array);

   --
   -- Dequeue an item or items.
   --
   -- Decodes handles and arguments, then dequeues handles
   -- and removes arguments from the class property $args.
   --
   -- @since 2.1.0
   -- @since 2.6.0 Moved from `WP_Scripts`.
   --
   -- @param string|string[] $handles Item handle (string) or item handles (array of
   --                                 strings).
   --
   procedure Dequeue (This    : in out Wp_Dependencies;
                      Handles : List_Type); -- String_Array);

   --
   -- Recursively search the passed dependency tree for a handle.
   --
   -- @since 4.0.0
   --
   -- @param string[] $queue  An array of queued _WP_Dependency handles.
   -- @param string   $handle Name of the item. Should be unique.
   -- @return bool Whether the handle is found after recursively searching the
   --              dependency tree.
   --
-- protected
   function Recurse_Deps (This   : in out Wp_Dependencies;
                          Queue  : List_Type; -- String_Array;
                          Handle : String)
                          return Boolean
                          with Side_Effects;

   --
   -- Query the list for an item.
   --
   -- @since 2.1.0
   -- @since 2.6.0 Moved from `WP_Scripts`.
   --
   -- @param string $handle Name of the item. Should be unique.
   -- @param string $status Optional. Status of the item to query. Default
   --                       'registered'.
   -- @return bool|_WP_Dependency Found, or object Item data.
   --
   type Query_Result is
      record
         Success : Boolean;
         Depend  : Class_Dependency.X_Wp_Dependency;
      end record;

   function Query (This   : in out Wp_Dependencies;
                   Handle : String;
                   Status : String := "registered")
                   return Query_Result
                   with Side_Effects;

   --
   -- Set item group, unless already in a lower group.
   --
   -- @since 2.8.0
   --
   -- @param string    $handle    Name of the item. Should be unique.
   -- @param bool      $recursion Internal flag that calling function was called
   --                             recursively.
   -- @param int|false $group     Group level: level (int), no group (false).
   -- @return bool Not already in the group or a lower group.
   --
   function Set_Group (This      : in out Wp_Dependencies;
                       Handle    : String;
                       Recursion : Boolean;
                       Group     : Group_Type)
                       return Boolean
                       with Side_Effects;

   --
   --
   --
   overriding
   function To_Array (This : Wp_Dependencies)
                      return Arrays.Array_Type;

   --
   --
   --
   overriding
   procedure Array_Unshift (X : in out Wp_Dependencies;
                            S : Arrays.Array_Type);

end Class_Dependencies;
