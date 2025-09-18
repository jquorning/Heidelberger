--
-- Dependencies API: Scripts functions
--
-- @since 2.6.0
--
-- @package WordPress
-- @subpackage Dependencies
--

package Inc_Functions_Wp_Scripts
is

   --
   -- Helper function to output a _doing_it_wrong message when applicable.
   --
   -- @ignore
   -- @since 4.2.0
   -- @since 5.5.0 Added the `handle` parameter.
   --
   -- @param string function Function name.
   -- @param string handle   Optional. Name of the script or stylesheet that was
   --                         registered or enqueued too early. Default empty.
   --
   procedure X_Wp_Scripts_Maybe_Doing_It_Wrong (Funct  : String;
                                                Handle : String := "");

end Inc_Functions_Wp_Scripts;
