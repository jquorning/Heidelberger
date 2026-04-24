--
--
--

with GNATCOLL.JSON;

with Php.Arrays;

with Helpers;
with Lists;
with Logging;

package body Php.JSON
is
   use Lists;

   -----------------
   -- JSON_Encode --
   -----------------

   function JSON_Encode
     (Value : Multi_Type; Flags : Integer := 0; Depth : Integer := 512)
      return String
   is
      use GNATCOLL.JSON;

      function To_JSON (Value : Multi_Type) return JSON_Value;

      function To_JSON (Value : Multi_Type) return JSON_Value is
      begin
         case Kind_Of (Value) is
            when Kind_Array                =>
               declare
                  A   : Array_Type renames As_Array (Value);
                  Obj : constant JSON_Value := Create_Object;
               begin
                  for B in A.Iterate loop
                     Obj.Set_Field (Key (B), To_JSON (Element (B)));
                  end loop;

                  return Obj;
               end;

            when Kind_String               =>
               return Create (As_String (Value));

            when Kind_Integer              =>
               return Create (As_Integer (Value));

            when Kind_List                 =>
               declare
                  A    : List_Type renames As_List (Value);
                  Arry : JSON_Array := GNATCOLL.JSON.Empty_Array;
               begin
                  for B of A loop
                     Append (Arry, Create (B));
                  end loop;

                  return Create (Arry);
               end;

            when Kind_Boolean              =>
               return Create (As_Boolean (Value));

            when Kind_Null | Kind_Callable =>
               return Create ("XXX-A04");
         end case;
      end To_JSON;

      JSON   : constant JSON_Value := To_JSON (Value);
      Result : constant String := Write (JSON, Compact => True);
   begin
      Logging.Log ("json_encode", Result);
      return Result;
   end JSON_Encode;

   -----------------
   -- JSON_Decode --
   -----------------

   function JSON_Decode
     (JSON : String; Associative : Boolean := False) return Array_Type is
   begin
      return As_Array (JSON_Decode (JSON));
   end JSON_Decode;

   -----------------
   -- JSON_Decode --
   -----------------

   function JSON_Decode
     (JSON : String; Associative : Boolean := False) return Multi_Type
   is
      use GNATCOLL.JSON;

      function Parse_Array (Value : JSON_Value) return Multi_Type;

      function Parse_Object (Value : JSON_Value) return Multi_Type;

      function Parse (Value : JSON_Value) return Multi_Type;

      -----------------
      -- Parse_Array --
      -----------------

      function Parse_Array (Value : JSON_Value) return Multi_Type is
         use Php.Arrays;

         Result : Array_Type;
         Count  : Natural := 0;
         Arry   : constant JSON_Array := Get (Value);
      begin
         for A of Arry loop
            Count := Count + 1;
            Array_Merge (Result, Build (Helpers.Image (Count), Parse (A)));
         end loop;
         return From_Array (Result);
      end Parse_Array;

      ------------------
      -- Parse_Object --
      ------------------

      function Parse_Object (Value : JSON_Value) return Multi_Type is
         procedure Handle
           (User_Object : in out Array_Type;
            Name        : UTF8_String;
            Value       : JSON_Value);

         ------------
         -- Handle --
         ------------

         procedure Handle
           (User_Object : in out Array_Type;
            Name        : UTF8_String;
            Value       : JSON_Value)
         is
            use Php.Arrays;
         begin
            Array_Merge (User_Object, Build (Name, Parse (Value)));
         end Handle;

         procedure Map_JSON_Object is new
           Gen_Map_JSON_Object (Mapped => Array_Type);

         Result : Array_Type;
      begin
         Map_JSON_Object (Value, Handle'Access, Result);

         return From_Array (Result);
      end Parse_Object;

      -----------
      -- Parse --
      -----------

      function Parse (Value : JSON_Value) return Multi_Type is
      begin
         case Kind (Value) is

            when JSON_Array_Type   =>
               return Parse_Array (Value);

            when JSON_Object_Type  =>
               return Parse_Object (Value);

            when JSON_String_Type  =>
               return From_String (Get (Value));

            when JSON_Boolean_Type =>
               return From_Boolean (Get (Value));

            when others            =>
               Logging.Log ("parse", Kind (Value)'Image);
               pragma Assert (False);

         end case;
      end Parse;

      Value : constant Read_Result := Read (JSON);
   begin
      if not Value.Success then
         Logging.Log
           ("json_decode",
            "failed with " & Format_Parsing_Error (Value.Error));
         return From_Null;
      end if;

      return Parse (Value.Value);
   end JSON_Decode;

end Php.JSON;
