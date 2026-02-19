--
-- WordPress List utility class
--
-- @package WordPress
-- @since 4.7.0
--

with Php.Arrays;
with Php.Lists;
with Php.Strings;

package body Class_List_Util
is
   --
   -- Constructor.
   --
   -- Sets the input array.
   --
   -- @since 4.7.0
   --
   -- @param array input Array to perform operations on.
   --
   -- public function __construct( input ) then

   function X_Construct (Input : Array_Type)
                         return Wp_List_Util
   is
      This : Wp_List_Util;
   begin
      This.Output := Input;
      This.Input  := Input;
      return This;
   end X_Construct;

--         --
--         -- Returns the original input array.
--         --
--         -- @since 4.7.0
--         --
--         -- @return array The input array.
--         --
--         public function get_input() then
--                 return this.input;
--         end;

   ----------------
   -- Get_Output --
   ----------------

   function Get_Output (This : Wp_List_Util)
            return Array_Type
   is
   begin
      return This.Output;
   end Get_Output;

   ------------
   -- Filter --
   ------------

   function Filter (This     : in out Wp_List_Util;
                    Args     : Array_Type := Empty_Array;
                    Operator : String     := "AND")
                    return Array_Type
   is
      use Php.Arrays;
      use Php.Lists;
      use Php.Strings;

      Operator_2 : constant String := Strtoupper (Operator);
   begin
      if Args.Is_Empty then
         return This.Output;
      end if;

      if not In_List (Operator_2, ["AND", "OR", "NOT"], True) then
         This.Output := Empty_Array;
         return This.Output;
      end if;

      declare
         Count    : constant Natural := Args.Length;
         Filtered : Array_Type;
      begin
         for A in This.Output.Iterate loop
            declare
               Key : constant String     := Arrays.Key (A);
               Obj : constant Array_Type := As_Array (Arrays.Element (A));
               Matched : Natural := 0;
            begin
               for B in Args.Iterate loop
                  declare
                     M_Key   : constant String     := Arrays.Key (B);
                     M_Value : constant Multi_Type := Arrays.Element (B);
                  begin
--                   if Kind_Of (Obj) = Kind_Array then
                        -- Treat object as an array.
                        if
                          Array_Key_Exists (M_Key, Obj) and then
                          (M_Value = Get (Obj, M_Key))
                        then
                           Matched := Matched + 1;
                        end if;
                     -- elsif ( is_object( obj ) ) then
                     --         -- Treat object as an object.
                     --         if ( isset( obj.thenm_keyend; ) && ( m_value == obj.thenm_keyend; ) ) then
                     --                 matched++;
                     --         end;
