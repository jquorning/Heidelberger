
with Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;

with Hb_Common;
with Php;

package body Inc_Class_Wp_Walker
is

   ---------------
   -- Start_LVL --
   ---------------

   procedure Start_LVL (This   : Walker;
                        Output : in out Unbounded_String;
                        Depth  : Integer    := 0;
                        Args   : Array_Type := Empty_Array)
   is null;

   -------------
   -- End_LVL --
   -------------

   procedure End_LVL (This   : Walker;
                      Output : in out Unbounded_String;
                      Depth  : Integer    := 0;
                      Args   : Array_Type := Empty_Array)
   is null;

   --------------
   -- Start_EL --
   --------------

   procedure Start_EL (This              : Walker;
                       Output            : in out Unbounded_String;
                       Data_Object       : Array_Type;
                       Depth             : Integer    := 0;
                       Args              : Array_Type := Empty_Array;
                       Current_Object_Id : Integer    := 0)
   is null;

   ------------
   -- End_EL --
   ------------

   procedure End_EL (This              : Walker;
                     Output            : in out Unbounded_String;
                     Data_Object       : Array_Type;
                     Depth             : Integer    := 0;
                     Args              : Array_Type := Empty_Array)
   is null;

   ---------------------
   -- Display_Element --
   ---------------------

   procedure Display_Element (This              : in out Walker;
                              Element           : Array_Type;
                              Children_Elements : in out Array_Type;
                              Max_Depth         : Integer;
                              Depth             : Integer;
                              Args              : Array_Type;
                              Output            : in out Unbounded_String)
   is
      use Hb_Common;
   begin
      if Element = Empty_Array then
         return;
      end if;

      declare
         Id_Field : String := Get (This.DB_Fields, "id");
         Id       : constant String := Get (Element, "term_id"); -- Element.Id_Field;
         Newlevel     : Boolean;
         Newlevel_Set : Boolean := False;
      begin
         -- Display this element.
         This.Has_Children := not Empty (Children_Elements, Id);
--       This.Has_Children := not Empty (Children_Elements (Id));
         -- if ( isset( $args[0] ) && is_array( $args[0] ) ) then
         --    $args[0]['has_children'] = $this->has_children; -- Back-compat.
         -- end;

         This.Start_EL (Output, Element, Depth, Args); -- ...Array_Values

         -- Descend only when the depth is right and there are children for this
         -- element.
         if
           (0 = Max_Depth or else Max_Depth > Depth + 1) and then
           Isset (Children_Elements, Id)
         then
            for A in Get_Array (Children_Elements, Id).Iterate loop
--          for Child of Get_Array (Children_Elements, Id) loop
               declare
                  Child : Array_Type; -- String := Array_Maps.Key (A);
               begin
                  if not Newlevel_Set then
--                if not Isset (Newlevel) then
                     Newlevel     := True;
                     Newlevel_Set := True;
                     -- Start the child delimiter.
                     This.Start_LVL (Output, Depth, Args); -- ...Array_Values
                  end if;
                  This.Display_Element (Child, Children_Elements, Max_Depth,
                                        Depth + 1, Args, Output);
               end;
            end loop;
            Children_Elements.Delete (Id);
--          Unset (Children_Elements (Id));
         end if;

         if Newlevel_Set and then Newlevel then
--       if Isset (Newlevel) and then Newlevel then
            -- End the child delimiter.
            This.End_LVL (Output, Depth, Args); -- ...Array_Values
         end if;

         -- End this element.
         This.End_EL (Output, Element, Depth, Args); -- ...Array_Values
      end;
   end Display_Element;

   ----------
   -- Walk --
   ----------

   function Walk (This      : in out Walker;
                  Elements  : Array_Type; -- Inc_Class_Wp_Terms.Wp_Term_Array;
                  Max_Depth : Integer;
                  Args      : Array_Type)
                  return String
   is
      use Ada.Containers;
      use Hb_Common;
      use Inc_Class_Wp_Terms;

      Output : Unbounded_String;
   begin
Put_Line ("#4-1");
      -- Invalid parameter or nothing to walk.
      if
        Max_Depth < -1 or else
        Length (Elements) = 0
--      Term_Vectors.Length (Elements) in 0
--      Empty (Elements)
      then
         return -Output;
      end if;
Put_Line ("#4-2");
      -- Flat display.
      if -1 = Max_Depth then
         declare
            Empty_Array : Array_Type;
         begin
            for E of Elements loop
               This.Display_Element (E.Arry.all, Empty_Array, 1, 0, Args, Output);
            end loop;
            return -Output;
         end;
      end if;
