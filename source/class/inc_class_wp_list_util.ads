with Arrays;

package Inc_Class_Wp_List_Util
is
   use Arrays;
--
-- List utility.
--
-- Utility class to handle operations on an array of objects or arrays.
--
-- @since 4.7.0
--
-- #[AllowDynamicProperties]
   type Wp_List_Util is tagged
      record
        --
        -- The input array.
        --
        -- @since 4.7.0
        -- @var array
        --
        Input : Array_Type := Empty_Array;

        --
        -- The output array.
        --
        -- @since 4.7.0
        -- @var array
        --
        Output : Array_Type := Empty_Array;

        --
        -- Temporary arguments for sorting.
        --
        -- @since 4.7.0
        -- @var string[]
        --
        Orderby : Array_Type := Empty_Array;

      end record;

   --
   -- Constructor.
   --
   -- Sets the input array.
   --
   -- @since 4.7.0
   --
   -- @param array $input Array to perform operations on.
   --
   function X_Construct (Input : Array_Type)
                         return Wp_List_Util;

   --
   -- Plucks a certain field out of each element in the input array.
   --
   -- This has the same functionality and prototype of
   -- array_column() (PHP 5.5) but also supports objects.
   --
   -- @since 4.7.0
   --
   -- @param int|string $field     Field to fetch from the object or array.
   -- @param int|string $index_key Optional. Field from the element to use as keys
   --                              for the new array. Default null.
   -- @return array Array of found values. If `$index_key` is set, an array of
   --               found values with keys corresponding to `$index_key`. If
   --               `$index_key` is null, array keys from the original `$list` will
   --               be preserved in the results.
   --
   function Pluck (List      : Wp_List_Util;
                   Field     : String;
                   Index_Key : String) -- = null )
                   return Array_Type
                   is (Empty_Array);

end Inc_Class_Wp_List_Util;
