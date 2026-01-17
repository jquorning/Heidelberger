--
--
--

with Lists;

package Php.Echoing
is

   procedure Echo (Item : String);

   procedure Printf (Format : String;
                     Args   : Lists.List_Type);

   procedure Clear_Echo;
   function Get_Echo
            return String;

   procedure OB_Start
   is null;

   function OB_Get_Clean
            return String
            is ("XXX-015");

end Php.Echoing;
