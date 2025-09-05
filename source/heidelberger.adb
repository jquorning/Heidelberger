with HB_Server;

procedure Heidelberger is
begin
   HB_Server.Start;
   HB_Server.Wait;
   HB_Server.Shutdown;
end Heidelberger;
