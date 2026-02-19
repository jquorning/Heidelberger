--
--
--

with Arrayable_Arrays;
with Logging;

with Inc_Plugins;

package body Wp_Common
is

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String := "";
                           X         : String := "")
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Args      : Array_Type)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           Post      : Class_Posts.Post_Id_Type)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Arg_3     : Array_Type;
                           Arg_4     : Array_Type := Empty_Array)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : String := "")
                           return Array_Type
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      return Inc_Plugins.Apply_Filters (Hook_Name, Value, Empty_Arrayable);
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           List      : List_Type)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : String;
                           I         : Integer)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           V         : String;
                           N         : Array_Type)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Right     : Integer := 0)
                           return Array_Type
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      return
        Inc_Plugins.Apply_Filters (Hook_Name, Value, Empty_Arrayable);
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : List_Type;
                           Right     : Integer := 0)
                           return List_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           Arg_2     : Positive;
                           Arg_3     : String;
                           Arg_4     : Boolean;
                           Arg_5     : String)
                           return Integer
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String := "";
                           P         : Array_Type)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           D         : String;
                           P         : List_Type)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           B         : String;
                           D         : String)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           S         : String;
                           B         : Boolean)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           B         : Integer := 0)
                           return Integer
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           B         : Integer;
                           S         : Boolean;
                           E         : Boolean)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           C         : String)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Integer)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Raw       : String;
                           Strict    : Boolean)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Path      : String;
                           Scheme    : String;
                           Blog      : Integer)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Integer;
                           Context   : String;
                           Allow     : Boolean)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Integer;
                           V         : Array_Type;
                           Trans     : String)
                           return Integer
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           User      : Class_Users.Wp_User)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term_Array;
                           Id        : String;
                           Taxonomy  : String;
                           A4        : Array_Type := Empty_Array)
                           return Class_Terms.Wp_Term_Array
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Class_Terms.Wp_Term_Array;
                           A2         : List_Type;
                           A3         : Array_Type;
                           A4         : Array_Type)
                           return Class_Terms.Wp_Term_Array
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Id        : Class_Posts.Wp_Post)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return False; -- Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Id        : Class_Posts.Post_Id_Type)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           C         : Class_Posts.Wp_Post)
                           return List_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Empty_List;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Wp_Post;
                           B         : Boolean)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           C         : Class_Posts.Wp_Post)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           A         : String;
                           C         : Class_Posts.Wp_Post)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Id        : Adi_Class_Wp_Screens.Wp_Screen;
                           Arg_4     : Boolean := False)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term;
                           Cats      : Class_Terms.Wp_Term_Array;
                           Post      : Class_Posts.Wp_Post)
                           return Class_Terms.Wp_Term
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Wp_Post;
                           A         : Boolean;
                           B         : Boolean)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Post      : Class_Posts.Post_Id_Type;
                           B         : Boolean)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Terms.Wp_Term_Array;
                           Post      : Class_Posts.Post_Id_Type)
                           return Class_Terms.Wp_Term_Array
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Taxonomy.Int_Arrays.Vector;
                           Id        : Integer;
                           Obj       : String;
                           Res       : String)
                           return Class_Taxonomy.Int_Arrays.Vector
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           Status    : Inc_Posts.Status_Type)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           Status    : Class_Post_Type.Wp_Post_Type)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Passed    : Boolean)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Id        : Integer;
                           Default   : Multi_Type)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Id        : Integer)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Old       : Multi_Type;
                           Option    : String)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Old       : Multi_Type;
                           Option    : String;
                           Net       : Natural)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           Option    : String;
                           Old       : Multi_Type)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Multi_Type;
                           Expiration : Natural;
                           Trans      : String)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Natural;
                           Value_2    : Multi_Type;
                           Trans      : String)
                           return Natural
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Path       : String;
                           Blog       : Integer;
                           Scheme     : String)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Typ        : String;
                           Args       : Array_Type)
                           return Adi_Translation_Install.Trans_Result
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Adi_Translation_Install.Trans_Result'(Success => False,
                                                   Arry    => Empty_Array,
                                                   Error   => Class_Errors.Null_Wp_Error);
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Adi_Translation_Install.Trans_Result;
                           Typ        : String;
                           Args       : Array_Type)
                           return Adi_Translation_Install.Trans_Result
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : List_Type;
                           Args       : Array_Type;
                           URL        : String)
                           return List_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Args       : Array_Type;
                           URL        : String)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Empty_Array;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Integer;
                           URL        : String)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return "XXX-942";
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Integer;
                           Name       : String)
                           return Integer
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Status     : Integer;
                           Location   : String)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Number     : Float;
                           Decimals   : Integer)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Code       : Integer;
                           Descript   : String;
                           Protocol   : String)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Funct      : String;
                           Message    : String;
                           Version    : String)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : List_Type;
                           Host       : String)
                           return List_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Email      : String;
                           Size       : Integer;
                           Default    : Array_Type;
                           Alt        : String;
                           Args       : Array_Type)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Size       : Integer;
                           Blog_Id    : Integer)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Php.Calendar.Time_Type;
                           Format     : String;
                           GMT        : Boolean)
                           return String -- Php.Calendar.Time_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return "XXX-943";
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Inc_Media.Image_Src_Type;
                           Id         : Integer;
                           Size       : String;
                           Icon       : Boolean)
                           return Inc_Media.Image_Src_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : String;
                           Item       : String;
                           User       : Class_Users.Wp_User)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name   : String;
                           Value       : Class_Errors.Wp_Error;
                           Redirect_To : String)
                           return Class_Errors.Wp_Error
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           Redirect_To : String;
                           User        : Inc_Users.User_Error_Type)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           User        : Inc_Users.User_Id_Error_Type)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name   : String;
                           Value       : Inc_Users.User_Error_Type;
                           Username    : String;
                           Password    : String)
                           return Inc_Users.User_Error_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name   : String;
                           Value       : Inc_Users.User_Error_Type;
                           Password    : String)
                           return Inc_Users.User_Error_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name   : String;
                           Value       : String;
                           Errors      : Class_Errors.Wp_Error)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name   : String;
                           Value       : Boolean;
                           Credentials : Array_Type)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Args       : Array_Type;
                           Typ        : String)
                           return Class_HTTP.Response_Result
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Class_HTTP.Response_Result'(Success => False,
                                         Arry    => Empty_Array,
                                         Error   => Class_Errors.Null_Wp_Error);
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Class_HTTP.Response_Result;
                           Args       : Array_Type;
                           URL        : String)
                           return Class_HTTP.Response_Result
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name  : String;
                           Value      : Boolean;
                           Object     : Integer;
                           Meta_Key   : String;
                           Meta_Value : String;
                           Delete_All : Boolean)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : List_Type;
                           T         : Class_Customize_Managers.Wp_Customize_Manager)
                           return List_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Customize_Managers.Wp_Customize_Setting;
                           Id        : String;
                           A         : Array_Type)
                           return Class_Customize_Managers.Wp_Customize_Setting
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Customize_Managers.Wp_Customize_Setting;
                           Id        : String;
                           Setting   : Boolean)
                           return Class_Customize_Managers.Wp_Customize_Setting
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           T         : Class_Customize_Managers.Wp_Customize_Manager)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           This      : Class_Customize_Settings.Wp_Customize_Setting)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Multi_Type;
                           This      : Class_Customize_Settings.Wp_Customize_Setting)
                           return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Class_Errors.Wp_Error;
                           Value_2   : Multi_Type;
                           This      : Class_Customize_Settings.Wp_Customize_Setting)
                           return Class_Errors.Wp_Error
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Array_Type;
               Item      : Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Array_Lists.Array_List;
               Item      : Class_Block_Editor_Contexts.Wp_Block_Editor_Context)
               return Array_Lists.Array_List
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters
              (Hook_Name : String;
               Value     : List_Type; -- Boolean;
               Item      : Class_Block_Editor_Contexts.Wp_Block_Editor_Context)                return List_Type -- Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           HTML      : Array_Type;
                           Protocols : List_Type)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : List_Type;
                           S         : String;
                           U         : Integer;
                           Args      : Inc_Capabilities.Args_Type)
                           return List_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Boolean;
                           S         : String;
                           O_Id      : Integer;
                           U_Id      : Integer;
                           C         : String;
                           L         : List_Type)
                           return Boolean
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Caps      : List_Type;
                           This      : Class_Users.Wp_User)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : String;
                           Text      : String;
                           Context   : String;
                           Domain    : String)
                           return String
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Natural;
                           U         : Natural;
                           P         : Natural)
                           return Natural
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Inc_Comments.Comment_Counts;
                           Post_Id   : Integer)
                           return Inc_Comments.Comment_Counts
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters (Hook_Name : String;
                           Value     : Array_Type;
                           Oi        : List_Type;
                           Tax       : Array_Type)
                           return Array_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Class_Sites.Wp_Site)
               return Class_Sites.Wp_Site
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Class_Users.User_Id_Type;
               Name      : String)
               return Class_Users.User_Id_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Array_Lists.Array_List)
               return Array_Lists.Array_List
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   function Apply_Filters
              (Hook_Name : String;
               Value     : Multi_Type;
               Old       : Multi_Type)
               return Multi_Type
   is
      use Arrayable_Arrays;

      Unused : Array_Type;
   begin
      Logging.Log ("apply_filters", Hook_Name);
      Unused := Inc_Plugins.Apply_Filters (Hook_Name, Empty_Array, Empty_Arrayable);
      return Value;
   end Apply_Filters;

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String := "";
                        Arg_3     : String := "")
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String;
                        Arg_3     : Boolean)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Arg_2     : String;
                        Arg_3     : Integer)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Net       : Natural)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type;
                        Option    : String)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Natural;
                        Option    : String)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Option    : String;
                        Arg_3     : Multi_Type;
                        Arg_4     : Multi_Type;
                        Net       : Natural)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Args      : Array_Type)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Tax       : String;
                        Arg_3     : List_Type;
                        Tax_2     : Class_Taxonomy.Wp_Taxonomy)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Role      : Class_Roles.Wp_Roles)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Code      : String;
                        Message   : String;
                        Data      : String;
                        Error     : Class_Errors.Wp_Error)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Value      : Array_Type;
                        Expiration : Integer;
                        Transient  : String)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Transient  : String;
                        Value      : Array_Type;
                        Expiration : Integer)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Arg_1      : String;
                        Arg_2      : String;
                        Arg_3      : String)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        A1        : Class_HTTP.Response_Result;
                        A2        : String;
                        A3        : String;
                        Args      : Array_Type;
                        Url       : String)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Error     : Class_Errors.Wp_Error)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Class_Users.Wp_User)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Login     : String;
                        User      : Class_Users.Wp_User)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Username  : String;
                        Error     : Class_Errors.Wp_Error)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer;
                        Role      : String)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer;
                        Role      : String;
                        Roles     : List_Type)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Integer)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Action    : Integer;
                        Result    : Boolean)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Version_1 : Integer;
                        Version_2 : Integer)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Cookie    : Array_Type;
                        User      : Class_Users.Wp_User)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Nonce     : String;
                        Action    : String;
                        User      : Class_Users.Wp_User;
                        Token     : String)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Errors    : Class_Errors.Wp_Error;
                        User      : Inc_Users.User_Error_Type)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Meta_Ids   : List_Type;
                        Object_Is  : Integer;
                        Meta_Key   : String;
                        Meta_Value : String)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name  : String;
                        Meta_Ids   : List_Type)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Value     : Array_Type;
                        This      : Class_Customize_Managers.Wp_Customize_Manager)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        Value     : String;
                        Value_2   : Array_Type;
                        This      : Class_Customize_Managers.Wp_Customize_Manager)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        This      : Class_Customize_Settings.Wp_Customize_Setting)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

   procedure Do_Action (Hook_Name : String;
                        User      : Class_Users.User_Id_Type)
   is
      use Arrayable_Arrays;
   begin
      Logging.Log ("do_action", Hook_Name);
      Inc_Plugins.Do_Action (Hook_Name, Empty_Arrayable);
   end Do_Action;

end Wp_Common;
