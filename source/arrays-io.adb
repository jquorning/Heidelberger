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

            Rec : Array_Record := Element (A);
         begin
            Put ("key: " & Key (A));
            Put ("  kind: " & Rec.Kind'Image);
            case Rec.Kind is
            when Is_String =>
               Put ("  string: " & To_String (Rec.Str));
            when Is_Integer =>
               Put ("  integer: " & Rec.Int'Image);
            when Is_Null =>
               Put ("  null");
            when Is_Boolean =>
               Put ("  boolean: " & Rec.Bool'Image);
            when Is_Array =>
               Put ("  array");
            when Is_Callable =>
               Put ("  callable");
            end case;
            New_Line;
         end;
      end loop;
   end Dump;

end Arrays.Io;
