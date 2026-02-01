--
--
--

with Arrays;
with Lists;

with Class_Dependency;
with Class_Posts;
with Class_Post_Type;
with Class_Taxonomy;
with Class_Terms;
with Inc_Taxonomys;

package Helpers_3
is
   use Arrays;
   use Lists;

   function In_Array (T : Integer;
                      A : Class_Taxonomy.Int_Arrays.Vector;
                      S : Boolean)
                      return Boolean
                      is (raise Program_Error with "not implemented");

   function Is_Object (Post : Class_Posts.Wp_Post)
                       return Boolean
                       is (True);

   function Get_Object_Vars (Object : Class_Posts.Wp_Post)
                             return Array_Type is (Empty_Array);

   procedure Set (Item : Array_Type;
                  Key  : String;
                  Term : Class_Terms.Wp_Term_Array) is null;

   function Array_Keys (Arry : Class_Terms.Wp_Term_Array)
                        return List_Type
                        is (Empty_List);

   procedure Array_Unshift (Arry : in out Class_Terms.Wp_Term_Array;
                            S    : Class_Terms.Wp_Term)
                            is null;

   function In_Array (Taxonomy   : String;
                      Taxonomies : Inc_Taxonomys.Taxonomy_Array;
                      S          : Boolean)
                      return Boolean is (True);

   function In_Array (A      : Integer;
                      B      : Array_Type;
                      Strict : Boolean)
                      return Boolean
                      is (True);

   function Get_Array (Arry : Class_Terms.Wp_Term_Array;
                       Key  : String)
                       return Array_Type
                       is (Empty_Array);

   function Get_Term_Array (Arry : Class_Terms.Wp_Term_Array;
                            Key  : String)
                            return Class_Terms.Wp_Term;

   function Get (Post_Type : Class_Post_Type.Wp_Post_Type;
                 Key       : String)
                 return String
                 is ("XXX-240");

   function Array_Keys (Arry : Class_Dependency.Dependency_Map)
                        return List_Type
                        is (Empty_List);

   function Array_Fill_Keys (Keys  : List_Type;
                             Value : Boolean)
                             return Array_Type
                             is (Empty_Array);

end Helpers_3;