Put_Line ("#4-3");
      --
      -- Need to display in hierarchical order.
      -- Separate elements into two buckets: top level and children elements.
      -- Children_elements is two dimensional array. Example:
      -- Children_elements[10][] contains all sub-elements whose parent is 10.
      --
      declare
         Parent_Field : constant String := Get (This.DB_Fields, "parent");
         Top_Level_Elements : Array_Type;
         Children_Elements  : Array_Type;
      begin
         for E of Elements loop
            if Empty (E.Arry.all, Parent_Field) then
--          if Empty (E.Parent_Field) then
               Set_Array (Top_Level_Elements, Key => "XXX-994", Value => E.Arry.all);
--             Top_Level_Elements.Append (E.Arry.all);
            else
               Children_Elements.Include (Key      => Parent_Field,
                                          New_Item => E);
--             Children_Elements (E.Parent_Field).Append (E);
            end if;
         end loop;
Put_Line ("#4-4");
         --
         -- When none of the elements is top level.
         -- Assume the first one must be root of the sub elements.
         --
         if Empty (Top_Level_Elements) then
            declare
               First : constant Array_Type := Php.Array_Slice (Elements, 0, 1);
               Root  : constant String     := -First.First_Element.Str; -- [0];

               Top_Level_Elements : Array_Type;
               Children_Elements  : Array_Type;
            begin
               for E of Elements loop
                  if Get (Root, Parent_Field) = Get (E.Arry.all, Parent_Field) then
--                if Root.Parent_Field = E.Parent_Field then
                     Set_Array (Top_Level_Elements,
                                Key   => "XXX-993",
                                Value => E.Arry.all);
--                   Top_Level_Elements.Append (E);
                  else
                     Children_Elements.Include (Key      => Parent_Field,
                                                New_Item => E);
--                   Children_Elements (E.Parent_Field).Append (E);
                  end if;
               end loop;
            end;
         end if;
Put_Line ("#4-5");
         for E of Top_Level_Elements loop
            This.Display_Element
              (E.Arry.all, Children_Elements, Max_Depth, 0, Args, Output);
         end loop;
Put_Line ("#4-6");
         --
         -- If we are displaying all levels, and remaining children_elements is not
         -- empty, then we got orphans, which should be displayed regardless.
         --
         if 0 = Max_Depth and then Length (Children_Elements) > 0 then
            declare
               Empty_Array : Array_Type;
            begin
               for Orphans of Children_Elements loop
                  for Op of Orphans.Arry.all loop
                     This.Display_Element (Op.Arry.all, Empty_Array, 1, 0,
                                           Args, Output);
                  end loop;
               end loop;
            end;
         end if;
Put_Line ("#4-7");
         return -Output;
      end;
   end Walk;

--         --
--         -- Produces a page of nested elements.
--         --
--         -- Given an array of hierarchical elements, the maximum depth, a specific page number,
--         -- and number of elements per page, this function first determines all top level root elements
--         -- belonging to that page, then lists them and all of their children in hierarchical order.
--         --
--         -- $max_depth = 0 means display all levels.
--         -- $max_depth > 0 specifies the number of display levels.
--         --
--         -- @since 2.7.0
--         -- @since 5.3.0 Formalized the existing `...$args` parameter by adding it
--         --              to the function signature.
--         --
--         -- @param array $elements  An array of elements.
--         -- @param int   $max_depth The maximum hierarchical depth.
--         -- @param int   $page_num  The specific page number, beginning with 1.
--         -- @param int   $per_page  Number of elements per page.
--         -- @param mixed ...$args   Optional additional arguments.
--         -- @return string XHTML of the specified page of elements.
--         --
--         public function paged_walk( $elements, $max_depth, $page_num, $per_page, ...$args ) then
--                 if ( empty( $elements ) || $max_depth < -1 ) then
--                         return '';
--                 end;

--                 $output = '';

--                 $parent_field = $this->db_fields['parent'];

--                 $count = -1;
--                 if ( -1 == $max_depth ) then
--                         $total_top = count( $elements );
--                 end;
--                 if ( $page_num < 1 || $per_page < 0 ) then
--                         // No paging.
--                         $paging = false;
--                         $start  = 0;
--                         if ( -1 == $max_depth ) then
--                                 $end = $total_top;
--                         end;
--                         $this->max_pages = 1;
--                 end; else then
--                         $paging = true;
--                         $start  = ( (int) $page_num - 1 )-- (int) $per_page;
--                         $end    = $start + $per_page;
--                         if ( -1 == $max_depth ) then
--                                 $this->max_pages = ceil( $total_top / $per_page );
--                         end;
--                 end;

