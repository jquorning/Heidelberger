with Ada.Strings.Unbounded;

package HB_Common
is
   use Ada.Strings.Unbounded;

   function "+" (Item : String) return Unbounded_String
      renames To_Unbounded_String;

   function "-" (Item : Unbounded_String) return String
      renames To_String;

   type Cap_Type is
      record
         Edit_Posts   : Boolean := True;
         Create_Posts : Boolean := True;
         Manage_Terms : Boolean := True;
         Edit_Terms   : Boolean := True;
         Delete_Terms : Boolean := True;
      end record;

   type Lab_Type is
      record
         Name              : Unbounded_String;
         Filter_Items_List : Unbounded_String;
         Items_List_Navigation  : Unbounded_String;
         Name_Field_Description : Unbounded_String;
         Items_List   : Unbounded_String;
         Add_New      : Unbounded_String;
         Add_New_Item : Unbounded_String;
         Search_Items : Unbounded_String;
         Edit_Items   : Unbounded_String;
         Edit_Item    : Unbounded_String;
         Slug_Field_Description : Unbounded_String;
         Parent_Field_Description : Unbounded_String;
         Parent_Item : Unbounded_String;
      end record;

   type Post_Rec is
      record
         Cap       : Cap_Type;
         Post_Type : Unbounded_String;
         Labels    : Lab_Type;
         Show_In_Menu : Boolean;
      end record;

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

   procedure HB_Die (Why : String; Sub : String := ""; Code : Integer := 0);

   procedure Check_Admin_Referer (Item : String; Item_2 : String := "");

   type Assoc_Type is
      record
         Key   : Unbounded_String;
         Value : Unbounded_String;
      end record;

   type Assoc_List is array (Positive range <>) of Assoc_Type;

   subtype Array_Type is Assoc_List;

   type Array_Access is access all Array_Type;

   type List_Type is array (Positive range <>) of Unbounded_String;
   function To_List (List : List_Type) return Assoc_List;
   function Get_Pagination_Arg (List : List_Type; Item : String) return Natural;
   function Get_Pagination_Arg (List : List_Table; Item : String) return Natural;

   function To_Array (List : Assoc_List) return Array_Type;
   function To_Array (Item : String) return Array_Type;

   function HB_Get_Referer return String;
   function Remove_Query_Arg  (List : Array_Type; Item : String) return String;

   function Admin_URL (Item : String) return String;

   function Preg_Replace (Left : String; Right : String) return Integer;
   function Preg_Replace (Left : String; Mid : String; Right : Array_Type) return Integer;
   function Get_Post_Status_Object (N : Integer) return Boolean;

   type Statement_Type is null record;
   type DB_Type is tagged null record;

   function Get_Col (Db : DB_Type; Statement : Statement_Type) return Array_Type;
   function Prepare (Db : DB_Type; Sql : String; Arg_1, Arg_2 : String) return Statement_Type;
   function Wpdb return DB_Type;

   function Explode (Item : String; Table : Array_Type) return Array_Type;
   function Implode (Item : String; Table : Array_Type) return String;
   function Implode (Item : String; Item_2 : Unbounded_String) return String;
   function Array_Map (Item : String; Table : Array_Type) return Array_Type;
   function Empty (Table : Array_Type) return Boolean;

   procedure HB_Redirect (Item : String);

   function HB_Check_Post_Lock (Post_Id : Assoc_Type) return Boolean is (True);
   function HB_Check_Post_Lock (Post_Id : String)     return Integer is (1);
   function HB_Trash_Post      (Post_Id : Assoc_Type) return Boolean;
   function HB_Trash_Post      (Post_Id : String)     return Boolean is (True);

   function Add_Query_Arg (Item : String; N : Natural; Sb : Unbounded_String)
      return Unbounded_String;
   function Add_Query_Arg (Item : String; N : String; I : String)
      return String is ("XXX-120");
   function Add_Query_Arg (Item : String; N : String) return String;
   function Add_Query_Arg (List : Array_Type; Sb : Unbounded_String)
      return Unbounded_String;

   procedure HB_Enqueue_Script (Item : String);
   procedure HB_Enqueue_Style  (Item : String);

   function Build (Key : String; Value : String) return Assoc_Type;
   function Absint (Item : Assoc_List) return String;

   function Array_Filter (List : Array_Type) return Assoc_List;

   procedure Add_Filter (Arg_1, Arg_2 : String; Arg_3, Arg_4 : Integer);
   procedure Remove_Filter (Arg_1, Arg_2 : String; Arg_3 : Integer);

   function HB_Delete_Attachment (Item : Assoc_Type;
                                  V    : Boolean := False) return Boolean is (True);
   function HB_Delete_Attachment (Id : String;
                                  V  : Boolean) return Boolean is (True);
   function HB_Delete_Post (Item : Assoc_Type; V : Boolean := False)
      return Boolean is (True);
   function HB_Delete_Post (Item : String; V : Boolean := False)
      return Boolean is (True);

   function Bulk_Edit_Posts (Item : Array_Type) return Array_Type;
   function Is_Array (Item : Assoc_List) return Boolean;

   procedure Set (Arr : in out Array_Type; Key : String; Value : String);
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

   function Apply_Filters (Item : String; S : Unbounded_String; D : String; X : Assoc_List)
      return Unbounded_String;
   function Apply_Filters (Item : String; S : String; D : String := ""; X : String := "")
      return String;
   function Apply_Filters (Item : String; S : Assoc_List; D : Assoc_List)
      return Assoc_List;
   function Apply_Filters (Item : String; a : Array_Type; V : String; N : String)
      return Array_Type;
