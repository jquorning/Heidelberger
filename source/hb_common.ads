
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Wpdb;
with Inc_Class_Wp_Posts;
with Inc_Class_Wp_Post_Type;
with Inc_Class_Wp_Terms;
with Inc_Taxonomys;

package HB_Common
is
   use Ada.Strings.Unbounded;
   use Arrays;

   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   function "-" (Item : Unbounded_String) return String
      renames To_String;

   type List_Table is tagged null record;
   function Get_Pagenum (Item : List_Table) return Natural;

   procedure Prepare_Items (Table : in out List_Table);
   function Current_Action (Item : List_Table) return String;
   function Views (Item : List_Table) return String;
   function Search_Box (Item : List_Table; L : String; R : String) return String;
   function Display (Item : List_Table) return String;
   function Inline_Edit (Item : List_Table) return String;
   function Has_Items (Item : List_Table) return Boolean;
   function X_Get_List_Table (Item : String) return List_Table;

   function Get_Pagination_Arg (List : List_Table; Item : String) return Natural;

   function To_Array (Item : String) return Array_Type;
   function To_Array (Db : Inc_Class_Wpdb.Wpdb_Class;
                      S  : String)
                      return Array_Type is (Empty_Array);

   function Add_Query_Arg (Item : String; N : Natural; Sb : Unbounded_String)
      return Unbounded_String;
   function Add_Query_Arg (Item : String; N : String; I : String)
      return String is ("XXX-120");
   function Add_Query_Arg (Item : String; N : String) return String;
   function Add_Query_Arg (List : Array_Type; Sb : Unbounded_String)
      return Unbounded_String;

   function Absint (Item : Assoc_List) return String;
   function Absint (Item : String)     return String is ("XXX-213");

   function Array_Filter (List : Array_Type) return Assoc_List;
   function Array_Filter (List : Array_Type) return Array_Type is (Empty_Array);

   procedure Add_Filter (Arg_1, Arg_2 : String; Arg_3, Arg_4 : Integer);
   procedure Remove_Filter (Arg_1, Arg_2 : String; Arg_3 : Integer);

   procedure Set (Arr : in out Array_Type; Key : String; Value : String);
   procedure Set (Arr : in out Array_Type; Key : String; Value : Array_Type)
     is null;

   function Count (Item : String) return String;

   function Apply_Filters (Item : String;
                           S : String;
                           D : String;
                           X : Assoc_List)
                           return String
                           is ("XXX-220");

   function Apply_Filters (Item : String;
                           S    : String;
                           D    : String := "";
                           X    : String := "")
                           return String;

   function Apply_Filters (Item : String;
                           S    : Assoc_List;
                           D    : Assoc_List)
                           return Assoc_List;

   function Apply_Filters (Hook_Name : String;
                           A         : Array_Type;
                           B         : Array_Type)
                           return Array_Type
                           is (Empty_Array);

   function Apply_Filters (Item : String;
                           A    : Array_Type;
                           V    : String;
                           N    : String)
                           return Array_Type;

   function Apply_Filters (Item  : String;
                           Left  : Array_Type;
                           Right : Integer)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           Value     : Inc_Class_Wp_Terms.Wp_Term_Array;
                           Id        : String;
                           Taxonomy  : String)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);

   function Apply_Filters (Hook_Name : String;
                           Value     : access Integer;
                           Arg_2     : Positive;
                           Arg_3     : String;
                           Arg_4     : Boolean;
                           Arg_5     : String)
                           return Integer is (1);

   function Apply_Filters (Hook_Name : String;
                           Arg_2     : Array_Type;
                           Arg_3     : Array_Type;
                           Arg_4     : Array_Type)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           A1 : Inc_Class_Wp_Terms.Wp_Term_Array;
                           A2 : String;
                           A3 : String;
                           A4 : Array_Type)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);

   function Apply_Filters (Hook_Name : String;
                           S         : String;
                           D         : String;
                           P         : Array_Type)
                           return String
                           is ("XXX-221");

   function Apply_Filters (Hook_Name : String;
                           S         : String;
                           D         : String;
                           P         : List_Type)
                           return String
                           is ("XXX-230");

   function Apply_Filters (Hook_Name : String;
                           List      : List_Type)
                           return List_Type
                           is (Empty_List);

   function Apply_Filters (Hook_Name : String;
                           Arg       : Boolean)
                           return Boolean
                           is (True);

   function "abs" (List : Array_Type) return String;

   function Printf (Format : String;
                    Arg_1  : String;
                    Arg_2  : String := "";
                    Arg_3  : String := "";
                    Arg_4  : String := "")
                    return String
                    is ("XXX-310");

   function Sprintf (Format : String;
                     Arg_1 : String;
                     Arg_2 : String := "";
                     Arg_3 : String := "")
      return String is ("XXX-201");

   function Count (Al : Assoc_List) return Natural;

   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "") return String;
   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "")
                 return Array_Type;

   function Get_2 (Arry : Array_Type; Key_1, Key_2 : String)
                  return String is ("XXX-303");

   function Get_List (Arry : Array_Type; Key : String)
                      return List_Type
                      is (Empty_List);

   function Get (List : List_Type;
                 Key  : String)
                 return String
                 is ("XXX-220");

   function Get_Integer (Arry : Array_Type;
                         Key  : String)
                         return Integer
                         is (1);

   function Get (A   : String;
                 Key : String)
                 return String
                 is ("XXX-251");

   function Get (Post : Inc_Class_Wp_Post_Type.Wp_Post_Type;
                 Key  : String)
                 return String is ("XXX-250");

   function Is_Wp_Error (Ret : Boolean) return Boolean is (True);

   procedure Do_Action_Deprecated (I1 : String;
                                   A1 : Array_Type;
                                   V : String;
                                   I2 : String) is null;
   procedure Do_Action (Item_1 : String; Item_2 : String := "") is null;

   function Get_Cat_Name (Item : String) return String is ("XXX-91");

   function Wp_Is_Mobile return Boolean is (False);
   procedure Wp_Dropdown_Categories (A : Array_Type) is null;

   function Submit_Button (Text : String; V1 : String; V2 : String; X : Boolean)
     return String is ("XX-101");
   function Is_Taxonomy_Hierarchical (Taxonomy : String) return Boolean is (True);

   procedure Wp_Reset_Vars (A : Array_Type) is null;

   function Wp_Dashboard_Quick_Press (I : String := "") return String is ("XXX-110");
   function Get_Default_Comment_Status (S : String; E : String := "") return String
     is ("XXX-111");
   function Edit_Post  return String is ("XXX-113");
   function Write_Post return String is ("XXX-114");

   procedure Enqueue_Comment_Hotkeys_JS is null;

   type Time is null record;
   procedure Setcookie (N    : String;
                        Post : String;
                        Ts   : Time;
                        Path : String;
                        Dom  : String;
                        Ssl  : Boolean) is null;
   MEDIA_TRASH : Boolean := False;
   function Post_Preview return String is ("XXX-104");

   function Empty (A : String) return Boolean is (True);
   function Empty (Table : Array_Type) return Boolean;
   function Empty (Arry : Array_Type; Key : String) return Boolean is (False);

   function Apply_Filters (Item : String; S : String; D : Inc_Class_Wp_Posts.Wp_Post)
      return Boolean is (True);
   function Apply_Filters (Hook_Name : String;
                           Arg_2     : Array_Type;
                           Id        : Inc_Class_Wp_Posts.Post_Id)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           Arg_2     : Array_Type)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name  : String;
                           A1         : Inc_Class_Wp_Terms.Wp_Term_Array;
                           A2, A3, A4 : Array_Type)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);

   function Use_Block_Editor_For_Post (Post : Inc_Class_Wp_Posts.Wp_Post)
                                       return Boolean is (True);

   function Isset (Item : Array_Type) return Boolean;
   function Isset (Item : String) return Boolean;

   function X_Isset (Arry : Array_Type; Value : String) return Boolean is (True);

   procedure Unset (A : String) is null;
   function Wp_Get_Attachment_Metadata (Id : String; V : Boolean) return Array_Type
     is (Empty_Array);

   function Get_User_Meta (Id : Integer; Item : String; V : Boolean) return Boolean
      is (True);

   procedure Update_User_Meta (Id : Integer; Item : String; V : Boolean) is null;

   type Walker_Type is access procedure;

   procedure Echo (Item : String) is null;

   function In_Array (Taxonomy   : String;
                      Taxonomies : Inc_Taxonomys.Taxonomy_Array;
                      S          : Boolean)
                      return Boolean is (True);

   function In_Array (Key  : String;
                      Arry : String_Array;
                      S    : Boolean)
                      return Boolean is (True);

   function Isset (Arry : Array_Type;
                   Key  : String)
                   return Boolean
                   is (True);

end HB_Common;
