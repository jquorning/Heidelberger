--
--
--

with Arrays;
with Lists;

with Adi_Class_Wp_Screens;

with Inc_Class_Wp_Admin_Bar;
with Inc_Class_Wp_Dependency;
with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;
with Inc_Taxonomys;

package Wp_Common
is
   use Arrays;
   use Lists;

   function Is_Object (Post : Inc_Class_Wp_Posts.Wp_Post)
                       return Boolean
                       is (True);

   function Get_Object_Vars (Object : Inc_Class_Wp_Posts.Wp_Post)
                             return Array_Type is (Empty_Array);

   procedure Set (Item : Array_Type;
                  Key  : String;
                  Term : Inc_Class_Wp_Terms.Wp_Term_Array) is null;

   function Array_Keys (Arry : Inc_Class_Wp_Terms.Wp_Term_Array)
                        return List_Type
                        is (Empty_List);

   procedure Array_Unshift (Arry : in out Inc_Class_Wp_Terms.Wp_Term_Array;
                            S    : Inc_Class_Wp_Terms.Wp_Term)
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

   function Array_Fill_Keys (Keys  : List_Type;
                             Value : Boolean)
                             return Array_Type
                             is (Empty_Array);

   function To_List (List : List_Type)
                     return List_Type
                     is (Empty_List);

   function Is_Object (Admin_Bar : Inc_Class_Wp_Admin_Bar.Wp_Admin_Bar)
                      return Boolean
                      is (True);

   function Apply_Filters (Hook_Name : String;
                           Value     : Inc_Class_Wp_Terms.Wp_Term_Array;
                           Id        : String;
                           Taxonomy  : String;
                           A4        : Array_Type := Empty_Array)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);

   function Apply_Filters (Hook_Name  : String;
                           A1         : Inc_Class_Wp_Terms.Wp_Term_Array;
                           A2         : List_Type;
                           A3         : Array_Type;
                           A4         : Array_Type)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Inc_Class_Wp_Posts.Wp_Post)
                           return Boolean
                           is (True);

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Id        : Inc_Class_Wp_Posts.Post_Id)
                           return Array_Type
                           is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           B         : String;
                           C         : Inc_Class_Wp_Posts.Wp_Post)
                           return List_Type
                           is (Empty_List);

   function Apply_Filters (Hook_Name : String;
                           B         : String;
                           C         : Inc_Class_Wp_Posts.Wp_Post)
                           return String
                           is ("XXX-980");

   function Apply_Filters (Hook_Name : String;
                           B         : String;
                           A         : String;
                           C         : Inc_Class_Wp_Posts.Wp_Post)
                           return String
                           is ("XXX-981");

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Id        : Adi_Class_Wp_Screens.Wp_Screen;
                           Arg_4     : Boolean := False)
                           return Array_Type
                           is (Empty_Array);

end Wp_Common;
