with Ada.Text_IO;

package body Arrays.Io
is
   procedure Dump (Arry : Array_Type)
   is
      use Ada.Text_IO;
   begin
      for A in Arry.Iterate loop
         declare
            use Array_Maps;

            Rec : constant Multi_Type := Element (A);
         begin
            Put ("key: " & Key (A));
            Put ("  kind: " & Rec.Kind'Image);
            case Rec.Kind is
            when Kind_String =>
               Put ("  string: " & To_String (Rec.Str));
            when Kind_Integer =>
               Put ("  integer: " & Rec.Int'Image);
            when Kind_Null =>
               Put ("  null");
            when Kind_Boolean =>
               Put ("  boolean: " & Rec.Bool'Image);
            when Kind_Array =>
               Put ("  array");
            when Kind_List =>
               Put ("  list");
            when Kind_Callable =>
               Put ("  callable");
            end case;
            New_Line;
         end;
      end loop;
   end Dump;

end Arrays.Io;
