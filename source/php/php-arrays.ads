--
--
--

with Arrays;
with Lists;

package Php.Arrays
is
   use Standard.Arrays;
   use Lists;

   function Array_Combine (Keys   : Array_Type;
                           Values : Array_Type)
                           return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Combine (Keys   : List_Type;
                           Values : List_Type)
                           return Array_Type;

   function Array_Column (Arry       : Array_Type;
                          Column_Key : String)
                          return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Diff_Assoc (Left  : Array_Type;
                              Right : Array_Type)
                              return Array_Type
   is (raise Program_Error with "not implemented");

   procedure Array_Merge (Left  : in out Array_Type;
                          Right : Array_Type);

   function Array_Merge (Left  : Array_Type;
                         Right : Array_Type)
                         return Array_Type;

   function Array_Merge (Arry_1 : Array_Type;
                         Arry_2 : Array_Type;
                         Arry_3 : Array_Type)
                         return Array_Type;

   function Array_Merge_Recursive (Left, Right : Array_Type)
                                   return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Diff (Left  : Array_Type;
                        Right : Array_Type)
                        return Array_Type;

   function Array_Diff_Key (Arry : Array_Type;
                            That : Array_Type)
                            return Array_Type
   is (raise Program_Error with "not implemented");

   type Callable_20 is access function (Item : String)
                                        return String;

   type Callable_21 is access function (Item : String;
                                        Base : Integer)
                                        return Integer;

   type Callable_22 is access function (Value : Integer)
                                        return Integer;

   type Callable_23 is access function (Item   : String;
                                        Item_2 : String)
                                        return String;

   function Array_Map (Callback : Callable_20;
                       Arry     : Array_Type)
                       return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Map (Callback : Callable_22;
                       Arry     : Array_Type)
                       return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Map (Callback : Callable_20;
                       Arry     : Array_Type)
                       return List_Type
   is (raise Program_Error with "not implemented");

   function Array_Map (Callback : Callable_21;
                       Arry     : Array_Type)
                       return List_Type
   is (raise Program_Error with "not implemented");

   function Array_Map (Callback : Callable_20;
                       List     : List_Type)
                       return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Map (Callback : Callable_23;
                       List     : List_Type)
                       return Array_Type
   is (raise Program_Error with "not implemented");

   function In_Array (Needle   : String;
                      Haystack : Array_Type;
                      Strict   : Boolean := False)
                      return Boolean;

   function In_Array (A      : Integer;
                      B      : Array_Type;
                      Strict : Boolean)
                      return Boolean
   is (raise Program_Error with "not implemented");

   procedure Array_Unshift (Arry : in out Array_Type;
                            S    : String);

   procedure Array_Unshift (Arry : in out Array_Type;
                            S    : Array_Type);

   function Array_Values (Arry : Array_Type)
                          return List_Type;

   function Array_Values (Arry : Array_Type)
                          return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Keys (Arry : Array_Type)
                        return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Keys (Arry : Array_Type)
                        return List_Type;

   function Array_Keys (Arry         : Array_Type;
                        Filter_Value : String;
                        Strict       : Boolean := False)
                        return List_Type
   is (raise Program_Error with "not implemented");

   function Array_Key_Exists (Key  : String;
                              Arry : Array_Type)
                              return Boolean;

   function Array_Search (Needle   : String;
                          Haystack : Array_Type;
                          Strict   : Boolean := False)
                          return String
   is (raise Program_Error with "not implemented");

   function Array_Search (Needle   : String;
                          Haystack : Array_Type;
                          Strict   : Boolean := False)
                          return Integer
                          is (99);

   function Array_Intersect_Key (Arry   : Array_Type;
                                 Arry_2 : Array_Type)
                                 return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Flip (Arry : Array_Type)
                        return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Flip (Arry : List_Type)
                        return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Fill_Keys (Keys  : Array_Type;
                             Value : Boolean)
                             return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Fill_Keys (Keys  : List_Type;
                             Value : Multi_Type)
                             return Array_Type
   is (raise Program_Error with "not implemented");

   function Array_Fill_Keys (Keys  : List_Type;
                             Value : Boolean)
                             return Array_Type
   is (raise Program_Error with "not implemented");

   ARRAY_FILTER_USE_KEY  : constant Integer := 47; -- arbitrary value
   ARRAY_FILTER_USE_BOTH : constant Integer := 48; -- arbitrary value

   type Filter_Callback_1 is access function (Item : String)
                                              return Boolean;
   type Filter_Callback_2 is access function (Item : Array_Type)
                                              return Boolean;

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_1 := null;
                          Mode     : Integer           := 0)
                          return Array_Type;

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_1 := null;
                          Mode     : Integer          := 0)
                          return List_Type
   is (raise Program_Error with "not implemented");

   function Array_Filter (Arry     : Array_Type;
                          Callback : Filter_Callback_2; --  := null;
                          Mode     : Integer           := 0)
                          return Array_Type
   is (raise Program_Error with "not implemented");

   type Reduce_Callback is access function (Carry : String;
                                            Acc   : Array_Type)
                                            return String;

   function Array_Reduce (Arry     : Array_Type;
                          Callback : Reduce_Callback;
                          Initial  : String)
                          return String
   is (raise Program_Error with "not implemented");

   type Reduce_Callback_2 is not null access function (Carry : Integer;
                                                       Item  : String)
                                                       return Integer;

   function Array_Reduce (Arry     : Array_Type;
                          Callback : Reduce_Callback_2;
                          Initial  : Integer)
                          return Integer
   is (raise Program_Error with "not implemented");

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

   function Array_Intersect (Arry    : Array_Type;
                             Array_2 : Array_Type)
                             return Array_Type;

   function Array_Reverse (Arry          : Array_Type;
                           Preserve_Keys : Boolean := False)
                           return Array_Type;

   function Array_Replace_Recursive (Arry    : Array_Type;
                                     Array_2 : Array_Type)
                                     return Array_Type
                                     is (Empty_Array);

   type Unique_Flags is (Sort_String);

   function Array_Unique (Arry  : Array_Type;
                          Flags : Unique_Flags := Sort_String)
                          return Array_Type;

   type Alter_Function is
     not null access procedure
       (Container : in out Array_Type;
        Key       : String;
        Value     : Multi_Type;
        Arg       : Multi_Type);

   procedure Array_Walk
     (Arry     : in out Array_Type;
      Callback : Alter_Function;
      Arg      : Multi_Type := From_Null);

   function Isset (Arry : Array_Type;
                   Key  : Integer)
                   return Boolean;

   function Isset (Item : Array_Type)
                   return Boolean;

   function Empty (Table : Array_Type)
                   return Boolean;

   CASE_UPPER : constant Integer := 1;
   CASE_LOWER : constant Integer := 2;

   function Array_Change_Key_Case (Arry : Array_Type;
                                   Cas  : Integer := CASE_LOWER)
                                   return Array_Type;

   procedure Arsort (Arry : in out Array_Type)
   is null;

end Php.Arrays;
