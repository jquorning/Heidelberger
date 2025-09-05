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
      end record;

   type Lab_Type is
      record
         Name              : Unbounded_String;
         Filter_Items_List : Unbounded_String;
         Items_List_Navigation : Unbounded_String;
         Items_List   : Unbounded_String;
         Add_New      : Unbounded_String;
         Search_Items : Unbounded_String;
         Edit_Items   : Unbounded_String;
         Edit_Item    : Unbounded_String;
      end record;

   type Post_Rec is
      record
         Cap       : Cap_Type;
         Post_Type : Unbounded_String;
         Labels    : Lab_Type;
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

--   procedure Post_Type_Object;
   procedure HB_Die (Why : String; Code : Integer := 0);

--   procedure Parent_File;
--   procedure Submenu_File;
--   procedure Post_New_File;

   procedure Check_Admin_Referer (Item : String);

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
   function To_Array (List : Assoc_List) return Array_Type;
   function HB_Get_Referer return String;
   function Remove_Query_Arg  (List : Array_Type; Item : String) return Unbounded_String;

   function Current_User_Can (Trait : Boolean) return Boolean;
   function Current_User_Can (Trait : String; Val : Assoc_Type) return Boolean;
   function Admin_URL (Item : String) return Unbounded_String;

   function Preg_Replace (Left : String; Right : Array_Type) return Integer;
   function Preg_Replace (Left : String; Mid : String; Right : Array_Type) return Integer;
   function X_REQUEST (Item : String) return Array_Type;
   function Get_Post_Status_Object (N : Integer) return Boolean;

   type Statement_Type is null record;
   type DB_Type is tagged null record;

   function Get_Col (Db : DB_Type; Statement : Statement_Type) return Array_Type;
   function Prepare (Db : DB_Type; Sql : String; Arg_1, Arg_2 : String) return Statement_Type;
   function Wpdb return DB_Type;

   function Isset (Item : Array_Type) return Boolean;
   function Explode (Item : String; Table : Array_Type) return Array_Type;
   function Implode (Item : String; Table : Array_Type) return String;
   function Implode (Item : String; Item_2 : Unbounded_String) return String;
   function Array_Map (Item : String; Table : Array_Type) return Array_Type;
   function Empty (Table : Array_Type) return Boolean;

   procedure HB_Redirect (Item : Unbounded_String);

   function HB_Check_Post_Lock (Post_Id : Assoc_Type) return Boolean;
   function HB_Trash_Post      (Post_Id : Assoc_Type) return Boolean;

   function Add_Query_Arg (Item : String; N : Natural; Sb : Unbounded_String)
      return Unbounded_String;
   function Add_Query_Arg (List : Array_Type; Sb : Unbounded_String)
      return Unbounded_String;

   procedure HB_Enqueue_Script (Item : String);
   procedure HB_Enqueue_Style  (Item : String);

   function Build (Key : String; Value : String) return Assoc_Type;
   function Absint (Item : Assoc_List) return String;

   function Array_Filter (List : Array_Type) return Assoc_List;
   function X_GET (Item : String) return Array_Type;
   function X_GET (Item : String) return String;

   procedure Add_Filter (Arg_1, Arg_2 : String; Arg_3, Arg_4 : Integer);
   procedure Remove_Filter (Arg_1, Arg_2 : String; Arg_3 : Integer);

   function HB_Untrash_Post (Item : Assoc_Type) return Boolean;
   function HB_Delete_Attachment (Item : Assoc_Type) return Boolean;
   function HB_Delete_Post (Item : Assoc_Type) return Boolean;

   function Get_Post (Id : Assoc_Type) return Post_Rec;
   function Bulk_Edit_Posts (Item : Array_Type) return Array_Type;
   function Is_Array (Item : Assoc_List) return Boolean;

   procedure Set (Arr : in out Array_Type; Key : String; Value : String);
   function Get (Arr : Array_Type; Key : String) return String;
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
   function Apply_Filters (Item : String; S : Assoc_List; D : Assoc_List)
      return Assoc_List;

   function HB_Unslash (Item : String) return String;
   X_SERVER : Array_Type := (1 .. 0 => <>); -- (Item : String) return String;
   procedure Add_Screen_Option (Item : String; List : Array_Type);

   function "abs" (List : Array_Type) return String;

   function ESC_HTML (Item : String) return String;
   function ESC_URL  (Item : String) return String;
   function ESC_Attr (AL : Assoc_List) return String;
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

   function Get_Edit_Post_Link (Id : Assoc_Type) return String;

   function Get (List : Array_Type; Arg_1 : String; Arg_2 : String) return Array_Type;
   function Get (List : Array_Type; Arg_1 : String; Arg_2 : String) return String;

   type Count_Message_Type is
      record
         Count   : Natural;
         Message : Unbounded_String;
      end record;

   function As_Count_Message (List : Array_Type) return Count_Message_Type;

end HB_Common;
