--
--
--

with HB_Server;
with Logging;

procedure Heidelberger is
begin
   -- Logging.Silence ("inc_plugins.apply_filters");
   -- Logging.Silence ("do_action");
   -- Logging.Silence ("apply_filters");

   HB_Server.Start;
   HB_Server.Wait;
   HB_Server.Shutdown;
end Heidelberger;
