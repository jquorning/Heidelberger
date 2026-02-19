--
--
--

with GNATCOLL.JSON;

with Php.Arrays;

with Helpers;
with Logging;

package body Php.JSON
is

   -----------------
   -- JSON_Encode --
   -----------------

   function JSON_Encode (Value : Multi_Type;
                         Flags : Integer := 0;
                         Depth : Integer := 512)
                         return String
   is
      use GNATCOLL.JSON;

      JSON : JSON_Value;
   begin
      Logging.Log ("json_encode", "not implemented");
      return Write (JSON, Compact => True);
   end JSON_Encode;

   -----------------
   -- JSON_Decode --
   -----------------

   function JSON_Decode (JSON        : String;
                         Associative : Boolean := False)
                         return Array_Type
   is
      use GNATCOLL.JSON;

      function Parse_Array (Value : JSON_Value)
                            return Multi_Type;

      function Parse_Object (Value : JSON_Value)
                             return Multi_Type;

      function Parse (Value : JSON_Value)
                      return Multi_Type;

      -----------------
      -- Parse_Array --
      -----------------

      function Parse_Array (Value : JSON_Value)
                            return Multi_Type
      is
         use Php.Arrays;

         Result : Array_Type;
         Count  : Natural := 0;
         Arry   : constant JSON_Array := Get (Value);
      begin
         for A of Arry loop
            Count := Count + 1;
            Array_Merge (Result, Build (Helpers.Image (Count),
                                        As_Array (Parse (A))));
         end loop;
         return From_Array (Result);
      end Parse_Array;

      ------------------
      -- Parse_Object --
      ------------------

      function Parse_Object (Value : JSON_Value)
                             return Multi_Type
      is
         procedure Handle (User_Object : in out Array_Type;
                           Name        : UTF8_String;
                           Value       : JSON_Value);

         ------------
         -- Handle --
         ------------

         procedure Handle (User_Object : in out Array_Type;
                           Name        : UTF8_String;
                           Value       : JSON_Value)
         is
            use Php.Arrays;
         begin
            Array_Merge (User_Object, Build (Name, Parse (Value)));
         end Handle;

         procedure Map_JSON_Object is
           new Gen_Map_JSON_Object (Mapped => Array_Type);

         Result : Array_Type;
      begin
         Map_JSON_Object (Value, Handle'Access, Result);

         return From_Array (Result);
      end Parse_Object;

      -----------
      -- Parse --
      -----------

      function Parse (Value : JSON_Value)
                      return Multi_Type
      is
      begin
         case Kind (Value) is

         when JSON_Array_Type =>
            return Parse_Array (Value);

         when JSON_Object_Type =>
            return Parse_Object (Value);

         when JSON_String_Type =>
            return From_String (Get (Value));

         when others =>
            pragma Assert (False);

         end case;
      end Parse;

      Value : constant Read_Result := Read (JSON);
   begin
      if not Value.Success then
         Logging.Log ("json_decode",
                      "failed with " & Format_Parsing_Error (Value.Error));
         return Standard.Arrays.Empty_Array;
      end if;

      return As_Array (Parse (Value.Value));
   end JSON_Decode;

end Php.JSON;