--                 // Flat display.
--                 if ( -1 == $max_depth ) then
--                         if ( ! empty( $args[0]['reverse_top_level'] ) ) then
--                                 $elements = array_reverse( $elements );
--                                 $oldstart = $start;
--                                 $start    = $total_top - $end;
--                                 $end      = $total_top - $oldstart;
--                         end;

--                         $empty_array = array();
--                         foreach ( $elements as $e ) then
--                                 $count++;
--                                 if ( $count < $start ) then
--                                         continue;
--                                 end;
--                                 if ( $count >= $end ) then
--                                         break;
--                                 end;
--                                 $this->display_element( $e, $empty_array, 1, 0, $args, $output );
--                         end;
--                         return $output;
--                 end;

--                 /*
--                 -- Separate elements into two buckets: top level and children elements.
--                 -- Children_elements is two dimensional array, e.g.
--                 -- $children_elements[10][] contains all sub-elements whose parent is 10.
--                 --
--                 $top_level_elements = array();
--                 $children_elements  = array();
--                 foreach ( $elements as $e ) then
--                         if ( empty( $e->$parent_field ) ) then
--                                 $top_level_elements[] = $e;
--                         end; else then
--                                 $children_elements[ $e->$parent_field ][] = $e;
--                         end;
--                 end;

--                 $total_top = count( $top_level_elements );
--                 if ( $paging ) then
--                         $this->max_pages = ceil( $total_top / $per_page );
--                 end; else then
--                         $end = $total_top;
--                 end;

--                 if ( ! empty( $args[0]['reverse_top_level'] ) ) then
--                         $top_level_elements = array_reverse( $top_level_elements );
--                         $oldstart           = $start;
--                         $start              = $total_top - $end;
--                         $end                = $total_top - $oldstart;
--                 end;
--                 if ( ! empty( $args[0]['reverse_children'] ) ) then
--                         foreach ( $children_elements as $parent => $children ) then
--                                 $children_elements[ $parent ] = array_reverse( $children );
--                         end;
--                 end;

--                 foreach ( $top_level_elements as $e ) then
--                         $count++;

--                         // For the last page, need to unset earlier children in order to keep track of orphans.
--                         if ( $end >= $total_top && $count < $start ) then
--                                         $this->unset_children( $e, $children_elements );
--                         end;

--                         if ( $count < $start ) then
--                                 continue;
--                         end;

--                         if ( $count >= $end ) then
--                                 break;
--                         end;

--                         $this->display_element( $e, $children_elements, $max_depth, 0, $args, $output );
--                 end;

--                 if ( $end >= $total_top && count( $children_elements ) > 0 ) then
--                         $empty_array = array();
--                         foreach ( $children_elements as $orphans ) then
--                                 foreach ( $orphans as $op ) then
--                                         $this->display_element( $op, $empty_array, 1, 0, $args, $output );
--                                 end;
--                         end;
--                 end;

--                 return $output;
--         end;

--         --
--         -- Calculates the total number of root elements.
--         --
--         -- @since 2.7.0
--         --
--         -- @param array $elements Elements to list.
--         -- @return int Number of root elements.
--         --
--         public function get_number_of_root_elements( $elements ) then
--                 $num          = 0;
--                 $parent_field = $this->db_fields['parent'];

--                 foreach ( $elements as $e ) then
--                         if ( empty( $e->$parent_field ) ) then
--                                 $num++;
--                         end;
--                 end;
--                 return $num;
--         end;

--         --
--         -- Unsets all the children for a given top level element.
--         --
--         -- @since 2.7.0
--         --
--         -- @param object $element           The top level element.
--         -- @param array  $children_elements The children elements.
--         --
--         public function unset_children( $element, &$children_elements ) then
--                 if ( ! $element || ! $children_elements ) then
--                         return;
--                 end;

--                 $id_field = $this->db_fields['id'];
--                 $id       = $element->$id_field;

--                 if ( ! empty( $children_elements[ $id ] ) && is_array( $children_elements[ $id ] ) ) then
--                         foreach ( (array) $children_elements[ $id ] as $child ) then
--                                 $this->unset_children( $child, $children_elements );
--                         end;
--                 end;

--                 unset( $children_elements[ $id ] );
--         end;

end Inc_Class_Wp_Walker;
