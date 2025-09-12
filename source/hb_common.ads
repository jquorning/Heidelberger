
with Ada.Strings.Unbounded;

with Arrays;

with Inc_Class_Posts;
with Inc_Class_Wpdb;
with Inc_Class_Wp_Terms;
with Inc_Class_Wp_Post_Type;
with Inc_Taxonomys;
with Inc_Class_Posts;

package HB_Common
is
   use Ada.Strings.Unbounded;
   use Arrays;

   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   function "-" (Item : Unbounded_String) return String
      renames To_String;

   -- type Cap_Type is
   --    record
   --       Edit_Posts   : Boolean := True;
   --       Create_Posts : Boolean := True;
   --       Manage_Terms : Boolean := True;
   --       Edit_Terms   : Boolean := True;
   --       Delete_Terms : Boolean := True;
   --       Assign_Terms : Boolean := True;
   --    end record;

   -- type Lab_Type is
   --    record
   --       Name              : Unbounded_String;
   --       Filter_Items_List : Unbounded_String;
   --       Items_List_Navigation  : Unbounded_String;
   --       Name_Field_Description : Unbounded_String;
   --       Items_List   : Unbounded_String;
   --       Add_New      : Unbounded_String;
   --       Add_New_Item : Unbounded_String;
   --       Search_Items : Unbounded_String;
   --       Edit_Items   : Unbounded_String;
   --       Edit_Item    : Unbounded_String;
   --       Slug_Field_Description : Unbounded_String;
   --       Parent_Field_Description : Unbounded_String;
   --       Parent_Item : Unbounded_String;
   --    end record;

   -- type Post_Rec is
   --    record
   --       Cap       : Cap_Type;
   --       Post_Type : Unbounded_String;
   --       Labels    : Lab_Type;
   --       Show_In_Menu : Boolean;
   --    end record;

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

   function Typenow return String;

   procedure Wp_Die (Why : String; Sub : String := ""; Code : Integer := 0) is null;

   procedure Check_Admin_Referer (Item : String; Item_2 : String := "");

--   function To_List (List : List_Type) return Assoc_List;
   function Get_Pagination_Arg (List : List_Type; Item : String) return Natural;
   function Get_Pagination_Arg (List : List_Table; Item : String) return Natural;

   function To_Array (Item : String) return Array_Type;
   function To_Array (Db : Inc_Class_Wpdb.Wpdb_Class;
                      S  : String)
                      return Array_Type is (Empty_Array);

   function Wp_Get_Referer return String is ("XXX-213");
   function Remove_Query_Arg  (List : List_Type;
                               Item : String)
                               return String
                               is ("XXX-214");

   function Remove_Query_Arg  (Arry : Array_Type;
                               Item : String)
                               return String
                               is ("XXX-221");

   function Admin_URL (Item : String) return String;

--   function Get_Post_Status_Object (N : Integer) return Boolean;

--   type Statement_Type is null record;
--   type DB_Type is tagged null record;

