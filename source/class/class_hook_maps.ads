--
--
--

with Ada.Containers.Indefinite_Ordered_Maps;

-- with Arrays;

with Class_Hooks;

package Class_Hook_Maps
is

   ---------------
   -- Hook_Maps --
   ---------------

   package Hook_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Class_Hooks.Wp_Hook,
         "="          => Class_Hooks."=");

   --
   -- Normalizes filters set up before WordPress has initialized to WP_Hook objects.
   --
   -- The `filters` parameter should be an array keyed by hook name, with values
   -- containing either:
   --
   --  - A `WP_Hook` instance
   --  - An array of callbacks keyed by their priorities
   --
   -- Examples:
   --
   --     filters = array(
   --         "wp_fatal_error_handler_enabled" => array(
   --             10 => array(
   --                 array(
   --                     "accepted_args" => 0,
   --                     "function"      => function() then
   --                         return false;
   --                     end;,
   --                 ),
   --             ),
   --         ),
   --     );
   --
   -- @since 4.7.0
   --
   -- @param array filters Filters to normalize. See documentation above for details.
   -- @return WP_Hook[] Array of normalized filters.
   --
   -- static
   function Build_Preinitialized_Hooks (Filters : Hook_Maps.Map) -- Arrays.Array_Type)
                                        return Hook_Maps.Map;

end Class_Hook_Maps;
