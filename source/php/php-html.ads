--
--
--

with Arrays;

package Php.HTML
is

   type Flag_Type is new Natural;

   ENT_QUOTES     : constant Flag_Type := 16#0001#;
   ENT_SUBSTITUTE : constant Flag_Type := 16#0002#;
   ENT_HTML404    : constant Flag_Type := 16#0004#;
   ENT_NOQUOTES   : constant Flag_Type := 16#0008#;
   ENT_XML1       : constant Flag_Type := 16#0010#;
   ENT_HTML401    : constant Flag_Type := 16#0020#;
   ENT_COMPAT     : constant Flag_Type := 16#0040#;
   -- Shold be or'ed together instead

   function HTML_Entity_Decode
              (Item     : String;
               Flags    : Flag_Type := ENT_QUOTES + ENT_SUBSTITUTE + ENT_HTML404;
               Encoding : String    := "")
               return String
               is ("XXX-312");

   function HTML_Entities (Item          : String;
                           Flags         : Flag_Type := ENT_QUOTES;
                           Encoding      : String  := "";
                           Double_Encode : Boolean := True)
                           return String
                           is ("XXX-462");

   function HTML_Special_Chars (Item          : String;
                                Flags         : Flag_Type := ENT_QUOTES +
                                                             ENT_SUBSTITUTE +
                                                             ENT_HTML401;
                                Encoding      : String := "";
                                Double_Encode : Boolean := True)
                                return String
                                is (Item);

   function URL_Encode (Item : String)
                        return String;

   function Get_Header
            return String;
   -- Get header set by Header. Not part of PHP.

   procedure Header (Header        : String;
                     Replace       : Boolean := True;
                     Response_Code : Integer := 0);

   procedure Header_Remove (Name : String)
   is null;

   function Headers_Sent (Filename : String  := "";
                          Line     : Integer := 0)
                          return Boolean
                          is (False);

   PHP_URL_SCHEME : constant Integer := 1; -- XXX guess
   PHP_URL_PATH   : constant Integer := 2;

   procedure Parse_Str (Item   : String;
                        Result : in out Arrays.Array_Type)
                        is null;

   function Parse_URL (URL       : String;
                       Component : Integer := -1)
                       return String
                       is ("XXX-781");

   function Parse_URL (URL       : String;
                       Component : Integer := -1)
                       return Arrays.Array_Type
                       is (Arrays.Empty_Array);

   function Raw_URL_Encode (Item : String)
                            return String;

   function URL_Decode (Item : String)
                        return String
                        is ("XXX-976");

   procedure Set_Cookie (Name      : String;
                         Value     : String  := "";
                         Expires   : Natural := 0;
                         Path      : String  := "";
                         Domain    : String  := "";
                         Secure    : Boolean := False;
                         HTTP_Only : Boolean := False)
                         is null;

   function Php_Sapi_Name return String
     is ("cgi");

   function PHP_SAPI return String
     renames Php_Sapi_Name;

end Php.HTML;
