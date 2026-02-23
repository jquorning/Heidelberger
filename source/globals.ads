--
--
--

with Ada.Containers.Indefinite_Ordered_Maps;

with Arrays;
with Lists;
with UStrings;

with Class_Hook_Maps;
with Class_Locales;
with Class_Posts;
with Class_Post_Type;
with Class_Screens;
with Class_Scripts;
with Class_Styles;
with Class_Taxonomy;
with Class_Users;
with Class_WpDB;
with Class_Wp;

package Globals
is
   use Arrays;
   use Lists;

   GLOBALS : Array_Type := Empty_Array;
   Table_Prefix : UStrings.UString;

   Global_Blog_Id : Integer := Integer'First;

   WpDB : Class_WpDB.Wpdb_Class;

   WP_INSTALLING         : Boolean := True;
   WP_REPAIRING          : Boolean := False;
   WP_INSTALLING_NETWORK : Boolean := False;

   WPINC           : UStrings.UString;
   WP_CONTENT_DIR  : UStrings.UString;
   WP_LANG_DIR     : UStrings.UString;

   Wp_Importers : Array_Type;

   package Count_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Natural);

   package Natural_Maps is new
      Ada.Containers.Indefinite_Ordered_Maps
        (Key_Type     => String,
         Element_Type => Natural);

   Global_Wp                : Class_Wp.Wp_Class;

   Global_Wp_Filter         : Class_Hook_Maps.Hook_Maps.Map;
   Global_Wp_Actions        : Count_Maps.Map;
   Global_Wp_Filters        : Natural_Maps.Map;
   Global_Wp_Current_Filter : List_Type;

   Global_Wp_Scripts : Class_Scripts.Wp_Scripts;
   Global_Wp_Styles  : Class_Styles.Wp_Styles;

   Global_Typenow : UStrings.UString;
   Global_Taxnow  : UStrings.UString;
   Global_Pagenow : UStrings.UString;
   Hook_Suffix    : UStrings.UString;

   Global_Title       : UStrings.UString;
   Global_Parent_File : UStrings.UString;
   Post_New_File      : UStrings.UString;

   Current_Screen     : Class_Screens.Wp_Screen;
   Wp_Locale          : Class_Locales.Wp_Locale;
   Total_Update_Count : Natural;
   Update_Title       : UStrings.UString;

   Global_Post_Id   : Class_Posts.Post_Id_Type;
   Post_Type        : UStrings.UString;
   Post_Type_Object : Class_Post_Type.Wp_Post_Type;
   Global_Post      : Class_Posts.Wp_Post;
   Global_Posts     : Class_Posts.Post_Array;

   Global_Query_String  : UStrings.UString;
   Global_Wp_Did_Header : Boolean := False;

   Global_Request    : UStrings.UString;
   Global_More       : Natural;
   Global_Single     : Natural;
   Global_Authordata : Class_Users.Wp_User;

   Global_Action : UStrings.UString;
   Taxonomy      : UStrings.UString;
   Tax           : Class_Taxonomy.Wp_Taxonomy; -- := Class_Taxonomy.X_Construct;

   Login_Grace_Period : Integer := 0;

   Global_Page  : Natural;
   Global_Paged : Natural;

   --
   --
   --
   procedure Initialize;

end Globals;
