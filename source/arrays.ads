--
--
--

with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Finalization;
with Ada.Iterator_Interfaces;

limited with Arrayable_Interfaces;
with Lists;
with UStrings;

package Arrays
is

   subtype Key_Type is UStrings.UString;
   subtype Value_Type is UStrings.UString;

   type Array_Kind is
     (Kind_String,
      Kind_Integer,
      Kind_Array,
      Kind_List,
      Kind_Boolean,
      Kind_Callable,
      Kind_Null);

   type Null_Type is null record;

   Null_Value : constant Null_Type := (null record);

   type Array_Type;
   type Array_Access is access all Array_Type;

   type Multi_Type (Kind : Array_Kind) is private;
   type Multi_Access is access all Multi_Type;

   function "=" (Left, Right : Multi_Type) return Boolean;

   type Array_Type is tagged private
   with
     Default_Iterator => Iterate,
     --         Constant_Indexing => Constant_Reference,
     --         Variable_Indexing => Reference,
     Iterator_Element => Multi_Type;

   type Callable is
     access function
       (Arry : Arrayable_Interfaces.Arrayable_Interface'Class)
        return Array_Type;

   type Cursor is private;

   function Has_Element (Position : Cursor) return Boolean;

   package Map_Iterator_Interfaces is new
     Ada.Iterator_Interfaces (Cursor, Has_Element);

   function Key (Position : Cursor) return String;

   function Element (Position : Cursor) return Multi_Type;

   -- procedure Append (Arry  : in out Array_Type;
   --                   Value : Multi_Type);
   -- -- Append Value to Array_Type referenced by Cursor.

   procedure Append
     (Arry : in out Array_Type; Key : String; Value : Multi_Type);
   -- Append Value to Array_Type.

   procedure Append_2
     (Arry  : in out Array_Type;
      Key_1 : String;
      Key_2 : String;
      Value : Multi_Type);
   -- Append Value to Array_Type.

   procedure Delete (Arry : in out Array_Type; Key : String);

   procedure Include
     (Arry : in out Array_Type; Key : String; Value : Multi_Type);

   procedure Prepend
     (Arry : in out Array_Type; Key : String; Value : Multi_Type);

   procedure Replace
     (Arry : in out Array_Type; Key : String; Value : Multi_Type);

   function Is_Empty (Arry : Array_Type) return Boolean;

   ---------
   -- Ref --
   ---------

   function Ref_0 (Arry : Array_Type) return Array_Type;

   function Ref (Arry : Array_Type; Key : String) return Cursor;

   function Ref_2
     (Arry : Array_Type; Key_1 : String; Key_2 : String) return Cursor;

   function Ref_3
     (Arry : Array_Type; Key_1 : String; Key_2 : String; Key_3 : String)
      return Cursor;

   function Ref_4
     (Arry  : Array_Type;
      Key_1 : String;
      Key_2 : String;
      Key_3 : String;
      Key_4 : String) return Cursor;

   function Ref_5
     (Arry  : Array_Type;
      Key_1 : String;
      Key_2 : String;
      Key_3 : String;
      Key_4 : String;
      Key_5 : String) return Cursor;

   function Kind_Of (Arry : Multi_Type) return Array_Kind;

   function Is_Array (Multi : Multi_Type) return Boolean;
   function Is_Boolean (Multi : Multi_Type) return Boolean;
   function Is_Integer (Multi : Multi_Type) return Boolean;
   function Is_Null (Multi : Multi_Type) return Boolean;
   function Is_String (Multi : Multi_Type) return Boolean;

   function Empty (Obj : Cursor) return Boolean;

   --------
   -- As --
   --------

   function As_Array (Arry : Multi_Type) return Array_Type;

   function As_List (Arry : Multi_Type) return Lists.List_Type;

   function As_String (Arry : Multi_Type) return String;

   function As_Integer (Arry : Multi_Type) return Integer;

   function As_Boolean (Arry : Multi_Type) return Boolean;

   function As_Callable (Arry : Multi_Type) return Callable;

   ----------
   -- From --
   ----------

   function From_Array (Value : Array_Type) return Multi_Type;

   function From_List (Value : Lists.List_Type) return Multi_Type;

   function From_String (Value : String) return Multi_Type;

   function From_Integer (Value : Integer) return Multi_Type;

   function From_Callable (Value : Callable) return Multi_Type;

   function From_Boolean (Value : Boolean) return Multi_Type;

   function From_Null return Multi_Type;

   ---------
   -- Get --
   ---------

   function Get (Arry : Multi_Type) return String;

   function Get (Position : Cursor) return Multi_Type;

   function Get (Arry : Array_Type; Key : String) return Multi_Type;

   function Get (Position : Cursor; Key : String) return Multi_Type;

   function Get_As_String (Arry : Array_Type; Key : String) return String;

   ---------
   -- Set --
   ---------

   procedure Assign
     (Target : in out Array_Type;
      -- Cursor;
      Source : Cursor);

   procedure Set
     (Arry  : in out Array_Type;
      -- Position : Cursor;
      Value : Multi_Type);

   procedure Set (Arry : in out Array_Type; Key : String; Value : Multi_Type);

   procedure Set_2
     (Arry  : in out Array_Type;
      Key_1 : String;
      Key_2 : String;
      Value : Multi_Type);

   procedure Set_3
     (Arry  : in out Array_Type;
      Key_1 : String;
      Key_2 : String;
      Key_3 : String;
      Value : Multi_Type);

   procedure Set_4
     (Arry  : in out Array_Type;
      Key_1 : String;
      Key_2 : String;
      Key_3 : String;
      Key_4 : String;
      Value : Multi_Type);

   procedure Set_5
     (Arry  : in out Array_Type;
      Key_1 : String;
      Key_2 : String;
      Key_3 : String;
      Key_4 : String;
      Key_5 : String;
      Value : Multi_Type);

   -----------
   -- Isset --
   -----------

   function Isset (Position : Cursor; Key : String) return Boolean;

   function Isset (Arry : Array_Type; Key : String) return Boolean;

   function Isset_2
     (Arry : Array_Type; Key_1 : String; Key_2 : String) return Boolean;

   function Isset_3
     (Arry : Array_Type; Key_1 : String; Key_2 : String; Key_3 : String)
      return Boolean;

   function Isset_4
     (Arry  : Array_Type;
      Key_1 : String;
      Key_2 : String;
      Key_3 : String;
      Key_4 : String) return Boolean;

   function Isset_5
     (Arry  : Array_Type;
      Key_1 : String;
      Key_2 : String;
      Key_3 : String;
      Key_4 : String;
      Key_5 : String) return Boolean;

   function Isset_6
     (Arry  : Array_Type;
      Key_1 : String;
      Key_2 : String;
      Key_3 : String;
      Key_4 : String;
      Key_5 : String;
      Key_6 : String) return Boolean;

   procedure Delete (Position : Cursor);

   function Find (Arry : Array_Type; Key : String) return Cursor;

   function First_Key (Arry : Array_Type) return String;

   function First_Element (Arry : Array_Type) return Multi_Type;

   function Last_Element (Arry : Array_Type) return Multi_Type;

   function Length (Arry : Array_Type) return Natural;

   function Empty (Arry : Array_Type; Key : String) return Boolean;

   function Exists (Arry : Array_Type; Key : String) return Boolean
   is (True);

   -----------
   -- Build --
   -----------

   function Build (Key : String; Value : Array_Type) return Array_Type;

   function Build (Key : String; Value : Multi_Type) return Array_Type;

   function Build (Key : String; Value : Lists.List_Type) return Array_Type;

   function Build (Key : String; Value : String) return Array_Type;

   function Build (Key : String; Value : Integer) return Array_Type;

   function Build (Key : String; Value : Boolean) return Array_Type;

   function Build (Key : String; Value : Callable) return Array_Type;

   function Build (Key : String; Value : Null_Type) return Array_Type;

   function Empty_Array return Array_Type;

   function First (Container : Array_Type) return Cursor;
   function Next (Container : Array_Type; Position : Cursor) return Cursor;

   function Iterate
     (Container : Array_Type)
      return Map_Iterator_Interfaces.Forward_Iterator'Class;

private

   type Array_Holder is new Ada.Finalization.Controlled with
     record
        Holder : Array_Access;
     end record;

   overriding
   procedure Initialize (Holder : in out Array_Holder);

   overriding
   procedure Adjust (Holder : in out Array_Holder);

   overriding
   procedure Finalize (Holder : in out Array_Holder);

   Empty_Holder : constant Array_Holder :=
     (Ada.Finalization.Controlled with Holder => null);

   type Multi_Type (Kind : Array_Kind) is
      record
         case Kind is
         when Kind_String   =>  Str  : UStrings.UString;
         when Kind_Integer  =>  Int  : Integer          := 0;
         when Kind_Array    =>  Arry : Array_Holder     := Empty_Holder;
         when Kind_List     =>  List : Lists.List_Type;
         when Kind_Callable =>  Func : Callable         := null;
         when Kind_Boolean  =>  Bool : Boolean          := False;
         when Kind_Null     =>  null;
         end case;
      end record;

   package Array_Maps is
      new Ada.Containers.Indefinite_Ordered_Maps (Key_Type     => String,
                                                  Element_Type => Multi_Type);

   type Array_Type is new Array_Maps.Map with null record;

   type Cursor is new Array_Maps.Cursor;

   Null_Array_Type : constant Array_Type :=
     (Array_Maps.Empty_Map with null record);

   type Map_Access is access all Array_Type;
   for Map_Access'Storage_Size use 0;

   type Iterator is new
      Map_Iterator_Interfaces.Forward_Iterator with
      record
         Container : Map_Access;
      end record;

   overriding function First (Object : Iterator) return Cursor;

   overriding function Next
     (Object   : Iterator;
      Position : Cursor) return Cursor;

end Arrays;
