
package body HB_Common
is
   function Get_Pagenum (Item : List_Table) return Natural is (99);

   procedure Prepare_Items (Table : in out List_Table) is
   begin
      null;
   end;

   function Current_Action (Item : List_Table) return String is ("XXX 1");
   function X_Get_List_Table (Item : String) return List_Table is
      List : List_Table;
   begin
      return list;
   end;

   function Typenow return String is ("XXX 2");

   function Get_Post_Type_Object (Item : String) return Post_Record is
      Rec : Post_Record;
   begin
      return Rec;
   end;

   procedure Post_Type_Object is null;

   procedure Hb_Die (Why : String; Code : Integer := 0) is
   begin
      null;
   end;

   procedure Parent_File is null;
   procedure Submenu_File is null;
   procedure Post_New_File is null;

   procedure Check_Admin_Referer (Item : String) is null;

   function To_List (List : List_Type) return Assoc_List is ((1..0 => <>));

   function To_Array (List : Assoc_List) return Array_Type is ((1..0 => <>));

   function Hb_Get_Referer return String is ("XXX 3");

   function Remove_Query_Arg  (List : Array_Type; Item : String) return Unbounded_String
   is (Null_Unbounded_String);

   function Current_User_Can (Trait : Boolean) return Boolean is
   begin
      return True;
   end;

   function Current_User_Can (Trait : String; Val : Assoc_Type) return Boolean is
   begin
      return True;
   end;

   function Admin_Url (Item : String) return Unbounded_String is (+"http://XXX 4");

   function Preg_Replace (Left : String; Right : Array_Type) return Integer is (1);
   function X_REQUEST (Item : String) return Array_Type is (1..0 => <>);
   function Get_Post_Status_Object (N : Integer) return Boolean is (True);

   function Get_Col (Db : Db_Type; Statement : Statement_type) return Array_Type is (1..0 => <>);

   function Prepare (Db : Db_Type; Sql : String; Arg_1,Arg_2 : string) return Statement_Type
   is
       S : Statement_type;
   begin
       return S;
   end;

   function Wpdb return Db_Type is
      Db : Db_Type;
   begin
      return Db;
   end;

   function Isset (Item : Array_Type) return Boolean is (True);
   function Explode (Item : String; Table : Array_Type) return Array_Type is (1..0=><>);
   function Implode (Item : String; Table : Array_Type) return String is ("XXX 5");
   function Array_Map (Item : String; Table : Array_Type) return Array_Type is (1..0=><>);
   function Empty (Table : Array_Type) return Boolean is (True);

   procedure HB_Redirect (Item : Unbounded_String) is null;

   function HB_Check_Post_Lock (Post_Id : Assoc_Type) return Boolean is (False);
   function Hb_Trash_Post      (Post_Id : Assoc_Type) return Boolean is (False);

   function Add_Query_Arg (Item : String; N : Natural; Sb : Unbounded_String)
      return Unbounded_String is (Null_Unbounded_String);
   function Add_Query_Arg (List : Array_Type; Sb : Unbounded_String)
      return Unbounded_String is (Null_Unbounded_String);

   procedure Hb_Enqueue_Script (Item : String) is null;
   procedure Hb_Enqueue_Style  (Item : String) is null;

   function Build (Key : String; Value : String) return Assoc_Type is
      A : Assoc_Type;
   begin
      return A;
   end;

   function Absint (Item : Assoc_List) return String is ("1");
   procedure Bulk_Messages is null;

   function Array_Filter (List : Array_Type) return Assoc_List is
       AL : constant Assoc_List := (1..0=><>);
   begin
      return AL;
   end;
   function X_GET (Item : String) return Array_Type is (1..0=><>);
   function X_GET (Item : String) return String is ("XXX 6");

   procedure Add_Filter (Arg_1, Arg_2 : String; Arg_3, Arg_4 : Integer) is null;
   procedure Remove_Filter (Arg_1, Arg_2 : String; Arg_3 : Integer) is null;

   function HB_Untrash_Post (Item : Assoc_Type) return Boolean is (True);
   function Hb_Delete_Attachment (Item : Assoc_Type) return Boolean is (True);
   function Hb_Delete_Post (Item : Assoc_Type) return Boolean is (True);

   function Get_Post (Id : Assoc_Type) return Post_Record is
      Pr : Post_Record;
   begin
      return Pr;
   end;

   function Bulk_Edit_Posts (Item : Array_Type) return Array_Type is
      A : constant Array_Type := (1..0=> <>);
   begin
      return A;
   end;

   function Is_Array (Item : Assoc_List) return Boolean is (True);

   procedure Set (Arr : in out Array_Type; Key : String; Value : String) is null;
   function Get (Arr : Array_Type; Key : string) return String is ("XXX 7");
   function Count (Item : String) return String is ("XXX 8");

   Screen : aliased Screen_Type;

   function Get_Current_Screen return Screen_Access is
   begin
      return Screen'Access;
   end;

   procedure Add_Help_Tab (Screen : in out Screen_Type; List : Array_Type) is null;
   procedure Set_Help_Sidebar (Screen : in out Screen_Type; Item : String) is null;
   procedure Set_Screen_Reader_Content (Screen : in out Screen_Type; List : Array_Type)
      is null;

   procedure Add_Screen_Option is null;

   function Apply_Filters (Item : String; S : Unbounded_String; D : String; X : Assoc_List)
      return Unbounded_String is (Null_Unbounded_String);
   function Apply_Filters (Item : String; S : Assoc_List; D : Assoc_List)
      return Assoc_List
   is
      Al : constant Assoc_List := (1..0=> <>);
   begin
      return Al;
   end;

   function Hb_Unslash (Item : String) return String is ("XXX 10");
   function X_SERVER (Item : String) return String is ("XXX 11");
   procedure Add_Screen_Option (Item : String; List : Array_Type) is null;

   function "abs" (List : Array_type) return String is ("XXX 12");

end Hb_Common;