--   function Get_Col (Db : DB_Type; Statement : Statement_Type) return Array_Type;
--   function Prepare (Db : DB_Type; Sql : String; Arg_1, Arg_2 : String) return Statement_Type;
   Wpdb : Inc_Class_Wpdb.Wpdb_Class; -- return DB_Type;

   procedure Wp_Redirect (Item : String) is null;

   function Wp_Check_Post_Lock (Post_Id : Assoc_Type) return Boolean is (True);
   function Wp_Check_Post_Lock (Post_Id : String)     return Integer is (1);
   function Wp_Trash_Post      (Post_Id : Assoc_Type) return Boolean is (True);
   function Wp_Trash_Post      (Post_Id : String)     return Boolean is (True);

   function Add_Query_Arg (Item : String; N : Natural; Sb : Unbounded_String)
      return Unbounded_String;
   function Add_Query_Arg (Item : String; N : String; I : String)
      return String is ("XXX-120");
   function Add_Query_Arg (Item : String; N : String) return String;
   function Add_Query_Arg (List : Array_Type; Sb : Unbounded_String)
      return Unbounded_String;

   procedure Wp_Enqueue_Script (Item : String) is null;
   procedure Wp_Enqueue_Style  (Item : String) is null;

   function Absint (Item : Assoc_List) return String;
   function Absint (Item : String)     return String is ("XXX-213");

   function Array_Filter (List : Array_Type) return Assoc_List;
   function Array_Filter (List : Array_Type) return Array_Type is (Empty_Array);

   procedure Add_Filter (Arg_1, Arg_2 : String; Arg_3, Arg_4 : Integer);
   procedure Remove_Filter (Arg_1, Arg_2 : String; Arg_3 : Integer);

   function Wp_Delete_Attachment (Item : Assoc_Type;
                                  V    : Boolean := False) return Boolean is (True);
   function Wp_Delete_Attachment (Id : String;
                                  V  : Boolean := False) return Boolean is (True);
   function Wp_Delete_Post (Item : Assoc_Type; V : Boolean := False)
      return Boolean is (True);
   function Wp_Delete_Post (Item : String; V : Boolean := False)
      return Boolean is (True);

   function Bulk_Edit_Posts (Item : Array_Type) return Array_Type;

   procedure Set (Arr : in out Array_Type; Key : String; Value : String);
   procedure Set (Arr : in out Array_Type; Key : String; Value : Array_Type)
     is null;

   function Count (Item : String) return String;

   type Screen_Id is new Integer;
   type Screen_Type is tagged
      record
         Id : Screen_Id;
      end record;
   type Screen_Access is access all Screen_Type;
   function Get_Current_Screen return Screen_Access;
   procedure Add_Help_Tab (Screen : in out Screen_Type; List : Array_Type);
   procedure Set_Help_Sidebar (Screen : in out Screen_Type; Item : String);
   procedure Set_Screen_Reader_Content (Screen : in out Screen_Type; List : Array_Type);

   procedure Add_Screen_Option;

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

   function Wp_Unslash (Item : String) return String is ("XXX-215");

   X_SERVER  : Array_Type := Empty_Array;
   X_POST    : Array_Type := Empty_Array;
   XX_GET    : Array_Type := Empty_Array;
   X_REQUEST : Array_Type := Empty_Array;
   X_COOKIE  : Array_Type := Empty_Array;
   GLOBALS   : Array_Type := Empty_Array;

   procedure Add_Screen_Option (Item : String; List : Array_Type);

   function "abs" (List : Array_Type) return String;

   function ESC_HTML (Item : String) return String;
   function ESC_URL  (Item : String) return String;
--   function ESC_Attr (AL : Assoc_List) return String;
   function ESC_Attr (AL : String) return String;
--   function ESC_Attrl (AL : Assoc_List) return String;

   function Printf (Format : String; Arg_1 : String) return String;

   function Get_Search_Query return String;

   function Sprintf (Format : String; Arg_1 : String; Arg_2 : String := "")
      return String is ("XXX-201");

   function Number_Format_I18n (N : Integer) return String;
   function Wp_Nonce_URL (Url : String; Item : String) return String is ("XXX-216");
   function Count (Al : Assoc_List) return Natural;

--   function Get_Post_Type_Object (Item : Post_Rec) return String;
--   function Get_Post_Type_Object (Item : String) return Post_Rec;
--   function Get_Post_Type_Object (Item : String) return String;
--   function Get_Post_Type (Item : Assoc_Type) return Post_Rec;

   function Get_Edit_Post_Link (Id : Assoc_Type; Item : String := "") return String;
   function Get_Edit_Post_Link (Id   : Integer;
                                Item : String := "")
                                return String
                                is ("XXX-250");

   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "") return String;
   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "")
                 return Array_Type;
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

   -- type Count_Message_Type is
   --    record
   --       Count   : Natural;
   --       Message : Unbounded_String;
   --    end record;

--   function As_Count_Message (List : Array_Type) return Count_Message_Type;

