with AWS.Response;
with AWS.Status;

package HB_Edit is

   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data;

end HB_Edit;
