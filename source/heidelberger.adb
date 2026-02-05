--
--
--

with HB_Server;
with Logging;

procedure Heidelberger is
begin
   Logging.Silence ("inc_plugins.apply_filters");
   Logging.Silence ("do_action");

   HB_Server.Start;
   HB_Server.Wait;
   HB_Server.Shutdown;
end Heidelberger;