--   type Lab_Record is
--      record
--         Name : Unbounded_String;
--      end record;

   -- type Tax_Rec is
   --    record
   --       Labels : Lab_Type;  --  Lab_Record;
   --       Name   : Unbounded_String;
   --       Cap    : Cap_Type;
   --       Show_In_Quick_Edit : Boolean;
   --       Hierarchical : Boolean;
   --    end record;

   function Taxnow return String;
--   function Get_Taxonomy (Item : String) return Tax_Rec;
--   function Get_Taxonomies (list : Array_Type) return Tax_Rec;
   function Wp_Insert_Term (Item : String; Item2 : String; Arr : Array_Type)
                            return Boolean
                            is (True);
   -- Get (X_Post, "tag-name"), Taxonomy, X_POST);
   function Is_Wp_Error (Ret : Boolean) return Boolean is (True);
   procedure Wp_Delete_Term (Tag : Integer; Taxonomy : String) is null;
   procedure Wp_Delete_Terms (Tag : Integer; Taxonomy : String) is null;

--   type Term_Type is null record;
--   function Get_Term (Id : Integer; Tax : String := "") return Term_Type;
   function "not" (Term : Inc_Class_Wp_Terms.Wp_Term)
                   return Boolean
                   is (False);

   function Sanitize_URL (Item : String) return String;
   function Get_Edit_Term_Link (Id : Integer; Taxonomy : String; Post_Type : String)
                               return String;
   function Wp_Update_Term (Id : Natural; Taxonomy : String; Arr : Array_Type)
                            return Boolean
                            is (True);

   function Is_Plugin_Active (Item : String) return Boolean;

   procedure Do_Action_Deprecated (I1 : String;
                                   A1 : Array_Type;
                                   V : String;
                                   I2 : String) is null;
   procedure Do_Action (Item_1 : String; Item_2 : String := "") is null;
   procedure Wp_Nonce_Field (I1, I2 : String) is null;

   function Get_Cat_Name (Item : String) return String is ("XXX-91");
--   function Get_Option (Item : String) return String is ("XXX-92");

   function Wp_Is_Mobile return Boolean is (False);
   procedure Wp_Dropdown_Categories (A : Array_Type) is null;

   function Submit_Button (Text : String; V1 : String; V2 : String; X : Boolean)
     return String is ("XX-101");
   function Is_Taxonomy_Hierarchical (Taxonomy : String) return Boolean is (True);

   procedure Wp_Reset_Vars (A : Array_Type) is null;
--   OBJECT : Post_Rec;
   type Hb_post is null record;
   function Wp_Verify_Nonce (V : String; Item : String) return Boolean is (True);
   function Wp_Dashboard_Quick_Press (I : String := "") return String is ("XXX-110");
   function Get_Default_Comment_Status (S : String; E : String := "") return String
     is ("XXX-111");
   function Edit_Post  return String is ("XXX-113");
   function Write_Post return String is ("XXX-114");
   procedure Redirect_Post (Post_Id : String) is null;

   function Get_Post_Types (A : Array_Type)
            return Array_Type is (Empty_Array);
--   function Get_Post_Types (A : Array_Type)
--            return Tax_Rec;
   type Lock_Type is new Integer;
   function Wp_Set_Post_Lock (Post_Id : String)  return Lock_Type is (1);
   function Wp_Set_Post_Lock (Post_Id : Integer) return Lock_Type is (1);

   function Post_Type_Supports (Post : String; I : String) return Boolean is (True);
   procedure Enqueue_Comment_Hotkeys_JS is null;
   function Wp_Basename (S : String) return String is ("XXX-106");
   procedure Wp_Update_Attachment_Metadata (Post : String; Newmeta : Array_Type)
     is null;


   type Time is null record;
   procedure Setcookie (N    : String;
                        Post : String;
                        Ts   : Time;
                        Path : String;
                        Dom  : String;
                        Ssl  : Boolean) is null;
   MEDIA_TRASH : Boolean := False;
   function Post_Preview return String is ("XXX-104");
   procedure Wp_Safe_Redirect (Ref : String) is null;
   -- type Wp_Post_2 is
   --    record
   --       Post_Type     : Unbounded_String;
   --       ID            : Unbounded_String;
   --       Post_Status   : Unbounded_String;
   --       Post_Title    : Unbounded_String;
   --       Post_Date     : Unbounded_String;
   --       Post_Password : Unbounded_String;
   --       Post_Parent   : Unbounded_String;
   --       Page_Template : Unbounded_String;
   --       Menu_Order    : Unbounded_String;
   --    end record;
   function "not" (T : Inc_Class_Posts.Wp_Post) return Boolean is (False);
   function "not" (T : Inc_Class_Wp_Post_type.Wp_Post_Type)
                   return Boolean
                   is (False);
