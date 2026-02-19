--
--
--

with Logging;
with UStrings;

package body Php.Multibyte
is

   Global_Internal_Encoding : UStrings.UString;

   function MB_Strlen (Item     : String;
                       Encoding : String)
                       return Natural
                       is (raise Program_Error with "not implemented");

   function MB_Substr (Item     : String;
                       Start    : Natural;
                       Length   : Natural;
                       Encoding : String := "")
                       return String
                       is (raise Program_Error with "not implemented");

   --------------------------
   -- MB_Internal_Encoding --
   --------------------------

   procedure MB_Internal_Encoding (Encoding : String)
   is
      use UStrings;
   begin
      Global_Internal_Encoding := +Encoding;
   end MB_Internal_Encoding;

   --------------------------
   -- MB_Internal_Encoding --
   --------------------------

   function MB_Internal_Encoding
            return String
   is
      use UStrings;
   begin
      Logging.Log ("mb_internal_encoding", -Global_Internal_Encoding);
      return -Global_Internal_Encoding;
   end MB_Internal_Encoding;

end Php.Multibyte;
