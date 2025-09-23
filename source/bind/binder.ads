with AWS.Response;
with AWS.Status;

package Binder
is
   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data;

end Binder;