--   function "not" (T : Post_Rec)  return Boolean is (False);

--   function Get_Post (Id : Assoc_Type) return Post_Rec;
--   function Get_Post (Id : String)     return Inc_Class_Posts.Wp_Post;
--   function Get_Post (Id : String; B : Post_Rec; Ltem : String)
--                      return Inc_Class_Posts.Wp_Post;
--   function Get_Post      return Inc_Class_Posts.Wp_Post; --  is (others => <>);

   function Empty (A : String) return Boolean is (True);
   function Empty (Table : Array_Type) return Boolean;
   function Empty (Arry : Array_Type; Key : String) return Boolean is (False);

   function Apply_Filters (Item : String; S : String; D : Inc_Class_Posts.Wp_Post)
      return Boolean is (True);
   function Apply_Filters (Hook_Name : String;
                           Arg_2     : Array_Type;
                           Id        : Inc_Class_Posts.Post_Id)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           Arg_2     : Array_Type)
                           return Array_Type is (Empty_Array);

   function Apply_Filters (Hook_Name  : String;
                           A1         : Inc_Class_Wp_Terms.Wp_Term_Array;
                           A2, A3, A4 : Array_Type)
                           return Inc_Class_Wp_Terms.Wp_Term_Array
                           is (Inc_Class_Wp_Terms.Empty_Term_Array);

   function Use_Block_Editor_For_Post (Post : Inc_Class_Posts.Wp_Post)
                                       return Boolean is (True);

   function Isset (Item : Array_Type) return Boolean;
   function Isset (Item : String) return Boolean;
--   function Isset (Item : Post_Rec) return Boolean is (True);
   function X_Isset (Arry : Array_Type; Value : String) return Boolean is (True);

   procedure Unset (A : String) is null;
   function Wp_Get_Attachment_Metadata (Id : String; V : Boolean) return Array_Type
     is (Empty_Array);

   type User_Type is
      record
         Display_Name : Unbounded_String;
      end record;

   function Get_Userdata (Id : Integer) return User_Type;

   function Current_User_Can (Trait : Boolean) return Boolean;
   function Current_User_Can (Trait : String; Val : Assoc_Type) return Boolean;
   function Current_User_Can (Trait : String; Val : String) return Boolean;
   function Current_User_Can (Trait : String; Val : Integer) return Boolean;
   function Current_User_Can (Trait : String) return Boolean is (True);
   function Current_User_Can (Trait : String; Val : Inc_Class_Posts.Wp_Post)
                              return Boolean
      is (True);

   function Wp_Untrash_Post (Item : Assoc_Type) return Boolean is (True);
   function Wp_Untrash_Post (Item : String) return Boolean is (True);
   function Wp_Untrash_Post (Item : Inc_Class_Posts.Wp_Post)
                             return Boolean is (True);

   function Get_Current_User_Id return Integer is (1);
   function Get_User_Meta (Id : Integer; Item : String; V : Boolean) return Boolean
      is (True);

   procedure Update_User_Meta (Id : Integer; Item : String; V : Boolean) is null;

   type Walker_Type is access procedure;

   procedure Echo (Item : String) is null;

   function In_Array (Taxonomy   : String;
                      Taxonomies : Inc_Taxonomys.Taxonomy_Array;
                      S          : Boolean)
                      return Boolean is (True);

end HB_Common;