--   function Apply_Filters ("redirect_term_location", -Location, Tax) return String;

   function HB_Unslash (Item : String) return String;

   X_SERVER  : Array_Type := (1 .. 0 => <>); -- (Item : String) return String;
   X_POST    : Array_Type := (1 .. 0 => <>);
   X_GET     : Array_Type := (1 .. 0 => <>);
--   function X_GET (Item : String) return String;
   X_REQUEST : Array_Type := (1 .. 0 => <>);

   procedure Add_Screen_Option (Item : String; List : Array_Type);

   function "abs" (List : Array_Type) return String;

   function ESC_HTML (Item : String) return String;
   function ESC_URL  (Item : String) return String;
   function ESC_Attr (AL : Assoc_List) return String;
   function ESC_Attr (AL : String) return String;
   function ESC_Attrl (AL : Assoc_List) return String;

   function Printf (Format : String; Arg_1 : String) return String;

   function Get_Search_Query return String;

   function Sprintf (Format : String; Arg_1 : String) return String;
   function Number_Format_I18n (N : Integer) return String;
   function HB_Nonce_URL (Url : String; Item : String) return String;
   function Count (Al : Assoc_List) return Natural;

   function Get_Post_Type_Object (Item : Post_Rec) return String;
   function Get_Post_Type_Object (Item : String) return Post_Rec;
   function Get_Post_Type_Object (Item : String) return String;
   function Get_Post_Type (Item : Assoc_Type) return Post_Rec;

   function Get_Edit_Post_Link (Id : Assoc_Type; Item : String := "") return String;

   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "") return String;
   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "") return Array_Type;

   type Count_Message_Type is
      record
         Count   : Natural;
         Message : Unbounded_String;
      end record;

   function As_Count_Message (List : Array_Type) return Count_Message_Type;

   type Lab_Record is
      record
         Name : Unbounded_String;
      end record;

   type Tax_Rec is
      record
         Labels : Lab_Type;  --  Lab_Record;
         Name   : Unbounded_String;
         Cap    : Cap_Type;
      end record;

   function Taxnow return String;
   function Get_Taxonomy (Item : String) return Tax_Rec;
   function Get_Taxonomies (list : Array_Type) return Tax_Rec;
   function In_Array (Item : String; Tax : Tax_Rec; V : Boolean) return Boolean;
   function HB_Insert_Term (Item : String; Item2 : String; Arr : Array_Type) return Boolean;
   -- Get (X_Post, "tag-name"), Taxonomy, X_POST);
   function Is_HB_Error (Ret : Boolean) return Boolean;
   procedure HB_Delete_Term (Tag : Integer; Taxonomy : String);
   procedure HB_Delete_Terms (Tag : Integer; Taxonomy : String);

   type Term_Type is null record;
   function Get_Term (Id : Integer; Tax : String := "") return Term_Type;
   function "not" (Term : Term_Type) return Boolean;
   function Sanitize_URL (Item : String) return String;
   function Get_Edit_Term_Link (Id : Integer; Taxonomy : String; Post_Type : String) return String;
   function HB_Update_Term (Id : Natural; Taxonomy : String; Arr : Array_Type) return Boolean;
   function Is_Plugin_Active (Item : String) return Boolean;

   procedure Do_Action_Deprecated (I1 : String;
                                   A1 : Array_Type;
                                   V : String;
                                   I2 : String) is null;
   procedure Do_Action (Item_1 : String; Item_2 : String := "") is null;
   procedure HB_Nonce_Field (I1, I2 : String) is null;

   function Get_Cat_Name (Item : String) return String is ("XXX-91");
   function Get_Option (Item : String) return String is ("XXX-92");

   function HB_Is_Mobile return Boolean is (False);
   procedure HB_Dropdown_Categories (A : Array_Type) is null;

   function Submit_Button (Text : String; V1 : String; V2 : String; X : Boolean)
     return String is ("XX-101");
   function Is_Taxonomy_Hierarchical (Taxonomy : String) return Boolean is (True);

   procedure HB_Reset_Vars (A : Array_Type) is null;
   OBJECT : Post_Rec;
   type Hb_post is null record;
   function HB_Verify_Nonce (V : String; Item : String) return Boolean is (True);
   function HB_Dashboard_Quick_Press (I : String := "") return String is ("XXX-110");
   function Get_Default_Comment_Status (S : String; E : String := "") return String
     is ("XXX-111");
   function Str_Replace (A : Array_Type;
                         S : String;
                         D : String) return String is ("XXX-112");
   function Edit_Post  return String is ("XXX-113");
   function Write_Post return String is ("XXX-114");
   procedure Redirect_Post (Post_Id : String) is null;

   function Get_Post_Types (A : Array_Type)
            return Array_Type is (1 .. 0 => <>);
   function Get_Post_Types (A : Array_Type)
            return Tax_Rec;
   type Lock_Type is new Integer;
   function HB_Set_Post_Lock (Post_Id : String) return Lock_Type is (1);

   function Post_Type_Supports (Post : String; I : String) return Boolean is (True);
   procedure Enqueue_Comment_Hotkeys_JS is null;
   function HB_Basename (S : String) return String is ("XXX-106");
   procedure HB_Update_Attachment_Metadata (Post : String; Newmeta : Array_Type)
     is null;


   X_COOKIE : Array_Type := (1 .. 0 => <>);
   type Time is null record;
   procedure Setcookie (N    : String;
                        Post : String;
                        Ts   : Time;
                        Path : String;
                        Dom  : String;
                        Ssl  : Boolean) is null;
   MEDIA_TRASH : Boolean := False;
   function Post_Preview return String is ("XXX-104");
   procedure HB_Safe_Redirect (Ref : String) is null;
   type HB_Post_2 is
      record
         Post_Type   : Unbounded_String;
         ID          : Unbounded_String;
         Post_Status : Unbounded_String;
      end record;
   function "not" (T : HB_Post_2) return Boolean is (False);
   function "not" (T : Post_Rec)  return Boolean is (False);

   function Get_Post (Id : Assoc_Type) return Post_Rec;
