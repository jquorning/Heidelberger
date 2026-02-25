--
--
--

with Php.Calendar;

with Array_Lists;
with Arrays;
with Lists;

with Adi_Translation_Install;

-- with Class_Admin_Bar;
with Class_Block_Editor_Contexts;
with Class_Customize_Managers;
with Class_Customize_Settings;
with Class_Errors;
with Class_HTTP;
with Class_Roles;
with Class_Taxonomy;
with Class_Terms;
with Class_Posts;
with Class_Post_Type;
with Class_Screens;
with Class_Sites;
with Class_Users;
with Inc_Capabilities;
with Inc_Comments;
with Inc_Media;
with Inc_Posts;
with Inc_Users;

package Wp_Common
is
   use Arrays;
   use Lists;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String := "";
                           X         : String := "")
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Diff      : Integer;
                           From      : Integer;
                           To        : Integer)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Args      : Array_Type)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           Post      : Class_Posts.Post_Id_Type)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Arg_3     : Array_Type;
                           Arg_4     : Array_Type := Empty_Array)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : String := "")
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           List      : List_Type)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : String;
                           I         : Integer)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : Array_Type)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Right     : Integer := 0)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : List_Type;
                           Right     : Integer := 0)
                           return List_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           Arg_2     : Positive;
                           Arg_3     : String;
                           Arg_4     : Boolean;
                           Arg_5     : String)
                           return Integer;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String := "";
                           P         : Array_Type)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String;
                           P         : List_Type)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           B         : String;
                           D         : String)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           S         : String;
                           B         : Boolean)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           B         : Integer := 0)
                           return Integer;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           B         : Integer;
                           S         : Boolean;
                           E         : Boolean)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           C         : String)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Integer)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Raw       : String;
                           Strict    : Boolean)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Path      : String;
                           Scheme    : String;
                           Blog      : Integer)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Integer;
                           Context   : String;
                           Allow     : Boolean)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           V         : Array_Type;
                           Trans     : String)
                           return Integer;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           User      : Class_Users.Wp_User)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term_Array;
                           Id        : String;
                           Taxonomy  : String;
                           A4        : Array_Type := Empty_Array)
                           return Class_Terms.Wp_Term_Array;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Class_Terms.Wp_Term_Array;
                           A2         : List_Type;
                           A3         : Array_Type;
                           A4         : Array_Type)
                           return Class_Terms.Wp_Term_Array;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Class_Posts.Wp_Post)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Id        : Class_Posts.Post_Id_Type)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           C         : Class_Posts.Wp_Post)
                           return List_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Wp_Post;
                           B         : Boolean)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           C         : Class_Posts.Wp_Post)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           A         : String;
                           C         : Class_Posts.Wp_Post)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Id        : Class_Screens.Wp_Screen;
                           Arg_4     : Boolean := False)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : List_Type;
                           Screen    : Class_Screens.Wp_Screen;
                           Default   : Boolean := False)
                           return List_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term;
                           Cats      : Class_Terms.Wp_Term_Array;
                           Post      : Class_Posts.Wp_Post)
                           return Class_Terms.Wp_Term;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Wp_Post;
                           A         : Boolean;
                           B         : Boolean)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Post_Id_Type;
                           B         : Boolean)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term_Array;
                           Post      : Class_Posts.Post_Id_Type)
                           return Class_Terms.Wp_Term_Array;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Taxonomy.Int_Arrays.Vector;
                           Id        : Integer;
                           Obj       : String;
                           Res       : String)
                           return Class_Taxonomy.Int_Arrays.Vector;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           Status    : Inc_Posts.Status_Type)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           Status    : Class_Post_Type.Wp_Post_Type)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String)
                           return Multi_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Passed    : Boolean)
                           return Multi_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Id        : Integer;
                           Default   : Multi_Type)
                           return Multi_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Id        : Integer)
                           return Multi_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Old       : Multi_Type;
                           Option    : String)
                           return Multi_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Old       : Multi_Type;
                           Option    : String;
                           Net       : Natural)
                           return Multi_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Old       : Multi_Type)
                           return Multi_Type;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Multi_Type;
                           Expiration : Natural;
                           Trans      : String)
                           return Multi_Type;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Natural;
                           Value_2    : Multi_Type;
                           Trans      : String)
                           return Natural;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Path       : String;
                           Blog       : Integer;
                           Scheme     : String)
                           return String;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Typ        : String;
                           Args       : Array_Type)
                           return Adi_Translation_Install.Trans_Result;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Adi_Translation_Install.Trans_Result;
                           Typ        : String;
                           Args       : Array_Type)
                           return Adi_Translation_Install.Trans_Result;

   function Apply_Filters (Hook_Name  : String;
                           Value      : List_Type;
                           Args       : Array_Type;
                           URL        : String)
                           return List_Type;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Args       : Array_Type;
                           URL        : String)
                           return Array_Type;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Integer;
                           URL        : String)
                           return String;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Integer;
                           Name       : String)
                           return Integer;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Status     : Integer;
                           Location   : String)
                           return String;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Number     : Float;
                           Decimals   : Integer)
                           return String;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Code       : Integer;
                           Descript   : String;
                           Protocol   : String)
                           return String;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Funct      : String;
                           Message    : String;
                           Version    : String)
                           return Boolean;

   function Apply_Filters (Hook_Name  : String;
                           Value      : List_Type;
                           Host       : String)
                           return List_Type;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Email      : String;
                           Size       : Integer;
                           Default    : Array_Type;
                           Alt        : String;
                           Args       : Array_Type)
                           return String;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Size       : Integer;
                           Blog_Id    : Integer)
                           return String;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Php.Calendar.Time_Type;
                           Format     : String;
                           GMT        : Boolean)
                           return String; -- Php.Calendar.Time_Type

   function Apply_Filters (Hook_Name  : String;
                           Value      : Inc_Media.Image_Src_Type;
                           Id         : Integer;
                           Size       : String;
                           Icon       : Boolean)
                           return Inc_Media.Image_Src_Type;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Item       : String;
                           User       : Class_Users.Wp_User)
                           return String;

   function Apply_Filters (Hook_Name   : String;
                           Value       : Class_Errors.Wp_Error;
                           Redirect_To : String)
                           return Class_Errors.Wp_Error;

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           Redirect_To : String;
                           User        : Inc_Users.User_Error_Type)
                           return String;

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           User        : Inc_Users.User_Id_Error_Type)
                           return String;

   function Apply_Filters (Hook_Name   : String;
                           Value       : Inc_Users.User_Error_Type;
                           Username    : String;
                           Password    : String)
                           return Inc_Users.User_Error_Type;

   function Apply_Filters (Hook_Name   : String;
                           Value       : Inc_Users.User_Error_Type;
                           Password    : String)
                           return Inc_Users.User_Error_Type;

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           Errors      : Class_Errors.Wp_Error)
                           return String;

   function Apply_Filters (Hook_Name   : String;
                           Value       : Boolean;
                           Credentials : Array_Type)
                           return Boolean;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Args       : Array_Type;
                           Typ        : String)
                           return Class_HTTP.Response_Result;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Class_HTTP.Response_Result;
                           Args       : Array_Type;
                           URL        : String)
                           return Class_HTTP.Response_Result;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Object     : Integer;
                           Meta_Key   : String;
                           Meta_Value : String;
                           Delete_All : Boolean)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : List_Type;
                           T         : Class_Customize_Managers.Wp_Customize_Manager)
                           return List_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Customize_Managers.Wp_Customize_Setting;
                           Id        : String;
                           A         : Array_Type)
                           return Class_Customize_Managers.Wp_Customize_Setting;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Customize_Managers.Wp_Customize_Setting;
                           Id        : String;
                           Setting   : Boolean)
                           return Class_Customize_Managers.Wp_Customize_Setting;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           T         : Class_Customize_Managers.Wp_Customize_Manager)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           This      : Class_Customize_Settings.Wp_Customize_Setting)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           This      : Class_Customize_Settings.Wp_Customize_Setting)
                           return Multi_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Errors.Wp_Error;
                           Value_2   : Multi_Type;
                           This      : Class_Customize_Settings.Wp_Customize_Setting)
                           return Class_Errors.Wp_Error;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Array_Type;
               Item      : Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Array_Lists.Array_List;
               Item      : Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Lists.Array_List;

   function Apply_Filters
              (Hook_Name : String;
               Value     : List_Type; -- Boolean;
               Item      : Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return List_Type; -- Boolean

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           HTML      : Array_Type;
                           Protocols : List_Type)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : List_Type;
                           S         : String;
                           U         : Integer;
                           Args      : Inc_Capabilities.Args_Type)
                           return List_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           S         : String;
                           O_Id      : Integer;
                           U_Id      : Integer;
                           C         : String;
                           L         : List_Type)
                           return Boolean;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Caps      : List_Type;
                           This      : Class_Users.Wp_User)
                           return Array_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Text      : String;
                           Context   : String;
                           Domain    : String)
                           return String;

   function Apply_Filters (Hook_Name : String;
                           Value     : Natural;
                           U         : Natural;
                           P         : Natural)
                           return Natural;

   function Apply_Filters (Hook_Name : String;
                           Value     : Inc_Comments.Comment_Counts_Type;
                           Post_Id   : Integer)
                           return Inc_Comments.Comment_Counts_Type;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Oi        : List_Type;
                           Tax       : Array_Type)
                           return Array_Type;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Class_Sites.Wp_Site)
               return Class_Sites.Wp_Site;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Class_Users.User_Id_Type;
               Name      : String)
               return Class_Users.User_Id_Type;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Array_Lists.Array_List)
               return Array_Lists.Array_List;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Multi_Type;
               Old       : Multi_Type)
               return Multi_Type;

   function Apply_Filters
              (Hook_Name   : String;
               Value       : Array_Type;
               Plugin_File : String;
               Plugin_Data : Array_Type;
               Context     : String)
               return Array_Type;

   function Apply_Filters
              (Hook_Name   : String;
               Value       : String;
               Plugin_File : String;
               Plugin_Data : Array_Type;
               Status      : String)
               return String;

   function Apply_Filters_Deprecated
              (Hook_Name : String;
               Value     : Array_Type;
               Version   : String;
               X         : String)
               return Array_Type
               is (Value);

   function Apply_Filters_Deprecated
              (Hook_Name : String;
               Value     : Array_Lists.Array_List;
               Version   : String;
               X         : String)
               return Array_Lists.Array_List
               is (Value);

   function Apply_Filters_Deprecated
              (Hook_Name : String;
               Value     : List_Type;
               Version   : String;
               X         : String)
               return List_Type
               is (Value);

   function Apply_Filters_Deprecated
              (Hook_Name : String;
               Value     : Array_Type;
               Post      : Class_Posts.Wp_Post;
               Version   : String;
               Hook      : String)
               return Array_Type
               is (Value);

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String := "";
                        Arg_3     : String := "");

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String;
                        Arg_3     : Boolean);

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String;
                        Arg_3     : Integer);

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type);

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type);

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Net       : Natural);

   procedure Do_Action (Hook_Name : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type;
                        Option    : String);

   procedure Do_Action (Hook_Name : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Natural;
                        Option    : String);

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type;
                        Net       : Natural);

   procedure Do_Action (Hook_Name : String;
                        Args      : Array_Type);

   procedure Do_Action (Hook_Name : String;
                        Tax       : String;
                        Arg_3     : List_Type;
                        Tax_2     : Class_Taxonomy.Wp_Taxonomy);

   procedure Do_Action (Hook_Name : String;
                        Role      : Class_Roles.Wp_Roles);

   procedure Do_Action (Hook_Name : String;
                        Code      : String;
                        Message   : String;
                        Data      : String;
                        Error     : Class_Errors.Wp_Error);

   procedure Do_Action (Hook_Name  : String;
                        Value      : Array_Type;
                        Expiration : Integer;
                        Transient  : String);

   procedure Do_Action (Hook_Name  : String;
                        Transient  : String;
                        Value      : Array_Type;
                        Expiration : Integer);

   procedure Do_Action (Hook_Name  : String;
                        Arg_1      : String;
                        Arg_2      : String;
                        Arg_3      : String);

   procedure Do_Action (Hook_Name : String;
                        A1        : Class_HTTP.Response_Result;
                        A2        : String;
                        A3        : String;
                        Args      : Array_Type;
                        Url       : String);

   procedure Do_Action (Hook_Name : String;
                        Error     : Class_Errors.Wp_Error);

   procedure Do_Action (Hook_Name : String;
                        User      : Class_Users.Wp_User);

   procedure Do_Action (Hook_Name : String;
                        Login     : String;
                        User      : Class_Users.Wp_User);

   procedure Do_Action (Hook_Name : String;
                        Username  : String;
                        Error     : Class_Errors.Wp_Error);

   procedure Do_Action (Hook_Name : String;
                        User      : Integer;
                        Role      : String);

   procedure Do_Action (Hook_Name : String;
                        User      : Integer;
                        Role      : String;
                        Roles     : List_Type);

   procedure Do_Action (Hook_Name : String;
                        User      : Integer);

   procedure Do_Action (Hook_Name : String;
                        Action    : Integer;
                        Result    : Boolean);

   procedure Do_Action (Hook_Name : String;
                        Version_1 : Integer;
                        Version_2 : Integer);

   procedure Do_Action (Hook_Name : String;
                        Cookie    : Array_Type;
                        User      : Class_Users.Wp_User);

   procedure Do_Action (Hook_Name : String;
                        Nonce     : String;
                        Action    : String;
                        User      : Class_Users.Wp_User;
                        Token     : String);

   procedure Do_Action (Hook_Name : String;
                        Errors    : Class_Errors.Wp_Error;
                        User      : Inc_Users.User_Error_Type);

   procedure Do_Action (Hook_Name  : String;
                        Meta_Ids   : List_Type;
                        Object_Is  : Integer;
                        Meta_Key   : String;
                        Meta_Value : String);

   procedure Do_Action (Hook_Name  : String;
                        Meta_Ids   : List_Type);

   procedure Do_Action (Hook_Name : String;
                        Value     : Array_Type;
                        This      : Class_Customize_Managers.Wp_Customize_Manager);

   procedure Do_Action (Hook_Name : String;
                        Value     : String;
                        Value_2   : Array_Type;
                        This      : Class_Customize_Managers.Wp_Customize_Manager);

   procedure Do_Action (Hook_Name : String;
                        This      : Class_Customize_Settings.Wp_Customize_Setting);

   procedure Do_Action (Hook_Name : String;
                        User      : Class_Users.User_Id_Type);

   procedure Do_Action (Hook_Name     : String;
                        Post_Id       : Class_Posts.Post_Id_Type;
                        Trackback_Url : String;
                        Charset       : String;
                        Title         : String;
                        Excerpt       : String;
                        Blog_Name     : String);

   procedure Do_Action (Hook_Name  : String;
                        Is_Comment : Boolean;
                        Feed       : String);

   procedure Do_Action (Hook_Name   : String;
                        Column      : String;
                        Plugin_File : String;
                        Plugin_Data : Array_Type);

   procedure Do_Action (Hook_Name   : String;
                        Plugin_File : String;
                        Plugin_Data : Array_Type;
                        Status      : String);

end Wp_Common;
