with AWS.Response;
with AWS.Status;

package Adm_Edit_Tags is

   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data;

end Adm_Edit_Tags;
