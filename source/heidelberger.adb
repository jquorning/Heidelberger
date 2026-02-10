--
--
--

with HB_Server;
with Logging;

procedure Heidelberger is
begin
   Logging.Silence ("preg_match");
   Logging.Silence ("preg_replace");
   Logging.Silence ("inc_plugins.apply_filters");
   Logging.Silence ("apply_filters");
   Logging.Silence ("x_do_query");
   -- Logging.Silence ("do_action");

   HB_Server.Start;
   HB_Server.Wait;
   HB_Server.Shutdown;
end Heidelberger;
