--
--
--

with Arrays;
with UStrings;

with Adi_Class_Wp_Screens;

with Class_WpDB;
with Class_Locales;
with Class_Posts;
with Class_Post_Type;
with Class_Taxonomy;

package Globals
is
   use Arrays;

   GLOBALS : Array_Type := Empty_Array;

   WpDB : Class_WpDB.Wpdb_Class;

   WP_INSTALLING         : Boolean := True;
   WP_REPAIRING          : Boolean := False;
   WP_INSTALLING_NETWORK : Boolean := False;

   WPINC           : UStrings.UString;
   WP_CONTENT_DIR  : UStrings.UString;

   Wp_Importers : Array_Type;

   Typenow     : UStrings.UString;
   Taxnow      : UStrings.UString;
   Pagenow     : UStrings.UString;
   Hook_Suffix : UStrings.UString;

   Title         : UStrings.UString;
   Post_New_File : UStrings.UString;

   Current_Screen     : Adi_Class_Wp_Screens.Wp_Screen;
   Wp_Locale          : Class_Locales.Wp_Locale;
   Total_Update_Count : Natural;
   Update_Title       : UStrings.UString;

   Post_Type        : UStrings.UString;
   Post_Type_Object : Class_Post_Type.Wp_Post_Type;
   Post             : Class_Posts.Wp_Post;

   Action   : UStrings.UString;
   Taxonomy : UStrings.UString;
   Tax      : Class_Taxonomy.Wp_Taxonomy; -- := Class_Taxonomy.X_Construct;

   Login_Grace_Period : Integer := 0;

   Global_Page  : Natural;
   Global_Paged : Natural;

end Globals;
