with Hb_Server;

procedure Heidelberger is
begin
   Hb_Server.Start;
   Hb_Server.Wait;
   Hb_Server.Shutdown;
end Heidelberger;
