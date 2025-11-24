
package body Hb_Common
is
   function To_Array (Item : String) return Array_Type is (Empty_Array);

   function Empty (Table : Array_Type) return Boolean is (True);

   function Count (Item : String) return String is ("XXX 8");

   function "abs" (List : Array_Type) return String is ("XXX 12");

   -----------
   -- Isset --
   -----------

   function Isset (Item : Array_Type)
                   return Boolean
                   is (True);

   -- function Isset (Arry : Array_Type;
   --                 Key  : String)
   --                 return Boolean
   -- is
   -- begin
   --    return Array_Maps.Has_Element (Arry.Find (Key));
   -- end Isset;

   function Isset (Item : String)
                   return Boolean
                   is (True);

end Hb_Common;
