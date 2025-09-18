with Arrays;

with Inc_Class_Wp_Dependency;
with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;
with Inc_Taxonomys;

package Wp_Common
is
   use Arrays;

   procedure Set (Item : Array_Type; -- Inc_Taxonomys.Wp_Term_Array;
                  Key  : String;
                  Term : Inc_Class_Wp_Terms.Wp_Term_Array) is null;

   function Array_Keys (Arry : Inc_Class_Wp_Terms.Wp_Term_Array)
                        return List_Type
                        is (Empty_List);

   procedure Array_Unshift (Arry : in out Inc_Class_Wp_Terms.Wp_Term_Array;
                            S    : Inc_Class_Wp_Terms.Wp_Term)
                            is null;

   function Apply_Filters (A : String;
                           B : String;
                           C : Inc_Class_Wp_Posts.Wp_Post)
                           return List_Type
                           is (Empty_List);

   function In_Array (A      : Integer;
                      B      : Array_Type;
                      Strict : Boolean)
                      return Boolean
                      is (True);

   function Get_Array (Arry : Inc_Class_Wp_Terms.Wp_Term_Array;
                       Key  : String)
                       return Array_Type
                       is (Empty_Array);

   function Get_Term_Array (Arry : Inc_Class_Wp_Terms.Wp_Term_Array;
                            Key  : String)
                            return Inc_Class_Wp_Terms.Wp_Term;

   function Get (Post_Type : Inc_Class_Wp_Post_Type.Wp_Post_Type;
                 Key       : String)
                 return String
                 is ("XXX-240");

   function Array_Keys (Arry : Inc_Class_Wp_Dependency.Dependency_Map)
                        return List_Type
                        is (Empty_List);

   function Array_Diff (Arry  : String_Array;
                        Arrys : List_Type)
                        return Boolean
                        is (False);

   function Array_Search (Needle   : String;
                          Haystack : List_Type;
                          Strict   : Boolean := False)
                          return String
                          is ("XXX-330");

   function Array_Fill_Keys (Keys  : String_Array;
                             Value : Boolean)
                             return Array_Type
                             is (Empty_Array);

   function To_List (List : String_Array)
                     return List_Type
                     is (Empty_List);

end Wp_Common;
