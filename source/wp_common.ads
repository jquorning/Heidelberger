--
--
--

with Php.Calendar;

with Arrays;
with Lists;

with Adi_Class_Wp_Screens;
with Adi_Translation_Install;

with Inc_Class_Wp_Admin_Bar;
with Inc_Class_Wp_Dependency;
with Class_Errors;
with Inc_Class_Wp_Http;
with Inc_Class_Wp_Taxonomy;
with Class_Terms;
with Class_Posts;
with Class_Post_Type;
with Inc_Class_Wp_Users;
with Inc_Media;
with Inc_Posts;
with Inc_Taxonomys;
with Inc_Users;

package Wp_Common
is
   use Arrays;
   use Lists;

   function In_Array (T : Integer;
                      A : Inc_Class_Wp_Taxonomy.Int_Arrays.Vector;
                      S : Boolean)
                      return Boolean
                      is (raise Program_Error with "not implemented");

   function Is_Object (Post : Class_Posts.Wp_Post)
                       return Boolean
                       is (True);

   function Get_Object_Vars (Object : Class_Posts.Wp_Post)
                             return Array_Type is (Empty_Array);

   procedure Set (Item : Array_Type;
                  Key  : String;
                  Term : Class_Terms.Wp_Term_Array) is null;

   function Array_Keys (Arry : Class_Terms.Wp_Term_Array)
                        return List_Type
                        is (Empty_List);

   procedure Array_Unshift (Arry : in out Class_Terms.Wp_Term_Array;
                            S    : Class_Terms.Wp_Term)
                            is null;

   function In_Array (Taxonomy   : String;
                      Taxonomies : Inc_Taxonomys.Taxonomy_Array;
                      S          : Boolean)
                      return Boolean is (True);

   function In_Array (A      : Integer;
                      B      : Array_Type;
                      Strict : Boolean)
                      return Boolean
                      is (True);

   function Get_Array (Arry : Class_Terms.Wp_Term_Array;
                       Key  : String)
                       return Array_Type
                       is (Empty_Array);

   function Get_Term_Array (Arry : Class_Terms.Wp_Term_Array;
                            Key  : String)
                            return Class_Terms.Wp_Term;

   function Get (Post_Type : Class_Post_Type.Wp_Post_Type;
                 Key       : String)
                 return String
                 is ("XXX-240");

   function Array_Keys (Arry : Inc_Class_Wp_Dependency.Dependency_Map)
                        return List_Type
                        is (Empty_List);

   function Array_Fill_Keys (Keys  : List_Type;
                             Value : Boolean)
                             return Array_Type
                             is (Empty_Array);

   function Is_Object (Admin_Bar : Inc_Class_Wp_Admin_Bar.Wp_Admin_Bar)
                      return Boolean
                      is (True);

   function Apply_Filters (Hook  : String;
                           Value : Array_Type;
                           User  : Inc_Class_Wp_Users.Wp_User)
                           return Array_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term_Array;
                           Id        : String;
                           Taxonomy  : String;
                           A4        : Array_Type := Empty_Array)
                           return Class_Terms.Wp_Term_Array
                           is (Class_Terms.Empty_Term_Array);

   function Apply_Filters (Hook_Name  : String;
                           A1         : Class_Terms.Wp_Term_Array;
                           A2         : List_Type;
                           A3         : Array_Type;
                           A4         : Array_Type)
                           return Class_Terms.Wp_Term_Array
                           is (Class_Terms.Empty_Term_Array);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Class_Posts.Wp_Post)
                           return Boolean
                           is (True);

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Id        : Class_Posts.Post_Id)
                           return Array_Type
                           is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           B         : String;
                           C         : Class_Posts.Wp_Post)
                           return List_Type
                           is (Empty_List);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Wp_Post;
                           B         : Boolean)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           B         : String;
                           C         : Class_Posts.Wp_Post)
                           return String
                           is ("XXX-980");

   function Apply_Filters (Hook_Name : String;
                           B         : String;
                           A         : String;
                           C         : Class_Posts.Wp_Post)
                           return String
                           is ("XXX-981");

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Id        : Adi_Class_Wp_Screens.Wp_Screen;
                           Arg_4     : Boolean := False)
                           return Array_Type
                           is (Empty_Array);

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term;
                           Cats      : Class_Terms.Wp_Term_Array;
                           Post      : Class_Posts.Wp_Post)
                           return Class_Terms.Wp_Term
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Wp_Post;
                           A         : Boolean;
                           B         : Boolean)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Post_Id;
                           B         : Boolean)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term_Array;
                           Post      : Class_Posts.Post_Id)
                           return Class_Terms.Wp_Term_Array
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Inc_Class_Wp_Taxonomy.Int_Arrays.Vector;
                           Id        : Integer;
                           Obj       : String;
                           Res       : String)
                           return Inc_Class_Wp_Taxonomy.Int_Arrays.Vector
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           Status    : Inc_Posts.Status_Type)
                           return Boolean
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           Status    : Class_Post_Type.Wp_Post_Type)
                           return Boolean
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String)
                           return Multi_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Passed    : Boolean)
                           return Multi_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Id        : Integer;
                           Default   : Multi_Type)
                           return Multi_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Id        : Integer)
                           return Multi_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Old       : Multi_Type;
                           Option    : String)
                           return Multi_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Old       : Multi_Type;
                           Option    : String;
                           Net       : Natural)
                           return Multi_Type
                           is (Value);

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Old       : Multi_Type)
                           return Multi_Type
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : Multi_Type;
                           Expiration : Natural;
                           Trans      : String)
                           return Multi_Type
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : Natural;
                           Value_2    : Multi_Type;
                           Trans      : String)
                           return Natural
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Path       : String;
                           Blog       : Integer;
                           Scheme     : String)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Typ        : String;
                           Args       : Array_Type)
                           return Adi_Translation_Install.Trans_Result
                           is ((Success => True,
                                Arry    => Empty_Array,
                                Error   => Class_Errors.Null_Wp_Error));

   function Apply_Filters (Hook_Name  : String;
                           Value      : Adi_Translation_Install.Trans_Result;
                           Typ        : String;
                           Args       : Array_Type)
                           return Adi_Translation_Install.Trans_Result
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : List_Type;
                           Args       : Array_Type;
                           URL        : String)
                           return List_Type
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Args       : Array_Type;
                           URL        : String)
                           return Array_Type
                           is (Empty_Array);

   function Apply_Filters (Hook_Name  : String;
                           Value      : Integer;
                           URL        : String)
                           return String
                           is ("XXX-987");

   function Apply_Filters (Hook_Name  : String;
                           Value      : Integer;
                           Name       : String)
                           return Integer
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Status     : Integer;
                           Location   : String)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Number     : Float;
                           Decimals   : Integer)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Code       : Integer;
                           Descript   : String;
                           Protocol   : String)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Funct      : String;
                           Message    : String;
                           Version    : String)
                           return Boolean
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : List_Type;
                           Host       : String)
                           return List_Type
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Email      : String;
                           Size       : Integer;
                           Default    : Array_Type;
                           Alt        : String;
                           Args       : Array_Type)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Size       : Integer;
                           Blog_Id    : Integer)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : Php.Calendar.Time_Type;
                           Format     : String;
                           GMT        : Boolean)
                           return String -- Php.Calendar.Time_Type
                           is ("XXX-844");

   function Apply_Filters (Hook_Name  : String;
                           Value      : Inc_Media.Image_Src_Type;
                           Id         : Integer;
                           Size       : String;
                           Icon       : Boolean)
                           return Inc_Media.Image_Src_Type
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Item       : String;
                           User       : Inc_Class_Wp_Users.Wp_User)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name   : String;
                           Value       : Class_Errors.Wp_Error;
                           Redirect_To : String)
                           return Class_Errors.Wp_Error
                           is (Value);

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           Redirect_To : String;
                           User        : Inc_Users.User_Error_Type)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           User        : Inc_Users.User_Id_Error_Type)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name   : String;
                           Value       : Inc_Users.User_Error_Type;
                           Username    : String;
                           Password    : String)
                           return Inc_Users.User_Error_Type
                           is (Value);

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           Errors      : Class_Errors.Wp_Error)
                           return String
                           is (Value);

   function Apply_Filters (Hook_Name   : String;
                           Value       : Boolean;
                           Credentials : Array_Type)
                           return Boolean
                           is (Value);

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Args       : Array_Type;
                           Typ        : String)
                           return Inc_Class_Wp_Http.Response_Result
                           is ((Success => Value,
                                Arry    => Empty_Array,
                                Error   => Class_Errors.Null_Wp_Error));

   function Apply_Filters (Hook_Name  : String;
                           Value      : Inc_Class_Wp_Http.Response_Result;
                           Args       : Array_Type;
                           URL        : String)
                           return Inc_Class_Wp_Http.Response_Result
                           is ((Success => True,
                                Arry    => Empty_Array,
                                Error   => Class_Errors.Null_Wp_Error));

   procedure Do_Action (Hook_Name : String;
                        A1        : Inc_Class_Wp_Http.Response_Result;
                        A2        : String;
                        A3        : String;
                        Args      : Array_Type;
                        Url       : String)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Error     : Class_Errors.Wp_Error)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        User      : Inc_Class_Wp_Users.Wp_User)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Login     : String;
                        User      : Inc_Class_Wp_Users.Wp_User)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Username  : String;
                        Error     : Class_Errors.Wp_Error)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer;
                        Role      : String)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer;
                        Role      : String;
                        Roles     : List_Type)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Action    : Integer;
                        Result    : Boolean)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Version_1 : Integer;
                        Version_2 : Integer)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Cookie    : Array_Type;
                        User      : Inc_Class_Wp_Users.Wp_User)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Nonce     : String;
                        Action    : String;
                        User      : Inc_Class_Wp_Users.Wp_User;
                        Token     : String)
                        is null;

   procedure Do_Action (Hook_Name : String;
                        Errors    : Class_Errors.Wp_Error;
                        User      : Inc_Users.User_Error_Type)
                        is null;

end Wp_Common;
