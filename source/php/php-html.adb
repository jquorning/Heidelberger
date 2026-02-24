--
--
--

with Ada.Text_IO; use Ada.Text_IO;

with AWS.URL;

with Logging;
with UStrings;

package body Php.HTML
is
   use Arrays;

   Static_Header : UStrings.UString;

   ----------------
   -- Get_Header --
   ----------------

   function Get_Header
            return String
   is
      use UStrings;

      Header : constant String := -Static_Header;
   begin
      Logging.Log ("get_header", "");
      Logging.Log ("get_header", Header);
      Static_Header := +"";
      return Header;
   end Get_Header;

   ------------
   -- Header --
   ------------

   procedure Header (Header        : String;
                     Replace       : Boolean := True;
                     Response_Code : Integer := 0)
   is
      use UStrings;
   begin
      Append (Static_Header, Header);
      Append (Static_Header, LF);
   end Header;

   ---------------
   -- Parse_URL --
   ---------------

   function Parse_URL (URL       : String;
                       Component : Component_Type := PHP_URL_ALL)
                       return Arrays.Array_Type
   is
      use AWS.URL;

      Obj : constant Object := Parse (URL);

      Result : Array_Type;
   begin
      Result.Append ("schema", From_String (Protocol_Name (Obj)));
      Result.Append ("host",   From_String (Host          (Obj)));
      Result.Append ("path",   From_String (Abs_Path      (Obj)));
      Result.Append ("query",  From_String (Query         (Obj)));
      return Result;
   end Parse_URL;

   ---------------
   -- Parse_URL --
   ---------------

   function Parse_URL (URL       : String;
                       Component : Component_Type)
                       return String
   is
      Result : constant Array_Type :=
        Parse_URL (URL, PHP_URL_ALL);
   begin
      case Component is
      when PHP_URL_SCHEME => return Get_As_String (Result, "scheme");
      when PHP_URL_PATH   => return Get_As_String (Result, "path");
      when PHP_URL_QUERY  => return Get_As_String (Result, "query");
      when PHP_URL_ALL    => raise Program_Error with "not implemented";
      end case;
   end Parse_URL;

   --------------------
   -- Raw_URL_Encode --
   --------------------

   function Raw_URL_Encode (Item : String)
                            return String
   is
   begin
      Put_Line ("raw_url_encode: " & Item);
      return Item;
   end Raw_URL_Encode;

   ----------------
   -- URL_Encode --
   ----------------

   function URL_Encode (Item : String)
                        return String
   is
   begin
      return Item;
   end URL_Encode;

end Php.HTML;
