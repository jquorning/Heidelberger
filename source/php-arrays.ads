--
--
--

with Arrays;

package Php.Arrays
is
   use Arrays;

   function Array_Merge (Left, Right : Array_Type) return Array_Type
      is (Left);

   function Array_Merge (Arry_1, Arry_2, Arry_3 : Array_Type)
            return Array_Type
   is (Array_Merge (Array_Merge (Arry_1, Arry_2), Arry_3));

   function Array_Merge_Recursive (Left, Right : Array_Type)
                                   return Array_Type
                                   is (Left);

   function Array_Diff (Left, Right : Array_Type) return Array_Type
      is (Left);

   function Array_Diff_Key (Arry : Array_Type;
                            That : Array_Type)
                            return Array_Type
                            is (Empty_Array);

   function Array_Map (Item  : String;
                       Table : Array_Type)
                       return Array_Type is (Empty_Array);

   function Array_Map (Item  : String;
                       Table : Array_Type)
                       return List_Type is (Empty_List);

   function In_Array (Needle   : String;
                      Haystack : Array_Type;
                      Strict   : Boolean := False)
                      return Boolean is (False);

   procedure Array_Unshift (Arry : in out Array_Type;
                            S    : String) is null;

   function Array_Values (Arry : Array_Type)
                          return List_Type
                          is (Empty_List);

   function Array_Values (Arry : Array_Type)
                          return Array_Type
                          is (Empty_Array);

   function Array_Keys (Arry : Array_Type)
                        return Array_Type
                        is (Empty_Array);

   function Array_Keys (Arry : Array_Type)
                        return List_Type
                        is (Empty_List);

   function Array_Keys (Arry         : Array_Type;
                        Filter_Value : String;
                        Strict       : Boolean := False)
                        return List_Type
                        is (Empty_List);

   function Array_Key_Exists (Key  : String;
                              Arry : Array_Type)
                              return Boolean
                              is (False);

   function Array_Search (Needle   : String;
                          Haystack : Array_Type;
                          Strict   : Boolean := False)
                          return String
                          is ("XXX-315");

   function Array_Search (Needle   : String;
                          Haystack : Array_Type;
                          Strict   : Boolean := False)
                          return Integer
                          is (99);

   function Array_Intersect_Key (Arry   : Array_Type;
                                 Arry_2 : Array_Type)
                                 return Array_Type
                                 is (Empty_Array);

   function Array_Flip (Arry : Array_Type)
                        return Array_Type
                        is (Empty_Array);

   function Array_Flip (Arry : List_Type)
                        return Array_Type
                        is (Empty_Array);

   function Array_Fill_Keys (Keys  : Array_Type;
                             Value : Boolean)
                             return Array_Type
                             is (Empty_Array);

   function Array_Fill_Keys (Keys  : List_Type;
                             Value : Multi_Type)
                             return Array_Type
                             is (Empty_Array);

   ARRAY_FILTER_USE_KEY  : constant Integer := 47; -- arbitrary value
   ARRAY_FILTER_USE_BOTH : constant Integer := 48; -- arbitrary value

   type Filter_Callback_1 is access function (Item : String)
                                              return Boolean;
   type Filter_Callback_2 is access function (Item : Array_Type)
                                              return Boolean;

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_1 := null;
                          Mode     : Integer           := 0)
                          return Array_Type
                          is (Empty_Array);

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_1 := null;
                          Mode     : Integer          := 0)
                          return List_Type
                          is (Empty_List);

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_2; --  := null;
                          Mode     : Integer           := 0)
                          return Array_Type
                          is (Empty_Array);

   type Reduce_Callback is access function (Carry : String;
                                            Acc   : Array_Type)
                                            return String;

   function Array_Reduce (Arry     : Array_Type;
                          Callback : Reduce_Callback;
                          Initial  : String)
                          return String
                          is ("XXX-006");

   function Array_Combine (Keys   : Array_Type;
                           Values : Array_Type)
                           return Array_Type
                           is (Empty_Array);

   function Array_Column (Arry       : Array_Type;
                          Column_Key : String)
                          return Array_Type
                          is (Empty_Array);

   function Array_Pop (Arry : Array_Type)
                       return Integer
                       is (1);

   function Array_Push (Arry  : Array_Type;
                        Value : Integer)
                        return Integer
                        is (1);

   procedure Array_Push (Arry  : Array_Type;
                         Value : String)
                         is null;

   function Array_Slice (Arry   : Array_Type;
                         Offset : Natural;
                         Length : Natural)
                         return Array_Type;

   function Array_Splice (Arry   : in out Array_Type;
                          Offset : Integer;
                          Length : Integer := 0)
                          return Array_Type
                          is (Empty_Array);

   type Unique_Flags is (Sort_String);

   function Array_Unique (Arry  : Array_Type;
                          Flags : Unique_Flags := Sort_String)
                          return Array_Type
                          is (Empty_Array);

   function Array_Unique (Arry  : List_Type;
                          Flags : Unique_Flags := Sort_String)
                          return List_Type
                          is (Empty_List);

   function Array_Unique (Arry  : List_Type;
                          Flags : Unique_Flags := Sort_String)
                          return Array_Type
                          is (Empty_Array);

   function Array_Intersect (Arry    : Array_Type;
                             Array_2 : Array_Type)
                             return Array_Type
                             is (Empty_Array);

   function Array_Reverse (Arry          : Array_Type;
                           Preserve_Keys : Boolean := False)
                           return Array_Type
                           is (Empty_Array);

   function Array_Replace_Recursive (Arry    : Array_Type;
                                     Array_2 : Array_Type)
                                     return Array_Type
                                     is (Empty_Array);

end Php.Arrays;