--   function Get_Post (Id : Integer)    return HB_Post_2;
   function Get_Post (Id : String)     return HB_Post_2;
   function Get_Post (Id : String; B : Post_Rec; Ltem : String) return HB_Post_2;

   function Empty (A : String) return Boolean is (True);

   function Apply_Filters (Item : String; S : String; D : HB_Post_2)
      return Boolean is (True);
   function Use_Block_Editor_For_Post (Post : HB_Post_2) return Boolean is (True);

   function Isset (Item : Array_Type) return Boolean;
   function Isset (Item : String) return Boolean;
   function Isset (Item : Post_Rec) return Boolean is (True);

   procedure Unset (A : String) is null;
   function HB_Get_Attachment_Metadata (Id : String; V : Boolean) return Array_Type
     is (1 .. 0 => <>);

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
   function Current_User_Can (Trait : String; Val : HB_Post_2) return Boolean
      is (True);

   function HB_Untrash_Post (Item : Assoc_Type) return Boolean is (True);
   function HB_Untrash_Post (Item : HB_Post_2)  return Boolean is (True);

   function Get_Current_User_Id return Integer is (1);
   function Get_User_Meta (Id : Integer; Item : String; V : Boolean) return Boolean
      is (True);

   procedure Update_User_Meta (Id : Integer; Item : String; V : Boolean) is null;


end HB_Common;
