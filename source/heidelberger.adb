--
--
--

with HB_Server;
with Logging;

procedure Heidelberger is
begin
   Logging.Silence ("preg_match");
   Logging.Silence ("preg_replace");
   Logging.Silence ("preg_replace_callback");
-- Logging.Silence ("preg_split");
   Logging.Silence ("inc_plugins.apply_filters");
   Logging.Silence ("apply_filters");
   Logging.Silence ("x_do_query");
   Logging.Silence ("ado.fetch_object");
   Logging.Silence ("ado.query2");
   Logging.Silence ("class_dependency.x_construct");
   Logging.Silence ("get_table_from_query");
   Logging.Silence ("find_marks");
   Logging.Silence ("check_safe_collation");
   Logging.Silence ("get_bloginfo");
   Logging.Silence ("get_results");
   Logging.Silence ("get_results_base");
   Logging.Silence ("get_table_charset");
   -- Logging.Silence ("do_action");

   HB_Server.Start;
   HB_Server.Wait;
   HB_Server.Shutdown;
end Heidelberger;
