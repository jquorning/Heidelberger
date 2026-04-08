--
--
--

with Arrays;
with Lists;

package Php.Lists
is
   use Arrays;
   use Standard.Lists;

   function In_List (Needle   : String;
                     Haystack : List_Type;
                     Strict   : Boolean := False)
                     return Boolean;

   function List_Merge (Left, Right : List_Type)
                        return List_Type;

   function List_Merge (List_1, List_2, List_3 : List_Type)
                        return List_Type;

   function List_Diff (Left, Right : List_Type)
                       return List_Type;

   function List_Diff (Left  : List_Type;
                       Right : String)
                       return List_Type;

   type Filter_Callback is access function (Value : String)
                                            return Boolean;

   function List_Filter (List     : List_Type;
                         Callback : Filter_Callback := null)
                         return List_Type;

   function List_Fill (Start_Index : Integer;
                       Count       : Integer;
                       Value       : Multi_Type)
                       return List_Type;

   type Callable_20 is access function (Item : String)
                                        return String;

   type Callable_21 is access function (Item : Integer)
                                        return Integer;

   type Callable_22 is access function (Item : String;
                                        Base : Integer)
                                        return Integer;

   type Callable_23 is access function (Item   : String;
                                        Item_2 : String)
                                        return String;

   function List_Map (Callback : Callable_20;
                      List     : List_Type)
                      return List_Type
   is (raise Program_Error with "not implemented");

   function List_Map (Callback : Callable_21;
                      List     : List_Type)
                      return List_Type
   is (raise Program_Error with "not implemented");

   function List_Map (Callback : Callable_22;
                      List     : List_Type)
                      return List_Type
   is (raise Program_Error with "not implemented");

   function List_Map (Callback : Callable_23;
                      List     : List_Type)
                      return List_Type
   is (raise Program_Error with "not implemented");

   function List_Slice (List : List_Type;
                        First : Natural;
                        Last  : Natural)
                        return List_Type
   is (raise Program_Error with "not implemented");

   procedure List_Shift (List : in out List_Type);

   function List_Shift (List : in out List_Type)
                         return String;

   procedure List_Unshift (List : in out List_Type;
                           Item : String);

   function List_Keys (List : List_Type)
                       return List_Type;

   function List_Key_Exists (Key  : String;
                             List : List_Type)
                             return Boolean;

   function List_Search (Needle   : String;
                         Haystack : List_Type;
                         Strict   : Boolean := False)
                         return String
   is (raise Program_Error with "not implemented");

   function List_Combine (Keys   : List_Type;
                          Values : List_Type)
                          return Array_Type;

   function List_Pop (List : in out List_Type)
                      return String;

   procedure List_Pop (List : in out List_Type);

   function List_Push (List  : List_Type;
                       Value : String)
                       return List_Type;

   procedure List_Push (List  : in out List_Type;
                        Value : String);

   function List_Push (List  : List_Type;
                       Value : List_Type)
                       return Integer
   is (raise Program_Error with "not implemented");

   function List_Intersect (List   : List_Type;
                            List_2 : List_Type)
                            return List_Type;

   function List_Reverse (List : List_Type)
                          return List_Type;

   type Unique_Flags is (Sort_String);

   function List_Unique (List  : List_Type;
                         Flags : Unique_Flags := Sort_String)
                         return List_Type;

   function Get (List : List_Type;
                 Key  : String)
                 return String
   is (raise Program_Error with "not implemented");

   function Isset (List : List_Type;
                   Key  : String)
                   return Boolean;

end Php.Lists;
