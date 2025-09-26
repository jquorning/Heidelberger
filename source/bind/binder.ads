with AWS.Response;
with AWS.Status;

with Arrays;

package Binder
is
   use Arrays;

   function Render (Request : in AWS.Status.Data)
                    return AWS.Response.Data;

   X_SERVER  : Array_Type := Empty_Array;
   X_POST    : Array_Type := Empty_Array;
   XX_GET    : Array_Type := Empty_Array;
   X_REQUEST : Array_Type := Empty_Array;
   X_COOKIE  : Array_Type := Empty_Array;

end Binder;
