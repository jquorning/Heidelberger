--
--
--

package Php.Lists
is

   function In_Array (Needle   : String;
                      Haystack : List_Type;
                      Strict   : Boolean := False)
                      return Boolean;

   function Array_Merge (Left, Right : List_Type) return List_Type
      is (Left);

   function Array_Diff (Left, Right : List_Type) return List_Type
      is (Left);

   function Array_Diff (Left  : List_Type;
                        Right : String) return List_Type
      is (Left);

   function Array_Map (Item : String;
                       List : List_Type)
                       return List_Type is (Empty_List);

   procedure Array_Shift (List : in out List_Type);
   function Array_Shift (List : in out List_Type)
                         return String;

   procedure Array_Unshift (List : in out List_Type;
                            Item : String)
                            is null;

   function Array_Keys (List : List_Type)
                        return List_Type
                        is (Empty_List);

   function Array_Key_Exists (Key  : String;
                              Arry : List_Type)
                              return Boolean
                              is (False);

   function Array_Search (Needle   : String;
                          Haystack : List_Type;
                          Strict   : Boolean := False)
                          return String
                          is ("XXX-012");

   function Array_Combine (Keys   : List_Type;
                           Values : List_Type)
                           return Array_Type
                           is (Empty_Array);

   function Array_Pop (Arry : List_Type)
                       return String
                       is ("XXX-332");

   procedure Array_Pop (Arry : List_Type)
                        is null;

   function Array_Push (Arry  : List_Type;
                        Value : String)
                        return List_Type
                        is (Empty_List);

   function Array_Push (Arry  : List_Type;
                        Value : List_Type)
                        return Integer
                        is (1);

   function Array_Intersect (List   : List_Type;
                             List_2 : List_Type)
                             return List_Type
                             is (Empty_List);

   function Array_Reverse (List : List_Type)
                           return List_Type
                           is (Empty_List);

end Php.Lists;
