--
--
--

package Logging
is

   --
   --
   --
   procedure Log (Channel : String;
                  Message : String)
     with Inline_Always;

   --
   --
   --
   procedure Silence (Channel : String)
     with Inline_Always;

   --
   --
   --
   procedure Add_Time
     with Inline_Always;

end Logging;
