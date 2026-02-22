--
--
--

package body Logging
is

   ---------
   -- Log --
   ---------

   procedure Log (Channel : String;
                  Message : String)
   is null;

   -------------
   -- Silence --
   -------------

   procedure Silence (Channel : String)
   is null;

end Logging;
