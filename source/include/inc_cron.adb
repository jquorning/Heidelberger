--
-- WordPress Cron API
--
-- @package WordPress
--

package body Inc_Cron
is

   ------------------------------
   -- Wp_Schedule_Single_Event --
   ------------------------------

   procedure Wp_Schedule_Single_Event (Timestamp : Integer;
                                       Hook      : String;
                                       Args      : Array_Type := Empty_Array;
                                       Wp_Error  : Boolean    := False)
   is
      Unused : constant Boolean :=
        Wp_Schedule_Single_Event (Timestamp, Hook, Args, Wp_Error);
   begin
      null;
   end Wp_Schedule_Single_Event;

   -----------------------------
   -- Wp_Clear_Scheduled_Hook --
   -----------------------------

   procedure Wp_Clear_Scheduled_Hook (Hook     : String;
                                      Args     : Array_Type := Empty_Array;
                                      Wp_Error : Boolean    := False)
   is
      Unused : constant Boolean :=
        Wp_Clear_Scheduled_Hook (Hook, Args, Wp_Error);
   begin
      null;
   end Wp_Clear_Scheduled_Hook;

   ----------------------
   -- X_Set_Cron_Array --
   ----------------------

   procedure X_Set_Cron_Array (Cron     : Array_Type;
                               Wp_Error : Boolean := False)
   is
      Unused : constant Boolean :=
        X_Set_Cron_Array (Cron, Wp_Error);
   begin
      null;
   end X_Set_Cron_Array;

end Inc_Cron;
