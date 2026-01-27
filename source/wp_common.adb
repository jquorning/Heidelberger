--
--
--

with Logging;

with Inc_Plugins;

package body Wp_Common
is

   function Get_Term_Array (Arry : Class_Terms.Wp_Term_Array;
                            Key  : String)
                            return Class_Terms.Wp_Term
   is
      T : Class_Terms.Wp_Term;
   begin
      return T;
   end Get_Term_Array;

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String;
                        Arg_3     : Boolean)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String;
                        Arg_3     : Integer)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Net       : Natural)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type;
                        Option    : String)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Natural;
                        Option    : String)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type;
                        Net       : Natural)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Args      : Array_Type)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Tax       : String;
                        Arg_3     : List_Type;
                        Tax_2     : Class_Taxonomy.Wp_Taxonomy)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Role      : Class_Roles.Wp_Roles)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Code      : String;
                        Message   : String;
                        Data      : String;
                        Error     : Class_Errors.Wp_Error)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Value      : Array_Type;
                        Expiration : Integer;
                        Transient  : String)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Transient  : String;
                        Value      : Array_Type;
                        Expiration : Integer)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Arg_1      : String;
                        Arg_2      : String;
                        Arg_3      : String)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        A1        : Class_HTTP.Response_Result;
                        A2        : String;
                        A3        : String;
                        Args      : Array_Type;
                        Url       : String)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Error     : Class_Errors.Wp_Error)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Class_Users.Wp_User)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Login     : String;
                        User      : Class_Users.Wp_User)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Username  : String;
                        Error     : Class_Errors.Wp_Error)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer;
                        Role      : String)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer;
                        Role      : String;
                        Roles     : List_Type)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Action    : Integer;
                        Result    : Boolean)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Version_1 : Integer;
                        Version_2 : Integer)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Cookie    : Array_Type;
                        User      : Class_Users.Wp_User)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Nonce     : String;
                        Action    : String;
                        User      : Class_Users.Wp_User;
                        Token     : String)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Errors    : Class_Errors.Wp_Error;
                        User      : Inc_Users.User_Error_Type)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Meta_Ids   : List_Type;
                        Object_Is  : Integer;
                        Meta_Key   : String;
                        Meta_Value : String)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Meta_Ids   : List_Type)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Value     : Array_Type;
                        This      : Class_Customize_Managers.Wp_Customize_Manager)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Value     : String;
                        Value_2   : Array_Type;
                        This      : Class_Customize_Managers.Wp_Customize_Manager)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        This      : Class_Customize_Settings.Wp_Customize_Setting)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Class_Users.User_Id_Type)
   is
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, "", "");
   end Do_Action;

end Wp_Common;
