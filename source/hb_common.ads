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
         Edit_Posts : Boolean := True;
      end record;

   type Lab_Type is
      record
         Name : Unbounded_String;
         Filter_Items_List : Unbounded_String;
         Items_List_Navigation : Unbounded_String;
         Items_List : Unbounded_String;
      end record;

   type Post_Record is
      record
         Cap : Cap_Type;
         Post_Type : Unbounded_String;
         Labels : Lab_Type;
      end record;

   type List_Table is tagged null record;
   function Get_Pagenum (Item : List_Table) return Natural;
   procedure Prepare_Items (Table : in out List_Table);
   function Current_Action (Item : List_Table) return String;
   function X_Get_List_Table (Item : String) return List_Table;


   function Typenow return String;
   function Get_Post_Type_Object (Item : String) return Post_Record;
   procedure Post_Type_Object;
   procedure Hb_Die (Why : String; Code : Integer := 0);

   procedure Parent_File;
   procedure Submenu_File;
   procedure Post_New_File;

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
   Function To_List (List : List_Type) return Assoc_List;
   function To_Array (List : Assoc_List) return Array_Type;
   function Hb_Get_Referer return String;
   function Remove_Query_Arg  (List : Array_Type; Item : String) return Unbounded_String;

   function Current_User_Can (Trait : Boolean) return Boolean;
   function Current_User_Can (Trait : String; Val : Assoc_Type) return Boolean;
   function Admin_Url (Item : String) return Unbounded_String;

   function Preg_Replace (Left : String; Right : Array_Type) return Integer;
   function X_REQUEST (Item : String) return Array_Type;
   function Get_Post_Status_Object (N : Integer) return Boolean;

   Type Statement_Type is null record;
   type Db_Type is tagged null record;

   function Get_Col (Db : Db_Type; Statement : Statement_type) return Array_Type;
   function Prepare (Db : Db_Type; Sql : String; Arg_1,Arg_2 : string) return Statement_Type;
   function Wpdb return Db_Type;

   function Isset (Item : Array_Type) return Boolean;
   function Explode (Item : String; Table : Array_Type) return Array_Type;
   function Implode (Item : String; Table : Array_Type) return String;
   function Array_Map (Item : String; Table : Array_Type) return Array_Type;
   function Empty (Table : Array_Type) return Boolean;

   procedure HB_Redirect (Item : Unbounded_String);

   function HB_Check_Post_Lock (Post_Id : Assoc_Type) return Boolean;
   function Hb_Trash_Post      (Post_Id : Assoc_Type) return Boolean;

   function Add_Query_Arg (Item : String; N : Natural; Sb : Unbounded_String)
      return Unbounded_String;
   function Add_Query_Arg (List : Array_Type; Sb : Unbounded_String)
      return Unbounded_String;

   procedure Hb_Enqueue_Script (Item : String);
   procedure Hb_Enqueue_Style  (Item : String);

   function Build (Key : String; Value : String) return Assoc_Type;
   function Absint (Item : Assoc_List) return String;
   procedure Bulk_Messages;

   function Array_Filter (List : Array_Type) return Assoc_List;
   function X_GET (Item : String) return Array_Type;
   function X_GET (Item : String) return String;

   procedure Add_Filter (Arg_1, Arg_2 : String; Arg_3, Arg_4 : Integer);
   procedure Remove_Filter (Arg_1, Arg_2 : String; Arg_3 : Integer);

   function HB_Untrash_Post (Item : Assoc_Type) return Boolean;
   function Hb_Delete_Attachment (Item : Assoc_Type) return Boolean;
   function Hb_Delete_Post (Item : Assoc_Type) return Boolean;

   function Get_Post (Id : Assoc_Type) return Post_Record;
   function Bulk_Edit_Posts (Item : Array_Type) return Array_Type;
   function Is_Array (Item : Assoc_List) return Boolean;

   procedure Set (Arr : in out Array_Type; Key : String; Value : String);
   function Get (Arr : Array_Type; Key : string) return String;
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

   function Hb_Unslash (Item : String) return String;
   function X_SERVER (Item : String) return String;
   procedure Add_Screen_Option (Item : String; List : Array_Type);

   function "abs" (List : Array_type) return String;

end Hb_Common;