--                   end if;
                  end;
               end loop;

               if
                 ("AND" = Operator_2 and then Matched = Count) or else
                 ("OR"  = Operator_2 and then Matched  > 0)    or else
                 ("NOT" = Operator_2 and then 0 = Matched)
               then
                  Set (Filtered, Key, From_Array (Obj));
               end if;
            end;
         end loop;

         This.Output := Filtered;
      end;
      return This.Output;
   end Filter;

   ------------
   -- Filter --
   ------------

   procedure Filter (This     : in out Wp_List_Util;
                     Args     : Array_Type := Empty_Array;
                     Operator : String     := "AND")
   is
      Unused : constant Array_Type := Filter (This, Args, Operator);
   begin
      null;
   end Filter;

   -----------
   -- Pluck --
   -----------

   function Pluck (This      : in out Wp_List_Util;
                   Field     : String;
                   Index_Key : String := "(null)")
                   return Array_Type
   is
      Newlist : Array_Type;
   begin
      if Index_Key = "(null)" then
         --
         -- This is simple. Could at some point wrap array_column()
         -- if we knew we had an array of arrays.
         --
         for A in This.Output.Iterate loop
            declare
               Key   : constant String     := Arrays.Key (A);
               Value : constant Array_Type := As_Array (Arrays.Element (A));
            begin
               -- if ( is_object( value ) ) then
               --    newlist[ key ] = value.field;
               -- else
               Set (Newlist, Key, Get (Value, Field));
               -- end if;
            end;
         end loop;

         This.Output := Newlist;

         return This.Output;
      end if;

      --
      -- When index_key is not set for a particular item, push the value
      -- to the end of the stack. This is how array_column() behaves.
      --
      for A in This.Output.Iterate loop
         declare
            Value : constant Array_Type := As_Array (Element (A));
         begin
         -- if ( is_object( value ) ) then
         --    if ( isset( value.index_key ) ) then
         --       newlist[ value.index_key ] = value.field;
         --    else
         --       newlist[] = value.field;
         --    end if;
         -- else
            if Isset (Value, Index_Key) then
               Set (Newlist, Get_As_String (Value, Index_Key),
                    Get (Value, Field));
            else
               Newlist.Append ("XXX-976", Get (Value, Field));
            end if;
         -- end if;
         end;
      end loop;

      This.Output := Newlist;

      return This.Output;
   end Pluck;

   -----------
   -- Pluck --
   -----------

   procedure Pluck (This      : in out Wp_List_Util;
                    Field     : String;
                    Index_Key : String := "(null)")
   is
      Unused : constant Array_Type := Pluck (This, Field, Index_Key);
   begin
      null;
   end Pluck;

--         --
--         -- Sorts the input array based on one or more orderby arguments.
--         --
--         -- @since 4.7.0
--         --
--         -- @param string|array orderby       Optional. Either the field name to order by or an array
--         --                                    of multiple orderby fields as orderby => order.
--         -- @param string       order         Optional. Either 'ASC' or 'DESC'. Only used if orderby
--         --                                    is a string.
--         -- @param bool         preserve_keys Optional. Whether to preserve keys. Default false.
--         -- @return array The sorted array.
--         --
--         public function sort( orderby = array(), order = 'ASC', preserve_keys = false ) then
--                 if ( empty( orderby ) ) then
--                         return this.output;
--                 end;

--                 if ( is_string( orderby ) ) then
--                         orderby = array( orderby => order );
--                 end;

--                 foreach ( orderby as field => direction ) then
--                         orderby[ field ] = 'DESC' === strtoupper( direction ) ? 'DESC' : 'ASC';
--                 end;

--                 this.orderby = orderby;

--                 if ( preserve_keys ) then
--                         uasort( this.output, array( this, 'sort_callback' ) );
--                 end; else then
--                         usort( this.output, array( this, 'sort_callback' ) );
--                 end;

--                 this.orderby = array();

--                 return this.output;
--         end;

--         --
--         -- Callback to sort an array by specific fields.
--         --
--         -- @since 4.7.0
--         --
--         -- @see WP_List_Util::sort()
--         --
--         -- @param object|array a One object to compare.
--         -- @param object|array b The other object to compare.
--         -- @return int 0 if both objects equal. -1 if second object should come first, 1 otherwise.
--         --
--         private function sort_callback( a, b ) then
--                 if ( empty( this.orderby ) ) then
--                         return 0;
--                 end;

--                 a = (array) a;
--                 b = (array) b;

--                 foreach ( this.orderby as field => direction ) then
--                         if ( ! isset( a[ field ] ) || ! isset( b[ field ] ) ) then
--                                 continue;
--                         end;

--                         if ( a[ field ] == b[ field ] ) then
--                                 continue;
--                         end;

--                         results = 'DESC' === direction ? array( 1, -1 ) : array( -1, 1 );

--                         if ( is_numeric( a[ field ] ) && is_numeric( b[ field ] ) ) then
--                                 return ( a[ field ] < b[ field ] ) ? results[0] : results[1];
--                         end;

--                         return 0 > strcmp( a[ field ], b[ field ] ) ? results[0] : results[1];
--                 end;

--                 return 0;
--         end;
-- end;

end Class_List_Util;
