--
--
--

package Php.HTML
is

   type Flag_Type is new Natural;

   ENT_QUOTES     : constant Flag_Type := 16#0001#;
   ENT_SUBSTITUTE : constant Flag_Type := 16#0002#;
   ENT_HTML404    : constant Flag_Type := 16#0004#;
   ENT_NOQUOTES   : constant Flag_Type := 16#0008#;
   ENT_XML1       : constant Flag_Type := 16#0010#;
   ENT_HTML401    : constant Flag_Type := 16#0020#;
   -- Shold be or'ed together instead

   function HTML_Entity_Decode (Item     : String;
                                Flags    : Flag_Type;
                                Encoding : String := "")
                                return String
                                is ("XXX-312");

   function HTMLentities (Item          : String;
                          Flags         : Flag_Type := ENT_QUOTES;
                          Encoding      : String  := "";
                          Double_Encode : Boolean := True)
                          return String
                          is ("XXX-462");

   function HTMLspecialchars (Item          : String;
                              Flags         : Flag_Type := ENT_QUOTES +
                                                           ENT_SUBSTITUTE +
                                                           ENT_HTML401;
                              Encoding      : String := "";
                              Double_Encode : Boolean := True)
                              return String
                              is (Item);

   function URLencode (Item : String)
                       return String
                       is ("XXX-301");

   procedure Header (Header        : String;
                     Replace       : Boolean := True;
                     Response_Code : Integer := 0)
                     is null;

end Php.HTML;
