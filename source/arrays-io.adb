-- with Ada.Strings.Unbounded;
with Ada.Text_IO;

with UStrings;
with Helpers;

package body Arrays.IO
is

   function Dump_Array (Arry : Array_Type)
            return String;

   function Dump_Array (Arry : Array_Type)
            return String
   is
--    use Ada.Strings.Unbounded;
      use UStrings;

      Buffer : Unbounded_String;
      First  : Boolean := True;
   begin
      Append (Buffer, "[");
      for A in Arry.Iterate loop
         declare
            use Array_Maps;

            Rec : constant Multi_Type := Element (A);
         begin
            if not First then
               Append (Buffer, ", ");
            end if;
            First := False;
            Append (Buffer, "'" & Key (A) & "'");
            Append (Buffer, "(" & Rec.Kind'Image & ") ");
            case Rec.Kind is
            when Kind_String =>
               Append (Buffer, """" & To_String (Rec.Str) & """");
            when Kind_Integer =>
               Append (Buffer, Helpers.Image (Rec.Int));
            when Kind_Null =>
               Append (Buffer, "<>");
            when Kind_Boolean =>
               Append (Buffer, Rec.Bool'Image);
            when Kind_Array =>
               Append (Buffer, Dump_Array (Rec.Arry.all));
            when Kind_List =>
               Append (Buffer, "<list>");
            when Kind_Callable =>
               Append (Buffer, "<callable>");
            end case;
         end;
      end loop;
      Append (Buffer, "]" & ASCII.LF);
      return -Buffer;
   end Dump_Array;

   ----------
   -- Dump --
   ----------

   procedure Dump (Arry : Array_Type)
   is
      use Ada.Text_IO;
   begin
      Put_Line (Dump_Array (Arry));
      -- for A in Arry.Iterate loop
      --    declare
      --       use Array_Maps;

      --       Rec : constant Multi_Type := Element (A);
      --    begin
      --       Put ("key: " & Key (A));
      --       Put ("  kind: " & Rec.Kind'Image);
      --       case Rec.Kind is
      --       when Kind_String =>
      --          Put ("  string: " & To_String (Rec.Str));
      --       when Kind_Integer =>
      --          Put ("  integer: " & Rec.Int'Image);
      --       when Kind_Null =>
      --          Put ("  null");
      --       when Kind_Boolean =>
      --          Put ("  boolean: " & Rec.Bool'Image);
      --       when Kind_Array =>
      --          Put ("  array");
      --       when Kind_List =>
      --          Put ("  list");
      --       when Kind_Callable =>
      --          Put ("  callable");
      --       end case;
      --       New_Line;
      --    end;
      -- end loop;
   end Dump;

end Arrays.IO;
