
package body HB_Common
is
   use Inc_Class_Wp_Posts;

--   function Get_Pagenum (Item : List_Table) return Natural is (99);

--   procedure Prepare_Items (Table : in out List_Table) is
--   begin
--      null;
--   end Prepare_Items;

--   function Current_Action (Item : List_Table) return String is ("XXX 1");
--   function X_Get_List_Table (Item : String) return List_Table is
--      List : List_Table;
--   begin
--      return List;
--   end X_Get_List_Table;

   procedure Post_Type_Object is null;

   procedure Parent_File is null;
   procedure Submenu_File is null;
   procedure Post_New_File is null;

   procedure Check_Admin_Referer (Item : String) is null;

   function To_List (List : List_Type) return Assoc_List is ((1 .. 0 => <>));

   function To_Array (List : Assoc_List) return Array_Type is (Empty_Array);
   function To_Array (Item : String) return Array_Type is (Empty_Array);

   function Remove_Query_Arg  (List : Array_Type; Item : String) return Unbounded_String
   is (Null_Unbounded_String);

   function Apply_Filters (Item : String;
                           S : String;
                           D : String := "";
                           X : String := "")
      return String is ("XXX-105");

   function Apply_Filters (Item : String; a : Array_Type; V : String; N : String)
      return Array_Type is (Empty_Array);

   function Current_User_Can (Trait : Boolean) return Boolean is
   begin
      return True;
   end Current_User_Can;

   function Current_User_Can (Trait : String; Val : Assoc_Type) return Boolean is
   begin
      return True;
   end Current_User_Can;

   function Preg_Replace (Left : String; Right : Array_Type) return Integer is (1);
   function Preg_Replace (Left : String; Mid : String; Right : Array_Type) return Integer is (1);

   function Get_Post_Status_Object (N : Integer) return Boolean is (True);

   function Isset (Item : Array_Type) return Boolean is (True);
   function Explode (Item : String; Table : Array_Type) return Array_Type
   is (Empty_Array);
   function Implode (Item : String; Table : Array_Type) return String is ("XXX 5");
   function Implode (Item : String; Item_2 : Unbounded_String) return String is ("XXX-61");
   function Array_Map (Item : String; Table : Array_Type) return Array_Type
   is (Empty_Array);
   function Empty (Table : Array_Type) return Boolean is (True);

   function Add_Query_Arg (Item : String; N : Natural; Sb : Unbounded_String)
      return Unbounded_String is (Null_Unbounded_String);
   function Add_Query_Arg (Item : String; N : String) return String is ("XXX-78");
   function Add_Query_Arg (List : Array_Type; Sb : Unbounded_String)
      return Unbounded_String is (Null_Unbounded_String);

   procedure Hb_Enqueue_Script (Item : String) is null;
   procedure Hb_Enqueue_Style  (Item : String) is null;

   function Build (Key : String; Value : String) return Assoc_Type is
      A : Assoc_Type;
   begin
      return A;
   end Build;

   function Absint (Item : Assoc_List) return String is ("1");
   procedure Bulk_Messages is null;

   function Array_Filter (List : Array_Type) return Assoc_List is
      AL : constant Assoc_List := (1 .. 0 => <>);
   begin
      return AL;
   end Array_Filter;

   procedure Add_Filter (Arg_1, Arg_2 : String; Arg_3, Arg_4 : Integer) is null;
   procedure Remove_Filter (Arg_1, Arg_2 : String; Arg_3 : Integer) is null;

   function Wp_Delete_Attachment (Item : Assoc_Type) return Boolean is (True);
   function Wp_Delete_Post (Item : Assoc_Type) return Boolean is (True);

   function Bulk_Edit_Posts (Item : Array_Type) return Array_Type is
      A : constant Array_Type := Empty_Array;
   begin
      return A;
   end Bulk_Edit_Posts;

   function Is_Array (Item : Assoc_List) return Boolean is (True);

   procedure Set (Arr : in out Array_Type; Key : String; Value : String) is null;
   function Get (Arr : Array_Type; Key : String) return String is ("XXX 7");
   function Count (Item : String) return String is ("XXX 8");

   procedure Add_Screen_Option is null;

   function Apply_Filters (Item : String; S : Unbounded_String; D : String; X : Assoc_List)
      return Unbounded_String is (Null_Unbounded_String);
   function Apply_Filters (Item : String; S : String; D : String)
      return String is ("XXX-77");
   function Apply_Filters (Item : String; S : Assoc_List; D : Assoc_List)
      return Assoc_List
   is
      Al : constant Assoc_List := (1 .. 0 => <>);
   begin
      return Al;
   end Apply_Filters;

   procedure Add_Screen_Option (Item : String; List : Array_Type) is null;

   function "abs" (List : Array_Type) return String is ("XXX 12");

--   function Views (Item : List_Table) return String is ("XXX-31");
--   function Search_Box (Item : List_Table; L : String; R : String) return String is ("XXX-32");
--   function Display (Item : List_Table) return String is ("XXX-33");
--   function Inline_Edit (Item : List_Table) return String is ("XXX-34");
--   function Has_Items (Item : List_Table) return Boolean is (False);

--   function ESC_HTML (Item : String) return String is (Item);
--   function ESC_URL  (Item : String) return String is (Item);
--   function ESC_Attr (AL : String) return String is ("XXX-106");

   function Printf (Format : String; Arg_1 : String) return String is (Format & Arg_1);

   function Get_Search_Query return String is ("XXX-43");

   function Sprintf (Format : String; Arg_1 : String) return String is ("XXX-62");

   function Number_Format_I18n (N : Integer) return String is ("XXX-63");
   function Count (Al : Assoc_List) return Natural is (1);

   function Get_Edit_Post_Link (Id : Assoc_Type; Item : String := "") return String
    is ("XXX-67");

   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "") return Array_Type
   is
      A : constant Array_Type := Empty_Array;
   begin
      return A;
   end Get;

   function Get (Arr : Array_Type; Key : String; Arg_2 : String := "")
                 return String is ("XXX-68");

   procedure Check_Admin_Referer (Item : String; Item_2 : String := "") is null;
   function Get_Pagination_Arg (List : List_Type; Item : String) return Natural is (1);
--   function Get_Pagination_Arg (List : List_Table; Item : String) return Natural is (1);
   function Current_User_Can (Trait : String; Val : String) return Boolean is (True);
   function Current_User_Can (Trait : String; Val : Integer) return Boolean is (True);
   function Admin_URL (Item : String) return String is ("XXX-71");
   function Preg_Replace (Left : String; Right : String) return Integer is (1);
   function Isset (Item : String) return Boolean is (True);
   function Taxnow return String is ("XXX-72");

   function Sanitize_URL (Item : String) return String is ("XXX-73");
   function Get_Edit_Term_Link (Id : Integer; Taxonomy : String; Post_Type : String) return String
      is ("XXX-74");

   function Is_Plugin_Active (Item : String) return Boolean is (False);

   function Get_Post      return Inc_Class_Wp_Posts.Wp_Post
   is
      P : Wp_Post;
   begin
      return P;
   end Get_Post;

end HB_Common;
