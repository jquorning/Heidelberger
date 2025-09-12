with Arrays;

with Inc_Class_Wp_Terms;
with Inc_Class_Posts;
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
                           C : Inc_Class_Posts.Wp_Post)
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

end Wp_Common;
