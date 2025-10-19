with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wp_Terms;

package Inc_Class_Wp_Walker
is
   use Ada.Strings.Unbounded;
   use Arrays;

   --
   -- A class for displaying various tree-like structures.
   --
   -- Extend the Walker class to use it, see examples below. Child classes
   -- do not need to implement all of the abstract methods in the class. The child
   -- only needs to implement the methods that are needed.
   --
   -- @since 2.1.0
   --
   -- @package WordPress
   -- @abstract
   --
   -- #[AllowDynamicProperties]
   type Walker is tagged
      record
         --
         -- What the class handles.
         --
         -- @since 2.1.0
         -- @var string
         --
         Tree_Type : Unbounded_String;

         --
         -- DB fields to use.
         --
         -- @since 2.1.0
         -- @var string[]
         --
         DB_Fields : Array_Type;

         --
         -- Max number of pages walked by the paged walker.
         --
         -- @since 2.7.0
         -- @var int
         --
         Max_Pages : Natural := 1;

         --
         -- Whether the current element has children or not.
         --
         -- To be used in start_el().
         --
         -- @since 4.0.0
         -- @var bool
         --
         Has_Children : Boolean;

      end record;

   --
   -- Starts the list before the elements are added.
   --
   -- The $args parameter holds additional values that may be used with the child
   -- class methods. This method is called at the start of the output list.
   --
   -- @since 2.1.0
   -- @abstract
   --
   -- @param string $output Used to append additional content (passed by reference).
   -- @param int    $depth  Depth of the item.
   -- @param array  $args   An array of additional arguments.
   --
   procedure Start_LVL (This   : Walker;
                        Output : in out Unbounded_String;
                        Depth  : Integer    := 0;
                        Args   : Array_Type := Empty_Array);

   --
   -- Ends the list of after the elements are added.
   --
   -- The $args parameter holds additional values that may be used with the child
   -- class methods. This method finishes the list at the end of output of the
   --  elements.
   --
   -- @since 2.1.0
   -- @abstract
   --
   -- @param string $output Used to append additional content (passed by reference).
   -- @param int    $depth  Depth of the item.
   -- @param array  $args   An array of additional arguments.
   --
   procedure End_LVL (This   : Walker;
                      Output : in out Unbounded_String;
                      Depth  : Integer    := 0;
                      Args   : Array_Type := Empty_Array);

   --
   -- Starts the element output.
   --
   -- The $args parameter holds additional values that may be used with the child
   -- class methods. Also includes the element output.
   --
   -- @since 2.1.0
   -- @since 5.9.0 Renamed `$object` (a PHP reserved keyword) to `$data_object` for
   --              PHP 8 named parameter support.
   -- @abstract
   --
   -- @param string $output            Used to append additional content (passed by
   --                                  reference).
   -- @param object $data_object       The data object.
   -- @param int    $depth             Depth of the item.
   -- @param array  $args              An array of additional arguments.
   -- @param int    $current_object_id Optional. ID of the current item. Default 0.
   --
   procedure Start_EL (This              : Walker;
                       Output            : in out Unbounded_String;
                       Data_Object       : Array_Type;
                       Depth             : Integer    := 0;
                       Args              : Array_Type := Empty_Array;
                       Current_Object_Id : Integer    := 0);

   --
   -- Ends the element output, if needed.
   --
   -- The $args parameter holds additional values that may be used with the child
   -- class methods.
   --
   -- @since 2.1.0
   -- @since 5.9.0 Renamed `$object` (a PHP reserved keyword) to `$data_object` for
   --              PHP 8 named parameter support.
   -- @abstract
   --
   -- @param string $output      Used to append additional content (passed by
   --                            reference).
   -- @param object $data_object The data object.
   -- @param int    $depth       Depth of the item.
   -- @param array  $args        An array of additional arguments.
   --
   procedure End_EL (This              : Walker;
                     Output            : in out Unbounded_String;
                     Data_Object       : Array_Type;
                     Depth             : Integer    := 0;
                     Args              : Array_Type := Empty_Array);

   --
   -- Traverses elements to create list from elements.
   --
   -- Display one element if the element doesn't have any children otherwise,
   -- display the element and its children. Will only traverse up to the max
   -- depth and no ignore elements under that depth. It is possible to set the
   -- max depth to include all depths, see walk() method.
   --
   -- This method should not be called directly, use the walk() method instead.
   --
   -- @since 2.5.0
   --
   -- @param object $element           Data object.
   -- @param array  $children_elements List of elements to continue traversing
   --                                  (passed by reference).
   -- @param int    $max_depth         Max depth to traverse.
   -- @param int    $depth             Depth of current element.
   -- @param array  $args              An array of arguments.
   -- @param string $output            Used to append additional content (passed by
   --                                  reference).
   --
   procedure Display_Element (This              : in out Walker;
                              Element           : Array_Type;
                              Children_Elements : in out Array_Type;
                              Max_Depth         : Integer;
                              Depth             : Integer;
                              Args              : Array_Type;
                              Output            : in out Unbounded_String);

   --
   -- Displays array of elements hierarchically.
   --
   -- Does not assume any existing order of elements.
   --
   -- $max_depth = -1 means flatly display every element.
   -- $max_depth = 0 means display all levels.
   -- $max_depth > 0 specifies the number of display levels.
   --
   -- @since 2.1.0
   -- @since 5.3.0 Formalized the existing `...$args` parameter by adding it
   --              to the function signature.
   --
   -- @param array $elements  An array of elements.
   -- @param int   $max_depth The maximum hierarchical depth.
   -- @param mixed ...$args   Optional additional arguments.
   -- @return string The hierarchical item output.
   --
   function Walk (This      : in out Walker;
                  Elements  : Array_Type; -- Inc_Class_Wp_Terms.Wp_Term_Array;
                  Max_Depth : Integer;
                  Args      : Array_Type)
                  return String;

end Inc_Class_Wp_Walker;
